unit WebLabel;

{ Метка-гиперссылка: синий подчёркнутый текст, курсор-рука, по клику
  открывает ссылку через ShellExecute. При наведении мыши перекрашивается
  в FocusColor, при уходе возвращает исходный цвет. }

interface

uses Windows, Messages, SysUtils, Classes, Controls, Graphics, StdCtrls, ShellAPI;

type
  TURLType = (lnFile, lnFtp, lnGopher, lnHttp, lnHttps, lnMailto,
              lnNews, lnTelnet, lnWais);

var
  { Приставка по типу ссылки -- её дописывает MouseDown. }
  URLPrefix: array[TURLType] of string =
    ('file://', 'ftp://', 'gopher://', 'http://', 'https://', 'mailto:',
     'news:', 'telnet:', 'wais:');

type
  TWebLabel = class(TCustomLabel)
  private
    FFocusColor: TColor;
    FNormalColor: TColor;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FLink: string;
    FLinkType: TURLType;
    procedure SetLinkType(Value: TURLType);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Loaded; override;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FocusColor: TColor read FFocusColor write FFocusColor default clRed;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Caption;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent;
    property Layout;
    property Visible;
    property WordWrap;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property Link: string read FLink write FLink;
    property LinkType: TURLType read FLinkType write SetLinkType;
  end;

implementation

uses Forms;   { Screen -- ради секции инициализации }

constructor TWebLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFocusColor := clRed;
  FNormalColor := Font.Color;
  FLink := 'ya.ru';
  Hint := '';
  ShowHint := False;
  Caption := 'ya.ru';
  Font.Color := clNavy;
  Font.Style := Font.Style + [fsUnderline];
  Cursor := crHandPoint;
  FLinkType := lnHttp;
end;

{ Открываем ссылку по нажатию, а не по Click: клик теряется, если мышь
  успела сдвинуться. }
procedure TWebLabel.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Prefix: string;
  Res: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  Prefix := URLPrefix[FLinkType];
  Res := ShellExecute(0, 'open', PChar(Prefix + FLink), nil, nil, SW_SHOWNORMAL);
  if Res <= 32 then
    raise Exception.CreateFmt('Execute "%s" failed (%d)', [FLink, Res]);
end;

procedure TWebLabel.SetLinkType(Value: TURLType);
begin
  if Value <> FLinkType then
    FLinkType := Value;
end;

{ Запоминаем цвет шрифта таким, каким его выставил DFM. }
procedure TWebLabel.Loaded;
begin
  inherited Loaded;
  FNormalColor := Font.Color;
end;

{ Цвет сменили снаружи -- запомним его как обычный, но только если это
  не наш же цвет подсветки. }
procedure TWebLabel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if Font.Color <> FFocusColor then
    FNormalColor := Font.Color;
end;

procedure TWebLabel.CMMouseEnter(var Message: TMessage);
begin
  Font.Color := FFocusColor;
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TWebLabel.CMMouseLeave(var Message: TMessage);
begin
  Font.Color := FNormalColor;
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

{ Рука у нас своя, из ресурса: системная в старых Windows не везде есть. }
initialization
  Screen.Cursors[crHandPoint] := LoadCursor(HInstance, 'WEB_HAND');

end.
