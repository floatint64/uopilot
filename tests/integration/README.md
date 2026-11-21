# Интеграционные тесты

[Тесты команд работы со строками](./strings_tests.txt)
[Тесты команд работы с окнами](./windows_tests.txt)
[Тесты команд отправки текста](./sends_tests.txt)
[Тесты команд буфера обмена](./clipboard_tests.txt)
[Проверки production-адаптера TScanDriverHost](./driver_host_tests.txt)
[Конфиг пилота для запуска тестов](./uopilot.ini)

Тесты движка, сгенерированные из `tests/unit/cases/*.tsv`
(подробности ниже). Строки, regexp, сравнения и `get number`/`get word`
остаются в `strings_tests.txt`: генерировать их повторно не нужно.

[Математика](./expr_math_tests.txt)
[Даты](./expr_dates_tests.txt)
[Константы](./expr_constants_tests.txt)
[Команда set](./cmd_set_tests.txt)
[Массивы](./arrays_tests.txt)
[Поток управления](./flow_tests.txt)
[Известные баги](./known_bugs_tests.txt)

Ручные дополнения (генератор их не покрывает):

[2D-массивы: sort/delete column](./arrays_2d_tests.txt)
[Edge-кейсы команд](./commands_edges_tests.txt)

[Генератор integration-тестов движка](./tools/gen_integration_tests.ps1)

## Запуск

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\strings_tests.txt /r0
```

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\windows_tests.txt /r0
```

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\sends_tests.txt /r0
```

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\clipboard_tests.txt /r0
```

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\driver_host_tests.txt /r0
```

Бинарник из `lazbuild uopilot.lpi` лежит в `lib\i386-win32\uopilot.exe`;
команды выше предполагают, что он доступен как `uopilot.exe`, либо
используйте полный путь (см. пример для `expr_math_tests.txt` ниже).

Приложение при выходе сохраняет `Last_scriptN`/`LastScripts` в
`uopilot.ini`. Это runtime-состояние, а не часть тестов: перед коммитом
восстанавливайте файл:

```shell
git checkout -- tests\integration\uopilot.ini
```

## Интеграционные тесты движка из юнит тестов

`tests/integration/*_tests.txt` для math/dates/cmd_set/arrays/flow/known_bugs
не редактируются руками: их собирает `tools\gen_integration_tests.ps1` из
`tests/unit/cases/*.tsv`. Скрипт — обычный UoPilot-скрипт, который
прогоняется через реальное приложение (сборка без `-dUOPILOT_UNIT_TESTS`),
а не через in-process бэкенд unit-тестов.

Уникальные кейсы из этих
TSV перенесены туда же руками: `hex2dec_ff/0x1f/invalid/empty`,
`get_num_0x_upper`, `get_num_inside_word`, `get_word_double_spaces`.

```powershell
# перегенерировать .txt после правки TSV
powershell -ExecutionPolicy Bypass -File tests\integration\tools\gen_integration_tests.ps1

# проверить, что checked-in .txt соответствуют TSV (exit code 1 при drift)
powershell -ExecutionPolicy Bypass -File tests\integration\tools\gen_integration_tests.ps1 -Check
```

Запуск одного файла (production-бинарник из `lib\i386-win32`):

```shell
start /wait lib\i386-win32\uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\expr_math_tests.txt /r0
```

`-Check` обязателен перед коммитом: иначе легко поправить TSV и забыть
перегенерировать `.txt`. Skip-кейсы перечислены в начале файла с причиной и в
`PASS`/`FAIL` не входят. Генератор собирает только файлы из `$fileMap`;
`expr_clock.tsv` — unit-only (в production часы реальные), поэтому отдельного
`.txt` для него нет. Константы и `version` локаль-независимы и генерируются в
`expr_constants_tests.txt`.

Что осознанно не переносится в integration:

- `msg`, `hint`, `exit`-флаг и прочие test-hooks — это unit-наблюдения,
  а не production; при `OutputMessagesTo=2` любой `msg`/error-path открывает
  модальное окно и вешает прогон;
- `div`/`mod` на ноль, `get number` без целей, `get word #...`, `size("")` и
  прочие известные баги — валят приложение или требуют message box;
- `flow_end_script` и `flow_exit` — останавливают скрипт/процесс; в
  `flow_tests.txt` вместо них остаются только `wait 0/1`;
- ячейки `%a[i][j]` (`j > 1`) в выражениях production не читаются, поэтому
  сортировка/удаление столбца двумерного массива проверяются косвенно в
  `arrays_2d_tests.txt`; обычные 2D-проверки (`size`, `minx`, `maxx`,
  `delete_row`) — в `arrays_tests.txt`;
- math-кейсы с десятичной точкой (`round(2.4)` и т.п.) и все `timestamp(...)`:
  production разбирает числа и даты системной локалью, а unit-бинарник
  принудительно ставит `.`/`yyyy-mm-dd`. На машине с `ru-RU` эти кейсы
  помечены `// SKIP locale`; `dayofweek(2024 1 2)` от локали не зависит и
  исполняется.

`known_bugs_tests.txt` содержит только skip-комментарии (`PASS=0 FAIL=0`):
баги остаются в unit-тестах, но список фиксируется и в integration.

## Результаты прогона 2026-11-18

Прогон на текущем `TScanThread.Execute` (после перехода на
`TScriptDriver.Step`), бинарник собран из `uopilot.lpi`:

| Набор | PASS | FAIL | Итог |
|---|---:|---:|---|
| `strings_tests.txt` | 148 | 0 | PASS |
| `clipboard_tests.txt` | 11 | 0 | PASS |
| `windows_tests.txt` | 21 | 0 | PASS |
| `sends_tests.txt` | 37 | 0 | PASS |
| `driver_host_tests.txt` | 3 | 0 | PASS |

Регрессий production-перехода на этих наборах не обнаружено, старый line-loop
под флагом не возвращался.

## Примечания к driver_host_tests.txt

- Набор идёт через реальный `TScanThread.Execute`, поэтому проверяет
  `TScanDriverHost`, а не тестовый `TLegacyDriverHost`.
- Покрыты `BeforeLine` (обычный `/r`-запуск), `WaitEmptyLine`/`WaitEmptyPrefix`
  (пустые строки и строка из пробелов), `WaitBeforeCommand` (пауза перед
  каждой командой задана `ScriptDelayDef=100` в `uopilot.ini`),
  `HandleBlockComment` (многострочный `(* ... *)`) и `HandleLuaBlock`
  (пустой `--lua`/`--endlua`).
- Непустой Lua-код и `WaitForInputIdle`/`PauseSOnClientClose` автоматически
  не проверяются: первому нужен стабильный Lua-стенд, второму — управляемое
  закрытие внешнего окна клиента.

## Примечания к windows_tests.txt

- Тест запускает классический `C:\Windows\System32\notepad.exe` (32-битный пилот
  через WOW64-редирекцию попадает в `SysWOW64`). На медленных машинах окно notepad
  с классом `Notepad` создаётся не мгновенно (~1.5–2 с), поэтому сетап ждёт с
  повторными попытками — общее время прогона может достигать ~6 с.
- Выделение текста в C-кейсах делается через `sendex {home}` + `sendex ~{end}`
  (Shift+End), а НЕ через `Ctrl+A`: глобальный хоткей UoPilot
  «Set work window» (Ctrl+A) перехватывает `Ctrl+A` и не даёт notepad выделить
  текст (проверено и вручную). Включение "прозрачных" хоткеев должно помочь это побороть.

## Примечания к sends_tests.txt

- Тест запускает классический `C:\Windows\System32\notepad.exe` и ставит рабочее
  окно на его Edit-контрол через `set workwindow #ed` (это корректный синтаксис;
  вариант `set #r workwindow (#ed)` не работает). `send`/`send217`/`say` шлют
  сообщения напрямую в `ClientWnd2` и от фокуса не зависят.
- Сравнение текста идёт через `getwindowtext (#ed)` в предположении, что
  системный ANSI-кодпейдж = cp1251 (как и в windows_tests.txt).
- **Очистка Edit**: `setwindowtext (#ed "")` не очищает текст в Edit-контроле
  notepad, поэтому `clear_edit` выделяет всё (`sendmessage (#ed 177 0 -1)` —
  `EM_SETSEL`) и удаляет выделение (`sendmessage (#ed 771 0 0)` — `WM_CLEAR`).
  Это детерминировано и не требует фокуса.
- **sendex** печатает через `keybd_event` в окно с фокусом и зависит от
  раскладки: перед латиницей ставится `setlayout (0409)`, перед кириллицей —
  `setlayout (0419)`. `setlayout` шлёт `WM_INPUTLANGCHANGEREQUEST` в `#ed`,
  поэтому notepad переключает язык ввода. Если русской раскладки `00000419` в
  системе нет (`setlayout` вернул 0), кириллические sendex-кейсы логируют
  `SKIP` и не падают.
- **Смешанные строки (кириллица+латиница) для sendex не проверяются**: `keybd_event`
  набирает символ по раскладке ЦЕЛЕВОГО окна, поэтому `приветworld` в одной
  раскладке корректно не набрать (латинская часть печатается как кириллица).
  Полная матрица mixed-строк покрывается для `send`/`send217`/`say`
  (детерминированы: `WM_CHAR` несёт байт cp1251).
- `say` шлёт текст + `Enter` (`$D`), поэтому проверяется префиксом
  (`posex` = 1) + наличие хвостового перевода строки.
- `*_up`/`*_down` — только smoke (одна клавиша): `send217_down {a}` резолвит
  имя клавиши в `VK_A` и печатает заглавную `A` с автоповтором; проверяется
  префикс и что клавиша не «залипает» (скрипт доходит до конца, не зависая).
- Прогон занимает ~25–35 с (сетап notepad + ожидания на применение раскладки и
  ввод); при зависании завершить приложение через `taskkill /f /im uopilot.exe`.