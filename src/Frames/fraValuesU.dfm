object fraValues: TfraValues
  HelpContext = 1700
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
  object DataGrid: TStringGrid
    Left = 0
    Top = 53
    Width = 342
    Height = 761
    Align = alClient
    ColCount = 2
    DefaultColWidth = 145
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object eValueSearch: TEdit
    Left = 0
    Top = 28
    Width = 342
    Height = 25
    Align = alTop
    TabOrder = 1
    TextHint = 'Szukaj parametru'
  end
end
