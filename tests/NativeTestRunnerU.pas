Unit NativeTestRunnerU;
Interface
Procedure RunNativeTests(Fixture: TClass);
Implementation
Uses System.SysUtils, DUnitX.TestFramework, DUnitX.Loggers.Console;
Procedure RunNativeTests(Fixture: TClass);
Var Runner: ITestRunner; Results: IRunResults;
Begin
 TDUnitX.RegisterTestFixture(Fixture);
 Runner := TDUnitX.CreateRunner;
 Runner.UseRTTI := True;
 Runner.FailsOnNoAsserts := False;
 Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
 Results := Runner.Execute;
 If not Results.AllPassed Then ExitCode := 1;
End;
End.
