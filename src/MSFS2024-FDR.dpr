Program MSFSFDR;

uses
  ParameterNamesU in 'Visualization\ParameterNamesU.pas',
  System.SysUtils,
  AppHelpU in 'Core\AppHelpU.pas',
  frmAboutU in 'Forms\frmAboutU.pas' {frmAbout},
  Vcl.Forms,
  LocalizationU in 'i18n\LocalizationU.pas',
  LocalizationCatalogU in 'i18n\LocalizationCatalogU.pas',
  frmAssignGroupU in 'Forms\frmAssignGroupU.pas' {frmAssignGroup},
  frmMainU in 'Forms\frmMainU.pas' {frmMain},
  EventFilterU in 'Recording\EventFilterU.pas',
  LegacyMigrationU in 'Core\LegacyMigrationU.pas',
  FlightAnalysisU in 'Analysis\FlightAnalysisU.pas',
  FlightChartsU in 'Visualization\FlightChartsU.pas',
  FlightDatabaseU in 'Data\FlightDatabaseU.pas',
  FacilitiesU in 'SimConnect\FacilitiesU.pas',
  AppLogU in 'Core\AppLogU.pas',
  FlightMapU in 'Visualization\FlightMapU.pas',
  iFlyDisplaysU in 'Aircraft\iFly\iFlyDisplaysU.pas',
  BoeingFMCValuesU in 'FMC\BoeingFMCValuesU.pas',
  RecorderWorkerU in 'Recording\RecorderWorkerU.pas',
  FlightRecorderU in 'Recording\FlightRecorderU.pas',
  SimConnectClientU in 'SimConnect\SimConnectClientU.pas',
  FlightTelemetryU in 'Telemetry\FlightTelemetryU.pas',
  frmReportU in 'Forms\frmReportU.pas' {frmReport},
  TelemetryCatalogU in 'Telemetry\TelemetryCatalogU.pas',
  FlightPlanU in 'FlightPlan\FlightPlanU.pas',
  frmSettingsU in 'Forms\frmSettingsU.pas' {frmSettings},
  AircraftDataStoreU in 'Data\AircraftDataStoreU.pas',
  AircraftLVarReaderU in 'SimConnect\AircraftLVarReaderU.pas',
  AircraftTelemetryU in 'Telemetry\AircraftTelemetryU.pas',
  AnalysisContextU in 'Analysis\AnalysisContextU.pas',
  FBWCatalogU in 'Aircraft\FBW\FBWCatalogU.pas',
  FBWReaderU in 'Aircraft\FBW\FBWReaderU.pas',
  FDRTypesU in 'Core\FDRTypesU.pas',
  FMCPreflightU in 'FMC\FMCPreflightU.pas',
  FMCScreensU in 'FMC\FMCScreensU.pas',
  FenixCatalogU in 'Aircraft\Fenix\FenixCatalogU.pas',
  FenixReaderU in 'Aircraft\Fenix\FenixReaderU.pas',
  iFlyReaderU in 'Aircraft\iFly\iFlyReaderU.pas',
  iFlySDKCatalogU in 'Aircraft\iFly\iFlySDKCatalogU.pas',
  MetarU in 'Weather\MetarU.pas',
  RouteBridgeU in 'FlightPlan\RouteBridgeU.pas',
  PMDGNG3CatalogU in 'Aircraft\PMDG\PMDGNG3CatalogU.pas',
  PMDGNG3DecodeU in 'Aircraft\PMDG\PMDGNG3DecodeU.pas',
  PMDGNG3ReaderU in 'Aircraft\PMDG\PMDGNG3ReaderU.pas',
  ReportMarkdownU in 'Analysis\ReportMarkdownU.pas',
  FlightPadScreenIPCU in 'FMC\FlightPadScreenIPCU.pas',
  FlightPadScreensU in 'FMC\FlightPadScreensU.pas',
  AirbusMCDUValuesU in 'FMC\AirbusMCDUValuesU.pas',
  OllamaAnalysisU in 'Analysis\OllamaAnalysisU.pas',
  frmTripInfoU in 'Forms\frmTripInfoU.pas' {frmTripInfo},
  AnalysisPrecisionU in 'Analysis\AnalysisPrecisionU.pas',
  AirlinerVarsU in 'Telemetry\AirlinerVarsU.pas',
  AirlinerCatalogU in 'Telemetry\AirlinerCatalogU.pas',
  SimBriefImportU in 'FlightPlan\SimBriefImportU.pas',
  frmSimBriefFrameU in 'Frames\frmSimBriefFrameU.pas' {fraSimBrief: TFrame},
  frmSimBriefU in 'Forms\frmSimBriefU.pas' {frmSimBrief},
  GSXVarsU in 'Telemetry\GSXVarsU.pas',
  FSHudProtocolU in 'FSHud\FSHudProtocolU.pas',
  FSHudClientU in 'FSHud\FSHudClientU.pas',
  FSHudDataU in 'FSHud\FSHudDataU.pas',
  frmChartsConfigureU in 'Forms\frmChartsConfigureU.pas' {frmChartsConfigure},
  fraMapU in 'Frames\fraMapU.pas' {fraMap: TFrame},
  fraGraphU in 'Frames\fraGraphU.pas' {fraGraph: TFrame},
  frmViewWindowU in 'Forms\frmViewWindowU.pas' {frmViewWindow};

Begin
 Try
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
 Except
  On E : Exception Do
   Begin
    Log(0, 'Startup/shutdown: ' + E.ClassName + ': ' + E.Message);
    Application.ShowException(E);
    ExitCode := 1;
   End;
 End;

End.
