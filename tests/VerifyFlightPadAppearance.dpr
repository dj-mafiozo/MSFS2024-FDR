Program VerifyFlightPadAppearance;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON, System.Classes,
 FlightPadScreenIPCU, FlightPadScreensU, FMCScreensU, FMCStyleU, FlightTelemetryU, FlightDatabaseU, Vcl.Graphics, TelemetryCatalogU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Start    : TStartupInfo;
 Process  : TProcessInformation;
 Command  : String;
 Root     : String;
 Text     : String;
 Snapshot : TFlightPadScreenSnapshot;
 Stop     : THandle;
 Change   : THandle;
 Offline  : THandle;
 Before   : UInt64;
 s        : TFlightSample;
 DB       : TFlightDatabase;
 Trip     : Integer;
 i        : Integer;
 Style    : TFMCStyle;
 Screen   : TJSONObject;

Procedure WaitFor(Const Token : String; Available : Boolean);
 Var
  Deadline : UInt64;
 Begin
  Deadline := GetTickCount64 + 5000;
  Repeat
   If ReadFlightPadScreenStatePID('FenixA320', Process.dwProcessId, Snapshot) And (Snapshot.Available = Available) And (Pos(Token, Snapshot.AppearanceJSON) > 0) Then
    Exit;
   Sleep(20);
  Until GetTickCount64 > Deadline;
  Raise Exception.Create('Timed out waiting for v2 appearance ' + Token);
 End;

Procedure Capture;
 Begin
  FreeAndNil(s.AircraftData);
  s.AircraftData := TJSONObject.Create;
  s.AircraftData.AddPair('provider', 'FenixA32X');
  AttachFlightPadScreen(s.AircraftData, Process.dwProcessId);
  DB.RecordSample(Trip, s);
 End;

Type

 [TestFixture]
 TVerifyFlightPadAppearanceTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyFlightPadAppearanceTests.Regression;
 Begin
  Root := TestDataDirectory;
  FillChar(Start, SizeOf(Start), 0);
  Start.cb          := SizeOf(Start);
  Start.dwFlags     := STARTF_USESHOWWINDOW;
  Start.wShowWindow := SW_HIDE;
  Command           := '"' + Root + 'MockFlightPad32.exe" FenixA320 appearance';
  UniqueString(Command);
  Check(CreateProcess(Nil, PChar(Command), Nil, Nil, False, CREATE_NO_WINDOW, Nil, Nil, Start, Process), 'Start Win32 publisher');
  Stop    := 0;
  Change  := 0;
  Offline := 0;
  s       := TFlightSample.Create;
  DB      := TFlightDatabase.Create(TestDatabasePath(Root + 'flightpad-appearance-test.db'), Root + 'sqlite3.dll');
  Try
   WaitFor('00FF0001', True);
   Text   := Snapshot.Text;
   Before := Snapshot.ScreenTick;
   Check(Snapshot.ProcessID = Process.dwProcessId, 'Win32 publisher identity');
   For i := 0 To FieldCount - 1 Do
    Begin
     If SimFields[i].Name = 'time_zulu.year' Then
      s.Numbers[i] := 2026;
     If SimFields[i].Name = 'time_zulu.month' Then
      s.Numbers[i] := 10;
     If SimFields[i].Name = 'time_zulu.day' Then
      s.Numbers[i] := 21;
    End;
   Trip := DB.StartTrip(s);
   Capture;
   Capture;
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t', [Trip]) = 1, 'Heartbeat is not a screen change');
   Screen := s.AircraftData.GetValue('cdu').GetValue<TJSONObject>('0');
   Style  := TFMCStyle.Create(Screen.GetValue('style_json').Value);
   Try
    Check(Style.Cell(0, 0).Small And (Style.Cell(0, 0).Foreground = clLime), 'RGB/small round trip');
   Finally
    Style.Free;
   End;
   Check(Screen.GetValue('annunciators_json').Value.Contains('"FM2":null'), 'Unknown lamp stays unknown');
   Change := OpenEvent(EVENT_MODIFY_STATE, False, PChar('Local\FDR.FlightPad.TestChange.' + IntToStr(Process.dwProcessId)));
   Check(Change <> 0, 'Change event');
   SetEvent(Change);
   WaitFor('FF000001', True);
   Check((Snapshot.Text = Text) And (Snapshot.ScreenTick > Before), 'Style-only timestamp');
   Capture;
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t', [Trip]) = 2, 'Style-only delta stored');
   Offline := OpenEvent(EVENT_MODIFY_STATE, False, PChar('Local\FDR.FlightPad.TestOffline.' + IntToStr(Process.dwProcessId)));
   Check(Offline <> 0, 'Offline event');
   SetEvent(Offline);
   WaitFor('DISCONNECTED', False);
   Capture;
   Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens where trip=:t order by id desc limit 1', [Trip]) = 0, 'Unavailable transition stored');
   Check(String(DB.Connection.ExecSQLScalar('select style_json from trip_fmc_screens where trip=:t order by id desc limit 1', [Trip])).Contains('DISCONNECTED'), 'Overlay retained');
   System.Writeln('PASS: Win32-to-Win64 v2 appearance IPC, RGB/small fonts, known/unknown lamps, style-only timestamps/deltas, heartbeat suppression and unavailable/overlay capture. Mock publishers only.');
  Finally
   Stop := OpenEvent(EVENT_MODIFY_STATE, False, PChar('Local\FDR.FlightPad.TestStop.' + IntToStr(Process.dwProcessId)));
   If Stop <> 0 Then
    Begin
     SetEvent(Stop);
     WaitForSingleObject(Process.hProcess, 5000);
     CloseHandle(Stop);
    End;
   CloseHandle(Change);
   CloseHandle(Offline);
   CloseHandle(Process.hThread);
   CloseHandle(Process.hProcess);
   DB.Free;
   s.Free;
  End;

 End;

Begin
 RunNativeTests(TVerifyFlightPadAppearanceTests);

End.
