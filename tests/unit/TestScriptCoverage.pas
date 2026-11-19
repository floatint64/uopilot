unit TestScriptCoverage;
{$mode objfpc}{$H+}

{ Guard-тесты матрицы покрытия: файл coverage.tsv не должен расходиться с
  живыми таблицами Unit1, allowlist-команды не должны оставаться без
  covered/skip, а ссылки на кейсы -- висеть в пустоте. }

interface

uses
  Classes, fpcunit, testregistry, uScriptCoverage;

type
  TScriptCoverageTest = class(TTestCase)
  private
    FRows: TScriptCoverageRows;
    procedure AssertKindCount(AKind: TScriptCoverageKind; AExpected: Integer);
    procedure AssertStatusAllowed(const AName: string;
      AStatus: TScriptCoverageStatus);
  protected
    procedure SetUp; override;
  published
    procedure TestMatrixMatchesLiveNames;
    procedure TestMatrixNamesAreUnique;
    procedure TestMatrixFieldValues;
    procedure TestCoveredHasCasesAndSkipHasNote;
    procedure TestCaseReferencesExist;
    procedure TestEveryLiveCaseIsReferenced;
    procedure TestAllowlistCommandsClassified;
    procedure TestPriorityOneAndTwoClassified;
  end;

implementation

uses
  SysUtils, Unit1, uScriptTestCases, uLegacyScriptSession;

type
  TCaseRef = record
    Name: string;
    Suite: string;
    IsSkip: Boolean;
  end;
  TCaseRefs = array of TCaseRef;

const
  CasesDirName = 'cases';

  { Приоритет 1: чистые eval-функции (математика, даты, строки, массивы). }
  PriorityOneNames: array[0..82] of string = (
    'abs', 'round', 'floor', 'ceil', 'frac', 'sqrt', 'power', 'exp', 'ln',
    'log', 'sin', 'cos', 'tan', 'arcsin', 'arccos', 'arctan', 'degtorad',
    'radtodeg', 'trunc', 'pi', 'minx', 'maxx', 'mean', 'mod',
    'point_distance', 'point_direction', 'lengthdir_x', 'lengthdir_y',
    'is_real', 'is_string', 'div',
    'size', 'posex', 'copy', 'delete', 'insert', 'hex2dec', 'dec2hex',
    'chartohex', 'chartohexf', 'chr', 'ord', 'string_replace', 'string_count',
    'string_lower', 'string_upper', 'string_letters', 'string_digits',
    'ltrim', 'rtrim', 'trim', 'regexp',
    'year', 'month', 'day', 'hour', 'min', 'sec', 'adddate', 'addyears',
    'addmonths', 'adddays', 'addhours', 'addminutes', 'addseconds', 'subdate',
    'subyears', 'submonths', 'subdays', 'subhours', 'subminutes',
    'subseconds', 'yearfromdate', 'monthfromdate', 'dayfromdate',
    'hourfromdate', 'minutefromdate', 'secondfromdate', 'timestamp',
    'datenow', 'timenow', 'dayofweek', 'indexof');

  { Приоритет 2: простые команды без UI. }
  PriorityTwoCommands: array[0..8] of string = (
    'set', 'get', 'wait', 'log', 'msg', 'hint', 'exit', 'sort_array',
    'delete_array');

function CoverageFileName: string;
begin
  Result := ExtractFilePath(ExpandFileName(ParamStr(0))) +
    CasesDirName + PathDelim + 'coverage.tsv';
end;

function CasesDir: string;
begin
  Result := ExtractFilePath(ExpandFileName(ParamStr(0))) +
    CasesDirName + PathDelim;
end;

function LoadAllCases: TCaseRefs;
var
  Files: TScriptCaseFileArray;
  Cases: TScriptTestCaseArray;
  I, J, N: Integer;
begin
  Result := nil;
  Files := ScriptCaseFiles;
  for I := 0 to Length(Files) - 1 do
  begin
    Cases := TScriptTestCaseSet.Load(CasesDir + Files[I].FileName);
    for J := 0 to Length(Cases) - 1 do
    begin
      N := Length(Result);
      SetLength(Result, N + 1);
      Result[N].Name := Cases[J].Name;
      Result[N].Suite := Files[I].SuiteName;
      Result[N].IsSkip := Cases[J].Kind = ckSkip;
    end;
  end;
end;

{ Ссылки разделяются запятыми, точками с запятой и пробелами. }
function SplitRefs(const S: string): TStringList;
var
  I: Integer;
  Cur: string;
begin
  Result := TStringList.Create;
  Cur := '';
  for I := 1 to Length(S) + 1 do
    if (I > Length(S)) or (S[I] in [',', ';', ' ', #9]) then
    begin
      if Cur <> '' then
      begin
        Result.Add(Cur);
        Cur := '';
      end;
    end
    else
      Cur := Cur + S[I];
end;

function SuiteExists(const Cases: TCaseRefs; const Suite: string): Boolean;
var
  I: Integer;
begin
  for I := 0 to Length(Cases) - 1 do
    if Cases[I].Suite = Suite then
      Exit(True);
  Result := False;
end;

function FindCase(const Cases: TCaseRefs; const Name: string;
  out IsSkip: Boolean): Boolean;
var
  I: Integer;
begin
  for I := 0 to Length(Cases) - 1 do
    if Cases[I].Name = Name then
    begin
      IsSkip := Cases[I].IsSkip;
      Exit(True);
    end;
  IsSkip := False;
  Result := False;
end;

{ Сколько не-skip кейсов реально стоит за ссылками строки. `code:` не
  сканирует реестр FPCUnit, поэтому считается непустой ссылкой. }
function ResolvedNonSkipCount(const Row: TScriptCoverageRow;
  const Cases: TCaseRefs): Integer;
var
  Refs: TStringList;
  I, J: Integer;
  Prefix, Value: string;
  IsSkip: Boolean;
begin
  Result := 0;
  Refs := SplitRefs(Row.Cases);
  try
    for I := 0 to Refs.Count - 1 do
    begin
      Prefix := Copy(Refs[I], 1, Pos(':', Refs[I]));
      Value := Copy(Refs[I], Pos(':', Refs[I]) + 1, Length(Refs[I]));
      if Prefix = 'code:' then
      begin
        if Value <> '' then
          Inc(Result);
      end
      else if Prefix = 'case:' then
      begin
        if FindCase(Cases, Value, IsSkip) and not IsSkip then
          Inc(Result);
      end
      else if Prefix = 'suite:' then
      begin
        for J := 0 to Length(Cases) - 1 do
          if (Cases[J].Suite = Value) and not Cases[J].IsSkip then
          begin
            Inc(Result);
            Break;
          end;
      end;
    end;
  finally
    Refs.Free;
  end;
end;

function LiveEvalNames(var EmptySlots: Integer): TStringList;
var
  I: Integer;
  S: string;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;
  EmptySlots := 0;
  for I := 0 to gCmdListah7.Count - 1 do
  begin
    S := AnsiLowerCase(gCmdListah7[I]);
    if S = '' then
      Inc(EmptySlots)
    else
      Result.Add(S);
  end;
end;

function LiveCommandNames: TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  Result.CaseSensitive := False;
  for I := 0 to gCmdList2jj.Count - 1 do
    if gCmdList2jj[I] <> '' then
      Result.Add(AnsiLowerCase(gCmdList2jj[I]));
end;

procedure TScriptCoverageTest.SetUp;
begin
  InitScriptCommandTables;
  FRows := LoadScriptCoverage(CoverageFileName);
end;

function CountKind(const Rows: TScriptCoverageRows;
  AKind: TScriptCoverageKind): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(Rows) - 1 do
    if Rows[I].Kind = AKind then
      Inc(Result);
end;

procedure TScriptCoverageTest.AssertKindCount(AKind: TScriptCoverageKind;
  AExpected: Integer);
begin
  AssertEquals('rows of kind ' + KindToText(AKind), AExpected,
    CountKind(FRows, AKind));
end;

procedure TScriptCoverageTest.AssertStatusAllowed(const AName: string;
  AStatus: TScriptCoverageStatus);
begin
  AssertTrue(AName + ' must be covered or skip, got ' + StatusToText(AStatus),
    AStatus in [scsCovered, scsSkip]);
end;

{ Пустые позиции gCmdNamesdd (23 штуки) остаются в матрице строками
  `#<index>` со статусом skip: так сохраняется порядок движка и ровно 289
  eval-строк, но живых имён по-прежнему 266. }
procedure TScriptCoverageTest.TestMatrixMatchesLiveNames;
var
  LiveEval, LiveCmd: TStringList;
  EmptySlots, I, Index, Placeholders: Integer;
  SlotIndex: Integer;
begin
  LiveEval := LiveEvalNames(EmptySlots);
  LiveCmd := LiveCommandNames;
  try
    AssertKindCount(sckEval, gCmdListah7.Count);
    AssertKindCount(sckCommand, LiveCmd.Count);

    for I := 0 to LiveEval.Count - 1 do
      AssertTrue('eval name missing in matrix: ' + LiveEval[I],
        FindCoverageRow(FRows, sckEval, LiveEval[I], Index));
    for I := 0 to LiveCmd.Count - 1 do
      AssertTrue('cmd name missing in matrix: ' + LiveCmd[I],
        FindCoverageRow(FRows, sckCommand, LiveCmd[I], Index));

    Placeholders := 0;
    for I := 0 to Length(FRows) - 1 do
      if (FRows[I].Kind = sckEval) and (Copy(FRows[I].Name, 1, 1) = '#') then
      begin
        Inc(Placeholders);
        SlotIndex := StrToIntDef(Copy(FRows[I].Name, 2, MaxInt), -1);
        AssertTrue('placeholder out of range: ' + FRows[I].Name,
          (SlotIndex >= 0) and (SlotIndex < gCmdListah7.Count));
        AssertEquals('placeholder must point to an empty slot: ' +
          FRows[I].Name, '', gCmdListah7[SlotIndex]);
      end;
    AssertEquals('empty slot placeholders', EmptySlots, Placeholders);
  finally
    LiveEval.Free;
    LiveCmd.Free;
  end;
end;

procedure TScriptCoverageTest.TestMatrixNamesAreUnique;
var
  Seen: TStringList;
  I: Integer;
  Key: string;
begin
  Seen := TStringList.Create;
  Seen.CaseSensitive := False;
  Seen.Sorted := True;
  try
    for I := 0 to Length(FRows) - 1 do
    begin
      Key := KindToText(FRows[I].Kind) + ':' + FRows[I].Name;
      AssertTrue('duplicate matrix row: ' + Key, Seen.IndexOf(Key) < 0);
      Seen.Add(Key);
    end;
  finally
    Seen.Free;
  end;
end;

procedure TScriptCoverageTest.TestMatrixFieldValues;
var
  I: Integer;
begin
  for I := 0 to Length(FRows) - 1 do
  begin
    AssertTrue('row name must not be empty', FRows[I].Name <> '');
    AssertTrue('kind text must round-trip',
      TextToKind(KindToText(FRows[I].Kind)) = FRows[I].Kind);
    AssertTrue('status text must round-trip',
      TextToStatus(StatusToText(FRows[I].Status)) = FRows[I].Status);
    AssertTrue('priority text must round-trip',
      TextToPriority(PriorityToText(FRows[I].Priority)) = FRows[I].Priority);
  end;
end;

procedure TScriptCoverageTest.TestCoveredHasCasesAndSkipHasNote;
var
  I: Integer;
begin
  for I := 0 to Length(FRows) - 1 do
  begin
    if FRows[I].Status = scsCovered then
      AssertTrue(FRows[I].Name + ' covered without cases',
        Trim(FRows[I].Cases) <> '');
    if FRows[I].Status in [scsSkip, scsMissing] then
      AssertTrue(FRows[I].Name + ' skipped without note',
        Trim(FRows[I].Note) <> '');
    if FRows[I].Status = scsMissing then
      AssertTrue(FRows[I].Name + ' missing must be P3',
        FRows[I].Priority = scpP3);
  end;
end;

procedure TScriptCoverageTest.TestCaseReferencesExist;
var
  Cases: TCaseRefs;
  Refs: TStringList;
  I, J: Integer;
  Prefix, Value: string;
  IsSkip: Boolean;
begin
  Cases := LoadAllCases;
  for I := 0 to Length(FRows) - 1 do
  begin
    Refs := SplitRefs(FRows[I].Cases);
    try
      for J := 0 to Refs.Count - 1 do
      begin
        Prefix := Copy(Refs[J], 1, Pos(':', Refs[J]));
        Value := Copy(Refs[J], Pos(':', Refs[J]) + 1, Length(Refs[J]));
        AssertTrue(FRows[I].Name + ': empty reference ' + Refs[J],
          Value <> '');
        if Prefix = 'case:' then
        begin
          AssertTrue(FRows[I].Name + ': unknown case ' + Value,
            FindCase(Cases, Value, IsSkip));
          AssertFalse(FRows[I].Name + ': case ' + Value + ' is skip',
            IsSkip);
        end
        else if Prefix = 'suite:' then
          AssertTrue(FRows[I].Name + ': unknown suite ' + Value,
            SuiteExists(Cases, Value))
        else if Prefix = 'code:' then
          { реестр FPCUnit не сканируем: проверяем только формат }
        else
          Fail(FRows[I].Name + ': unknown reference prefix in ' + Refs[J]);
      end;
    finally
      Refs.Free;
    end;
  end;
end;

procedure TScriptCoverageTest.TestEveryLiveCaseIsReferenced;
var
  Cases: TCaseRefs;
  Marked: array of Boolean;
  Refs: TStringList;
  I, J, K: Integer;
  Prefix, Value: string;
begin
  Cases := LoadAllCases;
  SetLength(Marked, Length(Cases));

  for I := 0 to Length(FRows) - 1 do
  begin
    Refs := SplitRefs(FRows[I].Cases);
    try
      for J := 0 to Refs.Count - 1 do
      begin
        Prefix := Copy(Refs[J], 1, Pos(':', Refs[J]));
        Value := Copy(Refs[J], Pos(':', Refs[J]) + 1, Length(Refs[J]));
        if Prefix = 'case:' then
          for K := 0 to Length(Cases) - 1 do
            if Cases[K].Name = Value then
              Marked[K] := True;
        if Prefix = 'suite:' then
          for K := 0 to Length(Cases) - 1 do
            if Cases[K].Suite = Value then
              Marked[K] := True;
      end;
    finally
      Refs.Free;
    end;
  end;

  for I := 0 to Length(Cases) - 1 do
    if not Cases[I].IsSkip then
      AssertTrue('case is not referenced by the matrix: ' +
        Cases[I].Suite + '/' + Cases[I].Name, Marked[I]);
end;

procedure TScriptCoverageTest.TestAllowlistCommandsClassified;
var
  Allowed: TAllowedCommandIds;
  Cases: TCaseRefs;
  I, Index: Integer;
  Name: string;
begin
  Cases := LoadAllCases;
  Allowed := TestAllowedCommands;
  for I := 0 to Length(Allowed) - 1 do
  begin
    Name := AnsiLowerCase(gCmdList2jj[Allowed[I]]);
    AssertTrue('allowlist command missing in matrix: ' + Name,
      FindCoverageRow(FRows, sckCommand, Name, Index));
    AssertStatusAllowed(Name, FRows[Index].Status);
    if FRows[Index].Status = scsCovered then
      AssertTrue(Name + ' covered without a non-skip case',
        ResolvedNonSkipCount(FRows[Index], Cases) > 0);
  end;
end;

procedure TScriptCoverageTest.TestPriorityOneAndTwoClassified;
var
  I, Index: Integer;
begin
  for I := 0 to High(PriorityOneNames) do
  begin
    AssertTrue('P1 eval name missing in matrix: ' + PriorityOneNames[I],
      FindCoverageRow(FRows, sckEval, PriorityOneNames[I], Index));
    AssertEquals('P1 priority for ' + PriorityOneNames[I], 'P1',
      PriorityToText(FRows[Index].Priority));
    AssertStatusAllowed(PriorityOneNames[I], FRows[Index].Status);
  end;

  for I := 0 to High(PriorityTwoCommands) do
  begin
    AssertTrue('P2 command missing in matrix: ' + PriorityTwoCommands[I],
      FindCoverageRow(FRows, sckCommand, PriorityTwoCommands[I], Index));
    AssertEquals('P2 priority for ' + PriorityTwoCommands[I], 'P2',
      PriorityToText(FRows[Index].Priority));
    AssertStatusAllowed(PriorityTwoCommands[I], FRows[Index].Status);
  end;
end;

initialization
  RegisterTest(TScriptCoverageTest);
end.
