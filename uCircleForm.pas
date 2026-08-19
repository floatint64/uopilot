unit uCircleForm;

{ Маленькое красное кольцо поверх всего -- показать место щелчка.
  Окно своего класса, форму кольца задаёт область окна, гаснет по таймеру. }

interface

uses Windows, Messages, SysUtils, Classes, Controls, Forms, ExtCtrls;

type
  { Класс нужен только как хозяин классового обработчика таймера:
    полей у него нет и создавать его никто не собирается. }
  TCircleForm = class(TObject)
  public
    class procedure CircleTimer(Sender: TObject);
  end;

var
  gCircleWnd: HWND;
  gCircleClass: TWndClass;
  gCircleShown: Boolean;
  gCircleTimer: TTimer;

implementation

uses Unit1;

var
  gCircleRgn1: HRGN;
  gCircleRgn2: HRGN;

{ Всё окно заливаем красным -- кольцо получается из области окна,
  а не из рисования. }
function CircleWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  PS: TPaintStruct;
  R: TRect;
  DC: HDC;
begin
  case uMsg of
    WM_PAINT:
      begin
        DC := BeginPaint(hWnd, PS);
        GetClientRect(hWnd, R);
        SelectObject(DC, CreateSolidBrush(RGB(255, 0, 0)));
        Rectangle(DC, R.Left, R.Top, R.Right, R.Bottom);
        ValidateRect(DC, nil);
        EndPaint(hWnd, PS);
      end;
    WM_DESTROY:
      PostQuitMessage(0);
  else
    Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
    Exit;
  end;
  Result := 0;
end;

procedure HideCircle;
begin
  if gCircleShown then
  begin
    ShowWindow(gCircleWnd, SW_HIDE);
    gCircleShown := False;
  end;
end;

class procedure TCircleForm.CircleTimer(Sender: TObject);
begin
  HideCircle;
  gCircleTimer.Enabled := False;
end;

initialization
  gCircleClass.style := CS_VREDRAW or CS_HREDRAW or CS_DBLCLKS or CS_OWNDC;
  gCircleClass.lpfnWndProc := @CircleWndProc;
  gCircleClass.cbClsExtra := 0;
  gCircleClass.cbWndExtra := 0;
  gCircleClass.hInstance := HInstance;
  gCircleClass.hIcon := LoadIcon(0, IDI_ASTERISK);
  gCircleClass.hCursor := LoadCursor(0, IDC_ARROW);
  gCircleClass.hbrBackground := 0;
  gCircleClass.lpszMenuName := nil;
  gCircleClass.lpszClassName := 'class_Circle';
  if Windows.RegisterClass(gCircleClass) <> 0 then
  begin
    gCircleWnd := CreateWindowEx(WS_EX_TOOLWINDOW, 'class_Circle', '',
      WS_POPUP or WS_VISIBLE, 100, 100, 10, 10, 0, 0, HInstance, nil);
    if gCircleWnd <> 0 then
    begin
      gCircleRgn1 := CreateRectRgn(1, 1, 10, 10);
      gCircleRgn2 := CreateRectRgn(3, 3, 8, 8);
      CombineRgn(gCircleRgn1, gCircleRgn1, gCircleRgn2, RGN_XOR);
      SetWindowRgn(gCircleWnd, gCircleRgn1, True);
      DeleteObject(gCircleRgn1);
      DeleteObject(gCircleRgn2);
      gCircleShown := True;
      HideCircle;
      UpdateWindow(gCircleWnd);
      gCircleTimer := TTimer.Create(fmSecondfj);
      gCircleTimer.Interval := 3000;
      gCircleTimer.Enabled := False;
      gCircleTimer.OnTimer := TCircleForm.CircleTimer;
    end
    else
      MessageBox(0, 'Cannot create window', 'Error', 0);
  end
  else
    MessageBox(0, 'Cannot register class', 'Error', 0);

finalization
  FreeAndNil(gCircleTimer);
  Windows.UnregisterClass('class_Circle', HInstance);

end.
