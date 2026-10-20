object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  HelpContext = 600
  BorderStyle = bsDialog
  Caption = 'O programie'
  ClientHeight = 380
  ClientWidth = 580
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object lName: TLabel
    Left = 20
    Top = 20
    Width = 173
    Height = 32
    Caption = 'MSFS2024-FDR'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lVersion: TLabel
    Left = 20
    Top = 80
    Width = 4
    Height = 17
  end
  object lCopyright: TLabel
    Left = 20
    Top = 104
    Width = 4
    Height = 17
  end
  object lTechnology: TLabel
    Left = 20
    Top = 58
    Width = 149
    Height = 17
    Caption = 'Delphi 10.2 / VCL / Win64'
  end
  object lDescription: TLabel
    Left = 20
    Top = 144
    Width = 540
    Height = 52
    AutoSize = False
    Caption = 
      'Rejestrator i przegl'#261'darka lot'#243'w Microsoft Flight Simulator 2024' +
      '.'
    WordWrap = True
  end
  object lAttribution: TLabel
    Left = 20
    Top = 203
    Width = 540
    Height = 70
    AutoSize = False
    Caption = 
      'Pierwotnie oparty na aplikacji Qt5 autorstwa MichaelHsu170. Od t' +
      'ego czasu architektura, interfejs i funkcje zosta'#322'y znacz'#261'co prz' +
      'ebudowane i rozszerzone.'
    WordWrap = True
  end
  object lLicense: TLabel
    Left = 20
    Top = 280
    Width = 375
    Height = 17
    Caption = 'Licencja: GNU AGPL-3.0. Informacje o zale'#380'no'#347'ciach: NOTICE.md.'
  end
  object btnUpstream: TButton
    Left = 20
    Top = 308
    Width = 340
    Height = 24
    Caption = 'MichaelHsu170/MSFS-Flight-Data-Recorder'
    TabOrder = 0
    OnClick = ProjectClick
  end
  object btnHelp: TButton
    Left = 354
    Top = 340
    Width = 98
    Height = 28
    Caption = 'Pomoc'
    TabOrder = 1
    OnClick = HelpClick
  end
  object btnClose: TButton
    Left = 462
    Top = 340
    Width = 98
    Height = 28
    Cancel = True
    Caption = 'Zamknij'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    OnAfterTranslate = RefreshVersion
    Left = 24
    Top = 340
  end
end
