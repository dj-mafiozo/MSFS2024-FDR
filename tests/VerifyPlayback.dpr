Program VerifyPlayback;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Math, System.Classes, PlaybackU In '..\src\Visualization\PlaybackU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas';

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Var
 Plot   : TTripPlot;
 p      : TPlotPoint;
 Player : TPlayback;
 s      : TFlightSample;
 DB     : TFlightDatabase;
 i      : Integer;
 Trip   : Integer;
 Cols   : TStringList;
 Names  : String;

Procedure N(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := Value;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Procedure SmoothPresentation;
 Var
  q : TTripPlot;
  r : TPlotPoint;
  a : TPlotPoint;
  c : TPlayback;
  j : Integer;
 Begin
  q := TTripPlot.Create;
  c := TPlayback.Create;
  Try
   q.SamplingIntervalMS := 500;
   q.Labels.Add('airspeed_indicated');
   q.Labels.Add('plane_heading_degrees_true');
   q.Labels.Add('sim_on_ground');
   q.Labels.Add('FBWLVar.PACKED_WORD');
   q.Labels.Add('eng_oil_pressure #1');
   For j := 0 To 1 Do
    Begin
     r         := Default(TPlotPoint);
     r.Seconds := j * 0.5;
     r.Lat     := 50 + j;
     r.Lon     := 179 + j * 2;
     If j = 0 Then
      r.Time := '2026-10-25T12:00:00.000Z'
     Else
      r.Time := '2026-10-25T12:00:00.500Z';
     SetLength(r.Values, 5);
     r.Values[0] := 100 + j * 20;
     r.Values[1] := 359 - j * 358;
     r.Values[2] := 1 - j;
     r.Values[3] := 1000 + j * 999;
     r.Values[4] := NaN;
     q.Points.Add(r);
    End;
   c.Bind(q);
   c.Play(0);
   c.Advance(250);
   c.Present(q);
   a := q.DisplayPoint(0);
   Check(Abs(a.Values[0] - 110) < 0.001, 'Mid-sample IAS interpolation');
   Check((Abs(a.Values[1]) < 0.001) Or (Abs(a.Values[1] - 360) < 0.001), 'Heading takes shortest path through north');
   Check((a.Values[2] = 1) And (a.Values[3] = 1000), 'Boolean and packed SDK states held until recorded boundary');
   Check(IsNan(a.Values[4]), 'Missing telemetry remains missing');
   Check((Abs(a.Lat - 50.5) < 0.001) And (Abs(Abs(a.Lon) - 180) < 0.001), 'Map position interpolates across date line');
   Check((q.Points[0].Values[0] = 100) And (q.Points[1].Values[0] = 120), 'Recorded arrays never modified');
   Check(Pos('00.250', a.Time) > 0, 'Presentation clock interpolates within sample');
   c.Advance(300);
   c.Present(q);
   Check(q.DisplayPoint(0).Values[0] > a.Values[0], 'Movement continues without changing sample index');
   c.Advance(500);
   c.Present(q);
   Check(q.DisplayPoint(1).Values[2] = 0, 'Discrete value changes at sample boundary');
   r             := q.Points[1];
   r.BreakBefore := True;
   q.Points[1]   := r;
   c.Bind(q);
   c.Play(0);
   c.Advance(250);
   c.Present(q);
   Check(q.DisplayPoint(0).Values[0] = 100, 'No fabricated motion across recording break');
   q.ClearDisplayPoint;
   Check(q.DisplayPoint(0).Values[0] = 100, 'Manual selection restores raw sample');
  Finally
   c.Free;
   q.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyPlaybackTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyPlaybackTests.Regression;
 Begin
  Try
   SmoothPresentation;
   Plot   := TTripPlot.Create;
   Player := TPlayback.Create;
   Try
    For i := 0 To 5 Do
     Begin
      p.Seconds := i * 0.5;
      If i = 5 Then
       p.Seconds := 5;
      Plot.Points.Add(p);
     End;
    Plot.ResolveSamplingInterval;
    Check((Plot.SamplingIntervalMS = 500) And (Plot.SamplingIntervalSource = 'estimated'), 'Median positive cadence ignores a minority of gaps');
    Plot.ResolveSamplingInterval(250);
    Check((Plot.SamplingIntervalMS = 250) And (Plot.SamplingIntervalSource = 'stored'), 'Stored nominal cadence takes precedence');
    Player.Bind(Plot);
    Player.SetRate(0, 0);
    Check(Player.RateCaption = '0.125x', 'Exact fractional rate');
    Player.Play(0);
    Player.Advance(3999);
    Check(Player.Position = 0, 'Slow playback preserves fractions');
    Player.Advance(4000);
    Check(Player.Position = 1, '0.125x reaches next half-second sample after four seconds');
    Player.Pause(4000);
    Player.Advance(9000);
    Check(Player.Position = 1, 'Paused time does not accumulate');
    Player.SetRate(8, 9000);
    Player.Play(9000);
    Player.Advance(9063);
    Check(Player.Position = 3, '16x skips crossed samples without lag');
    Player.SetRate(4, 9063);
    Player.Advance(9563);
    Check(Player.Position = 4, 'Rate changes preserve continuous time');
    Player.Advance(10500);
    Check(Player.Position = 4, 'Actual gap is preserved instead of treating frames as uniform');
    Player.Advance(14000);
    Check((Player.Position = 5) And Not Player.Playing, 'End clamps and pauses');
    Player.Play(15000);
    Check((Player.Position = 0) And Player.Playing, 'Play from end restarts');
    Player.Skip(30, 15000);
    Check((Player.Position = 5) And Not Player.Playing, 'Forward 30 seconds clamps to end');
    Player.Skip( -30, 15000);
    Check(Player.Position = 0, 'Backward clamps to beginning');
    For i := 0 To 8 Do
     Begin
      Player.SetRate(i, 16000);
      Check(Player.RateIndex = i, 'Every rate selectable');
     End;
    Player.Stop(17000);
    Check((Player.RateCaption = '1x') And (Player.Position = 0) And Not Player.Playing, 'Stop resets position and rate');
    Plot.Points.Clear;
    p.Seconds := 0;
    Plot.Points.Add(p);
    Plot.Points.Add(p);
    p.Seconds := NaN;
    Plot.Points.Add(p);
    Plot.ResolveSamplingInterval;
    Check((Plot.SamplingIntervalMS = 500) And (Plot.SamplingIntervalSource = 'fallback'), 'No usable timestamps falls back to 500 ms');
    Player.Bind(Plot);
    Player.Play(0);
    Player.Advance(500);
    Check(Player.Position = 1, 'Fallback times still advance');
    Player.Bind(Nil);
    Player.Play(0);
    Check((Player.Count = 0) And Not Player.Playing, 'Empty/unloaded plot cannot play');
   Finally
    Player.Free;
    Plot.Free;
   End;
   DB := TFlightDatabase.Create(TestDatabasePath('sampling.mfzr'), TestRuntimeFile('sqlite3.dll'));
   s  := TFlightSample.Create;
   Try
    N('time_zulu.year', 2026);
    N('time_zulu.month', 10);
    N('time_zulu.day', 25);
    N('time_zulu.seconds', 43200);
    Trip  := DB.StartTrip(s, 250);
    For i := 0 To 4 Do
     Begin
      N('time_zulu.seconds', 43200 + i * 0.5);
      DB.RecordSample(Trip, s);
     End;
    Plot := DB.LoadTrip(Trip);
    Try
     Check((Plot.SamplingIntervalMS = 250) And (Plot.SamplingIntervalSource = 'stored'), 'Configured sample interval SQLite roundtrip');
    Finally
     Plot.Free;
    End;
    DB.Connection.ExecSQL('update trips set sample_interval_ms=NULL');
    Plot := DB.LoadTrip(Trip);
    Try
     Check((Plot.SamplingIntervalMS = 500) And (Plot.SamplingIntervalSource = 'estimated'), 'Legacy NULL interval inferred');
    Finally
     Plot.Free;
    End;
    Cols := TStringList.Create;
    Try
     DB.Connection.GetFieldNames('', '', 'trips', '', Cols);
     Names := '';
     For i := 0 To Cols.Count - 1 Do
      If Cols[i] <> 'sample_interval_ms' Then
       Begin
        If Names <> '' Then
         Names := Names + ',';
        Names  := Names + '"' + Cols[i] + '"';
       End;
     DB.Connection.ExecSQL('create table legacy_trips as select ' + Names + ' from trips');
     DB.Connection.ExecSQL('drop table trips');
     DB.Connection.ExecSQL('alter table legacy_trips rename to trips');
    Finally
     Cols.Free;
    End;
    FreeAndNil(DB);
    DB   := TFlightDatabase.Create(TestDatabasePath('sampling.mfzr'), TestRuntimeFile('sqlite3.dll'), False, True);
    Plot := DB.LoadTrip(Trip);
    Try
     Check((Plot.SamplingIntervalMS = 500) And (Plot.SamplingIntervalSource = 'estimated'), 'Read-only old file without interval column');
    Finally
     Plot.Free;
    End;
   Finally
    s.Free;
    DB.Free;
   End;
   System.Writeln('PASS: all rates, monotonic elapsed playback, pause/seek/30s/end/stop, irregular times, stored/median/500ms sampling, SQLite and read-only legacy schema. Synthetic only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyPlaybackTests);
End.
