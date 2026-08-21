unit sendR;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Набор клавиш по строке в духе SendKeys: имя клавиши в фигурных скобках,
  @ -- Alt, ^ -- Ctrl, ~ -- Shift, всё остальное идёт как есть. }

interface

uses Windows;

function SendKeysEx(AWnd: HWND; S: string; ADelay: Integer;
                    ARef: Pointer; AFlag: Integer): Byte;
procedure SendKeysBody(S: string; ADelay: Integer; ARef: Pointer;
  AFlag: Integer);
procedure SendOneKey(W: Word; ADelay: Integer; AFlag: Integer);

implementation

uses
{$IFnDEF FPC}
  Gauges,
{$ELSE}
{$ENDIF}
  SysUtils, Keydefs, uScanThread;

var
  { Залипшие модификаторы набора. У макроса своя такая же тройка --
    смешивать их нельзя. }
  gSkAlt: Boolean;
  gSkCtrl: Boolean;
  gSkShift: Boolean;

{ Послать текст в окно. Пустая строка -- это сброс залипших модификаторов:
  правый Shift снимается расширенным кодом, дальше Shift, Ctrl и Alt
  обычными. Ошибка разбора отдаётся кодом 3. }
function SendKeysEx(AWnd: HWND; S: string; ADelay: Integer;
                    ARef: Pointer; AFlag: Integer): Byte;
begin
  if S = '' then
  begin
    keybd_event($A1, MapVirtualKey($A1, 0), 3, 0);
    keybd_event($10, MapVirtualKey($10, 0), 0, 0);
    keybd_event($10, MapVirtualKey($10, 0), 2, 0);
    keybd_event($11, MapVirtualKey($11, 0), 2, 0);
    keybd_event($12, MapVirtualKey($12, 0), 2, 0);
  end;
  Result := 0;
  try
    SendKeysBody(S, ADelay, ARef, AFlag);
  except
    Result := 3;
  end;
end;

{ Сам набор клавиш: разбор строки и посылка в окно. }
procedure SendKeysBody(S: string; ADelay: Integer; ARef: Pointer;
  AFlag: Integer);
var
  nI: Integer;
  nLen: Integer;
  bVK: Byte;
  nNum: Integer;
  sTok: string;
  bLay: Boolean;
  nK: Word;
begin
  nI := 1;
  nLen := Length(S);
  bLay := False;
  repeat
    case S[nI] of
      '{':
        begin
          sTok := '';
          Inc(nI);
          while (nI <= nLen) and (S[nI] <> '}') do
          begin
            sTok := sTok + S[nI];
            Inc(nI);
          end;
          nNum := StrToIntDef(sTok, 0);
          if not TextToVKey(sTok, bVK) then
            if nNum <> 0 then
              bVK := Byte(nNum)
            else
              raise Exception.Create('Invalid token');
          SendOneKey(MakeWord(bVK, 0), ADelay, AFlag);
        end;
      '@':
        begin
          gSkAlt := True;
          keybd_event($12, MapVirtualKey($12, 0), 0, 0);
        end;
      '^':
        begin
          gSkCtrl := True;
          keybd_event($11, MapVirtualKey($11, 0), 0, 0);
        end;
      '~':
        begin
          gSkShift := True;
          keybd_event($10, $2A, 0, 0);
        end;
    else
      begin
        nK := VkKeyScan(S[nI]);
        if nK = $FFFF then
        begin
          { Символа нет в текущей раскладке -- перекидываем её на другую
            и пробуем ещё раз. bLay помнит, что раскладку трогали, чтобы
            в конце вернуть как было. }
          if not bLay then
          begin
            ActivateKeyboardLayout(1, 0);
            bLay := not bLay;
          end
          else
          begin
            ActivateKeyboardLayout(0, 0);
            bLay := not bLay;
          end;
          nK := VkKeyScan(S[nI]);
        end;
        SendOneKey(nK, ADelay, AFlag);
      end;
    end;
    Inc(nI);
    { По команде «стоп» уходим сразу -- раскладку назад не возвращаем. }
    if TScanThread(ARef).StopRequested then
      Exit;
  until nI > Length(S);
  if bLay then
    ActivateKeyboardLayout(0, 0);
end;

{ Послать один код (младший байт W) с модификаторами из старшего:
  1 -- Shift, 2 -- Ctrl, 4 -- Alt. У Shift скан-код зашит числом, у
  остальных берём у MapVirtualKey. AFlag = 1 -- только нажатие,
  2 -- только отпускание. В конце снимаем залипшие. }
procedure SendOneKey(W: Word; ADelay: Integer; AFlag: Integer);
var
  bSC: Byte;
  bVK: Byte;
  nMod: Word;
begin
  bVK := Byte(W);
  bSC := MapVirtualKey(bVK, 0);
  nMod := Hi(W);
  if nMod > 0 then
  begin
    if nMod and 1 = 1 then
      keybd_event($10, $2A, 0, 0);
    if nMod and 2 = 2 then
      keybd_event($11, MapVirtualKey($11, 0), 0, 0);
    if nMod and 4 = 4 then
      keybd_event($12, MapVirtualKey($12, 0), 0, 0);
  end;
  if AFlag <> 2 then
    try
      if gSkShift then
        keybd_event(bVK, bSC, 1, 0)
      else
        keybd_event(bVK, bSC, 0, 0);
    except
    end;
  Windows.Sleep(1);
  if AFlag <> 1 then
    try
      keybd_event(bVK, bSC, 2, 0);
    except
    end;
  nMod := Hi(W);
  if nMod > 0 then
  begin
    if nMod and 1 = 1 then
      keybd_event($10, $2A, 2, 0);
    if nMod and 2 = 2 then
      keybd_event($11, MapVirtualKey($11, 0), 2, 0);
    if nMod and 4 = 4 then
      keybd_event($12, MapVirtualKey($12, 0), 2, 0);
  end;
  if gSkAlt then
  begin
    gSkAlt := False;
    keybd_event($12, MapVirtualKey($12, 0), 2, 0);
  end;
  if gSkCtrl then
  begin
    gSkCtrl := False;
    keybd_event($11, MapVirtualKey($11, 0), 2, 0);
  end;
  if gSkShift then
  begin
    gSkShift := False;
    keybd_event($10, $2A, 2, 0);
  end;
  if ADelay > 0 then
    Windows.Sleep(ADelay);
end;

end.
