Program VerifyIFlyDisplays;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.JSON, System.Math, FlightDatabaseU, FlightTelemetryU,

 TelemetryCatalogU, iFlyDisplaysU, FMCScreensU, FMCPreflightU;

Const
 Lamps : Array [0..4] Of String = ('FAIL', 'MSG', 'EXEC', 'CALL', 'OFST');

Var
 Fields  : TJSONObject;
 Root    : TJSONObject;
 j       : TJSONObject;
 Style   : TJSONObject;
 s       : TFlightSample;
 DB      : TFlightDatabase;
 Plot    : TTripPlot;
 Cache   : TFMCPreflightCache;
 Path    : String;
 Key     : String;
 Payload : String;
 Text    : String;
 Trip    : Integer;
 Other   : Integer;
 i       : Integer;
 d       : Integer;
 r       : Integer;
 c       : Integer;
 Idx     : Integer;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure N(Const k : String; v : Integer);
 Begin
  Fields.RemovePair(k).Free;
  Fields.AddPair(k, TJSONNumber.Create(v));
 End;

Procedure Digits(Const Prefix : String; Const Values : Array Of Integer);
 Const
  Places : Array [0..4] Of String = ('10000', '1000', '100', '10', '1');
 Var
  k : Integer;
 Begin
  For k := 0 To High(Values) Do
   N(Prefix + '_' + Places[k + 5 - Length(Values)] + '_Status', Values[k]);
 End;

Procedure SetN(Const Name : String; v : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    s.Numbers[k] := v;
 End;

Function Number(Const k : String) : Double;
 Begin
  Result := (Fields.GetValue(k) As TJSONNumber).AsDouble;
 End;

Type

 [TestFixture]
 TVerifyIFlyDisplaysTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyIFlyDisplaysTests.Regression;
 Begin

  Fields := TJSONObject.Create;
  Root   := TJSONObject.Create;
  s      := TFlightSample.Create;
  DB     := Nil;

  Cache := TFMCPreflightCache.Create;
  Root.AddPair('provider', 'iFly737MAX');
  Root.AddPair('fields', Fields);

  s.AircraftData := Root;

  Path := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'ifly-displays-' + IntToStr(GetTickCount64) + '.db');

  Try

   Digits('Flight_Altitude_Indicator', [3, 5, 0, 0, 0]);
   Digits('Landing_Altitude_Indicator', [10, 0, 5, 0, 0]);

   Digits('HDG', [1, 2, 3]);
   Digits('VS', [1, 5, 0, 0]);
   N('VS_Symbol_Status', 11);

   Digits('SPD', [7, 8, 0]);
   N('SPD_Point_Status', 1);

   For i := 0 To 4 Do
    N(Format('Fuel_Quantity_Indicator_Status[0][%d]', [i]), StrToInt(Copy('03875', i + 1, 1)));

   For i := 0 To 4 Do
    Begin

     Case i Of
      0 : Key := '1000';
      1 : Key := '100';
      2 : Key := '10';
      3 : Key := '1';
     Else Key := '01';
     End;

     N('ADF_num_' + Key + '_Status[1]', StrToInt(Copy('08900', i + 1, 1)));

    End;

   For i := 1 To 4 Do
    N(Format('ADF_num_point%d_Status[1]', [i]), Ord(i = 4));

   For i := 1 To 6 Do
    N(Format('IRS_Window_L_%d_Status', [i]), StrToInt(Copy('051436', i, 1)));

   N('IRS_Window_L_1_Status', 12);
   For i := 1 To 3 Do
    N(Format('IRS_Window_L_point_%d_Status', [i]), 1);

   AssembleIFlyDisplays(Fields);

   Check(Number('Flight_Altitude_Indicator_Value') = 35000, 'Flight altitude assembly');

   Check(Number('Landing_Altitude_Indicator_Value') = -500, 'Signed landing altitude');

   Check(Number('HDG_Value') = 123, 'Heading assembly');
   Check(Number('VS_Value') = -1500, 'Signed vertical speed');

   Check(Number('Fuel_Quantity_Indicator_Value[0]') = 3875, 'Fuel display index order');

   Check(Number('ADF_num_Value[1]') = 890, 'ADF decimal point');

   Check(Fields.GetValue('IRS_Window_L_Value').Value = 'N51436', 'IRS direction letter retained');

   Check(Number('IRS_Window_L_Points') = 7, 'IRS point mask preserved without coordinate guessing');

   Check(Fields.GetValue('SPD_Value') Is TJSONNull, 'Undefined Mach decimal is not guessed');

   Digits('Landing_Altitude_Indicator', [11, 11, 11, 11, 11]);
   AssembleIFlyDisplays(Fields);

   Check(Fields.GetValue('Landing_Altitude_Indicator_Value') Is TJSONNull, 'Blank display is not zero');

   Check(Not IFlyCompactField('Window_Heat_Switch_1_Status'), 'Switch names are not mistaken for display digits');

   For d := 0 To 1 Do
    Begin

     For r := 0 To 13 Do
      Begin

       Text := StringOfChar(' ', 24);
       If r = 0 Then
        Text := 'PERF INIT' + StringOfChar(' ', 15);

       If r = 1 Then
        Text := '<X&>' + StringOfChar(' ', 20);

       Fields.AddPair(Format('LSKChar[%d][%d]', [d, r]), Text);

       For c := 0 To 23 Do
        Begin
         N(Format('LSK_Color[%d][%d][%d]', [d, r, c]), 0);
         N(Format('LSK_SmallFont[%d][%d][%d]', [d, r, c]), 0);
        End;

      End;

     For Key In Lamps Do
      N(Format('CDU_%s_Status[%d]', [Key, d]), 0);

    End;

   N('FLAP_Status', 5);
   N('Tick18', 1);
   DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');

   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 18);

   Trip := DB.StartTrip(s);
   DB.RecordSample(Trip, s);

   Payload := DB.Connection.ExecSQLScalar('select payload from trip_aircraft_data where trip=:t', [Trip]);

   Check(Pos('Flight_Altitude_Indicator_Value', Payload) > 0, 'Assembled value stored');
   Check(Pos('Tick18', Payload) = 0, 'Clock tick excluded before SDK delta storage');
   N('Tick18', 999);
   SetN('time_zulu.seconds', 0);
   DB.RecordSample(Trip, s);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t', [Trip]) = 1, 'Tick-only change does not create delta');
   Check(Fields.GetValue('Tick18') <> Nil, 'Wire SDK clock remains intact in memory');

   Check((Pos('LSKChar[', Payload) = 0) And (Pos('LSK_Color[', Payload) = 0) And (Pos('CDU_EXEC_Status[', Payload) = 0), 'No duplicated FMC fields in general history');

   Check(Pos('Flight_Altitude_Indicator_10000_Status', Payload) = 0, 'No individual display digits in general history');

   Check(Fields.GetValue('LSKChar[0][0]') <> Nil, 'In-memory SDK remains available to FMC extraction');

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t', [Trip]) = 2, 'Two independent CDU records');

   N('LSK_SmallFont[0][1][0]', 1);
   SetN('time_zulu.seconds', 1);
   DB.RecordSample(Trip, s);

   N('LSK_Color[0][1][1]', 3);
   SetN('time_zulu.seconds', 2);
   DB.RecordSample(Trip, s);

   N('CDU_EXEC_Status[0]', 2);
   SetN('time_zulu.seconds', 3);
   DB.RecordSample(Trip, s);

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens where trip=:t', [Trip]) = 5, 'Font-only, color-only and lamp-only changes saved');

   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_aircraft_data where trip=:t', [Trip]) = 1, 'Font/lamps do not duplicate general telemetry');

   Text := DB.Connection.ExecSQLScalar('select formatted_html from trip_fmc_screens where trip=:t and device=''0'' order by id desc limit 1', [Trip]);

   Check((Pos('&lt;', Text) > 0) And (Pos('&amp;', Text) > 0) And (Pos('font-size:75%', Text) > 0) And (Pos('color:#ff00ff', Text) > 0), 'Escaped formatted HTML and small font');

   Text := DB.Connection.ExecSQLScalar('select annunciators_json from trip_fmc_screens where trip=:t and device=''0'' order by id desc limit 1', [Trip]);

   j := TJSONObject.ParseJSONValue(Text) As TJSONObject;
   Try
    Check(j.GetValue('EXEC').Value = '2', 'CDU EXEC brightness preserved');
   Finally
    j.Free;
   End;

   Text := DB.Connection.ExecSQLScalar('select style_json from trip_fmc_screens where trip=:t and device=''0'' order by id desc limit 1', [Trip]);

   Style := TJSONObject.ParseJSONValue(Text) As TJSONObject;

   Try
    Check(Length((Style.GetValue('rows') As TJSONArray).Items[1].Value) = 48, '24 packed color/font cells');
   Finally
    Style.Free;
   End;

   N('Flight_Altitude_Indicator_1000_Status', 6);
   SetN('time_zulu.seconds', 4);
   DB.RecordSample(Trip, s);

   Plot := DB.LoadTrip(Trip);

   Try

    Idx := Plot.Labels.IndexOf('iFlySDK.Flight_Altitude_Indicator_Value');
    Check(Idx >= 0, 'Assembled chart parameter');

    Check(Plot.Points[0].Values[Idx] = 35000, 'Chart baseline');
    Check(Plot.Points[5].Values[Idx] = 36000, 'Chart delta');

    Check(Plot.Labels.IndexOf('iFlySDK.LSK_Color[0][0][0]') < 0, 'No segment/color noise in new chart list');

   Finally
    Plot.Free;
   End;

   Cache.Observe(Root, s.Time('time_zulu'));
   Other := DB.StartTrip(s);
   Cache.Flush(DB.Connection, Other);

   Text := DB.Connection.ExecSQLScalar('select annunciators_json from trip_fmc_screens where trip=:t and device=''0''', [Other]);

   Check(Pos('"EXEC":2', Text) > 0, 'Preflight cache retains CDU lamps');

   Text := DB.Connection.ExecSQLScalar('select style_json from trip_fmc_screens where trip=:t and device=''0''', [Other]);

   Check(Pos('color-font-nibbles-v1', Text) > 0, 'Preflight cache retains packed styles');

   DB.DeleteTrip(Trip);
   DB.DeleteTrip(Other);

  Finally
   Cache.Free;
   DB.Free;
   s.Free;
   DeleteFile(PChar(Path));
  End;

  System.Writeln('PASS: assembled iFly displays, blank/sign/decimal/IRS states, compact SDK history and charts, separate FMC text/styles/HTML/CDU lamps, appearance-only changes and preflight retention. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyIFlyDisplaysTests);
End.
