unit LZW_CompressUnit;

{ Сам разжиматель LZW: словарь, разворот кода в цепочку байтов и цикл
  распаковки. Нижний слой -- чтение источника и битовый разбор -- лежит
  в LZW_FileBuffer. }

interface

uses Classes;

type
  { Узел словаря: первый потомок и два соседа, плюс код-префикс и символ.
    $100 в поле-ссылке значит «пусто». }
  TUopEntry = packed record
    Child: Word;                       // первый потомок
    Less: Word;                        // сосед со «меньшим» символом
    More: Word;                        // сосед со «большим» символом
    Parent: Word;                      // код-префикс
    Ch: Byte;                          // символ
    Pad: Byte;                         // выравнивание
  end;
  TDecodeBuffer = array of Byte;

var
  gUopBits: Byte;                   // разрядность кода

function UopLzwMaskOf(Bits: Byte): Word;
procedure UopLzwStart;
procedure UopLzwAddEntry(Code: Word; Ch: Byte);
procedure UopLzwClearDict;
procedure UopLzwChainMem(var MS: TMemoryStream; Chain: TDecodeBuffer);
procedure UopLzwChainDst(var Dst: TStream; Chain: TDecodeBuffer);
procedure UopLzwExpand(Code: Word);
procedure UopLzwDecode(var Src: TMemoryStream; var Dst: TStream);
procedure UopUnpackStream(var S: TMemoryStream);
procedure UopSaveStreamToFile(S: TMemoryStream; FileName: string);
procedure UopLzwInit;

implementation

uses SysUtils, LZW_FileBuffer;

var
  gUopFlagB4: Byte;                 // сбрасывается вместе с длиной кода
  gUopCodeLen: Byte;                // текущая длина кода
  gUopChar: Byte;                   // последний выданный байт
  gUopMask: Word;
  gUopLimit: Word;                  // граница словаря
  gUopDictSize: Word;               // размер словаря = маска от gUopBits
  gUopLen: Cardinal;                // длина накопленной цепочки
  gUopDict: array of TUopEntry;     // сам словарь LZW
  gUopChain: TDecodeBuffer;         // сама цепочка

function UopLzwMaskOf(Bits: Byte): Word;
var
  I: Byte;
  M: Cardinal;
begin
  { Маска в Bits младших единиц. }
  M := 1;
  for I := 1 to Bits do
    M := M + M;
  Dec(M);
  Result := M;
end;

procedure UopLzwStart;
begin
  { Размер словаря задаётся разрядностью кода. Сначала отпускаем массив
    и только потом заводим заново -- переносить старое содержимое незачем. }
  gUopDictSize := UopLzwMaskOf(gUopBits);
  SetLength(gUopDict, 0);
  SetLength(gUopDict, gUopDictSize);
end;

procedure UopLzwAddEntry(Code: Word; Ch: Byte);
var
  P: Word;
begin
  { Новая запись словаря. Узел -- это первый потомок (Child) плюс два
    соседа: Less и More. Если у Code потомка ещё нет, новый узел становится
    потомком; иначе идём по цепочке соседей в ту сторону, куда попадает
    символ, и вешаем узел ей в конец. }
  if gUopLimit < gUopDictSize then
  begin
    if gUopDict[Code].Child = $100 then
    begin
      gUopDict[Code].Child := gUopLimit;
      gUopDict[gUopLimit].Child := $100;
      gUopDict[gUopLimit].Less := $100;
      gUopDict[gUopLimit].More := $100;
      gUopDict[gUopLimit].Parent := Code;
      gUopDict[gUopLimit].Ch := Ch;
    end
    else if Ch > gUopDict[gUopDict[Code].Child].Ch then
    begin
      P := gUopDict[Code].Child;
      while gUopDict[P].More <> $100 do
        P := gUopDict[P].More;
      gUopDict[P].More := gUopLimit;
      gUopDict[gUopLimit].Child := $100;
      gUopDict[gUopLimit].Less := gUopLimit;
      gUopDict[gUopLimit].More := $100;
      gUopDict[gUopLimit].Parent := Code;
      gUopDict[gUopLimit].Ch := Ch;
    end
    else
    begin
      P := gUopDict[Code].Child;
      while gUopDict[P].Less <> $100 do
        P := gUopDict[P].Less;
      gUopDict[P].Less := gUopLimit;
      gUopDict[gUopLimit].Child := $100;
      gUopDict[gUopLimit].Less := $100;
      gUopDict[gUopLimit].More := gUopLimit;
      gUopDict[gUopLimit].Parent := Code;
      gUopDict[gUopLimit].Ch := Ch;
    end;
    Inc(gUopLimit);
  end;
end;

procedure UopLzwClearDict;
var
  I: Word;
begin
  { Словарь к 256 односимвольным записям. Коды $100..$103 служебные,
    поэтому граница словаря стартует с $104. }
  gUopCodeLen := 9;
  gUopFlagB4 := 0;
  gUopMask := UopLzwMaskOf(gUopCodeLen);
  for I := 0 to gUopDictSize - 1 do
  begin
    gUopDict[I].Parent := 0;
    gUopDict[I].Ch := 0;
    gUopDict[I].Child := $100;
    gUopDict[I].Less := $100;
    gUopDict[I].More := $100;
  end;
  for I := 0 to $FF do
  begin
    gUopDict[I].Parent := $100;
    gUopDict[I].Ch := I;
  end;
  gUopLimit := $104;
end;

procedure UopLzwChainMem(var MS: TMemoryStream; Chain: TDecodeBuffer);
var
  I: Cardinal;
begin
  { Цепочка байтов в память. }
  for I := 0 to Length(Chain) - 1 do
    UopLzwEmitMem(MS, Chain[I]);
end;

procedure UopLzwChainDst(var Dst: TStream; Chain: TDecodeBuffer);
var
  I: Cardinal;
begin
  { То же в поток-приёмник. }
  for I := 0 to Length(Chain) - 1 do
    UopLzwEmitDst(Dst, Chain[I]);
end;

procedure UopLzwExpand(Code: Word);
var
  Tmp: TDecodeBuffer;
  Cur: Word;
  I, J: Cardinal;
begin
  { Код разворачивается в цепочку байтов. Идём от кода к родителю,
    накапливая символы во временный массив, а потом переписываем его в
    gUopChain задом наперёд -- по дереву мы шли от конца цепочки к началу. }
  Cur := Code;
  gUopLen := 0;
  repeat
    SetLength(Tmp, gUopLen + 1);
    Tmp[gUopLen] := gUopDict[Cur].Ch;
    Cur := gUopDict[Cur].Parent;
    Inc(gUopLen);
  until Cur = $100;
  SetLength(gUopChain, gUopLen);
  J := 0;
  for I := gUopLen - 1 downto 0 do
  begin
    gUopChain[J] := Tmp[I];
    Inc(J);
  end;
end;

procedure UopLzwDecode(var Src: TMemoryStream; var Dst: TStream);
var
  Old, Code: Word;
begin
  { Тот же цикл LZW, что в UopUnpackStream, но пишет в произвольный поток
    и не заводит состояние заново -- это делает вызывающий. }
  UopLzwStart;
  Code := 0;
  UopLzwClearDict;
  gUopTotalau := Src.Size;
  Old := UopLzwReadCode(Src, gUopCodeLen);
  UopLzwEmitDst(Dst, Old);
  gUopChar := Byte(Old);
  while Code <> $103 do
  begin
    Code := UopLzwReadCode(Src, gUopCodeLen);
    case Code of
      $103: Break;
      $100:
        begin
          UopLzwClearDict;
          Old := UopLzwReadCode(Src, gUopCodeLen);
          gUopChar := Byte(Old);
          Code := UopLzwReadCode(Src, gUopCodeLen);
        end;
      $102:
        begin
          Inc(gUopCodeLen);
          gUopMask := UopLzwMaskOf(gUopCodeLen);
          Code := UopLzwReadCode(Src, gUopCodeLen);
        end;
    end;
    if Code >= gUopLimit then
    begin
      UopLzwExpand(Old);
      Inc(gUopLen);
      SetLength(gUopChain, gUopLen);
      gUopChain[gUopLen - 1] := gUopChar;
    end
    else
      UopLzwExpand(Code);
    UopLzwChainDst(Dst, gUopChain);
    gUopChar := gUopChain[0];
    UopLzwAddEntry(Old, gUopChar);
    Old := Code;
  end;
  UopLzwFlushDst(Dst);
end;

procedure UopUnpackStream(var S: TMemoryStream);
var
  MS: TMemoryStream;
  Old, Code: Word;
begin
  // Ядро распаковщика UoP: поток разжимается сам в себя.
  // Служебные коды: $100 -- сброс словаря, $102 -- увеличить длину кода,
  // $103 -- конец.
  UopLzwReset;
  UopLzwInit;
  gUopBits := 16;
  UopLzwStart;
  Code := 0;
  UopLzwClearDict;
  gUopTotalau := S.Size;
  MS := TMemoryStream.Create;
  Old := UopLzwReadCode(S, gUopCodeLen);
  UopLzwEmitMem(MS, Old);
  gUopChar := Byte(Old);
  while Code <> $103 do
  begin
    Code := UopLzwReadCode(S, gUopCodeLen);
    case Code of
      $103: Break;
      $100:
        begin
          UopLzwClearDict;
          Old := UopLzwReadCode(S, gUopCodeLen);
          gUopChar := Byte(Old);
          Code := UopLzwReadCode(S, gUopCodeLen);
        end;
      $102:
        begin
          Inc(gUopCodeLen);
          gUopMask := UopLzwMaskOf(gUopCodeLen);
          Code := UopLzwReadCode(S, gUopCodeLen);
        end;
    end;
    if Code >= gUopLimit then
    begin
      UopLzwExpand(Old);
      Inc(gUopLen);
      SetLength(gUopChain, gUopLen);
      gUopChain[gUopLen - 1] := gUopChar;
    end
    else
      UopLzwExpand(Code);
    UopLzwChainMem(MS, gUopChain);
    gUopChar := gUopChain[0];
    UopLzwAddEntry(Old, gUopChar);
    Old := Code;
  end;
  UopLzwFlushMem(MS);
  S.Clear;
  S.LoadFromStream(MS);
  MS.Free;
end;

procedure UopSaveStreamToFile(S: TMemoryStream; FileName: string);
begin
  // Разжать поток прямо в файл, минуя промежуточный буфер в памяти:
  // распакованный кусок бывает и в сотню мегабайт.
  UopLzwReset;
  UopLzwInit;
  gUopBits := 16;
  gUopTotalau := S.Size;
  gUopDstVargg := TFileStream.Create(FileName, fmCreate);
  UopLzwDecode(S, gUopDstVargg);
  gUopDstVargg.Free;
end;

procedure UopLzwInit;
begin
  { Обнуление состояния. }
  gUopBits := 0;
  gUopFlagB4 := 0;
  gUopCodeLen := 0;
  gUopChar := 0;
  gUopMask := 0;
  gUopLimit := 0;
  gUopDictSize := 0;
  gUopLen := 0;
end;

end.
