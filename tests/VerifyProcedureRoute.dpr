Program VerifyProcedureRoute;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, System.Classes, System.Math,
 FlightPlanU, ProcedureRouteU, SimConnectClientU, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Sim           : TSimConnectClient;
 Reader        : TProcedureReader;
 Plan          : TFlightPlan;
 CopyPlan      : TFlightPlan;
 SavedSnapshot : String;
 GeometryCount : Integer;
 Req           : Cardinal;
 OldReq        : Cardinal;
 PP            : TPlanPoint;
 l             : TProcedureLeg;
 i             : Integer;
 ID            : Integer;
 DB            : TFlightDatabase;
 Sample        : TFlightSample;
 Plot          : TTripPlot;

Procedure Packet(Kind, u, Parent, Index, Count : Cardinal; Const Data : TBytes);
 Var
  b : TBytes;
  n : Cardinal;
 Begin
  SetLength(b, 40 + Length(Data));
  n := Length(b);
  Move(n, b[0], 4);
  n := 28;
  Move(n, b[8], 4);
  Move(Req, b[12], 4);
  Move(u, b[16], 4);
  Move(Parent, b[20], 4);
  Move(Kind, b[24], 4);
  Move(Index, b[32], 4);
  Move(Count, b[36], 4);
  If Length(Data) > 0 Then
   Move(Data[0], b[40], Length(Data));
  Reader.Feed(@b[0], Length(b));
 End;

Function TextData(Const s : AnsiString) : TBytes;
 Begin
  SetLength(Result, 8);
  If Length(s) > 0 Then
   Move(s[1], Result[0], Min(8, Length(s)));
 End;

Function Ints(a, b, c, d : Integer; Size : Integer = 16) : TBytes;
 Begin
  SetLength(Result, Size);
  Move(a, Result[0], 4);
  If Size >= 8 Then
   Move(b, Result[4], 4);
  If Size >= 12 Then
   Move(c, Result[8], 4);
  If Size >= 16 Then
   Move(d, Result[12], 4);
 End;

Procedure Leg(u, Parent, k, Index, Count : Cardinal; Const Fix : AnsiString; Lat, Lon : Double; LegKind : Integer = 18);
 Var
  b : TBytes;
 Begin
  l      := Default(TProcedureLeg);
  l.Kind := LegKind;
  Move(Fix[1], l.Fix[0], Min(8, Length(Fix)));
  l.FixType  := 87;
  l.Lat      := Lat;
  l.Lon      := Lon;
  l.AltDesc  := 2;
  l.Alt1     := 1524;
  l.Speed    := 210;
  l.Course   := 90;
  l.Turn     := 2;
  l.Distance := 4000;
  If LegKind = 17 Then
   Begin
    l.ArcLat := 52.35;
    l.ArcLon := 20.35;
   End;
  SetLength(b, SizeOf(l));
  Move(l, b[0], Length(b));
  Packet(k, u, Parent, Index, Count, b);
 End;

Procedure Finish;
 Var
  b : Array[0..15] Of Byte;
  n : Cardinal;
 Begin
  FillChar(b, SizeOf(b), 0);
  n := 29;
  Move(n, b[8], 4);
  Move(Req, b[12], 4);
  Reader.Feed(@b[0], SizeOf(b));
 End;

Type

 [TestFixture]
 TVerifyProcedureRouteTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyProcedureRouteTests.Regression;
 Begin
  Try
   Sim    := TSimConnectClient.Create;
   Reader := TProcedureReader.Create(Sim);
   Plan   := TFlightPlan.Create;
   DB     := TFlightDatabase.Create(TestDatabasePath('procedure-route.mfzr'), TestRuntimeFile('sqlite3.dll'));
   Sample := TFlightSample.Create;
   Try
    Plan.Source := 'SimConnect PLN';
    Plan.Format := 'PLN';
    Plan.Raw    := '<SimBase.Document><FlightPlan.FlightPlan><DepartureID>EPAA</DepartureID><DestinationID>EPBB</DestinationID>' +
    '<DepartureDetails><DepartureFP>SID1</DepartureFP><RunwayNumberFP>30</RunwayNumberFP><RunwayDesignatorFP>L</RunwayDesignatorFP></DepartureDetails>' +
    '<ArrivalDetails><ArrivalFP>STAR1</ArrivalFP></ArrivalDetails>' +
    '<ApproachDetails><ApproachTypeFP>ILS</ApproachTypeFP><SuffixFP>Z</SuffixFP><RunwayNumberFP>25</RunwayNumberFP><TransitionFP>IAF1</TransitionFP></ApproachDetails>' +
    '</FlightPlan.FlightPlan></SimBase.Document>';
    CopyPlan := ParsePLN(Plan.Raw, '');
    Plan.Free;
    Plan := CopyPlan;
    Check((Plan.SID = 'SID1') And (Plan.ApproachRunway = '25'), 'Selected plan metadata');
    Sim.Connect(TestDataDirectory + 'MockLifecycleSim.dll');
    Sim.Connected     := True;
    Sim.Running       := True;
    Sim.FlightEnded   := False;
    Sim.FlightLoading := False;
    Check(Sim.FunctionAddress('SimConnect_RequestFacilityData') <> Nil, 'Fresh mock DLL has Facilities export');
    Reader.SetPlan(Plan);
    Reader.Tick;
    Req    := Reader.RequestID;
    OldReq := Req;
    Check(Req > 100000, 'Facility request issued');
    // Deliberately out of order: child before procedure and airport.
    Leg(31, 20, 7, 1, 2, 'SIDEND', 52.1, 20.1);
    Leg(30, 20, 7, 0, 2, 'SIDSTART', 52, 20, 15);
    Packet(12, 20, 10, 0, 2, Ints(30, 1, 0, 0, 8));
    Packet(12, 21, 10, 1, 2, Ints(12, 2, 0, 0, 8));
    Leg(32, 21, 7, 0, 1, 'WRONG', 51, 19);
    Packet(10, 10, 1, 0, 1, TextData('SID1'));
    Packet(0, 1, 0, 0, 0, Ints(0, 0, 0, 0, 4));
    Finish;
    Check(Plan.ProcedureData = '', 'No publication after departure only');
    Reader.Tick;
    Req := Reader.RequestID;
    Check(Req <> OldReq, 'Arrival request isolated');
    Packet(0, 1, 0, 0, 0, Ints(0, 0, 0, 0, 4));
    Packet(11, 10, 1, 0, 1, TextData('STAR1'));
    Leg(11, 10, 7, 0, 1, 'STAREND', 52.2, 20.2);
    Packet(5, 40, 1, 0, 1, Ints(4, Ord('Z'), 25, 0));
    Packet(6, 41, 40, 0, 1, TextData('IAF1'));
    Leg(42, 41, 7, 0, 1, 'IAF1', 52.3, 20.3, 15);
    Leg(43, 40, 8, 0, 1, 'RW25', 52.4, 20.4, 17);
    Leg(44, 40, 9, 0, 1, 'MISSED', 52.5, 20.5, 13);
    Finish;
    GeometryCount := Plan.Points.Count;
    Check(GeometryCount > 6, 'RF represented by curved geometry');
    ID := 0;
    For PP In Plan.Points Do
     If PP.Ident <> '' Then
      Begin
       Inc(ID);
       Check(PP.Ident <> 'WRONG', 'Unselected runway transition excluded');
      End;
    Check(ID = 6, 'Only selected procedure fixes');
    ExpandProcedureRoute(Plan);
    Check(Plan.Points.Count = GeometryCount, 'Repeated expansion is idempotent, including empty original route');
    Check((Plan.Points[0].Ident = 'SIDSTART') And (Plan.Points[1].Ident = 'SIDEND'), 'ItemIndex ordering, not arrival ordering');
    Check(Plan.Points.Last.MissedApproach And (Plan.Points.Last.LegType = 'HF'), 'Missed approach and holding metadata');
    Check(Plan.Points[0].ConstraintText = '210KT 5000A', 'Meters converted to feet with constraint semantics');
    CopyPlan := DecodeRecordedPlan('FDR ROUTE', EncodeRecordedPlan(Plan), '');
    Try
     Check((CopyPlan.Points.Count = GeometryCount) And CopyPlan.Points.Last.MissedApproach, 'Offline snapshot replay');
    Finally
     CopyPlan.Free;
    End;
    For i := 0 To FieldCount - 1 Do
     Begin
      If SimFields[i].Name = 'title' Then
       Sample.Texts[i] := 'iFly 737 MAX 8';
      If SimFields[i].Name = 'time_zulu.year' Then
       Sample.Numbers[i] := 2026;
      If SimFields[i].Name = 'time_zulu.month' Then
       Sample.Numbers[i] := 10;
      If SimFields[i].Name = 'time_zulu.day' Then
       Sample.Numbers[i] := 24;
      If SimFields[i].Name = 'time_zulu.seconds' Then
       Sample.Numbers[i] := 43200;
      If SimFields[i].Name = 'number_of_engines' Then
       Sample.Numbers[i] := 0;
     End;
    ID := DB.StartTrip(Sample);
    DB.SaveFlightPlan(ID, Plan);
    DB.RecordSample(ID, Sample);
    Plot := DB.LoadTrip(ID);
    Try
     Check((Plot.FlightPlan <> Nil) And (Plot.FlightPlan.Points.Count = GeometryCount) And Plot.FlightPlan.Points.Last.MissedApproach, 'SQLite stores procedure snapshot with recording');
    Finally
     Plot.Free;
    End;
    SavedSnapshot := Plan.ProcedureData;
    Reader.SetPlan(Plan);
    Reader.Tick;
    Req := Reader.RequestID;
    Packet(0, 1, 0, 0, 0, Ints(0, 0, 0, 0, 4));
    Packet(10, 10, 1, 0, 1, TextData('SID1'));
    Packet(12, 20, 10, 0, 1, Ints(30, 1, 0, 0, 8));
    Leg(30, 20, 7, 0, 2, 'INCOMP', 52, 20);
    Finish;
    Reader.Tick;
    Req := Reader.RequestID;
    Packet(0, 1, 0, 0, 0, Ints(0, 0, 0, 0, 4));
    Finish;
    Check(Plan.ProcedureData = SavedSnapshot, 'Incomplete leg list never replaces complete snapshot');
    Check(Plan.Points.Count = GeometryCount, 'Incomplete response leaves replay intact');
    Reader.SetPlan(Nil);
    Req := OldReq;
    Finish;
    Check(Reader.RequestID <> OldReq, 'Old generation ignored');
   Finally
    Reader.Free;
    Plan.Free;
    Sample.Free;
    DB.Free;
    Sim.Free;
   End;
   System.Writeln('PASS: real Facilities definitions/request path, out-of-order parents, selected procedures, item ordering, missed/hold constraints, SQLite and offline replay. Mock only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyProcedureRouteTests);

End.
