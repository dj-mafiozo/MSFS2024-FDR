Program VerifyRecordingImport;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Vcl.XPMan, Winapi.Windows, System.SysUtils, System.Classes, System.Types, System.IOUtils,
 System.Hash, System.Variants, Vcl.Forms, Vcl.Graphics, Vcl.ActnList, FireDAC.Comp.Client,
 FireDAC.Stan.Param, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', RecordingIndexU In '..\src\Data\RecordingIndexU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas',
 TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', frmMainU In '..\src\Forms\frmMainU.pas', AppPathsU In '..\src\Core\AppPathsU.pas';

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Function FileHash(Const Path : String) : String;
 Var
  Stream : TFileStream;
 Begin
  Stream := TFileStream.Create(Path, fmOpenRead Or fmShareDenyNone);
  Try
   Result := THashSHA2.GetHashString(Stream);
  Finally
   Stream.Free;
  End;
 End;

Function NewFlight(DB : TFlightDatabase; Day : Integer) : Integer;
 Var
  s : TFlightSample;
  i : Integer;
 Begin
  s := TFlightSample.Create;
  Try
   For i := 0 To FieldCount - 1 Do
    Begin
     If SimFields[i].Name = 'title' Then
      s.Texts[i] := 'Import preview test';
     If SimFields[i].Name = 'atc_model' Then
      s.Texts[i] := 'B38M';
     If SimFields[i].Name = 'time_zulu.year' Then
      s.Numbers[i] := 2026;
     If SimFields[i].Name = 'time_zulu.month' Then
      s.Numbers[i] := 10;
     If SimFields[i].Name = 'time_zulu.day' Then
      s.Numbers[i] := Day;
    End;
   Result := DB.StartTrip(s);
   DB.RecordSample(Result, s);
   DB.EndTrip(Result, s);
   DB.Connection.ExecSQL('update trips set departure_icao=''EPLL'',destination_icao=''EPMO'' where id=:id', [Result]);
  Finally
   s.Free;
  End;
 End;

Procedure Preview;
 Var
  m        : TfrmMain;
  DB       : TFlightDatabase;
  Before   : String;
  Rejected : Boolean;
  b        : TBitmap;
 Begin
  Check(PreviewRecordingArgument <> '', 'Existing single argument accepted');
  Before := FileHash(ParamStr(1));
  m      := TfrmMain.Create(Nil);
  Try
   m.Timer.Enabled := False;
   b               := TBitmap.Create;
   Try
    b.SetSize(22, 22);
    b.Canvas.Brush.Color := clWhite;
    b.Canvas.FillRect(Rect(0, 0, 22, 22));
    m.ImageList.Draw(b.Canvas, 0, 0, m.aImportFlight.ImageIndex);
    Check(ColorToRGB(b.Canvas.Pixels[0, 0]) = ColorToRGB(clWhite), 'Import toolbar icon transparent');
    b.Canvas.Brush.Color := clWhite;
    b.Canvas.FillRect(Rect(0, 0, 22, 22));
    m.ImageListSmall.Draw(b.Canvas, 0, 0, m.aImportFlight.ImageIndex);
    Check(ColorToRGB(b.Canvas.Pixels[0, 0]) = ColorToRGB(clWhite), 'Import menu icon transparent');
   Finally
    b.Free;
   End;
   Check(Not m.LeftPanel.Visible, 'Preview hides left panel');
   Check(Not m.SplitLeft.Visible, 'Preview hides splitter');
   Check(Not m.aStart.Enabled And Not m.aStop.Enabled And Not m.aAuto.Enabled, 'Recording disabled');
   Check(Not m.aImportFlight.Enabled And Not m.aDelete.Enabled And Not m.aAssign.Enabled, 'Management disabled');
   Check(m.FMCFrame <> Nil, 'Preview FMC frame available');
   Check(m.DataGrid.RowCount > 2, 'Preview telemetry loaded');
   Check((m.fFMCPage.PageControl = m.DataTabs) And (m.SixPackPanel.Parent = m.InstrumentsPanel) And
   (m.EnginePanel.Parent = m.InstrumentsPanel), 'DFM instrument pages');
   m.aStartExecute(Nil);
   m.aStopExecute(Nil);
   m.aOpenExecute(Nil);
   m.aDeleteExecute(Nil);
   m.Tick(Nil);
   Check(Not FileExists(TPath.Combine(TestDataDirectory, 'flight_data.mfzi')), 'No default index created');
   Check(Not FileExists(TPath.Combine(TestDataDirectory, 'recordings.lock')), 'No recorder lock');
  Finally
   m.Free;
  End;
  DB := TFlightDatabase.Create(ParamStr(1), TestRuntimeFile('sqlite3.dll'), True, True);
  Try
   Rejected := False;
   Try
    DB.Connection.ExecSQL('delete from trips');
   Except
    On E : Exception Do
     Rejected := True;
   End;
   Check(Rejected, 'SQLite rejects writes');
  Finally
   DB.Free;
  End;
  Check(Before = FileHash(ParamStr(1)), 'Preview source unchanged');
  System.Writeln('PASS: single-file command line preview, telemetry, DFM pages, blocked actions, no index/worker lock, read-only database.');
 End;

Procedure Import;
 Var
  DB      : TFlightDatabase;
  Index   : TRecordingIndex;
  Root    : String;
  Legacy  : String;
  First   : String;
  Dropped : String;
  Hash    : String;
  ID      : Integer;
  SI      : TStartupInfo;
  PI      : TProcessInformation;
  Command : String;
  Code    : Cardinal;
 Begin
  Root := TPath.Combine(TestDataDirectory, 'library');
  ForceDirectories(Root);
  Legacy := TPath.Combine(TestDataDirectory, 'flight_data.db');
  DB     := TFlightDatabase.Create(Legacy, TestRuntimeFile('sqlite3.dll'));
  Try
   NewFlight(DB, 21);
  Finally
   DB.Free;
  End;
  Index := TRecordingIndex.Create(TPath.Combine(Root, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'));
  Try
   Index.Migrate(Legacy);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 1, 'First migration');
   DB := TFlightDatabase.Create(Legacy, TestRuntimeFile('sqlite3.dll'));
   Try
    NewFlight(DB, 22);
   Finally
    DB.Free;
   End;
   Hash := FileHash(Legacy);
   Index.Migrate(Legacy);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 2, 'Incremental migration after finished marker');
   Index.Migrate(Legacy);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 2, 'Repeated import idempotent');
   Check(Hash = FileHash(Legacy), 'Legacy bytes unchanged');
   ID    := Index.Connection.ExecSQLScalar('select min(id) from trips');
   First := Index.PathFor(ID);
   Index.Migrate(First);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 2, 'Owned recording is not imported twice');
   Dropped := TPath.Combine(Root, 'dropped.mfzr');
   TFile.Copy(First, Dropped);
   Index.Discover(Root);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 3, 'Dropped recording discovered');
   Index.Discover(Root);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 3, 'Discovery idempotent');
   TFile.WriteAllText(TPath.Combine(Root, 'invalid.mfzr'), 'not sqlite');
   Index.Discover(Root);
   Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 3, 'Bad file does not destroy metadata');
  Finally
   Index.Free;
  End;
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  FillChar(PI, SizeOf(PI), 0);
  Command := '"' + ParamStr(0) + '" "' + First + '"';
  UniqueString(Command);
  Check(CreateProcess(Nil, PChar(Command), Nil, Nil, False, 0, Nil, Nil, SI, PI), 'Launch preview child');
  Try
   Check(WaitForSingleObject(PI.hProcess, 30000) = WAIT_OBJECT_0, 'Preview child finishes');
   Check(GetExitCodeProcess(PI.hProcess, Code) And (Code = 0), 'Preview child success');
  Finally
   CloseHandle(PI.hThread);
   CloseHandle(PI.hProcess);
  End;
  System.Writeln('PASS: incremental legacy migration, unchanged source, repeat import, dropped-file discovery and invalid-file isolation.');
 End;

Type

 [TestFixture]
 TVerifyRecordingImportTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyRecordingImportTests.Regression;
 Begin
  Try
   Application.Initialize;
   Import;
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 If ParamCount = 1 Then
  Begin
   Application.Initialize;
   Preview;
  End
 Else
  RunNativeTests(TVerifyRecordingImportTests);
End.
