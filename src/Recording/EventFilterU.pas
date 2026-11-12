{$StackFrames On}
Unit EventFilterU;

Interface

 Uses
  System.SysUtils, System.Generics.Collections;

 Type
  TOccurrence = Record
   Trip  : Integer;
   Zulu  : String;
   Local : String;
  End;

  TRecent = Record
   Seq  : Int64;
   Tick : UInt64;
  End;

  TEventState = Class
   Pending        : TList<TOccurrence>;
   Recent         : TList<TRecent>;
   FastLast       : UInt64;
   SlowLast       : UInt64;
   FastSuppressed : Boolean;
   SlowSuppressed : Boolean;
   Constructor Create;
   Destructor  Destroy; Override;
  End;

  TCommitEvent = Procedure(Const Name : String; Const Occurrence : TOccurrence; Seq : Int64) Of Object;

  TRetractEvent = Procedure(Seq : Int64) Of Object;

  TEventFilter = Class
   Private
    fStates : TObjectDictionary<String, TEventState>;
    fSeq    : Int64;
    Procedure CommitSlow(Const Name : String; s : TEventState; Const o : TOccurrence; Tick : UInt64);
   Public
    OnCommit  : TCommitEvent;
    OnRetract : TRetractEvent;
    Constructor Create(StartSeq : Int64);
    Destructor  Destroy; Override;
    Procedure   Add   (Const Name : String; Const o : TOccurrence; Tick : UInt64);
    Procedure   Flush (Tick : UInt64; All : Boolean = False);
  End;

Implementation

 Constructor TEventState.Create;
  Begin
   Inherited;
   Pending := TList<TOccurrence>.Create;
   Recent  := TList<TRecent>.Create;
  End;

 Destructor TEventState.Destroy;
  Begin
   Pending.Free;
   Recent.Free;
   Inherited;
  End;

 Constructor TEventFilter.Create(StartSeq : Int64);
  Begin
   Inherited Create;
   fStates := TObjectDictionary<String, TEventState>.Create([doOwnsValues]);
   fSeq    := StartSeq;
  End;

 Destructor TEventFilter.Destroy;
  Begin
   fStates.Free;
   Inherited;
  End;

 Procedure TEventFilter.CommitSlow(Const Name : String; s : TEventState; Const o : TOccurrence; Tick : UInt64);
  Var
   r : TRecent;
  Begin
   If s.SlowSuppressed And (Tick - s.SlowLast < 5000) Then
    Begin
     s.SlowLast := Tick;
     Exit;
    End;
   If Tick - s.SlowLast >= 5000 Then
    Begin
     s.Recent.Clear;
     s.SlowSuppressed := False;
    End;
   While (s.Recent.Count > 0) And (Tick - s.Recent[0].Tick >= 5000) Do
    s.Recent.Delete(0);
   s.SlowLast := Tick;
   Inc(fSeq);
   r.Seq  := fSeq;
   r.Tick := Tick;
   s.Recent.Add(r);
   If Assigned(OnCommit) Then
    OnCommit(Name, o, fSeq);
   If s.Recent.Count >= 3 Then
    Begin
     For r In s.Recent Do
      If Assigned(OnRetract) Then
       OnRetract(r.Seq);
     s.Recent.Clear;
     s.SlowSuppressed := True;
    End;
  End;

 Procedure TEventFilter.Add(Const Name : String; Const o : TOccurrence; Tick : UInt64);
  Var
   s : TEventState;
  Begin
   If (Name = 'FLAPS_INCR') Or (Name = 'FLAPS_DECR') Then
    Begin
     Inc(fSeq);
     If Assigned(OnCommit) Then
      OnCommit(Name, o, fSeq);
     Exit;
    End;
   Flush(Tick);
   If Not fStates.TryGetValue(Name, s) Then
    Begin
     s := TEventState.Create;
     fStates.Add(Name, s);
    End;
   If s.FastSuppressed And (Tick - s.FastLast < 500) Then
    Begin
     s.FastLast := Tick;
     Exit;
    End;
   If Tick - s.FastLast >= 500 Then
    s.FastSuppressed := False;
   s.FastLast        := Tick;
   s.Pending.Add(o);
   If s.Pending.Count >= 3 Then
    Begin
     s.Pending.Clear;
     s.FastSuppressed := True;
    End;
  End;

 Procedure TEventFilter.Flush(Tick : UInt64; All : Boolean);
  Var
   Pair : TPair<String, TEventState>;
   o    : TOccurrence;
  Begin
   For Pair In fStates Do
    If All Or (Tick - Pair.Value.FastLast >= 500) Then
     Begin
      If Not Pair.Value.FastSuppressed Then
       For o In Pair.Value.Pending Do
        CommitSlow(Pair.Key, Pair.Value, o, Tick);
      Pair.Value.Pending.Clear;
      Pair.Value.FastSuppressed := False;
     End;
   If All Then
    fStates.Clear;
  End;

End.
