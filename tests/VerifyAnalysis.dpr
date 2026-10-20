program VerifyAnalysis;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.SysUtils,System.Classes,System.IOUtils,FlightAnalysisU;
procedure Require(B:Boolean;const S:string);begin if not B then raise Exception.Create(S);end;
procedure Mock;
var B:array[0..1023]of Byte;N:DWORD;Stream:TMemoryStream;Bytes:TBytes;Prompt,Output:string;I:Integer;
begin
 Stream:=TMemoryStream.Create;
 try
  while ReadFile(GetStdHandle(STD_INPUT_HANDLE),B,SizeOf(B),N,nil) and (N>0) do Stream.WriteBuffer(B,N);
  SetLength(Bytes,Stream.Size);Stream.Position:=0;if Length(Bytes)>0 then Stream.ReadBuffer(Bytes[0],Length(Bytes));Prompt:=TEncoding.UTF8.GetString(Bytes);
 finally Stream.Free;end;
 if Pos('TIMEOUT',Prompt)>0 then Sleep(10000);
 if Pos('FAIL',Prompt)>0 then begin Writeln('mock: brak logowania');Halt(7);end;
 Require(Pos('po polsku',Prompt)>0,'Polish query missing');
 Require(Pos(#$017C#$00F3#$0142#$0107,Prompt)>0,'UTF-8 stdin corrupted');
 Output:='';for I:=1 to ParamCount-1 do if ParamStr(I)='-o' then Output:=ParamStr(I+1);
 Require(Output<>'','Output path missing');
 Require(Pos('exec',CmdLine)>0,'exec missing');
 TFile.WriteAllBytes(Output,TEncoding.UTF8.GetBytes('Analiza l'+#$0105+'dowania: '+#$017C#$00F3#$0142#$0107));
end;
var A:TAnalysisThread;Prompt:string;Started:UInt64;
begin
 if ParamStr(1)='exec' then begin Mock;Exit;end;
 Prompt:=BuildAnalysisPrompt('{"test":"'+#$017C#$00F3#$0142#$0107+'"}','l'#261'dowanie');
 A:=TAnalysisThread.Create('codex','','model with spaces',Prompt,ParamStr(0),10);
 try A.Start;A.WaitFor;Require(A.Error='',A.Error);Require(A.Report='Analiza l'+#$0105+'dowania: '+#$017C#$00F3#$0142#$0107,'UTF-8 result corrupted');finally A.Free;end;
 A:=TAnalysisThread.Create('codex','','',Prompt+' FAIL',ParamStr(0),10);
 try A.Start;A.WaitFor;Require(Pos('7',A.Error)>0,'Nonzero exit not reported');Require(Pos('brak logowania',A.Error)>0,'CLI diagnostic missing');finally A.Free;end;
 Started:=GetTickCount64;A:=TAnalysisThread.Create('codex','','',Prompt+' TIMEOUT',ParamStr(0),1);
 try A.Start;A.WaitFor;Require(Pos('limit czasu',A.Error)>0,'Timeout missing');Require(GetTickCount64-Started<5000,'Timeout did not terminate child');finally A.Free;end;
 A:=TAnalysisThread.Create('codex','','',Prompt+' TIMEOUT',ParamStr(0),10);
 try A.Start;Sleep(200);A.Terminate;A.WaitFor;Require(Pos('anulowana',A.Error)>0,'Cancellation missing');finally A.Free;end;
 Writeln('PASS: hidden Codex process, UTF-8 Polish query/result, argument quoting, CLI failure, timeout and cancellation. No cloud requests.');
end.
