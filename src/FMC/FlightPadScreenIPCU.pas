{$StackFrames On}
Unit FlightPadScreenIPCU;

Interface

 Uses
  Winapi.Windows, System.SysUtils;

 Const
  FlightPadTextLength  = 14 * 26; // 24 UTF-16 cells + CRLF per row
  FlightPadHeartbeatMS = 5000;

 Type
  // Fixed layout, shared unchanged between Win32 FlightPad and Win64 FDR.
  TFlightPadScreenPacket = Packed Record
   Public
    Magic         : Cardinal;
    Version       : Cardinal;
    PacketSize    : Cardinal;
    ProcessID     : Cardinal;
    HeartbeatTick : UInt64;
    ScreenTick    : UInt64;
    ScreenUTC     : TFileTime;
    Available     : Cardinal;
    TextLength    : Cardinal;
    Text          : Array [0 .. FlightPadTextLength - 1] Of WideChar;
  End;

  TFlightPadScreenSnapshot = Record
   Public
    Text       : String;
    ProcessID  : Cardinal;
    ScreenTick : UInt64;
    ScreenUTC  : TFileTime;
  End;

  TFlightPadScreenPublisher = Class
   Private
    FMap           : THandle;
    FMutex         : THandle;
    FView          : Pointer;
    FLastText      : String;
    FLastAvailable : Boolean;
    FScreenTick    : UInt64;
    FScreenUTC     : TFileTime;
   Public
    Constructor Create(Const Profile : String);
    Destructor Destroy; Override;
    Procedure Publish(Const Text : String; Available : Boolean);
  End;

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
   FMutex := CreateMutex(Nil, False, PChar(Name + '.Lock'));
   If FMutex = 0 Then
    Exit;
   FMap := CreateFileMapping(INVALID_HANDLE_VALUE, Nil, PAGE_READWRITE, 0, SizeOf(TFlightPadScreenPacket), PChar(Name));
   If FMap = 0 Then
    Exit;
   FView := MapViewOfFile(FMap, FILE_MAP_WRITE, 0, 0, SizeOf(TFlightPadScreenPacket));
  End;

 Destructor TFlightPadScreenPublisher.Destroy;
  Begin
   Publish('', False);
   If FView <> Nil Then
    UnmapViewOfFile(FView);
   If FMap <> 0 Then
    CloseHandle(FMap);
   If FMutex <> 0 Then
    CloseHandle(FMutex);
   Inherited;
  End;

 Procedure TFlightPadScreenPublisher.Publish(Const Text : String; Available : Boolean);
  Var
   P : TFlightPadScreenPacket;
   W : DWORD;
  Begin
   If (FView = Nil) Or (FMutex = 0) Then
    Exit;
   Available := Available And (Length(Text) = FlightPadTextLength);
   W         := WaitForSingleObject(FMutex, 0);
   If (W <> WAIT_OBJECT_0) And (W <> WAIT_ABANDONED) Then
    Exit;
   Try
    If (Text <> FLastText) Or (Available <> FLastAvailable) Or (FScreenTick = 0) Then
     Begin
      FScreenTick := GetTickCount64;
      GetSystemTimeAsFileTime(FScreenUTC);
      FLastText      := Text;
      FLastAvailable := Available;
     End;
    FillChar(P, SizeOf(P), 0);
    P.Magic         := ScreenMagic;
    P.Version       := 1;
    P.PacketSize    := SizeOf(P);
    P.ProcessID     := GetCurrentProcessId;
    P.HeartbeatTick := GetTickCount64;
    P.ScreenTick    := FScreenTick;
    P.ScreenUTC     := FScreenUTC;
    If Available Then
     Begin
      P.Available  := 1;
      P.TextLength := Length(Text);
      Move(PChar(Text)^, P.Text[0], Length(Text) * SizeOf(WideChar));
     End;
    Move(P, FView^, SizeOf(P));
   Finally
    ReleaseMutex(FMutex);
   End;
  End;

 Function ReadFlightPadScreenPID(Const Profile : String; PID : Cardinal; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Var
   M       : THandle;
   Lock    : THandle;
   View    : Pointer;
   P       : TFlightPadScreenPacket;
   Name    : String;
   W       : DWORD;
   NowTick : UInt64;
   R       : Integer;
  Begin
   Result              := False;
   Snapshot.Text       := '';
   Snapshot.ProcessID  := 0;
   Snapshot.ScreenTick := 0;
   FillChar(Snapshot.ScreenUTC, SizeOf(Snapshot.ScreenUTC), 0);
   Name := ObjectName(Profile, PID);
   Lock := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, PChar(Name + '.Lock'));
   If Lock = 0 Then
    Exit;
   Try
    M := OpenFileMapping(FILE_MAP_READ, False, PChar(Name));
    If M = 0 Then
     Exit;
    Try
     View := MapViewOfFile(M, FILE_MAP_READ, 0, 0, SizeOf(P));
     If View = Nil Then
      Exit;
     Try
      W := WaitForSingleObject(Lock, 0);
      If (W <> WAIT_OBJECT_0) And (W <> WAIT_ABANDONED) Then
       Exit;
      Try
       Move(View^, P, SizeOf(P));
      Finally
       ReleaseMutex(Lock);
      End;
     Finally
      UnmapViewOfFile(View);
     End;
    Finally
     CloseHandle(M);
    End;
   Finally
    CloseHandle(Lock);
   End;
   NowTick := GetTickCount64;
   If (P.Magic <> ScreenMagic) Or (P.Version <> 1) Or (P.PacketSize <> SizeOf(P)) Or (P.ProcessID <> PID) Or (P.Available <> 1) Or (P.TextLength <> FlightPadTextLength) Or (P.HeartbeatTick > NowTick) Or (NowTick - P.HeartbeatTick > FlightPadHeartbeatMS) Then
    Exit;
   For R := 0 To 13 Do
    If (P.Text[R * 26 + 24] <> #13) Or (P.Text[R * 26 + 25] <> #10) Then
     Exit;
   SetString(Snapshot.Text, PWideChar(@P.Text[0]), P.TextLength);
   If Pos(#0, Snapshot.Text) > 0 Then
    Begin
     Snapshot.Text := '';
     Exit;
    End;
   Snapshot.ProcessID  := PID;
   Snapshot.ScreenTick := P.ScreenTick;
   Snapshot.ScreenUTC  := P.ScreenUTC;
   Result              := True;
  End;

 Function ReadFlightPadScreen(Const Profile : String; Out Snapshot : TFlightPadScreenSnapshot) : Boolean;
  Var
   Processes : THandle;
   Entry     : TProcessEntry32;
   Candidate : TFlightPadScreenSnapshot;
  Begin
   Result              := False;
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

End.
