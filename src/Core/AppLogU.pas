{$StackFrames On}
Unit AppLogU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs;

 Procedure StartLog(Const Path, Level : String);
 Procedure Log(Level : Integer; Const Message : String);

Implementation

 Type
  TCrashHandler = Function(Info : Pointer) : LongInt;

  Stdcall;

 Var
  FileName  : String;
  MaxLevel  : Integer = 2;
  Lock      : TCriticalSection;
  DumpPath  : String;
  DebugLib  : HMODULE;
  WriteDump : Function(Process : THandle; PID : DWORD; FileHandle : THandle; Kind : DWORD; ExceptionInfo, UserStreams, Callback : Pointer) : BOOL;
  Stdcall;
  PreviousFilter : TCrashHandler;

 Function CrashFilter(Info : Pointer) : LongInt; Stdcall;
  Type
   TDumpException = Record
    Public
     ThreadID       : DWORD;
     Pointers       : Pointer;
     ClientPointers : BOOL;
   End;
  Var
   h : THandle;
   e : TDumpException;
  Begin
   h := CreateFile(PChar(DumpPath), GENERIC_WRITE, FILE_SHARE_READ, Nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
   If h <> INVALID_HANDLE_VALUE Then
    Begin
     e.ThreadID       := GetCurrentThreadId;
     e.Pointers       := Info;
     e.ClientPointers := False;
     If Assigned(WriteDump) Then
      If Info = Nil Then
       WriteDump(GetCurrentProcess, GetCurrentProcessId, h, 0, Nil, Nil, Nil)
      Else
       WriteDump(GetCurrentProcess, GetCurrentProcessId, h, 0, @e, Nil, Nil);
     CloseHandle(h);
    End;
   Result := 0;
   If Assigned(PreviousFilter) Then
    Result := PreviousFilter(Info);
  End;

 Procedure StartLog(Const Path, Level : String);
  Begin
   DumpPath := ChangeFileExt(Path, '.dmp');
   If DebugLib = 0 Then
    Begin
     DebugLib := LoadLibrary('dbghelp.dll');
     If DebugLib <> 0 Then
      @WriteDump := GetProcAddress(DebugLib, 'MiniDumpWriteDump');
     PreviousFilter := TCrashHandler(SetUnhandledExceptionFilter(@CrashFilter));
    End;
   FileName := Path;
   If FileExists(Path) Then
    MoveFileEx(PChar(Path), PChar(Path + '.old'), MOVEFILE_REPLACE_EXISTING);
   MaxLevel := 2;
   If SameText(Level, 'FATAL') Then
    MaxLevel := 0
   Else If SameText(Level, 'WARNING') Then
    MaxLevel := 1
   Else If SameText(Level, 'TRACE') Then
    MaxLevel := 3
   Else If SameText(Level, 'PROFILE') Then
    MaxLevel := 4;
  End;

 Procedure Log(Level : Integer; Const Message : String);
  Var
   f     : TFileStream;
   Bytes : TBytes;
  Begin
   If (FileName = '') Or (Level > MaxLevel) Then
    Exit;
   Lock.Enter;
   Try
    Try
     If FileExists(FileName) Then
      f := TFileStream.Create(FileName, fmOpenReadWrite Or fmShareDenyWrite)
     Else
      f := TFileStream.Create(FileName, fmCreate);
     Try
      f.Seek(0, soEnd);
      Bytes := TEncoding.UTF8.GetBytes(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' [' + IntToStr(Level) + '] ' + Message + sLineBreak);
      f.WriteBuffer(Bytes[0], Length(Bytes));
     Finally
      f.Free;
     End;
    Except
     OutputDebugString(PChar(Message));
    End;
   Finally
    Lock.Leave;
   End;
  End;

Initialization

 Lock := TCriticalSection.Create;

Finalization

 Lock.Free;

End.
