{$StackFrames On}
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
    fSHudDataU   : TJSONObject;
    Numbers      : Array Of Double;
    Texts        : Array Of String;
    Procedure OverrideNumber(Const Name : String; Value : Double; Const Source : String);
    Constructor Create;
    Destructor Destroy; Override;
    Procedure Decode(p : Pointer; Size : Integer);
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
   For i       := 709 To FieldCount - 1 Do
    Numbers[i] := NaN;
   For i       := 0 To FieldCount - 1 Do
    fIndex.Add(SimFields[i].Name, i);
  End;

 Destructor TFlightSample.Destroy;
  Begin
   fSHudDataU.Free;
   GSXData.Free;
   AirlinerData.Free;
   AircraftData.Free;
   DataSources.Free;
   fIndex.Free;
   Inherited;
  End;

 Procedure TFlightSample.Decode(p : Pointer; Size : Integer);
  Var
   i : Integer;
   z : Integer;
   a : AnsiString;
  Begin
   FreeAndNil(fSHudDataU);
   FreeAndNil(GSXData);
   FreeAndNil(AirlinerData);
   FreeAndNil(AircraftData);
   FreeAndNil(DataSources);
   If Size < PayloadSize Then
    Raise Exception.Create(Tr('Truncated SimConnect telemetry'));
   For i := 0 To FieldCount - 1 Do
    If SimFields[i].DataType = 4 Then
     Move(PByte(NativeUInt(p) + NativeUInt(SimFields[i].Offset))^, Numbers[i], 8)
    Else
     Begin
      SetString(a, PAnsiChar(NativeUInt(p) + NativeUInt(SimFields[i].Offset)), SimFields[i].Size);
      z := Pos(#0, String(a));
      If z > 0 Then
       SetLength(a, z - 1);
      Texts[i] := UTF8ToString(UTF8String(a));
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
   m       : Integer;
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
   m      := Abs(Trunc(Offset / 60));
   Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', DT) + Sign + Format('%.2d:%.2d', [m Div 60, m Mod 60]) + '_' + IntToStr(Trunc(N(Prefix + '.weekday')));
  End;

 Function TFlightSample.EngineCount : Integer;
  Var
   v : Double;
  Begin
   v := N('number_of_engines');
   If IsNan(v) Or IsInfinite(v) Then
    Exit(0);
   Result := EnsureRange(Trunc(v), 0, 16);
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
