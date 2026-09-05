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

- Сообщения скриптов (`TScanThread.Msg`, `Self.Msg`, `gScriptso3[..].Msg`) раньше
  собирались смешанно: `LoadStr` (FPC) возвращал UTF-8, а скриптовый движок
  (SynEdit, `LogPrefix`) держит строки в cp1251 — на границе `MsgBox`
  (`UTF8Decode`) это давало «???» вместо кириллицы в `ShowScriptMsg`.
  Решено локально (вариант 2): добавлен `LoadStrCP1251` (cp1251-вариант
  `LoadStr`), `T.Msg`/`Self.Msg` собираются в cp1251 (кириллические литералы
  обёрнуты в `UTF8ToCP1251`), а на границе вывода конвертируются в UTF-8
  (`ShowScriptMsg` → `CP1251ToUTF8` для `MsgBox`; `WriteScriptLog` — для LCL-
  мемо и файла лога). Hint-окно (`DrawTextA`) остаётся на cp1251. Полный переход
  на UTF-8 остаётся в этом разделе.

- Подсветка кириллических/Unicode идентификаторов в SynEdit. Сейчас `TSynUOPilotSyn`
  разбирает текст побайтово (`fProcTable[#0..#255]`, `Identifiers[#0..#255]`,
  `GetIdentChars: set of AnsiChar`), поэтому не-ASCII символы не являются валидными
  символами идентификатора: `привет`/`$привет` отображаются (после фикса `UnknownProc`),
  но красятся как `tkUnknown`, а не `tkIdentifier`. Сделать токенизатор
  codepoint-ориентированным (декодирование через `LazUTF8`, классификация буква/цифра
  через `Character.TCharacter.IsLetterOrDigit`): ввести `Utf8Proc` для не-ASCII старта,
  переписать `IdentProc` на сканирование Unicode-хвоста (с даунгрейдом `tkKey →
  tkIdentifier` для случая «ключевое слово + кириллица», напр. `forпривет`), а
  `$`/`%`/`#`-сканеры (`IntegerProc`/`PercentProc`/`AsciiCharProc`) — на сканирование
  Unicode-букв, чтобы `$привет` стал одним токеном как `$name`. ВАЖНО: двойной клик и
  `GetWordAtRowCol` уже выделяют кириллицу — `TSynWordBreaker` считает все байты
  `#$80..#$FF` символами слова (`syneditmiscclasses.pp:1805`), поэтому `GetIdentChars`
  для этого менять не нужно.
