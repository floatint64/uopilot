unit FixedTabControl;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  Classes, Controls, ComCtrls, Graphics, LCLType, Messages;

type
  TFixedTabControl = class;
  TFixedTabDrawTabEvent = procedure(Sender: TFixedTabControl; Canvas: TCanvas;
    TabIndex: Integer; const Rect: TRect; Active: Boolean) of object;

  TFixedTabControl = class(TTabControl)
  private
    FNoteBook: TCustomTabControl;
    FNoteBookOldProc: TWndMethod;
    FOnDrawTab: TFixedTabDrawTabEvent;
    procedure NoteBookWndProc(var Msg: TMessage);
    procedure DrawTabOverlay(DC: HDC);
    procedure HookNoteBook;
    procedure UnhookNoteBook;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure PaintWindow(DC: HDC); override;
  public
    function TabRect(Index: Integer): TRect;
    procedure InvalidateTabs;
  published
    property OnDrawTab: TFixedTabDrawTabEvent read FOnDrawTab write FOnDrawTab;
  end;

implementation

uses
  Windows, LMessages;

procedure TFixedTabControl.CreateWnd;
begin
  inherited CreateWnd;
  HookNoteBook;
end;

procedure TFixedTabControl.DestroyWnd;
begin
  UnhookNoteBook;
  inherited DestroyWnd;
end;

procedure TFixedTabControl.HookNoteBook;
begin
  if Assigned(FNoteBookOldProc) then
    Exit;
  if Tabs is TTabControlNoteBookStrings then
  begin
    FNoteBook := TTabControlNoteBookStrings(Tabs).NoteBook;
    if FNoteBook <> nil then
    begin
      FNoteBookOldProc := FNoteBook.WindowProc;
      FNoteBook.WindowProc := NoteBookWndProc;
    end;
  end;
end;

procedure TFixedTabControl.UnhookNoteBook;
begin
  if not Assigned(FNoteBookOldProc) then
    Exit;
  if FNoteBook <> nil then
    FNoteBook.WindowProc := FNoteBookOldProc;
  FNoteBookOldProc := nil;
  FNoteBook := nil;
end;

procedure TFixedTabControl.NoteBookWndProc(var Msg: TMessage);
begin
  FNoteBookOldProc(Msg);
  if Msg.Msg = LM_PAINT then
    DrawTabOverlay(TLMPaint(Msg).DC);
end;

procedure TFixedTabControl.DrawTabOverlay(DC: HDC);
var
  C: TCanvas;
  I: Integer;
  R: TRect;
begin
  if not (OwnerDraw and Assigned(FOnDrawTab)) then
    Exit;
  if DC = 0 then
    Exit;
  C := TCanvas.Create;
  try
    C.Handle := DC;
    C.Font.Assign(Font);
    C.Brush.Color := GetSysColor(COLOR_BTNFACE);
    for I := 0 to Tabs.Count - 1 do
    begin
      R := FNoteBook.TabRect(I);
      FOnDrawTab(Self, C, I, R, TabIndex = I);
    end;
  finally
    C.Handle := 0;
    C.Free;
  end;
end;

function TFixedTabControl.TabRect(Index: Integer): TRect;
begin
  if (FNoteBook <> nil) and FNoteBook.HandleAllocated then
    Result := FNoteBook.TabRect(Index)
  else
    Result := inherited TabRect(Index);
end;

procedure TFixedTabControl.InvalidateTabs;
begin
  if (FNoteBook <> nil) and FNoteBook.HandleAllocated then
    FNoteBook.Invalidate;
end;

procedure TFixedTabControl.PaintWindow(DC: HDC);
var
  ARect: TRect;
begin
  inherited PaintWindow(DC);
  ARect := ClientRect;
  AdjustDisplayRectWithBorder(ARect);
  Windows.FillRect(DC, ARect, GetSysColorBrush(COLOR_BTNFACE));
end;

initialization
  Classes.RegisterClass(TFixedTabControl);

end.
