Program VerifyRecordingTree;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms,
 VirtualTrees, VirtualTrees.BaseTree, VirtualTrees.Types, FireDAC.Comp.Client, FireDAC.Stan.Param, RecordingIndexU In '..\src\Data\RecordingIndexU.pas', RecordingTreeU In '..\src\Visualization\RecordingTreeU.pas', LocalizationU In '..\src\i18n\LocalizationU.pas';

Procedure Check(b : Boolean; Const Msg : String);
 Begin
  If Not b Then
   Raise Exception.Create(Msg);
 End;

Type
 TErrors = Class
  Procedure Handle(Sender : TObject; e : Exception);
 End;

Procedure TErrors.Handle(Sender : TObject; e : Exception);
 Begin
  System.Writeln('VCL EXCEPTION: ' + e.ClassName + ': ' + e.Message);
  Raise Exception.Create('Regression failed; see diagnostic above');
 End;

Var
 Index : TRecordingIndex;
 q     : TFDQuery;
 Tree  : TVirtualStringTree;
 Host  : TForm;
 Root  : String;
 Rel   : String;
 Node  : PVirtualNode;

Procedure Add(ID : Integer; Const Stamp, Model, Dep, Arr, Title, Status : String; GroupID : Integer; Exists : Boolean);
 Begin
  Rel := 'Recordings\fixture-' + IntToStr(ID) + '.mfzr';
  Index.Connection.ExecSQL('insert into trips(id,local_trip_id,started_utc,atc_model,departure_icao,destination_icao,title,status,relative_path,group_id) ' +
  'values(:id,:id,:s,:m,:d,:a,:t,:status,:path,:g)', [ID, Stamp, Model, Dep, Arr, Title, Status, Rel, GroupID]);
  If Exists Then
   Begin
    ForceDirectories(ExtractFileDir(Index.Resolve(Rel)));
    TFile.WriteAllText(Index.Resolve(Rel), 'fixture');
   End;
 End;

Procedure Fill(Group : Integer; Const Search, Locale : String);
 Begin
  q.Close;
  q.Open('select t.*,g.name group_name from trips t left join trip_groups g on g.id=t.group_id order by julianday(started_utc) desc,t.id desc');
  FillRecordingTree(Tree, q, Index, Group, Search, Locale);
 End;

Function CountRecordings : Integer;
 Var
  n : PVirtualNode;
 Begin
  Result := 0;
  n      := Tree.GetFirst;
  While n <> Nil Do
   Begin
    If RecordingNodeID(n) > 0 Then
     Inc(Result);
    n := Tree.GetNext(n);
   End;
 End;

Type

 [TestFixture]
 TVerifyRecordingTreeTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyRecordingTreeTests.Regression;
 Begin
  Try
   Application.Initialize;
   Application.OnException := TErrors.Create.Handle;
   SetLanguage('en-GB');
   Check(Tr('[Nagrywanie...]') = '[Recording...]', 'New catalog literal identifiers');
   SetLanguage('pl-PL');
   Root := TPath.Combine(TestDataDirectory, 'tree');
   ForceDirectories(Root);
   Index       := TRecordingIndex.Create(TPath.Combine(Root, 'flight_data.mfzi'), TestRuntimeFile('sqlite3.dll'));
   q           := TFDQuery.Create(Nil);
   Host        := TForm.Create(Nil);
   Tree        := TVirtualStringTree.Create(Host);
   Tree.Parent := Host;
   Try
    q.Connection := Index.Connection;
    Index.Connection.ExecSQL('insert into trip_groups(id,name) values(1,''Training'')');
    Check(RecordingAircraftCode('ATCCOMACMODELB73', 'iFly 737-MAX8 LOT SP-LVA (166Seat)') = 'B38M', 'Legacy truncated localization key uses precise title');
    Check(RecordingAircraftCode('B738', 'Boeing 737-800') = 'B738', 'Explicit ICAO preserved');
    Check(RecordingAircraftCode('ATCCOM.AC_MODEL.A320', 'FlyByWire A32NX') = 'A20N', 'A32NX fallback');
    Check(RecordingAircraftCode('ATCCOM.AC_MODEL.UNKNOWN', 'Unrecognized aircraft') = 'UNKNOWN', 'Unknown key never exposed as ICAO');
    Check(RecordingAircraftCode('CON', 'Unknown') = 'UNKNOWN', 'Device name never becomes an aircraft directory');
    Add(1, '2025-12-31T20:04:05Z', 'B38M', 'EPLL', 'EGLL', 'LOT old', 'completed', 1, True);
    Add(2, '2026-01-01T01:04:05Z', 'A320', 'EDDF', 'EGLL', 'Fenix first', 'completed', 0, True);
    Add(3, '2026-10-03T02:04:05Z', 'B38M', 'EPMO', 'EPLL', 'LOT second', 'completed', 1, True);
    Add(4, '2026-10-21T03:04:05Z', 'ATCCOM.AC_MODEL.B738', 'EPLL', 'EPLL', 'iFly 737 MAX 8 LOT newest', 'recording', 1, True);
    Add(5, '2027-01-01T04:04:05Z', 'B777', 'EGLL', 'EGLL', 'Missing flight', 'completed', 0, False);
    Add(6, '2026-10-20T04:04:05Z', 'B38M', 'EPLL', 'EPLL', 'LOT previous', 'completed', 1, True);
    Fill(0, '', 'pl-PL');
    Check(CountRecordings = 5, 'Missing file hidden');
    Check(Integer(Index.Connection.ExecSQLScalar('select count(*) from trips')) = 6, 'Missing metadata preserved');
    Node := Tree.GetFirst;
    Check(RecordingNodeCaption(Node) = 'B38M', 'Aircraft folders by newest descendant');
    Check(RecordingNodeImage(Tree, Node) = 29, 'Closed folder icon');
    Check(RecordingNodeCaption(Node.FirstChild) = 'EPLL', 'Airport folders by newest descendant');
    Node := Node.FirstChild.FirstChild;
    Check(RecordingNodeCaption(Node) = '2026', 'Years newest first');
    Check(RecordingNodeCaption(Node.FirstChild) = 'październik', 'Localized full month');
    Node := Node.FirstChild.FirstChild;
    Check(RecordingNodeID(Node) = 4, 'Newest recording first');
    Check(RecordingNodeImage(Tree, Node) = 63, 'Recording icon');
    Check(Pos('2026-10-21 03:04:05', RecordingNodeCaption(Node)) > 0, 'Zero-padded timestamp');
    Check(Pos('[', RecordingNodeCaption(Node)) = 1, 'Active recording prefix');
    Check(Tree.IsDisabled[Node], 'Active node is really disabled');
    Check(Not Tree.IsDisabled[Node.NextSibling], 'Completed node enabled');
    Check(RecordingNodeID(Node.NextSibling) = 6, 'Adjacent recording order');
    Tree.FocusedNode := Node.NextSibling;
    Fill(1, '', 'de-DE');
    Check(CountRecordings = 4, 'Group filter');
    Check(RecordingNodeID(Tree.FocusedNode) = 6, 'Selection retained on refresh');
    Check(RecordingNodeCaption(Tree.GetFirst.FirstChild.FirstChild.FirstChild) = 'Oktober', 'German month');
    Fill(0, 'FENIX', 'en-GB');
    Check(CountRecordings = 1, 'Case-insensitive search');
    Check(RecordingNodeCaption(Tree.GetFirst) = 'A320', 'Search removes empty folders');
    Fill(1, 'FENIX', 'en-US');
    Check(CountRecordings = 0, 'Combined group and search');
    Fill(0, '', 'en-US');
    Check(CountRecordings = 5, 'Blank group and search reset');
    Fill(0, '', 'ar-SA');
    Check(RecordingNodeCaption(Tree.GetFirst.FirstChild.FirstChild.FirstChild) = 'أكتوبر', 'Arabic Gregorian month');
    Fill(0, '', 'he-IL');
    Check(RecordingNodeCaption(Tree.GetFirst.FirstChild.FirstChild.FirstChild) = 'אוקטובר', 'Hebrew Gregorian month');
    System.Writeln('PASS: complete tree ordering, localized months, icons, timestamps, active prefix, search, groups, missing files, selection.');
   Finally
    Host.Free;
    q.Free;
    Index.Free;
   End;
  Except
   On e : Exception Do
    Begin
     System.Writeln(e.ClassName + ': ' + e.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyRecordingTreeTests);
End.
