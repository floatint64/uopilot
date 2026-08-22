unit SKey;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Служба-драйвер для посылки клавиш. Сам драйвер лежит в plugins\ и
  ставится как служба ядра; дальше коды клавиш уходят ему через
  DeviceIoControl, минуя очередь сообщений. }

interface

uses Windows;

function SvcInstall(Name, Plugin: string): Integer;
function SvcRemove(Name: string): Boolean;
function SvcQueryState(Name: string): Cardinal;
function SvcSendKeys(S: string): Boolean;

implementation

uses
{$IFnDEF FPC}
  WinSvc,
{$ELSE}
{$ENDIF}
  SysUtils, MathEx, Unit1, CRCunit, uCircleForm, sendR, HotKeyMgr, Keydefs, uScanThread;

var
  gSvcMgr: THandle;                  { менеджер служб }
  gSvcHandle: THandle;               { сама служба }
  gSvcStatus: TServiceStatus;
  gSvcDev: THandle;                  { ручка драйвера }

{ Ставим драйвер службой и открываем его. Старую службу с тем же именем
  сначала сносим -- иначе останется висеть прежний файл.
  Итог: состояние службы, либо отрицательный код, на чём споткнулись. }
function SvcInstall(Name, Plugin: string): Integer;
var
  s: string;
begin
  gSvcMgr := OpenSCManagerA(nil, nil, 3);
  if gSvcMgr > 0 then
  begin
    if gSvcHandle <> 0 then
    begin
      if gSvcDev > 0 then
      begin
        FileClose(gSvcDev); { *Преобразовано из CloseHandle* }
        gSvcDev := 0;
      end;
      ControlService(gSvcHandle, 1, gSvcStatus);
      DeleteService(gSvcHandle);
      CloseServiceHandle(gSvcHandle);
      gSvcHandle := 0;
    end;
    gSvcHandle := OpenServiceA(gSvcMgr, PChar(Name), $F01FF);
    if gSvcHandle <= 0 then
    begin
      CloseServiceHandle(gSvcHandle);
      s := ExtractFilePath(ParamStr(0));
      gSvcHandle := CreateServiceA(gSvcMgr, PChar(Name), PChar(Name), $F01FF,
        1, 3, 0, PChar(s + 'plugins\' + Plugin + '.dll'),
        nil, nil, nil, nil, nil);
    end;
    if gSvcHandle > 0 then
    begin
      StartServiceA(gSvcHandle, 0, nil);
      if QueryServiceStatus(gSvcHandle, gSvcStatus) then
      begin
        Result := gSvcStatus.dwCurrentState;
        if Result = 4 then
        begin
          gSvcDev := CreateFile(PChar('\\.\' + Name), $C0000000, 3, nil,
            3, 0, 0);
          if gSvcDev = INVALID_HANDLE_VALUE then
          begin
            FileClose(gSvcDev); { *Преобразовано из CloseHandle* }
            gSvcDev := 0;
            Result := -5;
          end;
        end
        else
          Result := -4;
      end
      else
        Result := -3;
    end
    else
    begin
      Result := -2;
      CloseServiceHandle(gSvcHandle);
      gSvcHandle := 0;
    end;
  end
  else
    Result := -1;
  CloseServiceHandle(gSvcMgr);
  gSvcMgr := 0;
end;

{ Снос службы. Если ручка ещё жива -- сносим по ней, иначе открываем
  службу по имени. }
function SvcRemove(Name: string): Boolean;
begin
  Result := False;
  if gSvcDev > 0 then
  begin
    FileClose(gSvcDev); { *Преобразовано из CloseHandle* }
    gSvcDev := 0;
  end;
  if gSvcHandle > 0 then
  begin
    ControlService(gSvcHandle, 1, gSvcStatus);
    DeleteService(gSvcHandle);
    CloseServiceHandle(gSvcHandle);
    gSvcHandle := 0;
    Result := True;
  end
  else
  begin
    gSvcMgr := OpenSCManagerA(nil, nil, 1);
    if gSvcMgr > 0 then
    begin
      gSvcHandle := OpenServiceA(gSvcMgr, PChar(Name), $24);
      DeleteService(gSvcHandle);
      CloseServiceHandle(gSvcHandle);
      gSvcHandle := 0;
      Result := True;
    end;
    CloseServiceHandle(gSvcMgr);
    gSvcMgr := 0;
  end;
end;

{ Состояние службы прямо из SERVICE_STATUS; 1 -- остановлена или её нет. }
function SvcQueryState(Name: string): Cardinal;
begin
  Result := 1;
  gSvcMgr := OpenSCManagerA(nil, nil, 1);
  if gSvcMgr > 0 then
  begin
    gSvcHandle := OpenServiceA(gSvcMgr, PChar(Name), 4);
    if gSvcHandle > 0 then
    begin
      if QueryServiceStatus(gSvcHandle, gSvcStatus) then
        Result := gSvcStatus.dwCurrentState;
      CloseServiceHandle(gSvcHandle);
      gSvcHandle := 0;
    end;
    CloseServiceHandle(gSvcMgr);
    gSvcMgr := 0;
  end;
end;

{ Разбор имени клавиши и отправка её драйверу. Сперва ищем имя целиком
  ('F5', 'Enter'); не нашлось -- значит пришёл обычный текст, и разбираем
  его побуквенно тем же обходом. Драйверу уходит скан-код. }
function SvcSendKeys(S: string): Boolean;
var
  sc, ob: Byte;
  br: DWORD;
  i, j, n: Integer;
  vk: Byte;
begin
  Result := False;
  vk := 0;
  for j := 0 to 101 do
    if CompareText(S, AnsiLowerCase(gHKNameTablee9[j])) = 0 then
    begin
      vk := gHKCodeTablepz[j];
      Break;
    end;
  if vk <> 0 then
    n := 1
  else
    n := Length(S);
  for i := 1 to n do
  begin
    for j := 0 to 101 do
      if CompareText(AnsiLowerCase(S[i]), AnsiLowerCase(gHKNameTablee9[j])) = 0 then
      begin
        vk := gHKCodeTablepz[j];
        Break;
      end;
    if vk <> 0 then
    begin
      j := MapVirtualKey(vk, 0);
      sc := j;
      if DeviceIoControl(gSvcDev, $22E000, @sc, 1, @ob, 1, br, nil) then
        Result := True
      else
        Result := False;
    end;
  end;
end;

end.
