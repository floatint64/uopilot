unit uScriptDriver;

{ Общий line-loop скрипта: production использует Step, тесты и будущий core --
  Run. Драйвер не знает ни про UI, ни про Unit1/uScanThread: всё внешнее
  приходит через IScriptDriverState/IScriptDriverHost. }

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  SysUtils, uScriptParser;

type
  EScriptDriverError = class(Exception);

  TScriptStepResult = (
    srNext,       { строка обработана/пропущена, продолжаем }
    srEnd,        { строки закончились }
    srRestart,    { restart_script или stop в начале строки }
    srScanLoop,   { stop/перезапуск из wait }
    srAgain,      { поток уже приостановлен хостом }
    srRetry,      { внутренний: повторить проход с BeforeLine }
    srStop        { явная остановка }
  );

  TRestartPolicy = (rpError, rpReset);

  IScriptDriverState = interface
    ['{8A1B2C3D-4E5F-4A60-9B71-0C2D3E4F5A61}']
    function  GetLinesCount: Integer;
    function  GetLine(Index: Integer): string;
    function  GetCurLine: Integer;
    procedure SetCurLine(Value: Integer);
    function  GetLineText: string;
    procedure SetLineText(const Value: string);
    function  GetLogPrefix: string;
    procedure SetLogPrefix(const Value: string);
    function  GetRestartFlag: Boolean;
    procedure SetRestartFlag(Value: Boolean);
    function  GetRepeatLine: Boolean;
    procedure SetRepeatLine(Value: Boolean);
    function  GetRepeatCmd: Boolean;
    procedure SetRepeatCmd(Value: Boolean);
  end;

  IScriptDriverHost = interface
    ['{8A1B2C3D-4E5F-4A60-9B71-0C2D3E4F5A62}']
    function  BeforeLine: TScriptStepResult;
    function  EvalLine(const S: string): string;
    function  ResolveCommand(const AName: string): Integer;
    procedure ExecuteCommand(var ACmd: Integer);
    function  HandleLuaBlock(out AConsumed: Boolean): TScriptStepResult;
    function  HandleBlockComment(out AConsumed: Boolean): TScriptStepResult;
    function  WaitEmptyLine: TScriptStepResult;
    function  WaitEmptyPrefix: TScriptStepResult;
    function  WaitBeforeCommand: TScriptStepResult;
  end;

  TScriptDriver = class
  private
    FState: IScriptDriverState;
    FHost: IScriptDriverHost;
    FMaxSteps: Integer;
    FSteps: Integer;
  public
    constructor Create(const AState: IScriptDriverState;
      const AHost: IScriptDriverHost);
    function  Step: TScriptStepResult;
    procedure Run(ARestartPolicy: TRestartPolicy = rpError);
    procedure ResetSteps;
    property  MaxSteps: Integer read FMaxSteps write FMaxSteps;
  end;

implementation

constructor TScriptDriver.Create(const AState: IScriptDriverState;
  const AHost: IScriptDriverHost);
begin
  inherited Create;
  FState := AState;
  FHost := AHost;
end;

procedure TScriptDriver.ResetSteps;
begin
  FSteps := 0;
end;

function TScriptDriver.Step: TScriptStepResult;
var
  Line: string;
  Cmd: Integer;
  Consumed: Boolean;
  R: TScriptStepResult;
begin
  while True do
  begin
    if FState.GetCurLine >= FState.GetLinesCount then
    begin
      Result := srEnd;
      Exit;
    end;

    R := FHost.BeforeLine;
    if R = srRetry then
      Continue;
    if R <> srNext then
    begin
      Result := R;
      Exit;
    end;

    FState.SetLineText(FState.GetLine(FState.GetCurLine));

    R := FHost.HandleLuaBlock(Consumed);
    if Consumed then
    begin
      FState.SetCurLine(FState.GetCurLine + 1);
      Result := srNext;
      Exit;
    end;

    while True do
    begin
      FState.SetRepeatLine(False);
      Line := FState.GetLineText;
      if Line = '' then
      begin
        R := FHost.WaitEmptyLine;
        if R <> srNext then
        begin
          Result := R;
          Exit;
        end;
        FState.SetCurLine(FState.GetCurLine + 1);
        Result := srNext;
        Exit;
      end;

      Line := TrimRightScriptLine(StripScriptComment(Line));
      FState.SetLineText(Line);

      R := FHost.HandleBlockComment(Consumed);
      if Consumed then
      begin
        FState.SetCurLine(FState.GetCurLine + 1);
        Result := srNext;
        Exit;
      end;

      Line := FState.GetLineText;
      if Line = '' then
      begin
        R := FHost.WaitEmptyLine;
        if R <> srNext then
        begin
          Result := R;
          Exit;
        end;
        FState.SetCurLine(FState.GetCurLine + 1);
        Result := srNext;
        Exit;
      end;

      FState.SetLogPrefix(FHost.EvalLine(Line));
      if FState.GetLogPrefix = '' then
      begin
        R := FHost.WaitEmptyPrefix;
        if R <> srNext then
        begin
          Result := R;
          Exit;
        end;
        FState.SetCurLine(FState.GetCurLine + 1);
        Result := srNext;
        Exit;
      end;

      R := FHost.WaitBeforeCommand;
      if R = srRetry then
        Break;
      if R <> srNext then
      begin
        Result := R;
        Exit;
      end;

      if Pos('(', FState.GetLogPrefix) > 0 then
      begin
        FState.SetLineText(InsertSpaceBeforeParen(FState.GetLineText,
          Pos('(', FState.GetLogPrefix)));
        FState.SetLogPrefix(FHost.EvalLine(FState.GetLineText));
      end;

      FState.SetLogPrefix(CutCommandAtColon(FState.GetLogPrefix));
      Cmd := FHost.ResolveCommand(FState.GetLogPrefix);

      repeat
        FHost.ExecuteCommand(Cmd);
        Inc(FSteps);
        if (FMaxSteps > 0) and (FSteps > FMaxSteps) then
          raise EScriptDriverError.CreateFmt(
            'step limit (%d) exceeded at line %d',
            [FMaxSteps, FState.GetCurLine]);
      until not FState.GetRepeatCmd;

      if FState.GetRestartFlag then
      begin
        Result := srRestart;
        Exit;
      end;
      if FState.GetRepeatLine then
        Continue;

      FState.SetCurLine(FState.GetCurLine + 1);
      Result := srNext;
      Exit;
    end;
  end;
end;

procedure TScriptDriver.Run(ARestartPolicy: TRestartPolicy);
var
  R: TScriptStepResult;
begin
  ResetSteps;
  while True do
  begin
    R := Step;
    case R of
      srNext:
        ;
      srEnd, srScanLoop, srStop:
        Exit;
      srRestart:
        case ARestartPolicy of
          rpError:
            raise EScriptDriverError.Create('restart_script is not supported');
          rpReset:
            begin
              FState.SetRestartFlag(False);
              FState.SetCurLine(0);
              ResetSteps;
            end;
        end;
      srAgain:
        raise EScriptDriverError.Create('script suspended');
      srRetry:
        ;
    end;
  end;
end;

end.
