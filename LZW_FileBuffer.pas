unit LZW_FileBuffer;

{ Нижний слой распаковки: чтение источника блоками по $10000 и разбор
  кодов LZW переменной длины из битового буфера. Основа взята из чужого
  распаковщика LZW и подогнана под свои потоки. }

interface

uses Classes;

var
  gUopDstVargg: TStream;            // куда пишет распаковщик
  gUopWritten: Int64;               // сколько байт выдано наружу
  gUopPos: Int64;                   // позиция чтения
  gUopTotalau: Int64;               // длина источника

procedure UopFillBuffer(var S: TMemoryStream);
function UopReadByte(var S: TMemoryStream): Byte;
procedure UopLzwFlushMem(var MS: TMemoryStream);
procedure UopLzwFlushDst(var Dst: TStream);
procedure UopLzwEmitMem(var MS: TMemoryStream; B: Byte);
procedure UopLzwEmitDst(var Dst: TStream; B: Byte);
function UopLzwReadCode(var Src: TMemoryStream; Bits: Byte): Word;
procedure UopLzwReset;

implementation

type
  TUopModeZ = set of (umReadZ, umWriteZ, umSeekZ);
  TUopStateZ = set of (usIdleZ, usBusyZ, usDoneZ);

var
  gUopBitCount: Byte;               // бит в битовом буфере
  gUopFlag81: Byte;
  gUopBlock: Cardinal;              // номер блока в буфере, 1..N
  gUopOutPos: Cardinal;             // заполнено в выходном буфере
  gUopBitBuf: Cardinal;             // битовый буфер кода
  gUopSpare90: Cardinal;
  gUopLoaded: Int64;                // сколько уже прочитано
  gUopSpare9C: Cardinal;
  gUopSpareA0: Cardinal;
  gUopBuf: array of Byte;           // входной буфер, $10001 байт
  gUopOut: array of Byte;           // выходной буфер, $10001 байт

procedure UopFillBuffer(var S: TMemoryStream);
var
  N: Cardinal;
begin
  { Дочитать очередной блок $10000 байт в gUopBuf; из накопленной длины
    пересчитывается номер блока. }
  if gUopTotalau >= gUopLoaded then
  begin
    if gUopBlock = 0 then
      gUopLoaded := 0;
    S.Seek((gUopPos div $10000) * $10000, 0);
    N := S.Read(gUopBuf[0], $10000);
    Inc(gUopLoaded, N);
    gUopBlock := (gUopLoaded - 1) div $10000 + 1;
  end;
end;

function UopReadByte(var S: TMemoryStream): Byte;
begin
  { Очередной байт источника через буфер: номер блока -- деление позиции,
    индекс в буфере -- остаток от начала блока. Нулевой gUopBlock значит
    «буфер ещё не читали», тогда и позицию сбрасываем. }
  Result := 0;
  if gUopBlock = 0 then
  begin
    UopFillBuffer(S);
    gUopPos := 0;
  end;
  if gUopBlock <> gUopPos div $10000 + 1 then
    UopFillBuffer(S);
  if gUopPos <= gUopTotalau then
  begin
    Result := gUopBuf[gUopPos - (gUopBlock - 1) * $10000];
    Inc(gUopPos);
  end;
end;

procedure UopLzwFlushMem(var MS: TMemoryStream);
begin
  { Вывалить накопленный выходной буфер в память. }
  MS.Write(gUopOut[0], gUopOutPos);
  gUopOutPos := 0;
end;

procedure UopLzwFlushDst(var Dst: TStream);
begin
  { То же в поток-приёмник. }
  Dst.Write(gUopOut[0], gUopOutPos);
  gUopOutPos := 0;
end;

procedure UopLzwEmitMem(var MS: TMemoryStream; B: Byte);
begin
  { Байт в выходной буфер; по заполнении $10000 буфер сбрасывается. }
  gUopOut[gUopOutPos] := B;
  Inc(gUopWritten);
  Inc(gUopOutPos);
  if gUopOutPos = $10000 then
    UopLzwFlushMem(MS);
end;

procedure UopLzwEmitDst(var Dst: TStream; B: Byte);
begin
  { То же в поток-приёмник. }
  gUopOut[gUopOutPos] := B;
  Inc(gUopWritten);
  Inc(gUopOutPos);
  if gUopOutPos = $10000 then
    UopLzwFlushDst(Dst);
end;

function UopLzwReadCode(var Src: TMemoryStream; Bits: Byte): Word;
var
  B: Word;
begin
  { Код переменной длины из битового буфера: пока бит не хватает,
    дочитываем байт источника и подсовываем его сверху. }
  while Bits > gUopBitCount do
  begin
    B := UopReadByte(Src);
    gUopBitBuf := gUopBitBuf or (B shl gUopBitCount);
    Inc(gUopBitCount, 8);
  end;
  Result := ((1 shl Bits) - 1) and gUopBitBuf;
  gUopBitBuf := gUopBitBuf shr Bits;
  Dec(gUopBitCount, Bits);
end;

procedure UopLzwReset;
begin
  { Сброс состояния читателя и выходного буфера. Буферы сперва отпускаем
    и лишь потом заводим заново -- так они не переезжают по памяти. }
  gUopWritten := 0;
  gUopPos := 0;
  gUopTotalau := 0;
  gUopBitCount := 0;
  gUopFlag81 := 0;
  gUopBlock := 0;
  gUopOutPos := 0;
  gUopBitBuf := 0;
  gUopSpare90 := 0;
  gUopLoaded := 0;
  gUopSpare9C := 0;
  gUopSpareA0 := 0;
  SetLength(gUopOut, 0);
  SetLength(gUopBuf, 0);
  SetLength(gUopOut, $10001);
  SetLength(gUopBuf, $10001);
end;

initialization
  UopLzwReset;

end.
