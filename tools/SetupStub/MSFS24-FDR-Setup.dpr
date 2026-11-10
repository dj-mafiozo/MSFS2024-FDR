Program MSFS24_FDR_Setup;
{$APPTYPE GUI}

Uses
 Winapi.Windows, Vcl.Forms, Vcl.Dialogs, System.UITypes;
{$R 'MSFS24-FDR-Setup.res'}

Begin
 Application.Initialize;
 If (GetUserDefaultUILanguage And $3FF) = LANG_POLISH Then
  MessageDlg('Trwają prace nad instalatorem, aktualizatorem i deinstalatorem MSFS24-FDR. Obecne wydanie należy rozpakować i uruchomić ręcznie.', mtInformation, [mbOK], 0)
 Else
  MessageDlg('The MSFS24-FDR installer, updater and uninstaller are under development. Extract and run this release manually.', mtInformation, [mbOK], 0);

End.
