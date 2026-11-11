Program MockFlightPad32;
{$APPTYPE CONSOLE}

Uses
 Winapi.Windows, System.SysUtils, System.JSON, FlightPadScreenIPCU In '..\src\FMC\FlightPadScreenIPCU.pas';

Var
 Publisher  : TFlightPadScreenPublisher;
 Stop       : THandle;
 Text       : String;
 Line       : String;
 r          : Integer;
 Change     : THandle;
 Offline    : THandle;
 Meta       : TJSONObject;
 Style      : TJSONObject;
 Lamps      : TJSONObject;
 Rows       : TJSONArray;
 Appearance : String;

Begin
 Stop      := CreateEvent(Nil, True, False, PChar('Local\FDR.FlightPad.TestStop.' + IntToStr(GetCurrentProcessId)));
 Publisher := TFlightPadScreenPublisher.Create(ParamStr(1));
 Try
  Text  := '';
  For r := 0 To 13 Do
   Begin
    Case r Of
     0  : Line := 'PERF TAKE OFF';
     1  : Line := 'V1 135';
     2  : Line := 'VR 140';
     3  : Line := 'V2 145';
     13 : Line := 'SCRATCHPAD ' + WideChar($2190);
    Else Line := '';
    End;
    Text := Text + Copy(Line + StringOfChar(' ', 24), 1, 24) + #13#10;
   End;
  Change  := CreateEvent(Nil, True, False, PChar('Local\FDR.FlightPad.TestChange.' + IntToStr(GetCurrentProcessId)));
  Offline := CreateEvent(Nil, True, False, PChar('Local\FDR.FlightPad.TestOffline.' + IntToStr(GetCurrentProcessId)));
  Repeat
   If ParamStr(2) = 'appearance' Then
    Begin
     Style := TJSONObject.Create;
     Lamps := TJSONObject.Create;
     Meta  := TJSONObject.Create;
     Try
      Style.AddPair('encoding', 'rgb-flags-v1');
      If WaitForSingleObject(Offline, 0) = WAIT_OBJECT_0 Then
       Style.AddPair('overlay', 'DISCONNECTED');
      Rows := TJSONArray.Create;
      Style.AddPair('rows', Rows);
      For r := 0 To 13 Do
       If WaitForSingleObject(Change, 0) = WAIT_OBJECT_0 Then
        Rows.Add(StringReplace(StringOfChar('X', 24), 'X', 'FF000001', [rfReplaceAll]))
       Else
        Rows.Add(StringReplace(StringOfChar('X', 24), 'X', '00FF0001', [rfReplaceAll]));
      Lamps.AddPair('FM1', TJSONBool.Create(True));
      Lamps.AddPair('FM2', TJSONNull.Create);
      Lamps.AddPair('MCDU MENU', TJSONBool.Create(True));
      Meta.AddPair('style_json', Style.ToJSON);
      Meta.AddPair('annunciators_json', Lamps.ToJSON);
      Meta.AddPair('side', 'capt');
      Appearance := Meta.ToJSON;
     Finally
      Style.Free;
      Lamps.Free;
      Meta.Free;
     End;
     Publisher.PublishFull(Text, Appearance, WaitForSingleObject(Offline, 0) <> WAIT_OBJECT_0);
    End
   Else
    Publisher.Publish(Text, True);
  Until WaitForSingleObject(Stop, 20) <> WAIT_TIMEOUT;
 Finally
  Publisher.Free;
  CloseHandle(Stop);
  CloseHandle(Change);
  CloseHandle(Offline);
 End;
End.
