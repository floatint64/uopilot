unit Gauges;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

// LCL-порт демо-юнита Delphi `Gauges` (компонент TGauge). Повторяет
// публичный интерфейс и алгоритм отрисовки Delphi-версии, чтобы индикатор
// `gScript` в Unit1 выглядел пиксельно идентично Delphi.

interface

uses
  Classes, Controls, Graphics, Math, SysUtils;

type

  TGaugeKind = (gkText, gkHorizontalBar, gkVerticalBar, gkPie, gkNeedle);

  TGauge = class(TGraphicControl)
  private
    FMinValue: Longint;
    FMaxValue: Longint;
    FProgress: Longint;
    FKind: TGaugeKind;
    FShowText: Boolean;
    FForeColor: TColor;
    FBackColor: TColor;
    procedure PaintBackground(AnImage: TBitmap);
    procedure PaintAsText(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
    procedure PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
    procedure SetGaugeKind(Value: TGaugeKind);
    procedure SetProgress(Value: Longint);
    procedure SetMinValue(Value: Longint);
    procedure SetMaxValue(Value: Longint);
    procedure SetShowText(Value: Boolean);
    procedure SetForeColor(Value: TColor);
    procedure SetBackColor(Value: TColor);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AddProgress(Value: Longint);
  published
    property Align;
    property Anchors;
    property BackColor: TColor read FBackColor write SetBackColor default clBtnFace;
    property Color nodefault;
    property Enabled;
    property ForeColor: TColor read FForeColor write SetForeColor default clHighlight;
    property Font;
    property Kind: TGaugeKind read FKind write SetGaugeKind default gkHorizontalBar;
    property MinValue: Longint read FMinValue write SetMinValue default 0;
    property MaxValue: Longint read FMaxValue write SetMaxValue default 100;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Progress: Longint read FProgress write SetProgress default 0;
    property ShowHint;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property Visible;
  end;

implementation

function MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer;
  stdcall; external 'kernel32' name 'MulDiv';

constructor TGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csFramed, csOpaque];
  FMinValue := 0;
  FMaxValue := 100;
  FProgress := 0;
  FKind := gkHorizontalBar;
  FShowText := True;
  FForeColor := clHighlight;
  FBackColor := clBtnFace;
  Color := clBtnFace;
  Width := 100;
  Height := 16;
end;

procedure TGauge.SetMinValue(Value: Longint);
begin
  if Value <> FMinValue then
  begin
    if Value > FMaxValue then
    begin
      if not (csLoading in ComponentState) then
        raise EInvalidOperation.Create('Invalid MinValue');
      FMaxValue := Value;
    end;
    FMinValue := Value;
    if FProgress < Value then
      FProgress := Value;
    Invalidate;
  end;
end;

procedure TGauge.SetMaxValue(Value: Longint);
begin
  if Value <> FMaxValue then
  begin
    if Value < FMinValue then
    begin
      if not (csLoading in ComponentState) then
        raise EInvalidOperation.Create('Invalid MaxValue');
      FMinValue := Value;
    end;
    FMaxValue := Value;
    if FProgress > Value then
      FProgress := Value;
    Invalidate;
  end;
end;

procedure TGauge.SetProgress(Value: Longint);
begin
  if Value < FMinValue then
    Value := FMinValue
  else if Value > FMaxValue then
    Value := FMaxValue;
  if FProgress <> Value then
  begin
    FProgress := Value;
    Invalidate;
  end;
end;

procedure TGauge.SetGaugeKind(Value: TGaugeKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Invalidate;
  end;
end;

procedure TGauge.SetShowText(Value: Boolean);
begin
  if Value <> FShowText then
  begin
    FShowText := Value;
    Invalidate;
  end;
end;

procedure TGauge.SetForeColor(Value: TColor);
begin
  if Value <> FForeColor then
  begin
    FForeColor := Value;
    Invalidate;
  end;
end;

procedure TGauge.SetBackColor(Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Invalidate;
  end;
end;

procedure TGauge.AddProgress(Value: Longint);
begin
  Progress := FProgress + Value;
  Refresh;
end;

procedure TGauge.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
    CopyMode := cmWhiteness;
    ARect := Rect(0, 0, AnImage.Width, AnImage.Height);
    CopyRect(ARect, AnImage.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure TGauge.PaintAsText(AnImage: TBitmap; PaintRect: TRect);
var
  S: string;
  X, Y: Integer;
  Percent: Longint;
begin
  with AnImage.Canvas do
  begin
    Brush.Style := bsClear;
    Font := Self.Font;
    if FMaxValue = FMinValue then
      Percent := 0
    else
      Percent := ((FProgress - FMinValue) * 100) div (FMaxValue - FMinValue);
    S := Format('%d%%', [Percent]);
    X := (PaintRect.Right - PaintRect.Left - TextWidth(S)) div 2;
    Y := (PaintRect.Bottom - PaintRect.Top - TextHeight(S)) div 2;
    Font.Color := clWindowText;
    TextRect(PaintRect, PaintRect.Left + X, PaintRect.Top + Y, S);
  end;
end;

procedure TGauge.PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
var
  FillSize: Longint;
  W, H: Integer;
begin
  W := PaintRect.Right - PaintRect.Left - 1;
  H := PaintRect.Bottom - PaintRect.Top - 1;
  with AnImage.Canvas do
  begin
    Brush.Color := FBackColor;
    FillRect(PaintRect);
    Pen.Color := FForeColor;
    Pen.Width := 1;
    Frame3D(PaintRect, clBtnShadow, clBtnHighlight, 1);
    Inc(PaintRect.Left);
    Inc(PaintRect.Top);
    Dec(PaintRect.Right);
    Dec(PaintRect.Bottom);
    if FKind = gkHorizontalBar then
    begin
      if FMaxValue = FMinValue then
        FillSize := 0
      else
        FillSize := MulDiv(W, FProgress - FMinValue, FMaxValue - FMinValue);
      if FillSize > W then
        FillSize := W;
      if FillSize > 0 then
      begin
        Brush.Color := FForeColor;
        FillRect(Rect(PaintRect.Left, PaintRect.Top,
          PaintRect.Left + FillSize, PaintRect.Bottom));
      end;
    end
    else
    begin
      if FMaxValue = FMinValue then
        FillSize := 0
      else
        FillSize := MulDiv(H, FProgress - FMinValue, FMaxValue - FMinValue);
      if FillSize > H then
        FillSize := H;
      if FillSize > 0 then
      begin
        Brush.Color := FForeColor;
        FillRect(Rect(PaintRect.Left, PaintRect.Bottom - FillSize,
          PaintRect.Right, PaintRect.Bottom));
      end;
    end;
    if FShowText then
      PaintAsText(AnImage, PaintRect);
  end;
end;

procedure TGauge.PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX, MiddleY: Integer;
  Angle, Percents: Double;
begin
  with AnImage.Canvas do
  begin
    Brush.Color := FForeColor;
    Pen.Color := FBackColor;
    Pen.Width := 1;
    MiddleX := (PaintRect.Left + PaintRect.Right) div 2;
    MiddleY := (PaintRect.Top + PaintRect.Bottom) div 2;
    if FMaxValue = FMinValue then
      Percents := 0
    else
      Percents := (FProgress - FMinValue) / (FMaxValue - FMinValue);
    Angle := Pi * Percents;
    Pie(PaintRect.Left, PaintRect.Top, PaintRect.Right, PaintRect.Bottom,
      PaintRect.Right, MiddleY,
      Round(MiddleX * (1 - Cos(Angle))), Round(MiddleY * (1 - Sin(Angle))));
    if FShowText then
      PaintAsText(AnImage, PaintRect);
  end;
end;

procedure TGauge.PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX: Integer;
  Angle: Double;
  X, Y: Integer;
begin
  with AnImage.Canvas do
  begin
    Brush.Color := FForeColor;
    Pen.Color := FForeColor;
    Pen.Width := 1;
    MiddleX := (PaintRect.Left + PaintRect.Right) div 2;
    if FMaxValue = FMinValue then
      Angle := 0
    else
      Angle := Pi * (FProgress - FMinValue) / (FMaxValue - FMinValue);
    X := Round(MiddleX + (MiddleX - PaintRect.Left) * Cos(Angle));
    Y := Round(MiddleX + (MiddleX - PaintRect.Left) * Sin(Angle));
    MoveTo(MiddleX, MiddleX);
    LineTo(X, Y);
    if FShowText then
      PaintAsText(AnImage, PaintRect);
  end;
end;

procedure TGauge.Paint;
var
  TheImage: TBitmap;
  PaintRect: TRect;
begin
  with Canvas do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := ClientHeight;
      TheImage.Width := ClientWidth;
      PaintBackground(TheImage);
      PaintRect := ClientRect;
      if FKind = gkNeedle then
      begin
        PaintAsBar(TheImage, PaintRect);
        PaintAsNeedle(TheImage, PaintRect);
      end;
      if FKind = gkPie then
        PaintAsPie(TheImage, PaintRect);
      if FKind = gkText then
        PaintAsText(TheImage, PaintRect);
      if FKind = gkHorizontalBar then
        PaintAsBar(TheImage, PaintRect);
      if FKind = gkVerticalBar then
        PaintAsBar(TheImage, PaintRect);
      Draw(0, 0, TheImage);
    finally
      TheImage.Free;
    end;
  end;
end;

initialization
  RegisterClass(TGauge);
{$IFnDEF FPC}
  RegisterComponents('Samples', [TGauge]);
{$ENDIF}

end.
