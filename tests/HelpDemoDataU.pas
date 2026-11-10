Unit HelpDemoDataU;

Interface

 Uses
  FlightDatabaseU;

 Procedure SetHelpValue(Plot : TTripPlot; Const Name : String; Value : Double);
 Procedure PrepareHelpDemo(Plot : TTripPlot; Airbus : Boolean);

Implementation

 Uses
  System.SysUtils, System.Math;

 Procedure SetHelpValue(Plot : TTripPlot; Const Name : String; Value : Double);
  Var
   k   : Integer;
   i   : Integer;
   Old : Integer;
   j   : Integer;
   p   : TPlotPoint;
  Begin
   k := Plot.Labels.IndexOf(Name);
   If k < 0 Then
    k    := Plot.Labels.Add(Name);
   For i := 0 To Plot.Points.Count - 1 Do
    Begin
     p   := Plot.Points[i];
     Old := Length(p.Values);
     SetLength(p.Values, Plot.Labels.Count);
     For j          := Old To High(p.Values) Do
      p.Values[j]   := NaN;
     p.Values[k]    := Value;
     Plot.Points[i] := p;
    End;
   Plot.ClearDisplayPoint;
  End;

 Function ARINC(Value : Single) : Double;
  Var
   Bits : Cardinal;
  Begin
   Move(Value, Bits, 4);
   Result := UInt64(Bits) + (UInt64(3) Shl 32);
  End;

 Procedure PrepareHelpDemo(Plot : TTripPlot; Airbus : Boolean);
  Var
   e : Integer;
   n : String;

   Procedure V(Const Name : String; Value : Double);
    Begin
     SetHelpValue(Plot, Name, Value);
    End;

  Begin
   Plot.FlightNumber := 'FDR101';
   Plot.Registration := 'DEMO';
   Plot.Selcal       := 'AB-CD';
   V('engine_type', 1);
   V('number_of_engines', 2);
   V('plane_heading_degrees_true', 267);
   V('plane_heading_degrees_magnetic', 261);
   V('ambient_wind_direction', 285);
   V('ambient_wind_velocity', 18);
   V('airspeed_true', 155);
   V('ground_velocity', 140);
   V('fuel_total_quantity_weight', 9520 / 0.45359237);
   V('total_weight', 59700 / 0.45359237);
   V('fuel_left_quantity', 240);
   V('fuel_right_quantity', 240);
   V('fuel_tank_left_main_quantity', 3000 / (6.7 * 0.45359237));
   V('fuel_tank_right_main_quantity', 3000 / (6.7 * 0.45359237));
   V('fuel_tank_center_quantity', 3520 / (6.7 * 0.45359237));
   V('fuel_weight_per_gallon', 6.7);
   V('sim_on_ground', 0);
   V('plane_turn_rate', 0.02);
   V('turn_coordinator_ball', 0.1);
   For e := 1 To 2 Do
    Begin
     n := ' #' + IntToStr(e);
     V('general_eng_rpm' + n, 2350);
     V('prop_rpm' + n, 1900);
     V('turb_eng_n1' + n, 84.7);
     V('turb_eng_n2' + n, 92.1);
     V('eng_exhaust_gas_temperature' + n, 650);
     V('eng_oil_pressure' + n, 53 * 144);
     V('eng_oil_temperature' + n, 95);
     V('eng_oil_quantity' + n, 0.82);
     V('turb_eng_fuel_flow_pph' + n, 2100);
     V('turb_eng_vibration' + n, 1.2);
     V('turb_eng_itt' + n, 680);
     V('turb_eng_max_torque_percent' + n, 72);
     V('turb_eng_condition_lever_position' + n, 1);
     V('recip_eng_cylinder_head_temperature' + n, 190);
     V('general_eng_combustion' + n, 1);
    End;
   If Airbus Then
    Begin
     Plot.AircraftTypeICAO := 'A20N';
     Plot.AircraftTitle    := 'FlyByWire A32NX DEMO';
     V('airspeed_indicated', 145);
     V('indicated_altitude', 3720);
     V('plane_pitch_degrees', -3);
     V('plane_bank_degrees', 0);
     V('heading_indicator', 261);
     V('vertical_speed', 800);
     V('kohlsman_setting_mb', 1013);
     V('autopilot_master', 1);
     V('autopilot_flight_director_active', 1);
     V('autothrottle_active', 1);
     V('autopilot_altitude_lock_var', 5000);
     V('autopilot_airspeed_hold_var', 145);
     V('radio_height', 2310);
     V('hsi_cdi_needle', 63.5);
     V('hsi_cdi_valid', 1);
     V('hsi_has_localizer', 1);
     V('hsi_gsi_needle', -59.5);
     V('hsi_gsi_valid', 1);
     V('gps_drives_nav1', 0);
     V('FBWLVar.A32NX_ECAM_SD_PAGE_TO_DISPLAY', 0);
     V('FBWLVar.A32NX_ECAM_SD_CURRENT_PAGE_INDEX', 5);
     V('FBWLVar.A32NX_ENGINE_N1:1', 19.7);
     V('turb_eng_n1 #1', 90);
     V('FBWLVar.A32NX_ENGINE_N1:2', 19.8);
     V('FBWLVar.A32NX_ENGINE_N2:1', 68.2);
     V('FBWLVar.A32NX_ENGINE_N2:2', 68.1);
     V('FBWLVar.A32NX_ENGINE_EGT:1', 518);
     V('FBWLVar.A32NX_ENGINE_EGT:2', 507);
     V('FBWLVar.A32NX_ENGINE_FF:1', 320);
     V('FBWLVar.A32NX_ENGINE_FF:2', 300);
     V('fuel_total_quantity_weight', 9520 / 0.45359237);
     V('total_weight', 59700 / 0.45359237);
     V('ambient_temperature', 12);
     V('total_air_temperature', 14);
     V('eng_oil_quantity #1', 0.8);
     V('eng_oil_quantity #2', 0.79);
     V('eng_oil_pressure #1', 53 * 144);
     V('eng_oil_pressure #2', 52 * 144);
     V('eng_oil_temperature #1', 91);
     V('eng_oil_temperature #2', 107);
     V('FBWLVar.A32NX_FUEL_USED:1', 4);
     V('FBWLVar.A32NX_FUEL_USED:2', 9);
     V('FBWLVar.A32NX_HYD_GREEN_SYSTEM_1_SECTION_PRESSURE', 3000);
     V('FBWLVar.A32NX_HYD_BLUE_SYSTEM_1_SECTION_PRESSURE', 3000);
     V('FBWLVar.A32NX_HYD_YELLOW_SYSTEM_1_SECTION_PRESSURE', 3000);
     V('FBWLVar.A32NX_APU_N', ARINC(100));
     V('FBWLVar.A32NX_APU_EGT', ARINC(415));
     V('FBWLVar.A32NX_PRESS_CPC_1_DISCRETE_WORD', ARINC(1024));
     V('FBWLVar.A32NX_PRESS_CPC_1_CABIN_ALTITUDE', ARINC(1285));
     V('FBWLVar.A32NX_PRESS_CPC_1_CABIN_DELTA_PRESSURE', ARINC(0.5));
     V('FBWLVar.A32NX_PRESS_CPC_1_CABIN_VS', ARINC(100));
     V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_1', ARINC((1 Shl 21) Or (1 Shl 19)));
     V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_2', ARINC(1 Shl 13));
     V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_3', ARINC(1 Shl 19));
     V('FBWLVar.A32NX_FM1_MINIMUM_DESCENT_ALTITUDE', ARINC(3500));
     V('FBWLVar.A32NX_FCU_LEFT_EIS_DISCRETE_WORD_2', ARINC(1 Shl 27));
     V('FBWLVar.A32NX_FCU_AFS_DISPLAY_MACH_MODE', 1);
     V('FBWLVar.A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE', 0.78);
     V('FBWLVar.A32NX_FMGC_1_PITCH_FD_COMMAND', ARINC( -4));
     V('FBWLVar.A32NX_FMGC_1_ROLL_FD_COMMAND', ARINC(10));
     V('FBWLVar.A32NX_FMGC_1_DISCRETE_WORD_4', ARINC((1 Shl 11) Or (1 Shl 12) Or (1 Shl 24)));
     V('FBWLVar.A32NX_FMGC_1_ATS_DISCRETE_WORD', ARINC(0));
     V('FBWLVar.A32NX_FMGC_2_DISCRETE_WORD_4', ARINC((1 Shl 11) Or (1 Shl 12)));
     V('FBWLVar.A32NX_FMGC_2_ATS_DISCRETE_WORD', ARINC(0));
     V('FBWLVar.A32NX_FCU_ATS_DISCRETE_WORD', ARINC((1 Shl 12) Or (1 Shl 13)));
     V('FBWLVar.A32NX_FCU_ATS_FMA_DISCRETE_WORD', ARINC(1 Shl 18));
     V('FBWLVar.A32NX_FCU_DISCRETE_WORD_2', ARINC(0));
     V('FBWLVar.A32NX_Ewd_LOWER_LEFT_LINE_1', 260001001);
     V('FBWLVar.A32NX_Ewd_LOWER_LEFT_LINE_2', 260001002);
     V('FBWLVar.A32NX_Ewd_LOWER_RIGHT_LINE_1', 20001);
     V('brake_parking_indicator', 1);
     V('spoilers_armed', 1);

     For e := 1 To 2 Do
      Begin
       n := IntToStr(e);
       V('FBWLVar.A32NX_ELEC_BAT_' + n + '_POTENTIAL', 28);
       V('FBWLVar.A32NX_ELEC_BAT_' + n + '_CURRENT', 4);
       V('FBWLVar.A32NX_ELEC_ENG_GEN_' + n + '_POTENTIAL', 115);
       V('FBWLVar.A32NX_ELEC_ENG_GEN_' + n + '_FREQUENCY', 400);
       V('FBWLVar.A32NX_PNEU_ENG_' + n + '_REGULATED_TRANSDUCER_PRESSURE', 32);
       V('FBWLVar.A32NX_PNEU_ENG_' + n + '_PRECOOLER_OUTLET_TEMPERATURE', 199);
       V('FBWLVar.A32NX_REPORTED_BRAKE_TEMPERATURE_' + n, ARINC(95));
       V('FBWLVar.A32NX_REPORTED_BRAKE_TEMPERATURE_' + IntToStr(e + 2), ARINC(98));
      End;
     V('FBWLVar.A32NX_COND_PACK_FLOW', 1.0);
     V('FBWLVar.A32NX_ELEC_APU_GEN_1_POTENTIAL', 115);
     V('FBWLVar.A32NX_ELEC_APU_GEN_1_FREQUENCY', 400);
     V('FBWLVar.APU_BLEED_PRESSURE', 35);
     V('FBWLVar.A32NX_APU_FLAP_OPEN_PERCENTAGE', 100);
     V('FBWLVar.A32NX_HYD_GREEN_RESERVOIR_LEVEL', 0.80);
     V('FBWLVar.A32NX_HYD_BLUE_RESERVOIR_LEVEL', 0.79);
     V('FBWLVar.A32NX_HYD_YELLOW_RESERVOIR_LEVEL', 0.82);
     V('FBWLVar.A32NX_COND_CKPT_TEMP', 24);
     V('FBWLVar.A32NX_COND_FWD_TEMP', 23);
     V('FBWLVar.A32NX_COND_AFT_TEMP', 23);
     V('FBWLVar.A32NX_COND_CKPT_DUCT_TEMP', 25);
     V('FBWLVar.A32NX_COND_FWD_DUCT_TEMP', 24);
     V('FBWLVar.A32NX_COND_AFT_DUCT_TEMP', 24);
     V('gear_position_0', 1);
     V('gear_position_1', 1);
     V('gear_position_2', 1);
     V('elevator_trim_position', 0.5);
     V('aileron_left_deflection_pct', 0.1);
     V('aileron_right_deflection_pct', -0.1);
     V('rudder_deflection_pct', 0.05);
    End
   Else
    Begin
     Plot.AircraftTypeICAO := 'B38M';
     Plot.AircraftTitle    := 'iFly 737 MAX 8 DEMO';
     V('iFlySDK.Transponder_Windows_Digital_1000_Status', 4);
     V('iFlySDK.Transponder_Windows_Digital_100_Status', 2);
     V('iFlySDK.Transponder_Windows_Digital_10_Status', 1);
     V('iFlySDK.Transponder_Windows_Digital_1_Status', 3);
     V('airspeed_indicated', 285);
     V('plane_pitch_degrees', -3);
     V('plane_bank_degrees', 0);
     V('indicated_altitude', 8020);
     V('heading_indicator', 351);
     V('vertical_speed', -677);
     V('kohlsman_setting_mb', 1013);
     V('autopilot_master', 1);
     V('autopilot_flight_director_active', 1);
     V('autothrottle_active', 1);
     V('autopilot_airspeed_hold_var', 290);
     V('autopilot_altitude_lock_var', 18000);
     V('autopilot_heading_lock_dir', 290);
     V('hsi_cdi_needle', 63.5);
     V('hsi_cdi_valid', 1);
     V('hsi_has_localizer', 1);
     V('hsi_gsi_needle', -59.5);
     V('hsi_gsi_valid', 1);
     V('gps_drives_nav1', 0);
     V('iFlySDK.FD_1_Switch_Status', 1);
     V('iFlySDK.CMD_A_Switch_Status', 2);
     V('iFlySDK.LNAV_Switch_Status', 2);
     V('iFlySDK.VNAV_Switch_Status', 2);
     V('iFlySDK.AT_Switch_Status', 1);
     V('iFlySDK.N1_Switch_Status', 2);
     V('autopilot_flight_director_pitch', DegToRad( -8));
     V('autopilot_flight_director_bank', DegToRad( -10));
     V('incidence_alpha', DegToRad(2.4));
     V('sim_on_ground', 0);
     V('ground_velocity', 280);
     V('airspeed_true', 310);
     V('plane_heading_degrees_true', 351);
     V('iFlySDK.VORADF_L_Status[0]', 0);
     V('iFlySDK.VORADF_R_Status[0]', 2);
     V('nav_active_frequency_1', 117.6);
     V('nav_has_dme_1', 1);
     V('nav_dme_1', 56.2);
     V('adf_active_frequency_2', 350.5);
     V('ambient_wind_direction', 276);
     V('ambient_wind_velocity', 57);
     V('iFlySDK.Transponder_Windows_Digital_1000_Status', 0);
     V('iFlySDK.Transponder_Windows_Digital_100_Status', 4);
     V('iFlySDK.Transponder_Windows_Digital_10_Status', 2);
     V('iFlySDK.Transponder_Windows_Digital_1_Status', 1);
     V('radio_height', 1200);
     V('airspeed_mach', 0.498);
    End;
  End;

End.
