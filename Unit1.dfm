object fmSecond: TfmSecond
  Left = 238
  Top = 126
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  AutoScroll = False
  Caption = '.........'
  ClientHeight = 767
  ClientWidth = 1419
  Color = clBtnFace
  Constraints.MaxHeight = 1500
  Constraints.MaxWidth = 1812
  Constraints.MinHeight = 343
  Constraints.MinWidth = 241
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Microsoft Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = mnHotKey
  OldCreateOrder = True
  Position = poScreenCenter
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Label14: TLabel
    Left = 280
    Top = 0
    Width = 41
    Height = 13
    Caption = '288x232'
    Visible = False
  end
  object sbCalibrate: TSpeedButton
    Left = 220
    Top = 365
    Width = 57
    Height = 20
    Caption = 'Calibrate'
    Enabled = False
    Visible = False
    OnClick = sbCalibrateClick
  end
  object Image1: TImage
    Left = 232
    Top = 304
    Width = 25
    Height = 17
  end
  object gbAnimalControl: TGroupBox
    Left = 768
    Top = -2
    Width = 225
    Height = 195
    Caption = 'Управление животными и вендорами'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    Visible = False
    object sbCome: TSpeedButton
      Tag = 1
      Left = 8
      Top = 17
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'come'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbGo: TSpeedButton
      Tag = 4
      Left = 80
      Top = 17
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'go'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbStay: TSpeedButton
      Tag = 5
      Left = 8
      Top = 41
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'stay'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbStop: TSpeedButton
      Tag = 7
      Left = 80
      Top = 41
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'stop'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbFollow: TSpeedButton
      Tag = 6
      Left = 152
      Top = 17
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'follow'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbGuard: TSpeedButton
      Tag = 2
      Left = 152
      Top = 41
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'guard'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbAttack: TSpeedButton
      Tag = 3
      Left = 152
      Top = 65
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'attack'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbKill: TSpeedButton
      Tag = 3
      Left = 152
      Top = 89
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'kill'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbTransfer: TSpeedButton
      Tag = 3
      Left = 8
      Top = 65
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'transfer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbRelease: TSpeedButton
      Tag = 3
      Left = 80
      Top = 65
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'release'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbBuy: TSpeedButton
      Tag = 3
      Left = 8
      Top = 118
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'buy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbSell: TSpeedButton
      Tag = 3
      Left = 8
      Top = 142
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'sell'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbStock: TSpeedButton
      Tag = 3
      Left = 152
      Top = 118
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'stock'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbPrice: TSpeedButton
      Tag = 3
      Left = 152
      Top = 142
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'price'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbStatus: TSpeedButton
      Tag = 3
      Left = 152
      Top = 166
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'status'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbDrop: TSpeedButton
      Tag = 3
      Left = 8
      Top = 89
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'drop'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbGive: TSpeedButton
      Tag = 3
      Left = 80
      Top = 89
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'give'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object Bevel9: TBevel
      Left = 0
      Top = 112
      Width = 223
      Height = 10
      Shape = bsTopLine
    end
    object sbHire: TSpeedButton
      Tag = 3
      Left = 80
      Top = 142
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'hire'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object sbBye: TSpeedButton
      Tag = 3
      Left = 80
      Top = 118
      Width = 65
      Height = 20
      AllowAllUp = True
      Caption = 'bye'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      OnClick = sbStayClick
    end
    object cbPref: TCheckBox
      Left = 8
      Top = 168
      Width = 13
      Height = 17
      Hint = 'Добавлять префикс'
      Caption = 'cbPref'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 0
    end
    object cbSuff: TCheckBox
      Left = 80
      Top = 168
      Width = 13
      Height = 17
      Hint = 'Добавлять суффикс'
      Caption = 'cbSuff'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object ePref: TEdit
      Left = 24
      Top = 166
      Width = 49
      Height = 21
      Hint = 'Префикс (имя животного или all)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = 'all'
    end
    object eSuff: TEdit
      Left = 96
      Top = 166
      Width = 49
      Height = 21
      Hint = 'Суффикс (обычно цель)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
  end
  object pcHelp: TPageControl
    Left = 8
    Top = 680
    Width = 473
    Height = 57
    ActivePage = tsWiki
    TabOrder = 20
    TabStop = False
    Visible = False
    OnChange = pcHelpChange
    object tsWiki: TTabSheet
      Caption = 'Wiki'
      ImageIndex = 1
      object Panel13: TPanel
        Left = 0
        Top = 0
        Width = 465
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object spUnpackWiki: TSpeedButton
          Left = 200
          Top = 8
          Width = 161
          Height = 22
          Caption = 'Распаковать старую версию'
          Visible = False
          OnClick = spUnpackWikiClick
        end
        object sbWikiBack: TSpeedButton
          Left = 8
          Top = 0
          Width = 23
          Height = 22
          Caption = 'п'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -17
          Font.Name = 'Wingdings'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = sbWikiBackClick
        end
        object sbWikiForward: TSpeedButton
          Left = 40
          Top = 0
          Width = 23
          Height = 22
          Caption = 'р'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -17
          Font.Name = 'Wingdings'
          Font.Style = [fsBold]
          ParentFont = False
          OnClick = sbWikiForwardClick
        end
        object sbDownloadWiki: TSpeedButton
          Left = 232
          Top = 0
          Width = 137
          Height = 21
          AllowAllUp = True
          GroupIndex = 1
          Caption = 'Перекачать всё с Wiki'
          OnClick = sbDownloadWikiClick
        end
        object pbWiki: TProgressBar
          Left = 232
          Top = 18
          Width = 137
          Height = 8
          Max = 408
          Position = 100
          Smooth = True
          Step = 1
          TabOrder = 1
          Visible = False
        end
        object cbWikiList: TComboBox
          Left = 80
          Top = 0
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          Sorted = True
          TabOrder = 0
          OnChange = cbWikiListChange
        end
      end
    end
    object tsHistory: TTabSheet
      Caption = 'История развития'
    end
  end
  object pMakrosPanel: TPanel
    Left = 0
    Top = 410
    Width = 737
    Height = 22
    BevelOuter = bvNone
    TabOrder = 0
    Visible = False
    object ToolBar1: TToolBar
      Left = 0
      Top = 0
      Width = 737
      Height = 22
      Align = alClient
      Anchors = []
      ButtonHeight = 21
      ButtonWidth = 67
      Caption = 'ToolBar1'
      Color = clBtnFace
      Customizable = True
      EdgeBorders = []
      EdgeInner = esNone
      EdgeOuter = esNone
      ParentColor = False
      ShowCaptions = True
      TabOrder = 0
      Wrapable = False
      OnMouseMove = ToolBar1MouseMove
      object tb1: TToolButton
        Left = 0
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 4
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb2: TToolButton
        Left = 67
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 7
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb3: TToolButton
        Left = 134
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 9
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb4: TToolButton
        Left = 201
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 5
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb5: TToolButton
        Left = 268
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 0
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb6: TToolButton
        Left = 335
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 1
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb7: TToolButton
        Left = 402
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 2
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb8: TToolButton
        Left = 469
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 10
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb9: TToolButton
        Left = 536
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 11
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb10: TToolButton
        Left = 603
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 6
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb11: TToolButton
        Left = 670
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 3
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb12: TToolButton
        Left = 737
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 4
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb15: TToolButton
        Left = 804
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 5
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb16: TToolButton
        Left = 871
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 6
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb17: TToolButton
        Left = 938
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 7
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb18: TToolButton
        Left = 1005
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 8
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb19: TToolButton
        Left = 1072
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 9
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb20: TToolButton
        Left = 1139
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 10
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb21: TToolButton
        Left = 1206
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 11
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb22: TToolButton
        Left = 1273
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 12
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb13: TToolButton
        Left = 1340
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 13
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object tb14: TToolButton
        Left = 1407
        Top = 2
        AllowAllUp = True
        Caption = '-'
        ImageIndex = 14
        OnClick = tb1Click
        OnMouseDown = tb1MouseDown
        OnMouseMove = ToolBar1MouseMove
      end
      object ToolButton1: TToolButton
        Left = 1474
        Top = 2
        Caption = '          -         '
        ImageIndex = 15
      end
    end
  end
  object pcAll: TPageControl
    Left = 0
    Top = 0
    Width = 265
    Height = 289
    ActivePage = tsScript
    Constraints.MaxHeight = 289
    Constraints.MinHeight = 289
    Constraints.MinWidth = 233
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = pcAllChange
    OnChanging = pcAllChanging
    object tsGeneral: TTabSheet
      Caption = 'Общее'
      object gbC: TGroupBox
        Left = 0
        Top = 0
        Width = 225
        Height = 129
        Caption = 'Наведите курсор на цель и нажм. (Ctrl+A)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object btS1: TSpeedButton
          Tag = 1
          Left = 176
          Top = 48
          Width = 41
          Height = 25
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Старт'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btCStartClick
        end
        object btS2: TSpeedButton
          Tag = 2
          Left = 176
          Top = 72
          Width = 41
          Height = 25
          AllowAllUp = True
          GroupIndex = 3
          Caption = 'Старт'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btCStartClick
        end
        object btS3: TSpeedButton
          Tag = 3
          Left = 176
          Top = 96
          Width = 41
          Height = 25
          AllowAllUp = True
          GroupIndex = 4
          Caption = 'Старт'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btCStartClick
        end
        object btS0: TSpeedButton
          Left = 158
          Top = 16
          Width = 59
          Height = 25
          Hint = 'Координаты, куда кликать'
          AllowAllUp = True
          GroupIndex = 1
          Caption = '0, 0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btCStartClick
        end
        object ed0: TEdit
          Left = 88
          Top = 18
          Width = 39
          Height = 21
          Hint = 'Интервал'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          Text = '5000'
          OnEnter = ed1Enter
        end
        object ed1: TEdit
          Left = 88
          Top = 48
          Width = 39
          Height = 21
          Hint = 'Интервал'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          Text = '5000'
          OnEnter = ed1Enter
        end
        object ed2: TEdit
          Left = 88
          Top = 72
          Width = 39
          Height = 21
          Hint = 'Интервал'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          Text = '1200'
          OnEnter = ed1Enter
        end
        object ed3: TEdit
          Left = 88
          Top = 96
          Width = 39
          Height = 21
          Hint = 'Интервал'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 9
          Text = '900'
          OnEnter = ed1Enter
        end
        object cb1: TComboBox
          Left = 8
          Top = 48
          Width = 81
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 0
          ParentFont = False
          TabOrder = 2
        end
        object cb2: TComboBox
          Left = 8
          Top = 72
          Width = 81
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 0
          ParentFont = False
          TabOrder = 5
        end
        object cb3: TComboBox
          Left = 8
          Top = 96
          Width = 81
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 0
          ParentFont = False
          TabOrder = 8
        end
        object cb0: TComboBox
          Left = 8
          Top = 18
          Width = 81
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          TabOrder = 0
          Items.Strings = (
            'Двойной левой'
            'Двойной правой'
            'Клик левой'
            'Клик правой')
        end
        object cbS1: TCheckBox
          Left = 158
          Top = 52
          Width = 15
          Height = 17
          Hint = 'Посылать BackSpace после посылки буквенно-цифровой клавиши'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object cbS2: TCheckBox
          Left = 158
          Top = 76
          Width = 15
          Height = 17
          Hint = 'Посылать BackSpace после посылки буквенно-цифровой клавиши'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
        end
        object cbS3: TCheckBox
          Left = 158
          Top = 100
          Width = 15
          Height = 17
          Hint = 'Посылать BackSpace после посылки буквенно-цифровой клавиши'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 10
        end
        object ec0: TEdit
          Left = 130
          Top = 18
          Width = 24
          Height = 21
          Hint = 'Количество повторений'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 11
          Text = '-1'
        end
        object ec1: TEdit
          Tag = 1
          Left = 130
          Top = 48
          Width = 24
          Height = 21
          Hint = 'Количество повторений'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 12
          Text = '-1'
        end
        object ec2: TEdit
          Tag = 2
          Left = 130
          Top = 72
          Width = 24
          Height = 21
          Hint = 'Количество повторений'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 13
          Text = '-1'
        end
        object ec3: TEdit
          Tag = 3
          Left = 130
          Top = 96
          Width = 24
          Height = 21
          Hint = 'Количество повторений'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 14
          Text = '-1'
        end
      end
      object gbOtherWindow: TGroupBox
        Left = 0
        Top = 136
        Width = 225
        Height = 73
        Caption = 'Второе окно (Ctrl+B)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        object btS4: TSpeedButton
          Tag = 4
          Left = 176
          Top = 16
          Width = 41
          Height = 25
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Старт'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btCStartClick
        end
        object btS5: TSpeedButton
          Tag = 5
          Left = 176
          Top = 40
          Width = 41
          Height = 25
          AllowAllUp = True
          GroupIndex = 3
          Caption = 'Старт'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btCStartClick
        end
        object ed4: TEdit
          Left = 88
          Top = 16
          Width = 39
          Height = 21
          Hint = 'Интервал'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          Text = '5000'
          OnEnter = ed1Enter
        end
        object ed5: TEdit
          Left = 88
          Top = 40
          Width = 39
          Height = 21
          Hint = 'Интервал'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          Text = '1200'
          OnEnter = ed1Enter
        end
        object cb4: TComboBox
          Left = 8
          Top = 16
          Width = 81
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 0
          ParentFont = False
          TabOrder = 0
        end
        object cb5: TComboBox
          Left = 8
          Top = 40
          Width = 81
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 0
          ParentFont = False
          TabOrder = 3
        end
        object cbS4: TCheckBox
          Left = 158
          Top = 20
          Width = 15
          Height = 17
          Hint = 'Посылать BackSpace после посылки буквенно-цифровой клавиши'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object cbS5: TCheckBox
          Left = 158
          Top = 44
          Width = 15
          Height = 17
          Hint = 'Посылать BackSpace после посылки буквенно-цифровой клавиши'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object ec4: TEdit
          Tag = 4
          Left = 130
          Top = 16
          Width = 24
          Height = 21
          Hint = 'Количество повторений'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          Text = '-1'
        end
        object ec5: TEdit
          Tag = 5
          Left = 130
          Top = 40
          Width = 24
          Height = 21
          Hint = 'Количество повторений'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
          Text = '-1'
        end
      end
      object gbScreenShot: TGroupBox
        Left = 0
        Top = 216
        Width = 225
        Height = 41
        Caption = 'Скриншот (PrintScreen) :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object cbDate: TCheckBox
          Left = 7
          Top = 19
          Width = 42
          Height = 14
          Hint = 'В имя файла добавить дату и время'
          Caption = 'дата'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object rbBmp: TRadioButton
          Left = 51
          Top = 19
          Width = 41
          Height = 14
          Hint = 'Занимает много места на диске, зато качественно'
          Caption = 'bmp'
          Checked = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          TabStop = True
        end
        object rbJpg: TRadioButton
          Left = 90
          Top = 19
          Width = 41
          Height = 14
          Hint = 'Не качественно, зато занимает мало места на диске'
          Caption = 'jpg'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object edScr: TEdit
          Left = 164
          Top = 12
          Width = 55
          Height = 21
          Hint = 'Куда сохранять файлы'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          Text = 'C:\'
          OnExit = edScrExit
        end
        object SpinEdit1: TSpinEdit
          Left = 126
          Top = 12
          Width = 35
          Height = 22
          Hint = 'Качество jpg'
          AutoSelect = False
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxLength = 2
          MaxValue = 100
          MinValue = 1
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          Value = 75
        end
      end
    end
    object tsScript: TTabSheet
      Caption = 'Скрипт'
      object gScript: TGauge
        Left = 0
        Top = 204
        Width = 257
        Height = 4
        Align = alBottom
        MaxValue = 0
        Progress = 0
        ShowText = False
      end
      object PanelTs: TPanel
        Left = 0
        Top = 209
        Width = 257
        Height = 52
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 4
        object tScript: TTabControl
          Left = 0
          Top = 0
          Width = 257
          Height = 52
          Align = alBottom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          PopupMenu = mnTab
          ShowHint = False
          TabHeight = 22
          TabOrder = 0
          Tabs.Strings = (
            '0')
          TabIndex = 0
          TabWidth = 23
          OnChange = tScriptChange
          OnChanging = tScriptChanging
          OnDrawTab = tScriptDrawTab
          OnMouseMove = tScriptMouseMove
          OnMouseUp = tScriptMouseUp
          object Panel4: TPanel
            Left = 2
            Top = 26
            Width = 215
            Height = 24
            BevelOuter = bvNone
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            ParentShowHint = False
            ShowHint = False
            TabOrder = 0
            object lHint: TLabel
              Left = 98
              Top = 9
              Width = 13
              Height = 13
              Caption = 'ms'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Microsoft Sans Serif'
              Font.Style = []
              ParentFont = False
            end
            object sbPause: TSpeedButton
              Left = 135
              Top = 2
              Width = 38
              Height = 20
              AllowAllUp = True
              GroupIndex = 2
              Enabled = False
              Glyph.Data = {
                F6010000424DF601000000000000760000002800000030000000100000000100
                0400000000008001000000000000000000001000000000000000000000000000
                80000080000000808000800000008000800080800000C0C0C000808080000000
                FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
                33333333333333333333333333333333333300000000000000000000000033FF
                FFFFFFFFFFFFFFFFFFF30F000000000000000000000038888888888888888888
                88F30FF88888888888888888880038F7777777777777777778F30FF777777777
                77777777780038F7777777777777777778F30FF77777777777777777780038F7
                777777FF77FF777778F30FF77777700770077777780038F77777788F788F7777
                78F30FF77777700770077777780038F77777788F788F777778F30FF777777007
                70077777780038F77777788F788F777778F30FF77777700770077777780038F7
                7777788F788F777778F30FF77777700770077777780038F77777788778877777
                78F30FF77777777777777777780038F7777777777777777778F30FF777777777
                77777777780038F7777777777777777778F30FFFFFFFFFFFFFFFFFFFFF0038FF
                FFFFFFFFFFFFFFFFF8F30FFFFFFFFFFFFFFFFFFFFFF038888888888888888888
                8833000000000000000000000000333333333333333333333333}
              NumGlyphs = 2
              ParentShowHint = False
              ShowHint = True
              Transparent = False
              OnClick = sbPauseClick
            end
            object btStart: TSpeedButton
              Left = 175
              Top = 2
              Width = 40
              Height = 20
              AllowAllUp = True
              GroupIndex = 1
              Glyph.Data = {
                76030000424D7603000000000000760000002800000060000000100000000100
                0400000000000003000000000000000000001000000000000000000000000000
                80000080000000808000800000008000800080800000C0C0C000808080000000
                FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
                3333333333333333333333333333333333333333333333333333333333333333
                3333333333333333333300000000000000000000000333FFFFFFFFFFFFFFFFFF
                FFF333FFFFFFFFFFFFFFFFFFFFF30000000000000000000000030F0000000000
                0000000000033888888888888888888888F33888888888888888888888F30F00
                000000000000000000030FF88888888888888888800338F77777777777777777
                78F338F7777777777777777778F30FF8888888888888888880030FF777777F77
                77777777800338F7777777777777777778F338F777777F777777777778F30FF7
                777777777777777780030FF777770FFFF7777777800338F77777FFFFFFFFFF77
                78F338F777778FFFF777777778F30FF77777FFFFFFFFF77780030FF777770000
                FFF77777800338F77788888888888F7778F338F777778888FFF7777778F30FF7
                770000000000F77780030FF77777000000FFF777800338F77788888888888F77
                78F338F77777888888FFF77778F30FF7770000000000F77780030FF777770000
                00007777800338F77788888888888F7778F338F7777788888888777778F30FF7
                770000000000F77780030FF77777000000777777800338F77788888888888F77
                78F338F7777788888877777778F30FF7770000000000F77780030FF777770000
                77777777800338F7778888888888877778F338F7777788887777777778F30FF7
                770000000000F77780030FF77777077777777777800338F77788888888888777
                78F338F7777787777777777778F30FF7770000000000777780030FF777777777
                77777777800338F7777777777777777778F338F7777777777777777778F30FF7
                777777777777777780030FFFFFFFFFFFFFFFFFFFF00338FFFFFFFFFFFFFFFFFF
                F8F338FFFFFFFFFFFFFFFFFFF8F30FFFFFFFFFFFFFFFFFFFF0030FFFFFFFFFFF
                FFFFFFFFFF033888888888888888888888333888888888888888888888330FFF
                FFFFFFFFFFFFFFFFFF0300000000000000000000000333333333333333333333
                3333333333333333333333333333000000000000000000000003}
              NumGlyphs = 4
              ParentShowHint = False
              ShowHint = True
              Transparent = False
              OnClick = btStartClick
            end
            object bAdd: TSpeedButton
              Left = 3
              Top = 2
              Width = 20
              Height = 20
              Hint = 'Добавить новый скрипт'
              Caption = '+'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -17
              Font.Name = 'MS Sans Serif'
              Font.Style = [fsBold]
              ParentFont = False
              ParentShowHint = False
              ShowHint = True
              OnClick = bAddClick
            end
            object bRemove: TSpeedButton
              Left = 27
              Top = 2
              Width = 20
              Height = 20
              Hint = 'Удалить текущий скрипт'
              Caption = '-'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -17
              Font.Name = 'MS Sans Serif'
              Font.Style = [fsBold]
              ParentFont = False
              ParentShowHint = False
              ShowHint = True
              OnClick = bRemoveClick
            end
            object edPause: TEdit
              Left = 54
              Top = 4
              Width = 41
              Height = 18
              Hint = 'Пауза между строками в миллисекундах'
              AutoSize = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Microsoft Sans Serif'
              Font.Style = []
              ParentFont = False
              ParentShowHint = False
              ShowHint = True
              TabOrder = 0
            end
            object cbDebug: TCheckBox
              Left = 118
              Top = 5
              Width = 15
              Height = 17
              Hint = 'Пошаговое выполнение скрипта'
              ParentShowHint = False
              ShowHint = True
              TabOrder = 1
              OnClick = cbDebugClick
            end
            object CheckBox1: TCheckBox
              Left = 48
              Top = 0
              Width = 17
              Height = 17
              Caption = 'CheckBox1'
              Checked = True
              State = cbChecked
              TabOrder = 2
              Visible = False
              OnClick = CheckBox1Click
            end
          end
        end
        object tScriptDesc: TTabControl
          Tag = 1
          Left = 104
          Top = 0
          Width = 73
          Height = 26
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          MultiLine = True
          ParentFont = False
          ParentShowHint = False
          ScrollOpposite = True
          ShowHint = False
          TabHeight = 22
          TabOrder = 1
          TabPosition = tpBottom
          Tabs.Strings = (
            '-')
          TabIndex = 0
          Visible = False
          OnChange = tScriptDescChange
          OnDrawTab = tScriptDrawTab
          OnMouseMove = tScriptDescMouseMove
          OnMouseUp = tScriptMouseUp
        end
        object pRestWait: TPanel
          Left = 88
          Top = 16
          Width = 8
          Height = 17
          AutoSize = True
          BevelInner = bvRaised
          BevelOuter = bvLowered
          BiDiMode = bdLeftToRight
          Color = clCream
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBtnText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentBiDiMode = False
          ParentFont = False
          TabOrder = 2
          Visible = False
          object lRestWait: TLabel
            Left = 2
            Top = 2
            Width = 4
            Height = 13
            Alignment = taRightJustify
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBtnText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
      end
      object Panel11: TPanel
        Left = 0
        Top = 202
        Width = 257
        Height = 2
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
      end
      object Panel12: TPanel
        Left = 0
        Top = 208
        Width = 257
        Height = 1
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
      end
      object pCoordsAndPoints: TPanel
        Left = 0
        Top = 0
        Width = 257
        Height = 61
        Hint = 'Ctrl + A'
        Align = alTop
        BevelOuter = bvNone
        Constraints.MinHeight = 43
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        object Bevel10: TBevel
          Left = 57
          Top = 1
          Width = 116
          Height = 15
        end
        object sbWorkwindowHandle: TSpeedButton
          Left = 0
          Top = 0
          Width = 56
          Height = 17
          Hint = 'Workwindow handle'
          Caption = '000000000'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btAddColClick
        end
        object Label4: TLabel
          Left = 0
          Top = 92
          Width = 70
          Height = 13
          Caption = 'Точка (Ctrl+A):'
        end
        object btXY: TSpeedButton
          Left = 19
          Top = 20
          Width = 49
          Height = 19
          Hint = 'Относительные координаты точки'
          Caption = '0, 0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btAddColClick
        end
        object btXYabs: TSpeedButton
          Left = 73
          Top = 20
          Width = 49
          Height = 19
          Hint = 'Абсолютные координаты точки'
          Caption = '0, 0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btAddColClick
        end
        object btColor: TSpeedButton
          Left = 72
          Top = 41
          Width = 66
          Height = 19
          Hint = 'Цвет точки'
          Caption = '0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btAddColClick
          OnMouseDown = btColorMouseDown
        end
        object btAddM: TSpeedButton
          Left = 210
          Top = 42
          Width = 14
          Height = 17
          Hint = 'Добавить клавишу в скрипт'
          Caption = '6'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -17
          Font.Name = 'Marlett'
          Font.Style = [fsBold]
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = btAddColClick
        end
        object miLogWindow: TSpeedButton
          Left = 177
          Top = 0
          Width = 29
          Height = 17
          Hint = 'On\off log window'
          Caption = 'log'
          ParentShowHint = False
          ShowHint = True
          OnClick = miLogWindowClick
        end
        object sbScriptProcessing: TSpeedButton
          Left = 152
          Top = 21
          Width = 73
          Height = 17
          Hint = 'Отображать ход выполнения скрипта и переменную timer'
          AllowAllUp = True
          GroupIndex = 1
          Caption = 'Слежение'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          OnClick = sbScriptProcessingClick
        end
        object lWinList: TLabel
          Left = 58
          Top = 2
          Width = 114
          Height = 13
          Hint = 'Press ''Shift'' and select window to insert his caption in to script.'
          AutoSize = False
          Color = clWindow
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          OnClick = sbWinListClick
        end
        object SpeedButton3: TSpeedButton
          Left = 224
          Top = 0
          Width = 17
          Height = 17
          Caption = 'F'
          OnClick = SpeedButton3Click
        end
        object Panel14: TPanel
          Left = 59
          Top = 0
          Width = 0
          Height = 17
          BevelOuter = bvNone
          TabOrder = 4
          object cbWinList: TComboBox
            Left = -2
            Top = -2
            Width = 200
            Height = 21
            BevelEdges = []
            BevelInner = bvNone
            Style = csDropDownList
            DropDownCount = 17
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ItemHeight = 13
            ParentFont = False
            TabOrder = 0
            OnChange = cbWinListChange
          end
        end
        object cbInsertXY: TCheckBox
          Tag = 1
          Left = 3
          Top = 21
          Width = 15
          Height = 17
          Hint = 'Сразу вставлять относительные координаты в скрипт'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = cbInsertXYClick
        end
        object cbInsertXYabs: TCheckBox
          Tag = 2
          Left = 125
          Top = 21
          Width = 15
          Height = 17
          Hint = 'Сразу вставлять абсолютные координаты в скрипт'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = cbInsertXYClick
        end
        object cbM: TComboBox
          Left = 141
          Top = 40
          Width = 68
          Height = 21
          Hint = 'Клавиша'
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object CBInsertColor: TCheckBox
          Left = 3
          Top = 42
          Width = 14
          Height = 17
          Hint = 'Сразу определять цвет'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 3
        end
        object Panel28: TPanel
          Left = 20
          Top = 41
          Width = 48
          Height = 19
          BevelOuter = bvNone
          Color = clWhite
          TabOrder = 5
          object Panel29: TPanel
            Left = 24
            Top = 0
            Width = 24
            Height = 19
            BevelOuter = bvNone
            Color = clBlack
            TabOrder = 1
          end
          object pDefineColor: TPanel
            Left = 6
            Top = 3
            Width = 36
            Height = 13
            BevelOuter = bvNone
            TabOrder = 0
            object sbDefineColor: TSpeedButton
              Left = 0
              Top = 0
              Width = 36
              Height = 13
              Hint = 'Определить цвет пикселя в выбранных координатах (Ctrl+B)'
              Caption = '4'
              Flat = True
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = 17
              Font.Name = 'Marlett'
              Font.Style = []
              ParentFont = False
              ParentShowHint = False
              ShowHint = True
              OnClick = miCtrlBClick
            end
          end
        end
        object cbLoggingCommands: TCheckBox
          Tag = 2
          Left = 207
          Top = 0
          Width = 15
          Height = 17
          Hint = 'Logging Commands'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 6
          OnClick = cbLoggingCommandsClick
        end
      end
      object pPos: TPanel
        Left = 184
        Top = 194
        Width = 40
        Height = 12
        Alignment = taRightJustify
        BevelInner = bvLowered
        Caption = '000000'
        Color = clWindow
        Constraints.MaxHeight = 12
        Constraints.MinHeight = 12
        Constraints.MinWidth = 11
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object Panel2: TPanel
        Left = 96
        Top = 104
        Width = 33
        Height = 33
        BevelOuter = bvNone
        TabOrder = 5
        Visible = False
        object Panel1: TImage
          Left = 0
          Top = 0
          Width = 32
          Height = 16
          OnClick = Panel1Click
        end
      end
      object pTabRename: TPanel
        Left = 128
        Top = 170
        Width = 73
        Height = 41
        TabOrder = 6
        Visible = False
        object lTabRename: TLabel
          Left = 5
          Top = 3
          Width = 24
          Height = 13
          Caption = '99 ->'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object bTagRenameOk: TButton
          Left = 40
          Top = 24
          Width = 33
          Height = 17
          Caption = 'Ok'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = bTagRenameOkClick
        end
        object bTagRenameCancel: TButton
          Left = 0
          Top = 24
          Width = 41
          Height = 17
          Caption = 'Cancel'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = bTagRenameCancelClick
        end
        object seTagRename: TSpinEdit
          Left = 34
          Top = 0
          Width = 41
          Height = 22
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxValue = 98
          MinValue = 0
          ParentFont = False
          TabOrder = 2
          Value = 98
        end
      end
    end
    object tsOther: TTabSheet
      Caption = 'Разное'
      ImageIndex = 3
      object GroupBox3: TGroupBox
        Left = 119
        Top = 172
        Width = 104
        Height = 87
        Caption = 'Будильник'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object Lbudilnik: TLabel
          Left = 49
          Top = 15
          Width = 6
          Height = 20
          Caption = ':'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = 20
          Font.Name = 'Small Fonts'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object SBBudilnik: TSpeedButton
          Left = 8
          Top = 44
          Width = 89
          Height = 20
          AllowAllUp = True
          GroupIndex = 1
          Caption = 'On\Off'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          OnClick = SBBudilnikClick
        end
        object SEMinutes: TSpinEdit
          Left = 61
          Top = 17
          Width = 35
          Height = 22
          Hint = 'Минуты'
          EditorEnabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxValue = 60
          MinValue = -1
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          Value = 0
          OnChange = SEMinutesChange
        end
        object SEHour: TSpinEdit
          Left = 9
          Top = 17
          Width = 35
          Height = 22
          Hint = 'Часы'
          EditorEnabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxValue = 24
          MinValue = -1
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Value = 0
          OnChange = SEHourChange
        end
        object cbScript: TCheckBox
          Left = 3
          Top = 66
          Width = 61
          Height = 17
          Hint = 'Запустить скрипт вместо издавания звукового сигнала'
          Caption = 'Скрипт'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object eBudilnikDelay: TEdit
          Left = 63
          Top = 65
          Width = 37
          Height = 18
          Hint = 'Пауза между началами сигналов будильника (ms)'
          AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          Text = '1000'
        end
      end
      object gbMove: TGroupBox
        Left = 0
        Top = -2
        Width = 225
        Height = 119
        Hint = 'Перемещение итема под мышкой в указанную точку (нажмите кнопку и задайте координаты)'
        Caption = 'AutoMove'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object sbAMove_1: TSpeedButton
          Left = 19
          Top = 31
          Width = 53
          Height = 19
          AllowAllUp = True
          GroupIndex = 5
          Caption = '300, 240'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object Label16: TLabel
          Left = 19
          Top = 14
          Width = 64
          Height = 13
          Caption = 'Выбор точки'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label18: TLabel
          Left = 89
          Top = 13
          Width = 37
          Height = 13
          Caption = '(Ctrl+A):'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object sbAMove_2: TSpeedButton
          Left = 87
          Top = 31
          Width = 53
          Height = 19
          AllowAllUp = True
          GroupIndex = 5
          Caption = '300, 240'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object sbAMove_3: TSpeedButton
          Left = 155
          Top = 31
          Width = 53
          Height = 19
          AllowAllUp = True
          GroupIndex = 5
          Caption = '300, 240'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object Edit1: TEdit
          Left = 175
          Top = 9
          Width = 21
          Height = 15
          Hint = 'Задержка после поднятия итема'
          BorderStyle = bsNone
          Color = clBtnFace
          Ctl3D = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          TabOrder = 0
          Text = '350'
        end
        object cbMoveLeftCl: TCheckBox
          Left = 18
          Top = 79
          Width = 169
          Height = 17
          Hint = 'Разрешает перемещать мышку в точку назначения (немного быстрее и корректнее)'
          Caption = 'Перемещать мышку'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
        end
        object seAmove1: TSpinEdit
          Left = 19
          Top = 53
          Width = 53
          Height = 22
          Hint = 'Количество перетаскиваемых итемов (0 - все)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxValue = 65535
          MinValue = 0
          ParentFont = False
          TabOrder = 2
          Value = 0
        end
        object seAmove2: TSpinEdit
          Left = 87
          Top = 53
          Width = 53
          Height = 22
          Hint = 'Количество перетаскиваемых итемов (0 - все)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxValue = 65535
          MinValue = 0
          ParentFont = False
          TabOrder = 3
          Value = 0
        end
        object seAmove3: TSpinEdit
          Left = 155
          Top = 53
          Width = 53
          Height = 22
          Hint = 'Количество перетаскиваемых итемов (0 - все)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          MaxValue = 65535
          MinValue = 0
          ParentFont = False
          TabOrder = 4
          Value = 0
        end
        object cbStoD1: TCheckBox
          Left = 18
          Top = 96
          Width = 28
          Height = 17
          Hint = 'Меняет местами Источник и Приемник при перетаскивании'
          Caption = '1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
        end
        object cbStoD2: TCheckBox
          Left = 50
          Top = 96
          Width = 28
          Height = 17
          Hint = 'Меняет местами Источник и Приемник при перетаскивании'
          Caption = '2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 7
        end
        object cbStoD3: TCheckBox
          Left = 82
          Top = 96
          Width = 136
          Height = 17
          Hint = 'Меняет местами Источник и Приемник при перетаскивании'
          Caption = '3 Source<>Destination'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 8
        end
        object Edit2: TEdit
          Left = 199
          Top = 9
          Width = 21
          Height = 15
          Hint = 'Задержка после указания количества итемов'
          BorderStyle = bsNone
          Color = clBtnFace
          Ctl3D = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          Text = '0'
        end
      end
      object gbGM: TGroupBox
        Left = 0
        Top = 117
        Width = 225
        Height = 55
        Caption = 'Для GM`ов'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object sbGMPage: TSpeedButton
          Left = 120
          Top = 32
          Width = 97
          Height = 17
          Hint = 'Нажмите кнопку и выберите окно (Ctrl+A)'
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Press and Select'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object Bevel7: TBevel
          Left = 14
          Top = 27
          Width = 12
          Height = 13
          Shape = bsFrame
        end
        object cbGMPage: TCheckBox
          Left = 8
          Top = 14
          Width = 177
          Height = 17
          Hint = 'UoPilot будет мигать при приходе пейджа'
          Caption = 'Мигать при приходе пейжджа'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = cbGMPageClick
        end
        object cbGMPageAlarm: TCheckBox
          Left = 24
          Top = 31
          Width = 65
          Height = 17
          Hint = 'UoPilot издаст звуковой сигнал при приходе пейджа'
          Caption = 'Пищать'
          Checked = True
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 1
        end
      end
      object gbStartLoginUO: TGroupBox
        Left = 2
        Top = 172
        Width = 113
        Height = 87
        Caption = 'Запуск и логин'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnDblClick = GroupBox6Click
        object sbStartUO: TSpeedButton
          Left = 6
          Top = 18
          Width = 59
          Height = 17
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Start UO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          OnClick = sbStartUOClick
        end
        object sbLoginUO: TSpeedButton
          Left = 6
          Top = 39
          Width = 59
          Height = 17
          Hint = 'Нажмите кнопку и выберите окно (Ctrl+A)'
          AllowAllUp = True
          GroupIndex = 2
          Caption = 'Login'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = sbLoginUOClick
        end
        object eSUO: TEdit
          Left = 8
          Top = 60
          Width = 97
          Height = 21
          TabOrder = 2
        end
        object cbSUOMin: TCheckBox
          Left = 70
          Top = 13
          Width = 37
          Height = 17
          Hint = 'Запускать в свернутом окне'
          Caption = 'Min'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object tbUOPriority: TTrackBar
          Left = 67
          Top = 42
          Width = 38
          Height = 17
          Hint = 'Приоритет для запускаемых клиентов'
          Max = 3
          Min = 1
          ParentShowHint = False
          PageSize = 1
          Position = 2
          ShowHint = True
          TabOrder = 1
          ThumbLength = 9
          OnChange = tbUOPriorityChange
        end
        object StartUOOnly: TCheckBox
          Left = 70
          Top = 29
          Width = 37
          Height = 13
          Hint = 'Только запуск, без логина'
          Caption = 'SO'
          Ctl3D = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = []
          ParentCtl3D = False
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
      end
    end
    object tsOptions: TTabSheet
      Caption = 'Наст.'
      ImageIndex = 4
      TabVisible = False
    end
    object tsStart: TTabSheet
      Caption = 'Ещё'
      ImageIndex = 4
      object Bevel1: TBevel
        Left = 109
        Top = 6
        Width = 113
        Height = 73
      end
      object Bevel2: TBevel
        Left = 110
        Top = 7
        Width = 111
        Height = 71
        Style = bsRaised
      end
      object sbMacros: TSpeedButton
        Left = 2
        Top = 6
        Width = 103
        Height = 21
        Hint = 'Панель макросов.'
        AllowAllUp = True
        GroupIndex = 1
        Caption = 'Macros'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = sbMacrosClick
      end
      object sbSControl: TSpeedButton
        Left = 2
        Top = 32
        Width = 103
        Height = 21
        Hint = 'Панель управления кораблем'
        AllowAllUp = True
        GroupIndex = 2
        Caption = 'Ship Control'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = sbSControlClick
      end
      object sbHouseControl: TSpeedButton
        Left = 2
        Top = 58
        Width = 103
        Height = 21
        Hint = 'Панель управления домом'
        AllowAllUp = True
        GroupIndex = 3
        Caption = 'House Control'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = sbHouseControlClick
      end
      object sbEditHK: TSpeedButton
        Left = 2
        Top = 110
        Width = 103
        Height = 21
        Hint = 'Редактировать горячие клавиши'
        AllowAllUp = True
        GroupIndex = 5
        Caption = 'Edit HotKeys'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = sbEditHKClick
      end
      object sbCharParams: TSpeedButton
        Tag = 1
        Left = 114
        Top = 11
        Width = 103
        Height = 21
        Hint = 'Панель характеристик чара.'
        AllowAllUp = True
        GroupIndex = 6
        Caption = 'Char Parameters'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = sbCharParamsClick
      end
      object Label1: TLabel
        Left = 109
        Top = 110
        Width = 21
        Height = 13
        Caption = 'Cl.v.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object sbCFCP1: TSpeedButton
        Left = 122
        Top = 36
        Width = 11
        Height = 38
        GroupIndex = 10
        OnClick = sbCFCP1Click
      end
      object sbCFCP2: TSpeedButton
        Left = 133
        Top = 37
        Width = 11
        Height = 32
        GroupIndex = 10
        OnClick = sbCFCP2Click
      end
      object sbCFCP3: TSpeedButton
        Left = 144
        Top = 36
        Width = 11
        Height = 27
        GroupIndex = 10
        OnClick = sbCFCP3Click
      end
      object sbCFCP4: TSpeedButton
        Left = 156
        Top = 36
        Width = 19
        Height = 23
        GroupIndex = 10
        OnClick = sbCFCP4Click
      end
      object sbCFCP5: TSpeedButton
        Left = 176
        Top = 37
        Width = 11
        Height = 21
        GroupIndex = 10
        OnClick = sbCFCP5Click
      end
      object sbCFCP7: TSpeedButton
        Left = 187
        Top = 36
        Width = 11
        Height = 20
        GroupIndex = 10
        OnClick = sbCFCP7Click
      end
      object Label6: TLabel
        Left = 11
        Top = 237
        Width = 159
        Height = 13
        AutoSize = False
        Caption = 'Размер табуляции в редакторе'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 11
        Top = 175
        Width = 99
        Height = 13
        AutoSize = False
        Caption = 'Пауза между строк'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 158
        Top = 175
        Width = 13
        Height = 13
        Caption = 'ms'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object sbAnimalControl: TSpeedButton
        Left = 2
        Top = 84
        Width = 103
        Height = 21
        Hint = 'Панель управления животными'
        AllowAllUp = True
        GroupIndex = 4
        Caption = 'Animal && Vendor'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = sbAnimalControlClick
      end
      object Label11: TLabel
        Left = 11
        Top = 194
        Width = 137
        Height = 13
        Caption = 'Пауза между пустых строк'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label12: TLabel
        Left = 203
        Top = 194
        Width = 13
        Height = 13
        Caption = 'ms'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label15: TLabel
        Left = 11
        Top = 157
        Width = 71
        Height = 13
        Caption = 'Пауза SendEx'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label13: TLabel
        Left = 158
        Top = 158
        Width = 13
        Height = 13
        Caption = 'ms'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Left = 11
        Top = 214
        Width = 119
        Height = 13
        Caption = 'Пауза в кликах мышью'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label10: TLabel
        Left = 209
        Top = 213
        Width = 13
        Height = 13
        Caption = 'ms'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label17: TLabel
        Left = 11
        Top = 133
        Width = 159
        Height = 13
        Caption = 'Приоритет для новых скриптов'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object sbCFCP8: TSpeedButton
        Left = 198
        Top = 37
        Width = 11
        Height = 16
        GroupIndex = 10
        OnClick = sbCFCP8Click
      end
      object sbScriptsPanel: TSpeedButton
        Left = 232
        Top = 72
        Width = 23
        Height = 22
        Caption = 'Scripts'
        OnClick = sbScriptsPanelClick
      end
      object cbEnableHK: TCheckBox
        Left = 109
        Top = 81
        Width = 113
        Height = 17
        Hint = 'Реагировать на горячие клавиши'
        Caption = 'Включить HotKeys'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbEnableHKClick
      end
      object cbClVer: TComboBox
        Left = 131
        Top = 104
        Width = 91
        Height = 21
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ItemHeight = 0
        ParentFont = False
        TabOrder = 1
        OnChange = cbClVerChange
      end
      object seTabSize: TSpinEdit
        Left = 178
        Top = 233
        Width = 35
        Height = 22
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        MaxLength = 2
        MaxValue = 32
        MinValue = 1
        ParentFont = False
        TabOrder = 4
        Value = 1
        OnChange = seTabSizeChange
      end
      object eScriptDelayDef: TEdit
        Left = 116
        Top = 172
        Width = 41
        Height = 18
        Hint = 'Пауза между строк для новых скриптов'
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '100'
      end
      object edPauseNil: TEdit
        Left = 161
        Top = 191
        Width = 41
        Height = 18
        Hint = 'Пауза между строк, не содержащих команды'
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Text = '0'
      end
      object seSendExDelayDef: TSpinEdit
        Left = 110
        Top = 149
        Width = 47
        Height = 22
        Hint = 'Пауза между посылаемыми символами в команде SendEx'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        MaxValue = 10000
        MinValue = 0
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Value = 0
      end
      object seMouseClicksDelay: TSpinEdit
        Left = 161
        Top = 210
        Width = 47
        Height = 22
        Hint = 'Пауза между нажатием и отпусканием кнопки мыши в мышинных командах'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        MaxValue = 10000
        MinValue = 0
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        Value = 10
      end
      object tbScriptPriority: TTrackBar
        Left = 178
        Top = 133
        Width = 38
        Height = 17
        Hint = 'Приоритет для запускаемых клиентов'
        Max = 3
        ParentShowHint = False
        PageSize = 1
        Position = 2
        ShowHint = True
        TabOrder = 7
        ThumbLength = 9
        OnChange = tbScriptPriorityChange
      end
      object cbNtUserPM: TComboBox
        Left = 176
        Top = 152
        Width = 57
        Height = 21
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ItemHeight = 0
        ParentFont = False
        TabOrder = 8
      end
    end
  end
  object gbHouseControl: TGroupBox
    Left = 544
    Top = -2
    Width = 224
    Height = 91
    Caption = 'Управление домом'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
    object Button1: TSpeedButton
      Tag = 1
      Left = 8
      Top = 17
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Lock Down'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object Button4: TSpeedButton
      Tag = 4
      Left = 24
      Top = 41
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Ban'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object Button6: TSpeedButton
      Tag = 5
      Left = 104
      Top = 41
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Trash'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object Button7: TSpeedButton
      Tag = 7
      Left = 104
      Top = 65
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Strongbox'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object Button5: TSpeedButton
      Tag = 6
      Left = 24
      Top = 65
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Remove'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object Button2: TSpeedButton
      Tag = 2
      Left = 80
      Top = 17
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Secure'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object Button3: TSpeedButton
      Tag = 3
      Left = 152
      Top = 17
      Width = 64
      Height = 20
      Hint = 'Right click to edit'
      AllowAllUp = True
      Caption = 'Release'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = bHouseClick
      OnMouseDown = Button1MouseDown
    end
    object sbMfHH: TSpeedButton
      Left = 181
      Top = 65
      Width = 33
      Height = 18
      Hint = 'Показать\спрятать главную форму'
      Caption = 'Hide'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = sbMfHHClick
    end
  end
  object Panel3: TPanel
    Left = 306
    Top = 392
    Width = 102
    Height = 17
    BevelOuter = bvNone
    Constraints.MaxHeight = 22
    Constraints.MaxWidth = 134
    TabOrder = 14
    Visible = False
    object SpeedButton1: TSpeedButton
      Left = 1
      Top = 1
      Width = 41
      Height = 20
      Caption = 'Load'
      OnClick = btLoadClick
    end
    object SpeedButton2: TSpeedButton
      Left = 46
      Top = 1
      Width = 40
      Height = 20
      Caption = 'Save'
      OnClick = btSaveClick
    end
    object sbHideOnMax: TSpeedButton
      Tag = 5
      Left = 94
      Top = 1
      Width = 40
      Height = 20
      Caption = 'Hide'
      OnClick = sbMfHHClick
    end
  end
  object pCPVar: TPanel
    Left = 320
    Top = 7
    Width = 158
    Height = 99
    BevelOuter = bvNone
    BorderWidth = 1
    Constraints.MinWidth = 158
    TabOrder = 6
    Visible = False
    object sgVar: TStringGrid
      Left = 1
      Top = 1
      Width = 156
      Height = 97
      Hint = 'Текущие значения переменных'
      Align = alClient
      ColCount = 2
      DefaultColWidth = 50
      DefaultRowHeight = 16
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs]
      ParentFont = False
      ParentShowHint = False
      ScrollBars = ssVertical
      ShowHint = True
      TabOrder = 0
      OnDrawCell = sgVarDrawCell
      OnSelectCell = sgVarSelectCell
      OnSetEditText = sgVarSetEditText
    end
  end
  object pCPLastObjects: TPanel
    Left = 320
    Top = 111
    Width = 158
    Height = 193
    BevelOuter = bvNone
    TabOrder = 5
    Visible = False
    object sbLODel: TSpeedButton
      Tag = 1
      Left = 53
      Top = 76
      Width = 41
      Height = 17
      AllowAllUp = True
      Caption = 'Delete'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbLODelClick
    end
    object Label25: TLabel
      Left = 98
      Top = 76
      Width = 54
      Height = 13
      Caption = 'Last Object'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object sbLTDel: TSpeedButton
      Tag = 2
      Left = 115
      Top = 98
      Width = 41
      Height = 17
      AllowAllUp = True
      Caption = 'Delete'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbLODelClick
    end
    object sbLTAdd: TSpeedButton
      Tag = 2
      Left = 65
      Top = 98
      Width = 49
      Height = 17
      AllowAllUp = True
      Caption = 'Add'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbLOAddClick
    end
    object Label24: TLabel
      Left = 5
      Top = 102
      Width = 54
      Height = 13
      Caption = 'Last Target'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object sbLOAdd: TSpeedButton
      Tag = 1
      Left = 3
      Top = 76
      Width = 49
      Height = 17
      AllowAllUp = True
      Caption = 'Add'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbLOAddClick
    end
    object sgLastObject: TStringGrid
      Tag = 1
      Left = 1
      Top = 0
      Width = 156
      Height = 72
      ColCount = 3
      DefaultColWidth = 22
      DefaultRowHeight = 16
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs, goAlwaysShowEditor]
      ParentFont = False
      ParentShowHint = False
      PopupMenu = pmSaveLoadLO
      ScrollBars = ssVertical
      ShowHint = False
      TabOrder = 0
      OnDblClick = sgLastObjectDblClick
    end
    object sgLastTarget: TStringGrid
      Tag = 2
      Left = 1
      Top = 118
      Width = 156
      Height = 72
      ColCount = 3
      DefaultColWidth = 22
      DefaultRowHeight = 16
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs, goAlwaysShowEditor]
      ParentFont = False
      ParentShowHint = False
      PopupMenu = pmSaveLoadLO
      ScrollBars = ssVertical
      ShowHint = False
      TabOrder = 1
      OnDblClick = sgLastObjectDblClick
    end
  end
  object pCPDTimer: TPanel
    Left = 520
    Top = 408
    Width = 158
    Height = 22
    BevelOuter = bvNone
    TabOrder = 7
    Visible = False
    object sbCPhide: TSpeedButton
      Left = 123
      Top = 3
      Width = 33
      Height = 17
      Hint = 'Показать\спрятать главную форму'
      Caption = 'Hide'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = sbMfHHClick
    end
    object cbDrinkTimer: TCheckBox
      Left = 1
      Top = 4
      Width = 73
      Height = 15
      Hint = 'Show in UO caption'
      TabStop = False
      Caption = 'Drink Timer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object SpinEdit2: TSpinEdit
      Left = 77
      Top = 0
      Width = 41
      Height = 22
      Hint = 'Задержка на питье пузырей'
      TabStop = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Value = 18
    end
  end
  object HorSize: TPanel
    Left = 0
    Top = 352
    Width = 233
    Height = 17
    Caption = 'Horisontal size'
    TabOrder = 10
    Visible = False
  end
  object VertSize: TPanel
    Left = 296
    Top = 0
    Width = 17
    Height = 289
    Caption = 'Vertical size'
    TabOrder = 11
    Visible = False
  end
  object pLog: TPanel
    Left = 160
    Top = 512
    Width = 81
    Height = 65
    Caption = 'pLog'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 13
    Visible = False
    object tcLog: TTabControl
      Left = 8
      Top = 29
      Width = 57
      Height = 20
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      Tabs.Strings = (
        'M'
        '0')
      TabIndex = 0
      TabWidth = 21
      Visible = False
      OnChange = tcLogChange
      OnChanging = tcLogChanging
    end
    object mLog: TMemo
      Left = 8
      Top = 8
      Width = 57
      Height = 17
      TabStop = False
      Color = clInfoBk
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
    end
  end
  object pSelectUOserver: TPanel
    Left = 440
    Top = 480
    Width = 370
    Height = 185
    Hint = 'Select UO server'
    TabOrder = 16
    Visible = False
    object lsusPath: TLabel
      Left = 8
      Top = 12
      Width = 40
      Height = 13
      Caption = 'UO path'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object sbReload: TSpeedButton
      Left = 8
      Top = 40
      Width = 65
      Height = 20
      Caption = 'Reload'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbReloadClick
    end
    object sbSaveLL: TSpeedButton
      Left = 80
      Top = 40
      Width = 65
      Height = 19
      Caption = 'Save'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbSaveLLClick
    end
    object sbAddLine: TSpeedButton
      Left = 160
      Top = 40
      Width = 57
      Height = 19
      Caption = 'Add Line'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbAddLineClick
    end
    object sbClose: TSpeedButton
      Left = 304
      Top = 40
      Width = 57
      Height = 19
      Caption = 'Close'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbCloseClick
    end
    object eUOpath: TEdit
      Left = 56
      Top = 8
      Width = 306
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object sgLoginLine: TStringGrid
      Left = 8
      Top = 68
      Width = 354
      Height = 109
      Hint = 'Отметьте крестиком активные адреса'
      ColCount = 4
      DefaultColWidth = 24
      DefaultRowHeight = 16
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowMoving, goEditing]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnMouseUp = sgLoginLineMouseDown
      OnRowMoved = sgLoginLineRowMoved
    end
  end
  object pMakroOptions: TPanel
    Left = 0
    Top = 840
    Width = 433
    Height = 95
    Hint = 'Options'
    TabOrder = 18
    Visible = False
    object sbmoOk: TSpeedButton
      Left = 304
      Top = 64
      Width = 58
      Height = 25
      Caption = 'Ok'
      OnClick = sbmoOkClick
    end
    object sbmoCancel: TSpeedButton
      Left = 368
      Top = 64
      Width = 58
      Height = 25
      Caption = 'Cancel'
      OnClick = sbmoCancelClick
    end
    object lmoButName: TLabel
      Left = 8
      Top = 71
      Width = 65
      Height = 13
      Caption = 'Button Name:'
    end
    object mmoText: TMemo
      Left = 8
      Top = 8
      Width = 417
      Height = 47
      TabOrder = 0
    end
    object emoButName: TEdit
      Left = 79
      Top = 68
      Width = 67
      Height = 21
      TabOrder = 1
    end
    object cbmoEnter: TCheckBox
      Left = 208
      Top = 71
      Width = 81
      Height = 17
      Hint = 'Нажимать [Enter] в конце каждой строки '
      Caption = 'Press [Enter]'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 2
    end
    object edmoPause: TEdit
      Left = 158
      Top = 68
      Width = 35
      Height = 18
      Hint = 'Пауза между строками в миллисекундах'
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '800'
    end
  end
  object pEditHouse: TPanel
    Left = 512
    Top = 672
    Width = 274
    Height = 73
    Hint = 'Edit House commands'
    TabOrder = 17
    Visible = False
    object sbehOk: TSpeedButton
      Left = 136
      Top = 40
      Width = 58
      Height = 25
      AllowAllUp = True
      Caption = 'Ok'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbehOkClick
    end
    object sbehCancel: TSpeedButton
      Left = 208
      Top = 40
      Width = 58
      Height = 25
      AllowAllUp = True
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbehCancelClick
    end
    object eehEditHouseCommands: TEdit
      Left = 8
      Top = 10
      Width = 257
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
  end
  object pCharParams: TPanel
    Left = 488
    Top = 96
    Width = 158
    Height = 366
    BevelOuter = bvNone
    TabOrder = 9
    Visible = False
    object lName: TLabel
      Left = 1
      Top = 0
      Width = 120
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Name'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object sbShowSkills: TSpeedButton
      Left = 128
      Top = 0
      Width = 30
      Height = 15
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Skills'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbShowSkillsClick
    end
    object mLM: TMemo
      Left = 1
      Top = 325
      Width = 156
      Height = 39
      TabStop = False
      BorderStyle = bsNone
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      PopupMenu = pmCopyLM
      ReadOnly = True
      TabOrder = 0
      OnDblClick = mLMDblClick
    end
    object pSkills: TPanel
      Left = 0
      Top = 15
      Width = 158
      Height = 296
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object sgSkills: TStringGrid
        Left = 1
        Top = 0
        Width = 155
        Height = 297
        ColCount = 3
        Ctl3D = True
        DefaultColWidth = 104
        DefaultRowHeight = 15
        FixedCols = 0
        RowCount = 50
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        GridLineWidth = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSizing, goRowSelect]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
      end
    end
    object pCP: TPanel
      Left = 0
      Top = 15
      Width = 158
      Height = 306
      BevelOuter = bvNone
      TabOrder = 2
      object mParamName: TMemo
        Left = 1
        Top = 0
        Width = 78
        Height = 110
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'Hits'
          'Mana'
          'Stamina'
          'Gold'
          'Weight'
          'A:ph/f/c/p/e'
          'Damage'
          'Followers,')
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        WordWrap = False
      end
      object mParamName2: TMemo
        Left = 1
        Top = 107
        Width = 81
        Height = 201
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        Lines.Strings = (
          'CharPosX'
          'CharPosY'
          'CharPosZ'
          'CharDir'
          'LastObjectID'
          'LastObjectType'
          'LastTargetID'
          'LastTargetX'
          'LastTargetY'
          'LastTargetZ'
          'LastTargetKind'
          'LastLiftedID'
          'LastSkill'
          'LastSpell'
          'LastStaticType')
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
        WordWrap = False
      end
      object pCPchekbokses: TPanel
        Left = 66
        Top = 1
        Width = 12
        Height = 120
        Hint = 'Show in UO caption'
        BevelOuter = bvNone
        Color = clWindow
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        object cbHits: TCheckBox
          Left = 0
          Top = 0
          Width = 15
          Height = 15
          TabStop = False
          Caption = 'Hits:'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 0
        end
        object cbMana: TCheckBox
          Left = 0
          Top = 13
          Width = 15
          Height = 15
          TabStop = False
          Caption = 'Mana:'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 1
        end
        object cbStam: TCheckBox
          Left = 0
          Top = 26
          Width = 15
          Height = 15
          TabStop = False
          Caption = 'Stam:'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 2
        end
        object cbWght: TCheckBox
          Left = 0
          Top = 52
          Width = 15
          Height = 15
          TabStop = False
          Caption = 'Wght:'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 3
        end
        object cbAr: TCheckBox
          Left = 0
          Top = 65
          Width = 15
          Height = 15
          TabStop = False
          Caption = 'Ar:'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 4
        end
        object cbShowCoords: TCheckBox
          Left = 0
          Top = 103
          Width = 15
          Height = 19
          TabStop = False
          Caption = 'Show Coords'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 5
        end
        object cbGold: TCheckBox
          Left = 0
          Top = 39
          Width = 15
          Height = 15
          TabStop = False
          Caption = 'Gold:'
          Color = clBtnFace
          ParentColor = False
          TabOrder = 6
        end
      end
      object Panel15: TPanel
        Left = 52
        Top = 95
        Width = 26
        Height = 10
        BevelOuter = bvNone
        Caption = 'Luck'
        Color = clWindow
        TabOrder = 5
      end
      object mParamValue2: TStringGrid
        Left = 82
        Top = 107
        Width = 75
        Height = 201
        ColCount = 2
        DefaultColWidth = 70
        DefaultRowHeight = 13
        FixedCols = 0
        RowCount = 15
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        Options = [goTabs, goAlwaysShowEditor, goThumbTracking]
        ParentFont = False
        ScrollBars = ssNone
        TabOrder = 3
        OnDblClick = mParamValue2DblClick
        OnSelectCell = mParamValue2SelectCell
      end
      object mParamValue: TMemo
        Left = 78
        Top = 0
        Width = 78
        Height = 110
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 2
        WordWrap = False
      end
    end
  end
  object gbFind: TGroupBox
    Left = 8
    Top = 440
    Width = 369
    Height = 65
    Caption = 'Найти'
    TabOrder = 19
    Visible = False
    object eFindText: TEdit
      Left = 8
      Top = 16
      Width = 345
      Height = 21
      TabOrder = 0
      OnKeyUp = eFindTextKeyUp
    end
    object cbCaseSens: TCheckBox
      Left = 8
      Top = 40
      Width = 121
      Height = 17
      Caption = 'С учетом регистра'
      TabOrder = 1
    end
    object bFindNext: TButton
      Left = 280
      Top = 40
      Width = 75
      Height = 17
      Caption = 'Найти далее'
      TabOrder = 4
      OnClick = bFindNextClick
    end
    object rbFindUp: TRadioButton
      Tag = 1
      Left = 152
      Top = 40
      Width = 57
      Height = 17
      Caption = 'Вверх'
      TabOrder = 2
    end
    object rbFindDown: TRadioButton
      Tag = 1
      Left = 208
      Top = 40
      Width = 57
      Height = 17
      Caption = 'Вниз'
      Checked = True
      TabOrder = 3
      TabStop = True
    end
  end
  object gbShipControl: TGroupBox
    Left = 1002
    Top = 0
    Width = 228
    Height = 106
    Caption = 'Управление кораблем'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Visible = False
    object sbMfHS: TSpeedButton
      Left = 185
      Top = 80
      Width = 33
      Height = 18
      Hint = 'Показать\спрятать главную форму'
      Caption = 'Hide'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = sbMfHSClick
    end
    object sForward: TButton
      Left = 36
      Top = 16
      Width = 24
      Height = 24
      Hint = 'Forward'
      Caption = 'с'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = bShipClick
    end
    object sBack: TButton
      Left = 36
      Top = 74
      Width = 24
      Height = 24
      Hint = 'Back'
      Caption = 'т'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnClick = bShipClick
    end
    object sStop: TButton
      Left = 36
      Top = 45
      Width = 24
      Height = 24
      Hint = 'Stop'
      Caption = 'Ў'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = bShipOClick
    end
    object sTurnLeft: TButton
      Left = 97
      Top = 76
      Width = 24
      Height = 24
      Hint = 'Turn Left'
      Caption = 'Е'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      OnClick = bShipOClick
    end
    object sTurnRight: TButton
      Left = 153
      Top = 76
      Width = 24
      Height = 24
      Hint = 'Turn Right'
      Caption = 'Ж'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      OnClick = bShipOClick
    end
    object sLeft: TButton
      Left = 7
      Top = 45
      Width = 24
      Height = 24
      Hint = 'Left'
      Caption = 'п'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = bShipClick
    end
    object sRight: TButton
      Left = 65
      Top = 45
      Width = 24
      Height = 24
      Hint = 'Right'
      Caption = 'р'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = bShipClick
    end
    object sRaiseAnchor: TButton
      Left = 94
      Top = 37
      Width = 70
      Height = 18
      Hint = 'Raise Anchor'
      Caption = 'Raise Anchor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
      OnClick = bShipOClick
    end
    object sDropAnchor: TButton
      Left = 94
      Top = 55
      Width = 70
      Height = 18
      Hint = 'Drop Anchor'
      Caption = 'Drop Anchor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 14
      OnClick = bShipOClick
    end
    object sUnfurlSail: TButton
      Left = 94
      Top = 16
      Width = 70
      Height = 18
      Hint = 'Unfurl Sail'
      Caption = 'Unfurl Sail'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      OnClick = bShipOClick
    end
    object sFL: TButton
      Left = 7
      Top = 16
      Width = 24
      Height = 24
      Hint = 'Forward Left'
      Caption = 'х'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = bShipClick
    end
    object sBL: TButton
      Left = 7
      Top = 74
      Width = 24
      Height = 24
      Hint = 'Back Left'
      Caption = 'ч'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = bShipClick
    end
    object sFR: TButton
      Left = 65
      Top = 16
      Width = 24
      Height = 24
      Hint = 'Forward Right'
      Caption = 'ц'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = bShipClick
    end
    object sBR: TButton
      Left = 65
      Top = 74
      Width = 24
      Height = 24
      Hint = 'Back Right'
      Caption = 'ш'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnClick = bShipClick
    end
    object sTurnA: TButton
      Left = 125
      Top = 76
      Width = 24
      Height = 24
      Hint = 'Turn Around'
      Caption = 'ф'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Wingdings'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      OnClick = bShipOClick
    end
    object rbNormal: TRadioButton
      Left = 168
      Top = 28
      Width = 55
      Height = 17
      Caption = 'Normal'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 16
      TabStop = True
    end
    object rbSlow: TRadioButton
      Left = 168
      Top = 44
      Width = 55
      Height = 17
      Caption = 'Slow'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 17
    end
    object rbOne: TRadioButton
      Left = 168
      Top = 60
      Width = 55
      Height = 17
      Caption = 'One'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 18
    end
    object rbFull: TRadioButton
      Left = 168
      Top = 12
      Width = 55
      Height = 17
      Caption = 'Full'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 15
      TabStop = True
    end
  end
  object pCustomClient: TPanel
    Left = 480
    Top = 256
    Width = 437
    Height = 377
    Hint = 'Custom Client'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 15
    Visible = False
    object lccName: TLabel
      Left = 15
      Top = 123
      Width = 28
      Height = 13
      Caption = 'Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccTrans: TLabel
      Left = 15
      Top = 147
      Width = 27
      Height = 13
      Caption = 'Trans'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccCrim: TLabel
      Left = 15
      Top = 171
      Width = 20
      Height = 13
      Caption = 'Crim'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offPathF1: TLabel
      Left = 15
      Top = 195
      Width = 28
      Height = 13
      Caption = 'PathF'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offCP1: TLabel
      Left = 8
      Top = 12
      Width = 14
      Height = 13
      Caption = 'CP'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLMess1: TLabel
      Left = 8
      Top = 36
      Width = 31
      Height = 13
      Caption = 'LMess'
    end
    object offCoords1: TLabel
      Left = 230
      Top = 12
      Width = 33
      Height = 13
      Caption = 'Coords'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offTarget1: TLabel
      Left = 230
      Top = 36
      Width = 31
      Height = 13
      Caption = 'Target'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastSpell1: TLabel
      Left = 230
      Top = 60
      Width = 43
      Height = 13
      Caption = 'LastSpell'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastSkill1: TLabel
      Left = 230
      Top = 84
      Width = 39
      Height = 13
      Caption = 'LastSkill'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastLiftedID1: TLabel
      Left = 230
      Top = 108
      Width = 57
      Height = 13
      Caption = 'LastLiftedID'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastObjectType1: TLabel
      Left = 230
      Top = 132
      Width = 75
      Height = 13
      Caption = 'LastObjectType'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastStaticType1: TLabel
      Left = 230
      Top = 156
      Width = 71
      Height = 13
      Caption = 'LastStaticType'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastTargetKind1: TLabel
      Left = 230
      Top = 180
      Width = 72
      Height = 13
      Caption = 'LastTargetKind'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastTargetXYZ1: TLabel
      Left = 230
      Top = 204
      Width = 72
      Height = 13
      Caption = 'LastTargetXYZ'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastOb1: TLabel
      Left = 230
      Top = 228
      Width = 34
      Height = 13
      Caption = 'LastOb'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offLastTar1: TLabel
      Left = 230
      Top = 252
      Width = 36
      Height = 13
      Caption = 'LastTar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object offCharDir1: TLabel
      Left = 230
      Top = 276
      Width = 35
      Height = 13
      Caption = 'CharDir'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object sbLMFind: TSpeedButton
      Left = 40
      Top = 32
      Width = 9
      Height = 21
      Hint = 'Start'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = sbLMFindClick
    end
    object sbCPFind: TSpeedButton
      Left = 40
      Top = 8
      Width = 9
      Height = 22
      Hint = 'Start'
      ParentShowHint = False
      ShowHint = True
      OnClick = sbCPFindClick
    end
    object lccFontcol: TLabel
      Left = 230
      Top = 323
      Width = 44
      Height = 13
      Caption = 'Fontcolor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccLastSp: TLabel
      Left = 7
      Top = 299
      Width = 87
      Height = 13
      Caption = 'LastSpellStartNum'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccSkills: TLabel
      Left = 230
      Top = 299
      Width = 24
      Height = 13
      Caption = 'Skills'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccHiddenW: TLabel
      Left = 15
      Top = 243
      Width = 59
      Height = 13
      Caption = 'Hidden\War'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccArun: TLabel
      Left = 15
      Top = 267
      Width = 53
      Height = 13
      Caption = 'AlwaysRun'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccConUnTe: TLabel
      Left = 7
      Top = 323
      Width = 99
      Height = 13
      Caption = 'ConsoleUnicodeText'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccWght: TLabel
      Left = 15
      Top = 219
      Width = 26
      Height = 13
      Caption = 'Wght'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lccClVer: TLabel
      Left = 16
      Top = 80
      Width = 48
      Height = 13
      Caption = 'Client Ver '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object sbStopSearchClient: TSpeedButton
      Left = 8
      Top = 56
      Width = 27
      Height = 16
      Caption = 'Stop'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = sbStopSearchClientClick
    end
    object lBackpack: TLabel
      Left = 230
      Top = 347
      Width = 49
      Height = 13
      Caption = 'Backpack'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object EoffName: TSpinEdit
      Tag = 1
      Left = 95
      Top = 119
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 4
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffTrans: TSpinEdit
      Tag = 2
      Left = 95
      Top = 143
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 5
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffCrim: TSpinEdit
      Tag = 3
      Left = 95
      Top = 167
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 6
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffPathF: TSpinEdit
      Tag = 4
      Left = 95
      Top = 191
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 7
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffCP: TSpinEdit
      Tag = 5
      Left = 120
      Top = 8
      Width = 89
      Height = 22
      Hint = 'Starting address'
      MaxValue = 0
      MinValue = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 25
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLMess: TSpinEdit
      Tag = 6
      Left = 120
      Top = 32
      Width = 89
      Height = 22
      Hint = 'Starting address'
      MaxValue = 0
      MinValue = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 26
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffCoords: TSpinEdit
      Tag = 7
      Left = 310
      Top = 8
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 11
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffTarget: TSpinEdit
      Tag = 8
      Left = 310
      Top = 32
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 12
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastSpell: TSpinEdit
      Tag = 9
      Left = 310
      Top = 56
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 13
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastSkill: TSpinEdit
      Tag = 10
      Left = 310
      Top = 80
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 14
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastLiftedID: TSpinEdit
      Tag = 11
      Left = 310
      Top = 104
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 15
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastObjectType: TSpinEdit
      Tag = 12
      Left = 310
      Top = 128
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 16
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastStaticType: TSpinEdit
      Tag = 13
      Left = 310
      Top = 152
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 17
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastTargetKind: TSpinEdit
      Tag = 14
      Left = 310
      Top = 176
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 18
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastTargetXYZ: TSpinEdit
      Tag = 15
      Left = 310
      Top = 200
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 19
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastObTar1: TSpinEdit
      Tag = 16
      Left = 310
      Top = 224
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 20
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffLastObTar2: TSpinEdit
      Tag = 17
      Left = 310
      Top = 248
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 21
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffCharDir: TSpinEdit
      Tag = 18
      Left = 310
      Top = 272
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 22
      Value = 0
      OnChange = EoffNameChange
    end
    object eLM: TEdit
      Left = 48
      Top = 32
      Width = 65
      Height = 21
      Hint = 'First 32 (unicode - 16) characters'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = 'You see'
    end
    object sLM: TSpinEdit
      Left = 120
      Top = 32
      Width = 97
      Height = 22
      Hint = 'Result'
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Value = 0
      Visible = False
    end
    object sCPGold: TSpinEdit
      Left = 48
      Top = 8
      Width = 65
      Height = 22
      Hint = 'Gold'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Value = 0
    end
    object sCP: TSpinEdit
      Left = 120
      Top = 8
      Width = 97
      Height = 22
      Hint = 'Result'
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Value = 0
      Visible = False
    end
    object rbClVer1_3: TRadioButton
      Left = 272
      Top = 8
      Width = 113
      Height = 17
      Caption = 'Client Ver < 6'
      Checked = True
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 27
      TabStop = True
      Visible = False
    end
    object rbClVer6_x: TRadioButton
      Left = 272
      Top = 27
      Width = 113
      Height = 17
      Caption = 'Client Ver >= 6'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 28
      Visible = False
    end
    object EoffFontcolor: TSpinEdit
      Tag = 19
      Left = 310
      Top = 319
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 24
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffWght: TSpinEdit
      Tag = 20
      Left = 95
      Top = 215
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 8
      Value = 0
      OnChange = EoffNameChange
    end
    object ELastSpellStartNum: TSpinEdit
      Tag = 21
      Left = 103
      Top = 295
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 9
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffSkills: TSpinEdit
      Tag = 22
      Left = 310
      Top = 295
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 23
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffHidden_War: TSpinEdit
      Tag = 23
      Left = 95
      Top = 239
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 29
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffAlwaysRun: TSpinEdit
      Tag = 24
      Left = 95
      Top = 263
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 30
      Value = 0
      OnChange = EoffNameChange
    end
    object EoffConsoleUnicodeText: TSpinEdit
      Tag = 25
      Left = 103
      Top = 319
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 10
      Value = 0
      OnChange = EoffNameChange
    end
    object cbCustomClVer: TComboBox
      Left = 72
      Top = 72
      Width = 89
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 31
      OnChange = cbCustomClVerChange
      Items.Strings = (
        'MU'
        '< 2.0.3'
        '2.0.3-3.0.0'
        '3.0.8'
        'ML6.0.7.0'
        'ML6.0.12.3'
        'ML7.0.4.3')
    end
    object EoffBackpack: TSpinEdit
      Tag = 26
      Left = 310
      Top = 343
      Width = 121
      Height = 22
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      MaxValue = 0
      MinValue = 0
      ParentFont = False
      TabOrder = 32
      Value = 0
      OnChange = EoffNameChange
    end
  end
  object gbHotKeyList: TGroupBox
    Left = 688
    Top = 28
    Width = 582
    Height = 407
    Caption = 'HotKeys list'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Microsoft Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 4
    Visible = False
    object Bevel4: TBevel
      Left = 426
      Top = 30
      Width = 150
      Height = 261
      Shape = bsFrame
    end
    object lhkUopUO: TSpeedButton
      Tag = 14
      Left = 430
      Top = 255
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkMove_3: TSpeedButton
      Tag = 16
      Left = 430
      Top = 153
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkMove_2: TSpeedButton
      Tag = 15
      Left = 430
      Top = 136
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhk3: TSpeedButton
      Tag = 10
      Left = 430
      Top = 68
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhk2: TSpeedButton
      Tag = 9
      Left = 430
      Top = 51
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhk1: TSpeedButton
      Tag = 8
      Left = 430
      Top = 34
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhk4: TSpeedButton
      Tag = 11
      Left = 430
      Top = 85
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhk5: TSpeedButton
      Tag = 12
      Left = 430
      Top = 102
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkMove_1: TSpeedButton
      Tag = 7
      Left = 430
      Top = 119
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkSetMove_1: TSpeedButton
      Tag = 17
      Left = 430
      Top = 170
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkSetMove_2: TSpeedButton
      Tag = 18
      Left = 430
      Top = 187
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkSetMove_3: TSpeedButton
      Tag = 19
      Left = 430
      Top = 204
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkLockAllScriptToUO: TSpeedButton
      Tag = 22
      Left = 430
      Top = 221
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkClipboardConsoleText: TSpeedButton
      Tag = 23
      Left = 430
      Top = 238
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkEnableKeyboard: TSpeedButton
      Tag = 34
      Left = 430
      Top = 272
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object lhkEnableAllHotKeys: TSpeedButton
      Tag = 33
      Left = 430
      Top = 13
      Width = 142
      Height = 15
      AllowAllUp = True
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      OnClick = lhkScrClick
    end
    object cbhkScr: TCheckBox
      Tag = 1
      Left = 8
      Top = 16
      Width = 126
      Height = 17
      Hint = 'Сохраняет копию экрана в файл'
      Caption = 'Print Screen'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkSScript: TCheckBox
      Tag = 2
      Left = 8
      Top = 33
      Width = 126
      Height = 17
      Hint = 'Запускает\останавливает текущий скрипт'
      Caption = 'Start Script'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkRec: TCheckBox
      Tag = 3
      Left = 8
      Top = 118
      Width = 126
      Height = 17
      Hint = 'Записывает макрос клавиш'
      Caption = 'Record Macros'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkRecStop: TCheckBox
      Tag = 4
      Left = 8
      Top = 135
      Width = 126
      Height = 17
      Hint = 'Останавливает запись или проигрывание макроса клавиш'
      Caption = 'Stop Play\Record'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkPlay: TCheckBox
      Tag = 5
      Left = 8
      Top = 152
      Width = 126
      Height = 17
      Hint = 'Проигрывает, записанный ранее, макрос клавиш'
      Caption = 'Play Macros'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkSNames: TCheckBox
      Tag = 6
      Left = 8
      Top = 169
      Width = 126
      Height = 17
      Hint = 'Включает\выключает отображение имен игроков'
      Caption = 'Show Names'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkMove_1: TCheckBox
      Tag = 7
      Left = 296
      Top = 118
      Width = 126
      Height = 17
      Hint = 'Перемещение итема под мышкой в указанную точку или наоборот'
      Caption = 'Auto Move 1'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 19
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhk1: TCheckBox
      Tag = 8
      Left = 296
      Top = 33
      Width = 126
      Height = 17
      Hint = 'Кликалки с вкладки Общее'
      Caption = 'Button 1'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 14
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhk2: TCheckBox
      Tag = 9
      Left = 296
      Top = 50
      Width = 126
      Height = 17
      Hint = 'Кликалки с вкладки Общее'
      Caption = 'Button 2'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 15
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhk3: TCheckBox
      Tag = 10
      Left = 296
      Top = 67
      Width = 126
      Height = 17
      Hint = 'Кликалки с вкладки Общее'
      Caption = 'Button 3'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 16
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhk4: TCheckBox
      Tag = 11
      Left = 296
      Top = 84
      Width = 126
      Height = 17
      Hint = 'Кликалки с вкладки Общее'
      Caption = 'Button 4'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 17
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhk5: TCheckBox
      Tag = 12
      Left = 296
      Top = 101
      Width = 126
      Height = 17
      Hint = 'Кликалки с вкладки Общее'
      Caption = 'Button 5'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 18
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkMes: TCheckBox
      Tag = 13
      Left = 8
      Top = 254
      Width = 126
      Height = 17
      Hint = 'Включает\выключает отображение панели макросов'
      Caption = 'Macros'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkUopUO: TCheckBox
      Tag = 14
      Left = 296
      Top = 254
      Width = 126
      Height = 17
      Hint = 'Переключает UoPilot <-> UO'
      Caption = 'UoPilot <-> UO'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkMove_2: TCheckBox
      Tag = 15
      Left = 296
      Top = 135
      Width = 126
      Height = 17
      Hint = 'Перемещение итема под мышкой в указанную точку или наоборот'
      Caption = 'Auto Move 2'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 20
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkMove_3: TCheckBox
      Tag = 16
      Left = 296
      Top = 152
      Width = 126
      Height = 17
      Hint = 'Перемещение итема под мышкой в указанную точку или наоборот'
      Caption = 'Auto Move 3'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 21
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkPScript: TCheckBox
      Tag = 20
      Left = 8
      Top = 50
      Width = 126
      Height = 17
      Hint = 'Приостанавливает\возобновляет выполнение  текущего скрипта'
      Caption = 'Pause Script'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkSetMove_3: TCheckBox
      Tag = 19
      Left = 296
      Top = 203
      Width = 126
      Height = 17
      Hint = 'Установка координат для функции AutoMove'
      Caption = 'Set AutoMove 3'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 24
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkSetMove_2: TCheckBox
      Tag = 18
      Left = 296
      Top = 186
      Width = 126
      Height = 17
      Hint = 'Установка координат для функции AutoMove'
      Caption = 'Set AutoMove 2'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 23
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkSetMove_1: TCheckBox
      Tag = 17
      Left = 296
      Top = 169
      Width = 126
      Height = 17
      Hint = 'Установка координат для функции AutoMove'
      Caption = 'Set AutoMove 1'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 22
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkCharParams: TCheckBox
      Tag = 21
      Left = 8
      Top = 271
      Width = 126
      Height = 17
      Hint = 'Включает\выключает отображение панели параметров чара'
      Caption = 'Char Params'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkLockAllScriptToUO: TCheckBox
      Tag = 22
      Left = 296
      Top = 220
      Width = 126
      Height = 17
      Hint = 'Прилочивает все скрипты к указанному окну УО'
      Caption = 'Lock all Scripts'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 25
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkClipboardConsoleText: TCheckBox
      Tag = 23
      Left = 296
      Top = 237
      Width = 126
      Height = 17
      Hint = 'Копирует текст, набранный в окне клиента, в буфер обмена'
      Caption = 'Copy ConsoleText'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 26
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkTransp: TCheckBox
      Tag = 24
      Left = 8
      Top = 186
      Width = 126
      Height = 17
      Hint = 'Включает\выключает круг прозрачности'
      Caption = 'Transparency'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkPathF: TCheckBox
      Tag = 25
      Left = 8
      Top = 203
      Width = 126
      Height = 17
      Hint = 'Включает\выключает поиск пути по двойному правому клику'
      Caption = 'Path Finding'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkCrimAct: TCheckBox
      Tag = 26
      Left = 8
      Top = 220
      Width = 126
      Height = 17
      Hint = 'Включает\выключает предупреждение о совершении противоправных действий'
      Caption = 'Criminal Actions'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkARun: TCheckBox
      Tag = 27
      Left = 8
      Top = 237
      Width = 126
      Height = 17
      Hint = 'Включает\выключает постоянный бег'
      Caption = 'Always Run'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object Panel16: TPanel
      Left = 296
      Top = 310
      Width = 279
      Height = 91
      BevelOuter = bvNone
      Color = clBtnShadow
      TabOrder = 27
      object sghkScriptHKList: TStringGrid
        Left = 0
        Top = 0
        Width = 281
        Height = 91
        Hint = 'Горячие клавиши для скриптов'
        ColCount = 6
        DefaultColWidth = 32
        DefaultRowHeight = 16
        FixedCols = 0
        RowCount = 1
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
        ParentFont = False
        ParentShowHint = False
        ScrollBars = ssVertical
        ShowHint = True
        TabOrder = 5
        OnClick = sghkScriptHKListClick
        OnDrawCell = sghkScriptHKListDrawCell
      end
      object Panel5: TPanel
        Left = 142
        Top = 0
        Width = 3
        Height = 90
        TabOrder = 1
      end
      object Panel23: TPanel
        Left = 258
        Top = 0
        Width = 3
        Height = 90
        TabOrder = 12
      end
      object Panel24: TPanel
        Left = 244
        Top = 0
        Width = 3
        Height = 90
        TabOrder = 13
      end
      object Panel18: TPanel
        Left = 245
        Top = 17
        Width = 16
        Height = 3
        TabOrder = 7
      end
      object Panel19: TPanel
        Left = 245
        Top = 34
        Width = 16
        Height = 3
        TabOrder = 8
      end
      object Panel20: TPanel
        Left = 245
        Top = 51
        Width = 16
        Height = 3
        TabOrder = 9
      end
      object Panel21: TPanel
        Left = 245
        Top = 68
        Width = 16
        Height = 3
        TabOrder = 10
      end
      object Panel22: TPanel
        Left = 245
        Top = 85
        Width = 16
        Height = 3
        TabOrder = 11
      end
      object Panel17: TPanel
        Left = 128
        Top = 0
        Width = 3
        Height = 90
        TabOrder = 14
      end
      object Panel6: TPanel
        Left = 129
        Top = 17
        Width = 16
        Height = 3
        TabOrder = 6
      end
      object Panel7: TPanel
        Left = 129
        Top = 34
        Width = 16
        Height = 3
        TabOrder = 4
      end
      object Panel8: TPanel
        Left = 129
        Top = 51
        Width = 16
        Height = 3
        TabOrder = 3
      end
      object Panel9: TPanel
        Left = 129
        Top = 68
        Width = 16
        Height = 3
        TabOrder = 2
      end
      object Panel10: TPanel
        Left = 129
        Top = 85
        Width = 16
        Height = 3
        TabOrder = 0
      end
    end
    object cbhkSetWorkWindow: TCheckBox
      Tag = 29
      Left = 8
      Top = 288
      Width = 126
      Height = 17
      Hint = 'Задает рабочее окно и определяет цвет с координатами. полный аналог Ctrl+A'
      Caption = 'Set work window'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 28
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkStopAllScript: TCheckBox
      Tag = 28
      Left = 8
      Top = 84
      Width = 126
      Height = 17
      Hint = 'Останавливает все скрипты'
      Caption = 'Stop All Scripts'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 29
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkPauseAllScript: TCheckBox
      Tag = 30
      Left = 8
      Top = 67
      Width = 126
      Height = 17
      Hint = 'Приостанавливает\возобнавляет все скрипты'
      Caption = 'Pause All Scripts'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 30
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object cbhkEnableKeyboard: TCheckBox
      Tag = 34
      Left = 296
      Top = 271
      Width = 126
      Height = 17
      Caption = 'Enable keyboard'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 31
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object Panel25: TPanel
      Left = 2
      Top = 333
      Width = 286
      Height = 73
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Constraints.MaxHeight = 73
      Constraints.MaxWidth = 286
      TabOrder = 32
      object sbCancel: TSpeedButton
        Left = 218
        Top = 38
        Width = 58
        Height = 25
        Hint = 'sbCancelClick'
        AllowAllUp = True
        Caption = 'Close'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        OnClick = sbCancelClick
      end
      object sbApply: TSpeedButton
        Left = 152
        Top = 38
        Width = 58
        Height = 25
        Caption = 'Apply'
        Enabled = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        OnClick = sbApplyClick
      end
      object Bevel6: TBevel
        Left = 0
        Top = 0
        Width = 285
        Height = 2
        Shape = bsTopLine
      end
      object Bevel5: TBevel
        Left = 267
        Top = 0
        Width = 19
        Height = 73
        Align = alRight
        Shape = bsRightLine
      end
      object sbSoundFileSelect: TSpeedButton
        Left = 128
        Top = 40
        Width = 15
        Height = 22
        Caption = '...'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        OnClick = sbSoundFileSelectClick
      end
      object cbHKList: TComboBox
        Left = 8
        Top = 10
        Width = 99
        Height = 21
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ItemHeight = 13
        ParentFont = False
        TabOrder = 0
      end
      object cbShift: TCheckBox
        Left = 133
        Top = 12
        Width = 40
        Height = 17
        Caption = 'Shift'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object cbAlt: TCheckBox
        Left = 185
        Top = 12
        Width = 31
        Height = 17
        Caption = 'Alt'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object cbCtrl: TCheckBox
        Left = 227
        Top = 12
        Width = 34
        Height = 17
        Caption = 'Ctrl'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
      object eSoundFileSelect: TEdit
        Left = 8
        Top = 40
        Width = 121
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Microsoft Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
      end
      object cbHotKeyIsHolded: TCheckBox
        Left = 100
        Top = 28
        Width = 41
        Height = 17
        Caption = 'Hold'
        TabOrder = 5
        Visible = False
      end
    end
    object cbhkEnableAllHotKeys: TCheckBox
      Tag = 33
      Left = 296
      Top = 12
      Width = 126
      Height = 17
      Caption = 'Enable All HotKeys'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 33
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object Panel26: TPanel
      Left = 424
      Top = 296
      Width = 67
      Height = 16
      Caption = 'Start\Stop'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 34
    end
    object Panel27: TPanel
      Left = 490
      Top = 296
      Width = 67
      Height = 16
      Caption = 'Pause'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 35
    end
    object cbhkStartAllScript: TCheckBox
      Tag = 31
      Left = 8
      Top = 101
      Width = 126
      Height = 17
      Caption = 'Start All Scripts'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 36
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object Bevel3: TPanel
      Left = 138
      Top = 13
      Width = 150
      Height = 312
      BevelInner = bvRaised
      BevelOuter = bvLowered
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 37
      object lhkScr: TSpeedButton
        Tag = 1
        Left = 4
        Top = 4
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkSScript: TSpeedButton
        Tag = 2
        Left = 4
        Top = 21
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkPScript: TSpeedButton
        Tag = 20
        Left = 4
        Top = 38
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkRec: TSpeedButton
        Tag = 3
        Left = 4
        Top = 106
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkRecStop: TSpeedButton
        Tag = 4
        Left = 4
        Top = 123
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkPlay: TSpeedButton
        Tag = 5
        Left = 4
        Top = 140
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkSNames: TSpeedButton
        Tag = 6
        Left = 4
        Top = 157
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkMes: TSpeedButton
        Tag = 13
        Left = 4
        Top = 242
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkCharParams: TSpeedButton
        Tag = 21
        Left = 4
        Top = 259
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkTransp: TSpeedButton
        Tag = 24
        Left = 4
        Top = 174
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkPathF: TSpeedButton
        Tag = 25
        Left = 4
        Top = 191
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkCrimAct: TSpeedButton
        Tag = 26
        Left = 4
        Top = 208
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkARun: TSpeedButton
        Tag = 27
        Left = 4
        Top = 225
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkStopAllScript: TSpeedButton
        Tag = 28
        Left = 4
        Top = 72
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkSetWorkWindow: TSpeedButton
        Tag = 29
        Left = 4
        Top = 276
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkPauseAllScript: TSpeedButton
        Tag = 30
        Left = 4
        Top = 55
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkStartAllScript: TSpeedButton
        Tag = 31
        Left = 4
        Top = 89
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
      object lhkShowScriptProcessing: TSpeedButton
        Tag = 29
        Left = 4
        Top = 293
        Width = 142
        Height = 15
        AllowAllUp = True
        Flat = True
        OnClick = lhkScrClick
      end
    end
    object cbhkShowScriptProcessing: TCheckBox
      Tag = 32
      Left = 8
      Top = 305
      Width = 126
      Height = 17
      Caption = 'ShowScriptProcessing'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 38
      OnClick = cbhk1Click
      OnMouseDown = cbhkMouseDown
    end
    object Button8: TButton
      Left = 104
      Top = 152
      Width = 185
      Height = 65
      Caption = 'Последний использованный тэг - 34'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 39
      Visible = False
      WordWrap = True
    end
  end
  object pOptions: TPanel
    Left = 1016
    Top = 360
    Width = 377
    Height = 385
    TabOrder = 12
    Visible = False
    object bSaveOptions: TButton
      Left = 184
      Top = 352
      Width = 75
      Height = 25
      Caption = 'Save'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = miSaveOptionsClick
    end
    object PageControl1: TPageControl
      Left = 0
      Top = 0
      Width = 378
      Height = 345
      ActivePage = tsSMouse
      TabOrder = 1
      object tsSUltimaOnline: TTabSheet
        Caption = 'Ultima Online'
        object gbUltimaOnline: TGroupBox
          Left = 0
          Top = 0
          Width = 369
          Height = 201
          Caption = 'Ultima Online'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object SelectUOserver1: TSpeedButton
            Left = 8
            Top = 168
            Width = 97
            Height = 17
            AllowAllUp = True
            Caption = 'Select UO server'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            OnClick = sbSelServClick
          end
          object miSortSkillList: TCheckBox
            Left = 8
            Top = 16
            Width = 353
            Height = 17
            Caption = 'Сортировать список скилов на панели параметров'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object N01: TGroupBox
            Left = 8
            Top = 40
            Width = 121
            Height = 105
            Caption = 'Наcтройки UO'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnClick = miUOSetupClick
            object cbName: TCheckBox
              Tag = 1
              Left = 8
              Top = 16
              Width = 105
              Height = 17
              Hint = 'Показывать имена приближающихся игроков'
              Caption = 'Имена '
              Checked = True
              Color = clBtnFace
              ParentColor = False
              State = cbChecked
              TabOrder = 0
              OnClick = cbNameClick
            end
            object cbTrans: TCheckBox
              Tag = 2
              Left = 8
              Top = 32
              Width = 105
              Height = 17
              Caption = 'Прозрачность'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 1
              OnClick = cbNameClick
            end
            object cbPathF: TCheckBox
              Tag = 3
              Left = 8
              Top = 48
              Width = 105
              Height = 17
              Caption = 'Патфиндинг'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 2
              OnClick = cbNameClick
            end
            object cbCrim: TCheckBox
              Tag = 4
              Left = 8
              Top = 64
              Width = 105
              Height = 17
              Caption = 'Criminal Actions'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 3
              OnClick = cbNameClick
            end
            object cbRun: TCheckBox
              Tag = 5
              Left = 8
              Top = 80
              Width = 105
              Height = 17
              Caption = 'Always Run'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 4
              OnClick = cbNameClick
            end
          end
          object miErrorReadCP: TGroupBox
            Left = 136
            Top = 120
            Width = 225
            Height = 73
            Caption = 'При ошибке чтения параметров чара'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 3
            object miStopSErrorRead: TCheckBox
              Left = 8
              Top = 16
              Width = 209
              Height = 17
              Caption = 'Оставливать скрипт'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 0
              OnClick = miStopSErrorReadClick
            end
            object miPauseSErrorRead: TCheckBox
              Left = 8
              Top = 32
              Width = 209
              Height = 17
              Caption = 'Приостанавливать скрипт'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 1
              OnClick = miPauseSErrorReadClick
            end
            object miInformErrorRead: TCheckBox
              Left = 8
              Top = 48
              Width = 209
              Height = 17
              Caption = 'Информировать об ошибке'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 2
              OnClick = miInformErrorReadClick
            end
          end
          object miShowCharParams: TGroupBox
            Left = 136
            Top = 40
            Width = 225
            Height = 73
            Caption = 'Отображать параметры чара'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            object miSCPscript: TRadioButton
              Left = 8
              Top = 16
              Width = 209
              Height = 17
              Caption = 'Активного скрипта'
              Checked = True
              Color = clBtnFace
              ParentColor = False
              TabOrder = 0
              TabStop = True
              OnClick = miSCPscriptClick
            end
            object miSCPtopuo: TRadioButton
              Left = 8
              Top = 32
              Width = 209
              Height = 17
              Caption = 'Верхнего окна UO'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 1
              OnClick = miSCPscriptClick
            end
            object miSCPuop: TRadioButton
              Left = 8
              Top = 48
              Width = 209
              Height = 17
              Caption = 'Окна UoPilot''а'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 2
              OnClick = miSCPscriptClick
            end
          end
        end
      end
      object tsSScripts: TTabSheet
        Caption = 'Scripts'
        ImageIndex = 1
        object GroupBox2: TGroupBox
          Left = 0
          Top = 0
          Width = 369
          Height = 265
          Caption = 'Scripts'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object lComment: TLabel
            Left = 8
            Top = 240
            Width = 88
            Height = 13
            Caption = 'Коментировать...'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object miAddSp: TCheckBox
            Left = 8
            Top = 176
            Width = 353
            Height = 17
            Caption = 'Добавлять пробелы'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 0
            OnClick = miAddSpClick
          end
          object miStopSUncC: TCheckBox
            Left = 8
            Top = 192
            Width = 353
            Height = 17
            Caption = 'Останавливать скрипт на неопознанной команде'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 1
          end
          object miPauseSOnClientClose: TCheckBox
            Left = 8
            Top = 208
            Width = 353
            Height = 17
            Caption = 'При закрытии клиента приостанавливать скрипт'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object miShowScriptProcessing: TCheckBox
            Left = 8
            Top = 16
            Width = 353
            Height = 17
            Caption = 'Отображать ход выполнения скрипта'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 3
          end
          object miShowSFNames: TCheckBox
            Left = 8
            Top = 32
            Width = 353
            Height = 17
            Caption = 'Отображать имена файлов скриптов'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 4
          end
          object miShowRuningScript: TCheckBox
            Left = 8
            Top = 64
            Width = 353
            Height = 17
            Caption = 'Отображать запущенные скрипты'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 5
            OnClick = miShowRuningScriptClick
          end
          object miKnopusechki_onoff: TCheckBox
            Left = 8
            Top = 96
            Width = 353
            Height = 17
            Caption = 'Отображать кнопки запуска\остановки скриптов'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 6
            OnClick = miShowRuningScriptClick
          end
          object miShowRemainingWait: TCheckBox
            Left = 8
            Top = 144
            Width = 353
            Height = 17
            Caption = 'Отображать оставшееся время ожидания'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 7
            OnClick = miShowRemainingWaitClick
          end
          object miGutterVisible: TCheckBox
            Left = 8
            Top = 128
            Width = 353
            Height = 17
            Caption = 'Отображать номера строк скрипта'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 8
            OnClick = miGutterVisibleClick
          end
          object miShowRuningScriptOnTaskbar: TCheckBox
            Left = 8
            Top = 80
            Width = 353
            Height = 17
            Caption = 'Отображать запущенные скрипты на панели задач'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 9
            OnClick = miShowRuningScriptOnTaskbarClick
          end
          object miShowCommandHint: TCheckBox
            Left = 8
            Top = 160
            Width = 353
            Height = 17
            Caption = 'Отображать подсказки для команд в скрипте'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 10
          end
          object cbShowScriptNamesOnTabs: TCheckBox
            Left = 8
            Top = 48
            Width = 353
            Height = 17
            Caption = 'Отображать имена скриптов на закладках'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 11
            OnClick = cbShowScriptNamesOnTabsClick
          end
          object cbShowUnsavedScripts: TCheckBox
            Left = 8
            Top = 112
            Width = 353
            Height = 17
            Caption = 'Отображать несохраненные скрипты'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 12
            OnClick = miShowRuningScriptClick
          end
          object cbCommentOnClick: TCheckBox
            Left = 104
            Top = 240
            Width = 121
            Height = 17
            Caption = 'при клике'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 13
          end
          object cbCommentOnSelect: TCheckBox
            Left = 232
            Top = 240
            Width = 129
            Height = 17
            Caption = 'при выделении'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 14
          end
          object CheckBox2: TCheckBox
            Left = 8
            Top = 224
            Width = 353
            Height = 17
            Caption = '-------------------'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 15
            Visible = False
          end
        end
      end
      object tsSWindows: TTabSheet
        Caption = 'Windows'
        ImageIndex = 2
        object N11: TGroupBox
          Left = 0
          Top = 0
          Width = 185
          Height = 131
          Caption = 'Располагать поверх всех окон...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object cbSOT: TCheckBox
            Left = 8
            Top = 16
            Width = 169
            Height = 17
            Caption = 'UoPilot'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
            OnClick = cbSOTClick
          end
          object miSOTShipControl: TCheckBox
            Left = 8
            Top = 32
            Width = 169
            Height = 17
            Caption = 'Ship Control'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 1
            OnClick = cbSOTClick
          end
          object miSOTHouseControl: TCheckBox
            Left = 8
            Top = 48
            Width = 169
            Height = 17
            Caption = 'House Control'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 2
            OnClick = cbSOTClick
          end
          object miSOTAnimalVendor: TCheckBox
            Left = 8
            Top = 64
            Width = 169
            Height = 17
            Caption = 'Animal && Vendor'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 3
            OnClick = cbSOTClick
          end
          object miSOTCharParameters: TCheckBox
            Left = 8
            Top = 80
            Width = 169
            Height = 17
            Caption = 'Char Parameters'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 4
            OnClick = cbSOTClick
          end
          object miSOTScriptWindow: TCheckBox
            Left = 8
            Top = 96
            Width = 169
            Height = 17
            Caption = 'Окно скрипта'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 5
            OnClick = cbSOTClick
          end
          object miSOTLogWindow: TCheckBox
            Left = 8
            Top = 112
            Width = 169
            Height = 17
            Caption = 'Log Window'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 6
            OnClick = cbSOTClick
          end
        end
        object N22: TGroupBox
          Left = 192
          Top = 0
          Width = 177
          Height = 129
          Caption = 'Запоминать положение окон...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          object miSPosUoP: TCheckBox
            Left = 8
            Top = 16
            Width = 165
            Height = 17
            Caption = 'UoPilot''a'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object miSPosS: TCheckBox
            Left = 8
            Top = 32
            Width = 165
            Height = 17
            Caption = 'Скрипта'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
          end
          object miSPosCP: TCheckBox
            Left = 8
            Top = 48
            Width = 165
            Height = 17
            Caption = 'Параметров чара'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object miSPosHC: TCheckBox
            Left = 8
            Top = 64
            Width = 165
            Height = 17
            Caption = 'Управления домом'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 3
          end
          object miSPosSC: TCheckBox
            Left = 8
            Top = 80
            Width = 165
            Height = 17
            Caption = 'Управления кораблем'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 4
          end
          object miSPosAC: TCheckBox
            Left = 8
            Top = 96
            Width = 165
            Height = 17
            Caption = 'Управления животными'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 5
          end
        end
        object N23: TGroupBox
          Left = 0
          Top = 136
          Width = 257
          Height = 61
          Caption = 'При запуске UoPilot''a открывать окна... '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          object miAutoOpenCP: TCheckBox
            Left = 8
            Top = 16
            Width = 180
            Height = 17
            Caption = 'Параметров чара'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
        end
        object N27: TGroupBox
          Left = 0
          Top = 204
          Width = 233
          Height = 73
          Caption = 'Сохранять скриншот...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          object miSaveScrActiweWindow: TRadioButton
            Left = 8
            Top = 16
            Width = 217
            Height = 17
            Caption = 'Aктивного окна'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object miSaveScrWorkWindow: TRadioButton
            Left = 8
            Top = 32
            Width = 217
            Height = 17
            Caption = 'Рабочего окна'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
          end
          object miSaveScrAllScreen: TRadioButton
            Left = 8
            Top = 48
            Width = 217
            Height = 17
            Caption = 'Всего экрана'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
            TabStop = True
          end
        end
      end
      object tsSMouse: TTabSheet
        Caption = 'Mouse'
        ImageIndex = 3
        object GroupBox4: TGroupBox
          Left = 0
          Top = 0
          Width = 369
          Height = 129
          Caption = 'Mouse'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object miMoveMouseBack: TCheckBox
            Left = 8
            Top = 64
            Width = 353
            Height = 17
            Caption = 'Возвращать курсор мыши после кликов'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object miMoveMouseBeforeClick: TCheckBox
            Left = 8
            Top = 48
            Width = 353
            Height = 17
            Caption = 'Перемещать курсор в точку клика'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
          end
          object miAMoveCount: TCheckBox
            Left = 8
            Top = 16
            Width = 353
            Height = 17
            Caption = 'Запоминать количество перетаскиваемых итемов'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object miUseNewClickMetod: TCheckBox
            Left = 8
            Top = 32
            Width = 353
            Height = 17
            Caption = 'UseNewClickMetod'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 3
          end
          object miUseKleft217: TCheckBox
            Left = 8
            Top = 80
            Width = 353
            Height = 17
            Caption = 'Использовать kleft v2.17'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 4
          end
        end
        object miShowCoords: TGroupBox
          Left = 0
          Top = 136
          Width = 257
          Height = 61
          Caption = 'Отображать координаты курсора'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          object miSKRel: TCheckBox
            Left = 8
            Top = 16
            Width = 180
            Height = 17
            Caption = 'Относительные'
            Checked = True
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            State = cbChecked
            TabOrder = 0
            OnClick = miSKRelClick
          end
          object miSKAbs: TCheckBox
            Left = 8
            Top = 32
            Width = 180
            Height = 17
            Caption = 'Абсолютные'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
            OnClick = miSKAbsClick
          end
        end
      end
      object tsSLogs: TTabSheet
        Caption = 'Logs'
        ImageIndex = 5
        object GroupBox1: TGroupBox
          Left = 0
          Top = 0
          Width = 369
          Height = 177
          Caption = 'Log'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object lLogfilesize: TLabel
            Left = 8
            Top = 128
            Width = 55
            Height = 13
            Caption = 'Log file size'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object miErrorLogging: TGroupBox
            Left = 8
            Top = 32
            Width = 193
            Height = 89
            Caption = 'Выводить в лог ошибки'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            object miELclrinvalid: TCheckBox
              Left = 8
              Top = 16
              Width = 180
              Height = 17
              Caption = 'Определения цвета'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 0
            end
            object miFileOpError: TCheckBox
              Left = 8
              Top = 32
              Width = 180
              Height = 17
              Caption = 'Файловых операций'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 1
            end
            object miSetHKError: TCheckBox
              Left = 8
              Top = 48
              Width = 180
              Height = 17
              Caption = 'Назначения горячих клавиш'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 2
            end
            object miPluginLoadError: TCheckBox
              Left = 8
              Top = 64
              Width = 180
              Height = 17
              Caption = 'Загрузки плагинов'
              Color = clBtnFace
              ParentColor = False
              TabOrder = 3
            end
          end
          object miLogging: TCheckBox
            Left = 208
            Top = 16
            Width = 159
            Height = 17
            Caption = 'Записывать лог в файл'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
          end
          object miAutoOpenLog: TCheckBox
            Left = 8
            Top = 16
            Width = 201
            Height = 17
            Caption = 'Автоматически открывать лог'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object gbOutputMessagesTo: TGroupBox
            Left = 208
            Top = 32
            Width = 153
            Height = 89
            Caption = 'Выводить сообщения в...'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 3
            object miToMessageBox: TRadioButton
              Left = 16
              Top = 16
              Width = 121
              Height = 17
              Caption = 'MessageBox'
              TabOrder = 0
            end
            object miToHint: TRadioButton
              Left = 16
              Top = 32
              Width = 121
              Height = 17
              Caption = 'Hint'
              TabOrder = 1
            end
            object miToLog: TCheckBox
              Left = 16
              Top = 68
              Width = 121
              Height = 17
              Caption = 'Log'
              TabOrder = 2
            end
            object miToDevnull: TRadioButton
              Left = 16
              Top = 48
              Width = 121
              Height = 17
              Caption = 'Dev/null'
              TabOrder = 3
            end
          end
          object seLogfilesize: TSpinEdit
            Left = 72
            Top = 124
            Width = 49
            Height = 22
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            MaxValue = 0
            MinValue = 0
            ParentFont = False
            TabOrder = 4
            Value = 0
            OnChange = seLogfilesizeChange
          end
          object CheckBox3: TCheckBox
            Left = 8
            Top = 152
            Width = 180
            Height = 17
            Caption = '-----------------'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 5
            Visible = False
          end
        end
      end
      object tsSMacro: TTabSheet
        Caption = 'Macro'
        ImageIndex = 6
        object miSpeed: TGroupBox
          Tag = 100
          Left = 0
          Top = 0
          Width = 241
          Height = 129
          Caption = 'Макрос'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Microsoft Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object lmSpeed: TLabel
            Left = 8
            Top = 16
            Width = 114
            Height = 13
            Alignment = taCenter
            Caption = 'Скорость (множитель)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lmRepeat: TLabel
            Left = 8
            Top = 88
            Width = 37
            Height = 13
            Alignment = taCenter
            Caption = 'Повтор'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object lmRepeatC: TLabel
            Left = 85
            Top = 104
            Width = 18
            Height = 13
            Caption = 'раз'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object Label2: TLabel
            Left = 10
            Top = 49
            Width = 216
            Height = 13
            Caption = '100 50 20 10  5  4  2  1  2  4  5  10 20 50 100'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object Label3: TLabel
            Left = 168
            Top = 64
            Width = 44
            Height = 13
            Alignment = taRightJustify
            Caption = 'Быстрее'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object Label5: TLabel
            Left = 24
            Top = 64
            Width = 57
            Height = 13
            Caption = 'Медленнее'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object tbmiSpeed: TTrackBar
            Left = 20
            Top = 33
            Width = 196
            Height = 17
            Hint = 'Приоритет для запускаемых клиентов'
            Max = 15
            Min = 1
            ParentShowHint = False
            PageSize = 1
            Position = 8
            ShowHint = True
            TabOrder = 0
            ThumbLength = 9
            OnChange = tbmiSpeedChange
          end
          object semiRepeat: TSpinEdit
            Left = 26
            Top = 104
            Width = 57
            Height = 22
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            MaxValue = 1000
            MinValue = 1
            ParentFont = False
            TabOrder = 1
            Value = 1
            OnChange = semiRepeatChange
          end
          object N20: TCheckBox
            Left = 138
            Top = 104
            Width = 89
            Height = 17
            Caption = 'Бесконечно'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            OnClick = N20Click
          end
        end
      end
      object tsSOther: TTabSheet
        Caption = 'Other'
        ImageIndex = 5
        object GroupBox5: TGroupBox
          Left = 0
          Top = 0
          Width = 369
          Height = 313
          TabOrder = 0
          object miLockOnStartup: TCheckBox
            Left = 8
            Top = 104
            Width = 353
            Height = 17
            Caption = 'Прикреплять все скрипты при старте UoPilot''a'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
          end
          object miMinToTray: TCheckBox
            Left = 8
            Top = 128
            Width = 353
            Height = 17
            Caption = 'Сворачивать UoPilot в трей'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
            OnClick = miMinToTrayClick
          end
          object miShowAllWindows: TCheckBox
            Left = 8
            Top = 160
            Width = 353
            Height = 17
            Caption = 'Показывать все окна'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
          end
          object miRenameSelf: TCheckBox
            Left = 8
            Top = 256
            Width = 353
            Height = 17
            Caption = 'Переименовывать пилот'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 3
            OnClick = miRenameSelfClick
          end
          object miTransparentHotKeys: TCheckBox
            Left = 8
            Top = 72
            Width = 353
            Height = 17
            Caption = '''Прозрачные'' хоткеи'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 4
            OnClick = miTransparentHotKeysClick
          end
          object miShowTimerVar: TCheckBox
            Left = 8
            Top = 32
            Width = 353
            Height = 17
            Caption = 'Отображать переменную timer'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 5
            OnClick = miShowTimerVarClick
          end
          object miShowHex: TCheckBox
            Left = 8
            Top = 48
            Width = 353
            Height = 17
            Caption = 'Отображать числа в hex формате'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 6
            OnClick = miShowHexClick
          end
          object miShowHelpOnTaskbar: TCheckBox
            Left = 8
            Top = 88
            Width = 353
            Height = 17
            Caption = 'Отображать окна справки на панели задач'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 7
            OnClick = miShowHelpOnTaskbarClick
          end
          object miSaveScriptsOnExit: TCheckBox
            Left = 8
            Top = 216
            Width = 353
            Height = 17
            Caption = 'Сохранять скрипты при выходе'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 9
          end
          object miSaveOnExit: TCheckBox
            Left = 8
            Top = 232
            Width = 353
            Height = 17
            Caption = 'Сохранять настройки при выходе'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 8
          end
          object miStartMinimized: TCheckBox
            Left = 8
            Top = 144
            Width = 353
            Height = 17
            Caption = 'Запускать свернутым'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 10
          end
          object cbHideUOSettings: TCheckBox
            Left = 8
            Top = 16
            Width = 353
            Height = 17
            Caption = 'Скрыть связанное с Ultima Online'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 11
            OnClick = cbHideUOSettingsClick
          end
          object miSaveScriptsOnRun: TCheckBox
            Left = 8
            Top = 200
            Width = 353
            Height = 17
            Caption = 'Сохранять скрипты перед запуском'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 12
          end
          object eRenameSelf: TEdit
            Left = 8
            Top = 280
            Width = 353
            Height = 21
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 13
          end
          object cbCheckGetImage: TCheckBox
            Left = 8
            Top = 176
            Width = 353
            Height = 17
            Caption = 'Check image capture by handle'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Microsoft Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 14
          end
        end
      end
    end
    object bOptionsClose: TButton
      Left = 296
      Top = 352
      Width = 75
      Height = 25
      Caption = 'Close'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Microsoft Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = bOptionsCloseClick
    end
  end
  object Panel30: TPanel
    Left = 8
    Top = 584
    Width = 230
    Height = 89
    TabOrder = 21
    Visible = False
    object sbAttriChangeApply: TSpeedButton
      Left = 180
      Top = 60
      Width = 41
      Height = 22
      Caption = 'Apply'
    end
    object sbSelectColorFront: TSpeedButton
      Left = 96
      Top = 20
      Width = 57
      Height = 22
      Caption = 'Color Front'
      OnClick = sbSelectColorFrontClick
    end
    object sbSelectColorBack: TSpeedButton
      Left = 160
      Top = 20
      Width = 57
      Height = 22
      Caption = 'Color Back'
      OnClick = sbSelectColorBackClick
    end
    object Label19: TLabel
      Left = 0
      Top = 0
      Width = 201
      Height = 13
      Caption = '<-- cllick on name to change font attributes'
    end
    object rbAttriN: TRadioButton
      Tag = 15
      Left = 0
      Top = 16
      Width = 65
      Height = 17
      Caption = 'normal'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbAttriI: TRadioButton
      Tag = 15
      Left = 0
      Top = 32
      Width = 65
      Height = 17
      Caption = 'italic'
      TabOrder = 1
    end
    object rbAttriBI: TRadioButton
      Tag = 15
      Left = 0
      Top = 48
      Width = 65
      Height = 17
      Caption = 'bold italic'
      TabOrder = 2
    end
    object rbAttriB: TRadioButton
      Tag = 15
      Left = 0
      Top = 64
      Width = 65
      Height = 17
      Caption = 'bold'
      TabOrder = 3
    end
    object cbAttriIU: TCheckBox
      Left = 72
      Top = 48
      Width = 65
      Height = 17
      Caption = 'underline'
      TabOrder = 4
    end
    object cbAttriIS: TCheckBox
      Left = 72
      Top = 64
      Width = 65
      Height = 17
      Caption = 'strikeout'
      TabOrder = 5
    end
  end
  object odLoad: TOpenDialog
    OnShow = odLoadShow
    DefaultExt = '.txt'
    Filter = 'Файлы скриптов (*.txt;*.scr;*.lua)|*.txt;*.scr;*.lua|Файлы макросов (*.mac)|*.mac|Все файлы (*.*)|*.*'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofPathMustExist, ofFileMustExist]
    Title = 'Сохранить скрипт как...'
    Left = 120
    Top = 296
  end
  object tm0: TTimer
    Enabled = False
    OnTimer = tm0Timer
    Left = 12
    Top = 376
  end
  object tm2: TTimer
    Tag = 2
    Enabled = False
    OnTimer = tm0Timer
    Left = 76
    Top = 376
  end
  object tm3: TTimer
    Tag = 3
    Enabled = False
    OnTimer = tm0Timer
    Left = 108
    Top = 376
  end
  object tm1: TTimer
    Tag = 1
    Enabled = False
    OnTimer = tm0Timer
    Left = 44
    Top = 376
  end
  object sdSave: TSaveDialog
    DefaultExt = '.txt'
    Filter = 'Файлы скриптов (*.txt;*.scr;*.lua)|*.txt;*.scr;*.lua|Файлы макросов (*.mac)|*.mac|Все файлы (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Left = 144
    Top = 296
  end
  object tm4: TTimer
    Tag = 4
    Enabled = False
    OnTimer = tm0Timer
    Left = 140
    Top = 376
  end
  object tm5: TTimer
    Tag = 5
    Enabled = False
    OnTimer = tm0Timer
    Left = 172
    Top = 376
  end
  object TBudilnik: TTimer
    Enabled = False
    OnTimer = TBudilnikTimer
    Left = 308
    Top = 40
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 308
    Top = 64
  end
  object tShowCoordsOnCap: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tShowCoordsOnCapTimer
    Left = 32
    Top = 328
  end
  object tHintTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tHintTimerTimer
    Left = 64
    Top = 328
  end
  object pmCopyLM: TPopupMenu
    Left = 40
    Top = 296
    object miCopyLM: TMenuItem
      Caption = 'Копировать'
      OnClick = miComClick
    end
  end
  object mnHotKey: TMainMenu
    AutoHotkeys = maManual
    Left = 144
    Top = 328
    object ddd1: TMenuItem
      Caption = 'Скрипт'
      object miNew: TMenuItem
        Caption = 'Новый'
        OnClick = miNewClick
      end
      object N15: TMenuItem
        Caption = '-'
      end
      object miOpen: TMenuItem
        Caption = 'Открыть'
        OnClick = btLoadClick
      end
      object miReOpen: TMenuItem
        Caption = 'Открыть последние ...'
      end
      object miProcOpen: TMenuItem
        Caption = 'Открыть файл процедур'
        OnClick = miProcOpenClick
      end
      object miSave: TMenuItem
        Caption = 'Сохранить'
        OnClick = miSaveClick
      end
      object miSaveAs: TMenuItem
        Caption = 'Сохранить как...'
        OnClick = btSaveClick
      end
      object miFormat: TMenuItem
        Caption = 'Форматировать'
        OnClick = miFormatClick
      end
      object miUnFormat: TMenuItem
        Caption = 'Убрать форматирование'
        OnClick = miUnFormatClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object miStartStopCurrentScript: TMenuItem
        Caption = 'Запустить\остановить текущий скрипт'
        OnClick = miStartStopCurrentScriptClick
      end
      object miPauseCurrentScript: TMenuItem
        Caption = 'Приостановить\продолжить текущий'
        OnClick = miPauseCurrentScriptClick
      end
      object miPauseAllScript: TMenuItem
        Caption = 'Приостановить все скрипты'
        OnClick = miPauseAllScriptClick
      end
      object N29: TMenuItem
        Caption = '-'
      end
      object miExit: TMenuItem
        Caption = 'Выход'
        OnClick = miExitClick
      end
      object miExitWoSave: TMenuItem
        Caption = 'Выход без сохранения'
        OnClick = miExitClick
      end
    end
    object nxxx: TMenuItem
      Caption = 'Макрос'
      object miLMkeymouse: TMenuItem
        Caption = 'Загрузить'
        OnClick = miLMkeymouseClick
      end
      object miSMkeymouse: TMenuItem
        Caption = 'Сохранить'
        OnClick = miSMkeymouseClick
      end
      object N13: TMenuItem
        Caption = '-'
      end
      object miRec: TMenuItem
        Caption = 'Запись '
        OnClick = HotKeyRec
      end
      object miStopRec: TMenuItem
        Caption = 'Стоп '
        OnClick = HotKeyRecStop
      end
      object miPlay: TMenuItem
        Caption = 'Воспроизвести '
        OnClick = HotKeyPlay
      end
    end
    object miCtrlB: TMenuItem
      Caption = 'Ctrl+B'
      ShortCut = 16450
      Visible = False
      OnClick = miCtrlBClick
    end
    object miCtrlA: TMenuItem
      Caption = 'Ctrl+A'
      ShortCut = 16449
      Visible = False
      OnClick = SetCoord
    end
    object N8: TMenuItem
      Caption = 'Настройки'
      object miLang: TMenuItem
        Caption = 'Language'
        object miLangDefault: TMenuItem
          Caption = 'Default'
          Checked = True
          RadioItem = True
          OnClick = miLangSelect
        end
        object miLangRus: TMenuItem
          Tag = 25
          Caption = 'Russian'
          RadioItem = True
          OnClick = miLangSelect
        end
        object miLangEng: TMenuItem
          Tag = 9
          Caption = 'English'
          RadioItem = True
          OnClick = miLangSelect
        end
        object miLangPor: TMenuItem
          Tag = 22
          Caption = 'Portuguese'
          RadioItem = True
          OnClick = miLangSelect
        end
        object miLangBy: TMenuItem
          Tag = 35
          Caption = 'Belarus'
          RadioItem = True
          OnClick = miLangSelect
        end
        object miLangUkr: TMenuItem
          Tag = 34
          Caption = 'Ukrainian'
          RadioItem = True
          OnClick = miLangSelect
        end
        object miLangGer: TMenuItem
          Tag = 7
          Caption = 'German'
          RadioItem = True
          OnClick = miLangSelect
        end
        object test1: TMenuItem
          Tag = 100
          Caption = 'test'
          OnClick = miLangSelect
        end
      end
      object miScriptFontSelect: TMenuItem
        Caption = 'Выбрать шрифт редактора'
        OnClick = miScriptFontSelectClick
      end
      object miLogFontSelect: TMenuItem
        Caption = 'Выбрать шрифт лога'
        OnClick = miScriptFontSelectClick
      end
      object miAttriChange: TMenuItem
        Caption = 'Подсветка синтаксиса'
        OnClick = miAttriChangeClick
      end
      object miEditHotKeys: TMenuItem
        Caption = 'Edit HotKeys'
        OnClick = sbEditHKClick
      end
      object miOptions: TMenuItem
        Caption = 'Настройки'
        OnClick = miOptionsClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object miSaveOptions: TMenuItem
        Caption = 'Сохранить настройки'
        OnClick = miSaveOptionsClick
      end
      object miSaveOptionsAs: TMenuItem
        Caption = 'Сохранить настройки как...'
        OnClick = miSaveOptionsAsClick
      end
      object miLoadOptionsAs: TMenuItem
        Caption = 'Загрузить настройки...'
        OnClick = miLoadOptionsAsClick
      end
      object miSaveScriptTemplate: TMenuItem
        Caption = 'Сохранить шаблон скрипта'
        OnClick = miSaveScriptTemplateClick
      end
      object miSaveMacros: TMenuItem
        Caption = 'Сохранить макросы сообщений'
        OnClick = miSaveMacrosClick
      end
    end
    object r1: TMenuItem
      Caption = 'Справка'
      object miUOPilotWiki: TMenuItem
        Caption = 'UOPilot Wiki'
        OnClick = miUOPilotWikiClick
      end
      object mmHelp: TMenuItem
        Caption = 'История развития программы'
        Enabled = False
        Visible = False
        OnClick = mmHelpClick
      end
      object miScriptHelp: TMenuItem
        Caption = 'Справка'
        OnClick = miScriptHelpClick
      end
      object miPluginSample: TMenuItem
        Caption = 'Пример плагина'
        OnClick = miPluginSampleClick
      end
      object miAbout: TMenuItem
        Caption = 'О программе...'
        OnClick = miAboutClick
      end
    end
  end
  object mnCom: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = mnComPopup
    Left = 176
    Top = 328
    object miCut: TMenuItem
      Caption = 'Вырезать'
      OnClick = miComClick
    end
    object miCopy: TMenuItem
      Caption = 'Копировать'
      OnClick = miComClick
    end
    object miPaste: TMenuItem
      Caption = 'Вставить'
      OnClick = miComClick
    end
    object miUndo: TMenuItem
      Caption = 'Отменить'
      OnClick = miComClick
    end
    object miWikiHelp: TMenuItem
      Visible = False
      OnClick = miWikiHelpClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object miUltimaOnline: TMenuItem
      Caption = 'Ultima Online'
      object mi2: TMenuItem
        Caption = 'Параметры чара'
        object mi21: TMenuItem
          Caption = 'Name'
          OnClick = miComClick
        end
        object mi22: TMenuItem
          Caption = 'Str'
          OnClick = miComClick
        end
        object mi23: TMenuItem
          Caption = 'Int'
          OnClick = miComClick
        end
        object mi24: TMenuItem
          Caption = 'Dex'
          OnClick = miComClick
        end
        object MenuItem1: TMenuItem
          Caption = 'Hits'
          OnClick = miComClick
        end
        object mi26: TMenuItem
          Caption = 'Mana'
          OnClick = miComClick
        end
        object mi27: TMenuItem
          Caption = 'Stam'
          OnClick = miComClick
        end
        object mi28: TMenuItem
          Caption = 'Gold'
          OnClick = miComClick
        end
        object mi29: TMenuItem
          Caption = 'Wght'
          OnClick = miComClick
        end
        object mi210: TMenuItem
          Caption = 'Armor'
          OnClick = miComClick
        end
        object mi211: TMenuItem
          Caption = 'CharposX'
          OnClick = miComClick
        end
        object mi212: TMenuItem
          Caption = 'CharposY'
          OnClick = miComClick
        end
        object mi213: TMenuItem
          Caption = 'CharposZ'
          OnClick = miComClick
        end
        object mi214: TMenuItem
          Caption = 'CharDir'
          OnClick = miComClick
        end
        object mi215: TMenuItem
          Caption = 'LastMsg'
          OnClick = miComClick
        end
        object war1: TMenuItem
          Caption = 'war'
          OnClick = miComClick
        end
        object hidden1: TMenuItem
          Caption = 'hidden'
          OnClick = miComClick
        end
        object arun1: TMenuItem
          Caption = 'arun'
          OnClick = miComClick
        end
        object skillsnumber1: TMenuItem
          Caption = 'skills <number>'
          OnClick = miComClick
        end
        object spellnamenember1: TMenuItem
          Caption = 'spellname <number>'
          OnClick = miComClick
        end
        object fontcolor1: TMenuItem
          Caption = 'fontcolor <number>'
          OnClick = miComClick
        end
        object miPsysresist: TMenuItem
          Caption = 'psysresist'
          OnClick = miComClick
        end
        object miFireresist: TMenuItem
          Caption = 'fireresist'
          OnClick = miComClick
        end
        object miColdresist: TMenuItem
          Caption = 'coldresist'
          OnClick = miComClick
        end
        object miPoisresist: TMenuItem
          Caption = 'poisresist'
          OnClick = miComClick
        end
        object miEnerresist: TMenuItem
          Caption = 'enerresist'
          OnClick = miComClick
        end
        object miLuck: TMenuItem
          Caption = 'luck'
          OnClick = miComClick
        end
        object miDamage: TMenuItem
          Caption = 'damage'
          OnClick = miComClick
        end
        object miHitsmax: TMenuItem
          Caption = 'hitsmax'
          OnClick = miComClick
        end
        object miManamax: TMenuItem
          Caption = 'manamax'
          OnClick = miComClick
        end
        object miStammax: TMenuItem
          Caption = 'stammax'
          OnClick = miComClick
        end
        object miWghtmax: TMenuItem
          Caption = 'wghtmax'
          OnClick = miComClick
        end
        object miDamagemax: TMenuItem
          Caption = 'damagemax'
          OnClick = miComClick
        end
        object miFollowers: TMenuItem
          Caption = 'followers'
          OnClick = miComClick
        end
        object miFollowersmax: TMenuItem
          Caption = 'followersmax'
          OnClick = miComClick
        end
      end
      object mi3: TMenuItem
        Caption = 'Последние объекты'
        object mi31: TMenuItem
          Caption = 'LastObjectID'
          OnClick = miComClick
        end
        object mi32: TMenuItem
          Caption = 'LastObjectType'
          OnClick = miComClick
        end
        object mi33: TMenuItem
          Caption = 'LastTargetID'
          OnClick = miComClick
        end
        object mi34: TMenuItem
          Caption = 'LastTargetX'
          OnClick = miComClick
        end
        object mi35: TMenuItem
          Caption = 'LastTargetY'
          OnClick = miComClick
        end
        object mi36: TMenuItem
          Caption = 'LastTargetZ'
          OnClick = miComClick
        end
        object mi37: TMenuItem
          Caption = 'LastTargetKind'
          OnClick = miComClick
        end
        object mi38: TMenuItem
          Caption = 'LastLiftedID'
          OnClick = miComClick
        end
        object mi39: TMenuItem
          Caption = 'LastSkill'
          OnClick = miComClick
        end
        object mi310: TMenuItem
          Caption = 'LastSpell'
          OnClick = miComClick
        end
        object mi311: TMenuItem
          Caption = 'LastStaticType'
          OnClick = miComClick
        end
      end
      object N7: TMenuItem
        Caption = 'Настройки клиента'
        object miCriminalactions: TMenuItem
          Caption = 'criminalactions'
          OnClick = miComClick
        end
        object miPathfinding: TMenuItem
          Caption = 'pathfinding'
          OnClick = miComClick
        end
        object miShownames: TMenuItem
          Caption = 'shownames'
          OnClick = miComClick
        end
        object miTransparency: TMenuItem
          Caption = 'transparency'
          OnClick = miComClick
        end
      end
      object mi4: TMenuItem
        Caption = 'Target'
        OnClick = miComClick
      end
      object EasyUOnvar1: TMenuItem
        Caption = 'EasyUO*n $var'
        OnClick = miComClick
      end
      object miWaitfortarget: TMenuItem
        Caption = 'waitfortarget [wait time]'
        OnClick = miComClick
      end
      object miInjection: TMenuItem
        Caption = 'injection <команда> [; команда...]'
        OnClick = miComClick
      end
      object setarrbackpack1: TMenuItem
        Caption = 'set %arr backpack'
        OnClick = miComClick
      end
    end
    object miVariables: TMenuItem
      Caption = 'Переменные'
      object mi1: TMenuItem
        Caption = 'Время'
        object mi11: TMenuItem
          Caption = 'Hour'
          OnClick = miComClick
        end
        object mi12: TMenuItem
          Caption = 'Min'
          OnClick = miComClick
        end
        object mi13: TMenuItem
          Caption = 'Sec'
          OnClick = miComClick
        end
        object miye: TMenuItem
          Caption = 'Year'
          OnClick = miComClick
        end
        object mimo: TMenuItem
          Caption = 'Month'
          OnClick = miComClick
        end
        object mida: TMenuItem
          Caption = 'Day'
          OnClick = miComClick
        end
        object miDayofweek: TMenuItem
          Caption = 'dayofweek (Year Month Day)'
          OnClick = miComClick
        end
        object mi14: TMenuItem
          Caption = 'Timer'
          OnClick = miComClick
        end
        object mi15: TMenuItem
          Caption = 'Timer1'
          OnClick = miComClick
        end
        object mi16: TMenuItem
          Caption = 'Timer2'
          OnClick = miComClick
        end
        object mi17: TMenuItem
          Caption = 'Timer3'
          OnClick = miComClick
        end
        object mi18: TMenuItem
          Caption = 'Timer4'
          OnClick = miComClick
        end
      end
      object micoco: TMenuItem
        Caption = 'Цвет, координаты, экран'
        object midefX: TMenuItem
          Caption = 'defX'
          OnClick = miComClick
        end
        object midefY: TMenuItem
          Caption = 'defY'
          OnClick = miComClick
        end
        object midefXabs: TMenuItem
          Caption = 'defXabs'
          OnClick = miComClick
        end
        object midefYabs: TMenuItem
          Caption = 'defYabs'
          OnClick = miComClick
        end
        object midefColor: TMenuItem
          Caption = 'defColor'
          OnClick = miComClick
        end
        object miMouseposx1: TMenuItem
          Caption = 'mousepos_x'
          OnClick = miComClick
        end
        object miMouseposy1: TMenuItem
          Caption = 'mousepos_y'
          OnClick = miComClick
        end
        object miMouseposabsx1: TMenuItem
          Caption = 'mouseposabs_x'
          OnClick = miComClick
        end
        object miMouseposabs_y1: TMenuItem
          Caption = 'mouseposabs_y'
          OnClick = miComClick
        end
        object miscreenheight: TMenuItem
          Caption = 'screenheight'
          OnClick = miComClick
        end
        object miscreenwidth: TMenuItem
          Caption = 'screenwidth'
          OnClick = miComClick
        end
        object midesktopheight: TMenuItem
          Caption = 'desktopheight'
          OnClick = miComClick
        end
        object midesktopwidth: TMenuItem
          Caption = 'desktopwidth'
          OnClick = miComClick
        end
        object mimonitorheight: TMenuItem
          Caption = 'monitorheight'
          OnClick = miComClick
        end
        object mimonitorwidth: TMenuItem
          Caption = 'monitorwidth'
          OnClick = miComClick
        end
        object mimonitor: TMenuItem
          Caption = 'monitor'
          OnClick = miComClick
        end
        object miFindoffsetx: TMenuItem
          Caption = 'findoffsetx'
          OnClick = miComClick
        end
        object miFindoffsety: TMenuItem
          Caption = 'findoffsety'
          OnClick = miComClick
        end
        object miClickoffsetx: TMenuItem
          Caption = 'clickoffsetx'
          OnClick = miComClick
        end
        object miClickoffsety: TMenuItem
          Caption = 'clickoffsety'
          OnClick = miComClick
        end
        object miPromptposx: TMenuItem
          Caption = 'promptpos_x'
          OnClick = miComClick
        end
        object miPromptposy: TMenuItem
          Caption = 'promptpos_y'
          OnClick = miComClick
        end
      end
      object micocos: TMenuItem
        Caption = 'Цвета'
        object claqua1: TMenuItem
          Caption = 'claqua'
          OnClick = miComClick
        end
        object clblack1: TMenuItem
          Caption = 'clblack'
          OnClick = miComClick
        end
        object clblue1: TMenuItem
          Caption = 'clblue'
          OnClick = miComClick
        end
        object clfuchsia1: TMenuItem
          Caption = 'clfuchsia'
          OnClick = miComClick
        end
        object clgreen1: TMenuItem
          Caption = 'clgreen'
          OnClick = miComClick
        end
        object cllime1: TMenuItem
          Caption = 'cllime'
          OnClick = miComClick
        end
        object clmaroon1: TMenuItem
          Caption = 'clmaroon'
          OnClick = miComClick
        end
        object clnavy1: TMenuItem
          Caption = 'clnavy'
          OnClick = miComClick
        end
        object clolive1: TMenuItem
          Caption = 'clolive'
          OnClick = miComClick
        end
        object clpurple1: TMenuItem
          Caption = 'clpurple'
          OnClick = miComClick
        end
        object clred1: TMenuItem
          Caption = 'clred'
          OnClick = miComClick
        end
        object clsilver1: TMenuItem
          Caption = 'clsilver'
          OnClick = miComClick
        end
        object clteal1: TMenuItem
          Caption = 'clteal'
          OnClick = miComClick
        end
        object clwhite1: TMenuItem
          Caption = 'clwhite'
          OnClick = miComClick
        end
        object clyellow1: TMenuItem
          Caption = 'clyellow'
          OnClick = miComClick
        end
        object clgray1: TMenuItem
          Caption = 'clgray'
          OnClick = miComClick
        end
        object clltgray1: TMenuItem
          Caption = 'clltgray'
          OnClick = miComClick
        end
        object cldkgray1: TMenuItem
          Caption = 'cldkgray'
          OnClick = miComClick
        end
      end
      object delimiter1: TMenuItem
        Caption = 'delimiter'
        OnClick = miComClick
      end
      object linedelay1: TMenuItem
        Caption = 'linedelay'
        OnClick = miComClick
      end
      object miEmptylinedelay: TMenuItem
        Caption = 'EmptyLineDelay'
        OnClick = miComClick
      end
      object miSendexdelay: TMenuItem
        Caption = 'SendExDelay'
        OnClick = miComClick
      end
      object miMouseclickdelay: TMenuItem
        Caption = 'MouseClickDelay'
        OnClick = miComClick
      end
      object miShowtimervar1: TMenuItem
        Caption = 'ShowTimerVar'
        OnClick = miComClick
      end
      object miShowscriptprocessing1: TMenuItem
        Caption = 'ShowScriptProcessing'
        OnClick = miComClick
      end
      object miStopscrunknowncommand1: TMenuItem
        Caption = 'StopScrUnknownCommand'
        OnClick = miComClick
      end
      object miWindowHandle: TMenuItem
        Caption = 'WindowHandle'
        OnClick = miComClick
      end
      object miExeFileName: TMenuItem
        Caption = 'ExeFileName'
        OnClick = miComClick
      end
      object miHomePath: TMenuItem
        Caption = 'HomePath'
        OnClick = miComClick
      end
      object miLoghandle: TMenuItem
        Caption = 'loghandle'
        OnClick = miComClick
      end
      object miLogautoopen: TMenuItem
        Caption = 'logautoopen'
        OnClick = miComClick
      end
      object miMessagesoutputto: TMenuItem
        Caption = 'messagesoutputto'
        OnClick = miComClick
      end
      object miscriptPath: TMenuItem
        Caption = 'scriptPath'
        OnClick = miComClick
      end
      object miscriptName: TMenuItem
        Caption = 'scriptName'
        OnClick = miComClick
      end
    end
    object miFunctions: TMenuItem
      Caption = 'Функции'
      Visible = False
    end
    object miLua: TMenuItem
      Caption = 'Lua'
      object miBasic: TMenuItem
        Caption = 'Basic Functions'
        object miAssert: TMenuItem
          Caption = 'assert (v [, message])'
          OnClick = miComClick
        end
        object miCollectgarbage: TMenuItem
          Caption = 'collectgarbage ([opt [, arg]])'
          OnClick = miComClick
        end
        object miDofile: TMenuItem
          Caption = 'dofile ([filename])'
          OnClick = miComClick
        end
        object miError: TMenuItem
          Caption = 'error (message [, level])'
          OnClick = miComClick
        end
        object miGetfenv: TMenuItem
          Caption = 'getfenv ([f])'
          OnClick = miComClick
        end
        object miIpairs: TMenuItem
          Caption = 'ipairs (t)'
          OnClick = miComClick
        end
        object miLoad: TMenuItem
          Caption = 'load (func [, chunkname])'
          OnClick = miComClick
        end
        object miLoadfile: TMenuItem
          Caption = 'loadfile ([filename])'
          OnClick = miComClick
        end
        object miLoadstring: TMenuItem
          Caption = 'loadstring (string [, chunkname])'
          OnClick = miComClick
        end
        object miNext: TMenuItem
          Caption = 'next (table [, index])'
          OnClick = miComClick
        end
        object miPairs: TMenuItem
          Caption = 'pairs (t)'
          OnClick = miComClick
        end
        object miPcall: TMenuItem
          Caption = 'pcall (f, arg1, ...)'
          OnClick = miComClick
        end
        object miPrint: TMenuItem
          Caption = 'print (...)'
          OnClick = miComClick
        end
        object miRawequal: TMenuItem
          Caption = 'rawequal (v1, v2)'
          OnClick = miComClick
        end
        object miRawget: TMenuItem
          Caption = 'rawget (table, index)'
          OnClick = miComClick
        end
        object miRawset: TMenuItem
          Caption = 'rawset (table, index, value)'
          OnClick = miComClick
        end
        object miSelect: TMenuItem
          Caption = 'select (index, ...)'
          OnClick = miComClick
        end
        object miSetfenv: TMenuItem
          Caption = 'setfenv (f, table)'
          OnClick = miComClick
        end
        object miSetmetatable: TMenuItem
          Caption = 'setmetatable (table, metatable)'
          OnClick = miComClick
        end
        object miTonumber: TMenuItem
          Caption = 'tonumber (e [, base])'
          OnClick = miComClick
        end
        object miTostring: TMenuItem
          Caption = 'tostring (e)'
          OnClick = miComClick
        end
        object miType: TMenuItem
          Caption = 'type (v)'
          OnClick = miComClick
        end
        object miUnpack: TMenuItem
          Caption = 'unpack (list [, i [, j]])'
          OnClick = miComClick
        end
        object miXpcall: TMenuItem
          Caption = 'xpcall (f, err)'
          OnClick = miComClick
        end
      end
      object miCoroutine: TMenuItem
        Caption = 'Coroutine Manipulation'
        object miCoroutineCreate: TMenuItem
          Caption = 'coroutine.create (f)'
          OnClick = miComClick
        end
        object miCoroutineResume: TMenuItem
          Caption = 'coroutine.resume (co [, val1, ...])'
          OnClick = miComClick
        end
        object miCoroutineRunning: TMenuItem
          Caption = 'coroutine.running ()'
          OnClick = miComClick
        end
        object miCoroutineStatus: TMenuItem
          Caption = 'coroutine.status (co)'
          OnClick = miComClick
        end
        object miCoroutineWrap: TMenuItem
          Caption = 'coroutine.wrap (f)'
          OnClick = miComClick
        end
        object miCoroutineYield: TMenuItem
          Caption = 'coroutine.yield (...)'
          OnClick = miComClick
        end
      end
      object miModules: TMenuItem
        Caption = 'Modules'
        object miModule: TMenuItem
          Caption = 'module (name [, ...])'
          OnClick = miComClick
        end
        object miRequire: TMenuItem
          Caption = 'require (modname)'
          OnClick = miComClick
        end
        object miPackageCpath: TMenuItem
          Caption = 'package.cpath'
          OnClick = miComClick
        end
        object miPackageLoaded: TMenuItem
          Caption = 'package.loaded'
          OnClick = miComClick
        end
        object miPackageLoaders: TMenuItem
          Caption = 'package.loaders'
          OnClick = miComClick
        end
        object miPackageLoadlib: TMenuItem
          Caption = 'package.loadlib (libname, funcname)'
          OnClick = miComClick
        end
        object miPackagePath: TMenuItem
          Caption = 'package.path'
          OnClick = miComClick
        end
        object miPackagePreload: TMenuItem
          Caption = 'package.preload'
          OnClick = miComClick
        end
        object miPackageSeeall: TMenuItem
          Caption = 'package.seeall (module)'
          OnClick = miComClick
        end
      end
      object miStringManipulation: TMenuItem
        Caption = 'String Manipulation'
        object miStringByte: TMenuItem
          Caption = 'string.byte (s [, i [, j]])'
          OnClick = miComClick
        end
        object miStringChar: TMenuItem
          Caption = 'string.char (...)'
          OnClick = miComClick
        end
        object miStringDump: TMenuItem
          Caption = 'string.dump (function)'
          OnClick = miComClick
        end
        object miStringFind: TMenuItem
          Caption = 'string.find (s, pattern [, init [, plain]])'
          OnClick = miComClick
        end
        object miStringFormat: TMenuItem
          Caption = 'string.format (formatstring, ...)'
          OnClick = miComClick
        end
        object miStringGmatch: TMenuItem
          Caption = 'string.gmatch (s, pattern)'
          OnClick = miComClick
        end
        object miStringGsub: TMenuItem
          Caption = 'string.gsub (s, pattern, repl [, n])'
          OnClick = miComClick
        end
        object miStringLen: TMenuItem
          Caption = 'string.len (s)'
          OnClick = miComClick
        end
        object miStringLowerLua: TMenuItem
          Caption = 'string.lower (s)'
          OnClick = miComClick
        end
        object miStringMatch: TMenuItem
          Caption = 'string.match (s, pattern [, init])'
          OnClick = miComClick
        end
        object miStringRep: TMenuItem
          Caption = 'string.rep (s, n)'
          OnClick = miComClick
        end
        object miStringReverse: TMenuItem
          Caption = 'string.reverse (s)'
          OnClick = miComClick
        end
        object miStringSub: TMenuItem
          Caption = 'string.sub (s, i [, j])'
          OnClick = miComClick
        end
        object miStringUpperLua: TMenuItem
          Caption = 'string.upper (s)'
          OnClick = miComClick
        end
      end
      object miTableManipulation: TMenuItem
        Caption = 'Table Manipulation'
        object miTableConcat: TMenuItem
          Caption = 'table.concat (table [, sep [, i [, j]]])'
          OnClick = miComClick
        end
        object miTableInsert: TMenuItem
          Caption = 'table.insert (table, [pos,] value)'
          OnClick = miComClick
        end
        object miTableMaxn: TMenuItem
          Caption = 'table.maxn (table)'
          OnClick = miComClick
        end
        object miTableRemove: TMenuItem
          Caption = 'table.remove (table [, pos])'
          OnClick = miComClick
        end
        object miTableSort: TMenuItem
          Caption = 'table.sort (table [, comp])'
          OnClick = miComClick
        end
      end
      object miMathematicalFunctions: TMenuItem
        Caption = 'Mathematical Functions'
        object miMathAbs: TMenuItem
          Caption = 'math.abs (x)'
          OnClick = miComClick
        end
        object miMathAcos: TMenuItem
          Caption = 'math.acos (x)'
          OnClick = miComClick
        end
        object miMathAsin: TMenuItem
          Caption = 'math.asin (x)'
          OnClick = miComClick
        end
        object miMathAtan: TMenuItem
          Caption = 'math.atan (x)'
          OnClick = miComClick
        end
        object miMathAtan2: TMenuItem
          Caption = 'math.atan2 (y, x)'
          OnClick = miComClick
        end
        object miMathCeil: TMenuItem
          Caption = 'math.ceil (x)'
          OnClick = miComClick
        end
        object miMathCos: TMenuItem
          Caption = 'math.cos (x)'
          OnClick = miComClick
        end
        object miMathCosh: TMenuItem
          Caption = 'math.cosh (x)'
          OnClick = miComClick
        end
        object miMathDeg: TMenuItem
          Caption = 'math.deg (x)'
          OnClick = miComClick
        end
        object miMathExp: TMenuItem
          Caption = 'math.exp (x)'
          OnClick = miComClick
        end
        object miMathFloor: TMenuItem
          Caption = 'math.floor (x)'
          OnClick = miComClick
        end
        object miMathFmod: TMenuItem
          Caption = 'math.fmod (x, y)'
          OnClick = miComClick
        end
        object miMathFrexp: TMenuItem
          Caption = 'math.frexp (x)'
          OnClick = miComClick
        end
        object miMathHuge: TMenuItem
          Caption = 'math.huge'
          OnClick = miComClick
        end
        object miMathLdexp: TMenuItem
          Caption = 'math.ldexp (m, e)'
          OnClick = miComClick
        end
        object miMathLog: TMenuItem
          Caption = 'math.log (x)'
          OnClick = miComClick
        end
        object miMathLog10: TMenuItem
          Caption = 'math.log10 (x)'
          OnClick = miComClick
        end
        object miMathMax: TMenuItem
          Caption = 'math.max (x, ...)'
          OnClick = miComClick
        end
        object miMathMin: TMenuItem
          Caption = 'math.min (x, ...)'
          OnClick = miComClick
        end
        object miMathModf: TMenuItem
          Caption = 'math.modf (x)'
          OnClick = miComClick
        end
        object miMathPi: TMenuItem
          Caption = 'math.pi'
          OnClick = miComClick
        end
        object miMathPow: TMenuItem
          Caption = 'math.pow (x, y)'
          OnClick = miComClick
        end
        object miMathRad: TMenuItem
          Caption = 'math.rad (x)'
          OnClick = miComClick
        end
        object miMathRandom: TMenuItem
          Caption = 'math.random ([m [, n]])'
          OnClick = miComClick
        end
        object miMathRandomseed: TMenuItem
          Caption = 'math.randomseed (x)'
          OnClick = miComClick
        end
        object miMathSin: TMenuItem
          Caption = 'math.sin (x)'
          OnClick = miComClick
        end
        object miMathSinh: TMenuItem
          Caption = 'math.sinh (x)'
          OnClick = miComClick
        end
        object miMathSqrt: TMenuItem
          Caption = 'math.sqrt (x)'
          OnClick = miComClick
        end
        object miMathTan: TMenuItem
          Caption = 'math.tan (x)'
          OnClick = miComClick
        end
        object miMathTanh: TMenuItem
          Caption = 'math.tanh (x)'
          OnClick = miComClick
        end
      end
      object miInputandOutput: TMenuItem
        Caption = 'Input and Output Facilities'
        object miIoClose: TMenuItem
          Caption = 'io.close ([file])'
          OnClick = miComClick
        end
        object miIoFlush: TMenuItem
          Caption = 'io.flush ()'
          OnClick = miComClick
        end
        object miIoInput: TMenuItem
          Caption = 'io.input ([file])'
          OnClick = miComClick
        end
        object miIoLines: TMenuItem
          Caption = 'io.lines ([filename])'
          OnClick = miComClick
        end
        object miIoOpen: TMenuItem
          Caption = 'io.open (filename [, mode])'
          OnClick = miComClick
        end
        object miIoOutput: TMenuItem
          Caption = 'io.output ([file])'
          OnClick = miComClick
        end
        object miIoPopen: TMenuItem
          Caption = 'io.popen (prog [, mode])'
          OnClick = miComClick
        end
        object miIoRead: TMenuItem
          Caption = 'io.read (...)'
          OnClick = miComClick
        end
        object miIoTmpfile: TMenuItem
          Caption = 'io.tmpfile ()'
          OnClick = miComClick
        end
        object miIoType: TMenuItem
          Caption = 'io.type (obj)'
          OnClick = miComClick
        end
        object miIoWrite: TMenuItem
          Caption = 'io.write (...)'
          OnClick = miComClick
        end
        object miFileClose: TMenuItem
          Caption = 'file:close ()'
          OnClick = miComClick
        end
        object miFileFlush: TMenuItem
          Caption = 'file:flush ()'
          OnClick = miComClick
        end
        object miFileLines: TMenuItem
          Caption = 'file:lines ()'
          OnClick = miComClick
        end
        object miFileRead: TMenuItem
          Caption = 'file:read (...)'
          OnClick = miComClick
        end
        object miFileSeek: TMenuItem
          Caption = 'file:seek ([whence] [, offset])'
          OnClick = miComClick
        end
        object miFileSetvbuf: TMenuItem
          Caption = 'file:setvbuf (mode [, size])'
          OnClick = miComClick
        end
        object miFileWrite: TMenuItem
          Caption = 'file:write (...)'
          OnClick = miComClick
        end
      end
      object miOperatingSystem: TMenuItem
        Caption = 'Operating System Facilities'
        object miOsClock: TMenuItem
          Caption = 'os.clock ()'
          OnClick = miComClick
        end
        object miOsDate: TMenuItem
          Caption = 'os.date ([format [, time]])'
          OnClick = miComClick
        end
        object miOsDifftime: TMenuItem
          Caption = 'os.difftime (t2, t1)'
          OnClick = miComClick
        end
        object miOsExecute: TMenuItem
          Caption = 'os.execute ([command])'
          OnClick = miComClick
        end
        object miOsExit: TMenuItem
          Caption = 'os.exit ([code])'
          OnClick = miComClick
        end
        object miOsGetenv: TMenuItem
          Caption = 'os.getenv (varname)'
          OnClick = miComClick
        end
        object miOsRemove: TMenuItem
          Caption = 'os.remove (filename)'
          OnClick = miComClick
        end
        object miOsRename: TMenuItem
          Caption = 'os.rename (oldname, newname)'
          OnClick = miComClick
        end
        object miOsSetlocale: TMenuItem
          Caption = 'os.setlocale (locale [, category])'
          OnClick = miComClick
        end
        object miOsTime: TMenuItem
          Caption = 'os.time ([table])'
          OnClick = miComClick
        end
        object miOsTmpname: TMenuItem
          Caption = 'os.tmpname ()'
          OnClick = miComClick
        end
      end
      object miTheDebugLibrary: TMenuItem
        Caption = 'The Debug Library'
        object miDebugDebug: TMenuItem
          Caption = 'debug.debug ()'
          OnClick = miComClick
        end
        object miDebugGetfenv: TMenuItem
          Caption = 'debug.getfenv (o)'
          OnClick = miComClick
        end
        object miDebugGethook: TMenuItem
          Caption = 'debug.gethook ([thread])'
          OnClick = miComClick
        end
        object miDebugGetinfo: TMenuItem
          Caption = 'debug.getinfo ([thread,] function [, what])'
          OnClick = miComClick
        end
        object miDebugGetlocal: TMenuItem
          Caption = 'debug.getlocal ([thread,] level, local)'
          OnClick = miComClick
        end
        object miDebugGetmetatable: TMenuItem
          Caption = 'debug.getmetatable (object)'
          OnClick = miComClick
        end
        object miDebugGetregistry: TMenuItem
          Caption = 'debug.getregistry ()'
          OnClick = miComClick
        end
        object miDebugGetupvalue: TMenuItem
          Caption = 'debug.getupvalue (func, up)'
          OnClick = miComClick
        end
        object miDebugSetfenv: TMenuItem
          Caption = 'debug.setfenv (object, table)'
          OnClick = miComClick
        end
        object miDebugSethook: TMenuItem
          Caption = 'debug.sethook ([thread,] hook, mask [, count])'
          OnClick = miComClick
        end
        object miDebugSetlocal: TMenuItem
          Caption = 'debug.setlocal ([thread,] level, local, value)'
          OnClick = miComClick
        end
        object miDebugSetmetatable: TMenuItem
          Caption = 'debug.setmetatable (object, table)'
          OnClick = miComClick
        end
        object miDebugSetupvalue: TMenuItem
          Caption = 'debug.setupvalue (func, up, value)'
          OnClick = miComClick
        end
        object miDebugTraceback: TMenuItem
          Caption = 'debug.traceback ([thread,] [message [, level]])'
          OnClick = miComClick
        end
      end
    end
    object miPlugins: TMenuItem
      Caption = 'Plugins'
      object miPluginload: TMenuItem
        Caption = 'pluginload [filename]'
        OnClick = miComClick
      end
      object miPluginunload: TMenuItem
        Caption = 'pluginunload [filename]'
        OnClick = miComClick
      end
      object miPluginreload: TMenuItem
        Caption = 'pluginreload [filename]'
        OnClick = miComClick
      end
    end
    object miSet: TMenuItem
      Caption = 'set <имя> <знач.>  [<зн.оп.> <знач.>]'
      OnClick = miComClick
    end
    object miW: TMenuItem
      Caption = 'wait <число>'
      OnClick = miComClick
    end
    object miMouses: TMenuItem
      Caption = 'Мышка'
      object miGetmousepos: TMenuItem
        Caption = 'get mouse_pos <#x> <#y> [abs]'
        OnClick = miComClick
      end
      object miMove: TMenuItem
        Caption = 'move <х> <у> [+х +у [-х -у]] [abs | handle] [nooffset]'
        OnClick = miComClick
      end
      object miMovesmooth: TMenuItem
        Caption = 'move_smooth <х> <у> [+х +у [-х -у]] [abs | handle] [nooffset]'
        OnClick = miComClick
      end
      object miDrag: TMenuItem
        Caption = 'drag <откуда> <куда> [сколько]'
        OnClick = miComClick
      end
      object simple1: TMenuItem
        Caption = 'simple'
        object miLeft: TMenuItem
          Caption = 'left <x> <y> [abs | handle] [nooffset] [~^rlm]'
          OnClick = miComClick
        end
        object miRight: TMenuItem
          Caption = 'right'
          OnClick = miComClick
        end
        object miMiddle: TMenuItem
          Caption = 'middle'
          OnClick = miComClick
        end
        object miDL: TMenuItem
          Caption = 'double_left'
          OnClick = miComClick
        end
        object miDR: TMenuItem
          Caption = 'double_right'
          OnClick = miComClick
        end
        object miDoublemiddle: TMenuItem
          Caption = 'double_middle'
          OnClick = miComClick
        end
        object miLeftdown: TMenuItem
          Caption = 'left_down'
          OnClick = miComClick
        end
        object miLeftup: TMenuItem
          Caption = 'left_up'
          OnClick = miComClick
        end
        object miRightdown: TMenuItem
          Caption = 'right_down'
          OnClick = miComClick
        end
        object miRightup: TMenuItem
          Caption = 'right_up'
          OnClick = miComClick
        end
        object miMiddledown: TMenuItem
          Caption = 'middle_down'
          OnClick = miComClick
        end
        object miMiddleup: TMenuItem
          Caption = 'middle_up'
          OnClick = miComClick
        end
      end
      object k1: TMenuItem
        Caption = 'k'
        object mikl: TMenuItem
          Caption = 'kleft <x> <y> [abs | handle] [nooffset]'
          OnClick = miComClick
        end
        object mikr: TMenuItem
          Caption = 'kright'
          OnClick = miComClick
        end
        object miKmiddle: TMenuItem
          Caption = 'kmiddle'
          OnClick = miComClick
        end
        object midkl: TMenuItem
          Caption = 'double_kleft'
          OnClick = miComClick
        end
        object midkr: TMenuItem
          Caption = 'double_kright'
          OnClick = miComClick
        end
        object miDoublekmiddle: TMenuItem
          Caption = 'double_kmiddle'
          OnClick = miComClick
        end
        object mikld: TMenuItem
          Caption = 'kleft_down'
          OnClick = miComClick
        end
        object miklu: TMenuItem
          Caption = 'kleft_up'
          OnClick = miComClick
        end
        object mikrd: TMenuItem
          Caption = 'kright_down'
          OnClick = miComClick
        end
        object mikru: TMenuItem
          Caption = 'kright_up'
          OnClick = miComClick
        end
        object miKmiddledown: TMenuItem
          Caption = 'kmiddle_down'
          OnClick = miComClick
        end
        object miKmiddleup: TMenuItem
          Caption = 'kmiddle_up'
          OnClick = miComClick
        end
      end
      object p1: TMenuItem
        Caption = 'p'
        object miPleft: TMenuItem
          Caption = 'pleft <x> <y> [abs | handle] [nooffset] [~^rlm]'
          OnClick = miComClick
        end
        object miPright: TMenuItem
          Caption = 'pright'
          OnClick = miComClick
        end
        object miPmiddle: TMenuItem
          Caption = 'pmiddle'
          OnClick = miComClick
        end
        object miDoublepleft: TMenuItem
          Caption = 'double_pleft'
          OnClick = miComClick
        end
        object miDoublepright: TMenuItem
          Caption = 'double_pright'
          OnClick = miComClick
        end
        object miDoublepmiddle: TMenuItem
          Caption = 'double_pmiddle'
          OnClick = miComClick
        end
        object miPleftdown: TMenuItem
          Caption = 'pleft_down'
          OnClick = miComClick
        end
        object miPleftup: TMenuItem
          Caption = 'pleft_up'
          OnClick = miComClick
        end
        object miPrightdown: TMenuItem
          Caption = 'pright_down'
          OnClick = miComClick
        end
        object miPrightup: TMenuItem
          Caption = 'pright_up'
          OnClick = miComClick
        end
        object miPmiddledown: TMenuItem
          Caption = 'pmiddle_down'
          OnClick = miComClick
        end
        object miPmiddleup: TMenuItem
          Caption = 'pmiddle_up'
          OnClick = miComClick
        end
      end
      object wheel1: TMenuItem
        Caption = 'wheel'
        object wheeldownxyabsrlmcount1: TMenuItem
          Caption = 'wheel_down <x> <y> [abs | handle] [nooffset] [~^rlm] count'
          OnClick = miComClick
        end
        object wheelup1: TMenuItem
          Caption = 'wheel_up'
          OnClick = miComClick
        end
        object pwheeldown1: TMenuItem
          Caption = 'pwheel_down'
          OnClick = miComClick
        end
        object pwheelup1: TMenuItem
          Caption = 'pwheel_up'
          OnClick = miComClick
        end
        object kwheeldownxyabscount1: TMenuItem
          Caption = 'kwheel_down <x> <y> [abs | handle] count'
          OnClick = miComClick
        end
        object kwheelup1: TMenuItem
          Caption = 'kwheel_up <x> <y> [abs | handle] count'
          OnClick = miComClick
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object miMouseposx: TMenuItem
        Caption = 'mousepos_x'
        OnClick = miComClick
      end
      object miMouseposy: TMenuItem
        Caption = 'mousepos_y'
        OnClick = miComClick
      end
      object miMouseposabsx: TMenuItem
        Caption = 'mouseposabs_x'
        OnClick = miComClick
      end
      object miMouseposabs_y: TMenuItem
        Caption = 'mouseposabs_y'
        OnClick = miComClick
      end
      object mimouse: TMenuItem
        Caption = 'mouse <enable|disable>'
        OnClick = miComClick
      end
    end
    object miKeys: TMenuItem
      Caption = 'Клавиши'
      object miM: TMenuItem
        Caption = 'send <клавиша [пауза]> | <текст>'
        OnClick = miComClick
      end
      object miSenddown: TMenuItem
        Caption = 'send_down <key> [time]'
        OnClick = miComClick
      end
      object miSendup: TMenuItem
        Caption = 'send_up <key>'
        OnClick = miComClick
      end
      object misend217: TMenuItem
        Caption = 'send217 <клавиша [пауза]> | <текст>'
        OnClick = miComClick
      end
      object miSend217down: TMenuItem
        Caption = 'send217_down <key> [time]'
        OnClick = miComClick
      end
      object miSend217up: TMenuItem
        Caption = 'send217_up <key>'
        OnClick = miComClick
      end
      object miMex: TMenuItem
        Caption = 'sendex <список клавиш>'
        OnClick = miComClick
      end
      object miSendexdown: TMenuItem
        Caption = 'sendex_down <key>'
        OnClick = miComClick
      end
      object miSendexup: TMenuItem
        Caption = 'sendex_up <key>'
        OnClick = miComClick
      end
      object miPost: TMenuItem
        Caption = 'post <клавиша [пауза]> | <текст>'
        Enabled = False
        OnClick = miComClick
      end
      object miPostdown: TMenuItem
        Caption = 'post_down <key> [time]'
        Enabled = False
        Visible = False
        OnClick = miComClick
      end
      object miPostup: TMenuItem
        Caption = 'post_up <key>'
        Enabled = False
        Visible = False
        OnClick = miComClick
      end
      object miGetlayout: TMenuItem
        Caption = 'set $var getlayout'
        OnClick = miComClick
      end
      object miSetlayout: TMenuItem
        Caption = 'set $var setlayout (layout)'
        OnClick = miComClick
      end
      object miSay: TMenuItem
        Caption = 'say [text]'
        OnClick = miComClick
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object miHotkeystart1: TMenuItem
        Caption = 'set hotkeystart [~|^|@] {key}'
        OnClick = miComClick
      end
      object miHotkeypause1: TMenuItem
        Caption = 'set hotkeypause [~|^|@] {key}'
        OnClick = miComClick
      end
      object mikeyboard: TMenuItem
        Caption = 'keyboard <enable|disable>'
        OnClick = miComClick
      end
    end
    object miRepits: TMenuItem
      Caption = 'Циклы'
      object miBreak: TMenuItem
        Caption = 'break [уровень]'
        OnClick = miComClick
      end
      object miContinue: TMenuItem
        Caption = 'continue'
        OnClick = miComClick
      end
      object miRt: TMenuItem
        Caption = 'repeat <число>'
        OnClick = miComClick
      end
      object mieRt: TMenuItem
        Caption = 'end_repeat'
        OnClick = miComClick
      end
      object miFor: TMenuItem
        Caption = 'for <имя> <начало> <конец> [шаг]'
        OnClick = miComClick
      end
      object mieFor: TMenuItem
        Caption = 'end_for'
        OnClick = miComClick
      end
      object miWhileP: TMenuItem
        Caption = 'while <параметр> <зн.оп.> <значение> [<and | or | xor> ...]'
        OnClick = miComClick
      end
      object miWhile: TMenuItem
        Caption = 'while <коорд> <цвет> [цвет2]'
        OnClick = miComClick
      end
      object miWhileL: TMenuItem
        Caption = 'while lastmsg <сообщение>'
        OnClick = miComClick
      end
      object miWhileN: TMenuItem
        Caption = 'while_not <...>'
        OnClick = miComClick
      end
      object mieWhile: TMenuItem
        Caption = 'end_while'
        OnClick = miComClick
      end
    end
    object miIfs: TMenuItem
      Caption = 'Условия'
      object miiIFp: TMenuItem
        Caption = 'if <параметр> <зн.оп.> <значение> [<and | or | xor> ...]'
        OnClick = miComClick
      end
      object miIF: TMenuItem
        Caption = 'if <коорд> <цвет> [цвет2]'
        OnClick = miComClick
      end
      object miIfLastmsg: TMenuItem
        Caption = 'if lastmsg <сообщение>'
        OnClick = miComClick
      end
      object miIFNot: TMenuItem
        Caption = 'if_not <...>'
        OnClick = miComClick
      end
      object miElse: TMenuItem
        Caption = 'else'
        OnClick = miComClick
      end
      object mieIF: TMenuItem
        Caption = 'end_if'
        OnClick = miComClick
      end
      object miSwitch: TMenuItem
        Caption = 'switch <значение>'
        OnClick = miComClick
      end
      object miCase: TMenuItem
        Caption = 'case <значение x>: [команда]'
        OnClick = miComClick
      end
      object miBreak1: TMenuItem
        Caption = 'break'
        OnClick = miComClick
      end
      object miEndswitch: TMenuItem
        Caption = 'end_switch'
        OnClick = miComClick
      end
    end
    object miColorsImages: TMenuItem
      Caption = 'Цвет и изображения'
      object miGetcolor: TMenuItem
        Caption = 'get color <#color> <#x> <#y> [handle] [abs]'
        OnClick = miComClick
      end
      object miWhile2: TMenuItem
        Caption = 'while <коорд> <цвет> [цвет2]'
        OnClick = miComClick
      end
      object miIF2: TMenuItem
        Caption = 'if <коорд> <цвет> [цвет2]'
        OnClick = miComClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object miFindImage: TMenuItem
        Caption = 'FindImage (StartX StartY EndX EndY (filename) ResultArray [type|handle [accuracy [count [deviation]]]] [abs])'
        OnClick = miComClick
      end
      object miFindcolor: TMenuItem
        Caption = 'FindColor (<StartX StartY EndX EndY ShiftX ShiftY (RequiredColor) ResultArray> [type [count [deviation]]] [abs])'
        OnClick = miComClick
      end
      object miColor: TMenuItem
        Caption = 'color (#x #y [handle] [abs])'
        OnClick = miComClick
      end
      object colorToRedcolor1: TMenuItem
        Caption = 'colorToRed (color)'
        OnClick = miComClick
      end
      object colorToGreencolor1: TMenuItem
        Caption = 'colorToGreen (color)'
        OnClick = miComClick
      end
      object colorToBluecolor1: TMenuItem
        Caption = 'colorToBlue (color)'
        OnClick = miComClick
      end
      object colorToRGBcolorarrx1: TMenuItem
        Caption = 'colorToRGB (color %arr[x])'
        OnClick = miComClick
      end
      object miGetImage: TMenuItem
        Caption = 'GetImage (StartX StartY EndX EndY [type|handle] [abs])'
        OnClick = miComClick
      end
      object miDeleteImage: TMenuItem
        Caption = 'DeleteImage (address)'
        OnClick = miComClick
      end
      object miLoadImage: TMenuItem
        Caption = 'LoadImage (filename)'
        OnClick = miComClick
      end
      object miSaveImage: TMenuItem
        Caption = 'SaveImage (Address filename)'
        OnClick = miComClick
      end
    end
    object miProcs: TMenuItem
      Caption = 'Подпрограммы'
      object miCall: TMenuItem
        Caption = 'call <имя> [var1] [var2] ...'
        OnClick = miComClick
      end
      object miProc: TMenuItem
        Caption = 'proc <имя> [var1] [var2] ...'
        OnClick = miComClick
      end
      object miEndProc: TMenuItem
        Caption = 'end_proc'
        OnClick = miComClick
      end
      object miGosub: TMenuItem
        Caption = 'gosub <метка>'
        OnClick = miComClick
      end
      object miReturn: TMenuItem
        Caption = 'return'
        OnClick = miComClick
      end
    end
    object miMLoad: TMenuItem
      Caption = 'Макроcы'
      object miMacroload: TMenuItem
        Caption = 'macro_load <имя файла>'
        OnClick = miComClick
      end
      object miMacroplay: TMenuItem
        Caption = 'macro_play [число] [скорость]'
        OnClick = miComClick
      end
      object miMacrosend: TMenuItem
        Caption = 'macro_send <list of keys>'
        OnClick = miComClick
      end
    end
    object miArrays: TMenuItem
      Caption = 'Массивы'
      object miLoadarray: TMenuItem
        Caption = 'load_array <%array> [#array_x] [#array_y] [#file_x] [#file_y] [#count_x] [#count_y] [$filename]'
        OnClick = miComClick
      end
      object miSavearray: TMenuItem
        Caption = 'save_array <%array> [#array_x] [#array_y] [#count_x] [#count_y] [$filename] [append]'
        OnClick = miComClick
      end
      object miinitarr: TMenuItem
        Caption = 'init_arr %arr [(startRow [colCount [startCol]])] set of values'
        OnClick = miComClick
      end
      object setresultindexOfarrnoabscasestartRowEndRowcounttext1: TMenuItem
        Caption = 'set %result indexOf ( %arr [noabs] [case] [[startRow [EndRow]] count] (text) )'
        OnClick = miComClick
      end
      object miSortarrayarray: TMenuItem
        Caption = 'sort_array %array [+col | -row] [dec]'
        OnClick = miComClick
      end
      object miDeletearray: TMenuItem
        Caption = 'delete_array %array [+col | -row] [count=1]'
        OnClick = miComClick
      end
      object miSize: TMenuItem
        Caption = 'size (<var>)'
        OnClick = miComClick
      end
    end
    object miScripts: TMenuItem
      Caption = 'Скрипты'
      object miStartScript: TMenuItem
        Caption = 'start_script <number | filename> [wait]'
        OnClick = miComClick
      end
      object miStopScript: TMenuItem
        Caption = 'stop_script [number | filename | all | allex]'
        OnClick = miComClick
      end
      object miPauseScript: TMenuItem
        Caption = 'pause_script [number | filename | all | allex]'
        OnClick = miComClick
      end
      object miResumeScript: TMenuItem
        Caption = 'resume_script <number | filename | all>'
        OnClick = miComClick
      end
      object miRestartscript: TMenuItem
        Caption = 'restart_script [number | filename | all | allex]'
        OnClick = miComClick
      end
      object miLoadscript: TMenuItem
        Caption = 'load_script <scriptNumber> <file>'
        OnClick = miComClick
      end
      object miPriority: TMenuItem
        Caption = 'set priority <0 | 1 | 2 | 3>'
        OnClick = miComClick
      end
      object setacurrentscript1: TMenuItem
        Caption = 'set #a current_script'
        OnClick = miComClick
      end
      object setaactivescript1: TMenuItem
        Caption = 'set #a active_script'
        OnClick = miComClick
      end
      object miGetScripts: TMenuItem
        Caption = 'get scripts %a'
        OnClick = miComClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mihotkeystart: TMenuItem
        Caption = 'set hotkeystart [~|^|@] {key}'
        OnClick = miComClick
      end
      object mihotkeypause: TMenuItem
        Caption = 'set hotkeypause [~|^|@] {key}'
        OnClick = miComClick
      end
    end
    object miPrograms: TMenuItem
      Caption = 'Программы'
      object miExec: TMenuItem
        Caption = 'exec <команда> [параметры]'
        OnClick = miComClick
      end
      object miExecAndWait: TMenuItem
        Caption = 'ExecAndWait <команда> [параметры]'
        OnClick = miComClick
      end
      object miTerminate: TMenuItem
        Caption = 'terminate <заголовок окна>'
        OnClick = miComClick
      end
    end
    object miFiles: TMenuItem
      Caption = 'Files'
      object mifilecopy: TMenuItem
        Caption = 'filecopy (<ExistingFileName> <NewFileName>)'
        OnClick = miComClick
      end
      object mifilerename: TMenuItem
        Caption = 'filerename (<OldFileName> <NewFileName>)'
        OnClick = miComClick
      end
      object mifiledelete: TMenuItem
        Caption = 'filedelete (<FileName>)'
        OnClick = miComClick
      end
      object mifilesetdate: TMenuItem
        Caption = 'filesetdate (<FileName> <Date> [Time])'
        OnClick = miComClick
      end
      object mifilesetattr: TMenuItem
        Caption = 'filesetattr (<FileName> <Attributes>)'
        OnClick = miComClick
      end
      object mifilegetattr: TMenuItem
        Caption = 'msg filegetattr (<FileName>)'
        OnClick = miComClick
      end
      object mifilegetdate: TMenuItem
        Caption = 'msg filegetdate (<FileName>)'
        OnClick = miComClick
      end
      object mifileexists: TMenuItem
        Caption = 'msg fileexists (<FileName>)'
        OnClick = miComClick
      end
      object midircreate: TMenuItem
        Caption = 'dircreate (<Dir>)'
        OnClick = miComClick
      end
      object midirremove: TMenuItem
        Caption = 'dirremove (<Dir>)'
        OnClick = miComClick
      end
      object midir: TMenuItem
        Caption = 'dir (%resultArray [Path [Filemask]])'
        OnClick = miComClick
      end
      object mierrorlevel: TMenuItem
        Caption = 'msg errorlevel'
        OnClick = miComClick
      end
      object miwritefile: TMenuItem
        Caption = 'write (<filename> <any text>)'
        OnClick = miComClick
      end
    end
    object Windows1: TMenuItem
      Caption = 'Windows'
      object miWindowpos: TMenuItem
        Caption = 'set windowpos [x] [y] [width] [height] [handle]'
        OnClick = miComClick
      end
      object miGetwindowpos: TMenuItem
        Caption = 'get windowpos <handle> [#X #Y [#width #height [#result]]]'
        OnClick = miComClick
      end
      object miFindwindow: TMenuItem
        Caption = 'set #var findwindow (<caption>)'
        OnClick = miComClick
      end
      object miWorkwindow: TMenuItem
        Caption = 'set workwindow <handle>'
        OnClick = miComClick
      end
      object miGetwindow: TMenuItem
        Caption = 'set #var getwindow (<handle> <direction>)'
        OnClick = miComClick
      end
      object miGetwindowtext: TMenuItem
        Caption = 'set $var getwindowtext (<handle>)'
        OnClick = miComClick
      end
      object miSetwindowtext: TMenuItem
        Caption = 'set #result setwindowtext (<handle> <caption>)'
        OnClick = miComClick
      end
      object miShowwindow: TMenuItem
        Caption = 'showwindow <handle> <state>'
        OnClick = miComClick
      end
      object miWindowFromCursor: TMenuItem
        Caption = 'set #w windowfromcursor'
        OnClick = miComClick
      end
      object miWindowfrompoint: TMenuItem
        Caption = 'set $var windowfrompoint (#x #y [one|all|child])'
        OnClick = miComClick
      end
      object miworkwindowpid: TMenuItem
        Caption = 'set #var workwindowpid'
        OnClick = miComClick
      end
      object miSendmessage: TMenuItem
        Caption = 'set $s sendmessage ([hWnd=workwindow [Msg=0 [wParam=0 [lParam=0]]]])'
        OnClick = miComClick
      end
      object miPostmessage: TMenuItem
        Caption = 'set $p postmessage ([hWnd=workwindow [Msg=0 [wParam=0 [lParam=0]]]])'
        OnClick = miComClick
      end
      object miGetFocus: TMenuItem
        Caption = 'set #var GetFocus'
        OnClick = miComClick
      end
    end
    object Memory1: TMenuItem
      Caption = 'Memory'
      object miReadmem: TMenuItem
        Caption = 'readmem <variable> <adress> <type> <size> [modulename]'
        OnClick = miComClick
      end
      object miWritemem: TMenuItem
        Caption = 'writemem <variable> <adress> <type> [ModuleName] [result]'
        OnClick = miComClick
      end
      object miRelativeAddress2absolute: TMenuItem
        Caption = 'set #var RelativeAddress2absolute (<module name> <address> [handle|PID])'
        OnClick = miComClick
      end
      object miAbsoluteAddress2relative: TMenuItem
        Caption = 'set #var AbsoluteAddress2relative (<module name> <address> [handle|PID])'
        OnClick = miComClick
      end
    end
    object miClipboard: TMenuItem
      Caption = 'Clipboard'
      object miSetClipboard: TMenuItem
        Caption = 'set clipboard <var | text>'
        OnClick = miComClick
      end
      object miGetClipboard: TMenuItem
        Caption = 'get clipboard <$var | %var>'
        OnClick = miComClick
      end
    end
    object miStrings: TMenuItem
      Caption = 'Строки'
      object miPosEx: TMenuItem
        Caption = 'set #n PosEx (SubStr String [Offset=1])'
        OnClick = miComClick
      end
      object miCopyString: TMenuItem
        Caption = 'set $s Copy (String Index Count)'
        OnClick = miComClick
      end
      object miDeleteString: TMenuItem
        Caption = 'set $s Delete (String Index Count)'
        OnClick = miComClick
      end
      object miInsertString: TMenuItem
        Caption = 'set $s Insert (Source String Index)'
        OnClick = miComClick
      end
      object miCharToHex: TMenuItem
        Caption = 'set $s CharToHex (<variable>)'
        OnClick = miComClick
      end
      object miCharToHexF: TMenuItem
        Caption = 'set $s CharToHexF (<variable>)'
        OnClick = miComClick
      end
      object miTrim: TMenuItem
        Caption = 'set $s trim (string)'
        OnClick = miComClick
      end
      object miLtrim: TMenuItem
        Caption = 'set $s ltrim (string)'
        OnClick = miComClick
      end
      object miRtrim: TMenuItem
        Caption = 'set $s rtrim (string)'
        OnClick = miComClick
      end
      object miRegexp: TMenuItem
        Caption = 'set #n regexp (#position $hitString $string $regexp)'
        OnClick = miComClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miGetnumber: TMenuItem
        Caption = 'get number <#var> <#pos> <$string>'
        OnClick = miComClick
      end
      object miGetword: TMenuItem
        Caption = 'get word <$var> <#pos> <$string>'
        OnClick = miComClick
      end
      object miGetselectedtext: TMenuItem
        Caption = 'set $w getselectedtext'
        OnClick = miComClick
      end
      object miSetselectedtext: TMenuItem
        Caption = 'set $w setselectedtext (text)'
        OnClick = miComClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object miIsreal: TMenuItem
        Caption = 'is_real (x)'
        OnClick = miComClick
      end
      object miIsstring: TMenuItem
        Caption = 'is_string (x)'
        OnClick = miComClick
      end
      object miChr: TMenuItem
        Caption = 'chr (val)'
        OnClick = miComClick
      end
      object miOrd: TMenuItem
        Caption = 'ord (str)'
        OnClick = miComClick
      end
      object miStringreplace: TMenuItem
        Caption = 'string_replace (str substr newstr [all])'
        OnClick = miComClick
      end
      object miStringcount: TMenuItem
        Caption = 'string_count (substr str)'
        OnClick = miComClick
      end
      object miStringlower: TMenuItem
        Caption = 'string_lower (str)'
        OnClick = miComClick
      end
      object miStringupper: TMenuItem
        Caption = 'string_upper (str)'
        OnClick = miComClick
      end
      object miStringletters: TMenuItem
        Caption = 'string_letters (str)'
        OnClick = miComClick
      end
      object miStringdigits: TMenuItem
        Caption = 'string_digits (str)'
        OnClick = miComClick
      end
      object miSize2: TMenuItem
        Caption = 'size (<var>)'
        OnClick = miComClick
      end
    end
    object miNumbers: TMenuItem
      Caption = 'Числа'
      object miRandom: TMenuItem
        Caption = 'Random (<number>)'
        OnClick = miComClick
      end
      object miSize3: TMenuItem
        Caption = 'size (<var>)'
        OnClick = miComClick
      end
      object miAbs: TMenuItem
        Caption = 'abs (x)'
        OnClick = miComClick
      end
      object miRound: TMenuItem
        Caption = 'round (x)'
        OnClick = miComClick
      end
      object miFloor: TMenuItem
        Caption = 'floor (x)'
        OnClick = miComClick
      end
      object miCeil: TMenuItem
        Caption = 'ceil (x)'
        OnClick = miComClick
      end
      object miFrac: TMenuItem
        Caption = 'frac (x)'
        OnClick = miComClick
      end
      object miSqrt: TMenuItem
        Caption = 'sqrt (x)'
        OnClick = miComClick
      end
      object miPower: TMenuItem
        Caption = 'power (x n)'
        OnClick = miComClick
      end
      object miExp: TMenuItem
        Caption = 'exp (x)'
        OnClick = miComClick
      end
      object miLn: TMenuItem
        Caption = 'ln (x)'
        OnClick = miComClick
      end
      object miLog: TMenuItem
        Caption = 'log (n x)'
        OnClick = miComClick
      end
      object miSin: TMenuItem
        Caption = 'sin (x)'
        OnClick = miComClick
      end
      object miCos: TMenuItem
        Caption = 'cos (x)'
        OnClick = miComClick
      end
      object miTan: TMenuItem
        Caption = 'tan (x)'
        OnClick = miComClick
      end
      object miArcsin: TMenuItem
        Caption = 'arcsin (x)'
        OnClick = miComClick
      end
      object miArccos: TMenuItem
        Caption = 'arccos (x)'
        OnClick = miComClick
      end
      object miArctan: TMenuItem
        Caption = 'arctan (x)'
        OnClick = miComClick
      end
      object miDegtorad: TMenuItem
        Caption = 'degtorad (x)'
        OnClick = miComClick
      end
      object miRadtodeg: TMenuItem
        Caption = 'radtodeg (x)'
        OnClick = miComClick
      end
      object miTrunc: TMenuItem
        Caption = 'trunc (x)'
        OnClick = miComClick
      end
      object miMinx: TMenuItem
        Caption = 'minx (val1 val2 val3 ...)'
        OnClick = miComClick
      end
      object miMaxx: TMenuItem
        Caption = 'maxx (val1 val2 val3 ...)'
        OnClick = miComClick
      end
      object miMean: TMenuItem
        Caption = 'mean (val1 val2 val3 ...)'
        OnClick = miComClick
      end
      object miPointdistance: TMenuItem
        Caption = 'point_distance (x1 y1 x2 y2)'
        OnClick = miComClick
      end
      object miPointdirection: TMenuItem
        Caption = 'point_direction (x1 y1 x2 y2)'
        OnClick = miComClick
      end
      object miLengthdirx: TMenuItem
        Caption = 'lengthdir_x (len dir)'
        OnClick = miComClick
      end
      object miLengthdiry: TMenuItem
        Caption = 'lengthdir_y (len dir)'
        OnClick = miComClick
      end
      object miDec2hex: TMenuItem
        Caption = 'dec2hex (#b)'
        OnClick = miComClick
      end
      object miHex2dec: TMenuItem
        Caption = 'hex2dec ($a)'
        OnClick = miComClick
      end
      object miCharToHex2: TMenuItem
        Caption = 'CharToHex (<variable>)'
        OnClick = miComClick
      end
      object miCharToHexF2: TMenuItem
        Caption = 'CharToHexF (<variable>)'
        OnClick = miComClick
      end
      object miMod: TMenuItem
        Caption = 'mod (x y)'
        OnClick = miComClick
      end
      object miDiv: TMenuItem
        Caption = 'div (x y)'
        OnClick = miComClick
      end
      object miPi: TMenuItem
        Caption = 'Pi'
        OnClick = miComClick
      end
    end
    object miDateTime: TMenuItem
      Caption = 'Date && Time'
      object miAddDate: TMenuItem
        Caption = 'AddDate(Date1 Date2)'
        OnClick = miComClick
      end
      object miAddYears: TMenuItem
        Caption = 'AddYears(Date Years)'
        OnClick = miComClick
      end
      object miAddMonths: TMenuItem
        Caption = 'AddMonths(Date Months)'
        OnClick = miComClick
      end
      object miAddDays: TMenuItem
        Caption = 'AddDays(Date Days)'
        OnClick = miComClick
      end
      object miAddHours: TMenuItem
        Caption = 'AddHours(Date Hours)'
        OnClick = miComClick
      end
      object miAddMinutes: TMenuItem
        Caption = 'AddMinutes(Date Minutes)'
        OnClick = miComClick
      end
      object miAddSeconds: TMenuItem
        Caption = 'AddSeconds(Date Seconds)'
        OnClick = miComClick
      end
      object miSubDate: TMenuItem
        Caption = 'SubDate(Date1 Date2)'
        OnClick = miComClick
      end
      object miSubYears: TMenuItem
        Caption = 'SubYears(Date Years)'
        OnClick = miComClick
      end
      object miSubMonths: TMenuItem
        Caption = 'SubMonths(Date Months)'
        OnClick = miComClick
      end
      object miSubDays: TMenuItem
        Caption = 'SubDays(Date Days)'
        OnClick = miComClick
      end
      object miSubHours: TMenuItem
        Caption = 'SubHours(Date Hours)'
        OnClick = miComClick
      end
      object miSubMinutes: TMenuItem
        Caption = 'SubMinutes(Date Minutes)'
        OnClick = miComClick
      end
      object miSubSeconds: TMenuItem
        Caption = 'SubSeconds(Date Seconds)'
        OnClick = miComClick
      end
      object miYearFromDate: TMenuItem
        Caption = 'YearFromDate(Date)'
        OnClick = miComClick
      end
      object miMonthFromDate: TMenuItem
        Caption = 'MonthFromDate(Date)'
        OnClick = miComClick
      end
      object miDayFromDate: TMenuItem
        Caption = 'DayFromDate(Date)'
        OnClick = miComClick
      end
      object miHourFromDate: TMenuItem
        Caption = 'HourFromDate(Date)'
        OnClick = miComClick
      end
      object miMinuteFromDate: TMenuItem
        Caption = 'MinuteFromDate(Date)'
        OnClick = miComClick
      end
      object miSecondFromDate: TMenuItem
        Caption = 'SecondFromDate(Date)'
        OnClick = miComClick
      end
      object miDateNow: TMenuItem
        Caption = 'DateNow'
        OnClick = miComClick
      end
      object miTimeNow: TMenuItem
        Caption = 'TimeNow'
        OnClick = miComClick
      end
      object miTimeStamp: TMenuItem
        Caption = 'TimeStamp (Date)'
        OnClick = miComClick
      end
    end
    object miDisplayMessages: TMenuItem
      Caption = 'Вывод сообщений'
      object miSetlogging: TMenuItem
        Caption = 'set logging [option | text]'
        OnClick = miComClick
      end
      object moLog: TMenuItem
        Caption = 'log [option | text]'
        OnClick = miComClick
      end
      object miMsg: TMenuItem
        Caption = 'msg [text]'
        OnClick = miComClick
      end
      object mihintF: TMenuItem
        Caption = 'hint (fontSize fontColor posX posY width height backColor fontStyle fontName (any text))'
        OnClick = miComClick
      end
      object mihint: TMenuItem
        Caption = 'hint [text]'
        OnClick = miComClick
      end
      object miAlarm: TMenuItem
        Caption = 'alarm [имя файла]'
        OnClick = miComClick
      end
      object miFlash: TMenuItem
        Caption = 'flash [параметр]'
        OnClick = miComClick
      end
      object miPrompt: TMenuItem
        Caption = 'Prompt ([!caption]<line1> [line2] [line3] [line4] [line5] [(timeout)])'
        OnClick = miComClick
      end
    end
    object miEvalC: TMenuItem
      Caption = 'eval (<some arguments>)'
      OnClick = miComClick
    end
    object miEvalF: TMenuItem
      Caption = 'set $var eval (some arguments)'
      OnClick = miComClick
    end
    object miGoto: TMenuItem
      Caption = 'goto <метка>'
      OnClick = miComClick
    end
    object miPrintscreen: TMenuItem
      Caption = 'printscreen <handle> <x> <y> <width> <heigth> <path>'
      OnClick = miComClick
    end
    object miExit1: TMenuItem
      Caption = 'exit'
      OnClick = miComClick
    end
    object miStop: TMenuItem
      Caption = 'end_script'
      OnClick = miComClick
    end
  end
  object pmSaveLoadLO: TPopupMenu
    Left = 72
    Top = 296
    object miLoadLO: TMenuItem
      Caption = 'Открыть'
      OnClick = miSaveLOClick
    end
    object miSaveLO: TMenuItem
      Caption = 'Сохранить'
      OnClick = miSaveLOClick
    end
    object miClesrLO: TMenuItem
      Caption = 'Очистить'
      OnClick = miClesrLOClick
    end
  end
  object fdEditor: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdApplyButton]
    OnApply = fdEditorApply
    Left = 168
    Top = 296
  end
  object tTabRefresh: TTimer
    Enabled = False
    Interval = 250
    OnTimer = tTabRefreshTimer
    Left = 308
    Top = 88
  end
  object pmTray: TPopupMenu
    OwnerDraw = True
    Left = 8
    Top = 296
    object miTrayRestore: TMenuItem
      Caption = 'Развернуть'
      OnClick = miTrayRestoreClick
    end
    object N30: TMenuItem
      Caption = '-'
    end
    object miTrayClose: TMenuItem
      Caption = 'Закрыть'
      OnClick = miExitClick
    end
  end
  object fhFindDialog: TFindDialog
    Options = [frDown, frDisableWholeWord]
    Left = 208
    Top = 328
  end
  object fhReplaceDialog: TReplaceDialog
    Options = [frDown, frDisableWholeWord]
    Left = 232
    Top = 328
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 7000
    OnTimer = Timer2Timer
    Top = 328
  end
  object mnTab: TPopupMenu
    AutoHotkeys = maManual
    Left = 272
    Top = 328
    object miTabRemove: TMenuItem
      Caption = 'Удалить'
      OnClick = bRemoveClick
    end
    object miTabClear: TMenuItem
      Caption = 'Очистить'
      OnClick = miNewClick
    end
    object miTabRename: TMenuItem
      Caption = 'Переименовать'
      OnClick = miTabRenameClick
    end
    object miTabClose: TMenuItem
      Caption = 'Закрыть'
      OnClick = bRemoveClick
    end
  end
  object tmTimer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmTimer1Timer
    Left = 8
    Top = 408
  end
end
