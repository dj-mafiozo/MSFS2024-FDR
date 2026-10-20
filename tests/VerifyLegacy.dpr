program VerifyLegacy;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.IOUtils,System.Types,Data.DB,FireDAC.Comp.Client,
  FlightDatabaseU in '..\src\data\FlightDatabaseU.pas',LegacyMigrationU in '..\src\core\LegacyMigrationU.pas',
  FlightTelemetryU in '..\src\telemetry\FlightTelemetryU.pas',TelemetryCatalogU in '..\src\telemetry\TelemetryCatalogU.pas';
var DB:TFlightDatabase;Root,Path:string;Version:Integer;P:TTripPlot;
procedure Require(B:Boolean;const Message:string);begin if not B then raise Exception.Create(Message);end;
begin
  Root:=ExtractFilePath(ParamStr(0));Path:=TPath.Combine(Root,'legacy-'+IntToStr(GetTickCount64)+'.db');DB:=TFlightDatabase.Create(Path,TPath.Combine(Root,'..\bin\sqlite3.dll'));
  try
    DB.Connection.ExecSQL('drop table trip_data');
    DB.Connection.ExecSQL('create table trip_data (id integer,trip integer,number_of_engines integer,engine_type integer,bool_group_1 integer,bool_group_2 integer,bool_group_3 integer,'+
      'plane_latitude real,plane_longitude real,plane_altitude integer,zulu_time text,local_time text,turb_eng_n1_1 real,turb_eng_n1_2 real)');
    DB.Connection.ExecSQL('insert into trip_data values (NULL,1,2,1,262144,393216,0,52,20,1000,''2026-10-12T10:00:00.000+00:00_0'',''2026-10-12T12:00:00.000-02:00_0'',45,46)');
    DB.Connection.ExecSQL('pragma user_version=0');
  finally DB.Free;end;
  DB:=TFlightDatabase.Create(Path,TPath.Combine(Root,'..\bin\sqlite3.dll'));
  try
    Version:=DB.Connection.ExecSQLScalar('pragma user_version');Require(Version=1,'Timezone version');
    Require(string(DB.Connection.ExecSQLScalar('select local_time from trip_data'))='2026-10-12T12:00:00.000+02:00_0','Legacy local timezone correction');
    Require(Integer(DB.Connection.ExecSQLScalar('select count(*) from trip_engine_data'))=2,'Legacy engine rows');
    Require(Integer(DB.Connection.ExecSQLScalar('select eng_combustion from trip_engine_data where engine=2'))=1,'Legacy engine packed bit');
    P:=DB.LoadTrip(1);try Require(Abs(P.Points[0].Values[P.Labels.IndexOf('turb_eng_n1 #2')]-46)<0.001,'Legacy engine #2 value');finally P.Free;end;
    Require(Length(TDirectory.GetFiles(Root,ExtractFileName(Path)+'.before-native-*.db'))=1,'Migration backup');
  finally DB.Free;end;
  DB:=TFlightDatabase.Create(Path,TPath.Combine(Root,'..\bin\sqlite3.dll'));
  try Require(string(DB.Connection.ExecSQLScalar('select local_time from trip_data'))='2026-10-12T12:00:00.000+02:00_0','Migration idempotence');finally DB.Free;end;
  Writeln('PASS: legacy samples, engine columns/bits, readback, backup, timezone correction and repeat-open idempotence.');
end.
