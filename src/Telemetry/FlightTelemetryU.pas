Unit FlightTelemetryU;

Interface

 Uses
  System.JSON, Winapi.Windows, System.SysUtils, System.DateUtils, System.Math, System.Generics.Collections,
  LocalizationU, TelemetryCatalogU;

 Type
  TFlightSample = Class
   Private
    fIndex : TDictionary<String, Integer>;
   Public
    AircraftData : TJSONObject;
    DataSources  : TJSONObject;
    AirlinerData : TJSONObject;
    GSXData      : TJSONObject;
    FSHudDataU   : TJSONObject;
    Numbers      : Array Of Double;
    Texts        : Array Of String;
    Procedure OverrideNumber(Const Name : String; Value : Double; Const Source : String);
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Decode(P : Pointer; Size : Integer);
    Function N(Const Name : String) : Double;
    Function S(Const Name : String) : String;
    Function Time(Const Prefix : String) : String;
    Function EngineCount : Integer;
    Function EngineRunning : Boolean;
  End;

Implementation

 Constructor TFlightSample.Create;
  Var
   i : Integer;
  Begin
   Inherited;
   fIndex := TDictionary<String, Integer>.Create;
   SetLength(Numbers, FieldCount);
   SetLength(Texts, FieldCount);
   For i := 0 To FieldCount - 1 Do
    fIndex.Add(SimFields[i].Name, i);
  End;

 Destructor TFlightSample.Destroy;
  Begin
   FSHudDataU.Free;
   GSXData.Free;
   AirlinerData.Free;
   AircraftData.Free;
   DataSources.Free;
   fIndex.Free;
   Inherited;
  End;

 Procedure TFlightSample.Decode(P : Pointer; Size : Integer);
  Var
   i : Integer;
   Z : Integer;
   A : AnsiString;
  Begin
   FreeAndNil(FSHudDataU);
   FreeAndNil(GSXData);
   FreeAndNil(AirlinerData);
   FreeAndNil(AircraftData);
   FreeAndNil(DataSources);
   If Size < PayloadSize Then
    Raise Exception.Create(Tr('Truncated SimConnect telemetry'));
   For i := 0 To FieldCount - 1 Do
    If SimFields[i].DataType = 4 Then
     Move(PByte(NativeUInt(P) + NativeUInt(SimFields[i].Offset))^, Numbers[i], 8)
    Else
     Begin
      SetString(A, PAnsiChar(NativeUInt(P) + NativeUInt(SimFields[i].Offset)), SimFields[i].Size);
      Z := Pos(#0, String(A));
      If Z > 0 Then
       SetLength(A, Z - 1);
      Texts[i] := UTF8ToString(UTF8String(A));
     End;
  End;

 Procedure TFlightSample.OverrideNumber(Const Name : String; Value : Double; Const Source : String);
  Var
   i : Integer;
  Begin
   If Not fIndex.TryGetValue(Name, i) Then
    Raise Exception.Create(Tr('Unknown SDK target ') + Name);
   Numbers[i] := Value;
   If DataSources = Nil Then
    DataSources := TJSONObject.Create;
   DataSources.RemovePair(Name).Free;
   DataSources.AddPair(Name, Source);
  End;

 Function TFlightSample.N(Const Name : String) : Double;
  Var
   i : Integer;
  Begin
   If Not fIndex.TryGetValue(Name, i) Then
    Raise Exception.Create(Tr('Unknown field ') + Name);
   Result := Numbers[i];
  End;

 Function TFlightSample.S(Const Name : String) : String;
  Var
   i : Integer;
  Begin
   If Not fIndex.TryGetValue(Name, i) Then
    Raise Exception.Create(Tr('Unknown field ') + Name);
   Result := Texts[i];
  End;

 Function TFlightSample.Time(Const Prefix : String) : String;
  Var
   DT      : TDateTime;
   Seconds : Double;
   Offset  : Double;
   Sign    : String;
   M       : Integer;
  Begin
   Seconds := N(Prefix + '.seconds');
   Offset  := 0;
   If Prefix = 'time_local' Then
    Offset := N(Prefix + '.offset');
   If Not TryEncodeDate(Trunc(N(Prefix + '.year')), Trunc(N(Prefix + '.month')), Trunc(N(Prefix + '.day')), DT) Then
    Exit('');
   DT   := DT + EnsureRange(Round(Seconds * 1000), Int64(0), Int64(86399999)) / 86400000;
   Sign := '+';
   If Offset > 0 Then
    Sign  := '-';
   M      := Abs(Trunc(Offset / 60));
   Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', DT) + Sign + Format('%.2d:%.2d', [M Div 60, M Mod 60]) + '_' + IntToStr(Trunc(N(Prefix + '.weekday')));
  End;

 Function TFlightSample.EngineCount : Integer;
  Var
   V : Double;
  Begin
   V := N('number_of_engines');
   If IsNan(V) Or IsInfinite(V) Then
    Exit(0);
   Result := EnsureRange(Trunc(V), 0, 16);
  End;

 Function TFlightSample.EngineRunning : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   For i  := 0 To EngineCount - 1 Do
    If N('eng_combustion[' + IntToStr(i) + ']') <> 0 Then
     Exit(True);
  End;

End.
