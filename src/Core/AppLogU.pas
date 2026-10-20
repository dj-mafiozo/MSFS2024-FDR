{$StackFrames On}
Unit AppLogU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs;

 Procedure StartLog(Const Path, Level : String);
 Procedure Log(Level : Integer; Const Message : String);

Implementation

 Type
  TCrashHandler = Function(Info : Pointer) : Longint; Stdcall;

 Var
  FileName       : String;
  MaxLevel       : Integer = 2;
  Lock           : TCriticalSection;
  DumpPath       : String;
  DebugLib       : HMODULE;
  WriteDump      : Function(Process : THandle; PID : DWORD; FileHandle : THandle; Kind : DWORD; ExceptionInfo, UserStreams, Callback : Pointer) : BOOL; Stdcall;
  PreviousFilter : TCrashHandler;

 Function CrashFilter(Info : Pointer) : Longint; Stdcall;
  Type
   TDumpException = Record
    Public
     ThreadID       : DWORD;
     Pointers       : Pointer;
     ClientPointers : BOOL;
   End;
  Var
   H : THandle;
   E : TDumpException;
  Begin
   H := CreateFile(PChar(DumpPath), GENERIC_WRITE, FILE_SHARE_READ, Nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
   If H <> INVALID_HANDLE_VALUE Then
    Begin
     E.ThreadID       := GetCurrentThreadId;
     E.Pointers       := Info;
     E.ClientPointers := False;
     If Assigned(WriteDump) Then
      If Info = Nil Then
       WriteDump(GetCurrentProcess, GetCurrentProcessId, H, 0, Nil, Nil, Nil)
      Else
       WriteDump(GetCurrentProcess, GetCurrentProcessId, H, 0, @E, Nil, Nil);
     CloseHandle(H);
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
      @WriteDump    := GetProcAddress(DebugLib, 'MiniDumpWriteDump');
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
   F     : TFileStream;
   Bytes : TBytes;
  Begin
   If (FileName = '') Or (Level > MaxLevel) Then
    Exit;
   Lock.Enter;
   Try
    Try
     If FileExists(FileName) Then
      F := TFileStream.Create(FileName, fmOpenReadWrite Or fmShareDenyWrite)
     Else
      F := TFileStream.Create(FileName, fmCreate);
     Try
      F.Seek(0, soEnd);
      Bytes := TEncoding.UTF8.GetBytes(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' [' + IntToStr(Level) + '] ' + Message + sLineBreak);
      F.WriteBuffer(Bytes[0], Length(Bytes));
     Finally
      F.Free;
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
