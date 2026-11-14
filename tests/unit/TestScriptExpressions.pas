unit TestScriptExpressions;
{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, uScriptTestSession;

type
  TScriptExprTest = class(TTestCase)
  private
    FSession: IScriptSession;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSizeCyrillic;
    procedure TestSizeMixed;
    procedure TestCopyCyrillic;
    procedure TestOrdChr;
    procedure TestCommandTablesInitialized;
    procedure TestKnownBugSizeEmpty;
  end;

implementation

uses
  SysUtils, Unit1;

procedure TScriptExprTest.SetUp;
begin
  FSession := CreateSession(sbLegacy);
end;

procedure TScriptExprTest.TearDown;
begin
  FSession := nil;
end;

procedure TScriptExprTest.TestSizeCyrillic;
begin
  AssertEquals('size("абв")', '3', FSession.Eval(ToScript('size("абв")')));
end;

procedure TScriptExprTest.TestSizeMixed;
begin
  AssertEquals('size("а1б2")', '4', FSession.Eval(ToScript('size("а1б2")')));
end;

procedure TScriptExprTest.TestCopyCyrillic;
begin
  AssertEquals('copy("матрёшка" 4 3)', ToScript('рёш'),
    FSession.Eval(ToScript('copy("матрёшка" 4 3)')));
end;

procedure TScriptExprTest.TestOrdChr;
begin
  AssertEquals('ord("а")', '224', FSession.Eval(ToScript('ord("а")')));
  AssertEquals('chr(224)', ToScript('а'), FSession.Eval('chr(224)'));
end;

{ Белый characterization-тест legacy-таблиц: к общему контракту движка он не
  относится и при появлении sbRuntime переедет в отдельный legacy-набор. }
procedure TScriptExprTest.TestCommandTablesInitialized;
begin
  AssertEquals('eval names count', 289, gCmdListah7.Count);
  AssertEquals('command names count', 136, gCmdList2jj.Count);
  AssertEquals('size index', 76, gCmdListah7.IndexOf('size'));
  AssertEquals('set index', 40, gCmdList2jj.IndexOf('set'));
end;

{ size("") -- не исключение, а доступ за границу строки (BUGS.md), поэтому
  движок здесь не вызывается: тест документирует баг и ждёт исправления. }
procedure TScriptExprTest.TestKnownBugSizeEmpty;
begin
  raise EIgnoredTest.Create('BUGS.md: size("") -> V[0] access violation');
end;

initialization
  RegisterTest(TScriptExprTest);
end.
