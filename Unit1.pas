unit Unit1;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

// Главная форма UoPilot: настройки, горячие клавиши, скрипты и
// работа с окном клиента Ultima Online.

interface

uses
{$IFnDEF FPC}
  jpeg, TlHelp32, SHDocVw,
{$ELSE}
{$ENDIF}
  Gauges,
  Types, HotKeyMgr, Keydefs, Recorder, Spin, Grids, mySys,
  MyIniFiles, geScale, SynMemo, SynHighlighterPas, SynEdit,
  SynEditCodeFolding, SynEditHighlighter, SynEditTypes, awMachMask,
  uScanThread, PerlRegEx, PngGDIP, GDIPAPI, GDIPOBJ, Unit2,
  LangClipboard, ActiveX, Buttons, Classes, Clipbrd, ComCtrls,
  Controls, Dialogs, ExtCtrls, Forms, Graphics, IniFiles, Menus, Messages,
  Registry, ShellAPI, StdCtrls, StrUtils, SyncObjs, SysUtils, WinInet,
  Windows{$IFDEF FPC}, LCLType{$ENDIF};

type

  THouseCmdsZ = array[1..16] of string;

  TLogWinRecZ = packed record               // сохранённая геометрия окна лога
  Shown:   Boolean;
  Left:    Integer;
  Top:     Integer;
  Width:   Integer;
  Height:  Integer;
  end;

  { TfmSecond }

  TfmSecond = class(TForm)
    miAbs: TMenuItem;
    miArccos: TMenuItem;
    miArcsin: TMenuItem;
    miArctan: TMenuItem;
    miAssert: TMenuItem;
    miBasic: TMenuItem;
    miCeil: TMenuItem;
    miChr: TMenuItem;
    miCollectgarbage: TMenuItem;
    miCoroutine: TMenuItem;
    miCoroutineCreate: TMenuItem;
    miCoroutineResume: TMenuItem;
    miCoroutineRunning: TMenuItem;
    miCoroutineStatus: TMenuItem;
    miCoroutineWrap: TMenuItem;
    miCoroutineYield: TMenuItem;
    miCos: TMenuItem;
    miDebugDebug: TMenuItem;
    miDebugGetfenv: TMenuItem;
    miDebugGethook: TMenuItem;
    miDebugGetinfo: TMenuItem;
    miDebugGetlocal: TMenuItem;
    miDebugGetmetatable: TMenuItem;
    miDebugGetregistry: TMenuItem;
    miDebugGetupvalue: TMenuItem;
    miDebugSetfenv: TMenuItem;
    miDebugSethook: TMenuItem;
    miDebugSetlocal: TMenuItem;
    miDebugSetmetatable: TMenuItem;
    miDebugSetupvalue: TMenuItem;
    miDebugTraceback: TMenuItem;
    miDegtorad: TMenuItem;
    miDofile: TMenuItem;
    miError: TMenuItem;
    miExp: TMenuItem;
    miFileClose: TMenuItem;
    miFileFlush: TMenuItem;
    miFileLines: TMenuItem;
    miFileRead: TMenuItem;
    miFileSeek: TMenuItem;
    miFileSetvbuf: TMenuItem;
    miFileWrite: TMenuItem;
    miFloor: TMenuItem;
    miFrac: TMenuItem;
    miGetfenv: TMenuItem;
    miInputandOutput: TMenuItem;
    miIoClose: TMenuItem;
    miIoFlush: TMenuItem;
    miIoInput: TMenuItem;
    miIoLines: TMenuItem;
    miIoOpen: TMenuItem;
    miIoOutput: TMenuItem;
    miIoPopen: TMenuItem;
    miIoRead: TMenuItem;
    miIoTmpfile: TMenuItem;
    miIoType: TMenuItem;
    miIoWrite: TMenuItem;
    miIpairs: TMenuItem;
    miIsreal: TMenuItem;
    miIsstring: TMenuItem;
    miLengthdirx: TMenuItem;
    miLengthdiry: TMenuItem;
    miLn: TMenuItem;
    miLoad: TMenuItem;
    miLoadfile: TMenuItem;
    miLoadstring: TMenuItem;
    miLog: TMenuItem;
    miMathAbs: TMenuItem;
    miMathAcos: TMenuItem;
    miMathAsin: TMenuItem;
    miMathAtan: TMenuItem;
    miMathAtan2: TMenuItem;
    miMathCeil: TMenuItem;
    miMathCos: TMenuItem;
    miMathCosh: TMenuItem;
    miMathDeg: TMenuItem;
    miMathematicalFunctions: TMenuItem;
    miMathExp: TMenuItem;
    miMathFloor: TMenuItem;
    miMathFmod: TMenuItem;
    miMathFrexp: TMenuItem;
    miMathHuge: TMenuItem;
    miMathLdexp: TMenuItem;
    miMathLog: TMenuItem;
    miMathLog10: TMenuItem;
    miMathMax: TMenuItem;
    miMathMin: TMenuItem;
    miMathModf: TMenuItem;
    miMathPi: TMenuItem;
    miMathPow: TMenuItem;
    miMathRad: TMenuItem;
    miMathRandom: TMenuItem;
    miMathRandomseed: TMenuItem;
    miMathSin: TMenuItem;
    miMathSinh: TMenuItem;
    miMathSqrt: TMenuItem;
    miMathTan: TMenuItem;
    miMathTanh: TMenuItem;
    miMaxx: TMenuItem;
    miMean: TMenuItem;
    miMinx: TMenuItem;
    miModule: TMenuItem;
    miModules: TMenuItem;
    miMouseposabsx: TMenuItem;
    miMouseposabsx1: TMenuItem;
    miMouseposabs_y: TMenuItem;
    miMouseposabs_y1: TMenuItem;
    miMouseposx: TMenuItem;
    miMouseposx1: TMenuItem;
    miMouseposy: TMenuItem;
    miMouseposy1: TMenuItem;
    miNext: TMenuItem;
    miOperatingSystem: TMenuItem;
    miOrd: TMenuItem;
    miOsClock: TMenuItem;
    miOsDate: TMenuItem;
    miOsDifftime: TMenuItem;
    miOsExecute: TMenuItem;
    miOsExit: TMenuItem;
    miOsGetenv: TMenuItem;
    miOsRemove: TMenuItem;
    miOsRename: TMenuItem;
    miOsSetlocale: TMenuItem;
    miOsTime: TMenuItem;
    miOsTmpname: TMenuItem;
    miPackageCpath: TMenuItem;
    miPackageLoaded: TMenuItem;
    miPackageLoaders: TMenuItem;
    miPackageLoadlib: TMenuItem;
    miPackagePath: TMenuItem;
    miPackagePreload: TMenuItem;
    miPackageSeeall: TMenuItem;
    miPairs: TMenuItem;
    miPcall: TMenuItem;
    miPi: TMenuItem;
    miPointdirection: TMenuItem;
    miPointdistance: TMenuItem;
    miPower: TMenuItem;
    miPrint: TMenuItem;
    miRadtodeg: TMenuItem;
    miRawequal: TMenuItem;
    miRawget: TMenuItem;
    miRawset: TMenuItem;
    miRequire: TMenuItem;
    miRound: TMenuItem;
    miSelect: TMenuItem;
    miSetfenv: TMenuItem;
    miSetmetatable: TMenuItem;
    miSin: TMenuItem;
    miSqrt: TMenuItem;
    miStringByte: TMenuItem;
    miStringChar: TMenuItem;
    miStringcount: TMenuItem;
    miStringdigits: TMenuItem;
    miStringDump: TMenuItem;
    miStringFind: TMenuItem;
    miStringFormat: TMenuItem;
    miStringGmatch: TMenuItem;
    miStringGsub: TMenuItem;
    miStringLen: TMenuItem;
    miStringletters: TMenuItem;
    miStringlower: TMenuItem;
    miStringLowerLua: TMenuItem;
    miStringManipulation: TMenuItem;
    miStringMatch: TMenuItem;
    miStringRep: TMenuItem;
    miStringreplace: TMenuItem;
    miStringReverse: TMenuItem;
    miStringSub: TMenuItem;
    miStringupper: TMenuItem;
    miStringUpperLua: TMenuItem;
    miTableConcat: TMenuItem;
    miTableInsert: TMenuItem;
    miTableManipulation: TMenuItem;
    miTableMaxn: TMenuItem;
    miTableRemove: TMenuItem;
    miTableSort: TMenuItem;
    miTan: TMenuItem;
    miTheDebugLibrary: TMenuItem;
    miTonumber: TMenuItem;
    miTostring: TMenuItem;
    miTrunc: TMenuItem;
    miType: TMenuItem;
    miUnpack: TMenuItem;
    miXpcall: TMenuItem;
    pcAll: TPageControl;
    tsGeneral: TTabSheet;
    tsScript: TTabSheet;
    gbC: TGroupBox;
    ed0: TEdit;
    ed1: TEdit;
    ed2: TEdit;
    ed3: TEdit;
    cb1: TComboBox;
    cb2: TComboBox;
    cb3: TComboBox;
    btS1: TSpeedButton;
    btS2: TSpeedButton;
    btS3: TSpeedButton;
    btS0: TSpeedButton;
    odLoad: TOpenDialog;
    tm0: TTimer;
    tm2: TTimer;
    tm3: TTimer;
    tm1: TTimer;
    sdSave: TSaveDialog;
    gbOtherWindow: TGroupBox;
    btS4: TSpeedButton;
    btS5: TSpeedButton;
    ed4: TEdit;
    ed5: TEdit;
    cb4: TComboBox;
    cb5: TComboBox;
    tm4: TTimer;
    tm5: TTimer;
    gbScreenShot: TGroupBox;
    cbDate: TCheckBox;
    rbBmp: TRadioButton;
    rbJpg: TRadioButton;
    edScr: TEdit;
    cb0: TComboBox;
    SpinEdit1: TSpinEdit;
    tsOther: TTabSheet;
    TBudilnik: TTimer;
    tsOptions: TTabSheet;
    gbShipControl: TGroupBox;
    sForward: TButton;
    sBack: TButton;
    sStop: TButton;
    sTurnLeft: TButton;
    sTurnRight: TButton;
    sLeft: TButton;
    sRight: TButton;
    sRaiseAnchor: TButton;
    sDropAnchor: TButton;
    sUnfurlSail: TButton;
    sFL: TButton;
    sBL: TButton;
    sFR: TButton;
    sBR: TButton;
    sTurnA: TButton;
    rbNormal: TRadioButton;
    rbSlow: TRadioButton;
    rbOne: TRadioButton;
    sbMfHS: TSpeedButton;
    GroupBox3: TGroupBox;
    Lbudilnik: TLabel;
    SBBudilnik: TSpeedButton;
    SEMinutes: TSpinEdit;
    SEHour: TSpinEdit;
    cbScript: TCheckBox;
    gScript: TGauge;
    Timer1: TTimer;
    tsStart: TTabSheet;
    cbEnableHK: TCheckBox;
    sbMacros: TSpeedButton;
    sbSControl: TSpeedButton;
    PanelTs: TPanel;
    tScript: TTabControl;
    tScriptDesc: TTabControl;
    btStart: TSpeedButton;
    bAdd: TSpeedButton;
    bRemove: TSpeedButton;
    edPause: TEdit;
    lHint: TLabel;
    sbHouseControl: TSpeedButton;
    gbHouseControl: TGroupBox;
    Button1: TSpeedButton;
    Button4: TSpeedButton;
    Button6: TSpeedButton;
    Button7: TSpeedButton;
    Button5: TSpeedButton;
    Button2: TSpeedButton;
    Button3: TSpeedButton;
    sbMfHH: TSpeedButton;
    gbMove: TGroupBox;
    sbAMove_1: TSpeedButton;
    Label16: TLabel;
    Label18: TLabel;
    Edit1: TEdit;
    sbAMove_2: TSpeedButton;
    sbAMove_3: TSpeedButton;
    cbMoveLeftCl: TCheckBox;
    seAmove1: TSpinEdit;
    seAmove2: TSpinEdit;
    seAmove3: TSpinEdit;
    cbS1: TCheckBox;
    cbS2: TCheckBox;
    cbS3: TCheckBox;
    cbS4: TCheckBox;
    cbS5: TCheckBox;
    tShowCoordsOnCap: TTimer;
    sbPause: TSpeedButton;
    cbDebug: TCheckBox;
    Label14: TLabel;
    gbHotKeyList: TGroupBox;
    cbhkSScript: TCheckBox;
    cbhkRec: TCheckBox;
    cbhkRecStop: TCheckBox;
    cbhkPlay: TCheckBox;
    cbhkSNames: TCheckBox;
    cbhkMove_1: TCheckBox;
    cbhk1: TCheckBox;
    cbhk2: TCheckBox;
    cbhk3: TCheckBox;
    cbhk4: TCheckBox;
    cbhk5: TCheckBox;
    cbhkMes: TCheckBox;
    cbhkUopUO: TCheckBox;
    cbhkScr: TCheckBox;
    cbhkMove_2: TCheckBox;
    cbhkMove_3: TCheckBox;
    cbhkPScript: TCheckBox;
    sbEditHK: TSpeedButton;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    sbHideOnMax: TSpeedButton;
    Panel4: TPanel;
    Bevel3: TPanel;
    Bevel4: TBevel;
    lhkScr: TSpeedButton;
    lhkSScript: TSpeedButton;
    lhkPScript: TSpeedButton;
    lhkRec: TSpeedButton;
    lhkRecStop: TSpeedButton;
    lhkPlay: TSpeedButton;
    lhkSNames: TSpeedButton;
    lhkMes: TSpeedButton;
    lhkUopUO: TSpeedButton;
    lhkMove_3: TSpeedButton;
    lhkMove_2: TSpeedButton;
    lhk3: TSpeedButton;
    lhk2: TSpeedButton;
    lhk1: TSpeedButton;
    lhk4: TSpeedButton;
    lhk5: TSpeedButton;
    lhkMove_1: TSpeedButton;
    cbhkSetMove_3: TCheckBox;
    cbhkSetMove_2: TCheckBox;
    cbhkSetMove_1: TCheckBox;
    lhkSetMove_1: TSpeedButton;
    lhkSetMove_2: TSpeedButton;
    lhkSetMove_3: TSpeedButton;
    gbGM: TGroupBox;
    sbGMPage: TSpeedButton;
    cbGMPage: TCheckBox;
    cbStoD1: TCheckBox;
    cbStoD2: TCheckBox;
    cbStoD3: TCheckBox;
    tHintTimer: TTimer;
    sbCharParams: TSpeedButton;
    pmCopyLM: TPopupMenu;
    miCopyLM: TMenuItem;
    cbClVer: TComboBox;
    Label1: TLabel;
    cbhkCharParams: TCheckBox;
    lhkCharParams: TSpeedButton;
    mnHotKey: TMainMenu;
    ddd1: TMenuItem;
    miNew: TMenuItem;
    N15: TMenuItem;
    miOpen: TMenuItem;
    miReOpen: TMenuItem;
    miProcOpen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    N6: TMenuItem;
    miExit: TMenuItem;
    miExitWoSave: TMenuItem;
    nxxx: TMenuItem;
    miLMkeymouse: TMenuItem;
    miSMkeymouse: TMenuItem;
    N13: TMenuItem;
    miRec: TMenuItem;
    miStopRec: TMenuItem;
    miPlay: TMenuItem;
    miCtrlB: TMenuItem;
    miCtrlA: TMenuItem;
    N8: TMenuItem;
    N12: TMenuItem;
    miSaveOptions: TMenuItem;
    miSaveMacros: TMenuItem;
    r1: TMenuItem;
    mmHelp: TMenuItem;
    miAbout: TMenuItem;
    mnCom: TPopupMenu;
    miCut: TMenuItem;
    miCopy: TMenuItem;
    miPaste: TMenuItem;
    miUndo: TMenuItem;
    N9: TMenuItem;
    mi1: TMenuItem;
    mi11: TMenuItem;
    mi12: TMenuItem;
    mi13: TMenuItem;
    mi14: TMenuItem;
    mi2: TMenuItem;
    mi21: TMenuItem;
    mi22: TMenuItem;
    mi23: TMenuItem;
    mi24: TMenuItem;
    MenuItem1: TMenuItem;
    mi26: TMenuItem;
    mi27: TMenuItem;
    mi28: TMenuItem;
    mi29: TMenuItem;
    mi210: TMenuItem;
    mi211: TMenuItem;
    mi212: TMenuItem;
    mi213: TMenuItem;
    mi214: TMenuItem;
    mi215: TMenuItem;
    mi3: TMenuItem;
    mi31: TMenuItem;
    mi32: TMenuItem;
    mi33: TMenuItem;
    mi34: TMenuItem;
    mi35: TMenuItem;
    mi36: TMenuItem;
    mi37: TMenuItem;
    mi38: TMenuItem;
    mi39: TMenuItem;
    mi310: TMenuItem;
    mi311: TMenuItem;
    mi4: TMenuItem;
    miM: TMenuItem;
    miMex: TMenuItem;
    miSet: TMenuItem;
    miW: TMenuItem;
    miWaitfortarget: TMenuItem;
    miMouses: TMenuItem;
    miDL: TMenuItem;
    miDR: TMenuItem;
    miLeft: TMenuItem;
    miRight: TMenuItem;
    miLeftdown: TMenuItem;
    miLeftup: TMenuItem;
    miRightdown: TMenuItem;
    miRightup: TMenuItem;
    miMove: TMenuItem;
    miDrag: TMenuItem;
    miRepits: TMenuItem;
    miBreak: TMenuItem;
    miContinue: TMenuItem;
    miRt: TMenuItem;
    mieRt: TMenuItem;
    miFor: TMenuItem;
    mieFor: TMenuItem;
    miWhile: TMenuItem;
    miWhileP: TMenuItem;
    miWhileL: TMenuItem;
    miWhileN: TMenuItem;
    mieWhile: TMenuItem;
    miIfs: TMenuItem;
    miIF: TMenuItem;
    miiIFp: TMenuItem;
    miIfLastmsg: TMenuItem;
    miIFNot: TMenuItem;
    miElse: TMenuItem;
    mieIF: TMenuItem;
    miProcs: TMenuItem;
    miye: TMenuItem;
    mimo: TMenuItem;
    mida: TMenuItem;
    mikl: TMenuItem;
    mikr: TMenuItem;
    midkl: TMenuItem;
    midkr: TMenuItem;
    mikld: TMenuItem;
    miklu: TMenuItem;
    mikrd: TMenuItem;
    mikru: TMenuItem;
    miCall: TMenuItem;
    miProc: TMenuItem;
    miEndProc: TMenuItem;
    miGosub: TMenuItem;
    miReturn: TMenuItem;
    miMLoad: TMenuItem;
    miMacroload: TMenuItem;
    miMacroplay: TMenuItem;
    miScripts: TMenuItem;
    miStartScript: TMenuItem;
    miStopScript: TMenuItem;
    miPrograms: TMenuItem;
    miExec: TMenuItem;
    miTerminate: TMenuItem;
    miGoto: TMenuItem;
    miSay: TMenuItem;
    miMsg: TMenuItem;
    miAlarm: TMenuItem;
    miStop: TMenuItem;
    miVariables: TMenuItem;
    pmSaveLoadLO: TPopupMenu;
    miLoadLO: TMenuItem;
    miSaveLO: TMenuItem;
    miClesrLO: TMenuItem;
    miPauseScript: TMenuItem;
    miResumeScript: TMenuItem;
    miScriptFontSelect: TMenuItem;
    fdEditor: TFontDialog;
    pCPLastObjects: TPanel;
    sgLastObject: TStringGrid;
    sbLOAdd: TSpeedButton;
    sbLODel: TSpeedButton;
    Label25: TLabel;
    sbLTDel: TSpeedButton;
    sbLTAdd: TSpeedButton;
    Label24: TLabel;
    sgLastTarget: TStringGrid;
    pCPVar: TPanel;
    sgVar: TStringGrid;
    pCPDTimer: TPanel;
    cbDrinkTimer: TCheckBox;
    SpinEdit2: TSpinEdit;
    sbCPhide: TSpeedButton;
    gbStartLoginUO: TGroupBox;
    sbStartUO: TSpeedButton;
    sbLoginUO: TSpeedButton;
    eSUO: TEdit;
    cbSUOMin: TCheckBox;
    sbCFCP1: TSpeedButton;
    sbCFCP2: TSpeedButton;
    sbCFCP3: TSpeedButton;
    sbCFCP4: TSpeedButton;
    sbCFCP5: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    sbCFCP7: TSpeedButton;
    seTabSize: TSpinEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    eScriptDelayDef: TEdit;
    miRandom: TMenuItem;
    tTabRefresh: TTimer;
    gbAnimalControl: TGroupBox;
    sbCome: TSpeedButton;
    sbGo: TSpeedButton;
    sbStay: TSpeedButton;
    sbStop: TSpeedButton;
    sbFollow: TSpeedButton;
    sbGuard: TSpeedButton;
    sbAttack: TSpeedButton;
    sbKill: TSpeedButton;
    sbTransfer: TSpeedButton;
    sbRelease: TSpeedButton;
    cbPref: TCheckBox;
    cbSuff: TCheckBox;
    ePref: TEdit;
    eSuff: TEdit;
    sbAnimalControl: TSpeedButton;
    sbBuy: TSpeedButton;
    sbSell: TSpeedButton;
    sbStock: TSpeedButton;
    sbPrice: TSpeedButton;
    sbStatus: TSpeedButton;
    sbDrop: TSpeedButton;
    sbGive: TSpeedButton;
    Bevel9: TBevel;
    sbHire: TSpeedButton;
    sbBye: TSpeedButton;
    miFlash: TMenuItem;
    sbCalibrate: TSpeedButton;
    cbGMPageAlarm: TCheckBox;
    Bevel7: TBevel;
    Label11: TLabel;
    edPauseNil: TEdit;
    Label12: TLabel;
    lhkLockAllScriptToUO: TSpeedButton;
    cbhkLockAllScriptToUO: TCheckBox;
    miInjection: TMenuItem;
    cbhkClipboardConsoleText: TCheckBox;
    lhkClipboardConsoleText: TSpeedButton;
    miLang: TMenuItem;
    miLangDefault: TMenuItem;
    miLangRus: TMenuItem;
    miLangEng: TMenuItem;
    miLangPor: TMenuItem;
    miScriptHelp: TMenuItem;
    tbUOPriority: TTrackBar;
    Edit2: TEdit;
    StartUOOnly: TCheckBox;
    miArrays: TMenuItem;
    miLoadarray: TMenuItem;
    miGetcolor: TMenuItem;
    rbFull: TRadioButton;
    pCharParams: TPanel;
    lName: TLabel;
    mLM: TMemo;
    pSkills: TPanel;
    sgSkills: TStringGrid;
    pCP: TPanel;
    pOptions: TPanel;
    mParamName: TMemo;
    mParamName2: TMemo;
    mParamValue: TMemo;
    mParamValue2: TStringGrid;
    pCPchekbokses: TPanel;
    cbHits: TCheckBox;
    cbMana: TCheckBox;
    cbStam: TCheckBox;
    cbWght: TCheckBox;
    cbAr: TCheckBox;
    cbShowCoords: TCheckBox;
    cbGold: TCheckBox;
    sbShowSkills: TSpeedButton;
    pmTray: TPopupMenu;
    miTrayRestore: TMenuItem;
    N30: TMenuItem;
    miTrayClose: TMenuItem;
    Panel11: TPanel;
    Panel12: TPanel;
    pCoordsAndPoints: TPanel;
    Label4: TLabel;
    cbInsertXY: TCheckBox;
    btXY: TSpeedButton;
    btXYabs: TSpeedButton;
    cbInsertXYabs: TCheckBox;
    cbM: TComboBox;
    btColor: TSpeedButton;
    sbDefineColor: TSpeedButton;
    CBInsertColor: TCheckBox;
    cbhkTransp: TCheckBox;
    lhkTransp: TSpeedButton;
    cbhkPathF: TCheckBox;
    lhkPathF: TSpeedButton;
    cbhkCrimAct: TCheckBox;
    lhkCrimAct: TSpeedButton;
    cbhkARun: TCheckBox;
    lhkARun: TSpeedButton;
    ec0: TEdit;
    ec1: TEdit;
    ec2: TEdit;
    ec3: TEdit;
    ec4: TEdit;
    ec5: TEdit;
    N29: TMenuItem;
    miPauseCurrentScript: TMenuItem;
    miPauseAllScript: TMenuItem;
    btAddM: TSpeedButton;
    Panel14: TPanel;
    cbWinList: TComboBox;
    Label15: TLabel;
    Label13: TLabel;
    seSendExDelayDef: TSpinEdit;
    miFunctions: TMenuItem;
    miGetmousepos: TMenuItem;
    miGetnumber: TMenuItem;
    miGetword: TMenuItem;
    miSavearray: TMenuItem;
    eBudilnikDelay: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    seMouseClicksDelay: TSpinEdit;
    Label17: TLabel;
    tbScriptPriority: TTrackBar;
    miPrompt: TMenuItem;
    miPriority: TMenuItem;
    Windows1: TMenuItem;
    miWindowpos: TMenuItem;
    miFindwindow: TMenuItem;
    miWorkwindow: TMenuItem;
    miGetwindow: TMenuItem;
    miGetwindowtext: TMenuItem;
    miShowwindow: TMenuItem;
    Memory1: TMenuItem;
    miReadmem: TMenuItem;
    miWritemem: TMenuItem;
    miPrintscreen: TMenuItem;
    war1: TMenuItem;
    hidden1: TMenuItem;
    arun1: TMenuItem;
    skillsnumber1: TMenuItem;
    spellnamenember1: TMenuItem;
    delimiter1: TMenuItem;
    EasyUOnvar1: TMenuItem;
    HorSize: TPanel;
    VertSize: TPanel;
    miSetwindowtext: TMenuItem;
    Panel15: TPanel;
    fhFindDialog: TFindDialog;
    fhReplaceDialog: TReplaceDialog;
    cbNtUserPM: TComboBox;
    linedelay1: TMenuItem;
    fontcolor1: TMenuItem;
    miSize: TMenuItem;
    miFindcolor: TMenuItem;
    miLangBy: TMenuItem;
    miLangGer: TMenuItem;
    pPos: TPanel;
    miLangUkr: TMenuItem;
    miClipboard: TMenuItem;
    miSetClipboard: TMenuItem;
    miGetClipboard: TMenuItem;
    miSetlogging: TMenuItem;
    miMiddle: TMenuItem;
    miDoublemiddle: TMenuItem;
    miMiddledown: TMenuItem;
    miMiddleup: TMenuItem;
    miPmiddle: TMenuItem;
    miDoublepmiddle: TMenuItem;
    miPmiddledown: TMenuItem;
    miPmiddleup: TMenuItem;
    miKmiddle: TMenuItem;
    miDoublekmiddle: TMenuItem;
    miKmiddledown: TMenuItem;
    miKmiddleup: TMenuItem;
    k1: TMenuItem;
    p1: TMenuItem;
    simple1: TMenuItem;
    miPleft: TMenuItem;
    miPright: TMenuItem;
    miDoublepleft: TMenuItem;
    miDoublepright: TMenuItem;
    miPleftdown: TMenuItem;
    miPleftup: TMenuItem;
    miPrightdown: TMenuItem;
    miPrightup: TMenuItem;
    miWindowFromCursor: TMenuItem;
    Image1: TImage;
    miGetselectedtext: TMenuItem;
    miSetselectedtext: TMenuItem;
    wheel1: TMenuItem;
    setacurrentscript1: TMenuItem;
    setaactivescript1: TMenuItem;
    wheeldownxyabsrlmcount1: TMenuItem;
    wheelup1: TMenuItem;
    pwheeldown1: TMenuItem;
    pwheelup1: TMenuItem;
    kwheeldownxyabscount1: TMenuItem;
    kwheelup1: TMenuItem;
    miDec2hex: TMenuItem;
    miHex2dec: TMenuItem;
    miFindImage: TMenuItem;
    miKeys: TMenuItem;
    miSenddown: TMenuItem;
    miSendup: TMenuItem;
    Panel16: TPanel;
    sghkScriptHKList: TStringGrid;
    Panel10: TPanel;
    Panel5: TPanel;
    Panel9: TPanel;
    Panel8: TPanel;
    Panel7: TPanel;
    Panel6: TPanel;
    cbhkSetWorkWindow: TCheckBox;
    cbhkStopAllScript: TCheckBox;
    lhkStopAllScript: TSpeedButton;
    lhkSetWorkWindow: TSpeedButton;
    cbhkPauseAllScript: TCheckBox;
    lhkPauseAllScript: TSpeedButton;
    lhkEnableKeyboard: TSpeedButton;
    cbhkEnableKeyboard: TCheckBox;
    miPlugins: TMenuItem;
    miPluginSample: TMenuItem;
    micoco: TMenuItem;
    midefColor: TMenuItem;
    midefX: TMenuItem;
    midefY: TMenuItem;
    midefXabs: TMenuItem;
    midefYabs: TMenuItem;
    mihint: TMenuItem;
    miLoadscript: TMenuItem;
    miGetwindowpos: TMenuItem;
    miLogFontSelect: TMenuItem;
    miPsysresist: TMenuItem;
    miFireresist: TMenuItem;
    miColdresist: TMenuItem;
    miPoisresist: TMenuItem;
    miEnerresist: TMenuItem;
    miLuck: TMenuItem;
    miDamage: TMenuItem;
    miHitsmax: TMenuItem;
    miManamax: TMenuItem;
    miStammax: TMenuItem;
    miWghtmax: TMenuItem;
    miDamagemax: TMenuItem;
    miFollowers: TMenuItem;
    miFollowersmax: TMenuItem;
    miPost: TMenuItem;
    miPostup: TMenuItem;
    miPostdown: TMenuItem;
    miSendexup: TMenuItem;
    miSendexdown: TMenuItem;
    miGetlayout: TMenuItem;
    miSetlayout: TMenuItem;
    miGetScripts: TMenuItem;
    mihintF: TMenuItem;
    sbCFCP8: TSpeedButton;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    Panel23: TPanel;
    Panel24: TPanel;
    Panel25: TPanel;
    sbCancel: TSpeedButton;
    sbApply: TSpeedButton;
    cbHKList: TComboBox;
    cbShift: TCheckBox;
    cbAlt: TCheckBox;
    cbCtrl: TCheckBox;
    pRestWait: TPanel;
    lRestWait: TLabel;
    miStrings: TMenuItem;
    miPosEx: TMenuItem;
    miCopyString: TMenuItem;
    miDeleteString: TMenuItem;
    miInsertString: TMenuItem;
    miDisplayMessages: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Timer2: TTimer;
    Panel2: TPanel;
    Panel1: TImage;
    miUOPilotWiki: TMenuItem;
    miSaveScriptTemplate: TMenuItem;
    mnTab: TPopupMenu;
    miTabRemove: TMenuItem;
    miTabClear: TMenuItem;
    miTabRename: TMenuItem;
    miTabClose: TMenuItem;
    pTabRename: TPanel;
    bTagRenameOk: TButton;
    bTagRenameCancel: TButton;
    seTagRename: TSpinEdit;
    lTabRename: TLabel;
    miExecAndWait: TMenuItem;
    misend217: TMenuItem;
    miFiles: TMenuItem;
    mifilerename: TMenuItem;
    mifilecopy: TMenuItem;
    mifiledelete: TMenuItem;
    midircreate: TMenuItem;
    midirremove: TMenuItem;
    mifileexists: TMenuItem;
    mifilegetattr: TMenuItem;
    mifilegetdate: TMenuItem;
    mifilesetdate: TMenuItem;
    mifilesetattr: TMenuItem;
    midir: TMenuItem;
    miworkwindowpid: TMenuItem;
    mierrorlevel: TMenuItem;
    miscreenheight: TMenuItem;
    miscreenwidth: TMenuItem;
    midesktopheight: TMenuItem;
    midesktopwidth: TMenuItem;
    mimonitorheight: TMenuItem;
    mimonitorwidth: TMenuItem;
    mimonitor: TMenuItem;
    miinitarr: TMenuItem;
    setresultindexOfarrnoabscasestartRowEndRowcounttext1: TMenuItem;
    miMacrosend: TMenuItem;
    miOptions: TMenuItem;
    pLog: TPanel;
    tcLog: TTabControl;
    mLog: TMemo;
    cbhkEnableAllHotKeys: TCheckBox;
    lhkEnableAllHotKeys: TSpeedButton;
    Bevel6: TBevel;
    Bevel5: TBevel;
    Panel17: TPanel;
    Panel26: TPanel;
    Panel27: TPanel;
    miColor: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    miNumbers: TMenuItem;
    cbhkStartAllScript: TCheckBox;
    lhkStartAllScript: TSpeedButton;
    lhkShowScriptProcessing: TSpeedButton;
    cbhkShowScriptProcessing: TCheckBox;
    sbWorkwindowHandle: TSpeedButton;
    miDayofweek: TMenuItem;
    miStartStopCurrentScript: TMenuItem;
    Panel28: TPanel;
    Panel29: TPanel;
    pDefineColor: TPanel;
    EoffName: TSpinEdit;
    EoffTrans: TSpinEdit;
    EoffCrim: TSpinEdit;
    EoffPathF: TSpinEdit;
    EoffCP: TSpinEdit;
    EoffLMess: TSpinEdit;
    EoffCoords: TSpinEdit;
    EoffTarget: TSpinEdit;
    EoffLastSpell: TSpinEdit;
    EoffLastSkill: TSpinEdit;
    EoffLastLiftedID: TSpinEdit;
    EoffLastObjectType: TSpinEdit;
    EoffLastStaticType: TSpinEdit;
    EoffLastTargetKind: TSpinEdit;
    EoffLastTargetXYZ: TSpinEdit;
    EoffLastObTar1: TSpinEdit;
    EoffLastObTar2: TSpinEdit;
    EoffCharDir: TSpinEdit;
    lccName: TLabel;
    lccTrans: TLabel;
    lccCrim: TLabel;
    offPathF1: TLabel;
    offCP1: TLabel;
    offLMess1: TLabel;
    offCoords1: TLabel;
    offTarget1: TLabel;
    offLastSpell1: TLabel;
    offLastSkill1: TLabel;
    offLastLiftedID1: TLabel;
    offLastStaticType1: TLabel;
    offLastTargetKind1: TLabel;
    offLastTargetXYZ1: TLabel;
    offLastOb1: TLabel;
    offLastTar1: TLabel;
    offCharDir1: TLabel;
    offLastObjectType1: TLabel;
    sbLMFind: TSpeedButton;
    eLM: TEdit;
    sLM: TSpinEdit;
    sCPGold: TSpinEdit;
    sbCPFind: TSpeedButton;
    sCP: TSpinEdit;
    rbClVer1_3: TRadioButton;
    rbClVer6_x: TRadioButton;
    lccFontcol: TLabel;
    lccLastSp: TLabel;
    lccSkills: TLabel;
    EoffFontcolor: TSpinEdit;
    EoffWght: TSpinEdit;
    ELastSpellStartNum: TSpinEdit;
    EoffSkills: TSpinEdit;
    lccHiddenW: TLabel;
    lccArun: TLabel;
    lccConUnTe: TLabel;
    EoffHidden_War: TSpinEdit;
    EoffAlwaysRun: TSpinEdit;
    EoffConsoleUnicodeText: TSpinEdit;
    lccWght: TLabel;
    cbCustomClVer: TComboBox;
    lccClVer: TLabel;
    pCustomClient: TPanel;
    eUOpath: TEdit;
    lsusPath: TLabel;
    sgLoginLine: TStringGrid;
    sbReload: TSpeedButton;
    sbSaveLL: TSpeedButton;
    sbAddLine: TSpeedButton;
    sbClose: TSpeedButton;
    pSelectUOserver: TPanel;
    pMakroOptions: TPanel;
    sbmoOk: TSpeedButton;
    sbmoCancel: TSpeedButton;
    mmoText: TMemo;
    emoButName: TEdit;
    lmoButName: TLabel;
    cbmoEnter: TCheckBox;
    edmoPause: TEdit;
    ToolBar1: TToolBar;
    tb5: TToolButton;
    tb6: TToolButton;
    tb7: TToolButton;
    tb11: TToolButton;
    tb1: TToolButton;
    tb4: TToolButton;
    tb10: TToolButton;
    tb2: TToolButton;
    tb3: TToolButton;
    tb8: TToolButton;
    tb9: TToolButton;
    tb12: TToolButton;
    tb15: TToolButton;
    tb16: TToolButton;
    tb17: TToolButton;
    tb18: TToolButton;
    tb19: TToolButton;
    tb20: TToolButton;
    tb21: TToolButton;
    tb22: TToolButton;
    tb13: TToolButton;
    tb14: TToolButton;
    tmTimer1: TTimer;
    ToolButton1: TToolButton;
    pMakrosPanel: TPanel;
    pEditHouse: TPanel;
    sbehOk: TSpeedButton;
    sbehCancel: TSpeedButton;
    eehEditHouseCommands: TEdit;
    Button8: TButton;
    eSoundFileSelect: TEdit;
    sbSoundFileSelect: TSpeedButton;
    N1: TMenuItem;
    mihotkeystart: TMenuItem;
    mihotkeypause: TMenuItem;
    miLogWindow: TSpeedButton;
    sbScriptProcessing: TSpeedButton;
    cbLoggingCommands: TCheckBox;
    lWinList: TLabel;
    Bevel10: TBevel;
    miSend217down: TMenuItem;
    miSend217up: TMenuItem;
    sbStopSearchClient: TSpeedButton;
    miExit1: TMenuItem;
    gbFind: TGroupBox;
    eFindText: TEdit;
    cbCaseSens: TCheckBox;
    bFindNext: TButton;
    rbFindUp: TRadioButton;
    rbFindDown: TRadioButton;
    miUltimaOnline: TMenuItem;
    miEvalF: TMenuItem;
    miEvalC: TMenuItem;
    bSaveOptions: TButton;
    test1: TMenuItem;
    cbHotKeyIsHolded: TCheckBox;
    CheckBox1: TCheckBox;
    mi15: TMenuItem;
    mi16: TMenuItem;
    mi17: TMenuItem;
    mi18: TMenuItem;
    miFormat: TMenuItem;
    SpeedButton3: TSpeedButton;
    miPluginload: TMenuItem;
    miPluginunload: TMenuItem;
    miPluginreload: TMenuItem;
    miCharToHex: TMenuItem;
    miCharToHex2: TMenuItem;
    miCharToHexF: TMenuItem;
    miCharToHexF2: TMenuItem;
    miWindowfrompoint: TMenuItem;
    miSwitch: TMenuItem;
    miCase: TMenuItem;
    miBreak1: TMenuItem;
    miEndswitch: TMenuItem;
    micocos: TMenuItem;
    claqua1: TMenuItem;
    clblack1: TMenuItem;
    clblue1: TMenuItem;
    clfuchsia1: TMenuItem;
    clgreen1: TMenuItem;
    cllime1: TMenuItem;
    clmaroon1: TMenuItem;
    clnavy1: TMenuItem;
    clolive1: TMenuItem;
    clpurple1: TMenuItem;
    clred1: TMenuItem;
    clsilver1: TMenuItem;
    clteal1: TMenuItem;
    clwhite1: TMenuItem;
    clyellow1: TMenuItem;
    clgray1: TMenuItem;
    clltgray1: TMenuItem;
    cldkgray1: TMenuItem;
    colorToRedcolor1: TMenuItem;
    colorToGreencolor1: TMenuItem;
    colorToBluecolor1: TMenuItem;
    colorToRGBcolorarrx1: TMenuItem;
    N7: TMenuItem;
    miCriminalactions: TMenuItem;
    miPathfinding: TMenuItem;
    miShownames: TMenuItem;
    miTransparency: TMenuItem;
    miLtrim: TMenuItem;
    miRtrim: TMenuItem;
    miMod: TMenuItem;
    miEmptylinedelay: TMenuItem;
    miSendexdelay: TMenuItem;
    miMouseclickdelay: TMenuItem;
    miShowtimervar1: TMenuItem;
    miShowscriptprocessing1: TMenuItem;
    miStopscrunknowncommand1: TMenuItem;
    miWindowHandle: TMenuItem;
    miExeFileName: TMenuItem;
    miHomePath: TMenuItem;
    miFindoffsetx: TMenuItem;
    miFindoffsety: TMenuItem;
    miClickoffsetx: TMenuItem;
    miClickoffsety: TMenuItem;
    miRegexp: TMenuItem;
    miUnFormat: TMenuItem;
    moLog: TMenuItem;
    miSortarrayarray: TMenuItem;
    miwritefile: TMenuItem;
    miDiv: TMenuItem;
    pcHelp: TPageControl;
    tsHistory: TTabSheet;
    tsWiki: TTabSheet;
    Panel13: TPanel;
    sbDownloadWiki: TSpeedButton;
    cbWikiList: TComboBox;
    spUnpackWiki: TSpeedButton;
    sbWikiBack: TSpeedButton;
    sbWikiForward: TSpeedButton;
    miWikiHelp: TMenuItem;
    miColorsImages: TMenuItem;
    miWhile2: TMenuItem;
    miIF2: TMenuItem;
    miSize2: TMenuItem;
    miSize3: TMenuItem;
    miPromptposx: TMenuItem;
    miPromptposy: TMenuItem;
    miLoghandle: TMenuItem;
    miLogautoopen: TMenuItem;
    miMessagesoutputto: TMenuItem;
    miSendmessage: TMenuItem;
    miPostmessage: TMenuItem;
    miRelativeAddress2absolute: TMenuItem;
    miAbsoluteAddress2relative: TMenuItem;
    miDeletearray: TMenuItem;
    miTrim: TMenuItem;
    N10: TMenuItem;
    miHotkeystart1: TMenuItem;
    miHotkeypause1: TMenuItem;
    miRestartscript: TMenuItem;
    miMovesmooth: TMenuItem;
    sbScriptsPanel: TSpeedButton;
    miSaveOptionsAs: TMenuItem;
    miLoadOptionsAs: TMenuItem;
    lBackpack: TLabel;
    EoffBackpack: TSpinEdit;
    PageControl1: TPageControl;
    tsSUltimaOnline: TTabSheet;
    tsSScripts: TTabSheet;
    tsSWindows: TTabSheet;
    tsSMouse: TTabSheet;
    tsSLogs: TTabSheet;
    tsSOther: TTabSheet;
    gbUltimaOnline: TGroupBox;
    SelectUOserver1: TSpeedButton;
    miSortSkillList: TCheckBox;
    N01: TGroupBox;
    cbName: TCheckBox;
    cbTrans: TCheckBox;
    cbPathF: TCheckBox;
    cbCrim: TCheckBox;
    cbRun: TCheckBox;
    miErrorReadCP: TGroupBox;
    miStopSErrorRead: TCheckBox;
    miPauseSErrorRead: TCheckBox;
    miInformErrorRead: TCheckBox;
    miShowCharParams: TGroupBox;
    miSCPscript: TRadioButton;
    miSCPtopuo: TRadioButton;
    miSCPuop: TRadioButton;
    GroupBox2: TGroupBox;
    lComment: TLabel;
    miAddSp: TCheckBox;
    miStopSUncC: TCheckBox;
    miPauseSOnClientClose: TCheckBox;
    miShowScriptProcessing: TCheckBox;
    miShowSFNames: TCheckBox;
    miShowRuningScript: TCheckBox;
    miKnopusechki_onoff: TCheckBox;
    miShowRemainingWait: TCheckBox;
    miGutterVisible: TCheckBox;
    miShowRuningScriptOnTaskbar: TCheckBox;
    miShowCommandHint: TCheckBox;
    cbShowScriptNamesOnTabs: TCheckBox;
    cbShowUnsavedScripts: TCheckBox;
    cbCommentOnClick: TCheckBox;
    cbCommentOnSelect: TCheckBox;
    N11: TGroupBox;
    cbSOT: TCheckBox;
    miSOTShipControl: TCheckBox;
    miSOTHouseControl: TCheckBox;
    miSOTAnimalVendor: TCheckBox;
    miSOTCharParameters: TCheckBox;
    miSOTScriptWindow: TCheckBox;
    miSOTLogWindow: TCheckBox;
    N22: TGroupBox;
    miSPosUoP: TCheckBox;
    miSPosS: TCheckBox;
    miSPosCP: TCheckBox;
    miSPosHC: TCheckBox;
    miSPosSC: TCheckBox;
    miSPosAC: TCheckBox;
    N23: TGroupBox;
    miAutoOpenCP: TCheckBox;
    N27: TGroupBox;
    miSaveScrActiweWindow: TRadioButton;
    miSaveScrWorkWindow: TRadioButton;
    miSaveScrAllScreen: TRadioButton;
    GroupBox4: TGroupBox;
    miMoveMouseBack: TCheckBox;
    miMoveMouseBeforeClick: TCheckBox;
    miAMoveCount: TCheckBox;
    miUseNewClickMetod: TCheckBox;
    miUseKleft217: TCheckBox;
    miShowCoords: TGroupBox;
    miSKRel: TCheckBox;
    miSKAbs: TCheckBox;
    GroupBox1: TGroupBox;
    miErrorLogging: TGroupBox;
    miELclrinvalid: TCheckBox;
    miFileOpError: TCheckBox;
    miSetHKError: TCheckBox;
    miPluginLoadError: TCheckBox;
    miLogging: TCheckBox;
    miAutoOpenLog: TCheckBox;
    gbOutputMessagesTo: TGroupBox;
    miToMessageBox: TRadioButton;
    miToHint: TRadioButton;
    miToLog: TCheckBox;
    miToDevnull: TRadioButton;
    bOptionsClose: TButton;
    GroupBox5: TGroupBox;
    miLockOnStartup: TCheckBox;
    miMinToTray: TCheckBox;
    miShowAllWindows: TCheckBox;
    miRenameSelf: TCheckBox;
    miTransparentHotKeys: TCheckBox;
    miShowTimerVar: TCheckBox;
    miShowHex: TCheckBox;
    miShowHelpOnTaskbar: TCheckBox;
    miSaveScriptsOnExit: TCheckBox;
    miSaveOnExit: TCheckBox;
    miStartMinimized: TCheckBox;
    cbHideUOSettings: TCheckBox;
    miSaveScriptsOnRun: TCheckBox;
    eRenameSelf: TEdit;
    tsSMacro: TTabSheet;
    miSpeed: TGroupBox;
    lmSpeed: TLabel;
    lmRepeat: TLabel;
    lmRepeatC: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    tbmiSpeed: TTrackBar;
    semiRepeat: TSpinEdit;
    N20: TCheckBox;
    lLogfilesize: TLabel;
    seLogfilesize: TSpinEdit;
    miGetImage: TMenuItem;
    miDeleteImage: TMenuItem;
    miLoadImage: TMenuItem;
    miSaveImage: TMenuItem;
    mikeyboard: TMenuItem;
    mimouse: TMenuItem;
    miGetFocus: TMenuItem;
    setarrbackpack1: TMenuItem;
    miDateTime: TMenuItem;
    miAddDate: TMenuItem;
    miAddYears: TMenuItem;
    miAddMonths: TMenuItem;
    miAddDays: TMenuItem;
    miAddHours: TMenuItem;
    miAddMinutes: TMenuItem;
    miAddSeconds: TMenuItem;
    miSubDate: TMenuItem;
    miSubYears: TMenuItem;
    miSubMonths: TMenuItem;
    miSubDays: TMenuItem;
    miSubHours: TMenuItem;
    miSubMinutes: TMenuItem;
    miSubSeconds: TMenuItem;
    miYearFromDate: TMenuItem;
    miMonthFromDate: TMenuItem;
    miDayFromDate: TMenuItem;
    miHourFromDate: TMenuItem;
    miMinuteFromDate: TMenuItem;
    miSecondFromDate: TMenuItem;
    miDateNow: TMenuItem;
    miTimeNow: TMenuItem;
    miTimeStamp: TMenuItem;
    miscriptPath: TMenuItem;
    miscriptName: TMenuItem;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    cbCheckGetImage: TCheckBox;
    miLua: TMenuItem;
    Panel30: TPanel;
    rbAttriN: TRadioButton;
    rbAttriI: TRadioButton;
    rbAttriBI: TRadioButton;
    rbAttriB: TRadioButton;
    cbAttriIS: TCheckBox;
    sbAttriChangeApply: TSpeedButton;
    sbSelectColorFront: TSpeedButton;
    cbAttriIU: TCheckBox;
    sbSelectColorBack: TSpeedButton;
    miAttriChange: TMenuItem;
    Label19: TLabel;
    miEditHotKeys: TMenuItem;
    pbWiki: TProgressBar;
    // -- обработчики событий
    procedure FormCreate(Sender: TObject);
    procedure SetCoord(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btCStartClick(Sender: TObject);
    procedure tm0Timer(Sender: TObject);
    procedure HotKeyScr(Sender: TObject);
    procedure HotKeyStartScript(Sender: TObject);
    procedure HotKeyPauseScript(Sender: TObject);
    procedure HotKeyRec(Sender: TObject);
    procedure HotKeyRecStop(Sender: TObject);
    procedure HotKeyPlay(Sender: TObject);
    procedure HotKeyshkctrl(Sender: TObject);
    procedure HotKeySNames(Sender: TObject);
    procedure HotKeyMove(P: TPoint; N: Integer; Back: Boolean);
    procedure HotKeyMove1(Sender: TObject);
    procedure HotKeyMove2(Sender: TObject);
    procedure HotKeyMove3(Sender: TObject);
    procedure HotKeySetMove1(Sender: TObject);
    procedure HotKeySetMove2(Sender: TObject);
    procedure HotKeySetMove3(Sender: TObject);
    procedure HotKeyUopUO(Sender: TObject);
    procedure HotKeyMes(Sender: TObject);
    procedure HotKeyScriptList(Sender: TObject);
    procedure HotKeyScriptListPause(Sender: TObject);
    procedure HotKeyLockAllScroptToUO(Sender: TObject);
    procedure HotKeyClipboardConsoleText(Sender: TObject);
    procedure HotKeyTransp(Sender: TObject);
    procedure HotKeyPathF(Sender: TObject);
    procedure HotKeyCrimAct(Sender: TObject);
    procedure HotKeyARun(Sender: TObject);
    procedure HotKeyStopAllScript(Sender: TObject);
    procedure HotKeyStartAllScript(Sender: TObject);
    procedure HotKeyShowScriptProcessing(Sender: TObject);
    procedure HotKeyPauseAllScript(Sender: TObject);
    procedure HotKeyEnableAllHotKeys(Sender: TObject);
    procedure HotKeyEnableKeyboard(Sender: TObject);
    procedure btLoadClick(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
    procedure miComClick(Sender: TObject);
    procedure edScrExit(Sender: TObject);
    procedure miNewClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miCtrlBClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure ed1Enter(Sender: TObject);
    procedure btAddColClick(Sender: TObject);
    procedure bHouseClick(Sender: TObject);
    procedure bShipOClick(Sender: TObject);
    procedure SBBudilnikClick(Sender: TObject);
    procedure TBudilnikTimer(Sender: TObject);
    procedure SEHourChange(Sender: TObject);
    procedure SEMinutesChange(Sender: TObject);
    procedure cbEnableHKClick(Sender: TObject);
    procedure mmHelpClick(Sender: TObject);
    procedure bShipClick(Sender: TObject);
    procedure cbNameClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbSControlClick(Sender: TObject);
    procedure sbMfHSClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sbStartUOClick(Sender: TObject);
    procedure cbGMPageClick(Sender: TObject);
    procedure sbLoginUOClick(Sender: TObject);
    procedure GroupBox6Click(Sender: TObject);
    procedure cbhk1Click(Sender: TObject);
    procedure sbMacrosClick(Sender: TObject);
    procedure bAddClick(Sender: TObject);
    procedure bAddClickSubproc(Sender: TObject; N: Integer);
    procedure bRemoveClick(Sender: TObject);
    procedure tScriptChange(Sender: TObject);
    procedure tScriptChanging(Sender: TObject; var AllowChange: Boolean);
    procedure miSaveOptionsClick(Sender: TObject);
    procedure miSaveMacrosClick(Sender: TObject);
    procedure mmScriptKeyPress(Sender: TObject; var Key: Char);
    procedure miAddSpClick(Sender: TObject);
    procedure mmScriptKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sbSelServClick(Sender: TObject);
    procedure sbMfHHClick(Sender: TObject);
    procedure sbHouseControlClick(Sender: TObject);
    procedure Button1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cbhkMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure pcAllChange(Sender: TObject);
    procedure cbSOTClick(Sender: TObject);
    procedure cbInsertXYClick(Sender: TObject);
    procedure miSKRelClick(Sender: TObject);
    procedure miSKAbsClick(Sender: TObject);
    procedure tShowCoordsOnCapTimer(Sender: TObject);
    procedure sbPauseClick(Sender: TObject);
    procedure sbEditHKClick(Sender: TObject);
    procedure sbCalibrateClick(Sender: TObject);
    procedure lhkScrClick(Sender: TObject);
    procedure miSMkeymouseClick(Sender: TObject);
    procedure miLMkeymouseClick(Sender: TObject);
    procedure sbLOAddClick(Sender: TObject);
    procedure sgLastObjectDblClick(Sender: TObject);
    procedure sbLODelClick(Sender: TObject);
    procedure miProcOpenClick(Sender: TObject);
    procedure tScriptMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure tHintTimerTimer(Sender: TObject);
    procedure sbCharParamsClick(Sender: TObject);
    procedure mParamNameEnter(Sender: TObject);
    procedure miSCPscriptClick(Sender: TObject);
    procedure miInvertChecked(Sender: TObject);
    procedure miShowHexClick(Sender: TObject);
    procedure miSaveLOClick(Sender: TObject);
    procedure mParamValue2DblClick(Sender: TObject);
    procedure mParamValue2SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
    procedure miClesrLOClick(Sender: TObject);
    procedure miScriptFontSelectClick(Sender: TObject);
    procedure fdEditorApply(Sender: TObject; Wnd: HWND);
    procedure sbCFCP1Click(Sender: TObject);
    procedure sbCFCP2Click(Sender: TObject);
    procedure sbCFCP3Click(Sender: TObject);
    procedure sbCFCP4Click(Sender: TObject);
    procedure sbCFCP5Click(Sender: TObject);
    procedure sbCFCP7Click(Sender: TObject);
    procedure miStopSErrorReadClick(Sender: TObject);
    procedure miPauseSErrorReadClick(Sender: TObject);
    procedure miInformErrorReadClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure IconCallBackMessage(var Msg: TMessage); message WM_USER + $64;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miMinToTrayClick(Sender: TObject);
    procedure tScriptDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure miShowRuningScriptClick(Sender: TObject);
    procedure tTabRefreshTimer(Sender: TObject);
    procedure mmScriptChange(Sender: TObject);
    procedure sghkScriptHKListClick(Sender: TObject);
    procedure sghkScriptHKListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
    procedure sbStayClick(Sender: TObject);
    procedure sbAnimalControlClick(Sender: TObject);
    procedure sgVarSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
    procedure sgVarDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
    procedure sgVarSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure miLangSelect(Sender: TObject);
    procedure miScriptHelpClick(Sender: TObject);
    procedure tbScriptPriorityChange(Sender: TObject);
    procedure tbUOPriorityChange(Sender: TObject);
    procedure cbDebugClick(Sender: TObject);
    procedure miShowTimerVarClick(Sender: TObject);
    procedure sbShowSkillsClick(Sender: TObject);
    procedure mLMDblClick(Sender: TObject);
    procedure miUOSetupClick(Sender: TObject);
    procedure miTrayRestoreClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure miPauseCurrentScriptClick(Sender: TObject);
    procedure miPauseAllScriptClick(Sender: TObject);
    procedure sbWinListClick(Sender: TObject);
    procedure cbWinListChange(Sender: TObject);
    procedure NotPayedProc(Sender: TObject);
    procedure tScriptMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pcAllChanging(Sender: TObject; var AllowChange: Boolean);
    procedure miLogWindowClick(Sender: TObject);
    procedure mmScriptKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mmScriptMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mmScriptMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mmScriptOnChange(Sender: TObject);
    procedure cbClVerChange(Sender: TObject);
    procedure miPluginsClick(Sender: TObject);
    procedure miPluginSampleClick(Sender: TObject);
    procedure miTransparentHotKeysClick(Sender: TObject);
    procedure miGutterVisibleClick(Sender: TObject);
    procedure miShowHelpOnTaskbarClick(Sender: TObject);
    procedure miRenameSelfClick(Sender: TObject);
    procedure sbCFCP8Click(Sender: TObject);
    procedure sbApplyClick(Sender: TObject);
    procedure sbCancelClick(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure miUOPilotWikiClick(Sender: TObject);
    procedure miSaveScriptTemplateClick(Sender: TObject);
    procedure miTabRenameClick(Sender: TObject);
    procedure bTagRenameCancelClick(Sender: TObject);
    procedure bTagRenameOkClick(Sender: TObject);
    procedure bOptionsCloseClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure tcLogChanging(Sender: TObject; var AllowChange: Boolean);
    procedure tcLogChange(Sender: TObject);
    procedure miShowRuningScriptOnTaskbarClick(Sender: TObject);
    procedure miStartStopCurrentScriptClick(Sender: TObject);
    procedure EoffNameChange(Sender: TObject);
    procedure sbLMFindClick(Sender: TObject);
    procedure sbCPFindClick(Sender: TObject);
    procedure cbCustomClVerChange(Sender: TObject);
    procedure sbReloadClick(Sender: TObject);
    procedure sgLoginLineMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure sbSaveLLClick(Sender: TObject);
    procedure sbAddLineClick(Sender: TObject);
    procedure sgLoginLineRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure sbCloseClick(Sender: TObject);
    procedure sbmoOkClick(Sender: TObject);
    procedure sbmoCancelClick(Sender: TObject);
    procedure sbehOkClick(Sender: TObject);
    procedure tb1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tb1Click(Sender: TObject);
    procedure ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure tmTimer1Timer(Sender: TObject);
    procedure tbmiSpeedChange(Sender: TObject);
    procedure semiRepeatChange(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure sbehCancelClick(Sender: TObject);
    procedure sbSoundFileSelectClick(Sender: TObject);
    procedure btColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure cbLoggingCommandsClick(Sender: TObject);
    procedure sbScriptProcessingClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure sbStopSearchClientClick(Sender: TObject);
    procedure bFindNextClick(Sender: TObject);
    procedure eFindTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbHideUOSettingsClick(Sender: TObject);
    procedure tScriptDescChange(Sender: TObject);
    procedure cbShowScriptNamesOnTabsClick(Sender: TObject);
    procedure tScriptDescMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormsKeyPress(Sender: TObject; var Key: Char);
    procedure CheckBox1Click(Sender: TObject);
    procedure seTabSizeChange(Sender: TObject);
    procedure miFormatClick(Sender: TObject);
    procedure miUnFormatClick(Sender: TObject);
    procedure sbDownloadWikiClick(Sender: TObject);
    procedure cbWikiListChange(Sender: TObject);
    procedure spUnpackWikiClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure sbWikiBackClick(Sender: TObject);
    procedure sbWikiForwardClick(Sender: TObject);
    procedure WebBrowserCommandStateChange(Sender: TObject; Command: Integer; Enable: WordBool);
    procedure mnComPopup(Sender: TObject);
    procedure miWikiHelpClick(Sender: TObject);
    procedure pcHelpChange(Sender: TObject);
    procedure sbScriptsPanelClick(Sender: TObject);
    procedure miSaveOptionsAsClick(Sender: TObject);
    procedure miLoadOptionsAsClick(Sender: TObject);
    procedure seLogfilesizeChange(Sender: TObject);
    procedure miShowRemainingWaitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure sbSelectColorFrontClick(Sender: TObject);
    procedure sbSelectColorBackClick(Sender: TObject);
    procedure miAttriChangeClick(Sender: TObject);
    procedure odLoadShow(Sender: TObject);
  public
    // Поля, которых нет в DFM: заводятся кодом в FormCreate.
    edScript: TSynMemo;
    fld_1428: TSynCustomHighlighter;
    FHelpMemo: TMemo;
    fld_1430: Integer;
    fld_1434: Integer;
    FFlag1438: Boolean;
    FFlag1439: Boolean;
    FFlag143A: Boolean;
    FFlag143B: Boolean;
    FOptionsFile: string;
    FTargetWnd: HWND;
    fld_1444: Integer;
    FClientProcess: THandle;
    fld_144C: Integer;
    fld_1450: Integer;
    fld_1454: Integer;
    fld_1458: Integer;
    fld_145C: Integer;
    fld_1460: Integer;
    FFlag1464: Boolean;
    FFlag1465: Boolean;
    FFlag1466: Boolean;
    FFlag1467: Boolean;
    FLogWin: TLogWinRecZ;
    FPausedByHotKey: array[0..99] of Byte;
    FFlag14DD: Boolean;
    FPad14DE: array[$14DE..$14DF] of Byte;
    fld_14E0: Integer;
    FFlag14E4: Boolean;
    FFlag14E5: Boolean;
    FFlag14E6: Boolean;
    FFlag14E7: Boolean;
    fld_14E8: Integer;
    FFlag14EC: Boolean;
    FFlag14ED: Boolean;
    FFlag14EE: Boolean;
    FFlag14EF: Boolean;
    wbWiki: TWebBrowser;
    function CanCloseOrActivate: Boolean;
    procedure SetRunButtonsStopped;
    procedure SetRunButtonsStarted;
    procedure UpdateClientFlags(ProcessHandle: THandle);
    procedure EmulateMouseMessage(Key: Byte; LParam: LPARAM);
    procedure MinimizeToTray;
    procedure AppActivateKeepTopmost(Sender: TObject);
    procedure InsertScriptCommand(Cmd: string);
    procedure HideHintWindow(var W: TObject);
    procedure EditHotKey(Name: ShortString);
    procedure DetachedPanelClose(Sender: TObject; var CanClose: Boolean);
    procedure CFCPRelayout(Sender: TObject);
    procedure MacroFileOp(Mode: Byte; FileName: string);
    procedure ApplyLogFont;
    procedure LoadScriptFile(FileName: string);
    procedure ApplyLanguage(Code: Integer);
    procedure HotKeyListClose(Sender: TObject; var CanClose: Boolean);
    procedure OptionsFormClose(Sender: TObject; var CanClose: Boolean);
    procedure HelpMemoWndProc(var Message: TMessage);
    procedure HelpMemoWndProc2(var Message: TMessage);
    procedure HelpFormClose(Sender: TObject; var CanClose: Boolean);
    procedure PluginSampleFormClose(Sender: TObject; var CanClose: Boolean);
    procedure ScriptHelpFormClose(Sender: TObject; var CanClose: Boolean);
    procedure AboutFormClose(Sender: TObject; var CanClose: Boolean);
    procedure ShipControlClose(Sender: TObject; var CanClose: Boolean);
    procedure HouseControlClose(Sender: TObject; var CanClose: Boolean);
    procedure AnimalControlClose(Sender: TObject; var CanClose: Boolean);
    procedure LogWindowClose(Sender: TObject; var CanClose: Boolean);
    procedure ShowWikiTopic(Topic: string);
    procedure SaveScriptToFile(FileName: string);
    procedure AfterOptionsLoaded;
    procedure RefreshVarPanel;
    procedure SaveScriptSection(Ini: TMyMemIniFile; Sect: string);
    procedure SaveUoPilotSection(Ini: TMyMemIniFile; Sect: string);
    procedure WebBrowserBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant; var Flags: OleVariant;
      var TargetFrameName: OleVariant; var PostData: OleVariant;
      var Headers: OleVariant; var Cancel: WordBool);
    procedure CharParamsWndProc(var Message: TMessage);
    procedure CharParamsCloseQuery(Sender: TObject;
      var CanClose: Boolean);
    procedure ScriptFindDialogFind(Sender: TObject);
    procedure ShowWikiForCommand;
    function ParseTimerValue(S: string): Integer;
    procedure TimerKeyAction(Kind: Byte; Value: Integer);
    procedure SelServerClose(Sender: TObject; var CanClose: Boolean);
    procedure MacroOptionsClose(Sender: TObject; var CanClose: Boolean);
    function CreateTabHint(C: TWinControl): THintWindow;
    procedure CharParamsFormClose(Sender: TObject;
      var Action: TCloseAction);
    procedure GutterClick(Sender: TObject; Button: TMouseButton;
      X, Y, Line: Integer; Mark: TSynEditMark);
    procedure RedrawAllTabs;
    procedure LastScriptItemClick(Sender: TObject);
    procedure ScriptTabWndProc(var Message: TMessage);
    procedure WndProc(var Message: TMessage); override;
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure WMNCHitTest(var Msg: TMessage); message WM_NCHITTEST;
    procedure WMSize(var Msg: TMessage); message WM_SIZE;
    procedure WMSysCommand(var Msg: TMessage); message WM_SYSCOMMAND;
    procedure WMNCLButtonDblClk(var Msg: TMessage); message WM_NCLBUTTONDBLCLK;
  public
    { public declarations }
  end;
  ToneButton = packed record
    Name: string;                      // +$000
    Enter: Boolean;                    // +$004
    Pad005: array[$005..$007] of Byte;
    Pause: string;                     // +$008
    Lines: array[1..3] of string[255]; // +$00C, +$10C, +$20C
  end;

  TGMPageThread = class(TThread)
  protected
    procedure Execute; override;
  end;
  TStartUOThread = class(TThread)
  public
    Wnd: HWND;             // найденное окно клиента
    Pid: DWORD;            // его pid (0 = окно ещё не найдено)
    ProcId: DWORD;         // pid, выданный CreateProcess
  protected
    procedure Execute; override;
  end;

  TLoginUOThread = class(TThread)
  protected
    procedure Execute; override;
  end;
  THKMod = (hkShift, hkAlt, hkCtrl);
  THKMods = set of THKMod;
  tHotKeyList = packed record
    Key: Integer;                      // +$00
    Name: string;                      // +$04  имя компонента
    Mods: THKMods;                     // +$08  Shift/Alt/Ctrl
    Pad09: array[$09..$0B] of Byte;
    Text: string;                      // +$0C  подпись клавиши
    Handler: TNotifyEvent;             // +$10
    Enabled: Boolean;                  // +$18
    Pad19: array[$19..$1B] of Byte;
    Sound: string;                     // +$1C
  end;

  TWikiThread = class(TThread)
  public
    FMsg: string;
    procedure SyncProgressStart;
    procedure SyncProgressStep;
    procedure SyncProgressDone;
  protected
    procedure Execute; override;
  end;


  { Псевдоним: сам класс окна подсказки живёт в uScanThread,
    а Unit2 знает его под этим именем. }
  TRxHintWindow = TRxHintWindowRef;

  TInitPlugin = function(AHandle: HWND; AParam: Integer;
    var AVersion: Double): PPluginFuncs; stdcall;

  PHKName = ^string;
  TLabelMark = packed record
    Row: Integer;
    Indent: Integer;
  end;
  THKNameTable = array[0..101] of string;
  PHKNameTable = ^THKNameTable;
  THKCodeTable = array[0..101] of Byte;
  PHKCodeTable = ^THKCodeTable;
  THKItemFull = class(TCollectionItem)
  public
    HotKeyId: Integer;                 // +$0C
    Handler: TNotifyEvent;             // +$10
    HKName: string;                    // +$18
    HotKeyCode: Integer;               // +$1C
    Shift: Byte;                       // +$20
    Pad21: array[$21..$2F] of Byte;
    Sound: string;                     // +$30
  end;

  PMouseMacro = ^ToneButton;







  PImgPt = ^TImgPt;
  TImgPt = packed record
    X: Integer;
    Y: Integer;
    C: Integer;
  end;

  TPackBuf = packed record
    F00: Integer;
    Pad04: array[$04..$23] of Byte;
    W24: Word;
    W26: Word;
    Pad28: array[$28..$3B] of Byte;
    W3C: Word;
    Pad3E: array[$3E..$3F] of Byte;
    W40: Word;
    W42: Word;
    Pad44: array[$44..$47] of Byte;
    N48: Integer;
    Pad4C: array[$4C..$7B] of Byte;
    S7C: Integer;
    O80: Integer;
    Pad84: array[$84..$87] of Byte;
    N88: Integer;
    Pad8C: array[$8C..$B3] of Byte;
  end;








  { Вкладок со скриптами 99; сотая, с процедурами, лежит отдельной
    величиной gProcScript. }
  TScriptArray = array[0..98] of TScanThread;
  TEvalNames = array[0..288] of string;
  TWordCharSet = set of Char;

{$WRITEABLECONST ON}

function OleInitialize(pvReserved: Pointer): HResult;
  stdcall; external 'ole32.dll';
procedure OleUninitialize;
  stdcall; external 'ole32.dll';

var
  gStartUOThread: TStartUOThread;
  fmSecondfj: TfmSecond;
  gClientThread: THandle;
  gWorkWnd: HWND;
  gLoginProcess: THandle;
  gLoginWnd: HWND;
  gLastPoint: Integer;
  gStr59615C: string;
  gHKNames: array of Cardinal;
  gAutoRun: array[0..99] of Boolean;      // ключ /rN
  gCmdFiles: array of string;             // скрипты из командной строки
  gPausedCache: array[0..99] of Boolean;
  gRunCache: array[0..99] of Boolean;
  gDrinkTicks: Integer;                    // обратный отсчёт зелья
  gAppTitle: string[255];            // исходный Application.Title
  gFormCaption: string[255];         // исходный заголовок формы
  gDrinkArmed: Integer;                    // отсчёт уже запущен
  gHouseMenu: array[0..6] of string;      // LockDown, Secure, Release,
                                          // Ban, Trash, Remove, Strongbox
  // команды кнопок дома/корабля, индексируются Tag кнопки.
  gHouseCmds: THouseCmdsZ absolute gHouseMenu;
  gHKBusy: Boolean;
  gNoFocusStealfq: Boolean;
  gCalibrBase: Cardinal;
  gHKMoveBusy: Boolean;
  gScriptCount: Integer;
  gPlayCount: Integer;              // число повторов воспроизведения
  gFlashing6: Boolean;
  gLangId: Integer;                       // PRIMARYLANGID системы
  gLangOffsety: Word;
  gHKEntrieslw: array of tHotKeyList;
  gHKSela: Integer;
  gHKMode: Integer;
  gHotKeyTag: Integer;               // Tag флажка, которому назначают клавишу
  gHKKeyIndex: Integer;
  gHKItem: Integer;                  // индекс правимой клавиши в gHotKeyMgr, -1 = нет
  gKbdLayoutow: string;                     // раскладка из реестра
  gCmdCounteh: Integer;
  gEditorFontName: string;
  gLogFontName: string;
  gEditorFontSize: Integer;
  gLogFontSize: Integer;
  gFontApplyBoth: Boolean;
  gListFontSize: Integer;
  gFontTarget: Integer;              // куда применять шрифт: 1 -- редактор, 2 -- лог
  gTemplateLines: TStrings;         // шаблон нового скрипта
  gMouseX: Integer;                  // координаты последнего клика по вкладке
  gMouseY: Integer;
  gHKDisabled: Boolean;
  gFlag596521: Boolean;
  gPerfFreqby: Int64;                       // QueryPerformanceFrequency на старте
  gTaskbarMsg: Cardinal;
type
  TSkillNameRecZ = record
    Name: string;
    Short: string;
  end;
  TSkillNamesZ = array[0..$39] of TSkillNameRecZ;

type
  TClVerNamesZ = array[0..23] of string;

const
  gExtNames: array[0..2] of string = (
    '.txt', '.scr', '.mac');
  gDrinkMsg1: string = 'You put the empty bottle';
  gDrinkMsg2: string = 'ss';
  gDrinkMsg3: string = ' in your pack.';
  gNtUserNames: array[0..3] of string = (
    'XP sp2-3 32bit', 'Vista H 32bit', 'W7 Ult 32bit', '');
  { Индексы -3..-1 -- номера системного вызова NtUserPostMessage по
    версиям Windows, остальное -- шкала скорости. }
  SpeedTableaah: array[-3..15] of Integer = (
    $11DB, $11F1, $11FC,
    0, -100, -50, -20, -10, -5, -4, -2, 1, 2, 4, 5, 10, 20, 50, 100);
var
  gSkillFlataq: array[0..115] of string = (   // 58 пар подряд
    'Alchemy', '', 'Anatomy', '', 'Animal Lore', 'AnimalLore', 'ItemID',
    'Item Identification', 'Arms Lore', 'ArmsLore', 'Parrying', '', 'Begging',
    '', 'Blacksmithing', 'Blacksmithy', 'Bowcraft', 'Fletching',
    'Peacemaking', '', 'Camping', '', 'Carpentry', '', 'Cartography', '',
    'Cooking', '', 'Detect Hidden', 'DetectHidden', 'Enticement',
    'Discordance', 'Evaluate Intelligence', 'EvaluateIntelligence', 'Healing',
    '', 'Fishing', '', 'Forensic Evaluation', 'ForensicEvaluation', 'Herding',
    '', 'Hiding', '', 'Provocation', '', 'Inscription', '', 'Lockpicking', '',
    'Magery', '', 'Magic Resistance', 'MagicResistance', 'Tactics', '',
    'Snooping', '', 'Musicianship', '', 'Poisoning', '', 'Archery', '',
    'Spirit Speak', 'SpiritSpeak', 'Stealing', '', 'Tailoring', '',
    'Animal Taming', 'AnimalTaming', 'TasteID', 'Taste Identification',
    'Tinkering', '', 'Tracking', '', 'Veterinary', '', 'Swordsmanship', '',
    'Mace Fighting', 'MaceFighting', 'Fencing', '', 'Wrestling', '',
    'Lumberjacking', '', 'Mining', '', 'Meditation', '', 'Stealth', '',
    'Remove Trap', 'RemoveTrap', 'Necro', 'Necromancy', 'Focus', '',
    'Chivalry', '', 'Bushido', '', 'Ninjitsu', '', 'Spellweaving', '',
    'Mysticism', '', 'Imbuing', '', 'Throwing', '');
  gSkillNames: TSkillNamesZ absolute gSkillFlataq;
const
  gItemNamesbq: array[0..692] of string = (
    'Clumsy', 'Create Food', 'Feeblemind', 'Heal', 'Magic Arrow',
    'Night Sight', 'Reactive Armor', 'Weaken', 'Agility', 'Cunning', 'Cure',
    'Harm', 'Magic Trap', 'Magic Untrap', 'Protection', 'Strength', 'Bless',
    'Firball', 'Magic Lock', 'Poison', 'Telekinesis', 'Teleport', 'Unlock',
    'Wall of Stone', 'Archcure', 'Archprotection', 'Curse', 'Fire Field',
    'Greater Heal', 'Lightning', 'Mana Drain', 'Recall', 'Blade Spirits',
    'Dispel Field', 'Incognito', 'Magic Reflection', 'Mind Blast', 'Paralyze',
    'Poison Field', 'Summon Creature', 'Dispel', 'Energy Bolt', 'Explosion',
    'Invisibility', 'Mark', 'Mass Curse', 'Paralyze Field', 'Reveal',
    'Chain Lightning', 'Energy Field', 'Flamestrike', 'Gate Travel',
    'Mana Vampire', 'Mass Dispel', 'Meteor Swarm', 'Polymorph', 'Earthquake',
    'Energy Vortex', 'Resurrection', 'Summon Air', 'Summon Demon',
    'Summon Earth', 'Summon Fire', 'Summon Water', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', 'Animate Dead', 'Blood Oath',
    'Corpse Skin', 'Curse Weapon', 'Evil Omen', 'Horrific Beast', 'Lich Form',
    'Mind Rot', 'Pain Spike', 'Poison Strike', 'Strangle', 'Summon Familiar',
    'Vampiric Embrace', 'Vengeful Spirit', 'Wither', 'Wraith Form',
    'Exorcism', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Cleanse by Fire',
    'Close Wounds', 'Consecrate Weapon', 'Dispel Evil', 'Divine Fury',
    'Enemy of One', 'Holy Light', 'Noble Sacrifice', 'Remove Curse',
    'Sacred Journey', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    'Honorable Execution', 'Confidence', 'Evasion', 'Counter Attack',
    'Lightning Strike', 'Momentum Strike', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', 'Focus Attack',
    'Death Strike', 'Animal Form', 'Ki Attack', 'Surprise Attack', 'Backstab',
    'Shadow Jump', 'Mirror Image', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', 'Arcane Circle', 'Gift of Renewal',
    'Immolating Weapon', 'Attunement', 'Thunderstorm', 'Nature''s Fury',
    'Summon Fey', 'Summon Fiend', 'Reaper Form', 'Wildfire',
    'Essense of Wind', 'Dryad Allure', 'Ethereal Voyage', 'Word of Death',
    'Gift of Life', 'Arcane Empowerment', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    'Nether Bolt', 'Healing Stone', 'Purge Magic', 'Enchant', 'Sleep',
    'Eagle Strike', 'Animated Weapon', 'Stone Form', 'Spell Trigger',
    'Mass Sleep', 'Cleansing Winds', 'Bombard', 'Spell Plague', 'Hail Storm',
    'Nether Cyclone', 'Rising Colossus');
var
  gWordCharsadq: TWordCharSet = ['!', '#'..'%', '('..'+', '-'..':',
    '<'..'Z', '\', '^'..'_', 'a'..'{', '}'..'~', #$A8, #$B8, #$C0..#$FF];

var
  gStrs596530: array of string;           // объявлен и не используется
  gScriptso3: TScriptArray;
  gScriptsRaw: array[0..99] of Pointer absolute gScriptso3;
  gScriptsA: array[0..99] of TScanThread absolute gScriptso3;
  gProcScript: TScanThread;                // вкладка процедур
  gCmdListah7: TStringList;
  gCmdList2jj: TStringList;

{ Доступ к защищённым методам: MoveRow у сетки и FreeImage у битмапа. }
type
  TGridCracker = class(TStringGrid);
  TBitmapCracker = class(Graphics.TBitmap);

const
  gCmdNamesdd: TEvalNames = (   // имена величин языка скриптов, 289 позиций
    'name', 'gold', 'wght', 'armor', 'hits', 'mana', 'stam', 'lastmsg',
    'coordx', 'coordy', 'min', 'hour', 'sec', 'str', 'int', 'dex', 'chardir',
    'timer', 'lastobjectid', 'lastobjecttype', 'lasttargetid', 'lasttargetx',
    'lasttargety', 'lasttargetz', 'lasttargetkind', 'lastliftedid',
    'lastskill', 'lastspell', 'laststatictype', 'coordz', 'target',
    'charposx', 'charposy', 'charposz', 'lastobject', 'lasttarget', 'skills',
    'war', 'hidden', 'arun', 'delimiter', 'spellname', 'windowpos',
    'findwindow', 'workwindow', 'random', 'getwindow', 'getwindowtext',
    'mouse_pos', 'color', 'number', 'word', 'xxx', 'year', 'month', 'day',
    'priority', 'prompt', 'setwindowtext', 'psysresist', 'fireresist',
    'coldresist', 'poisresist', 'enerresist', 'luck', 'damage', 'hitsmax',
    'manamax', 'stammax', 'wghtmax', 'damagemax', 'followers', 'followersmax',
    'linedelay', 'fontcolor', 'findcolor', 'size', 'clipboard', 'logging',
    'getlayout', 'setlayout', 'windowfromcursor', 'getselectedtext',
    'setselectedtext', 'scripts', 'current_script', 'active_script',
    'hex2dec', 'dec2hex', 'findimage', 'defcolor', 'defx', 'defy', 'defxabs',
    'defyabs', 'workwindowpid', 'posex', 'copy', 'delete', 'insert',
    'errorlevel', 'screenheight', 'screenwidth', 'desktopheight',
    'desktopwidth', 'monitorheight', 'monitorwidth', 'monitor', 'indexof',
    'fileexists', 'filegetattr', 'filegetdate', 'windowfrompoint',
    'mousepos_x', 'mousepos_y', 'mouseposabs_x', 'mouseposabs_y', 'abs',
    'round', 'floor', 'ceil', 'frac', 'sqrt', 'power', 'exp', 'ln', 'log',
    'sin', 'cos', 'tan', 'arcsin', 'arccos', 'arctan', 'degtorad', 'radtodeg',
    'trunc', 'pi', 'minx', 'maxx', 'mean', 'mod', 'point_distance',
    'point_direction', 'lengthdir_x', 'lengthdir_y', 'is_real', 'is_string',
    'chr', 'ord', 'string_replace', 'string_count', 'string_lower',
    'string_upper', 'string_letters', 'string_digits', '', '', '', '',
    'dayofweek', 'claqua', 'clblack', 'clblue', 'cldkgray', 'clfuchsia',
    'clgray', 'clgreen', 'cllime', 'clltgray', 'clmaroon', 'clnavy',
    'clolive', 'clpurple', 'clred', 'clsilver', 'clteal', 'clwhite',
    'clyellow', 'shownames', 'transparency', 'pathfinding', 'criminalactions',
    'eval', 'colortorgb', 'colortored', 'colortogreen', 'colortoblue',
    'ltrim', 'rtrim', 'trim', 'showscriptprocessing', 'stopscrunknowncommand',
    'showtimervar', 'div', 'regexp', 'hotkeystart', 'hotkeypause', 'homepath',
    'exefilename', 'windowhandle', 'rvpassword', '', 'rvwalkcount',
    'rvstayinsidecave', 'rvfisicalattack', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', 'timer1', 'timer2', 'timer3', 'timer4',
    'chartohex', 'chartohexf', 'moduleaddress', 'relativeaddress2absolute',
    'absoluteaddress2relative', '', 'clickoffsetx', 'clickoffsety',
    'findoffsetx', 'findoffsety', 'sendexdelay', '', 'emptylinedelay',
    'mouseclickdelay', 'arrayaddress', 'promptpos_x', 'promptpos_y',
    'loghandle', 'logautoopen', 'messagesoutputto', 'sendmessage',
    'postmessage', 'getimage', 'deleteimage', 'loadimage', 'saveimage',
    'getfocus', 'adddate', 'addyears', 'addmonths', 'adddays', 'addhours',
    'addminutes', 'addseconds', 'subdate', 'subyears', 'submonths', 'subdays',
    'subhours', 'subminutes', 'subseconds', 'yearfromdate', 'monthfromdate',
    'dayfromdate', 'hourfromdate', 'minutefromdate', 'secondfromdate',
    'timestamp', 'datenow', 'timenow', 'backpack', 'backpackposx',
    'backpackposy', 'scriptpath', 'scriptname', 'findmemory', 'terminated',
    'setprocesspriority', 'getprocesspriority', 'setprocessaffinitymask',
    'checkgetcolor', 'version', 'suspendprocess', 'resumeprocess', '');
  gCmdNames2b1: array[0..135] of string = (
    'continue', 'break', 'for', 'end_for', 'goto', 'gosub', 'return', 'else',
    'macro_load', 'macro_play', 'repeat', 'end_repeat', 'exec', 'terminate',
    'waitfortarget', 'wait', 'msg', 'say', 'send', 'sendex', 'left', 'right',
    'double_left', 'double_right', 'left_down', 'left_up', 'right_down',
    'right_up', 'move', 'drag', 'flash', 'alarm', 'end_script',
    'pause_script', 'resume_script', 'stop_script', 'start_script', 'call',
    'proc', 'end_proc', 'set', 'if', 'if_not', 'end_if', 'while', 'while_not',
    'end_while', ':', 'injection', 'get', 'load_array', 'save_array',
    'showwindow', 'kleft', 'kright', 'double_kleft', 'double_kright',
    'kleft_down', 'kleft_up', 'kright_down', 'kright_up', 'readmem',
    'writemem', 'printscreen', 'post', 'pleft', 'pright', 'double_pleft',
    'double_pright', 'pleft_down', 'pleft_up', 'pright_down', 'pright_up',
    'middle', 'double_middle', 'middle_down', 'middle_up', 'pmiddle',
    'double_pmiddle', 'pmiddle_down', 'pmiddle_up', 'kmiddle',
    'double_kmiddle', 'kmiddle_down', 'kmiddle_up', 'post_up', 'post_down',
    'send_up', 'send_down', 'sendex_up', 'sendex_down', 'wheel_down',
    'wheel_up', 'pwheel_down', 'pwheel_up', 'kwheel_down', 'kwheel_up',
    'load_script', 'hint', 'macro_send', 'execandwait', 'send217',
    'filerename', 'filecopy', 'filedelete', 'filesetattr', 'filesetdate',
    'dircreate', 'dirremove', 'dir', 'init_arr', 'log', 'eval', 'write',
    'switch', 'case', 'end_switch', 'send217_up', 'send217_down', 'exit',
    'test', 'pluginload', 'pluginreload', 'pluginunload', 'run_onload',
    'end_run', 'sort_array', 'delete_array', 'restart_script', 'move_smooth',
    'keyboard', 'mouse', 'servicegetstatus', 'servicestart', 'servicestop',
    'servicesend');
  gClVerNames: TClVerNamesZ = (
    '1.26.4a', '1.26.4b', '1.26.4e', '2.0.0', '2.0.0b', '2.0.3', '3.0.0c',
    '3.0.0g', '3.0.8', 'MU', 'MU 1.04J(3 сезон)', 'ML 6.0.7.0 p81',
    '6.0.12.3', '6.0.12.4', '6.0.13.0', '6.0.14.1', '6.0.14.2', '7.0.4.3',
    '7.0.4.4', '7.0.4.5', '7.0.5.0', '7.0.6.3', '7.0.18.0', 'custom');
  // Версии клиента: MU, < 2.0.3, 2.0.3-3.0.0, 3.0.8, ML6.0.7.0, ML6.0.12.3, ML7.0.4.3
  { 27 таблиц адресов памяти клиента, по строке на версию клиента.
    Индексный доступ к ним дают накладки ClientAddr и ClientAddr2,
    заведённые ниже, в разделе реализации. }
  gClT590778a8: array[0..24] of Cardinal = ($0050688C, $005089CC, $00505844, $0050CC42, $0050EEEA, $005474FF, $0055ED2B, $0055FDD3, $0059E563, $00000000, $00000000, $0060E2B5, $00612925, $00612925, $00612925, $00612925, $00612925, $006F7F0D, $006F6F0D, $006F7F0D, $006FAFBD, $006FBFBD, $00951FB8, $00000000, $00000000);
  gClT5907DCahr: array[0..24] of Cardinal = ($00C859DC, $00C87A8C, $00C8498C, $00C8C4C5, $00C8E8A5, $00CC9315, $00CE2C42, $00CE3CE2, $00D61ECA, $00000000, $00000000, $00839BD0, $0083CBE0, $0083CC00, $0083CC00, $0083CC00, $0083CC00, $009A8DC8, $009A7DC8, $009A8DC8, $009ABEA8, $009AFFB8, $00000000, $00000000, $00000000);
  gClT590840j4: array[0..24] of Cardinal = ($00506887, $005089C7, $0050583F, $0050CC3D, $0050EEE5, $005474FA, $0055ED26, $0055FDCE, $0059E55E, $00000000, $00000000, $0060E2AD, $0061291D, $0061291D, $0061291D, $0061291D, $0061291D, $006F7F05, $006F6F05, $006F7F05, $006FAFB5, $006FBFB5, $00000000, $00000000, $00000000);
  gClT5908A4av: array[0..24] of Cardinal = ($00506881, $005089C1, $00505839, $0050CC37, $0050EEDF, $005474F4, $0055ED20, $0055FDC8, $0059E558, $00000000, $00000000, $0060E2A7, $00612917, $00612917, $00612917, $00612917, $00612917, $006F7EFF, $006F6EFF, $006F7EFF, $006FAFAF, $006FBFAF, $00000000, $00000000, $00000000);
  gClT590908cx: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00CC4C64, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $007F7384, $007F73A4, $007F73A4, $007F73A4, $007F73A4, $009634DC, $009624DC, $009634DC, $009665BC, $0096A6CC, $00000000, $00000000, $00000000);
  gClT59096Cakx: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $008326E2, $00000000, $00000000, $00000000, $006D3B60, $006D3B80, $006D3B80, $006D3B80, $006D3B80, $0083EBA8, $0083DBA8, $0083EBA8, $00841C78, $00844C78, $00951FEE, $00000000, $00000000);
  gClT5909D0f9: array[0..24] of Cardinal = ($00000001, $00000001, $00000001, $00000001, $00000001, $00000002, $00000002, $00000002, $00000007, $00000010, $00000010, $00000003, $00000005, $00000005, $00000005, $00000005, $00000005, $00000006, $00000006, $00000006, $00000006, $00000006, $00000006, $00000000, $00000000);
  gClT590A34bv: array[0..24] of Cardinal = ($00C81A58, $00C83B08, $00C809E0, $00C88540, $00C8A8EC, $00C26164, $008CB1B4, $008CC254, $008F3124, $00000000, $00000000, $00000000, $007945B0, $007945D0, $007945D0, $007945D0, $007945D0, $008FF5FC, $008FE5FC, $008FF5FC, $009026CC, $009056CC, $004BB038, $00000000, $00000000);
  gClT590A98aq: array[0..24] of Cardinal = ($00CE3228, $00CD52D0, $00CE21D8, $00CD9D08, $00CDC118, $00D16B88, $00D2D1DC, $00D2E27C, $00DAC484, $00000000, $00000000, $00000000, $00874E38, $00874E58, $00874E58, $00874E58, $00874E58, $009E1100, $009E0100, $009E1100, $009E41E0, $009E82F0, $00AF56F0, $00000000, $00000000);
  gClT590AFCy: array[0..24] of Cardinal = ($00C7D2C0, $00C7F370, $00C7C270, $00C83B90, $00C85E94, $00CC0800, $00CD7DCC, $00CD8E6C, $00D55044, $08300A2C, $0759C980, $007F0EA0, $007F3EA0, $007F3EC0, $007F3EC0, $007F3EC0, $007F3EC0, $0095FE70, $0095EE70, $0095FE70, $00962F50, $009667F2, $00A73338, $00000000, $00000000);
  gClT590B60dt: array[0..24] of Cardinal = ($00C81864, $00C83914, $00C80814, $00C88348, $00C8A728, $00CC519C, $00CDE6C8, $00CDF768, $00D5D954, $0012AFC0, $00000000, $007F495C, $007F795C, $007F797C, $007F797C, $007F797C, $007F797C, $00963AB4, $00962AB4, $00963AB4, $00966B94, $0096ACA4, $00000000, $00000000, $00000000);
  gClT590BC4y2: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000001, $00000000, $00000000);
  gClT590C28o3: array[0..24] of Cardinal = ($00C7CF34, $00C7EFE4, $00C7BEE4, $00C83804, $00C85B04, $00CC045C, $00CD7A44, $00CD8AE4, $00D54CBC, $00000000, $00000000, $007F0984, $007F3984, $007F39A4, $007F39A4, $007F39A4, $007F39A4, $0095F954, $0095E954, $0095F954, $00962A34, $00965A34, $00A72E1C, $00000000, $00000000);
  gClT590C8Chr: array[0..24] of Cardinal = ($00C7CF38, $00C7EFE8, $00C7BEE8, $00C83808, $00C85B08, $00CC0460, $00CD7A48, $00CD8AE8, $00D54CC0, $00000000, $00000000, $007F0988, $007F3988, $007F39A8, $007F39A8, $007F39A8, $007F39A8, $0095F958, $0095E958, $0095F958, $00962A38, $00965A38, $00A72E20, $00000000, $00000000);
  gClT590CF0am: array[0..24] of Cardinal = ($00C81A6C, $00C83B1C, $00C80A1C, $00C88554, $00C8A934, $00CC53A4, $00CDECD8, $00CDFD78, $00D5DF60, $00000000, $00000000, $00835650, $00838660, $00838680, $00838680, $00838680, $00838680, $009A47B0, $009A37B0, $009A47B0, $009A7890, $009AB9A0, $00AB8DA0, $00000000, $00000000);
  gClT590D54e: array[0..24] of Cardinal = ($00C7CF2C, $00C7EFDC, $00C7BEDC, $00C837FC, $00C85AFC, $00CC0454, $00CD7A3C, $00CD8ADC, $00D54CB4, $00000000, $00000000, $007F097C, $007F397C, $007F399C, $007F399C, $007F399C, $007F399C, $0095F94C, $0095E94C, $0095F94C, $00962A2C, $00965A2C, $00A72E14, $00000000, $00000000);
  gClT590DB8y6: array[0..24] of Cardinal = ($00C7CF4C, $00C7EFFC, $00C7BEFC, $00C8381C, $00C85B1C, $00CC0474, $00CD7A5C, $00CD8AFC, $00D54CD4, $00000000, $00000000, $007F0990, $007F3990, $007F39B0, $007F39B0, $007F39B0, $007F39B0, $0095F960, $0095E960, $0095F960, $00962A40, $00965A40, $00A72E28, $00000000, $00000000);
  gClT590E1C3: array[0..24] of Cardinal = ($00C7CF50, $00C7F000, $00C7BF00, $00C83820, $00C85B20, $00CC0478, $00CD7A60, $00CD8B00, $00D54CD8, $00000000, $00000000, $007F0994, $007F3994, $007F39B4, $007F39B4, $007F39B4, $007F39B4, $0095F964, $0095E964, $0095F964, $00962A44, $00965A44, $00A72E2C, $00000000, $00000000);
  gClT590E80ep: array[0..24] of Cardinal = ($00C7CF44, $00C7EFF4, $00C7BEF4, $00C83814, $00C85B14, $00CC046C, $00CD7A54, $00CD8AF4, $00D54CCE, $00000000, $00000000, $007F0B1E, $007F3B1C, $007F3B3C, $007F3B3C, $007F3B3C, $007F3B3C, $0095FAEE, $0095EAEC, $0095FAEE, $00962BCC, $00965BBC, $00A72FB4, $00000000, $00000000);
  gClT590EE4fq: array[0..24] of Cardinal = ($00D24E10, $00000000, $00000000, $00000000, $00000000, $00D58780, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $008B6930, $008B6950, $008B6950, $008B6950, $008B6950, $00A23468, $00A22468, $00A23468, $00A26548, $00A2A658, $00B37A58, $00000000, $00000000);
  gClT590F48eh: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00CC535C, $00000000, $00000000, $00D5DF14, $00000000, $00000000, $00000000, $00838614, $00838636, $00838636, $00838636, $00838636, $0095FF0E, $0095E9C2, $0095FF0E, $009629BA, $009AB956, $00000000, $00000000, $00000000);
  gClT590FACbx: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00CC535C, $00000000, $00000000, $00D5DF14, $00000000, $00000000, $00000000, $00838614, $00838636, $00838636, $00838636, $00838636, $0095FF0E, $0095E9C2, $0095FF0E, $009629BA, $009AB956, $00000000, $00000000, $00000000);
  gClT591010ajm: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00CC9310, $00000000, $00000000, $00000000, $00000000, $00000000, $00839BDD, $0083CBED, $0083CC0D, $0083CC0D, $0083CC0D, $0083CC0D, $009A8DD5, $009A7DD5, $009A8DD5, $009ABEB5, $009AFFC5, $00000000, $00000000, $00000000);
  gClT591074cp: array[1..3, 0..24] of Cardinal = (
    ($00C7CF30, $00C7EFE0, $00C7BEE0, $00C83800, $00C85B00, $00CC0458, $00CD7A40, $00CD8AE0, $00D54CB8, $00000000, $00000000, $007F0980, $007F3980, $007F39A0, $007F39A0, $007F39A0, $007F39A0, $0095F950, $0095E950, $0095F950, $00962A30, $00965A30, $00A72E18, $00000000, $00000000),
    ($00C7CF3C, $00C7EFEC, $00C7BEEC, $00C8380C, $00C85B0C, $00CC0464, $00CD7A4C, $00CD8AEC, $00D54CC4, $00000000, $00000000, $4363C66A, $007F3958, $007F39AC, $007F39AC, $007F39AC, $007F39AC, $0095F95C, $0095E95C, $0095F95C, $00962A3C, $00965A3C, $00A72E24, $00000000, $00000000),
    ($00000000, $00000000, $00000000, $00000000, $00000000, $00CC4C44, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $007F7355, $007F7375, $007F7375, $007F7375, $007F7375, $009634AC, $009624AC, $009634AC, $0096658E, $0096A69E, $00000000, $00000000, $00000000));
  gClT5911A0dq: array[0..24] of Cardinal = ($00C7E9C8, $00C80A78, $00C7D978, $00C85330, $00C87638, $00CC1FA8, $00CDB4B8, $00CDC558, $00D58738, $00000000, $00000000, $007F16D0, $007F46D0, $007F46F0, $007F46F0, $007F46F0, $007F46F0, $00960700, $0095F700, $00960700, $009637E0, $009667E0, $00A73BC8, $00000000, $00000000);
  gClT591204ko: array[0..24] of Cardinal = ($00000000, $0126E2B2, $00000000, $0127E2B2, $00000000, $012BFD1A, $01473976, $01462DE6, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000);
  gClT591268lt: array[0..24] of Cardinal = ($00000000, $00000000, $00000000, $00000000, $00000000, $00CC535C, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000);

var
  gTempFilefv: string;                      // временный файл макроса
  gExeNameko: string;                       // имя своего файла
  gWikiPath: string;                      // каталог распакованной справки
  gAboutForm: TForm;
  // Вспомогательные окна: проверяются на nil/Visible в CanCloseOrActivate
  gDlg5966DC: TForm;
  gHelpForm: TForm;
  gDlg5966E4: TForm;
  gDlg5966E8: TForm;
  gDlg5966EC: TForm;
  gDlg5966F0: TForm;
  gDlg5966F4: TForm;
  gDlg5966F8c6: TForm;
  gDlg5966FC: TForm;
  // Диалоги, которые строятся кодом (TForm без DFM): заводятся лениво,
  // при первом показе.
  { Окно правки горячих клавиш: nil, пока не создано. }
  gDlg596700: TForm;
  gDlg596704: TForm;
  gDlg596708: TForm;
  gDlg59670C: TForm;
  gDlg596710: TForm;
  gDlg596714: TForm;
  gDlg596718: TForm;
  gDlg59671Ct7: TForm;
  gDlg596720: TForm;
  gDlg596724bt: TForm;
  gNtPmNumb4: Cardinal;
  gLogFilejr: TextFile;
const
  gHKDefNames: array[0..33] of string = (
    'hkScr', 'hkSScript', 'hkRec', 'hkRecStop', 'hkPlay', 'hkSNames',
    'hkMove_1', 'hk1', 'hk2', 'hk3', 'hk4', 'hk5', 'hkMes', 'hkUopUO',
    'hkMove_2', 'hkMove_3', 'hkSetMove_1', 'hkSetMove_2', 'hkSetMove_3',
    'hkPScript', 'hkCharParams', 'hkLockAllScriptToUO',
    'hkClipboardConsoleText', 'hkTransp', 'hkPathF', 'hkCrimAct', 'hkARun',
    'hkStopAllScript', 'hkSetWorkWindow', 'hkPauseAllScript',
    'hkStartAllScript', 'hkShowScriptProcessing', 'hkEnableAllHotKeys',
    'hkEnableKeyboard');
  gHKDefMods: array[0..33] of Byte = (
    0, 2, 2, 2, 2, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 0, 4, 6, 4, 2, 2,
    2, 2, 6, 4, 2, 6, 3, 4, 2);
  gHKDefTexts: array[0..33] of string = (
    'PrintScreen', 'Delete ', 'Insert', 'Home', 'End', 'Insert', 'C', '1',
    '2', '3', '4', '5', 'M', 'U', 'X', 'Z', 'C', 'X', 'Z', 'Pause', 'P', 'A',
    'Insert', '1', '2', '3', 'G', 'End', 'A', 'Pause', 'Home', 'S',
    'CapsLock', 'Home');

var
  gLogFileNamejr: string;                   // полный путь к uopilot.log
  gLogFileOpenar: Boolean;
  gLogFileClosedr: Boolean;
  gCoordCaptureddo: Boolean;
  gLogMaxSizehk: Integer;              // предел лога в 128-байтных единицах
  gProcImageer: TImage;                     // картинка окна прогресса
  gTextRange: Variant;                    // диапазон поиска в вики
  gServiceNamec: string;                   // имя службы
  gSvcRetakx: Integer;
const
  gHook591400: HHOOK = 0;
  gHook591404: HHOOK = 0;

var
  gSpeedObj: ^TObject;
function PrintWindow(hwnd: HWND; hdcBlt: HDC; nFlags: UINT): BOOL;
  stdcall; external 'user32.dll' name 'PrintWindow';

function GetPixel(DC: HDC; X, Y: Integer): COLORREF;
  stdcall; external 'gdi32.dll' name 'GetPixel';

var
  gAttriClass: TClass;               // ссылка на TAttriFontChange
  gOldHelpProc: TWndMethod;         // прежний WindowProc окна справки

procedure MsgBox(Text, Caption: PChar; Flags: Integer);
procedure UnhookHookB;
procedure UnhookHookA;
function KeyboardHookProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
procedure SetHookB;
function MouseHookProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
procedure SetHookA;
procedure WaitMilliseconds(S: string);
procedure MacroPause(S: string);
procedure MacroSendLine(S: string);
function ScanCommandMenu(M: TMenuItem): Boolean;
procedure DonePlugins(Form: TfmSecond; Name: string);
procedure LoadLuaLib(Form: TfmSecond);
procedure LoadPlugins(Form: TfmSecond; Only: string);
procedure AttachClientWindow;
procedure RegisterPlugin(Form: TfmSecond; const Name: string);
function HKLine(Pfx: ShortString; E: tHotKeyList): ShortString;
procedure SyncLogMsg;
function EnumStartUOWnd(H: HWND; L: LPARAM): Boolean; stdcall;
procedure WikiRefreshList(Form: TfmSecond);
function EnumKillWindowsProc(H: HWND; L: LPARAM): Boolean; stdcall;

implementation

uses
{$IFnDEF FPC}
  PsAPI, ScktComp, BrkrConst, HTTPApp, MSHTML,
{$ELSE}
{$ENDIF}
  sendR, MMSystem, SKey, fmFirst_u, WebLabel, MathEx, SynEditMiscClasses,
  Unit5,
  LZW_FolderActions, Masks, ProcessAPI,
  lualib, uCircleForm, AttriFont;

var
  gHotKeyMgr: THotKeyManager;
  gOldTabChange: TWndMethod;
  gHintPhase: Boolean;
  gHintTick: Integer;
  { Двенадцать чисел подряд: позиции и размеры вспомогательных окон.
    Читаются и пишутся циклом в AfterOptionsLoaded и miSaveOptionsClick. }
  gWinPos: array[0..11] of Integer;
  { Ширина и высота лежат в Right и Bottom, а не координаты угла. }
  gLogRect: TRect;
  gHelpRect: TRect;
  gTrayIcon: TNotifyIconData;        // структура иконки в трее
  gIconRun: HICON;
  gIconPause: HICON;
  gIconStop: HICON;
  gTrayBlink: Boolean;
  gInScriptTab: Boolean;             // сейчас открыта вкладка скрипта
  gFlag5969EE: Boolean;             // подавляет реакцию на смену вкладки
  gSavedWidth: Integer;
  gSavedHeight: Integer;
  { Шесть штук -- по числу пар btS0..btS5 / ec0..ec5 / tm0..tm5;
    индекс берётся из Tag кнопки. }
  gCalibrVals: array[0..5] of Integer;
  gWinHandles: array of Cardinal;         // окна из cbWinList
  gPanelPads: array[0..7] of Integer;
  gObjA34: TObject;
  gObjA38: TCriticalSection;
  gObjA3C: TCriticalSection;
  gFlag596A40: Boolean;             // проглотить следующий Backspace
  gOldLogProc: TWndMethod;
  gOldHelpProc2: TWndMethod;
  gOldCPProc: TWndMethod;
  gFlag596A5C: Integer;             // индекс переименовываемой вкладки, -1 = нет
  gStr596A60: string;                     // прежнее имя вкладки
  gWidth596A64: Integer;
  gMacroIndex: Integer;
  gMacroIni: TIniFile;
  gMouseMacros: array[1..22] of ToneButton;
  gMacroWnd: HWND;                  // окно для отправки макроса
  gMacroCols: Integer;
  gCount59AD80: Integer;
  gMacroThreadId: DWORD;
  gHKScript: Integer;
  gWikiThread: TWikiThread;

{ Накладки для индексного доступа к таблицам адресов клиента:
  absolute не заводит ни памяти, ни отдельной величины. }
var
  ClientAddr:  array[0..22, 0..24] of Cardinal absolute gClT590778a8;
  ClientAddr2: array[1..6,  0..24] of Cardinal absolute gClT591074cp;

procedure DownloadWikiPage(URL, FileName: string); forward;
procedure DrawGridCellText(Grid: TStringGrid; Cv: TCanvas;
      const R: TRect; const S: string; W: Word; B: ShortInt; C: ShortInt); forward;
function BuildHotKeyText(E: tHotKeyList): string; forward;
function RegisterHotKeyEntry(const E; S: string; var H: Integer;
  Sender: TObject; Mode: Byte): Boolean; forward;
function TryRegisterHotKey(Nm: ShortString; M: Byte;
  Key: ShortString; var Idx: Integer): Boolean; forward;
function HotKeyCaption(Nm: ShortString): ShortString; forward;
function LoadHotKeyEntry(Data, Nm: ShortString): Boolean; forward;





































// Приватные процедуры модуля (не методы формы).





















{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}



















































































































































































































































































































function SendKeyString(Wnd: Cardinal; S: string; Mode: Integer; Script: Pointer; Phase: Integer): Integer; forward;

function HKLine(Pfx: ShortString; E: tHotKeyList): ShortString;
begin
  // Тело не нужно: строку горячей клавиши собирает одноимённая
  // вложенная функция внутри miSaveOptionsClick.
end;

procedure SyncLogMsg;
begin
  // Тело живёт в TScanThread.SyncLogMsg (uScanThread).
end;

procedure TfmSecond.miSaveOptionsClick(Sender: TObject);
var
  Sect: string;
  S: string;
  Ident: string;
  Ini: TMyMemIniFile;
  Reg: TRegistry;
  I, N, Rep: Integer;
  { Собирает строку горячей клавиши для ini:
    '<Вкл>,<Подпись>,<Shift>,<Alt>,<Ctrl>,<Удержание>,<Звук>'.
    Парная к LoadHotKeyEntry. }
  function HKLine(Nm: ShortString; E: tHotKeyList): ShortString;
  type
    THKMod = (hkShift, hkAlt, hkCtrl);
    THKMods = set of THKMod;
  var
    M: ShortString;
    B: ShortString;
    Sep: ShortString;
  begin
    M := '0,0,0';
    Nm := E.Name;
    if hkShift in THKMods(E.Mods) then
      M[1] := '1';
    if hkAlt in THKMods(E.Mods) then
      M[3] := '1';
    if hkCtrl in THKMods(E.Mods) then
      M[5] := '1';
    if FindComponent('cb' + Nm) <> nil then
      B := BoolStr((FindComponent('cb' + Nm) as TCheckBox).Checked)
    else
      B := BoolStr(E.Enabled);
    Sep := ',0';
    if (gHKScript >= 0) and (gScriptso3[gHKScript] <> nil) and
      gScriptso3[gHKScript].HoldKey then
      Sep := ',1';
    Nm := E.Text;
    Result := B + ',' + Nm + ',' + M + Sep + ',' + E.Sound;
  end;

begin
  { Запись всех настроек в ini: одиннадцать секций подряд, между ними
    Sect переприсваивается литералом. }
  if not FFlag14E4 then
  begin
    SetForegroundWindow(Application.Handle);
    MsgBox('Settings not loaded correctly. Not saved.', 'UOPilot Error Message', 0);
    Exit;
  end;
  Ini := TMyMemIniFile.Create(FOptionsFile);
  Sect := 'UoPilot';
  { Галочки пакуются в битовое поле. }
  Ini.WriteInteger(Sect, 'SaveWinPosition',
    Ord(miSPosAC.Checked) shl 5 + Ord(miSPosHC.Checked) shl 4 +
    Ord(miSPosSC.Checked) shl 3 + Ord(miSPosUoP.Checked) shl 2 +
    Ord(miSPosCP.Checked) shl 1 + Ord(miSPosS.Checked));
  Ini.WriteInteger(Sect, 'SOT',
    Ord(cbSOT.Checked) shl 5 + Ord(miSOTShipControl.Checked) shl 4 +
    Ord(miSOTHouseControl.Checked) shl 3 + Ord(miSOTScriptWindow.Checked) shl 2 +
    Ord(miSOTCharParameters.Checked) shl 1 + Ord(miSOTAnimalVendor.Checked));
  Ini.WriteBool(Sect, 'SOTLogWindow', miSOTLogWindow.Checked);
  Ini.WriteInteger(Sect, 'Top', fmSecondfj.Top);
  Ini.WriteInteger(Sect, 'Left', fmSecondfj.Left);
  if gDlg5966F0 <> nil then
  begin
    gWinPos[0] := gDlg5966F0.Top;
    gWinPos[1] := gDlg5966F0.Left;
  end;
  Ini.WriteInteger(Sect, 'CParamsTop', gWinPos[0]);
  Ini.WriteInteger(Sect, 'CParamsLeft', gWinPos[1]);
  if gDlg5966EC <> nil then
  begin
    gWinPos[2] := gDlg5966EC.Top;
    gWinPos[3] := gDlg5966EC.Left;
    gWinPos[4] := gDlg5966EC.Height;
    gWinPos[5] := gDlg5966EC.Width;
  end;
  if gDlg5966E8 <> nil then
  begin
    gWinPos[6] := gDlg5966E8.Top;
    gWinPos[7] := gDlg5966E8.Left;
  end;
  if gDlg5966E4 <> nil then
  begin
    gWinPos[8] := gDlg5966E4.Top;
    gWinPos[9] := gDlg5966E4.Left;
  end;
  if gDlg5966F4 <> nil then
  begin
    gWinPos[10] := gDlg5966F4.Top;
    gWinPos[11] := gDlg5966F4.Left;
  end;
  { BoundsRect присваивается целиком; Right и Bottom тут же превращаются
    в ширину и высоту. }
  if gDlg5966F8c6 <> nil then
  begin
    gLogRect := gDlg5966F8c6.BoundsRect;
    gLogRect.Bottom := gLogRect.Bottom - gLogRect.Top;
    gLogRect.Right := gLogRect.Right - gLogRect.Left;
    Ini.WriteString(Sect, 'LogPos',
      IntToStr(gLogRect.Left) + ',' + IntToStr(gLogRect.Top) + ',' +
      IntToStr(gLogRect.Right) + ',' + IntToStr(gLogRect.Bottom));
  end;
  if gHelpForm <> nil then
  begin
    gHelpRect := gHelpForm.BoundsRect;
    gHelpRect.Bottom := gHelpRect.Bottom - gHelpRect.Top;
    gHelpRect.Right := gHelpRect.Right - gHelpRect.Left;
    Ini.WriteString(Sect, 'HelpPos',
      IntToStr(gHelpRect.Left) + ',' + IntToStr(gHelpRect.Top) + ',' +
      IntToStr(gHelpRect.Right) + ',' + IntToStr(gHelpRect.Bottom));
  end;
  Ini.WriteInteger(Sect, 'SEditorTop', gWinPos[2]);
  Ini.WriteInteger(Sect, 'SEditorLeft', gWinPos[3]);
  Ini.WriteInteger(Sect, 'SEditorHeight', gWinPos[4]);
  Ini.WriteInteger(Sect, 'SEditorWidth', gWinPos[5]);
  Ini.WriteInteger(Sect, 'HouseControlTop', gWinPos[6]);
  Ini.WriteInteger(Sect, 'HouseControlLeft', gWinPos[7]);
  Ini.WriteInteger(Sect, 'ShipControlTop', gWinPos[8]);
  Ini.WriteInteger(Sect, 'ShipControlLeft', gWinPos[9]);
  Ini.WriteInteger(Sect, 'AnimalControlTop', gWinPos[10]);
  Ini.WriteInteger(Sect, 'AnimalControlLeft', gWinPos[11]);
  Ini.WriteInteger(Sect, 'AutoOpenWin', Ord(miAutoOpenCP.Checked) shl 1);
  Ini.WriteBool(Sect, 'ShowScriptNames', miShowSFNames.Checked);
  Ini.WriteBool(Sect, 'ShowRuningScript', miShowRuningScript.Checked);
  Ini.WriteBool(Sect, 'ShowRuningScriptOnTaskbar', miShowRuningScriptOnTaskbar.Checked);
  Ini.WriteBool(Sect, 'ShowScriptNamesOnTabs', cbShowScriptNamesOnTabs.Checked);
  Ini.WriteBool(Sect, 'ShowUnsavedScripts', cbShowUnsavedScripts.Checked);
  Ini.WriteInteger(Sect, 'ShowStat',
    Byte(cbDrinkTimer.Checked) shl 7 + Ord(cbHits.Checked) shl 6 +
    Ord(cbMana.Checked) shl 5 + Ord(cbStam.Checked) shl 4 +
    Ord(cbGold.Checked) shl 3 + Ord(cbWght.Checked) shl 2 +
    Ord(cbAr.Checked) shl 1 + Ord(cbShowCoords.Checked));
  Rep := semiRepeat.Value;
  if N20.Checked then
    Rep := -Rep;
  Ini.WriteInteger(Sect, 'MacrosRepCount', Rep);
  Ini.WriteInteger(Sect, 'ShowCoordsInCaption',
    Byte(miSKRel.Checked) + Byte(miSKAbs.Checked) shl 1);
  Ini.WriteBool(Sect, 'SaveOnExit', miSaveOnExit.Checked);
  Ini.WriteBool(Sect, 'StopUnknownCommand', miStopSUncC.Checked);
  Ini.WriteInteger(Sect, 'ShowCharParamsScript',
    Byte(miSCPtopuo.Checked) + Byte(miSCPuop.Checked) shl 1);
  Ini.WriteBool(Sect, 'ShowHex', miShowHex.Checked);
  Ini.WriteBool(Sect, 'MoveMouseBack', miMoveMouseBack.Checked);
  Ini.WriteBool(Sect, 'MoveMouseBeforeClick', miMoveMouseBeforeClick.Checked);
  Ini.WriteBool(Sect, 'UseKleft217', miUseKleft217.Checked);
  Rep := Byte(sbCFCP8.Down) shl 6 + Byte(sbCFCP7.Down) shl 5 +
    Byte(sbCFCP1.Down) shl 4 + Byte(sbCFCP2.Down) shl 3 +
    Byte(sbCFCP3.Down) shl 2 + Byte(sbCFCP4.Down) shl 1 +
    Byte(sbCFCP5.Down);
  Ini.WriteInteger(Sect, 'TypeCharParamsForm', Rep);
  Ini.WriteInteger(Sect, 'ErrorReadCP',
    Byte(miInformErrorRead.Checked) shl 2 + Byte(miPauseSErrorRead.Checked) shl 1 +
    Byte(miStopSErrorRead.Checked));
  Ini.WriteBool(Sect, 'MinToTray', miMinToTray.Checked);
  Ini.WriteBool(Sect, 'StartMinimized', miStartMinimized.Checked);
  Ini.WriteBool(Sect, 'GMPageAlarm', cbGMPageAlarm.Checked);
  Ini.WriteInteger(Sect, 'ScriptHeight', fmSecondfj.Height);
  Ini.WriteInteger(Sect, 'ScriptWidth', fmSecondfj.Width);
  Ini.WriteBool(Sect, 'ShowAllWindows', miShowAllWindows.Checked);
  Ini.WriteBool(Sect, 'SortSkillList', miSortSkillList.Checked);
  Ini.WriteInteger(Sect, 'WivVer', cbNtUserPM.ItemIndex);
  Ini.WriteBool(Sect, 'RenameSelf', miRenameSelf.Checked);
  Ini.WriteString(Sect, 'RenameSelfTo', eRenameSelf.Text);
  Ini.WriteBool(Sect, 'Logging', miLogging.Checked);
  SaveUoPilotSection(Ini, Sect);
  Ini.WriteString(Sect, 'LogFont', FontToStr(pLog.Font, ','));
  Ini.WriteInteger(Sect, 'LogLimitMb', gLogMaxSizehk div 8192);
  Ini.WriteBool(Sect, 'miShowHelpOnTaskbar', miShowHelpOnTaskbar.Checked);
  Ini.WriteBool(Sect, 'ShowRemainingWait', miShowRemainingWait.Checked);
  Ini.WriteBool(Sect, 'AutoOpenLog', miAutoOpenLog.Checked);
  Ini.WriteInteger(Sect, 'OutputMessagesTo',
    Byte(miToMessageBox.Checked) shl 1 + Ord(miToHint.Checked));
  Ini.WriteBool(Sect, 'OutputMessagesToLogAlso', miToLog.Checked);
  Ini.WriteBool(Sect, 'HideUOSettings', cbHideUOSettings.Checked);
  Ini.WriteString(Sect, 'FindImagePos',
    IntToStr(gDlg59671Ct7.Left) + ',' + IntToStr(gDlg59671Ct7.Top) + ',' +
    IntToStr(gDlg59671Ct7.ClientWidth) + ',' + IntToStr(gDlg59671Ct7.ClientHeight));
  Ini.WriteString(Sect, 'LuaLibName', gLuaLibNameCow);
  Ini.WriteString(Sect, 'ServiceName', gServiceNamec);
  Ini.WriteBool(Sect, 'CheckGetImage', cbCheckGetImage.Checked);
  Sect := 'Client';
  Ini.WriteString(Sect, 'Version', cbClVer.Text);
  Ini.WriteInteger(Sect, 'Number', cbClVer.ItemIndex);
  Ini.WriteInteger(Sect, 'UOPriority', tbUOPriority.Position);
  Ini.WriteBool(Sect, 'StartUOMinimized', cbSUOMin.Checked);
  Ini.WriteBool(Sect, 'StartUOOnly', StartUOOnly.Checked);
  { Пустой except: на ограниченной учётке запись в HKLM падает, и это
    не повод ронять сохранение. }
  try
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey('\Software\Origin Worlds Online\Ultima Online\1.0', True) then
    begin
      Reg.WriteString('ExePath', eSUO.Text);
      Reg.WriteString('InstCDPath', ExtractFilePath(eSUO.Text));
    end;
    Reg.CloseKey;
    Reg.Destroy;
  except
  end;
  Sect := 'Click';
  Ini.WriteInteger(Sect, 'Mouse', cb0.ItemIndex);
  Ini.WriteString(Sect, 'Interval_m', ed0.Text);
  Ini.WriteString(Sect, 'Coords', btS0.Caption);
  Ini.WriteInteger(Sect, 'Key_1', cb1.ItemIndex);
  Ini.WriteString(Sect, 'Interval_k1', ed1.Text);
  Ini.WriteBool(Sect, 'SendBS_k1', cbS1.Checked);
  Ini.WriteInteger(Sect, 'Key_2', cb2.ItemIndex);
  Ini.WriteString(Sect, 'Interval_k2', ed2.Text);
  Ini.WriteBool(Sect, 'SendBS_k2', cbS2.Checked);
  Ini.WriteInteger(Sect, 'Key_3', cb3.ItemIndex);
  Ini.WriteString(Sect, 'Interval_k3', ed3.Text);
  Ini.WriteBool(Sect, 'SendBS_k3', cbS3.Checked);
  Ini.WriteInteger(Sect, 'Key_4', cb4.ItemIndex);
  Ini.WriteString(Sect, 'Interval_k4', ed4.Text);
  Ini.WriteBool(Sect, 'SendBS_k4', cbS4.Checked);
  Ini.WriteInteger(Sect, 'Key_5', cb5.ItemIndex);
  Ini.WriteString(Sect, 'Interval_k5', ed5.Text);
  Ini.WriteBool(Sect, 'SendBS_k5', cbS5.Checked);
  Ini.WriteString(Sect, 'Quantity_m', ec0.Text);
  Ini.WriteString(Sect, 'Quantity_k1', ec1.Text);
  Ini.WriteString(Sect, 'Quantity_k2', ec2.Text);
  Ini.WriteString(Sect, 'Quantity_k3', ec3.Text);
  Ini.WriteString(Sect, 'Quantity_k4', ec4.Text);
  Ini.WriteString(Sect, 'Quantity_k5', ec5.Text);
  Sect := 'Screen_saver';
  Ini.WriteBool(Sect, 'Date', cbDate.Checked);
  Ini.WriteBool(Sect, 'Jpg', rbJpg.Checked);
  Ini.WriteInteger(Sect, 'Jpg_quality', SpinEdit1.Value);
  Ini.WriteString(Sect, 'Path', edScr.Text);
  Ini.WriteInteger(Sect, 'ScreenType',
    Byte(miSaveScrActiweWindow.Checked) shl 2 +
    Byte(miSaveScrWorkWindow.Checked) shl 1 +
    Byte(miSaveScrAllScreen.Checked));
  Sect := 'Script';
  Ini.WriteInteger(Sect, 'ScriptPriority', tbScriptPriority.Position);
  Ini.WriteInteger(Sect, 'InsertXY',
    Byte(cbInsertXY.Checked) + Byte(cbInsertXYabs.Checked) shl 1);
  Ini.WriteBool(Sect, 'Det_color', CBInsertColor.Checked);
  Ini.WriteBool(Sect, 'Add_Space', miAddSp.Checked);
  { Шесть одинаковых циклов: столбцы двух сеток склеиваются через запятую. }
  S := '';
  for I := 1 to sgLastObject.RowCount do
    S := S + sgLastObject.Cells[0, I - 1] + ',';
  Ini.WriteString(Sect, 'LastObjectNum', S);
  S := '';
  for I := 1 to sgLastObject.RowCount do
    S := S + sgLastObject.Cells[1, I - 1] + ',';
  Ini.WriteString(Sect, 'LastObject', S);
  S := '';
  for I := 1 to sgLastObject.RowCount do
    S := S + sgLastObject.Cells[2, I - 1] + ',';
  Ini.WriteString(Sect, 'LastObjectDesc', S);
  S := '';
  for I := 1 to sgLastTarget.RowCount do
    S := S + sgLastTarget.Cells[0, I - 1] + ',';
  Ini.WriteString(Sect, 'LastTargetNum', S);
  S := '';
  for I := 1 to sgLastTarget.RowCount do
    S := S + sgLastTarget.Cells[1, I - 1] + ',';
  Ini.WriteString(Sect, 'LastTarget', S);
  S := '';
  for I := 1 to sgLastTarget.RowCount do
    S := S + sgLastTarget.Cells[2, I - 1] + ',';
  Ini.WriteString(Sect, 'LastTargetDesc', S);
  SaveScriptSection(Ini, Sect);
  Ini.WriteInteger(Sect, 'FontColor', edScript.Font.Color);
  Ini.WriteInteger(Sect, 'FontSize', gEditorFontSize);
  Ini.WriteString(Sect, 'FontName', gEditorFontName);
  Ini.WriteInteger(Sect, 'FontSizeSyn', gLogFontSize);
  Ini.WriteString(Sect, 'FontNameSyn', gLogFontName);
  { Стиль пакуется по одному биту: каждый шаг -- сдвиг накопителя и or. }
  Ini.WriteInteger(Sect, 'FontStyle',
    (((Byte(fsBold in edScript.Font.Style) shl 1 or
       Byte(fsItalic in edScript.Font.Style)) shl 1 or
       Byte(fsUnderline in edScript.Font.Style)) shl 1) or
       Byte(fsStrikeOut in edScript.Font.Style));
  Ini.WriteInteger(Sect, 'TabSize', seTabSize.Value);
  Ini.WriteString(Sect, 'ScriptDelayDef', eScriptDelayDef.Text);
  Ini.WriteString(Sect, 'PauseNil', edPauseNil.Text);
  Ini.WriteBool(Sect, 'ShowScriptProcessing', miShowScriptProcessing.Checked);
  Ini.WriteBool(Sect, 'LockOnStartup', miLockOnStartup.Checked);
  Ini.WriteBool(Sect, 'PauseSOnClientClose', miPauseSOnClientClose.Checked);
  Ini.WriteBool(Sect, 'ShowTimerVariable', miShowTimerVar.Checked);
  Ini.WriteInteger(Sect, 'SendExDelayDef', seSendExDelayDef.Value);
  Ini.WriteInteger(Sect, 'MouseClickDelay', seMouseClicksDelay.Value);
  Ini.WriteBool(Sect, 'Knopusechki', FFlag1464);
  Ini.WriteBool(Sect, 'GutterVisible', miGutterVisible.Checked);
  Ini.WriteBool(Sect, 'SaveScriptsOnExit', miSaveScriptsOnExit.Checked);
  Ini.WriteBool(Sect, 'ShowCommandHint', miShowCommandHint.Checked);
  Ini.WriteBool(Sect, 'SaveScriptsOnRun', miSaveScriptsOnRun.Checked);
  Ini.WriteBool(Sect, 'CommentOnClick', cbCommentOnClick.Checked);
  Ini.WriteBool(Sect, 'CommentOnSelect', cbCommentOnSelect.Checked);
  Sect := 'Alarm';
  Ini.WriteInteger(Sect, 'Hour', SEHour.Value);
  Ini.WriteInteger(Sect, 'Min', SEMinutes.Value);
  Ini.WriteString(Sect, 'Delay', eBudilnikDelay.Text);
  Sect := 'Auto_Move';
  Ini.WriteString(Sect, 'Coords', sbAMove_1.Caption);
  Ini.WriteString(Sect, 'Coords2', sbAMove_2.Caption);
  Ini.WriteString(Sect, 'Coords3', sbAMove_3.Caption);
  Ini.WriteBool(Sect, 'MoveMouse', cbMoveLeftCl.Checked);
  Ini.WriteString(Sect, 'Delay', Edit1.Text);
  Ini.WriteString(Sect, 'DelayAfterEnter', Edit2.Text);
  Ini.WriteBool(Sect, 'SaveCount', miAMoveCount.Checked);
  if miAMoveCount.Checked then
  begin
    Ini.WriteInteger(Sect, 'MoveCount1', seAmove1.Value);
    Ini.WriteInteger(Sect, 'MoveCount2', seAmove2.Value);
    Ini.WriteInteger(Sect, 'MoveCount3', seAmove3.Value);
  end;
  Ini.WriteBool(Sect, 'StoD1', cbStoD1.Checked);
  Ini.WriteBool(Sect, 'StoD2', cbStoD2.Checked);
  Ini.WriteBool(Sect, 'StoD3', cbStoD3.Checked);
  Sect := 'HouseMenu';
  Ini.WriteString(Sect, 'LockDown', gHouseCmds[1]);
  Ini.WriteString(Sect, 'Secure', gHouseCmds[2]);
  Ini.WriteString(Sect, 'Release', gHouseCmds[3]);
  Ini.WriteString(Sect, 'Ban', gHouseCmds[4]);
  Ini.WriteString(Sect, 'Trash', gHouseCmds[5]);
  Ini.WriteString(Sect, 'Remove', gHouseCmds[6]);
  Ini.WriteString(Sect, 'Strongbox', gHouseCmds[7]);
  Sect := 'Hotkeys';
  Ini.WriteBool(Sect, 'EnableHK', cbEnableHK.Checked);
  gHKScript := -1;
  if cbEnableHK.Checked then
  begin
    { Первые $22 записей -- общие клавиши: ключ = имя компонента без 'cb'. }
    for I := 0 to $21 do
      Ini.WriteString(Sect, Copy(gHKEntrieslw[I].Name, 3, 57),
        HKLine('', gHKEntrieslw[I]));
    { Дальше -- по две клавиши на каждую строку списка скриптов; номер
      скрипта берётся из столбца 1, а чётность I выбирает первую или
      вторую клавишу пары. }
    for I := 0 to sghkScriptHKList.RowCount * 2 - 1 do
    begin
      N := StrToInt(sghkScriptHKList.Cells[1, I div 2]) * 2 + $22 + I mod 2;
      if gHKEntrieslw[N].Name <> '' then
      begin
        if I = I div 2 * 2 then
          gHKScript := StrToInt(sghkScriptHKList.Cells[1, I div 2]);
        S := HKLine('', gHKEntrieslw[N]);
        Ident := gHKEntrieslw[N].Name;
        Delete(Ident, 1, 2);
        Ini.WriteString(Sect, Ident, S);
      end;
    end;
  end;
  Ini.WriteBool(Sect, 'TransparentHotKeys', miTransparentHotKeys.Checked);
  Sect := 'CustomClient';
  { Ключи и поля тут разъехались на одну позицию. }
  Ini.WriteInteger(Sect, 'AlwaysRun', EoffAlwaysRun.Value);
  Ini.WriteInteger(Sect, 'CP', EoffCP.Value);
  Ini.WriteInteger(Sect, 'CharDir', EoffCharDir.Value);
  Ini.WriteInteger(Sect, 'ConsoleUnicodeText', EoffConsoleUnicodeText.Value);
  Ini.WriteInteger(Sect, 'Coords', EoffCoords.Value);
  Ini.WriteInteger(Sect, 'Crim', EoffCrim.Value);
  Ini.WriteInteger(Sect, 'Fontcolor', EoffFontcolor.Value);
  Ini.WriteInteger(Sect, 'Hidden_War', EoffHidden_War.Value);
  Ini.WriteInteger(Sect, 'LastMess', EoffLMess.Value);
  Ini.WriteInteger(Sect, 'LastLiftedID', EoffLastLiftedID.Value);
  Ini.WriteInteger(Sect, 'LastOb', EoffLastObTar1.Value);
  Ini.WriteInteger(Sect, 'LastTar', EoffLastObTar2.Value);
  Ini.WriteInteger(Sect, 'LastObjectType', EoffLastObjectType.Value);
  Ini.WriteInteger(Sect, 'LastSkill', EoffLastSkill.Value);
  Ini.WriteInteger(Sect, 'LastSpell', EoffLastSpell.Value);
  Ini.WriteInteger(Sect, 'LastStaticType', EoffLastStaticType.Value);
  Ini.WriteInteger(Sect, 'LastTargetKind', EoffLastTargetKind.Value);
  Ini.WriteInteger(Sect, 'LastTargetXYZ', EoffLastTargetXYZ.Value);
  Ini.WriteInteger(Sect, 'LastSpellStartNum', EoffName.Value);
  Ini.WriteInteger(Sect, 'Name', EoffPathF.Value);
  Ini.WriteInteger(Sect, 'PathF', EoffSkills.Value);
  Ini.WriteInteger(Sect, 'Skills', EoffTarget.Value);
  Ini.WriteInteger(Sect, 'Target', EoffTrans.Value);
  Ini.WriteInteger(Sect, 'Trans', EoffWght.Value);
  Ini.WriteInteger(Sect, 'Wght', ELastSpellStartNum.Value);
  Ini.WriteInteger(Sect, 'ClVer', cbCustomClVer.ItemIndex);
  Ini.WriteInteger(Sect, 'Backpack', EoffBackpack.Value);
  { Цвета и списки слов подсветки уходят в ту же ini. }
  SaveHighlighter(fld_1428, Ini);
  Sect := 'LoggingErrors';
  Ini.WriteBool(Sect, 'clrinvalid', miELclrinvalid.Checked);
  Ini.WriteBool(Sect, 'FileOpError', miFileOpError.Checked);
  Ini.WriteBool(Sect, 'SetHKError', miSetHKError.Checked);
  Ini.WriteBool(Sect, 'PluginLoadError', miPluginLoadError.Checked);
  Ini.Free;
  if (gDlg596704 <> nil) and gDlg596704.Visible then
    miOptionsClick(Sender);
end;

procedure LoadLuaLib(Form: TfmSecond);
var
  Sect: string;
  Def: string;
  Ini: TMyMemIniFile;
  RS: TResourceStream;
begin
  { Имя библиотеки Lua берётся из ini, а если файла нет -- достаётся
    из собственных ресурсов (RT_RCDATA, номера 51 и 151). }
  Ini := TMyMemIniFile.Create(Form.FOptionsFile);
  Sect := 'UoPilot';
  Def := 'lua5.1.dll';
  gLuaLibNameCow := Ini.ReadString(Sect, 'LuaLibName', '');
  if gLuaLibNameCow = '' then
  begin
    if FileExists(Def) then
      gLuaLibNameCow := Def
    else
    begin
      gLuaLibNameCow := 'lua.dll';
      if not FileExists(gLuaLibNameCow) then
        gLuaLibNameCow := Def;
    end;
  end;
  if not FileExists(gLuaLibNameCow) then
  begin
    gLuaLibNameCow := Def;
    try
      RS := TResourceStream.CreateFromID(HInstance, $33, RT_RCDATA);
      RS.SaveToFile(ExtractFilePath(ParamStr(0)) + gLuaLibNameCow);
      RS.Free;
      RS := TResourceStream.CreateFromID(HInstance, $97, RT_RCDATA);
      RS.SaveToFile(ExtractFilePath(ParamStr(0)) + 'libgcc_s_dw2-1.dll');
      RS.Free;
    except
    end;
  end;
  Ini.Free;
end;

function LoadHotKeyEntry(Data, Nm: ShortString): Boolean;
var
  I: Integer;
  Hold: Boolean;
  En: Boolean;
const
  ModNone = [];
  ModShift = [hkShift];
  ModAlt = [hkAlt];
  ModCtrl = [hkCtrl];
var
  Mods: THKMods;
begin
  { Разбор строки настройки горячей клавиши из секции [Hotkeys]:
    '<Вкл>,<Подпись>,<Shift>,<Alt>,<Ctrl>,<Удержание>,<Звук>'.
    Оба параметра -- значениевые ShortString, и оба портятся по дороге. }
  En := StrIsTrue(Copy(Data, 1, Pos(',', Data) - 1));
  Nm := 'hk' + Nm;
  Delete(Data, 1, Pos(',', Data));
  for I := 0 to Length(gHKEntrieslw) - 1 do
    if CompareText(Nm, gHKEntrieslw[I].Name) = 0 then
      Break;
  if I >= Length(gHKEntrieslw) then
  begin
    SetLength(gHKEntrieslw, Length(gHKEntrieslw) + 1);
    I := Length(gHKEntrieslw) - 1;
  end;
  if Copy(Data, 1, Pos(',', Data) - 1) <> '' then
  begin
    gHKEntrieslw[I].Name := Nm;
    gHKEntrieslw[I].Text := Copy(Data, 1, Pos(',', Data) - 1);
    Delete(Data, 1, Pos(',', Data));
    Mods := ModNone;
    if Data[1] = '1' then
      Mods := Mods + ModShift;
    if Data[3] = '1' then
      Mods := Mods + ModAlt;
    if Data[5] = '1' then
      Mods := Mods + ModCtrl;
    gHKEntrieslw[I].Mods := Mods;
    if Length(Data) >= 7 then
      Hold := Data[7] = '1'
    else
      Hold := False;
    if (gHKScript >= 0) and (gScriptso3[gHKScript] <> nil) then
      gScriptso3[gHKScript].HoldKey := Hold;
    Delete(Data, 1, 8);
    gHKEntrieslw[I].Sound := Data;
  end
  else
    En := False;
  gHKEntrieslw[I].Enabled := En;
  Result := En;
end;

procedure TfmSecond.AfterOptionsLoaded;
var
  Sect: string;
  Ini: TMyMemIniFile;
  Ln: string;
  PID: DWORD;
  S: string;
  S2: string;
  S3: string;
  B: Boolean;
  FS: TFontStyles;
  L: TStringList;
  V: TMyStr;
  I, J, K: Integer;
  MI, NewMI: TMenuItem;
begin
  Ini := TMyMemIniFile.Create(FOptionsFile);
  gHKScript := -1;
  Sect := 'UoPilot';
  I := Ini.ReadInteger(Sect, 'SaveWinPosition', 0);
  miSPosS.Checked := (I and 1) = 1;
  I := I shr 1;
  miSPosCP.Checked := (I and 1) = 1;
  I := I shr 1;
  miSPosUoP.Checked := (I and 1) = 1;
  I := I shr 1;
  miSPosSC.Checked := (I and 1) = 1;
  I := I shr 1;
  miSPosHC.Checked := (I and 1) = 1;
  I := I shr 1;
  miSPosAC.Checked := (I and 1) = 1;
  I := Ini.ReadInteger(Sect, 'SOT', $1F);
  miSOTAnimalVendor.Checked := (I and 1) = 1;
  I := I shr 1;
  miSOTCharParameters.Checked := (I and 1) = 1;
  I := I shr 1;
  miSOTScriptWindow.Checked := (I and 1) = 1;
  I := I shr 1;
  miSOTHouseControl.Checked := (I and 1) = 1;
  I := I shr 1;
  miSOTShipControl.Checked := (I and 1) = 1;
  I := I shr 1;
  cbSOT.Checked := (I and 1) = 1;
  miSOTLogWindow.Checked := Ini.ReadBool(Sect, 'SOTLogWindow', True);
  if miSPosUoP.Checked then
  begin
    I := Ini.ReadInteger(Sect, 'Top', -1);
    J := Ini.ReadInteger(Sect, 'Left', -1);
    if (I > -1) and (J > -1) then
    begin
      fmSecondfj.Position := poDesigned;
      fmSecondfj.Top := I;
      fmSecondfj.Left := J;
    end;
  end;
  gWinPos[0] := Ini.ReadInteger(Sect, 'CParamsTop', -1);
  gWinPos[1] := Ini.ReadInteger(Sect, 'CParamsLeft', -1);
  gWinPos[2] := Ini.ReadInteger(Sect, 'SEditorTop', -1);
  gWinPos[3] := Ini.ReadInteger(Sect, 'SEditorLeft', -1);
  gWinPos[4] := Ini.ReadInteger(Sect, 'SEditorHeight', -1);
  gWinPos[5] := Ini.ReadInteger(Sect, 'SEditorWidth', -1);
  gWinPos[6] := Ini.ReadInteger(Sect, 'HouseControlTop', -1);
  gWinPos[7] := Ini.ReadInteger(Sect, 'HouseControlLeft', -1);
  gWinPos[8] := Ini.ReadInteger(Sect, 'ShipControlTop', -1);
  gWinPos[9] := Ini.ReadInteger(Sect, 'ShipControlLeft', -1);
  gWinPos[10] := Ini.ReadInteger(Sect, 'AnimalControlTop', -1);
  gWinPos[11] := Ini.ReadInteger(Sect, 'AnimalControlLeft', -1);
  S := Ini.ReadString(Sect, 'LogPos', '-1,-1,-1,-1');
  I := Pos(',', S);
  gLogRect.Left := StrToInt(Copy(S, 1, I - 1));
  Delete(S, 1, I);
  I := Pos(',', S);
  gLogRect.Top := StrToInt(Copy(S, 1, I - 1));
  Delete(S, 1, I);
  I := Pos(',', S);
  gLogRect.Right := StrToInt(Copy(S, 1, I - 1));
  Delete(S, 1, I);
  gLogRect.Bottom := StrToInt(S);
  S := Ini.ReadString(Sect, 'HelpPos', '-1,-1,-1,-1');
  I := Pos(',', S);
  gHelpRect.Left := StrToInt(Copy(S, 1, I - 1));
  Delete(S, 1, I);
  I := Pos(',', S);
  gHelpRect.Top := StrToInt(Copy(S, 1, I - 1));
  Delete(S, 1, I);
  I := Pos(',', S);
  gHelpRect.Right := StrToInt(Copy(S, 1, I - 1));
  Delete(S, 1, I);
  gHelpRect.Bottom := StrToInt(S);
  I := Ini.ReadInteger(Sect, 'AutoOpenWin', 0);
  I := I shr 1;
  miAutoOpenCP.Checked := (I and 1) = 1;
  miShowSFNames.Checked := Ini.ReadBool(Sect, 'ShowScriptNames', False);
  miShowRuningScript.Checked := Ini.ReadBool(Sect, 'ShowRuningScript', False);
  miShowRuningScriptOnTaskbar.Checked := Ini.ReadBool(Sect, 'ShowRuningScriptOnTaskbar', False);
  cbShowScriptNamesOnTabs.Checked := Ini.ReadBool(Sect, 'ShowScriptNamesOnTabs', False);
  cbShowUnsavedScripts.Checked := Ini.ReadBool(Sect, 'ShowUnsavedScripts', False);
  I := Ini.ReadInteger(Sect, 'ShowStat', 0);
  cbShowCoords.Checked := (I and 1) = 1;
  I := I shr 1;
  cbAr.Checked := (I and 1) = 1;
  I := I shr 1;
  cbWght.Checked := (I and 1) = 1;
  I := I shr 1;
  cbGold.Checked := (I and 1) = 1;
  I := I shr 1;
  cbStam.Checked := (I and 1) = 1;
  I := I shr 1;
  cbMana.Checked := (I and 1) = 1;
  I := I shr 1;
  cbHits.Checked := (I and 1) = 1;
  I := I shr 1;
  cbDrinkTimer.Checked := (I and 1) = 1;
  I := Ini.ReadInteger(Sect, 'MacrosRepCount', 1);
  semiRepeat.Value := Abs(I);
  N20.Checked := I < 0;
  if N20.Checked then
    N20Click(fmSecondfj);
  I := Ini.ReadInteger(Sect, 'ShowCoordsInCaption', 0);
  case I of
    0:
      begin
        miSKRel.Checked := False;
        miSKAbs.Checked := False;
      end;
    1:
      begin
        miSKRel.Checked := True;
        miSKAbs.Checked := False;
      end;
    2:
      begin
        miSKRel.Checked := False;
        miSKAbs.Checked := True;
      end;
  end;
  if I > 0 then
    tShowCoordsOnCap.Enabled := True;
  miSaveOnExit.Checked := Ini.ReadBool(Sect, 'SaveOnExit', False);
  miStopSUncC.Checked := Ini.ReadBool(Sect, 'StopUnknownCommand', True);
  I := Ini.ReadInteger(Sect, 'ShowCharParamsScript', 0);
  case I of
    0: miSCPscript.Checked := True;
    1: miSCPtopuo.Checked := True;
    2: miSCPuop.Checked := True;
  end;
  miShowHex.Checked := Ini.ReadBool(Sect, 'ShowHex', False);
  miMoveMouseBack.Checked := Ini.ReadBool(Sect, 'MoveMouseBack', False);
  miMoveMouseBeforeClick.Checked := Ini.ReadBool(Sect, 'MoveMouseBeforeClick', False);
  miUseKleft217.Checked := Ini.ReadBool(Sect, 'UseKleft217', True);
  I := Ini.ReadInteger(Sect, 'TypeCharParamsForm', $10);
  case I of
    1: sbCFCP5.Down := True;
    2: sbCFCP4.Down := True;
    4: sbCFCP3.Down := True;
    8: sbCFCP2.Down := True;
    16: sbCFCP1.Down := True;
    32: sbCFCP7.Down := True;
    64: sbCFCP8.Down := True;
  end;
  I := Ini.ReadInteger(Sect, 'ErrorReadCP', 0);
  miInformErrorRead.Checked := ((I shr 2) and 1) = 1;
  case I and 3 of
    1: miStopSErrorRead.Checked := True;
    2: miPauseSErrorRead.Checked := True;
  end;
  FFlag14E5 := Ini.ReadBool(Sect, 'MinToTray', False);
  miStartMinimized.Checked := Ini.ReadBool(Sect, 'StartMinimized', False);
  cbGMPageAlarm.Checked := Ini.ReadBool(Sect, 'GMPageAlarm', True);
  I := Ini.ReadInteger(Sect, 'Language', $63);
  if I <> 99 then
    case I of
      8: miLangSelect(miLangPor);
      4: miLangSelect(miLangEng);
      2: miLangSelect(miLangRus);
    end
  else
    case gLangId of
      $19: miLangSelect(miLangRus);
    else
      miLangSelect(miLangEng);
    end;
  fld_1460 := Ini.ReadInteger(Sect, 'Fl', 0);
  gSavedHeight := Ini.ReadInteger(Sect, 'ScriptHeight', 0);
  gSavedWidth := Ini.ReadInteger(Sect, 'ScriptWidth', 0);
  miShowAllWindows.Checked := Ini.ReadBool(Sect, 'ShowAllWindows', False);
  miSortSkillList.Checked := Ini.ReadBool(Sect, 'SortSkillList', True);
  cbNtUserPM.ItemIndex := Ini.ReadInteger(Sect, 'WivVer', 0);
  miRenameSelf.Checked := Ini.ReadBool(Sect, 'RenameSelf', False);
  eRenameSelf.Text := Ini.ReadString(Sect, 'RenameSelfTo', 'Program Manager');
  miLogging.Checked := Ini.ReadBool(Sect, 'Logging', False);
  S := Ini.ReadString(Sect, 'LogFont', 'Microsoft Sans Serif,8,-1,0');
  StrToFont(S, pLog.Font, ',');
  gListFontSize := pLog.Font.Size;
  seLogfilesize.Value := Ini.ReadInteger(Sect, 'LogLimitMb', $A);
  miShowHelpOnTaskbar.Checked := Ini.ReadBool(Sect, 'miShowHelpOnTaskbar', False);
  miShowRemainingWait.Checked := Ini.ReadBool(Sect, 'ShowRemainingWait', False);
  miAutoOpenLog.Checked := Ini.ReadBool(Sect, 'AutoOpenLog', True);
  case Ini.ReadInteger(Sect, 'OutputMessagesTo', 2) of
    2: miToMessageBox.Checked := True;
    1: miToHint.Checked := True;
  else
    miToDevnull.Checked := True;
  end;
  miToLog.Checked := Ini.ReadBool(Sect, 'OutputMessagesToLogAlso', True);
  cbHideUOSettings.Checked := Ini.ReadBool(Sect, 'HideUOSettings', False);
  S := Ini.ReadString(Sect, 'FindImagePos', '100,100,200,200');
  I := Pos(',', S);
  try
    gDlg59671Ct7.Left := StrToInt(Copy(S, 1, I - 1));
    Delete(S, 1, I);
    I := Pos(',', S);
    gDlg59671Ct7.Top := StrToInt(Copy(S, 1, I - 1));
    Delete(S, 1, I);
    I := Pos(',', S);
    gDlg59671Ct7.ClientWidth := StrToInt(Copy(S, 1, I - 1));
    Delete(S, 1, I);
    gDlg59671Ct7.ClientHeight := StrToInt(S);
  except
  end;
  gServiceNamec := Ini.ReadString(Sect, 'ServiceName', '');
  if gServiceNamec = '' then
    for K := 1 to Random(16) + 3 do
    begin
      I := Random(57) + 65;
      case I of
        $5B..$60: I := Random(26) + 65;
      end;
      gServiceNamec := gServiceNamec + Chr(I);
    end;
  cbCheckGetImage.Checked := Ini.ReadBool(Sect, 'CheckGetImage', True);
  Sect := 'Client';
  cbClVer.ItemIndex := Ini.ReadInteger(Sect, 'Number', 1);
  tbUOPriority.Position := Ini.ReadInteger(Sect, 'UOPriority', 2);
  tbUOPriorityChange(Self);
  cbSUOMin.Checked := Ini.ReadBool(Sect, 'StartUOMinimized', False);
  StartUOOnly.Checked := Ini.ReadBool(Sect, 'StartUOOnly', False);
  Sect := 'Click';
  cb0.ItemIndex := Ini.ReadInteger(Sect, 'Mouse', -1);
  ed0.Text := Ini.ReadString(Sect, 'Interval_m', '5000');
  btS0.Caption := Ini.ReadString(Sect, 'Coords', '0,0');
  cb1.ItemIndex := Ini.ReadInteger(Sect, 'Key_1', -1);
  ed1.Text := Ini.ReadString(Sect, 'Interval_k1', '5000');
  cb2.ItemIndex := Ini.ReadInteger(Sect, 'Key_2', -1);
  ed2.Text := Ini.ReadString(Sect, 'Interval_k2', '1200');
  cb3.ItemIndex := Ini.ReadInteger(Sect, 'Key_3', -1);
  ed3.Text := Ini.ReadString(Sect, 'Interval_k3', '900');
  cb4.ItemIndex := Ini.ReadInteger(Sect, 'Key_4', -1);
  ed4.Text := Ini.ReadString(Sect, 'Interval_k4', '5000');
  cb5.ItemIndex := Ini.ReadInteger(Sect, 'Key_5', -1);
  ed5.Text := Ini.ReadString(Sect, 'Interval_k5', '1200');
  cbS1.Checked := Ini.ReadBool(Sect, 'SendBS_k1', False);
  cbS2.Checked := Ini.ReadBool(Sect, 'SendBS_k2', False);
  cbS3.Checked := Ini.ReadBool(Sect, 'SendBS_k3', False);
  cbS4.Checked := Ini.ReadBool(Sect, 'SendBS_k4', False);
  cbS5.Checked := Ini.ReadBool(Sect, 'SendBS_k5', False);
  ec0.Text := Ini.ReadString(Sect, 'Quantity_m', '-1');
  ec1.Text := Ini.ReadString(Sect, 'Quantity_k1', '-1');
  ec2.Text := Ini.ReadString(Sect, 'Quantity_k2', '-1');
  ec3.Text := Ini.ReadString(Sect, 'Quantity_k3', '-1');
  ec4.Text := Ini.ReadString(Sect, 'Quantity_k4', '-1');
  ec5.Text := Ini.ReadString(Sect, 'Quantity_k5', '-1');
  Sect := 'Screen_saver';
  cbDate.Checked := Ini.ReadBool(Sect, 'Date', False);
  rbJpg.Checked := Ini.ReadBool(Sect, 'Jpg', True);
  SpinEdit1.Value := Ini.ReadInteger(Sect, 'Jpg_quality', $4B);
  edScr.Text := Ini.ReadString(Sect, 'Path', 'C:\');
  I := Ini.ReadInteger(Sect, 'ScreenType', 0);
  case I of
    4: miSaveScrActiweWindow.Checked := True;
    2: miSaveScrWorkWindow.Checked := True;
  end;
  try
    Sect := 'Hotkeys';
    gHKBusy := True;
    for I := 0 to 33 do
    begin
      LoadHotKeyEntry(Ini.ReadString(Sect, Copy(gHKEntrieslw[I].Name, 3, 255),
        'False,,0,0,0,0'), Copy(gHKEntrieslw[I].Name, 3, 255));
      (FindComponent('l' + gHKEntrieslw[I].Name) as TSpeedButton).Caption :=
        BuildHotKeyText(gHKEntrieslw[I]);
    end;
    if Ini.ReadString(Sect, 'StopAllScript', 'egog') = 'egog' then
      LoadHotKeyEntry('True,End,0,1,1,', 'StopAllScript');
    if cbEnableHK.Checked then
      for I := 0 to 33 do
        if I <> 32 then
          (FindComponent('cb' + gHKEntrieslw[I].Name)
            as TCheckBox).Checked := gHKEntrieslw[I].Enabled;
    (FindComponent('cb' + gHKEntrieslw[32].Name)
      as TCheckBox).Checked := gHKEntrieslw[32].Enabled;
    cbEnableHK.Checked := Ini.ReadBool(Sect, 'EnableHK', True);
    cbEnableHKClick(Self);
    gHKBusy := False;
  except
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $1C3)), 'UOPilot Error Message', 0)
    else
      MsgBox('Error loading HotKeys', 'UOPilot Error Message', 0);
  end;
  miTransparentHotKeys.Checked := Ini.ReadBool(Sect, 'TransparentHotKeys', False);
  Sect := 'ScriptTemplate';
  Ini.ReadSection(Sect, gTemplateLines);
  if gTemplateLines <> nil then
    for I := 0 to gTemplateLines.Count - 1 do
    begin
      S := Ini.ReadString(Sect, gTemplateLines[I], '');
      gTemplateLines[I] := Copy(S, 2, Length(S) - 2);
    end;
  Sect := 'Script';
  gNoFocusStealfq := True;
  tbScriptPriority.Position := Ini.ReadInteger(Sect, 'ScriptPriority', 2);
  I := Ini.ReadInteger(Sect, 'InsertXY', 0);
  case I of
    0:
      begin
        cbInsertXY.Checked := False;
        cbInsertXYabs.Checked := False;
      end;
    1:
      begin
        cbInsertXY.Checked := True;
        cbInsertXYabs.Checked := False;
      end;
    2:
      begin
        cbInsertXY.Checked := False;
        cbInsertXYabs.Checked := True;
      end;
  end;
  CBInsertColor.Checked := Ini.ReadBool(Sect, 'Det_color', True);
  miAddSp.Checked := Ini.ReadBool(Sect, 'Add_Space', True);
  S := Ini.ReadString(Sect, 'LastObjectNum', ',');
  S2 := Ini.ReadString(Sect, 'LastObject', ',');
  S3 := Ini.ReadString(Sect, 'LastObjectDesc', ',');
  FillGridFromCsv(sgLastObject, S, S2, S3, miShowHex.Checked);
  S := Ini.ReadString(Sect, 'LastTargetNum', ',');
  S2 := Ini.ReadString(Sect, 'LastTarget', ',');
  S3 := Ini.ReadString(Sect, 'LastTargetDesc', ',');
  FillGridFromCsv(sgLastTarget, S, S2, S3, miShowHex.Checked);
  sghkScriptHKList.Cells[1, 0] := '0';
  S2 := sghkScriptHKList.Name + '_' + '0';
  Delete(S2, 1, 2);
  gHKEntrieslw[34].Name := S2;
  S2 := sghkScriptHKList.Name + '_Pause_' + '0';
  Delete(S2, 1, 2);
  gHKEntrieslw[35].Name := S2;
  gScriptCount := 0;
  S := Ini.ReadString(Sect, 'Last_script0', 'x');
  if S <> 'x' then
  begin
    Inc(gScriptCount);
    LoadScriptFile(S);
    edPause.Text := Ini.ReadString(Sect, 'Script_delay0', '100');
  end
  else if (gTemplateLines <> nil) and (gTemplateLines.Count > 0) then
    edScript.Lines.Assign(gTemplateLines);
  I := 1;
  S := '';
  while I < 99 do
  begin
    S := Ini.ReadString(Sect, 'Last_script' + IntToStr(I), '');
    if S <> '' then
    begin
      bAddClickSubproc(bAdd, I);
      LoadScriptFile(S);
      edPause.Text := Ini.ReadString(Sect, 'Script_delay' + IntToStr(I), '99');
      Inc(gScriptCount);
    end;
    Inc(I);
  end;
  S := Ini.ReadString(Sect, 'Last_script' + IntToStr(99), 'x');
  if S <> 'x' then
  begin
    odLoad.FileName := S;
    miProcOpenClick(fmSecondfj);
    edPause.Text := Ini.ReadString(Sect, 'Script_delay' + IntToStr(99), '99');
  end;
  B := True;
  tScriptChanging(tScript, B);
  tScript.TabIndex := Ini.ReadInteger(Sect, 'Current_script', 0);
  tScriptDesc.TabIndex := tScript.TabIndex;
  tScriptChange(tScript);
  edScript.Font.Color := Ini.ReadInteger(Sect, 'FontColor', 0);
  gEditorFontName := Ini.ReadString(Sect, 'FontName', 'Microsoft Sans Serif');
  gEditorFontSize := Ini.ReadInteger(Sect, 'FontSize', 8);
  gLogFontName := Ini.ReadString(Sect, 'FontNameSyn', 'Courier New');
  gLogFontSize := Ini.ReadInteger(Sect, 'FontSizeSyn', 9);
  if gFontApplyBoth then
  begin
    edScript.Font.Size := gEditorFontSize;
    edScript.Font.Name := gEditorFontName;
  end
  else
  begin
    edScript.Font.Size := gLogFontSize;
    edScript.Font.Name := gLogFontName;
  end;
  I := Ini.ReadInteger(Sect, 'FontStyle', 0);
  FS := [];
  if (I and 1) = 1 then
    Include(FS, fsStrikeOut);
  I := I shr 1;
  if (I and 1) = 1 then
    Include(FS, fsUnderline);
  I := I shr 1;
  if (I and 1) = 1 then
    Include(FS, fsItalic);
  I := I shr 1;
  if (I and 1) = 1 then
    Include(FS, fsBold);
  edScript.Font.Style := FS;
  seTabSize.Value := Ini.ReadInteger(Sect, 'TabSize', 4);
  eScriptDelayDef.Text := Ini.ReadString(Sect, 'ScriptDelayDef', '100');
  if edPause.Text = '' then
    edPause.Text := eScriptDelayDef.Text;
  edPauseNil.Text := Ini.ReadString(Sect, 'PauseNil', '0');
  miShowScriptProcessing.Checked := Ini.ReadBool(Sect, 'ShowScriptProcessing', True);
  miLockOnStartup.Checked := Ini.ReadBool(Sect, 'LockOnStartup', False);
  miPauseSOnClientClose.Checked := Ini.ReadBool(Sect, 'PauseSOnClientClose', False);
  miShowTimerVar.Checked := Ini.ReadBool(Sect, 'ShowTimerVariable', True);
  GetWindowThreadProcessId(FTargetWnd, @PID);
  for I := 0 to tScript.Tabs.Count - 1 do
  begin
    K := StrToInt(tScript.Tabs[I]);
    gScriptso3[K].ClientWnd := FTargetWnd;
    gScriptso3[K].ProcessId := PID;
    if gScriptso3[K].ProcessHandle <> 0 then
      FileClose(gScriptso3[K].ProcessHandle); { *Преобразовано из CloseHandle* }
    gScriptso3[K].ProcessHandle := OpenProcess($638, True, PID);
  end;
  seSendExDelayDef.Value := Ini.ReadInteger(Sect, 'SendExDelayDef', 0);
  seMouseClicksDelay.Value := Ini.ReadInteger(Sect, 'MouseClickDelay', $A);
  miKnopusechki_onoff.Checked := Ini.ReadBool(Sect, 'Knopusechki', True);
  miGutterVisible.Checked := Ini.ReadBool(Sect, 'GutterVisible', True);
  miSaveScriptsOnExit.Checked := Ini.ReadBool(Sect, 'SaveScriptsOnExit', True);
  miSaveScriptsOnRun.Checked := Ini.ReadBool(Sect, 'SaveScriptsOnRun', True);
  miShowCommandHint.Checked := Ini.ReadBool(Sect, 'ShowCommandHint', False);
  cbCommentOnClick.Checked := Ini.ReadBool(Sect, 'CommentOnClick', False);
  cbCommentOnSelect.Checked := Ini.ReadBool(Sect, 'CommentOnSelect', False);
  gNoFocusStealfq := False;
  try
    Sect := 'Hotkeys';
    for I := $22 to $E7 do
      if gHKEntrieslw[I].Name <> '' then
      begin
        if I = (I div 2) * 2 then
          gHKScript := (I - $22) div 2
        else
          gHKScript := -1;
        LoadHotKeyEntry(Ini.ReadString(Sect, Copy(gHKEntrieslw[I].Name, 3, 255),
          'False,,0,0,0'), Copy(gHKEntrieslw[I].Name, 3, 255));
      end;
    sghkScriptHKList.Cells[1, 0] := '0';
    S := sghkScriptHKList.Name + '_' + '0';
    Delete(S, 1, 2);
    gHKEntrieslw[34].Name := S;
    for I := 0 to sghkScriptHKList.RowCount * 2 - 1 do
    begin
      K := StrToInt(sghkScriptHKList.Cells[1, I div 2]) * 2 + $22 + I mod 2;
      if gHKEntrieslw[K].Enabled then
      begin
        if Pos('_Pause_', gHKEntrieslw[K].Name) > 0 then
        begin
          gHKMode := 4;
          gHKSela := 5;
        end
        else
        begin
          gHKMode := 3;
          gHKSela := 0;
        end;
        sghkScriptHKList.Cells[gHKSela, I div 2] := 'X';
        sghkScriptHKList.Row := I div 2;
        if cbEnableHK.Checked then
          cbhk1Click(sghkScriptHKList);
      end;
    end;
  except
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $1C4)), 'UOPilot Error Message', 0)
    else
      MsgBox('Error loading HotKeys for scripts.', 'UOPilot Error Message', 0);
  end;
  Sect := 'LastScripts';
  for I := 0 to 9 do
  begin
    Ln := Ini.ReadString(Sect, 'Line_' + IntToStr(I), '');
    if Ln <> '' then
    begin
      MI := mnHotKey.Items[0].Items[3];
      NewMI := TMenuItem.Create(MI);
      NewMI.Caption := Ln;
      NewMI.AutoHotkeys := maManual;
      NewMI.OnClick := LastScriptItemClick;
      MI.Insert(MI.Count, NewMI);
    end;
  end;
  Sect := 'Alarm';
  SEHour.Value := Ini.ReadInteger(Sect, 'Hour', 0);
  SEMinutes.Value := Ini.ReadInteger(Sect, 'Min', 0);
  eBudilnikDelay.Text := Ini.ReadString(Sect, 'Delay', '1000');
  try
    TBudilnik.Interval := StrToInt(eBudilnikDelay.Text);
  except
    TBudilnik.Interval := 1000;
    eBudilnikDelay.Text := '1000';
  end;
  Sect := 'Auto_Move';
  sbAMove_1.Caption := Ini.ReadString(Sect, 'Coords', '300, 240');
  sbAMove_2.Caption := Ini.ReadString(Sect, 'Coords2', '300, 240');
  sbAMove_3.Caption := Ini.ReadString(Sect, 'Coords3', '300, 240');
  cbMoveLeftCl.Checked := Ini.ReadBool(Sect, 'MoveMouse', False);
  Edit1.Text := Ini.ReadString(Sect, 'Delay', '350');
  Edit2.Text := Ini.ReadString(Sect, 'DelayAfterEnter', '0');
  miAMoveCount.Checked := Ini.ReadBool(Sect, 'SaveCount', False);
  if miAMoveCount.Checked then
  begin
    seAmove1.Value := Ini.ReadInteger(Sect, 'MoveCount1', 0);
    seAmove2.Value := Ini.ReadInteger(Sect, 'MoveCount2', 0);
    seAmove3.Value := Ini.ReadInteger(Sect, 'MoveCount3', 0);
  end;
  cbStoD1.Checked := Ini.ReadBool(Sect, 'StoD1', False);
  cbStoD2.Checked := Ini.ReadBool(Sect, 'StoD2', False);
  cbStoD3.Checked := Ini.ReadBool(Sect, 'StoD3', False);
  Sect := 'HouseMenu';
  gHouseMenu[0] := Ini.ReadString(Sect, 'LockDown', 'I wish to lock this down');
  gHouseMenu[1] := Ini.ReadString(Sect, 'Secure', 'I wish to secure this');
  gHouseMenu[2] := Ini.ReadString(Sect, 'Release', 'I wish to release this');
  gHouseMenu[3] := Ini.ReadString(Sect, 'Ban', 'I ban thee');
  gHouseMenu[4] := Ini.ReadString(Sect, 'Trash', 'I wish to place a trash barrel');
  gHouseMenu[5] := Ini.ReadString(Sect, 'Remove', 'Remove thyself');
  gHouseMenu[6] := Ini.ReadString(Sect, 'Strongbox', 'I wish to place a strongbox');
  Sect := 'CustomClient';
  EoffAlwaysRun.Value := Ini.ReadInteger(Sect, 'AlwaysRun', 0);
  EoffCP.Value := Ini.ReadInteger(Sect, 'CP', 0);
  EoffCharDir.Value := Ini.ReadInteger(Sect, 'CharDir', 0);
  EoffConsoleUnicodeText.Value := Ini.ReadInteger(Sect, 'ConsoleUnicodeText', 0);
  EoffCoords.Value := Ini.ReadInteger(Sect, 'Coords', 0);
  EoffCrim.Value := Ini.ReadInteger(Sect, 'Crim', 0);
  EoffFontcolor.Value := Ini.ReadInteger(Sect, 'Fontcolor', 0);
  EoffHidden_War.Value := Ini.ReadInteger(Sect, 'Hidden_War', 0);
  EoffLMess.Value := Ini.ReadInteger(Sect, 'LastMess', 0);
  EoffLastLiftedID.Value := Ini.ReadInteger(Sect, 'LastLiftedID', 0);
  EoffLastObTar1.Value := Ini.ReadInteger(Sect, 'LastOb', 0);
  EoffLastObTar2.Value := Ini.ReadInteger(Sect, 'LastTar', 0);
  EoffLastObjectType.Value := Ini.ReadInteger(Sect, 'LastObjectType', 0);
  EoffLastSkill.Value := Ini.ReadInteger(Sect, 'LastSkill', 0);
  EoffLastSpell.Value := Ini.ReadInteger(Sect, 'LastSpell', 0);
  EoffLastStaticType.Value := Ini.ReadInteger(Sect, 'LastStaticType', 0);
  EoffLastTargetKind.Value := Ini.ReadInteger(Sect, 'LastTargetKind', 0);
  EoffLastTargetXYZ.Value := Ini.ReadInteger(Sect, 'LastTargetXYZ', 0);
  EoffName.Value := Ini.ReadInteger(Sect, 'LastSpellStartNum', 0);
  EoffPathF.Value := Ini.ReadInteger(Sect, 'Name', 0);
  EoffSkills.Value := Ini.ReadInteger(Sect, 'PathF', 0);
  EoffTarget.Value := Ini.ReadInteger(Sect, 'Skills', 0);
  EoffTrans.Value := Ini.ReadInteger(Sect, 'Target', 0);
  EoffWght.Value := Ini.ReadInteger(Sect, 'Trans', 0);
  ELastSpellStartNum.Value := Ini.ReadInteger(Sect, 'Wght', 0);
  cbCustomClVer.ItemIndex := Ini.ReadInteger(Sect, 'ClVer', -1);
  EoffBackpack.Value := Ini.ReadInteger(Sect, 'Backpack', 0);
  Sect := 'CustomVariables';
  L := TStringList.Create;
  Ini.ReadSection(Sect, L);
  for I := 0 to L.Count - 1 do
  begin
    S := Ini.ReadString(Sect, L[I], '');
    if S <> '' then
    begin
      V := TMyStr.Create;
      V.Text := S;
      gCmdListah7.AddObject(AnsiLowerCase(L[I]), V);
    end;
  end;
  L.Free;
  LoadHighlighter(fld_1428, Ini);
  Sect := 'LoggingErrors';
  miELclrinvalid.Checked := Ini.ReadBool(Sect, 'clrinvalid', True);
  miFileOpError.Checked := Ini.ReadBool(Sect, 'FileOpError', True);
  miSetHKError.Checked := Ini.ReadBool(Sect, 'SetHKError', True);
  miPluginLoadError.Checked := Ini.ReadBool(Sect, 'PluginLoadError', True);
  Ini.Free;
end;

function BuildHotKeyText(E: tHotKeyList): string;
begin
  Result := E.Text;
  if hkShift in THKMods(E.Mods) then Result := 'Shift + ' + Result;
  if hkAlt in THKMods(E.Mods) then Result := 'Alt + ' + Result;
  if hkCtrl in THKMods(E.Mods) then Result := 'Ctrl + ' + Result;
end;

procedure TfmSecond.SaveScriptSection(Ini: TMyMemIniFile; Sect: string);
var
  I, N: Integer;
  Found: Boolean;
const
  LastScript: string = 'Last_script';
  ScriptDelay: string = 'Script_delay';
begin
  { Секция [Script]: имена и задержки всех вкладок-скриптов. Ключи
    строятся из двух типизированных констант ('Last_script' и
    'Script_delay'). }
  Found := False;
  N := StrToInt(tScript.Tabs[tScript.TabIndex]);
  if gScriptso3[N] <> nil then
    gScriptso3[N].PauseCmd := edPause.Text;
  Ini.WriteInteger(Sect, 'Current_script', tScript.TabIndex);
  { Сначала чистим все сто пар ключей -- иначе от прошлого сеанса остались бы
    записи вкладок, которых уже нет. }
  for I := 0 to 99 do
  begin
    Ini.DeleteKey(Sect, LastScript + IntToStr(I));
    Ini.DeleteKey(Sect, ScriptDelay + IntToStr(I));
  end;
  I := 0;
  while I <= tScript.Tabs.Count - 1 do
  begin
    N := StrToInt(tScript.Tabs[I]);
    if N = 99 then
      Found := True;
    if gScriptso3[N].Title <> '' then
    begin
      Ini.WriteString(Sect, LastScript + IntToStr(N), gScriptso3[N].Title);
      Ini.WriteString(Sect, ScriptDelay + IntToStr(N), gScriptso3[N].PauseCmd);
    end;
    Inc(I);
  end;
  { Вкладка 99 -- служебная (процедуры). Если её среди вкладок не было,
    её ключи убираем отдельно. }
  if not Found then
  begin
    Ini.DeleteKey(Sect, LastScript + IntToStr(99));
    Ini.DeleteKey(Sect, ScriptDelay + IntToStr(99));
  end;
end;

procedure TfmSecond.SaveUoPilotSection(Ini: TMyMemIniFile; Sect: string);
begin
  { Одна строка: четыре галочки языка пакуются в битовое поле.
    Значим только порядок слагаемых. }
  Ini.WriteInteger(Sect, 'Language',
    Byte(miLangPor.Checked) shl 3 + Byte(miLangEng.Checked) shl 2 +
    Byte(miLangRus.Checked) shl 1 + Byte(miLangDefault.Checked));
end;

procedure MsgBox(Text, Caption: PChar; Flags: Integer);
begin
  // Flags не используется: сообщение всегда MB_SYSTEMMODAL.
  MessageBox(0, Text, Caption, MB_SYSTEMMODAL);
end;

procedure TfmSecond.TimerKeyAction(Kind: Byte; Value: Integer);
begin
  // Действие таймера tm0 по выбору в cb0: 11 -- двойной левый
  // клик через PostMessage, $16 -- двойной правый, 1 -- левый, 2 -- правый
  // (эти три через SendMessage). Каждому клику предшествует WM_SETCURSOR
  // с hit-test кодом, как это делает сама Windows.
  if Kind = $0B then
  begin
    PostMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    PostMessage(FTargetWnd, WM_MOUSEMOVE, 0, Value);
    PostMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0201));
    PostMessage(FTargetWnd, WM_LBUTTONDOWN, 1, Value);
    PostMessage(FTargetWnd, WM_LBUTTONUP, 0, Value);
    PostMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    PostMessage(FTargetWnd, WM_MOUSEMOVE, 0, Value);
    PostMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0201));
    PostMessage(FTargetWnd, WM_LBUTTONDOWN, 1, Value);
    PostMessage(FTargetWnd, WM_LBUTTONUP, 0, Value);
  end;
  if Kind = $16 then
  begin
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    SendMessage(FTargetWnd, WM_MOUSEMOVE, 0, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0204));
    SendMessage(FTargetWnd, WM_RBUTTONDOWN, 2, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0205));
    SendMessage(FTargetWnd, WM_RBUTTONUP, 0, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    SendMessage(FTargetWnd, WM_MOUSEMOVE, 0, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0204));
    SendMessage(FTargetWnd, WM_RBUTTONDOWN, 2, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0205));
    SendMessage(FTargetWnd, WM_RBUTTONUP, 0, Value);
  end;
  if Kind = $01 then
  begin
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    SendMessage(FTargetWnd, WM_MOUSEMOVE, 0, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0201));
    SendMessage(FTargetWnd, WM_LBUTTONDOWN, 1, Value);
    SendMessage(FTargetWnd, WM_LBUTTONUP, 0, Value);
  end;
  if Kind = $02 then
  begin
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    SendMessage(FTargetWnd, WM_MOUSEMOVE, 0, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0204));
    SendMessage(FTargetWnd, WM_RBUTTONDOWN, 2, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0200));
    SendMessage(FTargetWnd, WM_MOUSEMOVE, 2, Value);
    SendMessage(FTargetWnd, WM_SETCURSOR, FTargetWnd, MakeLong(1, $0205));
    SendMessage(FTargetWnd, WM_RBUTTONUP, 0, Value);
  end;
end;

procedure TfmSecond.FormCreate(Sender: TObject);
const
  MShift = [hkAlt];
  MCtrl = [hkCtrl];
var
  I: Integer;
  PID: DWORD;
  S: string;
  S2: string;
  Reg: TRegistry;
  B: Boolean;
  B2: Boolean;
  Buf: array[0..MAX_PATH] of Char;
  P: PChar;

  { Автозапуск скриптов, помеченных ключом /rN: вкладка, открытая сейчас,
    запускается кнопкой (btStartClick), остальные -- напрямую, с поиском
    окна клиента по классу 'Ultima Online'. }
  procedure AutoStartScripts;
  var
    I: Integer;
    PID: Integer;
    N: Integer;
  begin
    N := 99;
    for I := 0 to N do
      if gAutoRun[I] and (gScriptso3[I] <> nil) then
      begin
        PID := StrToInt(tScript.Tabs[tScript.TabIndex]);
        if PID = I then
        begin
          btStart.Down := True;
          btStartClick(Sender);
        end
        else
        begin
          if gScriptso3[I].StopRequested then
            gScriptso3[I].StopRequested := False;
          if gScriptso3[I].ClientWnd = 0 then
          begin
            gScriptso3[I].ClientWnd := FindWindow('Ultima Online', nil);
            GetWindowThreadProcessId(gScriptso3[I].ClientWnd, @PID);
            gScriptso3[I].ProcessId := PID;
            if gScriptso3[I].ProcessHandle <> 0 then
              FileClose(gScriptso3[I].ProcessHandle); { *Преобразовано из CloseHandle* }
            gScriptso3[I].ProcessHandle := OpenProcess($638, True, PID);
          end;
          gScriptso3[I].Paused := False;
          gScriptso3[I].Flag91 := True;
          StartScriptThread(gScriptso3[I]);
          gScriptso3[I].Resume;
        end;
      end;
  end;


begin
  { Конструктор главной формы: инициализация глобальных, создание редактора
    скрипта, таблицы горячих клавиш, разбор командной строки и раскладка. }
  Set8087CW(Get8087CW or $05);
  if not QueryPerformanceFrequency(gPerfFreqby) then
  begin
    gPerfFreqby := 0;
  end;
  FFlag14EC := False;
  gHKDisabled := False;
  FFlag14E4 := False;
  { заголовок окна -- случайная строка из 5..30 печатных символов }
  S := '';
  Randomize;
  for I := 1 to Random($1A) + 5 do
    S := S + Chr(Random($5F) + $20);
  Caption := S;
  gFontApplyBoth := False;
  { редактор скрипта создаётся кодом и кладётся на вкладку tsScript }
  edScript := TSynMemo.Create(Self);
  with edScript do
  begin
    Parent := tsScript;
    ParentFont := False;
    Left := 0;
    Top := 0;
    Align := alClient;
    Color := $FF000014;
    Font.Charset := RUSSIAN_CHARSET;
    Font.Color := $FF000008;
    Font.Height := -12;
    Font.Name := 'Courier New';
    Font.Style := [];
    ParentShowHint := False;
    PopupMenu := mnCom;
    ShowHint := False;
    TabOrder := 0;
    OnKeyDown := mmScriptKeyDown;
    OnKeyPress := mmScriptKeyPress;
    OnKeyUp := mmScriptKeyUp;
    OnMouseDown := mmScriptMouseDown;
    OnMouseUp := mmScriptMouseUp;
    OnChange := mmScriptOnChange;
    OnGutterClick := GutterClick;
    BookMarkOptions.DrawBookmarksFirst := False;
    BookMarkOptions.EnableKeys := False;
    BookMarkOptions.GlyphsVisible := False;
    Gutter.AutoSize := True;
    Gutter.DigitCount := 2;
    Gutter.Font.Charset := DEFAULT_CHARSET;
    Gutter.Font.Color := $FF000008;
    Gutter.Font.Height := -11;
    Gutter.Font.Name := 'Courier New';
    Gutter.Font.Style := [];
    Gutter.LeftOffset := 0;
    Gutter.RightOffset := 2;
    Gutter.ShowLineNumbers := True;
    Gutter.Visible := True;
    Gutter.Width := 10;
    Gutter.ZeroStart := True;
    Gutter.LineNumberStart := 0;
    TabWidth := 4;
    WantTabs := True;
    WordWrap := False;
    WordWrapGlyph.Visible := False;
    Options := Options - [eoSmartTabs];
  end;
  edScript.SendToBack;
  { подсветка синтаксиса: класс живёт в отдельном юните }
  fld_1428 := TSynPasSyn.Create(fmSecondfj);
  edScript.Highlighter := fld_1428;
  gCoordCaptureddo := False;
  gLogFileClosedr := False;
  FFlag1438 := True;
  sghkScriptHKList.Tag := $23;
  gFlag596A40 := False;
  gObjA34 := TCriticalSection.Create;
  gObjA38 := TCriticalSection.Create;
  gObjA3C := TCriticalSection.Create;
  gPanelPads[0] := pCPVar.Height;
  { снять ограничения, выставить размер по невидимым панелям-линейкам и
    заново зафиксировать его как минимум и максимум }
  fmSecondfj.Constraints.MinHeight := 0;
  fmSecondfj.Constraints.MinWidth := 0;
  fmSecondfj.Constraints.MaxHeight := 0;
  fmSecondfj.Constraints.MaxWidth := 0;
  fmSecondfj.ClientHeight := VertSize.Height;
  fmSecondfj.ClientWidth := HorSize.Width;
  fmSecondfj.Constraints.MinHeight := fmSecondfj.Height;
  fmSecondfj.Constraints.MinWidth := fmSecondfj.Width;
  fmSecondfj.Constraints.MaxHeight := fmSecondfj.Height;
  fmSecondfj.Constraints.MaxWidth := fmSecondfj.Width;
  gLangId := GetUserDefaultLangID and $3FF;
  FFlag1467 := True;
  FLogWin.Shown := False;
  FillChar(Buf, SizeOf(Buf), 0);
  GetModuleFileName(HInstance, Buf, SizeOf(Buf));
  gTempFilefv := ExtractFilePath(Buf);
  gExeNameko := ExtractFileName(Buf);
  SetLength(gHKEntrieslw, $E8);
  SetLength(gHKNames, $E8);
  gHotKeyMgr := THotKeyManager.Create(Self);
  { первые 34 клавиши -- именованные команды, дальше идут клавиши вкладок }
  for I := 0 to $21 do
  begin
    gHKEntrieslw[I].Name := gHKDefNames[I];
    gHKEntrieslw[I].Mods := THKMods(gHKDefMods[I]);
    gHKEntrieslw[I].Text := gHKDefTexts[I];
    case I of
      0: gHKEntrieslw[I].Handler := HotKeyScr;
      1: gHKEntrieslw[I].Handler := HotKeyStartScript;
      2: gHKEntrieslw[I].Handler := HotKeyRec;
      3: gHKEntrieslw[I].Handler := HotKeyRecStop;
      4: gHKEntrieslw[I].Handler := HotKeyPlay;
      5: gHKEntrieslw[I].Handler := HotKeySNames;
      6: gHKEntrieslw[I].Handler := HotKeyMove1;
      7: gHKEntrieslw[I].Handler := HotKeyshkctrl;
      8: gHKEntrieslw[I].Handler := HotKeyshkctrl;
      9: gHKEntrieslw[I].Handler := HotKeyshkctrl;
      10: gHKEntrieslw[I].Handler := HotKeyshkctrl;
      11: gHKEntrieslw[I].Handler := HotKeyshkctrl;
      12: gHKEntrieslw[I].Handler := HotKeyMes;
      13: gHKEntrieslw[I].Handler := HotKeyUopUO;
      14: gHKEntrieslw[I].Handler := HotKeyMove2;
      15: gHKEntrieslw[I].Handler := HotKeyMove3;
      16: gHKEntrieslw[I].Handler := HotKeySetMove1;
      17: gHKEntrieslw[I].Handler := HotKeySetMove2;
      18: gHKEntrieslw[I].Handler := HotKeySetMove3;
      19: gHKEntrieslw[I].Handler := HotKeyPauseScript;
      20: gHKEntrieslw[I].Handler := sbCharParamsClick;
      21: gHKEntrieslw[I].Handler := HotKeyLockAllScroptToUO;
      22: gHKEntrieslw[I].Handler := HotKeyClipboardConsoleText;
      23: gHKEntrieslw[I].Handler := HotKeyTransp;
      24: gHKEntrieslw[I].Handler := HotKeyPathF;
      25: gHKEntrieslw[I].Handler := HotKeyCrimAct;
      26: gHKEntrieslw[I].Handler := HotKeyARun;
      27: gHKEntrieslw[I].Handler := HotKeyStopAllScript;
      28: gHKEntrieslw[I].Handler := SetCoord;
      29: gHKEntrieslw[I].Handler := HotKeyPauseAllScript;
      30: gHKEntrieslw[I].Handler := HotKeyStartAllScript;
      31: gHKEntrieslw[I].Handler := HotKeyShowScriptProcessing;
      32: gHKEntrieslw[I].Handler := HotKeyEnableAllHotKeys;
      33: gHKEntrieslw[I].Handler := HotKeyEnableKeyboard;
    end;
  end;
  { дальше -- пары «переключиться на скрипт N» / «поставить его на паузу»,
    чередуются по флагу B, отличаются только модификатором }
  B := True;
  for I := $22 to $E7 do
  begin
    if B then
    begin
      gHKEntrieslw[I].Mods := MShift;
      gHKEntrieslw[I].Handler := HotKeyScriptList;
    end
    else
    begin
      gHKEntrieslw[I].Mods := MCtrl;
      gHKEntrieslw[I].Handler := HotKeyScriptListPause;
    end;
    B := not B;
    gHKEntrieslw[I].Text := 'S';
  end;
  { раскладка клавиатуры: из реестра берётся вторая по счёту, а если она
    английская или её нет -- первая }
  gKbdLayoutow := '00000409';
  S := '\Keyboard Layout\Preload';
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(S, False) then
    begin
      S := Reg.ReadString('2');
      if S <> '' then
      begin
        if S <> '00000409' then
          gKbdLayoutow := S
        else
          gKbdLayoutow := Reg.ReadString('1');
      end
      else
        gKbdLayoutow := Reg.ReadString('1');
    end;
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
  { разбор командной строки: ключи вида /cПуть, /sСкрипт, /iИни, /rN, /m, /hКаталог }
  FFlag14E6 := False;
  FOptionsFile := '';
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    try
      if S[1] = '/' then
      begin
        case LowerCase(S[2])[1] of
          'c':
            begin
              Delete(S, 1, 2);
              eSUO.Text := S;
            end;
          's':
            begin
              Delete(S, 1, 2);
              SetLength(gCmdFiles, Length(gCmdFiles) + 1);
              gCmdFiles[Length(gCmdFiles) - 1] := S;
            end;
          'i':
            begin
              Delete(S, 1, 2);
              FOptionsFile := S;
            end;
          'r':
            begin
              Delete(S, 1, 2);
              try
                gAutoRun[StrToInt(S)] := True;
              except
              end;
            end;
          'm':
            FFlag14E6 := True;
          'h':
            try
              Delete(S, 1, 2);
              if (Pos('\', S) > 0) and (S[Length(S)] <> '\') then
                S := S + '\'
              else if (Pos('/', S) > 0) and (S[Length(S)] <> '/') then
                S := S + '/'
              else
                case S[Length(S)] of
                  '/', '\': ;
                else
                  S := S + '\';
                end;
              gTempFilefv := S;
            except
            end;
        else
          raise EDivByZero.Create('ups...');
        end;
      end
      else
        raise EDivByZero.Create('ups...');
    except
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $198) + IntToStr(I) + '):' + #13 +
          ParamStr(I)), 'UOPilot Error Message', 0)
      else
        MsgBox(PChar('Ошибка в параметрах командной строки (' + IntToStr(I) +
          '):' + #13 + ParamStr(I)), 'UOPilot Error Message', 0);
    end;
  end;
  { путь к клиенту, если не задан ключом -- из реестра Origin }
  if eSUO.Text = '' then
  begin
    try
      Reg := TRegistry.Create;
      S2 := '\Software\Origin Worlds Online\Ultima Online\1.0';
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKeyReadOnly(S2);
      eSUO.Text := Reg.ReadString('ExePath');
      Reg.CloseKey;
      Reg.Destroy;
    except
      eSUO.Text := '';
    end;
  end;
  if FOptionsFile = '' then
    FOptionsFile := gTempFilefv + 'uopilot.ini';
  gWikiPath := gTempFilefv + 'Help\';
  { Ctrl+Y в редакторе занимаем под свою команду }
  with edScript.Keystrokes do
  begin
    I := FindShortcut(ShortCut(Ord('Y'), [ssCtrl]));
    if I > 0 then
      Delete(I);
    I := FindCommand($25A);
    if I > 0 then
      Items[I].ShortCut := ShortCut(Ord('Y'), [ssCtrl])
    else
      AddKey($25A, Ord('Y'), [ssCtrl]);
  end;
  LoadLuaLib(Self);
  { первая вкладка скрипта: поток, лог и подмена оконной процедуры лога }
  I := StrToInt(tScript.Tabs[tScript.TabIndex]);
  gScriptso3[I] := TScanThread.NewScriptTab(True);
  gScriptso3[I].SelfRef := Pointer(gScriptso3[I]);
  gScriptso3[I].Name := IntToStr(I);
  gScriptso3[I].AutoStart := True;
  with gScriptso3[I] do
  begin
    if LogView = nil then
    begin
      LogView := TMemo.Create(fmSecondfj);
      with LogView do
      begin
        Visible := False;
        Parent := fmSecondfj.pLog;
        Color := $FF000018;
        ParentFont := True;
        ReadOnly := True;
        ScrollBars := ssBoth;
        HideSelection := False;
        Align := alClient;
      end;
    end;
    LogView.Lines.Add(fmSecondfj.tScript.Tabs[fmSecondfj.tScript.Tabs.Count - 1]);
    OldLogProc := LogView.WindowProc;
    LogView.WindowProc := LogWndProc;
  end;
  case tbScriptPriority.Position of
    0: SetThreadPriority(gScriptso3[I].Handle, THREAD_PRIORITY_LOWEST);
    2: SetThreadPriority(gScriptso3[I].Handle, THREAD_PRIORITY_HIGHEST);
    3: SetThreadPriority(gScriptso3[I].Handle, THREAD_PRIORITY_TIME_CRITICAL);
  else
    SetThreadPriority(gScriptso3[I].Handle, THREAD_PRIORITY_NORMAL);
  end;
  fld_145C := -1;
  DragAcceptFiles(Handle, True);
  TheRecorder.SpeedFactor := miSpeed.Tag;
  { поиск окна клиента и открытие его процесса }
  if gLangOffsety > 0 then
  begin
    sgVar.Cells[0, 0] := LoadStr(gLangOffsety + $199);
    sgVar.Cells[1, 0] := LoadStr(gLangOffsety + $19A);
  end
  else
  begin
    sgVar.Cells[0, 0] := 'Имя';
    sgVar.Cells[1, 0] := 'Значение';
  end;
  FTargetWnd := FindWindow('Ultima Online', nil);
  GetWindowThreadProcessId(FTargetWnd, @PID);
  if FClientProcess <> 0 then
    FileClose(FClientProcess); { *Преобразовано из CloseHandle* }
  FClientProcess := OpenProcess($638, False, PID);
  gWorkWnd := FTargetWnd;
  gClientThread := OpenProcess($418, False, PID);
  gScriptso3[tScript.TabIndex].ClientWnd := FTargetWnd;
  GetWindowThreadProcessId(gScriptso3[tScript.TabIndex].ClientWnd, @PID);
  gScriptso3[tScript.TabIndex].ProcessId := PID;
  gScriptso3[tScript.TabIndex].ProcessHandle := OpenProcess($638, False, PID);
  if FTargetWnd <> 0 then
  begin
    GetMem(P, $FF);
    GetWindowText(FTargetWnd, P, $FF);
    I := Pos('-', P) + 1;
    sbGMPage.Caption := Copy(P, I, Pos('(', P) - I - 1);
    FreeMem(P);
  end;
  { Списки имён клавиш, версий клиента и команд скрипта. Таблица имён
    берётся из HotKeyMgr. }
  cb1.Items.Clear;
  for I := 0 to 99 do
    cb1.Items.Add(gHKNameTablee9[I]);
  cb2.Items := cb1.Items;
  cb3.Items := cb1.Items;
  cb4.Items := cb1.Items;
  cb5.Items := cb1.Items;
  cbM.Items := cb1.Items;
  for I := cbM.Items.Count - 1 downto 0 do
    if Length(cbM.Items[I]) = 1 then
      case cbM.Items[I][1] of
        '0'..'9', 'A'..'Z': cbM.Items.Delete(I);
      end;
  cbClVer.Items.Clear;
  for I := 0 to $17 do
    cbClVer.Items.Add(gClVerNames[I]);
  cbNtUserPM.Items.Clear;
  for I := 0 to 2 do
    cbNtUserPM.Items.Add(gNtUserNames[I]);
  gCmdCounteh := $120;
  for I := 0 to $120 do
    gCmdListah7.Add(gCmdNamesdd[I]);
  for I := 0 to $87 do
    gCmdList2jj.Add(gCmdNames2b1[I]);
  gTrayBlink := False;
  gIconRun := LoadIcon(HInstance, 'MICON');
  gIconPause := LoadIcon(HInstance, 'MICONRUN');
  gIconStop := LoadIcon(HInstance, 'MICONPAUSE');
  if gDlg59671Ct7 = nil then
  begin
    gDlg59671Ct7 := TForm.Create(fmSecondfj);
    gDlg59671Ct7.Parent := nil;
    gDlg59671Ct7.BorderStyle := bsSizeToolWin;
    gProcImageer := TImage.Create(gDlg59671Ct7);
    gProcImageer.Parent := gDlg59671Ct7;
    gProcImageer.Align := alClient;
  end;
  try
    AfterOptionsLoaded;
  except
  end;
  { подсказка окна: версия, собранная посимвольно, чтобы не бросалась в глаза }
  S := '2.42';
  I := $2C;
  I := I * 2;
  S := S + '   ' + Chr(I - 1);
  I := $25;
  I := I * 2;
  S := S + Chr(I + 1);
  fmSecondfj.Hint := 'UoPilot  v' + S;
  if miRenameSelf.Checked then
    fmSecondfj.Caption := eRenameSelf.Text
  else
    fmSecondfj.Caption := fmSecondfj.Hint;
  try
    if cbSOT.Checked then
      Application.OnDeactivate := AppActivateKeepTopmost;
    gOldTabChange := tScript.WindowProc;
    tScript.WindowProc := ScriptTabWndProc;
  except
  end;
  gNoFocusStealfq := True;
  if miAutoOpenCP.Checked then
    sbCharParamsClick(Sender);
  gNoFocusStealfq := False;
  Randomize;
  { скрипты, перечисленные в командной строке, открываются по вкладкам }
  for I := 0 to Length(gCmdFiles) - 1 do
  begin
    FFlag1467 := True;
    if tScript.Tabs.Count - 1 >= I then
    begin
      tScriptChanging(Sender, B);
      tScript.TabIndex := I;
      tScriptChange(Sender);
    end
    else
      bAddClick(bAdd);
    LoadScriptFile(gCmdFiles[I]);
  end;
  tScriptChanging(Sender, B);
  SetLength(gCmdFiles, 0);
  AutoStartScripts;
  SetChildFontHeight(fmSecondfj);
  fmSecondfj.Constraints.MinHeight := 0;
  fmSecondfj.Constraints.MinWidth := 0;
  fmSecondfj.Constraints.MaxHeight := 0;
  fmSecondfj.Constraints.MaxWidth := 0;
  fmSecondfj.ClientHeight := VertSize.Height;
  fmSecondfj.ClientWidth := HorSize.Width;
  fmSecondfj.Constraints.MinHeight := fmSecondfj.Height;
  fmSecondfj.Constraints.MinWidth := fmSecondfj.Width;
  fmSecondfj.Constraints.MaxHeight := fmSecondfj.Height;
  fmSecondfj.Constraints.MaxWidth := fmSecondfj.Width;
  fmSecondfj.Constraints.MaxHeight := 0;
  fmSecondfj.Constraints.MaxWidth := 0;
  fmSecondfj.Constraints.MinHeight := fmSecondfj.Height;
  fmSecondfj.Constraints.MinWidth := fmSecondfj.Width;
  pcAll.Constraints.MinHeight := fmSecondfj.ClientHeight;
  pcAll.Constraints.MinWidth := fmSecondfj.ClientWidth;
  pcAll.Constraints.MaxHeight := pcAll.Constraints.MinHeight;
  pcAll.Constraints.MaxWidth := pcAll.Constraints.MinWidth;
  pcAllChange(Sender);
  Panel4.ParentFont := False;
  tScript.ParentFont := False;
  tScript.Font.Style := [fsBold];
  FormResize(Sender);
  { ширины столбцов сеток считаются от невидимых панелей-линеек }
  sgVar.ColWidths[1] := $53;
  sgLastObject.ColWidths[1] := $40;
  sgLastTarget.ColWidths[1] := $40;
  sgLastObject.ColWidths[2] := $2E;
  sgLastTarget.ColWidths[2] := $2E;
  mParamValue2.ColWidths[1] := 0;
  mParamValue2.Col := 1;
  I := Panel7.Top - Panel6.Top - 1;
  sghkScriptHKList.DefaultRowHeight := I;
  sghkScriptHKList.ColWidths[0] := $12;
  sghkScriptHKList.ColWidths[1] := Panel17.Left - 1 - $12;
  sghkScriptHKList.ColWidths[2] := Panel6.Width - 2 - 2;
  sghkScriptHKList.ColWidths[3] :=
    (Panel24.Left - Panel5.Left - Panel5.Width + 1) div 2;
  sghkScriptHKList.ColWidths[4] := sghkScriptHKList.ColWidths[3];
  sghkScriptHKList.ColWidths[5] := Panel6.Width - 2 - 2;
  sgVar.DefaultRowHeight := I;
  sgLastObject.DefaultRowHeight := I;
  sgLastTarget.DefaultRowHeight := I;
  gLogFileNamejr := gTempFilefv + 'uopilot.log';
  AssignFile(gLogFilejr, gLogFileNamejr);
  test1.Visible := False;
  mLog.Width := 0;
  mLog.Height := 0;
  edScript.Gutter.Visible := False;
  if miGutterVisible.Checked then
    edScript.Gutter.Visible := True;
  FFlag14DD := False;
  gPluginListjr := TStringList.Create;
  LoadPlugins(Self, '');
  gNoFocusStealfq := True;
  miMinToTray.Checked := FFlag14E5;
  gNoFocusStealfq := False;
  if FFlag14E6 or miStartMinimized.Checked then
    ShowWindow(fmSecondfj.Handle, SW_SHOWMINNOACTIVE);
  FFlag14E6 := FFlag14E6 or miStartMinimized.Checked;
  sbScriptProcessing.Down := miShowScriptProcessing.Checked;
  FFlag14E4 := True;
  CreateDir(gTempFilefv + 'Scripts');
  pcAll.Font := gbC.Font;
  tScriptDesc.Align := alTop;
  B2 := SetDebugPrivilege(True);
end;

procedure TfmSecond.UpdateClientFlags(ProcessHandle: THandle);
var
  B: Byte;
  ReadCount: Cardinal;
begin
  // Читает флаги прямо из памяти процесса Ultima Online.
  // Адреса зависят от версии клиента -- отсюда выбор по cbClVer.ItemIndex.
  ReadProcessMemory(ProcessHandle, Pointer(ClientAddr[0, cbClVer.ItemIndex]),
                    @B, 1, ReadCount);
  cbName.Checked := B <> 0;
  ReadProcessMemory(ProcessHandle, Pointer(ClientAddr[1, cbClVer.ItemIndex]),
                    @B, 1, ReadCount);
  cbTrans.Checked := B <> 0;
  ReadProcessMemory(ProcessHandle, Pointer(ClientAddr[2, cbClVer.ItemIndex]),
                    @B, 1, ReadCount);
  cbCrim.Checked := B <> 0;
  ReadProcessMemory(ProcessHandle, Pointer(ClientAddr[3, cbClVer.ItemIndex]),
                    @B, 1, ReadCount);
  cbPathF.Checked := B <> 0;
  { пятая строка читает ClientAddr[22]: строка массива -- 25 Cardinal }
  ReadProcessMemory(ProcessHandle, Pointer(ClientAddr[22, cbClVer.ItemIndex]),
                    @B, 1, ReadCount);
  cbRun.Checked := B <> 0;
end;

procedure TfmSecond.EmulateMouseMessage(Key: Byte; LParam: LPARAM);
var
  H: HWND;
begin
  // Реализация команд мыши скриптового языка UoPilot.
  // Key: $01 = Left, $02 = Right, $0B = Double_Left, $16 = Double_Right.
  // Каждому клику предшествует WM_SETCURSOR с hit-test кодом, как это делает
  // сама Windows -- иначе клиент игры сообщение игнорирует.
  H := gWorkWnd;   // FTargetWnd -- хэндл окна игры
  if Key = $0B then
  begin
    PostMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    PostMessageA(H, WM_MOUSEMOVE, 0, LParam);
    PostMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0201));
    PostMessageA(H, WM_LBUTTONDOWN, 1, LParam);
    PostMessageA(H, WM_LBUTTONUP, 0, LParam);
    PostMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    PostMessageA(H, WM_MOUSEMOVE, 0, LParam);
    PostMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0201));
    PostMessageA(H, WM_LBUTTONDOWN, 1, LParam);
    PostMessageA(H, WM_LBUTTONUP, 0, LParam);
  end;
  if Key = $16 then
  begin
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    SendMessageA(H, WM_MOUSEMOVE, 0, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0204));
    SendMessageA(H, WM_RBUTTONDOWN, 2, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0205));
    SendMessageA(H, WM_RBUTTONUP, 0, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    SendMessageA(H, WM_MOUSEMOVE, 0, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0204));
    SendMessageA(H, WM_RBUTTONDOWN, 2, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0205));
    SendMessageA(H, WM_RBUTTONUP, 0, LParam);
  end;
  if Key = $01 then
  begin
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    SendMessageA(H, WM_MOUSEMOVE, 0, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0201));
    SendMessageA(H, WM_LBUTTONDOWN, 1, LParam);
    SendMessageA(H, WM_LBUTTONUP, 0, LParam);
  end;
  if Key = $02 then
  begin
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    SendMessageA(H, WM_MOUSEMOVE, 0, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0204));
    SendMessageA(H, WM_RBUTTONDOWN, 2, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0200));
    SendMessageA(H, WM_MOUSEMOVE, 2, LParam);
    SendMessageA(H, WM_SETCURSOR, H, MakeLong(1, $0205));
    SendMessageA(H, WM_RBUTTONUP, 0, LParam);
  end;
end;

procedure TfmSecond.SetCoord(Sender: TObject);
var
  P: TPoint;
  DC: HDC;
  Pid: DWORD;
  I: DWORD;
  Unused1: Integer;
  Pid2: DWORD;
  W: DWORD;
  Buf: PChar;
  S: string;
  Tid: DWORD;
  Buf2: PChar;
  H: DWORD;
  Ok: Boolean;
  Unused2: Integer;
  N: Integer;
  B: Graphics.TBitmap;
  SB: TSpeedButton;
begin
  { Ctrl+A: снимает координаты точки под курсором и рабочее окно скрипта.
    Одна переменная W служит и хэндлом окна, и цветом пикселя. }
  pCoordsAndPoints.ShowHint := False;
  if cbhkSetWorkWindow.Checked and (Sender is TMenuItem) and
     ((Sender as TMenuItem).Name = 'miCtrlA') and
     (pcAll.ActivePage = tsScript) then
  begin
    edScript.SelectAll;
    Exit;
  end;
  if sbGMPage.Down then
  begin
    GetCursorPos(P);
    FileClose(gClientThread); { *Преобразовано из CloseHandle* }
    gWorkWnd := WindowFromPoint(P);
    GetMem(Buf, $FF);
    GetWindowText(gWorkWnd, Buf, $FF);
    I := Pos('-', Buf) + 1;
    sbGMPage.Caption := Copy(Buf, I, Pos('(', Buf) - Integer(I) - 1);
    { приведение обязательно: Integer - Cardinal Delphi считает в Int64 }
    FreeMem(Buf);
    GetWindowThreadProcessId(gWorkWnd, @Pid);
    gClientThread := OpenProcess($418, False, Pid);
    sbGMPage.Down := False;
    UpdateClientFlags(gClientThread);
    Exit;
  end;
  if sbLoginUO.Down then
  begin
    GetCursorPos(P);
    FileClose(gLoginProcess); { *Преобразовано из CloseHandle* }
    gLoginWnd := WindowFromPoint(P);
    GetWindowThreadProcessId(gLoginWnd, @Pid);
    gLoginProcess := OpenProcess($10, True, Pid);
    Exit;
  end;
  if pcAll.ActivePage = tsScript then
  begin
    GetCursorPos(P);
    Buf2 := StrAlloc(100);
    if miLockOnStartup.Checked then
    begin
      W := WindowFromPoint(P);
      GetWindowText(W, Buf2, $50);
      N := StrToInt(tScript.Tabs[tScript.TabIndex]);
      if gScriptso3[N].ClientWnd = 0 then
      begin
        { Msg -- ShortString, а присваивается PChar. Текст берётся из строковых
          ресурсов через LoadStr. }
        if gLangOffsety > 0 then
          gScriptso3[N].Msg := PChar(LoadStr(gLangOffsety + $19B))
        else
          gScriptso3[N].Msg := PChar('Не могу найти рабочее окно');
        gScriptso3[N].SyncLogMsg;
      end;
      Tid := GetWindowThreadProcessId(W, @Pid);
      for I := 0 to tScript.Tabs.Count - 1 do
      begin
        N := StrToInt(tScript.Tabs[I]);
        gScriptso3[N].ClientWnd := W;
        gScriptso3[N].ThreadId := Tid;
        gScriptso3[N].ProcessId := Pid;
        if gScriptso3[N].ProcessHandle <> 0 then
          FileClose(gScriptso3[N].ProcessHandle); { *Преобразовано из CloseHandle* }
        gScriptso3[N].ProcessHandle := OpenProcess($638, True, Pid);
        gScriptso3[N].ClientWnd2 := gScriptso3[N].ClientWnd;
        gScriptso3[N].ProcessHandle2 := gScriptso3[N].ProcessHandle;
      end;
      FTargetWnd := W;
      GetWindowThreadProcessId(FTargetWnd, @Pid2);
      if Pointer(FClientProcess) <> nil then
        FileClose(FClientProcess); { *Преобразовано из CloseHandle* }
      FClientProcess := OpenProcess($638, False, Pid2);
    end
    else
    begin
      N := StrToInt(tScript.Tabs[tScript.TabIndex]);
      gScriptso3[N].ClientWnd := WindowFromPoint(P);
      GetWindowText(gScriptso3[N].ClientWnd, Buf2, $50);
      if gScriptso3[N].ClientWnd = 0 then
      begin
        if gLangOffsety > 0 then
          gScriptso3[0].Msg := PChar(LoadStr(gLangOffsety + $19B))
        else
          gScriptso3[0].Msg := PChar('Не могу найти рабочее окно');
        gCoordCaptureddo := True;
        gScriptso3[0].SyncLogMsg;
      end
      else
      begin
        gScriptso3[N].ThreadId :=
          GetWindowThreadProcessId(gScriptso3[N].ClientWnd, @Pid);
        gScriptso3[N].ProcessId := Pid;
        if gScriptso3[N].ProcessHandle <> 0 then
          FileClose(gScriptso3[N].ProcessHandle); { *Преобразовано из CloseHandle* }
        gScriptso3[N].ProcessHandle := OpenProcess($638, True, Pid);
        gScriptso3[N].ClientWnd2 := gScriptso3[N].ClientWnd;
        gScriptso3[N].ProcessHandle2 := gScriptso3[N].ProcessHandle;
      end;
    end;
    lWinList.Caption := Buf2;
    StrDispose(Buf2);
    sbWorkwindowHandle.Caption := IntToStr(gScriptso3[N].ClientWnd);
    btXYabs.Caption := IntToStr(P.X) + ', ' + IntToStr(P.Y);
    if CBInsertColor.Checked then
    begin
      DC := GetDC(0);
      W := GetPixel(DC, P.X, P.Y);
      ReleaseDC(0, DC);
      if W = 0 then
      begin
        { GetPixel вернул 0 -- снимаем точку через собственный битмап;
          в BitBlt ширина и высота читаются свойствами, а не константами }
        B := Graphics.TBitmap.Create;
        B.PixelFormat := pf24bit;
        DC := GetDC(0);
        B.Width := 1;
        B.Height := 1;
        BitBlt(B.Canvas.Handle, 0, 0, B.Width, B.Height, DC, P.X, P.Y, SRCCOPY);
        W := B.Canvas.Pixels[0, 0];
        TBitmapCracker(B).FreeImage;
        B.Free;
        ReleaseDC(0, DC);
      end;
      if miShowHex.Checked then
        btColor.Caption := '0x' + IntToHex(W, 6)
      else
        btColor.Caption := IntToStr(W);
      btColor.Hint := 'rgb- ' + IntToStr(W and $FF);
      btColor.Hint := btColor.Hint + ' ' + IntToStr((W and $FF00) shr 8);
      btColor.Hint := btColor.Hint + ' ' + IntToStr((W and $FF0000) shr 16);
      btColor.Hint := btColor.Hint + #13#10 + '        ' +
        IntToHex(W and $FF, 2);
      btColor.Hint := btColor.Hint + '  ' + IntToHex((W and $FF00) shr 8, 2);
      btColor.Hint := btColor.Hint + '  ' +
        IntToHex((W and $FF0000) shr 16, 2);
      sbDefineColor.Font.Color := W;
      pDefineColor.Color := W;
    end;
    if cbInsertXYabs.Checked then
      edScript.SelText := btXYabs.Caption + ' ';
    Windows.ScreenToClient(gScriptso3[N].ClientWnd, P);
    btXY.Caption := IntToStr(P.X) + ', ' + IntToStr(P.Y);
    if cbInsertXY.Checked then
      edScript.SelText := btXY.Caption + ' ';
    UpdateClientFlags(gScriptso3[N].ProcessHandle);
    if cbCheckGetImage.Checked then
    begin
      { проверка захвата картинки: идём вверх по родительским окнам, пока
        не получится или пока не выйдем за процесс клиента }
      N := StrToInt(tScript.Tabs[tScript.TabIndex]);
      Ok := False;
      H := gScriptso3[N].ClientWnd2;
      S := '';
      while not Ok do
      begin
        if H = 0 then
          Break;
        S := S + IntToStr(H) + ' -> ';
        Ok := TryCaptureImage(gScriptso3[N], H);
        if Ok then
        begin
          GetMem(Buf, $100);
          GetWindowText(H, Buf, $FF);
          S := S + Buf;
          if Pos(#10, S) > 0 then
            S := Copy(S, 1, Pos(#10, S) - 1);
          if tcLog.TabIndex > 0 then
          begin
            I := StrToInt(tcLog.Tabs[tcLog.TabIndex]);
            gScriptso3[I].LogView.Lines.Add(S);
          end;
          mLog.Lines.Add(S);
          FreeMem(Buf);
        end
        else
        begin
          H := GetParent(H);
          if H = 0 then
            Break;
          GetWindowThreadProcessId(H, @Pid2);
          if Pid2 <> Pid then
            Break;
        end;
      end;
      if not Ok then
      begin
        S := 'Image capture by handle Failed.';
        if tcLog.TabIndex > 0 then
        begin
          I := StrToInt(tcLog.Tabs[tcLog.TabIndex]);
          gScriptso3[I].LogView.Lines.Add(S);
        end;
        mLog.Lines.Add(S);
      end;
    end;
  end
  else
  begin
    { ветка else: вкладки «Общее» и «Прочее» разбираются только здесь }
    GetCursorPos(P);
    FTargetWnd := WindowFromPoint(P);
    if FTargetWnd = 0 then
    begin
      if gLangOffsety > 0 then
        gScriptso3[0].Msg := PChar(LoadStr(gLangOffsety + $19B))
      else
        gScriptso3[0].Msg := PChar('Не могу найти рабочее окно');
      gCoordCaptureddo := True;
      gScriptso3[0].SyncLogMsg;
    end
    else
    begin
      Windows.ScreenToClient(FTargetWnd, P);
      GetWindowThreadProcessId(FTargetWnd, @Pid2);
      if FClientProcess <> 0 then
        FileClose(FClientProcess); { *Преобразовано из CloseHandle* }
      FClientProcess := OpenProcess($638, False, Pid2);
      UpdateClientFlags(FClientProcess);
    end;
    if pcAll.ActivePage = tsGeneral then
    begin
      gLastPoint := MakeLong(P.X, P.Y);
      btS0.Caption := IntToStr(P.X) + ', ' + IntToStr(P.Y);
    end;
    if pcAll.ActivePage = tsOther then
    begin
      if sbAMove_1.Down then
      begin
        sbAMove_1.Caption := IntToStr(P.X) + ', ' + IntToStr(P.Y);
        sbAMove_1.Down := False;
      end;
      SB := sbAMove_2;
      if SB.Down then
      begin
        SB.Caption := IntToStr(P.X) + ', ' + IntToStr(P.Y);
        sbAMove_2.Down := False;
      end;
      SB := sbAMove_3;
      if SB.Down then
      begin
        SB.Caption := IntToStr(P.X) + ', ' + IntToStr(P.Y);
        sbAMove_3.Down := False;
      end;
    end;
  end;
end;

procedure TfmSecond.btStartClick(Sender: TObject);
var
  J: Integer;
  Pid: DWORD;
  S: string;
  I: Integer;
  N: Integer;
begin
  gObjA3C.Enter;
  I := StrToInt(tScript.Tabs[tScript.TabIndex]);
  if btStart.Down then
  begin
    if miSaveScriptsOnRun.Checked and
       (gScriptso3[I].Modified or edScript.Modified) then
    begin
      if gScriptso3[I].Title = '' then
        gScriptso3[I].Title := 'Scripts\autosaved_' + gScriptso3[I].Name + '.txt'
      else
      begin
        S := gScriptso3[I].Title;
        if Copy(S, 1, 2) <> '\\' then
          if Copy(S, 2, 1) <> ':' then
            S := gTempFilefv + S;
      end;
      miSave.Click;
    end;
    if gScriptso3[I] = nil then
      gScriptso3[I] := TScanThread.NewScriptTab(True);
    if gScriptso3[I].Paused then
    begin
      gScriptso3[I].Paused := False;
      sbPause.Down := False;
      gScriptso3[I].Flag91 := False;
      gScriptso3[I].Resume;
      gScriptso3[I].StopRequested := True;
      while not gScriptso3[I].Suspended do
        Application.ProcessMessages;
    end;
    sbPause.Enabled := True;
    sgVar.RowCount := 1;
    if gScriptso3[I].ClientWnd = 0 then
    begin
      gScriptso3[I].ClientWnd := FindWindow('Ultima Online', nil);
      GetWindowThreadProcessId(gScriptso3[I].ClientWnd, @Pid);
      gScriptso3[I].ProcessId := Pid;
      if gScriptso3[I].ProcessHandle <> 0 then
        FileClose(gScriptso3[I].ProcessHandle); { *Преобразовано из CloseHandle* }
      if Pid <> 0 then
        gScriptso3[I].ProcessHandle := OpenProcess($638, True, Pid)
      else
        gScriptso3[I].ProcessHandle := 0;
    end;
    N := edScript.Lines.Count;
    SetLength(gScriptso3[I].Lines, N);
    for J := 0 to N - 1 do
      gScriptso3[I].Lines[J] := edScript.Lines[J];
    if Length(gScriptso3[I].Lines) = 0 then
    begin
      btStart.Down := False;
      btStartClick(Sender);
      Exit;
    end
    else
    begin
      gScriptso3[I].PauseCmd := edPause.Text;
      gScriptso3[I].Flag91 := True;
      gScriptso3[I].AutoStart := True;
      gScript.MaxValue := Length(gScriptso3[I].Lines);
      edScript.Enabled := False;
      edScript.ReadOnly := True;
      if cbDebug.Checked then
      begin
        gScriptso3[I].Paused := True;
        sbPause.Down := True;
        edScript.Enabled := True;
        edScript.ReadOnly := True;
      end;
      if gScriptso3[I].StopRequested then
        gScriptso3[I].StopRequested := False;
      if gScriptso3[I].Suspended then
        gScriptso3[I].Resume;
    end;
  end
  else
  begin
    sbPause.Enabled := False;
    edScript.Enabled := True;
    edScript.ReadOnly := False;
    PlaySound(nil, 0, SND_ASYNC);
    gScriptso3[I].StopRequested := True;
    gScriptso3[I].Flag91 := False;
    { Здесь закрывается lua_State, а не прячется форма: поле +$105BE8
      хранит TLua. }
    if gScriptso3[I].DebugForm <> nil then
      LuaClose(TLua(gScriptso3[I].DebugForm), 0);
    if gScriptso3[I].Paused or (gScriptso3[I].PromptWnd <> nil) then
    begin
      gScriptso3[I].Paused := False;
      sbPause.Down := False;
      gScriptso3[I].Resume;
    end;
    Application.ProcessMessages;
    if fmSecondfj.Visible and fmSecondfj.Enabled and (edScript <> nil) and
       edScript.Visible and edScript.Enabled and
       (pcAll.ActivePage = tsScript) then
    begin
      edScript.SetFocus;
      if fmSecondfj.Handle = GetForegroundWindow then
        SetForegroundWindow(fmSecondfj.edScript.Handle);
    end;
  end;
  gObjA3C.Leave;
end;

procedure TfmSecond.HotKeyStartScript(Sender: TObject);
begin
  btStart.Down := not btStart.Down;
  btStartClick(Sender);
end;

procedure TfmSecond.HotKeyPauseScript(Sender: TObject);
begin
  if sbPause.Enabled then
  begin
    sbPause.Down := not sbPause.Down;
    sbPauseClick(Sender);
  end;
end;

function TfmSecond.ParseTimerValue(S: string): Integer;
var
  A: string;
  I: Integer;
begin
  try
    Result := StrToInt(S);
  except
    Result := -1;
  end;
  if Result = -1 then
  begin
    A := '';
    I := 1;
    while (I <= Length(S)) and (S[I] in ['0'..'9']) do
    begin
      A := A + S[I];
      Inc(I);
    end;
    Delete(S, 1, I - 1);
    while (Length(S) >= 1) and not (S[1] in ['0'..'9']) do
      Delete(S, 1, 1);
    I := 1;
    while (I <= Length(S)) and not (S[I] in ['0'..'9']) do
      Delete(S, 1, 1);
    if Length(S) <= 0 then
      S := '0';
    try
      Result := Random(StrToInt(S)) + 1 + StrToInt(A);
    except
      Result := -1;
    end;
  end;
end;

procedure TfmSecond.btCStartClick(Sender: TObject);
var
  S: string;
  Pid: DWORD;
  N: Integer;
  V: Integer;
  C: Integer;
begin
  { Кнопки калибровки btS1..btS8: у каждой свой Tag, по нему берётся поле
    ввода `ec<Tag>` и его значение уходит в gCalibrVals. Неразбираемое
    значение даёт -1. }
  N := (Sender as TComponent).Tag;
  try
    C := StrToInt((fmSecondfj.FindComponent('ec' + IntToStr(N)) as TEdit).Text);
  except
    C := -1;
  end;
  gCalibrVals[N] := C;
  if (Sender as TSpeedButton).Down then
  begin
    { btS4/btS5 работают со вторым окном, остальные -- с основным }
    if ((Sender as TSpeedButton).Name = 'btS4') or
       ((Sender as TSpeedButton).Name = 'btS5') then
    begin
      if fld_1444 = 0 then
        fld_1444 := FindWindow('Ultima Online', nil);
      if fld_1444 = 0 then
      begin
        (Sender as TSpeedButton).Down := False;
        SetForegroundWindow(Application.Handle);
        { строка перевода берётся из строковых ресурсов по номеру
          gLangOffsety + база }
        if gLangOffsety > 0 then
          MsgBox(PChar(LoadStr(gLangOffsety + $19C) + '"Ctrl+B"'),
            'UOPilot Error Message', 0)
        else
          MsgBox('Не могу найти рабочее окно, попробуйте указать его ' +
            'принудительно:'#13#10'Установите курсор мыши над окном и ' +
            'нажмите "Ctrl+B"', 'UOPilot Error Message', 0);
        Exit;
      end;
    end
    else
    begin
      if FTargetWnd = 0 then
        FTargetWnd := FindWindow('Ultima Online', nil);
      if FTargetWnd = 0 then
      begin
        (Sender as TSpeedButton).Down := False;
        SetForegroundWindow(Application.Handle);
        if gLangOffsety > 0 then
          MsgBox(PChar(LoadStr(gLangOffsety + $19C) + '"Ctrl+A"'),
            'UOPilot Error Message', 0)
        else
          MsgBox('Не могу найти рабочее окно, попробуйте указать его ' +
            'принудительно:'#13#10'Установите курсор мыши над окном и ' +
            'нажмите "Ctrl+A"', 'UOPilot Error Message', 0);
        Exit;
      end;
      GetWindowThreadProcessId(FTargetWnd, @Pid);
      if FClientProcess <> 0 then
        FileClose(FClientProcess); { *Преобразовано из CloseHandle* }
      FClientProcess := OpenProcess($638, True, Pid);
    end;
    if (Sender as TSpeedButton).Name = 'btS0' then
    begin
      if cb0.Text = '' then
      begin
        SetForegroundWindow(Application.Handle);
        if gLangOffsety > 0 then
          MsgBox(PChar(LoadStr(gLangOffsety + $19D)),
            'UOPilot Error Message', 0)
        else
          MsgBox('Выберите тип кликания', 'UOPilot Error Message', 0);
        btS0.Down := False;
        Exit;
      end;
    end
    else if (fmSecondfj.FindComponent('cb' +
        IntToStr((Sender as TComponent).Tag)) as TComboBox).Text = '' then
    begin
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $19E)),
          'UOPilot Error Message', 0)
      else
        MsgBox('Задайте клавишу', 'UOPilot Error Message', 0);
      (Sender as TSpeedButton).Down := False;
      Exit;
    end;
    try
      { текст поля ed<Tag> разбирается в код клавиши; -1 -- ошибка }
      S := (fmSecondfj.FindComponent('ed' +
        IntToStr((Sender as TComponent).Tag)) as TEdit).Text;
      V := ParseTimerValue(S);
      if V = -1 then
        raise Exception.Create('');
      (fmSecondfj.FindComponent('tm' +
        IntToStr((Sender as TComponent).Tag)) as TTimer).Interval := V;
      (fmSecondfj.FindComponent('tm' +
        IntToStr((Sender as TComponent).Tag)) as TTimer).Enabled := True;
      (fmSecondfj.FindComponent('cb' +
        IntToStr((Sender as TComponent).Tag)) as TComboBox).Enabled := False;
      (fmSecondfj.FindComponent('ec' +
        IntToStr((Sender as TComponent).Tag)) as TEdit).Enabled := False;
    except
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $19F)),
          'UOPilot Error Message', 0)
      else
        MsgBox('Задайте правильный интервал (в миллисекундах)',
          'UOPilot Error Message', 0);
      (Sender as TSpeedButton).Down := False;
      Exit;
    end;
  end
  else
  begin
    { кнопка отжата -- таймер стоп, поля ввода снова доступны }
    (fmSecondfj.FindComponent('tm' +
      IntToStr((Sender as TComponent).Tag)) as TTimer).Enabled := False;
    (fmSecondfj.FindComponent('cb' +
      IntToStr((Sender as TComponent).Tag)) as TComboBox).Enabled := True;
    (fmSecondfj.FindComponent('ec' +
      IntToStr((Sender as TComponent).Tag)) as TEdit).Enabled := True;
  end;
end;

procedure TfmSecond.tm0Timer(Sender: TObject);
var
  S: string;
  VK: Integer;
  P: TPoint;
  Ent: Boolean;
  T, K, L: Integer;
  Tg: Integer;
begin
  try
    T := ParseTimerValue((fmSecondfj.FindComponent('ed' +
      IntToStr((Sender as TComponent).Tag)) as TEdit).Text);
    if T = -1 then
      raise Exception.Create('');
  except
    (fmSecondfj.FindComponent('btS' +
      IntToStr((Sender as TComponent).Tag)) as TSpeedButton).Down := False;
    (fmSecondfj.FindComponent('btS' +
      IntToStr((Sender as TComponent).Tag)) as TSpeedButton).Click;
    Exit;
  end;
  Tg := (Sender as TComponent).Tag;
  if gCalibrVals[Tg] = 0 then
  begin
    (fmSecondfj.FindComponent('btS' +
      IntToStr((Sender as TComponent).Tag)) as TSpeedButton).Down := False;
    (fmSecondfj.FindComponent('btS' +
      IntToStr((Sender as TComponent).Tag)) as TSpeedButton).Click;
    Exit;
  end;
  if gCalibrVals[Tg] > 0 then
    Dec(gCalibrVals[Tg]);
  (fmSecondfj.FindComponent('tm' +
    IntToStr((Sender as TComponent).Tag)) as TTimer).Interval := T;
  P.X := 0;
  P.Y := 0;
  if (Sender as TTimer).Name = 'tm0' then
  begin
    if cb0.ItemIndex = 0 then
      TimerKeyAction($0B, gLastPoint);
    if cb0.ItemIndex = 1 then
      TimerKeyAction($16, gLastPoint);
    if cb0.ItemIndex = 2 then
      TimerKeyAction($01, gLastPoint);
    if cb0.ItemIndex = 3 then
      TimerKeyAction($02, gLastPoint);
  end
  else
  begin
    S := (fmSecondfj.FindComponent('cb' +
      IntToStr((Sender as TComponent).Tag)) as TComboBox).Text;
    Ent := (fmSecondfj.FindComponent('cbS' +
      IntToStr((Sender as TComponent).Tag)) as TCheckBox).Checked;
    try
      K := 0;
      repeat
        if CompareText(S, gHKNameTablee9[K]) = 0 then
          Break;
        Inc(K);
      until K > 101;
      L := MapVirtualKey(gHKCodeTablepz[K], 0) shl 16;
      if ((Sender as TTimer).Name = 'tm4') or ((Sender as TTimer).Name = 'tm5') then
      begin
        SendMessage(fld_1444, WM_KEYDOWN, gHKCodeTablepz[K], L + 1);
        VK := MapVirtualKey(gHKCodeTablepz[K], 2) and $FF;
        if VK <> 0 then
          SendMessage(fld_1444, WM_CHAR, VK, L + $C0000001);
        SendMessage(fld_1444, WM_KEYUP, gHKCodeTablepz[K], L + $C0000001);
        if Ent and (VK <> 0) then
          SendMessage(fld_1444, WM_CHAR, 8, L + $C0000001);
      end
      else
      begin
        SendMessage(FTargetWnd, WM_KEYDOWN, gHKCodeTablepz[K], L + 1);
        VK := MapVirtualKey(gHKCodeTablepz[K], 2) and $FF;
        if VK <> 0 then
          SendMessage(FTargetWnd, WM_CHAR, VK, L + $C0000001);
        SendMessage(FTargetWnd, WM_KEYUP, gHKCodeTablepz[K], L + $C0000001);
        if Ent and (VK <> 0) then
          SendMessage(FTargetWnd, WM_CHAR, 8, L + $C0000001);
      end;
    except
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $1A0)), 'UOPilot Error Message', 0)
      else
        MsgBox('Ошибка при попытке определить клавишу', 'UOPilot Error Message', 0);
    end;
  end;
  T := T;
end;

procedure TfmSecond.HotKeyScr(Sender: TObject);
var
  Max: Integer;
  B: Graphics.TBitmap;
  DC: HDC;
  S: string;
  Bmp: HBITMAP;
  Old: HGDIOBJ;
  SR: TSearchRec;
  R: TRect;
  Ok: Boolean;
  L: Integer;
  W: HWND;
  MemDC: HDC;
  J: TJPEGImage;
  Chk: Boolean;
begin
  { Снимок экрана по горячей клавише: имя файла -- либо PicNNN с
    автонумерацией (максимальный существующий номер ищется перебором
    каталога), либо Pic + дата-время. }
  try
    Chk := cbDate.Checked;
    if not Chk then
    begin
      Max := 0;
      S := ExtractFilePath(edScr.Text) + '*.*';
      if FindFirst(S, faAnyFile, SR) = 0 then
        repeat
          { своя try внутри цикла: имя вида picXX.bmp может не разбираться,
            и тогда файл просто пропускается }
          try
            if LowerCase(Copy(SR.Name, 1, 3)) = 'pic' then
              if StrToInt(Copy(SR.Name, 4, Length(SR.Name) - 7)) > Max then
                Max := StrToInt(Copy(SR.Name, 4, Pos('.', SR.Name) - 4));
          except
          end;
        until FindNext(SR) <> 0;
      { FindClose снаружи if -- закрываем поиск в любом случае }
      SysUtils.FindClose(SR);
      Inc(Max);
      S := IntToStr(Max);
      for L := Length(S) to 2 do
        S := '0' + S;
      S := ExtractFilePath(edScr.Text) + 'Pic' + S;
    end;
    if cbDate.Checked then
    begin
      S := ExtractFilePath(edScr.Text) + 'Pic' +
        FormatDateTime('dd.mm_hh.nn.ss', Now);
      if FileExists(S + '.bmp') or FileExists(S + '.jpg') then
        S := ExtractFilePath(edScr.Text) + 'Pic' +
          FormatDateTime('dd.mm_hh.nn.ss', Now + StrToTime('00:00:01'));
    end;
  except
    SetForegroundWindow(Application.Handle);
    MsgBox('Не удалось определить путь или имя файла',
      'UOPilot Error Message', 0);
    Exit;
  end;
  DC := 0;
  { внешняя рамка накрывает и съёмку, и сохранение, и освобождение ресурсов }
  try
    B := Graphics.TBitmap.Create;
    Ok := True;
    try
      B.PixelFormat := pf24bit;
      if miSaveScrAllScreen.Checked then
      begin
        DC := GetDC(0);
        B.Height := Screen.Height;
        B.Width := Screen.Width;
        BitBlt(B.Canvas.Handle, 0, 0, B.Width, B.Height, DC, 0, 0, SRCCOPY);
      end
      else
      begin
        if miSaveScrActiweWindow.Checked then
          W := GetForegroundWindow
        else
        begin
          L := StrToInt(tScript.Tabs[tScript.TabIndex]);
          W := gScriptso3[L].ClientWnd;
          if W = 0 then
            W := GetForegroundWindow;
        end;
        DC := GetWindowDC(W);
        GetWindowRect(W, R);
        B.Height := R.Bottom - R.Top;
        B.Width := R.Right - R.Left;
        { окно снимается через PrintWindow во временный DC -- иначе не видно
          содержимого перекрытых участков }
        MemDC := CreateCompatibleDC(DC);
        Bmp := CreateCompatibleBitmap(DC, B.Width, B.Height);
        Old := SelectObject(MemDC, Bmp);
        PrintWindow(W, MemDC, 0);
        BitBlt(B.Canvas.Handle, 0, 0, B.Width, B.Height, MemDC, 0, 0, SRCCOPY);
        SelectObject(MemDC, Old);
        DeleteObject(Bmp);
        DeleteDC(MemDC);
      end;
    except
      SetForegroundWindow(Application.Handle);
      MsgBox('Не удалось создать копию экрана', 'UOPilot Error Message', 0);
      Ok := False;
    end;
    if Ok then
    try
      if rbJpg.Checked then
      begin
        J := TJPEGImage.Create;
        J.Assign(B);
        J.CompressionQuality := SpinEdit1.Value;
        {$IFnDEF FPC}J.Compress;{$ENDIF}
        J.SaveToFile(S + '.jpg');
        J.Free;
      end;
      if rbBmp.Checked then
        B.SaveToFile(S + '.bmp');
    except
      SetForegroundWindow(Application.Handle);
      MsgBox('Не удалось сохранить копию экрана', 'UOPilot Error Message', 0);
    end;
    B.FreeImage;
    B.Free;
    ReleaseDC(0, DC);
  except
    SetForegroundWindow(Application.Handle);
    MsgBox('Ошибка при создпнии или очистке мусора',
      'UOPilot Error Message', 0);
  end;
end;

procedure TfmSecond.HotKeyRec(Sender: TObject);
begin
  TheRecorder.FStream.Free;
  TheRecorder.FStream := TMemoryStream.Create;
  TheRecorder.SpeedFactor := miSpeed.Tag;
  TheRecorder.DoStop;
  TheRecorder.DoRecord(True);
end;

procedure TfmSecond.LoadScriptFile(FileName: string);
var
  S, S2: string;
  N, L, Cnt, P, I: Integer;
  R: TRichEdit;
begin
  { Загрузка файла скрипта в текущую вкладку: относительный путь
    достраивается каталогом программы, RTF распознаётся по началу первой
    строки и прогоняется через скрытый TRichEdit, пауза берётся из имени
    файла (script.500.txt -> 500), а имя без расширения уходит в подпись
    вкладки. }
  if Copy(FileName, 1, 2) <> '\\' then
    if Copy(FileName, 2, 1) <> ':' then
      FileName := gTempFilefv + FileName;
  S := ExtractFileName(FileName);
  pcAll.ActivePage := tsScript;
  edScript.Clear;
  try
    edScript.Lines.LoadFromFile(FileName);
    if Copy(edScript.Lines[0], 1, 5) = '{\rtf' then
    begin
      R := TRichEdit.Create(fmSecondfj);
      R.Visible := False;
      R.Parent := fmSecondfj;
      R.PlainText := False;
      R.Lines.LoadFromFile(FileName);
      R.PlainText := True;
      edScript.Lines.Text := R.Lines.Text;
      R.Free;
    end;
  except
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $1A2) + #13 + FileName),
        'UOPilot Error Message', 0)
    else
      MsgBox(PChar('Не могу загрузить скрипт'#13 + FileName),
        'UOPilot Error Message', 0);
    Exit;
  end;
  L := Length(gTempFilefv);
  if AnsiLowerCase(Copy(FileName, 1, L)) = AnsiLowerCase(gTempFilefv) then
    Delete(FileName, 1, L);
  N := StrToInt(tScript.Tabs[tScript.TabIndex]);
  gScriptso3[N].Modified := False;
  gScriptso3[N].Title := FileName;
  gScriptso3[N].FilePath := ExtractFilePath(FileName);
  gScriptso3[N].FileTitle := ExtractFileName(FileName);
  gStr59615C := FileName;
  if not gNoFocusStealfq then
    SaveScriptToFile(FileName);
  Cnt := 0;
  P := Pos('.', S);
  while P > 0 do
  begin
    S2 := Copy(S, 1, P - 1);
    Inc(Cnt);
    Delete(S, 1, P);
    P := Pos('.', S);
  end;
  if Cnt <= 1 then
    S2 := eScriptDelayDef.Text;
  try
    edPause.Text := IntToStr(StrToInt(S2));
  except
    edPause.Text := '100';
  end;
  S := tScript.Tabs[tScript.TabIndex];
  if S <> '99' then
    for I := 0 to sghkScriptHKList.RowCount - 1 do
    begin
      if sghkScriptHKList.Cells[1, I] = S then
      begin
        sghkScriptHKList.Cells[2, I] := ExtractFileName(FileName);
        Break;
      end;
    end;
  S2 := ExtractFileName(FileName);
  tScriptDesc.Tabs[tScript.TabIndex] :=
    S + ': ' + Copy(S2, 1, Length(S2) - Length(ExtractFileExt(S2)));
  tScriptDesc.Align := alTop;
end;

procedure TfmSecond.btLoadClick(Sender: TObject);
begin
  odLoad.InitialDir := gTempFilefv + 'Scripts';
  odLoad.FileName := '';
  if gLangOffsety > 0 then
    odLoad.Title := LoadStr(gLangOffsety + $1A3)
  else
    odLoad.Title := 'Загрузить скрипт...';
  if odLoad.Execute then
  begin
    LoadScriptFile(odLoad.FileName);
    if cbSOT.Checked then
      SetWindowPos(fmSecondfj.Handle, HWND_TOPMOST, 1, 1, 1, 1,
        SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
    if edScript.Visible then
      if edScript.Enabled then
        edScript.SetFocus;
    SysUtils.SetCurrentDir(gTempFilefv);
  end;
end;

procedure TfmSecond.WMDropFiles(var Msg: TMessage);
var
  Buf: array[0..255] of Char;
  H: THandle;
begin
  { Перетаскивание файла на окно: имя первого файла берётся в буфер
    и отдаётся обычной загрузке скрипта. }
  H := Msg.WParam;
  DragQueryFile(H, 0, Buf, 255);
  LoadScriptFile(Buf);
  DragFinish(H);
end;

procedure TfmSecond.btSaveClick(Sender: TObject);
var
  S: string;
  Ext: string;
  Filter: string;
  Part: string;
  Chosen: string;
  WasSOT: Boolean;
  Cnt: Integer;
  I: Integer;
  N: Integer;
begin
  { Сохранение скрипта через диалог. Расширение подставляется из фильтра:
    список вида `описание|маска|...` разбирается по '|', и если у файла уже
    есть подходящее расширение, ничего не добавляется. Сравнение идёт
    в нижнем регистре. }
  if (Sender as TMenuItem).Name = 'miTabClose' then
    I := tScript.IndexOfTabAt(gMouseX, gMouseY)
  else
    I := tScript.TabIndex;
  S := tScript.Tabs[I];
  N := StrToInt(S);
  sdSave.InitialDir := gTempFilefv + 'Scripts';
  sdSave.FileName := gScriptso3[N].Title;
  if gLangOffsety > 0 then
    sdSave.Title := LoadStr(gLangOffsety + $1A4)
  else
    sdSave.Title := 'Сохранить скрипт как...';
  if Pos(AnsiLowerCase('Scripts') + '\',
             AnsiLowerCase(sdSave.FileName)) = 1 then
    sdSave.FileName := Copy(sdSave.FileName, 9, Length(sdSave.FileName));
  if cbSOT.Checked then
    SetWindowPos(fmSecondfj.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE);
  if cbSOT.Checked then
  begin
    WasSOT := True;
    cbSOT.Checked := False;
  end
  else
    WasSOT := False;
  if sdSave.Execute then
  begin
    S := sdSave.FileName;
    I := Length(S);
    while (I > 0) and (S[I] <> '.') do
      Dec(I);
    Ext := AnsiLowerCase(Copy(S, I, Length(S) - I + 1));
    Filter := sdSave.Filter;
    Chosen := '';
    while Length(Filter) > 0 do
    begin
      I := Pos('|', Filter);
      Delete(Filter, 1, I + 1);
      I := Pos('|', Filter);
      if I <= 0 then
        I := Length(Filter) + 1;
      Part := Copy(Filter, 1, I - 1);
      Delete(Filter, 1, I);
      if Length(Chosen) <= 0 then
        Chosen := Part;
      if (Ext = Part) or (Length(Part) = 2) then
      begin
        Chosen := '';
        Break;
      end;
    end;
    sdSave.FileName := S + Chosen;
    if WasSOT then
      cbSOT.Checked := True;
  end
  else
  begin
    if WasSOT then
      cbSOT.Checked := True;
    if cbSOT.Checked then
      SetWindowPos(fmSecondfj.Handle, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE);
    Exit;
  end;
  if cbSOT.Checked then
    SetWindowPos(fmSecondfj.Handle, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE);
  gScriptso3[N].Title := sdSave.FileName;
  gStr59615C := sdSave.FileName;
  SaveScriptToFile(gStr59615C);
  if N <> $63 then
    for I := 0 to sghkScriptHKList.RowCount - 1 do
      if sghkScriptHKList.Cells[1, I] = IntToStr(N) then
      begin
        sghkScriptHKList.Cells[2, I] := ExtractFileName(sdSave.FileName);
        Break;
      end;
  miSaveClick(Sender);
  SysUtils.SetCurrentDir(gTempFilefv);
end;

procedure TfmSecond.miComClick(Sender: TObject);
var
  S: string;
  I, J, D, K, L: Integer;
  E: TSynMemo;
begin
  { Пункты правки буфера уходят прямо в редактор и выходят из метода. }
  if (Sender as TMenuItem).Name = 'miPaste' then
  begin
    edScript.PasteFromClipboard;
    Exit;
  end;
  if (Sender as TMenuItem).Name = 'miCopy' then
  begin
    edScript.CopyToClipboard;
    Exit;
  end;
  if (Sender as TMenuItem).Name = 'miCut' then
  begin
    edScript.CutToClipboard;
    Exit;
  end;
  if (Sender as TMenuItem).Name = 'miUndo' then
  begin
    edScript.Perform($304, 0, 0);
    Exit;
  end;
  if (Sender as TMenuItem).Name = 'miCopyLM' then
  begin
    mLM.SelectAll;
    mLM.CopyToClipboard;
    Exit;
  end;
  { Остальное -- шаблон команды из подписи пункта. }
  S := LowerCase((Sender as TMenuItem).Caption);
  { Из шаблона выбрасываются угловые скобки вокруг имён параметров. }
  I := Pos('(', S);
  while I < Length(S) do
  begin
    Inc(I);
    if S[I] in ['<', '>'] then
      Delete(S, I, 1);
  end;
  { ... и квадратные скобки вместе с содержимым: D -- глубина вложенности }
  I := Pos('[', S);
  if I > 0 then
  begin
    J := I;
    L := Length(S);
    D := 0;
    while J <= L do
    begin
      case S[J] of
        '[': Inc(D);
        ']': Dec(D);
      end;
      if D = 0 then
      begin
        Delete(S, I, J - I + 1);
        I := PosEx('[', S, I);
        if I = 0 then
          Break;
        D := 1;
        J := I;
        L := Length(S);
      end;
      Inc(J);
    end;
  end;
  { Хвостовые пробелы срезаются, но Copy берёт K + 1 -- один пробел
    остаётся; закрывающая скобка приклеивается вплотную. }
  K := Length(S);
  while (K > 0) and (S[K] = ' ') do
    Dec(K);
  S := Copy(S, 1, K + 1);
  K := Length(S);
  if Copy(S, K, 1) = ')' then
  begin
    Dec(K);
    while (K > 0) and (S[K] = ' ') do
      Dec(K);
    S := Copy(S, 1, K) + ')';
  end;
  { Первая строка скрипта '--' -- старый диалект: там у команды обязательны
    круглые скобки, решётки не нужны, аргументы разделяются запятыми. }
  if Copy(edScript.Lines[0], 1, 2) = '--' then
  begin
    I := Pos('(', S);
    if I <= 0 then
    begin
      if Copy(S, Length(S), 1) <> ' ' then
        S := S + ' ';
      S := S + '()';
    end
    else
    begin
      D := I;
      K := D;
      while K < Length(S) do
      begin
        Inc(K);
        case S[K] of
          '#': Delete(S, K, 1);
        end;
      end;
      K := D;
      while K < Length(S) do
      begin
        Inc(K);
        if (S[K] = ' ') and (S[K - 1] in [')', 'A'..'Z', 'a'..'z']) then
        begin
          Insert(',', S, K);
          Inc(K);
        end;
      end;
      I := 0;
    end;
    edScript.SelText := S;
    E := edScript;
    E.SelStart := E.SelEnd - I;
  end
  else
    edScript.SelText := S;
end;

procedure TfmSecond.edScrExit(Sender: TObject);
begin
  if Copy(edScr.Text, Length(edScr.Text), 1) <> '\' then
    edScr.Text := edScr.Text + '\';
end;

procedure TfmSecond.miNewClick(Sender: TObject);
var
  S: string;
  Cur: Boolean;
  Empty: Boolean;
  I: Integer;
  N: Integer;
begin
  { Очистка скрипта: подтверждение, затем обнуление строк, текста и
    привязанной горячей клавиши. Сравнение S с '99' в конце идёт уже
    ПОСЛЕ того, как S перезаписана текстом вопроса. }
  if (Sender as TMenuItem).Name = 'miTabClear' then
    I := tScript.IndexOfTabAt(gMouseX, gMouseY)
  else
    I := tScript.TabIndex;
  S := tScript.Tabs[I];
  N := StrToInt(S);
  if I = tScript.TabIndex then
  begin
    Cur := True;
    Empty := edScript.Text <> '';
  end
  else
  begin
    Cur := False;
    Empty := Length(gScriptso3[N].Lines) > 0;
  end;
  if Empty then
  begin
    if gLangOffsety > 0 then
      S := LoadStr(gLangOffsety + $1A5)
    else
      S := 'Вы уверены, что хотите'#13'очистить существующий скрипт?';
    if MessageDlg(S, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      if Cur then
        edScript.Clear;
      SetLength(gScriptso3[N].Lines, 0);
      gStr59615C := '';
      gScriptso3[N].Title := '';
      if S <> '99' then
        for I := 0 to sghkScriptHKList.RowCount - 1 do
        begin
          if sghkScriptHKList.Cells[1, I] = S then
          begin
            sghkScriptHKList.Cells[2, I] := '';
            Break;
          end;
        end;
    end;
  end;
end;

procedure TfmSecond.miExitClick(Sender: TObject);
var
  Action: TCloseAction;
begin
  Action := caFree;
  FormClose(Sender, Action);
end;

procedure TfmSecond.miCtrlBClick(Sender: TObject);
var
  P: TPoint;
  C: Integer;
  DC: HDC;
begin
  { Ctrl+B: на вкладке скрипта берёт координаты из подписи btXYabs, читает
    пиксель экрана и раскладывает цвет по каналам -- десятичным и
    шестнадцатеричным; на остальных вкладках выбирает рабочее окно под
    курсором. }
  if pcAll.ActivePage = tsScript then
  begin
    DC := GetDC(0);
    P.X := StrToInt(Copy(btXYabs.Caption, 1,
      Pos(',', btXYabs.Caption) - 1));
    P.Y := StrToInt(Copy(btXYabs.Caption, Pos(',', btXYabs.Caption) + 1,
      Length(btXYabs.Caption) - Pos(',', btXYabs.Caption)));
    C := GetPixel(DC, P.X, P.Y);
    ReleaseDC(0, DC);
    if miShowHex.Checked then
      btColor.Caption := '0x' + IntToHex(C, 6)
    else
      btColor.Caption := IntToStr(C);
    btColor.Hint := 'rgb- ' + IntToStr(C and $FF);
    btColor.Hint := btColor.Hint + ' ' + IntToStr((C and $FF00) shr 8);
    btColor.Hint := btColor.Hint + ' ' + IntToStr((C and $FF0000) shr 16);
    btColor.Hint := btColor.Hint + #13#10 + '        ' + IntToHex(C and $FF, 2);
    btColor.Hint := btColor.Hint + '  ' + IntToHex((C and $FF00) shr 8, 2);
    btColor.Hint := btColor.Hint + '  ' + IntToHex((C and $FF0000) shr 16, 2);
    sbDefineColor.Font.Color := C;
    pDefineColor.Color := C;
  end
  else
  begin
    GetCursorPos(P);
    fld_1444 := Integer(WindowFromPoint(P));
    if fld_1444 = 0 then
    begin
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $19B)), 'UOPilot Error Message', 0)
      else
        MsgBox('Не могу найти рабочее окно', 'UOPilot Error Message', 0);
    end
    else
    begin
      if gLangOffsety > 0 then
        gbOtherWindow.Caption := LoadStr(gLangOffsety + $1A6)
      else
        gbOtherWindow.Caption := 'Выбрано! Для выбора другого: (Ctrl+B)';
    end;
  end;
end;

procedure TfmSecond.HotKeyRecStop(Sender: TObject);
begin
  TheRecorder.DoStop;
end;

procedure TfmSecond.HotKeyPlay(Sender: TObject);
begin
  TheRecorder.DoStop;
  TheRecorder.FRepeatCount := gPlayCount;
  TheRecorder.DoPlay;
end;

procedure TfmSecond.miSaveClick(Sender: TObject);
var
  S: string;
  Path: string;
  FName: string;
  I: Integer;
  Tab: Integer;
  M: TMemo;
  N: Integer;
begin
  { Сохранение скрипта в его файл. Прежняя версия уезжает в Backup рядом
    с файлом, с меткой времени в имени. Если сохраняется не текущая вкладка,
    строки берутся из объекта потока через временный TMemo. }
  if (Sender as TMenuItem).Name = 'miTabClose' then
    Tab := tScript.IndexOfTabAt(gMouseX, gMouseY)
  else
    Tab := tScript.TabIndex;
  S := tScript.Tabs[Tab];
  N := StrToInt(S);
  gStr59615C := gScriptso3[N].Title;
  if gStr59615C = '' then
  begin
    btSaveClick(Sender);
    Exit;
  end;
  if (Copy(gStr59615C, 1, 2) <> '\\') and (Copy(gStr59615C, 2, 1) <> ':') then
    gStr59615C := gTempFilefv + gStr59615C;
  SaveScriptToFile(gStr59615C);
  CreateDir(ExtractFilePath(gStr59615C) + 'Backup');
  Path := ExtractFileName(gStr59615C);
  FName := ExtractFileExt(gStr59615C);
  Path := Copy(Path, 1, Length(Path) - Length(FName));
  RenameFile(gStr59615C, ExtractFilePath(gStr59615C) + 'Backup' + '\' +
    Path + ' ' + FormatDateTime('yymmdd hhnnss', Now) + FName);
  if tScript.TabIndex = Tab then
    edScript.Lines.SaveToFile(gStr59615C)
  else
  begin
    M := TMemo.Create(fmSecondfj);
    M.Parent := fmSecondfj;
    for I := 0 to Length(gScriptso3[N].Lines) - 1 do
      M.Lines.Add(gScriptso3[N].Lines[I]);
    M.Lines.SaveToFile(gStr59615C);
    FreeAndNil(M);
  end;
  edScript.Modified := False;
  gScriptso3[N].Modified := False;
  RedrawAllTabs;
  SysUtils.SetCurrentDir(gTempFilefv);
end;

procedure TfmSecond.HotKeyshkctrl(Sender: TObject);
begin
  { Кнопка ищется по имени: 'btS' + третий символ имени горячей клавиши. }
  (fmSecondfj.FindComponent('btS' + Copy((Sender as THotKeyItem).Name, 3, 1)) as TSpeedButton).Down :=
    not (fmSecondfj.FindComponent('btS' + Copy((Sender as THotKeyItem).Name, 3, 1)) as TSpeedButton).Down;
  (fmSecondfj.FindComponent('btS' + Copy((Sender as THotKeyItem).Name, 3, 1)) as TSpeedButton).Click;
end;

procedure TfmSecond.ed1Enter(Sender: TObject);
begin
  (Sender as TEdit).SelectAll;
end;

procedure TfmSecond.btAddColClick(Sender: TObject);
var
  S: string;
begin
  { Одна кнопка на несколько вставок: что вставлять, решает её имя. }
  if (Sender as TSpeedButton).Name = 'sbWorkwindowHandle' then
    S := sbWorkwindowHandle.Caption + ' ';
  if (Sender as TSpeedButton).Name = 'btColor' then
    S := btColor.Caption + ' ';
  if (Sender as TSpeedButton).Name = 'btXY' then
    S := btXY.Caption + ' ';
  if (Sender as TSpeedButton).Name = 'btXYabs' then
    S := btXYabs.Caption + ' ' + 'abs';
  if (Sender as TSpeedButton).Name = 'btAddM' then
  begin
    if cbM.Text = '' then
    begin
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $19E)), 'UOPilot Error Message', 0)
      else
        MsgBox('Задайте клавишу', 'UOPilot Error Message', 0);
      Exit;
    end;
    S := '{' + cbM.Text + '} ';
  end;
  edScript.SelText := S;
  if edScript.Visible then
    if edScript.Enabled then
      edScript.SetFocus;
end;

procedure TfmSecond.bHouseClick(Sender: TObject);
begin
  InsertScriptCommand(gHouseCmds[(Sender as TSpeedButton).Tag]);
end;

procedure TfmSecond.bShipOClick(Sender: TObject);
begin
  InsertScriptCommand((Sender as TButton).Hint);
end;

procedure TfmSecond.bShipClick(Sender: TObject);
begin
  if rbSlow.Checked then
    InsertScriptCommand('Slow ' + (Sender as TButton).Hint)
  else if rbOne.Checked then
    InsertScriptCommand('One ' + (Sender as TButton).Hint)
  else if rbFull.Checked then
    InsertScriptCommand('Full ' + (Sender as TButton).Hint)
  else
    InsertScriptCommand((Sender as TButton).Hint);
end;

procedure TfmSecond.InsertScriptCommand(Cmd: string);
var
  I, L: Integer;
  W: HWND;
begin
  W := FTargetWnd;
  L := Length(Cmd);
  for I := 1 to L do
    SendMessage(W, WM_CHAR, Ord(Cmd[I]), 0);
  SendMessage(W, WM_CHAR, 13, 0);
end;

procedure TfmSecond.SBBudilnikClick(Sender: TObject);
var
  S: string;
  T: string;
  U: string;
begin
  { Будильник: кнопка включает таймер, поле ввода при этом блокируется. }
  Lbudilnik.Enabled := SBBudilnik.Down;
  TBudilnik.Enabled := SBBudilnik.Down;
  eBudilnikDelay.Enabled := not SBBudilnik.Down;
  try
    TBudilnik.Interval := StrToInt(eBudilnikDelay.Text);
  except
    TBudilnik.Interval := 1000;
  end;
  if TBudilnik.Interval < 500 then
    TBudilnik.Interval := 500;
  if TBudilnik.Interval > 30000 then
    TBudilnik.Interval := 30000;
  eBudilnikDelay.Text := IntToStr(TBudilnik.Interval);
  if not SBBudilnik.Down then
    SBBudilnik.Caption := 'On\Off'
  else
    SBBudilnik.Caption := TimeToStr(Time);
end;

procedure TfmSecond.TBudilnikTimer(Sender: TObject);
var
  S: string;
  H: Integer;
  M: Integer;
  R: THandle;
  P: PChar;
begin
  { Будильник тикает раз в секунду: сверяет текущее время с заданным и
    срабатывает на минуте X, X+2, X+4, X+6, X+8, а на X+9 выключается. }
  S := TimeToStr(Time);
  SBBudilnik.Caption := S;
  H := StrToInt(Copy(S, 1, Pos(':', S) - 1));
  M := StrToInt(Copy(S, Pos(':', S) + 1, 2));
  if H = SEHour.Value then
  begin
    if (M = SEMinutes.Value) or (M = SEMinutes.Value + 2) or
       (M = SEMinutes.Value + 4) or (M = SEMinutes.Value + 6) or
       (M = SEMinutes.Value + 8) then
    begin
      if cbScript.Checked then
      begin
        SBBudilnik.Down := False;
        SBBudilnikClick(Sender);
        if not btStart.Down then
        begin
          btStart.Down := True;
          btStartClick(Sender);
        end;
      end
      else
      begin
        R := FindResource(HInstance, 'MSGWAV', PChar(10));
        R := LoadResource(HInstance, R);
        P := LockResource(R);
        sndPlaySound(P, 6);
        UnlockResource(R);
        FreeResource(R);
      end;
    end;
    if M = SEMinutes.Value + 9 then
    begin
      SBBudilnik.Down := False;
      SBBudilnikClick(Sender);
    end;
  end;
end;

procedure TfmSecond.SEHourChange(Sender: TObject);
begin
  if SEHour.Value > 23 then
    SEHour.Value := 0;
  if SEHour.Value < 0 then
    SEHour.Value := 23;
end;

procedure TfmSecond.SEMinutesChange(Sender: TObject);
begin
  if SEMinutes.Value > 59 then
    SEMinutes.Value := 0;
  if SEMinutes.Value < 0 then
    SEMinutes.Value := 59;
end;

procedure TfmSecond.HotKeySNames(Sender: TObject);
begin
  cbNameClick(Self);
end;

procedure TfmSecond.HotKeyTransp(Sender: TObject);
begin
  cbNameClick(Self);
end;

procedure TfmSecond.HotKeyPathF(Sender: TObject);
begin
  cbNameClick(Self);
end;

procedure TfmSecond.HotKeyCrimAct(Sender: TObject);
begin
  cbNameClick(Self);
end;

procedure TfmSecond.HotKeyARun(Sender: TObject);
begin
  cbNameClick(Self);
end;

procedure TfmSecond.HotKeyShowScriptProcessing(Sender: TObject);
begin
  miShowScriptProcessing.Checked := not miShowScriptProcessing.Checked;
end;

procedure TfmSecond.HotKeyStopAllScript(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  while I <= 99 do
  begin
    if Assigned(gScriptso3[I]) then
      if gScriptso3[I].AutoStart then
      begin
        btStart.Down := False;
        btStartClick(Sender);
      end
      else
      begin
        gScriptso3[I].StopRequested := True;
        gScriptso3[I].Flag91 := False;
        if gScriptso3[I].Paused then
        begin
          gScriptso3[I].Paused := False;
          gScriptso3[I].Resume;
        end;
      end;
    Inc(I);
  end;
  btS0.Down := False;  btS0.Click;
  btS1.Down := False;  btS1.Click;
  btS2.Down := False;  btS2.Click;
  btS3.Down := False;  btS3.Click;
  btS4.Down := False;  btS4.Click;
  btS5.Down := False;  btS5.Click;
end;

procedure TfmSecond.HotKeyStartAllScript(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  while I <= 99 do
  begin
    if Assigned(gScriptso3[I]) then
    begin
      if not gScriptso3[I].Suspended then
        gScriptso3[I].StopRequested := True
      else if not gScriptso3[I].StopRequested and gScriptso3[I].Paused then
      begin
        gScriptso3[I].StopRequested := True;
        gScriptso3[I].Paused := False;
        gScriptso3[I].Resume;
      end;
      while not gScriptso3[I].Suspended do
        Application.ProcessMessages;
    end;
    Inc(I);
  end;
  I := 0;
  while I <= 99 do
  begin
    if Assigned(gScriptso3[I]) then
    begin
      gScriptso3[I].StopRequested := False;
      gScriptso3[I].Paused := False;
      gScriptso3[I].Flag91 := True;
      if gScriptso3[I].AutoStart then
      begin
        btStart.Down := True;
        btStartClick(Sender);
      end
      else
        gScriptso3[I].Resume;
    end;
    Inc(I);
  end;
end;

procedure TfmSecond.HotKeyPauseAllScript(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  FFlag14DD := not FFlag14DD;
  case FFlag14DD of
    True:
      while I <= 99 do
      begin
        if Assigned(gScriptso3[I]) then
          if gScriptso3[I].Flag91 and not gScriptso3[I].Paused then
          begin
            if gScriptso3[I].AutoStart then
            begin
              sbPause.Down := True;
              sbPauseClick(Sender);
            end
            else
              gScriptso3[I].Paused := True;
            FPausedByHotKey[I] := 1;
          end
          else
            FPausedByHotKey[I] := 0;
        Inc(I);
      end;
    False:
      while I <= 99 do
      begin
        if Assigned(gScriptso3[I]) then
        begin
          if gScriptso3[I].Flag91 and gScriptso3[I].Paused then
            if gScriptso3[I].AutoStart then
            begin
              sbPause.Down := False;
              sbPauseClick(Sender);
            end
            else
            begin
              gScriptso3[I].Paused := False;
              gScriptso3[I].Resume;
            end;
          FPausedByHotKey[I] := 0;
        end;
        Inc(I);
      end;
  end;
end;

procedure TfmSecond.HotKeyMove1(Sender: TObject);
var
  P: TPoint;
begin
  P.X := StrToInt(Copy(sbAMove_1.Caption, 1, Pos(',', sbAMove_1.Caption) - 1));
  P.Y := StrToInt(Copy(sbAMove_1.Caption, Pos(',', sbAMove_1.Caption) + 1,
    Length(sbAMove_1.Caption) - Pos(',', sbAMove_1.Caption)));
  HotKeyMove(P, seAmove1.Value, cbStoD1.Checked);
end;

procedure TfmSecond.HotKeyMove2(Sender: TObject);
var
  P: TPoint;
begin
  P.X := StrToInt(Copy(sbAMove_2.Caption, 1, Pos(',', sbAMove_2.Caption) - 1));
  P.Y := StrToInt(Copy(sbAMove_2.Caption, Pos(',', sbAMove_2.Caption) + 1,
    Length(sbAMove_2.Caption) - Pos(',', sbAMove_2.Caption)));
  HotKeyMove(P, seAmove2.Value, cbStoD2.Checked);
end;

procedure TfmSecond.HotKeyMove3(Sender: TObject);
var
  P: TPoint;
begin
  P.X := StrToInt(Copy(sbAMove_3.Caption, 1, Pos(',', sbAMove_3.Caption) - 1));
  P.Y := StrToInt(Copy(sbAMove_3.Caption, Pos(',', sbAMove_3.Caption) + 1,
    Length(sbAMove_3.Caption) - Pos(',', sbAMove_3.Caption)));
  HotKeyMove(P, seAmove3.Value, cbStoD3.Checked);
end;

procedure TfmSecond.HotKeyMove(P: TPoint; N: Integer; Back: Boolean);
var
  StartTick: DWORD;
  L1, L2, T: Integer;
  P2, P3: TPoint;
  S: string;
  I: Integer;
  W: HWND;

  { Пауза с прокачкой очереди сообщений. }
  procedure Wait(MS: string);
  begin
    if MS = '' then
      Exit;
    if MS <> '0' then
    begin
      StartTick := GetTickCount;
      repeat
        Application.ProcessMessages;
      until GetTickCount - StartTick >= DWORD(StrToInt(MS));
    end;
  end;
begin
  if not gHKMoveBusy then
  begin
    gHKMoveBusy := True;
    P2.X := P.X;
    P2.Y := P.Y;
    L1 := MakeLong(P.X, P.Y);
    GetCursorPos(P);
    W := WindowFromPoint(P);
    Windows.ScreenToClient(W, P);
    L2 := MakeLong(P.X, P.Y);
    if Back then
    begin
      { обмен местами: клик уходит туда, откуда пришла мышь }
      T := L2;
      L2 := L1;
      L1 := T;
      P3 := P;
      P := P2;
      P2 := P3;
    end;
    PostMessage(W, $20, W, MakeLong(0, $201));
    PostMessage(W, $201, 0, L2);
    if not cbMoveLeftCl.Checked then
      Wait(Edit1.Text);
    PostMessage(W, $200, 1, L1);
    if not Back then
      if cbMoveLeftCl.Checked then
      begin
        Windows.ClientToScreen(W, P2);
        SetCursorPos(P2.X, P2.Y);
      end;
    Wait(Edit1.Text);
    if N <> 0 then
    begin
      S := IntToStr(N);
      for I := 1 to Length(S) do
        PostMessage(W, $102, Byte(S[I]), 0);
    end;
    PostMessage(W, $102, $D, 0);
    Wait(Edit2.Text);
    PostMessage(W, $202, 0, L1);
    if not Back then
      if cbMoveLeftCl.Checked then
      begin
        Windows.ClientToScreen(W, P);
        SetCursorPos(P.X, P.Y);
      end;
    gHKMoveBusy := False;
  end;
end;

procedure TfmSecond.cbEnableHKClick(Sender: TObject);
var
  I: Integer;
  K: Integer;
  C: TCheckBox;
begin
  { Галка «горячие клавиши включены»: разрешает/запрещает все чекбоксы клавиш
    и переставляет пометки 'X' в списке скриптовых клавиш. Номер записи --
    удвоенный номер скрипта плюс $22, второй элемент пары -- пауза. }
  if cbEnableHK.Checked then
  begin
    if gHKBusy then
      Exit;
    for I := 0 to $21 do
    begin
      C := FindComponent('cb' + gHKEntrieslw[I].Name) as TCheckBox;
      C.Enabled := True;
      C.Checked := gHKEntrieslw[I].Enabled;
    end;
    I := 0;
    while I <= sghkScriptHKList.RowCount * 2 - 1 do
    begin
      K := StrToInt(sghkScriptHKList.Cells[1, I div 2]) * 2 + $22 + I mod 2;
      if gHKEntrieslw[K].Enabled then
      begin
        if Pos('_Pause_', gHKEntrieslw[K].Name) > 0 then
        begin
          gHKMode := 4;
          gHKSela := 5;
        end
        else
        begin
          gHKMode := 3;
          gHKSela := 0;
        end;
        sghkScriptHKList.Cells[gHKSela, I div 2] := 'X';
        sghkScriptHKList.Row := I div 2;
        cbhk1Click(sghkScriptHKList);
      end;
      Inc(I);
    end;
  end
  else
  begin
    gHKDisabled := True;
    for I := 0 to $21 do
      if I <> $20 then
      begin
        C := FindComponent('cb' + gHKEntrieslw[I].Name) as TCheckBox;
        C.Enabled := False;
        C.Checked := False;
      end;
    I := 0;
    while I <= sghkScriptHKList.RowCount * 2 - 1 do
    begin
      K := StrToInt(sghkScriptHKList.Cells[1, I div 2]) * 2 + $22 + I mod 2;
      if Pos('_Pause_', gHKEntrieslw[K].Name) > 0 then
      begin
        gHKMode := 4;
        gHKSela := 5;
      end
      else
      begin
        gHKMode := 3;
        gHKSela := 0;
      end;
      if sghkScriptHKList.Cells[gHKSela, I div 2] = 'X' then
      begin
        sghkScriptHKList.Cells[gHKSela, I div 2] := ' ';
        sghkScriptHKList.Row := I div 2;
        cbhk1Click(sghkScriptHKList);
      end;
      Inc(I);
    end;
    gHKDisabled := False;
  end;
  K := K;
end;

procedure TfmSecond.HotKeyUopUO(Sender: TObject);
var
  H: HWND;
begin
  if Handle = GetActiveWindow then
  begin
    if miSCPscript.Checked then
      H := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])].ClientWnd
    else if miSCPtopuo.Checked then
      H := FindWindow('Ultima Online', nil)
    else
      H := fmSecondfj.FTargetWnd;
    if H <> 0 then
      SetForegroundWindow(H);
  end
  else
  begin
    fmSecondfj.Show;
    fmSecondfj.WindowState := wsNormal;
    SetForegroundWindow(Handle);
  end;
end;

procedure TfmSecond.mmHelpClick(Sender: TObject);
var
  Res: Integer;
  Stream: TResourceStream;
begin
  { Окно справки строится кодом: форма без рамки, внутри TMemo во всю площадь,
    текст берётся из ресурса (номер зависит от языка). WindowProc у мемо
    подменяется, прежний сохраняется в глобальной. }
  if gDlg5966DC = nil then
  begin
    gDlg5966DC := TForm.Create(fmSecondfj);
    gDlg5966DC.Parent := nil;
    gDlg5966DC.BorderStyle := bsSizeToolWin;
    gDlg5966DC.Height := $202;
    gDlg5966DC.Width := $1E2;
    gDlg5966DC.Position := poScreenCenter;
    if gLangOffsety > 0 then
      gDlg5966DC.Caption := LoadStr(gLangOffsety + $1A7)
    else
      gDlg5966DC.Caption := 'Справка';
    gDlg5966DC.OnCloseQuery := HelpFormClose;
    FHelpMemo := TMemo.Create(gDlg5966DC);
    FHelpMemo.Parent := gDlg5966DC;
    FHelpMemo.HideSelection := False;
    FHelpMemo.Lines.Add('under construction');
    with FHelpMemo do
    begin
      Left := 0;
      Top := 0;
      Align := alClient;
      TabStop := False;
      Color := $FF000018;
      ReadOnly := True;
      ScrollBars := ssVertical;
      TabOrder := 0;
    end;
    Res := 1;
    if (gLangOffsety <> $7D0) and (gLangOffsety <> 0) then
      Res := Res + 10;
    Stream := TResourceStream.CreateFromID(HInstance, Res, PChar(10));
    FHelpMemo.Lines.LoadFromStream(Stream);
    Stream.Free;
    if miShowHelpOnTaskbar.Checked then
      SetWindowLong(gDlg5966DC.Handle, GWL_EXSTYLE,
        GetWindowLong(gDlg5966DC.Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
    gOldLogProc := FHelpMemo.WindowProc;
    FHelpMemo.WindowProc := HelpMemoWndProc;
  end;
  if gDlg5966DC.Visible then
    gDlg5966DC.Visible := False
  else
  begin
    gDlg5966DC.Visible := True;
    FHelpMemo.SetFocus;
  end;
end;

procedure TfmSecond.miScriptHelpClick(Sender: TObject);
var
  P: Integer;
  I, Q: Integer;
  Stream: TResourceStream;
  L: TStringList;
  V: Integer;

  procedure Nop;
  begin
    if Self = nil then
      Exit;
  end;
begin
  { Окно справки по скриптам: строится кодом при первом вызове, дальше только
    показывается/прячется. Внутри pcHelp: вкладка истории (TMemo в fld_1430)
    и вкладка вики (TWebBrowser); история берётся из ресурсов RCDATA. }
  if gHelpForm = nil then
  begin
    cbWikiList.DropDownCount := $14;
    gHelpForm := TForm.Create(fmSecondfj);
    gHelpForm.Parent := nil;
    gHelpForm.BorderStyle := bsSizeable;
    V := gHelpRect.Top;
    if V <> -1 then
      gHelpForm.Top := V
    else
      gHelpForm.Top := Top;
    V := gHelpRect.Left;
    if V <> -1 then
      gHelpForm.Left := V
    else
      gHelpForm.Left := Left + Width;
    V := gHelpRect.Right;
    if V <> -1 then
      gHelpForm.Width := V
    else
      gHelpForm.Width := Screen.Width div 2;
    V := gHelpRect.Bottom;
    if V <> -1 then
      gHelpForm.Height := V
    else
      gHelpForm.Height := Screen.Height div 2;
    if gHelpRect.Top = -1 then
      gHelpForm.Position := poScreenCenter;
    gHelpForm.OnCloseQuery := ScriptHelpFormClose;
    gHelpForm.OnKeyPress := FormsKeyPress;
    gHelpForm.KeyPreview := True;
    pcHelp.Parent := gHelpForm;
    pcHelp.Visible := True;
    pcHelp.Align := alClient;
    TMemo(fld_1430) := TMemo.Create(gHelpForm);
    TMemo(fld_1430).Parent := tsHistory;
    TMemo(fld_1430).HideSelection := False;
    TMemo(fld_1430).Lines.Add('under construction');
    with TMemo(fld_1430) do
    begin
      Left := 0;
      Top := 0;
      Align := alClient;
      TabStop := False;
      Color := $FF000018;
      ReadOnly := True;
      ScrollBars := ssVertical;
      TabOrder := 0;
    end;
    gbFind.Parent := tsHistory;
    gbFind.Top := 0;
    gbFind.Align := alTop;
    gbFind.Visible := True;
    if miShowHelpOnTaskbar.Checked then
      SetWindowLong(gHelpForm.Handle, GWL_EXSTYLE,
        GetWindowLong(gHelpForm.Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
    gOldHelpProc2 := TWinControl(Pointer(fld_1430)).WindowProc;
    TWinControl(Pointer(fld_1430)).WindowProc := HelpMemoWndProc2;
    if wbWiki = nil then
    begin
      wbWiki := TWebBrowser.Create(Self);
      { Parent у TWebBrowser перекрыт автоматизационным IDispatch, отсюда каст }
      TWinControl(wbWiki).Parent := tsWiki;
      with wbWiki do
      begin
        OnBeforeNavigate2 := WebBrowserBeforeNavigate2;
        OnCommandStateChange := WebBrowserCommandStateChange;
        Left := 0;
        Top := 0;
        Width := $21;
        Height := $1A;
        Align := alClient;
        TabOrder := 0;
        TabStop := True;
      end;
    end;
    if not DirectoryExists(gWikiPath) then
    begin
      CreateDir(gWikiPath);
      spUnpackWikiClick(Sender);
    end;
    WikiRefreshList(Self);
    wbWiki.Navigate(gWikiPath + 'Введение_в_пилотный_скриптинг' + '.htm');
    eFindText.Modified := True;
  end;
  if gHelpForm.Visible then
    gHelpForm.Visible := False
  else
  begin
    P := 2;
    if (gLangOffsety <> $7D0) and (gLangOffsety <> 0) then
      P := P + 10;
    Stream := TResourceStream.CreateFromID(HInstance, P, PChar(10));
    TMemo(fld_1430).Lines.LoadFromStream(Stream);
    Stream.Free;
    if gLangOffsety > 0 then
      gHelpForm.Caption := LoadStr(gLangOffsety + $1A7) + ', ' +
        LoadStr(gLangOffsety + $EE)
    else
      gHelpForm.Caption := 'Справка, История развития программы';
    L := TStringList.Create;
    P := 1;
    if (gLangOffsety <> $7D0) and (gLangOffsety <> 0) then
      P := P + 10;
    Stream := TResourceStream.CreateFromID(HInstance, P, PChar(10));
    L.LoadFromStream(Stream);
    Stream.Free;
    TMemo(fld_1430).Lines.AddStrings(L);
    P := $66;
    Stream := TResourceStream.CreateFromID(HInstance, P, PChar(10));
    L.LoadFromStream(Stream);
    Stream.Free;
    if L.Count > 0 then
    begin
      TMemo(fld_1430).Lines.Add('');
      TMemo(fld_1430).Lines.Add('2.42');
      { вычистить html-теги: пока в строке есть <...>, вырезать их }
      I := 0;
      while I <= L.Count - 1 do
      begin
        if L[I] = '' then
          L.Delete(I)
        else
        begin
          P := Pos('<', L[I]);
          while P > 0 do
          begin
            Q := PosEx('>', L[I], P);
            if Q > 0 then
            begin
              L[I] := Copy(L[I], 1, P - 1) +
                Copy(L[I], Q + 1, Length(L[I]));
              P := PosEx('<', L[I], P);
            end
            else
              P := PosEx('<', L[I], P + 1);
          end;
          Inc(I);
        end;
      end;
      TMemo(fld_1430).Lines.AddStrings(L);
    end;
    L.Free;
    gHelpForm.Visible := True;
    pcHelp.TabIndex := 0;
    pcHelpChange(Sender);
  end;
end;

procedure TfmSecond.miPluginSampleClick(Sender: TObject);
var
  Res: TResourceStream;
  TS: TTabSheet;
  S: string;
  PC: TPageControl;
  M: TMemo;
begin
  if gDlg5966FC = nil then
  begin
    gDlg5966FC := TForm.Create(fmSecondfj);
    gDlg5966FC.Parent := nil;
    gDlg5966FC.BorderStyle := bsSizeToolWin;
    gDlg5966FC.Height := $248;
    gDlg5966FC.Width := $1C4;
    gDlg5966FC.Position := poScreenCenter;
    if gLangOffsety > 0 then
      gDlg5966FC.Caption := LoadStr(gLangOffsety + $17E)
    else
      gDlg5966FC.Caption := 'Пример плагина';
    gDlg5966FC.OnKeyPress := FormsKeyPress;
    gDlg5966FC.KeyPreview := True;
    gDlg5966FC.OnCloseQuery := PluginSampleFormClose;
    PC := TPageControl.Create(gDlg5966FC);
    PC.Parent := gDlg5966FC;
    PC.Left := 0;
    PC.Top := 0;
    PC.Align := alClient;
    TS := TTabSheet.Create(PC);
    TS.PageControl := PC;
    TS.Caption := 'Delphi';
    FHelpMemo := TMemo.Create(gDlg5966FC);
    FHelpMemo.Parent := TS;
    FHelpMemo.HideSelection := False;
    FHelpMemo.Lines.Add('under construction');
    M := FHelpMemo;
    M.Left := 0;
    M.Top := 0;
    M.Align := alClient;
    M.TabStop := False;
    M.Color := $FF000018;
    M.ReadOnly := True;
    M.ScrollBars := ssVertical;
    M.TabOrder := 0;
    Res := TResourceStream.CreateFromID(HInstance, 10, RT_RCDATA);
    FHelpMemo.Lines.LoadFromStream(Res);
    Res.Free;
    TS := TTabSheet.Create(PC);
    TS.PageControl := PC;
    TS.Caption := 'C++';
    M := TMemo.Create(gDlg5966FC);
    M.Parent := TS;
    M.HideSelection := False;
    M.Lines.Add('under construction');
    M.Left := 0;
    M.Top := 0;
    M.Align := alClient;
    M.TabStop := False;
    M.Color := $FF000018;
    M.ReadOnly := True;
    M.ScrollBars := ssVertical;
    M.TabOrder := 0;
    Res := TResourceStream.CreateFromID(HInstance, 20, RT_RCDATA);
    M.Lines.LoadFromStream(Res);
    Res.Free;
  end;
  if gDlg5966FC.Visible then
    gDlg5966FC.Visible := False
  else
  begin
    gDlg5966FC.Visible := True;
    FHelpMemo.SetFocus;
  end;
end;

procedure TfmSecond.HotKeyMes(Sender: TObject);
begin
  sbMacros.Down := not sbMacros.Down;
  sbMacrosClick(Sender);
end;

procedure TfmSecond.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Sect: string;
  S: string;
  N: Integer;
  Sub: TMenuItem;
  Allow: Boolean;
  Ini: TMyMemIniFile;
  Chk: Boolean;
  Idx: Integer;
begin
  { Закрытие формы: снимаются перехваты оконных процедур, гасятся таймеры,
    изменённые скрипты автосохраняются, настройки уходят в ini, потоки скриптов
    останавливаются, и только потом Application.Terminate. }
  ClipCursor(nil);
  Application.OnDeactivate := nil;
  if gHotKeyMgr <> nil then
    gHotKeyMgr.Free;
  fmSecondfj.OnResize := nil;
  Timer1.Enabled := False;
  if (gDlg5966F8c6 <> nil) and (mLog <> nil) then
    mLog.WindowProc := gOldLogProc;
  if TWinControl(Pointer(fld_1430)) <> nil then
    TWinControl(Pointer(fld_1430)).WindowProc := gOldHelpProc2;
  try
    tScript.WindowProc := gOldTabChange;
  except
  end;
  tTabRefresh.Enabled := False;
  tScript.OwnerDraw := False;
  tScriptDesc.OwnerDraw := False;
  if gObjA34 <> nil then
    gObjA34.Free;
  if gObjA38 <> nil then
    gObjA38.Free;
  if gObjA3C <> nil then
    gObjA3C.Free;
  if sbDownloadWiki.Down then
  begin
    sbDownloadWiki.Down := False;
    sbDownloadWikiClick(Sender);
  end;
  if edScript.Modified then
  begin
    N := StrToInt(tScript.Tabs[tScript.TabIndex]);
    gScriptso3[N].StopRequested := True;
    gScriptso3[N].Flag91 := False;
    Allow := True;
    FFlag1467 := True;
    tScriptChanging(Sender, Allow);
  end;
  N := 0;
  while N <= 99 do
  begin
    try
      if gScriptso3[N] <> nil then
      begin
        Chk := miSaveScriptsOnExit.Checked;
        if Chk then
          if gScriptso3[N].Modified then
          begin
            tScript.OnChanging := nil;
            S := gScriptso3[N].Name;
            Idx := tScript.Tabs.IndexOf(S);
            tScript.TabIndex := Idx;
            tScriptChange(Sender);
            if gScriptso3[N].Title = '' then
              gScriptso3[N].Title := 'Scripts\autosaved_' + gScriptso3[N].Name + '.txt'
            else
            begin
              S := gScriptso3[N].Title;
              if Copy(S, 1, 2) <> '\\' then
                if Copy(S, 2, 1) <> ':' then
                  S := gTempFilefv + S;
            end;
            miSave.Click;
          end;
        gScriptso3[N].StopRequested := True;
      end;
    except
    end;
    Inc(N);
  end;
  try
    if gLogFileOpenar then
    begin
      gLogFileClosedr := True;
      {$I-} CloseFile(gLogFilejr); {$I+}
    end;
    if FClientProcess > 0 then
      FileClose(FClientProcess); { *Преобразовано из CloseHandle* }
    if gClientThread > 0 then
      FileClose(gClientThread); { *Преобразовано из CloseHandle* }
    if not ((Sender is TMenuItem) and
            ((Sender as TMenuItem).Name = 'miExitWoSave')) then
    begin
      Ini := TMyMemIniFile.Create(FOptionsFile);
      Sect := 'LastScripts';
      Sub := mnHotKey.Items[0].Items[3];
      for N := 0 to Sub.Count - 1 do
      begin
        if N > 9 then
          Break;
        Ini.WriteString(Sect, 'Line_' + IntToStr(N), Sub.Items[N].Caption);
      end;
      if not miSaveOnExit.Checked then
      begin
        Sect := 'Script';
        SaveScriptSection(Ini, Sect);
        Sect := 'UoPilot';
        SaveUoPilotSection(Ini, Sect);
      end;
      Sect := 'UoPilot';
      Ini.WriteInteger(Sect, 'Fl', fld_1460);
      Ini.Free;
      if miSaveOnExit.Checked then
        miSaveOptionsClick(Sender);
    end;
  except
    SetForegroundWindow(Application.Handle);
    MsgBox('Error on exit', 'UOPilot Error Message', 0);
  end;
  fmSecondfj.edScript.Enabled := False;
  { gPlugins объявлена указателем: сама переменная живёт в чужом юните }
  if Pointer(gPluginListjr) <> nil then
    if gPluginListjr.Count > 0 then
      DonePlugins(Self, '');
  gPluginListjr.Free;
  N := 0;
  while N <= 99 do
  begin
    if gScriptso3[N] <> nil then
    begin
      if not Assigned(gScriptso3[N].OnTerminate) then
      begin
        gScriptso3[N].Free;
        gScriptso3[N] := nil;
      end
      else
      begin
        if not gScriptso3[N].Suspended then
          gScriptso3[N].Suspend;
        gScriptso3[N].FreeOnTerminate := False;
        gScriptso3[N].StopRequested := True;
        gScriptso3[N].LogToParent := True;
        gScriptso3[N].Title := '';
        gScriptso3[N].Resume;
        gScriptso3[N].WaitFor;
        gScriptso3[N].Free;
        gScriptso3[N] := nil;
      end;
    end;
    Inc(N);
  end;
  UnLoadLuaLib;
  TObject(Pointer(fld_1428)).Free;
  edScript.Free;
  Application.Terminate;
end;

procedure TfmSecond.sbSControlClick(Sender: TObject);
begin
  if gDlg5966E4 = nil then
  begin
    gDlg5966E4 := TForm.Create(fmSecondfj);
    gDlg5966E4.Parent := nil;
    gDlg5966E4.Font := fmSecondfj.Font;
    gDlg5966E4.BorderStyle := bsToolWindow;
    if miSOTShipControl.Checked then
      gDlg5966E4.FormStyle := fsStayOnTop
    else
      gDlg5966E4.FormStyle := fsNormal;
    gDlg5966E4.ClientHeight := gbShipControl.Height + 2;
    gDlg5966E4.ClientWidth := gbShipControl.Width + 2 + 2;
    gDlg5966E4.Caption := 'Ship Control';
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
    if (gWinPos[8] <> -1) and (gWinPos[9] <> -1) and miSPosSC.Checked then
    begin
      gDlg5966E4.Top := gWinPos[8];
      gDlg5966E4.Left := gWinPos[9];
    end
    else
    begin
      gDlg5966E4.Top := Top;
      if Assigned(gDlg5966E8) then
        gDlg5966E4.Top := gDlg5966E4.Top + gDlg5966E8.Height;
      if Assigned(gDlg5966F4) then
        gDlg5966E4.Top := gDlg5966E4.Top + gDlg5966F4.Height;
      gDlg5966E4.Left := Left + Width;
      if (gDlg5966E4.Left + gDlg5966E4.Width) > Screen.DesktopWidth then
        gDlg5966E4.Left := Left - gDlg5966E4.Width;
    end;
    gDlg5966E4.OnCloseQuery := ShipControlClose;
    gbShipControl.Parent := gDlg5966E4;
    gbShipControl.Visible := True;
    gbShipControl.Top := 0;
    gbShipControl.Left := 2;
    if miSOTShipControl.Checked then
      SetWindowPos(gDlg5966E4.Handle, HWND_TOPMOST, 1, 1, 1, 1,
        SWP_NOSIZE or SWP_NOMOVE);
  end;

  if gDlg5966E4.Visible then
  begin
    gDlg5966E4.Visible := False;
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end
  else
  begin
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
    gDlg5966E4.Visible := True;
  end;
  sbSControl.Down := gDlg5966E4.Visible;
end;

procedure TfmSecond.AppActivateKeepTopmost(Sender: TObject);
begin
  if cbSOT.Checked then
    SetWindowPos(fmSecondfj.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg596718 <> nil) and gDlg596718.Visible then
    SetWindowPos(gDlg596718.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg5966E4 <> nil) and gDlg5966E4.Visible and miSOTShipControl.Checked then
    SetWindowPos(gDlg5966E4.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg5966E8 <> nil) and gDlg5966E8.Visible and miSOTHouseControl.Checked then
    SetWindowPos(gDlg5966E8.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg5966EC <> nil) and gDlg5966EC.Visible and miSOTScriptWindow.Checked then
    SetWindowPos(gDlg5966EC.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg5966F0 <> nil) and gDlg5966F0.Visible and miSOTCharParameters.Checked then
    SetWindowPos(gDlg5966F0.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg5966F4 <> nil) and gDlg5966F4.Visible and miSOTAnimalVendor.Checked then
    SetWindowPos(gDlg5966F4.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gDlg5966F8c6 <> nil) and gDlg5966F8c6.Visible and miSOTLogWindow.Checked then
    SetWindowPos(gDlg5966F8c6.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gAboutForm <> nil) and gAboutForm.Visible then
    SetWindowPos(gAboutForm.Handle, HWND_TOPMOST, 1, 1, 1, 1, $13);
  if (gHelpForm <> nil) and gHelpForm.Visible then
    SetWindowPos(gHelpForm.Handle, HWND_TOP, 1, 1, 1, 1, $13);
end;

procedure TfmSecond.sbMfHSClick(Sender: TObject);
begin
  fmSecondfj.Visible := not fmSecondfj.Visible;
  if fmSecondfj.Visible then
    sbMfHS.Caption := 'Hide'
  else
    sbMfHS.Caption := 'Show';
end;

procedure TfmSecond.sbMfHHClick(Sender: TObject);
begin
  fmSecondfj.Visible := not fmSecondfj.Visible;
  if fmSecondfj.Visible then
    (Sender as TSpeedButton).Caption := 'Hide'
  else
    (Sender as TSpeedButton).Caption := 'Show';
end;

procedure TfmSecond.Timer1Timer(Sender: TObject);
type
  { Блок состояния персонажа в памяти клиента UO. Читается одним
    ReadProcessMemory, поэтому поля названы по смещениям: смысл известен только
    у части из них. Новый формат -- 80 байт, старый -- 60. }
  TCharStat = packed record
    Name: array[0..31] of Char;        { +$00 }
    S20: SmallInt;                     { +$20  сила }
    S22: SmallInt;                     { +$22  ловкость }
    S24: SmallInt;                     { +$24  интеллект }
    S26: SmallInt;                     { +$26  жизнь }
    S28: SmallInt;                     { +$28  жизнь макс. }
    S2A: SmallInt;                     { +$2A }
    S2C: SmallInt;                     { +$2C }
    S2E: SmallInt;                     { +$2E }
    S30: SmallInt;                     { +$30 }
    S32: SmallInt;                     { +$32 }
    Gold: Cardinal;                    { +$34 }
    S38: Cardinal;                     { +$38 }
    S3C: Word;                         { +$3C }
    S3E: Word;                         { +$3E }
    S40: Byte;                         { +$40 }
    S41: Byte;                         { +$41 }
    S42: Word;                         { +$42 }
    S44: Word;                         { +$44 }
    S46: Word;                         { +$46 }
    S48: Word;                         { +$48 }
    S4A: Word;                         { +$4A }
    S4C: Word;                         { +$4C }
    S4E: Word;                         { +$4E }
  end;
  TCharStatOld = packed record
    Name: array[0..31] of Char;        { +$00 }
    O20: Word;
    O22: Word;
    O24: Word;
    O26: Word;                         { +$26 }
    O28: Word;                         { +$28 }
    O2A: Word;
    O2C: Word;
    O2E: Word;
    O30: Word;
    O32: Word;
    Gold: Cardinal;                    { +$34 }
    O38: Word;                         { +$38 }
    O3A: Word;                         { +$3A }
  end;
var
  Addr: Cardinal;
  Rd: DWORD;
  LM: string;
  Dir: string;
  S: string;
  W2: array[0..1] of Word;
  T: string;
  B: Byte;
  W3: array[0..2] of SmallInt;
  L1: TStringList;
  L2: TStringList;
  Wnd: HWND;
  Ph: THandle;
  Pid: DWORD;
  Opened: Boolean;
  Buf: array[0..255] of Char;
  R2: TCharStatOld;
  R1: TCharStat;
  Sk: array[0..114] of SmallInt;
  Cd: array[0..2] of Integer;
  I: Integer;
  N: Cardinal;
  P: PChar;
  PW: PWideChar;
const
  gNoValue: string = 'error';
begin
  { Главный таймер: читает состояние персонажа из памяти клиента и раскладывает
    его по сетке умений, двум панелям параметров и заголовку окна игры.
    Откуда брать процесс -- решают два переключателя. }
  Opened := False;
  if miSCPscript.Checked then
  begin
    Wnd := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])].ClientWnd;
    Ph := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])].ProcessHandle;
  end
  else if miSCPtopuo.Checked then
  begin
    Wnd := FindWindow('Ultima Online', nil);
    GetWindowThreadProcessId(Wnd, @Pid);
    Ph := OpenProcess($418, False, Pid);
    Opened := True;
  end
  else
  begin
    Wnd := fmSecondfj.FTargetWnd;
    Ph := fmSecondfj.FClientProcess;
  end;
  if Wnd = 0 then Exit;
  if sbShowSkills.Down then
  begin
    { Таблица умений: 58 записей по два байта подряд. }
    Addr := ClientAddr[19, cbClVer.ItemIndex];
    ReadProcessMemory(Ph, Pointer(Addr), @Sk, $E6, Rd);
    for I := 0 to $39 do
    begin
      sgSkills.Cells[0, I] := IntToStr(I);
      sgSkills.Cells[1, I] := gSkillNames[I].Name;
    end;
    if ClientAddr[6, cbClVer.ItemIndex] >= 4 then
      sgSkills.Cells[1, 15] := gSkillNames[15].Short;
    { У версий 4 и 5 значения лежат во второй половине блока -- сдвигаем. }
    case ClientAddr[6, cbClVer.ItemIndex] of
      4, 5:
        for I := 1 to 57 do
          Sk[I] := Sk[I + 56];
    end;
    for I := 0 to $39 do
    begin
      S := IntToStr(Sk[I]);
      Insert('.', S, Length(S));
      if S[1] = '.' then
        Insert('0', S, 0);
      sgSkills.Cells[2, I] := S;
    end;
    { Пузырьковая сортировка по названию: строка переставляется целиком. }
    if miSortSkillList.Checked then
      for I := 0 to sgSkills.RowCount - 1 do
        for Addr := I + 1 to sgSkills.RowCount - 1 do
          if sgSkills.Cells[1, Addr] < sgSkills.Cells[1, I] then
          begin
            S := sgSkills.Cells[2, Addr];
            sgSkills.Cells[2, Addr] := sgSkills.Cells[2, I];
            sgSkills.Cells[2, I] := S;
            S := sgSkills.Cells[0, Addr];
            sgSkills.Cells[0, Addr] := sgSkills.Cells[0, I];
            sgSkills.Cells[0, I] := S;
            S := sgSkills.Cells[1, Addr];
            sgSkills.Cells[1, Addr] := sgSkills.Cells[1, I];
            sgSkills.Cells[1, I] := S;
          end;
  end;
  L1 := TStringList.Create;
  { Указатель на блок состояния: у версии 1 он ещё раз разыменовывается. }
  Addr := ClientAddr[7, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if ClientAddr[6, cbClVer.ItemIndex] = 1 then
  begin
    if Addr < $FFFFFFFF then
      Addr := Addr + $8C;
    ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  end;
  case ClientAddr[6, cbClVer.ItemIndex] of
    5..7:
      begin
        if ClientAddr[6, cbClVer.ItemIndex] = 7 then
          Addr := Addr + 8;
        Addr := Addr + $C4;
        ReadProcessMemory(Ph, Pointer(Addr), @R1, $50, Rd);
        if Rd = $50 then
        begin
          P := @R1;
          lName.Caption := P;
          L1.Add(IntToStr(R1.S26) + '/' + IntToStr(R1.S28) + ' - ' + IntToStr(R1.S20));
          L1.Add(IntToStr(R1.S2E) + '/' + IntToStr(R1.S30) + ' - ' + IntToStr(R1.S24));
          L1.Add(IntToStr(R1.S2A) + '/' + IntToStr(R1.S2C) + ' - ' + IntToStr(R1.S22));
          L1.Add(IntToStr(R1.Gold));
          Addr := ClientAddr[5, cbClVer.ItemIndex];
          ReadProcessMemory(Ph, Pointer(Addr), @W2, 4, Rd);
          L1.Add(IntToStr(W2[0]) + '/' + IntToStr(W2[1]));
          W2[0] := 0;
          W2[1] := 0;
          L1.Add(IntToStr(R1.S3C) + '.' + IntToStr(R1.S42) + '.' + IntToStr(R1.S44) + '.' + IntToStr(R1.S46) + '.' + IntToStr(R1.S48));
          L1.Add(IntToStr(R1.S4E) + '-' + IntToStr(R1.S4C));
          L1.Add(IntToStr(R1.S40) + '/' + IntToStr(R1.S41) + '     ' + IntToStr(R1.S4A));
        end
        else
          for Addr := 1 to 6 do
            L1.Add(gNoValue);
      end;
  else
    begin
      if Addr < $FFFFFFFF then
        Addr := Addr + $A4;
      ReadProcessMemory(Ph, Pointer(Addr), @R2, $3C, Rd);
      if Rd = $3C then
      begin
        P := @R2;
        lName.Caption := P;
        L1.Add(IntToStr(R2.O26) + '/' + IntToStr(R2.O28));
        L1.Add(IntToStr(R2.O2E) + '/' + IntToStr(R2.O30));
        L1.Add(IntToStr(R2.O2A) + '/' + IntToStr(R2.O2C));
        L1.Add(IntToStr(R2.Gold));
        L1.Add(IntToStr(R2.O3A) + '/' + IntToStr(R2.O28 * 4 + 30));
        L1.Add(IntToStr(R2.O38));
      end
      else
        for Addr := 1 to 6 do
          L1.Add(gNoValue);
    end;
  end;
  mParamValue.Lines.Clear;
  mParamValue.Lines.Assign(L1);
  { Текст последнего сообщения клиента: двойное разыменование, потом 256 байт
    порциями по 16 -- так читается строка, лежащая не подряд. }
  Addr := ClientAddr[8, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
    if Rd = 4 then
    begin
      N := 0;
      repeat
        ReadProcessMemory(Ph, Pointer(Addr + N), @Buf[N], $10, Rd);
        Inc(N, $10);
      until N >= $100;
      Rd := $100;
    end
    else
      Rd := 0;
  end
  else
    Rd := 0;
  if Rd = $100 then
  begin
    N := 0;
    T := '';
    { Второй байт меньше пробела -- значит строка в UTF-16. }
    if Buf[1] >= ' ' then
    begin
      while Buf[N] <> #0 do
      begin
        T := T + Buf[N];
        Inc(N);
      end;
    end
    else
    begin
      PW := @Buf;
      T := WideCharToString(PW);
    end;
    LM := T;
  end
  else
    LM := gNoValue;
  { Сообщение «выпито зелье»: сверяется и целиком, и без средней части. }
  if (LM = gDrinkMsg1 + gDrinkMsg3) or (LM = gDrinkMsg1 + gDrinkMsg2 + gDrinkMsg3) then
  begin
    if gDrinkArmed <> 0 then
      LM[1] := 'y';
  end
  else
    if gDrinkTicks <= 0 then
      gDrinkArmed := 0;
  if gDrinkTicks <= 0 then
    if (LM = gDrinkMsg1 + gDrinkMsg3) or (LM = gDrinkMsg1 + gDrinkMsg2 + gDrinkMsg3) then
    begin
      gDrinkTicks := SpinEdit2.Value * 2;
      gDrinkArmed := 1;
    end;
  mLM.Lines.Clear;
  mLM.Lines.Add(LM);
  mLM.SelStart := 0;
  mLM.SelLength := 0;
  L2 := TStringList.Create;
  { Координаты: три числа подряд, выводятся в обратном порядке. }
  Addr := ClientAddr[9, cbClVer.ItemIndex];
  if Addr > 0 then
    Addr := Addr - 4;
  ReadProcessMemory(Ph, Pointer(Addr), @Cd, $C, Rd);
  if Rd = $C then
  begin
    L2.Add(IntToStr(Cd[2]));
    L2.Add(IntToStr(Cd[1]));
    L2.Add(IntToStr(Cd[0]));
  end
  else
    for Addr := 1 to 3 do
      L2.Add(gNoValue);
  ReadProcessMemory(Ph, Pointer(ClientAddr2[4, cbClVer.ItemIndex]), @B, 1, Rd);
  if Rd = 1 then
  begin
    case B of
      0: Dir := 'N';
      1: Dir := 'NE';
      2: Dir := 'E';
      3: Dir := 'SE';
      4: Dir := 'S';
      5: Dir := 'SW';
      6: Dir := 'W';
      7: Dir := 'NW';
    else
      Dir := '-';
    end;
    L2.Add(IntToStr(B) + ' (' + Dir + ')');
  end
  else
    L2.Add(gNoValue);
  Addr := ClientAddr2[1, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    if miShowHex.Checked then
    begin
      S := IntToHex(Addr, 8);
      if S[1] <> '0' then
        S := '0' + S;
    end
    else
      S := IntToStr(Addr);
  end
  else
    S := gNoValue;
  L2.Add(S);
  Addr := ClientAddr[15, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    if miShowHex.Checked then
    begin
      S := IntToHex(Addr, 4);
      if S[1] <> '0' then
        S := '0' + S;
    end
    else
      S := IntToStr(Addr);
  end
  else
    S := gNoValue;
  L2.Add(S);
  Addr := ClientAddr2[2, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    if miShowHex.Checked then
    begin
      S := IntToHex(Addr, 8);
      if S[1] <> '0' then
        S := '0' + S;
    end
    else
      S := IntToStr(Addr);
  end
  else
    S := gNoValue;
  L2.Add(S);
  Addr := ClientAddr[18, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @W3, 6, Rd);
  if Rd = 6 then
  begin
    L2.Add(IntToStr(W3[0]));
    L2.Add(IntToStr(W3[1]));
    L2.Add(IntToStr(W3[2]));
  end
  else
    for Addr := 1 to 3 do
      L2.Add(gNoValue);
  Addr := ClientAddr[17, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd <> 4 then
    Addr := $A;
  if Rd = 4 then
  begin
    case Addr of
      0: S := IntToStr(Addr) + ' (none)';
      1: S := IntToStr(Addr) + ' (Item)';
      2: S := IntToStr(Addr) + ' (Ground)';
      3: S := IntToStr(Addr) + ' (Static)';
    else
      S := IntToStr(Addr) + ' (unknown)';
    end;
  end
  else
    S := gNoValue;
  L2.Add(S);
  Addr := ClientAddr[14, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    if miShowHex.Checked then
    begin
      S := IntToHex(Addr, 8);
      if S[1] <> '0' then
        S := '0' + S;
    end
    else
      S := IntToStr(Addr);
  end
  else
    S := gNoValue;
  L2.Add(S);
  Addr := ClientAddr[13, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    case Addr of
      0..$39: S := gSkillNames[Addr].Name;
    else
      S := 'unknown';
    end;
    S := IntToStr(Addr) + ' (' + S + ')';
    L2.Add(S);
  end
  else
    L2.Add(gNoValue);
  Addr := ClientAddr[12, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    if ClientAddr[11, cbClVer.ItemIndex] <= Addr then
      Addr := Addr - ClientAddr[11, cbClVer.ItemIndex];
    case Addr of
      0..$2B4: S := gItemNamesbq[Addr];
    else
      S := 'unknown';
    end;
    S := IntToStr(Addr) + ' (' + S + ')';
    L2.Add(S);
  end
  else
    L2.Add(gNoValue);
  Addr := ClientAddr[16, cbClVer.ItemIndex];
  ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Rd);
  if Rd = 4 then
  begin
    if miShowHex.Checked then
    begin
      S := IntToHex(Addr, 4);
      if S[1] <> '0' then
        S := '0' + S;
    end
    else
      S := IntToStr(Addr);
  end
  else
    S := gNoValue;
  L2.Add(S);
  mParamValue2.Cols[0] := L2;
  { Заголовок окна игры: к имени персонажа дописывается то, что отмечено. }
  if cbHits.Checked or cbMana.Checked or cbStam.Checked or cbAr.Checked or
     cbWght.Checked or cbGold.Checked or cbShowCoords.Checked or cbDrinkTimer.Checked then
  begin
    GetWindowText(Wnd, Buf, $100);
    P := @Buf;
    I := Pos(')', P);
    if I = 0 then
    begin
      I := Pos('   -   ', P) - 1;
      if I = -1 then
        I := $FF;
    end;
    T := Copy(P, 0, I);
    T := T + '   -';
    if cbHits.Checked then
      T := T + '   h.' + L1[0];
    if cbMana.Checked then
      T := T + '   m.' + L1[1];
    if cbStam.Checked then
      T := T + '   s.' + L1[2];
    if cbAr.Checked then
      T := T + '     a.' + L1[5];
    if cbWght.Checked then
      T := T + '   w.' + L1[4];
    if cbGold.Checked then
      T := T + '   g.' + L1[3];
    if cbShowCoords.Checked then
      T := T + '     ' + L2[0] + '  ' + L2[1];
    if cbDrinkTimer.Checked then
      if gDrinkTicks >= 0 then
      begin
        T := T + '    ' + IntToStr(gDrinkTicks div 2);
        Dec(gDrinkTicks);
      end;
    SetWindowText(Wnd, PChar(T));
  end;
  L2.Free;
  L1.Free;
  if Opened then
    FileClose(Ph); { *Преобразовано из CloseHandle* }
end;

procedure TfmSecond.sbStartUOClick(Sender: TObject);
begin
  if fmSecondfj.sbStartUO.Down then
    gStartUOThread := TStartUOThread.Create(False);
end;

procedure TfmSecond.sbLoginUOClick(Sender: TObject);
begin
  if fmSecondfj.sbLoginUO.Down then
    TLoginUOThread.Create(False);
end;

procedure TLoginUOThread.Execute;
var
  Addr: Cardinal;
  Rd: DWORD;
  Buf: array[0..15] of Char;
  P: PChar;
  N: Cardinal;
begin
  FreeOnTerminate := True;
  gLoginProcess := 0;
  while fmSecondfj.sbLoginUO.Down do
  begin
    if Terminated then
      Exit;
    SysUtils.Sleep(1);
    if gLoginProcess <> 0 then
    begin
      P := '';
      N := 0;
      while Copy(P, 1, 7) <> 'Welcome' do
      begin
        SysUtils.Sleep(100);
        if not fmSecondfj.sbLoginUO.Down then
          Exit;
        Inc(N);
        if N > 10 then
        begin
          N := 0;
          PostMessage(gLoginWnd, WM_LBUTTONDOWN, 0, MakeLong($13E, $10C));
          PostMessage(gLoginWnd, WM_LBUTTONUP, 0, MakeLong($13E, $10C));
          SysUtils.Sleep(100);
          PostMessage(gLoginWnd, WM_LBUTTONDOWN, 0, MakeLong($140, $140));
          PostMessage(gLoginWnd, WM_LBUTTONUP, 0, MakeLong($140, $140));
        end;
        SysUtils.Sleep(100);
        PostMessage(gLoginWnd, WM_LBUTTONDOWN, 0, MakeLong($181, $18F));
        PostMessage(gLoginWnd, WM_LBUTTONUP, 0, MakeLong($181, $18F));
        SysUtils.Sleep(200);
        PostMessage(gLoginWnd, WM_KEYDOWN, VK_ESCAPE, 0);
        PostMessage(gLoginWnd, WM_KEYUP, VK_ESCAPE, $C0000000);
        SysUtils.Sleep(100);
        PostMessage(gLoginWnd, WM_LBUTTONDOWN, 0, MakeLong($267, $1C9));
        PostMessage(gLoginWnd, WM_LBUTTONUP, 0, MakeLong($267, $1C9));
        Addr := ClientAddr[8, fmSecondfj.cbClVer.ItemIndex];
        ReadProcessMemory(gLoginProcess, Pointer(Addr), @Addr, 4, Rd);
        ReadProcessMemory(gLoginProcess, Pointer(Addr), @Addr, 4, Rd);
        ReadProcessMemory(gLoginProcess, Pointer(Addr), @Buf, 16, Rd);
        P := @Buf;
      end;
      fmSecondfj.sbLoginUO.Down := False;
      Exit;
    end;
  end;
  FileClose(gLoginProcess); { *Преобразовано из CloseHandle* }
  gLoginProcess := 0;
end;

function SendKeyString(Wnd: Cardinal; S: string; Mode: Integer;
  Script: Pointer; Phase: Integer): Integer;
begin
  Result := 0;
end;

function EnumKillWindowsProc(H: HWND; L: LPARAM): Boolean; stdcall;
var
  P: ^PChar;
  N: Integer;
  Buf: array[0..255] of Char;
  Pc: PChar;
begin
  { Обратный вызов EnumWindows из ветки `killwindow` диспетчера команд:
    L -- адрес строки-образца в нижнем регистре. Окно, чей заголовок её
    содержит, убивается вместе с процессом. Result всегда True: перебор
    идёт до конца. }
  Result := True;
  if IsWindow(H) and IsWindowVisible(H) then
  begin
    GetWindowText(H, Buf, 256);
    Pc := Buf;
    P := Pointer(L);
    if Length(string(Pc)) <> 0 then
    begin
      N := Pos(P^, AnsiLowerCase(string(Pc)));
      if N <> 0 then
      begin
        GetWindowThreadProcessId(H, @N);
        N := OpenProcess(1, False, N);
        TerminateProcess(N, 5);
        FileClose(N); { *Преобразовано из CloseHandle* }
      end;
    end;
  end;
end;

function EnumStartUOWnd(H: HWND; L: LPARAM): Boolean; stdcall;
var
  Pid: DWORD;
begin
  { Обратный вызов EnumWindows из TStartUOThread.Execute: ищет видимое окно,
    принадлежащее только что запущенному процессу клиента. Найдя окно,
    возвращает False и тем обрывает перебор. }
  Result := True;
  if IsWindow(H) and IsWindowVisible(H) then
  begin
    GetWindowThreadProcessId(H, @Pid);
    if gStartUOThread.ProcId = Pid then
    begin
      Result := False;
      gStartUOThread.Wnd := H;
      gStartUOThread.Pid := Pid;
    end;
  end;
end;

procedure TStartUOThread.Execute;
var
  Addr: Cardinal;
  Rd: DWORD;
  N: Cardinal;
  P: PChar;
  Ok: Boolean;
  S: string;
  Buf: array[0..15] of Char;
  Cmd: array[0..512] of Char;
  Dir: array[0..512] of Char;
  PI: TProcessInformation;
  SI: TStartupInfo;
  W: HWND;
begin
  FreeOnTerminate := True;
  while fmSecondfj.sbStartUO.Down do
  begin
    if Terminated then
      Exit;
    FillChar(SI, SizeOf(SI), 0);
    FillChar(PI, SizeOf(PI), 0);
    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW;
    case fmSecondfj.cbSUOMin.Checked of
      False: SI.wShowWindow := SW_SHOW;
      True: SI.wShowWindow := SW_SHOWMINNOACTIVE;
    end;
    S := ExtractFilePath(fmSecondfj.eSUO.Text);
    Ok := CreateProcess(nil, StrPCopy(Cmd, fmSecondfj.eSUO.Text), nil, nil, False,
      $30, nil, StrPCopy(Dir, S), SI, PI);
    SysUtils.Sleep(1);
    Rd := WaitForInputIdle(PI.hProcess, 10000);
    Addr := GetLastError;
    if Rd <> 0 then
      SysUtils.Sleep(1000);
    case fmSecondfj.tbUOPriority.Position of
      1: SetThreadPriority(PI.hThread, -7);
      3: SetThreadPriority(PI.hThread, 7);
    end;
    ProcId := PI.dwProcessId;
    Wnd := 0;
    Pid := 0;
    EnumWindows(@EnumStartUOWnd, 0);
    if Pid = 0 then
    begin
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $19B)), 'UOPilot Error Message', 0)
      else
        MsgBox('Не могу найти рабочее окно', 'UOPilot Error Message', 0);
      TerminateProcess(PI.hProcess, 2);
      FileClose(PI.hProcess); { *Преобразовано из CloseHandle* }
      SysUtils.Sleep(1);
    end
    else
    begin
      FileClose(PI.hProcess); { *Преобразовано из CloseHandle* }
      W := Wnd;
      fmSecondfj.FClientProcess := OpenProcess($1F0FFF, True, Pid);
      Rd := GetLastError;
      if fmSecondfj.StartUOOnly.Checked then
      begin
        fmSecondfj.sbStartUO.Down := False;
        Exit;
      end;
      SysUtils.Sleep(1);
      if Ok then
      begin
        P := '';
        SysUtils.Sleep(1);
        N := 0;
        while (Pos('Sorry', P) = 0) and (Pid <> 0) do
        begin
          SysUtils.Sleep(350);
          if not fmSecondfj.sbStartUO.Down then
            Exit;
          Inc(N);
          if N > $F then
          begin
            N := 0;
            PostMessage(W, WM_LBUTTONDOWN, 0, MakeLong($141, $139));
            PostMessage(W, WM_LBUTTONUP, 0, MakeLong($141, $139));
          end;
          Addr := ClientAddr[8, fmSecondfj.cbClVer.ItemIndex];
          ReadProcessMemory(fmSecondfj.FClientProcess, Pointer(Addr), @Addr, 4, Rd);
          ReadProcessMemory(fmSecondfj.FClientProcess, Pointer(Addr), @Addr, 4, Rd);
          ReadProcessMemory(fmSecondfj.FClientProcess, Pointer(Addr), @Buf, 16, Rd);
          P := @Buf;
          PostMessage(W, WM_LBUTTONDOWN, 0, MakeLong($26A, $1C8));
          PostMessage(W, WM_LBUTTONUP, 0, MakeLong($26A, $1C8));
          if Copy(P, 1, 7) = 'Welcome' then
          begin
            fmSecondfj.sbStartUO.Down := False;
            Exit;
          end;
          SysUtils.Sleep(1);
          Pid := 0;
          EnumWindows(@EnumStartUOWnd, 0);
          SysUtils.Sleep(1);
        end;
      end;
      TerminateProcess(fmSecondfj.FClientProcess, 1);
      FileClose(fmSecondfj.FClientProcess); { *Преобразовано из CloseHandle* }
      Rd := GetLastError;
    end;
  end;
end;

procedure TfmSecond.cbGMPageClick(Sender: TObject);
begin
  if cbGMPage.Checked then
  begin
    cbGMPageAlarm.Enabled := True;
    TGMPageThread.Create(False);
  end
  else
  begin
    FlashWindow(gWorkWnd, False);
    cbGMPageAlarm.Enabled := False;
  end;
end;

procedure TGMPageThread.Execute;
var
  Addr: Cardinal;
  Rd: DWORD;
  Buf: array[0..15] of Char;
  P: PChar;
  Snd: PChar;
  Flashing: Boolean;
begin
  FreeOnTerminate := True;
  Flashing := False;
  while fmSecondfj.cbGMPage.Checked do
  begin
    SysUtils.Sleep(1);
    Addr := ClientAddr[8, fmSecondfj.cbClVer.ItemIndex];
    ReadProcessMemory(gClientThread, Pointer(Addr), @Addr, 4, Rd);
    ReadProcessMemory(gClientThread, Pointer(Addr), @Addr, 4, Rd);
    ReadProcessMemory(gClientThread, Pointer(Addr), @Buf, 16, Rd);
    if Rd <> 16 then
    begin
      if fmSecondfj.miStopSErrorRead.Checked or fmSecondfj.miPauseSErrorRead.Checked then
      begin
        fmSecondfj.sbGMPage.Caption := 'error';
        fmSecondfj.cbGMPage.Checked := False;
      end;
      if fmSecondfj.miInformErrorRead.Checked then
      begin
        SetForegroundWindow(gClientThread);
        SysUtils.Sleep(1);
        SetForegroundWindow(Application.Handle);
        if gLangOffsety > 0 then
          MsgBox(PChar(LoadStr(gLangOffsety + $1A8)), 'UOPilot Error Message', 0)
        else
          MsgBox('Ошибка определения GM Page', 'UOPilot Error Message', 0);
      end;
    end;
    P := @Buf;
    if Copy(P, 1, 12) = 'GM Page from' then
    begin
      if not Flashing and fmSecondfj.cbGMPageAlarm.Checked then
      begin
        Rd := FindResource(HInstance, 'MSGWAV', RT_RCDATA);
        Rd := LoadResource(HInstance, Rd);
        Snd := LockResource(Rd);
        sndPlaySound(Snd, SND_MEMORY or SND_NODEFAULT);
        UnlockResource(Rd);
        FreeResource(Rd);
      end;
      Flashing := True;
      gFlashing6 := True;
      FlashWindow(gWorkWnd, Flashing);
    end
    else
      if Flashing then
      begin
        Flashing := False;
        FlashWindow(gWorkWnd, False);
      end;
    SysUtils.Sleep(1000);
  end;
end;

procedure TfmSecond.GroupBox6Click(Sender: TObject);
begin
  sbLoginUO.Enabled :=
    (not cbName.Checked) and cbTrans.Checked and cbPathF.Checked and (not cbCrim.Checked);
end;

function RegisterHotKeyEntry(const E; S: string; var H: Integer;
  Sender: TObject; Mode: Byte): Boolean;
var
  Nm: string;
  P: PChar;
begin
  { Имя обманывает: никаких горячих клавиш здесь нет -- это ЗАХВАТ КЛАВИШИ
    МЕЖДУ ЭКЗЕМПЛЯРАМИ UoPilot через именованный мьютекс `UoPmutex_<текст>`.
    Mode = 1 -- занять (получилось только если мьютекса ещё не было), иначе --
    отпустить. Дескриптор возвращается в H (это элемент gHKNames, массива
    Integer, а вовсе не имён). Первый и четвёртый параметры не используются. }
  if S = '' then
  begin
    Result := False;
    Exit;
  end;
  Nm := 'UoPmutex_' + S;
  if Mode = 1 then
  begin
    P := PChar(Nm);
    H := OpenMutex(MUTEX_ALL_ACCESS, False, P);
    if H = 0 then
      H := CreateMutex(nil, True, P)
    else
    begin
      { мьютекс уже есть -- клавишу держит другой экземпляр }
      FileClose(H); { *Преобразовано из CloseHandle* }
      ReleaseMutex(H);
      H := 0;
      Result := False;
      Exit;
    end;
    if GetLastError <> 0 then
    begin
      FileClose(H); { *Преобразовано из CloseHandle* }
      ReleaseMutex(H);
      H := 0;
      Result := False;
    end
    else
    begin
      ReleaseMutex(H);
      Result := True;
    end;
  end
  else
  begin
    FileClose(H); { *Преобразовано из CloseHandle* }
    ReleaseMutex(H);
    H := 0;
    Result := False;
  end;
end;

function HotKeyCaption(Nm: ShortString): ShortString;
var
  M: Byte;
begin
  Result := '';
  try
    Result := gHotKeyMgr.HotKeyByName(Nm).HotKey;
    M := Byte(gHotKeyMgr.HotKeyByName(Nm).ShiftState);
    if (M and 1) <> 0 then Result := 'Shift + ' + Result;
    if (M and 2) <> 0 then Result := 'Alt + ' + Result;
    if (M and 4) <> 0 then Result := 'Ctrl + ' + Result;
  except
    Result := '';
  end;
end;

function TryRegisterHotKey(Nm: ShortString; M: Byte;
  Key: ShortString; var Idx: Integer): Boolean;
begin
  { Заводит горячую клавишу в коллекции THotKeyManager. Обе строки --
    короткие и по значению. Уже заведённая клавиша не трогается:
    возвращается только её номер. }
  Result := True;
  try
    if gHotKeyMgr.HotKeyByName(Nm) = nil then
      with gHotKeyMgr.HotKeys do
      begin
        Add;
        Idx := Count - 1;
        Items[Idx].Name := Nm;
        Items[Idx].ShiftState := HotKeyMgr.TShiftState(M);
        Items[Idx].HotKey := Key;
      end
    else
    begin
      Idx := gHotKeyMgr.HotKeyIndexByName(Nm);
      Result := True;
    end;
  except
    Result := False;
  end;
end;

procedure TfmSecond.cbhk1Click(Sender: TObject);
var
  Nm: string;
  Cap: string;
  Txt: string;
  Idx: Integer;
  N: Integer;
  Checked: Boolean;
  T: TScanThread;
begin
  { Включение/выключение горячей клавиши. Имя элемента складывается из имени
    компонента и номера скрипта, по нему клавиша ищется в коллекции
    THotKeyManager и регистрируется либо снимается. }
  Sender := Sender;
  fld_14E8 := 0;
  if Sender is TCheckBox then
  begin
    Nm := (Sender as TCheckBox).Name;
    N := (Sender as TCheckBox).Tag;
  end
  else
  begin
    N := (StrToInt((Sender as TStringGrid).Cells[1,
      (Sender as TStringGrid).Row]) + 1) * 2 +
      (Sender as TStringGrid).Tag - 1;
    case gHKSela of
      0:
        begin
          Nm := (Sender as TStringGrid).Name + '_' +
            (Sender as TStringGrid).Cells[1, (Sender as TStringGrid).Row];
          Dec(N);
        end;
      5:
        Nm := (Sender as TStringGrid).Name + '_Pause_' +
          (Sender as TStringGrid).Cells[1, (Sender as TStringGrid).Row];
    end;
  end;
  Delete(Nm, 1, 2);
  Idx := 0;
  if Sender is TCheckBox then
    Checked := (Sender as TCheckBox).Checked
  else
    Checked := (Sender as TStringGrid).Cells[gHKSela,
      (Sender as TStringGrid).Row] = 'X';
  if not Checked then
  begin
    { Снятие: ищем элемент по имени и гасим его. }
    if gHotKeyMgr <> nil then
    begin
      while (Idx < gHotKeyMgr.HotKeys.Count) and
        (gHotKeyMgr.HotKeys[Idx].Name <> Nm) do
        Inc(Idx);
      if Idx >= gHotKeyMgr.HotKeys.Count then
        Idx := -1
      else
      begin
        gHotKeyMgr.HotKeys[Idx].HotKey := '';
        gHotKeyMgr.HotKeys[Idx].ShiftState := [];
        gHotKeyMgr.HotKeys.Delete(Idx);
        if not gHKDisabled then
          gHKEntrieslw[N - 1].Enabled := False;
      end;
    end
    else if Sender is TCheckBox then
      (Sender as TCheckBox).Enabled := False;
    Txt := BuildHotKeyText(gHKEntrieslw[N - 1]);
    RegisterHotKeyEntry(gHKEntrieslw[N - 1], Txt, Integer(gHKNames[N - 1]), Sender, 0);
    if gDlg596700 <> nil then
      sbApply.Enabled := not (N = gHotKeyTag);
    Exit;
  end;
  if Sender is TCheckBox then
    (Sender as TCheckBox).Enabled := True;
  Idx := gHotKeyMgr.HotKeys.Count;
  Txt := BuildHotKeyText(gHKEntrieslw[N - 1]);
  if not RegisterHotKeyEntry(gHKEntrieslw[N - 1], Txt, Integer(gHKNames[N - 1]),
    Sender, 1) then
  begin
    { Не встало -- сообщение в лог текущего скрипта и снятая галка. }
    gHKEntrieslw[N - 1].Enabled := False;
    fld_14E8 := 1;
    if Sender is TCheckBox then
    begin
      Cap := (Sender as TCheckBox).Name;
      Delete(Cap, 1, 4);
    end
    else
      Cap := (Sender as TStringGrid).Cells[2, (Sender as TStringGrid).Row];
    T := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])];
    T.Msg := PChar('Set hotkey error. ' + Txt + '  ' + Cap);
    gCoordCaptureddo := True;
    T.SyncLogMsg;
    if Sender is TCheckBox then
      (Sender as TCheckBox).Checked := False
    else
      (Sender as TStringGrid).Cells[gHKSela,
        (Sender as TStringGrid).Row] := '';
  end;
  if not TryRegisterHotKey(gHKEntrieslw[N - 1].Name,
      Byte(gHKEntrieslw[N - 1].Mods),
    gHKEntrieslw[N - 1].Text, Idx) then
  begin
    if Sender is TCheckBox then
      (Sender as TCheckBox).Checked := False
    else
      (Sender as TStringGrid).Cells[gHKSela,
        (Sender as TStringGrid).Row] := '';
    fld_14E8 := 2;
    Exit;
  end;
  { Клавиша принята: переносим её в добавленный элемент коллекции. }
  gHotKeyMgr.HotKeys[Idx].ShiftState :=
    HotKeyMgr.TShiftState(gHKEntrieslw[N - 1].Mods);
  gHotKeyMgr.HotKeys[Idx].HotKey := gHKEntrieslw[N - 1].Text;
  gHotKeyMgr.HotKeys[Idx].OnHotKeyActivation := gHKEntrieslw[N - 1].Handler;
  THKItemFull(gHotKeyMgr.HotKeys[Idx]).Sound := gHKEntrieslw[N - 1].Sound;
  gHKEntrieslw[N - 1].Enabled := True;
  if Sender is TCheckBox then
    (FindComponent('l' + gHKEntrieslw[N - 1].Name) as TSpeedButton).Caption :=
      HotKeyCaption(gHKEntrieslw[N - 1].Name)
  else
    case gHKSela of
      0: (Sender as TStringGrid).Cells[3, (Sender as TStringGrid).Row] :=
        HotKeyCaption(gHKEntrieslw[N - 1].Name);
      5: (Sender as TStringGrid).Cells[4, (Sender as TStringGrid).Row] :=
        HotKeyCaption(gHKEntrieslw[N - 1].Name);
    end;
  { Подсказка у элемента, которому принадлежит клавиша. }
  case N of
    2: btStart.Hint := lhkSScript.Caption;
    3: miRec.Caption := Copy(miRec.Caption, 1, Pos(' ', miRec.Caption)) +
         '(' + lhkRec.Caption + ')';
    4: miStopRec.Caption := Copy(miStopRec.Caption, 1,
         Pos(' ', miStopRec.Caption)) + '(' + lhkRecStop.Caption + ')';
    5: miPlay.Caption := Copy(miPlay.Caption, 1, Pos(' ', miPlay.Caption)) +
         '(' + lhkPlay.Caption + ')';
    6: cbName.Caption := Copy(cbName.Caption, 1, Pos(' ', cbName.Caption)) +
         '(' + lhkSNames.Caption + ')';
    7: sbAMove_1.Hint := lhkMove_1.Caption;
    8: btS1.Hint := lhk1.Caption;
    9: btS2.Hint := lhk2.Caption;
    10: btS3.Hint := lhk3.Caption;
    11: btS4.Hint := lhk4.Caption;
    12: btS5.Hint := lhk5.Caption;
    13: sbMacros.Hint := Copy(sbMacros.Hint, 1, Pos('.', sbMacros.Hint)) +
          ' (' + lhkMes.Caption + ')';
    15: sbAMove_2.Hint := lhkMove_2.Caption;
    16: sbAMove_3.Hint := lhkMove_3.Caption;
    20: sbPause.Hint := lhkPScript.Caption;
    21: sbCharParams.Hint := Copy(sbCharParams.Hint, 1,
          Pos('.', sbCharParams.Hint)) + ' (' + lhkCharParams.Caption + ')';
  end;
  if (gDlg596700 <> nil) and (N = gHotKeyTag) then
    sbApply.Enabled := True;
end;

procedure TfmSecond.sbMacrosClick(Sender: TObject);
var
  Sect: ShortString;
  I: Integer;
begin
  Sect := 'Makros_';
  if sbMacros.Down then
  begin
    if gDlg596718 = nil then
    begin
      gDlg596718 := TForm.Create(fmSecondfj);
      gDlg596718.BorderStyle := bsNone;
      gDlg596718.Caption := 'Macros';
      gDlg596718.ClientHeight := $16;
      gDlg596718.ClientWidth := $2E1;
      gDlg596718.FormStyle := fsStayOnTop;
      gDlg596718.OldCreateOrder := True;
      gDlg596718.Scaled := False;
      pMakrosPanel.Parent := gDlg596718;
      pMakrosPanel.Visible := True;
      pMakrosPanel.Align := alClient;
      GetWindowThreadProcessId(Handle, @gMacroThreadId);
      gMacroCols := Screen.Width div $43;
      if gMacroCols > $16 then
        gMacroCols := $16;
      gDlg596718.Width := gMacroCols * $43;
      gMacroIni := TIniFile.Create(fmSecondfj.FOptionsFile);
      I := 1;
      while I < gMacroCols do
      begin
        gMouseMacros[I].Name := gMacroIni.ReadString(Sect + IntToStr(I), 'Name', '');
        gMouseMacros[I].Enter := gMacroIni.ReadBool(Sect + IntToStr(I), 'Enter', True);
        gMouseMacros[I].Pause := gMacroIni.ReadString(Sect + IntToStr(I), 'Pause', '800');
        gMouseMacros[I].Lines[1] := gMacroIni.ReadString(Sect + IntToStr(I), 'String_1', '');
        gMouseMacros[I].Lines[2] := gMacroIni.ReadString(Sect + IntToStr(I), 'String_2', '');
        gMouseMacros[I].Lines[3] := gMacroIni.ReadString(Sect + IntToStr(I), 'String_3', '');
        Inc(I);
      end;
      gMacroIni.Free;
      for I := 1 to gMacroCols do
      begin
        if gMouseMacros[I].Name <> '' then
          (FindComponent('tb' + IntToStr(I)) as TToolButton).Caption :=
            gMouseMacros[I].Name;
      end;
    end;
    gDlg596718.Show;
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
  end
  else
  begin
    gDlg596718.Hide;
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end;
end;

procedure TfmSecond.bAddClick(Sender: TObject);
begin
  bAddClickSubproc(Sender, -1);
end;

procedure TfmSecond.bAddClickSubproc(Sender: TObject; N: Integer);
var
  Allow: Boolean;
  Num: Integer;
  S: string;
  T: TScanThread;
  I: Integer;
  D: TTabControl;
  M: TMemo;
begin
  Allow := True;
  tScriptChanging(Sender, Allow);
  if N < 0 then
  begin
    S := tScript.Tabs[tScript.Tabs.Count - 1];
    if S = '99' then
    begin
      if tScript.Tabs.Count - 1 = 0 then
        Num := 0
      else
        Num := StrToInt(tScript.Tabs[tScript.Tabs.Count - 2]) + 1;
    end
    else
      Num := StrToInt(S) + 1;
  end
  else
  begin
    Num := N;
    S := IntToStr(Num);
  end;
  if Num > 98 then
    Exit;
  tScript.Tabs.Add(IntToStr(Num));
  I := StrToInt(tScript.Tabs[tScript.Tabs.Count - 1]);
  gScriptso3[I] := TScanThread.NewScriptTab(True);
  gScriptso3[I].SelfRef := Pointer(gScriptso3[I]);
  gScriptso3[I].Name := IntToStr(I);
  gScriptso3[I].PauseCmd := eScriptDelayDef.Text;
  gScriptso3[I].Modified := False;
  T := gScriptso3[I];
  if T.LogView = nil then
  begin
    M := TMemo.Create(fmSecondfj);
    T.LogView := M;
    M.Visible := False;
    M.Parent := fmSecondfj.pLog;
    M.Color := $FF000018;
    M.ParentFont := True;
    M.ReadOnly := True;
    M.ScrollBars := ssBoth;
    M.HideSelection := False;
    M.Align := alClient;
  end;
  T.LogView.Lines.Add(fmSecondfj.tScript.Tabs[fmSecondfj.tScript.Tabs.Count - 1]);
  T.OldLogProc := T.LogView.WindowProc;
  T.LogView.WindowProc := TScanThread(T).LogWndProc;
  tcLog.Tabs.Add(IntToStr(Num));
  tScriptDesc.Tabs.Add(IntToStr(Num));
  case tbScriptPriority.Position of
    0: SetThreadPriority(gScriptso3[I].Handle, -2);
    2: SetThreadPriority(gScriptso3[I].Handle, 2);
    3: SetThreadPriority(gScriptso3[I].Handle, 15);
  else
    SetThreadPriority(gScriptso3[I].Handle, 0);
  end;
  sghkScriptHKList.RowCount := sghkScriptHKList.RowCount + 1;
  sghkScriptHKList.Cells[1, sghkScriptHKList.RowCount - 1] := IntToStr(Num);
  S := sghkScriptHKList.Name + '_' + IntToStr(Num);
  Delete(S, 1, 2);
  gHKEntrieslw[$22 + Num * 2].Name := S;
  S := sghkScriptHKList.Name + '_Pause_' + IntToStr(Num);
  Delete(S, 1, 2);
  gHKEntrieslw[$22 + Num * 2 + 1].Name := S;
  tScript.TabIndex := tScript.Tabs.Count - 1;
  tScriptChange(Sender);
  if gTemplateLines <> nil then
    if gTemplateLines.Count > 0 then
      edScript.Lines.Assign(gTemplateLines);
  D := tScriptDesc;
  if D.Visible then
  begin
    D.Height := D.RowCount * tScriptDesc.TabHeight + 4;
    D := tScriptDesc;
    PanelTs.Height := (D.RowCount - 1) * D.TabHeight + tScript.Height;
  end
  else
    PanelTs.Height := tScript.Height;
  I := I;
end;

procedure TfmSecond.bRemoveClick(Sender: TObject);
var
  S: string;
  I: Integer;
  Tab: Integer;
  FromMenu: Boolean;
  Allow: Boolean;
  N, J: Integer;
  D: TTabControl;
begin
  FromMenu := False;
  if Sender is TMenuItem then
  begin
    if (Sender as TMenuItem).Name = 'miTabClose' then
      FromMenu := True;
    Tab := tScript.IndexOfTabAt(gMouseX, gMouseY);
  end
  else
    Tab := tScript.TabIndex;
  S := tScript.Tabs[Tab];
  N := StrToInt(S);
  if FromMenu then
    miSaveClick(Sender);
  if tScript.Tabs.Count > 1 then
  begin
    if tScript.Tabs.Count > tScript.TabIndex then
    begin
      if tScript.TabIndex = Tab then
      begin
        if Tab > 0 then
          tScript.TabIndex := tScript.TabIndex - 1
        else
          tScript.TabIndex := 1;
      end;
    end
    else
      tScript.TabIndex := tScript.Tabs.Count - 1;
    tScript.Tabs.Delete(Tab);
    tScriptDesc.Tabs.Delete(Tab);
    if tcLog.TabIndex <> 0 then
      tcLogChanging(Sender, Allow);
    Tab := tcLog.Tabs.IndexOf(S);
    if Tab > 0 then
      tcLog.Tabs.Delete(Tab);
    if not Assigned(gScriptso3[N].OnTerminate) then
    begin
      gScriptso3[N].Free;
      gScriptso3[N] := nil;
    end
    else
    begin
      if not gScriptso3[N].Suspended then
        gScriptso3[N].Suspend;
      gScriptso3[N].StopRequested := True;
      gScriptso3[N].LogToParent := True;
      gScriptso3[N].FreeOnTerminate := True;
      gScriptso3[N].Title := '';
      gScriptso3[N].FreeOnTerminate := False;
      gScriptso3[N].Resume;
      gScriptso3[N].WaitFor;
      gScriptso3[N].Free;
      gScriptso3[N] := nil;
    end;
    if S <> '99' then
    begin
      for I := 0 to tScript.Tabs.Count - 1 do
      begin
        if sghkScriptHKList.Cells[1, I] = S then
        begin
          if sghkScriptHKList.Cells[0, I] = 'X' then
          begin
            sghkScriptHKList.Cells[0, I] := '';
            sghkScriptHKList.Row := I;
            cbhk1Click(sghkScriptHKList);
          end;
          for J := I to sghkScriptHKList.RowCount - 1 do
          begin
            TGridCracker(sghkScriptHKList).MoveRow(J + 1, J);
            sghkScriptHKList.Rows[J + 1].Clear;
          end;
          sghkScriptHKList.RowCount := sghkScriptHKList.RowCount - 1;
          Break;
        end;
      end;
      gHKEntrieslw[$22 + StrToInt(S)].Name := '';
    end;
    tScriptChange(Sender);
  end;
  if tScriptDesc.Visible then
  begin
    tScriptDesc.Height := tScriptDesc.RowCount * tScriptDesc.TabHeight + 4;
    D := tScriptDesc;
    PanelTs.Height := (D.RowCount - 1) * D.TabHeight + tScript.Height;
  end
  else
    PanelTs.Height := tScript.Height;
end;

procedure TfmSecond.tScriptChange(Sender: TObject);
var
  N: Integer;
  Allow: Boolean;
  I: Integer;
  S: string;
begin
  { Переключение вкладки скрипта: поток замораживается, редактор
    перезаполняется строками этого скрипта, кнопки и флажки приводятся
    к его состоянию. }
  S := tScript.Tabs[tScript.TabIndex];
  N := StrToInt(S);
  if tcLog.TabIndex <> 0 then
  begin
    Allow := True;
    tcLogChanging(Sender, Allow);
    tcLog.TabIndex := tcLog.Tabs.IndexOf(S);
    if tcLog.TabIndex < 0 then
      tcLog.TabIndex := 0;
    tcLogChange(Sender);
  end;
  gScriptso3[N].Suspend;
  btStart.Down := gScriptso3[N].Flag91;
  sbPause.Enabled := btStart.Down;
  sbPause.Down := gScriptso3[N].Paused;
  edScript.Enabled := sbPause.Down or not btStart.Down;
  edScript.ReadOnly := not edScript.Enabled or
    (btStart.Down and not sbPause.Down);
  if Length(gScriptso3[N].Lines) - 1 > 0 then
    edScript.Visible := False;
  edScript.Lines.Clear;
  for I := 0 to Length(gScriptso3[N].Lines) - 1 do
    edScript.Lines.Add(gScriptso3[N].Lines[I]);
  edScript.Visible := True;
  gScript.MaxValue := Length(gScriptso3[N].Lines);
  gScript.Progress := 0;
  if edScript.Lines.Count > 0 then
    if TScanThread(gScriptso3[N]).Flag91 then
      TScanThread(gScriptso3[N]).SyncShowRunLine
    else
    begin
      edScript.CaretX := TScanThread(gScriptso3[N]).CaretX;
      edScript.CaretY := TScanThread(gScriptso3[N]).CaretY;
    end;
  edScript.Modified := gScriptso3[N].Modified;
  edPause.Text := gScriptso3[N].PauseCmd;
  cbDebug.Checked := gScriptso3[N].Debug;
  cbLoggingCommands.Checked := gScriptso3[N].LoggingCommands;
  try
    RefreshVarPanel;
  except
    Application.MessageBox('ошибка входа 0', 'еггог', 0);
  end;
  gScriptso3[N].AutoStart := True;
  gScriptso3[N].Resume;
  if (pcAll.ActivePage = tsScript) and edScript.Visible and
     edScript.Enabled and (gDlg596700 <> nil) then
    edScript.SetFocus;
  if gDlg5966EC <> nil then
    if gLangOffsety > 0 then
      gDlg5966EC.Caption := LoadStr(gLangOffsety + $1D8) +
        ExtractFileName(gScriptso3[N].Title) + ')'
    else
      gDlg5966EC.Caption := 'Editor (' +
        ExtractFileName(gScriptso3[N].Title) + ')';
  pPos.Caption := IntToStr(edScript.CaretY - 1);
  if tScript.OwnerDraw then
    RedrawAllTabs;
  sbWorkwindowHandle.Caption := IntToStr(gScriptso3[N].ClientWnd);
  lWinList.Caption := gScriptso3[N].WinListText;
  tScriptDesc.TabIndex := tScript.TabIndex;
end;

procedure TfmSecond.tScriptChanging(Sender: TObject; var AllowChange: Boolean);
var
  I: Integer;
  Cnt: Integer;
  N: Integer;
begin
  { Перед сменой вкладки текущий скрипт «замораживается»: текст, позиция
    курсора, флаги и подпись окна переносятся в объект потока. }
  if FFlag14E4 then
    fmSecondfj.pRestWait.Visible := False;
  { Сохраняем только при повторном входе (FFlag1467 уже взведён) или когда
    вкладку переключила кнопка bAdd. }
  if FFlag1467 or ((Sender is TSpeedButton) and ((Sender as TSpeedButton).Name = 'bAdd')) then
  begin
    N := StrToInt(tScript.Tabs[tScript.TabIndex]);
    if Assigned(gScriptso3[N]) then
    begin
      gScriptso3[N].Suspend;
      { текст и строка паузы переносятся только для незапущенного или
        приостановленного потока; остальные поля -- всегда }
      if (not gScriptso3[N].Flag91) or gScriptso3[N].Paused then
      begin
        Cnt := edScript.Lines.Count;
        SetLength(gScriptso3[N].Lines, Cnt);
        for I := 0 to Cnt - 1 do
          gScriptso3[N].Lines[I] := edScript.Lines[I];
        gScriptso3[N].PauseCmd := edPause.Text;
      end;
      gScriptso3[N].Modified := edScript.Modified or gScriptso3[N].Modified;
      gScriptso3[N].AutoStart := False;
      gScriptso3[N].Debug := cbDebug.Checked;
      gScriptso3[N].LoggingCommands := cbLoggingCommands.Checked;
      gScriptso3[N].CaretX := edScript.CaretX;
      gScriptso3[N].CaretY := edScript.CaretY;
      gScriptso3[N].Resume;
      gScriptso3[N].WinListText := lWinList.Caption;
    end;
  end
  else
  begin
    { чужой источник события -- смену запрещаем и взводим флаг, чтобы
      повторный вход (уже от самой вкладки) прошёл по первой ветке }
    AllowChange := False;
    FFlag1467 := True;
  end;
end;

procedure TfmSecond.RefreshVarPanel;
var
  N: Integer;
  R: Integer;
  I: Integer;
  J: Integer;
  P: Boolean;
  S: string;
begin
  // Перезаполнение сетки переменных и таймеров открытой
  // панели. Пока идёт чтение, поток скрипта приостанавливается
  // (Suspend/Resume), Resume обёрнут в try..except.
  if gDlg5966F0 <> nil then
  begin
    N := StrToInt(tScript.Tabs[tScript.TabIndex]);
    sgVar.RowCount := 1;
    if gScriptso3[N] <> nil then
    begin
      P := gScriptso3[N].Paused;
      if not P then
        gScriptso3[N].Suspend;
      sgVar.RowCount := Length(gScriptso3[N].Vars) + Length(gScriptso3[N].Timers) + 1;
      if miShowTimerVar.Checked then
        sgVar.RowCount := sgVar.RowCount + 1;
      if sgVar.RowCount > 1 then
        sgVar.FixedRows := 1;
      if gScriptso3[N].VarNames <> nil then
        for I := 0 to gScriptso3[N].VarNames.Count - 1 do
        begin
          R := I;
          S := gScriptso3[N].VarNames[R];
          if not miShowTimerVar.Checked then
            if S = 'timer' then
              Continue;
          if not miShowTimerVar.Checked then
            Dec(R);
          sgVar.Cells[0, R + 1] := S;
          if S[1] = '#' then
          begin
            Delete(S, 1, 1);
            J := 0;
            while J < Length(gScriptso3[N].Vars) do
            begin
              if gScriptso3[N].Vars[J].Name = LowerCase(S) then
                Break;
              Inc(J);
            end;
            sgVar.Cells[1, R + 1] := IntToStr(gScriptso3[N].Vars[J].Value);
          end
          else if S[1] = '$' then
          begin
            Delete(S, 1, 1);
            J := 0;
            while J < Length(gScriptso3[N].Timers) do
            begin
              if gScriptso3[N].Timers[J].Name = LowerCase(S) then
                Break;
              Inc(J);
            end;
            sgVar.Cells[1, R + 1] := gScriptso3[N].Timers[J].Value;
          end
          else
            sgVar.Cells[1, R + 1] := IntToStr(GetTickCount - gScriptso3[N].StartTick);
        end;
      try
        if not P then
          gScriptso3[N].Resume;
      except
        Application.MessageBox('ошибка входа33', 'еггог', 0);
      end;
    end;
  end;
end;

procedure TfmSecond.miSaveMacrosClick(Sender: TObject);
var
  Sect: ShortString;
  Ini: TMyMemIniFile;
  I: Integer;
begin
  { Все макросы мыши уходят в ini секциями Makros_1..Makros_11. }
  Sect := 'Makros_';
  Ini := TMyMemIniFile.Create(FOptionsFile);
  I := 1;
  while I < 12 do
  begin
    Ini.WriteString(Sect + IntToStr(I), 'Name', gMouseMacros[I].Name);
    Ini.WriteBool(Sect + IntToStr(I), 'Enter', gMouseMacros[I].Enter);
    Ini.WriteString(Sect + IntToStr(I), 'Pause', gMouseMacros[I].Pause);
    Ini.WriteString(Sect + IntToStr(I), 'String_1', gMouseMacros[I].Lines[1]);
    Ini.WriteString(Sect + IntToStr(I), 'String_2', gMouseMacros[I].Lines[2]);
    Ini.WriteString(Sect + IntToStr(I), 'String_3', gMouseMacros[I].Lines[3]);
    Inc(I);
  end;
  Ini.Free;
end;

procedure TfmSecond.LastScriptItemClick(Sender: TObject);
var
  S: ShortString;
begin
  { Пункт меню «последние скрипты», который заводит AfterOptionsLoaded. }
  S := (Sender as TMenuItem).Caption;
  LoadScriptFile(S);
  gStr59615C := S;
  if edScript.Enabled and edScript.Visible then edScript.SetFocus;
end;

procedure TfmSecond.SaveScriptToFile(FileName: string);
var
  I: Integer;
  Found: Boolean;
  Item, Root: TMenuItem;
begin
  { Имя метода историческое: файл он не пишет, а добавляет его в меню
    «последние скрипты» (mnHotKey.Items[0].Items[3]) и подрезает список
    до десяти пунктов. Зовётся из miSaveClick сразу после выбора файла. }
  if FileName <> '' then
  begin
    I := Length(gTempFilefv);
    if AnsiLowerCase(Copy(FileName, 1, I)) = AnsiLowerCase(gTempFilefv) then
      Delete(FileName, 1, I);
    Found := False;
    Root := mnHotKey.Items[0].Items[3];
    I := 0;
    while (I <= Root.Count - 1) and not Found do
    begin
      if AnsiLowerCase(Root.Items[I].Caption) = AnsiLowerCase(FileName) then
        Found := True;
      Inc(I);
    end;
    if Found then
      Root.Delete(I - 1);
    Item := TMenuItem.Create(Root);
    Item.Caption := FileName;
    Item.AutoHotkeys := maManual;
    Item.OnClick := LastScriptItemClick;
    Root.Insert(0, Item);
    while Root.Count > 10 do
      Root.Delete(Root.Count - 1);
  end;
end;

procedure TfmSecond.miAddSpClick(Sender: TObject);
begin
  Exit;
  if miAddSp.Checked then
    miAddSp.Checked := False;
  miAddSp.Checked := True;
end;

procedure TfmSecond.mmScriptKeyPress(Sender: TObject; var Key: Char);
begin
  if not edScript.ReadOnly then
    if (Key = #8) and gFlag596A40 then
    begin
      gFlag596A40 := False;
      Key := #0;
    end;
end;

procedure TfmSecond.mmScriptKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  S: string;
  K: Char;
  P: TBufferCoord;
  Y: Integer;
  I: Integer;
  E: TSynMemo;

  function ScanMenu(M: TMenuItem): Boolean;
  var
    J: Integer;
  begin
    Result := False;
    for J := 0 to M.Count - 1 do
    begin
      if M.Items[J].Count > 0 then
      begin
        Result := ScanMenu(M.Items[J]);
        if Result then
          Exit;
      end;
      if Pos(S, ' ' + LowerCase(M.Items[J].Caption)) > 0 then
      begin
        tScript.Hint := M.Items[J].Caption;
        fld_145C := -1;
        if fld_1458 <> 0 then
          HideHintWindow(TObject(fld_1458));
        fld_1458 := Integer(CreateTabHint(tScript));
        tHintTimer.Enabled := False;
        gHintTick := 0;
        gHintPhase := True;
        tHintTimer.Enabled := True;
        Result := True;
        Exit;
      end;
    end;
  end;
begin
  case Key of
    8, 13, 33, 34:
      pPos.Caption := IntToStr(edScript.CaretY - 1);
  end;
  if miShowCommandHint.Checked then
  begin
    E := edScript;
    Y := E.CaretY;
    P := E.CaretXY;
    S := edScript.GetWordAtRowCol(P);
    // Список команд ищется в нижнем регистре.
    I := gCmdListah7.IndexOf(AnsiLowerCase(S));
    if S = '' then
      I := -1;
    if I < 0 then
      I := gCmdList2jj.IndexOf(AnsiLowerCase(S));
    if S = '' then
      I := -1;
    while (I < 0) and (Y = P.Line) and not ((P.Char = 1) and (P.Line = 1)) do
    begin
      P := edScript.PrevWordPosEx(P);
      S := edScript.GetWordAtRowCol(P);
      I := gCmdListah7.IndexOf(AnsiLowerCase(S));
      if S = '' then
        I := -1;
      if I < 0 then
        I := gCmdList2jj.IndexOf(AnsiLowerCase(S));
    end;
    if S = '' then
      I := -1;
    if I >= 0 then
    begin
      S := ' ' + LowerCase(S) + ' ';
      if ScanMenu(mnCom.Items) then ;
    end;
  end;
  Exit;
  // Дальше код недостижим (перед ним безусловный Exit), но оставлен:
  // на Delete эмулируется Backspace через обработчик KeyPress.
  if Key = 46 then
  begin
    K := #8;
    mmScriptKeyPress(Sender, K);
  end;
end;

procedure TfmSecond.mmScriptOnChange(Sender: TObject);
var
  I: Integer;
begin
  I := StrToInt(tScript.Tabs[tScript.TabIndex]);
  if not gScriptso3[I].Modified then
  begin
    gScriptso3[I].Modified := True;
    RedrawAllTabs;
  end;
  edScript.Modified := True;
end;

procedure TfmSecond.sbSelServClick(Sender: TObject);
var
  S: string;
  T: string;
  X, Y: Integer;
  P: TPanel;
begin
  if gDlg59670C = nil then
  begin
    gDlg59670C := TForm.Create(fmSecondfj);
    gDlg59670C.Parent := nil;
    gDlg59670C.BorderStyle := bsSizeToolWin;
    gDlg59670C.ClientHeight := pSelectUOserver.Height;
    gDlg59670C.ClientWidth := pSelectUOserver.Width;
    gDlg59670C.Caption := pSelectUOserver.Hint;
    gDlg59670C.OnCloseQuery := SelServerClose;
    P := pSelectUOserver;
    P.Parent := gDlg59670C;
    P.Left := 0;
    P.Top := 0;
    P.Align := alClient;
    P.Visible := True;
  end;
  eUOpath.Text := ExtractFilePath(fmSecondfj.eSUO.Text);
  sgLoginLine.ColWidths[0] := 12;
  sgLoginLine.ColWidths[1] := $90;
  sgLoginLine.ColWidths[2] := $1E;
  sgLoginLine.ColWidths[3] := $90;
  sbReloadClick(Sender);
  gFlag596521 := False;
  X := (fmSecondfj.Width - gDlg59670C.Width) div 2 + fmSecondfj.Left;
  Y := (fmSecondfj.Height - gDlg59670C.Height) div 2 + fmSecondfj.Top;
  if X < 0 then
    X := 0;
  if Y < 0 then
    Y := 0;
  if Screen.DesktopWidth < gDlg59670C.Width + X then
    X := Screen.DesktopWidth - gDlg59670C.Width;
  if Screen.DesktopHeight < gDlg59670C.Height + Y then
    Y := Screen.DesktopHeight - gDlg59670C.Height;
  gDlg59670C.Left := X;
  gDlg59670C.Top := Y;
  gDlg59670C.Visible := True;
end;

procedure TfmSecond.sbHouseControlClick(Sender: TObject);
var
  S: string;
begin
  { Панель «House Control» на отдельном окне: позиция берётся из сохранённой,
    иначе окно пристраивается справа от главного, под уже открытыми панелями. }
  if gDlg5966E8 = nil then
  begin
    gDlg5966E8 := TForm.Create(fmSecondfj);
    gDlg5966E8.Parent := nil;
    gDlg5966E8.Font := fmSecondfj.Font;
    gDlg5966E8.BorderStyle := bsToolWindow;
    if miSOTHouseControl.Checked then
      gDlg5966E8.FormStyle := fsStayOnTop
    else
      gDlg5966E8.FormStyle := fsNormal;
    gDlg5966E8.ClientHeight := gbHouseControl.Height + 2;
    gDlg5966E8.ClientWidth := gbHouseControl.Width + 4 + 4;
    if gLangOffsety > 0 then
      gDlg5966E8.Caption := LoadStr(gLangOffsety + $D6)
    else
      gDlg5966E8.Caption := 'House Control';
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
    if (gWinPos[6] <> -1) and (gWinPos[7] <> -1) and miSPosHC.Checked then
    begin
      gDlg5966E8.Top := gWinPos[6];
      gDlg5966E8.Left := gWinPos[7];
    end
    else
    begin
      gDlg5966E8.Top := Top;
      if Assigned(gDlg5966E4) then
        gDlg5966E8.Top := gDlg5966E8.Top + gDlg5966E4.Height;
      if Assigned(gDlg5966F4) then
        gDlg5966E8.Top := gDlg5966E8.Top + gDlg5966F4.Height;
      gDlg5966E8.Left := Left + Width;
      if (gDlg5966E8.Left + gDlg5966E8.Width) > Screen.DesktopWidth then
        gDlg5966E8.Left := Left - gDlg5966E8.Width;
    end;
    gDlg5966E8.OnCloseQuery := HouseControlClose;
    gbHouseControl.Parent := gDlg5966E8;
    gbHouseControl.Visible := True;
    gbHouseControl.Top := 0;
    gbHouseControl.Left := 4;
  end;
  if gDlg5966E8.Visible then
  begin
    gDlg5966E8.Visible := False;
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end
  else
  begin
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
    gDlg5966E8.Visible := True;
  end;
  sbHouseControl.Down := gDlg5966E8.Visible;
end;

procedure TfmSecond.Button1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Px, Py: Integer;
  T: Integer;
  Pn: TPanel;
begin
  if Button <> mbRight then
    Exit;

  if gDlg596714 = nil then
  begin
    gDlg596714 := TForm.Create(fmSecondfj);
    gDlg596714.BorderStyle := bsToolWindow;
    gDlg596714.Caption := pEditHouse.Hint;
    gDlg596714.ClientHeight := pEditHouse.Height;
    gDlg596714.ClientWidth := pEditHouse.Width;
    gDlg596714.Color := $FF00000F;
    gDlg596714.Font := fmSecondfj.Font;

    Pn := pEditHouse;
    Pn.Parent := gDlg596714;
    Pn.Visible := True;
    Pn.Left := 0;
    Pn.Top := 0;
  end;

  T := (Sender as TSpeedButton).Tag;

  if Assigned(gDlg5966E8) then
  begin
    { Окно команд встаёт под панелью управления домом и прижимается к экрану }
    Px := gDlg5966E8.Left +
      (gDlg5966E8.Width - gDlg596714.Width) div 2;
    Py := gDlg5966E8.Top + gDlg5966E8.Height;

    if Px < 0 then
      Px := 0;
    if Py < 0 then
      Py := 0;

    if Px + gDlg596714.Width > Screen.DesktopWidth then
      Px := Screen.DesktopWidth - gDlg596714.Width;

    if Py + gDlg596714.Height > Screen.DesktopHeight then
      Py := Screen.DesktopHeight - gDlg596714.Height;

    gDlg596714.Left := Px;
    gDlg596714.Top := Py;
  end;

  gDlg596714.Tag := T;
  gDlg596714.Show;

  eehEditHouseCommands.Text :=
    gHouseCmds[T];
end;

procedure TfmSecond.cbhkMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  S: string;
begin
  if Button = mbRight then
  begin
    gHotKeyTag := (Sender as TCheckBox).Tag;
    S := (Sender as TCheckBox).Name;
    fld_14E0 := Integer(Sender);
    Delete(S, 1, 2);
    EditHotKey(S);
  end;
end;

procedure TfmSecond.lhkScrClick(Sender: TObject);
var
  S: string;
begin
  gHotKeyTag := (Sender as TSpeedButton).Tag;
  S := (Sender as TSpeedButton).Name;
  fld_14E0 := Integer(Sender);
  Delete(S, 1, 1);
  EditHotKey(S);
end;

procedure TfmSecond.EditHotKey(Name: ShortString);
var
  I: Integer;
  J: Integer;
begin
  // Показать в панели назначения текущую горячую клавишу элемента Name.
  // Параметр значениевый: найденное имя клавиши пишется обратно в Name.
  if TObject(fld_14E0) is TCheckBox then
    if (fmSecondfj.FindComponent('cb' + Name) as TCheckBox).Enabled then
      (fmSecondfj.FindComponent('cb' + Name) as TCheckBox).SetFocus;
  I := 0;
  if gHotKeyMgr <> nil then
  begin
    while (I < gHotKeyMgr.HotKeys.Count) and
          (gHotKeyMgr.HotKeys[I].Name <> Name) do
      Inc(I);
    if I < gHotKeyMgr.HotKeys.Count then
    begin
      Name := gHotKeyMgr.HotKeys[I].HotKey;
      gHKItem := I;
      gHKKeyIndex := -1;
      for J := 0 to 101 do
        if Name = gHKNameTablee9[J] then
        begin
          gHKKeyIndex := J;
          Break;
        end;
      cbHKList.ItemIndex := gHKKeyIndex;
      cbShift.Checked := HotKeyMgr.ssShift in gHotKeyMgr.HotKeys[gHKItem].ShiftState;
      cbAlt.Checked := HotKeyMgr.ssAlt in gHotKeyMgr.HotKeys[gHKItem].ShiftState;
      cbCtrl.Checked := HotKeyMgr.ssCtrl in gHotKeyMgr.HotKeys[gHKItem].ShiftState;
      sbApply.Enabled := True;
      eSoundFileSelect.Text := THKItemFull(gHotKeyMgr.HotKeys[gHKItem]).Sound;
      if (TObject(fld_14E0) is TStringGrid) and (gHKMode = 3) then
      begin
        cbHotKeyIsHolded.Enabled := True;
        cbHotKeyIsHolded.Checked := gScriptso3[gHKScript].HoldKey;
      end
      else
        cbHotKeyIsHolded.Enabled := False;
    end
    else
    begin
      cbHKList.ItemIndex := -1;
      cbShift.Checked := False;
      cbAlt.Checked := False;
      cbCtrl.Checked := False;
      cbHotKeyIsHolded.Checked := False;
      gHKItem := -1;
      eSoundFileSelect.Text := '';
      if TObject(fld_14E0) is TCheckBox then
        sbApply.Enabled :=
          (fmSecondfj.FindComponent('cb' + Name) as TCheckBox).Checked;
    end;
  end;
end;

procedure TfmSecond.cbSOTClick(Sender: TObject);
begin
  if cbSOT.Checked then
    Application.OnDeactivate := AppActivateKeepTopmost
  else
  begin
    SetWindowPos(fmSecondfj.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE);
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end;
end;

procedure TfmSecond.cbInsertXYClick(Sender: TObject);
begin
  if (Sender as TCheckBox).Tag = 1 then
  begin
    if cbInsertXY.Checked then
      cbInsertXYabs.Checked := False;
  end
  else if cbInsertXYabs.Checked then
    cbInsertXY.Checked := False;
end;

procedure TfmSecond.miSKRelClick(Sender: TObject);
begin
  if miSKRel.Checked then
    miSKAbs.Checked := False;
  if not miSKRel.Checked and not miSKAbs.Checked then
  begin
    tShowCoordsOnCap.Enabled := False;
    Application.Title := gAppTitle;
    fmSecondfj.Caption := gFormCaption;
  end
  else
    tShowCoordsOnCap.Enabled := True;
end;

procedure TfmSecond.miSKAbsClick(Sender: TObject);
begin
  if miSKAbs.Checked then
    miSKRel.Checked := False;
  if not miSKRel.Checked and not miSKAbs.Checked then
  begin
    tShowCoordsOnCap.Enabled := False;
    Application.Title := gAppTitle;
    fmSecondfj.Caption := gFormCaption;
  end
  else
    tShowCoordsOnCap.Enabled := True;
end;

procedure TfmSecond.tShowCoordsOnCapTimer(Sender: TObject);
var
  P: TPoint;
  DC: HDC;
  W: HWND;
  C: Cardinal;
  B: Graphics.TBitmap;
  Cap: string[255];
  T1: string;
  T2: string;
begin
  { Раз в тик показывает в заголовке координаты курсора и цвет пикселя под
    ним. Если GetPixel вернул 0 (окно закрыто слоем), цвет берётся через
    временный битмап с BitBlt. }
  if gAppTitle = '' then
    gAppTitle := Application.Title;
  if gFormCaption = '' then
    gFormCaption := fmSecondfj.Caption;
  GetCursorPos(P);
  DC := GetDC(0);
  C := GetPixel(DC, P.X, P.Y);
  ReleaseDC(0, DC);
  if C = 0 then
  begin
    B := Graphics.TBitmap.Create;
    B.PixelFormat := pf24bit;
    DC := GetDC(0);
    B.Width := 1;
    B.Height := 1;
    BitBlt(B.Canvas.Handle, 0, 0, B.Width, B.Height, DC, P.X, P.Y, SRCCOPY);
    C := B.Canvas.Pixels[0, 0];
    TBitmapCracker(B).FreeImage;
    B.Free;
    ReleaseDC(0, DC);
  end;
  if miSKRel.Checked then
  begin
    W := WindowFromPoint(P);
    Windows.ScreenToClient(W, P);
    Cap := 'r.';
  end
  else
    Cap := 'a.';
  Cap := Cap + IntToStr(P.X) + ',' + IntToStr(P.Y);
  if miShowHex.Checked then
    Cap := Cap + '  0x' + IntToHex(C, 6)
  else
    Cap := Cap + '  ' + IntToStr(C);
  fmSecondfj.Caption := Cap;
end;

procedure TfmSecond.sbPauseClick(Sender: TObject);
var
  I: Integer;
  Cnt: Integer;
  S: string;
  T: string;
  U: string;
  N: Integer;
begin
  { Пауза скрипта. При снятии паузы отредактированный текст переносится
    из редактора в массив строк потока, и поток возобновляется. }
  N := StrToInt(tScript.Tabs[tScript.TabIndex]);
  if sbPause.Down then
  begin
    gScriptso3[N].Paused := True;
    if Assigned(edScript) then
      if edScript.Visible then
        if edScript.Enabled then
          if pcAll.ActivePage = tsScript then
            edScript.SetFocus;
    edScript.Modified := False;
  end
  else
  begin
    gScriptso3[N].Paused := False;
    if not gScriptso3[N].StopOnPause then
      gScriptso3[N].PauseCmd := edPause.Text;
    if cbDebug.Checked and not gScriptso3[N].StopRequested then
    begin
      gScriptso3[N].Paused := True;
      sbPause.Down := True;
    end;
    if edScript.Modified then
    begin
      Cnt := edScript.Lines.Count;
      SetLength(gScriptso3[N].Lines, Cnt);
      for I := 0 to Cnt - 1 do
        gScriptso3[N].Lines[I] := edScript.Lines[I];
    end;
    gScriptso3[N].LineCount := edScript.CaretY - 1;
    gScriptso3[N].Resume;
  end;
  edScript.Enabled := sbPause.Down or not btStart.Down;
  edScript.ReadOnly := not sbPause.Down;
end;

procedure TfmSecond.sbEditHKClick(Sender: TObject);
var
  X: Integer;
  Y: Integer;
  I: Integer;
begin
  { Список горячих клавиш выносится на отдельное окно, отцентрованное
    по главной форме и прижатое к краям экрана, если не влезает. }
  if gDlg596700 = nil then
  begin
    gDlg596700 := TForm.Create(fmSecondfj);
    gDlg596700.BorderStyle := bsToolWindow;
    gDlg596700.Caption := 'Edit HotKeys';
    gDlg596700.ClientHeight := $153;
    gDlg596700.ClientWidth := $215;
    gDlg596700.Color := $FF00000F;
    gDlg596700.ClientHeight := gbHotKeyList.Height;
    gDlg596700.ClientWidth := gbHotKeyList.Width;
    gbHotKeyList.Parent := gDlg596700;
    gbHotKeyList.Visible := True;
    gbHotKeyList.Left := 0;
    gbHotKeyList.Top := 0;
    gbHotKeyList.SendToBack;
    X := (fmSecondfj.Width - gDlg596700.Width) div 2 + fmSecondfj.Left;
    Y := (fmSecondfj.Height - gDlg596700.Height) div 2 + fmSecondfj.Top;
    if X < 0 then
      X := 0;
    if Y < 0 then
      Y := 0;
    if Screen.DesktopWidth < gDlg596700.Width + X then
      X := Screen.DesktopWidth - gDlg596700.Width;
    if Screen.DesktopHeight < gDlg596700.Height + Y then
      Y := Screen.DesktopHeight - gDlg596700.Height;
    gDlg596700.Left := X;
    gDlg596700.Top := Y;
    gDlg596700.OnCloseQuery := HotKeyListClose;
    gDlg596700.Font := fmSecondfj.Font;
    { Имена клавиш переливаются в cbHKList из таблицы HotKeyMgr.gHKNameTablee9. }
    for I := 0 to High(gHKNameTablee9) do
      cbHKList.Items.Add(gHKNameTablee9[I]);
  end;
  gDlg596700.Visible := not gDlg596700.Visible;
  sbEditHK.Down := gDlg596700.Visible;
end;

procedure TfmSecond.sbCalibrateClick(Sender: TObject);
var
  N: DWORD;
  I: Integer;
  P: PDWORD;
  A: DWORD;
begin
  { Калибровка правит адрес прямо в таблице: сначала запоминает исходный,
    потом читает по нему четыре байта из памяти клиента в ту же ячейку. }
  if cbClVer.ItemIndex >= 4 then
  begin
    SetForegroundWindow(Application.Handle);
    MsgBox('Начиная с версии 2.0.3 калибровка не требуется.',
      'UOPilot Error Message', 0);
  end
  else
  begin
    I := cbClVer.ItemIndex;
    P := @ClientAddr[7, I];
    if gCalibrBase = 0 then
      gCalibrBase := ClientAddr[7, I]
    else
      P^ := gCalibrBase;
    A := ClientAddr[7, I];
    ReadProcessMemory(FClientProcess, Pointer(A), P, 4, N);
  end;
end;

procedure TfmSecond.miSMkeymouseClick(Sender: TObject);
var
  OldIdx: Integer;
  OldExt: string;
  S: string;
begin
  OldExt := sdSave.DefaultExt;
  OldIdx := sdSave.FilterIndex;
  sdSave.DefaultExt := '.mac';
  sdSave.FilterIndex := 3;
  sdSave.InitialDir := ExtractFilePath(Application.ExeName);
  sdSave.FileName := '';
  if gLangOffsety > 0 then
    sdSave.Title := LoadStr(gLangOffsety + $1AC)
  else
    sdSave.Title := 'Сохранить макрос как...';
  if sdSave.Execute then
    MacroFileOp(1, sdSave.FileName);
  sdSave.DefaultExt := OldExt;
  sdSave.FilterIndex := OldIdx;
  SysUtils.SetCurrentDir(gTempFilefv);
  OldIdx := OldIdx;
end;

procedure TfmSecond.miLMkeymouseClick(Sender: TObject);
var
  OldIdx: Integer;
  OldExt: string;
  S: string;
begin
  OldExt := odLoad.DefaultExt;
  OldIdx := odLoad.FilterIndex;
  odLoad.DefaultExt := '.mac';
  odLoad.FilterIndex := 3;
  odLoad.InitialDir := ExtractFilePath(Application.ExeName);
  odLoad.FileName := '';
  if gLangOffsety > 0 then
    odLoad.Title := LoadStr(gLangOffsety + $1AD)
  else
    odLoad.Title := 'Загрузить макрос...';
  if odLoad.Execute then
    MacroFileOp(2, odLoad.FileName);
  odLoad.DefaultExt := OldExt;
  odLoad.FilterIndex := OldIdx;
  SysUtils.SetCurrentDir(gTempFilefv);
  OldIdx := OldIdx;
end;

procedure TfmSecond.MacroFileOp(Mode: Byte; FileName: string);
var
  T: string;
  S: string;
  N: Integer;
  I: Integer;
  F: TextFile;
const
  gMsgNames: array[0..180] of string = (
    'NULL', 'CREATE', 'DESTROY', 'MOVE', 'SIZE', 'ACTIVATE', 'SETFOCUS',
    'KILLFOCUS', 'ENABLE', 'SETREDRAW', 'SETTEXT', 'GETTEXT', 'GETTEXTLENGTH',
    'PAINT', 'CLOSE', 'QUERYENDSESSION', 'QUIT', 'QUERYOPEN', 'ERASEBKGND',
    'SYSCOLORCHANGE', 'ENDSESSION', 'SYSTEMERROR', 'SHOWWINDOW', 'CTLCOLOR',
    'WININICHANGE', 'DEVMODECHANGE', 'ACTIVATEAPP', 'FONTCHANGE',
    'TIMECHANGE', 'CANCELMODE', 'SETCURSOR', 'MOUSEACTIVATE', 'CHILDACTIVATE',
    'QUEUESYNC', 'GETMINMAXINFO', 'PAINTICON', 'ICONERASEBKGND', 'NEXTDLGCTL',
    'SPOOLERSTATUS', 'DRAWITEM', 'MEASUREITEM', 'DELETEITEM', 'VKEYTOITEM',
    'CHARTOITEM', 'SETFONT', 'GETFONT', 'SETHOTKEY', 'GETHOTKEY',
    'QUERYDRAGICON', 'COMPAREITEM', 'GETOBJECT', 'COMPACTING', 'COMMNOTIFY',
    'WINDOWPOSCHANGING', 'WINDOWPOSCHANGED', 'POWER', 'COPYDATA',
    'CANCELJOURNAL', 'NOTIFY', 'INPUTLANGCHANGEREQUEST', 'INPUTLANGCHANGE',
    'TCARD', 'HELP', 'USERCHANGED', 'NOTIFYFORMAT', 'CONTEXTMENU',
    'STYLECHANGING', 'STYLECHANGED', 'DISPLAYCHANGE', 'GETICON', 'SETICON',
    'NCCREATE', 'NCDESTROY', 'NCCALCSIZE', 'NCHITTEST', 'NCPAINT',
    'NCACTIVATE', 'GETDLGCODE', 'NCMOUSEMOVE', 'NCLBUTTONDOWN', 'NCLBUTTONUP',
    'NCLBUTTONDBLCLK', 'NCRBUTTONDOWN', 'NCRBUTTONUP', 'NCRBUTTONDBLCLK',
    'NCMBUTTONDOWN', 'NCMBUTTONUP', 'NCMBUTTONDBLCLK', 'KEYDOWN', 'KEYUP',
    'CHAR', 'DEADCHAR', 'SYSKEYDOWN', 'SYSKEYUP', 'SYSCHAR', 'SYSDEADCHAR',
    'KEYLAST', 'INITDIALOG', 'COMMAND', 'SYSCOMMAND', 'TIMER', 'HSCROLL',
    'VSCROLL', 'INITMENU', 'INITMENUPOPUP', 'MENUSELECT', 'MENUCHAR',
    'ENTERIDLE', 'MENURBUTTONUP', 'MENUDRAG', 'MENUGETOBJECT',
    'UNINITMENUPOPUP', 'MENUCOMMAND', 'CHANGEUISTATE', 'UPDATEUISTATE',
    'QUERYUISTATE', 'MOUSEMOVE', 'LBUTTONDOWN', 'LBUTTONUP', 'LBUTTONDBLCLK',
    'RBUTTONDOWN', 'RBUTTONUP', 'RBUTTONDBLCLK', 'MBUTTONDOWN', 'MBUTTONUP',
    'MBUTTONDBLCLK', 'MOUSEWHEEL', 'PARENTNOTIFY', 'ENTERMENULOOP',
    'EXITMENULOOP', 'NEXTMENU', 'MDICREATE', 'MDIDESTROY', 'MDIACTIVATE',
    'MDIRESTORE', 'MDINEXT', 'MDIMAXIMIZE', 'MDITILE', 'MDICASCADE',
    'MDIICONARRANGE', 'MDIGETACTIVE', 'MDISETMENU', 'ENTERSIZEMOVE',
    'EXITSIZEMOVE', 'DROPFILES', 'MDIREFRESHMENU', 'MOUSEHOVER', 'MOUSELEAVE',
    'CUT', 'COPY', 'PASTE', 'CLEAR', 'UNDO', 'RENDERFORMAT',
    'RENDERALLFORMATS', 'DESTROYCLIPBOARD', 'DRAWCLIPBOARD', 'PAINTCLIPBOARD',
    'VSCROLLCLIPBOARD', 'SIZECLIPBOARD', 'ASKCBFORMATNAME', 'CHANGECBCHAIN',
    'HSCROLLCLIPBOARD', 'QUERYNEWPALETTE', 'PALETTEISCHANGING',
    'PALETTECHANGED', 'HOTKEY', 'PENWINFIRST', 'PENWINLAST', 'DDE_FIRST',
    'USER', 'APP', 'SIZING', 'CAPTURECHANGED', 'MOVING', 'POWERBROADCAST',
    'DEVICECHANGE', 'PRINT', 'PRINTCLIENT', 'HANDHELDFIRST', 'HANDHELDLAST');
  gMsgCodes: array[0..180] of Cardinal = (
    0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
    22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 38, 39, 40,
    42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 55, 57, 61, 65, 68, 70, 71, 72,
    74, 75, 78, 80, 81, 82, 83, 84, 85, 123, 124, 125, 126, 127, 128, 129,
    130, 131, 132, 133, 134, 135, 160, 161, 162, 163, 164, 165, 166, 167, 168,
    169, 256, 257, 258, 259, 260, 261, 262, 263, 264, 272, 273, 274, 275, 276,
    277, 278, 279, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 512,
    513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 528, 529, 530, 531, 544,
    545, 546, 547, 548, 549, 550, 551, 552, 553, 560, 561, 562, 563, 564, 673,
    675, 768, 769, 770, 771, 772, 773, 774, 775, 776, 777, 778, 779, 780, 781,
    782, 783, 784, 785, 786, 896, 911, 992, 1024, 32768, 532, 533, 534, 536,
    537, 791, 792, 856, 863);
begin
  { Макрос мыши/клавиатуры <-> текстовый файл. Mode = 1 -- выгрузка потока
    записи TheRecorder в текст (код сообщения переводится в имя по
    gMsgCodes/gMsgNames), иначе -- разбор текста обратно в поток.
    Весь метод с выключенным контролем ввода-вывода. }
  {$I-}
  AssignFile(F, FileName);
  try
    if Mode = 1 then
    begin
      Rewrite(F);
      TheRecorder.DoStop;
      TheRecorder.FStream.Seek(0, 0);
      while TheRecorder.FStream.Position < TheRecorder.FStream.Size do
      begin
        TheRecorder.FStream.Read(TheRecorder.EventMsg, SizeOf(TheRecorder.EventMsg));
        S := '';
        for I := 0 to $B4 do
          if TheRecorder.EventMsg.message = gMsgCodes[I] then
          begin
            S := gMsgNames[I];
            Break;
          end;
        if S = '' then
          S := IntToStr(TheRecorder.EventMsg.message);
        WriteLn(F, S, ' ', TheRecorder.EventMsg.paramL, ' ',
          TheRecorder.EventMsg.paramH, ' ', TheRecorder.EventMsg.time, ' ',
          TheRecorder.EventMsg.hwnd);
      end;
    end
    else
    begin
      Reset(F);
      TMemoryStream(TheRecorder.FStream).Clear;
      TheRecorder.SpeedFactor := miSpeed.Tag;
      TheRecorder.DoStop;
      while not Eof(F) do
      begin
        ReadLn(F, S);
        T := Copy(S, 1, Pos(' ', S) - 1);
        Delete(S, 1, Pos(' ', S));
        N := -1;
        for I := 0 to $B4 do
          if UpperCase(T) = gMsgNames[I] then
          begin
            N := gMsgCodes[I];
            Break;
          end;
        if N < 0 then
          if not TryStrToInt(T, N) then
            N := 0;
        TheRecorder.EventMsg.message := N;
        T := Copy(S, 1, Pos(' ', S) - 1);
        Delete(S, 1, Pos(' ', S));
        if not TryStrToInt(T, N) then
          N := 0;
        TheRecorder.EventMsg.paramL := N;
        T := Copy(S, 1, Pos(' ', S) - 1);
        Delete(S, 1, Pos(' ', S));
        if not TryStrToInt(T, N) then
          N := 0;
        TheRecorder.EventMsg.paramH := N;
        T := Copy(S, 1, Pos(' ', S) - 1);
        Delete(S, 1, Pos(' ', S));
        if not TryStrToInt(T, N) then
          N := 0;
        TheRecorder.EventMsg.time := N;
        T := Copy(S, 1, Pos(' ', S) - 1);
        S := '';
        if not TryStrToInt(T, N) then
          N := 0;
        TheRecorder.EventMsg.hwnd := N;
        TheRecorder.FStream.Write(TheRecorder.EventMsg, SizeOf(TheRecorder.EventMsg));
      end;
    end;
  except
    MsgBox('Error', 'UOPilot Error Message', 0);
  end;
  try
    CloseFile(F);
  except
  end;
  {$I+}
end;

procedure TfmSecond.sbLOAddClick(Sender: TObject);
var
  G: TStringGrid;
  N: Integer;
begin
  { Добавляет строку в список последних объектов/целей. Номер берётся из
    последней строки и увеличивается; больше $226 не даёт. }
  G := nil;
  case (Sender as TSpeedButton).Tag of
    1: G := sgLastObject;
    2: G := sgLastTarget;
  end;
  if (G.Cells[0, G.Row] = '') and (G.RowCount = 1) then
    G.Cells[0, G.Row] := '1'
  else
  begin
    try
      N := StrToInt(G.Cells[0, G.RowCount - 1]) + 1;
    except
      { except не пустой: при неразбираемом номере берётся заведомо большое
        значение, и следующая же проверка уводит в ветку с сообщением. }
      N := $226;
    end;
    if N > $226 then
    begin
      SetForegroundWindow(Application.Handle);
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $1AE)), 'UOPilot Error Message', 0)
      else
        MsgBox('Перебор', 'UOPilot Error Message', 0);
      Exit;
    end;
    G.RowCount := G.RowCount + 1;
    G.Row := G.RowCount - 1;
    G.Cells[0, G.Row] := IntToStr(N);
  end;
  sgLastObjectDblClick(G);
end;

procedure TfmSecond.sgLastObjectDblClick(Sender: TObject);
var
  Addr: Cardinal;
  Read: DWORD;
  Pid: DWORD;
  Opened: Boolean;
  Col: Integer;
  Row: Integer;
  P: TPoint;
  G: TStringGrid;
  Ph: THandle;
  Wnd: HWND;
begin
  { Двойной щелчок по списку: в первой колонке вставляет значение в скрипт,
    во второй -- читает адрес из памяти клиента и показывает его. }
  G := Sender as TStringGrid;
  GetCursorPos(P);
  Windows.ScreenToClient(G.Handle, P);
  G.MouseToCell(P.X, P.Y, Col, Row);
  if Col >= 0 then
    if Row >= 0 then
    begin
      G.Row := Row;
      if Col = 0 then
      begin
        edScript.SelText := G.Cells[1, Row];
        Exit;
      end;
    end;
  if G.Col = 1 then
  begin
    if (G.Cells[0, G.Row] = '') and (G.RowCount = 1) then
      G.Cells[0, G.Row] := '1';
    Addr := ClientAddr2[G.Tag, cbClVer.ItemIndex];
    Opened := False;
    if miSCPscript.Checked then
      Ph := gScriptso3[StrToInt(tScript.Tabs[tScript.TabIndex])].ProcessHandle
    else if miSCPtopuo.Checked then
    begin
      Wnd := FindWindow('Ultima Online', nil);
      GetWindowThreadProcessId(Wnd, @Pid);
      Ph := OpenProcess($10, False, Pid);
      Opened := True;
    end
    else
      Ph := fmSecondfj.FClientProcess;
    ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Read);
    if Read <> 4 then
      G.Cells[1, G.Row] := 'error'
    else if miShowHex.Checked then
      G.Cells[1, G.Row] := '0' + IntToHex(Addr, 8)
    else
      G.Cells[1, G.Row] := IntToStr(Addr);
    if (Col < 0) or (Row < 0) then
      G.Cells[2, G.Row] := '';
    if Opened then
      FileClose(Ph); { *Преобразовано из CloseHandle* }
  end;
end;

procedure TfmSecond.sbLODelClick(Sender: TObject);
var
  G: TStringGrid;
  R: Integer;
begin
  G := nil;
  case (Sender as TSpeedButton).Tag of
    1: G := sgLastObject;
    2: G := sgLastTarget;
  end;
  R := G.Row;
  if G.RowCount = 1 then
  begin
    G.Cells[0, 0] := '';
    G.Cells[1, 0] := '';
  end;
  GridDeleteRow(G, G.Row);
  if R < G.RowCount then
    G.Row := R;
end;

procedure TfmSecond.HotKeySetMove1(Sender: TObject);
var
  P: TPoint;
  W: HWND;
begin
  { Локализованный текст берётся из строковых ресурсов по номеру
    gLangOffsety + база. }
  GetCursorPos(P);
  W := WindowFromPoint(P);
  if W = 0 then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $19B)), 'UOPilot Error Message', 0)
    else
      MsgBox('Не могу найти рабочее окно', 'UOPilot Error Message', 0);
  end
  else
  begin
    Windows.ScreenToClient(W, P);
    sbAMove_1.Caption := IntToStr(P.x) + ', ' + IntToStr(P.y);
  end;
end;

procedure TfmSecond.HotKeySetMove2(Sender: TObject);
var
  P: TPoint;
  W: HWND;
begin
  { Локализованный текст берётся из строковых ресурсов по номеру
    gLangOffsety + база. }
  GetCursorPos(P);
  W := WindowFromPoint(P);
  if W = 0 then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $19B)), 'UOPilot Error Message', 0)
    else
      MsgBox('Не могу найти рабочее окно', 'UOPilot Error Message', 0);
  end
  else
  begin
    Windows.ScreenToClient(W, P);
    sbAMove_2.Caption := IntToStr(P.x) + ', ' + IntToStr(P.y);
  end;
end;

procedure TfmSecond.HotKeySetMove3(Sender: TObject);
var
  P: TPoint;
  W: HWND;
begin
  { Локализованный текст берётся из строковых ресурсов по номеру
    gLangOffsety + база. }
  GetCursorPos(P);
  W := WindowFromPoint(P);
  if W = 0 then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $19B)), 'UOPilot Error Message', 0)
    else
      MsgBox('Не могу найти рабочее окно', 'UOPilot Error Message', 0);
  end
  else
  begin
    Windows.ScreenToClient(W, P);
    sbAMove_3.Caption := IntToStr(P.x) + ', ' + IntToStr(P.y);
  end;
end;

procedure TfmSecond.miProcOpenClick(Sender: TObject);
var
  Allow: Boolean;
  I: Integer;
  Th: TScanThread;
begin
  { Вкладка «99» -- это файл процедур, общий для всех скриптов. Если её ещё
    нет, заводится отдельный поток TScanThread с типом '100'. }
  Allow := True;
  tScriptChanging(Sender, Allow);
  I := 0;
  while I <= tScript.Tabs.Count - 1 do
  begin
    if tScript.Tabs[I] = '99' then
      Break;
    Inc(I);
  end;
  if I > tScript.Tabs.Count - 1 then
  begin
    Th := TScanThread.NewScriptTab(True);
    gProcScript := Th;
    Th.SelfRef := gProcScript;
    Th.PauseCmd := '100';
    Th.Name := '99';
    tScript.Tabs.Add('99');
    tScriptDesc.Tabs.Add('99');
  end;
  tScript.TabIndex := I;
  tScriptChange(Sender);
  if Sender = miProcOpen then
  begin
    odLoad.InitialDir := ExtractFilePath(Application.ExeName) + 'Scripts';
    odLoad.FileName := '';
    if gLangOffsety > 0 then
      odLoad.Title := LoadStr(gLangOffsety + $1AF)
    else
      odLoad.Title := 'Загрузить файл процедур...';
    odLoad.Execute;
  end;
  LoadScriptFile(odLoad.FileName);
  if Assigned(gDlg596700) then
    edScript.SetFocus;
  SysUtils.SetCurrentDir(gTempFilefv);
end;

procedure TfmSecond.tScriptMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
  Idx: Integer;
begin
  Idx := tScript.IndexOfTabAt(X, Y);
  if FFlag1464 then
    if Idx >= 0 then
    begin
      R := tScript.TabRect(Idx);
      if (Y >= R.Bottom - 6) and (Y <= R.Bottom) then
        FFlag1467 := False
      else
        FFlag1467 := True;
    end;
  if miShowSFNames.Checked then
  begin
    if Idx >= 0 then
    begin
      if Idx <> fld_145C then
      begin
        tScript.Hint :=
          ExtractFileName(gScriptso3[StrToInt(tScript.Tabs[Idx])].Title);
        fld_145C := Idx;
        if fld_1458 <> 0 then
          HideHintWindow(TObject(fld_1458));
        fld_1458 := Integer(CreateTabHint(tScript));
        tHintTimer.Enabled := False;
        gHintTick := 0;
        tHintTimer.Enabled := True;
      end;
    end
    else
    begin
      if fld_1458 <> 0 then
        HideHintWindow(TObject(fld_1458));
    end;
  end;
end;

function TfmSecond.CreateTabHint(C: TWinControl): THintWindow;
var
  S: string;
  P: TPoint;
  R: TRect;
begin
  { Окно подсказки над вкладкой скрипта: создаётся, меряется под текст
    C.Hint и показывается под вкладкой -- ActivateHint сам делает окно
    видимым. И Bounds, и OffsetRect обязаны быть квалифицированы как
    Types: иначе первый уйдёт в Classes.Bounds, второй -- в stdcall
    из Windows.pas. }
  Result := THintWindow.Create(C);
  S := C.Hint;
  P := C.ClientOrigin;
  Inc(P.Y, C.Height + 8);
  R := Types.Bounds(0, 0, Screen.Width, 0);
  DrawText(Result.Canvas.Handle, PChar(S), -1, R,
    DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
  Types.OffsetRect(R, P.X, P.Y);
  Inc(R.Right, 6);
  Inc(R.Bottom, 2);
  Result.ActivateHint(R, S);
end;

procedure TfmSecond.CharParamsFormClose(Sender: TObject;
      var Action: TCloseAction);
begin
  // закрытие окна параметров персонажа
end;

procedure TfmSecond.HideHintWindow(var W: TObject);
begin
  THintWindow(W).ReleaseHandle;
  FreeAndNil(W);
end;

procedure TfmSecond.tHintTimerTimer(Sender: TObject);
begin
  if not gHintPhase then
    gHintTick := 100;
  if gHintTick > 14 then
  begin
    if fld_1458 <> 0 then
      HideHintWindow(TObject(fld_1458));
    tHintTimer.Enabled := False;
  end;
  Inc(gHintTick);
end;

procedure TfmSecond.ScriptTabWndProc(var Message: TMessage);
begin
  { $B013 и $B014 -- CM_MOUSEENTER и CM_MOUSELEAVE: курсор вошёл на ярлык
    вкладки и ушёл с него. Значения идут подряд, поэтому цепочка case-а
    сворачивается в вычитание с двумя переходами. }
  case Message.Msg of
    CM_MOUSELEAVE:
      begin
        gHintPhase := False;
        fld_145C := -1;
      end;
    CM_MOUSEENTER: gHintPhase := True;
  end;
  gOldTabChange(Message);
end;

procedure TfmSecond.sbCharParamsClick(Sender: TObject);
var
  Mask: Integer;
  M: TMonitor;
  I: Integer;
begin
  { Панель параметров чара: какая именно панель показывается, определяется
    маской нажатых кнопок sbCFCP1..8 -- ровно одна из них должна быть нажата,
    иначе форма не опознана. }
  Mask := Ord(sbCFCP8.Down) shl 6 + Ord(sbCFCP7.Down) shl 5 +
          Ord(sbCFCP1.Down) shl 4 + Ord(sbCFCP2.Down) shl 3 +
          Ord(sbCFCP3.Down) shl 2 + Ord(sbCFCP4.Down) * 2 +
          Ord(sbCFCP5.Down);
  if not (Mask in [1, 2, 4, 8, 16, 32, 64]) then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $1B0)), 'UOPilot Error Message', 0)
    else
      MsgBox('Не могу определить тип формы.', 'UOPilot Error Message', 0);
    Exit;
  end;
  if gDlg5966F0 = nil then
  begin
    gDlg5966F0 := TForm.Create(fmSecondfj);
    gDlg5966F0.Parent := nil;
    gDlg5966F0.Font := fmSecondfj.Font;
    gDlg5966F0.BorderStyle := bsToolWindow;
    gOldCPProc := gDlg5966F0.WindowProc;
    gDlg5966F0.WindowProc := CharParamsWndProc;
    if miSOTCharParameters.Checked then
      gDlg5966F0.FormStyle := fsStayOnTop
    else
      gDlg5966F0.FormStyle := fsNormal;
    if gLangOffsety > 0 then
      gDlg5966F0.Caption := LoadStr(gLangOffsety + $1B1)
    else
      gDlg5966F0.Caption := 'Параметры чара';
    pCPLastObjects.Parent := gDlg5966F0;
    pCPVar.Parent := gDlg5966F0;
    pCPDTimer.Parent := gDlg5966F0;
    pCharParams.Parent := gDlg5966F0;
    gDlg5966F0.HorzScrollBar.Visible := False;
    gDlg5966F0.VertScrollBar.Visible := False;
    { обработчик снят на время перестановки панелей }
    gDlg5966F0.OnResize := nil;
    if pCPVar.Tag = 0 then
    begin
      pCPVar.Tag := pCPVar.Width;
      gWidth596A64 := 0;
    end;
    { какая панель показывается -- определяет обработчик соответствующей кнопки }
    case Mask of
      1: sbCFCP5Click(Sender);
      2: sbCFCP4Click(Sender);
      4: sbCFCP3Click(Sender);
      8: sbCFCP2Click(Sender);
      16: sbCFCP1Click(Sender);
      32: sbCFCP7Click(Sender);
      64: sbCFCP8Click(Sender);
    end;
    gDlg5966F0.OnResize := CFCPRelayout;
    if (gWinPos[0] <> -1) and (gWinPos[1] <> -1) and miSPosCP.Checked then
    begin
      gDlg5966F0.Top := gWinPos[0];
      gDlg5966F0.Left := gWinPos[1];
    end
    else
    begin
      M := Screen.MonitorFromWindow(fmFirstfj.Handle, mdNearest);
      if Screen.Height <= $280 then
        gDlg5966F0.Top := -1
      else
        gDlg5966F0.Top := (M.Height - gDlg5966F0.Height) div 2 - 10;
      gDlg5966F0.Left := M.Width - gDlg5966F0.Width - 2;
    end;
    sgSkills.RowCount := $3A;
    sgSkills.ColWidths[0] := $10;
    sgSkills.ColWidths[1] := $58;
    sgSkills.ColWidths[2] := $1E;
    for I := 0 to $39 do
    begin
      sgSkills.Cells[0, I] := IntToStr(I);
      sgSkills.Cells[1, I] := gSkillNames[I].Name;
      sgSkills.Cells[2, I] := '0';
    end;
    gDlg5966F0.HorzScrollBar.Visible := False;
    gDlg5966F0.VertScrollBar.Visible := False;
    gDlg5966F0.OnResize := CFCPRelayout;
    gDlg5966F0.OnCloseQuery := CharParamsCloseQuery;
    gDlg5966F0.Visible := True;
    Application.OnDeactivate := AppActivateKeepTopmost;
    { раскладку надо посчитать сразу, не дожидаясь первого WM_SIZE }
    CFCPRelayout(Sender);
  end
  else
  begin
    { форма уже открыта -- запоминаем позицию, возвращаем панели на главную
      форму и освобождаем окно }
    gWinPos[0] := gDlg5966F0.Top;
    gWinPos[1] := gDlg5966F0.Left;
    case gDlg5966F0.Tag of
      2: gPanelPads[2] := gDlg5966F0.ClientHeight;
      5: gPanelPads[5] := gDlg5966F0.ClientHeight;
    end;
    pCharParams.Visible := False;
    pCPLastObjects.Visible := False;
    pCPVar.Visible := False;
    pCPDTimer.Visible := False;
    pCharParams.Parent := fmSecondfj;
    pCPLastObjects.Parent := fmSecondfj;
    pCPVar.Parent := fmSecondfj;
    pCPDTimer.Parent := fmSecondfj;
    pCharParams.Left := $1E8;
    pCPLastObjects.Left := $1E8;
    pCPVar.Left := $1E8;
    pCPDTimer.Left := $1E8;
    gDlg5966F0.WindowProc := gOldCPProc;
    try
      gDlg5966F0.Free;
      gDlg5966F0 := nil;
    except
    end;
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end;
  sbCharParams.Down := gDlg5966F0 <> nil;
  Timer1.Enabled := sbCharParams.Down;
  if Timer1.Enabled then
    Timer1Timer(Sender);
end;

procedure TfmSecond.mParamNameEnter(Sender: TObject);
begin
  cbDrinkTimer.SetFocus;
end;

function TfmSecond.CanCloseOrActivate: Boolean;
begin
  // Окно можно закрыть/активировать, если открыто хоть одно вспомогательное
  // окно, ЛИБО взведён флажок «поверх всех».
  if (gDlg5966F4 <> nil) or
     (gDlg5966E8 <> nil) or
     (gDlg5966E4 <> nil) or
     (gDlg5966EC <> nil) or
     ((gDlg596718 <> nil) and gDlg596718.Visible) or
     (gDlg5966F0 <> nil) or
     (gDlg5966F8c6 <> nil) or
     cbSOT.Checked then
    Result := True
  else
    Result := False;
end;

procedure TfmSecond.SetRunButtonsStopped;
begin
  btStart.Down := False;
  sbPause.Down := False;
  sbPause.Visible := False;
  edScript.Visible := True;
  edScript.Enabled := False;
end;

procedure TfmSecond.SetRunButtonsStarted;
begin
  btStart.Down := True;
  btStart.Visible := False;
  btStart.Visible := True;
  sbPause.Down := False;
  sbPause.Visible := True;
  edScript.Visible := False;
  edScript.Enabled := True;
end;

procedure TfmSecond.miSCPscriptClick(Sender: TObject);
begin
end;

procedure TfmSecond.miInvertChecked(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
end;

procedure TfmSecond.miShowHexClick(Sender: TObject);
var
  I: Integer;
  S: string;
begin
  { Переключение показа адресов: шестнадцатеричные значения получают
    префикс 0x, обратно -- разворачиваются в десятичные. }
  if miShowHex.Checked then
    btColor.Caption := '0x' + IntToHex(StrToInt(btColor.Caption), 6)
  else
    btColor.Caption := IntToStr(StrToInt(btColor.Caption));
  for I := 0 to sgLastObject.RowCount - 1 do
  begin
    try
      S := sgLastObject.Cells[1, I];
      if Length(S) > 0 then
      begin
        if Length(S) > 1 then
          if S[1] = '0' then
            if S[2] <> 'x' then
              S := '0x' + S;
        if miShowHex.Checked then
          sgLastObject.Cells[1, I] := '0' + IntToHex(StrToInt(S), 8)
        else
          sgLastObject.Cells[1, I] := IntToStr(StrToInt(S));
      end;
    except
    end;
  end;
  for I := 0 to sgLastTarget.RowCount - 1 do
  begin
    try
      S := sgLastTarget.Cells[1, I];
      if Length(S) > 0 then
      begin
        if Length(S) > 1 then
          if S[1] = '0' then
            if S[2] <> 'x' then
              S := '0x' + S;
        if miShowHex.Checked then
          sgLastTarget.Cells[1, I] := '0' + IntToHex(StrToInt(S), 8)
        else
          sgLastTarget.Cells[1, I] := IntToStr(StrToInt(S));
      end;
    except
    end;
  end;
end;

procedure TfmSecond.miSaveLOClick(Sender: TObject);
var
  OldFile, OldFilter, OldDir, OldTitle: string;
  OldIndex: Integer;
  G: TStringGrid;
  S1, S2, S3: string;
  I: Integer;
  F: TextFile;
begin
{$I-}
  { Загрузка/сохранение таблицы последних объектов. Один обработчик на два
    пункта меню: который из них нажали, видно по имени Sender.
    Настройки диалога подменяются на время вызова и возвращаются обратно. }
  if pmSaveLoadLO.PopupComponent = sgLastObject then
    G := sgLastObject
  else
    G := sgLastTarget;
  if (Sender as TMenuItem).Name = 'miLoadLO' then
  begin
    OldFile := odLoad.FileName;
    OldFilter := odLoad.Filter;
    OldDir := odLoad.InitialDir;
    OldTitle := odLoad.Title;
    OldIndex := odLoad.FilterIndex;
    odLoad.FileName := '';
    if gLangOffsety > 0 then
      odLoad.Filter := LoadStr(gLangOffsety + $1B2)
    else
      odLoad.Filter := 'Файлы таблиц (*.tbl)|*.tbl|Все файлы (*.*)|*.*';
    odLoad.FilterIndex := 0;
    odLoad.InitialDir := ExtractFilePath(Application.ExeName) + 'Scripts';
    if gLangOffsety > 0 then
      odLoad.Title := LoadStr(gLangOffsety + $1B3)
    else
      odLoad.Title := 'Загрузить таблицу...';
    if odLoad.Execute then
    begin
      AssignFile(F, odLoad.FileName);
      Reset(F);
      ReadLn(F, S1);
      ReadLn(F, S2);
      ReadLn(F, S3);
      FillGridFromCsv(G, S1, S2, S3, miShowHex.Checked);
      CloseFile(F);
    end;
    odLoad.FileName := OldFile;
    odLoad.Filter := OldFilter;
    odLoad.InitialDir := OldDir;
    odLoad.Title := OldTitle;
    odLoad.FilterIndex := OldIndex;
  end
  else
  begin
    OldFile := sdSave.FileName;
    OldFilter := sdSave.Filter;
    OldDir := sdSave.InitialDir;
    OldTitle := sdSave.Title;
    OldIndex := sdSave.FilterIndex;
    sdSave.FileName := '';
    if gLangOffsety > 0 then
      sdSave.Filter := LoadStr(gLangOffsety + $1B2)
    else
      sdSave.Filter := 'Файлы таблиц (*.tbl)|*.tbl|Все файлы (*.*)|*.*';
    sdSave.FilterIndex := 0;
    sdSave.InitialDir := ExtractFilePath(Application.ExeName) + 'Scripts';
    if gLangOffsety > 0 then
      sdSave.Title := LoadStr(gLangOffsety + $1B4)
    else
      sdSave.Title := 'Сохранить таблицу как...';
    if sdSave.Execute then
    begin
      AssignFile(F, sdSave.FileName);
      Rewrite(F);
      S1 := '';
      for I := 1 to G.RowCount do
        S1 := S1 + G.Cells[0, I - 1] + ',';
      WriteLn(F, S1);
      S1 := '';
      for I := 1 to G.RowCount do
        S1 := S1 + G.Cells[1, I - 1] + ',';
      WriteLn(F, S1);
      S1 := '';
      for I := 1 to G.RowCount do
        S1 := S1 + G.Cells[2, I - 1] + ',';
      WriteLn(F, S1);
      CloseFile(F);
    end;
    sdSave.FileName := OldFile;
    sdSave.Filter := OldFilter;
    sdSave.InitialDir := OldDir;
    sdSave.Title := OldTitle;
    sdSave.FilterIndex := OldIndex;
  end;
{$I+}
end;

procedure TfmSecond.mParamValue2DblClick(Sender: TObject);
var
  C, R: Integer;
  P: TPoint;
  S: string;
begin
  GetCursorPos(P);
  Windows.ScreenToClient(mParamValue2.Handle, P);
  mParamValue2.MouseToCell(P.X, P.Y, C, R);
  S := mParamValue2.Cells[0, R];
  edScript.SelText := S;
end;

procedure TfmSecond.mParamValue2SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if ACol <> 1 then
    CanSelect := False;
end;

procedure TfmSecond.miClesrLOClick(Sender: TObject);
var
  G: TStringGrid;
begin
  if pmSaveLoadLO.PopupComponent = sgLastObject then
    G := sgLastObject
  else
    G := sgLastTarget;
  G.RowCount := 1;
  G.Cells[0, 0] := '';
  G.Cells[1, 0] := '';
  G.Cells[2, 0] := '';
end;

procedure TfmSecond.cbNameClick(Sender: TObject);
var
  B: Byte;
  N: DWORD;
  Pid: DWORD;
  IsMI: Boolean;
  Wnd: HWND;
  Ph: THandle;
  MI: TMenuItem;
  Addr: Cardinal;
begin
  { Переключатели «имена/прозрачность/подсветка преступников/поиск пути»
    правят байт прямо в памяти клиента: адрес берётся из таблицы по выбранной
    версии клиента, а какой именно флаг -- по Tag пункта меню. }
  Wnd := FindWindow('Ultima Online', nil);
  GetWindowThreadProcessId(Wnd, @Pid);
  Ph := OpenProcess($638, False, Pid);
  IsMI := False;
  Addr := 0;
  MI := nil;
  if Sender is TMenuItem then
  begin
    MI := Sender as TMenuItem;
    IsMI := True;
  end;
  if Wnd <> 0 then
    if IsMI then
    begin
      case MI.Tag of
        1: Addr := ClientAddr[0, cbClVer.ItemIndex];
        2: Addr := ClientAddr[1, cbClVer.ItemIndex];
        3: Addr := ClientAddr[3, cbClVer.ItemIndex];
        4: Addr := ClientAddr[2, cbClVer.ItemIndex];
        5: Addr := ClientAddr[22, cbClVer.ItemIndex];
      end;
      ReadProcessMemory(Ph, Pointer(Addr), @B, 1, N);
      MI.Checked := not Boolean(B);
      B := Byte(MI.Checked);
      WriteProcessMemory(Ph, Pointer(Addr), @B, 1, N);
    end;
  FileClose(Ph); { *Преобразовано из CloseHandle* }
end;

procedure TfmSecond.miScriptFontSelectClick(Sender: TObject);
begin
  { Один обработчик на два пункта меню: шрифт редактора и шрифт лога.
    Высота вкладок лога считается как -Font.Height * 20 div 12. }
  if Sender = miScriptFontSelect then
  begin
    gFontTarget := 1;
    fdEditor.Font := edScript.Font;
    if fdEditor.Execute then
    begin
      edScript.Font := fdEditor.Font;
      if gFontApplyBoth then
      begin
        gEditorFontSize := edScript.Font.Size;
        gEditorFontName := edScript.Font.Name;
      end
      else
      begin
        gLogFontSize := edScript.Font.Size;
        gLogFontName := edScript.Font.Name;
      end;
    end;
  end
  else
  begin
    gFontTarget := 2;
    fdEditor.Font := pLog.Font;
    if fdEditor.Execute then
    begin
      pLog.Font := fdEditor.Font;
      gListFontSize := pLog.Font.Size;
    end;
    tcLog.Height := -tcLog.Font.Height * 20 div 12;
    ApplyLogFont;
  end;
end;

procedure TfmSecond.ApplyLogFont;
var
  DC: HDC;
  Old: HGDIOBJ;
  TM: TTextMetric;
  H: Integer;
begin
  H := 0;
  DC := GetDC(pLog.Handle);
  if DC <> 0 then
  begin
    Old := SelectObject(DC, pLog.Font.Handle);
    if GetTextMetrics(DC, TM) then
      H := TM.tmHeight + TM.tmExternalLeading;
    SelectObject(DC, Old);
    ReleaseDC(pLog.Handle, DC);
  end;
  if H <> 0 then
    Exit;
end;

procedure TfmSecond.fdEditorApply(Sender: TObject; Wnd: HWND);
begin
  case gFontTarget of
    1:
      begin
        edScript.Font := fdEditor.Font;
        if gFontApplyBoth then
        begin
          gEditorFontSize := edScript.Font.Size;
          gEditorFontName := edScript.Font.Name;
        end
        else
        begin
          gLogFontSize := edScript.Font.Size;
          gLogFontName := edScript.Font.Name;
        end;
      end;
    2:
      begin
        pLog.Font := fdEditor.Font;
        gListFontSize := pLog.Font.Size;
      end;
  end;
end;

procedure TfmSecond.sbCFCP1Click(Sender: TObject);
begin
  if Assigned(gDlg5966F0) then
  begin
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    pCPVar.Visible := False;
    gDlg5966F0.BorderStyle := bsSingle;
    gDlg5966F0.ClientHeight := pCPLastObjects.Height + pCharParams.Height +
      pCPDTimer.Height;
    gDlg5966F0.ClientWidth := pCharParams.Width;
    pCharParams.Left := 0;
    pCharParams.Top := 0;
    pCPLastObjects.Left := 0;
    pCPLastObjects.Top := pCharParams.Height;
    pCPDTimer.Left := 0;
    pCPDTimer.Top := pCPLastObjects.Height + pCharParams.Height;
    pCPDTimer.Visible := True;
    pCharParams.Visible := True;
    pCPLastObjects.Visible := True;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxWidth := gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 1;
    CFCPRelayout(Sender);
  end;
end;

procedure TfmSecond.sbCFCP2Click(Sender: TObject);
begin
  if Assigned(gDlg5966F0) then
  begin
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    pCPLastObjects.Visible := False;
    gDlg5966F0.BorderStyle := bsSizeable;
    gDlg5966F0.ClientWidth := pCharParams.Width;
    gDlg5966F0.ClientHeight := pCPVar.Height + pCharParams.Height +
      pCPDTimer.Height;
    pCharParams.Left := 0;
    pCharParams.Top := 0;
    pCPVar.Align := alNone;
    pCPVar.Width := pCPVar.Tag;
    pCPVar.Left := 0;
    pCPVar.Top := pCharParams.Height;
    pCPDTimer.Left := 0;
    pCPDTimer.Top := pCPVar.Height + pCharParams.Height;
    pCharParams.Visible := True;
    pCPDTimer.Visible := True;
    pCPVar.Visible := True;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height - pCPVar.Height +
      gPanelPads[0];
    gDlg5966F0.Constraints.MaxWidth := gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 2;
    CFCPRelayout(Sender);
  end;
end;

procedure TfmSecond.sbCFCP4Click(Sender: TObject);
begin
  if Assigned(gDlg5966F0) then
  begin
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    gDlg5966F0.BorderStyle := bsSingle;
    pCPVar.Align := alNone;
    pCPVar.Height := gPanelPads[0];
    pCPVar.Width := pCPVar.Tag;
    gDlg5966F0.ClientHeight := pCharParams.Height;
    gDlg5966F0.ClientWidth := pCPVar.Tag + pCharParams.Width;
    pCharParams.Left := 0;
    pCharParams.Top := 0;
    pCPLastObjects.Left := pCharParams.Width;
    pCPLastObjects.Top := pCPVar.Height + $F + 5;
    pCPVar.Left := pCharParams.Width;
    pCPVar.Top := $F;
    pCPDTimer.Left := pCharParams.Width;
    pCPDTimer.Top := pCPLastObjects.Top + pCPLastObjects.Height;
    pCPLastObjects.Visible := True;
    pCharParams.Visible := True;
    pCPDTimer.Visible := True;
    pCPVar.Visible := True;
    { Если окно вылезло за правый край экрана -- прижать его к краю }
    if Screen.DesktopWidth < gDlg5966F0.Width + gDlg5966F0.Left then
      gDlg5966F0.Left := Screen.DesktopWidth - gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxWidth := gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 4;
    CFCPRelayout(Sender);
  end;
end;

procedure TfmSecond.sbCFCP3Click(Sender: TObject);
begin
  if Assigned(gDlg5966F0) then
  begin
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    pCPLastObjects.Visible := False;
    pCPVar.Visible := False;
    gDlg5966F0.BorderStyle := bsSingle;
    gDlg5966F0.ClientHeight := pCharParams.Height + pCPDTimer.Height;
    gDlg5966F0.ClientWidth := pCharParams.Width;
    pCharParams.Left := 0;
    pCharParams.Top := 0;
    pCPDTimer.Left := 0;
    pCPDTimer.Top := pCharParams.Height;
    pCharParams.Visible := True;
    pCPDTimer.Visible := True;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxWidth := gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 3;
    CFCPRelayout(Sender);
  end;
end;

procedure TfmSecond.sbCFCP5Click(Sender: TObject);
begin
  if Assigned(gDlg5966F0) then
  begin
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    pCharParams.Visible := False;
    gDlg5966F0.BorderStyle := bsSizeable;
    gDlg5966F0.ClientWidth := pCharParams.Width;
    pCPLastObjects.Left := 0;
    pCPLastObjects.Top := pCPVar.Height + 5;
    pCPVar.Align := alNone;
    pCPVar.Width := pCPVar.Tag;
    pCPVar.Left := 0;
    pCPVar.Top := 0;
    pCPDTimer.Left := 0;
    pCPDTimer.Top := pCPLastObjects.Top + pCPLastObjects.Height;
    gDlg5966F0.ClientHeight := pCPDTimer.Top + pCPDTimer.Height;
    pCPLastObjects.Visible := True;
    pCPDTimer.Visible := True;
    pCPVar.Visible := True;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height - pCPVar.Height +
      gPanelPads[0];
    gDlg5966F0.Constraints.MaxWidth := gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 5;
    CFCPRelayout(Sender);
  end;
end;

procedure TfmSecond.sbCFCP7Click(Sender: TObject);
begin
  if Assigned(gDlg5966F0) then
  begin
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    pCharParams.Visible := False;
    pCPVar.Visible := False;
    gDlg5966F0.BorderStyle := bsSingle;
    gDlg5966F0.ClientWidth := pCharParams.Width;
    pCPLastObjects.Left := 0;
    pCPLastObjects.Top := 0;
    pCPVar.Left := 0;
    pCPVar.Top := 0;
    pCPDTimer.Left := 0;
    pCPDTimer.Top := pCPLastObjects.Top + pCPLastObjects.Height;
    gDlg5966F0.ClientHeight := pCPDTimer.Top + pCPDTimer.Height;
    pCPLastObjects.Visible := True;
    pCPDTimer.Visible := True;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxHeight := gDlg5966F0.Height;
    gDlg5966F0.Constraints.MaxWidth := gDlg5966F0.Width;
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 7;
    CFCPRelayout(Sender);
  end;
end;

procedure TfmSecond.sbCFCP8Click(Sender: TObject);
begin
  if gDlg5966F0 = nil then
    Exit;
    sbCharParams.Tag := 0;
    gDlg5966F0.Constraints.MinHeight := 0;
    gDlg5966F0.Constraints.MaxHeight := 0;
    gDlg5966F0.Constraints.MaxWidth := 0;
    gDlg5966F0.Constraints.MinWidth := 0;
    pCharParams.Visible := False;
    pCPLastObjects.Visible := False;
    pCPDTimer.Visible := False;
    gDlg5966F0.BorderStyle := bsSizeable;
    gDlg5966F0.ClientWidth := pCharParams.Width;
    pCPVar.Left := 0;
    pCPVar.Top := 0;
    gDlg5966F0.ClientHeight := pCPVar.Height;
    if pCPVar.Tag < gWidth596A64 then
      gDlg5966F0.ClientWidth := gWidth596A64;
    pCPVar.Visible := True;
    gDlg5966F0.Constraints.MinHeight := gDlg5966F0.Height - pCPVar.Height +
      gPanelPads[0];
    gDlg5966F0.Constraints.MinWidth := gDlg5966F0.Width;
    sbCharParams.Tag := 8;
    pCPVar.Align := alClient;
    CFCPRelayout(Sender);
  
end;

procedure TfmSecond.miStopSErrorReadClick(Sender: TObject);
begin
  if miStopSErrorRead.Checked then
    miPauseSErrorRead.Checked := False;
end;

procedure TfmSecond.miPauseSErrorReadClick(Sender: TObject);
begin
  if miPauseSErrorRead.Checked then
    miStopSErrorRead.Checked := False;
end;

procedure TfmSecond.miInformErrorReadClick(Sender: TObject);
begin
end;

procedure TfmSecond.miAboutClick(Sender: TObject);
const
  cBuildDate = '15.05.2021';
var
  X: Integer;
  Y: Integer;
  I: Integer;
  Img: TImage;
  lbVer, lbCopy, lbHidden, lbWM, lbYM: TLabel;
  wlSite, wlForum, wlMail: TWebLabel;
  mmWM, mmYM, mmThanks, mmDonate: TMemo;
  S: string;
begin
  { Окно «О программе» строится целиком кодом, без DFM: форма создаётся один
    раз и дальше только показывается/прячется. Под каждый элемент заведена
    своя переменная. }
  if gAboutForm = nil then
  begin
    gAboutForm := TForm.Create(fmSecondfj);
    gAboutForm.BorderStyle := bsDialog;
    if gLangOffsety > 0 then
      gAboutForm.Caption := LoadStr(gLangOffsety + $1B5)
    else
      gAboutForm.Caption := ' О программе UoPilot';
    gAboutForm.OnCloseQuery := AboutFormClose;
    gAboutForm.ClientHeight := $142;
    gAboutForm.ClientHeight := gAboutForm.ClientHeight + $14 + $3C - $E;
    gAboutForm.ClientWidth := $185;
    gAboutForm.OnKeyPress := FormsKeyPress;
    gAboutForm.KeyPreview := True;
    X := (fmSecondfj.Width - gAboutForm.Width) div 2 + fmSecondfj.Left;
    Y := (fmSecondfj.Height - gAboutForm.Height) div 2 + fmSecondfj.Top;
    if X < 0 then
      X := 0;
    if Y < 0 then
      Y := 0;
    if Screen.DesktopWidth < gAboutForm.Width + X then
      X := Screen.DesktopWidth - gAboutForm.Width;
    if Screen.DesktopHeight < gAboutForm.Height + Y then
      Y := Screen.DesktopHeight - gAboutForm.Height;
    gAboutForm.Left := X;
    gAboutForm.Top := Y;
    SetWindowPos(gAboutForm.Handle, HWND_TOPMOST, 1, 1, 1, 1,
      SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
    { иконка приложения }
    Img := TImage.Create(gAboutForm);
    Img.Parent := gAboutForm;
    Img.Left := $21;
    Img.Top := $10;
    Img.Width := $20;
    Img.Height := $20;
    Img.AutoSize := True;
    Img.Picture.Icon.Handle := Application.Icon.Handle;
    { строка версии собирается в четыре приёма прямо в Caption метки }
    lbVer := TLabel.Create(gAboutForm);
    lbVer.Parent := gAboutForm;
    lbVer.Left := $49;
    lbVer.Top := $10;
    lbVer.Width := $105;
    lbVer.Height := $D;
    lbVer.Alignment := taCenter;
    lbVer.AutoSize := False;
    lbVer.Caption := '';
    lbVer.Caption := lbVer.Caption;
    lbVer.Caption := '2.42' + lbVer.Caption + '';
    lbVer.Caption := lbVer.Caption + ' (' + cBuildDate + ')';
    lbVer.Caption := 'UoPilot Version ' + lbVer.Caption;
    lbCopy := TLabel.Create(gAboutForm);
    lbCopy.Parent := gAboutForm;
    lbCopy.Left := $49;
    lbCopy.Top := $20;
    lbCopy.Width := $105;
    lbCopy.Height := $D;
    lbCopy.Alignment := taCenter;
    lbCopy.AutoSize := False;
    { год берётся не константой, а вырезкой из строки даты сборки }
    lbCopy.Caption := 'Copyright (c) 2002-' + Copy(cBuildDate, 7, 4) +
      ' by White Knight';
    { ссылка на сайт: русский раздел подставляется только для русской локали }
    wlSite := TWebLabel.Create(gAboutForm);
    wlSite.Parent := gAboutForm;
    wlSite.Left := $72;
    wlSite.Top := $36;
    wlSite.Width := $B3;
    wlSite.Height := $D;
    wlSite.Alignment := taCenter;
    wlSite.AutoSize := False;
    wlSite.Link := 'uopilot.uokit.com';
    wlSite.Caption := 'http://' + wlSite.Link;
    if (gLangOffsety = 2000) or (gLangOffsety = 0) then
      wlSite.Link := wlSite.Link + '/index_rus.html';
    wlSite.LinkType := lnHttp;
    wlSite.Hint := 'UoPilot home page';
    wlSite.ShowHint := True;
    wlSite.Font.Color := clBlue;
    wlSite.Cursor := crHandPoint;
    wlSite.Font.Style := wlSite.Font.Style - [fsUnderline];
    { адрес форума переехал: до 2012 года -- ultimasoft.ru, дальше uokit.com }
    wlForum := TWebLabel.Create(gAboutForm);
    wlForum.Parent := gAboutForm;
    wlForum.Left := $2D;
    wlForum.Top := $46;
    wlForum.Width := $13A;
    wlForum.Height := $D;
    wlForum.Alignment := taCenter;
    wlForum.AutoSize := False;
    if Copy(FormatDateTime('dd.mm.yyyy', Now), 7, 4) = '2012' then
      wlForum.Link := 'forum.ultimasoft.ru/index.php?showforum=87'
    else
      wlForum.Link := 'forum.uokit.com/index.php?showforum=87';
    wlForum.Caption := 'http://' + wlForum.Link;
    wlForum.LinkType := lnHttp;
    wlForum.Hint := 'UoPilot forum';
    wlForum.ShowHint := True;
    wlForum.Font.Color := clBlue;
    wlForum.Cursor := crHandPoint;
    wlForum.Font.Style := wlForum.Font.Style - [fsUnderline];
    { почта: в теме письма уходит заголовок главного окна }
    wlMail := TWebLabel.Create(gAboutForm);
    wlMail.Parent := gAboutForm;
    wlMail.Left := $7A;
    wlMail.Top := $56;
    wlMail.Width := $A3;
    wlMail.Height := $D;
    wlMail.Alignment := taCenter;
    wlMail.AutoSize := False;
    wlMail.Link := 'uopilotwk@ya.ru';
    wlMail.Caption := wlMail.Link;
    wlMail.Link := wlMail.Link + '?subject=' + fmSecondfj.Caption;
    wlMail.LinkType := lnMailto;
    wlMail.Hint := 'Mail to me';
    wlMail.ShowHint := True;
    wlMail.Font.Color := clBlue;
    wlMail.Cursor := crHandPoint;
    wlMail.Font.Style := wlMail.Font.Style - [fsUnderline];
    S := '';
    { метка со скрытой строкой: Caption у только что созданной метки пуст,
      поэтому цикл не выполняется ни разу }
    lbHidden := TLabel.Create(gAboutForm);
    lbHidden.Parent := gAboutForm;
    lbHidden.Left := $26;
    lbHidden.Top := $6A;
    lbHidden.Width := $14B;
    lbHidden.Height := $D;
    lbHidden.Alignment := taCenter;
    lbHidden.AutoSize := False;
    for I := Length(lbHidden.Caption) downto 1 do
    begin
      S := lbHidden.Caption[I] + S;
      S[1] := Chr(Ord(S[1]) xor (I + $75) + 7);
    end;
    lbHidden.Caption := S;
    lbWM := TLabel.Create(gAboutForm);
    lbWM.Parent := gAboutForm;
    lbWM.Left := $41;
    lbWM.Top := $7F;
    lbWM.Width := $55;
    lbWM.Height := $D;
    lbWM.Alignment := taCenter;
    lbWM.AutoSize := False;
    lbWM.Caption := 'WebMoney';
    S := '';
    { номера кошельков собраны из IntToStr по цифрам -- чтобы их не нашли
      поиском строки в exe }
    mmWM := TMemo.Create(gAboutForm);
    mmWM.Parent := gAboutForm;
    mmWM.Left := $41;
    mmWM.Top := $8F;
    mmWM.Width := $55;
    mmWM.Height := $27;
    mmWM.Alignment := taCenter;
    { без квалификатора: это AutoSize самой формы, а не мемо }
    AutoSize := False;
    mmWM.BorderStyle := bsNone;
    mmWM.ReadOnly := True;
    mmWM.Text := 'Z' + IntToStr(35) + IntToStr(31) + IntToStr(14) + IntToStr(40) +
      IntToStr(82) + IntToStr(74) + #13#10 + 'U' + IntToStr(14) +
      IntToStr(59) + IntToStr(31) + IntToStr(77) + IntToStr(97) +
      IntToStr(18) + #13#10 + 'R' + IntToStr(84) + IntToStr(94) +
      IntToStr(64) + IntToStr(45) + IntToStr(13) + IntToStr(36);
    lbYM := TLabel.Create(gAboutForm);
    lbYM.Parent := gAboutForm;
    lbYM.Left := $DC;
    lbYM.Top := $7F;
    lbYM.Width := $64;
    lbYM.Height := $D;
    lbYM.Alignment := taCenter;
    lbYM.AutoSize := False;
    lbYM.Caption := 'Yandex-Money';
    mmYM := TMemo.Create(gAboutForm);
    mmYM.Parent := gAboutForm;
    mmYM.Left := $DC;
    mmYM.Top := $8F;
    mmYM.Width := $64;
    mmYM.Height := $D;
    mmYM.Alignment := taCenter;
    AutoSize := False;
    mmYM.BorderStyle := bsNone;
    mmYM.ReadOnly := True;
    mmYM.Text := IntToStr(4) + IntToStr(100) + IntToStr(114) + IntToStr(22) +
      IntToStr(5) + IntToStr(50) + IntToStr(40) + IntToStr(5);
    { благодарности }
    mmThanks := TMemo.Create(gAboutForm);
    mmThanks.Parent := gAboutForm;
    mmThanks.Lines.Add('under construction');
    mmThanks.Left := 6;
    mmThanks.Top := $F8;
    mmThanks.Top := mmThanks.Top + $14;
    mmThanks.Width := $179;
    mmThanks.Height := $70;
    mmThanks.TabStop := False;
    mmThanks.Color := $FF000018;
    mmThanks.ReadOnly := True;
    mmThanks.ScrollBars := ssVertical;
    mmThanks.TabOrder := 0;
    mmThanks.Font.Height := -8;
    mmThanks.Lines.Text := 'Thanks to:'#13#10 +
        'Blade[RBG] (blade17@rambler.ru): за оригинальную версию и ее исходники;'#13#10 +
        'Destruction (UltimaSoft.ru): за форум, тестирование, моральную и материальную поддержку, и прочие полезности;'#13#10 +
        'Anonymous (internet_mail@hotbox.ru): за форум, поиск адресов, тестирование и прочие полезности;'#13#10 +
        'GM F@got[FL] (rv3fs@afaru.ru): за поддержку клиента версии 1.26.4e;'#13#10 +
        'SVS RUSSIAN (svs_russian@hotmail.com): за помощь в переводе UoPilot''a на английский язык;'#13#10 +
        'Edred (tercia@spb.lanck.net): за создание нормального хелпа по языку скриптов;'#13#10 +
        'Gustavo (theyue@ibest.com.br): за помощь в переводе UoPilot''a на португальский язык;'#13#10 +
        'Vladimir ''SirZ'' K : за полную поддержку клиента версии 6.0.12.3-4, 6.0.13.0, 6.0.14.1-2, 7.0.4.3-5, 7.0.5.0, 7.0.6.3;'#13#10 +
        'Николай С : за начальную поддержку клиента MU 1.04J. (3 сезон);'#13#10 +
        'Alexey ''Basket'' Andreev: перевод на Немецкий язык;'#13#10 +
        'Оксана Погодина (pogodinamusic.ru): перевод на Беларуский язык;'#13#10 +
        'ARSI & Small: перевод на Украинский язык;'#13#10 +
        'DarkMaster: саппорт на форуме, UOWiki, материальную поддержку;'#13#10 +
        'Zeleax: саппорт на форуме, латание багов пилота внешними самописными программами, материальную поддержку;'#13#10 +
        'Peter Below: исправил ошибку в VCL Delphi 7 на 64 битных Windows;'#13#10 +
        'Code highlighting based on SynEdit 2.0.3 - http://synedit.sourceforge.net;'#13#10 +
        'Alexandr Petrovich Sysoev : за модуль поиска по маске;'#13#10 +
        'За материальную поддержку:'#13#10 +
        'stepanian, команде L2Farm, Tomas1917, nick, veiron,Crox'#13#10 +
        'Dalamar81 : за алгоритм чтения содержимого бакпака;'#13#10 +
        'cirus : за саппорт на форуме;'#13#10 +
        'Cockney : за саппорт на форуме;'#13#10;
    { просьба о поддержке -- по языку интерфейса }
    mmDonate := TMemo.Create(gAboutForm);
    mmDonate.Parent := gAboutForm;
    mmDonate.Lines.Add('under construction');
    mmDonate.Left := 6;
    mmDonate.Top := $AA;
    mmDonate.Top := mmDonate.Top + $14;
    mmDonate.Width := $179;
    mmDonate.Height := $47;
    mmDonate.TabStop := False;
    mmDonate.Color := $FF000018;
    mmDonate.Font.Color := clRed;
    mmDonate.ReadOnly := True;
    mmDonate.Enabled := True;
    mmDonate.ScrollBars := ssNone;
    mmDonate.TabOrder := 0;
    mmDonate.Font.Height := -11;
    if (gLangOffsety = 2000) or (gLangOffsety = 0) then
      mmDonate.Lines.Text := '    UoPilot абсолютно бесплатная программа, это значит, что Вы не должны платить за ее использование.'#13#10 +
        '    Однако если Вам нравится наш проект и Вы заинтересованы в его дальнейшем развитии и регулярных обновлениях, окажите нам поддержку, отправив денежный перевод.'
    else
      mmDonate.Lines.Text := '    UoPilot is freeware, meaning you don''t have to pay to use it.'#13#10 +
        '    If You like our project, and You are interested in its further development and regular updates, support us by making a donation.';
    SetChildFontHeight(gAboutForm);
  end;
  { пока окно открыто, главная форма выключена -- окно ведёт себя как модальное }
  if gAboutForm.Visible then
  begin
    fmSecondfj.Enabled := True;
    gAboutForm.Visible := False;
  end
  else
  begin
    fmSecondfj.Enabled := False;
    gAboutForm.Enabled := False;
    gAboutForm.Visible := True;
    gAboutForm.Enabled := True;
  end;
end;

procedure TfmSecond.FormDestroy(Sender: TObject);
begin
  try
    Shell_NotifyIcon(NIM_DELETE, @gTrayIcon);
    DestroyIcon(gIconRun);
    DestroyIcon(gIconPause);
    DestroyIcon(gIconStop);
  except
  end;
end;

procedure TfmSecond.FormShow(Sender: TObject);
var
  St: Cardinal;
begin
  if miMinToTray.Checked then
  begin
    St := GetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE);
    if St and WS_EX_APPWINDOW > 0 then
      St := St - WS_EX_APPWINDOW;
    SetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE, St);
  end;
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TfmSecond.IconCallBackMessage(var Msg: TMessage);
var
  P: TPoint;
begin
  case Msg.LParam of
    WM_LBUTTONDBLCLK:
      begin
        fmSecondfj.Show;
        fmSecondfj.WindowState := wsNormal;
        SetForegroundWindow(Application.Handle);
      end;
    WM_RBUTTONDOWN:
      begin
        GetCursorPos(P);
        fmFirstfj.OnActivate := nil;
        if IsWindowEnabled(fmFirstfj.Handle) then
          SetForegroundWindow(fmFirstfj.Handle);
        Application.ProcessMessages;
        fmFirstfj.OnActivate := fmFirstfj.FormActivate;
        fmSecondfj.pmTray.Popup(P.X, P.Y);
      end;
  end;
end;

procedure TfmSecond.WndProc(var Message: TMessage);
begin
  { Переопределённый WndProc формы: три перехвата и передача всего
    остального предку. Тело целиком в try..except: любая ошибка внутри
    помечается фиктивным Tag = $48 и гасится. }
  try
    { «Сворачивать в трей»: SC_MINIMIZE не доходит до предка вовсе,
      форма просто прячется. }
    if (Message.Msg = WM_SYSCOMMAND) and (Message.WParam = SC_MINIMIZE) and
       miMinToTray.Checked then
    begin
      if fmSecondfj.Visible then
        fmSecondfj.Hide;
      Exit;
    end;
    { Активация: круговое окно поднимается поверх всех, а если «поверх лога»
      не отмечено -- возвращается под главную форму. }
    if Message.Msg = WM_ACTIVATE then
    begin
      if (gDlg5966F8c6 <> nil) and gDlg5966F8c6.Visible then
      begin
        SetWindowPos(gDlg5966F8c6.Handle, HWND_TOPMOST, 1, 1, 1, 1,
          SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
        if not miSOTLogWindow.Checked then
          SetWindowPos(gDlg5966F8c6.Handle, fmSecondfj.Handle, 1, 1, 1, 1,
            SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
      end;
      SetWindowPos(fmSecondfj.Handle, HWND_TOP, 1, 1, 1, 1,
        SWP_NOSIZE or SWP_NOMOVE);
      Exit;
    end;
    { Explorer перезапустился -- вернуть иконку в трей. }
    if Message.Msg = gTaskbarMsg then
    begin
      Shell_NotifyIcon(NIM_ADD, @gTrayIcon);
      Exit;
    end;
    inherited WndProc(Message);
  except
    fmSecondfj.Tag := $48;
  end;
end;

procedure TfmSecond.miMinToTrayClick(Sender: TObject);
begin
  MinimizeToTray;
end;

procedure TfmSecond.MinimizeToTray;
var
  S: string;
  I: Integer;
  L: Cardinal;
begin
  { Показ/снятие иконки в трее. }
  case miMinToTray.Checked of
    True:
      begin
        if gTaskbarMsg = 0 then
          gTaskbarMsg := RegisterWindowMessage('TaskbarCreated');
        gTrayIcon.cbSize := SizeOf(TNotifyIconData);
        gTrayIcon.Wnd := fmSecondfj.Handle;
        gTrayIcon.uID := fmSecondfj.Handle;
        gTrayIcon.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
        S := fmSecondfj.Caption;
        I := 0;
        while I <= Length(S) - 1 do
        begin
          gTrayIcon.szTip[I] := S[I + 1];
          Inc(I);
        end;
        gTrayIcon.hIcon := gIconRun;
        gTrayIcon.uCallbackMessage := $464;
        Shell_NotifyIcon(NIM_ADD, @gTrayIcon);
        { Снять WS_EX_APPWINDOW -- убрать кнопку с панели задач; следом тот же
          бит переключается ещё раз через xor: так окно перерисовывает свой
          стиль. }
        L := GetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE);
        if (L and WS_EX_APPWINDOW) > 0 then
          L := L - WS_EX_APPWINDOW;
        SetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE, L);
        SetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE,
          GetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE) xor WS_EX_APPWINDOW);
        ShowWindow(fmSecondfj.Handle, SW_HIDE);
        if not gNoFocusStealfq then
          ShowWindow(fmSecondfj.Handle, SW_SHOW);
        ShowWindow(Application.Handle, SW_HIDE);
      end;
    False:
      begin
        Shell_NotifyIcon(NIM_DELETE, @gTrayIcon);
        L := GetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE);
        if (L and WS_EX_APPWINDOW) <= 0 then
          L := L + WS_EX_APPWINDOW;
        SetWindowLong(fmSecondfj.Handle, GWL_EXSTYLE, L);
        fmSecondfj.Hide;
        fmSecondfj.Show;
      end;
  end;
end;

procedure TfmSecond.tScriptDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  N: Integer;
  OldColor: TColor;
  IsDesc: Boolean;
  R: TRect;
  R2: TRect;
  R3: TRect;
  W: Integer;
  C: Integer;
  Lx: Integer;
begin
  { Отрисовка вкладки скрипта: цвет надписи показывает состояние потока
    (красный -- пауза, зелёный -- работает), справа рисуется красный квадрат
    для несохранённых, слева-снизу -- полоски кнопок «пуск» и «стоп». }
  IsDesc := Control.Tag = 1;
  OldColor := Control.Canvas.Brush.Color;
  if IsDesc then
    R := tScriptDesc.TabRect(TabIndex)
  else
    R := tScript.TabRect(TabIndex);
  if Active then
  begin
    Inc(R.Bottom);
    if IsDesc then
      Control.Canvas.Font.Style := [];
  end;
  R2 := R;
  R2.Right := R2.Right - 2;
  R2.Left := R2.Left + 2;
  R2.Top := R2.Top + 2;
  Control.Canvas.FillRect(R2);
  R2 := R;
  R3 := R;
  N := StrToInt(tScript.Tabs[TabIndex]);
  if FFlag1465 and Assigned(gScriptso3[N]) then
  begin
    try
      if gScriptso3[N].Paused then
        Control.Canvas.Font.Color := $FF
      else if gScriptso3[N].Flag91 then
        Control.Canvas.Font.Color := $D629
      else
        Control.Canvas.Font.Color := $FF000008;
    except
      Control.Canvas.Font.Color := $FF000008;
    end;
  end
  else
    Control.Canvas.Font.Color := $FF000008;
  Control.Canvas.Brush.Color := $FF00000F;
  if IsDesc then
    W := Control.Canvas.TextWidth(tScriptDesc.Tabs[TabIndex])
  else
    W := Control.Canvas.TextWidth(tScript.Tabs[TabIndex]);
  C := (R.Right - R.Left) div 2 + R.Left - W div 2 - 1;
  if C > R.Left then
  begin
    Lx := C;
    R.Left := Lx;
    R.Right := Lx + W;
  end;
  if Active then
    if R.Top >= 2 then
      R.Top := R.Top - 2;
  if IsDesc then
    Control.Canvas.TextRect(R, R.Left, R.Top, tScriptDesc.Tabs[TabIndex])
  else
    Control.Canvas.TextRect(R, R.Left, R.Top, tScript.Tabs[TabIndex]);
  if Active and IsDesc then
    Control.Canvas.Font.Style := [fsBold];
  if cbShowUnsavedScripts.Checked then
    if gScriptso3[N].Modified then
    begin
      R2.Bottom := R2.Top + 6 + 1;
      R2.Left := R2.Right - 6 - 1;
      R2.Right := R2.Right - 2;
      R2.Top := R2.Top + 2;
      if Active then
        Dec(R2.Bottom);
      Control.Canvas.Brush.Color := $FF;
      Control.Canvas.FillRect(R2);
      R2 := R3;
    end;
  if IsDesc then
  begin
    R2 := R3;
    R2.Top := R2.Bottom - 2;
    Control.Canvas.Brush.Color := 0;
    Control.Canvas.FillRect(R2);
    R2 := R3;
  end;
  if FFlag1464 then
  begin
    if Active then
    begin
      Dec(R3.Bottom);
      Dec(R2.Bottom);
    end;
    R3.Top := R3.Bottom - 6;
    R3.Left := R3.Left + 2;
    R3.Right := R3.Left + 8;
    Control.Canvas.Brush.Color := $D629;
    Control.Canvas.FillRect(R3);
    R2.Top := R3.Top;
    R2.Right := R2.Right - 2;
    R2.Left := R2.Right - 8;
    Control.Canvas.Brush.Color := $D7;
    Control.Canvas.FillRect(R2);
  end;
  Control.Canvas.Brush.Color := OldColor;
end;

procedure TfmSecond.miShowRuningScriptOnTaskbarClick(Sender: TObject);
begin
  tTabRefresh.Enabled := miShowRuningScript.Checked or
    miShowRuningScriptOnTaskbar.Checked;
  if not miShowRuningScriptOnTaskbar.Checked then
    if miRenameSelf.Checked then
      fmSecondfj.Caption := eRenameSelf.Text
    else
      fmSecondfj.Caption := fmSecondfj.Hint;
end;

procedure TfmSecond.miShowRuningScriptClick(Sender: TObject);
begin
  FFlag1465 := miShowRuningScript.Checked;
  FFlag1464 := miKnopusechki_onoff.Checked;
  FFlag1466 := cbShowUnsavedScripts.Checked;
  tTabRefresh.Enabled := FFlag1465 or miShowRuningScriptOnTaskbar.Checked;
  tScript.OwnerDraw := FFlag1465 or FFlag1464 or FFlag1466;
  tScriptDesc.OwnerDraw := FFlag1465 or FFlag1464 or FFlag1466;
  if tScript.OwnerDraw then
    RedrawAllTabs;
end;

procedure TfmSecond.tTabRefreshTimer(Sender: TObject);
var
  I: Integer;
  P: Integer;
  AnyRun: Boolean;
  Redraw: Boolean;
  All: string;
  Title: string;
  Name: string;
  R: TRect;
  Tip: string[64];
  N: Integer;
  AnyPause: Boolean;
begin
  { Раз в тик обновляет вкладки скриптов, подпись в трее и заголовок формы.
    Перерисовка вкладки делается только когда флаг скрипта изменился --
    поэтому рядом с gScriptso3 живут два кэша прошлых значений. }
  { прямоугольник обнуляется по полям }
  R.Left := 0;
  R.Top := 0;
  R.Right := 0;
  R.Bottom := 0;
  AnyRun := False;
  AnyPause := False;
  Redraw := False;
  Tip := '';
  All := '';
  for I := 0 to tScript.Tabs.Count - 1 do
  begin
    N := StrToInt(tScript.Tabs[I]);
    if gScriptso3[N] <> nil then
    begin
      if tScript.OwnerDraw then
      begin
        if gScriptso3[N].Paused <> gPausedCache[N] then
        begin
          gPausedCache[N] := gScriptso3[N].Paused;
          if tScriptDesc.Visible then
            tScriptDrawTab(tScriptDesc, I, R, tScript.TabIndex = I)
          else
            tScriptDrawTab(tScript, I, R, tScript.TabIndex = I);
          Redraw := True;
        end
        else if gScriptso3[N].Flag91 <> gRunCache[N] then
        begin
          gRunCache[N] := gScriptso3[N].Flag91;
          if tScriptDesc.Visible then
            tScriptDrawTab(tScriptDesc, I, R, tScript.TabIndex = I)
          else
            tScriptDrawTab(tScript, I, R, tScript.TabIndex = I);
          Redraw := True;
        end;
      end;
      if gScriptso3[N].Flag91 then
      begin
        Title := gScriptso3[N].Title;
        P := Pos('\', Title);
        if P > 0 then
          Delete(Title, 1, P);
        P := Pos('.txt', Title);
        if P > 0 then
          Title := Copy(Title, 1, P - 1);
        if Length(Title) > 0 then
          Title := ' ' + Title;
        if Length(Tip) > 0 then
          Tip := Tip + #13;
        Name := gScriptso3[N].Name;
        if gScriptso3[N].Paused then
          Name := '(' + Name + ')';
        Tip := Tip + Name + Title;
        All := All + Name + ' ';
      end;
      AnyRun := AnyRun or (gRunCache[N] <> False);
      AnyPause := AnyPause or (gPausedCache[N] <> False);
    end;
  end;
  StrPCopy(gTrayIcon.szTip, Tip);
  if AnyRun or AnyPause then
  begin
    gTrayBlink := not gTrayBlink;
    if gTrayBlink then
      if AnyPause then
        gTrayIcon.hIcon := gIconStop
      else
        gTrayIcon.hIcon := gIconPause
    else
      gTrayIcon.hIcon := gIconRun;
    Shell_NotifyIcon(NIM_MODIFY, @gTrayIcon);
  end
  else if Redraw then
  begin
    gTrayIcon.hIcon := gIconRun;
    Shell_NotifyIcon(NIM_MODIFY, @gTrayIcon);
  end;
  if miShowRuningScriptOnTaskbar.Checked then
  begin
    if Length(All) = 0 then
      if miRenameSelf.Checked then
        All := eRenameSelf.Text
      else
        All := fmSecondfj.Hint;
    fmSecondfj.Caption := All;
  end;
  N := StrToInt(tScript.Tabs[tScript.TabIndex]);
  if gScriptso3[N] <> nil then
    sbWorkwindowHandle.Caption := IntToStr(gScriptso3[N].ClientWnd);
end;

procedure TfmSecond.mmScriptChange(Sender: TObject);
begin
end;

procedure TfmSecond.sghkScriptHKListClick(Sender: TObject);
var
  Nm: string;
  Col: Integer;
  Row: Integer;
  P: TPoint;
begin
  { Щелчок по сетке горячих клавиш. Колонки 2 и 5 -- галки «включено» и
    «пауза», колонки 3 и 4 открывают редактор клавиши для обычного и
    паузного действия, прочие колонки гасят панель назначения. }
  GetCursorPos(P);
  Windows.ScreenToClient(sghkScriptHKList.Handle, P);
  sghkScriptHKList.MouseToCell(P.X, P.Y, Col, Row);
  if (Col >= 0) and (Row >= 0) then
  begin
    sghkScriptHKList.Row := Row;
    case Col of
      2:
        begin
          if sghkScriptHKList.Cells[0, Row] = 'X' then
            sghkScriptHKList.Cells[0, Row] := ' '
          else
            sghkScriptHKList.Cells[0, Row] := 'X';
          gHKSela := 0;
          cbhk1Click(Sender);
        end;
      5:
        begin
          if sghkScriptHKList.Cells[5, Row] = 'X' then
            sghkScriptHKList.Cells[5, Row] := ' '
          else
            sghkScriptHKList.Cells[5, Row] := 'X';
          gHKSela := 5;
          cbhk1Click(Sender);
        end;
      3:
        begin
          gHotKeyTag := sghkScriptHKList.Tag + sghkScriptHKList.Row;
          Nm := sghkScriptHKList.Name + '_' +
            sghkScriptHKList.Cells[1, sghkScriptHKList.Row];
          fld_14E0 := Integer(Sender);
          Delete(Nm, 1, 2);
          gHKMode := 3;
          gHKSela := 0;
          gHKScript := StrToInt(sghkScriptHKList.Cells[1,
            sghkScriptHKList.Row]);
          EditHotKey(Nm);
        end;
      4:
        begin
          gHotKeyTag := sghkScriptHKList.Tag + sghkScriptHKList.Row;
          Nm := sghkScriptHKList.Name + '_Pause_' +
            sghkScriptHKList.Cells[1, sghkScriptHKList.Row];
          fld_14E0 := Integer(Sender);
          Delete(Nm, 1, 2);
          gHKMode := 4;
          gHKSela := 5;
          EditHotKey(Nm);
        end;
    else
      { Клик мимо рабочих колонок -- панель назначения клавиши сбрасывается }
      cbHKList.ItemIndex := -1;
      cbShift.Checked := False;
      cbAlt.Checked := False;
      cbCtrl.Checked := False;
      gHKItem := -1;
      sbApply.Enabled := False;
    end;
    sghkScriptHKList.Repaint;
  end;
end;

procedure DrawGridCellText(Grid: TStringGrid; Cv: TCanvas;
      const R: TRect; const S: string; W: Word; B: ShortInt; C: ShortInt);
var
  Buf: array[0..255] of Char;
begin
  { Метки 2 и 1 стоят в этом порядке нарочно: W = 1 -- центр,
    W = 2 -- правый край. }
  case W of
    0: ExtTextOut(Cv.Handle, R.Left + B, R.Top + C, 6, @R,
         StrPCopy(Buf, S), Length(S), nil);
    2: ExtTextOut(Cv.Handle, R.Right - Cv.TextWidth(S) - 3, R.Top + C, 6, @R,
         StrPCopy(Buf, S), Length(S), nil);
    1: ExtTextOut(Cv.Handle, R.Left + (R.Right - R.Left - Cv.TextWidth(S)) div 2,
         R.Top + C, 6, @R, StrPCopy(Buf, S), Length(S), nil);
  end;
end;

procedure TfmSecond.sghkScriptHKListDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  W: Word;
  B: Byte;
  C: Byte;
  X: Integer;
begin
  { Раскраска ячейки списка горячих клавиш. Колонки переставлены: 0->1,
    1->2, 2->0, остальные как есть; W -- выравнивание, B/C -- цвета.
    Жирный шрифт ставится для колонок 0 и 5, они же теряют выравнивание. }
  W := 1;
  B := 2;
  C := 2;
  case ACol of
    0: X := 1;
    1: X := 2;
    2: X := 0;
  else
    X := ACol;
  end;
  case X of
    0:
      begin
        W := 0;
        sghkScriptHKList.Canvas.Font.Style := [fsBold];
        B := 1;
      end;
    5:
      begin
        W := 0;
        sghkScriptHKList.Canvas.Font.Style := [fsBold];
      end;
    2:
      W := 0;
  end;
  DrawGridCellText(sghkScriptHKList, sghkScriptHKList.Canvas, Rect,
    sghkScriptHKList.Cells[X, ARow], W, B, C);
end;

procedure TfmSecond.HotKeyScriptList(Sender: TObject);
var
  S: string;
  J: Integer;
  Pid: DWORD;
  N: Integer;
  I: Integer;
  H: HWND;
  B: Boolean;
  gSZ: TScriptArrayS absolute gScriptso3;
begin
  gObjA38.Enter;
  S := (Sender as THotKeyItem).Name;
  Delete(S, 1, Pos('_', S));
  I := StrToInt(S);
  if gScriptso3[I] = nil then
  begin
    if gLangOffsety > 0 then
      gScriptso3[I].Msg := LoadStr(gLangOffsety + $1D9)
    else
      gScriptso3[I].Msg := 'System error: script not created.';
    ShowScriptMsg(TScanThread(gScriptso3[I]));
    Exit;
  end;
  if gScriptso3[I].Paused then
    B := True
  else
    B := not gScriptso3[I].Flag91;
  case B of
    False:
      begin
        gScriptso3[I].StopRequested := True;
        gScriptso3[I].Flag91 := False;
        if gScriptso3[I].Paused then
        begin
          gScriptso3[I].Paused := False;
          gScriptso3[I].Resume;
        end;
        if gSZ[I].AutoStart then
        begin
          gSZ[I].StopScriptThread;
          edScript.Enabled := True;
          edScript.ReadOnly := False;
        end;
      end;
    True:
      begin
        if gScriptso3[I].StopRequested then
          gScriptso3[I].StopRequested := False;
        if gScriptso3[I].AutoStart then
        begin
          SetLength(gScriptso3[I].Lines, edScript.Lines.Count);
          for J := 0 to edScript.Lines.Count - 1 do
            gScriptso3[I].Lines[J] := edScript.Lines[J];
          if Length(gScriptso3[I].Lines) = 0 then
          begin
            gSZ[I].StopScriptThread;
            Exit;
          end;
          gScriptso3[I].PauseCmd := edPause.Text;
          gScript.MaxValue := Length(gScriptso3[I].Lines);
        end;
        if gScriptso3[I].Paused then
        begin
          gScriptso3[I].Paused := False;
          gScriptso3[I].Resume;
          if gScriptso3[I].AutoStart then
            sbPause.Down := False;
        end
        else
        begin
          if gScriptso3[I].AutoStart then
            sgVar.RowCount := 1;
        end;
        if not gScriptso3[I].Flag91 then
        begin
          if gScriptso3[I].ClientWnd = 0 then
          begin
            gScriptso3[I].ClientWnd := FindWindow('Ultima Online', nil);
            GetWindowThreadProcessId(gScriptso3[I].ClientWnd, @Pid);
            gScriptso3[I].ProcessId := Pid;
            if gScriptso3[I].ProcessHandle <> 0 then
              FileClose(gScriptso3[I].ProcessHandle); { *Преобразовано из CloseHandle* }
            gScriptso3[I].ProcessHandle := OpenProcess($638, True, Pid);
          end;
          gScriptso3[I].Flag91 := True;
          StartScriptThread(gScriptso3[I]);
          gScriptso3[I].Resume;
        end;
        if gSZ[I].AutoStart then
        begin
          gSZ[I].AfterScriptStarted;
          edScript.Enabled := False;
          edScript.ReadOnly := True;
        end;
      end;
  end;
  gObjA38.Leave;
end;

procedure TfmSecond.sbStayClick(Sender: TObject);
var
  S: string;
begin
  S := '';
  if cbPref.Checked then
    S := ePref.Text + ' ';
  S := S + (Sender as TSpeedButton).Caption;
  if cbSuff.Checked then
    S := S + ' ' + eSuff.Text;
  InsertScriptCommand(S);
end;

procedure TfmSecond.sbAnimalControlClick(Sender: TObject);
begin
  if gDlg5966F4 = nil then
  begin
    gDlg5966F4 := TForm.Create(fmSecondfj);
    gDlg5966F4.Parent := nil;
    gDlg5966F4.Font := fmSecondfj.Font;
    gDlg5966F4.BorderStyle := bsToolWindow;
    if miSOTAnimalVendor.Checked then
      gDlg5966F4.FormStyle := fsStayOnTop
    else
      gDlg5966F4.FormStyle := fsNormal;
    gDlg5966F4.ClientHeight := gbAnimalControl.Height + 2;
    gDlg5966F4.ClientWidth := gbAnimalControl.Width + 4 + 4;
    if gLangOffsety > 0 then
      gDlg5966F4.Caption := LoadStr(gLangOffsety + $1DA)
    else
      gDlg5966F4.Caption := 'Animal & Vendor Control';
    if (gWinPos[10] <> -1) and (gWinPos[11] <> -1) and miSPosAC.Checked then
    begin
      gDlg5966F4.Top := gWinPos[10];
      gDlg5966F4.Left := gWinPos[11];
    end
    else
    begin
      gDlg5966F4.Top := Top;
      if Assigned(gDlg5966E4) then
        gDlg5966F4.Top := gDlg5966F4.Top + gDlg5966E4.Height;
      if Assigned(gDlg5966E8) then
        gDlg5966F4.Top := gDlg5966F4.Top + gDlg5966E8.Height;
      gDlg5966F4.Left := Left + Width;
      if (gDlg5966F4.Left + gDlg5966F4.Width) > Screen.DesktopWidth then
        gDlg5966F4.Left := Left - gDlg5966F4.Width;
    end;
    gDlg5966F4.OnCloseQuery := AnimalControlClose;
    gbAnimalControl.Parent := gDlg5966F4;
    gbAnimalControl.Visible := True;
    gbAnimalControl.Top := 0;
    gbAnimalControl.Left := 4;
  end;
  if gDlg5966F4.Visible then
  begin
    gDlg5966F4.Visible := False;
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end
  else
  begin
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
    gDlg5966F4.Visible := True;
  end;
  sbAnimalControl.Down := gDlg5966F4.Visible;
end;

procedure TfmSecond.sgVarSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if (ACol <> 1) or (ARow < 1) then
    CanSelect := False;
end;

procedure TfmSecond.sgVarDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  if sgVar.RowCount <= 1 then
    sgVar.Options := sgVar.Options - [goEditing]
  else
    sgVar.Options := sgVar.Options + [goEditing];
  sgVar.Col := 1;
end;

procedure TfmSecond.sgVarSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: string);
var
  S: string;
  T1: string;
  T2: string;
  T3: string;
  N: Integer;
  I: Integer;
begin
  { Правка значения переменной или таймера прямо в таблице. Имя переменной
    начинается с '#', имя таймера -- с любого другого символа; первый символ
    в обоих случаях отбрасывается. }
  if Value <> '' then
  begin
    try
      N := StrToInt(tScript.Tabs[tScript.TabIndex]);
      S := sgVar.Cells[0, ARow];
      if S[1] = '#' then
      begin
        Delete(S, 1, 1);
        I := 0;
        while I < Length(gScriptso3[N].Vars) do
        begin
          if gScriptso3[N].Vars[I].Name = S then
            Break;
          Inc(I);
        end;
        if I < Length(gScriptso3[N].Vars) then
          gScriptso3[N].Vars[I].Value := StrToInt64Def(Value, 0);
      end
      else
      begin
        Delete(S, 1, 1);
        I := 0;
        while I < Length(gScriptso3[N].Timers) do
        begin
          if gScriptso3[N].Timers[I].Name = S then
            Break;
          Inc(I);
        end;
        if I < Length(gScriptso3[N].Timers) then
          gScriptso3[N].Timers[I].Value := Value;
      end;
    except
    end;
  end;
end;

procedure TfmSecond.HotKeyLockAllScroptToUO(Sender: TObject);
var
  P: TPoint;
  W: HWND;
  I: Cardinal;
  Pid: DWORD;
  N: Integer;
  S: string;
  T: string;
begin
  { Привязывает ВСЕ открытые скрипты к одному окну клиента: каждому кладётся
    хэндл окна, идентификатор процесса и свежий OpenProcess. }
  GetCursorPos(P);
  W := WindowFromPoint(P);
  if W = 0 then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $19B)), 'UOPilot Error Message', 0)
    else
      MsgBox('Не могу найти рабочее окно', 'UOPilot Error Message', 0);
  end
  else
  begin
    GetWindowThreadProcessId(W, @Pid);
    FTargetWnd := W;
    if FClientProcess <> 0 then
      FileClose(FClientProcess); { *Преобразовано из CloseHandle* }
    FClientProcess := OpenProcess($638, False, Pid);
    for I := 0 to tScript.Tabs.Count - 1 do
    begin
      N := StrToInt(tScript.Tabs[I]);
      gScriptso3[N].ClientWnd := W;
      gScriptso3[N].ProcessId := Pid;
      if gScriptso3[N].ProcessHandle <> 0 then
        FileClose(gScriptso3[N].ProcessHandle); { *Преобразовано из CloseHandle* }
      gScriptso3[N].ProcessHandle := OpenProcess($638, True, Pid);
    end;
  end;
end;

procedure TfmSecond.HotKeyClipboardConsoleText(Sender: TObject);
var
  S: string;
  N: DWORD;
  Pid: DWORD;
  Addr: Cardinal;
  Ph: THandle;
  Buf: array[0..$203] of Byte;
  W: HWND;
  P: PChar;
begin
  { Забирает текст консоли прямо из памяти клиента: по адресу из таблицы
    лежит указатель, а по нему -- Pascal-строка (длина в первом байте,
    сами символы со смещения 4). }
  W := FindWindow('Ultima Online', nil);
  GetWindowThreadProcessId(W, @Pid);
  Ph := OpenProcess($638, False, Pid);
  Addr := ClientAddr2[3, cbClVer.ItemIndex];
  if Ph <> 0 then
  begin
    try
      ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, N);
      ReadProcessMemory(Ph, Pointer(Addr + 8), @Buf, $204, N);
      P := PChar(@Buf[4]);
  S := WideCharToString(PWideChar(P));
      S := Copy(S, 1, Buf[0]);
    except
      if gLangOffsety > 0 then
        S := LoadStr(gLangOffsety + $1DB)
      else
        S := 'Error reading memory';
    end;
    SetClipboardText(Clipboard, S);
  end;
  FileClose(Ph); { *Преобразовано из CloseHandle* }
end;

procedure TfmSecond.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WndParent := GetDesktopWindow;
  Params.ExStyle := Params.ExStyle or $10;
end;

procedure TfmSecond.ApplyLanguage(Code: Integer);
begin
  gbAnimalControl.Caption := LoadStr(Code + $1);
  cbPref.Hint := LoadStr(Code + $2);
  cbSuff.Hint := LoadStr(Code + $3);
  ePref.Hint := LoadStr(Code + $4);
  eSuff.Hint := LoadStr(Code + $5);
  tsGeneral.Caption := LoadStr(Code + $6);
  gbC.Caption := LoadStr(Code + $7);
  btS1.Caption := LoadStr(Code + $8);
  btS2.Caption := LoadStr(Code + $9);
  btS3.Caption := LoadStr(Code + $A);
  btS0.Hint := LoadStr(Code + $B);
  ed0.Hint := LoadStr(Code + $C);
  ed1.Hint := LoadStr(Code + $D);
  ed2.Hint := LoadStr(Code + $E);
  ed3.Hint := LoadStr(Code + $F);
  ec0.Hint := LoadStr(Code + $15E);
  ec1.Hint := LoadStr(Code + $15E);
  ec2.Hint := LoadStr(Code + $15E);
  ec3.Hint := LoadStr(Code + $15E);
  ec4.Hint := LoadStr(Code + $15E);
  ec5.Hint := LoadStr(Code + $15E);
  cb0.Items.Clear;
  cb0.Items.Add(LoadStr(Code + $13C));
  cb0.Items.Add(LoadStr(Code + $13D));
  cb0.Items.Add(LoadStr(Code + $13E));
  cb0.Items.Add(LoadStr(Code + $13F));
  cbS1.Hint := LoadStr(Code + $11);
  cbS2.Hint := LoadStr(Code + $12);
  cbS3.Hint := LoadStr(Code + $13);
  gbOtherWindow.Caption := LoadStr(Code + $14);
  btS4.Caption := LoadStr(Code + $15);
  btS5.Caption := LoadStr(Code + $16);
  ed4.Hint := LoadStr(Code + $17);
  ed5.Hint := LoadStr(Code + $18);
  cbS4.Hint := LoadStr(Code + $19);
  cbS5.Hint := LoadStr(Code + $1A);
  gbScreenShot.Caption := LoadStr(Code + $1B);
  cbDate.Hint := LoadStr(Code + $1C);
  cbDate.Caption := LoadStr(Code + $1D);
  rbBmp.Hint := LoadStr(Code + $1E);
  rbJpg.Hint := LoadStr(Code + $1F);
  edScr.Hint := LoadStr(Code + $20);
  SpinEdit1.Hint := LoadStr(Code + $21);
  tsScript.Caption := LoadStr(Code + $22);
  tsScript.Hint := tsScript.Caption;
  btAddM.Hint := LoadStr(Code + $23);
  Label4.Caption := LoadStr(Code + $24);
  btXY.Hint := LoadStr(Code + $25);
  btColor.Hint := LoadStr(Code + $26);
  sbDefineColor.Hint := LoadStr(Code + $28);
  btXYabs.Hint := LoadStr(Code + $29);
  cbM.Hint := LoadStr(Code + $2A);
  cbInsertXY.Hint := LoadStr(Code + $2B);
  CBInsertColor.Hint := LoadStr(Code + $2C);
  edPause.Hint := LoadStr(Code + $2D);
  cbDebug.Hint := LoadStr(Code + $2E);
  cbInsertXYabs.Hint := LoadStr(Code + $2F);
  edScript.Hint := LoadStr(Code + $30);
  tsOther.Caption := LoadStr(Code + $31);
  GroupBox3.Caption := LoadStr(Code + $32);
  SEMinutes.Hint := LoadStr(Code + $33);
  SEHour.Hint := LoadStr(Code + $34);
  cbScript.Hint := LoadStr(Code + $35);
  cbScript.Caption := LoadStr(Code + $36);
  gbMove.Hint := LoadStr(Code + $37);
  gbMove.Caption := LoadStr(Code + $38);
  Label16.Caption := LoadStr(Code + $39);
  Edit1.Hint := LoadStr(Code + $3A);
  cbMoveLeftCl.Hint := LoadStr(Code + $3B);
  cbMoveLeftCl.Caption := LoadStr(Code + $3C);
  seAmove1.Hint := LoadStr(Code + $3D);
  seAmove2.Hint := LoadStr(Code + $3E);
  seAmove3.Hint := LoadStr(Code + $3F);
  cbStoD1.Hint := LoadStr(Code + $40);
  cbStoD2.Hint := LoadStr(Code + $41);
  cbStoD3.Hint := LoadStr(Code + $42);
  gbGM.Caption := LoadStr(Code + $43);
  sbGMPage.Hint := LoadStr(Code + $44);
  cbGMPage.Hint := LoadStr(Code + $45);
  cbGMPage.Caption := LoadStr(Code + $46);
  cbGMPageAlarm.Hint := LoadStr(Code + $47);
  cbGMPageAlarm.Caption := LoadStr(Code + $48);
  gbStartLoginUO.Caption := LoadStr(Code + $49);
  sbLoginUO.Hint := LoadStr(Code + $4A);
  cbSUOMin.Hint := LoadStr(Code + $4B);
  tsStart.Caption := LoadStr(Code + $4C);
  sbMacros.Hint := LoadStr(Code + $4D);
  sbSControl.Hint := LoadStr(Code + $4E);
  sbHouseControl.Hint := LoadStr(Code + $4F);
  sbEditHK.Hint := LoadStr(Code + $50);
  sbCharParams.Hint := LoadStr(Code + $51);
  Label6.Caption := LoadStr(Code + $52);
  Label7.Caption := LoadStr(Code + $53);
  sbAnimalControl.Hint := LoadStr(Code + $55);
  Label11.Caption := LoadStr(Code + $56);
  cbEnableHK.Hint := LoadStr(Code + $57);
  cbEnableHK.Caption := LoadStr(Code + $58);
  eScriptDelayDef.Hint := LoadStr(Code + $59);
  eBudilnikDelay.Hint := LoadStr(Code + $5A);
  edPauseNil.Hint := LoadStr(Code + $5B);
  gbShipControl.Caption := LoadStr(Code + $5C);
  sbMfHS.Hint := LoadStr(Code + $5D);
  gbHouseControl.Caption := LoadStr(Code + $5E);
  gbHouseControl.Hint := LoadStr(Code + $5F);
  sbMfHH.Hint := LoadStr(Code + $60);
  SpeedButton1.Caption := LoadStr(Code + $61);
  SpeedButton2.Caption := LoadStr(Code + $62);
  pCPchekbokses.Hint := LoadStr(Code + $63);
  sgVar.Hint := LoadStr(Code + $64);
  sbLOAdd.Caption := LoadStr(Code + $65);
  sbLODel.Caption := LoadStr(Code + $66);
  Label25.Caption := LoadStr(Code + $67);
  sbLTDel.Caption := LoadStr(Code + $68);
  sbLTAdd.Caption := LoadStr(Code + $69);
  Label24.Caption := LoadStr(Code + $6A);
  sbCPhide.Hint := LoadStr(Code + $6B);
  cbDrinkTimer.Hint := LoadStr(Code + $6C);
  cbDrinkTimer.Caption := LoadStr(Code + $6D);
  SpinEdit2.Hint := LoadStr(Code + $6E);
  gbHotKeyList.Caption := LoadStr(Code + $6F);
  cbhkScr.Hint := LoadStr(Code + $70);
  cbhkScr.Caption := LoadStr(Code + $71);
  cbhkSScript.Hint := LoadStr(Code + $72);
  cbhkSScript.Caption := LoadStr(Code + $73);
  cbhkRec.Hint := LoadStr(Code + $74);
  cbhkRec.Caption := LoadStr(Code + $75);
  cbhkRecStop.Hint := LoadStr(Code + $76);
  cbhkRecStop.Caption := LoadStr(Code + $77);
  cbhkPlay.Hint := LoadStr(Code + $78);
  cbhkPlay.Caption := LoadStr(Code + $79);
  cbhkSNames.Hint := LoadStr(Code + $7A);
  cbhkSNames.Caption := LoadStr(Code + $7B);
  cbhkTransp.Caption := LoadStr(Code + $C6);
  cbhkTransp.Hint := LoadStr(Code + $154);
  cbhkPathF.Caption := LoadStr(Code + $C7);
  cbhkPathF.Hint := LoadStr(Code + $156);
  cbhkCrimAct.Caption := LoadStr(Code + $C8);
  cbhkCrimAct.Hint := LoadStr(Code + $158);
  cbhkARun.Caption := LoadStr(Code + $15B);
  cbhkARun.Hint := LoadStr(Code + $15A);
  cbhkMove_1.Hint := LoadStr(Code + $7C);
  cbhkMove_1.Caption := LoadStr(Code + $7D);
  cbhk1.Hint := LoadStr(Code + $7E);
  cbhk1.Caption := LoadStr(Code + $7F);
  cbhk2.Hint := LoadStr(Code + $80);
  cbhk2.Caption := LoadStr(Code + $81);
  cbhk3.Hint := LoadStr(Code + $82);
  cbhk3.Caption := LoadStr(Code + $83);
  cbhk4.Hint := LoadStr(Code + $84);
  cbhk4.Caption := LoadStr(Code + $85);
  cbhk5.Hint := LoadStr(Code + $86);
  cbhk5.Caption := LoadStr(Code + $87);
  cbhkMes.Hint := LoadStr(Code + $88);
  cbhkMes.Caption := LoadStr(Code + $89);
  cbhkUopUO.Hint := LoadStr(Code + $8A);
  cbhkUopUO.Caption := LoadStr(Code + $8B);
  cbhkMove_2.Hint := LoadStr(Code + $8C);
  cbhkMove_2.Caption := LoadStr(Code + $8D);
  cbhkMove_3.Hint := LoadStr(Code + $8E);
  cbhkMove_3.Caption := LoadStr(Code + $8F);
  cbhkPScript.Hint := LoadStr(Code + $90);
  cbhkPScript.Caption := LoadStr(Code + $91);
  cbhkSetMove_3.Hint := LoadStr(Code + $92);
  cbhkSetMove_3.Caption := LoadStr(Code + $93);
  cbhkSetMove_2.Hint := LoadStr(Code + $94);
  cbhkSetMove_2.Caption := LoadStr(Code + $95);
  cbhkSetMove_1.Hint := LoadStr(Code + $96);
  cbhkSetMove_1.Caption := LoadStr(Code + $97);
  cbhkCharParams.Hint := LoadStr(Code + $98);
  cbhkCharParams.Caption := LoadStr(Code + $99);
  sghkScriptHKList.Hint := LoadStr(Code + $9A);
  cbhkLockAllScriptToUO.Hint := LoadStr(Code + $9B);
  cbhkLockAllScriptToUO.Caption := LoadStr(Code + $9C);
  cbhkClipboardConsoleText.Hint := LoadStr(Code + $9D);
  cbhkClipboardConsoleText.Caption := LoadStr(Code + $9E);
  odLoad.Filter := LoadStr(Code + $9F);
  sdSave.Filter := LoadStr(Code + $A0);
  miCopyLM.Caption := LoadStr(Code + $A1);
  ddd1.Caption := LoadStr(Code + $A2);
  miNew.Caption := LoadStr(Code + $A3);
  miOpen.Caption := LoadStr(Code + $A4);
  miReOpen.Caption := LoadStr(Code + $A5);
  miProcOpen.Caption := LoadStr(Code + $A6);
  miSave.Caption := LoadStr(Code + $A7);
  miSaveAs.Caption := LoadStr(Code + $A8);
  miExit.Caption := LoadStr(Code + $A9);
  miExitWoSave.Caption := LoadStr(Code + $AA);
  nxxx.Caption := LoadStr(Code + $AB);
  miSpeed.Caption := LoadStr(Code + $AB);
  miLMkeymouse.Caption := LoadStr(Code + $AC);
  miSMkeymouse.Caption := LoadStr(Code + $AD);
  miRec.Caption := LoadStr(Code + $AE);
  miStopRec.Caption := LoadStr(Code + $AF);
  miPlay.Caption := LoadStr(Code + $B0);
  lmSpeed.Caption := LoadStr(Code + $B1);
  lmRepeat.Caption := LoadStr(Code + $B2);
  lmRepeatC.Caption := LoadStr(Code + $B3);
  lmRepeatC.Caption := Copy(lmRepeatC.Caption, 2, $FF);
  N20.Caption := LoadStr(Code + $B7);
  N8.Caption := LoadStr(Code + $B8);
  miAddSp.Caption := LoadStr(Code + $B9);
  miShowScriptProcessing.Caption := LoadStr(Code + $BA);
  miShowSFNames.Caption := LoadStr(Code + $BB);
  miShowRuningScript.Caption := LoadStr(Code + $BC);
  miLockOnStartup.Caption := LoadStr(Code + $BD);
  miMoveMouseBack.Caption := LoadStr(Code + $BE);
  miAMoveCount.Caption := LoadStr(Code + $BF);
  miShowCoords.Caption := LoadStr(Code + $C0);
  miSKRel.Caption := LoadStr(Code + $C1);
  miSKAbs.Caption := LoadStr(Code + $C2);
  N01.Caption := LoadStr(Code + $C3);
  cbName.Caption := LoadStr(Code + $C4);
  cbName.Hint := LoadStr(Code + $C5);
  cbTrans.Caption := LoadStr(Code + $C6);
  cbPathF.Caption := LoadStr(Code + $C7);
  cbCrim.Caption := LoadStr(Code + $C8);
  cbRun.Caption := LoadStr(Code + $15B);
  miStopSUncC.Caption := LoadStr(Code + $CB);
  miPauseSOnClientClose.Caption := LoadStr(Code + $CC);
  miErrorReadCP.Caption := LoadStr(Code + $CD);
  miStopSErrorRead.Caption := LoadStr(Code + $CE);
  miPauseSErrorRead.Caption := LoadStr(Code + $CF);
  miInformErrorRead.Caption := LoadStr(Code + $D0);
  miMinToTray.Caption := LoadStr(Code + $D2);
  N11.Caption := LoadStr(Code + $D3);
  cbSOT.Caption := LoadStr(Code + $D4);
  miSOTShipControl.Caption := LoadStr(Code + $D5);
  miSOTHouseControl.Caption := LoadStr(Code + $D6);
  miSOTAnimalVendor.Caption := LoadStr(Code + $D7);
  miSOTCharParameters.Caption := LoadStr(Code + $D8);
  miSOTScriptWindow.Caption := LoadStr(Code + $D9);
  N22.Caption := LoadStr(Code + $DA);
  miSPosUoP.Caption := LoadStr(Code + $DB);
  miSPosS.Caption := LoadStr(Code + $DC);
  miSPosCP.Caption := LoadStr(Code + $DD);
  miSPosHC.Caption := LoadStr(Code + $DE);
  miSPosSC.Caption := LoadStr(Code + $DF);
  miSPosAC.Caption := LoadStr(Code + $E0);
  N23.Caption := LoadStr(Code + $E1);
  miAutoOpenCP.Caption := LoadStr(Code + $E2);
  miShowCharParams.Caption := LoadStr(Code + $E4);
  miSCPscript.Caption := LoadStr(Code + $E5);
  miSCPtopuo.Caption := LoadStr(Code + $E6);
  miSCPuop.Caption := LoadStr(Code + $E7);
  miShowHex.Caption := LoadStr(Code + $E8);
  miScriptFontSelect.Caption := LoadStr(Code + $E9);
  SelectUOserver1.Caption := LoadStr(Code + $EA);
  miSaveOptions.Caption := LoadStr(Code + $EB);
  miSaveMacros.Caption := LoadStr(Code + $EC);
  miSaveOnExit.Caption := LoadStr(Code + $ED);
  mmHelp.Caption := LoadStr(Code + $EE);
  miAbout.Caption := LoadStr(Code + $EF);
  miCut.Caption := LoadStr(Code + $F0);
  miCopy.Caption := LoadStr(Code + $F1);
  miPaste.Caption := LoadStr(Code + $F2);
  miUndo.Caption := LoadStr(Code + $F3);
  miVariables.Caption := LoadStr(Code + $F5);
  mi1.Caption := LoadStr(Code + $F6);
  mi2.Caption := LoadStr(Code + $F7);
  mi3.Caption := LoadStr(Code + $F8);
  miM.Caption := 'send' + LoadStr(Code + $FA);
  miPost.Caption := 'post' + LoadStr(Code + $FA);
  miMex.Caption := LoadStr(Code + $FB);
  miSet.Caption := LoadStr(Code + $FC);
  miW.Caption := LoadStr(Code + $FD);
  miWaitfortarget.Caption := LoadStr(Code + $FE);
  miMouses.Caption := LoadStr(Code + $FF);
  miMove.Caption := LoadStr(Code + $108);
  miDrag.Caption := LoadStr(Code + $109);
  miRepits.Caption := LoadStr(Code + $10A);
  miBreak.Caption := LoadStr(Code + $10B);
  miRt.Caption := LoadStr(Code + $10C);
  miFor.Caption := LoadStr(Code + $10D);
  miWhile.Caption := LoadStr(Code + $10E);
  miWhileP.Caption := LoadStr(Code + $10F);
  miWhileL.Caption := LoadStr(Code + $110);
  miIfs.Caption := LoadStr(Code + $111);
  miIF.Caption := LoadStr(Code + $112);
  miiIFp.Caption := LoadStr(Code + $113);
  miIfLastmsg.Caption := LoadStr(Code + $114);
  miProcs.Caption := LoadStr(Code + $115);
  miCall.Caption := LoadStr(Code + $116);
  miProc.Caption := LoadStr(Code + $117);
  miGosub.Caption := LoadStr(Code + $118);
  miMLoad.Caption := LoadStr(Code + $119);
  miMacroload.Caption := LoadStr(Code + $11A);
  miMacroplay.Caption := LoadStr(Code + $11B);
  miScripts.Caption := LoadStr(Code + $11C);
  miStartScript.Caption := LoadStr(Code + $11D);
  miStopScript.Caption := LoadStr(Code + $11E);
  miPauseScript.Caption := LoadStr(Code + $11F);
  miResumeScript.Caption := LoadStr(Code + $120);
  miPrograms.Caption := LoadStr(Code + $121);
  miExec.Caption := 'exec' + LoadStr(Code + $122);
  miTerminate.Caption := LoadStr(Code + $123);
  miInjection.Caption := LoadStr(Code + $124);
  miGoto.Caption := LoadStr(Code + $125);
  miSay.Caption := LoadStr(Code + $126);
  miMsg.Caption := LoadStr(Code + $127);
  miAlarm.Caption := LoadStr(Code + $128);
  miFlash.Caption := LoadStr(Code + $129);
  miLoadLO.Caption := LoadStr(Code + $12A);
  miSaveLO.Caption := LoadStr(Code + $12B);
  miClesrLO.Caption := LoadStr(Code + $12C);
  bRemove.Hint := LoadStr(Code + $12D);
  bAdd.Hint := LoadStr(Code + $12E);
  sgLoginLine.Hint := LoadStr(Code + $12F);
  N27.Caption := LoadStr(Code + $C9);
  miSaveScrActiweWindow.Caption := LoadStr(Code + $131);
  miSaveScrWorkWindow.Caption := LoadStr(Code + $132);
  miSaveScrAllScreen.Caption := LoadStr(Code + $133);
  miScriptHelp.Caption := LoadStr(Code + $1A7) + ', ' + LoadStr(Code + $EE);
  r1.Caption := LoadStr(Code + $1A7);
  miShowTimerVar.Caption := LoadStr(Code + $141);
  miSortSkillList.Caption := LoadStr(Code + $142);
  tbUOPriorityChange(Self);
  Edit2.Hint := LoadStr(Code + $14F);
  sgVar.Cells[0, 0] := LoadStr(Code + $199);
  sgVar.Cells[1, 0] := LoadStr(Code + $19A);
  StartUOOnly.Hint := LoadStr(Code + $150);
  miPauseCurrentScript.Caption := LoadStr(Code + $15F);
  miPauseAllScript.Caption := LoadStr(Code + $160);
  Label9.Caption := LoadStr(Code + $161);
  seMouseClicksDelay.Hint := LoadStr(Code + $162);
  miShowAllWindows.Caption := LoadStr(Code + $163);
  Label15.Caption := LoadStr(Code + $164);
  seSendExDelayDef.Hint := LoadStr(Code + $165);
  Label17.Caption := LoadStr(Code + $167);
  miFunctions.Caption := LoadStr(Code + $16D);
  miKnopusechki_onoff.Caption := LoadStr(Code + $177);
  miRenameSelf.Caption := LoadStr(Code + $178);
  miMoveMouseBeforeClick.Caption := LoadStr(Code + $179);
  miLogging.Caption := LoadStr(Code + $17A);
  miKeys.Caption := LoadStr(Code + $17B);
  cbhkStopAllScript.Hint := LoadStr(Code + $17C);
  cbhkSetWorkWindow.Hint := LoadStr(Code + $17D);
  miPluginSample.Caption := LoadStr(Code + $17E);
  micoco.Caption := LoadStr(Code + $17F);
  miLogFontSelect.Caption := LoadStr(Code + $180);
  miTransparentHotKeys.Caption := LoadStr(Code + $181);
  miGutterVisible.Caption := LoadStr(Code + $182);
  miArrays.Caption := LoadStr(Code + $183);
  miSaveScriptsOnExit.Caption := LoadStr(Code + $184);
  miShowHelpOnTaskbar.Caption := LoadStr(Code + $185);
  miErrorLogging.Caption := LoadStr(Code + $186);
  miELclrinvalid.Caption := LoadStr(Code + $187);
  cbhkPauseAllScript.Hint := LoadStr(Code + $1E0);
  miShowRemainingWait.Caption := LoadStr(Code + $1E1);
  miStrings.Caption := LoadStr(Code + $1E2);
  miDisplayMessages.Caption := LoadStr(Code + $1E3);
  miTabRemove.Caption := LoadStr(Code + $1E5);
  miTabClear.Caption := LoadStr(Code + $12C);
  miTabRename.Caption := LoadStr(Code + $1E7);
  miTabClose.Caption := LoadStr(Code + $1E6);
  miSaveScriptTemplate.Caption := LoadStr(Code + $1E8);
  miFileOpError.Caption := LoadStr(Code + $1EA);
  miExecAndWait.Caption := 'ExecAndWait' + LoadStr(Code + $122);
  misend217.Caption := 'send217' + LoadStr(Code + $FA);
  miAutoOpenLog.Caption := LoadStr(Code + $1EB);
  gbOutputMessagesTo.Caption := LoadStr(Code + $1EC);
  miShowRuningScriptOnTaskbar.Caption := LoadStr(Code + $BC) + ' ' + LoadStr(Code + $1ED);
  miNumbers.Caption := LoadStr(Code + $1EE);
  miOptions.Caption := LoadStr(Code + $B8);
  miStartMinimized.Caption := LoadStr(Code + $1F0);
  miStartStopCurrentScript.Caption := LoadStr(Code + $1F1);
  miSaveScriptsOnRun.Caption := LoadStr(Code + $1F3);
  miShowCommandHint.Caption := LoadStr(Code + $1F4);
  miSetHKError.Caption := LoadStr(Code + $1F5);
  miUseKleft217.Caption := LoadStr(Code + $1F6);
  sbScriptProcessing.Caption := LoadStr(Code + $1F7);
  sbScriptProcessing.Hint := LoadStr(Code + $1F8);
  Label5.Caption := LoadStr(Code + $1F9);
  Label3.Caption := LoadStr(Code + $1FA);
  miPluginLoadError.Caption := LoadStr(Code + $1FB);
  cbShowUnsavedScripts.Caption := LoadStr(Code + $1FC);
  cbShowScriptNamesOnTabs.Caption := LoadStr(Code + $1FD);
  cbHideUOSettings.Caption := LoadStr(Code + $1FE);
  gbFind.Caption := LoadStr(Code + $1FF);
  cbCaseSens.Caption := LoadStr(Code + $200);
  rbFindUp.Caption := LoadStr(Code + $201);
  rbFindDown.Caption := LoadStr(Code + $202);
  bFindNext.Caption := LoadStr(Code + $203);
  miFormat.Caption := LoadStr(Code + $206);
  miUnFormat.Caption := LoadStr(Code + $207);
  miColorsImages.Caption := LoadStr(Code + $208);
  miLoadOptionsAs.Caption := LoadStr(Code + $20A);
  miSaveOptionsAs.Caption := LoadStr(Code + $209);
  lComment.Caption := LoadStr(Code + $20B);
  cbCommentOnClick.Caption := LoadStr(Code + $20C);
  cbCommentOnSelect.Caption := LoadStr(Code + $20D);
  miAttriChange.Caption := LoadStr(Code + $20E);
  tsHistory.Caption := LoadStr(Code + $218);
  sbDownloadWiki.Caption := LoadStr(Code + $219);
end;

procedure TfmSecond.miLangSelect(Sender: TObject);
begin
  { Tag пунктов меню -- не порядковые номера, а коды языков. }
  (Sender as TMenuItem).Checked := True;
  case (Sender as TMenuItem).Tag of
    25:
      begin
        gLangOffsety := $7D0;
        ApplyLanguage(gLangOffsety);
      end;
    22:
      begin
        gLangOffsety := $BB8;
        ApplyLanguage(gLangOffsety);
      end;
    35:
      begin
        gLangOffsety := $FA0;
        ApplyLanguage(gLangOffsety);
      end;
    7:
      begin
        gLangOffsety := $1388;
        ApplyLanguage(gLangOffsety);
      end;
    34:
      begin
        gLangOffsety := $1B58;
        ApplyLanguage(gLangOffsety);
      end;
    100:
      begin
        gLangOffsety := $2710;
        ApplyLanguage(gLangOffsety);
      end;
    0:
      if gLangOffsety > 0 then
        MsgBox(PChar(LoadStr(gLangOffsety + $1B7)), 'UOPilot Error Message', 0)
      else
        MsgBox('Выбран язык по умолчанию.'#13'Необходим перезапуск.', 'Info', 0);
  else
    gLangOffsety := $3E8;
    ApplyLanguage(gLangOffsety);
  end;
end;

procedure TfmSecond.tbUOPriorityChange(Sender: TObject);
var
  S: string;
begin
  case tbUOPriority.Position of
    1: if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $14A) else S := 'ниже';
    3: if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $14B) else S := 'выше';
  else
    if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $14C) else S := 'нормальный';
  end;
  if gLangOffsety > 0 then
    S := LoadStr(gLangOffsety + $14D) + ' (' + S + ')'
  else
    S := 'Приоритет для запускаемых клиентов (' + S + ')';
  tbUOPriority.Hint := S;
end;

procedure TfmSecond.tbScriptPriorityChange(Sender: TObject);
var
  S: string;
begin
  case tbScriptPriority.Position of
    0: if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $168) else S := 'пониженный';
    2: if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $16A) else S := 'средний';
    3: if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $16B) else S := 'максимальный';
  else
    if gLangOffsety > 0 then S := LoadStr(gLangOffsety + $169) else S := 'нормальный';
  end;
  tbScriptPriority.Hint := S;
end;

procedure TfmSecond.cbDebugClick(Sender: TObject);
var
  I: Integer;
begin
  I := StrToInt(tScript.Tabs[tScript.TabIndex]);
  gScriptso3[I].Debug := cbDebug.Checked;
end;

procedure TfmSecond.miShowTimerVarClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 99 do
    if Assigned(gScriptso3[I]) then
      gScriptso3[I].ShowTimerVar := fmSecondfj.miShowTimerVar.Checked;
  RefreshVarPanel;
end;

procedure TfmSecond.sbShowSkillsClick(Sender: TObject);
begin
  pCP.Visible := not sbShowSkills.Down;
  pSkills.Visible := sbShowSkills.Down;
  if pSkills.Visible then
    Timer1Timer(Sender);
end;

procedure TfmSecond.mLMDblClick(Sender: TObject);
begin
  miComClick(miCopyLM);
end;

procedure TfmSecond.miUOSetupClick(Sender: TObject);
var
  H: THandle;
  Pid: DWORD;
begin
  H := FindWindow('Ultima Online', nil);
  GetWindowThreadProcessId(H, @Pid);
  H := OpenProcess($418, False, Pid);
  UpdateClientFlags(H);
  FileClose(H); { *Преобразовано из CloseHandle* }
end;

procedure TfmSecond.miTrayRestoreClick(Sender: TObject);
begin
  fmSecondfj.Show;
  fmSecondfj.WindowState := wsNormal;
  SetForegroundWindow(Application.Handle);
end;

procedure TfmSecond.pcAllChange(Sender: TObject);
var
  Saved: Boolean;
begin
  { При переходе на вкладку скрипта окно распахивается до сохранённого размера
    и снимаются ограничения; при уходе с неё ограничения возвращаются. }
  if pcAll.ActivePage = tsScript then
  begin
    gInScriptTab := True;
    fmSecondfj.Constraints.MaxHeight := 0;
    fmSecondfj.Constraints.MaxWidth := 0;
    Saved := gFlag5969EE;
    fmSecondfj.Width := gSavedWidth;
    fmSecondfj.Height := gSavedHeight;
    if Saved then
    begin
      ShowWindow(fmSecondfj.Handle, SW_MAXIMIZE);
      gFlag5969EE := True;
    end;
    pcAll.Constraints.MaxHeight := 0;
    pcAll.Constraints.MaxWidth := 0;
    pcAll.Align := alClient;
    FormResize(Sender);
    if (not gNoFocusStealfq) and fmSecondfj.Visible and Assigned(edScript) and
       edScript.Visible and edScript.Enabled then
      edScript.SetFocus;
    if tScript.OwnerDraw then
      RedrawAllTabs;
  end
  else
  begin
    pcAll.Constraints.MaxHeight := pcAll.Constraints.MinHeight;
    pcAll.Constraints.MaxWidth := pcAll.Constraints.MinWidth;
    Saved := gFlag5969EE;
    if gFlag5969EE then
    begin
      ShowWindow(fmSecondfj.Handle, SW_RESTORE);
      gFlag5969EE := True;
    end;
    fmSecondfj.Constraints.MaxHeight := fmSecondfj.Constraints.MinHeight;
    fmSecondfj.Constraints.MaxWidth := fmSecondfj.Constraints.MinWidth;
    gFlag5969EE := Saved;
    gInScriptTab := False;
  end;
end;

procedure TfmSecond.WMNCHitTest(var Msg: TMessage);
begin
  { Пока открыта НЕ вкладка скрипта, окно тянуть за рамку нельзя: все
    попадания в рамку и кнопку разворота ($09..$11) подменяются заголовком,
    и рамка перестаёт тянуться. HTZOOM = HTMAXBUTTON = 9,
    HTBOTTOMRIGHT = 17. }
  inherited;
  if not gInScriptTab then
    case Msg.Result of
      HTZOOM..HTBOTTOMRIGHT: Msg.Result := HTCAPTION;
    end;
end;

procedure TfmSecond.WMSize(var Msg: TMessage);
begin
  { Запоминает, развёрнуто ли окно: тем же флагом pcAllChange решает,
    разворачивать ли его обратно. Ветка SIZE_MINIMIZED не делает ничего. }
  inherited;
  case Msg.WParam of
    SIZE_MAXIMIZED: gFlag5969EE := True;
    SIZE_RESTORED: gFlag5969EE := False;
  end;
end;

procedure TfmSecond.WMSysCommand(var Msg: TMessage);
begin
  { Перед разворотом окна запоминается его размер, чтобы pcAllChange
    вернул именно его. Сравнение точное, без маски $FFF0. }
  if Msg.WParam = SC_MAXIMIZE then
  begin
    gSavedWidth := fmSecondfj.Width;
    gSavedHeight := fmSecondfj.Height;
  end;
  inherited;
end;

procedure TfmSecond.WMNCLButtonDblClk(var Msg: TMessage);
begin
  { То же, что и WMSysCommand, но для двойного щелчка по заголовку
    (HTCAPTION = 2). Предка тут нет: inherited уходит в DefaultHandler. }
  if Msg.WParam = HTCAPTION then
  begin
    gSavedWidth := fmSecondfj.Width;
    gSavedHeight := fmSecondfj.Height;
  end;
  inherited;
end;

procedure TfmSecond.FormResize(Sender: TObject);
var
  T: TTabControl;
begin
  if tScriptDesc.Visible then
  begin
    tScriptDesc.Height := tScriptDesc.RowCount * tScriptDesc.TabHeight + 4;
    T := tScriptDesc;
    PanelTs.Height := (T.RowCount - 1) * T.TabHeight + tScript.Height;
  end
  else
    PanelTs.Height := tScript.Height;
  try
    pPos.Left := edScript.Left + edScript.Width - pPos.Width;
    pPos.Top := edScript.Top + edScript.Height - pPos.Height;
  except
  end;
  pTabRename.Top := gScript.Top - pTabRename.Height;
end;

procedure TfmSecond.miPauseCurrentScriptClick(Sender: TObject);
begin
  if sbPause.Enabled then
  begin
    sbPause.Down := not sbPause.Down;
    sbPauseClick(Sender);
  end;
end;

procedure TfmSecond.miPauseAllScriptClick(Sender: TObject);
var
  Cur: Integer;
  S: string;
  I: Integer;
  Lo, Hi: Integer;
  gSZ: TScriptArrayS absolute gScriptso3;
begin
  S := tScript.Tabs[tScript.TabIndex];
  Cur := StrToInt(S);
  Lo := Low(gScriptso3);
  Hi := High(gSZ);
  for I := Lo to Hi do
    if Assigned(gScriptso3[I]) then
      if gScriptso3[I].Flag91 and not gScriptso3[I].Paused then
      begin
        gScriptso3[I].Paused := True;
        if (I = Cur) and gScriptso3[I].AutoStart then
          gSZ[I].PauseScriptThread;
      end;
end;

procedure TfmSecond.sbWinListClick(Sender: TObject);
var
  Buf: PChar;
  IsWin: Boolean;
  Show: Boolean;
  Vis: Boolean;
  HasOwn: Boolean;
  S: string;
  T: string;
  Old: string;
  Pid: DWORD;
  Cur: HWND;
  W: HWND;
  N: HWND;
begin
  { Перебор всех окон верхнего уровня: заголовок, признак видимости и наличие
    дочерних окон складываются в подпись, хэндлы -- в gWinHandles. Прежний
    выбор восстанавливается по совпадению заголовка и хэндла. }
  if (cbWinList.ItemIndex <= Length(gWinHandles)) and
     (cbWinList.ItemIndex >= 0) then
    Cur := gWinHandles[cbWinList.ItemIndex]
  else
    Cur := 0;
  Old := lWinList.Caption;
  cbWinList.Items.Clear;
  W := GetTopWindow(0);
  repeat
    N := GetWindow(W, GW_OWNER);
    if N <> 0 then
      W := N;
  until N = 0;
  W := GetWindow(W, GW_HWNDFIRST);
  Buf := StrAlloc(100);
  SetLength(gWinHandles, 0);
  repeat
    GetWindowText(W, Buf, $50);
    IsWin := IsWindow(W);
    Vis := IsWindowVisible(W);
    HasOwn := GetWindow(W, GW_OWNER) <> 0;
    S := '';
    Show := Vis or miShowAllWindows.Checked;
    if (StrComp(Buf, '') <> 0) and IsWin then
      if Show then
      begin
        GetWindowThreadProcessId(W, @Pid);
        T := IntToStr(Pid);
        while Length(T) < 4 do
          T := ' ' + T;
        if HasOwn then
          S := S + '> ';
        if not Vis then
          S := S + '* ';
        cbWinList.Items.Add(T + ' ' + S + Buf);
        if (Buf = Old) and (W = Cur) then
        begin
          cbWinList.Tag := 1;
          cbWinList.ItemIndex := cbWinList.Items.Count - 1;
          cbWinList.Tag := 0;
        end;
        SetLength(gWinHandles, cbWinList.Items.Count);
        gWinHandles[Length(gWinHandles) - 1] := W;
      end;
    N := GetWindow(W, GW_HWNDNEXT);
    if N <> 0 then
      W := N;
  until N = 0;
  StrDispose(Buf);
  SendMessage(cbWinList.Handle, $14F, 1, 0);
end;

procedure TfmSecond.cbWinListChange(Sender: TObject);
var
  S: string;
  I: Integer;
  W: HWND;
  Pid: DWORD;
begin
  if cbWinList.Tag = 0 then
  begin
    I := StrToInt(tScript.Tabs[tScript.TabIndex]);
    W := gWinHandles[cbWinList.ItemIndex];

    gScriptso3[I].ClientWnd := W;
    gScriptso3[I].ClientWnd2 := W;

    GetWindowThreadProcessId(W, @Pid);
    gScriptso3[I].ProcessId := Pid;

    if gScriptso3[I].ProcessHandle <> 0 then
      FileClose(gScriptso3[I].ProcessHandle); { *Преобразовано из CloseHandle* }

    gScriptso3[I].ProcessHandle := OpenProcess($638, False, Pid);
    gScriptso3[I].ProcessHandle2 := gScriptso3[I].ProcessHandle;

    S := cbWinList.Items[cbWinList.ItemIndex];
    Delete(S, 1, 5);

    if Copy(S, 1, 2) = '> ' then
      Delete(S, 1, 2);

    if Copy(S, 1, 2) = '* ' then
      Delete(S, 1, 2);

    if GetKeyState(VK_SHIFT) and $80 = $80 then
      edScript.SelText := S;

    if edScript.Visible then
      if edScript.Enabled then
        edScript.SetFocus;

    lWinList.Caption := S;
    sbWorkwindowHandle.Caption := IntToStr(W);
  end;
  I := I;
end;

procedure TfmSecond.CFCPRelayout(Sender: TObject);
var
  W: Integer;
begin
  if sbCharParams.Tag in [1..7] then
  begin
    sgVar.ColWidths[0] := sgVar.DefaultColWidth;
    sgVar.ColWidths[1] := $53;
  end;
  case sbCharParams.Tag of
    2:
      begin
        pCPVar.Height := gDlg5966F0.ClientHeight -
          (pCharParams.Height + pCPDTimer.Height);
        pCPDTimer.Top := pCPVar.Height + pCharParams.Height;
      end;
    5:
      begin
        pCPVar.Height := gDlg5966F0.ClientHeight - (pCPLastObjects.Height + 5);
        pCPLastObjects.Top := pCPVar.Height + 5;
        pCPDTimer.Top := pCPLastObjects.Top + pCPLastObjects.Height;
      end;
    8:
      begin
        pCPVar.Height := gDlg5966F0.ClientHeight;
        W := (pCPVar.Width - pCPVar.Tag) div 10;
        sgVar.ColWidths[0] := sgVar.DefaultColWidth + W;
        sgVar.ColWidths[1] := pCPVar.Width + $53 - pCPVar.Tag - W;
        gWidth596A64 := pCPVar.Width;
      end;
  end;
end;

procedure TfmSecond.tScriptMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
  Pid: DWORD;
  R: TRect;
  I: Integer;
  gSZ: TScriptArrayS absolute gScriptso3;
begin
  if Sender is TTabControl then
  begin
    gMouseX := X;
    gMouseY := Y;
    if FFlag1464 then
    begin
      X := X;
      Y := Y;
      Idx := tScript.IndexOfTabAt(X, Y);
      if Idx >= 0 then
      begin
        R := tScript.TabRect(Idx);
        if (Y >= R.Bottom - 6) and (Y <= R.Bottom) then
        begin
          if (X >= R.Left + 2) and (X <= R.Left + 10) then
          begin
            I := StrToInt(tScript.Tabs[Idx]);
            if gScriptso3[I] <> nil then
            begin
              if tScript.TabIndex = Idx then
                if not gScriptso3[I].Flag91 then
                begin
                  btStart.Down := True;
                  btStartClick(Sender);
                  Exit;
                end;
              if gSZ[I].AutoStart then
                gSZ[I].AfterScriptStarted;
              if gScriptso3[I].StopRequested then
                gScriptso3[I].StopRequested := False;
              if gScriptso3[I].Paused then
              begin
                gScriptso3[I].Paused := False;
                gScriptso3[I].Resume;
              end;
              if not gScriptso3[I].Flag91 then
              begin
                if gScriptso3[I].ClientWnd = 0 then
                begin
                  gScriptso3[I].ClientWnd := FindWindow('Ultima Online', nil);
                  GetWindowThreadProcessId(gScriptso3[I].ClientWnd, @Pid);
                  gScriptso3[I].ProcessId := Pid;
                  if gScriptso3[I].ProcessHandle <> 0 then
                    FileClose(gScriptso3[I].ProcessHandle); { *Преобразовано из CloseHandle* }
                  gScriptso3[I].ProcessHandle := OpenProcess($638, True, Pid);
                end;
                gScriptso3[I].Flag91 := True;
                StartScriptThread(gScriptso3[I]);
                gScriptso3[I].Resume;
              end;
              if gSZ[I].AutoStart then
                gSZ[I].AfterScriptStarted;
            end;
          end
          else
          begin
            if (X <= R.Right - 2) and (X >= R.Right - 10) then
            begin
              if tScript.TabIndex = Idx then
              begin
                btStart.Down := False;
                btStartClick(Sender);
              end
              else
              begin
                I := StrToInt(tScript.Tabs[Idx]);
                if gScriptso3[I] <> nil then
                begin
                  gScriptso3[I].StopRequested := True;
                  gScriptso3[I].Flag91 := False;
                  if gScriptso3[I].Paused then
                  begin
                    gScriptso3[I].Paused := False;
                    gScriptso3[I].Resume;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TfmSecond.pcAllChanging(Sender: TObject; var AllowChange: Boolean);
begin
  if not gFlag5969EE then
    if pcAll.ActivePage = tsScript then
    begin
      gSavedWidth := fmSecondfj.Width;
      gSavedHeight := fmSecondfj.Height;
    end;
end;

procedure TfmSecond.NotPayedProc(Sender: TObject);
begin
  MsgBox('Please donate for further development and regular updates of this product.', 'Donation', 0);
end;

procedure TfmSecond.eFindTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = $D then
    bFindNextClick(Sender);
end;

procedure TfmSecond.bFindNextClick(Sender: TObject);
var
  Text: string;
  Dir: Integer;
  Flags: Integer;
  V: OleVariant;
begin
  { Поиск по справке идёт поздним связыванием через DOM браузера:
    у документа берётся body.CreateTextRange, найденное подсвечивается
    execCommand. }
  case pcHelp.TabIndex of
    0:
      begin
        Text := eFindText.Text;
        if Text <> '' then
        begin
          case rbFindDown.Checked of
            True: Dir := 1;
            False: Dir := -1;
          end;
          case cbCaseSens.Checked of
            True: Flags := 4;
            False: Flags := 0;
          end;
          if eFindText.Modified then
          begin
            V := wbWiki.Document;
            gTextRange := V.body.CreateTextRange;
            eFindText.Modified := False;
          end;
          if not gTextRange.FindText(Text, Dir, Flags) then
          begin
            V := wbWiki.Document;
            gTextRange := V.body.CreateTextRange;
            gTextRange.FindText(Text, Dir, Flags);
          end;
          gTextRange.execCommand('BackColor', '', 'yellow');
          gTextRange.execCommand('ForeColor', '', 'red');
          gTextRange.execCommand('Bold');
          gTextRange.ScrollInToView;
          gTextRange.collapse(False);
          gTextRange.select;
        end;
      end;
    1:
      begin
        fhFindDialog.FindText := eFindText.Text;
        if rbFindDown.Checked then
          fhFindDialog.Options := fhFindDialog.Options + [frDown]
        else
          fhFindDialog.Options := fhFindDialog.Options - [frDown];
        if cbCaseSens.Checked then
          fhFindDialog.Options := fhFindDialog.Options + [frMatchCase]
        else
          fhFindDialog.Options := fhFindDialog.Options - [frMatchCase];
        FFlag1438 := True;
        fld_1434 := fld_1430;
        ScriptFindDialogFind(fhFindDialog);
      end;
  end;
end;

procedure TfmSecond.ScriptFindDialogFind(Sender: TObject);
var
  TextLen: Integer;
  FindLen: Integer;
  Backwards: Boolean;
  Memo: TMemo;
  Ed: TSynEdit;
  sRepl: string;
  sFind: string;
  b2: Boolean;
  b1: Boolean;
  Dlg: TFindDialog;
  TextBuf: PChar;
  FindBuf: PChar;
  P: PChar;
  I: Integer;
  MC: Boolean;
  C: Char;
begin
  { OnFind/OnReplace обоих диалогов (fhFindDialog и fhReplaceDialog, см.
    FormCreate), а также поиск по вкладке истории из bFindNextClick.
    Один обработчик обслуживает два приёмника текста: SynEdit со скриптом и
    TMemo окна справки. Какой из них -- говорит FFlag1438, а сам объект лежит
    в fld_1434, поэтому на одно значение заведены две переменные разного типа.
    Ищется не по строке, а по копии текста в PChar-буфере: для поиска ВВЕРХ
    буфер и образец разворачиваются задом наперёд, и дальше работает обычный
    StrPos вниз. }
  Memo := TMemo(fld_1434);
  Ed := TSynEdit(fld_1434);
  if Sender is TReplaceDialog then
  begin
    sRepl := (Sender as TReplaceDialog).ReplaceText;
    sFind := (Sender as TReplaceDialog).FindText;
    MC := frMatchCase in (Sender as TReplaceDialog).Options;
    b1 := Pos(sFind, sRepl) > 0;
    b2 := Pos(AnsiLowerCase(sFind), AnsiLowerCase(sRepl)) > 0;
    { «заменить всё», когда замена сама содержит образец, -- это бесконечный
      цикл: пищим и уходим, ничего не тронув }
    if (frReplaceAll in (Sender as TReplaceDialog).Options) and
      (b1 and MC or not MC and b2) then
    begin
      MessageBeep(0);
      Exit;
    end;
  end;
  Dlg := Sender as TFindDialog;
  GetMem(FindBuf, Length(Dlg.FindText) + 1);
  StrPCopy(FindBuf, Dlg.FindText);
  while True do
  begin
    TextLen := Memo.GetTextLen + 1;
    GetMem(TextBuf, TextLen);
    if FFlag1438 then
      Memo.GetTextBuf(TextBuf, TextLen)
    else
      Ed.GetTextBuf(TextBuf, TextLen);
    { без учёта регистра сравниваем в верхнем: оба буфера прогоняются
      через AnsiStrUpper прямо на месте }
    if not (frMatchCase in Dlg.Options) then
    begin
      TextBuf := AnsiStrUpper(TextBuf);
      FindBuf := AnsiStrUpper(FindBuf);
    end;
    Backwards := not (frDown in Dlg.Options);
    if Backwards then
    begin
      I := 0;
      while I < (TextLen - 1) div 2 do
      begin
        C := TextBuf[I];
        TextBuf[I] := TextBuf[TextLen - 1 - I - 1];
        TextBuf[TextLen - 1 - I - 1] := C;
        Inc(I);
      end;
      FindLen := Length(Dlg.FindText);
      I := 0;
      while I < FindLen div 2 do
      begin
        C := FindBuf[I];
        FindBuf[I] := FindBuf[FindLen - I - 1];
        FindBuf[FindLen - I - 1] := C;
        Inc(I);
      end;
      { в перевёрнутом буфере курсору соответствует зеркальное смещение;
        при замене отсчёт идёт от НАЧАЛА выделения, при поиске -- от конца }
      if FFlag1438 then
        P := TextBuf + (TextLen - 1) - Memo.SelStart
      else if (Sender is TReplaceDialog) and
        (frReplace in (Sender as TReplaceDialog).Options) then
        P := TextBuf + (TextLen - 1) - Ed.SelStart - Ed.SelLength
      else
        P := TextBuf + (TextLen - 1) - Ed.SelStart;
    end
    else
    begin
      if FFlag1438 then
        P := TextBuf + Memo.SelStart + Memo.SelLength
      else if (Sender is TReplaceDialog) and
        (frReplace in (Sender as TReplaceDialog).Options) then
        P := TextBuf + Ed.SelStart
      else
        P := TextBuf + Ed.SelStart + Ed.SelLength;
    end;
    P := StrPos(P, FindBuf);
    { до конца не нашли -- заходим на второй круг от начала текста }
    if P = nil then
    begin
      P := TextBuf;
      P := StrPos(P, FindBuf);
      if P = nil then
      begin
        if FFlag1438 then
          Memo.SelLength := 0
        else
          Ed.SelLength := 0;
        MessageBeep(0);
        FreeMem(FindBuf, Length(Dlg.FindText) + 1);
        FreeMem(TextBuf, TextLen);
        Exit;
      end;
    end;
    I := P - TextBuf;
    if Backwards then
      I := TextLen - 1 - I - Length(Dlg.FindText);
    if FFlag1438 then
    begin
      Memo.SelStart := I;
      Memo.SelLength := Length(Dlg.FindText);
    end
    else
    begin
      Ed.SelStart := I;
      Ed.SelLength := Length(Dlg.FindText);
    end;
    { «заменить всё» -- заменили, встали за заменой и пошли на следующий круг
      уже по изменённому тексту; текстовый буфер перечитывается заново }
    if frReplaceAll in Dlg.Options then
    begin
      if FFlag1438 then
      begin
        Memo.SelText := sRepl;
        Memo.SelStart := Length(sRepl) + I;
      end
      else
      begin
        Ed.SelText := sRepl;
        Ed.SelStart := Length(sRepl) + I;
      end;
      FreeMem(TextBuf, TextLen);
    end
    else
    begin
      if frReplace in Dlg.Options then
        if FFlag1438 then
        begin
          Memo.SelText := sRepl;
          Memo.SelStart := I;
          Memo.SelLength := Length(sRepl);
        end
        else
        begin
          Ed.SelText := sRepl;
          Ed.SelStart := I;
          Ed.SelLength := Length(sRepl);
        end;
      FreeMem(FindBuf, Length(Dlg.FindText) + 1);
      FreeMem(TextBuf, TextLen);
      Exit;
    end;
  end;
end;

procedure TfmSecond.miLogWindowClick(Sender: TObject);
var
  V: Integer;
begin
  { Окно лога: размеры и позиция берутся из сохранённых, а если вызов пришёл
    от самой формы -- из полей FLogWin, запомненных при закрытии. }
  if gDlg5966F8c6 = nil then
  begin
    gDlg5966F8c6 := TForm.Create(fmSecondfj);
    gDlg5966F8c6.Parent := nil;
    gDlg5966F8c6.BorderStyle := bsSizeable;
    if miSOTLogWindow.Checked then
      gDlg5966F8c6.FormStyle := fsStayOnTop
    else
      gDlg5966F8c6.FormStyle := fsNormal;
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
    gDlg5966F8c6.Caption := 'Log Window';
    if miSPosUoP.Checked then
    begin
      V := gLogRect.Top;
      if V <> -1 then
        gDlg5966F8c6.Top := V
      else
        gDlg5966F8c6.Top := Top;
      V := gLogRect.Left;
      if V <> -1 then
        gDlg5966F8c6.Left := V
      else
        gDlg5966F8c6.Left := Left + Width;
    end
    else
    begin
      gDlg5966F8c6.Top := Top;
      gDlg5966F8c6.Left := Left + Width;
    end;
    if Sender = fmSecondfj then
    begin
      gDlg5966F8c6.Width := FLogWin.Width;
      gDlg5966F8c6.Height := FLogWin.Height;
      V := FLogWin.Left;
      if (V <> -1) and (FLogWin.Top <> -1) then
      begin
        gDlg5966F8c6.Left := V;
        gDlg5966F8c6.Top := FLogWin.Top;
      end;
    end
    else
    begin
      gDlg5966F8c6.Width := $1DB;
      gDlg5966F8c6.Height := $14C;
    end;
    if miSPosUoP.Checked then
    begin
      V := gLogRect.Right;
      if V <> -1 then
        gDlg5966F8c6.Width := V;
      V := gLogRect.Bottom;
      if V <> -1 then
        gDlg5966F8c6.Height := V;
    end;
    if (gDlg5966F8c6.Left + gDlg5966F8c6.Width) > Screen.DesktopWidth then
      gDlg5966F8c6.Left := Left - gDlg5966F8c6.Width;
    if gDlg5966F8c6.Left < 0 then
      gDlg5966F8c6.Left := 0;
    gDlg5966F8c6.OnCloseQuery := LogWindowClose;
    pLog.Parent := gDlg5966F8c6;
    pLog.Visible := True;
    pLog.Align := alClient;
    pLog.Font.Size := gListFontSize;
    mLog.HideSelection := False;
    with mLog do
    begin
      Left := 0;
      Top := 0;
      Align := alClient;
    end;
    gOldLogProc := mLog.WindowProc;
    mLog.WindowProc := HelpMemoWndProc;
    tcLog.Height := -tcLog.Font.Height * 20 div 12;
    tcLog.Visible := True;
    tcLog.Align := alBottom;
  end;
  if gDlg5966F8c6.Visible then
    gDlg5966F8c6.Visible := False
  else
    gDlg5966F8c6.Visible := True;
end;

procedure TfmSecond.mmScriptKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Y: Integer;
  X: Integer;
  M: Integer;
  T: string;
  S: string;
  W: string;
  N: Integer;
  E: TSynMemo;
begin
  case Key of
    38:
      begin
        N := edScript.CaretY;
        if N = 1 then
          pPos.Caption := IntToStr(N - 1)
        else
          pPos.Caption := IntToStr(N - 2);
      end;
    40:
      begin
        E := edScript;
        if E.Lines.Count = E.CaretY then
          pPos.Caption := IntToStr(edScript.CaretY - 1)
        else
          pPos.Caption := IntToStr(edScript.CaretY);
      end;
    112:
      ShowWikiForCommand;
    13:
      begin
        Key := 0;
        S := '';
        if miAddSp.Checked and (Shift = []) then
        begin
          Y := edScript.CaretY;
          X := edScript.CaretX;
          T := Copy(edScript.Lines[Y - 1], 1, X);
          if Length(T) <> 0 then
          begin
            N := 0;
            while (N <= Length(T)) and (T[N + 1] in [#9, ' ']) do
              Inc(N);
            if N > 0 then
              Delete(T, 1, N);
            M := 1;
            while (Length(T) >= M) and not (T[M] in [#9, ' ']) do
              Inc(M);
            W := AnsiLowerCase(Copy(T, 1, M - 1));
            if (W = 'repeat') or (W = 'switch') or (W = 'if') or (W = 'if_not') or
              (W = 'while') or (W = 'while_not') or (W = 'for') or (W = 'proc') or
              (W = 'else') or (W = 'case') then
              N := N + seTabSize.Value;
            while N > 0 do
            begin
              Dec(N);
              S := S + ' ';
            end;
          end;
        end;
        edScript.SelText := #13#10 + S;
      end;
  end;
  if Key = 70 then
  begin
    if Shift = [ssCtrl] then
    begin
      FFlag1438 := False;
      fld_1434 := Integer(Sender as TSynMemo);
      fhFindDialog.OnFind := ScriptFindDialogFind;
      fhFindDialog.Execute;
    end;
  end;
  if Key = 72 then
  begin
    if Shift = [ssCtrl] then
    begin
      FFlag1438 := False;
      Key := 0;
      Shift := [];
      gFlag596A40 := True;
      fld_1434 := Integer(Sender as TSynMemo);
      fhReplaceDialog.OnFind := ScriptFindDialogFind;
      fhReplaceDialog.OnReplace := ScriptFindDialogFind;
      fhReplaceDialog.Execute;
    end;
  end;
end;

procedure TfmSecond.mmScriptMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  S: string;
begin
  S := IntToStr(edScript.CaretY - 1);
  pPos.Caption := S;
end;

procedure TfmSecond.mmScriptMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  S: string;
begin
  S := IntToStr(edScript.CaretY - 1);
  pPos.Caption := S;
end;

procedure TfmSecond.RedrawAllTabs;
var
  I: Integer;
  R: TRect;
begin
  for I := 0 to tScript.Tabs.Count - 1 do
  begin
    R.Left := 0;
    R.Top := 0;
    R.Right := 0;
    R.Bottom := 0;
    if tScriptDesc.Visible then
      tScriptDrawTab(tScriptDesc, I, R, I = tScriptDesc.TabIndex)
    else
      tScriptDrawTab(tScript, I, R, I = tScript.TabIndex);
  end;
end;

procedure TfmSecond.cbClVerChange(Sender: TObject);
var
  P: TPanel;
begin
  if cbClVer.ItemIndex = 23 then
  begin
    if gDlg596708 = nil then
    begin
      gDlg596708 := TForm.Create(fmSecondfj);
      gDlg596708.Parent := nil;
      gDlg596708.BorderStyle := bsSizeToolWin;
      gDlg596708.ClientHeight := pCustomClient.Height;
      gDlg596708.ClientWidth := pCustomClient.Width;
      gDlg596708.Position := poScreenCenter;
      gDlg596708.Caption := pCustomClient.Hint;
      gDlg596708.OnCloseQuery := DetachedPanelClose;
      P := pCustomClient;
      P.Parent := gDlg596708;
      P.Left := 0;
      P.Top := 0;
      P.Align := alClient;
      P.Visible := True;
    end;
    gDlg596708.Visible := True;
  end;
end;

procedure LoadPlugins(Form: TfmSecond; Only: string);
var
  Ver: Double;
  Dir: string;
  S: string;
  Loaded: Boolean;
  Cap: string;
  H: HMODULE;
  Init: TInitPlugin;
  Cnt: Integer;
  Sub: string;
  P: Integer;
  Nm: string;
  Found: Boolean;
  Mi: TMenuItem;
  NewMi: TMenuItem;
  P2: Integer;
  Part: string;
  Err: string;
  SR: TSearchRec;

  procedure RegPlugin(Name: string);
  begin
    Loaded := False;
    if AnsiUpperCase(ExtractFileExt(Name)) = '.DLL' then
    begin
      H := LoadLibrary(PChar(Dir + Name));
      if H >= 32 then
      begin
        Init := nil;
        @Init := GetProcAddress(H, 'InitPlugin');
        if not Assigned(Init) then
          @Init := GetProcAddress(H, '_InitPlugin');
        if Assigned(Init) then
        begin
          try
            gPluginFuncsgm := Init(Application.Handle, 0, Ver);
            gPluginListjr.AddObject(Name, TObject(H));
            Loaded := gPluginFuncsgm^.Count > 0;
            Cnt := gPluginFuncsgm^.Count;
            while gPluginFuncsgm^.Count > 0 do
            begin
              S := gPluginFuncsgm^.Names[gPluginFuncsgm^.Count - 1];
              Nm := '';
              P := Pos('|', S);
              if P > 0 then
              begin
                Nm := Copy(S, 1, P - 1);
                Delete(S, 1, P);
                while S[Length(S)] = ' ' do
                  S := Copy(S, 1, Length(S) - 1);
              end;
              Sub := '';
              P := Pos('\', S);
              while P > 0 do
              begin
                Sub := Sub + Copy(S, 1, P);
                Delete(S, 1, P);
                P := Pos('\', S);
              end;
              P := Pos('(', S);
              if P > 0 then
                Cap := Copy(S, 1, P - 1)
              else
              begin
                Cap := S;
                S := S + ' ()';
              end;
              while Cap[Length(Cap)] = ' ' do
                Cap := PChar(Copy(Cap, 1, Length(Cap) - 1));
              P := Pos('.', Name);
              if P > 0 then
                Name := Copy(Name, 1, P - 1);
              if Nm = '' then
                Nm := Cap;
              gCmdListah7.AddObject(AnsiLowerCase(Name + '.' + Cap),
                TObject(GetProcAddress(H, PChar(Nm))));
              Found := False;
              Mi := Form.miPlugins;
              P := 0;
              while (Mi.Count - 1 >= P) and not Found do
                if Mi.Items[P].Caption = Name then
                begin
                  Found := True;
                  Break;
                end
                else
                  Inc(P);
              if Found then
                Mi := Mi.Items[P]
              else
              begin
                NewMi := TMenuItem.Create(Mi);
                NewMi.Caption := Name;
                NewMi.AutoHotkeys := maManual;
                Mi.Insert(0, NewMi);
                Mi := NewMi;
              end;
              if Sub <> '' then
              begin
                P2 := Pos('\', Sub);
                while P2 <> 0 do
                begin
                  Part := Copy(Sub, 1, P2 - 1);
                  Delete(Sub, 1, P2);
                  Found := False;
                  P := 0;
                  while (Mi.Count - 1 >= P) and not Found do
                    if Mi.Items[P].Caption = Part then
                    begin
                      Found := True;
                      Break;
                    end
                    else
                      Inc(P);
                  if Found then
                    Mi := Mi.Items[P]
                  else
                  begin
                    NewMi := TMenuItem.Create(Mi);
                    NewMi.Caption := Part;
                    NewMi.AutoHotkeys := maManual;
                    Mi.Insert(0, NewMi);
                    Mi := NewMi;
                  end;
                  P2 := Pos('\', Sub);
                end;
              end;
              NewMi := TMenuItem.Create(Mi);
              NewMi.Caption := S;
              NewMi.AutoHotkeys := maManual;
              NewMi.OnClick := Form.miPluginsClick;
              Mi.Insert(0, NewMi);
              Dec(gPluginFuncsgm^.Count);
            end;
            Err := 'Incorrect plugin version - ' + FloatToStr(Ver) +
              ' or missing functions.';
          except
            Err := 'Call ''InitPlugin'' failed.';
          end;
        end
        else
          Err := '''InitPlugin'' not found.';
      end
      else
        Err := 'Load failed.';
      if not Loaded then
        FreeLibrary(H);
      if Form.miPluginLoadError.Checked then
      begin
        if Loaded then
          gScriptso3[0].Msg := 'Plugin loaded: ' + Name + '. ' +
            IntToStr(Cnt) + ' functions found'
        else
          gScriptso3[0].Msg := 'Error loading plugin: ' + Name + '. ' + Err;
        gCoordCaptureddo := True;
        TScanThread(gScriptso3[0]).SyncLogMsg;
      end;
    end;
  end;

begin
  { Обход Plugins\*.dll. Вся работа с одним файлом -- во вложенной
    RegisterPlugin. Пустое второе имя -- перезагрузить всё, непустое --
    дозагрузить один плагин. }
  Err := '';
  Ver := 2.37;
  Dir := 'Plugins\';
  Cnt := 0;
  if Length(Only) <= 0 then
  begin
    if gPluginListjr.Count > 0 then
      DonePlugins(Form, '');
    gPluginListjr.Clear;
    if FindFirst(gTempFilefv + '\Plugins\' + '*.dll', faAnyFile, SR) = 0 then
      repeat
        RegPlugin(SR.Name);
      until FindNext(SR) <> 0;
    { FindClose обязан быть КВАЛИФИЦИРОВАН: Windows.FindClose(THandle)
      перекрывает SysUtils.FindClose(var TSearchRec) }
    SysUtils.FindClose(SR);
  end
  else
    RegPlugin(Only);
end;

procedure AttachClientWindow;
begin
  // Тело живёт во вложенной процедуре FormCreate: автозапуск скриптов,
  // помеченных ключом /rN.
end;

procedure RegisterPlugin(Form: TfmSecond; const Name: string);
begin
  // Тело живёт во вложенной процедуре LoadPlugins.
end;

procedure DonePlugins(Form: TfmSecond; Name: string);
var
  I: Integer;
  Cmd: string;
  Q: procedure;
  M: TMenuItem;
  K: Integer;
  N: Integer;
  Found: Boolean;
begin
  { Выгрузка плагинов. Пустое имя -- выгрузить все, иначе только названный.
    Список живёт в чужом юните (gPlugins), в Objects лежит HMODULE.
    Меню чистится снизу вверх: у каждого пункта обрывается самый глубокий
    лист, его команда убирается из gCmdListah7, и так пока лист не кончится. }
  if Length(Name) <= 0 then
  begin
    for I := 0 to gPluginListjr.Count - 1 do
    begin
      @Q := GetProcAddress(HMODULE(gPluginListjr.Objects[I]), 'DonePlugin');
      if not Assigned(Q) then
        @Q := GetProcAddress(HMODULE(gPluginListjr.Objects[I]), '_DonePlugin');
      if Assigned(Q) then
        try
          Q;
        except
        end;
      FreeLibrary(HMODULE(gPluginListjr.Objects[I]));
    end;
    gPluginListjr.Clear;
    for I := Form.miPlugins.Count - 1 downto 0 do
    begin
      Found := False;
      while Form.miPlugins.Items[I].Count > 0 do
      begin
        Found := True;
        M := Form.miPlugins.Items[I];
        while M.Count <> 0 do
          M := M.Items[0];
        Cmd := Form.miPlugins.Items[I].Caption + '.' +
          Copy(M.Caption, 1, Pos(' (', M.Caption) - 1);
        K := gCmdListah7.IndexOf(Cmd);
        if K >= 0 then
          gCmdListah7.Delete(K);
        M := M.Parent;
        M.Delete(0);
      end;
      if Found then
        Form.miPlugins.Delete(I);
    end;
  end
  else
  begin
    I := gPluginListjr.IndexOf(Name);
    if I >= 0 then
    begin
      @Q := GetProcAddress(HMODULE(gPluginListjr.Objects[I]), 'DonePlugin');
      if not Assigned(Q) then
        @Q := GetProcAddress(HMODULE(gPluginListjr.Objects[I]), '_DonePlugin');
      if Assigned(Q) then
        try
          Q;
        except
        end;
      FreeLibrary(HMODULE(gPluginListjr.Objects[I]));
      gPluginListjr.Delete(I);
    end;
    N := Pos('.', Name);
    if N > 0 then
      Name := Copy(Name, 1, N - 1);
    for I := Form.miPlugins.Count - 1 downto 0 do
    begin
      Found := False;
      if Name = Form.miPlugins.Items[I].Caption then
      begin
      while Form.miPlugins.Items[I].Count > 0 do
      begin
        Found := True;
        M := Form.miPlugins.Items[I];
        while M.Count <> 0 do
          M := M.Items[0];
        Cmd := Form.miPlugins.Items[I].Caption + '.' +
          Copy(M.Caption, 1, Pos(' (', M.Caption) - 1);
        K := gCmdListah7.IndexOf(Cmd);
        if K >= 0 then
          gCmdListah7.Delete(K);
        M := M.Parent;
        M.Delete(0);
      end;
        if Found then
          Form.miPlugins.Delete(I);
        Break;
      end;
    end;
  end;
end;

procedure TfmSecond.miPluginsClick(Sender: TObject);
var
  P: TMenuItem;
begin
  P := (Sender as TMenuItem).Parent;
  while P.Parent <> miPlugins do
    P := P.Parent;
  edScript.SelText := P.Caption + '.' + (Sender as TMenuItem).Caption;
end;

procedure TfmSecond.miTransparentHotKeysClick(Sender: TObject);
begin
  gHotKeyMgr.FFlag34 := miTransparentHotKeys.Checked;
end;

procedure TfmSecond.miGutterVisibleClick(Sender: TObject);
begin
  edScript.Gutter.Visible := miGutterVisible.Checked;
end;

procedure TfmSecond.miShowHelpOnTaskbarClick(Sender: TObject);
begin
  if Assigned(gDlg5966DC) then
  begin
    ShowWindow(gDlg5966DC.Handle, SW_HIDE);
    SetWindowLong(gDlg5966DC.Handle, GWL_EXSTYLE,
      GetWindowLong(gDlg5966DC.Handle, GWL_EXSTYLE) xor WS_EX_APPWINDOW);
    ShowWindow(gDlg5966DC.Handle, SW_SHOW);
  end;
  if Assigned(gHelpForm) then
  begin
    ShowWindow(gHelpForm.Handle, SW_HIDE);
    SetWindowLong(gHelpForm.Handle, GWL_EXSTYLE,
      GetWindowLong(gHelpForm.Handle, GWL_EXSTYLE) xor WS_EX_APPWINDOW);
    ShowWindow(gHelpForm.Handle, SW_SHOW);
  end;
end;

procedure TfmSecond.HotKeyScriptListPause(Sender: TObject);
var
  S: string;
  N: Integer;
  gSZ: TScriptArrayS absolute gScriptso3;
begin
  { Номер скрипта -- хвост имени горячей клавиши после ВТОРОГО подчёркивания. }
  S := (Sender as THotKeyItem).Name;
  Delete(S, 1, PosEx('_', S, Pos('_', S) + 1));
  N := StrToInt(S);
  if gScriptso3[N] = nil then
  begin
    if gLangOffsety > 0 then
      gScriptso3[0].Msg := LoadStr(gLangOffsety + $1D9)
    else
      gScriptso3[0].Msg := 'System error: script ' + IntToStr(N) + ' not created.';
    ShowScriptMsg(TScanThread(gScriptso3[0]));
    Exit;
  end;
  { $91 -- скрипт запущен, $92 -- стоит на паузе. Снятие с паузы будит поток. }
  if gSZ[N].Flag91 then
  begin
    if gSZ[N].Paused then
    begin
      gSZ[N].Paused := False;
      if gSZ[N].AutoStart then
        gSZ[N].ResumeScriptThread;
      gSZ[N].Resume;
    end
    else
    begin
      gSZ[N].Paused := True;
      if gSZ[N].AutoStart then
        gSZ[N].PauseScriptThread;
    end;
  end;
end;

procedure TfmSecond.miRenameSelfClick(Sender: TObject);
begin
  if miRenameSelf.Checked then
    fmSecondfj.Caption := eRenameSelf.Text
  else
    fmSecondfj.Caption := fmSecondfj.Hint;
end;

procedure TfmSecond.sbApplyClick(Sender: TObject);
const
  ModNone = [];
  ModShift = [hkShift];
  ModAlt = [hkAlt];
  ModCtrl = [hkCtrl];
var
  S: string[255];
  Nm: string[255];
  Mods: THKMods;
  Idx: Integer;
  N: Integer;
  Found: Boolean;
  Tmp: THKMods;
begin
  { fld_14E0 хранит указатель на компонент -- отсюда TObject(...).
    Применение горячей клавиши: собирается подпись вида `Ctrl + Alt + F5`,
    маска модификаторов пишется в gHKEntrieslw, а связанные с клавишей
    флажок и метка ищутся через FindComponent по имени `cb`/`l` + имя. }
  Mods := ModNone;
  S := cbHKList.Text;
  if S <> '' then
  begin
    Found := False;
    if cbShift.Checked then
    begin
      Mods := Mods + ModShift;
      S := 'Shift + ' + S;
    end;
    if cbAlt.Checked then
    begin
      Mods := Mods + ModAlt;
      S := 'Alt + ' + S;
    end;
    if cbCtrl.Checked then
    begin
      Mods := Mods + ModCtrl;
      S := 'Ctrl + ' + S;
    end;
    if TObject(fld_14E0) is TSpeedButton then
      N := (TObject(fld_14E0) as TSpeedButton).Tag
    else if TObject(fld_14E0) is TCheckBox then
      N := (TObject(fld_14E0) as TCheckBox).Tag
    else
    begin
      Idx := StrToInt(fmSecondfj.sghkScriptHKList.Cells[1,
        fmSecondfj.sghkScriptHKList.Row]);
      Found := True;
      case gHKMode of
        3: N := fmSecondfj.sghkScriptHKList.Tag + (Idx + 1) * 2 - 2;
        4: N := fmSecondfj.sghkScriptHKList.Tag + (Idx + 1) * 2 - 1;
      else
        N := 0;
      end;
    end;
    if TObject(fld_14E0) is TSpeedButton then
    begin
      Nm := (TObject(fld_14E0) as TSpeedButton).Name;
      Delete(Nm, 1, 1);
      (fmSecondfj.FindComponent('l' + Nm) as TSpeedButton).Caption := S;
    end
    else if TObject(fld_14E0) is TCheckBox then
    begin
      Nm := (TObject(fld_14E0) as TCheckBox).Name;
      Delete(Nm, 1, 2);
      (fmSecondfj.FindComponent('l' + Nm) as TSpeedButton).Caption := S;
    end
    else
    begin
      case gHKMode of
        3: Nm := fmSecondfj.sghkScriptHKList.Name + '_' +
             fmSecondfj.sghkScriptHKList.Cells[1, fmSecondfj.sghkScriptHKList.Row];
        4: Nm := fmSecondfj.sghkScriptHKList.Name + '_Pause_' +
             fmSecondfj.sghkScriptHKList.Cells[1, fmSecondfj.sghkScriptHKList.Row];
      end;
      Delete(Nm, 1, 2);
    end;
    { связанный флажок: если он снят -- строка списка помечается пробелом,
      если стоит -- вызывается обработчик, как при ручном щелчке }
    if (TObject(fld_14E0) is TCheckBox) or (TObject(fld_14E0) is TSpeedButton) then
    begin
      if (fmSecondfj.FindComponent('cb' + Nm) as TCheckBox).Checked then
        (fmSecondfj.FindComponent('cb' + Nm) as TCheckBox).Checked := False
      else
        fmSecondfj.cbhk1Click(fmSecondfj.FindComponent('cb' + Nm) as TCheckBox);
    end
    else
    begin
      if fmSecondfj.sghkScriptHKList.Cells[gHKSela,
           fmSecondfj.sghkScriptHKList.Row] = 'X' then
        fmSecondfj.sghkScriptHKList.Cells[gHKSela,
          fmSecondfj.sghkScriptHKList.Row] := ' ';
      fmSecondfj.cbhk1Click(fmSecondfj.sghkScriptHKList);
    end;
    gHKEntrieslw[N - 1].Mods := Mods;
    gHKEntrieslw[N - 1].Text := cbHKList.Text;
    gHKEntrieslw[N - 1].Sound := eSoundFileSelect.Text;
    if Found then
      gScriptso3[Idx].HoldKey := cbHotKeyIsHolded.Checked;
    { зеркальный блок: после записи настроек флажок включается обратно }
    if (TObject(fld_14E0) is TCheckBox) or (TObject(fld_14E0) is TSpeedButton) then
    begin
      if not (fmSecondfj.FindComponent('cb' + Nm) as TCheckBox).Checked then
        (fmSecondfj.FindComponent('cb' + Nm) as TCheckBox).Checked := True
      else
        fmSecondfj.cbhk1Click(fmSecondfj.FindComponent('cb' + Nm) as TCheckBox);
    end
    else
    begin
      if fmSecondfj.sghkScriptHKList.Cells[gHKSela,
           fmSecondfj.sghkScriptHKList.Row] <> 'X' then
        fmSecondfj.sghkScriptHKList.Cells[gHKSela,
          fmSecondfj.sghkScriptHKList.Row] := 'X';
      fmSecondfj.cbhk1Click(fmSecondfj.sghkScriptHKList);
    end;
  end;
end;

procedure TfmSecond.HelpMemoWndProc(var Message: TMessage);
begin
  { перехват Ctrl+C в окне лога: копируем выделение своей функцией, которая
    кладёт в буфер обмена с правильной раскладкой, и гасим сообщение }
  if Message.Msg = WM_COPY then
  begin
    Message.Msg := 0;
    SetClipboardText(Clipboard, mLog.SelText);
  end;
  gOldLogProc(Message);
end;

procedure TfmSecond.HelpMemoWndProc2(var Message: TMessage);
begin
  { близнец HelpMemoWndProc, но для мемо истории (fld_1430) и своего
    старого обработчика gOldHelpProc2 }
  if Message.Msg = WM_COPY then
  begin
    Message.Msg := 0;
    SetClipboardText(Clipboard, TMemo(fld_1430).SelText);
  end;
  gOldHelpProc2(Message);
end;

procedure TfmSecond.CharParamsWndProc(var Message: TMessage);
begin
  { трюк с WS_EX_APPWINDOW: при сворачивании окно должно появиться в панели
    задач, при разворачивании -- снова исчезнуть; стиль меняется на скрытом
    окне, поэтому вокруг ShowWindow(SW_HIDE)/ShowWindow(SW_SHOW) }
  if Message.Msg = WM_SYSCOMMAND then
    case Message.WParam of
      SC_MINIMIZE:
        begin
          ShowWindow(gDlg5966F0.Handle, SW_HIDE);
          SetWindowLong(gDlg5966F0.Handle, GWL_EXSTYLE,
            GetWindowLong(gDlg5966F0.Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
          ShowWindow(gDlg5966F0.Handle, SW_SHOW);
        end;
      SC_MAXIMIZE, SC_RESTORE:
        begin
          ShowWindow(gDlg5966F0.Handle, SW_HIDE);
          SetWindowLong(gDlg5966F0.Handle, GWL_EXSTYLE,
            GetWindowLong(gDlg5966F0.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW);
          ShowWindow(gDlg5966F0.Handle, SW_SHOW);
        end;
    end;
  gOldCPProc(Message);
end;

procedure TfmSecond.Timer2Timer(Sender: TObject);
begin
end;

procedure TfmSecond.Panel1Click(Sender: TObject);
begin
end;

procedure TfmSecond.miUOPilotWikiClick(Sender: TObject);
var
  Url: PChar;
begin
  Url := 'https://uopilot.uokit.com/wiki/';
  if Integer(ShellExecute(0, 'open', Url, nil, nil, SW_SHOWNORMAL)) <= 32 then
    Application.MessageBox(Url, 'Error launch link', 0);
end;

procedure TfmSecond.miSaveScriptTemplateClick(Sender: TObject);
var
  Sect: string;
  Ini: TMyMemIniFile;
  I: Integer;
begin
{$I-}
  { Сохраняет текущий скрипт как шаблон: каждая строка уходит в ini
    отдельным ключом lineN, в кавычках -- чтобы не терялись пробелы. }
  Ini := TMyMemIniFile.Create(FOptionsFile);
  Sect := 'ScriptTemplate';
  Ini.EraseSection(Sect);
  for I := 0 to edScript.Lines.Count - 1 do
    Ini.WriteString(Sect, 'line' + IntToStr(I),
      '"' + edScript.Lines[I] + '"');
  Ini.Free;
  gTemplateLines.Assign(edScript.Lines);
{$I+}
end;

procedure TfmSecond.miTabRenameClick(Sender: TObject);
begin
  gFlag596A5C := tScript.IndexOfTabAt(gMouseX, gMouseY);
  gStr596A60 := tScript.Tabs[gFlag596A5C];
  lTabRename.Caption := gStr596A60 + ' ->';
  seTagRename.Value := StrToInt(gStr596A60);
  pTabRename.Visible := True;
end;

procedure TfmSecond.bTagRenameCancelClick(Sender: TObject);
begin
  gFlag596A5C := -1;
  gStr596A60 := '';
  pTabRename.Visible := False;
end;

procedure TfmSecond.bTagRenameOkClick(Sender: TObject);
var
  NewIndex: Integer;
  OldIndex: Integer;
  Allow: Boolean;
  I: Integer;
begin
  Allow := True;

  NewIndex := seTagRename.Value;

  { имя вкладки не изменилось }
  if IntToStr(NewIndex) = gStr596A60 then
    Exit;

  { вкладка с таким именем уже есть }
  if tScript.Tabs.IndexOf(IntToStr(NewIndex)) >= 0 then
    Exit;

  pTabRename.Visible := False;

  if tScript.TabIndex = gFlag596A5C then
    tScriptChanging(Sender, Allow);

  OldIndex := StrToInt(gStr596A60);

  tScript.Tabs[gFlag596A5C] := IntToStr(NewIndex);

  { скрипт переезжает на новый номер, старый слот освобождается }
  gScriptso3[NewIndex] := gScriptso3[OldIndex];
  gScriptso3[NewIndex].Name := IntToStr(NewIndex);
  gScriptso3[OldIndex] := nil;

  for I := 0 to sghkScriptHKList.RowCount - 1 do
  begin
    if sghkScriptHKList.Cells[1, I] = IntToStr(OldIndex) then
    begin
      sghkScriptHKList.Cells[1, I] := IntToStr(NewIndex);
      Break;
    end;
  end;

  if tScript.TabIndex = gFlag596A5C then
    tScriptChange(Sender);
end;

procedure TfmSecond.PluginSampleFormClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  miPluginSampleClick(Sender);
end;

procedure TfmSecond.HelpFormClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  mmHelpClick(Sender);
end;

procedure TfmSecond.ScriptHelpFormClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  miScriptHelpClick(Sender);
end;

procedure TfmSecond.AboutFormClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  miAboutClick(Sender);
end;

procedure TfmSecond.LogWindowClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  miLogWindowClick(Sender);
end;

procedure TfmSecond.ShipControlClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  sbSControlClick(Sender);
end;

procedure TfmSecond.HouseControlClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  sbHouseControlClick(Sender);
end;

procedure TfmSecond.AnimalControlClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  sbAnimalControlClick(Sender);
end;

procedure TfmSecond.CharParamsCloseQuery(Sender: TObject;
      var CanClose: Boolean);
begin
  CanClose := False;
  fmSecondfj.sbCharParamsClick(Sender);
end;

procedure TfmSecond.sbCancelClick(Sender: TObject);
begin
  gDlg596700.Close;
end;

procedure TfmSecond.HotKeyListClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  sbEditHKClick(Sender);
end;

procedure TfmSecond.OptionsFormClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  miOptionsClick(Sender);
end;

procedure TfmSecond.DetachedPanelClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  gDlg596708.Visible := False;
end;

procedure TfmSecond.SelServerClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  gDlg59670C.Visible := False;
end;

procedure TfmSecond.MacroOptionsClose(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  gDlg596710.Visible := False;
end;

procedure TfmSecond.AppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  { TheRecorder -- переменная чужого юнита. $4B -- номер сообщения,
    которым запись сообщает о нажатии клавиши прерывания. }
  if (Msg.message = $4B) and (TheRecorder.State = rsPlaying) then
  begin
    TheRecorder.DoStop;
    fmSecondfj.mLog.Lines.Add('Воспроизведение прервано.');
  end;
end;

procedure TfmSecond.bOptionsCloseClick(Sender: TObject);
begin
  miOptionsClick(Sender);
end;

procedure TfmSecond.miOptionsClick(Sender: TObject);
begin
  { Панель настроек живёт на отдельном окне, которое создаётся при первом
    показе и потом только прячется/показывается. }
  if gDlg596704 = nil then
  begin
    gDlg596704 := TForm.Create(fmSecondfj);
    gDlg596704.Parent := nil;
    gDlg596704.BorderStyle := bsToolWindow;
    gDlg596704.FormStyle := fsStayOnTop;
    gDlg596704.Caption := 'Options';
    gDlg596704.Position := poScreenCenter;
    gDlg596704.AutoSize := True;
    gDlg596704.OnCloseQuery := OptionsFormClose;
    gDlg596704.OnKeyPress := FormsKeyPress;
    gDlg596704.KeyPreview := True;
    pOptions.Parent := gDlg596704;
    pOptions.Visible := True;
    pOptions.Left := 0;
    pOptions.Top := 0;
  end;
  gDlg596704.Visible := not gDlg596704.Visible;
  if gDlg596704.Visible then
    PageControl1.Pages[0].TabVisible := not cbHideUOSettings.Checked;
end;

procedure TfmSecond.tcLogChanging(Sender: TObject; var AllowChange: Boolean);
var
  I: Integer;
begin
  if tcLog.TabIndex > 0 then
  begin
    I := StrToInt(tcLog.Tabs[tcLog.TabIndex]);
    gScriptso3[I].LogView.Visible := False;
  end
  else
    mLog.Visible := False;
end;

procedure TfmSecond.tcLogChange(Sender: TObject);
var
  I: Integer;
begin
  if tcLog.TabIndex > 0 then
  begin
    I := StrToInt(tcLog.Tabs[tcLog.TabIndex]);
    gScriptso3[I].LogView.Visible := True;
    gScriptso3[I].LogView.SelStart := Length(gScriptso3[I].LogView.Text);
    gScriptso3[I].LogView.Perform($B7, 0, 0);
  end
  else
  begin
    mLog.Visible := True;
    mLog.SelStart := Length(mLog.Text);
    mLog.Perform($B7, 0, 0);
  end;
end;

procedure TfmSecond.miStartStopCurrentScriptClick(Sender: TObject);
begin
  btStart.Down := not btStart.Down;
  btStartClick(Sender);
end;

procedure TfmSecond.EoffNameChange(Sender: TObject);
var
  I: Integer;
  P: PInteger;
begin
  { 27 таблиц адресов памяти клиента, по 25 версий в каждой. Индекс 23 --
    пользовательская строка «свой клиент», её и правит этот спин-эдит. }
  if (Sender as TSpinEdit).Value < 0 then
    (Sender as TSpinEdit).Value := 0;
  I := $17;
  P := @ClientAddr[0, I];
  case (Sender as TSpinEdit).Tag of
    1: P := @ClientAddr[0, I];
    2: P := @ClientAddr[1, I];
    3: P := @ClientAddr[2, I];
    4: P := @ClientAddr[3, I];
    5: P := @ClientAddr[7, I];
    6: P := @ClientAddr[8, I];
    7: P := @ClientAddr[9, I];
    8: P := @ClientAddr[10, I];
    9: P := @ClientAddr[12, I];
    10: P := @ClientAddr[13, I];
    11: P := @ClientAddr[14, I];
    12: P := @ClientAddr[15, I];
    13: P := @ClientAddr[16, I];
    14: P := @ClientAddr[17, I];
    15: P := @ClientAddr[18, I];
    16: P := @ClientAddr2[1, I];
    17: P := @ClientAddr2[2, I];
    18: P := @ClientAddr2[4, I];
    19: P := @ClientAddr[4, I];
    20: P := @ClientAddr[5, I];
    21: P := @ClientAddr[11, I];
    22: P := @ClientAddr[19, I];
    23: P := @ClientAddr[21, I];
    24: P := @ClientAddr[22, I];
    25: P := @ClientAddr2[3, I];
    26: P := @ClientAddr2[6, I];
  end;
  try
    P^ := (Sender as TSpinEdit).Value;
  except
  end;
end;

procedure TfmSecond.sbLMFindClick(Sender: TObject);
var
  Addr: Cardinal;
  Read: DWORD;
  S: string;
  Ph: THandle;
  Pid: DWORD;
  N: Cardinal;
  Buf: array[0..$FF] of Char;
  I: Integer;
  Cur: Integer;
  Wnd: HWND;
  P: PChar;
begin
  { Поиск адреса последнего сообщения: по цепочке из двух указателей
    читается 32 байта текста. }
  if fmSecondfj.FTargetWnd = 0 then
  begin
    Wnd := FindWindow('Ultima Online', nil);
    GetWindowThreadProcessId(Wnd, @Pid);
    Ph := OpenProcess($10, False, Pid);
  end
  else
    Ph := fmSecondfj.FClientProcess;
  if Ph <> 0 then
  begin
    N := 0;
    Addr := EoffLMess.Value;
    sLM.Visible := True;
    sLM.Value := Addr;
    FFlag14ED := False;
    sbStopSearchClient.Enabled := True;
    Cur := sLM.Value;
    while Pos(eLM.Text, S) = 0 do
    begin
      Addr := Cur;
      ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Read);
      if Read = 4 then
      begin
        ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Read);
        if Read = 4 then
          ReadProcessMemory(Ph, Pointer(Addr), @Buf, $20, Read)
        else
          Read := 0;
      end
      else
        Read := 0;
      if Read = $20 then
      begin
        Buf[$20] := #0;
        I := 0;
        S := '';
        if Buf[1] <> #0 then
          while Buf[I] <> #0 do
          begin
            S := S + Buf[I];
            Inc(I);
          end
        else
          begin
            P := @Buf[0];
  S := WideCharToString(PWideChar(P));
          end;
      end
      else
        S := 'err';
      Inc(Cur);
      sLM.Value := Cur;
      Inc(N);
      if N > $2710 then
      begin
        N := 0;
        Application.ProcessMessages;
      end;
      if FFlag14ED then
        Break;
    end;
    sbStopSearchClient.Enabled := False;
    sLM.Visible := False;
    EoffLMess.Value := sLM.Value - 1;
  end;
end;

procedure TfmSecond.sbCPFindClick(Sender: TObject);
label
  zCPBody, zCPCond, zCPDone;
var
  Addr: Cardinal;
  Read: DWORD;
  Value: Cardinal;
  Target: Cardinal;
  Pid: DWORD;
  Tmp: Cardinal;
  Ver: Integer;
  Ph: THandle;
  I: Integer;
  N: Cardinal;
  Wnd: HWND;
begin
  if fmSecondfj.FTargetWnd = 0 then
  begin
    Wnd := FindWindow('Ultima Online', nil);
    GetWindowThreadProcessId(Wnd, @Pid);
    Ph := OpenProcess($10, False, Pid);
  end
  else
    Ph := fmSecondfj.FClientProcess;
  if Ph <> 0 then
  begin
    Addr := EoffCP.Value;
    sCP.Visible := True;
    sCP.Value := Addr;
    Value := 0;
    Target := sCPGold.Value;
    N := 0;
    I := sCP.Value;
    case cbCustomClVer.ItemIndex of
      0: Ver := $10;
      1: Ver := 1;
      2: Ver := 2;
      3: Ver := 7;
      4: Ver := 3;
      5: Ver := 5;
      6: Ver := 6;
    else
      Ver := 0;
    end;
    ClientAddr[6, cbClVer.ItemIndex] := Ver;
    FFlag14ED := False;
    sbStopSearchClient.Enabled := True;
    goto zCPCond;
zCPBody:
      Addr := I;
      ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Read);
      { Второй разыменовыватель нужен только версии 1 -- он внутри if. }
      if Ver = 1 then
      begin
        Addr := Addr + $8C;
        ReadProcessMemory(Ph, Pointer(Addr), @Addr, 4, Read);
      end;
      if Addr < $FFFFF000 then
      begin
        Addr := Addr + $34;
        case Ver of
          4, 5: Addr := Addr + $C4;
        else
          begin
            if Ver = 7 then
              Addr := Addr + 8;
            Addr := Addr + $A4;
          end;
        end;
        ReadProcessMemory(Ph, Pointer(Addr), @Tmp, 4, Read);
        if Read = 4 then
          Value := Tmp
        else
          Value := 0;
      end;
      Inc(I);
      sCP.Value := I;
      Inc(N);
      if N > $2710 then
      begin
        N := 0;
        Application.ProcessMessages;
      end;
    if FFlag14ED then
      goto zCPDone;
zCPCond:
    if Target <> Value then
      goto zCPBody;
zCPDone:
    sbStopSearchClient.Enabled := False;
    sCP.Visible := False;
    EoffCP.Value := sCP.Value - 1;
  end;
  N := N;
  I := I;
end;

procedure TfmSecond.cbCustomClVerChange(Sender: TObject);
var
  P: PInteger;
  V: Integer;
begin
  P := @ClientAddr[6, 23];
  case cbCustomClVer.ItemIndex of
    0: V := $10;
    1: V := 1;
    2: V := 2;
    3: V := 7;
    4: V := 3;
    5: V := 5;
    6: V := 6;
  else
    V := 0;
  end;
  P^ := V;
end;

procedure TfmSecond.sbReloadClick(Sender: TObject);
var
  L: TStringList;
  Msg: string;
  Line: string;
  S: string;
  I: Integer;
  Row: Integer;
  P: Integer;
begin
  { Перечитывает login.cfg рядом с клиентом в таблицу: строки с ключом
    LoginServer разбираются на адрес, порт и комментарий; закомментированные
    (ключ не в начале строки) помечаются 'X' в нулевой колонке. }
  if eUOpath.Text = '' then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $190)), 'UOPilot Error Message', 0)
    else
      MsgBox('Введите путь к UO и нажмите кнопку Reload',
        'UOPilot Error Message', 0);
    Exit;
  end;
  S := eUOpath.Text;
  if S[Length(S)] <> '\' then
    S := S + '\';
  S := S + 'login.cfg';
  L := TStringList.Create;
  try
    L.LoadFromFile(S);
  except
  end;
  if L.Count < 1 then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      Msg := LoadStr(gLangOffsety + $191) + Copy(S, Length(S) - 8, 9) +
             LoadStr(gLangOffsety + $192) + Copy(S, 1, Length(S) - 9)
    else
      Msg := 'Файл ' + Copy(S, Length(S) - 8, 9) + ' не найден в ' +
             Copy(S, 1, Length(S) - 9);
    MsgBox(PChar(Msg), 'UOPilot Error Message', 0);
    L.Free;
    Exit;
  end;
  Msg := 'LoginServer';
  Row := 0;
  for I := 0 to L.Count - 1 do
  begin
    Line := L[I];
    P := Pos(AnsiLowerCase(Msg), AnsiLowerCase(Line));
    if P <> 0 then
    begin
      Inc(Row);
      sgLoginLine.RowCount := Row + 1;
      if P = 1 then
        sgLoginLine.Cells[0, Row] := 'X'
      else
        sgLoginLine.Cells[0, Row] := '';
      Delete(Line, 1, P + 11);
      P := Pos(',', Line);
      sgLoginLine.Cells[1, Row] := Copy(Line, 1, P - 1);
      Delete(Line, 1, P);
      P := Pos('//', Line);
      if P <> 0 then
      begin
        sgLoginLine.Cells[2, Row] := Copy(Line, 1, P - 1);
        sgLoginLine.Cells[3, Row] := Copy(Line, P + 2, Length(Line));
      end
      else
      begin
        sgLoginLine.Cells[2, Row] := Copy(Line, 1, Length(Line));
        sgLoginLine.Cells[3, Row] := '';
      end;
      Line := sgLoginLine.Cells[2, Row];
      while Length(Line) > 0 do
        if Line[1] in ['0'..'9'] then
          Break
        else
          Delete(Line, 1, 1);
      while Length(Line) > 0 do
        if Line[Length(Line)] in ['0'..'9'] then
          Break
        else
          Delete(Line, Length(Line), 1);
      sgLoginLine.Cells[2, Row] := Line;
      try
        StrToInt(sgLoginLine.Cells[2, Row]);
      except
        { непарсящийся порт -- строка выбрасывается }
        Dec(Row);
        sgLoginLine.RowCount := Row + 1;
      end;
    end;
  end;
  if Row < 1 then
  begin
    sgLoginLine.RowCount := 2;
    sgLoginLine.Cells[1, 1] := '';
    sgLoginLine.Cells[2, 1] := '';
    sgLoginLine.Cells[3, 1] := '';
  end;
  sgLoginLine.FixedRows := 1;
  if gLangOffsety > 0 then
  begin
    sgLoginLine.Cells[1, 0] := LoadStr(gLangOffsety + $193);
    sgLoginLine.Cells[2, 0] := LoadStr(gLangOffsety + $194);
    sgLoginLine.Cells[3, 0] := LoadStr(gLangOffsety + $195);
  end
  else
  begin
    sgLoginLine.Cells[1, 0] := 'Адрес';
    sgLoginLine.Cells[2, 0] := 'Порт';
    sgLoginLine.Cells[3, 0] := 'Коментарий';
  end;
  L.Free;
end;

procedure TfmSecond.sgLoginLineMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  C, R: Integer;
  S: string;
begin
  if gFlag596521 then
    gFlag596521 := False
  else
  begin
    sgLoginLine.MouseToCell(X, Y, C, R);
    if (C = 0) and (R > 0) then
    begin
      S := sgLoginLine.Cells[C, R];
      if S = '' then
        sgLoginLine.Cells[C, R] := 'X'
      else
        sgLoginLine.Cells[C, R] := '';
    end;
  end;
end;

procedure TfmSecond.sbSaveLLClick(Sender: TObject);
var
  L: TStringList;
  S: string;
  I: Integer;
  Key: string[255];
  Line: string[255];
begin
  { Пишет login.cfg рядом с клиентом: по строке на каждую запись таблицы,
    закомментированные (пустая нулевая колонка) -- с точкой с запятой. }
  if eUOpath.Text = '' then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $196)), 'UOPilot Error Message', 0)
    else
      MsgBox('Введите путь к UO и нажмите кнопку Reload',
        'UOPilot Error Message', 0);
  end
  else
  begin
    S := eUOpath.Text;
    if S[Length(S)] <> '\' then
      S := S + '\';
    S := S + 'login.cfg';
    L := TStringList.Create;
    Key := 'LoginServer';
    for I := 0 to sgLoginLine.RowCount - 1 - 1 do
    begin
      try
        StrToInt(sgLoginLine.Cells[2, I + 1]);
      except
        Continue;
      end;
      Line := Key + '=' + sgLoginLine.Cells[1, I + 1] + ',' +
        sgLoginLine.Cells[2, I + 1];
      if sgLoginLine.Cells[3, I + 1] <> '' then
        Line := Line + ' //' + sgLoginLine.Cells[3, I + 1];
      if sgLoginLine.Cells[0, I + 1] = '' then
        Line := ';' + Line;
      L.Add(Line);
    end;
    try
      L.SaveToFile(S);
    except
        SetForegroundWindow(Application.Handle);
        if gLangOffsety > 0 then
          MsgBox(PChar(LoadStr(gLangOffsety + $197)),
            'UOPilot Error Message', 0)
        else
          MsgBox(PChar('Не удалось записать изменения в файл ' + S),
            'UOPilot Error Message', 0);
    end;
    L.Free;
  end;
end;

procedure TfmSecond.sbAddLineClick(Sender: TObject);
begin
  sgLoginLine.RowCount := sgLoginLine.RowCount + 1;
end;

procedure TfmSecond.sgLoginLineRowMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  gFlag596521 := True;
end;

procedure TfmSecond.sbCloseClick(Sender: TObject);
begin
  gDlg59670C.Visible := False;
end;

procedure TfmSecond.sbmoOkClick(Sender: TObject);
var
  W: Integer;
  S1, S2: string;
  L1, L2, L3: string;
  T1, T2, T3, T4: string;
begin
  { Сохраняет макрос мыши: имя кнопки, пауза, флаг Enter и три строки текста.
    Имя урезается по ширине, пока не влезет в шаблон '          -         '. }
  gMouseMacros[gMacroIndex].Enter := cbmoEnter.Checked;
  gMouseMacros[gMacroIndex].Name := emoButName.Text;
  gMouseMacros[gMacroIndex].Pause := edmoPause.Text;
  W := Canvas.TextWidth('          -         ');
  while Canvas.TextWidth(gMouseMacros[gMacroIndex].Name) > W do
    gMouseMacros[gMacroIndex].Name :=
      Copy(gMouseMacros[gMacroIndex].Name, 1,
        Length(gMouseMacros[gMacroIndex].Name) - 1);
  gMouseMacros[gMacroIndex].Lines[1] := mmoText.Lines[0];
  gMouseMacros[gMacroIndex].Lines[2] := mmoText.Lines[1];
  gMouseMacros[gMacroIndex].Lines[3] := mmoText.Lines[2];
  mmoText.Clear;
  gDlg596710.Hide;
  if gMouseMacros[gMacroIndex].Name <> '' then
    (FindComponent('tb' + IntToStr(gMacroIndex)) as TToolButton).Caption :=
      gMouseMacros[gMacroIndex].Name
  else
    (FindComponent('tb' + IntToStr(gMacroIndex)) as TToolButton).Caption :=
      '          -         ';
end;

procedure TfmSecond.sbmoCancelClick(Sender: TObject);
begin
  gDlg596710.Hide;
end;

procedure TfmSecond.sbehOkClick(Sender: TObject);
begin
  gHouseCmds[gDlg596714.Tag] := eehEditHouseCommands.Text;
  gDlg596714.Hide;
end;

procedure TfmSecond.tb1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  S: string;
  A, B, C: string;
  P: TPanel;
begin
  if Button = mbRight then
  begin
    gMacroIndex := StrToInt(Copy((Sender as TToolButton).Name, 3, 2));
    if gDlg596710 = nil then
    begin
      gDlg596710 := TForm.Create(fmSecondfj);
      gDlg596710.Parent := nil;
      gDlg596710.BorderStyle := bsSizeToolWin;
      gDlg596710.ClientHeight := fmSecondfj.pMakroOptions.Height;
      gDlg596710.ClientWidth := fmSecondfj.pMakroOptions.Width;
      gDlg596710.Caption := fmSecondfj.pMakroOptions.Hint;
      gDlg596710.OnCloseQuery := fmSecondfj.MacroOptionsClose;
      P := fmSecondfj.pMakroOptions;
      P.Parent := gDlg596710;
      P.Left := 0;
      P.Top := 0;
      P.Align := alClient;
      P.Visible := True;
    end;
    gDlg596710.Visible := True;
    fmSecondfj.cbmoEnter.Checked := gMouseMacros[gMacroIndex].Enter;
    fmSecondfj.edmoPause.Text := gMouseMacros[gMacroIndex].Pause;
    fmSecondfj.emoButName.Text := gMouseMacros[gMacroIndex].Name;
    fmSecondfj.mmoText.Clear;
    fmSecondfj.mmoText.Lines.Add(gMouseMacros[gMacroIndex].Lines[1]);
    fmSecondfj.mmoText.Lines.Add(gMouseMacros[gMacroIndex].Lines[2]);
    fmSecondfj.mmoText.Lines.Add(gMouseMacros[gMacroIndex].Lines[3]);
    fmSecondfj.mmoText.SelStart := 0;
    fmSecondfj.mmoText.SelLength := 0;
  end;
end;

procedure MacroSendLine(S: string);
var
  Old: string;
  Buf: array[0..255] of Char;
  I: Integer;
begin
  // Одна строка макроса мыши уходит в окно клиента посимвольно.
  // Раскладка на время отправки переключается на gKbdLayoutow, после -- на
  // '00000409' (US), причём условие возврата то же самое, что и на входе.
  GetKeyboardLayoutName(Buf);
  Old := Buf;
  if Old <> gKbdLayoutow then
    LoadKeyboardLayout(StrCopy(Buf, PChar(gKbdLayoutow)), 1);
  for I := 1 to Length(S) do
    PostMessage(gMacroWnd, WM_CHAR, Ord(S[I]),
      MapVirtualKey(Byte(S[I]), 0) shl 16 + $C0000001);
  if fmSecondfj.cbmoEnter.Checked then
    PostMessage(gMacroWnd, WM_CHAR, 13, 0);
  if Old <> gKbdLayoutow then
    LoadKeyboardLayout(StrCopy(Buf, '00000409'), 1);
end;

procedure MacroPause(S: string);
var
  T: DWORD;
  N: Cardinal;
begin
  // Пауза между строками макроса. Число берётся StrToInt, а
  // если строка кончается буквой -- разбор идёт через ИСКЛЮЧЕНИЕ: в except
  // читается суффикс S/M/H, множитель, хвост отрезается и число умножается.
  // Ветка else намеренно зовёт StrToInt('error') -- второе исключение.
  if S = '' then
    Exit;
  if S = '0' then
    Exit;
  T := GetTickCount;
  try
    N := StrToInt(S);
  except
    case UpCase(S[Length(S)]) of
      'S': N := 1000;
      'M': N := 60000;
      'H': N := 3600000;
    else
      N := StrToInt('error');
    end;
    Delete(S, Length(S), 1);
    N := StrToInt(S) * N;
  end;
  repeat
    Application.ProcessMessages;
  until GetTickCount - T >= N;
end;

procedure TfmSecond.tb1Click(Sender: TObject);
var
  S: string;
  I: Integer;
  J: Integer;
begin
  { Кнопка макроса мыши: номер берётся из её имени (bmoNN), строки макроса
    отправляются в окно клиента одна за другой с паузой между ними. }
  gMacroWnd := gScriptso3[StrToInt(fmSecondfj.tScript.Tabs[fmSecondfj.tScript.TabIndex])].ClientWnd;
  if gMacroWnd = 0 then
  begin
    SetForegroundWindow(Application.Handle);
    if gLangOffsety > 0 then
      MsgBox(PChar(LoadStr(gLangOffsety + $1D6)), 'UOPilot Error Message', 0)
    else
      MsgBox('UO not found', 'UOPilot Error Message', 0);
  end
  else
  begin
    I := StrToInt(Copy((Sender as TToolButton).Name, 3, 2));
    S := '';
    for J := 1 to 3 do
      if gMouseMacros[I].Lines[J] <> '' then
      begin
        if J > 1 then
          MacroPause(fmSecondfj.edmoPause.Text);
        MacroSendLine(gMouseMacros[I].Lines[J]);
      end;
    SetForegroundWindow(gMacroWnd);
    Windows.SetFocus(gMacroWnd);
  end;
end;

procedure TfmSecond.ToolBar1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(gDlg596718) then
  begin
    gCount59AD80 := 10;
    gDlg596718.Height := 22;
    tmTimer1.Enabled := True;
  end;
end;

procedure TfmSecond.tmTimer1Timer(Sender: TObject);
begin
  Dec(gCount59AD80);
  if gCount59AD80 <= 0 then
  begin
    tmTimer1.Enabled := False;
    gDlg596718.ClientHeight := 3;
  end;
end;

procedure TfmSecond.tbmiSpeedChange(Sender: TObject);
var
  P: Integer;
begin
  P := tbmiSpeed.Position;
  if P > 8 then
    TheRecorder.SpeedFactor := 100 div SpeedTableaah[P]
  else if P < 8 then
    TheRecorder.SpeedFactor := Abs(SpeedTableaah[P]) * 100
  else
    TheRecorder.SpeedFactor := 100;
end;

procedure TfmSecond.semiRepeatChange(Sender: TObject);
var
  V: Integer;
begin
  if TryStrToInt(semiRepeat.Text, V) then
  begin
    if N20.Checked then
      gPlayCount := $309
    else
      gPlayCount := semiRepeat.Value;
    TheRecorder.FRepeatCount := gPlayCount;
  end;
end;

procedure TfmSecond.N20Click(Sender: TObject);
begin
  semiRepeat.Enabled := not N20.Checked;
  semiRepeatChange(Sender);
end;

procedure TfmSecond.HotKeyEnableAllHotKeys(Sender: TObject);
begin
  cbEnableHK.Checked := not cbEnableHK.Checked;
end;

procedure TfmSecond.sbehCancelClick(Sender: TObject);
begin
  gDlg596714.Hide;
end;

procedure TfmSecond.HotKeyEnableKeyboard(Sender: TObject);
begin
  UnhookHookB;
  UnhookHookA;
end;

procedure TfmSecond.sbSoundFileSelectClick(Sender: TObject);
var
  D: TOpenDialog;
begin
  { Диалог не освобождается: владелец -- fmSecondfj, и он же его снесёт. }
  D := TOpenDialog.Create(fmSecondfj);
  D.Filter := 'Sound files (*.wav)|*.wav';
  D.FilterIndex := 1;
  D.DefaultExt := '.wav';
  D.Options := [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist,
    ofFileMustExist];
  D.InitialDir := ExtractFilePath(eSoundFileSelect.Text);
  D.FileName := ExtractFileName(eSoundFileSelect.Text);
  if D.Execute then
    eSoundFileSelect.Text := D.FileName;
end;

procedure TfmSecond.btColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    edScript.SelText := '0x' + IntToHex(StrToInt(btColor.Caption), 8) + ' ';
    if edScript.Visible and edScript.Enabled then
      edScript.SetFocus;
  end;
end;

procedure TfmSecond.cbLoggingCommandsClick(Sender: TObject);
var
  I: Integer;
begin
  I := StrToInt(tScript.Tabs[tScript.TabIndex]);
  gScriptso3[I].LoggingCommands := cbLoggingCommands.Checked;
end;

procedure TfmSecond.sbScriptProcessingClick(Sender: TObject);
begin
  miShowScriptProcessing.Checked := sbScriptProcessing.Down;
  miShowTimerVar.Checked := sbScriptProcessing.Down;
end;

procedure TfmSecond.SpeedButton3Click(Sender: TObject);
begin
  gDlg59671Ct7.Visible := not gDlg59671Ct7.Visible;
end;

procedure TfmSecond.sbStopSearchClientClick(Sender: TObject);
begin
  FFlag14ED := True;
end;

procedure TfmSecond.cbHideUOSettingsClick(Sender: TObject);
var
  V: Boolean;
begin
  V := not cbHideUOSettings.Checked;
  { Вкладка UO прячется только когда окно настроек открыто: иначе PageControl1
    ещё не показан и менять TabVisible нечему. }
  if (Assigned(gDlg596704)) and gDlg596704.Visible then
    PageControl1.Pages[0].TabVisible := V;
  miUltimaOnline.Visible := V;
  gbUltimaOnline.Visible := V;
  miSOTShipControl.Visible := V;
  miSOTHouseControl.Visible := V;
  miSOTAnimalVendor.Visible := V;
  miSPosHC.Visible := V;
  miSPosSC.Visible := V;
  miSPosAC.Visible := V;
  gbGM.Visible := V;
  gbStartLoginUO.Visible := V;
  sbSControl.Visible := V;
  sbHouseControl.Visible := V;
  sbAnimalControl.Visible := V;
  Label1.Visible := V;
  cbClVer.Visible := V;
  sbCFCP1.Visible := V;
  sbCFCP2.Visible := V;
  sbCFCP3.Visible := V;
  sbCFCP4.Visible := V;
  sbCFCP5.Visible := V;
  sbCFCP7.Visible := V;
end;

procedure TfmSecond.tScriptDescChange(Sender: TObject);
var
  Allow: Boolean;
begin
  Allow := True;
  tScriptChanging(tScript, Allow);
  tScript.TabIndex := tScriptDesc.TabIndex;
  tScriptChange(tScript);
end;

procedure TfmSecond.cbShowScriptNamesOnTabsClick(Sender: TObject);
begin
  tScriptDesc.Visible := cbShowScriptNamesOnTabs.Checked;
  FormResize(Sender);
end;

procedure TfmSecond.tScriptDescMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  R: TRect;
begin
  I := tScriptDesc.IndexOfTabAt(X, Y);
  if FFlag1464 and (I >= 0) then
  begin
    R := tScriptDesc.TabRect(I);
    if (Y >= R.Bottom - 6) and (Y <= R.Bottom) then
      FFlag1467 := False
    else
      FFlag1467 := True;
  end;
end;

procedure TfmSecond.FormsKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = 27 then
    (Sender as TForm).Close;
end;

procedure TfmSecond.CheckBox1Click(Sender: TObject);
begin
  edScript.CodeFolding.CollapsingMarkStyle := msSquare;
  edScript.CodeFolding.CollapsedCodeHint := True;
  edScript.CodeFolding.ShowCollapsedLine := True;
  edScript.CodeFolding.IndentGuides := False;
  edScript.CodeFolding.FolderBarColor := $20000000;
  edScript.CodeFolding.HighlighterFoldRegions := False;
  edScript.CodeFolding.FoldRegions.Add(rtChar, False, False, True, '{', '}');
  edScript.CodeFolding.FoldRegions.Add(rtKeyword, False, False, True,
    'for', 'end_for');
  edScript.InitCodeFolding;
  edScript.CodeFolding.Enabled := CheckBox1.Checked;
end;

procedure TfmSecond.seTabSizeChange(Sender: TObject);
begin
  edScript.TabWidth := seTabSize.Value;
end;

procedure TfmSecond.miFormatClick(Sender: TObject);
var
  Row: Integer;
  Indent: Integer;
  K: Integer;
  S: string;
  Pad: string;
  W: string;
  Head: string;
  Cur: string;
  StartRow, EndRow: Integer;
  Marks: array of TLabelMark;
  Top: Integer;
  I, J, N: Integer;
begin
  { Расстановка отступов в скрипте. Ключевые слова из списка увеличивают или
    уменьшают отступ на seTabSize; метка (строка, начинающаяся с ':')
    запоминается вместе с текущим отступом, а 'return' по ней выравнивает
    хвост процедуры. }
  if not edScript.ReadOnly then
  begin
    Indent := 0;
    SetLength(Marks, 0);
    Top := -1;
    if edScript.SelStart <> edScript.SelEnd then
    begin
      StartRow := edScript.CharIndexToRowCol(edScript.SelStart).Line - 1;
      EndRow := edScript.CharIndexToRowCol(edScript.SelEnd).Line - 1;
      S := edScript.Lines[StartRow];
      I := 0;
      while (Length(S) >= I + 1) and (S[I + 1] in [#9, ' ']) do
        Inc(I);
      if I > 0 then
        Indent := I;
    end
    else
    begin
      StartRow := 0;
      EndRow := edScript.Lines.Count - 1;
    end;
    for Row := StartRow to EndRow do
    begin
      S := edScript.Lines[Row];
      I := 0;
      while (Length(S) >= I + 1) and (S[I + 1] in [#9, ' ']) do
        Inc(I);
      if I > 0 then
        Delete(S, 1, I);
      if S = '' then
        Continue;
      J := 1;
      while (J <= Length(S)) and not (S[J] in [#9, ' ']) do
        Inc(J);
      W := AnsiLowerCase(Copy(S, 1, J - 1));
      if W = 'end_switch' then
        Dec(Indent, seTabSize.Value);
      if (W = 'end_repeat') or (W = 'end_switch') or (W = 'end_if') or
         (W = 'end_while') or (W = 'end_for') or (W = 'end_proc') or
         (W = 'else') or (W = 'case') then
        if Indent > 0 then
          Dec(Indent, seTabSize.Value)
        else if gLangOffsety > 0 then
          MessageBox(fmSecondfj.Handle,
            PChar(LoadStr(gLangOffsety + $204) + ' ' + IntToStr(Row) + '.' + #13 +
                  LoadStr(gLangOffsety + $205)),
            PChar(miFormat.Caption), 0)
        else
          MessageBox(fmSecondfj.Handle,
            PChar('Подозрительный отступ в строке ' + IntToStr(Row) + '.' + #13 +
                  'Где-то лишний "end".'),
            PChar(miFormat.Caption), 0);
      if W = 'if' then
      begin
        Head := Copy(S, 1, J - 1);
        J := 2;
        while (Length(S) >= J + 1) and (S[J + 1] in [#9, ' ']) do
          Inc(J);
        Delete(S, 1, J);
        S := Head + '  ' + S;
      end;
      Pad := '';
      for N := 1 to Indent do
        Pad := Pad + ' ';
      edScript.Lines[Row] := Pad + S;
      if (W = 'repeat') or (W = 'switch') or (W = 'if') or (W = 'if_not') or
         (W = 'while') or (W = 'while_not') or (W = 'for') or (W = 'proc') or
         (W = 'else') or (W = 'case') then
        Inc(Indent, seTabSize.Value);
      if W = 'switch' then
        Inc(Indent, seTabSize.Value);
      if Copy(W, 1, 1) = ':' then
      begin
        Top := Length(Marks);
        SetLength(Marks, Top + 1);
        Marks[Top].Row := Row;
        Marks[Top].Indent := Indent;
      end;
      if W = 'return' then
        if Top >= 0 then
          if Marks[Top].Indent = Indent then
          begin
            { хвост процедуры сдвигается на один уровень внутрь }
            for K := Marks[Top].Row + 1 to Row - 1 do
            begin
              Cur := edScript.Lines[K];
              if Cur <> '' then
              begin
                Pad := '';
                I := seTabSize.Value;
                for N := 1 to I do
                  Pad := Pad + ' ';
                edScript.Lines[K] := Pad + Cur;
              end;
            end;
            SetLength(Marks, Top);
            Dec(Top);
          end;
    end;
  end;
end;

procedure TfmSecond.miUnFormatClick(Sender: TObject);
var
  I: Integer;
  S: string;
  N: Integer;
  StartRow, EndRow: Integer;
begin
  { Снимает ведущие табы и пробелы у выделенных строк, а без выделения --
    у всех. Пустые строки не переписываются. }
  if not edScript.ReadOnly then
  begin
    if edScript.SelStart <> edScript.SelEnd then
    begin
      StartRow := edScript.CharIndexToRowCol(edScript.SelStart).Line - 1;
      EndRow := edScript.CharIndexToRowCol(edScript.SelEnd).Line - 1;
    end
    else
    begin
      StartRow := 0;
      EndRow := edScript.Lines.Count - 1;
    end;
    for I := StartRow to EndRow do
    begin
      S := edScript.Lines[I];
      N := 0;
      while (Length(S) >= N + 1) and (S[N + 1] in [#9, ' ']) do
        Inc(N);
      if N > 0 then
        Delete(S, 1, N);
      if S <> '' then
        edScript.Lines[I] := S;
    end;
  end;
end;

procedure DownloadWikiPage(URL, FileName: string);
var
  Buf: Pointer;
  hNet, hUrl: HINTERNET;
  UA, Hdr: string;
  FS: TFileStream;
  Len: Cardinal;
  Body, Title, Foot, Content, Styles: string;
  N: Integer;
  P: PChar;
  BufSize: Integer;
  K, M: Integer;
begin
  { Качалка страниц вики. WinInet тянет страницу целиком в буфер на $50000,
    из неё вырезается обвязка MediaWiki и остаётся <title> + тело статьи +
    printfooter, обёрнутые в свой html. Ссылки '/wiki/index.php?title=X'
    переписываются в локальные 'X.htm'. При FileName = 'styles' страница
    берётся как таблица стилей и правится подстановкой пробелов; до 10
    повторов, если стилей ещё нет. Вызов рекурсивный: докачивает styles
    по ссылке rel="stylesheet". }
  try
    Buf := nil;
    hNet := nil;
    hUrl := nil;
    BufSize := $50000;
    Hdr := '';
    UA := 'Mozilla/5.001 (windows; U; NT4.0; en-US; rv:1.0) Gecko/25250101';
    try
      GetMem(Buf, BufSize);
      try
        hNet := InternetOpen(PChar(UA), 0, nil, nil, 0);
        if hNet = nil then
          Exit;
        try
          hUrl := InternetOpenUrl(hNet, PChar(URL), PChar(Hdr), Length(Hdr),
            $84000000, 0);
          if hUrl = nil then
            Exit;
          Content := '';
          N := 1;
          repeat
            repeat
              if not InternetReadFile(hUrl, Buf, BufSize, Len) then
                if gLangOffsety > 0 then
                  fmSecondfj.mLog.Lines.Add('-' + LoadStr(gLangOffsety + $20F))
                else
                  fmSecondfj.mLog.Lines.Add('-Не скачался файл.');
              P := Buf;
              Content := Content + Copy(P, 1, Len);
            until Len = 0;
            Len := Length(Content);
            P := PChar(Content);
            if FileName = 'styles' then
            begin
              K := Pos('margin-left:10em;', P);
              if K > 0 then
              begin
                for M := K to K + 12 do
                  P[M] := ' ';
                Break;
              end;
              if N >= 10 then
                Break;
              Inc(N);
            end
            else
            begin
              if not FileExists(gWikiPath + 'styles') then
                Styles := Content;
              K := Pos('noarticletext', P);
              if K <= 0 then
              begin
              Title := '';
              K := Pos('<title>', P);
              M := Pos('</title>', P);
              if (K > 0) and (M > 0) then
                Title := Copy(P, K, M - K + 8);
              K := Pos('<h1 id="firstHeading"', P);
              M := Pos('<div id="mw-navigation"', P);
              if (K <= 0) or (M <= 0) then
                Break;
              Body := Copy(P, K, M - K);
              K := Pos('<div class="printfooter">', Body);
              M := PosEx('</div>', Body, K);
              if (K > 0) and (M > 0) then
              begin
                Foot := Copy(Body, K, M - K + 6);
                Delete(Body, K, M - K + 6);
              end;
              K := Pos('<table', Body);
              M := Pos('</table>', Body);
              if (K > 0) and (M > 0) then
                Delete(Body, K, M - K + 8);
              K := Pos('<div', Body);
              M := Pos('<h2><span', Body);
              if (K > 0) and (M > 0) then
                Delete(Body, K, M - K);
              K := Pos('"/wiki/index.php?title=', Body);
              while K > 0 do
              begin
                Delete(Body, K + 1, $16);
                K := PosEx('"', Body, K + 1);
                Insert('.htm', Body, K);
                K := PosEx('"/wiki/index.php?title=', Body, K);
              end;
              K := Pos('id="catlinks"', Body);
              K := PosEx('href="', Body, K);
              while K > 0 do
              begin
                M := PosEx('"', Body, K + 6);
                Delete(Body, K, M - K + 1);
                K := PosEx('href="', Body, K);
              end;
              K := Pos('<!-- tagline -->', Body);
              M := PosEx('<!-- /jumpto -->', Body, K);
              if (K > 0) and (M > 0) then
                Delete(Body, K, M - K + $15);
              K := Pos('<!--', Body);
              M := PosEx('-->', Body, K);
              if (K > 0) and (M > 0) then
                Delete(Body, K, M - K + 3);
              K := Pos('<!--', Body);
              M := PosEx('-->', Body, K);
              if (K > 0) and (M > 0) then
                Delete(Body, K, M - K + 3);
              K := PosEx('</div></div>', Body, K);
              if K > 0 then
                Delete(Body, K, 12);
              K := PosEx('</div></div>', Body, K);
              if K > 0 then
                Delete(Body, K, 12);
              K := Pos('<!-- Saved', Body);
              M := PosEx('-->', Body, K);
              if (K > 0) and (M > 0) then
                Delete(Body, K, M - K + 3);
              Body := '<!DOCTYPE html>'#10'<html>'#10'<head>'#10 + Title + #10 +
                '<meta charset="UTF-8" />' + #10 +
                '<link rel="stylesheet" href="styles" />' + #10 + '</head>' + #10 +
                '<body>' + #10 + Body + #10 + '<br>' + #10 + Foot + '</body>' + #10 +
                '</html>' + #10 + #0;
              Len := Length(Body);
              P := PChar(Body);
              end
              else
                Len := 0;
              Break;
            end;
          until False;
          if Len > 0 then
          try
            FS := TFileStream.Create(gWikiPath + FileName, $FFFF);
            FS.WriteBuffer(P^, Len);
          finally
            FS.Free;
          end;
          if not FileExists(gWikiPath + 'styles') then
          begin
            K := Pos('rel="stylesheet"', Styles);
            if K > 0 then
            begin
              K := PosEx('href="', Styles, K) + 6;
              M := PosEx('"', Styles, K);
              Body := Copy(Styles, K, M - K);
              K := Pos('amp;', Body);
              while K > 0 do
              begin
                Delete(Body, K, 4);
                K := Pos('amp;', Body);
              end;
              Styles := '';
              DownloadWikiPage('https://uopilot.uokit.com/wiki' + Body, 'styles');
            end;
          end;
        finally
          InternetCloseHandle(hUrl);
        end;
      finally
        InternetCloseHandle(hNet);
      end;
    finally
      FreeMem(Buf);
    end;
  except
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('! ' + LoadStr(gLangOffsety + $210) + ' ' + FileName)
    else
      fmSecondfj.mLog.Lines.Add('! Ошибка при закачке ' + FileName);
  end;
end;

procedure TfmSecond.sbDownloadWikiClick(Sender: TObject);
begin
  { Скачивание вики в отдельном потоке; ошибка уходит сообщением в лог. }
  try
    if sbDownloadWiki.Down then
    begin
      gWikiThread := TWikiThread.Create(True);
      gWikiThread.FreeOnTerminate := True;
      gWikiThread.Resume;
    end
    else
    begin
      gWikiThread.FreeOnTerminate := False;
      sbDownloadWiki.Enabled := False;
      gWikiThread.Terminate;
      gWikiThread.WaitFor;
      gWikiThread.Free;
      sbDownloadWiki.Enabled := True;
    end;
  except
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('! ' + LoadStr(gLangOffsety + $211))
    else
      fmSecondfj.mLog.Lines.Add('! Что то пошло не так.');
  end;
end;

procedure TfmSecond.WebBrowserBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant; var Flags: OleVariant;
      var TargetFrameName: OleVariant; var PostData: OleVariant;
      var Headers: OleVariant; var Cancel: WordBool);
var
  S: string;
begin
  { OnBeforeNavigate2 у wbWiki: если статьи ещё нет в кэше -- скачать её
    рядом с exe и увести переход в браузер (Cancel := True), иначе дать
    компоненту открыть локальный файл. URL приходит OleVariant. }
  if not FileExists(URL) then
  begin
    S := ExtractFileName(URL);
    S := ChangeFileExt(S, '');
    DownloadWikiPage('https://uopilot.uokit.com/wiki/index.php?title=' + S,
      S + '.htm');
    if not FileExists(URL) then
    begin
      Cancel := True;
      S := URL;
      ShellExecute(0, 'Open', PChar(S), nil, nil, SW_SHOWNORMAL);
    end;
  end;
end;

procedure TfmSecond.ShowWikiTopic(Topic: string);
begin
  { Показ раздела вики: если окно справки закрыто -- открыть его тем же
    обработчиком меню и, при несохранённой позиции (gHelpRect.Top = -1),
    поставить посередине экрана. Дальше: локальная копия страницы, если
    её нет -- качаем. }
  try
    if (gHelpForm = nil) or (not gHelpForm.Visible) then
    begin
      miScriptHelpClick(Self);
      if gHelpRect.Top = -1 then
      begin
        gHelpForm.Height := Screen.Height div 2;
        gHelpForm.Width := Screen.Width div 3;
        gHelpForm.Left := (Screen.Width - Screen.Width div 3) div 2;
      end;
    end;
    pcHelp.TabIndex := 0;
    if not DirectoryExists(gWikiPath) then
      CreateDir(gWikiPath);
    gHelpForm.BringToFront;
    if FileExists(gWikiPath + Topic + '.htm') then
      wbWiki.Navigate(gWikiPath + Topic + '.htm')
    else
    begin
      DownloadWikiPage('https://uopilot.uokit.com/wiki/index.php?title=' + Topic,
        Topic + '.htm');
      if FileExists(gWikiPath + Topic + '.htm') then
        wbWiki.Navigate(gWikiPath + Topic + '.htm');
    end;
  except
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('! ' + LoadStr(gLangOffsety + $212))
    else
      fmSecondfj.mLog.Lines.Add('! Не удалось открыть форму.');
  end;
end;

procedure TfmSecond.ShowWikiForCommand;
var
  P: TBufferCoord;
  W: string;
  W2: string;
  Suffix: string;
  P2: TBufferCoord;
  M: Integer;
  N: Integer;
  I: Integer;
begin
  // F1 в редакторе: показать вики по команде под курсором.
  // Тот же разбор, что в mnComPopup, но точка берётся от каретки.
  try
    P := edScript.CaretXY;
    W := edScript.GetWordAtRowCol(P);
    if W = '' then
      Exit;
    N := gCmdListah7.IndexOf(AnsiLowerCase(W));
    case N of
      42, 50, 51, 77, 84:
        begin
          P2 := edScript.PrevWordPosEx(P);
          W2 := edScript.GetWordAtRowCol(P2);
          if W2 = W then
            W2 := edScript.GetWordAtRowCol(edScript.PrevWordPosEx(P2));
          M := gCmdList2jj.IndexOf(AnsiLowerCase(W2));
          case M of
            40, 49:
              W := W2 + '_' + W;
          end;
        end;
    end;
    if N < 0 then
      N := gCmdList2jj.IndexOf(AnsiLowerCase(W));
    if N < 0 then
      Exit;
    Suffix := '';
    I := edScript.CaretY - 1;
    while I >= 0 do
    begin
      if Copy(edScript.Lines[I], 1, 2) = '--' then
      begin
        Suffix := '_(Lua)';
        Break;
      end;
      if Copy(edScript.Lines[I], 1, 2) = '//' then
        Break;
      Dec(I);
    end;
    ShowWikiTopic(W + Suffix);
  except
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('! ' + LoadStr(gLangOffsety + $213))
    else
      fmSecondfj.mLog.Lines.Add('! Не удалось показать справку.');
  end;
end;

procedure TfmSecond.mnComPopup(Sender: TObject);
var
  P: TBufferCoord;
  W: string;
  W2: string;
  Suffix: string;
  P2: TBufferCoord;
  N: Integer;
  I: Integer;
  Ok: Boolean;
begin
  { Всплывающее меню редактора: под курсором ищется команда, для составных
    (`if`, `while` и прочих с продолжением) подтягивается предыдущее слово
    через `_`, а язык скрипта определяется первым комментарием снизу вверх --
    от него зависит суффикс в ссылке на вики. }
  try
    miWikiHelp.Visible := False;
    Ok := edScript.GetPositionOfMouse(P);
    W := edScript.GetWordAtRowCol(P);
    if W = '' then
      Exit;
    N := gCmdListah7.IndexOf(AnsiLowerCase(W));
    case N of
      42, 50, 51, 77, 84:
        begin
          P2 := edScript.PrevWordPosEx(P);
          W2 := edScript.GetWordAtRowCol(P2);
          if W2 = W then
            W2 := edScript.GetWordAtRowCol(edScript.PrevWordPosEx(P2));
          case gCmdList2jj.IndexOf(AnsiLowerCase(W2)) of
            40, 49:
              W := W2 + '_' + W;
          end;
        end;
    end;
    if N < 0 then
      N := gCmdList2jj.IndexOf(AnsiLowerCase(W));
    if N < 0 then
      Exit;
    Suffix := '';
    I := edScript.CaretY - 1;
    while I >= 0 do
    begin
      if Copy(edScript.Lines[I], 1, 2) = '--' then
      begin
        Suffix := '_(Lua)';
        Break;
      end;
      if Copy(edScript.Lines[I], 1, 2) = '//' then
        Break;
      Dec(I);
    end;
    W := W + Suffix;
    miWikiHelp.Caption := '* WikiHelp: ' + W;
    miWikiHelp.Hint := W;
    miWikiHelp.Visible := True;
  except
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('! ' + LoadStr(gLangOffsety + $214))
    else
      fmSecondfj.mLog.Lines.Add('! Проблемы с меню.');
  end;
end;

procedure TfmSecond.miWikiHelpClick(Sender: TObject);
var
  R: TRect;
  Doc: IDispatch;
  W: TWebBrowser;
begin
  { Открывает раздел справки и активирует встроенный браузер: DoVerb с
    OLEIVERB_UIACTIVATE. Сам wbWiki передаётся как IOleClientSite --
    TOleControl её реализует. }
  ShowWikiTopic(miWikiHelp.Hint);
  W := wbWiki;
  Doc := W.Document;
  if Assigned(Doc) then
  begin
    R := ClientRect;
    (W.Application as IOleObject).DoVerb(-4, nil, wbWiki, 0,
      W.Handle, R);
  end;
end;

procedure WikiRefreshList(Form: TfmSecond);
var
  SR: TSearchRec;
begin
  { Перечитывание списка скачанных страниц справки. SysUtils.FindClose --
    с квалификатором: юнит Windows идёт в uses позже и перекрывает имя
    своим FindClose(THandle), иначе «Incompatible types». }
  try
    if not DirectoryExists(gWikiPath) then
      Exit;
    Form.cbWikiList.Clear;
    if FindFirst(gWikiPath + '*.htm', faAnyFile, SR) = 0 then
      repeat
        Form.cbWikiList.AddItem(ChangeFileExt(ExtractFileName(SR.Name), ''), nil);
      until FindNext(SR) <> 0;
    SysUtils.FindClose(SR);
  except
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('! ' + LoadStr(gLangOffsety + $215))
    else
      fmSecondfj.mLog.Lines.Add('! Не удалось получить список файлов.');
  end;
end;

procedure TfmSecond.cbWikiListChange(Sender: TObject);
var
  W: WideString;
begin
  W := gWikiPath + cbWikiList.Text + '.htm';
  wbWiki.Navigate(W);
  eFindText.Modified := True;
end;

procedure TfmSecond.spUnpackWikiClick(Sender: TObject);
begin
  UnpackUoPArchive('Help', 77);
end;

procedure TfmSecond.sbWikiBackClick(Sender: TObject);
begin
  wbWiki.GoBack;
end;

procedure TfmSecond.sbWikiForwardClick(Sender: TObject);
begin
  wbWiki.GoForward;
end;

procedure TfmSecond.WebBrowserCommandStateChange(Sender: TObject; Command: Integer; Enable: WordBool);
begin
  { Ветки перечислены не по возрастанию: сначала 2, потом 1. }
  case Command of
    2: sbWikiBack.Enabled := Enable;
    1: sbWikiForward.Enabled := Enable;
  end;
end;

procedure TWikiThread.Execute;
var
  Rd: DWORD;
  Size: Integer;
  Buf: Pointer;
  S: string;
  Html: string;
  Part: string;
  Sep: string;
  Name: string;
  J: Integer;
  A: array of array of string;
  U: array[0..1] of string;
  P1, P2, I: Integer;

  function GetUrl(Url: string; var Text: string): Boolean;
  var
    hSession: HINTERNET;
    hUrl: HINTERNET;
    Agent: string;
    Hdr: string;
    Q: PChar;
  begin
    hSession := nil;
    hUrl := nil;
    Size := $50000;
    Hdr := '';
    Agent := 'Mozilla/5.001 (windows; U; NT4.0; en-US; rv:1.0) Gecko/25250101';
    Result := False;
    try
      hSession := InternetOpen(PChar(Agent), 0, nil, nil, 0);
      if hSession = nil then
        Exit;
      try
        hUrl := InternetOpenUrl(hSession, PChar(Url), PChar(Hdr), Length(Hdr), 0, 0);
        if hUrl = nil then
          Exit;
        Text := '';
        repeat
          if not InternetReadFile(hUrl, Buf, Size, Rd) then
            Exit;
          Q := Buf;
          Text := Text + Copy(Q, 1, Rd);
        until Rd = 0;
        Rd := Length(Text);
        Result := True;
      finally
        InternetCloseHandle(hUrl);
      end;
    finally
      InternetCloseHandle(hSession);
    end;
  end;
begin
  Sep := '/index.php?title=';
  CreateDir(gWikiPath);
  S := 'index.htm';
  try
    Size := $50000;
    GetMem(Buf, Size);
    SetLength(A, 0, 0);
    U[0] := 'https://uopilot.uokit.com/wiki/index.php?title=%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA_%D1%84%D1%83%D0%BD%D0%BA%D1%86%D0%B8%D0%B9';
    U[1] := 'https://uopilot.uokit.com/wiki/index.php?title=%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA_%D1%84%D1%83%D0%BD%D0%BA%D1%86%D0%B8%D0%B9_(Lua)';
    for J := 0 to 1 do
    begin
      if Terminated then
        Break;
      if GetUrl(U[J], Html) then
      begin
        if Terminated then
          Break;
        P1 := Pos('"printfooter"', Html);
        if P1 > 0 then
        begin
          Part := Copy(Html, 1, P1);
          P2 := Pos(Sep, Part);
          while P2 > 0 do
          begin
            if Terminated then
              Break;
            if not fmSecondfj.sbDownloadWiki.Down then
              Break;
            P2 := P2 + Length(Sep);
            P1 := PosEx('"', Part, P2);
            Name := Copy(Part, P2, P1 - P2);
            if Pos('%', Name) > 0 then
              Name := Utf8ToAnsi(WikiUrlDecode(Name));
            P2 := Pos('/', Name);
            if P2 > 0 then
              Name := Copy(Name, 1, P2 - 1);
            P2 := Pos('&', Name);
            if P2 > 0 then
              Name := Copy(Name, 1, P2 - 1);
            P2 := Pos(':', Name);
            if P2 > 0 then
              Name[P2] := '_';
            FMsg := 'https://uopilot.uokit.com/wiki/index.php?title=' + Name;
            P2 := Length(A);
            SetLength(A, P2 + 1, 2);
            A[P2][0] := FMsg;
            A[P2][1] := Name;
            Delete(Part, 1, P1);
            P2 := Pos(Sep, Part);
          end;
        end;
      end;
    end;
    if gLangOffsety > 0 then
      fmSecondfj.mLog.Lines.Add('+ ' + LoadStr(gLangOffsety + $216) + ': ' +
        IntToStr(Length(A)))
    else
      fmSecondfj.mLog.Lines.Add('+ Нашли функций: ' + IntToStr(Length(A)));
    P2 := Length(A) - 1;
    fmSecondfj.sbDownloadWiki.Tag := P2;
    if P2 >= 0 then
    begin
      Synchronize(SyncProgressStart);
      for I := 0 to Length(A) - 1 do
      begin
        fmSecondfj.sbDownloadWiki.Tag := I + 1;
        Synchronize(SyncProgressStep);
        if Terminated then
          Break;
        FMsg := A[I][0];
        Name := A[I][1];
        S := Name + '.htm';
        if gLangOffsety > 0 then
          fmSecondfj.mLog.Lines.Add('+ ' + LoadStr(gLangOffsety + $217) + ' ' +
            IntToStr(I + 1) + ': ' + Name)
        else
          fmSecondfj.mLog.Lines.Add('+ Скачиваем ' + IntToStr(I + 1) + ': ' + Name);
        DownloadWikiPage(FMsg, S);
      end;
    end;
  finally
    FreeMem(Buf);
  end;
  SetLength(A, 0, 0);
  fmSecondfj.sbDownloadWiki.Tag := 0;
  Synchronize(SyncProgressDone);
  if Terminated then
    fmSecondfj.mLog.Lines.Add('== terminated')
  else
    fmSecondfj.mLog.Lines.Add('== finish');
  WikiRefreshList(fmSecondfj);
  fmSecondfj.sbDownloadWiki.Down := False;
end;

procedure TWikiThread.SyncProgressStart;
begin
  fmSecondfj.pbWiki.Max := fmSecondfj.sbDownloadWiki.Tag;
  fmSecondfj.pbWiki.Position := 0;
  fmSecondfj.pbWiki.Visible := True;
end;

procedure TWikiThread.SyncProgressStep;
begin
  fmSecondfj.pbWiki.Position := fmSecondfj.sbDownloadWiki.Tag;
end;

procedure TWikiThread.SyncProgressDone;
begin
  fmSecondfj.pbWiki.Visible := False;
end;

procedure TfmSecond.FormActivate(Sender: TObject);
begin
  if (Assigned(gHelpForm)) and gHelpForm.Visible then
    SetWindowPos(gHelpForm.Handle, 0, 1, 1, 1, 1, $13);
end;

procedure TfmSecond.pcHelpChange(Sender: TObject);
begin
  case pcHelp.TabIndex of
    0:
      begin
        gbFind.Parent := tsWiki;
        rbFindUp.Enabled := False;
        rbFindDown.Checked := True;
      end;
    1:
      begin
        gbFind.Parent := tsHistory;
        rbFindUp.Enabled := True;
      end;
  end;
  if pcHelp.TabIndex = 1 then
    eFindText.SetFocus;
end;

function KeyboardHookProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  bShift, bCtrl, bAlt: Boolean;
  I: Integer;
  s: string;
begin
  { Хук WH_KEYBOARD_LL: при Code < 0 событие уходит дальше по цепочке,
    иначе возвращается 1, то есть ввод ГЛУШИТСЯ. Разбирается только
    Code = 0 (HC_ACTION): ищется горячая клавиша по имени
    `hkEnableKeyboard`, и если её код и три модификатора совпали
    с нажатым -- оба хука снимаются.
    GetKeyState возвращает Smallint, поэтому `and $80 = $80` считается
    в шестнадцати битах. FKey -- Integer, а PDWORD(lParam)^ (поле vkCode
    структуры KBDLLHOOKSTRUCT) -- Cardinal, и Delphi 7 сравнивает такую
    пару как Int64.
    Имена элементов набора зовутся с юнитом: `ssCtrl` без него берётся
    из Classes (тот идёт в uses позже HotKeyMgr) и даёт `Incompatible
    types`. }
  if Code < 0 then
    Result := CallNextHookEx(gHook591404, Code, wParam, lParam)
  else
  begin
    if Code = 0 then
    begin
      bShift := (GetKeyState(VK_SHIFT) and $80) = $80;
      bCtrl := (GetKeyState(VK_CONTROL) and $80) = $80;
      bAlt := (GetKeyState(VK_MENU) and $80) = $80;
      for I := 0 to gHotKeyMgr.HotKeys.Count - 1 do
        if (gHotKeyMgr.HotKeys.Items[I].Name = 'hkEnableKeyboard') and
           (gHotKeyMgr.HotKeys.Items[I].FKey = PDWORD(lParam)^) and
           ((HotKeyMgr.ssCtrl in gHotKeyMgr.HotKeys.Items[I].ShiftState) = bCtrl) and
           ((HotKeyMgr.ssShift in gHotKeyMgr.HotKeys.Items[I].ShiftState) = bShift) and
           ((HotKeyMgr.ssAlt in gHotKeyMgr.HotKeys.Items[I].ShiftState) = bAlt) then
        begin
          UnhookHookB;
          UnhookHookA;
        end;
    end;
    Result := 1;
  end;
end;

procedure UnhookHookB;
begin
  if gHook591404 <> 0 then
  begin
    UnhookWindowsHookEx(gHook591404);
    gHook591404 := 0;
  end;
  // $24 = SPI_SETFASTTASKSWITCH, $61 = SPI_SETSCREENSAVERRUNNING.
  // SPI_SETSCREENSAVERRUNNING в Windows.pas Delphi 7 нет, поэтому числом.
  SystemParametersInfo(SPI_SETFASTTASKSWITCH, 0, nil, 0);
  SystemParametersInfo($61, 0, nil, 0);
end;

procedure SetHookB;
var
  Old: Integer;
begin
  { Ставит хук клавиатуры и на время его работы гасит переключение задач
    и хранитель экрана. Пара к UnhookHookB. }
  Old := 0;
  SystemParametersInfo(SPI_SETFASTTASKSWITCH, 1, @Old, 0);
  SystemParametersInfo($61, 1, @Old, 0);
  gHook591404 := SetWindowsHookEx(13, @KeyboardHookProc, HInstance, 0);
end;

function MouseHookProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  { Хук мыши глушит ввод: при Code >= 0 возвращает 1, то есть событие
    дальше не идёт. }
  if Code < 0 then
    Result := CallNextHookEx(gHook591400, Code, wParam, lParam)
  else
    Result := 1;
end;

procedure UnhookHookA;
begin
  if gHook591400 <> 0 then
  begin
    UnhookWindowsHookEx(gHook591400);
    gHook591400 := 0;
  end;
end;

procedure SetHookA;
begin
  { Пара к UnhookHookA: прежний хук снимается перед постановкой нового. }
  if gHook591400 <> 0 then
    UnhookHookA;
  gHook591400 := SetWindowsHookEx(14, @MouseHookProc, HInstance, 0);
end;

procedure WaitMilliseconds(S: string);
var
  StartTick: DWORD;
  Delay: Integer;
begin
  // Пауза с прокачкой очереди сообщений: 'wait 500' в скрипте UoPilot.
  if S = '' then
    Exit;
  if S <> 'HMS' then
  begin
    StartTick := GetTickCount;
    Delay := StrToInt(S);
    repeat
      Application.ProcessMessages;
    until GetTickCount - StartTick >= DWORD(Delay);
  end;
end;

function ScanCommandMenu(M: TMenuItem): Boolean;
begin
  // Тело живёт во вложенной функции ScanMenu в mmScriptKeyUp.
  Result := False
end;

procedure TfmSecond.sbScriptsPanelClick(Sender: TObject);
var
  B: TSpeedButton;
begin
  { Панель со списком скриптов -- отдельное окошко в 22 пикселя высотой
    с двумя кнопками по 20x20, создаётся один раз при первом включении. }
  if sbScriptsPanel.Down then
  begin
    if gDlg596720 = nil then
    begin
      gDlg596720 := TForm.Create(fmSecondfj);
      gDlg596720.Caption := 'Scripts';
      gDlg596720.ClientHeight := $16;
      gDlg596720.ClientWidth := $2E1;
      gDlg596720.FormStyle := fsStayOnTop;
      gDlg596720.OldCreateOrder := True;
      gDlg596720.Scaled := False;
      B := TSpeedButton.Create(gDlg596720);
      B.Left := 0;
      B.Top := 0;
      B.Width := $14;
      B.Height := $14;
      B := TSpeedButton.Create(gDlg596720);
      B.Left := $15;
      B.Top := 0;
      B.Width := $14;
      B.Height := $14;
    end;
    gDlg596720.Show;
    if CanCloseOrActivate then
      Application.OnDeactivate := AppActivateKeepTopmost;
  end
  else
  begin
    gDlg596720.Hide;
    if not CanCloseOrActivate then
      Application.OnDeactivate := nil;
  end;
end;

procedure TfmSecond.miSaveOptionsAsClick(Sender: TObject);
var
  OldExt: string;
  OldFilter: string;
  OldDir: string;
  OldTitle: string;
begin
  { Диалог общий, поэтому все четыре свойства сохраняются и возвращаются. }
  OldExt := sdSave.DefaultExt;
  sdSave.DefaultExt := '.ini';
  sdSave.FileName := FOptionsFile;
  OldFilter := sdSave.Filter;
  sdSave.Filter := 'Ini files (*.ini)|*.ini|All files (*.*)|*.*';
  OldDir := sdSave.InitialDir;
  sdSave.InitialDir := gTempFilefv;
  OldTitle := sdSave.Title;
  if gLangOffsety > 0 then
    sdSave.Title := LoadStr(gLangOffsety + $209)
  else
    sdSave.Title := 'Сохранить настройки как...';
  if sdSave.Execute then
  begin
    FOptionsFile := sdSave.FileName;
    miSaveOptionsClick(Sender);
  end;
  sdSave.DefaultExt := OldExt;
  sdSave.FileName := '';
  sdSave.Filter := OldFilter;
  sdSave.InitialDir := OldDir;
  sdSave.Title := OldTitle;
  SysUtils.SetCurrentDir(gTempFilefv);
end;

procedure TfmSecond.miLoadOptionsAsClick(Sender: TObject);
var
  OldExt, OldFilter, OldDir, OldTitle: string;
  N: Integer;
  I: Integer;
  J: Integer;
  M: TMemo;
begin
  { Загрузка настроек из другого ini. Перед этим все вкладки скриптов
    закрываются по одной, а после -- создаётся одна пустая. Настройки диалога
    подменяются на время вызова и возвращаются в конце. }
  OldExt := odLoad.DefaultExt;
  odLoad.DefaultExt := '.ini';
  odLoad.FileName := FOptionsFile;
  OldFilter := odLoad.Filter;
  odLoad.Filter := 'Ini files (*.ini)|*.ini|All files (*.*)|*.*';
  OldDir := odLoad.InitialDir;
  odLoad.InitialDir := gTempFilefv;
  OldTitle := odLoad.Title;
  if gLangOffsety > 0 then
    odLoad.Title := LoadStr(gLangOffsety + $20A)
  else
    odLoad.Title := 'Загрузить настройки...';
  if odLoad.Execute then
  begin
    FOptionsFile := odLoad.FileName;
    tTabRefresh.Enabled := False;
    I := 0;
    while tScript.Tabs.Count > 0 do
    begin
      N := StrToInt(tScript.Tabs[I]);
      if sghkScriptHKList.Cells[0, I] = 'X' then
      begin
        sghkScriptHKList.Cells[0, I] := '';
        sghkScriptHKList.Row := I;
        cbhk1Click(sghkScriptHKList);
      end;
      { строки списка горячих клавиш сдвигаются вверх на место удалённой }
      for J := I to sghkScriptHKList.RowCount - 1 do
      begin
        TGridCracker(sghkScriptHKList).MoveRow(J + 1, J);
        sghkScriptHKList.Rows[J + 1].Clear;
      end;
      sghkScriptHKList.RowCount := sghkScriptHKList.RowCount - 1;
      gHKEntrieslw[$22 + N].Name := '';
      if gScriptso3[N] <> nil then
      begin
        if not Assigned(gScriptso3[N].OnTerminate) then
        begin
          gScriptso3[N].Free;
          gScriptso3[N] := nil;
        end
        else
        begin
          if not gScriptso3[N].Suspended then
            gScriptso3[N].Suspend;
          gScriptso3[N].FreeOnTerminate := False;
          gScriptso3[N].StopRequested := True;
          gScriptso3[N].LogToParent := True;
          gScriptso3[N].Title := '';
          gScriptso3[N].Resume;
          gScriptso3[N].WaitFor;
          TObject(gScriptso3[N]).Free;
          gScriptso3[N] := nil;
        end;
      end;
      tScript.Tabs.Delete(0);
    end;
    tScript.Tabs.Add('0');
    tScript.TabIndex := 0;
    tTabRefresh.Enabled := True;
    gScriptso3[0] := TScanThread.NewScriptTab(True);
    gScriptso3[0].SelfRef := Pointer(gScriptso3[0]);
    gScriptso3[0].Name := IntToStr(0);
    gScriptso3[0].AutoStart := True;
    edScript.Clear;
    { окно лога скрипта создаётся кодом, а его WindowProc перехватывается }
    if gScriptso3[0].LogView = nil then
    begin
      M := TMemo.Create(fmSecondfj);
      gScriptso3[0].LogView := M;
      M.Visible := False;
      M.Parent := fmSecondfj.pLog;
      M.Color := $FF000018;
      M.ParentFont := True;
      M.ReadOnly := True;
      M.ScrollBars := ssBoth;
      M.HideSelection := False;
      M.Align := alClient;
    end;
    gScriptso3[0].LogView.Lines.Add(
      fmSecondfj.tScript.Tabs[fmSecondfj.tScript.Tabs.Count - 1]);
    gScriptso3[0].OldLogProc :=
      gScriptso3[0].LogView.WindowProc;
    gScriptso3[0].LogView.WindowProc :=
      gScriptso3[0].LogWndProc;
    AfterOptionsLoaded;
  end;
  odLoad.DefaultExt := OldExt;
  odLoad.FileName := '';
  odLoad.Filter := OldFilter;
  odLoad.InitialDir := OldDir;
  odLoad.Title := OldTitle;
  SysUtils.SetCurrentDir(gTempFilefv);
end;

procedure TfmSecond.GutterClick(Sender: TObject; Button: TMouseButton;
      X, Y, Line: Integer; Mark: TSynEditMark);
var
  { Mode и Cm видны вложенной DoComment. J и L -- одни и те же переменные
    в обеих половинах метода: сначала «позиция первого непробела» и
    «длина строки минус 2», потом границы выделения. }
  Mode: Integer;
  Cm: string;
  I: Integer;
  Ln: string;
  Found: Boolean;
  J, L: Integer;

  { Комментирует или раскомментирует строки с AFrom по ATo. Первая строка
    задаёт режим (Mode): нашли префикс -- снимаем его со всех, не нашли --
    ставим всем. }
  function DoComment(AFrom, ATo: Integer): Boolean;
  var
    K, J2, L2: Integer;
    S: string;
  begin
    for K := AFrom to ATo do
    begin
      S := edScript.Lines[K - 1];
      L2 := Length(S) - 2;
      J2 := 1;
      while (J2 <= L2) and ((S[J2] = ' ') or (S[J2] = #9)) do
        Inc(J2);
      if Mode = 0 then
      begin
        if Copy(S, J2, 2) = Cm then
        begin
          Delete(S, J2, 2);
          Mode := 1;
        end
        else
        begin
          S := Cm + S;
          Mode := 2;
        end;
      end
      else if Mode = 1 then
      begin
        if Copy(S, J2, 2) = Cm then
          Delete(S, J2, 2);
      end
      else
        S := Cm + S;
      edScript.Lines[K - 1] := S;
    end;
  end;
begin
  { Клик по гуттеру редактора: комментирует строку или выделение. Префикс
    выбирается по коду ВЫШЕ: идём вверх от текущей строки, пока не встретим
    '//' или '--'; '--' внутри lua-блока (перед ним где-то был 'endlua')
    означает, что дальше снова Pascal-подобный код, и префикс снова '//'. }
  I := Line - 1;
  Found := False;
  while I >= 0 do
  begin
    Ln := edScript.Lines[I];
    L := Length(Ln) - 2;
    J := 1;
    while (J <= L) and ((Ln[J] = ' ') or (Ln[J] = #9)) do
      Inc(J);
    Cm := Copy(Ln, J, 2);
    if Cm = '//' then
    begin
      Found := True;
      Break;
    end;
    if Cm = '--' then
    begin
      if (Copy(Ln, J + 2, 6) = 'endlua') and (Line - 1 <> I) then
        Cm := '//';
      Found := True;
      Break;
    end;
    Dec(I);
  end;
  if not Found then
    Cm := '//';
  Mode := 0;
  if edScript.SelLength <= 0 then
  begin
    if cbCommentOnClick.Checked then
    begin
      mmScriptOnChange(Sender);
      DoComment(Line, Line);
    end;
  end
  else if cbCommentOnSelect.Checked then
  begin
    { Границы выделения -- в НОМЕРАХ СТРОК: каретка ставится на начало и на
      конец, после каждой установки читается CaretY. }
    L := edScript.SelStart;
    J := edScript.SelEnd;
    edScript.SelStart := L;
    L := edScript.CaretY;
    edScript.SelStart := J;
    J := edScript.CaretY;
    mmScriptOnChange(Sender);
    if L < J then
      DoComment(L, J)
    else
      DoComment(J, L);
  end;
end;

procedure TfmSecond.seLogfilesizeChange(Sender: TObject);
var
  V: Integer;
begin
  if TryStrToInt(seLogfilesize.Text, V) then
  begin
    if V < 0 then
      seLogfilesize.Value := 0;
    if V > 999 then
      seLogfilesize.Value := 999;
    gLogMaxSizehk := (seLogfilesize.Value * 1024 * 1024) div 128;
  end
  else
    seLogfilesize.Value := 0;
end;

procedure TfmSecond.miShowRemainingWaitClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to 99 do
    if Assigned(gScriptso3[I]) then
      gScriptso3[I].ShowRemainingWait := fmSecondfj.miShowRemainingWait.Checked;
  if not miShowRemainingWait.Checked then
  begin
    fmSecondfj.pRestWait.Visible := False;
    fmSecondfj.lRestWait.Caption := '';
  end;
end;

procedure TfmSecond.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  I: Integer;
  Allow: Boolean;
begin
  if (pcAll.ActivePage = tsScript) and (Key = VK_TAB) then
  begin
    Allow := True;
    I := tScript.TabIndex;
    if Shift = [ssCtrl] then
    begin
      if I < tScript.Tabs.Count - 1 then
        Inc(I);
    end
    else if Shift = [ssShift, ssCtrl] then
    begin
      if I > 0 then
        Dec(I);
    end;
    if I <> tScript.TabIndex then
    begin
      tScriptChanging(Sender, Allow);
      tScript.TabIndex := I;
      tScriptChange(Sender);
    end;
  end;
end;

procedure TfmSecond.sbSelectColorFrontClick(Sender: TObject);
begin
  (fmSecondfj.FindComponent('cdColorFront') as TColorDialog).Execute;
end;

procedure TfmSecond.sbSelectColorBackClick(Sender: TObject);
begin
  (fmSecondfj.FindComponent('cdColorBack') as TColorDialog).Execute;
end;

procedure TfmSecond.miAttriChangeClick(Sender: TObject);
begin
  try
    if gDlg596724bt = nil then
    begin
      CreateAttriDialog(TAttriFontChange, Sender);
      SetChildFontHeight(gDlg596724bt);
    end;
    gDlg596724bt.Visible := not gDlg596724bt.Visible;
  finally
  end;
end;

procedure TfmSecond.odLoadShow(Sender: TObject);
begin
  if cbSOT.Checked then
    SetWindowPos(fmSecondfj.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
      SWP_NOSIZE or SWP_NOMOVE);
  SetWindowPos(odLoad.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOSIZE or SWP_NOMOVE or SWP_FRAMECHANGED);
end;

initialization
  gCmdListah7 := TStringList.Create;
  gCmdList2jj := TStringList.Create;
  gTemplateLines := TStringList.Create;
  OleInitialize(nil);

finalization
  gTemplateLines.Free;
  gCmdList2jj.Free;
  for gMacroIndex := 0 to gCmdListah7.Count - 1 do
    if gCmdListah7.Objects[gMacroIndex] <> nil then
      gCmdListah7.Objects[gMacroIndex].Free;
  gCmdListah7.Free;
  SetLength(gWinHandles, 0);
  OleUninitialize;

end.
