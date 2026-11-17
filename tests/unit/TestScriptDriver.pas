unit TestScriptDriver;
{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, uLegacyScriptSession, uScriptDriver;

type
  TScriptDriverTest = class(TTestCase)
  private
    FSession: TLegacyScriptSession;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestUnknownCommand;
    procedure TestEvalUnknownCommand;
    procedure TestEvalRepeatHitsStepLimit;
    procedure TestSetLoggingRejected;
    procedure TestExternalCommandRejected;
    procedure TestLuaBlockRejected;
    procedure TestBlockCommentRejected;
    procedure TestGotoLoopHitsStepLimit;
    procedure TestEndScriptStops;
    procedure TestScalarSetRuns;
  end;

implementation

uses
  SysUtils;

procedure TScriptDriverTest.SetUp;
begin
  FSession := TLegacyScriptSession.Create;
end;

procedure TScriptDriverTest.TearDown;
begin
  FreeAndNil(FSession);
end;

procedure TScriptDriverTest.TestUnknownCommand;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('bogus 1');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('unknown command must raise EScriptDriverError', Raised);
end;

procedure TScriptDriverTest.TestEvalUnknownCommand;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('eval (bogus)');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('eval to unknown command must raise EScriptDriverError', Raised);
end;

procedure TScriptDriverTest.TestEvalRepeatHitsStepLimit;
var
  Raised: Boolean;
begin
  FSession.MaxSteps := 100;
  Raised := False;
  try
    FSession.RunScript('set $c eval (chr(36)c)'#10'eval ($c)');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('self-referential eval must hit MaxSteps', Raised);
end;

procedure TScriptDriverTest.TestSetLoggingRejected;
const
  Scripts: array[0..1] of string = (
    'set logging commands'#10'set #r 1',
    'set "logging" commands'#10'set #r 1');
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
    AssertTrue('set logging must be rejected by the driver', Raised);
  end;
end;

procedure TScriptDriverTest.TestExternalCommandRejected;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('send hello');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('send must be rejected by allowlist', Raised);
end;

procedure TScriptDriverTest.TestLuaBlockRejected;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('--lua'#10'print(1)'#10'--endlua');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('lua block must raise EScriptDriverError', Raised);
end;

procedure TScriptDriverTest.TestBlockCommentRejected;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('(* comment *)');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('block comment must raise EScriptDriverError', Raised);
end;

procedure TScriptDriverTest.TestGotoLoopHitsStepLimit;
var
  Raised: Boolean;
begin
  FSession.MaxSteps := 1000;
  Raised := False;
  try
    FSession.RunScript(':loop'#10'goto loop');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('goto loop must hit MaxSteps', Raised);
end;

procedure TScriptDriverTest.TestEndScriptStops;
begin
  FSession.RunScript('set #r 1'#10'end_script'#10'set #r 2');
  AssertEquals('end_script stops before next line', 1, FSession.NumVar('r'));
end;

procedure TScriptDriverTest.TestScalarSetRuns;
begin
  FSession.RunScript('set #r 1');
  AssertEquals(1, FSession.NumVar('r'));
end;

initialization
  RegisterTest(TScriptDriverTest);
end.
