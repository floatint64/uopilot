unit TestScriptParser;
{$mode objfpc}{$H+}

interface

uses
  fpcunit, testregistry, uScanThread;

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
    procedure TestPrepareCommandParen;
    procedure TestPrepareCommandColon;
    procedure TestPrepareCommandUnchanged;
    procedure TestEvalScriptPointWords;
  end;

implementation

uses
  SysUtils, Unit1;

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
  AssertEquals('set $a 1 ', StripScriptComment('set $a 1 // comment'));
end;

procedure TScriptParserTest.TestStripCommentQuotedUrl;
begin
  AssertEquals('set $a "http://x" ',
    StripScriptComment('set $a "http://x" // c'));
end;

procedure TScriptParserTest.TestStripCommentInsideQuotes;
begin
  AssertEquals('set $a "a // b"',
    StripScriptComment('set $a "a // b"'));
end;

procedure TScriptParserTest.TestStripCommentWholeLine;
begin
  AssertEquals('', StripScriptComment('// whole line'));
end;

procedure TScriptParserTest.TestStripCommentNoComment;
begin
  AssertEquals('set $a 1', StripScriptComment('set $a 1'));
end;

procedure TScriptParserTest.TestPrepareCommandParen;
begin
  FT.Line := 'if(1)';
  FT.LogPrefix := 'if(';
  PrepareScriptCommandLine(FT);
  AssertEquals('if (1)', FT.Line);
  AssertEquals('if', FT.LogPrefix);
end;

procedure TScriptParserTest.TestPrepareCommandColon;
begin
  FT.Line := 'foo:bar';
  FT.LogPrefix := 'foo:bar';
  PrepareScriptCommandLine(FT);
  AssertEquals('foo:bar', FT.Line);
  AssertEquals('foo', FT.LogPrefix);
end;

procedure TScriptParserTest.TestPrepareCommandUnchanged;
begin
  FT.Line := 'set #r 1';
  FT.LogPrefix := 'set';
  PrepareScriptCommandLine(FT);
  AssertEquals('set #r 1', FT.Line);
  AssertEquals('set', FT.LogPrefix);
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

initialization
  RegisterTest(TScriptParserTest);
end.
