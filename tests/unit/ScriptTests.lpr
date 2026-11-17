program ScriptTests;
{$mode objfpc}{$H+}

uses
  Interfaces, Classes, consoletestrunner,
  TestScriptExpressions, TestScriptParser, TestScriptDriver,
  TestScriptDriverFlow, TestScriptCases;

var
  App: TTestRunner;
begin
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
