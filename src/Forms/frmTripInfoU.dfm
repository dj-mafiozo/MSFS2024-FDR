object frmTripInfo: TfrmTripInfo
  Left = 0
  Top = 0
  Caption = 'Informacje o nagraniu'
  ClientHeight = 620
  ClientWidth = 640
  Color = clBtnFace
  Constraints.MinHeight = 360
  Constraints.MinWidth = 540
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object SimBriefPanel: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 76
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object chkAllowOlder: TCheckBox
      Left = 12
      Top = 47
      Width = 495
      Height = 21
      Caption = 'Dopuszczaj starszy plan (wymaga zgodnej zapisanej trasy)'
      TabOrder = 3
    end
    object eAccount: TEdit
      Left = 12
      Top = 12
      Width = 225
      Height = 25
      TabOrder = 0
      TextHint = 'SimBrief username / Pilot ID'
    end
    object btnImport: TButton
      Left = 245
      Top = 10
      Width = 135
      Height = 28
      Caption = 'Import SimBrief'
      TabOrder = 1
      OnClick = ImportClick
    end
    object btnOFP: TButton
      Left = 388
      Top = 10
      Width = 115
      Height = 28
      Caption = 'Zapisz OFP'
      TabOrder = 2
      OnClick = OFPClick
    end
  end
  object mInfo: TMemo
    Left = 0
    Top = 76
    Width = 640
    Height = 500
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object ButtonsPanel: TPanel
    Left = 0
    Top = 576
    Width = 640
    Height = 44
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      640
      44)
    object btnRefresh: TButton
      Left = 12
      Top = 9
      Width = 100
      Height = 27
      Caption = 'Od'#347'wie'#380
      TabOrder = 0
      OnClick = RefreshClick
    end
    object btnClose: TButton
      Left = 524
      Top = 9
      Width = 100
      Height = 27
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Zamknij'
      Default = True
      ModalResult = 2
      TabOrder = 1
    end
  end
  object FetchTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = FetchTick
    Left = 552
    Top = 12
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 8
    Top = 8
  end
end
