Program VerifySimBacklog;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Classes, SimConnectClientU, FlightTelemetryU, TelemetryCatalogU;

Type
 TProbe = Class
  Count      : Integer;
  Edges      : Integer;
  LastTime   : Double;
  LastGround : Boolean;
  Known      : Boolean;
  Procedure Sample(Sender : TObject; s : TFlightSample);
 End;

Procedure TProbe.Sample(Sender : TObject; s : TFlightSample);
 Var
  Ground : Boolean;
 Begin
  Inc(Count);
  Ground := s.N('sim_on_ground') <> 0;
  If Known And (Ground <> LastGround) Then
   Inc(Edges);
  Known      := True;
  LastGround := Ground;
  LastTime   := s.N('time_zulu.seconds');
  Sleep(5); // A slow consumer must not be invoked for every queued visual/sim frame.
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Sim     : TSimConnectClient;
 Probe   : TProbe;
 Packets : TArray<TBytes>;
 Header  : Array [0..9] Of DWORD;
 i       : Integer;
 j       : Integer;
 v       : Double;
 Started : UInt64;

Type

 [TestFixture]
 TVerifySimBacklogTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySimBacklogTests.Regression;
 Begin
  Sim   := TSimConnectClient.Create;
  Probe := TProbe.Create;
  Try
   Sim.OnSample := Probe.Sample;
   SetLength(Packets, 1000);
   FillChar(Header, SizeOf(Header), 0);
   Header[0] := 40 + PayloadSize;
   Header[2] := 8;
   Header[3] := 1;
   Header[5] := 1;
   Header[9] := FieldCount;
   For i     := 0 To High(Packets) Do
    Begin
     SetLength(Packets[i], 40 + PayloadSize);
     Move(Header, Packets[i][0], 40);
     For j := 0 To FieldCount - 1 Do
      Begin
       If SimFields[j].Name = 'time_zulu.seconds' Then
        Begin
         v := i;
         Move(v, Packets[i][40 + SimFields[j].Offset], 8);
        End;
       If SimFields[j].Name = 'sim_on_ground' Then
        Begin
         v := Ord((i < 300) Or ((i >= 500) And (i < 900)));
         Move(v, Packets[i][40 + SimFields[j].Offset], 8);
        End;
      End;
    End;
   Started := GetTickCount64;
   Sim.FeedBatch(Packets);
   Check(Probe.Count = 5, 'Only baseline, three ground transitions and latest telemetry delivered');
   Check(Probe.Edges = 3, 'Liftoff/touchdown/bounce transitions must survive coalescing');
   Check(Probe.LastTime = 999, 'Newest telemetry replaces old frame backlog');
   Check(GetTickCount64 - Started < 3000, 'Slow consumer executed for historical frames');
   Sim.Feed(@Packets[999][0], Length(Packets[999]));
   Check(Probe.Count = 6, 'Direct test Feed remains synchronous');
  Finally
   Probe.Free;
   Sim.Free;
  End;
  System.Writeln('PASS: 1000 queued telemetry packets become five callbacks, latest timestamp retained and all three ground transitions preserved; slow consumer does not replay every historical frame. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifySimBacklogTests);
End.
