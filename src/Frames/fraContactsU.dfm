object fraContacts: TfraContacts
  HelpContext = 1720
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
  object ContactGrid: TDBGrid
    Left = 0
    Top = 28
    Width = 342
    Height = 786
    Align = alClient
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
end
