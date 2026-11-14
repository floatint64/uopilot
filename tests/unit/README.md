# Юнит-тесты

Консольное приложение на FPCUnit (`ScriptTests.lpi`). Линкует движок скриптов
(`Unit1`, `uScanThread`), но не показывает окон: проверяются выражения и
команды без GUI.

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

## Полный прогон (с выводом информации)

```powershell
.\tests\unit\ScriptTests.exe --all --format=plain
```

Выводит каждый тест; при падении — сообщение, класс исключения и место
(`at TestScriptExpressions.pas:42`), в конце — итог:

```text
TScriptExprTest Time:00.003 N:6 E:0 F:0 I:1
...
Number of run tests: 6
Number of errors:    0
Number of failures:  0
```

- `N` — выполнено, `E` — errors, `F` — failures, `I` — ignored.
- `Ignored` — тесты, помеченные `EIgnoredTest` (например, известный баг
  `size("")` из `BUGS.md`); на код возврата не влияют, в выводе попадают в
  `List of ignored tests`.

Полезные варианты:

```powershell
# один набор
.\tests\unit\ScriptTests.exe --suite=TScriptExprTest --format=plain

# список зарегистрированных наборов/тестов
.\tests\unit\ScriptTests.exe --list

# XML-отчёт для CI
.\tests\unit\ScriptTests.exe --all --format=xml --file=tests\unit\results.xml

# прогресс точками и без адресов в выводе падений
.\tests\unit\ScriptTests.exe --all --progress --no-addresses
```

`plain` — формат по умолчанию (задан в `ScriptTests.lpr`), а запуск без
аргументов уже прогоняет все тесты, поэтому `ScriptTests.exe` равнозначен
`ScriptTests.exe --all --format=plain`.

## Примечания

- Бинарник линкует движок и LCL: окно не создаётся, но для сборки нужны
  установленные в Lazarus пакеты, перечисленные в `.lpi`.
- Движок работает с cp1251, поэтому UTF-8 литералы в тестах переводятся через
  `ToScript()` (`uScriptTestSession.pas`), иначе кириллические кейсы падают.
