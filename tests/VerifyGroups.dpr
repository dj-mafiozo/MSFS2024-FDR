Program VerifyGroups;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU,
 System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms, Vcl.Controls,
 Vcl.ExtCtrls, Data.DB, FireDAC.Comp.Client, FlightDatabaseU, FlightTelemetryU,
 TelemetryCatalogU, frmMainU, frmAssignGroupU, VirtualTrees, VirtualTrees.BaseTree, VirtualTrees.Types, RecordingTreeU;

Procedure Check(Value : Boolean; Const Msg : String);
 Begin
  If Not Value Then
   Raise Exception.Create(Msg);
 End;

Type
 TProbe = Class
  Public
   Expected   : Integer;
   Chosen     : Integer;
   ResultCode : Integer;
   Seen       : Boolean;
   Procedure Tick(Sender : TObject);
 End;

Procedure TProbe.Tick(Sender : TObject);
 Var
  i : Integer;
  d : TfrmAssignGroup;
 Begin
  For i := 0 To Screen.FormCount - 1 Do
   If Screen.Forms[i] Is TfrmAssignGroup Then
    Begin
     TTimer(Sender).Enabled := False;
     d                      := TfrmAssignGroup(Screen.Forms[i]);
     Check(d.BorderStyle = bsDialog, 'Dialog border');
     Check(Integer(NativeInt(d.cbGroups.Items.Objects[d.cbGroups.ItemIndex])) = Expected, 'Current group');
     d.cbGroups.ItemIndex := d.cbGroups.Items.IndexOfObject(TObject(NativeInt(Chosen)));
     Check(d.cbGroups.ItemIndex >= 0, 'Group available');
     Seen := True;
     If ResultCode = mrOk Then
      d.btnOK.Click
     Else
      d.btnCancel.Click;
     Exit;
    End;
 End;

Var
 DB   : TFlightDatabase;
 s    : TFlightSample;
 m    : TfrmMain;
 p    : TProbe;
 t    : TTimer;
 IDs  : Array [0..2] Of Integer;
 g    : Array [0..1] Of Integer;
 i    : Integer;
 k    : Integer;
 Root : String;
 Rows : TDataSet;

Function TreeCount : Integer;
 Var
  n : PVirtualNode;
 Begin
  Result := 0;
  n      := m.vstRecordings.GetFirst;
  While n <> Nil Do
   Begin
    If RecordingNodeID(n) > 0 Then
     Inc(Result);
    n := m.vstRecordings.GetNext(n);
   End;
 End;

Procedure Filter(GroupID : Integer);
 Begin
  m.cbGroup.ItemIndex := m.cbGroup.Items.IndexOfObject(TObject(NativeInt(GroupID)));
  m.GroupChanged(m.cbGroup);
 End;

Procedure Assign(Current, Target, Code : Integer);
 Begin
  If m.vstRecordings.FocusedNode = Nil Then
   m.SelectRecording(IDs[0]);
  p.Expected   := Current;
  p.Chosen     := Target;
  p.ResultCode := Code;
  p.Seen       := False;
  t.Enabled    := True;
  m.aAssignExecute(m.aAssign);
  Check(p.Seen, 'Modal dialog opened');
 End;

Type

 [TestFixture]
 TVerifyGroupsTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyGroupsTests.Regression;
 Begin
  Try
   Application.Initialize;
   Root := TestDataDirectory;
   DB   := TFlightDatabase.Create(TestDatabasePath(TPath.Combine(Root, 'flight_data.db')), TPath.Combine(Root, 'sqlite3.dll'));
   s    := TFlightSample.Create;
   Try
    For k := 0 To FieldCount - 1 Do
     Begin
      If SimFields[k].Name = 'time_zulu.year' Then
       s.Numbers[k] := 2026;
      If SimFields[k].Name = 'time_zulu.month' Then
       s.Numbers[k] := 10;
      If SimFields[k].Name = 'time_zulu.day' Then
       s.Numbers[k] := 18;
      If SimFields[k].Name = 'title' Then
       s.Texts[k] := 'Group fixture';
     End;
    For i := 0 To 2 Do
     Begin
      IDs[i] := DB.StartTrip(s);
      DB.EndTrip(IDs[i], s);
     End;
    For i := 0 To 1 Do
     Begin
      DB.Connection.ExecSQL('insert into trip_groups(name) values (:n)', ['Group test ' + IntToStr(IDs[0]) + '-' + IntToStr(i)]);
      g[i] := DB.Connection.ExecSQLScalar('select last_insert_rowid()');
      DB.Connection.ExecSQL('update trips set group_id=:g where id=:id', [g[i], IDs[i]]);
     End;
   Finally
    s.Free;
    DB.Free;
   End;
   m := TfrmMain.Create(Nil);
   p := TProbe.Create;
   t := TTimer.Create(Nil);
   Try
    m.Timer.Enabled := False;
    t.Enabled       := False;
    t.Interval      := 20;
    t.OnTimer       := p.Tick;
    Rows            := m.RecordingRows;
    Check(m.cbGroup.Items[0] = '', 'Empty means no filter');
    Filter(g[0]);
    Check(TreeCount = 1, 'First group');
    m.SelectRecording(IDs[0]);
    m.aRefreshExecute(m.aRefresh);
    Check(Integer(NativeInt(m.cbGroup.Items.Objects[m.cbGroup.ItemIndex])) = g[0], 'Refresh preserves filter');
    Assign(g[0], g[1], mrCancel);
    Check(TreeCount = 1, 'Cancel preserves assignment');
    Assign(g[0], g[1], mrOk);
    Check((TreeCount = 0), 'Reassignment removes filtered row');
    Check((m.DataGrid.RowCount = 2) And (m.DataGrid.Cells[1, 1] = ''), 'No stale inspector');
    Filter(g[1]);
    Check(TreeCount = 2, 'Second group');
    m.SelectRecording(IDs[0]);
    Assign(g[1], 0, mrOk);
    Check(TreeCount = 1, 'Unassign removes filtered row');
    Filter(0);
    Check(Rows.Locate('id', IDs[0], []), 'All includes ungrouped');
    Check(Rows.Locate('id', IDs[2], []), 'All includes originally ungrouped');
    m.cbGroup.ItemIndex := -1;
    m.GroupChanged(m.cbGroup);
    Check(m.cbGroup.ItemIndex = 0, 'No selection means all');
    Filter(g[0]);
    Check((TreeCount = 0), 'Empty group');
   Finally
    t.Free;
    p.Free;
    m.Free;
   End;
   System.Writeln('PASS: group filtering, empty/all selection, refresh retention, modal OK/Cancel, assignment/unassignment and empty groups. Synthetic SQLite/VCL only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln('FAIL: ', E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyGroupsTests);
End.
