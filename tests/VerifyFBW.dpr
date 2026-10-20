program VerifyFBW;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Math,System.JSON,FireDAC.Comp.Client,FlightTelemetryU,TelemetryCatalogU,FlightDatabaseU,
 AircraftTelemetryU,AircraftDataStoreU,AircraftLVarReaderU,FBWReaderU,FBWCatalogU,AnalysisContextU;
type TReset=procedure(Mode:Integer);stdcall;TCount=function(Kind:Integer):Integer;stdcall;
var DLL:HMODULE;Reset:TReset;Counter:TCount;Reader:TFBWReader;Provider:TFBWProvider;Registry:TAircraftProviders;S:TFlightSample;DB:TFlightDatabase;
 V:TArray<Double>;Age:UInt64;I,N,ID,EventID,Flaps:Integer;Path,MockPath:string;Plot:TTripPlot;Q:TFDQuery;Context:TJSONObject;
function IndexOf(const Name:string):Integer;
begin for Result:=0 to FBWFieldCount-1 do if FBWFields[Result].Name=Name then Exit;Result:=-1;end;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=Value;Exit;end;raise Exception.Create(Name);end;
procedure SetTitle(const Title:string);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name='title' then begin S.Texts[K]:=Title;Exit;end;end;
procedure ReadMode(Mode:Integer);
begin Reader.Close;Reset(Mode);Reader.Tick;N:=Reader.Snapshot(V,Age,3000);end;
begin
 MockPath:=ExtractFilePath(ParamStr(0))+'MockFenixSim.dll';DLL:=LoadLibrary(PChar(MockPath));Check(DLL<>0,'Load mock aircraft transport');
 @Reset:=GetProcAddress(DLL,'FenixMockReset');@Counter:=GetProcAddress(DLL,'FenixMockCount');
 Reader:=TFBWReader.Create(MockPath);Provider:=TFBWProvider.Create(MockPath);S:=TFlightSample.Create;DB:=nil;
 try
  Check(Provider.Matches('FlyByWire A320neo LOT'),'FlyByWire title');Check(Provider.Matches('FBW-A32NX LOT'),'A32NX title');
  Check(not Provider.Matches('Fenix A320 CFM'),'No Fenix match');Check(not Provider.Matches('Asobo A320neo'),'No generic A320 match');Check(not Provider.Matches('FlyByWire A380X'),'No FBW A380 match');
  Check(IndexOf('A32NX_AUTOPILOT_1_ACTIVE')<0,'Deprecated AP fields excluded');Check(IndexOf('A32NX_AUTOBRAKES_ARMED_MODE_SET')<0,'Write-only setters excluded');Check(IndexOf('A32NX.FCU_AP_1_PUSH')<0,'Events excluded');
  ReadMode(0);Check(N=FBWFieldCount,'All readable FBW L-vars');Check(Counter(0)=FBWFieldCount,'223 definitions');Check(Counter(5)=0,'Correct read-only API definition');Check(Counter(4)=0,'No writes');
  SetN('autopilot_master',0);SetN('autopilot_throttle_arm',0);SetN('autothrottle_active',0);SetN('general_eng_throttle_lever_position[0]',79);
  Provider.Apply(S,V,Age,'');Check(S.N('flaps_handle_index')=4,'Native FBW detent 3 maps to MSFS detent 4');
  Check(S.N('autopilot_throttle_arm')=1,'Documented A/THR armed');Check(S.N('autothrottle_active')=1,'Documented A/THR active');Check(S.N('autopilot_master')=0,'AP light is not actual AP state');
  Check(S.N('autopilot_airspeed_hold_var')=180,'FCU selected IAS');Check(S.N('general_eng_throttle_lever_position[0]')=79,'Flight dynamics retained');
  Check((S.AircraftData.GetValue('performance_reference') as TJSONObject).GetValue('vapp_kt').Value='138','FMS VAPP in knots');
  ReadMode(8);SetN('flaps_handle_index',2);Provider.Apply(S,V,Age,'');Check(S.N('flaps_handle_index')=2,'Initialization preserves SimConnect');Check(S.DataSources=nil,'No SDK overrides until ready');
  Check((S.AircraftData.GetValue('performance_reference') as TJSONObject).GetValue('vapp_kt') is TJSONNull,'No fabricated VAPP before ready');
  ReadMode(9);Provider.Apply(S,V,Age,'');Check(Abs(S.N('autopilot_mach_hold_var')-0.78)<0.00001,'Mach value is not treated as IAS');
  ReadMode(10);SetN('autopilot_airspeed_hold_var',222);Provider.Apply(S,V,Age,'');Check(S.N('autopilot_airspeed_hold_var')=222,'FCU dashes preserve target');
  for I:=1 to 7 do begin
   ReadMode(I);
   case I of
    1:Check(N=LVarBatchSize,'Missing batch remains unavailable');
    2:Check(N=FBWFieldCount-1,'Nonfinite FBW value unavailable');
    3,4:Check(N=FBWFieldCount-LVarBatchSize,'Optional failed or malformed batch isolated');
    5,6:Check(N=0,'Quit or missing replies clear values');
    7:Check(N=FBWFieldCount,'Raw transported zeros retained');
   end;
  end;
  Reader.Close;Registry:=TAircraftProviders.Create('',MockPath);
  try
   Reset(0);SetTitle('FBW A32NX LOT');Registry.Capture(S);Check(S.AircraftData.GetValue('provider').Value='FBWA32NX','Automatic FBW selection');
   Reset(6);SetTitle('FBW A32NX New Livery');Registry.Capture(S);Check(S.AircraftData.GetValue('status').Value='unavailable_simconnect_fallback','Aircraft change resets FBW cache');
   SetTitle('Asobo A320neo');Registry.Tick(S,True,500);Registry.Capture(S);Check(S.AircraftData=nil,'No SDK values leak into other aircraft');
  finally Registry.Free;end;
  ReadMode(0);Provider.Apply(S,V,Age,'');SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
  Path:=ExtractFilePath(ParamStr(0))+'fbw-'+IntToStr(GetTickCount64)+'.db';DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');ID:=DB.StartTrip(S);
  DB.RecordSample(ID,S);SetN('time_zulu.seconds',1);DB.RecordSample(ID,S);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=1,'Unchanged FBW state omitted');
  Flaps:=IndexOf('A32NX_FLAPS_HANDLE_INDEX');V[Flaps]:=4;Provider.Apply(S,V,Age,'');SetN('time_zulu.seconds',2);DB.RecordSample(ID,S);EventID:=DB.Contact(ID,S,True);
  Check(Pos('A32NX_SPEEDS_VAPP',string(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1')))=0,'Delta omits unchanged raw FBW fields');
  for I:=0 to High(V) do V[I]:=NaN;Provider.Apply(S,V,0,'No response');SetN('time_zulu.seconds',3);DB.RecordSample(ID,S);
  ReadMode(0);Provider.Apply(S,V,Age,'');SetN('time_zulu.seconds',4);DB.RecordSample(ID,S);
  Plot:=DB.LoadTrip(ID);
  try I:=Plot.Labels.IndexOf('FBWLVar.A32NX_FLAPS_HANDLE_INDEX');Check(I>=0,'FBW chart parameter');Check(Plot.Points[0].Values[I]=3,'Raw FBW chart baseline');Check(Plot.Points[1].Values[I]=3,'FBW carry forward');Check(Plot.Points[2].Values[I]=4,'Raw full flap detent');Check(IsNan(Plot.Points[3].Values[I]),'FBW chart gap');Check(Plot.Points[4].Values[I]=3,'FBW chart recovery');finally Plot.Free;end;
  Q:=TFDQuery.Create(nil);Q.Connection:=DB.Connection;
  try Q.Open('select * from trip_touchdowns where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,1,1);
   try Check(Context.GetValue('fbw_lvar_field_definitions')<>nil,'FBW field definitions in AI');Check(Pos('vapp_kt',Context.ToJSON)>0,'VAPP in AI');Check(Pos('FBWA32NX',Context.ToJSON)>0,'FBW samples in AI');finally Context.Free;end;
  finally Q.Free;end;
  DB.DeleteTrip(ID);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=0,'FBW trip cleanup');
 finally DB.Free;S.Free;Provider.Free;Reader.Free;FreeLibrary(DLL);if Path<>'' then DeleteFile(PChar(Path));end;
 Writeln('PASS: FBW title detection, readable API catalog, real DLL calls, optional failures, readiness, A/THR, flap mapping, IAS/Mach/dashes, VAPP, cache isolation, delta history, charts and AI. Mock only.');
end.
