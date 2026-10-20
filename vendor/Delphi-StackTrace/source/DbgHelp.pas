Unit DbgHelp;

{
  Selection of Windows API types and functions that are needed for stacktraces.
  DbgHelp.h
  WinNT.h
  https://docs.microsoft.com/en-us/windows/win32/debug/updated-platform-support
}

{$include LibOptions.inc}
{$MinEnumSize 4}

Interface

 Uses
  Winapi.Windows;

 {$If not defined(Win32) and not defined(Win64)}
 {$Message error 'wrong!'}
 {$Ifend}

 Type
  {$If declared(DWORD64)}
  DWORD64 = Winapi.Windows.DWORD64;
  {$Else}
  DWORD64 = uint64;
  {$Ifend}
  {$If declared(ULONG64)}
  ULONG64 = Winapi.Windows.ULONG64;
  {$Else}
  ULONG64 = uint64;
  {$Ifend}
  {$If declared(LONG)}
  LONG = Winapi.Windows.LONG;
  {$Else}
  LONG = Longint;
  {$Ifend}

 Const
  IMAGE_FILE_MACHINE_I386 = Winapi.Windows.IMAGE_FILE_MACHINE_I386;
  {$If declared(IMAGE_FILE_MACHINE_AMD64)}
  IMAGE_FILE_MACHINE_AMD64 = Winapi.Windows.IMAGE_FILE_MACHINE_AMD64;
  {$Ifend}
  {$If declared(IMAGE_FILE_MACHINE_ARM)}
  IMAGE_FILE_MACHINE_ARM = Winapi.Windows.IMAGE_FILE_MACHINE_ARM;
  {$Ifend}

  // WinNT.h:
 Const
  MAXIMUM_SUPPORTED_EXTENSION = 512;

  {$Ifdef Win64}
  CONTEXT_AMD64 = $100000;

  CONTEXT_CONTROL         = (CONTEXT_AMD64 Or $01);
  CONTEXT_INTEGER         = (CONTEXT_AMD64 Or $02);
  CONTEXT_SEGMENTS        = (CONTEXT_AMD64 Or $04);
  CONTEXT_FLOATING_POINT  = (CONTEXT_AMD64 Or $08);
  CONTEXT_DEBUG_REGISTERS = (CONTEXT_AMD64 Or $10);

  CONTEXT_FULL = (CONTEXT_CONTROL Or CONTEXT_INTEGER Or CONTEXT_FLOATING_POINT);

  CONTEXT_ALL = (CONTEXT_CONTROL Or CONTEXT_INTEGER Or CONTEXT_SEGMENTS Or CONTEXT_FLOATING_POINT Or CONTEXT_DEBUG_REGISTERS);

  {$Else}
  CONTEXT_i386 = $00010000; // this assumes that i386 and

  CONTEXT_CONTROL            = (CONTEXT_i386 Or $00000001); // SS:SP, CS:IP, FLAGS, BP
  CONTEXT_INTEGER            = (CONTEXT_i386 Or $00000002); // AX, BX, CX, DX, SI, DI
  CONTEXT_SEGMENTS           = (CONTEXT_i386 Or $00000004); // DS, ES, FS, GS
  CONTEXT_FLOATING_POINT     = (CONTEXT_i386 Or $00000008); // 387 state
  CONTEXT_DEBUG_REGISTERS    = (CONTEXT_i386 Or $00000010); // DB 0-3,6,7
  CONTEXT_EXTENDED_REGISTERS = (CONTEXT_i386 Or $00000020); // cpu specific extensions

  CONTEXT_FULL = (CONTEXT_CONTROL Or CONTEXT_INTEGER Or CONTEXT_SEGMENTS);

  CONTEXT_ALL = (CONTEXT_CONTROL Or CONTEXT_INTEGER Or CONTEXT_SEGMENTS Or CONTEXT_FLOATING_POINT Or CONTEXT_DEBUG_REGISTERS Or CONTEXT_EXTENDED_REGISTERS);
  {$Endif}

  // WinNT.h:
 Type
  // *** DECLSPEC_ALIGN(16)
  M128A = Record
   Low : ULONGLONG;
   High : LONGLONG;
  End;
  {$If sizeof(M128A) <> 16} {$Message error 'wrong size'} {$Ifend}

  // *** DECLSPEC_ALIGN(16)
  XMM_SAVE_AREA32 = Record
   Case byte Of
    0 :
     (ControlWord : WORD;
      StatusWord : WORD;
      TagWord : byte;
      Reserved1 : byte;
      ErrorOpcode : WORD;
      ErrorOffset : DWORD;
      ErrorSelector : WORD;
      Reserved2 : WORD;
      DataOffset : DWORD;
      DataSelector : WORD;
      Reserved3 : WORD;
      MxCsr : DWORD;
      MxCsr_Mask : DWORD;
      FloatRegisters : Array [0 .. 7] Of M128A;

      XmmRegisters : Array [0 .. 15] Of M128A;
      Reserved4 : Array [0 .. 95] Of byte;
     );
    1 :
     (Header : Array [0 .. 1] Of M128A;
      Legacy : Array [0 .. 7] Of M128A;
      Xmm0 : M128A;
      Xmm1 : M128A;
      Xmm2 : M128A;
      Xmm3 : M128A;
      Xmm4 : M128A;
      Xmm5 : M128A;
      Xmm6 : M128A;
      Xmm7 : M128A;
      Xmm8 : M128A;
      Xmm9 : M128A;
      Xmm10 : M128A;
      Xmm11 : M128A;
      Xmm12 : M128A;
      Xmm13 : M128A;
      Xmm14 : M128A;
      Xmm15 : M128A;
     );
  End;
  {$If sizeof(XMM_SAVE_AREA32) <> 512} {$Message error 'wrong size'} {$Ifend}

  // *** DECLSPEC_ALIGN(16)
  CONTEXT_x64 = Record

   //
   // Register parameter home addresses.
   //
   // N.B. These fields are for convience - they could be used to extend the
   // context record in the future.
   //

   P1Home : DWORD64;
   P2Home : DWORD64;
   P3Home : DWORD64;
   P4Home : DWORD64;
   P5Home : DWORD64;
   P6Home : DWORD64;

   //
   // Control flags.
   //

   ContextFlags : DWORD;
   MxCsr : DWORD;

   //
   // Segment Registers and processor flags.
   //

   SegCs : WORD;
   SegDs : WORD;
   SegEs : WORD;
   SegFs : WORD;
   SegGs : WORD;
   SegSs : WORD;
   EFlags : DWORD;

   //
   // Debug registers
   //

   Dr0 : DWORD64;
   Dr1 : DWORD64;
   Dr2 : DWORD64;
   Dr3 : DWORD64;
   Dr6 : DWORD64;
   Dr7 : DWORD64;

   //
   // Integer registers.
   //

   Rax : DWORD64;
   Rcx : DWORD64;
   Rdx : DWORD64;
   Rbx : DWORD64;
   Rsp : DWORD64;
   Rbp : DWORD64;
   Rsi : DWORD64;
   Rdi : DWORD64;
   R8 : DWORD64;
   R9 : DWORD64;
   R10 : DWORD64;
   R11 : DWORD64;
   R12 : DWORD64;
   R13 : DWORD64;
   R14 : DWORD64;
   R15 : DWORD64;

   //
   // Program counter.
   //

   Rip : DWORD64;

   //
   // Floating point state.
   //

   FltSave : XMM_SAVE_AREA32;

   //
   // Vector registers.
   //

   VectorRegister : Array [0 .. 25] Of M128A;
   VectorControl : DWORD64;

   //
   // Special debug control registers.
   //

   DebugControl : DWORD64;
   LastBranchToRip : DWORD64;
   LastBranchFromRip : DWORD64;
   LastExceptionToRip : DWORD64;
   LastExceptionFromRip : DWORD64;
  End;
  {$If sizeof(CONTEXT_x64) <> 1232} {$Message error 'wrong size'} {$Ifend}

  CONTEXT_x32 = Record

   //
   // The flags values within this flag control the contents of
   // a CONTEXT record.
   //
   // If the context record is used as an input parameter, then
   // for each portion of the context record controlled by a flag
   // whose value is set, it is assumed that that portion of the
   // context record contains valid context. If the context record
   // is being used to modify a threads context, then only that
   // portion of the threads context will be modified.
   //
   // If the context record is used as an IN OUT parameter to capture
   // the context of a thread, then only those portions of the thread's
   // context corresponding to set flags will be returned.
   //
   // The context record is never used as an OUT only parameter.
   //

   ContextFlags : DWORD;

   //
   // This section is specified/returned if CONTEXT_DEBUG_REGISTERS is
   // set in ContextFlags.  Note that CONTEXT_DEBUG_REGISTERS is NOT
   // included in CONTEXT_FULL.
   //

   Dr0 : DWORD;
   Dr1 : DWORD;
   Dr2 : DWORD;
   Dr3 : DWORD;
   Dr6 : DWORD;
   Dr7 : DWORD;

   //
   // This section is specified/returned if the
   // ContextFlags word contians the flag CONTEXT_FLOATING_POINT.
   //

   FloatSave : Winapi.Windows.FLOATING_SAVE_AREA;

   //
   // This section is specified/returned if the
   // ContextFlags word contians the flag CONTEXT_SEGMENTS.
   //

   SegGs : DWORD;
   SegFs : DWORD;
   SegEs : DWORD;
   SegDs : DWORD;

   //
   // This section is specified/returned if the
   // ContextFlags word contians the flag CONTEXT_INTEGER.
   //

   Edi : DWORD;
   Esi : DWORD;
   Ebx : DWORD;
   Edx : DWORD;
   Ecx : DWORD;
   Eax : DWORD;

   //
   // This section is specified/returned if the
   // ContextFlags word contians the flag CONTEXT_CONTROL.
   //

   Ebp : DWORD;
   Eip : DWORD;
   SegCs : DWORD;  // MUST BE SANITIZED
   EFlags : DWORD; // MUST BE SANITIZED
   Esp : DWORD;
   SegSs : DWORD;

   //
   // This section is specified/returned if the ContextFlags word
   // contains the flag CONTEXT_EXTENDED_REGISTERS.
   // The format and contexts are processor specific
   //

   ExtendedRegisters : Array [0 .. MAXIMUM_SUPPORTED_EXTENSION - 1] Of byte;
  End;
  {$If sizeof(CONTEXT_x32) <> 716} {$Message error 'wrong size'} {$Ifend}

  CONTEXT = {$Ifdef Win64}CONTEXT_x64{$Else}CONTEXT_x32{$Endif};

  // DbgHelp.h:
 Const
  DbgHelpDLL = 'DbgHelp.dll';

  //
  // options that are set/returned by SymSetOptions() & SymGetOptions()
  // these are used as a mask
  //
  SYMOPT_CASE_INSENSITIVE          = $00000001;
  SYMOPT_UNDNAME                   = $00000002;
  SYMOPT_DEFERRED_LOADS            = $00000004;
  SYMOPT_NO_CPP                    = $00000008;
  SYMOPT_LOAD_LINES                = $00000010;
  SYMOPT_OMAP_FIND_NEAREST         = $00000020;
  SYMOPT_LOAD_ANYTHING             = $00000040;
  SYMOPT_IGNORE_CVREC              = $00000080;
  SYMOPT_NO_UNQUALIFIED_LOADS      = $00000100;
  SYMOPT_FAIL_CRITICAL_ERRORS      = $00000200;
  SYMOPT_EXACT_SYMBOLS             = $00000400;
  SYMOPT_ALLOW_ABSOLUTE_SYMBOLS    = $00000800;
  SYMOPT_IGNORE_NT_SYMPATH         = $00001000;
  SYMOPT_INCLUDE_32BIT_MODULES     = $00002000;
  SYMOPT_PUBLICS_ONLY              = $00004000;
  SYMOPT_NO_PUBLICS                = $00008000;
  SYMOPT_AUTO_PUBLICS              = $00010000;
  SYMOPT_NO_IMAGE_SEARCH           = $00020000;
  SYMOPT_SECURE                    = $00040000;
  SYMOPT_NO_PROMPTS                = $00080000;
  SYMOPT_OVERWRITE                 = $00100000;
  SYMOPT_IGNORE_IMAGEDIR           = $00200000;
  SYMOPT_FLAT_DIRECTORY            = $00400000;
  SYMOPT_FAVOR_COMPRESSED          = $00800000;
  SYMOPT_ALLOW_ZERO_ADDRESS        = $01000000;
  SYMOPT_DISABLE_SYMSRV_AUTODETECT = $02000000;

  SYMOPT_DEBUG = $80000000;

  // DbgHelp.h:
 Type
  KDHELP64 = Record
   //
   // address of kernel thread object, as provided in the
   // WAIT_STATE_CHANGE packet.
   //
   Thread : DWORD64;

   //
   // offset in thread object to pointer to the current callback frame
   // in kernel stack.
   //
   ThCallbackStack : DWORD;

   //
   // offset in thread object to pointer to the current callback backing
   // store frame in kernel stack.
   //
   ThCallbackBStore : DWORD;

   //
   // offsets to values in frame:
   //
   // address of next callback frame
   NextCallback : DWORD;

   // address of saved frame pointer (if applicable)
   FramePointer : DWORD;

   //
   // Address of the kernel function that calls out to user mode
   //
   KiCallUserMode : DWORD64;

   //
   // Address of the user mode dispatcher function
   //
   KeUserCallbackDispatcher : DWORD64;

   //
   // Lowest kernel mode address
   //
   SystemRangeStart : DWORD64;

   //
   // Address of the user mode exception dispatcher function.
   // Added in API version 10.
   //
   KiUserExceptionDispatcher : DWORD64;

   //
   // Stack bounds, added in API version 11.
   //
   StackBase : DWORD64;
   StackLimit : DWORD64;

   Reserved : Array [0 .. 4] Of DWORD64;
  End;

  ADDRESS_MODE = (AddrMode1616, AddrMode1632, AddrModeReal, AddrModeFlat);

  ADDRESS64 = Record
   Offset : DWORD64;
   Segment : WORD;
   Mode : ADDRESS_MODE;
  End;

  STACKFRAME64 = Record
   AddrPC : ADDRESS64;                 // program counter
   AddrReturn : ADDRESS64;             // return address
   AddrFrame : ADDRESS64;              // frame pointer
   AddrStack : ADDRESS64;              // stack pointer
   AddrBStore : ADDRESS64;             // backing store pointer
   FuncTableEntry : pointer;           // pointer to pdata/fpo or NULL
   Params : Array [0 .. 3] Of DWORD64; // possible arguments to the function
   &Far : BOOL;                        // WOW far call
   &Virtual : BOOL;                    // is this a virtual frame?
   Reserved : Array [0 .. 2] Of DWORD64;
   KdHelp : KDHELP64;
  End;

  SYM_TYPE = (SymNone = 0, SymCoff, SymCv, SymPdb, SymExport, SymDeferred, SymSym, // .sym file
   SymDia, SymVirtual, NumSymTypes);

  IMAGEHLP_MODULE64 = Record
   SizeOfStruct : DWORD;                       // set to sizeof(IMAGEHLP_MODULE64)
   BaseOfImage : DWORD64;                      // base load address of module
   ImageSize : DWORD;                          // virtual size of the loaded module
   TimeDateStamp : DWORD;                      // date/time stamp from pe header
   CheckSum : DWORD;                           // checksum from the pe header
   NumSyms : DWORD;                            // number of symbols in the symbol table
   SymType : SYM_TYPE;                         // type of symbols loaded
   ModuleName : Array [0 .. 31] Of Char;       // module name
   ImageName : Array [0 .. 255] Of Char;       // image name
   LoadedImageName : Array [0 .. 255] Of Char; // symbol file name
   // new elements: 07-Jun-2002
   LoadedPdbName : Array [0 .. 255] Of Char;       // pdb file name
   CVSig : DWORD;                                  // Signature of the CV record in the debug directories
   CVData : Array [0 .. MAX_PATH * 3 - 1] Of Char; // Contents of the CV record
   PdbSig : DWORD;                                 // Signature of PDB
   PdbSig70 : TGUID;                               // Signature of PDB (VC 7 and up)
   PdbAge : DWORD;                                 // DBI age of pdb
   PdbUnmatched : BOOL;                            // loaded an unmatched pdb
   DbgUnmatched : BOOL;                            // loaded an unmatched dbg
   LineNumbers : BOOL;                             // we have line number information
   GlobalSymbols : BOOL;                           // we have internal symbol information
   TypeInfo : BOOL;                                // we have type information
   // new elements: 17-Dec-2003
   SourceIndexed : BOOL; // pdb supports source server
   Publics : BOOL;       // contains public symbols
  End;

  SYMBOL_INFO = Record
   SizeOfStruct : ULONG;
   TypeIndex : ULONG; // Type Index of symbol
   Reserved : Array [0 .. 1] Of ULONG64;
   Index : ULONG;
   Size : ULONG;
   ModBase : ULONG64; // Base Address of module comtaining this symbol
   Flags : ULONG;
   Value : ULONG64;   // Value of symbol, ValuePresent should be 1
   Address : ULONG64; // Address of symbol including base address of module
   &Register : ULONG; // register holding value or pointer to value
   Scope : ULONG;     // scope of the symbol
   Tag : ULONG;       // pdb classification
   NameLen : ULONG;   // Actual length of name
   MaxNameLen : ULONG;
   Name : Array [0 .. 0] Of Char; // Name of symbol
  End;

  IMAGEHLP_LINE64 = Record
   SizeOfStruct : DWORD; // set to sizeof(IMAGEHLP_LINE64)
   Key : pointer;        // internal
   LineNumber : DWORD;   // line number in file
   FileName : PChar;     // full filename
   Address : DWORD64;    // first instruction of line
  End;

  // DbgHelp.h:
 Function SymInitialize(hProcess : THandle; UserSearchPath : PChar; fInvadeProcess : BOOL) : BOOL; Stdcall; External DbgHelpDLL Name {$Ifdef UNICODE}'SymInitializeW'{$Else}'SymInitialize'{$Endif};

 // DbgHelp.h:
 Function SymCleanup(hProcess : THandle) : BOOL; Stdcall; External DbgHelpDLL Name 'SymCleanup';

 // DbgHelp.h:
 Function SymSetOptions(SymOptions : DWORD) : DWORD; Stdcall; External DbgHelpDLL Name 'SymSetOptions';

 // DbgHelp.h:
 Function SymRefreshModuleList(hProcess : THandle) : BOOL; Stdcall; External DbgHelpDLL Name 'SymRefreshModuleList';

 // DbgHelp.h:
 Function SymFunctionTableAccess64(hProcess : THandle; AddrBase : DWORD64) : pointer; Stdcall; External DbgHelpDLL Name 'SymFunctionTableAccess64';

 // DbgHelp.h:
 Function SymGetModuleBase64(hProcess : THandle; dwAddr : DWORD64) : DWORD64; Stdcall; External DbgHelpDLL Name 'SymGetModuleBase64';

 // DbgHelp.h:
 Function SymGetModuleInfo64(hProcess : THandle; dwAddr : DWORD64; Out ModuleInfo : IMAGEHLP_MODULE64) : BOOL; Stdcall; External DbgHelpDLL Name {$Ifdef UNICODE}'SymGetModuleInfoW64'{$Else}'SymGetModuleInfo64'{$Endif};

 // DbgHelp.h:
 Function SymFromAddr(hProcess : THandle; dwAddr : DWORD64; Out Displacement : DWORD64; Var Symbol : SYMBOL_INFO) : BOOL; Stdcall; External DbgHelpDLL Name {$Ifdef UNICODE}'SymFromAddrW'{$Else}'SymFromAddr'{$Endif};
 (*
   // DbgHelp.h:
   function SymGetSymFromAddr64(
   hProcess: THandle;
   dwAddr: DWORD64;
   out pdwDisplacement: DWORD64;
   out Symbol: IMAGEHLP_SYMBOL64
   ): Bool; stdcall; external DbgHelpDLL name 'SymGetSymFromAddr64';
 *)
 // DbgHelp.h:
 Function SymGetLineFromAddr64(hProcess : THandle; dwAddr : DWORD64; Out pdwDisplacement : DWORD; Out Line : IMAGEHLP_LINE64) : BOOL; Stdcall; External DbgHelpDLL Name {$Ifdef UNICODE}'SymGetLineFromAddrW64'{$Else}'SymGetLineFromAddr64'{$Endif};

 Type
  // DbgHelp.h:
  PREAD_PROCESS_MEMORY_ROUTINE = Function(hProcess : THandle; lpBaseAddress : DWORD64; lpBuffer : pointer; nSize : DWORD; Out lpNumberOfBytesRead : DWORD) : BOOL; Stdcall;

  // DbgHelp.h:
  PFUNCTION_TABLE_ACCESS_ROUTINE = Function(hProcess : THandle; AddrBase : DWORD64) : pointer; Stdcall;

  // DbgHelp.h:
  PGET_MODULE_BASE_ROUTINE = Function(hProcess : THandle; Address : DWORD64) : DWORD64; Stdcall;

  // DbgHelp.h:
  PTRANSLATE_ADDRESS_ROUTINE = Function(hProcess : THandle; hThread : THandle; Out lpaddr : ADDRESS64) : DWORD64; Stdcall;

  // DbgHelp.h:
 Function StackWalk64(MachineType : DWORD; hProcess : THandle; hThread : THandle; Var StackFrame : STACKFRAME64; Var ContextRecord : CONTEXT; ReadMemoryRoutine : PREAD_PROCESS_MEMORY_ROUTINE; FunctionTableAccessRoutine : PFUNCTION_TABLE_ACCESS_ROUTINE; GetModuleBaseRoutine : PGET_MODULE_BASE_ROUTINE; TranslateAddress : PTRANSLATE_ADDRESS_ROUTINE) : BOOL; Stdcall; External DbgHelpDLL Name 'StackWalk64';

 (*
   // WinNT.h:
   function RtlCaptureStackBackTrace(
   FramesToSkip: ULONG;
   FramesToCapture: ULONG;
   BackTrace: Pointer;
   BackTraceHash: PULONG
   ): USHORT; stdcall; external Windows.kernel32 name 'RtlCaptureStackBackTrace';
 *)

 Type
  // WinNT.h:
  PEXCEPTION_POINTERS = ^EXCEPTION_POINTERS;

  EXCEPTION_POINTERS = Record
   ExceptionRecord : ^Winapi.Windows.EXCEPTION_RECORD;
   ContextRecord : ^DbgHelp.CONTEXT;
  End;

  // WinNT.h:
  PVECTORED_EXCEPTION_HANDLER = Function(ExceptionInfo : PEXCEPTION_POINTERS) : LONG; Stdcall;

  // WinBase.h:
 Function AddVectoredExceptionHandler(First : ULONG; Handler : PVECTORED_EXCEPTION_HANDLER) : pointer; Stdcall; External Winapi.Windows.Kernel32 Name 'AddVectoredExceptionHandler';

 // WinBase.h:
 Function RemoveVectoredExceptionHandler(Handle : pointer) : ULONG; Stdcall; External Winapi.Windows.Kernel32 Name 'RemoveVectoredExceptionHandler';

 Type
  // winternl.h:
  NTSTATUS = LONG;

 Const
  // ntstatus.h:
  STATUS_SUCCESS = NTSTATUS(0);

  // https://docs.microsoft.com/en-us/windows/win32/devnotes/ldrdllnotification
  LDR_DLL_NOTIFICATION_REASON_LOADED   = 1;
  LDR_DLL_NOTIFICATION_REASON_UNLOADED = 2;

 Type
  // no Windows header file [This function may be changed or removed from Windows without further notice.]
  PLDR_DLL_NOTIFICATION_FUNCTION = Procedure(NotificationReason : ULONG; NotificationData : pointer; // PCLDR_DLL_NOTIFICATION_DATA;
   CONTEXT : pointer); Stdcall;

  // no Windows header file [This function may be changed or removed from Windows without further notice.]
  TLdrRegisterDllNotification = Function(Flags : ULONG; NotificationFunction : PLDR_DLL_NOTIFICATION_FUNCTION; CONTEXT : pointer; Out Cookie : pointer) : NTSTATUS; Stdcall;

  // no Windows header file [This function may be changed or removed from Windows without further notice.]
  TLdrUnregisterDllNotification = Function(Cookie : pointer) : NTSTATUS; Stdcall;

Implementation

End.
