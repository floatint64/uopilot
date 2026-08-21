unit ProcessAPI;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Всё, что мы знаем о чужом процессе: сведения из PEB, список загруженных
  модулей, счётчики памяти и дескрипторов, командная строка.

  Разбор идёт ДВУМЯ ветвями. Под 32-разрядной Windows и для процессов под
  WOW64 хватает обычных NtQueryInformationProcess/NtReadVirtualMemory:
  всё, что нам надо, лежит в первых четырёх гигабайтах. Для настоящего
  64-разрядного процесса из-под нашего 32-разрядного те же данные
  приходится доставать через NtWow64*64 -- иначе адреса не влезают. Обе
  ветви заполняют одну и ту же PROCESS_INFO. }

interface

uses Windows, SysUtils;

type
  { Снимаем через GetProcAddress, а не импортом: в Windows 2000 этой
    функции нет, и со статическим импортом программа там не запустилась
    бы вовсе. }
  TIsWow64Process = function(hProcess: THandle;
    var Wow64Process: BOOL): BOOL; stdcall;

  { Осторожно с шириной доводов: у чтения адрес и размер восьмибайтовые,
    а у запроса длина буфера обычная, четырёхбайтовая. }
  TNtWow64Read = function(hProcess: THandle; BaseAddress: Int64;
    Buffer: Pointer; Size: Int64; Read: Pointer): Integer; stdcall;

  TNtWow64Query = function(hProcess: THandle; InfoClass: Integer;
    Info: Pointer; InfoLen: Cardinal; RetLen: Pointer): Integer; stdcall;

  { Один модуль чужого процесса. Всё восьмибайтовое нарочно: та же запись
    заполняется и из 64-разрядного списка. }
  TModuleInfo = record
    Path   : string;
    Name   : string;
    Base   : Int64;
    Size   : Int64;
    Res18  : Cardinal;                 { SizeOfImage }
    Res1C  : Cardinal;
  end;

  TModulesList = record
    Count  : Integer;
    Items  : array of TModuleInfo;
  end;

  { Всё, что мы собрали о процессе. Заполняется целиком любой из двух
    ветвей разбора, поэтому поля адресов и здесь восьмибайтовые. }
  PROCESS_INFO = record
    hProc     : Cardinal;              { дескриптор процесса; закрывается
                                         тут же, в конце разбора }
    Res04     : Cardinal;
    Pid       : Int64;
    ParentPid : Int64;
    SessionId : Cardinal;
    Res1C     : Cardinal;
    Priority  : Int64;                 { базовый приоритет -- он знаковый }
    Affinity  : Int64;
    Debugged  : Byte;                  { BeingDebugged из PEB }
    Res31     : array[0..2] of Byte;
    ExitCode  : Cardinal;
    Threads   : Cardinal;              { из PROCESSENTRY32 }
    Handles   : Cardinal;
    PrivMem   : Cardinal;              { PrivateUsage; ради него и берётся
                                         расширенная запись счётчиков }
    Res44     : Cardinal;
    ImageBase : Int64;
    LdrAddr   : Int64;
    PebAddr   : Int64;
    ConHandle : Int64;                 { дальше -- из параметров процесса }
    StdIn     : Int64;
    StdOut    : Int64;
    StdErr    : Int64;
    ExeFile   : string;                { szExeFile из TlHelp32 }
    CurDir    : string;
    ImagePath : string;
    CmdLine   : string;
    Modules   : TModulesList;
    IsWow     : Integer;               { процесс НЕ под WOW64, то есть
                                         настоящий 64-разрядный }
    Res9C     : Cardinal;
  end;

  { Имя, под которым запись знает ReadMem. }
  TProcModules = PROCESS_INFO;

var
  { Обе ntdll'ные функции снимает InitProcApi. }
  pNtWow64Query: TNtWow64Query;        { NtWow64QueryInformationProcess64 }
  pNtWow64Read: TNtWow64Read;          { NtWow64ReadVirtualMemory64 }
  pIsWow64Process: TIsWow64Process;
  gOS64: Integer = 0;                  { система 64-разрядная. При нуле
                                         список модулей читается
                                         32-разрядной ветвью, каким бы ни
                                         был сам процесс }

procedure GetProcModules(APid: Cardinal; out AList: PROCESS_INFO;
  AFlag: Boolean);

function SetDebugPrivilege(Enable: Boolean): Boolean;

implementation

{ Из TlHelp32 берём снимок процессов и тип TProcessEntry32; сами
  Process32First/Next объявлены ниже заново -- в юните они обёрнуты
  ленивой загрузкой, а нам она тут не нужна. }
uses
{$IFnDEF FPC}
  HTTPApp, BrkrConst, SHDocVw, ScktComp, TlHelp32, WebConst,
{$ELSE}
{$ENDIF}
  Masks;

type
  { Дальше идут внутренние структуры Windows -- в Windows.pas их нет, и
    описывать приходится руками. Смещения проставлены нарочно: на них и
    держится вся эта работа. }
  TNtUniStr = record                   { UNICODE_STRING, 8 байт }
    Len     : Word;
    MaxLen  : Word;
    Buffer  : PWideChar;
  end;

  TPebLdrData = record                 { читается ровно $24 байта }
    Size              : Cardinal;      { +$00 }
    Initialized       : Cardinal;      { +$04 }
    SsHandle          : Cardinal;      { +$08 }
    InLoadOrderFlink  : Cardinal;      { +$0C -- с него начинается обход }
    InLoadOrderBlink  : Cardinal;      { +$10 }
    InMemOrderFlink   : Cardinal;      { +$14 }
    InMemOrderBlink   : Cardinal;      { +$18 }
    InInitOrderFlink  : Cardinal;      { +$1C }
    InInitOrderBlink  : Cardinal;      { +$20 }
  end;

  TLdrModule = record                  { читается ровно $40 байт }
    InLoadOrderFlink  : Cardinal;      { +$00 }
    InLoadOrderBlink  : Cardinal;      { +$04 }
    InMemOrderFlink   : Cardinal;      { +$08 }
    InMemOrderBlink   : Cardinal;      { +$0C }
    InInitOrderFlink  : Cardinal;      { +$10 }
    InInitOrderBlink  : Cardinal;      { +$14 }
    BaseAddress       : Cardinal;      { +$18 }
    EntryPoint        : Cardinal;      { +$1C }
    SizeOfImage       : Cardinal;      { +$20 }
    FullDllName       : TNtUniStr;     { +$24 }
    BaseDllName       : TNtUniStr;     { +$2C }
    Flags             : Cardinal;      { +$34 }
    LoadCount         : Word;          { +$38 }
    TlsIndex          : Word;          { +$3A }
    HashNext          : Cardinal;      { +$3C }
  end;

  TProcessBasicInfo = record            { читается ровно $18 байт }
    ExitStatus     : Cardinal;         { +$00 }
    PebBaseAddress : Cardinal;         { +$04 }
    AffinityMask   : Cardinal;         { +$08 }
    BasePriority   : Integer;          { +$0C -- именно знаковый }
    UniqueProcessId: Cardinal;         { +$10 }
    ParentProcessId: Cardinal;         { +$14 }
  end;

  TPebRec = record                     { читается ровно $1D8 байт }
    Res00             : Byte;          { +$00 }
    Res01             : Byte;          { +$01 }
    BeingDebugged     : Byte;          { +$02 -- уходит в PROCESS_INFO+$30 }
    Res03             : Byte;          { +$03 }
    Mutant            : Cardinal;      { +$04 }
    ImageBase         : Cardinal;      { +$08 }
    Ldr               : Cardinal;      { +$0C }
    ProcessParams     : Cardinal;      { +$10 }
    Tail              : array[0..$1BF] of Byte;  { +$14 }
    SessionId         : Cardinal;      { +$1D4 -- последнее нужное поле,
                                         под него и подобран размер
                                         чтения }
  end;

  { Раскладка RTL_USER_PROCESS_PARAMETERS. Читается $48 байт, то есть ровно
    до конца CommandLine включительно -- дальше нам ничего не нужно. }
  TProcParamsRec = record              { читается ровно $48 байт }
    Head          : array[0..$0F] of Byte;  { +$00 }
    ConsoleHandle : Cardinal;          { +$10 }
    ConsoleFlags  : Cardinal;          { +$14 }
    StdInput      : Cardinal;          { +$18 }
    StdOutput     : Cardinal;          { +$1C }
    StdError      : Cardinal;          { +$20 }
    CurrentDir    : TNtUniStr;         { +$24 }
    CurDirHandle  : Cardinal;          { +$2C }
    DllPath       : TNtUniStr;         { +$30 }
    ImagePath     : TNtUniStr;         { +$38 }
    CommandLine   : TNtUniStr;         { +$40 }
  end;

  { --- 64-разрядные близнецы. Всё то же самое, только указатели по
    восемь байт, а UNICODE_STRING растянут до $10 из-за выравнивания. --- }
  TNtUniStr64 = record                 { $10 байт }
    Len     : Word;                    { +$00 }
    MaxLen  : Word;                    { +$02 }
    Res     : Cardinal;                { +$04 -- набивка }
    Buffer  : Int64;                   { +$08 }
  end;

  TPebLdrData64 = record               { читается ровно $40 байт }
    Size              : Cardinal;      { +$00 }
    Initialized       : Cardinal;      { +$04 }
    SsHandle          : Int64;         { +$08 }
    InLoadOrderFlink  : Int64;         { +$10 -- с него начинается обход }
    InLoadOrderBlink  : Int64;         { +$18 }
    InMemOrderFlink   : Int64;         { +$20 }
    InMemOrderBlink   : Int64;         { +$28 }
    InInitOrderFlink  : Int64;         { +$30 }
    InInitOrderBlink  : Int64;         { +$38 }
  end;

  TLdrModule64 = record                { читается ровно $78 байт }
    InLoadOrderFlink  : Int64;         { +$00 }
    InLoadOrderBlink  : Int64;         { +$08 }
    InMemOrderFlink   : Int64;         { +$10 }
    InMemOrderBlink   : Int64;         { +$18 }
    InInitOrderFlink  : Int64;         { +$20 }
    InInitOrderBlink  : Int64;         { +$28 }
    BaseAddress       : Int64;         { +$30 }
    EntryPoint        : Int64;         { +$38 }
    SizeOfImage       : Cardinal;      { +$40 }
    Res44             : Cardinal;      { +$44 }
    FullDllName       : TNtUniStr64;   { +$48 }
    BaseDllName       : TNtUniStr64;   { +$58 }
    Tail              : array[0..$0F] of Byte;   { +$68 }
  end;

  TProcessBasicInfo64 = record         { читается ровно $30 байт }
    ExitStatus     : Cardinal;         { +$00 }
    Res04          : Cardinal;         { +$04 }
    PebBaseAddress : Int64;            { +$08 }
    AffinityMask   : Int64;            { +$10 }
    BasePriority   : Cardinal;         { +$18 -- а здесь беззнаковый,
                                         в отличие от 32-разрядной
                                         записи }
    Res1C          : Cardinal;         { +$1C }
    UniqueProcessId: Int64;            { +$20 }
    ParentProcessId: Int64;            { +$28 }
  end;

  TPebRec64 = record                   { читается ровно $2C8 байт }
    Res00         : Byte;              { +$00 }
    Res01         : Byte;              { +$01 }
    BeingDebugged : Byte;              { +$02 }
    Res03         : Byte;              { +$03 }
    Res04         : Cardinal;          { +$04 }
    Mutant        : Int64;             { +$08 }
    ImageBase     : Int64;             { +$10 }
    Ldr           : Int64;             { +$18 }
    ProcessParams : Int64;             { +$20 }
    Tail          : array[0..$297] of Byte;   { +$28 }
    SessionId     : Cardinal;          { +$2C0 -- и опять последнее нужное
                                         поле задаёт размер чтения }
    Tail2         : array[0..3] of Byte;      { +$2C4 }
  end;

  TProcParams64 = record               { читается ровно $80 байт }
    Head          : array[0..$0F] of Byte;  { +$00 }
    ConsoleHandle : Int64;             { +$10 }
    ConsoleFlags  : Cardinal;          { +$18 }
    Res1C         : Cardinal;          { +$1C }
    StdInput      : Int64;             { +$20 }
    StdOutput     : Int64;             { +$28 }
    StdError      : Int64;             { +$30 }
    CurrentDir    : TNtUniStr64;       { +$38 }
    CurDirHandle  : Int64;             { +$48 }
    DllPath       : TNtUniStr64;       { +$50 }
    ImagePath     : TNtUniStr64;       { +$60 }
    CommandLine   : TNtUniStr64;       { +$70 }
  end;

  { Это PROCESS_MEMORY_COUNTERS_EX, а не обычная запись из PsAPI: нужен
    PrivateUsage, а он лежит в хвосте расширенной. }
  TProcMemCounters = record            { $2C байт }
    cb                         : Cardinal;   { +$00 }
    PageFaultCount             : Cardinal;   { +$04 }
    PeakWorkingSetSize         : Cardinal;   { +$08 }
    WorkingSetSize             : Cardinal;   { +$0C }
    QuotaPeakPagedPoolUsage    : Cardinal;   { +$10 }
    QuotaPagedPoolUsage        : Cardinal;   { +$14 }
    QuotaPeakNonPagedPoolUsage : Cardinal;   { +$18 }
    QuotaNonPagedPoolUsage     : Cardinal;   { +$1C }
    PagefileUsage              : Cardinal;   { +$20 }
    PeakPagefileUsage          : Cardinal;   { +$24 }
    PrivateUsage               : Cardinal;   { +$28 }
  end;

function NtQueryInformationProcess(ProcessHandle: THandle;
  InfoClass: Integer; Info: Pointer; InfoLen: Cardinal;
  RetLen: PCardinal): Integer; stdcall;
  external 'ntdll.dll' name 'NtQueryInformationProcess';

{ Объявляем сами: ntdll в Windows.pas нет вовсе. }
function NtReadVirtualMemory(ProcessHandle: THandle; BaseAddress: Pointer;
  Buffer: Pointer; NumberOfBytesToRead: Cardinal;
  NumberOfBytesRead: PCardinal): Integer; stdcall;
  external 'ntdll.dll' name 'NtReadVirtualMemory';

function GetProcessMemoryInfo(Process: THandle; ppsmemCounters: Pointer;
  cb: Cardinal): BOOL; stdcall;
  external 'psapi.dll' name 'GetProcessMemoryInfo';

function GetProcessHandleCount(hProcess: THandle;
  pdwHandleCount: PCardinal): BOOL; stdcall;
  external 'kernel32.dll' name 'GetProcessHandleCount';

{$IFDEF FPC}
type
  TProcessEntry32 = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;
    th32DefaultHeapID: DWORD;
    th32ModuleID: DWORD;
    cntThreads: DWORD;
    th32ParentProcessID: DWORD;
    pcPriClassBase: Longint;
    dwFlags: DWORD;
    szExeFile: array[0..MAX_PATH - 1] of Char;
  end;

const
  TH32CS_SNAPPROCESS = $00000002;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall;
  external 'kernel32.dll' name 'CreateToolhelp32Snapshot';
{$ENDIF}

function Process32First(hSnapshot: THandle;
  var lppe: TProcessEntry32): BOOL; stdcall;
  external 'kernel32.dll' name 'Process32First';

function Process32Next(hSnapshot: THandle;
  var lppe: TProcessEntry32): BOOL; stdcall;
  external 'kernel32.dll' name 'Process32Next';

procedure FindProcEntry(APid: Cardinal; var APe: TProcessEntry32); forward;

function OpenProcFull(APid: Cardinal): THandle;
begin
  Result := OpenProcess($1F0FFF, False, APid);
end;

{ WideString -> string с ЯВНОЙ кодовой страницей: обычное приведение
  берёт текущую системную, а нам иногда нужна другая. }
function WideToStr(const S: WideString; CP: Word): string;
var
  n: Integer;
begin
  if S = '' then
    Result := ''
  else
  begin
    n := WideCharToMultiByte(CP, WC_COMPOSITECHECK or WC_DISCARDNS or
      WC_SEPCHARS or WC_DEFAULTCHAR, PWideChar(S), -1, nil, 0, nil, nil);
    SetLength(Result, n - 1);
    if n > 1 then
      WideCharToMultiByte(CP, WC_COMPOSITECHECK or WC_DISCARDNS or
        WC_SEPCHARS or WC_DEFAULTCHAR, PWideChar(S), -1, @Result[1], n - 1,
        nil, nil);
  end;
end;

{ Включить привилегию по имени. Отсюда её просят обе ветви разбора --
  без SeDebugPrivilege чужой PEB не прочитать. }
function SetPrivilege(AName: string; AEnable: Boolean): Boolean;
var
  hTok: THandle;
  RetLen: DWORD;
  TP: TTokenPrivileges;
  TPPrev: TTokenPrivileges;
begin
  if OpenProcessToken(GetCurrentProcess,
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hTok) then
  begin
    if LookupPrivilegeValueA(nil, PChar(AName), TP.Privileges[0].Luid) then
    begin
      TP.PrivilegeCount := 1;
      case AEnable of
        True: TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
        False: TP.Privileges[0].Attributes := 0;
      end;
      RetLen := 0;
      TPPrev := TP;
      AdjustTokenPrivileges(hTok, False, TP, SizeOf(TP), TPPrev, RetLen);
    end;
    FileClose(hTok); { *Преобразовано из CloseHandle* }
  end;
  Result := GetLastError = ERROR_SUCCESS;
end;

{ «Система 64-разрядная?» Мы сами 32-разрядные, значит под 64-разрядной
  Windows идём через WOW64 -- и IsWow64Process на СВОЁМ процессе как раз
  и отвечает на этот вопрос. }
function IsOS64: BOOL;
begin
  pIsWow64Process := GetProcAddress(GetModuleHandle('kernel32.dll'),
    'IsWow64Process');
  Result := False;
  if Assigned(pIsWow64Process) then
    Result := pIsWow64Process(GetCurrentProcess, Result) and Result;
end;

{ Один раз при запуске: узнать разрядность системы и, если она
  64-разрядная, снять две функции WOW64 из ntdll. }
procedure InitProcApi;
var
  h: HMODULE;
begin
  gOS64 := Integer(IsOS64);
  if gOS64 <> 0 then
  begin
    h := GetModuleHandleA('ntdll.dll');
    pNtWow64Query := GetProcAddress(h, 'NtWow64QueryInformationProcess64');
    pNtWow64Read := GetProcAddress(h, 'NtWow64ReadVirtualMemory64');
  end
  else
    gOS64 := 0;
end;

{ Обход списка модулей 32-разрядного процесса: по PEB.Ldr идём цепочкой
  InLoadOrder и каждый узел читаем из чужой памяти целиком. Имена лежат
  там же, отдельными кусками, -- под каждое берём временный буфер. }
procedure ReadPebModules32(AProcess: THandle; ALdr: Cardinal;
  out AList: TModulesList);
var
  Ret: Cardinal;
  Ldr: TPebLdrData;
  M: TLdrModule;
  p: PWideChar;
  Buf: PWideChar;
  Len: Word;
begin
  NtReadVirtualMemory(AProcess, Pointer(ALdr), @Ldr, SizeOf(Ldr), @Ret);
  NtReadVirtualMemory(AProcess, Pointer(Ldr.InLoadOrderFlink), @M, SizeOf(M),
    @Ret);
  FillChar(AList, SizeOf(AList), 0);
  while (Ldr.InLoadOrderFlink <> 0) and (Ret <> 0) and (M.BaseAddress <> 0) do
  begin
    Inc(AList.Count);
    SetLength(AList.Items, AList.Count);
    AList.Items[AList.Count - 1].Base := M.BaseAddress;
    AList.Items[AList.Count - 1].Size := M.EntryPoint;
    AList.Items[AList.Count - 1].Res18 := M.SizeOfImage;
    Buf := M.FullDllName.Buffer;
    Len := M.FullDllName.Len;
    GetMem(p, Len + 2);
    FillChar(p^, Len + 2, 0);
    NtReadVirtualMemory(AProcess, Buf, p, Len, @Ret);
    AList.Items[AList.Count - 1].Path := WideToStr(p, 0);
    FreeMem(p);
    Buf := M.BaseDllName.Buffer;
    Len := M.BaseDllName.Len;
    GetMem(p, Len + 2);
    FillChar(p^, Len + 2, 0);
    NtReadVirtualMemory(AProcess, Buf, p, Len, @Ret);
    AList.Items[AList.Count - 1].Name := WideToStr(p, 0);
    FreeMem(p);
    NtReadVirtualMemory(AProcess, Pointer(M.InLoadOrderFlink), @M, SizeOf(M),
      @Ret);
  end;
end;

{ Обе ветви разбора устроены одинаково: чистим буферы, берём привилегию
  отладки, открываем процесс, читаем PBI -> PEB -> параметры процесса,
  обходим список модулей, вытаскиваем три строки из чужой памяти,
  добираем счётчики и раскладываем всё по полям.

  Размеры чтений PEB и параметров подобраны ПОД ПОСЛЕДНЕЕ НУЖНОЕ ПОЛЕ --
  SessionId и CommandLine: читать структуру целиком незачем, да и хвост
  её от версии к версии разный. }
procedure ReadModules32(APid: Cardinal; out AList: PROCESS_INFO);
var
  Ret: Cardinal;
  RetLen: Cardinal;
  W: BOOL;
  S3, S2, S1: string;
  StrAddr: Cardinal;
  HandleCount: Cardinal;
  PBI: TProcessBasicInfo;
  Peb: TPebRec;
  Params: TProcParamsRec;
  PE: TProcessEntry32;
  PMC: TProcMemCounters;
  h: THandle;
  p: PWideChar;
  Len: Word;
begin
  FillChar(PBI, SizeOf(PBI), 0);
  FillChar(Peb, SizeOf(Peb), 0);
  FillChar(Params, SizeOf(Params), 0);
  FillChar(AList, SizeOf(AList), 0);
  SetPrivilege('SeDebugPrivilege', True);
  h := OpenProcess($410, False, APid);
  W := False;
  NtQueryInformationProcess(h, 0, @PBI, SizeOf(PBI), @RetLen);
  NtReadVirtualMemory(h, Pointer(PBI.PebBaseAddress), @Peb, SizeOf(Peb), @Ret);
  NtReadVirtualMemory(h, Pointer(Peb.ProcessParams), @Params, SizeOf(Params),
    @Ret);
  ReadPebModules32(h, Peb.Ldr, AList.Modules);
  StrAddr := Cardinal(Params.CommandLine.Buffer);
  Len := Params.CommandLine.Len;
  GetMem(p, Len + 2);
  FillChar(p^, Len + 2, 0);
  NtReadVirtualMemory(h, Pointer(StrAddr), p, Len, @Ret);
  S1 := WideToStr(p, 0);
  FreeMem(p);
  StrAddr := Cardinal(Params.ImagePath.Buffer);
  Len := Params.ImagePath.Len;
  GetMem(p, Len + 2);
  FillChar(p^, Len + 2, 0);
  NtReadVirtualMemory(h, Pointer(StrAddr), p, Len, @Ret);
  S2 := WideToStr(p, 0);
  FreeMem(p);
  StrAddr := Cardinal(Params.CurrentDir.Buffer);
  Len := Params.CurrentDir.Len;
  GetMem(p, Len + 2);
  FillChar(p^, Len + 2, 0);
  NtReadVirtualMemory(h, Pointer(StrAddr), p, Len, @Ret);
  S3 := WideToStr(p, 0);
  FreeMem(p);
  FillChar(PMC, SizeOf(PMC), 0);
  GetProcessMemoryInfo(h, @PMC, SizeOf(PMC));
  FillChar(PE, SizeOf(PE), 0);
  FindProcEntry(APid, PE);
  GetProcessHandleCount(h, @HandleCount);
  AList.hProc := h;
  AList.Pid := PBI.UniqueProcessId;
  AList.ParentPid := PBI.ParentProcessId;
  AList.SessionId := Peb.SessionId;
  AList.Priority := PBI.BasePriority;
  AList.Affinity := PBI.AffinityMask;
  AList.Debugged := Peb.BeingDebugged;
  AList.ExitCode := PBI.ExitStatus;
  AList.Threads := PE.cntThreads;
  AList.Handles := HandleCount;
  AList.PrivMem := PMC.PrivateUsage;
  AList.ImageBase := Peb.ImageBase;
  AList.LdrAddr := Peb.Ldr;
  AList.PebAddr := PBI.PebBaseAddress;
  AList.ConHandle := Params.ConsoleHandle;
  AList.StdIn := Params.StdInput;
  AList.StdOut := Params.StdOutput;
  AList.StdErr := Params.StdError;
  AList.ExeFile := PE.szExeFile;
  AList.CurDir := S3;
  AList.ImagePath := S2;
  AList.CmdLine := S1;
  AList.IsWow := Integer(W);
  FileClose(h); { *Преобразовано из CloseHandle* }
end;

{ Тот же обход списка модулей, только у 64-разрядного процесса и через
  NtWow64ReadVirtualMemory64. }
procedure ReadPebModules64(AProcess: THandle; ALdr: Int64;
  out AList: TModulesList);
var
  p: PWideChar;
  Buf: Int64;
  Len: Word;
  Ret: Int64;
  Ldr: TPebLdrData64;
  M: TLdrModule64;
begin
  pNtWow64Read(AProcess, ALdr, @Ldr, SizeOf(Ldr), @Ret);
  pNtWow64Read(AProcess, Ldr.InLoadOrderFlink, @M, SizeOf(M), @Ret);
  FillChar(AList, SizeOf(AList), 0);
  while (Ldr.InLoadOrderFlink <> 0) and (Ret <> 0) and (M.BaseAddress <> 0) do
  begin
    Inc(AList.Count);
    SetLength(AList.Items, AList.Count);
    AList.Items[AList.Count - 1].Base := M.BaseAddress;
    AList.Items[AList.Count - 1].Size := M.EntryPoint;
    AList.Items[AList.Count - 1].Res18 := M.SizeOfImage;
    Buf := M.FullDllName.Buffer;
    Len := M.FullDllName.Len;
    GetMem(p, Len + 2);
    FillChar(p^, Len + 2, 0);
    pNtWow64Read(AProcess, Buf, p, Len, @Ret);
    AList.Items[AList.Count - 1].Path := WideToStr(p, 0);
    FreeMem(p);
    Buf := M.BaseDllName.Buffer;
    Len := M.BaseDllName.Len;
    GetMem(p, Len + 2);
    FillChar(p^, Len + 2, 0);
    pNtWow64Read(AProcess, Buf, p, Len, @Ret);
    AList.Items[AList.Count - 1].Name := WideToStr(p, 0);
    FreeMem(p);
    pNtWow64Read(AProcess, M.InLoadOrderFlink, @M, SizeOf(M), @Ret);
  end;
end;

{ 64-разрядная ветвь. Отличий от 32-разрядной два: разрядность процесса
  тут выясняется, а не берётся нулём, и BasePriority в 64-разрядной
  PROCESS_BASIC_INFORMATION беззнаковый. }
procedure ReadModules64(APid: Cardinal; out AList: PROCESS_INFO);
var
  Ret: Int64;
  RetLen: Int64;
  W: BOOL;
  S3, S2, S1: string;
  StrAddr: Int64;
  HandleCount: Cardinal;
  PBI: TProcessBasicInfo64;
  Peb: TPebRec64;
  Params: TProcParams64;
  PE: TProcessEntry32;
  PMC: TProcMemCounters;
  h: THandle;
  p: PWideChar;
  Len: Word;
begin
  Assert(W);
  FillChar(PBI, SizeOf(PBI), 0);
  FillChar(Peb, SizeOf(Peb), 0);
  FillChar(Params, SizeOf(Params), 0);
  FillChar(AList, SizeOf(AList), 0);
  SetPrivilege('SeDebugPrivilege', True);
  h := OpenProcess($410, False, APid);
  pIsWow64Process(h, W);
  W := not W;
  pNtWow64Query(h, 0, @PBI, SizeOf(PBI), @RetLen);
  pNtWow64Read(h, PBI.PebBaseAddress, @Peb, SizeOf(Peb), @Ret);
  pNtWow64Read(h, Peb.ProcessParams, @Params, SizeOf(Params), @Ret);
  ReadPebModules64(h, Peb.Ldr, AList.Modules);
  StrAddr := Params.CommandLine.Buffer;
  Len := Params.CommandLine.Len;
  GetMem(p, Len + 2);
  FillChar(p^, Len + 2, 0);
  pNtWow64Read(h, StrAddr, p, Len, @Ret);
  S1 := WideToStr(p, 0);
  FreeMem(p);
  StrAddr := Params.ImagePath.Buffer;
  Len := Params.ImagePath.Len;
  GetMem(p, Len + 2);
  FillChar(p^, Len + 2, 0);
  pNtWow64Read(h, StrAddr, p, Len, @Ret);
  S2 := WideToStr(p, 0);
  FreeMem(p);
  StrAddr := Params.CurrentDir.Buffer;
  Len := Params.CurrentDir.Len;
  GetMem(p, Len + 2);
  FillChar(p^, Len + 2, 0);
  pNtWow64Read(h, StrAddr, p, Len, @Ret);
  S3 := WideToStr(p, 0);
  FreeMem(p);
  FillChar(PMC, SizeOf(PMC), 0);
  GetProcessMemoryInfo(h, @PMC, SizeOf(PMC));
  FillChar(PE, SizeOf(PE), 0);
  FindProcEntry(APid, PE);
  GetProcessHandleCount(h, @HandleCount);
  AList.hProc := h;
  AList.Pid := PBI.UniqueProcessId;
  AList.ParentPid := PBI.ParentProcessId;
  AList.SessionId := Peb.SessionId;
  AList.Priority := PBI.BasePriority;
  AList.Affinity := PBI.AffinityMask;
  AList.Debugged := Peb.BeingDebugged;
  AList.ExitCode := PBI.ExitStatus;
  AList.Threads := PE.cntThreads;
  AList.Handles := HandleCount;
  AList.PrivMem := PMC.PrivateUsage;
  AList.ImageBase := Peb.ImageBase;
  AList.LdrAddr := Peb.Ldr;
  AList.PebAddr := PBI.PebBaseAddress;
  AList.ConHandle := Params.ConsoleHandle;
  AList.StdIn := Params.StdInput;
  AList.StdOut := Params.StdOutput;
  AList.StdErr := Params.StdError;
  AList.ExeFile := PE.szExeFile;
  AList.CurDir := S3;
  AList.ImagePath := S2;
  AList.CmdLine := S1;
  AList.IsWow := Integer(W);
  FileClose(h); { *Преобразовано из CloseHandle* }
end;

{ Выбор ветви. IsWow64Process отвечает «процесс под WOW64», то есть
  32-разрядный, а нам удобнее обратное -- отсюда `not`. AFlag заставляет
  читать 64-разрядный список даже у процесса под WOW64: иногда нужны
  именно настоящие адреса. }
procedure GetProcModules(APid: Cardinal; out AList: PROCESS_INFO;
  AFlag: Boolean);
var
  W: BOOL;
  h: THandle;
begin
  FillChar(AList, SizeOf(AList), 0);
  h := OpenProcFull(APid);
  if h <> 0 then
  begin
    pIsWow64Process(h, W);
    W := not W;
    FileClose(h); { *Преобразовано из CloseHandle* }
    if gOS64 <> 0 then
    begin
      if W then
        ReadModules64(APid, AList)
      else if AFlag then
        ReadModules64(APid, AList)
      else
        ReadModules32(APid, AList);
    end
    else
      ReadModules32(APid, AList);
  end;
end;

{ Поиск записи процесса по идентификатору через снимок TlHelp32. }
procedure FindProcEntry(APid: Cardinal; var APe: TProcessEntry32);
var
  h: THandle;
  E: TProcessEntry32;
begin
  FillChar(APe, SizeOf(APe), 0);
  E.dwSize := SizeOf(E);
  h := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(h, E) then
  begin
    if APid = E.th32ProcessID then
      APe := E
    else
      while Process32Next(h, E) do
        if APid = E.th32ProcessID then
        begin
          APe := E;
          Break;
        end;
  end;
  FileClose(h); { *Преобразовано из CloseHandle* }
end;

function SetDebugPrivilege(Enable: Boolean): Boolean;
var
  hTok: THandle;
  Ret: DWORD;
  TP: TTokenPrivileges;
begin
  Result := False;
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES, hTok) then
  begin
    TP.PrivilegeCount := 1;
    LookupPrivilegeValue(nil, 'SeDebugPrivilege', TP.Privileges[0].Luid);
    if Enable then
      TP.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
    else
      TP.Privileges[0].Attributes := $80000000;
    { Прежнее состояние не спрашиваем -- возвращать привилегию назад
      всё равно не собираемся. }
    AdjustTokenPrivileges(hTok, False, TP, SizeOf(TP), nil, Ret);
    if GetLastError = ERROR_SUCCESS then
      Result := True;
    FileClose(hTok); { *Преобразовано из CloseHandle* }
  end;
end;

initialization
  InitProcApi;

end.
