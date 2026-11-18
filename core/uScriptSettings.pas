unit uScriptSettings;

{ Профиль настроек движка скриптов, нужный test-инфраструктуре.
  Намеренно не зависит от Unit1/LCL: значения передаются снаружи, а не
  берутся из формы настроек. }

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

type
  IScriptSettings = interface
    ['{0F4E8D61-3A7B-4C52-9E18-6B2D7A5C1F30}']
    function GetPauseCmd: string;
    function GetPauseStr: string;
    function GetSendDelay: Integer;
    function GetClickDelay: Integer;
    function GetLogLevel: Integer;
    procedure SetPauseCmd(const Value: string);
    procedure SetPauseStr(const Value: string);
    procedure SetSendDelay(Value: Integer);
    procedure SetClickDelay(Value: Integer);
    procedure SetLogLevel(Value: Integer);
    property PauseCmd: string read GetPauseCmd write SetPauseCmd;
    property PauseStr: string read GetPauseStr write SetPauseStr;
    property SendDelay: Integer read GetSendDelay write SetSendDelay;
    property ClickDelay: Integer read GetClickDelay write SetClickDelay;
    property LogLevel: Integer read GetLogLevel write SetLogLevel;
  end;

  TScriptSettings = class(TInterfacedObject, IScriptSettings)
  private
    FPauseCmd: string;
    FPauseStr: string;
    FSendDelay: Integer;
    FClickDelay: Integer;
    FLogLevel: Integer;
    function GetPauseCmd: string;
    function GetPauseStr: string;
    function GetSendDelay: Integer;
    function GetClickDelay: Integer;
    function GetLogLevel: Integer;
    procedure SetPauseCmd(const Value: string);
    procedure SetPauseStr(const Value: string);
    procedure SetSendDelay(Value: Integer);
    procedure SetClickDelay(Value: Integer);
    procedure SetLogLevel(Value: Integer);
  public
    constructor Create;
    property PauseCmd: string read FPauseCmd write FPauseCmd;
    property PauseStr: string read FPauseStr write FPauseStr;
    property SendDelay: Integer read FSendDelay write FSendDelay;
    property ClickDelay: Integer read FClickDelay write FClickDelay;
    property LogLevel: Integer read FLogLevel write FLogLevel;
  end;

{ Профиль, который раньше был жёстко зашит в TScanThread.CreateForTest:
  нулевые задержки и выключенный лог. }
function FastTestProfile: IScriptSettings;

implementation

constructor TScriptSettings.Create;
begin
  inherited Create;
  FPauseCmd := '0';
  FPauseStr := '0';
  FSendDelay := 0;
  FClickDelay := 0;
  FLogLevel := 0;
end;

function TScriptSettings.GetPauseCmd: string;
begin
  Result := FPauseCmd;
end;

function TScriptSettings.GetPauseStr: string;
begin
  Result := FPauseStr;
end;

function TScriptSettings.GetSendDelay: Integer;
begin
  Result := FSendDelay;
end;

function TScriptSettings.GetClickDelay: Integer;
begin
  Result := FClickDelay;
end;

function TScriptSettings.GetLogLevel: Integer;
begin
  Result := FLogLevel;
end;

procedure TScriptSettings.SetPauseCmd(const Value: string);
begin
  FPauseCmd := Value;
end;

procedure TScriptSettings.SetPauseStr(const Value: string);
begin
  FPauseStr := Value;
end;

procedure TScriptSettings.SetSendDelay(Value: Integer);
begin
  FSendDelay := Value;
end;

procedure TScriptSettings.SetClickDelay(Value: Integer);
begin
  FClickDelay := Value;
end;

procedure TScriptSettings.SetLogLevel(Value: Integer);
begin
  FLogLevel := Value;
end;

function FastTestProfile: IScriptSettings;
begin
  Result := TScriptSettings.Create;
end;

end.
