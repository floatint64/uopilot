program ScriptTests;
{$mode objfpc}{$H+}

uses
  Interfaces, Classes, SysUtils, consoletestrunner,
  TestScriptExpressions, TestScriptParser, TestScriptDriver,
  TestScriptDriverFlow, TestScriptCases, TestScriptSession,
  TestScriptCommands, TestScriptCommandEdges, TestScriptKnownBugs,
  TestScriptCoverage, uScriptCoverage, Unit1;

const
  GenCoveragePrefix = '--gen-coverage=';

var
  App: TTestRunner;
  Path: string;
  Existing, Rows: TScriptCoverageRows;
begin
  { Фиксированный локаль тестового профиля: math/date-кейсы должны быть
    воспроизводимы независимо от настроек Windows. Production-локаль не
    меняется: это отдельный бинарник. }
  DefaultFormatSettings.DecimalSeparator := '.';
  DefaultFormatSettings.DateSeparator := '-';
  DefaultFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  DefaultFormatSettings.TimeSeparator := ':';
  DefaultFormatSettings.LongTimeFormat := 'hh:nn:ss';

  if Copy(ParamStr(1), 1, Length(GenCoveragePrefix)) = GenCoveragePrefix then
  begin
    Path := Copy(ParamStr(1), Length(GenCoveragePrefix) + 1, MaxInt);
    InitScriptCommandTables;
    Existing := nil;
    if FileExists(Path) then
      Existing := LoadScriptCoverage(Path);
    Rows := BuildScriptCoverage(Existing);
    SaveScriptCoverage(Path, Rows);
    Halt(0);
  end;

  IsMultiThread := True;
  DefaultFormat := fPlain;
  DefaultRunAllTests := True;
  App := TTestRunner.Create(nil);
  try
    App.Initialize;
    App.Title := 'UoPilot script tests';
    App.Run;
  finally
    App.Free;
  end;
end.
