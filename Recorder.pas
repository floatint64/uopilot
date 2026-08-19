// TRecorder
//
// cyamon software
// place de l'Hфtel-de-Ville 8
// 1040 Echallens
// Switzerland
// www.cyamon.com

// 11/99

// This unit is a freeware. You may change it, use it in your applications
// at your own risks.

// The recorder is an object that allows to record and play back mouse and
// keyboard events. The recorder is not a component, it is instead a singleton
// that is created and destroyed automatically in the initialization and
// finalization parts of this unit. The recorded information is saved into a
// memory stream.

// The recorder exports the following properties and methods:

// property State (Read only) is the recorder's state (idle, recording or playing).

// property SpeedFactor is the factor (in %) by which the playback speed is modified.
// Values < 100 accelerate, and values > 100 slowdown.

// property OnStateChange is an event that is fired when the state changes.

// procedure DoRecord(Append : boolean);
// Starts recording. When "Append" is true the new recorded information is appended
// to information already stored in the local stream. Otherwise, the local stream is
// clared before recording.

// procedure DoPlay;
// Plays the recorded information

// procedure DoStop;
// Stops recording and/or to playing

unit Recorder;

interface
  uses
    Classes, Windows;

  type
    TRecorderState = (rsIdle, rsRecording, rsPlaying);
    TStateChangeEvent = procedure(NewState : TRecorderState) of object;

    TRecorder = class(TObject)
    public
      { Поля открыты нарочно: Unit1 читает EventMsg и FStream напрямую. }
      FState : TRecorderState;
      HookHandle : THandle;
      BaseTime : integer;
      FSpeedFactor : integer;
      Tag : integer;
      FOnStateChange : TStateChangeEvent;
      EventMsg : TEVENTMSG;
      { 777 -- играть без конца, иначе это счётчик повторов. }
      FRepeatCount : Integer;
      FStream : TStream;
      procedure SetSpeedFactor(const Value: integer);
      constructor Create;
      destructor Destroy; override;
      procedure SetState(const Value: TRecorderState);
      procedure DoPlay;
      procedure DoRecord(Append : boolean);
      procedure DoStop;
      property SpeedFactor : integer read FSpeedFactor write SetSpeedFactor;
      property OnStateChange : TStateChangeEvent read FOnStateChange write FOnStateChange;
      property State : TRecorderState read FState;
      property Stream : TStream read FStream;
    end;

  var
    TheRecorder : TRecorder;

    { Залипшие модификаторы макроса: их взводят @ ^ ~ в строке. }
    gMacAlt: Boolean;
    gMacCtrl: Boolean;
    gMacShift: Boolean;

  { Набрать макрос из строки прямо в поток записи. }
  function MacroFileLoad(S: string): Integer;

implementation
  uses
    SysUtils, Messages, HotKeyMgr, Keydefs, Unit1;
{~t}
(************)
(* PlayProc *)
(************)

function PlayProc(Code : integer; Undefined : WPARAM; P : LPARAM) : LRESULT; stdcall;
var
  T : Cardinal;
begin
  Result := 0;
  if Code < 0 then
    Result := CallNextHookEx(TheRecorder.HookHandle, Code, Undefined, P)
  else begin
    case Code of
      HC_SKIP: begin
        if TheRecorder.FStream.Position < TheRecorder.FStream.Size then begin
          TheRecorder.FStream.Read(TheRecorder.EventMsg, SizeOf(TheRecorder.EventMsg));
          TheRecorder.EventMsg.Time := TheRecorder.SpeedFactor*(TheRecorder.EventMsg.Time div 100)
            + TheRecorder.BaseTime;
        end else begin //stop
          TheRecorder.SetState(rsIdle);


	if TheRecorder.FRepeatCount=777 then begin TheRecorder.DoPlay; exit; end;
	TheRecorder.FRepeatCount:=TheRecorder.FRepeatCount-1;
	if TheRecorder.FRepeatCount>0 then  TheRecorder.DoPlay;  
		    end;
      end;

      HC_GETNEXT: begin
        T := GetTickCount();
        if T < TheRecorder.EventMsg.Time then
          Result := TheRecorder.EventMsg.Time - T
        else
          Result := 0;
        PEVENTMSG(P)^ := TheRecorder.EventMsg;
      end;
    else
      PEVENTMSG(P)^ := TheRecorder.EventMsg;
      Result := CallNextHookEx(TheRecorder.HookHandle, Code, Undefined, P)
    end {case};
  end {if};

end {PlayProc};


(**************)
(* RecordProc *)
(**************)

function RecordProc(Code : integer; Undefined : WPARAM; P : LPARAM) : LRESULT; stdcall;
begin
  Result := 0;
  if Code < 0 then
    Result := CallNextHookEx(TheRecorder.HookHandle, Code, Undefined, P)
  else begin
    case Code of
      HC_ACTION: begin
        TheRecorder.EventMsg := PEVENTMSG(P)^;
        TheRecorder.EventMsg.Time := TheRecorder.EventMsg.Time-TheRecorder.BaseTime;
        if (TheRecorder.EventMsg.Message >= WM_KEYFIRST) and (TheRecorder.EventMsg.Message <= WM_KEYLAST) and
          (LoByte(TheRecorder.EventMsg.ParamL) = VK_CANCEL) then begin
          // Recording aborted by ctrl-Break
          TheRecorder.SetState(rsIdle);
        end {if};
        TheRecorder.FStream.Write(TheRecorder.EventMsg, sizeOf(TheRecorder.EventMsg));
      end;
      HC_SYSMODALON:;
      HC_SYSMODALOFF:
    end {case};
  end {if};
end {RecordProc};


(********************)
(* TRecorder.Create *)
(********************)

constructor TRecorder.Create;
begin
  if TheRecorder = nil then begin
    FStream := TMemoryStream.Create;
    FSpeedFactor := 100;
  end else
    Fail;
end {TRecorder.Create};


(*********************)
(* TRecorder.Destroy *)
(*********************)

destructor TRecorder.Destroy;
begin
  DoStop;
  FStream.Free;
  inherited;
end {TRecorder.Destroy};


(********************)
(* TRecorder.DoPlay *)
(********************)

procedure TRecorder.DoPlay;
begin
  if State <> rsIdle then
    raise Exception.Create('Recorder: Not ready to play.')
  else if FStream.Size = 0 then
    raise Exception.Create('Recorder: Nothing to play')
  else begin
    FStream.Seek(0,0);
    FStream.Read(EventMsg, SizeOf(EventMsg));
    HookHandle := SetWindowsHookEx(WH_JOURNALPLAYBACK, @PlayProc, hInstance, 0);
    if HookHandle = 0 then
      raise Exception.Create('Playback hook cannot be created')
    else begin
      BaseTime := GetTickCount();
      SetState(rsPlaying);
    end {if};
  end {if};
end {TRecorder.DoPlay};


(**********************)
(* TRecorder.DoRecord *)
(**********************)

procedure TRecorder.DoRecord(Append : boolean);
var
  Err : Integer;
begin
  if State <> rsIdle then
    raise Exception.Create('Recorder: NotReady to record.')
  else begin
    if not Append then begin
      FStream.Size := 0;
      BaseTime := GetTickCount();
    end else 
begin
      EventMsg.Time := 0;
      if FStream.Size > 0 then begin
        FStream.Seek(-SizeOf(EventMsg),soFromCurrent);
        FStream.Read(TheRecorder.EventMsg, SizeOf(EventMsg));
      end {if};
      BaseTime := GetTickCount() - EventMsg.Time;
    end {if};
    HookHandle := SetWindowsHookEx(WH_JOURNALRECORD, @RecordProc, hInstance, 0);
    { Ошибку снимаем сразу: до сообщения её успеет затереть что угодно. }
    Err := GetLastError;
    if HookHandle = 0 then
      raise Exception.Create('JournalHook cannot be created: ' + SysErrorMessage(Err))
    else begin
      SetState(rsRecording);
    end {if};
  end {if};
end {TRecorder.DoRecord};


(********************)
(* TRecorder.DoStop *)
(********************)

procedure TRecorder.DoStop;
begin
 SetState(rsIdle);
end {TRecorder.DoStop};


(****************************)
(* TRecorder.SetSpeedFactor *)
(****************************)

procedure TRecorder.SetSpeedFactor(const Value: integer);
begin
  { Ноль и отрицательное отбрасываем одним сравнением. }
  if Cardinal(Value) > 0 then
    FSpeedFactor := Value;
end {TRecorder.SetSpeedFactor};


(**********************)
(* TRecorder.SetState *)
(**********************)

procedure TRecorder.SetState(const Value: TRecorderState);
begin
  if (Value = rsIdle) and (HookHandle <> THandle(0)) then begin
    UnhookWindowsHookEx(HookHandle);
    HookHandle := THandle(0);
  end {if};
  if Value <> FState then begin
    FState := Value;
    if Assigned(FOnStateChange) then
      FOnStateChange(FState)
  end {if};
end {TRecorder.SetState};


{ Код клавиши и скан-код в одно слово: младший байт -- сам код. }
function MakeKeyCode(A, B: Byte): Word;
var
  W: Word;
begin
  W := B;
  W := A or (W shl 8);
  Result := W;
end;

{ Дописать одно событие клавиатуры в поток записи. Время считаем от
  длины потока: шаг 50 мс на событие, чтобы проигрывалось ровно. }
procedure RecKey(V: Byte; Msg: Word);
begin
  TheRecorder.EventMsg.message := Msg;
  TheRecorder.EventMsg.paramL := MakeKeyCode(V, MapVirtualKey(V, 0));
  TheRecorder.EventMsg.paramH := MapVirtualKey(V, 0);
  TheRecorder.EventMsg.time :=
    (TheRecorder.FStream.Size div SizeOf(TEVENTMSG)) * 50;
  TheRecorder.EventMsg.hwnd := 0;
  TheRecorder.FStream.Write(TheRecorder.EventMsg, SizeOf(TEVENTMSG));
end;

{ Нажатие. При зажатом Alt (и не Ctrl) буквы и F1..F12 обязаны идти
  СИСТЕМНЫМ сообщением, иначе окно их не примет; сам Alt -- всегда
  системным. }
procedure KeyDown(V: Byte);
begin
  if gMacAlt and not gMacCtrl and (V in [$41..$5A, $70..$7B])
    or (V = VK_MENU) then
    RecKey(V, WM_SYSKEYDOWN)
  else
    RecKey(V, WM_KEYDOWN);
end;

{ Отпускание. От нажатия отличается тем, что сам Alt отпускается
  обычным сообщением. }
procedure KeyUp(V: Byte);
begin
  if gMacAlt and not gMacCtrl and (V in [$41..$5A, $70..$7B]) then
    RecKey(V, WM_SYSKEYUP)
  else
    RecKey(V, WM_KEYUP);
end;

{ Проиграть код клавиши со всеми модификаторами. Старший байт слова --
  то, что вернул VkKeyScan: бит 1 в нём означает, что символ набирается
  с Shift. Shift давим по нему (и только если не зажат Ctrl) либо по
  флагу '~'. }
procedure PlayKeyCode(W: Word);
var
  bVK: Byte;
begin
  if gMacAlt then
    KeyDown(VK_MENU);
  if gMacCtrl then
    KeyDown(VK_CONTROL);
  if (Hi(W) and 1 <> 0) and not gMacCtrl or gMacShift then
    KeyDown(VK_SHIFT);
  bVK := W and $FF;
  KeyDown(bVK);
  KeyUp(bVK);
  if (Hi(W) and 1 <> 0) and not gMacCtrl or gMacShift then
    KeyUp(VK_SHIFT);
  if gMacShift then
    gMacShift := False;
  if gMacCtrl then
  begin
    KeyUp(VK_CONTROL);
    gMacCtrl := False;
  end;
  if gMacAlt then
  begin
    KeyUp(VK_MENU);
    gMacAlt := False;
  end;
end;

{ Имя клавиши в фигурных скобках, @ ^ ~ -- Alt/Ctrl/Shift, всё прочее --
  символ через VkKeyScan. Итог: 0 -- разобрано, 2 -- негодная скобка. }
function MacroFileLoad(S: string): Integer;
var
  bVK: Byte;
  sKey: string[7];
  nI: Integer;
  cC: Char;
  wK: Word;
begin
  TMemoryStream(TheRecorder.Stream).Clear;
  TheRecorder.DoStop;
  Result := 0;
  nI := 1;
  repeat
    cC := S[nI];
    case cC of
      '{':
        begin
          sKey := '';
          Inc(nI);
          while S[nI] <> '}' do
          begin
            sKey := sKey + S[nI];
            Inc(nI);
            if Length(sKey) > 12 then
              if S[nI] <> '}' then
              begin
                Result := 2;
                Exit;
              end;
          end;
          if not TextToVKey(sKey, bVK) then
          begin
            Result := 2;
            Exit;
          end;
          PlayKeyCode(MakeKeyCode(bVK, 0));
        end;
      '@': gMacAlt := True;
      '^': gMacCtrl := True;
      '~': gMacShift := True;
    else
    begin
      wK := VkKeyScan(cC);
      PlayKeyCode(wK);
    end;
    end;
    Inc(nI);
  until nI > Length(S);
end;

{~b}
initialization
  TheRecorder := nil;
  TheRecorder := TRecorder.Create;
finalization
  TheRecorder.Free;
end.
