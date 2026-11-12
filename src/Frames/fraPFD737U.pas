Unit fraPFD737U;

Interface

 Uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ImgList, Vcl.ActnList, System.Actions, System.ImageList, FlightDatabaseU, Boeing737PFDU;

 Type
  TfraPFD737 = Class(TFrame)
    Actions     : TActionList;
    aWindow     : TAction;
    btnWindow   : TToolButton;
    ImageList1  : TImageList;
    lTime       : TLabel;
    ToolBar1    : TToolBar;
    ToolButton2 : TToolButton;
   Private
    fDisplay   : TPFD737Display;
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create  (AOwner : TComponent); Override;
    Procedure   SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure   Clear;
    Property Display : TPFD737Display Read fDisplay;
  End;

Implementation

 Uses
  LocalizationU;
{$R *.dfm}

 Constructor TfraPFD737.Create(AOwner : TComponent);
  Begin
   Inherited;
   If csDesigning In ComponentState Then
    Exit;
   DoubleBuffered  := True;
   fDisplay        := TPFD737Display.Create(Self);
   fDisplay.Parent := Self;
   fDisplay.Align  := alClient;
  End;

 Procedure TfraPFD737.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized And Not(csDesigning In ComponentState) Then
    Begin
     LocalizeRoot(Self);
     aWindow.Caption := Tr('Osobne okno');
     fLocalized      := True;
    End;
  End;

 Procedure TfraPFD737.SetPoint(Plot : TTripPlot; Index : Integer);
  Begin
   fDisplay.SetPoint(Plot, Index);
   lTime.Caption := fDisplay.State.Time;
  End;

 Procedure TfraPFD737.Clear;
  Begin
   fDisplay.Clear;
   lTime.Caption := '';
  End;

End.
