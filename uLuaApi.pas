unit uLuaApi;

{ Две функции lua51.dll, которые нужны в стороне от самого lualib.
  Держу их отдельным юнитом, чтобы не тащить весь lualib туда, где
  кроме этой пары ничего не требуется. }

interface

type
  TLuaIsString = function(L, Idx: Integer): Integer; cdecl;
  TLuaToLString = function(L, Idx: Integer; Len: Pointer): PChar; cdecl;

var
  gLuaIsString: TLuaIsString;
  gLuaToLString: TLuaToLString;

implementation

end.
