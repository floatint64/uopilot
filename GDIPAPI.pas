unit GDIPAPI;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Плоский GDI+ ровно в том объёме, который нужен: заголовков GDI+ в
  поставке Delphi 7 нет, а тащить сюда полный GDIPAPI на триста килобайт
  ради двенадцати имён незачем. }

interface

uses Windows, ActiveX;

type
  PGpRect = ^TGpRect;
  TGpRect = packed record
    X, Y, Width, Height: Integer;
  end;

  { Stride знаковый нарочно: у растра, идущего снизу вверх, он
    отрицательный. }
  PGpBitmapData = ^TGpBitmapData;
  TGpBitmapData = packed record
    Width: UINT;
    Height: UINT;
    Stride: Integer;
    PixelFormat: Integer;
    Scan0: Pointer;
    Reserved: UINT;
  end;

  PGdiplusStartupInput = ^TGdiplusStartupInput;
  TGdiplusStartupInput = packed record
    GdiplusVersion: DWORD;
    DebugEventCallback: Pointer;
    SuppressBackgroundThread: BOOL;
    SuppressExternalCodecs: BOOL;
  end;

const
  PixelFormat24bppRGB = $00021808;

function GdiplusStartup(out token: DWORD; input: PGdiplusStartupInput;
  output: Pointer): Integer; stdcall; external 'gdiplus.dll';
procedure GdiplusShutdown(token: DWORD);
  stdcall; external 'gdiplus.dll';
function GdipDisposeImage(image: Pointer): Integer;
  stdcall; external 'gdiplus.dll';
function GdipSaveImageToFile(image: Pointer; filename: PWideChar;
  clsidEncoder: PGUID; encoderParams: Pointer): Integer;
  stdcall; external 'gdiplus.dll';
function GdipSaveImageToStream(image: Pointer; const stream: IStream;
  clsidEncoder: PGUID; encoderParams: Pointer): Integer;
  stdcall; external 'gdiplus.dll';
{ Размеры берём знаковыми: они сразу идут в счёт по массиву точек. }
function GdipGetImageWidth(image: Pointer; out width: Integer): Integer;
  stdcall; external 'gdiplus.dll';
function GdipGetImageHeight(image: Pointer; out height: Integer): Integer;
  stdcall; external 'gdiplus.dll';
function GdipCreateBitmapFromFile(filename: PWideChar;
  out bitmap: Pointer): Integer; stdcall; external 'gdiplus.dll';
function GdipCreateBitmapFromScan0(width, height, stride: Integer;
  format: Integer; scan0: Pointer; out bitmap: Pointer): Integer;
  stdcall; external 'gdiplus.dll';
function GdipCreateBitmapFromHBITMAP(hbm: HBITMAP; hpal: HPALETTE;
  out bitmap: Pointer): Integer; stdcall; external 'gdiplus.dll';
function GdipBitmapLockBits(bitmap: Pointer; rect: PGpRect; flags: UINT;
  format: Integer; lockedBitmapData: PGpBitmapData): Integer;
  stdcall; external 'gdiplus.dll';
function GdipBitmapUnlockBits(bitmap: Pointer;
  lockedBitmapData: PGpBitmapData): Integer; stdcall; external 'gdiplus.dll';

implementation

end.
