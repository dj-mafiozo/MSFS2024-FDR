program VerifyAirbusMCDU;
{$APPTYPE CONSOLE}
uses Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  FireDAC.Comp.Client, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, FMCScreensU, AirbusMCDUValuesU;
var Screen: TFMCScreen; Parsed, Root, CDU, Obj, Context, Values: TJSONObject;
  Rows: TJSONArray; DB: TFlightDatabase; Sample: TFlightSample; Path,Provider: string; I,K,Trip: Integer;
procedure Check(B:Boolean;const M:string);
begin if not B then raise Exception.Create(M);end;
procedure Blank(const Title:string);
var R:Integer;
begin Screen.Lines.Clear;Screen.Lines.Add(Copy(Title+StringOfChar(' ',24),1,24));
  for R:=1 to 13 do Screen.Lines.Add(StringOfChar(' ',24));Screen.Available:=True;Screen.PowerState:=-1;end;
procedure Cell(Row,Col:Integer;const Text:string);
var L:string;J:Integer;
begin L:=Screen.Lines[Row];for J:=1 to Length(Text) do L[Col+J]:=Text[J];Screen.Lines[Row]:=L;end;
procedure Field(Row,Col:Integer;const LabelText,Text:string);
begin Cell(Row,Col,LabelText);Cell(Row+1,Col,Text);end;
procedure Num(const Key:string;N:Double);
begin Check(Parsed.GetValue(Key) is TJSONNumber,'Numeric '+Key);
  Check(Abs(TJSONNumber(Parsed.GetValue(Key)).AsDouble-N)<0.001,'Value '+Key);end;
procedure Null(const Key:string);
begin Check(Parsed.GetValue(Key) is TJSONNull,'Null '+Key);end;
procedure Parse;
begin FreeAndNil(Parsed);Screen.IdentifyPage;Parsed:=ParseFMCValues(Screen);end;
procedure Save(Seconds:Integer);
var J:Integer;
begin
  FreeAndNil(Sample.AircraftData);Root:=TJSONObject.Create;Sample.AircraftData:=Root;
  Root.AddPair('provider',Provider);CDU:=TJSONObject.Create;Root.AddPair('cdu',CDU);
  Obj:=TJSONObject.Create;CDU.AddPair('0',Obj);Obj.AddPair('status','available');
  Rows:=TJSONArray.Create;Obj.AddPair('rows',Rows);for J:=0 to 13 do Rows.Add(Screen.Lines[J]);
  for J:=0 to FieldCount-1 do if SimFields[J].Name='time_zulu.seconds' then Sample.Numbers[J]:=Seconds;
  DB.RecordSample(Trip,Sample);
end;
begin
  Screen:=TFMCScreen.Create;Parsed:=nil;
  try
    for K:=0 to 1 do
    begin
      if K=0 then Provider:='FenixA32X' else Provider:='FBWA32NX';Screen.Provider:=Provider;
      Blank('TAKE OFF');Field(1,0,'V1','135');Field(3,0,'VR','140');Field(5,0,'V2','145');
      Field(5,12,'FLAPS/THS','1/UP0.7');Field(7,0,'TRANS ALT','5000');Field(7,12,'FLX TO TEMP','58');
      Field(9,0,'THR RED/ACC','1500/3000');Field(9,12,'ENG OUT ACC','1800');
      Cell(13,0,'VAPP 299');Parse;
      Check(Screen.PageKey='AIRBUS_PERF_TAKEOFF','Airbus takeoff classification');
      Num('v1_kt',135);Num('vr_kt',140);Num('v2_kt',145);Num('flex_to_temperature_c',58);
      Num('takeoff_flaps',1);Num('takeoff_ths_nose_up_deg',0.7);Num('transition_altitude_ft',5000);
      Num('thrust_reduction_altitude_ft',1500);Num('acceleration_altitude_ft',3000);Num('engine_out_acceleration_altitude_ft',1800);
      Check(Parsed.GetValue('vapp_kt')=nil,'Scratchpad excluded');
      Blank('PERF TAKE OFF');Field(1,0,'V1','---');Cell(2,20,'199');Field(3,12,'FLAPS/THS','2/0.5DN');Parse;
      Null('v1_kt');Num('takeoff_ths_nose_up_deg',-0.5);
      Blank('TAKE OFF');Cell(1,0,'V1 137');Parse;Num('v1_kt',137);
      Blank('APPR');Field(1,0,'QNH','1004');Field(1,12,'FINAL','ILS25');Field(3,0,'TEMP','-5');
      Field(3,12,'BARO','420');Field(5,0,'MAG WIND','251/12');Field(5,12,'RADIO','200');
      Field(7,0,'TRANS LVL','70');Field(7,12,'VLS','130');Field(9,0,'VAPP','138');Field(9,12,'LDG CONF','FULL');Parse;
      Check(Screen.PageKey='AIRBUS_PERF_APPR','Airbus approach classification');
      Num('vapp_kt',138);Num('vls_kt',130);Num('approach_speed_additive_kt',8);
      Num('approach_qnh_hpa',1004);Null('approach_qnh_inhg');Num('approach_temperature_c',-5);
      Num('approach_wind_magnetic_deg',251);Num('approach_wind_kt',12);Num('transition_level_fl',70);
      Num('barometric_minimum_ft',420);Num('radio_minimum_ft',200);
      Check(Parsed.GetValue('landing_configuration').Value='FULL','Selected unambiguous landing configuration');
      Check(Parsed.GetValue('final_approach').Value='ILS25','Final approach identifier');
      Check(Parsed.GetValue('vref_kt')=nil,'VLS is not fabricated VREF');Check(Parsed.GetValue('wind_correction_kt')=nil,'Additive is not automatically wind correction');
      Blank('APPR');Field(1,0,'QNH','29.92');Field(3,0,'VAPP','---');Field(3,12,'VLS','130');
      Field(5,0,'MAG WIND','999/99');Field(5,12,'LDG CONF','CONF3 FULL');Parse;
      Num('approach_qnh_inhg',29.92);Null('approach_qnh_hpa');Null('vapp_kt');Null('approach_speed_additive_kt');
      Null('approach_wind_kt');Null('landing_configuration');
      Blank('INIT');Field(1,0,'FLT NBR','LOT123');Field(1,12,'FROM/TO','EPLL/EPLL');Field(3,0,'COST INDEX','25');Field(3,12,'CRZ FL/TEMP','FL350/-50');Parse;
      Check(Screen.PageKey='AIRBUS_INIT_A','INIT A classification');Num('cost_index',25);Num('cruise_flight_level',350);Num('cruise_temperature_c',-50);
      Check(Parsed.GetValue('from_to').Value='EPLL/EPLL','Airports');
      Blank('INIT');Field(1,0,'ZFW/ZFWCG','58.5/27.0');Field(1,12,'BLOCK','6.2');Parse;
      Check(Screen.PageKey='AIRBUS_INIT_B','INIT B separate cache');Check(Parsed.GetValue('block_fuel_display').Value='6.2','Unknown fuel units retained as display');
      Blank('F-PLN');Field(1,0,'V1','299');Parse;Check(Parsed.Count=0,'Unrelated page not parsed');
      Blank('TMPY TAKE OFF');Field(1,0,'V1','199');Parse;Check(Pos(':MOD',Screen.PageKey)>0,'TMPY not executed');
      Screen.PowerState:=0;Parse;Check(Parsed.Count=0,'Powered off not parsed');Screen.PowerState:=-1;Screen.Available:=False;Parse;Check(Parsed.Count=0,'Unavailable not parsed');
      Sample:=TFlightSample.Create;Path:=ExtractFilePath(ParamStr(0))+'airbus-mcdu-'+IntToStr(GetTickCount64)+'.db';
      DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');
      try
        for I:=0 to FieldCount-1 do begin
          if SimFields[I].Name='time_zulu.year' then Sample.Numbers[I]:=2026;
          if SimFields[I].Name='time_zulu.month' then Sample.Numbers[I]:=10;
          if SimFields[I].Name='time_zulu.day' then Sample.Numbers[I]:=17;
        end;
        Trip:=DB.StartTrip(Sample);Blank('TAKE OFF');Field(1,0,'V1','135');Save(0);Save(1);
        Blank('APPR');Field(1,0,'VAPP','138');Field(1,12,'VLS','130');Save(2);
        Blank('TMPY TAKE OFF');Field(1,0,'V1','199');Save(3);
        Blank('APPR');Field(1,0,'VAPP','299');Save(4);
        Check(Pos('v1_kt',string(DB.Connection.ExecSQLScalar('select parsed_json from trip_fmc_screens order by id limit 1')))>0,'Parsed Airbus fields persisted');
        DB.Connection.ExecSQL('update trip_fmc_screens set parsed_json=''{}'',page_key=''OTHER:LEGACY''');
        Context:=LatestFMCContext(DB.Connection,Trip,'2026-10-17T00:00:03.000');
        try
          Values:=(Context.GetValue('last_values_by_device') as TJSONObject).GetValue(Provider+'/0') as TJSONObject;
          Check((Values.GetValue('v1_kt') as TJSONObject).GetValue('value').Value='135','Executed V1 retained before TMPY');
          Check((Values.GetValue('vapp_kt') as TJSONObject).GetValue('value').Value='138','No future Airbus value leakage');
          Check(Pos('AIRBUS_PERF_APPR',Context.ToJSON)>0,'Airbus pages and provenance in analysis');
        finally Context.Free;end;
        DB.DeleteTrip(Trip);
      finally DB.Free;Sample.Free;DeleteFile(PChar(Path));end;
    end;
  finally Parsed.Free;Screen.Free;end;
  Writeln('PASS: Fenix/FBW MCDU TAKEOFF/APPR/INIT parsing, V-speeds, FLEX/THS/altitudes, QNH units, wind/minima, nulls, scratchpad/column isolation, TMPY, timestamped history and as-of-event analysis. Synthetic screens only.');
end.
