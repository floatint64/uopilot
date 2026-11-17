unit uScriptTestSession;
{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TScriptBackend = (sbLegacy, sbRuntime);

  IScriptSession = interface
    ['{6F1C7D2A-6C2B-4A4E-9A7F-2C5E1B8D3A41}']
    procedure Reset;
    function  Eval(const Expr: string): string;
    procedure RunScript(const Script: string);
    function  NumVar(const Name: string): Int64;
    function  StrVar(const Name: string): string;
    function  ArrCell(const Name: string; Row, Col: Integer): string;
    function  LastError: string;
  end;

function CreateSession(ABackend: TScriptBackend): IScriptSession;
function ToScript(const Utf8: string): string;

implementation

uses
  Windows, uLegacyScriptSession;

function CreateSession(ABackend: TScriptBackend): IScriptSession;
begin
  case ABackend of
    sbLegacy: Result := TLegacyScriptSession.Create;
    sbRuntime: raise ENotImplemented.Create('runtime backend is not implemented yet');
  end;
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
