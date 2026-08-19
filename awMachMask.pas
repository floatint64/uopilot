unit awMachMask;

{ Список масок и сравнение строки с маской.

  IsMatchMask взята слово в слово из awMachMask.pas
  (c) Alexandr Petrovich Sysoev, http://www.kansoftware.ru/?tid=5071 }

interface

uses Classes;

type
  { Список масок. Сама маска делится вертикальной чертой на «что берём»
    и «что исключаем», внутри каждой половины элементы через точку с
    запятой. Разбор ленивый: сеттеры только сбрасывают FDirty, а разбирает
    Update перед первым сравнением. }
  tMatchMaskList = class(TObject)
  public
    FMasks: string;
    { False -- сравниваем без учёта регистра, для этого обе стороны
      гоняем через UpperCase. }
    FMatchCase: Boolean;
    { Дописывать точку строке, у которой её нет: имя без расширения
      иначе не ловится маской вида *.* }
    Flag9: Boolean;
    { Список уже разобран. }
    FDirty: Boolean;
    FInc: TStringList;
    FExc: TStringList;
    constructor Create(const AMasks: string);
    destructor Destroy; override;
    procedure SetMasks(V: string);
    procedure SetMatchCase(V: Boolean);
    procedure Update;
    function Matches(S: string): Boolean;
    property Masks: string write SetMasks;
    property MatchCase: Boolean write SetMatchCase;
  end;

function IsMatchMask(aText, aMask: PChar): Boolean;

implementation

uses SysUtils;

{ Взято слово в слово из awMachMask.pas (c) Alexandr Petrovich Sysoev,
  http://www.kansoftware.ru/?tid=5071 }
function IsMatchMask(aText, aMask: PChar): Boolean;
begin
  Result := False;
  While True Do
  begin
    Case aMask^ of
      '*':
        begin
          repeat
            Inc(aMask);
          Until (aMask^ <> '*');
          If aMask^ <> '?' then
            While (aText^ <> #0) And (aText^ <> aMask^) Do
              Inc(aText);
          If aText^ <> #0 Then
          begin
            If IsMatchMask(aText + 1, aMask - 1) Then
              Break;
            Inc(aMask);
            Inc(aText);
          End
          Else If (aMask^ = #0) Then
            Break
          Else
            Exit
        End;
      '?':
        If (aText^ = #0) Then
          Exit
        Else
        begin
          Inc(aMask);
          Inc(aText);
        End;
    Else
      If aMask^ <> aText^ Then
        Exit
      Else
      begin
        If (aMask^ = #0) Then
          Break;
        Inc(aMask);
        Inc(aText);
      End;
    End;
  End;
  Result := True;
End;

procedure tMatchMaskList.SetMasks(V: string);
begin
  if FMasks <> V then
  begin
    FMasks := V;
    FDirty := False;
  end;
end;

procedure tMatchMaskList.SetMatchCase(V: Boolean);
begin
  if V <> FMatchCase then
  begin
    FMatchCase := V;
    FDirty := False;
  end;
end;

constructor tMatchMaskList.Create(const AMasks: string);
var
  L: TStringList;
begin
  Masks := AMasks;
  Flag9 := True;
  FInc := TStringList.Create;
  L := FInc;
  L.Delimiter := ';';
  FExc := TStringList.Create;
  L := FExc;
  L.Delimiter := ';';
end;

destructor tMatchMaskList.Destroy;
begin
  FInc.Free;
  FExc.Free;
end;

procedure MaskListDropEmpty(L: TStrings);
var
  I: Integer;
  S: string;
begin
  for I := L.Count - 1 downto 0 do
  begin
    S := L[I];
    if S = '' then
      L.Delete(I);
  end;
end;

procedure tMatchMaskList.Update;
var
  S: string;
  P: Integer;
begin
  if not FDirty then
  begin
    if FMatchCase then
      S := FMasks
    else
      S := UpperCase(FMasks);
    P := Pos('|', S);
    if P = 0 then
    begin
      FInc.DelimitedText := S;
      FExc.DelimitedText := '';
    end
    else
    begin
      FInc.DelimitedText := Copy(S, 1, P - 1);
      FExc.DelimitedText := Copy(S, P + 1, MaxInt);
    end;
    MaskListDropEmpty(FInc);
    MaskListDropEmpty(FExc);
    if (FInc.Count = 0) and (FExc.Count <> 0) then
      FInc.Add('*');
    FDirty := True;
  end;
end;

function tMatchMaskList.Matches(S: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if S <> '' then
  begin
    if not FMatchCase then
      S := UpperCase(S);
    if Flag9 then
      if Pos('.', S) = 0 then
        S := S + '.';
    if not FDirty then
      Update;
    I := I;
    for I := 0 to FInc.Count - 1 do
      if IsMatchMask(PChar(S), PChar(FInc[I])) then
      begin
        Result := True;
        Break;
      end;
    if Result then
      for I := 0 to FExc.Count - 1 do
        if IsMatchMask(PChar(S), PChar(FExc[I])) then
        begin
          Result := False;
          Break;
        end;
  end;
end;

end.
