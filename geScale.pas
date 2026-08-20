unit geScale;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Приведение шрифта дочерних элементов формы к одному размеру. }

interface

uses Controls;

procedure SetChildFontHeight(C: TWinControl);

implementation

uses StdCtrls;

{ Font у TControl protected, поэтому идём через приведение к наследнику,
  у которого он published. }
procedure SetChildFontHeight(C: TWinControl);
var
  I: Integer;
begin
  for I := C.ControlCount - 1 downto 0 do
    TLabel(C.Controls[I]).Font.Height := -11;
end;

end.
