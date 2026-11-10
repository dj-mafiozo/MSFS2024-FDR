{$StackFrames On}
Unit SimVarSelectionU;

Interface

 Uses
  System.SysUtils, TelemetryCatalogU;

 Function IsBootstrapField(Index : Integer) : Boolean;
 Function IsEngineField(Const SimVar : String) : Boolean;
 Function UseSimField(Index, EngineType, Engines : Integer) : Boolean;
 Function UseSharedAirliner(Const Title, AircraftPath : String; EngineType : Integer) : Boolean;

Implementation

 Function IsBootstrapField(Index : Integer) : Boolean;
  Begin
   Result := (SimFields[Index].Name = 'title') Or (SimFields[Index].Name = 'engine_type') Or (SimFields[Index].Name = 'number_of_engines');
  End;

 Function IsEngineField(Const SimVar : String) : Boolean;
  Begin
   Result := (Pos('ENG ', SimVar) = 1) Or (Pos('GENERAL ENG ', SimVar) = 1) Or (Pos('TURB ENG ', SimVar) = 1) Or (Pos('RECIP ENG ', SimVar) = 1) Or (Pos('PROP ', SimVar) = 1) Or (Pos('BLEED AIR ENGINE', SimVar) = 1) Or (Pos('APU BLEED PRESSURE RECEIVED BY ENGINE', SimVar) = 1);
  End;

 Function UseSimField(Index, EngineType, Engines : Integer) : Boolean;
  Var
   n : String;
   p : Integer;
   e : Integer;
  Begin
   n      := UpperCase(SimFields[Index].SimVar);
   Result := True;
   If IsEngineField(n) Then
    Begin
     If Engines = 0 Then
      Exit(False);
     p := LastDelimiter(':', n);
     If p > 0 Then
      Begin
       e := StrToIntDef(Copy(n, p + 1, MaxInt), 0);
       If (e > Engines) Or (e < 1) Then
        Exit(False);
      End;
    End;
   If (Pos('APU BLEED PRESSURE RECEIVED BY ENGINE', n) = 1) Or (Pos('BLEED AIR ENGINE', n) = 1) Then
    Exit((EngineType = 1) Or (EngineType = 3) Or (EngineType = 5));
   If Pos('TURB ENG MAX TORQUE PERCENT', n) = 1 Then
    Exit((EngineType = 3) Or (EngineType = 5));
   If Pos('GENERAL ENG MIXTURE LEVER POSITION', n) = 1 Then
    Exit(EngineType = 0);
   If Pos('TURB ENG CONDITION LEVER POSITION', n) = 1 Then
    Exit(EngineType = 5);
   If Pos('TURB ENG ITT', n) = 1 Then
    Exit((EngineType = 3) Or (EngineType = 5));
   If Pos('RECIP ENG ', n) = 1 Then
    Exit(EngineType = 0);
   If Pos('TURB ENG ', n) = 1 Then
    Exit((EngineType = 1) Or (EngineType = 3) Or (EngineType = 5));
   If Pos('PROP ', n) = 1 Then
    Exit((EngineType = 0) Or (EngineType = 5) Or (EngineType = 6));
   If (Pos('ROTOR ', n) = 1) Or (Pos('HELICOPTER ', n) = 1) Then
    Exit(EngineType = 3);
  End;

 Function UseSharedAirliner(Const Title, AircraftPath : String; EngineType : Integer) : Boolean;
  Var
   t : String;
  Begin
   t := UpperCase(Title + ' ' + AircraftPath);
   // These instrument L-vars are not a general property of turbine engines.
   // Aircraft-specific SDK providers are authoritative and do not need this fallback.
   If (Pos('PMDG', t) > 0) Or (Pos('IFLY', t) > 0) Or (Pos('FENIX', t) > 0) Or (Pos('FNX', t) > 0) Or (Pos('FBW', t) > 0) Or (Pos('FLYBYWIRE', t) > 0) Or (Pos('TFDI', t) > 0) Or (Pos('MADDOG', t) > 0) Or (Pos('SKYSIM', t) > 0) Then
    Exit(False);
   Result := (EngineType = 1) And ((Pos('A320', t) > 0) Or (Pos('A32NX', t) > 0) Or (Pos('A330', t) > 0) Or (Pos('A310', t) > 0) Or (Pos('B737', t) > 0) Or (Pos('737 MAX', t) > 0) Or (Pos('747', t) > 0) Or (Pos('787', t) > 0) Or (Pos('A400', t) > 0));
  End;

End.
