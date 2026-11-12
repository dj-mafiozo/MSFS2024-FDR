Unit fraA320PFDU;

Interface

 Uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ImgList, Vcl.ActnList, System.Actions, System.ImageList, FlightDatabaseU, AirbusPFDU;

 Type
  TfraA320PFD = Class(TFrame)
    Actions     : TActionList;
    aWindow     : TAction;
    btnWindow   : TToolButton;
    ImageList1  : TImageList;
    lTime       : TLabel;
    ToolBar1    : TToolBar;
    ToolButton2 : TToolButton;
   Private
    fDisplay   : TAirbusPFD;
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create  (AOwner : TComponent); Override;
    Procedure   SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure   Clear;
    Property Display : TAirbusPFD Read fDisplay;
  End;

Implementation

 Uses
  LocalizationU;
{$R *.dfm}

 Constructor TfraA320PFD.Create(AOwner : TComponent);
  Begin
   Inherited;
   If csDesigning In ComponentState Then
    Exit;
   DoubleBuffered  := True;
   fDisplay        := TAirbusPFD.Create(Self);
   fDisplay.Parent := Self;
   fDisplay.Align  := alClient;
  End;

 Procedure TfraA320PFD.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized And Not(csDesigning In ComponentState) Then
    Begin
     LocalizeRoot(Self);
     aWindow.Caption := Tr('Osobne okno');
     fLocalized      := True;
    End;
  End;

 Procedure TfraA320PFD.SetPoint(Plot : TTripPlot; Index : Integer);
  Begin
   fDisplay.SetPoint(Plot, Index);
   lTime.Caption := fDisplay.Data.Time;
  End;

 Procedure TfraA320PFD.Clear;
  Begin
   fDisplay.Clear;
   lTime.Caption := '';
  End;

End.
