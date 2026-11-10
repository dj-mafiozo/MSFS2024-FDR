//
// Include file for stable compiler options
//
// Supposed Build Configurations in each project with the respective conditional defines:
// - Debug: DEBUG;MEMTEST_ACTIVE
//   -   LibDebug: LIB_DEBUG
// - Release: RELEASE;NOASSERT
//

{$Ifdef LIB_DEBUG}
  {$DebugInfo on}
  {$OverflowChecks on}
  {$RangeChecks on}
{$Else}
  {$DebugInfo off}
  {$OverflowChecks off}
  {$RangeChecks off}
{$Endif}

{$Ifdef NOASSERT}
  {$Assertions off}
{$Else}
  {$Assertions on}
{$Endif}

{$Align on}
{$BoolEval off}
{$ExtendedSyntax on}
{$Hints on}
{$IoChecks on}
{$LocalSymbols on}
{$LongStrings on}
{$MinEnumSize 1}
{$OpenStrings on}
{$Optimization on}
{$ReferenceInfo on}
{$SafeDivide off}
{$StackFrames on}
{$TypedAddress on}
{$TypeInfo off}
{$VarStringChecks on}
{$Warnings on}
{$WriteableConst off}

{$Warn SYMBOL_PLATFORM off}
{$Warn UNIT_PLATFORM off}

{$Include AdditionalSymbols.inc}

{$Ifndef UNICODE} {$Message error 'Unicode required'} {$Endif}
{$Ifndef D2009} {$Message error 'D2009 required'} {$Endif}

{$Inline on}
{$MethodInfo off}
{$PointerMath on}
{$ScopedEnums off}
{$StringChecks off}

{$Ifdef D2011}
  {$StrongLinkTypes off}	// Because this directive defeats the smart linker to a large degree, it can cause inflation of the executable size.
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}	// Extended RTTI => off => smaller EXE
  {$WeakLinkRTTI ON}		// enables more Smart Linking => smaller EXE
{$Endif}