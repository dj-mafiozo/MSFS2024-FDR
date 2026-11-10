{$StackFrames On}
Program MSFSFDR;

Uses
 StackTrace,
 Winapi.Windows,
 System.SysUtils,
 Vcl.Forms,
 SimulatorPackagesU   In 'Core\SimulatorPackagesU.pas',
 FSLTLU               In 'Visualization\FSLTLU.pas',
 NativeATCU           In 'SimConnect\NativeATCU.pas',
 GhostReplayU         In 'Visualization\GhostReplayU.pas',
 B38MEICASU           In 'Visualization\B38MEICASU.pas',
 Boeing737PFDU        In 'Visualization\Boeing737PFDU.pas',
 fraB38MEICASU        In 'Frames\fraB38MEICASU.pas'      {fraB38MEICAS: TFrame},
 PFDScalesU           In 'Visualization\PFDScalesU.pas',
 AirbusDataU          In 'Visualization\AirbusDataU.pas',
 SimWeatherU          In 'Weather\SimWeatherU.pas',
 MetarDecodeU         In 'Weather\MetarDecodeU.pas',
 frmWeatherU          In 'Forms\frmWeatherU.pas'         {frmWeather},
 PanelProportionsU    In 'Visualization\PanelProportionsU.pas',
 InstrumentRenderU    In 'Visualization\InstrumentRenderU.pas',
 DockPreviewU         In 'Visualization\DockPreviewU.pas',
 frmDockViewU         In 'Forms\frmDockViewU.pas'        {frmDockView},
 FSHudReplayU         In 'FSHud\FSHudReplayU.pas',
 PlaybackU            In 'Visualization\PlaybackU.pas',
 PFDReadoutsU         In 'Visualization\PFDReadoutsU.pas',
 PFDMinimaU           In 'Visualization\PFDMinimaU.pas',
 FlightDirectorU      In 'Visualization\FlightDirectorU.pas',
 iFlyFMAU             In 'Visualization\iFlyFMAU.pas',
 ProcedureRouteU      In 'FlightPlan\ProcedureRouteU.pas',
 AirbusFMAU           In 'Visualization\AirbusFMAU.pas',
 AirbusMessagesU      In 'Visualization\AirbusMessagesU.pas',
 AirbusDisplayU       In 'Visualization\AirbusDisplayU.pas',
 AirbusPFDU           In 'Visualization\AirbusPFDU.pas',
 AirbusECAMU          In 'Visualization\AirbusECAMU.pas',
 fraA320PFDU          In 'Frames\fraA320PFDU.pas'        {fraA320PFD: TFrame},
 fraA320ECAMU         In 'Frames\fraA320ECAMU.pas'       {fraA320ECAM: TFrame},
 fraPFD737U           In 'Frames\fraPFD737U.pas'         {fraPFD737: TFrame},
 InstrumentDataU      In 'Visualization\InstrumentDataU.pas',
 EngineGaugesU        In 'Visualization\EngineGaugesU.pas',
 fraEnginesU          In 'Frames\fraEnginesU.pas'        {fraEngines: TFrame},
 ViewStateU           In 'Core\ViewStateU.pas',
 SixPackU             In 'Visualization\SixPackU.pas',
 fraSixPackU          In 'Frames\fraSixPackU.pas'        {fraSixPack: TFrame},
 AddonLVarTypesU      In 'Aircraft\AddonLVarTypesU.pas',
 SimVarSelectionU     In 'Telemetry\SimVarSelectionU.pas',
 AsoboBell407LVarsU   In 'Aircraft\AsoboBell407\AsoboBell407LVarsU.pas',
 AsoboEC135LVarsU     In 'Aircraft\AsoboEC135\AsoboEC135LVarsU.pas',
 CSS737LVarsU         In 'Aircraft\CSS737\CSS737LVarsU.pas',
 MaddogXLVarsU        In 'Aircraft\MaddogX\MaddogXLVarsU.pas',
 SkySimDC9LVarsU      In 'Aircraft\SkySimDC9\SkySimDC9LVarsU.pas',
 SkySimMD11LVarsU     In 'Aircraft\SkySimMD11\SkySimMD11LVarsU.pas',
 TFDiMD11LVarsU       In 'Aircraft\TFDiMD11\TFDiMD11LVarsU.pas',
 PMDG777CatalogU      In 'Aircraft\PMDG\PMDG777CatalogU.pas',
 PMDG777ReaderU       In 'Aircraft\PMDG\PMDG777ReaderU.pas',
 PMDG777DecodeU       In 'Aircraft\PMDG\PMDG777DecodeU.pas',
 AddonLVarCatalogU    In 'Aircraft\AddonLVarCatalogU.pas',
 FMCStyleU            In 'FMC\FMCStyleU.pas',
 AppPathsU            In 'Core\AppPathsU.pas',
 FMCReplayU           In 'FMC\FMCReplayU.pas',
 fraFMCU              In 'Frames\fraFMCU.pas'            {fraFMC: TFrame},
 UIFontsU             In 'i18n\UIFontsU.pas',
 VersionU             In 'Common\VersionU.pas',
 FlapsHandleU         In 'Visualization\FlapsHandleU.pas',
 ParameterNamesU      In 'Visualization\ParameterNamesU.pas',
 AppHelpU             In 'Core\AppHelpU.pas',
 frmAboutU            In 'Forms\frmAboutU.pas'           {frmAbout},
 LocalizationU        In 'i18n\LocalizationU.pas',
 LocalizationCatalogU In 'i18n\LocalizationCatalogU.pas',
 frmAssignGroupU      In 'Forms\frmAssignGroupU.pas'     {frmAssignGroup},
 frmMainU             In 'Forms\frmMainU.pas'            {frmMain},
 EventFilterU         In 'Recording\EventFilterU.pas',
 LegacyMigrationU     In 'Core\LegacyMigrationU.pas',
 FlightAnalysisU      In 'Analysis\FlightAnalysisU.pas',
 FlightChartsU        In 'Visualization\FlightChartsU.pas',
 RecordingTreeU       In 'Visualization\RecordingTreeU.pas',
 RecordingIndexU      In 'Data\RecordingIndexU.pas',
 LegacyExportU        In 'Data\LegacyExportU.pas',
 FlightDatabaseU      In 'Data\FlightDatabaseU.pas',
 FacilitiesU          In 'SimConnect\FacilitiesU.pas',
 AppLogU              In 'Core\AppLogU.pas',
 FlightMapU           In 'Visualization\FlightMapU.pas',
 iFlyDisplaysU        In 'Aircraft\iFly\iFlyDisplaysU.pas',
 BoeingFMCValuesU     In 'FMC\BoeingFMCValuesU.pas',
 RecorderWorkerU      In 'Recording\RecorderWorkerU.pas',
 FlightRecorderU      In 'Recording\FlightRecorderU.pas',
 SimConnectClientU    In 'SimConnect\SimConnectClientU.pas',
 FlightTelemetryU     In 'Telemetry\FlightTelemetryU.pas',
 frmReportU           In 'Forms\frmReportU.pas'          {frmReport},
 TelemetryCatalogU    In 'Telemetry\TelemetryCatalogU.pas',
 FlightPlanU          In 'FlightPlan\FlightPlanU.pas',
 frmSettingsU         In 'Forms\frmSettingsU.pas'        {frmSettings},
 AircraftDataStoreU   In 'Data\AircraftDataStoreU.pas',
 AircraftLVarReaderU  In 'SimConnect\AircraftLVarReaderU.pas',
 AircraftTelemetryU   In 'Telemetry\AircraftTelemetryU.pas',
 AnalysisContextU     In 'Analysis\AnalysisContextU.pas',
 FBWCatalogU          In 'Aircraft\FBW\FBWCatalogU.pas',
 FBWReaderU           In 'Aircraft\FBW\FBWReaderU.pas',
 FDRTypesU            In 'Core\FDRTypesU.pas',
 FMCPreflightU        In 'FMC\FMCPreflightU.pas',
 FMCScreensU          In 'FMC\FMCScreensU.pas',
 FenixCatalogU        In 'Aircraft\Fenix\FenixCatalogU.pas',
 FenixReaderU         In 'Aircraft\Fenix\FenixReaderU.pas',
 iFlyReaderU          In 'Aircraft\iFly\iFlyReaderU.pas',
 iFlySDKCatalogU      In 'Aircraft\iFly\iFlySDKCatalogU.pas',
 MetarU               In 'Weather\MetarU.pas',
 RouteBridgeU         In 'FlightPlan\RouteBridgeU.pas',
 PMDGNG3CatalogU      In 'Aircraft\PMDG\PMDGNG3CatalogU.pas',
 PMDGNG3DecodeU       In 'Aircraft\PMDG\PMDGNG3DecodeU.pas',
 PMDGNG3ReaderU       In 'Aircraft\PMDG\PMDGNG3ReaderU.pas',
 ReportMarkdownU      In 'Analysis\ReportMarkdownU.pas',
 FlightPadScreenIPCU  In 'FMC\FlightPadScreenIPCU.pas',
 FlightPadScreensU    In 'FMC\FlightPadScreensU.pas',
 AirbusMCDUValuesU    In 'FMC\AirbusMCDUValuesU.pas',
 OllamaAnalysisU      In 'Analysis\OllamaAnalysisU.pas',
 frmTripInfoU         In 'Forms\frmTripInfoU.pas'        {frmTripInfo},
 AnalysisPrecisionU   In 'Analysis\AnalysisPrecisionU.pas',
 AirlinerVarsU        In 'Telemetry\AirlinerVarsU.pas',
 AirlinerCatalogU     In 'Telemetry\AirlinerCatalogU.pas',
 SimBriefImportU      In 'FlightPlan\SimBriefImportU.pas',
 SimBriefMapsU        In 'FlightPlan\SimBriefMapsU.pas',
 fraSimBriefMapU      In 'Frames\fraSimBriefMapU.pas'    {fraSimBriefMap: TFrame},
 frmSimBriefFrameU    In 'Frames\frmSimBriefFrameU.pas'  {fraSimBrief: TFrame},
 frmSimBriefU         In 'Forms\frmSimBriefU.pas'        {frmSimBrief},
 GSXVarsU             In 'Telemetry\GSXVarsU.pas',
 FSHudProtocolU       In 'FSHud\FSHudProtocolU.pas',
 FSHudClientU         In 'FSHud\FSHudClientU.pas',
 FSHudDataU           In 'FSHud\FSHudDataU.pas',
 frmChartsConfigureU  In 'Forms\frmChartsConfigureU.pas' {frmChartsConfigure},
 fraMapU              In 'Frames\fraMapU.pas'            {fraMap: TFrame},
 fraGraphU            In 'Frames\fraGraphU.pas'          {fraGraph: TFrame},
 frmViewWindowU       In 'Forms\frmViewWindowU.pas'      {frmViewWindow},
 MarkdownRichEditU    In 'Visualization\MarkdownRichEditU.pas',
 frmChangeLogU        In 'Forms\frmChangeLogU.pas'       {frmChangeLog},
 PMDGDC6LVarsU        In 'Aircraft\PMDG\PMDGDC6LVarsU.pas';

{$R 'MSFS2024-FDR.res'}

Var
 RunMutex : THandle;

Begin
 Try
  RunMutex := AcquireApplicationMutex;
  If RunMutex = 0 Then
   Exit;
  Try
   If PreviewRecordingArgument = '' Then
    InitializeAppStorage;
   Application.Initialize;
   Application.MainFormOnTaskBar := True;
   Application.CreateForm(TfrmMain, frmMain);
   If FindCmdLineSwitch('ShowChangeLog', ['/'], True) Then
    Begin
     frmMain.Show;
     ShowChangeLog(frmMain);
    End;
   Application.Run;
  Finally
   CloseHandle(RunMutex);
  End;
 Except
  On E : Exception Do
   Begin
    Log(0, 'Startup/shutdown: ' + E.ClassName + ': ' + E.Message);
    If Not E.StackTrace.IsEmpty Then
     Log(0, 'StackTrace = [' + #13#10 + E.StackTrace + #13#10 + ')');
    Application.ShowException(E);
    ExitCode := 1;
   End;
 End;

End.
