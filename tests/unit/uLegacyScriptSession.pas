unit uLegacyScriptSession;
{$mode objfpc}{$H+}

interface

uses
  uScanThread, uScriptTestSession, uScriptDriver;

type
  TLegacyScriptSession = class(TInterfacedObject, IScriptSession)
  private
    FT: TScanThread;
    FDriver: TScriptDriver;
    FMaxSteps: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    function Eval(const Expr: string): string;
    procedure RunScript(const Script: string);
    function NumVar(const Name: string): Int64;
    function StrVar(const Name: string): string;
    function ArrCell(const Name: string; Row, Col: Integer): string;
    function LastError: string;
    property MaxSteps: Integer read FMaxSteps write FMaxSteps;
  end;

implementation

uses
  Classes, SysUtils, Unit1;

{ Команды, которые тестовый драйвер исполняет. Внешние команды (send, mouse,
  clipboard, window, memory, file, plugin, macro), `log`, `wait`, `msg`,
  `hint`, `exit`, `proc`/`call`, `exec`, `load_script`, `restart_script` сюда
  не входят: им нужен host/UI, которого в unit-тестах нет. }
function IsAllowedCommand(Cmd: Integer): Boolean;
begin
  case Cmd of
    0, 1, 2, 3, 4, 5, 6, 7, 10, 11,
    32, 40, 41, 42, 43, 44, 45, 46, 47,
    49, 110, 112, 114, 115, 116, 126, 127:
      Result := True;
  else
    Result := False;
  end;
end;

{ ShowScriptMsg в тестовом режиме не дописывает завершающий #0, но многие
  ветки ошибок ставят его сами -- снимаем ровно один. }
function StripMsgNul(const S: string): string;
begin
  Result := S;
  if (Length(Result) > 0) and (Result[Length(Result)] = #0) then
    Delete(Result, Length(Result), 1);
end;

type
  { Адаптеры тестового драйвера: те же поля TScanThread, что и у production. }
  TLegacyDriverState = class(TInterfacedObject, IScriptDriverState)
  private
    FT: TScanThread;
  public
    constructor Create(AT: TScanThread);
    function GetLinesCount: Integer;
    function GetLine(Index: Integer): string;
    function GetCurLine: Integer;
    procedure SetCurLine(Value: Integer);
    function GetLineText: string;
    procedure SetLineText(const Value: string);
    function GetLogPrefix: string;
    procedure SetLogPrefix(const Value: string);
    function GetRestartFlag: Boolean;
    procedure SetRestartFlag(Value: Boolean);
    function GetRepeatLine: Boolean;
    procedure SetRepeatLine(Value: Boolean);
    function GetRepeatCmd: Boolean;
    procedure SetRepeatCmd(Value: Boolean);
  end;

  TLegacyDriverHost = class(TInterfacedObject, IScriptDriverHost)
  private
    FT: TScanThread;
  public
    constructor Create(AT: TScanThread);
    function BeforeLine: TScriptStepResult;
    function EvalLine(const S: string): string;
    function ResolveCommand(const AName: string): Integer;
    procedure ExecuteCommand(var ACmd: Integer);
    function HandleLuaBlock(out AConsumed: Boolean): TScriptStepResult;
    function HandleBlockComment(out AConsumed: Boolean): TScriptStepResult;
    function WaitEmptyLine: TScriptStepResult;
    function WaitEmptyPrefix: TScriptStepResult;
    function WaitBeforeCommand: TScriptStepResult;
  end;

constructor TLegacyDriverState.Create(AT: TScanThread);
begin
  inherited Create;
  FT := AT;
end;

function TLegacyDriverState.GetLinesCount: Integer;
begin
  Result := Length(FT.Lines);
end;

function TLegacyDriverState.GetLine(Index: Integer): string;
begin
  Result := FT.Lines[Index];
end;

function TLegacyDriverState.GetCurLine: Integer;
begin
  Result := FT.CurLine;
end;

procedure TLegacyDriverState.SetCurLine(Value: Integer);
begin
  FT.CurLine := Value;
end;

function TLegacyDriverState.GetLineText: string;
begin
  Result := FT.Line;
end;

procedure TLegacyDriverState.SetLineText(const Value: string);
begin
  FT.Line := Value;
end;

function TLegacyDriverState.GetLogPrefix: string;
begin
  Result := FT.LogPrefix;
end;

procedure TLegacyDriverState.SetLogPrefix(const Value: string);
begin
  FT.LogPrefix := Value;
end;

function TLegacyDriverState.GetRestartFlag: Boolean;
begin
  Result := FT.RestartFlag;
end;

procedure TLegacyDriverState.SetRestartFlag(Value: Boolean);
begin
  FT.RestartFlag := Value;
end;

function TLegacyDriverState.GetRepeatLine: Boolean;
begin
  Result := FT.RepeatLine;
end;

procedure TLegacyDriverState.SetRepeatLine(Value: Boolean);
begin
  FT.RepeatLine := Value;
end;

function TLegacyDriverState.GetRepeatCmd: Boolean;
begin
  Result := FT.RepeatCmd;
end;

procedure TLegacyDriverState.SetRepeatCmd(Value: Boolean);
begin
  FT.RepeatCmd := Value;
end;

constructor TLegacyDriverHost.Create(AT: TScanThread);
begin
  inherited Create;
  FT := AT;
end;

function TLegacyDriverHost.BeforeLine: TScriptStepResult;
begin
  if FT.StopRequested then
    Result := srStop
  else
    Result := srNext;
end;

function TLegacyDriverHost.EvalLine(const S: string): string;
begin
  Result := EvalScriptExpr(FT, S, 0);
end;

function TLegacyDriverHost.ResolveCommand(const AName: string): Integer;
begin
  Result := gCmdList2jj.IndexOf(AName);
end;

procedure TLegacyDriverHost.ExecuteCommand(var ACmd: Integer);
var
  CmdName: string;
  SubCmd: string;
begin
  { Метка `:name`: в Execute её молча пропускает else-ветка
    ExecScriptCommand (LogPrefix начинается с ':'). }
  if ACmd < 0 then
  begin
    if Copy(FT.LogPrefix, 1, 1) = ':' then
      Exit;
    raise EScriptDriverError.CreateFmt(
      'unknown command "%s" (line %d)', [FT.LogPrefix, FT.CurLine]);
  end;

  if not IsAllowedCommand(ACmd) then
  begin
    if (ACmd >= 0) and (ACmd < gCmdList2jj.Count) then
      CmdName := gCmdList2jj[ACmd]
    else
      CmdName := FT.LogPrefix;
    raise EScriptDriverError.CreateFmt(
      'command "%s" is not supported (line %d)',
      [CmdName, FT.CurLine]);
  end;

  { `set logging` меняет глобальное состояние и в test-режиме пишет
    служебный текст в Msg, который драйвер считает ошибкой. }
  if ACmd = 40 then
  begin
    SubCmd := AnsiLowerCase(EvalScriptPoint(FT, FT.Line, 1));
    if (Length(SubCmd) >= 2) and (SubCmd[1] = '"') and
       (SubCmd[Length(SubCmd)] = '"') then
      SubCmd := Copy(SubCmd, 2, Length(SubCmd) - 2);
    if SubCmd = 'logging' then
      raise EScriptDriverError.CreateFmt(
        'set logging is not supported (line %d)', [FT.CurLine]);
  end;

  FT.Msg := '';
  ExecScriptCommand(FT, ACmd, FT.Line);
  if FT.Msg <> '' then
    raise EScriptDriverError.Create('script error: ' + StripMsgNul(FT.Msg));
end;

function TLegacyDriverHost.HandleLuaBlock(out AConsumed: Boolean): TScriptStepResult;
var
  S: string;
begin
  AConsumed := False;
  S := AnsiLowerCase(FT.Line);
  if (S = '--lua') or (S = '-- lua') then
    raise EScriptDriverError.CreateFmt(
      'lua blocks are not supported (line %d)', [FT.CurLine]);
  Result := srNext;
end;

function TLegacyDriverHost.HandleBlockComment(out AConsumed: Boolean): TScriptStepResult;
begin
  AConsumed := False;
  if Pos('(*', FT.Line) > 0 then
    raise EScriptDriverError.CreateFmt(
      'block comments are not supported (line %d)', [FT.CurLine]);
  Result := srNext;
end;

function TLegacyDriverHost.WaitEmptyLine: TScriptStepResult;
begin
  Result := srNext;
end;

function TLegacyDriverHost.WaitEmptyPrefix: TScriptStepResult;
begin
  Result := srNext;
end;

function TLegacyDriverHost.WaitBeforeCommand: TScriptStepResult;
begin
  Result := srNext;
end;

constructor TLegacyScriptSession.Create;
begin
  inherited Create;
  FMaxSteps := 100000;
  Reset;
end;

destructor TLegacyScriptSession.Destroy;
begin
  FreeAndNil(FDriver);
  FreeAndNil(FT);
  inherited Destroy;
end;

{ Таблицы команд -- глобальное состояние Unit1, поэтому их поднимают при
  каждом создании сессии. }
procedure TLegacyScriptSession.Reset;
begin
  FreeAndNil(FDriver);
  FreeAndNil(FT);
  InitScriptCommandTables;
  FT := TScanThread.CreateForTest;
  FDriver := TScriptDriver.Create(
    TLegacyDriverState.Create(FT), TLegacyDriverHost.Create(FT));
end;

{ Внутренний вычислитель ожидает 'calc ' перед выражением и nv = -1:
  тогда он берёт всё после первого слова. }
function TLegacyScriptSession.Eval(const Expr: string): string;
begin
  if FT = nil then
    Reset;
  Result := EvalScriptExpr(FT, 'calc ' + Expr, -1);
end;

{ Загрузка сценария и сброс состояния; сам line-loop -- в uScriptDriver. }
procedure TLegacyScriptSession.RunScript(const Script: string);
var
  I: Integer;
  LinesList: TStringList;
begin
  if FT = nil then
    Reset;

  LinesList := TStringList.Create;
  try
    LinesList.Text := Script;
    SetLength(FT.Lines, LinesList.Count);
    for I := 0 to LinesList.Count - 1 do
      FT.Lines[I] := LinesList[I];
  finally
    LinesList.Free;
  end;

  FT.CurLine := 0;
  FT.StopRequested := False;
  FT.Paused := False;
  FT.RestartFlag := False;
  FT.RepeatLine := False;
  FT.RepeatCmd := False;
  FT.LogPrefix := '';
  FT.Msg := '';
  FT.CmdLine := 0;
  FT.ParenPos := 0;
  FT.Line := '';
  FT.LineCount := 0;
  SetLength(FT.Arr50, 0);
  SetLength(FT.Arr54, 0);
  SetLength(FT.Arr58, 0);
  FT.VarNames.Clear;
  FT.VarNames.Add('timer');
  FT.LogLevel := 0;
  FT.LoggingCommands := False;
  FT.AutoStart := False;
  FT.ShowRun := False;

  FDriver.MaxSteps := FMaxSteps;
  FDriver.Run;
end;

function TLegacyScriptSession.NumVar(const Name: string): Int64;
var
  Idx: Integer;
begin
  if FT = nil then
    Reset;
  Idx := FindScriptVar(FT, '#', AnsiLowerCase(Name), 0, 0);
  Result := FT.Vars[Idx].Value;
end;

function TLegacyScriptSession.StrVar(const Name: string): string;
var
  Idx: Integer;
begin
  if FT = nil then
    Reset;
  Idx := FindScriptVar(FT, '$', AnsiLowerCase(Name), 0, 0);
  Result := FT.Timers[Idx].Value;
end;

function TLegacyScriptSession.ArrCell(const Name: string; Row, Col: Integer): string;
var
  Idx: Integer;
begin
  Result := '';
  if (Row < 1) or (Col < 1) then
    Exit;
  if FT = nil then
    Reset;
  Idx := FindScriptVar(FT, '%', AnsiLowerCase(Name), Row, Col);
  if (Length(FT.Arr48[Idx].Data) < Row) or
     (Length(FT.Arr48[Idx].Data[Row - 1]) < Col) then
    Exit;
  Result := FT.Arr48[Idx].Data[Row - 1][Col - 1];
end;

function TLegacyScriptSession.LastError: string;
begin
  if FT = nil then
    Exit('');
  Result := StripMsgNul(FT.Msg);
end;

end.
