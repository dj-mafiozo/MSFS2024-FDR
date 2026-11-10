Program ProbePMDG;
{$APPTYPE CONSOLE}

Uses
 Winapi.Windows, System.SysUtils, System.JSON, SimConnectClientU, AircraftTelemetryU, PMDGNG3CatalogU;

Var
 Sim      : TSimConnectClient;
 Provider : TPMDGNG3Provider;
 Started  : UInt64;
 Title    : String;
 Status   : String;
 v        : TJSONValue;
 c        : TJSONObject;
 i        : Integer;

Begin
 Sim      := TSimConnectClient.Create;
 Provider := TPMDGNG3Provider.Create;
 Try
  Sim.Connect(ExtractFilePath(ParamStr(0)) + 'SimConnect.dll');
  Started := GetTickCount64;
  Status  := '';
  While GetTickCount64 - Started < 10000 Do
   Begin
    Sim.Poll;
    Title := Sim.Sample.S('title');
    If Title <> '' Then
     Begin
      If Not Provider.Matches(Title) Then
       Begin
        Writeln('Current aircraft: ' + Title);
        Writeln('SKIP: current aircraft is not PMDG 737 NG; no PMDG SDK read attempted.');
        Break;
       End;
      Provider.Tick(500);
      Provider.Capture(Sim.Sample);
      Status := Sim.Sample.AircraftData.GetValue('status').Value;
      If Status = 'available' Then
       Begin
        Writeln('Current aircraft: ' + Title);
        Writeln('SDK status: ' + Status + '; fields=' + Sim.Sample.AircraftData.GetValue('received_field_count').Value);
        v := Sim.Sample.AircraftData.GetValue('performance_reference');
        Writeln('FMC references: ' + v.ToJSON);
        c     := Sim.Sample.AircraftData.GetValue('cdu') As TJSONObject;
        For i := 0 To 1 Do
         Begin
          v := c.GetValue(IntToStr(i));
          Writeln('CDU ' + IntToStr(i) + ': ' + (v As TJSONObject).GetValue('status').Value);
         End;
        Writeln('PASS: live read-only PMDG NG3 Client Data received. No recording, controls or simulator variables written.');
        Break;
       End;
     End;
    Sleep(20);
   End;
  If (Title = '') Or ((Title <> '') And Provider.Matches(Title) And (Status <> 'available')) Then
   Writeln('UNAVAILABLE: no valid PMDG SDK block within 10 seconds; verify aircraft and SDK broadcast settings.');
 Except
  On E : Exception Do
   Begin
    Writeln('UNAVAILABLE: ' + E.Message);
    ExitCode := 1;
   End;
 End;
 Provider.Free;
 Sim.Free;
End.
