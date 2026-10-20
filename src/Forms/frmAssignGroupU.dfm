object frmAssignGroup: TfrmAssignGroup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Przypisz do grupy'
  ClientHeight = 126
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 17
  object lGroup: TLabel
    Left = 12
    Top = 12
    Width = 91
    Height = 17
    Caption = 'Grupa nagrania'
  end
  object cbGroups: TComboBox
    Left = 12
    Top = 36
    Width = 336
    Height = 25
    Style = csDropDownList
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 180
    Top = 84
    Width = 80
    Height = 28
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 268
    Top = 84
    Width = 80
    Height = 28
    Cancel = True
    Caption = 'Anuluj'
    ModalResult = 2
    TabOrder = 2
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 16
    Top = 80
  end
end
