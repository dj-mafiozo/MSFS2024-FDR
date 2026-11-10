Unit AirbusDataU;

Interface

 Uses
  System.SysUtils, System.Math, System.Generics.Collections, FlightDatabaseU;

 Type
  TAirbusSDPage = (aspENG, aspBLEED, aspPRESS, aspELEC, aspHYD, aspFUEL, aspAPU, aspCOND, aspDOOR, aspWHEEL, aspFCTL, aspSTS, aspCRUISE);

  TAirbusData = Class
   Private
    fPlot     : TTripPlot;
    fRevision : UInt64;
    fLabels   : TPlotLabels;
    fIndex    : Integer;
    fLookup   : TDictionary<String, Integer>;
   Public
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Clear;
    Procedure SetPoint(Plot : TTripPlot; Index : Integer);
    Function Value(Const Name : String) : Double;
    Function FBW(Const Name : String) : Double;
    Function Fenix(Const Name : String) : Double;
    Function ARINC(Const Name : String) : Double;
    Function Cabin(Const Suffix : String) : Double;
    Function Engine(Const Name : String; Number : Integer) : Double;
    Function RecordedPage : Integer;
    Function RecordedPageSource : String;
    Function Time : String;
    Function Seconds : Double;
    Function IsFenix : Boolean;
  End;

 Function DecodeAirbusARINC(Raw : Double) : Double;
 Function AirbusPageName(Page : Integer) : String;
 Function AirbusPageFromFBWDisplay(Value : Double) : Integer;

Implementation

 Uses
  FenixCatalogU,
  InstrumentDataU, System.DateUtils;

 Function DecodeAirbusARINC(Raw : Double) : Double;
  Var
   Bits    : UInt64;
   Payload : Cardinal;
   v       : Single;
  Begin
   Result := NaN;
   If Not InstrumentValid(Raw) Or (Raw < 0) Or (Raw > 17179869183) Or (Raw <> Trunc(Raw)) Then
    Exit;
   Bits := UInt64(Trunc(Raw));
   If ((Bits Shr 32) And 3) <> 3 Then
    Exit;
   Payload := Cardinal(Bits And $FFFFFFFF);
   Move(Payload, v, SizeOf(v));
   If InstrumentValid(v) Then
    Result := v;
  End;

 Function AirbusPageName(Page : Integer) : String;
  Const
   Names : Array [TAirbusSDPage] Of String = ('ENG', 'BLEED', 'PRESS', 'ELEC', 'HYD', 'FUEL', 'APU', 'COND', 'DOOR/OXY', 'WHEEL', 'F/CTL', 'STS', 'CRUISE');
  Begin
   If (Page < 0) Or (Page > Ord(High(TAirbusSDPage))) Then
    Result := '--'
   Else
    Result := Names[TAirbusSDPage(Page)];
  End;

 Function AirbusPageFromFBWDisplay(Value : Double) : Integer;
  Begin
   Result := -1;
   If Not InstrumentValid(Value) Or (Value < 0) Or (Value > 12) Or (Value <> Trunc(Value)) Then
    Exit;
   Result := Trunc(Value);
   // PagesContainer.tsx: display enum 11=CRZ, 12=STS (selector enum differs).
   If Result = 11 Then
    Result := Ord(aspCRUISE)
   Else If Result = 12 Then
    Result := Ord(aspSTS);
  End;

 Constructor TAirbusData.Create;
  Begin
   Inherited;
   fLookup := TDictionary<String, Integer>.Create;
   Clear;
  End;

 Destructor TAirbusData.Destroy;
  Begin
   fLookup.Free;
   Inherited;
  End;

 Procedure TAirbusData.Clear;
  Begin
   fPlot     := Nil;
   fLabels   := Nil;
   fIndex    := -1;
   fRevision := 0;
   fLookup.Clear;
  End;

 Procedure TAirbusData.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   i : Integer;
  Begin
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Begin
     Clear;
     Exit;
    End;
   If (Plot <> fPlot) Or (Plot.Labels <> fLabels) Or (Plot.Labels.Revision <> fRevision) Then
    Begin
     fLookup.Clear;
     For i := 0 To Plot.Labels.Count - 1 Do
      fLookup.AddOrSetValue(Plot.Labels[i], i);
     fLabels   := Plot.Labels;
     fRevision := Plot.Labels.Revision;
    End;
   fPlot  := Plot;
   fIndex := Index;
  End;

 Function TAirbusData.Value(Const Name : String) : Double;
  Var
   k : Integer;
  Begin
   Result := NaN;
   If (fPlot <> Nil) And fLookup.TryGetValue(Name, k) Then
    If k < Length(fPlot.DisplayPoint(fIndex).Values) Then
     Result := fPlot.DisplayPoint(fIndex).Values[k];
  End;

 Function TAirbusData.FBW(Const Name : String) : Double;
  Begin
   Result := Value('FBWLVar.' + Name);
  End;

 Function TAirbusData.Fenix(Const Name : String) : Double;
  Begin
   Result := Value('FenixLVar.' + Name);
  End;

 Function TAirbusData.ARINC(Const Name : String) : Double;
  Begin
   Result := DecodeAirbusARINC(FBW(Name));
  End;

 Function TAirbusData.Cabin(Const Suffix : String) : Double;
  Var
   WordValue : Double;
   CPC       : Integer;
  Begin
   Result    := NaN;
   WordValue := ARINC('A32NX_PRESS_CPC_1_DISCRETE_WORD');
   If InstrumentValid(WordValue) Then
    Begin
     If (Trunc(WordValue) And (Int64(1) Shl 10)) <> 0 Then
      CPC := 1
     Else
      CPC   := 2;
     Result := ARINC('A32NX_PRESS_CPC_' + IntToStr(CPC) + '_' + Suffix);
     If Not InstrumentValid(Result) Then
      Result := FBW('A32NX_PRESS_MAN_' + Suffix);
    End;
   If Not InstrumentValid(Result) And (Suffix = 'CABIN_ALTITUDE') Then
    Result := Value('pressurization_cabin_altitude');
  End;

 Function TAirbusData.Engine(Const Name : String; Number : Integer) : Double;
  Begin
   Result := NaN;
   If Name = 'turb_eng_n1' Then
    Result := FBW('A32NX_ENGINE_N1:' + IntToStr(Number));
   If Name = 'turb_eng_n2' Then
    Result := FBW('A32NX_ENGINE_N2:' + IntToStr(Number));
   If Name = 'eng_exhaust_gas_temperature' Then
    Result := FBW('A32NX_ENGINE_EGT:' + IntToStr(Number));
   If Not InstrumentValid(Result) Then
    Result := Value(Name + ' #' + IntToStr(Number));
  End;

 Function TAirbusData.RecordedPage : Integer;
  Begin
   // Neither the FBW manual selector nor Fenix pushbutton lamps prove the displayed auto page.
   Result := AirbusPageFromFBWDisplay(FBW('A32NX_ECAM_SD_PAGE_TO_DISPLAY'));
  End;

 Function TAirbusData.RecordedPageSource : String;
  Begin
   If RecordedPage >= 0 Then
    Result := 'FBW SD PAGE TO DISPLAY'
   Else
    Result := 'PAGE --';
  End;

 Function TAirbusData.IsFenix : Boolean;
  Begin
   Result := (fPlot <> Nil) And (Pos('FENIX', UpperCase(fPlot.AircraftTitle)) > 0);
  End;

 Function TAirbusData.Time : String;
  Begin
   Result := '';
   If fPlot <> Nil Then
    Result := fPlot.DisplayPoint(fIndex).Time;
  End;

 Function TAirbusData.Seconds : Double;
  Var
   d : TDateTime;
  Begin
   Result := 0;
   If TryISO8601ToDate(Time, d, True) Then
    Result := d * 86400;
  End;

End.
