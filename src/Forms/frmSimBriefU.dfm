object frmSimBrief: TfrmSimBrief
  Left = 0
  Top = 0
  Caption = 'SimBrief Dispatch'
  ClientHeight = 800
  ClientWidth = 1000
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 480
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object ViewHost: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 770
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
  end
  object btnClose: TButton
    Left = 0
    Top = 770
    Width = 1000
    Height = 30
    Align = alBottom
    Cancel = True
    Caption = 'Zamknij'
    ModalResult = 2
    TabOrder = 1
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 8
    Top = 8
  end
end
