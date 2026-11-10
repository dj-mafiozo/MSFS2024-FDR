Program VerifyDiagnostics;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 Winapi.Windows, System.SysUtils, System.IOUtils, AppLogU;

Type
 TFilter = Function(Info : Pointer) : LongInt;

 Stdcall;

Var
 p : String;
 f : TFilter;
 b : TBytes;

Type

 [TestFixture]
 TVerifyDiagnosticsTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyDiagnosticsTests.Regression;
 Begin

  p := TPath.Combine(ExtractFilePath(ParamStr(0)), 'diagnostics-test.log');

  StartLog(p, 'INFO');
  AppLogU.Log(0, 'diagnostic probe');

  If Pos('diagnostic probe', TFile.ReadAllText(p)) = 0 Then
   Raise Exception.Create('Missing log');

  f := TFilter(SetUnhandledExceptionFilter(Nil));

  If Not Assigned(f) Then
   Raise Exception.Create('Missing crash filter');

  // Exercise the dump writer without crashing the test runner.

  SetUnhandledExceptionFilter(Nil);

  f(Nil);

  b := TFile.ReadAllBytes(ChangeFileExt(p, '.dmp'));

  If (Length(b) < 32) Or (b[0] <> Ord('M')) Or (b[1] <> Ord('D')) Then
   Raise Exception.Create('Invalid minidump');

  System.Writeln('PASS: persistent error log and readable Windows minidump header.');

 End;

Begin
 RunNativeTests(TVerifyDiagnosticsTests);

End.
