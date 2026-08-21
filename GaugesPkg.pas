{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit GaugesPkg;

{$warn 5023 off : no warning about unused units}
interface

uses
  Gauges, GaugesReg, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('GaugesReg', @GaugesReg.Register);
end;

initialization
  RegisterPackage('GaugesPkg', @Register);
end.
