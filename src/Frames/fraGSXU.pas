Unit fraGSXU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnList, System.Actions, Vcl.Grids,
  Vcl.DBGrids, Vcl.CheckLst, LocalizationU;

 Type
  TfraGSX = Class(TFrame)
    WindowToolbar              : TToolBar;
    WindowButton               : TToolButton;
    WindowActions              : TActionList;
    aWindow                    : TAction;
    GSXProgressPanel           : TPanel;
    GSXBoardingProgressPanel   : TPanel;
    GSXBoardingProgressLabel   : TLabel;
    GSXBoardingProgress        : TProgressBar;
    GSXBoardingCargoProgress   : TProgressBar;
    GSXDeboardingProgressPanel : TPanel;
    GSXDeboardingProgressLabel : TLabel;
    GSXDeboardingProgress      : TProgressBar;
    GSXDeboardingCargoProgress : TProgressBar;
    GSXRefuelingProgressPanel  : TPanel;
    GSXRefuelingProgressLabel  : TLabel;
    GSXRefuelingProgress       : TProgressBar;
    GSXCateringProgressPanel   : TPanel;
    GSXCateringProgressLabel   : TLabel;
    GSXCateringProgress        : TProgressBar;
    GSXDepartureProgressPanel  : TPanel;
    GSXDepartureProgressLabel  : TLabel;
    GSXDepartureProgress       : TProgressBar;
    GSXDeiceProgressPanel      : TPanel;
    GSXDeiceProgressLabel      : TLabel;
    GSXDeiceProgress           : TProgressBar;
    GSXGrid                    : TStringGrid;
   Private
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
  End;

Implementation
{$R *.dfm}

 Procedure TfraGSX.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

End.
