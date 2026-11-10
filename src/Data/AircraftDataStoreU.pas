{$StackFrames On}
Unit AircraftDataStoreU;

Interface

 Uses
  System.Generics.Collections, System.JSON, System.SysUtils, FireDAC.Comp.Client;

 Function RecordedSDKFields(DB : TFDConnection; Trip : Integer; Const Provider : String) : TArray<String>;
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

 Function RecordedSDKFields(DB : TFDConnection; Trip : Integer; Const Provider : String) : TArray<String>;
  Var
   q       : TFDQuery;
   Root    : TJSONValue;
   SDK     : TJSONValue;
   v       : TJSONValue;
   Fields  : TJSONValue;
   Pair    : TJSONPair;
   Current : String;
   Names   : TList<String>;
   Seen    : TDictionary<String, Boolean>;
  Begin
   Result := Nil;
   q      := TFDQuery.Create(Nil);
   Names  := TList<String>.Create;
   Seen   := TDictionary<String, Boolean>.Create;
   Try
    q.Connection := DB;
    q.Open('select reset_state,payload from trip_aircraft_data where trip=:t order by sample', [Trip]);
    Current := '';
    While Not q.Eof Do
     Begin
      If q.FieldByName('reset_state').AsInteger <> 0 Then
       Current := '';
      Root     := TJSONObject.ParseJSONValue(q.FieldByName('payload').AsString);
      Try
       If Root Is TJSONObject Then
        Begin
         SDK := TJSONObject(Root).GetValue('aircraft_sdk');
         If SDK Is TJSONNull Then
          Current := ''
         Else If SDK Is TJSONObject Then
          Begin
           v := TJSONObject(SDK).GetValue('provider');
           If v <> Nil Then
            Current := v.Value;
           Fields   := TJSONObject(SDK).GetValue('fields');
           If SameText(Current, Provider) And (Fields Is TJSONObject) Then
            For Pair In TJSONObject(Fields) Do
             If Not Seen.ContainsKey(Pair.JsonString.Value) Then
              Begin
               Seen.Add(Pair.JsonString.Value, True);
               Names.Add(Pair.JsonString.Value);
              End;
          End;
        End;
      Finally
       Root.Free;
      End;
      q.Next;
     End;
    Result := Names.ToArray;
   Finally
    Seen.Free;
    Names.Free;
    q.Free;
   End;
  End;

 Function JSONDelta(Current, Previous : TJSONObject) : TJSONObject;
  Var
   p     : TJSONPair;
   Old   : TJSONValue;
   Child : TJSONObject;
  Begin
   Result := TJSONObject.Create;
   If Previous <> Nil Then
    For p In Previous Do
     If Current.GetValue(p.JsonString.Value) = Nil Then
      Result.AddPair(p.JsonString.Value, TJSONNull.Create);
   For p In Current Do
    Begin
     Old := Nil;
     If Previous <> Nil Then
      Old := Previous.GetValue(p.JsonString.Value);
     If (p.JsonValue Is TJSONObject) And (Old Is TJSONObject) Then
      Begin
       Child := JSONDelta(TJSONObject(p.JsonValue), TJSONObject(Old));
       If Child.Count = 0 Then
        Child.Free
       Else
        Result.AddPair(p.JsonString.Value, Child);
      End
     Else If (Old = Nil) Or (Old.ToJSON <> p.JsonValue.ToJSON) Then
      Result.AddPair(p.JsonString.Value, TJSONObject.ParseJSONValue(p.JsonValue.ToJSON));
    End;
  End;

 Procedure MergeJSON(State, Delta : TJSONObject);
  Var
   p   : TJSONPair;
   Old : TJSONValue;
  Begin
   For p In Delta Do
    Begin
     Old := State.GetValue(p.JsonString.Value);
     If (Old Is TJSONObject) And (p.JsonValue Is TJSONObject) Then
      MergeJSON(TJSONObject(Old), TJSONObject(p.JsonValue))
     Else
      Begin
       State.RemovePair(p.JsonString.Value).Free;
       State.AddPair(p.JsonString.Value, TJSONObject.ParseJSONValue(p.JsonValue.ToJSON));
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
   d   : TJSONObject;
   SDK : TJSONObject;
   v   : TJSONValue;
  Begin
   While Not q.Eof And (q.FieldByName('sample').AsLargeInt <= ID) Do
    Begin
     If q.FieldByName('reset_state').AsInteger <> 0 Then
      Begin
       fState.Free;
       fState := TJSONObject.Create;
      End;
     d := TJSONObject.ParseJSONValue(q.FieldByName('payload').AsString) As TJSONObject;
     Try
      If d <> Nil Then
       MergeJSON(fState, d);
     Finally
      d.Free;
     End;
     q.Next;
    End;
   Result := TJSONObject.ParseJSONValue(fState.ToJSON) As TJSONObject;
   v      := Result.GetValue('aircraft_sdk');
   If v Is TJSONObject Then
    Begin
     SDK := TJSONObject(v);
     If (SDK.GetValue('provider') <> Nil) And (SDK.GetValue('provider').Value = 'iFly737MAX') Then
      Begin
       v := SDK.GetValue('fields');
       If v Is TJSONObject Then
        AssembleIFlyDisplays(TJSONObject(v));
      End;
    End;
  End;

End.
