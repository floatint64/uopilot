unit uScanThread;

{ Рабочий поток скрипта и всё, что ему нужно: своё окно подсказки,
  таймеры-долбилки, разбор и выполнение команд.

  Окно подсказки сделано на базе TRxHintWindow из RX Library, но сильно
  урезано и переделано под себя:

  * тень и «хвост» не рисуются, поэтому второй TBitmap не нужен --
  остался один FImage;
  * регион всегда прямоугольный (CreateRectRgnIndirect), round-rect и
  эллипс выброшены вместе с CreateRegion;
  * FillRegion принимает один параметр -- ветки Shade нет;
  * CalcHintRect считает по ширине экрана, а не по MaxWidth, и вдобавок
  выравнивает ширину вверх до кратной 16;
  * добавлен WMNCHitTest, которого в RxLib нет;
  * конструктор подменяет обработчик родителя, сохраняя прежний в
  FSavedWndProc. }

interface

uses LangClipboard, Types, geScale, SynMemo, {$IFnDEF FPC}FastMM4,{$ENDIF} {$IFnDEF FPC}jpeg,{$ENDIF} Recorder, MyIniFiles, mySys, awMachMask, PerlRegEx, SynHighlighterPas, SynEditCodeFolding, SynEditHighlighter, SynEditMiscClasses, SynEditTypes, TlHelp32, PngGDIP, GDIPAPI, GDIPOBJ, SynEdit, Unit2, lualib, ActiveX, Buttons, Classes, Clipbrd, ComCtrls, Controls, Dialogs, ExtCtrls, Forms, Graphics, IniFiles, MMSystem, Menus, Messages, Registry, ShellAPI, StdCtrls, StrUtils, SyncObjs, SysUtils, WinInet, Windows;
type
  { Пользовательская переменная: одна строка. Создаётся в
    Unit1.AfterOptionsLoaded по секции CustomVariables. }
  TMyStr = class(TObject)
  public
    Text: string;
  end;

  TLockZ = packed record             { итог GdipBitmapLockBits }
      W: Integer;
      H: Integer;
      Stride: Integer;
      Handle: THandle;
      Flag: Boolean;
  end;

  { Узел списка вещей рюкзака -- читается из памяти клиента как есть,
    поэтому неиспользуемые куски оставлены заполнителями. }
  TBackpackZ = packed record
      Alive:  Integer;               { узел жив }
      f04:    array[1..$20] of Byte;
      w24:    Word;
      w26:    Word;
      f28:    array[1..$14] of Byte;
      w3C:    Word;
      f3E:    array[1..2] of Byte;
      w40:    Word;
      w42:    Word;
      f44:    array[1..4] of Byte;
      d48:    Integer;
      f4C:    array[1..$30] of Byte;
      d7C:    Cardinal;
      Key:    Cardinal;              { ключ сравнения }
      f84:    array[1..4] of Byte;
      Next:   Integer;               { следующий узел }
      f8C:    array[1..$28] of Byte;
  end;

  TvarS = packed record
    Name: string[255];
    Value: string;                     // (строка, не число)
  end;

  TvArray = packed record
    Name: string[255];                 // имя без ведущего %
    Data: array of array of string;
  end;
  TTimerThread = class(TThread)
  public
    FStop: Boolean;                    // просьба прекратить
    FDone: Boolean;                    // поток отработал
    FWnd: Cardinal;                    // окно клиента
    FKey: Integer;                     // wParam клавиши
    FChar: Integer;                    // символ для WM_CHAR, 0 -- не слать
    FLParam: Cardinal;                 // lParam (Cardinal: | $C0000000)
    FDelay: Cardinal;                  // срок в тиках
    FSlot: Pointer;                    // адрес ячейки массива
    FFiller5C: Integer;
    FSend: Boolean;                    // Send вместо Post
  protected
    procedure Execute; override;
  end;

  TTimerThreadEx = class(TThread)
  public
    FStop: Boolean;
    FDone: Boolean;
    FWnd: Cardinal;                    // окно клиента
    FNum: Integer;
    FStr: string;                      // посылаемая строка
    FScript: Pointer;                  // объект скрипта (+$43D8)
    FMode: Integer;
    FDelay: Cardinal;                  // срок в тиках
    FSlot: Pointer;                    // адрес ячейки массива
    FFiller60: Integer;
  protected
    procedure Execute; override;
  end;

  TRxHintWindow = class(THintWindow)
  private
    FImage: Graphics.TBitmap;
    FRect: TRect;
    FTextRect: TRect;                 { прямоугольник текста }
    FSavedWndProc: TWndMethod;        { прежняя оконная процедура }
    FHintText: PChar;
    { +$24C и +$24D в разобранных методах не встречаются, но два байта здесь
      обязаны быть: без них флаги съезжают на $24C/$24D вместо $24E/$24F.
      В RxLib на этом месте FPos: THintPos, так что имена взяты по аналогии. }
    FPos: Byte;
    FStyle: Byte;
    FUseFixedSize: Boolean;
    FActive: Boolean;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure FillRegion(Rgn: HRgn);
    procedure HookWndProc(var Message: TMessage);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ActivateHint(Rect: TRect; const AHint: string); override;
  end;

  { Таймеры-долбилки: пока не вышел срок и не снят FStop, шлют в окно
    клиента клавишу (первый) или строку (второй). FSlot -- адрес ячейки
    массива, в которой лежит сам поток: по ней он себя оттуда и убирает,
    отработав. }

  TmsgHintParam = packed record
    Size: Integer;                     // <0 -- девятка
    Color: Integer;                    // <0 -- clInfoText
    Left: Integer;                     // -1 -- не задан
    Top: Integer;
    Width: Integer;
    Height: Integer;
    Back: Integer;                     // цвет окна
    Style: string;                     // буквы b i u s
    Font: string;                      // имя шрифта
    Text: string;                      // текст подсказки
  end;

  TParams = packed record
    Kind: Integer;
    Val: Integer;
    Str: string;
  end;

  arrayOfString = array of string;



  { Набор модификаторов горячей клавиши. }
  THKModsZ = set of (hkShiftZ, hkAltZ, hkCtrlZ);

  TLoopRec = packed record
    Name: string[255];
    Step: Integer;                     // шаг (4-е выражение)
    Limit: Integer;                    // предел (3-е выражение)
    Line: Integer;                     // строка самого for
    EndLine: Integer;                  // строка end_for
  end;

  TRepeatRec = packed record
    Line: Integer;                     // строка самого repeat
    EndLine: Integer;                  // строка end_repeat
    Count: Integer;                    // сколько повторов
  end;

  TGosubRec = packed record
    Line: Integer;                     // строка вызова
    ForIdx: Integer;                   // вершина Arr50 или -1
    RepIdx: Integer;                   // вершина Arr54 или -1
  end;

  TScriptVar = packed record
    Name: string[255];                 // имя без ведущего #
    Value: Int64;
  end;

  TScriptBlock = packed record
    W: Integer;                        // ширина
    H: Integer;                        // высота
    Bits: Integer;                     // указатель на биты
    Stride: Integer;                   // шаг строки
    Extra: Integer;
    Handle: THandle;                   // GlobalFree
  end;

  { Дальше идут классы, у которых раскладка полей задана жёстко: заполнители
    держат смещения, поэтому переставлять и вставлять поля нельзя.
    Первые $40 байт занимает сам TThread (FHandle, FSuspended,
    FFreeOnTerminate, OnTerminate), свои поля начинаются с +$40. }
  TRxHintWindowRef = class(THintWindow)
  public
    Filler218: array[$218..$24B] of Byte;
    Busy: Boolean;
    Filler24D: array[$24D..$24F] of Byte;
  end;

  { Ответ подключаемой функции. Запись упакованная: поля лежат вплотную и
    адресуются прямо по смещению, без арифметики над указателем. Len именно
    Cardinal -- сравнение с Length() должно идти через Int64. }
  PPlugRec = ^TPlugRec;

  TPlugRec = packed record
    Flag: Byte;                        // +0  ответ есть/нет
    Len:  Cardinal;                    // +1  длина ответа
    Ptr:  Integer;                     // +5  адрес строки ответа
  end;

  TScanThread = class(TThread)
  public
    Vars: array of TScriptVar;
    Timers: array of TvarS;
    Arr48: array of TvArray;
    VarNames: TStrings;
    Arr50: array of TLoopRec;          // стек циклов
    Arr54: array of TRepeatRec;        // стек repeat
    Arr58: array of TGosubRec;         // стек gosub
    PromptKind: string;                // '#' / '$' / '%'
    PromptTime: Integer;               // секунд до закрытия
    VarTimer: TTimer;
    RegEx: TObject;                    // TPerlRegEx
    Blocks: array of TScriptBlock;
    ShowWait: Boolean;
    StopRequested: Boolean;
    Filler72: array[$72..$73] of Byte;
    Title: string;                     // полный путь файла
    FilePath: string;
    FileTitle: string;
    Lines: arrayOfString;
    ClientWnd: HWND;                   // окно клиента у скрипта
    ProcessHandle: THandle;
    ProcessId: DWORD;
    AutoStart: Boolean;
    Flag91: Boolean;
    Paused: Boolean;
    Debug: Boolean;
    LineCount: Integer;                // номер текущей строки
    StartLine: Integer;
    Msg: string[255];
    LogBuf: array[0..$3FFF] of Char;
    ClVerIdx: Byte;                    // cbClVer.ItemIndex
    NtUserIdx: Byte;                   // cbNtUserPM.ItemIndex
    VarGridBusy: Boolean;
    VarName: string[255];
    VarValue: string[255];
    Filler439F: array[$439F..$439F] of Byte;
    VarRow: Integer;
    VarNameNew: Boolean;
    Filler43A5: array[$43A5..$43A7] of Byte;
    StartTick: Cardinal;
    Tick1: Cardinal;
    Tick2: Cardinal;
    Tick3: Cardinal;
    Tick4: Cardinal;
    NextVarGrid: Cardinal;
    LogToParent: Boolean;              // писать в лог вкладки-хозяина
    Filler43C1: array[$43C1..$43C3] of Byte;
    ClientWnd2: HWND;
    ProcessHandle2: THandle;
    ThreadId: DWORD;
    Owner43D0: TScanThread;            // вкладка-хозяин
    Root43D4: Pointer;                  // корневая вкладка
    SelfRef: Pointer;                  // ссылка на себя же
    Name: string;                      // имя вкладки
    Str43E0: string;
    PromptWnd: TForm;
    FoundWnd: HWND;                    // ответ EnumWindows
    FindPid: DWORD;                    // искомый процесс
    Arr43F0: array of string;
    Params: string;
    ProcName: string;                  // имя процедуры
    Obj43FC: TObject;                  // FreeAndNil
    Filler4400: array[$4400..$4403] of Byte;
    HKMods: THKModsZ;
    IsProc: Boolean;                   // запущено как процедура
    LogFlags: Word;
    Workers: array[1..10] of TTimerThread;
    Workers2: array[1..10] of TTimerThreadEx;
    Masks: tMatchMaskList;             // FreeAndNil
    WinListText: string;               // подпись рабочего окна
    MemTarget: string;
    MemTarget2: string;
    Obj4468: TObject;                  // .Free в деструкторе
    Obj446C: TObject;                  // .Free в деструкторе
    ScreenBmp: Graphics.TBitmap;
    CapW: Integer;
    CapH: Integer;
    Filler447C: array[$447C..$447F] of Byte;
    ImgFile: string;
    ShotW: Integer;                    // = CapTo.X - CapFrom.X
    ShotH: Integer;                    // = CapTo.Y - CapFrom.Y
    ShotFailed: Boolean;
    Filler448D: array[$448D..$448F] of Byte;
    ImgPts: array of Cardinal;
    ImgTol: array of Integer;
    ImgList: array of array of Integer;
    CapWnd: HWND;                      // ($02 -- снимать с экрана)
    Fld44A0: Integer;
    Filler44A4: array[$44A4..$44AB] of Byte;
    ShotBits: Pointer;                 // буфер строк 24-бит
    Filler44B0: array[$44B0..$44B3] of Byte;
    ShotSize: Integer;                 // Abs(Height * Stride)
    CapTo: TPoint;
    CapFrom: TPoint;
    Fld44C8: Integer;
    ShotCount: Integer;
    ImgFmt: Integer;
    Filler44D4: array[$44D4..$44DB] of Byte;
    { Поле нигде не используется, но тип у него именно строковый: место под
      него должно быть управляемым, иначе съедет раскладка. }
    Fld44DC: string;
    BottomUp: Boolean;                 // Stride > 0
    Filler44E1: array[$44E1..$44E3] of Byte;
    LogPrefix: string;                 // приставка к строке лога
    CaretX: Integer;
    CaretY: Integer;
    { stdcall, а не cdecl: довод со стека снимает сама функция. }
    PlugFunc: procedure(P: Pointer); stdcall;
    PlugProc: THandle;
    PlugPid: DWORD;
    PlugRec: PPlugRec;
    PlugStr1: PChar;
    PlugStr2: PChar;
    { Буфер обмена с плагином -- массив СИМВОЛОВ, а не байтов: тогда
      `V := T.PlugBuf` берётся одним LStrFromArray. Ответ плагина -- отдельное
      поле сразу за буфером, а не хвост того же массива. }
    { Индекс обязан начинаться с нуля: только нуль-базовый массив символов
      считается нуль-терминированным буфером и берётся через LStrFromArray;
      с любым другим началом получится LStrFromPCharLen и лишняя длина. }
    PlugBuf: array[0..$100000] of Char;
    PlugRes: TPlugRec;
    Filler104512: array[$104512..$10452F] of Byte;
    Modified: Boolean;
    Filler104531: array[$104531..$104533] of Byte;
    ClipLen: Integer;
    ShowRemainingWait: Boolean;
    ShowTimerVar: Boolean;
    Filler10453A: array[$10453A..$10453B] of Byte;
    TabCount: Integer;
    TabList: TStringList;
    ShowAllWnd: Boolean;
    Filler104545: array[$104545..$104547] of Byte;
    LogView: TMemo;                    // мемо вкладки
    SubScript: TScanThread;
    ToMsgBox: Boolean;
    StopOnPause: Boolean;
    Filler104552: array[$104552..$104553] of Byte;
    CtlId: Integer;                    // номер величины
    CtlValue: Integer;                 // числовое значение
    CtlText: string[255];              // текстовое значение
    LineBase: Integer;                 // сдвиг нумерации строк
    LoggingCommands: Boolean;
    Filler104661: array[$104661..$104663] of Byte;
    LogLevel: Integer;                 // 0 -- лог выключен
    OldLogProc: TWndMethod;
    HoldKey: Boolean;
    Filler104671: array[$104671..$104673] of Byte;
    Cnt104674: Integer;
    Cnt104678: Integer;
    Cnt10467C: Integer;
    Cnt104680: Integer;
    PauseCmd: string[255];
    PauseStr: string[255];
    SendDelay: Integer;                // seSendExDelayDef
    ClickDelay: Integer;               // seMouseClicksDelay
    Fld10488C: Integer;                // = $104
    Fld104890: Integer;                // = $DB
    LogCont: Boolean;                  // дописать к прошлой строке
    LogCrLf: Boolean;                  // добавить перевод строки
    Filler104896: array[$104896..$104897] of Byte;
    Arr104898: array of Char;
    ShowRun: Boolean;                  // sbScriptProcessing.Down
    Filler10489D: array[$10489D..$1048A4] of Byte;
    Lock: TLockZ;
    Filler1048B6: array[$1048B6..$1048B7] of Byte;
    Str1048B8: string;
    CmdCount: Integer;
    Filler1048C0: array[$1048C0..$1050BF] of Byte;
    CmdList: array[0..0] of string[255];
    CmdParts: array[0..9] of string[255];
    WordPos: Integer;
    CmdLine: Integer;
    Cnt105BC8: Integer;
    ClProc: THandle;
    Line: string;
    CurLine: Integer;
    RestartFlag: Boolean;
    RepeatLine: Boolean;
    RepeatCmd: Boolean;
    SubstAdvance: Boolean;             // сдвигать ли позицию после подстановки
    ParenPos: Integer;
    CmdArg: string;
    CmdArg2: string;
    DebugForm: TForm;                  // (на деле TLua)
    LuaCalcStr: string;
    Filler105BF0: array[$105BF0..$105BF4] of Byte;
    InLua: Boolean;                    // идёт lua-блок
    Filler105BF6: array[$105BF6..$105BF7] of Byte;
    RxLen: string;
    RxSub: string;
    LuaRes1: Integer;                  // итог get для lua
    LuaRes2: Integer;
    LuaRes3: Integer;
    LuaRes4: Integer;
    LuaRes5: Integer;
    Filler105C14: array[$105C14..$105C17] of Byte;
    Filler105C18: array[$105C18..$105C27] of Byte;
    DirMask: array[0..9] of string;
    Args: array[0..20] of TParams;      { шаг $C }
    HasArgs: Boolean;
    LuaUnclosed: Boolean;              // нет -- endlua
    Filler105D4E: array[$105D4E..$105D4F] of Byte;
    Backpack: TBackpackZ;
    Filler105E04: array[$105E04..$105E07] of Byte;
    PerfFreq: Int64;
    HintWnd: TRxHintWindowRef;            // окно подсказки
    Hint: TmsgHintParam;
    Timer: TTimer;                     // интервал $FA0
  protected
    procedure Execute; override;
  public
    procedure LogWndProc(var Message: TMessage);
    destructor Destroy; override;
    procedure CaptureWindowBits;
    procedure ShowScriptHint;
    procedure SyncShowRunLine;
    procedure PauseScriptThread;
    procedure AfterScriptStarted;
    procedure ResumeScriptThread;
    procedure StopScriptThread;
    procedure SyncAddScriptTab;
    procedure SyncScriptChanging;
    procedure SyncScriptChange;
    procedure SyncRestoreCaret;
    procedure SyncCreateWindow;
    procedure SyncGetControlText;
    procedure SyncShowHint;
    procedure SyncSetHotKey;
    procedure SyncShowLogWin;
    procedure PrepareScreenBitmap;
    function ScriptStrToInt(S: string): Integer;
    constructor NewScriptTab(CreateSuspended: Boolean);
    procedure SyncLogMsg;
    procedure WriteScriptLog;
    procedure SyncShowWait;
    procedure SyncUpdateVarGrid;
    procedure SyncGetTabCount;
    procedure SyncGetTabNames;
    procedure SyncShowAllWnd;
    procedure SyncLoadPlugin;
    procedure SyncUnloadPlugin;
    procedure SyncReloadPlugin;
    procedure SyncHideHint;
    procedure HideHint(Sender: TObject);
    procedure ScriptTerminated(Sender: TObject);
    procedure SyncFreeTimers;
    procedure SyncClearLog;
    procedure PromptMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PromptKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PromptTimer(Sender: TObject);
    procedure PromptOkClick(Sender: TObject);
    procedure PromptClose(Sender: TObject; var Action: TCloseAction);
    procedure SyncCaptureScreen;
    procedure SyncSetControlText;
    procedure SyncKeyboardOn;
    procedure SyncKeyboardOff;
    procedure SyncMouseOn;
    procedure SyncMouseOff;
    procedure SyncLog737C;
    procedure SyncLog6548;
    function ServiceCall: string;
    function ServiceStop: string;
    function ServiceSend: string;
    function ServiceGetStatus: string;
  end;




  PPluginFuncs = ^TPluginFuncs;
  TPFNamesZ = array of PChar;
  TPluginFuncs = packed record
    Count: Cardinal;
    Names: TPFNamesZ;
  end;


type

  { Двойник TScriptArray, но с типом потомка: даёт обращаться к элементу
    массива скриптов без приведения типа. Приведение мешает удержать
    `gScriptso3[Cnt]` в регистре -- элемент пересчитывается на каждом
    обращении. Объявляется через `absolute`, места не занимает. }
  TScriptArrayS = array[0..99] of TScanThread;

{ ---- привязка Lua ---------------------------------------------------------
  Обёртка над lua_State лежит в поле TScanThread, которое по старой памяти
  зовётся DebugForm. }
type
  { TLuaCFunc и формы вызова lua51.dll объявлены в lualib -- вместе с
    переменными, через которые они зовутся. }
  { Таблица TLuaStatusText живёт в lualib, отсюда к ней ходят через
    посредник PLuaStatus (объявлен ниже). }
  PPtr = ^Pointer;

  { Сам класс TLua со своими глобалями объявлен в lualib; здесь он виден
    через uses и используется как `TLua(T.DebugForm)`. }


{ Свои переменные привязки держит lualib: gLuaLoaded, gLuaProc01, таблица
  состояний; таблица CRC32 -- в CRCunit. Здесь только ссылка-посредник ниже:
  массив живёт в чужом юните, и читать его отсюда надо в два шага. }


{ В интерфейсе потому, что зовут её двое: EvalScriptExpr отсюда же и одно
  место в Unit1. }
function TryCaptureImage(T: TScanThread; H: HWND): Boolean;

{ LuaBindGlobal, LuaPushClosure и LuaDoString объявлены в lualib. }
{ Один обработчик на все команды скрипта: своё имя он берёт из upvalue
  замыкания, поэтому в таблице регистрации всюду он же }
function LuaScriptCommand(L: Integer): Integer; cdecl;

procedure StartScriptThread(T: TScanThread);
procedure ShowScriptMsg(T: TScanThread);
procedure RunLuaScript(T: TScanThread);
procedure UpdateScriptButtons(T: Pointer);
{ Число из строки: если это не число, строка считается ИМЕНЕМ переменной
  ('#' или '$') и берётся её значение. }
{ Найти (или завести) переменную скрипта по ПЕРВОМУ СИМВОЛУ имени:
  '#' -- число, '$' -- строка, '%' -- матрица. X и Y -- запрошенные размеры
  матрицы. Возвращает номер в массиве. }
function FindScriptVar(T: TScanThread; C: Char; Name: string;
  X, Y: Integer): Integer;
{ Записать значение в переменную, найденную предыдущей. }
procedure StoreScriptVar(T: TScanThread; C: Char; Idx: Integer; Res: string;
  Cnt: Integer; W: string; X, Y: Integer);
{ Разбор слова: N = 0 -- первое слово в нижнем регистре, N > 0 -- N-е слово
  как есть, N < 0 -- хвост строки начиная со слова -N. Побочный итог --
  T.WordPos, позиция найденного слова. }
function EvalScriptPoint(T: TScanThread; S: string; N: Integer): string;
{ Вычислитель выражений скрипта. }
function EvalScriptExpr(T: TScanThread; sv: string;
                        nv: Integer): string;
{ Диспетчер команд скрипта: по номеру N выполняет тело команды.
  Зовётся из Execute на каждом шаге. }
procedure ExecScriptCommand(T: TScanThread; var N: Integer;
  var S: string);
{ Размеры матричной переменной. Объявление вынесено сюда, потому что
  LuaScriptCommand лежит ВЫШЕ самой функции, а вперёд в Паскале не
  сослаться. }
function GetArraySize(T: TScanThread; S: string; var A: Cardinal;
                      var C: Cardinal; B: Boolean): Boolean;

{ Табличка функций, которые объявил о себе плагин. }
{ Список загруженных плагинов: дом у него здесь, Unit1 берёт его отсюда. }
var
  gPluginListjr: TStringList;

var
  gPluginFuncsgm: PPluginFuncs;


implementation

uses Math, ShlObj, SKey, MathEx, Unit1, HotKeyMgr, CRCunit, uCircleForm, Keydefs, sendR, ComObj, DateUtils, Grids, ScktComp, SHDocVw, Masks, WebConst, HTTPApp, ProcessAPI, ReadMem, WinSvc;



{ Тела WaitPartOf, WaitTextOf, WaitUnitOf, ParseWaitSuffix -- в юните `MathEx`. }
{ Тела SvcInstall, SvcRemove, SvcQueryState, SvcSendKeys -- в юните `SKey`. }
{ Тела CrcOfBuf, SendExKeyCode -- в юните `CRCunit`. }
{ Тела SendKeysEx, SendKeysBody, SendOneKey -- в юните `sendR`. }

var
  { Имена логических операций держим ОДНИМ массивом, а не шестью
    отдельными строками: тогда очистка при завершении юнита -- один вызов
    FinalizeArray вместо шести LStrClr. `gOpsZ[3]` ('not') сейчас никто не
    читает, но место в ряду за собой оставляет. }

  { Двойник массива скриптов с типом потомка. Хранения не занимает,
    адресация та же, зато `gScriptsS[Cnt].Synchronize(...)` пишется БЕЗ
    приведения и элемент удерживается в регистре. В StoreScriptVar заменены
    ВСЕ обращения: двойник и оригинал -- разные символы, смешивать их нельзя,
    иначе элемент будет пересчитываться. }
  gScriptsS: TScriptArrayS absolute gScriptso3;

{ Привести кнопки и редактор в соответствие с состоянием скрипта на
  ТЕКУЩЕЙ вкладке и вернуть фокус в редактор. Зовётся из Execute и из
  Synchronize-обёртки.

  Номер скрипта -- ПОДПИСЬ вкладки: tScript.Tabs[tScript.TabIndex] хранит его
  строкой, поэтому StrToInt. Аргумент T не используется -- как и у
  PauseScriptThread/StopScriptThread, он есть только ради единой сигнатуры
  Synchronize-обёрток. }

{ Убрать из строки скрипта хвостовой комментарий `//`, не тронув `//`
  внутри кавычек. Признак «внутри строки» -- НЕЧЁТНОЕ число кавычек до
  найденного `//`; при чётном комментарий настоящий и строка обрезается,
  при нечётном ищется следующий `//` (PosEx с P+2).

  Длина L берётся ОДИН раз до цикла: Copy всегда завершается Break, так что
  устареть она не успевает. }


{ Снять окно (или область экрана) в буфер T.ShotBits.

  Порядок: DDB через CreateCompatibleDC/CreateCompatibleBitmap, наполнение --
  BitBlt с экрана (CapWnd = 2) либо PrintWindow в память с последующим
  BitBlt; дальше картинка отдаётся GDI+ (GdipCreateBitmapFromHBITMAP), при
  открытом окне предпросмотра кодируется в BMP и грузится в gProcImageer, а
  сами пиксели забираются GdipBitmapLockBits и копируются в блок GlobalAlloc.
  Каждая неудача -- не выход, а строка в T.Msg и Synchronize(SyncLogMsg):
  показываем сообщение и идём дальше. }
{ Пересоздать растр под снимок экрана: старый освободить, новый завести
  пустым 1x1 в pf24bit. Весь блок в try..except, ошибка 3313. }









type
  { Запись под ReadShortcut: на входе untyped var, внутри -- вот это. }
  TZzLnk = packed record
    Path: array[0..$104] of Char;      { путь к самому .lnk }
    Name: array[0..$104] of Char;      { ответ: на что ссылается }
    Args: array[0..$104] of Char;      { ответ: аргументы }
    Dir:  array[0..$104] of Char;      { ответ: рабочий каталог }
    Pad:  array[$414..$62B] of Byte;
    Find: TWin32FindData;
  end;









type
  PStrPtr = ^string;
  TClVerTab = array[0..24] of Cardinal;
  PClVerTab = ^TClVerTab;
  TClVerTab2 = array[0..7] of TClVerTab;
  PClVerTab2 = ^TClVerTab2;
  TReadMemProc = procedure(hProc: THandle; var bRes; var qErr: Int64;
    qAddr: Int64; nSize: Int64; const sMod: string; nPid: Cardinal);
  TChSet = set of Char;
  PChSet = ^TChSet;
  { Таблица имён команд -- указатель на структуру, где массив строк идёт со
    смещения 8. Имя команды в `switch` достаётся двумя командами; TStringList
    на этом месте давал бы виртуальный вызов `Strings[]`, SEH-рамку и лишнюю
    строковую временную. }
  TCmdStrArrZ = array[0..255] of string;
  TCmdStrTab = record
    hdr0, hdr4: Integer;
    S: TCmdStrArrZ;
  end;
  PCmdStrTab = ^TCmdStrTab;


var
  gStitchNeverZ: Boolean;




{ ReadMemByName и WriteMemByName -- в юните `ReadMem`. }

{ Показать текст ошибки скрипта: в лог, окном сообщения или подсказкой --
  смотря что отмечено на вкладке настроек. }

{ Набрать текст в окно клиента. Раскладка на время набора подменяется на
  ту, что записана в gKbdLayoutow, и возвращается в конце. }

{ ЗАПИСЬ ЧИСЛА В ПАМЯТЬ КЛИЕНТА ПО ИМЕНИ ЗАПИСИ. Зовётся из ветки `set`
  диспетчера. Довод `S` -- либо само число, либо имя строки таблицы `G`;
  если таблица задана и число не больше $226, оно считается НОМЕРОМ СТРОКИ
  и настоящее значение берётся из второй колонки.

  Мелочи, которые лучше не трогать:
  * `Length(S) - 1 > 0` короче на команду, чем `Length(S) > 1`;
  * `nRow` -- Cardinal нарочно: вход в цикл проверяется беззнаково. Он же
  уходит в WriteProcessMemory как «сколько байт записано» -- одна
  переменная на два дела;
  * хвостовой `#0` в обоих сообщениях стоит по делу, это не опечатка. }

{ Разбор хвоста ожидания: шестнадцатеричные числа (1a2bh и $1a2b)
  переводятся в десятичные, потом строка разбирается по словам.
  Отрицательное A -- признак ошибки для вызывающего. }


{ MacroFileLoad живёт в Recorder.pas. }

{ Поставить скрипту рабочее окно и перечитать по нему процесс. Довод T не
  используется: вкладка берётся заново по номеру.

  Прежнее окно держит сам `Result`, отдельного локала под него нет нарочно:
  с ним база массива не удерживается в регистре и слот вкладки читается
  заново на каждом шаге. По той же причине последняя группа обращается к
  элементу напрямую, а не через временную. }






{ Отражает состояние AutoStart и LoggingCommands на галке настроек. }






type
  PExprDesc = ^TExprDesc;
  TEvalErrs = array[-6..1] of string;
  PEvalErrs = ^TEvalErrs;
  TExprDesc = record
    ErrMsg: TEvalErrs;
    Ops: array[0..7] of Char;
    Prec: array[0..7] of Byte;
  end;
  TAddrTable = array[0..99] of Cardinal;
  PAddrTable = ^TAddrTable;
  TCaseRec = packed record
    Text: string[255];
    Line: Int64;
  end;
  PStrPtr2 = ^string;
  TLnkRec = packed record
    Path: array[0..$104] of Char;
    Args: array[0..$104] of Char;
    Run:  array[0..$104] of Char;
    Dir:  array[0..$104] of Char;
    Rest: array[0..$76C - 4 * $105 - 1] of Byte;
  end;
  TChSet2 = set of Char;
  PChSet2 = ^TChSet2;

const
  cHKShift = [hkShiftZ];
  cHKAlt = [hkAltZ];
  cHKCtrl = [hkCtrlZ];

var
  gHKNoneZ: Byte;
  gCbStubStr: string;
  gHoldStr: string;   { приёмник для веток с var-параметром }
  gCbStubInt: Integer;

{ Процедурная форма EvalScriptExpr: результат уходит через `var Res`.
  Имя другое, потому что переобъявить EvalScriptExpr в том же юните нельзя. }
{ Контрольная сумма строки: длина берётся у временной строки, а сам
  буфер -- исходный PChar. }
{ Первая группа в скобках. S -- ЗНАЧЕНИЕВЫЙ параметр, T не используется
  вовсе. }
{ Быстрая сортировка СТРОК массива по столбцу D. Числа сравниваются как
  числа, остальное -- как строки; Asc задаёт направление. Рекурсия только
  в меньшую половину, большая уходит в тот же цикл. }
{ То же самое, но сортируются СТОЛБЦЫ: сравнение идёт по строке D, а
  меняются местами элементы всех строк. }
type
  { Массивы кривой уходят ПО ЗНАЧЕНИЮ и копируются целиком, поэтому длина
    ровно 101. Вызывающий заполняет только четыре первые ячейки -- остальное
    копируется как есть, и так и задумано. }
  TCurveArr = array[0..100] of Integer;


{ Последняя группа в скобках: просмотр идёт С КОНЦА строки. Параметр N
  после первого присваивания служит индексом просмотра. }
{ Разобрать командную строку на слова. Возвращает число слов; вызывающие
  результат отбрасывают. Отрицательный индекс в CmdParts -- не описка:
  таблица частей видна и назад, туда кладётся хвост. }
{ Первая группа в кавычках. Границы возвращаются через A и B, и из них же
  считается Copy -- по указателям, а не по локальным. }
{ Близнец `EvalScriptPoint`, ЧИТАЮЩИЙ СТРОКУ С КОНЦА. Отличий ровно три,
  всё остальное слово в слово:
  * цикл идёт `downto`, поэтому счётчик -- сам `I`, а не отдельный слот;
  * слово наращивается СЛЕВА (`W := S[I] + W`);
  * позиция слова -- `I + 1`, а не `I - Length(W)`.
  Первая запись `T.WordPos` тут же затирается второй -- так и есть. }
{ Ручки службы -- в юните `SKey`, вместе с четвёркой Svc*. }

{ ОПРОС СОСТОЯНИЯ СЛУЖБЫ. Единица взводится ДО всего и остаётся, если
  менеджер или служба не открылись, -- то есть 1 значит «спросить не
  удалось», а не «остановлена». try..finally нужен из-за строкового
  довода по значению. }




{ Обе строки -- одно и то же значение. }

{ Условие вывернуто -- `or` с отрицанием, а не `and`: так тело ветки `-6`
  идёт первым. Итог второго опроса намеренно выбрасывается. }

{ Близнец ServiceStop: та же форма
  `if not <опрос> then gSvcRetakx := <число> else SvcQueryState(gServiceNamec)`,
  и итог второго опроса так же выбрасывается. }






{ Крупные локалы держим модульными: в кадре они сдвигают все временные. }
var
  F         : TextFile;
  PI        : TProcessInformation;
  R         : TRect;
  SI        : TStartupInfo;
  fBin      : file;
  rF228     : Real48;
  rLnk      : TLnkRec;

type
  { Накладка на объект описания величины: сразу за VMT одна строка. }
  TValDescRecZ = record
    VmtZ: Pointer;
    TxtZ: string;
  end;
  PValDescZ = ^TValDescRecZ;

  { Накладка на окно журнала: нужен только флаг «показано» на +$57 }
  TLogWinRecZ = record
    VmtLWZ: Pointer;
    FillLWZ: array[1..$53] of Byte;
    ShownZ: Boolean;
  end;
  PLogWinZ = ^TLogWinRecZ;



{ Номера системного вызова NtUserPostMessage по версиям Windows; какой
  брать, говорит cbNtUserPM.ItemIndex. Сам номер лежит отдельной
  переменной, её читает `NtPostMsgZ`. }
type
  TNtPmTab = array[0..3] of Cardinal;



{ `p`-семейство команд мыши шлёт сообщение НЕ через PostMessage, а прямым
  системным вызовом: номер в EAX, четыре довода на стеке, возврат по адресу,
  положенному тут же. Паскалем `sysenter` не выразить, поэтому вставка на
  ассемблере. Первый довод (поток) самому вызову не нужен -- он есть ради
  единой формы вызова с PostMessage в соседних ветвях. }

type
  TVerTab = array[0..63] of Integer;
type
  PVerTab = ^TVerTab;
type
  TIntGrid = array[0..0] of array[0..63] of Integer;
type
  PIntGrid = ^TIntGrid;
{ Таблица адресов по номеру версии клиента (`T.ClVerIdx`). Объявлена
  ЗДЕСЬ, а не ниже по файлу: её читает `CheckCompare`, вложенная в
  `ExecScriptCommand`. }

{ Два указателя на строки чужого юнита -- их читают ветки `homepath` и
  `exefilename`. Объявлены ЗДЕСЬ, а не в общем блоке переменных ниже: тот
  лежит после этой функции, а вперёд ссылаться нельзя. }

{ Переходник Lua к тем же двум спискам, по которым работают
  ExecScriptCommand и EvalScriptExpr. Числовые метки обоих `case` -- это
  ИНДЕКСЫ в этих списках: 43 -- findwindow, 194 -- regexp, 246 и 248 --
  getimage и loadimage. Первыми в кадре идут четыре локала, захваченные
  вложенными процедурами. }

{ Подсветить в редакторе строку, на которой стоит выполнение, подвинуть
  индикатор и показать номер строки. Именно МЕТОД, а не модульная процедура:
  он уходит в Synchronize, а `procedure of object` указателем на модульную
  процедуру быть не может. }

{ Сброс вкладки скрипта перед запуском: чистит таблицы переменных и
  таймеров, освобождает блоки GlobalAlloc, гасит рабочие объекты. Каждый шаг
  в своём try..except: сбой одного не должен мешать остальным. }


{ Скрипт встал на паузу: кнопка «пауза» нажата, редактор снова доступен.
  Параметр не используется. Ранний Exit, а не if вокруг всего блока: только
  так адрес fmSecondfj удерживается в регистре. }

{ Скрипт запущен: «старт» нажат, редактор закрыт на правку. }

{ Снятие с паузы, близнец PauseScriptThread: та же проверка доступности
  кнопки и та же пара присваиваний, но Down := False. ReadOnly считается
  уже ПО ПОЛЮ Enabled редактора, а не по sbPause.Down. }

{ Скрипт остановлен: обе кнопки отжаты, редактор разблокирован.
  Обращений к fmSecondfj тут немного, так что with не нужен. }

{ Завести новую вкладку: то же, что нажать «+» на форме. }

{ Предупредить форму о смене вкладки. Локал живёт прямо в стеке, потому
  что второй довод обработчика -- `var`. }

{ Вкладка сменилась. }



{ Вывод накопленной строки лога: в окно лога, в мемо вкладки и в файл.
  Зовётся из SyncLogMsg.

  Строка собирается из буфера T.LogBuf, а маска T.LogFlags гасит её части:
  1 -- время, 2 -- имя вкладки, 4 -- имя файла, 8 -- номер строки,
  $10 -- время с миллисекундами. При T.LogFlags = 0 формат фиксированный и
  склейка идёт одним LStrCatN на 11 частей.

  Директива I- обязательна: ошибки ввода-вывода ловит общий try..except,
  который на второй раз гасит лог совсем (gLogFileClosedr).

  Обрезка окна лога пополам (Copy от первого CRLF за серединой) взводит
  Trimmed, и только тогда проверяется предел файла: FileSize у ТЕКСТОВОГО
  файла делит размер на BufSize, то есть считает буферами по 128 байт --
  отсюда единицы gLogMaxSizehk. }
{$I+}

{ Показать текст ошибки подсказкой над ярлыком вкладки и подержать её три
  секунды, прокачивая очередь сообщений. }


{ Выполнение блока `--lua ... -- endlua`. Execute собирает строки чанка
  в T.LuaText и зовёт сюда.

  Три четверти тела -- однотипные регистрации команд языка UoPilot в
  lua_State. Обработчик у всех ОДИН: своё имя он достаёт из upvalue
  замыкания. Четвёртый параметр (0..20) не используется. }


{ ---- Sync-обёртки потока ---- }






{ Вернуть окну лога сохранённые размеры и положение (fmSecondfj.FLogWin)
  и показать его. -1 в поле означает «не задано». }

{ Конструктор потока скрипта. CreateSuspended передаётся насквозь в
  inherited: значение и так уже в нужном регистре, лишних команд не
  появляется.

  Локальная только одна -- T под таймер. Список живёт в поле: пара
  `VarNames := TStringList.Create; VarNames.Add('timer');` удерживает
  только что записанное поле в регистре, а второй локальной под список
  регистра уже не достаётся. }

{ --- обвязка вычислителя выражений --- }
type
  TChSetE = set of Char;
  PChSetE = ^TChSetE;

{ Наборы символов пишем ПРЯМО В ВЫРАЖЕНИИ, а не типизированной постоянной:
  постоянная уводит 32 байта в DATA, встроенный набор ложится в пул кода. }



type
  { состояние персонажа, клиенты 5..7 -- $50 байт (2121) }
  TStat1 = record
    Name    : array[0..$1F] of Char;  { $00  имя, $20 байт }
    Strg    : SmallInt;               { $20  13 str      }
    Dext    : SmallInt;               { $22  15 dex      }
    Intl    : SmallInt;               { $24  14 int      }
    Hits    : SmallInt;               { $26   4 hits     }
    HitsMax : SmallInt;               { $28  66          }
    Stam    : SmallInt;               { $2A   6 stam     }
    StamMax : SmallInt;               { $2C  68          }
    Mana    : SmallInt;               { $2E   5 mana     }
    ManaMax : SmallInt;               { $30  67          }
    Gold    : Cardinal;               { $34   1 gold     }
    Res38   : Cardinal;               { $38  не читается }
    PSys    : Word;                   { $3C  59          }
    Res3E   : Word;                   { $3E  не читается }
    Foll    : Byte;                   { $40  71          }
    FollMax : Byte;                   { $41  72          }
    Fire    : Word;                   { $42  60          }
    Cold    : Word;                   { $44  61          }
    Pois    : Word;                   { $46  62          }
    Ener    : Word;                   { $48  63          }
    Luck    : Word;                   { $4A  64          }
    DmgMax  : Word;                   { $4C  70          }
    Dmg     : Word;                   { $4E  65          }
  end;                                { всего $50 }

type
  { то же для остальных клиентов -- $3C байт, всё беззнаковое,
    имя длиннее ($26 против $20): `nn := $25` (2121) }
  TStat2 = record
    Name  : array[0..$25] of Char;    { $00  имя, $26 байт }
    Hits  : Word;                     { $26   4 hits  }
    Strg  : Word;                     { $28  13 str   }
    Stam  : Word;                     { $2A   6 stam  }
    Dext  : Word;                     { $2C  15 dex   }
    Mana  : Word;                     { $2E   5 mana  }
    Intl  : Word;                     { $30  14 int   }
    Gold  : Cardinal;                 { $34   1 gold  }
    Armor : Word;                     { $38   3 armor }
    Wght  : Word;                     { $3A   2 wght  }
  end;                                { всего $3C }

type
  TThreadEntry32 = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ThreadID: DWORD;
    th32OwnerProcessID: DWORD;
    tpBasePri: Longint;
    tpDeltaPri: Longint;
    dwFlags: DWORD;
  end;

{ Размер массива скрипта -- прочитать или задать. Последний флаг: True --
  задать, False -- только прочитать (ветка `size`).
  Имя вида `arr.N` -- обращение к массиву ЧУЖОЙ вкладки: до точки имя,
  после -- номер скрипта. }

{ Разбор ссылки `%имя[строка,столбец]` внутри строки скрипта: ищет её от
  позиции P и через var-доводы отдаёт имя массива, оба индекса, номер
  вкладки, номер в Arr48, само значение и позицию закрывающей `]`.
  `nAt` заполняется и нигде не читается -- присваивание оставлено нарочно. }

{ Загрузить картинку из файла в буфер снимка и построить по ней список
  опорных точек: самый частый цвет считается фоном, всё остальное попадает
  в ImgList. Зовут из веток `loadimage` и `findimage`.
  Счётчики строки и столбца -- Cardinal, индекс списка -- Integer.
  ImgList -- ДВУМЕРНЫЙ динамический массив (`SetLength(..., N, 3)`), а не
  массив указателей. }

{ Строка в EAX, var-целое в EDX; ответ проверяется через `test al,al`.
  Лежит вплотную перед EvalScriptExpr.

  Полезной работы в теле нет -- Result приходит из EBX. Рамка тут не от
  `try`, а от уборки местной строки: только с ней Result остаётся в EBX.
  `if 1 = 0 then` нужен, чтобы уборки НЕ БЫЛО: строку надо ПОМЯНУТЬ (иначе
  переменная пропадёт вместе с рамкой), но не присвоить (иначе в finally
  встанет LStrClr). }

{ Объявление `OpenThread` -- в юните `mySys`. }

{ Довод в EAX телу не нужен, но место вызова его кладёт, поэтому он
  остаётся в подписи. Окно ввода чужого потока не отдаёт фокус, пока входы
  не сцеплены AttachThreadInput; отцепление -- в finally. }



type
  TSkillTbl = array[0..255] of PChar;
type
  PSkillTbl = ^TSkillTbl;
type
  TColRec = packed record
    Lo1: Byte;
    Hi1: Byte;
    Lo2: Byte;
    Hi2: Byte;
    Lo3: Byte;
    Hi3: Byte;
  end;
type
  TColBytes = array[0..2] of Byte;
type
  { Накладка на объект-держатель строки: за VMT одна строка. }
  TStrHoldRecZ = record
    VmtSHZ: Pointer;
    Txt: string;
  end;
  PStrHoldZ = ^TStrHoldRecZ;
type
  TEbPadRec = record
    d: array[1..1392] of Byte;
  end;
type
  PReal48 = ^Real48;
type
  TChSetE2 = set of Char;
type
  PChSetE2 = ^TChSetE2;
type
  TEbT = packed record
    A: Integer;
    B: Integer;
  end;
type
  TFlagArr_0CD3 = array[0..63] of Boolean;
type
  TUoStats = packed record
    Hits: Integer;
    HitsMax: Integer;
    Mana: Integer;
    ManaMax: Integer;
    Stam: Integer;
    StamMax: Integer;
    Strg: Integer;
    Intl: Integer;
    Dext: Integer;
    Gold: Integer;
    Armor: Integer;
    Wght: Integer;
    Luck: Integer;
    Dmg: Integer;
    DmgMax: Integer;
    Foll: Integer;
    FollMax: Integer;
    PSys: Integer;
    Fire: Integer;
    Cold: Integer;
    Pois: Integer;
    Ener: Integer;
  end;
type
  TWndRec = packed record
    Handle: Integer;
    Title: string;
  end;
type
  TWndArr = array of TWndRec;
type
  TPackRec = packed record
    Kind: Integer;
    Data: string;
  end;
type
  TWndRec2 = packed record
    Handle: Integer;
    Title: string;
  end;
type
  TFlagArr = array[0..1023] of Boolean;
type
  TPackRec2 = packed record
    Kind: Integer;
    Data: string;
  end;
type
  TSkillNm = array[0..255] of string;
type
  PSkillNm = ^TSkillNm;
type
  TCardTab221A = array[0..63] of Cardinal;
type
  PCardTab221A = ^TCardTab221A;
  { `TModHelper` объявлен в `ReadMem`, сюда виден через uses. }
type
  TProcEnt = packed record
    dwSize: Cardinal;
    cntUsage: Cardinal;
    th32ThreadID: Cardinal;
    th32OwnerProcessID: Cardinal;
    tpBasePri: Integer;
    tpDeltaPri: Integer;
    dwFlags: Cardinal;
  end;
type
  TStrTab = array[0..255] of string;
type
  PStrTab = ^TStrTab;
type
  TIntTab2 = array[0..255] of array[0..255] of Integer;
type
  PIntTab2 = ^TIntTab2;
type
  PFormRef = ^TForm;
type
  TIntGrid_3841 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_1D09 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_1BD3 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_1C6E = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_1E78 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_1F13 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_1FAE = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_2049 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_20E4 = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_217F = array[0..7] of array[0..63] of Integer;
type
  TIntGrid_2797 = array[0..7] of array[0..63] of Integer;
type
  PColBytes = ^TColBytes;
type
  PEbT = ^TEbT;
type
  { Локалы хвоста области A и головы области B одной записью -- так они
    ложатся подряд. Три слота посередине заняты счётчиком `for` и двумя
    якорями `with`, полями их держать нельзя. }
  TEbR1 = packed record
    _re_wcnt     : Integer;
    _re_wlen     : Integer;
    padB2C8      : Integer;
    rxLoc        : TPerlRegEx;
    pSk          : PSkillNm;
    pBuf         : PByteArray;
    rxLoc_F99D   : TPerlRegEx;
  end;
type
  { семь слов под DecodeDate/DecodeTime }
  TEbW = packed record
    wYear        : Word;
    wMon         : Word;
    wDay         : Word;
    wHour        : Word;
    wMin         : Word;
    wSec         : Word;
    wMSec        : Word;
  end;
type
  { остаток хвоста, 104 байта }
  TEbR2 = packed record
    _re_bFlag    : Boolean;
    _re_ok       : Boolean;
    _mp_simple   : Boolean;
    _mp_cKind2   : Char;
    jj_2884      : Integer;
    padR2_found  : Byte;
    padR2_fCase  : Byte;
    _mp_fWhole   : Boolean;
    _mp_more     : Boolean;
    _mp_nBig     : array[1..8] of Byte;
    _mp_h        : Integer;
    nA           : Integer;
    nB           : Integer;
    dwSize       : Integer;
    th32ThreadID : Integer;
    dep_2884     : Integer;
    u1_F0A9      : Integer;
    rr_A6E8      : Integer;
    sa_A6E8      : Integer;
    sb_A6E8      : Integer;
    padEb        : array[1..8] of Byte;
    _re_pIns     : Integer;
    padR2        : array[1..18] of Byte;
  end;

var
  gClientKind: array[0..63] of Integer;
var
  gSkillBase:  array[0..63] of Integer;
var
  gScr: TObject;

var
  fRead: TFlagArr_0CD3;
var
  hProc2: THandle;
type
  TPackArrZ = array of TPackRec;
  TWndArr2Z = array of TWndRec2;
var
  Pack: TPackArrZ;
var
  Pack_B713: TWndArr2Z;
var
  Pack_1076: TWndArr2Z;
var
  Wnd2: Integer;
var
  HexFlag: Boolean;
var
  LastErr: Integer;
var
  Fmt: string;
var
  Mod2: Integer;
var
  MonitorNo: Integer;
var
  B4, E2, I8AD: Integer;
var
  ClVer: Integer;
var
  ModHelper: TModHelper;

var
  gMonitorNo: Integer;


{ ВЫЧИСЛИТЕЛЬ ВЫРАЖЕНИЙ СКРИПТА.

  Голова -- разбор слова N из строки S (то же, что EvalScriptPoint, только
  множество с кавычкой И фигурной скобкой), дальше поиск в этом слове всех
  известных имён выражений и замена каждого на значение. Сами ветки лежат
  в `case idx of` ниже. }


























{ Обратная сторона SyncGetControlText: положить значение в элемент формы.
  Номера 1..3 приходят от диспетчера команд и к списку имён отношения не
  имеют -- строка S в этих ветках не используется. }

{ Команда скрипта `screenshot`: снять экран, окно клиента или заданное
  окно и сохранить в файл, имя которого лежит в Msg. Расширение .jpg
  переключает на TJPEGImage с качеством из SpinEdit1. CapWnd: 0 -- весь
  экран, 1 -- окно клиента (или активное), иначе -- прямо хэндл окна. }








{ Долбить клавишей, пока не выйдет срок. Срок 0 значит «навсегда»: поле
  выставляется в $FFFFFFFF, а не складывается с тиками. }

{ То же, но строкой: Phase 1 -- очередной повтор, 2 -- добивка после
  выхода из цикла. }

{ В RxLib эта функция сидит в implementation-секции Rxhints.pas и наружу
  не видна -- тело пришлось скопировать сюда. }




{ Зеркалит конструктор: сперва картинка, потом оконная процедура
  возвращается на место, и только затем унаследованный деструктор. }

{ Перехват оконной процедуры, снимающий сам себя. На первом же WM_MOVE
  ставит флаг и возвращает прежнюю процедуру на место, после чего всегда
  передаёт сообщение дальше. }




{ в RxLib этого нет: окно ловит мышь как заголовок }

{ у RxLib второй параметр Shade, здесь ветки тени нет }


{ Это ActivateHint, а не CalcHintRect: в конце SetWindowPos и установка
  FActive, а входной Rect -- не готовые координаты, а набор пожеланий:
  -1 в поле означает «посчитай сам».
  Ширина/высота: отрицательное значение -> берём вычисленное по тексту.
  Left = -1 -> прижать к правому краю экрана с отступом 4. }



procedure ScanDirReal(const AMask, AFilter: string; ANoRec: Boolean); forward;
procedure MouseClickReal(AWnd: HWND; ABtn: Byte; const S: string; var P: TPoint; N: Integer; const S2: string); forward;
procedure WaitDelayReal(const S: string); forward;
procedure SayText(T: TScanThread; S: string); forward;
procedure ScSetCl(T: TScanThread; G: TGridCracker; S: string; A: Cardinal); forward;
function GetWord(T: TScanThread; const S: string; N: Integer): string; forward;
function ApplyWorkWindow(T: TScanThread; H, Idx: Integer): Integer; forward;
procedure SetArrSize(T: TScanThread; S: string; var A, B: Integer; C: Integer); forward;
function FindParenGroupF(T: TScanThread; const S: string; N: Integer; var A, B: Integer): string; forward;
procedure EvalScriptExprV(T: TScanThread; const S: string; N: Integer; var Res: string); forward;
function FindParenGroup(T: TScanThread; S: string; N: Integer; var A, B: Integer): string; forward;
procedure SortScriptArray(T: TScanThread; N, M, H, D, I: Integer; Asc: Boolean); forward;
procedure SortScriptArray2(T: TScanThread; N, M, H, I, D: Integer; Asc: Boolean); forward;
procedure WaitDelayStub(const S: string); forward;
function FindParenGroup2(T: TScanThread; S: string; N: Integer; var A, B: Integer): string; forward;
function SplitCmdLine(T: TScanThread; S: string): Integer; forward;
function FindQuotedGroup(T: TScanThread; S: string; N: Integer; var A, B: Integer): string; forward;
function EvalScriptPart(T: TScanThread; S: string; N: Integer): string; forward;
procedure SetMaskList(L: TObject; const S: string); forward;
procedure ScanDirStub(const AMask, AFilter: string; ANoRec: Boolean); forward;
function NtPostMsgZ(TZ: TScanThread; hWndNt: HWND; uMsg: Cardinal; wPar, lPar: Integer): Integer; stdcall; forward;
function FindArrayItem(T: TScanThread; S: string; var P: Integer; var Fin, Row, Col, Scr, Idx: Integer; var N, R: string): Boolean; forward;
procedure LoadImageFile(T: TScanThread); forward;
function FocusedWindow(T: TScanThread): Integer; forward;
procedure EbRegexAnchor; forward;
procedure ParseWaitSuffix2(const S: string; var A: Integer; var B: string); forward;
procedure SplitCmdLine2(T: TScanThread; const S: string); forward;
procedure SetScriptVar(T: TScanThread; C: Char; N, A, B: Integer; const S: string; P: Integer; const S2: string); forward;
procedure Synchronize2; forward;
procedure CaptureScreen(T: TScanThread); forward;
procedure Synchronize3; forward;
procedure LoadImageFile2(T: TScanThread); forward;
function FindScriptVarC(T: TScanThread; C: Char; const S: string; A, B: Integer): Integer; forward;
procedure CaptureScreen2(T: TScanThread); forward;
function GetPixel2(DC: HDC; X, Y: Integer): Integer; forward;
function EbArcCos(A: Extended): Extended; forward;
function EbArcSin(A: Extended): Extended; forward;
function EbCeil(A: Extended): Integer; forward;
function EbDegToRad(A: Extended): Extended; forward;
function EbFloor(A: Extended): Integer; forward;
function EbLogN(A, B: Extended): Extended; forward;
function EbPower(A, B: Extended): Extended; forward;
function EbRadToDeg(A: Extended): Extended; forward;
function EbTan(A: Extended): Extended; forward;
procedure ReadMemTyped(H: THandle; var Buf; var Addr: Int64; A: Int64; B: Int64; const C: string; D: DWORD); forward;
function StrToInt2(const S: string): Integer; forward;
procedure ScriptIdle2; forward;
function EbPadF: TEbPadRec; forward;
procedure EbUsePad(const R: TEbPadRec); forward;
function FindParenGroup3(T: TScanThread; const S: string; N: Integer; var C: string; var A, B: Integer): string; forward;
procedure EvalScriptExprP(T: TScanThread; const S: string; N: Integer); forward;
function SplitCmdLine3(T: TScanThread; const S: string): Integer; forward;
function EbIncYear(D: TDateTime; N: Integer): TDateTime; forward;
function EbIncMonth(D: TDateTime; N: Integer): TDateTime; forward;
function EbIncDay(D: TDateTime; N: Integer): TDateTime; forward;
function EbIncHour(D: TDateTime; N: Int64): TDateTime; forward;
function EbIncMinute(D: TDateTime; N: Int64): TDateTime; forward;
function EbIncSecond(D: TDateTime; N: Int64): TDateTime; forward;
procedure EbDecodeDateTime(D: TDateTime; var Y, M, Dd, H, N, S, MS: Word); forward;
function EbEval(T: TScanThread; const S: string; N: Integer): string; forward;
procedure EbFPG(T: TScanThread; const S: string; N: Integer; var A, B: Integer; var C: string); forward;
function EbPoint(T: TScanThread; const S: string; N: Integer): string; forward;
function EbS2I(T: TScanThread; const S: string): Integer; forward;
function EbFSV(T: TScanThread; C: Char; const S: string; var A, B: Integer): Integer; forward;
procedure EbSSV(T: TScanThread; c: Char; ix: Integer; const s2: string; i3: Integer; const v: string; i2, i1: Integer); forward;
function GetString(const S: string): string; forward;
function EbStrComp(A, B: PChar): Integer; forward;
procedure SetScriptVar2(T: TScanThread; C: Char; N, A, B: Integer; const S: string; P: Integer; const S2: string); forward;
procedure ShowErr(T: TScanThread; const S: string); forward;
function ExprName(N: Integer): string; forward;
function IsClientWindow(T: TScanThread; H: Integer): Boolean; forward;
function EbPWS(T: TScanThread; const S: string; N: Integer): string; forward;
function EbSnap(T: TScanThread; N: Integer): Integer; forward;
procedure EbSaveImg(T: TScanThread); forward;
function EbOpenThread(A: Cardinal; B: Boolean; C: Cardinal): Integer; forward;
function EbFQG(T: TScanThread; const S: string; N: Integer; var A, B: Integer; var C: string): string; forward;
function EbPWS_2BE9(A0: string; A1: Integer; A2: string): string; forward;
function EnumFindWndProc(H: HWND; L: Integer): Boolean; stdcall; forward;
procedure EbFindWnd(T: TScanThread; var S: string; F: Boolean); forward;
function EbPWS_F0A9(A0: string; A1: Integer; A2: Integer): string; forward;
function EbPWS_2884(A0: string; A1: Integer; A2: string): string; forward;
function EbWnd(T: TScanThread): Integer; forward;
function EbSelWnd(T: TScanThread): Integer; forward;
procedure ScanSplitGuardZ; forward;
procedure StandardHintFont(AFont: TFont); forward;
function WidthOf(R: TRect): Integer; forward;
function HeightOf(R: TRect): Integer; forward;

procedure TScanThread.PrepareScreenBitmap;
begin
  try
    if ScreenBmp <> nil then
      ScreenBmp.Free;
    ScreenBmp := Graphics.TBitmap.Create;
    ScreenBmp.PixelFormat := pf24bit;
    ScreenBmp.Width := 1;
    ScreenBmp.Height := 1;
  except
    Msg := 'Ошибка выполнения скрипта 3313 ';
    Synchronize(ShowScriptHint);
  end;
end;

procedure LoadImageFile(T: TScanThread);
var
  Y: Cardinal;
  V: Integer;
  C0: Integer;
  Found: Boolean;
  i: Integer;
  Tmp: Integer;
  Cnt: Integer;
  Token: DWORD;
  Img: Pointer;
  Stride: Integer;
  nMode: Integer;
  Stm: IStream;
  NewPos: Int64;
  SI: TGdiplusStartupInput;
  BD: TGpBitmapData;
  R: TGpRect;
  Cid: TGUID;
  MS: TMemoryStream;
  Src: Pointer;
  P: PByteArray;
  X: Cardinal;
  a, b: Integer;
  Err: DWORD;
  { Перевод строки в WideChar считается ОТДЕЛЬНЫМ оператором, а не внутри
    списка доводов: иначе `@Img` уходит в стек раньше, чем готова строка.
    Слота в кадре не занимает -- значение живёт в регистре до самого вызова. }
  PW: PWideChar;
begin
  Stride := 0;
  nMode := T.CapWnd;
  case nMode of
    0, 1:
    begin
    Img := nil;
    FillChar(SI, SizeOf(SI), 0);
    SI.GdiplusVersion := 1;
    GdiplusStartup(Token, @SI, nil);
    PW := PWideChar(WideString(T.ImgFile));
    GdipCreateBitmapFromFile(PW, Img);
    Err := GetLastError;
    if Err <> 0 then
    begin
      T.CapWnd := Integer(Err) * -1;
      GdipDisposeImage(Img);
      GdiplusShutdown(Token);
      Exit;
    end;
    GdipGetImageWidth(Img, V);
    T.CapW := V;
    GdipGetImageHeight(Img, V);
    T.CapH := V;
    if GetEncoderClsid('image/bmp', Cid) > 0 then
    begin
      T.Msg := 'Не удалось закодировать картинку.';
      { Data метода-указателя берётся ГОЛЫМ именем, без приведения: с
        приведением оба значения сливаются в одно и вызов выходит длиннее. }
      TScanThread(T).Synchronize(T.SyncLogMsg);
    end;
    if gDlg59671Ct7.Visible then
    begin
      MS := TMemoryStream.Create;
      Stm := nil;
      Stm := TStreamAdapter.Create(MS, soReference) as IStream;
      GdipSaveImageToStream(Img, Stm, @Cid, nil);
      Stm.Seek(0, 0, NewPos);
      gProcImageer.Picture.Bitmap.LoadFromStream(MS);
      Stm := nil;
      MS.Free;
    end;
    R.X := 0;
    R.Y := 0;
    R.Width := T.CapW;
    R.Height := T.CapH;
    GdipBitmapLockBits(Img, @R, 3, PixelFormat24bppRGB, @BD);
    Stride := BD.Stride;
    T.ShotSize := Abs(Integer(BD.Height) * BD.Stride);
    T.ShotBits := Pointer(GlobalAlloc(GPTR, T.ShotSize));
    if BD.Stride > 0 then
      Src := BD.Scan0
    else
      Src := Pointer(Integer(BD.Scan0) - (T.ShotSize - Abs(BD.Stride)));
    T.BottomUp := BD.Stride > 0;
    CopyMemory(T.ShotBits, Src, T.ShotSize);
    T.Lock.W := BD.Width;
    T.Lock.H := BD.Height;
    T.Lock.Stride := BD.Stride;
    T.Lock.Handle := THandle(T.ShotBits);
    GdipBitmapUnlockBits(Img, @BD);
    GdipDisposeImage(Img);
    GdiplusShutdown(Token);
    end;
  end;
  case nMode of
    2: Stride := T.Fld44A0;
  end;
  { Здесь именно `if`, а не `case`: `case nMode of 0, 2:` разворачивается
    длиннее, а два употребления довода с приведением кладут его в регистр
    и дают `sub` вместо `cmp`. }
  if (Integer(nMode) = 0) or (Integer(nMode) - 2 = 0) then
    begin
    P := PByteArray(T.ShotBits);
    C0 := P[0] * $10000 + P[1] * $100 + P[2];
    for Y := 0 to Cardinal(T.CapH) - 1 do
    begin
      P := PByteArray(Integer(T.ShotBits) + Stride * Integer(Y));
      X := 0;
      while X <= Cardinal(T.CapW * 3 - 1) do
      begin
        V := P[X] * $10000 + P[X + 1] * $100 + P[X + 2];
        if V <> C0 then
        begin
          Found := False;
          for i := 0 to Length(T.ImgPts) - 1 do
            if T.ImgPts[i] = Cardinal(V) then
            begin
              Inc(T.ImgTol[i]);
              Found := True;
              Break;
            end;
          if not Found then
          begin
            Cnt := Length(T.ImgPts) + 1;
            SetLength(T.ImgPts, Cnt);
            SetLength(T.ImgTol, Cnt);
            T.ImgPts[Cnt - 1] := V;
            T.ImgTol[Cnt - 1] := 1;
          end;
        end;
        { Лишнее упоминание `X` стоит внутри цикла нарочно: снаружи оно ничего
          не даёт, а здесь переворачивает раздачу регистров -- `T` остаётся
          в ESI, `X` уходит в EBX. Хватает одного. }
        X := X;
        Inc(X, 3);
      end;
    end;
    i := Length(T.ImgTol) - 1;
    for a := 0 to i do
      for b := a + 1 to i do
        if T.ImgTol[a] > T.ImgTol[b] then
        begin
          Tmp := T.ImgTol[b];
          T.ImgTol[b] := T.ImgTol[a];
          T.ImgTol[a] := Tmp;
          Tmp := T.ImgPts[b];
          T.ImgPts[b] := T.ImgPts[a];
          T.ImgPts[a] := Tmp;
        end;
    SetLength(T.ImgList, T.CapW * T.CapH, 3);
    Tmp := 0;
    for i := 0 to Length(T.ImgPts) - 1 do
      for Y := 0 to Cardinal(T.CapH) - 1 do
      begin
        P := PByteArray(Integer(T.ShotBits) + Stride * Integer(Y));
        X := 0;
        while X <= Cardinal(T.CapW * 3 - 1) do
        begin
          V := P[X] * $10000 + P[X + 1] * $100 + P[X + 2];
          if (V <> C0) and (T.ImgPts[i] = Cardinal(V)) then
          begin
            Inc(Tmp);
            T.ImgList[Tmp - 1][0] := X div 3;
            T.ImgList[Tmp - 1][1] := Y;
            T.ImgList[Tmp - 1][2] := V;
          end;
          Inc(X, 3);
        end;
      end;
    T.CapWnd := Tmp;
    SetLength(T.ImgList, Tmp, 3);
    end;
  { И здесь `if`, а не `case`. Голое `if nMode = 0` сравнивает прямо с
    памятью, без загрузки; `shl 0` не стоит ни одной команды, но требует
    регистра -- и значение всё-таки материализуется. }
  if (Integer(nMode) shl 0) = 0 then
    GlobalFree(THandle(T.ShotBits));
  T.ShotBits := nil;
end;

procedure TScanThread.CaptureWindowBits;
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
  Self.ShotBits := nil;
  PTo := Self.CapTo;
  PFrom := Self.CapFrom;
  W := PTo.X;
  Self.ShotW := W - PFrom.X;
  H := PTo.Y;
  Self.ShotH := H - PFrom.Y;
  DC := GetDC(0);
  if DC = 0 then
  begin
    Self.Msg := 'Поверхность неровная.';
    Self.Synchronize(Self.SyncLogMsg);
  end;
  try
    MemDC := CreateCompatibleDC(DC);
    if MemDC = 0 then
    begin
      Self.Msg := 'Не удалось выровнять поверхность.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    if Self.CapWnd = 2 then
    begin
      Bmp := CreateCompatibleBitmap(DC, Self.ShotW, Self.ShotH);
      if Bmp = 0 then
      begin
        Self.Msg := 'Не удалось создать картинку.';
        Self.Synchronize(Self.SyncLogMsg);
      end;
      OldBmp := SelectObject(MemDC, Bmp);
      if (OldBmp = 0) or (OldBmp = HGDI_ERROR) then
      begin
        Self.Msg := 'Не удалось выбрать картинку.';
        Self.Synchronize(Self.SyncLogMsg);
      end;
      OK := BitBlt(MemDC, 0, 0, Self.ShotW, Self.ShotH, DC, PFrom.X, PFrom.Y, SRCCOPY);
      if not OK then
      begin
        Self.Msg := 'Не удалось скопировать картинку.';
        Self.Synchronize(Self.SyncLogMsg);
      end;
    end
    else
    begin
      Bmp := CreateCompatibleBitmap(DC, W, H);
      if Bmp = 0 then
      begin
        Self.Msg := 'Не удалось создать картинку.';
        Self.Synchronize(Self.SyncLogMsg);
      end;
      OldBmp := SelectObject(MemDC, Bmp);
      if (OldBmp = 0) or (OldBmp = HGDI_ERROR) then
      begin
        Self.Msg := 'Не удалось выбрать картинку.';
        Self.Synchronize(Self.SyncLogMsg);
      end;
      PrintWindow(Self.CapWnd, MemDC, 0);
      OK := BitBlt(MemDC, 0, 0, Self.ShotW, Self.ShotH, MemDC, PFrom.X, PFrom.Y, SRCCOPY);
      if not OK then
      begin
        Self.Msg := 'Не удалось скопировать картинку повторно.';
        Self.Synchronize(Self.SyncLogMsg);
      end;
    end;
    Img := nil;
    FillChar(SI, SizeOf(SI), 0);
    SI.GdiplusVersion := 1;
    if GdiplusStartup(Token, @SI, nil) <> 0 then
    begin
      Self.Msg := 'С+ не запущен.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    if GdipCreateBitmapFromHBITMAP(Bmp, 0, Img) <> 0 then
    begin
      Self.Msg := 'Не удалось создать картинку из памяти.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    if GetEncoderClsid('image/bmp', Cid) > 0 then
    begin
      Self.Msg := 'Не удалось закодировать картинку.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    if gDlg59671Ct7.Visible then
    begin
      MS := TMemoryStream.Create;
      Stm := nil;
      Stm := TStreamAdapter.Create(MS, soReference) as IStream;
      GdipSaveImageToStream(Img, Stm, @Cid, nil);
      Stm.Seek(0, 0, NewPos);
      gProcImageer.Picture.Bitmap.LoadFromStream(MS);
      Stm := nil;
      MS.Free;
    end;
    R.X := 0;
    R.Y := 0;
    R.Width := Self.ShotW;
    R.Height := Self.ShotH;
    if GdipBitmapLockBits(Img, @R, 3, PixelFormat24bppRGB, @BD) <> 0 then
    begin
      Self.Msg := 'Не закрылось.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    Self.ShotSize := Abs(Integer(BD.Height) * BD.Stride);
    Self.ShotBits := Pointer(GlobalAlloc(GPTR, Self.ShotSize));
    if Self.ShotBits = nil then
    begin
      Self.Msg := 'Некуда копировать картинку.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    { строки DIB идут снизу вверх, когда Stride отрицательный: тогда началом
      кадра служит ПОСЛЕДНЯЯ строка. Знаковость разная (Height -- UINT,
      Stride -- Integer), поэтому произведение считается 64-битным. Внешнее
      приведение к 32 битам ОБЯЗАТЕЛЬНО: без него всё выражение сужается
      до imul. }
    if BD.Stride > 0 then
      Src := BD.Scan0
    else
      Src := Pointer(Integer(BD.Scan0) + (BD.Height - 1) * BD.Stride);
    Self.BottomUp := BD.Stride > 0;
    CopyMemory(Self.ShotBits, Src, Self.ShotSize);
    Self.Lock.W := BD.Width;
    Self.Lock.H := BD.Height;
    Self.Lock.Stride := BD.Stride;
    if GdipBitmapUnlockBits(Img, @BD) <> 0 then
    begin
      Self.Msg := 'Не открылось.';
      Self.Synchronize(Self.SyncLogMsg);
    end;
    GdipDisposeImage(Img);
    GdiplusShutdown(Token);
    SelectObject(MemDC, OldBmp);
    DeleteDC(MemDC);
    DeleteObject(Bmp);
    if not OK then
      Self.ShotFailed := True;
  except
    Self.ShotFailed := True;
    Self.Msg := 'Ошибка выполнения скрипта 3317 ';
    Self.Synchronize(Self.ShowScriptHint);
  end;
  ReleaseDC(0, DC);
end;

procedure TScanThread.SyncCaptureScreen;
var
  DC: HDC;
  Ofs: TPoint;
  Dim: TPoint;
  MemBmp: HBITMAP;
  OldBmp: HGDIOBJ;
  R: TRect;
  Bmp: Graphics.TBitmap;
  SW, SH: Integer;
  MemDC: HDC;
  Jpg: TJPEGImage;
begin
  Ofs := CapTo;
  Dim := CapFrom;
  try
    Bmp := Graphics.TBitmap.Create;
    Bmp.PixelFormat := pf24bit;
    case CapWnd of
      0:
        begin
          DC := GetDC(0);
          R := Rect(0, 0, Screen.Width, Screen.Height);
        end;
      1:
        begin
          if ClientWnd2 = 0 then
            CapWnd := GetForegroundWindow
          else
            CapWnd := ClientWnd2;
          DC := GetWindowDC(CapWnd);
          GetWindowRect(CapWnd, R);
        end;
    else
      DC := GetWindowDC(CapWnd);
      GetWindowRect(CapWnd, R);
    end;
    if (Dim.X = 0) or (Dim.X + Ofs.X > R.Right - R.Left) then
      Dim.X := R.Right - R.Left - Ofs.X;
    if (Dim.Y = 0) or (Dim.Y + Ofs.Y > R.Bottom - R.Top) then
      Dim.Y := R.Bottom - R.Top - Ofs.Y;
    SW := Screen.Width * 2;
    SH := Screen.Height * 2;
    if (SW < -Dim.X) or (Dim.X > SW) then
      Dim.X := SW div 2;
    if (SH < -Dim.Y) or (Dim.Y > SH) then
      Dim.Y := SH div 2;
    if (Ofs.X < 0) or (Ofs.X > SW) then
      Ofs.X := SW div 2;
    if (Ofs.Y < 0) or (Ofs.Y > SH) then
      Ofs.Y := SH div 2;
    Bmp.Width := Dim.X;
    Bmp.Height := Dim.Y;
    if CapWnd = 0 then
    begin
      BitBlt(Bmp.Canvas.Handle, 0, 0, Dim.X, Dim.Y, DC, Ofs.X, Ofs.Y, SRCCOPY);
      ReleaseDC(0, DC);
    end
    else
    begin
      MemDC := CreateCompatibleDC(DC);
      MemBmp := CreateCompatibleBitmap(DC, Dim.X + Ofs.X, Dim.Y + Ofs.Y);
      OldBmp := SelectObject(MemDC, MemBmp);
      PrintWindow(CapWnd, MemDC, 0);
      BitBlt(Bmp.Canvas.Handle, 0, 0, Dim.X, Dim.Y, MemDC, Ofs.X, Ofs.Y, SRCCOPY);
      SelectObject(MemDC, OldBmp);
      DeleteObject(MemBmp);
      DeleteDC(MemDC);
      ReleaseDC(CapWnd, DC);
    end;
    if LowerCase(Copy(Msg, Length(Msg) - 3, 4)) = '.jpg' then
    begin
      Jpg := TJPEGImage.Create;
      Jpg.Assign(Bmp);
      Jpg.CompressionQuality := fmSecondfj.SpinEdit1.Value;
      {$IFnDEF FPC}Jpg.Compress;{$ENDIF}
      Jpg.SaveToFile(Msg);
      Jpg.Free;
    end
    else
      Bmp.SaveToFile(Msg);
    Bmp.FreeImage;
    Bmp.Free;
  except
  end;
end;

procedure EbSaveImg(T: TScanThread);
{ Сохранить уже снятый блок пикселей в файл средствами GDI+: поднять
  GDI+, завернуть буфер строк `T.Lock` в битмап PixelFormat24bppRGB, взять
  CLSID кодировщика по MIME-имени и записать файл.

  Именно процедура, а не функция: ответа она не отдаёт вовсе.

  try..finally тут не свой -- его ставит компилятор ради временной
  WideString от `WideString(T.ImgFile)`, и весь finally из одного WStrClr.

  `T.CapWnd` здесь НЕ окно, а номер формата: 1 = bmp, 2 = jpeg, 3 = png.
  Кладёт его ветка `saveimage` по расширению имени файла.

  Ответ ни одного из пяти вызовов GDI+ не проверяется. }
var
  token: DWORD;
  img: Pointer;
  si: TGdiplusStartupInput;
  clsid: TGUID;
  pw: PWideChar;
begin
  FillChar(si, SizeOf(si), 0);
  si.GdiplusVersion := 1;
  GdiplusStartup(token, @si, nil);
  pw := PWideChar(WideString(T.ImgFile));
  img := nil;
  GdipCreateBitmapFromScan0(T.Lock.W, T.Lock.H, T.Lock.Stride,
    PixelFormat24bppRGB, Pointer(T.Lock.Handle), img);
  case T.CapWnd of
    1: GetEncoderClsid('image/bmp', clsid);
    2: GetEncoderClsid('image/jpeg', clsid);
    3: GetEncoderClsid('image/png', clsid);
  end;
  GdipSaveImageToFile(img, pw, @clsid, nil);
  GdipDisposeImage(img);
  GdiplusShutdown(token);
end;

function EbOpenThread(A: Cardinal; B: Boolean; C: Cardinal): Integer;
begin
  Result := 0;
end;

function EbFQG(T: TScanThread; const S: string; N: Integer;
               var A, B: Integer; var C: string): string;
begin
  Result := S;
end;

function EbPWS_2BE9(A0: string; A1: Integer; A2: string): string;
begin
  Result := A0;
end;


procedure TScanThread.Execute;
var
  { Раскладку кадра задаёт ПОРЯДОК УПОМИНАНИЯ в мёртвой HoldFrameZ, а не
    порядок объявления: W/WIdx/WaitStart тянут к себе ScanWatchList и
    DoWait, всё остальное раздаёт HoldFrameZ. }
  W: string;
  WIdx: Integer;
  WaitStart: Cardinal;
  Cnt: Int64;
  f1C: Integer;
  s20: string;
  s24: string;
  f28: Integer;
  f2C: Integer;
  f30: Integer;
  f34: Integer;
  f38: Integer;
  f3C: Integer;
  f40: Integer;
  f44: Integer;
  s48: string;
  f4C: Integer;
  f50: Integer;
  f54: Integer;
  f58: Integer;
  f5C: Integer;
  f60: Integer;
  f64: Integer;
  f68: Integer;
  N2: Integer;
  N1: Integer;
  f74: Integer;
  f78: Integer;
  Cmd: Integer;
  f080: Integer;
  f084: Integer;
  f088: Integer;
  f08C: Integer;
  f090: Integer;
  f094: Integer;
  f098: Integer;
  f09C: Integer;
  f0A0: Integer;
  f0A4: Integer;
  f0A8: Integer;
  f0AC: Integer;
  f0B0: Integer;
  f0B4: Integer;
  f0B8: Integer;
  f0BC: Integer;
  f0C0: Integer;
  f0C4: Integer;
  f0C8: Integer;
  f0CC: Integer;
  f0D0: Integer;
  f0D4: Integer;
  f0D8: Integer;
  f0DC: Integer;
  f0E0: Integer;
  f0E4: Integer;
  f0E8: Integer;
  f0EC: Integer;
  f0F0: Integer;
  f0F4: Integer;
  f0F8: Integer;
  f0FC: Integer;
  f100: Integer;
  f104: Integer;
  f108: Integer;
  f10C: Integer;
  f110: Integer;
  f114: Integer;
  f118: Integer;
  f11C: Integer;
  f120: Integer;
  f124: Integer;
  f128: Integer;
  f12C: Integer;
  f130: Integer;
  f134: Integer;
  s138: string;
  s13C: string;
  s140: string;
  S: string;
  f148: Integer;
  f14C: Integer;
  f150: Integer;
  f154: Integer;
  f158: Integer;
  f15C: Integer;
  f160: Integer;
  f164: Integer;
  f168: Integer;
  dA: array of TScriptVar;
  f170: Integer;
  s174: string;
  f178: Integer;
  dB: array of TColRec;
  I: Integer;
  K: Cardinal;
  P: Integer;
  Fin: Boolean;
  Qa: Integer;
  g000: Integer;
  g001: Integer;
  g002: Integer;
  g003: Integer;
  g004: Integer;
  g005: Integer;
  g006: Integer;
  g007: Integer;
  g008: Integer;
  g009: Integer;
  g010: Integer;
  g011: Integer;
  g012: Integer;
  g013: Integer;
  g014: Integer;
  g015: Integer;
  g016: Integer;
  g017: Integer;
  g018: Integer;
  g019: Integer;
  g020: Integer;
  g021: Integer;
  g022: Integer;
  Pad: array[1..3652] of Byte;
label
  Restart, Again, ScanLoop, NoLua, RunCmd, NextLine;
  { fmSecondfj перечитывается на каждом из 13 обращений -- кэшировать его
    в локальной здесь нельзя. }
  { Разбор строки запуска процедуры (Self.Params): слова начиная со ВТОРОГО
    объявляются наблюдаемыми величинами. Первый символ слова задаёт вид --
    '#' число, '$' строка, '%' матрица, -- а значение берётся из
    Self.Arr43F0[N-2]. Шесть обнулённых счётчиков и обе строки в конце
    складываются в Res, который никто не читает. }
  procedure ScanWatchList;
  var
    Wd: string;
    Res: string;
    Pfx: string;
    Line: string;
    V: string;
    Sub: string;
    n1: Integer;
    n2: Integer;
    X: Integer;
    Y: Integer;
    Idx: Integer;
    N: Integer;
    Cnt: Integer;
    A: Integer;
    { Под копию индекса заведена ОТДЕЛЬНАЯ переменная, а не `Cnt`: живёт она
      в том же регистре и кода не стоит ни одной команды, зато снимает с
      `Cnt` лишний вес, и пара ESI/EDI не переворачивается. }
    Ix: Integer;
    Tab: TScanThread;
    C: Char;
  begin
    Res := '';
    Pfx := '';
    Cnt := 0;
    A := 0;
    n1 := 0;
    n2 := 0;
    X := 0;
    Y := 0;
    Line := Self.Params;
    N := 2;
    Wd := EvalScriptPoint(Self, Self.Params, N);
    while Wd <> '' do
    begin
      W := Wd;
      if ((W[1] = '#') or (W[1] = '$') or (W[1] = '%')) and (Length(W) >= 2) then
      begin
        C := W[1];
        Delete(W, 1, 1);
        if Length(Self.Arr43F0) > N - 2 then
          V := Self.Arr43F0[N - 2]
        else if C = '#' then
          V := '0'
        else
          V := '';
        case C of
          '#':
            begin
              WIdx := FindScriptVar(Self, '#', W, X, Y);
              W := V;
              StoreScriptVar(Self, '#', WIdx, Res, Cnt, W, X, Y);
            end;
          '$':
            begin
              WIdx := FindScriptVar(Self, '$', W, X, Y);
              W := V;
              StoreScriptVar(Self, '$', WIdx, Res, Cnt, W, X, Y);
            end;
          '%':
            begin
              X := 1;
              Y := 1;
              WIdx := FindScriptVar(Self, '%', W, X, Y);
              Idx := WIdx;
              Delete(V, 1, 1);
              V := AnsiLowerCase(V);
              Cnt := Pos('.', V);
              if Cnt > 0 then
              begin
                Sub := V;
                Delete(Sub, 1, Cnt);
                V := Copy(V, 1, Cnt - 1);
                A := TScanThread(Self).ScriptStrToInt(Sub);
                Tab := gScriptso3[A];
              end
              else
                Tab := Self.Owner43D0;
              WIdx := 0;
              Cnt := Length(Tab.Arr48);
              if Cnt > WIdx then
                repeat
                  if Tab.Arr48[WIdx].Name = V then
                    Break;
                  Inc(WIdx);
                until Cnt <= WIdx;
              if Cnt <= WIdx then
                with TScanThread(Tab) do
                begin
                  SetLength(Arr48, Length(Arr48) + 1);
                  Arr48[WIdx].Name := V;
                end;
              Ix := WIdx;
              Self.Arr48[Idx].Data := Tab.Arr48[Ix].Data;
            end;
        end;
      end
      else
      begin
        Self.StopRequested := True;
        Self.Flag91 := False;
        if gLangOffsety > 0 then
          Self.Msg := '(' + IntToStr(N) + LoadStr(gLangOffsety + $1BA)
        else
          Self.Msg := '(' + IntToStr(N) + '): Не могу определить имя переменной';
        ShowScriptMsg(TScanThread(Self));
        Exit;
      end;
      Res := '';
      Pfx := '';
      Cnt := 0;
      A := 0;
      n1 := 0;
      n2 := 0;
      X := 0;
      Y := 0;
      N := N + 1;
      Wd := EvalScriptPoint(Self, Self.Params, N);
    end;
    { Слагаемых шесть -- те же шесть обнулённых счётчиков и в том же
      порядке, что в блоке обнуления. }
    Res := Pfx + IntToStr(Cnt + A + n1 + n2 + X + Y);
  end;

  { Пауза между строками скрипта. Две булевы, а не одна: BigR живёт в
    регистре и выталкивает Cnt в ESI, а Big[0] -- массив из одного
    элемента, чтобы наверняка встать в кадр. Приведение
    `PWord(@gLangOffsety)^` во втором чтении убирает кэш gLangOffsety. }
  procedure DoWait(S: string);
  var
    Ms: Integer;
    Big: array[0..0] of Boolean;
    Mul: Integer;
    Cnt: Integer;
    BigR: Boolean;
  begin
    if S = '' then
      Exit;
    if S = '0' then
      Exit;
    if S = '1' then
    begin
      SysUtils.Sleep(1);
      Exit;
    end;
    WaitStart := GetTickCount;
    if not TryStrToInt(S, Ms) then
    begin
      if gLangOffsety > 0 then
        Self.Msg := LoadStr(PWord(@gLangOffsety)^ + $1A9)
      else
        Self.Msg := 'Неправильно указана задержка между строк.';
      case UpCase(S[Length(S)]) of
        'S':
          begin
            Mul := 1000;
            Delete(S, Length(S), 1);
          end;
        'M':
          begin
            Mul := 60000;
            Delete(S, Length(S), 1);
          end;
        'H':
          begin
            Mul := 3600000;
            Delete(S, Length(S), 1);
          end;
        'C':
          begin
            Mul := 1000;
            Delete(S, Length(S) - 2, 3);
          end;
        'N':
          begin
            Mul := 60000;
            Delete(S, Length(S) - 2, 3);
          end;
        'R':
          begin
            Mul := 3600000;
            Delete(S, Length(S) - 3, 4);
          end;
      else
        begin
          Self.StopRequested := True;
          ShowScriptMsg(TScanThread(Self));
          Exit;
        end;
      end;
      try
        Ms := StrToInt(S) * Mul;
      except
        Self.StopRequested := True;
        ShowScriptMsg(TScanThread(Self));
        Exit;
      end;
    end;
    Cnt := 0;
    BigR := Ms > 1000;
    Big[0] := BigR and Self.ShowRemainingWait;
    if Big[0] and Self.AutoStart then
    begin
      Self.ShowWait := True;
      Self.Msg := IntToStr(Ms);
      Self.Synchronize(Self.SyncShowWait);
    end;
    Inc(Ms, WaitStart);
    repeat
      if Self.StopRequested then
      begin
        if Big[0] and Self.AutoStart then
        begin
          Self.ShowWait := False;
          Self.Msg := '';
          Self.Synchronize(Self.SyncShowWait);
        end;
        Exit;
      end;
      SysUtils.Sleep(1);
      if Self.AutoStart and BigR then
        if Self.ShowRemainingWait then
        begin
          if Cnt = 10 then
            if GetTickCount + 150 < Cardinal(Ms) then
            begin
              Self.ShowWait := True;
              Self.Msg := IntToStr(Cardinal(Ms) - GetTickCount);
              Self.Synchronize(Self.SyncShowWait);
              Cnt := 0;
            end;
          Cnt := Cnt + 1;
        end;
    until GetTickCount >= Cardinal(Ms);
    if Big[0] and Self.AutoStart then
    begin
      Self.ShowWait := False;
      Self.Msg := '';
      Self.Synchronize(Self.SyncShowWait);
    end;
  end;
  { Вложенная, а не юнитовая, и стоит ПОСЛЕ `DoWait`: вложенные тела
    выпускаются перед телом родителя, и порядок здесь важен.
    Статической ссылки не заводит -- тело не трогает ни одного локала
    родителя. }

  function StripComment(S: string): string;
  var
    { Тип `L` здесь ЗНАКОВЫЙ -- единственное отличие от близнеца
      `CutComment`, где он Cardinal: там сравнение уходит в Int64, здесь
      остаётся одной командой. }
    L: Integer;
    P, N, I: Integer;      { перестановка объявлений раскладку не меняет:
                             I и N живут в регистрах, а не в кадре }
    { Позиция последней кавычки: запоминается и нигде не читается --
      недоделанный остаток. Команд от неё не выходит ни одной, зато второе
      чтение `I` в теле цикла перевешивает скрытый счётчик `for`: без него
      счётчик забирает регистр, а `I` уезжает в другой. }
    J: Integer;
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
          begin
            Inc(N);
            J := I;
          end;
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


  { Никем не вызывается. Держит кадр и ЗАДАЁТ ПОРЯДОК слотов: локалы,
    видимые вложенным процедурам, раздаются в порядке ПЕРВОГО УПОМИНАНИЯ,
    а не объявления, и список ниже задаёт этот порядок. }
  procedure HoldFrameZ;
  begin
    Cnt := 0;
    f1C := 0;
    if s20 <> '' then Exit;
    if s24 <> '' then Exit;
    f28 := 0;
    f2C := 0;
    f30 := 0;
    f34 := 0;
    f38 := 0;
    f3C := 0;
    f40 := 0;
    f44 := 0;
    if s48 <> '' then Exit;
    f4C := 0;
    f50 := 0;
    f54 := 0;
    f58 := 0;
    f5C := 0;
    f60 := 0;
    f64 := 0;
    f68 := 0;
    N2 := 0;
    N1 := 0;
    f74 := 0;
    f78 := 0;
    Cmd := 0;
    f080 := 0;
    f084 := 0;
    f088 := 0;
    f08C := 0;
    f090 := 0;
    f094 := 0;
    f098 := 0;
    f09C := 0;
    f0A0 := 0;
    f0A4 := 0;
    f0A8 := 0;
    f0AC := 0;
    f0B0 := 0;
    f0B4 := 0;
    f0B8 := 0;
    f0BC := 0;
    f0C0 := 0;
    f0C4 := 0;
    f0C8 := 0;
    f0CC := 0;
    f0D0 := 0;
    f0D4 := 0;
    f0D8 := 0;
    f0DC := 0;
    f0E0 := 0;
    f0E4 := 0;
    f0E8 := 0;
    f0EC := 0;
    f0F0 := 0;
    f0F4 := 0;
    f0F8 := 0;
    f0FC := 0;
    f100 := 0;
    f104 := 0;
    f108 := 0;
    f10C := 0;
    f110 := 0;
    f114 := 0;
    f118 := 0;
    f11C := 0;
    f120 := 0;
    f124 := 0;
    f128 := 0;
    f12C := 0;
    f130 := 0;
    f134 := 0;
    if s138 <> '' then Exit;
    if s13C <> '' then Exit;
    if s140 <> '' then Exit;
    if S <> '' then Exit;
    f148 := 0;
    f14C := 0;
    f150 := 0;
    f154 := 0;
    f158 := 0;
    f15C := 0;
    f160 := 0;
    f164 := 0;
    f168 := 0;
    if Length(dA) <> 0 then Exit;
    f170 := 0;
    if s174 <> '' then Exit;
    f178 := 0;
    if Length(dB) <> 0 then Exit;
    g000 := 0;
    g001 := 0;
    g002 := 0;
    g003 := 0;
    g004 := 0;
    g005 := 0;
    g006 := 0;
    g007 := 0;
    g008 := 0;
    g009 := 0;
    g010 := 0;
    g011 := 0;
    g012 := 0;
    g013 := 0;
    g014 := 0;
    g015 := 0;
    g016 := 0;
    g017 := 0;
    g018 := 0;
    g019 := 0;
    g020 := 0;
    g021 := 0;
    g022 := 0;
    Pad[1] := 0;
  end;
begin
  Self.FreeOnTerminate := True;
  if Self.LogToParent and not Self.StopRequested then
  begin
    Self.StartTick := 0;
    StartScriptThread(Self);
    ScanWatchList;
    Self.FreeOnTerminate := False;
  end
  else
    Self.Owner43D0 := nil;
  Self.OnTerminate := ScriptTerminated;
  Self.SubScript := nil;
  Self.Str1048B8 := '';
  Self.CurLine := -1;
  while True do
  begin
    try
Restart:
      Self.RestartFlag := False;
      try
        if Self.DebugForm <> nil then
          FreeAndNil(Self.DebugForm);
      except
        Self.Msg := 'Error while closing Lua virtual mashine'#0;
        ShowScriptMsg(TScanThread(Self));
      end;
      if not Self.LogToParent then
        StartScriptThread(Self);
      if Self.LogToParent and Self.StopRequested then
      begin
        Self.OnTerminate := nil;
        if Self.IsProc then
        begin
          Self.LogPrefix := 'proc ' + EvalScriptExpr(Self, Self.Params, 1);
          Self.Msg := 'finished';
          Synchronize(SyncLogMsg);
        end;
        Synchronize(SyncHideHint);
        Exit;
      end;
      if Self.AutoStart then
        UpdateScriptButtons(Self);
      if Self.StopRequested then
      begin
        if not Self.FreeOnTerminate then
          Exit;
        Suspend;
      end;
      if Self.StopRequested then
      begin
        StartScriptThread(Self);
        Self.Flag91 := False;
        goto Restart;
      end;
      Self.InLua := False;
      Self.VarGridBusy := True;
      Self.VarNames.Clear;
      Self.VarNames.Add('timer');
      if Self.AutoStart then
        Self.StartLine := fmSecondfj.edScript.CaretY
      else
        Self.StartLine := Self.CaretY;
Again:
      if Self.VarNames = nil then
      begin
        Self.VarNames := TStringList.Create;
        Self.VarNames.Add('timer');
      end;
      Self.Masks := tMatchMaskList.Create('');
      Self.Masks.Flag9 := True;
      Self.Masks.MatchCase := False;
      Self.Obj43FC := TRegistry.Create;
      TRegistry(Self.Obj43FC).RootKey := HKEY_CURRENT_USER;
      if (Self.PerfFreq > 0) and QueryPerformanceCounter(Cnt) then
        Self.StartTick := Trunc(Cnt / Self.PerfFreq * 1000)
      else
      begin
        Qa := GetTickCount;
        Self.StartTick := Qa;
      end;
      Self.Tick1 := Self.StartTick;
      Self.Tick2 := Self.StartTick;
      Self.Tick3 := Self.StartTick;
      Self.Tick4 := Self.StartTick;
      Self.NextVarGrid := Self.StartTick;
      Self.ClickDelay := fmSecondfj.seMouseClicksDelay.Value;
      Self.SendDelay := fmSecondfj.seSendExDelayDef.Value;
      Self.PauseStr := fmSecondfj.edPauseNil.Text;
      Self.Fld10488C := $104;
      Self.Fld104890 := $DB;
      Self.ClVerIdx := fmSecondfj.cbClVer.ItemIndex;
      Self.NtUserIdx := fmSecondfj.cbNtUserPM.ItemIndex;
      N1 := 0;
      N2 := 0;
      Self.IsProc := False;
      Self.LogLevel := 1;
      if Self.AutoStart then
        Self.LoggingCommands := fmSecondfj.cbLoggingCommands.Checked
      else
        Self.LoggingCommands := False;
      Self.Cnt105BC8 := 0;
      Self.Cnt104674 := 0;
      Self.Cnt104678 := 0;
      Self.Cnt10467C := 0;
      Self.Cnt104680 := 0;
ScanLoop:
      while True do
      begin
        Self.StopOnPause := False;
        Self.ShowRemainingWait := fmSecondfj.miShowRemainingWait.Checked;
        if Self.StopRequested then
        begin
          StartScriptThread(Self);
          Self.Flag91 := False;
          goto Restart;
        end;
        SysUtils.Sleep(0);
        Self.CurLine := 0;
        while Length(Self.Lines) > Self.CurLine do
        begin
          Self.ClientWnd2 := Self.ClientWnd;
          Self.ProcessHandle2 := Self.ProcessHandle;
          Self.ShowRun := fmSecondfj.sbScriptProcessing.Down;
          if Self.StopRequested then
          begin
            StartScriptThread(Self);
            Self.Flag91 := False;
            goto Restart;
          end;
          if not Self.Flag91 then
          begin
            Suspend;
            goto Again;
          end;
          Self.LineCount := Self.CurLine;
          if Self.AutoStart and fmSecondfj.miShowScriptProcessing.Checked then
            Synchronize(TScanThread(Self).SyncShowRunLine);
          if Self.Paused then
          begin
            if Self.SubScript <> nil then
              Self.SubScript.Paused := True;
            Suspend;
            if Self.SubScript <> nil then
            begin
              Self.SubScript.Paused := False;
              Self.SubScript.Resume;
            end;
            Self.ShowRemainingWait := fmSecondfj.miShowRemainingWait.Checked;
            Self.SendDelay := fmSecondfj.seSendExDelayDef.Value;
            Self.CurLine := Self.LineCount;
            if Self.StopRequested then
              goto ScanLoop;
          end;
          if Self.ShowRun and Self.AutoStart and (GetTickCount > Self.NextVarGrid)
            and fmSecondfj.miShowTimerVar.Checked then
          begin
            Self.NextVarGrid := GetTickCount + $80;
            Self.VarGridBusy := False;
            Self.VarName := 'timer';
            K := GetTickCount;
            Self.VarValue := IntToStr(Integer(K) - Self.StartTick);
            Synchronize(TScanThread(Self).SyncUpdateVarGrid);
          end;
          Self.Line := Self.Lines[Self.CurLine];
          S := AnsiLowerCase(Self.Line);
          if (S = '--lua') or (S = '-- lua') then
          begin
            if Self.DebugForm = nil then
            begin
              try
                Self.DebugForm := TForm(TLua.Create);
                if gLuaErrorCcl <> '' then
                begin
                  Self.Msg := gLuaErrorCcl + #0;
                  Synchronize(SyncLogMsg);
                  gLuaErrorCcl := '';
                end;
              except
                Self.Msg := 'Error while creating Lua virtual mashine'#13#10 +
                  gLuaErrorCcl + #0;
                ShowScriptMsg(TScanThread(Self));
              end;
            end;
            if gLuaAvail7 then
            begin
              Self.ClientWnd2 := Self.ClientWnd;
              Self.ProcessHandle2 := Self.ProcessHandle;
              Self.Line := '';
              Fin := False;
              for I := Self.CurLine to Length(Self.Lines) - 1 do
              begin
                Self.CurLine := I;
                S := AnsiLowerCase(Self.Lines[I]);
                if (S = '--endlua') or (S = '-- endlua') then
                begin
                  Fin := True;
                  Break;
                end;
                Self.Line := Self.Line + Self.Lines[I] + #13#10;
              end;
              Self.LuaUnclosed := not Fin;
              Self.InLua := True;
              RunLuaScript(Self);
              Self.InLua := False;
            end;
            Self.Line := '';
            if not Self.LuaUnclosed then
              goto NextLine;
            Self.StopRequested := True;
            if Self.AutoStart then
            begin
              Self.CaretY := Self.StartLine;
              Synchronize(TScanThread(Self).SyncRestoreCaret);
            end;
          end;
NoLua:
          Self.RepeatLine := False;
          if Self.Line = '' then
          begin
            DoWait(Self.PauseStr);
            if Self.StopRequested then
              goto ScanLoop;
            Inc(Self.CurLine);
            Continue;
          end;
          Self.Line := StripComment(Self.Line);
          K := Length(Self.Line);
          while (K > 0) and ((Self.Line[K] = ' ') or (Self.Line[K] = #9)) do
            Dec(K);
          Self.Line := Copy(Self.Line, 1, K);
          K := Pos('(*', Self.Line);
          if K > 0 then
          begin
            Fin := False;
            Dec(K);
            while K > 0 do
            begin
              if not (Self.Line[K] in [#9, ' ']) then
              begin
                Fin := True;
                Break;
              end;
              Dec(K);
            end;
            if not Fin then
            begin
              Inc(Self.CurLine);
              while Length(Self.Lines) > Self.CurLine do
              begin
                K := Pos('*)', Self.Lines[Self.CurLine]);
                if K > 0 then
                begin
                  Fin := False;
                  Dec(K);
                  while K > 0 do
                  begin
                    { Кривовато: позиция K найдена в Lines[CurLine] -- в
                      строке, ГДЕ КОММЕНТАРИЙ ЗАКРЫВАЕТСЯ, а символы берутся из
                      Self.Line, то есть из строки, где он ОТКРЫЛСЯ. }
                    if not (Self.Line[K] in [#9, ' ']) then
                    begin
                      Fin := True;
                      Break;
                    end;
                    Dec(K);
                  end;
                  if not Fin then
                    goto NextLine;
                  Break;
                end;
                Inc(Self.CurLine);
              end;
            end;
          end;
          if Self.Line = '' then
          begin
            DoWait(Self.PauseStr);
            if Self.StopRequested then
              goto ScanLoop;
            Inc(Self.CurLine);
            Continue;
          end;
          Self.LogPrefix := EvalScriptExpr(Self, Self.Line, 0);
          if Self.LogPrefix = '' then
          begin
            if not (Self.AutoStart and Self.Debug and Self.Paused) then
              DoWait(Self.PauseStr);
            if Self.StopRequested then
              goto ScanLoop;
            goto NextLine;
          end;
          if not (Self.AutoStart and Self.Debug and Self.Paused) then
            DoWait(Self.PauseCmd);
          if Self.StopRequested then
            goto ScanLoop;
          if fmSecondfj.miPauseSOnClientClose.Checked then
          begin
            K := WaitForInputIdle(Self.ProcessHandle2, 0);
            if K <> 0 then
            begin
              if K = WAIT_TIMEOUT then
              begin
                Self.Paused := True;
                if gLangOffsety > 0 then
                  Self.Msg := LoadStr(gLangOffsety + $1DC) + #0
                else
                  Self.Msg := 'Клиент скорее мертв, чем жив...'#0;
              end
              else
              begin
                Self.Paused := True;
                if gLangOffsety > 0 then
                  Self.Msg := LoadStr(gLangOffsety + $1DD) + #0
                else
                  Self.Msg := 'Клиент мертв...'#0;
              end;
              if Self.AutoStart then
                Synchronize(TScanThread(Self).PauseScriptThread);
              ShowScriptMsg(TScanThread(Self));
              Dec(Self.CurLine);
              goto NextLine;
            end;
          end;
          P := Pos('(', Self.LogPrefix);
          if P > 0 then
          begin
            Insert(' ', Self.Line, P);
            Self.LogPrefix := EvalScriptExpr(Self, Self.Line, 0);
          end;
          P := Pos(':', Self.LogPrefix);
          if P > 1 then
            Self.LogPrefix := Copy(Self.LogPrefix, 1, P - 1);
          Cmd := gCmdList2jj.IndexOf(Self.LogPrefix);
RunCmd:
          ExecScriptCommand(TScanThread(Self), Cmd, Self.Line);
NextLine:
          if Self.RestartFlag then
            goto Restart;
          if Self.RepeatLine then
            goto NoLua;
          if Self.RepeatCmd then
            goto RunCmd;
          Inc(Self.CurLine);
        end;
        Self.CurLine := 0;
      end;
    except
      on E: Exception do
        Self.Msg := E.ClassName + ' ' + E.Message;
    else
      begin
        if gLangOffsety > 0 then
          Self.Msg := 'Unknown'#0
        else
          Self.Msg := 'Абсолютно неизвестная ошибка.'#0;
        Synchronize(TScanThread(Self).ShowScriptHint);
        Synchronize(SyncLogMsg);
      end;
    end;
    StartScriptThread(Self);
    if gLangOffsety > 0 then
      Self.Msg := '(' + IntToStr(Self.CurLine) + LoadStr(gLangOffsety + $1DF) + Self.Msg
    else
      Self.Msg := '(' + IntToStr(Self.CurLine) +
        '): Ошибка! Проверьте правильность скрипта! '#13#10 + Self.Msg;
    Self.Msg := Self.Msg + #13 + #10 + Self.Line + #0;
    if not Self.StopRequested or (Copy(Self.Lines[0], 1, 2) <> '--') then
      ShowScriptMsg(TScanThread(Self));
    Self.StopRequested := True;
    Self.Flag91 := False;
    Self.Paused := False;
  end;
end;

procedure TScanThread.SyncShowWait;
begin
  fmSecondfj.pRestWait.Visible := ShowWait;
  fmSecondfj.lRestWait.Caption := Msg;
end;

{$I-}
procedure TScanThread.SyncShowRunLine;
var
  P, N, I: Integer;
begin
  N := Self.LineCount - 1;
  P := 0;
  for I := 0 to N do
    Inc(P, Length(Self.Lines[I]) + 2);
  fmSecondfj.edScript.SelStart := P;
  fmSecondfj.edScript.SelLength := 1;
  { два inc подряд, а не add reg,2: в исходнике две отдельные единицы }
  fmSecondfj.gScript.Progress := N + 1 + 1;
  fmSecondfj.pPos.Caption := IntToStr(Self.LineCount);
end;

{$I+}
procedure TScanThread.SyncRestoreCaret;
begin
  fmSecondfj.edScript.CaretY := CaretY;
  fmSecondfj.edScript.CaretX := 0;
end;

{$I-}
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
    FreeAndNil(T.Masks);
  except
  end;
  try
    for I := 1 to 10 do
      if T.Workers[I] <> nil then
      begin
        T.Workers[I].FStop := True;
        FreeAndNil(T.Workers[I]);
      end;
  except
  end;
  try
    for I := 1 to 10 do
      if T.Workers2[I] <> nil then
      begin
        T.Workers2[I].FStop := True;
        FreeAndNil(T.Workers2[I]);
      end;
  except
  end;
end;

{$I+}
procedure TScanThread.SyncUpdateVarGrid;
var
  N: Integer;
begin
  try
    N := Length(Vars) + Length(Timers) + 1;
    if fmSecondfj.miShowTimerVar.Checked then
      Inc(N)
    else if VarName = 'timer' then
      Exit;
    if N <> fmSecondfj.sgVar.RowCount then
    begin
      fmSecondfj.sgVar.RowCount := N;
      if fmSecondfj.sgVar.RowCount > 1 then
        fmSecondfj.sgVar.FixedRows := 1;
    end;
    if VarNames <> nil then
    begin
      if VarGridBusy or VarNameNew then
      begin
        VarNames.Add(VarName);
        VarGridBusy := False;
        VarNameNew := False;
      end;
      N := VarNames.IndexOf(VarName);
      if N >= 0 then
      begin
        if (N > 0) and not fmSecondfj.miShowTimerVar.Checked then
          Dec(N);
        if fmSecondfj.sgVar.Cells[0, N + 1] <> VarName then
          fmSecondfj.sgVar.Cells[0, N + 1] := VarName;
        fmSecondfj.sgVar.Cells[1, N + 1] := VarValue;
      end;
    end;
  except
    SyncUpdateVarGrid;
  end;
end;

procedure ShowScriptMsg(T: TScanThread);
var
  S: string;
  I: Integer;
begin
  if T.ClientWnd2 <> 0 then
    SetForegroundWindow(T.ClientWnd2);
  SysUtils.Sleep(1);
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
  if fmSecondfj.miToLog.Checked then
    TScanThread(T).Synchronize(T.SyncLogMsg);
  T.ToMsgBox := fmSecondfj.miToMessageBox.Checked;
  if T.ToMsgBox then
  begin
    if fmSecondfj.miRenameSelf.Checked then
      MsgBox(@T.Msg[1], PChar(fmSecondfj.miRenameSelf.Hint + ' Message  (' +
        T.Str43E0 + T.Name + ': ' + S + ')'), 0)
    else
      MsgBox(@T.Msg[1], PChar(Copy(fmSecondfj.Hint, 1, 7) + ' Message  (' +
        T.Str43E0 + T.Name + ': ' + S + ')'), 0);
  end
  else if fmSecondfj.miToHint.Checked then
  begin
    T.Msg := T.Name + ': ' + S + #13 + #10 + T.Msg + #0;
    TScanThread(T).ShowScriptHint;
  end;
end;

procedure TScanThread.SyncLogMsg;
begin
  LogCrLf := True;
  Move(Msg[1], LogBuf, Length(Msg));
  WriteScriptLog;
end;

{$I-}
procedure TScanThread.WriteScriptLog;
{$I-}
var
  S, A, Pfx: string;
  Trimmed: Boolean;
  Num: string;
  L: Integer;
  Tab: TScanThread;
begin
  if Self.LogLevel >= 1 then
  begin
    if fmSecondfj.miAutoOpenLog.Checked then
      if (gDlg5966F8c6 = nil) or not gDlg5966F8c6.Visible then
        fmSecondfj.miLogWindowClick(nil);
    if gCoordCaptureddo then
    begin
      S := TimeToStr(Time) + ' : ' + Self.Msg;
      gCoordCaptureddo := False;
    end
    else
    begin
      if Self.StopRequested then
        Exit;
      S := '';
      if Self.LogBuf[0] <> #0 then
      begin
        if not Self.LogCont then
        begin
          A := '';
          Pfx := '';
          Num := IntToStr(Self.LineCount + Self.LineBase);
          if Self.LogPrefix <> '' then
            Pfx := Self.LogPrefix + ' - ';
          if Self.LogFlags = 0 then
            S := TimeToStr(Time) + ' ' + Self.Name + ' (' + ExtractFileName(Self.Title) +
              ', ' + Num + ')' + ': ' + Pfx + PChar(@Self.LogBuf)
          else
          begin
            if Self.LogFlags and 1 = 0 then
            begin
              if Self.LogFlags and $10 = $10 then
                S := S + FormatDateTime('hh:nn:ss.zzz', Time) + ' '
              else
                S := S + TimeToStr(Time) + ' ';
            end;
            if Self.LogFlags and 2 = 0 then
              S := S + Self.Name;
            if Self.LogFlags and 4 = 0 then
              A := A + ' (' + ExtractFileName(Self.Title);
            if Self.LogFlags and 8 = 0 then
            begin
              if A = '' then
                A := A + ' ('
              else
                A := A + ', ';
              A := A + Num;
            end;
            if A <> '' then
              A := A + ')';
            if Self.LogFlags = $F then
              S := S + A + Pfx + PChar(@Self.LogBuf)
            else
              S := S + A + ': ' + Pfx + PChar(@Self.LogBuf);
          end;
        end
        else
          S := PChar(@Self.LogBuf);
      end;
    end;
    FillChar(Self.LogBuf, $4000, 0);
    Trimmed := False;
    if fmSecondfj.mLog.Lines.Count > $400 then
    begin
      L := Length(fmSecondfj.mLog.Lines.Text);
      fmSecondfj.mLog.Lines.Text := Copy(fmSecondfj.mLog.Lines.Text,
        PosEx(#13#10, fmSecondfj.mLog.Lines.Text, L div 2) + 2, L - L div 2);
      Trimmed := True;
    end;
    if not Self.LogCont then
      fmSecondfj.mLog.Lines.Add(S)
    else
      with fmSecondfj.mLog.Lines do
        Strings[Count - 1] := Strings[Count - 1] + S;
    if Self.LogToParent then
      Tab := Self.Owner43D0
    else
      Tab := TScanThread(Self.SelfRef);
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
    if not gLogFileClosedr then
    begin
      try
        if fmSecondfj.miLogging.Checked then
        begin
          if not gLogFileOpenar then
            if FileExists(gLogFileNamejr) then
              Append(gLogFilejr)
            else
              Rewrite(gLogFilejr);
          gLogFileOpenar := True;
          if Self.LogCrLf then
            { Write, а НЕ Writeln: перевод строки дописывается сам -- отсюда
              S + #13 + #10. }
            Write(gLogFilejr, S + #13 + #10)
          else
            Write(gLogFilejr, S);
          Flush(gLogFilejr);
          if Trimmed and (gLogMaxSizehk > 0) then
            if FileSize(gLogFilejr) > gLogMaxSizehk then
            begin
              CloseFile(gLogFilejr);
              S := gLogFileNamejr + '.bak';
              if FileExists(S) then
                SysUtils.DeleteFile(S);
              RenameFile(gLogFileNamejr, S);
              Rewrite(gLogFilejr);
            end;
        end;
      except
        fmSecondfj.mLog.Lines.Add('Can''t wrie to log file.');
        gLogFileClosedr := True;
      end;
    end;
    Self.LogCont := False;
    Self.LogCrLf := True;
  end;
end;

{$I+}
procedure TScanThread.SyncCreateWindow;
var
  L1: TLabel;
  L2: TLabel;
  Ed: TEdit;
  Items: array of string;
  S: string;
  K: Integer;
  Y: Integer;
  C: Integer;
  D: Integer;
  Lb: TLabel;
  Cb: TCheckBox;
  Lr: TLabel;
  Rb: TRadioButton;
  Pn: TPanel;
  Bt: TButton;
  I: Integer;
  N: Integer;
begin
  SetForegroundWindow(ClientWnd2);
  SysUtils.Sleep(1);
  SetForegroundWindow(Application.Handle);
  PromptWnd := TForm.Create(fmSecondfj);
  PromptWnd.Parent := nil;
  PromptWnd.Left := Fld10488C;
  PromptWnd.Top := Fld104890;
  PromptWnd.BorderStyle := bsDialog;
  PromptWnd.FormStyle := fsStayOnTop;
  S := ExtractFileName(Title);
  PromptWnd.Caption := 'UoPilot Prompt  (' + Str43E0 + Name + ': ' + S + ')';
  PromptWnd.ClientHeight := $3D;
  PromptWnd.ClientWidth := $C9;
  PromptWnd.OnClose := PromptClose;
  PromptWnd.Enabled := True;
  PromptWnd.KeyPreview := True;
  PromptWnd.OnKeyDown := PromptKeyDown;
  PromptWnd.Visible := False;
  D := 0;
  Pn := TPanel.Create(PromptWnd);
  Pn.Parent := PromptWnd;
  Pn.BevelInner := bvNone;
  Pn.BevelOuter := bvNone;
  Pn.Height := 1;
  Pn.Width := 1;
  Pn.Top := 0;
  Pn.Left := 0;
  Pn.Enabled := False;
  Y := 8;
  L1 := TLabel.Create(PromptWnd);
  L1.Parent := PromptWnd;
  L1.Left := 8;
  L1.Top := Y;
  L1.Width := $9A;
  L1.Height := $E;
  if (gLangOffsety = 2000) or (gLangOffsety = 0) then
    L1.Caption := 'Выберите значение:'
  else
    L1.Caption := 'Select value:';
  S := LogBuf;
  I := 1;
  K := 0;
  N := Length(S);
  while I <= N do
  begin
    while (S[I] <> #162) and (I <= N) do
      Inc(I);
    if S[I] = #162 then
    begin
      Inc(K);
      SetLength(Items, K + 1);
      Items[K] := '';
      Inc(I);
      while (S[I] <> #161) and (I <= N) do
      begin
        Items[K] := Items[K] + S[I];
        Inc(I);
      end;
    end;
    Inc(I);
  end;
  if not (PromptKind[1] in ['#', '$', '%']) then
  begin
    if Length(Items) <= 2 then
      PromptKind := '$'
    else
      PromptKind := '#';
  end;
  Ed := nil;
  L2 := TLabel.Create(PromptWnd);
  L2.Parent := PromptWnd;
  L2.Left := 0;
  L2.Top := 0;
  L2.Width := 0;
  L2.Height := $E;
  L2.Caption := '';
  if PromptKind[1] = '$' then
  begin
        N := Length(S);
        for I := 1 to N do
          if ((S[I] = '/') or (S[I] = '\')) and (S[I + 1] = 'n') then
          begin
            S[I] := #13;
            S[I + 1] := #10;
          end;
        L1.Caption := S;
        Y := L1.Height + Y + $11;
        Ed := TEdit.Create(PromptWnd);
        Ed.Parent := PromptWnd;
        Ed.Left := 8;
        Ed.Top := Y;
        I := L1.Width - $1C - 8;
        if I < $B5 then
          I := $B5;
        Ed.Width := I;
        Ed.Height := $15;
        Ed.Text := '';
    PromptWnd.Tag := 1;
  end
  else if PromptKind[1] = '%' then
  begin
        Y := L1.Height + Y + 1;
        C := 0;
        for I := 1 to Length(Items) - 1 do
        begin
          if (Length(Items[I]) > 0) and (Items[I][1] = '!') then
          begin
            Delete(Items[I], 1, 1);
            if I = 1 then
            begin
              L1.Caption := Items[I];
              D := -$10;
            end
            else
            begin
              Lb := TLabel.Create(PromptWnd);
              Lb.Parent := PromptWnd;
              Lb.Left := Lb.Height + 8;
              Lb.Top := I * $10 + Y;
              Lb.AutoSize := True;
              Lb.Height := $C;
              Lb.Caption := Items[I];
            end;
          end
          else
          begin
            Inc(C);
            L2.Caption := Items[I];
            Cb := TCheckBox.Create(PromptWnd);
            Cb.Parent := PromptWnd;
            Cb.Tag := C;
            Cb.Left := 8;
            Cb.Top := I * $10 + Y + D;
            Cb.Width := L2.Width + $14;
            Cb.Height := $C;
            Cb.Caption := Items[I];
            PromptWnd.Tag := C;
          end;
        end;
  end
  else
  begin
      Y := L1.Height + Y + 1;
      C := 0;
      for I := 1 to Length(Items) - 1 do
      begin
        if (Length(Items[I]) > 0) and (Items[I][1] = '!') then
        begin
          Delete(Items[I], 1, 1);
          if I = 1 then
          begin
            L1.Caption := Items[I];
            D := -$10;
          end
          else
          begin
            Lr := TLabel.Create(PromptWnd);
            Lr.Parent := PromptWnd;
            Lr.Left := Lr.Height + 8;
            Lr.Top := I * $10 + Y;
            Lr.AutoSize := True;
            Lr.Height := $C;
            Lr.Caption := Items[I];
          end;
        end
        else
        begin
          Inc(C);
          L2.Caption := Items[I];
          Rb := TRadioButton.Create(PromptWnd);
          Rb.Parent := PromptWnd;
          Rb.Tag := C;
          Rb.Left := 8;
          Rb.Top := I * $10 + Y + D;
          Rb.Width := L2.Width + $14;
          Rb.Height := $C;
          Rb.Caption := Items[I];
          Rb.OnMouseUp := PromptMouseUp;
          PromptWnd.Tag := C;
        end;
      end;
  end;
  L2.Free;
  L1.ShowHint := True;
  L1.Hint := PromptWnd.Caption;
  SetLength(Items, 0);
  PromptWnd.Visible := True;
  PromptWnd.AutoSize := True;
  Bt := TButton.Create(PromptWnd);
  Bt.Parent := PromptWnd;
  Bt.Height := $14;
  Bt.Width := $1C;
  Bt.Caption := 'Ok';
  Bt.Left := PromptWnd.ClientWidth - Bt.Width;
  if Bt.Left < $50 then
    Bt.Left := $50;
  if PromptKind = '$' then
    Bt.Top := PromptWnd.ClientHeight + 8
  else
    Bt.Top := PromptWnd.ClientHeight - $A;
  Bt.OnClick := PromptOkClick;
  Bt.SetFocus;
  Pn := TPanel.Create(PromptWnd);
  Pn.Parent := PromptWnd;
  Pn.BevelInner := bvNone;
  Pn.BevelOuter := bvNone;
  Pn.Height := 8;
  Pn.Width := 1;
  Pn.Top := PromptWnd.ClientHeight;
  Pn.Enabled := False;
  Pn := TPanel.Create(PromptWnd);
  Pn.Parent := PromptWnd;
  Pn.BevelInner := bvNone;
  Pn.BevelOuter := bvNone;
  Pn.Height := 1;
  Pn.Width := 8;
  Pn.Left := PromptWnd.ClientWidth;
  Pn.Enabled := False;
  if Ed <> nil then
    Ed.SetFocus;
  if PromptTime > 0 then
  begin
    if VarTimer <> nil then
      FreeAndNil(VarTimer);
    VarTimer := TTimer.Create(PromptWnd);
    VarTimer.Enabled := False;
    VarTimer.Interval := PromptTime * 1000;
    VarTimer.OnTimer := PromptTimer;
    VarTimer.Enabled := True;
  end;
end;

procedure TScanThread.PromptMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PromptWnd.Close;
end;

procedure TScanThread.PromptKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    PromptWnd.Close;
end;

procedure TScanThread.PromptTimer(Sender: TObject);
begin
  PromptWnd.Close;
end;

procedure TScanThread.PromptOkClick(Sender: TObject);
begin
  PromptWnd.Close;
end;

procedure TScanThread.SyncFreeTimers;
begin
  if VarTimer <> nil then
  begin
    VarTimer.Enabled := False;
    FreeAndNil(VarTimer);
  end;
  if PromptWnd <> nil then
    FreeAndNil(PromptWnd);
end;

procedure TScanThread.PromptClose(Sender: TObject;
  var Action: TCloseAction);
var
  K: Integer;
  Flags: array of Boolean;
  S: string;
  C: TComponent;
  I: Integer;
begin
  if VarTimer <> nil then
  begin
    VarTimer.Enabled := False;
    FreeAndNil(VarTimer);
  end;
  Msg := 'Error';
  SetLength(Flags, PromptWnd.Tag + 1);
  if PromptKind[1] = '$' then
  begin
    for I := PromptWnd.ComponentCount - 1 downto 0 do
    begin
      C := PromptWnd.Components[I];
      if C is TEdit then
      begin
        Msg := (C as TEdit).Text;
        Break;
      end;
    end;
  end
  else if PromptKind[1] = '%' then
  begin
    S := '';
    for I := PromptWnd.ComponentCount - 1 downto 0 do
    begin
      C := PromptWnd.Components[I];
      if C is TCheckBox then
        Flags[(C as TCheckBox).Tag] := (C as TCheckBox).Checked;
    end;
    for I := 1 to PromptWnd.Tag do
      S := S + IntToStr(Byte(Flags[I])) + ' ';
    Msg := S + #0;
  end
  else
  begin
    K := 0;
    for I := PromptWnd.ComponentCount - 1 downto 0 do
    begin
      C := PromptWnd.Components[I];
      if (C is TRadioButton) and (C as TRadioButton).Checked then
      begin
        K := (C as TRadioButton).Tag;
        Break;
      end;
    end;
    Msg := IntToStr(K);
  end;
  SetLength(Flags, 0);
  Resume;
end;

procedure TScanThread.ShowScriptHint;
var
  H: TObject;
  Tick: Cardinal;
begin
  with fmSecondfj do
  begin
    tScript.Hint := Self.Msg;
    H := CreateTabHint(tScript);
  end;
  Tick := GetTickCount;
  repeat
    Application.ProcessMessages;
  until GetTickCount - Tick >= 3000;
  fmSecondfj.HideHintWindow(H);
end;

{$I-}
procedure TScanThread.PauseScriptThread;
begin
  with fmSecondfj do
  begin
    if not sbPause.Enabled then
      Exit;
    sbPause.Down := True;
    edScript.Enabled := sbPause.Down or not btStart.Down;
    edScript.ReadOnly := not sbPause.Down;
  end;
end;

procedure TScanThread.ResumeScriptThread;
begin
  with fmSecondfj do
  begin
    if not sbPause.Enabled then
      Exit;
    sbPause.Down := False;
    edScript.Enabled := sbPause.Down or not btStart.Down;
    edScript.ReadOnly := not edScript.Enabled or btStart.Down;
  end;
end;

procedure TScanThread.AfterScriptStarted;
begin
  with fmSecondfj do
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

procedure TScanThread.StopScriptThread;
begin
  fmSecondfj.btStart.Down := False;
  fmSecondfj.sbPause.Down := False;
  fmSecondfj.sbPause.Enabled := False;
  fmSecondfj.edScript.Enabled := True;
  fmSecondfj.edScript.ReadOnly := False;
end;

{$I+}
procedure UpdateScriptButtons(T: Pointer);
begin
  with fmSecondfj do
  begin
    if tScript.Tabs.Count <> 0 then
    begin
      btStart.Down := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])].Flag91;
      sbPause.Enabled := btStart.Down;
      sbPause.Down := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])].Paused and
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

procedure TScanThread.ScriptTerminated(Sender: TObject);
begin
  UpdateScriptButtons(Self);
  if DebugForm <> nil then
    FreeAndNil(DebugForm);
end;

function NtPostMsgZ(TZ: TScanThread; hWndNt: HWND; uMsg: Cardinal;
  wPar, lPar: Integer): Integer; stdcall;
var
  nRes: Integer;
begin
  asm
    { `sysenter` Паскалем не выразить -- вставка на ассемблере }
    push  lPar
    push  wPar
    push  uMsg
    push  hWndNt
    mov   eax, gNtPmNumb4
    lea   edx, @@1
    push  edx
    push  edx
    mov   edx, esp
    sysenter
  @@1:
    add   esp, $14
    mov   nRes, eax
  end;
  Result := nRes;
end;

procedure TScanThread.SyncLog6548;
begin
  { Просто дёргает пункт меню «окно журнала» у главной формы: ни локалов,
    ни Self. }
  fmSecondfj.miLogWindowClick(fmSecondfj);
end;

procedure TScanThread.SyncShowLogWin;
begin
  if (fmSecondfj.FLogWin.Width <> -1) and (fmSecondfj.FLogWin.Height <> -1) then
  begin
    gDlg5966F8c6.Width := fmSecondfj.FLogWin.Width;
    gDlg5966F8c6.Height := fmSecondfj.FLogWin.Height;
  end;
  if (fmSecondfj.FLogWin.Left <> -1) and (fmSecondfj.FLogWin.Top <> -1) then
  begin
    gDlg5966F8c6.Left := fmSecondfj.FLogWin.Left;
    gDlg5966F8c6.Top := fmSecondfj.FLogWin.Top;
  end;
  gDlg5966F8c6.Visible := True;
end;

procedure TScanThread.SyncAddScriptTab;
begin
  fmSecondfj.bAddClick(fmSecondfj.bAdd);
end;

procedure TScanThread.SyncScriptChanging;
var
  b: Boolean;
begin
  b := True;
  fmSecondfj.tScriptChanging(fmSecondfj, b);
end;

procedure TScanThread.SyncScriptChange;
begin
  fmSecondfj.tScriptChange(fmSecondfj);
end;

constructor TScanThread.NewScriptTab(CreateSuspended: Boolean);
var
  { Единственная локальная: пять упоминаний таймера, ESI. }
  T: TTimer;
begin
  inherited Create(CreateSuspended);
  LogLevel := 1;
  PerfFreq := PInt64(@gPerfFreqby)^;
  T := TTimer.Create(fmSecondfj);
  Timer := T;
  T.Enabled := False;
  T.Interval := $FA0;
  T.OnTimer := HideHint;
  VarNames := TStringList.Create;
  VarNames.Add('timer');
  Synchronize(PrepareScreenBitmap);
  LineBase := 0;
end;

destructor TScanThread.Destroy;
var
  i: Integer;
begin
  FreeAndNil(ScreenBmp);
  Timer.Enabled := False;
  Synchronize(SyncHideHint);
  FreeAndNil(Timer);
  SetLength(Arr104898, 0);
  SetLength(Vars, 0);
  SetLength(Timers, 0);
  VarNames.Free;
  SetLength(Arr50, 0);
  SetLength(Arr54, 0);
  SetLength(Arr58, 0);
  SetLength(Arr48, 0);
  for i := 0 to Length(Blocks) - 1 do
  begin
    GlobalFree(Blocks[i].Handle);
    Blocks[i].Handle := 0;
  end;
  SetLength(Blocks, 0);
  VarTimer.Free;
  SetLength(Lines, 0);
  SetLength(Arr43F0, 0);
  Obj43FC.Free;
  Masks.Free;
  Obj4468.Free;
  Obj446C.Free;
  SetLength(ImgPts, 0);
  SetLength(ImgTol, 0);
  SetLength(ImgList, 0);
  TabList.Free;
  if LogView <> nil then
    LogView.WindowProc := OldLogProc;
  LogView.Free;
  SubScript.Free;
  HintWnd.Free;
  inherited Destroy;
end;

procedure TScanThread.SyncSetControlText;
var
  S: string;
begin
  S := gCmdNamesdd[CtlId];
  Delete(S, 1, 2);
  case CtlId of
    1: fmSecondfj.miShowScriptProcessing.Checked := CtlValue > 0;
    2: fmSecondfj.miStopSUncC.Checked := CtlValue > 0;
    3: fmSecondfj.miShowTimerVar.Checked := CtlValue > 0;
    197, 198, 203, 204:
      (fmSecondfj.FindComponent('cb' + S) as TCheckBox).Checked := CtlValue > 0;
    199, 200:
      (fmSecondfj.FindComponent('e' + S) as TEdit).Text := IntToStr(CtlValue);
    202:
      begin
        (fmSecondfj.FindComponent('cb' + S + 'Limited') as TCheckBox).Checked := True;
        (fmSecondfj.FindComponent('e' + S) as TEdit).Text := IntToStr(CtlValue);
      end;
  end;
end;

procedure TScanThread.SyncGetControlText;
var
  S: string;
begin
  S := gCmdNamesdd[CtlId];
  Delete(S, 1, 2);
  CtlValue := 0;
  case CtlId of
    86: CtlText := fmSecondfj.tScript.Tabs[fmSecondfj.tScript.TabIndex];
    197, 198, 203, 204:
      if (fmSecondfj.FindComponent('cb' + S) as TCheckBox).Checked then
        CtlValue := 1;
    199, 200, 202:
      CtlValue := StrToInt((fmSecondfj.FindComponent('e' + S) as TEdit).Text);
  end;
end;

procedure TScanThread.SyncShowHint;
var
  R: TRect;
  I: Integer;
begin
  if HintWnd = nil then
  begin
    HintWnd := TRxHintWindowRef(uScanThread.TRxHintWindow.Create(fmSecondfj));
    HintWnd.Busy := True;
  end;
  R := Types.Bounds(-1, -1, -1, -1);
  if Hint.Size >= 0 then
    HintWnd.Canvas.Font.Size := Hint.Size
  else
    HintWnd.Canvas.Font.Size := 9;
  if Hint.Color >= 0 then
    HintWnd.Canvas.Font.Color := Hint.Color
  else
    HintWnd.Canvas.Font.Color := clInfoText;
  if Hint.Left <> -1 then
    R.Left := Hint.Left;
  if Hint.Top <> -1 then
    R.Top := Hint.Top;
  if Hint.Width >= 0 then
    R.Right := Hint.Width;
  if Hint.Height >= 0 then
    R.Bottom := Hint.Height;
  HintWnd.Color := Hint.Back;
  HintWnd.Canvas.Font.Style := [];
  if Hint.Style <> '' then
    for I := 1 to Length(Hint.Style) do
      case Hint.Style[I] of
        'b': HintWnd.Canvas.Font.Style := HintWnd.Canvas.Font.Style + [fsBold];
        'i': HintWnd.Canvas.Font.Style := HintWnd.Canvas.Font.Style + [fsItalic];
        'u': HintWnd.Canvas.Font.Style := HintWnd.Canvas.Font.Style + [fsUnderline];
        's': HintWnd.Canvas.Font.Style := HintWnd.Canvas.Font.Style + [fsStrikeOut];
      end;
  HintWnd.Canvas.Font.Name := Hint.Font;
  Hint.Text := StringReplace(Hint.Text, '|', #13#10, [rfReplaceAll, rfIgnoreCase]);
  Hint.Text := StringReplace(Hint.Text, '/n', #13#10, [rfReplaceAll, rfIgnoreCase]);
  Hint.Text := StringReplace(Hint.Text, '\n', #13#10, [rfReplaceAll, rfIgnoreCase]) + #0;
  HintWnd.ActivateHint(R, Hint.Text);
  HintWnd.Busy := False;
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TScanThread.SyncHideHint;
begin
  if HintWnd <> nil then
  begin
    HintWnd.ReleaseHandle;
    HintWnd.Free;
    HintWnd := nil;
  end;
end;

procedure TScanThread.HideHint(Sender: TObject);
begin
  Synchronize(SyncHideHint);
  Timer.Enabled := False;
  Hint.Text := '';
end;

procedure TScanThread.SyncSetHotKey;
var
  Row, I: Integer;
begin
  Row := -1;
  for I := 0 to fmSecondfj.sghkScriptHKList.RowCount - 1 do
    if fmSecondfj.sghkScriptHKList.Cells[1, I] = Name then
    begin
      Row := I;
      Break;
    end;
  I := StrToInt(Name) * 2 + fmSecondfj.sghkScriptHKList.Tag + CapWnd;
  TfmSecond(fmSecondfj).sghkScriptHKList.Row := Row;
  if fmSecondfj.sghkScriptHKList.Cells[gHKSela, Row] = 'X' then
    fmSecondfj.sghkScriptHKList.Cells[gHKSela, Row] := ' ';
  fmSecondfj.cbhk1Click(fmSecondfj.sghkScriptHKList);
  gHKEntrieslw[I - 1].Mods := THKMods(HKMods);
  gHKEntrieslw[I - 1].Text := Msg;
  gHKEntrieslw[I - 1].Sound := fmSecondfj.eSoundFileSelect.Text;
  fmSecondfj.sghkScriptHKList.Cells[gHKSela, Row] := 'X';
  fmSecondfj.cbhk1Click(fmSecondfj.sghkScriptHKList);
  CapWnd := fmSecondfj.fld_14E8;
end;

procedure TScanThread.SyncLog737C;
begin
  { Ставит галку cbLoggingCommands по полю LoggingCommands -- но только
    если взведён AutoStart. }
  if AutoStart then
    fmSecondfj.cbLoggingCommands.Checked := LoggingCommands;
end;

procedure TScanThread.SyncLoadPlugin;
begin
  LoadPlugins(fmSecondfj, Msg);
end;

procedure TScanThread.SyncReloadPlugin;
begin
  DonePlugins(fmSecondfj, Msg);
  LoadPlugins(fmSecondfj, Msg);
end;

procedure TScanThread.SyncUnloadPlugin;
begin
  DonePlugins(fmSecondfj, Msg);
end;

procedure StandardHintFont(AFont: TFont);
var
  NonClientMetrics: TNonClientMetrics;
begin
  NonClientMetrics.cbSize := SizeOf(NonClientMetrics);
  if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NonClientMetrics, 0) then
    AFont.Handle := CreateFontIndirect(NonClientMetrics.lfStatusFont)
  else begin
    AFont.Name := 'MS Sans Serif';
    AFont.Size := 8;
  end;
  AFont.Color := clInfoText;
end;

constructor TRxHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FActive := False;
  StandardHintFont(Canvas.Font);
  FImage := Graphics.TBitmap.Create;
  FUseFixedSize := False;
  FSavedWndProc := WindowProc;
  WindowProc := HookWndProc;
end;

destructor TRxHintWindow.Destroy;
begin
  FImage.Free;
  WindowProc := FSavedWndProc;
  inherited Destroy;
end;

procedure TRxHintWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style and not WS_BORDER;
end;

procedure TRxHintWindow.WMNCPaint(var Message: TMessage);
begin
end;

procedure TRxHintWindow.WMEraseBkgnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure TRxHintWindow.FillRegion(Rgn: HRgn);
begin
  FImage.Canvas.Pen.Style := psSolid;
  FImage.Canvas.Brush.Color := Color;
  try
    PaintRgn(FImage.Canvas.Handle, Rgn);
    FImage.Canvas.Brush.Color := Font.Color;
    DrawEdge(FImage.Canvas.Handle, FRect, BDR_RAISEDOUTER, BF_RECT);
  finally
    FImage.Canvas.Brush.Color := Color;
  end;
end;

procedure TRxHintWindow.Paint;
var
  R: TRect;
  Rgn: HRgn;
begin
  FImage.Handle := CreateCompatibleBitmap(Canvas.Handle,
    WidthOf(ClientRect), HeightOf(ClientRect));
  FImage.Canvas.Font := Self.Canvas.Font;
  Rgn := CreateRectRgnIndirect(FRect);
  try
    FillRegion(Rgn);
  finally
    DeleteObject(Rgn);
  end;
  R := FTextRect;
  Inc(R.Left, 2);
  { $810 = DT_NOPREFIX or DT_WORDBREAK; параметра у флагов нет, значит зовётся
    DrawTextBiDiModeFlagsReadingOnly, а не DrawTextBiDiModeFlags(0). }
  DrawText(FImage.Canvas.Handle, FHintText, -1, R,
    DT_LEFT or DT_NOPREFIX or DT_WORDBREAK or DrawTextBiDiModeFlagsReadingOnly);
  Canvas.Draw(0, 0, FImage);
end;

procedure TRxHintWindow.ActivateHint(Rect: TRect; const AHint: string);
var
  R: TRect;
  Extra: Integer;
begin
  FActive := False;
  FHintText := PChar(AHint);
  R := Types.Rect(0, 0, Screen.Width, 0);
  { константы должны стоять слитно, иначе они не свернутся в $C10 и выйдет
    три отдельных or вместо одного }
  DrawText(Canvas.Handle, FHintText, -1, R,
    DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX or DrawTextBiDiModeFlagsReadingOnly);
  Inc(R.Right, 8);
  Inc(R.Bottom, 4);
  { ширина округляется вверх до кратной 16 }
  Extra := (R.Right - R.Left) mod 16;
  if Extra > 0 then Inc(R.Right, 16 - Extra);

  if FUseFixedSize then
  begin
    Rect.Left := Left;
    Rect.Top := Top;
  end;
  if Rect.Bottom >= 0 then R.Bottom := Rect.Bottom;
  if Rect.Right >= 0 then R.Right := Rect.Right;

  FRect := R;
  FTextRect := R;
  InflateRect(FTextRect, -1, -1);

  if Rect.Left <> -1 then
    Types.OffsetRect(R, Rect.Left, 0)
  else
    Types.OffsetRect(R, Screen.WorkAreaWidth - R.Right - 4, 0);
  if Rect.Top <> -1 then
    Types.OffsetRect(R, 0, Rect.Top)
  else
    Types.OffsetRect(R, 0, Screen.WorkAreaHeight - R.Bottom - 4);

  BoundsRect := R;
  Paint;
  if FPos <> 0 then
    SetWindowPos(Handle, HWND_TOPMOST, R.Left, R.Top, 0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW)
  else
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
  FActive := True;
end;

procedure TRxHintWindow.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
  Message.Result := HTCAPTION;
end;

procedure TRxHintWindow.HookWndProc(var Message: TMessage);
begin
  if FActive and (Message.Msg = WM_MOVE) then
  begin
    FUseFixedSize := True;
    WindowProc := FSavedWndProc;
  end;
  FSavedWndProc(Message);
end;

function WidthOf(R: TRect): Integer;
begin
  Result := R.Right - R.Left;
end;

function HeightOf(R: TRect): Integer;
begin
  Result := R.Bottom - R.Top;
end;

procedure TScanThread.SyncGetTabCount;
begin
  TabCount := fmSecondfj.tScript.Tabs.Count;
end;

procedure TScanThread.SyncGetTabNames;
begin
  TabList.Assign(fmSecondfj.tScript.Tabs);
end;

procedure TScanThread.SyncShowAllWnd;
begin
  ShowAllWnd := fmSecondfj.miShowAllWindows.Checked;
end;

procedure TScanThread.SyncClearLog;
var
  I: Integer;
begin
  fmSecondfj.mLog.Lines.SetText('');
  for I := 1 to fmSecondfj.tcLog.Tabs.Count - 1 do
    gScriptso3[StrToInt(fmSecondfj.tcLog.Tabs[I])].LogView.Lines.SetText('');
end;

procedure TTimerThread.Execute;
begin
  if FDelay = 0 then
    FDelay := $FFFFFFFF
  else
    Inc(FDelay, GetTickCount);
  while (not FStop) and (GetTickCount < FDelay) do
  begin
    if not FSend then
      PostMessage(FWnd, WM_KEYDOWN, FKey, FLParam)
    else
    begin
      SendMessage(FWnd, WM_KEYDOWN, FKey, FLParam);
      if FChar <> 0 then
        SendMessage(FWnd, WM_CHAR, FChar, FLParam or $C0000000);
    end;
    SysUtils.Sleep(15);
  end;
  if not FSend then
    PostMessage(FWnd, WM_KEYUP, FKey, FLParam or $C0000000)
  else
    SendMessage(FWnd, WM_KEYUP, FKey, FLParam or $C0000000);
  FDone := True;
end;

procedure TTimerThreadEx.Execute;
begin
  if FDelay = 0 then
    FDelay := $FFFFFFFF
  else
    Inc(FDelay, GetTickCount);
  while (not FStop) and (GetTickCount < FDelay) do
  begin
    SendKeysEx(FWnd, FStr, FMode, FScript, 1);
    SysUtils.Sleep(15);
  end;
  SendKeysEx(FWnd, FStr, FMode, FScript, 2);
  FDone := True;
end;

procedure TScanThread.LogWndProc(var Message: TMessage);
begin
  if Message.Msg = WM_COPY then
  begin
    Message.Msg := 0;
    { SelText стоит ПРЯМО в вызове, без промежуточной переменной }
    SetClipboardText(Clipboard, LogView.SelText);
  end;
  OldLogProc(Message);
end;

function TScanThread.ServiceCall: string;
begin
  gSvcRetakx := SvcInstall(gServiceNamec, gServiceNamec);
  Result := IntToStr(gSvcRetakx);
end;

function TScanThread.ServiceStop: string;
begin
  if not (SvcRemove(gServiceNamec) and (SvcQueryState(gServiceNamec) = 1)) then
    gSvcRetakx := -6
  else
    SvcQueryState(gServiceNamec);
  Result := IntToStr(gSvcRetakx);
end;

function TScanThread.ServiceSend: string;
begin
  if not SvcSendKeys('form1.Edit1.text') then
    gSvcRetakx := -7
  else
    SvcQueryState(gServiceNamec);
  Result := IntToStr(gSvcRetakx);
end;

function TScanThread.ServiceGetStatus: string;
begin
  gSvcRetakx := SvcQueryState(gServiceNamec);
  Result := IntToStr(gSvcRetakx);
end;

procedure TScanThread.SyncKeyboardOn;
begin
  UnhookHookB;
end;

procedure TScanThread.SyncKeyboardOff;
begin
  SetHookB;
end;

procedure TScanThread.SyncMouseOn;
begin
  UnhookHookA;
end;

procedure TScanThread.SyncMouseOff;
begin
  SetHookA;
end;

{$I-}
function LuaScriptCommand(L: Integer): Integer; cdecl;
type
  TLuaArgs = array[0..20] of string;
  PLuaArgs = ^TLuaArgs;
  { Динамический массив, передаваемый ПО ЗНАЧЕНИЮ, требует ИМЕНОВАННОГО
    типа: безымянный `TvArray.Data` из Unit1 по присваиванию несовместим.
    На месте вызова приведение не стоит ни одной команды. }
  aas = array of array of string;
var
  P: PChar;      { захвачен, вложенная $537EB0 в него ПИШЕТ }
  b: Boolean;    { захвачен: команда (True) или выражение }
  i: Integer;    { захвачен: индекс в списке, он же var-довод }
  idx: Integer;  { захвачен: номер вкладки }
                 { Result -- СКОЛЬКО ЗНАЧЕНИЙ ОТДАНО LUA }
  S: string;
  nm: string;
  W: string;
  n1, n2, old: Integer;
  { GetArraySize берёт их var-доводами и объявлены они Cardinal -- на кадр
    это не влияет, оба по четыре байта. }
  aX, aY: Cardinal;
  A: TLuaArgs;
  { Ниже -- имена, которым нужны регистры (esi -- число доводов Lua).
    Объявлены последними нарочно: если регистра не достанется, слот уедет
    в конец кадра и не собьёт разметку выше. }
  q, k: Integer;
  { Второй признак, живущий только в регистре: ветка `terminated` (280)
    читает в него поле и отдаёт Lua. Дома в кадре не имеет. }
  bv: Boolean;
  { Номер матричной переменной, найденной FindScriptVar. Живёт в регистре,
    дома в кадре не имеет. }
  vi: Integer;
  { Элемент массива скриптов, взятый ОДИН раз на ветку 284: живёт в
    регистре и подаётся доводом одной командой. Через `with` этого не
    получить -- предмет `with` по имени не назвать, и довод считается
    заново. }
  TE: TScanThread;

  { ДЕРЖАЛКА ЗАХВАТОВ. Кадр задают вложенные: первыми ложатся локалы, у
    которых вложенная взяла адрес. Никто её не зовёт, значит и байт она не
    стоит, зато порядок первых упоминаний здесь и есть порядок слотов. }
  procedure HoldZ;
  begin
    P := nil;
    b := False;
    i := 0;
    idx := 0;
  end;

  { ОТДАТЬ LUA ДВУМЕРНУЮ МАТРИЧНУЮ ПЕРЕМЕННУЮ СКРИПТА: таблица таблиц,
    ключи с единицы в обоих ярусах. Довод берётся ПО ЗНАЧЕНИЮ, как и у
    PushLines -- отсюда DynArrayAddRef в прологе и DynArrayClear в finally.
    Два отличия от PushLines:
    * ПУСТАЯ СТРОКА МАТРИЦЫ ПРОПУСКАЕТСЯ ЦЕЛИКОМ -- проверка
    `Length(M[k]) > 0` стоит ДО lua_pushnumber, то есть в таблице
    остаются дырки, а не пустые подтаблицы;
    * ЧИСЛОВОЙ ПРИЗНАК СЧИТАЕТСЯ НА КАЖДУЮ ЯЧЕЙКУ, а не один раз перед
    циклом: в него входит НОМЕР СТОЛБЦА. }
  procedure PushMatrix(M: aas);
  var
    { Кадр на четыре байта больше, чем у PushLines: регистров хватает ровно
      на три имени (k, q и счётчик внутреннего цикла), счётчик внешнего
      `for` живёт в памяти. Остальные слоты -- временные под `fild` в
      lua_pushnumber и под приведение PChar -> string; объявлять их именами
      нельзя: тогда `k` теряет регистр и кадр растёт ещё. }
    k: Integer;
    q: Integer;
    bNum: Boolean;
  begin
    gLuaCreateTableej(L, 0, 0);
    for k := 0 to Length(M) - 1 do
    begin
      if Length(M[k]) > 0 then
      begin
        gLuaPushNumberdp(L, k + 1);
        gLuaCreateTableej(L, 0, 0);
        for q := 0 to Length(M[k]) - 1 do
        begin
          P := PChar(M[k][q]);
          gLuaPushNumberdp(L, q + 1);
          { Две мелочи, обе важны:
            * `i in [75, 89]` даёт ОДНО чтение `i`, два отдельных
            сравнения -- два;
            * присваивание через `if ... then True else False` кладёт блок
            `True` первым, присваивание выражения -- блок `False`.
            Имя нужно, хотя тут же и читается: без него строятся прямые
            переходы. Дома `bNum` не получает -- живёт в регистре от
            присваивания до проверки. }
          if (not b) and ((i = 43) and (q = 0) or (i in [75, 89])) then
            bNum := True
          else
            bNum := False;
          if bNum then
          begin
            gLuaPushNumberdp(L, StrToIntDef(P, 0));
          end
          else
            gLuaPushLStringej(L, P, Length(P));
          gLuaSetTableej(L, -3);
        end;
        gLuaSetTableej(L, -3);
      end;
    end;
  end;

  { ОТДАТЬ МАССИВ СТРОК ТАБЛИЦЕЙ LUA. Довод берётся ПО ЗНАЧЕНИЮ -- отсюда
    DynArrayAddRef в прологе и DynArrayClear в finally; при `const` не было
    бы ни того, ни другого.
    Ключ таблицы -- номер строки с единицы, значение -- сама строка,
    а для findcolor (75) и findimage (89) -- ЧИСЛО: их вывод целиком
    числовой, и Lua получает его числом, а не текстом. }
  procedure PushLines(Lines: arrayOfString);
  var
    { ПОРЯДОК ОБЪЯВЛЕНИЯ ЗДЕСЬ -- ЭТО КАДР: целое, через которое идёт fild
      в lua_pushnumber, строка числовой ветки, строка обычной. }
    n: Integer;
    k: Integer;
    bNum: Boolean;
  begin
    { Держалка слота: при -$C- команд не выпускает, но отнимает у `n`
      регистр и даёт ему дом ровно там, откуда идёт `fild`. Без неё под
      пересчёт заводится своя временная, и весь кадр съезжает. }
    Assert(@n <> nil);
    { Две формы разом:
      * `i in [75, 89]` вместо `(i = 75) or (i = 89)` -- значение читается
      ОДИН раз, два отдельных сравнения дают два чтения;
      * `if ... then bNum := True else bNum := False` вместо присваивания
      выражения -- от этого зависит раскладка веток: блок `True` идёт
      сразу, а не после `False`. }
    if (not b) and (i in [75, 89]) then
      bNum := True
    else
      bNum := False;
    gLuaCreateTableej(L, 0, 0);
    for k := 0 to Length(Lines) - 1 do
    begin
      P := PChar(Lines[k]);
      n := k + 1;
      gLuaPushNumberdp(L, n);
      if bNum then
      begin
        n := StrToIntDef(P, 0);
        gLuaPushNumberdp(L, n);
      end
      else
        gLuaPushLStringej(L, P, Length(P));
      gLuaSetTableej(L, -3);
    end;
  end;

  { Рабочее окно ставит ApplyWorkWindow -- процедура модуля выше; своей
    вложенной копии здесь нет. }

  { ТАБЛИЦА LUA ПОД НОМЕРОМ N В СТРОКУ ДОВОДОВ. Обход стандартный --
    `lua_pushnil` и `lua_next` до нуля; значение берётся
    `lua_tolstring(L, -1, nil)` и приклеивается через пробел, а ключ
    остаётся на стеке до следующего шага (`LuaPop(L, 1)` снимает только
    значение).
    Цикл идёт через `jmp @test`: условие -- вызов, то есть дорогое, и вход
    в него не дублируется. `L` берётся из кадра родителя. }
  function TableToStr(N: Integer): string;
  var
    { Вторая ячейка кадра -- временная под приведение PChar -> string,
      объявлять её не нужно. }
    R: string;
  begin
    R := '';
    gLuaPushNilej(L);
    while gLuaNextej(L, N) <> 0 do
    begin
      if Length(R) > 0 then
        R := R + ' ';
      R := R + gLuaToLStringej(L, -1, nil);
      LuaPop(L, 1);
    end;
    Result := R;
  end;

  { Разбор доводов Lua в A[0..20] и в T.Args[1..20].
    Вид довода: 0 -- нет, 1 -- число, 2 -- строка, 3 -- таблица Lua. }
  procedure ParseArgs(var Arr: TLuaArgs; Cnt: Integer);
  var
    j: Integer;
    d: Double;
  begin
    for j := 1 to Cnt do
    begin
      gScriptso3[idx].Args[j].Kind := 0;
      if LuaIsNil(L, j) then
        Arr[j - 1] := 'nil'
      else if LuaIsTable(L, j) then
      begin
        Arr[j - 1] := 'LuaTable';
        gScriptso3[idx].Args[j].Kind := 3;
        gScriptso3[idx].Args[j].Val := j;
        gScriptso3[idx].Args[0].Val := j;
      end
      { Проверяется `lua_isnumber`, а значение потом снимается
        `lua_tolstring` -- так исторически, менять не буду. }
      else if gLuaIsNumberej(L, j) <> 0 then
      begin
        Arr[j - 1] := gLuaToLStringej(L, j, nil);
        d := StrToFloatDef(Arr[j - 1], 0);
        { ПОСТОЯННАЯ СЛЕВА: у сравнения вещественных порядок операндов задаёт,
          кто попадёт в ST(0). Точка обязательна -- без неё High(Int64)
          сожмётся до Single. }
        if 9223372036854775807.0 < d then
        begin
          gScriptso3[idx].Args[j].Str := Arr[j - 1];
          gScriptso3[idx].Args[j].Kind := 2;
        end
        else
        begin
          gScriptso3[idx].Args[j].Val := Trunc(d);
          gScriptso3[idx].Args[j].Kind := 1;
        end;
      end
      else
      begin
        Arr[j - 1] := gLuaToLStringej(L, j, nil);
        gScriptso3[idx].Args[j].Str := Arr[j - 1];
        gScriptso3[idx].Args[j].Kind := 2;
      end;
    end;
    for j := Cnt + 1 to 20 do
    begin
      gScriptso3[idx].Args[j].Str := '';
      gScriptso3[idx].Args[j].Val := 0;
      gScriptso3[idx].Args[j].Kind := 0;
    end;
  end;

  { СТРОКА ВИДА «ячейка|ячейка/ячейка|ячейка» В ТАБЛИЦУ ТАБЛИЦ LUA.
    `/` кончает строку, `|` кончает ячейку. Довод берётся ПО ЗНАЧЕНИЮ, а
    не `const`.
    Осторожно: признак «таблица строки открыта» взводится только в ветке
    `|` и никогда не гасится, поэтому со второй строки lua_pushnumber и
    lua_createtable уже не выпускаются. }
  procedure PushVersion(V: string);
  var
    { -$4 достаётся `n` не по объявлению, а потому что его ПЕРВЫМ упоминает
      вложенная PushCell; дом довода из-за этого -- -$8. }
    n: Integer;
    r: Integer;
    W: string;
    bOpen: Boolean;
    c, i, ln: Integer;

    { Пара «номер ячейки, значение» в открытую таблицу. ЧИСЛО УХОДИТ ЧИСЛОМ:
      если ячейка переводится в целое, Lua получает число, а не текст.
      Вложенность двухъярусная, отсюда и двойное разыменование статической
      ссылки на кадр родителя. }
    procedure PushCell(S: string; K: Integer);
    begin
      gLuaPushNumberdp(L, K);
      if TryStrToInt(S, n) then
        gLuaPushNumberdp(L, n)
      else
        gLuaPushLStringej(L, PChar(S), Length(S));
      gLuaSetTableej(L, -3);
    end;

  begin
    r := 1;
    c := 1;
    i := 1;
    ln := Length(V);
    bOpen := False;
    gLuaCreateTableej(L, 0, 0);
    { Условие дешёвое (два регистра), поэтому вход в цикл продублирован, а
      не уведён под `jmp @test`. Написано именно `i <= ln`: от порядка
      доводов зависит, в какую сторону пойдёт сравнение. }
    while i <= ln do
    begin
      case V[i] of
        '|':
          begin
            if not bOpen then
            begin
              gLuaPushNumberdp(L, r);
              gLuaCreateTableej(L, 0, 0);
              bOpen := True;
            end;
            PushCell(W, c);
            W := '';
            Inc(c);
          end;
        '/':
          begin
            if not bOpen then
            begin
              gLuaPushNumberdp(L, r);
              gLuaCreateTableej(L, 0, 0);
            end;
            PushCell(W, c);
            W := '';
            gLuaSetTableej(L, -3);
            Inc(r);
            c := 1;
          end;
      else
        W := W + V[i];
      end;
      Inc(i);
    end;
  end;

begin
  { ДЕРЖАЛКА СЛОТА ИТОГА. Result должен лежать в кадре: иначе он забирает
    регистр, нужный дальше. При -$C- Assert не выпускает ни одной команды,
    но взятие адреса лишает имя регистра и даёт ему дом. }
  Assert(@Result <> nil);
  { Та же держалка для `old`: иначе он подхватывает регистр, как только
    Result его освободит. }
  Result := 0;
  idx := -1;
  for k := 0 to 99 do
  begin
    { Употребление `bv` стоит ВНУТРИ ЦИКЛА нарочно: снаружи оно не даёт
      ничего, а здесь поднимает его в регистр -- лишний байт уходит из кадра
      вместе с `push ecx` в прологе, и массив `A` встаёт на место.
      Хватает одного раза. }
    bv := bv;
    if (gScriptsS[k] <> nil) and (gScriptsS[k].DebugForm <> nil) and
       (TLua(gScriptsS[k].DebugForm).Handle = L) then
    begin
      idx := k;
      Break;
    end;
  end;
  k := gLuaGetTopej(L);
  ParseArgs(A, k);
  S := A[0];
  { ДВА ОПЕРАТОРА, А НЕ ОДИН: одним выражением заводится лишняя временная
    строка, кадр вырастает на четыре байта и весь массив A съезжает. }
  nm := gLuaToLStringej(L, LuaUpvalueIndex(1), nil);
  nm := nm + '';
  if gScriptsS[idx].StopRequested then
  begin
    gLuaRaiseby(L);
    Result := 0;
  end
  else
  begin
    b := True;
    i := gCmdList2jj.IndexOf(nm);
    { Проверка написана «наоборот» -- `i < 0` -- нарочно: так case КОМАНД
      уходит физически вниз, а `then` занимают выражения и хвост. }
    if i < 0 then
    begin
      i := gCmdListah7.IndexOf(nm);
      if i >= 0 then
      begin
        b := False;
        { case по ВЫРАЖЕНИЯМ. Метки -- индексы в gCmdListah7.
          ВСЕ ветки, включая else, ПРОВАЛИВАЮТСЯ в хвост ниже. }
        case i of
          { НАСТРОЙКА «ПРОЧИТАТЬ ИЛИ ЗАПИСАТЬ». Пустой довод -- чтение, непустой --
            запись; отсюда ДВА case подряд по одному и тому же `i`, а третий
            решает, ЧЕМ отдать значение Lua: числом, строкой или признаком. }
          40,44,95,100,197,198,230..234,237,239,240,277,278,280:
            begin
              S := EvalScriptExpr(gScriptsS[idx], 'calc ' + S, -1);
              n1 := StrToIntDef(S, 0);
              if S <> '' then
                { ЗАПИСЬ. Прежнее значение сперва ложится в
                  `old`, и только потом поле переписывается. }
                case i of
                  { workwindow: рабочее окно ставит ApplyWorkWindow, она же перечитывает
                    Pid и Tid. }
                  44:
                    begin
                      old := gScriptsS[idx].ClientWnd2;
                      ApplyWorkWindow(gScriptsS[idx], n1, idx);
                    end;
                  230:
                    begin
                      old := gScriptsS[idx].Cnt104674;
                      gScriptsS[idx].Cnt104674 := n1;
                    end;
                  231:
                    begin
                      old := gScriptsS[idx].Cnt104678;
                      gScriptsS[idx].Cnt104678 := n1;
                    end;
                  232:
                    begin
                      old := gScriptsS[idx].Cnt10467C;
                      gScriptsS[idx].Cnt10467C := n1;
                    end;
                  233:
                    begin
                      old := gScriptsS[idx].Cnt104680;
                      gScriptsS[idx].Cnt104680 := n1;
                    end;
                  234:
                    begin
                      old := gScriptsS[idx].SendDelay;
                      gScriptsS[idx].SendDelay := n1;
                    end;
                  237:
                    begin
                      old := gScriptsS[idx].ClickDelay;
                      gScriptsS[idx].ClickDelay := n1;
                    end;
                  239:
                    begin
                      old := gScriptsS[idx].Fld10488C;
                      gScriptsS[idx].Fld10488C := n1;
                    end;
                  240:
                    begin
                      old := gScriptsS[idx].Fld104890;
                      gScriptsS[idx].Fld104890 := n1;
                    end;
                  40:
                    begin
                      W := gScriptsS[idx].Str1048B8;
                      gScriptsS[idx].Str1048B8 := S;
                    end;
                end
              else
                { ЧТЕНИЕ. Тот же список плюс те настройки,
                  которые записать нельзя вовсе. }
                case i of
                  44: old := gScriptsS[idx].ClientWnd2;
                  100: old := gScriptsS[idx].ClipLen;
                  95: old := gScriptsS[idx].ProcessId;
                  230: old := gScriptsS[idx].Cnt104674;
                  231: old := gScriptsS[idx].Cnt104678;
                  232: old := gScriptsS[idx].Cnt10467C;
                  233: old := gScriptsS[idx].Cnt104680;
                  234: old := gScriptsS[idx].SendDelay;
                  237: old := gScriptsS[idx].ClickDelay;
                  239: old := gScriptsS[idx].Fld10488C;
                  240: old := gScriptsS[idx].Fld104890;
                  40: W := gScriptsS[idx].Str1048B8;
                  197: W := gTempFilefv;
                  198: W := gExeNameko;
                  277: W := gScriptsS[idx].FilePath;
                  278: W := gScriptsS[idx].FileTitle;
                  280: bv := gScriptsS[idx].StopRequested;
                end;
              { ЧЕМ ОТДАТЬ. Ветки обоих case выше сходятся
                сюда, поэтому третий case стоит ПОСЛЕ них, а не внутри. }
              case i of
                44,95,100,230..234,237,239,240: gLuaPushIntegerej(L, old);
                40,197,198,277,278: gLuaPushLStringej(L, PChar(W), Length(W));
                280: gLuaPushBooleanej(L, bv);
              end;
              Result := 1;
            end;
          { ОБЩЕЕ ТЕЛО ВЫРАЖЕНИЙ: склеить доводы, при надобности взять их в
            скобки, приписать `get ` или `calc ` и отдать в EvalScriptExpr. }
          0..7,10..28,30..33,37..39,42,45..49,53..58,73,76,78..83,85..88,
          90..94,96..99,101..154,159..177,182..189,193,195,196,199,
          220..228,238,241..250,281,282:
            begin
              S := '';
              for q := 0 to k - 1 do
                S := S + ' ' + A[q];
              { Набор лежит ПОСТОЯННОЙ: `bt` выпускается только для `in`, а не для
                `case`. Хвост набора (281, 282) в постоянную не влезает --
                у множества Delphi потолок 256 элементов, поэтому вторым
                доводом `or` стоит сдвинутая проверка. }
              if (i in [43,45..47,49,57,58,76,80,83,87,88,96..99,108..112,
                        117..135,137..154,159,182..189,193,224..228,238,
                        244..249]) or ((i - 200) in [81,82]) then
                S := '(' + S + ')';
              case i of
                42,48: S := 'get ' + nm + ' ' + S;
              else
                if S = '' then
                  S := 'calc ' + nm
                else
                  S := 'calc ' + nm + ' ' + S;
              end;
              { Внутренний case по ТОМУ ЖЕ индексу: чем именно
                отдавать вычисленное Lua. }
              case i of
                { getimage, loadimage: итог приходит строкой
                  «x|y|w/h», и разбирается он ЧЕТЫРЬМЯ развёрнутыми шагами,
                  а не циклом -- у последнего шага нет Delete. }
                246,248:
                  begin
                    W := EvalScriptExpr(gScriptsS[idx], S, -1);
                    n1 := Pos('|', W);
                    if n1 > 0 then
                    begin
                      S := Copy(W, 1, n1 - 1);
                      Delete(W, 1, n1);
                      gLuaPushNumberdp(L, StrToIntDef(S, -1));
                      n1 := Pos('|', W);
                      S := Copy(W, 1, n1 - 1);
                      Delete(W, 1, n1);
                      gLuaPushNumberdp(L, StrToIntDef(S, -1));
                      n1 := Pos('|', W);
                      S := Copy(W, 1, n1 - 1);
                      Delete(W, 1, n1);
                      gLuaPushNumberdp(L, StrToIntDef(S, -1));
                      n1 := Pos('/', W);
                      S := Copy(W, 1, n1 - 1);
                      gLuaPushNumberdp(L, StrToIntDef(S, -1));
                      Result := 4;
                    end
                    else
                    begin
                      if TryStrToInt(W, n1) then
                        gLuaPushIntegerej(L, n1)
                      else
                        gLuaPushLStringej(L, PChar(W), Length(W));
                      Result := 1;
                    end;
                  end;
                { windowpos: с доводами это ЗАПИСЬ через
                  диспетчер под номером 40, без доводов -- чтение пяти
                  ячеек LuaRes1..5. }
                42:
                  begin
                    if k > 1 then
                    begin
                      i := 40;
                      ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                      Result := 0;
                    end
                    else
                    begin
                      i := 49;
                      ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                      gLuaPushNumberdp(L, gScriptsS[idx].LuaRes1);
                      gLuaPushNumberdp(L, gScriptsS[idx].LuaRes2);
                      gLuaPushNumberdp(L, gScriptsS[idx].LuaRes3);
                      gLuaPushNumberdp(L, gScriptsS[idx].LuaRes4);
                      gLuaPushNumberdp(L, gScriptsS[idx].LuaRes5);
                      Result := 5;
                    end;
                  end;
                { size: те же ячейки, но только две }
                48:
                  begin
                    i := 49;
                    ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                    gLuaPushNumberdp(L, gScriptsS[idx].LuaRes1);
                    gLuaPushNumberdp(L, gScriptsS[idx].LuaRes2);
                    Result := 2;
                  end;
                { Целое, значение по умолчанию 1 }
                45,46,49,53..55,81,85,159,199,241:
                  begin
                    S := EvalScriptExpr(gScriptsS[idx], S, -1);
                    gLuaPushIntegerej(L, StrToIntDef(S, 1));
                    Result := 1;
                  end;
                { setprocesspriority, getprocesspriority }
                281,282:
                  begin
                    S := EvalScriptExpr(gScriptsS[idx], S, -1);
                    gLuaPushIntegerej(L, StrToIntDef(S, -1));
                    Result := 1;
                  end;
                { suspendprocess, resumeprocess. ВЕТКА МЁРТВАЯ: внешний case 286 и 287
                  к себе не пускает, они уходят в else. }
                286,287:
                  begin
                    S := EvalScriptExpr(gScriptsS[idx], S, -1);
                    gLuaPushIntegerej(L, StrToIntDef(S, -1));
                    Result := 1;
                  end;
                { windowfrompoint. Без разделителя отдаётся одно число, с разделителем --
                  ТАБЛИЦА Lua из пар. Ключи пар кладутся постоянными 1.0 и
                  2.0, а не через FPU.
                  Два огреха, которые тут давно живут: `W` вычисляется и не
                  используется, а в пару кладётся `n2`, которому в этой ветке
                  никто не присваивал. }
                112:
                  begin
                    S := EvalScriptExpr(gScriptsS[idx], S, -1);
                    n1 := Pos('/', S);
                    if n1 <= 0 then
                      gLuaPushNumberdp(L, StrToIntDef(S, -1))
                    else
                    begin
                      gLuaCreateTableej(L, 0, 0);
                      gLuaPushNumberdp(L, 1.0);
                      gLuaCreateTableej(L, 0, 0);
                      while n1 > 0 do
                      begin
                        W := Copy(S, 1, n1 - 1);
                        Delete(S, 1, n1);
                        gLuaPushNumberdp(L, 1.0);
                        gLuaPushIntegerej(L, n2);
                        gLuaSetTableej(L, -3);
                        gLuaPushNumberdp(L, 2.0);
                        gLuaPushNumberdp(L, StrToIntDef(S, -1));
                        gLuaSetTableej(L, -3);
                        n1 := Pos('/', S);
                      end;
                      gLuaSetTableej(L, -3);
                    end;
                    Result := 1;
                    S := '';
                  end;
              else
                { Всё остальное отдаётся СТРОКОЙ }
                S := EvalScriptExpr(gScriptsS[idx], S, -1);
                gLuaPushLStringej(L, PChar(S), Length(S));
                Result := 1;
              end;
            end;
          { regexp: доводы склеиваются В КАВЫЧКАХ, к имени
            приписывается ДВАЖДЫ `#luatemp`, и обратно приходят три
            значения -- длина, найденный кусок и код возврата. }
          194:
            begin
              S := '';
              for q := 0 to k - 1 do
                S := S + ' "' + A[q] + 'Щ"А';
              S := 'calc ' + nm + ' (#luatemp #luatemp' + S + ')';
              S := EvalScriptExpr(gScriptsS[idx], S, -1);
              gLuaPushNumberdp(L, StrToIntDef(gScriptsS[idx].RxLen, -1));
              P := PChar(gScriptsS[idx].RxSub);
              gLuaPushLStringej(L, P, Length(string(P)));
              gLuaPushNumberdp(L, StrToIntDef(S, -10));
              Result := 3;
            end;
          { findcolor, findimage. Довод-ТАБЛИЦА (вид 3) в пятом или седьмом месте
            переводится в строку вложенной процедурой и подменяет собой
            склейку; иначе доводы склеиваются как обычно. Итог -- либо
            матричная переменная целиком, либо число. }
          75,89:
            begin
              S := '';
              if (gScriptsS[idx].Args[5].Kind = 3) or
                 (gScriptsS[idx].Args[7].Kind = 3) then
              begin
                n1 := gScriptsS[idx].Args[0].Val;
                gScriptsS[idx].Args[n1].Kind := 2;
                gScriptsS[idx].Args[n1].Str :=
                  TableToStr(gScriptsS[idx].Args[n1].Val);
                gScriptsS[idx].HasArgs := True;
                n1 := 2;
              end
              else
              begin
                for q := 0 to k - 1 do
                  S := S + ' ' + A[q];
                gScriptsS[idx].HasArgs := False;
                n1 := 1;
              end;
              S := 'calc ' + nm + ' (' + S + ')';
              S := EvalScriptExpr(gScriptsS[idx], S, -1);
              W := gScriptsS[idx].RxLen;
              n2 := StrToIntDef(S, 0);
              if Copy(W, 1, 1) = '%' then
              begin
                Delete(W, 1, 1);
                vi := FindScriptVar(gScriptsS[idx], '%', W, 0, 0);
                if n2 > 0 then
                begin
                  PushMatrix(aas(gScriptsS[idx].Arr48[vi].Data));
                  if not gScriptsS[idx].HasArgs then
                    LuaSetGlobal(L, PChar(W));
                end
                else
                  if gScriptsS[idx].HasArgs or (k > 3) then
                  begin
                    gLuaPushNilej(L);
                    n1 := 2;
                  end;
                aX := 0;
                aY := 0;
                GetArraySize(gScriptsS[idx], W, aX, aY, True);
              end
              else
                if gScriptsS[idx].HasArgs or (k > 3) then
                begin
                  gLuaPushNilej(L);
                  n1 := 2;
                end;
              gLuaPushIntegerej(L, n2);
              Result := n1;
            end;
          { findwindow. С доводами итог просят в матричную
            переменную и отдают таблицей; без доводов -- ищут окно, читают
            его заголовок в буфер StrAlloc и отдают таблицу из одной пары
            «дескриптор, заголовок». }
          43:
            begin
              S := '';
              if k > 0 then
              begin
                for q := 0 to k - 1 do
                  S := S + ' ' + A[q];
                S := 'set %luatemp ' + nm + ' (' + S + ')';
                i := 40;
                ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                vi := FindScriptVar(gScriptsS[idx], '%', 'luatemp', 0, 0);
                i := 43;
                n2 := Length(gScriptsS[idx].Arr48[vi].Data);
                if n2 > 0 then
                  PushMatrix(aas(gScriptsS[idx].Arr48[vi].Data))
                else
                  gLuaPushNilej(L);
                aX := 0;
                aY := 0;
                GetArraySize(gScriptsS[idx], 'luatemp', aX, aY, True);
              end
              else
              begin
                S := EvalScriptExpr(gScriptsS[idx], 'calc ' + nm + ' ()', -1);
                n2 := StrToIntDef(S, -1);
                P := StrAlloc(250);
                GetWindowText(n2, P, 240);
                gLuaCreateTableej(L, 0, 0);
                gLuaPushNumberdp(L, 1.0);
                gLuaCreateTableej(L, 0, 0);
                gLuaPushNumberdp(L, 1.0);
                gLuaPushIntegerej(L, n2);
                gLuaSetTableej(L, -3);
                gLuaPushNumberdp(L, 2.0);
                gLuaPushLStringej(L, P, Length(string(P)));
                gLuaSetTableej(L, -3);
                gLuaSetTableej(L, -3);
                StrDispose(P);
              end;
              Result := 1;
            end;
          { clipboard. Один довод -- запись, ноль доводов --
            чтение в ТАЙМЕРНУЮ переменную ($luatemp, строка), больше одного --
            чтение в МАТРИЧНУЮ (%luatemp, таблица). }
          77:
            begin
              if k = 1 then
              begin
                S := 'set clipboard ' + A[0];
                i := 40;
                ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                Result := 0;
              end
              else
              begin
                i := 49;
                S := 'get clipboard ';
                if k = 0 then
                begin
                  S := S + '$luatemp';
                  ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                  vi := FindScriptVar(gScriptsS[idx], '$', 'luatemp', 0, 0);
                  P := PChar(gScriptsS[idx].Timers[vi].Value);
                  gLuaPushLStringej(L, P, Length(string(P)));
                end
                else
                begin
                  S := S + '%luatemp';
                  for q := 0 to k - 1 do
                    S := S + ' ' + A[q];
                  ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
                  vi := FindScriptVar(gScriptsS[idx], '%', 'luatemp', 0, 0);
                  PushMatrix(aas(gScriptsS[idx].Arr48[vi].Data));
                end;
                Result := 1;
              end;
              S := '';
            end;
          { checkgetcolor: три значения. Разбор доводов уже сделан заранее и лежит
            в Args; ветка только проверяет, что второй довод посчитан
            (`Kind = 1`), гоняет выражение и отдаёт Lua три готовых числа.
            Порядок именно такой: LuaRes3, LuaRes1, LuaRes2. Склейка идёт
            прямо в поле LuaCalcStr, без локала. }
          284:
            begin
              TE := gScriptsS[idx];
              if TE.Args[1].Kind = 1 then
              begin
                TE.LuaCalcStr := 'calc ' + gCmdNamesdd[i] + ' ()';
                TE.LuaCalcStr :=
                  EvalScriptExpr(TE, TE.LuaCalcStr, -1);
                gLuaPushNumberdp(L, TE.LuaRes3);
                gLuaPushNumberdp(L, TE.LuaRes1);
                gLuaPushNumberdp(L, TE.LuaRes2);
              end
              else
              begin
                gLuaPushNumberdp(L, 0);
                gLuaPushNumberdp(L, 0);
                gLuaPushNumberdp(L, 0);
              end;
              Result := 3;
              S := '';
            end;
          { version: имя берётся ИЗ СПИСКА, а не из nm }
          285:
            begin
              S := 'calc ' + gCmdNamesdd[i];
              S := EvalScriptExpr(gScriptsS[idx], S, -1);
              PushVersion(S);
              Result := 1;
              S := '';
            end;
          { scripts: итог просят В МАТРИЧНУЮ переменную
            %luatemp и оттуда отдают Lua таблицей. }
          84:
            begin
              S := 'get ' + gCmdNamesdd[i] + ' %luatemp';
              i := 49;
              ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
              vi := FindScriptVar(gScriptsS[idx], '%', 'luatemp', 0, 0);
              PushMatrix(aas(gScriptsS[idx].Arr48[vi].Data));
              Result := 1;
              S := '';
              aX := 0;
              aY := 0;
              GetArraySize(gScriptsS[idx], 'luatemp', aX, aY, True);
            end;
        else
          { else: `calc <имя> (<доводы>)` и итог СТРОКОЙ }
          S := 'calc ' + nm + ' (' + S + ')';
          S := EvalScriptExpr(gScriptsS[idx], S, -1);
          gLuaPushLStringej(L, PChar(S), Length(S));
          Result := 1;
        end;
      end;
      { ХВОСТ, общий для «имени нет ни в одном списке» и для всех веток case
        выражений. Двух имён нет ни в одном списке, поэтому меткой case они
        быть не могут. }
      if nm = 'get_script_text' then
      begin
        if k > 0 then
          k := StrToIntDef(A[0], 0)
        else
          k := idx;
        if gScriptsS[k] <> nil then
        begin
          PushLines(gScriptsS[k].Lines);
          Result := 1;
        end
        else
          Result := 0;
      end
      else
        if nm = 'set_script_text' then
        begin
          { Тела нет: сравнение считается, а итог выбрасывается. Команда в Lua
            зарегистрирована и не делает ничего. }
        end;
    end
    else
    begin
      { case по КОМАНДАМ скрипта. Метки -- индексы в gCmdList2jj. Ветки уходят
        прямо в эпилог, минуя хвост get_script_text. }
      case i of
        { Команда исполняется и следом Lua-исключение }
        32:
          begin
            ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
            gLuaRaiseby(L);
          end;
        { ОБЩАЯ СКЛЕЙКА: `<имя> <довод> <довод>`, а у части команд доводы ещё и
          в скобках. }
        8,9,12,13,15..31,33..37,40,48..60,63..108,110,112,113,117..119,
        121..123,126..131:
          begin
            S := '';
            for q := 0 to k - 1 do
              S := S + ' ' + A[q];
            case i of
              102..109,112,113,119: S := '(' + S + ')';
            end;
            S := nm + ' ' + S;
            ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
          end;
        { `dir`: доводы одновременно раскладываются по полю
          класса (маска, фильтр, ...) И склеиваются в команду, итог просят
          в матричную переменную. }
        109:
          begin
            S := '';
            for q := 0 to k - 1 do
            begin
              { DirMask -- массив из десяти строк, поэтому адрес элемента
                считается одной командой. }
              gScriptsS[idx].DirMask[q] := A[q];
              S := S + ' ' + A[q];
            end;
            S := nm + ' (%luatemp ' + S + ')';
            ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
            vi := FindScriptVar(gScriptsS[idx], '%', 'luatemp', 0, 0);
            n2 := Length(gScriptsS[idx].Arr48[vi].Data);
            if n2 > 0 then
              PushMatrix(aas(gScriptsS[idx].Arr48[vi].Data))
            else
              gLuaPushNilej(L);
            aX := 0;
            aY := 0;
            GetArraySize(gScriptsS[idx], 'luatemp', aX, aY, True);
            gLuaPushNumberdp(L, gScriptsS[idx].ClipLen);
            Result := 2;
          end;
        { `readmem` (61) и `writemem` (62): итог просят в $luatemp и отдают Lua
          тем видом, какой назван ПЕРВОЙ БУКВОЙ второго довода: `b`,`w` ->
          целое, `d` -> Int64, `f`,`r` -> дробное, всё прочее -> else.
          Пустая буква заменяется на `c`, то есть уходит в else нарочно. }
        61,62:
          begin
            if i = 61 then
              S := nm + ' $luatemp ' + A[0]
            else
              S := nm + ' "' + A[0] + '"';
            { обход с ЕДИНИЦЫ, а не с нуля: A[0] уже вклеен выше }
            for q := 1 to k - 1 do
              S := S + ' ' + A[q];
            ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
            vi := FindScriptVar(gScriptsS[idx], '$', 'luatemp', 0, 0);
            W := Copy(LowerCase(A[1]), 1, 1);
            if Length(W) = 0 then
              W := 'c';
            case W[1] of
              'b', 'w':
                gLuaPushIntegerej(L,
                  StrToIntDef(gScriptsS[idx].Timers[vi].Value, -1));
              'd':
                gLuaPushNumberdp(L,
                  StrToInt64Def(gScriptsS[idx].Timers[vi].Value, -1));
              'f', 'r':
                gLuaPushNumberdp(L,
                  StrToFloatDef(gScriptsS[idx].Timers[vi].Value, -1));
            else
              if Copy(LowerCase(A[1]), 1, 2) = 'dc' then
                gLuaPushNumberdp(L,
                  StrToIntDef(gScriptsS[idx].Timers[vi].Value, -1))
              else
                gLuaPushLStringej(L,
                  PChar(gScriptsS[idx].Timers[vi].Value),
                  Length(gScriptsS[idx].Timers[vi].Value));
            end;
            Result := 1;
          end;
        { `logging` пересобирается в команду `set logging ...`
          и уходит диспетчеру под ЧУЖИМ номером 40 (delimiter/set). }
        111:
          begin
            S := 'set logging';
            for q := 0 to k - 1 do
              S := S + ' ' + A[q];
            i := 40;
            ExecScriptCommand(TScanThread(gScriptsS[idx]), i, S);
          end;
      end;
    end;
  end;
end;

{$I+}
procedure RunLuaScript(T: TScanThread);
var
  S, M: string;
  Err: Integer;
  E, P1, P2, N, Cnt: Integer;
  R: Integer;
begin
  { Запуск блока `--lua ... -- endlua` внутри скрипта UoPilot.
    Сначала объекту-обёртке отдаётся номер скрипта, потом в его lua_State
    регистрируются ВСЕ команды языка (311 штук, обработчик у всех один --
    он узнаёт себя по upvalue с именем), потом выполняется сам чанк. }
  TLua(T.DebugForm).ScriptNo := StrToInt(T.Name);
  TLua(T.DebugForm).RegP('findwindow', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('size', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('msg', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('say', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('send', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('macro_send', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('send217', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('sendex', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('drag', @LuaScriptCommand, 5);
  TLua(T.DebugForm).RegP('left', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('right', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('double_left', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('double_right', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('middle', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('double_middle', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('left_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('left_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('right_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('right_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('middle_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('middle_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('move', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('move_smooth', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kleft', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kright', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('double_kleft', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('double_kright', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kmiddle', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('double_kmiddle', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kleft_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kleft_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kright_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kright_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kmiddle_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('kmiddle_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('pleft', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('pright', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('double_pleft', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('double_pright', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('pmiddle', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('double_pmiddle', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('pleft_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('pleft_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('pright_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('pright_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('pmiddle_down', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('pmiddle_up', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('send_up', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('send217_up', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('send_down', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('send217_down', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('sendex_up', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('sendex_down', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('wheel_down', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('wheel_up', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('pwheel_down', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('pwheel_up', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('kwheel_down', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('kwheel_up', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('macro_load', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('macro_play', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('exec', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('terminate', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('wait', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('flash', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('alarm', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('end_script', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('pause_script', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('resume_script', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('stop_script', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('start_script', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('injection', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('load_array', @LuaScriptCommand, 8);
  TLua(T.DebugForm).RegP('save_array', @LuaScriptCommand, 6);
  TLua(T.DebugForm).RegP('showwindow', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('readmem', @LuaScriptCommand, 5);
  TLua(T.DebugForm).RegP('writemem', @LuaScriptCommand, 5);
  TLua(T.DebugForm).RegP('printscreen', @LuaScriptCommand, 6);
  TLua(T.DebugForm).RegP('post', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('post_up', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('post_down', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('load_script', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('execandwait', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('init_arr', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('log', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('pluginload', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('pluginreload', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('pluginunload', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('sort_array', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('delete_array', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('restart_script', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('keyboard', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('mouse', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('hint', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('filerename', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('filecopy', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('filedelete', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('filesetattr', @LuaScriptCommand, 5);
  TLua(T.DebugForm).RegP('filesetdate', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('dircreate', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('dirremove', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('dir', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('eval', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('write', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('exit', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('set', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('call', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('get', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('claqua', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clblack', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clblue', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('cldkgray', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clfuchsia', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clgray', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clgreen', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('cllime', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clltgray', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clmaroon', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clnavy', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clolive', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clpurple', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clred', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clsilver', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clteal', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clwhite', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('clyellow', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('windowhandle', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('loghandle', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('windowpos', @LuaScriptCommand, 5);
  TLua(T.DebugForm).RegP('mouse_pos', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('year', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('month', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('day', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('priority', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('linedelay', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('clipboard', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('logging', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('getlayout', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('windowfromcursor', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('getselectedtext', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('scripts', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('current_script', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('active_script', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('defcolor', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('defx', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('defy', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('defxabs', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('defyabs', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('screenheight', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('screenwidth', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('desktopheight', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('desktopwidth', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('monitorheight', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('monitorwidth', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('monitor', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('mousepos_x', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('mousepos_y', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('mouseposabs_x', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('mouseposabs_y', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('pi', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('hotkeystart', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('hotkeypause', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('min', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('hour', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('sec', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('timer', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('timer1', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('timer2', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('timer3', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('timer4', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('logautoopen', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('messagesoutputto', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('getfocus', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('name', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('gold', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('wght', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('armor', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('hits', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('mana', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('stam', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lastmsg', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('str', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('int', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('dex', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('chardir', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lastobjectid', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lastobjecttype', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lasttargetid', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lasttargetx', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lasttargety', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lasttargetz', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lasttargetkind', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lastliftedid', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lastskill', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('lastspell', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('laststatictype', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('war', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('arun', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('target', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('charposx', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('charposy', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('charposz', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('hidden', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('findwindow', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('random', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('getwindow', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('getwindowtext', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('color', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('prompt', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('setwindowtext', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('findcolor', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('size', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('setlayout', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('setselectedtext', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('hex2dec', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('dec2hex', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('findimage', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('posex', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('copy', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('delete', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('insert', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('indexof', @LuaScriptCommand, 7);
  TLua(T.DebugForm).RegP('fileexists', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('filegetattr', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('filegetdate', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('windowfrompoint', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('abs', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('round', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('floor', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('ceil', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('frac', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('sqrt', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('power', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('exp', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('ln', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('log', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('sin', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('cos', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('tan', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('arcsin', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('arccos', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('arctan', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('degtorad', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('radtodeg', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('trunc', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('minx', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('maxx', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('mean', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('mod', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('point_distance', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('point_direction', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('lengthdir_x', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('lengthdir_y', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('is_real', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('is_string', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('chr', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('ord', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('string_replace', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('string_count', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('string_lower', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('string_upper', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('string_letters', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('string_digits', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('dayofweek', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('eval', @LuaScriptCommand, 20);
  TLua(T.DebugForm).RegP('colortorgb', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('colortored', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('colortogreen', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('colortoblue', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('ltrim', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('rtrim', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('trim', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('div', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('regexp', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('chartohex', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('chartohexf', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('moduleaddress', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('arrayaddress', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('sendmessage', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('postmessage', @LuaScriptCommand, 4);
  TLua(T.DebugForm).RegP('getimage', @LuaScriptCommand, 6);
  TLua(T.DebugForm).RegP('deleteimage', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('loadimage', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('saveimage', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('relativeaddress2absolute', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('absoluteaddress2relative', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('setprocesspriority', @LuaScriptCommand, 2);
  TLua(T.DebugForm).RegP('getprocesspriority', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('checkgetcolor', @LuaScriptCommand, 3);
  TLua(T.DebugForm).RegP('version', @LuaScriptCommand, 0);
  TLua(T.DebugForm).RegP('suspendprocess', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('resumeprocess', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('workwindow', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('errorlevel', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('terminated', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('delimiter', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('workwindowpid', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('homepath', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('exefilename', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('clickoffsetx', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('clickoffsety', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('findoffsetx', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('findoffsety', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('sendexdelay', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('mouseclickdelay', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('promptpos_x', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('promptpos_y', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('scriptPath', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('scriptName', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('get_script_text', @LuaScriptCommand, 1);
  TLua(T.DebugForm).RegP('set_script_text', @LuaScriptCommand, 2);
  Err := 0;
  M := '';
  try
    R := LuaDoString(TLua(T.DebugForm).Handle, PChar(T.Line));
    Inc(Err, R);
  except
    on EAccessViolation do
    begin
      E := GetLastError;
      if E = 0 then
        Err := 0
      else
      begin
        T.Msg := SysErrorMessage(E);
        ShowScriptMsg(T);
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
    S := gLuaStatusTextjm[Err] + #13#10
  else
    S := 'Lua error.'#13#10 + M;
  if gLuaIsStringej(TLua(T.DebugForm).Handle, -1) <> 0 then
    S := S + gLuaToLStringej(TLua(T.DebugForm).Handle, -1, nil);
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
    ShowScriptMsg(T);
    T.StopRequested := True;
  end
  else
    ShowScriptMsg(T);
end;

function EnumFindWndProc(H: HWND; L: Integer): Boolean; stdcall;
{ Обратный вызов EnumWindows для поиска окна ПО НОМЕРУ ПРОЦЕССА. Ответ
  False останавливает перебор; найденное окно кладётся в поле потока, оттуда
  же берётся искомый номер процесса, а сам поток приходит вторым доводом
  (lParam = SelfRef). Ответ -- Boolean, а не BOOL. }
var
  Pid: DWORD;
begin
  Result := True;
  if IsWindow(H) and IsWindowVisible(H) then
  begin
    GetWindowThreadProcessId(H, @Pid);
    if TScanThread(L).FindPid = Pid then
    begin
      Result := False;
      TScanThread(L).FoundWnd := H;
    end;
  end;
end;

procedure EbFindWnd(T: TScanThread; var S: string; F: Boolean);
{ Поиск окна по описанию -- самая большая функция юнита. Это процедура,
  ответ отдаётся через var-строку.

  `findwindow` отдаёт сюда описание окна и признак «список»:
  * края описания обрезаются по СИМВОЛАМ, которых нет в gWordCharsadq;
  * пустое описание -> текущее окно переднего плана;
  * F=False: FindWindow по заголовку, потом по классу, потом обход всех
  окон верхнего уровня -- сперва точное начало заголовка
  (AnsiStrLIComp), потом вхождение подстроки;
  * F=True: обход всех окон от Application.Handle с накоплением списка
  `номер|заголовок/`, а если по заголовкам никто не нашёлся -- ВТОРОЙ
  обход по ИМЕНАМ КЛАССОВ; заголовок с '|', '/' или кавычкой по краю
  берётся в кавычки;
  * если окна нет -- ищется ПРОЦЕСС с таким именем (Process32First/Next);
  * если и процесса нет, а описание -- число, оно считается номером
  процесса, и окно ищется через EnumWindows.

  `if (W > 0) and LFound then ;` в хвосте -- не описка: условие считается,
  а тела у него нет. }
var
  Res: string;
  sT: string;
  LFound: Boolean;
  W: Cardinal;
  Pid: Integer;
  Top: Cardinal;
  ShowAll: Boolean;
  PE: TProcessEntry32;
  B: Cardinal;
  H: Cardinal;
  P: PChar;
  Vis: Boolean;
begin
  while (Length(S) > 0) and not (S[1] in gWordCharsadq) do
    Delete(S, 1, 1);
  while (Length(S) > 0) and not (S[Length(S)] in gWordCharsadq) do
    Delete(S, Length(S), 1);
  if Length(S) <= 0 then
    W := GetForegroundWindow
  else
    W := 0;
  if not F then
  begin
    if W <= 0 then
      W := FindWindow(nil, PChar(S));
    if W <= 0 then
      W := FindWindow(PChar(S), nil);
    if W <= 0 then
    begin
      H := GetTopWindow(0);
      repeat
        B := GetWindow(H, GW_OWNER);
        if B <> 0 then
          H := B;
      until B = 0;
      B := GetWindow(H, GW_HWNDFIRST);
      H := B;
      P := StrAlloc(250);
      TScanThread(T).Synchronize(T.SyncShowAllWnd);
      ShowAll := T.ShowAllWnd;
      repeat
        GetWindowText(H, P, 240);
        Vis := IsWindowVisible(H);
        if IsWindow(H) and (ShowAll or Vis) and
           (AnsiStrLIComp(P, PChar(S), Length(S)) = 0) then
        begin
          W := H;
          Break;
        end;
        if IsWindow(H) and (Vis or ShowAll) and (Pos(PChar(S), P) > 0) then
          W := H;
        B := GetWindow(H, GW_HWNDNEXT);
        if B <> 0 then
          H := B;
      until B = 0;
      StrDispose(P);
    end;
  end
  else
  begin
    H := Application.Handle;
    repeat
      B := GetWindow(H, GW_OWNER);
      if B <> 0 then
        H := B;
    until B = 0;
    Top := H;
    B := GetWindow(H, GW_HWNDFIRST);
    H := B;
    P := StrAlloc(250);
    TScanThread(T).Synchronize(T.SyncShowAllWnd);
    ShowAll := T.ShowAllWnd;
    repeat
      GetWindowText(H, P, 240);
      Vis := IsWindowVisible(H);
      if IsWindow(H) and (Vis or ShowAll) and (Pos(PChar(S), P) > 0) then
      begin
        sT := P;
        if (Pos('|', P) > 0) or (Pos('/', P) > 0) or (P[0] = '"') or
           (P[Length(sT) - 1] = '"') then
          Res := Res + IntToStr(H) + '|' + '"' + P + '"' + '/'
        else
          Res := Res + IntToStr(H) + '|' + P + '/';
        W := H;
      end;
      B := GetWindow(H, GW_HWNDNEXT);
      if B <> 0 then
        H := B;
    until B = 0;
    if Res = '' then
    begin
      B := GetWindow(Top, GW_HWNDFIRST);
      H := B;
      repeat
        GetClassName(H, P, 240);
        Vis := IsWindowVisible(H);
        if IsWindow(H) and (Vis or ShowAll) and (Pos(PChar(S), P) > 0) then
        begin
          sT := P;
          if (Pos('|', P) > 0) or (Pos('/', P) > 0) or (P[0] = '"') or
             (P[Length(sT) - 1] = '"') then
            Res := Res + IntToStr(H) + '|' + '"' + P + '"' + '/'
          else
            Res := Res + IntToStr(H) + '|' + P + '/';
          W := H;
        end;
        B := GetWindow(H, GW_HWNDNEXT);
        if B <> 0 then
          H := B;
      until B = 0;
    end;
    StrDispose(P);
  end;
  LFound := False;
  if W <= 0 then
  begin
    S := UpperCase(S);
    B := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    PE.dwSize := SizeOf(PE);
    LFound := Process32First(B, PE);
    while LFound do
    begin
      if UpperCase(PE.szExeFile) = S then
      begin
        if not F then
        begin
          S := IntToStr(PE.th32ProcessID);
          Break;
        end
        else
          Res := Res + IntToStr(PE.th32ProcessID) + '|' + PE.szExeFile + '/';
      end;
      LFound := Process32Next(B, PE);
    end;
    CloseHandle(B);
  end;
  if not F then
  begin
    if W <= 0 then
    begin
      try
        T.FoundWnd := 0;
        if TryStrToInt(S, Pid) then
        begin
          T.FindPid := Pid;
          EnumWindows(@EnumFindWndProc, Integer(T.SelfRef));
          B := T.FoundWnd;
        end
        else
          B := 0;
      except
        B := 0;
      end;
      W := B;
      if W > 0 then
        if LFound then
        begin
        end;
    end;
    S := IntToStr(W);
  end
  else
    S := Res;
end;

function EbPWS_F0A9(A0: string; A1: Integer; A2: Integer): string;
begin
  Result := A0;
end;

function EbPWS_2884(A0: string; A1: Integer; A2: string): string;
begin
  Result := A0;
end;

function EbWnd(T: TScanThread): Integer;
begin
  Result := 0;
end;

function EbSelWnd(T: TScanThread): Integer;
begin
  Result := 0;
end;

function FindArrayItem(T: TScanThread; S: string; var P: Integer;
                       var Fin, Row, Col, Scr, Idx: Integer;
                       var N, R: string): Boolean;
var
  nOpen: Integer;
  sIn: string;
  bBr: Boolean;
  sTmp: string;
  i, L, nLev, nAt: Integer;
  W: TScanThread;
begin
  Fin := -1;
  Row := -1;
  Col := -1;
  Scr := -1;
  Idx := -1;
  R := '';
  Result := False;
  P := PosEx('%', S, P);
  if P <= 0 then
  begin
    P := -1;
    Exit;
  end;
  i := P;
  L := Length(S);
  while (i <= L) and (S[i] in ['.'] + gWordCharsadq) do
    Inc(i);
  N := Copy(S, P + 1, i - P - 1);
  bBr := False;
  while (i <= L) and not (S[i] in gWordCharsadq - ['[', ']']) do
  begin
    if S[i] = '[' then
    begin
      bBr := True;
      Break;
    end;
    Inc(i);
  end;
  if not bBr then
  begin
    P := -1;
    Exit;
  end;
  nOpen := i;
  nLev := 0;
  bBr := False;
  nAt := 0;
  while i <= L do
  begin
    case S[i] of
      '[':
        begin
          Inc(nLev);
          bBr := True;
          if nAt = 0 then
            nAt := i;
        end;
      ']': Dec(nLev);
    end;
    if bBr and (nLev = 0) then
      Break;
    Inc(i);
  end;
  if i > L then
  begin
    P := -1;
    Exit;
  end;
  Fin := i;
  i := nOpen + 1;
  while (i < L) and (S[i] in [#9, ' ']) do
    Inc(i);
  L := Fin - 1;
  while (L > 0) and (S[L] in [#9, ' ']) do
    Dec(L);
  sIn := Copy(S, i, L - i + 1);
  i := Pos('.', N);
  if i > 0 then
  begin
    sTmp := N;
    Delete(sTmp, 1, i);
    N := AnsiLowerCase(Copy(N, 1, i - 1));
    Scr := TScanThread(T).ScriptStrToInt(sTmp);
  end;
  i := 1;
  L := Length(sIn);
  while (i <= L) and (sIn[i] in ['.'] + gWordCharsadq) do
    Inc(i);
  sTmp := Copy(sIn, 1, i - 1);
  if not TryStrToInt(sTmp, Row) then
  begin
    sTmp := EvalScriptExpr(T, 'calc ' + sTmp, -1);
    if not TryStrToInt(sTmp, Row) then
      Exit;
  end;
  while (i < L) and (sIn[i] in [#9, ' ']) do
    Inc(i);
  sTmp := Copy(sIn, i, L - i + 1);
  if not TryStrToInt(sTmp, Col) then
  begin
    sTmp := EvalScriptExpr(T, 'calc ' + sTmp, -1);
    if not TryStrToInt(sTmp, Col) then
      Col := -1;
  end;
  if Scr < 0 then
    W := TScanThread(T.SelfRef)
  else
    W := TScanThread(gScriptso3[Scr].SelfRef);
  Idx := 0;
  { `with` здесь не украшение: приведение в нём заводит отдельное значение,
    под которое выделяется свой регистр -- вторая копия объекта. Без неё
    цикл считает предмет заново. Так же сделано в `ScanWatchList`. }
  with TScanThread(W) do
  while Length(Arr48) > Idx do
  begin
    if Arr48[Idx].Name = N then
    begin
      if Length(Arr48[Idx].Data) < Row then
        Exit;
      if Col <= 0 then
      begin
        { Счётчик здесь -- `i`, а не отдельная переменная: значение разбора к
          этому месту уже мертво, зато у `i` два десятка употреблений выше,
          и только с ними он обгоняет `W` в раздаче регистров. С отдельной
          переменной раздача зеркалится. }
        for i := 1 to Length(Arr48[Idx].Data[Row - 1]) do
          if i > 1 then
            R := R + T.Str1048B8 + Arr48[Idx].Data[Row - 1][i - 1]
          else
            R := Arr48[Idx].Data[Row - 1][i - 1];
        Result := True;
        Exit;
      end
      else
      begin
        if Length(Arr48[Idx].Data[Row - 1]) < Col then
          Exit;
        R := Arr48[Idx].Data[Row - 1][Col - 1];
        Result := True;
        Exit;
      end;
    end;
    Inc(Idx);
  end;
end;

function SplitCmdLine(T: TScanThread; S: string): Integer;
var
  sT: string;
  nLen: Integer;
  bQ, bSp: Boolean;
  nI, nK, nCnt: Integer;
  nZ: Integer;
  oZ: TScanThread;
begin
  T.CmdCount := 0;
  for nI := -9 to 9 do
    T.CmdParts[nI] := '';
  nLen := Length(S);
  nCnt := 0;
  sT := '';
  bQ := False;
  bSp := False;
  for nI := 1 to nLen do
  begin
    if S[nI] = '"' then
    begin
      if bQ then
        bQ := False
      else
      begin
        nK := nLen;
        while (S[nK] <> '"') and (nK > nI) do
        begin
          Dec(nK);
          nZ := nCnt;
          nZ := nCnt;
          oZ := T;
        end;
        if nK > nI then
          bQ := True;
      end;
    end;
    if bSp then
    begin
      T.CmdParts[-nCnt] := Copy(S, nI - 1, nLen - nI + 2);
      bSp := False;
    end;
    if (S[nI] in (['"'] + gWordCharsadq)) or bQ then
    begin
      if (sT = '') and (nCnt > 0) then
        bSp := True;
      sT := sT + S[nI];
    end
    else if sT <> '' then
    begin
      if nCnt > 9 then
        Break;
      T.CmdCount := nCnt + 1;
      T.CmdParts[nCnt] := sT;
      Inc(nCnt);
      sT := '';
      bQ := False;
    end;
  end;
  if sT <> '' then
  begin
    if nCnt <= 9 then
    begin
      T.CmdCount := nCnt + 1;
      T.CmdParts[nCnt] := sT;
    end;
    sT := '';
  end;
  Result := T.CmdCount;
end;

function EvalScriptPoint(T: TScanThread; S: string; N: Integer): string;
  { Множество символов слова живёт в Unit1 и берётся через указатель.
    Своя добавка -- одна кавычка; в голове EvalScriptExpr их две. }
var
  W: string;
  Q: Boolean;
  I, J, C: Integer;
begin
  C := 0;
  W := '';
  Q := False;
  for I := 1 to Length(S) do
  begin
    if S[I] = '"' then
      if Q then
        Q := False
      else
      begin
        J := Length(S);
        while (S[J] <> '"') and (J > I) do
          Dec(J);
        if J > I then
          Q := True;
      end;
    if (S[I] in ['"'] + gWordCharsadq) or Q or ((N < 0) and (C = -N)) then
    begin
      W := W + S[I];
      Continue;
    end;
    if W = '' then
      Continue;
    if C = N then
      Break;
    C := C + 1;
    W := '';
    Q := False;
  end;
  if (N < 0) and (C < -N) then
  begin
    W := '';
    T.WordPos := 0;
  end;
  T.WordPos := I - Length(W);
  if N = 0 then
    Result := AnsiLowerCase(W)
  else
  begin
    Result := W;
    if (N > 0) and (N <> C) then
    begin
      T.WordPos := 0;
      Result := '';
    end;
  end;
end;

procedure ScanDirReal(const AMask, AFilter: string; ANoRec: Boolean);
begin
end;

procedure MouseClickReal(AWnd: HWND; ABtn: Byte; const S: string;
  var P: TPoint; N: Integer; const S2: string);
begin
end;

procedure WaitDelayReal(const S: string);
begin
end;

function EvalScriptPart(T: TScanThread; S: string; N: Integer): string;
  { Набор символов слова живёт в чужом юните и берётся через указатель.
    Чтение одно, поэтому и кэшировать нечего. }
var
  W: string;
  Q: Boolean;
  I, J, C: Integer;
begin
  C := 0;
  W := '';
  Q := False;
  for I := Length(S) downto 1 do
  begin
    if S[I] = '"' then
      if Q then
        Q := False
      else
      begin
        J := Length(S);
        while (S[J] <> '"') and (J > I) do
          Dec(J);
        if J > I then
          Q := True;
      end;
    if (S[I] in ['"'] + gWordCharsadq) or Q or ((N < 0) and (C = -N)) then
    begin
      W := S[I] + W;
      Continue;
    end;
    if W = '' then
      Continue;
    if C = N then
      Break;
    C := C + 1;
    W := '';
    Q := False;
  end;
  if (N < 0) and (C < -N) then
  begin
    W := '';
    T.WordPos := 0;
  end;
  T.WordPos := I + 1;
  if N = 0 then
    Result := AnsiLowerCase(W)
  else
  begin
    Result := W;
    if (N > 0) and (N <> C) then
    begin
      T.WordPos := 0;
      Result := '';
    end;
  end;
end;

procedure SetMaskList(L: TObject; const S: string);
begin
end;

procedure ScanDirStub(const AMask, AFilter: string; ANoRec: Boolean);
begin
end;

function FocusedWindow(T: TScanThread): Integer;
var
  tidFg, tidCur: Cardinal;
  hw: HWND;
begin
  Result := 0;
  hw := GetForegroundWindow;
  if hw <> 0 then
  begin
    tidFg := GetWindowThreadProcessId(hw, nil);
    tidCur := GetCurrentThreadId;
    if tidFg <> tidCur then
      if AttachThreadInput(tidCur, tidFg, True) then
      try
        Result := GetFocus;
      finally
        AttachThreadInput(tidCur, tidFg, False);
      end;
  end;
end;

procedure EbRegexAnchor;
var
  sAnc: string;
begin
  { Ссылка на PCRE нужна, чтобы компоновщик не выбросил обёртку и все
    pcre*.obj: единственный пользователь TPerlRegEx -- ветка `regexp` этой
    же функции. Именно ПРОЦЕДУРА, а не функция-строка: вызов строковой
    функции оператором завёл бы в `EvalScriptExpr` лишнюю строковую
    временную. Результат тут никому не нужен -- нужна ссылка. }
  with TPerlRegEx.Create do
  try
    RegEx := '.';
    Subject := '.';
    if Match then
      sAnc := MatchedText;
  finally
    Free;
  end;
end;

procedure ParseWaitSuffix2(const S: string; var A: Integer; var B: string);
begin
end;

procedure SplitCmdLine2(T: TScanThread; const S: string);
begin
end;

procedure SetScriptVar(T: TScanThread; C: Char; N, A, B: Integer;
                       const S: string; P: Integer; const S2: string);
begin
end;

procedure Synchronize2;
begin
end;

procedure CaptureScreen(T: TScanThread);
begin
end;

procedure Synchronize3;
begin
end;

procedure LoadImageFile2(T: TScanThread);
begin
end;

function FindScriptVarC(T: TScanThread; C: Char; const S: string;
                        A, B: Integer): Integer;
begin
  Result := 0;
end;

procedure CaptureScreen2(T: TScanThread);
begin
end;

function GetPixel2(DC: HDC; X, Y: Integer): Integer;
begin
  Result := 0;
end;

function EbArcCos(A: Extended): Extended;
begin
  Result := 0;
end;

function EbArcSin(A: Extended): Extended;
begin
  Result := 0;
end;

function EbCeil(A: Extended): Integer;
begin
  Result := 0;
end;

function EbDegToRad(A: Extended): Extended;
begin
  Result := 0;
end;

function EbFloor(A: Extended): Integer;
begin
  Result := 0;
end;

function EbLogN(A, B: Extended): Extended;
begin
  Result := 0;
end;

function EbPower(A, B: Extended): Extended;
begin
  Result := 0;
end;

function EbRadToDeg(A: Extended): Extended;
begin
  Result := 0;
end;

function EbTan(A: Extended): Extended;
begin
  Result := 0;
end;

procedure ReadMemTyped(H: THandle; var Buf; var Addr: Int64; A: Int64;
                       B: Int64; const C: string; D: DWORD);
begin
end;

function StrToInt2(const S: string): Integer;
begin
  Result := 0;
end;

function FindParenGroup(T: TScanThread; S: string; N: Integer;
                        var A, B: Integer): string;
var
  nD, nS: Integer;
  bF: Boolean;
begin
  nD := 0;
  bF := False;
  nS := 0;
  while N <= Length(S) do
  begin
    case S[N] of
      '(':
        begin
          Inc(nD);
          bF := True;
          if nS = 0 then
            nS := N;
        end;
      ')': Dec(nD);
    end;
    if bF and (nD = 0) then
      Break;
    Inc(N);
  end;
  if N <= Length(S) then
  begin
    A := nS;
    B := N;
    Inc(nS);
    Dec(N);
    while (nS < Length(S)) and (S[nS] in [#9, ' ']) do
      Inc(nS);
    while (N > 0) and (S[N] in [#9, ' ']) do
      Dec(N);
    Result := Copy(S, nS, N - nS + 1);
  end
  else
  begin
    Result := '';
    A := 0;
    B := 0;
  end;
end;

function FindParenGroup2(T: TScanThread; S: string; N: Integer;
                         var A, B: Integer): string;
var
  nS, nD, nE: Integer;
  bF: Boolean;
begin
  bF := False;
  nS := N;
  N := Length(S);
  nE := 0;
  while N > nS do
  begin
    if S[N] = ')' then
    begin
      nE := N;
      Dec(N);
      nD := 1;
      while N > nS do
      begin
        case S[N] of
          '(': Dec(nD);
          ')': Inc(nD);
        end;
        if nD = 0 then
        begin
          bF := True;
          Break;
        end;
        Dec(N);
      end;
      Break;
    end;
    Dec(N);
  end;
  if bF then
  begin
    A := N;
    B := nE;
    Inc(N);
    Dec(nE);
    while (N < Length(S)) and (S[N] in [#9, ' ']) do
      Inc(N);
    while (nE > 0) and (S[nE] in [#9, ' ']) do
      Dec(nE);
    Result := Copy(S, N, nE - N + 1);
  end
  else
  begin
    Result := '';
    A := 0;
    B := 0;
  end;
end;

function FindQuotedGroup(T: TScanThread; S: string; N: Integer;
                         var A, B: Integer): string;
var
  bF: Boolean;
begin
  bF := False;
  while N <= Length(S) do
  begin
    if S[N] = '"' then
    begin
      A := N;
      Inc(N);
      while N <= Length(S) do
      begin
        if S[N] = '"' then
        begin
          B := N;
          bF := True;
          Break;
        end;
        Inc(N);
      end;
    end;
    if bF then
      Break;
    Inc(N);
  end;
  if bF then
    Result := Copy(S, A + 1, B - (A + 1))
  else
  begin
    Result := '';
    A := 0;
    B := 0;
  end;
end;

procedure ScriptIdle2;
begin
end;

function EbPadF: TEbPadRec;
begin
  FillChar(Result, SizeOf(Result), 0);
end;

procedure EbUsePad(const R: TEbPadRec);
begin
end;

function FindParenGroup3(T: TScanThread; const S: string; N: Integer;
                         var C: string; var A, B: Integer): string;
begin
  Result := S;
end;

procedure EvalScriptExprP(T: TScanThread; const S: string; N: Integer);
begin
end;

function SplitCmdLine3(T: TScanThread; const S: string): Integer;
begin
  Result := 0;
end;

function EbIncYear(D: TDateTime; N: Integer): TDateTime;
begin
  Result := D;
end;

function EbIncMonth(D: TDateTime; N: Integer): TDateTime;
begin
  Result := D;
end;

function EbIncDay(D: TDateTime; N: Integer): TDateTime;
begin
  Result := D;
end;

function EbIncHour(D: TDateTime; N: Int64): TDateTime;
begin
  Result := D;
end;

function EbIncMinute(D: TDateTime; N: Int64): TDateTime;
begin
  Result := D;
end;

function EbIncSecond(D: TDateTime; N: Int64): TDateTime;
begin
  Result := D;
end;

procedure EbDecodeDateTime(D: TDateTime; var Y, M, Dd, H, N, S, MS: Word);
begin
end;

function EbEval(T: TScanThread; const S: string; N: Integer): string;
begin
  Result := S;
end;

procedure EbFPG(T: TScanThread; const S: string; N: Integer;
                var A, B: Integer; var C: string);
begin
end;

function EbPoint(T: TScanThread; const S: string; N: Integer): string;
begin
  Result := S;
end;

function EbS2I(T: TScanThread; const S: string): Integer;
begin
  Result := 0;
end;

function EbFSV(T: TScanThread; C: Char; const S: string;
               var A, B: Integer): Integer;
begin
  Result := 0;
end;

procedure EbSSV(T: TScanThread; c: Char; ix: Integer; const s2: string;
                i3: Integer; const v: string; i2, i1: Integer);
begin
end;

function GetString(const S: string): string;
begin
  Result := S;
end;

function EbStrComp(A, B: PChar): Integer;
begin
  Result := 0;
end;

procedure SetScriptVar2(T: TScanThread; C: Char; N, A, B: Integer;
                        const S: string; P: Integer; const S2: string);
begin
end;

procedure ShowErr(T: TScanThread; const S: string);
begin
end;

function ExprName(N: Integer): string;
begin
  Result := '';
end;

function IsClientWindow(T: TScanThread; H: Integer): Boolean;
begin
  Result := False;
end;

function EbPWS(T: TScanThread; const S: string; N: Integer): string;
begin
  Result := S;
end;

function EbSnap(T: TScanThread; N: Integer): Integer;
begin
  Result := 0;
end;

function EvalScriptExpr(T: TScanThread; sv: string; nv: Integer): string;
label
  NextChar;                     { Выход подстановки к Inc(k) }
var
  wcnt        : Integer;
  bFlag: Boolean;
  ok: Boolean;
  pIns        : Integer;
  arrCol     : array of TColRec;
  ptC: TPoint;
  a          : Cardinal;
  qq         : Integer;
  V          : string;
  sEe        : string;
  sB         : string;
  nn         : Integer;
  q          : Integer;
  bHas: Boolean;
  bMatch: Boolean;
  bHit: Boolean;
  nTol       : Integer;
  nPct       : Integer;
  nGap       : Integer;
  ts         : string;
  nm         : string;
  i          : Integer;
  p          : Integer;
  lastp      : Integer;
  k          : Integer;
  mm         : Integer;
  kk         : Integer;
  nQ         : Integer;
  nR3        : Integer;
  nAdd       : Integer;
  nH         : Integer;
  pb         : PChar;
  nn07C      : Integer;
  wB: Word;
  wA: Word;
  rd         : DWORD;
  nQ2        : Integer;
  hp         : Cardinal;
  crd: array[0..2] of SmallInt;
  bDir: Byte;                    { ветвь chardir }
  sd         : string;
  sdi        : Integer;
  pw         : PWideChar;
  pc         : PChar;
  tt         : string;
  sCc        : string;
  sA         : string;
  tv         : string;
  sDd: string;
  bTol: Byte;
  idx        : Integer;
  err: Boolean;
  hash: Boolean;
  hProc      : THandle;
  force: Boolean;
  scr        : Integer;
  quo: Boolean;
  hasq: Boolean;
  cK: Char;
  cS: Char;                      { ветвь size }
  wSk: SmallInt;
  wv: Word;
  ptA: TPoint;
  ptB: TPoint;
  ptF: TPoint;
  ptD: TPoint;
  ptE: TPoint;
  ptC104: TPoint;
  v10C: Integer;
  bAbs: Boolean;
  fCase: Boolean;
  wC: Word;
  wD: Word;
  rr         : Cardinal;
  bad: Boolean;
  nJ2        : Integer;
  nGy        : Integer;
  nHits      : Integer;
  nRow       : Integer;
  nCol       : Integer;
  nShots     : Integer;
  nB_9E32    : Integer;
  v13C: Integer;
  bMulti: Boolean;
  neg13E: Boolean;
  isVar13F: Boolean;
  bDot: Boolean;
  arg        : string;
  sAcc       : string;
  s3         : string;
  s4         : string;
  s5         : string;
  s1         : string;
  s2         : string;
  s3160      : string;
  sOptV      : string;
  s168       : string;
  s16C       : string;
  s170       : string;
  s174       : string;
  s178       : string;
  nLev_9E32  : Integer;
  nCnt2      : Integer;
  ccnt_F27C  : Integer;
  sub_F27C   : Integer;
  nB_33FB    : Integer;
  nLev_33FB  : Integer;
  w: string;
  isop: Boolean;
  isvar: Boolean;
  f: Extended;
  g: Extended;
  g2: Extended;
  g3: Extended;
  g4: Extended;
  nRep       : Integer;
  sTail      : string;
  nStart2    : Integer;
  nIdx3      : Integer;
  nPix       : Integer;
  nPad       : Integer;
  th_1A04    : THandle;
  nLen3      : Integer;
  nR1        : Integer;
  nG1        : Integer;
  nB1        : Integer;
  nIdx       : Integer;
  kk214      : Cardinal;
  pt: TPoint;
  dcS        : HDC;
  nLim       : Integer;
  nSave      : Integer;
  k1         : Integer;
  u1         : Integer;   { довод ParseWaitSuffix }
  jj_2BE9    : Integer;
  dep_2BE9   : Integer;
  i1: Int64;
  i2: Int64;
  bF1: Byte;
  wF2: Word;
  nDW: Cardinal;
  cF: Char;
  sngF: Single;
  rl48: Real48;
  dblF: Double;
  i64: Int64;
  nP1: Int64;
  nVal: Int64;
  nWnd       : Integer;
  bErrShown  : Boolean;
  jj_2A15    : array[1..3] of Byte;     { добивка: ts2 остаётся на -$290 }
  ts2: TTimeStamp;
  dtA: Double;
  dep_2A15   : Integer;
  ebR1: TEbR1;   { голова области B }
  st2: TStat2;
  nmv: ShortString;
  ebR2: TEbR2;
  padFmB     : array[1..140] of Byte;   { раскладка области B }
  st1: TStat1;
  crd548: array[0..2] of Integer;
  buf: array[0..255] of Char;
  fRead: array[0..288] of Boolean;
  mbi: TMemoryBasicInformation;
  rcW: TRect;
  sFind: string[255];
  sFind99C: array[0..255] of Char;   { буфер windowpos }
  ebW         : TEbW;   { семь слов под дату и время }
  te_1A04     : TlHelp32.TThreadEntry32;   { хвост области B }

  { Массив скриптов лежит в чужом юните; типизированная константа даёт одно
    обращение вместо двух через слот импорта -- так же сделано в
    `TScanThread.Execute`. }

  { ДЕРЖАТЕЛЬ КАДРА. Порядок упоминаний ЗДЕСЬ и есть раскладка кадра: слот
    выдаётся на первом упоминании, курсор идёт сверху вниз. Параметры `T`,
    `sv`, `nv` стоят в этом порядке и заодно выбывают из раздачи регистров,
    освобождая EBX/ESI счётчикам слов. Сама процедура не делает ничего --
    она нужна не программе, а раскладке. }
  procedure EbHoldFrameZ;
  begin
    FillChar(arrCol, SizeOf(arrCol), 0);
    FillChar(ptC, SizeOf(ptC), 0);
    FillChar(a, SizeOf(a), 0);
    FillChar(qq, SizeOf(qq), 0);
    FillChar(T, SizeOf(T), 0);
    FillChar(V, SizeOf(V), 0);
    FillChar(sEe, SizeOf(sEe), 0);
    FillChar(sB, SizeOf(sB), 0);
    FillChar(nn, SizeOf(nn), 0);
    FillChar(q, SizeOf(q), 0);
    FillChar(sv, SizeOf(sv), 0);
    FillChar(nv, SizeOf(nv), 0);
  end;

  { ВЛОЖЕННАЯ ПРОЦЕДУРА ВЫЧИСЛИТЕЛЯ. Разбирает список цветов ветки
    `findcolor` в `arrCol`: слово за словом из `V`, пока слова не кончатся.
    Слово бывает двух видов -- либо покомпонентное `R(..)G(..)B(..)` с
    диапазонами через дефис, либо одно число (тоже с дефисом или без),
    которое раскладывается по байтам.

    Своих локалов у неё нет вовсе: двадцать двойных слов в прологе -- это
    строковые временные, а всё остальное -- локалы внешней функции через
    статическую ссылку. Порядок их упоминания и держит кадр. }
  procedure ScriptIdle2;
  begin
    a := 1;
    qq := 0;
    sEe := EvalScriptExpr(T, V, a);        { временная -$4 }
    while sEe <> '' do
    begin
      SetLength(arrCol, qq + 1);
      arrCol[qq].Lo3 := Pos('B(', UpperCase(sEe));   { временная -$8 }
      arrCol[qq].Lo2 := Pos('G(', UpperCase(sEe));   { временная -$C }
      arrCol[qq].Lo1 := Pos('R(', UpperCase(sEe));   { временная -$10 }
      if (arrCol[qq].Lo3 > 0) or (arrCol[qq].Lo2 > 0) or
         (arrCol[qq].Lo1 > 0) then
      begin
        if arrCol[qq].Lo3 > 0 then
        begin
          sB := FindParenGroup(T, sEe, arrCol[qq].Lo3, ptC.X, ptC.Y);
          arrCol[qq].Lo3 := Pos('-', sB);            { временная -$14 }
          if arrCol[qq].Lo3 > 0 then
          begin
            arrCol[qq].Hi3 := StrToInt(Copy(sB, arrCol[qq].Lo3 + 1,
                                            Length(sB) - arrCol[qq].Lo3));
            arrCol[qq].Lo3 := StrToInt(Copy(sB, 0, arrCol[qq].Lo3 - 1));
          end                            { временные -$18 и -$1C }
          else
          begin
            arrCol[qq].Hi3 := StrToInt(sB);
            arrCol[qq].Lo3 := arrCol[qq].Hi3;
          end;
        end
        else
        begin
          arrCol[qq].Hi3 := $FF;
          arrCol[qq].Lo3 := 0;
        end;
        if arrCol[qq].Lo2 > 0 then
        begin
          sB := FindParenGroup(T, sEe, arrCol[qq].Lo2, ptC.X, ptC.Y);
          arrCol[qq].Lo2 := Pos('-', sB);            { временная -$20 }
          if arrCol[qq].Lo2 > 0 then
          begin
            arrCol[qq].Hi2 := StrToInt(Copy(sB, arrCol[qq].Lo2 + 1,
                                            Length(sB) - arrCol[qq].Lo2));
            arrCol[qq].Lo2 := StrToInt(Copy(sB, 0, arrCol[qq].Lo2 - 1));
          end                            { временные -$24 и -$28 }
          else
          begin
            arrCol[qq].Hi2 := StrToInt(sB);
            arrCol[qq].Lo2 := arrCol[qq].Hi2;
          end;
        end
        else
        begin
          arrCol[qq].Hi2 := $FF;
          arrCol[qq].Lo2 := 0;
        end;
        if arrCol[qq].Lo1 > 0 then
        begin
          sB := FindParenGroup(T, sEe, arrCol[qq].Lo1, ptC.X, ptC.Y);
          arrCol[qq].Lo1 := Pos('-', sB);            { временная -$2C }
          if arrCol[qq].Lo1 > 0 then
          begin
            arrCol[qq].Hi1 := StrToInt(Copy(sB, arrCol[qq].Lo1 + 1,
                                            Length(sB) - arrCol[qq].Lo1));
            arrCol[qq].Lo1 := StrToInt(Copy(sB, 0, arrCol[qq].Lo1 - 1));
          end                            { временные -$30 и -$34 }
          else
          begin
            arrCol[qq].Hi1 := StrToInt(sB);
            arrCol[qq].Lo1 := arrCol[qq].Hi1;
          end;
        end
        else
        begin
          arrCol[qq].Hi1 := $FF;
          arrCol[qq].Lo1 := 0;
        end;
      end
      else
      begin
        nn := Pos('-', sEe);
        if nn > 0 then
        begin
          { временные -$38 (значение), -$3C (склейка), -$40 (Copy) }
          q := StrToInt(EvalScriptExpr(T, 'calc ' + Copy(sEe, 0, nn - 1), 1));
          { и -$44, -$48, -$4C -- те же три на второй половине }
          nn := StrToInt(EvalScriptExpr(T, 'calc ' +
                         Copy(sEe, nn + 1, Length(sEe) - nn), 1));
        end
        else
        begin
          nn := StrToInt(sEe);
          q := nn;
        end;
        if q and $FF <= nn and $FF then
        begin
          arrCol[qq].Lo1 := q and $FF;
          arrCol[qq].Hi1 := nn and $FF;
        end
        else
        begin
          arrCol[qq].Lo1 := nn and $FF;
          arrCol[qq].Hi1 := q and $FF;
        end;
        q := q shr 8;
        nn := nn shr 8;
        if q and $FF <= nn and $FF then
        begin
          arrCol[qq].Lo2 := q and $FF;
          arrCol[qq].Hi2 := nn and $FF;
        end
        else
        begin
          arrCol[qq].Lo2 := nn and $FF;
          arrCol[qq].Hi2 := q and $FF;
        end;
        q := q shr 8;
        nn := nn shr 8;
        if q and $FF <= nn and $FF then
        begin
          arrCol[qq].Lo3 := q and $FF;
          arrCol[qq].Hi3 := nn and $FF;
        end
        else
        begin
          arrCol[qq].Lo3 := nn and $FF;
          arrCol[qq].Hi3 := q and $FF;
        end;
      end;
      Inc(qq);
      Inc(a);
      sEe := EvalScriptExpr(T, V, a);      { временная -$50 }
    end;
  end;

var
  aI         : Integer absolute a;
  function FindOpenParen(const S: string; var P: Integer): Boolean;
  var
    sTmp: string;
  begin
    if 1 = 0 then sTmp := S;
  end;

begin
  wcnt := 0;
  ts := '';
  quo := False;
  for k := 1 to Length(sv) do
  begin
    if sv[k] = '"' then
      if quo then
        quo := False
      else
      begin
        p := Length(sv);
        while (sv[p] <> '"') and (p > k) do
          Dec(p);
        if p > k then
          quo := True;
      end;
    if (sv[k] in ['"', '{'] + gWordCharsadq) or quo or
       ((nv < 0) and (wcnt = nv * -1) and (ts <> '')) then
    begin
      ts := ts + sv[k];
      Continue;
    end;
    if ts = '' then
      Continue;
    if wcnt = nv then
      Break;
    Inc(wcnt);
    ts := '';
    quo := False;
  end;
  if (nv < 0) and (wcnt < nv * -1) then
    ts := '';
  Result := '';
  if nv = 0 then
  begin
    Result := AnsiLowerCase(ts);
    T.CmdLine := k - Length(ts);
    Exit;
  end;
  Result := ts;
  T.WordPos := k - Length(ts);
  if ((nv > 0) and (wcnt <> nv)) or ((wcnt = nv) and (ts = '')) then
  begin
    Result := '';
    T.WordPos := 0;
    Exit;
  end;
  tt := EvalScriptExpr(T, sv, 0);
  isop := tt = 'supoponly';
  isvar := tt = 'supvaronly';
  if nv > 4 then
    if (tt <> 'drag') and (tt <> 'call') and (tt <> 'save_array') and
       (tt <> 'load_array') and (tt <> 'calc') and (tt <> 'printscreen') and
       not isop and not isvar then
      Exit;
  if nv = 1 then
    if (tt = 'set') or (tt = 'for') or (tt = 'readmem') or (tt = 'writemem') then
      Exit;
  if tt = 'get' then
    Exit;
  hProc := 0;
  force := False;
  scr := 0;
  if not isvar then
  begin
    if (tt = 'exec') or (tt = 'macro_load') or (tt = 'terminate') then
      hash := True
    else
      hash := False;
    for i := 0 to gCmdListah7.Count - 1 do
    begin
      if (i >= $C8) and (i <= $DB) then
        Continue;
      nm := gCmdListah7[i];
      if hash then
        nm := '#' + nm;
      p := Pos(nm, LowerCase(ts));
      lastp := 0;
      hasq := Pos('"', ts) > 0;
      while p > lastp do
      begin
        err := False;
        try
          if p > 1 then
            if ts[p - 1] in gWordCharsadq - ['(', ')', '.'] then
            begin
              lastp := p;
              Inc(p, Pos(nm, Copy(LowerCase(ts), p + 1, Length(ts) - p)));
              Continue;
            end;
          q := Length(nm) + p;
          if (Length(ts) >= q) and (ts[q] in gWordCharsadq - ['(', ')']) then
          begin
            if ts[q] = '.' then
            begin
              sdi := q + 1;
              sd := '';
              while (Length(ts) >= sdi) and (ts[sdi] in gWordCharsadq) do
              begin
                sd := sd + ts[sdi];
                Inc(sdi);
              end;
              sdi := TScanThread(T).ScriptStrToInt(sd);
              scr := sdi;
              hProc := gScriptso3[sdi].ProcessHandle;
              force := True;
              Delete(ts, q, Length(sd) + 1);
            end
            else
            begin
              lastp := p;
              Inc(p, Pos(nm, Copy(LowerCase(ts), p + 1, Length(ts) - p)));
              Continue;
            end;
          end
          else
            hProc := T.ProcessHandle2;
        except
        end;
        if hasq then
        begin
          quo := False;
          for q := p downto 1 do
            if ts[q] = '"' then
              quo := not quo;
        end;
        if not quo then
        begin
          { ОДНО ИМЯ, А НЕ ДВА: длина слова и позиция вставки делят один регистр.
            Отдельная длина заняла бы ещё один, и байтовому `bMatch` регистра
            не досталось бы вовсе. }
          pIns := Length(nm);
          w := Copy(ts, p, pIns);
          Delete(ts, p, pIns);
          pIns := p;
          idx := gCmdListah7.IndexOf(AnsiLowerCase(nm));
          case idx of
          -1:
            begin { имя не опознано }
      Insert(w, ts, pIns);
      Inc(p, Length(w));
            end;
          0..6, 13..15:
            begin { name,gold,wght }
      if (not fRead[0]) or force then begin
        a := gClT590A34bv[T.ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
        if gClT5909D0f9[T.ClVerIdx] = 1 then begin
          Inc(a, $8C);
          ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
          err := (rd <> 4) or err;
        end;
        case gClT5909D0f9[T.ClVerIdx] of
          5..7: begin
          if gClT5909D0f9[T.ClVerIdx] = 7 then
            Inc(a, 8);
          Inc(a, $C4);
          ReadProcessMemory(hProc, Pointer(a), @st1, $50, rd);
          err := (rd <> $50) or err;
          pb := PChar(@st1);
          nn07C := $20;
            end;
        else
          Inc(a, $A4);
          ReadProcessMemory(hProc, Pointer(a), @st2, $3C, rd);
          err := (rd <> $3C) or err;
          pb := PChar(@st2);
          nn07C := $25;
        end;
        sdi := 1;
        sd := '';
        while ((pb[sdi - 1] <> #0) or (pb[sdi] <> #0)) and (sdi < nn07C) do begin
          if (pb[0] <> #0) and (pb[sdi - 1] = #0) then
            Break;
          if pb[sdi - 1] <> #0 then
            sd := sd + pb[sdi - 1];
          Inc(sdi);
        end;
        nmv := sd;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[0] := True;
        case gClT5909D0f9[T.ClVerIdx] of
          5, 6:
            case idx of
            0: V := nmv;
            4: V := IntToStr(st1.Hits);
            5: V := IntToStr(st1.Mana);
            6: V := IntToStr(st1.Stam);
            13: V := IntToStr(st1.Strg);
            14: V := IntToStr(st1.Intl);
            15: V := IntToStr(st1.Dext);
            1: V := IntToStr(st1.Gold);
            2: begin
                 a := gClT59096Cakx[T.ClVerIdx];
                 ReadProcessMemory(hProc, Pointer(a), @wA, 4, rd);
                 V := IntToStr(wA);
               end;
            59: V := IntToStr(st1.PSys);
            60: V := IntToStr(st1.Fire);
            61: V := IntToStr(st1.Cold);
            62: V := IntToStr(st1.Pois);
            63: V := IntToStr(st1.Ener);
            64: V := IntToStr(st1.Luck);
            65: V := IntToStr(st1.Dmg);
            66: V := IntToStr(st1.HitsMax);
            67: V := IntToStr(st1.ManaMax);
            68: V := IntToStr(st1.StamMax);
            69: begin
                 a := gClT59096Cakx[T.ClVerIdx];
                 ReadProcessMemory(hProc, Pointer(a), @wA, 4, rd);
                 V := IntToStr(wB);
               end;
            70: V := IntToStr(st1.DmgMax);
            71: V := IntToStr(st1.Foll);
            72: V := IntToStr(st1.FollMax);
            end;
        else
          case idx of
            0: V := nmv;
            4: V := IntToStr(st2.Hits);
            5: V := IntToStr(st2.Mana);
            6: V := IntToStr(st2.Stam);
            13: V := IntToStr(st2.Strg);
            14: V := IntToStr(st2.Intl);
            15: V := IntToStr(st2.Dext);
            1: V := IntToStr(st2.Gold);
            2: V := IntToStr(st2.Wght);
            3: V := IntToStr(st2.Armor);
          end;
        end;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          7:
            begin { lastmsg }
      if not isop then begin
        if (not fRead[7]) or force then begin
          a := gClT590A98aq[TScanThread(T).ClVerIdx];
          ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
          err := rd <> 4;
          ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
          err := (rd <> 4) or err;
          kk214 := 0;
          ReadProcessMemory(hProc, Pointer(a + Cardinal(kk214)), @buf[kk214], 16, rd);
          err := (rd <> 16) or err;
          Inc(kk214, 16);
          while kk214 < $100 do begin
            ReadProcessMemory(hProc, Pointer(a + Cardinal(kk214)), @buf[kk214], 16, rd);
            Inc(kk214, 16);
          end;
          if not err then begin
            sdi := 0;
            sd := '';
            if buf[1] >= ' ' then begin
              while buf[sdi] <> #0 do begin
                sd := sd + buf[sdi];
                Inc(sdi);
              end;
            end else begin
              pw := @buf;
              sd := WideCharToString(pw);
            end;
          end else
            sd := 'error';
        end;
        fRead[7] := True;
        V := sd;
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          8, 9, 29, 31..33:
            begin { coordx,coordy,coordz }
      if (not fRead[8]) or force then begin
        a := gClT590AFCy[TScanThread(T).ClVerIdx] - 4;
        ReadProcessMemory(hProc, Pointer(a), @crd548, 12, rd);
        err := rd <> 12;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[8] := True;
        if TScanThread(T).ClVerIdx = 8 then begin
          case idx of
            8, 31: V := IntToStr(crd548[0]);
            9, 32: V := IntToStr(crd548[1]);
            29, 33: begin
              a := gClT590B60dt[TScanThread(T).ClVerIdx];
              ReadProcessMemory(hProc, Pointer(a), @crd548, 12, rd);
              V := IntToStr(crd548[0]);
            end;
          end;
        end else begin
          case idx of
            8, 31: V := IntToStr(crd548[2]);
            9, 32: V := IntToStr(crd548[1]);
            29, 33: V := IntToStr(crd548[0]);
          end;
        end;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          10..12:
            begin { min,hour,sec }
      if not fRead[10] then begin
        tt := TimeToStr(Time);
        sEe := Copy(tt, 1, Pos(':', tt) - 1);
        sB := Copy(tt, Pos(':', tt) + 1, 2);
        sA := Copy(tt, Pos(':', tt) + 4, 2);
      end;
      fRead[10] := True;
      case idx of
        $0A: V := sB;
        $0B: V := sEe;
        $0C: V := sA;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          53..55:
            begin { year,month,day }
      if not fRead[53] then begin
        tt := FormatDateTime('dd.mm.yyyy', Now);
        sB := Copy(tt, 1, 2);
        sEe := Copy(tt, 4, 2);
        sA := Copy(tt, 7, 4);
      end;
      fRead[53] := True;
      case idx of
        $37: V := sB;
        $36: V := sEe;
        $35: V := sA;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          16:
            begin { chardir }
      if (not fRead[16]) or force then begin
        a := gClT5911A0dq[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @bDir, 1, rd);
        err := rd <> 1;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[16] := True;
        V := IntToStr(bDir);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          17, 220..223:
            begin { timer,timer1,timer2 }
      if (not fRead[17]) or force then begin
        if TScanThread(T).ProcessHandle2 = hProc then begin
          case idx of
            17:  a := TScanThread(T).StartTick;
            220: a := TScanThread(T).Tick1;
            221: a := TScanThread(T).Tick2;
            222: a := TScanThread(T).Tick3;
            223: a := TScanThread(T).Tick4;
          end;
        end else begin
          case idx of
            17:  a := gScriptso3[scr].StartTick;
            220: a := gScriptso3[scr].Tick1;
            221: a := gScriptso3[scr].Tick2;
            222: a := gScriptso3[scr].Tick3;
            223: a := gScriptso3[scr].Tick4;
          end;
        end;
        if (TScanThread(T).PerfFreq > 0) and QueryPerformanceCounter(i1) then
          tv := IntToStr(Trunc(i1 / TScanThread(T).PerfFreq * 1000) - a)
        else
          tv := IntToStr(GetTickCount - a);
      end;
      fRead[17] := True;
      V := tv;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          18, 34:
            begin { lastobjectid,lastobject }
      if (not fRead[18]) or force then begin
        a := gClT591074cp[1, TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[18] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          19:
            begin { lastobjecttype }
      if (not fRead[19]) or force then begin
        a := gClT590D54e[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[19] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          20, 35:
            begin { lasttargetid,lasttarget }
      if (not fRead[20]) or force then begin
        a := gClT591074cp[2, TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[20] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          21..23:
            begin { lasttargetx,lasttargety,lasttargetz }
      if (not fRead[21]) or force then begin
        a := gClT590E80ep[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @crd, 6, rd);
        err := rd <> 6;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[21] := True;
        case idx of
          $15: V := IntToStr(crd[0]);
          $16: V := IntToStr(crd[1]);
          $17: V := IntToStr(crd[2]);
        end;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          24:
            begin { lasttargetkind }
      if (not fRead[24]) or force then begin
        a := gClT590E1C3[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[24] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          25:
            begin { lastliftedid }
      if (not fRead[25]) or force then begin
        a := gClT590CF0am[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[25] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          26:
            begin { lastskill }
      if (not fRead[26]) or force then begin
        a := gClT590C8Chr[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[26] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          27:
            begin { lastspell }
      if (not fRead[27]) or force then begin
        a := gClT590C28o3[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[27] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          28:
            begin { laststatictype }
      if (not fRead[28]) or force then begin
        a := gClT590DB8y6[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[28] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          30:
            begin { target }
      if (not fRead[30]) or force then begin
        a := gClT590B60dt[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[30] := True;
        V := IntToStr(Int64(Cardinal(a)));
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          36:
            begin { skills }
      qq := p;
      bFlag := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq) do
      begin
        if ts[qq] = '[' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        bFlag := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do
        begin
          case ts[a] of
            '[': begin Inc(rd); bFlag := True; end;
            ']': Dec(rd);
          end;
          if bFlag then
            if rd = 0 then
              Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        V := EvalScriptExpr(T, 'calc ' + V, -1);
        sB := ParseWaitSuffix(V, qq, sdi);
        bFlag := False;
        if qq <> 0 then
        begin
          while not (V[1] in gWordCharsadq) do
            Delete(sv, 1, 1);
          while not (V[Length(V)] in gWordCharsadq) do
            Delete(V, Length(V), 1);
          rd := 0;
          ebR1.pSk := @gSkillFlataq;
          repeat
            a := StrIComp(PChar(ebR1.pSk^[0]), PChar(V));
            if a = 0 then
            begin
              a := rd;
              bFlag := True;
              Break;
            end;
            a := StrIComp(PChar(ebR1.pSk^[1]), PChar(V));
            if a = 0 then
            begin
              a := rd;
              bFlag := True;
              Break;
            end;
            Inc(rd);
            Inc(PChar(ebR1.pSk), 8);
          until rd = $3B;
        end
        else
        begin
          a := StrToInt(sB);
          bFlag := True;
        end;
        if bFlag then
        begin
          if (gClT5909D0f9[TScanThread(T).ClVerIdx] in [4, 5]) and (a > 0) then
            a := gClT590EE4fq[TScanThread(T).ClVerIdx] + a * 2 + $38
          else
            a := gClT590EE4fq[TScanThread(T).ClVerIdx] + a * 2;
          ReadProcessMemory(hProc, Pointer(a), @wSk, 2, rd);
          err := rd <> 2;
        end
        else
          wSk := SmallInt($FFFF);
        if err then
          V := IntToStr(-1)
        else begin
          fRead[36] := True;
          V := IntToStr(wSk);
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;

            end;
          37:
            begin { war }
      if (not fRead[37]) or force then begin
        a := gClT590FACbx[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
        if gClT5909D0f9[TScanThread(T).ClVerIdx] = 7 then Inc(a, 4);
        nQ2 := a + $9C;
        Inc(a, $154);
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := err or (rd <> 4);
        ReadProcessMemory(hProc, Pointer(nQ2), @nQ2, 4, rd);
        err := err or (rd <> 4);
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[37] := True;
        if (nQ2 and $40) = $40 then a := 1;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          38:
            begin { hidden }
      if (not fRead[38]) or force then begin
        a := gClT590F48eh[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
        Inc(a, $9C);
        if gClT5909D0f9[TScanThread(T).ClVerIdx] = 7 then Inc(a, 4);
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := err or (rd <> 4);
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[38] := True;
        if (a and $80) = $80 then a := 1 else a := 0;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          39:
            begin { arun }
      if (not fRead[39]) or force then begin
        a := gClT591010ajm[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[39] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          40:
            begin { delimiter }
      V := TScanThread(T).Str1048B8;
      if isop then
        V := '"' + V + '"';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          41:
            begin { spellname }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq) do begin
        if ts[qq] = '[' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        aI := qq;
        while Cardinal(Length(ts)) >= Cardinal(aI) do begin
          case ts[aI] of
            '[': begin Inc(rd); ok := True; end;
            ']': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(aI);
        end;
        V := Copy(ts, qq + 1, aI - (qq + 1));
        Delete(ts, p, aI - p + 1);
        V := EvalScriptExpr(T, 'calc ' + V, -1);
        sB := ParseWaitSuffix(V, qq, sdi);
        if qq <> 0 then
          aI := 0
        else
          aI := StrToInt(sB);
        V := gItemNamesbq[aI - Integer(gClT590BC4y2[TScanThread(T).ClVerIdx])];
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;
            end;
          43:
            begin { findwindow }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if (LowerCase(EvalScriptPoint(T, sv, 0)) = 'set') and
         (LowerCase(EvalScriptPoint(T, sv, 1))[1] = '%') then
        isVar13F := True
      else
        isVar13F := False;
      if ok then begin
        ok := False;
        aI := qq;
        arg := '';
        while Cardinal(Length(ts)) >= Cardinal(aI) do begin
          case ts[aI] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(aI);
        end;
        V := Copy(ts, qq + 1, aI - (qq + 1));
        Delete(ts, p, aI - p + 1);
        V := EvalScriptExpr(T, 'calc ' + V, -1);
        EbFindWnd(T, V, isVar13F);
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;
            end;
          45:
            begin { random }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        aI := qq;
        while Cardinal(Length(ts)) >= Cardinal(aI) do begin
          case ts[aI] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(aI);
        end;
        V := Copy(ts, qq + 1, aI - (qq + 1));
        Delete(ts, p, aI - p + 1);
        V := EvalScriptExpr(T, 'calc ' + V, -1);
        while (Length(V) > 0) and not (V[1] in gWordCharsadq) do
          Delete(V, 1, 1);
        while not (V[Length(V)] in gWordCharsadq) do
          Delete(V, Length(V), 1);
        try
          V := IntToStr(Random(StrToInt(ParseWaitSuffix(V, qq, sdi))));
        except
          V := '-1';
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(nm, ts, p);
        Inc(p, Length(nm));
      end;
            end;
          46:
            begin { getwindow }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        if (not TryStrToInt(EvalScriptExpr(T, 'calc ' + V, 1), Integer(a))) or (a = 0) then
          a := GetForegroundWindow;
        V := EvalScriptExpr(T, 'calc ' + V, 2);
        if LowerCase(V) = 'owner' then
          a := GetParent(a)
        else if LowerCase(V) = 'child' then
          a := GetWindow(a, 5)
        else if LowerCase(V) = 'first' then
          a := GetWindow(a, 0)
        else if LowerCase(V) = 'next' then
          a := GetWindow(a, 2);
        V := IntToStr(Cardinal(a));
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;
            end;
          47:
            begin { getwindowtext }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        buf[0] := #0;
        try
          a := StrToInt(EvalScriptExpr(T, 'calc ' + V, -1));
        except
          a := 0;
        end;
        if not (Cardinal(a) > 0) then
          a := TScanThread(T).ClientWnd2;
        SendMessage(a, $D, $100, Integer(@buf));
        pc := @buf;
        V := pc;
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;
            end;
          58:
            begin { setwindowtext }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        a := StrToInt(EvalScriptExpr(T, 'calc ' + V, 1));
        V := EvalScriptExpr(T, 'calc ' + V, -2);
        a := Integer(SetWindowText(a, PChar(V)));
        if Cardinal(a) > 0 then
          a := 1;
        V := IntToStr(Cardinal(a));
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;
            end;
          57:
            begin { prompt }
      qq := p;
      bFlag := False;
      while (Length(ts) >= qq) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        bFlag := False;
        aI := qq;
        rd := 0;
        while Cardinal(Length(ts)) >= Cardinal(aI) do
        begin
          case ts[aI] of
            '(': begin Inc(rd); bFlag := True; end;
            ')': Dec(rd);
          end;
          if bFlag then
            if rd = 0 then
              Break;
          Inc(aI);
        end;
        V := Copy(ts, qq + 1, aI - (qq + 1));
        Delete(ts, p, aI - p + 1);
        bFlag := False;
        aI := 1;
        rd := 0;
        qq := 0;
        while Cardinal(Length(V)) >= Cardinal(aI) do
        begin
          case V[aI] of
            '(':
              begin
                Inc(rd);
                if bFlag = False then
                  qq := aI;
                bFlag := True;
              end;
            ')': Dec(rd);
          end;
          if bFlag then
            if rd = 0 then
              Break;
          Inc(aI);
        end;
        Inc(qq);
        arg := EvalScriptExpr(T, 'calc ' + Copy(V, qq, aI - qq), 1);
        Delete(V, qq - 1, aI - qq + 2);
        if not TryStrToInt(arg, TScanThread(T).PromptTime) then
          TScanThread(T).PromptTime := 0;
        if TScanThread(T).PromptKind = '' then
        begin
          if EvalScriptPoint(T, 'calc ' + V, 2) = '' then
            TScanThread(T).PromptKind := '$'
          else
            TScanThread(T).PromptKind := '#';
        end;
        if TScanThread(T).PromptKind[1] = '$' then
          V := EvalScriptExpr(T, 'calc ' + V, -1)
        else
        begin
          qq := 1;
          sAcc := '';
          arg := EvalScriptExpr(T, 'calc ' + V, qq);
          while TScanThread(T).WordPos <> 0 do
          begin
            if arg <> '' then
              sAcc := sAcc + #162 + arg + #161' ';
            Inc(qq);
            arg := EvalScriptExpr(T, 'calc ' + V, qq);
          end;
          V := sAcc;
        end;
        Move(V[1], TScanThread(T).LogBuf, Length(V));
        TScanThread(T).LogBuf[Length(V)] := #0;
        TScanThread(T).Synchronize(TScanThread(T).SyncCreateWindow);
        TScanThread(T).Suspend;
        if TScanThread(T).StopRequested then
        begin
          TScanThread(T).Synchronize(TScanThread(T).SyncFreeTimers);
          Result := '-1';
          Exit;
        end;
        Insert(TScanThread(T).Msg, ts, p);
        Inc(p, Length(V));
      end
      else
      begin
        if TScanThread(T).IsProc then
        begin
          TScanThread(T).Msg := '''prompt'' parameters not recognized'#0;
          TScanThread(T).Synchronize(TScanThread(T).SyncLogMsg);
        end;
      end;

            end;
          73:
            begin { linedelay }
      V := T.PauseCmd;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          74:
            begin { fontcolor }
      if (not fRead[74]) or force then begin
        a := gClT590908cx[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @wv, 2, rd);
        err := rd <> 2;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[74] := True;
        V := IntToStr(Word(wv));
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          75:
            begin { findcolor }
      nStart2 := p;
      qq := p;
      if FindOpenParen(ts, qq) then
      begin
        ptC.X := 0;
        ptC.Y := 0;
        V := 'calc ' + FindParenGroup(T, ts, qq, nn, mm);
        Delete(ts, p, mm - p + 1);
        try
          if TScanThread(T).HasArgs then
          begin
            if TScanThread(T).Args[1].Kind = 1 then
              ptA.X := TScanThread(T).Args[1].Val
            else
              ptA.X := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[1].Str, 1));
            if TScanThread(T).Args[2].Kind = 1 then
              ptA.Y := TScanThread(T).Args[2].Val
            else
              ptA.Y := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[2].Str, 1));
            if TScanThread(T).Args[3].Kind = 1 then
              ptB.X := TScanThread(T).Args[3].Val
            else
              ptB.X := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[3].Str, 1));
            if TScanThread(T).Args[4].Kind = 1 then
              ptB.Y := TScanThread(T).Args[4].Val
            else
              ptB.Y := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[4].Str, 1));
            if TScanThread(T).Args[0].Val = 7 then
            begin
              if TScanThread(T).Args[5].Kind = 1 then
                ptC104.X := TScanThread(T).Args[5].Val
              else
                ptC104.X := StrToInt(EvalScriptExpr(T, 'calc ' +
                                  TScanThread(T).Args[5].Str, 1));
              if TScanThread(T).Args[6].Kind = 1 then
                ptC104.Y := TScanThread(T).Args[6].Val
              else
                ptC104.Y := StrToInt(EvalScriptExpr(T, 'calc ' +
                                  TScanThread(T).Args[6].Str, 1));
              a := 7;
            end
            else
            begin
              ptC104.X := 1;
              ptC104.Y := 1;
              a := 5;
            end;
          end
          else
          begin
            ptA.X := StrToInt(EvalScriptExpr(T, V, 1));
            ptA.Y := StrToInt(EvalScriptExpr(T, V, 2));
            ptB.X := StrToInt(EvalScriptExpr(T, V, 3));
            ptB.Y := StrToInt(EvalScriptExpr(T, V, 4));
            bFlag := False;
            if not TryStrToInt(EvalScriptExpr(T, V, 5), ptC104.X) or
               not TryStrToInt(EvalScriptExpr(T, V, 6), ptC104.Y) then
            begin
              bFlag := True;
              ptC104.X := 1;
              ptC104.Y := 1;
            end;
            if bFlag then
              a := 5
            else
              a := 7;
          end;
          nm := EvalScriptExpr(T, V, 0 - a);
          rd := 0;
          if (Pos('(', nm) > 0) or TScanThread(T).HasArgs then
          begin
            bHas := True;
            if TScanThread(T).HasArgs then
            begin
              if TScanThread(T).Args[TScanThread(T).Args[0].Val].Kind = 1 then
                V := IntToStr(TScanThread(T).Args[5].Val)
              else
                V := EvalScriptExpr(T, 'calc ' + TScanThread(T).Args[5].Str, 1);
            end
            else
            begin
              bFlag := False;
              a := 1;
              while Cardinal(Length(nm)) >= a do
              begin
                case nm[a] of
                  '(': begin Inc(rd); bFlag := True; end;
                  ')': Dec(rd);
                end;
                if bFlag then
                  if rd = 0 then
                    Break;
                Inc(a);
              end;
              V := 'calc ' + EvalScriptExpr(T, 'calc ' +
                             Copy(nm, 2, a - 2), -1);
              nm := 'calc ' + Copy(nm, a + 1,
                                      Cardinal(Length(nm)) - a);
            end;
            qq := Pos('-', V);
            while qq > 0 do
            begin
              while qq > 1 do
              begin
                Dec(qq);
                case V[qq] of
                  #9, #32: Delete(V, qq, 1);
                else
                  begin
                    Inc(qq);
                    Break;
                  end;
                end;
              end;
              Inc(qq);
              while Length(V) > qq do
              begin
                case V[qq] of
                  #9, #32: Delete(V, qq, 1);
                else
                  Break;
                end;
              end;
              qq := PosEx('-', V, qq);
            end;
            ScriptIdle2;
            a := 0;
          end
          else
          begin
            bHas := False;
            nQ := StrToInt(EvalScriptExpr(T, V, a));
            nQ2 := nQ;
            nm := 'calc ' + nm;
            a := 1;
          end;
          if TScanThread(T).HasArgs then
          begin
            a := TScanThread(T).Args[0].Val - 1;
            V := '%luatemp';
            if TScanThread(T).Args[a + 2].Kind = 1 then
              sA := IntToStr(TScanThread(T).Args[a + 2].Val)
            else
              sA := EvalScriptExpr(T, 'calc ' +
                                   TScanThread(T).Args[a + 2].Str, 1);
            if TScanThread(T).Args[a + 3].Kind = 1 then
              sEe := IntToStr(TScanThread(T).Args[a + 3].Val)
            else
              sEe := EvalScriptExpr(T, 'calc ' +
                                   TScanThread(T).Args[a + 3].Str, 1);
            if TScanThread(T).Args[a + 4].Kind = 1 then
              sDd := IntToStr(TScanThread(T).Args[a + 4].Val)
            else
              sDd := EvalScriptExpr(T, 'calc ' +
                                   TScanThread(T).Args[a + 4].Str, 1);
            if TScanThread(T).Args[a + 5].Kind = 1 then
              sB := IntToStr(TScanThread(T).Args[a + 5].Val)
            else
              sB := EvalScriptExpr(T, 'calc ' +
                                   TScanThread(T).Args[a + 5].Str, 1);
          end
          else
          begin
            sA := AnsiLowerCase(EvalScriptExpr(T, nm, a + 2));
            sEe := AnsiLowerCase(EvalScriptExpr(T, nm, a + 3));
            sDd := AnsiLowerCase(EvalScriptExpr(T, nm, a + 4));
            sB := AnsiLowerCase(EvalScriptExpr(T, nm, a + 5));
            V := EvalScriptExpr(T, nm, a + 1);
          end;
          TScanThread(T).RxLen := V;
          if (sB = 'abs') or (sA = 'abs') or (sEe = 'abs') or (sDd = 'abs') then
            bAbs := True
          else
            bAbs := False;
          if not TryStrToInt(sEe, nTol) then
            nTol := -1;
          if TryStrToInt(sDd, nPct) then
            if nPct >= 0 then
            begin
              if nPct > 99 then
                nPct := 99;
              bTol := Trunc(nPct * 2.56) and $FF;
              if bHas then
                for qq := 0 to Length(arrCol) - 1 do
                begin
                  if arrCol[qq].Lo3 > bTol then
                    Dec(arrCol[qq].Lo3, bTol)
                  else
                    arrCol[qq].Lo3 := 0;
                  if arrCol[qq].Lo2 > bTol then
                    Dec(arrCol[qq].Lo2, bTol)
                  else
                    arrCol[qq].Lo2 := 0;
                  if arrCol[qq].Lo1 > bTol then
                    Dec(arrCol[qq].Lo1, bTol)
                  else
                    arrCol[qq].Lo1 := 0;
                  if arrCol[qq].Hi3 + bTol < $FF then
                    Inc(arrCol[qq].Hi3, bTol)
                  else
                    arrCol[qq].Hi3 := $FF;
                  if arrCol[qq].Hi2 + bTol < $FF then
                    Inc(arrCol[qq].Hi2, bTol)
                  else
                    arrCol[qq].Hi2 := $FF;
                  if arrCol[qq].Hi1 + bTol < $FF then
                    Inc(arrCol[qq].Hi1, bTol)
                  else
                    arrCol[qq].Hi1 := $FF;
                end;
            end;
          if not TryStrToInt(sA, PInteger(@TScanThread(T).CapWnd)^) then
            TScanThread(T).CapWnd := 2;
          if Integer(TScanThread(T).CapWnd) > 0 then
          begin
            nShots := TScanThread(T).CapWnd;
            ptD.X := ptA.X;
            ptD.Y := ptA.Y;
            ptE.X := ptB.X;
            ptE.Y := ptB.Y;
            if not bAbs then
              if Integer(TScanThread(T).CapWnd) <= 2 then
              begin
                ClientToScreen(TScanThread(T).ClientWnd, ptA);
                ClientToScreen(TScanThread(T).ClientWnd, ptB);
              end;
            cK := V[1];
            Delete(V, 1, 1);
            nm := V;
            a := 0;
            rd := 0;
            GetArraySize(T, V, Cardinal(a), Cardinal(rd), True);
            nLim := $64;
            TScanThread(T).ParenPos := 0;
            p := FindScriptVar(T, cK, nm, $64, 3);
            a := 1;
            Inc(ptB.X);
            Inc(ptB.Y);
            if TScanThread(T).CapWnd <> 1 then
            begin
              if Integer(TScanThread(T).CapWnd) > 2 then
                bMulti := True
              else
                bMulti := False;
              TScanThread(T).Lock.Flag := False;
              if bMulti then
              begin
                qq := 0;
                while qq <= Length(TScanThread(T).Blocks) - 1 do
                begin
                  if TScanThread(T).Blocks[qq].Handle =
                     Integer(TScanThread(T).CapWnd) then
                  begin
                    ptC.X := TScanThread(T).Blocks[qq].W;
                    ptC.Y := TScanThread(T).Blocks[qq].H;
                    TScanThread(T).ShotW := TScanThread(T).Blocks[qq].Bits;
                    TScanThread(T).ShotH := TScanThread(T).Blocks[qq].Stride;
                    if TScanThread(T).ShotW < ptB.X then
                      ptB.X := TScanThread(T).ShotW;
                    if TScanThread(T).ShotH < ptB.Y then
                      ptB.Y := TScanThread(T).ShotH;
                    ptE.X := ptB.X - 1;
                    ptE.Y := ptB.Y - 1;
                    TScanThread(T).BottomUp := TScanThread(T).Blocks[qq].Extra > 0;
                    TScanThread(T).ShotSize :=
                      Abs(TScanThread(T).Blocks[qq].Stride *
                          TScanThread(T).Blocks[qq].Extra);
                    TScanThread(T).ShotBits :=
                      Pointer(TScanThread(T).Blocks[qq].Handle);
                    TScanThread(T).Lock.Flag := True;
                    TScanThread(T).Fld44C8 := nGap;
                    TScanThread(T).ShotFailed := False;
                    Break;
                  end;
                  Inc(qq);
                end;
              end;
              if not TScanThread(T).Lock.Flag then
              begin
                TScanThread(T).CapTo := ptB;
                TScanThread(T).CapFrom := ptA;
                try
                  TScanThread(T).ShotFailed := False;
                  TScanThread(T).CaptureWindowBits;
                except
                  TScanThread(T).ShotCount := 0;
                  TScanThread(T).ShotFailed := True;
                end;
                if TScanThread(T).ShotFailed then
                  V := '-6';
              end;
              a := 1;
              nPad := TScanThread(T).ShotW mod 4;
              if TScanThread(T).ShotFailed and TScanThread(T).IsProc then
              begin
                if TScanThread(T).IsProc then
                begin
                  TScanThread(T).Msg := 'error retrieving pictures';
                  TScanThread(T).Synchronize(T.SyncLogMsg);
                end;
              end
              else
              begin
                Dec(ptB.X, ptA.X);
                Dec(ptB.Y, ptA.Y);
                if TScanThread(T).Lock.Flag then
                  nn := 0
                else
                  nn := ptB.Y - 1;
                while ((nn >= 0) and (nn < ptB.Y)) and (nTol <> 0) do
                begin
                  if TScanThread(T).StopRequested then
                  begin
                    if not TScanThread(T).Lock.Flag then
                    begin
                      GlobalFree(THandle(TScanThread(T).ShotBits));
                      TScanThread(T).ShotBits := nil;
                    end;
                    SetLength(arrCol, 0);
                    Exit;
                  end;
                  qq := 0;
                  while (qq < ptB.X) and (nTol <> 0) do
                  begin
                    if a > Cardinal(nLim) then
                    begin
                      Inc(nLim, $64);
                      TScanThread(T).ParenPos := 0;
                      rd := 3;
                      nSave := a;
                      a := nLim;
                      nm := V;
                      p := FindScriptVar(T, cK, nm, a, rd);
                      a := nSave;
                    end;
                    nIdx3 := qq * 3;
                    if TScanThread(T).Lock.Flag then
                      nPix := Integer(TScanThread(T).ShotBits) +
                              (TScanThread(T).ShotW * 3 + nPad) * nn + nIdx3
                    else
                      nPix := (TScanThread(T).ShotH - 1 - nn) *
                              (TScanThread(T).ShotW * 3 + nPad) +
                              Integer(TScanThread(T).ShotBits) + nIdx3;
                    with PRGBTriple(nPix)^ do
                      q := rgbtRed + rgbtGreen shl 8 + rgbtBlue shl 16;
                    bMatch := False;
                    if bHas then
                    begin
                      nB_33FB := Length(arrCol) - 1;
                      lastp := 0;
                      while (lastp <= nB_33FB) and not bMatch do
                      begin
                        bMatch := (arrCol[lastp].Lo1 <= q and $FF) and
                                  (arrCol[lastp].Hi1 >= q and $FF) and
                                  (arrCol[lastp].Lo2 <= (q and $FF00) shr 8) and
                                  (arrCol[lastp].Hi2 >= (q and $FF00) shr 8) and
                                  (arrCol[lastp].Lo3 <= (q and $FF0000) shr 16) and
                                  (arrCol[lastp].Hi3 >= (q and $FF0000) shr 16);
                        Inc(lastp);
                      end;
                    end
                    else
                      bMatch := q = nQ;
                    if bMatch then
                    begin
                      if bMulti then
                      begin
                        GetWindowRect(nShots, rcW);
                        if not bAbs then
                          ScreenToClient(nShots, PPoint(@rcW)^);
                        if not TScanThread(T).Lock.Flag then
                        begin
                          if TScanThread(T).BottomUp then
                            nRow := ptE.Y - nn
                          else
                            nRow := nn;
                        end
                        else
                        begin
                          if TScanThread(T).BottomUp then
                            nRow := nn
                          else
                            nRow := ptE.Y - nn;
                        end;
                        nCol := qq + rcW.Left;
                        Inc(nRow, rcW.Top);
                        rd := 1;
                        nm := IntToStr(qq + ptD.X + rcW.Left +
                                          TScanThread(T).Cnt10467C);
                        StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                       TScanThread(T).ParenPos, nm, a, rd);
                        rd := 2;
                        nm := IntToStr(TScanThread(T).Cnt104680 + nRow);
                        StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                       TScanThread(T).ParenPos, nm, a, rd);
                        rd := 3;
                        nm := IntToStr(q);
                        StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                       TScanThread(T).ParenPos, nm, a, rd);
                      end
                      else
                      begin
                        rd := 1;
                        nm := IntToStr(qq + ptD.X + TScanThread(T).Cnt10467C);
                        StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                       TScanThread(T).ParenPos, nm, a, rd);
                        rd := 2;
                        if TScanThread(T).BottomUp then
                          nm := IntToStr(ptE.Y - nn +
                                            TScanThread(T).Cnt104680)
                        else
                          nm := IntToStr(TScanThread(T).Cnt104680 + nn);
                        StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                       TScanThread(T).ParenPos, nm, a, rd);
                        rd := 3;
                        nm := IntToStr(q);
                        StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                       TScanThread(T).ParenPos, nm, a, rd);
                      end;
                      Inc(a);
                      Dec(nTol);
                    end;
                    Inc(qq, ptC104.X);
                  end;
                  if TScanThread(T).Lock.Flag then
                    Inc(nn, ptC104.Y)
                  else
                    Dec(nn, ptC104.Y);
                end;
                SetLength(arrCol, 0);
              end;
              if not TScanThread(T).Lock.Flag then
              begin
                GlobalFree(THandle(TScanThread(T).ShotBits));
                TScanThread(T).ShotBits := nil;
              end;
            end
            else
            begin
              dcS := GetDC(0);
              nn := ptA.Y;
              while (nn <= ptB.Y - 1) and (nTol <> 0) do
              begin
                if TScanThread(T).StopRequested then
                begin
                  ReleaseDC(0, dcS);
                  Exit;
                end;
                qq := ptA.X;
                while (qq <= ptB.X - 1) and (nTol <> 0) do
                begin
                  if a > Cardinal(nLim) then
                  begin
                    Inc(nLim, $64);
                    TScanThread(T).ParenPos := 0;
                    rd := 2;
                    nSave := a;
                    a := nLim;
                    nm := V;
                    p := FindScriptVar(T, cK, nm, a, rd);
                    a := nSave;
                  end;
                  q := GetPixel(dcS, qq, nn);
                  bMatch := False;
                  if bHas then
                  begin
                    lastp := 0;
                    while (Length(arrCol) - 1 >= lastp) and not bMatch do
                    begin
                      if (arrCol[lastp].Lo1 <= q and $FF) and
                         (arrCol[lastp].Hi1 >= q and $FF) and
                         (arrCol[lastp].Lo2 <= (q and $FF00) shr 8) and
                         (arrCol[lastp].Hi2 >= (q and $FF00) shr 8) and
                         (arrCol[lastp].Lo3 <= (q and $FF0000) shr 16) and
                         (arrCol[lastp].Hi3 >= (q and $FF0000) shr 16) then
                        bMatch := True;
                      Inc(lastp);
                    end;
                  end
                  else
                    if q = nQ2 then
                      bMatch := True;
                  if bMatch then
                  begin
                    ptF.X := qq;
                    ptF.Y := nn;
                    if not bAbs then
                      ScreenToClient(TScanThread(T).ClientWnd, ptF);
                    rd := 1;
                    nm := IntToStr(TScanThread(T).Cnt10467C + ptF.X);
                    StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                   TScanThread(T).ParenPos, nm, a, rd);
                    rd := 2;
                    nm := IntToStr(TScanThread(T).Cnt104680 + ptF.Y);
                    StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                   TScanThread(T).ParenPos, nm, a, rd);
                    rd := 3;
                    nm := IntToStr(q);
                    StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                   TScanThread(T).ParenPos, nm, a, rd);
                    Inc(a);
                    Dec(nTol);
                  end;
                  Inc(qq, ptC104.X);
                end;
                Inc(nn, ptC104.Y);
              end;
              ReleaseDC(0, dcS);
            end;
            rd := 3;
            Dec(a);
            GetArraySize(T, V, Cardinal(a), Cardinal(rd), True);
            V := IntToStr(a);
          end
          else
            V := '-4';
        except
          V := '-1';
          a := 0;
          rd := 0;
          GetArraySize(T, V, Cardinal(a), Cardinal(rd), True);
        end;
      end
      else
        V := '-2';
      Insert(V, ts, p);
      Inc(p, Length(V));
      SetLength(arrCol, 0);

            end;
          89:
            begin { findimage }
      qq := p;
      bFlag := False;
      nStart2 := p;
      nLen3 := Length(ts);
      while (qq <= nLen3) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
      bFlag := False;
      a := qq;
      nLen3 := Length(ts);
      rd := 0;
      while a <= Cardinal(nLen3) do
      begin
        case ts[a] of
          '(': begin Inc(rd); bFlag := True; end;
          ')': Dec(rd);
        end;
        if bFlag then
          if rd = 0 then
            Break;
        Inc(a);
      end;
      V := 'calc ' + Copy(ts, qq + 1, Integer(a) - (qq + 1));
      Delete(ts, p, Integer(a) - p + 1);
      try
        a := 5;
        rd := 0;
        nQ := Pos('(', V);
        if (nQ > 0) or TScanThread(T).HasArgs then
        begin
          if TScanThread(T).HasArgs then
          begin
            if TScanThread(T).Args[1].Kind = 1 then
              ptA.X := TScanThread(T).Args[1].Val
            else
              ptA.X := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[1].Str, 1));
            if TScanThread(T).Args[2].Kind = 1 then
              ptA.Y := TScanThread(T).Args[2].Val
            else
              ptA.Y := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[2].Str, 1));
            if TScanThread(T).Args[3].Kind = 1 then
              ptB.X := TScanThread(T).Args[3].Val
            else
              ptB.X := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[3].Str, 1));
            if TScanThread(T).Args[4].Kind = 1 then
              ptB.Y := TScanThread(T).Args[4].Val
            else
              ptB.Y := StrToInt(EvalScriptExpr(T, 'calc ' +
                                TScanThread(T).Args[4].Str, 1));
          end
          else
          begin
            nm := EvalScriptExpr(T, 'calc ' +
                       Copy(V, nQ, Length(V) - nQ + 1 + 1), -1);
            V := 'calc ' + EvalScriptExpr(T, Copy(V, 1, nQ - 1), -1);
            ptA.X := StrToInt(EvalScriptExpr(T, V, 1));
            ptA.Y := StrToInt(EvalScriptExpr(T, V, 2));
            ptB.X := StrToInt(EvalScriptExpr(T, V, 3));
            ptB.Y := StrToInt(EvalScriptExpr(T, V, 4));
          bFlag := False;
          a := 1;
          rd := 0;
          nLen3 := Length(nm);
          while a <= Cardinal(nLen3) do
          begin
            case nm[a] of
              '(': begin Inc(rd); bFlag := True; end;
              ')': Dec(rd);
            end;
            if bFlag then
              if rd = 0 then
                Break;
            Inc(a);
          end;
          end;
          if TScanThread(T).HasArgs then
          begin
            if TScanThread(T).Args[5].Kind = 1 then
              V := IntToStr(TScanThread(T).Args[5].Val)
            else
              V := EvalScriptExpr(T, 'calc ' +
                                  TScanThread(T).Args[5].Str, 1);
          end
          else
          begin
            V := EvalScriptExpr(T, 'calc ' + Copy(nm, 2, a - 2), -1);
            nm := 'calc ' + Copy(nm, a + 1,
                                    Length(nm) - Integer(a));
          end;
          if (Pos('.', V) = 0) and TryStrToInt(V, nn) then
            begin
              TScanThread(T).CapWnd := 2;
              qq := 1;
              while Length(TScanThread(T).Blocks) >= qq do
              begin
                if TScanThread(T).Blocks[qq - 1].Handle = nn then
                  Break;
                Inc(qq);
              end;
              if Length(TScanThread(T).Blocks) >= qq then
              begin
                Dec(qq);
                TScanThread(T).Fld44A0 := TScanThread(T).Blocks[qq].Extra;
                TScanThread(T).CapW := TScanThread(T).Blocks[qq].Bits;
                TScanThread(T).CapH := TScanThread(T).Blocks[qq].Stride;
                TScanThread(T).ShotBits :=
                  Pointer(TScanThread(T).Blocks[qq].Handle);
              end
              else
              begin
                TScanThread(T).Fld44A0 := 0;
                TScanThread(T).CapW := 0;
                TScanThread(T).CapH := 0;
                TScanThread(T).ShotBits := nil;
              end;
            end
            else
            begin
              if Copy(V, 1, 2) <> '\\' then
                if Copy(V, 2, 1) <> ':' then
                  V := gTempFilefv + V;
              TScanThread(T).CapWnd := 0;
            end;
          try
            TScanThread(T).ShotFailed := False;
            TScanThread(T).ImgFile := V;
            LoadImageFile(TScanThread(T));
            nn := TScanThread(T).CapWnd;
          except
            nn := 0;
            TScanThread(T).ShotFailed := True;
            V := '-5';
          end;
          if nn < 0 then
          begin
            TScanThread(T).ShotFailed := True;
            V := '-4';
          end;
          if nn = 0 then
          begin
            TScanThread(T).ShotFailed := True;
            V := '-7';
          end;
          if nn > 0 then
          begin
            SetLength(TScanThread(T).ImgPts, 0);
            SetLength(TScanThread(T).ImgTol, 0);
            nGap := nn;
            nJ2 := TScanThread(T).ImgList[0][0];
            nGy := TScanThread(T).ImgList[0][1];
            for qq := 1 to Length(TScanThread(T).ImgList) - 1 do
            begin
              Dec(TScanThread(T).ImgList[qq][0], nJ2);
              Dec(TScanThread(T).ImgList[qq][1], nGy);
            end;
            qq := 0;
            if TScanThread(T).HasArgs then
            begin
              a := 4;
              V := '%luatemp';
              if TScanThread(T).Args[a + 2].Kind = 1 then
                sA := IntToStr(TScanThread(T).Args[a + 2].Val)
              else
                sA := EvalScriptExpr(T, 'calc ' +
                                     TScanThread(T).Args[a + 2].Str, 1);
              if TScanThread(T).Args[a + 3].Kind = 1 then
                sB := IntToStr(TScanThread(T).Args[a + 3].Val)
              else
                sB := EvalScriptExpr(T, 'calc ' +
                                     TScanThread(T).Args[a + 3].Str, 1);
              if TScanThread(T).Args[a + 4].Kind = 1 then
                sCc := IntToStr(TScanThread(T).Args[a + 4].Val)
              else
                sCc := EvalScriptExpr(T, 'calc ' +
                                      TScanThread(T).Args[a + 4].Str, 1);
              if TScanThread(T).Args[a + 5].Kind = 1 then
                sDd := IntToStr(TScanThread(T).Args[a + 5].Val)
              else
                sDd := EvalScriptExpr(T, 'calc ' +
                                      TScanThread(T).Args[a + 5].Str, 1);
              if TScanThread(T).Args[a + 6].Kind = 1 then
                sEe := IntToStr(TScanThread(T).Args[a + 6].Val)
              else
                sEe := EvalScriptExpr(T, 'calc ' +
                                      TScanThread(T).Args[a + 6].Str, 1);
            end
            else
            begin
              a := 0;
              V := EvalScriptExpr(T, nm, a + 1);
              sA := AnsiLowerCase(EvalScriptExpr(T, nm, a + 2));
              sB := AnsiLowerCase(EvalScriptExpr(T, nm, a + 3));
              sCc := AnsiLowerCase(EvalScriptExpr(T, nm, a + 4));
              sDd := AnsiLowerCase(EvalScriptExpr(T, nm, a + 5));
              sEe := AnsiLowerCase(EvalScriptExpr(T, nm, a + 6));
            end;
            TScanThread(T).RxLen := V;
            if (sB = 'abs') or (sA = 'abs') or (sCc = 'abs') or
               (sDd = 'abs') or (sEe = 'abs') then
              bAbs := True
            else
              bAbs := False;
            if not TryStrToInt(sDd, nPct) or (nPct < 0) then
            begin
              bTol := 0;
              bHas := False;
            end
            else
            begin
              bTol := Trunc(nPct * 2.56) and $FF;
              bHas := True;
            end;
            if not TryStrToInt(sB, nPct) then
              nPct := $50;
            if not TryStrToInt(sCc, nTol) then
              nTol := 1;
            if not TryStrToInt(sA, PInteger(@TScanThread(T).CapWnd)^) or
               (Integer(TScanThread(T).CapWnd) < 1) then
              TScanThread(T).CapWnd := 2;
            nShots := TScanThread(T).CapWnd;
            dcS := GetDC(0);
            ptD.X := ptA.X;
            ptD.Y := ptA.Y;
            ptE.X := ptB.X;
            ptE.Y := ptB.Y;
            if not bAbs then
              if Integer(TScanThread(T).CapWnd) <= 2 then
              begin
                ClientToScreen(TScanThread(T).ClientWnd, ptA);
                ClientToScreen(TScanThread(T).ClientWnd, ptB);
              end;
            Inc(ptB.X);
            Inc(ptB.Y);
          cK := V[1];
          Delete(V, 1, 1);
          nm := V;
          a := 0;
          rd := 0;
          GetArraySize(T, V, Cardinal(a), Cardinal(rd), True);
          a := $64;
          TScanThread(T).ParenPos := 0;
          rd := 5;
          nLim := a;
          p := FindScriptVar(T, cK, nm, a, rd);
          a := 1;
          if TScanThread(T).CapWnd <> 1 then
          begin
            if Integer(TScanThread(T).CapWnd) > 2 then
              bMulti := True
            else
              bMulti := False;
            TScanThread(T).Lock.Flag := False;
            if bMulti then
            begin
              qq := 0;
              while qq <= Length(TScanThread(T).Blocks) - 1 do
              begin
                if TScanThread(T).Blocks[qq].Handle =
                   Integer(TScanThread(T).CapWnd) then
                begin
                  ptC.X := TScanThread(T).Blocks[qq].W;
                  ptC.Y := TScanThread(T).Blocks[qq].H;
                  TScanThread(T).ShotW := TScanThread(T).Blocks[qq].Bits;
                  TScanThread(T).ShotH := TScanThread(T).Blocks[qq].Stride;
                  if TScanThread(T).ShotW < ptB.X then
                    ptB.X := TScanThread(T).ShotW;
                  if TScanThread(T).ShotH < ptB.Y then
                    ptB.Y := TScanThread(T).ShotH;
                  ptE.X := ptB.X - 1;
                  ptE.Y := ptB.Y - 1;
                  TScanThread(T).BottomUp := TScanThread(T).Blocks[qq].Extra > 0;
                  TScanThread(T).ShotSize :=
                    Abs(TScanThread(T).Blocks[qq].Stride *
                        TScanThread(T).Blocks[qq].Extra);
                  TScanThread(T).ShotBits :=
                    Pointer(TScanThread(T).Blocks[qq].Handle);
                  TScanThread(T).Lock.Flag := True;
                  TScanThread(T).Fld44C8 := nGap;
                  TScanThread(T).ShotFailed := False;
                  Break;
                end;
                Inc(qq);
              end;
            end;
          if not TScanThread(T).Lock.Flag then
          begin
            TScanThread(T).CapTo := ptB;
            TScanThread(T).CapFrom := ptA;
            TScanThread(T).Fld44C8 := nGap;
            try
              TScanThread(T).ShotFailed := False;
              TScanThread(T).CaptureWindowBits;
            except
              TScanThread(T).ShotCount := 0;
              TScanThread(T).ShotFailed := True;
            end;
            if TScanThread(T).ShotFailed then
              V := '-6';
          end;
          a := 1;
          nPad := TScanThread(T).ShotW mod 4;
          if TScanThread(T).ShotFailed then
          begin
            if TScanThread(T).IsProc then
            begin
              TScanThread(T).Msg := 'error retrieving pictures';
              TScanThread(T).Synchronize(T.SyncLogMsg);
            end;
          end
          else
          begin
            SetLength(arrCol, 1);
            Dec(ptB.X, ptA.X);
            Dec(ptB.Y, ptA.Y);
            if TScanThread(T).Lock.Flag then
              nn := 0
            else
              nn := ptB.Y - 1;
            while ((nn >= 0) and (nn < ptB.Y)) and (nTol <> 0) do
            begin
              if TScanThread(T).StopRequested then
              begin
                if not TScanThread(T).Lock.Flag then
                begin
                  GlobalFree(THandle(TScanThread(T).ShotBits));
                  TScanThread(T).ShotBits := nil;
                end;
                ReleaseDC(0, dcS);
                SetLength(arrCol, 0);
                Exit;
              end;
              qq := 0;
              while (qq < ptB.X) and (nTol <> 0) do
              begin
                if a > Cardinal(nLim) then
                begin
                  Inc(nLim, $64);
                  TScanThread(T).ParenPos := 0;
                  rd := 4;
                  nSave := a;
                  a := nLim;
                  nm := V;
                  p := FindScriptVar(T, cK, nm, a, rd);
                  a := nSave;
                end;
                bMatch := False;
                nIdx3 := qq * 3;
                if TScanThread(T).Lock.Flag then
                  nPix := Integer(TScanThread(T).ShotBits) +
                          (TScanThread(T).ShotW * 3 + nPad) * nn + nIdx3
                else
                  nPix := (TScanThread(T).ShotH - 1 - nn) *
                          (TScanThread(T).ShotW * 3 + nPad) +
                          Integer(TScanThread(T).ShotBits) + nIdx3;
                with PRGBTriple(nPix)^ do
                begin
                  q := rgbtRed + rgbtGreen shl 8 + rgbtBlue shl 16;
                  if bHas then
                  begin
                    nR1 := TScanThread(T).ImgList[0][2] and $FF;
                    nG1 := (TScanThread(T).ImgList[0][2] and $FF00) shr 8;
                    nB1 := (TScanThread(T).ImgList[0][2] and $FF0000) shr 16;
                    if rgbtRed - bTol > 0 then
                      arrCol[0].Lo1 := rgbtRed - bTol
                    else
                      arrCol[0].Lo1 := 0;
                    if rgbtRed + bTol < $FF then
                      arrCol[0].Hi1 := rgbtRed + bTol
                    else
                      arrCol[0].Hi1 := $FF;
                    if rgbtGreen - bTol > 0 then
                      arrCol[0].Lo2 := rgbtGreen - bTol
                    else
                      arrCol[0].Lo2 := 0;
                    if rgbtGreen + bTol < $FF then
                      arrCol[0].Hi2 := rgbtGreen + bTol
                    else
                      arrCol[0].Hi2 := $FF;
                    if rgbtBlue - bTol > 0 then
                      arrCol[0].Lo3 := rgbtBlue - bTol
                    else
                      arrCol[0].Lo3 := 0;
                    if rgbtBlue + bTol < $FF then
                      arrCol[0].Hi3 := rgbtBlue + bTol
                    else
                      arrCol[0].Hi3 := $FF;
                    bHit := (arrCol[0].Lo1 <= nR1) and (arrCol[0].Hi1 >= nR1) and
                            (arrCol[0].Lo2 <= nG1) and (arrCol[0].Hi2 >= nG1) and
                            (arrCol[0].Lo3 <= nB1) and (arrCol[0].Hi3 >= nB1);
                  end
                  else
                    bHit := TScanThread(T).ImgList[0][2] = q;
                end;
                if bHit then
                begin
                  nHits := 1;
                  for nJ2 := 1 to Length(TScanThread(T).ImgList) - 1 do
                  begin
                    if TScanThread(T).Lock.Flag then
                    begin
                      nIdx3 := TScanThread(T).ImgList[nJ2][0] + qq;
                      if nIdx3 < ptA.X then
                        Continue;
                      if nIdx3 > ptB.X then
                        Continue;
                      nIdx3 := TScanThread(T).ImgList[nJ2][1] + nn;
                      if nIdx3 < ptA.Y then
                        Continue;
                      if nIdx3 > ptB.Y then
                        Continue;
                    end;
                    nIdx3 := (TScanThread(T).ImgList[nJ2][0] + qq) * 3;
                    if TScanThread(T).Lock.Flag then
                      nPix := (TScanThread(T).ImgList[nJ2][1] + nn) *
                              (TScanThread(T).ShotW * 3 + nPad) + nIdx3
                    else
                      nPix := (TScanThread(T).ShotH - 1 -
                               (nn - TScanThread(T).ImgList[nJ2][1])) *
                              (TScanThread(T).ShotW * 3 + nPad) + nIdx3;
                    if (nPix < 0) or
                       (nPix > Cardinal(TScanThread(T).ShotSize)) then
                    begin
                      nPix := 0;
                      Continue;
                    end;
                    Inc(nPix, Integer(TScanThread(T).ShotBits));
                    with PRGBTriple(nPix)^ do
                    begin
                      try
                        nGy := rgbtBlue shl 16 + rgbtGreen shl 8 + rgbtRed;
                      except
                        nGy := 1;
                        TScanThread(T).StopRequested := True;
                        if not TScanThread(T).Lock.Flag then
                        begin
                          GlobalFree(THandle(TScanThread(T).ShotBits));
                          TScanThread(T).ShotBits := nil;
                        end;
                        ReleaseDC(0, dcS);
                        SetLength(arrCol, nJ2 + nIdx3);
                        SetLength(arrCol, 0);
                        Exit;
                      end;
                      if bHas then
                      begin
                        nR1 := TScanThread(T).ImgList[nJ2][2] and $FF;
                        nG1 := (TScanThread(T).ImgList[nJ2][2] and $FF00) shr 8;
                        nB1 := (TScanThread(T).ImgList[nJ2][2] and $FF0000) shr 16;
                        if rgbtRed - bTol > 0 then
                          arrCol[0].Lo1 := rgbtRed - bTol
                        else
                          arrCol[0].Lo1 := 0;
                        if rgbtRed + bTol < $FF then
                          arrCol[0].Hi1 := rgbtRed + bTol
                        else
                          arrCol[0].Hi1 := $FF;
                        if rgbtGreen - bTol > 0 then
                          arrCol[0].Lo2 := rgbtGreen - bTol
                        else
                          arrCol[0].Lo2 := 0;
                        if rgbtGreen + bTol < $FF then
                          arrCol[0].Hi2 := rgbtGreen + bTol
                        else
                          arrCol[0].Hi2 := $FF;
                        if rgbtBlue - bTol > 0 then
                          arrCol[0].Lo3 := rgbtBlue - bTol
                        else
                          arrCol[0].Lo3 := 0;
                        if rgbtBlue + bTol < $FF then
                          arrCol[0].Hi3 := rgbtBlue + bTol
                        else
                          arrCol[0].Hi3 := $FF;
                        bHit := (arrCol[0].Lo1 <= nR1) and (arrCol[0].Hi1 >= nR1) and
                                (arrCol[0].Lo2 <= nG1) and (arrCol[0].Hi2 >= nG1) and
                                (arrCol[0].Lo3 <= nB1) and (arrCol[0].Hi3 >= nB1);
                      end
                      else
                        bHit := TScanThread(T).ImgList[nJ2][2] = nGy;
                    end;
                    if bHit then
                      Inc(nHits);
                  end;
                  if nHits * $64 div TScanThread(T).Fld44C8 >= nPct then
                  begin
                    bMatch := True;
                    TScanThread(T).CapWnd := nHits;
                  end;
                end;
                if bMatch then
                begin
                  if bMulti then
                  begin
                    GetWindowRect(nShots, rcW);
                    if not bAbs then
                      ScreenToClient(nShots, PPoint(@rcW)^);
                    if not TScanThread(T).Lock.Flag then
                    begin
                      if TScanThread(T).BottomUp then
                        nRow := ptE.Y - nn
                      else
                        nRow := nn;
                      nCol := qq + ptD.X - TScanThread(T).ImgList[0][0] +
                              rcW.Left;
                      nRow := nRow - TScanThread(T).ImgList[0][1] + rcW.Top;
                    end
                    else
                    begin
                      if TScanThread(T).BottomUp then
                        nRow := nn
                      else
                        nRow := ptE.Y - nn;
                      nCol := qq - TScanThread(T).ImgList[0][0] + rcW.Left + ptC.X;
                      nRow := nRow - TScanThread(T).ImgList[0][1] +
                              rcW.Top + ptC.Y;
                    end;
                    if (nCol >= ptD.X) and (nRow >= ptD.Y) then
                    begin
                      rd := 1;
                      nm := IntToStr(TScanThread(T).Cnt10467C + nCol);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 2;
                      nm := IntToStr(TScanThread(T).Cnt104680 + nRow);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 3;
                      nm := IntToStr(TScanThread(T).Cnt10467C + nCol +
                                        TScanThread(T).CapW - 1);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 4;
                      nm := IntToStr(TScanThread(T).Cnt104680 + nRow +
                                        TScanThread(T).CapH - 1);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 5;
                      nm := IntToStr(nHits * $64 div
                                        TScanThread(T).Fld44C8);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      Inc(a);
                      Dec(nTol);
                    end;
                  end
                  else
                  begin
                    nCol := qq + ptD.X - TScanThread(T).ImgList[0][0];
                    if TScanThread(T).BottomUp then
                      nRow := ptE.Y - nn - TScanThread(T).ImgList[0][1]
                    else
                      nRow := nn - TScanThread(T).ImgList[0][1];
                    if (nCol >= ptD.X) and (nRow >= ptD.Y) then
                    begin
                      rd := 1;
                      nm := IntToStr(TScanThread(T).Cnt10467C + nCol);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 2;
                      nm := IntToStr(TScanThread(T).Cnt104680 + nRow);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 3;
                      nm := IntToStr(TScanThread(T).Cnt10467C + nCol +
                                        TScanThread(T).CapW);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 4;
                      nm := IntToStr(TScanThread(T).Cnt104680 + nRow +
                                        TScanThread(T).CapH);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      rd := 5;
                      nm := IntToStr(nHits * $64 div
                                        TScanThread(T).Fld44C8);
                      StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                     TScanThread(T).ParenPos, nm, a, rd);
                      Inc(a);
                      Dec(nTol);
                    end;
                  end;
                end;
                Inc(qq);
              end;
              if TScanThread(T).Lock.Flag then
                Inc(nn)
              else
                Dec(nn);
            end;
            SetLength(arrCol, 0);
          end;
          if not TScanThread(T).Lock.Flag then
          begin
            GlobalFree(THandle(TScanThread(T).ShotBits));
            TScanThread(T).ShotBits := nil;
          end;
          nHits := TScanThread(T).CapWnd;
          end
          else
          begin
            sdi := 0;
            TScanThread(T).ShotFailed := False;
            nn := ptA.Y;
            SetLength(arrCol, 1);
            while (nn <= ptB.Y - 1) and (nTol <> 0) do
            begin
              if TScanThread(T).StopRequested then
              begin
                SetLength(arrCol, 0);
                ReleaseDC(0, dcS);
                Exit;
              end;
              qq := ptA.X;
              while (qq <= ptB.X - 1) and (nTol <> 0) do
              begin
                if TScanThread(T).StopRequested then
                begin
                  SetLength(arrCol, 0);
                  ReleaseDC(0, dcS);
                  Exit;
                end;
                if a > Cardinal(nLim) then
                begin
                  Inc(nLim, $64);
                  TScanThread(T).ParenPos := 0;
                  rd := 4;
                  nSave := a;
                  a := nLim;
                  nm := V;
                  p := FindScriptVar(T, cK, nm, a, rd);
                  a := nSave;
                end;
                q := GetPixel(dcS, qq, nn);
                bMatch := False;
                if bHas then
                begin
                  nIdx3 := q and $FF;
                  if nIdx3 - bTol > 0 then
                    arrCol[0].Lo1 := nIdx3 - bTol
                  else
                    arrCol[0].Lo1 := 0;
                  if bTol + nIdx3 < $FF then
                    arrCol[0].Hi1 := nIdx3 + bTol
                  else
                    arrCol[0].Hi1 := $FF;
                  nIdx3 := (q and $FF00) shr 8;
                  if nIdx3 - bTol > 0 then
                    arrCol[0].Lo2 := nIdx3 - bTol
                  else
                    arrCol[0].Lo2 := 0;
                  if bTol + nIdx3 < $FF then
                    arrCol[0].Hi2 := nIdx3 + bTol
                  else
                    arrCol[0].Hi2 := $FF;
                  nIdx3 := (q and $FF0000) shr 16;
                  if nIdx3 - bTol > 0 then
                    arrCol[0].Lo3 := nIdx3 - bTol
                  else
                    arrCol[0].Lo3 := 0;
                  if bTol + nIdx3 < $FF then
                    arrCol[0].Hi3 := nIdx3 + bTol
                  else
                    arrCol[0].Hi3 := $FF;
                  bHit :=
                    (TScanThread(T).ImgList[sdi][2] and $FF >= arrCol[0].Lo1) and
                    (TScanThread(T).ImgList[sdi][2] and $FF <= arrCol[0].Hi1) and
                    ((TScanThread(T).ImgList[sdi][2] and $FF00) shr 8 >=
                     arrCol[0].Lo2) and
                    ((TScanThread(T).ImgList[sdi][2] and $FF00) shr 8 <=
                     arrCol[0].Hi2) and
                    ((TScanThread(T).ImgList[sdi][2] and $FF0000) shr 16 >=
                     arrCol[0].Lo3) and
                    ((TScanThread(T).ImgList[sdi][2] and $FF0000) shr 16 <=
                     arrCol[0].Hi3);
                end
                else
                  bHit := TScanThread(T).ImgList[sdi][2] = q;
                if bHit then
                begin
                  nHits := 1;
                  for nJ2 := 1 to Length(TScanThread(T).ImgList) - 1 do
                  begin
                    nGy := GetPixel(dcS,
                                TScanThread(T).ImgList[nJ2][0] + qq,
                                TScanThread(T).ImgList[nJ2][1] + nn);
                    if bHas then
                    begin
                      nIdx3 := nGy and $FF;
                      if nIdx3 - bTol > 0 then
                        arrCol[0].Lo1 := nIdx3 - bTol
                      else
                        arrCol[0].Lo1 := 0;
                      if bTol + nIdx3 < $FF then
                        arrCol[0].Hi1 := nIdx3 + bTol
                      else
                        arrCol[0].Hi1 := $FF;
                      nIdx3 := (nGy and $FF00) shr 8;
                      if nIdx3 - bTol > 0 then
                        arrCol[0].Lo2 := nIdx3 - bTol
                      else
                        arrCol[0].Lo2 := 0;
                      if bTol + nIdx3 < $FF then
                        arrCol[0].Hi2 := nIdx3 + bTol
                      else
                        arrCol[0].Hi2 := $FF;
                      nIdx3 := (nGy and $FF0000) shr 16;
                      if nIdx3 - bTol > 0 then
                        arrCol[0].Lo3 := nIdx3 - bTol
                      else
                        arrCol[0].Lo3 := 0;
                      if bTol + nIdx3 < $FF then
                        arrCol[0].Hi3 := nIdx3 + bTol
                      else
                        arrCol[0].Hi3 := $FF;
                      bHit :=
                        (TScanThread(T).ImgList[nJ2][2] and $FF >= arrCol[0].Lo1) and
                        (TScanThread(T).ImgList[nJ2][2] and $FF <= arrCol[0].Hi1) and
                        ((TScanThread(T).ImgList[nJ2][2] and $FF00) shr 8 >=
                         arrCol[0].Lo2) and
                        ((TScanThread(T).ImgList[nJ2][2] and $FF00) shr 8 <=
                         arrCol[0].Hi2) and
                        ((TScanThread(T).ImgList[nJ2][2] and $FF0000) shr 16 >=
                         arrCol[0].Lo3) and
                        ((TScanThread(T).ImgList[nJ2][2] and $FF0000) shr 16 <=
                         arrCol[0].Hi3);
                    end
                    else
                      bHit := TScanThread(T).ImgList[nJ2][2] = nGy;
                    if bHit then
                      Inc(nHits);
                  end;
                  if nHits * $64 div nGap >= nPct then
                  begin
                    bMatch := True;
                    TScanThread(T).CapWnd := nHits;
                  end;
                end;
                if bMatch then
                begin
                  ptF.X := qq - TScanThread(T).ImgList[0][0];
                  ptF.Y := nn - TScanThread(T).ImgList[0][1];
                  if not bAbs then
                    ScreenToClient(TScanThread(T).ClientWnd, ptF);
                  rd := 1;
                  nm := IntToStr(TScanThread(T).Cnt10467C + ptF.X);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm, a, rd);
                  rd := 2;
                  nm := IntToStr(TScanThread(T).Cnt104680 + ptF.Y);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm, a, rd);
                  rd := 3;
                  nm := IntToStr(TScanThread(T).Cnt10467C + ptF.X +
                                    TScanThread(T).CapW);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm, a, rd);
                  rd := 4;
                  nm := IntToStr(TScanThread(T).Cnt104680 + ptF.Y +
                                    TScanThread(T).CapH);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm, a, rd);
                  rd := 5;
                  nm := IntToStr(nHits * $64 div nGap);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm, a, rd);
                  Inc(a);
                  Dec(nTol);
                end;
                Inc(qq);
              end;
              Inc(nn);
            end;
            SetLength(arrCol, 0);
            nHits := TScanThread(T).CapWnd;
          end;
          rd := 5;
          Dec(a);
          GetArraySize(T, V, Cardinal(a), Cardinal(rd), True);
          ReleaseDC(0, dcS);
        end;
      end
      else
      begin
        TScanThread(T).ShotFailed := True;
        V := '-3';
      end;
      if not TScanThread(T).ShotFailed then
      begin
        if a = 1 then
          V := IntToStr(nHits * $64 div nGap)
        else
          V := IntToStr(a);
      end;
      except
        V := '-1';
      end;
      end
      else
        V := '-2';
      p := nStart2;
      Insert(V, ts, p);
      Inc(p, Length(V));

            end;
          246:
            begin { getimage }

          qq := p;
          bFlag := False;
          nLen3 := Length(ts);
          while (qq <= nLen3) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
          begin
            if ts[qq] = '(' then
            begin
              bFlag := True;
              Break;
            end;
            Inc(qq);
          end;
          if bFlag then
          begin
            bFlag := False;
            a := qq;
            nLen3 := Length(ts);
            rd := 0;
            while Cardinal(a) <= Cardinal(nLen3) do
            begin
              case ts[a] of
                '(': begin Inc(rd); bFlag := True; end;
                ')': Dec(rd);
              end;
              if bFlag then
                if rd = 0 then
                  Break;
              Inc(a);
            end;
            V := 'calc ' + Copy(ts, qq + 1, Integer(a) - (qq + 1));
            Delete(ts, p, Integer(a) - p + 1);
            try
              a := 5;
              rd := 0;
              ptA.X := StrToInt(EvalScriptExpr(T, V, 1));
              ptA.Y := StrToInt(EvalScriptExpr(T, V, 2));
              ptB.X := StrToInt(EvalScriptExpr(T, V, 3));
              ptB.Y := StrToInt(EvalScriptExpr(T, V, 4));
              qq := 0;
              a := 0;
              sA := AnsiLowerCase(EvalScriptExpr(T, V, 5));
              sEe := AnsiLowerCase(EvalScriptExpr(T, V, 6));
              if (sA = 'abs') or (sEe = 'abs') then
                bAbs := True
              else
                bAbs := False;
              bFlag := False;
              if not TryStrToInt(sA, PInteger(@TScanThread(T).CapWnd)^) or
                 (Integer(TScanThread(T).CapWnd) < 1) then
                TScanThread(T).CapWnd := 2;
              nShots := TScanThread(T).CapWnd;
              dcS := GetDC(0);
              ptD.X := ptA.X;
              ptD.Y := ptA.Y;
              ptE.X := ptB.X;
              ptE.Y := ptB.Y;
              if not bAbs then
                if Integer(TScanThread(T).CapWnd) <= 2 then
                begin
                  ClientToScreen(TScanThread(T).ClientWnd, ptA);
                  ClientToScreen(TScanThread(T).ClientWnd, ptB);
                  bFlag := GetClientRect(TScanThread(T).ClientWnd, rcW);
                end
                else
                  bFlag := GetWindowRect(nShots, rcW);
              if bFlag then
                if Integer(TScanThread(T).CapWnd) <= 2 then
                begin
                  ptC := Types.Point(rcW.Left, rcW.Top);
                  ClientToScreen(TScanThread(T).ClientWnd, ptC);
                  kk := ptA.X - ptC.X;
                  q := ptA.Y - ptC.Y;
                  rcW.Left := rcW.Right - rcW.Left;
                  rcW.Top := rcW.Bottom - rcW.Top;
                  if ptB.X - ptA.X - 1 <= 0 then
                    ptB.X := rcW.Left - kk;
                  if ptB.Y - ptA.Y - 1 <= 0 then
                    ptB.Y := rcW.Top - q;
                  ptB.X := ptA.X + rcW.Left;
                  ptB.Y := ptA.Y + rcW.Top;
                end
                else
                begin
                  ptC := Types.Point(0, 0);
                  ClientToScreen(nShots, ptC);
                  kk := ptC.X - rcW.Left;
                  q := ptC.Y - rcW.Top;
                  Inc(ptA.X, kk);
                  Inc(ptA.Y, q);
                  Inc(ptB.X, kk);
                  Inc(ptB.Y, q);
                  pt := Types.Point(rcW.Right, rcW.Bottom);
                  ScreenToClient(nShots, pt);
                  if (rcW.Right - ptC.X - 1 < ptB.X) or (ptB.X - ptA.X < 0) then
                    ptB.X := rcW.Right - ptC.X - 1;
                  if (pt.Y - kk + q - 1 < ptB.Y) or (ptB.Y - ptA.Y < 0) then
                    ptB.Y := pt.Y - kk + q - 1;
                  if ptA.X > ptB.X then
                    ptA.X := kk;
                  if ptA.Y > ptB.Y then
                    ptA.Y := q;
                end;
              Inc(ptB.X);
              Inc(ptB.Y);
              if Integer(TScanThread(T).CapWnd) <> 1 then
              begin
                if Integer(TScanThread(T).CapWnd) > 2 then
                  bMulti := True
                else
                  bMulti := False;
                TScanThread(T).CapTo := ptB;
                TScanThread(T).CapFrom := ptA;
                try
                  TScanThread(T).ShotFailed := False;
                  TScanThread(T).CaptureWindowBits;
                except
                  TScanThread(T).ShotCount := 0;
                  TScanThread(T).ShotFailed := True;
                end;
                if TScanThread(T).ShotFailed then
                  V := '-6';
                a := 1;
                nPad := TScanThread(T).ShotW mod 4;
                if TScanThread(T).ShotFailed then
                begin
                  if TScanThread(T).IsProc then
                  begin
                    TScanThread(T).Msg := 'error retrieving pictures';
                    TScanThread(T).Synchronize(T.SyncLogMsg);
                  end;
                end
                else
                begin
                  Dec(ptB.X, ptA.X);
                  Dec(ptB.Y, ptA.Y);
                  nn := ptB.Y - 1;
                end;
                qq := 1;
                while Length(TScanThread(T).Blocks) >= qq do
                begin
                  if TScanThread(T).Blocks[qq - 1].Handle = 0 then
                    Break;
                  Inc(qq);
                end;
                if Length(TScanThread(T).Blocks) < qq then
                  SetLength(TScanThread(T).Blocks, qq);
                Dec(qq);
                TScanThread(T).Blocks[qq].W := ptD.X;
                TScanThread(T).Blocks[qq].H := ptD.Y;
                TScanThread(T).Blocks[qq].Bits := TScanThread(T).Lock.W;
                TScanThread(T).Blocks[qq].Stride := TScanThread(T).Lock.H;
                TScanThread(T).Blocks[qq].Extra := TScanThread(T).Lock.Stride;
                TScanThread(T).Blocks[qq].Handle := THandle(TScanThread(T).ShotBits);
                nHits := TScanThread(T).CapWnd;
                V := IntToStr(Int64(TScanThread(T).Blocks[qq].Handle)) + '|' +
                  IntToStr(Int64(Cardinal(TScanThread(T).Blocks[qq].Bits))) + '|' +
                  IntToStr(Int64(Cardinal(TScanThread(T).Blocks[qq].Stride))) + '|' +
                  IntToStr(TScanThread(T).Blocks[qq].Extra) + '/';
              end
              else
                V := 'Сервис не реализован.';
              rd := 4;
              ReleaseDC(0, dcS);
            except
              V := '-1';
            end;
          end
          else
            V := '-2';
          Insert(V, ts, p);
          Inc(p, Length(V));

            end;
          247:
            begin { deleteimage }
      qq := p;
      ok := False;
      nLen3 := Length(ts);
      while (qq <= nLen3) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        nLen3 := Length(ts);
        rd := 0;
        while Cardinal(a) <= Cardinal(nLen3) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := 'calc ' + Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        try
          V := EvalScriptPoint(T, EvalScriptExpr(T, V, -1), 0);
          if TryStrToInt(V, nn) then begin
            V := '0';
            qq := 0;
            while Length(TScanThread(T).Blocks) - 1 >= qq do begin
              if TScanThread(T).Blocks[qq].Handle = nn then begin
                TScanThread(T).Blocks[qq].W := 0;
                TScanThread(T).Blocks[qq].H := 0;
                TScanThread(T).Blocks[qq].Bits := 0;
                TScanThread(T).Blocks[qq].Stride := 0;
                TScanThread(T).Blocks[qq].Extra := 0;
                GlobalFree(TScanThread(T).Blocks[qq].Handle);
                TScanThread(T).Blocks[qq].Handle := 0;
                V := '1';
                Break;
              end;
              Inc(qq);
            end;
          end else
            V := '-3';
        except
          V := '-1';
        end;
      end else
        V := '-2';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          248:
            begin { loadimage }
      qq := p;
      bFlag := False;
      nLen3 := Length(ts);
      while (qq <= nLen3) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        bFlag := False;
        a := qq;
        nLen3 := Length(ts);
        rd := 0;
        while Cardinal(a) <= Cardinal(nLen3) do
        begin
          case ts[a] of
            '(': begin Inc(rd); bFlag := True; end;
            ')': Dec(rd);
          end;
          if bFlag then
            if rd = 0 then
              Break;
          Inc(a);
        end;
        V := 'calc ' + Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        try
          while (Length(V) > 0) and (V[1] in [#9, #32]) do
            Delete(V, 1, 1);
          while (Length(V) > 0) and (V[Length(V)] in [#9, #32]) do
            Delete(V, Length(V), 1);
          V := EvalScriptExpr(T, V, -1);
          try
            TScanThread(T).ShotFailed := False;
            TScanThread(T).ImgFile := V;
            TScanThread(T).CapWnd := 1;
            LoadImageFile(TScanThread(T));
            nn := TScanThread(T).CapWnd;
          except
            nn := 0;
            TScanThread(T).ShotFailed := True;
            V := '-6';
          end;
          if nn < 0 then
          begin
            TScanThread(T).ShotFailed := True;
            V := '-4';
          end
          else
          begin
            qq := 1;
            while Length(TScanThread(T).Blocks) >= qq do
            begin
              if TScanThread(T).Blocks[qq - 1].Handle = 0 then
                Break;
              Inc(qq);
            end;
            if Length(TScanThread(T).Blocks) < qq then
              SetLength(TScanThread(T).Blocks, qq);
            Dec(qq);
            TScanThread(T).Blocks[qq].W := 0;
            TScanThread(T).Blocks[qq].H := 0;
            TScanThread(T).Blocks[qq].Bits := TScanThread(T).Lock.W;
            TScanThread(T).Blocks[qq].Stride := TScanThread(T).Lock.H;
            TScanThread(T).Blocks[qq].Extra := TScanThread(T).Lock.Stride;
            TScanThread(T).Blocks[qq].Handle := TScanThread(T).Lock.Handle;
            V := IntToStr(Int64(TScanThread(T).Blocks[qq].Handle)) + '|' +
              IntToStr(Int64(Cardinal(TScanThread(T).Blocks[qq].Bits))) + '|' +
              IntToStr(Int64(Cardinal(TScanThread(T).Blocks[qq].Stride))) + '|' +
              IntToStr(TScanThread(T).Blocks[qq].Extra) + '/';
          end;
          ReleaseDC(0, dcS);
        except
          V := '-1';
        end;
      end
      else
        V := '-2';
      Insert(V, ts, p);
      Inc(p, Length(V));

            end;
          249:
            begin { saveimage }
      qq := p;
      ok := False;
      nLen3 := Length(ts);
      while (qq <= nLen3) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        nLen3 := Length(ts);
        rd := 0;
        while Cardinal(a) <= Cardinal(nLen3) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := 'calc ' + Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        V := 'calc ' + EvalScriptExpr(T, V, -1);
        nn := StrToInt(EvalScriptExpr(T, V, 1));
        TScanThread(T).ImgFile := EvalScriptExpr(T, V, -2);
        qq := 1;
        while Length(TScanThread(T).Blocks) >= qq do begin
          if TScanThread(T).Blocks[qq - 1].Handle = nn then
            Break;
          Inc(qq);
        end;
        if Length(TScanThread(T).Blocks) >= qq then begin
          Dec(qq);
          TScanThread(T).Lock.Stride := TScanThread(T).Blocks[qq].Extra;
          TScanThread(T).Lock.W := TScanThread(T).Blocks[qq].Bits;
          TScanThread(T).Lock.H := TScanThread(T).Blocks[qq].Stride;
          TScanThread(T).Lock.Handle := TScanThread(T).Blocks[qq].Handle;
          V := AnsiLowerCase(Copy(TScanThread(T).ImgFile,
            Length(TScanThread(T).ImgFile) - 3, 4));
          if V = '.bmp' then
            TScanThread(T).CapWnd := 1
          else if V = '.jpg' then
            TScanThread(T).CapWnd := 2
          else if V = '.png' then
            TScanThread(T).CapWnd := 3
          else
            TScanThread(T).CapWnd := 1;
          EbSaveImg(T);
        end else
          V := '-7';
      end else
        V := '-2';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          279:
            begin { findmemory }
      qq := p;
      nn := Length(ts);
      bFlag := False;
      while (qq <= nn) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        qq := 0;
        nn := 0;
        V := 'calc ' + FindParenGroup(T, ts, p, qq, nn);
        if nn > 0 then
        begin
          Delete(ts, p, nn - p + 1);
          SplitCmdLine(T, V);
          arg := EvalScriptExpr(T, 'calc ' + TScanThread(T).CmdParts[1], -1);
          sAcc := EvalScriptExpr(T, 'calc ' + TScanThread(T).CmdParts[2], -1);
          TScanThread(T).CmdArg := AnsiLowerCase(TScanThread(T).CmdParts[3]);
          s3 := TScanThread(T).CmdParts[4];
          qq := StrToIntDef(EvalScriptExpr(T, 'calc ' +
                     TScanThread(T).CmdParts[5], -1), 100);
          nCnt2 := StrToIntDef(sAcc, $63);
          nShots := StrToIntDef(EvalScriptExpr(T, 'calc ' +
                     TScanThread(T).CmdParts[6], -1), 0);
          bF1 := 0;
          wF2 := 0;
          dblF := 0;
          nDW := 0;
          i64 := 0;
          sngF := 0;
          rl48 := 0;
          cF := #0;
          sFind := '';
          bFlag := False;
          if Length(s3) >= 2 then
            if s3[1] = '%' then
            begin
              cK := s3[1];
              Delete(s3, 1, 1);
              nAdd := FindScriptVar(T, cK, s3, 0, 0);
              bFlag := True;
            end;
          bFlag := bFlag and True;
          case TScanThread(T).CmdArg[1] of
            'b': bF1 := StrToIntDef(sAcc, $11);
            'w': wF2 := StrToIntDef(sAcc, $1111);
            'd':
              if (Length(TScanThread(T).CmdArg) > 1) and
                 (TScanThread(T).CmdArg[2] = 'o') then
                dblF := StrToFloatDef(sAcc, 1)
              else
                nDW := StrToIntDef(sAcc, $11111111);
            'l': i64 := StrToIntDef(sAcc, $63);
            'f': sngF := StrToFloatDef(sAcc, 1);
            'r': rl48 := StrToFloatDef(sAcc, 1);
            'c':
              if Length(sAcc) > 0 then
                cF := sAcc[1]
              else
                cF := 'e';
            's': sFind := Copy(sAcc, 1, $FF);
          else
            bFlag := False;
          end;
          if bFlag then
          begin
            if nShots <> 0 then
            begin
              GetWindowThreadProcessId(nShots, @a);
              nShots := OpenProcess($638, False, a);
              try
                rr := 0;
                a := 1;
                rd := 1;
                nQ := Length(sFind);
                while VirtualQueryEx(nShots, Pointer(rr), mbi, $1C) <> 0 do
                begin
                  if TScanThread(T).StopRequested then
                    Break;
                  if mbi.State = $1000 then
                    if mbi.Protect and $100 <> $100 then
                    begin
                      GetMem(pc, mbi.RegionSize);
                      try
                        ReadMemDispatch(nShots, pc, nVal,
                          Cardinal(mbi.BaseAddress), mbi.RegionSize);
                        if nVal > 0 then
                        begin
                          TScanThread(T).ClipLen := gMemLastErrorao;
                          nm := IntToStr(wF2);
                          case TScanThread(T).CmdArg[1] of
                            'b':
                              for nn := 0 to Integer(nVal) - 1 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PByte(@PByteArray(pc)^[nn])^ = bF1 then
                                begin
                                  StoreScriptVar(T, cK, nAdd, '', -1,
                                    IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                      nn), 8), a, rd);
                                  Inc(a);
                                end;
                              end;
                            'w':
                              for nn := 0 to Integer(nVal) - 2 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PWord(@PByteArray(pc)^[nn])^ = wF2 then
                                begin
                                  StoreScriptVar(T, cK, nAdd, '', -1,
                                    IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                      nn), 8), a, rd);
                                  Inc(a);
                                end;
                              end;
                            'l':
                              for nn := 0 to Integer(nVal) - 8 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PCardinal(@PByteArray(pc)^[nn])^ =
                                   i64 then
                                begin
                                  StoreScriptVar(T, cK, nAdd, '', -1,
                                    IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                      nn), 8), a, rd);
                                  Inc(a);
                                end;
                              end;
                            'd':
                              if (Length(TScanThread(T).CmdArg) > 1) and
                                 (TScanThread(T).CmdArg[2] = 'o') then
                              begin
                                for nn := 0 to Integer(nVal) - 8 - 1 do
                                begin
                                  if TScanThread(T).StopRequested then
                                    Break;
                                  if PDouble(@PByteArray(pc)^[nn])^ =
                                     dblF then
                                  begin
                                    StoreScriptVar(T, cK, nAdd, '', -1,
                                      IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                        nn), 8), a, rd);
                                    Inc(a);
                                  end;
                                end;
                              end
                              else
                                for nn := 0 to Integer(nVal) - 4 - 1 do
                                begin
                                  if TScanThread(T).StopRequested then
                                    Break;
                                  if PCardinal(@PByteArray(pc)^[nn])^ =
                                     nDW then
                                  begin
                                    StoreScriptVar(T, cK, nAdd, '', -1,
                                      IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                        nn), 8), a, rd);
                                    Inc(a);
                                  end;
                                end;
                            'f':
                              for nn := 0 to Integer(nVal) - 4 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PSingle(@PByteArray(pc)^[nn])^ =
                                   sngF then
                                begin
                                  StoreScriptVar(T, cK, nAdd, '', -1,
                                    IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                      nn), 8), a, rd);
                                  Inc(a);
                                end;
                              end;
                            'r':
                              for nn := 0 to Integer(nVal) - 6 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PReal48(@PByteArray(pc)^[nn])^ =
                                   rl48 then
                                begin
                                  StoreScriptVar(T, cK, nAdd, '', -1,
                                    IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                      nn), 8), a, rd);
                                  Inc(a);
                                end;
                              end;
                            'c':
                              for nn := 0 to Integer(nVal) - 1 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PChar(@PByteArray(pc)^[nn])^ = cF then
                                begin
                                  StoreScriptVar(T, cK, nAdd, '', -1,
                                    IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                      nn), 8), a, rd);
                                  Inc(a);
                                end;
                              end;
                            's':
                              for nn := 0 to Integer(nVal) - $100 - 1 do
                              begin
                                if TScanThread(T).StopRequested then
                                  Break;
                                if PChar(@PByteArray(pc)^[nn])^ = sFind[1] then
                                begin
                                  { Здесь переиспользуется `bFlag`: к этому
                                    месту он уже мёртв -- последнее чтение
                                    на полторы сотни строк выше. }
                                  nH := 2;
                                  bFlag := True;
                                  while nH <= nQ do
                                  begin
                                    if PChar(@PByteArray(pc)^[nn + nH - 1])^ <>
                                       sFind[nH] then
                                    begin
                                      bFlag := False;
                                      Break;
                                    end;
                                    Inc(nH);
                                  end;
                                  if bFlag then
                                  begin
                                    StoreScriptVar(T, cK, nAdd, '', -1,
                                      IntToHex(Integer(Cardinal(mbi.BaseAddress) +
                                        nn), 8), a, rd);
                                    Inc(a);
                                  end;
                                end;
                              end;
                          end;
                        end
                        else
                          V := '-5';
                      except
                        V := '-4';
                      end;
                      FreeMem(pc);
                    end;
                  if Cardinal($FFFFFFFF) - rr < mbi.RegionSize then
                    Break;
                  Inc(rr, mbi.RegionSize);
                end;
                V := IntToStr(a - 1);
              except
                CloseHandle(nShots);
                V := '-3';
              end;
            end
            else
              V := '-2';
          end
          else
            V := '-7';
        end
        else
          V := '-1';
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end
      else
      begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;

            end;
          76:
            begin { size }
      qq := p;
      bFlag := False;
      while (Length(ts) >= qq) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        bFlag := False;
        aI := qq;
        rd := 0;
        while Cardinal(Length(ts)) >= Cardinal(aI) do
        begin
          case ts[aI] of
            '(': begin Inc(rd); bFlag := True; end;
            ')': Dec(rd);
          end;
          if bFlag then
            if rd = 0 then
              Break;
          Inc(aI);
        end;
        V := Copy(ts, qq + 1, aI - (qq + 1));
        Delete(ts, p, aI - p + 1);
        while (Length(V) > 0) and not (V[1] in gWordCharsadq) do
          Delete(V, 1, 1);
        while not (V[Length(V)] in ([']'] + gWordCharsadq)) do
          Delete(V, Length(V), 1);
        cS := V[1];
        case cS of
          '%':
            begin
              Delete(V, 1, 1);
              nIdx := Pos('[', V);
              if Cardinal(nIdx) > 0 then
              begin
                sd := Copy(V, nIdx + 1, Length(V));
                while sd[Length(sd)] <> ']' do
                  Delete(sd, Length(sd), 1);
                Delete(sd, Length(sd), 1);
                sd := EvalScriptExpr(T, 'calc ' + sd, -1);
                V := Copy(V, 1, nIdx - 1);
                while not (V[Length(V)] in gWordCharsadq) do
                  Delete(V, Length(V), 1);
                if EvalScriptExpr(T, 'calc ' + sd, 2) <> '' then
                begin
                  sd := EvalScriptExpr(T, 'calc %' + V + ' [' + sd + ']', -1);
                  V := IntToStr(Length(sd));
                  nIdx := 2;
                end
                else
                  nIdx := 1;
              end;
              aI := 0;
              rd := 0;
              case Cardinal(nIdx) of
                0:
                  try
                    GetArraySize(T, V, Cardinal(aI), Cardinal(rd), False);
                    V := IntToStr(Int64(Cardinal(aI)));
                  except
                    V := '-1';
                  end;
                1:
                  try
                    GetArraySize(T, V, Cardinal(aI), Cardinal(rd), False);
                    V := IntToStr(Int64(Cardinal(rd)));
                  except
                    V := '-1';
                  end;
              end;
            end;
          '$':
            begin
              sd := EvalScriptExpr(T, 'calc ' + V, -1);
              V := IntToStr(Length(sd));
            end;
          '#':
            begin
              sd := EvalScriptExpr(T, 'calc ' + V, -1);
              V := IntToStr(Length(sd));
            end;
        else
          V := IntToStr(Length(V));
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end;

            end;
          44:
            begin { workwindow }
      if TScanThread(T).ProcessHandle2 = hProc then
        V := IntToStr(TScanThread(T).ClientWnd2)
      else
        V := IntToStr(gScriptso3[scr].ClientWnd2);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          95:
            begin { workwindowpid }
      V := IntToStr(T.ProcessId);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          79:
            begin { getlayout }
      aI := GetKeyboardLayout(TScanThread(T).ThreadId);
      if (aI shr 16) = (aI and $FFFF) then
        V := IntToHex(Cardinal(aI) shr 16, 8)
      else
        V := IntToHex(Cardinal(aI), 8);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          80:
            begin { setlayout }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        V := EvalScriptExpr(T, 'calc ' + V, -1);
        while (Length(V) > 0) and not (V[1] in gWordCharsadq) do
          Delete(V, 1, 1);
        while not (V[Length(V)] in gWordCharsadq) do
          Delete(V, Length(V), 1);
        while Length(V) < 8 do
          V := '0' + V;
        a := LoadKeyboardLayout(PChar(V), 2);
        SendMessage(TScanThread(T).ClientWnd2, $50, 1, a);
        if a = 0 then
          V := '0'
        else
          V := '1';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(nm, ts, p);
        Inc(p, Length(nm));
      end;
            end;
          81:
            begin { windowfromcursor }
      GetCursorPos(pt);
      aI := Integer(WindowFromPoint(pt));
      V := IntToStr(Int64(Cardinal(aI)));
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          82:
            begin { getselectedtext }
      qq := p;
      a := FocusedWindow(T);
      rd := SendMessage(a, $D, $100, Integer(@buf));
      if rd > 0 then begin
        rr := SendMessage(a, $B0, 0, 0);
        if rr > 0 then begin
          wC := rr;
          wD := HiWord(rr);
        end else begin
          wC := 0;
          wD := rd;
        end;
        buf[wD] := #0;
        pc := PChar(@buf[wC]);
      end else
        pc := '';
      V := pc;
      if isop then
        V := '"' + V + '"';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          83:
            begin { setselectedtext }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        a := FocusedWindow(T);
        SendMessage(a, $C2, 1, Integer(@V[1]));
        V := IntToStr(Cardinal(a));
      Insert(V, ts, p);
      Inc(p, Length(V));
      end;
            end;
          85:
            begin { current_script }
      V := T.Name;
      while V[1] = '^' do
        Delete(V, 1, 1);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          87:
            begin { hex2dec }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        try
          V := EvalScriptExpr(T, 'calc ' + V, -1);
          if Copy(V, 1, 2) <> '0x' then
            V := '0x' + V;
          V := IntToStr(StrToInt64(V));
        except
          V := '-1';
          if TScanThread(T).IsProc then
            TScanThread(T).Msg := 'Convert error' + #0;
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else if TScanThread(T).IsProc then
        TScanThread(T).Msg := 'Wrong parameter specified' + #0;
      if TScanThread(T).IsProc then
        TScanThread(T).Synchronize(T.SyncLogMsg);
            end;
          88:
            begin { dec2hex }
      qq := p;
      ok := False;
      while (Length(ts) >= qq) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        ok := False;
        a := qq;
        while Cardinal(Length(ts)) >= Cardinal(a) do begin
          case ts[a] of
            '(': begin Inc(rd); ok := True; end;
            ')': Dec(rd);
          end;
          if ok and (rd = 0) then Break;
          Inc(a);
        end;
        V := Copy(ts, qq + 1, Integer(a) - (qq + 1));
        Delete(ts, p, Integer(a) - p + 1);
        try
          V := '0x' + IntToHex(StrToInt64(EvalScriptExpr(T, 'calc ' + V, -1)), 8);
        except
          V := '-1';
          if TScanThread(T).IsProc then
            TScanThread(T).Msg := 'Convert error' + #0;
        end;
        Insert(V, ts, p);
        Inc(p, Length(pc));
      end else if TScanThread(T).IsProc then
        TScanThread(T).Msg := 'Wrong parameter specified' + #0;
      if TScanThread(T).IsProc then
        TScanThread(T).Synchronize(T.SyncLogMsg);
            end;
          96..99:
            begin { posex,copy,delete }
      V := 'calc ' + FindParenGroup(T, ts, p, ptC.X, ptC.Y);
      if ptC.Y > 0 then
      begin
        Delete(ts, p, ptC.Y - p + 1);
        sB := EvalScriptPoint(T, V, 1);
        if (Length(sB) > 0) and (sB[1] = '%') then
        begin
          qq := PosEx('[', V, TScanThread(T).WordPos);
          if qq > 0 then
          begin
            nn := PosEx(']', V, qq);
            if nn > 0 then
            begin
              sB := Copy(V, TScanThread(T).WordPos,
                         nn - TScanThread(T).WordPos + 1);
              Delete(V, TScanThread(T).WordPos,
                     nn - TScanThread(T).WordPos + 1);
              qq := TScanThread(T).WordPos;
              sB := EvalScriptExpr(T, 'calc ' + sB, -1);
              Insert(sB, V, qq);
            end;
          end;
        end
        else
          sB := EvalScriptExpr(T, 'calc ' + sB, -1);
        sCc := EvalScriptPoint(T, V, 2);
        if (Length(sCc) > 0) and (sCc[1] = '%') then
        begin
          qq := PosEx('[', V, TScanThread(T).WordPos);
          if qq > 0 then
          begin
            nn := PosEx(']', V, qq);
            if nn > 0 then
            begin
              sCc := Copy(V, TScanThread(T).WordPos,
                         nn - TScanThread(T).WordPos + 1);
              Delete(V, TScanThread(T).WordPos,
                     nn - TScanThread(T).WordPos + 1);
              qq := TScanThread(T).WordPos;
              sCc := EvalScriptExpr(T, 'calc ' + sCc, -1);
              Insert(sCc, V, qq);
            end;
          end;
        end
        else
          sCc := EvalScriptExpr(T, 'calc ' + sCc, -1);
        V := EvalScriptPoint(T, 'calc ' + EvalScriptExpr(T, V, -3), 1);
        case idx of
          $60:
            begin
              if not TryStrToInt(V, qq) then
                qq := 1;
              V := IntToStr(PosEx(sB, sCc, qq));
            end;
          $61:
            begin
              if not TryStrToInt(sCc, nn) then
                nn := 1;
              if not TryStrToInt(V, qq) then
                qq := 0;
              V := Copy(sB, nn, qq);
            end;
          $62:
            begin
              if not TryStrToInt(sCc, nn) then
                nn := 1;
              if not TryStrToInt(V, qq) then
                qq := 0;
              Delete(sB, nn, qq);
              V := sB;
            end;
          $63:
            begin
              if not TryStrToInt(V, qq) then
                qq := 1;
              Insert(sB, sCc, qq);
              V := sCc;
            end;
        end;
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end
      else
      begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;

            end;
          100:
            begin { errorlevel }
      V := IntToStr(TScanThread(T).ClipLen);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          101:
            begin { screenheight }
      V := IntToStr(Screen.Height);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          102:
            begin { screenwidth }
      V := IntToStr(Screen.Width);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          103:
            begin { desktopheight }
      V := IntToStr(Screen.DesktopHeight);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          104:
            begin { desktopwidth }
      V := IntToStr(Screen.DesktopWidth);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          105:
            begin { monitorheight }
      try
        V := IntToStr(Screen.Monitors[TScanThread(T).Cnt105BC8].Height);
      except
        V := '0';
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          106:
            begin { monitorwidth }
      try
        V := IntToStr(Screen.Monitors[TScanThread(T).Cnt105BC8].Width);
      except
        V := '0';
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          107:
            begin { monitor }
      V := IntToStr(TScanThread(T).Cnt105BC8);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          109..111:
            begin { fileexists,filegetattr,filegetdate }
      qq := 0;
      nn := 0;
      arg := FindParenGroup(T, ts, p, qq, nn);
      Delete(ts, p, nn - p + 1);
      if (nn > 0) and (Length(arg) > 0) then begin
        V := '';
        s5 := '';
        V := FindQuotedGroup(T, arg, 1, kk, q);
        if V = '' then
          V := arg;
        V := EvalScriptExpr(T, 'calc ' + V, -1);
        case idx of
          $6D: if FileExists(V) then
                 V := '1'
               else
                 V := '0';
          $6E: begin
                 kk := FileGetAttr(V);
                 V := '';
                 if kk >= 0 then begin
                   if kk and 1 <> 0 then
                     V := V + 'R';
                   if kk and $20 <> 0 then
                     V := V + 'A';
                   if kk and 4 <> 0 then
                     V := V + 'S';
                   if kk and 2 <> 0 then
                     V := V + 'H';
                 end;
               end;
          $6F: begin
                 kk := FileAge(V);
                 if kk >= 0 then
                   V := DateTimeToStr(FileDateToDateTime(kk))
                 else
                   V := '';
               end;
        end;
        TScanThread(T).ClipLen := GetLastError;
        if TScanThread(T).IsProc and fmSecondfj.miFileOpError.Checked then begin
          TScanThread(T).LogPrefix := gCmdListah7[idx];
          TScanThread(T).Msg := SysErrorMessage(TScanThread(T).ClipLen);
          TScanThread(T).Synchronize(T.SyncLogMsg);
          TScanThread(T).LogPrefix := '';
        end;
      end;
      if isop then
        V := '"' + V + '"';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          112:
            begin { windowfrompoint }
      qq := 0;
      nn := 0;
      arg := FindParenGroup(T, ts, p, qq, nn);
      Delete(ts, p, nn - p + 1);
      V := '';
      s5 := '';
      if (nn > 0) and (Length(arg) > 0) then begin
        arg := 'calc ' + EvalScriptExpr(T, 'calc ' + arg, -1);
        V := EvalScriptPoint(T, arg, 1);
        s5 := EvalScriptPoint(T, arg, 2);
        arg := LowerCase(EvalScriptPoint(T, arg, 3));
        kk := 0;
        if Length(arg) > 0 then
          case arg[1] of
            'a': kk := 1;
            'c': kk := 2;
          end;
        if TryStrToInt(V, qq) and TryStrToInt(s5, nn) then begin
          pt.X := qq;
          pt.Y := nn;
          SetLength(TScanThread(T).ImgTol, 0);
          V := '';
          while True do begin
            nn := Integer(WindowFromPoint(pt));
            if kk = 2 then begin
              kk := 0;
              qq := nn;
            end else begin
              repeat
                if TScanThread(T).StopRequested then
                  Break;
                qq := nn;
                nn := GetParent(nn);
              until nn = 0;
              if qq < $105B8 then
                Break;
            end;
            if GetClassName(qq, @buf[1], $C8) > 0 then begin
              if string(PChar(@buf[1])) = 'Shell_TrayWnd' then
                Break;
              if string(PChar(@buf[1])) = 'Progman' then
                Break;
            end;
            q := Length(TScanThread(T).ImgTol);
            SetLength(TScanThread(T).ImgTol, q + 1);
            TScanThread(T).ImgTol[q] := qq;
            if q > 0 then
              V := V + '/';
            V := V + IntToStr(qq);
            if kk = 0 then
              Break;
            ShowWindow(qq, 0);
          end;
          if kk = 1 then
            for qq := Length(TScanThread(T).ImgTol) - 1 downto 0 do
              ShowWindow(TScanThread(T).ImgTol[qq], 5);
          SetLength(TScanThread(T).ImgTol, 0);
        end else begin
          if TScanThread(T).IsProc then begin
            TScanThread(T).LogPrefix := gCmdListah7[idx];
            TScanThread(T).Msg := 'Wrong parameter specified' + #0;
            TScanThread(T).Synchronize(T.SyncLogMsg);
            TScanThread(T).LogPrefix := '';
          end;
          V := '';
        end;
      end;
      if isop then
        V := '"' + V + '"';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          108:
            begin { indexof }
      qq := p;
      nn := Length(ts);
      bFlag := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin bFlag := True; Break; end;
        Inc(qq);
      end;
      if bFlag then begin
        if (Length(TScanThread(T).CmdArg) > 0) and (TScanThread(T).CmdArg[1] = '#') then
          isVar13F := True
        else
          isVar13F := False;
        qq := 0;
        nn := 0;
        V := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        a := nn;
        nm := EvalScriptPoint(T, V, 0);
        qq := 0;
        nn := 0;
        sAcc := FindParenGroup(T, V, 1, qq, nn);
        Delete(V, qq, nn - qq + 1);
        V := EvalScriptExpr(T, 'calc ' + V, -2);
        qq := 0;
        fCase := False;
        bAbs := True;
        arg := EvalScriptPoint(T, V, qq);
        if LowerCase(arg) = 'noabs' then begin
          Inc(qq);
          bAbs := False;
        end;
        if qq = 1 then
          arg := EvalScriptPoint(T, V, qq);
        if LowerCase(arg) = 'case' then begin
          Inc(qq);
          fCase := True;
        end;
        nn := 4;
        arg := EvalScriptPoint(T, V, nn);
        while (arg = '') and (nn >= -1) do begin
          Dec(nn);
          arg := EvalScriptPoint(T, V, nn);
        end;
        if not TryStrToInt(arg, nQ) then
          nQ := 0;
        if not TryStrToInt(EvalScriptPoint(T, V, nn - 1), q) then
          q := 1;
        if not TryStrToInt(EvalScriptPoint(T, V, nn - 2), kk) then
          kk := 1;
        case nn of
          3: case qq of
               2: begin
                    kk := q;
                    q := 1;
                  end;
             end;
          2: case qq of
               2: begin
                    kk := 1;
                    q := 1;
                  end;
               1: q := 1;
             end;
          1: case qq of
               1: begin
                    kk := 1;
                    q := 1;
                  end;
               0: q := 1;
             end;
          0: begin
               kk := 1;
               q := 1;
             end;
        else
          kk := 1;
          q := 1;
          nQ := 0;
        end;
        neg13E := False;
        if nQ < 0 then begin
          neg13E := True;
          nQ := Abs(nQ);
        end else if nQ = 0 then
          case isVar13F of
            False: nQ := -1;
            True: nQ := 1;
          end;
        if nm[1] = '%' then begin
          sAcc := EvalScriptExpr(T, 'calc ' + sAcc, -1);
          Delete(nm, 1, 1);
          a := 0;
          rd := 0;
          qq := FindScriptVar(T, '%', nm, Integer(a), Integer(rd));
          arg := '';
          bFlag := False;
          Dec(kk);
          Dec(q);
          if kk < 0 then
            kk := 0;
          if (q <= 0) or (Length(TScanThread(T).Arr48[qq].Data) < q) then
            q := Length(TScanThread(T).Arr48[qq].Data) - 1;
          if q >= 0 then begin
            if not fCase then
              sAcc := AnsiUpperCase(sAcc);
            for rd := 0 to Length(TScanThread(T).Arr48[qq].Data[0]) - 1 do begin
              if bFlag then
                Break;
              for a := kk to q do begin
                bDot := False;
                if neg13E then
                  nn := q - a
                else
                  nn := a;
                case bAbs of
                  True:
                    if fCase then
                      bDot := AnsiStrComp(PChar(sAcc),
                        PChar(TScanThread(T).Arr48[qq].Data[nn][rd])) = 0
                    else
                      bDot := AnsiStrComp(PChar(sAcc),
                        PChar(AnsiUpperCase(
                          TScanThread(T).Arr48[qq].Data[nn][rd]))) = 0;
                  False:
                    if fCase then
                      bDot := Pos(sAcc,
                        TScanThread(T).Arr48[qq].Data[nn][rd]) > 0
                    else
                      bDot := Pos(sAcc, AnsiUpperCase(
                        TScanThread(T).Arr48[qq].Data[nn][rd])) > 0;
                end;
                if bDot then begin
                  arg := arg + IntToStr(nn + 1) + '|' + IntToStr(rd + 1) + '/';
                  Dec(nQ);
                  if nQ = 0 then begin
                    if isVar13F then
                      arg := IntToStr(nn + 1);
                    bFlag := True;
                    Break;
                  end;
                end;
              end;
            end;
          end;
          if (not bFlag) and isVar13F then
            arg := '-1';
        end;
        if isop then
          arg := '"' + arg + '"';
        Insert(arg, ts, p);
        Inc(p, Length(arg));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          113:
            begin { mousepos_x }
      GetCursorPos(pt);
      ScreenToClient(T.ClientWnd, pt);
      V := IntToStr(pt.X);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          114:
            begin { mousepos_y }
      GetCursorPos(pt);
      ScreenToClient(T.ClientWnd, pt);
      V := IntToStr(pt.Y);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          115:
            begin { mouseposabs_x }
      GetCursorPos(pt);
      V := IntToStr(pt.X);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          116:
            begin { mouseposabs_y }
      GetCursorPos(pt);
      V := IntToStr(pt.Y);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          117..135, 137..154, 193:
            begin { abs,round,floor }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        s5 := FindParenGroup(T, ts, p, qq, nn);
        V := EvalScriptExpr(T, 'calc ' + s5, -1);
        Delete(ts, p, nn - p + 1);
        case idx of
        $75: begin { abs }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Abs(f))
          else
            V := '-1';
          end;
        $76: begin { round }
          if TryStrToFloat(V, f) then
            V := IntToStr(Round(f))
          else
            V := '-1';
          end;
        $77: begin { floor }
          if TryStrToFloat(V, f) then
            V := IntToStr(Floor(f))
          else
            V := '-1';
          end;
        $78: begin { ceil }
          if TryStrToFloat(V, f) then
            V := IntToStr(Ceil(f))
          else
            V := '-1';
          end;
        $79: begin { frac }
          qq := Pos(',', V);
          if qq = 0 then
            qq := Pos('.', V);
          if qq = 0 then
            V := '0'
          else
            Delete(V, 1, qq);
          end;
        $7A: begin { sqrt }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Sqrt(Abs(f)))
          else
            V := '-1';
          end;
        $7B: begin { power }
          V := 'exp ' + V;
          sAcc := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 2), '_', ',', [rfReplaceAll]);
          if TryStrToFloat(sAcc, g) and TryStrToFloat(arg, g2) then
            V := FloatToStr(Power(g, g2))
          else
            V := '-1';
          end;
        $7C: begin { exp }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Exp(f))
          else
            V := '-1';
          end;
        $7D: begin { ln }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Ln(f))
          else
            V := '-1';
          end;
        $7E: begin { log }
          V := 'exp ' + V;
          sAcc := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 2), '_', ',', [rfReplaceAll]);
          if TryStrToFloat(sAcc, g) and TryStrToFloat(arg, g2) then
            V := FloatToStr(LogN(g, g2))
          else
            V := '-1';
          end;
        $7F: begin { sin }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Sin(f))
          else
            V := '-1';
          end;
        $80: begin { cos }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Cos(f))
          else
            V := '-1';
          end;
        $81: begin { tan }
          if TryStrToFloat(V, f) then
            V := FloatToStr(Tan(f))
          else
            V := '-1';
          end;
        $82: begin { arcsin }
          if TryStrToFloat(V, f) then
            V := FloatToStr(ArcSin(f))
          else
            V := '-1';
          end;
        $83: begin { arccos }
          if TryStrToFloat(V, f) then
            V := FloatToStr(ArcCos(f))
          else
            V := '-1';
          end;
        $84: begin { arctan }
          if TryStrToFloat(V, f) then
            V := FloatToStr(ArcTan(f))
          else
            V := '-1';
          end;
        $85: begin { degtorad }
          if TryStrToFloat(V, f) then
            V := FloatToStr(DegToRad(f))
          else
            V := '-1';
          end;
        $86: begin { radtodeg }
          if TryStrToFloat(V, f) then
            V := FloatToStr(RadToDeg(f))
          else
            V := '-1';
          end;
        $87: begin { trunc }
          if TryStrToFloat(V, f) then
            V := IntToStr(Trunc(f))
          else
            V := '-1';
          end;
        $89: begin { minx }
          V := 'exp ' + StringReplace(V, ',', '_', [rfReplaceAll]);
          f := MaxComp;
          qq := 1;
          sAcc := EvalScriptPoint(T, V, qq);
          bad := True;
          bDot := True;
          while Length(sAcc) > 0 do begin
            if not TryStrToFloat(StringReplace(sAcc, '_', ',', [rfReplaceAll]), g) then begin
              bad := True;
              if (sAcc[1] = '%') and (qq = 1) then begin
                bDot := False;
                nn := 1;
                kk := Pos('.', sAcc);
                if kk > 0 then begin
                  s3 := sAcc;
                  Delete(s3, 1, kk);
                  sAcc := AnsiLowerCase(Copy(sAcc, 2, kk - 2));
                  kk := TScanThread(T).ScriptStrToInt(s3);
                  kk := Integer(gScriptso3[kk].SelfRef);
                end else begin
                  kk := Integer(TScanThread(T).SelfRef);
                  Delete(sAcc, 1, 1);
                  sAcc := AnsiLowerCase(sAcc);
                end;
                nm := '';
                mm := 0;
                while Length(TScanThread(kk).Arr48) > mm do begin
                  if TScanThread(kk).Arr48[mm].Name = sAcc then begin
                    for nQ := 1 to Length(TScanThread(kk).Arr48[mm].Data[0]) do begin
                      f := MaxComp;
                      qq := 1;
                      s3 := '';
                      for q := 1 to Length(TScanThread(kk).Arr48[mm].Data) do begin
                        if s3 <> '' then s3 := s3 + ' ';
                        if TryStrToFloat(TScanThread(kk).Arr48[mm].Data[q - 1][nQ - 1], g) then
                          s3 := s3 + FloatToStr(g);
                        bad := False;
                      end;
                      nn := 0;
                      if Length(s3) > 0 then begin
                        sAcc := EvalScriptPoint(T, s3, nn);
                        while Length(sAcc) > 0 do begin
                          if not TryStrToFloat(StringReplace(sAcc, '_', ',', [rfReplaceAll]), g) then begin
                            f := -1;
                            qq := 1;
                            bad := True;
                            Break;
                          end;
                          if g < f then f := g;
                          Inc(nn);
                          sAcc := EvalScriptPoint(T, s3, nn);
                        end;
                        if nm = '' then
                          nm := FloatToStr(f)
                        else
                          nm := nm + '|' + FloatToStr(f);
                      end else
                        nm := nm + '|';
                    end;
                    Break;
                  end;
                  Inc(mm);
                end;
                if Length(nm) = 0 then bad := True;
              end else begin
                f := -1;
                qq := 1;
              end;
              Break;
            end else begin
              if g < f then f := g;
              Inc(qq);
              sAcc := EvalScriptPoint(T, V, qq);
              bad := False;
            end;
          end;
          if bDot then begin
            if bad then f := -1;
            V := FloatToStr(f);
          end else
            V := nm;
          end;
        $8A: begin { maxx }
          V := 'exp ' + StringReplace(V, ',', '_', [rfReplaceAll]);
          f := Low(Int64);
          qq := 1;
          sAcc := EvalScriptPoint(T, V, qq);
          bad := True;
          bDot := True;
          while Length(sAcc) > 0 do begin
            if not TryStrToFloat(StringReplace(sAcc, '_', ',', [rfReplaceAll]), g) then begin
              bad := True;
              if (sAcc[1] = '%') and (qq = 1) then begin
                bDot := False;
                nn := 1;
                kk := Pos('.', sAcc);
                if kk > 0 then begin
                  s3 := sAcc;
                  Delete(s3, 1, kk);
                  sAcc := AnsiLowerCase(Copy(sAcc, 2, kk - 2));
                  kk := TScanThread(T).ScriptStrToInt(s3);
                  kk := Integer(gScriptso3[kk].SelfRef);
                end else begin
                  kk := Integer(TScanThread(T).SelfRef);
                  Delete(sAcc, 1, 1);
                  sAcc := AnsiLowerCase(sAcc);
                end;
                nm := '';
                mm := 0;
                while Length(TScanThread(kk).Arr48) > mm do begin
                  if TScanThread(kk).Arr48[mm].Name = sAcc then begin
                    for nQ := 1 to Length(TScanThread(kk).Arr48[mm].Data[0]) do begin
                      f := Low(Int64);
                      qq := 1;
                      s3 := '';
                      for q := 1 to Length(TScanThread(kk).Arr48[mm].Data) do begin
                        if s3 <> '' then s3 := s3 + ' ';
                        if TryStrToFloat(TScanThread(kk).Arr48[mm].Data[q - 1][nQ - 1], g) then
                          s3 := s3 + FloatToStr(g);
                        bad := False;
                      end;
                      nn := 0;
                      if Length(s3) > 0 then begin
                        sAcc := EvalScriptPoint(T, s3, nn);
                        while Length(sAcc) > 0 do begin
                          if not TryStrToFloat(StringReplace(sAcc, '_', ',', [rfReplaceAll]), g) then begin
                            f := -1;
                            qq := 1;
                            bad := True;
                            Break;
                          end;
                          if f < g then f := g;
                          Inc(nn);
                          sAcc := EvalScriptPoint(T, s3, nn);
                        end;
                        if nm = '' then
                          nm := FloatToStr(f)
                        else
                          nm := nm + '|' + FloatToStr(f);
                      end else
                        nm := nm + '|';
                    end;
                    Break;
                  end;
                  Inc(mm);
                end;
                if Length(nm) = 0 then bad := True;
              end else begin
                f := -1;
                qq := 1;
              end;
              Break;
            end else begin
              if f < g then f := g;
              Inc(qq);
              sAcc := EvalScriptPoint(T, V, qq);
              bad := False;
            end;
          end;
          if bDot then begin
            if bad then f := -1;
            V := FloatToStr(f);
          end else
            V := nm;
          end;
        $8B: begin { mean }
          V := 'exp ' + StringReplace(V, ',', '_', [rfReplaceAll]);
          f := 0;
          qq := 1;
          sAcc := EvalScriptPoint(T, V, qq);
          while Length(sAcc) > 0 do begin
            if not TryStrToFloat(StringReplace(sAcc, '_', ',', [rfReplaceAll]), g) then begin
              f := -1;
              qq := 1;
              Break;
            end else begin
              f := f + g;
              Inc(qq);
              sAcc := EvalScriptPoint(T, V, qq);
            end;
          end;
          V := FloatToStr(f / (qq - 1));
          end;
        $8D: begin { point_distance }
          V := 'exp ' + StringReplace(V, ',', '_', [rfReplaceAll]);
          sAcc := StringReplace(EvalScriptPoint(T, V, 3), '_', ',', [rfReplaceAll]);
          s3 := StringReplace(EvalScriptPoint(T, V, 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, V, 4), '_', ',', [rfReplaceAll]);
          s4 := StringReplace(EvalScriptPoint(T, V, 2), '_', ',', [rfReplaceAll]);
          if TryStrToFloat(sAcc, g) and TryStrToFloat(arg, g2)
            and TryStrToFloat(s3, g3) and TryStrToFloat(s4, g4) then begin
            g := g - g3;
            g2 := g2 - g4;
            f := Sqrt(Abs(Sqr(g) + Sqr(g2)));
            V := FloatToStr(f);
          end else
            V := '-1';
          end;
        $8E: begin { point_direction }
          V := 'exp ' + StringReplace(V, ',', '_', [rfReplaceAll]);
          sAcc := StringReplace(EvalScriptPoint(T, V, 3), '_', ',', [rfReplaceAll]);
          s3 := StringReplace(EvalScriptPoint(T, V, 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, V, 4), '_', ',', [rfReplaceAll]);
          s4 := StringReplace(EvalScriptPoint(T, V, 2), '_', ',', [rfReplaceAll]);
          if TryStrToFloat(sAcc, g) and TryStrToFloat(arg, g2)
            and TryStrToFloat(s3, g3) and TryStrToFloat(s4, g4) then begin
            g := g - g3;
            g2 := g2 - g4;
            if g = 0 then begin
              if g2 = 0 then
                f := 0
              else if g2 > 0 then
                f := 90
              else
                f := 270;
            end else if g2 = 0 then begin
              if g > 0 then
                f := 0
              else
                f := 180;
            end else begin
              f := Abs(RadToDeg(ArcTan(g2 / g)));
              if g < 0 then begin
                if g2 < 0 then
                  f := f + 180
                else
                  f := 180 - f;
              end else if g2 < 0 then
                f := 360 - f;
            end;
            V := FloatToStr(f);
          end else
            V := '-1';
          end;
        $8F: begin { lengthdir_x }
          V := 'exp ' + V;
          sAcc := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 2), '_', ',', [rfReplaceAll]);
          if TryStrToFloat(sAcc, g) and TryStrToFloat(arg, g2) then
            V := FloatToStr(g * Cos(DegToRad(g2)))
          else
            V := '-1';
          end;
        $90: begin { lengthdir_y }
          V := 'exp ' + V;
          sAcc := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 2), '_', ',', [rfReplaceAll]);
          if TryStrToFloat(sAcc, g) and TryStrToFloat(arg, g2) then
            V := FloatToStr(g * Sin(DegToRad(g2)))
          else
            V := '-1';
          end;
        $91: begin { is_real }
          if (V <> DecimalSeparator) and TryStrToFloat(V, f) then
            V := '1'
          else
            V := '0';
          end;
        $92: begin { is_string }
          if not TryStrToFloat(V, f) then
            V := '1'
          else
            V := '0';
          end;
        $93: begin { chr }
          if TryStrToInt(V, qq) then
            V := Chr(qq)
          else
            V := '';
          end;
        $94: begin { ord }
          if Length(V) > 0 then
            V := IntToStr(Ord(V[1]))
          else
            V := '0';
          end;
        $95: begin { string_replace }
          V := 'exp ' + s5;
          s3 := EvalScriptExpr(T, 'calc ' + EvalScriptPoint(T, V, 1), -1);
          arg := EvalScriptExpr(T, 'calc ' + EvalScriptPoint(T, V, 2), -1);
          sAcc := EvalScriptExpr(T, 'calc ' + EvalScriptPoint(T, V, 3), -1);
          s4 := EvalScriptExpr(T, 'calc ' + EvalScriptPoint(T, V, 4), -1);
          if Length(s4) > 0 then
            V := StringReplace(s3, arg, sAcc, [rfReplaceAll, rfIgnoreCase])
          else
            V := StringReplace(s3, arg, sAcc, [rfIgnoreCase]);
          end;
        $96: begin { string_count }
          V := 'calc ' + s5;
          s3 := EvalScriptExpr(T, V, 1);
          arg := EvalScriptExpr(T, V, 2);
          qq := 0;
          nn := Pos(s3, arg);
          while nn > 0 do begin
            Inc(qq);
            nn := PosEx(s3, arg, nn + 1);
          end;
          V := IntToStr(qq);
          end;
        $97: begin { string_lower }
          V := AnsiLowerCase(V);
          end;
        $98: begin { string_upper }
          V := AnsiUpperCase(V);
          end;
        $99: begin { string_letters }
          arg := '';
          for qq := 1 to Length(V) do
            if not (V[qq] in ['0'..'9']) then
              arg := arg + V[qq];
          V := arg;
          end;
        $9A: begin { string_digits }
          arg := '';
          for qq := 1 to Length(V) do
            if V[qq] in ['0'..'9'] then
              arg := arg + V[qq];
          if Length(arg) > 0 then
            V := arg
          else
            V := '-1';
          end;
        $8C: begin { mod }
          V := 'exp ' + V;
          sAcc := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 2), '_', ',', [rfReplaceAll]);
          if TryStrToInt64(sAcc, i1) and TryStrToInt64(arg, i2) then
            V := IntToStr(i1 mod i2)
          else
            V := '-1';
          end;
        $C1: begin { div }
          V := 'exp ' + V;
          sAcc := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 1), '_', ',', [rfReplaceAll]);
          arg := StringReplace(EvalScriptPoint(T, StringReplace(V, ',', '_', [rfReplaceAll]), 2), '_', ',', [rfReplaceAll]);
          if TryStrToInt64(sAcc, i1) and TryStrToInt64(arg, i2) then
            V := IntToStr(i1 div i2)
          else
            V := '-1';
          end;
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          136:
            begin { pi }
      V := FloatToStr(System.Pi);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          159:
            begin { dayofweek }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        if (nn > 0) and (Length(arg) > 0) then begin
          Delete(ts, p, nn - p + 1);
          sAcc := EvalScriptExpr(T, 'calc ' + arg, -1);
          arg := 'calc ' + sAcc;
          V := EvalScriptPoint(T, arg, 1);
          s5 := EvalScriptPoint(T, arg, 2);
          arg := EvalScriptPoint(T, arg, 3);
          if TryStrToInt(V, qq) and TryStrToInt(s5, nn) and
            TryStrToInt(arg, mm) then begin
            kk := (14 - nn) div 12;
            q := qq - kk;
            nQ := kk * 12 + nn - 2;
            V := IntToStr((mm + q + q div 4 - q div 100 + q div 400 +
              (31 * nQ) div 12 + 7000) mod 7);
          end else
            try
              kk := DayOfWeek(StrToDate(sAcc)) - 1;
              V := IntToStr(kk);
            except
              if TScanThread(T).IsProc then begin
                TScanThread(T).LogPrefix := gCmdListah7[idx];
                TScanThread(T).Msg := 'Wrong parameter specified' + #0;
                TScanThread(T).Synchronize(T.SyncLogMsg);
                TScanThread(T).LogPrefix := '';
              end;
              V := '';
            end;
        end else
          V := '-1';
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          160:
            begin { claqua }
      V := IntToStr(clAqua);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          161:
            begin { clblack }
      V := IntToStr(clBlack);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          162:
            begin { clblue }
      V := IntToStr(clBlue);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          163:
            begin { cldkgray }
      V := IntToStr(clDkGray);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          164:
            begin { clfuchsia }
      V := IntToStr(clFuchsia);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          165:
            begin { clgray }
      V := IntToStr(clGray);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          166:
            begin { clgreen }
      V := IntToStr(clGreen);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          167:
            begin { cllime }
      V := IntToStr(clLime);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          168:
            begin { clltgray }
      V := IntToStr(clLtGray);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          169:
            begin { clmaroon }
      V := IntToStr(clMaroon);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          170:
            begin { clnavy }
      V := IntToStr(clNavy);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          171:
            begin { clolive }
      V := IntToStr(clOlive);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          172:
            begin { clpurple }
      V := IntToStr(clPurple);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          173:
            begin { clred }
      V := IntToStr(clRed);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          174:
            begin { clsilver }
      V := IntToStr(clSilver);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          175:
            begin { clteal }
      V := IntToStr(clTeal);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          176:
            begin { clwhite }
      V := IntToStr(clWhite);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          177:
            begin { clyellow }
      V := IntToStr(clYellow);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          178..181:
            begin { shownames,transparency,pathfinding }
      if (not fRead[idx]) or force then begin
        case idx of
          $B2: a := gClT590778a8[TScanThread(T).ClVerIdx];
          $B3: a := gClT5907DCahr[TScanThread(T).ClVerIdx];
          $B4: a := gClT5908A4av[TScanThread(T).ClVerIdx];
          $B5: a := gClT590840j4[TScanThread(T).ClVerIdx];
        end;
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[idx] := True;
        V := IntToStr(a);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          182:
            begin { eval }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        if (nn > 0) and (Length(arg) > 0) then begin
          Delete(ts, p, nn - p + 1);
          V := '';
          s5 := '';
          arg := EvalScriptExpr(T, 'calc ' + arg, -1);
          nm := ParseWaitSuffix(arg, k1, u1);
          if k1 <> 0 then
            V := arg
          else
            V := nm;
        end else
          V := '-1';
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          183..186:
            begin { colortorgb,colortored,colortogreen }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        V := '';
        s5 := '';
        bad := False;
        if (nn > 0) and (Length(arg) > 0) then begin
          try
            V := EvalScriptExpr(T, 'calc ' + arg, 1);
            if TryStrToInt(V, qq) then begin
              case idx of
                $B7: begin
                       TScanThread(T).CmdArg := '';
                       TScanThread(T).ParenPos := 0;
                       V := '';
                       nm := EvalScriptPoint(T, arg, 1);
                       nQ := 1;
                       nn := PosEx('[', arg, TScanThread(T).WordPos);
                       if nn > 0 then begin
                         mm := PosEx(']', arg, nn);
                         if mm > 0 then
                           if not TryStrToInt(EvalScriptExpr(T, 'calc ' +
                             Copy(arg, nn + 1, mm - nn - 1), -1), nQ) then
                             nQ := 1;
                       end;
                       aI := nQ;
                       Delete(nm, 1, 1);
                       rd := 3;
                       nn := FindScriptVar(T, '%', nm, aI, rd);
                       nm := IntToStr(qq and $FF);
                       StoreScriptVar(T, '%', nn, TScanThread(T).CmdArg, TScanThread(T).ParenPos, nm,
                         aI, 1);
                       nm := IntToStr((qq and $FF00) shr 8);
                       StoreScriptVar(T, '%', nn, TScanThread(T).CmdArg, TScanThread(T).ParenPos, nm,
                         aI, 2);
                       nm := IntToStr((qq and $FF0000) shr 16);
                       StoreScriptVar(T, '%', nn, TScanThread(T).CmdArg, TScanThread(T).ParenPos, nm,
                         aI, 3);
                     end;
                $B8: V := IntToStr(qq and $FF);
                $B9: V := IntToStr((qq and $FF00) shr 8);
                $BA: V := IntToStr((qq and $FF0000) shr 16);
              end;
            end else
              bad := True;
          except
            bad := True;
          end;
          if bad then begin
            if TScanThread(T).IsProc then begin
              TScanThread(T).LogPrefix := gCmdListah7[idx];
              TScanThread(T).Msg := 'Wrong parameter specified' + #0;
              TScanThread(T).Synchronize(T.SyncLogMsg);
              TScanThread(T).LogPrefix := '';
            end;
            V := '-1';
          end;
        end else
          V := '-1';
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          187..189:
            begin { ltrim,rtrim,trim }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        case idx of
          $BB: V := TrimLeft(arg);
          $BC: V := TrimRight(arg);
          $BD: V := Trim(arg);
        end;
        if isop then
          V := '"' + V + '"';
      Insert(V, ts, p);
      Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          190:
            begin { showscriptprocessing }
      if fmSecondfj.miShowScriptProcessing.Checked then
        V := '1'
      else
        V := '0';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          191:
            begin { stopscrunknowncommand }
      if fmSecondfj.miStopSUncC.Checked then
        V := '1'
      else
        V := '0';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          192:
            begin { showtimervar }
      if fmSecondfj.miShowTimerVar.Checked then
        V := '1'
      else
        V := '0';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          194:
            begin { regexp }
      qq := p;
      nn := Length(ts);
      bFlag := False;
      while (qq <= nn) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
      qq := 0;
      nn := 0;
      arg := FindParenGroup(T, ts, p, qq, nn);
      Delete(ts, p, nn - p + 1);
      s1 := EvalScriptPoint(T, arg, 0);
      s2 := EvalScriptPoint(T, arg, 1);
      if TScanThread(T).InLua then
      begin
        s3160 := arg;
        Delete(s3160, 1, Pos('"', s3160));
        kk := Pos(#217'"'#192' "', s3160);
        sOptV := Copy(s3160, kk + 5, Length(s3160) - 5 - kk - 2);
        s3160 := Copy(s3160, 1, kk - 1);
        s3160 := EvalScriptExpr(T, 'calc ' + s3160, -1);
      end
      else
        s3160 := EvalScriptPoint(T, arg, 2);
      if s3160 <> '' then
        case s3160[1] of
          '$': s3160 := EvalScriptExpr(T, 'calc ' + s3160, -1);
          '%':
            begin
              kk := TScanThread(T).WordPos;
              if FindArrayItem(T, arg, kk, q, nQ, nR3, nAdd, nH,
                               s4, sAcc) then
              begin
                s3160 := sAcc;
                Delete(arg, kk, q - kk + 1);
                Insert(s4, arg, kk);
              end
              else
              begin
                bFlag := False;
                V := '-1';
              end;
            end;
        end
      else
      begin
        bFlag := False;
        V := '-4';
        s3160 := '-1';
        sOptV := '-1';
      end;
      if bFlag then
      begin
        if not TScanThread(T).InLua then
          sOptV := EvalScriptPoint(T, arg, -3);
        qq := 1;
        nn := Length(sOptV);
        while (qq < nn) and (sOptV[qq] in [#9, #32]) do
          Inc(qq);
        sOptV := Copy(sOptV, qq, nn - qq + 1);
        kk := 0;
        if sOptV <> '' then
          case sOptV[1] of
            '$': sOptV := EvalScriptExpr(T, 'calc ' + sOptV, -1);
            '%':
              if FindArrayItem(T, sOptV, kk, q, nQ, nR3, nAdd, nH,
                               s4, sAcc) then
                sOptV := sAcc;
          end
        else
        begin
          s3160 := '-1';
          sOptV := '-1';
          V := '-5';
        end;
        TScanThread(T).RegEx := TPerlRegEx.Create;
        ebR1.rxLoc_F99D := TPerlRegEx(TScanThread(T).RegEx);
        { Порядок важен: сперва SetRegEx, потом SetSubject. }
        ebR1.rxLoc_F99D.RegEx := sOptV;
        ebR1.rxLoc_F99D.Subject := s3160;
        if ebR1.rxLoc_F99D.Match then
        begin
          V := '1';
          s3160 := IntToStr(ebR1.rxLoc_F99D.MatchedOffset);
          sOptV := ebR1.rxLoc_F99D.MatchedText;
        end
        else
        begin
          V := '0';
          s3160 := '-1';
          sOptV := '-1';
        end;
        TScanThread(T).RegEx.Free;
        TScanThread(T).RxLen := s3160;
        TScanThread(T).RxSub := sOptV;
        TScanThread(T).CmdArg := '';
        TScanThread(T).ParenPos := 0;
        cK := s1[1];
        Delete(s1, 1, 1);
        nn := FindScriptVar(T, cK, s1, 0, 0);
        StoreScriptVar(T, cK, nn, TScanThread(T).CmdArg,
                       TScanThread(T).ParenPos, s3160, 0, 0);
        TScanThread(T).CmdArg := '';
        TScanThread(T).ParenPos := 0;
        cK := s2[1];
        Delete(s2, 1, 1);
        nn := FindScriptVar(T, cK, s2, 0, 0);
        StoreScriptVar(T, cK, nn, TScanThread(T).CmdArg,
                       TScanThread(T).ParenPos, sOptV, 0, 0);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
      end
      else
      begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;

            end;
          86:
            begin { active_script }
      TScanThread(T).CtlId := idx;
      TScanThread(T).Synchronize(TScanThread(T).SyncGetControlText);
      V := TScanThread(T).CtlText;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          90:
            begin { defcolor }
      V := IntToStr(StrToInt(fmSecondfj.btColor.Caption));
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          91:
            begin { defx }
      V := fmSecondfj.btXY.Caption;
      V := Copy(V, 1, Pos(',', V) - 1);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          92:
            begin { defy }
      V := fmSecondfj.btXY.Caption;
      V := Copy(V, Pos(',', V) + 2, 16);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          93:
            begin { defxabs }
      V := fmSecondfj.btXYabs.Caption;
      V := Copy(V, 1, Pos(',', V) - 1);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          94:
            begin { defyabs }
      V := fmSecondfj.btXYabs.Caption;
      V := Copy(V, Pos(',', V) + 2, 16);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          197:
            begin { homepath }
      V := gTempFilefv;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          198:
            begin { exefilename }
      V := gExeNameko;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          199:
            begin { windowhandle }
      V := IntToStr(fmSecondfj.Handle);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          200..219:
            begin { rvpassword,rvwalkcount,rvstayinsidecave }
      TScanThread(T).CtlId := idx;
      TScanThread(T).Synchronize(TScanThread(T).SyncGetControlText);
      V := IntToStr(TScanThread(T).CtlValue);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          230..233:
            begin { clickoffsetx,clickoffsety,findoffsetx }
      case idx of
        $E6: V := IntToStr(TScanThread(T).Cnt104674);
        $E7: V := IntToStr(TScanThread(T).Cnt104678);
        $E8: V := IntToStr(TScanThread(T).Cnt10467C);
        $E9: V := IntToStr(TScanThread(T).Cnt104680);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          234, 236, 237:
            begin { sendexdelay,emptylinedelay,mouseclickdelay }
      case idx of
        $ED: V := IntToStr(TScanThread(T).ClickDelay);
        $EA: V := IntToStr(TScanThread(T).SendDelay);
        $EC: V := TScanThread(T).PauseStr;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          239, 240:
            begin { promptpos_x,promptpos_y }
      case idx of
        $EF: V := IntToStr(T.Fld10488C);
        $F0: V := IntToStr(T.Fld104890);
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          241..243:
            begin { loghandle,logautoopen,messagesoutputto }
      case idx of
        $F1: if gDlg5966F8c6 <> nil then
               V := IntToStr(gDlg5966F8c6.Handle)
             else
               V := IntToStr(0);
        $F2: if fmSecondfj.miAutoOpenLog.Checked then
               V := IntToStr(1)
             else
               V := IntToStr(0);
        $F3: begin
               if fmSecondfj.miToMessageBox.Checked then
                 qq := 2
               else if fmSecondfj.miToHint.Checked then
                 qq := 4
               else
                 qq := 8;
               if fmSecondfj.miToLog.Checked then
                 Inc(qq);
               V := IntToStr(qq);
             end;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          224, 225:
            begin { chartohex,chartohexf }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        TScanThread(T).SubstAdvance := True;
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        Delete(ts, p, nn - p + 1);
        V := '';
        case idx of
          $E0: for qq := 1 to Length(arg) do
                 V := V + IntToHex(Ord(arg[qq]), 2);
          $E1: begin
                 V := V + #13 + #10;
                 nm := '';
                 for qq := 1 to Length(arg) do begin
                   if (arg[qq] = #13) or (arg[qq] = #10) then
                     nm := nm + '_'
                   else
                     nm := nm + arg[qq];
                   V := V + IntToHex(Ord(arg[qq]), 2);
                   if qq mod 8 = 0 then begin
                     V := V + ' ';
                     nm := nm + ' ';
                   end;
                   if qq mod 16 = 0 then begin
                     V := V + '  ' + nm + #13 + #10;
                     nm := '';
                   end;
                 end;
                 if nm <> '' then
                   V := V + '  ' + nm + #13 + #10;
               end;
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else
        Insert(w, ts, pIns);
      Inc(p, Length(w));
            end;
          226..228:
            begin { moduleaddress,relativeaddress2absolute,absoluteaddress2relative }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        Delete(ts, p, nn - p + 1);
        s1 := EvalScriptPoint(T, arg, 0);
        s2 := EvalScriptPoint(T, arg, 1);
        s3160 := EvalScriptPoint(T, arg, 2);
        if idx = $E2 then begin
          if not TryStrToInt(s2, qq) then
            qq := TScanThread(T).ProcessId;
        end else begin
          try
            nP1 := StrToInt64(s2);
          except
            nP1 := 0;
          end;
          if not TryStrToInt(s3160, qq) then
            qq := TScanThread(T).ProcessId;
        end;
        if qq > $7D00 then
          GetWindowThreadProcessId(qq, @qq);
        case idx of
          $E2: V := IntToStr(Integer(TModHelper(TScanThread(T).ProcessHandle2).ModAddr(AnsiLowerCase(s1), qq)));
          $E3: V := IntToStr(Integer(TModHelper(TScanThread(T).ProcessHandle2).Rel2Abs(AnsiLowerCase(s1), qq, nP1)));
          $E4: V := IntToStr(Integer(TModHelper(TScanThread(T).ProcessHandle2).Abs2Rel(AnsiLowerCase(s1), qq, nP1)));
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          238:
            begin { arrayaddress }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        a := 0;
        rd := 0;
        nm := EvalScriptPoint(T, arg, 0);
        Delete(nm, 1, 1);
        nn := FindScriptVar(T, '%', nm, Integer(a), Integer(rd));
        a := Length(TScanThread(T).Arr48[nn].Data);
        if a > 0 then
          rd := Length(TScanThread(T).Arr48[nn].Data[0])
        else
          rd := 0;
        V := IntToStr(Integer(@TScanThread(T).Arr48[nn])) + ' ' + IntToStr(a) +
          ' ' + IntToStr(rd);
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          244, 245:
            begin { sendmessage,postmessage }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        Delete(ts, p, nn - p + 1);
        s1 := EvalScriptPoint(T, arg, 0);
        s2 := EvalScriptPoint(T, arg, 1);
        s3160 := EvalScriptPoint(T, arg, 2);
        sOptV := EvalScriptPoint(T, arg, 3);
        if not TryStrToInt(s1, qq) then
          qq := TScanThread(T).ClientWnd2;
        if not TryStrToInt(s2, nn) then
          nn := 0;
        if not TryStrToInt(s3160, nLim) then
          nLim := 0;
        if not TryStrToInt(sOptV, nSave) then
          nSave := 0;
        case idx of
          $F4: begin
                 rr := SendMessage(qq, nn, nLim, nSave);
                 V := IntToStr(rr);
               end;
          $F5: begin
                 ok := PostMessage(qq, nn, nLim, nSave);
                 V := IntToStr(Ord(ok));
               end;
        end;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          250:
            begin { getfocus }
      a := GetForegroundWindow;
      if a <> 0 then begin
        rd := GetCurrentThreadId;
        rr := GetWindowThreadProcessId(a, nil);
        a := 0;
        if rd = rr then
          a := GetFocus
        else if AttachThreadInput(rd, rr, True) then begin
          a := GetFocus;
          AttachThreadInput(rd, rr, False);
        end;
      end;
      V := IntToStr(a);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          274..276:
            begin { backpack,backpackposx,backpackposy }
      if (not fRead[$112]) or force then begin
        a := gClT591268lt[TScanThread(T).ClVerIdx];
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        Inc(a, $11C);
        ReadProcessMemory(hProc, Pointer(a), @a, 4, rd);
        err := rd <> 4;
        case idx of
          $113: begin
                  nQ2 := a + $30;
                  ReadProcessMemory(hProc, Pointer(nQ2), @rr, 4, rd);
                  err := rd <> 4;
                  arg := IntToStr(rr);
                end;
          $114: begin
                  nQ2 := a + $34;
                  ReadProcessMemory(hProc, Pointer(nQ2), @rr, 4, rd);
                  err := rd <> 4;
                  arg := IntToStr(rr);
                end;
          $112: begin
                  nQ2 := a + $88;
                  ReadProcessMemory(hProc, Pointer(nQ2), @hp, 4, rd);
                  err := rd <> 4;
                  arg := '';
                  while True do begin
                    if hp = 0 then
                      Break;
                    ReadProcessMemory(hProc, Pointer(hp),
                      @TScanThread(T).Backpack, $B4, rd);
                    err := (rd <> $B4) or err;
                    if TScanThread(T).Backpack.Alive = 0 then
                      Break;
                    if TScanThread(T).Backpack.Key <> a then
                      hp := TScanThread(T).Backpack.Next
                    else begin
                      arg := arg + IntToStr(TScanThread(T).Backpack.d7C) + '|' +
                        IntToStr(TScanThread(T).Backpack.w3C) + '|' +
                        IntToStr(TScanThread(T).Backpack.w40) + '|' +
                        IntToStr(TScanThread(T).Backpack.w42) + '|' +
                        IntToStr(TScanThread(T).Backpack.w24) + '|' +
                        IntToStr(TScanThread(T).Backpack.w26) + '/';
                      hp := TScanThread(T).Backpack.d48;
                    end;
                  end;
                end;
        end;
      end;
      if err then
        V := IntToStr(-1)
      else begin
        fRead[idx] := True;
        V := arg;
      end;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          277:
            begin { scriptpath }
      V := T.FilePath;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          278:
            begin { scriptname }
      V := T.FileTitle;
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          281, 282:
            begin { setprocesspriority,getprocesspriority }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        case idx of
          $119: begin
                  hp := StrToIntDef(EvalScriptPoint(T, arg, 0), GetCurrentProcess);
                  a := hp;
                  if hp > $2710 then
                    GetWindowThreadProcessId(hp, @a);
                  hp := OpenProcess($638, True, a);
                  nAdd := StrToIntDef(EvalScriptPoint(T, arg, 1), 0);
                  case nAdd of
                    -2: rr := $40;
                    -1: rr := $4000;
                    1: rr := $8000;
                    2: rr := $80;
                    3: rr := $100;
                  else
                    rr := $20;
                  end;
                  if SetPriorityClass(hp, rr) then
                    V := '0'
                  else
                    V := IntToStr(GetLastError);
                  CloseHandle(hp);
                end;
          $11A: begin
                  hp := StrToIntDef(arg, GetCurrentProcess);
                  a := hp;
                  if hp > $2710 then
                    GetWindowThreadProcessId(hp, @a);
                  hp := OpenProcess($638, True, a);
                  rr := GetPriorityClass(hp);
                  case rr of
                    $40: V := '-2';
                    $4000: V := '-1';
                    $20: V := '0';
                    $8000: V := '1';
                    $80: V := '2';
                    $100: V := '3';
                  else
                    V := '-3';
                  end;
                  CloseHandle(hp);
                end;
        end;
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          283:
            begin { setprocessaffinitymask }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        hp := StrToIntDef(EvalScriptPoint(T, arg, 0), GetCurrentProcess);
        a := hp;
        if hp > $2710 then
          GetWindowThreadProcessId(hp, @a);
        hp := OpenProcess($638, True, a);
        nAdd := StrToIntDef(EvalScriptPoint(T, arg, 1), 0);
        if SetProcessAffinityMask(hp, nAdd) then
          V := '0'
        else
          V := IntToStr(GetLastError);
        CloseHandle(hp);
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          286, 287:
            begin { suspendprocess,resumeprocess }
      qq := p;
      nn := Length(ts);
      ok := False;
      while (qq <= nn) and not (ts[qq] in gWordCharsadq - ['(', ')']) do begin
        if ts[qq] = '(' then begin ok := True; Break; end;
        Inc(qq);
      end;
      if ok then begin
        qq := 0;
        nn := 0;
        arg := FindParenGroup(T, ts, p, qq, nn);
        Delete(ts, p, nn - p + 1);
        arg := EvalScriptExpr(T, 'calc ' + arg, -1);
        hp := StrToIntDef(EvalScriptPoint(T, arg, 0), 0);
        a := hp;
        if hp > $2710 then
          GetWindowThreadProcessId(hp, @a);
        hp := OpenProcess($638, True, a);
        rd := CreateToolhelp32Snapshot(4, a);
        if rd <> $FFFFFFFF then begin
          te_1A04.dwSize := $1C;
          bDot := Thread32First(rd, te_1A04);
          while bDot do begin
            if te_1A04.th32OwnerProcessID = a then begin
              nQ2 := OpenThread(2, False, te_1A04.th32ThreadID);
              if nQ2 <> 0 then
                case idx of
                  $11E: SuspendThread(nQ2);
                  $11F: ResumeThread(nQ2);
                end;
              V := IntToStr(GetLastError);
              CloseHandle(nQ2);
            end;
            bDot := Thread32Next(rd, te_1A04);
          end;
        end else
          V := IntToStr(GetLastError);
        CloseHandle(rd);
        CloseHandle(hp);
        if isop then
          V := '"' + V + '"';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end else begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;
            end;
          49:
            begin { color }
      qq := p;
      nn := Length(ts);
      bFlag := False;
      while (qq <= nn) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        qq := 0;
        nn := 0;
        V := FindParenGroup(T, ts, p, qq, nn);
        if nn > 0 then
        begin
          Delete(ts, p, nn - p + 1);
          sAcc := 'calc ' + EvalScriptExpr(T, 'calc ' + V, -1);
          pt.X := StrToInt(EvalScriptExpr(T, sAcc, 1));
          pt.Y := StrToInt(EvalScriptExpr(T, sAcc, 2));
          arg := AnsiLowerCase(EvalScriptExpr(T, sAcc, 3));
          sAcc := AnsiLowerCase(EvalScriptExpr(T, sAcc, 4));
          if not TryStrToInt(arg, nWnd) then
            nWnd := 0;
          if (arg = 'abs') or (sAcc = 'abs') then
          begin
            if nWnd > 0 then
            begin
              ScreenToClient(nWnd, pt);
              nIdx := 0;
            end
            else
            begin
              dcS := GetDC(0);
              nIdx := GetPixel(dcS, pt.X, pt.Y);
              ReleaseDC(0, dcS);
            end;
          end
          else
            if nWnd > 0 then
              nIdx := 0
            else
            begin
              ClientToScreen(TScanThread(T).ClientWnd, pt);
              dcS := GetDC(0);
              nIdx := GetPixel(dcS, pt.X, pt.Y);
              ReleaseDC(0, dcS);
            end;
          if nIdx = 0 then
          begin
            if nWnd > 0 then
              TScanThread(T).CapWnd := nWnd
            else
              TScanThread(T).CapWnd := TScanThread(T).ClientWnd;
            TScanThread(T).CapTo := pt;
            TScanThread(T).CapFrom := pt;
            Inc(TScanThread(T).CapTo.X);
            Inc(TScanThread(T).CapTo.Y);
            try
              TScanThread(T).ShotFailed := False;
              TScanThread(T).Synchronize(TScanThread(T).CaptureWindowBits);
            except
              TScanThread(T).ShotFailed := True;
            end;
            if TScanThread(T).ShotFailed then
              V := '-6';
            if TScanThread(T).ShotFailed and TScanThread(T).IsProc then
            begin
              if TScanThread(T).IsProc then
              begin
                TScanThread(T).Msg := 'error retrieving pictures';
                TScanThread(T).Synchronize(T.SyncLogMsg);
              end;
            end
            else
            begin
              ebR1.pBuf := TScanThread(T).ShotBits;
              nIdx := ebR1.pBuf[2] + ebR1.pBuf[1] shl 8 + ebR1.pBuf[0] shl 16;
            end;
            GlobalFree(THandle(TScanThread(T).ShotBits));
            TScanThread(T).ShotBits := nil;
            SetLength(arrCol, 0);
            ReleaseDC(0, dcS);
          end;
          if nIdx = -1 then
            V := '-1'
          else
            V := IntToStr(Cardinal(nIdx));
        end
        else
          V := '-1';
        Insert(V, ts, p);
        Inc(p, Length(V));
      end
      else
      begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;

            end;
          251..271:
            begin { adddate,addyears,addmonths }
      qq := p;
      nn := Length(ts);
      bFlag := False;
      while (qq <= nn) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        qq := 0;
        nn := 0;
        arg := EvalScriptExpr(T, 'calc ' +
                   FindParenGroup(T, ts, p, qq, nn), -1);
        Delete(ts, p, nn - p + 1);
        a := SplitCmdLine(T, arg);
        ts2.Date := 0;
        ts2.Time := 0;
        quo := False;
        if a > 2 then
          ts2 := DateTimeToTimeStamp(StrToDateTime(TScanThread(T).CmdParts[0] +
                   ' ' + TScanThread(T).CmdParts[1]))
        else
          if Pos('.', TScanThread(T).CmdParts[0]) > 0 then
            ts2 := DateTimeToTimeStamp(StrToDateTime(TScanThread(T).CmdParts[0]))
          else
            if Pos(':', TScanThread(T).CmdParts[0]) > 0 then
            begin
              quo := True;
              ts2 := DateTimeToTimeStamp(StrToDateTime(DateToStr(Date) + ' ' +
                       TScanThread(T).CmdParts[0]));
            end
            else
              if TryStrToInt64(TScanThread(T).CmdParts[0], i1) then
              begin
                ts2.Time := i1 and $FFFFFFFF;
                i1 := i1 shr 32;
                ts2.Date := i1 and $FFFFFFFF;
                if ts2.Date = 0 then
                begin
                  quo := True;
                  ts2.Date := DateTimeToTimeStamp(Date).Date;
                end;
              end;
        i1 := ts2.Date;
        i1 := (i1 shl 32) + ts2.Time;
        bFlag := False;
        case idx of
          $FB, $102:
            begin
              ts2.Date := 0;
              ts2.Time := 0;
              if a = 4 then
                ts2 := DateTimeToTimeStamp(StrToDateTime(
                         TScanThread(T).CmdParts[2] + ' ' +
                         TScanThread(T).CmdParts[3]))
              else
              begin
                s1 := TScanThread(T).CmdList[a];
                if Pos('.', s1) > 0 then
                  ts2 := DateTimeToTimeStamp(StrToDateTime(s1))
                else
                  if Pos(':', s1) > 0 then
                  begin
                    bFlag := True;
                    ts2 := DateTimeToTimeStamp(StrToDateTime(DateToStr(Date) +
                             ' ' + s1));
                  end
                  else
                    if TryStrToInt64(s1, i2) then
                    begin
                      ts2.Time := i2 and $FFFFFFFF;
                      i2 := i2 shr 32;
                      ts2.Date := i2 and $FFFFFFFF;
                    end;
              end;
              i2 := ts2.Date;
              i2 := (i2 shl 32) + ts2.Time;
            end;
          $109..$10F: ;
        else
          if not TryStrToInt(TScanThread(T).CmdList[a], nAdd) then
            nAdd := 0;
        end;
        case idx of
          $FB, $102:
            begin
              ts2.Time := i2 and $FFFFFFFF;
              i2 := i2 shr 32;
              ts2.Date := i2 and $FFFFFFFF;
              DecodeDateTime(TimeStampToDateTime(ts2), ebW.wYear, ebW.wMon, ebW.wDay,
                               ebW.wHour, ebW.wMin, ebW.wSec, ebW.wMSec);
              ts2.Time := i1 and $FFFFFFFF;
              i1 := i1 shr 32;
              ts2.Date := i1 and $FFFFFFFF;
              if idx = $102 then
              begin
                dtA := TimeStampToDateTime(ts2);
                nH := ebW.wHour;
                dtA := IncHour(dtA, -nH);
                nH := ebW.wMin;
                dtA := IncMinute(dtA, -nH);
                nH := ebW.wSec;
                dtA := IncSecond(dtA, -nH);
                if (quo = False) and (bFlag = False) then
                begin
                  nH := ebW.wYear;
                  dtA := IncYear(dtA, -nH);
                  nH := ebW.wMon;
                  dtA := IncMonth(dtA, -nH);
                  nH := ebW.wDay;
                  dtA := IncDay(dtA, -nH);
                end;
                ts2 := DateTimeToTimeStamp(dtA);
              end
              else
                if (quo = False) and (bFlag = False) then
                  ts2 := DateTimeToTimeStamp(IncSecond(IncMinute(IncHour(
                           IncDay(IncMonth(IncYear(TimeStampToDateTime(ts2),
                           ebW.wYear), ebW.wMon), ebW.wDay), ebW.wHour), ebW.wMin), ebW.wSec))
                else
                  ts2 := DateTimeToTimeStamp(IncSecond(IncMinute(IncHour(
                           TimeStampToDateTime(ts2), ebW.wHour), ebW.wMin), ebW.wSec));
              i1 := ts2.Date;
              if quo then
                i1 := ts2.Time
              else
                i1 := (i1 shl 32) + ts2.Time;
            end;
          $FC:
            ts2 := DateTimeToTimeStamp(IncYear(TimeStampToDateTime(ts2), nAdd));
          $FD:
            ts2 := DateTimeToTimeStamp(IncMonth(TimeStampToDateTime(ts2), nAdd));
          $FE:
            ts2 := DateTimeToTimeStamp(IncDay(TimeStampToDateTime(ts2), nAdd));
          $FF:
            ts2 := DateTimeToTimeStamp(IncHour(TimeStampToDateTime(ts2), nAdd));
          $100:
            ts2 := DateTimeToTimeStamp(IncMinute(TimeStampToDateTime(ts2), nAdd));
          $101:
            ts2 := DateTimeToTimeStamp(IncSecond(TimeStampToDateTime(ts2), nAdd));
          $103:
            ts2 := DateTimeToTimeStamp(IncYear(TimeStampToDateTime(ts2), -nAdd));
          $104:
            ts2 := DateTimeToTimeStamp(IncMonth(TimeStampToDateTime(ts2), -nAdd));
          $105:
            ts2 := DateTimeToTimeStamp(IncDay(TimeStampToDateTime(ts2), -nAdd));
          $106:
            ts2 := DateTimeToTimeStamp(IncHour(TimeStampToDateTime(ts2), -nAdd));
          $107:
            ts2 := DateTimeToTimeStamp(IncMinute(TimeStampToDateTime(ts2), -nAdd));
          $108:
            ts2 := DateTimeToTimeStamp(IncSecond(TimeStampToDateTime(ts2), -nAdd));
          $109:
            begin
              DecodeDate(TimeStampToDateTime(ts2), wA, wB, wC);
              i1 := wA;
            end;
          $10A:
            begin
              DecodeDate(TimeStampToDateTime(ts2), wA, wB, wC);
              i1 := wB;
            end;
          $10B:
            begin
              DecodeDate(TimeStampToDateTime(ts2), wA, wB, wC);
              i1 := wC;
            end;
          $10C:
            begin
              DecodeTime(TimeStampToDateTime(ts2), wA, wB, wC, wD);
              i1 := wA;
            end;
          $10D:
            begin
              DecodeTime(TimeStampToDateTime(ts2), wA, wB, wC, wD);
              i1 := wB;
            end;
          $10E:
            begin
              DecodeTime(TimeStampToDateTime(ts2), wA, wB, wC, wD);
              i1 := wC;
            end;
          $10F:
            begin
              quo := False;
              if a > 1 then
                ts2 := DateTimeToTimeStamp(StrToDateTime(
                         TScanThread(T).CmdParts[0] + ' ' +
                         TScanThread(T).CmdParts[1]))
              else
                if Pos('.', TScanThread(T).CmdParts[0]) > 0 then
                  ts2 := DateTimeToTimeStamp(StrToDateTime(
                           TScanThread(T).CmdParts[0]))
                else
                  if Pos(':', TScanThread(T).CmdParts[0]) > 0 then
                    ts2 := DateTimeToTimeStamp(StrToDateTime(DateToStr(Date) +
                             ' ' + TScanThread(T).CmdParts[0]))
                  else
                    if TryStrToInt64(TScanThread(T).CmdParts[0], i1) then
                    begin
                      ts2.Time := i1 and $FFFFFFFF;
                      i1 := i1 shr 32;
                      ts2.Date := i1 and $FFFFFFFF;
                      quo := True;
                    end;
              if quo then
              begin
                if ts2.Date = 0 then
                begin
                  ts2.Date := DateTimeToTimeStamp(Date).Date;
                  nm := TimeToStr(TimeStampToDateTime(ts2));
                end
                else
                  nm := DateTimeToStr(TimeStampToDateTime(ts2));
              end
              else
              begin
                i1 := ts2.Date;
                i1 := (i1 shl 32) + ts2.Time;
                nm := IntToStr(i1);
              end;
            end;
        end;
        case idx of
          $FC..$101, $103..$108:
            begin
              i1 := ts2.Date;
              if quo then
                i1 := ts2.Time
              else
                i1 := (i1 shl 32) + ts2.Time;
            end;
        end;
        if idx <> $10F then
          nm := IntToStr(i1);
        V := nm;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end
      else
      begin
        { `lastp` живёт в кадре, регистра ему тут не достаётся: ESI занят
          `pIns`, который становится живым ещё в начале ветки. }
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;

            end;
          272:
            begin { datenow }
      V := DateToStr(Date);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          273:
            begin { timenow }
      V := TimeToStr(Time);
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          284:
            begin { checkgetcolor }
      nAdd := p;
      qq := p;
      nn := Length(ts);
      bFlag := False;
      while (qq <= nn) and not (ts[qq] in (gWordCharsadq - ['(', ')'])) do
      begin
        if ts[qq] = '(' then
        begin
          bFlag := True;
          Break;
        end;
        Inc(qq);
      end;
      if bFlag then
      begin
        qq := 0;
        nn := 0;
        V := FindParenGroup(T, ts, p, qq, nn);
        if nn > 0 then
        begin
          Delete(ts, p, nn - p + 1);
          SplitCmdLine(T, 'calc ' + V);
          if TScanThread(T).InLua then
            TScanThread(T).CmdParts[3] := IntToStr(TScanThread(T).Args[1].Val);
          if TryStrToInt(EvalScriptExpr(T, 'calc ' +
               TScanThread(T).CmdParts[3], -1), qq) then
          begin
            ptC := Types.Point(0, 0);
            bFlag := False;
            while not bFlag do
            begin
              if qq = 0 then
                Break;
              bFlag := TryCaptureImage(T, HWND(qq));
              if not bFlag then
              begin
                if not GetWindowRect(qq, rcW) then
                begin
                  rcW.Left := 0;
                  rcW.Top := 0;
                end;
                Inc(ptC.X, rcW.Left);
                Inc(ptC.Y, rcW.Left);
                qq := GetParent(qq);
                if qq = 0 then
                  Break;
                GetWindowThreadProcessId(qq, PDWORD(@a));
                if Integer(TScanThread(T).ProcessId) <> Integer(a) then
                  Break;
              end;
            end;
            if bFlag then
            begin
              if TScanThread(T).InLua then
              begin
                TScanThread(T).LuaRes1 := ptC.X;
                TScanThread(T).LuaRes2 := ptC.Y;
                TScanThread(T).LuaRes3 := qq;
              end
              else
              begin
                nm := TScanThread(T).CmdParts[1];
                V := TScanThread(T).CmdParts[2];
                if (Length(nm) >= 2) and ((nm[1] = '#') or (nm[1] = '$')) and
                   (Length(V) >= 2) and ((V[1] = '#') or (V[1] = '$')) then
                begin
                  cK := nm[1];
                  Delete(nm, 1, 1);
                  p := FindScriptVar(T, cK, nm, a, rd);
                  nm := IntToStr(ptC.X);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm,
                                 a, rd);
                  cK := V[1];
                  Delete(V, 1, 1);
                  nm := V;
                  p := FindScriptVar(T, cK, nm, a, rd);
                  nm := IntToStr(ptC.Y);
                  StoreScriptVar(T, cK, p, TScanThread(T).CmdArg,
                                 TScanThread(T).ParenPos, nm,
                                 a, rd);
                end
                else
                  TScanThread(T).ClipLen := 2;
                V := IntToStr(qq);
              end;
            end
            else
              V := IntToStr(0);
          end;
        end
        else
          V := '-1';
        p := nAdd;
        Insert(V, ts, p);
        Inc(p, Length(V));
      end
      else
      begin
        Insert(w, ts, pIns);
        Inc(p, Length(w));
      end;

            end;
          285:
            begin { version }
      nm := 'r';
      V := '2.42|' + nm + '|' + '0' + '|' + '0' + '/';
      Insert(V, ts, p);
      Inc(p, Length(V));
            end;
          else
            begin { else }
      if (nm <> '') and (Pos('.', nm) <= 0) and
         (gCmdListah7.Objects[idx] is TMyStr) then
      begin
            V := PStrHoldZ(gCmdListah7.Objects[idx])^.Txt;
      s1 := '-1';
      qq := Pos(';', V);
      nP1 := 0;
      while qq > 0 do
      begin
        TScanThread(T).CmdArg := Copy(V, 1, qq - 1);
        nn := Pos(',', TScanThread(T).CmdArg);
        if not TryStrToInt64(Copy(TScanThread(T).CmdArg, 1, nn - 1), nVal) then
          nVal := 0;
        Delete(TScanThread(T).CmdArg, 1, nn);
        cK := TScanThread(T).CmdArg[1];
      nP1 := nP1 + nVal;
      if nP1 = 0 then
      begin
        s1 := '-1';
        Break;
      end
      else
        case cK of
          'b':
            begin
              ReadMemByName(TScanThread(T).ProcessHandle2, bF1, nVal,
                           nP1, 1, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              s1 := IntToStr(bF1);
            end;
          'w':
            begin
              ReadMemByName(TScanThread(T).ProcessHandle2, wF2, nVal,
                           nP1, 2, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              s1 := IntToStr(wF2);
            end;
          'd':
            begin
              if (Length(TScanThread(T).CmdArg) > 1) and
                 (TScanThread(T).CmdArg[2] = 'o') then
              begin
                ReadMemByName(TScanThread(T).ProcessHandle2, dblF, nVal,
                             nP1, 8, TScanThread(T).MemTarget,
                             TScanThread(T).ProcessId);
                s1 := FloatToStr(dblF);
              end;
              ReadMemByName(TScanThread(T).ProcessHandle2, nDW, nVal,
                           nP1, 4, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              nP1 := nDW;
              s1 := IntToStr(nDW);
            end;
          'l':
            begin
              ReadMemByName(TScanThread(T).ProcessHandle2, i64, nVal,
                           nP1, 8, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              nP1 := i64;
              s1 := IntToStr(i64);
            end;
          'f':
            begin
              ReadMemByName(TScanThread(T).ProcessHandle2, sngF, nVal,
                           nP1, 4, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              s1 := FloatToStr(sngF);
            end;
          'r':
            begin
              ReadMemByName(TScanThread(T).ProcessHandle2, rl48, nVal,
                           nP1, 6, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              s1 := FloatToStr(rl48);
            end;
          'c':
            begin
              ReadMemByName(TScanThread(T).ProcessHandle2, cF, nVal,
                           nP1, 1, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              s1 := cF;
            end;
          's':
            begin
              rd := StrToInt(TScanThread(T).MemTarget);
              TScanThread(T).MemTarget := AnsiLowerCase(
                EvalScriptExpr(T, sv, 4));
              if rd > $FF then
                rd := $FF;
              ReadMemByName(TScanThread(T).ProcessHandle2, sFind99C, nVal,
                           nP1, rd, TScanThread(T).MemTarget,
                           TScanThread(T).ProcessId);
              TScanThread(T).ClipLen := gMemLastErrorao;
              s1 := PChar(@sFind99C);
            end;
        else
          begin
            nVal := -2;
          end;
        end;
        Delete(V, 1, qq);
        qq := Pos(';', V);
      end;
      V := s1;
      Insert(V, ts, p);
      Inc(p, Length(V));
      end
      else
      begin
        ptC.X := 0;
        ptC.Y := 0;
        @TScanThread(T).PlugFunc := Pointer(gCmdListah7.Objects[idx]);
        if Assigned(TScanThread(T).PlugFunc) then
        begin
          V := FindParenGroup(T, ts, 1, ptC.X, ptC.Y);
          TScanThread(T).PlugProc := TScanThread(T).ClientWnd2;
          TScanThread(T).PlugPid := TScanThread(T).ProcessId;
          TScanThread(T).PlugStr1 :=
            PChar(EvalScriptExpr(T, 'calc ' + V, -1));
          TScanThread(T).PlugStr2 := PChar(V);
          TScanThread(T).PlugRec := @TScanThread(T).PlugRes;
          TScanThread(T).PlugRec^.Flag := 0;
          TScanThread(T).PlugRec^.Len := 0;
          TScanThread(T).PlugRec^.Ptr := Integer(PChar(''));
          FillChar(TScanThread(T).PlugBuf, $100001, 0);
          Delete(ts, p, ptC.Y - p + 1);
          TScanThread(T).PlugFunc(@TScanThread(T).PlugProc);
          if TScanThread(T).PlugRec^.Flag <> 0 then
          begin
            if Length(string(PChar(TScanThread(T).PlugRec^.Ptr))) >
               TScanThread(T).PlugRec^.Len then
              PChar(TScanThread(T).PlugRec^.Ptr)
                [TScanThread(T).PlugRec^.Len] := #0;
            V := string(PChar(TScanThread(T).PlugRec^.Ptr));
          end
          else
            V := TScanThread(T).PlugBuf;
          Insert(V, ts, p);
          Inc(p, Length(V));
        end
        else
          Insert(nm, ts, p);
      end;
            end;
          end;
          { общий хвост: галки группы miErrorReadCP }
          if fmSecondfj.miStopSErrorRead.Checked and err then
            T.StopRequested := True;
          if fmSecondfj.miPauseSErrorRead.Checked and err then
          begin
            if T.AutoStart then
              TScanThread(T).Synchronize(TScanThread(T).PauseScriptThread);
            T.Paused := True;
          end;
          if fmSecondfj.miInformErrorRead.Checked and err then
            if not bErrShown then
            begin
              bErrShown := True;
              SetForegroundWindow(TScanThread(T).ClientWnd2);
              SetForegroundWindow(Application.Handle);
              if gLangOffsety > 0 then
                MsgBox(PChar(LoadStr(gLangOffsety + $1C8)),
                       'UOPilot Error Message', $40000)
              else
                MsgBox('Ошибка чтения параметров чара',
                       'UOPilot Error Message', $40000);
            end;
        end
        { Это ветка `else` того же `if not quo`, а не отдельная проверка.
          Цикл -- сложное условие, вход через проверку внизу. }
        else
        begin
          q := Length(ts);
          while (p <= q) and (ts[p] <> '"') do
            Inc(p);
        end;
        lastp := p;
        Inc(p, Pos(nm, Copy(LowerCase(ts), p + 1, Length(ts) - p)));
      end;
    end;
    { ВЫХОД ПО `isop`, и он ВНУТРИ `if not isvar`, сразу за циклом по
      `gCmdListah7`. }
    if isop then
    begin
      Result := ts;
      Exit;
    end;
  end;
  { ДЕРЖАТЕЛЬ КАДРА -- только тем локалам, которым он нужен.
    Держит именно ВЗЯТИЕ АДРЕСА, а не `FillChar`: флаг ставит любое `@имя`,
    а вызов вчетверо дороже присваивания. При -$C- `Assert` не стоит ни
    одной команды. }
  Assert(@isvar <> nil);
  { ПРОХОД 1 по `#` и `$`. Вход в цикл -- переход на условие внизу.
    `sTail` -- приёмник, `nRep` -- счётчик 32 повторов.

    Сторож здесь -- ТОТ ЖЕ СПИСОК ПЯТИ ИМЁН, что и у прохода 2, целиком
    продублированный: при совпадении управление уходит прямо во вторую
    цепочку. }
  if ((tt <> 'set') and (tt <> 'for') and (tt <> 'exec') and
      (tt <> 'macro_load') and (tt <> 'terminate')) or (nv <> 1) then
  begin
    k := 1;
    quo := False;
    nRep := 32;
    sTail := ts;
    while Length(ts) > k do
    begin
      { Секция 1: сторожи и защита от зацикливания.
        Все три «Continue» -- вложенные `if`, а не оператор `Continue`:
        тот прыгнул бы на проверку и пропустил `Inc(k)`. `Break` при
        неизменившейся строке уходит за цикл. }
      if T.StopRequested then
      begin
        Result := '0';
        Exit;
      end;
      if ts[k] = '"' then
        quo := not quo;
      if not quo then
        if (ts[k] = '#') or (ts[k] = '$') then
          if ts[k + 1] in gWordCharsadq then
          begin
            if nRep > 0 then
              Dec(nRep)
            else
            begin
              if sTail = ts then
                Break;
              nRep := 32;
              sTail := ts;
            end;
            { Секция 2a: вид переменной, рекурсивный разбор имени и подготовка
              к разбору индекса. }
            cK := ts[k];
            tt := EvalScriptExpr(T, sv, 0);
            Inc(k);
            nm := '';
            p := Length(ts);
            bDot := False;
            { Секция 2b: сбор имени переменной до разделителя. Отсев разделителей --
              `case` по шести символам (диапазон '('..')' плюс четыре
              одиночных), а не `in`-множество. `except` пуст нарочно. }
            try
              while (k <= p) and (ts[k] in gWordCharsadq) do
              begin
                if ts[k] = '.' then
                  bDot := True;
                if (ts[k] = '#') or (ts[k] = '$') or (ts[k] = '%') then
                  if bDot then
                    bDot := False
                  else
                    Break;
                if ts[k] in ['(', ')', '[', ']', '{', '}'] then
                  Break;
                nm := nm + ts[k];
                Inc(k);
              end;
            except
            end;
            { Секция 3a: имя в нижний регистр, разбор
              «имя.индекс» для `#`. `sd` (-$98) -- строка головы. }
            nm := AnsiLowerCase(nm);
            p := 0;
            if cK = '#' then
            begin
              { Числовые переменные: поле `Vars`, элемент 264 байта
                (string[255] + Int64), подстановка через IntToStr. Зеркала
                с `$` нет: у него другое поле, другой шаг, другой тип
                значения и лишний Dec(k). }
              i := Pos('.', nm);
              if i > 0 then
              begin
                sd := nm;
                Delete(sd, 1, i);
                nm := Copy(nm, 1, i - 1);
                i := TScanThread(T).ScriptStrToInt(sd);
                while Length(gScriptso3[i].Vars) > p do
                begin
                  if gScriptso3[i].Vars[p].Name = nm then
                  begin
                    qq := Length(nm) + Length(sd) + 1;
                    k := k - qq - 1;
                    Delete(ts, k, qq + 1);
                    Insert(IntToStr(gScriptso3[i].Vars[p].Value), ts, k);
                    if T.SubstAdvance then
                      Inc(k, Length(IntToStr(gScriptso3[i].Vars[p].Value)));
                    goto NextChar;
                  end;
                  Inc(p);
                end;
              end
              else
                while Length(T.Vars) > p do
                begin
                  if T.Vars[p].Name = nm then
                  begin
                    qq := Length(nm);
                    k := k - qq - 1;
                    Delete(ts, k, qq + 1);
                    Insert(IntToStr(T.Vars[p].Value), ts, k);
                    if T.SubstAdvance then
                      Inc(k, Length(IntToStr(T.Vars[p].Value)));
                    goto NextChar;
                  end;
                  Inc(p);
                end;
            end
            else if cK = '$' then
            begin
              { Строковые переменные: поле +$44, элемент 260
                (string[255] + string), значение идёт в Insert НАПРЯМУЮ,
                и после вставки Dec(k). }
              i := Pos('.', nm);
              if i > 0 then
              begin
                sd := nm;
                Delete(sd, 1, i);
                nm := Copy(nm, 1, i - 1);
                i := TScanThread(T).ScriptStrToInt(sd);
                while Length(gScriptso3[i].Timers) > p do
                begin
                  if gScriptso3[i].Timers[p].Name = nm then
                  begin
                    qq := Length(nm) + Length(sd) + 1;
                    k := k - qq - 1;
                    Delete(ts, k, qq + 1);
                    Insert(gScriptso3[i].Timers[p].Value, ts, k);
                    Dec(k);
                    if T.SubstAdvance then
                      Inc(k, Length(gScriptso3[i].Timers[p].Value));
                    goto NextChar;
                  end;
                  Inc(p);
                end;
              end
              else
                while Length(T.Timers) > p do
                begin
                  if T.Timers[p].Name = nm then
                  begin
                    qq := Length(nm);
                    k := k - qq - 1;
                    Delete(ts, k, qq + 1);
                    Insert(T.Timers[p].Value, ts, k);
                    Dec(k);
                    if T.SubstAdvance then
                      Inc(k, Length(T.Timers[p].Value));
                    goto NextChar;
                  end;
                  Inc(p);
                end;
            end;
          end;
NextChar:
      Inc(k);
    end;
  end;
  { ПРОХОД 2: МАТРИЧНЫЕ ПЕРЕМЕННЫЕ `%имя[индекс]`.

    Список ПЯТИ имён -- не `Exit`, а сторож прохода: управление уходит не в
    эпилог, а на общую концовку, то есть проход 2 просто пропускается.
    Условие -- `(and-цепочка) or (nv <> 1)`, а не двухуровневый `if`.

    Цикл идёт СПРАВА НАЛЕВО: счётчик `q` от Length(ts) вниз, на каждом шаге
    `k := q`. Это `if ... then repeat ... until`, а не `for ... downto`:
    проверка стоит и на входе, и в подвале.

    Массивы -- поле `Arr48`, элемент `TvArray` 260 байт. Данные двумерные
    и НУЛЬ-БАЗНЫЕ: при счёте с единицы адресация идёт со сдвигом.
    Разделитель при склейке всей строки -- `Str1048B8`. }
  if ((tt <> 'set') and (tt <> 'for') and (tt <> 'exec') and
      (tt <> 'macro_load') and (tt <> 'terminate')) or (nv <> 1) then
  begin
    q := Length(ts);
    quo := False;
    if q > 0 then
      repeat
        k := q;
        if ts[k] = '"' then
          quo := not quo;
        if not quo then
          if ts[k] = '%' then
            if ts[k + 1] in gWordCharsadq then
            begin
              { Сбор имени. В отличие от прохода 1 здесь НЕТ
                `bDot`: отсев '#', '$' и '%' стоит в УСЛОВИИ цикла, а не в
                теле, и только скобки уходят через `case`. }
              cK := ts[k];
              tt := EvalScriptExpr(T, sv, 0);
              Inc(k);
              nm := '';
              p := Length(ts);
              try
                while (k <= p) and (ts[k] in gWordCharsadq) and (ts[k] <> '#')
                      and (ts[k] <> '$') and (ts[k] <> '%') do
                begin
                  if ts[k] in ['(', ')', '[', ']', '{', '}'] then
                    Break;
                  nm := nm + ts[k];
                  Inc(k);
                end;
              except
              end;
              p := 0;
              if cK = '%' then
              begin
                { Имя уходит в `V`, а `nm` собирается заново:
                  в нём теперь индексное выражение, до закрывающей ']'. }
                V := AnsiLowerCase(nm);
                nm := '';
                while (Length(ts) >= k) and (ts[k] <> ']') do
                begin
                  nm := nm + ts[k];
                  Inc(k);
                end;
                if (Length(ts) >= k) and (ts[k] = ']') then
                begin
                  { «имя.скрипт»: номер чужого скрипта в `i`, иначе -1. Длины
                    считаются ДВАЖДЫ -- двумя отдельными выражениями, а не
                    одним общим. }
                  i := Pos('.', V);
                  if i > 0 then
                  begin
                    sd := V;
                    Delete(sd, 1, i);
                    V := Copy(V, 1, i - 1);
                    i := TScanThread(T).ScriptStrToInt(sd);
                  end
                  else
                    i := -1;
                  lastp := k - (Length(nm) + Length(V) + 1);
                  sdi := Length(nm) + Length(V) + 1 + 1;
                  if i >= 0 then
                  begin
                    Dec(lastp, Length(sd) + 1);
                    Inc(sdi, Length(sd) + 1);
                  end;
                  Delete(ts, lastp, sdi);
                  sdi := lastp;
                  { Разбор индекса: первое число уходит в
                    `lastp`, второе (необязательное) остаётся строкой в
                    `sd`. Пустой `sd` значит «вся строка целиком». }
                  while (Length(nm) > 0) and not (nm[1] in ['0'..'9']) do
                    Delete(nm, 1, 1);
                  sd := '';
                  while (Length(nm) > 0) and (nm[1] in ['0'..'9']) do
                  begin
                    sd := sd + nm[1];
                    Delete(nm, 1, 1);
                  end;
                  lastp := StrToInt(sd);
                  try
                    while (Length(nm) > 0) and not (nm[1] in ['0'..'9']) do
                      Delete(nm, 1, 1);
                    sd := '';
                    while (Length(nm) > 0) and (nm[1] in ['0'..'9']) do
                    begin
                      sd := sd + nm[1];
                      Delete(nm, 1, 1);
                    end;
                  except
                    sd := '';
                  end;
                  if i < 0 then
                  begin
                    { СВОЙ поток: обе границы проверяются }
                    while Length(T.Arr48) > p do
                    begin
                      if T.Arr48[p].Name = V then
                      begin
                        if Length(T.Arr48[p].Data) >= lastp then
                          if sd = '' then
                          begin
                            for qq := 1 to Length(T.Arr48[p].Data[lastp - 1]) do
                            begin
                              if qq > 1 then
                                sd := sd + T.Str1048B8;
                              sd := sd + T.Arr48[p].Data[lastp - 1][qq - 1];
                            end;
                          end
                          else if Length(T.Arr48[p].Data[lastp - 1]) >=
                                  StrToInt(sd) then
                            sd := T.Arr48[p].Data[lastp - 1][StrToInt(sd) - 1]
                          else
                            sd := ''
                        else
                          sd := '';
                        Insert(sd, ts, sdi);
                        Break;
                      end;
                      Inc(p);
                    end;
                  end
                  else
                    { ЧУЖОЙ скрипт: проверок границ НЕТ, и сторож разделителя
                      другой -- `sd <> ''` вместо `qq > 1`. }
                    while Length(gScriptso3[i].Arr48) > p do
                    begin
                      if gScriptso3[i].Arr48[p].Name = V then
                      begin
                        if sd = '' then
                        begin
                          for qq := 1 to
                              Length(gScriptso3[i].Arr48[p].Data[lastp - 1]) do
                          begin
                            if sd <> '' then
                              sd := sd + T.Str1048B8;
                            sd := sd +
                              gScriptso3[i].Arr48[p].Data[lastp - 1][qq - 1];
                          end;
                        end
                        else
                          sd := gScriptso3[i].Arr48[p].Data[lastp - 1]
                                  [StrToInt(sd) - 1];
                        Insert(sd, ts, sdi);
                        Break;
                      end;
                      Inc(p);
                    end;
                end;
              end;
            end;
        Dec(q);
      until q <= 0;
  end;
  { ОБЩАЯ КОНЦОВКА. Сюда же приходит пропуск прохода 2. }
  if nv = 0 then
    Result := AnsiLowerCase(ts)
  else
  begin
    { Снятие обрамляющих кавычек, но только если внутри
      кавычек больше нет. }
    qq := Length(ts);
    if qq > 1 then
      if ts[1] = '"' then
        if ts[qq] = '"' then
        begin
          tt := Copy(ts, 2, qq - 2);
          if Pos('"', tt) = 0 then
            ts := tt;
        end;
    { Ведущий ноль без 'x' достраивается до '0x'. Здесь именно `LowerCase`,
      а не `AnsiLowerCase`. }
    if nv > 0 then
      { Сравнение С ЕДИНИЦЕЙ, а не вычитание: `Length(X) > 1` даёт две
        команды, `Length(X) - 1 > 0` -- три. Тот же случай, что в ветке 'd'
        у `writemem`/`readmem`. }
      if Length(ts) > 1 then
        if ts[1] = '0' then
          if LowerCase(ts[2]) <> 'x' then
            ts := '0x' + ts;
    Result := ts;
  end;
end;

procedure ScanSplitGuardZ;
var
  a: Unit1.TRxHintWindow;
  b: TRxHintWindowRef;
begin
  a := nil;
  b := a;
  a := b;
end;

procedure SayText(T: TScanThread; S: string);
var
  sKL: string;
  bufKL: array[0..$FF] of Char;
  nI: Integer;
  nU, nL: Integer;
begin
  GetKeyboardLayoutName(bufKL);
  sKL := bufKL;
  if sKL <> gKbdLayoutow then
    LoadKeyboardLayout(StrCopy(bufKL, PChar(gKbdLayoutow)), 1);
  for nI := 1 to Length(S) do
  begin
    nU := Ord(UpCase(S[nI]));
    nL := MapVirtualKey(nU, 0);
    SendMessage(T.ClientWnd2, $102, Byte(S[nI]), nL shl 16 + Integer($C0000001));
  end;
  SendMessage(T.ClientWnd2, $102, $D, 0);
  if sKL <> gKbdLayoutow then
    LoadKeyboardLayout(StrCopy(bufKL, '00000409'), 1);
end;

procedure ScSetCl(T: TScanThread; G: TGridCracker; S: string; A: Cardinal);
var
  nV: Cardinal;
  nRow: Cardinal;
begin
  if (Length(S) > 1) and (S[1] = '0') and (LowerCase(S[2]) <> 'x') then
    S := '0x' + S;
  nV := StrToInt64(S);
  { ДВА ВЛОЖЕННЫХ `if` ВМЕСТО `and`: код тот же (короткое замыкание), но
    цена уровня внутри вдвое ниже, и довод `G` обгоняет счётчик цикла в
    раздаче регистров. }
  if G <> nil then
  if nV <= $226 then
  begin
    for nRow := 0 to G.RowCount - 1 do
      if S = G.Cells[0, nRow] then
        Break;
    if S <> G.Cells[0, nRow] then
    begin
      if gLangOffsety > 0 then
        T.Msg := LoadStr(gLangOffsety + $1C9) + S + LoadStr(gLangOffsety + $1CA) + #0
      else
        T.Msg := 'Запись с указанным номером (' + S + ') не найдена.' + #0;
      ShowScriptMsg(T);
      if T.ToMsgBox then
      begin
        T.StopRequested := True;
        T.Flag91 := False;
        Exit;
      end;
    end;
    S := G.Cells[1, nRow];
    if (Length(S) > 1) and (S[1] = '0') and (LowerCase(S[2]) <> 'x') then
      S := '0x' + S;
    try
      nV := StrToInt64(S);
    except
      nV := 0;
    end;
  end;
  WriteProcessMemory(T.ClProc, Pointer(A), @nV, 4, nRow);
end;

function GetWord(T: TScanThread; const S: string; N: Integer): string;
begin
  Result := S;
end;

function TScanThread.ScriptStrToInt(S: string): Integer;
var
  C: Char;
  X, Y: Integer;
begin
  if not TryStrToInt(S, Result) then
  begin
    if Length(S) > 1 then
    begin
      C := S[1];
      Delete(S, 1, 1);
      X := 0;
      Y := 0;
      case C of
        '#':
          Result := Self.Vars[FindScriptVar(Self, C, S, X, Y)].Value;
        '$':
          Result := StrToInt(Self.Timers[FindScriptVar(Self, C, S, X, Y)].Value);
      end;
    end
    else
      Result := -1;
  end;
end;

function FindScriptVar(T: TScanThread; C: Char; Name: string;
  X, Y: Integer): Integer;
var
  DX, DY, L, Grow, Idx: Integer;
  { Потомок ОДНИМ присваиванием, дальше по телу ходит только он. Жёсткое
    приведение прямо в месте вызова ломает нумерацию значений и добавляет
    лишний `mov`. Команд локал не стоит -- параметр и так кладётся сюда в
    прологе. }
  TS: TScanThread;
begin
  TS := TScanThread(T);
  case C of
    '%':
      begin
        DX := X;
        DY := Y;
        Result := Pos('.', Name);
        TS.ParenPos := Result;
        if Result > 0 then
        begin
          TS.CmdArg2 := Name;
          Delete(TS.CmdArg2, 1, TS.ParenPos);
          Name := Copy(Name, 1, TS.ParenPos - 1);
          L := TS.ParenPos;
          Idx := TS.ScriptStrToInt(TS.CmdArg2);
          TS.ParenPos := L;
        end
        else
          Idx := -1;
        Result := 0;
        Name := AnsiLowerCase(Name);
        if TS.ParenPos > 0 then
        begin
          while Result < Length(gScriptso3[Idx].Arr48) do
          begin
            if gScriptso3[Idx].Arr48[Result].Name = Name then
              Break;
            Inc(Result);
          end;
          if Result >= Length(gScriptso3[Idx].Arr48) then
          begin
            SetLength(gScriptso3[Idx].Arr48, Length(gScriptso3[Idx].Arr48) + 1);
            gScriptso3[Idx].Arr48[Result].Name := Name;
          end;
          Grow := 0;
          L := Length(gScriptso3[Idx].Arr48[Result].Data);
          if DX < L then
            DX := L
          else
            Grow := 1;
          if L > 0 then
            L := Length(gScriptso3[Idx].Arr48[Result].Data[0]);
          if DY < L then
            DY := L
          else
            Grow := 1;
          if Grow > 0 then
            SetLength(gScriptso3[Idx].Arr48[Result].Data, DX, DY);
        end
        else
        begin
          while Result < Length(TS.Arr48) do
          begin
            if TS.Arr48[Result].Name = Name then
              Break;
            Inc(Result);
          end;
          if Result >= Length(TS.Arr48) then
          begin
            SetLength(TS.Arr48, Length(TS.Arr48) + 1);
            TS.Arr48[Result].Name := Name;
          end;
          Grow := 0;
          L := Length(TS.Arr48[Result].Data);
          if DX <= L then
            DX := L
          else
            Grow := 1;
          if L > 0 then
          begin
            L := Length(TS.Arr48[Result].Data[0]);
            if DY <= L then
              DY := L
            else
              Grow := 1;
          end;
          if Grow > 0 then
            SetLength(TS.Arr48[Result].Data, DX, DY);
        end;
      end;
    '#':
      begin
        Idx := Pos('.', Name);
        TS.ParenPos := Idx;
        Result := 0;
        if Idx > 0 then
        begin
          TS.CmdArg := Name;
          Delete(TS.CmdArg, 1, TS.ParenPos);
          Name := Copy(Name, 1, TS.ParenPos - 1);
          TS.CmdArg2 := EvalScriptExpr(TS, 'calc ' + TS.CmdArg, -1);
          Idx := TS.ScriptStrToInt(TS.CmdArg2);
          while Result < Length(gScriptso3[Idx].Vars) do
          begin
            if gScriptso3[Idx].Vars[Result].Name = AnsiLowerCase(Name) then
              Break;
            Inc(Result);
          end;
          if Result < Length(gScriptso3[Idx].Vars) then
            Exit;
          SetLength(gScriptso3[Idx].Vars, Length(gScriptso3[Idx].Vars) + 1);
          gScriptso3[Idx].Vars[Result].Name := LowerCase(Name);
          gScriptso3[Idx].VarNames.Add('#' + gScriptso3[Idx].Vars[Result].Name);
        end
        else
        begin
          while Result < Length(TS.Vars) do
          begin
            if TS.Vars[Result].Name = LowerCase(Name) then
              Break;
            Inc(Result);
          end;
          if Result < Length(TS.Vars) then
            Exit;
          SetLength(TS.Vars, Length(TS.Vars) + 1);
          TS.Vars[Result].Name := LowerCase(Name);
          if TS.AutoStart and TS.ShowRun then
          begin
            TS.VarGridBusy := True;
            TS.VarRow := Result + 1;
            TS.VarName := '#' + TS.Vars[Result].Name;
            TS.Synchronize(TS.SyncUpdateVarGrid);
          end;
        end;
      end;
    '$':
      begin
        Idx := Pos('.', Name);
        TS.ParenPos := Idx;
        Result := 0;
        if Idx > 0 then
        begin
          TS.CmdArg := Name;
          Delete(TS.CmdArg, 1, TS.ParenPos);
          Name := Copy(Name, 1, TS.ParenPos - 1);
          TS.CmdArg := EvalScriptExpr(TS, 'calc ' + TS.CmdArg, -1);
          Idx := TS.ScriptStrToInt(TS.CmdArg);
          while Result < Length(gScriptso3[Idx].Timers) do
          begin
            if gScriptso3[Idx].Timers[Result].Name = AnsiLowerCase(Name) then
              Break;
            Inc(Result);
          end;
          if Result < Length(gScriptso3[Idx].Timers) then
            Exit;
          SetLength(gScriptso3[Idx].Timers, Length(gScriptso3[Idx].Timers) + 1);
          gScriptso3[Idx].Timers[Result].Name := LowerCase(Name);
          gScriptso3[Idx].VarNames.Add('$' + gScriptso3[Idx].Timers[Result].Name);
        end
        else
        begin
          while Result < Length(TS.Timers) do
          begin
            if TS.Timers[Result].Name = LowerCase(Name) then
              Break;
            Inc(Result);
          end;
          if Result < Length(TS.Timers) then
            Exit;
          SetLength(TS.Timers, Length(TS.Timers) + 1);
          TS.Timers[Result].Name := LowerCase(Name);
          if TS.AutoStart and TS.ShowRun then
          begin
            TS.VarGridBusy := True;
            TS.VarRow := Result + 1;
            TS.VarName := '$' + TS.Timers[Result].Name;
            TS.Synchronize(TS.SyncUpdateVarGrid);
          end;
        end;
      end;
  else
    Result := 0;
  end;
end;

procedure StoreScriptVar(T: TScanThread; C: Char; Idx: Integer; Res: string;
  Cnt: Integer; W: string; X, Y: Integer);
var
  DX: Integer;
  DY: Integer;
  Grow: Integer;
  L: Integer;
  TS: TScanThread;             { потомок без приведения }
begin
  TS := TScanThread(T);
  try
    if Cnt > 0 then
    begin
      Cnt := TS.ScriptStrToInt(Res);
      case C of
        '%':
          begin
            Grow := 0;
            DX := X;
            DY := Y;
            L := Length(gScriptsS[Cnt].Arr48[Idx].Data);
            if L >= DX then
              DX := L
            else
              Grow := 1;
            if L > 0 then
            begin
              L := Length(gScriptsS[Cnt].Arr48[Idx].Data[0]);
              if L >= DY then
                DY := L
              else
                Grow := 1;
            end;
            if Grow > 0 then
              SetLength(gScriptsS[Cnt].Arr48[Idx].Data, DX, DY);
            gScriptsS[Cnt].Arr48[Idx].Data[X - 1][Y - 1] := W;
          end;
        '#':
          begin
            gScriptsS[Cnt].Vars[Idx].Value := StrToInt64Def(W, 0);
            if gScriptsS[Cnt].AutoStart and gScriptsS[Cnt].ShowRun then
            begin
                if gScriptsS[Cnt].Name <> IntToStr(Cnt) then
                  gScriptsS[Cnt].VarNameNew := True;
                gScriptsS[Cnt].VarRow := Idx + 1;
                gScriptsS[Cnt].VarValue := IntToStr(gScriptsS[Cnt].Vars[Idx].Value);
                gScriptsS[Cnt].VarName := '#' + gScriptsS[Cnt].Vars[Idx].Name;
                TS.Synchronize(gScriptsS[Cnt].SyncUpdateVarGrid);
              end;
          end;
        '$':
          begin
            gScriptsS[Cnt].Timers[Idx].Value := W;
            if gScriptsS[Cnt].AutoStart and gScriptsS[Cnt].ShowRun then
            begin
                if gScriptsS[Cnt].Name <> IntToStr(Cnt) then
                  gScriptsS[Cnt].VarNameNew := True;
                gScriptsS[Cnt].VarRow := Idx + 1;
                gScriptsS[Cnt].VarValue := gScriptsS[Cnt].Timers[Idx].Value;
                gScriptsS[Cnt].VarName := '$' + gScriptsS[Cnt].Timers[Idx].Name;
                gScriptsS[Cnt].Synchronize(gScriptsS[Cnt].SyncUpdateVarGrid);
              end;
          end;
      end;
    end
    else
      case C of
        '%':
          begin
            Grow := 0;
            DX := X;
            DY := Y;
            L := Length(TS.Arr48[Idx].Data);
            if L >= DX then
              DX := L
            else
              Grow := 1;
            if L > 0 then
            begin
              L := Length(TS.Arr48[Idx].Data[0]);
              if L >= DY then
                DY := L
              else
                Grow := 1;
            end;
            if Grow > 0 then
              SetLength(TS.Arr48[Idx].Data, DX, DY);
            TS.Arr48[Idx].Data[X - 1][Y - 1] := W;
          end;
        '#':
          begin
            TS.Vars[Idx].Value := StrToInt64Def(W, 0);
            if TS.AutoStart and TS.ShowRun then
            begin
                TS.VarRow := Idx + 1;
                TS.VarValue := IntToStr(TS.Vars[Idx].Value);
                TS.VarName := '#' + TS.Vars[Idx].Name;
                TS.Synchronize(TS.SyncUpdateVarGrid);
              end;
          end;
        '$':
          begin
            TS.Timers[Idx].Value := W;
            if TS.AutoStart and TS.ShowRun then
            begin
                TS.VarRow := Idx + 1;
                TS.VarValue := TS.Timers[Idx].Value;
                TS.VarName := '$' + TS.Timers[Idx].Name;
                TS.Synchronize(TS.SyncUpdateVarGrid);
              end;
          end;
      end;
  except
  end;
end;

function GetArraySize(T: TScanThread; S: string; var A: Cardinal;
                      var C: Cardinal; B: Boolean): Boolean;
var
  k, i, p: Integer;
  s2: string;
begin
  { Это не опечатка и не пустая строка. Присваивание себе не даёт ни одной
    команды, но даёт `T` ещё одно тарифицируемое употребление -- только с
    ним ESI достаётся `T`, а EDI -- `k`. Без него веса расходятся на
    единицу и регистры зеркалятся. }
  T := T;
  Result := False;
  k := -1;
  p := Pos('.', S);
  if p > 0 then
  begin
    s2 := S;
    Delete(s2, 1, p);
    S := Copy(S, 1, p - 1);
    k := TScanThread(T).ScriptStrToInt(s2);
  end;
  i := 0;
  S := AnsiLowerCase(S);
  if p > 0 then
  begin
    while i < Length(gScriptso3[k].Arr48) do
    begin
      if gScriptso3[k].Arr48[i].Name = S then
        Break;
      Inc(i);
    end;
    if i < Length(gScriptso3[k].Arr48) then
    begin
      if B then
        SetLength(gScriptso3[k].Arr48[i].Data, A, C)
      else
      begin
        A := Length(gScriptso3[k].Arr48[i].Data);
        if A > 0 then
          C := Length(gScriptso3[k].Arr48[i].Data[0])
        else
          C := 0;
      end;
      Result := True;
    end;
  end
  else
  begin
    while i < Length(T.Arr48) do
    begin
      if T.Arr48[i].Name = S then
        Break;
      Inc(i);
    end;
    if i < Length(T.Arr48) then
    begin
      if B then
        SetLength(T.Arr48[i].Data, A, C)
      else
      begin
        A := Length(T.Arr48[i].Data);
        if A > 0 then
          C := Length(T.Arr48[i].Data[0])
        else
          C := 0;
      end;
      Result := True;
    end;
  end;
end;

procedure SortScriptArray(T: TScanThread; N, M, H, D, I: Integer;
                          Asc: Boolean);
var
  nJ, nK: Integer;
  sPv, sT: string;
  nPv, nV: Integer;
  nI: Integer;
  bC: Boolean;
begin
  while M <> H do
  begin
    nI := M;
    nJ := H;
    sPv := T.Arr48[N].Data[(nJ + nI) div 2][D];
    repeat
      if TryStrToInt(sPv, nPv) then
      begin
        if Asc then
        begin
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[nI][D], nV) then
              bC := nV < nPv
            else
              bC := T.Arr48[N].Data[nI][D] < sPv;
            if bC then
              Inc(nI);
          end;
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[nJ][D], nV) then
              bC := nV > nPv
            else
              bC := T.Arr48[N].Data[nJ][D] > sPv;
            if bC then
              Dec(nJ);
          end;
        end
        else
        begin
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[nI][D], nV) then
              bC := nV > nPv
            else
              bC := T.Arr48[N].Data[nI][D] > sPv;
            if bC then
              Inc(nI);
          end;
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[nJ][D], nV) then
              bC := nV < nPv
            else
              bC := T.Arr48[N].Data[nJ][D] < sPv;
            if bC then
              Dec(nJ);
          end;
        end;
      end
      else if Asc then
      begin
        while T.Arr48[N].Data[nI][D] < sPv do
          Inc(nI);
        while T.Arr48[N].Data[nJ][D] > sPv do
          Dec(nJ);
      end
      else
      begin
        while T.Arr48[N].Data[nI][D] > sPv do
          Inc(nI);
        while T.Arr48[N].Data[nJ][D] < sPv do
          Dec(nJ);
      end;
      if nI <= nJ then
      begin
        for nK := 0 to Length(T.Arr48[N].Data[nI]) - 1 do
        begin
          sT := T.Arr48[N].Data[nI][nK];
          T.Arr48[N].Data[nI][nK] := T.Arr48[N].Data[nJ][nK];
          T.Arr48[N].Data[nJ][nK] := sT;
        end;
        Inc(nI);
        Dec(nJ);
      end;
    until nI > nJ;
    if nJ - M < H - nI then
    begin
      if M < nJ then
        SortScriptArray(T, N, M, nJ, D, I, Asc);
      M := nI;
    end
    else
    begin
      if nI < H then
        SortScriptArray(T, N, nI, H, D, I, Asc);
      H := nJ;
    end;
  end;
end;

procedure SortScriptArray2(T: TScanThread; N, M, H, I, D: Integer;
                           Asc: Boolean);
var
  { nI объявлен ПЕРВЫМ: веса у nI и nJ здесь равны (в отличие от
    SortScriptArray, где nI читает ещё и Length(Data[nI])), а при равных
    весах регистр достаётся тому, кто объявлен раньше. }
  nI: Integer;
  nJ, nK: Integer;
  sPv, sT: string;
  nPv, nV: Integer;
  bC: Boolean;
begin
  while M <> H do
  begin
    nI := M;
    nJ := H;
    sPv := T.Arr48[N].Data[D][(nJ + nI) div 2];
    repeat
      if TryStrToInt(sPv, nPv) then
      begin
        if Asc then
        begin
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[D][nI], nV) then
              bC := nV < nPv
            else
              bC := T.Arr48[N].Data[D][nI] < sPv;
            if bC then
              Inc(nI);
          end;
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[D][nJ], nV) then
              bC := nV > nPv
            else
              bC := T.Arr48[N].Data[D][nJ] > sPv;
            if bC then
              Dec(nJ);
          end;
        end
        else
        begin
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[D][nI], nV) then
              bC := nV > nPv
            else
              bC := T.Arr48[N].Data[D][nI] > sPv;
            if bC then
              Inc(nI);
          end;
          bC := True;
          while bC do
          begin
            if TryStrToInt(T.Arr48[N].Data[D][nJ], nV) then
              bC := nV < nPv
            else
              bC := T.Arr48[N].Data[D][nJ] < sPv;
            if bC then
              Dec(nJ);
          end;
        end;
      end
      else if Asc then
      begin
        while T.Arr48[N].Data[D][nI] < sPv do
          Inc(nI);
        while T.Arr48[N].Data[D][nJ] > sPv do
          Dec(nJ);
      end
      else
      begin
        while T.Arr48[N].Data[D][nI] > sPv do
          Inc(nI);
        while T.Arr48[N].Data[D][nJ] < sPv do
          Dec(nJ);
      end;
      if nI <= nJ then
      begin
        for nK := 0 to Length(T.Arr48[N].Data) - 1 do
        begin
          sT := T.Arr48[N].Data[nK][nI];
          T.Arr48[N].Data[nK][nI] := T.Arr48[N].Data[nK][nJ];
          T.Arr48[N].Data[nK][nJ] := sT;
        end;
        Inc(nI);
        Dec(nJ);
      end;
    until nI > nJ;
    if nJ - M < H - nI then
    begin
      if M < nJ then
        SortScriptArray2(T, N, M, nJ, I, D, Asc);
      M := nI;
    end
    else
    begin
      if nI < H then
        SortScriptArray2(T, N, nI, H, I, D, Asc);
      H := nJ;
    end;
  end;
end;

{ Массив плюс цикл на `goto` в `CheckOneExpr` -- то единственное
  сочетание, которое даёт сразу и слитую чистку одним FinalizeArray, и
  прямые обращения к глобалям. Надбавка за цикл привязана к структурному
  виду (`repeat`/`while`/`for`), а не к обратной дуге графа, поэтому форма
  `goto` не стоит ни одного байта. }

procedure WaitDelayStub(const S: string);
begin
end;

procedure ExecScriptCommand(T: TScanThread; var N: Integer;
  var S: string);
{ кадр СВЕДЁН В ЗАПИСИ: поле записи для распределителя регистров
  символом не считается, и потолок в 127 символов перестаёт вытеснять
  временные. }
type
  TFzZ0 = packed record
    v108      : array[1..252] of Byte;
    v00C      : Integer;
  end;
  { `pWide` вынесен отсюда в обычный локал: записанное значение держится в
    регистре только когда цель -- ПОЛЕ ЗАПИСИ, а у обычного локала слот
    честно перечитывается. Слот при этом тот же. }
  TFzZ2 = packed record
    bF        : Boolean;
    v12C      : Integer;
    v128      : array[1..3] of Byte;
  end;
  TFzZ3 = packed record
    nL        : Integer;
    nK        : Integer;
    { сюда пишет `WaitDelay` -- начало отсчёта паузы, ровно как `WaitStart`
      у сестры `TScanThread.DoWait` в Unit1 }
    nWaitStart: Cardinal;
  end;
  TFzZ5 = packed record
    nTo       : Integer;
    nStart    : Cardinal;
  end;
  TFzZ6 = packed record
    v184      : Integer;
    nColor    : Cardinal;
  end;
  TFzZ7 = packed record
    nDY1      : Integer;
    nDX0      : Integer;
    nDY0      : Integer;
    ptSave    : TPoint;
    ptMv      : TPoint;
    pRes      : Pointer;
    nv        : Integer;
    pzZ24: array[1..2] of Byte;
  end;
  TFzZ8 = packed record
    vA        : Integer;
    vB        : Integer;
    vC        : Integer;
    vD        : Integer;
    vE        : Integer;
    vF        : Integer;
    nSw       : Integer;
    nFor      : Integer;
    nRep      : Integer;
    pzZ24: array[1..2] of Byte;
    wv        : Word;
    grid      : TObject;
  end;
  TFzZ9 = packed record
    bv        : Byte;
  end;
  TFzZ10 = packed record
    nRows     : Integer;
    nPos2     : Integer;
  end;
  TFzZ11 = packed record
    mB        : Integer;
    wF214     : Word;
    pzZ6: array[1..1] of Byte;
    bF211     : Byte;
    ptFr      : TPoint;
    ptTo      : TPoint;
  end;
  TFzZ12 = packed record
    bAppend   : Boolean;
    bOwn      : Boolean;
    v26C      : Integer;
    v268      : array[1..8] of Byte;
    pc        : Int64;
    vNum      : Int64;
    dc        : Integer;
    hW        : Integer;
    qErr      : Int64;
    qAddr     : Int64;
    qC        : Int64;
  end;
  { ЗАКРЕПЛЁННАЯ ЧАСТЬ: держалка в DeadFrame3Z оставлена, поэтому слот
    выдаётся В ПОРЯДКЕ ОБЪЯВЛЕНИЯ. }
  TFzZ13 = packed record
    v2AC      : array[1..24] of Byte;
    nPid      : Cardinal;
    hProc     : THandle;
  end;
  { ОТЛОЖЕННАЯ ЧАСТЬ: крупнее восьми байт и БЕЗ ДЕРЖАЛКИ, поэтому слот ей
    выдаётся ПОСЛЕ объекта `on E:`, а не по порядку объявления -- этим и
    освобождается место под сам объект исключения. Вариантная часть даёт
    второе имя тому же слоту вместо `absolute`. }
  TFzZ13B = packed record
    case Integer of
      0: (pK    : PStrPtr;
          pName : PStrPtr;
          pB2   : PByteArray);
      1: (pCode : PByte);              { тот же слот другим типом }
  end;
  TFzZ14 = packed record
    rLnk      : TLnkRec;               { ровно до PI }
    PI        : TProcessInformation;
    SI        : TStartupInfo;
    rcLeft    : Integer;
    rcTop     : Integer;
    rcRight   : Integer;
    rcBottom  : Integer;
  end;
var
  a         : Cardinal;
  wr        : Cardinal;
  fzZ0      : TFzZ0;                   { полей 2 }
  { регистровые: в кадр не попадают, поэтому мёртвая вложенная
    процедура их не трогает }
  nSaveLine, nOfs: Integer;
  { тела зовут давящие переменные пробника напрямую }
  pr0, pr1: Integer;
  nDepth: Integer;
  nPrevY, pBar, pSlash: Integer;
  nCols: Cardinal;
  nEdi: Integer;
  nEnd: Integer;
  nRest: Integer;
  nLevel: Integer;
  nRepG, nForG: Integer;
  nSat1: Integer;
  nSat2: Integer;
  nSat3: Integer;
  nSat4: Integer;
  nSat5: Integer;
  nSat6: Integer;

  procedure DeadFrame0Z;
  begin
    FillChar(a, SizeOf(a), 0);
    FillChar(wr, SizeOf(wr), 0);
    FillChar(fzZ0, SizeOf(fzZ0), 0);
    if Integer(Pointer(@T)) = 0 then Exit;
  end;

var
  { читает и пишет их `CheckCompare` через три хопа: счётчик байтов в
    буфере и собранная из него строка }
  nIx       : Integer;
  sMemStr   : string;
  pWide     : PWideChar;
  nB        : Integer;                 { БЫЛ полем fzZ1 }

  procedure DeadFrame1Z;
  begin
    FillChar(nIx, SizeOf(nIx), 0);
    FillChar(sMemStr, SizeOf(sMemStr), 0);
    { Без этой строки `pWide` не получает своего слота, а уезжает в хвост
      кадра: обычный указатель -- кандидат на регистр, а кандидат, регистра
      не получивший, кладётся ПОСЛЕ всех, а не по порядку объявления.
      `FillChar` берёт довод по ссылке, кандидатство снимается, и слот
      встаёт на место. Поля записи кандидатами не считаются вовсе. }
    FillChar(pWide, SizeOf(pWide), 0);
    FillChar(nB, SizeOf(nB), 0);
    if Length(S) = -1 then Exit;
  end;

var
  sC        : string;
  bOk       : Boolean;                 { БЫЛ полем fzZ2 }
  fzZ2      : TFzZ2;                   { полей 2 }
  nD        : Integer;
  sE        : string;
  nF        : Integer;
  sG        : string;
  { Эти три строки перенесены сюда только объявлением, слоты у них прежние:
    смещение обычного локала задаёт ПОРЯДОК УПОМИНАНИЯ В МЁРТВОЙ ВЛОЖЕННОЙ,
    а состав первого куска финализации -- ПОРЯДОК ОБЪЯВЛЕНИЯ. Держалки этих
    трёх остались в `DeadFrame3Z`. }
  sQ        : string;
  sBin      : WideString;
  sV274     : string;
  sH        : string;
  nI        : Integer;
  nJ        : Integer;
  nW3       : Cardinal;
  nK3       : Integer;
  nL3       : Integer;
  nM        : Integer;

  procedure DeadFrame2Z;
  begin
    FillChar(sC, SizeOf(sC), 0);
    FillChar(bOk, SizeOf(bOk), 0);
    FillChar(fzZ2, SizeOf(fzZ2), 0);
    FillChar(nD, SizeOf(nD), 0);
    FillChar(sE, SizeOf(sE), 0);
    FillChar(nF, SizeOf(nF), 0);
    FillChar(sG, SizeOf(sG), 0);
    FillChar(sH, SizeOf(sH), 0);
    FillChar(nI, SizeOf(nI), 0);
    FillChar(nJ, SizeOf(nJ), 0);
    FillChar(nW3, SizeOf(nW3), 0);
    FillChar(nK3, SizeOf(nK3), 0);
    FillChar(nL3, SizeOf(nL3), 0);
    FillChar(nM, SizeOf(nM), 0);
    if N = -1 then Exit;
  end;

var
  { `nO` вынесен из записи в обычный локал: у поля записи вес выше, поэтому
    в сравнении грузилось оно, а не соперник, да и присваивание
    непосредственного значения полю стоит лишней команды. Объявлен ПЕРЕД
    записью -- только так слот остаётся на месте: соседний занят домашним
    слотом довода N. }
  nO        : Integer;
  nP        : Integer;
  nElse     : Integer;
  nBack     : Integer;
  fzZ5      : TFzZ5;                   { полей 2 }
  fzZ6      : TFzZ6;                   { полей 2 }
  bNoOff    : Boolean;
  cKz       : Char;
  fzZ7      : TFzZ7;                   { полей 7 }
  nDX1      : Integer;
  fzZ8      : TFzZ8;                   { полей 11 }
  bBinz     : Boolean;
  fzZ9      : TFzZ9;                   { полей 1 }
  nX        : Integer;
  nLenQ     : Integer;
  fzZ10     : TFzZ10;                  { полей 2 }
  nPrevXQ   : Integer;
  ptYQ      : Integer;
  ptX       : Integer;
  fzZ11     : TFzZ11;                  { полей 7 }
  bG        : Boolean;
  mD        : Integer;
  v224      : array[1..4] of Byte;
  nE        : Integer;
  qA        : Int64;
  fzZ12     : TFzZ12;                  { полей 11 }
  bAbs      : Boolean;
  sW278     : string;
  sType     : string;
  nPos      : Integer;
  aCases    : array of TCaseRec;
  hMtx      : THandle;
  arrB      : array of TColRec;        { elSize 6, а не 1 }
  fzZ13     : TFzZ13;                  { полей 3, держалка есть }
  fzZ13B    : TFzZ13B;                 { полей 3, ДЕРЖАЛКИ НЕТ }
  fArr      : TextFile;
  fBin      : file;
  bufStr    : string[255];
  bufChr    : array[0..255] of Char;
  fzZ14     : TFzZ14;                  { полей 22 }
const
  { Шестёрка -- местная постоянная `ExecScriptCommand`, и стоит ПОСЛЕ
    раздела `var` нарочно: RTTI безымянного типа выпускается при РАЗБОРЕ
    объявления, значит объявление шестёрки обязано стоять НИЖЕ обоих
    массивов. }
  gOpsZ: array[0..5] of string = ('and', 'or', 'xor', 'not', '&&', '||');

  procedure DeadFrame3Z;
  begin
    FillChar(nO, SizeOf(nO), 0);
    FillChar(nP, SizeOf(nP), 0);
    FillChar(nElse, SizeOf(nElse), 0);
    FillChar(nBack, SizeOf(nBack), 0);
    FillChar(fzZ5, SizeOf(fzZ5), 0);
    FillChar(sQ, SizeOf(sQ), 0);
    FillChar(fzZ6, SizeOf(fzZ6), 0);
    FillChar(bNoOff, SizeOf(bNoOff), 0);
    FillChar(cKz, SizeOf(cKz), 0);
    FillChar(fzZ7, SizeOf(fzZ7), 0);
    FillChar(nDX1, SizeOf(nDX1), 0);
    FillChar(fzZ8, SizeOf(fzZ8), 0);
    FillChar(sBin, SizeOf(sBin), 0);
    FillChar(bBinz, SizeOf(bBinz), 0);
    FillChar(fzZ9, SizeOf(fzZ9), 0);
    FillChar(nX, SizeOf(nX), 0);
    FillChar(nLenQ, SizeOf(nLenQ), 0);
    FillChar(fzZ10, SizeOf(fzZ10), 0);
    FillChar(nPrevXQ, SizeOf(nPrevXQ), 0);
    FillChar(ptYQ, SizeOf(ptYQ), 0);
    FillChar(ptX, SizeOf(ptX), 0);
    FillChar(fzZ11, SizeOf(fzZ11), 0);
    FillChar(bG, SizeOf(bG), 0);
    FillChar(mD, SizeOf(mD), 0);
    FillChar(v224, SizeOf(v224), 0);
    FillChar(nE, SizeOf(nE), 0);
    FillChar(qA, SizeOf(qA), 0);
    FillChar(fzZ12, SizeOf(fzZ12), 0);
    FillChar(bAbs, SizeOf(bAbs), 0);
    FillChar(sV274, SizeOf(sV274), 0);
    FillChar(sW278, SizeOf(sW278), 0);
    FillChar(sType, SizeOf(sType), 0);
    FillChar(nPos, SizeOf(nPos), 0);
    FillChar(aCases, SizeOf(aCases), 0);
    FillChar(hMtx, SizeOf(hMtx), 0);
    FillChar(arrB, SizeOf(arrB), 0);
    FillChar(fzZ13, SizeOf(fzZ13), 0);
    { Держалки `fzZ13B`, `fArr`, `fBin`, `bufStr`, `bufChr`, `fzZ14` сняты
      нарочно. Упоминание во вложенной процедуре выдаёт слот немедленно, а
      без него локал крупнее восьми байт ждёт своей очереди и получает слот
      ПОСЛЕ объекта `on E:` -- именно это здесь и нужно. }
  end;

{ вторые имена слотов: тот же адрес, другой тип }
var
  bDone     : Boolean absolute bNoOff;
  bNum      : Boolean absolute bNoOff;
  cF219     : Char absolute bG;
  cVar      : Char absolute bNoOff;
  dF230     : Double absolute qA;
  ptG       : TPoint absolute ptX;
  ptM       : TPoint absolute nDX1;
  rF228     : Real48 absolute nE;
  sF220     : Single absolute mD;

  { Счёт ОДНОГО логического выражения `exp ...`. Вложена не в диспетчер, а
    в `CheckCondition`, и кадр берёт у неё. Довод -- `var`. }
  { РАСКРЫТИЕ СКОБОК в условии `if`. Идёт слева
    направо до первой `)`, от неё назад до парной `(`, считает то, что между
    ними, отдельным выражением `exp ...`, вырезает кусок ВМЕСТЕ со скобками и
    вставляет на его место ' 0 ' или ' 1 '. После каждой замены счётчик
    сбрасывается в ноль, то есть разбор начинается заново. Когда скобок не
    осталось -- считается вся строка целиком, а ответ это сравнение с '1'.
    Довод -- строка ПО ЗНАЧЕНИЮ, а не `const`: в прологе стоит `@LStrAddRef`
    и свой слот в кадре, и тело эту строку переписывает.
    Непарная `(` -- окно с сообщением и остановка скрипта.
    ДВЕ ТОНКОСТИ, ВИДНЫЕ ТОЛЬКО В МАШИННОМ КОДЕ:
    * `Dec(j)` стоит ПОСЛЕ цикла `for j := i downto 1`, и проверяется
    именно то значение, на котором цикл кончился: дошёл до нуля -- скобки
    нет (`j` станет -1), вышел по `Break` -- есть;
    * ' ' + Chr(..) + ' ' считается КОРОТКИМИ строками: `PStrCpy`,
    `PStrNCat` с длиной 2, затем с длиной 3, и только потом
    `LStrFromString`. Это признак того, что все три слагаемых -- литералы
    и Char, а не длинные строки. }
  function CheckCondition(S: string): Boolean;
  var
    { ПЯТЬ СЛОВ В ГОЛОВЕ КАДРА. Сама `CheckCondition` их не читает и не
      пишет ни разу; слот им нужен потому, что к ним лезут ВЛОЖЕННЫЕ через
      статическую ссылку, а такой локал получает слот раньше довода -- в
      самой голове кадра:
      mOfs, mDC -- их берёт `CheckCompare`: счётчик и длина в цикле
      `ReadProcessMemory` (сравнение с $100 беззнаковое, значит
      Cardinal) и итог `GetDC(0)`, который потом идёт в `GetPixel`;
      nPos, nBeg, nEnd -- их берёт `CheckOneExpr`. }
    mOfs: Cardinal;
    mDC: Cardinal;
    nPos: Integer;
    nBeg: Integer;
    nEnd: Integer;
    i: Integer;
    j: Integer;
    { Порядок важен: строка объявлена ПЕРЕД булевой. }
    sX: string;
    bGo: Boolean;

    { ВЫЧИСЛИТЬ ОДНО ВЫРАЖЕНИЕ УСЛОВИЯ. Вложена в `CheckCondition`, а не в
      диспетчер, и кадр берёт у неё.

      Работа в четыре захода:
      1) `%...[...]` -- подстановка МАТРИЧНОЙ переменной: от `%` ищется
      `[`, от неё `]`, кусок вырезается и заменяется на
      `"` + calc-значение + `"`;
      2) `$...` -- подстановка СТРОКОВОЙ переменной: `get ` даёт имя,
      оно вырезается по ДЛИНЕ ответа, на его место идёт
      `"` + calc-значение + `"`, и позиция сдвигается на длину
      вставки (у первого захода такого сдвига нет);
      3) разбор слева направо: слово 2 -- знак операции. Пусто --
      дописать в ответ слово 1; `and`/`or`/`xor`/`&&`/`||` -- дописать
      слово 1, первую букву знака и отрезать два слова; иначе --
      позвать `CheckCompare` и дописать '0'/'1' плюс первую букву
      следующего знака;
      4) свёртка накопленного `1&0|1...`: ответ -- первый знак, дальше
      парами `знак, значение`, лишний знак -- окно с ошибкой.

      Довод `var`: в регистре идёт АДРЕС строки, а не значение. }
    function CheckOneExpr(var sE: string): Boolean;
    label
      LOpsZ;
    var
      { ДВА ВОСЬМИБАЙТНЫХ В ГОЛОВЕ КАДРА -- та же причина: сама
        `CheckOneExpr` их не трогает, в них пишет вложенная `CheckCompare`,
        а читает парами -- обычное 64-разрядное сравнение. }
      qA: Int64;
      qB: Int64;
      sT: string;
      sR: string;
      b: Boolean;
      { Двойка считается ОТДЕЛЬНЫМ оператором, а не прямо среди доводов --
        тогда `-2` приходит через переменную. С прямым `-2` вышла бы одна
        команда. Регистр она получает сама, слота не берёт. }
      nCut: Integer;

      { СРАВНИТЬ ДВА ОПЕРАНДА. Вложена в `CheckOneExpr`, поэтому до `T` ей
        три хопа по статическим ссылкам.

        Голова разбирает восемь знаков сравнения, середина читает строку
        из памяти чужого процесса, общий хвост отрезает разобранное от
        строки.

        Число `k` -- сколько слов разобрано; общий хвост склеивает остаток
        начиная со слова `k+1`, и приходит оно туда прямо через регистр. }
      function CheckCompare(var sC: string): Boolean;
      var
        { СТРОК РОВНО ЧЕТЫРЕ: sOp, sRest, sA, sB, дальше Result и ptC. Пятая
          строка сдвинула бы весь кадр на слово; слово `point` берётся
          временной. }
        sOp: string;
        sRest: string;
        sA: string;
        sB: string;
        { ОТВЕТ ЖИВЁТ В ИМЕНОВАННОМ ЛОКАЛЕ, А НЕ В `Result`: его место -- между
          четырьмя строками и `ptC`. Спиленный кандидат лёг бы в голову
          кадра и сдвинул все строки на слово. }
        b: Boolean;
        ptC: TPoint;
        { БЕЗЗНАКОВЫЕ: расширение до Int64 идёт `xor edx,edx`, а сравнения
          половинок цвета -- `jb`/`ja`/`jae`/`jbe`. }
        nPix: Cardinal;
        nC1: Cardinal;
        nC2: Cardinal;
        k: Integer;
        m: Integer;
      begin
        sOp := EvalScriptExpr(T, sC, 2);
        if (sOp[1] in ['!', '<'..'>']) or (sOp = '->') then
        begin
          sA := EvalScriptExpr(T, sC, 1);
          sB := EvalScriptExpr(T, sC, 3);
          { один из операндов -- код символа `%NN`, другой -- сам символ }
          if (Length(sA) > 1) and (Length(sB) > 1) and
            ((sA[1] = '%') or (sB[1] = '%')) and (sA[1] <> sB[1]) then
            if sA[1] = '%' then
              sA[1] := Chr(StrToInt(sA))
            else
              sB[1] := Chr(StrToInt(sB));
          if sOp = '<' then
          begin
            if TryStrToInt64(sA, qA) and TryStrToInt64(sB, qB) then
              b := qA < qB
            else
              b := CompareStr(AnsiLowerCase(sA), AnsiLowerCase(sB)) < 0;
          end
          else if sOp = '>' then
          begin
            if TryStrToInt64(sA, qA) and TryStrToInt64(sB, qB) then
              b := qA > qB
            else
              b := CompareStr(AnsiLowerCase(sA), AnsiLowerCase(sB)) > 0;
          end
          else if sOp = '<=' then
          begin
            if TryStrToInt64(sA, qA) and TryStrToInt64(sB, qB) then
              b := qA <= qB
            else
              b := Pos(AnsiLowerCase(sB), AnsiLowerCase(sA)) > 0;
          end
          else if sOp = '>=' then
          begin
            if TryStrToInt64(sA, qA) and TryStrToInt64(sB, qB) then
              b := qA >= qB
            else
              b := Pos(AnsiLowerCase(sA), AnsiLowerCase(sB)) > 0;
          end
          else if sOp = '<-' then
            b := Pos(AnsiLowerCase(sB), AnsiLowerCase(sA)) > 0
          else if sOp = '->' then
            b := Pos(AnsiLowerCase(sA), AnsiLowerCase(sB)) > 0
          else if (sOp = '=') or (sOp = '==') then
          begin
            if TryStrToInt64(sA, qA) and TryStrToInt64(sB, qB) then
              b := qA = qB
            else
              b := CompareStr(AnsiLowerCase(sA), AnsiLowerCase(sB)) = 0;
          end
          else
          begin
            if TryStrToInt64(sA, qA) and TryStrToInt64(sB, qB) then
              b := qA <> qB
            else
              b := CompareStr(AnsiLowerCase(sA), AnsiLowerCase(sB)) <> 0;
          end;
          k := 3;
        end
        else
        begin
          sOp := '';
          { слово `point` уходит во ВРЕМЕННУЮ, а не в переменную: своего слота
            под него нет }
          if EvalScriptPoint(T, sC, 1) = gCmdNamesdd[7] then
          begin
            { Начальный адрес берётся из таблицы по номеру версии клиента, дальше
              цепочка из двух разыменований ЧУЖОЙ памяти: читаем 4 байта по
              адресу `a` снова в `a`, число прочитанного -- в `wr`. }
            a := gClT590A98aq[T.ClVerIdx];
            ReadProcessMemory(TScanThread(T).ProcessHandle2, Pointer(a),
              @a, 4, DWORD(wr));
            ReadProcessMemory(TScanThread(T).ProcessHandle2, Pointer(a),
              @a, 4, DWORD(wr));
            mOfs := 0;
            while mOfs < $100 do
            begin
              ReadProcessMemory(TScanThread(T).ProcessHandle2,
                Pointer(Integer(a) + Integer(mOfs)), @fzZ0.v108[mOfs + 1], $10,
                DWORD(wr));
              Inc(mOfs, $10);
            end;
            wr := $100;
            { Из буфера собирается строка. Второй байт нулевой -- значит она
              ДВУХБАЙТНАЯ, и её снимает `WideCharToString`; иначе байты
              добираются по одному до первого нуля. Все три величины
              (`nIx`, `sMemStr`, `pWide`) -- слоты кадра ДИСПЕТЧЕРА, а не
              свои. }
            nIx := 0;
            sMemStr := '';
            if fzZ0.v108[2] <> 0 then
            begin
              while fzZ0.v108[nIx + 1] <> 0 do
              begin
                sMemStr := sMemStr + Char(fzZ0.v108[nIx + 1]);
                Inc(nIx);
              end;
            end
            else
            begin
              { Приведение на чтении кэш подвыражений не ломает. Ломает ПОЛЕ ЗАПИСИ
                против ЛОКАЛА: у поля записанное держится в регистре, у
                локала слот перечитывается. }
              pWide := @fzZ0.v108[1];
              sMemStr := WideCharToString(pWide);
            end;
            if Pos(LowerCase(EvalScriptExpr(T, sC, -2)),
              LowerCase(sMemStr)) <> 0 then
              b := True
            else
              b := False;
            k := -1;
          end
          else
          begin
            sC := StringReplace(sC, '"', '', [rfReplaceAll]);
            mDC := GetDC(0);
            ptC.X := StrToInt(EvalScriptExpr(T, sC, 1));
            ptC.Y := StrToInt(EvalScriptExpr(T, sC, 2));
            ClientToScreen(TScanThread(T).ClientWnd2, ptC);
            nPix := GetPixel(mDC, ptC.X, ptC.Y);
            { точку не прочитали: в журнал уходит `pixel not found` }
            if nPix = CLR_INVALID then
              if fmSecondfj.miELclrinvalid.Checked then
                if T.IsProc then
                begin
                  { ЧЕТЫРЕ ЗАГРУЗКИ `T` -- это четыре ГОЛЫХ имени. Приведение (и
                    `absolute`-двойник) считается временным значением и
                    кэшируется в регистре, а голое имя переменной
                    перечитывается каждый раз. Отсюда и `SyncLogMsg` вместо
                    `TScanThread(T).SyncLogMsg`. }
                  T.Msg := 'pixel not found'#0;
                  TScanThread(T).Synchronize(T.SyncLogMsg);
                end;
            { первый ReleaseDC с нулевым окном, второй (в ветке `abs`) --
              с рабочим }
            ReleaseDC(0, mDC);
            sOp := LowerCase(EvalScriptExpr(T, sC, 4));
            if (sOp = '') or (sOp = gOpsZ[0]) or (sOp = gOpsZ[1]) or
              (sOp = gOpsZ[2]) or (sOp = gOpsZ[4]) or (sOp = gOpsZ[5]) then
            begin
              b := nPix = StrToInt64(EvalScriptExpr(T, sC, 3));
              k := 3;
            end
            else
            begin
              { `k := 4` ОДИН на обе ветки: присваивание стоит ПОСЛЕ внутреннего
                if..else, а не в каждой из них. }
              if sOp = 'abs' then
              begin
                mDC := GetDC(0);
                nPix := GetPixel(mDC, StrToInt(EvalScriptExpr(T, sC, 1)),
                  StrToInt(EvalScriptExpr(T, sC, 2)));
                ReleaseDC(TScanThread(T).ClientWnd2, mDC);
                b := nPix = StrToInt64(EvalScriptExpr(T, sC, 3));
              end
              else
              begin
                nC1 := StrToInt64(EvalScriptExpr(T, sC, 3));
                nC2 := StrToInt64(EvalScriptExpr(T, sC, 4));
                b := ((nPix and $FF) >= (nC1 and $FF)) and
                  ((nPix and $FF) <= (nC2 and $FF)) and
                  ((nPix and $FF00) >= (nC1 and $FF00)) and
                  ((nPix and $FF00) <= (nC2 and $FF00)) and
                  ((nPix and $FF0000) >= (nC1 and $FF0000)) and
                  ((nPix and $FF0000) <= (nC2 and $FF0000)) or
                  ((nPix and $FF) <= (nC1 and $FF)) and
                  ((nPix and $FF) >= (nC2 and $FF)) and
                  ((nPix and $FF00) <= (nC1 and $FF00)) and
                  ((nPix and $FF00) >= (nC2 and $FF00)) and
                  ((nPix and $FF0000) <= (nC1 and $FF0000)) and
                  ((nPix and $FF0000) >= (nC2 and $FF0000));
              end;
              k := 4;
            end;
          end;
        end;
        if k > 0 then
        begin
          m := k + 1;
          sRest := '';
          sOp := EvalScriptExpr(T, sC, m);
          while sOp <> '' do
          begin
            { Порядок `push` у LStrCatN прямой: первый толчок и есть первое
              слагаемое. Здесь это `sRest + ' ' + sOp` -- остаток строки
              собирается ВПЕРЁД, а не задом наперёд. }
            sRest := sRest + ' ' + sOp;
            Inc(m);
            sOp := EvalScriptExpr(T, sC, m);
          end;
          sC := sRest;
        end
        else
          sC := '';
        Result := b;
      end;

    begin
      sR := '';
      Result := False;
      sE := AnsiLowerCase(sE);
      nPos := 1;
      repeat
        if T.StopRequested then
          Exit;
        nPos := PosEx('%', sE, nPos);
        if nPos > 0 then
        begin
          sT := Copy(sE, nPos, Length(sE) - nPos + 1);
          nBeg := Pos('[', sT);
          if nBeg > 0 then
          begin
            sT := Copy(sT, nBeg, Length(sT) - nBeg + 1);
            nEnd := Pos(']', sT);
            if nEnd > 0 then
            begin
              sT := Copy(sE, nPos, nEnd + nBeg - 1);
              Delete(sE, nPos, nEnd + nBeg - 1);
              sT := '"' + EvalScriptExpr(T, 'calc ' + sT, -1) + '"';
              Insert(sT, sE, nPos);
            end;
          end
          else
            Inc(nPos);
        end;
      until nPos = 0;
      nPos := 1;
      repeat
        if T.StopRequested then
          Exit;
        nPos := PosEx('$', sE, nPos);
        if nPos > 0 then
        begin
          sT := Copy(sE, nPos, Length(sE) - nPos + 1);
          sT := EvalScriptExpr(T, 'get ' + sT, 1);
          Delete(sE, nPos, Length(sT));
          sT := '"' + EvalScriptExpr(T, 'calc ' + sT, -1) + '"';
          Insert(sT, sE, nPos);
          Inc(nPos, Length(sT));
        end;
      until nPos = 0;
      LOpsZ:
        sT := EvalScriptExpr(T, sE, 2);
        if sT = '' then
        begin
          sE := StringReplace(sE, '"', '', [rfReplaceAll]);
          sT := EvalScriptExpr(T, sE, 2);
        end;
        if sT = '' then
          sR := sR + EvalScriptExpr(T, sE, 1)
        else if (sT = gOpsZ[0]) or (sT = gOpsZ[1]) or (sT = gOpsZ[2]) or
          (sT = gOpsZ[4]) or (sT = gOpsZ[5]) then
        begin
          sR := sR + EvalScriptExpr(T, sE, 1);
          sR := sR + EvalScriptExpr(T, sE, 2)[1];
          nCut := 2;
          sE := EvalScriptExpr(T, sE, -nCut);
          sT := gOpsZ[0];
        end
        else
        begin
          b := CheckCompare(sE);
          if T.StopRequested then
            Exit;
          sR := sR + Chr(Ord(b) + 48);
          sT := EvalScriptExpr(T, sE, 0);
          if Length(sT) > 0 then
            sR := sR + sT[1];
        end;
      if not ((sT <> gOpsZ[0]) and (sT <> gOpsZ[1]) and (sT <> gOpsZ[2]) and
        (sT <> gOpsZ[4]) and (sT <> gOpsZ[5])) then goto LOpsZ;
      b := sR[1] = '1';
      while Length(sR) > 1 do
      begin
        if (sR[2] = gOpsZ[0][1]) or (sR[2] = gOpsZ[4][1]) then
          b := b and (sR[3] = '1')
        else if (sR[2] = gOpsZ[1][1]) or (sR[2] = gOpsZ[5][1]) then
          b := b or (sR[3] = '1')
        else if sR[2] = gOpsZ[2][1] then
          b := b xor (sR[3] = '1')
        else
        begin
          SetForegroundWindow(Application.Handle);
          MsgBox('Syntax error (Exp1)', 'UOPilot Error Message', 0);
          T.StopRequested := True;
          Exit;
        end;
        Delete(sR, 1, 2);
      end;
      Result := b;
    end;

  begin
    S := EvalScriptExpr(T, 'SupOpOnly ' + S, -1);
    i := 1;
    Result := False;
    bGo := True;
    if T.StopRequested then
      Exit;
    while (i <= Length(S)) and bGo do
    begin
      if S[i] = ')' then
      begin
        for j := i downto 1 do
          if S[j] = '(' then
          begin
            sX := 'exp ' + Copy(S, j + 1, i - j - 1);
            Delete(S, j, i - j + 1);
            sX := ' ' + Chr(Ord(CheckOneExpr(sX)) + 48) + ' ';
            if T.StopRequested then
              Exit;
            Insert(sX, S, j);
            i := 0;
            Break;
          end;
        { Сравнение С ЕДИНИЦЕЙ, схлопнутое в `dec`: так делается только когда
          регистр дальше мёртв, а прыжок знаковый. `dec` не трогает CF,
          поэтому для Cardinal замена запрещена и `cmp` остаётся -- на входе
          в цикл он и стоит, там `j` ещё жива. Форма `j - 1 < 0` дала бы
          `dec/jns`, `Dec(j); if j < 0` -- `dec/test/jge`. }
        if j < 1 then
        begin
          SetForegroundWindow(Application.Handle);
          if gLangOffsety > 0 then
            MsgBox(PChar(LoadStr(gLangOffsety + $1D1)), 'UOPilot Error Message', 0)
          else
            MsgBox('Не могу найти открывающую скобку.',
                   'UOPilot Error Message', 0);
          T.StopRequested := True;
          Exit;
        end;
      end;
      Inc(i);
    end;
    S := Chr(Ord(CheckOneExpr(S)) + 48);
    Result := S = '1';
  end;

  { ИСПОЛНИТЕЛЬ ВСЕХ 42 КОМАНД МЫШИ. Вложенная процедура диспетчера: зовут
    её 42 ветки (`left`, `kwheel_up`, `double_pmiddle`, ...), и весь разбор
    координат, модификаторов и способа доставки события лежит здесь, а не в
    ветках. Из охватывающей трогает ТОЛЬКО `T`, поэтому статическая ссылка
    приходит последним доводом.

    Кадр: дома доводов, две точки, семь целых, три ShortString по $100 и
    два десятка строковых временных.

    ТРИ СПОСОБА ДОСТАВКИ, и они же три семейства команд:
    обычные (left, middle, ...)   -- PostMessage;
    `p`-семейство (pleft, ...)    -- прямой системный вызов
    NtUserPostMessage (NtPostMsgZ);
    `k`-семейство (kleft, ...)    -- mouse_event, то есть настоящий ввод. }
  procedure MouseClick(AWnd: HWND; ABtn: Byte; sCmd: string; ptBack: TPoint;
    bAbsolute: Boolean; S2: string);
  var
    ptClick: TPoint;
    ptScr: TPoint;
    nMk: Integer;
    nAmt: Integer;
    nWhl: Integer;
    nOfsX: Integer;
    nRndX: Integer;
    nOfsY: Integer;
    nRndY: Integer;
    sKeys: ShortString;
    sKeysCopy: ShortString;
    sTail: ShortString;
    nLParam: Integer;                      { регистровая: esi }
    nNoOff: Integer;                     { регистровая: esi }
    nAbsPos: Integer;                    { регистровая: eax }

    { Своя вложенная у вложенной: ждёт nDue
      миллисекунд, меряя время счётчиком высокого разрешения, когда он
      заведён (T.PerfFreq > 0), и GetTickCount иначе. `T` берётся ЧЕРЕЗ ДВА
      уровня: [ebp+8] -> кадр MouseClick, +$14 -> кадр диспетчера, -$10C. }
    { ВЫХОД ИЗ ЦИКЛА ЧЕРЕЗ `Exit`, А НЕ `Break`: с `Break` сохраняемых
      регистров выходит три, а так -- два. `nTime` живёт только до `until`,
      и при единственном выходе в эпилог он перестаёт быть кандидатом на
      EBX/ESI/EDI и остаётся в EAX. }
    procedure Delay(nDue: Cardinal);
    var
      qTick: Int64;
      nTime: Cardinal;
    begin
      if (T.PerfFreq > 0) and QueryPerformanceCounter(qTick) then
        nDue := nDue + Trunc(qTick / T.PerfFreq * 1000)
      else
        nDue := nDue + GetTickCount;
      repeat
        if T.StopRequested then Exit;
        SysUtils.Sleep(1);
        if (T.PerfFreq > 0) and QueryPerformanceCounter(qTick) then
          nTime := Trunc(qTick / T.PerfFreq * 1000)
        else
          nTime := GetTickCount;
      until nTime >= nDue;
    end;

  begin
    if not T.StopRequested then
    begin
      SplitCmdLine(T, sCmd);
      nLParam := MakeLong(StrToInt(T.CmdParts[1]), StrToInt(T.CmdParts[2]));
      { Приведение к `Word` тут не просто лишнее, оно меняет код: с ним `and`
        считается в Word, постоянная $FFFF беззнаковая и не влезает в байт --
        берётся длинная форма. Без него маску сужает сам `SmallInt`,
        постоянная знаковая и форма короткая. }
      ptClick.Y := SmallInt((nLParam shr 16) and $FFFF);
      ptClick.X := SmallInt(nLParam and $FFFF);
      S2 := AnsiLowerCase(S2);
      nAbsPos := Pos('abs', S2);
      bAbsolute := nAbsPos > 0;
      if bAbsolute then Delete(S2, nAbsPos, 3);
      nNoOff := Pos('nooffset', S2);
      if nNoOff > 0 then Delete(S2, nNoOff, 8);
      nOfsX := 0;
      nRndX := 0;
      nOfsY := 0;
      nRndY := 0;
      if not (ABtn in [91..96]) then
        if TryStrToInt(EvalScriptPoint(T, S2, 0), nOfsX) and
           TryStrToInt(EvalScriptPoint(T, S2, 1), nOfsY) then
        begin
          S2 := EvalScriptPoint(T, S2, -2);
          if TryStrToInt(EvalScriptPoint(T, S2, 0), nRndX) and
             TryStrToInt(EvalScriptPoint(T, S2, 1), nRndY) then
            S2 := EvalScriptPoint(T, S2, -2)
          else
          begin
            nRndX := 0;
            nRndY := 0;
          end;
        end
        else
        begin
          nOfsX := 0;
          nOfsY := 0;
        end;
      ptClick.X := ptClick.X - Abs(nRndX) + Random(Abs(nRndX) + nOfsX + 1);
      ptClick.Y := ptClick.Y - Abs(nRndY) + Random(Abs(nRndY) + nOfsY + 1);
      if nNoOff <= 0 then
      begin
        ptClick.X := ptClick.X + T.Cnt104674;
        ptClick.Y := ptClick.Y + T.Cnt104678;
      end;
      nLParam := MakeLong(ptClick.X, ptClick.Y);
      sTail := EvalScriptPoint(T, S2, 1);
      if not (ABtn in [91..96]) or (sTail <> '') then
      begin
        nWhl := 0;
        if not bAbsolute and (Length(S2) > 0) then
        begin
          sTail := EvalScriptPoint(T, S2, 0);
          if Length(sTail) > 0 then
            if TryStrToInt(sTail, nWhl) then
            begin
              AWnd := nWhl;
              S2 := EvalScriptPoint(T, S2, -1);
            end;
        end;
      end;
      if ABtn in [93, 94, 201..203, 210..212, 220..222, 233, 243, 244] then
        gNtPmNumb4 := SpeedTableaah[T.NtUserIdx - 3];
      nMk := 0;
      if ABtn in [91..96] then
      begin
        nAmt := 3;
        if bAbsolute then Inc(nAmt);
        if nWhl > 0 then Inc(nAmt);
        sKeys := AnsiLowerCase(T.CmdParts[nAmt]);
      end
      else
        sKeys := AnsiLowerCase(EvalScriptPoint(T, S2, 0));
      nWhl := 0;
      sKeysCopy := sKeys;
      if sKeys <> '' then
        while Length(sKeys) > 0 do
        begin
          case sKeys[1] of
            '~': nMk := nMk or 4;
            '@': nMk := nMk;
            '^': nMk := nMk or 8;
            'r': nMk := nMk or 2;
            'm': nMk := nMk or $10;
            'l': nMk := nMk or 1;
          end;
          Delete(sKeys, 1, 1);
        end;
      if ABtn in [91..96] then
      begin
        if nMk <> 0 then
          nAmt := StrToInt(AnsiLowerCase(T.CmdParts[nAmt + 1]))
        else
          nAmt := StrToInt(T.CmdParts[nAmt]);
        case ABtn of
          91, 93, 95: if nAmt > 0 then nAmt := nAmt * -1;
          92, 94, 96: if nAmt < 0 then nAmt := nAmt * -1;
        end;
        if ABtn in [95, 96] then
          nWhl := nAmt * 120
        else
          nWhl := (nAmt * 120) shl 16 or nMk;
      end;
      ptScr := ptClick;
      ClientToScreen(AWnd, ptScr);
      if bAbsolute then
      begin
        ptScr := ptClick;
        if not (ABtn in [101..103, 110..112, 120..122, 131..133]) then
        begin
          SetCursorPos(ptClick.X, ptClick.Y);
          AWnd := WindowFromPoint(ptClick);
          ScreenToClient(AWnd, ptClick);
          nLParam := MakeLong(ptClick.X, ptClick.Y);
        end;
      end;
      if (ptBack.X = 0) and (ptBack.Y = 0) then GetCursorPos(ptBack);
      if fmSecondfj.miMoveMouseBeforeClick.Checked then SetCursorPos(ptScr.X, ptScr.Y);
      case ABtn of
        11:
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $201));
            PostMessage(AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $202, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $201));
            PostMessage(AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $202, nMk, nLParam);
          end;
        22:
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $204));
            PostMessage(AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $205));
            PostMessage(AWnd, $205, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $204));
            PostMessage(AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $205));
            PostMessage(AWnd, $205, nMk, nLParam);
          end;
        23:
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $207));
            PostMessage(AWnd, $207, nMk or $10, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $208, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $207));
            PostMessage(AWnd, $207, nMk or $10, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $208, nMk, nLParam);
          end;
        1:
          if not fmSecondfj.miUseNewClickMetod.Checked then
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $201));
            PostMessage(AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $202, nMk, nLParam);
          end
          else
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $201, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $201));
            PostMessage(AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $202, nMk or 1, nLParam);
          end;
        2:
          if not fmSecondfj.miUseNewClickMetod.Checked then
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $204));
            PostMessage(AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk or 2, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $205));
            PostMessage(AWnd, $205, nMk, nLParam);
          end
          else
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $204, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $204));
            PostMessage(AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $205, nMk or 2, nLParam);
          end;
        3:
          begin
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $200));
            PostMessage(AWnd, $200, nMk, nLParam);
            PostMessage(AWnd, $20, AWnd, MakeLong(1, $207));
            PostMessage(AWnd, $207, nMk or $10, nLParam);
            Delay(T.ClickDelay);
            PostMessage(AWnd, $208, nMk, nLParam);
          end;
        30: PostMessage(AWnd, $201, nMk, nLParam);
        40: PostMessage(AWnd, $202, nMk, nLParam);
        33: PostMessage(AWnd, $204, nMk, nLParam);
        34: PostMessage(AWnd, $205, nMk, nLParam);
        43: PostMessage(AWnd, $207, nMk, nLParam);
        44: PostMessage(AWnd, $208, nMk, nLParam);
        91, 92: PostMessage(AWnd, $20A, nWhl, nLParam);
        93, 94: NtPostMsgZ(T, AWnd, $20A, nWhl, nLParam);
        95, 96:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            mouse_event($800, ptClick.X, ptClick.Y, nWhl, GetMessageExtraInfo);
          end;
        110:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(2, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event(4, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        101:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(8, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($10, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        103:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event($20, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($40, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        120:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(2, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event(4, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event(2, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event(4, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        102:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(8, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($10, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event(8, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($10, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        133:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event($20, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($40, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($20, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
            Delay(T.ClickDelay);
            mouse_event($40, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        111:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(2, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        112:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(4, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        121:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event(8, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        122:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event($10, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        131:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event($20, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        132:
          begin
            SetCursorPos(ptScr.X, ptScr.Y);
            if fmSecondfj.miUseKleft217.Checked then ptScr := Types.Point(0, 0);
            mouse_event($40, ptScr.X, ptScr.Y, 0, GetMessageExtraInfo);
          end;
        210:
          begin
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $201));
            NtPostMsgZ(T, AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $202, nMk, nLParam);
          end;
        201:
          begin
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $204));
            NtPostMsgZ(T, AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $205, nMk, nLParam);
          end;
        220:
          begin
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $201));
            NtPostMsgZ(T, AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $202, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $201));
            NtPostMsgZ(T, AWnd, $201, nMk or 1, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $202, nMk, nLParam);
          end;
        202:
          begin
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $204));
            NtPostMsgZ(T, AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $205, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $204));
            NtPostMsgZ(T, AWnd, $204, nMk or 2, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $205, nMk, nLParam);
          end;
        233:
          begin
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $207));
            NtPostMsgZ(T, AWnd, $207, nMk or $10, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $208, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $207));
            NtPostMsgZ(T, AWnd, $207, nMk or $10, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $208, nMk, nLParam);
          end;
        203:
          begin
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $200));
            NtPostMsgZ(T, AWnd, $200, nMk, nLParam);
            NtPostMsgZ(T, AWnd, $20, AWnd, MakeLong(1, $207));
            NtPostMsgZ(T, AWnd, $207, nMk or $10, nLParam);
            Delay(T.ClickDelay);
            NtPostMsgZ(T, AWnd, $208, nMk, nLParam);
          end;
        211: NtPostMsgZ(T, AWnd, $201, nMk, nLParam);
        212: NtPostMsgZ(T, AWnd, $202, nMk, nLParam);
        221: NtPostMsgZ(T, AWnd, $204, nMk, nLParam);
        222: NtPostMsgZ(T, AWnd, $205, nMk, nLParam);
        243: NtPostMsgZ(T, AWnd, $207, nMk, nLParam);
        244: NtPostMsgZ(T, AWnd, $208, nMk, nLParam);
      end;
      if not bAbsolute then
        if fmSecondfj.miMoveMouseBack.Checked then
          if (ptBack.X <> 0) or (ptBack.Y <> 0) then
          begin
            SetCursorPos(ptBack.X, ptBack.Y);
            ptBack.X := 0;
            ptBack.Y := 0;
          end;
    end;
  end;
  { ПРОХОД КУРСОРА ПО КРИВОЙ БЕЗЬЕ степени N. Точка кривой считается по
    Бернштейну: C(N,k) = N! / (k! * (N-k)!), причём все три факториала
    считаются циклами прямо здесь. Шаг по параметру приходит доводом (Double
    на стеке), между шагами -- Sleep со случайной добавкой, чтобы движение
    выглядело человеческим. В конце курсор ставится ровно в AX[3]/AY[3] --
    зашито 3, а не N. }
  procedure BezierMove(AX, AY: TCurveArr; N: Integer; AStep: Double);
  var
    nF: Integer;                         { -8 }
    dX, dY: Double;
    dB, dC: Double;
    t: Double;
    k: Integer;
    i, nA, nB: Integer;                  { регистры }
  begin
    SetCursorPos(AX[0], AY[0]);
    SysUtils.Sleep(Random(15) + 10);
    nF := 1;
    for i := 1 to N do
      nF := nF * i;
    t := AStep;
    while t <= 1 do
    begin
      dX := 0;
      dY := 0;
      for k := 0 to N do
      begin
        nA := 1;
        nB := 1;
        for i := 1 to k do
          nA := nA * i;
        for i := 1 to N - k do
          nB := nB * i;
        dC := nF / (nA * nB);
        dB := Power(t, k) * dC * Power(1 - t, N - k);
        dX := dX + AX[k] * dB;
        dY := dY + AY[k] * dB;
      end;
      SetCursorPos(Round(dX), Round(dY));
      SysUtils.Sleep(Random(15) + 10);
      t := t + AStep;
    end;
    SetCursorPos(AX[3], AY[3]);
  end;
  { ПЛАВНЫЙ ПЕРЕЕЗД КУРСОРА ИЗ A В B. Две опорные точки
    кривой ставятся на треть пути, но со случайным перекосом: направление
    перекоса выбирает `Random(4)`, величину -- два `Random(5)`. Шаг по параметру
    обратно пропорционален длине отрезка, так что дальний переезд идёт не
    дольше ближнего. Обе точки кривой одинаковы (aX[1] = aX[2]), то есть кривая
    на деле квадратичная, записанная как кубическая. }
  {$W+}
  function SmoothMove(A, B: TPoint): Boolean;
  var
    nCX: Integer;                        { edi }
    nCY: Integer;
    nR1, nR2: Integer;
    dStep: Double;
    aX, aY: TCurveArr;
    nDX, nDY: Integer;                   { ebx, esi }
  begin
    nDX := (B.X - A.X) div 3;
    nDY := (B.Y - A.Y) div 3;
    nR1 := Random(5);
    nR2 := Random(5);
    case Random(4) of
      0:
        begin
          nCX := nDX - nDY div (nR1 + 3);
          nCY := nDX div (nR2 + 3) + nDY;
        end;
      1:
        begin
          nCX := nDY div (nR1 + 3) + nDX;
          nCY := nDY - nDX div (nR2 + 3);
        end;
      2:
        begin
          nCX := nDY div (nR1 + 3) + nDX * 2;
          nCY := nDY * 2 - nDX div (nR2 + 3);
        end;
      3:
        begin
          nCX := nDX * 2 - nDY div (nR1 + 3);
          nCY := nDX div (nR2 + 3) + nDY * 2;
        end;
    end;
    if (nDX <> 0) or (nDY <> 0) then
      dStep := 1 / Sqrt(nDX * nDX + nDY * nDY) * (Random($46) + $19)
    else
      dStep := 1;
    aX[0] := A.X;
    aY[0] := A.Y;
    aX[1] := A.X + nCX;
    aY[1] := A.Y + nCY;
    aX[2] := aX[1];
    aY[2] := aY[1];
    aX[3] := B.X;
    aY[3] := B.Y;
    BezierMove(aX, aY, 3, dStep);
    Result := True;
  end;
  {$W-}

  { Команда скрипта `restart_script`. Единственная во всей семье, что
    ВОЗВРАЩАЕТ значение: `True` значит «перезапустили самих себя», и по
    этому ответу диспетчер начинает скрипт заново.
    Работа в ДВА прохода по одному и тому же диапазону, а между ними --
    выход, если за это время остановили нас самих:
    первый гасит выбранные скрипты (как `StopCmd`) и запоминает в кадре,
    по БАЙТУ НА СКРИПТ, кого потом поднимать;
    второй ждёт, пока поток встанет приостановленным, и поднимает его
    заново (как `StartCmd`).
    Отсюда и стобайтовый массив в кадре: счётчик и указатель по нему идут
    парой.
    Три мелочи:
    * приставка строки -- `stop_script `, а не `restart_script `: описка
    старая, но трогать её не будем;
    * `allex` здесь не `if`, а ПРЯМОЕ присваивание -- на две команды
    короче, чем в `StopCmd`;
    * проверка «свой ли это поток» в первом проходе стоит ДВАЖДЫ, и вторая
    делает первую бессмысленной. }
  function RestartCmd: Boolean;
  var
    { Порядок объявления задаёт смещения: `Result` -- -$1, дальше -$8, -$9 и
      сто байт до -$6D. }
    n: Integer;
    b: Boolean;
    bUp: array[0..99] of Boolean;
  begin
    Result := False;
    try
      S := 'stop_script ' + EvalScriptExpr(T, S, -1);
      sC := AnsiLowerCase(EvalScriptExpr(T, S, 1));
      if sC <> '' then
      begin
        bOk := False;
        if (sC = 'all') or (sC = 'allex') then
        begin
          T.ParenPos := 0;
          fzZ2.v12C := 99;
          bOk := sC <> 'all';
        end
        else
        begin
          if not TryStrToInt(sC, n) then
          begin
            b := False;
            for n := 0 to 99 do
              if gScriptso3[n] <> nil then
                if sC = ExtractFileName(gScriptso3[n].Title) then
                begin
                  b := True;
                  Break;
                end;
            if not b then
            begin
              n := -1;
              T.Msg := '''' + sC + ''' not found.' + #0;
              TScanThread(T).Synchronize(T.SyncLogMsg);
            end;
          end;
          T.ParenPos := n;
          fzZ2.v12C := n;
        end;
        for n := T.ParenPos to fzZ2.v12C do
          if gScriptso3[n] <> nil then
          begin
            if bOk and (gScriptso3[n].Handle = T.Handle) then
              Continue;
            if gScriptso3[n].Handle = T.Handle then
              Continue;
            bUp[n] := gScriptso3[n].Flag91 and
              not gScriptso3[n].StopRequested;
            b := (gScriptso3[n].Suspended and bUp[n] and
              gScriptso3[n].Paused) or (gScriptso3[n].PromptWnd <> nil);
            bUp[n] := bUp[n] or gScriptso3[n].Paused or
              (gScriptso3[n].PromptWnd <> nil);
            gScriptso3[n].StopRequested := True;
            gScriptso3[n].Flag91 := False;
            gScriptso3[n].Paused := False;
            if b then
              gScriptso3[n].Resume;
            if gScriptso3[n].AutoStart then
              T.Synchronize(T.StopScriptThread);
          end;
        if T.StopRequested then
          Exit;
        repeat
        for n := T.ParenPos to fzZ2.v12C do
          if gScriptso3[n] <> nil then
            if bUp[n] then
              if gScriptso3[n].Handle <> T.Handle then
              begin
                while not gScriptso3[n].Suspended do
                begin
                  if T.StopRequested then
                    Exit;
                  SysUtils.Sleep(0);
                end;
                gScriptso3[n].StopRequested := False;
                gScriptso3[n].Paused := False;
                if gScriptso3[n].ClientWnd = 0 then
                begin
                  gScriptso3[n].ClientWnd := FindWindow('Ultima Online', nil);
                  GetWindowThreadProcessId(gScriptso3[n].ClientWnd, @nB);
                  gScriptso3[n].ProcessId := nB;
                  if gScriptso3[n].ProcessHandle <> 0 then
                    CloseHandle(gScriptso3[n].ProcessHandle);
                  if nB <> 0 then
                    gScriptso3[n].ProcessHandle :=
                      OpenProcess($638, True, nB)
                  else
                    gScriptso3[n].ProcessHandle := 0;
                end;
                gScriptso3[n].Flag91 := True;
                if gScriptso3[n].AutoStart then
                  T.Synchronize(T.AfterScriptStarted);
                if gScriptso3[n].Suspended then
                  gScriptso3[n].Resume;
              end
              else
              begin
                if (not bOk) and not T.LogToParent then
                begin
                  Result := True;
                  T.StopRequested := False;
                  T.Flag91 := True;
                  T.Paused := False;
                end;
              end;
        until True;
      end
      else
      begin
        if not T.LogToParent then
        begin
          Result := True;
          T.StopRequested := False;
          T.Flag91 := True;
          T.Paused := False;
        end;
      end;
    except
      T.Msg := 'Ошибка перезапуска' + #0;
      T.Synchronize(T.ShowScriptHint);
    end;
  end;

  { Команда скрипта `pause_script`. Довод: пусто -- пауза САМОМУ СЕБЕ;
    `all` -- всем; `allex` -- всем, кроме себя (отличие ровно в одном флаге
    `bOk`, он же и значит «кроме себя»); число -- номеру; иначе имя файла
    вкладки.

    ДВА РАЗНЫХ ИДИОМА `for` в одном теле, и путать их нельзя: по
    КОНСТАНТНЫМ границам (0..99) счётчик живёт в кадре, а по ВЫЧИСЛЯЕМЫМ --
    заводится отдельный счётчик вниз в регистре, пустота диапазона
    проверяется до входа, и ход идёт по АДРЕСУ элемента.

    `gScriptso3[n]` -- ПРЯМОЕ обращение к переменной ЧУЖОГО ЮНИТА, а не
    через указатель. Разыменование `P^[n]` собственного символа не имеет,
    поэтому кандидатом на регистр становится адрес ячейки, а не адрес
    массива. Сравнение «свой ли это поток» идёт по `Handle` TThread. }
  procedure PauseCmd;
  var
    n: Integer;
    { ПОЛЕ ЗАПИСИ, а не плоский локал: плоские имена в этой вложенной
      процедуре меняют раздачу регистров у СОСЕДНИХ вложенных того же
      диспетчера. Счётчик `for` полем записи быть не может -- поэтому `n`
      остаётся локалом, а в запись ушёл только `b`. }
    fzB: packed record
      b: Boolean;                      { держим в кадре }
    end;
  begin
    S := 'pause_script ' + EvalScriptExpr(T, S, -1);
    sC := AnsiLowerCase(EvalScriptExpr(T, S, 1));
    if sC <> '' then
    begin
      bOk := False;
      if (sC = 'all') or (sC = 'allex') then
      begin
        T.ParenPos := 0;
        fzZ2.v12C := 99;
        if sC <> 'all' then
          bOk := True;
      end
      else
      begin
        if not TryStrToInt(sC, n) then
        begin
          fzB.b := False;
          for n := 0 to 99 do
            if gScriptso3[n] <> nil then
              if sC = ExtractFileName(gScriptso3[n].Title) then
              begin
                fzB.b := True;
                Break;
              end;
          if not fzB.b then
          begin
            n := -1;
            T.Msg := '''' + sC + ''' not found.' + #0;
            TScanThread(T).Synchronize(T.SyncLogMsg);
          end;
        end;
        T.ParenPos := n;
        fzZ2.v12C := n;
      end;
      for n := T.ParenPos to fzZ2.v12C do
        if gScriptso3[n] <> nil then
        begin
          if bOk and (gScriptso3[n].Handle = T.Handle) then
            Continue;
          if (not gScriptso3[n].Paused) and gScriptso3[n].Flag91 then
          begin
            PlaySound(nil, 0, 2);
            gScriptso3[n].Paused := True;
            if gScriptso3[n].AutoStart then
              T.Synchronize(T.PauseScriptThread);
          end;
        end;
    end
    else
    begin
      T.Paused := True;
      if T.AutoStart then
        T.Synchronize(T.PauseScriptThread);
    end;
  end;

  { Команда скрипта `resume_script`. Самая короткая из звезды: довод `all`
    (после AnsiLowerCase) снимает с паузы всех, иначе это номер вкладки или
    имя её файла. Отличие от `PauseCmd` в голове: в `sC` кладётся ИСХОДНЫЙ
    итог `EvalScriptExpr`, а нижний регистр берётся временным прямо в
    сравнении -- поэтому `LStrAsg` стоит ДО `AnsiLowerCase`, а не после.
    Флаг «нашлось по имени» здесь ПЛОСКИЙ локал, а не поле записи: он живёт
    в регистре, и слотов в кадре шесть, а не семь, как у `PauseCmd`. }
  procedure ResumeCmd;
  var
    n: Integer;
    b: Boolean;
  begin
    S := 'resume_script ' + EvalScriptExpr(T, S, -1);
    sC := EvalScriptExpr(T, S, 1);
    if AnsiLowerCase(sC) = 'all' then
    begin
      T.ParenPos := 0;
      fzZ2.v12C := 99;
    end
    else
    begin
      if not TryStrToInt(sC, n) then
      begin
        b := False;
        for n := 0 to 99 do
          if gScriptso3[n] <> nil then
            if sC = ExtractFileName(gScriptso3[n].Title) then
            begin
              b := True;
              Break;
            end;
        if not b then
        begin
          n := -1;
          T.Msg := '''' + sC + ''' not found.' + #0;
          TScanThread(T).Synchronize(T.SyncLogMsg);
        end;
      end;
      T.ParenPos := n;
      fzZ2.v12C := n;
    end;
    for n := T.ParenPos to fzZ2.v12C do
      if gScriptso3[n] <> nil then
        if gScriptso3[n].Paused then
        begin
          gScriptso3[n].Paused := False;
          if gScriptso3[n].AutoStart then
            T.Synchronize(T.ResumeScriptThread);
          gScriptso3[n].Resume;
        end;
  end;

  { Команда скрипта `stop_script`. Голова, разбор довода и оба идиома `for`
    -- дословно от `PauseCmd`. Отличий три:
    * всё тело обёрнуто в `try..except` -- отсюда ВТОРОЙ кадр SEH в
    прологе, а в обработчике литеральная строка ложится в `T.Msg`
    прямым копированием, а не через LStrToString;
    * звук играет БЕЗУСЛОВНО, без проверки «стоит ли уже на паузе»;
    * вместо одного флага паузы взводится остановка, а спящему на паузе
    потоку дают проснуться -- иначе он остановки не увидит. Условие
    побудки -- ИЛИ из двух частей: поток висит приостановленным при
    взведённом «запущен» и не остановлен, но на паузе, ЛИБО у него
    открыт диалог ввода. }
  procedure StopCmd;
  var
    n: Integer;
    { ПОЛЕ ЗАПИСИ, а не плоский локал: флаг должен лежать в кадре, иначе
      не сходится число `push ecx`. }
    fzB: packed record
      b: Boolean;
    end;
  begin
    try
      S := 'stop_script ' + EvalScriptExpr(T, S, -1);
      sC := AnsiLowerCase(EvalScriptExpr(T, S, 1));
      if sC <> '' then
      begin
        bOk := False;
        if (sC = 'all') or (sC = 'allex') then
        begin
          T.ParenPos := 0;
          fzZ2.v12C := 99;
          if sC <> 'all' then
            bOk := True;
        end
        else
        begin
          if not TryStrToInt(sC, n) then
          begin
            fzB.b := False;
            for n := 0 to 99 do
              if gScriptso3[n] <> nil then
                if sC = ExtractFileName(gScriptso3[n].Title) then
                begin
                  fzB.b := True;
                  Break;
                end;
            if not fzB.b then
            begin
              n := -1;
              T.Msg := '''' + sC + ''' not found.' + #0;
              TScanThread(T).Synchronize(T.SyncLogMsg);
            end;
          end;
          T.ParenPos := n;
          fzZ2.v12C := n;
        end;
        for n := T.ParenPos to fzZ2.v12C do
          if gScriptso3[n] <> nil then
          begin
            if bOk and (gScriptso3[n].Handle = T.Handle) then
              Continue;
            PlaySound(nil, 0, 2);
            fzB.b := (gScriptso3[n].Suspended and gScriptso3[n].Flag91 and
              not gScriptso3[n].StopRequested and gScriptso3[n].Paused) or
              (gScriptso3[n].PromptWnd <> nil);
            gScriptso3[n].StopRequested := True;
            gScriptso3[n].Flag91 := False;
            gScriptso3[n].Paused := False;
            { Приведение ломает проброс записи в чтение, и это же освобождает EDX.
              Голое `fzB.b` взялось бы из регистра, куда только что положено,
              а флаг должен ПЕРЕЧИТЫВАТЬСЯ. Заодно занятый DL сдвигал
              регистр второго кадра SEH. }
            if Byte(fzB.b) <> 0 then
              gScriptso3[n].Resume;
            if gScriptso3[n].AutoStart then
              T.Synchronize(T.StopScriptThread);
          end;
      end
      else
      begin
        T.StopRequested := True;
        T.Flag91 := False;
        T.Paused := False;
        if T.AutoStart then
          T.Synchronize(T.StopScriptThread);
      end;
    except
      T.Msg := 'Ошибка остановки' + #0;
      T.Synchronize(T.ShowScriptHint);
    end;
  end;

  { Команда скрипта `start_script`. Из звезды выпадает сильнее прочих:
    `all` не понимает вовсе, ветки «всем» нет, а значит нет и цикла по
    диапазону -- работа идёт с ОДНОЙ вкладкой. Зато есть второе слово довода
    `wait`: с ним команда ждёт, пока запущенный скрипт не кончится.
    Указатель на массив скриптов держится в регистре всю функцию --
    обращений к нему больше двух десятков.
    Порядок такой: снять с паузы (проснуться потоку нужно ДО остановки),
    затем дождаться, пока поток встанет приостановленным, и только потом
    привязать окно клиента и взвести «запущен». Ожидание -- два `while` с
    `Sleep`, и оба прерываются, если остановили НАС самих. }
  procedure StartCmd;
  var
    n: Integer;
    { как в `StopCmd`: в кадре, слотов восемь }
    fzB: packed record
      b: Boolean;
    end;
    { А этот -- в BL: одно присваивание и одно чтение. }
    bWait: Boolean;
  begin
    S := 'start_script ' + EvalScriptExpr(T, S, -1);
    sC := EvalScriptExpr(T, S, 1);
    if not TryStrToInt(sC, n) then
    begin
      fzB.b := False;
      repeat
        for n := 0 to 99 do
          if gScriptso3[n] <> nil then
            if sC = ExtractFileName(gScriptso3[n].Title) then
            begin
              fzB.b := True;
              Break;
            end;
      until True;
      if not fzB.b then
      begin
        n := -1;
        T.Msg := '''' + sC + ''' not found.' + #0;
        TScanThread(T).Synchronize(T.SyncLogMsg);
        Exit;
      end;
    end;
    bWait := LowerCase(EvalScriptPoint(T, S, 2)) = 'wait';
    if gScriptso3[n] = nil then
      Exit;
    if gScriptso3[n].AutoStart then
      T.Synchronize(T.AfterScriptStarted);
    if not gScriptso3[n].Suspended then
      gScriptso3[n].StopRequested := True
    else
      if (not gScriptso3[n].StopRequested) and gScriptso3[n].Paused then
      begin
        gScriptso3[n].StopRequested := True;
        gScriptso3[n].Paused := False;
        gScriptso3[n].Resume;
      end;
    while not gScriptso3[n].Suspended do
    begin
      if T.StopRequested then
        Exit;
      SysUtils.Sleep(0);
    end;
    gScriptso3[n].StopRequested := False;
    gScriptso3[n].Paused := False;
    if not gScriptso3[n].Flag91 then
    begin
      if gScriptso3[n].ClientWnd = 0 then
      begin
        gScriptso3[n].ClientWnd := FindWindow('Ultima Online', nil);
        GetWindowThreadProcessId(gScriptso3[n].ClientWnd, @nB);
        gScriptso3[n].ProcessId := nB;
        if gScriptso3[n].ProcessHandle <> 0 then
          CloseHandle(gScriptso3[n].ProcessHandle);
        if nB <> 0 then
          gScriptso3[n].ProcessHandle := OpenProcess($638, True, nB)
        else
          gScriptso3[n].ProcessHandle := 0;
      end;
      gScriptso3[n].Flag91 := True;
      if gScriptso3[n].AutoStart then
        T.Synchronize(T.AfterScriptStarted);
    end;
    if gScriptso3[n].Suspended then
      gScriptso3[n].Resume;
    if bWait then
      while (gScriptso3[n] <> nil) and gScriptso3[n].Flag91 do
      begin
        if T.StopRequested then
          Exit;
        SysUtils.Sleep(1);
      end;
  end;

  { Команда скрипта `load_script <номер> <файл>`:
    загрузить файл в вкладку с заданным НОМЕРОМ. Номер ищется среди подписей
    вкладок (`tScript.Tabs` -- это и есть номера), нашлась -- переключаемся;
    не нашлась -- вкладка ЗАВОДИТСЯ хитростью: подпись последней временно
    подменяется на `<номер>-1`, жмётся `bAdd` (он берёт номер от последней и
    прибавляет единицу), после чего подпись возвращается на место. Обновление
    заголовков на это время выключается, прежнее состояние -- в `b`.
    Вкладка `99` -- файл процедур, он всегда последний, поэтому при подписи
    `99` берётся ПРЕДпоследняя.
    Имя файла без `\`, `/` и `:` считается лежащим в `Scripts\` рабочей папки
    -- дословно тот же идиом, что в ветках `load_array`/`save_array`.
    Дальше три случая: вкладка запущена и это ЧУЖОЙ поток -- он гасится через
    `stop_script`, файл грузится и пускается заново через `start_script`;
    вкладка запущена и это МЫ САМИ -- строки берутся прямо из редактора
    (перезапуска нет, иначе поток убил бы себя), номер строки в -1; вкладка
    не запущена -- просто грузим файл.
    Кадр: десять слотов, из них объявленный ОДИН (`b` по -$1), ещё один --
    скрытый счётчик `for`, остальные восемь строковые временные. `n` слота
    не получил вовсе -- он в ESI, как `b` у `ResumeCmd`. }
  procedure LoadScriptCmd;
  var
    fzL: packed record b: Boolean; end;
    n: Integer;
  begin
    S := 'load_script ' + EvalScriptExpr(T, S, -1);
    repeat
      sC := EvalScriptExpr(T, S, 1);
    until True;
    fzZ2.bF := True;
    T.ParenPos := fmSecondfj.tScript.TabIndex;
    fmSecondfj.FFlag1467 := True;
    nD := fmSecondfj.tScript.Tabs.IndexOf(sC);
    if nD >= 0 then
    begin
      T.Synchronize(T.SyncScriptChanging);
      fmSecondfj.tScript.TabIndex := nD;
      T.Synchronize(T.SyncScriptChange);
    end
    else
    begin
      nD := StrToInt(sC);
      sE := fmSecondfj.tScript.Tabs[fmSecondfj.tScript.Tabs.Count - 1];
      nF := fmSecondfj.tScript.Tabs.Count - 1;
      if sE = '99' then
      begin
        sE := fmSecondfj.tScript.Tabs[fmSecondfj.tScript.Tabs.Count - 2];
        nF := fmSecondfj.tScript.Tabs.Count - 2;
      end;
      sG := sE;
      fzL.b := fmSecondfj.tTabRefresh.Enabled;
      fmSecondfj.tTabRefresh.Enabled := False;
      fmSecondfj.tScript.Tabs[nF] := IntToStr(StrToInt(sC) - 1);
      T.Synchronize(T.SyncAddScriptTab);
      fmSecondfj.tScript.Tabs[nF] := sG;
      fmSecondfj.tTabRefresh.Enabled := fzL.b;
    end;
    sE := EvalScriptExpr(T, S, -2);
    if (Pos('\', sE) = 0) and (Pos('/', sE) = 0) and (Pos(':', sE) = 0) then
      sE := gTempFilefv + 'Scripts' + '\' + sE;
    nD := StrToInt(sC);
    if gScriptso3[nD].Flag91 then
    begin
      if gScriptso3[nD].Handle <> T.Handle then
      begin
        S := 'stop_script ' + sC;
        StopCmd;
      end;
      fmSecondfj.LoadScriptFile(sE);
      T.Synchronize(T.SyncScriptChanging);
      T.Synchronize(T.AfterScriptStarted);
      if gScriptso3[nD].Handle <> T.Handle then
      begin
        S := 'start_script ' + sC;
        StartCmd;
      end
      else
      begin
        T.CurLine := -1;
        fmSecondfj.sgVar.RowCount := 1;
        n := fmSecondfj.edScript.Lines.Count;
        SetLength(T.Lines, n);
        fmSecondfj.gScript.MaxValue := n;
        for n := 0 to n - 1 do
          T.Lines[n] := fmSecondfj.edScript.Lines[n];
        T.PauseCmd := fmSecondfj.edPause.Text;
      end;
    end
    else
    begin
      fmSecondfj.LoadScriptFile(sE);
      T.Synchronize(T.SyncScriptChanging);
    end;
    gScriptso3[nD].AutoStart := True;
  end;
  { Объявление вперёд: тело `CutComment` лежит последним среди вложенных,
    прямо перед телом хозяина, а зовут её отсюда, из `CallCmd`. }
  function CutComment(S: string): string; forward;


  { Команда скрипта `call <имя> <довод> ...`: вызов процедуры скрипта в
    ОТДЕЛЬНОМ потоке-спутнике. Самая большая вложенная диспетчера.
    ПОРЯДОК РАБОТЫ:
    1. заводится поток-спутник `T.SubScript`, ему достаются имя хозяина с
    приставкой `^`, окно и процесс клиента, флажок «писать в лог хозяина»
    и ссылка на КОРНЕВУЮ вкладку (нет своего хозяина -- корень мы сами);
    2. в строке команды раскрываются индексы массивов: каждое
    `%имя[выражение]` считается вычислителем и заменяется на `"значение"`;
    3. доводы со второго и дальше складываются в `SubScript.Arr43F0`;
    4. тело процедуры ищется СНАЧАЛА в строках хозяйской вкладки, а если не
    нашлось или тело пустое -- в строках вкладки 99, файла процедур;
    5. спутник пускается, хозяин ждёт его циклом `Sleep(1)` и по дороге
    переносит на него собственную паузу;
    6. в конце спутник останавливается, дожидается и освобождается.
    Ветвь поиска написана ДВАЖДЫ почти дословно; отличий ровно два -- источник
    строк и то, что доводы процедуры в первом случае берутся через
    `CutComment`, а во втором сырой строкой.
    Кадр: 37 слотов. Объявленных четыре, ещё один локал (`nAt`) живёт в
    регистре, остальные -- строковые временные. }
  procedure CallCmd;
  var
    nOpen: Integer;
    nClose: Integer;
    sPart: string;
    sIdx: string;
    nAt: Integer;                        { в EDI, слота нет }
  begin
    sC := LowerCase(EvalScriptExpr(T, S, 1));
    T.SubScript := TScanThread.NewScriptTab(True);
    { Приведение справа ломает проброс записи в чтение: голое
      `T.SubScript` взялось бы из регистра, куда только что записано, а
      поле должно ПЕРЕЧИТЫВАТЬСЯ. }
    T.SubScript.SelfRef := Pointer(T.SubScript);
    T.SubScript.Str43E0 := '^' + T.Str43E0;
    T.SubScript.Name := T.Name;
    T.SubScript.StopRequested := False;
    StartScriptThread(T.SubScript);
    T.SubScript.ClientWnd := T.ClientWnd;
    T.SubScript.ProcessHandle := T.ProcessHandle;
    T.SubScript.LogToParent := True;
    { сравнение ЧЕРЕЗ ПРИВЕДЕНИЕ даёт `mov`+`test`, голое поле -- короткое
      `cmp [mem],0`; здесь нужна загрузка }
    if Integer(T.Owner43D0) = 0 then
      a := Integer(T.SelfRef)
    else
      a := Integer(T.Owner43D0);
    T.SubScript.Owner43D0 := TScanThread(a);
    T.SubScript.Root43D4 := T.SelfRef;
    nAt := 1;
    repeat
      nAt := PosEx('%', S, nAt);
      if nAt > 0 then
      begin
        sPart := Copy(S, nAt, Length(S) - nAt + 1);
        nOpen := Pos('[', sPart);
        if nOpen > 0 then
        begin
          sPart := Copy(sPart, nOpen, Length(sPart) - nOpen + 1);
          nClose := Pos(']', sPart);
          if nClose > 0 then
          begin
            sPart := Copy(S, nAt, nClose + nOpen - 1);
            Delete(S, nAt, nClose + nOpen - 1);
            sIdx := Copy(sPart, nOpen + 1, nClose - 2);
            Delete(sPart, nOpen + 1, nClose - 2);
            sIdx := EvalScriptExpr(T, 'calc ' + sIdx, -1);
            Insert(sIdx, sPart, nOpen + 1);
            sPart := '"' + EvalScriptExpr(T, 'calc ' + sPart, -1) + '"';
            Insert(sPart, S, nAt);
            Inc(nAt, Length(sPart));
          end;
        end
        else
          Inc(nAt);
      end;
    until nAt = 0;
    nD := 2;
    sE := EvalScriptExpr(T, S, nD);
    while sE <> '' do
    begin
      SetLength(T.SubScript.Arr43F0, nD - 1);
      T.SubScript.Arr43F0[nD - 2] := sE;
      Inc(nD);
      sE := EvalScriptExpr(T, S, nD);
    end;
    nD := 0;
    while Length(TScanThread(a).Lines) - 1 >= nD do
    begin
      sH := TScanThread(a).Lines[nD];
      if (EvalScriptPoint(T, sH, 0) = 'proc') and
         (LowerCase(EvalScriptPoint(T, sH, 1)) = sC) then
      begin
        T.SubScript.Params := CutComment(sH);
        T.SubScript.ProcName := sC;
        T.SubScript.LineBase := nD + 1;
        nI := nD;
        Inc(nD);
        sE := '';
        while (sE <> 'end_proc') and (Length(TScanThread(a).Lines) > nD) do
        begin
          sH := TScanThread(a).Lines[nD];
          sE := EvalScriptPoint(T, sH, 0);
          if sE = 'proc' then
          begin
            T.StopRequested := True;
            if gLangOffsety > 0 then
              T.Msg := LoadStr(gLangOffsety + $1BC) + sC +
                       LoadStr(gLangOffsety + $1BD) + #0
            else
              T.Msg := 'Конец процедуры ' + sC +
                       ' не найден в текущем скрипте.' + #0;
            ShowScriptMsg(T);
          end;
          SetLength(T.SubScript.Lines, nD - nI);
          T.SubScript.Lines[nD - nI - 1] := TScanThread(a).Lines[nD];
          Inc(nD);
        end;
        Break;
      end;
      Inc(nD);
    end;
    T.SubScript.PauseCmd := TScanThread(a).PauseCmd;
    if ((Length(T.Lines) <= nD) and (sE <> 'end_proc')) or
       (Length(T.SubScript.Lines) <= 0) then
    begin
      nD := 0;
      if gScriptsA[99] <> nil then
      begin
        while Length(gScriptsA[99].Lines) - 1 >= nD do
        begin
          sH := gScriptsA[99].Lines[nD];
          if (EvalScriptPoint(T, sH, 0) = 'proc') and
             (LowerCase(EvalScriptPoint(T, sH, 1)) = sC) then
          begin
            T.SubScript.Params := sH;
            T.SubScript.ProcName := sC;
            T.SubScript.LineBase := nD + 1;
            nI := nD;
            Inc(nD);
            sE := '';
            while (sE <> 'end_proc') and
                  (Length(gScriptsA[99].Lines) > nD) do
            begin
              sH := gScriptsA[99].Lines[nD];
              sE := EvalScriptPoint(T, sH, 0);
              if sE = 'proc' then
              begin
                T.StopRequested := True;
                if gLangOffsety > 0 then
                  T.Msg := LoadStr(gLangOffsety + $1BC) + sC +
                           LoadStr(gLangOffsety + $1BE) + #0
                else
                  T.Msg := 'Конец процедуры ' + sC +
                           ' не найден в файле процедур.' + #0;
                ShowScriptMsg(T);
              end;
              SetLength(T.SubScript.Lines, nD - nI);
              T.SubScript.Lines[nD - nI - 1] := gScriptsA[99].Lines[nD];
              Inc(nD);
            end;
            Break;
          end;
          Inc(nD);
        end;
        T.SubScript.PauseCmd := gScriptsA[99].PauseCmd;
        if ((Length(gScriptsA[99].Lines) <= nD) and (sE <> 'end_proc')) or
           (Length(T.SubScript.Lines) <= 0) then
          nD := 0;
      end;
    end;
    if T.SubScript.Params = '' then
    begin
      T.StopRequested := True;
      if gLangOffsety > 0 then
        T.Msg := LoadStr(gLangOffsety + $1E9) + ' ''' + sC +
                 LoadStr(gLangOffsety + $1C7) + #0
      else
        T.Msg := 'Процедура ''' + sC +
                 ''' не найдена, проверьте скрипт' + #0;
      ShowScriptMsg(T);
    end
    else
      if nD = 0 then
      begin
        T.StopRequested := True;
        if gLangOffsety > 0 then
          T.Msg := LoadStr(gLangOffsety + $1BC) + sC +
                   LoadStr(gLangOffsety + $1BF) + #0
        else
          T.Msg := 'Конец процедуры ' + sC + ' не найден' + #0;
        ShowScriptMsg(T);
      end;
    T.SubScript.Flag91 := True;
    T.SubScript.Paused := False;
    T.SubScript.Resume;
    if T.IsProc then
    begin
      T.LogPrefix := 'proc ' + sC;
      T.Msg := 'started';
      TScanThread(T).Synchronize(T.SyncLogMsg);
    end;
    while (T.SubScript <> nil) and (not T.SubScript.StopRequested) and
          (not T.SubScript.Paused) do
    begin
      SysUtils.Sleep(1);
      if T.StopRequested then
        Break;
      if T.Paused then
      begin
        T.SubScript.Paused := True;
        T.Suspend;
        T.SubScript.Paused := False;
        T.SubScript.Resume;
      end;
    end;
    if T.SubScript <> nil then
    begin
      T.SubScript.StopRequested := True;
      T.SubScript.WaitFor;
      T.SubScript.Free;
      T.SubScript := nil;
    end;
  end;

  { Команда `proc <имя>`: САМО ОПРЕДЕЛЕНИЕ процедуры в тексте скрипта
    исполнять не надо, надо ПЕРЕПРЫГНУТЬ его до `end_proc`. Ищет вперёд от
    текущей строки первую, у которой ПЕРВОЕ СЛОВО -- `end_proc`, и ставит на
    неё `CurLine`. Не нашлось -- стоп скрипта и сообщение.
    Своих локалов нет вовсе, все шесть строковых слотов -- временные. Из
    кадра родителя захватываются `T`, `S`, `sC`, `sH` и запись в `nJ`. }
  procedure ProcCmd;
  begin
    nJ := T.CurLine;
    while Length(T.Lines) > nJ do
    begin
      sH := T.Lines[nJ];
      sH := EvalScriptPoint(T, sH, 0);
      if sH = 'end_proc' then
      begin
        T.CurLine := nJ;
        Break;
      end;
      Inc(nJ);
    end;
    if Length(T.Lines) <= T.CurLine then
    begin
      T.StopRequested := True;
      T.Flag91 := False;
      if gLangOffsety > 0 then
        T.Msg := LoadStr(PWord(@gLangOffsety)^ + $1BC) + sC +
                 LoadStr(gLangOffsety + $1BF) + #0
      else
        T.Msg := 'Конец процедуры ' +
                 EvalScriptExpr(T, S, 1) + ' не найден' + #0;
      ShowScriptMsg(T);
    end;
  end;

  { Команда скрипта `end_proc`: процедура кончилась,
    надо ВЕРНУТЬ ЗНАЧЕНИЕ хозяину и остановить поток-спутник.
    Возврат идёт через строковые переменные ('$'): берётся `$result` СВОЕЙ
    вкладки и кладётся в переменную с ИМЕНЕМ ПРОЦЕДУРЫ у КОРНЕВОЙ вкладки
    (`Root43D4`, поле +$43D4, которое `CallCmd` и заполняет). Нет такой
    переменной -- массив удлиняется на единицу и имя записывается.
    Если у корневой вкладки открыт вид переменных, туда же уходит строка
    `$<имя процедуры>` и таблица обновляется.
    Кадр: три слота, из них объявленный ОДИН (`V` по -$4), остальные два --
    строковые временные; `idx`, `cnt` и сама корневая вкладка живут в
    регистрах (EBX, EDI, ESI) и слотов не получают. }
  procedure EndProcCmd;
  var
    V: string;
    idx: Integer;
    cnt: Integer;
    W: TScanThread;
    { ДВА НУЛЕВЫХ ДОВОДА `FindScriptVar` -- это ПЕРЕМЕННЫЕ, а не литералы:
      литеральный ноль ушёл бы как `push 0`, а тут нужно `xor reg,reg` --
      само присваивание нуля переменной, которой достался регистр. Регистры
      волатильные, потому что дальше обе переменные мертвы. }
    nX: Integer;
    nY: Integer;
  begin
    W := TScanThread(T.Root43D4);
    nX := 0;
    nY := 0;
    idx := FindScriptVar(T, '$', 'result', nX, nY);
    V := TScanThread(T.SelfRef).Timers[idx].Value;
    idx := 0;
    cnt := Length(W.Timers);
    { СРАВНЕНИЯ ЗАПИСАНЫ ОТ `idx`, А НЕ ОТ `cnt`: операнды `cmp` меняются
      местами -- первым идёт ПРАВЫЙ операнд исходника. }
    if idx < cnt then
      repeat
        if W.Timers[idx].Name = T.ProcName then
          Break;
        Inc(idx);
      until idx >= cnt;
    if idx >= cnt then
    begin
      { ПРИВЕДЕНИЕ НА КАЖДОМ УПОТРЕБЛЕНИИ `W` ПОСЛЕ ЦИКЛА: временное от
        приведения заводится заново в КАЖДОМ базовом блоке, и дальше всё
        идёт через свой регистр. Голым именем копии не было бы. }
      SetLength(TScanThread(W).Timers, Length(TScanThread(W).Timers) + 1);
      TScanThread(W).Timers[idx].Name := T.ProcName;
    end;
    TScanThread(W).Timers[idx].Value := V;
    if TScanThread(W).AutoStart then
    begin
      TScanThread(W).VarNameNew := True;
      TScanThread(W).VarValue := V;
      TScanThread(W).VarName := '$' + T.ProcName;
      TScanThread(W).Synchronize(TScanThread(W).SyncUpdateVarGrid);
    end;
    T.StopRequested := True;
  end;

  { Пауза `wait <время>` между строками скрипта. Родная сестра
    `TScanThread.DoWait` из Unit1: те же три ранних выхода ('', '0', '1'),
    тот же разбор суффикса по ПОСЛЕДНЕЙ букве ('S'/'M'/'H' и 'C'/'N'/'R' от
    sec/min/hour), тот же показ остатка в строке состояния и то же снятие
    показа на выходе.
    Пять отличий, и все они -- от того, что здесь время берут ЧАСАМИ
    ПРОЦЕССОРА, а не GetTickCount:
    * задержка читается `TryStrToInt64` (у сестры `TryStrToInt`), поэтому
    число живёт в отдельном Int64 и лишь потом переносится в `nMs`;
    * `nMs` -- Cardinal, а не Integer, отсюда и `IntToStr64`;
    * начало отсчёта кладётся в локал ОХВАТЫВАЮЩЕЙ, а не в свой кадр --
    это единственный захват сверх `T`;
    * добавлен показ переменной `timer` в таблице переменных;
    * из ожидания выводит не только `StopRequested`, но и пауза.
    Три булевы объявлены В ПОРЯДКЕ КАДРА -- вложенных процедур тут нет,
    так что порядок объявления и есть порядок слотов. `bBig` живёт в
    регистре и переиспользуется в `T.AutoStart and bBig` -- разворачивать
    этот `and` во вложенный `if` нельзя. }
  procedure WaitDelay(S: string);
  var
    bBigShow: Boolean;
    bShown: Boolean;
    bUpd: Boolean;
    qTick: Int64;
    qNow: Int64;
    qVal: Int64;
    nMul: Integer;                        { реально: esi }
    nMs: Cardinal;                        { реально: esi }
    nCnt: Cardinal;                       { реально: edi }
    bBig: Boolean;                        { реально: bl }
  begin
    bShown := False;
    if S = '' then
      Exit;
    if S = '0' then
      Exit;
    if S = '1' then
    begin
      SysUtils.Sleep(1);
      Exit;
    end;
    if (T.PerfFreq > 0) and QueryPerformanceCounter(qTick) then
      nW3 := Trunc(qTick / T.PerfFreq * 1000)
    else
      nW3 := GetTickCount;
    if not TryStrToInt64(S, qVal) then
    begin
      if gLangOffsety > 0 then
        T.Msg := LoadStr(PWord(@gLangOffsety)^ + $1A9)
      else
        T.Msg := 'Неправильно указана задержка между строк.';
      case UpCase(S[Length(S)]) of
        'S':
          begin
            nMul := 1000;
            Delete(S, Length(S), 1);
          end;
        'M':
          begin
            nMul := 60000;
            Delete(S, Length(S), 1);
          end;
        'H':
          begin
            nMul := 3600000;
            Delete(S, Length(S), 1);
          end;
        'C':
          begin
            nMul := 1000;
            Delete(S, Length(S) - 2, 3);
          end;
        'N':
          begin
            nMul := 60000;
            Delete(S, Length(S) - 2, 3);
          end;
        'R':
          begin
            nMul := 3600000;
            Delete(S, Length(S) - 3, 4);
          end;
      else
        begin
          T.StopRequested := True;
          ShowScriptMsg(T);
          Exit;
        end;
      end;
      try
        nMs := StrToInt(S) * nMul;
      except
        T.StopRequested := True;
        ShowScriptMsg(T);
        Exit;
      end;
    end
    else
      nMs := qVal;
    nCnt := 0;
    bBig := nMs > 1000;
    bBigShow := bBig and T.ShowRemainingWait;
    if bBigShow and T.AutoStart then
    begin
      bShown := True;
      T.ShowWait := True;
      T.Msg := IntToStr(nMs);
      TScanThread(T).Synchronize(T.SyncShowWait);
    end;
    Inc(nMs, nW3);
    repeat
      if T.StopRequested or T.Paused then
      begin
        if T.AutoStart and (bShown or bBigShow) then
        begin
          T.ShowWait := False;
          T.Msg := '';
          TScanThread(T).Synchronize(T.SyncShowWait);
        end;
        Exit;
      end;
      SysUtils.Sleep(1);
      if T.AutoStart and bBig then
        if qNow + 150 < nMs then
        begin
          if T.ShowRun and (nCnt > 100) and T.ShowTimerVar then
          begin
            T.VarGridBusy := False;
            T.VarName := 'timer';
            T.VarValue := IntToStr(qNow - T.StartTick);
            { Два одинаковых жёстких приведения в одном вызове считаются ОДНИМ
              значением, и вторая загрузка `T` пропадает. Поэтому
              `SyncUpdateVarGrid` берётся у `T` без приведения. }
            TScanThread(T).Synchronize(T.SyncUpdateVarGrid);
            bUpd := True;
          end;
          if T.ShowRemainingWait and (nCnt > 100) then
          begin
            bShown := True;
            T.ShowWait := True;
            T.Msg := IntToStr(nMs - qNow);
            TScanThread(T).Synchronize(T.SyncShowWait);
            bUpd := True;
          end;
          if bUpd then
          begin
            nCnt := 0;
            bUpd := False;
          end;
          Inc(nCnt);
        end;
      if (T.PerfFreq > 0) and QueryPerformanceCounter(qTick) then
        qNow := Trunc(qTick / T.PerfFreq * 1000)
      else
        qNow := GetTickCount;
    until nMs <= qNow;
    if T.AutoStart and (bShown or bBigShow) then
    begin
      T.ShowWait := False;
      T.Msg := '';
      TScanThread(T).Synchronize(T.SyncShowWait);
    end;
  end;

  { ВЛОЖЕННАЯ процедура диспетчера, а не отдельная функция: зовут её из
    ветки `scan_dir` и рекурсивно из неё самой, а тело читает кадр родителя.
    Оба строковых довода -- ПО ЗНАЧЕНИЮ, а не `const`.
    Из кадра родителя захвачены `a`, `wr`, `nD`, `nI`, `nK3`, `nL3`, `nM` и
    `T`; адрес слота `T` кэшируется общим подвыражением, у остальных кэша
    нет.
    `nAt` и `nCur` слотов не получают -- живут в регистрах. `nAt` -- одна
    переменная на три дела: маска атрибутов, ответ `Pos` и счётчик обоих
    циклов. }
  procedure ScanDirTree(APath, AMask: string; ANoRec: Boolean);
  var
    sFull: string;
    sAttr: string;
    sName: string;
    nPrev: Integer;
    nAt: Integer;                      { EBX }
    nCur: Integer;                     { EDI }
    SR: TSearchRec;                    { кладётся ПОСЛЕ временной цикла:
                                         крупнее восьми байт и во вложенной
                                         не упомянут }
  begin
    if FindFirst(APath + '\' + '*.*', $3F, SR) = 0 then
    begin
      repeat
        if T.StopRequested then
          Exit;
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          sFull := APath + '\' + SR.Name;
          if (AMask = '') or TScanThread(T).Masks.Matches(SR.Name) then
          begin
            { РОСТ МАТРИЦЫ. `nM` -- признак «размер не тот»; растим сразу на
              тысячу строк вперёд. `wr + 1 + 7` даёт `inc eax`/`add eax,7`:
              слагаемые не переставляются, а `wr + 8` дало бы одну команду. }
            nK3 := a;
            nL3 := wr + 1 + 7;
            nM := 0;
            nD := Length(TScanThread(T).Arr48[nI].Data);
            if nK3 < nD then
              nK3 := nD
            else
              if nK3 > nD then
                nM := 1;
            if nD > 0 then
              nD := Length(TScanThread(T).Arr48[nI].Data[0]);
            if nL3 < nD then
              nL3 := nD
            else
              if nL3 > nD then
                nM := 1;
            if nM > 0 then
              SetLength(TScanThread(T).Arr48[nI].Data, nK3 + 1000, nL3);
            sAttr := '';
            TScanThread(T).Arr48[nI].Data[a - 1][0] := sFull;
            TScanThread(T).Arr48[nI].Data[a - 1][1] := ExtractFilePath(sFull);
            sName := ExtractFileName(sFull);
            { ПЕРВАЯ проверка каталога -- `<> 0` (байтовая), ВТОРАЯ (перед
              рекурсией) -- `> 0`. Это разные команды, а не одна и та же. }
            if SR.Attr and $10 <> 0 then
            begin
              TScanThread(T).Arr48[nI].Data[a - 1][3] := '';
              TScanThread(T).Arr48[nI].Data[a - 1][2] := sName;
            end
            else
            begin
              TScanThread(T).Arr48[nI].Data[a - 1][3] := ExtractFileExt(sName);
              TScanThread(T).Arr48[nI].Data[a - 1][2] := Copy(sName, 1,
                Length(sName) - Length(TScanThread(T).Arr48[nI].Data[a - 1][3]));
            end;
            TScanThread(T).Arr48[nI].Data[a - 1][4] := IntToStr(SR.Size);
            nAt := SR.Attr;
            if nAt and 1 <> 0 then
              sAttr := sAttr + 'R';
            if nAt and $20 <> 0 then
              sAttr := sAttr + 'A';
            if nAt and 4 <> 0 then
              sAttr := sAttr + 'S';
            if nAt and 2 <> 0 then
              sAttr := sAttr + 'H';
            if nAt and 8 <> 0 then
              sAttr := sAttr + 'V';
            if nAt and $10 <> 0 then
              sAttr := sAttr + 'D';
            TScanThread(T).Arr48[nI].Data[a - 1][5] := sAttr;
            sName := DateTimeToStr(FileDateToDateTime(SR.Time));
            nAt := Pos(' ', sName);
            TScanThread(T).Arr48[nI].Data[a - 1][6] := Copy(sName, 1, nAt - 1);
            Delete(sName, 1, nAt);
            TScanThread(T).Arr48[nI].Data[a - 1][7] := sName;
            TScanThread(T).Arr48[nI].Data[a - 1][8] := IntToStr(wr - 1);
            if AMask = '' then
            begin
              { БЕЗ МАСКИ путь берётся из предыдущей строки. `a` -- Cardinal,
                поэтому проверка `a > 0` идёт беззнаково; на `a = 1`
                читается строка -1 -- старая ошибка, но трогать её не
                будем. }
              if a > 0 then
                for nAt := 9 to wr + 8 - 1 do
                  TScanThread(T).Arr48[nI].Data[a - 1][nAt] :=
                    TScanThread(T).Arr48[nI].Data[a - 2][nAt];
            end
            else
            begin
              nCur := 0;
              for nAt := 9 to wr + 8 - 1 do
              begin
                nPrev := nCur;
                nCur := PosEx(#9, TScanThread(T).CmdArg2, nCur + 1);
                TScanThread(T).Arr48[nI].Data[a - 1][nAt] :=
                  Copy(TScanThread(T).CmdArg2, nPrev + 1, nCur - nPrev - 1);
              end;
            end;
            Inc(a);
          end;
          if SR.Attr and $10 > 0 then
          begin
            if AMask <> '' then
              T.CmdArg2 := T.CmdArg2 + SR.Name + #9;
            if not ANoRec then
            begin
              Inc(wr);
              ScanDirTree(sFull, AMask, False);
            end;
          end;
        end;
      until FindNext(SR) <> 0;
      SysUtils.FindClose(SR);
    end;
    if AMask <> '' then
      for nAt := Length(T.CmdArg2) - 1 downto 1 do
        if T.CmdArg2[nAt] = #9 then
        begin
          T.CmdArg2 := Copy(T.CmdArg2, 1, nAt);
          Break;
        end
        else
          if nAt = 1 then
          begin
            T.CmdArg2 := '';
            Break;
          end;
    Dec(wr);
  end;
  { Прочитать ярлык .lnk через IShellLink. На входе запись:
    в начале лежит путь к ярлыку, дальше три поля под ответы. }
  procedure ReadShortcut(var R);
  var
    SL: IShellLinkA;
    PF: IPersistFile;
    U: IUnknown;
    W: WideString;
  begin
    CoInitialize(nil);
    U := CreateComObject(CLSID_ShellLink);
    SL := U as IShellLinkA;
    PF := U as IPersistFile;
    PF.Load(PWideChar(WideString(TZzLnk(R).Path)), 0);
    SL.GetPath(TZzLnk(R).Name, $105, TZzLnk(R).Find, 2);
    SL.GetArguments(TZzLnk(R).Args, $105);
    SL.GetWorkingDirectory(TZzLnk(R).Dir, $105);
    CoUninitialize;
  end;
  { Прокрутить очередь сообщений. hWnd у PeekMessage -- результат
    GetCurrentProcess; окном это значение не является, но так оно и есть. }
  {$W+}
  procedure ScriptIdle;
  var
    M: TMsg;
  begin
    while PeekMessage(M, GetCurrentProcess, 0, 0, PM_REMOVE) do
    begin
      TranslateMessage(M);
      DispatchMessage(M);
    end;
  end;
  {$W-}

  { ПОСЛЕДНЯЯ вложенная диспетчера (стоит прямо перед его телом):
    отрезать хвостовой комментарий `//`, но только если он не внутри
    кавычек. Довод-строка -- ПО ЗНАЧЕНИЮ. }
  function CutComment(S: string): string;
  var
    { БЛИЗНЕЦ `StripComment` слово в слово, отличается РОВНО ТИПОМ `L`:
      здесь он БЕЗЗНАКОВЫЙ, поэтому условие цикла считается в Int64 --
      отсюда и лишние команды. }
    L: Cardinal;
    P, N, I: Integer;
    J: Integer;

    { Никем не зовётся. Нужна ради одного: из-за упоминания локала деда
      `CutComment` начинает нуждаться в статической ссылке, и место вызова
      в `CallCmd` получает нужную форму. Само это тело в сборку не идёт --
      его никто не зовёт. }
    procedure ZzLink;
    begin
      if nD < 0 then
        Exit;
    end;

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
          begin
            Inc(N);
            J := I;
          end;
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

begin
  { Подстановка вычисленных выражений в строку журнала: пока
    `supvaronly <строка>` даёт очередное слово, оно считается и дописывается
    в скобках после самого слова. `[...]` внутри слова -- индекс массива, он
    считается отдельной командой `calc`. }
  if T.LoggingCommands and not T.RepeatCmd then
  begin
    nSaveLine := T.CmdLine;
    nSaveLine := nSaveLine;
    nSat1 := nSat1;
    nSat2 := nSat2;
    nSat3 := nSat3;
    nSat4 := nSat4;
    nSat5 := nSat5;
    nSat6 := nSat6;
    sType := '';
    T.Msg := S;
    sE := T.LogPrefix;
    nPos := 1;
    sG := 'supvaronly ' + S;
    sV274 := EvalScriptPoint(T, sG, nPos);
    nOfs := -11;
    while Length(sV274) > 0 do
    begin
      sW278 := EvalScriptExpr(T, sG, nPos);
      if (Length(sW278) > 0) and (sW278[1] = '%') then
      begin
        nX := Length(sW278) + T.WordPos;
        nF := Length(sG);
        fzZ12.bOwn := False;
        nO := nX;
        while (nX <= nF) and not (sG[nX] in gWordCharsadq - ['[', ']']) do
        begin
          if sG[nX] = '[' then
          begin
            nO := nX;
            while nX <= nF do
            begin
              if sG[nX] = ']' then
              begin
                fzZ12.bOwn := True;
                Break;
              end;
              Inc(nX);
            end;
            Break;
          end;
          Inc(nX);
        end;
        if fzZ12.bOwn then
        begin
          nF := T.WordPos;
          sW278 := EvalScriptExpr(T, 'calc ' + sW278 + ' ' +
            Copy(sG, nO, nX - nO + 1), -1);
          Insert('(' + sW278 + ')', T.Msg, Length(sV274) + nF + nOfs);
          nOfs := nOfs + Length(sW278) + 2;
          Inc(nPos);
          sV274 := EvalScriptPoint(T, sG, nPos);
          Continue;
        end;
      end;
      if sV274 <> sW278 then
      begin
        Insert('(' + sW278 + ')', T.Msg, Length(sV274) + T.WordPos + nOfs);
        nOfs := nOfs + Length(sW278) + 2;
      end;
      Inc(nPos);
      sV274 := EvalScriptPoint(T, sG, nPos);
    end;
    T.LogPrefix := '';
    { ГОЛОЕ ИМЯ ЗДЕСЬ НАРОЧНО. Приведение завело бы кэшируемую временную, и
      второе чтение поля пропало бы. Голое имя убирает этого кандидата,
      ранги сдвигаются на один, и `E` пролезает под отсечку и получает EBX.
      Работает в паре с шестой гирей `nSat6 := nSat6;` выше. }
    T.Synchronize(TScanThread(T).SyncLogMsg);
    T.LogPrefix := sE;
    T.CmdLine := nSaveLine;
  end;
  T.RepeatCmd := False;

  case N of
  50:
    begin
    TScanThread(T).ParenPos := 8;
      sE := AnsiLowerCase(EvalScriptExpr(T, S, TScanThread(T).ParenPos * -1));
      while (sE = '') and (TScanThread(T).ParenPos >= 0) do
      begin
        Dec(TScanThread(T).ParenPos);
        sE := AnsiLowerCase(EvalScriptExpr(T, S, TScanThread(T).ParenPos * -1));
      end;
      fzZ8.vA := -1;
      fzZ8.vB := -1;
      fzZ8.vC := 1;
      fzZ8.vD := 1;
      fzZ8.vE := 1;
      fzZ8.vF := 1;
      if TScanThread(T).ParenPos <= 0 then Exit;
      if TScanThread(T).ParenPos > 7 then
        try
          fzZ8.vA := StrToInt(EvalScriptExpr(T, S, 7));
        except
          fzZ8.vA := 0;
        end;
      if TScanThread(T).ParenPos > 6 then
        try
          fzZ8.vB := StrToInt(EvalScriptExpr(T, S, 6));
        except
          fzZ8.vB := 0;
        end;
      if TScanThread(T).ParenPos > 5 then
        try
          fzZ8.vC := StrToInt(EvalScriptExpr(T, S, 5));
        except
          fzZ8.vC := 1;
        end;
      if TScanThread(T).ParenPos > 4 then
        try
          fzZ8.vD := StrToInt(EvalScriptExpr(T, S, 4));
        except
          fzZ8.vD := 1;
        end;
      if TScanThread(T).ParenPos > 3 then
        try
          fzZ8.vE := StrToInt(EvalScriptExpr(T, S, 3));
        except
          fzZ8.vE := 1;
        end;
      if TScanThread(T).ParenPos > 2 then
        try
          fzZ8.vF := StrToInt(EvalScriptExpr(T, S, 2));
        except
          fzZ8.vF := 1;
        end;
      if fzZ8.vA <= 0 then
        fzZ8.vA := -1;
      if fzZ8.vB <= 0 then
        fzZ8.vB := -1;
      if fzZ8.vC < 1 then
        fzZ8.vC := 1;
      if fzZ8.vD < 1 then
        fzZ8.vD := 1;
      if fzZ8.vE < 1 then
        fzZ8.vE := 1;
      if fzZ8.vF < 1 then
        fzZ8.vF := 1;
      if (Pos('\', sE) = 0) and (Pos('/', sE) = 0) and (Pos(':', sE) = 0) then
        sE := gTempFilefv + 'Scripts' + '\' + sE;
      AssignFile(fArr, sE);
      sG := sE;
      sE := AnsiLowerCase(EvalScriptExpr(T, S, 1));
      if sE[1] = '%' then
        Delete(sE, 1, 1);
      nI := 0;
      while Length(TScanThread(T).Arr48) > nI do
      begin
        if TScanThread(T).Arr48[nI].Name = AnsiLowerCase(sE) then
          Break;
        Inc(nI);
      end;
      if Length(TScanThread(T).Arr48) <= nI then
      begin
        SetLength(TScanThread(T).Arr48, Length(TScanThread(T).Arr48) + 1);
        TScanThread(T).Arr48[nI].Name := LowerCase(sE);
      end;
      nEdi := Length(TScanThread(T).Arr48[nI].Data);
      TScanThread(T).Msg := '';
      try
      hMtx := CreateMutex(nil, True, PChar(LowerCase(ExtractFileName(sG))));
      if hMtx <> 0 then
        if GetLastError = $B7 then
          while WaitForSingleObject(hMtx, 100) = $102 do
            if TScanThread(T).StopRequested then
              Break;
      FileMode := $40;
      try
    {$I-}
      Reset(fArr);
      { Не `if IOResult <> 0 then Msg`, а ЕСЛИ-ИНАЧЕ: весь разбор файла --
        ветка THEN, а ругань -- ELSE в самом конце try. }
      if IOResult = 0 then
      begin
        while not Eof(fArr) and (fzZ8.vD > 1) do
        begin
          ReadLn(fArr, sE);
          Dec(fzZ8.vD);
        end;
        a := fzZ8.vF - 1;
        { Условие внешнего цикла -- Eof и fzZ8.vB, а StopRequested -- ПЕРВЫЙ
          оператор тела. }
        while not Eof(fArr) and (fzZ8.vB <> 0) do
        begin
          if TScanThread(T).StopRequested then
            Break;
          Inc(a);
          Dec(fzZ8.vB);
          ReadLn(fArr, sE);
          if Length(sE) > 0 then
            if sE[Length(sE)] <> #9 then
              sE := sE + #9;
          nD := Pos(#9, sE);
          nRest := fzZ8.vC;
          while (nRest > 1) and (nD > 0) and (Length(sE) > 0) do
          begin
            Delete(sE, 1, nD);
            nD := Pos(#9, sE);
            Dec(nRest);
          end;
          wr := fzZ8.vE - 1;
          nRest := fzZ8.vA;
          { Это `for ... downto 1`, а не `while >= 1`. Имя СВОЁ, не общее
            `nLenQ`: то лежит в кадре и кандидатом на регистр не бывает. }
          for nOfs := Length(sE) downto 1 do
            if sE[nOfs] = #9 then
            begin
              Inc(wr);
              Dec(nRest);
              if nRest = 0 then
                Break;
            end;
          nK3 := a;
          nL3 := wr;
          nM := 0;
          nD := Length(TScanThread(T).Arr48[nI].Data);
          if nK3 < nD then
            nK3 := nD
          else
            if nK3 > nD then
              nM := 1;
          if nD > 0 then
            nD := Length(TScanThread(T).Arr48[nI].Data[0]);
          if nL3 < nD then
            nL3 := nD
          else
            if nL3 > nD then
              nM := 1;
          if nM > 0 then
            SetLength(TScanThread(T).Arr48[nI].Data, nK3 + 1000, nL3);
          wr := fzZ8.vE - 1;
          nRest := fzZ8.vA;
          nD := Pos(#9, sE);
          bDone := False;
          { Это WHILE, а не repeat: условие `((nD > 0) or bDone) and (nRest <> 0)`
            целиком стоит ВНИЗУ. }
          while ((Byte(nD > 0) or Byte(bDone)) <> 0) and (nRest <> 0) do
          begin
            Inc(wr);
            Dec(nRest);
            TScanThread(T).CmdArg := Copy(sE, 1, nD - 1);
            Delete(sE, 1, nD);
            T.Arr48[nI].Data[a - 1][wr - 1] := T.CmdArg;
            nD := Pos(#9, sE);
            { Сокращённое `and`, и присваивание ЯВНОЕ True/False -- отсюда запись
              прямо в слот, а не через регистр, и все три лжи сходятся в
              одно место. Сравнение идёт через Int64: `wr` Cardinal,
              Length Integer, приведения НЕТ. }
            if (nD = 0)
               and (Cardinal(wr)
                    < Length(TScanThread(T).Arr48[nI].Data[a - 1])) then
              bDone := True
            else
              bDone := False;
          end;
        end;
        { nEdi -- Integer, a -- Cardinal, отсюда снова Int64. }
        { `a` ложится на стек первым, значит слева стоит он: перестановка
          операндов машинный код не меняет, а порядок вычисления -- меняет. }
        if Cardinal(a) < nEdi then
          a := nEdi;
        SetLength(TScanThread(T).Arr48[nI].Data, a);
        CloseFile(fArr);
      end
      else
        TScanThread(T).Msg := 'Cannot open file ' + sG + #0;
      except
        { Сообщение из ШЕСТИ частей через LStrCatN, а не одно
          E.Message: имя класса (ClassName -> LStrFromString), '. ', текст
          исключения, '. ', SysErrorMessage(GetLastError) и завершающий #0. }
        on E: Exception do
        begin
          { Гири `E := E;` здесь нет нарочно: пока объект жил в регистре, она не
            давала ни одной команды и только держала ему вес, а теперь
            объект лежит в кадре, и та же строка стоила бы двух команд. }
          TScanThread(T).Msg := E.ClassName + '. ' + E.Message + '. ' +
                           SysErrorMessage(GetLastError) + #0;
        end;
      else
        { у except есть и ветка `else` -- из трёх частей: 'Unknown',
          SysErrorMessage(GetLastError) и #0 }
        TScanThread(T).Msg := 'Unknown' + SysErrorMessage(GetLastError) + #0;
      end;
      FileMode := 2;
      finally
        { ReleaseMutex и CloseHandle лежат В САМОМ finally, а не перед ним. }
        ReleaseMutex(hMtx);
        CloseHandle(hMtx);
      end;
      if T.IsProc then
        if T.Msg <> '' then
          TScanThread(T).Synchronize(T.SyncLogMsg);

    end;
  51:
    begin
    fzZ12.bAppend := False;
      sE := '';
      TScanThread(T).ParenPos := 8;
      { Это WHILE с условием ВНИЗУ, а не repeat -- та же голова, что у
        load_array. }
      while (sE = '') and (TScanThread(T).ParenPos >= 0) do
      begin
        Dec(TScanThread(T).ParenPos);
        sE := AnsiLowerCase(EvalScriptExpr(T, S, TScanThread(T).ParenPos * -1));
        if sE = 'append' then
        begin
          Delete(S, TScanThread(T).WordPos, 6);
          sE := '';
          fzZ12.bAppend := True;
        end;
      end;
      fzZ8.vA := -1;
      fzZ8.vB := -1;
      fzZ8.vE := 1;
      fzZ8.vF := 1;
      if TScanThread(T).ParenPos <= 0 then Exit;
      if TScanThread(T).ParenPos > 5 then
        try
          fzZ8.vA := StrToInt(EvalScriptExpr(T, S, 5));
        except
          fzZ8.vA := 0;
        end;
      if TScanThread(T).ParenPos > 4 then
        try
          fzZ8.vB := StrToInt(EvalScriptExpr(T, S, 4));
        except
          fzZ8.vB := 0;
        end;
      if TScanThread(T).ParenPos > 3 then
        try
          fzZ8.vE := StrToInt(EvalScriptExpr(T, S, 3));
        except
          fzZ8.vE := 1;
        end;
      if TScanThread(T).ParenPos > 2 then
        try
          fzZ8.vF := StrToInt(EvalScriptExpr(T, S, 2));
        except
          fzZ8.vF := 1;
        end;
      if fzZ8.vA <= 0 then
        fzZ8.vA := -1;
      if fzZ8.vB <= 0 then
        fzZ8.vB := -1;
      if fzZ8.vE < 1 then
        fzZ8.vE := 1;
      if fzZ8.vF < 1 then
        fzZ8.vF := 1;
      if (Pos('\', sE) = 0) and (Pos('/', sE) = 0) and (Pos(':', sE) = 0) then
        sE := gTempFilefv + 'Scripts' + '\' + sE;
      bBinz := False;
      if bBinz then
        AssignFile(fBin, sE)
      else
        AssignFile(fArr, sE);
      try
      hMtx := CreateMutex(nil, True, PChar(LowerCase(ExtractFileName(sE))));
      if hMtx <> 0 then
        if GetLastError = $B7 then
          while WaitForSingleObject(hMtx, 100) = $102 do
            if TScanThread(T).StopRequested then
              Break;
      if bBinz then
        Rewrite(fBin, 1)
      else
        Rewrite(fArr);
      sE := AnsiLowerCase(EvalScriptExpr(T, S, 1));
      if sE[1] = '%' then
        Delete(sE, 1, 1);
      nI := 0;
      try
      while Length(TScanThread(T).Arr48) > nI do
      begin
        if TScanThread(T).Arr48[nI].Name = AnsiLowerCase(sE) then
          Break;
        Inc(nI);
      end;
      if Length(TScanThread(T).Arr48) > nI then
        if Length(TScanThread(T).Arr48[nI].Data) > 0 then
          for a := fzZ8.vF - 1 to Length(TScanThread(T).Arr48[nI].Data) - 1 do
          begin
            TScanThread(T).CmdArg := '';
            nRest := fzZ8.vA;
            for wr := fzZ8.vE - 1 to Length(TScanThread(T).Arr48[nI].Data[a]) - 1 do
            begin
              if bBinz then
              begin
                SetLength(sBin, 2);
                { Ведущий #0 не описка: в двоичный поток пара байт идёт
                  старшим вперёд, поэтому знака здесь два -- #0 и #9. }
                sBin := #0#9;
                TScanThread(T).CmdArg := TScanThread(T).CmdArg +
                  TScanThread(T).Arr48[nI].Data[a][wr];
                BlockWrite(fBin, TScanThread(T).CmdArg, Length(TScanThread(T).CmdArg));
                BlockWrite(fBin, sBin, Length(sBin));
              end
              else
                TScanThread(T).CmdArg := TScanThread(T).CmdArg +
                  TScanThread(T).Arr48[nI].Data[a][wr] + #9;
              Dec(nRest);
              if nRest = 0 then
                Break;
            end;
            if bBinz then
            begin
              SetLength(sBin, 4);
              { То же самое: четыре знака -- #0 #13 #0 #10. }
              sBin := #0#13#0#10;
              BlockWrite(fBin, sBin, Length(sBin));
            end
            else
              { Один WriteLn с доводом, а не Write плюс пустой WriteLn. }
              WriteLn(fArr, TScanThread(T).CmdArg);
            Dec(fzZ8.vB);
            if fzZ8.vB = 0 then
              Break;
          end;
      except
        { Обработчик НЕ пустой: при IsProc в Msg кладётся 'Ops...' и зовётся
          Synchronize(SyncLogMsg). }
        if TScanThread(T).IsProc then
        begin
          TScanThread(T).Msg := 'Ops...';
          TScanThread(T).Synchronize(T.SyncLogMsg);
        end;
      end;
      { Закрытие файла тоже развилка по bBinz, причём в двоичной ветви перед
        CloseFile стоит Finalize(sBin). FileMode тут НЕ трогается. }
      if bBinz then
      begin
        Finalize(sBin);
        CloseFile(fBin);
      end
      else
        CloseFile(fArr);
      finally
        { ReleaseMutex и CloseHandle -- тело finally; ветка на этом КОНЧАЕТСЯ,
          хвостовой проверки IsProc/Msg тут нет. }
        ReleaseMutex(hMtx);
        CloseHandle(hMtx);
      end;
    end;
  126:
    begin
      sE := AnsiLowerCase(EvalScriptPoint(T, S, 1));
      if Length(sE) < 2 then
        Exit;
      cKz := sE[1];
      Delete(sE, 1, 1);
      a := 1;
      wr := 1;
      nI := FindScriptVar(T, cKz, sE, a, wr);
      nO := 0;
      if TryStrToInt(EvalScriptExpr(T, S, 2), nX) then
      begin
        if nX > 0 then
        begin
          nF := 0;
          Dec(nX);
        end
        else
        begin
          nF := Abs(nX) - 1;
          nX := -1;
        end;
        if AnsiLowerCase(Copy(EvalScriptPoint(T, S, 3), 1, 1)) = 'd' then
          nO := 1;
      end
      else
      begin
        nX := 0;
        if AnsiLowerCase(Copy(EvalScriptPoint(T, S, 2), 1, 1)) = 'd' then
          nO := 1;
      end;
      if TScanThread(T).ParenPos > 0 then
        nP := T.ScriptStrToInt(TScanThread(T).CmdArg2);
      { на стек после High идёт СНАЧАЛА nX, а ПОТОМ nF -- порядок доводов
        H, D, I }
      if nX >= 0 then
        SortScriptArray(T, nI, 0,
          High(TScanThread(T).Arr48[nI].Data), nX, nF, nO = 0)
      else
        SortScriptArray2(T, nI, 0,
          High(TScanThread(T).Arr48[nI].Data[0]), nX, nF, nO = 0);

    end;
  127:
    begin
      sE := AnsiLowerCase(EvalScriptPoint(T, S, 1));
      if Length(sE) < 2 then
        Exit;
      cKz := sE[1];
      Delete(sE, 1, 1);
      a := 1;
      wr := 1;
      nI := FindScriptVar(T, cKz, sE, a, wr);
      fzZ8.vB := 1;
      if TryStrToInt(EvalScriptExpr(T, S, 2), fzZ8.vF) then
        if not TryStrToInt(EvalScriptExpr(T, S, 3), fzZ8.vB) then
          fzZ8.vB := 1;
      fzZ8.vB := Abs(fzZ8.vB);
      if TScanThread(T).ParenPos > 0 then
        nP := T.ScriptStrToInt(TScanThread(T).CmdArg2);
      if fzZ8.vF < 0 then
      begin
        fzZ8.vF := Abs(fzZ8.vF) - 1;
        if Length(TScanThread(T).Arr48[nI].Data) < fzZ8.vF + fzZ8.vB then
          fzZ8.vB := Length(TScanThread(T).Arr48[nI].Data) - fzZ8.vF;
        for nF := fzZ8.vF to Length(TScanThread(T).Arr48[nI].Data) - 1 - fzZ8.vB do
          TScanThread(T).Arr48[nI].Data[nF] :=
            TScanThread(T).Arr48[nI].Data[nF + fzZ8.vB];
        SetLength(TScanThread(T).Arr48[nI].Data,
          Length(TScanThread(T).Arr48[nI].Data) - fzZ8.vB);
      end
      else
      begin
        Dec(fzZ8.vF);
        { Условие ОБРАТНОЕ: обнуление массива -- ветка ELSE и лежит В КОНЦЕ,
          а не первой. }
        if Length(TScanThread(T).Arr48[nI].Data[0]) <> fzZ8.vB then
        begin
          if Length(TScanThread(T).Arr48[nI].Data[0]) < fzZ8.vF + fzZ8.vB then
            fzZ8.vB := Length(TScanThread(T).Arr48[nI].Data[0]) - fzZ8.vF;
          for nF := 0 to Length(TScanThread(T).Arr48[nI].Data) - 1 do
          begin
            for nX := fzZ8.vF to
              Length(TScanThread(T).Arr48[nI].Data[nF]) - 1 - fzZ8.vB do
              TScanThread(T).Arr48[nI].Data[nF][nX] :=
                TScanThread(T).Arr48[nI].Data[nF][nX + fzZ8.vB];
            SetLength(TScanThread(T).Arr48[nI].Data[nF],
              Length(TScanThread(T).Arr48[nI].Data[nF]) - fzZ8.vB);
          end;
        end
        else
          SetLength(TScanThread(T).Arr48[nI].Data, 0, 0);
      end;

    end;
  0:
    begin
    nJ := T.CurLine + 1;
    nDepth := 0;
    while Length(T.Lines) > nJ do
    begin
      sH := T.Lines[nJ];
      sH := EvalScriptPoint(T, sH, 0);
      if (sH = 'while') or (sH = 'while_not') or (sH = 'repeat') or (sH = 'for') then Inc(nDepth);
      if (sH = 'end_while') or (sH = 'end_repeat') or (sH = 'end_for') then Dec(nDepth);
      if nDepth < 0 then Break;
      Inc(nJ);
    end;
    if Length(T.Lines) <= nJ then
    begin
      if gLangOffsety > 0 then
      T.Msg := LoadStr(gLangOffsety + $1C1) + #0
    else
      T.Msg := 'Не могу найти конец цикла, проверьте скрипт'#0;
    ShowScriptMsg(T);
    if T.ToMsgBox then
    begin
      T.StopRequested := True;
      T.Flag91 := False;
      T.RestartFlag := True;
    end;
    end
    else
      T.CurLine := nJ - 1;
    end;
  1:
    begin
      if not TryStrToInt(EvalScriptExpr(T, S, 1), nPos) then
        nPos := 1;
      nJ := TScanThread(T).CurLine + 1;
      nLevel := nPos - 1;
      fzZ8.nRep := 0;
      fzZ8.nFor := 0;
      fzZ8.nSw := 0;
      while Length(TScanThread(T).Lines) > nJ do
      begin
        sH := TScanThread(T).Lines[nJ];
        sH := EvalScriptPoint(T, sH, 0);
        if (sH = 'end_switch') and (fzZ8.nRep = 0) and (fzZ8.nFor = 0) and (nLevel = 0) then
          Break;
        if (sH = 'while') or (sH = 'while_not') or (sH = 'switch') then
          Inc(nLevel);
        if sH = 'repeat' then
        begin
          Inc(nLevel);
          Inc(fzZ8.nRep);
        end;
        if sH = 'for' then
        begin
          Inc(nLevel);
          Inc(fzZ8.nFor);
        end;
        if (sH = 'end_while') or (sH = 'end_switch') then
          Dec(nLevel);
        if sH = 'end_repeat' then
        begin
          Dec(nLevel);
          Dec(fzZ8.nRep);
        end;
        if sH = 'end_for' then
        begin
          Dec(nLevel);
          Dec(fzZ8.nFor);
        end;
        if nLevel < 0 then
          Break;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Lines) <= nJ then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1C1) + #0
        else
          TScanThread(T).Msg := 'Не могу найти конец цикла, проверьте скрипт' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          T.StopRequested := True;
          T.Flag91 := False;
          T.RestartFlag := True;
        end;
        Exit;
      end;
      try
        if fzZ8.nRep <> 0 then
          SetLength(TScanThread(T).Arr54, Length(TScanThread(T).Arr54) + fzZ8.nRep);
        if fzZ8.nFor <> 0 then
          SetLength(TScanThread(T).Arr50, Length(TScanThread(T).Arr50) + fzZ8.nFor);
      except
        TScanThread(T).StopRequested := True;
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1C2) + #0
        else
          TScanThread(T).Msg := 'Нечего прерывать, проверьте скрипт' + #0;
        ShowScriptMsg(TScanThread(T));
      end;
      if TScanThread(T).StopRequested then
      begin
        if T.ToMsgBox then
        begin
          T.StopRequested := True;
          T.Flag91 := False;
          T.RestartFlag := True;
        end
        else
          T.StopRequested := False;
      end
      else
        T.CurLine := nJ;

    end;
  102, 103, 104, 105, 106, 107, 108:
    begin
      nX := 0;
      nF := 0;
      sC := FindParenGroup(T, S, 1, nX, nF);
      if nF <= 0 then
        Exit;
      if Length(sC) <= 0 then
        Exit;
      sQ := '';
      sG := '';
      case N of
        $66, $67:
          begin
            nLenQ := 0;
            fzZ10.nPos2 := 0;
            if sC[1] = '"' then
              sQ := FindQuotedGroup(T, sC, 1, nLenQ, fzZ10.nPos2)
            else
              sQ := EvalScriptExpr(T, 'calc ' + sC, 1);
            if sC[Length(sC)] = '"' then
              sG := FindQuotedGroup(T, sC, fzZ10.nPos2 + 1, nLenQ, fzZ10.nPos2)
            else
              sG := EvalScriptExpr(T, 'calc ' + sC, -2);
          end;
        $68, $6B, $6C:
          begin
            sQ := FindQuotedGroup(T, sC, 1, nLenQ, fzZ10.nPos2);
            if sQ = '' then
              sQ := sC;
            sQ := EvalScriptExpr(T, 'calc ' + sQ, -1);
          end;
        $69, $6A:
          begin
            if sC[1] = '"' then
              sQ := FindQuotedGroup(T, sC, 1, nLenQ, fzZ10.nPos2)
            else
              sQ := EvalScriptExpr(T, 'calc ' + sC, 1);
            sG := AnsiLowerCase(EvalScriptExpr(T, 'calc ' + sC, -2));
          end;
      end;
      case N of
        $66:
          begin
            nLenQ := Pos('\', sG);
            if nLenQ <= 0 then
              nLenQ := Pos('/', sG);
            if nLenQ <= 0 then
              sG := ExtractFilePath(sQ) + sG;
            RenameFile(sQ, sG);
          end;
        $67:
          CopyFile(PChar(sQ), PChar(sG), True);
        $69:
          begin
            nLenQ := FileGetAttr(sQ);
            if nLenQ >= 0 then
            begin
              fzZ10.nRows := Pos('r', sG);
              if fzZ10.nRows > 0 then
                case sG[fzZ10.nRows - 1] of
                  '+': nLenQ := nLenQ or 1;
                  '-': nLenQ := nLenQ and not 1;
                end;
              fzZ10.nRows := Pos('a', sG);
              if fzZ10.nRows > 0 then
                case sG[fzZ10.nRows - 1] of
                  '+': nLenQ := nLenQ or 32;
                  '-': nLenQ := nLenQ and not 32;
                end;
              fzZ10.nRows := Pos('s', sG);
              if fzZ10.nRows > 0 then
                case sG[fzZ10.nRows - 1] of
                  '+': nLenQ := nLenQ or 4;
                  '-': nLenQ := nLenQ and not 4;
                end;
              fzZ10.nRows := Pos('h', sG);
              if fzZ10.nRows > 0 then
                case sG[fzZ10.nRows - 1] of
                  '+': nLenQ := nLenQ or 2;
                  '-': nLenQ := nLenQ and not 2;
                end;
              FileSetAttr(sQ, nLenQ);
            end;
          end;
        $6A:
          try
            SetLastError(FileSetDate(sQ, DateTimeToFileDate(StrToDateTime(sG))));
          except
          end;
        $68:
          SysUtils.DeleteFile(sQ);
        $6B:
          begin
            if Length(sQ) > 0 then
            begin
              if (Length(sQ) > 2) and ((sQ[1] = '\') or (sQ[2] = ':')) then
              else
                sQ := GetCurrentDir + '\' + sQ;
              if ForceDirectories(sQ) then
                SetLastError(0)
              else
                SetLastError(2);
            end;
          end;
        $6C:
          RemoveDir(sQ);
      end;
      TScanThread(T).ClipLen := GetLastError;
      if TScanThread(T).IsProc then
        if fmSecondfj.miFileOpError.Checked then
        begin
          TScanThread(T).LogPrefix := gCmdList2jj[N];
          TScanThread(T).Msg := SysErrorMessage(TScanThread(T).ClipLen);
          TScanThread(T).Synchronize(T.SyncLogMsg);
          TScanThread(T).LogPrefix := '';
        end;

    end;
  109:
    begin
      nX := 0;
      nF := 0;
      sC := FindParenGroup(T, S, 1, nX, nF);
      if nF <= 0 then
        Exit;
      if Length(sC) <= 0 then
        Exit;
      sQ := '';
      sG := '';
      nLenQ := 0;
      fzZ10.nPos2 := 0;
      sQ := EvalScriptExpr(T, 'set ' + sC, 1);
      sG := AnsiLowerCase(EvalScriptPart(T, 'calc ' + sC, 0));
      if Copy(sG, 1, 7) = 'norecur' then
      begin
        sC := Copy(sC, 1, TScanThread(T).WordPos - 1);
        fzZ2.bF := True;
      end
      else
        fzZ2.bF := False;
      if TScanThread(T).InLua then
      begin
        sG := TScanThread(T).DirMask[0];
        TScanThread(T).CmdArg := AnsiLowerCase(TScanThread(T).DirMask[1]);
      end
      else
      begin
        sG := EvalScriptPoint(T, 'calc ' + sC, -2);
        TScanThread(T).CmdArg := AnsiLowerCase(EvalScriptExpr(T, 'calc ' + sG, -2));
        sG := EvalScriptExpr(T, 'calc ' + sG, 1);
      end;
      sE := AnsiLowerCase(sQ);
      if sE[1] = '%' then
        Delete(sE, 1, 1);
      nI := 0;
      while Length(TScanThread(T).Arr48) > nI do
      begin
        if TScanThread(T).Arr48[nI].Name = AnsiLowerCase(sE) then
          Break;
        Inc(nI);
      end;
      if Length(TScanThread(T).Arr48) <= nI then
      begin
        SetLength(TScanThread(T).Arr48, Length(TScanThread(T).Arr48) + 1);
        TScanThread(T).Arr48[nI].Name := LowerCase(sE);
      end;
      if sG = '' then
      begin
        SetLength(TScanThread(T).Arr48[nI].Data, 1, 4);
        TScanThread(T).Arr48[nI].Data[0][3] := GetCurrentDir;
        Exit;
      end;
      nX := Length(sG);
      if sG[nX] = '\' then
        Delete(sG, nX, 1);
      a := 1;
      wr := 1;
      TScanThread(T).CmdArg2 := '';
      fzZ12.hW := 0;
      TScanThread(T).Masks.Masks := TScanThread(T).CmdArg;
      ScanDirTree(sG, TScanThread(T).CmdArg, fzZ2.bF);
      Dec(a);
      SetLength(TScanThread(T).Arr48[nI].Data, a);
      TScanThread(T).ClipLen := Length(TScanThread(T).Arr48[nI].Data);
      if TScanThread(T).IsProc then
        if fmSecondfj.miFileOpError.Checked then
        begin
          TScanThread(T).LogPrefix := gCmdList2jj[N];
          { Сообщение собирается ИЗ ДВУХ ЧАСТЕЙ, а не SysErrorMessage: сперва
            'Array Size = ' + число строк, и если строк больше нуля --
            дописывается '  x  ' + длина ПЕРВОЙ строки. }
          TScanThread(T).Msg := 'Array Size = ' + IntToStr(TScanThread(T).ClipLen);
          if TScanThread(T).ClipLen > 0 then
            TScanThread(T).Msg := TScanThread(T).Msg + '  x  ' +
              IntToStr(Length(TScanThread(T).Arr48[nI].Data[0]));
          TScanThread(T).Synchronize(T.SyncLogMsg);
          TScanThread(T).LogPrefix := '';
        end;

    end;
  2:
    begin
      nJ := 0;
      while Length(TScanThread(T).Arr50) > nJ do
      begin
        if TScanThread(T).Arr50[nJ].Line = T.CurLine then
          Break;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Arr50) > nJ then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1CB) + #0
        else
          TScanThread(T).Msg := 'Ошибка интерпретации скрипта (for).' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
        Exit;
      end;
      sE := LowerCase(EvalScriptExpr(T, S, 1));
      S := 'for ' + sE + ' ' + EvalScriptExpr(T, S, -2);
      nI := 0;
      if (sE[1] = '#') and (Length(sE) >= 2) then
      begin
        Delete(sE, 1, 1);
        nX := Length(TScanThread(T).Vars);
        while nI < nX do
        begin
          if TScanThread(T).Vars[nI].Name = sE then
            Break;
          Inc(nI);
        end;
        if nI < nX then
        begin
          TScanThread(T).VarValue := EvalScriptExpr(T, S, 2);
          TScanThread(T).Vars[nI].Value := StrToInt64Def(TScanThread(T).VarValue, 0);
        end
        else
        begin
          SetLength(TScanThread(T).Vars, nX + 1);
          TScanThread(T).VarGridBusy := True;
          TScanThread(T).Vars[nI].Name := LowerCase(sE);
          TScanThread(T).VarValue := EvalScriptExpr(T, S, 2);
          TScanThread(T).Vars[nI].Value := StrToInt64Def(TScanThread(T).VarValue, 0);
        end;
        T.VarName := '#' + T.Vars[nI].Name;
        if T.AutoStart then
          if T.ShowRun then
          begin
            T.VarRow := nI + 1;
            T.Synchronize(T.SyncUpdateVarGrid);
          end;
        nK3 := TScanThread(T).Vars[nI].Value;
        SetLength(TScanThread(T).Arr50, Length(TScanThread(T).Arr50) + 1);
        nX := Length(TScanThread(T).Arr50) - 1;
        TScanThread(T).Arr50[nX].Name := TScanThread(T).Vars[nI].Name;
        TScanThread(T).Arr50[nX].Line := TScanThread(T).CurLine;
      end
      else
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := '(' + IntToStr(TScanThread(T).CurLine) +
            LoadStr(gLangOffsety + $1CC) + #0
        else
          TScanThread(T).Msg := '(' + IntToStr(TScanThread(T).CurLine) +
            '): Немогу определить имя переменной' + #0;
        ShowScriptMsg(TScanThread(T));
      end;
      if not TryStrToInt(EvalScriptExpr(T, S, 4), nI) then
        nI := 1;
      nX := Length(TScanThread(T).Arr50) - 1;
      TScanThread(T).Arr50[nX].Step := nI;
      TScanThread(T).Arr50[nX].Limit := StrToInt(EvalScriptExpr(T, S, 3));
      nJ := TScanThread(T).CurLine + 1;
      nSaveLine := 0;
      while Length(TScanThread(T).Lines) > nJ do
      begin
        sH := TScanThread(T).Lines[nJ];
        sH := EvalScriptPoint(T, sH, 0);
        if sH = 'for' then Inc(nSaveLine);
        if sH = 'end_for' then Dec(nSaveLine);
        if nSaveLine < 0 then
        begin
          TScanThread(T).Arr50[Length(TScanThread(T).Arr50) - 1].EndLine := nJ;
          Break;
        end;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Lines) <= nJ then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1CD) + #0
        else
          TScanThread(T).Msg := 'Не могу найти конец цикла: "End_for", проверьте скрипт' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
      end
      else
      begin
        nF := TScanThread(T).Arr50[nX].Step;
        fzZ2.bF := ((nF > 0) and (TScanThread(T).Arr50[nX].Limit < nK3)) or
                 ((nF < 0) and (TScanThread(T).Arr50[nX].Limit > nK3));
        if fzZ2.bF then
          TScanThread(T).CurLine := TScanThread(T).Arr50[nX].EndLine - 1;
      end;

    end;
  3:
    begin
      nI := 0;
      nX := Length(TScanThread(T).Arr50) - 1;
      while Length(TScanThread(T).Vars) > nI do
      begin
        if TScanThread(T).Vars[nI].Name = TScanThread(T).Arr50[nX].Name then
          Break;
        Inc(nI);
      end;
      if Length(TScanThread(T).Vars) > nI then
      begin
        nF := TScanThread(T).Arr50[nX].Step;
        fzZ2.bF := ((nF > 0) and
                (nF + TScanThread(T).Vars[nI].Value <= TScanThread(T).Arr50[nX].Limit)) or
               ((nF < 0) and
                (nF + TScanThread(T).Vars[nI].Value >= TScanThread(T).Arr50[nX].Limit)) or
               (nF = 0);
        if fzZ2.bF then
        begin
          TScanThread(T).Vars[nI].Value := TScanThread(T).Arr50[nX].Step +
            TScanThread(T).Vars[nI].Value;
          if TScanThread(T).AutoStart then
            if TScanThread(T).ShowRun then
            begin
              TScanThread(T).VarName := '#' + TScanThread(T).Vars[nI].Name;
              TScanThread(T).VarValue := IntToStr(TScanThread(T).Vars[nI].Value);
              TScanThread(T).VarRow := nI + 1;
              TScanThread(T).Synchronize(T.SyncUpdateVarGrid);
            end;
          TScanThread(T).CurLine := TScanThread(T).Arr50[nX].Line;
        end
        else
          SetLength(TScanThread(T).Arr50, nX);
      end
      else
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := '(' + IntToStr(TScanThread(T).CurLine) +
            LoadStr(gLangOffsety + $1CE) + #0
        else
          TScanThread(T).Msg := '(' + IntToStr(TScanThread(T).CurLine) +
            '): Немогу найти имя переменной for' + #0;
        ShowScriptMsg(TScanThread(T));
      end;

    end;
  49:
    begin
    T.ParenPos := 0;
      T.CmdArg := '';
      sE := AnsiLowerCase(EvalScriptExpr(T, S, 1));
      bOk := True;
    if sE = 'mouse_pos' then
      begin
        GetCursorPos(PPoint(@ptX)^);
        if T.InLua then
          nF := 2
        else
          nF := 4;
        if AnsiLowerCase(EvalScriptExpr(T, S, nF)) <> 'abs' then
          ScreenToClient(T.ClientWnd, PPoint(@ptX)^);
        if T.InLua then
        begin
          T.LuaRes1 := ptX;
          T.LuaRes2 := ptYQ;
        end
        else
        begin
          sE := EvalScriptExpr(T, S, 2);
          sQ := EvalScriptExpr(T, S, 3);
          if (Length(sE) >= 2) and ((sE[1] = '#') or (sE[1] = '$')) and
             (Length(sQ) >= 2) and ((sQ[1] = '#') or (sQ[1] = '$')) then
          begin
            cKz := sE[1];
            Delete(sE, 1, 1);
            nI := FindScriptVar(T, cKz, sE, a, wr);
            sE := IntToStr(ptX);
            StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
            cKz := sQ[1];
            Delete(sQ, 1, 1);
            sE := sQ;
            nI := FindScriptVar(T, cKz, sE, a, wr);
            sE := IntToStr(ptYQ);
            StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
          end
          else
            bOk := False;
        end;
      end
    else if sE = 'color' then
      begin
        sE := EvalScriptExpr(T, S, 2);
        if (Length(sE) >= 2) and ((sE[1] = '#') or (sE[1] = '$')) then
        begin
          cKz := sE[1];
          Delete(sE, 1, 1);
          nI := FindScriptVar(T, cKz, sE, a, wr);
          nD := nI;
          S := 'calc ' + EvalScriptExpr(T, S, -3);
          sW278 := 'calc ' + EvalScriptExpr(T, S, -1);
          ptG.X := StrToInt(EvalScriptExpr(T, sW278, 1));
          ptG.Y := StrToInt(EvalScriptExpr(T, sW278, 2));
          sV274 := AnsiLowerCase(EvalScriptExpr(T, sW278, 3));
          sW278 := AnsiLowerCase(EvalScriptExpr(T, sW278, 4));
          if not TryStrToInt(sV274, fzZ12.hW) then
            fzZ12.hW := 0;
          if (sV274 = 'abs') or (sW278 = 'abs') then
          begin
            if fzZ12.hW > 0 then
            begin
              ScreenToClient(fzZ12.hW, ptG);
              fzZ6.nColor := 0;
            end
            else
            begin
              fzZ12.dc := GetDC(0);
              fzZ6.nColor := GetPixel(fzZ12.dc, ptG.X, ptG.Y);
              ReleaseDC(0, fzZ12.dc);
            end;
          end
          else if fzZ12.hW > 0 then
            fzZ6.nColor := 0
          else
          begin
            ClientToScreen(T.ClientWnd, ptG);
            fzZ12.dc := GetDC(0);
            fzZ6.nColor := GetPixel(fzZ12.dc, ptG.X, ptG.Y);
            ReleaseDC(0, fzZ12.dc);
          end;
          if fzZ6.nColor = 0 then
          begin
            if fzZ12.hW > 0 then
              T.CapWnd := fzZ12.hW
            else
              T.CapWnd := T.ClientWnd;
            T.CapTo := ptG;
            T.CapFrom := ptG;
            Inc(T.CapTo.X);
            Inc(T.CapTo.Y);
            try
              T.ShotFailed := False;
              T.Synchronize(T.CaptureWindowBits);
            except
              T.ShotFailed := True;
            end;
            if T.ShotFailed then
              sQ := '-6';
            if T.ShotFailed and T.IsProc then
            begin
              if T.IsProc then
              begin
                T.Msg := 'error retrieving pictures';
                TScanThread(T).Synchronize(T.SyncLogMsg);
              end;
            end
            else
            begin
              fzZ13B.pB2 := T.ShotBits;
              fzZ6.nColor := fzZ13B.pB2^[2] + fzZ13B.pB2^[1] shl 8 + fzZ13B.pB2^[0] shl 16;
            end;
            GlobalFree(THandle(T.ShotBits));
            T.ShotBits := nil;
            SetLength(arrB, 0);
            ReleaseDC(0, fzZ12.dc);
          end;
          sE := IntToStr(fzZ6.nColor);
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end
        else
          bOk := False;
      end
    else if sE = 'number' then
      begin
        sE := EvalScriptExpr(T, S, 2);
        sQ := EvalScriptExpr(T, S, 3);
        if (Length(sE) >= 2) and ((sE[1] = '#') or (sE[1] = '$')) and
           (Length(sQ) >= 2) and ((sQ[1] = '#') or (sQ[1] = '$')) then
        begin
          cKz := sE[1];
          Delete(sE, 1, 1);
          nI := FindScriptVar(T, cKz, sE, a, wr);
          S := 'calc ' + EvalScriptExpr(T, S, -4);
          S := 'calc ' + EvalScriptExpr(T, S, -1);
          for nD := 1 to Length(S) do
            case S[nD] of
              '(', ')', ',', '.', '[', ']': S[nD] := ' ';
            end;
          fzZ2.bF := False;
          nD := 1;
          fzZ12.vNum := -1;
          sE := EvalScriptExpr(T, S, nD);
          while (not fzZ2.bF) and (sE <> '') do
          begin
            if (Length(sE) > 1) and (sE[2] <> 'x') and
               (sE[1] in ['0', 'A'..'F', 'a'..'f']) then
              sE := '0x' + sE;
            try
              fzZ12.vNum := StrToInt64(sE);
              fzZ2.bF := True;
              Break;
            except
            end;
            Inc(nD);
            sE := EvalScriptExpr(T, S, nD);
          end;
          if not fzZ2.bF then
          begin
            sE := '-1';
            Dec(nD);
          end;
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
          cKz := sQ[1];
          Delete(sQ, 1, 1);
          sE := sQ;
          nI := FindScriptVar(T, cKz, sE, a, wr);
          sE := IntToStr(nD);
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end
        else
          bOk := False;
      end
    else if sE = 'word' then
      begin
        sE := EvalScriptExpr(T, S, 2);
        if (Length(sE) >= 2) and (sE[1] = '$') then
        begin
          cKz := sE[1];
          Delete(sE, 1, 1);
          S := 'calc ' + EvalScriptExpr(T, S, -3);
          S := 'calc ' + EvalScriptExpr(T, S, -1);
          for nD := 1 to Length(S) do
            case S[nD] of
              '(', ')', ',', '.', '[', ']': S[nD] := ' ';
            end;
          nI := FindScriptVar(T, cKz, sE, a, wr);
          sE := '';
          nP := StrToInt(EvalScriptExpr(T, S, 1));
          if nP <> 0 then
          begin
            for nD := 1 to Length(S) do
              case S[nD] of
                '(', ')', ',', '[', ']': S[nD] := ' ';
              end;
            if nP > 0 then
              Inc(nP)
            else
              Dec(nP, 2);
            sE := EvalScriptExpr(T, S, nP);
          end;
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end
        else
          bOk := False;
      end
    else if sE = 'clipboard' then
      begin
        sE := LowerCase(EvalScriptExpr(T, S, -3));
        if Length(sE) > 0 then
        begin
          if Pos('string', sE) > 0 then
            nD := nD or 1;
          if Pos('word', sE) > 0 then
            nD := nD or 2;
        end
        else
          nD := 0;
        sE := EvalScriptExpr(T, S, 2);
        if Clipboard.HasFormat(CF_TEXT) then
        begin
          nO := 250;
          fzZ2.bF := False;
          T.ClipLen := 0;
          while (not fzZ2.bF) and (nO > 0) do
          begin
            if T.StopRequested then
              Break;
            try
              S := GetClipboardText(Clipboard);
              fzZ2.bF := True;
              T.ClipLen := Length(S);
            except
              SysUtils.Sleep(1);
            end;
            Dec(nO);
          end;
        end
        else
          S := '';
        if (Length(sE) >= 2) and (sE[1] = '$') then
        begin
          cKz := sE[1];
          Delete(sE, 1, 1);
          nI := FindScriptVar(T, cKz, sE, a, wr);
          sE := S;
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end
        else if (Length(sE) >= 2) and (sE[1] = '%') then
        begin
          cKz := sE[1];
          Delete(sE, 1, 1);
          T.ParenPos := 0;
          sQ := sE;
          a := 0;
          wr := 0;
          GetArraySize(T, sQ, a, wr, True);
          a := 1;
          wr := 1;
          if nD and 3 = 3 then
          begin
            nF := Pos(#10, S);
            nO := 1;
            fzZ2.bF := False;
            repeat
              if nF = 0 then
              begin
                nF := Length(S) + 1;
                fzZ2.bF := True;
              end;
              if Length(S) <= 0 then
                sG := ''
              else if S[nF - 1] = #13 then
                sG := Copy(S, nO, nF - nO - 1)
              else
                sG := Copy(S, nO, nF - nO);
              wr := 1;
              repeat
                sE := sQ;
                nI := FindScriptVar(T, cKz, sE, a, wr);
                sE := EvalScriptPoint(T, 'clipboard ' + sG, wr);
                StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
                Inc(wr);
              until sE = '';
              Inc(a);
              nO := nF + 1;
              nF := PosEx(#10, S, nO);
            until fzZ2.bF;
          end
          else if nD and 1 = 1 then
          begin
            nF := Pos(#10, S);
            nO := 1;
            fzZ2.bF := False;
            repeat
              if nF = 0 then
              begin
                nF := Length(S) + 1;
                fzZ2.bF := True;
              end;
              sE := sQ;
              nI := FindScriptVar(T, cKz, sE, a, wr);
              if Length(S) <= 0 then
                sE := ''
              else if S[nF - 1] = #13 then
                sE := Copy(S, nO, nF - nO - 1)
              else
                sE := Copy(S, nO, nF - nO);
              StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
              Inc(a);
              nO := nF + 1;
              nF := PosEx(#10, S, nO);
            until fzZ2.bF;
          end
          else
          begin
            fzZ2.bF := False;
            repeat
              nI := FindScriptVar(T, cKz, sQ, a, wr);
              if not fzZ2.bF then
              begin
                sE := EvalScriptPoint(T, 'clipboard ' + S, wr);
                fzZ2.bF := True;
              end;
              StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
              Inc(wr);
              if fzZ2.bF then
                sE := EvalScriptPoint(T, 'clipboard ' + S, wr);
            until sE = '';
          end;
        end
        else
          bOk := False;
      end
    else if sE = gCmdNamesdd[84] then
      begin
        sE := EvalScriptExpr(T, S, 2);
        cKz := sE[1];
        Delete(sE, 1, 1);
        TScanThread(T).Synchronize(T.SyncGetTabCount);
        T.TabList := TStringList.Create;
        { Здесь ДРУГОЙ метод, а не повторный SyncGetTabCount: он копирует
          имена вкладок в только что созданный TabList. }
        TScanThread(T).Synchronize(T.SyncGetTabNames);
        a := T.TabCount;
        wr := 3;
        sQ := sE;
        for nF := 0 to a - 1 do
        begin
          sE := sQ;
          a := nF + 1;
          wr := 3;
          nI := FindScriptVar(T, cKz, sE, a, wr);
          wr := 1;
          sE := T.TabList[nF];
          nX := StrToInt(sE);
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
          wr := 2;
          sE := ExtractFileName(gScriptso3[nX].Title);
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
          if gScriptso3[nX].StopRequested then
            sE := 'stoped'
          else if gScriptso3[nX].Paused then
            sE := 'paused'
          else if gScriptso3[nX].Flag91 then
            sE := 'runing'
          else
            sE := 'stoped';
          wr := 3;
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end;
        T.TabList.Free;
        T.TabList := nil;
      end
    else if sE = gCmdNamesdd[42] then
      begin
        T.ClipLen := 0;
        sE := EvalScriptExpr(T, 'calc ' + EvalScriptExpr(T, S, 2), 1);
        sG := EvalScriptExpr(T, S, 7);
        fzZ2.bF := False;
        if TryStrToInt(sE, Integer(a)) then
        begin
          if a = 0 then
            a := T.ClientWnd2;
          if not GetWindowRect(a, PRect(@fzZ14.rcLeft)^) then
          begin
            T.ClipLen := 3;
            fzZ14.rcRight := 0;
            fzZ14.rcLeft := 0;
            fzZ14.rcBottom := 0;
            fzZ14.rcTop := 0;
          end;
          sE := EvalScriptExpr(T, S, 3);
          sQ := EvalScriptExpr(T, S, 4);
          if T.InLua then
          begin
            T.LuaRes1 := fzZ14.rcLeft;
            T.LuaRes2 := fzZ14.rcTop;
            T.LuaRes3 := fzZ14.rcRight - fzZ14.rcLeft;
            T.LuaRes4 := fzZ14.rcBottom - fzZ14.rcTop;
          end
          else if (Length(sE) >= 2) and ((sE[1] = '#') or (sE[1] = '$')) and
                  (Length(sQ) >= 2) and ((sQ[1] = '#') or (sQ[1] = '$')) then
          begin
            cKz := sE[1];
            Delete(sE, 1, 1);
            nI := FindScriptVar(T, cKz, sE, a, wr);
            sE := IntToStr(fzZ14.rcLeft);
            StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
            cKz := sQ[1];
            Delete(sQ, 1, 1);
            sE := sQ;
            nI := FindScriptVar(T, cKz, sE, a, wr);
            sE := IntToStr(fzZ14.rcTop);
            StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
            sE := EvalScriptExpr(T, S, 5);
            sQ := EvalScriptExpr(T, S, 6);
            if (Length(sE) >= 2) and ((sE[1] = '#') or (sE[1] = '$')) and
               (Length(sQ) >= 2) and ((sQ[1] = '#') or (sQ[1] = '$')) then
            begin
              cKz := sE[1];
              Delete(sE, 1, 1);
              nI := FindScriptVar(T, cKz, sE, a, wr);
              sE := IntToStr(fzZ14.rcRight - fzZ14.rcLeft);
              StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
              cKz := sQ[1];
              Delete(sQ, 1, 1);
              sE := sQ;
              nI := FindScriptVar(T, cKz, sE, a, wr);
              sE := IntToStr(fzZ14.rcBottom - fzZ14.rcTop);
              StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
            end
            else
              T.ClipLen := 1;
          end
          else
            T.ClipLen := 2;
        end
        else
          T.ClipLen := 4;
        case T.ClipLen of
          1: T.Msg := '''width'' or ''height'' not recognized'#0;
          2: T.Msg := '''x'' or ''y'' not recognized'#0;
          3: T.Msg := 'windowpos false'#0;
          4: T.Msg := 'handle not recognized'#0;
        end;
        if T.ClipLen >= 1 then
          TScanThread(T).Synchronize(T.SyncLogMsg);
        if T.InLua then
          T.LuaRes5 := T.ClipLen
        else if (Length(sG) >= 2) and ((sG[1] = '#') or (sG[1] = '$')) then
        begin
          sE := sG;
          cKz := sE[1];
          Delete(sE, 1, 1);
          nI := FindScriptVar(T, cKz, sE, a, wr);
          sE := IntToStr(T.ClipLen);
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end;
      end
    else if Copy(LowerCase(sE), 1, 7) = 'easyuo*' then
      begin
        TRegistry(T.Obj43FC).RootKey := HKEY_CURRENT_USER;
        TRegistry(T.Obj43FC).OpenKey('Software\EasyUO', True);
        sQ := Copy(sE, 8, $20);
        sQ := EvalScriptExpr(T, 'calc ' + sQ, 1);
        sQ := TRegistry(T.Obj43FC).ReadString(sQ);
        sE := EvalScriptExpr(T, S, 2);
        TRegistry(T.Obj43FC).CloseKey;
      end
    else
      begin
      if gLangOffsety > 0 then
          T.Msg := '(' + IntToStr(T.CurLine) + LoadStr(gLangOffsety + $151) + #0
        else
          T.Msg := '(' + IntToStr(T.CurLine) + '): Не могу определить операцию' + #0;
        ShowScriptMsg(T);
        if T.ToMsgBox then
        begin
          T.StopRequested := True;
          T.Flag91 := False;
          T.RestartFlag := True;
        end;
        Exit;
      end;
    if not bOk then
      begin
        if gLangOffsety > 0 then
          T.Msg := '(' + IntToStr(T.CurLine) + LoadStr(gLangOffsety + $1BA) + #0
        else
          T.Msg := '(' + IntToStr(T.CurLine) + '): Не могу определить имя переменной' + #0;
        ShowScriptMsg(T);
        if T.ToMsgBox then
        begin
          T.StopRequested := True;
          T.Flag91 := False;
          T.RestartFlag := True;
        end;
      end;
    end;
  4:
    begin
      nP := TScanThread(T).CurLine;
      nJ := 0;
      sE := AnsiLowerCase(EvalScriptExpr(T, S, -1));
      while Length(TScanThread(T).Lines) > nJ do
      begin
        if AnsiLowerCase(EvalScriptExpr(T, TScanThread(T).Lines[nJ], 0)) =
           ':' + sE then
        begin
          TScanThread(T).CurLine := nJ;
          Break;
        end;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Lines) <= nJ then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1C6) +
            EvalScriptExpr(T, S, 1) + LoadStr(gLangOffsety + $1C7) + #0
        else
          TScanThread(T).Msg := 'Метка ''' + EvalScriptExpr(T, S, 1) +
            ''' не найдена, проверьте скрипт' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
        Exit;
      end;
      nJ := TScanThread(T).CurLine;
      nRepG := 0;
      nForG := 0;
      while nJ <> nP do
      begin
        sH := TScanThread(T).Lines[nJ];
        sV274 := EvalScriptPoint(T, sH, 0);
        if nJ > nP then
        begin
          if sV274 = 'repeat' then Inc(nRepG);
          if sV274 = 'end_repeat' then Dec(nRepG);
          if sV274 = 'for' then Inc(nForG);
          if sV274 = 'end_for' then Dec(nForG);
          Dec(nJ);
        end
        else
        begin
          if sV274 = 'repeat' then Dec(nRepG);
          if sV274 = 'end_repeat' then Inc(nRepG);
          if sV274 = 'for' then Dec(nForG);
          if sV274 = 'end_for' then Inc(nForG);
          Inc(nJ);
        end;
      end;
      if nRepG <> 0 then
        SetLength(TScanThread(T).Arr54, nRepG + Length(TScanThread(T).Arr54));
      if nForG <> 0 then
        SetLength(TScanThread(T).Arr50, nForG + Length(TScanThread(T).Arr50));

    end;
  5:
    begin
      nJ := 0;
      SetLength(TScanThread(T).Arr58, Length(TScanThread(T).Arr58) + 1);
      TScanThread(T).Arr58[Length(TScanThread(T).Arr58) - 1].Line := TScanThread(T).CurLine;
      if (Length(TScanThread(T).Arr50) > 0) and
         (TScanThread(T).Arr50[Length(TScanThread(T).Arr50) - 1].Line < TScanThread(T).CurLine) and
         (TScanThread(T).Arr50[Length(TScanThread(T).Arr50) - 1].EndLine > TScanThread(T).CurLine) then
        TScanThread(T).Arr58[Length(TScanThread(T).Arr58) - 1].ForIdx :=
          Length(TScanThread(T).Arr50) - 1
      else
        TScanThread(T).Arr58[Length(TScanThread(T).Arr58) - 1].ForIdx := -1;
      if (Length(TScanThread(T).Arr54) > 0) and
         (TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].Line < TScanThread(T).CurLine) and
         (TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].EndLine > TScanThread(T).CurLine) then
        TScanThread(T).Arr58[Length(TScanThread(T).Arr58) - 1].RepIdx :=
          Length(TScanThread(T).Arr54) - 1
      else
        TScanThread(T).Arr58[Length(TScanThread(T).Arr58) - 1].RepIdx := -1;
      sE := AnsiLowerCase(EvalScriptExpr(T, S, -1));
      while Length(TScanThread(T).Lines) > nJ do
      begin
        if AnsiLowerCase(EvalScriptExpr(T, TScanThread(T).Lines[nJ], 0)) =
           ':' + sE then
        begin
          TScanThread(T).CurLine := nJ;
          Break;
        end;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Lines) > nJ then
        Exit;
      if gLangOffsety > 0 then
        TScanThread(T).Msg := LoadStr(gLangOffsety + $1C6) +
          EvalScriptExpr(T, S, 1) + LoadStr(gLangOffsety + $1C7) + #0
      else
        TScanThread(T).Msg := 'Метка ''' + EvalScriptExpr(T, S, 1) +
          ''' не найдена, проверьте скрипт' + #0;
      ShowScriptMsg(TScanThread(T));
      if TScanThread(T).ToMsgBox then
      begin
        TScanThread(T).StopRequested := True;
        TScanThread(T).Flag91 := False;
        TScanThread(T).RestartFlag := True;
      end;

    end;
  6:
    begin
    if Length(T.Arr58) > 0 then
    begin
      T.CurLine := T.Arr58[Length(T.Arr58) - 1].Line;
      if T.Arr58[Length(T.Arr58) - 1].ForIdx >= 0 then
        SetLength(T.Arr50, T.Arr58[Length(T.Arr58) - 1].ForIdx + 1);
      if T.Arr58[Length(T.Arr58) - 1].RepIdx >= 0 then
        SetLength(T.Arr54, T.Arr58[Length(T.Arr58) - 1].RepIdx + 1);
      SetLength(T.Arr58, Length(T.Arr58) - 1);
    end;
    end;
  41, 42:
    begin
    nJ := T.CurLine + 1;
    nDepth := 0;
    nElse := 0;
    while Length(T.Lines) > nJ do
    begin
      sH := T.Lines[nJ];
      sH := EvalScriptPoint(T, sH, 0);
      if (sH = 'if') or (sH = 'if_not') then Inc(nDepth);
      if sH = 'end_if' then Dec(nDepth);
      if sH = 'else' then
        if nDepth = 0 then nElse := nJ;
      if nDepth < 0 then Break;
      Inc(nJ);
    end;
    if Length(T.Lines) = nJ then
    begin
      if gLangOffsety > 0 then
        T.Msg := LoadStr(gLangOffsety + $1C5) + #0
      else
        T.Msg := 'Не могу найти конец условия: "End_IF", проверьте скрипт'#0;
      ShowScriptMsg(T);
      if T.ToMsgBox then
      begin
        T.StopRequested := True;
        T.Flag91 := False;
        T.RestartFlag := True;
      end;
    end
    else
    begin
      bOk := CheckCondition(S);
      if N = 42 then bOk := not bOk;
      if not bOk then
        if nElse <> 0 then
          T.CurLine := nElse
        else
          T.CurLine := nJ;
    end;
    end;
  7:
    begin
    nJ := T.CurLine + 1;
    nDepth := 0;
    while Length(T.Lines) > nJ do
    begin
      sH := T.Lines[nJ];
      sH := EvalScriptPoint(T, sH, 0);
      if (sH = 'if') or (sH = 'if_not') then Inc(nDepth);
      if sH = 'end_if' then Dec(nDepth);
      if nDepth < 0 then Break;
      Inc(nJ);
    end;
    if Length(T.Lines) = nJ then
    begin
      if gLangOffsety > 0 then
      T.Msg := LoadStr(gLangOffsety + $1C5) + #0
    else
      T.Msg := 'Не могу найти конец условия: "End_IF", проверьте скрипт'#0;
    ShowScriptMsg(T);
    if T.ToMsgBox then
    begin
      T.StopRequested := True;
      T.Flag91 := False;
      T.RestartFlag := True;
    end;
    end
    else
      T.CurLine := nJ;
    end;
  8:
    begin
    sC := EvalScriptExpr(T, S, -1);
    if Pos('\', sC) < 1 then
      sC := ExtractFilePath(Application.ExeName) + '\' + sC;
    fmSecondfj.MacroFileOp(2, sC);
    end;
  9:
    begin
    sC := EvalScriptExpr(T, S, 1);
    if not TryStrToInt(sC, TheRecorder.FRepeatCount) then
      TheRecorder.FRepeatCount := 1;
    sC := EvalScriptExpr(T, S, 2);
    if not TryStrToInt(sC, nD) then
      nD := fmSecondfj.miSpeed.Tag;
    TheRecorder.SpeedFactor := nD;
    TheRecorder.DoStop;
    Application.OnMessage := TfmSecond(fmSecondfj).AppMessage;
    TheRecorder.DoPlay;
    while TheRecorder.State = rsPlaying do
      Application.ProcessMessages;
    Application.OnMessage := nil;
    end;
  20:
    begin
      sE := 'left ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 1, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  21:
    begin
      sE := 'right ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 2, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  22:
    begin
      sE := 'double_left ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 11, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  23:
    begin
      sE := 'double_right ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 22, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  24:
    begin
      sE := 'left_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 30, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  25:
    begin
      sE := 'left_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 40, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  26:
    begin
      sE := 'right_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 33, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  27:
    begin
      sE := 'right_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 34, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  53:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 110, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  54:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 101, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  55:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 120, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  56:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 102, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  57:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 111, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  58:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 112, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  59:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 121, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  60:
    begin
      sE := 'kmouse ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 122, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  65:
    begin
      sE := 'pleft ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 210, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  66:
    begin
      sE := 'pright ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 201, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  67:
    begin
      sE := 'double_pleft ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 220, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  68:
    begin
      sE := 'double_pright ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 202, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));
      ptM.X := 0;
      ptM.Y := 0;

    end;
  69:
    begin
      sE := 'pleft_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 211, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  70:
    begin
      sE := 'pleft_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 212, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  71:
    begin
      sE := 'pright_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 221, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  72:
    begin
      sE := 'pright_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 222, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  73:
    begin
      sE := 'middle ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 3, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  74:
    begin
      sE := 'double_middle ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 23, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  75:
    begin
      sE := 'middle_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 43, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  76:
    begin
      sE := 'middle_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 44, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  77:
    begin
      sE := 'pmiddle ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 203, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  78:
    begin
      sE := 'double_pmiddle ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 233, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  79:
    begin
      sE := 'pmiddle_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 243, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  80:
    begin
      sE := 'pmiddle_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 244, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  81:
    begin
      sE := 'kmiddle ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 103, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  82:
    begin
      sE := 'double_kmiddle ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 133, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  83:
    begin
      sE := 'kmiddle_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 131, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  84:
    begin
      sE := 'kmiddle_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 132, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  91:
    begin
      sE := 'whell_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 91, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  92:
    begin
      sE := 'wheel_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 92, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  93:
    begin
      sE := 'pwhell_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 93, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  94:
    begin
      sE := 'pwheel_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 94, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  95:
    begin
      sE := 'kwheel_down ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 95, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  96:
    begin
      sE := 'kwheel_up ' + EvalScriptExpr(T, S, -1);
      MouseClick(TScanThread(T).ClientWnd2, 96, sE, ptM, False,
        EvalScriptPoint(T, sE, -3));

    end;
  28, 129:
    begin
      GetCursorPos(fzZ7.ptSave);
      sE := 'move ' + EvalScriptExpr(T, S, -1);
      fzZ7.ptMv.X := StrToInt(EvalScriptPoint(T, sE, 1));
      fzZ7.ptMv.Y := StrToInt(EvalScriptPoint(T, sE, 2));
      sType := AnsiLowerCase(EvalScriptPoint(T, sE, -3));
      pr0 := Pos('abs', sType);
      bAbs := pr0 > 0;
      if bAbs then
        Delete(sType, pr0, 3);
      pr0 := Pos('nooffset', sType);
      bNoOff := pr0 > 0;
      if bNoOff then
        Delete(sType, pr0, 8);
      fzZ7.nDX0 := 0;
      nDX1 := 0;
      fzZ7.nDY0 := 0;
      fzZ7.nDY1 := 0;
      if TryStrToInt(EvalScriptPoint(T, sType, 0), fzZ7.nDX0) and
         TryStrToInt(EvalScriptPoint(T, sType, 1), fzZ7.nDY0) then
      begin
        sType := EvalScriptPoint(T, sType, -2);
        if TryStrToInt(EvalScriptPoint(T, sType, 0), nDX1) and
           TryStrToInt(EvalScriptPoint(T, sType, 1), fzZ7.nDY1) then
          sType := EvalScriptPoint(T, sType, -2)
        else
        begin
          nDX1 := 0;
          fzZ7.nDY1 := 0;
        end;
      end
      else
      begin
        fzZ7.nDX0 := 0;
        fzZ7.nDY0 := 0;
      end;
      fzZ7.ptMv.X := fzZ7.ptMv.X - Abs(nDX1) + Random(Abs(nDX1) + fzZ7.nDX0 + 1);
      fzZ7.ptMv.Y := fzZ7.ptMv.Y - Abs(fzZ7.nDY1) + Random(Abs(fzZ7.nDY1) + fzZ7.nDY0 + 1);
      if not bNoOff then
      begin
        fzZ7.ptMv.X := fzZ7.ptMv.X + TScanThread(T).Cnt104674;
        fzZ7.ptMv.Y := fzZ7.ptMv.Y + TScanThread(T).Cnt104678;
      end;
      if not bAbs then
      begin
        nPos := 0;
        pr1 := TScanThread(T).ClientWnd2;
        if Length(sType) > 0 then
          if TryStrToInt(sType, nPos) then
            pr1 := nPos;
        ClientToScreen(pr1, fzZ7.ptMv);
      end;
      case N of
        $1C: fzZ2.bF := SetCursorPos(fzZ7.ptMv.X, fzZ7.ptMv.Y);
        $81: fzZ2.bF := SmoothMove(fzZ7.ptSave, fzZ7.ptMv);
      end;

    end;
  29:
    begin
      sE := 'drag ' + EvalScriptExpr(T, S, -1);
      pr0 := MakeLong(StrToInt(EvalScriptExpr(T, sE, 1)),
                        StrToInt(EvalScriptExpr(T, sE, 2)));
      fzZ5.nTo := MakeLong(StrToInt(EvalScriptExpr(T, sE, 3)),
                      StrToInt(EvalScriptExpr(T, sE, 4)));
      PostMessage(TScanThread(T).ClientWnd2, $20, TScanThread(T).ClientWnd2,
                  MakeLong(1, $201));
      PostMessage(TScanThread(T).ClientWnd2, $201, 1, pr0);
      WaitDelay(fmSecondfj.Edit1.Text);
      PostMessage(TScanThread(T).ClientWnd2, $200, 1, fzZ5.nTo);
      WaitDelay(fmSecondfj.Edit1.Text);
      sC := AnsiLowerCase(EvalScriptExpr(T, sE, 5));
      if sC <> '' then
        if sC <> 'all' then
        begin
          for nJ := 1 to Length(sC) do
            PostMessage(TScanThread(T).ClientWnd2, $102, Ord(sC[nJ]), 0);
        end;
      if sC <> '' then
        PostMessage(TScanThread(T).ClientWnd2, $102, $D, 0);
      WaitDelay(fmSecondfj.Edit2.Text);
      PostMessage(TScanThread(T).ClientWnd2, $202, 0, fzZ5.nTo);

    end;
  61:
    begin
    sE := EvalScriptExpr(T, S, 1);
      if (Length(sE) >= 2) and ((sE[1] = '#') or (sE[1] = '$')) then
      begin
        cKz := sE[1];
        Delete(sE, 1, 1);
        nI := FindScriptVar(T, cKz, sE, a, wr);
        S := 'calc ' + EvalScriptExpr(T, S, -2);
        fzZ12.qAddr := StrToInt64(EvalScriptExpr(T, S, 1));
        TScanThread(T).CmdArg := AnsiLowerCase(EvalScriptExpr(T, S, 2));
        if TScanThread(T).CmdArg[1] = 's' then
        begin
          wr := StrToIntDef(AnsiLowerCase(EvalScriptExpr(T, S, 3)), 1);
          nPos := 4;
        end
        else
          nPos := 3;
        sType := AnsiLowerCase(EvalScriptExpr(T, S, nPos));
        TScanThread(T).MemTarget := AnsiLowerCase(EvalScriptExpr(T, S, nPos + 1));
        fzZ12.bOwn := False;
        if sType <> '' then
        begin
          if TryStrToInt(sType, nPos) then
          begin
            GetWindowThreadProcessId(nPos, @fzZ13.nPid);
            fzZ13.hProc := OpenProcess($638, False, fzZ13.nPid);
            fzZ12.bOwn := True;
          end
          else
          begin
            fzZ13.hProc := TScanThread(T).ProcessHandle2;
            fzZ13.nPid := TScanThread(T).ProcessId;
            if TScanThread(T).MemTarget = '' then
            begin
              TScanThread(T).MemTarget := sType;
              fzZ12.qErr := 0;
            end
            else
              fzZ12.qErr := -4;
          end;
        end
        else
        begin
          fzZ13.hProc := TScanThread(T).ProcessHandle2;
          fzZ13.nPid := TScanThread(T).ProcessId;
        end;
        fzZ11.bF211 := 0;
        fzZ11.wF214 := 0;
        dF230 := 0;
        fzZ11.mB := 0;
        fzZ12.qC := 0;
        sF220 := 0;
        rF228 := 0;
        bG := False;
        bufStr := '';
        if fzZ12.qErr >= 0 then
        begin
          try
            TScanThread(T).ClipLen := 0;
            case TScanThread(T).CmdArg[1] of
    'b':
      begin
        ReadMemByName(fzZ13.hProc, fzZ11.bF211, fzZ12.qErr, fzZ12.qAddr,
        1, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := IntToStr(fzZ11.bF211);
      end;
    'w':
      begin
        ReadMemByName(fzZ13.hProc, fzZ11.wF214, fzZ12.qErr, fzZ12.qAddr,
        2, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := IntToStr(fzZ11.wF214);
      end;
    'd':
      begin
        if Length(TScanThread(T).CmdArg) > 1 then
          if TScanThread(T).CmdArg[2] = 'o' then
          begin
            ReadMemByName(fzZ13.hProc, dF230, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, fzZ13.nPid);
            TScanThread(T).ClipLen := gMemLastErrorao;
            sE := FloatToStr(dF230);
          end;
        ReadMemByName(fzZ13.hProc, fzZ11.mB, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := IntToStr(Cardinal(fzZ11.mB));
      end;
    'l':
      begin
        ReadMemByName(fzZ13.hProc, fzZ12.qC, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := IntToStr(fzZ12.qC);
      end;
    'f':
      begin
        ReadMemByName(fzZ13.hProc, sF220, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := FloatToStr(sF220);
      end;
    'r':
      begin
        ReadMemByName(fzZ13.hProc, rF228, fzZ12.qErr, fzZ12.qAddr,
        6, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := FloatToStr(rF228);
      end;
    'c':
      begin
        ReadMemByName(fzZ13.hProc, cF219, fzZ12.qErr, fzZ12.qAddr,
        1, TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := cF219;
      end;
    's':
      begin
        if Cardinal(wr) > $FF then
          wr := $FF;
        ReadMemByName(fzZ13.hProc, bufChr, fzZ12.qErr, fzZ12.qAddr,
        Cardinal(wr), TScanThread(T).MemTarget, fzZ13.nPid);
        TScanThread(T).ClipLen := gMemLastErrorao;
        sE := PChar(@bufChr);
      end;
        else
              fzZ12.qErr := -2;
            end;
          except
            fzZ12.qErr := -3;
          end;
        end;
        if fzZ12.bOwn then
          CloseHandle(fzZ13.hProc);
        case fzZ12.qErr of
          0: sE := '-1';
          -2: sE := '-2';
          -3: sE := '-3';
          -4: sE := '-4';
        end;
        TScanThread(T).CmdArg := '';
        StoreScriptVar(T, cKz, nI, TScanThread(T).CmdArg, TScanThread(T).ParenPos, sE,
          a, wr);
      end
      else
      begin
        if gLangOffsety > 0 then
          T.Msg := '(' + IntToStr(T.CurLine) + LoadStr(gLangOffsety + $1BA) + #0
        else
          T.Msg := '(' + IntToStr(T.CurLine) +
            '): Не могу определить имя переменной' + #0;
        ShowScriptMsg(T);
        if T.ToMsgBox then
        begin
          T.StopRequested := True;
          T.Flag91 := False;
          T.RestartFlag := True;
        end;
      end;
    end;
  62:
    begin
    sE := EvalScriptExpr(T, S, 1);
      a := Length(sE);
      if Cardinal(a) > 2 then
        if sE[1] = '"' then
          if sE[a] = '"' then
            sE := Copy(sE, 2, a - 2);
      if Length(sE) >= 2 then
        if (sE[1] = '#') or (sE[1] = '$') then
          sE := EvalScriptExpr(T, 'calc ' + sE, 1);
      S := 'calc ' + EvalScriptExpr(T, S, -2);
      fzZ12.qAddr := StrToInt64(EvalScriptExpr(T, S, 1));
      TScanThread(T).CmdArg := AnsiLowerCase(EvalScriptExpr(T, S, 2));
      sType := EvalScriptPoint(T, S, 3);
      TScanThread(T).MemTarget := AnsiLowerCase(EvalScriptPoint(T, S, 4));
      TScanThread(T).MemTarget2 := EvalScriptPoint(T, S, 5);
      if sType <> '' then
      begin
        if (sType[1] <> '#') and (sType[1] <> '$') then
        begin
          sType := EvalScriptExpr(T, 'calc ' + sType, -1);
          if TryStrToInt(sType, nPos) then
          begin
            GetWindowThreadProcessId(nPos, @fzZ13.nPid);
            fzZ13.hProc := OpenProcess($638, False, fzZ13.nPid);
            if TScanThread(T).MemTarget <> '' then
            begin
              if (TScanThread(T).MemTarget[1] <> '#') and (TScanThread(T).MemTarget[1] <> '$') then
              begin
                TScanThread(T).MemTarget := AnsiLowerCase(EvalScriptExpr(T, 'calc ' +
                                         TScanThread(T).MemTarget, -1));
                TScanThread(T).MemTarget2 := EvalScriptExpr(T, 'calc ' +
                                          TScanThread(T).MemTarget2, -1);
              end
              else
              begin
                TScanThread(T).MemTarget2 := TScanThread(T).MemTarget;
                TScanThread(T).MemTarget := '';
              end;
            end;
          end
          else
          begin
            fzZ13.hProc := TScanThread(T).ProcessHandle2;
            fzZ13.nPid := TScanThread(T).ProcessId;
            TScanThread(T).MemTarget := sType;
            TScanThread(T).MemTarget2 := '';
          end;
        end
        else
        begin
          fzZ13.hProc := TScanThread(T).ProcessHandle2;
          fzZ13.nPid := TScanThread(T).ProcessId;
          TScanThread(T).MemTarget := '';
          TScanThread(T).MemTarget2 := sType;
        end;
      end
      else
      begin
        fzZ13.hProc := TScanThread(T).ProcessHandle2;
        fzZ13.nPid := TScanThread(T).ProcessId;
      end;
      TScanThread(T).ClipLen := 0;
      try
        case TScanThread(T).CmdArg[1] of
    'b':
      begin
        fzZ11.bF211 := StrToInt(sE);
        WriteMemByName(TScanThread(T).ProcessHandle2, fzZ11.bF211, fzZ12.qErr, fzZ12.qAddr,
        1, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    'w':
      begin
        fzZ11.wF214 := StrToInt(sE);
        WriteMemByName(TScanThread(T).ProcessHandle2, fzZ11.wF214, fzZ12.qErr, fzZ12.qAddr,
        2, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    'd':
      begin
        if Length(TScanThread(T).CmdArg) > 1 then
          if TScanThread(T).CmdArg[2] = 'o' then
          begin
            dF230 := StrToFloat(sE);
            WriteMemByName(TScanThread(T).ProcessHandle2, dF230, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
          end;
        fzZ11.mB := StrToInt(sE);
        WriteMemByName(TScanThread(T).ProcessHandle2, fzZ11.mB, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    'l':
      begin
        fzZ12.qC := StrToInt64(sE);
        WriteMemByName(TScanThread(T).ProcessHandle2, fzZ12.qC, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    'f':
      begin
        sF220 := StrToFloat(sE);
        WriteMemByName(TScanThread(T).ProcessHandle2, sF220, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    'r':
      begin
        rF228 := StrToFloat(sE);
        WriteMemByName(TScanThread(T).ProcessHandle2, rF228, fzZ12.qErr, fzZ12.qAddr,
        6, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    'c':
      begin
        cF219 := sE[1];
        WriteMemByName(TScanThread(T).ProcessHandle2, cF219, fzZ12.qErr, fzZ12.qAddr,
        1, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
    's':
      begin
        ptYQ := Length(sE);
        if ptYQ > $FF then
          ptYQ := $FF;
        bufStr := Copy(sE, 1, ptYQ);
        WriteMemByName(TScanThread(T).ProcessHandle2, bufStr[1], fzZ12.qErr, fzZ12.qAddr,
        Byte(bufStr[0]), TScanThread(T).MemTarget, TScanThread(T).ProcessId);
        TScanThread(T).ClipLen := gMemLastErrorao;
      end;
        end;
      except
        fzZ12.qErr := 0;
      end;
      if TScanThread(T).MemTarget2 <> '' then
      begin
        sE := TScanThread(T).MemTarget2;
        cKz := sE[1];
        Delete(sE, 1, 1);
        nI := FindScriptVar(T, cKz, sE, a, wr);
        sE := IntToStr(fzZ12.qErr);
        TScanThread(T).CmdArg := '';
        StoreScriptVar(T, cKz, nI, TScanThread(T).CmdArg, TScanThread(T).ParenPos, sE,
          a, wr);
      end;
    end;
  10:
    begin
      nJ := 0;
      while Length(TScanThread(T).Arr54) > nJ do
      begin
        if TScanThread(T).Arr54[nJ].Line = TScanThread(T).CurLine then
          Break;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Arr54) > nJ then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1D2) + #0
        else
          TScanThread(T).Msg := 'Ошибка интерпретации скрипта (repeat).' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
        Exit;
      end;
      S := 'repeat ' + EvalScriptExpr(T, S, -1);
      nP := StrToInt(ParseWaitSuffix(EvalScriptExpr(T, S, -1), nD, nM));
      if nD <> 0 then
      begin
        TScanThread(T).Msg := '(' + IntToStr(TScanThread(T).CurLine) + '): ' +
          gEvalErrorsl6[nD] + ' (pos:' + IntToStr(nM) + ')+#0';
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
        Exit;
      end;
      SetLength(TScanThread(T).Arr54, Length(TScanThread(T).Arr54) + 1);
      TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].Line := TScanThread(T).CurLine;
      TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].Count := nP;
      nJ := TScanThread(T).CurLine + 1;
      nLevel := 0;
      while Length(TScanThread(T).Lines) > nJ do
      begin
        sH := TScanThread(T).Lines[nJ];
        sH := EvalScriptPoint(T, sH, 0);
        if sH = 'repeat' then Inc(nLevel);
        if sH = 'end_repeat' then Dec(nLevel);
        if nLevel < 0 then
        begin
          TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].EndLine := nJ;
          Break;
        end;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Lines) = nJ then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1D3) + #0
        else
          TScanThread(T).Msg := 'Не могу найти конец цикла: "End_Repeat", проверьте скрипт' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
        Exit;
      end;
      if TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].Count <= 0 then
        TScanThread(T).CurLine := TScanThread(T).Arr54[Length(TScanThread(T).Arr54) - 1].EndLine - 1;

    end;
  11:
    begin
    nJ := 0;
    while Length(T.Arr54) > nJ do
    begin
      if T.Arr54[nJ].EndLine = T.CurLine then Break;
      Inc(nJ);
    end;
    if Length(T.Arr54) <= nJ then
    begin
      if gLangOffsety > 0 then
      T.Msg := LoadStr(gLangOffsety + $1D4) + #0
    else
      T.Msg := 'Ошибка интерпретации скрипта (end_repeat).'#0;
    ShowScriptMsg(T);
    if T.ToMsgBox then
    begin
      T.StopRequested := True;
      T.Flag91 := False;
      T.RestartFlag := True;
    end;
    end
    else
    begin
      Dec(T.Arr54[nJ].Count);
      if T.Arr54[nJ].Count > 0 then
        T.CurLine := T.Arr54[nJ].Line
      else
        SetLength(T.Arr54, Length(T.Arr54) - 1);
    end;
    end;
  17:
    begin
    sC := EvalScriptExpr(T, S, -1);
      SayText(T, sC);
    end;
  18, 87, 88, 101, 117, 118:
    begin
    S := EvalScriptExpr(T, S, -1);
      if Length(S) > 0 then
      begin
        fzZ2.bF := False;
        if (S[1] = '{') and (S[Length(S)] = '}')
           and (PosEx('{', S, 2) = 0) then
        begin
          S := Copy(S, 2, Length(S) - 2);
          fzZ2.bF := True;
        end
        else
          fzZ2.bF := False;
        S := 'send ' + S;
        nD := 1;
        sC := AnsiLowerCase(EvalScriptExpr(T, S, nD));
        sE := EvalScriptExpr(T, S, nD + 2);
      end
      else
        sC := '';
      while sC <> '' do
      begin
    pr1 := 0;
      if sC[1] = '{' then
        if sC[Length(sC)] = '}' then
        begin
          sC := Copy(sC, 2, Length(sC) - 2);
          fzZ2.bF := True;
        end;
      if fzZ2.bF then
        nF := StrToIntDef(sC, 0)
      else
        nF := 0;
      if nF < 10 then
      begin
        nJ := 0;
        fzZ13B.pName := @gHKNameTablee9[0];
        fzZ13B.pCode := @gHKCodeTablepz[0];
        repeat
          if CompareText(sC, AnsiLowerCase(fzZ13B.pName^)) = 0 then
          begin
            pr1 := fzZ13B.pCode^;
            Break;
          end;
          Inc(nJ);
          Inc(fzZ13B.pCode);
          Inc(fzZ13B.pName);
        until nJ = 102;
      end;
      if pr1 = 0 then
      begin
        pr1 := nF;
        nJ := 0;
      end;
      if pr1 <> 0 then
      begin
      case nJ of
        0..$1C, $41..$55: pr0 := pr1;
      else
        pr0 := SmallInt(VkKeyScan(Char(pr1)));
      end;
      if pr0 = -1 then
        pr0 := pr1;
      nB := MapVirtualKey(pr0 and $FF, 0);
      nB := nB shl 16;
      case N of
        $58:
        begin
    PostMessage(TScanThread(T).ClientWnd2, $100, pr0, nB + 1);
      nX := 1;
      while nX <= 10 do
      begin
        if TScanThread(T).Workers[nX] = nil then
          Break;
        if TScanThread(T).Workers[nX].FDone then
        begin
          FreeAndNil(TScanThread(T).Workers[nX]);
          Break;
        end;
        Inc(nX);
      end;
      if nX <= 10 then
      begin
        TScanThread(T).Workers[nX] := TTimerThread.Create(True);
        TScanThread(T).Workers[nX].FreeOnTerminate := False;
        TScanThread(T).Workers[nX].FDone := False;
        TScanThread(T).Workers[nX].FSlot := @TScanThread(T).Workers[nX];
        TScanThread(T).Workers[nX].FWnd := TScanThread(T).ClientWnd2;
        TScanThread(T).Workers[nX].FKey := pr0;
        TScanThread(T).Workers[nX].FChar := 0;
        TScanThread(T).Workers[nX].FSend := False;
        TScanThread(T).Workers[nX].FLParam := (nB + 1) or 2;
        if not TryStrToInt(EvalScriptExpr(T, S, 2), nF) then
          nF := 0;
        TScanThread(T).Workers[nX].FDelay := nF;
        TScanThread(T).Workers[nX].Resume;
      end
      else
      begin
    T.Msg := 'exceeded the number of keystrokes';
      TScanThread(T).Synchronize(T.SyncLogMsg);
      end;
        end;
        $76:
        begin
    nB := MapVirtualKey(pr1, 0);
      nB := nB shl 16;
      pr0 := MapVirtualKey(pr1, 2) and $FF;
      SendMessage(TScanThread(T).ClientWnd2, $100, pr1, nB + 1);
      if pr0 <> 0 then
        SendMessage(TScanThread(T).ClientWnd2, $102, pr0, nB + $C0000001);
      nX := 1;
      while nX <= 10 do
      begin
        if TScanThread(T).Workers[nX] = nil then
          Break;
        if TScanThread(T).Workers[nX].FDone then
        begin
          FreeAndNil(TScanThread(T).Workers[nX]);
          Break;
        end;
        Inc(nX);
      end;
      if nX <= 10 then
      begin
        TScanThread(T).Workers[nX] := TTimerThread.Create(True);
        TScanThread(T).Workers[nX].FreeOnTerminate := False;
        TScanThread(T).Workers[nX].FDone := False;
        TScanThread(T).Workers[nX].FSlot := @TScanThread(T).Workers[nX];
        TScanThread(T).Workers[nX].FWnd := TScanThread(T).ClientWnd2;
        TScanThread(T).Workers[nX].FKey := pr1;
        TScanThread(T).Workers[nX].FChar := pr0;
        TScanThread(T).Workers[nX].FSend := True;
        TScanThread(T).Workers[nX].FLParam := (nB + 1) or 2;
        if not TryStrToInt(EvalScriptExpr(T, S, 2), nF) then
          nF := 0;
        TScanThread(T).Workers[nX].FDelay := nF;
        TScanThread(T).Workers[nX].Resume;
      end
      else
      begin
    T.Msg := 'exceeded the number of keystrokes';
      TScanThread(T).Synchronize(T.SyncLogMsg);
      end;
        end;
        $57:
        begin
    nX := 1;
      while nX <= 10 do
      begin
        if TScanThread(T).Workers[nX] <> nil then
          if pr0 = TScanThread(T).Workers[nX].FKey then
          begin
            TScanThread(T).Workers[nX].FStop := True;
            FreeAndNil(TScanThread(T).Workers[nX]);
            Break;
          end;
        Inc(nX);
      end;
        end;
        $75:
        begin
    nX := 1;
      while nX <= 10 do
      begin
        if TScanThread(T).Workers[nX] <> nil then
          if pr1 = TScanThread(T).Workers[nX].FKey then
          begin
            TScanThread(T).Workers[nX].FStop := True;
            FreeAndNil(TScanThread(T).Workers[nX]);
            Break;
          end;
        Inc(nX);
      end;
        end;
        $12:
        begin
    PostMessage(T.ClientWnd2, $100, pr0, nB + 1);
      PostMessage(T.ClientWnd2, $101, pr0, nB + $C0000001);
        end;
        $65:
        begin
    nB := MapVirtualKey(pr1, 0);
      nB := nB shl 16;
      SendMessage(T.ClientWnd2, $100, pr1, nB + 1);
      pr0 := MapVirtualKey(pr1, 2) and $FF;
      if pr0 <> 0 then
        SendMessage(T.ClientWnd2, $102, pr0, nB + $C0000001);
      SendMessage(T.ClientWnd2, $101, pr1, nB + $C0000001);
        end;
      end;
    if sE = '' then
        if EvalScriptExpr(T, S, 2) <> '' then
        begin
          try
            pr1 := StrToInt(EvalScriptExpr(T, S, 2));
          except
            pr1 := -1;
          end;
          if pr1 >= 0 then
          begin
            WaitDelay(IntToStr(pr1));
            Exit;
          end;
        end;
      S := EvalScriptExpr(T, S, -1);
      end
      else
      begin
    S := EvalScriptExpr(T, S, -1);
      fzZ12.bOwn := False;
      for nJ := 1 to Length(S) do
      begin
        pr0 := SmallInt(VkKeyScan(S[nJ]));
        if pr0 = -1 then
        begin
          if Boolean(Ord(fzZ12.bOwn) xor 1) then
          begin
            pr0 := ActivateKeyboardLayout(0, 0);
            fzZ12.bOwn := not fzZ12.bOwn;
          end
          else
          begin
            pr0 := ActivateKeyboardLayout(0, 0);
            fzZ12.bOwn := not fzZ12.bOwn;
          end;
          if pr0 > 0 then ;
          pr0 := SmallInt(VkKeyScan(S[nJ]));
        end;
        nB := MapVirtualKey(pr0 and $FF, 0);
        nB := nB shl 16;
        if (pr0 shr 8) > 0 then
        begin
          if ((pr0 shr 8) and 1) = 1 then
            keybd_event($A1, MapVirtualKey($A1, 0), 0, 0);
          if ((pr0 shr 8) and 2) = 2 then
            keybd_event($11, MapVirtualKey($11, 0), 0, 0);
          if ((pr0 shr 8) and 4) = 4 then
            keybd_event($12, MapVirtualKey($12, 0), 0, 0);
        end;
        SendMessage(TScanThread(T).ClientWnd2, $100, pr0, nB + 1);
        SendMessage(TScanThread(T).ClientWnd2, $102, Byte(S[nJ]), nB + $C0000001);
        SendMessage(TScanThread(T).ClientWnd2, $101, pr0, nB + $C0000001);
        if (pr0 shr 8) > 0 then
        begin
          if ((pr0 shr 8) and 1) = 1 then
          begin
            keybd_event($A1, MapVirtualKey($A1, 0), 3, 0);
            keybd_event($10, MapVirtualKey($10, 0), 0, 0);
            keybd_event($10, MapVirtualKey($10, 0), 2, 0);
          end;
          if ((pr0 shr 8) and 2) = 2 then
            keybd_event($11, MapVirtualKey($11, 0), 2, 0);
          if ((pr0 shr 8) and 4) = 4 then
            keybd_event($12, MapVirtualKey($12, 0), 2, 0);
        end;
      end;
      if fzZ12.bOwn then
        ActivateKeyboardLayout(0, 0);
      S := '';
      end;
      sC := AnsiLowerCase(EvalScriptExpr(T, S, nD));
      end;
    end;
  19:
    begin
      SysUtils.Sleep(1);
      sE := StringReplace(S, '{', '{ ', [rfReplaceAll]);
      sE := StringReplace(sE, '}', ' }', [rfReplaceAll]);
      sE := EvalScriptExpr(T, sE, -1);
      sE := StringReplace(sE, '{ ', '{', [rfReplaceAll]);
      sE := StringReplace(sE, ' }', '}', [rfReplaceAll]);
      SendKeysEx(TScanThread(T).ClientWnd2, sE, TScanThread(T).SendDelay,
                 TScanThread(T).SelfRef, 0);

    end;
  89:
    begin
      SysUtils.Sleep(1);
      sE := StringReplace(S, '{', '{ ', [rfReplaceAll]);
      sE := StringReplace(sE, '}', ' }', [rfReplaceAll]);
      sE := EvalScriptExpr(T, sE, -1);
      sE := StringReplace(sE, '{ ', '{', [rfReplaceAll]);
      sE := StringReplace(sE, ' }', '}', [rfReplaceAll]);
      nF := SendExKeyCode(PChar(sE));
      nX := 1;
      while nX <= 10 do
      begin
        if TScanThread(T).Workers2[nX] <> nil then
          if TScanThread(T).Workers2[nX].FNum = nF then
          begin
            TScanThread(T).Workers2[nX].FStop := True;
            FreeAndNil(TScanThread(T).Workers2[nX]);
            Exit;
          end;
        Inc(nX);
      end;

    end;
  90:
    begin
      SysUtils.Sleep(1);
      sE := StringReplace(S, '{', '{ ', [rfReplaceAll]);
      sE := StringReplace(sE, '}', ' }', [rfReplaceAll]);
      sE := EvalScriptExpr(T, sE, -1);
      sE := StringReplace(sE, '{ ', '{', [rfReplaceAll]);
      sE := StringReplace(sE, ' }', '}', [rfReplaceAll]);
      nF := SendExKeyCode(PChar(sE));
      nX := 1;
      while nX <= 10 do
      begin
        if TScanThread(T).Workers2[nX] = nil then
          Break;
        if TScanThread(T).Workers2[nX].FDone then
        begin
          FreeAndNil(TScanThread(T).Workers2[nX]);
          Break;
        end;
        Inc(nX);
      end;
      if nX <= 10 then
      begin
        TScanThread(T).Workers2[nX] := TTimerThreadEx.Create(True);
        TScanThread(T).Workers2[nX].FreeOnTerminate := False;
        TScanThread(T).Workers2[nX].FDone := False;
        TScanThread(T).Workers2[nX].FSlot := @TScanThread(T).Workers2[nX];
        TScanThread(T).Workers2[nX].FWnd := TScanThread(T).ClientWnd2;
        TScanThread(T).Workers2[nX].FNum := nF;
        TScanThread(T).Workers2[nX].FStr := sE;
        TScanThread(T).Workers2[nX].FScript := TScanThread(T).SelfRef;
        if not TryStrToInt(EvalScriptExpr(T, S, 2), nF) then
          nF := 0;
        TScanThread(T).Workers2[nX].FDelay := nF;
        TScanThread(T).Workers2[nX].FMode := TScanThread(T).SendDelay;
        TScanThread(T).Workers2[nX].Resume;
      end
      else
      begin
        TScanThread(T).Msg := 'exceeded the number of keystrokes';
        TScanThread(T).Synchronize(T.SyncLogMsg);
      end;

    end;
  99:
    begin
    SysUtils.Sleep(1);
    sE := EvalScriptExpr(T, S, -1);
    nD := MacroFileLoad(sE);
    TheRecorder.FRepeatCount := 1;
    TheRecorder.SpeedFactor := 100;
    Application.OnMessage := TfmSecond(fmSecondfj).AppMessage;
    TheRecorder.DoPlay;
    while TheRecorder.State = rsPlaying do
      Application.ProcessMessages;
    Application.OnMessage := nil;
    end;
  40:
    begin
    nI := 0;
      sE := EvalScriptExpr(T, S, 1);
      nP := -1;
      T.ParenPos := Pos('(', sE);
      if T.ParenPos > 0 then
        sE := Copy(sE, 1, T.ParenPos - 1);
      T.CmdArg := sE;
      sQ := '';
      T.PromptKind := sE;
      sV274 := sE;
      Delete(sV274, 1, 1);
      if (sE[1] = '%') and (Length(sE) >= 2) then
      begin
    nEdi := T.WordPos;
      sQ := AnsiLowerCase(EvalScriptExpr(T, 'get ' + S, 3));
      nF := Pos('(', sQ);
      if nF > 0 then
        sQ := Copy(sQ, 1, nF - 1);
      if gCmdListah7.IndexOf(sQ) > gCmdCounteh then
      begin
        sG := EvalScriptExpr(T, S, -2);
        a := 0;
        wr := 0;
        GetArraySize(T, sV274, a, wr, True);
        a := 1;
        wr := 1;
        T.ParenPos := 0;
        while sG <> '' do
        begin
          nL3 := Pos(#13, sG);
          fzZ2.bF := False;
          nLenQ := Pos(#10, sG);
          if nL3 > nLenQ then
          begin
            fzZ2.bF := True;
            nL3 := nLenQ;
          end;
          if nL3 > 0 then
            nK3 := nL3 - 1
          else
            nK3 := Length(sG);
          sQ := Copy(sG, 1, nK3);
          if (not fzZ2.bF) and (Copy(sG, nK3 + 2, 1) = #10) then
            Delete(sG, 1, nK3 + 2)
          else
            Delete(sG, 1, nK3 + 1);
          while sQ <> '' do
          begin
            nL3 := Pos(#9, sQ);
            if nL3 > 0 then
              nK3 := nL3 - 1
            else
              nK3 := Length(sQ);
            T.CmdArg2 := Copy(sQ, 1, nK3);
            Delete(sQ, 1, nK3 + 1);
            sE := sV274;
            cKz := '%';
            nI := FindScriptVar(T, cKz, sE, a, wr);
            sE := T.CmdArg2;
            StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
            Inc(wr);
          end;
          Inc(a);
          wr := 1;
        end;
      end
      else
    if sQ = 'prompt' then
      begin
        sG := EvalScriptExpr(T, S, -2);
        a := 0;
        wr := 0;
        GetArraySize(T, sV274, a, wr, True);
        a := 1;
        wr := 1;
        T.ParenPos := 0;
        sQ := EvalScriptExpr(T, 'get ' + sG, wr);
        while sQ <> '' do
        begin
          sE := sV274;
          cKz := '%';
          nI := FindScriptVar(T, cKz, sE, a, wr);
          sE := sQ;
          StoreScriptVar(T, cKz, nI, T.CmdArg, T.ParenPos, sE, a, wr);
          Inc(wr);
          sQ := EvalScriptExpr(T, 'get ' + sG, wr);
        end;
      end
      else
      begin
    Delete(sE, 1, 1);
      Inc(nEdi);
      nF := Length(S);
      fzZ2.bF := False;
      while (nEdi <= nF) and (S[nEdi] in (['[', ']'] + gWordCharsadq)) do
      begin
        if S[nEdi] = '[' then
        begin
          fzZ2.bF := True;
          Break;
        end;
        Inc(nEdi);
      end;
      if not fzZ2.bF then
        while (nEdi <= nF) and not (S[nEdi] in (gWordCharsadq - ['[', ']'])) do
        begin
          if S[nEdi] = '[' then
          begin
            fzZ2.bF := True;
            Break;
          end;
          Inc(nEdi);
        end;
      if fzZ2.bF then
        T.CmdArg := Copy(S, 1, Pos(']', S))
      else
        T.CmdArg := '';
      T.CmdArg2 := T.CmdArg;
      if TryStrToInt(EvalScriptExpr(T, T.CmdArg, 2), Integer(a)) then
      begin
        bNum := False;
        try
          T.CmdArg := EvalScriptExpr(T, T.CmdArg, 3);
          if T.CmdArg <> '' then
          begin
            wr := StrToInt(T.CmdArg);
            bNum := True;
          end
          else
            wr := 1;
        except
          wr := 1;
        end;
        nP := Pos(']', S);
        T.CmdArg := Copy(S, nP + 1, Length(S) - nP + 1);
        if Length(T.CmdArg) > 0 then
          if (T.CmdArg[1] = ' ') or (T.CmdArg[1] = #9) then
            Delete(T.CmdArg, 1, 1);
        nI := FindScriptVar(T, '%', sE, a, wr);
        sW278 := sE;
        sE := EvalScriptExpr(T, 'calc ' + T.CmdArg, -1);
        try
          T.CmdArg := ParseWaitSuffix(sE, nD, nM);
        except
          nM := 1;
        end;
        if nM > 0 then
          T.CmdArg := sE;
        if nD = 0 then
          sE := T.CmdArg;
        T.CmdArg := T.CmdArg2;
        if bNum or (Pos('|', sE) = 0) then
          StoreScriptVar(T, '%', nI, T.CmdArg, T.ParenPos, sE, a, wr)
        else
        begin
    if T.ParenPos > 0 then
        nP := StrToInt(T.CmdArg)
      else
        nP := -1;
      sV274 := sE;
      nLenQ := Length(sV274);
      if nLenQ > 0 then
      begin
        if sV274[nLenQ] <> '/' then
        begin
          sV274 := sV274 + '/';
          Inc(nLenQ);
        end;
        fzZ10.nPos2 := 1;
        sE := '';
        wr := 1;
        fzZ12.bOwn := False;
        nPrevY := wr;
        nPrevXQ := a;
        if nP >= 0 then
        begin
          if Cardinal(a) > Length(gScriptso3[nP].Arr48[nI].Data) then
            SetLength(gScriptso3[nP].Arr48[nI].Data, a);
        end
        else
        begin
          if Cardinal(a) > Length(T.Arr48[nI].Data) then
            SetLength(T.Arr48[nI].Data, a);
        end;
        if fzZ10.nPos2 <= nLenQ then
        repeat
          case sV274[fzZ10.nPos2] of
            '|':
              begin
                fzZ12.bOwn := True;
                Inc(wr);
              end;
            '/':
              begin
                fzZ12.bOwn := True;
                Inc(a);
                wr := 1;
              end;
          else
            sE := sE + sV274[fzZ10.nPos2];
          end;
          if fzZ12.bOwn then
          begin
            fzZ12.bOwn := False;
            if nP >= 0 then
              gScriptso3[nP].Arr48[nI].Data[nPrevXQ - 1][nPrevY - 1] := sE
            else
              T.Arr48[nI].Data[nPrevXQ - 1][nPrevY - 1] := sE;
            if fzZ10.nPos2 < nLenQ then
            begin
              if nP >= 0 then
              begin
                fzZ10.nRows := Length(gScriptso3[nP].Arr48[nI].Data);
              if fzZ10.nRows > 0 then
              begin
                nCols := Length(gScriptso3[nP].Arr48[nI].Data[0]);
                if nCols < Cardinal(wr) then
                begin
                  fzZ12.bOwn := True;
                  nCols := wr;
                end;
              end
              else
                nCols := 1;
              if Cardinal(fzZ10.nRows) < Cardinal(a) then
              begin
                fzZ12.bOwn := True;
                fzZ10.nRows := a;
              end;
              if fzZ12.bOwn then
                SetLength(gScriptso3[nP].Arr48[nI].Data, fzZ10.nRows, nCols);
              end
              else
              begin
                fzZ10.nRows := Length(T.Arr48[nI].Data);
              if fzZ10.nRows > 0 then
              begin
                nCols := Length(T.Arr48[nI].Data[0]);
                if nCols < Cardinal(wr) then
                begin
                  fzZ12.bOwn := True;
                  nCols := wr;
                end;
              end
              else
                nCols := 1;
              if Cardinal(fzZ10.nRows) < Cardinal(a) then
              begin
                fzZ12.bOwn := True;
                fzZ10.nRows := a;
              end;
              if fzZ12.bOwn then
                SetLength(T.Arr48[nI].Data, fzZ10.nRows, nCols);
              end;
            end;
            fzZ12.bOwn := False;
            sE := '';
          end;
          nPrevY := wr;
          nPrevXQ := a;
          Inc(fzZ10.nPos2);
        until fzZ10.nPos2 > nLenQ;
      end;
        end;
      end
      else
      begin
    T.CmdArg := EvalScriptPoint(T, S, 2);
      if T.CmdArg[1] = '%' then
      begin
        cKz := '%';
        a := 1;
        wr := 1;
        nI := FindScriptVar(T, cKz, sE, a, wr);
        nL3 := nI;
        sE := T.CmdArg;
        Delete(sE, 1, 1);
        a := 1;
        wr := 1;
        nI := FindScriptVar(T, cKz, sE, a, wr);
        nK3 := nI;
        nX := PosEx('[', S, T.WordPos);
        nF := PosEx(']', S, nX);
        if (nX > 0) and (nF > 0) then
        begin
          sG := Copy(S, nX + 1, nF - nX - 1);
          sG := EvalScriptExpr(T, 'calc ' + sG, -1);
          nX := Length(T.Arr48[nK3].Data);
          if nX > 0 then
            nF := Length(T.Arr48[nK3].Data[0])
          else
            nF := 0;
          SetLength(T.Arr48[nL3].Data, nF, 1);
          nX := StrToInt(sG);
          Dec(nX);
          Dec(nF);
          for nM := 0 to nF do
            T.Arr48[nL3].Data[nM][0] := T.Arr48[nK3].Data[nX][nM];
        end
        else
        begin
    nX := Length(T.Arr48[nK3].Data);
      if nX > 0 then
        nF := Length(T.Arr48[nK3].Data[0])
      else
        nF := 0;
      SetLength(T.Arr48[nL3].Data, nX, nF);
      Dec(nX);
      Dec(nF);
      if nX >= 0 then
        repeat
          for nM := 0 to nF do
            T.Arr48[nL3].Data[nX][nM] := T.Arr48[nK3].Data[nX][nM];
          Dec(nX);
        until nX < 0;
        end;
      end
      else
      begin
    nI := FindScriptVar(T, '%', sE, a, wr);
      nP := T.ScriptStrToInt(T.CmdArg2);
      if nP >= 0 then
        SetLength(gScriptso3[nP].Arr48[nI].Data, 0, 0)
      else
        SetLength(T.Arr48[nI].Data, 0, 0);
      sV274 := EvalScriptExpr(T, S, -2);
      nLenQ := Length(sV274);
      if nLenQ > 0 then
      begin
        if sV274[nLenQ] <> '/' then
        begin
          sV274 := sV274 + '/';
          Inc(nLenQ);
        end;
        fzZ10.nPos2 := 1;
        sE := '';
        a := 1;
        wr := 1;
        fzZ12.bOwn := False;
        nPrevY := wr;
        nPrevXQ := a;
        if nP >= 0 then
          SetLength(gScriptso3[nP].Arr48[nI].Data, 1, 1)
        else
          SetLength(T.Arr48[nI].Data, 1, 1);
        if fzZ10.nPos2 <= nLenQ then
        repeat
          if (sV274[fzZ10.nPos2] = '"') and (fzZ10.nPos2 > 1) then
            case sV274[fzZ10.nPos2 - 1] of
              '/', '|':
                if Pos('findwindow', AnsiLowerCase(S)) > 0 then
                begin
                  pBar := PosEx('|', sV274, fzZ10.nPos2);
                  pSlash := PosEx('/', sV274, fzZ10.nPos2);
                  while pBar + pSlash > 0 do
                  begin
                    if pBar = 0 then
                      pBar := pSlash
                    else if (pSlash <> 0) and (pBar > pSlash) then
                      pBar := pSlash;
                    if sV274[pBar - 1] = '"' then
                    begin
                      Inc(fzZ10.nPos2);
                      sE := sE + Copy(sV274, fzZ10.nPos2, pBar - fzZ10.nPos2 - 1);
                      fzZ10.nPos2 := pBar;
                      Break;
                    end;
                    pSlash := PosEx('/', sV274, pBar + 1);
                    pBar := PosEx('|', sV274, pBar + 1);
                  end;
                end;
            end;
          case sV274[fzZ10.nPos2] of
            '|':
              begin
                fzZ12.bOwn := True;
                Inc(wr);
              end;
            '/':
              begin
                fzZ12.bOwn := True;
                Inc(a);
                wr := 1;
              end;
          else
            sE := sE + sV274[fzZ10.nPos2];
          end;
          if fzZ12.bOwn then
          begin
            fzZ12.bOwn := False;
            if nP >= 0 then
            begin
              gScriptso3[nP].Arr48[nI].Data[nPrevXQ - 1][nPrevY - 1] := sE;
              fzZ10.nRows := Length(gScriptso3[nP].Arr48[nI].Data);
              if fzZ10.nRows > 0 then
              begin
                nCols := Length(gScriptso3[nP].Arr48[nI].Data[0]);
                if nCols < Cardinal(wr) then
                begin
                  fzZ12.bOwn := True;
                  nCols := wr;
                end;
              end
              else
                nCols := 1;
              if Cardinal(fzZ10.nRows) < Cardinal(a) then
              begin
                fzZ12.bOwn := True;
                fzZ10.nRows := a;
              end;
              if fzZ12.bOwn then
                SetLength(gScriptso3[nP].Arr48[nI].Data, fzZ10.nRows, nCols);
            end
            else
            begin
              T.Arr48[nI].Data[nPrevXQ - 1][nPrevY - 1] := sE;
              fzZ10.nRows := Length(T.Arr48[nI].Data);
              if fzZ10.nRows > 0 then
              begin
                nCols := Length(T.Arr48[nI].Data[0]);
                if nCols < Cardinal(wr) then
                begin
                  fzZ12.bOwn := True;
                  nCols := wr;
                end;
              end
              else
                nCols := 1;
              if Cardinal(fzZ10.nRows) < Cardinal(a) then
              begin
                fzZ12.bOwn := True;
                fzZ10.nRows := a;
              end;
              if fzZ12.bOwn then
                SetLength(T.Arr48[nI].Data, fzZ10.nRows, nCols);
            end;
            fzZ12.bOwn := False;
            sE := '';
          end;
          nPrevY := wr;
          nPrevXQ := a;
          Inc(fzZ10.nPos2);
        until fzZ10.nPos2 > nLenQ;
        if nP >= 0 then
          SetLength(gScriptso3[nP].Arr48[nI].Data, fzZ10.nRows - 1)
        else
    SetLength(T.Arr48[nI].Data, fzZ10.nRows - 1);
      end;
      end;
      end;
      end;
    if T.LoggingCommands then
      begin
        sV274 := T.LogPrefix;
        T.LogPrefix := '';
        { Значение расширяется БЕЗЗНАКОВО, то есть операнд Cardinal и берётся
          64-битная перегрузка IntToStr64. Приведение здесь надо ставить
          ЯВНО. }
        T.Msg := '%' + sW278 + ' [ ' + IntToStr(Cardinal(a)) + ' ' +
          IntToStr(Cardinal(wr)) + ' ]' + ' = ' + sE + #0;
        TScanThread(T).Synchronize(T.SyncLogMsg);
        T.LogPrefix := sV274;
      end;
      Exit;
      end;
    if ((sE[1] = '#') or (sE[1] = '$')) and (Length(sE) >= 2) then
      begin
        cKz := sE[1];
        Delete(sE, 1, 1);
        if cKz = '#' then
        begin
          nI := FindScriptVar(T, '#', sE, a, wr);
          sE := EvalScriptExpr(T, S, -2);
          sType := sE;
          sE := ParseWaitSuffix(sE, nD, nM);
          if T.StopRequested then
            Exit;
          if nD <> 0 then
          begin
            T.Msg := '(' + IntToStr(T.CurLine) + '): ' + gEvalErrorsl6[nD] +
              ' (pos:' + IntToStr(nM) + ' ''' + sType + ''')' + #0;
            ShowScriptMsg(T);
            if T.ToMsgBox then
            begin
              T.StopRequested := True;
              T.Flag91 := False;
              T.RestartFlag := True;
            end;
            Exit;
          end
          else
            StoreScriptVar(T, '#', nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end
        else
        begin
          nI := FindScriptVar(T, '$', sE, a, wr);
          sE := EvalScriptExpr(T, S, -2);
          StoreScriptVar(T, '$', nI, T.CmdArg, T.ParenPos, sE, a, wr);
        end;
        T.PromptKind := '';
        if T.LoggingCommands then
        begin
          T.CmdArg := T.LogPrefix;
          T.LogPrefix := '';
          T.Msg := cKz + sV274 + ' = ' + sE + #0;
          TScanThread(T).Synchronize(T.SyncLogMsg);
          T.LogPrefix := T.CmdArg;
        end;
        Exit;
      end;
    T.ParenPos := Pos('.', sE);
      T.CmdArg := sE;
      if T.ParenPos > 0 then
      begin
        Delete(T.CmdArg, 1, T.ParenPos);
        nD := T.ParenPos;
        nP := T.ScriptStrToInt(T.CmdArg);
        T.CmdArg := sE;
        sE := Copy(sE, 1, nD - 1);
        T.ClProc := gScriptso3[nP].ProcessHandle;
      end
      else
        T.ClProc := T.ProcessHandle2;
      nJ := gCmdListah7.IndexOf(LowerCase(sE));
      nD := 0;
      if (nJ > 0) and not (nJ in [$28, $4C..$4E, $54, $5A, $C3..$C4]) then
        sQ := ParseWaitSuffix(EvalScriptExpr(T, S, -2), nD, nM)
      else
        sQ := '';
      if nD <> 0 then
      begin
        T.Msg := '(' + IntToStr(T.CurLine) + '): ' + gEvalErrorsl6[nD] +
          ' (pos:' + IntToStr(nM) + ')' + #0;
        ShowScriptMsg(T);
        if T.ToMsgBox then
        begin
          T.StopRequested := True;
          T.Flag91 := False;
          T.RestartFlag := True;
        end;
        Exit;
      end;
    sE := T.CmdArg;

    case nJ of
    $10:
    begin
    a := gClT591204ko[T.ClVerIdx];
      if (Length(sQ) > 1) and (sQ[1] = '0') then
        sQ := '0x' + sQ;
      fzZ7.nv := StrToInt(sQ);
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ7.nv, 4, DWORD(wr));
    end;
    $11, $DC..$DF:
    begin
    if (T.PerfFreq > 0) and QueryPerformanceCounter(fzZ12.pc) then
        a := Trunc(fzZ12.pc / T.PerfFreq * 1000)
      else
        a := GetTickCount;
      if nP < 0 then
      begin
        case nJ of
          $11: T.StartTick := a;
          $DC: T.Tick1 := a;
          $DD: T.Tick2 := a;
          $DE: T.Tick3 := a;
          $DF: T.Tick4 := a;
        end;
      end
      else
      begin
        case nJ of
          $11: gScriptso3[nP].StartTick := a;
          $DC: gScriptso3[nP].Tick1 := a;
          $DD: gScriptso3[nP].Tick2 := a;
          $DE: gScriptso3[nP].Tick3 := a;
          $DF: gScriptso3[nP].Tick4 := a;
        end;
      end;
    end;
    $12, $22:
    begin
    fzZ8.grid := fmSecondfj.sgLastObject;
      a := gClT591074cp[1, T.ClVerIdx];
      ScSetCl(T, TGridCracker(fzZ8.grid), sQ, a);
    end;
    $13:
    begin
    a := gClT590D54e[T.ClVerIdx];
      ScSetCl(T, nil, sQ, a);
    end;
    $14, $23:
    begin
    fzZ8.grid := fmSecondfj.sgLastTarget;
      a := gClT591074cp[2, T.ClVerIdx];
      ScSetCl(T, TGridCracker(fzZ8.grid), sQ, a);
    end;
    $15..$17:
    begin
    a := gClT590E80ep[T.ClVerIdx];
      if (sQ[1] = '0') and (Length(sQ) > 1) then
        sQ := '0x' + sQ;
      fzZ8.wv := StrToInt(sQ);
      case nJ of
        $15: Inc(a, 0);
        $16: Inc(a, 2);
        $17: Inc(a, 4);
      end;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ8.wv, 2, DWORD(wr));
    end;
    $18:
    begin
    a := gClT590E1C3[T.ClVerIdx];
      ScSetCl(T, nil, sQ, a);
    end;
    $19:
    begin
    a := gClT590CF0am[T.ClVerIdx];
      ScSetCl(T, nil, sQ, a);
    end;
    $1A:
    begin
    a := gClT590C8Chr[T.ClVerIdx];
      ScSetCl(T, nil, sQ, a);
    end;
    $1B:
    begin
    a := gClT590C28o3[T.ClVerIdx];
      sQ := IntToStr(gClT590BC4y2[T.ClVerIdx] + StrToInt64(sQ));
      ScSetCl(T, nil, sQ, a);
    end;
    $1C:
    begin
    a := gClT590DB8y6[T.ClVerIdx];
      ScSetCl(T, nil, sQ, a);
    end;
    $1E:
    begin
    a := gClT590B60dt[T.ClVerIdx];
      ScSetCl(T, nil, sQ, a);
    end;
    $27:
    begin
    a := gClT591010ajm[T.ClVerIdx];
      fzZ9.bv := StrToInt(sQ);
      if fzZ9.bv > 0 then
        fzZ9.bv := 1;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ9.bv, 1, DWORD(wr));
    end;
    $25:
    begin
    a := gClT590FACbx[T.ClVerIdx];
      ReadProcessMemory(T.ClProc, Pointer(a), @a, 4, DWORD(wr));
      wr := a + $154;
      Inc(a, $9C);
      fzZ6.v184 := StrToInt(sQ);
      if Cardinal(fzZ6.v184) > 0 then
        fzZ6.v184 := 1;
      WriteProcessMemory(T.ClProc, Pointer(wr), @fzZ6.v184, 4, DWORD(wr));
      ReadProcessMemory(T.ClProc, Pointer(a), @nP, 4, DWORD(wr));
      case fzZ6.v184 of
        0: nP := nP and not $40;
        1: nP := nP or $40;
      end;
      WriteProcessMemory(T.ClProc, Pointer(a), @nP, 4, DWORD(wr));
    end;
    $28:
    begin
    { Здесь именно EvalScriptPoint, а не GetWord. }
      T.Str1048B8 := EvalScriptPoint(T, S, -2);
      while (Length(T.Str1048B8) > 0) and not (T.Str1048B8[1] in [''''] + gWordCharsadq) do
        Delete(T.Str1048B8, 1, 1);
      while (Length(T.Str1048B8) > 0) and not (T.Str1048B8[Length(T.Str1048B8)] in [''''] + gWordCharsadq) do
        Delete(T.Str1048B8, Length(T.Str1048B8), 1);
      nP := Length(T.Str1048B8);
      if (nP > 1) and (T.Str1048B8[1] = '''') and (T.Str1048B8[nP] = '''') then
        T.Str1048B8 := Copy(T.Str1048B8, 2, nP - 2);
    end;
    $2A:
    begin
    sQ := EvalScriptExpr(T, S, -2);
      if not TryStrToInt(EvalScriptExpr(T, sQ, 0), nX) then
        nX := -1;
      if not TryStrToInt(EvalScriptExpr(T, sQ, 1), nF) then
        nF := -1;
      if not TryStrToInt(EvalScriptExpr(T, sQ, 2), nK3) then
        nK3 := -1;
      if not TryStrToInt(EvalScriptExpr(T, sQ, 3), nL3) then
        nL3 := -1;
      nP := 0;
      a := 0;
      if (nK3 < 0) or (nL3 < 0) then
      begin
        nP := 1;
        case nL3 of
          1: a := 0;
          2: a := Cardinal(-1);
          3: a := Cardinal(-2);
          4: a := 1;
        end;
      end;
      if (not TryStrToInt(EvalScriptExpr(T, sQ, 4), fzZ10.nRows)) or (fzZ10.nRows = 0) then
        fzZ10.nRows := T.ClientWnd2;
      if (nK3 < 0) and (nL3 > 0) then
      begin
        case nL3 of
          1: a := 0;
          4: a := 1;
        end;
        nO := GetWindowThreadProcessId(fzZ10.nRows, nil);
        if nO = GetCurrentThreadId then
          Exit;
        AttachThreadInput(GetCurrentThreadId, nO, True);
        SetWindowPos(fzZ10.nRows, a, 0, 0, 0, 0, $23);
        AttachThreadInput(GetCurrentThreadId, nO, False);
      end
      else
        SetWindowPos(fzZ10.nRows, a, nX, nF, nK3, nL3, nP);
    end;
    $2C:
    begin
    sQ := EvalScriptExpr(T, S, -2);
      if nP < 0 then
        nP := StrToInt(T.Name);
      try
        ApplyWorkWindow(T, StrToInt(sQ), nP);
      except
      end;
      if T.LogToParent then
      begin
        T.ClientWnd := gScriptso3[nP].ClientWnd;
        T.ClientWnd2 := gScriptso3[nP].ClientWnd2;
        T.ThreadId := gScriptso3[nP].ThreadId;
        T.ProcessId := gScriptso3[nP].ProcessId;
        T.ProcessHandle := gScriptso3[nP].ProcessHandle;
        T.ProcessHandle2 := gScriptso3[nP].ProcessHandle2;
      end;
    end;
    $38:
    begin
    try
        nX := StrToInt(EvalScriptExpr(T, S, -2));
      except
        nX := 1;
      end;
      case nX of
        0: TScanThread(T).Priority := tpLowest;
        2: TScanThread(T).Priority := tpHighest;
        3: TScanThread(T).Priority := tpTimeCritical;
      else
        TScanThread(T).Priority := tpNormal;
      end;
    end;
    $49:
    begin
    try
        T.PauseCmd := IntToStr(StrToInt(EvalScriptExpr(T, S, -2)));
        T.StopOnPause := True;
      except
        T.PauseCmd := '1';
      end;
    end;
    $4A:
    begin
    a := gClT590908cx[T.ClVerIdx];
      fzZ8.wv := StrToInt(sQ);
      { Сравнение и на входе, и внизу -- это `if ... then repeat ... until`,
        а не `while`: у `while` сравнение было бы одно. }
      if fzZ8.wv > $421 then
        repeat
          fzZ8.wv := fzZ8.wv - $421;
        until fzZ8.wv <= $421;
      if fzZ8.wv < 2 then
        fzZ8.wv := 2;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ8.wv, 2, DWORD(wr));
    end;
    $4D:
    begin
    a := 250;
      fzZ2.bF := False;
      T.ClipLen := 0;
      sV274 := EvalScriptExpr(T, S, -2);
      while not fzZ2.bF and (Cardinal(a) > 0) do
      begin
        if T.StopRequested then
          Break;
        try
          SetClipboardText(Clipboard, sV274);
          fzZ2.bF := True;
          T.ClipLen := Length(sV274);
        except
          SysUtils.Sleep(1);
        end;
        Dec(a);
      end;
    end;
    $4E:
    begin
    TScanThread(T).Msg := '';
      sE := LowerCase(EvalScriptPoint(T, S, 2));
      if TScanThread(T).InLua then
        sW278 := EvalScriptPoint(T, S, -1)
      else
        sW278 := EvalScriptExpr(T, S, -1);
      if sE = 'off' then
      begin
        TScanThread(T).IsProc := False;
        TScanThread(T).LoggingCommands := False;
        TScanThread(T).Synchronize(TScanThread(T).SyncLog737C);
        Exit;
      end;
      if sE = 'on' then
      begin
        TScanThread(T).IsProc := True;
        Exit;
      end;
      if sE = 'commands' then
      begin
        TScanThread(T).LoggingCommands := True;
        TScanThread(T).Synchronize(TScanThread(T).SyncLog737C);
        Exit;
      end;
      if sE = 'clear' then
      begin
        fmSecondfj.mLog.Lines.SetText(#0);
        Exit;
      end;
      if sE = 'save' then
      begin
        fmSecondfj.mLog.Lines.SaveToFile(EvalScriptExpr(T, S, -3));
        Exit;
      end;
      if sE = 'clear_all' then
      begin
        TScanThread(T).Synchronize(TScanThread(T).SyncClearLog);
        Exit;
      end;
      if sE = 'clear_current' then
      begin
        TScanThread(T).LogView.Lines.SetText(#0);
        Exit;
      end;
      if sE = 'save_current' then
      begin
        TScanThread(T).LogView.Lines.SaveToFile(EvalScriptExpr(T, S, -3));
        Exit;
      end;
      if sE = 'open' then
      begin
        SplitCmdLine(T, 'calc ' + sW278);
        if not TryStrToInt(TScanThread(T).CmdParts[3], nX) then
          nX := -1;
        fmSecondfj.FLogWin.Left := nX;
        if not TryStrToInt(TScanThread(T).CmdParts[4], nX) then
          nX := -1;
        fmSecondfj.FLogWin.Top := nX;
        if not TryStrToInt(TScanThread(T).CmdParts[5], nX) then
          nX := -1;
        fmSecondfj.FLogWin.Width := nX;
        if not TryStrToInt(TScanThread(T).CmdParts[6], nX) then
          nX := -1;
        fmSecondfj.FLogWin.Height := nX;
        if gDlg5966F8c6 = nil then
        begin
          if (fmSecondfj.FLogWin.Width = -1) or (fmSecondfj.FLogWin.Height = -1) then
          begin
            fmSecondfj.FLogWin.Width := $117;
            fmSecondfj.FLogWin.Height := $14C;
          end;
          TScanThread(T).Synchronize(TScanThread(T).SyncLog6548);
          Exit;
        end;
        T.Synchronize(T.SyncShowLogWin);
        Exit;
      end;
      if sE = 'close' then
      begin
        if gDlg5966F8c6 <> nil then
          if PLogWinZ(gDlg5966F8c6)^.ShownZ then
            TScanThread(T).Synchronize(TScanThread(T).SyncLog6548);
        Exit;
      end;
      if sE = 'mode' then
      begin
        TScanThread(T).LogFlags := 0;
        sE := LowerCase(EvalScriptExpr(T, S, -3));
        if Pos('notime', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags or 1;
        if Pos('nonumber', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags or 2;
        if Pos('noscript', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags or 4;
        if Pos('noline', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags or 8;
        if Pos('compact', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags or $F;
        if Pos('fulltime', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags or $10;
        if Pos('shorttime', sE) > 0 then
          TScanThread(T).LogFlags := TScanThread(T).LogFlags and not $10;
        Exit;
      end;
      if sE = 'level' then
      begin
        if not TryStrToInt(LowerCase(EvalScriptExpr(T, S, -3)),
                           TScanThread(T).LogLevel) then
          TScanThread(T).LogLevel := 1;
        Exit;
      end;
      TScanThread(T).LogPrefix := '';
      sE := sW278;
      Delete(sE, 1, 8);
      sE := FixLineBreaks(sE) + #0;
      nF := Length(sE);
      nO := $3FFE;
      nX := 1;
      nK3 := nO;
      TScanThread(T).LogCrLf := True;
      TScanThread(T).LogCont := False;
      if nF = 0 then
      begin
        TScanThread(T).LogBuf[0] := #0;
        TScanThread(T).Synchronize(TScanThread(T).WriteScriptLog);
        Exit;
      end;
      if nX <= nF then
        repeat
          if nF - nX + 1 > nO then
            nK3 := nO
          else
            nK3 := nF - nX + 1;
          TScanThread(T).LogCrLf := nK3 <> nO;
          Move(sE[nX], TScanThread(T).LogBuf, nK3);
          TScanThread(T).LogBuf[nK3] := #0;
          TScanThread(T).Synchronize(TScanThread(T).WriteScriptLog);
          Inc(nX, nK3);
          if nX <= nF then
            TScanThread(T).LogCont := True;
        until nX > nF;
    end;
    $4C:
    begin
      fzZ2.bF := False;
      a := 9;
      wr := 0;
      nX := 0;
      while Cardinal(Length(S)) >= Cardinal(a) do
      begin
        case S[a] of
          '(': begin
                 Inc(wr);
                 fzZ2.bF := True;
                 if nX = 0 then
                   nX := a;
               end;
          ')': Dec(wr);
        end;
        if fzZ2.bF and (wr = 0) then
          Break;
        Inc(a);
      end;
      if fzZ2.bF and (wr = 0) then
      begin
        sQ := Copy(S, nX + 1, Integer(a) - (nX + 1));
        sE := EvalScriptExpr(T, 'set ' + sQ, 1);
        sQ := EvalScriptExpr(T, 'calc ' + sQ, -2);
        nX := 0;
        if sE[1] = '%' then
        begin
          Delete(sE, 1, 1);
          a := 0;
          wr := 0;
          nI := FindScriptVar(T, '%', sE, a, wr);
          if not TryStrToInt(EvalScriptExpr(T, 'calc ' + sQ, 1), Integer(a)) then
            a := 0;
          if (a = 0) or (not TryStrToInt(EvalScriptExpr(T, 'calc ' + sQ, 2), Integer(wr))) then
            wr := 0;
          GetArraySize(T, sE, a, wr, True);
        end
        else
          nX := 2;
      end
      else
        nX := 1;
      if T.IsProc then
      begin
        case nX of
          1: T.Msg := 'sintax error';
          2: T.Msg := 'array name not recognized';
        end;
        if nX > 0 then
          TScanThread(T).Synchronize(TScanThread(T).SyncLogMsg);
      end;
    end;
    $6B:
    begin
    try
        T.Cnt105BC8 := StrToInt(EvalScriptExpr(T, S, -2));
      except
        T.Cnt105BC8 := 0;
      end;
    end;
    $B2:
    begin
    a := gClT590778a8[T.ClVerIdx];
      fzZ9.bv := StrToInt(sQ);
      if fzZ9.bv > 0 then
        fzZ9.bv := 1;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ9.bv, 1, DWORD(wr));
    end;
    $B3:
    begin
    a := gClT5907DCahr[T.ClVerIdx];
      fzZ9.bv := StrToInt(sQ);
      if fzZ9.bv > 0 then
        fzZ9.bv := 1;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ9.bv, 1, DWORD(wr));
    end;
    $B4:
    begin
    a := gClT5908A4av[T.ClVerIdx];
      fzZ9.bv := StrToInt(sQ);
      if fzZ9.bv > 0 then
        fzZ9.bv := 1;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ9.bv, 1, DWORD(wr));
    end;
    $B5:
    begin
    a := gClT590840j4[T.ClVerIdx];
      fzZ9.bv := StrToInt(sQ);
      if fzZ9.bv > 0 then
        fzZ9.bv := 1;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ9.bv, 1, DWORD(wr));
    end;
    $BE..$C0:
    begin
    case nJ of
        $BE: T.CtlId := 1;
        $BF: T.CtlId := 2;
        $C0: T.CtlId := 3;
      end;
      if not TryStrToInt(sQ, T.CtlValue) then
        T.CtlValue := 0;
      T.Synchronize(T.SyncSetControlText);
    end;
    $C3..$C4:
    begin
    sQ := EvalScriptExpr(T, S, -2);
      nPos := Pos('{', sQ) + 1;
      nEnd := Pos('}', sQ) - 1;
      while (Length(sQ) > nPos) and (sQ[nPos] in [#9, ' ']) do
        Inc(nPos);
      while (nEnd > 0) and (sQ[nEnd] in [#9, ' ']) do
        Dec(nEnd);
      if nEnd - nPos + 1 > 0 then
      begin
        case nJ of
          $C3: gHKSela := 0;
          $C4: gHKSela := 5;
        end;
        sType := AnsiUpperCase(Copy(sQ, nPos, nEnd - nPos + 1));
        sW278 := '';
        fzZ2.bF := False;
        nPos := 0;
        fzZ13B.pK := @gHKNameTablee9[0];
        repeat
          if sType = AnsiUpperCase(fzZ13B.pK^) then
          begin
            fzZ2.bF := True;
            Break;
          end;
          Inc(nPos);
          Inc(fzZ13B.pK);
        until nPos = $66;
        if fzZ2.bF then
        begin
          T.Msg := sType;
          T.CapWnd := 0;
          T.HKMods := [];
          if Pos('~', sQ) > 0 then
          begin
            TScanThread(T).HKMods := T.HKMods + cHKShift;
            sW278 := 'Shift + ' + sW278;
          end;
          if Pos('@', sQ) > 0 then
          begin
            TScanThread(T).HKMods := T.HKMods + cHKAlt;
            sW278 := 'Alt + ' + sW278;
          end;
          if Pos('^', sQ) > 0 then
          begin
            TScanThread(T).HKMods := T.HKMods + cHKCtrl;
            sW278 := 'Ctrl + ' + sW278;
          end;
          case gHKSela of
            0: T.CapWnd := 0;
            5: T.CapWnd := 1;
          end;
          T.Synchronize(T.SyncSetHotKey);
          T.ClipLen := T.CapWnd;
        end
        else
          T.ClipLen := 3;
      end
      else
        T.ClipLen := 4;
      if (T.ClipLen > 0) and T.IsProc and fmSecondfj.miSetHKError.Checked then
      begin
        T.LogPrefix := gCmdListah7[nJ];
        case T.ClipLen of
          1: T.Msg := 'Already exist and enabled. ''' + sW278 + sType + '''';
          2: T.Msg := 'Can''t add new HotKey. ''' + sW278 + sType + '''';
          3: T.Msg := 'Unrecognized Key. ''' + sType + '''';
          4: T.Msg := 'Syntax error.';
        end;
        TScanThread(T).Synchronize(T.SyncLogMsg);
        T.LogPrefix := '';
      end;
    end;
    $C8..$DB:
    begin
    T.CtlId := nJ;
      if not TryStrToInt(sQ, T.CtlValue) then
        T.CtlValue := 0;
      T.Synchronize(T.SyncSetControlText);
    end;
    $E6..$E9:
    begin
    case nJ of
        $E6: T.Cnt104674 := StrToInt(sQ);
        $E7: T.Cnt104678 := StrToInt(sQ);
        $E8: T.Cnt10467C := StrToInt(sQ);
        $E9: T.Cnt104680 := StrToInt(sQ);
      end;
    end;
    $EA, $EC..$ED:
    begin
    case nJ of
        $ED: T.ClickDelay := StrToInt(sQ);
        $EA: T.SendDelay := StrToInt(sQ);
        $EC: T.PauseStr := sQ;
      end;
    end;
    $EF..$F0:
    begin
    case nJ of
        $EF: T.Fld10488C := StrToInt(sQ);
        $F0: T.Fld104890 := StrToInt(sQ);
      end;
    end;
    $113..$114:
    begin
    a := gClT591268lt[T.ClVerIdx];
      ReadProcessMemory(T.ClProc, Pointer(a), @a, 4, DWORD(wr));
      Inc(a, $11C);
      ReadProcessMemory(T.ClProc, Pointer(a), @a, 4, DWORD(wr));
      case nJ of
        $113: Inc(a, $30);
        $114: Inc(a, $34);
      end;
      WriteProcessMemory(T.ClProc, Pointer(a), @fzZ9.bv, 1, DWORD(wr));
    end;
    else
    if Copy(LowerCase(sE), 1, 7) = 'easyuo*' then
      begin
        sE := Copy(sE, 8, $20);
        TRegistry(T.Obj43FC).RootKey := HKEY_CURRENT_USER;
        TRegistry(T.Obj43FC).OpenKey('Software\EasyUO', True);
        TRegistry(T.Obj43FC).WriteString(sE, EvalScriptExpr(T, S, -2));
        TRegistry(T.Obj43FC).CloseKey;
        Exit;
      end;
    sE := sQ;
      sQ := gCmdListah7[nJ];
      { Это НЕ Exit, а выход из блока: следующий кусок `set/else_P4` идёт
        встык. }
      if (Pos('.', sQ) <= 0) and (gCmdListah7.Objects[nJ] is TMyStr) then
      begin
        sQ := PValDescZ(gCmdListah7.Objects[nJ])^.TxtZ;
        fzZ12.qErr := -1;
        nX := Pos(';', sQ);
        fzZ12.qAddr := 0;
        if nX <= 0 then
          Exit;
        repeat
          TScanThread(T).CmdArg := Copy(sQ, 1, nX - 1);
          nF := Pos(',', TScanThread(T).CmdArg);
          if not TryStrToInt64(Copy(TScanThread(T).CmdArg, 1, nF - 1), fzZ12.qErr) then
            fzZ12.qErr := 0;
          Delete(TScanThread(T).CmdArg, 1, nF);
          cKz := TScanThread(T).CmdArg[1];
          Delete(sQ, 1, nX);
          nX := Pos(';', sQ);
          fzZ12.qAddr := fzZ12.qAddr + fzZ12.qErr;
          if (fzZ12.qAddr = 0) or (TScanThread(T).ProcessId = 0) then
          begin
            fzZ12.qErr := -1;
            Exit;
          end;
          if nX > 0 then
            case cKz of
              'd':
                begin
                  ReadMemByName(TScanThread(T).ProcessHandle2, fzZ11.mB, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                  fzZ12.qAddr := Cardinal(fzZ11.mB);
                end;
              'l':
                begin
                  ReadMemByName(TScanThread(T).ProcessHandle2, fzZ12.qC, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                  fzZ12.qAddr := fzZ12.qC;
                end;
            else
              fzZ12.qErr := -2;
            end
          else
            case cKz of
              'b':
                begin
                  fzZ11.bF211 := StrToInt(sE);
                  WriteMemByName(TScanThread(T).ProcessHandle2, fzZ11.bF211, fzZ12.qErr, fzZ12.qAddr,
        1, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              'w':
                begin
                  fzZ11.wF214 := StrToInt(sE);
                  WriteMemByName(TScanThread(T).ProcessHandle2, fzZ11.wF214, fzZ12.qErr, fzZ12.qAddr,
        2, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              'd':
                begin
                  { ДЕФЕКТ, тот же, что N34 в `writemem`: после записи Double
                    НЕТ выхода, и следом та же ячейка пишется как Cardinal }
                  { сравнение С ЕДИНИЦЕЙ, а не вычитание: `Length(X) > 1` даёт две
                    команды, `Length(X) - 1 > 0` -- три }
                  if Length(TScanThread(T).CmdArg) > 1 then
                    if TScanThread(T).CmdArg[2] = 'o' then
                    begin
                      dF230 := StrToFloat(sE);
                      WriteMemByName(TScanThread(T).ProcessHandle2, dF230, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                    end;
                  fzZ11.mB := StrToInt(sE);
                  WriteMemByName(TScanThread(T).ProcessHandle2, fzZ11.mB, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              'l':
                begin
                  fzZ12.qC := StrToInt64(sE);
                  WriteMemByName(TScanThread(T).ProcessHandle2, fzZ12.qC, fzZ12.qErr, fzZ12.qAddr,
        8, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              'f':
                begin
                  sF220 := StrToFloat(sE);
                  WriteMemByName(TScanThread(T).ProcessHandle2, sF220, fzZ12.qErr, fzZ12.qAddr,
        4, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              'r':
                begin
                  rF228 := StrToFloat(sE);
                  WriteMemByName(TScanThread(T).ProcessHandle2, rF228, fzZ12.qErr, fzZ12.qAddr,
        6, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              'c':
                begin
                  cF219 := sE[1];
                  WriteMemByName(TScanThread(T).ProcessHandle2, cF219, fzZ12.qErr, fzZ12.qAddr,
        1, TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
              's':
                begin
                  ptYQ := Length(sE);
                  if ptYQ > $FF then
                    ptYQ := $FF;
                  bufStr := Copy(sE, 1, ptYQ);
                  WriteMemByName(TScanThread(T).ProcessHandle2, bufStr[1], fzZ12.qErr, fzZ12.qAddr,
        Byte(bufStr[0]), TScanThread(T).MemTarget, TScanThread(T).ProcessId);
                end;
            else
              fzZ12.qErr := -2;
            end;
        until nX <= 0;
        Exit;
      end;
    if gLangOffsety > 0 then
        T.Msg := '(' + IntToStr(T.CurLine) + LoadStr(gLangOffsety + $1BA) + #0
      else
        T.Msg := '(' + IntToStr(T.CurLine) + '): Не могу определить имя переменной' + #0;
      ShowScriptMsg(T);
      if T.ToMsgBox then
      begin
        T.StopRequested := True;
        T.Flag91 := False;
        T.RestartFlag := True;
      end;
    end;
    end;
  114:
    begin
      nJ := TScanThread(T).CurLine + 1;
      nLevel := 0;
      nBack := 0;
      SetLength(aCases, 0);
      while Length(TScanThread(T).Lines) > nJ do
      begin
        sH := TScanThread(T).Lines[nJ];
        sType := EvalScriptPoint(T, sH, 0);
        nF := Pos(':', sType);
        if nF > 0 then
          sType := Copy(sType, 1, nF - 1);
        if sType = 'switch' then Inc(nLevel);
        if sType = 'end_switch' then Dec(nLevel);
        if sType = 'case' then
          if nLevel = 0 then
          begin
            SetLength(aCases, Length(aCases) + 1);
            aCases[Length(aCases) - 1].Line := nJ;
            aCases[Length(aCases) - 1].Text := sH;
          end;
        if nLevel < 0 then
          Break;
        Inc(nJ);
      end;
      if Length(TScanThread(T).Lines) = nJ then
      begin
        if gLangOffsety > 0 then
        begin
          TScanThread(T).Msg := LoadStr(gLangOffsety + $1F2) + #0;
          { игла -- КОРОТКАЯ строка из трёх знаков (' ' ,); в имя команды
            подставляется gCmdList2jj[N] }
          nX := Pos(''''',', TScanThread(T).Msg);
          Insert(gCmdNames2b1[N + 2], TScanThread(T).Msg, nX + 1);
        end
        else
          TScanThread(T).Msg := 'Не могу найти ''end_switch'', проверьте скрипт' + #0;
        ShowScriptMsg(TScanThread(T));
        if TScanThread(T).ToMsgBox then
        begin
          TScanThread(T).StopRequested := True;
          TScanThread(T).Flag91 := False;
          TScanThread(T).RestartFlag := True;
        end;
        Exit;
      end;
      nBack := nJ;
      fzZ2.bF := True;
      sV274 := EvalScriptExpr(T, S, -1);
      for nJ := 0 to Length(aCases) - 1 do
      begin
        nX := Pos(':', aCases[nJ].Text);
        if nX = 0 then
          nX := Length(aCases[nJ].Text) + 1;
        sW278 := Copy(aCases[nJ].Text, 1, nX - 1);
        sW278 := EvalScriptExpr(T, 'calc ' + sW278, -2);
        nX := Length(sW278);
        while (nX > 0) and ((sW278[nX] = ' ') or (sW278[nX] = #9)) do
          Dec(nX);
        sW278 := Copy(sW278, 1, nX);
        if sW278 = sV274 then
        begin
          TScanThread(T).CurLine := Trunc(Integer(aCases[nJ].Line)) - 1;
          fzZ2.bF := False;
          Break;
        end;
        aCases[nJ].Text := sW278;
      end;
      if fzZ2.bF then
      begin
        if (Length(aCases) > 0) and (aCases[Length(aCases) - 1].Text = '') then
          TScanThread(T).CurLine := Trunc(Integer(aCases[Length(aCases) - 1].Line)) - 1
        else
          TScanThread(T).CurLine := nBack;
      end;
      SetLength(aCases, 0);

    end;
  115:
    begin
    nD := Pos(':', S);
    if nD > 0 then
    begin
      Delete(S, 1, nD);
      T.RepeatLine := True;
    end;
    end;
  44, 45:
    begin
    nJ := T.CurLine + 1;
    nDepth := 0;
    while Length(T.Lines) > nJ do
    begin
      sH := T.Lines[nJ];
      sH := EvalScriptPoint(T, sH, 0);
      if (sH = 'while') or (sH = 'while_not') then Inc(nDepth);
      if sH = 'end_while' then Dec(nDepth);
      if nDepth < 0 then Break;
      Inc(nJ);
    end;
    if Length(T.Lines) <= nJ then
    begin
      if gLangOffsety > 0 then
      T.Msg := LoadStr(gLangOffsety + $1B8) + #0
    else
      T.Msg := 'Не могу найти конец цикла: "End_While", проверьте скрипт'#0;
    ShowScriptMsg(T);
    if T.ToMsgBox then
    begin
      T.StopRequested := True;
      T.Flag91 := False;
      T.RestartFlag := True;
    end;
    end
    else
    begin
      bOk := CheckCondition(S);
      if N = 45 then bOk := not bOk;
      if not bOk then
        T.CurLine := nJ;
    end;
    end;
  46:
    begin
    nJ := T.CurLine - 1;
    nDepth := 0;
    while nJ >= 0 do
    begin
      sH := T.Lines[nJ];
      sH := EvalScriptPoint(T, sH, 0);
      if (sH = 'while') or (sH = 'while_not') then Dec(nDepth);
      if sH = 'end_while' then Inc(nDepth);
      if nDepth < 0 then Break;
      Dec(nJ);
    end;
    if nJ < 0 then
    begin
      if gLangOffsety > 0 then
      T.Msg := LoadStr(gLangOffsety + $1B9) + #0
    else
      T.Msg := 'Не могу найти начало цикла: "While", проверьте скрипт'#0;
    ShowScriptMsg(T);
    if T.ToMsgBox then
    begin
      T.StopRequested := True;
      T.Flag91 := False;
      T.RestartFlag := True;
    end;
    end
    else
      T.CurLine := nJ - 1;
    end;
  132:
    begin
      TScanThread(T).Msg := TScanThread(T).ServiceGetStatus;
      TScanThread(T).Synchronize(TScanThread(T).SyncLogMsg);

    end;
  133:
    begin
      TScanThread(T).Msg := TScanThread(T).ServiceCall;
      TScanThread(T).Synchronize(TScanThread(T).SyncLogMsg);

    end;
  134:
    begin
      TScanThread(T).Msg := TScanThread(T).ServiceStop;
      TScanThread(T).Synchronize(TScanThread(T).SyncLogMsg);

    end;
  135:
    begin
      TScanThread(T).Msg := TScanThread(T).ServiceSend;
      TScanThread(T).Synchronize(TScanThread(T).SyncLogMsg);

    end;
  12:
    begin
      sC := EvalScriptExpr(T, S, -1);
      ZeroMemory(@fzZ14.SI, $44);
      ZeroMemory(@fzZ14.PI, $10);
      fzZ14.SI.cb := $44;
      fzZ14.SI.dwFlags := 1;
      fzZ14.SI.wShowWindow := 1;
      SplitCmdLine(T, sC);
      sE := ExtractFilePath(TScanThread(T).CmdParts[0]);
      sQ := sC;
      nLenQ := Length(sQ);
      if nLenQ > 0 then
      begin
        if sQ[1] = '"' then
        begin
          fzZ10.nPos2 := PosEx('"', sQ, 2);
          sQ := Copy(sQ, 2, fzZ10.nPos2 - 2);
        end;
        fzZ10.nPos2 := PosEx(':', sQ, 3);
        if fzZ10.nPos2 > 0 then
          sQ := Copy(sQ, 1, fzZ10.nPos2 - 2);
        fzZ10.nPos2 := PosEx('\\', sQ, 3);
        if fzZ10.nPos2 > 0 then
          sQ := Copy(sQ, 1, fzZ10.nPos2 - 1);
        fzZ10.nPos2 := Pos('.', sQ);
        fzZ10.nRows := fzZ10.nPos2;
        { проверка стоит ДВАЖДЫ -- перед телом и после него: `while` дал бы одну
          проверку и переход на неё, а здесь `if` вокруг `repeat` }
        if fzZ10.nPos2 > 0 then
          repeat
            fzZ10.nRows := fzZ10.nPos2;
            fzZ10.nPos2 := PosEx('.', sQ, fzZ10.nPos2 + 1);
          until fzZ10.nPos2 <= 0;
        sG := AnsiLowerCase(Copy(sQ, fzZ10.nRows + 1, 3));
        if (sG = 'com') or (sG = 'exe') or (sG = 'cmd') or (sG = 'bat') then
        begin
          sG := Copy(sQ, fzZ10.nRows + 4, 1);
          if (sG = ' ') or (sG = '') then
          begin
            sQ := Copy(sQ, 1, fzZ10.nRows + 3);
            sE := ExtractFilePath(sQ);
          end;
        end
        else
          if sG = 'lnk' then
          begin
            sG := Copy(sQ, fzZ10.nRows + 4, 1);
            if (sG = ' ') or (sG = '') then
            begin
              sQ := Copy(sQ, 1, fzZ10.nRows + 3);
              FillChar(fzZ14.rLnk, $76C, 0);
              Move(sQ[1], fzZ14.rLnk,
                IfThen(Length(sQ) <= $105, Length(sQ), 0));
              ReadShortcut(fzZ14.rLnk);
              sC := ShortString(PChar(@fzZ14.rLnk.Args)) + ' ' + string(PChar(@fzZ14.rLnk.Run));
              sE := fzZ14.rLnk.Dir;
            end;
          end;
      end;
      if sE = '' then
        fzZ12.bOwn := CreateProcess(nil, PChar(sC), nil, nil, False, 0, nil, nil, fzZ14.SI, fzZ14.PI)
      else
        fzZ12.bOwn := CreateProcess(nil, PChar(sC), nil, nil, False, 0, nil,
                             PChar(sE), fzZ14.SI, fzZ14.PI);
      if not fzZ12.bOwn then
      begin
        a := GetLastError;
        TScanThread(T).ClipLen := a;
        TScanThread(T).Msg := ' failed';
        if a <> 0 then
          TScanThread(T).Msg := TScanThread(T).Msg + ' ' + SysErrorMessage(a);
        TScanThread(T).Synchronize(T.SyncLogMsg);
      end
      else
        TScanThread(T).ClipLen := fzZ14.PI.dwProcessId;
      CloseHandle(fzZ14.PI.hThread);
      CloseHandle(fzZ14.PI.hProcess);
      SetCurrentDir(gTempFilefv);

    end;
  100:
    begin
      sC := EvalScriptExpr(T, S, -1);
      ZeroMemory(@fzZ14.SI, $44);
      ZeroMemory(@fzZ14.PI, $10);
      fzZ14.SI.cb := $44;
      fzZ14.SI.dwFlags := 1;
      fzZ14.SI.wShowWindow := 1;
      SplitCmdLine(T, sC);
      sE := ExtractFilePath(TScanThread(T).CmdParts[0]);
      sQ := sC;
      nLenQ := Length(sQ);
      if nLenQ > 0 then
      begin
        if sQ[1] = '"' then
        begin
          fzZ10.nPos2 := PosEx('"', sQ, 2);
          sQ := Copy(sQ, 2, fzZ10.nPos2 - 2);
        end;
        fzZ10.nPos2 := PosEx(':', sQ, 3);
        if fzZ10.nPos2 > 0 then
          sQ := Copy(sQ, 1, fzZ10.nPos2 - 2);
        fzZ10.nPos2 := PosEx('\\', sQ, 3);
        if fzZ10.nPos2 > 0 then
          sQ := Copy(sQ, 1, fzZ10.nPos2 - 1);
        fzZ10.nPos2 := Pos('.', sQ);
        fzZ10.nRows := fzZ10.nPos2;
        { проверка стоит ДВАЖДЫ -- перед телом и после него: `while` дал бы одну
          проверку и переход на неё, а здесь `if` вокруг `repeat` }
        if fzZ10.nPos2 > 0 then
          repeat
            fzZ10.nRows := fzZ10.nPos2;
            fzZ10.nPos2 := PosEx('.', sQ, fzZ10.nPos2 + 1);
          until fzZ10.nPos2 <= 0;
        sG := AnsiLowerCase(Copy(sQ, fzZ10.nRows + 1, 3));
        if (sG = 'com') or (sG = 'exe') or (sG = 'cmd') or (sG = 'bat') then
        begin
          sG := Copy(sQ, fzZ10.nRows + 4, 1);
          if (sG = ' ') or (sG = '') then
          begin
            sQ := Copy(sQ, 1, fzZ10.nRows + 3);
            sE := ExtractFilePath(sQ);
          end;
        end
        else
          if sG = 'lnk' then
          begin
            sG := Copy(sQ, fzZ10.nRows + 4, 1);
            if (sG = ' ') or (sG = '') then
            begin
              sQ := Copy(sQ, 1, fzZ10.nRows + 3);
              FillChar(fzZ14.rLnk, $76C, 0);
              Move(sQ[1], fzZ14.rLnk,
                IfThen(Length(sQ) <= $105, Length(sQ), 0));
              ReadShortcut(fzZ14.rLnk);
              sC := ShortString(PChar(@fzZ14.rLnk.Args)) + ' ' + string(PChar(@fzZ14.rLnk.Run));
              sE := fzZ14.rLnk.Dir;
            end;
          end;
      end;
      if sE = '' then
        fzZ12.bOwn := CreateProcess(nil, PChar(sC), nil, nil, False, 0, nil, nil, fzZ14.SI, fzZ14.PI)
      else
        fzZ12.bOwn := CreateProcess(nil, PChar(sC), nil, nil, False, 0, nil,
                             PChar(sE), fzZ14.SI, fzZ14.PI);
      if fzZ12.bOwn then ;
      CloseHandle(fzZ14.PI.hThread);
      while WaitForSingleObject(fzZ14.PI.hProcess, $32) <> 0 do
      begin
        if TScanThread(T).StopRequested then
          Break;
        ScriptIdle;
      end;
      GetExitCodeProcess(fzZ14.PI.hProcess, DWORD(a));
      TScanThread(T).ClipLen := a;
      CloseHandle(fzZ14.PI.hProcess);
      SetCurrentDir(gTempFilefv);

    end;
  13:
    begin
    sC := AnsiLowerCase(EvalScriptExpr(T, S, -1));
    EnumWindows(@EnumKillWindowsProc, Integer(@sC));
    end;
  14:
    begin
      fzZ5.nStart := GetTickCount;
      sE := EvalScriptExpr(T, S, -1);
      try
        nI := StrToInt(sE) + fzZ5.nStart;
      except
        try
          case UpCase(sE[Length(sE)]) of
            'S': wr := 1000;
            'M': wr := 60000;
            'H': wr := 3600000;
          else
            wr := 1;
          end;
          if Cardinal(wr) > 1 then
            Delete(sE, Length(sE), 1);
          nI := StrToInt(sE) * wr + fzZ5.nStart;
        except
          nI := fzZ5.nStart + 10000;
        end;
      end;
      repeat
        SysUtils.Sleep(1);
        ReadProcessMemory(TScanThread(T).ProcessHandle2,
          Pointer(gClT590B60dt[TScanThread(T).ClVerIdx]), @fzZ6.nColor, 4, DWORD(fzZ6.v184));
      until (GetTickCount >= Cardinal(nI)) or (fzZ6.nColor <> 0);

    end;
  15:
    begin
    if T.AutoStart and T.Debug and T.Paused then Exit;
    sV274 := EvalScriptExpr(T, S, -1);
    if not TryStrToInt(sV274, nD) then
    begin
      if UpCase(sV274[Length(sV274)]) <> 'H' then
        sW278 := ParseWaitSuffix(sV274, nD, nM)
      else
      begin
        nD := 0;
        sW278 := sV274;
      end;
      if nD = 0 then
        sV274 := sW278;
    end;
    WaitDelay(sV274);
    end;
  16:
    begin
    T.Msg := EvalScriptExpr(T, 'msg ' + S, -1) + #0;
    Delete(T.Msg, 1, 4);
    ShowScriptMsg(T);
    end;
  98:
    begin
      TScanThread(T).Hint.Text := EvalScriptPoint(T, S, -1);
      TScanThread(T).Hint.Size := -1;
      TScanThread(T).Hint.Color := -1;
      TScanThread(T).Hint.Left := -1;
      TScanThread(T).Hint.Top := -1;
      TScanThread(T).Hint.Width := -1;
      TScanThread(T).Hint.Height := -1;
      TScanThread(T).Hint.Back := Integer($FF000018);
      TScanThread(T).Hint.Style := '';
      TScanThread(T).Hint.Font := 'Microsoft Sans Serif';
      a := Length(TScanThread(T).Hint.Text);
      if (Cardinal(a) > 0) and (TScanThread(T).Hint.Text[1] = '(') and
         (TScanThread(T).Hint.Text[a] = ')') then
      begin
        sE := Copy(TScanThread(T).Hint.Text, 2, a - 2);
        TScanThread(T).Hint.Text := EvalScriptExpr(T,
          'hint ' + FindParenGroup2(T, sE, 1, Integer(a), Integer(wr)), -1);
        sE := 'hint ' + EvalScriptExpr(T,
          'hint ' + Copy(sE, 1, a - 1), -1);
        TScanThread(T).Hint.Size := StrToIntDef(EvalScriptPoint(T, sE, 1), -1);
        TScanThread(T).Hint.Color := StrToIntDef(EvalScriptPoint(T, sE, 2), -1);
        TScanThread(T).Hint.Left := StrToIntDef(EvalScriptPoint(T, sE, 3), -1);
        TScanThread(T).Hint.Top := StrToIntDef(EvalScriptPoint(T, sE, 4), -1);
        TScanThread(T).Hint.Width := StrToIntDef(EvalScriptPoint(T, sE, 5), -1);
        TScanThread(T).Hint.Height := StrToIntDef(EvalScriptPoint(T, sE, 6), -1);
        TScanThread(T).Hint.Back := StrToIntDef(EvalScriptPoint(T, sE, 7),
          Integer($FF000018));
        sV274 := EvalScriptPoint(T, sE, 8);
        if sV274 <> '' then
        begin
          TScanThread(T).Hint.Style := LowerCase(sV274);
          sV274 := EvalScriptPoint(T, sE, -9);
          if sV274 <> '' then
            TScanThread(T).Hint.Font := AnsiDequotedStr(sV274, '"');
        end;
      end
      else
        TScanThread(T).Hint.Text := EvalScriptExpr(T, S, -1);
      TScanThread(T).Synchronize(T.SyncShowHint);

    end;
  30:
    begin
    try
      if EvalScriptExpr(T, S, 1) <> '' then
        FlashWindow(T.ClientWnd2, True)
      else
      begin
        FlashWindow(fmSecondfj.Handle, True);
        gFlashing6 := True;
      end;
    except
      gFlashing6 := False;
    end;
    end;
  31:
    begin
    sC := EvalScriptExpr(T, S, -1);
    if sC <> '' then
      sC := Chr(Byte(PlaySound(PChar(sC), 0, $20002)) + Ord('0'));
    if (sC = '') or (sC = '0') then
    begin
      wr := FindResource(HInstance, 'MSGWAV', PChar(10));
      wr := LoadResource(HInstance, wr);
      fzZ7.pRes := LockResource(wr);
      sndPlaySound(fzZ7.pRes, 6);
      UnlockResource(wr);
      FreeResource(wr);
    end;
    end;
  32:
    begin
    T.Paused := False;
    T.Flag91 := False;
    T.StopRequested := True;
    end;
  33:
    begin
    PauseCmd;
    end;
  34:
    begin
      ResumeCmd;

    end;
  35:
    begin
      StopCmd;

    end;
  36:
    begin
      StartCmd;

    end;
  97:
    begin
      LoadScriptCmd;

    end;
  128:
    begin
    if RestartCmd then
      T.RestartFlag := True;
    end;
  37:
    begin
      CallCmd;

    end;
  38:
    begin
      ProcCmd;

    end;
  39:
    begin
      EndProcCmd;

    end;
  119:
    begin
    PostMessage(fmSecondfj.Handle, WM_CLOSE, 0, 0);
    end;
  48:
    begin
    if SendMessage(T.ClientWnd2, $4721, 0, 0) <> $4321 then
    begin
      T.Paused := True;
      if T.AutoStart then
        T.Synchronize(T.PauseScriptThread);
      if gLangOffsety > 0 then
        T.Msg := LoadStr(gLangOffsety + $1C0) + #0
      else
        T.Msg := 'Injection v309.05+ не найден.'#0;
      ShowScriptMsg(T);
    end
    else
    begin
      sC := EvalScriptExpr(T, S, -1);
      SendMessage(T.ClientWnd2, $4721, 1, GlobalAddAtom(PChar(sC)));
    end;
    end;
  52:
    begin
    sC := 'sw ' + EvalScriptExpr(T, S, -1);
    a := 0;
    if not TryStrToInt(EvalScriptExpr(T, sC, 1), nD) then
      nD := 0;
    a := nD;
    if Cardinal(a) <= 0 then
      a := T.ClientWnd2;
    sC := AnsiUpperCase(EvalScriptExpr(T, sC, 2));
    if sC = 'HIDE' then
      wr := 0
    else if sC = 'MAXIMIZE' then
      wr := 3
    else if sC = 'MINIMIZE' then
      wr := 6
    else if sC = 'RESTORE' then
      wr := 9
    else if sC = 'SHOW' then
      wr := 5
    else
    begin
      if IsIconic(a) then
        ShowWindow(a, SW_RESTORE);
      BringWindowToTop(a);
      SetForegroundWindow(a);
      wr := 8;
    end;
    ShowWindow(a, wr);
    end;
  63:
    begin
      sE := EvalScriptExpr(T, S, -6);
      try
        fzZ12.v26C := StrToInt(EvalScriptExpr(T, S, 1));
      except
        fzZ12.v26C := 0;
      end;
      fzZ11.ptTo.X := StrToInt(EvalScriptExpr(T, S, 2));
      fzZ11.ptTo.Y := StrToInt(EvalScriptExpr(T, S, 3));
      fzZ11.ptFr.X := StrToInt(EvalScriptExpr(T, S, 4));
      fzZ11.ptFr.Y := StrToInt(EvalScriptExpr(T, S, 5));
      TScanThread(T).CapTo := fzZ11.ptTo;
      TScanThread(T).CapFrom := fzZ11.ptFr;
      TScanThread(T).CapWnd := fzZ12.v26C;
      TScanThread(T).Msg := sE;
      TScanThread(T).Synchronize(T.SyncCaptureScreen);

    end;
  110:
    begin
      nI := 0;
      sE := EvalScriptExpr(T, S, 1);
      nX := Pos('(', sE);
      if nX > 0 then
      begin
        Insert(' ', S, TScanThread(T).WordPos + nX - 1);
        sE := EvalScriptExpr(T, S, 1);
      end;
      TScanThread(T).ParenPos := Pos('.', sE);
      TScanThread(T).CmdArg := sE;
      if TScanThread(T).ParenPos > 0 then
      begin
        Delete(TScanThread(T).CmdArg, 1, TScanThread(T).ParenPos);
        nD := TScanThread(T).ParenPos;
        nP := T.ScriptStrToInt(TScanThread(T).CmdArg);
        TScanThread(T).CmdArg := sE;
        sE := Copy(sE, 1, nD - 1);
      end;
      sE := TScanThread(T).CmdArg;
      Delete(sE, 1, 1);
      nX := Pos('%', S) + Length(TScanThread(T).CmdArg);
      nF := Length(S);
      fzZ12.bOwn := False;
      { Множество здесь `['[', ']']`, а не `[' ']` -- та же постоянная, что и
        в двух местах выше, поэтому она с ними склеивается. Смысл сходится
        с сообщением об ошибке двумя строками ниже:
        «'[',']' must be '(',')'». }
      while (nX <= nF) and not (S[nX] in (gWordCharsadq - ['[', ']'])) do
      begin
        if S[nX] = '[' then
        begin
          fzZ12.bOwn := True;
          Break;
        end;
        Inc(nX);
      end;
      if fzZ12.bOwn then
      begin
        if gLangOffsety > 0 then
          TScanThread(T).Msg := '(' + IntToStr(TScanThread(T).CurLine) +
            '): ''['','']'' must be ''('','')'' ' + #0;
        ShowScriptMsg(TScanThread(T));
      end;
      TScanThread(T).CmdArg := EvalScriptExpr(T, 'calc ' + S, -3);
      cKz := '%';
      a := 1;
      wr := 1;
      nI := FindScriptVar(T, cKz, sE, a, wr);
      nX := 1;
      nF := Length(TScanThread(T).CmdArg);
      fzZ12.bOwn := False;
      while (nX <= nF) and
            { И тут в множестве ДВА знака -- `(` и `)`. }
            not (TScanThread(T).CmdArg[nX] in (gWordCharsadq - ['(', ')'])) do
      begin
        if TScanThread(T).CmdArg[nX] = '(' then
        begin
          fzZ12.bOwn := True;
          Break;
        end;
        Inc(nX);
      end;
      if fzZ12.bOwn then
      begin
        { Порядок доводов: первым идёт `nX`, ровно как в остальных 34 местах
          вызова -- тогда `Delete(CmdArg, nX, nF - nX + 1)` ниже получает
          осмысленные границы. }
        sV274 := FindParenGroup(T, TScanThread(T).CmdArg, 1, nX, nF);
        Delete(TScanThread(T).CmdArg, nX, nF - nX + 1);
      end
      else
        sV274 := '';
      if not TryStrToInt(EvalScriptPoint(T, sV274, 2), fzZ10.nRows) or
         (fzZ10.nRows <= 0) then
        fzZ10.nRows := 1;
      Dec(fzZ10.nRows);
      if not TryStrToInt(EvalScriptPoint(T, sV274, 1), fzZ10.nPos2) or
         (fzZ10.nPos2 <= 0) then
        fzZ10.nPos2 := 0;
      Dec(fzZ10.nPos2);
      if not TryStrToInt(EvalScriptPoint(T, sV274, 0), nLenQ) or
         (nLenQ <= 0) then
      begin
        nLenQ := 1;
        fzZ10.nPos2 := 0;
      end;
      Dec(nLenQ);
      nPrevXQ := Length(TScanThread(T).Arr48[nI].Data);
      if nPrevXQ > 0 then
        nEdi := Length(TScanThread(T).Arr48[nI].Data[0])
      else
        nEdi := 0;
      nX := fzZ10.nRows + 1;
      nK3 := nX;
      nL3 := nLenQ + 1 + $3E8;
      if nL3 < nPrevXQ then
        nL3 := nPrevXQ;
      if nEdi > nK3 then
        nK3 := nEdi;
      SetLength(TScanThread(T).Arr48[nI].Data, nL3, nK3);
      a := 0;
      TScanThread(T).CmdArg := 'calc ' + TScanThread(T).CmdArg;
      Inc(a);
      sE := EvalScriptPoint(T, TScanThread(T).CmdArg, a);
      fzZ12.bOwn := False;
      while Length(sE) <> 0 do
      begin
        if nLenQ + 1 > nL3 then
        begin
          Inc(nL3, $3E8);
          fzZ12.bOwn := True;
        end;
        if nK3 < nX then
        begin
          nK3 := nX;
          fzZ12.bOwn := True;
        end;
        if fzZ12.bOwn then
        begin
          if nL3 < nPrevXQ then
            nL3 := nPrevXQ;
          if nEdi > nK3 then
            nK3 := nEdi;
          SetLength(TScanThread(T).Arr48[nI].Data, nL3, nK3);
          fzZ12.bOwn := False;
        end;
        TScanThread(T).Arr48[nI].Data[nLenQ][nX - 1] := sE;
        if (fzZ10.nPos2 >= 0) and (fzZ10.nPos2 + fzZ10.nRows < nX) then
        begin
          nX := fzZ10.nRows + 1;
          Inc(nLenQ);
        end
        else
          Inc(nX);
        Inc(a);
        sE := EvalScriptPoint(T, TScanThread(T).CmdArg, a);
      end;
      if fzZ10.nRows + 1 = nX then
        Dec(nLenQ);
      Inc(nLenQ);
      if nLenQ < nPrevXQ then
        nLenQ := nPrevXQ;
      if nEdi > nK3 then
        nK3 := nEdi;
      SetLength(TScanThread(T).Arr48[nI].Data, nLenQ, nK3);
      sE := '';

    end;
  111:
    begin
    Delete(S, 1, T.CmdLine + 2);
    S := 'set logging' + S;
    T.LogPrefix := 'set';
    N := gCmdList2jj.IndexOf(T.LogPrefix);
    T.RepeatCmd := True;
    end;
  112:
    begin
    S := FindParenGroup(T, S, 1, nX, nF);
    S := EvalScriptExpr(T, 'calc ' + S, -1);
    T.LogPrefix := EvalScriptPoint(T, S, 0);
    N := gCmdList2jj.IndexOf(T.LogPrefix);
    T.RepeatCmd := True;
    end;
  113:
    begin
      {$I-}
      S := 'calc ' + FindParenGroup(T, S, 1, nX, nF);
      sV274 := EvalScriptExpr(T, S, 1);
      sW278 := EvalScriptExpr(T, S, -2);
      if (Pos('\', sV274) = 0) and (Pos('/', sV274) = 0) and
         (Pos(':', sV274) = 0) then
        sV274 := gTempFilefv + 'Scripts' + '\' + sV274;
      AssignFile(fArr, sV274);
      if FileExists(sV274) then
        Append(fArr)
      else
        Rewrite(fArr);
      nX := Pos('\r', sW278);
      while nX > 0 do
      begin
        sW278[nX] := #13;
        Delete(sW278, nX + 1, 1);
        nX := Pos('\r', sW278);
      end;
      nX := Pos('\n', sW278);
      while nX > 0 do
      begin
        sW278[nX] := #10;
        Delete(sW278, nX + 1, 1);
        nX := Pos('\n', sW278);
      end;
      Write(fArr, sW278);
      CloseFile(fArr);

    end;
  121:
    begin
    T.Msg := EvalScriptExpr(T, S, -1);
    TScanThread(T).Synchronize(T.SyncLoadPlugin);
    end;
  122:
    begin
      TScanThread(T).Msg := EvalScriptExpr(T, S, -1);
      TScanThread(T).Synchronize(T.SyncReloadPlugin);

    end;
  123:
    begin
      TScanThread(T).Msg := EvalScriptExpr(T, S, -1);
      TScanThread(T).Synchronize(T.SyncUnloadPlugin);

    end;
  125:
    begin
    S := 'pause_script';
    PauseCmd;
    end;
  130:
    begin
    sE := AnsiLowerCase(EvalScriptExpr(T, S, 1));
    if Length(sE) > 0 then
      case sE[1] of
        'e': TScanThread(T).Synchronize(TScanThread(T).SyncKeyboardOn);
        'd': TScanThread(T).Synchronize(TScanThread(T).SyncKeyboardOff);
      end;
    end;
  131:
    begin
    sE := AnsiLowerCase(EvalScriptExpr(T, S, 1));
    if Length(sE) > 0 then
      case sE[1] of
        'e': TScanThread(T).Synchronize(TScanThread(T).SyncMouseOn);
        'd': TScanThread(T).Synchronize(TScanThread(T).SyncMouseOff);
        'h': begin
               { прямоугольник держим В КАДРЕ четырьмя Integer: `R: TRect` уехал бы
                 в модульные переменные }
               fzZ14.rcLeft := GetSystemMetrics(SM_CXSCREEN);
               fzZ14.rcRight := fzZ14.rcLeft;
               fzZ14.rcTop := 0;
               fzZ14.rcBottom := fzZ14.rcTop;
               ClipCursor(PRect(@fzZ14.rcLeft));
             end;
        's': ClipCursor(nil);
      end;
    end;
  43, 116, 120, 124: ;    { тела нет: запись ведёт прямо в хвост }
  else
    if Copy(T.LogPrefix, 1, 1) <> ':' then
      if fmSecondfj.miStopSUncC.Checked then
      begin
        T.Paused := True;
        T.Synchronize(T.PauseScriptThread);
        if gLangOffsety > 0 then
          T.Msg := LoadStr(gLangOffsety + $1DE) + T.LogPrefix + #0
        else
          T.Msg := 'Неопознанная команда: ' + T.LogPrefix + #0;
        ShowScriptMsg(T);
      end;
  end;
end;

{$I+}
function ApplyWorkWindow(T: TScanThread; H, Idx: Integer): Integer;
var
  Pid: DWORD;
begin
  Result := gScriptso3[Idx].ClientWnd;
  gScriptso3[Idx].ClientWnd := H;
  gScriptso3[Idx].ClientWnd2 := H;
  gScriptso3[Idx].ThreadId := GetWindowThreadProcessId(H, @Pid);
  gScriptso3[Idx].ProcessId := Pid;
  if gScriptso3[Idx].ProcessHandle <> 0 then
    CloseHandle(gScriptso3[Idx].ProcessHandle);
  gScriptso3[Idx].ProcessHandle := OpenProcess($638, False, Pid);
  gScriptso3[Idx].ProcessHandle2 := gScriptso3[Idx].ProcessHandle;
end;

function TryCaptureImage(T: TScanThread; H: HWND): Boolean;
var
  R: TRect;
  Pad: Integer;
  X: Integer;
  Y: Integer;
  W: Integer;
  C: Integer;
  N: Integer;
  P: PByteArray;
begin
  { Point ОБЯЗАТЕЛЬНО квалифицированный: неквалифицированный разрешается
    в Classes.Point -- это переходник, а нужен Types.Point. }
  { Снимает окно H в буфер скрипта и отвечает, есть ли в снимке хоть один
    ненулевой пиксель. Строки 24-битные и идут снизу вверх, поэтому индекс
    строки считается как ShotH - 1 - Y, а шаг строки -- ShotW * 3 + добивка. }
  if not GetWindowRect(H, R) then
  begin
    R.Right := 500;
    R.Left := 0;
    R.Bottom := 500;
    R.Top := 0;
  end;
  W := R.Right - R.Left;
  T.CapW := W;
  if W > 500 then
    T.CapW := 500;
  W := R.Bottom - R.Top;
  T.CapH := W;
  if W > 500 then
    T.CapH := 500;
  T.CapFrom := Types.Point(0, 0);
  T.CapTo := Types.Point(T.CapW, T.CapH);
  if (T.CapTo.X = 0) and (T.CapTo.Y = 0) then
    T.CapTo := Types.Point(500, 500);
  T.ShotFailed := False;
  T.Lock.Flag := False;
  T.CapWnd := H;
  TScanThread(T).CaptureWindowBits;
  Result := False;
  if not T.ShotFailed then
  begin
    Pad := T.CapTo.X mod 4;
    Y := T.CapTo.Y - 1;
    while (Y >= 0) and not Result do
    begin
      X := 0;
      while (X < T.CapTo.X) and not Result do
      begin
        { смещение внутри строки считается ОТДЕЛЬНЫМ оператором: одним
          выражением компилятор берётся сперва за произведение (оно
          тяжелее), и порядок слагаемых разъезжается }
        N := X * 3;
        N := N + ((T.ShotH - 1 - Y) * (T.ShotW * 3 + Pad) +
          Integer(T.ShotBits));
        P := PByteArray(N);
        C := P[2] + P[1] shl 8 + P[0] shl 16;
        Result := C <> 0;
        Inc(X);
      end;
      Dec(Y);
    end;
  end;
  GlobalFree(Cardinal(T.ShotBits));
  T.ShotBits := nil;
end;

procedure SetArrSize(T: TScanThread; S: string; var A, B: Integer;
  C: Integer);
begin
  A := C;
  B := C;
end;

function FindParenGroupF(T: TScanThread; const S: string; N: Integer;
  var A, B: Integer): string;
begin
  Result := S;
end;


procedure EvalScriptExprV(T: TScanThread; const S: string; N: Integer;
                          var Res: string);
begin Res := S; end;
function EvalScriptExprF(T: TScanThread; const S: string; N: Integer): string;
begin Result := S; end;
function EvalScriptPointF(T: TScanThread; const S: string; N: Integer): string;
begin Result := S; end;
procedure WaitDelay(const S: string);
begin end;
procedure MouseClickStub(AWnd: HWND; ABtn: Byte; const S: string;
                         var P: TPoint; N: Integer; const S2: string);
begin
end;



end.
