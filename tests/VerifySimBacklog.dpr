program VerifySimBacklog;
{$APPTYPE CONSOLE}
uses Winapi.Windows, System.SysUtils, System.Classes, SimConnectClientU, FlightTelemetryU, TelemetryCatalogU;
type TProbe=class
  Count,Edges:Integer;LastTime:Double;LastGround,Known:Boolean;
  procedure Sample(Sender:TObject;S:TFlightSample);
end;
procedure TProbe.Sample(Sender:TObject;S:TFlightSample);
var Ground:Boolean;
begin
  Inc(Count);Ground:=S.N('sim_on_ground')<>0;
  if Known and (Ground<>LastGround) then Inc(Edges);
  Known:=True;LastGround:=Ground;LastTime:=S.N('time_zulu.seconds');
  Sleep(5); // A slow consumer must not be invoked for every queued visual/sim frame.
end;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
var Sim:TSimConnectClient;Probe:TProbe;Packets:TArray<TBytes>;Header:array[0..9]of DWORD;
    I,J:Integer;V:Double;Started:UInt64;
begin
  Sim:=TSimConnectClient.Create;Probe:=TProbe.Create;
  try
    Sim.OnSample:=Probe.Sample;SetLength(Packets,1000);
    FillChar(Header,SizeOf(Header),0);Header[0]:=40+PayloadSize;Header[2]:=8;
    Header[3]:=1;Header[5]:=1;Header[9]:=FieldCount;
    for I:=0 to High(Packets) do begin
      SetLength(Packets[I],40+PayloadSize);Move(Header,Packets[I][0],40);
      for J:=0 to FieldCount-1 do begin
        if SimFields[J].Name='time_zulu.seconds' then begin V:=I;Move(V,Packets[I][40+SimFields[J].Offset],8);end;
        if SimFields[J].Name='sim_on_ground' then begin
          V:=Ord((I<300) or ((I>=500) and (I<900)));Move(V,Packets[I][40+SimFields[J].Offset],8);
        end;
      end;
    end;
    Started:=GetTickCount64;Sim.FeedBatch(Packets);
    Check(Probe.Count=5,'Only baseline, three ground transitions and latest telemetry delivered');
    Check(Probe.Edges=3,'Liftoff/touchdown/bounce transitions must survive coalescing');
    Check(Probe.LastTime=999,'Newest telemetry replaces old frame backlog');
    Check(GetTickCount64-Started<3000,'Slow consumer executed for historical frames');
    Sim.Feed(@Packets[999][0],Length(Packets[999]));
    Check(Probe.Count=6,'Direct test Feed remains synchronous');
  finally Probe.Free;Sim.Free;end;
  Writeln('PASS: 1000 queued telemetry packets become five callbacks, latest timestamp retained and all three ground transitions preserved; slow consumer does not replay every historical frame. Synthetic only.');
end.
