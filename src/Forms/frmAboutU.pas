Unit frmAboutU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, LocalizationU, i18nLocalizer;

 Type
  TfrmAbout = Class(TLocalizedForm)
   Published
    lName : TLabel;
    lTechnology : TLabel;
    lDescription : TLabel;
    lAttribution : TLabel;
    lLicense : TLabel;
    btnUpstream : TButton;
    btnHelp : TButton;
    btnClose : TButton;
    AppTranslator : TTranslator;
    Procedure ProjectClick(Sender : TObject);
    Procedure HelpClick(Sender : TObject);
  End;

Implementation

 Uses Winapi.Windows, Winapi.ShellAPI, AppHelpU;

 {$R *.dfm}

 Procedure TfrmAbout.ProjectClick(Sender : TObject);
  Begin
   ShellExecute(Handle, 'open', 'https://github.com/MichaelHsu170/MSFS-Flight-Data-Recorder', Nil, Nil, SW_SHOWNORMAL);
  End;

 Procedure TfrmAbout.HelpClick(Sender : TObject);
  Begin
   ShowAppHelp(Self);
  End;

End.
