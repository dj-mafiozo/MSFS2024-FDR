{$StackFrames On}
Unit FlightPlanU;

Interface

 Uses
  LocalizationU, System.SysUtils, System.Classes, System.Math, System.Variants,
  System.JSON, System.Generics.Collections, Xml.XMLDoc, Xml.XMLIntf, Winapi.Windows,
  Winapi.ActiveX, System.StrUtils;

 Type
  TPlanPoint = Record
   Ident               : String;
   ProcedureName       : String;
   ConstraintText      : String;
   LegType             : String;
   MissedApproach      : Boolean;
   Course              : Double;
   RouteDistance       : Double;
   ArcLat              : Double;
   ArcLon              : Double;
   Altitude1           : Double;
   Altitude2           : Double;
   SpeedLimit          : Double;
   TurnDirection       : Integer;
   AltitudeDescription : Integer;
   TrueCourse          : Boolean;
   DistanceMinute      : Boolean;
   Lat                 : Double;
   Lon                 : Double;
   BreakBefore         : Boolean;
  End;

  TFlightPlan = Class
   DepartureICAO      : String;
   DestinationICAO    : String;
   SID                : String;
   STAR               : String;
   SIDTransition      : String;
   STARTransition     : String;
   DepartureRunway    : String;
   DestinationRunway  : String;
   ApproachType       : String;
   ApproachRunway     : String;
   ApproachSuffix     : String;
   ApproachTransition : String;
   ProcedureData      : String;
   BasePoints         : TArray<TPlanPoint>;
   BasePointsCaptured : Boolean;
   Source             : String;
   Path               : String;
   Format             : String;
   Raw                : String;
   Summary            : String;
   Points             : TList<TPlanPoint>;
   Constructor Create;
   Destructor  Destroy; Override;
  End;

 Procedure ResolvePlanNames(Plan : TFlightPlan; Const SimBriefJSON : String);
 Function ParsePLN(Const Raw, Path : String) : TFlightPlan;
 Function ParseEFBRoute(Const Raw : String) : TFlightPlan;

Implementation

 Constructor TFlightPlan.Create;
  Begin
   Inherited;
   Points := TList<TPlanPoint>.Create;
  End;

 Destructor TFlightPlan.Destroy;
  Begin
   Points.Free;
   Inherited;
  End;

 Function Child(n : IXMLNode; Const Name : String) : IXMLNode;
  Begin
   Result := Nil;
   If Assigned(n) Then
    Result := n.ChildNodes.FindNode(Name);
  End;

 Function Value(n : IXMLNode; Const Name : String) : String;
  Begin
   n      := Child(n, Name);
   Result := '';
   If Assigned(n) Then
    Result := n.Text;
  End;

 Procedure Append(Var s : String; Const v : String);
  Begin
   If v <> '' Then
    Begin
     If s <> '' Then
      s := s + ' ';
     s  := s + v;
    End;
  End;

 Function Runway(n : IXMLNode) : String;
  Var
   v : String;
   i : Integer;
  Begin
   v := Value(n, 'RunwayNumberFP');
   If TryStrToInt(v, i) Then
    v     := System.SysUtils.Format('%.2d', [i]);
   Result := v + Value(n, 'RunwayDesignatorFP');
  End;

 Function Coordinate(Const s : String; Latitude : Boolean; Out v : Double) : Boolean;
  Var
   t     : String;
   Parts : TArray<String>;
   d     : Double;
   m     : Double;
   Sec   : Double;
   FS    : TFormatSettings;
   Neg   : Boolean;
  Begin
   Result := False;
   t      := Trim(s);
   If t = '' Then
    Exit;
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   Neg                 := CharInSet(UpCase(t[1]), ['S', 'W']);
   If CharInSet(UpCase(t[1]), ['N', 'S', 'E', 'W']) Then
    Delete(t, 1, 1);
   t     := t.Replace(#$00B0, ' ').Replace('''', ' ').Replace('"', ' ');
   Parts := t.Split([' '], TStringSplitOptions.ExcludeEmpty);
   If Length(Parts) = 1 Then
    Begin
     If Not TryStrToFloat(Parts[0], v, FS) Then
      Exit;
    End
   Else
    Begin
     If (Length(Parts) <> 3) Or Not TryStrToFloat(Parts[0], d, FS) Or Not TryStrToFloat(Parts[1], m, FS) Or Not TryStrToFloat(Parts[2], Sec, FS) Then
      Exit;
     If (m < 0) Or (m >= 60) Or (Sec < 0) Or (Sec >= 60) Then
      Exit;
     v := d + m / 60 + Sec / 3600;
    End;
   If Neg Then
    v     := -v;
   Result := Not IsNan(v) And Not IsInfinite(v) And (Abs(v) <= 180);
   If Latitude Then
    Result := Result And (Abs(v) <= 90);
  End;

 Function ParsePLN(Const Raw, Path : String) : TFlightPlan;
  Var
   Doc       : IXMLDocument;
   n         : IXMLNode;
   w         : IXMLNode;
   d         : IXMLNode;
   a         : IXMLNode;
   p         : IXMLNode;
   i         : Integer;
   r         : String;
   Dep       : String;
   Dest      : String;
   c         : TArray<String>;
   Point     : TPlanPoint;
   Gap       : Boolean;
   Apartment : HRESULT;
  Begin
   Apartment := CoInitialize(Nil);
   Try
    // No external declarations/entities are needed in a simulator flight plan.
    If (Pos('<!DOCTYPE', UpperCase(Raw)) > 0) Or (Pos('<!ENTITY', UpperCase(Raw)) > 0) Then
     Raise Exception.Create(Tr('Unsupported XML declaration'));
    Doc := LoadXMLData(Raw);
    n   := Child(Doc.DocumentElement, 'FlightPlan.FlightPlan');
    If Not Assigned(n) Then
     Raise Exception.Create(Tr('Missing FlightPlan.FlightPlan'));
    Result := TFlightPlan.Create;
    Try
     Result.Source := 'SimConnect PLN';
     Result.Path   := Path;
     Result.Format := 'PLN';
     Result.Raw    := Raw;
     d             := Child(n, 'DepartureDetails');
     a             := Child(n, 'ArrivalDetails');
     p             := Child(n, 'ApproachDetails');
     Dep           := Value(n, 'DepartureID');
     Dest          := Value(n, 'DestinationID');
     If (Dep = '') And (Dest = '') Then
      Raise Exception.Create(Tr('Flight plan has no airports'));
     Result.DepartureICAO      := UpperCase(Trim(Dep));
     Result.DestinationICAO    := UpperCase(Trim(Dest));
     Result.SID                := Value(d, 'DepartureFP');
     Result.STAR               := Value(a, 'ArrivalFP');
     Result.SIDTransition      := Value(d, 'TransitionFP');
     Result.STARTransition     := Value(a, 'TransitionFP');
     Result.DepartureRunway    := Runway(d);
     Result.DestinationRunway  := Runway(a);
     Result.ApproachType       := Value(p, 'ApproachTypeFP');
     Result.ApproachSuffix     := Value(p, 'SuffixFP');
     Result.ApproachRunway     := Runway(p);
     Result.ApproachTransition := Value(p, 'TransitionFP');
     r                         := Dep;
     If Runway(d) <> '' Then
      r := r + '.' + Runway(d);
     Append(r, Value(d, 'DepartureFP'));
     Append(r, Value(a, 'ArrivalFP'));
     Append(r, Value(p, 'TransitionFP'));
     If Value(p, 'ApproachTypeFP') <> '' Then
      Append(r, Value(p, 'ApproachTypeFP') + Value(p, 'SuffixFP') + '.' + Runway(p));
     If Runway(a) <> '' Then
      Dest := Dest + '.' + Runway(a);
     Append(r, Dest);
     Result.Summary := r;
     Gap            := False;
     For i          := 0 To n.ChildNodes.Count - 1 Do
      Begin
       w := n.ChildNodes[i];
       If w.NodeName <> 'ATCWaypoint' Then
        Continue;
       c           := Value(w, 'WorldPosition').Split([',']);
       Point       := Default(TPlanPoint);
       Point.Ident := VarToStr(w.Attributes['id']);
       If Result.SID = '' Then
        Result.SID := Value(w, 'DepartureFP');
       If Result.STAR = '' Then
        Result.STAR := Value(w, 'ArrivalFP');
       If Result.ApproachType = '' Then
        Result.ApproachType := Value(w, 'ApproachTypeFP');
       If (Result.DepartureRunway = '') And (Value(w, 'DepartureFP') <> '') Then
        Result.DepartureRunway := Runway(w);
       If (Result.DestinationRunway = '') And (Value(w, 'ArrivalFP') <> '') Then
        Result.DestinationRunway := Runway(w);
       If (Result.ApproachRunway = '') And (Value(w, 'ApproachTypeFP') <> '') Then
        Begin
         Result.ApproachRunway := Runway(w);
         Result.ApproachSuffix := Value(w, 'SuffixFP');
        End;

       Point.ProcedureName := Value(w, 'DepartureFP');
       If Point.ProcedureName = '' Then
        Point.ProcedureName := Value(w, 'ArrivalFP');
       If Point.ProcedureName = '' Then
        Point.ProcedureName := Value(w, 'ApproachTypeFP');
       // Retain explicit constraints; WorldPosition altitude is not a restriction.
       Case IndexText(Value(w, 'AltDescFP'), ['ALT_DESC_AT_OR_BELOW', 'ALT_DESC_AT', 'ALT_DESC_AT_OR_ABOVE', 'ALT_DESC_IN_BETWEEN']) Of
        0 : Point.ConstraintText := Value(w, 'Alt1FP') + 'B';
        1 : Point.ConstraintText := Value(w, 'Alt1FP');
        2 : Point.ConstraintText := Value(w, 'Alt1FP') + 'A';
        3 : Point.ConstraintText := Value(w, 'Alt1FP') + 'A / ' + Value(w, 'Alt2FP') + 'B';
       End;
       If (Value(w, 'SpeedMaxFP') <> '') And (Value(w, 'SpeedMaxFP') <> '-1') Then
        Point.ConstraintText := Trim(Value(w, 'SpeedMaxFP') + 'KT ' + Point.ConstraintText);
       Point.BreakBefore     := Gap;
       If (Length(c) >= 2) And Coordinate(c[0], True, Point.Lat) And Coordinate(c[1], False, Point.Lon) Then
        Begin
         Result.Points.Add(Point);
         Gap := False;
        End
       Else
        Gap := True;
      End;
    Except
     Result.Free;
     Raise;
    End;
   Finally
    n   := Nil;
    w   := Nil;
    d   := Nil;
    a   := Nil;
    p   := Nil;
    Doc := Nil;
    If Apartment >= 0 Then
     CoUninitialize;
   End;
  End;

 Function JString(o : TJSONObject; Const Name : String) : String;
  Var
   v : TJSONValue;
  Begin
   Result := '';
   If o = Nil Then
    Exit;
   v := o.GetValue(Name);
   If (v <> Nil) And Not(v Is TJSONNull) Then
    If v Is TJSONNumber Then
     Result := v.ToJSON
    Else
     Result := v.Value;
  End;

 Function JObject(o : TJSONObject; Const Name : String) : TJSONObject;
  Var
   v : TJSONValue;
  Begin
   Result := Nil;
   If o = Nil Then
    Exit;
   v := o.GetValue(Name);
   If v Is TJSONObject Then
    Result := TJSONObject(v);
  End;

 Function JRunway(o : TJSONObject) : String;
  Begin
   Result := JString(o, 'number') + JString(o, 'designator');
  End;

 Function ParseEFBRoute(Const Raw : String) : TFlightPlan;
  Var
   v        : TJSONValue;
   o        : TJSONObject;
   l        : TJSONObject;
   Approach : TJSONObject;
   a        : TJSONArray;
   Item     : TJSONValue;
   r        : String;
   Dep      : String;
   Dest     : String;
   Point    : TPlanPoint;
   Gap      : Boolean;
   FS       : TFormatSettings;
  Begin
   v := TJSONObject.ParseJSONValue(Raw);
   If Not(v Is TJSONObject) Then
    Begin
     v.Free;
     Raise Exception.Create(Tr('Invalid EFB route JSON'));
    End;
   o      := TJSONObject(v);
   Result := TFlightPlan.Create;
   Try
    Try
     Result.Source := 'MSFS24 EFB';
     Result.Format := 'EFB JSON';
     Result.Raw    := Raw;
     Dep           := JString(JObject(o, 'departureAirport'), 'ident');
     Dest          := JString(JObject(o, 'destinationAirport'), 'ident');
     If (Dep = '') And (Dest = '') Then
      Raise Exception.Create(Tr('EFB route has no airports'));
     Result.DepartureICAO      := UpperCase(Trim(Dep));
     Result.DestinationICAO    := UpperCase(Trim(Dest));
     Result.SID                := JString(o, 'departure');
     Result.STAR               := JString(o, 'arrival');
     Result.SIDTransition      := JString(o, 'departureTransition');
     Result.STARTransition     := JString(o, 'arrivalTransition');
     Result.DepartureRunway    := JRunway(JObject(o, 'departureRunway'));
     Result.DestinationRunway  := JRunway(JObject(o, 'destinationRunway'));
     Result.ApproachType       := JString(JObject(o, 'approach'), 'type');
     Result.ApproachSuffix     := JString(JObject(o, 'approach'), 'suffix');
     Result.ApproachRunway     := JRunway(JObject(JObject(o, 'approach'), 'runway'));
     Result.ApproachTransition := JString(o, 'approachTransition');
     r                         := Dep;
     If JRunway(JObject(o, 'departureRunway')) <> '' Then
      r := r + '.' + JRunway(JObject(o, 'departureRunway'));
     Append(r, JString(o, 'departure'));
     Append(r, JString(o, 'departureTransition'));
     Item                := o.GetValue('enroute');
     Gap                 := True;
     FS                  := TFormatSettings.Create;
     FS.DecimalSeparator := '.';
     If Item Is TJSONArray Then
      Begin
       a := TJSONArray(Item);
       For Item In a Do
        If Item Is TJSONObject Then
         Begin
          l           := TJSONObject(Item);
          Point       := Default(TPlanPoint);
          Point.Ident := JString(JObject(l, 'fixIcao'), 'ident');
          If Point.Ident <> '' Then
           Begin
            If JString(l, 'via') = '' Then
             Append(r, 'DCT')
            Else
             Append(r, JString(l, 'via'));
            Append(r, Point.Ident);
           End;
          // Do not draw fictitious coordinates for facility references or PPOS.
          If SameText(JString(l, 'hasLatLon'), 'true') And Not SameText(JString(l, 'isPpos'), 'true') And TryStrToFloat(JString(l, 'lat'), Point.Lat, FS) And TryStrToFloat(JString(l, 'lon'), Point.Lon, FS) And Not IsNan(Point.Lat) And Not IsInfinite(Point.Lat) And Not IsNan(Point.Lon) And Not IsInfinite(Point.Lon) And (Abs(Point.Lat) <= 90) And (Abs(Point.Lon) <= 180) Then
           Begin
            Point.BreakBefore := Gap;
            Result.Points.Add(Point);
            Gap := False;
           End
          Else
           Gap := True;
         End;
      End;
     Append(r, JString(o, 'arrivalTransition'));
     Append(r, JString(o, 'arrival'));
     Append(r, JString(o, 'approachTransition'));
     Approach := JObject(o, 'approach');
     If JString(Approach, 'type') <> '' Then
      Append(r, JString(Approach, 'type') + JString(Approach, 'suffix') + '.' + JRunway(JObject(Approach, 'runway')));
     If JRunway(JObject(o, 'destinationRunway')) <> '' Then
      Dest := Dest + '.' + JRunway(JObject(o, 'destinationRunway'));
     Append(r, Dest);
     Result.Summary := r;
    Except
     Result.Free;
     Raise;
    End;
   Finally
    v.Free;
   End;
  End;

 Procedure ResolvePlanNames(Plan : TFlightPlan; Const SimBriefJSON : String);
  Var
   Root  : TJSONValue;
   Nav   : TJSONValue;
   Fixes : TJSONValue;
   Fix   : TJSONValue;
   i     : Integer;
   j     : Integer;
   Best  : Integer;
   p     : TPlanPoint;
   Lat   : Double;
   Lon   : Double;
   d     : Double;
   BestD : Double;
   FS    : TFormatSettings;
   Name  : String;
  Begin
   If (Plan = Nil) Or (SimBriefJSON = '') Then
    Exit;
   Root := TJSONObject.ParseJSONValue(SimBriefJSON);
   Try
    If Not(Root Is TJSONObject) Then
     Exit;
    Nav := TJSONObject(Root).GetValue('navlog');
    If Not(Nav Is TJSONObject) Then
     Exit;
    Fixes := TJSONObject(Nav).GetValue('fix');
    If Not(Fixes Is TJSONArray) Then
     Exit;
    FS    := TFormatSettings.Create('en-US');
    For i := 0 To Plan.Points.Count - 1 Do
     Begin
      p := Plan.Points[i];
      If (Trim(p.Ident) <> '') And Not SameText(p.Ident, 'USER') And Not SameText(p.Ident, 'CUSTOM') And (Pos(',', p.Ident) = 0) And (Pos('/', p.Ident) = 0) Then
       Continue;
      Best  := -1;
      BestD := Sqr(0.5 / 60); // half nautical mile, reject ambiguous matches
      For j := 0 To TJSONArray(Fixes).Count - 1 Do
       Begin
        Fix := TJSONArray(Fixes).Items[j];
        If Not(Fix Is TJSONObject) Then
         Continue;
        If Not TryStrToFloat(JString(TJSONObject(Fix), 'pos_lat'), Lat, FS) Or Not TryStrToFloat(JString(TJSONObject(Fix), 'pos_long'), Lon, FS) Then
         Continue;
        d := Sqr(Lat - p.Lat) + Sqr((Lon - p.Lon) * Cos(DegToRad(p.Lat)));
        If d < BestD Then
         Begin
          BestD := d;
          Best  := j;
         End;
       End;
      If Best >= 0 Then
       Begin
        Fix  := TJSONArray(Fixes).Items[Best];
        Name := JString(TJSONObject(Fix), 'ident');
        If Name <> '' Then
         Begin
          p.Ident        := Name;
          Plan.Points[i] := p;
         End;
       End;
     End;
   Finally
    Root.Free;
   End;
  End;

End.
