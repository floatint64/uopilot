unit GDIPOBJ;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Запуск и остановка GDI+ на всю программу. Классы-обёртки полного
  GDIPOBJ мне не нужны -- отсюда пустые объявления: важны только две
  секции ниже. }

interface

uses Windows, GDIPAPI;

type
  TGPFontFamily = class(TObject)
  end;

  TGPStringFormat = class(TObject)
  end;

var
  GenericSansSerifFontFamily: TGPFontFamily = nil;
  GenericSerifFontFamily: TGPFontFamily = nil;
  GenericMonospaceFontFamily: TGPFontFamily = nil;

  GenericTypographicStringFormatBuffer: TGPStringFormat = nil;
  GenericDefaultStringFormatBuffer: TGPStringFormat = nil;

  StartupInput: TGdiplusStartupInput;
  gdiplusToken: ULONG;

implementation

initialization
begin
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs := False;
  StartupInput.GdiplusVersion := 1;
  GdiplusStartup(gdiplusToken, @StartupInput, nil);
end;

finalization
begin
  if Assigned(GenericSansSerifFontFamily) then GenericSansSerifFontFamily.Free;
  if Assigned(GenericSerifFontFamily) then GenericSerifFontFamily.Free;
  if Assigned(GenericMonospaceFontFamily) then GenericMonospaceFontFamily.Free;

  if Assigned(GenericTypographicStringFormatBuffer) then GenericTypographicStringFormatBuffer.Free;
  if Assigned(GenericDefaultStringFormatBuffer) then GenericDefaultStringFormatBuffer.Free;

  GdiplusShutdown(gdiplusToken);
end;

end.
