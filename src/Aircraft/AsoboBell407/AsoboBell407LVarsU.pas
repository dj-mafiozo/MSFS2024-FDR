{$StackFrames On}
Unit AsoboBell407LVarsU;

Interface

 Uses
  AddonLVarTypesU;

{FLD+}

 Const
  AsoboBell407Fields : Array [0..71] Of TAddonLVarField =
   (
    (Provider: 'AsoboBell407'; Name: 'A:ATTITUDE BARS POSITION';             SourceUnits: 'position'; DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'A:AVIONICS MASTER SWITCH:1';           SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:COM TRANSMIT:1';                     SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:COM TRANSMIT:2';                     SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:ELECTRICAL MASTER BATTERY:1';        SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:ELT ACTIVATED';                      SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:ENG ANTI ICE:1';                     SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:FUELSYSTEM PUMP ACTIVE:1';           SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:FUELSYSTEM PUMP ACTIVE:2';           SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:FUELSYSTEM VALVE SWITCH:1';          SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:HYDRAULIC SWITCH:1';                 SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:INTERCOM SYSTEM ACTIVE';             SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT BEACON';                       SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT LANDING';                      SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT LOGO';                         SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT NAV';                          SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT PANEL';                        SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT POTENTIOMETER:4';              SourceUnits: 'percent';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT POTENTIOMETER:5';              SourceUnits: 'percent';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT RECOGNITION ON';               SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:LIGHT STROBE';                       SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:MARKER BEACON TEST MUTE';            SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:NAV OBS:1';                          SourceUnits: 'degrees';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'A:NAV OBS:2';                          SourceUnits: 'degrees';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'A:PITOT HEAT';                         SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:ROTOR BRAKE ACTIVE';                 SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'A:ROTOR COLLECTIVE BLADE PITCH PCT:1'; SourceUnits: 'percent';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'A:ROTOR GOV SWITCH POS';               SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'ChronoMode';                           SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'ChronoOatVolt';                        SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'CollectiveGrip';                       SourceUnits: 'percent';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'TotalRunning chrono';                  SourceUnits: 'seconds';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'adfObs';                               SourceUnits: 'degrees';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'buttonAnnTest';                        SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'buttonFireTest';                       SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'buttonFloatTest';                      SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'buttonHornTest';                       SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'buttonInstrTest';                      SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'buttonLcdTest';                        SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'collGripState';                        SourceUnits: 'enum';     DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'fuelQtyMode';                          SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'hornMuted';                            SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'knobAcTemp';                           SourceUnits: 'celsius';  DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'knobAttCage';                          SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'knobDefrost';                          SourceUnits: 'number';   DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'knobFriction';                         SourceUnits: 'number';   DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'needleHsiMarker';                      SourceUnits: 'number';   DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'panelLightTilt';                       SourceUnits: 'number';   DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'switchAircondAft';                     SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchAircondFwd';                     SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchAircondMode';                    SourceUnits: 'enum';     DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'switchAttGyro';                        SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchAutotrim';                       SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchAuxSys';                         SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchBroadcastMaster';                SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchCargoRelease';                   SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchCautLtsMode';                    SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchDefog';                          SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchForceTrim';                      SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchFuelValveCover';                 SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchGenerator';                      SourceUnits: 'enum';     DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'switchHeater';                         SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchLandingLight';                   SourceUnits: 'enum';     DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'switchLtsCabinPass';                   SourceUnits: 'enum';     DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'switchParicleSep';                     SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchPrimaryCompassMode';             SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchRadAlt';                         SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'switchStarter';                        SourceUnits: 'enum';     DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'switchturnCoord';                      SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'testOvrspd';                           SourceUnits: 'bool';     DisplayValue: '0=OFF\r\n1=ON'),
    (Provider: 'AsoboBell407'; Name: 'ventKnobCopilot';                      SourceUnits: 'number';   DisplayValue: ''),
    (Provider: 'AsoboBell407'; Name: 'ventKnobPilot';                        SourceUnits: 'number';   DisplayValue: '')
   );
{FLD-}

Implementation

End.
