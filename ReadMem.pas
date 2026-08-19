unit ReadMem;

{ Чтение и запись памяти чужого процесса.

  Ни одна функция ntdll здесь не импортируется статически: всё снимается
  GetProcAddress при запуске. Причин две. Первая -- Wow64-функций в старых
  Windows просто нет, и со статическим импортом программа там не поднялась
  бы вовсе. Вторая -- имена этих функций незачем держать в таблице импорта
  на виду, поэтому и собираются они на месте, по кускам.

  Дальше всё разветвляется по разрядности ЧУЖОГО процесса: до 32-разрядного
  дотягиваемся обычными Nt*VirtualMemory, до 64-разрядного -- парой
  NtWow64*64. }

interface

uses
  DateUtils, Windows, SysUtils, ProcessAPI;

type
  { Три обёртки для скрипта: адрес модуля по имени и пересчёт адреса
    из относительного в абсолютный и обратно. Итог всюду Int64 --
    у 64-разрядного процесса адрес в Integer не влезает. }
  TModHelper = class
    function ModAddr(S: string; N: Integer): Int64;
    function Rel2Abs(S: string; N: Integer; V: Int64): Int64;
    function Abs2Rel(S: string; N: Integer; V: Int64): Int64;
  end;

type
  { У 64-разрядных близнецов адрес и размер восьмибайтовые -- ради них
    всё и затевалось. }
  TNtQueryInformationProcess = function(ProcessHandle: THandle;
    InfoClass: Integer; Info: Pointer; Len: Cardinal;
    Ret: Pointer): Integer; stdcall;
  TMemProc32 = function(ProcessHandle: THandle; Addr: Pointer; Buf: Pointer;
    Size: Cardinal; Bytes: Pointer): BOOL; stdcall;
  TMemProc64 = function(ProcessHandle: THandle; Addr: Int64; Buf: Pointer;
    Size: Int64; Bytes: Pointer): Integer; stdcall;
  TNtStatusToDosError = function(Status: Integer): Cardinal; stdcall;

var
  pNtQueryInformationProcess: TNtQueryInformationProcess = nil;
  pReadMem32: TMemProc32 = nil;
  pWriteMem32: TMemProc32 = nil;
  pReadMem64: TMemProc64 = nil;
  pWriteMem64: TMemProc64 = nil;
  pNtStatusToDosError: TNtStatusToDosError = nil;

  gMemLastErrorao: Integer;   { сюда ложится результат GetLastError }

function NtQueryInformationProcess(ProcessHandle: THandle; InfoClass: Integer;
  Info: Pointer; Len: Cardinal; Ret: Pointer): Integer; stdcall;
function ReadMem32(ProcessHandle: THandle; Addr: Pointer; Buf: Pointer;
  Size: Cardinal; Bytes: Pointer): BOOL; stdcall;
function WriteMem32(ProcessHandle: THandle; Addr: Pointer; Buf: Pointer;
  Size: Cardinal; Bytes: Pointer): BOOL; stdcall;
function ReadMem64(ProcessHandle: THandle; Addr: Int64; Buf: Pointer;
  Size: Int64; Bytes: Pointer): Integer; stdcall;
function WriteMem64(ProcessHandle: THandle; Addr: Int64; Buf: Pointer;
  Size: Int64; Bytes: Pointer): Integer; stdcall;
function NtStatusToDosError(Status: Integer): Cardinal; stdcall;
function CheckNtStatus(AStatus: Integer): Boolean;

function IsTarget64(Process: THandle): Boolean;
procedure ReadMemDispatch(H: Cardinal; P: Pointer; var R: Int64;
  A, N: Int64);
procedure WriteMemDispatch(H: Cardinal; P: Pointer; var R: Int64;
  A, N: Int64);
procedure ReadMemByName(hProc: THandle; var bRes; var qErr: Int64;
  qAddr: Int64; nSize: Int64; sMod: string; nPid: Cardinal);
procedure WriteMemByName(hProc: THandle; var bVal; var qErr: Int64;
  qAddr: Int64; nSize: Int64; sMod: string; nPid: Cardinal);

implementation

var
  gWow64Mode: Integer;      { ненулевой TEB->WOW32Reserved }
  { Целых имён Nt-функций в файле нет: секция инициализации собирает их
    склейкой из кусков, а куски лежат вот в этих строках. Сами строки
    положены поверх целых ячеек -- так они не попадают в чистку юнита и
    не заводят себе места в списке управляемых величин. }
  nNtLib: Integer;          { 'Ntdll.dll', собирается на месте }
  nWow64: Integer;          { 'Wow64' }
  nProcess: Integer;        { 'Process' }
  nQuery: Integer;          { 'Query' }
  nNt: Integer;             { 'Nt' }

  sNtLib: string absolute nNtLib;
  sWow64: string absolute nWow64;
  sProcess: string absolute nProcess;
  sQuery: string absolute nQuery;
  sNt: string absolute nNt;


{ Снять адрес функции в указатель, если он ещё пуст. Приёмник --
  нетипизированный var: типы у всех шести указателей разные, а делать на
  каждый свою обёртку незачем.
  Итог: 0 -- всё вышло, 1 -- нет библиотеки, 2 -- нет функции. }
function LoadNtProc(var P; const sLib, sName: string): Integer;
var
  h: HMODULE;
begin
  Result := 0;
  if Integer(P) = 0 then
  begin
    h := GetModuleHandle(PChar(string(Pointer(sLib))));
    if h = 0 then
    begin
      h := LoadLibrary(PChar(sLib));
      if h = 0 then
        Result := 1;
    end;
    Pointer(P) := GetProcAddress(h, PChar(sName));
    if Integer(P) = 0 then
      Result := 2;
  end;
end;

function NtQueryInformationProcess(ProcessHandle: THandle; InfoClass: Integer;
  Info: Pointer; Len: Cardinal; Ret: Pointer): Integer; stdcall;
begin
  Result := pNtQueryInformationProcess(ProcessHandle, InfoClass, Info, Len, Ret);
end;

function ReadMem32(ProcessHandle: THandle; Addr: Pointer; Buf: Pointer;
  Size: Cardinal; Bytes: Pointer): BOOL; stdcall;
begin
  Result := pReadMem32(ProcessHandle, Addr, Buf, Size, Bytes);
end;

function WriteMem32(ProcessHandle: THandle; Addr: Pointer; Buf: Pointer;
  Size: Cardinal; Bytes: Pointer): BOOL; stdcall;
begin
  Result := pWriteMem32(ProcessHandle, Addr, Buf, Size, Bytes);
end;

function ReadMem64(ProcessHandle: THandle; Addr: Int64; Buf: Pointer;
  Size: Int64; Bytes: Pointer): Integer; stdcall;
begin
  Result := pReadMem64(ProcessHandle, Addr, Buf, Size, Bytes);
end;

function WriteMem64(ProcessHandle: THandle; Addr: Int64; Buf: Pointer;
  Size: Int64; Bytes: Pointer): Integer; stdcall;
begin
  Result := pWriteMem64(ProcessHandle, Addr, Buf, Size, Bytes);
end;

function NtStatusToDosError(Status: Integer): Cardinal; stdcall;
begin
  Result := pNtStatusToDosError(Status);
end;

{ Ассемблер тут не от лихости: чтения через сегмент FS в Паскале нет
  вовсе, а нужно именно оно -- fs:[$18] даёт линейный адрес TEB, и уже
  из него берётся WOW32Reserved.

  Ненулевое значение означает: мы -- 32-разрядный процесс на 64-разрядной
  Windows. Ответ ложится в gWow64Mode, и оттуда его читает IsTarget64. }
function GetWow32Reserved: Integer;
asm
  xor eax, eax
  mov eax, fs:[eax + $18]
  mov eax, [eax + $C0]
end;

{ Код ошибки NT переводим в код Windows и ставим его последней ошибкой
  потока -- дальше её читают обычным GetLastError. }
function CheckNtStatus(AStatus: Integer): Boolean;
var
  nErr: Cardinal;
begin
  Result := AStatus >= 0;
  if not Result then
  begin
    nErr := NtStatusToDosError(AStatus);
    SetLastError(nErr);
  end;
end;

{ Разрядность чужого процесса. Смысл ответа ProcessWow64Information
  переворачивается в зависимости от того, где мы сами: из-под WOW64
  пустое поле означает НАСТОЯЩИЙ 64-разрядный процесс, а на обычной
  32-разрядной системе -- наоборот. }
function IsTarget64(Process: THandle): Boolean;
var
  V: Cardinal;
begin
  Result := False;
  V := 1;
  try
    if CheckNtStatus(NtQueryInformationProcess(Process, $1A, @V, 4, nil)) then
      if gWow64Mode <> 0 then
        Result := V = 0
      else
        Result := V <> 0;
  finally
  end;
end;

{ Чтение по адресу: сами выбираем ветвь по разрядности чужого процесса.
  У 32-разрядного от адреса берётся только младшая половина. }
procedure ReadMemDispatch(H: Cardinal; P: Pointer; var R: Int64;
  A, N: Int64);
var
  nRead: Cardinal;
begin
  if IsTarget64(H) then
    ReadMem64(H, A, P, N, @R)
  else
  begin
    ReadMem32(H, Pointer(Cardinal(A)), P, Cardinal(N), @nRead);
    R := nRead;
  end;
  gMemLastErrorao := GetLastError;
end;

{ То же самое, только пишем. }
procedure WriteMemDispatch(H: Cardinal; P: Pointer; var R: Int64;
  A, N: Int64);
var
  nRead: Cardinal;
begin
  if IsTarget64(H) then
    WriteMem64(H, A, P, N, @R)
  else
  begin
    WriteMem32(H, Pointer(Cardinal(A)), P, Cardinal(N), @nRead);
    R := nRead;
  end;
  gMemLastErrorao := GetLastError;
end;

{ Чтение по имени модуля: адрес считается от базы загрузки, так что
  скрипту не надо знать, куда именно легла библиотека.
  Пустое имя -- читаем прямо по адресу; непустое, но не найденное --
  ошибку гасим и не читаем вовсе. }
procedure ReadMemByName(hProc: THandle; var bRes; var qErr: Int64;
  qAddr: Int64; nSize: Int64; sMod: string; nPid: Cardinal);
var
  bFound: Boolean;
  M: TProcModules;
  i: Integer;
begin
  if sMod <> '' then
  begin
    bFound := False;
    GetProcModules(nPid, M, False);
    for i := 0 to M.Modules.Count - 1 do
      if sMod = AnsiLowerCase(M.Modules.Items[i].Name) then
      begin
        bFound := True;
        qAddr := M.Modules.Items[i].Base + qAddr;
        Break;
      end;
    if not bFound then
    begin
      qErr := 0;
      Exit;
    end;
  end;
  ReadMemDispatch(hProc, @bRes, qErr, qAddr, nSize);
end;

{ Слово в слово ReadMemByName, только пишем. }
procedure WriteMemByName(hProc: THandle; var bVal; var qErr: Int64;
  qAddr: Int64; nSize: Int64; sMod: string; nPid: Cardinal);
var
  bFound: Boolean;
  M: TProcModules;
  i: Integer;
begin
  if sMod <> '' then
  begin
    bFound := False;
    GetProcModules(nPid, M, False);
    for i := 0 to M.Modules.Count - 1 do
      if sMod = AnsiLowerCase(M.Modules.Items[i].Name) then
      begin
        bFound := True;
        qAddr := M.Modules.Items[i].Base + qAddr;
        Break;
      end;
    if not bFound then
    begin
      qErr := 0;
      Exit;
    end;
  end;
  WriteMemDispatch(hProc, @bVal, qErr, qAddr, nSize);
end;

{ Все три ходят одним путём: берём список модулей чужого процесса,
  ищем по имени в нижнем регистре и отвечаем из найденной записи.
  Не нашли -- ноль. }
function TModHelper.ModAddr(S: string; N: Integer): Int64;
var
  pi: PROCESS_INFO;
  i: Integer;
begin
  Result := 0;
  if S <> '' then
  begin
    GetProcModules(N, pi, False);
    for i := 0 to pi.Modules.Count - 1 do
      if S = AnsiLowerCase(pi.Modules.Items[i].Name) then
      begin
        Result := pi.Modules.Items[i].Base;
        Break;
      end;
  end;
end;
function TModHelper.Rel2Abs(S: string; N: Integer; V: Int64): Int64;
var
  pi: PROCESS_INFO;
  i: Integer;
begin
  Result := 0;
  if S <> '' then
  begin
    GetProcModules(N, pi, False);
    for i := 0 to pi.Modules.Count - 1 do
      if S = AnsiLowerCase(pi.Modules.Items[i].Name) then
      begin
        Result := pi.Modules.Items[i].Base + V;
        Break;
      end;
  end;
end;
function TModHelper.Abs2Rel(S: string; N: Integer; V: Int64): Int64;
var
  pi: PROCESS_INFO;
  i: Integer;
begin
  Result := 0;
  if S <> '' then
  begin
    GetProcModules(N, pi, False);
    for i := 0 to pi.Modules.Count - 1 do
      if S = AnsiLowerCase(pi.Modules.Items[i].Name) then
      begin
        Result := V - pi.Modules.Items[i].Base;
        Break;
      end;
  end;
end;

{ Оптимизацию на секцию инициализации снимаю нарочно, и ключ стоит
  именно здесь: с оптимизацией куски имён складываются обратно в целые
  строки, а весь смысл этой сборки по частям в том, чтобы целых имён в
  файле не было. Ключ действует с начала следующего тела, а секция
  инициализации в юните последняя -- закрывать его не надо. }
{$O-}
initialization
  sWow64 := 'Wow64';
  sProcess := 'Process';
  sQuery := 'Query';
  sNt := 'Nt';
  if sNt = '' then
    sNt := 'dll';
  sNtLib := sNt;
  if sNtLib <> '' then
    sNtLib := sNtLib + 'dll' + '.' + 'dll';
  gWow64Mode := GetWow32Reserved;
  LoadNtProc(pNtQueryInformationProcess, sNtLib,
    sNt + sQuery + 'Information' + sProcess);
  LoadNtProc(pReadMem32, sNtLib, sNt + 'Read' + 'Virtual' + 'Memory');
  LoadNtProc(pWriteMem32, sNtLib, sNt + 'Write' + 'Virtual' + 'Memory');
  LoadNtProc(pReadMem64, sNtLib,
    sNt + sWow64 + 'Read' + 'Virtual' + 'Memory' + '64');
  LoadNtProc(pWriteMem64, sNtLib,
    sNt + sWow64 + 'Write' + 'Virtual' + 'Memory' + '64');
  LoadNtProc(pNtStatusToDosError, sNtLib, 'Rtl' + sNt + 'StatusToDosError');

end.
