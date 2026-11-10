Program VerifyIDEProjectSave;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, System.SysUtils, System.IOUtils, Xml.XMLDoc, Xml.XMLIntf, Xml.xmldom, Xml.omnixmldom, Xml.XMLIniFile;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Var
 Count : Integer;

Procedure SaveCopy(Const Relative : String; IsGroup : Boolean);
 Var
  Doc   : IXMLDocument;
  Again : IXMLDocument;
  Obj   : TXMLDocument;
  Node  : IXMLNode;
  Ini   : TXmlIniFile;
  Dest  : String;
 Begin
  Obj           := TXMLDocument.Create(Nil);
  Obj.DOMVendor := GetDOMVendor('Omni XML');
  Doc           := Obj;
  Doc.LoadFromFile(TestRepositoryPath(Relative));
  Check(Doc.DocumentElement <> Nil, Relative + ': root');
  Node := Doc.DocumentElement.ChildNodes.FindNode('ProjectExtensions');
  Check(Node <> Nil, Relative + ': ProjectExtensions');
  Node := Node.ChildNodes.FindNode('BorlandProject');
  Check(Node <> Nil, Relative + ': BorlandProject');
  If IsGroup Then
   Node := Node.ChildNodes.FindNode('Default.Personality')
  Else
   Node := Node.ChildNodes.FindNode('Delphi.Personality');
  Check(Node <> Nil, Relative + ': IDE personality');
  Ini := TXmlIniFile.Create(Node);
  Try
   Ini.WriteString('FDR_Save_Probe', 'Source', Relative);
   Check(Ini.ReadString('FDR_Save_Probe', 'Source', '') = Relative, 'XmlIniFile round trip');
  Finally
   Ini.Free;
  End;
  Inc(Count);
  Dest := TestDatabasePath('project-save-copy-' + IntToStr(Count) + '.xml');
  Doc.SaveToFile(Dest);
  Doc           := Nil;
  Obj           := TXMLDocument.Create(Nil);
  Obj.DOMVendor := GetDOMVendor('Omni XML');
  Again         := Obj;
  Again.LoadFromFile(Dest);
  Check(Again.DocumentElement.ChildNodes.FindNode('ProjectExtensions') <> Nil, 'Reload');
 End;

Var
 Group : IXMLDocument;
 Obj   : TXMLDocument;
 Items : IXMLNode;
 Item  : IXMLNode;
 i     : Integer;

Type

 [TestFixture]
 TVerifyIDEProjectSaveTests = Class
  Public
   [Test]
   Procedure Regression;
 End;

Procedure TVerifyIDEProjectSaveTests.Regression;
 Begin
  Count := 0;
  SaveCopy('MSFS24 Flight Data Recorder.groupproj', True);
  SaveCopy('tests\Tests.groupproj', True);
  SaveCopy('src\MSFS2024-FDR.dproj', False);
  SaveCopy('..\MSFS2024-FDR-Setup\src\MSFS24-FDR-Setup.dproj', False);
  SaveCopy('..\MSFS2024-FDR-Setup\src\PackageRelease.dproj', False);
  Obj           := TXMLDocument.Create(Nil);
  Obj.DOMVendor := GetDOMVendor('Omni XML');
  Group         := Obj;
  Group.LoadFromFile(TestRepositoryPath('tests\Tests.groupproj'));
  Items := Group.DocumentElement.ChildNodes.FindNode('ItemGroup');
  Check(Items <> Nil, 'Test group items');
  For i := 0 To Items.ChildNodes.Count - 1 Do
   Begin
    Item := Items.ChildNodes[i];
    If Item.NodeName = 'Projects' Then
     SaveCopy('tests\' + String(Item.Attributes['Include']), False);
   End;
  System.Writeln('PASS: ', Count, ' group/project personalities written through TXmlIniFile and reloaded as isolated copies. Actual IDE save not exercised.');

 End;

Begin
 RunNativeTests(TVerifyIDEProjectSaveTests);

End.
