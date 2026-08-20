unit HotKeyMgr;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Updates :
  11/14/1999 : Added Delphi 5 support

               !!! You have to add the path to the file "dsgnintf,pas" to
               your library. e.g. ...\Borland\Delphi5\Source\Toolsapi !!!
}

{ Designed by Alexandre Guillien 11/11/1999

  This component allows you to easily use hot keys in your project. These hot keys
  are active even if your application is not active.

  Component use :
    Drop it on your Form/DataModule
    Dbl click on it or Edit the HotKeys property.
    In the editor, select the key and the optional shifts (Shift, Alt or Ctrl)
    Give a name to the hot key (optional).
    Finally, double click on the OnHotKeyActivation event in the object inspector.
    The will create an event where you will be able to make your code.

  E-Mail = AGuillien@csi.com
  Mail : 12, rue Rhonat      69100 Villeurbanne      FRANCE
}

{$IFDEF VER120}
{$DEFINE VER100}
{$ENDIF}

interface

uses
  Classes, Windows, Messages, Forms;

type
  { Своего множества тут не надо -- берём Classes.TShiftState. Именно
    ПСЕВДОНИМ (без слова `type`), нового типа не заводим: Unit1 пишет
    приведение полным именем HotKeyMgr.TShiftState(M). }
  TShiftState = Classes.TShiftState;

const
  { Те же три имени -- чтобы Unit1 мог писать HotKeyMgr.ssAlt полным
    именем. }
  ssShift = Classes.ssShift;
  ssAlt = Classes.ssAlt;
  ssCtrl = Classes.ssCtrl;

type

  THotKeyManager = class;

  THotKeyItem = class(TCollectionItem)
  private
    FHotKeyId: Integer;
    FOnHotKey: TNotifyEvent;
    FName: string;
    {}
    FHotKey: Integer;
    FShiftState: TShiftState;
    // Модификаторы и код запоминает RegisterHotKey: по ним WMHotKey
    // перерегистрирует клавишу после сквозного нажатия.
  public
    FShift: Integer;
    FKey: Integer;
    FRegistered: Boolean;
  public
    // WAV, который играем на срабатывание.
    FSound: string;
    FFlag34: Integer;
  private
    procedure SetShiftState(State: TShiftState);
    function GetHotKey: string;
    procedure SetHotKey(Key: string);
    function GetManager: THotKeyManager;
  protected
    function GetDisplayName: string; override;
    {}
    function RegisterHotKey: Boolean;
    procedure UnRegisterHotKey;
    {}
    property HotKeyId: Integer read FHotKeyId;
    property Manager: THotKeyManager read GetManager;
  public
    function GetNamePath: string; override;
    {}
    procedure Assign(Item: TPersistent); override;
  published
    property Name: string read FName write FName;
    property ShiftState: TShiftState read FShiftState write SetShiftState;
    property HotKey: string read GetHotKey write SetHotKey;
    property OnHotKeyActivation: TNotifyEvent read FOnHotKey write FOnHotKey;
  end;

  THotKeyCollection = class(TCollection)
  private
    FOwner: THotKeyManager;
    function GetItem(Idx: Integer): THotKeyItem;
    procedure SetItem(Idx: Integer; Item: THotKeyItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(Manager: THotKeyManager);
    {}
    property Items[Idx: Integer]: THotKeyItem read GetItem write SetItem; default;
  end;

  THotKeyManager = class(TComponent)
  private
    FHotKeys: THotKeyCollection;
    // Признак "горячие клавиши работают и в прозрачном режиме":
    // пишется прямо из меню, поэтому публичное, без свойства.
  public
    FFlag34: Boolean;
  private
    procedure SetHotKeys(HotKeys: THotKeyCollection);
    {}
    function WMHotKey(var Msg: TMessage): Boolean;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    {}
    function HotKeyByName(const Name: string): THotKeyItem;
    { Тот же поиск по имени, но возвращает НОМЕР элемента; -1 -- нет такой. }
    function HotKeyIndexByName(const Name: string): Integer;
  published
    property HotKeys: THotKeyCollection read FHotKeys write SetHotKeys;
  end;


implementation

uses SysUtils, TypInfo, MMSystem;

const
  { Клавиши, которые можно назначить: код и подпись идут парой,
    номер в этих таблицах и есть значение FHotKey. }
  KeyCodes: array[0..96] of Integer =
     ($00, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, 
      $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $31, 
      $32, $33, $34, $35, $36, $37, $38, $39, $30, $70, $71, $72, $73, $74, 
      $75, $76, $77, $78, $79, $7A, $7B, $26, $28, $25, $27, $1B, $09, $2D, 
      $2E, $24, $23, $21, $22, $2C, $08, $0D, $13, $91, $6F, $6A, $6D, $6B, 
      $14, $20, $5D, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6E, 
      $90, $C0, $2D, $3D, $5C, $2C, $2E, $2F, $3B, $27, $5B, $5D, $00);

  KeyLabels: array[0..96] of string =
     ('', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', 
      '2', '3', '4', '5', '6', '7', '8', '9', '0', 'F1', 'F2', 'F3', 'F4', 
      'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12', 'Up', 'Down', 
      'Left', 'Right', 'Escape', 'Tab', 'Insert', 'Delete', 'Home', 'End', 
      'PageUp', 'PageDown', 'PrintScreen', 'Backspace', 'Enter', 'Pause', 
      'ScrollLock', 'num_/', 'num_*', 'num_-', 'num_+', 'CapsLock', 
      'Spacebar', 'Applications', 'num_0', 'num_1', 'num_2', 'num_3', 
      'num_4', 'num_5', 'num_6', 'num_7', 'num_8', 'num_9', 'num_Decimal', 
      'NumLock', '`', '-', '=', '\', ',', '.', '/', ';', '''', '[', ']', '');

function THotKeyManager.WMHotKey(var Msg: TMessage): Boolean;
var i: Integer;
    V: Integer;
    Scan: Integer;
begin
  if Msg.Msg = WM_HOTKEY then
  begin
    for i:= 0 to HotKeys.Count - 1 do
      if Msg.wParam = HotKeys[i].HotKeyId then
      begin
        if FFlag34 then
        begin
          Windows.UnRegisterHotKey(Application.Handle, HotKeys[i].HotKeyId);
          V:= HiWord(Msg.lParam);
          Scan:= Byte(MapVirtualKey(V, 0));
          keybd_event(V, Scan, 0, 0);
          Sleep(1);
          keybd_event(V, Scan, KEYEVENTF_KEYUP, 0);
        end;
        if Assigned(HotKeys[i].OnHotKeyActivation) then
        begin
          if Length(HotKeys[i].FSound) > 0 then
            PlaySound(PChar(HotKeys[i].FSound), 0,
              SND_FILENAME or SND_NODEFAULT or SND_ASYNC);
          HotKeys[i].OnHotKeyActivation(HotKeys[i]);
        end;
        if FFlag34 then
          Result:= Windows.RegisterHotKey(Application.Handle,
            HotKeys[i].HotKeyId, HotKeys[i].FShift, HotKeys[i].FKey)
        else
          Result:= True;
        Exit;
      end;
  end;
  Result:= False;
end;

constructor THotKeyManager.Create(AOwner: TComponent);
begin
  FHotKeys:= THotKeyCollection.Create(Self);
  inherited Create(AOwner);
  if not (csDesigning in ComponentState) then
    Application.HookMainWindow(WMHotKey);
  FFlag34:= False;
end;

destructor THotKeyManager.Destroy;
var i: Integer;
begin
  if not (csDesigning in ComponentState) then
    Application.UnHookMainWindow(WMHotKey);
  for i:= 0 to HotKeys.Count - 1 do
    HotKeys[i].UnRegisterHotKey;
  FHotKeys.Free; FHotKeys:= nil;
  inherited Destroy;
end;

procedure THotKeyManager.Loaded;
var i: Integer;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    for i:= 0 to HotKeys.Count - 1 do
      HotKeys[i].RegisterHotKey;
end;

function THotKeyManager.HotKeyByName(const Name: string): THotKeyItem;
var i: Integer;
begin
  for i:= 0 to HotKeys.Count - 1 do
    if CompareText(Name, HotKeys[i].Name) = 0 then
    begin
      Result:= HotKeys[i];
      Exit;
    end;
  Result:= nil;
end;

function THotKeyManager.HotKeyIndexByName(const Name: string): Integer;
var i: Integer;
begin
  for i:= 0 to HotKeys.Count - 1 do
    if CompareText(Name, HotKeys[i].Name) = 0 then
    begin
      Result:= i;
      Exit;
    end;
  Result:= -1;
end;

procedure THotKeyManager.SetHotKeys(HotKeys: THotKeyCollection);
begin
  FHotKeys.Assign(HotKeys);
end;

{ THotKeyCollection }

constructor THotKeyCollection.Create(Manager: THotKeyManager);
begin
  FOwner:= Manager;
  inherited Create(THotKeyItem);
end;

function THotKeyCollection.GetItem(Idx: Integer): THotKeyItem;
begin
  Result:= THotKeyItem(inherited Items[Idx]);
end;

function THotKeyCollection.GetOwner: TPersistent;
begin
  Result:= FOwner;
end;

procedure THotKeyCollection.SetItem(Idx: Integer; Item: THotKeyItem);
begin
  inherited Items[Idx]:= Item;
end;

{ THotKeyItem }

{ Модификаторы и код кладём в поля, а не в локальные: WMHotKey по ним
  перерегистрирует клавишу после сквозного нажатия. }
function THotKeyItem.RegisterHotKey: Boolean;
begin
  Result:= False;
  if FHotKeyId <> 0 then
    UnRegisterHotKey;
  if FHotKey <> 0 then
  begin
    FShift:= 0;
    if ssAlt in ShiftState then
      FShift:= FShift + MOD_ALT;
    if ssCtrl in ShiftState then
      FShift:= FShift + MOD_CONTROL;
    if ssShift in ShiftState then
      FShift:= FShift + MOD_SHIFT;
    FKey:= KeyCodes[FHotKey];
    FHotKeyId:= $A000 + ID;
    Result:= Windows.RegisterHotKey(Application.Handle, FHotKeyId, FShift, FKey);
  end;
end;

procedure THotKeyItem.UnRegisterHotKey;
begin
  if FHotKeyId <> 0 then
  begin
    Windows.UnRegisterHotKey(Application.Handle, FHotKeyId);
    FHotKeyId:= 0;
  end;
end;

procedure THotKeyItem.Assign(Item: TPersistent);
begin
  if Item is THotKeyItem then
  begin
    HotKey:= THotKeyItem(Item).HotKey;
    ShiftState:= THotKeyItem(Item).ShiftState;
  end else
    inherited Assign(Item);
end;

function THotKeyItem.GetDisplayName: string;
  procedure AddShift(const S: string);
  begin
    if Result <> '' then
      Result:= Result + ' + ';
    Result:= Result + S;
  end;
begin
  if HotKey = '' then
    Result:= inherited GetDisplayName
  else if Name <> '' then
    Result:= Name
  else begin
    if ssAlt in ShiftState then
      AddShift('Alt');
    if ssCtrl in ShiftState then
      AddShift('Ctrl');
    if ssShift in ShiftState then
      AddShift('Shift');
    AddShift(HotKey);
  end;
end;

function THotKeyItem.GetNamePath: string;
  function NameToSymbol(Name: string): string;
  var i: Integer;
  begin
    Result:= '';
    for i:= 1 to Length(Name) do
      if Name[i] in ['A'..'Z', 'a'..'z', '0'..'9'] then
        Result:= Result + Name[i];
  end;
var S: string;
begin
  if Collection <> nil then
  begin
    S:= Name;
    if (S = '') and (HotKey <> '') then
      S:= GetDisplayName;
    S:= NameToSymbol(S);
    if S <> '' then
      Result:= Format('%s[%s]',[Collection.GetNamePath, S])
    else
      Result:= Format('%s[%d]',[Collection.GetNamePath, Index]);
  end else
    Result:= ClassName;
end;

function THotKeyItem.GetHotKey: string;
begin
  Result:= KeyLabels[FHotKey];
end;

procedure THotKeyItem.SetHotKey(Key: string);
var i: Integer;
begin
  i:= 0;
  while i < High(KeyLabels) do
  begin
    Inc(i);
    if CompareText(Key, KeyLabels[i]) = 0 then
      Break;
  end;
  if i > High(KeyLabels) then
    i:= 0;
  FHotKey:= i;
  if not (csDesigning in Manager.ComponentState) then
    FRegistered:= RegisterHotKey;
end;

procedure THotKeyItem.SetShiftState(State: TShiftState);
begin
  FShiftState:= State;
  if not (csDesigning in Manager.ComponentState) then
    RegisterHotKey;
end;

function THotKeyItem.GetManager: THotKeyManager;
begin
  Result:= THotKeyCollection(Collection).FOwner;
end;

{ PropEditors }

end.
