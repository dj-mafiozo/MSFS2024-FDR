{$StackFrames On}
Unit fraEnginesU;

Interface

 Uses
  System.Classes, System.Actions, Vcl.ActnList, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  FlightDatabaseU, EngineGaugesU, LocalizationU, Vcl.ComCtrls, Vcl.ToolWin,
  System.ImageList, Vcl.ImgList;

 Type
  TfraEngines = Class(TFrame)
    Actions     : TActionList;
    aWindow     : TAction;
    btnWindow   : TToolButton;
    ImageList1  : TImageList;
    lTime       : TLabel;
    ToolBar1    : TToolBar;
    ToolButton2 : TToolButton;
    Procedure FrameResize(Sender : TObject);
   Private
    fLocalized : Boolean;
    fDisplay   : TEngineGauges;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure Clear;
    Property Display : TEngineGauges Read fDisplay;
  End;

Implementation

 Uses
  InstrumentDataU;
{$R *.dfm}

// Direct TFrame ancestry keeps inline-frame loading compatible with the IDE.

 Procedure TfraEngines.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized And Not(csDesigning In ComponentState) Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Constructor TfraEngines.Create(AOwner : TComponent);
  Begin
   Inherited;
   If csDesigning In ComponentState Then
    Exit;
   DoubleBuffered  := True;
   fDisplay        := TEngineGauges.Create(Self);
   fDisplay.Parent := Self;
   fDisplay.Align  := alClient;
   fDisplay.Left   := 0;
   fDisplay.Top    := 0;
   FrameResize(Self);
  End;

 Procedure TfraEngines.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   Profile : TInstrumentProfile;
  Begin
   fDisplay.SetPoint(Plot, Index);
   Profile := fDisplay.Profile;
   If fDisplay.IsB38M Then
    lTime.Caption := 'B38M / EICAS  ' + fDisplay.Time
   Else
    lTime.Caption := InstrumentKindName(Profile.Kind) + '  ' + fDisplay.Time;
   FrameResize(Self);
  End;

 Procedure TfraEngines.Clear;
  Begin
   fDisplay.Clear;
   lTime.Caption := '';
  End;

 Procedure TfraEngines.FrameResize(Sender : TObject);
  Begin
   If fDisplay <> Nil Then
    fDisplay.Invalidate;
  End;

End.
