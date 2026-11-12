{$StackFrames On}
Unit FacilitiesU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Math, System.Generics.Collections,
  FlightDatabaseU, SimConnectClientU;

 Type
  TAirportCandidate = Record
   ICAO     : String;
   Region   : String;
   Lat      : Double;
   Lon      : Double;
   Distance : Double;
  End;

  TFacilityTask = Record
   Trip    : Integer;
   Row     : Integer;
   Kind    : String;
   Lat     : Double;
   Lon     : Double;
   Heading : Double;
  End;

  TRunway = Record
   Length              : Single;
   Width               : Single;
   Heading             : Single;
   Primary             : Integer;
   Secondary           : Integer;
   PrimaryDesignator   : Integer;
   SecondaryDesignator : Integer;
   Lat                 : Double;
   Lon                 : Double;
   Request             : DWORD;
   Seen                : Integer;
   PrimaryOffset       : Double;
   SecondaryOffset     : Double;
  End;

  TFacilityReader = Class
   Private
    fSim        : TSimConnectClient;
    fDB         : TFlightDatabase;
    fQueue      : TQueue<TFacilityTask>;
    fTask       : TFacilityTask;
    fCandidates : TList<TAirportCandidate>;
    fRunways    : TList<TRunway>;
    fIndex      : Integer;
    fName       : String;
    fRequest    : DWORD;
    fDeadline   : UInt64;
    fBusy       : Boolean;
    fDefined    : Boolean;
    fList       : Function(h : THandle; Kind, ID : DWORD) : HRESULT; Stdcall;
    fDefine     : Function(h : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
    fFacility   : Function(h : THandle; Def, Req : DWORD; ICAO, Region : PAnsiChar; FacilityType : AnsiChar) : HRESULT; Stdcall;
    Procedure Candidate;
    Procedure Finish;
    Procedure Save(Const Airport : TAirportCandidate; Const Runway : String; Heading : Integer; Along, Cross, Length, Width : Double);
   Public
    Constructor Create (Sim : TSimConnectClient; DB : TFlightDatabase);
    Destructor  Destroy; Override;
    Procedure   Request(Const Task : TFacilityTask);
    Procedure   Feed   (p : Pointer; Size : DWORD);
    Procedure   Tick;
  End;

 Function MatchRunway(Const r : TRunway; Lat, Lon, Track : Double; Out Secondary : Boolean; Out Along, Cross : Double) : Boolean;

Implementation

 Function MatchRunway(Const r : TRunway; Lat, Lon, Track : Double; Out Secondary : Boolean; Out Along, Cross : Double) : Boolean;
  Var
   North  : Double;
   East   : Double;
   a      : Double;
   h      : Double;
   Offset : Double;
  Begin
   North     := DegToRad(Lat - r.Lat) * 6371000;
   East      := DegToRad(Lon - r.Lon) * 6371000 * Cos(DegToRad(r.Lat));
   h         := DegToRad(r.Heading);
   Along     := North * Cos(h) + East * Sin(h);
   Cross     := East * Cos(h) - North * Sin(h);
   a         := Abs(((Track - r.Heading + 540) - Floor((Track - r.Heading + 540) / 360) * 360) - 180);
   Secondary := a > 90;
   If Secondary Then
    Begin
     Along  := -Along;
     Cross  := -Cross;
     Offset := r.SecondaryOffset;
    End
   Else
    Offset := r.PrimaryOffset;
   Along   := Along + r.Length / 2 - Offset;
   Result  := (Abs(Cross) <= r.Width / 2) And (Along >= 0) And (Along <= r.Length - Offset) And (r.Length > 0) And (r.Width > 0);
  End;

 Constructor TFacilityReader.Create(Sim : TSimConnectClient; DB : TFlightDatabase);
  Begin
   Inherited Create;
   fSim          := Sim;
   fDB           := DB;
   fQueue        := TQueue<TFacilityTask>.Create;
   fCandidates   := TList<TAirportCandidate>.Create;
   fRunways      := TList<TRunway>.Create;
   fSim.OnPacket := Feed;
   fRequest      := 2000;
  End;

 Destructor TFacilityReader.Destroy;
  Begin
   fSim.OnPacket := Nil;
   fQueue.Free;
   fCandidates.Free;
   fRunways.Free;
   Inherited;
  End;

 Procedure TFacilityReader.Request(Const Task : TFacilityTask);
  Begin
   fQueue.Enqueue(Task);
  End;

 Procedure TFacilityReader.Tick;
  Begin
   If Not fSim.Connected Then
    Begin
     fBusy    := False;
     fDefined := False;
     fQueue.Clear;
     Exit;
    End;
   If fBusy And (GetTickCount64 > fDeadline) Then
    fBusy := False;
   If fBusy Or (fQueue.Count = 0) Then
    Exit;
   @fList := fSim.FunctionAddress('SimConnect_RequestFacilitiesList_EX1');
   @fDefine := fSim.FunctionAddress('SimConnect_AddToFacilityDefinition');
   @fFacility := fSim.FunctionAddress('SimConnect_RequestFacilityData_EX1');
   If Not(Assigned(fList) And Assigned(fDefine) And Assigned(fFacility)) Then
    Begin
     fQueue.Clear;
     Exit;
    End;
   fTask := fQueue.Dequeue;
   fCandidates.Clear;
   fBusy := True;
   Inc(fRequest);
   fDeadline := GetTickCount64 + 10000;
   If fList(fSim.Handle, 0, fRequest) < 0 Then
    fBusy := False;
  End;

 Procedure TFacilityReader.Candidate;
  Const
   Definitions : Array [0..25] Of AnsiString = ('OPEN AIRPORT', 'NAME64', 'MAGVAR', 'N_RUNWAYS', 'OPEN RUNWAY', 'LENGTH', 'WIDTH', 'HEADING', 'PRIMARY_NUMBER', 'SECONDARY_NUMBER', 'PRIMARY_DESIGNATOR', 'SECONDARY_DESIGNATOR', 'LATITUDE', 'LONGITUDE', 'OPEN PRIMARY_THRESHOLD', 'LENGTH', 'WIDTH', 'ENABLE', 'CLOSE PRIMARY_THRESHOLD', 'OPEN SECONDARY_THRESHOLD', 'LENGTH', 'WIDTH', 'ENABLE', 'CLOSE SECONDARY_THRESHOLD', 'CLOSE RUNWAY', 'CLOSE AIRPORT');
  Var
   s      : AnsiString;
   a      : TAirportCandidate;
   ICAO   : AnsiString;
   Region : AnsiString;
  Begin
   If fIndex >= fCandidates.Count Then
    Begin
     fBusy := False;
     Exit;
    End;
   If Not fDefined Then
    Begin
     For s In Definitions Do
      If fDefine(fSim.Handle, 2, PAnsiChar(s)) < 0 Then
       Begin
        fBusy := False;
        Exit;
       End;
     fDefined := True;
    End;
   a      := fCandidates[fIndex];
   ICAO   := AnsiString(a.ICAO);
   Region := AnsiString(a.Region);
   Inc(fRequest);
   fRunways.Clear;
   fName     := '';
   fDeadline := GetTickCount64 + 10000;
   If fFacility(fSim.Handle, 2, fRequest, PAnsiChar(ICAO), PAnsiChar(Region), #0) < 0 Then
    fBusy := False;
  End;

 Function Text(p : Pointer; Len : Integer) : String;
  Var
   s : AnsiString;
   z : Integer;
  Begin
   SetString(s, PAnsiChar(p), Len);
   z := Pos(#0, String(s));
   If z > 0 Then
    SetLength(s, z - 1);
   Result := UTF8ToString(UTF8String(s));
  End;

 Procedure TFacilityReader.Feed(p : Pointer; Size : DWORD);
  Var
   ID      : DWORD;
   Req     : DWORD;
   Count   : DWORD;
   Entry   : DWORD;
   OutOf   : DWORD;
   Kind    : DWORD;
   Unique  : DWORD;
   Parent  : DWORD;
   i       : Integer;
   j       : Integer;
   Base    : NativeUInt;
   a       : TAirportCandidate;
   r       : TRunway;
   Offset  : Single;
   Enabled : Integer;
  Begin
   If Not fBusy Or (Size < 16) Then
    Exit;
   Move(PByte(NativeUInt(p) + 8)^, ID, 4);
   Move(PByte(NativeUInt(p) + 12)^, Req, 4);
   If Req <> fRequest Then
    Exit;
   If ID = 18 Then
    Begin
     If Size < 28 Then
      Exit;
     Move(PByte(NativeUInt(p) + 16)^, Count, 4);
     Move(PByte(NativeUInt(p) + 20)^, Entry, 4);
     Move(PByte(NativeUInt(p) + 24)^, OutOf, 4);
     If UInt64(28) + UInt64(Count) * 36 > Size Then
      Exit;
     For i := 0 To Integer(Count) - 1 Do
      Begin
       Base     := NativeUInt(p) + 28 + NativeUInt(i) * 36;
       a.ICAO   := Text(Pointer(Base), 9);
       a.Region := Text(Pointer(Base + 9), 3);
       Move(PByte(Base + 12)^, a.Lat, 8);
       Move(PByte(Base + 20)^, a.Lon, 8);
       a.Distance := Sqrt(Sqr(DegToRad(a.Lat - fTask.Lat) * 6371000) + Sqr(DegToRad(a.Lon - fTask.Lon) * 6371000 * Cos(DegToRad(fTask.Lat))));
       If a.Distance > 10000 Then
        Continue;
       j := 0;
       While (j < fCandidates.Count) And (fCandidates[j].Distance < a.Distance) Do
        Inc(j);
       fCandidates.Insert(j, a);
       If fCandidates.Count > 5 Then
        fCandidates.Delete(5);
      End;
     If Entry + 1 >= OutOf Then
      Begin
       fIndex := 0;
       Candidate;
      End;
    End
   Else If ID = 28 Then
    Begin
     If Size < 40 Then
      Exit;
     Move(PByte(NativeUInt(p) + 16)^, Unique, 4);
     Move(PByte(NativeUInt(p) + 20)^, Parent, 4);
     Move(PByte(NativeUInt(p) + 24)^, Kind, 4);
     Base := NativeUInt(p) + 40;
     If (Kind = 0) And (Size >= 112) Then
      fName := Text(Pointer(Base), 64);
     If (Kind = 1) And (Size >= 84) Then
      Begin
       r := Default(TRunway);
       Move(PByte(Base)^, r.Length, 4);
       Move(PByte(Base + 4)^, r.Width, 4);
       Move(PByte(Base + 8)^, r.Heading, 4);
       Move(PByte(Base + 12)^, r.Primary, 4);
       Move(PByte(Base + 16)^, r.Secondary, 4);
       Move(PByte(Base + 20)^, r.PrimaryDesignator, 4);
       Move(PByte(Base + 24)^, r.SecondaryDesignator, 4);
       Move(PByte(Base + 28)^, r.Lat, 8);
       Move(PByte(Base + 36)^, r.Lon, 8);
       r.Request := Unique;
       fRunways.Add(r);
      End;
     If (Kind = 23) And (Size >= 52) Then
      Begin
       Move(PByte(Base)^, Offset, 4);
       Move(PByte(Base + 8)^, Enabled, 4);
       For i := 0 To fRunways.Count - 1 Do
        If fRunways[i].Request = Parent Then
         Begin
          r := fRunways[i];
          If Enabled <> 0 Then
           If r.Seen = 0 Then
            r.PrimaryOffset := Offset
           Else
            r.SecondaryOffset := Offset;
          Inc(r.Seen);
          fRunways[i] := r;
          Break;
         End;
      End;
    End
   Else If ID = 29 Then
    Finish;
  End;

 Procedure TFacilityReader.Save(Const Airport : TAirportCandidate; Const Runway : String; Heading : Integer; Along, Cross, Length, Width : Double);
  Var
   Prefix : String;
   Table  : String;
  Begin
   If fTask.Kind = 'departure' Then
    Begin
     Table  := 'trips';
     Prefix := 'departure_';
    End
   Else
    Begin
     Table  := fTask.Kind;
     Prefix := '';
    End;
   If Table = 'trips' Then
    fDB.Connection.ExecSQL('update trips set departure_icao=:i,departure_name=:n,departure_region=:r,departure_rwy=:w where id=:id', [Airport.ICAO, fName, Airport.Region, Runway, fTask.Row])
   Else
    Begin
     fDB.Connection.ExecSQL('update ' + Table + ' set icao=:i,airport_name=:n,runway=:w,runway_heading=:h,runway_length_m=:rl,runway_width_m=:rw,distance_length=:l,distance_width=:c,distance_length_percent=:lp,distance_width_percent=:cp where id=:id', [Airport.ICAO, fName, Runway, Heading, Length, Width, Along / 0.3048, Cross / 0.3048, Along / Max(Length, 1), Cross / Max(Width / 2, 1), fTask.Row]);
     Prefix := 'destination_';
     If Table = 'trip_liftoffs' Then
      Begin
       If Integer(fDB.Connection.ExecSQLScalar('select min(id) from trip_liftoffs where trip=:t', [fTask.Trip])) <> fTask.Row Then
        Exit;
       Prefix := 'departure_';
      End;
     fDB.Connection.ExecSQL('update trips set ' + Prefix + 'icao=:i,' + Prefix + 'name=:n,' + Prefix + 'region=:r,' + Prefix + 'rwy=:w where id=:id', [Airport.ICAO, fName, Airport.Region, Runway, fTask.Trip]);
    End;
  End;

 Procedure TFacilityReader.Finish;
  Const
   Designators : Array [0..6] Of String = ('', 'L', 'R', 'C', 'W', 'A', 'B');
  Var
   r          : TRunway;
   Secondary  : Boolean;
   Along      : Double;
   Cross      : Double;
   Code       : String;
   Number     : Integer;
   Designator : Integer;
   Heading    : Integer;
  Begin
   For r In fRunways Do
    If MatchRunway(r, fTask.Lat, fTask.Lon, fTask.Heading, Secondary, Along, Cross) Then
     Begin
      Number     := r.Primary;
      Designator := r.PrimaryDesignator;
      Heading    := Round(r.Heading);
      If Secondary Then
       Begin
        Number     := r.Secondary;
        Designator := r.SecondaryDesignator;
        Heading    := (Heading + 180) Mod 360;
       End;
      Code := Format('%.2d', [Number]);
      If InRange(Designator, 0, 6) Then
       Code := Code + Designators[Designator];
      Save(fCandidates[fIndex], Code, Heading, Along, Cross, r.Length, r.Width);
      fBusy := False;
      Exit;
     End;
   If fTask.Kind = 'departure' Then
    Begin
     Save(fCandidates[fIndex], '', 0, 0, 0, 1, 1);
     fBusy := False;
    End
   Else
    Begin
     Inc(fIndex);
     Candidate;
    End;
  End;

End.
