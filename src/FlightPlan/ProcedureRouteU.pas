Unit ProcedureRouteU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.JSON,
  System.Generics.Collections, FlightPlanU, SimConnectClientU;

 Type
  // Packed in exactly the order of LegFields below. No pointer-sized members.
  TProcedureLeg = Packed Record
   Kind           : Integer;
   Fix            : Array [0..7] Of AnsiChar;
   Region         : Array [0..7] Of AnsiChar;
   FixType        : Integer;
   Lat            : Double;
   Lon            : Double;
   Course         : Single;
   TrueDegree     : Integer;
   Turn           : Integer;
   Distance       : Single;
   DistanceMinute : Integer;
   AltDesc        : Integer;
   Alt1           : Single;
   Alt2           : Single;
   Speed          : Single;
   ArcLat         : Double;
   ArcLon         : Double;
   OriginLat      : Double;
   OriginLon      : Double;
   Rho            : Single;
   Theta          : Single;
   FlyOver        : Integer;
  End;

  TProcedureNode = Class
   ID           : Cardinal;
   Parent       : Cardinal;
   Kind         : Cardinal;
   Index        : Cardinal;
   Count        : Cardinal;
   Name         : String;
   Airport      : String;
   Runway       : Integer;
   Designator   : Integer;
   ApproachType : Integer;
   Suffix       : Integer;
   MagVar       : Single;
   Leg          : TProcedureLeg;
  End;

  TProcedureReader = Class
   Private
    fSim        : TSimConnectClient;
    fPlan       : TFlightPlan;
    fNodes      : TObjectList<TProcedureNode>;
    fKeys       : TDictionary<String, TProcedureNode>;
    fRequest    : Cardinal;
    fStage      : Integer;
    fDefined    : Boolean;
    fBusy       : Boolean;
    fDeadline   : UInt64;
    fRetryAt    : UInt64;
    fAttempts   : Integer;
    fFacilityEx : Function(h : THandle; Def, Req : DWORD; ICAO, Region : PAnsiChar; Kind : AnsiChar) : HRESULT; Stdcall;
    fDefine     : Function(h : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
    fFacility   : Function(h : THandle; Def, Req : DWORD; ICAO, Region : PAnsiChar) : HRESULT; Stdcall;
    Procedure NextAirport;
    Procedure Publish;
   Public
    OnUpdated : TNotifyEvent;
    Constructor Create (Sim : TSimConnectClient);
    Destructor  Destroy; Override;
    Procedure   SetPlan(Plan : TFlightPlan);
    Procedure   Tick;
    Procedure   Feed   (p : Pointer; Size : DWORD);
    Property RequestID : Cardinal Read fRequest;
  End;

 Procedure UnwrapRecordedPlan(Const Format, Raw : String; Out BaseFormat, BaseRaw : String);
 Function EncodeRecordedPlan(Plan : TFlightPlan) : String;
 Function DecodeRecordedPlan(Const Format, Raw, Path : String) : TFlightPlan;
 Procedure ExpandProcedureRoute(Plan : TFlightPlan);
 Function ProcedureDefinition : TArray<AnsiString>;

Implementation

 Uses
  AppLogU, System.Math, System.StrUtils, System.NetEncoding, System.Generics.Defaults;

 Const
  LegFields : Array [0..22] Of AnsiString = ('TYPE', 'FIX_ICAO', 'FIX_REGION', 'FIX_TYPE', 'FIX_LATITUDE', 'FIX_LONGITUDE', 'COURSE', 'TRUE_DEGREE', 'TURN_DIRECTION', 'ROUTE_DISTANCE', 'DISTANCE_MINUTE', 'APPROACH_ALT_DESC', 'ALTITUDE1', 'ALTITUDE2', 'SPEED_LIMIT', 'ARC_CENTER_FIX_LATITUDE', 'ARC_CENTER_FIX_LONGITUDE', 'ORIGIN_LATITUDE', 'ORIGIN_LONGITUDE', 'RHO', 'THETA', 'FLY_OVER', '');

 Function ProcedureDefinition : TArray<AnsiString>;
  Var
   l : TList<AnsiString>;

   Procedure Add(Const S : AnsiString);
    Begin
     l.Add(S);
    End;

   Procedure Legs(Const Name : AnsiString);
    Var
     f : AnsiString;
    Begin
     Add('OPEN ' + Name);
     For f In LegFields Do
      If f <> '' Then
       Add(f);
     Add('CLOSE ' + Name);
    End;

   Procedure Departure(Const Name : AnsiString);
    Begin
     Add('OPEN ' + Name);
     Add('NAME');
     Legs('APPROACH_LEG');
     Add('OPEN RUNWAY_TRANSITION');
     Add('RUNWAY_NUMBER');
     Add('RUNWAY_DESIGNATOR');
     Legs('APPROACH_LEG');
     Add('CLOSE RUNWAY_TRANSITION');
     Add('OPEN ENROUTE_TRANSITION');
     Add('NAME');
     Legs('APPROACH_LEG');
     Add('CLOSE ENROUTE_TRANSITION');
     Add('CLOSE ' + Name);
    End;

  Begin
   l := TList<AnsiString>.Create;
   Try
    Add('OPEN AIRPORT');
    Add('MAGVAR');
    Departure('DEPARTURE');
    Departure('ARRIVAL');
    Add('OPEN APPROACH');
    Add('TYPE');
    Add('SUFFIX');
    Add('RUNWAY_NUMBER');
    Add('RUNWAY_DESIGNATOR');
    Add('OPEN APPROACH_TRANSITION');
    Add('NAME');
    Legs('APPROACH_LEG');
    Add('CLOSE APPROACH_TRANSITION');
    Legs('FINAL_APPROACH_LEG');
    Legs('MISSED_APPROACH_LEG');
    Add('CLOSE APPROACH');
    Add('CLOSE AIRPORT');
    Result := l.ToArray;
   Finally
    l.Free;
   End;
  End;

 Function FixedText(p : Pointer; Len : Integer) : String;
  Var
   S : AnsiString;
   i : Integer;
  Begin
   SetString(S, PAnsiChar(p), Len);
   i := Pos(#0, String(S));
   If i > 0 Then
    SetLength(S, i - 1);
   Result := Trim(UTF8ToString(UTF8String(S)));
  End;

 Constructor TProcedureReader.Create(Sim : TSimConnectClient);
  Begin
   Inherited Create;
   fSim     := Sim;
   fNodes   := TObjectList<TProcedureNode>.Create;
   fKeys    := TDictionary<String, TProcedureNode>.Create;
   fRequest := 100000;
  End;

 Destructor TProcedureReader.Destroy;
  Begin
   fKeys.Free;
   fNodes.Free;
   Inherited;
  End;

 Procedure TProcedureReader.SetPlan(Plan : TFlightPlan);
  Begin
   Inc(fRequest);
   fBusy := False;
   fKeys.Clear;
   fNodes.Clear;
   fPlan     := Plan;
   fStage    := 0;
   fDeadline := 0;
   fRetryAt  := 0;
   fAttempts := 0;
   If (fPlan <> Nil) And Not fPlan.BasePointsCaptured Then
    Begin
     fPlan.BasePoints         := fPlan.Points.ToArray;
     fPlan.BasePointsCaptured := True;
    End;
  End;

 Procedure TProcedureReader.Tick;
  Var
   S : AnsiString;
  Begin
   If Not fSim.Connected Then
    Begin
     fDefined := False;
     If fBusy Then
      Begin
       Inc(fRequest);
       fBusy := False;
       fKeys.Clear;
       fNodes.Clear;
       fStage := 0;
      End;
     Exit;
    End;
   If fPlan = Nil Then
    Exit;
   If Not fSim.Running Or fSim.FlightEnded Or fSim.FlightLoading Then
    Begin
     If fBusy Then
      Begin
       Inc(fRequest);
       fBusy := False;
       fKeys.Clear;
       fNodes.Clear;
       fStage := 0;
      End;
     Exit;
    End;
   If fBusy Then
    Begin
     If GetTickCount64 > fDeadline Then
      Begin
       // A partial airport response is never published as a completed procedure.
       Log(1, Format('Procedure request timeout: request=%d attempt=%d', [fRequest, fAttempts]));
       fBusy := False;
       fKeys.Clear;
       fNodes.Clear;
       fStage   := 3;
       fRetryAt := GetTickCount64 + 10000;
      End;
     Exit;
    End;
   If (fStage = 3) And (fAttempts < 3) And (GetTickCount64 >= fRetryAt) Then
    Begin
     fStage := 0;
     fKeys.Clear;
     fNodes.Clear;
    End;
   If fStage >= 2 Then
    Exit;
   If (fPlan.SID = '') And (fPlan.STAR = '') And (fPlan.ApproachType = '') Then
    Begin
     fStage := 2;
     Exit;
    End;
   @fDefine := fSim.FunctionAddress('SimConnect_AddToFacilityDefinition');
   @fFacility := fSim.FunctionAddress('SimConnect_RequestFacilityData');
   @fFacilityEx := fSim.FunctionAddress('SimConnect_RequestFacilityData_EX1');
   If Not Assigned(fDefine) Or (Not Assigned(fFacility) And Not Assigned(fFacilityEx)) Then
    Exit;
   If Not fDefined Then
    Begin
     For S In ProcedureDefinition Do
      Begin
       If fDefine(fSim.Handle, 600, PAnsiChar(S)) < 0 Then
        Begin
         Log(1, 'Procedure definition failed: ' + String(S));
         fStage   := 3;
         fRetryAt := GetTickCount64 + 10000;
         Inc(fAttempts);
         Exit;
        End;
       fSim.TrackAuxiliary('procedure definition: ' + String(S));
      End;
     fDefined := True;
    End;
   NextAirport;
  End;

 Procedure TProcedureReader.NextAirport;
  Var
   Airport : AnsiString;
   HR      : HRESULT;
  Begin
   If fStage = 0 Then
    Airport := AnsiString(fPlan.DepartureICAO)
   Else
    Airport := AnsiString(fPlan.DestinationICAO);
   If fStage = 0 Then
    Inc(fAttempts);
   Inc(fStage);
   If Airport = '' Then
    Begin
     If fStage = 2 Then
      Publish;
     Exit;
    End;
   Inc(fRequest);
   fBusy     := True;
   fDeadline := GetTickCount64 + 30000;
   If Assigned(fFacilityEx) Then
    HR := fFacilityEx(fSim.Handle, 600, fRequest, PAnsiChar(Airport), '', 'A')
   Else
    HR := fFacility(fSim.Handle, 600, fRequest, PAnsiChar(Airport), '');
   fSim.TrackAuxiliary('procedure airport ' + String(Airport));
   Log(2, Format('Procedure airport request: %s id=%d attempt=%d HRESULT=%s', [String(Airport), fRequest, fAttempts, IntToHex(Cardinal(HR), 8)]));
   If HR < 0 Then
    Begin
     fBusy    := False;
     fStage   := 3;
     fRetryAt := GetTickCount64 + 10000;
    End;
  End;

 Procedure TProcedureReader.Feed(p : Pointer; Size : DWORD);
  Var
   ID     : Cardinal;
   Req    : Cardinal;
   k      : Cardinal;
   u      : Cardinal;
   Parent : Cardinal;
   Idx    : Cardinal;
   Cnt    : Cardinal;
   b      : NativeUInt;
   n      : TProcedureNode;
   Key    : String;
  Begin
   If Not fBusy Or (fPlan = Nil) Or (Size < 16) Then
    Exit;
   Move(PByte(NativeUInt(p) + 8)^, ID, 4);
   Move(PByte(NativeUInt(p) + 12)^, Req, 4);
   If Req <> fRequest Then
    Exit;
   If ID = 29 Then
    Begin
     Log(2, Format('Procedure airport received: stage=%d nodes=%d', [fStage, fNodes.Count]));
     fBusy := False;
     If (fStage = 1) And SameText(fPlan.DepartureICAO, fPlan.DestinationICAO) Then
      fStage := 2;
     If fStage = 2 Then
      Publish;
     Exit;
    End;
   If (ID <> 28) Or (Size < 40) Or (fNodes.Count >= 50000) Then
    Exit;
   Move(PByte(NativeUInt(p) + 16)^, u, 4);
   Move(PByte(NativeUInt(p) + 20)^, Parent, 4);
   Move(PByte(NativeUInt(p) + 24)^, k, 4);
   Move(PByte(NativeUInt(p) + 32)^, Idx, 4);
   Move(PByte(NativeUInt(p) + 36)^, Cnt, 4);
   If (k > 13) Or Not(k In [0, 5, 6, 7, 8, 9, 10, 11, 12, 13]) Then
    Exit;
   b := NativeUInt(p) + 40;
   If ((k In [7, 8, 9]) And (Size < 40 + SizeOf(TProcedureLeg))) Or ((k In [6, 10, 11, 12, 13]) And (Size < 48)) Or ((k = 5) And (Size < 56)) Or ((k = 0) And (Size < 44)) Then
    Exit;
   // Retransmission replaces a node; request-local IDs can be reused at the other airport.
   Key := IfThen(fStage = 1, fPlan.DepartureICAO, fPlan.DestinationICAO) + '|' + UIntToStr(u);
   If fKeys.ContainsKey(Key) Then
    Exit;
   n        := TProcedureNode.Create;
   n.ID     := u;
   n.Parent := Parent;
   n.Kind   := k;
   n.Index  := Idx;
   n.Count  := Cnt;
   If fStage = 1 Then
    n.Airport := fPlan.DepartureICAO
   Else
    n.Airport := fPlan.DestinationICAO;
   Case k Of
    0 :
     Move(PByte(b)^, n.MagVar, 4);
    5 :
     Begin
      Move(PByte(b)^, n.ApproachType, 4);
      Move(PByte(b + 4)^, n.Suffix, 4);
      Move(PByte(b + 8)^, n.Runway, 4);
      Move(PByte(b + 12)^, n.Designator, 4);
     End;
    6, 10, 11, 13 :
     n.Name := FixedText(Pointer(b), 8);
    12 :
     Begin
      Move(PByte(b)^, n.Runway, 4);
      Move(PByte(b + 4)^, n.Designator, 4);
     End;
    7, 8, 9 :
     Move(PByte(b)^, n.Leg, SizeOf(n.Leg));
   End;
   fNodes.Add(n);
   fKeys.Add(Key, n);
  End;

 Procedure TProcedureReader.Publish;
  Var
   Root   : TJSONObject;
   o      : TJSONObject;
   a      : TJSONArray;
   n      : TProcedureNode;
   Bytes  : TBytes;
   Counts : TDictionary<String, Integer>;
   Key    : String;
   c      : Integer;

   Procedure Failed(Const Why : String);
    Begin
     Log(1, 'Procedure snapshot rejected: ' + Why);
     fStage   := 3;
     fRetryAt := GetTickCount64 + 10000;
    End;

  Begin
   Counts := TDictionary<String, Integer>.Create;
   Try
    For n In fNodes Do
     Begin
      If (n.Kind <> 0) And Not fKeys.ContainsKey(n.Airport + '|' + UIntToStr(n.Parent)) Then
       Begin
        Failed('missing parent node');
        Exit;
       End;
      Key := n.Airport + '|' + UIntToStr(n.Parent) + '|' + UIntToStr(n.Kind);
      If Not Counts.TryGetValue(Key, c) Then
       c := 0;
      Counts.AddOrSetValue(Key, c + 1);
     End;
    For n In fNodes Do
     If n.Count > 0 Then
      Begin
       Key := n.Airport + '|' + UIntToStr(n.Parent) + '|' + UIntToStr(n.Kind);
       If Not Counts.TryGetValue(Key, c) Or (Cardinal(c) <> n.Count) Then
        Begin
         Failed('incomplete list ' + Key);
         Exit;
        End;
      End;
   Finally
    Counts.Free;
   End;
   Root := TJSONObject.Create;
   a    := TJSONArray.Create;
   Root.AddPair('nodes', a);
   Root.AddPair('version', TJSONNumber.Create(1));
   Try
    For n In fNodes Do
     Begin
      o := TJSONObject.Create;
      a.AddElement(o);
      o.AddPair('id', TJSONNumber.Create(n.ID));
      o.AddPair('parent', TJSONNumber.Create(n.Parent));
      o.AddPair('kind', TJSONNumber.Create(n.Kind));
      o.AddPair('index', TJSONNumber.Create(n.Index));
      o.AddPair('count', TJSONNumber.Create(n.Count));
      o.AddPair('airport', n.Airport);
      o.AddPair('name', n.Name);
      o.AddPair('runway', TJSONNumber.Create(n.Runway));
      o.AddPair('designator', TJSONNumber.Create(n.Designator));
      o.AddPair('approach', TJSONNumber.Create(n.ApproachType));
      o.AddPair('suffix', TJSONNumber.Create(n.Suffix));
      If Not IsNan(n.MagVar) And Not IsInfinite(n.MagVar) Then
       o.AddPair('magvar', TJSONNumber.Create(n.MagVar));
      If n.Kind In [7, 8, 9] Then
       Begin
        SetLength(Bytes, SizeOf(n.Leg));
        Move(n.Leg, Bytes[0], Length(Bytes));
        o.AddPair('leg_le_v1', TNetEncoding.Base64.EncodeBytesToString(Bytes));
       End;
     End;
    If fNodes.Count = 0 Then
     Begin
      Log(1, 'Procedure response has no airport nodes');
      fStage   := 3;
      fRetryAt := GetTickCount64 + 10000;
      Exit;
     End;
    fPlan.ProcedureData := Root.ToJSON;
    ExpandProcedureRoute(fPlan);
    Log(2, Format('Procedure snapshot ready: nodes=%d route_points=%d SID=%s STAR=%s approach=%s%s%s', [fNodes.Count, fPlan.Points.Count, fPlan.SID, fPlan.STAR, fPlan.ApproachType, fPlan.ApproachSuffix, fPlan.ApproachRunway]));
    If fPlan.Points.Count = 0 Then
     Failed('no resolved points for selected procedures');
    If Assigned(OnUpdated) Then
     OnUpdated(Self);
   Finally
    Root.Free;
   End;
  End;

 Function Num(o : TJSONObject; Const Name : String) : Integer;
  Var
   v : TJSONValue;
  Begin
   Result := 0;
   v      := o.GetValue(Name);
   If v <> Nil Then
    TryStrToInt(v.Value, Result);
  End;

 Function Str(o : TJSONObject; Const Name : String) : String;
  Var
   v : TJSONValue;
  Begin
   Result := '';
   v      := o.GetValue(Name);
   If v <> Nil Then
    Result := v.Value;
  End;

 Function RunwayName(n, d : Integer) : String;
  Const
   S : Array [0..6] Of String = ('', 'L', 'R', 'C', 'W', 'A', 'B');
  Begin
   Result := Format('%.2d', [n]);
   If InRange(d, 0, 6) Then
    Result := Result + S[d];
  End;

 Function ApproachNumber(Const Name : String) : Integer;
  Const
   S : Array [0..11] Of String = ('', 'GPS', 'VOR', 'NDB', 'ILS', 'LOCALIZER', 'SDF', 'LDA', 'VORDME', 'NDBDME', 'RNAV', 'LOCALIZER_BACK_COURSE');
  Var
   i : Integer;
  Begin
   Result := -1;
   For i  := 1 To 11 Do
    If SameText(Name, S[i]) Then
     Exit(i);
  End;

 Procedure ExpandProcedureRoute(Plan : TFlightPlan);
  Var
   Root   : TJSONValue;
   v      : TJSONValue;
   a      : TJSONArray;
   o      : TJSONObject;
   Nodes  : TObjectList<TProcedureNode>;
   Lookup : TDictionary<String, TProcedureNode>;
   n      : TProcedureNode;
   p      : TProcedureNode;
   Proc   : TProcedureNode;
   t      : TProcedureNode;
   Chosen : TProcedureNode;
   Bytes  : TBytes;
   Stages : Array [0..2] Of TList<TPlanPoint>;
   i      : Integer;
   Stage  : Integer;
   Group  : Integer;
   Count  : Integer;
   q      : TPlanPoint;
   Prev   : TPlanPoint;
   Gap    : Boolean;

   Function ParentOf(Node : TProcedureNode) : TProcedureNode;
    Begin
     If Not Lookup.TryGetValue(Node.Airport + '|' + UIntToStr(Node.Parent), Result) Then
      Result := Nil;
    End;

   Procedure AppendLeg(Node : TProcedureNode; Target : TList<TPlanPoint>);
    Const
     Types : Array [0..23] Of String = ('', 'AF', 'CA', 'CD', 'CF', 'CI', 'CR', 'DF', 'FA', 'FC', 'FD', 'FM', 'HA', 'HF', 'HM', 'IF', 'PI', 'RF', 'TF', 'VA', 'VD', 'VI', 'VM', 'VR');
    Var
     l        : TProcedureLeg;
     Saved    : TPlanPoint;
     ArcPoint : TPlanPoint;
     CLat     : Double;
     CLon     : Double;
     LatScale : Double;
     R1       : Double;
     R2       : Double;
     A1       : Double;
     A2       : Double;
     Delta    : Double;
     Angle    : Double;
     Step     : Integer;
     Steps    : Integer;
    Begin
     l := Node.Leg;
     If (l.Kind < 1) Or (l.Kind > 23) Or IsNan(l.Lat) Or IsNan(l.Lon) Or IsInfinite(l.Lat) Or IsInfinite(l.Lon) Or (Abs(l.Lat) > 90) Or (Abs(l.Lon) > 180) Or (FixedText(@l.Fix[0], 8) = '') Then
      Begin
       Gap := True;
       Exit;
      End;
     q               := Default(TPlanPoint);
     q.Ident         := FixedText(@l.Fix[0], 8);
     q.Lat           := l.Lat;
     q.Lon           := l.Lon;
     q.ProcedureName := Proc.Name;
     If Proc.Kind = 5 Then
      q.ProcedureName := Plan.ApproachType + Plan.ApproachSuffix + Plan.ApproachRunway;
     q.LegType        := Types[l.Kind];
     q.MissedApproach := Node.Kind = 9;
     q.BreakBefore    := Gap Or (l.Kind = 16) Or (l.Kind In [2, 3, 5, 6, 8, 9, 10, 11, 19, 20, 21, 22, 23]);
     // Manual/vector/altitude terminated legs retain raw metadata; never invent a fix-to-fix connector.
     If l.Kind In [2, 3, 5, 6, 8, 9, 10, 11, 19, 20, 21, 22, 23] Then
      Begin
       Gap := True;
       Exit;
      End;
     q.Course              := l.Course;
     q.TurnDirection       := l.Turn;
     q.RouteDistance       := l.Distance;
     q.DistanceMinute      := l.DistanceMinute <> 0;
     q.TrueCourse          := l.TrueDegree <> 0;
     q.ArcLat              := l.ArcLat;
     q.ArcLon              := l.ArcLon;
     q.Altitude1           := l.Alt1;
     q.Altitude2           := l.Alt2;
     q.AltitudeDescription := l.AltDesc;
     q.SpeedLimit          := l.Speed;
     If Not IsNan(l.Alt1) And Not IsInfinite(l.Alt1) And ((l.AltDesc <> 4) Or (Not IsNan(l.Alt2) And Not IsInfinite(l.Alt2))) Then
      Case l.AltDesc Of
       1 : q.ConstraintText := Format('%.0f', [l.Alt1 / 0.3048]);
       2 : q.ConstraintText := Format('%.0fA', [l.Alt1 / 0.3048]);
       3 : q.ConstraintText := Format('%.0fB', [l.Alt1 / 0.3048]);
       4 : q.ConstraintText := Format('%.0fA/%.0fB', [Min(l.Alt1, l.Alt2) / 0.3048, Max(l.Alt1, l.Alt2) / 0.3048]);
      End;
     If (l.Speed > 0) And Not IsNan(l.Speed) And Not IsInfinite(l.Speed) Then
      q.ConstraintText := Trim(Format('%.0fKT ', [l.Speed]) + q.ConstraintText);
     If l.Kind In [12, 13, 14] Then
      Begin
       If IsNan(l.Course) Or IsInfinite(l.Course) Then
        q.ConstraintText := Trim(q.ConstraintText + ' HOLD --')
       Else
        q.ConstraintText := Trim(q.ConstraintText + ' HOLD ' + Format('%.0f', [l.Course]));
      End;
     If Target.Count > 0 Then
      Begin
       Prev := Target.Last;
       If (Abs(Prev.Lat - q.Lat) < 0.000001) And (Abs(Prev.Lon - q.Lon) < 0.000001) And (Prev.LegType = q.LegType) Then
        Exit;
      End;
     If (l.Kind In [1, 17]) And (Target.Count > 0) Then
      Begin
       Prev := Target.Last;
       CLat := l.ArcLat;
       CLon := l.ArcLon;
       If l.Kind = 1 Then
        Begin
         CLat := l.OriginLat;
         CLon := l.OriginLon;
        End;
       LatScale := Cos(DegToRad(CLat));
       If Not IsNan(CLat) And Not IsNan(CLon) And (Abs(CLat) < 85) And (Abs(CLon) <= 180) And (l.Turn In [1, 2]) Then
        Begin
         R1 := Hypot(Prev.Lat - CLat, (Prev.Lon - CLon) * LatScale);
         R2 := Hypot(q.Lat - CLat, (q.Lon - CLon) * LatScale);
         If (R1 > 0.00001) And (Abs(R1 - R2) < R1 * 0.2) Then
          Begin
           A1    := ArcTan2((Prev.Lon - CLon) * LatScale, Prev.Lat - CLat);
           A2    := ArcTan2((q.Lon - CLon) * LatScale, q.Lat - CLat);
           Delta := A2 - A1;
           If l.Turn = 2 Then
            Begin
             While Delta < 0 Do
              Delta := Delta + 2 * Pi;
            End
           Else
            Begin
             While Delta > 0 Do
              Delta := Delta - 2 * Pi;
            End;
           Steps    := Max(2, Ceil(Abs(Delta) / DegToRad(5)));
           Saved    := q;
           For Step := 1 To Steps - 1 Do
            Begin
             Angle                   := A1 + Delta * Step / Steps;
             ArcPoint                := Saved;
             ArcPoint.Ident          := '';
             ArcPoint.ConstraintText := '';
             ArcPoint.BreakBefore    := False;
             ArcPoint.Lat            := CLat + R2 * Cos(Angle);
             ArcPoint.Lon            := CLon + R2 * Sin(Angle) / LatScale;
             Target.Add(ArcPoint);
            End;
          End
         Else
          q.BreakBefore := True;
        End
       Else
        q.BreakBefore := True;
      End;
     Target.Add(q);
     Gap := l.Kind In [12, 14, 16];
    End;

   Function Selected(Node : TProcedureNode; S : Integer) : Boolean;
    Begin
     Result := False;
     Case S Of
      0 : Result := (Node.Kind = 10) And (Plan.SID <> '') And SameText(Node.Name, Plan.SID) And SameText(Node.Airport, Plan.DepartureICAO);
      1 : Result := (Node.Kind = 11) And (Plan.STAR <> '') And SameText(Node.Name, Plan.STAR) And SameText(Node.Airport, Plan.DestinationICAO);
      2 : Result := (Node.Kind = 5) And (Node.ApproachType = ApproachNumber(Plan.ApproachType)) And SameText(Node.Airport, Plan.DestinationICAO) And SameText(RunwayName(Node.Runway, Node.Designator), Plan.ApproachRunway) And (((Node.Suffix = 0) Or (Node.Suffix = 32)) And (Plan.ApproachSuffix = '') Or ((Node.Suffix > 32) And SameText(Char(Node.Suffix), Plan.ApproachSuffix)));
     End;
    End;

   Function TransitionSelected(Node : TProcedureNode; S : Integer) : Boolean;
    Var
     Name : String;
     Rwy  : String;
    Begin
     Name := '';
     Rwy  := '';
     Case S Of
      0 :
       Begin
        Name := Plan.SIDTransition;
        Rwy  := Plan.DepartureRunway;
       End;
      1 :
       Begin
        Name := Plan.STARTransition;
        Rwy  := Plan.DestinationRunway;
       End;
      2 :
       Name := Plan.ApproachTransition;
     End;
     If Node.Kind = 12 Then
      Result := (Rwy <> '') And SameText(RunwayName(Node.Runway, Node.Designator), Rwy)
     Else
      Result := (Name <> '') And SameText(Name, Node.Name);
    End;

  Begin
   If (Plan = Nil) Or (Plan.ProcedureData = '') Then
    Exit;
   If Not Plan.BasePointsCaptured Then
    Begin
     Plan.BasePoints         := Plan.Points.ToArray;
     Plan.BasePointsCaptured := True;
    End;
   Root       := TJSONObject.ParseJSONValue(Plan.ProcedureData);
   Nodes      := TObjectList<TProcedureNode>.Create;
   Lookup     := TDictionary<String, TProcedureNode>.Create;
   For i      := 0 To 2 Do
    Stages[i] := TList<TPlanPoint>.Create;
   Try
    If Not(Root Is TJSONObject) Then
     Exit;
    v := TJSONObject(Root).GetValue('nodes');
    If Not(v Is TJSONArray) Then
     Exit;
    a := TJSONArray(v);
    If a.Count > 50000 Then
     Exit;
    For v In a Do
     If v Is TJSONObject Then
      Begin
       o := TJSONObject(v);
       n := TProcedureNode.Create;
       Nodes.Add(n);
       n.ID           := Num(o, 'id');
       n.Parent       := Num(o, 'parent');
       n.Kind         := Num(o, 'kind');
       n.Index        := Num(o, 'index');
       n.Count        := Num(o, 'count');
       n.Airport      := Str(o, 'airport');
       n.Name         := Str(o, 'name');
       n.Runway       := Num(o, 'runway');
       n.Designator   := Num(o, 'designator');
       n.ApproachType := Num(o, 'approach');
       n.Suffix       := Num(o, 'suffix');
       Lookup.AddOrSetValue(n.Airport + '|' + UIntToStr(n.ID), n);
       If n.Kind In [7, 8, 9] Then
        Begin
         Try
          Bytes := TNetEncoding.Base64.DecodeStringToBytes(Str(o, 'leg_le_v1'));
         Except
          SetLength(Bytes, 0);
         End;
         If Length(Bytes) = SizeOf(n.Leg) Then
          Move(Bytes[0], n.Leg, SizeOf(n.Leg))
         Else
          n.Leg.Kind := 0;
        End;
      End;
    Nodes.Sort(TComparer<TProcedureNode>.Construct(
    Function(Const l, r : TProcedureNode) : Integer
    Begin
    If l.Parent = r.Parent Then
    Result := CompareValue(l.Index, r.Index)
    Else
    Result := CompareValue(l.Parent, r.Parent);
    End));
    For Stage := 0 To 2 Do
     Begin
      Chosen := Nil;
      Count  := 0;
      For n In Nodes Do
       If Selected(n, Stage) Then
        Begin
         Chosen := n;
         Inc(Count);
        End;
      If Count <> 1 Then
       Continue;
      Proc := Chosen;
      Gap  := True;
      // SID runway/common/enroute; STAR enroute/common/runway; approach transition/final/missed.
      For Group := 0 To 2 Do
       For n In Nodes Do
        If n.Kind In [7, 8, 9] Then
         Begin
          p := ParentOf(n);
          If p = Nil Then
           Continue;
          If p = Proc Then
           Begin
            If Stage < 2 Then
             Begin
              If Group = 1 Then
               AppendLeg(n, Stages[Stage]);
             End
            Else If ((Group = 1) And (n.Kind = 8)) Or ((Group = 2) And (n.Kind = 9)) Then
             AppendLeg(n, Stages[Stage]);
           End
          Else
           Begin
            t := ParentOf(p);
            If t <> Proc Then
             Continue;
            If Not TransitionSelected(p, Stage) Then
             Continue;
            If ((Stage = 0) And (((Group = 0) And (p.Kind = 12)) Or ((Group = 2) And (p.Kind = 13)))) Or ((Stage = 1) And (((Group = 0) And (p.Kind = 13)) Or ((Group = 2) And (p.Kind = 12)))) Or ((Stage = 2) And (Group = 0) And (p.Kind = 6)) Then
             AppendLeg(n, Stages[Stage]);
           End;
         End;
     End;
    If (Stages[0].Count + Stages[1].Count + Stages[2].Count) = 0 Then
     Exit;
    Plan.Points.Clear;
    If Stages[0].Count > 0 Then
     For q In Plan.BasePoints Do
      If SameText(q.Ident, Plan.DepartureICAO) Then
       Plan.Points.Add(q);
    For q In Stages[0] Do
     Plan.Points.Add(q);
    For q In Plan.BasePoints Do
     Begin
      If ((Stages[0].Count > 0) And SameText(q.Ident, Plan.DepartureICAO)) Or ((Stages[1].Count + Stages[2].Count > 0) And SameText(q.Ident, Plan.DestinationICAO)) Then
       Continue;
      If (Stages[2].Count > 0) And (q.ProcedureName <> '') And SameText(q.ProcedureName, Plan.ApproachType) Then
       Continue;
      If (q.ProcedureName <> '') And ((Stages[0].Count > 0) And SameText(q.ProcedureName, Plan.SID) Or (Stages[1].Count > 0) And SameText(q.ProcedureName, Plan.STAR)) Then
       Continue;
      Count := 0;
      For i := 0 To 2 Do
       For Prev In Stages[i] Do
        If (Abs(Prev.Lat - q.Lat) < 0.00001) And (Abs(Prev.Lon - q.Lon) < 0.00001) Then
         Inc(Count);
      If Count = 0 Then
       Plan.Points.Add(q);
     End;
    For i := 1 To 2 Do
     For q In Stages[i] Do
      Plan.Points.Add(q);
    If (Stages[1].Count > 0) And (Stages[2].Count = 0) Then
     For q In Plan.BasePoints Do
      If SameText(q.Ident, Plan.DestinationICAO) Then
       Plan.Points.Add(q);
   Finally
    For i := 0 To 2 Do
     Stages[i].Free;
    Lookup.Free;
    Nodes.Free;
    Root.Free;
   End;
  End;

 Procedure UnwrapRecordedPlan(Const Format, Raw : String; Out BaseFormat, BaseRaw : String);
  Var
   v : TJSONValue;
  Begin
   BaseFormat := Format;
   BaseRaw    := Raw;
   If Format <> 'FDR ROUTE' Then
    Exit;
   v := TJSONObject.ParseJSONValue(Raw);
   Try
    If Not(v Is TJSONObject) Then
     Raise Exception.Create('Invalid recorded route');
    BaseFormat := Str(TJSONObject(v), 'format');
    BaseRaw    := Str(TJSONObject(v), 'raw');
   Finally
    v.Free;
   End;
  End;

 Function EncodeRecordedPlan(Plan : TFlightPlan) : String;
  Var
   o : TJSONObject;
  Begin
   Result := Plan.Raw;
   If Plan.ProcedureData = '' Then
    Exit;
   o := TJSONObject.Create;
   Try
    o.AddPair('format', Plan.Format);
    o.AddPair('raw', Plan.Raw);
    o.AddPair('procedures', TJSONObject.ParseJSONValue(Plan.ProcedureData));
    Result := o.ToJSON;
   Finally
    o.Free;
   End;
  End;

 Function DecodeRecordedPlan(Const Format, Raw, Path : String) : TFlightPlan;
  Var
   o : TJSONValue;
   f : String;
   r : String;
   v : TJSONValue;
  Begin
   If Format = 'FDR ROUTE' Then
    Begin
     o := TJSONObject.ParseJSONValue(Raw);
     Try
      If Not(o Is TJSONObject) Then
       Raise Exception.Create('Invalid recorded route');
      f := Str(TJSONObject(o), 'format');
      r := Str(TJSONObject(o), 'raw');
      If f = 'PLN' Then
       Result := ParsePLN(r, Path)
      Else If f = 'EFB JSON' Then
       Result := ParseEFBRoute(r)
      Else
       Raise Exception.Create('Unknown recorded route source');
      Try
       v := TJSONObject(o).GetValue('procedures');
       If v <> Nil Then
        Result.ProcedureData := v.ToJSON;
       ExpandProcedureRoute(Result);
      Except
       Result.Free;
       Raise;
      End;
     Finally
      o.Free;
     End;
    End
   Else If Format = 'PLN' Then
    Result := ParsePLN(Raw, Path)
   Else
    Result := ParseEFBRoute(Raw);
  End;

End.
