{$StackFrames On}
Unit AppHelpU;

Interface

 Uses
  Vcl.Controls, Vcl.Forms, System.Classes;

 Function HelpContextFor(Control : TControl) : Integer;
 Function HelpFileName : String;
 Function RouteAppHelp(Command : Word; Data : THelpEventData; Var CallHelp : Boolean) : Boolean;
 Procedure ShowAppHelp(Control : TControl);

Implementation

 Uses
  System.SysUtils, System.IOUtils, Winapi.Windows, Winapi.ShellAPI,
  Vcl.HtmlHelpViewer, LocalizationU;

 Function HelpContextFor(Control : TControl) : Integer;
  Begin
   If Control = Nil Then
    Control := Screen.ActiveForm;
   While Control <> Nil Do
    Begin
     If Control.HelpContext > 0 Then
      Exit(Control.HelpContext);
     Control := Control.Parent;
    End;
   Result := 100;
  End;

 Function HelpFileName : String;
  Begin
   Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'help\MSFS2024-FDR.' + Copy(Language, 1, 2) + '.chm');
   If Not FileExists(Result) Then
    Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'help\MSFS2024-FDR.en.chm');
  End;

 Function RouteAppHelp(Command : Word; Data : THelpEventData; Var CallHelp : Boolean) : Boolean;
  Var
   Path, Topic : String;
  Begin
   Application.HelpFile := HelpFileName;
   CallHelp             := FileExists(Application.HelpFile);
   Result               := Not CallHelp;
   If CallHelp Then
    Exit;
   Case Data Of
    200 :
     Topic := 'map';
    300 :
     Topic := 'charts';
    400 :
     Topic := 'analysis';
    500 :
     Topic := 'settings';
    600 :
     Topic := 'about';
    Else
     Topic := 'overview';
   End;
   Path := TPath.Combine(ExtractFilePath(ParamStr(0)), 'help\' + Copy(Language, 1, 2) + '\' + Topic + '.htm');
   If Not FileExists(Path) Then
    Path := TPath.Combine(ExtractFilePath(ParamStr(0)), '..\help\' + Copy(Language, 1, 2) + '\' + Topic + '.htm');
   If Not FileExists(Path) Then
    Path := TPath.Combine(ExtractFilePath(ParamStr(0)), 'help\en\' + Topic + '.htm');
   If FileExists(Path) Then
    ShellExecute(0, 'open', PChar(Path), Nil, Nil, SW_SHOWNORMAL);
  End;

 Procedure ShowAppHelp(Control : TControl);
  Begin
   Application.HelpContext(HelpContextFor(Control));
  End;

End.
