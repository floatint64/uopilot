unit PngGDIP;

{ Поиск CLSID кодировщика GDI+ по MIME-типу -- то есть выбор формата,
  в котором снимок окна уходит в поток. }

interface

uses Windows;

type
  { Раскладка ImageCodecInfo из GDI+. Запись packed: размер элемента должен
    совпасть с тем, из чего GdipGetImageEncodersSize считает свой Size. }
  PImageCodecInfo = ^TImageCodecInfo;
  TImageCodecInfo = packed record
    Clsid: TGUID;
    FormatID: TGUID;
    CodecName: PWideChar;
    DllName: PWideChar;
    FormatDescription: PWideChar;
    FilenameExtension: PWideChar;
    MimeType: PWideChar;
    Flags: DWORD;
    Version: DWORD;
    SigCount: DWORD;
    SigSize: DWORD;
    SigPattern: PByte;
    SigMask: PByte;
  end;
  TImageCodecInfoArray = array[0..0] of TImageCodecInfo;
  PImageCodecInfoArray = ^TImageCodecInfoArray;

function GdipGetImageEncodersSize(out numEncoders, size: UINT): Integer;
function GdipGetImageEncoders(numEncoders, size: UINT;
  encoders: PImageCodecInfo): Integer;
function GetEncoderClsid(MimeType: string; out Clsid: TGUID): Integer;

implementation

{ Сам импорт stdcall, наружу отдаём register-обёртки -- звать удобнее. }
function GdipGetImageEncodersSizeStd(out numEncoders, size: UINT): Integer;
  stdcall; external 'gdiplus.dll' name 'GdipGetImageEncodersSize';
function GdipGetImageEncodersStd(numEncoders, size: UINT;
  encoders: PImageCodecInfo): Integer;
  stdcall; external 'gdiplus.dll' name 'GdipGetImageEncoders';

function GdipGetImageEncodersSize(out numEncoders, size: UINT): Integer;
begin
  Result := GdipGetImageEncodersSizeStd(numEncoders, size);
end;

function GdipGetImageEncoders(numEncoders, size: UINT;
  encoders: PImageCodecInfo): Integer;
begin
  Result := GdipGetImageEncodersStd(numEncoders, size, encoders);
end;

function GetEncoderClsid(MimeType: string; out Clsid: TGUID): Integer;
var
  Num: UINT;
  Size: UINT;
  Info: PImageCodecInfo;
  J: Cardinal;
begin
  { Спрашиваем размер таблицы кодировщиков, забираем её целиком и ищем
    нужный по MIME-типу. Выход из цикла по находке не делаю: если кодек
    в системе двоится, пусть останется последний. }
  Num := 0;
  Size := 0;
  Result := -1;
  GdipGetImageEncodersSize(Num, Size);
  if Size = 0 then
    Exit;
  GetMem(Info, Size);
  if Info = nil then
    Exit;
  GdipGetImageEncoders(Num, Size, Info);
  for J := 0 to Num - 1 do
    if PImageCodecInfoArray(Info)^[J].MimeType = MimeType then
    begin
      Clsid := PImageCodecInfoArray(Info)^[J].Clsid;
      Result := J;
    end;
  FreeMem(Info, Size);
end;

end.
