unit uLegacyScriptSession;
{$mode objfpc}{$H+}

interface

uses
  uScanThread, uScriptTestSession;

type
  TLegacyScriptSession = class(TInterfacedObject, IScriptSession)
  private
    FT: TScanThread;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Reset;
    function Eval(const Expr: string): string;
    function NumVar(const Name: string): Int64;
    function StrVar(const Name: string): string;
    function ArrCell(const Name: string; Row, Col: Integer): string;
  end;

implementation

uses
  SysUtils, Unit1;

constructor TLegacyScriptSession.Create;
begin
  inherited Create;
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

end.
