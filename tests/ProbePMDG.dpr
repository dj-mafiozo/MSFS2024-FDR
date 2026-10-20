program ProbePMDG;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.JSON,SimConnectClientU,AircraftTelemetryU,PMDGNG3CatalogU;
var Sim:TSimConnectClient;Provider:TPMDGNG3Provider;Started:UInt64;Title,Status:string;V:TJSONValue;C:TJSONObject;I:Integer;
begin
 Sim:=TSimConnectClient.Create;Provider:=TPMDGNG3Provider.Create;
 try
  Sim.Connect(ExtractFilePath(ParamStr(0))+'SimConnect.dll');Started:=GetTickCount64;Status:='';
  while GetTickCount64-Started<10000 do begin
   Sim.Poll;Title:=Sim.Sample.S('title');
   if Title<>'' then begin
    if not Provider.Matches(Title) then begin Writeln('Current aircraft: '+Title);Writeln('SKIP: current aircraft is not PMDG 737 NG; no PMDG SDK read attempted.');Break;end;
    Provider.Tick(500);Provider.Capture(Sim.Sample);Status:=Sim.Sample.AircraftData.GetValue('status').Value;
    if Status='available' then begin
     Writeln('Current aircraft: '+Title);Writeln('SDK status: '+Status+'; fields='+Sim.Sample.AircraftData.GetValue('received_field_count').Value);
     V:=Sim.Sample.AircraftData.GetValue('performance_reference');Writeln('FMC references: '+V.ToJSON);
     C:=Sim.Sample.AircraftData.GetValue('cdu') as TJSONObject;
     for I:=0 to 1 do begin V:=C.GetValue(IntToStr(I));Writeln('CDU '+IntToStr(I)+': '+(V as TJSONObject).GetValue('status').Value);end;
     Writeln('PASS: live read-only PMDG NG3 Client Data received. No recording, controls or simulator variables written.');Break;
    end;
   end;
   Sleep(20);
  end;
  if (Title='') or ((Title<>'') and Provider.Matches(Title) and (Status<>'available')) then Writeln('UNAVAILABLE: no valid PMDG SDK block within 10 seconds; verify aircraft and SDK broadcast settings.');
 except on E:Exception do begin Writeln('UNAVAILABLE: '+E.Message);ExitCode:=1;end;end;
 Provider.Free;Sim.Free;
end.
