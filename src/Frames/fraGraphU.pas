{$StackFrames On}
Unit fraGraphU;

Interface

 Uses
  System.SysUtils, System.Classes, System.Types, System.Actions, Vcl.Controls, Vcl.Forms,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ImgList, Vcl.ActnList,
  LocalizationU, i18nLocalizer, FlightChartsU, i18nCore, System.ImageList;

 Type
  TfraGraph = Class(TFrame)
   Published
    Actions            : TActionList;
    ImageList          : TImageList;
    aZoomIn            : TAction;
    aZoomOut           : TAction;
    aFullView          : TAction;
    aChartsConfigure   : TAction;
    aGraphWindow       : TAction;
    ToolBar2           : TToolBar;
    btnZoomIn          : TToolButton;
    btnZoomOut         : TToolButton;
    btnFullView        : TToolButton;
    Separator1         : TToolButton;
    btnChartsConfigure : TToolButton;
    Separator2         : TToolButton;
    btnGraphWindow     : TToolButton;
    Separator3         : TToolButton;
    lView              : TLabel;
    ChartsHost         : TScrollBox;
    AppTranslator      : TTranslator;
    Procedure TranslateView(Sender : TObject);
    Procedure Wheel(Sender : TObject; Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint; Var Handled : Boolean);
    Procedure WindowExecute(Sender : TObject);
    Procedure ZoomChart(Sender : TObject);
    Procedure ConfigureExecute(Sender : TObject);
   Private
    fLocalized   : Boolean;
    fOnWindow    : TNotifyEvent;
    fOnConfigure : TNotifyEvent;
    fViewCaption : String;
    fCharts      : TFlightCharts;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Procedure BindActions(ConfigureCharts, WindowAction : TNotifyEvent; UpdateAction : TActionEvent);
    Procedure SetViewCaption(Const Text : String);
    Property Charts : TFlightCharts Read fCharts;
  End;

Implementation

 {$R *.dfm}

 Procedure TfraGraph.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Constructor TfraGraph.Create(AOwner : TComponent);
  Begin
   Inherited;
   fCharts        := TFlightCharts.Create(Self);
   fCharts.Parent := ChartsHost;
   fCharts.Align  := alTop;
  End;

 Procedure TfraGraph.BindActions(ConfigureCharts, WindowAction : TNotifyEvent; UpdateAction : TActionEvent);
  Begin
   fOnWindow        := WindowAction;
   Actions.OnUpdate := UpdateAction;
   fOnConfigure     := ConfigureCharts;
  End;

 Procedure TfraGraph.WindowExecute(Sender : TObject);
  Begin
   If Assigned(fOnWindow) Then
    fOnWindow(Sender);
  End;

 Procedure TfraGraph.ConfigureExecute(Sender : TObject);
  Begin
   If Assigned(fOnConfigure) Then
    fOnConfigure(Sender);
  End;

 Procedure TfraGraph.ZoomChart(Sender : TObject);
  Begin
   If (Sender = aZoomIn) Or (Sender = btnZoomIn) Then
    fCharts.Zoom(0.5)
   Else If (Sender = aZoomOut) Or (Sender = btnZoomOut) Then
    fCharts.Zoom(2)
   Else
    fCharts.ResetView;
  End;

 Procedure TfraGraph.SetViewCaption(Const Text : String);
  Begin
   fViewCaption  := Text;
   lView.Caption := Text;
  End;

 Procedure TfraGraph.TranslateView(Sender : TObject);
  Begin
   If fViewCaption <> '' Then
    lView.Caption := fViewCaption;
  End;

 Procedure TfraGraph.Wheel(Sender : TObject; Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint; Var Handled : Boolean);
  Var
   P : TPoint;
  Begin
   If Handled Or (fCharts = Nil) Or Not ChartsHost.Showing Then
    Exit;
   P := ChartsHost.ScreenToClient(MousePos);
   If Not PtInRect(ChartsHost.ClientRect, P) Then
    Exit;
   If ssCtrl In Shift Then
    Begin
     If WheelDelta > 0 Then
      fCharts.Zoom(0.8)
     Else
      fCharts.Zoom(1.25);
    End
   Else
    ChartsHost.VertScrollBar.Position := ChartsHost.VertScrollBar.Position - Round(WheelDelta / 120 * 100);
   Handled                            := True;
  End;

End.
