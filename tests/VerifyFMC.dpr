program VerifyFMC;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Classes,System.Variants,System.JSON,System.Generics.Collections,FireDAC.Comp.Client,
 FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU,FMCScreensU,FMCPreflightU,AnalysisContextU;
var DB:TFlightDatabase;S:TFlightSample;Q:TFDQuery;Root,Fields,Parsed,Context,FMC,Devices,Values:TJSONObject;Screens:TObjectList<TFMCScreen>;
 Preflight:TFMCPreflightCache;Left,Right:TStringList;I,ID,EventID,Count:Integer;Path:string;Text:string;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;V:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=V;Exit;end;raise Exception.Create(Name);end;
procedure Blank(L:TStringList;const Title:string);
var K:Integer;begin L.Clear;L.Add(Copy(Title+StringOfChar(' ',24),1,24));for K:=1 to 13 do L.Add(StringOfChar(' ',24));end;
procedure Cell(L:TStringList;Row,Col:Integer;const V:string);
var A:string;begin A:=L[Row];Move(V[1],A[Col+1],Length(V)*SizeOf(Char));L[Row]:=A;end;
procedure MakeRoot;
var D,R:Integer;L:TStringList;
begin
 FreeAndNil(S.AircraftData);Root:=TJSONObject.Create;S.AircraftData:=Root;Root.AddPair('provider','iFly737MAX');Fields:=TJSONObject.Create;Root.AddPair('fields',Fields);
 for D:=0 to 1 do begin if D=0 then L:=Left else L:=Right;for R:=0 to 13 do Fields.AddPair(Format('LSKChar[%d][%d]',[D,R]),L[R]);end;
end;
procedure Save(Seconds:Integer);begin MakeRoot;SetN('time_zulu.seconds',Seconds);DB.RecordSample(ID,S);end;
begin
 S:=TFlightSample.Create;Left:=TStringList.Create;Right:=TStringList.Create;Q:=TFDQuery.Create(nil);DB:=nil;
 try
  Blank(Left,'TAKEOFF REF 1/2');Cell(Left,1,0,'FLAPS');Cell(Left,1,21,'V1');Cell(Left,2,0,'5');Cell(Left,2,20,'135');Cell(Left,3,22,'VR');Cell(Left,4,20,'140');Cell(Left,5,22,'V2');Cell(Left,6,20,'145');
  Blank(Right,'PERF INIT');Cell(Right,1,0,'GW / CRZ ALT');Cell(Right,2,0,'65.0 / 37000');MakeRoot;
  Fields.AddPair('LSK_Color[0][12][0]',TJSONNumber.Create(6));Screens:=ExtractFMCScreens(Root);
  try
   Check(Screens.Count=2,'Two independent iFly CDUs');Check(Screens[0].PageKey='TAKEOFF_REF:1/2','Page number retained in cache key');Check(Screens[0].Lines.Count=14,'TStringList has 14 rows');Check(Length(Screens[0].Lines[2])=24,'Fixed columns preserved');Check(Screens[0].Lines[12][1]=WideChar($B0),'iFly glyph flags decoded');
   Check(Screens[0].PowerState=-1,'Brightness does not invent power state');Check(Pos(#13#10,Screens[0].Lines.Text)>0,'Raw TStringList text preserves CRLF');
   Parsed:=ParseFMCValues(Screens[0]);try Check(Parsed.GetValue('v1_kt').Value='135','Right-aligned V1');Check(Parsed.GetValue('vr_kt').Value='140','Right-aligned VR');Check(Parsed.GetValue('v2_kt').Value='145','Right-aligned V2');finally Parsed.Free;end;
  finally Screens.Free;end;
  // Actual iFly QRH/selected columns: QRH is a proposal, the far-right value is selected.
  Blank(Left,'TAKEOFF REF 1/2');
  Cell(Left,1,0,' FLAPS          QRH   V1');Cell(Left,2,0,'15              119  124');
  Cell(Left,3,0,' TO N1                VR');Cell(Left,4,0,' 93.8/ 93.8%    120  125');
  Cell(Left,5,0,' CG    TRIM           V2');Cell(Left,6,0,'22.1%  3.95     130  137');
  MakeRoot;Screens:=ExtractFMCScreens(Root);
  try Parsed:=ParseFMCValues(Screens[0]);try
    Check(Parsed.GetValue('v1_kt').Value='124','QRH column must not replace selected V1');
    Check(Parsed.GetValue('vr_kt').Value='125','Selected VR');
    Check(Parsed.GetValue('v2_kt').Value='137','Selected V2');
  finally Parsed.Free;end;finally Screens.Free;end;
  Cell(Left,2,20,'---');MakeRoot;Screens:=ExtractFMCScreens(Root);
  try Parsed:=ParseFMCValues(Screens[0]);try
    Check(Parsed.GetValue('v1_kt') is TJSONNull,'Unselected V1 does not fall back to QRH');
  finally Parsed.Free;end;finally Screens.Free;end;
  Blank(Left,'APPROACH REF 1/2');
  Cell(Left,1,0,' GROSS WT   FLAPS   VREF');Cell(Left,2,0,'62.1         15    147KT');
  Cell(Left,4,0,'<QFE/QNH     30    142KT');Cell(Left,6,0,' 8202FT2500M 40    137KT');
  Cell(Left,7,0,' ILS 25 /CRS    FLAP/SPD');Cell(Left,8,0,'110.50LOD/245     40/137');
  Cell(Left,9,0,' G/S           WIND CORR');Cell(Left,10,0,'<ON/OFF            +05KT');
  MakeRoot;Screens:=ExtractFMCScreens(Root);
  try Parsed:=ParseFMCValues(Screens[0]);try
    Check(Parsed.GetValue('vref_kt').Value='137','Selected FLAP/SPD speed is VREF');
    Check(Parsed.GetValue('approach_flaps_deg').Value='40','Selected landing flaps');
    Check(Parsed.GetValue('wind_correction_kt').Value='5','Wind correction retained separately');
  finally Parsed.Free;end;finally Screens.Free;end;
  Cell(Left,8,18,'30/142');MakeRoot;Screens:=ExtractFMCScreens(Root);
  try Parsed:=ParseFMCValues(Screens[0]);try
    Check(Parsed.GetValue('vref_kt').Value='142','Selection follows FLAP/SPD, not last table row');
  finally Parsed.Free;end;finally Screens.Free;end;
  Cell(Left,8,18,'--/---');MakeRoot;Screens:=ExtractFMCScreens(Root);
  try Parsed:=ParseFMCValues(Screens[0]);try
    Check(Parsed.GetValue('vref_kt') is TJSONNull,'Cleared FLAP/SPD never guesses table VREF');
  finally Parsed.Free;end;finally Screens.Free;end;
  SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
  Path:=ExtractFilePath(ParamStr(0))+'fmc-'+IntToStr(GetTickCount64)+'.db';DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');ID:=DB.StartTrip(S);
  Save(0);Save(1);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')=2,'Unchanged raw screens omitted: '+VarToStr(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')));
  Blank(Left,'N1 LIMIT');Cell(Left,2,0,'26K  N1 98.2');Save(2);
  Blank(Left,'APPROACH REF');Cell(Left,1,0,'VREF 130');Cell(Left,3,0,'WIND CORR +05KT');Save(3);
  Blank(Left,'TAKEOFF REF');Cell(Left,1,0,'V1 138');Save(4);
  Blank(Left,'MOD TAKEOFF REF');Cell(Left,1,0,'V1 199');Save(5);
  // A shorter analysis window must still recover the last previously seen pages.
  SetN('time_zulu.seconds',20);EventID:=DB.Contact(ID,S,True);
  Blank(Left,'TAKEOFF REF');Cell(Left,1,0,'V1 250');Save(40);
  DB.Connection.ExecSQL('update trip_fmc_screens set parsed_json=''{"v1_kt":null,"vref_kt":null}''');
  Q.Connection:=DB.Connection;Q.FormatOptions.StrsTrim:=False;Q.Open('select * from trip_touchdowns where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,1,1);
  try
   FMC:=Context.GetValue('fmc_last_observed') as TJSONObject;Text:=FMC.ToJSON.Replace('\/','/');
   Check(Pos('65.0 / 37000',Text)>0,'PERF INIT outside window retained');Check(Pos('98.2',Text)>0,'N1 LIMIT retained');Check(Pos('V1 250',Text)=0,'No future screen leakage');
   Devices:=FMC.GetValue('last_values_by_device') as TJSONObject;Values:=Devices.GetValue('iFly737MAX/0') as TJSONObject;
   Check((Values.GetValue('v1_kt') as TJSONObject).GetValue('value').Value='138','Last non-MOD V1 at event');
   Check((Values.GetValue('vref_kt') as TJSONObject).GetValue('value').Value='130','Last approach VREF');
   Check((Values.GetValue('wind_correction_kt') as TJSONObject).GetValue('value').Value='5','Wind correction units');
   Check(Pos('MOD TAKEOFF REF',Text)>0,'Pending MOD page retained separately');Check(Pos('199',(Values.GetValue('v1_kt') as TJSONObject).ToJSON)=0,'MOD not treated as executed');
  finally Context.Free;end;
  Q.Close;Q.Open('select raw_text,time_zulu,captured_utc from trip_fmc_screens where page_key=''PERF_INIT''');
  Check(DB.Connection.ExecSQLScalar('select length(raw_text) from trip_fmc_screens where page_key=''PERF_INIT''')=Length(Right.Text),'Stored raw text retains trailing spaces and rows');
  Check(Q.FieldByName('raw_text').AsWideString=Right.Text,'Exact raw text round trip');Check(Q.FieldByName('time_zulu').AsString<>'','Simulation timestamp');Check(Q.FieldByName('captured_utc').AsString<>'','Capture timestamp');Q.Close;
  // Clearing an explicitly shown value must replace a previous parsed value with null.
  Blank(Left,'TAKEOFF REF');Cell(Left,1,0,'V1 ---');Save(45);FMC:=LatestFMCContext(DB.Connection,ID,S.Time('time_zulu'));
  try Devices:=FMC.GetValue('last_values_by_device') as TJSONObject;Values:=Devices.GetValue('iFly737MAX/0') as TJSONObject;Check((Values.GetValue('v1_kt') as TJSONObject).GetValue('value') is TJSONNull,'Cleared V1 is null, not carried forward');finally FMC.Free;end;
  // Do not mistake a multi-row VREF table for one selected speed.
  Blank(Left,'APPROACH REF');Cell(Left,1,16,'VREF');Cell(Left,2,0,'15');Cell(Left,2,18,'145');Cell(Left,3,0,'30');Cell(Left,3,18,'137');MakeRoot;Screens:=ExtractFMCScreens(Root);
  try Parsed:=ParseFMCValues(Screens[0]);try Check(Parsed.GetValue('vref_kt') is TJSONNull,'No guessed VREF from table');finally Parsed.Free;end;finally Screens.Free;end;
  // Missing one row invalidates the screen; no partial raw screen is fabricated.
  Fields.RemovePair('LSKChar[0][13]').Free;DB.RecordSample(ID,S);
  Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens where device=''0'' order by id desc limit 1')=0,'Missing row marks unavailable');
  // PMDG and future providers use the same generic row API and TStringList conversion.
  FreeAndNil(S.AircraftData);S.AircraftData:=TJSONObject.ParseJSONValue('{"provider":"PMDGNG3","cdu":{"0":{"status":"available","powered":true,"rows":[]}}}') as TJSONObject;
  Root:=S.AircraftData;Fields:=Root.GetValue('cdu') as TJSONObject;Fields:=Fields.GetValue('0') as TJSONObject;
  for I:=0 to 13 do (Fields.GetValue('rows') as TJSONArray).Add(Left[I]);SetN('time_zulu.seconds',46);DB.RecordSample(ID,S);
  Count:=DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens');
  Fields.RemovePair('powered').Free;Fields.AddPair('powered',TJSONBool.Create(False));SetN('time_zulu.seconds',47);DB.RecordSample(ID,S);
  Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')=Count+1,'Power change recorded even with identical text');
  FreeAndNil(S.AircraftData);SetN('time_zulu.seconds',48);DB.RecordSample(ID,S);
  Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens where provider=''PMDGNG3'' order by id desc limit 1')=0,'Provider disappearance invalidates screen');
  DB.DeleteTrip(ID);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')=0,'FMC history removed with trip');
  // Preparation pages are observed before engine-start recording; pruning retains last pages.
  Preflight:=TFMCPreflightCache.Create(1);
  try
   Blank(Left,'PERF INIT 1/2');Cell(Left,2,0,'PRESTART GW 65.0');MakeRoot;Preflight.Observe(S.AircraftData,'2026-10-17T00:01:00.000+00:00_0');
   Blank(Left,'N1 LIMIT');Cell(Left,2,0,'PRESTART N1 98.2');MakeRoot;Preflight.Observe(S.AircraftData,'2026-10-17T00:01:01.000+00:00_0');
   Blank(Left,'TAKEOFF REF');Cell(Left,1,0,'V1 141');MakeRoot;Preflight.Observe(S.AircraftData,'2026-10-17T00:01:02.000+00:00_0');
   SetN('time_zulu.seconds',100);ID:=DB.StartTrip(S);Preflight.Flush(DB.Connection,ID);
   FMC:=LatestFMCContext(DB.Connection,ID,'2026-10-17T00:01:50.000+00:00_0');
   try Text:=FMC.ToJSON;Check(Pos('PRESTART GW 65.0',Text)>0,'Preflight PERF INIT survives bounded history pruning');Check(Pos('PRESTART N1 98.2',Text)>0,'Preflight N1 LIMIT retained');Check(Pos('141',Text)>0,'Preflight takeoff values retained');finally FMC.Free;end;
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t and sample=0',[ID])>0,'Preflight text tagged without flight snapshot');
   Count:=DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens');Preflight.Flush(DB.Connection,ID);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')=Count,'Flushed preflight cache cleared');
   DB.DeleteTrip(ID);
  finally Preflight.Free;end;

 finally Q.Free;DB.Free;S.Free;Left.Free;Right.Free;if Path<>'' then DeleteFile(PChar(Path));end;
 Writeln('PASS: iFly/PMDG TStringList screens, glyphs, raw text round trip, change-only history, timestamps, per-page/as-of-event cache, V-speeds/wind correction, MOD isolation, cleared/ambiguous values, power/unavailability and cleanup.');
end.
