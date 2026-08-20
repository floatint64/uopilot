unit LangClipboard;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Почему здесь сырой WinAPI, а не потомок TClipboard с override Open/Close,
  как было в Delphi-версии:

  Юнит портирован с Delphi VCL на Lazarus LCL. В LCL-юните Clipbrd:
    - Open/Close объявлены БЕЗ virtual (clipbrd.pp), поэтому override не
      компилируется, а reintroduce не даёт виртуальной диспетчеризации
      (вызов через ссылку TClipboard уйдёт в базовый метод);
    - AsText-сеттер не вызывает Open/Close вовсе (идёт через
      BeginUpdate/EndUpdate в SetBuffer), поэтому перехватить запись в
      буфер через Open/Close в принципе невозможно;
    - GetAsHandle отсутствует.

  Поэтому локаль CF_LOCALE кладём здесь явно, в обёртках, через
  OpenClipboard/EmptyClipboard/SetClipboardData/GetClipboardData.

  Плюс две обёртки на строку, ими пользуются Unit1, uScanThread и SynEdit:
  SetClipboardText кладёт в буфер CF_UNICODETEXT, CF_TEXT и CF_LOCALE (русская
  локаль $0419), чтобы клиент Ultima Online корректно перекодировал текст при
  вставке. }

interface

uses Windows, Clipbrd;

const
  LOCALE_RUSSIAN = $0419;

function SetClipboardText(C: TClipboard; S: string): Boolean;
function GetClipboardText(C: TClipboard): string;

implementation

uses SysUtils;

{ Кладём в буфер обмена строку S в трёх форматах: CF_UNICODETEXT (cp1251 ->
  UTF-16), CF_TEXT (байты как есть, в проекте string = AnsiString/cp1251) и
  CF_LOCALE = $0419. Параметр C не используется: работаем с буфером ОС
  напрямую. }
function SetClipboardText(C: TClipboard; S: string): Boolean;

  function AllocText: HGLOBAL;
  var
    P: Pointer;
    Len: Integer;
  begin
    Len := Length(S) + 1;
    Result := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, Len);
    if Result = 0 then
      Exit;
    P := GlobalLock(Result);
    if P = nil then
    begin
      GlobalFree(Result);
      Result := 0;
      Exit;
    end;
    Move(PChar(S)^, P^, Len);
    GlobalUnlock(Result);
  end;

  function AllocUnicodeText: HGLOBAL;
  var
    P: Pointer;
    CharCount: Integer;
    ByteCount: Integer;
  begin
    Result := 0;
    CharCount := MultiByteToWideChar(1251, 0, PChar(S), -1, nil, 0);
    if CharCount = 0 then
      Exit;
    ByteCount := CharCount * SizeOf(WideChar);
    Result := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, ByteCount);
    if Result = 0 then
      Exit;
    P := GlobalLock(Result);
    if P = nil then
    begin
      GlobalFree(Result);
      Result := 0;
      Exit;
    end;
    MultiByteToWideChar(1251, 0, PChar(S), -1, PWideChar(P), CharCount);
    GlobalUnlock(Result);
  end;

  function AllocLocale: HGLOBAL;
  var
    P: Pointer;
    LCID: DWORD;
  begin
    Result := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SizeOf(DWORD));
    if Result = 0 then
      Exit;
    P := GlobalLock(Result);
    if P = nil then
    begin
      GlobalFree(Result);
      Result := 0;
      Exit;
    end;
    LCID := LOCALE_RUSSIAN;
    Move(LCID, P^, SizeOf(DWORD));
    GlobalUnlock(Result);
  end;

  procedure SetData(Format: UINT; H: HGLOBAL);
  begin
    if H <> 0 then
    begin
      if SetClipboardData(Format, H) = 0 then
        GlobalFree(H);
    end;
  end;

begin
  Result := False;
  if not OpenClipboard(0) then
    Exit;
  try
    EmptyClipboard;
    SetData(CF_UNICODETEXT, AllocUnicodeText);
    SetData(CF_TEXT, AllocText);
    SetData(CF_LOCALE, AllocLocale);
    Result := True;
  finally
    CloseClipboard;
  end;
end;

{ Читаем из буфера обмена: предпочитаем CF_UNICODETEXT (перекодируем UTF-16 ->
  cp1251), иначе CF_TEXT (байты как есть). Параметр C не используется. }
function GetClipboardText(C: TClipboard): string;

  function ReadUnicode: string;
  var
    H: THandle;
    P: Pointer;
    WideLen: Integer;
    ByteLen: Integer;
  begin
    Result := '';
    H := GetClipboardData(CF_UNICODETEXT);
    if H = 0 then
      Exit;
    P := GlobalLock(H);
    if P = nil then
      Exit;
    try
      WideLen := lstrlenW(PWideChar(P));
      ByteLen := WideCharToMultiByte(1251, 0, PWideChar(P), WideLen, nil, 0,
        nil, nil);
      SetLength(Result, ByteLen);
      if ByteLen > 0 then
        WideCharToMultiByte(1251, 0, PWideChar(P), WideLen, PChar(Result),
          ByteLen, nil, nil);
    finally
      GlobalUnlock(H);
    end;
  end;

  function ReadAnsi: string;
  var
    H: THandle;
    P: Pointer;
    Len: Integer;
  begin
    Result := '';
    H := GetClipboardData(CF_TEXT);
    if H = 0 then
      Exit;
    P := GlobalLock(H);
    if P = nil then
      Exit;
    try
      Len := lstrlenA(PAnsiChar(P));
      SetLength(Result, Len);
      if Len > 0 then
        Move(P^, PChar(Result)^, Len);
    finally
      GlobalUnlock(H);
    end;
  end;

begin
  Result := '';
  if not OpenClipboard(0) then
    Exit;
  try
    if IsClipboardFormatAvailable(CF_UNICODETEXT) then
      Result := ReadUnicode
    else if IsClipboardFormatAvailable(CF_TEXT) then
      Result := ReadAnsi;
  finally
    CloseClipboard;
  end;
end;

end.
