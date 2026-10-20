Unit FacilitiesU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Math, System.Generics.Collections,
  FlightDatabaseU, SimConnectClientU;

 Type
  TAirportCandidate = Record
   Public
    ICAO     : String;
    Region   : String;
    Lat      : Double;
    Lon      : Double;
    Distance : Double;
  End;

  TFacilityTask = Record
   Public
    Trip    : Integer;
    Row     : Integer;
    Kind    : String;
    Lat     : Double;
    Lon     : Double;
    Heading : Double;
  End;

  TRunway = Record
   Public
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
    fSim            : TSimConnectClient;
    fDB             : TFlightDatabase;
    fQueue          : TQueue<TFacilityTask>;
    fTask           : TFacilityTask;
    fCandidates     : TList<TAirportCandidate>;
    fRunways        : TList<TRunway>;
    fIndex          : Integer;
    fName           : String;
    fRequest        : DWORD;
    fDeadline       : UInt64;
    fBusy, FDefined : Boolean;
    fList           : Function(H : THandle; Kind, ID : DWORD) : HRESULT; Stdcall;
    fDefine         : Function(H : THandle; ID : DWORD; Name : PAnsiChar) : HRESULT; Stdcall;
    fFacility       : Function(H : THandle; Def, Req : DWORD; ICAO, Region : PAnsiChar; FacilityType : AnsiChar) : HRESULT; Stdcall;
    Procedure Candidate;
    Procedure Finish;
    Procedure Save(Const Airport : TAirportCandidate; Const Runway : String; Heading : Integer; Along, Cross, Length, Width : Double);
   Public
    Constructor Create(Sim : TSimConnectClient; DB : TFlightDatabase);
    Destructor Destroy; Override;
    Procedure Request(Const Task : TFacilityTask);
    Procedure Feed(P : Pointer; Size : DWORD);
    Procedure Tick;
  End;

 Function MatchRunway(Const R : TRunway; Lat, Lon, Track : Double; Out Secondary : Boolean; Out Along, Cross : Double) : Boolean;

Implementation

 Function MatchRunway(Const R : TRunway; Lat, Lon, Track : Double; Out Secondary : Boolean; Out Along, Cross : Double) : Boolean;
  Var
   North  : Double;
   East   : Double;
   A      : Double;
   H      : Double;
   Offset : Double;
  Begin
   North     := DegToRad(Lat - R.Lat) * 6371000;
   East      := DegToRad(Lon - R.Lon) * 6371000 * Cos(DegToRad(R.Lat));
   H         := DegToRad(R.Heading);
   Along     := North * Cos(H) + East * Sin(H);
   Cross     := East * Cos(H) - North * Sin(H);
   A         := Abs(((Track - R.Heading + 540) - Floor((Track - R.Heading + 540) / 360) * 360) - 180);
   Secondary := A > 90;
   If Secondary Then
    Begin
     Along  := -Along;
     Cross  := -Cross;
     Offset := R.SecondaryOffset;
    End
   Else
    Offset := R.PrimaryOffset;
   Along   := Along + R.Length / 2 - Offset;
   Result  := (Abs(Cross) <= R.Width / 2) And (Along >= 0) And (Along <= R.Length - Offset) And (R.Length > 0) And (R.Width > 0);
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
     FDefined := False;
     fQueue.Clear;
     Exit;
    End;
   If fBusy And (GetTickCount64 > fDeadline) Then
    fBusy := False;
   If fBusy Or (fQueue.Count = 0) Then
    Exit;
   @fList     := fSim.FunctionAddress('SimConnect_RequestFacilitiesList_EX1');
   @fDefine   := fSim.FunctionAddress('SimConnect_AddToFacilityDefinition');
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
   Definitions : Array [0 .. 25] Of AnsiString = ('OPEN AIRPORT', 'NAME64', 'MAGVAR', 'N_RUNWAYS', 'OPEN RUNWAY', 'LENGTH', 'WIDTH', 'HEADING', 'PRIMARY_NUMBER', 'SECONDARY_NUMBER', 'PRIMARY_DESIGNATOR', 'SECONDARY_DESIGNATOR', 'LATITUDE', 'LONGITUDE', 'OPEN PRIMARY_THRESHOLD', 'LENGTH', 'WIDTH', 'ENABLE', 'CLOSE PRIMARY_THRESHOLD', 'OPEN SECONDARY_THRESHOLD', 'LENGTH', 'WIDTH', 'ENABLE', 'CLOSE SECONDARY_THRESHOLD', 'CLOSE RUNWAY', 'CLOSE AIRPORT');
  Var
   S      : AnsiString;
   A      : TAirportCandidate;
   ICAO   : AnsiString;
   Region : AnsiString;
  Begin
   If fIndex >= fCandidates.Count Then
    Begin
     fBusy := False;
     Exit;
    End;
   If Not FDefined Then
    Begin
     For S In Definitions Do
      If fDefine(fSim.Handle, 2, PAnsiChar(S)) < 0 Then
       Begin
        fBusy := False;
        Exit;
       End;
     FDefined := True;
    End;
   A      := fCandidates[fIndex];
   ICAO   := AnsiString(A.ICAO);
   Region := AnsiString(A.Region);
   Inc(fRequest);
   fRunways.Clear;
   fName     := '';
   fDeadline := GetTickCount64 + 10000;
   If fFacility(fSim.Handle, 2, fRequest, PAnsiChar(ICAO), PAnsiChar(Region), #0) < 0 Then
    fBusy := False;
  End;

 Function Text(P : Pointer; Len : Integer) : String;
  Var
   S : AnsiString;
   Z : Integer;
  Begin
   SetString(S, PAnsiChar(P), Len);
   Z := Pos(#0, String(S));
   If Z > 0 Then
    SetLength(S, Z - 1);
   Result := UTF8ToString(UTF8String(S));
  End;

 Procedure TFacilityReader.Feed(P : Pointer; Size : DWORD);
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
   A       : TAirportCandidate;
   R       : TRunway;
   Offset  : Single;
   Enabled : Integer;
  Begin
   If Not fBusy Or (Size < 16) Then
    Exit;
   Move(PByte(NativeUInt(P) + 8)^, ID, 4);
   Move(PByte(NativeUInt(P) + 12)^, Req, 4);
   If Req <> fRequest Then
    Exit;
   If ID = 18 Then
    Begin
     If Size < 28 Then
      Exit;
     Move(PByte(NativeUInt(P) + 16)^, Count, 4);
     Move(PByte(NativeUInt(P) + 20)^, Entry, 4);
     Move(PByte(NativeUInt(P) + 24)^, OutOf, 4);
     If UInt64(28) + UInt64(Count) * 36 > Size Then
      Exit;
     For i := 0 To Integer(Count) - 1 Do
      Begin
       Base     := NativeUInt(P) + 28 + NativeUInt(i) * 36;
       A.ICAO   := Text(Pointer(Base), 9);
       A.Region := Text(Pointer(Base + 9), 3);
       Move(PByte(Base + 12)^, A.Lat, 8);
       Move(PByte(Base + 20)^, A.Lon, 8);
       A.Distance := Sqrt(Sqr(DegToRad(A.Lat - fTask.Lat) * 6371000) + Sqr(DegToRad(A.Lon - fTask.Lon) * 6371000 * Cos(DegToRad(fTask.Lat))));
       If A.Distance > 10000 Then
        Continue;
       j := 0;
       While (j < fCandidates.Count) And (fCandidates[j].Distance < A.Distance) Do
        Inc(j);
       fCandidates.Insert(j, A);
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
     Move(PByte(NativeUInt(P) + 16)^, Unique, 4);
     Move(PByte(NativeUInt(P) + 20)^, Parent, 4);
     Move(PByte(NativeUInt(P) + 24)^, Kind, 4);
     Base := NativeUInt(P) + 40;
     If (Kind = 0) And (Size >= 112) Then
      fName := Text(Pointer(Base), 64);
     If (Kind = 1) And (Size >= 84) Then
      Begin
       R := Default (TRunway);
       Move(PByte(Base)^, R.Length, 4);
       Move(PByte(Base + 4)^, R.Width, 4);
       Move(PByte(Base + 8)^, R.Heading, 4);
       Move(PByte(Base + 12)^, R.Primary, 4);
       Move(PByte(Base + 16)^, R.Secondary, 4);
       Move(PByte(Base + 20)^, R.PrimaryDesignator, 4);
       Move(PByte(Base + 24)^, R.SecondaryDesignator, 4);
       Move(PByte(Base + 28)^, R.Lat, 8);
       Move(PByte(Base + 36)^, R.Lon, 8);
       R.Request := Unique;
       fRunways.Add(R);
      End;
     If (Kind = 23) And (Size >= 52) Then
      Begin
       Move(PByte(Base)^, Offset, 4);
       Move(PByte(Base + 8)^, Enabled, 4);
       For i := 0 To fRunways.Count - 1 Do
        If fRunways[i].Request = Parent Then
         Begin
          R := fRunways[i];
          If Enabled <> 0 Then
           If R.Seen = 0 Then
            R.PrimaryOffset := Offset
           Else
            R.SecondaryOffset := Offset;
          Inc(R.Seen);
          fRunways[i] := R;
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
   Designators : Array [0 .. 6] Of String = ('', 'L', 'R', 'C', 'W', 'A', 'B');
  Var
   R          : TRunway;
   Secondary  : Boolean;
   Along      : Double;
   Cross      : Double;
   Code       : String;
   Number     : Integer;
   Designator : Integer;
   Heading    : Integer;
  Begin
   For R In fRunways Do
    If MatchRunway(R, fTask.Lat, fTask.Lon, fTask.Heading, Secondary, Along, Cross) Then
     Begin
      Number     := R.Primary;
      Designator := R.PrimaryDesignator;
      Heading    := Round(R.Heading);
      If Secondary Then
       Begin
        Number     := R.Secondary;
        Designator := R.SecondaryDesignator;
        Heading    := (Heading + 180) Mod 360;
       End;
      Code := Format('%.2d', [Number]);
      If InRange(Designator, 0, 6) Then
       Code := Code + Designators[Designator];
      Save(fCandidates[fIndex], Code, Heading, Along, Cross, R.Length, R.Width);
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
