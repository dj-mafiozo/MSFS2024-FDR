Program VerifyRecordingUI;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Windows, System.SysUtils, System.Classes, System.IOUtils, System.Variants,
 Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, VirtualTrees, VirtualTrees.BaseTree, VirtualTrees.Types, Vcl.Controls, FireDAC.Comp.Client, FireDAC.Stan.Param,
 FlightDatabaseU, RecordingIndexU, RecordingTreeU, FlightTelemetryU, TelemetryCatalogU, frmMainU;

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Type
 TRecoveryChoice = Class
  Choice : Integer;
  Seen   : Boolean;
  Procedure Tick(Sender : TObject);
 End;

Procedure TRecoveryChoice.Tick(Sender : TObject);
 Var
  i : Integer;
 Begin
  For i := 0 To Screen.FormCount - 1 Do
   If (fsModal In Screen.Forms[i].FormState) And Not(Screen.Forms[i] Is TfrmMain) Then
    Begin
     Seen                        := True;
     TTimer(Sender).Enabled      := False;
     Screen.Forms[i].ModalResult := Choice;
    End;
 End;

Var
 DB         : TFlightDatabase;
 s          : TFlightSample;
 m          : TfrmMain;
 Index      : TRecordingIndex;
 Root       : String;
 Path       : String;
 ActivePath : String;
 i          : Integer;
 ID         : Integer;
 ActiveID   : Integer;
 Node       : PVirtualNode;
 ActiveNode : PVirtualNode;
 Allow      : Boolean;
 Choice     : TRecoveryChoice;
 Timer      : TTimer;
 Lock       : THandle;
 Rejected   : Boolean;

Type

 [TestFixture]
 TVerifyRecordingUITests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyRecordingUITests.Regression;
 Begin
  Try
   Application.Initialize;
   Root := TestDataDirectory;
   Path := TPath.Combine(Root, 'flight_data.db');
   DB   := TFlightDatabase.Create(Path, TestRuntimeFile('sqlite3.dll'));
   s    := TFlightSample.Create;
   Try
    For i := 0 To FieldCount - 1 Do
     Begin
      If SimFields[i].Name = 'title' Then
       s.Texts[i] := 'Recording UI test';
      If SimFields[i].Name = 'atc_model' Then
       s.Texts[i] := 'B38M';
      If SimFields[i].Name = 'time_zulu.year' Then
       s.Numbers[i] := 2026;
      If SimFields[i].Name = 'time_zulu.month' Then
       s.Numbers[i] := 10;
      If SimFields[i].Name = 'time_zulu.day' Then
       s.Numbers[i] := 21;
     End;
    ID := DB.StartTrip(s);
    DB.RecordSample(ID, s);
    DB.EndTrip(ID, s);
    DB.Connection.ExecSQL('update trips set departure_icao=''EPLL'',destination_icao=''EPLL'' where id=:id', [ID]);
   Finally
    s.Free;
    DB.Free;
   End;
   m := TfrmMain.Create(Nil);
   Try
    m.Timer.Enabled := False;
    Check(m.vstRecordings.Images = m.ImageListSmall, 'Tree assigned existing ImageList');
    Check(Assigned(m.vstRecordings.OnDblClick), 'Tree double click hooked');
    m.SelectRecording(ID);
    Check(RecordingNodeID(m.vstRecordings.FocusedNode) = ID, 'Recording selected');
    Check(m.DataGrid.RowCount > 2, 'Recording opens inspector');
    m.vstRecordings.OnDblClick(m.vstRecordings);
    Check(m.SixPackFrame <> Nil, 'Synchronized instrument frame remains available');
    Index := TRecordingIndex.Create(TPath.Combine(Root, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'));
    Try
     ActiveID := Index.Reserve('2026-10-22T00:00:00Z');
     Index.Connection.ExecSQL('update trips set atc_model=''A320'',departure_icao=''EDDF'',title=''Active'' where id=:id', [ActiveID]);
     ActivePath := Index.RecordingPath(ActiveID);
     ForceDirectories(ExtractFileDir(Index.Resolve(ActivePath)));
     TFile.WriteAllText(Index.Resolve(ActivePath), 'fixture');
     Index.SetPath(ActiveID, ActivePath);
     m.aRefreshExecute(m.aRefresh);
     ActiveNode := Nil;
     Node       := m.vstRecordings.GetFirst;
     While Node <> Nil Do
      Begin
       If RecordingNodeID(Node) = ActiveID Then
        ActiveNode := Node;
       Node        := m.vstRecordings.GetNext(Node);
      End;
     Check(ActiveNode <> Nil, 'Active recording visible');
     Allow := True;
     m.vstRecordings.OnFocusChanging(m.vstRecordings, m.vstRecordings.FocusedNode, ActiveNode, 0, 0, Allow);
     Check(Not Allow And m.vstRecordings.IsDisabled[ActiveNode], 'Active recording selection disabled');
     m.SelectRecording(ActiveID);
     Check(RecordingNodeID(m.vstRecordings.FocusedNode) = ID, 'Active recording cannot replace selection');
     m.eSearch.Text := 'no recording matches this';
     Check(m.vstRecordings.TotalCount = 0, 'Search filters whole tree');
     Check(m.DataGrid.RowCount = 2, 'Search clears stale inspector');
     m.eSearch.Clear;
     m.SelectRecording(ID);
     Check(m.DataGrid.RowCount > 2, 'Search reset reopens recording');
     m.vstRecordings.FocusedNode := m.vstRecordings.GetFirst;
     Check(m.DataGrid.RowCount = 2, 'Folder selection clears inspector');
     Index.SetStatus(ActiveID, 'error');
    Finally
     Index.Free;
    End;
   Finally
    m.Free;
   End;
   System.Writeln('PASS: migrated recording opens from tree, read-only/double click, active disabled, search reset, folder selection, instrument integration.');
   // Leave a valid committed file in recording state, simulating an unclosed session.
   DB := TFlightDatabase.Create(TPath.Combine(Root, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'), True);
   s  := TFlightSample.Create;
   Try
    For i := 0 To FieldCount - 1 Do
     Begin
      If SimFields[i].Name = 'title' Then
       s.Texts[i] := 'Recoverable';
      If SimFields[i].Name = 'time_zulu.year' Then
       s.Numbers[i] := 2026;
      If SimFields[i].Name = 'time_zulu.month' Then
       s.Numbers[i] := 10;
      If SimFields[i].Name = 'time_zulu.day' Then
       s.Numbers[i] := 21;
     End;
    ActiveID := DB.StartTrip(s);
    DB.RecordSample(ActiveID, s);
   Finally
    s.Free;
    DB.Free;
   End;
   Choice := TRecoveryChoice.Create;
   Timer  := TTimer.Create(Nil);
   Try
    Timer.Interval := 10;
    Timer.OnTimer  := Choice.Tick;
    Choice.Choice  := mrNo;
    Timer.Enabled  := True;
    m              := TfrmMain.Create(Nil);
    Try
     m.Timer.Enabled := False;
     Check(Choice.Seen, 'Recovery asks before restoring');
     m.SelectRecording(ActiveID);
     Check(RecordingNodeID(m.vstRecordings.FocusedNode) <> ActiveID, 'Declined recording disabled');
    Finally
     m.Free;
    End;
    Index := TRecordingIndex.Create(TPath.Combine(Root, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'));
    Try
     Check(FileExists(Index.PathFor(ActiveID)), 'Decline retains file');
     Check(Integer(Index.Connection.ExecSQLScalar('select recovery_pending from trips where id=:id', [ActiveID])) = 1, 'Decline retains pending metadata');
    Finally
     Index.Free;
    End;
    Choice.Seen   := False;
    Choice.Choice := mrYes;
    Timer.Enabled := True;
    m             := TfrmMain.Create(Nil);
    Try
     m.Timer.Enabled := False;
     Check(Choice.Seen, 'Next launch asks again');
     m.SelectRecording(ActiveID);
     Check(RecordingNodeID(m.vstRecordings.FocusedNode) = ActiveID, 'Accepted recovery can be opened');
     Check(m.DataGrid.RowCount > 2, 'Accepted recovery loads samples');
     ActivePath := TPath.Combine(Root, m.RecordingRows.FieldByName('relative_path').AsString);
     Lock       := CreateFile(PChar(ActivePath), GENERIC_READ, FILE_SHARE_READ Or FILE_SHARE_WRITE, Nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
     Check(Lock <> INVALID_HANDLE_VALUE, 'Hold recording open without delete sharing');
     Rejected := False;
     Try
      Choice.Seen   := False;
      Choice.Choice := mrYes;
      Timer.Enabled := True;
      Try
       m.aDeleteExecute(m.aDelete);
      Except
       On E : EOSError Do
        Rejected := True;
      End;
     Finally
      CloseHandle(Lock);
     End;
     Check(Rejected, 'Busy recording deletion rejected');
     Check(FileExists(ActivePath), 'Busy recording file retained');
     Check(m.RecordingRows.Locate('id', ActiveID, []), 'Busy recording metadata retained');
     Check(m.DataGrid.RowCount = 2, 'Failed deletion leaves safe cleared inspector');
     m.SelectRecording(ActiveID);
     Choice.Seen   := False;
     Choice.Choice := mrYes;
     Timer.Enabled := True;
     m.aDeleteExecute(m.aDelete);
     Check(Choice.Seen, 'Deletion confirmation');
     Check(Not FileExists(ActivePath), 'Deletion removes the single recording file');
     Check(Not m.RecordingRows.Locate('id', ActiveID, []), 'Deletion removes selected metadata only');
     Check(m.DataGrid.RowCount = 2, 'Deletion clears inspector safely');
    Finally
     m.Free;
    End;
   Finally
    Timer.Free;
    Choice.Free;
   End;
   System.Writeln('PASS: startup warning, decline preserves file/metadata, next-launch prompt, accepted recovery opens, busy-file protection and confirmed single-file deletion.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyRecordingUITests);
End.
