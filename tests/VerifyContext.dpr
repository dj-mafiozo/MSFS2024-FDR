Program VerifyContext;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.IOUtils, System.JSON, FireDAC.Comp.Client, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', AnalysisContextU In '..\src\Analysis\AnalysisContextU.pas';

Procedure Require(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 DB       : TFlightDatabase;
 s        : TFlightSample;
 q        : TFDQuery;
 j        : TJSONObject;
 Samples  : TJSONArray;
 Window   : TJSONObject;
 Row      : TJSONObject;
 State    : TJSONObject;
 Deltas   : TJSONArray;
 Expanded : TJSONArray;
 ID       : Integer;
 EventID  : Integer;
 i        : Integer;
 Seconds  : Double;

Procedure SetN(Const Name : String; v : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := v;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Procedure Merge(State, Delta : TJSONObject);
 Var
  k   : Integer;
  p   : TJSONPair;
  Old : TJSONValue;
 Begin

  For k := 0 To Delta.Count - 1 Do
   Begin

    p   := Delta.Pairs[k];
    Old := State.GetValue(p.JsonString.Value);

    If (Old Is TJSONObject) And (p.JsonValue Is TJSONObject) Then
     Merge(TJSONObject(Old), TJSONObject(p.JsonValue))

    Else
     Begin

      If Old <> Nil Then
       State.RemovePair(p.JsonString.Value).Free;

      State.AddPair(p.JsonString.Value, TJSONObject.ParseJSONValue(p.JsonValue.ToJSON));

     End;

   End;

 End;

Type

 [TestFixture]
 TVerifyContextTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyContextTests.Regression;
 Begin

  DB := TFlightDatabase.Create(TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'context-' + IntToStr(GetTickCount64) + '.db'), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
  s  := TFlightSample.Create;
  q  := TFDQuery.Create(Nil);

  Try

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 12);
   SetN('time_zulu.seconds', 86370);
   ID      := DB.StartTrip(s);
   EventID := 0;

   For i := 0 To 180 Do
    Begin

     Seconds := 86370 + i * 0.5;
     SetN('time_zulu.day', 12 + Trunc(Seconds / 86400));
     SetN('time_zulu.seconds', Seconds - Trunc(Seconds / 86400) * 86400);

     SetN('ambient_temperature', 12 + Ord(i >= 120));
     SetN('ambient_pressure', 28.92);
     SetN('barometer_pressure', 1013);
     SetN('ambient_visibility', 8000 - i * 10);
     SetN('ambient_wind_direction', 250);
     SetN('ambient_wind_velocity', 10);

     SetN('number_of_engines', 2);
     SetN('turb_eng_n1[0]', 45);
     SetN('turb_eng_n1[1]', 46);
     SetN('general_eng_throttle_lever_position[0]', 50 + 20 * Ord(i >= 100));

     SetN('autopilot_master', Ord((i < 120) Or (i >= 130)));
     SetN('autothrottle_active', Ord(i < 120));
     SetN('autopilot_throttle_arm', 1);

     SetN('gear_position_0', 1);
     SetN('gear_position_1', 1);
     SetN('gear_position_2', 1);

     If i >= 121 Then
      SetN('gear_position_1', 0.35);

     SetN('gear_is_on_ground_0', Ord(i < 119));
     SetN('gear_is_on_ground_1', Ord(i < 120));
     SetN('gear_is_on_ground_2', Ord(i < 121));

     SetN('wheel_rpm_0', 10);
     SetN('wheel_rpm_1', 20);
     SetN('wheel_rpm_2', 30);

     SetN('sim_on_ground', Ord(i < 120));
     SetN('plane_pitch_degrees', -8.5);
     SetN('g_force', 1);
     If i = 122 Then
      SetN('g_force', 2.3);

     SetN('vertical_speed', i - 100);
     DB.RecordSample(ID, s);

     If i = 120 Then
      EventID := DB.Contact(ID, s, False);

     If i = 140 Then
      DB.Contact(ID, s, True);

    End;

   DB.Connection.ExecSQL('update trip_engine_data set turb_eng_n1=NULL where engine=1 and sample=(select id from trip_data where trip=:t order by id limit 1 offset 125)', [ID]);

   DB.Connection.ExecSQL('delete from trip_engine_data where engine=2 and sample=(select id from trip_data where trip=:t order by id limit 1 offset 127)', [ID]);

   DB.Connection.ExecSQL('update trip_liftoffs set distance_length=1000,distance_width=-10,runway_heading=0 where id=:id', [EventID]);

   q.Connection := DB.Connection;
   q.Open('select * from trip_liftoffs where id=' + IntToStr(EventID));

   Expanded := Nil;
   j        := BuildContactContext(DB, q, 60, 30);

   Try

    Deltas := j.GetValue<TJSONArray>('samples');

    Require(Length(Deltas.ToJSON) < Length(Deltas.Items[0].ToJSON) * Deltas.Count Div 2, 'Delta payload must be smaller than full repeated states');

    Expanded := TJSONArray.Create;
    State    := TJSONObject.Create;

    Try

     Require(TJSONObject(Deltas.Items[1]).GetValue('ambient_pressure') = Nil, 'Repeated value omitted');

     Require(TJSONObject(Deltas.Items[120]).GetValue('autopilot_master').Value = 'false', 'False change retained');

     Require(TJSONObject(Deltas.Items[121]).GetValue('autopilot_master') = Nil, 'Unchanged false omitted');

     Require(TJSONObject(Deltas.Items[125]).GetValue<TJSONObject>('engines').GetValue<TJSONObject>('1').GetValue('turb_eng_n1') Is TJSONNull, 'Engine explicit null retained');

     Require(TJSONObject(Deltas.Items[127]).GetValue<TJSONObject>('engines').GetValue('2') Is TJSONNull, 'Missing engine explicit null');

     For i := 0 To Deltas.Count - 1 Do
      Begin

       Merge(State, TJSONObject(Deltas.Items[i]));
       Expanded.AddElement(TJSONObject.ParseJSONValue(State.ToJSON));

       Require(State.GetValue('autopilot_master').Value = LowerCase(BoolToStr((i < 120) Or (i >= 130), True)), 'AP state reconstruction');

       Require(State.GetValue('autothrottle_active').Value = LowerCase(BoolToStr(i < 120, True)), 'AT state reconstruction');

       Require(State.GetValue<Integer>('ambient_visibility') = 8000 - i * 10, 'Weather reconstruction');

      End;

    Finally
     State.Free;
    End;

    Samples := Expanded;
    Window  := j.GetValue<TJSONObject>('window');

    Require(Samples.Count = 181, 'Full 90-second window across midnight');

    Require(Window.GetValue<Integer>('before_count') = 120, 'Samples before liftoff');
    Require(Window.GetValue<Integer>('after_count') = 60, 'Samples after liftoff');

    Require(Abs(Window.GetValue<Double>('observed_max_g') - 2.3) < 0.001, 'Post-event peak retained');

    Row := TJSONObject(Samples.Items[120]);
    Require(Abs(Row.GetValue<Double>('pitch_nose_up_deg') - 8.5) < 0.001, 'Pitch sign normalized');

    Require(Row.GetValue('sim_on_ground').Value = 'false', 'Ground bit decoded');

    Require(j.GetValue<TJSONArray>('nearby_contacts').Count = 2, 'Liftoff/touchdown sequence supplied');

    Require(j.GetValue<TJSONObject>('weather').GetValue<TJSONObject>('nearest_event_sample').GetValue<Integer>('ambient_temperature') = 13, 'Weather nearest event');

    Require(TJSONObject(Samples.Items[0]).GetValue<Integer>('ambient_temperature') = 12, 'Before-event weather retained');

    Require(TJSONObject(Samples.Items[180]).GetValue<Integer>('ambient_visibility') = 6200, 'After-event visibility retained');

    Require(Abs(Row.GetValue<Double>('ambient_pressure') - 28.92) < 0.001, 'Local pressure inHg retained');

    Require(Row.GetValue<Integer>('barometer_pressure') = 1013, 'Sea-level pressure retained separately');

    Row := TJSONObject(Samples.Items[121]).GetValue<TJSONObject>('landing_gear');

    Require(Abs(Row.GetValue<TJSONObject>('left').GetValue<Double>('extension_ratio') - 0.35) < 0.0001, 'Fractional gear extension preserved');

    Require(Row.GetValue<TJSONObject>('right').GetValue<Integer>('wheel_rpm') = 30, 'Right wheel RPM separate');

    Row := TJSONObject(Samples.Items[119]).GetValue<TJSONObject>('landing_gear');

    Require(Row.GetValue<TJSONObject>('center').GetValue('on_ground').Value = 'false', 'Nose contact independent');

    Require(Row.GetValue<TJSONObject>('left').GetValue('on_ground').Value = 'true', 'Left contact independent');

    Require(Abs(j.GetValue<TJSONObject>('event').GetValue<Double>('distance_from_threshold_m') - 304.8) < 0.0001, 'Event distance converted to metres');

    Require(Abs(TJSONObject(Samples.Items[0]).GetValue<Double>('runway_cross_m') + 3.048) < 0.0001, 'Signed runway cross-track metres');

    Require(j.GetValue<TJSONObject>('event').GetValue('airspeed_indicated') Is TJSONNumber, 'Typed contact numbers');

   Finally
    Expanded.Free;
    j.Free;
   End;

   j := BuildContactContext(DB, q, 1, 1);
   Try
    Require(j.GetValue<TJSONArray>('samples').Count = 5, 'Configurable bounded window');
   Finally
    j.Free;
   End;

  Finally
   q.Free;
   s.Free;
   DB.Free;
  End;

  System.Writeln('PASS: full parameter baseline, AP/AT transitions, recursive deltas, engine null/removal/reappearance, reconstructed weather and reduced payload across 181 snapshots.');

 End;

Begin
 RunNativeTests(TVerifyContextTests);
End.
