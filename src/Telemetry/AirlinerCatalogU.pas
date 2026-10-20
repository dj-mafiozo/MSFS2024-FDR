{$StackFrames On}
Unit AirlinerCatalogU;

Interface

 Const
  AirlinerVarCount                          = 31;
  AirlinerNames : Array [0 .. 30] Of String = (
   'AIRLINER_V1_SPEED',
   'AIRLINER_VR_SPEED',
   'AIRLINER_V2_SPEED',
   'AIRLINER_MINIMUM_DESCENT_ALTITUDE',
   'AIRLINER_DECISION_HEIGHT',
   'A32NX_AIRLINER_CRUISE_ALTITUDE',
   'A32NX_AIRLINER_TO_FLEX_TEMP',
   'AIRLINER_ACC_ALT',
   'AIRLINER_APPR_GREEN_DOT_SPD',
   'AIRLINER_CRUISE_ALTITUDE',
   'AIRLINER_FLIGHT_PHASE',
   'AIRLINER_FMC_FORCE_NEXT_UPDATE',
   'AIRLINER_FMS_HEADING_TOP_CLIMB',
   'AIRLINER_FMS_HEADING_TOP_DSCNT',
   'AIRLINER_FMS_LAT_TOP_CLIMB',
   'AIRLINER_FMS_LAT_TOP_DSCNT',
   'AIRLINER_FMS_LONG_TOP_CLIMB',
   'AIRLINER_FMS_LONG_TOP_DSCNT',
   'AIRLINER_FMS_SHOW_TOP_CLIMB',
   'AIRLINER_FMS_SHOW_TOP_DSCNT',
   'AIRLINER_MANAGED_APPROACH_SPEED',
   'AIRLINER_MCDU_CURRENT_FPLN_WAYPOINT',
   'AIRLINER_TAKEOFF_FLAP',
   'AIRLINER_THRUST_CLIMB_MODE',
   'AIRLINER_THRUST_TAKEOFF_MODE',
   'AIRLINER_THR_RED_ALT',
   'AIRLINER_TO_FLEX_TEMP',
   'AIRLINER_TO_GREEN_DOT_SPD',
   'AIRLINER_TRANS_ALT',
   'AIRLINER_VREF_SPEED',
   'AIRLINER_VX_SPEED');
  AirlinerUnits : Array [0 .. 30] Of String = (
   'Knots',
   'Knots',
   'Knots',
   'feet',
   'feet',
   'number',
   'number',
   'Number',
   'Number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'number',
   'Number',
   'Number',
   'Number',
   'Number',
   'knots',
   'Knots');

Implementation

End.
