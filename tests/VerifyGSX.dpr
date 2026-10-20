program VerifyGSX;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Math,System.JSON,GSXVarsU,
  FlightTelemetryU,TelemetryCatalogU,FlightDatabaseU,AnalysisContextU,FireDAC.Comp.Client;
type TReset=procedure(Mode:Integer);stdcall;TCount=function(Kind:Integer):Integer;stdcall;
var DLL:HMODULE;Reset:TReset;Counter:TCount;R:TGSXVars;J,Fields,Context:TJSONObject;
  DB:TFlightDatabase;S:TFlightSample;Plot:TTripPlot;Q:TFDQuery;Path,Mock:string;Mode,I,Trip,EventID,Index:Integer;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=Value;Exit;end;end;
begin
  Mock:=ExtractFilePath(ParamStr(0))+'MockFenixSim.dll';DLL:=LoadLibrary(PChar(Mock));Check(DLL<>0,'Load transport');
  @Reset:=GetProcAddress(DLL,'FenixMockReset');@Counter:=GetProcAddress(DLL,'FenixMockCount');
  R:=TGSXVars.Create(Mock);
  try
    Reset(0);R.Tick;J:=R.Snapshot;
    try
      Fields:=J.GetValue('fields') as TJSONObject;
      Check(Fields.Count=GSXVarCount,'GSX Pro catalog');Check(Fields.GetValue('FSDT_GSX_BOARDING_STATE').Value='5','V1');

      Check((Counter(0)=GSXVarCount) and (Counter(1)=GSXVarCount) and (Counter(5)=0),'Isolated read definitions');Check(Counter(4)=0,'No writes');
    finally J.Free;end;
    for Mode:=1 to 7 do begin
      R.Close;Reset(Mode);R.Tick;J:=R.Snapshot;
      try
        Fields:=J.GetValue('fields') as TJSONObject;
        if Mode=1 then begin Check(Fields.GetValue(GSXNames[GSXVarCount-1]) is TJSONNull,'Missing optional field');Check(Fields.GetValue('FSDT_GSX_DEBOARDING_STATE').Value='5','Other fields retained');end;
        if Mode in [2,3,4] then begin Check(Fields.GetValue('FSDT_GSX_BOARDING_STATE') is TJSONNull,'Invalid field isolated');Check(Fields.GetValue('FSDT_GSX_DEBOARDING_STATE').Value='5','Unrelated field survives');end;
        if Mode in [5,6] then Check(J.GetValue('status').Value='unavailable','Quit/missing replies unavailable');
        if Mode=7 then begin Check(Fields.GetValue('FSDT_GSX_BOARDING_STATE').Value='0','Raw zero retained');Check(J.GetValue('status').Value='received_not_verified','Zero does not prove GSX active');end;
      finally J.Free;end;
    end;
    R.Close;Reset(0);R.Tick;
    S:=TFlightSample.Create;Path:=ExtractFilePath(ParamStr(0))+'gsx-'+IntToStr(GetTickCount64)+'.db';
    DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');Q:=TFDQuery.Create(nil);
    try
      SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
      S.GSXData:=R.Snapshot;Trip:=DB.StartTrip(S);DB.RecordSample(Trip,S);SetN('time_zulu.seconds',1);DB.RecordSample(Trip,S);
      Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=1,'Unchanged common data omitted');
      Fields:=S.GSXData.GetValue('fields') as TJSONObject;Fields.RemovePair('FSDT_GSX_BOARDING_STATE').Free;Fields.AddPair('FSDT_GSX_BOARDING_STATE',TJSONNumber.Create(6));
      SetN('time_zulu.seconds',2);DB.RecordSample(Trip,S);EventID:=DB.Contact(Trip,S,False);
      R.Close;FreeAndNil(S.GSXData);S.GSXData:=R.Snapshot;SetN('time_zulu.seconds',3);DB.RecordSample(Trip,S);
      Plot:=DB.LoadTrip(Trip);
      try Index:=Plot.Labels.IndexOf('GSX.FSDT_GSX_BOARDING_STATE');Check(Index>=0,'GSX chart parameter');
        Check((Plot.Points[0].Values[Index]=5) and (Plot.Points[1].Values[Index]=5) and (Plot.Points[2].Values[Index]=6),'GSX chart replay');
        Check(IsNan(Plot.Points[3].Values[Index]),'Unavailable chart gap');
      finally Plot.Free;end;
      Q.Connection:=DB.Connection;Q.Open('select * from trip_liftoffs where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,3,2);
      try Check(Context.GetValue('gsx_lvar_definitions')<>nil,'Definitions in AI');Check(Pos('gsx_lvars',Context.ToJSON)>0,'GSX data in AI');finally Context.Free;end;
      DB.DeleteTrip(Trip);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=0,'GSX history deletion');
    finally Q.Free;DB.Free;S.Free;DeleteFile(PChar(Path));end;
  finally R.Free;FreeLibrary(DLL);end;
  Writeln('PASS: GSX Pro read-only SimConnect L-vars, per-field isolation, zeros/null/errors, optional delta storage, chart replay/gaps, AI definitions and cleanup. Mock only.');
end.
