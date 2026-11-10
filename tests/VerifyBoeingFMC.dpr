Program VerifyBoeingFMC;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.JSON, FMCScreensU, FlightDatabaseU, FlightTelemetryU,
 TelemetryCatalogU, frmTripInfoU;

Var
 Screen : TFMCScreen;
 j      : TJSONObject;
 DB     : TFlightDatabase;
 s      : TFlightSample;
 Form   : TfrmTripInfo;
 Path   : String;
 Trip   : Integer;
 i      : Integer;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Procedure Page(Const Title : String);
 Var
  k : Integer;
 Begin
  Screen.Lines.Clear;
  Screen.Lines.Add(Title);
  For k := 1 To 13 Do
   Screen.Lines.Add(StringOfChar(' ', 24));
 End;

Procedure Row(n : Integer; Const Value : String);
 Begin
  Screen.Lines[n] := Copy(Value + StringOfChar(' ', 24), 1, 24);
 End;

Procedure Parse;
 Begin
  j.Free;
  Screen.IdentifyPage;
  j := ParseFMCValues(Screen);
 End;

Procedure Expect(Const Key, Value : String);
 Begin
  Check((j.GetValue(Key) <> Nil) And ((j.GetValue(Key).Value = Value) Or ((j.GetValue(Key) Is TJSONNumber) And (j.GetValue(Key).ToJSON = Value))), Key + ' expected ' + Value + ' in ' + j.ToJSON);
 End;

Procedure Missing(Const Key : String);
 Begin
  Check(j.GetValue(Key) Is TJSONNull, Key + ' must be null');
 End;

Procedure Save(Second : Integer);
 Begin
  DB.Connection.ExecSQL('insert into trip_fmc_screens(trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json) ' + 'values(:t,0,:u,:u,''iFly737MAX'',''0'',:p,:h,1,1,:r,''{}'')', [Trip, Format('2026-10-18T00:00:%2.2d.000Z', [Second]), Screen.PageKey, Screen.Title, Screen.Lines.Text]);
 End;

Procedure SetN(Const Name : String; Value : Double);
 Var
  k : Integer;
 Begin
  For k := 0 To FieldCount - 1 Do
   If SimFields[k].Name = Name Then
    s.Numbers[k] := Value;
 End;

Type

 [TestFixture]
 TVerifyBoeingFMCTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyBoeingFMCTests.Regression;
 Begin
  Screen := TFMCScreen.Create;
  j      := Nil;
  DB     := Nil;
  s      := TFlightSample.Create;
  Form   := Nil;
  Path   := TestDatabasePath(ExtractFilePath(ParamStr(0)) + 'boeing-fmc-' + IntToStr(GetTickCount64) + '.db');
  Try
   DB := TFlightDatabase.Create(TestDatabasePath(Path), ExtractFilePath(ParamStr(0)) + 'sqlite3.dll');
   SetN('time_zulu.year', 2026);
   SetN('time_zulu.month', 10);
   SetN('time_zulu.day', 18);
   Trip              := DB.StartTrip(s);
   Screen.Provider   := 'iFly737MAX';
   Screen.Available  := True;
   Screen.PowerState := 1;
   Page('N1 LIMIT 1/1');
   Row(1, ' SEL/OAT           TO N1');
   Row(2, '----/ +14' + WideChar($B0) + 'C   93.8/ 93.8');
   Row(3, ' 28K');
   Row(4, '<TO   <ACT> <SEL>   CLB>');
   Row(5, ' 10% DERATE');
   Row(6, '<TO-1             CLB-1>');
   Row(7, ' 20% DERATE');
   Row(8, '<TO-2             CLB-2>');
   Row(9, ' 29K BUMP');
   Row(10, '<TO-B');
   Parse;
   Expect('takeoff_mode_active', 'TO');
   Expect('climb_mode_selected', 'CLB');
   Missing('takeoff_mode_selected');
   Expect('takeoff_active_rating_k', '28');
   Expect('takeoff_active_derate_pct', '0');
   Missing('assumed_temp_c');
   Expect('oat_c', '14');
   Expect('takeoff_n1_left_pct', '93.8');
   Expect('takeoff_n1_right_pct', '93.8');
   Save(1);
   Row(4, '<TO               CLB>');
   Row(6, '<TO-1 <ACT>       CLB-1>');
   Row(10, '<TO-B <SEL>');
   Row(2, '+45 / -10' + WideChar($B0) + 'C   90.1/ 90.2');
   Parse;
   Expect('takeoff_mode_active', 'TO-1');
   Expect('takeoff_active_derate_pct', '10');
   Expect('takeoff_mode_selected', 'TO-B');
   Expect('takeoff_selected_rating_k', '29');
   Expect('takeoff_selected_bump', 'true');
   Expect('assumed_temp_c', '45');
   Expect('oat_c', '-10');
   Page('TAKEOFF REF 1/2');
   Row(1, ' FLAPS          QRH   V1');
   Row(2, '15' + WideChar($B0) + '             119  124');
   Row(3, ' TO N1                VR');
   Row(4, ' 93.8/ 93.8%    120  125');
   Row(5, ' CG    TRIM           V2');
   Row(6, '22.1%  3.95     130  137');
   Parse;
   Expect('takeoff_flaps_deg', '15');
   Expect('takeoff_cg_pct', '22.1');
   Expect('takeoff_trim_units', '3.95');
   Expect('takeoff_n1_left_pct', '93.8');
   Expect('v1_kt', '124');
   Save(2);
   Page('PERF INIT 1/2');
   Row(1, ' GW/CRZ CG       CRZ ALT');
   Row(2, ' 51.1/22.1%        FL130');
   Row(3, ' PLAN/FUEL      CRZ WIND');
   Row(4, '---.-/ 6.0SENS  ---' + WideChar($B0) + '/---');
   Row(5, ' ZFW             ISA DEV');
   Row(6, ' 45.1         ---' + WideChar($B0) + 'F---' + WideChar($B0) + 'C');
   Row(7, ' RESERVES        T/C OAT');
   Row(8, ' 2.1          ---' + WideChar($B0) + 'F---' + WideChar($B0) + 'C');
   Row(9, ' COST INDEX    TRANS ALT');
   Row(10, ' 60                 6500');
   Parse;
   Expect('gross_weight_display', '51.1');
   Expect('cruise_cg_pct', '22.1');
   Expect('cruise_altitude_ft', '13000');
   Missing('planned_fuel_display');
   Expect('fuel_display', '6');
   Expect('fuel_source', 'SENS');
   Expect('zfw_display', '45.1');
   Expect('reserves_display', '2.1');
   Expect('cost_index', '60');
   Expect('transition_altitude_ft', '6500');
   Missing('cruise_wind_deg');
   Missing('isa_dev_c');
   Save(3);
   SetN('time_zulu.seconds', 10);
   DB.Contact(Trip, s, False);
   Page('APPROACH REF');
   Row(1, ' GROSS WT   FLAPS   VREF');
   Row(7, ' ILS 25 /CRS    FLAP/SPD');
   Row(8, '110.50LOD/245     40/137');
   Parse;
   Save(15);
   SetN('time_zulu.seconds', 20);
   DB.Contact(Trip, s, True);
   // A later edit must never leak into the preceding takeoff/landing information.
   Page('TAKEOFF REF');
   Row(1, ' FLAPS');
   Row(2, '25');
   Parse;
   Save(30);
   Form := TfrmTripInfo.Create(Nil);
   Form.LoadTrip(DB.Connection, Trip);
   Check(Pos('Klapy start: 15 deg', Form.mInfo.Text) > 0, 'Takeoff flap information');
   Check(Pos('Klapy start: 25 deg', Form.mInfo.Text) = 0, 'No future flap edit in event views');
   Check(Pos('Klapy ladowanie: 40 deg', Form.mInfo.Text) > 0, 'Landing flap information');
   Check(Pos('VREF: 137 kt', Form.mInfo.Text) > 0, 'VREF in trip information');
   Check(Pos('CG start: 22.1 %', Form.mInfo.Text) > 0, 'CG in trip information');
   Check(Pos('Trim start: 3.95 units', Form.mInfo.Text) > 0, 'Trim in trip information');
   Check(Pos('Tryb start aktywny: TO', Form.mInfo.Text) > 0, 'Active mode in trip information');
   DB.DeleteTrip(Trip);
  Finally
   Form.Free;
   s.Free;
   j.Free;
   Screen.Free;
   DB.Free;
   DeleteFile(PChar(Path));
  End;
  System.Writeln('PASS: Boeing performance pages, ACT/SEL sides, derate versus bump, assumed temperature versus OAT, N1, flaps/CG/trim, PERF INIT display units and trip information as of each contact. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyBoeingFMCTests);

End.
