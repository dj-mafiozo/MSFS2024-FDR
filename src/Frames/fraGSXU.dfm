object fraGSX: TfraGSX
  Left = 0
  Top = 0
  Width = 342
  Height = 786
  HelpContext = 1200
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
  object GSXProgressPanel: TPanel
    Left = 0
    Top = 28
    Width = 342
    Height = 352
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    object GSXBoardingProgressPanel: TPanel
      Left = 0
      Top = 0
      Width = 342
      Height = 68
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      Visible = False
      DesignSize = (
        342
        68)
      object GSXBoardingProgressLabel: TLabel
        Left = 4
        Top = 2
        Width = 334
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object GSXBoardingProgress: TProgressBar
        Left = 4
        Top = 34
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 0
      end
      object GSXBoardingCargoProgress: TProgressBar
        Left = 4
        Top = 50
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 1
      end
    end
    object GSXDeboardingProgressPanel: TPanel
      Left = 0
      Top = 68
      Width = 342
      Height = 68
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      DesignSize = (
        342
        68)
      object GSXDeboardingProgressLabel: TLabel
        Left = 4
        Top = 2
        Width = 334
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object GSXDeboardingProgress: TProgressBar
        Left = 4
        Top = 34
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 0
      end
      object GSXDeboardingCargoProgress: TProgressBar
        Left = 4
        Top = 50
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 1
      end
    end
    object GSXRefuelingProgressPanel: TPanel
      Left = 0
      Top = 136
      Width = 342
      Height = 54
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      Visible = False
      DesignSize = (
        342
        54)
      object GSXRefuelingProgressLabel: TLabel
        Left = 4
        Top = 2
        Width = 334
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object GSXRefuelingProgress: TProgressBar
        Left = 4
        Top = 36
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 0
      end
    end
    object GSXCateringProgressPanel: TPanel
      Left = 0
      Top = 190
      Width = 342
      Height = 54
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      Visible = False
      DesignSize = (
        342
        54)
      object GSXCateringProgressLabel: TLabel
        Left = 4
        Top = 2
        Width = 334
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object GSXCateringProgress: TProgressBar
        Left = 4
        Top = 36
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 0
      end
    end
    object GSXDepartureProgressPanel: TPanel
      Left = 0
      Top = 244
      Width = 342
      Height = 54
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 4
      Visible = False
      DesignSize = (
        342
        54)
      object GSXDepartureProgressLabel: TLabel
        Left = 4
        Top = 2
        Width = 334
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object GSXDepartureProgress: TProgressBar
        Left = 4
        Top = 36
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 0
      end
    end
    object GSXDeiceProgressPanel: TPanel
      Left = 0
      Top = 298
      Width = 342
      Height = 54
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 5
      Visible = False
      DesignSize = (
        342
        54)
      object GSXDeiceProgressLabel: TLabel
        Left = 4
        Top = 2
        Width = 334
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        WordWrap = True
      end
      object GSXDeiceProgress: TProgressBar
        Left = 4
        Top = 36
        Width = 334
        Height = 12
        Anchors = [akLeft, akTop, akRight]
        ParentShowHint = False
        Smooth = True
        ShowHint = True
        TabOrder = 0
      end
    end
  end
  object GSXGrid: TStringGrid
    Left = 0
    Top = 380
    Width = 342
    Height = 406
    Align = alClient
    ColCount = 2
    DefaultColWidth = 180
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowSelect]
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
