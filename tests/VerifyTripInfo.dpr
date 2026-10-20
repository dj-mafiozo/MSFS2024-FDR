program VerifyTripInfo;

{$APPTYPE CONSOLE}

uses Winapi.Windows,System.SysUtils,FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU,frmTripInfoU;

var DB:TFlightDatabase;S:TFlightSample;F:TfrmTripInfo;Path:string;I,Trip:Integer;

procedure SetN(const Name:string;N:Double);

begin for I:=0 to FieldCount-1 do if SimFields[I].Name=Name then begin S.Numbers[I]:=N;Exit;end;end;

procedure Check(B:Boolean;const M:string);

begin if not B then raise Exception.Create(M);end;

begin

  Path:=ExtractFilePath(ParamStr(0))+'trip-info-'+IntToStr(GetTickCount64)+'.db';

  DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');S:=TFlightSample.Create;F:=TfrmTripInfo.Create(nil);

  try

    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);

    for I:=0 to FieldCount-1 do if SimFields[I].Name='title' then S.Texts[I]:='Trip info test';

    Trip:=DB.StartTrip(S);SetN('time_zulu.seconds',10);DB.RecordSample(Trip,S);

    F.LoadTrip(DB.Connection,Trip);

    Check(F.mInfo.ReadOnly,'Read-only information');Check(Pos('Trip info test',F.mInfo.Text)>0,'Selected aircraft');

    Check(Pos('Probki telemetrii: 1',F.mInfo.Text)>0,'Sample count');

    Check(Pos('0:00:10',F.mInfo.Text)>0,'Open trip duration through latest sample');

    Check(Pos('Brak zapisanego zakonczenia',F.mInfo.Text)>0,'Incomplete trip is explicit');

    SetN('time_zulu.seconds',20);DB.EndTrip(Trip,S);F.RefreshClick(nil);

    Check(Pos('0:00:20',F.mInfo.Text)>0,'Completed duration');Check(Pos('Stan: Zakonczony',F.mInfo.Text)>0,'Refresh completed state');

    Check(F.btnClose.ModalResult<>0,'Modal Close button');

    DB.Contact(Trip,S,False);DB.Contact(Trip,S,True);

    DB.Connection.ExecSQL('update trip_liftoffs set icao=''EPLL'',metar_status=''ok'',metar_station=''EPLL'',metar_text=''EPLL START METAR'',metar_observed_utc=''2026-10-17T00:00:00Z'' where trip=:t',[Trip]);

    DB.Connection.ExecSQL('update trip_touchdowns set icao=''EPLL'',metar_status=''ok'',metar_station=''EPLL'',metar_text=''EPLL LANDING METAR'',metar_fetched_utc=''2026-10-17T00:01:00Z'' where trip=:t',[Trip]);

    F.RefreshClick(nil);

    Check((Pos('EPLL START METAR',F.mInfo.Text)>0) and (Pos('EPLL LANDING METAR',F.mInfo.Text)>0),'Both event METARs');

    Check((Pos('2026-10-17T00:00:00Z',F.mInfo.Text)>0) and (Pos('2026-10-17T00:01:00Z',F.mInfo.Text)>0),'Observation and fetch times');

    DB.Connection.ExecSQL('update trip_touchdowns set metar_text=NULL,metar_status=''unavailable'',metar_error=''No report'' where trip=:t',[Trip]);F.RefreshClick(nil);

    Check((Pos('unavailable',F.mInfo.Text)>0) and (Pos('No report',F.mInfo.Text)>0),'Missing METAR feedback');

    F.LoadTrip(DB.Connection,Trip+999);Check(Pos('Nie znaleziono',F.mInfo.Text)>0,'Deleted/missing trip');

    DB.DeleteTrip(Trip);

  finally F.Free;S.Free;DB.Free;DeleteFile(PChar(Path));end;

  Writeln('PASS: trip info DFM, selected aircraft, sample count, unfinished/completed duration, refresh, read-only view, close action and missing trip.');

end.

