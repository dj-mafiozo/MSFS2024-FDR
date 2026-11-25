object fraChecklists: TfraChecklists
  HelpContext = 2000
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
  object ChecklistSelector: TComboBox
    Left = 0
    Top = 28
    Width = 342
    Height = 25
    Align = alTop
    Style = csDropDownList
    TabOrder = 0
  end
  object ChecklistEmpty: TLabel
    Left = 0
    Top = 53
    Width = 342
    Height = 40
    Align = alTop
    AutoSize = False
    WordWrap = True
    Caption = 'Brak zapisanych checklist w tym nagraniu.'
  end
  object ChecklistItems: TCheckListBox
    Left = 0
    Top = 93
    Width = 342
    Height = 721
    Align = alClient
    AllowGrayed = True
    ItemHeight = 17
    TabOrder = 1
  end
end
