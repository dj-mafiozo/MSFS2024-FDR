{$StackFrames On}
Unit frmAboutU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, LocalizationU, i18nLocalizer,
  i18nCore;

 Type
  TfrmAbout = Class(TLocalizedForm)
   Published
    lName         : TLabel;
    lVersion      : TLabel;
    lCopyright    : TLabel;
    lTechnology   : TLabel;
    lDescription  : TLabel;
    lAttribution  : TLabel;
    lLicense      : TLabel;
    btnUpstream   : TButton;
    btnHelp       : TButton;
    btnClose      : TButton;
    AppTranslator : TTranslator;
    Procedure RefreshVersion(Sender : TObject);
    Procedure ProjectClick(Sender : TObject);
    Procedure HelpClick(Sender : TObject);
   Public
    Constructor Create(AOwner : TComponent); Override;
  End;

Implementation

 Uses
  Winapi.Windows, Winapi.ShellAPI, AppHelpU, VersionU, System.SysUtils;

 {$R *.dfm}

 Constructor TfrmAbout.Create(AOwner : TComponent);
  Begin
   Inherited;
   RefreshVersion(Self);
  End;

 Procedure TfrmAbout.RefreshVersion(Sender : TObject);
  Begin
   If Not VersionInfo.Available Then
    Begin
     lVersion.Caption   := '';
     lCopyright.Caption := '';
     Exit;
    End;
   lVersion.Caption   := Tr('Wersja') + ' ' + VersionInfo.FileVersion;
   lCopyright.Caption := VersionInfo.LegalCopyright;
   If VersionInfo.ProductName <> '' Then
    lDescription.Caption := VersionInfo.ProductName;
  End;

 Procedure TfrmAbout.ProjectClick(Sender : TObject);
  Begin
   ShellExecute(Handle, 'open', 'https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder', Nil, Nil, SW_SHOWNORMAL);
  End;

 Procedure TfrmAbout.HelpClick(Sender : TObject);
  Begin
   ShowAppHelp(Self);
  End;

End.
