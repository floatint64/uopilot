# TODO

## Миграция VCL → Lazarus/LCL

- В перспективе заменить локальный VCL-SynEdit (`synedit/`) на Lazarus-овый SynEdit
  из `components/synedit` и перевести код на `TSynEdit`/`TSynMemo` вместо точечных
  `{$IFNDEF FPC}`-правок вендорных исходников (см. `synedit/SynEditMiscClasses.pas`).

## Миграция на UTF-8

- Текущий код — гибрид: LCL-строки уже UTF-8, но часть API/логики (WinAPI
  `MessageBoxA`, cp1251-транскодирование в SynEdit) завязана на ANSI/cp1251.
  Полностью перейти на UTF-8: убрать точечные `UTF8Decode`/`UTF8ToAnsi`
  обвязки, перевести SynEdit-транскодирование на UTF-8 и использовать широкие
  WinAPI (W-варианты) повсеместно. См. `Unit1.pas:MsgBox` и
  `synedit/SynEdit.pas` (cp1251).
