program VerifyPrecision;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.JSON,AnalysisPrecisionU,AnalysisContextU,
  FlightDatabaseU,FlightTelemetryU,TelemetryCatalogU,FireDAC.Comp.Client;
var Original,Rounded:TJSONValue;DB:TFlightDatabase;Sample:TFlightSample;Q:TFDQuery;
  Context:TJSONObject;Samples:TJSONArray;Row:TJSONObject;Trip,EventID,I:Integer;Path:string;
const G:array[0..6]of Double=(1.00049,1.00051,1.0014,1.0021,1.00149,1.00151,1.0044);
procedure Check(B:Boolean;const M:string);
begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;N:Double);
var K:Integer;
begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin Sample.Numbers[K]:=N;Exit;end;end;
procedure CheckPrecision(V:TJSONValue);
var P:TJSONPair;E:TJSONValue;S:string;Dot:Integer;
begin
  if V is TJSONObject then for P in TJSONObject(V) do CheckPrecision(P.JsonValue)
  else if V is TJSONArray then for E in TJSONArray(V) do CheckPrecision(E)
  else if V is TJSONNumber then begin S:=V.Value;Dot:=Pos('.',S);
    Check((Dot=0) or (Length(S)-Dot<=3),'At most three decimal places: '+S);end;
end;
begin
  Original:=TJSONObject.ParseJSONValue('{"n":-12.3456789,"nested":[0.00000001,{"x":1.23456}],"id":9007199254740993,"flag":false,"null":null,"text":"1.23456789"}');
  Rounded:=RoundAnalysisJSON(Original);
  try
    CheckPrecision(Rounded);Check(Pos('-12.346',Rounded.ToJSON)>0,'Negative rounding');
    Check(Pos('9007199254740993',Rounded.ToJSON)>0,'Integer identity preserved');
    Check(Pos('1.23456789',Rounded.ToJSON)>0,'Strings untouched');
    Check(Pos('-12.3456789',Original.ToJSON)>0,'Source unchanged');
  finally Rounded.Free;Original.Free;end;
  Path:=ExtractFilePath(ParamStr(0))+'precision-'+IntToStr(GetTickCount64)+'.db';
  DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');Sample:=TFlightSample.Create;Q:=TFDQuery.Create(nil);
  try
    SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);Trip:=DB.StartTrip(Sample);
    for I:=0 to High(G) do begin SetN('time_zulu.seconds',I);SetN('g_force',G[I]);
      SetN('autopilot_master',Ord(I<3));DB.RecordSample(Trip,Sample);end;
    EventID:=DB.Contact(Trip,Sample,True);Q.Connection:=DB.Connection;Q.Open('select * from trip_touchdowns where id=:i',[EventID]);
    Context:=BuildContactContext(DB,Q,10,1);
    try
      CheckPrecision(Context);Samples:=Context.GetValue('samples') as TJSONArray;
      Check(Samples.Count=7,'All timestamps retained');
      Check((TJSONObject(Samples.Items[0]).GetValue('g_force') as TJSONNumber).AsDouble=1,'Rounded baseline');
      Check(TJSONObject(Samples.Items[1]).GetValue('g_force')=nil,'Rounding boundary noise suppressed');
      Check(TJSONObject(Samples.Items[2]).GetValue('g_force')=nil,'Subthreshold drift suppressed');
      Check(Abs((TJSONObject(Samples.Items[3]).GetValue('g_force') as TJSONNumber).AsDouble-1.002)<0.00001,'Cumulative drift emitted');
      Check(TJSONObject(Samples.Items[4]).GetValue('g_force')=nil,'Reverse jitter suppressed');
      Check(TJSONObject(Samples.Items[5]).GetValue('g_force')=nil,'Boundary jitter suppressed');
      Check(Abs((TJSONObject(Samples.Items[6]).GetValue('g_force') as TJSONNumber).AsDouble-1.004)<0.00001,'Later cumulative drift retained');
      Row:=TJSONObject(Samples.Items[3]);Check(Row.GetValue('autopilot_master').Value='false','Boolean transition preserved');
      for I:=0 to Samples.Count-1 do begin Row:=TJSONObject(Samples.Items[I]);Check((Row.GetValue('utc')<>nil) and (Row.GetValue('t_seconds')<>nil),'Time coordinates never filtered');end;
      Check(Abs(Double(DB.Connection.ExecSQLScalar('select g_force from trip_data where trip=:t order by id limit 1',[Trip]))-G[0])<1E-10,'Raw database precision unchanged');
    finally Context.Free;end;
    DB.DeleteTrip(Trip);
  finally Q.Free;Sample.Free;DB.Free;DeleteFile(PChar(Path));end;
  Writeln('PASS: recursive three-decimal analysis JSON, exact integer IDs, untouched strings/raw DB, hysteresis against emitted state, cumulative drift, jitter suppression and AP/timestamps.');
end.
