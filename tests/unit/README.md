# Юнит-тесты

Консольное приложение на FPCUnit (`ScriptTests.lpi`). Линкует движок скриптов
(`Unit1`, `uScanThread`), но не показывает окон: проверяются выражения, команды
и control-flow без GUI.

Эти тесты **не заменяют** интеграционный прогон
`tests/integration/strings_tests.txt`. Интеграционный скрипт остаётся
регрессией реального GUI-цикла (`Execute`) и не переносится сюда целиком:
здесь каждый кейс проверяет один контракт, а не сценарий.

Из `cases/*.tsv` собираются интеграционные аналоги
`tests/integration/*_tests.txt` для production-бинарника
`lib\i386-win32\uopilot.exe` и для оригинального бинарника: см.
`tests/integration/tools/gen_integration_tests.ps1` и
[README интеграционных тестов](../integration/README.md). После правки TSV
нужно перегенерировать файлы и прогнать `gen_integration_tests.ps1 -Check`.

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
| `ScriptsExprStrings` | `cases/expr_strings.tsv` | `size`, `posex`, `copy`, `delete`, `insert`, `ord`, `chr`, `chartohex`, `chartohexf`, `hex2dec`, `string_*`, `trim`/`ltrim`/`rtrim`, пустые строки |
| `ScriptsExprRegexp` | `cases/expr_regexp.tsv` | `regexp` через скрипт; `#r`, `#pos`, `$hit` — отдельные кейсы |
| `ScriptsExprCompare` | `cases/expr_compare.tsv` | `=`, `==`, `<>`, `<`, `>`, `<=`, `>=`, `<-`, `->` в `if`/`else` |
| `ScriptsExprMath` | `cases/expr_math.tsv` | `abs`, `round`/`floor`/`ceil`/`trunc`, `sqrt`/`power`/`log`, тригонометрия, `minx`/`maxx`/`mean`, `mod`/`div`, точки, `lengthdir_*`, `is_real`/`is_string`; invalid-аргументы |
| `ScriptsExprDates` | `cases/expr_dates.tsv` | `timestamp`/`*fromdate`, `add*`/`sub*`, `dayofweek`; `datenow`/`timenow` — `skip` |
| `ScriptsCmdSet` | `cases/cmd_set.tsv` | скалярные `set #`/`set $`: кавычки, подстановка, перезапись, регистр, арифметика, комментарий внутри кавычек |
| `ScriptsCmdGet` | `cases/cmd_get.tsv` | `get number`, `get word`; negative/edge (hex, слово с числом, двойные пробелы) |
| `ScriptsArray` | `cases/arrays.tsv` | `set %a [N]` и `1|2/3|4`, `size(%a)`, `minx`/`maxx`, `sort_array`, `delete_array`, `indexof`, доступ к ячейке |
| `ScriptsFlow` | `cases/flow.tsv` | `if`/`if_not`/`else`, вложенный `if`, `for`, `while`, `repeat`, `gosub`/`return`, `goto`, `break`, `continue`, `switch`/`case`, `end_script`, `wait`, `exit` |
| `ScriptsKnownBugs` | `cases/known_bugs.tsv` | известные баги (`BUGS.md`) в виде `skip`-кейсов |

Каждый TSV-набор регистрируется дважды: `Scripts*` (legacy) и
`Scripts*Runtime` (dual-run скелет). Runtime-кейсы видны в `--list`, но пока
все `Ignored` с причиной `runtime backend is not migrated yet`: переноса
движка на новый core ещё нет, `CoreSupports` возвращает `False`.

Остальные unit-тесты:

- `TestScriptExpressions` — smoke/white-box выражения и таблицы команд;
- `TestScriptParser` — `StripScriptComment`, `TrimRightScriptLine`,
  `InsertSpaceBeforeParen`, `CutCommandAtColon`, `EvalScriptPoint`;
- `TestScriptDriver` — ошибки драйвера: неизвестная/внешняя команда, `--lua`,
  `(* *)`, лимит шагов, `end_script`, успешный `set`;
- `TestScriptDriverFlow` — сам `TScriptDriver.Step`/`Run` на fake
  state/host: комментарии, пустые строки, `(`/`:`, `RepeatLine`/`RepeatCmd`,
  `RestartFlag`, `srEnd`/`srScanLoop`/`srAgain`/`srRetry`, `MaxSteps`,
  `rpError`/`rpReset`;
- `TestScriptSession` — наблюдаемость сессии: `TryNumVar`/`TryStrVar`/
  `TryArrCell` (не создают переменную), `HostCallText`, `LogText`,
  `MessageText`/`HintText`/`ExitRequested`, структурированный `LastErrorInfo`,
  allowlist;
- `TestScriptCommands` — code-тесты `msg`/`hint`/`exit`/`wait`, потому что TSV
  умеет читать только переменные;
- `TestScriptCommandEdges` — negative/edge: деление на ноль, `set #r` без
  довода, `get number` без целей, `get word` с `#`-целью, удалённый столбец,
  сброс наблюдений между `RunScript`;
- `TestScriptKnownBugs` — по одному `EIgnoredTest` на баг из `BUGS.md`;
- `TestScriptCoverage` — guard матрицы покрытия (см. ниже).

## Контракт `IScriptSession`

Помимо значений переменных, сессия отдаёт наблюдения:

- `TryNumVar`/`TryStrVar`/`TryArrCell` — `False`, если цели нет; в отличие
  от `NumVar`/`StrVar` не вызывают `FindScriptVar` и не создают переменную;
- `LogText` — строки, попавшие в лог (`log <text>` в тестовом драйвере пишет
  в наблюдаемый буфер, а не в UI);
- `HostCallText` — какие команды и на каких строках выполнял драйвер;
- `MessageText`/`HintText`/`ExitRequested` — наблюдения `msg`/`hint`/`exit`;
- `LastErrorInfo` — `Kind`/`Line`/`Message`; `LastError` оставлен для
  совместимости и читает `Msg`.

Data-driven наборы читают target через `Try...`: если скрипт не создал
переменную, кейс падает, а не получает `0`/`''` из несуществующей переменной.

## Настройки и сброс глобального состояния

`core/uScriptSettings.pas` содержит `IScriptSettings`/`TScriptSettings` и
`FastTestProfile` — прежний жёсткий профиль `CreateForTest` (`PauseCmd='0'`,
`PauseStr='0'`, нулевые задержки, `LogLevel=0`). `CreateForTest` принимает
профиль параметром; `nil` означает `FastTestProfile`.

`TLegacyScriptSession.Reset` вызывает `ResetGlobals` (`Unit1`):
обнуляет `gScriptso3`/`gProcScript`, кэши запуска, `Randomize`, очищает и
заново заполняет таблицы команд.

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

## Матрица покрытия

`cases/coverage.tsv` — checked-in артефакт `(name, kind) -> status/priority/
cases/note`. Строки строятся из живых таблиц `gCmdListah7`/`gCmdList2jj`
(`Unit1`), а не переписываются руками:

```powershell
.\tests\unit\ScriptTests.exe --gen-coverage=tests\unit\cases\coverage.tsv
```

Генератор сохраняет уже заполненные поля существующих имён; новые имена
получают `missing/P3`. `TestScriptCoverage` падает, если файл разошёлся с
движком, поэтому после добавления имени в `Unit1.pas` нужно перезапустить
генератор и закоммитить файл.

`gCmdNamesdd` содержит 23 пустые позиции-заглушки. Они остаются в матрице
строками `#<index>` со статусом `skip`, чтобы порядок и число строк совпадали
с движком: eval-строк 289, cmd — 136. Живых eval-имён при этом 266; guard
отдельно проверяет, что placeholder указывает именно на пустой слот.

Формат — те же 6 колонок TSV:

```text
name	kind	status	priority	cases	note
abs	eval	covered	P1	suite:ScriptsExprMath	
proc	cmd	skip	P3		spawns a separate TScanThread and tab; integration
```

- `kind`: `eval` или `cmd`.
- `status`: `covered` (есть непустой `cases`), `skip` (непустой `note`),
  `missing` (только `P3`, непустой `note`).
- `priority`: `P1` — чистые eval-функции; `P2` — простые команды без UI;
  `P3` — остальное.
- `cases` — ссылки через запятую/пробел:
  - `suite:ScriptsFlow` — все не-skip кейсы набора;
  - `case:flow_for_sum` — конкретный не-skip кейс;
  - `code:TestScriptSession.TestLogTextCapturesCommandLog` — code-тест
    (реестр FPCUnit не сканируется, проверяется только непустота).

Guard проверяет: точное соответствие живым именам, уникальность, допустимые
значения, наличие `cases`/`note`, существование `case:`/`suite:` ссылок,
покрытие каждого не-skip TSV-кейса, `covered`/`skip` у allowlist и P1/P2.

Отложено осознанно (в матрице `skip` с причиной): `proc`/`call` (отдельный
`TScanThread` и вкладка), `write`/`load_script`/`save_array`/`load_array` и
прочие внешние команды (нужен `IScriptHost`/`IFileHost`),
`StopUnknownCommand=0` (поля нет в `IScriptSettings`), `dec2hex` (ветка 88 с
подозрительным `Inc(p, Length(pc))`).

Characterization выявил ещё два ограничения, которые тоже помечены `skip`:
`mean(%a)` не принимает массив (`EZeroDivide`; скалярный `mean` покрыт в
`expr_math`), а ссылки на ячейку массива в выражениях (`set $r %a[2][2]`)
движок не поддерживает (так написано в `res/history_en.txt`). `indexof` с
отсутствующим значением возвращает `-1`, а не `0`, как предполагалось в плане.

## Локаль тестов

`ScriptTests.lpr` фиксирует тестовый профиль локали:
`DecimalSeparator='.'`, `DateSeparator='-'`, `ShortDateFormat='yyyy-mm-dd'`,
`TimeSeparator=':'`, `LongTimeFormat='hh:nn:ss'`. Без этого math/date-кейсы
зависели бы от настроек Windows. Это настройка тестового бинарника, а не
production: движок не становится локаль-независимым.

Поэтому в интеграционном тесте десятичные math-кейсы (`round(2.4)` и т.п.)
и все `timestamp(...)` помечены `// SKIP locale`: реальный `uopilot.exe`
разбирает их системной локалью. На `ru-RU` десятичная точка не парсится, а
`timestamp("2024-01-02 00:00:00")` даёт `EConvertError` и обрывает скрипт.
`dayofweek(2024 1 2)` от локали не зависит и остаётся в integration.

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

Драйвер исполняет только allowlist команд (список — `TestAllowedCommands` в
`uLegacyScriptSession.pas`):

`continue`, `break`, `for`/`end_for`, `goto`, `gosub`, `return`, `else`,
`repeat`/`end_repeat`, `end_script`, `set`, `if`/`if_not`/`end_if`,
`while`/`while_not`/`end_while`, `get`, `wait`, `msg`, `hint`, `exit`,
`init_arr`, `eval`, `log <text>`, `switch`, `case`, `end_switch`,
`sort_array`, `delete_array`.

`log <text>` в тестовом драйвере не трогает UI: текст складывается в
`TestLog` и доступен через `LogText`. UI-подкоманды (`log clear`, `log mode`,
`log save`, `log open`/`close`) по-прежнему отклоняются.

`msg`/`hint`/`exit` под `-dUOPILOT_UNIT_TESTS` пишут наблюдения в
`TScanThread` (`TestMessageText`/`TestHintText`/`TestExitRequested`) вместо
message box, hint-окна и `PostMessage(WM_CLOSE)`. Production-ветки не
меняются: весь test-hook под `{$IFDEF UOPILOT_UNIT_TESTS}`.

Явно **не поддерживается** и поднимает `EScriptDriverError`:

- блоки `--lua ... --endlua`;
- block-комментарии `(* ... *)` (разбор в `Execute` привязан к его циклу и
  содержит выход за границу строки; это отдельная bug-first задача);
- внешние команды: `send`/`mouse`/`window`/`memory`/`file`/`plugin`/`macro`,
  `clipboard`, `proc`/`call`, `exec`, `load_script`, `restart_script`,
  `write`/`save_array`/`load_array`;
- UI-подкоманды `log` (`clear`, `mode`, `save`, `open`, `close`);
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

Известные баги (`size("")`, маркеры `--lua` с пробелами, `get clipboard %a`,
`HexPairToByte("4g")`) живут в `TestScriptKnownBugs` и `cases/known_bugs.tsv`
как `EIgnoredTest`/`skip`: на код возврата они не влияют.

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
- `TScanThread.CreateForTest` выставляет `SelfRef` на себя: без этого ветки,
  работающие с массивом текущего скрипта (`minx`/`maxx`), падали в unit-тестах.
- `hex2dec`: в ветке 87 не сбрасывался `rd`, поэтому
  аргумент захватывался вместе с `)` и функция всегда возвращала `-1`.
  `dec2hex` (ветка 88) не характеризован: там отдельный подозрительный
  `Inc(p, Length(pc))`.
