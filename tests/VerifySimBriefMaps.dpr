Program VerifySimBriefMaps;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, System.Classes, System.JSON, System.NetEncoding, System.Math,
 Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, IdHTTPServer, IdContext, IdCustomHTTPServer,
 SimBriefMapsU In '..\src\FlightPlan\SimBriefMapsU.pas', SimBriefImportU In '..\src\FlightPlan\SimBriefImportU.pas', FlightDatabaseU In '..\src\Data\FlightDatabaseU.pas', FlightTelemetryU In '..\src\Telemetry\FlightTelemetryU.pas', TelemetryCatalogU In '..\src\Telemetry\TelemetryCatalogU.pas',
 fraSimBriefMapU In '..\src\Frames\fraSimBriefMapU.pas', frmSimBriefFrameU In '..\src\Frames\frmSimBriefFrameU.pas';

Type
 TFakeMaps = Class
  Count : Integer;
  GIF   : TBytes;
  Procedure Get(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 End;

Procedure TFakeMaps.Get(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
 Begin
  InterlockedIncrement(Count);
  If Pos('bad.gif', Request.Document) > 0 Then
   Begin
    Response.ContentType := 'text/html';
    Response.ContentText := '<html>missing map</html>';
   End
  Else
   Begin
    Response.ContentType       := 'image/gif';
    Response.ContentStream     := TBytesStream.Create(GIF);
    Response.FreeContentStream := True;
   End;
 End;

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Var
 Server      : TIdHTTPServer;
 Fake        : TFakeMaps;
 Worker      : TSimBriefMapsFetch;
 DB          : TFlightDatabase;
 Sample      : TFlightSample;
 Images      : TArray<TSimBriefMap>;
 Stored      : TArray<TSimBriefMap>;
 Payload     : String;
 Other       : String;
 Base        : String;
 Trip        : Integer;
 i           : Integer;
 ImagesFound : Integer;
 Deadline    : UInt64;
 Host        : TForm;
 f           : TfraSimBrief;
 c           : TControl;

Procedure N(Const Name : String; Value : Double);
 Var
  j : Integer;
 Begin
  For j := 0 To FieldCount - 1 Do
   If SimFields[j].Name = Name Then
    Sample.Numbers[j] := Value;
 End;

Type

 [TestFixture]
 TVerifySimBriefMapsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifySimBriefMapsTests.Regression;
 Begin
  Application.Initialize;
  Fake   := TFakeMaps.Create;
  Server := TIdHTTPServer.Create(Nil);
  Worker := Nil;
  DB     := Nil;
  Sample := Nil;
  Host   := Nil;
  Try
   Fake.GIF := TNetEncoding.Base64.DecodeStringToBytes('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7');
   Check(ValidSimBriefGIF(Fake.GIF), 'Fixture GIF validation');
   Server.Bindings.Clear;
   With Server.Bindings.Add Do
    Begin
     IP   := '127.0.0.1';
     Port := 0;
    End;
   Server.OnCommandGet := Fake.Get;
   Server.Active       := True;
   Base                := 'http://127.0.0.1:' + IntToStr(Server.Bindings[0].Port) + '/maps/';
   Payload             := '{"origin":{"icao_code":"EPLL"},"destination":{"icao_code":"EGLL"},"text":{"plan_html":"TEST"},"images":{"directory":"' + Base + '","map":[' +
   '{"name":"Route","link":"route.gif"},{"name":"Weather","link":"wx.gif"},{"name":"Duplicate","link":"route.gif"},{"name":"Bad","link":"bad.gif"}]},"links":{"skyvector":"https://skyvector.com"},"prefile":{"vatsim":"never-submit"}}';
   Images := SimBriefMapRequests(Payload);
   Check(Length(Images) = 3, 'Map list joins directory, deduplicates links and excludes network/JS links');
   Worker := TSimBriefMapsFetch.Create(Payload);
   Worker.Start;
   Deadline := GetTickCount64 + 15000;
   While WaitForSingleObject(Worker.Handle, 0) <> WAIT_OBJECT_0 Do
    Begin
     Check(GetTickCount64 < Deadline, 'Map worker timeout');
     Sleep(10);
    End;
   Images := Copy(Worker.Images);
   Check((Fake.Count = 3) And (Length(Images[0].Data) > 0) And (Length(Images[1].Data) > 0), 'Worker downloads map GIFs');
   Check((Images[2].Error <> '') And (Length(Images[2].Data) = 0), 'HTML response is not stored as image');
   DB     := TFlightDatabase.Create(TestDatabasePath('simbrief-maps.mfzr'), TestRuntimeFile('sqlite3.dll'));
   Sample := TFlightSample.Create;
   N('time_zulu.year', 2026);
   N('time_zulu.month', 10);
   N('time_zulu.day', 25);
   N('number_of_engines', 0);
   Trip := DB.StartTrip(Sample);
   DB.Connection.ExecSQL('insert into trip_simbrief(trip,captured_utc,payload) values(:t,''2026-10-25T12:00:00Z'',:p)', [Trip, Payload]);
   SaveSimBriefMaps(DB.Connection, Trip, Payload, Images);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief_maps where length(data)>0 and typeof(data)=''blob''') = 2, 'GIFs stored as BLOB, not URLs/base64');
   Stored := LoadSimBriefMaps(DB.Connection, Trip, Payload);
   Check(Length(Stored) = 3, 'Images and individual errors round-trip');
   Check(TNetEncoding.Base64.EncodeBytesToString(Stored[0].Data) = TNetEncoding.Base64.EncodeBytesToString(Fake.GIF), 'Original image bytes preserved');
   Other := Payload.Replace('EGLL', 'EGKK');
   SaveSimBriefMaps(DB.Connection, Trip, Other, Images);
   Check(Length(LoadSimBriefMaps(DB.Connection, Trip, Other)) = 0, 'Wrong plan cannot attach or read another plan maps');
   Server.Active     := False;
   Host              := TForm.Create(Nil);
   Host.ClientWidth  := 900;
   Host.ClientHeight := 700;
   f                 := TfraSimBrief.Create(Host);
   f.ReadOnly        := True;
   f.Parent          := Host;
   f.Align           := alClient;
   f.SetTrip(DB.Connection, Trip);
   f.LoadPayload(Payload, 'Offline');
   Host.Show;
   Application.ProcessMessages;
   Check(Assigned(f.WheelEvents.OnMessage), 'Runtime wheel binding survives DFM creation');
   Check(f.FindComponent('SB_prefile') = Nil, 'No network filing section');
   c           := f.FindComponent('SB_maps') As TControl;
   ImagesFound := 0;
   For i       := 0 To TWinControl(c).ControlCount - 1 Do
    If TWinControl(c).Controls[i] Is TfraSimBriefMap Then
     Begin
      If TfraSimBriefMap(TWinControl(c).Controls[i]).MapImage.Picture.Graphic <> Nil Then
       Inc(ImagesFound);
     End;
   Check(ImagesFound = 2, 'Offline frame renders two images from SQLite with server stopped');
   f.ReadOnly := False;
   f.LoadPayload(Payload, 'Offline normal mode');
   Check(Not f.FetchTimer.Enabled, 'Complete stored maps do not trigger new HTTP requests');
   FreeAndNil(Host);
   DB.DeleteTrip(Trip);
   Check(DB.Connection.ExecSQLScalar('select count(*) from trip_simbrief_maps') = 0, 'Trip deletion cleans map BLOBs');
  Finally
   Host.Free;
   Sample.Free;
   DB.Free;
   Worker.Free;
   Server.Free;
   Fake.Free;
  End;
  System.Writeln('PASS: mock HTTP GIF download, validation, per-plan BLOB storage, offline DFM image rendering, errors, no network filing and cleanup.');

 End;

Begin
 RunNativeTests(TVerifySimBriefMapsTests);
End.
