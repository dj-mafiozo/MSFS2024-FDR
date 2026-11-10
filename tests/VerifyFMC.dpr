Program VerifyFMC;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.Classes, System.Variants, System.JSON, System.Generics.Collections, FireDAC.Comp.Client,

 FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, FMCScreensU, FMCPreflightU, AnalysisContextU;

Var
 DB        : TFlightDatabase;
 s         : TFlightSample;
 q         : TFDQuery;
 Root      : TJSONObject;
 Fields    : TJSONObject;
 Parsed    : TJSONObject;
 Context   : TJSONObject;
 FMC       : TJSONObject;
 Devices   : TJSONObject;
 Values    : TJSONObject;
 Screens   : TObjectList<TFMCScreen>;
 Preflight : TFMCPreflightCache;
 Left      : TStringList;
 Right     : TStringList;
 i         : Integer;
 ID        : Integer;
 EventID   : Integer;
 Count     : Integer;
 Path      : String;
 Text      : String;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure SetN(Const Name : String; v : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    Begin
     s.Numbers[k] := v;
     Exit;
    End;
  Raise Exception.Create(Name);
 End;

Procedure Blank(l : TStringList; Const Title : String);
 Var
  k : Integer;
 Begin
  l.Clear;
  l.Add(Copy(Title + StringOfChar(' ', 24), 1, 24));
  For k := 1 To 13 Do
   l.Add(StringOfChar(' ', 24));
 End;

Procedure Cell(l : TStringList; Row, Col : Integer; Const v : String);
 Var
  a : String;
 Begin
  a := l[Row];
  Move(v[1], a[Col + 1], Length(v) * SizeOf(Char));
  l[Row] := a;
 End;

Procedure MakeRoot;
 Var
  d : Integer;
  r : Integer;
  l : TStringList;
 Begin

  FreeAndNil(s.AircraftData);
  Root           := TJSONObject.Create;
  s.AircraftData := Root;
  Root.AddPair('provider', 'iFly737MAX');
  Fields := TJSONObject.Create;
  Root.AddPair('fields', Fields);

  For d := 0 To 1 Do
   Begin
    If d = 0 Then
     l := Left
    Else
     l    := Right;
    For r := 0 To 13 Do
     Fields.AddPair(Format('LSKChar[%d][%d]', [d, r]), l[r]);
   End;

 End;

Procedure Save(Seconds : Integer);
 Begin
  MakeRoot;
  SetN('time_zulu.seconds', Seconds);
  DB.RecordSample(ID, s);
 End;

Type

 [TestFixture]
 TVerifyFMCTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyFMCTests.Regression;
 Begin

  s     := TFlightSample.Create;
  Left  := TStringList.Create;
  Right := TStringList.Create;
  q     := TFDQuery.Create(Nil);
  DB    := Nil;

  Try

   Blank(Left, 'TAKEOFF REF 1/2');
   Cell(Left, 1, 0, 'FLAPS');
   Cell(Left, 1, 21, 'V1');
   Cell(Left, 2, 0, '5');
   Cell(Left, 2, 20, '135');
   Cell(Left, 3, 22, 'VR');
   Cell(Left, 4, 20, '140');
   Cell(Left, 5, 22, 'V2');
   Cell(Left, 6, 20, '145');

   Blank(Right, 'PERF INIT');
   Cell(Right, 1, 0, 'GW / CRZ ALT');
   Cell(Right, 2, 0, '65.0 / 37000');
   MakeRoot;

   Fields.AddPair('LSK_Color[0][12][0]', TJSONNumber.Create(6));
   Screens := ExtractFMCScreens(Root);

   Try

    Check(Screens.Count = 2, 'Two independent iFly CDUs');
    Check(Screens[0].PageKey = 'TAKEOFF_REF:1/2', 'Page number retained in cache key');
    Check(Screens[0].Lines.Count = 14, 'TStringList has 14 rows');
    Check(Length(Screens[0].Lines[2]) = 24, 'Fixed columns preserved');
    Check(Screens[0].Lines[12][1] = WideChar($B0), 'iFly glyph flags decoded');

    Check(Screens[0].PowerState = -1, 'Brightness does not invent power state');
    Check(Pos(#13#10, Screens[0].Lines.Text) > 0, 'Raw TStringList text preserves CRLF');

    Parsed := ParseFMCValues(Screens[0]);
    Try
     Check(Parsed.GetValue('v1_kt').Value = '135', 'Right-aligned V1');
     Check(Parsed.GetValue('vr_kt').Value = '140', 'Right-aligned VR');
     Check(Parsed.GetValue('v2_kt').Value = '145', 'Right-aligned V2');
    Finally
     Parsed.Free;
    End;

   Finally
    Screens.Free;
   End;

   // Actual iFly QRH/selected columns: QRH is a proposal, the far-right value is selected.

   Blank(Left, 'TAKEOFF REF 1/2');

   Cell(Left, 1, 0, ' FLAPS          QRH   V1');
   Cell(Left, 2, 0, '15              119  124');

   Cell(Left, 3, 0, ' TO N1                VR');
   Cell(Left, 4, 0, ' 93.8/ 93.8%    120  125');

   Cell(Left, 5, 0, ' CG    TRIM           V2');
   Cell(Left, 6, 0, '22.1%  3.95     130  137');

   MakeRoot;
   Screens := ExtractFMCScreens(Root);

   Try
    Parsed := ParseFMCValues(Screens[0]);
    Try

     Check(Parsed.GetValue('v1_kt').Value = '124', 'QRH column must not replace selected V1');

     Check(Parsed.GetValue('vr_kt').Value = '125', 'Selected VR');

     Check(Parsed.GetValue('v2_kt').Value = '137', 'Selected V2');

    Finally
     Parsed.Free;
    End;
   Finally
    Screens.Free;
   End;

   Cell(Left, 2, 20, '---');
   MakeRoot;
   Screens := ExtractFMCScreens(Root);

   Try
    Parsed := ParseFMCValues(Screens[0]);
    Try

     Check(Parsed.GetValue('v1_kt') Is TJSONNull, 'Unselected V1 does not fall back to QRH');

    Finally
     Parsed.Free;
    End;
   Finally
    Screens.Free;
   End;

   Blank(Left, 'APPROACH REF 1/2');

   Cell(Left, 1, 0, ' GROSS WT   FLAPS   VREF');
   Cell(Left, 2, 0, '62.1         15    147KT');

   Cell(Left, 4, 0, '<QFE/QNH     30    142KT');
   Cell(Left, 6, 0, ' 8202FT2500M 40    137KT');

   Cell(Left, 7, 0, ' ILS 25 /CRS    FLAP/SPD');
   Cell(Left, 8, 0, '110.50LOD/245     40/137');

   Cell(Left, 9, 0, ' G/S           WIND CORR');
   Cell(Left, 10, 0, '<ON/OFF            +05KT');

   MakeRoot;
   Screens := ExtractFMCScreens(Root);

   Try
    Parsed := ParseFMCValues(Screens[0]);
    Try

     Check(Parsed.GetValue('vref_kt').Value = '137', 'Selected FLAP/SPD speed is VREF');

     Check(Parsed.GetValue('approach_flaps_deg').Value = '40', 'Selected landing flaps');

     Check(Parsed.GetValue('wind_correction_kt').Value = '5', 'Wind correction retained separately');

    Finally
     Parsed.Free;
    End;
   Finally
    Screens.Free;
   End;

   Cell(Left, 8, 18, '30/142');
   MakeRoot;
   Screens := ExtractFMCScreens(Root);

   Try
    Parsed := ParseFMCValues(Screens[0]);
    Try

     Check(Parsed.GetValue('vref_kt').Value = '142', 'Selection follows FLAP/SPD, not last table row');

    Finally
     Parsed.Free;
    End;
   Finally
    Screens.Free;
   End;

   Cell(Left, 8, 18, '--/---');
   MakeRoot;
   Screens := ExtractFMCScreens(Root);

   Try
    Parsed := ParseFMCValues(Screens[0]);
    Try

     Check(Parsed.GetValue('vref_kt') Is TJSONNull, 'Cleared FLAP/SPD never guesses table VREF');

    Finally
     Parsed.Free;
    End;
   Finally
    Screens.Free;
   End;

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 17);

   Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'fmc-' + IntToStr(GetTickCount64) + '.db');
   DB   := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   ID   := DB.StartTrip(s);

   Save(0);
   Save(1);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens') = 2, 'Unchanged raw screens omitted: ' + VarToStr(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')));

   Blank(Left, 'N1 LIMIT');
   Cell(Left, 2, 0, '26K  N1 98.2');
   Save(2);

   Blank(Left, 'APPROACH REF');
   Cell(Left, 1, 0, 'VREF 130');
   Cell(Left, 3, 0, 'WIND CORR +05KT');
   Save(3);

   Blank(Left, 'TAKEOFF REF');
   Cell(Left, 1, 0, 'V1 138');
   Save(4);

   Blank(Left, 'MOD TAKEOFF REF');
   Cell(Left, 1, 0, 'V1 199');
   Save(5);

   // A shorter analysis window must still recover the last previously seen pages.

   SetN('time_zulu.seconds', 20);
   EventID := DB.Contact(ID, s, True);

   Blank(Left, 'TAKEOFF REF');
   Cell(Left, 1, 0, 'V1 250');
   Save(40);

   DB.Connection.ExecSQL('update trip_fmc_screens set parsed_json=''{"v1_kt":null,"vref_kt":null}''');

   q.Connection             := DB.Connection;
   q.FormatOptions.StrsTrim := False;
   q.Open('select * from trip_touchdowns where id=:i', [EventID]);
   Context := BuildContactContext(DB, q, 1, 1);

   Try

    FMC  := Context.GetValue('fmc_last_observed') As TJSONObject;
    Text := FMC.ToJSON.Replace('\/', '/');

    Check(Pos('65.0 / 37000', Text) > 0, 'PERF INIT outside window retained');
    Check(Pos('98.2', Text) > 0, 'N1 LIMIT retained');
    Check(Pos('V1 250', Text) = 0, 'No future screen leakage');

    Devices := FMC.GetValue('last_values_by_device') As TJSONObject;
    Values  := Devices.GetValue('iFly737MAX/0') As TJSONObject;

    Check((Values.GetValue('v1_kt') As TJSONObject).GetValue('value').Value = '138', 'Last non-MOD V1 at event');

    Check((Values.GetValue('vref_kt') As TJSONObject).GetValue('value').Value = '130', 'Last approach VREF');

    Check((Values.GetValue('wind_correction_kt') As TJSONObject).GetValue('value').Value = '5', 'Wind correction units');

    Check(Pos('MOD TAKEOFF REF', Text) > 0, 'Pending MOD page retained separately');
    Check(Pos('199', (Values.GetValue('v1_kt') As TJSONObject).ToJSON) = 0, 'MOD not treated as executed');

   Finally
    Context.Free;
   End;

   q.Close;
   q.Open('select raw_text,time_zulu,captured_utc from trip_fmc_screens where page_key=''PERF_INIT''');

   Check(DB.Connection.ExecSQLScalar('select length(raw_text) from trip_fmc_screens where page_key=''PERF_INIT''') = Length(Right.Text), 'Stored raw text retains trailing spaces and rows');

   Check(q.FieldByName('raw_text').AsWideString = Right.Text, 'Exact raw text round trip');
   Check(q.FieldByName('time_zulu').AsString <> '', 'Simulation timestamp');
   Check(q.FieldByName('captured_utc').AsString <> '', 'Capture timestamp');
   q.Close;

   // Clearing an explicitly shown value must replace a previous parsed value with null.

   Blank(Left, 'TAKEOFF REF');
   Cell(Left, 1, 0, 'V1 ---');
   Save(45);
   FMC := LatestFMCContext(DB.Connection, ID, s.Time('time_zulu'));

   Try
    Devices := FMC.GetValue('last_values_by_device') As TJSONObject;
    Values  := Devices.GetValue('iFly737MAX/0') As TJSONObject;
    Check((Values.GetValue('v1_kt') As TJSONObject).GetValue('value') Is TJSONNull, 'Cleared V1 is null, not carried forward');
   Finally
    FMC.Free;
   End;

   // Do not mistake a multi-row VREF table for one selected speed.

   Blank(Left, 'APPROACH REF');
   Cell(Left, 1, 16, 'VREF');
   Cell(Left, 2, 0, '15');
   Cell(Left, 2, 18, '145');
   Cell(Left, 3, 0, '30');
   Cell(Left, 3, 18, '137');
   MakeRoot;
   Screens := ExtractFMCScreens(Root);

   Try
    Parsed := ParseFMCValues(Screens[0]);
    Try
     Check(Parsed.GetValue('vref_kt') Is TJSONNull, 'No guessed VREF from table');
    Finally
     Parsed.Free;
    End;
   Finally
    Screens.Free;
   End;

   // Missing one row invalidates the screen; no partial raw screen is fabricated.

   Fields.RemovePair('LSKChar[0][13]').Free;
   DB.RecordSample(ID, s);

   Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens where device=''0'' order by id desc limit 1') = 0, 'Missing row marks unavailable');

   // PMDG and future providers use the same generic row API and TStringList conversion.

   FreeAndNil(s.AircraftData);
   s.AircraftData := TJSONObject.ParseJSONValue('{"provider":"PMDGNG3","cdu":{"0":{"status":"available","powered":true,"rows":[]}}}') As TJSONObject;

   Root   := s.AircraftData;
   Fields := Root.GetValue('cdu') As TJSONObject;
   Fields := Fields.GetValue('0') As TJSONObject;

   For i := 0 To 13 Do
    (Fields.GetValue('rows') As TJSONArray).Add(Left[i]);
   SetN('time_zulu.seconds', 46);
   DB.RecordSample(ID, s);

   Count := DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens');

   Fields.RemovePair('powered').Free;
   Fields.AddPair('powered', TJSONBool.Create(False));
   SetN('time_zulu.seconds', 47);
   DB.RecordSample(ID, s);

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens') = Count + 1, 'Power change recorded even with identical text');

   FreeAndNil(s.AircraftData);
   SetN('time_zulu.seconds', 48);
   DB.RecordSample(ID, s);

   Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens where provider=''PMDGNG3'' order by id desc limit 1') = 0, 'Provider disappearance invalidates screen');

   DB.DeleteTrip(ID);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens') = 0, 'FMC history removed with trip');

   // Preparation pages are observed before engine-start recording; pruning retains last pages.

   Preflight := TFMCPreflightCache.Create(1);

   Try

    Blank(Left, 'PERF INIT 1/2');
    Cell(Left, 2, 0, 'PRESTART GW 65.0');
    MakeRoot;
    Preflight.Observe(s.AircraftData, '2026-10-17T00:01:00.000+00:00_0');

    Blank(Left, 'N1 LIMIT');
    Cell(Left, 2, 0, 'PRESTART N1 98.2');
    MakeRoot;
    Preflight.Observe(s.AircraftData, '2026-10-17T00:01:01.000+00:00_0');

    Blank(Left, 'TAKEOFF REF');
    Cell(Left, 1, 0, 'V1 141');
    MakeRoot;
    Preflight.Observe(s.AircraftData, '2026-10-17T00:01:02.000+00:00_0');

    SetN('time_zulu.seconds', 100);
    ID := DB.StartTrip(s);
    Preflight.Flush(DB.Connection, ID);

    FMC := LatestFMCContext(DB.Connection, ID, '2026-10-17T00:01:50.000+00:00_0');

    Try
     Text := FMC.ToJSON;
     Check(Pos('PRESTART GW 65.0', Text) > 0, 'Preflight PERF INIT survives bounded history pruning');
     Check(Pos('PRESTART N1 98.2', Text) > 0, 'Preflight N1 LIMIT retained');
     Check(Pos('141', Text) > 0, 'Preflight takeoff values retained');
    Finally
     FMC.Free;
    End;

    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t and sample=0', [ID]) > 0, 'Preflight text tagged without flight snapshot');

    Count := DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens');
    Preflight.Flush(DB.Connection, ID);
    Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens') = Count, 'Flushed preflight cache cleared');

    DB.DeleteTrip(ID);

   Finally
    Preflight.Free;
   End;

  Finally
   q.Free;
   DB.Free;
   s.Free;
   Left.Free;
   Right.Free;
   If Path <> '' Then
    DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: iFly/PMDG TStringList screens, glyphs, raw text round trip, change-only history, timestamps, per-page/as-of-event cache, V-speeds/wind correction, MOD isolation, cleared/ambiguous values, power/unavailability and cleanup.');

 End;

Begin
 RunNativeTests(TVerifyFMCTests);
End.
