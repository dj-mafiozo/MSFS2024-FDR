{$StackFrames On}
Unit FMCPreflightU;

Interface

 Uses
  System.Classes, System.SysUtils, System.JSON, System.Generics.Collections, FireDAC.Comp.Client;

 Type
  TFMCObservation = Class
   Seq         : Int64;
   SimUTC      : String;
   CapturedUTC : String;
   Root        : TJSONObject;
   Destructor Destroy; Override;
   Function Clone : TFMCObservation;
  End;

  TFMCPreflightCache = Class
   Private
    fHistory : TObjectList<TFMCObservation>;
    fPages   : TObjectDictionary<String, TFMCObservation>;
    fLast    : String;
    fSeq     : Int64;
    fLimit   : Integer;
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
   fLimit   := Max(1, Limit);
   fHistory := TObjectList<TFMCObservation>.Create(True);
   fPages   := TObjectDictionary<String, TFMCObservation>.Create([doOwnsValues]);
  End;

 Destructor TFMCPreflightCache.Destroy;
  Begin
   fPages.Free;
   fHistory.Free;
   Inherited;
  End;

 Procedure TFMCPreflightCache.Clear;
  Begin
   fHistory.Clear;
   fPages.Clear;
   fLast := '';
   fSeq  := 0;
  End;

 Procedure TFMCPreflightCache.Observe(Root : TJSONObject; Const SimUTC : String);
  Var
   Screens   : TObjectList<TFMCScreen>;
   s         : TFMCScreen;
   o         : TFMCObservation;
   Canonical : TJSONObject;
   CDUs      : TJSONObject;
   Device    : TJSONObject;
   Rows      : TJSONArray;
   Line      : String;
   Key       : String;
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
     For s In Screens Do
      Begin
       Device := TJSONObject.Create;
       CDUs.AddPair(s.Device, Device);
       Device.AddPair('style_json', s.StyleJSON);
       Device.AddPair('annunciators_json', s.AnnunciatorsJSON);
       If s.Available Then
        Device.AddPair('status', 'available')
       Else
        Device.AddPair('status', 'unavailable');
       If s.PowerState >= 0 Then
        Device.AddPair('powered', TJSONBool.Create(s.PowerState = 1));
       Rows := TJSONArray.Create;
       Device.AddPair('rows', Rows);
       For Line In s.Lines Do
        Rows.Add(Line);
      End;
     Key := Canonical.ToJSON;
     If Key = fLast Then
      Exit;
     Inc(fSeq);
     o             := TFMCObservation.Create;
     o.Seq         := fSeq;
     o.SimUTC      := SimUTC;
     o.CapturedUTC := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
     o.Root        := Canonical;
     Canonical     := Nil;
     fHistory.Add(o);
     fLast := Key;
     For s In Screens Do
      If s.Available And (s.PowerState <> 0) And (s.PageKey <> 'BLANK') Then
       fPages.AddOrSetValue(s.Provider + '/' + s.Device + '/' + s.PageKey, o.Clone);
     While fHistory.Count > fLimit Do
      fHistory.Delete(0);
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
   o     : TFMCObservation;
   p     : TPair<String, TFMCObservation>;

   Procedure Add(Item : TFMCObservation);
    Begin
     If Seen.ContainsKey(Item.Seq) Then
      Exit;
     Seen.Add(Item.Seq, True);
     Items.Add(Item);
    End;

  Begin
   If fHistory.Count = 0 Then
    Exit;
   Items := TList<TFMCObservation>.Create;
   Seen  := TDictionary<Int64, Boolean>.Create;
   Try
    For o In fHistory Do
     Add(o);
    For p In fPages Do
     Add(p.Value);
    Items.Sort(TComparer<TFMCObservation>.Construct(
    Function(Const l, r : TFMCObservation) : Integer
    Begin
    If l.Seq < r.Seq Then
    Result := -1
    Else If l.Seq > r.Seq Then
    Result := 1
    Else
    Result := 0;
    End));
    DB.StartTransaction;
    Try
     For o In Items Do
      SaveFMCScreens(DB, Trip, 0, o.SimUTC, o.Root, o.CapturedUTC);
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
