unit CRCunit;

{ CRC32 буфера по готовой таблице. Таблицу строим при запуске. }

interface

function CrcOfBuf(N: Integer; P: PChar; L: Cardinal): Integer;
function SendExKeyCode(P: PChar): Integer;

implementation

var
  { Таблица CRC32. В файле её нет -- строится в initialization. }
  gCrcTable: array[0..$FF] of Integer;

{ Длина беззнаковая, так что с L = 0 звать нельзя: цикл уйдёт по всей
  памяти. Пустой буфер отсекает вызывающий. }
function CrcOfBuf(N: Integer; P: PChar; L: Cardinal): Integer;
var
  K: Integer;
  I: Cardinal;
begin
  for I := 0 to L - 1 do
  begin
    K := (Ord(P[I]) xor N) and $FF;
    N := (N shr 8) xor gCrcTable[K];
  end;
  Result := N;
end;

{ Контрольная сумма нуль-строки: длину берём у временной строки,
  считаем по исходному буферу. }
function SendExKeyCode(P: PChar): Integer;
var
  S: string;
begin
  S := P;
  Result := CrcOfBuf(-1, P, Length(S));
end;

{ Обычная таблица CRC32 по многочлену $EDB88320. }
procedure BuildCrcTable;
var
  I, J, C: Integer;
begin
  for I := 0 to $FF do
  begin
    C := I;
    for J := 1 to 8 do
      if Odd(C) then
        C := (C shr 1) xor Integer($EDB88320)
      else
        C := C shr 1;
    gCrcTable[I] := C;
  end;
end;

initialization
  BuildCrcTable;

end.
