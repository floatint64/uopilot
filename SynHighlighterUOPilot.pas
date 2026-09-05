{ Подсветчик синтаксиса скриптов UO Pilot, портированный с локального
  SynEdit 2.0.3 (SynHighlighterPas.pas) на Lazarus SynEdit (UTF-8).

  Класс TSynUOPilotSyn строится на Lazarus TSynCustomHighlighter и повторяет
  логику токенизатора и 24-категорийной хэш-таблицы ключевых слов старого
  TSynPasSyn: язык скриптов разбирается побайтово (идентификаторы и ключевые
  слова -- ASCII), кириллица в строках/комментариях пропускается как есть. }

unit SynHighlighterUOPilot;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  SysUtils,
  Classes,
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  { TMyMemIniFile: тип параметра процедур загрузки/сохранения ниже. }
  MyIniFiles;

type
  TtkTokenKind = (tkAsm, tkComment, tkIdentifier, tkKey, tkNull, tkNumber,
    tkSpace, tkString, tkSymbol, tkUnknown, tkFloat, tkHex, tkDirec, tkChar);

  TRangeState = (rsANil, rsAnsi, rsAnsiAsm, rsAsm, rsBor, rsBorAsm, rsProperty,
    rsExports, rsDirective, rsDirectiveAsm, rsUnKnown);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

  { UoPilot: ведро хэш-таблицы ключевых слов. Три параллельных динамических
    массива: само слово, вид зарезервированного слова (см. поля fRW*Attri) и
    флаг «добавлено пользователем» -- SaveHighlighter пишет в ini только такие. }
  TlistRW = record
    Names: array of string;
    Kinds: array of Integer;
    Mine: array of Boolean;
  end;

  TRWTable = array[0..255] of TlistRW;
  PRWTable = ^TRWTable;

  { Атрибут подсветки с дополнительным полем Kind -- номер категории
    зарезервированного слова (1..24) или 0 для стандартных атрибутов. В
    Lazarus TSynHighlighterAttributes не имеет Kind, поэтому он вынесен сюда. }
  TSynUOAttributes = class(TSynHighlighterAttributes)
  private
    FKind: Integer;
  published
    property Kind: Integer read FKind write FKind;
  end;

  { TSynUOPilotSyn }

  TSynUOPilotSyn = class(TSynCustomHighlighter)
  private
    fAsmStart: Boolean;
    fRange: TRangeState;
    fLineStr: string;
    fLine: PChar;
    fLineLen: Integer;
    fLineNumber: Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fIdentFuncTable: array[0..255] of TIdentFuncTableFunc;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    fStringAttri: TSynUOAttributes;
    fCharAttri: TSynUOAttributes;
    fNumberAttri: TSynUOAttributes;
    fFloatAttri: TSynUOAttributes;
    fHexAttri: TSynUOAttributes;
    fKeyAttri: TSynUOAttributes;
    { UoPilot script: по одному атрибуту на категорию зарезервированных слов }
    fRWTimeAttri: TSynUOAttributes;                // kind 1
    fRWCharParamAttri: TSynUOAttributes;           // kind 2
    fRWLastObjectAttri: TSynUOAttributes;          // kind 3
    fRWColorAndCordAttri: TSynUOAttributes;        // kind 4
    fRWFunctionAttri: TSynUOAttributes;            // kind 5
    fRWMacrosAttri: TSynUOAttributes;              // kind 7
    fRWMouseAttri: TSynUOAttributes;               // kind 8
    fRWKeyboardAttri: TSynUOAttributes;            // kind 9
    fRWForAttri: TSynUOAttributes;                 // kind 10
    fRWIfAttri: TSynUOAttributes;                  // kind 11
    fRWSubAttri: TSynUOAttributes;                 // kind 12
    fRWArrayAttri: TSynUOAttributes;               // kind 14
    fRWScriptAttri: TSynUOAttributes;              // kind 15
    fRWProcAttri: TSynUOAttributes;                // kind 16
    fRWWindowsAttri: TSynUOAttributes;             // kind 17
    fRWMemoryAttri: TSynUOAttributes;              // kind 18
    fRWMsgAttri: TSynUOAttributes;                 // kind 19
    fRWWaitAttri: TSynUOAttributes;                // kind 20
    fRWOtherAttri: TSynUOAttributes;               // kind 21
    fRWGetAttri: TSynUOAttributes;                 // kind 22
    fRWEndScriptAttri: TSynUOAttributes;           // kind 23
    fRWPluginAttri: TSynUOAttributes;              // kind 24
    fTokenKind: Integer;
    fSymbolAttri: TSynUOAttributes;
    fAsmAttri: TSynUOAttributes;
    fCommentAttri: TSynUOAttributes;
    fDirecAttri: TSynUOAttributes;
    fIdentifierAttri: TSynUOAttributes;
    fSpaceAttri: TSynUOAttributes;
    { хэш-таблица ключевых слов скрипта UoPilot: 256 ведер, заполняется
      AddKeyword, читается IdentKind. Должно оставаться ПОСЛЕДНИМ полем. }
    fKeywords: array[0..255] of TlistRW;
    function KeyComp(const aKey: string): Boolean;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure AddressOpProc;
    procedure AsciiCharProc;
    procedure AnsiProc;
    procedure BorProc;
    procedure BraceOpenProc;
    procedure ColonOrGreaterProc;
    procedure CRProc;
    procedure IdentProc;
    procedure PercentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PointProc;
    procedure RoundOpenProc;
    procedure SemicolonProc;
    procedure SlashProc;
    procedure MinusProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure SymbolProc;
    procedure UnknownProc;
  protected
    function GetIdentChars: TSynIdentChars; override;
    function IsFilterStored: boolean; override;
  public
    class function GetCapabilities: TSynHighlighterCapabilities; override;
    class function GetLanguageName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
      override;
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetToken: string; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
      override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
    procedure ResetRange; override;
    procedure SetLine(const NewValue: string; LineNumber: Integer); override;
    procedure SetRange(Value: Pointer); override;
    { типизированные акцессоры к приватному состоянию ключевых слов,
      используются процедурами юнита и диалогами AttriFont.pas }
    property KeywordStringLen: Integer read fStringLen write fStringLen;
    property KeywordToIdent: PChar read fToIdent write fToIdent;
    function KeywordTablePtr: PRWTable;
  published
    property AsmAttri: TSynUOAttributes read fAsmAttri write fAsmAttri;
    property CommentAttri: TSynUOAttributes read fCommentAttri write fCommentAttri;
    property DirectiveAttri: TSynUOAttributes read fDirecAttri write fDirecAttri;
    property IdentifierAttri: TSynUOAttributes read fIdentifierAttri
      write fIdentifierAttri;
    property KeyAttri: TSynUOAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TSynUOAttributes read fNumberAttri write fNumberAttri;
    property FloatAttri: TSynUOAttributes read fFloatAttri write fFloatAttri;
    property HexAttri: TSynUOAttributes read fHexAttri write fHexAttri;
    property SpaceAttri: TSynUOAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynUOAttributes read fStringAttri write fStringAttri;
    property CharAttri: TSynUOAttributes read fCharAttri write fCharAttri;
    property SymbolAttri: TSynUOAttributes read fSymbolAttri write fSymbolAttri;
  end;

function KeywordHash(H: TSynCustomHighlighter; P: PChar): Integer;
function LoadHighlighterAttri(H: TSynCustomHighlighter; A: TSynHighlighterAttributes; Ini: TMyMemIniFile; Index: Integer): Boolean;
function SaveHighlighterAttri(H: TSynCustomHighlighter; A: TSynHighlighterAttributes; Ini: TMyMemIniFile; Sect: string): Boolean;
function SaveHighlighter(H: TSynCustomHighlighter; Ini: TMyMemIniFile): Boolean;
function LoadHighlighter(H: TSynCustomHighlighter; Ini: TMyMemIniFile): Boolean;
function AddKeyword(H: TSynCustomHighlighter; S: string; Kind: Integer): Boolean;
procedure DeleteKeyword(H: TSynCustomHighlighter; S: string);

implementation

uses
  StrUtils,
  { используется только из implementation: Unit1 даёт gNoFocusStealfq,
    читаемый процедурами ниже, а интерфейс Unit1 в свою очередь использует
    этот юнит (взаимная ссылка через implementation) }
  Unit1;

const
  gScriptVarNames: array[0..288] of string = (
    'name', 'gold', 'wght', 'armor',
    'hits', 'mana', 'stam', 'lastmsg',
    'coordx', 'coordy', 'min', 'hour',
    'sec', 'str', 'int', 'dex',
    'chardir', 'timer', 'lastobjectid', 'lastobjecttype',
    'lasttargetid', 'lasttargetx', 'lasttargety', 'lasttargetz',
    'lasttargetkind', 'lastliftedid', 'lastskill', 'lastspell',
    'laststatictype', 'coordz', 'target', 'charposx',
    'charposy', 'charposz', 'lastobject', 'lasttarget',
    'skills', 'war', 'hidden', 'arun',
    'delimiter', 'spellname', 'windowpos', 'findwindow',
    'workwindow', 'random', 'getwindow', 'getwindowtext',
    'mouse_pos', 'color', 'number', 'word',
    'xxx', 'year', 'month', 'day',
    'priority', 'prompt', 'setwindowtext', 'psysresist',
    'fireresist', 'coldresist', 'poisresist', 'enerresist',
    'luck', 'damage', 'hitsmax', 'manamax',
    'stammax', 'wghtmax', 'damagemax', 'followers',
    'followersmax', 'linedelay', 'fontcolor', 'findcolor',
    'size', 'clipboard', 'logging', 'getlayout',
    'setlayout', 'windowfromcursor', 'getselectedtext', 'setselectedtext',
    'scripts', 'current_script', 'active_script', 'hex2dec',
    'dec2hex', 'findimage', 'defcolor', 'defx',
    'defy', 'defxabs', 'defyabs', 'workwindowpid',
    'posex', 'copy', 'delete', 'insert',
    'errorlevel', 'screenheight', 'screenwidth', 'desktopheight',
    'desktopwidth', 'monitorheight', 'monitorwidth', 'monitor',
    'indexof', 'fileexists', 'filegetattr', 'filegetdate',
    'windowfrompoint', 'mousepos_x', 'mousepos_y', 'mouseposabs_x',
    'mouseposabs_y', 'abs', 'round', 'floor',
    'ceil', 'frac', 'sqrt', 'power',
    'exp', 'ln', 'log', 'sin',
    'cos', 'tan', 'arcsin', 'arccos',
    'arctan', 'degtorad', 'radtodeg', 'trunc',
    'pi', 'minx', 'maxx', 'mean',
    'mod', 'point_distance', 'point_direction', 'lengthdir_x',
    'lengthdir_y', 'is_real', 'is_string', 'chr',
    'ord', 'string_replace', 'string_count', 'string_lower',
    'string_upper', 'string_letters', 'string_digits', '',
    '', '', '', 'dayofweek',
    'claqua', 'clblack', 'clblue', 'cldkgray',
    'clfuchsia', 'clgray', 'clgreen', 'cllime',
    'clltgray', 'clmaroon', 'clnavy', 'clolive',
    'clpurple', 'clred', 'clsilver', 'clteal',
    'clwhite', 'clyellow', 'shownames', 'transparency',
    'pathfinding', 'criminalactions', 'eval', 'colortorgb',
    'colortored', 'colortogreen', 'colortoblue', 'ltrim',
    'rtrim', 'trim', 'showscriptprocessing', 'stopscrunknowncommand',
    'showtimervar', 'div', 'regexp', 'hotkeystart',
    'hotkeypause', 'homepath', 'exefilename', 'windowhandle',
    'rvpassword', '', 'rvwalkcount', 'rvstayinsidecave',
    'rvfisicalattack', '', '', '',
    '', '', '', '',
    '', '', '', '',
    '', '', '', '',
    'timer1', 'timer2', 'timer3', 'timer4',
    'chartohex', 'chartohexf', 'moduleaddress', 'relativeaddress2absolute',
    'absoluteaddress2relative', '', 'clickoffsetx', 'clickoffsety',
    'findoffsetx', 'findoffsety', 'sendexdelay', '',
    'emptylinedelay', 'mouseclickdelay', 'arrayaddress', 'promptpos_x',
    'promptpos_y', 'loghandle', 'logautoopen', 'messagesoutputto',
    'sendmessage', 'postmessage', 'getimage', 'deleteimage',
    'loadimage', 'saveimage', 'getfocus', 'adddate',
    'addyears', 'addmonths', 'adddays', 'addhours',
    'addminutes', 'addseconds', 'subdate', 'subyears',
    'submonths', 'subdays', 'subhours', 'subminutes',
    'subseconds', 'yearfromdate', 'monthfromdate', 'dayfromdate',
    'hourfromdate', 'minutefromdate', 'secondfromdate', 'timestamp',
    'datenow', 'timenow', 'backpack', 'backpackposx',
    'backpackposy', 'scriptpath', 'scriptname', 'findmemory',
    'terminated', 'setprocesspriority', 'getprocesspriority', 'setprocessaffinitymask',
    'checkgetcolor', 'version', 'suspendprocess', 'resumeprocess',
    ''
  );
  gScriptCmdNames: array[0..135] of string = (
    'continue', 'break', 'for', 'end_for',
    'goto', 'gosub', 'return', 'else',
    'macro_load', 'macro_play', 'repeat', 'end_repeat',
    'exec', 'terminate', 'waitfortarget', 'wait',
    'msg', 'say', 'send', 'sendex',
    'left', 'right', 'double_left', 'double_right',
    'left_down', 'left_up', 'right_down', 'right_up',
    'move', 'drag', 'flash', 'alarm',
    'end_script', 'pause_script', 'resume_script', 'stop_script',
    'start_script', 'call', 'proc', 'end_proc',
    'set', 'if', 'if_not', 'end_if',
    'while', 'while_not', 'end_while', ':',
    'injection', 'get', 'load_array', 'save_array',
    'showwindow', 'kleft', 'kright', 'double_kleft',
    'double_kright', 'kleft_down', 'kleft_up', 'kright_down',
    'kright_up', 'readmem', 'writemem', 'printscreen',
    'post', 'pleft', 'pright', 'double_pleft',
    'double_pright', 'pleft_down', 'pleft_up', 'pright_down',
    'pright_up', 'middle', 'double_middle', 'middle_down',
    'middle_up', 'pmiddle', 'double_pmiddle', 'pmiddle_down',
    'pmiddle_up', 'kmiddle', 'double_kmiddle', 'kmiddle_down',
    'kmiddle_up', 'post_up', 'post_down', 'send_up',
    'send_down', 'sendex_up', 'sendex_down', 'wheel_down',
    'wheel_up', 'pwheel_down', 'pwheel_up', 'kwheel_down',
    'kwheel_up', 'load_script', 'hint', 'macro_send',
    'execandwait', 'send217', 'filerename', 'filecopy',
    'filedelete', 'filesetattr', 'filesetdate', 'dircreate',
    'dirremove', 'dir', 'init_arr', 'log',
    'eval', 'write', 'switch', 'case',
    'end_switch', 'send217_up', 'send217_down', 'exit',
    'test', 'pluginload', 'pluginreload', 'pluginunload',
    'run_onload', 'end_run', 'sort_array', 'delete_array',
    'restart_script', 'move_smooth', 'keyboard', 'mouse',
    'servicegetstatus', 'servicestart', 'servicestop', 'servicesend'
  );

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    J := UpCase(I);
    Case I of
      'a'..'z', 'A'..'Z', '_': mHashTable[I] := Ord(J) - 64;
    else mHashTable[Char(I)] := 0;
    end;
  end;
end;

procedure TSynUOPilotSyn.InitIdent;
begin
  { пусто -- таблица ключевых слов Pascal заменена хэш-таблицей UoPilot
    (см. AddKeyword / IdentKind), вызов из Create оставлен на месте }
end;

function TSynUOPilotSyn.KeywordTablePtr: PRWTable;
begin
  Result := @fKeywords;
end;

function KeywordHash(H: TSynCustomHighlighter; P: PChar): Integer;
begin
  { хэш ключевого слова: сумма mHashTable по буквам, цифрам и '_' слова,
    усечённая до байта; длина слова по пути сохраняется в fStringLen }
  Result := 0;
  while P^ in ['0'..'9', 'A'..'Z', '_', 'a'..'z'] do
  begin
    Inc(Result, mHashTable[P^]);
    Inc(P);
  end;
  TSynUOPilotSyn(H).KeywordStringLen := P - TSynUOPilotSyn(H).KeywordToIdent;
  Result := Result and $FF;
end;

function TSynUOPilotSyn.KeyComp(const aKey: string): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if mHashTable[Temp^] <> mHashTable[aKey[i]] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end;

function TSynUOPilotSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey, I: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeywordHash(Self, MayBe);
  Result := tkIdentifier;
  for I := 0 to Length(fKeywords[HashKey].Names) - 1 do
    if KeyComp(fKeywords[HashKey].Names[I]) then
    begin
      Result := tkKey;
      fTokenKind := fKeywords[HashKey].Kinds[I];
    end;
end;

procedure TSynUOPilotSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #0: fProcTable[I] := NullProc;
      #10: fProcTable[I] := LFProc;
      #13: fProcTable[I] := CRProc;
      #1..#9, #11, #12, #14..#32:
        fProcTable[I] := SpaceProc;
      '#': fProcTable[I] := AsciiCharProc;
      '$': fProcTable[I] := IntegerProc;
      '%': fProcTable[I] := PercentProc;
      #39: fProcTable[I] := StringProc;
      '0'..'9': fProcTable[I] := NumberProc;
      'A'..'Z', 'a'..'z', '_':
        fProcTable[I] := IdentProc;
      '{': fProcTable[I] := BraceOpenProc;
      '}', '!', '"', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(': fProcTable[I] := RoundOpenProc;
            '.': fProcTable[I] := PointProc;
            ';': fProcTable[I] := SemicolonProc;
            '/': fProcTable[I] := SlashProc;
            '-': fProcTable[I] := MinusProc;
            ':', '>': fProcTable[I] := ColonOrGreaterProc;
            '<': fProcTable[I] := LowerProc;
            '@': fProcTable[I] := AddressOpProc;
          else
            fProcTable[I] := SymbolProc;
          end;
        end;
    else
      fProcTable[I] := UnknownProc;
    end;
end;

constructor TSynUOPilotSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fAsmAttri := TSynUOAttributes.Create('Assembler');
  fAsmAttri.Background := $FF000005;
  fAsmAttri.Foreground := clBlack;
  fAsmAttri.Style := [];
  AddAttribute(fAsmAttri);
  fCommentAttri := TSynUOAttributes.Create('Comment');
  fCommentAttri.Background := $FF000005;
  fCommentAttri.Foreground := clNavy;
  fCommentAttri.Style := [fsItalic];
  AddAttribute(fCommentAttri);
  fDirecAttri := TSynUOAttributes.Create('Preprocessor');
  fDirecAttri.Background := $FF000005;
  fDirecAttri.Foreground := clGreen;
  fDirecAttri.Style := [fsItalic];
  AddAttribute(fDirecAttri);
  fIdentifierAttri := TSynUOAttributes.Create('Identifier');
  fIdentifierAttri.Background := $FF000005;
  fIdentifierAttri.Foreground := clBlack;
  fIdentifierAttri.Style := [];
  AddAttribute(fIdentifierAttri);
  fKeyAttri := TSynUOAttributes.Create('Reserved Word');
  fKeyAttri.Background := $FF000005;
  fKeyAttri.Foreground := clBlack;
  fKeyAttri.Style := [fsBold];
  AddAttribute(fKeyAttri);
  fNumberAttri := TSynUOAttributes.Create('Number');
  fNumberAttri.Background := $FF000005;
  fNumberAttri.Foreground := clNavy;
  fNumberAttri.Style := [];
  AddAttribute(fNumberAttri);
  fFloatAttri := TSynUOAttributes.Create('Float');
  fFloatAttri.Background := $FF000005;
  fFloatAttri.Foreground := clNavy;
  fFloatAttri.Style := [];
  AddAttribute(fFloatAttri);
  fHexAttri := TSynUOAttributes.Create('Hexadecimal');
  fHexAttri.Background := $FF000005;
  fHexAttri.Foreground := clNavy;
  fHexAttri.Style := [];
  AddAttribute(fHexAttri);
  fStringAttri := TSynUOAttributes.Create('String');
  fStringAttri.Background := $FF000005;
  fStringAttri.Foreground := clNavy;
  fStringAttri.Style := [];
  AddAttribute(fStringAttri);
  fCharAttri := TSynUOAttributes.Create('Character');
  fCharAttri.Background := $FF000005;
  fCharAttri.Foreground := clNavy;
  fCharAttri.Style := [];
  AddAttribute(fCharAttri);
  fSpaceAttri := TSynUOAttributes.Create('Space');
  fSpaceAttri.Background := $FF000005;
  fSpaceAttri.Foreground := clBlack;
  fSpaceAttri.Style := [];
  AddAttribute(fSpaceAttri);
  fSymbolAttri := TSynUOAttributes.Create('Symbol');
  fSymbolAttri.Background := $FF000005;
  fSymbolAttri.Foreground := clBlack;
  fSymbolAttri.Style := [];
  AddAttribute(fSymbolAttri);
  fRWTimeAttri := TSynUOAttributes.Create('RW Time');
  fRWTimeAttri.Background := $FF000005;
  fRWTimeAttri.Foreground := clBlack;
  fRWTimeAttri.Style := [fsBold];
  AddAttribute(fRWTimeAttri);
  fRWTimeAttri.Kind := 1;
  fRWCharParamAttri := TSynUOAttributes.Create('RW CharParam');
  fRWCharParamAttri.Background := $FF000005;
  fRWCharParamAttri.Foreground := clBlack;
  fRWCharParamAttri.Style := [fsBold];
  AddAttribute(fRWCharParamAttri);
  fRWCharParamAttri.Kind := 2;
  fRWLastObjectAttri := TSynUOAttributes.Create('RW LastObject');
  fRWLastObjectAttri.Background := $FF000005;
  fRWLastObjectAttri.Foreground := clBlack;
  fRWLastObjectAttri.Style := [fsBold];
  AddAttribute(fRWLastObjectAttri);
  fRWLastObjectAttri.Kind := 3;
  fRWColorAndCordAttri := TSynUOAttributes.Create('RW ColorAndCord');
  fRWColorAndCordAttri.Background := $FF000005;
  fRWColorAndCordAttri.Foreground := clBlack;
  fRWColorAndCordAttri.Style := [fsBold];
  AddAttribute(fRWColorAndCordAttri);
  fRWColorAndCordAttri.Kind := 4;
  fRWFunctionAttri := TSynUOAttributes.Create('RW Function');
  fRWFunctionAttri.Background := $FF000005;
  fRWFunctionAttri.Foreground := clBlack;
  fRWFunctionAttri.Style := [fsBold];
  AddAttribute(fRWFunctionAttri);
  fRWFunctionAttri.Kind := 5;
  fRWMacrosAttri := TSynUOAttributes.Create('RW Macros');
  fRWMacrosAttri.Background := $FF000005;
  fRWMacrosAttri.Foreground := clBlack;
  fRWMacrosAttri.Style := [fsBold];
  AddAttribute(fRWMacrosAttri);
  fRWMacrosAttri.Kind := 7;
  fRWMouseAttri := TSynUOAttributes.Create('RW Mouse');
  fRWMouseAttri.Background := $FF000005;
  fRWMouseAttri.Foreground := clBlack;
  fRWMouseAttri.Style := [fsBold];
  AddAttribute(fRWMouseAttri);
  fRWMouseAttri.Kind := 8;
  fRWKeyboardAttri := TSynUOAttributes.Create('RW Keyboard');
  fRWKeyboardAttri.Background := $FF000005;
  fRWKeyboardAttri.Foreground := clBlack;
  fRWKeyboardAttri.Style := [fsBold];
  AddAttribute(fRWKeyboardAttri);
  fRWKeyboardAttri.Kind := 9;
  fRWForAttri := TSynUOAttributes.Create('RW For');
  fRWForAttri.Background := $FF000005;
  fRWForAttri.Foreground := clBlack;
  fRWForAttri.Style := [fsBold];
  AddAttribute(fRWForAttri);
  fRWForAttri.Kind := 10;
  fRWIfAttri := TSynUOAttributes.Create('RW If');
  fRWIfAttri.Background := $FF000005;
  fRWIfAttri.Foreground := clBlack;
  fRWIfAttri.Style := [fsBold];
  AddAttribute(fRWIfAttri);
  fRWIfAttri.Kind := 11;
  fRWSubAttri := TSynUOAttributes.Create('RW Sub');
  fRWSubAttri.Background := $FF000005;
  fRWSubAttri.Foreground := clBlack;
  fRWSubAttri.Style := [fsBold];
  AddAttribute(fRWSubAttri);
  fRWSubAttri.Kind := 12;
  fRWArrayAttri := TSynUOAttributes.Create('RW Array');
  fRWArrayAttri.Background := $FF000005;
  fRWArrayAttri.Foreground := clBlack;
  fRWArrayAttri.Style := [fsBold];
  AddAttribute(fRWArrayAttri);
  fRWArrayAttri.Kind := 14;
  fRWScriptAttri := TSynUOAttributes.Create('RW Script');
  fRWScriptAttri.Background := $FF000005;
  fRWScriptAttri.Foreground := clBlack;
  fRWScriptAttri.Style := [fsBold];
  AddAttribute(fRWScriptAttri);
  fRWScriptAttri.Kind := 15;
  fRWProcAttri := TSynUOAttributes.Create('RW Proc');
  fRWProcAttri.Background := $FF000005;
  fRWProcAttri.Foreground := clBlack;
  fRWProcAttri.Style := [fsBold];
  AddAttribute(fRWProcAttri);
  fRWProcAttri.Kind := 16;
  fRWWindowsAttri := TSynUOAttributes.Create('RW Windows');
  fRWWindowsAttri.Background := $FF000005;
  fRWWindowsAttri.Foreground := clBlack;
  fRWWindowsAttri.Style := [fsBold];
  AddAttribute(fRWWindowsAttri);
  fRWWindowsAttri.Kind := 17;
  fRWMemoryAttri := TSynUOAttributes.Create('RW Memory');
  fRWMemoryAttri.Background := $FF000005;
  fRWMemoryAttri.Foreground := clBlack;
  fRWMemoryAttri.Style := [fsBold];
  AddAttribute(fRWMemoryAttri);
  fRWMemoryAttri.Kind := 18;
  fRWMsgAttri := TSynUOAttributes.Create('RW Msg');
  fRWMsgAttri.Background := $FF000005;
  fRWMsgAttri.Foreground := clBlack;
  fRWMsgAttri.Style := [fsBold];
  AddAttribute(fRWMsgAttri);
  fRWMsgAttri.Kind := 19;
  fRWWaitAttri := TSynUOAttributes.Create('RW Wait');
  fRWWaitAttri.Background := $FF000005;
  fRWWaitAttri.Foreground := clBlack;
  fRWWaitAttri.Style := [fsBold];
  AddAttribute(fRWWaitAttri);
  fRWWaitAttri.Kind := 20;
  fRWOtherAttri := TSynUOAttributes.Create('RW Other');
  fRWOtherAttri.Background := $FF000005;
  fRWOtherAttri.Foreground := clBlack;
  fRWOtherAttri.Style := [fsBold];
  AddAttribute(fRWOtherAttri);
  fRWOtherAttri.Kind := 21;
  fRWGetAttri := TSynUOAttributes.Create('RW Get');
  fRWGetAttri.Background := $FF000005;
  fRWGetAttri.Foreground := clBlack;
  fRWGetAttri.Style := [fsBold];
  AddAttribute(fRWGetAttri);
  fRWGetAttri.Kind := 22;
  fRWEndScriptAttri := TSynUOAttributes.Create('RW EndScript');
  fRWEndScriptAttri.Background := $FF000005;
  fRWEndScriptAttri.Foreground := clBlack;
  fRWEndScriptAttri.Style := [fsBold];
  AddAttribute(fRWEndScriptAttri);
  fRWEndScriptAttri.Kind := 23;
  fRWPluginAttri := TSynUOAttributes.Create('RW Plugin');
  fRWPluginAttri.Background := $FF000005;
  fRWPluginAttri.Foreground := clBlack;
  fRWPluginAttri.Style := [fsBold];
  AddAttribute(fRWPluginAttri);
  fRWPluginAttri.Kind := 24;
  SetAttributesOnChange(DefHighlightChange);

  InitIdent;
  MakeMethodTables;
  fRange := rsUnknown;
  fAsmStart := False;
  fDefaultFilter := 'UO Pilot Script';
end;

procedure TSynUOPilotSyn.SetLine(const NewValue: string; LineNumber: Integer);
begin
  fLineStr := NewValue;
  fLineLen := Length(fLineStr);
  fLine := PChar(Pointer(fLineStr));
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

procedure TSynUOPilotSyn.AddressOpProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] = '@' then inc(Run);
end;

procedure TSynUOPilotSyn.AsciiCharProc;
begin
  fTokenID := tkChar;
  Inc(Run);
  while FLine[Run] in ['.', '0'..'9', 'A'..'Z', 'a'..'z'] do
    Inc(Run);
end;

procedure TSynUOPilotSyn.BorProc;
begin
  case fLine[Run] of
     #0: NullProc;
    #10: LFProc;
    #13: CRProc;
  else
    begin
      if fRange in [rsDirective, rsDirectiveAsm] then
        fTokenID := tkDirec
      else
        fTokenID := tkComment;
      repeat
        if fLine[Run] = '}' then
        begin
          Inc(Run);
          if fRange in [rsBorAsm, rsDirectiveAsm] then
            fRange := rsAsm
          else
            fRange := rsUnKnown;
          break;
        end;
        Inc(Run);
      until fLine[Run] in [#0, #10, #13];
    end;
  end;
end;

procedure TSynUOPilotSyn.BraceOpenProc;
begin
  if (fLine[Run + 1] = '$') then
  begin
    if fRange = rsAsm then
      fRange := rsDirectiveAsm
    else
      fRange := rsDirective;
  end
  else
  begin
    if fRange = rsAsm then
      fRange := rsBorAsm
    else
      fRange := rsBor;
  end;
  BorProc;
end;

procedure TSynUOPilotSyn.ColonOrGreaterProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] = '=' then inc(Run);
end;

procedure TSynUOPilotSyn.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if fLine[Run] = #10 then
    Inc(Run);
end;

procedure TSynUOPilotSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do
    Inc(Run);
end;

procedure TSynUOPilotSyn.PercentProc;
begin
  Inc(Run);
  fTokenID := tkKey;
  fTokenKind := 14;                        { 'RW Array' }
  while fLine[Run] in ['.', '0'..'9', 'A'..'Z', 'a'..'z'] do Inc(Run);
end;

procedure TSynUOPilotSyn.IntegerProc;
begin
  inc(Run);
  fTokenID := tkHex;
  while FLine[Run] in ['.', '0'..'9', 'A'..'Z', 'a'..'z'] do
    Inc(Run);
end;

procedure TSynUOPilotSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TSynUOPilotSyn.LowerProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] in ['=', '>'] then
    Inc(Run);
end;

procedure TSynUOPilotSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TSynUOPilotSyn.NumberProc;
var
  Hex, Dot: Boolean;
begin
  Hex := False;
  Dot := False;
  Inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['.', '0'..'9', 'A'..'F', 'a'..'f'] do
  begin
    case FLine[Run] of
      'A'..'Z', 'a'..'z':
        begin
          if Dot then
            Break;
          Hex := True;
        end;
      '.':
        if (FLine[Run + 1] = '.') or Hex then
          Break
        else
          Dot := True;
    end;
    Inc(Run);
  end;
end;

procedure TSynUOPilotSyn.PointProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] in ['.', ')'] then
    Inc(Run);
end;

procedure TSynUOPilotSyn.AnsiProc;
var
  Found: Boolean;
  I: Integer;
begin
  case fLine[Run] of
     #0: NullProc;
    #10: LFProc;
    #13: CRProc;
  else
    fTokenID := tkComment;
    repeat
      if (fLine[Run] = '*') and (fLine[Run + 1] = ')') then
      begin
        Found := False;
        I := Run - 1;
        while I >= 0 do
        begin
          if not (fLine[I] in [#9, ' ']) then
          begin
            Found := True;
            Break;
          end;
          Dec(I);
        end;
        if not Found then
        begin
          Inc(Run, 2);
          if fRange = rsAnsiAsm then
            fRange := rsAsm
          else
            fRange := rsUnKnown;
          break;
        end;
      end;
      Inc(Run);
    until fLine[Run] in [#0, #10, #13];
  end;
end;

procedure TSynUOPilotSyn.RoundOpenProc;
var
  Found: Boolean;
  I: Integer;
begin
  Inc(Run);
  case fLine[Run] of
    '*':
      begin
        Found := False;
        I := Run - 2;
        while I >= 0 do
        begin
          if not (fLine[I] in [#9, ' ']) then
          begin
            Found := True;
            Break;
          end;
          Dec(I);
        end;
        if not Found then
        begin
          Inc(Run);
          fRange := rsAnsi;
          fTokenID := tkComment;
          if not (fLine[Run] in [#0, #10, #13]) then
            AnsiProc;
        end;
      end;
    '.':
      begin
        inc(Run);
        fTokenID := tkSymbol;
      end;
  else
    fTokenID := tkSymbol;
  end;
end;

procedure TSynUOPilotSyn.SemicolonProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
  if fRange in [rsProperty, rsExports] then
    fRange := rsUnknown;
end;

procedure TSynUOPilotSyn.SlashProc;
begin
  Inc(Run);
  if fLine[Run] = '/' then
  begin
    fTokenID := tkComment;
    repeat
      Inc(Run);
    until fLine[Run] in [#0, #10, #13];
  end
  else
    fTokenID := tkSymbol;
end;

procedure TSynUOPilotSyn.MinusProc;
begin
  Inc(Run);
  if fLine[Run] = '-' then
  begin
    if (LowerCase(Copy(fLineStr, Run + 2, 3)) <> 'lua') and
       (LowerCase(Copy(fLineStr, Run + 2, 6)) <> 'endlua') then
    begin
      fTokenID := tkComment;
      repeat
        Inc(Run);
      until fLine[Run] in [#0, #10, #13];
    end
    else
      fTokenID := tkSymbol;
  end
  else
    fTokenID := tkSymbol;
end;

procedure TSynUOPilotSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TSynUOPilotSyn.StringProc;
begin
  fTokenID := tkString;
  Inc(Run);
  while not (fLine[Run] in [#0, #10, #13]) do begin
    if fLine[Run] = #39 then begin
      Inc(Run);
      if fLine[Run] <> #39 then
        break;
    end;
    Inc(Run);
  end;
end;

procedure TSynUOPilotSyn.SymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynUOPilotSyn.UnknownProc;
begin
  fTokenID := tkUnknown;
  Inc(Run);
  while (Run < fLineLen) and (fLine[Run] in [#$80..#$BF]) do
    Inc(Run);
end;

procedure TSynUOPilotSyn.Next;
begin
  fAsmStart := False;
  fTokenPos := Run;
  if Run >= fLineLen then
  begin
    NullProc;
    Exit;
  end;
  case fRange of
    rsAnsi, rsAnsiAsm:
      AnsiProc;
    rsBor, rsBorAsm, rsDirective, rsDirectiveAsm:
      BorProc;
  else
    fProcTable[fLine[Run]];
  end;
end;

function TSynUOPilotSyn.GetDefaultAttribute(Index: integer):
  TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    SYN_ATTR_SYMBOL: Result := fSymbolAttri;
  else
    Result := nil;
  end;
end;

function TSynUOPilotSyn.GetEol: Boolean;
begin
  Result := (fTokenID = tkNull) and (Run >= fLineLen);
end;

function TSynUOPilotSyn.GetToken: string;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetLength(Result, Len);
  if Len > 0 then
    System.Move(fLine[fTokenPos], Result[1], Len);
end;

procedure TSynUOPilotSyn.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenLength := Run - fTokenPos;
  if TokenLength > 0 then
    TokenStart := @fLine[fTokenPos]
  else
    TokenStart := nil;
end;

function TSynUOPilotSyn.GetTokenID: TtkTokenKind;
begin
  if not fAsmStart and (fRange = rsAsm)
    and not (fTokenId in [tkNull, tkComment, tkDirec, tkSpace])
  then
    Result := tkAsm
  else
    Result := fTokenId;
end;

function TSynUOPilotSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case GetTokenID of
    tkAsm: Result := fAsmAttri;
    tkComment: Result := fCommentAttri;
    tkDirec: Result := fDirecAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey:
      case fTokenKind of
        1 : Result := fRWTimeAttri;
        2 : Result := fRWCharParamAttri;
        3 : Result := fRWLastObjectAttri;
        4 : Result := fRWColorAndCordAttri;
        5 : Result := fRWFunctionAttri;
        7 : Result := fRWMacrosAttri;
        8 : Result := fRWMouseAttri;
        9 : Result := fRWKeyboardAttri;
        10: Result := fRWForAttri;
        11: Result := fRWIfAttri;
        12: Result := fRWSubAttri;
        14: Result := fRWArrayAttri;
        15: Result := fRWScriptAttri;
        16: Result := fRWProcAttri;
        17: Result := fRWWindowsAttri;
        18: Result := fRWMemoryAttri;
        19: Result := fRWMsgAttri;
        20: Result := fRWWaitAttri;
        21: Result := fRWOtherAttri;
        22: Result := fRWGetAttri;
        23: Result := fRWEndScriptAttri;
        24: Result := fRWPluginAttri;
      else
        Result := fKeyAttri;
      end;
    tkNumber: Result := fNumberAttri;
    tkFloat: Result := fFloatAttri;
    tkHex: Result := fHexAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkChar: Result := fCharAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fSymbolAttri;
  else
    Result := nil;
  end;
end;

function TSynUOPilotSyn.GetTokenKind: integer;
begin
  Result := Ord(GetTokenID);
end;

function TSynUOPilotSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TSynUOPilotSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

procedure TSynUOPilotSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

procedure TSynUOPilotSyn.ResetRange;
begin
  fRange := rsUnknown;
end;

function TSynUOPilotSyn.GetIdentChars: TSynIdentChars;
begin
  Result := ['_', '0'..'9', 'A'..'Z', 'a'..'z'];
end;

class function TSynUOPilotSyn.GetLanguageName: string;
begin
  Result := 'UO Pilot Script';
end;

class function TSynUOPilotSyn.GetCapabilities: TSynHighlighterCapabilities;
begin
  Result := [hcUserSettings];
end;

function TSynUOPilotSyn.IsFilterStored: boolean;
begin
  Result := fDefaultFilter <> 'UO Pilot Script';
end;

function LoadHighlighterAttri(H: TSynCustomHighlighter; A: TSynHighlighterAttributes; Ini: TMyMemIniFile; Index: Integer): Boolean;
var
  Sect, S, Sub: string;
  Bg, Fg, St: Integer;
  P: Integer;
begin
  { читает один атрибут подсветки из ini. Секция 'Highlighter', ключ -- имя
    атрибута, значение -- '<фон>,<цвет>,<стиль>'; отдельный ключ '<имя> List'
    держит слова этого вида через запятую. }
  Sect := 'Highlighter';
  Result := False;
  try
    S := Ini.ReadString(Sect, A.Name, '');
    if S <> '' then
    begin
      P := Pos(',', S);
      if not TryStrToInt(Copy(S, 1, P - 1), Bg) then
        Bg := $FFFFFF;
      Delete(S, 1, P);
      P := Pos(',', S);
      if not TryStrToInt(Copy(S, 1, P - 1), Fg) then
        Fg := 0;
      Delete(S, 1, P);
      if not TryStrToInt(S, St) then
        St := 3;
      Result := True;
    end;
  except
  end;
  if Result then
  begin
    A.Background := Bg;
    A.Foreground := Fg;
    A.IntegerStyle := St;
  end;
  try
    S := Ini.ReadString(Sect, A.Name + ' List', '');
    if S <> '' then
    begin
      P := Pos(',', S);
      Bg := 0;
      Fg := 1;
      while P > 0 do
      begin
        Sub := Copy(S, Fg, P - Fg);
        AddKeyword(H, UpperCase(Sub), TSynUOAttributes(A).Kind);
        Inc(P);
        Fg := P;
        P := PosEx(',', S, Fg);
      end;
      if P < Length(S) then
      begin
        Sub := Copy(S, Fg, Length(S) - Fg + 1);
        AddKeyword(H, UpperCase(Sub), TSynUOAttributes(A).Kind);
      end;
    end;
  except
  end;
end;

function SaveHighlighterAttri(H: TSynCustomHighlighter; A: TSynHighlighterAttributes; Ini: TMyMemIniFile; Sect: string): Boolean;
var
  S: string;
begin
  { зеркало LoadHighlighterAttri: пишет '<фон>,<цвет>,<стиль>' в ключ с именем
    атрибута }
  S := IntToStr(A.Background) + ',' + IntToStr(A.Foreground) + ',' +
    IntToStr(A.IntegerStyle);
  Ini.WriteString(Sect, A.Name, S);
  Result := True;
end;

function SaveHighlighter(H: TSynCustomHighlighter; Ini: TMyMemIniFile): Boolean;
var
  N: Integer;
  Def, Val, Sect, Ident: string;
  L: array of string;
  I, K: Integer;
  T: PRWTable;
  A: TSynHighlighterAttributes;
begin
  { обратная операция LoadHighlighter, вызывается из miSaveOptionsClick. Три
    прохода: 1) цвета каждого атрибута -- SaveHighlighterAttri; 2) по всей
    хэш-таблице (256 ведер): слова с флагом Mine собираются в L[kind] через
    запятые, по пути в нижний регистр; 3) снова по атрибутам: если у атрибута
    есть kind (> 0), собранная строка уходит в ключ '<имя> List' -- но только
    если этот ключ уже был в ini. }
  Sect := 'Highlighter';
  for I := 0 to H.AttrCount - 1 do
    SaveHighlighterAttri(H, H.Attribute[I], Ini, Sect);
  SetLength(L, H.AttrCount + 1);
  T := TSynUOPilotSyn(H).KeywordTablePtr;
  for K := 0 to 255 do
    for N := 0 to Length(T^[K].Names) - 1 do
      if T^[K].Mine[N] then
      begin
        I := T^[K].Kinds[N];
        if L[I] <> '' then
          L[I] := L[I] + ',';
        L[I] := L[I] + LowerCase(T^[K].Names[N]);
      end;
  Def := 'not found';
  for I := 0 to H.AttrCount - 1 do
  begin
    A := H.Attribute[I];
    N := TSynUOAttributes(A).Kind;
    if N > 0 then
    begin
      Ident := A.Name + ' List';
      if Ini.ReadString(Sect, Ident, Def) = Def then
        Val := ''
      else
        Val := L[N];
      Ini.WriteString(Sect, Ident, Val);
    end;
  end;
  Result := True;
end;

function LoadHighlighter(H: TSynCustomHighlighter; Ini: TMyMemIniFile): Boolean;
var
  I: Integer;
begin
  { заполняет таблицу ключевых слов подсветчика: 346 слов, каждое идёт через
    UpperCase в хэш-таблицу H }
  gNoFocusStealfq := True;
  AddKeyword(H, UpperCase('lua'), $17);
  AddKeyword(H, UpperCase('endlua'), $17);
  AddKeyword(H, UpperCase('EasyUO'), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[0]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[1]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[2]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[3]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[4]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[5]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[6]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[7]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[10]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[11]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[12]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[13]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[14]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[15]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[16]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[17]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[18]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[19]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[20]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[21]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[22]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[23]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[24]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[25]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[26]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[27]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[28]), $3);
  AddKeyword(H, UpperCase(gScriptVarNames[30]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[31]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[32]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[33]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[36]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[37]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[38]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[39]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[40]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[41]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[42]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[43]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[44]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[45]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[46]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[47]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[48]), $8);
  AddKeyword(H, UpperCase(gScriptVarNames[49]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[50]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[51]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[53]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[54]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[55]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[56]), $F);
  AddKeyword(H, UpperCase(gScriptVarNames[57]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[58]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[59]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[60]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[61]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[62]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[63]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[64]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[65]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[66]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[67]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[68]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[69]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[70]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[71]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[72]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[73]), $14);
  AddKeyword(H, UpperCase(gScriptVarNames[74]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[75]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[76]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[77]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[78]), $13);
  AddKeyword(H, UpperCase(gScriptVarNames[79]), $9);
  AddKeyword(H, UpperCase(gScriptVarNames[80]), $9);
  AddKeyword(H, UpperCase(gScriptVarNames[81]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[82]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[83]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[84]), $F);
  AddKeyword(H, UpperCase(gScriptVarNames[85]), $F);
  AddKeyword(H, UpperCase(gScriptVarNames[86]), $F);
  AddKeyword(H, UpperCase(gScriptVarNames[87]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[88]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[89]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[90]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[91]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[92]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[93]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[94]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[95]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[96]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[97]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[98]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[99]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[100]), $10);
  AddKeyword(H, UpperCase(gScriptVarNames[101]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[102]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[103]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[104]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[105]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[106]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[107]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[108]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[109]), $10);
  AddKeyword(H, UpperCase(gScriptVarNames[110]), $10);
  AddKeyword(H, UpperCase(gScriptVarNames[111]), $10);
  AddKeyword(H, UpperCase(gScriptVarNames[112]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[113]), $8);
  AddKeyword(H, UpperCase(gScriptVarNames[114]), $8);
  AddKeyword(H, UpperCase(gScriptVarNames[115]), $8);
  AddKeyword(H, UpperCase(gScriptVarNames[116]), $8);
  AddKeyword(H, UpperCase(gScriptVarNames[117]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[118]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[119]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[120]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[121]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[122]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[123]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[124]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[125]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[127]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[128]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[129]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[130]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[131]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[132]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[133]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[134]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[135]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[136]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[137]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[138]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[139]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[140]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[141]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[142]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[143]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[144]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[145]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[146]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[147]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[148]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[149]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[150]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[151]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[152]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[153]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[154]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[155]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[156]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[157]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[158]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[159]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[160]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[161]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[162]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[163]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[164]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[165]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[166]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[167]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[168]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[169]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[170]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[171]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[172]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[173]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[174]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[175]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[176]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[177]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[178]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[179]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[180]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[181]), $2);
  AddKeyword(H, UpperCase(gScriptVarNames[182]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[183]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[184]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[185]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[186]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[187]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[188]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[189]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[190]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[191]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[192]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[193]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[194]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[195]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[196]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[197]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[198]), $15);
  AddKeyword(H, UpperCase(gScriptVarNames[199]), $11);
  AddKeyword(H, UpperCase(gScriptVarNames[220]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[221]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[222]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[223]), $1);
  AddKeyword(H, UpperCase(gScriptVarNames[224]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[225]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[226]), $12);
  AddKeyword(H, UpperCase(gScriptVarNames[227]), $12);
  AddKeyword(H, UpperCase(gScriptVarNames[228]), $12);
  AddKeyword(H, UpperCase(gScriptVarNames[230]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[231]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[232]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[233]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[234]), $14);
  AddKeyword(H, UpperCase(gScriptVarNames[235]), $14);
  AddKeyword(H, UpperCase(gScriptVarNames[236]), $14);
  AddKeyword(H, UpperCase(gScriptVarNames[237]), $14);
  AddKeyword(H, UpperCase(gScriptVarNames[238]), $12);
  AddKeyword(H, UpperCase(gScriptVarNames[239]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[240]), $4);
  AddKeyword(H, UpperCase(gScriptVarNames[241]), $13);
  AddKeyword(H, UpperCase(gScriptVarNames[242]), $13);
  AddKeyword(H, UpperCase(gScriptVarNames[243]), $13);
  AddKeyword(H, UpperCase(gScriptVarNames[244]), $5);
  AddKeyword(H, UpperCase(gScriptVarNames[245]), $5);
  AddKeyword(H, UpperCase(gScriptCmdNames[0]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[1]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[2]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[3]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[4]), $C);
  AddKeyword(H, UpperCase(gScriptCmdNames[5]), $C);
  AddKeyword(H, UpperCase(gScriptCmdNames[6]), $C);
  AddKeyword(H, UpperCase(gScriptCmdNames[7]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[8]), $7);
  AddKeyword(H, UpperCase(gScriptCmdNames[9]), $7);
  AddKeyword(H, UpperCase(gScriptCmdNames[10]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[11]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[12]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[13]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[14]), $14);
  AddKeyword(H, UpperCase(gScriptCmdNames[15]), $14);
  AddKeyword(H, UpperCase(gScriptCmdNames[16]), $13);
  AddKeyword(H, UpperCase(gScriptCmdNames[17]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[18]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[19]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[20]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[21]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[22]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[23]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[24]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[25]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[26]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[27]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[28]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[29]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[30]), $13);
  AddKeyword(H, UpperCase(gScriptCmdNames[31]), $13);
  AddKeyword(H, UpperCase(gScriptCmdNames[32]), $17);
  AddKeyword(H, UpperCase(gScriptCmdNames[33]), $F);
  AddKeyword(H, UpperCase(gScriptCmdNames[34]), $F);
  AddKeyword(H, UpperCase(gScriptCmdNames[35]), $F);
  AddKeyword(H, UpperCase(gScriptCmdNames[36]), $F);
  AddKeyword(H, UpperCase(gScriptCmdNames[37]), $C);
  AddKeyword(H, UpperCase(gScriptCmdNames[38]), $C);
  AddKeyword(H, UpperCase(gScriptCmdNames[39]), $C);
  AddKeyword(H, UpperCase(gScriptCmdNames[40]), $16);
  AddKeyword(H, UpperCase(gScriptCmdNames[41]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[42]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[43]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[44]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[45]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[46]), $A);
  AddKeyword(H, UpperCase(gScriptCmdNames[48]), $15);
  AddKeyword(H, UpperCase(gScriptCmdNames[49]), $16);
  AddKeyword(H, UpperCase(gScriptCmdNames[50]), $E);
  AddKeyword(H, UpperCase(gScriptCmdNames[51]), $E);
  AddKeyword(H, UpperCase(gScriptCmdNames[52]), $11);
  AddKeyword(H, UpperCase(gScriptCmdNames[53]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[54]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[55]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[56]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[57]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[58]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[59]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[60]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[61]), $12);
  AddKeyword(H, UpperCase(gScriptCmdNames[62]), $12);
  AddKeyword(H, UpperCase(gScriptCmdNames[63]), $15);
  AddKeyword(H, UpperCase(gScriptCmdNames[64]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[65]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[66]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[67]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[68]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[69]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[70]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[71]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[72]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[73]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[74]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[75]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[76]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[77]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[78]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[79]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[80]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[81]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[82]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[83]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[84]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[85]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[86]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[87]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[88]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[89]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[90]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[91]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[92]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[93]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[94]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[95]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[96]), $8);
  AddKeyword(H, UpperCase(gScriptCmdNames[97]), $F);
  AddKeyword(H, UpperCase(gScriptCmdNames[98]), $13);
  AddKeyword(H, UpperCase(gScriptCmdNames[99]), $7);
  AddKeyword(H, UpperCase(gScriptCmdNames[100]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[101]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[102]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[103]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[104]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[105]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[106]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[107]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[108]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[109]), $10);
  AddKeyword(H, UpperCase(gScriptCmdNames[110]), $E);
  AddKeyword(H, UpperCase(gScriptCmdNames[111]), $13);
  AddKeyword(H, UpperCase(gScriptCmdNames[113]), $15);
  AddKeyword(H, UpperCase(gScriptCmdNames[114]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[115]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[116]), $B);
  AddKeyword(H, UpperCase(gScriptCmdNames[117]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[118]), $9);
  AddKeyword(H, UpperCase(gScriptCmdNames[119]), $17);
  AddKeyword(H, UpperCase(gScriptCmdNames[121]), $18);
  AddKeyword(H, UpperCase(gScriptCmdNames[122]), $18);
  AddKeyword(H, UpperCase(gScriptCmdNames[123]), $18);
  AddKeyword(H, UpperCase(gScriptCmdNames[126]), $E);
  AddKeyword(H, UpperCase(gScriptCmdNames[127]), $E);
  AddKeyword(H, UpperCase(gScriptCmdNames[128]), $F);
  AddKeyword(H, UpperCase(gScriptCmdNames[129]), $8);
  gNoFocusStealfq := False;
  for I := 0 to H.AttrCount - 1 do
    LoadHighlighterAttri(H, H.Attribute[I], Ini, I);
  Result := True;
end;

function AddKeyword(H: TSynCustomHighlighter; S: string; Kind: Integer): Boolean;
var
  T: PRWTable;
  N: Integer;
  Found: Boolean;
  I, K: Integer;
begin
  { добавляет слово в хэш-таблицу ключевых слов. Ведро -- запись из трёх
    динамических массивов; они растут вместе и только если слова ещё нет.
    Mine[N] := not <флаг загрузки>: пока идёт LoadHighlighter флаг взведён,
    поэтому встроенные слова помечаются False, а добавленные пользователем --
    True, и SaveHighlighter пишет в ini только последние. }
  K := KeywordHash(H, PChar(S));
  T := TSynUOPilotSyn(H).KeywordTablePtr;
  N := Length(T^[K].Names);
  Found := False;
  for I := 0 to N - 1 do
    if T^[K].Names[I] = S then
    begin
      N := I;
      Found := True;
      Break;
    end;
  if not Found then
  begin
    SetLength(T^[K].Names, N + 1);
    SetLength(T^[K].Kinds, N + 1);
    SetLength(T^[K].Mine, N + 1);
    T^[K].Names[N] := S;
  end;
  T^[K].Kinds[N] := Kind;
  T^[K].Mine[N] := not gNoFocusStealfq;
  Result := not Found;
end;

procedure DeleteKeyword(H: TSynCustomHighlighter; S: string);
var
  T: PRWTable;
  I, K: Integer;
begin
  { обратная AddKeyword: слово ищется в своём ведре и очищается на месте (имя
    в '', вид в 0, флаг Mine в False); массивы не укорачиваются }
  K := KeywordHash(H, PChar(S));
  T := TSynUOPilotSyn(H).KeywordTablePtr;
  for I := 0 to Length(T^[K].Names) - 1 do
    if T^[K].Names[I] = S then
    begin
      T^[K].Names[I] := '';
      T^[K].Kinds[I] := 0;
      T^[K].Mine[I] := False;
      Break;
    end;
end;

initialization
  MakeIdentTable;
end.
