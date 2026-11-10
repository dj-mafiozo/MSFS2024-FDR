object frmWeather: TfrmWeather
  HelpContext = 1300
  Left = 0
  Top = 0
  Caption = 'METAR / TAF'
  ClientHeight = 720
  ClientWidth = 1000
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 720
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object Events: TComboBox
    Left = 0
    Top = 0
    Width = 1000
    Height = 25
    Align = alTop
    Style = csDropDownList
    TabOrder = 0
    OnChange = EventChanged
  end
  object Buttons: TPanel
    Left = 0
    Top = 678
    Width = 1000
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      1000
      42)
    object btnRefresh: TButton
      Left = 8
      Top = 8
      Width = 150
      Height = 27
      Caption = 'Od'#347'wie'#380
      TabOrder = 0
      OnClick = RefreshClick
    end
    object btnFetch: TButton
      Left = 166
      Top = 8
      Width = 260
      Height = 27
      Caption = 'Pobierz archiwalny METAR real'
      TabOrder = 1
      OnClick = FetchClick
    end
    object btnClose: TButton
      Left = 882
      Top = 8
      Width = 110
      Height = 27
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Zamknij'
      ModalResult = 1
      TabOrder = 2
    end
  end
  object CompareBox: TGroupBox
    Left = 0
    Top = 500
    Width = 1000
    Height = 178
    Align = alBottom
    Caption = 'Por'#243'wnanie'
    TabOrder = 2
    object CompareMemo: TMemo
      Left = 2
      Top = 19
      Width = 996
      Height = 157
      Align = alClient
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Sources: TPanel
    Left = 0
    Top = 25
    Width = 1000
    Height = 475
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    OnResize = SourcesResize
    object SimulatorBox: TGroupBox
      Left = 0
      Top = 0
      Width = 500
      Height = 475
      Align = alLeft
      Caption = 'MSFS / Coherent'
      TabOrder = 0
      object SimulatorMemo: TMemo
        Left = 2
        Top = 19
        Width = 496
        Height = 454
        Align = alClient
        BiDiMode = bdLeftToRight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Consolas'
        Font.Style = []
        ParentBiDiMode = False
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object RealBox: TGroupBox
      Left = 500
      Top = 0
      Width = 500
      Height = 475
      Align = alClient
      Caption = 'aviationweather.gov'
      TabOrder = 1
      object RealMemo: TMemo
        Left = 2
        Top = 19
        Width = 496
        Height = 454
        Align = alClient
        BiDiMode = bdLeftToRight
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Consolas'
        Font.Style = []
        ParentBiDiMode = False
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object RefreshTimer: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = RefreshClick
    Left = 440
    Top = 680
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 480
    Top = 680
  end
end
