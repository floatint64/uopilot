unit uLegacyScriptSession;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, uScanThread, uScriptTestSession, uScriptDriver,
  uScriptSettings;

type
  TAllowedCommandIds = array of Integer;

  TLegacyScriptSession = class(TInterfacedObject, IScriptSession)
  private
    FT: TScanThread;
    FDriver: TScriptDriver;
    FMaxSteps: Integer;
    FSettings: IScriptSettings;
    FHostCalls: TStringList;
    FLastError: TScriptError;
    procedure SetError(AKind: TScriptErrorKind; ALine: Integer;
      const AMessage: string);
    procedure SetErrorFromException(E: Exception);
  public
    constructor Create(const ASettings: IScriptSettings = nil);
    destructor Destroy; override;
    procedure Reset;
    procedure SetNow(const AValue: TDateTime);
    function Eval(const Expr: string): string;
    procedure RunScript(const Script: string);
    function NumVar(const Name: string): Int64;
    function StrVar(const Name: string): string;
    function ArrCell(const Name: string; Row, Col: Integer): string;
    function TryNumVar(const Name: string; out Value: Int64): Boolean;
    function TryStrVar(const Name: string; out Value: string): Boolean;
    function TryArrCell(const Name: string; Row, Col: Integer;
      out Value: string): Boolean;
    function LogText: string;
    function HostCallText: string;
    function MessageText: string;
    function HintText: string;
    function ExitRequested: Boolean;
    function LastError: string;
    function LastErrorInfo: TScriptError;
    property MaxSteps: Integer read FMaxSteps write FMaxSteps;
  end;

{ Команды, которые тестовый драйвер исполняет. Внешние команды (send, mouse,
  clipboard, window, memory, file, plugin, macro), `proc`/`call`, `exec`,
  `load_script`, `restart_script` сюда не входят: им нужен host/UI, которого
  в unit-тестах нет. `log <text>` -- исключение: он пишет в наблюдаемый
  TestLog без UI. }
function TestAllowedCommands: TAllowedCommandIds;
function IsTestCommandAllowed(Cmd: Integer): Boolean;

implementation

uses
  Unit1, mySys;

const
  { Индексы в gCmdList2jj. Порядок -- как в движке, чтобы TestAllowedCommands
    был стабильным. }
  TestAllowedCommandIds: array[0..31] of Integer = (
    0, 1, 2, 3, 4, 5, 6, 7, 10, 11,
    15, 16, 32, 40, 41, 42, 43, 44, 45, 46, 47,
    49, 98, 110, 111, 112, 114, 115, 116, 119, 126, 127);

function TestAllowedCommands: TAllowedCommandIds;
var
  I: Integer;
begin
  SetLength(Result, Length(TestAllowedCommandIds));
  for I := 0 to High(TestAllowedCommandIds) do
    Result[I] := TestAllowedCommandIds[I];
end;

function IsTestCommandAllowed(Cmd: Integer): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(TestAllowedCommandIds) do
    if TestAllowedCommandIds[I] = Cmd then
      Exit(True);
  Result := False;
end;

{ ShowScriptMsg в тестовом режиме не дописывает завершающий #0, но многие
  ветки ошибок ставят его сами -- снимаем ровно один. }
function StripMsgNul(const S: string): string;
begin
  Result := S;
  if (Length(Result) > 0) and (Result[Length(Result)] = #0) then
    Delete(Result, Length(Result), 1);
end;

{ Фиксированные часы по умолчанию: clock-кейсы не должны зависеть от
  реального времени машины. }
function DefaultTestNow: TDateTime;
begin
  Result := EncodeDate(2024, 1, 2) + EncodeTime(3, 4, 5, 0);
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
    FCalls: TStrings;
    procedure RecordCall(const AName: string);
  public
    constructor Create(AT: TScanThread; ACalls: TStrings);
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

constructor TLegacyDriverHost.Create(AT: TScanThread; ACalls: TStrings);
begin
  inherited Create;
  FT := AT;
  FCalls := ACalls;
end;

procedure TLegacyDriverHost.RecordCall(const AName: string);
begin
  if FCalls <> nil then
    FCalls.Add(IntToStr(FT.CurLine) + ': ' + AName);
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
  if ACmd < 0 then
  begin
    RecordCall(FT.LogPrefix);
    { Метка `:name`: в Execute её молча пропускает else-ветка
      ExecScriptCommand (LogPrefix начинается с ':'). }
    if Copy(FT.LogPrefix, 1, 1) = ':' then
      Exit;
    raise EScriptDriverError.CreateFmt(
      'unknown command "%s" (line %d)', [FT.LogPrefix, FT.CurLine]);
  end;

  if (ACmd >= 0) and (ACmd < gCmdList2jj.Count) then
    CmdName := gCmdList2jj[ACmd]
  else
    CmdName := FT.LogPrefix;
  RecordCall(CmdName);

  if not IsTestCommandAllowed(ACmd) then
    raise EScriptDriverError.CreateFmt(
      'command "%s" is not supported (line %d)',
      [CmdName, FT.CurLine]);

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

  { `log <text>` в тестовом драйвере пишет в наблюдаемый TestLog, а не в
    UI. Подкоманды, которым нужно окно лога, отклоняем. }
  if ACmd = 111 then
  begin
    SubCmd := AnsiLowerCase(EvalScriptPoint(FT, FT.Line, 1));
    if (Length(SubCmd) > 0) and (SubCmd[1] = '"') then
      Delete(SubCmd, 1, 1);
    if (SubCmd = 'clear') or (SubCmd = 'clear_all') or
       (SubCmd = 'clear_current') or (SubCmd = 'save') or
       (SubCmd = 'save_current') or (SubCmd = 'open') or
       (SubCmd = 'close') or (SubCmd = 'mode') or
       (SubCmd = 'off') or (SubCmd = 'on') or
       (SubCmd = 'commands') or (SubCmd = 'level') then
      raise EScriptDriverError.CreateFmt(
        'log %s is not supported (line %d)', [SubCmd, FT.CurLine]);
    FT.AppendTestLog(StripMsgNul(
      FixLineBreaks(EvalScriptExpr(FT, FT.Line, -1))));
    Exit;
  end;

  FT.Msg := '';
  ExecScriptCommand(FT, ACmd, FT.Line);
  { `msg` кладёт текст в Msg, а в тестовом режиме он уже записан в
    TestMessageText. Иначе драйвер принял бы сообщение за ошибку скрипта. }
  if ACmd = 16 then
    FT.Msg := '';
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

constructor TLegacyScriptSession.Create(const ASettings: IScriptSettings);
begin
  inherited Create;
  FMaxSteps := 100000;
  FSettings := ASettings;
  FHostCalls := TStringList.Create;
  Reset;
end;

destructor TLegacyScriptSession.Destroy;
begin
  FreeAndNil(FDriver);
  FreeAndNil(FT);
  FreeAndNil(FHostCalls);
  inherited Destroy;
end;

procedure TLegacyScriptSession.SetError(AKind: TScriptErrorKind; ALine: Integer;
  const AMessage: string);
begin
  FLastError.Kind := AKind;
  FLastError.Line := ALine;
  FLastError.Message := AMessage;
end;

procedure TLegacyScriptSession.SetErrorFromException(E: Exception);
var
  Kind: TScriptErrorKind;
begin
  if Pos('step limit', E.Message) > 0 then
    Kind := sekStepLimit
  else if Pos('restart_script', E.Message) > 0 then
    Kind := sekRestart
  else if Pos('script suspended', E.Message) > 0 then
    Kind := sekSuspended
  else if Pos('unknown command', E.Message) > 0 then
    Kind := sekUnknownCommand
  else if (Pos('is not supported', E.Message) > 0) or
          (Pos('are not supported', E.Message) > 0) then
    Kind := sekUnsupportedCommand
  else if Pos('script error', E.Message) > 0 then
    Kind := sekScriptError
  else
    Kind := sekOther;
  SetError(Kind, FT.CurLine, E.Message);
end;

{ Таблицы и прочее глобальное состояние движка -- глобальное состояние
  Unit1, поэтому его сбрасывают при каждом создании сессии. }
procedure TLegacyScriptSession.Reset;
begin
  FreeAndNil(FDriver);
  FreeAndNil(FT);
  ResetGlobals;
  FT := TScanThread.CreateForTest(FSettings);
  FT.SetTestNow(DefaultTestNow);
  FDriver := TScriptDriver.Create(
    TLegacyDriverState.Create(FT),
    TLegacyDriverHost.Create(FT, FHostCalls));
  FHostCalls.Clear;
  FT.ClearTestObservations;
  SetError(sekNone, 0, '');
end;

procedure TLegacyScriptSession.SetNow(const AValue: TDateTime);
begin
  if FT = nil then
    Reset;
  FT.SetTestNow(AValue);
end;

{ Внутренний вычислитель ожидает 'calc ' перед выражением и nv = -1:
  тогда он берёт всё после первого слова. }
function TLegacyScriptSession.Eval(const Expr: string): string;
begin
  if FT = nil then
    Reset;
  SetError(sekNone, 0, '');
  try
    Result := EvalScriptExpr(FT, 'calc ' + Expr, -1);
  except
    on E: Exception do
    begin
      SetErrorFromException(E);
      raise;
    end;
  end;
end;

{ Загрузка сценария и сброс состояния; сам line-loop -- в uScriptDriver. }
procedure TLegacyScriptSession.RunScript(const Script: string);
var
  I: Integer;
  LinesList: TStringList;
begin
  if FT = nil then
    Reset;

  SetError(sekNone, 0, '');
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
  if FSettings <> nil then
    FT.LogLevel := FSettings.LogLevel
  else
    FT.LogLevel := 0;
  FT.LoggingCommands := False;
  FT.AutoStart := False;
  FT.ShowRun := False;
  FHostCalls.Clear;
  FT.ClearTestObservations;

  FDriver.MaxSteps := FMaxSteps;
  try
    FDriver.Run;
  except
    on E: Exception do
    begin
      SetErrorFromException(E);
      raise;
    end;
  end;
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

function TLegacyScriptSession.LastErrorInfo: TScriptError;
begin
  Result := FLastError;
end;

function TLegacyScriptSession.TryNumVar(const Name: string;
  out Value: Int64): Boolean;
var
  I: Integer;
  Lower: string;
begin
  Value := 0;
  Result := False;
  if FT = nil then
    Reset;
  Lower := AnsiLowerCase(Name);
  for I := 0 to Length(FT.Vars) - 1 do
    if FT.Vars[I].Name = Lower then
    begin
      Value := FT.Vars[I].Value;
      Result := True;
      Exit;
    end;
end;

function TLegacyScriptSession.TryStrVar(const Name: string;
  out Value: string): Boolean;
var
  I: Integer;
  Lower: string;
begin
  Value := '';
  Result := False;
  if FT = nil then
    Reset;
  Lower := AnsiLowerCase(Name);
  for I := 0 to Length(FT.Timers) - 1 do
    if FT.Timers[I].Name = Lower then
    begin
      Value := FT.Timers[I].Value;
      Result := True;
      Exit;
    end;
end;

function TLegacyScriptSession.TryArrCell(const Name: string; Row, Col: Integer;
  out Value: string): Boolean;
var
  I: Integer;
  Lower: string;
begin
  Value := '';
  Result := False;
  if (Row < 1) or (Col < 1) then
    Exit;
  if FT = nil then
    Reset;
  Lower := AnsiLowerCase(Name);
  for I := 0 to Length(FT.Arr48) - 1 do
    if FT.Arr48[I].Name = Lower then
    begin
      if (Length(FT.Arr48[I].Data) < Row) or
         (Length(FT.Arr48[I].Data[Row - 1]) < Col) then
        Exit;
      Value := FT.Arr48[I].Data[Row - 1][Col - 1];
      Result := True;
      Exit;
    end;
end;

function TLegacyScriptSession.LogText: string;
begin
  if FT = nil then
    Exit('');
  Result := FT.TestLogText;
end;

function TLegacyScriptSession.HostCallText: string;
begin
  Result := FHostCalls.Text;
end;

function TLegacyScriptSession.MessageText: string;
begin
  if FT = nil then
    Reset;
  Result := FT.TestMessageText;
end;

function TLegacyScriptSession.HintText: string;
begin
  if FT = nil then
    Reset;
  Result := FT.TestHintText;
end;

function TLegacyScriptSession.ExitRequested: Boolean;
begin
  if FT = nil then
    Reset;
  Result := FT.TestExitRequested;
end;

end.
