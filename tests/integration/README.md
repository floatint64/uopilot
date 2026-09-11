# Интеграционные тесты

[Тесты команд работы со строками](./strings_tests.txt)
[Тесты команд работы с окнами](./windows_tests.txt)
[Тесты команд отправки текста](./sends_tests.txt)
[Тесты команд буфера обмена](./clipboard_tests.txt)
[Конфиг пилота для запуска тестов](./uopilot.ini)

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