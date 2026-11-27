object fraFlightPlan: TfraFlightPlan
  Left = 0
  Top = 0
  Width = 342
  Height = 786
  HelpContext = 1000
  TabOrder = 0
  object WindowToolbar: TToolBar
    Left = 0
    Top = 0
    Width = 342
    Height = 28
    ButtonHeight = 26
    ButtonWidth = 28
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object WindowButton: TToolButton
      Left = 0
      Top = 0
      Action = aWindow
    end
  end
  object mPlan: TMemo
    Left = 0
    Top = 56
    Width = 342
    Height = 730
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ToolBar5: TToolBar
    Left = 0
    Top = 28
    Width = 342
    Height = 28
    ButtonHeight = 28
    ButtonWidth = 146
    Caption = 'ToolBar5'
    List = True
    ParentShowHint = False
    ShowCaptions = True
    ShowHint = True
    TabOrder = 1
    object ToolButton7: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
    end
  end
  object WindowActions: TActionList
    object aWindow: TAction
      Caption = 'Osobne okno'
      Hint = 'Osobne okno'
      ImageIndex = 0
    end
  end
end
