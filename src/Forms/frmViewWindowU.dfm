object frmViewWindow: TfrmViewWindow
  HelpContext = 1600
  Left = 0
  Top = 0
  Caption = 'Widok'
  ClientHeight = 600
  ClientWidth = 1000
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 480
  UseDockManager = True
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnDockOver = ViewDockOver
  OnEndDock = DockFinished
  OnStartDock = StartDockPreview
  OnUnDock = ViewUnDock
  PixelsPerInch = 96
  TextHeight = 17
  object AppTranslator: TTranslator
    AutoBiDiLayout = False
    OnAfterTranslate = TranslateTitle
    Left = 8
    Top = 48
  end
end
