unit uScript;

{ Управление выполнением скрипта: запуск, пауза, остановка потока, показ
  текущей строки и ошибок. Всё, что зовётся из потока через Synchronize,
  собрано здесь. }

interface

{ ActiveX -- IStream (снимок уходит в поток через TStreamAdapter),
  Graphics/ExtCtrls -- картинка окна прогресса gProcImage.
  Unit1 стоит ПОСЛЕДНИМ: всё, что объявлено и там, и в VCL, должно
  разрешаться в пользу Unit1. }
uses Windows, Messages, SysUtils, Classes, Graphics, Controls, ExtCtrls,
  StdCtrls, StrUtils, ActiveX, Forms, Unit1, uLuaApi;

type
  { Потомок без единого своего поля -- он нужен только затем, чтобы
    компилятор вывел тип метода-указателя у перегруженной
    TThread.Synchronize: с классом из ЧУЖОГО юнита он этого не делает и
    ругается «There is no overloaded version of 'Synchronize'». }
  TScriptThread = class(TScanThread)
  public
    procedure ShowScriptHint;
  end;

{ ---- привязка Lua ---------------------------------------------------------
  Обёртка над lua_State; сам объект живёт в поле потока. }
type
  TLuaCFunc = function(L: Integer): Integer; cdecl;
  TLuaStatusText = array[0..6] of string;
  PPtr = ^Pointer;

  TLua = class
  public
    Handle: Integer;                   { lua_State* }
    ScriptNo: Integer;                 { номер скрипта }
    procedure Reg(const Name: string; Func: Pointer; N: Integer);
    procedure RegP(const Name: string; Func: TLuaCFunc; N: Integer);
  end;


var
  { Тексты кодов возврата Lua -- по ним печатается ошибка скрипта. }
  gLuaStatusText: TLuaStatusText;

const
  PLuaStatus: ^TLuaStatusText = @gLuaStatusText;

{ luaL_loadstring + lua_pcall }
function LuaDoString(L: Integer; S: PChar): Integer;
{ ОДИН обработчик на все команды: своё имя он берёт из upvalue замыкания,
  поэтому в таблице регистрации всюду стоит один и тот же адрес. }
function LuaCmdHandler(L: Integer): Integer; cdecl;

procedure CaptureWindowBits(T: TScriptThread);
procedure ShowScriptRunLine(T: TScanThread);
procedure StartScriptThread(T: TScanThread);
procedure ShowScriptError(T: TScriptThread);
procedure PauseScriptThread(T: Pointer);
procedure AfterScriptStarted(T: Pointer);
procedure ResumeScriptThread(T: Pointer);
procedure StopScriptThread(T: Pointer);
procedure WriteScriptLog(T: TScanThread);
procedure RunLuaScript(T: TScanThread);
function StripComment(S: string): string;
procedure UpdateScriptButtons(T: Pointer);

{ Табличка функций, которую видит плагин. }
var
  gPluginFuncs: PPluginFuncs;

implementation

{$IFDEF FPC}
const
  HGDI_ERROR = HGDIOBJ($FFFFFFFF);
{$ENDIF}

{ Привести кнопки и редактор в соответствие с состоянием скрипта на
  ТЕКУЩЕЙ вкладке и вернуть фокус в редактор.

  Номер скрипта -- это ПОДПИСЬ вкладки, она хранится строкой, отсюда
  StrToInt. Аргумент не нужен: он есть только ради единой подписи у всех
  обёрток под Synchronize. }
procedure UpdateScriptButtons(T: Pointer);
begin
  with fmSecond do
  begin
    if tScript.Tabs.Count <> 0 then
    begin
      btStart.Down := gScripts[StrToInt(tScript.Tabs[tScript.TabIndex])].Flag91;
      sbPause.Enabled := btStart.Down;
      sbPause.Down := gScripts[StrToInt(tScript.Tabs[tScript.TabIndex])].Paused and
        btStart.Down;
      edScript.Enabled := sbPause.Down or not btStart.Down;
      edScript.ReadOnly := not edScript.Enabled or btStart.Down;
    end;
    if (edScript <> nil) and Visible and Enabled and edScript.Visible and
      edScript.Enabled and (pcAll.ActivePage = tsScript) then
    begin
      edScript.SetFocus;
      if Handle = GetForegroundWindow then
        SetForegroundWindow(edScript.Handle);
    end;
  end;
end;

{ Убрать из строки скрипта хвостовой комментарий `//`, не тронув `//`
  внутри кавычек. Признак «внутри строки» -- НЕЧЁТНОЕ число кавычек до
  найденного `//`: при чётном комментарий настоящий и строку режем, при
  нечётном ищем следующий `//`. }
function StripComment(S: string): string;
var
  P, L, N, I: Integer;
begin
  P := Pos('//', S);
  L := Length(S);
  while (P > 0) and (P <= L - 1) do
  begin
    if Pos('"', S) > 0 then
    begin
      N := 0;
      for I := 1 to P - 1 do
        if S[I] = '"' then
          Inc(N);
      if N mod 2 = 0 then
      begin
        S := Copy(S, 1, P - 1);
        Break;
      end
      else
        P := PosEx('//', S, P + 2);
    end
    else
    begin
      S := Copy(S, 1, P - 1);
      Break;
    end;
  end;
  Result := S;
end;


{ Снять окно (или область экрана) в буфер T.ShotBits.

  Порядок: заводим DDB, наполняем его -- либо BitBlt прямо с экрана, либо
  PrintWindow в память; дальше картинка отдаётся GDI+, при открытом окне
  предпросмотра кодируется в BMP и грузится в gProcImage, а сами пиксели
  забираются GdipBitmapLockBits и копируются в блок GlobalAlloc.
  Каждая неудача -- не выход, а сообщение и шаг дальше: чем меньше
  снимок сорвёт поиск, тем лучше. }
procedure CaptureWindowBits(T: TScriptThread);
var
  PFrom, PTo: TPoint;
  DC: HDC;
  OK: Boolean;
  Token: DWORD;
  Img: Pointer;
  MS: TMemoryStream;
  Stm: IStream;
  NewPos: Int64;
  SI: TGdiplusStartupInput;
  Cid: TGUID;
  BD: TGpBitmapData;
  R: TGpRect;
  W, H: Integer;
  MemDC: HDC;
  Bmp, OldBmp: HGDIOBJ;
  Src: Pointer;
begin
  T.ShotBits := nil;
  PTo := T.CapTo;
  PFrom := T.CapFrom;
  W := PTo.X;
  T.ShotW := W - PFrom.X;
  H := PTo.Y;
  T.ShotH := H - PFrom.Y;
  DC := GetDC(0);
  if DC = 0 then
  begin
    T.Msg := 'Поверхность неровная.';
    T.Synchronize(T.SyncShowMsg);
  end;
  try
    MemDC := CreateCompatibleDC(DC);
    if MemDC = 0 then
    begin
      T.Msg := 'Не удалось выровнять поверхность.';
      T.Synchronize(T.SyncShowMsg);
    end;
    if T.CapWnd = 2 then
    begin
      Bmp := CreateCompatibleBitmap(DC, T.ShotW, T.ShotH);
      if Bmp = 0 then
      begin
        T.Msg := 'Не удалось создать картинку.';
        T.Synchronize(T.SyncShowMsg);
      end;
      OldBmp := SelectObject(MemDC, Bmp);
      if (OldBmp = 0) or (OldBmp = HGDI_ERROR) then
      begin
        T.Msg := 'Не удалось выбрать картинку.';
        T.Synchronize(T.SyncShowMsg);
      end;
      OK := BitBlt(MemDC, 0, 0, T.ShotW, T.ShotH, DC, PFrom.X, PFrom.Y, SRCCOPY);
      if not OK then
      begin
        T.Msg := 'Не удалось скопировать картинку.';
        T.Synchronize(T.SyncShowMsg);
      end;
    end
    else
    begin
      Bmp := CreateCompatibleBitmap(DC, W, H);
      if Bmp = 0 then
      begin
        T.Msg := 'Не удалось создать картинку.';
        T.Synchronize(T.SyncShowMsg);
      end;
      OldBmp := SelectObject(MemDC, Bmp);
      if (OldBmp = 0) or (OldBmp = HGDI_ERROR) then
      begin
        T.Msg := 'Не удалось выбрать картинку.';
        T.Synchronize(T.SyncShowMsg);
      end;
      PrintWindow(T.CapWnd, MemDC, 0);
      OK := BitBlt(MemDC, 0, 0, T.ShotW, T.ShotH, MemDC, PFrom.X, PFrom.Y, SRCCOPY);
      if not OK then
      begin
        T.Msg := 'Не удалось скопировать картинку повторно.';
        T.Synchronize(T.SyncShowMsg);
      end;
    end;
    Img := nil;
    FillChar(SI, SizeOf(SI), 0);
    SI.GdiplusVersion := 1;
    if GdiplusStartup(Token, @SI, nil) <> 0 then
    begin
      T.Msg := 'С+ не запущен.';
      T.Synchronize(T.SyncShowMsg);
    end;
    if GdipCreateBitmapFromHBITMAP(Bmp, 0, Img) <> 0 then
    begin
      T.Msg := 'Не удалось создать картинку из памяти.';
      T.Synchronize(T.SyncShowMsg);
    end;
    if GetEncoderClsid('image/bmp', Cid) > 0 then
    begin
      T.Msg := 'Не удалось закодировать картинку.';
      T.Synchronize(T.SyncShowMsg);
    end;
    if gDlg59671C.Visible then
    begin
      MS := TMemoryStream.Create;
      Stm := nil;
      Stm := TStreamAdapter.Create(MS, soReference) as IStream;
      GdipSaveImageToStream(Img, Stm, @Cid, nil);
      Stm.Seek(0, 0, NewPos);
      gProcImage.Picture.Bitmap.LoadFromStream(MS);
      Stm := nil;
      MS.Free;
    end;
    R.X := 0;
    R.Y := 0;
    R.Width := T.ShotW;
    R.Height := T.ShotH;
    if GdipBitmapLockBits(Img, @R, 3, PixelFormat24bppRGB, @BD) <> 0 then
    begin
      T.Msg := 'Не закрылось.';
      T.Synchronize(T.SyncShowMsg);
    end;
    T.ShotSize := Abs(Integer(BD.Height) * BD.Stride);
    T.ShotBits := Pointer(GlobalAlloc(GPTR, T.ShotSize));
    if T.ShotBits = nil then
    begin
      T.Msg := 'Некуда копировать картинку.';
      T.Synchronize(T.SyncShowMsg);
    end;
    { Строки DIB идут снизу вверх, когда Stride отрицательный: тогда
      началом кадра служит ПОСЛЕДНЯЯ строка. }
    if BD.Stride > 0 then
      Src := BD.Scan0
    else
      Src := Pointer(Integer(BD.Scan0) + (BD.Height - 1) * BD.Stride);
    T.BottomUp := BD.Stride > 0;
    CopyMemory(T.ShotBits, Src, T.ShotSize);
    T.Lock.W := BD.Width;
    T.Lock.H := BD.Height;
    T.Lock.Stride := BD.Stride;
    if GdipBitmapUnlockBits(Img, @BD) <> 0 then
    begin
      T.Msg := 'Не открылось.';
      T.Synchronize(T.SyncShowMsg);
    end;
    GdipDisposeImage(Img);
    GdiplusShutdown(Token);
    SelectObject(MemDC, OldBmp);
    DeleteDC(MemDC);
    DeleteObject(Bmp);
    if not OK then
      T.ShotFailed := True;
  except
    T.ShotFailed := True;
    T.Msg := 'Ошибка выполнения скрипта 3317 ';
    T.Synchronize(T.ShowScriptHint);
  end;
  ReleaseDC(0, DC);
end;

procedure TLua.Reg(const Name: string; Func: Pointer; N: Integer);
begin
  { lua_pushstring(имя) / lua_pushcclosure(Func, 1) /
    lua_settable(L, LUA_GLOBALSINDEX) }
end;

procedure TLua.RegP(const Name: string; Func: TLuaCFunc; N: Integer);
begin
end;

function LuaDoString(L: Integer; S: PChar): Integer;
begin
  Result := 0;
end;

function LuaCmdHandler(L: Integer): Integer; cdecl;
begin
  Result := 0;
end;

{ Подсветить в редакторе строку, на которой стоит выполнение, подвинуть
  индикатор и показать номер строки. }
procedure ShowScriptRunLine(T: TScanThread);
var
  P, N, I: Integer;
begin
  N := T.LineCount - 1;
  P := 0;
  for I := 0 to N do
    Inc(P, Length(T.Lines[I]) + 2);
  fmSecond.edScript.SelStart := P;
  fmSecond.edScript.SelLength := 1;
  { номер строки с единицы, и ещё одна вперёд -- индикатор идёт по
    ЗАВЕРШЁННЫМ строкам }
  fmSecond.gScript.Progress := N + 1 + 1;
  fmSecond.pPos.Caption := IntToStr(T.LineCount);
end;

{ Сброс вкладки скрипта перед запуском: чистим таблицы переменных и
  таймеров, освобождаем блоки GlobalAlloc, гасим рабочие объекты. Каждый
  шаг в своём try..except: сбой одного не должен мешать остальным. }
procedure StartScriptThread(T: TScanThread);
var
  I: Integer;
begin
  try
    SetLength(T.Vars, 0);
    SetLength(T.Timers, 0);
    SetLength(T.Arr50, 0);
    SetLength(T.Arr54, 0);
    SetLength(T.Arr58, 0);
    SetLength(T.Arr48, 0);
    for I := 0 to Length(T.Blocks) - 1 do
    begin
      GlobalFree(T.Blocks[I].Handle);
      T.Blocks[I].Handle := 0;
    end;
    SetLength(T.Blocks, 0);
    if T.StartTick <> 0 then
      SetLength(T.Arr43F0, 0);
  except
  end;
  try
    T.VarNames.Clear;
    T.VarNames.Add('timer');
  except
  end;
  try
    FreeAndNil(T.Obj43FC);
  except
  end;
  try
    FreeAndNil(T.Obj4458);
  except
  end;
  try
    for I := 1 to 10 do
      if T.Workers[I] <> nil then
      begin
        T.Workers[I].Stop := True;
        FreeAndNil(T.Workers[I]);
      end;
  except
  end;
  try
    for I := 1 to 10 do
      if T.Workers2[I] <> nil then
      begin
        T.Workers2[I].Stop := True;
        FreeAndNil(T.Workers2[I]);
      end;
  except
  end;
end;

{ Показать текст ошибки скрипта: в лог, окном сообщения или подсказкой --
  смотря что отмечено на вкладке настроек. }
procedure ShowScriptError(T: TScriptThread);
var
  S: string;
  I: Integer;
begin
  if T.ClientWnd2 <> 0 then
    SetForegroundWindow(T.ClientWnd2);
  Sleep(1);
  S := ExtractFileName(T.Title);
  SetForegroundWindow(Application.Handle);
  T.Msg := FixLineBreaks(T.Msg) + #0;
  { перевод строки в скрипте пишут как /n или \n -- разворачиваем в CRLF }
  for I := 1 to Length(T.Msg) - 1 do
    if ((T.Msg[I] = '/') or (T.Msg[I] = '\')) and (T.Msg[I + 1] = 'n') then
    begin
      T.Msg[I] := #13;
      T.Msg[I + 1] := #10;
    end;
  if fmSecond.miToLog.Checked then
    T.Synchronize(T.SyncShowMsg);
  T.ToMsgBox := fmSecond.miToMessageBox.Checked;
  if T.ToMsgBox then
  begin
    if fmSecond.miRenameSelf.Checked then
      MsgBox(@T.Msg[1], PChar(fmSecond.miRenameSelf.Hint + ' Message  (' +
        T.Str43E0 + T.Name + ': ' + S + ')'), 0)
    else
      MsgBox(@T.Msg[1], PChar(Copy(fmSecond.Hint, 1, 7) + ' Message  (' +
        T.Str43E0 + T.Name + ': ' + S + ')'), 0);
  end
  else if fmSecond.miToHint.Checked then
  begin
    T.Msg := T.Name + ': ' + S + #13 + #10 + T.Msg + #0;
    T.ShowScriptHint;
  end;
end;

{ Скрипт встал на паузу: кнопка «пауза» нажата, редактор снова доступен. }
procedure PauseScriptThread(T: Pointer);
begin
  with fmSecond do
  begin
    if not sbPause.Enabled then
      Exit;
    sbPause.Down := True;
    edScript.Enabled := sbPause.Down or not btStart.Down;
    edScript.ReadOnly := not sbPause.Down;
  end;
end;

{ Скрипт запущен: «старт» нажат, редактор закрыт на правку. }
procedure AfterScriptStarted(T: Pointer);
begin
  with fmSecond do
  begin
    btStart.Down := True;
    btStart.Enabled := False;
    btStart.Enabled := True;
    sbPause.Down := False;
    sbPause.Enabled := True;
    edScript.Enabled := False;
    edScript.ReadOnly := True;
  end;
end;

{ Снятие с паузы -- близнец PauseScriptThread, только Down := False.
  ReadOnly тут считается уже по Enabled редактора, а не по кнопке. }
procedure ResumeScriptThread(T: Pointer);
begin
  with fmSecond do
  begin
    if not sbPause.Enabled then
      Exit;
    sbPause.Down := False;
    edScript.Enabled := sbPause.Down or not btStart.Down;
    edScript.ReadOnly := not edScript.Enabled or btStart.Down;
  end;
end;

{ Скрипт остановлен: обе кнопки отжаты, редактор разблокирован. }
procedure StopScriptThread(T: Pointer);
begin
  fmSecond.btStart.Down := False;
  fmSecond.sbPause.Down := False;
  fmSecond.sbPause.Enabled := False;
  fmSecond.edScript.Enabled := True;
  fmSecond.edScript.ReadOnly := False;
end;



{ Вывод накопленной строки лога: в окно лога, в мемо вкладки и в файл.

  Строка собирается из буфера T.LogBuf, а маска T.LogFlags гасит её части:
  1 -- время, 2 -- имя вкладки, 4 -- имя файла, 8 -- номер строки,
  $10 -- время с миллисекундами.

  Проверки ввода-вывода сняты нарочно: писать в лог мы можем откуда угодно,
  и падать на нём нельзя -- ошибка ловится общим try..except, который на
  второй раз гасит лог совсем.

  Обрезка окна лога пополам взводит Trimmed, и только тогда проверяется
  предел файла: FileSize у ТЕКСТОВОГО файла делит размер на BufSize, то есть
  считает буферами по 128 байт -- отсюда единицы gLogMaxSize. }
procedure WriteScriptLog(T: TScanThread);
{$I-}
var
  S, A, Pfx: string;
  Trimmed: Boolean;
  Num: string;
  L: Integer;
  Tab: TScanThread;
begin
  if T.LogLevel >= 1 then
  begin
    if fmSecond.miAutoOpenLog.Checked then
      if (gDlg5966F8 = nil) or not gDlg5966F8.Visible then
        fmSecond.miLogWindowClick(nil);
    if gCoordCaptured then
    begin
      S := TimeToStr(Time) + ' : ' + T.Msg;
      gCoordCaptured := False;
    end
    else
    begin
      if T.StopRequested then
        Exit;
      S := '';
      if T.LogBuf[0] <> #0 then
      begin
        if not T.LogCont then
        begin
          A := '';
          Pfx := '';
          Num := IntToStr(T.LineCount + T.LineBase);
          if T.LogPrefix <> '' then
            Pfx := T.LogPrefix + ' - ';
          if T.LogFlags = 0 then
            S := TimeToStr(Time) + ' ' + T.Name + ' (' + ExtractFileName(T.Title) +
              ', ' + Num + ')' + ': ' + Pfx + PChar(@T.LogBuf)
          else
          begin
            if T.LogFlags and 1 = 0 then
            begin
              if T.LogFlags and $10 = $10 then
                S := S + FormatDateTime('hh:nn:ss.zzz', Time) + ' '
              else
                S := S + TimeToStr(Time) + ' ';
            end;
            if T.LogFlags and 2 = 0 then
              S := S + T.Name;
            if T.LogFlags and 4 = 0 then
              A := A + ' (' + ExtractFileName(T.Title);
            if T.LogFlags and 8 = 0 then
            begin
              if A = '' then
                A := A + ' ('
              else
                A := A + ', ';
              A := A + Num;
            end;
            if A <> '' then
              A := A + ')';
            if T.LogFlags = $F then
              S := S + A + Pfx + PChar(@T.LogBuf)
            else
              S := S + A + ': ' + Pfx + PChar(@T.LogBuf);
          end;
        end
        else
          S := PChar(@T.LogBuf);
      end;
    end;
    FillChar(T.LogBuf, $4000, 0);
    Trimmed := False;
    if fmSecond.mLog.Lines.Count > $400 then
    begin
      L := Length(fmSecond.mLog.Lines.Text);
      fmSecond.mLog.Lines.Text := Copy(fmSecond.mLog.Lines.Text,
        PosEx(#13#10, fmSecond.mLog.Lines.Text, L div 2) + 2, L - L div 2);
      Trimmed := True;
    end;
    if not T.LogCont then
      fmSecond.mLog.Lines.Add(S)
    else
      with fmSecond.mLog.Lines do
        Strings[Count - 1] := Strings[Count - 1] + S;
    if T.LogToParent then
      Tab := T.Owner43D0
    else
      Tab := TScanThread(T.SelfRef);
    if Tab.LogView.Lines.Count > $400 then
    begin
      L := Length(Tab.LogView.Lines.Text);
      Tab.LogView.Lines.Text := Copy(Tab.LogView.Lines.Text,
        PosEx(#13#10, Tab.LogView.Lines.Text, L div 2) + 2, L - L div 2);
      Trimmed := True;
    end;
    if not Tab.LogCont then
      Tab.LogView.Lines.Add(S)
    else
      with Tab.LogView.Lines do
        Strings[Count - 1] := Strings[Count - 1] + S;
    if not gLogFileClosed then
    begin
      try
        if fmSecond.miLogging.Checked then
        begin
          if not gLogFileOpen then
            if FileExists(gLogFileName) then
              Append(gLogFile)
            else
              Rewrite(gLogFile);
          gLogFileOpen := True;
          if T.LogCrLf then
            { Write, а не Writeln: перевод строки дописываем сами, иначе
              на разных платформах он выйдет разным. }
            Write(gLogFile, S + #13 + #10)
          else
            Write(gLogFile, S);
          Flush(gLogFile);
          if Trimmed and (gLogMaxSize > 0) then
            if FileSize(gLogFile) > gLogMaxSize then
            begin
              CloseFile(gLogFile);
              S := gLogFileName + '.bak';
              if FileExists(S) then
                DeleteFile(S);
              RenameFile(gLogFileName, S);
              Rewrite(gLogFile);
            end;
        end;
      except
        fmSecond.mLog.Lines.Add('Can''t wrie to log file.');
        gLogFileClosed := True;
      end;
    end;
    T.LogCont := False;
    T.LogCrLf := True;
  end;
end;
{$I+}

{ Показать текст ошибки подсказкой над ярлыком вкладки и подержать её
  три секунды, прокачивая очередь сообщений. }
procedure TScriptThread.ShowScriptHint;
var
  H: TObject;
  Tick: Cardinal;
begin
  with fmSecond do
  begin
    tScript.Hint := Self.Msg;
    H := CreateTabHint(tScript);
  end;
  Tick := GetTickCount;
  repeat
    Application.ProcessMessages;
  until GetTickCount - Tick >= 3000;
  fmSecond.HideHintWindow(H);
end;


{ Выполнение блока `--lua ... -- endlua`: строки чанка поток собирает в
  T.LuaText и зовёт сюда. }
procedure RunLuaScript(T: TScanThread);
var
  S, M: string;
  Err: Integer;
  E, P1, P2, N, Cnt: Integer;
begin
  { Сначала объекту-обёртке отдаётся номер скрипта, потом в его lua_State
    регистрируются ВСЕ команды языка -- обработчик у всех один, он узнаёт
    себя по upvalue с именем, -- и только потом выполняется сам чанк. }
  TLua(T.DebugForm).ScriptNo := StrToInt(T.Name);
  TLua(T.DebugForm).RegP('findwindow', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('size', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('msg', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('say', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('send', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('macro_send', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('send217', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('sendex', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('drag', @LuaCmdHandler, 5);
  TLua(T.DebugForm).RegP('left', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('right', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('double_left', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('double_right', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('middle', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('double_middle', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('left_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('left_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('right_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('right_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('middle_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('middle_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('move', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('move_smooth', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kleft', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kright', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('double_kleft', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('double_kright', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kmiddle', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('double_kmiddle', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kleft_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kleft_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kright_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kright_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kmiddle_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('kmiddle_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('pleft', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('pright', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('double_pleft', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('double_pright', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('pmiddle', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('double_pmiddle', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('pleft_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('pleft_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('pright_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('pright_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('pmiddle_down', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('pmiddle_up', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('send_up', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('send217_up', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('send_down', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('send217_down', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('sendex_up', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('sendex_down', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('wheel_down', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('wheel_up', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('pwheel_down', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('pwheel_up', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('kwheel_down', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('kwheel_up', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('macro_load', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('macro_play', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('exec', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('terminate', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('wait', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('flash', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('alarm', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('end_script', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('pause_script', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('resume_script', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('stop_script', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('start_script', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('injection', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('load_array', @LuaCmdHandler, 8);
  TLua(T.DebugForm).RegP('save_array', @LuaCmdHandler, 6);
  TLua(T.DebugForm).RegP('showwindow', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('readmem', @LuaCmdHandler, 5);
  TLua(T.DebugForm).RegP('writemem', @LuaCmdHandler, 5);
  TLua(T.DebugForm).RegP('printscreen', @LuaCmdHandler, 6);
  TLua(T.DebugForm).RegP('post', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('post_up', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('post_down', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('load_script', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('execandwait', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('init_arr', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('log', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('pluginload', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('pluginreload', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('pluginunload', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('sort_array', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('delete_array', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('restart_script', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('keyboard', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('mouse', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('hint', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('filerename', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('filecopy', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('filedelete', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('filesetattr', @LuaCmdHandler, 5);
  TLua(T.DebugForm).RegP('filesetdate', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('dircreate', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('dirremove', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('dir', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('eval', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('write', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('exit', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('set', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('call', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('get', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('claqua', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clblack', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clblue', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('cldkgray', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clfuchsia', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clgray', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clgreen', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('cllime', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clltgray', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clmaroon', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clnavy', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clolive', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clpurple', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clred', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clsilver', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clteal', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clwhite', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('clyellow', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('windowhandle', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('loghandle', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('windowpos', @LuaCmdHandler, 5);
  TLua(T.DebugForm).RegP('mouse_pos', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('year', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('month', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('day', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('priority', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('linedelay', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('clipboard', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('logging', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('getlayout', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('windowfromcursor', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('getselectedtext', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('scripts', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('current_script', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('active_script', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('defcolor', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('defx', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('defy', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('defxabs', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('defyabs', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('screenheight', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('screenwidth', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('desktopheight', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('desktopwidth', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('monitorheight', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('monitorwidth', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('monitor', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('mousepos_x', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('mousepos_y', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('mouseposabs_x', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('mouseposabs_y', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('pi', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('hotkeystart', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('hotkeypause', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('min', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('hour', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('sec', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('timer', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('timer1', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('timer2', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('timer3', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('timer4', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('logautoopen', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('messagesoutputto', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('getfocus', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('name', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('gold', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('wght', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('armor', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('hits', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('mana', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('stam', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lastmsg', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('str', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('int', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('dex', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('chardir', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lastobjectid', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lastobjecttype', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lasttargetid', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lasttargetx', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lasttargety', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lasttargetz', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lasttargetkind', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lastliftedid', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lastskill', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('lastspell', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('laststatictype', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('war', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('arun', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('target', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('charposx', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('charposy', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('charposz', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('hidden', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('findwindow', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('random', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('getwindow', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('getwindowtext', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('color', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('prompt', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('setwindowtext', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('findcolor', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('size', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('setlayout', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('setselectedtext', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('hex2dec', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('dec2hex', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('findimage', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('posex', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('copy', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('delete', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('insert', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('indexof', @LuaCmdHandler, 7);
  TLua(T.DebugForm).RegP('fileexists', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('filegetattr', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('filegetdate', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('windowfrompoint', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('abs', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('round', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('floor', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('ceil', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('frac', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('sqrt', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('power', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('exp', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('ln', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('log', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('sin', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('cos', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('tan', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('arcsin', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('arccos', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('arctan', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('degtorad', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('radtodeg', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('trunc', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('minx', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('maxx', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('mean', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('mod', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('point_distance', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('point_direction', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('lengthdir_x', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('lengthdir_y', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('is_real', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('is_string', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('chr', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('ord', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('string_replace', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('string_count', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('string_lower', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('string_upper', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('string_letters', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('string_digits', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('dayofweek', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('eval', @LuaCmdHandler, 20);
  TLua(T.DebugForm).RegP('colortorgb', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('colortored', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('colortogreen', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('colortoblue', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('ltrim', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('rtrim', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('trim', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('div', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('regexp', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('chartohex', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('chartohexf', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('moduleaddress', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('arrayaddress', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('sendmessage', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('postmessage', @LuaCmdHandler, 4);
  TLua(T.DebugForm).RegP('getimage', @LuaCmdHandler, 6);
  TLua(T.DebugForm).RegP('deleteimage', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('loadimage', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('saveimage', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('relativeaddress2absolute', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('absoluteaddress2relative', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('setprocesspriority', @LuaCmdHandler, 2);
  TLua(T.DebugForm).RegP('getprocesspriority', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('checkgetcolor', @LuaCmdHandler, 3);
  TLua(T.DebugForm).RegP('version', @LuaCmdHandler, 0);
  TLua(T.DebugForm).RegP('suspendprocess', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('resumeprocess', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('workwindow', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('errorlevel', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('terminated', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('delimiter', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('workwindowpid', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('homepath', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('exefilename', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('clickoffsetx', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('clickoffsety', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('findoffsetx', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('findoffsety', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('sendexdelay', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('mouseclickdelay', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('promptpos_x', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('promptpos_y', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('scriptPath', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('scriptName', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('get_script_text', @LuaCmdHandler, 1);
  TLua(T.DebugForm).RegP('set_script_text', @LuaCmdHandler, 2);
  Err := 0;
  M := '';
  try
    Inc(Err, LuaDoString(TLua(T.DebugForm).Handle, PChar(T.LuaText)));
  except
    on EAccessViolation do
    begin
      E := GetLastError;
      if E = 0 then
        Err := 0
      else
      begin
        T.Msg := SysErrorMessage(E);
        ShowScriptError(TScriptThread(T));
      end;
    end;
    on Ex: Exception do
    begin
      Err := 99;
      M := Ex.Message;
    end;
  end;
  if Err = 0 then
    Exit;
  { прерывание по кнопке «стоп» -- не ошибка скрипта, о ней не сообщаем }
  if (Err = 2) and T.StopRequested and not T.Flag91 then
    Exit;
  T.StopRequested := True;
  if Err in [0..6] then
    S := PLuaStatus^[Err] + #13#10
  else
    S := 'Lua error.'#13#10 + M;
  if gLuaIsString(TLua(T.DebugForm).Handle, -1) <> 0 then
    S := S + gLuaToLString(TLua(T.DebugForm).Handle, -1, nil);
  { в тексте ошибки Lua номер строки стоит между `]:` и `:` }
  P1 := Pos(']:', S);
  if P1 > 0 then
  begin
    P2 := PosEx(']:', S, P1 + 2) + 1;
    N := StrToIntDef(Copy(S, P1 + 2, P2 - P1 - 2), 0) - 4;
    if N < 0 then
      N := 0;
    Cnt := 5;
    while (N < Length(T.Lines)) and (Cnt > 0) do
    begin
      S := S + #10 + T.Lines[N];
      Inc(N);
      Dec(Cnt);
    end;
  end;
  T.Msg := FixLineBreaks(S) + #0;
  T.Msg := StringReplace(T.Msg, '[string "--lua..."]:', '',
    [rfReplaceAll, rfIgnoreCase]);
  if T.StopRequested then
  begin
    T.StopRequested := False;
    ShowScriptError(TScriptThread(T));
    T.StopRequested := True;
  end
  else
    ShowScriptError(TScriptThread(T));
end;

end.
