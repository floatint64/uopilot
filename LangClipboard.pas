unit LangClipboard;

{ Подменяем глобальный Clipboard своим потомком: тот кладёт в буфер обмена
  формат CF_LOCALE с русской локалью, чтобы Windows перекодировала текст при
  вставке в приложения с другой кодовой страницей. Клиент Ultima Online --
  как раз такой случай.

  Плюс две обёртки на строку, ими пользуются Unit1, uScanThread и SynEdit. }

interface

uses Windows, Clipbrd;

type
  TLangClipboard = class(TClipboard)
  private
    procedure SetClipboardLocale(LCID: DWORD);
  public
    procedure Close; override;
    procedure Open; override;
  end;

function SetClipboardText(C: TClipboard; S: string): Boolean;
function GetClipboardText(C: TClipboard): string;

const
  LOCALE_RUSSIAN = $0419;

implementation

uses SysUtils;

{ Прежний буфер обмена -- чтобы освободить его после подмены. }
var
  OldClipboard: TClipboard;

function SetClipboardText(C: TClipboard; S: string): Boolean;
begin
  C.Open;
  C.AsText := S;
  C.Close;
  Result := True;
end;

{ Параметр в теле не нужен -- работаем с глобальным Clipboard; оставлен
  парой к SetClipboardText, чтобы звать одинаково. }
function GetClipboardText(C: TClipboard): string;
var
  H: THandle;
  P: Pointer;
  Sz: Integer;
  Len: Integer;
  Failed: Boolean;
begin
  Result := '';
  with Clipboard do
  begin
    try
      Open;
      if HasFormat(CF_TEXT) or HasFormat(CF_UNICODETEXT) then
      begin
        if Win32Platform = VER_PLATFORM_WIN32_NT then
        begin
          Failed := False;
          if not Failed then
          begin
            H := GetAsHandle(CF_UNICODETEXT);
            Sz := GlobalSize(H);
            P := GlobalLock(H);
            try
              Len := Sz div 2 - 1;
              SetLength(Result, Len);
              WideCharToMultiByte(0, 0, P, Sz, PChar(Result), Len, nil, nil);
            finally
              GlobalUnlock(H);
            end;
          end;
        end
        else
        begin
          H := GetAsHandle(CF_TEXT);
          Len := GlobalSize(H);
          SetLength(Result, Len);
          SetLength(Result, GetTextBuf(PChar(Result), Len));
        end;
      end;
    finally
      Close;
    end;
  end;
end;

procedure TLangClipboard.Close;
begin
  SetClipboardLocale(LOCALE_RUSSIAN);
  inherited Close;
end;

procedure TLangClipboard.Open;
begin
  inherited Open;
  SetClipboardLocale(LOCALE_RUSSIAN);
end;

{ Кладём в буфер обмена локаль отдельным форматом. Если не вышло -- молча
  отдаём блок обратно, наружу не пробрасываем: из-за локали ронять вставку
  незачем. }
procedure TLangClipboard.SetClipboardLocale(LCID: DWORD);
var
  H: THandle;
  P: Pointer;
begin
  H := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SizeOf(DWORD));
  try
    P := GlobalLock(H);
    try
      Move(LCID, P^, SizeOf(DWORD));
      SetClipboardData(CF_LOCALE, H);
    finally
      GlobalUnlock(H);
    end;
  except
    GlobalFree(H);
  end;
end;

initialization
  OldClipboard := SetClipboard(TLangClipboard.Create);
  if OldClipboard <> nil then
    OldClipboard.Free;

finalization
  if Clipboard is TLangClipboard then
    SetClipboard(nil).Free;

end.
