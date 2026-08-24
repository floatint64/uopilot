unit FixedTabControlReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, FixedTabControl;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TFixedTabControl]);
end;

end.
