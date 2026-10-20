program VerifyAircraftSDK;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Math,System.JSON,System.IOUtils,FireDAC.Comp.Client,
 FlightTelemetryU,FlightDatabaseU,AircraftTelemetryU,AircraftDataStoreU,IFlyReaderU,IFlySDKCatalogU,FDRTypesU,TelemetryCatalogU,AnalysisContextU;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
var P:TIFlyProvider;R:TIFlyReader;V:TReadings;Stamp:TCaptureTime;Map,Mutex:THandle;View:Pointer;Buffer:array[0..SDKSize-1] of Byte;
 S:TFlightSample;Q:TFDQuery;Context:TJSONObject;Samples:TJSONArray;EventID:Integer;DB:TFlightDatabase;ID,I,RowID:Integer;History:TAircraftHistory;State:TJSONObject;Plot:TTripPlot;Name,Path:string;
procedure Put(const Field:string;Value:Double);
var K,N:Integer;
begin for K:=0 to SDKFieldCount-1 do if SDKFields[K].Name=Field then begin
 N:=Round(Value);if SDKFields[K].Kind='float64' then Move(Value,Buffer[SDKFields[K].Offset],8)
 else if SDKFields[K].Kind='int32' then Move(N,Buffer[SDKFields[K].Offset],4)
 else Buffer[SDKFields[K].Offset]:=N;Exit;end;raise Exception.Create(Field);end;
procedure SetN(const Field:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Field then begin S.Numbers[K]:=Value;Exit;end;raise Exception.Create(Field);end;
begin
 Name:='MSFSFDRTest'+IntToStr(GetCurrentProcessId);Path:=ExtractFilePath(ParamStr(0))+'sdk-'+Name+'.db';
 Mutex:=CreateMutex(nil,False,PChar(Name+'Mutex'));Map:=CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SDKSize,PChar(Name+'Map'));View:=MapViewOfFile(Map,FILE_MAP_WRITE,0,0,SDKSize);
 R:=TIFlyReader.Create(Name+'Map',Name+'Mutex');P:=TIFlyProvider.Create;S:=TFlightSample.Create;DB:=nil;
 try
  Check(P.Matches('iFly 737-MAX8 LOT SP-LVA (166Seat)'),'Detect iFly title');Check(not P.Matches('Boeing 737 MAX8'),'No other vendor');
  Check(not P.Matches('iFly 737-700'),'No other model');
  FillChar(Buffer,SizeOf(Buffer),0);Put('iFly737MAX_STATE',1);Put('Aircraft_Model',1);Put('FLAP_Status',5);Put('Gear_Lever_Status',1);Put('Throttle_Lever_1_Position',0.63);Put('AT_Switch_Status',1);Put('HDG_100_Status',2);Put('HDG_10_Status',5);Put('HDG_1_Status',1);Put('SPD_100_Status',2);Put('SPD_10_Status',4);Put('SPD_1_Status',0);
  Move(Buffer,View^,SDKSize);Check(R.Read(V,Stamp),'Read mapped SDK');Check(Length(V)=SDKFieldCount,'Read every SDK field');
  SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);SetN('airspeed_indicated',145);SetN('number_of_engines',2);
  P.Apply(S,V);Check(S.N('flaps_handle_index')=5,'SDK flap override');Check(Abs(S.N('general_eng_throttle_lever_position[0]')-63)<0.001,'Throttle unit conversion');Check(S.N('airspeed_indicated')=145,'SimConnect dynamics preserved');Check(S.N('autopilot_heading_lock_dir')=251,'SDK selected heading digits');Check(S.N('autopilot_airspeed_hold_var')=240,'SDK selected IAS digits');
  SetN('autopilot_heading_lock_dir',123);Put('HDG_100_Status',14);Move(Buffer,View^,SDKSize);Check(R.Read(V,Stamp),'Read blank display');P.Apply(S,V);Check(S.N('autopilot_heading_lock_dir')=123,'Blank SDK digits preserve SimConnect');
  Put('HDG_100_Status',2);Move(Buffer,View^,SDKSize);Check(R.Read(V,Stamp),'Read restored display');P.Apply(S,V);
  Check((S.AircraftData.GetValue('fields') as TJSONObject).Count=SDKFieldCount,'All raw SDK fields');
  DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');ID:=DB.StartTrip(S);
  DB.RecordSample(ID,S);SetN('time_zulu.seconds',1);DB.RecordSample(ID,S);
  Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=1,'Unchanged SDK omitted');
  Put('FLAP_Status',6);Move(Buffer,View^,SDKSize);Check(R.Read(V,Stamp),'Read changed SDK');P.Apply(S,V);SetN('time_zulu.seconds',2);DB.RecordSample(ID,S);
  State:=TJSONObject.ParseJSONValue(DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data order by sample desc limit 1')) as TJSONObject;
  try Check(Pos('FLAP_Status',State.ToJSON)>0,'SDK delta includes change');Check(Pos('Aircraft_Model',State.ToJSON)=0,'SDK delta omits unchanged');finally State.Free;end;
  EventID:=DB.Contact(ID,S,True);
  FreeAndNil(S.AircraftData);FreeAndNil(S.DataSources);S.AircraftData:=TJSONObject.Create;S.AircraftData.AddPair('provider','iFly737MAX');S.AircraftData.AddPair('status','unavailable_simconnect_fallback');SetN('time_zulu.seconds',3);DB.RecordSample(ID,S);
  RowID:=DB.Connection.ExecSQLScalar('select max(id) from trip_data');History:=TAircraftHistory.Create(DB.Connection,ID);
  try State:=History.AtSample(RowID);try Check(Pos('FLAP_Status',State.ToJSON)=0,'No stale SDK on disconnect');finally State.Free;end;finally History.Free;end;
  P.Apply(S,V);SetN('time_zulu.seconds',4);DB.RecordSample(ID,S);Plot:=DB.LoadTrip(ID);
  try I:=Plot.Labels.IndexOf('iFlySDK.FLAP_Status');Check(I>=0,'SDK chart available');Check(Plot.Points[0].Values[I]=5,'SDK chart baseline');Check(Plot.Points[1].Values[I]=5,'SDK chart carry forward');Check(Plot.Points[2].Values[I]=6,'SDK chart delta');Check(IsNan(Plot.Points[3].Values[I]),'SDK chart gap');Check(Plot.Points[4].Values[I]=6,'SDK chart reconnect');finally Plot.Free;end;
  Q:=TFDQuery.Create(nil);Q.Connection:=DB.Connection;
  try Q.Open('select * from trip_touchdowns where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,1,1);
   try
    Check(Context.GetValue('ifly_sdk_field_definitions')<>nil,'SDK units/enum descriptions in analysis');
    Samples:=Context.GetValue('samples') as TJSONArray;Check(Samples.Count=3,'Analysis window');
    Check(Pos('FLAP_Status',Samples.Items[0].ToJSON)>0,'Window baseline reconstructs earlier SDK data');
    Check(Pos('unavailable_simconnect_fallback',Samples.Items[2].ToJSON)>0,'Analysis SDK outage');
   finally Context.Free;end;
  finally Q.Free;end;
  Put('iFly737MAX_STATE',0);Move(Buffer,View^,SDKSize);Check(not R.Read(V,Stamp),'SDK not running rejected');
  DB.DeleteTrip(ID);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=0,'SDK trip cleanup');
 finally DB.Free;S.Free;P.Free;R.Free;UnmapViewOfFile(View);CloseHandle(Map);CloseHandle(Mutex);DeleteFile(PChar(Path));end;
 Writeln('PASS: official SDK shared memory, aircraft detection, all 2411 fields, precedence, units, delta persistence, chart replay, disconnect/reconnect and cleanup.');
end.
