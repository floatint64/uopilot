unit fmFirst_u;

{ Пустая служебная форма: в DFM у неё нет ни одного компонента, только
  `BorderStyle = bsNone` и `Visible = True`. Обе процедуры служат одному --
  спрятать окно и вернуть фокус главной форме.

  FormCreate даёт форме случайный заголовок из 5..20 случайных печатных
  символов, схлопывает её в нулевой размер в точке (0,0) и добавляет
  WS_EX_TOOLWINDOW: окно перестаёт находиться поиском по заголовку.

  FormActivate при активации возвращает фокус на fmSecondfj -- на редактор
  скрипта, если открыта вкладка tsScript, иначе на саму форму.

  Ссылка на fmFirstfj используется из Unit1 (IconCallBackMessage временно
  снимает у неё OnActivate, пока показывает меню в трее). }

interface

uses SynEdit, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms;

type
  TfmFirst = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  end;

var
  fmFirstfj: TfmFirst;

implementation

uses Unit1;

{$R *.dfm}

procedure TfmFirst.FormCreate(Sender: TObject);
var
  S: string;
  I, N: Integer;
begin
  S := '';
  Randomize;
  N := Random(16);
  Inc(N, 5);
  for I := 1 to N do
    S := S + Chr(Random($5F) + $20);
  fmFirstfj.Caption := S;
  fmFirstfj.Top := 0;
  fmFirstfj.Left := 0;
  fmFirstfj.Height := 0;
  fmFirstfj.Width := 0;
  N := GetWindowLong(fmFirstfj.Handle, GWL_EXSTYLE);
  N := N or WS_EX_TOOLWINDOW;
  SetWindowLong(fmFirstfj.Handle, GWL_EXSTYLE, N);
end;

procedure TfmFirst.FormActivate(Sender: TObject);
begin
  { Активация может прийти и на полуразрушенной второй форме, поэтому всё
    под try..except и с проверками по одной. }
  try
    if fmSecondfj <> nil then
      if fmSecondfj.edScript <> nil then
        if fmSecondfj.Visible then
          if fmSecondfj.Enabled then
            if fmSecondfj.edScript.Visible and fmSecondfj.edScript.Enabled and
               (fmSecondfj.pcAll.ActivePage = fmSecondfj.tsScript) then
              fmSecondfj.edScript.SetFocus
            else
              fmSecondfj.SetFocus;
  except
  end;
end;

end.
