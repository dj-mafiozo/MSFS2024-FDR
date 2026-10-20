program VerifyAirliner;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Math,System.JSON,AirlinerVarsU, AirlinerCatalogU,
  FlightTelemetryU,TelemetryCatalogU,FlightDatabaseU,AnalysisContextU,FireDAC.Comp.Client;
type TReset=procedure(Mode:Integer);stdcall;TCount=function(Kind:Integer):Integer;stdcall;
var DLL:HMODULE;Reset:TReset;Counter:TCount;R:TAirlinerVars;J,Fields,Context:TJSONObject;
  DB:TFlightDatabase;S:TFlightSample;Plot:TTripPlot;Q:TFDQuery;Path,Mock:string;Mode,I,Trip,EventID,Index:Integer;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure SetN(const Name:string;Value:Double);
var K:Integer;begin for K:=0 to FieldCount-1 do if SimFields[K].Name=Name then begin S.Numbers[K]:=Value;Exit;end;end;
begin
  Mock:=ExtractFilePath(ParamStr(0))+'MockFenixSim.dll';DLL:=LoadLibrary(PChar(Mock));Check(DLL<>0,'Load transport');
  @Reset:=GetProcAddress(DLL,'FenixMockReset');@Counter:=GetProcAddress(DLL,'FenixMockCount');
  R:=TAirlinerVars.Create(Mock);
  try
    Reset(0);R.Tick;J:=R.Snapshot;
    try
      Fields:=J.GetValue('fields') as TJSONObject;
      Check(Fields.Count=AirlinerVarCount,'Common AIRLINER catalog');Check(Fields.GetValue('AIRLINER_V1_SPEED').Value='135','V1');
      Check((J.GetValue('performance_reference') as TJSONObject).GetValue('vr_kt').Value='140','VR reference');
      Check((Counter(0)=AirlinerVarCount) and (Counter(1)=AirlinerVarCount) and (Counter(5)=0),'Isolated read definitions');Check(Counter(4)=0,'No writes');
    finally J.Free;end;
    for Mode:=1 to 7 do begin
      R.Close;Reset(Mode);R.Tick;J:=R.Snapshot;
      try
        Fields:=J.GetValue('fields') as TJSONObject;
        if Mode=1 then begin Check(Fields.GetValue(AirlinerNames[AirlinerVarCount-1]) is TJSONNull,'Missing optional field');Check(Fields.GetValue('AIRLINER_VR_SPEED').Value='140','Other fields retained');end;
        if Mode in [2,3,4] then begin Check(Fields.GetValue('AIRLINER_V1_SPEED') is TJSONNull,'Invalid field isolated');Check(Fields.GetValue('AIRLINER_VR_SPEED').Value='140','Unrelated field survives');end;
        if Mode in [5,6] then Check(J.GetValue('status').Value='unavailable','Quit/missing replies unavailable');
        if Mode=7 then begin Check(Fields.GetValue('AIRLINER_V1_SPEED').Value='0','Raw zero retained');Check((J.GetValue('performance_reference') as TJSONObject).Count=0,'Zero is not valid speed reference');end;
      finally J.Free;end;
    end;
    R.Close;Reset(0);R.Tick;
    S:=TFlightSample.Create;Path:=ExtractFilePath(ParamStr(0))+'airliner-'+IntToStr(GetTickCount64)+'.db';
    DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');Q:=TFDQuery.Create(nil);
    try
      SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
      S.AirlinerData:=R.Snapshot;Trip:=DB.StartTrip(S);DB.RecordSample(Trip,S);SetN('time_zulu.seconds',1);DB.RecordSample(Trip,S);
      Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=1,'Unchanged common data omitted');
      Fields:=S.AirlinerData.GetValue('fields') as TJSONObject;Fields.RemovePair('AIRLINER_V1_SPEED').Free;Fields.AddPair('AIRLINER_V1_SPEED',TJSONNumber.Create(136));
      SetN('time_zulu.seconds',2);DB.RecordSample(Trip,S);EventID:=DB.Contact(Trip,S,False);
      R.Close;FreeAndNil(S.AirlinerData);S.AirlinerData:=R.Snapshot;SetN('time_zulu.seconds',3);DB.RecordSample(Trip,S);
      Plot:=DB.LoadTrip(Trip);
      try Index:=Plot.Labels.IndexOf('AirlinerLVar.AIRLINER_V1_SPEED');Check(Index>=0,'Common chart parameter');
        Check((Plot.Points[0].Values[Index]=135) and (Plot.Points[1].Values[Index]=135) and (Plot.Points[2].Values[Index]=136),'Common chart replay');
        Check(IsNan(Plot.Points[3].Values[Index]),'Unavailable chart gap');
      finally Plot.Free;end;
      Q.Connection:=DB.Connection;Q.Open('select * from trip_liftoffs where id=:i',[EventID]);Context:=BuildContactContext(DB,Q,3,2);
      try Check(Context.GetValue('airliner_lvar_definitions')<>nil,'Definitions in AI');Check(Pos('airliner_lvars',Context.ToJSON)>0,'Common data in AI');finally Context.Free;end;
      DB.DeleteTrip(Trip);Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data')=0,'Common history deletion');
    finally Q.Free;DB.Free;S.Free;DeleteFile(PChar(Path));end;
  finally R.Free;FreeLibrary(DLL);end;
  Writeln('PASS: common AIRLINER read-only SimConnect L-vars, per-field isolation, zeros/null/errors, optional delta storage, chart replay/gaps, AI definitions and cleanup. Mock only.');
end.
