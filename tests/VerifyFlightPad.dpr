Program VerifyFlightPad;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
 FireDAC.Comp.Client, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', FMCScreensU In '..\src\FMC\FMCScreensU.pas',
 FlightPadScreenIPCU In '..\src\FMC\FlightPadScreenIPCU.pas', FlightPadScreensU In '..\src\FMC\FlightPadScreensU.pas', AircraftTelemetryU In '..\src\Telemetry\AircraftTelemetryU.pas';

Var
 Publisher : TFlightPadScreenPublisher;
 Snapshot  : TFlightPadScreenSnapshot;
 Other     : TFlightPadScreenSnapshot;
 Root      : TJSONObject;
 Context   : TJSONObject;
 Screens   : TObjectList<TFMCScreen>;
 Text      : String;
 Path      : String;
 Profile   : String;
 Provider  : String;
 r         : Integer;
 k         : Integer;
 Trip      : Integer;
 s         : TFlightSample;
 DB        : TFlightDatabase;
 Startup   : TStartupInfo;
 Process   : TProcessInformation;
 Stop      : THandle;
 Map       : THandle;
 Lock      : THandle;
 View      : Pointer;
 Packet    : TFlightPadScreenPacket;
 Started   : UInt64;
 Registry  : TAircraftProviders;

Procedure Check(b : Boolean; Const Message : String);
 Begin
  If Not b Then
   Raise Exception.Create(Message);
 End;

Procedure SetN(Const Name : String; Value : Double);
 Var
  i : Integer;
 Begin
  For i := 0 To FieldCount - 1 Do
   If SimFields[i].Name = Name Then
    Begin
     s.Numbers[i] := Value;
     Exit;
    End;
 End;

Type

 [TestFixture]
 TVerifyFlightPadTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyFlightPadTests.Regression;
 Begin
  Check(SizeOf(TFlightPadScreenPacket) = 776, 'Stable packed protocol size');
  Text      := '';
  For r     := 0 To 13 Do
   Text     := Text + StringOfChar(' ', 24) + #13#10;
  Publisher := TFlightPadScreenPublisher.Create('FenixA320');
  Try
   Check(Not ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Snapshot), 'No uninitialized screen');
   Publisher.Publish(Text, True);
   Check(ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Snapshot), 'Published screen');
   Check(Snapshot.Text = Text, 'Spaces and CRLF preserved');
   Sleep(20);
   Publisher.Publish(Text, True);
   ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Other);
   Check(Snapshot.ScreenTick = Other.ScreenTick, 'Heartbeat does not change observation timestamp');
   Check(Not ReadFlightPadScreenPID('FBWA320', GetCurrentProcessId, Other), 'Profiles isolated');
   Publisher.Publish('short', True);
   Check(Not ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Other), 'Malformed text unavailable');
   Publisher.Publish(Text, False);
   Check(Not ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Other), 'Disconnected unavailable');
   Publisher.Publish(Text, True);
   Map  := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar('Local\FlightPadFMC.Screen.v1.FenixA320.' + IntToStr(GetCurrentProcessId)));
   Lock := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, PChar('Local\FlightPadFMC.Screen.v1.FenixA320.' + IntToStr(GetCurrentProcessId) + '.Lock'));
   View := MapViewOfFile(Map, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(Packet));
   Check(View <> Nil, 'Open controlled fixture mapping');
   Try
    WaitForSingleObject(Lock, INFINITE);
    Try
     Move(View^, Packet, SizeOf(Packet));
     Packet.HeartbeatTick := GetTickCount64 - 6000;
     Move(Packet, View^, SizeOf(Packet));
    Finally
     ReleaseMutex(Lock);
    End;
    Check(Not ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Other), 'Stalled heartbeat rejected');
    Publisher.Publish(Text, True);
    WaitForSingleObject(Lock, INFINITE);
    Try
     Move(View^, Packet, SizeOf(Packet));
     Packet.Version := 99;
     Move(Packet, View^, SizeOf(Packet));
    Finally
     ReleaseMutex(Lock);
    End;
    Check(Not ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Other), 'Unknown protocol rejected');
   Finally
    UnmapViewOfFile(View);
    CloseHandle(Map);
    CloseHandle(Lock);
   End;
  Finally
   Publisher.Free;
  End;
  Check(Not ReadFlightPadScreenPID('FenixA320', GetCurrentProcessId, Snapshot), 'Closed publisher unavailable');
  For k := 0 To 1 Do
   Begin
    If k = 0 Then
     Begin
      Profile  := 'FenixA320';
      Provider := 'FenixA32X';
     End
    Else
     Begin
      Profile  := 'FBWA320';
      Provider := 'FBWA32NX';
     End;
    FillChar(Startup, SizeOf(Startup), 0);
    Startup.cb          := SizeOf(Startup);
    Startup.dwFlags     := STARTF_USESHOWWINDOW;
    Startup.wShowWindow := SW_HIDE;
    Text                := '"' + ExtractFilePath(ParamStr(0)) + 'MockFlightPad32.exe" ' + Profile;
    UniqueString(Text);
    Check(CreateProcess(Nil, PChar(Text), Nil, Nil, False, CREATE_NO_WINDOW, Nil, Nil, Startup, Process), 'Start Win32 publisher');
    Try
     Started := GetTickCount64;
     Repeat
      If ReadFlightPadScreenPID(Profile, Process.dwProcessId, Snapshot) Then
       Break;
      Sleep(20);
     Until GetTickCount64 - Started > 5000;
     Check(Snapshot.Text <> '', 'Win32 publisher -> Win64 reader');
     Check(ReadFlightPadScreen(Profile, Other) And (Other.ProcessID = Process.dwProcessId), 'Running process autodetection');
     Root := TJSONObject.Create;
     Try
      Root.AddPair('provider', Provider);
      AttachFlightPadScreen(Root);
      Screens := ExtractFMCScreens(Root);
      Try
       Check((Screens.Count = 1) And Screens[0].Available, 'Generic CDU attached');
       Check((Screens[0].Lines.Count = 14) And (Length(Screens[0].Lines[13]) = 24), 'Full screen and scratchpad');
       Check(Pos(WideChar($2190), Screens[0].Lines[13]) > 0, 'Unicode glyph survives cross-bitness');
       Check(Screens[0].PowerState = -1, 'No invented electrical power state');
      Finally
       Screens.Free;
      End;
      s    := TFlightSample.Create;
      Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'flightpad-' + IntToStr(GetTickCount64) + '.db');
      DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
      Try
       SetN('time_zulu.year', 2026);
       SetN('time_zulu.month', 10);
       SetN('time_zulu.day', 17);
       s.AircraftData := TJSONObject.ParseJSONValue(Root.ToJSON) As TJSONObject;
       Trip           := DB.StartTrip(s);
       DB.RecordSample(Trip, s);
       SetN('time_zulu.seconds', 1);
       DB.RecordSample(Trip, s);
       Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens') = 1, 'Unchanged external screen stored once');
       Context := LatestFMCContext(DB.Connection, Trip, s.Time('time_zulu'));
       Try
        Check(Pos('v1_kt', Context.ToJSON) > 0, 'External V-speeds in analysis');
       Finally
        Context.Free;
       End;
       Registry := TAircraftProviders.Create(ExtractFilePath(ParamStr(0)) + 'MockFenixSim.dll', ExtractFilePath(ParamStr(0)) + 'MockFenixSim.dll');
       Try
        For r := 0 To FieldCount - 1 Do
         If SimFields[r].Name = 'title' Then
          If k = 0 Then
           s.Texts[r] := 'Fenix A320 LOT'
          Else
           s.Texts[r] := 'FBW A32NX LOT';
        Registry.Capture(s);
        Check(s.AircraftData.GetValue('cdu') <> Nil, 'Aircraft registry includes FlightPad screen');
       Finally
        Registry.Free;
       End;
       Stop := OpenEvent(EVENT_MODIFY_STATE, False, PChar('Local\FDR.FlightPad.TestStop.' + IntToStr(Process.dwProcessId)));
       Check(Stop <> 0, 'Stop publisher event');
       Try
        SetEvent(Stop);
       Finally
        CloseHandle(Stop);
       End;
       Check(WaitForSingleObject(Process.hProcess, 3000) = WAIT_OBJECT_0, 'Publisher exits');
       AttachFlightPadScreen(s.AircraftData);
       SetN('time_zulu.seconds', 2);
       DB.RecordSample(Trip, s);
       Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens order by id desc limit 1') = 0, 'Stopped app invalidates FDR screen');
       DB.DeleteTrip(Trip);
       Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens') = 0, 'External screen cleanup');
      Finally
       DB.Free;
       s.Free;
       DeleteFile(PChar(Path));
      End;
     Finally
      Root.Free;
     End;
    Finally
     If WaitForSingleObject(Process.hProcess, 0) = WAIT_TIMEOUT Then
      TerminateProcess(Process.hProcess, 1);
     CloseHandle(Process.hThread);
     CloseHandle(Process.hProcess);
    End;
   End;
  System.Writeln('PASS: FlightPad Win32/Win64 text IPC, running process detection, Fenix/FBW isolation, heartbeat, unavailable/malformed/version rejection, Unicode, aircraft integration, change-only FDR and AI context. Mock publishers only.');

 End;

Begin
 RunNativeTests(TVerifyFlightPadTests);
End.
