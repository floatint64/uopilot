unit Keydefs;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{ Имена клавиш для скрипта и разбор имени в виртуальный код.
  Обе таблицы идут ПАРОЙ и одного размера: номер в именах -- он же
  номер в кодах. }

interface

uses SysUtils;

const
  gHKCodeTablepz: array[0..101] of Byte = (
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 38, 40, 37,
    39, 27, 9, 45, 46, 36, 35, 33, 34, 44, 8, 13, 19, 145, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87,
    88, 89, 90, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 111, 106, 109, 107,
    20, 32, 91, 92, 93, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 110,
    144, 96, 45, 61, 92, 44, 46, 47, 59, 39, 91, 93, 123, 125, 27, 32, 3);

  gHKNameTablee9: array[0..101] of string = (
    'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
    'Up', 'Down', 'Left', 'Right', 'Escape', 'Tab', 'Insert', 'Delete',
    'Home', 'End', 'PageUp', 'PageDown', 'PrintScreen', 'Backspace', 'Enter',
    'Pause', 'ScrollLock', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
    'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'num_/', 'num_*',
    'num_-', 'num_+', 'CapsLock', 'Spacebar', 'WindowsLeft', 'WindowsRight',
    'Applications', 'num_0', 'num_1', 'num_2', 'num_3', 'num_4', 'num_5',
    'num_6', 'num_7', 'num_8', 'num_9', 'num_Decimal', 'NumLock', '`', '-',
    '=', '\', ',', '.', '/', ';', '''', '[', ']', '{', '}', 'Esc', 'Space',
    'Cansel');

{ Имя клавиши -> виртуальный код. Сравниваем без учёта регистра. }
function TextToVKey(S: string; var V: Byte): Boolean;

implementation

function TextToVKey(S: string; var V: Byte): Boolean;
var
  I: Word;
  N: Word;
begin
  Result := False;
  I := 0;
  N := High(gHKNameTablee9);
  while I <= N do
  begin
    if UpperCase(S) = UpperCase(gHKNameTablee9[I]) then
    begin
      V := gHKCodeTablepz[I];
      Result := True;
      Break;
    end;
    Inc(I);
  end;
end;

end.
