library Plugin;

uses  windows;

type
  tInitStruct = packed record
    FunctionCount : Cardinal;
    FunctionNames : Array of Pchar; // Должно быть именно динамическим массивом, иначе адресация съезжает
  end;

  tParamStruct = packed record // Структуру этого типа заполняет пилот, и передает на нее указатель плагину
    WindowHandle : Cardinal; // Handle of workWindow
    WindowPID    : Cardinal; // pid of process of workWindow
    ResultStruct : Cardinal; // ранее Reserved. Тип не менял, так что можно не переименовывать в плагине.
    ParamString     : Pchar; // string of parameters with substituted variables
    ParamStringOrig : Pchar; // original string of parameters
    ResultArr    : array [0..1048576{0..32767}] of char // array for returned values
  end;

  tResultStruct = packed record // Заполняется плагином. Память под строку выделяется и освобождается плагином.
    used          : boolean;   // Используется ли эта структура при возврате значения. = false
    RLength       : Cardinal;  // Размер данных.                                       = 0
    RArray        : Pchar;     // Указатель на возвращаемую строку.                    = ''
    Reserved1     : Cardinal;
    Reserved2     : Cardinal;
    Reserved3     : Int64;
    Reserved4     : Int64;
  end;
  ptResultStruct = ^tResultStruct;


var
  ParamStruct: ^tParamStruct;  // init by UOPilot
  InitStruct :  tInitStruct;   // init by plugin, free on unload


function InitPlugin(App, Scr: integer; Var Version: Real):Pointer ; stdcall;
// App: Application.Handle of UOPilot
// Scr: reserved
// Version: UOPilot version
begin
  // check UOPilot version, if it needed
  if Version >= 2.37 then begin
    // exported function count, for UOPilot
    InitStruct.FunctionCount := 4;
    // Задаем размер динамического массива для имен функций
    setlength (InitStruct.FunctionNames, InitStruct.FunctionCount);
    // exported function names
    InitStruct.FunctionNames[0]   := 'Function1';
    InitStruct.FunctionNames[1]   := 'Function2 (много параметров)';
    InitStruct.FunctionNames[2]   := 'Function3|path\path2\path\name_in_UOPilot (a lot of parameters)';
    InitStruct.FunctionNames[3]   := 'Function4|path\path2\name_in_UOPilot2 (a lot of parameters)';

  end else begin
    InitStruct.FunctionCount := 0;
    Version := 2.37;  // Вернем в UOPilot, для сообщения пользователю.
  end;

  // if exported function count = 0, then plugin will be unloaded
  Result := @InitStruct; // Возвращаем в пилот адрес структуры с именами функций и их колличеством
end;


procedure DonePlugin; stdcall;
begin
  // free memory
  setlength (InitStruct.FunctionNames, 0);
end;


// exported function example
function Function1(AdressPS: Pointer): boolean ; stdcall;
var f :string;
begin
  // function has only one parameter, this is Pointer to the tParamStruct structure
  ParamStruct := AdressPS;

  if ParamStruct^.WindowHandle = 0 then
    f:= 'workwindow not defined'+#0
  else begin
    f:= 'ok, worked' + #9 + 'value, sended to plugin, returned in next element of array';
    f:= f + '/n' + ParamStruct^.ParamString+#0;
  end;
  CopyMemory (@ParamStruct^.ResultArr[0], @f[1], length(f));

  // return value not analized while, may be later
  Result := true;
end;

function Function2(AdressPS: Pointer): boolean ; stdcall;
begin
  Result := true;
end;

function Function3(AdressPS: Pointer): boolean ; stdcall;
var f :string;
begin
  ParamStruct := AdressPS;
  f:= 'Function3 passed'+#0;
  CopyMemory (@ParamStruct^.ResultArr[0], @f[1], length(f));
  Result := true;
end;

function Function4(AdressPS: Pointer): boolean ; stdcall;
begin
  ParamStruct := AdressPS;
 
  ptResultStruct(ParamStruct.ResultStruct).used    := true;
  ptResultStruct(ParamStruct.ResultStruct).RArray  := 'Function4 passed too'+#0;   // Pchar;
  ptResultStruct(ParamStruct.ResultStruct).RLength := Length(ptResultStruct(ParamStruct.ResultStruct).RArray);  // Cardinal;

  Result := true;
end;


// Имена экспортируемых функций.
// При загрузке плагина пилот ищет функцию с именем "InitPlugin", если не нашел, то ищет "_InitPlugin" и выполняет ее.
// При выгрузке плагина пилот ищет необязательную функцию с именем "DonePlugin", если не нашел, то ищет "_DonePlugin" и выполняет ее если нашел.
Exports
  InitPlugin,
  DonePlugin,
  Function1,
  Function2,
  Function3,
  Function4;

begin
end.

