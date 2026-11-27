object fraATC: TfraATC
  Left = 0
  Top = 0
  Width = 342
  Height = 786
  HelpContext = 1100
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
    TabOrder = 1
    object WindowButton: TToolButton
      Left = 0
      Top = 0
      Action = aWindow
    end
  end
  object FSHudMemo: TMemo
    Left = 0
    Top = 28
    Width = 342
    Height = 758
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object WindowActions: TActionList
    object aWindow: TAction
      Caption = 'Osobne okno'
      Hint = 'Osobne okno'
      ImageIndex = 0
    end
  end
end
