object frmViewWindow: TfrmViewWindow
  Left = 0
  Top = 0
  Caption = 'Widok'
  ClientHeight = 600
  ClientWidth = 1000
  Constraints.MinHeight = 300
  Constraints.MinWidth = 480
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 17
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    OnAfterTranslate = TranslateTitle
    Left = 8
    Top = 48
  end
end
