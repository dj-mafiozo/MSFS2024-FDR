// Contract: MichaelHsu170/MSFS-Flight-Data-Recorder, commit 63670f84257011693823910b0b94082858e83e1b.
// AGPL-3.0 attribution retained. Telemetry columns permit NULL like upstream migrated databases.
Const
 LegacyTableNames : Array [0..6] Of String = ('trips', 'trip_data', 'trip_engine_data', 'trip_events', 'trip_liftoffs', 'trip_touchdowns', 'trip_groups');
 LegacyTableSQL : Array [0..6] Of String = (
  'CREATE TABLE trips (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,title VARCHAR(256) NOT NULL,atc_airline VARCHAR(64) NOT NULL,atc_flight_number VARCHAR(8) NOT NULL,atc_id V' +
  'ARCHAR(32) NOT NULL,atc_model VARCHAR(32) NOT NULL,atc_type VARCHAR(64) NOT NULL,departure_latitude REAL NOT NULL,departure_longitude REAL NOT NULL,departure_icao VARCHAR(4),depart' +
  'ure_name VARCHAR(64),departure_region VARCHAR(2),departure_rwy VARCHAR(3),departure_zulu_time VARCHAR(32) NOT NULL,departure_local_time VARCHAR(32) NOT NULL,destination_latitude RE' +
  'AL,destination_longitude REAL,destination_icao VARCHAR(4),destination_name VARCHAR(64),destination_region VARCHAR(2),destination_rwy VARCHAR(3),destination_zulu_time VARCHAR(32),de' +
  'stination_local_time VARCHAR(32),group_id INTEGER)',
  'CREATE TABLE trip_data (id INTEGER PRIMARY KEY,trip INTEGER NOT NULL,bool_group_1 INTEGER NOT NULL,bool_group_2 INTEGER NOT NULL,bool_group_3 INTEGER NOT NULL,ambient_temperature I' +
  'NTEGER,autopilot_heading_lock_dir INTEGER,aileron_left_deflection REAL,aileron_right_deflection REAL,aileron_trim REAL,elevator_deflection REAL,elevator_trim_position REAL,elevon_d' +
  'eflection REAL,rudder_deflection REAL,rudder_trim REAL,plane_bank_degrees REAL,plane_heading_degrees_gyro INTEGER,plane_heading_degrees_magnetic INTEGER,plane_heading_degrees_true ' +
  'INTEGER,plane_latitude REAL,plane_longitude REAL,plane_pitch_degrees REAL,plane_touchdown_bank_degrees REAL,plane_touchdown_heading_degrees_magnetic INTEGER,plane_touchdown_heading' +
  '_degrees_true INTEGER,plane_touchdown_latitude REAL,plane_touchdown_longitude REAL,plane_touchdown_pitch_degrees REAL,gps_ground_true_heading INTEGER,gps_ground_true_track INTEGER,' +
  'gps_position_lat REAL,gps_position_lon REAL,gyro_drift_error INTEGER,heading_indicator INTEGER,magnetic_compass INTEGER,ambient_wind_direction INTEGER,gear_position_0 INTEGER,gear_' +
  'position_1 INTEGER,gear_position_2 INTEGER,gear_warning_0 INTEGER,gear_warning_1 INTEGER,gear_warning_2 INTEGER,bleed_air_source_control_1 INTEGER,bleed_air_source_control_2 INTEGE' +
  'R,engine_type INTEGER,fuel_cross_feed_l INTEGER,fuel_cross_feed_r INTEGER,surface_condition INTEGER,surface_type INTEGER,pitot_heat_switch INTEGER,plane_touchdown_normal_velocity I' +
  'NTEGER,vertical_speed INTEGER,autopilot_altitude_lock_var INTEGER,plane_altitude INTEGER,plane_alt_above_ground INTEGER,radio_height INTEGER,indicated_altitude INTEGER,indicated_al' +
  'titude_calibrated INTEGER,pressurization_cabin_altitude INTEGER,autopilot_vertical_hold_var INTEGER,engine_control_select INTEGER,fuel_selected_quantity_l INTEGER,fuel_selected_qua' +
  'ntity_r INTEGER,fuel_total_quantity INTEGER,g_force REAL,ambient_pressure REAL,kohlsman_setting_hg REAL,autopilot_airspeed_hold_var INTEGER,ground_velocity INTEGER,airspeed_indicat' +
  'ed INTEGER,airspeed_true INTEGER,ambient_wind_velocity INTEGER,airspeed_mach REAL,light_states INTEGER,gps_ground_speed INTEGER,gps_position_alt INTEGER,pressure_altitude INTEGER,a' +
  'mbient_visibility INTEGER,barometer_pressure INTEGER,kohlsman_setting_mb INTEGER,autopilot_mach_hold_var REAL,auto_brake_switch_cb INTEGER,flaps_handle_index INTEGER,flaps_num_hand' +
  'le_positions INTEGER,number_of_engines INTEGER,gear_handle_position REAL,aileron_left_deflection_pct REAL,aileron_right_deflection_pct REAL,aileron_trim_pct REAL,elevator_deflectio' +
  'n_pct REAL,elevator_trim_pct REAL,rudder_deflection_pct REAL,rudder_trim_pct REAL,spoilers_handle_position REAL,spoilers_left_position REAL,spoilers_right_position REAL,apu_pct_rpm' +
  ' REAL,apu_pct_starter REAL,fuel_selected_quantity_percent_l REAL,fuel_selected_quantity_percent_r REAL,pitot_ice_pct REAL,autopilot_throttle_max_thrust REAL,electrical_battery_esti' +
  'mated_capacity_pct REAL,brake_indicator INTEGER,empty_weight INTEGER,total_weight INTEGER,fuel_total_quantity_weight INTEGER,fuel_weight_per_gallon REAL,hydraulic_pressure_1 INTEGE' +
  'R,hydraulic_pressure_2 INTEGER,apu_bleed_pressure_received_by_engine INTEGER,wheel_rpm_0 INTEGER,wheel_rpm_1 INTEGER,wheel_rpm_2 INTEGER,electrical_battery_voltage REAL,ambient_pre' +
  'cip_state INTEGER,ambient_precip_rate REAL,sea_level_pressure REAL,velocity_world_y INTEGER,structural_ice_pct REAL,ambient_wind_x REAL,ambient_wind_y REAL,ambient_wind_z REAL,inci' +
  'dence_alpha REAL,incidence_beta REAL,stall_alpha REAL,max_g_force REAL,min_g_force REAL,zulu_time VARCHAR(32) NOT NULL,local_time VARCHAR(32) NOT NULL)',
  'CREATE TABLE trip_engine_data (sample INTEGER NOT NULL,engine INTEGER NOT NULL,trip INTEGER NOT NULL,turb_eng_n1 REAL,turb_eng_n2 REAL,general_eng_rpm REAL,prop_rpm REAL,recip_eng_' +
  'manifold_pressure REAL,turb_eng_max_torque_percent REAL,eng_exhaust_gas_temperature INTEGER,eng_oil_temperature INTEGER,turb_eng_ignition_switch_ex1 INTEGER,general_eng_elapsed_tim' +
  'e REAL,general_eng_throttle_managed_mode REAL,turb_eng_vibration REAL,general_eng_damage_percent REAL,general_eng_throttle_lever_position REAL,turb_eng_fuel_flow_pph INTEGER,genera' +
  'l_eng_fuel_used_since_start INTEGER,eng_hydraulic_pressure INTEGER,eng_oil_pressure INTEGER,turb_eng_bleed_air INTEGER,bleed_air_engine INTEGER,eng_anti_ice INTEGER,eng_combustion ' +
  'INTEGER,eng_failed INTEGER,eng_on_fire INTEGER,general_eng_fire_detected INTEGER,general_eng_fuel_valve INTEGER,general_eng_generator_active INTEGER,general_eng_generator_switch IN' +
  'TEGER,general_eng_starter INTEGER,general_eng_starter_active INTEGER,turb_eng_fuel_available INTEGER,turb_eng_is_igniting INTEGER,PRIMARY KEY (sample, engine)) WITHOUT ROWID',
  'CREATE TABLE trip_events (trip INTEGER NOT NULL,event VARCHAR(32) NOT NULL,time_zulu VARCHAR(32) NOT NULL,time_local VARCHAR(32) NOT NULL,event_seq INTEGER)',
  'CREATE TABLE trip_liftoffs (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,trip INTEGER NOT NULL,airspeed_indicated INTEGER NOT NULL,vertical_speed INTEGER NOT NULL,plane_pit' +
  'ch_degrees REAL NOT NULL,plane_bank_degrees REAL NOT NULL,heading_indicator INTEGER NOT NULL,plane_latitude REAL NOT NULL,plane_longitude REAL NOT NULL,icao VARCHAR(4),airport_name' +
  ' VARCHAR(64),runway VARCHAR(3),runway_heading INTEGER,distance_length REAL,distance_width REAL,distance_length_percent REAL,distance_width_percent REAL,wind_direction INTEGER,wind_' +
  'velocity INTEGER,time_zulu VARCHAR(32) NOT NULL,time_local VARCHAR(32) NOT NULL,analysis_report TEXT,runway_length REAL,runway_width REAL,threshold_offset REAL,runway_start_latitud' +
  'e REAL,runway_start_longitude REAL,runway_true_heading REAL,runway_slope REAL,velocity_world_y INTEGER)',
  'CREATE TABLE trip_touchdowns (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,trip INTEGER NOT NULL,airspeed_indicated INTEGER NOT NULL,vertical_speed INTEGER NOT NULL,g_force' +
  ' REAL NOT NULL,plane_pitch_degrees REAL NOT NULL,plane_bank_degrees REAL NOT NULL,heading_indicator INTEGER NOT NULL,plane_latitude REAL NOT NULL,plane_longitude REAL NOT NULL,icao' +
  ' VARCHAR(4),airport_name VARCHAR(64),runway VARCHAR(3),runway_heading INTEGER,distance_length REAL,distance_width REAL,distance_length_percent REAL,distance_width_percent REAL,wind' +
  '_direction INTEGER,wind_velocity INTEGER,time_zulu VARCHAR(32) NOT NULL,time_local VARCHAR(32) NOT NULL,analysis_report TEXT,runway_length REAL,runway_width REAL,threshold_offset R' +
  'EAL,runway_start_latitude REAL,runway_start_longitude REAL,runway_true_heading REAL,runway_slope REAL,velocity_world_y INTEGER)',
  'CREATE TABLE trip_groups (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,name VARCHAR(64) NOT NULL,sort_order INTEGER NOT NULL DEFAULT 0)'
);
 LegacyBoolMasks : Array [1..3] Of UInt64 = (4294967295, 2147500031, 4294966305);
 LegacyBoolExpressions : Array [1..3] Of String = (
  '(((bool_group_1 >> 0) & 1) << 0) | (((bool_group_1 >> 1) & 1) << 1) | (((bool_group_1 >> 2) & 1) << 2) | (((bool_group_1 >> 3) & 1) << 3) | (((bool_group_1 >> 4) & 1) << 4) | (((bo' +
  'ol_group_1 >> 5) & 1) << 5) | (((bool_group_1 >> 6) & 1) << 6) | (((bool_group_1 >> 7) & 1) << 7) | (((bool_group_1 >> 8) & 1) << 8) | (((bool_group_1 >> 9) & 1) << 9) | (((bool_gr' +
  'oup_1 >> 10) & 1) << 10) | (((bool_group_1 >> 11) & 1) << 11) | (((bool_group_1 >> 12) & 1) << 12) | (((bool_group_1 >> 13) & 1) << 13) | (((bool_group_1 >> 14) & 1) << 14) | (((bo' +
  'ol_group_1 >> 15) & 1) << 15) | (((bool_group_1 >> 16) & 1) << 16) | (((bool_group_1 >> 17) & 1) << 17) | (((bool_group_1 >> 18) & 1) << 18) | (((bool_group_1 >> 19) & 1) << 19) | ' +
  '(((bool_group_1 >> 20) & 1) << 20) | (((bool_group_1 >> 21) & 1) << 21) | (((bool_group_1 >> 22) & 1) << 22) | (((bool_group_1 >> 23) & 1) << 23) | (((bool_group_1 >> 24) & 1) << 2' +
  '4) | (((bool_group_1 >> 25) & 1) << 25) | (((bool_group_1 >> 26) & 1) << 26) | (((bool_group_1 >> 27) & 1) << 27) | (((bool_group_1 >> 28) & 1) << 28) | (((bool_group_1 >> 29) & 1)' +
  ' << 29) | (((bool_group_1 >> 30) & 1) << 30) | (((bool_group_1 >> 31) & 1) << 31)',
  '(((bool_group_2 >> 0) & 1) << 0) | (((bool_group_2 >> 1) & 1) << 1) | (((bool_group_2 >> 2) & 1) << 2) | (((bool_group_2 >> 3) & 1) << 3) | (((bool_group_2 >> 4) & 1) << 4) | (((bo' +
  'ol_group_2 >> 5) & 1) << 5) | (((bool_group_2 >> 6) & 1) << 6) | (((bool_group_2 >> 7) & 1) << 7) | (((bool_group_2 >> 8) & 1) << 8) | (((bool_group_2 >> 9) & 1) << 9) | (((bool_gr' +
  'oup_2 >> 10) & 1) << 10) | (((bool_group_2 >> 11) & 1) << 11) | (((bool_group_2 >> 12) & 1) << 12) | (((bool_group_2 >> 31) & 1) << 31)',
  '(((bool_group_3 >> 0) & 1) << 0) | (((bool_group_3 >> 5) & 1) << 5) | (((bool_group_3 >> 10) & 1) << 10) | (((bool_group_3 >> 11) & 1) << 11) | (((bool_group_3 >> 12) & 1) << 12) |' +
  ' (((bool_group_3 >> 13) & 1) << 13) | (((bool_group_3 >> 14) & 1) << 14) | (((bool_group_3 >> 15) & 1) << 15) | (((bool_group_3 >> 16) & 1) << 16) | (((bool_group_3 >> 17) & 1) << ' +
  '17) | (((bool_group_3 >> 18) & 1) << 18) | (((bool_group_3 >> 19) & 1) << 19) | (((bool_group_3 >> 20) & 1) << 20) | (((bool_group_3 >> 21) & 1) << 21) | (((bool_group_3 >> 22) & 1' +
  ') << 22) | (((bool_group_3 >> 23) & 1) << 23) | (((bool_group_3 >> 24) & 1) << 24) | (((bool_group_3 >> 25) & 1) << 25) | (((bool_group_3 >> 26) & 1) << 26) | (((bool_group_3 >> 27' +
  ') & 1) << 27) | (((bool_group_3 >> 28) & 1) << 28) | (((bool_group_3 >> 29) & 1) << 29) | (((bool_group_3 >> 30) & 1) << 30) | (((bool_group_3 >> 31) & 1) << 31)'
);