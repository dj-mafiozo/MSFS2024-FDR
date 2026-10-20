program VerifyIFlyDisplays;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.JSON,System.Math,FlightDatabaseU,FlightTelemetryU,
  TelemetryCatalogU,IFlyDisplaysU,FMCScreensU,FMCPreflightU;
const Lamps:array[0..4]of string=('FAIL','MSG','EXEC','CALL','OFST');
var Fields,Root,J,Style:TJSONObject;S:TFlightSample;DB:TFlightDatabase;Plot:TTripPlot;Cache:TFMCPreflightCache;
    Path,Key,Payload,Text:string;Trip,Other,I,D,R,C,Idx:Integer;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure N(const K:string;V:Integer);
begin Fields.RemovePair(K).Free;Fields.AddPair(K,TJSONNumber.Create(V));end;
procedure Digits(const Prefix:string;const Values:array of Integer);
const Places:array[0..4]of string=('10000','1000','100','10','1');
var K:Integer;
begin for K:=0 to High(Values) do N(Prefix+'_'+Places[K+5-Length(Values)]+'_Status',Values[K]);end;
procedure SetN(const Name:string;V:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then S.Numbers[K]:=V;end;
function Number(const K:string):Double;
begin Result:=(Fields.GetValue(K) as TJSONNumber).AsDouble;end;
begin
  Fields:=TJSONObject.Create;Root:=TJSONObject.Create;S:=TFlightSample.Create;DB:=nil;
  Cache:=TFMCPreflightCache.Create;Root.AddPair('provider','iFly737MAX');Root.AddPair('fields',Fields);
  S.AircraftData:=Root;
  Path:=ExtractFilePath(ParamStr(0))+'ifly-displays-'+IntToStr(GetTickCount64)+'.db';
  try
    Digits('Flight_Altitude_Indicator',[3,5,0,0,0]);Digits('Landing_Altitude_Indicator',[10,0,5,0,0]);
    Digits('HDG',[1,2,3]);Digits('VS',[1,5,0,0]);N('VS_Symbol_Status',11);
    Digits('SPD',[7,8,0]);N('SPD_Point_Status',1);
    for I:=0 to 4 do N(Format('Fuel_Quantity_Indicator_Status[0][%d]',[I]),StrToInt(Copy('03875',I+1,1)));
    for I:=0 to 4 do begin
      case I of 0:Key:='1000';1:Key:='100';2:Key:='10';3:Key:='1';else Key:='01';end;
      N('ADF_num_'+Key+'_Status[1]',StrToInt(Copy('08900',I+1,1)));
    end;
    for I:=1 to 4 do N(Format('ADF_num_point%d_Status[1]',[I]),Ord(I=4));
    for I:=1 to 6 do N(Format('IRS_Window_L_%d_Status',[I]),StrToInt(Copy('051436',I,1)));
    N('IRS_Window_L_1_Status',12);for I:=1 to 3 do N(Format('IRS_Window_L_point_%d_Status',[I]),1);
    AssembleIFlyDisplays(Fields);
    Check(Number('Flight_Altitude_Indicator_Value')=35000,'Flight altitude assembly');
    Check(Number('Landing_Altitude_Indicator_Value')=-500,'Signed landing altitude');
    Check(Number('HDG_Value')=123,'Heading assembly');Check(Number('VS_Value')=-1500,'Signed vertical speed');
    Check(Number('Fuel_Quantity_Indicator_Value[0]')=3875,'Fuel display index order');
    Check(Number('ADF_num_Value[1]')=890,'ADF decimal point');
    Check(Fields.GetValue('IRS_Window_L_Value').Value='N51436','IRS direction letter retained');
    Check(Number('IRS_Window_L_Points')=7,'IRS point mask preserved without coordinate guessing');
    Check(Fields.GetValue('SPD_Value') is TJSONNull,'Undefined Mach decimal is not guessed');
    Digits('Landing_Altitude_Indicator',[11,11,11,11,11]);AssembleIFlyDisplays(Fields);
    Check(Fields.GetValue('Landing_Altitude_Indicator_Value') is TJSONNull,'Blank display is not zero');
    Check(not IFlyCompactField('Window_Heat_Switch_1_Status'),'Switch names are not mistaken for display digits');
    for D:=0 to 1 do begin
      for R:=0 to 13 do begin
        Text:=StringOfChar(' ',24);if R=0 then Text:='PERF INIT'+StringOfChar(' ',15);
        if R=1 then Text:='<X&>'+StringOfChar(' ',20);
        Fields.AddPair(Format('LSKChar[%d][%d]',[D,R]),Text);
        for C:=0 to 23 do begin N(Format('LSK_Color[%d][%d][%d]',[D,R,C]),0);N(Format('LSK_SmallFont[%d][%d][%d]',[D,R,C]),0);end;
      end;
      for Key in Lamps do N(Format('CDU_%s_Status[%d]',[Key,D]),0);
    end;
    N('FLAP_Status',5);DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');
    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',18);
    Trip:=DB.StartTrip(S);DB.RecordSample(Trip,S);
    Payload:=DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data where trip=:t',[Trip]);
    Check(Pos('Flight_Altitude_Indicator_Value',Payload)>0,'Assembled value stored');
    Check((Pos('LSKChar[',Payload)=0) and (Pos('LSK_Color[',Payload)=0) and (Pos('CDU_EXEC_Status[',Payload)=0),'No duplicated FMC fields in general history');
    Check(Pos('Flight_Altitude_Indicator_10000_Status',Payload)=0,'No individual display digits in general history');
    Check(Fields.GetValue('LSKChar[0][0]')<>nil,'In-memory SDK remains available to FMC extraction');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t',[Trip])=2,'Two independent CDU records');
    N('LSK_SmallFont[0][1][0]',1);SetN('time_zulu.seconds',1);DB.RecordSample(Trip,S);
    N('LSK_Color[0][1][1]',3);SetN('time_zulu.seconds',2);DB.RecordSample(Trip,S);
    N('CDU_EXEC_Status[0]',2);SetN('time_zulu.seconds',3);DB.RecordSample(Trip,S);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t',[Trip])=5,'Font-only, color-only and lamp-only changes saved');
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t',[Trip])=1,'Font/lamps do not duplicate general telemetry');
    Text:=DB.Connection.ExecSQLScalar('select formatted_html from trip_fmc_screens where trip=:t and device=''0'' order by id desc limit 1',[Trip]);
    Check((Pos('&lt;',Text)>0) and (Pos('&amp;',Text)>0) and (Pos('font-size:75%',Text)>0) and (Pos('color:#ff00ff',Text)>0),'Escaped formatted HTML and small font');
    Text:=DB.Connection.ExecSQLScalar('select annunciators_json from trip_fmc_screens where trip=:t and device=''0'' order by id desc limit 1',[Trip]);
    J:=TJSONObject.ParseJSONValue(Text) as TJSONObject;try Check(J.GetValue('EXEC').Value='2','CDU EXEC brightness preserved');finally J.Free;end;
    Text:=DB.Connection.ExecSQLScalar('select style_json from trip_fmc_screens where trip=:t and device=''0'' order by id desc limit 1',[Trip]);
    Style:=TJSONObject.ParseJSONValue(Text) as TJSONObject;
    try Check(Length((Style.GetValue('rows') as TJSONArray).Items[1].Value)=48,'24 packed color/font cells');finally Style.Free;end;
    N('Flight_Altitude_Indicator_1000_Status',6);SetN('time_zulu.seconds',4);DB.RecordSample(Trip,S);
    Plot:=DB.LoadTrip(Trip);
    try
      Idx:=Plot.Labels.IndexOf('iFlySDK.Flight_Altitude_Indicator_Value');Check(Idx>=0,'Assembled chart parameter');
      Check(Plot.Points[0].Values[Idx]=35000,'Chart baseline');Check(Plot.Points[4].Values[Idx]=36000,'Chart delta');
      Check(Plot.Labels.IndexOf('iFlySDK.LSK_Color[0][0][0]')<0,'No segment/color noise in new chart list');
    finally Plot.Free;end;
    Cache.Observe(Root,S.Time('time_zulu'));Other:=DB.StartTrip(S);Cache.Flush(DB.Connection,Other);
    Text:=DB.Connection.ExecSQLScalar('select annunciators_json from trip_fmc_screens where trip=:t and device=''0''',[Other]);
    Check(Pos('"EXEC":2',Text)>0,'Preflight cache retains CDU lamps');
    Text:=DB.Connection.ExecSQLScalar('select style_json from trip_fmc_screens where trip=:t and device=''0''',[Other]);
    Check(Pos('color-font-nibbles-v1',Text)>0,'Preflight cache retains packed styles');
    DB.DeleteTrip(Trip);DB.DeleteTrip(Other);
  finally Cache.Free;DB.Free;S.Free;DeleteFile(PChar(Path));end;
  Writeln('PASS: assembled iFly displays, blank/sign/decimal/IRS states, compact SDK history and charts, separate FMC text/styles/HTML/CDU lamps, appearance-only changes and preflight retention. Synthetic only.');
end.
