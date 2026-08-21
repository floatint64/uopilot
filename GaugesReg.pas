unit GaugesReg;

{$mode objfpc}{$H+}

interface

uses
  Classes, Gauges;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TGauge]);
end;

end.
