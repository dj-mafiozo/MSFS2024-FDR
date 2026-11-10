object frmChangeLog: TfrmChangeLog
  HelpContext = 610
  Left = 0
  Top = 0
  BiDiMode = bdLeftToRight
  Caption = 'Historia zmian'
  ClientHeight = 650
  ClientWidth = 850
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 420
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  ParentBiDiMode = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 20
  object Content: TRichEdit
    AlignWithMargins = True
    Left = 12
    Top = 12
    Width = 826
    Height = 581
    Margins.Left = 12
    Margins.Top = 12
    Margins.Right = 12
    Margins.Bottom = 12
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    Zoom = 100
  end
  object Buttons: TPanel
    Left = 0
    Top = 605
    Width = 850
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      850
      45)
    object btnClose: TButton
      Left = 720
      Top = 8
      Width = 110
      Height = 28
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Zamknij'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
  end
end
