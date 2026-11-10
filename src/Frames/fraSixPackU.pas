{$StackFrames On}
Unit fraSixPackU;

Interface

 Uses
  System.Classes, System.Actions, Vcl.ActnList, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  FlightDatabaseU, SixPackU, LocalizationU, EngineGaugesU, InstrumentDataU,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin;

 Type
  TfraSixPack = Class(TFrame)
    ToolBar1    : TToolBar;
    btnWindow   : TToolButton;
    ToolButton2 : TToolButton;
    ImageList1  : TImageList;
    lTime       : TLabel;
    Actions     : TActionList;
    aWindow     : TAction;
   Private
    fLocalized           : Boolean;
    fShowEmbeddedEngines : Boolean;
    fDisplay             : TSixPackDisplay;
    fEngines             : TEngineGauges;
    Procedure SetShowEmbeddedEngines(Value : Boolean);
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure Clear;
    Property Display             : TSixPackDisplay Read fDisplay;
    Property ShowEmbeddedEngines : Boolean Read fShowEmbeddedEngines Write SetShowEmbeddedEngines;
  End;

Implementation

{$R *.dfm}

// Direct TFrame ancestry keeps inline-frame loading compatible with the IDE.

 Procedure TfraSixPack.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized And Not(csDesigning In ComponentState) Then
    Begin
     aWindow.Caption := Tr('Osobne okno');
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Procedure TfraSixPack.SetShowEmbeddedEngines(Value : Boolean);
  Begin
   fShowEmbeddedEngines := Value;
   If Not Value And (fEngines <> Nil) Then
    fEngines.Visible := False;
  End;

 Constructor TfraSixPack.Create(AOwner : TComponent);
  Begin
   Inherited;
   If csDesigning In ComponentState Then
    Exit;
   fShowEmbeddedEngines := True;
   DoubleBuffered       := True;
   fDisplay             := TSixPackDisplay.Create(Self);
   fDisplay.Parent      := Self;
   fDisplay.Align       := alClient;
   fEngines             := TEngineGauges.Create(Self);
   fEngines.Parent      := Self;
   fEngines.Align       := alBottom;
   fEngines.Height      := 145;
   fEngines.Compact     := True;
   fEngines.Visible     := False;
  End;

 Procedure TfraSixPack.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   Profile : TInstrumentProfile;
  Begin
   fDisplay.SetPoint(Plot, Index);
   Profile          := InstrumentProfile(Plot, Index);
   fEngines.Visible := fShowEmbeddedEngines And (Plot <> Nil) And (Profile.EngineCount > 0) And (Profile.Kind In [ikGaAnalog, ikGaGlass]);
   If fEngines.Visible Then
    fEngines.SetPoint(Plot, Index)
   Else
    fEngines.Clear;
   lTime.Caption := fDisplay.State.Time;
  End;

 Procedure TfraSixPack.Clear;
  Begin
   fDisplay.Clear;
   fEngines.Clear;
   fEngines.Visible := False;
   lTime.Caption    := '';
  End;

End.
