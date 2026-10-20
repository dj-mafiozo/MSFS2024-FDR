program ProbeFMCScreens;
{$APPTYPE CONSOLE}
uses Winapi.Windows,System.JSON,System.SysUtils,System.Generics.Collections,FlightTelemetryU,AircraftTelemetryU,FMCScreensU;
var S:TFlightSample;P:TIFlyProvider;Screens:TObjectList<TFMCScreen>;Screen:TFMCScreen;I,A,B:Integer;H,M:THandle;View:Pointer;W:DWORD;
begin
 S:=TFlightSample.Create;P:=TIFlyProvider.Create;
 try
  for I:=1 to 30 do begin P.Capture(S);if S.AircraftData.GetValue('status').Value='available' then Break;Sleep(30);end;
  Writeln('SDK status: '+S.AircraftData.GetValue('status').Value);
  H:=OpenMutex(SYNCHRONIZE or MUTEX_MODIFY_STATE,False,'iFly737MAX_SDK_Mutex');if H=0 then Writeln('OpenMutex error='+IntToStr(GetLastError)) else CloseHandle(H);
  H:=OpenFileMapping(FILE_MAP_READ,False,'iFly737MAX_SDK_FileMappingObject');if H=0 then Writeln('OpenFileMapping error='+IntToStr(GetLastError)) else CloseHandle(H);
  M:=OpenMutex(SYNCHRONIZE or MUTEX_MODIFY_STATE,False,'iFly737MAX_SDK_Mutex');H:=OpenFileMapping(FILE_MAP_READ,False,'iFly737MAX_SDK_FileMappingObject');
  if (M<>0) and (H<>0) then begin
   View:=MapViewOfFile(H,FILE_MAP_READ,0,0,0);
   if View<>nil then begin
    W:=WaitForSingleObject(M,50);Writeln('SDK mutex wait='+IntToStr(W));
    if (W=WAIT_OBJECT_0) or (W=WAIT_ABANDONED) then begin Move(View^,A,4);Move(PByte(NativeUInt(View)+4)^,B,4);ReleaseMutex(M);Writeln('SDK state='+IntToStr(A)+' model='+IntToStr(B));end;
    UnmapViewOfFile(View);
   end else Writeln('MapView error='+IntToStr(GetLastError));
  end;
  if H<>0 then CloseHandle(H);if M<>0 then CloseHandle(M);
  Screens:=ExtractFMCScreens(S.AircraftData);
  try
   for Screen in Screens do begin
    Writeln('CDU '+Screen.Device+' available='+BoolToStr(Screen.Available,True)+' rows='+IntToStr(Screen.Lines.Count)+' title='+Screen.Title);
    if Screen.Available then Writeln('Fixed-width text length='+IntToStr(Length(Screen.Lines.Text))+' page='+Screen.PageKey);
   end;
   if Screens.Count=0 then Writeln('No FMC screen source available.');
  finally Screens.Free;end;
 finally P.Free;S.Free;end;
end.
