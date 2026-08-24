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


## Цветные вкладки скриптов (TTabControl) не работают в LCL

В Delphi вкладки `tScript`/`tScriptDesc` рисуются вручную: `OwnerDraw := True`,
событие `OnDrawTab` и `Control.Canvas`. В LCL этот механизм отсутствует:

- у `TCustomTabControl` нет свойства `Canvas`;
- события `OnDrawTab` нет (в `comctrls.pp` оно закомментировано и исключено
  из стриминга через `RegisterPropertyToSkip`);
- `OwnerDraw` ничего не делает (стиль `TCS_OWNERDRAWFIXED` LCL не выставляет);
- `TTabControl.TabRect` возвращает нулевой прямоугольник;
- вкладки рисует дочерний нативный `SysTabControl32` (внутренний `NoteBook`),
  поэтому рисовать на `GetDC(tScript.Handle)` бессмысленно — вкладки окажутся
  под дочерним окном.

Поэтому процедура `TfmSecond.tScriptDrawTab` под `{$IFDEF FPC}` выключена
(no-op), и вкладки под Lazarus отображаются стандартно, без индикации
состояния скрипта (цвет, «не сохранено», кнопки пуск/стоп). Для восстановления
фичи нужен кастомный таб-контрол (ATTabs или собственный `TCustomControl`),
рисующий вкладки на своём `Canvas`.


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