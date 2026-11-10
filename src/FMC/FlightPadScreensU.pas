{$StackFrames On}
Unit FlightPadScreensU;

Interface

 Uses
  System.JSON;

 Procedure AttachFlightPadScreen(Root : TJSONObject; PublisherPID : Cardinal = 0);

Implementation

 Uses
  System.SysUtils, FlightPadScreenIPCU;

 Procedure AttachFlightPadScreen(Root : TJSONObject; PublisherPID : Cardinal);
  Var
   Profile  : String;
   v        : TJSONValue;
   Metadata : TJSONValue;
   Pair     : TJSONPair;
   Snapshot : TFlightPadScreenSnapshot;
   CDU      : TJSONObject;
   Screen   : TJSONObject;
   Rows     : TJSONArray;
   r        : Integer;
   Live     : Boolean;
  Begin
   If Root = Nil Then
    Exit;
   v := Root.GetValue('provider');
   If v = Nil Then
    Exit;
   If v.Value = 'FenixA32X' Then
    Profile := 'FenixA320'
   Else If v.Value = 'FBWA32NX' Then
    Profile := 'FBWA320'
   Else
    Exit;
   Root.RemovePair('cdu').Free;
   CDU := TJSONObject.Create;
   Root.AddPair('cdu', CDU);
   Screen := TJSONObject.Create;
   CDU.AddPair('0', Screen);
   Screen.AddPair('source', 'FlightPadFMC/' + Profile);
   If PublisherPID = 0 Then
    Live := ReadFlightPadScreenState(Profile, Snapshot)
   Else
    Live := ReadFlightPadScreenStatePID(Profile, PublisherPID, Snapshot);
   If Live Then
    Begin
     If Snapshot.Available Then
      Screen.AddPair('status', 'available')
     Else
      Screen.AddPair('status', 'unavailable');
     Metadata := TJSONObject.ParseJSONValue(Snapshot.AppearanceJSON);
     Try
      If Metadata Is TJSONObject Then
       For Pair In TJSONObject(Metadata) Do
        If (Pair.JsonString.Value = 'style_json') Or (Pair.JsonString.Value = 'annunciators_json') Or (Pair.JsonString.Value = 'side') Or (Pair.JsonString.Value = 'profile') Or (Pair.JsonString.Value = 'has_screen') Then
         Screen.AddPair(Pair.JsonString.Value, TJSONObject.ParseJSONValue(Pair.JsonValue.ToJSON));
     Finally
      Metadata.Free;
     End;
     Screen.AddPair('publisher_pid', TJSONNumber.Create(Snapshot.ProcessID));
     // Stable timestamp of the changed text, not the changing IPC heartbeat.
     Screen.AddPair('observed_filetime_utc', IntToStr((UInt64(Snapshot.ScreenUTC.dwHighDateTime) Shl 32) Or Snapshot.ScreenUTC.dwLowDateTime));
     Rows := TJSONArray.Create;
     Screen.AddPair('rows', Rows);
     For r := 0 To 13 Do
      Rows.Add(Copy(Snapshot.Text, r * 26 + 1, 24));
    End
   Else
    Screen.AddPair('status', 'unavailable');
   // No power flag: connectivity is not proof of electrical power.
  End;

End.
