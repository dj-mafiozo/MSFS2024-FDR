Program VerifyHelpAbout;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.Classes, System.IOUtils, System.Types, System.Generics.Collections, Winapi.Windows, Winapi.Messages,
 Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Imaging.pngimage,
 FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, frmMainU, frmAboutU, LocalizationU, AppHelpU, ParameterNamesU;

Procedure Check(Value : Boolean; Const Msg : String);
 Begin
  If Not Value Then
   Raise Exception.Create(Msg);
 End;

Procedure Screenshot(Form : TForm; Const Path : String);
 Var
  b : TBitmap;
  p : TPngImage;
 Begin
  b := Form.GetFormImage;
  p := TPngImage.Create;
  Try
   p.Assign(b);
   p.SaveToFile(Path);
  Finally
   p.Free;
   b.Free;
  End;
 End;

Type
 TProbe = Class
  Seen      : Boolean;
  Failure   : String;
  ImagePath : String;
  Procedure Tick(Sender : TObject);
 End;

Procedure TProbe.Tick(Sender : TObject);
 Var
  i : Integer;
  d : TfrmAbout;
 Begin
  For i := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[i] Is TfrmAbout Then
    Begin
     TTimer(Sender).Enabled := False;
     d                      := TfrmAbout(Screen.Forms[i]);
     Seen                   := True;
     Try
      Check(d.Caption = 'O programie', 'Polish About caption');
      Check(d.BorderStyle = bsDialog, 'About dialog border');
      Check(Pos('AGPL-3.0', d.lLicense.Caption) > 0, 'License attribution');
      Screenshot(d, ImagePath);
      SetLanguage('en-US');
      Check(d.Caption = 'About', 'Live About translation');
      SetLanguage('de-DE');
      Check(d.btnClose.Caption = 'Schlie' + #$00DF + 'en', 'German About translation');
      SetLanguage('es-ES');
      Check(d.btnClose.Caption = 'Cerrar', 'Spanish About translation');
      SetLanguage('pl-PL');
     Except
      On E : Exception Do
       Failure := E.Message;
     End;
     d.btnClose.Click;
     Exit;
    End;
 End;

Type
 THtmlHelp = Function(Caller : HWND; FileName : PWideChar; Command : UINT; Data : NativeUInt) : HWND;

 Stdcall;

Const
 Languages : Array [0..3] Of String = ('pl-PL', 'en-US', 'de-DE', 'es-ES');

Var
 Main     : TfrmMain;
 Probe    : TProbe;
 Timer    : TTimer;
 Root     : String;
 Docs     : String;
 b        : TBitmap;
 BG       : TColor;
 CallHelp : Boolean;
 Lang     : String;
 Viewer   : HWND;
 DB       : TFlightDatabase;
 Sample   : TFlightSample;
 TripID   : Integer;
 k        : Integer;
 i        : Integer;
 Indices  : TList<Integer>;
 Module   : HMODULE;
 HtmlHelp : THtmlHelp;
 HelpInfo : THelpInfo;

Type

 [TestFixture]
 TVerifyHelpAboutTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyHelpAboutTests.Regression;
 Begin
  Try
   Application.Initialize;
   SetLanguage('pl-PL');
   Root := TestDataDirectory;
   Docs := TestRepositoryPath('docs\screenshots');
   ForceDirectories(Docs);
   // Explicit fixture: never depend on the last trip left by a previous test.
   DB     := TFlightDatabase.Create(TestDatabasePath(TPath.Combine(Root, 'flight_data.db')), TPath.Combine(Root, 'sqlite3.dll'));
   Sample := TFlightSample.Create;
   Try
    For k := 0 To FieldCount - 1 Do
     Begin
      If SimFields[k].Name = 'number_of_engines' Then
       Sample.Numbers[k] := 2;
      If SimFields[k].Name = 'time_zulu.year' Then
       Sample.Numbers[k] := 2026;
      If SimFields[k].Name = 'time_zulu.month' Then
       Sample.Numbers[k] := 10;
      If SimFields[k].Name = 'time_zulu.day' Then
       Sample.Numbers[k] := 21;
      If SimFields[k].Name = 'title' Then
       Sample.Texts[k] := 'Help fixture';
     End;
    TripID := DB.StartTrip(Sample);
    DB.RecordSample(TripID, Sample);
    DB.EndTrip(TripID, Sample);
   Finally
    Sample.Free;
    DB.Free;
   End;
   Main := TfrmMain.Create(Nil);
   SetLanguage('pl-PL');
   Probe := TProbe.Create;
   Timer := TTimer.Create(Nil);
   b     := TBitmap.Create;
   Try
    Main.Timer.Enabled  := False;
    Main.aTiles.Checked := False;
    Main.aTilesExecute(Main.aTiles);
    Main.Position := poDesigned;
    Main.Left     := -4000;
    Main.Show;
    Main.cbGroup.ItemIndex := 0;
    Main.GroupChanged(Main.cbGroup);
    Main.SelectRecording(TripID);
    Check(Main.RecordingRows.Locate('id', TripID, []), 'Help fixture visible');
    Main.SelectTrip(Main);
    Application.ProcessMessages;
    Check((Main.ImageListSmall.Width = 16) And (Main.ImageListSmall.Height = 16) And (Main.ImageListSmall.Count >= 40), 'Small icon dimensions/indices');
    Check(Not Main.ImageListSmall.Masked, 'Small icons use alpha');
    b.SetSize(16, 16);
    BG                   := RGB(155, 183, 209);
    b.Canvas.Brush.Color := BG;
    b.Canvas.FillRect(Rect(0, 0, 16, 16));
    Main.ImageListSmall.Draw(b.Canvas, 0, 0, 0);
    Check(ColorToRGB(b.Canvas.Pixels[15, 15]) = BG, 'Transparent icon corner');
    b.Canvas.Brush.Color := BG;
    b.Canvas.FillRect(Rect(0, 0, 16, 16));
    Main.ImageListSmall.Draw(b.Canvas, 0, 0, 34);
    Check(ColorToRGB(b.Canvas.Pixels[0, 0]) = BG, 'New analysis icon transparent background');
    Main.miMapWindow.Action       := Nil;
    Main.miGraphWindow.Action     := Nil;
    Main.miZoomIn.Action          := Nil;
    Main.miZoomOut.Action         := Nil;
    Main.miFullView.Action        := Nil;
    Main.miChartsConfigure.Action := Nil;
    Main.FrameMenuOpen(Main.miView);
    Check(Not Main.miMapWindow.Visible And Not Main.miGraphWindow.Visible And Not Main.miZoomIn.Visible And Not Main.miZoomOut.Visible And Not Main.miFullView.Visible And Not Main.miChartsConfigure.Visible, 'Unbound menu items hidden');
    Main.miMapWindow.Action       := Main.aMapWindow;
    Main.miGraphWindow.Action     := Main.aGraphWindow;
    Main.miZoomIn.Action          := Main.aZoomIn;
    Main.miZoomOut.Action         := Main.aZoomOut;
    Main.miFullView.Action        := Main.aFullView;
    Main.miChartsConfigure.Action := Main.aChartsConfigure;
    Main.FrameMenuOpen(Main.miView);
    Check(Main.miGraphWindow.Visible And Main.miZoomIn.Visible, 'Bound menu items restored');
    Indices := TList<Integer>.Create;
    Try
     For i := 1 To Main.DataGrid.RowCount - 1 Do
      If (Main.DataGrid.Cells[0, i] = ParameterCaption('plane_altitude')) Or (Main.DataGrid.Cells[0, i] = ParameterCaption('vertical_speed')) Or (Main.DataGrid.Cells[0, i] = ParameterCaption('turb_eng_n1 #1')) Then
       Indices.Add(i - 1);
     Check(Indices.Count = 3, 'Readable inspector captions for recorded parameters');
     Main.GraphFrame.Charts.Select(Indices);
    Finally
     Indices.Free;
    End;
    Main.DataTabs.ActivePage := Main.ValuesPage;
    Application.ProcessMessages;
    Screenshot(Main, TPath.Combine(Docs, 'main.png'));
    Main.aGraphWindow.Execute;
    Application.ProcessMessages;
    Check(Main.GraphWindow.HelpContext = 300, 'Detached window inherits chart help context');
    Screenshot(Main.GraphWindow, TPath.Combine(Docs, 'charts-window.png'));
    Main.GraphWindow.Close;
    Application.ProcessMessages;
    Probe.ImagePath := TPath.Combine(Docs, 'about.png');
    Timer.Interval  := 30;
    Timer.OnTimer   := Probe.Tick;
    Timer.Enabled   := True;
    Main.aAboutExecute(Main.aAbout);
    Check(Probe.Seen, 'About action opens modal dialog');
    Check(Probe.Failure = '', Probe.Failure);
    For Lang In Languages Do
     Begin
      SetLanguage(Lang);
      CallHelp := True;
      Main.AppHelp(HELP_CONTEXT, 300, CallHelp);
      Check(CallHelp, 'Compiled help available');
      Check(Pos(Copy(Lang, 1, 2) + '.chm', Application.HelpFile) > 0, 'Language-specific CHM');
      Check(TFile.ReadAllBytes(Application.HelpFile)[0] = Ord('I'), 'CHM signature');
     End;
    SetLanguage('pl-PL');
    Check(HelpContextFor(Main.GraphFrame.ChartsHost) = 300, 'Chart help context');
    Check(HelpContextFor(Main.MapFrame.MapHost) = 200, 'Map help context');
    FillChar(HelpInfo, SizeOf(HelpInfo), 0);
    HelpInfo.cbSize       := SizeOf(HelpInfo);
    HelpInfo.iContextType := HELPINFO_WINDOW;
    HelpInfo.hItemHandle  := Main.GraphFrame.ChartsHost.Handle;
    HelpInfo.dwContextId  := 300;
    Main.Perform(WM_HELP, 0, LPARAM(@HelpInfo));
    Application.ProcessMessages;
    Viewer := FindWindow('HH Parent', Nil);
    Check(Viewer <> 0, 'WM_HELP opens compiled HTML Help viewer');
    Module := LoadLibrary('hhctrl.ocx');
    If Module <> 0 Then
     Begin
      HtmlHelp := THtmlHelp(GetProcAddress(Module, 'HtmlHelpW'));
      If Assigned(HtmlHelp) Then
       HtmlHelp(0, Nil, $12, 0);
      FreeLibrary(Module);
     End;
   Finally
    b.Free;
    Timer.Free;
    Probe.Free;
    Main.Free;
   End;
   System.Writeln('PASS: 16px alpha menu icons, nil-action menu visibility, modal localized About, six help contexts, four CHMs, real WM_HELP viewer and synthetic screenshots.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyHelpAboutTests);
End.
