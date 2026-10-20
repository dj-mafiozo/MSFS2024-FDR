object frmAbout: TfrmAbout
  BorderStyle = bsDialog
  Caption = 'O programie'
  ClientHeight = 330
  ClientWidth = 580
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  HelpType = htContext
  HelpContext = 600
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object lName: TLabel
    Left = 20
    Top = 20
    Caption = 'MSFS2024-FDR'
    Font.Height = -24
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lTechnology: TLabel
    Left = 20
    Top = 58
    Caption = 'Delphi 10.2 / VCL / Win64'
  end
  object lDescription: TLabel
    Left = 20
    Top = 94
    Width = 540
    Height = 52
    AutoSize = False
    Caption = 'Rejestrator i przegl'#261'darka lot'#243'w Microsoft Flight Simulator 2024.'
    WordWrap = True
  end
  object lAttribution: TLabel
    Left = 20
    Top = 153
    Width = 540
    Height = 70
    AutoSize = False
    Caption = 'Pierwotnie oparty na aplikacji Qt5 autorstwa MichaelHsu170. Od tego czasu architektura, interfejs i funkcje zosta'#322'y znacz'#261'co przebudowane i rozszerzone.'
    WordWrap = True
  end
  object lLicense: TLabel
    Left = 20
    Top = 230
    Caption = 'Licencja: GNU AGPL-3.0. Informacje o zale'#380'no'#347'ciach: NOTICE.md.'
  end
  object btnUpstream: TButton
    Left = 20
    Top = 258
    Width = 340
    Height = 24
    Caption = 'MichaelHsu170/MSFS-Flight-Data-Recorder'
    OnClick = ProjectClick
    TabOrder = 0
  end
  object btnHelp: TButton
    Left = 354
    Top = 290
    Width = 98
    Height = 28
    Caption = 'Pomoc'
    OnClick = HelpClick
    TabOrder = 1
  end
  object btnClose: TButton
    Left = 462
    Top = 290
    Width = 98
    Height = 28
    Cancel = True
    Default = True
    Caption = 'Zamknij'
    ModalResult = 1
    TabOrder = 2
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 24
    Top = 290
  end
end
