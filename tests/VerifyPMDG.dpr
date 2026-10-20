program VerifyPMDG;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Math,System.JSON,FireDAC.Comp.Client,FlightTelemetryU,TelemetryCatalogU,FlightDatabaseU,
 AircraftTelemetryU,PMDGNG3ReaderU,PMDGNG3CatalogU,PMDGNG3DecodeU,AnalysisContextU;
type TReset=procedure(Mode:Integer);stdcall;TCount=function(Kind:Integer):Integer;stdcall;
var DLL:HMODULE;Reset:TReset;Counter:TCount;Reader:TPMDGNG3Reader;Provider:TPMDGNG3Provider;Registry:TAircraftProviders;
 S:TFlightSample;DB:TFlightDatabase;Q:TFDQuery;Fields,Performance,CDU,Context:TJSONObject;Rows:TJSONArray;
 Data,Screen,Packet:TBytes;Age:UInt64;I,ID,EventID,Index:Integer;Path,MockPath:string;Plot:TTripPlot;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=Value;Exit;end;raise Exception.Create(Name);end;
procedure SetTitle(const Title:string);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name='title' then begin S.Texts[K]:=Title;Exit;end;end;
procedure ReadMode(Mode:Integer);
begin Reader.Close;Reset(Mode);Reader.Tick;Reader.Snapshot(0,Data,Age);end;
procedure SetSDKByte(const Name:string;V:Byte);
var K:Integer;begin for K:=0 to PMDGFieldCount-1 do if PMDGFields[K].Name=Name then begin Data[PMDGFields[K].Offset]:=V;Exit;end;raise Exception.Create(Name);end;
procedure PutHeader(Offset:Integer;V:DWORD);begin Move(V,Packet[Offset],4);end;
begin
 MockPath:=ExtractFilePath(ParamStr(0))+'MockPMDGSim.dll';DLL:=LoadLibrary(PChar(MockPath));Check(DLL<>0,'Load mock PMDG transport');
 @Reset:=GetProcAddress(DLL,'PMDGMockReset');@Counter:=GetProcAddress(DLL,'PMDGMockCount');
 Reader:=TPMDGNG3Reader.Create(MockPath);Provider:=TPMDGNG3Provider.Create(MockPath);S:=TFlightSample.Create;DB:=nil;
 try
  Check(Provider.Matches('PMDG 737-600 LOT'),'PMDG 736');Check(Provider.Matches('PMDG 737-700 BBJ'),'PMDG 737');Check(Provider.Matches('PMDG B738 LOT'),'PMDG B738');
  Check(not Provider.Matches('PMDG 777-300ER'),'No PMDG widebody');Check(not Provider.Matches('PMDG 737 MAX8'),'No different MAX SDK');Check(not Provider.Matches('iFly 737 MAX8'),'No other vendor');
  ReadMode(0);Check(Length(Data)=PMDGDataSize,'SDK block size');Check(Counter(0)=3,'Only main and CDU areas mapped');Check(Counter(1)=3,'SDK definitions');Check(Counter(2)=6,'ON_SET and ONCE requests');Check(Counter(5)=0,'Names, IDs, sizes and periods');Check(Counter(3)=0,'No SDK writes or controls');
  Fields:=DecodePMDGData(Data);
  try
   Check(Fields.Count=PMDGFieldCount,'All 494 named fields');Check(Fields.GetValue('FMC_V1').Value='135','V1 byte');Check(Fields.GetValue('MCP_VertSpeed').Value='-700','Signed MCP vertical speed');
   Check(Fields.GetValue('FMC_LandingAltitude').Value='-150','Signed below-sea-level elevation');Check(Fields.GetValue('COMM_ReceiverSwitches[0]').Value=IntToStr(Int64($F1234567)),'Unsigned 32-bit flags');Check(Fields.GetValue('FMC_flightNumber').Value='LOT123','Null-terminated string');
  finally Fields.Free;end;
  Check(Reader.Snapshot(1,Screen,Age),'Optional captain CDU');CDU:=DecodePMDGCDU(Screen);
  try Rows:=CDU.GetValue('rows') as TJSONArray;Check(Rows.Count=14,'14 CDU rows');Check(Pos('PMDG CAPTAIN',Rows.Items[0].Value)=1,'Column-major CDU text');Check(Rows.Items[1].Value[1]=WideChar($2190),'CDU special arrow');Check(Copy(CDU.GetValue('raw_cells_hex').Value,7,6)='A10101','CDU symbol/color/font flags preserved');finally CDU.Free;end;
  SetN('gear_handle_position',0.25);SetN('autopilot_master',0);SetN('autothrottle_active',0);SetN('autopilot_airspeed_hold_var',222);
  Provider.Apply(S,Data,Age,'');Check(S.N('gear_handle_position')=1,'SDK down lever precedence');Check(S.N('autopilot_master')=1,'Actual AFS control');Check(S.N('autothrottle_active')=1,'Actual A/T servo connection');
  Check(S.N('fuel_total_quantity_weight')=5000,'Fuel mass pounds');Check(S.N('autopilot_vertical_hold_var')=-700,'SDK vertical target');Check(S.N('autopilot_airspeed_hold_var')=175,'MCP IAS');
  Performance:=S.AircraftData.GetValue('performance_reference') as TJSONObject;
  Check(Performance.GetValue('v1_kt').Value='135','FMC V1 reference');Check(Performance.GetValue('vr_kt').Value='140','FMC VR reference');Check(Performance.GetValue('v2_kt').Value='145','FMC V2 reference');Check(Performance.GetValue('vref_kt').Value='130','FMC VREF reference');Check(Performance.GetValue('distance_to_tod_nm').Value='0','TOD passed zero remains valid');
  ReadMode(7);Provider.Apply(S,Data,Age,'');Performance:=S.AircraftData.GetValue('performance_reference') as TJSONObject;
  Check(Performance.GetValue('v1_kt') is TJSONNull,'Unset V-speed not zero');Check(Performance.GetValue('vref_kt') is TJSONNull,'Unset VREF');Check(Performance.GetValue('landing_altitude_ft') is TJSONNull,'Unavailable altitude sentinel');Check(Performance.GetValue('distance_to_tod_nm') is TJSONNull,'Unavailable negative distance');
  ReadMode(8);SetN('gear_handle_position',0.25);Provider.Apply(S,Data,Age,'');Check(S.N('gear_handle_position')=0.25,'OFF lever is not collapsed to up/down');Check(S.DataSources.GetValue('gear_handle_position')=nil,'OFF lever provenance retains SimConnect');
  ReadMode(9);Provider.Apply(S,Data,Age,'');Check(Abs(S.N('autopilot_mach_hold_var')-0.78)<0.0001,'MCP Mach float');
  ReadMode(10);SetN('autopilot_heading_lock_dir',123);Provider.Apply(S,Data,Age,'');Check(S.N('autopilot_heading_lock_dir')=123,'Unpowered MCP preserves target');
  ReadMode(12);SetN('autopilot_airspeed_hold_var',222);SetN('autopilot_vertical_hold_var',-222);Provider.Apply(S,Data,Age,'');Check(S.N('autopilot_airspeed_hold_var')=222,'Blank IAS');Check(S.N('autopilot_vertical_hold_var')=-222,'Blank VS');
  ReadMode(2);SetN('pressurization_cabin_altitude',2000);SetN('autopilot_airspeed_hold_var',222);Provider.Apply(S,Data,Age,'');Check(S.AircraftData.GetValue('status').Value='partial','Malformed field makes partial status');Check(S.N('pressurization_cabin_altitude')=2000,'NaN does not override standard field');Check(S.N('autopilot_airspeed_hold_var')=222,'Invalid bool does not masquerade as blank=false');
  ReadMode(11);Provider.Apply(S,Data,Age,'');Check(S.DataSources=nil,'Uninitialized SDK does not override');Check(S.AircraftData.GetValue('status').Value='initializing','Model zero not valid flight data');
  for I:=1 to 6 do begin
   ReadMode(I);
   case I of
    1:begin Check(Length(Data)=PMDGDataSize,'Missing optional CDU cannot block main data');Check(not Reader.Snapshot(2,Screen,Age),'Missing CDU unavailable');end;
    3,4,5,6:Check(Length(Data)=0,'Error/truncation/quit/no reply invalidates main data');
   end;
  end;
  ReadMode(15);Check(Length(Data)=PMDGDataSize,'Optional CDU error isolated');Check(not Reader.Snapshot(2,Screen,Age),'Failed CDU unavailable');
  ReadMode(0);SetLength(Packet,40+PMDGDataSize);FillChar(Packet[0],Length(Packet),0);PutHeader(8,16);PutHeader(12,7000);PutHeader(20,PMDGDataDefinition);PutHeader(36,1);Move(Data[0],Packet[40],PMDGDataSize);
  Reader.Feed(@Packet[0],Length(Packet),GetTickCount64-60000);Check(Reader.Snapshot(0,Data,Age) and (Age>=60000),'ON_SET cached state retained without artificial heartbeat');
  Reader.Close;Registry:=TAircraftProviders.Create('','',MockPath);
  try
   Reset(0);SetTitle('PMDG 737-600 LOT');Registry.Capture(S);Check(S.AircraftData.GetValue('provider').Value='PMDGNG3','Automatic SDK selection');Check(S.AircraftData.GetValue('cdu')<>nil,'Both CDUs included in snapshot');
   Reset(6);SetTitle('PMDG 737-800 Another Livery');Registry.Capture(S);Check(S.AircraftData.GetValue('status').Value='unavailable_simconnect_fallback','Aircraft change resets SDK cache');
   SetTitle('Asobo A320neo');Registry.Capture(S);Check(S.AircraftData=nil,'No SDK values leak into generic aircraft');
  finally Registry.Free;end;
  ReadMode(0);Provider.Apply(S,Data,Age,'');SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
  Path:=ExtractFilePath(ParamStr(0))+'pmdg-'+IntToStr(GetTickCount64)+'.db';DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');ID:=DB.StartTrip(S);
  DB.RecordSample(ID,S);SetN('time_zulu.seconds',1);DB.RecordSample(ID,S);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=1,'Unchanged PMDG SDK state omitted');
  SetSDKByte('FMC_V1',136);Provider.Apply(S,Data,Age,'');SetN('time_zulu.seconds',2);DB.RecordSample(ID,S);EventID:=DB.Contact(ID,S,True);
  Check(Pos('FMC_VR',string(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1')))=0,'Unchanged FMC fields omitted from delta');
  Provider.Apply(S,nil,0,'No SDK data');SetN('time_zulu.seconds',3);DB.RecordSample(ID,S);ReadMode(0);Provider.Apply(S,Data,Age,'');SetN('time_zulu.seconds',4);DB.RecordSample(ID,S);
  Plot:=DB.LoadTrip(ID);
  try Index:=Plot.Labels.IndexOf('PMDGNG3.FMC_V1');Check(Index>=0,'PMDG chart parameter');Check(Plot.Points[0].Values[Index]=135,'SDK chart baseline');Check(Plot.Points[1].Values[Index]=135,'SDK chart carry forward');Check(Plot.Points[2].Values[Index]=136,'SDK chart change');Check(IsNan(Plot.Points[3].Values[Index]),'SDK chart gap');Check(Plot.Points[4].Values[Index]=135,'SDK chart recovery');finally Plot.Free;end;
  Q:=TFDQuery.Create(nil);Q.Connection:=DB.Connection;
  try Q.Open('select * from trip_touchdowns where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,1,1);
   try Check(Context.GetValue('pmdg_ng3_field_definitions')<>nil,'SDK definitions in AI');Check(Pos('vref_kt',Context.ToJSON)>0,'FMC references in AI');Check(Pos('PMDGNG3',Context.ToJSON)>0,'SDK time series in AI');finally Context.Free;end;
  finally Q.Free;end;
  DB.DeleteTrip(ID);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=0,'SDK trip cleanup');
 finally DB.Free;S.Free;Provider.Free;Reader.Free;FreeLibrary(DLL);if Path<>'' then DeleteFile(PChar(Path));end;
 Writeln('PASS: PMDG NG3 typed Client Data, 494 fields, signed/float/text decoding, FMC sentinels, AP/AT, MCP blank/power/Mach, gear OFF, CDU layout/arrows/colors, optional failures, provider reset, cached ON_SET, delta history, charts and AI. Mock only.');
end.
