object fraSimBriefMap: TfraSimBriefMap
  HelpContext = 900
  Left = 0
  Top = 0
  Width = 400
  Height = 300
  TabOrder = 0
  OnResize = FrameResize
  object MapTitle: TLabel
    Left = 0
    Top = 0
    Width = 400
    Height = 24
    Align = alTop
    AutoSize = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ShowAccelChar = False
    Layout = tlCenter
  end
  object MapStatus: TLabel
    Left = 0
    Top = 24
    Width = 400
    Height = 276
    Align = alClient
    AutoSize = False
    ShowAccelChar = False
    WordWrap = True
  end
  object MapImage: TImage
    Left = 0
    Top = 24
    Width = 400
    Height = 276
    Align = alClient
    Center = True
    Proportional = True
    Stretch = True
  end
end
