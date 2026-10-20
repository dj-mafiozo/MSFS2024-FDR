object frmReport: TfrmReport
  Left = 0
  Top = 0
  HelpContext = 400
  Caption = 'Analiza kontaktu z pasem'
  ClientHeight = 600
  ClientWidth = 850
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 19
  object btnClose: TButton
    Left = 0
    Top = 575
    Width = 850
    Height = 25
    Align = alBottom
    Cancel = True
    Caption = 'Zamknij'
    TabOrder = 0
    OnClick = CloseClick
  end
  object ReportGroupBox: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 834
    Height = 559
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object BrowserPanel: TPanel
      AlignWithMargins = True
      Left = 10
      Top = 22
      Width = 814
      Height = 527
      Margins.Left = 8
      Margins.Top = 0
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
    end
    object mReport: TMemo
      AlignWithMargins = True
      Left = 10
      Top = 22
      Width = 814
      Height = 527
      Margins.Left = 8
      Margins.Top = 0
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object StartTimer: TTimer
    Interval = 100
    OnTimer = StartTick
    Left = 200
    Top = 24
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    OnAfterTranslate = TranslateTitle
    Left = 88
    Top = 24
  end
end
