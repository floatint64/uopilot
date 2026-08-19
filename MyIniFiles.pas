unit MyIniFiles;

{ Свой TMemIniFile: числа читаются через StrToInt64, булево -- первым
  символом строки, и файл сам сохраняется при разрушении, если в него
  писали. }

interface

uses IniFiles;

type
  TMyMemIniFile = class(TMemIniFile)
  private
    { «в файл что-то писали»: конструктор гасит, WriteString взводит }
    fld_0C: Boolean;
  public
    constructor Create(const FileName: string);
    function ReadInteger(const Section, Ident: string;
      Default: Longint): Longint; override;
    procedure WriteInteger(const Section, Ident: string;
      Value: Longint); override;
    function ReadBool(const Section, Ident: string;
      Default: Boolean): Boolean; override;
    procedure WriteBool(const Section, Ident: string;
      Value: Boolean); override;
    procedure WriteString(const Section, Ident, Value: string); override;
    destructor Destroy; override;
  end;

implementation

uses SysUtils;

{ Своё чтение числа: без StrToIntDef и разбора '$', зато через StrToInt64 --
  из ini спокойно приходят значения шире Integer. }
function TMyMemIniFile.ReadInteger(const Section, Ident: string;
  Default: Longint): Longint;
begin
  Result := StrToInt64(ReadString(Section, Ident, IntToStr(Default)));
end;

procedure TMyMemIniFile.WriteInteger(const Section, Ident: string;
  Value: Longint);
begin
  WriteString(Section, Ident, IntToStr(Value));
end;

{ Булево читаем ПЕРВЫМ символом строки -- так переживаются и 'true',
  и '1 ', и мусор в хвосте. }
function TMyMemIniFile.ReadBool(const Section, Ident: string;
  Default: Boolean): Boolean;
begin
  Result := StrToInt(
    ReadString(Section, Ident, IntToStr(Ord(Default)))[1]) <> 0;
end;

procedure TMyMemIniFile.WriteBool(const Section, Ident: string;
  Value: Boolean);
const
  Values: array[Boolean] of string = ('0', '1');
begin
  WriteString(Section, Ident, Values[Value]);
end;

constructor TMyMemIniFile.Create(const FileName: string);
begin
  inherited Create(FileName);
  fld_0C := False;
end;

{ Сохраняемся сами: настройки пишутся врассыпную по всей программе,
  и звать UpdateFile из каждого места неудобно. }
destructor TMyMemIniFile.Destroy;
begin
  if fld_0C then
    UpdateFile;
  inherited Destroy;
end;

{ Вся правка предка -- отметить, что в файл писали. }
procedure TMyMemIniFile.WriteString(const Section, Ident, Value: string);
begin
  fld_0C := True;
  inherited WriteString(Section, Ident, Value);
end;

end.
