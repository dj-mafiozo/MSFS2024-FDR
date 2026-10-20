{$StackFrames On}
Unit FlightChartsU;

Interface

 Uses
  System.SysUtils, System.Classes, System.Math, System.Types, System.Generics.Collections,
  Vcl.Controls, Vcl.Graphics, Vcl.Forms, Winapi.Windows,
  FlightDatabaseU, LocalizationU, UIFontsU, ParameterNamesU;

 Type
  TCursorEvent = Procedure(Sender : TObject; Index : Integer) Of Object;

  TFlightCharts = Class(TCustomControl)
   Private
    fViewStart     : Double;
    fViewEnd       : Double;
    fZoomDrag      : Boolean;
    fDragViewStart : Double;
    fDragViewEnd   : Double;
    fDragging      : Boolean;
    fDragStart     : Integer;
    fDragEnd       : Integer;
    fData          : TTripPlot;
    fSelected      : TList<Integer>;
    fCursor        : Integer;
    Function IndexAt(T : Double) : Integer;
    Function TimeAt(X : Integer) : Double;
   Protected
    Function DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean; Override;
    Procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); Override;
    Procedure MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); Override;
    Procedure DblClick; Override;
    Procedure Paint; Override;
    Procedure MouseMove(Shift : TShiftState; X, Y : Integer); Override;
   Public
    OnViewChange       : TNotifyEvent;
    OnCursor           : TCursorEvent;
    Property ViewStart : Double Read fViewStart;
    Property ViewEnd   : Double Read fViewEnd;
    Procedure SetView(A, B : Double);
    Procedure ResetView;
    Procedure Zoom(Factor : Double);
    Procedure Pan(Fraction : Double);
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetData(Data : TTripPlot);
    Procedure Select(Indices : TList<Integer>);
    Procedure SetCursor(Index : Integer);
  End;

Implementation

 Constructor TFlightCharts.Create(AOwner : TComponent);
  Begin
   Inherited;
   ParentBiDiMode := False;
   BiDiMode       := bdLeftToRight;
   DoubleBuffered := True;
   fSelected      := TList<Integer>.Create;
  End;

 Destructor TFlightCharts.Destroy;
  Begin
   fSelected.Free;
   Inherited;
  End;

 Procedure TFlightCharts.SetData(Data : TTripPlot);
  Begin
   fData   := Data;
   fCursor := 0;
   ResetView;
   Invalidate;
  End;

 Procedure TFlightCharts.Select(Indices : TList<Integer>);
  Begin
   fSelected.Clear;
   fSelected.AddRange(Indices);
   DoubleBuffered := True;
   Height         := Max(160, fSelected.Count * 155);
   Invalidate;
  End;

 Procedure TFlightCharts.SetCursor(Index : Integer);
  Begin
   If fCursor = Index Then
    Exit;
   fCursor := Index;
   Invalidate;
  End;

 Procedure TFlightCharts.Paint;
  Var
   i          : Integer;
   j          : Integer;
   Field      : Integer;
   y0         : Integer;
   y1         : Integer;
   X          : Integer;
   Y          : Integer;
   FirstIndex : Integer;
   LastIndex  : Integer;
   MinV       : Double;
   MaxV       : Double;
   V          : Double;
   Duration   : Double;
   P          : TPlotPoint;
   Started    : Boolean;
   Title      : String;
   TitleRect  : TRect;
   TextRect   : TRect;
   Text       : String;
  Begin
   Canvas.Brush.Color := $241810;
   Canvas.FillRect(ClientRect);
   Canvas.Font.Name  := LocaleFontName(Language);
   Canvas.Font.Color := clWhite;
   If Not Assigned(fData) Or (fData.Points.Count = 0) Or (fSelected.Count = 0) Then
    Begin
     Text     := Tr('Wybierz lot i parametry wykres'#243'w.');
     TextRect := Rect(20, 20, Width - 5, 45);
     DrawText(Canvas.Handle, PChar(Text), Length(Text), TextRect, DT_SINGLELINE Or DT_NOPREFIX Or IfThen(AppLocalizer.BiDiMode = bdRightToLeft, DT_RTLREADING, 0));
     Exit;
    End;
   Duration   := Max(0.001, fViewEnd - fViewStart);
   FirstIndex := IndexAt(fViewStart);
   LastIndex  := IndexAt(fViewEnd);
   For j      := Max(0, Canvas.ClipRect.Top Div 155) To Min(fSelected.Count - 1, Canvas.ClipRect.Bottom Div 155) Do
    Begin
     Field := fSelected[j];
     y0    := j * 155 + 30;
     y1    := y0 + 105;
     MinV  := MaxDouble;
     MaxV  := -MaxDouble;
     For i := FirstIndex To LastIndex Do
      Begin
       P := fData.Points[i];
       V := ParameterDisplayValue(fData.Labels[Field], P.Values[Field]);
       If IsNan(V) Then
        Continue;
       MinV := Min(MinV, V);
       MaxV := Max(MaxV, V);
      End;
     Canvas.Font.Color := clWhite;
     Title             := ParameterCaption(fData.Labels[Field]);
     TitleRect         := Rect(64, y0 - 25, Max(65, Width - 145), y0 - 5);
     DrawText(Canvas.Handle, PChar(Title), Length(Title), TitleRect, DT_SINGLELINE Or DT_END_ELLIPSIS Or DT_NOPREFIX Or IfThen(AppLocalizer.BiDiMode = bdRightToLeft, DT_RTLREADING, 0));
     If MinV = MaxDouble Then
      Begin
       Text     := Tr('Brak danych');
       TextRect := Rect(64, y0, Width - 5, y0 + 30);
       DrawText(Canvas.Handle, PChar(Text), Length(Text), TextRect, DT_SINGLELINE Or DT_NOPREFIX Or IfThen(AppLocalizer.BiDiMode = bdRightToLeft, DT_RTLREADING, 0));
       Continue;
      End;
     If MinV = MaxV Then
      Begin
       MinV := MinV - 1;
       MaxV := MaxV + 1;
      End;
     Canvas.Pen.Color := $504030;
     Canvas.Pen.Width := 1;
     For i            := 0 To 4 Do
      Begin
       Y := y0 + Round(i * (y1 - y0) / 4);
       Canvas.MoveTo(60, Y);
       Canvas.LineTo(Width - 15, Y);
       Canvas.Font.Color := clSilver;
       Canvas.TextOut(3, Y - 5, Format('%.4g', [MaxV - i * (MaxV - MinV) / 4]));
      End;
     Canvas.Pen.Color := $BBDD55;
     Started          := False;
     For i            := FirstIndex To LastIndex Do
      Begin
       P := fData.Points[i];
       V := ParameterDisplayValue(fData.Labels[Field], P.Values[Field]);
       If IsNan(V) Then
        Begin
         Started := False;
         Continue;
        End;
       X := 60 + Round((EnsureRange(P.Seconds, fViewStart, fViewEnd) - fViewStart) / Duration * (Width - 75));
       Y := y1 - Round((V - MinV) / (MaxV - MinV) * (y1 - y0));
       If Not Started Then
        Canvas.MoveTo(X, Y)
       Else
        Canvas.LineTo(X, Y);
       Started := True;
      End;
     If (fCursor >= 0) And (fCursor < fData.Points.Count) And (fData.Points[fCursor].Seconds >= fViewStart) And (fData.Points[fCursor].Seconds <= fViewEnd) Then
      Begin
       P                := fData.Points[fCursor];
       X                := 60 + Round((EnsureRange(P.Seconds, fViewStart, fViewEnd) - fViewStart) / Duration * (Width - 75));
       Canvas.Pen.Color := clYellow;
       Canvas.MoveTo(X, y0);
       Canvas.LineTo(X, y1);
       Canvas.Font.Color := clYellow;
       If Not IsNan(P.Values[Field]) Then
        Canvas.TextOut(Width - 130, y0 - 25, Format('%.6g', [ParameterDisplayValue(fData.Labels[Field], P.Values[Field])]));
      End;
    End;
   If fDragging And fZoomDrag Then
    Begin
     Canvas.Pen.Color   := clAqua;
     Canvas.Brush.Style := bsClear;
     Canvas.Rectangle(Min(fDragStart, fDragEnd), Canvas.ClipRect.Top, Max(fDragStart, fDragEnd), Canvas.ClipRect.Bottom);
     Canvas.Brush.Style := bsSolid;
    End;
  End;

 Function TFlightCharts.DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean;
  Begin
   If ssCtrl In Shift Then
    Begin
     If WheelDelta > 0 Then
      Zoom(0.8)
     Else
      Zoom(1.25);
     Exit(True);
    End;
   Result := Parent Is TScrollBox;
   If Result Then
    TScrollBox(Parent).VertScrollBar.Position := TScrollBox(Parent).VertScrollBar.Position - Round(WheelDelta / 120 * 100)
   Else
    Result := Inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  End;

 Function TFlightCharts.IndexAt(T : Double) : Integer;
  Var
   Lo : Integer;
   Hi : Integer;
   M  : Integer;
  Begin
   Result := 0;
   If (fData = Nil) Or (fData.Points.Count = 0) Then
    Exit;
   Lo := 0;
   Hi := fData.Points.Count - 1;
   While Lo < Hi Do
    Begin
     M := (Lo + Hi + 1) Div 2;
     If fData.Points[M].Seconds <= T Then
      Lo := M
     Else
      Hi := M - 1;
    End;
   Result := Lo;
  End;

 Function TFlightCharts.TimeAt(X : Integer) : Double;
  Begin
   Result := fViewStart + EnsureRange((X - 60) / Max(1, Width - 75), 0.0, 1.0) * (fViewEnd - fViewStart);
  End;

 Procedure TFlightCharts.SetView(A, B : Double);
  Var
   Lo   : Double;
   Hi   : Double;
   Span : Double;
   T    : Double;
  Begin
   If (fData = Nil) Or (fData.Points.Count = 0) Then
    Exit;
   If B < A Then
    Begin
     T := A;
     A := B;
     B := T;
    End;
   Lo         := fData.Points.First.Seconds;
   Hi         := Max(Lo + 0.001, fData.Points.Last.Seconds);
   Span       := EnsureRange(B - A, Min(0.1, Hi - Lo), Hi - Lo);
   A          := EnsureRange(A, Lo, Hi - Span);
   fViewStart := A;
   fViewEnd   := A + Span;
   Invalidate;
   If Assigned(OnViewChange) Then
    OnViewChange(Self);
  End;

 Procedure TFlightCharts.ResetView;
  Begin
   fViewStart := 0;
   fViewEnd   := 0.001;
   If (fData <> Nil) And (fData.Points.Count > 0) Then
    SetView(fData.Points.First.Seconds, fData.Points.Last.Seconds)
   Else If Assigned(OnViewChange) Then
    OnViewChange(Self);
  End;

 Procedure TFlightCharts.Zoom(Factor : Double);
  Var
   Mid  : Double;
   Half : Double;
  Begin
   Mid  := (fViewStart + fViewEnd) / 2;
   Half := (fViewEnd - fViewStart) * Factor / 2;
   SetView(Mid - Half, Mid + Half);
  End;

 Procedure TFlightCharts.Pan(Fraction : Double);
  Var
   Span : Double;
   Lo   : Double;
   Hi   : Double;
  Begin
   If (fData = Nil) Or (fData.Points.Count = 0) Then
    Exit;
   Span := fViewEnd - fViewStart;
   Lo   := fData.Points.First.Seconds;
   Hi   := fData.Points.Last.Seconds;
   Lo   := Lo + Max(0, Hi - Lo - Span) * EnsureRange(Fraction, 0.0, 1.0);
   SetView(Lo, Lo + Span);
  End;

 Procedure TFlightCharts.MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
  Begin
   Inherited;
   If Button = mbLeft Then
    Begin
     fDragging      := True;
     fZoomDrag      := ssShift In Shift;
     fDragViewStart := fViewStart;
     fDragViewEnd   := fViewEnd;
     fDragStart     := EnsureRange(X, 60, Max(60, Width - 15));
     fDragEnd       := fDragStart;
     MouseCapture   := True;
    End;
  End;

 Procedure TFlightCharts.MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
  Var
   A : Double;
   B : Double;
  Begin
   Inherited;
   If (Button = mbLeft) And fDragging Then
    Begin
     fDragging    := False;
     MouseCapture := False;
     If fZoomDrag And (Abs(X - fDragStart) >= 5) Then
      Begin
       A := TimeAt(fDragStart);
       B := TimeAt(X);
       SetView(A, B);
      End;
     Invalidate;
    End;
  End;

 Procedure TFlightCharts.DblClick;
  Begin
   Inherited;
   ResetView;
  End;

 Procedure TFlightCharts.MouseMove(Shift : TShiftState; X, Y : Integer);
  Begin
   Inherited;
   If fDragging Then
    Begin
     fDragEnd := EnsureRange(X, 60, Max(60, Width - 15));
     If Not fZoomDrag Then
      SetView(fDragViewStart - (X - fDragStart) * (fDragViewEnd - fDragViewStart) / Max(1, Width - 75), fDragViewEnd - (X - fDragStart) * (fDragViewEnd - fDragViewStart) / Max(1, Width - 75));
     Invalidate;
    End;
   If (fData <> Nil) And (fData.Points.Count > 0) And Assigned(OnCursor) Then
    OnCursor(Self, IndexAt(TimeAt(X)));
  End;

End.
