unit uLegacyScriptSession;
{$mode objfpc}{$H+}

interface

uses
  uScanThread, uScriptTestSession;

type
  TLegacyScriptSession = class(TInterfacedObject, IScriptSession)
  private
    FT: TScanThread;
    FMaxSteps: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    function Eval(const Expr: string): string;
    procedure RunScript(const Script: string);
    function NumVar(const Name: string): Int64;
    function StrVar(const Name: string): string;
    function ArrCell(const Name: string; Row, Col: Integer): string;
    function LastError: string;
    property MaxSteps: Integer read FMaxSteps write FMaxSteps;
  end;

implementation

uses
  Classes, SysUtils, Unit1;

{ Команды, которые тестовый драйвер исполняет. Внешние команды (send, mouse,
  clipboard, window, memory, file, plugin, macro), `log`, `wait`, `msg`,
  `hint`, `exit`, `proc`/`call`, `exec`, `load_script`, `restart_script` сюда
  не входят: им нужен host/UI, которого в unit-тестах нет. }
function IsAllowedCommand(Cmd: Integer): Boolean;
begin
  case Cmd of
    0, 1, 2, 3, 4, 5, 6, 7, 10, 11,
    32, 40, 41, 42, 43, 44, 45, 46, 47,
    49, 110, 112, 114, 115, 116, 126, 127:
      Result := True;
  else
    Result := False;
  end;
end;

constructor TLegacyScriptSession.Create;
begin
  inherited Create;
  FMaxSteps := 100000;
  Reset;
end;

destructor TLegacyScriptSession.Destroy;
begin
  FreeAndNil(FT);
  inherited Destroy;
end;

{ Таблицы команд -- глобальное состояние Unit1, поэтому их поднимают при
  каждом создании сессии. }
procedure TLegacyScriptSession.Reset;
begin
  FreeAndNil(FT);
  InitScriptCommandTables;
  FT := TScanThread.CreateForTest;
end;

{ Внутренний вычислитель ожидает 'calc ' перед выражением и nv = -1:
  тогда он берёт всё после первого слова. }
function TLegacyScriptSession.Eval(const Expr: string): string;
begin
  if FT = nil then
    Reset;
  Result := EvalScriptExpr(FT, 'calc ' + Expr, -1);
end;

{ Минимальный драйвер legacy-цикла: повторяет порядок Execute, но без UI,
  пауз, логов и внешних команд. }
procedure TLegacyScriptSession.RunScript(const Script: string);
label
  NoLua;
var
  Cmd: Integer;
  Steps: Integer;
  I: Integer;
  LinesList: TStringList;
  S: string;
  CmdName: string;
  SubCmd: string;
begin
  if FT = nil then
    Reset;

  LinesList := TStringList.Create;
  try
    LinesList.Text := Script;
    SetLength(FT.Lines, LinesList.Count);
    for I := 0 to LinesList.Count - 1 do
      FT.Lines[I] := LinesList[I];
  finally
    LinesList.Free;
  end;

  FT.CurLine := 0;
  FT.StopRequested := False;
  FT.Paused := False;
  FT.RestartFlag := False;
  FT.RepeatLine := False;
  FT.RepeatCmd := False;
  FT.LogPrefix := '';
  FT.Msg := '';
  FT.CmdLine := 0;
  FT.ParenPos := 0;
  FT.Line := '';
  FT.LineCount := 0;
  SetLength(FT.Arr50, 0);
  SetLength(FT.Arr54, 0);
  SetLength(FT.Arr58, 0);
  FT.VarNames.Clear;
  FT.VarNames.Add('timer');
  FT.LogLevel := 0;
  FT.LoggingCommands := False;
  FT.AutoStart := False;
  FT.ShowRun := False;

  Steps := 0;
  while FT.CurLine < Length(FT.Lines) do
  begin
    FT.Line := FT.Lines[FT.CurLine];
    S := AnsiLowerCase(FT.Line);
    if (S = '--lua') or (S = '-- lua') then
      raise EScriptDriverError.CreateFmt(
        'lua blocks are not supported (line %d)', [FT.CurLine]);

  NoLua:
    FT.RepeatLine := False;
    if FT.Line = '' then
    begin
      Inc(FT.CurLine);
      Continue;
    end;

    FT.Line := StripScriptComment(FT.Line);
    I := Length(FT.Line);
    while (I > 0) and ((FT.Line[I] = ' ') or (FT.Line[I] = #9)) do
      Dec(I);
    FT.Line := Copy(FT.Line, 1, I);

    if FT.Line = '' then
    begin
      Inc(FT.CurLine);
      Continue;
    end;

    if Pos('(*', FT.Line) > 0 then
      raise EScriptDriverError.CreateFmt(
        'block comments are not supported (line %d)', [FT.CurLine]);

    FT.LogPrefix := EvalScriptExpr(FT, FT.Line, 0);
    if FT.LogPrefix = '' then
    begin
      Inc(FT.CurLine);
      Continue;
    end;

    PrepareScriptCommandLine(FT);
    Cmd := gCmdList2jj.IndexOf(FT.LogPrefix);
    if Cmd < 0 then
    begin
      { Метка `:name`: в Execute её молча пропускает else-ветка
        ExecScriptCommand (LogPrefix начинается с ':'). }
      if Copy(FT.LogPrefix, 1, 1) <> ':' then
        raise EScriptDriverError.CreateFmt(
          'unknown command "%s" (line %d)', [FT.LogPrefix, FT.CurLine]);
      Inc(FT.CurLine);
      Continue;
    end;

    { `eval` и `set logging` переписывают Cmd и ставят RepeatCmd, поэтому
      allowlist перепроверяется на каждой итерации. }
    repeat
      if not IsAllowedCommand(Cmd) then
      begin
        if (Cmd >= 0) and (Cmd < gCmdList2jj.Count) then
          CmdName := gCmdList2jj[Cmd]
        else
          CmdName := FT.LogPrefix;
        raise EScriptDriverError.CreateFmt(
          'command "%s" is not supported (line %d)',
          [CmdName, FT.CurLine]);
      end;

      { `set logging` меняет глобальное состояние и в test-режиме пишет
        служебный текст в Msg, который драйвер считает ошибкой. }
      if Cmd = 40 then
      begin
        SubCmd := AnsiLowerCase(EvalScriptPoint(FT, FT.Line, 1));
        if (Length(SubCmd) >= 2) and (SubCmd[1] = '"') and
           (SubCmd[Length(SubCmd)] = '"') then
          SubCmd := Copy(SubCmd, 2, Length(SubCmd) - 2);
        if SubCmd = 'logging' then
          raise EScriptDriverError.CreateFmt(
            'set logging is not supported (line %d)', [FT.CurLine]);
      end;

      Inc(Steps);
      if Steps > FMaxSteps then
        raise EScriptDriverError.CreateFmt(
          'step limit (%d) exceeded at line %d', [FMaxSteps, FT.CurLine]);

      FT.Msg := '';
      ExecScriptCommand(FT, Cmd, FT.Line);
      if FT.Msg <> '' then
        raise EScriptDriverError.Create('script error: ' + LastError);
      if FT.StopRequested then
        Exit;
      if FT.RestartFlag then
        raise EScriptDriverError.Create('restart_script is not supported');
    until not FT.RepeatCmd;

    if FT.RepeatLine then
      goto NoLua;
    Inc(FT.CurLine);
  end;
end;

function TLegacyScriptSession.NumVar(const Name: string): Int64;
var
  Idx: Integer;
begin
  if FT = nil then
    Reset;
  Idx := FindScriptVar(FT, '#', AnsiLowerCase(Name), 0, 0);
  Result := FT.Vars[Idx].Value;
end;

function TLegacyScriptSession.StrVar(const Name: string): string;
var
  Idx: Integer;
begin
  if FT = nil then
    Reset;
  Idx := FindScriptVar(FT, '$', AnsiLowerCase(Name), 0, 0);
  Result := FT.Timers[Idx].Value;
end;

function TLegacyScriptSession.ArrCell(const Name: string; Row, Col: Integer): string;
var
  Idx: Integer;
begin
  Result := '';
  if (Row < 1) or (Col < 1) then
    Exit;
  if FT = nil then
    Reset;
  Idx := FindScriptVar(FT, '%', AnsiLowerCase(Name), Row, Col);
  if (Length(FT.Arr48[Idx].Data) < Row) or
     (Length(FT.Arr48[Idx].Data[Row - 1]) < Col) then
    Exit;
  Result := FT.Arr48[Idx].Data[Row - 1][Col - 1];
end;

{ ShowScriptMsg в тестовом режиме не дописывает завершающий #0, но многие
  ветки ошибок ставят его сами -- снимаем ровно один. }
function TLegacyScriptSession.LastError: string;
begin
  if FT = nil then
    Exit('');
  Result := FT.Msg;
  if (Length(Result) > 0) and (Result[Length(Result)] = #0) then
    Delete(Result, Length(Result), 1);
end;

end.
