{$StackFrames On}
Unit FlightPadScreensU;

Interface

 Uses
  System.JSON;

 Procedure AttachFlightPadScreen(Root : TJSONObject);

Implementation

 Uses
  System.SysUtils, FlightPadScreenIPCU;

 Procedure AttachFlightPadScreen(Root : TJSONObject);
  Var
   Profile  : String;
   V        : TJSONValue;
   Snapshot : TFlightPadScreenSnapshot;
   CDU      : TJSONObject;
   Screen   : TJSONObject;
   Rows     : TJSONArray;
   R        : Integer;
  Begin
   If Root = Nil Then
    Exit;
   V := Root.GetValue('provider');
   If V = Nil Then
    Exit;
   If V.Value = 'FenixA32X' Then
    Profile := 'FenixA320'
   Else If V.Value = 'FBWA32NX' Then
    Profile := 'FBWA320'
   Else
    Exit;
   Root.RemovePair('cdu').Free;
   CDU := TJSONObject.Create;
   Root.AddPair('cdu', CDU);
   Screen := TJSONObject.Create;
   CDU.AddPair('0', Screen);
   Screen.AddPair('source', 'FlightPadFMC/' + Profile);
   If ReadFlightPadScreen(Profile, Snapshot) Then
    Begin
     Screen.AddPair('status', 'available');
     Screen.AddPair('publisher_pid', TJSONNumber.Create(Snapshot.ProcessID));
     // Stable timestamp of the changed text, not the changing IPC heartbeat.
     Screen.AddPair('observed_filetime_utc', IntToStr((UInt64(Snapshot.ScreenUTC.dwHighDateTime) Shl 32) Or Snapshot.ScreenUTC.dwLowDateTime));
     Rows := TJSONArray.Create;
     Screen.AddPair('rows', Rows);
     For R := 0 To 13 Do
      Rows.Add(Copy(Snapshot.Text, R * 26 + 1, 24));
    End
   Else
    Screen.AddPair('status', 'unavailable');
   // No power flag: connectivity is not proof of electrical power.
  End;

End.
