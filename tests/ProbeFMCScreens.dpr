Program ProbeFMCScreens;

{$APPTYPE CONSOLE}

Uses
 Winapi.Windows, System.JSON, System.SysUtils, System.Generics.Collections, FlightTelemetryU, AircraftTelemetryU, FMCScreensU;

Var
 s       : TFlightSample;
 p       : TIFlyProvider;
 Screens : TObjectList<TFMCScreen>;
 Screen  : TFMCScreen;
 i       : Integer;
 a       : Integer;
 b       : Integer;
 h       : THandle;
 m       : THandle;
 View    : Pointer;
 w       : DWORD;

Begin

 s := TFlightSample.Create;
 p := TIFlyProvider.Create;

 Try

  For i := 1 To 30 Do
   Begin
    p.Capture(s);
    If s.AircraftData.GetValue('status').Value = 'available' Then
     Break;
    Sleep(30);
   End;

  Writeln('SDK status: ' + s.AircraftData.GetValue('status').Value);

  h := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, 'iFly737MAX_SDK_Mutex');
  If h = 0 Then
   Writeln('OpenMutex error=' + IntToStr(GetLastError))
  Else
   CloseHandle(h);

  h := OpenFileMapping(FILE_MAP_READ, False, 'iFly737MAX_SDK_FileMappingObject');
  If h = 0 Then
   Writeln('OpenFileMapping error=' + IntToStr(GetLastError))
  Else
   CloseHandle(h);

  m := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, 'iFly737MAX_SDK_Mutex');
  h := OpenFileMapping(FILE_MAP_READ, False, 'iFly737MAX_SDK_FileMappingObject');

  If (m <> 0) And (h <> 0) Then
   Begin

    View := MapViewOfFile(h, FILE_MAP_READ, 0, 0, 0);

    If View <> Nil Then
     Begin

      w := WaitForSingleObject(m, 50);
      Writeln('SDK mutex wait=' + IntToStr(w));

      If (w = WAIT_OBJECT_0) Or (w = WAIT_ABANDONED) Then
       Begin
        Move(View^, a, 4);
        Move(PByte(NativeUInt(View) + 4)^, b, 4);
        ReleaseMutex(m);
        Writeln('SDK state=' + IntToStr(a) + ' model=' + IntToStr(b));
       End;

      UnmapViewOfFile(View);

     End
    Else
     Writeln('MapView error=' + IntToStr(GetLastError));

   End;

  If h <> 0 Then
   CloseHandle(h);
  If m <> 0 Then
   CloseHandle(m);

  Screens := ExtractFMCScreens(s.AircraftData);

  Try

   For Screen In Screens Do
    Begin

     Writeln('CDU ' + Screen.Device + ' available=' + BoolToStr(Screen.Available, True) + ' rows=' + IntToStr(Screen.Lines.Count) + ' title=' + Screen.Title);

     If Screen.Available Then
      Writeln('Fixed-width text length=' + IntToStr(Length(Screen.Lines.Text)) + ' page=' + Screen.PageKey);

    End;

   If Screens.Count = 0 Then
    Writeln('No FMC screen source available.');

  Finally
   Screens.Free;
  End;

 Finally
  p.Free;
  s.Free;
 End;
End.
