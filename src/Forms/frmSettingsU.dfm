object frmSettings: TfrmSettings
  HelpContext = 500
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Ustawienia'
  ClientHeight = 500
  ClientWidth = 660
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnShow = ModelsActivate
  PixelsPerInch = 96
  TextHeight = 17
  object SettingsPages: TPageControl
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 644
    Height = 448
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 44
    ActivePage = GeneralPage
    Align = alClient
    TabOrder = 0
    object GhostPage: TTabSheet
      HelpContext = 560
      Caption = 'Ghost replay'
      object lGhostHz: TLabel
        Left = 16
        Top = 20
        Width = 128
        Height = 17
        Caption = 'Refresh rate (5-60 Hz)'
      end
      object lGhostVMR: TLabel
        Left = 16
        Top = 64
        Width = 182
        Height = 17
        Caption = 'FSLTL_Rules.vmr (optional path)'
      end
      object seGhostHz: TSpinEdit
        Left = 250
        Top = 16
        Width = 100
        Height = 27
        MaxValue = 60
        MinValue = 5
        TabOrder = 0
        Value = 30
      end
      object eGhostVMR: TEdit
        Left = 16
        Top = 90
        Width = 580
        Height = 25
        TabOrder = 1
      end
    end
    object GeneralPage: TTabSheet
      HelpContext = 510
      Caption = 'Ogolne'
      object LanguageLabel: TLabel
        Left = 16
        Top = 20
        Width = 87
        Height = 17
        Caption = 'J'#281'zyk interfejsu'
      end
      object cbLanguage: TComboBox
        Left = 250
        Top = 16
        Width = 280
        Height = 30
        Style = csOwnerDrawFixed
        ItemHeight = 24
        TabOrder = 0
        OnDrawItem = LanguageDrawItem
        Items.Strings = (
          'Wykryj automatycznie'
          #1575#1604#1593#1585#1576#1610#1577
          #1041#1077#1083#1072#1088#1091#1089#1082#1072#1103
          #268'e'#353'tina'
          'Dansk'
          'Deutsch ('#214'sterreich)'
          'Deutsch (Schweiz)'
          'Deutsch'
          #917#955#955#951#957#953#954#940
          'English (United Kingdom)'
          'English'
          'Espa'#241'ol'
          'Suomi'
          'Fran'#231'ais (Canada)'
          'Fran'#231'ais'
          #1506#1489#1512#1497#1514
          #2361#2367#2344#2381#2342#2368
          'Hrvatski'
          'Bahasa Indonesia'
          'Italiano'
          #26085#26412#35486
          'Norsk (bokm'#229'l)'
          'Nederlands'
          'Polski'
          'Portugu'#234's (Brasil)'
          'Portugu'#234's'
          #1056#1091#1089#1089#1082#1080#1081
          'Sloven'#269'ina'
          'Svenska'
          'T'#252'rk'#231'e'
          #1059#1082#1088#1072#1111#1085#1089#1100#1082#1072
          'Ti'#7871'ng Vi'#7879't'
          #31616#20307#20013#25991)
      end
      object cbAutomaticUpdates: TCheckBox
        Left = 16
        Top = 125
        Width = 580
        Height = 25
        Caption = 'Sprawdzaj i instaluj aktualizacje przy uruchomieniu'
        Enabled = False
        TabOrder = 2
      end
      object btnCheckUpdates: TButton
        Left = 16
        Top = 166
        Width = 280
        Height = 28
        Caption = 'Sprawd'#378' aktualizacje'
        Enabled = False
        TabOrder = 3
        OnClick = CheckUpdatesClick
      end
      object btnChangeLog: TButton
        Left = 316
        Top = 166
        Width = 280
        Height = 28
        Caption = 'Historia zmian'
        TabOrder = 4
        OnClick = ChangeLogClick
      end
      object btnResetLayout: TButton
        Left = 16
        Top = 72
        Width = 580
        Height = 25
        Caption = 'Przywroc domyslny uklad paneli'
        TabOrder = 1
      end
    end
    object DebugPage: TTabSheet
      HelpContext = 550
      Caption = 'Debug'
      object lInstrumentOverride: TLabel
        Left = 16
        Top = 20
        Width = 209
        Height = 17
        Caption = 'Instrument display override (debug)'
      end
      object cbB38MInfoLeft: TCheckBox
        Left = 16
        Top = 192
        Width = 580
        Height = 25
        Caption = 
          'B38M: flight information on left (CPT); right when unchecked (FO' +
          ')'
        TabOrder = 4
      end
      object cbB38MInfo: TCheckBox
        Left = 16
        Top = 160
        Width = 580
        Height = 25
        Caption = 'B38M: display flight information panel'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object cbB38MAoA: TCheckBox
        Left = 16
        Top = 128
        Width = 580
        Height = 25
        Caption = 'B38M: display angle of attack (AoA)'
        TabOrder = 2
      end
      object cbB38MFD: TCheckBox
        Left = 16
        Top = 96
        Width = 580
        Height = 25
        Caption = 'B38M: display Flight Director from SimConnect'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object cbInstrumentOverride: TComboBox
        Left = 16
        Top = 48
        Width = 580
        Height = 25
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Automatic'
        Items.Strings = (
          'Automatic'
          'GA / ANALOG'
          'GA / GLASS'
          'AIRLINER / CLASSIC'
          'AIRLINER / PFD'
          'B38M / PFD + EICAS'
          'A320 / PFD + ECAM')
      end
    end
    object UnitsPage: TTabSheet
      HelpContext = 520
      Caption = 'Jednostki'
      object UnitsEditor: TValueListEditor
        Left = 0
        Top = 0
        Width = 636
        Height = 416
        Align = alClient
        TabOrder = 0
        TitleCaptions.Strings = (
          'Jednostka oryginalna'
          'Jednostka wy'#347'wietlana')
        ColWidths = (
          280
          300)
      end
    end
    object AnalysisPage: TTabSheet
      HelpContext = 530
      Caption = 'Analiza'
      ImageIndex = 1
      object lStartWindow: TLabel
        Left = 16
        Top = 20
        Width = 183
        Height = 17
        Caption = 'START - okno analizy (sekundy) '
      end
      object lBefore: TLabel
        Left = 16
        Top = 54
        Width = 109
        Height = 17
        Caption = 'Przed oderwaniem'
      end
      object lAfter: TLabel
        Left = 330
        Top = 54
        Width = 80
        Height = 17
        Caption = 'Po oderwaniu'
      end
      object lLandingWindow: TLabel
        Left = 16
        Top = 140
        Width = 216
        Height = 17
        Caption = 'LADOWANIE - okno analizy (sekundy)'
      end
      object lLandingBefore: TLabel
        Left = 16
        Top = 174
        Width = 195
        Height = 17
        Caption = 'Przed przyziemieniem (podejscie)'
      end
      object lLandingAfter: TLabel
        Left = 330
        Top = 174
        Width = 98
        Height = 17
        Caption = 'Po przyziemieniu'
      end
      object seBefore: TSpinEdit
        Left = 16
        Top = 80
        Width = 150
        Height = 27
        MaxValue = 300
        MinValue = 1
        TabOrder = 0
        Value = 60
      end
      object seAfter: TSpinEdit
        Left = 330
        Top = 80
        Width = 150
        Height = 27
        MaxValue = 300
        MinValue = 1
        TabOrder = 1
        Value = 30
      end
      object seLandingBefore: TSpinEdit
        Left = 16
        Top = 200
        Width = 150
        Height = 27
        MaxValue = 300
        MinValue = 1
        TabOrder = 2
        Value = 180
      end
      object seLandingAfter: TSpinEdit
        Left = 330
        Top = 200
        Width = 150
        Height = 27
        MaxValue = 300
        MinValue = 1
        TabOrder = 3
        Value = 30
      end
    end
    object AIPage: TTabSheet
      HelpContext = 540
      Caption = 'Silniki AI'
      ImageIndex = 2
      object lProvider: TLabel
        Left = 16
        Top = 12
        Width = 56
        Height = 17
        Caption = 'Dostawca'
      end
      object lTimeout: TLabel
        Left = 16
        Top = 324
        Width = 81
        Height = 17
        Caption = 'Limit czasu (s)'
      end
      object lHelp: TLabel
        Left = 16
        Top = 360
        Width = 600
        Height = 54
        AutoSize = False
        Caption = 
          'Codex: wykonaj codex login na tym koncie Windows. Zapytania i ra' +
          'porty po polsku.'
        WordWrap = True
      end
      object cbProvider: TComboBox
        Left = 16
        Top = 36
        Width = 600
        Height = 30
        Style = csOwnerDrawFixed
        ItemHeight = 24
        ItemIndex = 0
        TabOrder = 0
        Text = 'Codex (konto ChatGPT / CLI)'
        OnChange = ModelsActivate
        OnDrawItem = LanguageDrawItem
        Items.Strings = (
          'Codex (konto ChatGPT / CLI)'
          'Gemini (klucz API)'
          'Ollama (HTTP / lokalny model)')
      end
      object ProviderPages: TPageControl
        Left = 16
        Top = 80
        Width = 600
        Height = 230
        ActivePage = CodexPage
        TabOrder = 1
        object CodexPage: TTabSheet
          HelpContext = 541
          Caption = 'Codex'
          object lCodexPath: TLabel
            Left = 12
            Top = 12
            Width = 246
            Height = 17
            Caption = 'Codex EXE (puste = wykryj automatycznie)'
          end
          object lCodexModel: TLabel
            Left = 12
            Top = 80
            Width = 216
            Height = 17
            Caption = 'Model Codex (puste = domyslny CLI)'
          end
          object eCodexPath: TEdit
            Left = 12
            Top = 36
            Width = 560
            Height = 25
            TabOrder = 0
          end
          object eCodexModel: TEdit
            Left = 12
            Top = 104
            Width = 560
            Height = 25
            TabOrder = 1
          end
        end
        object GeminiPage: TTabSheet
          HelpContext = 542
          Caption = 'Gemini'
          ImageIndex = 1
          object lGeminiModel: TLabel
            Left = 12
            Top = 12
            Width = 82
            Height = 17
            Caption = 'Model Gemini'
          end
          object lKey: TLabel
            Left = 12
            Top = 80
            Width = 74
            Height = 17
            Caption = 'Klucz Gemini'
          end
          object eGeminiModel: TEdit
            Left = 12
            Top = 36
            Width = 560
            Height = 25
            TabOrder = 0
          end
          object eGeminiKey: TEdit
            Left = 12
            Top = 104
            Width = 560
            Height = 25
            PasswordChar = '*'
            TabOrder = 1
          end
        end
        object OllamaPage: TTabSheet
          HelpContext = 543
          Caption = 'Ollama'
          ImageIndex = 2
          object lOllamaURL: TLabel
            Left = 12
            Top = 12
            Width = 85
            Height = 17
            Caption = 'Serwer Ollama'
          end
          object lOllamaModel: TLabel
            Left = 12
            Top = 80
            Width = 83
            Height = 17
            Caption = 'Model Ollama'
          end
          object lOllamaContext: TLabel
            Left = 12
            Top = 144
            Width = 100
            Height = 17
            Caption = 'Kontekst (tokeny)'
          end
          object eOllamaURL: TEdit
            Left = 12
            Top = 36
            Width = 560
            Height = 25
            TabOrder = 0
            Text = 'http://localhost:11434'
            OnExit = ModelsActivate
          end
          object cbOllamaModel: TComboBox
            Left = 12
            Top = 104
            Width = 310
            Height = 25
            TabOrder = 1
          end
          object btnOllamaRefresh: TButton
            Left = 332
            Top = 104
            Width = 240
            Height = 25
            Caption = 'Odswiez modele'
            TabOrder = 2
            OnClick = RefreshOllamaModels
          end
          object seOllamaContext: TSpinEdit
            Left = 230
            Top = 140
            Width = 180
            Height = 27
            MaxValue = 262144
            MinValue = 2048
            TabOrder = 3
            Value = 32768
          end
        end
      end
      object seTimeout: TSpinEdit
        Left = 230
        Top = 320
        Width = 150
        Height = 27
        MaxValue = 1800
        MinValue = 1
        TabOrder = 2
        Value = 180
      end
    end
  end
  object btnOK: TButton
    Left = 440
    Top = 462
    Width = 96
    Height = 25
    Caption = 'Zapisz'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 548
    Top = 462
    Width = 104
    Height = 25
    Cancel = True
    Caption = 'Anuluj'
    ModalResult = 2
    TabOrder = 2
  end
  object ModelsTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ModelsTick
    Left = 552
    Top = 52
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 8
    Top = 52
  end
end
