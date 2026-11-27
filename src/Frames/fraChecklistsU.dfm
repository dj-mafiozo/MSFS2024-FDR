object fraChecklists: TfraChecklists
  Left = 0
  Top = 0
  Width = 342
  Height = 786
  HelpContext = 2000
  TabOrder = 0
  object ChecklistEmpty: TLabel
    Left = 0
    Top = 53
    Width = 342
    Height = 40
    Align = alTop
    AutoSize = False
    Caption = 'Brak zapisanych checklist w tym nagraniu.'
    WordWrap = True
  end
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
  object ChecklistSelector: TComboBox
    Left = 0
    Top = 28
    Width = 342
    Height = 21
    Align = alTop
    Style = csDropDownList
    TabOrder = 0
  end
  object ChecklistItems: TCheckListBox
    Left = 0
    Top = 93
    Width = 342
    Height = 693
    Align = alClient
    AllowGrayed = True
    ItemHeight = 13
    TabOrder = 1
  end
  object WindowActions: TActionList
    object aWindow: TAction
      Caption = 'Osobne okno'
      Hint = 'Osobne okno'
      ImageIndex = 0
    end
  end
end
