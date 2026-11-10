Program VerifyGroundWeather;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.JSON, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU,
 AnalysisContextU, FlightAnalysisU, FireDAC.Comp.Client;

Var
 DB        : TFlightDatabase;
 s         : TFlightSample;
 q         : TFDQuery;
 j         : TJSONObject;
 Context   : TJSONObject;
 Trip      : Integer;
 EmptyTrip : Integer;
 i         : Integer;
 StartID   : Integer;
 LandingID : Integer;
 Path      : String;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetN(Const Name : String; n : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := n;
     Exit;
    End;
 End;

Type

 [TestFixture]
 TVerifyGroundWeatherTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyGroundWeatherTests.Regression;
 Begin
  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'ground-weather-' + IntToStr(GetTickCount64) + '.db');
  DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
  s    := TFlightSample.Create;
  q    := TFDQuery.Create(Nil);
  Try
   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);
   Trip      := DB.StartTrip(s);
   StartID   := 0;
   LandingID := 0;
   For i     := 0 To 5 Do
    Begin
     SetN('time_zulu.seconds', i);
     SetN('ambient_temperature', 20 + i);
     SetN('ambient_pressure', 29 + i * 0.01);
     SetN('kohlsman_setting_mb', 1026);
     SetN('plane_altitude', 1000 + i * 100);
     SetN('sim_on_ground', Ord((i < 2) Or (i = 3) Or (i = 5)));
     DB.RecordSample(Trip, s);
     If i = 2 Then
      StartID := DB.Contact(Trip, s, False);
     If i = 3 Then
      LandingID := DB.Contact(Trip, s, True);
    End;
   j := GroundWeatherReference(DB.Connection, Trip, '2026-10-17T00:00:02.000Z', False);
   Try
    Check(j.GetValue('ambient_temperature').Value = '21', 'Last ground before takeoff');
    Check(Pos('00:00:01', j.GetValue('utc').Value) > 0, 'Takeoff ground timestamp');
   Finally
    j.Free;
   End;
   j := GroundWeatherReference(DB.Connection, Trip, '2026-10-17T00:00:03.000Z', True);
   Try
    Check(j.GetValue('ambient_temperature').Value = '23', 'First landing ground, not later bounce/rollout');
    Check(j.GetValue('kohlsman_setting_mb').Value = '1026', 'Setting separate from ambient pressure');
   Finally
    j.Free;
   End;
   q.Connection := DB.Connection;
   q.Open('select * from trip_liftoffs where id=:i', [StartID]);
   Context := BuildContactContext(DB, q, 0, 0);
   Try
    j := (Context.GetValue('weather') As TJSONObject).GetValue('ground_reference') As TJSONObject;
    Check(j.GetValue('ambient_temperature').Value = '21', 'Reference outside selected analysis window');
   Finally
    Context.Free;
   End;
   q.Close;
   q.Open('select * from trip_touchdowns where id=:i', [LandingID]);
   Context := BuildContactContext(DB, q, 0, 0);
   Try
    j := (Context.GetValue('weather') As TJSONObject).GetValue('ground_reference') As TJSONObject;
    Check(j.GetValue('ambient_temperature').Value = '23', 'Landing classification in context');
   Finally
    Context.Free;
   End;
   EmptyTrip := DB.StartTrip(s);
   j         := GroundWeatherReference(DB.Connection, EmptyTrip, s.Time('time_zulu'), False);
   Try
    Check(j.GetValue('available').Value = 'false', 'Missing reference explicit');
    Check(j.GetValue('ambient_temperature') = Nil, 'No other-trip/airborne fallback');
   Finally
    j.Free;
   End;
   Check(Pos('weather.ground_reference', BuildAnalysisPrompt('{}', 'start')) > 0, 'Prompt ground-only policy');
   DB.DeleteTrip(Trip);
   DB.DeleteTrip(EmptyTrip);
  Finally
   q.Free;
   s.Free;
   DB.Free;
   DeleteFile(PChar(Path));
  End;
  System.Writeln('PASS: last pre-liftoff ground/first landing ground weather, bounce exclusion, outside-window selection, missing reference without fallback, trip isolation and prompt policy.');

 End;

Begin
 RunNativeTests(TVerifyGroundWeatherTests);

End.
