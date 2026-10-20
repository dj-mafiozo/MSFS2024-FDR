{$StackFrames On}
Unit AircraftDataStoreU;

Interface

 Uses
  System.Generics.Collections, System.JSON, System.SysUtils, FireDAC.Comp.Client;

 Function JSONDelta(Current, Previous : TJSONObject) : TJSONObject;
 Procedure MergeJSON(State, Delta : TJSONObject);

 Type
  TAircraftHistory = Class
   Private
    q      : TFDQuery;
    fState : TJSONObject;
   Public
    Constructor Create(DB : TFDConnection; Trip : Integer);
    Destructor Destroy; Override;
    Function AtSample(ID : Int64) : TJSONObject;
  End;

Implementation

 Uses
  iFlyDisplaysU;

 Function JSONDelta(Current, Previous : TJSONObject) : TJSONObject;
  Var
   P     : TJSONPair;
   Old   : TJSONValue;
   Child : TJSONObject;
  Begin
   Result := TJSONObject.Create;
   If Previous <> Nil Then
    For P In Previous Do
     If Current.GetValue(P.JsonString.Value) = Nil Then
      Result.AddPair(P.JsonString.Value, TJSONNull.Create);
   For P In Current Do
    Begin
     Old := Nil;
     If Previous <> Nil Then
      Old := Previous.GetValue(P.JsonString.Value);
     If (P.JsonValue Is TJSONObject) And (Old Is TJSONObject) Then
      Begin
       Child := JSONDelta(TJSONObject(P.JsonValue), TJSONObject(Old));
       If Child.Count = 0 Then
        Child.Free
       Else
        Result.AddPair(P.JsonString.Value, Child);
      End
     Else If (Old = Nil) Or (Old.ToJSON <> P.JsonValue.ToJSON) Then
      Result.AddPair(P.JsonString.Value, TJSONObject.ParseJSONValue(P.JsonValue.ToJSON));
    End;
  End;

 Procedure MergeJSON(State, Delta : TJSONObject);
  Var
   P   : TJSONPair;
   Old : TJSONValue;
  Begin
   For P In Delta Do
    Begin
     Old := State.GetValue(P.JsonString.Value);
     If (Old Is TJSONObject) And (P.JsonValue Is TJSONObject) Then
      MergeJSON(TJSONObject(Old), TJSONObject(P.JsonValue))
     Else
      Begin
       State.RemovePair(P.JsonString.Value).Free;
       State.AddPair(P.JsonString.Value, TJSONObject.ParseJSONValue(P.JsonValue.ToJSON));
      End;
    End;
  End;

 Constructor TAircraftHistory.Create(DB : TFDConnection; Trip : Integer);
  Begin
   Inherited Create;
   fState       := TJSONObject.Create;
   q            := TFDQuery.Create(Nil);
   q.Connection := DB;
   q.Open('select sample,reset_state,payload from trip_aircraft_data where trip=:t order by sample', [Trip]);
  End;

 Destructor TAircraftHistory.Destroy;
  Begin
   q.Free;
   fState.Free;
   Inherited;
  End;

 Function TAircraftHistory.AtSample(ID : Int64) : TJSONObject;
  Var
   D, SDK : TJSONObject;
   V      : TJSONValue;
  Begin
   While Not q.Eof And (q.FieldByName('sample').AsLargeInt <= ID) Do
    Begin
     If q.FieldByName('reset_state').AsInteger <> 0 Then
      Begin
       fState.Free;
       fState := TJSONObject.Create;
      End;
     D := TJSONObject.ParseJSONValue(q.FieldByName('payload').AsString) As TJSONObject;
     Try
      If D <> Nil Then
       MergeJSON(fState, D);
     Finally
      D.Free;
     End;
     q.Next;
    End;
   Result := TJSONObject.ParseJSONValue(fState.ToJSON) As TJSONObject;
   V      := Result.GetValue('aircraft_sdk');
   If V Is TJSONObject Then
    Begin
     SDK := TJSONObject(V);
     If (SDK.GetValue('provider') <> Nil) And (SDK.GetValue('provider').Value = 'iFly737MAX') Then
      Begin
       V := SDK.GetValue('fields');
       If V Is TJSONObject Then
        AssembleIFlyDisplays(TJSONObject(V));
      End;
    End;
  End;

End.
