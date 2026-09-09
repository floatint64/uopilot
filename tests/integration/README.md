# Интеграционные тесты

[Тесты работы со строками](./strings_tests.txt)
[Тесты команд работы с окнами](./windows_tests.txt)
[Конфиг пилота для запуска тестов](./uopilot.ini)

## Запуск

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\strings_tests.txt /r0
```

```shell
start /wait uopilot.exe /h%CD%\tests\integration /s%CD%\tests\integration\windows_tests.txt /r0
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