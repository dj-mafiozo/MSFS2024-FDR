Program VerifyChecklists;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU        In 'TestPathsU.pas', DUnitX.TestFramework,
 NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Classes,
 System.DateUtils, System.JSON, System.Net.HttpClient, System.IOUtils, Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.StdCtrls,
 frmMainU          In '..\src\Forms\frmMainU.pas',
 FlightTelemetryU  In '..\src\Telemetry\FlightTelemetryU.pas',
 FlightDatabaseU   In '..\src\Data\FlightDatabaseU.pas',
 RouteBridgeU      In '..\src\FlightPlan\RouteBridgeU.pas',
 ChecklistU        In '..\src\Recording\ChecklistU.pas';

Type

 [TestFixture]
 TChecklistTests = Class
  Public
   [Test] Procedure RecordingAndReplay;
   [Test] Procedure InvalidStates;
   [Test] Procedure ListenerNormalization;
 End;

Procedure TChecklistTests.RecordingAndReplay;
 Var
  Main     : TfrmMain;
  DB       : TFlightDatabase;
  Bridge   : TRouteBridge;
  Recorder : TChecklistRecorder;
  Replay   : TChecklistReplay;
  Sample   : TFlightSample;
  HTTP     : THTTPClient;
  Body     : TStringStream;
  Trip     : Integer;
  Raw      : String;

  Procedure Send(Checked : Boolean);
   Begin
    Raw  := '{"schema":1,"captured_utc":"' + DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True) + '","checklists":[{"id":"1","name":"Before start","items":[{"id":"2","text":"Parking brake - SET","checked":' + LowerCase(BoolToStr(Checked, True)) + '}]}]}';
    Body := TStringStream.Create(Raw, TEncoding.UTF8);
    Try
     Assert.AreEqual(202, HTTP.Post('http://127.0.0.1:' + IntToStr(Bridge.Port) + '/checklists/state', Body).StatusCode);
    Finally
     Body.Free;
    End;
   End;

 Begin
  DB       := TFlightDatabase.Create(TestDatabasePath('checklists.mfzr'), TestRuntimeFile('sqlite3.dll'));
  Sample   := TFlightSample.Create;
  Bridge   := Nil;
  Recorder := Nil;
  Replay   := Nil;
  HTTP     := Nil;
  Try
   Trip     := DB.StartTrip(Sample);
   Bridge   := TRouteBridge.Create(0);
   Recorder := TChecklistRecorder.Create(DB);
   Replay   := TChecklistReplay.Create;
   HTTP     := THTTPClient.Create;
   Send(False);
   Recorder.Tick(Bridge, Trip, '2026-11-24T12:00:00Z', False);
   Assert.AreEqual(0, Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_checklists')));
   Recorder.Tick(Bridge, Trip, '2026-11-24T12:00:00Z', True);
   Send(False);
   Recorder.Tick(Bridge, Trip, '2026-11-24T12:00:01Z', True);
   Assert.AreEqual(1, Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_checklists')), 'Heartbeats do not duplicate state');
   Send(True);
   Recorder.Tick(Bridge, Trip, '2026-11-24T12:00:02Z', True);
   Assert.AreEqual(2, Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_checklists')));
   Replay.Load(DB.Connection, Trip);
   Assert.AreEqual('', Replay.SnapshotAt('2026-11-24T11:59:59Z'), 'No future state');
   Assert.IsTrue(Pos('"checked":true', Replay.SnapshotAt('2026-11-24T12:00:02Z')) > 0);
   Assert.IsTrue(Pos('"checked":false', Replay.SnapshotAt('2026-11-24T12:00:01Z')) > 0, 'Rewind restores unchecked');
   Main := TfrmMain.Create(Nil);
   Try
    Main.Timer.Enabled         := False;
    Main.PlaybackTimer.Enabled := False;
    Replay.Present('2026-11-24T12:00:02Z', Main.ChecklistSelector, Main.ChecklistItems, Main.ChecklistEmpty);
    Assert.AreEqual(1, Main.ChecklistSelector.Items.Count);
    Assert.IsTrue(Main.ChecklistItems.Checked[0]);
    Assert.IsFalse(Main.ChecklistItems.ItemEnabled[0], 'Read-only native checkbox');
    Main.ChecklistItems.ItemIndex := 0;
    Main.ChecklistItems.Perform(WM_CHAR, VK_SPACE, 0);
    Assert.IsTrue(Main.ChecklistItems.Checked[0], 'Space does not edit recorded state');
    Replay.Present('2026-11-24T12:00:01Z', Main.ChecklistSelector, Main.ChecklistItems, Main.ChecklistEmpty);
    Assert.IsFalse(Main.ChecklistItems.Checked[0]);
   Finally
    Main.Free;
   End;
   Replay.Load(DB.Connection, Trip + 1);
   Assert.AreEqual('', Replay.SnapshotAt('2026-11-24T12:00:02Z'), 'Trip isolation');
   DB.DeleteTrip(Trip);
   Assert.AreEqual(0, Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_checklists')));
  Finally
   HTTP.Free;
   Replay.Free;
   Recorder.Free;
   Bridge.Free;
   Sample.Free;
   DB.Free;
  End;
 End;

Procedure TChecklistTests.InvalidStates;
 Var
  Value : TJSONValue;
 Begin
  Value := TJSONObject.ParseJSONValue('{"schema":1,"checklists":[{"id":"1","name":"Test","items":[{"text":"Missing state","checked":null}]}]}');
  Try
   Assert.IsTrue(ValidChecklistSnapshot(Value), 'Unknown is distinct from false');
  Finally
   Value.Free;
  End;
  Value := TJSONObject.ParseJSONValue('{"schema":1,"checklists":[{"id":"1","name":"Test","items":[{"text":"Invalid state","checked":2}]}]}');
  Try
   Assert.IsFalse(ValidChecklistSnapshot(Value));
  Finally
   Value.Free;
  End;
 End;

Procedure TChecklistTests.ListenerNormalization;
 Var
  SI       : TStartupInfo;
  PI       : TProcessInformation;
  Cmd      : String;
  Output   : String;
  Code     : DWORD;
  Value    : TJSONValue;
  Root     : TJSONObject;
  Snapshot : TJSONObject;
  Lists    : TJSONArray;
  Rows     : TJSONArray;
 Begin
  Output := TestDatabasePath('checklist-listener.json');
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  FillChar(PI, SizeOf(PI), 0);
  Cmd := 'node "' + TestRepositoryPath('tests\ChecklistBridgeFixture.js') + '" "' + Output + '"';
  UniqueString(Cmd);
  Assert.IsTrue(CreateProcess(Nil, PChar(Cmd), Nil, Nil, False, CREATE_NO_WINDOW, Nil, Nil, SI, PI));
  Try
   If WaitForSingleObject(PI.hProcess, 30000) <> WAIT_OBJECT_0 Then
    Begin
     TerminateProcess(PI.hProcess, 1);
     Assert.Fail('Listener fixture timeout');
    End;
   Assert.IsTrue(GetExitCodeProcess(PI.hProcess, Code));
   Assert.AreEqual(0, Integer(Code));
  Finally
   CloseHandle(PI.hThread);
   CloseHandle(PI.hProcess);
  End;
  Value := TJSONObject.ParseJSONValue(TFile.ReadAllText(Output, TEncoding.UTF8));
  Try
   Assert.IsTrue(Value Is TJSONObject);
   Root := TJSONObject(Value);
   Assert.IsTrue(Pos('JS_LISTENER_CHECKLIST', Root.GetValue('subscriptions').ToJSON) > 0);
   Assert.IsTrue(Pos('ChecklistCompletion', Root.GetValue('events').ToJSON) > 0);
   Assert.AreEqual('[]', Root.GetValue('sent').ToJSON, 'No checklist control commands');
   Snapshot := TJSONObject(Root.GetValue('unknown'));
   Assert.IsTrue(ValidChecklistSnapshot(Snapshot));
   Lists := TJSONArray(Snapshot.GetValue('checklists'));
   Rows  := TJSONArray(TJSONObject(Lists.Items[0]).GetValue('items'));
   Assert.IsTrue(TJSONObject(Rows.Items[0]).GetValue('checked') Is TJSONNull);
   Assert.AreEqual('false', TJSONObject(Rows.Items[1]).GetValue('checked').Value);
   Assert.IsTrue(Pos('"checked":true', Root.GetValue('complete').ToJSON) > 0);
   Assert.IsTrue(Pos('"checked":false', Root.GetValue('unchecked').ToJSON) > 0);
   Assert.IsTrue(Pos('"checked":null', Root.GetValue('aircraftChanged').ToJSON) > 0, 'Aircraft change clears old completion');
   Snapshot := TJSONObject(Root.GetValue('cleared'));
   Assert.AreEqual('[]', Snapshot.GetValue('checklists').ToJSON);
  Finally
   Value.Free;
  End;
 End;

Begin
 RunNativeTests(TChecklistTests);
End.
