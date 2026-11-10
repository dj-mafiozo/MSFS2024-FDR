Program VerifyPrecision;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.JSON, AnalysisPrecisionU, AnalysisContextU,
 FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, FireDAC.Comp.Client;

Var
 Original : TJSONValue;
 Rounded  : TJSONValue;
 DB       : TFlightDatabase;
 Sample   : TFlightSample;
 q        : TFDQuery;
 Context  : TJSONObject;
 Samples  : TJSONArray;
 Row      : TJSONObject;
 Trip     : Integer;
 EventID  : Integer;
 i        : Integer;
 Path     : String;

Const
 G : Array [0..6] Of Double = (1.00049, 1.00051, 1.0014, 1.0021, 1.00149, 1.00151, 1.0044);

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
     Sample.Numbers[k] := n;
     Exit;
    End;
 End;

Procedure CheckPrecision(v : TJSONValue);
 Var
  p   : TJSONPair;
  e   : TJSONValue;
  s   : String;
  Dot : Integer;
 Begin
  If v Is TJSONObject Then
   For p In TJSONObject(v) Do
    CheckPrecision(p.JsonValue)
  Else If v Is TJSONArray Then
   For e In TJSONArray(v) Do
    CheckPrecision(e)
  Else If v Is TJSONNumber Then
   Begin
    s   := v.Value;
    Dot := Pos('.', s);
    Check((Dot = 0) Or (Length(s) - Dot <= 3), 'At most three decimal places: ' + s);
   End;
 End;

Type

 [TestFixture]
 TVerifyPrecisionTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyPrecisionTests.Regression;
 Begin
  Original := TJSONObject.ParseJSONValue('{"n":-12.3456789,"nested":[0.00000001,{"x":1.23456}],"id":9007199254740993,"flag":false,"null":null,"text":"1.23456789"}');
  Rounded  := RoundAnalysisJSON(Original);
  Try
   CheckPrecision(Rounded);
   Check(Pos('-12.346', Rounded.ToJSON) > 0, 'Negative rounding');
   Check(Pos('9007199254740993', Rounded.ToJSON) > 0, 'Integer identity preserved');
   Check(Pos('1.23456789', Rounded.ToJSON) > 0, 'Strings untouched');
   Check(Pos('-12.3456789', Original.ToJSON) > 0, 'Source unchanged');
  Finally
   Rounded.Free;
   Original.Free;
  End;
  Path   := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'precision-' + IntToStr(GetTickCount64) + '.db');
  DB     := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
  Sample := TFlightSample.Create;
  q      := TFDQuery.Create(Nil);
  Try
   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);
   Trip  := DB.StartTrip(Sample);
   For i := 0 To High(G) Do
    Begin
     SetN('time_zulu.seconds', i);
     SetN('g_force', G[i]);
     SetN('autopilot_master', Ord(i < 3));
     DB.RecordSample(Trip, Sample);
    End;
   EventID      := DB.Contact(Trip, Sample, True);
   q.Connection := DB.Connection;
   q.Open('select * from trip_touchdowns where id=:i', [EventID]);
   Context := BuildContactContext(DB, q, 10, 1);
   Try
    CheckPrecision(Context);
    Samples := Context.GetValue('samples') As TJSONArray;
    Check(Samples.Count = 7, 'All timestamps retained');
    Check((TJSONObject(Samples.Items[0]).GetValue('g_force') As TJSONNumber).AsDouble = 1, 'Rounded baseline');
    Check(TJSONObject(Samples.Items[1]).GetValue('g_force') = Nil, 'Rounding boundary noise suppressed');
    Check(TJSONObject(Samples.Items[2]).GetValue('g_force') = Nil, 'Subthreshold drift suppressed');
    Check(Abs((TJSONObject(Samples.Items[3]).GetValue('g_force') As TJSONNumber).AsDouble - 1.002) < 0.00001, 'Cumulative drift emitted');
    Check(TJSONObject(Samples.Items[4]).GetValue('g_force') = Nil, 'Reverse jitter suppressed');
    Check(TJSONObject(Samples.Items[5]).GetValue('g_force') = Nil, 'Boundary jitter suppressed');
    Check(Abs((TJSONObject(Samples.Items[6]).GetValue('g_force') As TJSONNumber).AsDouble - 1.004) < 0.00001, 'Later cumulative drift retained');
    Row := TJSONObject(Samples.Items[3]);
    Check(Row.GetValue('autopilot_master').Value = 'false', 'Boolean transition preserved');
    For i := 0 To Samples.Count - 1 Do
     Begin
      Row := TJSONObject(Samples.Items[i]);
      Check((Row.GetValue('utc') <> Nil) And (Row.GetValue('t_seconds') <> Nil), 'Time coordinates never filtered');
     End;
    Check(Abs(Double(DB.Connection.ExecSQLScalar('select g_force from trip_data where trip=:t order by id limit 1', [Trip])) - G[0]) < 1E-10, 'Raw database precision unchanged');
   Finally
    Context.Free;
   End;
   DB.DeleteTrip(Trip);
  Finally
   q.Free;
   Sample.Free;
   DB.Free;
   DeleteFile(PChar(Path));
  End;
  System.Writeln('PASS: recursive three-decimal analysis JSON, exact integer IDs, untouched strings/raw DB, hysteresis against emitted state, cumulative drift, jitter suppression and AP/timestamps.');

 End;

Begin
 RunNativeTests(TVerifyPrecisionTests);

End.
