Unit frmChartsConfigureU;

Interface

 Uses
  System.Classes, System.SysUtils, System.Types, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.CheckLst, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls, Vcl.ImgList,
  System.Actions, System.ImageList, Vcl.ActnList,
  LocalizationU, i18nLocalizer, i18nCore, Vcl.Buttons, Vcl.Graphics, System.Math;

 Type
  TfrmChartsConfigure = Class(TLocalizedForm)
   Published
    aAccept          : TAction;
    aCancel          : TAction;
    ActionList       : TActionList;
    aHide            : TAction;
    aMoveDown        : TAction;
    aMoveFirst       : TAction;
    aMoveLast        : TAction;
    aMoveUp          : TAction;
    AppTranslator    : TTranslator;
    aShow            : TAction;
    btnCancel        : TButton;
    btnHide          : TSpeedButton;
    btnMoveDown      : TSpeedButton;
    btnMoveFirst     : TSpeedButton;
    btnMoveLast      : TSpeedButton;
    btnMoveUp        : TSpeedButton;
    btnOk            : TButton;
    btnShow          : TSpeedButton;
    ButtonPanel      : TPanel;
    ChartOrderList   : TListBox;
    eSearch          : TEdit;
    GraphButtonPanel : TPanel;
    ImageList        : TImageList;
    ListPanel        : TPanel;
    MainPanel        : TPanel;
    ParameterList    : TCheckListBox;
    Separator        : TPanel;
    Splitter1        : TSplitter;
    VisiblePanel     : TPanel;
    Procedure FormResize(Sender : TObject);
    Procedure ActionsUpdate(Action : TBasicAction; Var Handled : Boolean);
    Procedure AcceptExecute(Sender : TObject);
    Procedure CancelExecute(Sender : TObject);
    Procedure SearchChange(Sender : TObject);
    Procedure ParameterCheck(Sender : TObject);
    Procedure MoveChart(Sender : TObject);
    Procedure HideChart(Sender : TObject);
    Procedure ShowChart(Sender : TObject);
    Procedure OrderClick(Sender : TObject);
    Procedure ButtonsResize(Sender : TObject);
    Procedure NamesChanged(Sender : TObject);
    Procedure ParameterHint(Sender : TObject; Shift : TShiftState; X, Y : Integer);
    Procedure aMoveFirstExecute(Sender : TObject);
    Procedure aMoveLastExecute(Sender : TObject);
    Procedure aShowExecute(Sender : TObject);
   Private
    fSplitRatio : Double;
    fAvailable : TStringList;
    fSelected  : TStringList;
    fUpdating  : Boolean;
    Procedure SplitterMoved(Sender : TObject);
    Procedure PrepareButtonGlyphs;
    Function RawName(Items : TStrings; Index : Integer) : String;
    Procedure RebuildParameters;
    Procedure RebuildOrder(Const SelectedName : String = '');
    Procedure UpdateButtons;
   Public
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure Configure(Available, Selected : TStrings);
    Procedure CopySelectionTo(Destination : TStrings);
  End;

Implementation

 Uses
  ParameterNamesU;

 {$R *.dfm}

 Constructor TfrmChartsConfigure.Create(AOwner : TComponent);
  Begin
   Inherited;
   fAvailable := TStringList.Create;
   fSelected  := TStringList.Create;
   SplitterMoved(Self);
   Splitter1.OnMoved := SplitterMoved;
   PrepareButtonGlyphs;
   FormResize(Self);
   UpdateButtons;
  End;

 Destructor TfrmChartsConfigure.Destroy;
  Begin
   fSelected.Free;
   fAvailable.Free;
   Inherited;
  End;

 Procedure TfrmChartsConfigure.SplitterMoved(Sender : TObject);
  Var
   AvailableWidth : Integer;
  Begin
   AvailableWidth := MainPanel.ClientWidth - Splitter1.Width - GraphButtonPanel.Width;
   If AvailableWidth > 0 Then
    fSplitRatio := ListPanel.Width / AvailableWidth;
  End;

 Procedure TfrmChartsConfigure.PrepareButtonGlyphs;
  Var
   Button : TSpeedButton;
   Buttons : TArray<TSpeedButton>;
   Bitmap : TBitmap;
  Begin
   // Delphi 10.2 copies the action image to TSpeedButton.Glyph without
   // preserving alpha correctly. Composite once, then use its colour key.
   Bitmap := TBitmap.Create;
   Try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.SetSize(ImageList.Width, ImageList.Height);
    Buttons := TArray<TSpeedButton>.Create(btnMoveFirst, btnMoveUp, btnMoveDown, btnMoveLast, btnShow, btnHide);
    For Button In Buttons Do
     Begin
      Bitmap.Canvas.Brush.Color := clBtnFace;
      Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));
      ImageList.Draw(Bitmap.Canvas, 0, 0, TAction(Button.Action).ImageIndex, True);
      Bitmap.TransparentColor := clBtnFace;
      Bitmap.Transparent := True;
      Button.Glyph.Assign(Bitmap);
      Button.NumGlyphs := 1;
      Button.Caption := '';
      Button.ShowHint := True;
     End;
   Finally
    Bitmap.Free;
   End;
  End;

 Procedure TfrmChartsConfigure.FormResize(Sender : TObject);
  Var
   AvailableWidth, MinimumWidth : Integer;
  Begin
   If (MainPanel = Nil) Or (GraphButtonPanel = Nil) Or (Separator = Nil) Then
    Exit;
   If fSplitRatio > 0 Then
    Begin
     AvailableWidth := MainPanel.ClientWidth - Splitter1.Width - GraphButtonPanel.Width;
     MinimumWidth := Min(120, Max(0, AvailableWidth Div 2));
     ListPanel.Width := EnsureRange(Round(AvailableWidth * fSplitRatio), MinimumWidth,
       Max(MinimumWidth, AvailableWidth - MinimumWidth));
    End;
   Separator.Height := Max(0, (GraphButtonPanel.Height - 192) Div 2);
  End;

 Procedure TfrmChartsConfigure.Configure(Available, Selected : TStrings);
  Var
   Name : String;
  Begin
   fAvailable.Assign(Available);
   fSelected.Clear;
   For Name In Selected Do
    If fSelected.IndexOf(Name) < 0 Then
     fSelected.Add(Name);
   eSearch.Clear;
   RebuildParameters;
   RebuildOrder;
  End;

 Procedure TfrmChartsConfigure.CopySelectionTo(Destination : TStrings);
  Begin
   Destination.Assign(fSelected);
  End;

 Function TfrmChartsConfigure.RawName(Items : TStrings; Index : Integer) : String;
  Var
   AvailableIndex : Integer;
  Begin
   Result := '';
   If (Index < 0) Or (Index >= Items.Count) Then
    Exit;
   AvailableIndex := Integer(NativeInt(Items.Objects[Index])) - 1;
   If (AvailableIndex >= 0) And (AvailableIndex < fAvailable.Count) Then
    Result := fAvailable[AvailableIndex];
  End;

 Procedure TfrmChartsConfigure.NamesChanged(Sender : TObject);
  Var
   Name : String;
  Begin
   If fAvailable = Nil Then
    Exit;
   PrepareButtonGlyphs;
   Name := RawName(ChartOrderList.Items, ChartOrderList.ItemIndex);
   RebuildParameters;
   RebuildOrder(Name);
  End;

 Procedure TfrmChartsConfigure.ParameterHint(Sender : TObject; Shift : TShiftState; X, Y : Integer);
  Var
   Name : String;
   I    : Integer;
  Begin
   If Sender = ParameterList Then
    Begin
     I    := ParameterList.ItemAtPos(Point(X, Y), True);
     Name := RawName(ParameterList.Items, I);
    End
   Else
    Begin
     I    := ChartOrderList.ItemAtPos(Point(X, Y), True);
     Name := RawName(ChartOrderList.Items, I);
    End;
   If Name <> '' Then
    TControl(Sender).Hint := ParameterCaption(Name) + sLineBreak + Name
   Else
    TControl(Sender).Hint := '';
  End;

 Procedure TfrmChartsConfigure.RebuildParameters;
  Var
   Name, Filter, Caption, SelectedName : String;
   I, Index                            : Integer;
  Begin
   If fAvailable = Nil Then
    Exit;
   SelectedName := RawName(ParameterList.Items, ParameterList.ItemIndex);
   fUpdating    := True;
   ParameterList.Items.BeginUpdate;
   Try
    Filter := LowerCase(Trim(eSearch.Text));
    ParameterList.Items.Clear;
    For Index := 0 To fAvailable.Count - 1 Do
     Begin
      Name    := fAvailable[Index];
      Caption := ParameterCaption(Name);
      If (Filter = '') Or (Pos(Filter, LowerCase(Name)) > 0) Or (Pos(Filter, LowerCase(Caption)) > 0) Then
       Begin
        I                        := ParameterList.Items.AddObject(Caption, TObject(NativeInt(Index + 1)));
        ParameterList.Checked[I] := fSelected.IndexOf(Name) >= 0;
        If Name = SelectedName Then
         ParameterList.ItemIndex := I;
       End;
     End;
   Finally
    ParameterList.Items.EndUpdate;
    fUpdating := False;
   End;
  End;

 Procedure TfrmChartsConfigure.RebuildOrder(Const SelectedName : String);
  Var
   Name : String;
  Begin
   ChartOrderList.Items.BeginUpdate;
   Try
    ChartOrderList.Items.Clear;
    For Name In fSelected Do
     If fAvailable.IndexOf(Name) >= 0 Then
      ChartOrderList.Items.AddObject(ParameterCaption(Name), TObject(NativeInt(fAvailable.IndexOf(Name) + 1)));
    ChartOrderList.ItemIndex := ChartOrderList.Items.IndexOfObject(TObject(NativeInt(fAvailable.IndexOf(SelectedName) + 1)));
   Finally
    ChartOrderList.Items.EndUpdate;
   End;
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.ParameterCheck(Sender : TObject);
  Var
   I, P : Integer;
   Name : String;
  Begin
   If fUpdating Or (fSelected = Nil) Then
    Exit;
   I := ParameterList.ItemIndex;
   If I < 0 Then
    Exit;
   Name := RawName(ParameterList.Items, I);
   P    := fSelected.IndexOf(Name);
   If ParameterList.Checked[I] Then
    Begin
     If P < 0 Then
      fSelected.Add(Name);
    End
   Else If P >= 0 Then
    fSelected.Delete(P);
   RebuildOrder(Name);
  End;

 Procedure TfrmChartsConfigure.SearchChange(Sender : TObject);
  Begin
   RebuildParameters;
  End;

 Procedure TfrmChartsConfigure.MoveChart(Sender : TObject);
  Var
   I    : Integer;
   j    : Integer;
   a    : Integer;
   b    : Integer;
   Name : String;
  Begin
   I := ChartOrderList.ItemIndex;
   If I < 0 Then
    Exit;
   j := I + 1;
   If (Sender = btnMoveUp) Or (Sender = aMoveUp) Then
    j := I - 1
   Else If (Sender = btnMoveFirst) Or (Sender = aMoveFirst) Then
    j := 0
   Else If (Sender = btnMoveLast) Or (Sender = aMoveLast) Then
    j := ChartOrderList.Count - 1;
   If (j < 0) Or (j >= ChartOrderList.Count) Then
    Exit;
   Name := RawName(ChartOrderList.Items, I);
   a    := fSelected.IndexOf(Name);
   b    := fSelected.IndexOf(RawName(ChartOrderList.Items, j));
   fSelected.Move(a, b);
   RebuildOrder(Name);
  End;

 Procedure TfrmChartsConfigure.ShowChart(Sender : TObject);
  Var
   I : Integer;
  Begin
   I := ParameterList.ItemIndex;
   If I < 0 Then
    Exit;
   ParameterList.Checked[I] := True;
   ParameterCheck(ParameterList);
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.HideChart(Sender : TObject);
  Var
   I : Integer;
  Begin
   I := ChartOrderList.ItemIndex;
   If I < 0 Then
    Exit;
   fSelected.Delete(fSelected.IndexOf(RawName(ChartOrderList.Items, I)));
   RebuildParameters;
   RebuildOrder;
   If ChartOrderList.Count > 0 Then
    Begin
     If I >= ChartOrderList.Count Then
      I                       := ChartOrderList.Count - 1;
     ChartOrderList.ItemIndex := I;
    End;
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.UpdateButtons;
  Var
   I : Integer;
  Begin
   If (ChartOrderList = Nil) Or (aMoveUp = Nil) Or (aMoveDown = Nil) Or (aHide = Nil) Then
    Exit;
   I                 := ChartOrderList.ItemIndex;
   aMoveUp.Enabled   := I > 0;
   aMoveDown.Enabled := (I >= 0) And (I < ChartOrderList.Count - 1);
   aHide.Enabled     := I >= 0;
  End;

 Procedure TfrmChartsConfigure.OrderClick(Sender : TObject);
  Begin
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.ActionsUpdate(Action : TBasicAction; Var Handled : Boolean);
  Begin
   UpdateButtons;
   Handled := (Action = aMoveUp) Or (Action = aMoveDown) Or (Action = aHide) Or (Action = aMoveFirst) Or (Action = aMoveLast) Or (Action = aShow);
  End;

 Procedure TfrmChartsConfigure.aMoveFirstExecute(Sender : TObject);
  Begin
   MoveChart(Sender);
  End;

 Procedure TfrmChartsConfigure.aMoveLastExecute(Sender : TObject);
  Begin
   MoveChart(Sender);
  End;

 Procedure TfrmChartsConfigure.aShowExecute(Sender : TObject);
  Begin
   ShowChart(Sender);
  End;

 Procedure TfrmChartsConfigure.AcceptExecute(Sender : TObject);
  Begin
   ModalResult := mrOk;
  End;

 Procedure TfrmChartsConfigure.CancelExecute(Sender : TObject);
  Begin
   ModalResult := mrCancel;
  End;

 Procedure TfrmChartsConfigure.ButtonsResize(Sender : TObject);
  Begin
   If (btnOk = Nil) Or (btnCancel = Nil) Then
    Exit;
   btnOk.Left     := (ButtonPanel.ClientWidth - btnOk.Width - btnCancel.Width - 8) Div 2;
   btnCancel.Left := btnOk.Left + btnOk.Width + 8;
  End;

End.
