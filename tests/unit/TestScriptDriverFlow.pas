unit TestScriptDriverFlow;
{$mode objfpc}{$H+}

interface

uses
  Classes, fpcunit, testregistry, uScriptDriver;

type
  TFakeDriverState = class(TInterfacedObject, IScriptDriverState)
  private
    FLines: TStringList;
    FCurLine: Integer;
    FLineText: string;
    FLogPrefix: string;
    FRestartFlag: Boolean;
    FRepeatLine: Boolean;
    FRepeatCmd: Boolean;
    FStopRequested: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddLine(const S: string);
    property StopRequested: Boolean
      read FStopRequested write FStopRequested;
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

  TFakeDriverHost = class(TInterfacedObject, IScriptDriverHost)
  private
    FState: TFakeDriverState;
    FCommands: TStringList;
    FEvalCalls: TStringList;
    FExecuted: TStringList;
    FEvalEmpty: Boolean;
    FBeforeLineCalls: Integer;
    FWaitBeforeCalls: Integer;
    FBeforeLineResult: TScriptStepResult;
    FBeforeLineRetries: Integer;
    FWaitEmptyLineResult: TScriptStepResult;
    FWaitEmptyPrefixResult: TScriptStepResult;
    FWaitBeforeResult: TScriptStepResult;
    FWaitBeforeRetries: Integer;
    FRepeatCmdLeft: Integer;
    FRepeatLineLeft: Integer;
    FRestartLeft: Integer;
    function FirstToken(const S: string): string;
  public
    constructor Create(AState: TFakeDriverState);
    destructor Destroy; override;
    function AddCommand(const Name: string): Integer;
    property BeforeLineCalls: Integer read FBeforeLineCalls;
    property WaitBeforeCalls: Integer read FWaitBeforeCalls;
    function ExecutedCount: Integer;
    function ExecutedName(Index: Integer): string;
    function EvalName(Index: Integer): string;
    function EvalCount: Integer;
    { Поведение хуков. }
    property EvalEmpty: Boolean read FEvalEmpty write FEvalEmpty;
    property BeforeLineResult: TScriptStepResult
      read FBeforeLineResult write FBeforeLineResult;
    property BeforeLineRetries: Integer
      read FBeforeLineRetries write FBeforeLineRetries;
    property WaitEmptyLineResult: TScriptStepResult
      read FWaitEmptyLineResult write FWaitEmptyLineResult;
    property WaitEmptyPrefixResult: TScriptStepResult
      read FWaitEmptyPrefixResult write FWaitEmptyPrefixResult;
    property WaitBeforeResult: TScriptStepResult
      read FWaitBeforeResult write FWaitBeforeResult;
    property WaitBeforeRetries: Integer
      read FWaitBeforeRetries write FWaitBeforeRetries;
    property RepeatCmdLeft: Integer read FRepeatCmdLeft write FRepeatCmdLeft;
    property RepeatLineLeft: Integer read FRepeatLineLeft write FRepeatLineLeft;
    property RestartLeft: Integer read FRestartLeft write FRestartLeft;
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

  TScriptDriverFlowTest = class(TTestCase)
  private
    FState: TFakeDriverState;
    FHost: TFakeDriverHost;
    FDriver: TScriptDriver;
    procedure AssertStep(const Msg: string;
      Expected, Actual: TScriptStepResult);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestStepStripsCommentsAndEmptyLines;
    procedure TestStepInsertsParenAndCutsColon;
    procedure TestStepEmptyPrefixSkipsLine;
    procedure TestStepRepeatLineSkipsBeforeLine;
    procedure TestStepRepeatCmd;
    procedure TestStepRestartFlag;
    procedure TestRunRestartPolicyError;
    procedure TestRunRestartPolicyReset;
    procedure TestStepEndWhenNoLines;
    procedure TestStepScanLoopFromWaitEmptyLine;
    procedure TestStepAgain;
    procedure TestStepRetryFromBeforeLine;
    procedure TestStepRetryFromWaitBeforeCommand;
    procedure TestRunStepLimit;
    procedure TestRunStopsOnStop;
    procedure TestStepLuaBlockConsumed;
    procedure TestStepBlockCommentConsumed;
  end;

implementation

uses
  SysUtils;

{ ------------------------------------------------------------------------- }
{ Fake state/host: минимальная модель строк скрипта без UI. }

{ TFakeDriverState }

constructor TFakeDriverState.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
end;

destructor TFakeDriverState.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TFakeDriverState.AddLine(const S: string);
begin
  FLines.Add(S);
end;

function TFakeDriverState.GetLinesCount: Integer;
begin
  Result := FLines.Count;
end;

function TFakeDriverState.GetLine(Index: Integer): string;
begin
  Result := FLines[Index];
end;

function TFakeDriverState.GetCurLine: Integer;
begin
  Result := FCurLine;
end;

procedure TFakeDriverState.SetCurLine(Value: Integer);
begin
  FCurLine := Value;
end;

function TFakeDriverState.GetLineText: string;
begin
  Result := FLineText;
end;

procedure TFakeDriverState.SetLineText(const Value: string);
begin
  FLineText := Value;
end;

function TFakeDriverState.GetLogPrefix: string;
begin
  Result := FLogPrefix;
end;

procedure TFakeDriverState.SetLogPrefix(const Value: string);
begin
  FLogPrefix := Value;
end;

function TFakeDriverState.GetRestartFlag: Boolean;
begin
  Result := FRestartFlag;
end;

procedure TFakeDriverState.SetRestartFlag(Value: Boolean);
begin
  FRestartFlag := Value;
end;

function TFakeDriverState.GetRepeatLine: Boolean;
begin
  Result := FRepeatLine;
end;

procedure TFakeDriverState.SetRepeatLine(Value: Boolean);
begin
  FRepeatLine := Value;
end;

function TFakeDriverState.GetRepeatCmd: Boolean;
begin
  Result := FRepeatCmd;
end;

procedure TFakeDriverState.SetRepeatCmd(Value: Boolean);
begin
  FRepeatCmd := Value;
end;

{ TFakeDriverHost }

constructor TFakeDriverHost.Create(AState: TFakeDriverState);
begin
  inherited Create;
  FState := AState;
  FCommands := TStringList.Create;
  FEvalCalls := TStringList.Create;
  FExecuted := TStringList.Create;
  FBeforeLineResult := srNext;
  FWaitEmptyLineResult := srNext;
  FWaitEmptyPrefixResult := srNext;
  FWaitBeforeResult := srNext;
  AddCommand('set');
  AddCommand('if');
  AddCommand('echo');
  AddCommand('again');
  AddCommand('loop');
  AddCommand('restart');
  AddCommand('stop');
  AddCommand('forever');
end;

destructor TFakeDriverHost.Destroy;
begin
  FCommands.Free;
  FEvalCalls.Free;
  FExecuted.Free;
  inherited Destroy;
end;

function TFakeDriverHost.AddCommand(const Name: string): Integer;
begin
  Result := FCommands.Add(Name);
end;

function TFakeDriverHost.ExecutedCount: Integer;
begin
  Result := FExecuted.Count;
end;

function TFakeDriverHost.ExecutedName(Index: Integer): string;
begin
  Result := FExecuted[Index];
end;

function TFakeDriverHost.EvalName(Index: Integer): string;
begin
  Result := FEvalCalls[Index];
end;

function TFakeDriverHost.EvalCount: Integer;
begin
  Result := FEvalCalls.Count;
end;

function TFakeDriverHost.FirstToken(const S: string): string;
var
  P: Integer;
begin
  Result := S;
  P := Pos(' ', Result);
  if P > 0 then
    Result := Copy(Result, 1, P - 1);
end;

function TFakeDriverHost.BeforeLine: TScriptStepResult;
begin
  Inc(FBeforeLineCalls);
  if FState.StopRequested then
    Exit(srStop);
  if FBeforeLineRetries > 0 then
  begin
    Dec(FBeforeLineRetries);
    Exit(srRetry);
  end;
  Result := FBeforeLineResult;
end;

function TFakeDriverHost.EvalLine(const S: string): string;
begin
  FEvalCalls.Add(S);
  if FEvalEmpty then
    Exit('');
  Result := FirstToken(S);
end;

function TFakeDriverHost.ResolveCommand(const AName: string): Integer;
begin
  Result := FCommands.IndexOf(AName);
end;

procedure TFakeDriverHost.ExecuteCommand(var ACmd: Integer);
var
  Name: string;
begin
  if (ACmd >= 0) and (ACmd < FCommands.Count) then
    Name := FCommands[ACmd]
  else
    Name := '#' + IntToStr(ACmd);
  FExecuted.Add(Name);

  if Name = 'again' then
  begin
    FState.SetRepeatLine(FRepeatLineLeft > 0);
    if FRepeatLineLeft > 0 then
      Dec(FRepeatLineLeft);
  end
  else if Name = 'loop' then
  begin
    FState.SetRepeatCmd(FRepeatCmdLeft > 0);
    if FRepeatCmdLeft > 0 then
      Dec(FRepeatCmdLeft);
  end
  else if Name = 'forever' then
    FState.SetRepeatCmd(True)
  else if Name = 'restart' then
  begin
    FState.SetRestartFlag(FRestartLeft > 0);
    if FRestartLeft > 0 then
      Dec(FRestartLeft);
  end
  else if Name = 'stop' then
    FState.StopRequested := True;
end;

function TFakeDriverHost.HandleLuaBlock(out AConsumed: Boolean): TScriptStepResult;
var
  I: Integer;
begin
  AConsumed := False;
  if AnsiLowerCase(FState.GetLineText) = '--lua' then
  begin
    I := FState.GetCurLine + 1;
    while I < FState.GetLinesCount do
    begin
      if AnsiLowerCase(FState.GetLine(I)) = '--endlua' then
      begin
        FState.SetCurLine(I);
        AConsumed := True;
        Break;
      end;
      Inc(I);
    end;
    if not AConsumed then
      raise EScriptDriverError.Create('lua block is not closed');
  end;
  Result := srNext;
end;

function TFakeDriverHost.HandleBlockComment(out AConsumed: Boolean): TScriptStepResult;
begin
  AConsumed := False;
  if Pos('(*', FState.GetLineText) > 0 then
  begin
    FState.SetCurLine(FState.GetCurLine + 1);
    AConsumed := True;
  end;
  Result := srNext;
end;

function TFakeDriverHost.WaitEmptyLine: TScriptStepResult;
begin
  if FState.StopRequested then
    Exit(srScanLoop);
  Result := FWaitEmptyLineResult;
end;

function TFakeDriverHost.WaitEmptyPrefix: TScriptStepResult;
begin
  Result := FWaitEmptyPrefixResult;
end;

function TFakeDriverHost.WaitBeforeCommand: TScriptStepResult;
begin
  Inc(FWaitBeforeCalls);
  if FWaitBeforeRetries > 0 then
  begin
    Dec(FWaitBeforeRetries);
    Exit(srRetry);
  end;
  Result := FWaitBeforeResult;
end;

{ TScriptDriverFlowTest }

procedure TScriptDriverFlowTest.SetUp;
begin
  FState := TFakeDriverState.Create;
  FHost := TFakeDriverHost.Create(FState);
  FDriver := TScriptDriver.Create(FState, FHost);
end;

procedure TScriptDriverFlowTest.TearDown;
begin
  FreeAndNil(FDriver);
  FState := nil;
  FHost := nil;
end;

procedure TScriptDriverFlowTest.AssertStep(const Msg: string;
  Expected, Actual: TScriptStepResult);
begin
  AssertEquals(Msg, Ord(Expected), Ord(Actual));
end;

procedure TScriptDriverFlowTest.TestStepStripsCommentsAndEmptyLines;
begin
  FState.AddLine('set #r 1 // c');
  FState.AddLine('');
  FState.AddLine('// only');

  AssertStep('line 0', srNext, FDriver.Step);
  AssertEquals('curline after set', 1, FState.GetCurLine);
  AssertStep('empty line', srNext, FDriver.Step);
  AssertEquals('curline after empty', 2, FState.GetCurLine);
  AssertStep('comment line', srNext, FDriver.Step);
  AssertEquals('curline after comment', 3, FState.GetCurLine);
  AssertStep('end', srEnd, FDriver.Step);

  AssertEquals('executed', 1, FHost.ExecutedCount);
  AssertEquals('command', 'set', FHost.ExecutedName(0));
end;

procedure TScriptDriverFlowTest.TestStepInsertsParenAndCutsColon;
begin
  FState.AddLine('if(1)');
  FState.AddLine('echo:foo');

  AssertStep('if', srNext, FDriver.Step);
  AssertEquals('paren fixed', 'if (1)', FState.GetLineText);
  AssertEquals('if eval calls', 2, FHost.EvalCount);
  AssertEquals('first eval', 'if(1)', FHost.EvalName(0));
  AssertEquals('second eval', 'if (1)', FHost.EvalName(1));

  AssertStep('colon', srNext, FDriver.Step);
  AssertEquals('executed 0', 'if', FHost.ExecutedName(0));
  AssertEquals('executed 1', 'echo', FHost.ExecutedName(1));
end;

procedure TScriptDriverFlowTest.TestStepEmptyPrefixSkipsLine;
begin
  FState.AddLine('set #r 1');
  FHost.EvalEmpty := True;

  AssertStep('empty prefix', srNext, FDriver.Step);
  AssertEquals('line skipped', 1, FState.GetCurLine);
  AssertEquals('nothing executed', 0, FHost.ExecutedCount);
end;

procedure TScriptDriverFlowTest.TestStepRepeatLineSkipsBeforeLine;
begin
  FState.AddLine('again');
  FState.AddLine('set #r 1');
  FHost.RepeatLineLeft := 1;

  AssertStep('repeat line', srNext, FDriver.Step);
  AssertEquals('line advanced once', 1, FState.GetCurLine);
  AssertEquals('again executed twice', 2, FHost.ExecutedCount);
  AssertEquals('again 0', 'again', FHost.ExecutedName(0));
  AssertEquals('again 1', 'again', FHost.ExecutedName(1));
  AssertEquals('BeforeLine once per line', 1, FHost.BeforeLineCalls);

  AssertStep('next line', srNext, FDriver.Step);
  AssertEquals('set after repeat', 'set', FHost.ExecutedName(2));
  AssertEquals('BeforeLine twice', 2, FHost.BeforeLineCalls);
end;

procedure TScriptDriverFlowTest.TestStepRepeatCmd;
begin
  FState.AddLine('loop');
  FHost.RepeatCmdLeft := 2;

  AssertStep('repeat cmd', srNext, FDriver.Step);
  AssertEquals('line advanced', 1, FState.GetCurLine);
  AssertEquals('loop executed 3 times', 3, FHost.ExecutedCount);
  AssertEquals('BeforeLine once', 1, FHost.BeforeLineCalls);
end;

procedure TScriptDriverFlowTest.TestStepRestartFlag;
begin
  FState.AddLine('restart');
  FHost.RestartLeft := 1;

  AssertStep('restart', srRestart, FDriver.Step);
  AssertEquals('line not advanced', 0, FState.GetCurLine);
  AssertTrue('flag left to caller', FState.GetRestartFlag);
end;

procedure TScriptDriverFlowTest.TestRunRestartPolicyError;
var
  Raised: Boolean;
begin
  FState.AddLine('restart');
  FHost.RestartLeft := 1;
  Raised := False;
  try
    FDriver.Run(rpError);
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('rpError must raise', Raised);
end;

procedure TScriptDriverFlowTest.TestRunRestartPolicyReset;
begin
  FState.AddLine('restart');
  FState.AddLine('set #r 1');
  FHost.RestartLeft := 1;

  FDriver.Run(rpReset);

  AssertEquals('script completed', 2, FState.GetCurLine);
  AssertFalse('flag cleared', FState.GetRestartFlag);
  AssertEquals('executed', 3, FHost.ExecutedCount);
  AssertEquals('restart 0', 'restart', FHost.ExecutedName(0));
  AssertEquals('restart 1', 'restart', FHost.ExecutedName(1));
  AssertEquals('set', 'set', FHost.ExecutedName(2));
end;

procedure TScriptDriverFlowTest.TestStepEndWhenNoLines;
begin
  AssertStep('no lines', srEnd, FDriver.Step);
  AssertEquals('BeforeLine not called', 0, FHost.BeforeLineCalls);
end;

procedure TScriptDriverFlowTest.TestStepScanLoopFromWaitEmptyLine;
begin
  FState.AddLine('');
  FState.AddLine('set #r 1');
  FHost.WaitEmptyLineResult := srScanLoop;

  AssertStep('scan loop', srScanLoop, FDriver.Step);
  AssertEquals('line stays', 0, FState.GetCurLine);
  AssertEquals('nothing executed', 0, FHost.ExecutedCount);
end;

procedure TScriptDriverFlowTest.TestStepAgain;
begin
  FState.AddLine('set #r 1');
  FHost.BeforeLineResult := srAgain;

  AssertStep('again', srAgain, FDriver.Step);
  AssertEquals('nothing executed', 0, FHost.ExecutedCount);
  AssertEquals('BeforeLine called once', 1, FHost.BeforeLineCalls);
end;

procedure TScriptDriverFlowTest.TestStepRetryFromBeforeLine;
begin
  FState.AddLine('set #r 1');
  FHost.BeforeLineRetries := 1;

  AssertStep('retry before line', srNext, FDriver.Step);
  AssertEquals('BeforeLine twice', 2, FHost.BeforeLineCalls);
  AssertEquals('executed once', 1, FHost.ExecutedCount);
end;

procedure TScriptDriverFlowTest.TestStepRetryFromWaitBeforeCommand;
begin
  FState.AddLine('set #r 1');
  FHost.WaitBeforeRetries := 1;

  AssertStep('retry wait', srNext, FDriver.Step);
  AssertEquals('BeforeLine twice', 2, FHost.BeforeLineCalls);
  AssertEquals('WaitBeforeCommand twice', 2, FHost.WaitBeforeCalls);
  AssertEquals('same line executed once', 1, FHost.ExecutedCount);
  AssertEquals('line advanced', 1, FState.GetCurLine);
end;

procedure TScriptDriverFlowTest.TestRunStepLimit;
var
  Raised: Boolean;
begin
  FState.AddLine('forever');
  FDriver.MaxSteps := 10;
  Raised := False;
  try
    FDriver.Run;
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('MaxSteps must raise', Raised);
  AssertEquals('10 commands plus the one over the limit',
    11, FHost.ExecutedCount);
end;

procedure TScriptDriverFlowTest.TestRunStopsOnStop;
begin
  FState.AddLine('set #r 1');
  FState.AddLine('stop');
  FState.AddLine('set #r 2');

  FDriver.Run;

  AssertEquals('stop prevents next line', 2, FHost.ExecutedCount);
  AssertEquals('set', 'set', FHost.ExecutedName(0));
  AssertEquals('stop', 'stop', FHost.ExecutedName(1));
end;

procedure TScriptDriverFlowTest.TestStepLuaBlockConsumed;
begin
  FState.AddLine('--lua');
  FState.AddLine('print(1)');
  FState.AddLine('--endlua');
  FState.AddLine('set #r 1');

  AssertStep('lua block', srNext, FDriver.Step);
  AssertEquals('jump after endlua', 3, FState.GetCurLine);
  AssertEquals('nothing executed', 0, FHost.ExecutedCount);

  AssertStep('line after lua', srNext, FDriver.Step);
  AssertEquals('set executed', 1, FHost.ExecutedCount);
end;

procedure TScriptDriverFlowTest.TestStepBlockCommentConsumed;
begin
  FState.AddLine('(* comment *)');
  FState.AddLine('middle');
  FState.AddLine('set #r 1');

  AssertStep('block comment', srNext, FDriver.Step);
  AssertEquals('line after comment', 2, FState.GetCurLine);
  AssertEquals('nothing executed', 0, FHost.ExecutedCount);

  AssertStep('line after block', srNext, FDriver.Step);
  AssertEquals('set executed', 1, FHost.ExecutedCount);
end;

initialization
  RegisterTest(TScriptDriverFlowTest);
end.
