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
    FBackend: TScriptBackend;
    function ReadTarget(const Target: string): string;
    function ReadArrayCell(const Target: string): string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure RunTest; override;
  public
    constructor CreateWithCase(const C: TScriptTestCase;
      const ASuiteName: string; ABackend: TScriptBackend = sbLegacy);
  end;

implementation

uses
  SysUtils, Classes;

constructor TScriptCaseTest.CreateWithCase(const C: TScriptTestCase;
  const ASuiteName: string; ABackend: TScriptBackend);
begin
  inherited CreateWith(C.Name, ASuiteName);
  FCase := C;
  FBackend := ABackend;
end;

procedure TScriptCaseTest.SetUp;
begin
  FSession := CreateSession(FBackend);
end;

procedure TScriptCaseTest.TearDown;
begin
  FSession := nil;
end;

function TScriptCaseTest.ReadArrayCell(const Target: string): string;
var
  Rest, Name: string;
  P1, P2, Row, Col: Integer;
  Value: string;
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

  if not FSession.TryArrCell(ToScript(Name), Row, Col, Value) then
    raise EAssertionFailed.CreateFmt('array target %s does not exist', [Target]);
  Result := Value;
end;

function TScriptCaseTest.ReadTarget(const Target: string): string;
var
  Value: string;
  Num: Int64;
begin
  Result := '';
  if Target = '' then
    Exit;
  case Target[1] of
    '#':
      begin
        if not FSession.TryNumVar(ToScript(Copy(Target, 2, Length(Target) - 1)),
          Num) then
          raise EAssertionFailed.CreateFmt('numeric target %s does not exist',
            [Target]);
        Result := IntToStr(Num);
      end;
    '$':
      begin
        if not FSession.TryStrVar(ToScript(Copy(Target, 2, Length(Target) - 1)),
          Value) then
          raise EAssertionFailed.CreateFmt('string target %s does not exist',
            [Target]);
        Result := Value;
      end;
    '%':
      Result := ReadArrayCell(Target);
  end;
end;

procedure TScriptCaseTest.RunTest;
var
  Actual, Expected: string;
  ExpNum, ActNum: Int64;
begin
  { Runtime-бэкенд ещё не перенесён: кейс остаётся видимым в --list, но
    помечается Ignored с причиной, а не притворяется зелёным. }
  if (FBackend = sbRuntime) and not CoreSupports(FCase.Name) then
  begin
    Ignore('runtime backend is not migrated yet');
    Exit;
  end;

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
  begin
    RegisterTest(SuiteName,
      TScriptCaseTest.CreateWithCase(Cases[I], SuiteName, sbLegacy));
    { Параллельный runtime-набор: пока все кейсы Ignored через CoreSupports,
      но набор уже виден в --list. }
    RegisterTest(SuiteName + 'Runtime',
      TScriptCaseTest.CreateWithCase(Cases[I], SuiteName + 'Runtime',
        sbRuntime));
  end;
end;

procedure RegisterAllCases;
var
  Dir: string;
  Files: TScriptCaseFileArray;
  I: Integer;
begin
  Dir := ExtractFilePath(ExpandFileName(ParamStr(0))) + CasesDirName + PathDelim;
  Files := ScriptCaseFiles;
  for I := 0 to Length(Files) - 1 do
    RegisterCaseFile(Files[I].SuiteName, Dir + Files[I].FileName);
end;

initialization
  RegisterAllCases;
end.
