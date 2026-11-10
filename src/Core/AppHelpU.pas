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
   Path  : String;
   Topic : String;
  Begin
   Application.HelpFile := HelpFileName;
   CallHelp             := FileExists(Application.HelpFile);
   Result               := Not CallHelp;
   If CallHelp Then
    Exit;
   Case Data Of
    200                : Topic := 'map';
    300                : Topic := 'charts';
    400                : Topic := 'analysis';
    500                : Topic := 'settings';
    600                : Topic := 'about';
    310                : Topic := 'chart-options';
    510                : Topic := 'settings-general';
    520                : Topic := 'settings-units';
    530                : Topic := 'settings-analysis';
    540, 541, 542, 543 : Topic := 'settings-ai';
    550                : Topic := 'settings-instruments';
    560, 1500          : Topic := 'ghost';
    610                : Topic := 'release';
    700                : Topic := 'instruments';
    710, 711           : Topic := 'boeing';
    720                : Topic := 'engines';
    730, 731           : Topic := 'airbus';
    800                : Topic := 'fmc';
    900                : Topic := 'simbrief';
    1000               : Topic := 'flight-plan';
    1100               : Topic := 'atc';
    1200               : Topic := 'gsx';
    1300               : Topic := 'weather';
    1400, 1410, 1420   : Topic := 'recordings';
    1600               : Topic := 'workspace';
    1700, 1710, 1720   : Topic := 'data';
    1800               : Topic := 'playback';
    733                : Topic := 'a320-ewd';
    739                : Topic := 'ecam-recorded';
    740                : Topic := 'ecam-engine';
    741                : Topic := 'ecam-bleed';
    742                : Topic := 'ecam-press';
    743                : Topic := 'ecam-elec';
    744                : Topic := 'ecam-hyd';
    745                : Topic := 'ecam-fuel';
    746                : Topic := 'ecam-apu';
    747                : Topic := 'ecam-cond';
    748                : Topic := 'ecam-door';
    749                : Topic := 'ecam-wheel';
    750                : Topic := 'ecam-fctl';
    751                : Topic := 'ecam-sts';
    752                : Topic := 'ecam-cruise';
   Else Topic := 'overview';
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
