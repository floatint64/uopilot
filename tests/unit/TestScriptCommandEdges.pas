unit TestScriptCommandEdges;
{$mode objfpc}{$H+}

{ Negative/edge-кейсы команд и выражений. Часть поведения -- просто
  characterization: если движок молча делает no-op, тест это фиксирует,
  а не подгоняет движок под желаемое. }

interface

uses
  fpcunit, testregistry, uScriptTestSession;

type
  TScriptCommandEdgesTest = class(TTestCase)
  private
    FSession: IScriptSession;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDivByZero;
    procedure TestModByZero;
    procedure TestSetWithoutValue;
    procedure TestGetNumberWithoutTargets;
    procedure TestGetWordNumericTarget;
    procedure TestTryArrCellAfterColumnDelete;
    procedure TestRunScriptClearsObservations;
  end;

implementation

uses
  SysUtils, uLegacyScriptSession, uScriptDriver;

procedure TScriptCommandEdgesTest.SetUp;
begin
  FSession := CreateSession(sbLegacy);
end;

procedure TScriptCommandEdgesTest.TearDown;
begin
  FSession := nil;
end;

procedure TScriptCommandEdgesTest.TestDivByZero;
var
  Raised: Boolean;
  Info: TScriptError;
begin
  Raised := False;
  try
    FSession.Eval('div(1 0)');
  except
    on E: Exception do
    begin
      Raised := True;
      AssertTrue('unexpected exception class: ' + E.ClassName,
        (E is EDivByZero) or (E is EZeroDivide));
    end;
  end;
  AssertTrue('div(1 0) must raise', Raised);
  Info := FSession.LastErrorInfo;
  AssertEquals('div by zero is not classified specially yet',
    Ord(sekOther), Ord(Info.Kind));
end;

procedure TScriptCommandEdgesTest.TestModByZero;
var
  Raised: Boolean;
  Info: TScriptError;
begin
  Raised := False;
  try
    FSession.Eval('mod(1 0)');
  except
    on E: Exception do
    begin
      Raised := True;
      AssertTrue('unexpected exception class: ' + E.ClassName,
        (E is EDivByZero) or (E is EZeroDivide));
    end;
  end;
  AssertTrue('mod(1 0) must raise', Raised);
  Info := FSession.LastErrorInfo;
  AssertEquals('mod by zero is not classified specially yet',
    Ord(sekOther), Ord(Info.Kind));
end;

{ `set #r` без довода создаёт переменную и обнуляет её: это не ошибка,
  а молчаливое поведение движка. }
procedure TScriptCommandEdgesTest.TestSetWithoutValue;
var
  Value: Int64;
begin
  FSession.RunScript('set #r');
  AssertTrue('set #r creates the variable', FSession.TryNumVar('r', Value));
  AssertEquals('created variable is zero', 0, Value);
  AssertEquals('no error', Ord(sekNone), Ord(FSession.LastErrorInfo.Kind));
end;

{ `get number` без целей движок считает ошибкой скрипта. }
procedure TScriptCommandEdgesTest.TestGetNumberWithoutTargets;
var
  Raised: Boolean;
begin
  Raised := False;
  try
    FSession.RunScript('get number');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('get number without targets must fail', Raised);
  AssertEquals('script error', Ord(sekScriptError),
    Ord(FSession.LastErrorInfo.Kind));
end;

{ `get word` с числовой целью (#) отклоняется: цель должна быть $. }
procedure TScriptCommandEdgesTest.TestGetWordNumericTarget;
var
  Raised: Boolean;
begin
  FSession.RunScript('set #w 0');
  Raised := False;
  try
    FSession.RunScript('get word #w 1 "a b"');
  except
    on E: EScriptDriverError do
      Raised := True;
  end;
  AssertTrue('get word with # target must fail', Raised);
  AssertEquals('script error', Ord(sekScriptError),
    Ord(FSession.LastErrorInfo.Kind));
end;

procedure TScriptCommandEdgesTest.TestTryArrCellAfterColumnDelete;
var
  Value: string;
begin
  FSession.RunScript('set %a 1|2/3|4'#10'delete_array %a 2 1');
  AssertFalse('deleted column is gone',
    FSession.TryArrCell('a', 1, 2, Value));
  AssertTrue('remaining column is readable',
    FSession.TryArrCell('a', 1, 1, Value));
  AssertEquals('1', Value);
end;

procedure TScriptCommandEdgesTest.TestRunScriptClearsObservations;
begin
  FSession.RunScript('msg one'#10'hint h1');
  FSession.RunScript('set #r 1');
  AssertEquals('messages reset', '', FSession.MessageText);
  AssertEquals('hint reset', '', FSession.HintText);
  AssertFalse('exit flag reset', FSession.ExitRequested);
  AssertTrue('host calls reset: ' + FSession.HostCallText,
    Pos('msg', FSession.HostCallText) = 0);
end;

initialization
  RegisterTest(TScriptCommandEdgesTest);
end.
