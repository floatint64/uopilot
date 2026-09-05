# Портирование на Lazarus / FPC

Проект открывается и собирается в **Lazarus 2.0.12 / FPC 3.2.0**, target
**i386-win32**. Основной файл проекта — `uopilot.lpi`.

## Компонент TGauge и пакет GaugesPkg

`TGauge` (тонкая полоса прогресса `gScript` на вкладке «Скрипт») описан в
юните `Gauges.pas`. При открытии `Unit1.lfm` среда Lazarus ищет класс компонента
в собственном реестре, который строится из **установленных пакетов**. Пока
`Gauges.pas` не входит ни в один design-time пакет, среда выдаёт ошибку
«Невозможно найти класс компонента TGauge».

Чтобы IDE находила `TGauge`, в проект добавлен design-time пакет `GaugesPkg.lpk`
(юниты `Gauges.pas` + `GaugesReg.pas`, зависимость — `LCL`).

### Установка пакета

1. В Lazarus: **Пакет → Открыть файл пакета (.lpk)…** → выбрать `GaugesPkg.lpk`.
2. Нажать **Компилировать**, затем **Использовать → Установить**.
3. Согласиться на пересборку IDE и перезапустить Lazarus.

Если автоматическая установка не сработала:

- **Пакет → Установить/Удалить пакеты…** → найти `GaugesPkg` в списке доступных
  → **Установить выделенное** → **Сохранить и пересобрать IDE**.
- Если пакет не найден, вручную указать путь к `GaugesPkg.lpk`.

После установки `TGauge` появляется на вкладке палитры **Samples**, а форма
`Unit1.lfm` открывается без ошибки.

### Проверка

- Открыть `uopilot.lpi` — форма `Unit1.lfm` должна открыться без диалога об
  ошибке `TGauge`.
- `gScript` (полоса прогресса на вкладке «Скрипт») отображается на дизайнере.
- Сборка основного проекта не меняется: `GaugesReg.pas` и `GaugesPkg.lpk` нужны
  только среде, в `.lpi` они не добавляются.


## TColorDialog.Options и cdFullOpen

Свойство `TColorDialog.Options` и константа `cdFullOpen` существуют в Delphi
(VCL), но в LCL добавлены только начиная с версии 4.0. В Lazarus 2.0.12
(используемом в проекте) у `TColorDialog` есть лишь `Title`, `Color`,
`CustomColors`, поэтому строки `Options := [cdFullOpen];` в `AttriFont.pas`
обёрнуты в `{$IFNDEF FPC}` — полный диалог с дополнительными цветами в LCL
открывается всегда, отдельная опция не требуется.


## Цветные вкладки скриптов (TTabControl) — оверлей поверх NoteBook

В Delphi вкладки `tScript`/`tScriptDesc` рисуются вручную: `OwnerDraw := True`,
событие `OnDrawTab` и `Control.Canvas`. В LCL этот механизм отсутствует:

- события `OnDrawTab` нет (в `comctrls.pp` оно закомментировано и исключено
  из стриминга через `RegisterPropertyToSkip`);
- `OwnerDraw` ничего не делает (стиль `TCS_OWNERDRAWFIXED` LCL не выставляет);
- `TTabControl.TabRect` возвращает нулевой прямоугольник (для `TTabControl`
  Win32-виджет `GetTabRect` явно отдаёт `(0,0,0,0)`);
- вкладки рисует дочерний нативный `SysTabControl32` (внутренний `NoteBook`),
  поэтому рисовать на `GetDC(tScript.Handle)` бессмысленно — вкладки окажутся
  под дочерним окном.

Решение — **пассивный оверлей поверх внутреннего `NoteBook`** в том же
`TFixedTabControl` (юнит `FixedTabControl.pas`):

1. В `CreateWnd`/`DestroyWnd` подклассируется `NoteBook` (тип
   `TTabControlNoteBookStrings(Tabs).NoteBook` — нативный `TPageControl`):
   его `WindowProc` перехватывается, штатный вызов сохраняется.
2. Перехватывается `LM_PAINT` дочернего `NoteBook` (в LCL `WM_PAINT` нативного
   окна превращается в `LM_PAINT`, значение совпадает с `WM_PAINT` = `$000F`).
   После штатной отрисовки `SysTabControl32` (через `FNoteBookOldProc`) оверлей
   дорисовывается на **том же paint DC**, что и нативный контрол — его берём из
   сообщения (`TLMPaint(Msg).DC`), а не через `GetDC`. Рисование через
   `GetDC(NoteBook.Handle)` на экран не попадает (поверхность рисует только
   paint DC из `BeginPaint`). Цветной текст, красный квадрат «не сохранено» и
   блоки «пуск/стоп» рисуются в координатах `NoteBook.TabRect` (LCL-координаты
   клиентской области, совпадают с paint DC). Мышь оверлей не перехватывает —
   клики по вкладкам работают как раньше.
3. Рабочий прямоугольник вкладки берётся из `NoteBook.TabRect` (тот является
   `TPageControl`, а не `TTabControl`, поэтому Win32-виджет шлёт
   `TCM_GETITEMRECT`). Невиртуальное сокрытие `TFixedTabControl.TabRect`
   возвращает `NoteBook.TabRect` (координаты клиентской области `NoteBook`) —
   это неидентичная система координат с `tScript` (мышь в `tScriptMouseUp`
   приходит в координатах `tScript`), поэтому hit-test по блокам
   «пуск/стоп» требует дополнительной поправки на смещение клиентской области.
4. Гейт включения — штатный `OwnerDraw` (выставляется в
   `miShowRuningScriptClick`), как в Delphi. Событие `OnDrawTab` публикуется
   в `TFixedTabControl` и присваивается в коде (`tScriptDrawTabFPC`), чтобы не
   трогать `.lfm`.

Общее тело отрисовки вынесено в `TfmSecond.DrawScriptTabBody`; Delphi-ветка
(`{$IFnDEF FPC}`) продолжает использовать прежний `tScriptDrawTab` с
`Control.Canvas` и `TabRect`, а FPC-ветка рисует по прямоугольнику из
`NoteBook.TabRect` (единый источник прямоугольников для отрисовки).

Ограничение: решение win32-специфично (подкласс `LM_PAINT`, paint DC,
`TCM_GETITEMRECT`) — допустимо для target i386-win32. Оверлей рисует поверх
нативного контрола, поэтому 3D-рамки вкладок остаются нативными; точный
«плоский» вид Delphi не воспроизводится (это отдельная задача).


## Чёрная заливка области вкладок TTabControl

В Delphi `TTabControl` — нативный `SysTabControl32`, заливающий область под
вкладками цветом `COLOR_3DFACE`/`COLOR_BTNFACE` (светло-серый). В Lazarus
`TTabControl` — составной контрол: вкладки рисует внутренний `NoteBook`, а
область под вкладками («pane») LCL рисует сам через `ThemeServices` (`ttPane`).
Когда приложение работает **без визуальных стилей Windows** (в проекте нет
comctl32 v6-манифеста), `ThemeServices.ThemesEnabled = False` и срабатывает
fallback из `D:\Lazarus\lcl\themes.pas:2213`:

```pascal
teTab:
  begin
    if Details.Part in [TABP_PANE, TABP_BODY] then
      FillWithColor(ARect, clBackground);   // <-- БАГ
  end;
```

`clBackground` — это системный `COLOR_BACKGROUND` (цвет рабочего стола, на
машине пользователя чёрный), поэтому фон `tScript`/`tScriptDesc` вокруг
`Panel4` и под строкой вкладок был чёрным.

### Решение: локальный подкласс `TFixedTabControl`

Создан юнит `FixedTabControl.pas` с классом `TFixedTabControl = class(TTabControl)`,
переопределяющим `PaintWindow(DC)`:

1. `inherited PaintWindow(DC)` — штатная отрисовка (включая чёрный pane);
2. `AdjustDisplayRectWithBorder(ARect)` — display area с учётом `TabPosition`
   (работает и для `tpTop`, и для `tpBottom`);
3. `Windows.FillRect(DC, ARect, GetSysColorBrush(COLOR_BTNFACE))` — перезаливка
   display area светло-серым системным цветом (как в Delphi).

Класс регистрируется через `RegisterClass(TFixedTabControl)` в `initialization`
(иначе стример lfm не найдёт класс при `Application.CreateForm`). Тип
`tScript`/`tScriptDesc` заменён на `TFixedTabControl` в `Unit1.pas` и `Unit1.lfm`,
юнит подключён в `uopilot.dpr` и `uopilot.lpi`.

### Регистрация в IDE (пакет FixedTabControlPkg)

`RegisterClass(TFixedTabControl)` в `FixedTabControl.pas` работает только в
скомпилированном приложении — среда Lazarus ищет классы компонентов в
собственном реестре, который строится из установленных пакетов (аналогично
`TGauge`). Поэтому при открытии `Unit1.lfm` без установленного пакета среда
выдаёт ошибку «Невозможно найти класс компонента TFixedTabControl».

В проект добавлен design-time пакет `FixedTabControlPkg.lpk` (юниты
`FixedTabControl.pas` + `FixedTabControlReg.pas`, зависимость — `LCL`),
регистрирующий `TFixedTabControl` на вкладке **Samples** через
`RegisterComponents`.

Установка — как для `GaugesPkg`:

1. **Пакет → Открыть файл пакета (.lpk)…** → `FixedTabControlPkg.lpk`.
2. **Компилировать**, затем **Использовать → Установить**.
3. Пересобрать и перезапустить Lazarus.

После установки `TFixedTabControl` появляется на вкладке **Samples**, а
`Unit1.lfm` открывается без ошибки.

### Альтернативные варианты (запасные, не применяются)

- **Правка LCL `themes.pas`** — заменить `clBackground` на `clBtnFace` в
  `D:\Lazarus\lcl\themes.pas:2213` и пересобрать LCL/IDE. Чинит все
  `TTabControl` разом, но глобально меняет поведение и требует пересборки
  Lazarus.
- **Включить визуальные стили** — добавить в проект comctl32 v6-манифест
  (`Application` → «Use manifest» / `XPManifest`). Тогда `TABP_PANE` рисуется
  корректно, но меняется внешний вид всех контролов (темы), что для
  классического Delphi-7-интерфейса нежелательно.


## Application.OnMessage отсутствует в LCL

В Delphi VCL глобальный `Application` (`Forms.TApplication`) имеет событие
`OnMessage`, которое вызывается из цикла сообщений (`ProcessMessages`) для
каждого сообщения из очереди до его диспетчеризации. В LCL такого события нет
(у `TApplication` есть только `OnMessageDialogFinished`).

В `uScanThread.pas` через `Application.OnMessage` подключался обработчик
`TfmSecond.AppMessage` для перехвата кастомного сообщения `$4B` (остановка
воспроизведения макроса при нажатии клавиши прерывания) на время
`TheRecorder.DoPlay` / `ProcessMessages`.

Решение: присваивания `Application.OnMessage := ...` и `:= nil` обёрнуты в
`{$IFnDEF FPC}` — под Delphi механизм сохраняется, под FPC пропускается.

Связанный случай — `Application.HookMainWindow` в `HotKeyMgr.pas`. Отличие:
`HookMainWindow` работает на стадии диспетчеризации (WindowProc главного окна)
и видит только сообщения, адресованные главному окну, поэтому он заменён
скрытым окном `LCLIntf.AllocateHWnd`. `OnMessage` работает на стадии извлечения
из очереди и видит все сообщения потока независимо от получателя, поэтому
скрытым окном не заменяется.

Примечание: сообщение `$4B` нигде в исходниках не отправляется
(нет `PostMessage`/`SendMessage` с таким номером), поэтому отключение
`OnMessage` под FPC ничего не ломает.


## Кириллица в редакторе скрипта отображается как «????»

Локальный SynEdit (`synedit/SynEdit.pas`, `SynMemo.pas`, `SynEditTypes.pas`) — это
однобайтовый порт SynEdit 2.0.3, заточенный под cp1251: `TSynSpecialChars =
[#$A8, #$B8, #$C0..#$FF]` (SynEditTypes.pas:50), `Font.Charset = RUSSIAN_CHARSET`
(Unit1.pas:3950), файлы скриптов читаются/пишутся в cp1251 (LangClipboard.pas).
Приложение собирается в UTF-8 LCL (без `-dDisableUTF8RTL`), поэтому ввод клавиатуры
доставляется как UTF-8 через виртуальный метод `TWinControl.UTF8KeyPress`
(`win32callback.inc` `HandleUnicodeChar` → `DoUTF8KeyPress`).

`TCustomSynEdit` переопределяет только однобайтовый `KeyPress(var Key: Char)`
(SynEdit.pas:671, :2244), а `UTF8KeyPress` — нет. Для не-ASCII символа LCL уходит
в fallback-ветку `CN_CHAR` (`win32callback.inc:1243` `CharCode :=
Word(Char(WideChar(WParam)))`), где Unicode-код сужается до одного байта, не
совпадающего с cp1251, — кириллица искажалась и выводилась как «?».

Решение: в `TCustomSynEdit` под `{$IFDEF FPC}` добавлено переопределение
`UTF8KeyPress(var UTF8Key: TUTF8Char)` — символ UTF-8 перекодируется в cp1251 через
`UTF8Decode` + `WideCharToMultiByte(1251, ...)` и вставляется штатным `KeyPress`
(undo/redo и подсветка сохраняются); `UTF8Key := ''` помечает символ обработанным и
отключает fallback-ветку, исключая двойную вставку. Delphi-ветка не затрагивается
(обёрнута в `{$IFDEF FPC}`).


## Окно поиска/замены (TFindDialog) — английские подписи и позиция

При переходе Delphi→Lazarus стандартное окно поиска текста (`fhFindDialog:
TFindDialog` и `fhReplaceDialog: TReplaceDialog`, `Unit1.pas:724-725`, LFM
`Unit1.lfm:10955-10964`) стало англоязычным и открывается на сохранённой
дизайн-тайм позиции (левый верхний угол), а не по центру. Причина не в SynEdit —
окно не связано с `TCustomSynEdit.SearchEngine`, а обслуживается компонентами
`Dialogs` (`TFindDialog`/`TReplaceDialog`), у которых в Delphi и Lazarus два
разных back-end'а:

1. **Язык.** В Delphi 7 `TFindDialog` — нативный системный диалог Windows
   `FindText`, который русская ОС локализует автоматически. В Lazarus LCL рисует
   собственную форму `TFindDialogForm`
   (`D:\Lazarus\lcl\include\finddialog.inc`), все подписи которой задаются
   английскими resourcestrings LCL в `TFindDialog.CreateForm`
   (`finddialog.inc:508-523`): `rsFind`, `rsText`, `rsDirection`, `rsForward`,
   `rsBackward`, `rsWholeWordsOnly`, `rsCaseSensitive`, `rsEntireScope`,
   `rsMbCancel`, `rsHelp` (`D:\Lazarus\lcl\lclstrconsts.pas:29`, `:59`, `:72`,
   `:76`, `:332-339`). Перевести их можно только механизмом i18n LCL
   (`.po`/`.mo`), которого в проекте нет: своя локализация
   `TfmSecond.ApplyLanguage` (`Unit1.pas:11798`) работает через `LoadStr` и о
   LCL-диалоге не знает.

2. **Позиция.** В LFM сохранены неотрицательные `Left = 208; Top = 328`
   (`Unit1.lfm:10957-10958`). `TFindDialog.CalcPosition`
   (`finddialog.inc:585-599`) центрирует форму только при `(FFormLeft < 0) and
   (FFormTop < 0)`, поэтому с сохранёнными координатами диалог ставится на
   дизайн-тайм позицию (левый верхний угол) вместо центра. Delphi центрировал
   диалог средствами системы.

3. **Почему не подключить `DefaultTranslator`/i18n LCL.** Хук `LRSTranslator`
   съедает кириллические подписи из LFM (меню, вкладки и пр. становятся пустыми)
   — см. `MENU_RESEARCH_2.md`. Поэтому собственные LCL-переводы в проекте
   отсутствуют намеренно.

Обработчик поиска/замены не затрагивается: `ScriptFindDialogFind`
(`Unit1.pas:12800`) работает через публичные `FindText`/`Options` и
`Sender is TReplaceDialog`/`TFindDialog`, поэтому любое будущее исправление
оформления диалога на логику не влияет.

### Варианты исправления (не реализованы)

- **Подкласс `TFindDialog`/`TReplaceDialog`** с переопределением `CreateForm`:
  после `inherited` переписать подписи на русские и выставить
  `Position := poScreenCenter`. Точка переопределения готова — `CreateForm`
  виртуален (`D:\Lazarus\lcl\dialogs.pp:452`) и сам подставляет LCL
  resourcestrings.
- **Собственная русская форма поиска/замены** вместо `TFindDialog`.