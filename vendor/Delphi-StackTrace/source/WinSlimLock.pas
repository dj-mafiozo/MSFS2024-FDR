Unit WinSlimLock;

{
  Unit only contains definitions that could also be used by MemTest.pas.
  - TSlimRWLock: Structure that wraps Windows' built-in Slim Reader/Writer Lock.
}

{$include LibOptions.inc}
{$ifdef MEMTEST_DEBUG}
{$DebugInfo on}
{$else}
{$DebugInfo off}
{$endif}

Interface

 Uses
  Winapi.Windows;

 Type
  TConditionVariable = Winapi.Windows.CONDITION_VARIABLE;

  // Wraps Windows' built-in Slim Reader/Writer Lock (needs Windows Vista):
  // An initialization is not necessary if the corresponding variable is zero-initialized.
  TSlimRWLock = Record
   Strict Private

    { WinNt.h + WinBase.h }
   Type
    SRWLOCK = Type pointer;

   Const
    SRWLOCK_INIT = SRWLOCK(Nil);

    Class Procedure _AcquireSRWLockExclusive(Var SRWLOCK : SRWLOCK); Stdcall; Static;
    Class Procedure _AcquireSRWLockShared(Var SRWLOCK : SRWLOCK); Stdcall; Static;
    Class Procedure _ReleaseSRWLockExclusive(Var SRWLOCK : SRWLOCK); Stdcall; Static;
    Class Procedure _ReleaseSRWLockShared(Var SRWLOCK : SRWLOCK); Stdcall; Static;
    Class Function _SleepConditionVariableSRW(Var ConditionVariable : TConditionVariable; Var SRWLOCK : SRWLOCK; dwMilliseconds : DWORD; Flags : ULONG) : BOOL; Stdcall; Static;
    Class Function _TryAcquireSRWLockExclusive(Var SRWLOCK : SRWLOCK) : BOOL; Stdcall; Static;
    Class Function _TryAcquireSRWLockShared(Var SRWLOCK : SRWLOCK) : BOOL; Stdcall; Static;

   Var
    FLock : SRWLOCK;
   Public
    Procedure Init; Inline; // not needed if zero-initialized

    Procedure AcquireExclusive; Inline;
    Function TryAcquireExclusive : boolean; Inline;
    Procedure ReleaseExclusive; Inline;

    Procedure AcquireShared; Inline;
    Function TryAcquireShared : boolean; Inline;
    Procedure ReleaseShared; Inline;

    Function SleepConditionVariable(Var ConditionVariable : TConditionVariable; Milliseconds : DWORD; Flags : ULONG) : boolean; Inline;

    Class Procedure WakeAllConditionVariable(Var ConditionVariable : TConditionVariable); Stdcall; Static;
    Class Procedure WakeConditionVariable(Var ConditionVariable : TConditionVariable); Stdcall; Static;
  End;

  { ############################################################################ }
Implementation

 { ############################################################################ }

 { TSlimRWLock }

 Class Procedure TSlimRWLock._AcquireSRWLockExclusive(Var SRWLOCK : SRWLOCK); Stdcall; External Winapi.Windows.kernel32 Name 'AcquireSRWLockExclusive';
 Class Procedure TSlimRWLock._AcquireSRWLockShared(Var SRWLOCK : SRWLOCK); Stdcall; External Winapi.Windows.kernel32 Name 'AcquireSRWLockShared';
 Class Procedure TSlimRWLock._ReleaseSRWLockExclusive(Var SRWLOCK : SRWLOCK); Stdcall; External Winapi.Windows.kernel32 Name 'ReleaseSRWLockExclusive';
 Class Procedure TSlimRWLock._ReleaseSRWLockShared(Var SRWLOCK : SRWLOCK); Stdcall; External Winapi.Windows.kernel32 Name 'ReleaseSRWLockShared';
 Class Function TSlimRWLock._SleepConditionVariableSRW(Var ConditionVariable : TConditionVariable; Var SRWLOCK : SRWLOCK; dwMilliseconds : DWORD; Flags : ULONG) : BOOL; Stdcall; External Winapi.Windows.kernel32 Name 'SleepConditionVariableSRW';
 Class Function TSlimRWLock._TryAcquireSRWLockExclusive(Var SRWLOCK : SRWLOCK) : BOOL; Stdcall; External Winapi.Windows.kernel32 Name 'TryAcquireSRWLockExclusive';
 Class Function TSlimRWLock._TryAcquireSRWLockShared(Var SRWLOCK : SRWLOCK) : BOOL; Stdcall; External Winapi.Windows.kernel32 Name 'TryAcquireSRWLockShared';

 // D2009: this functions are also in Windows.pas:
 Class Procedure TSlimRWLock.WakeAllConditionVariable(Var ConditionVariable : TConditionVariable); Stdcall; External Winapi.Windows.kernel32 Name 'WakeAllConditionVariable';
 Class Procedure TSlimRWLock.WakeConditionVariable(Var ConditionVariable : TConditionVariable); Stdcall; External Winapi.Windows.kernel32 Name 'WakeConditionVariable';

 // =============================================================================
 // =============================================================================
 Procedure TSlimRWLock.Init;
  Begin
   FLock := SRWLOCK_INIT;
  End;

 // =============================================================================
 // Acquires the lock in exclusive mode:
 // =============================================================================
 Procedure TSlimRWLock.AcquireExclusive;
  Begin
   _AcquireSRWLockExclusive(FLock);
  End;

 // =============================================================================
 // Acquires the lock in shared mode:
 // =============================================================================
 Procedure TSlimRWLock.AcquireShared;
  Begin
   _AcquireSRWLockShared(FLock);
  End;

 // =============================================================================
 // Attempts to acquire the lock in exclusive mode. If the lock could be acquired,
 // it returns true.
 // =============================================================================
 Function TSlimRWLock.TryAcquireExclusive : boolean;
  Begin
   Result := _TryAcquireSRWLockExclusive(FLock);
  End;

 // =============================================================================
 // Attempts to acquire the lock in shared mode. If the lock could be acquired,
 // it returns true.
 // =============================================================================
 Function TSlimRWLock.TryAcquireShared : boolean;
  Begin
   Result := _TryAcquireSRWLockShared(FLock);
  End;

 // =============================================================================
 // Releases an lock that was opened in exclusive mode.
 // =============================================================================
 Procedure TSlimRWLock.ReleaseExclusive;
  Begin
   _ReleaseSRWLockExclusive(FLock);
  End;

 // =============================================================================
 // Releases an SRW lock that was opened in shared mode.
 // =============================================================================
 Procedure TSlimRWLock.ReleaseShared;
  Begin
   _ReleaseSRWLockShared(FLock);
  End;

 // =============================================================================
 // Sleeps on the condition variable and releases the specified lock as an atomic operation.
 // =============================================================================
 Function TSlimRWLock.SleepConditionVariable(Var ConditionVariable : TConditionVariable; Milliseconds : DWORD; Flags : ULONG) : boolean;
  Begin
   Result := _SleepConditionVariableSRW(ConditionVariable, FLock, Milliseconds, Flags);
  End;

End.
