object frmSettings: TfrmSettings
  HelpType = htContext
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
    Left = 8
    Top = 8
    Width = 644
    Height = 440
    ActivePage = GeneralPage
    TabOrder = 0
    object GeneralPage: TTabSheet
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
        Height = 25
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Polski'
        Items.Strings = (
          'Polski'
          'English'
          'Deutsch'
          'Espa'#241'ol')
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
    object UnitsPage: TTabSheet
      Caption = 'Jednostki'
      object UnitsEditor: TValueListEditor
        Left = 0
        Top = 0
        Width = 620
        Height = 410
        Align = alClient
        KeyOptions = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
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
        Height = 25
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'Codex (konto ChatGPT / CLI)'
        OnChange = ModelsActivate
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
