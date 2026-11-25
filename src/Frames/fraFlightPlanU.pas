Unit fraFlightPlanU;

Interface

 Uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnList, System.Actions, Vcl.Grids,
  Vcl.DBGrids, Vcl.CheckLst, LocalizationU;

 Type
  TfraFlightPlan = Class(TFrame)
    WindowToolbar : TToolBar;
    WindowButton  : TToolButton;
    WindowActions : TActionList;
    aWindow       : TAction;
    mPlan         : TMemo;
    ToolBar5      : TToolBar;
    ToolButton7   : TToolButton;
   Private
    fLocalized : Boolean;
   Protected
    Procedure SetParent(AParent : TWinControl); Override;
  End;

Implementation
{$R *.dfm}

 Procedure TfraFlightPlan.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

End.
