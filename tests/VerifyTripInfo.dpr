Program VerifyTripInfo;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', frmTripInfoU In '..\src\Forms\frmTripInfoU.pas';

Var
 DB   : TFlightDatabase;
 s    : TFlightSample;
 f    : TfrmTripInfo;
 Path : String;
 i    : Integer;
 Trip : Integer;

Procedure SetN(Const Name : String; n : Double);
 Begin
  For i := 0 To FieldCount - 1 Do
   If SimFields[i].Name = Name Then
    Begin
     s.Numbers[i] := n;
     Exit;
    End;
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Type

 [TestFixture]
 TVerifyTripInfoTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyTripInfoTests.Regression;
 Begin

  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'trip-info-' + IntToStr(GetTickCount64) + '.db');

  DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
  s  := TFlightSample.Create;
  f  := TfrmTripInfo.Create(Nil);

  Try

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);

   For i := 0 To FieldCount - 1 Do
    If SimFields[i].Name = 'title' Then
     s.Texts[i] := 'Trip info test';

   Trip := DB.StartTrip(s);
   SetN('time_zulu.seconds', 10);
   DB.RecordSample(Trip, s);

   f.LoadTrip(DB.Connection, Trip);

   Check(f.mInfo.ReadOnly, 'Read-only information');
   Check(Pos('Trip info test', f.mInfo.Text) > 0, 'Selected aircraft');

   Check(Pos('Probki telemetrii: 1', f.mInfo.Text) > 0, 'Sample count');

   Check(Pos('0:00:10', f.mInfo.Text) > 0, 'Open trip duration through latest sample');

   Check(Pos('Brak zapisanego zakonczenia', f.mInfo.Text) > 0, 'Incomplete trip is explicit');

   SetN('time_zulu.seconds', 20);
   DB.EndTrip(Trip, s);
   f.RefreshClick(Nil);

   Check(Pos('0:00:20', f.mInfo.Text) > 0, 'Completed duration');
   Check(Pos('Stan: Zakonczony', f.mInfo.Text) > 0, 'Refresh completed state');

   Check(f.btnClose.ModalResult <> 0, 'Modal Close button');

   DB.Contact(Trip, s, False);
   DB.Contact(Trip, s, True);

   DB.Connection.ExecSQL('update trip_liftoffs set icao=''EPLL'',metar_status=''ok'',metar_station=''EPLL'',metar_text=''EPLL START METAR'',metar_observed_utc=''2026-10-17T00:00:00Z'' where trip=:t', [Trip]);

   DB.Connection.ExecSQL('update trip_touchdowns set icao=''EPLL'',metar_status=''ok'',metar_station=''EPLL'',metar_text=''EPLL LANDING METAR'',metar_fetched_utc=''2026-10-17T00:01:00Z'' where trip=:t', [Trip]);

   f.RefreshClick(Nil);

   Check((Pos('EPLL START METAR', f.mInfo.Text) > 0) And (Pos('EPLL LANDING METAR', f.mInfo.Text) > 0), 'Both event METARs');

   Check((Pos('2026-10-17T00:00:00Z', f.mInfo.Text) > 0) And (Pos('2026-10-17T00:01:00Z', f.mInfo.Text) > 0), 'Observation and fetch times');

   DB.Connection.ExecSQL('update trip_touchdowns set metar_text=NULL,metar_status=''unavailable'',metar_error=''No report'' where trip=:t', [Trip]);
   f.RefreshClick(Nil);

   Check((Pos('unavailable', f.mInfo.Text) > 0) And (Pos('No report', f.mInfo.Text) > 0), 'Missing METAR feedback');

   f.LoadTrip(DB.Connection, Trip + 999);
   Check(Pos('Nie znaleziono', f.mInfo.Text) > 0, 'Deleted/missing trip');

   DB.DeleteTrip(Trip);

  Finally
   f.Free;
   s.Free;
   DB.Free;
   DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: trip info DFM, selected aircraft, sample count, unfinished/completed duration, refresh, read-only view, close action and missing trip.');

 End;

Begin
 RunNativeTests(TVerifyTripInfoTests);
End.
