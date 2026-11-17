# Юнит-тесты

Консольное приложение на FPCUnit (`ScriptTests.lpi`). Линкует движок скриптов
(`Unit1`, `uScanThread`), но не показывает окон: проверяются выражения, команды
и control-flow без GUI.

Эти тесты **не заменяют** интеграционный прогон
`tests/integration/strings_tests.txt`. Интеграционный скрипт остаётся
регрессией реального GUI-цикла (`Execute`) и не переносится сюда целиком:
здесь каждый кейс проверяет один контракт, а не сценарий.

## Сборка

Из корня репозитория:

```powershell
& "$env:LAZARUS_ROOT\lazbuild.exe" tests\unit\ScriptTests.lpi -B
```

Если `LAZARUS_ROOT` не задан, укажите путь к `lazbuild.exe` явно.

Результат сборки — `tests\unit\ScriptTests.exe`. Проект собирается под
`i386-win32` с `-dUOPILOT_UNIT_TESTS`; зависимости (`LCL`, `SynEdit`,
`richmemopackage`, `pcre\coff`) уже прописаны в `.lpi`, промежуточные файлы
пишутся в `tests\unit\lib\...`.

## Короткий прогон (по коду возврата)

```powershell
.\tests\unit\ScriptTests.exe --all --sparse
if ($LASTEXITCODE -ne 0) { throw "Unit tests failed, exit code $LASTEXITCODE" }
```

`--sparse` выводит только упавшие/сломанные тесты и итоговую строку.

| Код | Значение |
|---|---|
| 0 | все тесты прошли (включая `Ignored`) |
| 1 | есть failures (несовпадение `Assert*`) |
| 2 | есть errors (исключение/AV внутри теста) |
| 3 | есть и failures, и errors |

Без PowerShell:

```shell
tests\unit\ScriptTests.exe --all --sparse
echo %ERRORLEVEL%
```

## Наборы

| Suite | Файл кейсов | Что проверяется |
|---|---|---|
| `ScriptsExprStrings` | `cases/expr_strings.tsv` | `size`, `posex`, `copy`, `delete`, `insert`, `ord`, `chr`, `chartohex`, `chartohexf`, `string_*`, `trim`/`ltrim`/`rtrim`, пустые строки |
| `ScriptsExprRegexp` | `cases/expr_regexp.tsv` | `regexp` через скрипт; `#r`, `#pos`, `$hit` — отдельные кейсы |
| `ScriptsExprCompare` | `cases/expr_compare.tsv` | `=`, `==`, `<>`, `<`, `>`, `<=`, `>=`, `<-`, `->` в `if`/`else` |
| `ScriptsCmdSet` | `cases/cmd_set.tsv` | скалярные `set #`/`set $`: кавычки, подстановка, перезапись, регистр, арифметика |
| `ScriptsCmdGet` | `cases/cmd_get.tsv` | `get number`, `get word` |
| `ScriptsArray` | `cases/arrays.tsv` | `set %a [N]`, `size(%a)`, `indexof`, доступ к ячейке |
| `ScriptsFlow` | `cases/flow.tsv` | `if`/`if_not`/`else`, вложенный `if`, `for`, `while`, `repeat`, `gosub`/`return`, `goto`, `break`, `continue`, `switch`/`case`, `end_script` |

Остальные unit-тесты:

- `TestScriptExpressions` — smoke/white-box выражения и таблицы команд;
- `TestScriptParser` — `StripScriptComment`, `TrimRightScriptLine`,
  `InsertSpaceBeforeParen`, `CutCommandAtColon`, `EvalScriptPoint`;
- `TestScriptDriver` — ошибки драйвера: неизвестная/внешняя команда, `--lua`,
  `(* *)`, лимит шагов, `end_script`, успешный `set`;
- `TestScriptDriverFlow` — сам `TScriptDriver.Step`/`Run` на fake
  state/host: комментарии, пустые строки, `(`/`:`, `RepeatLine`/`RepeatCmd`,
  `RestartFlag`, `srEnd`/`srScanLoop`/`srAgain`/`srRetry`, `MaxSteps`,
  `rpError`/`rpReset`.

Один suite:

```powershell
.\tests\unit\ScriptTests.exe --suite=ScriptsFlow --sparse
```

## Формат TSV

Файл — UTF-8, ровно 6 колонок через TAB:

```text
name	kind	target	script	expected	note
set_scalar_num	script	#r	set #r 42	42	
copy_ryosh	eval		copy("матрёшка" 4 3)	рёш	
flow_for_sum	script	#r	set #r 0\nfor #i 1 5\nset #r #r + #i\nend_for	15	
```

- `kind`: `eval` (одно выражение), `script` (многострочный скрипт), `skip`
  (игнорируемый кейс, `note` обязателен).
- `target`: для `script` — `#name`, `$name`, `%name[row][col]`
  (без индексов — `1,1`); для `eval` — пусто.
- Экранирование: `\n`, `\r`, `\t`, `\\`. Остальные `\x` сохраняются как есть,
  поэтому regexp-паттерны (`\d`, `\w`) не нужно удваивать.
- Ожидаемая пустая строка — пустое поле `expected` (строка TSV при этом
  заканчивается двумя TAB).
- Для числового target (`#...`) ожидание и факт сравниваются через `Int64`,
  с fallback на строку.
- Строки, начинающиеся с `//`, и необязательная строка заголовка
  `name<TAB>kind...` пропускаются.

Файлы кейсов читаются с диска из `tests\unit\cases\`; в `.lpi` они не входят.
Если файла нет, прогон падает с `EFOpenError`, а не становится «зелёным» без
данных. Дубли имён внутри файла и неверный `kind` — ошибка загрузки с номером
строки.

## Кодировка

Движок работает с cp1251. Исходники и TSV хранятся в UTF-8, поэтому
`TestScriptCases` переводит скрипт и ожидание через `ToScript()`
(`uScriptTestSession.pas`). Без этого кириллические кейсы падают.

## Что умеет тестовый драйвер

Line-loop скрипта живёт в `core/uScriptDriver.pas` (`TScriptDriver`), а чистые
текстовые хелперы — в `core/uScriptParser.pas`. Core не зависит от `Unit1`,
`uScanThread` и LCL: окружение приходит через `IScriptDriverState` и
`IScriptDriverHost`.

- `Step` — один проход по строке; на нём работает production
  `TScanThread.Execute`;
- `Run` — выполнить скрипт один раз (`srEnd`/`srScanLoop`/`srStop` — выход,
  `srRestart` — `rpError`/`rpReset`);
- `MaxSteps = 0` — без лимита (production), тесты выставляют конечный лимит.

Адаптеры production живут в `uScanThread.pas` (`TScanDriverState`/
`TScanDriverHost`), тестовые — в `uLegacyScriptSession.pas`
(`TLegacyDriverState`/`TLegacyDriverHost`). `TScanThread.Execute` только
вызывает `FDriver.Step` и маппит результат в `goto`/`Suspend`; собственного
line-loop там нет. `TLegacyScriptSession.RunScript` только загружает строки,
сбрасывает состояние и вызывает `FDriver.Run`.

Драйвер исполняет только allowlist команд:

`continue`, `break`, `for`/`end_for`, `goto`, `gosub`, `return`, `else`,
`repeat`/`end_repeat`, `end_script`, `set`, `if`/`if_not`/`end_if`,
`while`/`while_not`/`end_while`, `get`, `init_arr`, `eval`, `switch`, `case`,
`end_switch`, `sort_array`, `delete_array`.

Явно **не поддерживается** и поднимает `EScriptDriverError`:

- блоки `--lua ... --endlua`;
- block-комментарии `(* ... *)` (разбор в `Execute` привязан к его циклу и
  содержит выход за границу строки; это отдельная bug-first задача);
- внешние команды: `send`/`mouse`/`clipboard`/`window`/`memory`/`file`/
  `plugin`/`macro`, а также `wait`, `log`, `msg`, `hint`, `exit`,
  `proc`/`call`, `exec`, `load_script`, `restart_script`;
- `set logging ...` (меняет глобальное состояние лога и в test-режиме
  подмешивает служебный текст в `Msg`);
- неизвестная команда (кроме меток `:name`).

Лимит шагов — `MaxSteps` (по умолчанию `100000`); считаются все выполнения
команд, включая повторные итерации `RepeatCmd`. Зацикленный `goto` или
самоссылающийся `eval` даёт `EScriptDriverError`, а не зависание.

## Полный прогон

```powershell
.\tests\unit\ScriptTests.exe --all --format=plain
```

Выводит каждый тест; при падении — сообщение, класс исключения и место
(`at TestScriptCases.pas:119`), в конце — итог. `N` — выполнено, `E` — errors,
`F` — failures, `I` — ignored.

`size("")` остаётся известным багом (`BUGS.md`) и помечен `EIgnoredTest`:
на код возврата он не влияет.

Полезные варианты:

```powershell
# список зарегистрированных наборов/тестов
.\tests\unit\ScriptTests.exe --list

# XML-отчёт для CI
.\tests\unit\ScriptTests.exe --all --format=xml --file=tests\unit\results.xml

# прогресс точками и без адресов в выводе падений
.\tests\unit\ScriptTests.exe --all --progress --no-addresses
```

`plain` — формат по умолчанию (задан в `ScriptTests.lpr`), а запуск без
аргументов уже прогоняет все тесты.

## Примечания

- Бинарник линкует движок и LCL: окно не создаётся, но для сборки нужны
  установленные в Lazarus пакеты, перечисленные в `.lpi`.
- Тестовый экземпляр `TScanThread.CreateForTest` имеет `FForTest = True`;
  `ShowScriptMsg` в этом режиме не трогает `Application`/`fmSecondfj`, поэтому
  ошибки доступны через `LastError`, а не через message box.
- Каждый кейс получает свежую сессию в `SetUp`; `Vars`/`Timers`/`Arr48` между
  кейсами не переиспользуются.
