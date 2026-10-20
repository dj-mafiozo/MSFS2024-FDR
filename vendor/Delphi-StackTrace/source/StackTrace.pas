Unit StackTrace;

{
  Enables the collection and output of stack traces in Delphi code.

  For readable and sensible results, *current* PDB files must exist in the same directory.

  Anders Melander's map2pdb.exe can be used for this:
  https://bitbucket.org/anders_melander/map2pdb/src/master/


  Notes:

  As the Delphi runtime library handles things not consistently and contains bugs (see some of the comments in the code),
  I don't know if this works with other Delphi versions as well. Please use a memory leak detector to verify the behavior.

  Generally, the 64bit compiler and RTL fixes a few things, as exception reraising now always reuses the original exception
  object and it also generates source-line infos for the main part of the dpr file (the lines between "begin" and "end.").

  The 32bit compiler and RTL makes it nearly impossible to get the stacktrace from an non-delphi exception that is reraised:
  For some reason, the original exception object is released by the RTL and then a new one is created, but we still need the
  stackinfo from the original object which is now gone. It is not possible to recreate it. So for now, I just reattach the
  very last stackinfo, but depending on other exceptions thrown and catched between the original point and the reraise point,
  it may be no longer the correct one.

  To get notifications on DLL unloading, the Windows function LdrRegisterDllNotification is used, which  may change on
  later Windows releases (unlikely). But there is no alternative.


  Enable lookup of Windows symbols:

  The standard dbghelp.dll that comes with Windows does not support downloading from symbol servers. To use this, you need
  two DLLs from the "Windows Debugging Tools":
  https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools

  Both "dbghelp.dll" and "symsrv.dll" from
  "C:\Program Files (x86)\Windows Kits\10\Debuggers\x86" (32 bit)
  or
  "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64" (64 bit)
  needs to be copied into the same folder as the Delphi executable.

  To have the Windows symbols be used, the symbol search path needs to be altered, like this:
  TStackTraceHlp.SymSearchPath := 'srv*c:\temp\symbols*https://msdl.microsoft.com/download/symbols';

  "c:\temp\symbols" inside this example string specifies a folder that is used as a cache for the downloaded PDBs (see
  https://learn.microsoft.com/en-us/windows/win32/debug/symbol-paths).

  As the download takes time and needs internet connectivity, and the cache folder needs to be placed somewhere, this is
  usually not an option for production environments.
}

{$include LibOptions.inc}

Interface

 Uses
  Winapi.Windows,
  WinSlimLock,
  DbgHelp;

 Type
  // Supports the acquisition of stack traces with build-in Windows functionality.
  // The methods is also the basis for the private structure TExceptionHelp, which is used to capture
  // stack traces when exceptions are thrown.
  TStackTraceHlp = Record
   Private Type
    TAddr = DWORD_PTR;
   Strict Private
   Type
    self        = TStackTraceHlp;
    CONTEXT     = DbgHelp.CONTEXT;
    PCONTEXT    = ^CONTEXT;
    SYMBOL_INFO = DbgHelp.SYMBOL_INFO;

    TFrameInfo = Record
     ModuleName : String;
     FuncName : String;
     SrcFilename : String;
     SrcLineNo : uint32;
     Function ToString : String;
    End;

   Const
    FThread = THandle( -2); // = Winapi.Windows.GetCurrentThread

   Class Var
    FLock              : TSlimRWLock; // lock around all DbgHelp functions
    FHandlerCookie     : pointer;     // LdrRegisterDllNotification handle
    FProcess           : THandle;     // real handle of the current process, non-zero after SymInitialize
    FDoReinit          : boolean;     // set to true when a DLL was unloaded
    FSymSearchPath     : String;      // additional locations to lookup PDB files
    FEnableDebugOutput : boolean;     // controls debug output from dbghelp.dll

    Class Procedure InitSyms; Static;
    Class Function ProcessFrame(VirtualAddr : DWORD64) : TFrameInfo; Static;
    Class Function GetModuleFilename(hModule : HINST) : String; Static;
    Class Procedure SetSymSearchPath(Const Value : String); Static;

    Class Function GetFuncPtr(FuncName : PAnsiChar) : pointer; Static;
    Class Procedure OsDllNotification(Reason : ULONG; Data : pointer; CONTEXT : pointer); Stdcall; Static;
   Private
    Class Procedure Init; Static;
    Class Procedure Fini; Static;
    Class Procedure FiniSyms; Static;
    Class Procedure DoSetupContext(Var Ctx : CONTEXT); Static;
    Class Function DoGetStackTrace(Var Ctx : CONTEXT; SkipFrames : uint32; Out Addrs : Array Of TAddr) : uint32; Static;
    Class Function InterpretStackTrace(Const Addrs : Array Of TAddr; Count : uint32) : String; Static;
   Public
    // for the syntax, see: https://learn.microsoft.com/en-us/windows/win32/debug/symbol-paths
    Class Property SymSearchPath     : String Read FSymSearchPath Write SetSymSearchPath;
    Class Property EnableDebugOutput : boolean Read FEnableDebugOutput Write FEnableDebugOutput;

    Class Function GetStackTrace : String; Static;
  End;

  { ############################################################################ }
Implementation

 { ############################################################################ }

 Uses
  System.Types,
  System.SysUtils;

 Type
  TAddr = TStackTraceHlp.TAddr;

  TContextHlp = Record Helper For DbgHelp.CONTEXT
   Strict Private
    Function GetIP : TAddr; Inline;
    Function GetSP : TAddr; Inline;
    Function GetBP : TAddr; Inline;
    Procedure SetIP(Value : TAddr); Inline;
    Procedure SetSP(Value : TAddr); Inline;
    Procedure SetBP(Value : TAddr); Inline;
   Public
    Procedure SetNull; Inline;
    Property IP : TAddr Read GetIP Write SetIP;
    Property SP : TAddr Read GetSP Write SetSP;
    Property BP : TAddr Read GetBP Write SetBP;
  End;

  // ===================================================================================================================
  // ===================================================================================================================
 Procedure MyAssert(Cond : boolean); Inline;
  Begin
   {$Ifopt C+}
   If Not Cond Then
    Begin
     Winapi.Windows.OutputDebugString('StackTrace error');
     Winapi.Windows.DebugBreak;
    End;
   {$Endif}
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Procedure ZeroMem(Var Mem; Size : integer); Inline;
  Begin
   System.FillChar(Mem, Size, 0);
  End;

 { TContextHlp }

 // ===================================================================================================================
 // ===================================================================================================================
 Procedure TContextHlp.SetNull;
  Begin
   ZeroMem(self, sizeof(self));
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Function TContextHlp.GetIP : TAddr;
  Begin
   Result := {$Ifdef Win64} self.Rip {$Else} self.Eip {$Endif};
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Function TContextHlp.GetSP : TAddr;
  Begin
   Result := {$Ifdef Win64} self.Rsp {$Else} self.Esp {$Endif};
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Function TContextHlp.GetBP : TAddr;
  Begin
   Result := {$Ifdef Win64} self.Rbp {$Else} self.Ebp {$Endif};
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Procedure TContextHlp.SetIP(Value : TAddr);
  Begin
   {$Ifdef Win64} self.Rip {$Else} self.Eip {$Endif} := Value;
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Procedure TContextHlp.SetSP(Value : TAddr);
  Begin
   {$Ifdef Win64} self.Rsp {$Else} self.Esp {$Endif} := Value;
  End;

 // ===================================================================================================================
 // ===================================================================================================================
 Procedure TContextHlp.SetBP(Value : TAddr);
  Begin
   {$Ifdef Win64} self.Rbp {$Else} self.Ebp {$Endif} := Value;
  End;

 { TStackTraceHlp.TFrameInfo }

 // ===================================================================================================================
 // Returns a line of text for this stack frame.
 // ===================================================================================================================
 Function TStackTraceHlp.TFrameInfo.ToString : String;
  Begin
   If self.SrcLineNo = 0 Then
    Result := System.SysUtils.Format('%s%s', [self.ModuleName, self.FuncName])
   Else
    Result := System.SysUtils.Format('%s%s in %s (Line %u)', [self.ModuleName, self.FuncName, self.SrcFilename, self.SrcLineNo]);
  End;

 { TStackTraceHlp }

 // ===================================================================================================================
 // Setup for getting stack traces on Delphi exceptions.
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.Init;
  Var
   RegisterFunc : TLdrRegisterDllNotification;
  Begin
   // registering to get DLL unload notifications (may not work in future Windows versions, but there is nothing else!):
   RegisterFunc := self.GetFuncPtr('LdrRegisterDllNotification');
   If Assigned(RegisterFunc) Then
    MyAssert(RegisterFunc(0, self.OsDllNotification, Nil, FHandlerCookie) = STATUS_SUCCESS);
  End;

 // ===================================================================================================================
 // Teardown for getting stack traces on Delphi exceptions.
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.Fini;
  Var
   UnregisterFunc : TLdrUnregisterDllNotification;
  Begin
   If Assigned(FHandlerCookie) Then
    Begin
     UnregisterFunc := self.GetFuncPtr('LdrUnregisterDllNotification');
     MyAssert(UnregisterFunc(FHandlerCookie) = STATUS_SUCCESS);
    End;
  End;

 // ===================================================================================================================
 // Setter for property "SymSearchPath".
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.SetSymSearchPath(Const Value : String);
  Begin
   FSymSearchPath := Value;
   FDoReinit      := true;
  End;

 // ===================================================================================================================
 // Initializes the DbgHelp DLL for this process.
 // Must run in lock, as DbgHelp functions are not thread-safe.
 // Does not throw exceptions.
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.InitSyms;
  Var
   SearchPath : String;
   SymOptions : DWORD;
  Begin
   // address space of an unloaded DLL may be reused (e.g. dynamic plug-ins) => reinitialize DbgHelp's symbol cache:
   If FDoReinit Then
    Begin
     FDoReinit := false;
     self.FiniSyms;
     // Note: Calling DbgHelp.SymRefreshModuleList(FProcess) takes much longer than simply reinitializing everything,
     // even at the 2nd call in the same process, as it downloads Windows symbols for a lot of Windows DLLs.
     // This is surprising as SymInitialize() with Invade=true should load the same modules.
     // MyAssert(DbgHelp.SymRefreshModuleList(FProcess));
    End;

   // A process that calls SymInitialize should not call it again unless it calls SymCleanup first.
   If FProcess = 0 Then
    Begin

     FProcess := Winapi.Windows.OpenProcess(PROCESS_VM_READ Or PROCESS_QUERY_INFORMATION, false, Winapi.Windows.GetCurrentProcessId);
     MyAssert(FProcess <> 0);

     // SYMOPT_DEBUG will cause diagnostics to be written to the "Event Log" window of the Delphi IDE:
     SymOptions := SYMOPT_LOAD_LINES Or SYMOPT_DEFERRED_LOADS Or SYMOPT_UNDNAME;
     If FEnableDebugOutput Then
      SymOptions := SymOptions Or SYMOPT_DEBUG;
     DbgHelp.SymSetOptions(SymOptions);

     SearchPath := System.SysUtils.ExtractFileDir(self.GetModuleFilename(0));
     If FSymSearchPath <> '' Then
      Begin
       SearchPath := SearchPath + ';' + FSymSearchPath;
      End;

     MyAssert(DbgHelp.SymInitialize(FProcess, PChar(SearchPath), true));
    End;
  End;

 // ===================================================================================================================
 // Must run in lock, as DbgHelp functions are not thread-safe.
 // Does not throw exceptions.
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.FiniSyms;
  Begin
   If FProcess <> 0 Then
    Begin
     MyAssert(DbgHelp.SymCleanup(FProcess));
     MyAssert(Winapi.Windows.CloseHandle(FProcess));
     FProcess := 0;
    End;
  End;

 // ===================================================================================================================
 // Get pointer of function in ntdll.dll. Returns nil if unavaiable.
 // ===================================================================================================================
 Class Function TStackTraceHlp.GetFuncPtr(FuncName : PAnsiChar) : pointer;
  Begin
   Result := Winapi.Windows.GetProcAddress(Winapi.Windows.LoadLibrary('ntdll.dll'), FuncName);
  End;

 // ===================================================================================================================
 // Is called on loading and unloading of DLLs in the process. DLL unloading can occur at the very same time some thread
 // is taking a stack trace, but this thread should not have addresses of an unloading/unloaded DLL in its call stack.
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.OsDllNotification(Reason : ULONG; Data : pointer; CONTEXT : pointer);
  Begin
   If Reason = LDR_DLL_NOTIFICATION_REASON_UNLOADED Then
    FDoReinit := true;
  End;

 // ===================================================================================================================
 // Returns the full path to the loaded module (EXE oder DLL) <hModule>.
 // Does not throw exceptions. Does not return path names longer than 511 characters.
 // ===================================================================================================================
 Class Function TStackTraceHlp.GetModuleFilename(hModule : HINST) : String;
  Var
   Len    : DWORD;
   Buffer : Array [0 .. 511] Of char;
  Begin
   Len := System.Length(Buffer);
   If Winapi.Windows.GetModuleFilename(hModule, Buffer, Len) >= Len Then
    Result := '???'
   Else
    Result := Buffer;
  End;

 // ===================================================================================================================
 // Captures the stack for the CPU context <Ctx>. (The stack must still cover the location of <Ctx>.)
 // Does not throw exceptions.
 // ===================================================================================================================
 Class Function TStackTraceHlp.DoGetStackTrace(Var Ctx : CONTEXT; SkipFrames : uint32; Out Addrs : Array Of TAddr) : uint32;
  Const
   MachineType = {$Ifdef Win64} IMAGE_FILE_MACHINE_AMD64 {$Else} IMAGE_FILE_MACHINE_I386 {$Endif};
  Var
   Frame : STACKFRAME64;
  Begin
   // DbgHelp functions are not thread-safe:
   FLock.AcquireExclusive;
   Try

    self.InitSyms;

    ZeroMem(Frame, sizeof(Frame));
    Frame.AddrPC.Mode      := AddrModeFlat;
    Frame.AddrFrame.Mode   := AddrModeFlat;
    Frame.AddrStack.Mode   := AddrModeFlat;
    Frame.AddrPC.Offset    := Ctx.IP;
    Frame.AddrFrame.Offset := Ctx.BP;
    Frame.AddrStack.Offset := Ctx.SP;

    Result := 0;

    // ContextRecord: This context may be modified,
    While (int32(Result) <= System.High(Addrs)) And DbgHelp.StackWalk64(MachineType, FProcess, FThread, Frame, Ctx, Nil, DbgHelp.SymFunctionTableAccess64, DbgHelp.SymGetModuleBase64, Nil) Do
     Begin
      If SkipFrames > 0 Then
       Begin
        dec(SkipFrames);
        continue;
       End;
      {$Ifdef Win64}
      Addrs[Result] := Frame.AddrPC.Offset;
      inc(Result);
      {$Else}
      // prevent a Range Check exception on 32bit if Frame.AddrPC.Offset contains uint64(-1) which happens sometimes,
      // or a full 64bit address (happens when casting a COM interface fails):
      If Int64Rec(Frame.AddrPC.Offset).Hi = 0 Then
       Begin
        Addrs[Result] := Int64Rec(Frame.AddrPC.Offset).Lo;
        inc(Result);
       End;
      {$Endif}
     End;

   Finally
    FLock.ReleaseExclusive;
   End;
  End;

 // ===================================================================================================================
 // Provides information on the code address <VirtualAddr> via Windows' built-in mechanisms. The information improves
 // drastically if there are suitable pdb files for the EXE and DLLs.
 // Does not throw exceptions.
 // ===================================================================================================================
 Class Function TStackTraceHlp.ProcessFrame(VirtualAddr : DWORD64) : TFrameInfo;
  Const
   MaxSymbolLen = 254;
  Var
   SymOffset  : DWORD64;
   LineOffset : DWORD;
   Symbol     : Record Case byte Of 0 : (s : DbgHelp.SYMBOL_INFO);
   1          : (b : Array [0 .. sizeof(SYMBOL_INFO) - sizeof(char) + MaxSymbolLen * sizeof(char)] Of byte);
 End;
HaveSymbol :
 boolean;
Line :
 IMAGEHLP_LINE64;
 Begin
  MyAssert(FProcess <> 0);

  Finalize(Result);
  ZeroMem(Result, sizeof(Result));

  ZeroMem(Symbol, sizeof(Symbol));
  Symbol.s.SizeOfStruct := sizeof(Symbol.s);
  Symbol.s.MaxNameLen   := MaxSymbolLen; // max name length excluding the null char

  // DbgHelp functions are not thread-safe:
  FLock.AcquireExclusive;
  Try

   HaveSymbol := DbgHelp.SymFromAddr(FProcess, VirtualAddr, SymOffset, Symbol.s);

   If Not HaveSymbol Or (Symbol.s.ModBase = 0) Then
    Symbol.s.ModBase := DbgHelp.SymGetModuleBase64(FProcess, VirtualAddr);

   If Symbol.s.ModBase <> 0 Then
    Result.ModuleName := System.SysUtils.ExtractFilename(self.GetModuleFilename(HINST(Symbol.s.ModBase))) + ': ';

   If Not HaveSymbol Then
    Begin
     Result.FuncName := '0x' + System.SysUtils.IntToHex(VirtualAddr, 2 * sizeof(pointer));
     exit;
    End;

   SetString(Result.FuncName, Symbol.s.Name, Symbol.s.NameLen);

   ZeroMem(Line, sizeof(Line));
   Line.SizeOfStruct := sizeof(Line);

   If DbgHelp.SymGetLineFromAddr64(FProcess, VirtualAddr, LineOffset, Line) Then
    Begin
     Result.SrcFilename := Line.FileName;
     Result.SrcLineNo   := Line.LineNumber;
    End
   Else If SymOffset <> 0 Then
    Begin
     Result.FuncName := Result.FuncName + ' + 0x' + System.SysUtils.IntToHex(SymOffset, 1)
    End;

  Finally
   FLock.ReleaseExclusive;
  End;
 End;

 // ===================================================================================================================
 // Returns textual representation of <Addrs>.
 // Does not throw exceptions.
 // ===================================================================================================================
 Class Function TStackTraceHlp.InterpretStackTrace(Const Addrs : Array Of TAddr; Count : uint32) : String;
  Var
   i : int32;
  Begin
   Result := '';
   For i  := 0 To int32(Count) - 1 Do
    Begin
     If i <> 0 Then
      Result := Result + #13#10;
     Result  := Result + '  at ' + self.ProcessFrame(Addrs[i]).ToString;
    End;
  End;

 // ===================================================================================================================
 // Initializes <Ctx> for the current thread. It is particularly important to set EIP / RIP to an address within the
 // body(!) of the calling function.
 // ===================================================================================================================
 Class Procedure TStackTraceHlp.DoSetupContext(Var Ctx : CONTEXT);
  asm
   {$Ifdef Win64}

   // RCX = @Ctx

   .NOFRAME
   MOV Ctx.ContextFlags, CONTEXT_CONTROL or CONTEXT_INTEGER
   // for CONTEXT_CONTROL:
   MOV RDX, [RSP]		// top element contains return address
   MOV Ctx.&Rip, RDX
   MOV Ctx.&Rbp, RBP		 // unclear if used as it is not part of the x64 calling convention
   LEA RDX, [RSP + 8]	   // make .RSP consistent to .RBP
   MOV Ctx.&Rsp, RDX     // := RSP + sizeof(return address)
   // CONTEXT_INTEGER seams to cover Rbp and Rsp

   {$Else}

   // EAX = @Ctx

   MOV Ctx.ContextFlags, CONTEXT_CONTROL
   // for CONTEXT_CONTROL:
   MOV EDX, [ESP]		// top element contains return address
   MOV Ctx.&Eip, EDX
   MOV Ctx.&Ebp, EBP
   LEA EDX, [ESP + 4]	   // make .ESP consistent to .EBP
   MOV Ctx.&Esp, EDX     // := ESP + sizeof(return address)

   {$Endif}
 end;

 // ===================================================================================================================
 // For usage by application code, outside of the internal Delphi or Windows exception handling.
 // ===================================================================================================================
 Class Function TStackTraceHlp.GetStackTrace : String;
  Var
   Ctx   : DbgHelp.CONTEXT;
   Addrs : Array [0 .. 255] Of TAddr;
   Count : uint32;
  Begin
   Ctx.SetNull;
   self.DoSetupContext(Ctx);
   Count  := self.DoGetStackTrace(Ctx, 1, Addrs);
   Result := self.InterpretStackTrace(Addrs, Count);
  End;

 Type
  // Provides types and methods to hook into the Delphi and Windows exception mechanisms in order to
  // obtain stack traces of exceptions.
  TExceptionHelp = Record
   Strict Private
   Const
    cDelphiException = $0EEDFADE; // from System.pas

   Type
    self = TExceptionHelp;

    PFrames = ^TFrames;

    TFrames = Record
     Addrs : Array [0 .. 63] Of TAddr;
     Count : uint32;
    End;

    Class Var FHandlerHandle : pointer;

    Class Function OsExceptionHandler(Info : PEXCEPTION_POINTERS) : LONG; Stdcall; Static;

    Class Function GetExceptionStackInfo(P : PExceptionRecord) : pointer; Static;
    Class Procedure CleanupStackInfo(Info : pointer); Static;
    Class Function GetStackInfoString(Info : pointer) : String; Static;

    {$Ifndef Win64}
    Class Var FSavedErrorProc : Procedure(ErrorCode : byte; ErrorAddr : pointer);

    Class Procedure ErrorProc(ErrorCode : byte; ErrorAddr : pointer); Static;
    {$Endif}
   Private Type
    TOsExceptCtx = Record
     IP : TAddr;
     SP : TAddr;
     BP : TAddr;
     {$Ifndef Win64}
     Stack : TFrames;
     ValidCtx : boolean;
     {$Endif}
    End;

   Public
    Class Procedure Init; Static;
    Class Procedure Fini; Static;
  End;

 Threadvar gOsExceptCtx : TExceptionHelp.TOsExceptCtx;

 { TExceptionHelp }

 // ===================================================================================================================
 // Setup for getting stack traces on Delphi exceptions.
 // ===================================================================================================================
 Class Procedure TExceptionHelp.Init;
  Begin
   System.SysUtils.Exception.GetExceptionStackInfoProc := self.GetExceptionStackInfo;
   System.SysUtils.Exception.CleanupStackInfoProc      := self.CleanupStackInfo;
   System.SysUtils.Exception.GetStackInfoStringProc    := self.GetStackInfoString;

   // hook into Windows exception handling:
   FHandlerHandle := DbgHelp.AddVectoredExceptionHandler(1, OsExceptionHandler);
   Assert(FHandlerHandle <> Nil);

   {$Ifndef Win64}
   FSavedErrorProc  := System.ErrorProc;
   System.ErrorProc := TExceptionHelp.ErrorProc;
   {$Endif}
  End;

 // ===================================================================================================================
 // Teardown for getting stack traces on Delphi exceptions.
 // ===================================================================================================================
 Class Procedure TExceptionHelp.Fini;
  Begin
   {$Ifndef Win64}
   System.ErrorProc := FSavedErrorProc;
   {$Endif}
   MyAssert(DbgHelp.RemoveVectoredExceptionHandler(FHandlerHandle) <> 0);

   System.SysUtils.Exception.GetExceptionStackInfoProc := Nil;
   // Release should remain possible: System.SysUtils.Exception.CleanupStackInfoProc not cleared
   System.SysUtils.Exception.GetStackInfoStringProc := Nil;
  End;

 {$Ifndef Win64}

 // ===================================================================================================================
 // Workaround for:
 // - Bug in System._IntfCast: It does a JMP to Error() with a non-conforming stack, making Error() unable to retrieve
 // the caller's address from the stack; by accident, it reads a zero value instead.
 // - In later Delphi versions, System.SysUtils.ErrorHandler uses "raise E" without "at address" when called with a address
 // of zero. While this could theoretically compensate for the bug previously mentioned, it makes the stackwalk
 // engine unhappy.
 // => Fix the nil address before it reaches System.SysUtils.ErrorHandler. For the stackwalk engine to pick it up, we need to
 // have a regular stack frame, and use an address from inside this procedure.
 // For Delphi XE2 and up, the address could stay at nil (in D13 it works with nil), but the stackframe is
 // still needed.
 // ===================================================================================================================
 Class Procedure TExceptionHelp.ErrorProc(ErrorCode : byte; ErrorAddr : pointer);
  asm
   // AL = ErrroCode
   // EDX = ErrorAddr
   PUSH EBP
   MOV EBP, ESP				       // establish standard stack frame
   TEST EDX, EDX             // ErrorAddr = nil?
   JNZ @@1
   MOV EDX, offset @@1		// ErrorAddr := address from inside this proc
  @@1:
   CALL [FSavedErrorProc]
   MOV ESP, EBP
   POP EBP
 end;
 {$Endif}

 // ===================================================================================================================
 // Is called for every exception in the process and, in the case of Windows-generated exceptions, provides exact
 // information about the point at which the exception occurred.
 // Is not called again when re-raising an exception.
 // The handler should not call functions that acquire synchronization objects or allocate memory, because this can cause problems.
 // ===================================================================================================================
 Class Function TExceptionHelp.OsExceptionHandler(Info : PEXCEPTION_POINTERS) : LONG;
  Var
   Ctx : ^TOsExceptCtx;
  Begin
   If Info.ExceptionRecord.ExceptionCode <> cDelphiException Then
    Begin
     Ctx    := @gOsExceptCtx;
     Ctx.IP := Info.ContextRecord.IP;
     Ctx.SP := Info.ContextRecord.SP;
     Ctx.BP := Info.ContextRecord.BP;
     {$Ifndef Win64}
     Ctx.ValidCtx := true;
     {$Endif}
    End;

   Result := 0; // EXCEPTION_CONTINUE_SEARCH
  End;


 // ===================================================================================================================
 // Hook for Exception.GetExceptionStackInfoProc: Returns a TStack record as the result, which the Delphi RTL then
 // stores in the exception.
 // Is called by the RTL:
 // - For Delphi's own exceptions ("raise" statement): Before calling the Windows exception mechanism and thus
 // before OsExceptionHandler.
 // - For non-Delphi exception (i.e. Div-by-zero): As a reaction to the Windows exception and thus after OsExceptionHandler.
 // - For reraise ("raise" statement without argument): Without OsExceptionHandler being called.
 //
 // Win32: Reraise of Delphi exceptions:
 // The RTL keeps the exception objec created by the original "raise".
 //
 // Win32: Reraise of non-Delphi exceptions:
 // Idiotically, the RTL releases the original execption object and therefore the attached StackInfo (System.pas,
 // _RaiseAgain, line 12524), instead of keeping and resuing it!
 // The CPU stack and gOsExceptCtx are outdated and therefore unusable at this point => We only can reuse the last
 // stackinfo generated for the address, which is not 100% reliable...
 //
 // Win64: Reraise: The original exception *code* is lost due to _RaiseAgain calling _RaiseAtExcept, which handles
 // reraised non-delphi exceptions the same as Delphi exception. But the original exception object is kept and reused,
 // so it's stackinfo is still available.
 // ===================================================================================================================
 {$Ifdef Win64}

 Class Function TExceptionHelp.GetExceptionStackInfo(P : PExceptionRecord) : pointer;
  Var
   OsCtx      : ^TOsExceptCtx;
   Ctx        : DbgHelp.CONTEXT;
   SkipFrames : uint32;
  Begin
   If P.ExceptionCode = cDelphiException Then
    Begin
     // p.ExceptObject is only valid for Delphi exceptions (can be non-nil for EAccessViolation without pointing to an Delphi object)

     If TObject(P.ExceptObject) Is EAbort Then
      exit(Nil);

     // Delphi 10.1 + Win64: Prevent memory leak, as also preserve the StackInfo from the original exception, by not
     // overwriting an already existing StackInfo object in the reraised exception object.
     If (TObject(P.ExceptObject) Is Exception) And (Exception(P.ExceptObject).StackInfo <> Nil) Then
      exit(Exception(P.ExceptObject).StackInfo);

     // initial handling of a Delphi exception: System._RaiseExcept: Creates the Exception object before
     // Winapi.Windows.RaiseException is called => must construct a suitable Context:
     Ctx.SetNull;
     TStackTraceHlp.DoSetupContext(Ctx);
     SkipFrames := 5;
    End
   Else
    Begin
     // initial handling of a non-Delphi exception: OsCtx contains the data captured immediately before:
     Ctx.SetNull;
     Ctx.ContextFlags := CONTEXT_CONTROL Or CONTEXT_INTEGER;
     OsCtx            := @gOsExceptCtx;
     Ctx.IP           := OsCtx.IP;
     Ctx.SP           := OsCtx.SP;
     Ctx.BP           := OsCtx.BP;
     SkipFrames       := 0;
    End;

   System.GetMem(Result, sizeof(TFrames));
   PFrames(Result).Count := TStackTraceHlp.DoGetStackTrace(Ctx, SkipFrames, PFrames(Result).Addrs);
  End;

 {$Else}

 Class Function TExceptionHelp.GetExceptionStackInfo(P : PExceptionRecord) : pointer;
  Var
   OsCtx : ^TOsExceptCtx;
   Ctx   : DbgHelp.CONTEXT;
  Begin
   OsCtx := @gOsExceptCtx;

   If P.ExceptionCode = cDelphiException Then
    Begin
     // p.ExceptObject is only valid for Delphi exceptions (can be non-nil for EAccessViolation without pointing to an Delphi object)

     If TObject(P.ExceptObject) Is EAbort Then
      exit(Nil);

     // case "raise System.AcquireExceptionObject": Prevent memory leak, as also preserve the StackInfo from the original
     // exception, by not overwriting an already existing StackInfo object in the reraised exception object.
     If (TObject(P.ExceptObject) Is Exception) And (Exception(P.ExceptObject).StackInfo <> Nil) Then
      exit(Exception(P.ExceptObject).StackInfo);

     // initial handling of a Delphi exception: System._RaiseExcept: Creates the Exception object before
     // Winapi.Windows.RaiseException is called => must construct a suitable Context:

     // System.pas, procedure _RaiseExcept, puts the registers of the exception point as 7 arguments into ExceptionInformation:
     Assert(P.NumberParameters = 7);
     Ctx.SetNull;
     Ctx.ContextFlags := CONTEXT_CONTROL;
     Ctx.IP           := TAddr(P.ExceptionAddress);
     Ctx.SP           := TAddr(P.ExceptionInformation[6]);
     Ctx.BP           := TAddr(P.ExceptionInformation[5]);
    End
   Else If OsCtx.ValidCtx Then
    Begin
     // initial handling of a non-Delphi exception: OsCtx contains the data captured immediately before:
     Ctx.SetNull;
     Ctx.ContextFlags := CONTEXT_CONTROL;
     Ctx.IP           := OsCtx.IP;
     Ctx.SP           := OsCtx.SP;
     Ctx.BP           := OsCtx.BP;
    End
   Else If OsCtx.IP = TAddr(P.ExceptionAddress) Then
    Begin
     // reraise of a non-Delphi exception: OsCtx does not match the current CPU stack, which no longer covers the original
     // point of exception => can only reuse the last stackinfo (hopefully still the right one):
     System.GetMem(Result, sizeof(TFrames));
     PFrames(Result)^ := OsCtx.Stack;
     exit;
    End
   Else
    exit(Nil);

   System.GetMem(Result, sizeof(TFrames));
   PFrames(Result).Count := TStackTraceHlp.DoGetStackTrace(Ctx, 0, PFrames(Result).Addrs);

   If P.ExceptionCode <> cDelphiException Then
    Begin
     // non-Delphi exception: Context is consumed now, save the generated stackinfo for possible reraise:
     OsCtx.ValidCtx := false;
     OsCtx.Stack    := PFrames(Result)^;
    End;
  End;
 {$Endif}

 // ===================================================================================================================
 // Hook for Exception.CleanupStackInfoProc: Releases  <Info>.
 // ===================================================================================================================
 Class Procedure TExceptionHelp.CleanupStackInfo(Info : pointer);
  Begin
   // Bug since Delphi 2009: System.SysUtils.pas, line 17891, DoneExceptions:
   // InvalidPointer.*Free* should be *FreeInstance* (as a few lines before with OutOfMemory.FreeInstance)
   // => CleanupStackInfo is also called for the shared "InvalidPointer" object which has no StackInfo
   System.FreeMem(Info);
  End;

 // ===================================================================================================================
 // Hook for Exception.GetStackInfoStringProc: Generates text from <Info>.
 // ===================================================================================================================
 Class Function TExceptionHelp.GetStackInfoString(Info : pointer) : String;
  Begin
   If Info = Nil Then
    Result := ''
   Else
    Result := TStackTraceHlp.InterpretStackTrace(PFrames(Info).Addrs, PFrames(Info).Count);
  End;

Initialization

 TStackTraceHlp.Init;
 TExceptionHelp.Init;

Finalization

 TExceptionHelp.Fini;
 TStackTraceHlp.Fini;

End.
