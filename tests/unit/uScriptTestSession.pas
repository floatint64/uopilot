unit uScriptTestSession;
{$mode objfpc}{$H+}

interface

uses
  SysUtils, uScriptSettings;

type
  TScriptBackend = (sbLegacy, sbRuntime);

  TScriptErrorKind = (
    sekNone,
    sekUnknownCommand,
    sekUnsupportedCommand,
    sekScriptError,
    sekStepLimit,
    sekRestart,
    sekSuspended,
    sekOther
  );

  TScriptError = record
    Kind: TScriptErrorKind;
    Line: Integer;
    Message: string;
  end;

  { Runtime-бэкенд ещё не перенесён; заглушка нужна, чтобы dual-run набор
    регистрировался и падал/игнорировался явно, а не молча. }
  EScriptRuntimeNotImplemented = class(Exception);

  IScriptSession = interface
    ['{6F1C7D2A-6C2B-4A4E-9A7F-2C5E1B8D3A41}']
    procedure Reset;
    function  Eval(const Expr: string): string;
    procedure RunScript(const Script: string);
    function  NumVar(const Name: string): Int64;
    function  StrVar(const Name: string): string;
    function  ArrCell(const Name: string; Row, Col: Integer): string;
    { Try-варианты не создают переменную: False означает, что её нет. }
    function  TryNumVar(const Name: string; out Value: Int64): Boolean;
    function  TryStrVar(const Name: string; out Value: string): Boolean;
    function  TryArrCell(const Name: string; Row, Col: Integer;
      out Value: string): Boolean;
    function  LogText: string;
    function  HostCallText: string;
    function  MessageText: string;
    function  HintText: string;
    function  ExitRequested: Boolean;
    function  LastError: string;
    function  LastErrorInfo: TScriptError;
  end;

function CreateSession(ABackend: TScriptBackend;
  const ASettings: IScriptSettings = nil): IScriptSession;
{ Возможности core-бэкенда по имени кейса. Пока ни один кейс не перенесён. }
function CoreSupports(const CaseName: string): Boolean;
function ToScript(const Utf8: string): string;

implementation

uses
  Windows, uLegacyScriptSession;

type
  { Заглушка runtime-бэкенда: каждый метод сообщает, что перенос не сделан. }
  TRuntimeScriptSession = class(TInterfacedObject, IScriptSession)
  public
    procedure Reset;
    function  Eval(const Expr: string): string;
    procedure RunScript(const Script: string);
    function  NumVar(const Name: string): Int64;
    function  StrVar(const Name: string): string;
    function  ArrCell(const Name: string; Row, Col: Integer): string;
    function  TryNumVar(const Name: string; out Value: Int64): Boolean;
    function  TryStrVar(const Name: string; out Value: string): Boolean;
    function  TryArrCell(const Name: string; Row, Col: Integer;
      out Value: string): Boolean;
    function  LogText: string;
    function  HostCallText: string;
    function  MessageText: string;
    function  HintText: string;
    function  ExitRequested: Boolean;
    function  LastError: string;
    function  LastErrorInfo: TScriptError;
  end;

function CreateSession(ABackend: TScriptBackend;
  const ASettings: IScriptSettings): IScriptSession;
begin
  case ABackend of
    sbLegacy: Result := TLegacyScriptSession.Create(ASettings);
    sbRuntime: Result := TRuntimeScriptSession.Create;
  end;
end;

function CoreSupports(const CaseName: string): Boolean;
begin
  Result := False;
end;

procedure TRuntimeScriptSession.Reset;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.Eval(const Expr: string): string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

procedure TRuntimeScriptSession.RunScript(const Script: string);
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.NumVar(const Name: string): Int64;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.StrVar(const Name: string): string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.ArrCell(const Name: string;
  Row, Col: Integer): string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.TryNumVar(const Name: string;
  out Value: Int64): Boolean;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.TryStrVar(const Name: string;
  out Value: string): Boolean;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.TryArrCell(const Name: string;
  Row, Col: Integer; out Value: string): Boolean;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.LogText: string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.HostCallText: string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.MessageText: string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.HintText: string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.ExitRequested: Boolean;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.LastError: string;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

function TRuntimeScriptSession.LastErrorInfo: TScriptError;
begin
  raise EScriptRuntimeNotImplemented.Create(
    'runtime backend is not implemented yet');
end;

{ UTF-8 -> cp1251 через WinAPI: движок скриптов работает с байтами cp1251,
  а исходники тестов сохраняются в UTF-8. }
function ToScript(const Utf8: string): string;
var
  WS: WideString;
  N: Integer;
begin
  Result := '';
  if Utf8 = '' then
    Exit;
  N := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(Utf8), Length(Utf8), nil, 0);
  SetLength(WS, N);
  if N > 0 then
    MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(Utf8), Length(Utf8), PWideChar(WS), N);
  N := WideCharToMultiByte(1251, 0, PWideChar(WS), Length(WS), nil, 0, nil, nil);
  SetLength(Result, N);
  if N > 0 then
    WideCharToMultiByte(1251, 0, PWideChar(WS), Length(WS), PAnsiChar(Result), N, nil, nil);
end;

end.
