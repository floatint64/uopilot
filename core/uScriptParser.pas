unit uScriptParser;

{ Чистые текстовые хелперы разбора строк скрипта. Не зависят от VCL/LCL,
  Unit1 и uScanThread, поэтому годятся и для production, и для тестов. }

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

{ Отрезает от строки скрипта однострочный комментарий `//`, не трогая `//`
  внутри кавычек. }
function StripScriptComment(const S: string): string;

{ Убирает завершающие пробелы и табуляции. }
function TrimRightScriptLine(const S: string): string;

{ Вставляет пробел перед позицией P (первой `(` в LogPrefix). }
function InsertSpaceBeforeParen(const S: string; P: Integer): string;

{ Обрезает имя команды по первому `:`, если двоеточие не в самом начале. }
function CutCommandAtColon(const S: string): string;

implementation

uses
  StrUtils;

function StripScriptComment(const S: string): string;
var
  L: Integer;
  P, N, I, J: Integer;
begin
  Result := S;
  P := Pos('//', Result);
  L := Length(Result);
  while (P > 0) and (P <= L - 1) do
  begin
    if Pos('"', Result) > 0 then
    begin
      N := 0;
      for I := 1 to P - 1 do
        if Result[I] = '"' then
        begin
          Inc(N);
          J := I;
        end;
      if N mod 2 = 0 then
      begin
        Result := Copy(Result, 1, P - 1);
        Break;
      end
      else
        P := PosEx('//', Result, P + 2);
    end
    else
    begin
      Result := Copy(Result, 1, P - 1);
      Break;
    end;
  end;
end;

function TrimRightScriptLine(const S: string): string;
var
  K: Integer;
begin
  K := Length(S);
  while (K > 0) and ((S[K] = ' ') or (S[K] = #9)) do
    Dec(K);
  Result := Copy(S, 1, K);
end;

function InsertSpaceBeforeParen(const S: string; P: Integer): string;
begin
  Result := S;
  if (P > 0) and (P <= Length(Result) + 1) then
    Insert(' ', Result, P);
end;

function CutCommandAtColon(const S: string): string;
var
  P: Integer;
begin
  P := Pos(':', S);
  if P > 1 then
    Result := Copy(S, 1, P - 1)
  else
    Result := S;
end;

end.
