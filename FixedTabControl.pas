unit FixedTabControl;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  Classes, Controls, ComCtrls, LCLType;

type
  TFixedTabControl = class(TTabControl)
  protected
    procedure PaintWindow(DC: HDC); override;
  end;

implementation

uses
  Windows;

procedure TFixedTabControl.PaintWindow(DC: HDC);
var
  ARect: TRect;
begin
  inherited PaintWindow(DC);
  // LCL рисует pane через ThemeServices(ttPane); без визуальных стилей
  // fallback из themes.pas заливает его clBackground (цвет рабочего стола = чёрный).
  // Перезаливаем display area стандартным цветом диалога (как в Delphi).
  ARect := ClientRect;
  AdjustDisplayRectWithBorder(ARect);
  Windows.FillRect(DC, ARect, GetSysColorBrush(COLOR_BTNFACE));
end;

initialization
  Classes.RegisterClass(TFixedTabControl);

end.
