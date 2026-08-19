unit Unit5;

{ Служебная форма с картинкой на всю клиентскую область.
  Ресурс формы подключается не отсюда, а общим uopres.res. }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm5 = class(TForm)
    Image1: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

procedure TForm5.FormShow(Sender: TObject);
begin
end;

end.
