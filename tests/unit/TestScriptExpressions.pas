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
    procedure TestFileExistsTempFile;
    procedure TestFileExistsMissing;
    procedure TestFileGetAttrReadOnly;
    procedure TestFileGetAttrMissing;
    procedure TestFileGetDateTempFile;
    procedure TestFileGetDateMissing;
  end;

implementation

uses
  SysUtils, Windows, Unit1;

{ Временный файл в системной temp-директории: GetTempFileName создаёт его
  сразу, поэтому путь заведомо существует. }
function NewTempFile: string;
var
  Dir, Name: array[0..MAX_PATH - 1] of Char;
begin
  if GetTempPath(MAX_PATH, Dir) = 0 then
    raise Exception.Create('GetTempPath failed');
  if GetTempFileName(Dir, 'uop', 0, Name) = 0 then
    raise Exception.Create('GetTempFileName failed');
  Result := Name;
end;

function NewMissingPath: string;
begin
  Result := NewTempFile;
  if not SysUtils.DeleteFile(Result) then
    raise Exception.Create('cannot remove temp file');
end;

function QuotedPath(const Path: string): string;
begin
  Result := '"' + Path + '"';
end;

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

procedure TScriptExprTest.TestFileExistsTempFile;
var
  Path: string;
begin
  Path := NewTempFile;
  try
    AssertEquals('fileexists existing file', '1',
      FSession.Eval('fileexists(' + QuotedPath(Path) + ')'));
  finally
    SysUtils.DeleteFile(Path);
  end;
end;

procedure TScriptExprTest.TestFileExistsMissing;
var
  Path: string;
begin
  Path := NewMissingPath;
  AssertEquals('fileexists missing file', '0',
    FSession.Eval('fileexists(' + QuotedPath(Path) + ')'));
end;

procedure TScriptExprTest.TestFileGetAttrReadOnly;
var
  Path: string;
begin
  Path := NewTempFile;
  try
    FileSetAttr(Path, faReadOnly);
    AssertEquals('filegetattr read-only', 'R',
      FSession.Eval('filegetattr(' + QuotedPath(Path) + ')'));
  finally
    FileSetAttr(Path, faArchive);
    SysUtils.DeleteFile(Path);
  end;
end;

procedure TScriptExprTest.TestFileGetAttrMissing;
var
  Path: string;
begin
  Path := NewMissingPath;
  AssertEquals('filegetattr missing file', '',
    FSession.Eval('filegetattr(' + QuotedPath(Path) + ')'));
end;

procedure TScriptExprTest.TestFileGetDateTempFile;
var
  Path, Expected: string;
  Stamp: TDateTime;
begin
  Path := NewTempFile;
  try
    Stamp := EncodeDate(2024, 1, 2) + EncodeTime(3, 4, 6, 0);
    FileSetDate(Path, DateTimeToFileDate(Stamp));
    Expected := DateTimeToStr(FileDateToDateTime(FileAge(Path)));
    AssertEquals('filegetdate existing file', Expected,
      FSession.Eval('filegetdate(' + QuotedPath(Path) + ')'));
  finally
    SysUtils.DeleteFile(Path);
  end;
end;

procedure TScriptExprTest.TestFileGetDateMissing;
var
  Path: string;
begin
  Path := NewMissingPath;
  AssertEquals('filegetdate missing file', '',
    FSession.Eval('filegetdate(' + QuotedPath(Path) + ')'));
end;

initialization
  RegisterTest(TScriptExprTest);
end.
