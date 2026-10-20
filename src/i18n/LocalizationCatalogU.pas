Unit LocalizationCatalogU;

Interface

 Uses
  i18nLocalizer;

 Type
  TApplicationLocalizer = Class(TLocalizer)
   Public
    Property Catalog;
  End;

 Function ApplicationCatalogFile : String;
 Procedure LoadApplicationCatalog(Localizer : TApplicationLocalizer);

Implementation

 Uses
  System.SysUtils, System.IOUtils, Winapi.ActiveX, Winapi.Windows;

 Function ApplicationCatalogFile : String;
  Const
   FileName = 'MSFS2024-FDR.i18n';
  Var
   Base : String;
  Begin
   Base   := ExtractFilePath(ParamStr(0));
   Result := TPath.Combine(Base, FileName);
   // Development/test binaries can read the same authoritative source catalog.
   If Not TFile.Exists(Result) Then
    Result := TPath.GetFullPath(TPath.Combine(Base, '..\Translations\' + FileName));
  End;

 Procedure LoadApplicationCatalog(Localizer : TApplicationLocalizer);
  Var
   InitResult : HRESULT;
  Begin
   InitResult := CoInitializeEx(Nil, COINIT_APARTMENTTHREADED);
   Try
    Localizer.Catalog.LoadFromFile(ApplicationCatalogFile);
   Finally
    If (InitResult = S_OK) Or (InitResult = S_FALSE) Then
     CoUninitialize;
   End;
  End;

End.
