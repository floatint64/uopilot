unit mySys;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Свалка общих мелочей: строки, шрифты, таблицы. }

interface

uses Windows, Grids, Graphics;

{ В Windows.pas Delphi 7 её нет. }
function OpenThread(dwDesiredAccess: DWORD; bInheritHandle: BOOL;
  dwThreadId: DWORD): THandle; stdcall;
  external 'kernel32.dll' name 'OpenThread';

function BoolStr(B: Boolean): ShortString;
function StrIsTrue(S: ShortString): Boolean;
procedure GridDeleteRow(G: TCustomGrid; ARow: Integer);
procedure FillGridFromCsv(Grid: TStringGrid; A, B, C: string; Hex: Boolean);
function CutStr(var S: string; Sep: string): string;
function CutInt(var S: string; Sep: string): Integer;
function FontToStr(F: TFont; Sep: string): string;
procedure StrToFont(S: string; F: TFont; Delim: string);
function HexPairToByte(W: Word): Byte;
function PeekChar(P: PChar; var C: Char): Char;
function WikiUrlDecode(S: string): string;
function FixLineBreaks(const S: string): string;

implementation

uses SysUtils;

type
  { Класс-взломщик обязан лежать в том же юните, что и обращение: Паскаль
    пускает к protected предка только код того юнита, где объявлен
    наследник. Вынести один общий в интерфейс не выйдет -- у каждого свой. }
  TGridCracker = class(TStringGrid);

function BoolStr(B: Boolean): ShortString;
begin
  if B then
    Result := 'True'
  else
    Result := 'False';
end;

function StrIsTrue(S: ShortString): Boolean;
begin
  if LowerCase(S) = 'true' then
    Result := True
  else
    Result := False;
end;

procedure GridDeleteRow(G: TCustomGrid; ARow: Integer);
begin
  // DeleteRow у TCustomGrid protected, отсюда и обёртка с взломщиком.
  TGridCracker(G).DeleteRow(ARow);
end;

procedure FillGridFromCsv(Grid: TStringGrid; A, B, C: string; Hex: Boolean);
var
  S1, S2, S3: string;
  V: Cardinal;
  R: Integer;
begin
  { CSV трёх колонок таблицы последних объектов: A -- номера, B -- серийники,
    C -- описания, все три режутся по запятой синхронно. Разбор строки под
    пустым except: битую строку просто пропускаем, а откусывание идёт после
    него -- иначе на первой же кривой записи цикл встанет намертво.
    '0' в начале серийника -- метка шестнадцатеричного: StrToInt64 понимает
    префикс '0x', обратно число уходит как '0' + IntToHex(V, 8). }
  Grid.RowCount := 1;
  Grid.Cells[0, 0] := '';
  while Pos(',', A) <> 0 do
  begin
    try
      S3 := Copy(A, 1, Pos(',', A) - 1);
      if Length(S3) <> 0 then
      begin
        V := StrToInt64(S3);
        S1 := IntToStr(V);
      end
      else
        S1 := '';
      S2 := Copy(B, 1, Pos(',', B) - 1);
      if Length(S2) <> 0 then
      begin
        if (S2[1] = '0') and (Length(S2) > 1) then
          S2 := '0x' + S2;
        V := StrToInt64(S2);
        if Hex then
          S2 := '0' + IntToHex(V, 8)
        else
          S2 := IntToStr(V);
      end
      else
        S2 := '';
      if Grid.Cells[0, 0] <> '' then
        Grid.RowCount := Grid.RowCount + 1;
      R := Grid.RowCount - 1;
      Grid.Cells[0, R] := S1;
      Grid.Cells[1, R] := S2;
      Grid.Cells[2, R] := Copy(C, 1, Pos(',', C) - 1);
    except
    end;
    Delete(A, 1, Pos(',', A));
    Delete(B, 1, Pos(',', B));
    Delete(C, 1, Pos(',', C));
  end;
end;

function CutStr(var S: string; Sep: string): string;
var
  P: Integer;
begin
  // Откусить от S кусок до разделителя и вернуть его.
  P := Pos(Sep, S)  { именно Pos, а не AnsiPos: разделитель тут однобайтный };
  if P > 0 then
  begin
    Result := Copy(S, 1, P - 1);
    Delete(S, 1, P - 1 + Length(Sep));
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

function CutInt(var S: string; Sep: string): Integer;
var
  P: Integer;
begin
  // То же, что CutStr, но кусок разбирается числом; не число (и пустая
  // строка) дают -1 -- отсюда все проверки <> -1 в StrToFont.
  P := Pos(Sep, S)  { именно Pos, а не AnsiPos: разделитель тут однобайтный };
  if P > 0 then
  begin
    if not TryStrToInt(Copy(S, 1, P - 1), Result) then Result := -1;
    Delete(S, 1, P - 1 + Length(Sep));
  end
  else
  begin
    if not TryStrToInt(S, Result) then Result := -1;
    S := '';
  end;
end;

function FontToStr(F: TFont; Sep: string): string;
var
  St: Integer;
begin
  // Шрифт в строку 'имя,кегль,цвет,стиль' через разделитель Sep:
  // так шрифт лога уезжает в ini ключом LogFont.
  St := 0;
  if fsBold in F.Style then St := St or 1;
  if fsItalic in F.Style then St := St or 2;
  if fsUnderline in F.Style then St := St or 4;
  if fsStrikeOut in F.Style then St := St or 8;
  Result := F.Name + Sep + IntToStr(F.Size) + Sep + IntToStr(F.Color) + Sep + IntToStr(St);
end;

procedure StrToFont(S: string; F: TFont; Delim: string);
var
  N: Integer;
begin
  // Обратная FontToStr: разбирает 'имя,кегль,цвет,стиль'. Отсутствующее
  // или нечисловое поле CutInt отдаёт как -1 -- отсюда умолчания.
  F.Name := CutStr(S, Delim);
  N := CutInt(S, Delim);
  if N <> -1 then F.Size := N else F.Size := 8;
  N := CutInt(S, Delim);
  if N <> -1 then F.Color := N else F.Color := clWindowText;
  N := CutInt(S, Delim);
  F.Style := [];
  if N <> -1 then
  begin
    if N and 1 <> 0 then F.Style := F.Style + [fsBold];
    if N and 2 <> 0 then F.Style := F.Style + [fsItalic];
    if N and 4 <> 0 then F.Style := F.Style + [fsUnderline];
    if N and 8 <> 0 then F.Style := F.Style + [fsStrikeOut];
  end;
end;

function HexPairToByte(W: Word): Byte;
asm
  { Пара hex-цифр в байт: старшая цифра приходит в AL, младшая в AH.
    На ассемблере затем, что обе половины разбираются в одном регистре и
    ни одной переменной не заводится -- зовётся оно на каждый символ. }
  CMP     AH, '0'
  JL      @@bad
  CMP     AH, '9'
  JG      @@h1
  SUB     AH, '0'
  JMP     @@lo
@@h1:
  CMP     AH, 'A'
  JL      @@bad
  CMP     AH, 'F'
  JG      @@h2
  SUB     AH, 'A'
  ADD     AH, 10
  JMP     @@lo
@@h2:
  CMP     AH, 'a'
  JL      @@bad
  CMP     AL, 'f'
  JG      @@bad
  SUB     AH, 'a'
  ADD     AH, 10
@@lo:
  CMP     AL, '0'
  JL      @@bad
  CMP     AL, '9'
  JG      @@l1
  SUB     AL, '0'
  JMP     @@ok
@@l1:
  CMP     AL, 'A'
  JL      @@bad
  CMP     AL, 'F'
  JG      @@l2
  SUB     AL, 'A'
  ADD     AL, 10
  JMP     @@ok
@@l2:
  CMP     AL, 'a'
  JL      @@bad
  CMP     AL, 'f'
  JG      @@bad
  SUB     AL, 'a'
  ADD     AL, 10
@@ok:
  SHL     AL, 4
  OR      AL, AH
  RET
@@bad:
  XOR     AL, AL
end;

function PeekChar(P: PChar; var C: Char): Char;
begin
  { Читает символ и заодно отдаёт его наружу -- на этом держится условие
    цикла в WikiUrlDecode. }
  C := P^;
  Result := C;
end;

function WikiUrlDecode(S: string): string;
var
  P: PChar;
  C: Char;
begin
  { Раскодирование %XX в имени статьи вики; дальше результат уходит в
    Utf8ToAnsi. Битую пару после '%' не проверяем -- HexPairToByte на такой
    отдаёт ноль, и символ просто пропадёт. }
  Result := '';
  P := @S[1];
  while PeekChar(P, C) <> #0 do
  begin
    case C of
      '+':
        Result := Result + ' ';
      '%':
        begin
          Inc(P);
          Result := Result + Char(HexPairToByte(PWord(P)^));
          Inc(P);
        end;
    else
      Result := Result + C;
    end;
    Inc(P);
  end;
end;

function FixLineBreaks(const S: string): string;
var
  R: string;
  I: Integer;
begin
  R := S;
  I := Length(R);
  while I >= 1 do
  begin
    case R[I] of
      #10:
        if (I > 1) and (R[I - 1] <> #13) then
          R := Copy(R, 1, I - 1) + #13 + Copy(R, I, Length(R) - I + 1);
    end;
    Dec(I);
    Result := R;
  end;
end;

end.
