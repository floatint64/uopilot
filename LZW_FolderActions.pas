unit LZW_FolderActions;

{ Распаковка своего архива (UoP) из ресурса программы и создание
  каталогов под него. }

interface

procedure UopMakePath(Path: string);
function UnpackUoPArchive(Dir: string; ResID: Integer): Boolean;

implementation

uses Windows, SysUtils, Classes, LZW_CompressUnit;

type
  TFolderModsZ = set of (fmAZ, fmBZ, fmCZ);

var
  LZWUnpackName: string;

procedure LZWKeepUnpackName;
begin
  LZWUnpackName := '';
end;

procedure UopMakePath(Path: string);
var
  S, Dir: string;
  I, J: Integer;
begin
  // Самодельный ForceDirectories: путь режется по '\' и каждый накопленный
  // кусок создаётся отдельно.
  Dir := Path[1] + Path[2] + Path[3];
  I := 1;
  S := '';
  if Path[1] = '\' then
    I := 2;
  for J := I to Length(Path) do
  begin
    if Path[J] <> '\' then
      S := S + Path[J];
    if (Path[J] = '\') or (J = Length(Path)) then
    begin
      if not DirectoryExists(S) then
        CreateDirectory(PChar(S), nil);
      S := '';
    end;
  end;
end;

function UnpackUoPArchive(Dir: string; ResID: Integer): Boolean;
var
  Sig: Integer;
  Size: Cardinal;
  Cnt: Cardinal;
  S: string;
  MS: TMemoryStream;
  RS: TResourceStream;
  NameLen: Word;
  BufSize: Cardinal;
  MS2: TMemoryStream;
  Buf: array of Char;
  I, J: Cardinal;
  P: Pointer;
  N: Integer;
begin
  // Свой архив в ресурсе RT_RCDATA: сигнатура 'UoP.', затем записи
  // «упакованное имя + данные».
  // Имя тоже сжато, поэтому его сначала гоняем через распаковщик.
  Result := False;
  BufSize := $10000;
  RS := TResourceStream.CreateFromID(HInstance, ResID, RT_RCDATA);
  RS.Seek(0, soFromBeginning);
  RS.Read(Sig, 4);
  if Sig <> $2E506F55 then
  begin
    RS.Free;
    Exit;
  end;
  RS.Read(Cnt, 4);
  MS := TMemoryStream.Create;
  for I := 1 to Cnt do
  begin
    S := '';
    RS.Read(NameLen, 2);
    RS.Read(Size, 4);
    SetLength(Buf, NameLen);
    RS.Read(Buf[0], NameLen);
    MS.Clear;
    MS.Write(Buf[0], NameLen);
    MS.Seek(0, soFromBeginning);
    UopUnpackStream(MS);
    NameLen := MS.Size;
    MS.Seek(0, soFromBeginning);
    SetLength(Buf, 0);
    SetLength(Buf, NameLen);
    MS.Read(Buf[0], NameLen);
    for J := 0 to NameLen - 1 do
      S := S + Char(Buf[J]);
    SetLength(Buf, 0);
    if Dir[Length(Dir)] <> '\' then
      Dir := Dir + '\';
    S := Dir + S;
    UopMakePath(ExtractFileDir(S));
    P := VirtualAlloc(nil, $10000, MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
    MS2 := TMemoryStream.Create;
    for J := 1 to Size shr 16 do
    begin
      N := RS.Read(P^, BufSize);
      MS2.Write(P^, N);
    end;
    N := RS.Read(P^, Size mod BufSize);
    MS2.Write(P^, N);
    VirtualFree(P, MEM_RELEASE, 0);
    UopSaveStreamToFile(MS2, S);
    MS2.Free;
  end;
  RS.Free;
  MS.Free;
  Result := True;
end;

end.
