Program VerifyGSX;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Math, System.JSON, GSXVarsU,

 FlightTelemetryU, TelemetryCatalogU, FlightDatabaseU, AnalysisContextU, FireDAC.Comp.Client;

Type
 TReset = Procedure(Mode : Integer);

 Stdcall;

 TCount = Function(Kind : Integer) : Integer;

 Stdcall;

Var
 DLL     : HMODULE;
 Reset   : TReset;
 Counter : TCount;
 r       : TGSXVars;
 j       : TJSONObject;
 Fields  : TJSONObject;
 Context : TJSONObject;
 DB      : TFlightDatabase;
 s       : TFlightSample;
 Plot    : TTripPlot;
 q       : TFDQuery;
 Path    : String;
 Mock    : String;
 Mode    : Integer;
 i       : Integer;
 Trip    : Integer;
 EventID : Integer;
 Index   : Integer;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetN(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := Value;
     Exit;
    End;
 End;

Type

 [TestFixture]
 TVerifyGSXTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyGSXTests.Regression;
 Begin

  Mock := ExtractFilePath(ParamStr(0)) + 'MockFenixSim.dll';
  DLL  := LoadLibrary(PChar(Mock));
  Check(DLL <> 0, 'Load transport');

  @Reset := GetProcAddress(DLL, 'FenixMockReset');
  @Counter := GetProcAddress(DLL, 'FenixMockCount');

  r := TGSXVars.Create(Mock);

  Try

   Reset(0);
   r.Tick;
   j := r.Snapshot;

   Try

    Fields := j.GetValue('fields') As TJSONObject;

    Check(Fields.Count = GSXVarCount, 'GSX Pro catalog');
    Check(Fields.GetValue('FSDT_GSX_BOARDING_STATE').Value = '5', 'V1');

    Check((Counter(0) = GSXVarCount) And (Counter(1) = GSXVarCount) And (Counter(5) = 0), 'Isolated read definitions');
    Check(Counter(4) = 0, 'No writes');

   Finally
    j.Free;
   End;

   For Mode := 1 To 7 Do
    Begin

     r.Close;
     Reset(Mode);
     r.Tick;
     j := r.Snapshot;

     Try

      Fields := j.GetValue('fields') As TJSONObject;

      If Mode = 1 Then
       Begin
        Check(Fields.GetValue(GSXNames[GSXVarCount - 1]) Is TJSONNull, 'Missing optional field');
        Check(Fields.GetValue('FSDT_GSX_DEBOARDING_STATE').Value = '5', 'Other fields retained');
       End;

      If Mode In [2, 3, 4] Then
       Begin
        Check(Fields.GetValue('FSDT_GSX_BOARDING_STATE') Is TJSONNull, 'Invalid field isolated');
        Check(Fields.GetValue('FSDT_GSX_DEBOARDING_STATE').Value = '5', 'Unrelated field survives');
       End;

      If Mode In [5, 6] Then
       Check(j.GetValue('status').Value = 'unavailable', 'Quit/missing replies unavailable');

      If Mode = 7 Then
       Begin
        Check(Fields.GetValue('FSDT_GSX_BOARDING_STATE').Value = '0', 'Raw zero retained');
        Check(j.GetValue('status').Value = 'received_not_verified', 'Zero does not prove GSX active');
       End;

     Finally
      j.Free;
     End;

    End;

   r.Close;
   Reset(0);
   r.Tick;

   s    := TFlightSample.Create;
   Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'gsx-' + IntToStr(GetTickCount64) + '.db');

   DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   q  := TFDQuery.Create(Nil);

   Try

    SetN('time_zulu.year', 2026);
    SetN('time_zulu.month', 10);
    SetN('time_zulu.day', 17);

    s.GSXData := r.Snapshot;
    Trip      := DB.StartTrip(s);
    DB.RecordSample(Trip, s);
    SetN('time_zulu.seconds', 1);
    DB.RecordSample(Trip, s);

    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 1, 'Unchanged common data omitted');

    Fields := s.GSXData.GetValue('fields') As TJSONObject;
    Fields.RemovePair('FSDT_GSX_BOARDING_STATE').Free;
    Fields.AddPair('FSDT_GSX_BOARDING_STATE', TJSONNumber.Create(6));

    SetN('time_zulu.seconds', 2);
    DB.RecordSample(Trip, s);
    EventID := DB.Contact(Trip, s, False);

    r.Close;
    FreeAndNil(s.GSXData);
    s.GSXData := r.Snapshot;
    SetN('time_zulu.seconds', 3);
    DB.RecordSample(Trip, s);

    Plot := DB.LoadTrip(Trip);

    Try
     Index := Plot.Labels.IndexOf('GSX.FSDT_GSX_BOARDING_STATE');
     Check(Index >= 0, 'GSX chart parameter');

     Check((Plot.Points[0].Values[Index] = 5) And (Plot.Points[1].Values[Index] = 5) And (Plot.Points[2].Values[Index] = 6), 'GSX chart replay');

     Check(IsNan(Plot.Points[3].Values[Index]), 'Unavailable chart gap');

    Finally
     Plot.Free;
    End;

    q.Connection := DB.Connection;
    q.Open('select * from trip_liftoffs where id=:i', [EventID]);
    Context := BuildContactContext(DB, q, 3, 2);

    Try
     Check(Context.GetValue('gsx_lvar_definitions') <> Nil, 'Definitions in AI');
     Check(Pos('gsx_lvars', Context.ToJSON) > 0, 'GSX data in AI');
    Finally
     Context.Free;
    End;

    DB.DeleteTrip(Trip);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 0, 'GSX history deletion');

   Finally
    q.Free;
    DB.Free;
    s.Free;
    DeleteFile(PChar(Path));
   End;

  Finally
   r.Free;
   FreeLibrary(DLL);
  End;

  System.Writeln('PASS: GSX Pro read-only SimConnect L-vars, per-field isolation, zeros/null/errors, optional delta storage, chart replay/gaps, AI definitions and cleanup. Mock only.');

 End;

Begin
 RunNativeTests(TVerifyGSXTests);

End.
