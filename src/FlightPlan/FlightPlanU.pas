Unit FlightPlanU;

Interface

 Uses
  LocalizationU, System.SysUtils, System.Classes, System.Math, System.Variants,
  System.JSON, System.Generics.Collections, Xml.XMLDoc, Xml.XMLIntf, Winapi.Windows,
  Winapi.ActiveX;

 Type
  TPlanPoint = Record
   Public
    Ident       : String;
    Lat         : Double;
    Lon         : Double;
    BreakBefore : Boolean;
  End;

  TFlightPlan = Class
   Public
    Source  : String;
    Path    : String;
    Format  : String;
    Raw     : String;
    Summary : String;
    Points  : TList<TPlanPoint>;
    Constructor Create;
    Destructor Destroy; Override;
  End;

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

 Function Child(N : IXMLNode; Const Name : String) : IXMLNode;
  Begin
   Result := Nil;
   If Assigned(N) Then
    Result := N.ChildNodes.FindNode(Name);
  End;

 Function Value(N : IXMLNode; Const Name : String) : String;
  Begin
   N      := Child(N, Name);
   Result := '';
   If Assigned(N) Then
    Result := N.Text;
  End;

 Procedure Append(Var S : String; Const V : String);
  Begin
   If V <> '' Then
    Begin
     If S <> '' Then
      S := S + ' ';
     S  := S + V;
    End;
  End;

 Function Runway(N : IXMLNode) : String;
  Var
   V : String;
   I : Integer;
  Begin
   V := Value(N, 'RunwayNumberFP');
   If TryStrToInt(V, I) Then
    V     := System.SysUtils.Format('%.2d', [I]);
   Result := V + Value(N, 'RunwayDesignatorFP');
  End;

 Function Coordinate(Const S : String; Latitude : Boolean; Out V : Double) : Boolean;
  Var
   T     : String;
   Parts : TArray<String>;
   D     : Double;
   M     : Double;
   Sec   : Double;
   FS    : TFormatSettings;
   Neg   : Boolean;
  Begin
   Result := False;
   T      := Trim(S);
   If T = '' Then
    Exit;
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   Neg                 := CharInSet(UpCase(T[1]), ['S', 'W']);
   If CharInSet(UpCase(T[1]), ['N', 'S', 'E', 'W']) Then
    Delete(T, 1, 1);
   T     := T.Replace(#$00B0, ' ').Replace('''', ' ').Replace('"', ' ');
   Parts := T.Split([' '], TStringSplitOptions.ExcludeEmpty);
   If Length(Parts) = 1 Then
    Begin
     If Not TryStrToFloat(Parts[0], V, FS) Then
      Exit;
    End
   Else
    Begin
     If (Length(Parts) <> 3) Or Not TryStrToFloat(Parts[0], D, FS) Or Not TryStrToFloat(Parts[1], M, FS) Or Not TryStrToFloat(Parts[2], Sec, FS) Then
      Exit;
     If (M < 0) Or (M >= 60) Or (Sec < 0) Or (Sec >= 60) Then
      Exit;
     V := D + M / 60 + Sec / 3600;
    End;
   If Neg Then
    V     := -V;
   Result := Not IsNan(V) And Not IsInfinite(V) And (Abs(V) <= 180);
   If Latitude Then
    Result := Result And (Abs(V) <= 90);
  End;

 Function ParsePLN(Const Raw, Path : String) : TFlightPlan;
  Var
   Doc       : IXMLDocument;
   N         : IXMLNode;
   W         : IXMLNode;
   D         : IXMLNode;
   A         : IXMLNode;
   P         : IXMLNode;
   I         : Integer;
   R         : String;
   Dep       : String;
   Dest      : String;
   C         : TArray<String>;
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
    N   := Child(Doc.DocumentElement, 'FlightPlan.FlightPlan');
    If Not Assigned(N) Then
     Raise Exception.Create(Tr('Missing FlightPlan.FlightPlan'));
    Result := TFlightPlan.Create;
    Try
     Result.Source := 'SimConnect PLN';
     Result.Path   := Path;
     Result.Format := 'PLN';
     Result.Raw    := Raw;
     D             := Child(N, 'DepartureDetails');
     A             := Child(N, 'ArrivalDetails');
     P             := Child(N, 'ApproachDetails');
     Dep           := Value(N, 'DepartureID');
     Dest          := Value(N, 'DestinationID');
     If (Dep = '') And (Dest = '') Then
      Raise Exception.Create(Tr('Flight plan has no airports'));
     R := Dep;
     If Runway(D) <> '' Then
      R := R + '.' + Runway(D);
     Append(R, Value(D, 'DepartureFP'));
     Append(R, Value(A, 'ArrivalFP'));
     Append(R, Value(P, 'TransitionFP'));
     If Value(P, 'ApproachTypeFP') <> '' Then
      Append(R, Value(P, 'ApproachTypeFP') + Value(P, 'SuffixFP') + '.' + Runway(P));
     If Runway(A) <> '' Then
      Dest := Dest + '.' + Runway(A);
     Append(R, Dest);
     Result.Summary := R;
     Gap            := False;
     For I          := 0 To N.ChildNodes.Count - 1 Do
      Begin
       W := N.ChildNodes[I];
       If W.NodeName <> 'ATCWaypoint' Then
        Continue;
       C                 := Value(W, 'WorldPosition').Split([',']);
       Point             := Default (TPlanPoint);
       Point.Ident       := VarToStr(W.Attributes['id']);
       Point.BreakBefore := Gap;
       If (Length(C) >= 2) And Coordinate(C[0], True, Point.Lat) And Coordinate(C[1], False, Point.Lon) Then
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
    N   := Nil;
    W   := Nil;
    D   := Nil;
    A   := Nil;
    P   := Nil;
    Doc := Nil;
    If Apartment >= 0 Then
     CoUninitialize;
   End;
  End;

 Function JString(O : TJSONObject; Const Name : String) : String;
  Var
   V : TJSONValue;
  Begin
   Result := '';
   If O = Nil Then
    Exit;
   V := O.GetValue(Name);
   If (V <> Nil) And Not(V Is TJSONNull) Then
    If V Is TJSONNumber Then
     Result := V.ToJSON
    Else
     Result := V.Value;
  End;

 Function JObject(O : TJSONObject; Const Name : String) : TJSONObject;
  Var
   V : TJSONValue;
  Begin
   Result := Nil;
   If O = Nil Then
    Exit;
   V := O.GetValue(Name);
   If V Is TJSONObject Then
    Result := TJSONObject(V);
  End;

 Function JRunway(O : TJSONObject) : String;
  Begin
   Result := JString(O, 'number') + JString(O, 'designator');
  End;

 Function ParseEFBRoute(Const Raw : String) : TFlightPlan;
  Var
   V        : TJSONValue;
   O        : TJSONObject;
   L        : TJSONObject;
   Approach : TJSONObject;
   A        : TJSONArray;
   Item     : TJSONValue;
   R        : String;
   Dep      : String;
   Dest     : String;
   Point    : TPlanPoint;
   Gap      : Boolean;
   FS       : TFormatSettings;
  Begin
   V := TJSONObject.ParseJSONValue(Raw);
   If Not(V Is TJSONObject) Then
    Begin
     V.Free;
     Raise Exception.Create(Tr('Invalid EFB route JSON'));
    End;
   O      := TJSONObject(V);
   Result := TFlightPlan.Create;
   Try
    Try
     Result.Source := 'MSFS24 EFB';
     Result.Format := 'EFB JSON';
     Result.Raw    := Raw;
     Dep           := JString(JObject(O, 'departureAirport'), 'ident');
     Dest          := JString(JObject(O, 'destinationAirport'), 'ident');
     If (Dep = '') And (Dest = '') Then
      Raise Exception.Create(Tr('EFB route has no airports'));
     R := Dep;
     If JRunway(JObject(O, 'departureRunway')) <> '' Then
      R := R + '.' + JRunway(JObject(O, 'departureRunway'));
     Append(R, JString(O, 'departure'));
     Append(R, JString(O, 'departureTransition'));
     Item                := O.GetValue('enroute');
     Gap                 := True;
     FS                  := TFormatSettings.Create;
     FS.DecimalSeparator := '.';
     If Item Is TJSONArray Then
      Begin
       A := TJSONArray(Item);
       For Item In A Do
        If Item Is TJSONObject Then
         Begin
          L           := TJSONObject(Item);
          Point       := Default (TPlanPoint);
          Point.Ident := JString(JObject(L, 'fixIcao'), 'ident');
          If Point.Ident <> '' Then
           Begin
            If JString(L, 'via') = '' Then
             Append(R, 'DCT')
            Else
             Append(R, JString(L, 'via'));
            Append(R, Point.Ident);
           End;
          // Do not draw fictitious coordinates for facility references or PPOS.
          If SameText(JString(L, 'hasLatLon'), 'true') And Not SameText(JString(L, 'isPpos'), 'true') And TryStrToFloat(JString(L, 'lat'), Point.Lat, FS) And TryStrToFloat(JString(L, 'lon'), Point.Lon, FS) And Not IsNan(Point.Lat) And Not IsInfinite(Point.Lat) And Not IsNan(Point.Lon) And Not IsInfinite(Point.Lon) And (Abs(Point.Lat) <= 90) And (Abs(Point.Lon) <= 180) Then
           Begin
            Point.BreakBefore := Gap;
            Result.Points.Add(Point);
            Gap := False;
           End
          Else
           Gap := True;
         End;
      End;
     Append(R, JString(O, 'arrivalTransition'));
     Append(R, JString(O, 'arrival'));
     Append(R, JString(O, 'approachTransition'));
     Approach := JObject(O, 'approach');
     If JString(Approach, 'type') <> '' Then
      Append(R, JString(Approach, 'type') + JString(Approach, 'suffix') + '.' + JRunway(JObject(Approach, 'runway')));
     If JRunway(JObject(O, 'destinationRunway')) <> '' Then
      Dest := Dest + '.' + JRunway(JObject(O, 'destinationRunway'));
     Append(R, Dest);
     Result.Summary := R;
    Except
     Result.Free;
     Raise;
    End;
   Finally
    V.Free;
   End;
  End;

End.
