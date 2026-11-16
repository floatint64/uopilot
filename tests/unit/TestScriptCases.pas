unit TestScriptCases;
{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, uScriptTestSession, uScriptTestCases;

type
  TScriptCaseTest = class(TTestCase)
  private
    FCase: TScriptTestCase;
    FSession: IScriptSession;
    function ReadTarget(const Target: string): string;
    function ReadArrayCell(const Target: string): string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure RunTest; override;
  public
    constructor CreateWithCase(const C: TScriptTestCase;
      const ASuiteName: string);
  end;

implementation

uses
  SysUtils, Classes;

constructor TScriptCaseTest.CreateWithCase(const C: TScriptTestCase;
  const ASuiteName: string);
begin
  inherited CreateWith(C.Name, ASuiteName);
  FCase := C;
end;

procedure TScriptCaseTest.SetUp;
begin
  FSession := CreateSession(sbLegacy);
end;

procedure TScriptCaseTest.TearDown;
begin
  FSession := nil;
end;

function TScriptCaseTest.ReadArrayCell(const Target: string): string;
var
  Rest, Name: string;
  P1, P2, Row, Col: Integer;
begin
  Result := '';
  Name := Copy(Target, 2, Length(Target) - 1);
  Row := 1;
  Col := 1;

  P1 := Pos('[', Name);
  if P1 > 0 then
  begin
    Rest := Copy(Name, P1, Length(Name) - P1 + 1);
    Name := Copy(Name, 1, P1 - 1);

    P1 := Pos('[', Rest);
    P2 := Pos(']', Rest);
    if (P1 > 0) and (P2 > P1) then
    begin
      Row := StrToIntDef(Copy(Rest, P1 + 1, P2 - P1 - 1), 1);
      Rest := Copy(Rest, P2 + 1, Length(Rest) - P2);
      P1 := Pos('[', Rest);
      P2 := Pos(']', Rest);
      if (P1 > 0) and (P2 > P1) then
        Col := StrToIntDef(Copy(Rest, P1 + 1, P2 - P1 - 1), 1);
    end;
  end;

  Result := FSession.ArrCell(ToScript(Name), Row, Col);
end;

function TScriptCaseTest.ReadTarget(const Target: string): string;
begin
  Result := '';
  if Target = '' then
    Exit;
  case Target[1] of
    '#':
      Result := IntToStr(FSession.NumVar(ToScript(Copy(Target, 2, Length(Target) - 1))));
    '$':
      Result := FSession.StrVar(ToScript(Copy(Target, 2, Length(Target) - 1)));
    '%':
      Result := ReadArrayCell(Target);
  end;
end;

procedure TScriptCaseTest.RunTest;
var
  Actual, Expected: string;
  ExpNum, ActNum: Int64;
begin
  case FCase.Kind of
    ckSkip:
      Ignore(FCase.Note);
    ckEval:
      Actual := FSession.Eval(ToScript(FCase.Script));
    ckScript:
      begin
        FSession.RunScript(ToScript(FCase.Script));
        Actual := ReadTarget(FCase.Target);
      end;
  else
    Actual := '';
  end;

  Expected := ToScript(FCase.Expected);

  if (FCase.Kind = ckScript) and (FCase.Target <> '') and
     (FCase.Target[1] = '#') and
     TryStrToInt64(FCase.Expected, ExpNum) and
     TryStrToInt64(Actual, ActNum) then
    AssertEquals(FCase.Name, ExpNum, ActNum)
  else
    AssertEquals(FCase.Name, Expected, Actual);
end;

const
  CasesDirName = 'cases';

procedure RegisterCaseFile(const SuiteName, FileName: string);
var
  Cases: TScriptTestCaseArray;
  I: Integer;
begin
  if not FileExists(FileName) then
    raise EFOpenError.CreateFmt('case file not found: %s', [FileName]);
  Cases := TScriptTestCaseSet.Load(FileName);
  for I := 0 to Length(Cases) - 1 do
    RegisterTest(SuiteName, TScriptCaseTest.CreateWithCase(Cases[I], SuiteName));
end;

procedure RegisterAllCases;
var
  Dir: string;
begin
  Dir := ExtractFilePath(ExpandFileName(ParamStr(0))) + CasesDirName + PathDelim;
  RegisterCaseFile('ScriptsExprStrings', Dir + 'expr_strings.tsv');
  RegisterCaseFile('ScriptsExprRegexp', Dir + 'expr_regexp.tsv');
  RegisterCaseFile('ScriptsExprCompare', Dir + 'expr_compare.tsv');
  RegisterCaseFile('ScriptsCmdSet', Dir + 'cmd_set.tsv');
  RegisterCaseFile('ScriptsCmdGet', Dir + 'cmd_get.tsv');
  RegisterCaseFile('ScriptsArray', Dir + 'arrays.tsv');
  RegisterCaseFile('ScriptsFlow', Dir + 'flow.tsv');
end;

initialization
  RegisterAllCases;
end.
