Program VerifyLegacy;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.IOUtils, System.Types, Data.DB, FireDAC.Comp.Client,
 FlightDatabaseU In '..\src\data\FlightDatabaseU.pas', LegacyMigrationU In '..\src\core\LegacyMigrationU.pas',
 FlightTelemetryU In '..\src\telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\telemetry\TelemetryCatalogU.pas';

Var
 DB      : TFlightDatabase;
 Root    : String;
 Path    : String;
 Version : Integer;
 p       : TTripPlot;

Procedure Require(b : Boolean; Const Message : String);
 Begin
  If Not b Then
   Raise Exception.Create(Message);
 End;

Type

 [TestFixture]
 TVerifyLegacyTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyLegacyTests.Regression;
 Begin
  Root := TestDataDirectory;
  Path := TestDatabasePath(TPath.Combine(Root, 'legacy-' + IntToStr(GetTickCount64) + '.db'));
  DB   := TFlightDatabase.Create(TestDatabasePath(Path), TestRuntimeFile('sqlite3.dll'));
  Try
   DB.Connection.ExecSQL('drop table trip_data');
   DB.Connection.ExecSQL('create table trip_data (id integer,trip integer,number_of_engines integer,engine_type integer,bool_group_1 integer,bool_group_2 integer,bool_group_3 integer,' + 'plane_latitude real,plane_longitude real,plane_altitude integer,zulu_time text,local_time text,turb_eng_n1_1 real,turb_eng_n1_2 real)');
   DB.Connection.ExecSQL('insert into trip_data values (NULL,1,2,1,262144,393216,0,52,20,1000,''2026-10-12T10:00:00.000+00:00_0'',''2026-10-12T12:00:00.000-02:00_0'',45,46)');
   DB.Connection.ExecSQL('pragma user_version=0');
  Finally
   DB.Free;
  End;
  DB := TFlightDatabase.Create(TestDatabasePath(Path), TestRuntimeFile('sqlite3.dll'));
  Try
   Version := DB.Connection.ExecSQLScalar('pragma user_version');
   Require(Version = 1, 'Timezone version');
   Require(String(DB.Connection.ExecSQLScalar('select local_time from trip_data')) = '2026-10-12T12:00:00.000+02:00_0', 'Legacy local timezone correction');
   Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_engine_data')) = 2, 'Legacy engine rows');
   Require(Integer(DB.Connection.ExecSQLScalar('select eng_combustion from trip_engine_data where engine=2')) = 1, 'Legacy engine packed bit');
   p := DB.LoadTrip(1);
   Try
    Require(Abs(p.Points[0].Values[p.Labels.IndexOf('turb_eng_n1 #2')] - 46) < 0.001, 'Legacy engine #2 value');
   Finally
    p.Free;
   End;
   Require(Length(TDirectory.GetFiles(Root, ExtractFileName(Path) + '.before-native-*.db')) = 1, 'Migration backup');
  Finally
   DB.Free;
  End;
  DB := TFlightDatabase.Create(TestDatabasePath(Path), TestRuntimeFile('sqlite3.dll'));
  Try
   Require(String(DB.Connection.ExecSQLScalar('select local_time from trip_data')) = '2026-10-12T12:00:00.000+02:00_0', 'Migration idempotence');
  Finally
   DB.Free;
  End;
  System.Writeln('PASS: legacy samples, engine columns/bits, readback, backup, timezone correction and repeat-open idempotence.');

 End;

Begin
 RunNativeTests(TVerifyLegacyTests);
End.
