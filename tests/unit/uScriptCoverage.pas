unit uScriptCoverage;
{$mode objfpc}{$H+}

{ Матрица покрытия скриптового движка. Файл `coverage.tsv` -- checked-in
  артефакт: генератор строит строки из живых таблиц Unit1 и сохраняет уже
  заполненные status/priority/cases/note. Guard-тест в TestScriptCoverage
  сравнивает файл с движком. }

interface

uses
  Classes, SysUtils;

type
  EScriptCoverageError = class(Exception);

  TScriptCoverageKind = (sckEval, sckCommand);
  TScriptCoverageStatus = (scsCovered, scsSkip, scsMissing);
  TScriptCoveragePriority = (scpP1, scpP2, scpP3);

  TScriptCoverageRow = record
    Name: string;
    Kind: TScriptCoverageKind;
    Status: TScriptCoverageStatus;
    Priority: TScriptCoveragePriority;
    Cases: string;
    Note: string;
  end;
  TScriptCoverageRows = array of TScriptCoverageRow;

function KindToText(Kind: TScriptCoverageKind): string;
function StatusToText(Status: TScriptCoverageStatus): string;
function PriorityToText(Priority: TScriptCoveragePriority): string;

function TextToKind(const S: string): TScriptCoverageKind;
function TextToStatus(const S: string): TScriptCoverageStatus;
function TextToPriority(const S: string): TScriptCoveragePriority;

{ Читает UTF-8 TSV: name, kind, status, priority, cases, note.
  Строки `//`, пустые и заголовок пропускаются. }
function LoadScriptCoverage(const FileName: string): TScriptCoverageRows;

{ Пишет UTF-8 TSV без BOM, с заголовком. }
procedure SaveScriptCoverage(const FileName: string;
  const Rows: TScriptCoverageRows);

{ Строит матрицу из gCmdListah7/gCmdList2jj (имена в нижнем регистре).
  Пустые позиции gCmdNamesdd в матрицу не попадают: это не имена.
  Поля существующих строк сохраняются по (kind, name), новые -- missing/P3. }
function BuildScriptCoverage(
  const Existing: TScriptCoverageRows): TScriptCoverageRows;

function FindCoverageRow(const Rows: TScriptCoverageRows;
  Kind: TScriptCoverageKind; const Name: string;
  out Index: Integer): Boolean;

implementation

uses
  Unit1;

const
  ColumnCount = 6;

function KindToText(Kind: TScriptCoverageKind): string;
begin
  case Kind of
    sckEval: Result := 'eval';
    sckCommand: Result := 'cmd';
  else
    Result := '';
  end;
end;

function StatusToText(Status: TScriptCoverageStatus): string;
begin
  case Status of
    scsCovered: Result := 'covered';
    scsSkip: Result := 'skip';
    scsMissing: Result := 'missing';
  else
    Result := '';
  end;
end;

function PriorityToText(Priority: TScriptCoveragePriority): string;
begin
  case Priority of
    scpP1: Result := 'P1';
    scpP2: Result := 'P2';
    scpP3: Result := 'P3';
  else
    Result := '';
  end;
end;

function TextToKind(const S: string): TScriptCoverageKind;
begin
  if S = 'eval' then
    Result := sckEval
  else if (S = 'cmd') or (S = 'command') then
    Result := sckCommand
  else
    raise EScriptCoverageError.Create('unknown kind "' + S + '"');
end;

function TextToStatus(const S: string): TScriptCoverageStatus;
begin
  if S = 'covered' then
    Result := scsCovered
  else if S = 'skip' then
    Result := scsSkip
  else if S = 'missing' then
    Result := scsMissing
  else
    raise EScriptCoverageError.Create('unknown status "' + S + '"');
end;

function TextToPriority(const S: string): TScriptCoveragePriority;
begin
  if S = 'P1' then
    Result := scpP1
  else if S = 'P2' then
    Result := scpP2
  else if S = 'P3' then
    Result := scpP3
  else
    raise EScriptCoverageError.Create('unknown priority "' + S + '"');
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

function LoadScriptCoverage(const FileName: string): TScriptCoverageRows;
var
  Lines: TStringList;
  Fields: array[0..ColumnCount - 1] of string;
  Rec: TScriptCoverageRow;
  I, N: Integer;
  Line: string;
begin
  Result := nil;
  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(FileName);
    except
      on E: Exception do
        raise EScriptCoverageError.CreateFmt('%s: %s', [FileName, E.Message]);
    end;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      if (I = 0) and (Length(Line) >= 3) and
         (Line[1] = #$EF) and (Line[2] = #$BB) and (Line[3] = #$BF) then
        Delete(Line, 1, 3);

      if (Line = '') or (Copy(Line, 1, 2) = '//') then
        Continue;
      if (I = 0) and (Copy(Line, 1, 5) = 'name'#9) then
        Continue;

      try
        if SplitTsv(Line, Fields) <> ColumnCount then
          raise EScriptCoverageError.CreateFmt(
            '%s:%d: expected %d TSV columns', [FileName, I + 1, ColumnCount]);

        Rec.Name := AnsiLowerCase(Trim(Fields[0]));
        Rec.Kind := TextToKind(AnsiLowerCase(Trim(Fields[1])));
        Rec.Status := TextToStatus(AnsiLowerCase(Trim(Fields[2])));
        Rec.Priority := TextToPriority(Trim(Fields[3]));
        Rec.Cases := Fields[4];
        Rec.Note := Fields[5];

        if Rec.Name = '' then
          raise EScriptCoverageError.CreateFmt(
            '%s:%d: empty name', [FileName, I + 1]);
      except
        on E: EScriptCoverageError do
          raise;
        on E: Exception do
          raise EScriptCoverageError.CreateFmt('%s:%d: %s',
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

function CleanField(const S: string): string;
begin
  Result := StringReplace(S, #9, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
end;

procedure SaveScriptCoverage(const FileName: string;
  const Rows: TScriptCoverageRows);
var
  Stream: TFileStream;
  I: Integer;
  Line: string;
  procedure WriteLine(const S: string);
  begin
    Stream.WriteBuffer(PAnsiChar(S)^, Length(S));
  end;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    WriteLine('name'#9'kind'#9'status'#9'priority'#9'cases'#9'note'#10);
    for I := 0 to Length(Rows) - 1 do
    begin
      Line := Rows[I].Name + #9 + KindToText(Rows[I].Kind) + #9 +
        StatusToText(Rows[I].Status) + #9 +
        PriorityToText(Rows[I].Priority) + #9 +
        CleanField(Rows[I].Cases) + #9 + CleanField(Rows[I].Note) + #10;
      WriteLine(Line);
    end;
  finally
    Stream.Free;
  end;
end;

function FindCoverageRow(const Rows: TScriptCoverageRows;
  Kind: TScriptCoverageKind; const Name: string; out Index: Integer): Boolean;
var
  I: Integer;
  Lower: string;
begin
  Lower := AnsiLowerCase(Name);
  for I := 0 to Length(Rows) - 1 do
    if (Rows[I].Kind = Kind) and (Rows[I].Name = Lower) then
    begin
      Index := I;
      Exit(True);
    end;
  Index := -1;
  Result := False;
end;

function BuildScriptCoverage(
  const Existing: TScriptCoverageRows): TScriptCoverageRows;
var
  Rec: TScriptCoverageRow;
  I, N, Index: Integer;
  Name: string;

  procedure AddRow(const AName: string; AKind: TScriptCoverageKind;
    AEmptySlot: Boolean);
  begin
    Name := AnsiLowerCase(AName);
    if Name = '' then
      Exit;
    if FindCoverageRow(Result, AKind, Name, Index) then
      Exit;
    if FindCoverageRow(Existing, AKind, Name, Index) then
      Rec := Existing[Index]
    else if AEmptySlot then
    begin
      Rec.Name := Name;
      Rec.Kind := AKind;
      Rec.Status := scsSkip;
      Rec.Priority := scpP3;
      Rec.Cases := '';
      Rec.Note := 'empty slot in gCmdNamesdd';
    end
    else
    begin
      Rec.Name := Name;
      Rec.Kind := AKind;
      Rec.Status := scsMissing;
      Rec.Priority := scpP3;
      Rec.Cases := '';
      Rec.Note := 'not characterized yet';
    end;
    N := Length(Result);
    SetLength(Result, N + 1);
    Result[N] := Rec;
  end;

  procedure AddEvalIndex(AIndex: Integer);
  var
    SlotName: string;
  begin
    SlotName := AnsiLowerCase(gCmdListah7[AIndex]);
    if SlotName = '' then
      SlotName := '#' + IntToStr(AIndex);
    AddRow(SlotName, sckEval, SlotName[1] = '#');
  end;

begin
  Result := nil;
  for I := 0 to gCmdListah7.Count - 1 do
    AddEvalIndex(I);
  for I := 0 to gCmdList2jj.Count - 1 do
    AddRow(gCmdList2jj[I], sckCommand, False);
end;

end.
