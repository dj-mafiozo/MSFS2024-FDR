object frmAssignGroup: TfrmAssignGroup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Przypisz do grupy'
  ClientHeight = 111
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
  object btnOK: TButton
    Left = 174
    Top = 76
    Width = 80
    Height = 28
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 262
    Top = 76
    Width = 80
    Height = 28
    Cancel = True
    Caption = 'Anuluj'
    ModalResult = 2
    TabOrder = 1
  end
  object GroupAssignGroupBox: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 8
    Width = 344
    Height = 57
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 44
    Align = alTop
    Caption = 'Grupa nagrania'
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    Padding.Bottom = 8
    TabOrder = 2
    object cbGroups: TComboBox
      Left = 10
      Top = 22
      Width = 324
      Height = 25
      Align = alBottom
      Style = csDropDownList
      TabOrder = 0
    end
  end
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    Left = 240
    Top = 8
  end
end
