{$StackFrames On}
Unit fraMapU;

Interface

 Uses
  System.Classes, System.Types, System.Actions, Vcl.Controls, Vcl.Forms,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ImgList, Vcl.ActnList,
  LocalizationU, i18nLocalizer, FlightMapU, i18nCore, System.ImageList;

 Type
  TfraMap = Class(TFrame)
   Published
    Actions       : TActionList;
    ImageList     : TImageList;
    aMapWindow    : TAction;
    ToolBar6      : TToolBar;
    btnMapWindow  : TToolButton;
    MapHost       : TPanel;
    AppTranslator : TTranslator;
    Procedure WindowExecute(Sender : TObject);
   Private
    fLocalized : Boolean;
    fOnWindow : TNotifyEvent;
    fMap      : TFlightMap;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Procedure BindActions(WindowAction : TNotifyEvent; UpdateAction : TActionEvent);
    Property Map : TFlightMap Read fMap;
  End;

Implementation

 {$R *.dfm}

 Procedure TfraMap.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Constructor TfraMap.Create(AOwner : TComponent);
  Begin
   Inherited;
   fMap        := TFlightMap.Create(Self);
   fMap.Parent := MapHost;
   fMap.Align  := alClient;
  End;

 Procedure TfraMap.BindActions(WindowAction : TNotifyEvent; UpdateAction : TActionEvent);
  Begin
   fOnWindow        := WindowAction;
   Actions.OnUpdate := UpdateAction;
  End;

 Procedure TfraMap.WindowExecute(Sender : TObject);
  Begin
   If Assigned(fOnWindow) Then
    fOnWindow(Sender);
  End;

End.
