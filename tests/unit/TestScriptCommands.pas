unit TestScriptCommands;
{$mode objfpc}{$H+}

{ Наблюдаемость команд, которым нужен test-hook: msg/hint/exit/wait.
  TSV-кейсы умеют читать только переменные, поэтому это code-тесты. }

interface

uses
  fpcunit, testregistry, uScriptTestSession;

type
  TScriptCommandsTest = class(TTestCase)
  private
    FSession: IScriptSession;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestMsgCaptured;
    procedure TestMsgEvaluatesVariables;
    procedure TestHintCaptured;
    procedure TestHintEvaluatesVariables;
    procedure TestExitStopsAndFlags;
    procedure TestWaitInvalid;
  end;

implementation

uses
  SysUtils, uLegacyScriptSession, uScriptDriver;

procedure TScriptCommandsTest.SetUp;
begin
  FSession := CreateSession(sbLegacy);
end;

procedure TScriptCommandsTest.TearDown;
begin
  FSession := nil;
end;

procedure TScriptCommandsTest.TestMsgCaptured;
var
  Text: string;
begin
  FSession.RunScript('msg hello');
  Text := FSession.MessageText;
  AssertTrue('msg text: ' + Text, Pos('hello', Text) > 0);
  AssertEquals('msg is not an error', Ord(sekNone),
    Ord(FSession.LastErrorInfo.Kind));
end;

procedure TScriptCommandsTest.TestMsgEvaluatesVariables;
var
  Text: string;
begin
  FSession.RunScript('set #r 5'#10'msg value #r');
  Text := FSession.MessageText;
  AssertTrue('evaluated msg: ' + Text, Pos('value 5', Text) > 0);
end;

procedure TScriptCommandsTest.TestHintCaptured;
begin
  FSession.RunScript('hint hello');
  AssertEquals('hello', FSession.HintText);
end;

procedure TScriptCommandsTest.TestHintEvaluatesVariables;
begin
  FSession.RunScript('set #r 5'#10'hint #r');
  AssertEquals('5', FSession.HintText);
end;

procedure TScriptCommandsTest.TestExitStopsAndFlags;
begin
  FSession.RunScript('set #r 1'#10'exit'#10'set #r 2');
  AssertTrue('exit flag', FSession.ExitRequested);
  AssertEquals('script stopped before the next set', 1, FSession.NumVar('r'));
end;

procedure TScriptCommandsTest.TestWaitInvalid;
var
  Raised: Boolean;
  Info: TScriptError;
begin
  Raised := False;
  try
    FSession.RunScript('wait abc');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('wait abc must fail', Raised);
  Info := FSession.LastErrorInfo;
  AssertEquals('structured script error', Ord(sekScriptError), Ord(Info.Kind));
  AssertTrue('error mentions delay: ' + Info.Message,
    Pos(ToScript('задержк'), Info.Message) > 0);
end;

initialization
  RegisterTest(TScriptCommandsTest);
end.
