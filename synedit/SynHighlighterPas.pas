{------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterPas.pas, released 2000-04-17.
The Original Code is based on the mwPasSyn.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is Martin Waldenburg.
Portions created by Martin Waldenburg are Copyright (C) 1998 Martin Waldenburg.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynHighlighterPas.pas,v 1.30 2005/01/28 16:53:24 maelh Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}
{
@abstract(Provides a Pascal/Delphi syntax highlighter for SynEdit)
@author(Martin Waldenburg)
@created(1998, converted to SynEdit 2000-04-07)
@lastmod(2001-11-21)
The SynHighlighterPas unit provides SynEdit with a Object Pascal syntax highlighter.
Two extra properties included (DelphiVersion, PackageSource):
  DelphiVersion - Allows you to enable/disable the highlighting of various
                  language enhancements added in the different Delphi versions.
  PackageSource - Allows you to enable/disable the highlighting of package keywords
}

{$IFNDEF QSYNHIGHLIGHTERPAS}
unit SynHighlighterPas;
{$ENDIF}

{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_CLX}
  QGraphics,
  QSynEditTypes,
  QSynEditHighlighter,
{$ELSE}
  Windows,
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
{$ENDIF}
  SysUtils,
  { TMyMemIniFile: parameter type of the load/save routines below. }
  MyIniFiles,
  Classes;

type
  TtkTokenKind = (tkAsm, tkComment, tkIdentifier, tkKey, tkNull, tkNumber,
    tkSpace, tkString, tkSymbol, tkUnknown, tkFloat, tkHex, tkDirec, tkChar);

  TRangeState = (rsANil, rsAnsi, rsAnsiAsm, rsAsm, rsBor, rsBorAsm, rsProperty,
    rsExports, rsDirective, rsDirectiveAsm, rsUnKnown);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

  { UoPilot: bucket of the keyword hash table. Three parallel dynamic arrays:
    the word itself, the kind of reserved word (see the fRW*Attri fields) and
    the "added by the user" flag -- SaveHighlighter writes out only those. }
  TlistRW = record
    Names: array of string;
    Kinds: array of Integer;
    Mine: array of Boolean;
  end;

  TDelphiVersion = (dvDelphi1, dvDelphi2, dvDelphi3, dvDelphi4, dvDelphi5,
    dvDelphi6, dvDelphi7, dvDelphi8, dvDelphi2005);

const
  LastDelphiVersion = dvDelphi2005;

type
  TSynPasSyn = class(TSynCustomHighlighter)
  private
    fAsmStart: Boolean;
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    { Local change: 256 entries, not 192 -- KeyHash masks the hash with $FF.
      The table itself is dead weight (InitIdent is empty and IdentKind goes
      through fKeywords), but it is kept in place. }
    fIdentFuncTable: array[0..255] of TIdentFuncTableFunc;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    fStringAttri: TSynHighlighterAttributes;
    fCharAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fFloatAttri: TSynHighlighterAttributes;
    fHexAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    { UoPilot script: one attribute per kind of reserved word }
    fRWTimeAttri: TSynHighlighterAttributes;                // kind 1
    fRWCharParamAttri: TSynHighlighterAttributes;           // kind 2
    fRWLastObjectAttri: TSynHighlighterAttributes;          // kind 3
    fRWColorAndCordAttri: TSynHighlighterAttributes;        // kind 4
    fRWFunctionAttri: TSynHighlighterAttributes;            // kind 5
    fRWMacrosAttri: TSynHighlighterAttributes;              // kind 7
    fRWMouseAttri: TSynHighlighterAttributes;               // kind 8
    fRWKeyboardAttri: TSynHighlighterAttributes;            // kind 9
    fRWForAttri: TSynHighlighterAttributes;                 // kind 10
    fRWIfAttri: TSynHighlighterAttributes;                  // kind 11
    fRWSubAttri: TSynHighlighterAttributes;                 // kind 12
    fRWArrayAttri: TSynHighlighterAttributes;               // kind 14
    fRWScriptAttri: TSynHighlighterAttributes;              // kind 15
    fRWProcAttri: TSynHighlighterAttributes;                // kind 16
    fRWWindowsAttri: TSynHighlighterAttributes;             // kind 17
    fRWMemoryAttri: TSynHighlighterAttributes;              // kind 18
    fRWMsgAttri: TSynHighlighterAttributes;                 // kind 19
    fRWWaitAttri: TSynHighlighterAttributes;                // kind 20
    fRWOtherAttri: TSynHighlighterAttributes;               // kind 21
    fRWGetAttri: TSynHighlighterAttributes;                 // kind 22
    fRWEndScriptAttri: TSynHighlighterAttributes;           // kind 23
    fRWPluginAttri: TSynHighlighterAttributes;              // kind 24
    fTokenKind: Integer;
    fSymbolAttri: TSynHighlighterAttributes;
    fAsmAttri: TSynHighlighterAttributes;
    fCommentAttri: TSynHighlighterAttributes;
    fDirecAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    { hash table of the UoPilot script keywords: 256 buckets, filled by
      AddKeyword, read by IdentKind. Must stay the LAST field. }
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
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
    procedure ResetRange; override;
    procedure SetLine(NewValue: string; LineNumber:Integer); override;
    procedure SetRange(Value: Pointer); override;
    property IdentChars;
  published
    property AsmAttri: TSynHighlighterAttributes read fAsmAttri write fAsmAttri;
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri
      write fCommentAttri;
    property DirectiveAttri: TSynHighlighterAttributes read fDirecAttri
      write fDirecAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri
      write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri
      write fNumberAttri;
    property FloatAttri: TSynHighlighterAttributes read fFloatAttri
      write fFloatAttri;
    property HexAttri: TSynHighlighterAttributes read fHexAttri
      write fHexAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri
      write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri
      write fStringAttri;
    property CharAttri: TSynHighlighterAttributes read fCharAttri
      write fCharAttri;
    property SymbolAttri: TSynHighlighterAttributes read fSymbolAttri
      write fSymbolAttri;
  end;

{ Local change: the keyword and attribute helpers used by this project are
  declared here as unit routines. They reach the fields of the highlighter
  through the overlay types below rather than through its properties. }
type
  { Overlay for TSynHighlighterAttributes: gives access to the kind of token
    the attribute stands for, used when loading and saving keyword lists. }
  TUoPAttriRec = record
    Pad00: array[$00..$27] of Byte;
    Kind: Integer;                     // $28  token kind
  end;
  TUoPAttri = ^TUoPAttriRec;

  TRWTable = array[0..255] of TlistRW;

  TUoPHighlighter = class(TComponent)
  public
    Pad30: array[$30..$5F] of Byte;
    Attrs: TStringList;                // $60  fAttributes
    Pad64: array[$64..$883] of Byte;
    StringLen: Integer;                // $884  fStringLen
    ToIdent: PChar;                    // $888  fToIdent
    Pad88C: array[$88C..$1123] of Byte;
    Table: TRWTable;                  // $1124
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
{$IFDEF SYN_CLX}
  QSynEditStrConst,
{$ELSE}
  SynEditStrConst,
{$ENDIF}
  StrUtils,
  { used from the implementation section only: Unit1 provides
    gNoFocusStealfq, read by the routines below, while the interface of
    Unit1 in turn uses this unit }
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

procedure TSynPasSyn.InitIdent;
begin
  { Local change: empty -- the Pascal keyword table was replaced by the
    UoPilot hash table (see AddKeyword / IdentKind), the call from Create
    is kept in place }
end;

function KeywordHash(H: TSynCustomHighlighter; P: PChar): Integer;
var
  HL: TUoPHighlighter;
begin
  { hash of a keyword: the sum of mHashTable over the letters, digits and
    '_' of the word, truncated to a byte; the length of the word is stored
    in fStringLen along the way }
  HL := TUoPHighlighter(H);
  Result := 0;
  while P^ in ['0'..'9', 'A'..'Z', '_', 'a'..'z'] do
  begin
    Inc(Result, mHashTable[P^]);
    Inc(P);
  end;
  HL.StringLen := P - HL.ToIdent;
  Result := Result and $FF;
end;

function TSynPasSyn.KeyComp(const aKey: string): Boolean;
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
end; { KeyComp }

function TSynPasSyn.IdentKind(MayBe: PChar): TtkTokenKind;
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

procedure TSynPasSyn.MakeMethodTables;
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

constructor TSynPasSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  fAsmAttri := TSynHighlighterAttributes.Create(SYNS_AttrAssembler);
  fAsmAttri.Background := $FF000005;
  fAsmAttri.Foreground := clBlack;
  fAsmAttri.Style := [];
  AddAttribute(fAsmAttri);
  fCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment);
  fCommentAttri.Background := $FF000005;
  fCommentAttri.Foreground := clNavy;
  fCommentAttri.Style := [fsItalic];
  AddAttribute(fCommentAttri);
  fDirecAttri := TSynHighlighterAttributes.Create(SYNS_AttrPreprocessor);
  fDirecAttri.Background := $FF000005;
  fDirecAttri.Foreground := clGreen;
  fDirecAttri.Style := [fsItalic];
  AddAttribute(fDirecAttri);
  fIdentifierAttri := TSynHighlighterAttributes.Create(SYNS_AttrIdentifier);
  fIdentifierAttri.Background := $FF000005;
  fIdentifierAttri.Foreground := clBlack;
  fIdentifierAttri.Style := [];
  AddAttribute(fIdentifierAttri);
  fKeyAttri := TSynHighlighterAttributes.Create(SYNS_AttrReservedWord);
  fKeyAttri.Background := $FF000005;
  fKeyAttri.Foreground := clBlack;
  fKeyAttri.Style := [fsBold];
  AddAttribute(fKeyAttri);
  fNumberAttri := TSynHighlighterAttributes.Create(SYNS_AttrNumber);
  fNumberAttri.Background := $FF000005;
  fNumberAttri.Foreground := clNavy;
  fNumberAttri.Style := [];
  AddAttribute(fNumberAttri);
  fFloatAttri := TSynHighlighterAttributes.Create(SYNS_AttrFloat);
  fFloatAttri.Background := $FF000005;
  fFloatAttri.Foreground := clNavy;
  fFloatAttri.Style := [];
  AddAttribute(fFloatAttri);
  fHexAttri := TSynHighlighterAttributes.Create(SYNS_AttrHexadecimal);
  fHexAttri.Background := $FF000005;
  fHexAttri.Foreground := clNavy;
  fHexAttri.Style := [];
  AddAttribute(fHexAttri);
  fStringAttri := TSynHighlighterAttributes.Create(SYNS_AttrString);
  fStringAttri.Background := $FF000005;
  fStringAttri.Foreground := clNavy;
  fStringAttri.Style := [];
  AddAttribute(fStringAttri);
  fCharAttri := TSynHighlighterAttributes.Create(SYNS_AttrCharacter);
  fCharAttri.Background := $FF000005;
  fCharAttri.Foreground := clNavy;
  fCharAttri.Style := [];
  AddAttribute(fCharAttri);
  fSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace);
  fSpaceAttri.Background := $FF000005;
  fSpaceAttri.Foreground := clBlack;
  fSpaceAttri.Style := [];
  AddAttribute(fSpaceAttri);
  fSymbolAttri := TSynHighlighterAttributes.Create(SYNS_AttrSymbol);
  fSymbolAttri.Background := $FF000005;
  fSymbolAttri.Foreground := clBlack;
  fSymbolAttri.Style := [];
  AddAttribute(fSymbolAttri);
  fRWTimeAttri := TSynHighlighterAttributes.Create('RW Time');
  fRWTimeAttri.Background := $FF000005;
  fRWTimeAttri.Foreground := clBlack;
  fRWTimeAttri.Style := [fsBold];
  AddAttribute(fRWTimeAttri);
  fRWTimeAttri.Kind := 1;
  fRWCharParamAttri := TSynHighlighterAttributes.Create('RW CharParam');
  fRWCharParamAttri.Background := $FF000005;
  fRWCharParamAttri.Foreground := clBlack;
  fRWCharParamAttri.Style := [fsBold];
  AddAttribute(fRWCharParamAttri);
  fRWCharParamAttri.Kind := 2;
  fRWLastObjectAttri := TSynHighlighterAttributes.Create('RW LastObject');
  fRWLastObjectAttri.Background := $FF000005;
  fRWLastObjectAttri.Foreground := clBlack;
  fRWLastObjectAttri.Style := [fsBold];
  AddAttribute(fRWLastObjectAttri);
  fRWLastObjectAttri.Kind := 3;
  fRWColorAndCordAttri := TSynHighlighterAttributes.Create('RW ColorAndCord');
  fRWColorAndCordAttri.Background := $FF000005;
  fRWColorAndCordAttri.Foreground := clBlack;
  fRWColorAndCordAttri.Style := [fsBold];
  AddAttribute(fRWColorAndCordAttri);
  fRWColorAndCordAttri.Kind := 4;
  fRWFunctionAttri := TSynHighlighterAttributes.Create('RW Function');
  fRWFunctionAttri.Background := $FF000005;
  fRWFunctionAttri.Foreground := clBlack;
  fRWFunctionAttri.Style := [fsBold];
  AddAttribute(fRWFunctionAttri);
  fRWFunctionAttri.Kind := 5;
  fRWMacrosAttri := TSynHighlighterAttributes.Create('RW Macros');
  fRWMacrosAttri.Background := $FF000005;
  fRWMacrosAttri.Foreground := clBlack;
  fRWMacrosAttri.Style := [fsBold];
  AddAttribute(fRWMacrosAttri);
  fRWMacrosAttri.Kind := 7;
  fRWMouseAttri := TSynHighlighterAttributes.Create('RW Mouse');
  fRWMouseAttri.Background := $FF000005;
  fRWMouseAttri.Foreground := clBlack;
  fRWMouseAttri.Style := [fsBold];
  AddAttribute(fRWMouseAttri);
  fRWMouseAttri.Kind := 8;
  fRWKeyboardAttri := TSynHighlighterAttributes.Create('RW Keyboard');
  fRWKeyboardAttri.Background := $FF000005;
  fRWKeyboardAttri.Foreground := clBlack;
  fRWKeyboardAttri.Style := [fsBold];
  AddAttribute(fRWKeyboardAttri);
  fRWKeyboardAttri.Kind := 9;
  fRWForAttri := TSynHighlighterAttributes.Create('RW For');
  fRWForAttri.Background := $FF000005;
  fRWForAttri.Foreground := clBlack;
  fRWForAttri.Style := [fsBold];
  AddAttribute(fRWForAttri);
  fRWForAttri.Kind := 10;
  fRWIfAttri := TSynHighlighterAttributes.Create('RW If');
  fRWIfAttri.Background := $FF000005;
  fRWIfAttri.Foreground := clBlack;
  fRWIfAttri.Style := [fsBold];
  AddAttribute(fRWIfAttri);
  fRWIfAttri.Kind := 11;
  fRWSubAttri := TSynHighlighterAttributes.Create('RW Sub');
  fRWSubAttri.Background := $FF000005;
  fRWSubAttri.Foreground := clBlack;
  fRWSubAttri.Style := [fsBold];
  AddAttribute(fRWSubAttri);
  fRWSubAttri.Kind := 12;
  fRWArrayAttri := TSynHighlighterAttributes.Create('RW Array');
  fRWArrayAttri.Background := $FF000005;
  fRWArrayAttri.Foreground := clBlack;
  fRWArrayAttri.Style := [fsBold];
  AddAttribute(fRWArrayAttri);
  fRWArrayAttri.Kind := 14;
  fRWScriptAttri := TSynHighlighterAttributes.Create('RW Script');
  fRWScriptAttri.Background := $FF000005;
  fRWScriptAttri.Foreground := clBlack;
  fRWScriptAttri.Style := [fsBold];
  AddAttribute(fRWScriptAttri);
  fRWScriptAttri.Kind := 15;
  fRWProcAttri := TSynHighlighterAttributes.Create('RW Proc');
  fRWProcAttri.Background := $FF000005;
  fRWProcAttri.Foreground := clBlack;
  fRWProcAttri.Style := [fsBold];
  AddAttribute(fRWProcAttri);
  fRWProcAttri.Kind := 16;
  fRWWindowsAttri := TSynHighlighterAttributes.Create('RW Windows');
  fRWWindowsAttri.Background := $FF000005;
  fRWWindowsAttri.Foreground := clBlack;
  fRWWindowsAttri.Style := [fsBold];
  AddAttribute(fRWWindowsAttri);
  fRWWindowsAttri.Kind := 17;
  fRWMemoryAttri := TSynHighlighterAttributes.Create('RW Memory');
  fRWMemoryAttri.Background := $FF000005;
  fRWMemoryAttri.Foreground := clBlack;
  fRWMemoryAttri.Style := [fsBold];
  AddAttribute(fRWMemoryAttri);
  fRWMemoryAttri.Kind := 18;
  fRWMsgAttri := TSynHighlighterAttributes.Create('RW Msg');
  fRWMsgAttri.Background := $FF000005;
  fRWMsgAttri.Foreground := clBlack;
  fRWMsgAttri.Style := [fsBold];
  AddAttribute(fRWMsgAttri);
  fRWMsgAttri.Kind := 19;
  fRWWaitAttri := TSynHighlighterAttributes.Create('RW Wait');
  fRWWaitAttri.Background := $FF000005;
  fRWWaitAttri.Foreground := clBlack;
  fRWWaitAttri.Style := [fsBold];
  AddAttribute(fRWWaitAttri);
  fRWWaitAttri.Kind := 20;
  fRWOtherAttri := TSynHighlighterAttributes.Create('RW Other');
  fRWOtherAttri.Background := $FF000005;
  fRWOtherAttri.Foreground := clBlack;
  fRWOtherAttri.Style := [fsBold];
  AddAttribute(fRWOtherAttri);
  fRWOtherAttri.Kind := 21;
  fRWGetAttri := TSynHighlighterAttributes.Create('RW Get');
  fRWGetAttri.Background := $FF000005;
  fRWGetAttri.Foreground := clBlack;
  fRWGetAttri.Style := [fsBold];
  AddAttribute(fRWGetAttri);
  fRWGetAttri.Kind := 22;
  fRWEndScriptAttri := TSynHighlighterAttributes.Create('RW EndScript');
  fRWEndScriptAttri.Background := $FF000005;
  fRWEndScriptAttri.Foreground := clBlack;
  fRWEndScriptAttri.Style := [fsBold];
  AddAttribute(fRWEndScriptAttri);
  fRWEndScriptAttri.Kind := 23;
  fRWPluginAttri := TSynHighlighterAttributes.Create('RW Plugin');
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
  fDefaultFilter := SYNS_FilterPascal;
end; { Create }

procedure TSynPasSyn.SetLine(NewValue: string; LineNumber:Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TSynPasSyn.AddressOpProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] = '@' then inc(Run);
end;

procedure TSynPasSyn.AsciiCharProc;
begin
  fTokenID := tkChar;
  Inc(Run);
  while FLine[Run] in ['.', '0'..'9', 'A'..'Z', 'a'..'z'] do
    Inc(Run);
end;

procedure TSynPasSyn.BorProc;
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

procedure TSynPasSyn.BraceOpenProc;
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

procedure TSynPasSyn.ColonOrGreaterProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] = '=' then inc(Run);
end;

procedure TSynPasSyn.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if fLine[Run] = #10 then
    Inc(Run);
end; { CRProc }


procedure TSynPasSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do
    Inc(Run);
end; { IdentProc }


procedure TSynPasSyn.PercentProc;
begin
  Inc(Run);
  fTokenID := tkKey;
  fTokenKind := 14;                        { 'RW Array' }
  while fLine[Run] in ['.', '0'..'9', 'A'..'Z', 'a'..'z'] do Inc(Run);
end;

procedure TSynPasSyn.IntegerProc;
begin
  inc(Run);
  fTokenID := tkHex;
  while FLine[Run] in ['.', '0'..'9', 'A'..'Z', 'a'..'z'] do
    Inc(Run);
end; { IntegerProc }


procedure TSynPasSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end; { LFProc }


procedure TSynPasSyn.LowerProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] in ['=', '>'] then
    Inc(Run);
end; { LowerProc }


procedure TSynPasSyn.NullProc;
begin
  fTokenID := tkNull;
end; { NullProc }

procedure TSynPasSyn.NumberProc;
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
end; { NumberProc }

procedure TSynPasSyn.PointProc;
begin
  fTokenID := tkSymbol;
  inc(Run);
  if fLine[Run] in ['.', ')'] then
    Inc(Run);
end; { PointProc }

procedure TSynPasSyn.AnsiProc;
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

procedure TSynPasSyn.RoundOpenProc;
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

procedure TSynPasSyn.SemicolonProc;
begin
  Inc(Run);
  fTokenID := tkSymbol;
  if fRange in [rsProperty, rsExports] then
    fRange := rsUnknown;
end;

procedure TSynPasSyn.SlashProc;
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

procedure TSynPasSyn.MinusProc;
begin
  Inc(Run);
  if fLine[Run] = '-' then
  begin
    if (LowerCase(Copy(fLine, Run + 2, 3)) <> 'lua') and
       (LowerCase(Copy(fLine, Run + 2, 6)) <> 'endlua') then
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

procedure TSynPasSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TSynPasSyn.StringProc;
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

procedure TSynPasSyn.SymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TSynPasSyn.UnknownProc;
begin
{$IFDEF SYN_MBCSSUPPORT}
  if FLine[Run] in LeadBytes then
    Inc(Run, 2)
  else
{$ENDIF}
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TSynPasSyn.Next;
begin
  fAsmStart := False;
  fTokenPos := Run;
  case fRange of
    rsAnsi, rsAnsiAsm:
      AnsiProc;
    rsBor, rsBorAsm, rsDirective, rsDirectiveAsm:
      BorProc;
  else
    fProcTable[fLine[Run]];
  end;
end;

function TSynPasSyn.GetDefaultAttribute(Index: integer):
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

function TSynPasSyn.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;
end;

function TSynPasSyn.GetToken: string;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TSynPasSyn.GetTokenID: TtkTokenKind;
begin
  if not fAsmStart and (fRange = rsAsm)
    and not (fTokenId in [tkNull, tkComment, tkDirec, tkSpace])
  then
    Result := tkAsm
  else
    Result := fTokenId;
end;

function TSynPasSyn.GetTokenAttribute: TSynHighlighterAttributes;
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

function TSynPasSyn.GetTokenKind: integer;
begin
  Result := Ord(GetTokenID);
end;

function TSynPasSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TSynPasSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

procedure TSynPasSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

procedure TSynPasSyn.ResetRange;
begin
  fRange:= rsUnknown;
end;

function TSynPasSyn.GetIdentChars: TSynIdentChars;
begin
  Result := TSynValidStringChars;
end;

class function TSynPasSyn.GetLanguageName: string;
begin
  Result := SYNS_LangPascal;
end;

class function TSynPasSyn.GetCapabilities: TSynHighlighterCapabilities;
begin
  Result := inherited GetCapabilities + [hcUserSettings];
end;

function TSynPasSyn.IsFilterStored: boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterPascal;
end;

function LoadHighlighterAttri(H: TSynCustomHighlighter; A: TSynHighlighterAttributes; Ini: TMyMemIniFile; Index: Integer): Boolean;
var
  Sect, S, Sub: string;
  Bg, Fg, St: Integer;
  P: Integer;
begin
  { reads one highlighter attribute from the ini. Section 'Highlighter',
    the key is the name of the attribute and the value is
    '<background>,<foreground>,<style>'; a separate key '<name> List' holds
    the words of that kind, separated by commas. }
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
        AddKeyword(H, UpperCase(Sub), TUoPAttri(A).Kind);
        Inc(P);
        Fg := P;
        P := PosEx(',', S, Fg);
      end;
      if P < Length(S) then
      begin
        Sub := Copy(S, Fg, Length(S) - Fg + 1);
        AddKeyword(H, UpperCase(Sub), TUoPAttri(A).Kind);
      end;
    end;
  except
  end;
end;

function SaveHighlighterAttri(H: TSynCustomHighlighter; A: TSynHighlighterAttributes; Ini: TMyMemIniFile; Sect: string): Boolean;
var
  S: string;
begin
  { mirror of LoadHighlighterAttri: writes '<background>,<foreground>,<style>'
    into the key named after the attribute }
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
  HA: TSynCustomHighlighter absolute H;
begin
  { inverse of LoadHighlighter, called from miSaveOptionsClick. Three passes:
      1) the colours of every attribute -- SaveHighlighterAttri;
      2) over the whole hash table (256 buckets): the words flagged Mine are
         collected into L[kind] through commas, lowercased on the way;
      3) over the attributes again: if an attribute has a kind (> 0), the
         collected string goes into the key '<name> List' -- but only if
         that key was already present in the ini. }
  Sect := 'Highlighter';
  for I := 0 to TUoPHighlighter(H).Attrs.Count - 1 do
    SaveHighlighterAttri(H, TSynHighlighterAttributes(
      TUoPHighlighter(H).Attrs.Objects[I]), Ini, Sect);
  SetLength(L, TUoPHighlighter(H).Attrs.Count + 1);
  for K := 0 to 255 do
    for N := 0 to Length(TUoPHighlighter(H).Table[K].Names) - 1 do
      if TUoPHighlighter(H).Table[K].Mine[N] then
      begin
        I := TUoPHighlighter(H).Table[K].Kinds[N];
        if L[I] <> '' then
          L[I] := L[I] + ',';
        L[I] := L[I] + LowerCase(TUoPHighlighter(H).Table[K].Names[N]);
      end;
  Def := 'not found';
  for I := 0 to TUoPHighlighter(H).Attrs.Count - 1 do
  begin
    N := TUoPAttri(TUoPHighlighter(H).Attrs.Objects[I]).Kind;
    if N > 0 then
    begin
      Ident := TSynHighlighterAttributes(
        TUoPHighlighter(HA).Attrs.Objects[I]).Name + ' List';
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
  { fills the keyword table of the highlighter: 346 words, each of them
    goes through UpperCase into the hash table of H }
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
  for I := 0 to TUoPHighlighter(H).Attrs.Count - 1 do
    LoadHighlighterAttri(H, TSynHighlighterAttributes(TUoPHighlighter(H).Attrs.Objects[I * 1]), Ini, I);
  Result := True;
end;

function AddKeyword(H: TSynCustomHighlighter; S: string; Kind: Integer): Boolean;
var
  HL: TUoPHighlighter;
  N: Integer;
  Found: Boolean;
  I, K: Integer;
begin
  { adds a word to the keyword hash table. A bucket is a record of three
    dynamic arrays; they grow together and only if the word is not there
    yet. Mine[N] := not <loading flag>: while LoadHighlighter runs the flag
    is set, so the built-in words are marked False and the ones added by
    the user True, and SaveHighlighter writes only the latter into the ini. }
  K := KeywordHash(H, PChar(S));
  HL := TUoPHighlighter(H);
  N := Length(HL.Table[K].Names);
  Found := False;
  for I := 0 to N - 1 do
    if HL.Table[K].Names[I] = S then
    begin
      N := I;
      Found := True;
      Break;
    end;
  if not Found then
  begin
    SetLength(HL.Table[K].Names, N + 1);
    SetLength(HL.Table[K].Kinds, N + 1);
    SetLength(HL.Table[K].Mine, N + 1);
    HL.Table[K].Names[N] := S;
  end;
  HL.Table[K].Kinds[N] := Kind;
  HL.Table[K].Mine[N] := not gNoFocusStealfq;
  Result := not Found;
end;

procedure DeleteKeyword(H: TSynCustomHighlighter; S: string);
var
  I, K: Integer;
begin
  { inverse of AddKeyword: the word is found in its bucket and cleared in
    place (the name to '', the kind to 0, the Mine flag to False); the
    arrays are not shortened }
  K := KeywordHash(H, PChar(S));
  for I := 0 to Length(TUoPHighlighter(H).Table[K].Names) - 1 do
    if TUoPHighlighter(H).Table[K].Names[I] = S then
    begin
      TUoPHighlighter(H).Table[K].Names[I] := '';
      TUoPHighlighter(H).Table[K].Kinds[I] := 0;
      TUoPHighlighter(H).Table[K].Mine[I] := False;
      Break;
    end;
end;

var
  sPasIdle: string;

initialization
  MakeIdentTable;
{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TSynPasSyn);
{$ENDIF}
end.
