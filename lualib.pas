unit lualib;

{ Привязка Lua: адреса функций lua51.dll и то, что ими пользуется.

  Библиотека грузится на ходу, по имени файла из настроек: без Lua
  программа должна просто работать без скриптов, а не отказываться
  запускаться. Поэтому никакого статического импорта -- только
  LoadLibrary и разбор по ячейкам. }

interface

uses Windows;

type
  { Тексты кодов возврата Lua -- по ним печатается ошибка скрипта. }
  TLuaStatusText = array[0..6] of string;
  TLuaCFunc = function(L: Integer): Integer; cdecl;
  TLuaIsString = function(L, Idx: Integer): Integer; cdecl;
  TLuaGetTop = function(L: Integer): Integer; cdecl;
  TLuaRaise = procedure(L: Integer); cdecl;
  TLuaClose = procedure(L: Integer); cdecl;
  TLuaCreateTable = procedure(L, NArr, NRec: Integer); cdecl;
  TLuaPushNumber = procedure(L: Integer; D: Double); cdecl;
  TLuaType = function(L, Idx: Integer): Integer; cdecl;
  TLuaToLString = function(L, Idx: Integer; Len: Pointer): PChar; cdecl;
  TLuaPushString = procedure(L: Integer; S: PChar); cdecl;
  TLuaPushLString = procedure(L: Integer; S: PChar; Len: Integer); cdecl;
  TLuaPushCClosure = procedure(L: Integer; F: TLuaCFunc; N: Integer); cdecl;
  TLuaSetTable = procedure(L, Idx: Integer); cdecl;
  { lua_settop, через неё работает LuaPop }
  TLuaSetTop = procedure(L, Idx: Integer); cdecl;
  { обход таблицы Lua ключ за ключом }
  TLuaNext = function(L, Idx: Integer): Integer; cdecl;
  TLuaInsert = procedure(L, Idx: Integer); cdecl;
  TLuaPushNil = procedure(L: Integer); cdecl;
  TLuaPushInteger = procedure(L, N: Integer); cdecl;
  { Признак именно LongBool: на стороне Lua это int, и байтом его не
    передать. }
  TLuaPushBoolean = procedure(L: Integer; B: LongBool); cdecl;
  TLuaLoadString = function(L: Integer; S: PChar): Integer; cdecl;
  TLuaPCall = function(L, NArgs, NRes, ErrFunc: Integer): Integer; cdecl;
  TLuaNewState = function: Integer; cdecl;
  TLuaOpenLibs = procedure(L: Integer); cdecl;

const
  { псевдоиндекс таблицы глобальных в Lua 5.1 }
  LUA_GLOBALSINDEX = -10002;

  { Тексты кодов возврата lua_pcall: индекс -- сам код. }
  gLuaStatusTextjm: TLuaStatusText = (
    'success.',
    'success.',
    'a runtime error.',
    'syntax error during precompilation.',
    'memory allocation error.',
    'error while running a __gc',
    'error while running the message handler.');

type
  { Обёртка над lua_State: заводит состояние на свой скрипт и закрывает
    его. Живёт по одной на вкладку. }
  TLua = class
  public
    Handle: Integer;                   { lua_State* }
    ScriptNo: Integer;                 { номер скрипта }
    constructor Create;
    destructor Destroy; override;
    procedure Reg(const Name: string; Func: Pointer; N: Integer);
    procedure RegP(const Name: string; Func: TLuaCFunc; N: Integer);
  end;

var
  { Ручка lua51.dll и адреса всех её функций, какие нам нужны. Часть
    ячеек так и осталась Pointer -- их только загружаем, зовёт их
    никто. }
  gLuaAvail7: Boolean;
  gLuaHandle: HMODULE;
  gLuaLoaded: Boolean;
  { Имя файла библиотеки -- задаётся настройкой. }
  gLuaLibNameCow: string;
  { Текст последней ошибки загрузки. }
  gLuaErrorCcl: string;
  gLuaProc00: Pointer;                  // luaL_newstate
  gLuaProc01: Pointer;                  // luaL_openlibs
  gLuaProc02: Pointer;                  // lua_close
  gLuaPCall: TLuaPCall;                 // lua_pcall
  gLuaProc04: Pointer;                  // lua_tonumber
  gLuaToLStringej: TLuaToLString;       // lua_tolstring
  gLuaPushString: TLuaPushString;
  gLuaPushLStringej: TLuaPushLString;
  gLuaInsert: TLuaInsert;
  gLuaSetTableej: TLuaSetTable;
  gLuaPushCClosure: TLuaPushCClosure;
  { Зовётся одним доводом, когда у вкладки взведён StopRequested, и итог
    не берётся: она не возвращается. }
  gLuaRaiseby: TLuaRaise;               // lua_error
  gLuaLoadString: TLuaLoadString;
  gLuaProc13: Pointer;                  // luaL_loadfile
  gLuaCreateTableej: TLuaCreateTable;
  gLuaPushNumberdp: TLuaPushNumber;
  gLuaPushIntegerej: TLuaPushInteger;
  gLuaPushBooleanej: TLuaPushBoolean;
  gLuaIsNumberej: TLuaIsString;         // lua_isnumber
  gLuaGetTopej: TLuaGetTop;
  gLuaSetTop: TLuaSetTop;
  gLuaIsStringej: TLuaIsString;
  gLuaType: TLuaType;
  gLuaPushNilej: TLuaPushNil;
  gLuaNextej: TLuaNext;
  gLuaProc25: Pointer;                  // lua_gettable


function LoadLuaProcs(const Name: string): Boolean;
function UnLoadLuaLib: Boolean;
procedure LuaClose(T: TObject; X: Integer);
function LuaNewState: Integer;

{ Имя команды в стек, следом замыкание, и пара уходит в таблицу
  глобальных. }
procedure LuaBindGlobal(L: Integer; Name: PChar; Func: TLuaCFunc);
{ Замыкание команды: имя уходит в upvalue, обработчик один на все }
procedure LuaPushClosure(L: Integer; Name: PChar; Func: TLuaCFunc);
{ luaL_loadstring + lua_pcall }
function LuaDoString(L: Integer; S: PChar): Integer;
{ Положить значение со стека Lua в глобальную переменную под именем Name:
  имя в стек, поменять его местами со значением и в таблицу глобальных. }
procedure LuaSetGlobal(L: Integer; Name: PChar);
{ Индекс upvalue замыкания: обработчик команд узнаёт по нему своё имя. }
function LuaUpvalueIndex(N: Integer): Integer;
{ Снять N значений со стека Lua. }
procedure LuaPop(L, N: Integer);
{ Вид значения на стеке Lua. }
function LuaIsTable(L, Idx: Integer): Boolean;
function LuaIsNil(L, Idx: Integer): Boolean;

implementation

type
  { Двойник TLua ради одного поля: настоящий класс объявлен в Unit2, а
    оттуда сюда не дотянуться -- Unit2 подключает нас, а не наоборот. }
  TLuaRef = class(TObject)
  public
    Handle: Integer;                   { lua_State* }
  end;

function LoadLuaProcs(const Name: string): Boolean;
begin
  { Загрузить lua5.1.dll и разобрать её по ячейкам. Ни одна из них не
    проверяется на nil: если библиотека не та, скрипт всё равно не
    поедет, а разбираться удобнее по тексту ошибки. }
  string(gLuaErrorCcl) := '';
  gLuaLoaded := False;
  if Name <> '' then
    gLuaHandle := LoadLibrary(PChar(Name))
  else
    gLuaHandle := 0;
  if gLuaHandle = 0 then
  begin
    string(gLuaErrorCcl) := 'could not load Lua library "' + Name + '".';
    Result := False;
    Exit;
  end;
  gLuaProc00 := GetProcAddress(gLuaHandle, 'luaL_newstate');
  gLuaProc01 := GetProcAddress(gLuaHandle, 'luaL_openlibs');
  gLuaProc02 := GetProcAddress(gLuaHandle, 'lua_close');
  gLuaPCall := TLuaPCall(GetProcAddress(gLuaHandle, 'lua_pcall'));
  gLuaProc04 := GetProcAddress(gLuaHandle, 'lua_tonumber');
  gLuaToLStringej := TLuaToLString(GetProcAddress(gLuaHandle, 'lua_tolstring'));
  gLuaPushString := TLuaPushString(GetProcAddress(gLuaHandle, 'lua_pushstring'));
  gLuaPushLStringej := TLuaPushLString(GetProcAddress(gLuaHandle, 'lua_pushlstring'));
  gLuaInsert := TLuaInsert(GetProcAddress(gLuaHandle, 'lua_insert'));
  gLuaSetTableej := TLuaSetTable(GetProcAddress(gLuaHandle, 'lua_settable'));
  gLuaPushCClosure := TLuaPushCClosure(GetProcAddress(gLuaHandle, 'lua_pushcclosure'));
  gLuaRaiseby := TLuaRaise(GetProcAddress(gLuaHandle, 'lua_error'));
  gLuaLoadString := TLuaLoadString(GetProcAddress(gLuaHandle, 'luaL_loadstring'));
  gLuaProc13 := GetProcAddress(gLuaHandle, 'luaL_loadfile');
  gLuaCreateTableej := TLuaCreateTable(GetProcAddress(gLuaHandle, 'lua_createtable'));
  gLuaPushNumberdp := TLuaPushNumber(GetProcAddress(gLuaHandle, 'lua_pushnumber'));
  gLuaPushIntegerej := TLuaPushInteger(GetProcAddress(gLuaHandle, 'lua_pushinteger'));
  gLuaPushBooleanej := TLuaPushBoolean(GetProcAddress(gLuaHandle, 'lua_pushboolean'));
  gLuaIsNumberej := TLuaIsString(GetProcAddress(gLuaHandle, 'lua_isnumber'));
  gLuaIsStringej := TLuaIsString(GetProcAddress(gLuaHandle, 'lua_isstring'));
  gLuaGetTopej := TLuaGetTop(GetProcAddress(gLuaHandle, 'lua_gettop'));
  gLuaSetTop := TLuaSetTop(GetProcAddress(gLuaHandle, 'lua_settop'));
  gLuaType := TLuaType(GetProcAddress(gLuaHandle, 'lua_type'));
  gLuaPushNilej := TLuaPushNil(GetProcAddress(gLuaHandle, 'lua_pushnil'));
  gLuaNextej := TLuaNext(GetProcAddress(gLuaHandle, 'lua_next'));
  gLuaProc25 := GetProcAddress(gLuaHandle, 'lua_gettable');
  Result := True;
  gLuaLoaded := True;
  gLuaAvail7 := True;
end;

function UnLoadLuaLib: Boolean;
begin
  { Выгрузка lua5.1.dll: гасим все указатели, потом признак загрузки и
    саму библиотеку. Гасить обязательно -- иначе после повторной загрузки
    в ячейке остался бы адрес из прежнего образа. }
  gLuaProc01 := nil;
  gLuaProc00 := nil;
  gLuaProc02 := nil;
  gLuaPCall := nil;
  gLuaProc04 := nil;
  gLuaToLStringej := nil;
  gLuaPushString := nil;
  gLuaPushLStringej := nil;
  gLuaInsert := nil;
  gLuaSetTableej := nil;
  gLuaPushCClosure := nil;
  gLuaRaiseby := nil;
  gLuaLoadString := nil;
  gLuaProc13 := nil;
  gLuaCreateTableej := nil;
  gLuaPushNumberdp := nil;
  gLuaPushIntegerej := nil;
  gLuaPushBooleanej := nil;
  gLuaIsNumberej := nil;
  gLuaIsStringej := nil;
  gLuaGetTopej := nil;
  gLuaSetTop := nil;
  gLuaType := nil;
  gLuaPushNilej := nil;
  gLuaNextej := nil;
  gLuaProc25 := nil;
  Result := False;
  gLuaLoaded := False;
  if gLuaHandle <> 0 then
  begin
    FreeLibrary(gLuaHandle);
    Result := True;
  end;
end;

procedure LuaClose(T: TObject; X: Integer);
begin
  { Закрыть lua_State у объекта-обёртки. Под try..except нарочно: lua_close
    на испорченном состоянии валится внутри библиотеки, а нам после этого
    ещё жить. Ручку гасим в любом случае -- второй раз закрывать нечего. }
  if gLuaLoaded then
  begin
    try
      TLuaClose(gLuaProc02)(TLuaRef(T).Handle);
    except
    end;
    TLuaRef(T).Handle := 0;
  end;
end;

{ Если библиотека ещё не загружена -- грузим прямо здесь, и только при
  удаче открываем состояние. Handle остаётся нулевым, если Lua нет:
  дальше по нулю всё и проверяется. }
constructor TLua.Create;
begin
  inherited Create;
  if gLuaLoaded or LoadLuaProcs(string(gLuaLibNameCow)) then
  begin
    Handle := LuaNewState;
    TLuaOpenLibs(gLuaProc01)(Handle);
  end;
end;

destructor TLua.Destroy;
begin
  if Handle <> 0 then
    TLuaClose(gLuaProc02)(Handle);
  inherited Destroy;
end;

procedure TLua.RegP(const Name: string; Func: TLuaCFunc; N: Integer);
begin
  LuaBindGlobal(Handle, PChar(Name), Func);
end;

{ Не дописано: то же, что RegP, но с сырым указателем. }
procedure TLua.Reg(const Name: string; Func: Pointer; N: Integer);
begin
  { lua_pushstring(имя) / lua_pushcclosure(Func, 1) /
    lua_settable(L, LUA_GLOBALSINDEX) }
end;

function LuaNewState: Integer;
begin
  Result := TLuaNewState(gLuaProc00);
end;

{ Загрузка кода и запуск. Ошибка загрузки возвращается как есть, pcall
  зовётся только при нулевом коде. }
function LuaDoString(L: Integer; S: PChar): Integer;
var
  R: Integer;
begin
  R := gLuaLoadString(L, S);
  Result := R;
  if R = 0 then
  begin
    R := gLuaPCall(L, 0, -1, 0);
    Result := R;
  end;
end;

{ Значение уже лежит на вершине стека Lua; имя кладём сверху,
  lua_insert(L, -2) меняет их местами, и пара уходит в таблицу глобальных. }
procedure LuaSetGlobal(L: Integer; Name: PChar);
begin
  gLuaPushString(L, Name);
  gLuaInsert(L, -2);
  gLuaSetTableej(L, LUA_GLOBALSINDEX);
end;

{ Пара «имя -> замыкание» кладётся в таблицу глобальных. }
procedure LuaBindGlobal(L: Integer; Name: PChar; Func: TLuaCFunc);
begin
  gLuaPushString(L, Name);
  LuaPushClosure(L, Name, Func);
  gLuaSetTableej(L, LUA_GLOBALSINDEX);
end;

{ Имя команды попадает в стек Lua ДВАЖДЫ: ключом таблицы (это делает
  LuaBindGlobal) и здесь -- значением upvalue, по которому единственный
  обработчик узнаёт, какую команду у него просят. }
procedure LuaPushClosure(L: Integer; Name: PChar; Func: TLuaCFunc);
var
  S: string;
begin
  S := Name;
  gLuaPushLStringej(L, Name, Length(S));
  gLuaPushCClosure(L, Func, 1);
end;

function LuaUpvalueIndex(N: Integer): Integer;
begin
  Result := LUA_GLOBALSINDEX - N;
end;

{ Обычный lua_pop: settop на -N-1. }
procedure LuaPop(L, N: Integer);
begin
  gLuaSetTop(L, -N - 1);
end;

{ 5 -- LUA_TTABLE }
function LuaIsTable(L, Idx: Integer): Boolean;
begin
  Result := gLuaType(L, Idx) = 5;
end;

{ 0 -- LUA_TNIL }
function LuaIsNil(L, Idx: Integer): Boolean;
begin
  Result := gLuaType(L, Idx) = 0;
end;

initialization

end.
