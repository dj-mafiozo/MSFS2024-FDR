program VerifyFlightPad;
{$APPTYPE CONSOLE}
uses Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  FireDAC.Comp.Client, FlightDatabaseU, FlightTelemetryU, TelemetryCatalogU, FMCScreensU,
  FlightPadScreenIPCU, FlightPadScreensU, AircraftTelemetryU;
var Publisher: TFlightPadScreenPublisher; Snapshot, Other: TFlightPadScreenSnapshot;
  Root, Context: TJSONObject; Screens: TObjectList<TFMCScreen>; Text, Path, Profile, Provider: string;
  R, K, Trip: Integer; S: TFlightSample; DB: TFlightDatabase; Startup: TStartupInfo;
  Process: TProcessInformation; Stop, Map, Lock: THandle; View: Pointer; Packet: TFlightPadScreenPacket;
  Started: UInt64; Registry: TAircraftProviders;
procedure Check(B: Boolean; const Message: string);
begin if not B then raise Exception.Create(Message); end;
procedure SetN(const Name: string; Value: Double);
var I: Integer;
begin for I := 0 to FieldCount-1 do if SimFields[I].Name=Name then begin S.Numbers[I]:=Value; Exit; end; end;
begin
  Check(SizeOf(TFlightPadScreenPacket)=776, 'Stable packed protocol size');
  Text := ''; for R:=0 to 13 do Text:=Text+StringOfChar(' ',24)+#13#10;
  Publisher:=TFlightPadScreenPublisher.Create('FenixA320');
  try
    Check(not ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Snapshot),'No uninitialized screen');
    Publisher.Publish(Text,True);
    Check(ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Snapshot),'Published screen');
    Check(Snapshot.Text=Text,'Spaces and CRLF preserved');
    Sleep(20);Publisher.Publish(Text,True);ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Other);
    Check(Snapshot.ScreenTick=Other.ScreenTick,'Heartbeat does not change observation timestamp');
    Check(not ReadFlightPadScreenPID('FBWA320',GetCurrentProcessId,Other),'Profiles isolated');
    Publisher.Publish('short',True);Check(not ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Other),'Malformed text unavailable');
    Publisher.Publish(Text,False);Check(not ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Other),'Disconnected unavailable');
    Publisher.Publish(Text,True);
    Map:=OpenFileMapping(FILE_MAP_ALL_ACCESS,False,PChar('Local\FlightPadFMC.Screen.v1.FenixA320.'+IntToStr(GetCurrentProcessId)));
    Lock:=OpenMutex(SYNCHRONIZE or MUTEX_MODIFY_STATE,False,PChar('Local\FlightPadFMC.Screen.v1.FenixA320.'+IntToStr(GetCurrentProcessId)+'.Lock'));
    View:=MapViewOfFile(Map,FILE_MAP_ALL_ACCESS,0,0,SizeOf(Packet));
    Check(View<>nil,'Open controlled fixture mapping');
    try
      WaitForSingleObject(Lock,INFINITE);
      try Move(View^,Packet,SizeOf(Packet));Packet.HeartbeatTick:=GetTickCount64-6000;Move(Packet,View^,SizeOf(Packet));
      finally ReleaseMutex(Lock);end;
      Check(not ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Other),'Stalled heartbeat rejected');
      Publisher.Publish(Text,True);
      WaitForSingleObject(Lock,INFINITE);
      try Move(View^,Packet,SizeOf(Packet));Packet.Version:=99;Move(Packet,View^,SizeOf(Packet));
      finally ReleaseMutex(Lock);end;
      Check(not ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Other),'Unknown protocol rejected');
    finally UnmapViewOfFile(View);CloseHandle(Map);CloseHandle(Lock);end;
  finally Publisher.Free;end;
  Check(not ReadFlightPadScreenPID('FenixA320',GetCurrentProcessId,Snapshot),'Closed publisher unavailable');
  for K:=0 to 1 do
  begin
    if K=0 then begin Profile:='FenixA320';Provider:='FenixA32X';end
    else begin Profile:='FBWA320';Provider:='FBWA32NX';end;
    FillChar(Startup,SizeOf(Startup),0);Startup.cb:=SizeOf(Startup);
    Startup.dwFlags:=STARTF_USESHOWWINDOW;Startup.wShowWindow:=SW_HIDE;
    Text:='"'+ExtractFilePath(ParamStr(0))+'MockFlightPad32.exe" '+Profile;
    UniqueString(Text);
    Check(CreateProcess(nil,PChar(Text),nil,nil,False,CREATE_NO_WINDOW,nil,nil,Startup,Process),'Start Win32 publisher');
    try
      Started:=GetTickCount64;
      repeat
        if ReadFlightPadScreenPID(Profile,Process.dwProcessId,Snapshot) then Break;
        Sleep(20);
      until GetTickCount64-Started>5000;
      Check(Snapshot.Text<>'','Win32 publisher -> Win64 reader');
      Check(ReadFlightPadScreen(Profile,Other) and (Other.ProcessID=Process.dwProcessId),'Running process autodetection');
      Root:=TJSONObject.Create;
      try
        Root.AddPair('provider',Provider);AttachFlightPadScreen(Root);Screens:=ExtractFMCScreens(Root);
        try
          Check((Screens.Count=1) and Screens[0].Available,'Generic CDU attached');
          Check((Screens[0].Lines.Count=14) and (Length(Screens[0].Lines[13])=24),'Full screen and scratchpad');
          Check(Pos(WideChar($2190),Screens[0].Lines[13])>0,'Unicode glyph survives cross-bitness');
          Check(Screens[0].PowerState=-1,'No invented electrical power state');
        finally Screens.Free;end;
        S:=TFlightSample.Create;
        Path:=ExtractFilePath(ParamStr(0))+'flightpad-'+IntToStr(GetTickCount64)+'.db';
        DB:=TFlightDatabase.Create(Path,ExtractFilePath(ParamStr(0))+'sqlite3.dll');
        try
          SetN('time_zulu.year',2026);SetN('time_zulu.month',10);SetN('time_zulu.day',17);
          S.AircraftData:=TJSONObject.ParseJSONValue(Root.ToJSON) as TJSONObject;Trip:=DB.StartTrip(S);
          DB.RecordSample(Trip,S);SetN('time_zulu.seconds',1);DB.RecordSample(Trip,S);
          Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')=1,'Unchanged external screen stored once');
          Context:=LatestFMCContext(DB.Connection,Trip,S.Time('time_zulu'));
          try Check(Pos('v1_kt',Context.ToJSON)>0,'External V-speeds in analysis');finally Context.Free;end;
          Registry:=TAircraftProviders.Create(ExtractFilePath(ParamStr(0))+'MockFenixSim.dll',ExtractFilePath(ParamStr(0))+'MockFenixSim.dll');
          try
            for R:=0 to FieldCount-1 do if SimFields[R].Name='title' then
              if K=0 then S.Texts[R]:='Fenix A320 LOT' else S.Texts[R]:='FBW A32NX LOT';
            Registry.Capture(S);
            Check(S.AircraftData.GetValue('cdu')<>nil,'Aircraft registry includes FlightPad screen');
          finally Registry.Free;end;
          Stop:=OpenEvent(EVENT_MODIFY_STATE,False,PChar('Local\FDR.FlightPad.TestStop.'+IntToStr(Process.dwProcessId)));
          Check(Stop<>0,'Stop publisher event');try SetEvent(Stop);finally CloseHandle(Stop);end;
          Check(WaitForSingleObject(Process.hProcess,3000)=WAIT_OBJECT_0,'Publisher exits');
          AttachFlightPadScreen(S.AircraftData);SetN('time_zulu.seconds',2);DB.RecordSample(Trip,S);
          Check(DB.Connection.ExecSQLScalar('select available from trip_fmc_screens order by id desc limit 1')=0,'Stopped app invalidates FDR screen');
          DB.DeleteTrip(Trip);
          Check(DB.Connection.ExecSQLScalar('select count(*) from trip_fmc_screens')=0,'External screen cleanup');
        finally DB.Free;S.Free;DeleteFile(PChar(Path));end;
      finally Root.Free;end;
    finally
      if WaitForSingleObject(Process.hProcess,0)=WAIT_TIMEOUT then TerminateProcess(Process.hProcess,1);
      CloseHandle(Process.hThread);CloseHandle(Process.hProcess);
    end;
  end;
  Writeln('PASS: FlightPad Win32/Win64 text IPC, running process detection, Fenix/FBW isolation, heartbeat, unavailable/malformed/version rejection, Unicode, aircraft integration, change-only FDR and AI context. Mock publishers only.');
end.
