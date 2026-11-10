Program CaptureHelpScreenshots;
{$APPTYPE CONSOLE}

Uses
 TestPathsU, HelpScreenshotU                 In 'HelpScreenshotU.pas', Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.Math,
 System.IOUtils, System.IniFiles, System.JSON, Vcl.Forms, Vcl.Controls, Vcl.Graphics,
 Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
 LocalizationU, frmSettingsU, frmMainU, frmChartsConfigureU, frmWeatherU, frmReportU,
 frmDockViewU, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, ParameterNamesU,
 FlightPlanU, SimBriefImportU, HelpDemoDataU In 'HelpDemoDataU.pas', InstrumentDataU, Boeing737PFDU,
 fraPFD737U, fraB38MEICASU, fraA320PFDU, fraA320ECAMU, fraEnginesU, fraSixPackU,
 fraFMCU, MetarDecodeU, FireDAC.Comp.Client;
{ FLD+ }

Const
 Languages : Array[0..3] Of String =
  (
   'pl-PL',
   'en-US',
   'de-DE',
   'es-ES'
  );
 EcamPages : Array[0..12] Of String =
  (
   'engine',
   'bleed',
   'press',
   'elec',
   'hyd',
   'fuel',
   'apu',
   'cond',
   'door',
   'wheel',
   'fctl',
   'sts',
   'cruise'
  );
 GenericModes : Array[0..3] Of String =
  (
   'sixpack',
   'ga-glass',
   'airliner-classic',
   'generic-pfd'
  );
 EngineModes : Array[0..2] Of String =
  (
   'engine-piston',
   'engine-turboprop',
   'engine-jet'
  );
 EngineTypes : Array[0..2] Of Integer =
  (
   0,
   5,
   1
  );
{ FLD- }

Var
 Folder : String;
 Lang   : String;
 Code   : String;
 Plot   : TTripPlot;
 DemoID : Integer;

Procedure SaveControl(Control : TWinControl; Const Name : String);
 Var
  b : TBitmap;
  p : TPngImage;
 Begin
  Application.ProcessMessages;
  b := TBitmap.Create;
  p := TPngImage.Create;
  Try
   b.SetSize(Control.Width, Control.Height);
   Control.PaintTo(b.Canvas, 0, 0);
   p.Assign(b);
   p.SaveToFile(Folder + Code + '-' + Name + '.png');
  Finally
   p.Free;
   b.Free;
  End;
 End;

Procedure SaveWindow(Form : TForm; Const Name : String);
 Var
  b : TBitmap;
  p : TPngImage;
 Begin
  Form.Position := poDesigned;
  Form.Left     := -10000;
  Form.Top      := 0;
  If Not Form.Visible Then
   Form.Show;
  Application.ProcessMessages;
  b := CaptureHelpWindow(Form);
  p := TPngImage.Create;
  Try
   p.Assign(b);
   p.SaveToFile(Folder + Code + '-' + Name + '.png');
  Finally
   p.Free;
   b.Free;
  End;
 End;

Procedure AddFMC(DB : TFlightDatabase; Trip : Integer; Const Provider : String);
 Var
  Device : Integer;
  Raw    : String;
 Begin
  For Device := 0 To 1 Do
   Begin
    If Provider = 'FBWA32NX' Then
     Raw := '       INIT        1/2' + sLineBreak +
     ' CO RTE       FROM/TO' + sLineBreak +
     ' DEMO       EPLL/EPLL' + sLineBreak +
     ' ALTN/CO RTE    FLT NBR' + sLineBreak +
     ' ----          FDR101' + sLineBreak +
     ' LAT            LONG' + sLineBreak +
     ' 51.72N       019.40E' + sLineBreak +
     ' COST INDEX    CRZ FL' + sLineBreak +
     ' 25             330' + sLineBreak +
     ' TROPO          TEMP' + sLineBreak +
     ' 36090          -45' + sLineBreak +
     ' IRS INIT>           ' + sLineBreak +
     '<RETURN              '
    Else
     Raw := '     PERF INIT      1/2' + sLineBreak +
     ' GW/CRZ CG      CRZ ALT' + sLineBreak +
     ' 66.2/23.0       FL330' + sLineBreak +
     ' PLAN/FUEL    CRZ WIND' + sLineBreak +
     ' 7.6          270/020' + sLineBreak +
     ' ZFW             ISA' + sLineBreak +
     ' 58.6              0' + sLineBreak +
     ' RESERVES       T/C OAT' + sLineBreak +
     ' 2.5             -45' + sLineBreak +
     ' COST INDEX    TRANS ALT' + sLineBreak +
     ' 25               6000' + sLineBreak +
     '              TRIP/CRZ' + sLineBreak +
     '<INDEX        N1 LIMIT>';
    DB.Connection.ExecSQL('insert into trip_fmc_screens(trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json,style_json,annunciators_js' +
    'on,formatted_html) values(:t,1,:u,:u,:p,:d,''DEMO'',''DEMO'',1,1,:raw,''{}'',''{}'',''{"EXEC":1,"MSG":0}'','''')', [Trip, '2026-10-12T00:00:00Z', Provider, IntToStr(Device), Raw]);
   End;
 End;

Procedure Seed;
 Var
  DB       : TFlightDatabase;
  s        : TFlightSample;
  i        : Integer;
  j        : Integer;
  e        : Integer;
  Plan     : TFlightPlan;
  LegIndex : Integer;
  Fraction : Double;
  UTC      : String;
  Altitude : Double;
  IAS      : Double;
  VS       : Double;
  N1       : Double;
  Phase    : Double;
  Progress : Double;

  Procedure N(Const Name : String; v : Double);
   Var
    k : Integer;
   Begin
    For k := 0 To FieldCount - 1 Do
     If SimFields[k].Name = Name Then
      Begin
       s.Numbers[k] := v;
       Exit;
      End;
   End;

  Procedure Text(Const Name, Value : String);
   Var
    k : Integer;
   Begin
    For k := 0 To FieldCount - 1 Do
     If SimFields[k].Name = Name Then
      Begin
       s.Texts[k] := Value;
       Exit;
      End;
   End;

  Procedure GSX(Const Name : String; Value : Double);
   Var
    Fields : TJSONObject;
    Pair   : TJSONPair;
   Begin
    Fields := s.GSXData.GetValue('fields') As TJSONObject;
    Pair   := Fields.RemovePair(Name);
    Pair.Free;
    Fields.AddPair(Name, TJSONNumber.Create(Value));
   End;

 Begin
  DB := TFlightDatabase.Create(TestDataDirectory + 'flight_data.db', TestRuntimeFile('sqlite3.dll'));
  s  := TFlightSample.Create;
  Try
   Text('title', 'iFly 737 MAX 8 DEMO');
   Text('atc_type', 'B38M');
   Text('atc_id', 'DEMO');
   Text('atc_flight_number', 'FDR101');
   N('time_zulu.year', 2026);
   N('time_zulu.month', 10);
   N('time_zulu.day', 12);
   N('time_local.year', 2026);
   N('time_local.month', 10);
   N('time_local.day', 12);
   N('number_of_engines', 2);
   N('engine_type', 1);
   N('kohlsman_setting_mb', 1013);
   N('autopilot_master', 1);
   N('autopilot_flight_director_active', 1);
   N('autothrottle_active', 1);
   N('autopilot_airspeed_hold_var', 180);
   N('autopilot_altitude_lock_var', 5000);
   N('autopilot_heading_lock_dir', 80);
   N('fuel_total_quantity_weight', 16000);
   N('total_weight', 145000);
   N('ambient_temperature', 12);
   N('total_air_temperature', 14);
   s.GSXData := TJSONObject.ParseJSONValue('{"provider":"GSXPro","fields":{"FSDT_GSX_BOARDING_STATE":5,"FSDT_GSX_NUMPASSENGERS_BOARDING_TOTAL":74,"FSDT_GSX_NUMPASSENGERS":145,"FSDT_GSX_BOARDING_CARGO_PERC' +
   'ENT":65,"FSDT_GSX_REFUELING_STATE":5,"FSDT_GSX_FUEL_COUNTER":2500,"FSDT_GSX_FUEL_COUNTER_MAX":5000,"FSDT_GSX_CATERING_STATE":6}}') As TJSONObject;
   For e := 0 To 1 Do
    Begin
     N('eng_combustion[' + IntToStr(e) + ']', 1);
     N('turb_eng_n1[' + IntToStr(e) + ']', 84.7);
     N('turb_eng_n2[' + IntToStr(e) + ']', 92);
     N('eng_exhaust_gas_temperature[' + IntToStr(e) + ']', 650);
     N('eng_oil_pressure[' + IntToStr(e) + ']', 53 * 144);
     N('eng_oil_temperature[' + IntToStr(e) + ']', 95);
     N('turb_eng_fuel_flow_pph[' + IntToStr(e) + ']', 2100);
    End;
   Plan   := ParsePLN(TFile.ReadAllText(TestRepositoryPath('help\demo-route.pln'), TEncoding.UTF8), 'DEMO.pln');
   DemoID := DB.StartTrip(s, 20000);
   For j  := 0 To 119 Do
    Begin
     N('time_zulu.seconds', j * 20);
     N('time_local.seconds', j * 20);
     Progress := EnsureRange((j - 10) / 90, 0.0, 1.0);
     Fraction := Progress * (Plan.Points.Count - 1);
     LegIndex := Min(Trunc(Fraction), Plan.Points.Count - 2);
     Fraction := Fraction - LegIndex;
     N('plane_coordinate.latitude', Plan.Points[LegIndex].Lat + Fraction * (Plan.Points[LegIndex + 1].Lat - Plan.Points[LegIndex].Lat));
     N('plane_coordinate.longitude', Plan.Points[LegIndex].Lon + Fraction * (Plan.Points[LegIndex + 1].Lon - Plan.Points[LegIndex].Lon));
     Altitude := 607;
     IAS      := 0;
     VS       := 0;
     N1       := 22;
     If j < 10 Then
      IAS := j * 1.2
     Else If j < 39 Then
      Begin
       Phase    := (j - 10) / 29;
       Altitude := 607 + 12393 * Phase;
       IAS      := 160 + 90 * Phase;
       VS       := 1280;
       N1       := 89;
      End
     Else If j < 70 Then
      Begin
       Altitude := 13000;
       IAS      := 250;
       N1       := 78;
      End
     Else If j < 100 Then
      Begin
       Phase    := (j - 70) / 30;
       Altitude := 13000 - 12393 * Phase;
       IAS      := 240 - 95 * Phase;
       VS       := -1240;
       N1       := 45;
      End
     Else
      Begin
       IAS := Max(0, 145 - (j - 100) * 9);
       N1  := 24;
      End;
     If j = 100 Then
      Begin
       IAS := 145;
       VS  := -120;
      End;
     N('plane_altitude', Altitude);
     N('indicated_altitude', Altitude);
     N('radio_height', Max(0, Altitude - 607));
     N('vertical_speed', VS);
     N('airspeed_indicated', IAS);
     N('ground_velocity', Max(0, IAS - 7));
     N('airspeed_true', IAS * 1.08);
     N('heading_indicator', 245 + 10 * Sin(j / 7));
     If (j < 10) Or (j >= 100) Then
      N('heading_indicator', 245);
     N('plane_heading_degrees_magnetic', 245 + 10 * Sin(j / 7));
     N('plane_heading_degrees_true', 251 + 10 * Sin(j / 7));
     N('plane_pitch_degrees', -VS / 160);
     N('plane_bank_degrees', 8 * Sin(j / 9));
     If j = 100 Then
      Begin
       N('plane_pitch_degrees', -2.6);
       N('plane_bank_degrees', 0.7);
      End;
     N('g_force', 1 + 0.025 * Sin(j / 5));
     If j = 100 Then
      N('g_force', 1.18);
     N('ambient_wind_direction', 270);
     N('ambient_wind_velocity', 8);
     N('fuel_total_quantity_weight', (7600 - j * 12) / 0.45359237);
     N('total_weight', (66000 - j * 12) / 0.45359237);
     N('sim_on_ground', Ord((j < 10) Or (j >= 100)));
     N('autopilot_master', Ord((j > 15) And (j < 97)));
     N('autopilot_flight_director_active', Ord((j >= 10) And (j < 101)));
     N('autothrottle_active', Ord((j >= 10) And (j < 100)));
     N('gear_handle_position', Ord((j < 13) Or (j >= 89)));
     N('gear_position_0', Ord((j < 13) Or (j >= 89)));
     N('gear_position_1', Ord((j < 13) Or (j >= 89)));
     N('gear_position_2', Ord((j < 13) Or (j >= 89)));
     N('flaps_handle_index', 0);
     If j < 18 Then
      N('flaps_handle_index', 3);
     If j >= 82 Then
      N('flaps_handle_index', Min(8, 3 + (j - 82) Div 3));
     N('spoilers_armed', Ord(j >= 89));
     N('spoilers_handle_position', Ord(j >= 100));
     N('brake_parking_indicator', Ord((j < 2) Or (j >= 117)));
     N('brake_indicator', Ord(j >= 100) * 0.45);
     For e := 0 To 1 Do
      Begin
       N('turb_eng_n1[' + IntToStr(e) + ']', N1 + e * 0.3);
       N('turb_eng_n2[' + IntToStr(e) + ']', 60 + N1 * 0.35);
       N('eng_exhaust_gas_temperature[' + IntToStr(e) + ']', 350 + N1 * 3);
       N('turb_eng_fuel_flow_pph[' + IntToStr(e) + ']', 400 + N1 * 20);
      End;
     GSX('FSDT_GSX_BOARDING_STATE', 6);
     If j = 0 Then
      GSX('FSDT_GSX_BOARDING_STATE', 4)
     Else If j < 6 Then
      GSX('FSDT_GSX_BOARDING_STATE', 5);
     GSX('FSDT_GSX_NUMPASSENGERS_BOARDING_TOTAL', Min(145, j * 29));
     GSX('FSDT_GSX_BOARDING_CARGO_PERCENT', Min(100, j * 20));
     GSX('FSDT_GSX_REFUELING_STATE', 6);
     If j = 0 Then
      GSX('FSDT_GSX_REFUELING_STATE', 4)
     Else If j < 8 Then
      GSX('FSDT_GSX_REFUELING_STATE', 5);
     GSX('FSDT_GSX_FUEL_COUNTER', Min(5000, j * 625));
     DB.RecordSample(DemoID, s);
     If j = 10 Then
      DB.Contact(DemoID, s, False);
     If j = 100 Then
      DB.Contact(DemoID, s, True);
    End;
   DB.EndTrip(DemoID, s);
   DB.Connection.ExecSQL('update trips set departure_icao=''EPLL'',destination_icao=''EPLL''');
   DB.Event(DemoID, 'DEMO: flight prepared', '2026-10-12T00:00:00Z', '2026-10-12T00:00:00Z', 1);
   DB.Event(DemoID, 'DEMO: initial climb', '2026-10-12T00:03:20Z', '2026-10-12T00:03:20Z', 2);
   DB.Connection.ExecSQL('update trip_liftoffs set icao=''EPLL''');
   DB.Connection.ExecSQL('update trip_touchdowns set icao=''EPLL''');
   DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:u,:u,''RadioMessagesData'',:p)', [DemoID, '2026-10-12T00:00:01Z', '{"MessageItems":[{"Id":"DEMO1","Message":"FDR101, CLEARED TO LODZ, CLIMB 5000 FEET, SQUAWK 4213","Frequency":"120.005"}]}']);
   DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:u,:u,''NativeATCLine'',:p)', [DemoID, '2026-10-12T00:00:15Z', '{"Id":"DEMO2","Message":"[MSFS ATC] FDR101, WIND 270 AT 8, RUNWAY 25 CLEARED FOR TAKEOFF"}']);

   Try
    DB.SaveFlightPlan(DemoID, Plan);
   Finally
    Plan.Free;
   End;
   DB.Event(DemoID, 'DEMO: top of climb', '2026-10-12T00:13:00Z', '2026-10-12T00:13:00Z', 3);
   DB.Event(DemoID, 'DEMO: descent', '2026-10-12T00:23:20Z', '2026-10-12T00:23:20Z', 4);
   DB.Event(DemoID, 'DEMO: gear down / approach', '2026-10-12T00:29:40Z', '2026-10-12T00:29:40Z', 5);
   DB.Event(DemoID, 'DEMO: touchdown', '2026-10-12T00:33:20Z', '2026-10-12T00:33:20Z', 6);
   DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:u,:u,''NativeATCLine'',:p)', [DemoID, '2026-10-12T00:06:25Z', '{"Id":"DEMO3","Message":"[MSFS ATC] FDR101, CLIMB FL130, CONTINUE ADOX2W"}']);
   DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:u,:u,''NativeATCLine'',:p)', [DemoID, '2026-10-12T00:23:20Z', '{"Id":"DEMO4","Message":"[MSFS ATC] FDR101, DESCEND 3000 FEET, QNH 1013, EXPECT ILS Z RUNWAY 25"}']);
   DB.Connection.ExecSQL('insert into trip_fshud_messages(trip,captured_utc,sim_utc,message_type,payload) values(:t,:u,:u,''NativeATCLine'',:p)', [DemoID, '2026-10-12T00:30:00Z', '{"Id":"DEMO5","Message":"[MSFS ATC] FDR101, WIND 270 AT 8, RUNWAY 25 CLEARED TO LAND"}']);
   AddFMC(DB, DemoID, 'iFly737MAX');
   Plot := DB.LoadTrip(DemoID);
  Finally
   s.Free;
   DB.Free;
  End;
 End;

Procedure FullCatalog(Const LanguageCode : String; Available : TStrings);
 Var
  i    : Integer;
  e    : Integer;
  Name : String;
  Rows : TJSONArray;
  Row  : TJSONObject;

  Procedure Add(Const Raw : String);
   Begin
    If Available.IndexOf(Raw) < 0 Then
     Available.Add(Raw);
   End;

 Begin
  Available.Clear;
  For i := 0 To High(NumericColumns) Do
   Add(NumericColumns[i].Name);
  For i := 0 To High(BooleanColumns) Do
   Add(BooleanColumns[i].Name);
  For i  := 0 To High(EngineColumns) Do
   For e := 1 To 4 Do
    Add(EngineColumns[i].Name + ' #' + IntToStr(e));
  Rows := TJSONArray.Create;
  Try
   For i := 0 To Available.Count - 1 Do
    Begin
     Name := Available[i];
     Row  := TJSONObject.Create;
     Row.AddPair('name', Name);
     Row.AddPair('caption', ParameterCaption(Name));
     Row.AddPair('unit', ParameterDisplayUnit(Name));
     Rows.AddElement(Row);
    End;
   TFile.WriteAllText(TestRepositoryPath('help\simvars.' + LanguageCode + '.json'), Rows.ToJSON, TEncoding.UTF8);
  Finally
   Rows.Free;
  End;
 End;

Procedure Instruments;
 Var
  Host    : TForm;
  Boeing  : TfraPFD737;
  Eicas   : TfraB38MEICAS;
  Airbus  : TfraA320PFD;
  ECAM    : TfraA320ECAM;
  Engines : TfraEngines;
  Generic : TfraSixPack;
  i       : Integer;
  c       : TControl;
 Begin
  Host          := TForm.Create(Nil);
  Host.Position := poDesigned;
  Host.Left     := -10000;
  Host.Show;
  Try
   PrepareHelpDemo(Plot, False);
   InstrumentKindOverride := -1;
   Host.ClientWidth       := 860;
   Host.ClientHeight      := 680;
   Boeing                 := TfraPFD737.Create(Host);
   Boeing.Parent          := Host;
   Boeing.Align           := alClient;
   B38MInfoEnabled        := True;
   B38MAoAEnabled         := True;
   B38MInfoOnLeft         := True;
   Boeing.SetPoint(Plot, 20);
   SaveControl(Boeing, 'b38m-cpt');
   B38MInfoOnLeft := False;
   Boeing.Invalidate;
   SaveControl(Boeing, 'b38m-fo');
   Boeing.Free;
   Host.ClientWidth  := 620;
   Host.ClientHeight := 820;
   Eicas             := TfraB38MEICAS.Create(Host);
   Eicas.Parent      := Host;
   Eicas.Align       := alClient;
   Eicas.SetPoint(Plot, 20);
   SaveControl(Eicas, 'b38m-eicas');
   Eicas.Free;
   For i := 0 To 3 Do
    Begin
     InstrumentKindOverride      := i;
     Plot.AircraftTypeICAO       := 'C172';
     Plot.AircraftTitle          := 'Documentation DEMO';
     Host.ClientWidth            := 900;
     Host.ClientHeight           := 680;
     Generic                     := TfraSixPack.Create(Host);
     Generic.Parent              := Host;
     Generic.Align               := alClient;
     Generic.ShowEmbeddedEngines := False;
     Generic.SetPoint(Plot, 20);
     SaveControl(Generic, GenericModes[i]);
     Generic.Free;
    End;
   InstrumentKindOverride := -1;
   For i                  := 0 To 2 Do
    Begin
     Plot.AircraftTypeICAO := 'C172';
     Plot.AircraftTitle    := 'Engine DEMO';
     SetHelpValue(Plot, 'engine_type', EngineTypes[i]);
     SetHelpValue(Plot, 'number_of_engines', 1 + Ord(i > 0));
     Host.ClientWidth  := 900;
     Host.ClientHeight := 680;
     Engines           := TfraEngines.Create(Host);
     Engines.Parent    := Host;
     Engines.Align     := alClient;
     Engines.SetPoint(Plot, 20);
     SaveControl(Engines, EngineModes[i]);
     Engines.Free;
    End;
   PrepareHelpDemo(Plot, True);
   Host.ClientWidth  := 640;
   Host.ClientHeight := 690;
   Airbus            := TfraA320PFD.Create(Host);
   Airbus.Parent     := Host;
   Airbus.Align      := alClient;
   Airbus.SetPoint(Plot, 20);
   SaveControl(Airbus, 'a320-pfd');
   Airbus.Free;
   Host.ClientWidth  := 660;
   Host.ClientHeight := 1380;
   ECAM              := TfraA320ECAM.Create(Host);
   ECAM.Parent       := Host;
   ECAM.Align        := alClient;
   ECAM.SetPoint(Plot, 20);
   SaveControl(ECAM.UpperDisplay, 'a320-ewd');
   ECAM.PageClick(ECAM.btnRecorded);
   SaveControl(ECAM.LowerDisplay, 'ecam-recorded');
   SaveControl(ECAM.PagePanel, 'ecam-controls');
   For i := 0 To 12 Do
    Begin

     ECAM.LowerDisplay.Page := i;
     SaveControl(ECAM.LowerDisplay, 'ecam-' + EcamPages[i]);
    End;
   ECAM.Free;
  Finally
   Host.Free;
   InstrumentKindOverride := -1;
  End;
 End;

Procedure FMCExamples;
 Var
  Host     : TForm;
  Frame    : TfraFMC;
  DB       : TFlightDatabase;
  s        : TFlightSample;
  Family   : String;
  Provider : String;
  i        : Integer;
  Trip     : Integer;
  { FLD+ }
 Const
  Families : Array[0..2] Of String =
   (
    'B737',
    'A320',
    'B777'
   );
  Providers : Array[0..2] Of String =
   (
    'iFly737MAX',
    'FBWA32NX',
    'PMDG777'
   );
  { FLD- }
 Begin
  For i := 0 To 2 Do
   Begin
    Family   := Families[i];
    Provider := Providers[i];
    DB       := TFlightDatabase.Create(TestDataDirectory + 'fmc-' + Code + '-' + Family + '.db', TestRuntimeFile('sqlite3.dll'));
    s        := TFlightSample.Create;
    Host     := TForm.Create(Nil);
    Try
     Trip := DB.StartTrip(s);
     AddFMC(DB, Trip, Provider);
     Host.ClientWidth  := 470;
     Host.ClientHeight := 790;
     Host.Position     := poDesigned;
     Host.Left         := -10000;
     Host.Show;
     Frame        := TfraFMC.Create(Host);
     Frame.Parent := Host;
     Frame.Align  := alClient;
     Frame.Load(DB.Connection, Trip);
     Frame.SetTime('2026-10-12T00:00:20Z');
     SaveControl(Frame, 'fmc-' + LowerCase(Family));
     Frame.DeviceTabs.TabIndex := 1;
     Frame.DeviceChanged(Frame.DeviceTabs);
     SaveControl(Frame, 'fmc-' + LowerCase(Family) + '-right');
    Finally
     Host.Free;
     s.Free;
     DB.Free;
    End;
   End;
 End;

Procedure DataViews(Main : TfrmMain);
 Var
  i       : Integer;
  View    : TfrmDockView;
  Name    : String;
  Payload : String;
  g       : TGroupBox;
 Begin
  Main.Timeline.Position := 20;
  Main.TimelineChange(Main);
  Application.ProcessMessages;
  For i := 0 To Main.ComponentCount - 1 Do
   If Main.Components[i] Is TfrmDockView Then
    Begin
     View := TfrmDockView(Main.Components[i]);
     Name := '';
     If View.Page = Main.GSXPage Then
      Name := 'gsx';
     If View.Page = Main.PlanPage Then
      Name := 'plan';
     If View.Page = Main.ValuesPage Then
      Name := 'values';
     If View.Page = Main.EventsPage Then
      Name := 'events';
     If View.Page = Main.ContactsPage Then
      Name := 'contacts';
     If View.Page = Main.FSHudPage Then
      Name := 'atc';
     If Name = '' Then
      Continue;
     If Name = 'gsx' Then
      Begin
       Main.Timeline.Position := 3;
       Main.TimelineChange(Main);
      End;
     View.ManualFloat(Rect( -10000, 0, -9000, 700));
     View.ClientWidth  := 1000;
     View.ClientHeight := 650;
     View.FitClient(View);
     If Name = 'gsx' Then
      Begin
       Main.GSXGrid.ColWidths[0] := 430;
       Main.GSXGrid.ColWidths[1] := 540;
      End;
     If Name = 'values' Then
      Begin
       Main.DataGrid.ColWidths[0] := 650;
       Main.DataGrid.ColWidths[1] := 310;
      End;
     SaveWindow(View, Name);
     View.ManualDock(Main.DataTabs, Nil, alClient);
     View.Show;
     If Name = 'gsx' Then
      Begin
       Main.Timeline.Position := 20;
       Main.TimelineChange(Main);
      End;
    End;
  Main.GraphFrame.aGraphWindow.Execute;
  Main.GraphWindow.ClientWidth  := 1000;
  Main.GraphWindow.ClientHeight := 650;
  SaveWindow(Main.GraphWindow, 'charts-view');
  Main.GraphWindow.Close;
  Main.MapFrame.aMapWindow.Execute;
  Main.MapWindow.ClientWidth  := 1000;
  Main.MapWindow.ClientHeight := 650;
  For i                       := 1 To 80 Do
   Begin
    Application.ProcessMessages;
    Sleep(100);
   End;
  SaveWindow(Main.MapWindow, 'map-view');
  Main.MapWindow.Close;
  Main.SimBriefFrame.ReadOnly := True;
  Payload                     := TFile.ReadAllText(TestRepositoryPath('help\demo-simbrief.json'), TEncoding.UTF8);
  Main.SimBriefFrame.LoadPayload(Payload, 'DEMO');
  Main.SimBriefFrame.aWindow.Execute;
  Main.SimBriefWindow.ClientWidth  := 1000;
  Main.SimBriefWindow.ClientHeight := 800;
  Main.SimBriefFrame.ResizeCards(Nil);
  Main.SimBriefFrame.Sections.VertScrollBar.Position := 0;
  SaveControl(Main.SimBriefFrame.Sections, 'simbrief');
  g := Main.SimBriefFrame.FindComponent('SB_ofp') As TGroupBox;
  If g <> Nil Then
   Begin
    If g.Height < 100 Then
     If g.Controls[0] Is TButton Then
      TButton(g.Controls[0]).Click;
    Main.SimBriefFrame.Sections.VertScrollBar.Position := g.Top;
    SaveControl(Main.SimBriefFrame.Sections, 'simbrief-ofp');
   End;
  Main.SimBriefWindow.Close;
  Main.FMCFrame.aWindow.Execute;
  Main.FMCWindow.ClientWidth  := 470;
  Main.FMCWindow.ClientHeight := 790;
  SaveWindow(Main.FMCWindow, 'fmc-view');
  Main.FMCWindow.Close;
 End;

Procedure WeatherAndReport;
 Var
  Weather : TfrmWeather;
  Report  : TfrmReport;
  Text    : String;
  Sim     : String;
  Real    : String;
 Begin
  Weather := TfrmWeather.Create(Nil);
  Try
   Weather.RefreshTimer.Enabled := False;
   Weather.ClientWidth          := 1100;
   Weather.ClientHeight         := 720;
   Weather.Events.Items.Add('EPLL 2026-10-12 00:00 UTC / DEMO');
   Weather.Events.ItemIndex   := 0;
   Sim                        := 'EPLL 120000Z 27008KT 9999 SCT025 12/08 Q1013';
   Real                       := 'EPLL 120000Z 28012G18KT 8000 BKN020 11/07 Q1012';
   Weather.SimulatorMemo.Text := DecodedMetarText(Sim);
   Weather.RealMemo.Text      := DecodedMetarText(Real);
   Weather.CompareMemo.Text   := CompareMetarReports(Sim, Real);
   SaveWindow(Weather, 'weather');
  Finally
   Weather.Free;
  End;
  Text   := TFile.ReadAllText(TestRepositoryPath('help\example-analysis.' + Code + '.txt'), TEncoding.UTF8);
  Report := TfrmReport.Create(Nil);
  Try
   Report.ClientWidth  := 900;
   Report.ClientHeight := 700;
   Report.SetReport(Text, True);
   SaveWindow(Report, 'analysis-report');
   HelpReportText(Report).Perform(EM_LINESCROLL, 0, 20);
   SaveWindow(Report, 'analysis-report-details');
  Finally
   Report.Free;
  End;
 End;

Var
 Settings  : TfrmSettings;
 Main      : TfrmMain;
 Charts    : TfrmChartsConfigure;
 Config    : TMemIniFile;
 Available : TStringList;
 Selected  : TStringList;
 Page      : Integer;
 Provider  : Integer;
 Handled   : Boolean;
 Warmup    : TBitmap;

Begin
 Application.Initialize;
 Folder := TestRepositoryPath('help\images\');
 ForceDirectories(Folder);
 Seed;
 For Lang In Languages Do
  Begin
   SetLanguage(Lang);
   Code := Copy(Lang, 1, 2);
   System.Writeln('CAPTURE ' + Code);
   Instruments;
   FMCExamples;
   WeatherAndReport;
   Config := TMemIniFile.Create(TestDataDirectory + Code + '-settings.ini');
   Config.WriteString('ui', 'language', Lang);
   Settings := TfrmSettings.Create(Nil);
   Try
    Settings.Load(Config);
    Settings.OnShow              := Nil;
    Settings.ModelsTimer.Enabled := False;
    For Page                     := 0 To Settings.SettingsPages.PageCount - 1 Do
     Begin
      Settings.SettingsPages.ActivePageIndex := Page;
      If Settings.SettingsPages.ActivePage = Settings.AIPage Then
       For Provider := 0 To Settings.ProviderPages.PageCount - 1 Do
        Begin
         Settings.ProviderPages.ActivePageIndex := Provider;
         Settings.cbProvider.ItemIndex          := Provider;
         SaveWindow(Settings, 'settings-ai-' + IntToStr(Provider));
        End
      Else
       SaveWindow(Settings, 'settings-' + LowerCase(Settings.SettingsPages.Pages[Page].Name));
     End;
   Finally
    Settings.Free;
    Config.Free;
   End;
   Config := TMemIniFile.Create(TestDataDirectory + 'settings.ini');
   Try
    Config.Clear;
    Config.WriteString('ui', 'language', Lang);
    Config.UpdateFile;
   Finally
    Config.Free;
   End;
   Main := TfrmMain.Create(Nil);
   Try
    SetLanguage(Lang);
    Main.Timer.Enabled         := False;
    Main.PlaybackTimer.Enabled := False;
    Main.aTiles.Checked        := True;
    Main.aTilesExecute(Main.aTiles);
    Main.ClientWidth  := 1280;
    Main.ClientHeight := 800;
    Main.Position     := poDesigned;
    Main.Left         := -10000;
    Main.Show;
    Application.ProcessMessages;
    Main.SelectTrip(Main);
    Main.aFit.Execute;
    Warmup := Main.GetFormImage;
    Warmup.Free;
    For Page := 1 To 80 Do
     Begin
      Application.ProcessMessages;
      Sleep(100);
     End;
    SaveWindow(Main, 'workspace');
    DataViews(Main);
   Finally
    Main.Free;
   End;
   Available := TStringList.Create;
   Selected  := TStringList.Create;
   Charts    := TfrmChartsConfigure.Create(Nil);
   Try
    FullCatalog(Code, Available);
    Selected.Add('plane_altitude');
    Selected.Add('airspeed_indicated');
    Selected.Add('vertical_speed');
    Selected.Add('heading_indicator');
    Selected.Add('autopilot_master');
    Charts.Configure(Available, Selected);
    Charts.ParameterList.ItemIndex  := Min(10, Charts.ParameterList.Items.Count - 1);
    Charts.ChartOrderList.ItemIndex := 2;
    Charts.OrderClick(Charts.ChartOrderList);
    Charts.ActionsUpdate(Charts.aShow, Handled);
    SaveWindow(Charts, 'charts');
    System.Writeln('STANDARD CATALOG ' + Code + ': ' + IntToStr(Available.Count));
   Finally
    Charts.Free;
    Selected.Free;
    Available.Free;
   End;
  End;
 Plot.Free;
 System.Writeln('PASS: detached localized frames, complete instrument/ECAM gallery and standard catalog.');

End.
