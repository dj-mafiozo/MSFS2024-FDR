Unit EventFilterU;

Interface

 Uses
  System.SysUtils, System.Generics.Collections;

 Type
  TOccurrence = Record
   Public
    Trip  : Integer;
    Zulu  : String;
    Local : String;
  End;

  TRecent = Record
   Public
    Seq  : Int64;
    Tick : UInt64;
  End;

  TEventState = Class
   Public
    Pending        : TList<TOccurrence>;
    Recent         : TList<TRecent>;
    FastLast       : UInt64;
    SlowLast       : UInt64;
    FastSuppressed : Boolean;
    SlowSuppressed : Boolean;
    Constructor Create;
    Destructor Destroy; Override;
  End;

  TCommitEvent  = Procedure(Const Name : String; Const Occurrence : TOccurrence; Seq : Int64) Of Object;
  TRetractEvent = Procedure(Seq : Int64) Of Object;

  TEventFilter = Class
   Private
    fStates : TObjectDictionary<String, TEventState>;
    fSeq    : Int64;
    Procedure CommitSlow(Const Name : String; S : TEventState; Const O : TOccurrence; Tick : UInt64);
   Public
    OnCommit  : TCommitEvent;
    OnRetract : TRetractEvent;
    Constructor Create(StartSeq : Int64);
    Destructor Destroy; Override;
    Procedure Add(Const Name : String; Const O : TOccurrence; Tick : UInt64);
    Procedure Flush(Tick : UInt64; All : Boolean = False);
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

 Procedure TEventFilter.CommitSlow(Const Name : String; S : TEventState; Const O : TOccurrence; Tick : UInt64);
  Var
   R : TRecent;
  Begin
   If S.SlowSuppressed And (Tick - S.SlowLast < 5000) Then
    Begin
     S.SlowLast := Tick;
     Exit;
    End;
   If Tick - S.SlowLast >= 5000 Then
    Begin
     S.Recent.Clear;
     S.SlowSuppressed := False;
    End;
   While (S.Recent.Count > 0) And (Tick - S.Recent[0].Tick >= 5000) Do
    S.Recent.Delete(0);
   S.SlowLast := Tick;
   Inc(fSeq);
   R.Seq  := fSeq;
   R.Tick := Tick;
   S.Recent.Add(R);
   If Assigned(OnCommit) Then
    OnCommit(Name, O, fSeq);
   If S.Recent.Count >= 3 Then
    Begin
     For R In S.Recent Do
      If Assigned(OnRetract) Then
       OnRetract(R.Seq);
     S.Recent.Clear;
     S.SlowSuppressed := True;
    End;
  End;

 Procedure TEventFilter.Add(Const Name : String; Const O : TOccurrence; Tick : UInt64);
  Var
   S : TEventState;
  Begin
   If (Name = 'FLAPS_INCR') Or (Name = 'FLAPS_DECR') Then
    Begin
     Inc(fSeq);
     If Assigned(OnCommit) Then
      OnCommit(Name, O, fSeq);
     Exit;
    End;
   Flush(Tick);
   If Not fStates.TryGetValue(Name, S) Then
    Begin
     S := TEventState.Create;
     fStates.Add(Name, S);
    End;
   If S.FastSuppressed And (Tick - S.FastLast < 500) Then
    Begin
     S.FastLast := Tick;
     Exit;
    End;
   If Tick - S.FastLast >= 500 Then
    S.FastSuppressed := False;
   S.FastLast        := Tick;
   S.Pending.Add(O);
   If S.Pending.Count >= 3 Then
    Begin
     S.Pending.Clear;
     S.FastSuppressed := True;
    End;
  End;

 Procedure TEventFilter.Flush(Tick : UInt64; All : Boolean);
  Var
   Pair : TPair<String, TEventState>;
   O    : TOccurrence;
  Begin
   For Pair In fStates Do
    If All Or (Tick - Pair.Value.FastLast >= 500) Then
     Begin
      If Not Pair.Value.FastSuppressed Then
       For O In Pair.Value.Pending Do
        CommitSlow(Pair.Key, Pair.Value, O, Tick);
      Pair.Value.Pending.Clear;
      Pair.Value.FastSuppressed := False;
     End;
   If All Then
    fStates.Clear;
  End;

End.
