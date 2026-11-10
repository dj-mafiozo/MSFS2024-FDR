{$StackFrames On}
Unit InstrumentDataU;

Interface

 Uses
  System.SysUtils, System.Math, FlightDatabaseU;

 Type
  TInstrumentKind = (ikGaAnalog, ikGaGlass, ikAirlinerClassic, ikAirlinerPFD, ikB38MPFD, ikA320PFD);

  TInstrumentProfile = Record
   Kind        : TInstrumentKind;
   EngineType  : Integer;
   EngineCount : Integer;
   Title       : String;
  End;

 Var
  InstrumentKindOverride : Integer = -1;

 Function InstrumentValue(Plot : TTripPlot; Index : Integer; Const Name : String) : Double;
 Function InstrumentValid(v : Double) : Boolean;
 Function InstrumentProfile(Plot : TTripPlot; Index : Integer) : TInstrumentProfile;
 Function InstrumentKindName(Kind : TInstrumentKind) : String;

Implementation

 Function InstrumentValid(v : Double) : Boolean;
  Begin
   Result := Not IsNan(v) And Not IsInfinite(v);
  End;

 Function InstrumentValue(Plot : TTripPlot; Index : Integer; Const Name : String) : Double;
  Var
   k : Integer;
  Begin
   Result := NaN;
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Exit;
   k := Plot.Labels.IndexOf(Name);
   If (k >= 0) And (k < Length(Plot.DisplayPoint(Index).Values)) Then
    Result := Plot.DisplayPoint(Index).Values[k];
  End;

 Function InstrumentKindName(Kind : TInstrumentKind) : String;
  Begin
   Case Kind Of
    ikA320PFD         : Result := 'A320 / PFD';
    ikB38MPFD         : Result := 'B38M / PFD';
    ikGaAnalog        : Result := 'GA / ANALOG';
    ikGaGlass         : Result := 'GA / GLASS';
    ikAirlinerClassic : Result := 'AIRLINER / CLASSIC';
   Else Result := 'AIRLINER / PFD';
   End;
  End;

 Function InstrumentProfile(Plot : TTripPlot; Index : Integer) : TInstrumentProfile;
  Var
   s : String;
   v : Double;

   Function Has(Const Token : String) : Boolean;
    Begin
     Result := Pos(Token, s) > 0;
    End;

  Begin
   Result.Kind        := ikGaAnalog;
   Result.EngineType  := -1;
   Result.EngineCount := 0;
   Result.Title       := '';
   If Plot = Nil Then
    Exit;
   Result.Title := Plot.AircraftTitle;
   s            := UpperCase(Result.Title + ' ' + Plot.AircraftTypeICAO).Replace('-', '').Replace('_', '').Replace(' ', '');
   v            := InstrumentValue(Plot, Index, 'engine_type');
   If InstrumentValid(v) And (v >= 0) And (v <= 6) Then
    Result.EngineType := Trunc(v);
   v                  := InstrumentValue(Plot, Index, 'number_of_engines');
   If InstrumentValid(v) And (v >= 0) And (v <= 16) Then
    Result.EngineCount := Trunc(v);
   If SameText(Trim(Plot.AircraftTypeICAO), 'B38M') Then
    Result.Kind := ikB38MPFD
   Else If (Has('FENIX') Or Has('A32NX') Or (Has('FLYBYWIRE') And Has('A320')) Or (Plot.Labels.IndexOf('FenixLVar.S_MIP_GEAR') >= 0) Or (Plot.Labels.IndexOf('FBWLVar.A32NX_IS_READY') >= 0)) And (Has('A32') Or Has('A319') Or Has('A20N') Or Has('A21N')) Then
    Result.Kind := ikA320PFD
   Else If Has('DC6') Or Has('DC9') Or Has('MADDOG') Or Has('MD80') Or Has('B727') Or (Has('CSS') And Has('737')) Or Has('737200') Or Has('737300') Or Has('737400') Or Has('737500') Then
    Result.Kind := ikAirlinerClassic
   Else If Has('B38M') Or Has('B39M') Or Has('B736') Or Has('B737') Or Has('B738') Or Has('B739') Or Has('A32') Or Has('A330') Or Has('A350') Or Has('A380') Or Has('A310') Or Has('B737') Or Has('737MAX') Or Has('737NG') Or Has('B747') Or Has('B757') Or Has('B767') Or Has('B777') Or Has('B787') Or (Has('PMDG') And (Has('777') Or Has('737'))) Or Has('MD11') Or Has('CRJ') Or Has('E170') Or Has('E175') Or Has('E190') Or Has('E195') Then
    Result.Kind := ikAirlinerPFD
   Else If Has('G1000') Or Has('AS1000') Or Has('G3000') Or Has('G5000') Or Has('SF50') Or Has('VISIONJET') Or Has('TBM930') Or Has('TBM850') Or Has('PC12') Or Has('DA40NG') Or Has('DA62') Or Has('CJ4') Or Has('LONGITUDE') Then
    Result.Kind := ikGaGlass;
   If (InstrumentKindOverride >= 0) And (InstrumentKindOverride <= Ord(High(TInstrumentKind))) Then
    Result.Kind := TInstrumentKind(InstrumentKindOverride);
  End;

End.
