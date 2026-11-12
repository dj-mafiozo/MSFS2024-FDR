{$StackFrames On}
Unit FlightPadScreenIPCU;

Interface

 Uses
  Winapi.Windows, System.SysUtils;

 Const
  FlightPadTextLength       = 14 * 26; // 24 UTF-16 cells + CRLF per row
  FlightPadHeartbeatMS      = 5000;
  FlightPadAppearanceLength = 32768;

 Type
  // Fixed layout, shared unchanged between Win32 FlightPad and Win64 FDR.
  TFlightPadScreenPacket = Packed Record
   Magic         : Cardinal;
   Version       : Cardinal;
   PacketSize    : Cardinal;
   ProcessID     : Cardinal;
   HeartbeatTick : UInt64;
   ScreenTick    : UInt64;
   ScreenUTC     : TFileTime;
   Available     : Cardinal;
   TextLength    : Cardinal;
   Text          : Array [0..FlightPadTextLength - 1] Of WideChar;
  End;

  TFlightPadAppearancePacket = Packed Record
   Header           : TFlightPadScreenPacket;
   AppearanceLength : Cardinal;
   Appearance       : Array [0..FlightPadAppearanceLength - 1] Of WideChar;
  End;

  TFlightPadScreenSnapshot = Record
   Available      : Boolean;
   AppearanceJSON : String;
   Text           : String;
   ProcessID      : Cardinal;
   ScreenTick     : UInt64;
   ScreenUTC      : TFileTime;
  End;

  TFlightPadScreenPublisher = Class
   Private
    fMetaMap        : THandle;
    fMetaView       : Pointer;
    fLastAppearance : String;
    fMap            : THandle;
    fMutex          : THandle;
    fView           : Pointer;
    fLastText       : String;
    fLastAvailable  : Boolean;
    fScreenTick     : UInt64;
    fScreenUTC      : TFileTime;
   Public
    Constructor Create     (Const Profile : String);
    Destructor  Destroy; Override;
    Procedure   Publish    (Const Text : String; Available : Boolean);
    Procedure   PublishFull(Const Text, AppearanceJSON : String; Available : Boolean);
  End;

 Function ReadFlightPadScreenStatePID(Const Profile : String; PID : Cardinal; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
 Function ReadFlightPadScreenState(Const Profile : String; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
 Function ReadFlightPadScreen(Const Profile : String; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
 Function ReadFlightPadScreenPID(Const Profile : String; PID : Cardinal; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;

Implementation

 Uses
  Winapi.TlHelp32;

 Const
  ScreenMagic = $46504D43;

 Function ObjectName(Const Profile : String; PID : Cardinal) : String;
  Begin
   Result := 'Local\FlightPadFMC.Screen.v1.' + Profile + '.' + IntToStr(PID);
  End;

 Constructor TFlightPadScreenPublisher.Create(Const Profile : String);
  Var
   Name : String;
  Begin
   Inherited Create;
   If (Profile <> 'FenixA320') And (Profile <> 'FBWA320') Then
    Exit;
   Name   := ObjectName(Profile, GetCurrentProcessId);
   fMutex := CreateMutex(Nil, False, PChar(Name + '.Lock'));
   If fMutex = 0 Then
    Exit;
   fMap := CreateFileMapping(INVALID_HANDLE_VALUE, Nil, PAGE_READWRITE, 0, SizeOf(TFlightPadScreenPacket), PChar(Name));
   If fMap = 0 Then
    Exit;
   fView    := MapViewOfFile(fMap, FILE_MAP_WRITE, 0, 0, SizeOf(TFlightPadScreenPacket));
   Name     := StringReplace(Name, '.v1.', '.v2.', []);
   fMetaMap := CreateFileMapping(INVALID_HANDLE_VALUE, Nil, PAGE_READWRITE, 0, SizeOf(TFlightPadAppearancePacket), PChar(Name));
   If fMetaMap <> 0 Then
    fMetaView := MapViewOfFile(fMetaMap, FILE_MAP_WRITE, 0, 0, SizeOf(TFlightPadAppearancePacket));
  End;

 Destructor TFlightPadScreenPublisher.Destroy;
  Begin
   Publish('', False);
   If fMetaView <> Nil Then
    UnmapViewOfFile(fMetaView);
   If fMetaMap <> 0 Then
    CloseHandle(fMetaMap);
   If fView <> Nil Then
    UnmapViewOfFile(fView);
   If fMap <> 0 Then
    CloseHandle(fMap);
   If fMutex <> 0 Then
    CloseHandle(fMutex);
   Inherited;
  End;

 Procedure TFlightPadScreenPublisher.Publish(Const Text : String; Available : Boolean);
  Begin
   PublishFull(Text, '', Available);
  End;

 Procedure TFlightPadScreenPublisher.PublishFull(Const Text, AppearanceJSON : String; Available : Boolean);
  Var
   Full : TFlightPadAppearancePacket;
   p    : TFlightPadScreenPacket;
   w    : DWORD;
  Begin
   If (fView = Nil) Or (fMutex = 0) Then
    Exit;
   Available := Available And (Length(Text) = FlightPadTextLength) And (Length(AppearanceJSON) <= FlightPadAppearanceLength);
   w         := WaitForSingleObject(fMutex, 0);
   If (w <> WAIT_OBJECT_0) And (w <> WAIT_ABANDONED) Then
    Exit;
   Try
    If (Text <> fLastText) Or (Available <> fLastAvailable) Or (AppearanceJSON <> fLastAppearance) Or (fScreenTick = 0) Then
     Begin
      fScreenTick := GetTickCount64;
      GetSystemTimeAsFileTime(fScreenUTC);
      fLastAppearance := AppearanceJSON;
      fLastText       := Text;
      fLastAvailable  := Available;
     End;
    FillChar(p, SizeOf(p), 0);
    p.Magic         := ScreenMagic;
    p.Version       := 1;
    p.PacketSize    := SizeOf(p);
    p.ProcessID     := GetCurrentProcessId;
    p.HeartbeatTick := GetTickCount64;
    p.ScreenTick    := fScreenTick;
    p.ScreenUTC     := fScreenUTC;
    If Available Then
     Begin
      p.Available  := 1;
      p.TextLength := Length(Text);
      Move(PChar(Text)^, p.Text[0], Length(Text) * SizeOf(WideChar));
     End;
    Move(p, fView^, SizeOf(p));
    If fMetaView <> Nil Then
     Begin
      FillChar(Full, SizeOf(Full), 0);
      Full.Header            := p;
      Full.Header.Version    := 2;
      Full.Header.PacketSize := SizeOf(Full);
      If Length(Text) = FlightPadTextLength Then
       Begin
        Full.Header.TextLength := Length(Text);
        Move(PChar(Text)^, Full.Header.Text[0], Length(Text) * SizeOf(WideChar));
       End;
      If (Length(AppearanceJSON) > 0) And (Length(AppearanceJSON) <= FlightPadAppearanceLength) Then
       Begin
        Full.AppearanceLength := Length(AppearanceJSON);
        Move(PChar(AppearanceJSON)^, Full.Appearance[0], Length(AppearanceJSON) * SizeOf(WideChar));
       End;
      Move(Full, fMetaView^, SizeOf(Full));
     End;
   Finally
    ReleaseMutex(fMutex);
   End;
  End;

 Function ReadFlightPadScreenPID(Const Profile : String; PID : Cardinal; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Var
   m       : THandle;
   Lock    : THandle;
   View    : Pointer;
   p       : TFlightPadScreenPacket;
   Name    : String;
   w       : DWORD;
   NowTick : UInt64;
   r       : Integer;
  Begin
   Result              := False;
   Snapshot            := Default(TFlightPadScreenSnapshot);
   Snapshot.Text       := '';
   Snapshot.ProcessID  := 0;
   Snapshot.ScreenTick := 0;
   FillChar(Snapshot.ScreenUTC, SizeOf(Snapshot.ScreenUTC), 0);
   Name := ObjectName(Profile, PID);
   Lock := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, PChar(Name + '.Lock'));
   If Lock = 0 Then
    Exit;
   Try
    m := OpenFileMapping(FILE_MAP_READ, False, PChar(Name));
    If m = 0 Then
     Exit;
    Try
     View := MapViewOfFile(m, FILE_MAP_READ, 0, 0, SizeOf(p));
     If View = Nil Then
      Exit;
     Try
      w := WaitForSingleObject(Lock, 0);
      If (w <> WAIT_OBJECT_0) And (w <> WAIT_ABANDONED) Then
       Exit;
      Try
       Move(View^, p, SizeOf(p));
      Finally
       ReleaseMutex(Lock);
      End;
     Finally
      UnmapViewOfFile(View);
     End;
    Finally
     CloseHandle(m);
    End;
   Finally
    CloseHandle(Lock);
   End;
   NowTick := GetTickCount64;
   If (p.Magic <> ScreenMagic) Or (p.Version <> 1) Or (p.PacketSize <> SizeOf(p)) Or (p.ProcessID <> PID) Or (p.Available <> 1) Or (p.TextLength <> FlightPadTextLength) Or (p.HeartbeatTick > NowTick) Or (NowTick - p.HeartbeatTick > FlightPadHeartbeatMS) Then
    Exit;
   For r := 0 To 13 Do
    If (p.Text[r * 26 + 24] <> #13) Or (p.Text[r * 26 + 25] <> #10) Then
     Exit;
   SetString(Snapshot.Text, PWideChar(@p.Text[0]), p.TextLength);
   If Pos(#0, Snapshot.Text) > 0 Then
    Begin
     Snapshot.Text := '';
     Exit;
    End;
   Snapshot.Available  := True;
   Snapshot.ProcessID  := PID;
   Snapshot.ScreenTick := p.ScreenTick;
   Snapshot.ScreenUTC  := p.ScreenUTC;
   Result              := True;
  End;

 Function ReadFlightPadScreen(Const Profile : String; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Var
   Processes : THandle;
   Entry     : TProcessEntry32;
   Candidate : TFlightPadScreenSnapshot;
  Begin
   Result              := False;
   Snapshot            := Default(TFlightPadScreenSnapshot);
   Snapshot.Text       := '';
   Snapshot.ProcessID  := 0;
   Snapshot.ScreenTick := 0;
   FillChar(Snapshot.ScreenUTC, SizeOf(Snapshot.ScreenUTC), 0);
   Processes := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   If Processes = INVALID_HANDLE_VALUE Then
    Exit;
   Try
    Entry.dwSize := SizeOf(Entry);
    If Process32First(Processes, Entry) Then
     Repeat
      If ReadFlightPadScreenPID(Profile, Entry.th32ProcessID, Candidate) Then
       If Not Result Or (Candidate.ScreenTick > Snapshot.ScreenTick) Then
        Begin
         Snapshot := Candidate;
         Result   := True;
        End;
     Until Not Process32Next(Processes, Entry);
   Finally
    CloseHandle(Processes);
   End;
  End;

 Function ReadAppearancePID(Const Profile : String; PID : Cardinal; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Var
   m    : THandle;
   Lock : THandle;
   View : Pointer;
   p    : TFlightPadAppearancePacket;
   Name : String;
   w    : DWORD;
   t    : UInt64;
   r    : Integer;
  Begin
   Result   := False;
   Snapshot := Default(TFlightPadScreenSnapshot);
   Name     := ObjectName(Profile, PID);
   Lock     := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, PChar(Name + '.Lock'));
   If Lock = 0 Then
    Exit;
   Try
    Name := StringReplace(Name, '.v1.', '.v2.', []);
    m    := OpenFileMapping(FILE_MAP_READ, False, PChar(Name));
    If m = 0 Then
     Exit;
    Try
     View := MapViewOfFile(m, FILE_MAP_READ, 0, 0, SizeOf(p));
     If View = Nil Then
      Exit;
     Try
      w := WaitForSingleObject(Lock, 0);
      If (w <> WAIT_OBJECT_0) And (w <> WAIT_ABANDONED) Then
       Exit;
      Try
       Move(View^, p, SizeOf(p));
      Finally
       ReleaseMutex(Lock);
      End;
     Finally
      UnmapViewOfFile(View);
     End;
    Finally
     CloseHandle(m);
    End;
   Finally
    CloseHandle(Lock);
   End;
   t := GetTickCount64;
   If (p.Header.Magic <> ScreenMagic) Or (p.Header.Version <> 2) Or (p.Header.PacketSize <> SizeOf(p)) Or (p.Header.ProcessID <> PID) Or (p.Header.Available > 1) Or (p.Header.HeartbeatTick > t) Or (t - p.Header.HeartbeatTick > FlightPadHeartbeatMS) Or (p.AppearanceLength > FlightPadAppearanceLength) Or (p.Header.TextLength > FlightPadTextLength) Then
    Exit;
   If (p.Header.Available = 1) And (p.Header.TextLength <> FlightPadTextLength) Then
    Exit;
   If p.Header.TextLength > 0 Then
    Begin
     If p.Header.TextLength <> FlightPadTextLength Then
      Exit;
     For r := 0 To 13 Do
      If (p.Header.Text[r * 26 + 24] <> #13) Or (p.Header.Text[r * 26 + 25] <> #10) Then
       Exit;
     SetString(Snapshot.Text, PWideChar(@p.Header.Text[0]), p.Header.TextLength);
     If Pos(#0, Snapshot.Text) > 0 Then
      Exit;
    End;
   SetString(Snapshot.AppearanceJSON, PWideChar(@p.Appearance[0]), p.AppearanceLength);
   If Pos(#0, Snapshot.AppearanceJSON) > 0 Then
    Exit;
   Snapshot.Available  := p.Header.Available = 1;
   Snapshot.ProcessID  := PID;
   Snapshot.ScreenTick := p.Header.ScreenTick;
   Snapshot.ScreenUTC  := p.Header.ScreenUTC;
   Result              := True;
  End;

 Function ReadFlightPadScreenStatePID(Const Profile : String; PID : Cardinal; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Begin
   Result := ReadAppearancePID(Profile, PID, Snapshot);
   If Not Result Then
    Result := ReadFlightPadScreenPID(Profile, PID, Snapshot);
  End;

 Function ReadFlightPadScreenState(Const Profile : String; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Var
   Processes : THandle;
   Entry     : TProcessEntry32;
   Candidate : TFlightPadScreenSnapshot;
  Begin
   Result    := False;
   Snapshot  := Default(TFlightPadScreenSnapshot);
   Processes := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   If Processes = INVALID_HANDLE_VALUE Then
    Exit;
   Try
    Entry.dwSize := SizeOf(Entry);
    If Process32First(Processes, Entry) Then
     Repeat
      If ReadAppearancePID(Profile, Entry.th32ProcessID, Candidate) Then
       If Not Result Or (Candidate.ScreenTick > Snapshot.ScreenTick) Then
        Begin
         Snapshot := Candidate;
         Result   := True;
        End;
     Until Not Process32Next(Processes, Entry);
   Finally
    CloseHandle(Processes);
   End;
   If Not Result Then
    Result := ReadFlightPadScreen(Profile, Snapshot);
  End;

End.
