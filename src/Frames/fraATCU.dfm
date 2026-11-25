object fraATC: TfraATC
  HelpContext = 1100
  Width = 342
  Height = 786
  TabOrder = 0
  object WindowToolbar: TToolBar
    Left = 0
    Top = 0
    Width = 342
    Height = 28
    Align = alTop
    ButtonHeight = 26
    ButtonWidth = 28
    ShowHint = True
    TabOrder = 20
    object WindowButton: TToolButton
      Left = 0
      Top = 0
      Action = aWindow
    end
  end
  object WindowActions: TActionList
    object aWindow: TAction
      Caption = 'Osobne okno'
      Hint = 'Osobne okno'
      ImageIndex = 0
    end
  end
  object FSHudMemo: TMemo
    Left = 0
    Top = 28
    Width = 342
    Height = 786
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
end
