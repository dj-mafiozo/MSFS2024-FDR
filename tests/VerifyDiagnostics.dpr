program VerifyDiagnostics;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.IOUtils,AppLogU;
type TFilter=function(Info:Pointer):Longint;stdcall;
var P:string;F:TFilter;B:TBytes;
begin
 P:=TPath.Combine(ExtractFilePath(ParamStr(0)),'diagnostics-test.log');
 StartLog(P,'INFO');Log(0,'diagnostic probe');
 if Pos('diagnostic probe',TFile.ReadAllText(P))=0 then raise Exception.Create('Missing log');
 F:=TFilter(SetUnhandledExceptionFilter(nil));
 if not Assigned(F) then raise Exception.Create('Missing crash filter');
 // Exercise the dump writer without crashing the test runner.
 SetUnhandledExceptionFilter(nil);
 F(nil);
 B:=TFile.ReadAllBytes(ChangeFileExt(P,'.dmp'));
 if (Length(B)<32) or (B[0]<>Ord('M')) or (B[1]<>Ord('D')) then raise Exception.Create('Invalid minidump');
 Writeln('PASS: persistent error log and readable Windows minidump header.');
end.
