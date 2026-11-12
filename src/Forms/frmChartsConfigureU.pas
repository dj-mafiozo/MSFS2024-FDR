{$StackFrames On}
Unit frmChartsConfigureU;

Interface

 Uses
  System.Classes, System.SysUtils, System.Types, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.CheckLst, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls, Vcl.ImgList,
  System.Actions, System.ImageList, Vcl.ActnList,
  LocalizationU, i18nLocalizer, i18nCore, Vcl.Buttons, Vcl.Graphics, System.Math;

 Type
  TfrmChartsConfigure = Class(TLocalizedForm)
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
    ChartListPanel   : TPanel;
    ChartOrderList   : TListBox;
    DragScrollTimer  : TTimer;
    eSearch          : TEdit;
    GraphButtonPanel : TPanel;
    ImageList        : TImageList;
    lAllParameters   : TLabel;
    lChartsShown     : TLabel;
    ListPanel        : TPanel;
    MainGroupBox     : TGroupBox;
    ParameterList    : TCheckListBox;
    Separator        : TPanel;
    Splitter1        : TSplitter;
    VisiblePanel     : TPanel;
    Procedure AcceptExecute    (Sender : TObject);
    Procedure ActionsUpdate    (Action : TBasicAction; Var Handled : Boolean);
    Procedure aMoveFirstExecute(Sender : TObject);
    Procedure aMoveLastExecute (Sender : TObject);
    Procedure aShowExecute     (Sender : TObject);
    Procedure ButtonsResize    (Sender : TObject);
    Procedure CancelExecute    (Sender : TObject);
    Procedure DragScrollTick   (Sender : TObject);
    Procedure DrawChartItem    (Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
    Procedure FormResize       (Sender : TObject);
    Procedure HideChart        (Sender : TObject);
    Procedure ListDragDrop     (Sender, Source : TObject; x, y : Integer);
    Procedure ListDragOver     (Sender, Source : TObject; x, y : Integer; State : TDragState; Var Accept : Boolean);
    Procedure ListEndDrag      (Sender, Target : TObject; x, y : Integer);
    Procedure ListMouseDown    (Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
    Procedure ListStartDrag    (Sender : TObject; Var DragObject : TDragObject);
    Procedure MoveChart        (Sender : TObject);
    Procedure NamesChanged     (Sender : TObject);
    Procedure OrderClick       (Sender : TObject);
    Procedure ParameterCheck   (Sender : TObject);
    Procedure ParameterHint    (Sender : TObject; Shift : TShiftState; x, y : Integer);
    Procedure SearchChange     (Sender : TObject);
    Procedure ShowChart        (Sender : TObject);
   Private
    fAvailable  : TStringList;
    fDragName   : String;
    fDragSource : TObject;
    fDragTarget : TObject;
    fDropSlot   : Integer;
    fSelected   : TStringList;
    fSplitRatio : Double;
    fUpdating   : Boolean;
    Function  DropAllowed  (Target, Source : TObject)          : Boolean;
    Function  DropSlot     (y : Integer)                       : Integer;
    Function  RawName      (Items : TStrings; Index : Integer) : String;
    Procedure ClearDrag;
    Procedure PrepareButtonGlyphs;
    Procedure RebuildOrder (Const SelectedName : String = '');
    Procedure RebuildParameters;
    Procedure SplitterMoved(Sender : TObject);
    Procedure UpdateButtons;
   Public
    Constructor Create         (AOwner : TComponent); Override;
    Destructor  Destroy; Override;
    Procedure   Configure      (Available, Selected : TStrings);
    Procedure   CopySelectionTo(Destination : TStrings);
  End;

Implementation

 Uses
  ParameterNamesU, Winapi.Windows;

{$R *.dfm}

 Constructor TfrmChartsConfigure.Create(AOwner : TComponent);
  Begin
   Inherited;
   fDropSlot  := -1;
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
   ClearDrag;
   fSelected.Free;
   fAvailable.Free;
   Inherited;
  End;

 Procedure TfrmChartsConfigure.ClearDrag;
  Begin
   If DragScrollTimer <> Nil Then
    DragScrollTimer.Enabled := False;
   fDragSource              := Nil;
   fDragTarget              := Nil;
   fDragName                := '';
   fDropSlot                := -1;
   If ChartOrderList <> Nil Then
    ChartOrderList.Invalidate;
  End;

 Procedure TfrmChartsConfigure.ListMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; x, y : Integer);
  Var
   i : Integer;
  Begin
   If Button <> mbLeft Then
    Exit;
   ClearDrag;
   // Leave the checkbox itself to TCheckListBox's normal click handling.
   If (Sender = ParameterList) And (x < GetSystemMetrics(SM_CXMENUCHECK) + 4) Then
    Exit;
   If Sender = ParameterList Then
    Begin
     i := ParameterList.ItemAtPos(Point(x, y), True);
     If i < 0 Then
      Exit;
     ParameterList.ItemIndex := i;
    End
   Else If Sender = ChartOrderList Then
    Begin
     i := ChartOrderList.ItemAtPos(Point(x, y), True);
     If i < 0 Then
      Exit;
     ChartOrderList.ItemIndex := i;
    End
   Else
    Exit;
   // False waits for the system drag threshold, preserving an ordinary click.
   TControl(Sender).BeginDrag(False);
  End;

 Procedure TfrmChartsConfigure.ListStartDrag(Sender : TObject; Var DragObject : TDragObject);
  Begin
   fDragSource := Sender;
   If Sender = ParameterList Then
    fDragName := RawName(ParameterList.Items, ParameterList.ItemIndex)
   Else If Sender = ChartOrderList Then
    fDragName := RawName(ChartOrderList.Items, ChartOrderList.ItemIndex)
   Else
    fDragName := '';
  End;

 Function TfrmChartsConfigure.DropAllowed(Target, Source : TObject) : Boolean;
  Begin
   Result := (Source = fDragSource) And (fDragName <> '') And (fAvailable.IndexOf(fDragName) >= 0) And (((Source = ParameterList) And (Target = ChartOrderList)) Or ((Source = ChartOrderList) And (Target = ParameterList)) Or ((Source = ChartOrderList) And (Target = ChartOrderList) And (GetKeyState(VK_CONTROL) < 0)));
  End;

 Function TfrmChartsConfigure.DropSlot(y : Integer) : Integer;
  Var
   i : Integer;
   r : TRect;
  Begin
   If ChartOrderList.Count = 0 Then
    Exit(0);
   If y < 0 Then
    Exit(ChartOrderList.TopIndex);
   i := ChartOrderList.ItemAtPos(Point(2, y), True);
   If i < 0 Then
    Exit(ChartOrderList.Count);
   r      := ChartOrderList.ItemRect(i);
   Result := i;
   If y >= (r.Top + r.Bottom) Div 2 Then
    Inc(Result);
  End;

 Procedure TfrmChartsConfigure.ListDragOver(Sender, Source : TObject; x, y : Integer; State : TDragState; Var Accept : Boolean);
  Var
   Slot : Integer;
  Begin
   Accept                  := (State <> dsDragLeave) And DropAllowed(Sender, Source);
   fDragTarget             := Nil;
   DragScrollTimer.Enabled := False;
   Slot                    := -1;
   If Accept Then
    Begin
     fDragTarget             := Sender;
     DragScrollTimer.Enabled := True;
     If Sender = ChartOrderList Then
      Slot := DropSlot(y);
    End;
   If fDropSlot <> Slot Then
    Begin
     fDropSlot := Slot;
     ChartOrderList.Invalidate;
    End;
  End;

 Procedure TfrmChartsConfigure.ListDragDrop(Sender, Source : TObject; x, y : Integer);
  Var
   Name       : String;
   Anchor     : String;
   Slot       : Integer;
   Old        : Integer;
   VisibleOld : Integer;
   i          : Integer;
  Begin
   If Not DropAllowed(Sender, Source) Then
    Begin
     ClearDrag;
     Exit;
    End;
   Name := fDragName;
   Old  := fSelected.IndexOf(Name);
   If Sender = ParameterList Then
    Begin
     If Old >= 0 Then
      fSelected.Delete(Old);
    End
   Else
    Begin
     Slot := DropSlot(y);
     // Resolve the insertion boundary before rebuilding or deleting any items.
     Anchor := '';
     For i  := Slot To ChartOrderList.Count - 1 Do
      If RawName(ChartOrderList.Items, i) <> Name Then
       Begin
        Anchor := RawName(ChartOrderList.Items, i);
        Break;
       End;
     If Old >= 0 Then
      fSelected.Delete(Old);
     If Anchor <> '' Then
      fSelected.Insert(fSelected.IndexOf(Anchor), Name)
     Else
      fSelected.Add(Name);
    End;
   VisibleOld := ChartOrderList.ItemIndex;
   ClearDrag;
   RebuildParameters;
   RebuildOrder(Name);
   If (Sender = ParameterList) And (ChartOrderList.Count > 0) Then
    ChartOrderList.ItemIndex := EnsureRange(VisibleOld, 0, ChartOrderList.Count - 1);
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.ListEndDrag(Sender, Target : TObject; x, y : Integer);
  Begin
   ClearDrag;
  End;

 Procedure TfrmChartsConfigure.DragScrollTick(Sender : TObject);
  Var
   p      : TPoint;
   List   : TCustomListBox;
   NewTop : Integer;
  Begin
   If (fDragTarget = Nil) Or Not DropAllowed(fDragTarget, fDragSource) Then
    Begin
     DragScrollTimer.Enabled := False;
     Exit;
    End;
   List := TCustomListBox(fDragTarget);
   p    := List.ScreenToClient(Mouse.CursorPos);
   If Not PtInRect(List.ClientRect, p) Then
    Exit;
   NewTop := List.TopIndex;
   If p.y < 20 Then
    Dec(NewTop)
   Else If p.y >= List.ClientHeight - 20 Then
    Inc(NewTop);
   List.TopIndex := EnsureRange(NewTop, 0, Max(0, List.Items.Count - 1));
   If fDragTarget = ChartOrderList Then
    Begin
     fDropSlot := DropSlot(p.y);
     ChartOrderList.Invalidate;
    End;
  End;

 Procedure TfrmChartsConfigure.DrawChartItem(Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
  Var
   c          : TCanvas;
   Title      : String;
   TextBounds : TRect;
  Begin
   c := ChartOrderList.Canvas;
   c.Font.Assign(ChartOrderList.Font);
   If odSelected In State Then
    Begin
     c.Brush.Color := clHighlight;
     c.Font.Color  := clHighlightText;
    End
   Else
    Begin
     c.Brush.Color := ChartOrderList.Color;
     c.Font.Color  := ChartOrderList.Font.Color;
    End;
   c.FillRect(Rect);
   Title      := ChartOrderList.Items[Index];
   TextBounds := Rect;
   Inc(TextBounds.Left, 2);
   DrawText(c.Handle, PChar(Title), Length(Title), TextBounds, DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX Or DT_END_ELLIPSIS);
   If (fDragTarget = ChartOrderList) And ((fDropSlot = Index) Or ((fDropSlot = ChartOrderList.Count) And (Index = ChartOrderList.Count - 1))) Then
    Begin
     c.Pen.Color := clHighlight;
     c.Pen.Width := 2;
     If fDropSlot = Index Then
      c.MoveTo(Rect.Left, Rect.Top + 1)
     Else
      c.MoveTo(Rect.Left, Rect.Bottom - 1);
     c.LineTo(Rect.Right, c.PenPos.y);
     c.Pen.Width := 1;
    End;
  End;

 Procedure TfrmChartsConfigure.SplitterMoved(Sender : TObject);
  Var
   AvailableWidth : Integer;
  Begin
   AvailableWidth := MainGroupBox.ClientWidth - Splitter1.Width - GraphButtonPanel.Width;
   If AvailableWidth > 0 Then
    fSplitRatio := ListPanel.Width / AvailableWidth;
  End;

 Procedure TfrmChartsConfigure.PrepareButtonGlyphs;
  Var
   Button  : TSpeedButton;
   Buttons : TArray<TSpeedButton>;
   Bitmap  : Vcl.Graphics.TBitmap;
  Begin
   // Delphi 10.2 copies the action image to TSpeedButton.Glyph without
   // preserving alpha correctly. Composite once, then use its colour key.
   Bitmap := Vcl.Graphics.TBitmap.Create;
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
      Bitmap.Transparent      := True;
      Button.Glyph.Assign(Bitmap);
      Button.NumGlyphs := 1;
      Button.Caption   := '';
      Button.ShowHint  := True;
     End;
   Finally
    Bitmap.Free;
   End;
  End;

 Procedure TfrmChartsConfigure.FormResize(Sender : TObject);
  Var
   AvailableWidth : Integer;
   MinimumWidth   : Integer;
  Begin
   If (MainGroupBox = Nil) Or (GraphButtonPanel = Nil) Or (Separator = Nil) Then
    Exit;
   If fSplitRatio > 0 Then
    Begin
     AvailableWidth  := MainGroupBox.ClientWidth - Splitter1.Width - GraphButtonPanel.Width;
     MinimumWidth    := Min(120, Max(0, AvailableWidth Div 2));
     ListPanel.Width := EnsureRange(Round(AvailableWidth * fSplitRatio), MinimumWidth, Max(MinimumWidth, AvailableWidth - MinimumWidth));
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

 Procedure TfrmChartsConfigure.ParameterHint(Sender : TObject; Shift : TShiftState; x, y : Integer);
  Var
   Name : String;
   i    : Integer;
  Begin
   If Sender = ParameterList Then
    Begin
     i    := ParameterList.ItemAtPos(Point(x, y), True);
     Name := RawName(ParameterList.Items, i);
    End
   Else
    Begin
     i    := ChartOrderList.ItemAtPos(Point(x, y), True);
     Name := RawName(ChartOrderList.Items, i);
    End;
   If Name <> '' Then
    TControl(Sender).Hint := ParameterCaption(Name) + sLineBreak + Name
   Else
    TControl(Sender).Hint := '';
  End;

 Procedure TfrmChartsConfigure.RebuildParameters;
  Var
   Name         : String;
   Filter       : String;
   Caption      : String;
   SelectedName : String;
   i            : Integer;
   Index        : Integer;
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
        i                        := ParameterList.Items.AddObject(Caption, TObject(NativeInt(Index + 1)));
        ParameterList.Checked[i] := fSelected.IndexOf(Name) >= 0;
        If Name = SelectedName Then
         ParameterList.ItemIndex := i;
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
   i    : Integer;
   p    : Integer;
   Name : String;
  Begin
   If fUpdating Or (fSelected = Nil) Then
    Exit;
   i := ParameterList.ItemIndex;
   If i < 0 Then
    Exit;
   Name := RawName(ParameterList.Items, i);
   p    := fSelected.IndexOf(Name);
   If ParameterList.Checked[i] Then
    Begin
     If p < 0 Then
      fSelected.Add(Name);
    End
   Else If p >= 0 Then
    fSelected.Delete(p);
   RebuildOrder(Name);
  End;

 Procedure TfrmChartsConfigure.SearchChange(Sender : TObject);
  Begin
   RebuildParameters;
  End;

 Procedure TfrmChartsConfigure.MoveChart(Sender : TObject);
  Var
   i    : Integer;
   j    : Integer;
   a    : Integer;
   b    : Integer;
   Name : String;
  Begin
   i := ChartOrderList.ItemIndex;
   If i < 0 Then
    Exit;
   j := i + 1;
   If (Sender = btnMoveUp) Or (Sender = aMoveUp) Then
    j := i - 1
   Else If (Sender = btnMoveFirst) Or (Sender = aMoveFirst) Then
    j := 0
   Else If (Sender = btnMoveLast) Or (Sender = aMoveLast) Then
    j := ChartOrderList.Count - 1;
   If (j < 0) Or (j >= ChartOrderList.Count) Then
    Exit;
   Name := RawName(ChartOrderList.Items, i);
   a    := fSelected.IndexOf(Name);
   b    := fSelected.IndexOf(RawName(ChartOrderList.Items, j));
   fSelected.Move(a, b);
   RebuildOrder(Name);
  End;

 Procedure TfrmChartsConfigure.ShowChart(Sender : TObject);
  Var
   i : Integer;
  Begin
   i := ParameterList.ItemIndex;
   If i < 0 Then
    Exit;
   ParameterList.Checked[i] := True;
   ParameterCheck(ParameterList);
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.HideChart(Sender : TObject);
  Var
   i : Integer;
  Begin
   i := ChartOrderList.ItemIndex;
   If i < 0 Then
    Exit;
   fSelected.Delete(fSelected.IndexOf(RawName(ChartOrderList.Items, i)));
   RebuildParameters;
   RebuildOrder;
   If ChartOrderList.Count > 0 Then
    Begin
     If i >= ChartOrderList.Count Then
      i                       := ChartOrderList.Count - 1;
     ChartOrderList.ItemIndex := i;
    End;
   UpdateButtons;
  End;

 Procedure TfrmChartsConfigure.UpdateButtons;
  Var
   i : Integer;
  Begin
   If (ChartOrderList = Nil) Or (aMoveUp = Nil) Or (aMoveDown = Nil) Or (aHide = Nil) Then
    Exit;
   i                  := ChartOrderList.ItemIndex;
   aMoveUp.Enabled    := i > 0;
   aMoveDown.Enabled  := (i >= 0) And (i < ChartOrderList.Count - 1);
   aHide.Enabled      := i >= 0;
   aMoveFirst.Enabled := aMoveUp.Enabled;
   aMoveLast.Enabled  := aMoveDown.Enabled;
   aShow.Enabled      := (fSelected <> Nil) And (ParameterList.ItemIndex >= 0);
   If aShow.Enabled Then
    aShow.Enabled := fSelected.IndexOf(RawName(ParameterList.Items, ParameterList.ItemIndex)) < 0;
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
