# Портирование PCRE *.obj файлов (OMF формат) в COFF формат для линкера Lazarus

В лоб не слинкуется - не поддерживается формат OMF от Delphi.
В репозитории уже лежат пропатченные и линкуемые объектники. Нет необходимости выполнять процедуру заново. `pcre.pas` в основных исходниках содержит объявление символов для корректной линковки.

## Инструменты

### Скрипт пост-обработки COFF

`pcre\patch_symbols.ps1` — переписывает в каждом COFF объекте:

- имена секционных символов (StorageClass = 3 = C_STAT, 1 aux) на inline-имена
  `.text` / `.data` / `.bss` (≤8 байт, без строковой таблицы);
- имена секций `_TEXT` / `_DATA` / `_BSS` → `.text` / `.data` / `.bss`.

Причина: 

objconv пишет **имена секционных символов** с неправильными индексами в
строковую таблицу. У объекта `pcre_version.obj` три секционных символа
(C_STAT, 1 aux) ссылаются на смещения внутри строки `"pcre_version"`:

| Секция | Заголовок секции | Имя секционного символа (ожидалось) | Фактически (stridx) |
|---|---|---|---|
| `_TEXT` | `_TEXT` | `_TEXT` | `pcre_version` (4) |
| `_DATA` | `_DATA` | `_DATA` | `ersion` (10) |
| `_BSS`  | `_BSS`  | `_BSS`  | `` (16, пусто) |

Место в исходнике: `objconv\src\omf2cof.cpp:136` (`MakeSymbolTable1`):

```c
StringI = NewStringTable.PushString(sname);
((uint32_t*)(sym.s.Name))[1] = StringI;   // имя секционного символа
```

При финализации строковой таблицы индексы «съезжают»: заголовок секции получает
корректное имя (`_TEXT`), а символ — смещение в середину другой строки. FPC-линкер
(ogcoff) не находит секцию по имени символа → `internalerror(200205172)`.

### 

## Алгоритм:

- `objconv.exe -fcoff32 "-np:@:" pcre\<name>.obj pcre\coff\<name>.obj`
- `powershell -ExecutionPolicy Bypass -File pcre\coff\patch_symbols.ps1`
- `lazbuild.exe --build-all uopilot.lpi`