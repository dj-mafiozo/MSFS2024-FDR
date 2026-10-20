Unit FMCPreflightU;

Interface

 Uses
  System.Classes, System.SysUtils, System.JSON, System.Generics.Collections, FireDAC.Comp.Client;

 Type
  TFMCObservation = Class
   Public
    Seq         : Int64;
    SimUTC      : String;
    CapturedUTC : String;
    Root        : TJSONObject;
    Destructor Destroy; Override;
    Function Clone : TFMCObservation;
  End;

  TFMCPreflightCache = Class
   Private
    FHistory : TObjectList<TFMCObservation>;
    FPages   : TObjectDictionary<String, TFMCObservation>;
    FLast    : String;
    FSeq     : Int64;
    FLimit   : Integer;
   Public
    Constructor Create(Limit : Integer = 4096);
    Destructor Destroy; Override;
    Procedure Clear;
    Procedure Observe(Root : TJSONObject; Const SimUTC : String);
    Procedure Flush(DB : TFDConnection; Trip : Integer);
  End;

Implementation

 Uses
  System.DateUtils, System.Math, System.Generics.Defaults, FMCScreensU;

 Destructor TFMCObservation.Destroy;
  Begin
   Root.Free;
   Inherited;
  End;

 Function TFMCObservation.Clone : TFMCObservation;
  Begin
   Result             := TFMCObservation.Create;
   Result.Seq         := Seq;
   Result.SimUTC      := SimUTC;
   Result.CapturedUTC := CapturedUTC;
   Result.Root        := TJSONObject.ParseJSONValue(Root.ToJSON) As TJSONObject;
  End;

 Constructor TFMCPreflightCache.Create(Limit : Integer);
  Begin
   Inherited Create;
   FLimit   := Max(1, Limit);
   FHistory := TObjectList<TFMCObservation>.Create(True);
   FPages   := TObjectDictionary<String, TFMCObservation>.Create([doOwnsValues]);
  End;

 Destructor TFMCPreflightCache.Destroy;
  Begin
   FPages.Free;
   FHistory.Free;
   Inherited;
  End;

 Procedure TFMCPreflightCache.Clear;
  Begin
   FHistory.Clear;
   FPages.Clear;
   FLast := '';
   FSeq  := 0;
  End;

 Procedure TFMCPreflightCache.Observe(Root : TJSONObject; Const SimUTC : String);
  Var
   Screens   : TObjectList<TFMCScreen>;
   S         : TFMCScreen;
   O         : TFMCObservation;
   Canonical : TJSONObject;
   CDUs      : TJSONObject;
   Device    : TJSONObject;
   Rows      : TJSONArray;
   Line, Key : String;
  Begin
   If (Root = Nil) Or (SimUTC = '') Then
    Exit;
   Screens := ExtractFMCScreens(Root);
   Try
    If Screens.Count = 0 Then
     Exit;
    Canonical := TJSONObject.Create;
    Try
     Canonical.AddPair('provider', Screens[0].Provider);
     CDUs := TJSONObject.Create;
     Canonical.AddPair('cdu', CDUs);
     For S In Screens Do
      Begin
       Device := TJSONObject.Create;
       CDUs.AddPair(S.Device, Device);
       Device.AddPair('style_json',S.StyleJSON);Device.AddPair('annunciators_json',S.AnnunciatorsJSON);
       If S.Available Then
        Device.AddPair('status', 'available')
       Else
        Device.AddPair('status', 'unavailable');
       If S.PowerState >= 0 Then
        Device.AddPair('powered', TJSONBool.Create(S.PowerState = 1));
       Rows := TJSONArray.Create;
       Device.AddPair('rows', Rows);
       For Line In S.Lines Do
        Rows.Add(Line);
      End;
     Key := Canonical.ToJSON;
     If Key = FLast Then
      Exit;
     Inc(FSeq);
     O             := TFMCObservation.Create;
     O.Seq         := FSeq;
     O.SimUTC      := SimUTC;
     O.CapturedUTC := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
     O.Root        := Canonical;
     Canonical     := Nil;
     FHistory.Add(O);
     FLast := Key;
     For S In Screens Do
      If S.Available And (S.PowerState <> 0) And (S.PageKey <> 'BLANK') Then
       FPages.AddOrSetValue(S.Provider + '/' + S.Device + '/' + S.PageKey, O.Clone);
     While FHistory.Count > FLimit Do
      FHistory.Delete(0);
    Finally
     Canonical.Free;
    End;
   Finally
    Screens.Free;
   End;
  End;

 Procedure TFMCPreflightCache.Flush(DB : TFDConnection; Trip : Integer);
  Var
   Items : TList<TFMCObservation>;
   Seen  : TDictionary<Int64, Boolean>;
   O     : TFMCObservation;
   P     : TPair<String, TFMCObservation>;
   Procedure Add(Item : TFMCObservation);
    Begin
     If Seen.ContainsKey(Item.Seq) Then
      Exit;
     Seen.Add(Item.Seq, True);
     Items.Add(Item);
    End;

  Begin
   If FHistory.Count = 0 Then
    Exit;
   Items := TList<TFMCObservation>.Create;
   Seen  := TDictionary<Int64, Boolean>.Create;
   Try
    For O In FHistory Do
     Add(O);
    For P In FPages Do
     Add(P.Value);
    Items.Sort(TComparer<TFMCObservation>.Construct(
       Function(Const L, R : TFMCObservation) : Integer
      Begin
       If L.Seq < R.Seq Then
        Result := -1
       Else If L.Seq > R.Seq Then
        Result := 1
       Else
        Result := 0;
      End));
    DB.StartTransaction;
    Try
     For O In Items Do
      SaveFMCScreens(DB, Trip, 0, O.SimUTC, O.Root, O.CapturedUTC);
     DB.Commit;
    Except
     DB.Rollback;
     Raise;
    End;
    Clear;
   Finally
    Seen.Free;
    Items.Free;
   End;
  End;

End.
