unit TestScriptKnownBugs;
{$mode objfpc}{$H+}

{ Известные баги движка: по одному ignored-тесту на баг. Реального вызова
  движка нет намеренно -- тест документирует баг и ждёт исправления. }

interface

uses
  fpcunit, testregistry;

type
  TScriptKnownBugsTest = class(TTestCase)
  published
    procedure TestSizeEmpty;
    procedure TestLuaMarkersSpaces;
    procedure TestGetClipboardArray;
    procedure TestHexPairLowNibble;
  end;

implementation

uses
  SysUtils;

procedure TScriptKnownBugsTest.TestSizeEmpty;
begin
  raise EIgnoredTest.Create('BUGS.md: size("") -> V[0] access violation');
end;

procedure TScriptKnownBugsTest.TestLuaMarkersSpaces;
begin
  raise EIgnoredTest.Create(
    'BUGS.md: --lua/--endlua markers are not trimmed');
end;

procedure TScriptKnownBugsTest.TestGetClipboardArray;
begin
  raise EIgnoredTest.Create(
    'BUGS.md: get clipboard %a puts words into columns');
end;

procedure TScriptKnownBugsTest.TestHexPairLowNibble;
begin
  raise EIgnoredTest.Create(
    'BUGS.md: HexPairToByte accepts 4g as a byte');
end;

initialization
  RegisterTest(TScriptKnownBugsTest);
end.
