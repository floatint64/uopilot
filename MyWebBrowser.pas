unit MyWebBrowser;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

{$IFDEF FPC}

uses
  Windows, Messages, Classes, Controls, ActiveX, ComObj, Variants, SysUtils, Forms;

type
  TWebBrowserBeforeNavigate2 = procedure(Sender: TObject;
    const pDisp: IDispatch; var URL: OleVariant; var Flags: OleVariant;
    var TargetFrameName: OleVariant; var PostData: OleVariant;
    var Headers: OleVariant; var Cancel: WordBool) of object;

  TWebBrowserCommandStateChange = procedure(Sender: TObject;
    Command: Integer; Enable: WordBool) of object;

  IWebBrowser = interface(IDispatch)
    ['{EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}']
  end;

  IWebBrowserApp = interface(IWebBrowser)
    ['{0002DF05-0000-0000-C000-000000000046}']
    procedure GoBack; safecall;
    procedure GoForward; safecall;
  end;

  IWebBrowser2 = interface(IWebBrowserApp)
    ['{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}']
    procedure Navigate(const URL: OleVariant; var Flags: OleVariant;
      var TargetFrameName: OleVariant; var PostData: OleVariant;
      var Headers: OleVariant); safecall;
    function Get_Document: IDispatch; safecall;
    function Get_Application: IDispatch; safecall;
    property Document: IDispatch read Get_Document;
    property Application: IDispatch read Get_Application;
  end;

  TWebBrowser = class;

  TWebBrowserEventSink = class(TObject, IDispatch)
  private
    FOwner: TWebBrowser;
  public
    constructor Create(AOwner: TWebBrowser);
    function QueryInterface(constref IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: LongInt; stdcall;
    function _Release: LongInt; stdcall;
    function GetTypeInfoCount(out Count: LongInt): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: LongInt; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: LongInt; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: LongInt; const IID: TGUID; LocaleID: LongInt; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  end;

  TWebBrowser = class(TWinControl, IUnknown, IOleClientSite, IOleControlSite,
    IOleInPlaceSite, IOleInPlaceFrame, IDispatch)
  private
    FDispatch: IDispatch;
    FOleObj: OleVariant;
    FOleObject: IOleObject;
    FInPlaceObject: IOleInPlaceObject;
    FSink: TWebBrowserEventSink;
    FCookie: DWORD;
    FOnBeforeNavigate2: TWebBrowserBeforeNavigate2;
    FOnCommandStateChange: TWebBrowserCommandStateChange;
    procedure EnsureBrowser;
    procedure AdviseEvents;
    procedure UnadviseEvents;
  protected
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function QueryInterface(constref IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: LongInt; stdcall;
    function _Release: LongInt; stdcall;
    function GetTypeInfoCount(out Count: LongInt): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: LongInt; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: LongInt; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: LongInt; const IID: TGUID; LocaleID: LongInt; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint; out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
    function OnControlInfoChanged: HResult; stdcall;
    function LockInPlaceActive(fLock: Bool): HResult; stdcall;
    function GetExtendedControl(out ppDisp: IDispatch): HResult; stdcall;
    function TransformCoords(var pPtlHimetric: _POINTL; var pPtfContainer: tagPOINTF; dwFlags: LongWord): HResult; stdcall;
    function TranslateAccelerator(var pMsg: tagMSG; grfModifiers: LongWord): HResult; stdcall; overload;
    function OnFocus(fGotFocus: Bool): HResult; stdcall;
    function ShowPropertyFrame: HResult; stdcall;
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out ppframe: IOleInPlaceFrame; out ppdoc: IOleInPlaceUIWindow; lprcposrect: LPRECT; lprccliprect: LPRECT; lpframeinfo: LPOLEINPLACEFRAMEINFO): HResult; stdcall;
    function Scroll(scrollExtant: TSIZE): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(lprcPosRect: LPRect): HResult; stdcall;
    function GetBorder(out rectBorder: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetActiveObject(const activeObject: IOleInPlaceActiveObject; pszObjName: POleStr): HResult; stdcall;
    function InsertMenus(hmenuShared: HMenu; var menuWidths: TOleMenuGroupWidths): HResult; stdcall;
    function SetMenu(hmenuShared: HMenu; holemenu: HMenu; hwndActiveObject: HWnd): HResult; stdcall;
    function RemoveMenus(hmenuShared: HMenu): HResult; stdcall;
    function SetStatusText(pszStatusText: POleStr): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    function TranslateAccelerator(var msg: TMsg; wID: Word): HResult; stdcall; overload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Navigate(const URL: OleVariant);
    procedure GoBack;
    procedure GoForward;
    function Document: IDispatch;
    function Application: IDispatch;
    function OleObject: IOleObject;
  published
    property Align;
    property OnBeforeNavigate2: TWebBrowserBeforeNavigate2 read FOnBeforeNavigate2 write FOnBeforeNavigate2;
    property OnCommandStateChange: TWebBrowserCommandStateChange read FOnCommandStateChange write FOnCommandStateChange;
  end;

const
  DIID_DWebBrowserEvents2: TGUID = '{34A715A0-6587-11D0-924A-0020AFC7AC4D}';

{$ENDIF}

implementation

{$IFDEF FPC}

function ReadArgVariant(const A: TVariantArg): OleVariant;
begin
  if (A.vt and VT_BYREF) <> 0 then
  begin
    if A.vt = (VT_VARIANT or VT_BYREF) then
      Result := A.pvarVal^
    else if A.vt = (VT_BSTR or VT_BYREF) then
      Result := A.pbstrVal^
    else if A.vt = (VT_BOOL or VT_BYREF) then
      Result := A.pbool^ <> False
    else
      Result := Unassigned;
  end
  else
  begin
    if A.vt = VT_BSTR then
      Result := WideString(A.bstrVal)
    else if A.vt = VT_I4 then
      Result := A.lVal
    else if A.vt = VT_I2 then
      Result := A.iVal
    else if A.vt = VT_BOOL then
      Result := A.vbool <> False
    else
      Result := Unassigned;
  end;
end;

function ReadArgBool(const A: TVariantArg): WordBool;
begin
  Result := False;
  if (A.vt and VT_BYREF) <> 0 then
  begin
    if A.vt = (VT_BOOL or VT_BYREF) then
      Result := A.pbool^;
  end
  else if A.vt = VT_BOOL then
    Result := A.vbool;
end;

function ReadArgDispatch(const A: TVariantArg): IDispatch;
begin
  Result := nil;
  if (A.vt and VT_BYREF) <> 0 then
  begin
    if A.vt = (VT_DISPATCH or VT_BYREF) then
      Result := A.pdispVal^;
  end
  else if A.vt = VT_DISPATCH then
    Result := IDispatch(A.dispVal);
end;

procedure WriteArgVariant(const A: TVariantArg; const V: OleVariant);
begin
  if (A.vt and VT_BYREF) <> 0 then
  begin
    if A.vt = (VT_VARIANT or VT_BYREF) then
      A.pvarVal^ := V;
  end;
end;

procedure WriteArgBool(const A: TVariantArg; const V: WordBool);
begin
  if (A.vt and VT_BYREF) <> 0 then
  begin
    if A.vt = (VT_BOOL or VT_BYREF) then
      A.pbool^ := V;
  end;
end;

{ TWebBrowserEventSink }

constructor TWebBrowserEventSink.Create(AOwner: TWebBrowser);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TWebBrowserEventSink.QueryInterface(constref IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
  begin
    Pointer(Obj) := nil;
    Result := E_NOINTERFACE;
  end;
end;

function TWebBrowserEventSink._AddRef: LongInt;
begin
  Result := -1;
end;

function TWebBrowserEventSink._Release: LongInt;
begin
  Result := -1;
end;

function TWebBrowserEventSink.GetTypeInfoCount(out Count: LongInt): HResult;
begin
  Count := 0;
  Result := S_OK;
end;

function TWebBrowserEventSink.GetTypeInfo(Index, LocaleID: LongInt; out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowserEventSink.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: LongInt; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowserEventSink.Invoke(DispID: LongInt; const IID: TGUID; LocaleID: LongInt; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
var
  D: TDispParams;
  pDisp: IDispatch;
  URL, VFlags, TargetFrameName, PostData, Headers: OleVariant;
  Cancel: WordBool;
  Command: Integer;
  Enable: WordBool;
begin
  Result := S_OK;
  D := TDispParams(Params);
  case DispID of
    250:
      begin
        pDisp := nil;
        URL := Unassigned;
        VFlags := Unassigned;
        TargetFrameName := Unassigned;
        PostData := Unassigned;
        Headers := Unassigned;
        Cancel := False;
        if D.cArgs >= 7 then
        begin
          pDisp := ReadArgDispatch(D.rgvarg[6]);
          URL := ReadArgVariant(D.rgvarg[5]);
          VFlags := ReadArgVariant(D.rgvarg[4]);
          TargetFrameName := ReadArgVariant(D.rgvarg[3]);
          PostData := ReadArgVariant(D.rgvarg[2]);
          Headers := ReadArgVariant(D.rgvarg[1]);
          Cancel := ReadArgBool(D.rgvarg[0]);
        end;
        if Assigned(FOwner) and Assigned(FOwner.FOnBeforeNavigate2) then
          FOwner.FOnBeforeNavigate2(FOwner, pDisp, URL, VFlags, TargetFrameName,
            PostData, Headers, Cancel);
        if D.cArgs >= 7 then
        begin
          WriteArgBool(D.rgvarg[0], Cancel);
          WriteArgVariant(D.rgvarg[5], URL);
        end;
      end;
    105:
      begin
        Command := 0;
        Enable := False;
        if D.cArgs >= 2 then
        begin
          Command := D.rgvarg[1].lVal;
          Enable := D.rgvarg[0].vbool <> False;
        end;
        if Assigned(FOwner) and Assigned(FOwner.FOnCommandStateChange) then
          FOwner.FOnCommandStateChange(FOwner, Command, Enable);
      end;
  end;
end;

{ TWebBrowser }

constructor TWebBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSink := TWebBrowserEventSink.Create(Self);
  FCookie := 0;
  FOleObj := Unassigned;
end;

destructor TWebBrowser.Destroy;
begin
  UnadviseEvents;
  if FOleObject <> nil then
  begin
    if FInPlaceObject <> nil then
      FInPlaceObject.InPlaceDeactivate;
    FOleObject.Close(OLECLOSE_NOSAVE);
    FOleObject.SetClientSite(nil);
  end;
  FInPlaceObject := nil;
  FOleObject := nil;
  FDispatch := nil;
  FOleObj := Unassigned;
  FreeAndNil(FSink);
  inherited Destroy;
end;

procedure TWebBrowser.EnsureBrowser;
var
  R: TRect;
  Sz: TPoint;
begin
  if FOleObject <> nil then
    Exit;
  HandleNeeded;
  FDispatch := CreateOleObject('Shell.Explorer');
  FOleObj := FDispatch;
  FOleObject := FDispatch as IOleObject;
  FOleObject.SetClientSite(Self as IOleClientSite);
  FOleObject.SetHostNames(nil, nil);
  R := ClientRect;
  Sz := Point(R.Right - R.Left, R.Bottom - R.Top);
  FOleObject.SetExtent(DVASPECT_CONTENT, Sz);
  FOleObject.DoVerb(OLEIVERB_INPLACEACTIVATE, nil, Self as IOleClientSite, 0, Handle, R);
  FInPlaceObject := FOleObject as IOleInPlaceObject;
  AdviseEvents;
end;

procedure TWebBrowser.AdviseEvents;
var
  Sink: IDispatch;
begin
  Sink := FSink;
  InterfaceConnect(FDispatch, DIID_DWebBrowserEvents2, Sink, FCookie);
end;

procedure TWebBrowser.UnadviseEvents;
begin
  if FCookie <> 0 then
  begin
    InterfaceDisconnect(FDispatch, DIID_DWebBrowserEvents2, FCookie);
    FCookie := 0;
  end;
end;

procedure TWebBrowser.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  R: TRect;
  Sz: TPoint;
begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if FOleObject <> nil then
  begin
    R := Rect(0, 0, AWidth, AHeight);
    Sz := Point(AWidth, AHeight);
    FOleObject.SetExtent(DVASPECT_CONTENT, Sz);
    if FInPlaceObject <> nil then
      FInPlaceObject.SetObjectRects(@R, @R);
  end;
end;

function TWebBrowser.QueryInterface(constref IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
  begin
    Pointer(Obj) := nil;
    Result := E_NOINTERFACE;
  end;
end;

function TWebBrowser._AddRef: LongInt;
begin
  Result := -1;
end;

function TWebBrowser._Release: LongInt;
begin
  Result := -1;
end;

function TWebBrowser.GetTypeInfoCount(out Count: LongInt): HResult;
begin
  Count := 0;
  Result := S_OK;
end;

function TWebBrowser.GetTypeInfo(Index, LocaleID: LongInt; out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowser.GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount, LocaleID: LongInt; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowser.Invoke(DispID: LongInt; const IID: TGUID; LocaleID: LongInt; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
  Result := DISP_E_MEMBERNOTFOUND;
end;

function TWebBrowser.SaveObject: HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowser.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint; out mk: IMoniker): HResult;
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function TWebBrowser.GetContainer(out container: IOleContainer): HResult;
begin
  container := nil;
  Result := E_NOTIMPL;
end;

function TWebBrowser.ShowObject: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.OnShowWindow(fShow: BOOL): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowser.OnControlInfoChanged: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.LockInPlaceActive(fLock: Bool): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.GetExtendedControl(out ppDisp: IDispatch): HResult;
begin
  ppDisp := Self as IDispatch;
  Result := S_OK;
end;

function TWebBrowser.TransformCoords(var pPtlHimetric: _POINTL; var pPtfContainer: tagPOINTF; dwFlags: LongWord): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.TranslateAccelerator(var pMsg: tagMSG; grfModifiers: LongWord): HResult;
begin
  Result := S_FALSE;
end;

function TWebBrowser.OnFocus(fGotFocus: Bool): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.ShowPropertyFrame: HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowser.GetWindow(out wnd: HWnd): HResult;
begin
  wnd := Handle;
  Result := S_OK;
end;

function TWebBrowser.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.CanInPlaceActivate: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.OnInPlaceActivate: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.OnUIActivate: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.GetWindowContext(out ppframe: IOleInPlaceFrame; out ppdoc: IOleInPlaceUIWindow; lprcposrect: LPRECT; lprccliprect: LPRECT; lpframeinfo: LPOLEINPLACEFRAMEINFO): HResult;
var
  R: TRect;
  F: TCustomForm;
begin
  ppframe := Self as IOleInPlaceFrame;
  ppdoc := nil;
  R := ClientRect;
  if lprcposrect <> nil then
    lprcposrect^ := R;
  if lprccliprect <> nil then
    lprccliprect^ := R;
  if lpframeinfo <> nil then
  begin
    FillChar(lpframeinfo^, SizeOf(lpframeinfo^), 0);
    lpframeinfo^.cb := SizeOf(lpframeinfo^);
    lpframeinfo^.fMDIApp := False;
    F := GetParentForm(Self);
    if F <> nil then
      lpframeinfo^.hwndFrame := F.Handle
    else
      lpframeinfo^.hwndFrame := Handle;
    lpframeinfo^.haccel := 0;
    lpframeinfo^.cAccelEntries := 0;
  end;
  Result := S_OK;
end;

function TWebBrowser.Scroll(scrollExtant: TSIZE): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.OnUIDeactivate(fUndoable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.OnInPlaceDeactivate: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.DiscardUndoState: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.DeactivateAndUndo: HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.OnPosRectChange(lprcPosRect: LPRect): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.GetBorder(out rectBorder: TRect): HResult;
begin
  FillChar(rectBorder, SizeOf(rectBorder), 0);
  Result := E_NOTIMPL;
end;

function TWebBrowser.RequestBorderSpace(const borderwidths: TRect): HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowser.SetBorderSpace(const borderwidths: TRect): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.SetActiveObject(const activeObject: IOleInPlaceActiveObject; pszObjName: POleStr): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.InsertMenus(hmenuShared: HMenu; var menuWidths: TOleMenuGroupWidths): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.SetMenu(hmenuShared: HMenu; holemenu: HMenu; hwndActiveObject: HWnd): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.RemoveMenus(hmenuShared: HMenu): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.SetStatusText(pszStatusText: POleStr): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TWebBrowser.TranslateAccelerator(var msg: TMsg; wID: Word): HResult;
begin
  Result := S_FALSE;
end;

procedure TWebBrowser.Navigate(const URL: OleVariant);
begin
  EnsureBrowser;
  FOleObj.Navigate(URL);
end;

procedure TWebBrowser.GoBack;
begin
  EnsureBrowser;
  FOleObj.GoBack;
end;

procedure TWebBrowser.GoForward;
begin
  EnsureBrowser;
  FOleObj.GoForward;
end;

function TWebBrowser.Document: IDispatch;
begin
  EnsureBrowser;
  Result := FOleObj.Document;
end;

function TWebBrowser.Application: IDispatch;
begin
  EnsureBrowser;
  Result := FOleObj.Application;
end;

function TWebBrowser.OleObject: IOleObject;
begin
  EnsureBrowser;
  Result := FOleObject;
end;

{$ENDIF}

end.
