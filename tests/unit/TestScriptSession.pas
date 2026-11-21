unit TestScriptSession;
{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, uScriptTestSession;

type
  TScriptSessionTest = class(TTestCase)
  private
    FSession: IScriptSession;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestTryNumVarFindsExisting;
    procedure TestTryNumVarDoesNotCreateMissing;
    procedure TestTryStrVarFindsExisting;
    procedure TestTryStrVarDoesNotCreateMissing;
    procedure TestTryArrCellFindsExisting;
    procedure TestTryArrCellRejectsMissing;
    procedure TestTryArrCellMissingColumn;
    procedure TestHostCallTextRecordsCommands;
    procedure TestLogTextStartsEmpty;
    procedure TestLogTextCapturesCommandLog;
    procedure TestLogTextEvaluatesVariables;
    procedure TestLogStateSubcommandsRejected;
    procedure TestStructuredUnknownCommand;
    procedure TestStructuredStepLimit;
    procedure TestObservationsResetBetweenRuns;
    procedure TestAllowedCommandsIncludeWaitMsgHintExit;
    procedure TestSetNowControlsClockNames;
  end;

implementation

uses
  SysUtils, uLegacyScriptSession, uScriptDriver;

procedure TScriptSessionTest.SetUp;
begin
  FSession := CreateSession(sbLegacy);
end;

procedure TScriptSessionTest.TearDown;
begin
  FSession := nil;
end;

procedure TScriptSessionTest.TestTryNumVarFindsExisting;
var
  Value: Int64;
begin
  FSession.RunScript('set #r 42');
  AssertTrue('existing numeric variable', FSession.TryNumVar('r', Value));
  AssertEquals(42, Value);
end;

{ Опечатка в target не должна давать зелёный тест: Try не заводит
  переменную, в отличие от старого NumVar/FindScriptVar. }
procedure TScriptSessionTest.TestTryNumVarDoesNotCreateMissing;
var
  Value: Int64;
begin
  AssertFalse('missing numeric variable', FSession.TryNumVar('typo', Value));
  AssertFalse('missing variable must stay missing',
    FSession.TryNumVar('typo', Value));
end;

procedure TScriptSessionTest.TestTryStrVarFindsExisting;
var
  Value: string;
begin
  FSession.RunScript('set $s hello');
  AssertTrue('existing string variable', FSession.TryStrVar('s', Value));
  AssertEquals('hello', Value);
end;

procedure TScriptSessionTest.TestTryStrVarDoesNotCreateMissing;
var
  Value: string;
begin
  AssertFalse('missing string variable', FSession.TryStrVar('typo', Value));
  AssertFalse('missing string variable must stay missing',
    FSession.TryStrVar('typo', Value));
end;

procedure TScriptSessionTest.TestTryArrCellFindsExisting;
var
  Value: string;
begin
  FSession.RunScript('set %a [1] one'#10'set %a [2] two');
  AssertTrue('existing array cell', FSession.TryArrCell('a', 2, 1, Value));
  AssertEquals('two', Value);
end;

procedure TScriptSessionTest.TestTryArrCellRejectsMissing;
var
  Value: string;
begin
  AssertFalse('missing array', FSession.TryArrCell('nope', 1, 1, Value));
  FSession.RunScript('set %a [1] one');
  AssertFalse('row out of bounds', FSession.TryArrCell('a', 2, 1, Value));
  AssertFalse('column out of bounds', FSession.TryArrCell('a', 1, 2, Value));
end;

procedure TScriptSessionTest.TestTryArrCellMissingColumn;
var
  Value: string;
begin
  FSession.RunScript('set %a 1|2/3|4'#10'delete_array %a 2 1');
  AssertFalse('deleted column is gone',
    FSession.TryArrCell('a', 1, 2, Value));
end;

procedure TScriptSessionTest.TestHostCallTextRecordsCommands;
var
  Calls: string;
begin
  FSession.RunScript('set #r 1'#10'set $s two');
  Calls := FSession.HostCallText;
  AssertTrue('first set recorded: ' + Calls, Pos('0: set', Calls) > 0);
  AssertTrue('second set recorded: ' + Calls, Pos('1: set', Calls) > 0);
end;

procedure TScriptSessionTest.TestLogTextStartsEmpty;
begin
  AssertEquals('', FSession.LogText);
end;

procedure TScriptSessionTest.TestLogTextCapturesCommandLog;
var
  Log: string;
begin
  FSession.RunScript('log hello');
  Log := FSession.LogText;
  AssertTrue('log text contains line: ' + Log, Pos('hello', Log) > 0);
end;

procedure TScriptSessionTest.TestLogTextEvaluatesVariables;
var
  Log: string;
begin
  FSession.RunScript('set #r 5'#10'log #r');
  Log := FSession.LogText;
  AssertTrue('log text contains value: ' + Log, Pos('5', Log) > 0);
  AssertTrue('log text is evaluated, not raw: ' + Log, Pos('#r', Log) = 0);
end;

procedure TScriptSessionTest.TestLogStateSubcommandsRejected;
const
  Scripts: array[0..3] of string = (
    'log off', 'log on', 'log commands', 'log level 0');
var
  I: Integer;
  Raised: Boolean;
begin
  for I := 0 to High(Scripts) do
  begin
    Raised := False;
    try
      FSession.RunScript(Scripts[I]);
    except
      on E: EScriptDriverError do
        Raised := True;
    end;
    AssertTrue(Scripts[I] + ' must be rejected', Raised);
  end;
end;

procedure TScriptSessionTest.TestStructuredUnknownCommand;
var
  Info: TScriptError;
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('bogus 1');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('unknown command must raise', Raised);
  Info := FSession.LastErrorInfo;
  AssertEquals(Ord(sekUnknownCommand), Ord(Info.Kind));
  AssertEquals(0, Info.Line);
  AssertTrue('message mentions command: ' + Info.Message,
    Pos('bogus', Info.Message) > 0);
end;

procedure TScriptSessionTest.TestStructuredStepLimit;
var
  Info: TScriptError;
  Session: TLegacyScriptSession;
  Raised: Boolean;
begin
  Session := TLegacyScriptSession.Create(nil);
  try
    Session.MaxSteps := 100;
    Raised := False;
    try
      Session.RunScript(':loop'#10'goto loop');
    except
      on E: EScriptDriverError do
        Raised := True;
    end;
    AssertTrue('step limit must raise', Raised);
    Info := Session.LastErrorInfo;
    AssertEquals(Ord(sekStepLimit), Ord(Info.Kind));
    AssertTrue('message mentions limit: ' + Info.Message,
      Pos('step limit', Info.Message) > 0);
  finally
    Session.Free;
  end;
end;

procedure TScriptSessionTest.TestObservationsResetBetweenRuns;
begin
  FSession.RunScript('msg one'#10'hint h1');
  FSession.RunScript('set #r 1');
  AssertEquals('messages reset', '', FSession.MessageText);
  AssertEquals('hint reset', '', FSession.HintText);
  AssertFalse('exit flag reset', FSession.ExitRequested);
end;

procedure TScriptSessionTest.TestAllowedCommandsIncludeWaitMsgHintExit;
var
  Allowed: TAllowedCommandIds;
  I: Integer;
  function HasIndex(AIndex: Integer): Boolean;
  var
    J: Integer;
  begin
    for J := 0 to High(Allowed) do
      if Allowed[J] = AIndex then
        Exit(True);
    Result := False;
  end;
begin
  Allowed := TestAllowedCommands;
  for I := 0 to High(Allowed) do
    AssertTrue('allowlist index in range: ' + IntToStr(Allowed[I]),
      (Allowed[I] >= 0) and (Allowed[I] < 136));
  AssertTrue('wait allowed', HasIndex(15));
  AssertTrue('msg allowed', HasIndex(16));
  AssertTrue('hint allowed', HasIndex(98));
  AssertTrue('exit allowed', HasIndex(119));
end;

procedure TScriptSessionTest.TestSetNowControlsClockNames;
begin
  FSession.SetNow(EncodeDate(1999, 12, 31) + EncodeTime(23, 58, 57, 0));
  AssertEquals('year', '1999', FSession.Eval('year'));
  AssertEquals('datenow', '1999-12-31', FSession.Eval('datenow'));
  AssertEquals('timenow', '23:58:57', FSession.Eval('timenow'));
end;

initialization
  RegisterTest(TScriptSessionTest);
end.
