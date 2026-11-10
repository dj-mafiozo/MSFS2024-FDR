Unit fraA320ECAMU;

Interface

 Uses
  System.Classes, System.Actions, System.ImageList, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.ToolWin, Vcl.ActnList, Vcl.ImgList, FlightDatabaseU, AirbusECAMU, AirbusDataU;

 Type
  TfraA320ECAM = Class(TFrame)
    Actions      : TActionList;
    aWindow      : TAction;
    btnAPU       : TSpeedButton;
    btnBLEED     : TSpeedButton;
    btnCOND      : TSpeedButton;
    btnCRUISE    : TSpeedButton;
    btnDOOR      : TSpeedButton;
    btnELEC      : TSpeedButton;
    btnENG       : TSpeedButton;
    btnFCTL      : TSpeedButton;
    btnFUEL      : TSpeedButton;
    btnHYD       : TSpeedButton;
    btnPRESS     : TSpeedButton;
    btnRecorded  : TSpeedButton;
    btnSTS       : TSpeedButton;
    btnWHEEL     : TSpeedButton;
    btnWindow    : TToolButton;
    DisplayPanel : TPanel;
    ImageList1   : TImageList;
    LowerPanel   : TPanel;
    lTime        : TLabel;
    PagePanel    : TFlowPanel;
    ToolBar1     : TToolBar;
    ToolButton2  : TToolButton;
    UpperPanel   : TPanel;
    Procedure FrameResize(Sender : TObject);
    Procedure PageClick(Sender : TObject);
   Private
    fUpper     : TAirbusEWD;
    fLower     : TAirbusSD;
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure Clear;
    Property UpperDisplay : TAirbusEWD Read fUpper;
    Property LowerDisplay : TAirbusSD Read fLower;
  End;

Implementation

 Uses
  LocalizationU;
{$R *.dfm}

 Constructor TfraA320ECAM.Create(AOwner : TComponent);
  Begin
   Inherited;
   If csDesigning In ComponentState Then
    Exit;
   DoubleBuffered := True;
   fUpper         := TAirbusEWD.Create(Self);
   fUpper.Parent  := UpperPanel;
   fUpper.Align   := alClient;
   fLower         := TAirbusSD.Create(Self);
   fLower.Parent  := LowerPanel;
   fLower.Align   := alClient;
   FrameResize(Self);
  End;

 Procedure TfraA320ECAM.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized And Not(csDesigning In ComponentState) Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Procedure TfraA320ECAM.FrameResize(Sender : TObject);
  Var
   Cols : Integer;
  Begin
   If (Parent = Nil) Or (csDesigning In ComponentState) Or (PagePanel = Nil) Or (DisplayPanel = Nil) Or (UpperPanel = Nil) Or (LowerPanel = Nil) Then
    Exit;
   Cols             := Max(1, PagePanel.ClientWidth Div Max(1, btnRecorded.Width));
   PagePanel.Height := ((14 + Cols - 1) Div Cols) * btnRecorded.Height + 4;
   DisplayPanel.DisableAlign;
   Try
    If DisplayPanel.ClientWidth > DisplayPanel.ClientHeight * 1.8 Then
     Begin
      UpperPanel.Align := alLeft;
      UpperPanel.Width := DisplayPanel.ClientWidth Div 2;
     End
    Else
     Begin
      UpperPanel.Align  := alTop;
      UpperPanel.Height := DisplayPanel.ClientHeight Div 2;
     End;
   Finally
    DisplayPanel.EnableAlign;
   End;
  End;

 Procedure TfraA320ECAM.PageClick(Sender : TObject);
  Begin
   If (Sender Is TSpeedButton) And (fLower <> Nil) Then
    Begin
     TSpeedButton(Sender).Down := True;
     fLower.Page               := TSpeedButton(Sender).Tag;
     If fLower.Page < 0 Then
      LowerPanel.HelpContext := 739
     Else
      LowerPanel.HelpContext := 740 + fLower.Page;
    End;
  End;

 Procedure TfraA320ECAM.SetPoint(Plot : TTripPlot; Index : Integer);
  Begin
   fUpper.SetPoint(Plot, Index);
   fLower.SetPoint(Plot, Index);
   lTime.Caption    := 'A320 / ECAM  ' + fUpper.Data.Time;
   btnRecorded.Hint := fLower.Data.RecordedPageSource;
  End;

 Procedure TfraA320ECAM.Clear;
  Begin
   fUpper.Clear;
   fLower.Clear;
   fLower.Page      := -1;
   btnRecorded.Down := True;
   lTime.Caption    := '';
  End;

End.
