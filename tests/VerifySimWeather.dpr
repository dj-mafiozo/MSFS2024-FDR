Program VerifySimWeather;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.DateUtils, System.Math,
 System.Net.HttpClient, Vcl.Forms, RouteBridgeU, SimWeatherU, MetarDecodeU, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, frmWeatherU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Const
 RawSim  = 'METAR EPLL 251200Z 36010G20KT 9999 -SHRA BKN020CB 12/08 Q1013 NOSIG';
 RawReal = 'EPLL 251200Z 36010G20KT 9999 -SHRA BKN020CB 12/08 Q1008 NOSIG';

Var
 DB       : TFlightDatabase;
 s        : TFlightSample;
 b        : TRouteBridge;
 Service  : TSimWeatherService;
 HTTP     : THTTPClient;
 Trip     : Integer;
 Contact  : Integer;
 i        : Integer;
 v        : TJSONValue;
 Request  : TJSONObject;
 ID       : String;
 URL      : String;
 Body     : String;
 Stream   : TStringStream;
 d        : TDecodedMetar;
 f        : TfrmWeather;
 Response : IHTTPResponse;

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
 End;

Type

 [TestFixture]
 TVerifySimWeatherTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySimWeatherTests.Regression;
 Begin
  Application.Initialize;
  d := DecodeMetarReport('KJFK 251200Z VRB03KT 1 1/2SM BKN005 M02/M05 A2992');
  Check(d.VariableWind And (Abs(d.WindKnots - 3) < 0.01), 'Variable wind');
  Check(Abs(d.VisibilityMeters - 2414.016) < 0.1, 'Mixed statute-mile visibility');
  Check((d.Temperature = -2) And (d.DewPoint = -5), 'Negative temperatures');
  Check(Abs(d.QNH - 1013.2) < 0.1, 'inHg to hPa');
  Check(IsNan(DecodeMetarReport('EPLL 251200Z /////').WindKnots), 'Missing wind not calm');
  Check(Pos('QNH', CompareMetarReports(RawSim, RawReal)) > 0, 'Pressure mismatch detected');
  Check(Pos('EPLL', CompareMetarReports(RawSim, 'EPWA 251200Z 00000KT CAVOK 12/08 Q1013')) > 0, 'Different stations explicitly identified');
  Check(CompareMetarReports(RawSim, RawSim) <> CompareMetarReports('', RawSim), 'Missing data not agreement');
  Check(Pos('2000 ft', DecodedMetarText(RawSim)) > 0, 'Cloud base decoded in feet');
  DB      := TFlightDatabase.Create(TestDatabasePath('sim-weather.mfzr'), TestRuntimeFile('sqlite3.dll'));
  s       := TFlightSample.Create;
  b       := TRouteBridge.Create(0);
  HTTP    := THTTPClient.Create;
  Service := TSimWeatherService.Create(DB, b);
  Try
   N('time_zulu.year', 2026);
   N('time_zulu.month', 10);
   N('time_zulu.day', 25);
   N('time_zulu.seconds', 43200);
   Trip    := DB.StartTrip(s);
   Contact := DB.Contact(Trip, s, False);
   DB.Connection.ExecSQL('update trip_liftoffs set icao=''EPLL'',metar_requested_utc=:u where id=:id', [DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True), Contact]);
   Service.Tick;
   URL := 'http://127.0.0.1:' + IntToStr(b.Port);
   v   := TJSONObject.ParseJSONValue(HTTP.Get(URL + '/weather/requests').ContentAsString);
   Try
    Check((v Is TJSONArray) And (TJSONArray(v).Count = 1), 'Contact queues one simulator request');
    Request := TJSONObject(TJSONArray(v).Items[0]);
    ID      := Request.GetValue('id').Value;
    Check(Request.GetValue('station').Value = 'EPLL', 'Request uses contact airport');
   Finally
    v.Free;
   End;
   Body   := '{"id":"' + ID + '","metar":{"icao":"EPLL","metarString":"' + RawSim + '"},"taf":{"icao":"EPLL","tafString":"TAF EPLL 251100Z 2512/2612 36010KT CAVOK"}}';
   Stream := TStringStream.Create(Body, TEncoding.UTF8);
   Try
    Response := HTTP.Post(URL + '/weather/responses', Stream);
    Check(Response.StatusCode = 202, 'Bridge accepts correlated response');
   Finally
    Stream.Free;
   End;
   Service.Tick;
   Check(DB.Connection.ExecSQLScalar('select metar_text from trip_weather_reports where source=''msfs''') = RawSim, 'Simulator report persisted');
   StoreRealWeather(DB.Connection, 'trip_liftoffs', Contact, 'EPLL', RawReal, '2026-10-25T12:00:00Z', '2026-10-25T12:00:01Z', 'ok', '', '[]');
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_weather_reports') = 2, 'Sources stored independently');
   f := TfrmWeather.Create(Nil);
   Try
    f.Load(DB.Connection, Trip, False, Nil);
    Check(f.SimulatorMemo.ReadOnly And f.RealMemo.ReadOnly, 'DFM source views read-only');
    Check((Pos(RawSim, f.SimulatorMemo.Text) > 0) And (Pos(RawReal, f.RealMemo.Text) > 0), 'Dialog shows both original reports');
    Check(Pos('QNH', f.CompareMemo.Text) > 0, 'Dialog highlights decoded differences');
    Check(Pos('TAF EPLL', f.SimulatorMemo.Text) > 0, 'Simulator TAF retained');
   Finally
    f.Free;
   End;
   Stream := TStringStream.Create(Body, TEncoding.UTF8);
   Try
    Check(HTTP.Post(URL + '/weather/responses', Stream).StatusCode = 410, 'Duplicate or stale response rejected');
   Finally
    Stream.Free;
   End;
   Contact := DB.Contact(Trip, s, True);
   DB.Connection.ExecSQL('update trip_touchdowns set icao=''EPLL'',metar_requested_utc=:u,metar_target_utc=''2020-01-01T12:00:00Z'' where id=:id', [DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True), Contact]);
   FreeAndNil(Service);
   Service := TSimWeatherService.Create(DB, b);
   Service.Tick;
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_weather_reports where contact_table=''trip_touchdowns''') = 0, 'Historical requests never fetch current simulator weather');
   DB.DeleteTrip(Trip);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_weather_reports') = 0, 'Weather cleanup with trip');
  Finally
   Service.Free;
   HTTP.Free;
   b.Free;
   s.Free;
   DB.Free;
  End;
  System.Writeln('PASS: METAR decoding and comparison, HTTP weather queue, correlation, independent SQLite sources, TAF retention, DFM dialog and historical isolation. Mock simulator only.');

 End;

Begin
 RunNativeTests(TVerifySimWeatherTests);
End.
