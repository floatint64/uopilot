unit uScriptTestCases;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { Ошибка формата файла кейсов: содержит имя файла и номер строки. }
  EScriptTestCaseError = class(Exception);

  TScriptTestCaseKind = (ckEval, ckScript, ckSkip);

  TScriptTestCase = record
    Name: string;
    Kind: TScriptTestCaseKind;
    Target: string;    // '', '#r', '$r', '%r[1][1]'
    Script: string;
    Expected: string;
    Note: string;
  end;
  TScriptTestCaseArray = array of TScriptTestCase;

  TScriptCaseFile = record
    SuiteName: string;
    FileName: string;
  end;
  TScriptCaseFileArray = array of TScriptCaseFile;

  { Читает UTF-8 TSV: name, kind, target, script, expected, note.
    Строки `//` и пустые пропускаются, BOM снимается. }
  TScriptTestCaseSet = class
  public
    class function Load(const FileName: string): TScriptTestCaseArray;
  end;

{ Единый список case-файлов: его используют и регистрация тестов, и guard
  матрицы покрытия, чтобы ссылки не разъезжались с набором. }
function ScriptCaseFiles: TScriptCaseFileArray;

implementation

const
  ColumnCount = 6;

function ScriptCaseFiles: TScriptCaseFileArray;

  procedure Add(const SuiteName, FileName: string);
  var
    N: Integer;
  begin
    N := Length(Result);
    SetLength(Result, N + 1);
    Result[N].SuiteName := SuiteName;
    Result[N].FileName := FileName;
  end;

begin
  Result := nil;
  Add('ScriptsExprStrings', 'expr_strings.tsv');
  Add('ScriptsExprRegexp', 'expr_regexp.tsv');
  Add('ScriptsExprCompare', 'expr_compare.tsv');
  Add('ScriptsCmdSet', 'cmd_set.tsv');
  Add('ScriptsCmdGet', 'cmd_get.tsv');
  Add('ScriptsArray', 'arrays.tsv');
  Add('ScriptsFlow', 'flow.tsv');
  Add('ScriptsExprMath', 'expr_math.tsv');
  Add('ScriptsExprDates', 'expr_dates.tsv');
  Add('ScriptsExprClock', 'expr_clock.tsv');
  Add('ScriptsExprConstants', 'expr_constants.tsv');
  Add('ScriptsKnownBugs', 'known_bugs.tsv');
end;

function SplitTsv(const S: string; var Fields: array of string): Integer;
var
  I, N, StartPos: Integer;
begin
  N := 0;
  StartPos := 1;
  for I := 1 to Length(S) do
    if S[I] = #9 then
    begin
      if N <= High(Fields) then
        Fields[N] := Copy(S, StartPos, I - StartPos);
      Inc(N);
      StartPos := I + 1;
    end;
  if N <= High(Fields) then
    Fields[N] := Copy(S, StartPos, Length(S) - StartPos + 1);
  Result := N + 1;
end;

{ Экранирование минимальное: \n, \r, \t, \\; прочие \x сохраняются
  как есть, иначе regexp-паттерны (`\d`, `\w`) сломались бы. }
function Unescape(const S: string): string;
var
  I: Integer;
begin
  Result := '';
  I := 1;
  while I <= Length(S) do
  begin
    if (S[I] = '\') and (I < Length(S)) then
      case S[I + 1] of
        'n':
          begin
            Result := Result + #10;
            Inc(I, 2);
          end;
        'r':
          begin
            Result := Result + #13;
            Inc(I, 2);
          end;
        't':
          begin
            Result := Result + #9;
            Inc(I, 2);
          end;
        '\':
          begin
            Result := Result + '\';
            Inc(I, 2);
          end;
      else
        begin
          Result := Result + S[I];
          Inc(I);
        end;
      end
    else
    begin
      Result := Result + S[I];
      Inc(I);
    end;
  end;
end;

function ParseKind(const S: string): TScriptTestCaseKind;
begin
  if S = 'eval' then
    Result := ckEval
  else if S = 'script' then
    Result := ckScript
  else if S = 'skip' then
    Result := ckSkip
  else
    raise EScriptTestCaseError.Create('unknown kind "' + S + '"');
end;

class function TScriptTestCaseSet.Load(
  const FileName: string): TScriptTestCaseArray;
var
  Lines: TStringList;
  Fields: array[0..ColumnCount - 1] of string;
  Rec: TScriptTestCase;
  I, J, N: Integer;
  Line: string;
begin
  Result := nil;
  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(FileName);
    except
      on E: Exception do
        raise EScriptTestCaseError.CreateFmt('%s: %s', [FileName, E.Message]);
    end;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      if (I = 0) and (Length(Line) >= 3) and
         (Line[1] = #$EF) and (Line[2] = #$BB) and (Line[3] = #$BF) then
        Delete(Line, 1, 3);

      if (Line = '') or (Copy(Line, 1, 2) = '//') then
        Continue;
      { Необязательная строка заголовка: name<TAB>kind<TAB>... }
      if (I = 0) and (Copy(Line, 1, 5) = 'name'#9) then
        Continue;

      try
        if SplitTsv(Line, Fields) <> ColumnCount then
          raise EScriptTestCaseError.CreateFmt(
            '%s:%d: expected %d TSV columns', [FileName, I + 1, ColumnCount]);

        Rec.Name := Trim(Fields[0]);
        Rec.Kind := ParseKind(Trim(Fields[1]));
        Rec.Target := Trim(Fields[2]);
        Rec.Script := Unescape(Fields[3]);
        Rec.Expected := Unescape(Fields[4]);
        Rec.Note := Fields[5];

        if Rec.Name = '' then
          raise EScriptTestCaseError.CreateFmt(
            '%s:%d: empty name', [FileName, I + 1]);

        for J := 0 to Length(Result) - 1 do
          if Result[J].Name = Rec.Name then
            raise EScriptTestCaseError.CreateFmt(
              '%s:%d: duplicate name "%s"', [FileName, I + 1, Rec.Name]);

        if (Rec.Kind in [ckEval, ckScript]) and (Rec.Script = '') then
          raise EScriptTestCaseError.CreateFmt(
            '%s:%d: empty script', [FileName, I + 1]);

        if (Rec.Kind = ckScript) and (Rec.Target = '') then
          raise EScriptTestCaseError.CreateFmt(
            '%s:%d: empty target for script case', [FileName, I + 1]);

        if (Rec.Kind = ckEval) and (Rec.Target <> '') then
          raise EScriptTestCaseError.CreateFmt(
            '%s:%d: target must be empty for eval case', [FileName, I + 1]);

        if (Rec.Kind = ckSkip) and (Rec.Note = '') then
          raise EScriptTestCaseError.CreateFmt(
            '%s:%d: empty note for skip case', [FileName, I + 1]);
      except
        on E: EScriptTestCaseError do
          raise;
        on E: Exception do
          raise EScriptTestCaseError.CreateFmt('%s:%d: %s',
            [FileName, I + 1, E.Message]);
      end;

      N := Length(Result);
      SetLength(Result, N + 1);
      Result[N] := Rec;
    end;
  finally
    Lines.Free;
  end;
end;

end.
