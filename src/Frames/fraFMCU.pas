{$StackFrames On}
Unit fraFMCU;

Interface

 Uses
  System.Classes, System.SysUtils, System.Actions, Vcl.ActnList, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, Vcl.Imaging.pngimage, System.JSON,
  FireDAC.Comp.Client, FMCReplayU, FMCScreensU, FMCStyleU, LocalizationU, i18nLocalizer,
  Vcl.ToolWin, System.ImageList, Vcl.ImgList;

 Type
  TfraFMC = Class(TFrame)
    Actions       : TActionList;
    AppTranslator : TTranslator;
    aWindow       : TAction;
    btnWindow     : TToolButton;
    DeviceTabs    : TTabControl;
    Display       : TPaintBox;
    ImageList1    : TImageList;
    ToolBar1      : TToolBar;
    ToolButton2   : TToolButton;
    Procedure PaintDisplay (Sender : TObject);
    Procedure DeviceChanged(Sender : TObject);
   Private
    fAirframe   : String;
    fLoading    : Boolean;
    fLocalized  : Boolean;
    fHistory    : TFMCHistory;
    fTime       : TDateTime;
    fCurrent    : TFMCSnapshot;
    fBackground : TPicture;
    fAsset      : String;
    Procedure RefreshScreen;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Constructor Create (AOwner : TComponent); Override;
    Destructor  Destroy; Override;
    Procedure   Load   (Connection : TFDConnection; Trip : Integer);
    Procedure   SetTime(Const Time : String);
    Property AirframeKind : String Read fAirframe;
    Property Current      : TFMCSnapshot Read fCurrent;
  End;

Implementation

 Uses
  System.IOUtils, System.Math, Winapi.Windows, AppPathsU;
{$R *.dfm}

 Procedure TfraFMC.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized                := True;
     DoubleBuffered            := True;
     DeviceTabs.ParentBiDiMode := False;
     DeviceTabs.BiDiMode       := bdLeftToRight;
    End;
  End;

 Constructor TfraFMC.Create(AOwner : TComponent);
  Begin
   Inherited;
   fHistory    := TFMCHistory.Create;
   fBackground := TPicture.Create;

  End;

 Destructor TfraFMC.Destroy;
  Begin
   fCurrent := Nil;
   FreeAndNil(fBackground);
   FreeAndNil(fHistory);
   Inherited;
  End;

 Procedure TfraFMC.Load(Connection : TFDConnection; Trip : Integer);
  Var
   d         : TFMCDeviceHistory;
   LabelText : String;
  Begin
   fLoading := True;
   Try
    fCurrent := Nil;
    DeviceTabs.Tabs.Clear;
    fHistory.Load(Connection, Trip);
    fAirframe := DetectFMCFamily(fHistory.TripTitle, '');
    For d In fHistory.Devices Do
     Begin
      LabelText := d.Device;
      If (LabelText = '0') Or SameText(LabelText, 'capt') Then
       LabelText := 'L'
      Else If (LabelText = '1') Or SameText(LabelText, 'fo') Then
       LabelText := 'R'
      Else If LabelText = '2' Then
       LabelText := 'C';
      DeviceTabs.Tabs.Add('CDU ' + LabelText);
      If fAirframe = '' Then
       fAirframe := DetectFMCFamily('', d.Provider);
     End;
    If DeviceTabs.Tabs.Count > 0 Then
     DeviceTabs.TabIndex := 0;
    DeviceTabs.Visible   := DeviceTabs.Tabs.Count > 1;
    ToolBar1.Height      := ToolBar1.ButtonHeight + 1;
   Finally
    fLoading := False;
   End;
   RefreshScreen;
   Display.Invalidate;
  End;

 Procedure TfraFMC.SetTime(Const Time : String);
  Begin
   If Not FMCTime(Time, fTime) Then
    fTime := 0;
   RefreshScreen;
  End;

 Procedure TfraFMC.DeviceChanged(Sender : TObject);
  Begin
   RefreshScreen;
   If Display <> Nil Then
    Display.Invalidate;
  End;

 Procedure TfraFMC.RefreshScreen;
  Var
   Next : TFMCSnapshot;
  Begin
   If (csLoading In ComponentState) Or (csDestroying In ComponentState) Or (fHistory = Nil) Or fLoading Or (Parent = Nil) Then
    Exit;
   Next := Nil;
   If (DeviceTabs.TabIndex >= 0) And (DeviceTabs.TabIndex < fHistory.Devices.Count) Then
    Next := fHistory.Devices[DeviceTabs.TabIndex].AtTime(fTime);
   If Next = fCurrent Then
    Exit;
   fCurrent := Next;
   Display.Invalidate;
  End;

 Procedure TfraFMC.PaintDisplay(Sender : TObject);
  Var
   c           : TCanvas;
   Asset       : String;
   Path        : String;
   Line        : String;
   Ch          : String;
   Provider    : String;
   Bounds      : TRect;
   ScreenRect  : TRect;
   Cell        : TRect;
   w           : Integer;
   h           : Integer;
   x           : Integer;
   y           : Integer;
   r           : Integer;
   Col         : Integer;
   Scale       : Double;
   CW          : Double;
   RH          : Double;
   Lamps       : TJSONValue;
   Airbus      : Boolean;
   TripleSeven : Boolean;
   Powered     : Boolean;

   Appearance : TFMCStyle;
   CellStyle  : TFMCCellStyle;

   Function NRect(l, t, r, b : Double) : TRect;
    Begin
     Result := Rect(Bounds.Left + Round(l * w), Bounds.Top + Round(t * h), Bounds.Left + Round(r * w), Bounds.Top + Round(b * h));
    End;

   Procedure Lamp(Const Name : String; l, t, r, b : Double; Color : TColor; Vertical : Boolean);
    Var
     v    : TJSONValue;
     q    : TRect;
     i    : Integer;
     Step : Integer;
    Begin
     If Not Powered Or Not(Lamps Is TJSONObject) Then
      Exit;
     v := TJSONObject(Lamps).GetValue(Name);
     If (v = Nil) Or (v Is TJSONNull) Or ((v.Value <> '1') And (v.Value <> 'true') And (v.Value <> '2')) Then
      Exit;
     q             := NRect(l, t, r, b);
     c.Brush.Style := bsSolid;
     c.Brush.Color := clBlack;
     c.FillRect(q);
     c.Font.Name   := 'Consolas';
     c.Font.Style  := [fsBold];
     c.Font.Color  := Color;
     c.Font.Height := -Max(5, Round(h * 0.012));
     c.Brush.Style := bsClear;
     If Name = 'EXEC' Then
      Begin
       c.Brush.Style := bsSolid;
       c.Brush.Color := Color;
       c.FillRect(q);
      End
     Else If Vertical Then
      Begin
       Step  := Max(1, (q.Bottom - q.Top) Div Length(Name));
       For i := 1 To Length(Name) Do
        c.TextOut(q.Left + (q.Width - c.TextWidth(Name[i])) Div 2, q.Top + (i - 1) * Step, Name[i]);
      End
     Else
      DrawText(c.Handle, PChar(Name), Length(Name), q, DT_CENTER Or DT_VCENTER Or DT_SINGLELINE);
    End;

  Begin
   If (csDestroying In ComponentState) Or (fBackground = Nil) Then
    Exit;
   c             := Display.Canvas;
   c.Brush.Color := clBtnFace;
   c.FillRect(Display.ClientRect);
   Provider := fAirframe;
   If fCurrent <> Nil Then
    Provider := DetectFMCFamily('', fCurrent.Screen.Provider);
   If Provider = '' Then
    Provider   := fAirframe;
   Airbus      := Provider = 'A320';
   TripleSeven := Provider = 'B777';
   If Provider = '' Then
    Exit;
   Asset := 'B737-FMC.png';
   If Airbus Then
    Asset := 'A320-MCDU.png'
   Else If TripleSeven Then
    Asset := 'B777-FMC.png';
   If Asset <> fAsset Then
    Begin
     Path := TPath.Combine(ApplicationDirectory, 'Assets\' + Asset);
     If Not TFile.Exists(Path) Then
      Path := TPath.Combine(ApplicationDirectory, '..\Assets\' + Asset);
     If TFile.Exists(Path) Then
      Begin
       fBackground.LoadFromFile(Path);
       fAsset := Asset;
      End
     Else
      Begin
       fBackground.Assign(Nil);
       fAsset := '';
      End;
    End;
   If (fBackground.Width = 0) Or (Display.Width <= 0) Or (Display.Height <= 0) Then
    Exit;
   Scale  := Min(Display.Width / fBackground.Width, Display.Height / fBackground.Height);
   w      := Round(fBackground.Width * Scale);
   h      := Round(fBackground.Height * Scale);
   Bounds := Rect((Display.Width - w) Div 2, (Display.Height - h) Div 2, (Display.Width + w) Div 2, (Display.Height + h) Div 2);
   SetStretchBltMode(c.Handle, HALFTONE);
   c.StretchDraw(Bounds, fBackground.Graphic);
   ScreenRect := NRect(0.1457, 0.0792, 0.8592, 0.4427);
   If Airbus Then
    ScreenRect := NRect(0.15924072, 0.07854814, 0.8425598, 0.4440826)
   Else If TripleSeven Then
    ScreenRect   := NRect(0.14666007, 0.07033213, 0.84544694, 0.43650627);
   Powered       := (fCurrent <> Nil) And fCurrent.Screen.Available And (fCurrent.Screen.PowerState <> 0);
   c.Brush.Style := bsSolid;
   c.Brush.Color := clBlack;
   c.FillRect(ScreenRect);
   If Not Powered Then
    Begin
     If fCurrent <> Nil Then
      Begin
       Appearance := TFMCStyle.Create(fCurrent.Screen.StyleJSON);
       Try
        If Appearance.Overlay <> '' Then
         Begin
          c.Brush.Style := bsClear;
          c.Font.Name   := 'Consolas';
          c.Font.Color  := clSilver;
          c.Font.Height := -Max(8, Round(ScreenRect.Height / 16));
          DrawText(c.Handle, PChar(Appearance.Overlay), Length(Appearance.Overlay), ScreenRect, DT_CENTER Or DT_WORDBREAK);
         End;
       Finally
        Appearance.Free;
       End;
      End;
     Exit;
    End;
   Appearance := TFMCStyle.Create(fCurrent.Screen.StyleJSON);
   Lamps      := TJSONObject.ParseJSONValue(fCurrent.Screen.AnnunciatorsJSON);
   Try
    CW    := ScreenRect.Width / 24;
    RH    := ScreenRect.Height / 14;
    For r := 0 To Min(13, fCurrent.Screen.Lines.Count - 1) Do
     Begin
      Line    := fCurrent.Screen.Lines[r];
      For Col := 0 To Min(23, Length(Line) - 1) Do
       Begin
        Ch            := Line[Col + 1];
        CellStyle     := Appearance.Cell(r, Col);
        c.Font.Name   := 'Consolas';
        c.Font.Style  := [fsBold];
        c.Font.Height := -Max(1, Round(Min(RH * 0.9, CW * 1.6)));
        If CellStyle.Small Then
         c.Font.Height := -Max(1, Round(Abs(c.Font.Height) * 0.75));
        c.Font.Color   := CellStyle.Foreground;
        Cell           := Rect(ScreenRect.Left + Round(Col * CW), ScreenRect.Top + Round(r * RH), ScreenRect.Left + Round((Col + 1) * CW), ScreenRect.Top + Round((r + 1) * RH));
        c.Brush.Style  := bsSolid;
        c.Brush.Color  := CellStyle.Background;
        c.FillRect(Cell);
        c.Brush.Style := bsClear;
        x             := Cell.Left + (Cell.Width - c.TextWidth(Ch)) Div 2;
        y             := Cell.Top + (Cell.Height - c.TextHeight(Ch)) Div 2;
        c.TextRect(Cell, x, y, Ch);
       End;
     End;
    If Airbus Then
     Begin
      Lamp('FM1', 0.2398, 0.0069, 0.3263, 0.0374, $0000A0FF, False);
      Lamp('FM2', 0.6755, 0.0073, 0.7620, 0.0378, $0000A0FF, False);
      Lamp('FM', 0.0505, 0.7712, 0.0889, 0.8275, clWhite, True);
      Lamp('IND', 0.3480, 0.0069, 0.4345, 0.0374, $0000A0FF, False);
      Lamp('RDY', 0.4579, 0.0073, 0.5445, 0.0378, clLime, False);
      Lamp('FM', 0.5661, 0.0073, 0.6526, 0.0378, clWhite, False);
      Lamp('FAIL', 0.0499, 0.6867, 0.0895, 0.7681, clRed, True);
      Lamp('MCDU MENU', 0.9123, 0.6852, 0.9513, 0.8295, $0000A0FF, True);
     End
    Else If TripleSeven Then
     Begin
      Lamp('EXEC', 0.7782, 0.5377, 0.8714, 0.5569, clLime, False);
      Lamp('DSPY', 0.0343, 0.6762, 0.0745, 0.7442, clWhite, True);
      Lamp('FAIL', 0.0349, 0.7473, 0.0745, 0.8215, clRed, True);
      Lamp('MSG', 0.9237, 0.6758, 0.9639, 0.7350, clWhite, True);
      Lamp('OFST', 0.9237, 0.7362, 0.9639, 0.8215, $0000A0FF, True);
     End
    Else
     Begin
      Lamp('EXEC', 0.7839, 0.5624, 0.8676, 0.5824, clLime, False);
      Lamp('CALL', 0.0441, 0.7100, 0.0868, 0.7829, clWhite, True);
      Lamp('FAIL', 0.0434, 0.7876, 0.0875, 0.8605, clRed, True);
      Lamp('MSG', 0.9132, 0.7095, 0.9589, 0.7838, clWhite, True);
      Lamp('OFST', 0.9140, 0.7876, 0.9589, 0.8605, $0000A0FF, True);
     End;
   Finally
    Appearance.Free;
    Lamps.Free;
   End;
  End;

End.
