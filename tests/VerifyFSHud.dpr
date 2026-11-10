Program VerifyFSHud;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.JSON, FSHudReplayU, FSHudProtocolU, FSHudClientU, FSHudDataU,

 FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, AircraftDataStoreU;

Var
 Replay    : TFSHudReplay;
 c         : TFSHudClient;
 d         : TFSHudData;
 DB        : TFlightDatabase;
 s         : TFlightSample;
 Messages  : TArray<TFSHudMessage>;
 j         : TJSONObject;
 Path      : String;
 Text      : String;
 Encrypted : String;
 i         : Integer;
 Trip      : Integer;
 Index     : Integer;
 Plot      : TTripPlot;
 Failed    : Boolean;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Type

 [TestFixture]
 TVerifyFSHudTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyFSHudTests.Regression;
 Begin

  Text := '{"MessageData":{"DataType":"RadioMessagesData","Message":"' + WideChar($141) + 'odz & QNH 1013"}}';

  Encrypted := FSHudEncode(Text, '0123456789ABCDEF');
  Check(FSHudDecode(Encrypted, '0123456789ABCDEF') = Text, 'AES/CBC UTF8 frame roundtrip');

  Failed := False;
  Try
   FSHudDecode('!', '0123456789ABCDEF');
  Except
   Failed := True;
  End;
  Check(Failed, 'Malformed frame rejected');

  c := TFSHudClient.Create;
  d := TFSHudData.Create(False);
  s := TFlightSample.Create;

  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'fshud-' + IntToStr(GetTickCount64) + '.db');
  DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');

  Try

   c.Accept('{"MessageData":{"DataType":"ClientValidationResponseMessage","IsValid":true}}');
   Check(c.GetStatus = 'connected', 'Validation accepted');

   c.Accept(Text);
   Messages := c.Take;
   Check(Length(Messages) = 1, 'Radio message captured');

   For i := 0 To FieldCount - 1 Do
    Begin

     If SimFields[i].Name = 'time_zulu.year' Then
      s.Numbers[i] := 2026;

     If SimFields[i].Name = 'time_zulu.month' Then
      s.Numbers[i] := 10;

     If SimFields[i].Name = 'time_zulu.day' Then
      s.Numbers[i] := 17;

    End;

   Trip := DB.StartTrip(s);
   d.Apply(DB.Connection, Trip, s.Time('time_zulu'), Messages);

   d.Apply(DB.Connection, Trip, s.Time('time_zulu'), Messages);

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages') = 1, 'Identical message omitted');
   Replay := TFSHudReplay.Create;
   Try
    Replay.Load(DB.Connection, Trip);
    Check(Pos('QNH 1013', Replay.TextAt(s.Time('time_zulu'))) > 0, 'Legacy radio text replay');
    Check(Replay.TextAt('2020-01-01T00:00:00Z') = '', 'Rewind hides future messages');
    c.Accept('{"MessageData":{"DataType":"RadioMessagesData","NotificationType":"AddedOrUpdated","MessageItems":[{"Id":"test1","ChannelFrequency":"121.500","TransmittingStationCallsign":"TOWER","Message":"CLEARED"}]}}');
    d.Apply(DB.Connection, Trip, '2026-10-17T00:01:00Z', c.Take);
    c.Accept('{"MessageData":{"DataType":"RadioMessagesData","NotificationType":"Removed","MessageItems":[{"Id":"test1"}]}}');
    d.Apply(DB.Connection, Trip, '2026-10-17T00:02:00Z', c.Take);
    Replay.Load(DB.Connection, Trip);
    Text := Replay.TextAt('2026-10-17T00:03:00Z_4');
    Check((Pos('CLEARED', Text) > 0) And (Pos('TOWER', Text) > 0) And (Pos('121.500', Text) > 0), 'ATC history preserves removed items, frequency and callsign');
    Check(Pos('CLEARED', Replay.TextAt('2026-10-17T00:00:59Z')) = 0, 'Timeline excludes future ATC');
    Replay.Load(Nil, 0);
    Check(Replay.TextAt('2026-10-17T00:03:00Z') = '', 'Trip clear removes messages');
   Finally
    Replay.Free;
    DB.Connection.ExecSQL('delete from trip_fshud_messages where id > 1');
   End;

   c.Accept('{"MessageData":{"DataType":"ApplicationSettingsMessageData","secret":"PRIVATE"}}');
   Check(Length(c.Take) = 0, 'Settings excluded');

   c.Accept('{"MessageData":{"DataType":"ApplicationStateMessage","NetworkUrls":["PRIVATE"],"ApplicationState":{"Mode":1}}}');

   Messages := c.Take;
   Check(Pos('PRIVATE', Messages[0].Payload) = 0, 'Network addresses excluded');

   d.Apply(DB.Connection, Trip, s.Time('time_zulu'), Messages);

   c.Accept('{"MessageData":{"DataType":"RadioPanelData","PanelRadioStates":{"Com1":{"SelectedFrequency":"120.005"},"Com2":{"SelectedFrequency":"126.500"}}}}');

   d.Apply(DB.Connection, Trip, s.Time('time_zulu'), c.Take);

   c.Accept('{"MessageData":{"DataType":"UserAircraftDetailsMessage","UserAircraftDetails":{"SquawkCode0":1,"SquawkCode1":2,"SquawkCode2":3,"SquawkCode3":4}}}');

   d.Apply(DB.Connection, Trip, s.Time('time_zulu'), c.Take);

   s.FSHudDataU := d.Snapshot;
   DB.RecordSample(Trip, s);

   j := TJSONObject.ParseJSONValue(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data')) As TJSONObject;

   Try
    Check(j.GetValue('fshud') <> Nil, 'FSHud state in unified sample history');
   Finally
    j.Free;
   End;

   Plot := DB.LoadTrip(Trip);

   Try

    Index := Plot.Labels.IndexOf('FSHud.COM1_selected_MHz');
    Check(Index >= 0, 'FSHud chart fields');

    Check(Abs(Plot.Points[0].Values[Index] - 120.005) < 0.0001, 'COM MHz decoded with invariant decimal');

    Index := Plot.Labels.IndexOf('FSHud.squawk_display');
    Check(Plot.Points[0].Values[Index] = 1234, 'Four squawk digits');

   Finally
    Plot.Free;
   End;

   Check(DB.Connection.ExecSQLScalar('select captured_utc from trip_fshud_messages limit 1') <> '', 'Reception timestamp');

   i := DB.Contact(Trip, s, False);

   Text := DB.Connection.ExecSQLScalar('select captured_utc from trip_liftoffs where id=:i', [i]);

   DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,''2099-01-01T00:00:00.000Z'',:s,''RadioMessagesData'',''{"Message":"FUTURE"}'')', [Trip, s.Time('time_zulu')]);

   j := FSHudContext(DB.Connection, Trip, Text);

   Try
    Check(Pos('FUTURE', j.ToJSON) = 0, 'Wall-clock bound excludes future radio even at same simulation time');

    Check(Pos('QNH 1013', j.ToJSON) > 0, 'ATC messages included once in contact context');
   Finally
    j.Free;
   End;

   DB.DeleteTrip(Trip);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fshud_messages') = 0, 'FSHud cleanup');

  Finally
   DB.Free;
   s.Free;
   d.Free;
   c.Free;
   DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: FSHud codec Unicode/malformed frames, validation, read-only allowlist, privacy filter, duplicate suppression, timestamped raw messages, snapshot history and cleanup. Offline only.');

 End;

Begin
 RunNativeTests(TVerifyFSHudTests);

End.
