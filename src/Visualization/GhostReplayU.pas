Unit GhostReplayU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  System.Generics.Collections, FlightDatabaseU, FireDAC.Comp.Client, FSLTLU;

 Const
  GhostVisualCount = 56;

 Type
  TGhostSample = Packed Record
   Seconds     : Double;
   Pose        : Array [0..5] Of Double; // lat, lon, feet, pitch, bank, true heading
   Visual      : Array [0..GhostVisualCount - 1] Of Double;
   BreakBefore : Boolean;
  End;

  TGhostModel = Record
   Title  : String;
   Livery : String;
  End;

  TGhostState = Record
   Playing  : Boolean;
   Finished : Boolean;
   Failed   : Boolean;
   Position : Double;
   Model    : String;
   Error    : String;
  End;

  TGhostReplayThread = Class(TThread)
   Private
    fLock          : TCriticalSection;
    fWake          : TEvent;
    fRows          : TArray<TGhostSample>;
    fState         : TGhostState;
    fSeek          : Double;
    fWantPlay      : Boolean;
    fDirty         : Boolean;
    fDLL           : String;
    fICAO          : String;
    fVMR           : String;
    fInventory     : TAIModelInventory;
    fAirline       : String;
    fRegistration  : String;
    fAircraftTitle : String;
    fHz            : Integer;
   Protected
    Procedure Execute; Override;
   Public
    Constructor Create(Plot : TTripPlot; Const DLL, VMR : String; Hz : Integer; StartSeconds : Double; Inventory : TAIModelInventory = Nil);
    Destructor  Destroy; Override;
    Procedure   Toggle;
    Procedure   Skip  (Seconds : Double);
    Function    Snapshot : TGhostState;
  End;

 Function GhostInterpolate(Const a, b : TGhostSample; Seconds : Double) : TGhostSample;
 Function GhostModelScore(Const ICAO, Title, RuleTitles : String) : Integer;

Implementation

 Uses
  System.Math, System.StrUtils, System.IOUtils, System.JSON, System.Variants, Data.DB, Xml.xmldom, Xml.omnixmldom,
  FireDAC.Stan.Param, FireDAC.Phys.SQLite, Xml.XMLDoc, Xml.XMLIntf, AppLogU;

{ FLD+ }

 Const
  VisualNames : Array [0..GhostVisualCount - 1] Of String =
   (
    'aileron_left_deflection_pct',
    'aileron_right_deflection_pct',
    'elevator_deflection_pct',
    'rudder_deflection_pct',
    'spoilers_left_position',
    'spoilers_right_position',
    'trailing_edge_flaps_left_percent',
    'trailing_edge_flaps_right_percent',
    'gear_animation_position_0',
    'gear_animation_position_1',
    'gear_animation_position_2',
    'general_eng_throttle_lever_position #1',
    'general_eng_throttle_lever_position #2',
    'eng_combustion #1',
    'eng_combustion #2',
    'eng_rpm_animation_percent #1',
    'eng_rpm_animation_percent #2',
    'light_states',
    'general_eng_throttle_lever_position #3',
    'general_eng_throttle_lever_position #4',
    'eng_combustion #3',
    'eng_combustion #4',
    'eng_rpm_animation_percent #3',
    'eng_rpm_animation_percent #4',
    'leading_edge_flaps_left_percent',
    'leading_edge_flaps_right_percent',
    'flaps_handle_percent',
    'gear_handle_position',
    'sim_on_ground',
    'turb_eng_jet_thrust #1',
    'turb_eng_jet_thrust #2',
    'turb_eng_jet_thrust #3',
    'turb_eng_jet_thrust #4',
    'spoilers_handle_position',
    'turb_eng_n1 #1',
    'turb_eng_n1 #2',
    'turb_eng_n1 #3',
    'turb_eng_n1 #4',
    'general_eng_rpm #1',
    'general_eng_rpm #2',
    'general_eng_rpm #3',
    'general_eng_rpm #4',
    'airspeed_indicated',
    'vertical_speed',
    'plane_alt_above_ground',
    'ground_velocity',
    'visual_velocity_body_z',
    'visual_rotation_velocity_body_y',
    'prop_max_rpm_percent #1',
    'prop_max_rpm_percent #2',
    'prop_max_rpm_percent #3',
    'prop_max_rpm_percent #4',
    'turb_eng_reverse_nozzle_percent #1',
    'turb_eng_reverse_nozzle_percent #2',
    'turb_eng_reverse_nozzle_percent #3',
    'turb_eng_reverse_nozzle_percent #4'
   );

  VisualVars : Array [0..GhostVisualCount - 1] Of AnsiString =
   (
    'AILERON LEFT DEFLECTION PCT',
    'AILERON RIGHT DEFLECTION PCT',
    'ELEVATOR DEFLECTION PCT',
    'RUDDER DEFLECTION PCT',
    'SPOILERS LEFT POSITION',
    'SPOILERS RIGHT POSITION',
    'TRAILING EDGE FLAPS LEFT PERCENT',
    'TRAILING EDGE FLAPS RIGHT PERCENT',
    'GEAR ANIMATION POSITION:0',
    'GEAR ANIMATION POSITION:1',
    'GEAR ANIMATION POSITION:2',
    'GENERAL ENG THROTTLE LEVER POSITION:1',
    'GENERAL ENG THROTTLE LEVER POSITION:2',
    'GENERAL ENG COMBUSTION:1',
    'GENERAL ENG COMBUSTION:2',
    'ENG RPM ANIMATION PERCENT:1',
    'ENG RPM ANIMATION PERCENT:2',
    '',
    'GENERAL ENG THROTTLE LEVER POSITION:3',
    'GENERAL ENG THROTTLE LEVER POSITION:4',
    'GENERAL ENG COMBUSTION:3',
    'GENERAL ENG COMBUSTION:4',
    'ENG RPM ANIMATION PERCENT:3',
    'ENG RPM ANIMATION PERCENT:4',
    'LEADING EDGE FLAPS LEFT PERCENT',
    'LEADING EDGE FLAPS RIGHT PERCENT',
    'FLAPS HANDLE PERCENT',
    'GEAR HANDLE POSITION',
    'SIM ON GROUND',
    'TURB ENG JET THRUST:1',
    'TURB ENG JET THRUST:2',
    'TURB ENG JET THRUST:3',
    'TURB ENG JET THRUST:4',
    'SPOILERS HANDLE POSITION',
    'ENG N1 RPM:1',
    'ENG N1 RPM:2',
    'ENG N1 RPM:3',
    'ENG N1 RPM:4',
    'GENERAL ENG RPM:1',
    'GENERAL ENG RPM:2',
    'GENERAL ENG RPM:3',
    'GENERAL ENG RPM:4',
    'AIRSPEED INDICATED',
    'VERTICAL SPEED',
    'PLANE ALT ABOVE GROUND',
    'GROUND VELOCITY',
    'VELOCITY BODY Z',
    'ROTATION VELOCITY BODY Y',
    'PROP MAX RPM PERCENT:1',
    'PROP MAX RPM PERCENT:2',
    'PROP MAX RPM PERCENT:3',
    'PROP MAX RPM PERCENT:4',
    'TURB ENG REVERSE NOZZLE PERCENT:1',
    'TURB ENG REVERSE NOZZLE PERCENT:2',
    'TURB ENG REVERSE NOZZLE PERCENT:3',
    'TURB ENG REVERSE NOZZLE PERCENT:4'
   );

  PoseNames : Array [0..5] Of String =
   (
    'plane_latitude',
    'plane_longitude',
    'plane_altitude',
    'plane_pitch_degrees',
    'plane_bank_degrees',
    'plane_heading_degrees_true'
   );

  PoseVars : Array [0..5] Of AnsiString =
   (
    'PLANE LATITUDE',
    'PLANE LONGITUDE',
    'PLANE ALTITUDE',
    'PLANE PITCH DEGREES',
    'PLANE BANK DEGREES',
    'PLANE HEADING DEGREES TRUE'
   );

  LightEvents : Array [0..9] Of AnsiString =
   (
    'NAV_LIGHTS_SET',
    'BEACON_LIGHTS_SET',
    'LANDING_LIGHTS_SET',
    'TAXI_LIGHTS_SET',
    'STROBES_SET',
    'PANEL_LIGHTS_SET',
    'RECOGNITION_LIGHTS_SET',
    'WING_LIGHTS_SET',
    'LOGO_LIGHTS_SET',
    'CABIN_LIGHTS_SET'
   );
{ FLD- }

 Function GhostInterpolate(Const a, b : TGhostSample; Seconds : Double) : TGhostSample;
  Var
   i : Integer;
   f : Double;
   d : Double;
  Begin
   Result := a;
   If (b.Seconds <= a.Seconds) Or b.BreakBefore Or (b.Seconds - a.Seconds > 5) Then
    Exit;
   f              := EnsureRange((Seconds - a.Seconds) / (b.Seconds - a.Seconds), 0.0, 1.0);
   Result.Seconds := Seconds;
   For i          := 0 To 5 Do
    Begin
     d := b.Pose[i] - a.Pose[i];
     If i In [1, 4, 5] Then
      d             := d - 360 * Floor((d + 180) / 360);
     Result.Pose[i] := a.Pose[i] + d * f;
     If i = 1 Then
      Result.Pose[i] := Result.Pose[i] - 360 * Floor((Result.Pose[i] + 180) / 360);
     If i = 5 Then
      Result.Pose[i] := Result.Pose[i] - 360 * Floor(Result.Pose[i] / 360);
    End;
   For i := 0 To GhostVisualCount - 1 Do
    If Not(i In [13, 14, 17, 20, 21, 27, 28]) And Not IsNan(a.Visual[i]) And Not IsNan(b.Visual[i]) Then
     Result.Visual[i] := a.Visual[i] + (b.Visual[i] - a.Visual[i]) * f;
  End;

 Function GhostModelScore(Const ICAO, Title, RuleTitles : String) : Integer;
  Var
   t     : String;
   c     : String;
   Match : Boolean;
   Light : Boolean;
  Begin
   t      := UpperCase(Title);
   c      := UpperCase(ICAO);
   Result := -1;
   If (Pos('FENIX', t) > 0) Or (Pos('PMDG', t) > 0) Or (Pos('IFLY', t) > 0) Or (Pos('FLYBYWIRE', t) > 0) Then
    Exit;
   Match := (c <> '') And (Pos(c, t) > 0);
   If Not Match And (c = 'B38M') Then
    Match := (Pos('B738', t) > 0) Or (Pos('737-800', t) > 0);
   Light  := (Pos('FSLTL', t) > 0) Or (Pos('AIPLANE', t) > 0) Or (Pos('AI PLANE', t) > 0) Or (Pos('AIRTRAFFIC', t) > 0);
   If Not Light Then
    Exit;
   If Match Then
    Result := 500
   Else
    Result := 10;
   If Pos('FSLTL', t) > 0 Then
    Begin
     If Match Then
      Inc(Result, 500)
     Else
      Result := -1;
    End;
   If (c = 'B38M') And (Pos('B38M', t) = 0) And Match Then
    Dec(Result, 100);
   If (RuleTitles <> '') And (Pos('|' + t + '|', RuleTitles) > 0) Then
    Result := 2000;
  End;

 Constructor TGhostReplayThread.Create(Plot : TTripPlot; Const DLL, VMR : String; Hz : Integer; StartSeconds : Double; Inventory : TAIModelInventory);
  Var
   i       : Integer;
   j       : Integer;
   Indices : Array [0..GhostVisualCount + 5] Of Integer;
   p       : TPlotPoint;
   r       : TGhostSample;
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fLock           := TCriticalSection.Create;
   fWake           := TEvent.Create(Nil, False, False, '');
   fDLL            := DLL;
   fVMR            := VMR;
   fHz             := EnsureRange(Hz, 5, 60);
   fICAO           := Plot.AircraftTypeICAO;
   fInventory      := Inventory;
   fAirline        := Plot.Airline;
   fRegistration   := Plot.Registration;
   fAircraftTitle  := Plot.AircraftTitle;
   For j           := 0 To 5 Do
    Indices[j]     := Plot.Labels.IndexOf(PoseNames[j]);
   For j           := 0 To GhostVisualCount - 1 Do
    Indices[j + 6] := Plot.Labels.IndexOf(VisualNames[j]);
   For j           := 0 To 2 Do
    If Indices[14 + j] < 0 Then
     Indices[14 + j] := Plot.Labels.IndexOf('gear_position_' + IntToStr(j));
   For j             := 0 To 3 Do
    If Indices[21 + (j Div 2) * 7 + (j Mod 2)] < 0 Then
     Indices[21 + (j Div 2) * 7 + (j Mod 2)] := Plot.Labels.IndexOf('turb_eng_n1 #' + IntToStr(j + 1));
   For j                                     := 0 To 5 Do
    If Indices[j] < 0 Then
     Raise Exception.Create('Ghost: missing ' + PoseNames[j]);
   SetLength(fRows, Plot.Points.Count);
   i := 0;
   For p In Plot.Points Do
    Begin
     r             := Default(TGhostSample);
     r.Seconds     := p.Seconds;
     r.BreakBefore := p.BreakBefore;
     For j         := 0 To 5 Do
      If Indices[j] < Length(p.Values) Then
       r.Pose[j] := p.Values[Indices[j]]
      Else
       r.Pose[j] := NaN;
     If IsNan(r.Pose[0]) Or IsNan(r.Pose[1]) Or IsNan(r.Pose[2]) Or IsNan(r.Pose[3]) Or IsNan(r.Pose[4]) Or IsNan(r.Pose[5]) Then
      Continue;
     If (Abs(r.Pose[0]) > 90) Or (Abs(r.Pose[1]) > 180) Then
      Continue;
     If (i > 0) And (r.Seconds <= fRows[i - 1].Seconds) Then
      Continue;
     For j := 0 To GhostVisualCount - 1 Do
      Begin
       r.Visual[j] := NaN;
       If (Indices[j + 6] >= 0) And (Indices[j + 6] < Length(p.Values)) Then
        r.Visual[j] := p.Values[Indices[j + 6]];
      End;
     fRows[i] := r;
     Inc(i);
    End;
   SetLength(fRows, i);
   If i = 0 Then
    Raise Exception.Create('Ghost: no valid trajectory');
   fSeek           := EnsureRange(StartSeconds, fRows[0].Seconds, fRows[i - 1].Seconds);
   fState.Position := fSeek;
   fWantPlay       := True;
   fDirty          := True;
  End;

 Destructor TGhostReplayThread.Destroy;
  Begin
   Terminate;
   If Suspended Then
    Start;
   If fWake <> Nil Then
    fWake.SetEvent;
   WaitFor;
   fWake.Free;
   fLock.Free;
   Inherited;
  End;

 Procedure TGhostReplayThread.Toggle;
  Begin
   fLock.Enter;
   Try
    If fState.Finished And Not fWantPlay Then
     Begin
      fSeek  := 0;
      fDirty := True;
     End;
    fWantPlay := Not fWantPlay;
   Finally
    fLock.Leave;
   End;
   fWake.SetEvent;
  End;

 Procedure TGhostReplayThread.Skip(Seconds : Double);
  Begin
   fLock.Enter;
   Try
    fSeek  := fState.Position + Seconds;
    fDirty := True;
   Finally
    fLock.Leave;
   End;
   fWake.SetEvent;
  End;

 Function TGhostReplayThread.Snapshot : TGhostState;
  Begin
   fLock.Enter;
   Try
    Result := fState;
   Finally
    fLock.Leave;
   End;
  End;

 Procedure TGhostReplayThread.Execute;
  Type
   TInit = Packed Record
    Public
     Lat     : Double;
     Lon     : Double;
     Alt     : Double;
     Pitch   : Double;
     Bank    : Double;
     Heading : Double;
     Ground  : DWORD;
     Speed   : DWORD;
   End;
  Var
   Lib    : HMODULE;
   h      : THandle;
   DB     : TFDConnection;
   q      : TFDQuery;
   Ins    : TFDQuery;
   Rows   : TArray<TGhostSample>;
   OpenSC : Function(Var h : THandle; n : PAnsiChar; w : HWND; e : DWORD; EH : THandle; c : DWORD) : HRESULT;
   Stdcall;
   CloseSC : Function(h : THandle) : HRESULT;
   Stdcall;
   NextSC : Function(h : THandle; Var p : Pointer; Var Size : DWORD) : HRESULT;
   Stdcall;
   EnumSC : Function(h : THandle; r, t : DWORD) : HRESULT;
   Stdcall;
   CreateSC : Function(h : THandle; t, l, n : PAnsiChar; Init : TInit; r : DWORD) : HRESULT;
   Stdcall;
   ReleaseSC : Function(h : THandle; o, r : DWORD) : HRESULT;
   Stdcall;
   RemoveSC : Function(h : THandle; o, r : DWORD) : HRESULT;
   Stdcall;
   AddSC : Function(h : THandle; d : DWORD; n, u : PAnsiChar; t : DWORD; e : Single; ID : DWORD) : HRESULT;
   Stdcall;
   SetSC : Function(h : THandle; d, o, f, n, Size : DWORD; p : Pointer) : HRESULT;
   Stdcall;
   MapSC : Function(h : THandle; e : DWORD; n : PAnsiChar) : HRESULT;
   Stdcall;
   EventSC : Function(h : THandle; o, e, v, g, f : DWORD) : HRESULT;
   Stdcall;
   p               : Pointer;
   Size            : DWORD;
   ID              : DWORD;
   Obj             : DWORD;
   Count           : DWORD;
   Entry           : DWORD;
   OutOf           : DWORD;
   i               : DWORD;
   j               : DWORD;
   Packet          : DWORD;
   Models          : TList<TGhostModel>;
   InstalledModels : TArray<TAIModelInfo>;
   ModelIndex      : TDictionary<String, TAIModelInfo>;
   InstalledModel  : TAIModelInfo;
   OutputValue     : Double;
   KnownModel      : Boolean;
   M               : TGhostModel;
   Best            : TGhostModel;
   Score           : Integer;
   BestScore       : Integer;
   K               : Integer;
   Blob            : RawByteString;
   b               : TBytes;
   a               : TGhostSample;
   Z               : TGhostSample;
   r               : TGhostSample;
   Init            : TInit;
   Current         : Double;
   First           : Double;
   Last            : Double;
   Tick            : UInt64;
   Prev            : UInt64;
   Deadline        : UInt64;
   Play            : Boolean;
   Dirty           : Boolean;
   Opened          : Boolean;
   Enumerated      : Boolean;
   Ready           : Boolean;
   Disabled        : Array [0..GhostVisualCount - 1] Of Boolean;
   LastLights      : Integer;
   v               : AnsiString;
   Units           : AnsiString;
   Rules           : String;
   Doc             : IXMLDocument;
   DocObj          : TXMLDocument;
   Packets         : TDictionary<DWORD, Integer>;
   LastPacket      : Function(h : THandle; Var ID : DWORD) : HRESULT;
   Stdcall;

   Procedure Check(HR : HRESULT; Const Op : String);
    Begin
     If HR < 0 Then
      Raise Exception.CreateFmt('Ghost %s: %.8x', [Op, Cardinal(HR)]);
    End;

   Function Address(Const n : AnsiString) : Pointer;
    Begin
     Result := GetProcAddress(Lib, PAnsiChar(n));
     If Result = Nil Then
      Raise Exception.Create('Ghost: missing ' + String(n));
    End;

   Function U32(Offset : NativeUInt) : DWORD;
    Begin
     Move(PByte(NativeUInt(p) + Offset)^, Result, 4);
    End;

   Function Text(Offset : NativeUInt) : String;
    Var
     s : AnsiString;
     n : Integer;
    Begin
     n := 0;
     While (n < 256) And (PByte(NativeUInt(p) + Offset + NativeUInt(n))^ <> 0) Do
      Inc(n);
     SetString(s, PAnsiChar(NativeUInt(p) + Offset), n);
     Result := String(s);
    End;

   Procedure RuleNode(Node : IXMLNode);
    Var
     x      : Integer;
     Types  : String;
     Titles : String;
    Begin
     If SameText(Node.NodeName, 'ModelMatchRule') Then
      Begin
       Types := ' ' + UpperCase(VarToStr(Node.Attributes['TypeCode'])) + ' ';
       If Pos(' ' + UpperCase(fICAO) + ' ', Types) > 0 Then
        Begin
         Titles := UpperCase(VarToStr(Node.Attributes['ModelName']));
         Rules  := Rules + '|' + StringReplace(Titles, '//', '|', [rfReplaceAll]) + '|';
        End;
      End;
     For x := 0 To Node.ChildNodes.Count - 1 Do
      RuleNode(Node.ChildNodes[x]);
    End;

   Procedure Poll;
    Var
     n    : Integer;
     i    : DWORD;
     j    : DWORD;
     t    : TGhostModel;
     Code : DWORD;
     Sent : DWORD;
    Begin
     For n := 1 To 256 Do
      Begin
       p    := Nil;
       Size := 0;
       If NextSC(h, p, Size) < 0 Then
        Break;
       If (p = Nil) Or (Size < 12) Then
        Break;
       ID := U32(8);
       Case ID Of
        1 :
         Begin
          If Size < 24 Then
           Continue;
          Code := U32(12);
          Sent := U32(16);
          If Packets.TryGetValue(Sent, K) Then
           Begin
            Disabled[K] := True;
            Log(1, Format('Ghost visual %d disabled: SimConnect exception %d', [K, Code]));
           End
          Else
           Raise Exception.CreateFmt('Ghost: SimConnect exception %d (packet %d)', [Code, Sent]);
         End;
        2 :
         Begin
          If (Size < 308) Or (U32(268) <> 12) Or Not(SameText(Text(12), 'SunRise') Or SameText(Text(12), 'Microsoft Flight Simulator 2024')) Then
           Raise Exception.Create('Ghost requires Microsoft Flight Simulator 2024');
          Opened := True;
         End;
        3 :
         Raise Exception.Create('Ghost: simulator disconnected');
        12 :
         If (Size >= 20) And (U32(12) = 2) Then
          Begin
           Obj := U32(16);
           If Obj = 0 Then
            Raise Exception.Create('Ghost: invalid object ID');
           Check(ReleaseSC(h, Obj, 3), 'release AI');
           For j := 1 To 3 Do
            Check(EventSC(h, Obj, j, 1, $FFFFFFFF, 16), 'freeze');
           Ready := True;
          End;
        38 :
         If (Size >= 28) And (U32(12) = 1) Then
          Begin
           Count := U32(16);
           Entry := U32(20);
           OutOf := U32(24);
           If Count > (Size - 28) Div 512 Then
            Raise Exception.Create('Ghost: malformed model list');
           If Count > 0 Then
            For i := 0 To Count - 1 Do
             Begin
              t.Title  := Text(28 + i * 512);
              t.Livery := Text(28 + i * 512 + 256);
              Models.Add(t);
             End;
           If (OutOf = 0) Or (Entry + 1 >= OutOf) Then
            Enumerated := True;
          End;
       End;
      End;
    End;

   Function ReadRow(At : Double; After : Boolean) : TGhostSample;
    Begin
     q.Close;
     If After Then
      q.SQL.Text := 'select frame from frames where seconds>=:t order by seconds limit 1'
     Else
      q.SQL.Text                := 'select frame from frames where seconds<=:t order by seconds desc limit 1';
     q.ParamByName('t').AsFloat := At;
     q.Open;
     If q.IsEmpty Then
      Raise Exception.Create('Ghost: trajectory outside range');
     b := q.Fields[0].AsBytes;
     If Length(b) <> SizeOf(Result) Then
      Raise Exception.Create('Ghost: invalid cached frame');
     Move(b[0], Result, SizeOf(Result));
    End;

   Procedure TrackVisual(Index : Integer);
    Begin
     If Packets.Count > 4096 Then
      Packets.Clear;
     If LastPacket(h, Packet) >= 0 Then
      Packets.AddOrSetValue(Packet, Index);
    End;

  Begin
   Lib        := 0;
   h          := 0;
   Obj        := 0;
   DB         := Nil;
   q          := Nil;
   Ins        := Nil;
   Models     := TList<TGhostModel>.Create;
   ModelIndex := TDictionary<String, TAIModelInfo>.Create;
   Packets    := TDictionary<DWORD, Integer>.Create;
   FillChar(Disabled, SizeOf(Disabled), 0);
   Opened     := False;
   Enumerated := False;
   Ready      := False;
   LastLights := -1;
   Try
    Try
     DB                           := TFDConnection.Create(Nil);
     DB.LoginPrompt               := False;
     DB.Params.Values['DriverID'] := 'SQLite';
     DB.Params.Values['Database'] := ':memory:';
     DB.Connected                 := True;
     DB.ExecSQL('create table frames(seconds real primary key, frame blob not null)');
     Ins            := TFDQuery.Create(Nil);
     Ins.Connection := DB;
     Ins.SQL.Text   := 'insert into frames values(:t,:f)';
     Rows           := fRows;
     fRows          := Nil;
     First          := Rows[0].Seconds;
     Last           := Rows[High(Rows)].Seconds;
     DB.StartTransaction;
     For r In Rows Do
      Begin
       If Terminated Then
        Exit;
       Ins.ParamByName('t').AsFloat := r.Seconds;
       SetString(Blob, PAnsiChar(@r), SizeOf(r));
       Ins.ParamByName('f').AsBlob := Blob;
       Ins.ExecSQL;
      End;
     DB.Commit;
     Rows         := Nil;
     q            := TFDQuery.Create(Nil);
     q.Connection := DB;
     Rules        := '';
     If FileExists(fVMR) Then
      Begin
       DocObj           := TXMLDocument.Create(Nil);
       DocObj.DOMVendor := GetDOMVendor('Omni XML');
       Doc              := DocObj;
       Doc.LoadFromFile(fVMR);
       RuleNode(Doc.DocumentElement);
       Doc := Nil;
      End;
     Lib := LoadLibrary(PChar(fDLL));
     If Lib = 0 Then
      RaiseLastOSError;
     @OpenSC := Address('SimConnect_Open');
     @CloseSC := Address('SimConnect_Close');
     @NextSC := Address('SimConnect_GetNextDispatch');
     @EnumSC := Address('SimConnect_EnumerateSimObjectsAndLiveries');
     @CreateSC := Address('SimConnect_AICreateNonATCAircraft_EX1');
     @ReleaseSC := Address('SimConnect_AIReleaseControl');
     @RemoveSC := Address('SimConnect_AIRemoveObject');
     @AddSC := Address('SimConnect_AddToDataDefinition');
     @SetSC := Address('SimConnect_SetDataOnSimObject');
     @MapSC := Address('SimConnect_MapClientEventToSimEvent');
     @EventSC := Address('SimConnect_TransmitClientEvent');
     @LastPacket := Address('SimConnect_GetLastSentPacketID');
     Check(OpenSC(h, 'MSFS24-FDR Ghost', 0, 0, 0, 0), 'open');
     Deadline := GetTickCount64 + 10000;
     While Not Opened And Not Terminated Do
      Begin
       Poll;
       If GetTickCount64 > Deadline Then
        Raise Exception.Create('Ghost: OPEN timeout');
       fWake.WaitFor(10);
      End;
     If Terminated Then
      Exit;
     Check(EnumSC(h, 1, 2), 'enumerate aircraft');
     Deadline := GetTickCount64 + 15000;
     While Not Enumerated And Not Terminated Do
      Begin
       Poll;
       If GetTickCount64 > Deadline Then
        Raise Exception.Create('Ghost: model enumeration timeout');
       fWake.WaitFor(10);
      End;
     If Terminated Then
      Exit;
     If fInventory <> Nil Then
      Begin
       InstalledModels := fInventory.Models;
       For InstalledModel In InstalledModels Do
        ModelIndex.AddOrSetValue(UpperCase(InstalledModel.Title), InstalledModel);
      End;
     BestScore := -1;
     Best      := Default(TGhostModel);
     For M In Models Do
      Begin
       Score := GhostModelScore(fICAO, M.Title, Rules);
       If fInventory <> Nil Then
        Begin
         KnownModel := ModelIndex.TryGetValue(UpperCase(M.Title), InstalledModel);
         If KnownModel Then
          Begin
           Score := AIModelMatchScore(InstalledModel, fICAO, fAirline, fRegistration, fAircraftTitle);
           If (Score >= 0) And (Rules <> '') And (Pos('|' + UpperCase(M.Title) + '|', Rules) > 0) Then
            Inc(Score, 1000);
          End;
         If Not KnownModel And ((Pos('FSLTL', UpperCase(M.Title)) > 0) Or (Pos('AIG', UpperCase(M.Title)) > 0)) Then
          Score := -1;
        End;
       If Score > BestScore Then
        Begin
         BestScore := Score;
         Best      := M;
        End;
      End;
     If BestScore < 0 Then
      Raise Exception.Create('Ghost: no installed FSLTL / AIPlane model matched');
     fLock.Enter;
     Try
      fState.Model := Best.Title;
      Current      := EnsureRange(fSeek, First, Last);
     Finally
      fLock.Leave;
     End;
     r := ReadRow(Current, False);
     FillChar(Init, SizeOf(Init), 0);
     Move(r.Pose, Init, 48);
     For i := 0 To 5 Do
      Begin
       v     := PoseVars[i];
       Units := 'degrees';
       If i = 2 Then
        Units := 'feet';
       Check(AddSC(h, 1, PAnsiChar(v), PAnsiChar(Units), 4, 0, $FFFFFFFF), 'pose definition');
      End;
     Check(MapSC(h, 1, 'FREEZE_LATITUDE_LONGITUDE_SET'), 'freeze map');
     Check(MapSC(h, 2, 'FREEZE_ALTITUDE_SET'), 'freeze map');
     Check(MapSC(h, 3, 'FREEZE_ATTITUDE_SET'), 'freeze map');
     For i := 0 To 9 Do
      Begin
       v := LightEvents[i];
       Check(MapSC(h, 100 + i, PAnsiChar(v)), 'light map');
      End;
     For i := 0 To GhostVisualCount - 1 Do
      If VisualVars[i] <> '' Then
       Begin
        If (fInventory <> Nil) And (FSLTLProfileIndex(Best.Title) >= 0) And Not FSLTLUses(Best.Title, String(VisualVars[i])) Then
         Begin
          Disabled[i] := True;
          Continue;
         End;
        v     := VisualVars[i];
        Units := 'percent over 100';
        If i In [11, 12, 15, 16, 18, 19, 22, 23] Then
         Units := 'percent';
        If i In [13, 14, 20, 21, 27] Then
         Units := 'bool';
        If i = 28 Then
         Units := 'bool';
        If i In [29, 30, 31, 32] Then
         Units := 'pounds';
        If i In [34, 35, 36, 37, 38, 39, 40, 41] Then
         Units := 'RPM';
        If i In [42, 45] Then
         Units := 'knots';
        If i = 43 Then
         Units := 'feet per minute';
        If i = 44 Then
         Units := 'feet';
        If i = 46 Then
         Units := 'feet per second';
        If i = 47 Then
         Units := 'radians per second';
        If i >= 48 Then
         Units := 'percent';
        If AddSC(h, 10 + i, PAnsiChar(v), PAnsiChar(Units), 4, 0, $FFFFFFFF) < 0 Then
         Disabled[i] := True
        Else
         TrackVisual(i);
       End;
     v     := AnsiString(Best.Title);
     Units := AnsiString(Best.Livery);
     Check(CreateSC(h, PAnsiChar(v), PAnsiChar(Units), 'FDRGHOST', Init, 2), 'create');
     Deadline := GetTickCount64 + 15000;
     While Not Ready And Not Terminated Do
      Begin
       Poll;
       If GetTickCount64 > Deadline Then
        Raise Exception.Create('Ghost: creation timeout');
       fWake.WaitFor(10);
      End;
     Prev := GetTickCount64;
     While Not Terminated Do
      Begin
       Poll;
       Tick := GetTickCount64;
       fLock.Enter;
       Try
        Play  := fWantPlay;
        Dirty := fDirty;
        If Dirty Then
         Begin
          Current := EnsureRange(fSeek, First, Last);
          fDirty  := False;
         End;
       Finally
        fLock.Leave;
       End;
       If Play And Not Dirty Then
        Current := Min(Last, Current + (Tick - Prev) / 1000);
       Prev     := Tick;
       If Play Or Dirty Then
        Begin
         a := ReadRow(Current, False);
         Z := ReadRow(Current, True);
         r := GhostInterpolate(a, Z, Current);
         Check(SetSC(h, 1, Obj, 0, 0, 48, @r.Pose[0]), 'position');
         For i := 0 To GhostVisualCount - 1 Do
          If (i <> 17) And Not Disabled[i] And Not IsNan(r.Visual[i]) And Not IsInfinite(r.Visual[i]) Then
           Begin
            OutputValue := r.Visual[i];
            If i In [34, 35, 36, 37] Then
             OutputValue := OutputValue * 163.84; // ENG N1 RPM uses 0..16384 for 0..100%.
            If SetSC(h, 10 + i, Obj, 0, 0, 8, @OutputValue) < 0 Then
             Disabled[i] := True
            Else
             TrackVisual(i);
           End;
         If Not Disabled[17] And Not IsNan(r.Visual[17]) And Not IsInfinite(r.Visual[17]) Then
          If LastLights <> Round(r.Visual[17]) Then
           Begin
            LastLights := Round(r.Visual[17]);
            For i      := 0 To 9 Do
             Begin
              EventSC(h, Obj, 100 + i, (DWORD(LastLights) Shr i) And 1, $FFFFFFFF, 16);
              TrackVisual(17);
             End;
           End;
        End;
       fLock.Enter;
       Try
        fState.Position := Current;
        fState.Finished := Current >= Last;
        If fState.Finished Then
         fWantPlay     := False;
        fState.Playing := fWantPlay;
       Finally
        fLock.Leave;
       End;
       fWake.WaitFor(Max(1, 1000 Div fHz));
      End;
    Except
     On e : Exception Do
      Begin
       fLock.Enter;
       Try
        fState.Error   := e.Message;
        fState.Failed  := True;
        fState.Playing := False;
       Finally
        fLock.Leave;
       End;
       Log(1, e.Message);
      End;
    End;
   Finally
    If h <> 0 Then
     Begin
      // Drain a pending creation before closing, so late assignment can be removed.
      If (Obj = 0) And Not Ready And Assigned(NextSC) Then
       Begin
        Deadline := GetTickCount64 + 1000;
        While GetTickCount64 < Deadline Do
         Begin
          Try
           Poll;
          Except
           Break;
          End;
          If Obj <> 0 Then
           Break;
          fWake.WaitFor(10);
         End;
       End;
      If (Obj <> 0) And Assigned(RemoveSC) Then
       RemoveSC(h, Obj, 4);
      If Assigned(CloseSC) Then
       CloseSC(h);
     End;
    If Lib <> 0 Then
     FreeLibrary(Lib);
    Packets.Free;
    ModelIndex.Free;
    Models.Free;
    Ins.Free;
    q.Free;
    DB.Free;
   End;
  End;

End.
