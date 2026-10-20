program VerifyFenix;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Math,System.JSON,System.IOUtils,FireDAC.Comp.Client,
 FlightTelemetryU,TelemetryCatalogU,FlightDatabaseU,AircraftTelemetryU,FenixReaderU,FenixCatalogU,AircraftDataStoreU,AnalysisContextU;
type TReset=procedure(Mode:Integer);stdcall;TCount=function(Kind:Integer):Integer;stdcall;
var DLL:HMODULE;Reset:TReset;Counter:TCount;Reader:TFenixReader;Registry:TAircraftProviders;Provider:TFenixProvider;S:TFlightSample;DB:TFlightDatabase;Q:TFDQuery;
 V:TArray<Double>;Age:UInt64;N,I,Gear,Flaps,ID,EventID:Integer;Path,MockPath:string;Plot:TTripPlot;Context,State:TJSONObject;History:TAircraftHistory;
 Packet:array[0..40+FenixBatchSize*8-1]of Byte;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=Value;Exit;end;raise Exception.Create(Name);end;
procedure SetTitle(const Title:string);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name='title' then begin S.Texts[K]:=Title;Exit;end;end;
function IndexOf(const Name:string):Integer;
begin for Result:=0 to FenixFieldCount-1 do if FenixFields[Result].Name=Name then Exit;raise Exception.Create(Name);end;
procedure Put(Offset:Integer;Value:DWORD);begin Move(Value,Packet[Offset],4);end;
begin
 MockPath:=ExtractFilePath(ParamStr(0))+'MockFenixSim.dll';DLL:=LoadLibrary(PChar(MockPath));Check(DLL<>0,'Load mock Fenix transport');
 @Reset:=GetProcAddress(DLL,'FenixMockReset');@Counter:=GetProcAddress(DLL,'FenixMockCount');
 Reader:=TFenixReader.Create(MockPath);Provider:=TFenixProvider.Create(MockPath);S:=TFlightSample.Create;DB:=nil;
 try
  Check(Provider.Matches('Fenix A320 CFM LOT SP-LNA'),'Fenix title');Check(Provider.Matches('FNX_320_IAE'),'FNX title');
  Check(not Provider.Matches('iFly 737-MAX8 LOT'),'No iFly match');Check(not Provider.Matches('Asobo A320neo'),'No other Airbus match');
  Registry:=TAircraftProviders.Create(MockPath);
  try
   Reset(0);SetTitle('Asobo A320neo');Registry.Capture(S);Check(S.AircraftData=nil,'Generic aircraft uses SimConnect only');Check(Counter(0)=0,'No Fenix requests for other aircraft');
   SetTitle('Fenix A320 LOT');Registry.Capture(S);Check(S.AircraftData.GetValue('provider').Value='FenixA32X','Automatic Fenix provider selection');Check(S.AircraftData.GetValue('received_field_count').Value=IntToStr(FenixFieldCount),'Automatic live reader capture');
   Reset(6);SetTitle('Fenix A320 Another Livery');Registry.Capture(S);Check(S.AircraftData.GetValue('status').Value='unavailable_simconnect_fallback','Changing Fenix title invalidates old data');
   SetTitle('Asobo A320neo');Registry.Tick(S,True,500);Registry.Capture(S);Check(S.AircraftData=nil,'Leaving Fenix clears provider state');
  finally Registry.Free;end;
  Reset(0);Reader.Tick;N:=Reader.Snapshot(V,Age,3000);Check(N=FenixFieldCount,'All Fenix L-vars decoded');
  Check(Counter(0)=FenixFieldCount,'Every L-var defined');Check(Counter(1)=FenixBatchCount,'Bounded definition batches');Check(Counter(5)=0,'Correct names, datatype, units and read requests');Check(Counter(4)=0,'No simulator writes');
  Gear:=IndexOf('S_MIP_GEAR');Flaps:=IndexOf('S_FC_FLAPS');Check(V[Gear]=1,'Gear L-var value');Check(V[Flaps]=3,'Flap L-var value');
  SetN('gear_handle_position',0);SetN('flaps_handle_index',0);SetN('general_eng_throttle_lever_position[0]',79);SetN('autopilot_master',0);
  Provider.Apply(S,V,Age,'');Check(S.N('gear_handle_position')=1,'Gear SDK precedence');Check(S.N('flaps_handle_index')=3,'Flap SDK precedence');
  Check(S.N('general_eng_throttle_lever_position[0]')=79,'Fenix animation input is not throttle percent');Check(S.N('autopilot_master')=0,'AP annunciator not mistaken for AP master');
  Check(S.DataSources.GetValue('gear_handle_position').Value='FenixLVar:S_MIP_GEAR','Fenix provenance');
  // Transport failures remain optional and never invent zero values.
  for I:=1 to 7 do begin
   Reader.Close;Reset(I);Reader.Tick;N:=Reader.Snapshot(V,Age,3000);
   case I of
    1:Check(N=FenixFieldCount-(FenixFieldCount mod FenixBatchSize),'Missing batch is null');
    2:begin Check(N=FenixFieldCount-1,'Non-finite L-var is null');Check(IsNan(V[Gear]),'Invalid gear not zero');end;
    3:begin Check(N=FenixFieldCount-FenixBatchSize,'Optional exception isolates batch');Check(Reader.LastError<>'','Optional exception diagnostics');end;
    4:Check(N=FenixFieldCount-FenixBatchSize,'Malformed batch rejected');
    5:Check(N=0,'Quit invalidates cached values');
    6:Check(N=0,'No replies produce null values');
    7:begin Check(N=FenixFieldCount,'Received zero values retained');Check(V[Gear]=0,'Real transported zero retained');end;
   end;
  end;
  Reader.Close;Reset(0);Reader.Tick;Check(Reader.Snapshot(V,Age,3000)=FenixFieldCount,'Reconnection');
  FillChar(Packet,SizeOf(Packet),0);Put(8,8);
  for I:=0 to FenixBatchCount-1 do begin
   Put(12,2000+I);Put(20,1000+I);N:=Min(FenixBatchSize,FenixFieldCount-I*FenixBatchSize);Put(36,N);
   Reader.Feed(@Packet[0],40+N*8,GetTickCount64-10000);
  end;
  Check(Reader.Snapshot(V,Age,1000)=0,'Stale packets expire');
  Reader.Close;Reset(0);Reader.Tick;Reader.Snapshot(V,Age,3000);Provider.Apply(S,V,Age,'');
  SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
  Path:=ExtractFilePath(ParamStr(0))+'fenix-'+IntToStr(GetTickCount64)+'.db';DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');ID:=DB.StartTrip(S);
  DB.RecordSample(ID,S);SetN('time_zulu.seconds',1);DB.RecordSample(ID,S);
  Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=1,'Unchanged Fenix state omitted');
  V[Flaps]:=1;Provider.Apply(S,V,Age,'');SetN('time_zulu.seconds',2);DB.RecordSample(ID,S);EventID:=DB.Contact(ID,S,True);
  Check(Pos('I_FCU_AP1',string(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1')))=0,'Delta omits unchanged Fenix fields');
  for I:=0 to High(V) do V[I]:=NaN;SetN('gear_handle_position',0.5);Provider.Apply(S,V,0,'No fresh Fenix response');SetN('time_zulu.seconds',3);DB.RecordSample(ID,S);
  Check(S.DataSources=nil,'Outage clears SDK overrides');Check(S.N('gear_handle_position')=0.5,'Outage preserves SimConnect');
  Reader.Close;Reset(0);Reader.Tick;Reader.Snapshot(V,Age,3000);Provider.Apply(S,V,Age,'');SetN('time_zulu.seconds',4);DB.RecordSample(ID,S);
  // A provider change must reset carry-forward state instead of mixing aircraft.
  FreeAndNil(S.AircraftData);FreeAndNil(S.DataSources);S.AircraftData:=TJSONObject.ParseJSONValue('{"provider":"iFly737MAX","status":"available","fields":{"CabinAltitude":5000}}') as TJSONObject;
  SetN('time_zulu.seconds',5);DB.RecordSample(ID,S);
  Plot:=DB.LoadTrip(ID);
  try
   I:=Plot.Labels.IndexOf('FenixLVar.S_FC_FLAPS');Check(I>=0,'Fenix chart parameter');
   Check(Plot.Points[0].Values[I]=3,'Fenix chart baseline');Check(Plot.Points[1].Values[I]=3,'Fenix chart carry forward');Check(Plot.Points[2].Values[I]=1,'Fenix chart delta');
   Check(IsNan(Plot.Points[3].Values[I]),'Fenix chart outage gap');Check(Plot.Points[4].Values[I]=3,'Fenix chart reconnect');Check(IsNan(Plot.Points[5].Values[I]),'No cross-provider carry forward');
   I:=Plot.Labels.IndexOf('iFlySDK.CabinAltitude');Check(Plot.Points[5].Values[I]=5000,'iFly history still loads');
  finally Plot.Free;end;
  Q:=TFDQuery.Create(nil);Q.Connection:=DB.Connection;
  try
   Q.Open('select * from trip_touchdowns where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,1,1);
   try
    Check(Context.GetValue('fenix_lvar_field_definitions')<>nil,'Fenix definitions in AI');
    Check(Pos('FenixA32X',Context.ToJSON)>0,'Fenix payload in AI');Check(Pos('S_FC_FLAPS',Context.ToJSON)>0,'Fenix window baseline');
    Check(Pos('unavailable_simconnect_fallback',Context.ToJSON)>0,'Fenix outage in AI');
   finally Context.Free;end;
  finally Q.Free;end;
  History:=TAircraftHistory.Create(DB.Connection,ID);
  try State:=History.AtSample(DB.Connection.ExecSQLScalar('select max(id) from trip_data'));try Check(Pos('S_FC_FLAPS',State.ToJSON)=0,'Provider reset drops old fields');finally State.Free;end;finally History.Free;end;
  DB.DeleteTrip(ID);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=0,'Fenix history deletion');
 finally DB.Free;S.Free;Provider.Free;Reader.Free;FreeLibrary(DLL);if Path<>'' then DeleteFile(PChar(Path));end;
 Writeln('PASS: automatic Fenix matching, 1203 L-vars via mock SimConnect DLL, batching, read-only API, provenance, zeros/null/stale/partial/malformed/error/reconnect, delta storage, charts, AI and provider isolation.');
end.
