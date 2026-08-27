Автор DarkMaster
https://forum.uokit.com/index.php?showtopic=28840

============== Файл .cpp 0.1.1 ==============

#include <stdexcept>

using namespace std;

struct tInitStruct
{
long unsigned FunctionCount;
const char** FunctionNames;
};

struct tParamStruct
{
    int unsigned* WindowHandle; // Handle of workWindow
    int unsigned* WindowPID; // pid of process of workWindow
    int unsigned Reserved;
    char* ParamString; // string of parameters with substituted variables
    char* ParamStringOrig; // original string of parameters
    char Result[1048576]; // array for returned values
};


tParamStruct *ParamStruct;       // init by UOPilot
static tInitStruct InitStruct;   // init by plugin, free on unload


extern "C" __declspec(dllexport) unsigned long * __stdcall InitPlugin(int App, int Scr, double& Version)
{
    // Количество полезных экспортируемых функций для сообщения пилоту
    // в зависимости от версии протокола обмена между пилотом и плагином.
    // Это НЕ версия самого пилота, а версия протокола обмена между пилотом и длл.
    if (Version >= 2.37)
    {
        InitStruct.FunctionCount = 4;
        InitStruct.FunctionNames = new const char*[InitStruct.FunctionCount];
        InitStruct.FunctionNames[0] = "Function1";
        InitStruct.FunctionNames[1] = "Function2 (много параметров)";
        InitStruct.FunctionNames[2] = "Function3|path\path2\path\name_in_UOPilot (a lot of parameters)";
        InitStruct.FunctionNames[3] = "Function4|path\path2\name_in_UOPilot2 (a lot of parameters)";
    }
    else
    {
        InitStruct.FunctionCount = 0; // Выгурзит длл, т.к. функций для экспорта нет.
        Version = 2.37; // Вернем в UOPilot, для сообщения пользователю.
    }
    return (&InitStruct.FunctionCount);
}

// Образец функции используемой в пилоте. Вернет значения переданные пилотом
// при иницализации dll и доступные для для дальнейших действий.
extern "C" __declspec(dllexport) void __stdcall Function1(tParamStruct *ParamStruct)
{
    sprintf_s(ParamStruct->Result,
        "%s" "%d" "%s" "%d" "%s" "%s" "%s" "%s",
        "Handle ", ParamStruct->WindowHandle,
        "; Pid ", ParamStruct->WindowPID,
        "; Parametr string ", ParamStruct->ParamString,
        "; Parametr string original ", ParamStruct->ParamStringOrig
        );
}

// Образец функции, возвращающей строку.
extern "C" __declspec(dllexport) void __stdcall Function2(tParamStruct *ParamStruct)
{
    strcpy_s(ParamStruct->Result, "Simple emty function");
}
extern "C" __declspec(dllexport) void __stdcall Function3(tParamStruct *ParamStruct)
{
    strcpy_s(ParamStruct->Result, "Simple emty function");
}
extern "C" __declspec(dllexport) void __stdcall Function4(tParamStruct *ParamStruct)
{
    strcpy_s(ParamStruct->Result, "Simple emty function");
}

extern "C" __declspec(dllexport) void __stdcall DonePlugin()
{
    delete[] InitStruct.FunctionNames;
}




================= Файл .def =================

LIBRARY
EXPORTS
    InitPlugin
    DonePlugin
    Function1
    Function2
    Function3
    Function4
