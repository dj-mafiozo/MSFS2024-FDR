program VerifyContext;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.IOUtils,System.JSON,FireDAC.Comp.Client,FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU,AnalysisContextU;
procedure Require(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
var DB:TFlightDatabase;S:TFlightSample;Q:TFDQuery;J:TJSONObject;Samples:TJSONArray;Window,Row,State:TJSONObject;Deltas,Expanded:TJSONArray;ID,EventID,I:Integer;Seconds:Double;
procedure SetN(const Name:string;V:Double);
var K:Integer;
begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=V;Exit;end;raise Exception.Create(Name);end;
procedure Merge(State,Delta:TJSONObject);
var K:Integer;P:TJSONPair;Old:TJSONValue;
begin
 for K:=0 to Delta.Count-1 do begin
  P:=Delta.Pairs[K];Old:=State.GetValue(P.JsonString.Value);
  if (Old is TJSONObject) and (P.JsonValue is TJSONObject) then Merge(TJSONObject(Old),TJSONObject(P.JsonValue))
  else begin
   if Old<>nil then State.RemovePair(P.JsonString.Value).Free;
   State.AddPair(P.JsonString.Value,TJSONObject.ParseJSONValue(P.JsonValue.ToJSON));
  end;
 end;
end;
begin
 DB:=TFlightDatabase.Create(ExtractFilePath(ParamStr(0))+'context-'+IntToStr(GetTickCount64)+'.db',ExtractFilePath(ParamStr(0))+'sqlite3.dll');S:=TFlightSample.Create;Q:=TFDQuery.Create(nil);
 try
  SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',12);SetN('time_zulu.seconds',86370);ID:=DB.StartTrip(S);EventID:=0;
  for I:=0 to 180 do begin
   Seconds:=86370+I*0.5;SetN('time_zulu.day',12+Trunc(Seconds/86400));SetN('time_zulu.seconds',Seconds-Trunc(Seconds/86400)*86400);
   SetN('ambient_temperature',12+Ord(I>=120));SetN('ambient_pressure',28.92);SetN('barometer_pressure',1013);SetN('ambient_visibility',8000-I*10);SetN('ambient_wind_direction',250);SetN('ambient_wind_velocity',10);
   SetN('number_of_engines',2);SetN('turb_eng_n1[0]',45);SetN('turb_eng_n1[1]',46);SetN('general_eng_throttle_lever_position[0]',50+20*Ord(I>=100));
   SetN('autopilot_master',Ord((I<120) or (I>=130)));SetN('autothrottle_active',Ord(I<120));SetN('autopilot_throttle_arm',1);
   SetN('gear_position_0',1);SetN('gear_position_1',1);SetN('gear_position_2',1);
   if I>=121 then SetN('gear_position_1',0.35);
   SetN('gear_is_on_ground_0',Ord(I<119));SetN('gear_is_on_ground_1',Ord(I<120));SetN('gear_is_on_ground_2',Ord(I<121));
   SetN('wheel_rpm_0',10);SetN('wheel_rpm_1',20);SetN('wheel_rpm_2',30);
   SetN('sim_on_ground',Ord(I<120));SetN('plane_pitch_degrees',-8.5);SetN('g_force',1);if I=122 then SetN('g_force',2.3);
   SetN('vertical_speed',I-100);DB.RecordSample(ID,S);
   if I=120 then EventID:=DB.Contact(ID,S,False);
   if I=140 then DB.Contact(ID,S,True);
  end;
  DB.Connection.ExecSQL('update trip_engine_data set turb_eng_n1=NULL where engine=1 and sample=(select id from trip_data where trip=:t order by id limit 1 offset 125)',[ID]);
  DB.Connection.ExecSQL('delete from trip_engine_data where engine=2 and sample=(select id from trip_data where trip=:t order by id limit 1 offset 127)',[ID]);
  DB.Connection.ExecSQL('update trip_liftoffs set distance_length=1000,distance_width=-10,runway_heading=0 where id=:id',[EventID]);
  Q.Connection:=DB.Connection;Q.Open('select * from trip_liftoffs where id='+IntToStr(EventID));
  Expanded:=nil;J:=BuildContactContext(DB,Q,60,30);
  try
   Deltas:=J.GetValue<TJSONArray>('samples');
   Require(Length(Deltas.ToJSON)<Length(Deltas.Items[0].ToJSON)*Deltas.Count div 2,'Delta payload must be smaller than full repeated states');
   Expanded:=TJSONArray.Create;State:=TJSONObject.Create;
   try
    Require(TJSONObject(Deltas.Items[1]).GetValue('ambient_pressure')=nil,'Repeated value omitted');
    Require(TJSONObject(Deltas.Items[120]).GetValue('autopilot_master').Value='false','False change retained');
    Require(TJSONObject(Deltas.Items[121]).GetValue('autopilot_master')=nil,'Unchanged false omitted');
    Require(TJSONObject(Deltas.Items[125]).GetValue<TJSONObject>('engines').GetValue<TJSONObject>('1').GetValue('turb_eng_n1') is TJSONNull,'Engine explicit null retained');
    Require(TJSONObject(Deltas.Items[127]).GetValue<TJSONObject>('engines').GetValue('2') is TJSONNull,'Missing engine explicit null');
    for I:=0 to Deltas.Count-1 do begin
     Merge(State,TJSONObject(Deltas.Items[I]));Expanded.AddElement(TJSONObject.ParseJSONValue(State.ToJSON));
     Require(State.GetValue('autopilot_master').Value=LowerCase(BoolToStr((I<120) or (I>=130),True)),'AP state reconstruction');
     Require(State.GetValue('autothrottle_active').Value=LowerCase(BoolToStr(I<120,True)),'AT state reconstruction');
     Require(State.GetValue<Integer>('ambient_visibility')=8000-I*10,'Weather reconstruction');
    end;
   finally State.Free;end;
   Samples:=Expanded;Window:=J.GetValue<TJSONObject>('window');
   Require(Samples.Count=181,'Full 90-second window across midnight');
   Require(Window.GetValue<Integer>('before_count')=120,'Samples before liftoff');Require(Window.GetValue<Integer>('after_count')=60,'Samples after liftoff');
   Require(Abs(Window.GetValue<Double>('observed_max_g')-2.3)<0.001,'Post-event peak retained');
   Row:=TJSONObject(Samples.Items[120]);Require(Abs(Row.GetValue<Double>('pitch_nose_up_deg')-8.5)<0.001,'Pitch sign normalized');
   Require(Row.GetValue('sim_on_ground').Value='false','Ground bit decoded');
   Require(J.GetValue<TJSONArray>('nearby_contacts').Count=2,'Liftoff/touchdown sequence supplied');
   Require(J.GetValue<TJSONObject>('weather').GetValue<TJSONObject>('nearest_event_sample').GetValue<Integer>('ambient_temperature')=13,'Weather nearest event');
   Require(TJSONObject(Samples.Items[0]).GetValue<Integer>('ambient_temperature')=12,'Before-event weather retained');
   Require(TJSONObject(Samples.Items[180]).GetValue<Integer>('ambient_visibility')=6200,'After-event visibility retained');
   Require(Abs(Row.GetValue<Double>('ambient_pressure')-28.92)<0.001,'Local pressure inHg retained');
   Require(Row.GetValue<Integer>('barometer_pressure')=1013,'Sea-level pressure retained separately');
   Row:=TJSONObject(Samples.Items[121]).GetValue<TJSONObject>('landing_gear');
   Require(Abs(Row.GetValue<TJSONObject>('left').GetValue<Double>('extension_ratio')-0.35)<0.0001,'Fractional gear extension preserved');
   Require(Row.GetValue<TJSONObject>('right').GetValue<Integer>('wheel_rpm')=30,'Right wheel RPM separate');
   Row:=TJSONObject(Samples.Items[119]).GetValue<TJSONObject>('landing_gear');
   Require(Row.GetValue<TJSONObject>('center').GetValue('on_ground').Value='false','Nose contact independent');
   Require(Row.GetValue<TJSONObject>('left').GetValue('on_ground').Value='true','Left contact independent');
   Require(Abs(J.GetValue<TJSONObject>('event').GetValue<Double>('distance_from_threshold_m')-304.8)<0.0001,'Event distance converted to metres');
   Require(Abs(TJSONObject(Samples.Items[0]).GetValue<Double>('runway_cross_m')+3.048)<0.0001,'Signed runway cross-track metres');
   Require(J.GetValue<TJSONObject>('event').GetValue('airspeed_indicated') is TJSONNumber,'Typed contact numbers');
  finally Expanded.Free;J.Free;end;
  J:=BuildContactContext(DB,Q,1,1);try Require(J.GetValue<TJSONArray>('samples').Count=5,'Configurable bounded window');finally J.Free;end;
 finally Q.Free;S.Free;DB.Free;end;
 Writeln('PASS: full parameter baseline, AP/AT transitions, recursive deltas, engine null/removal/reappearance, reconstructed weather and reduced payload across 181 snapshots.');
end.
