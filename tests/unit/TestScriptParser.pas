unit TestScriptParser;
{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, uScanThread, uScriptParser;

type
  TScriptParserTest = class(TTestCase)
  private
    FT: TScanThread;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestStripCommentTrailing;
    procedure TestStripCommentQuotedUrl;
    procedure TestStripCommentInsideQuotes;
    procedure TestStripCommentWholeLine;
    procedure TestStripCommentNoComment;
    procedure TestTrimRightScriptLine;
    procedure TestInsertSpaceBeforeParen;
    procedure TestCutCommandAtColon;
    procedure TestEvalScriptPointWords;
    procedure TestCreateForTestDefaultProfile;
    procedure TestCreateForTestCustomProfile;
  end;

implementation

uses
  SysUtils, Unit1, uScriptSettings;

procedure TScriptParserTest.SetUp;
begin
  InitScriptCommandTables;
  FT := TScanThread.CreateForTest;
end;

procedure TScriptParserTest.TearDown;
begin
  FreeAndNil(FT);
end;

procedure TScriptParserTest.TestStripCommentTrailing;
begin
  AssertEquals('set $a 1 ',
    uScriptParser.StripScriptComment('set $a 1 // comment'));
end;

procedure TScriptParserTest.TestStripCommentQuotedUrl;
begin
  AssertEquals('set $a "http://x" ',
    uScriptParser.StripScriptComment('set $a "http://x" // c'));
end;

procedure TScriptParserTest.TestStripCommentInsideQuotes;
begin
  AssertEquals('set $a "a // b"',
    uScriptParser.StripScriptComment('set $a "a // b"'));
end;

procedure TScriptParserTest.TestStripCommentWholeLine;
begin
  AssertEquals('', uScriptParser.StripScriptComment('// whole line'));
end;

procedure TScriptParserTest.TestStripCommentNoComment;
begin
  AssertEquals('set $a 1', uScriptParser.StripScriptComment('set $a 1'));
end;

procedure TScriptParserTest.TestTrimRightScriptLine;
begin
  AssertEquals('set $a 1', uScriptParser.TrimRightScriptLine('set $a 1 '#9' '));
  AssertEquals('', uScriptParser.TrimRightScriptLine(' '#9' '));
end;

procedure TScriptParserTest.TestInsertSpaceBeforeParen;
begin
  AssertEquals('if (1)', uScriptParser.InsertSpaceBeforeParen('if(1)', 3));
  AssertEquals('if(1)', uScriptParser.InsertSpaceBeforeParen('if(1)', 0));
  AssertEquals('if(1) ', uScriptParser.InsertSpaceBeforeParen('if(1)', 6));
  AssertEquals('if(1)', uScriptParser.InsertSpaceBeforeParen('if(1)', 7));
end;

procedure TScriptParserTest.TestCutCommandAtColon;
begin
  AssertEquals('foo', uScriptParser.CutCommandAtColon('foo:bar'));
  AssertEquals(':bar', uScriptParser.CutCommandAtColon(':bar'));
  AssertEquals('foo', uScriptParser.CutCommandAtColon('foo'));
end;

{ Слово 0 -- первое слово в нижнем регистре, слово 1 -- второе как есть.
  WordPos у найденного слова -- 1 для первого и 7 для второго. }
procedure TScriptParserTest.TestEvalScriptPointWords;
var
  S: string;
begin
  S := 'Alpha beta gamma';
  AssertEquals('alpha', EvalScriptPoint(FT, S, 0));
  AssertEquals('WordPos(0)', 1, FT.WordPos);
  AssertEquals('beta', EvalScriptPoint(FT, S, 1));
  AssertEquals('WordPos(1)', 7, FT.WordPos);
  AssertEquals('beta gamma', EvalScriptPoint(FT, S, -1));
end;

procedure TScriptParserTest.TestCreateForTestDefaultProfile;
begin
  AssertEquals('default PauseCmd', '0', FT.PauseCmd);
  AssertEquals('default PauseStr', '0', FT.PauseStr);
  AssertEquals('default SendDelay', 0, FT.SendDelay);
  AssertEquals('default ClickDelay', 0, FT.ClickDelay);
  AssertEquals('default LogLevel', 0, FT.LogLevel);
end;

procedure TScriptParserTest.TestCreateForTestCustomProfile;
var
  Profile: IScriptSettings;
  T: TScanThread;
begin
  Profile := TScriptSettings.Create;
  Profile.PauseCmd := '7';
  Profile.PauseStr := '8';
  Profile.SendDelay := 9;
  Profile.ClickDelay := 10;
  Profile.LogLevel := 1;
  T := TScanThread.CreateForTest(Profile);
  try
    AssertEquals('custom PauseCmd', '7', T.PauseCmd);
    AssertEquals('custom PauseStr', '8', T.PauseStr);
    AssertEquals('custom SendDelay', 9, T.SendDelay);
    AssertEquals('custom ClickDelay', 10, T.ClickDelay);
    AssertEquals('custom LogLevel', 1, T.LogLevel);
  finally
    T.Free;
  end;
end;

initialization
  RegisterTest(TScriptParserTest);
end.
