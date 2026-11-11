Program VerifyAirliner;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas',
 Winapi.Windows, System.SysUtils, System.Math, System.JSON, AirlinerVarsU In '..\src\Telemetry\AirlinerVarsU.pas', AirlinerCatalogU In '..\src\Telemetry\AirlinerCatalogU.pas',

 FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', AnalysisContextU In '..\src\Analysis\AnalysisContextU.pas', FireDAC.Comp.Client;

Type
 TReset = Procedure(Mode : Integer);

 Stdcall;

 TCount = Function(Kind : Integer) : Integer;

 Stdcall;

Var
 DLL     : HMODULE;
 Reset   : TReset;
 Counter : TCount;
 r       : TAirlinerVars;
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
 TVerifyAirlinerTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyAirlinerTests.Regression;
 Begin

  Mock := ExtractFilePath(ParamStr(0)) + 'MockFenixSim.dll';
  DLL  := LoadLibrary(PChar(Mock));
  Check(DLL <> 0, 'Load transport');

  @Reset := GetProcAddress(DLL, 'FenixMockReset');
  @Counter := GetProcAddress(DLL, 'FenixMockCount');

  r := TAirlinerVars.Create(Mock);

  Try

   Reset(0);
   r.Tick;
   j := r.Snapshot;

   Try

    Fields := j.GetValue('fields') As TJSONObject;

    Check(Fields.Count = AirlinerVarCount, 'Common AIRLINER catalog');
    Check(Fields.GetValue('AIRLINER_V1_SPEED').Value = '135', 'V1');

    Check((j.GetValue('performance_reference') As TJSONObject).GetValue('vr_kt').Value = '140', 'VR reference');

    Check((Counter(0) = AirlinerVarCount) And (Counter(1) = AirlinerVarCount) And (Counter(5) = 0), 'Isolated read definitions');
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
        Check(Fields.GetValue(AirlinerNames[AirlinerVarCount - 1]) Is TJSONNull, 'Missing optional field');
        Check(Fields.GetValue('AIRLINER_VR_SPEED').Value = '140', 'Other fields retained');
       End;

      If Mode In [2, 3, 4] Then
       Begin
        Check(Fields.GetValue('AIRLINER_V1_SPEED') Is TJSONNull, 'Invalid field isolated');
        Check(Fields.GetValue('AIRLINER_VR_SPEED').Value = '140', 'Unrelated field survives');
       End;

      If Mode In [5, 6] Then
       Check(j.GetValue('status').Value = 'unavailable', 'Quit/missing replies unavailable');

      If Mode = 7 Then
       Begin
        Check(Fields.GetValue('AIRLINER_V1_SPEED').Value = '0', 'Raw zero retained');
        Check((j.GetValue('performance_reference') As TJSONObject).Count = 0, 'Zero is not valid speed reference');
       End;

     Finally
      j.Free;
     End;

    End;

   r.Close;
   Reset(0);
   r.Tick;

   s    := TFlightSample.Create;
   Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'airliner-' + IntToStr(GetTickCount64) + '.db');

   DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   q  := TFDQuery.Create(Nil);

   Try

    SetN('time_zulu.year', 2026);
    SetN('time_zulu.month', 10);
    SetN('time_zulu.day', 17);

    s.AirlinerData := r.Snapshot;
    Trip           := DB.StartTrip(s);
    DB.RecordSample(Trip, s);
    SetN('time_zulu.seconds', 1);
    DB.RecordSample(Trip, s);

    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 1, 'Unchanged common data omitted');

    Fields := s.AirlinerData.GetValue('fields') As TJSONObject;
    Fields.RemovePair('AIRLINER_V1_SPEED').Free;
    Fields.AddPair('AIRLINER_V1_SPEED', TJSONNumber.Create(136));

    SetN('time_zulu.seconds', 2);
    DB.RecordSample(Trip, s);
    EventID := DB.Contact(Trip, s, False);

    r.Close;
    FreeAndNil(s.AirlinerData);
    s.AirlinerData := r.Snapshot;
    SetN('time_zulu.seconds', 3);
    DB.RecordSample(Trip, s);

    Plot := DB.LoadTrip(Trip);

    Try
     Index := Plot.Labels.IndexOf('AirlinerLVar.AIRLINER_V1_SPEED');
     Check(Index >= 0, 'Common chart parameter');

     Check((Plot.Points[0].Values[Index] = 135) And (Plot.Points[1].Values[Index] = 135) And (Plot.Points[2].Values[Index] = 136), 'Common chart replay');

     Check(IsNan(Plot.Points[3].Values[Index]), 'Unavailable chart gap');

    Finally
     Plot.Free;
    End;

    q.Connection := DB.Connection;
    q.Open('select * from trip_liftoffs where id=:i', [EventID]);
    Context := BuildContactContext(DB, q, 3, 2);

    Try
     Check(Context.GetValue('airliner_lvar_definitions') <> Nil, 'Definitions in AI');
     Check(Pos('airliner_lvars', Context.ToJSON) > 0, 'Common data in AI');
    Finally
     Context.Free;
    End;

    DB.DeleteTrip(Trip);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data') = 0, 'Common history deletion');

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

  System.Writeln('PASS: common AIRLINER read-only SimConnect L-vars, per-field isolation, zeros/null/errors, optional delta storage, chart replay/gaps, AI definitions and cleanup. Mock only.');

 End;

Begin
 RunNativeTests(TVerifyAirlinerTests);
End.
