{$StackFrames On}
Unit EngineGaugesU;

Interface

 Uses
  B38MEICASU, System.Classes, System.SysUtils, System.Math, System.Types, System.Generics.Collections,
  Vcl.Controls, Vcl.Graphics, FlightDatabaseU, InstrumentDataU;

 Type
  TEngineReading = Record
   Engine    : Integer;
   Caption   : String;
   Parameter : String;
   Value     : Double;
   Scale     : Double;
   Primary   : Boolean;
  End;

  TEngineGauges = Class(TCustomControl)
   Private
    fEicas      : TB38MEICAS;
    fBuffer     : TBitmap;
    fUseEicas   : Boolean;
    fItems      : TList<TEngineReading>;
    fProfile    : TInstrumentProfile;
    fTime       : String;
    fCompact    : Boolean;
    fColumns    : Integer;
    fCardHeight : Integer;
    Procedure SetCompact(Value : Boolean);
    Procedure Add       (Plot : TTripPlot; Index, Engine : Integer; Const Caption, Parameter : String; Scale : Double; Primary, Optional : Boolean);
   Protected
    Procedure Paint; Override;
   Public
    Constructor Create  (AOwner : TComponent); Override;
    Destructor  Destroy; Override;
    Procedure   Clear;
    Procedure   SetPoint(Plot : TTripPlot; Index : Integer);
    Procedure   FitWidth(Value : Integer);
    Property IsB38M  : Boolean Read fUseEicas;
    Property Eicas   : TB38MEICAS Read fEicas;
    Property Items   : TList < TEngineReading > Read fItems;
    Property Profile : TInstrumentProfile Read fProfile;
    Property Compact : Boolean Read fCompact Write SetCompact;
    Property Time    : String Read fTime;
  End;

 Function EngineGaugeUnit(Const Parameter : String) : String;
 Function EngineGaugeValue(Const Parameter : String; Raw : Double) : Double;

Implementation

 Uses
  InstrumentRenderU, Winapi.Windows, ParameterNamesU;

 Function EngineGaugeUnit(Const Parameter : String) : String;
  Begin
   Result := ParameterDisplayUnit(Parameter);
   If (Pos('eng_oil_pressure', Parameter) = 1) And (Result = 'psf') Then
    Result := 'psi';
  End;

 Function EngineGaugeValue(Const Parameter : String; Raw : Double) : Double;
  Begin
   Result := ParameterDisplayValue(Parameter, Raw);
   If (Pos('eng_oil_pressure', Parameter) = 1) And (ParameterDisplayUnit(Parameter) = 'psf') Then
    Result := Result / 144;
  End;

 Constructor TEngineGauges.Create(AOwner : TComponent);
  Begin
   Inherited;
   fEicas              := TB38MEICAS.Create;
   fBuffer             := Vcl.Graphics.TBitmap.Create;
   fBuffer.PixelFormat := pf32bit;
   fItems              := TList<TEngineReading>.Create;
   DoubleBuffered      := True;
   Color               := $00202020;
   ParentBiDiMode      := False;
   BiDiMode            := bdLeftToRight;
   Clear;
  End;

 Destructor TEngineGauges.Destroy;
  Begin
   fBuffer.Free;
   fEicas.Free;
   fItems.Free;
   Inherited;
  End;

 Procedure TEngineGauges.Clear;
  Begin
   fUseEicas := False;
   fEicas.Clear;
   fItems.Clear;
   fTime                := '';
   fProfile.Title       := '';
   fProfile.EngineType  := -1;
   fProfile.EngineCount := 0;
   fProfile.Kind        := ikGaAnalog;
   Invalidate;
  End;

 Procedure TEngineGauges.Add(Plot : TTripPlot; Index, Engine : Integer; Const Caption, Parameter : String; Scale : Double; Primary, Optional : Boolean);
  Var
   Item : TEngineReading;
   Name : String;
  Begin
   Name := Parameter;
   If Engine > 0 Then
    Name      := Name + ' #' + IntToStr(Engine);
   Item.Value := InstrumentValue(Plot, Index, Name);
   If Optional And Not InstrumentValid(Item.Value) Then
    Exit;
   Item.Engine    := Engine;
   Item.Caption   := Caption;
   Item.Parameter := Name;
   Item.Scale     := Scale;
   Item.Primary   := Primary;
   fItems.Add(Item);
  End;

 Procedure TEngineGauges.SetCompact(Value : Boolean);
  Begin
   fCompact := Value;
   Invalidate;
  End;

 Procedure TEngineGauges.SetPoint(Plot : TTripPlot; Index : Integer);
  Var
   e : Integer;
  Begin
   Clear;
   If (Plot = Nil) Or (Index < 0) Or (Index >= Plot.Points.Count) Then
    Exit;
   fProfile  := InstrumentProfile(Plot, Index);
   fUseEicas := fProfile.Kind = ikB38MPFD;
   If fUseEicas Then
    fEicas.SetPoint(Plot, Index);
   fTime := Plot.DisplayPoint(Index).Time;
   For e := 1 To fProfile.EngineCount Do
    Begin
     Case fProfile.EngineType Of
      0 :
       Begin
        Add(Plot, Index, e, 'RPM', 'general_eng_rpm', 4000, True, False);
        Add(Plot, Index, e, 'EGT', 'eng_exhaust_gas_temperature', 1200, True, False);
        Add(Plot, Index, e, 'OIL P', 'eng_oil_pressure', 14400, True, False);
        Add(Plot, Index, e, 'OIL T', 'eng_oil_temperature', 200, True, False);
        Add(Plot, Index, e, 'CHT', 'recip_eng_cylinder_head_temperature', 300, False, True);
        Add(Plot, Index, e, 'MIX', 'general_eng_mixture_lever_position', 100, False, True);
       End;
      3, 5 :
       Begin
        Add(Plot, Index, e, 'TORQUE', 'turb_eng_max_torque_percent', 100, True, False);
        Add(Plot, Index, e, 'PROP RPM', 'prop_rpm', 2500, True, False);
        Add(Plot, Index, e, 'ITT', 'turb_eng_itt', 1000, True, False);
        Add(Plot, Index, e, 'NG / N1', 'turb_eng_n1', 120, True, False);
        Add(Plot, Index, e, 'OIL P', 'eng_oil_pressure', 14400, False, False);
        Add(Plot, Index, e, 'OIL T', 'eng_oil_temperature', 200, False, False);
        Add(Plot, Index, e, 'FF', 'turb_eng_fuel_flow_pph', 2000, False, False);
        Add(Plot, Index, e, 'COND', 'turb_eng_condition_lever_position', 2, False, True);
       End;
      1 :
       Begin
        Add(Plot, Index, e, 'N1', 'turb_eng_n1', 120, True, False);
        Add(Plot, Index, e, 'N2', 'turb_eng_n2', 120, True, False);
        Add(Plot, Index, e, 'EGT', 'eng_exhaust_gas_temperature', 1200, True, False);
        Add(Plot, Index, e, 'FF', 'turb_eng_fuel_flow_pph', 10000, True, False);
        Add(Plot, Index, e, 'OIL P', 'eng_oil_pressure', 14400, False, False);
        Add(Plot, Index, e, 'OIL T', 'eng_oil_temperature', 200, False, False);
        Add(Plot, Index, e, 'VIB', 'turb_eng_vibration', 5, False, True);
        Add(Plot, Index, e, 'MODE', 'general_eng_throttle_managed_mode', 0, False, True);
       End;
     Else
       Add(Plot, Index, e, 'RPM', 'general_eng_rpm', 4000, True, False);
     End;
     Add(Plot, Index, e, 'BETA', 'prop_beta', 90, False, True);
     Add(Plot, Index, e, 'REV', 'engine_reverse_engaged', 1, False, True);
    End;
   Add(Plot, Index, 0, 'FUEL L', 'fuel_left_quantity', 0, False, True);
   Add(Plot, Index, 0, 'FUEL R', 'fuel_right_quantity', 0, False, True);
   If fProfile.EngineType = 0 Then
    Begin
     Add(Plot, Index, 0, 'BAT', 'electrical_battery_load', 0, False, True);
     Add(Plot, Index, 0, 'VAC', 'suction_pressure', 0, False, True);
    End;
   Add(Plot, Index, 0, 'A/T ARM', 'autopilot_throttle_arm', 0, False, True);
   Add(Plot, Index, 0, 'A/T ACTIVE', 'autothrottle_active', 0, False, True);
   FitWidth(Width);
  End;

// Compatibility entry point: host alignment owns the bounds, never sample data.

 Procedure TEngineGauges.FitWidth(Value : Integer);
  Begin
   If Align = alNone Then
    Width := Max(1, Value);
   Invalidate;
  End;

 Procedure TEngineGauges.Paint;
  Var
   c            : TCanvas;
   e            : Integer;
   ColumnWidth  : Integer;
   x            : Integer;
   y            : Integer;
   r            : Integer;
   n            : Integer;
   CardY        : Integer;
   TextY        : Integer;
   Item         : TEngineReading;
   v            : Double;
   s            : String;
   RenderWidth  : Integer;
   RenderHeight : Integer;
   Columns      : Integer;
   Secondary    : Integer;
   Maximum      : Integer;
   RenderDC     : Integer;
   Scale        : Double;
   Candidate    : Double;
   Target       : TRect;

   Procedure Text(Const s : String; x, y : Integer; Col : TColor);
    Begin
     c.Brush.Style := bsClear;
     c.Font.Color  := Col;
     c.TextOut(x, y, s);
    End;

   Procedure Dial(Const Item : TEngineReading; CX, CY, r : Integer);
    Var
     k         : Integer;
     a         : Double;
     Scale     : Double;
     v         : Double;
     q         : TPoint;
     LabelText : String;
     Tick      : String;

     Function PointAt(a, Radius : Double) : TPoint;
      Begin
       Result := Point(CX + Round(Sin(DegToRad(a)) * r * Radius), CY - Round(Cos(DegToRad(a)) * r * Radius));
      End;

    Begin
     c.Brush.Style := bsSolid;
     c.Brush.Color := $00101010;
     c.Pen.Color   := $00666666;
     c.Pen.Width   := 2;
     c.Ellipse(CX - r, CY - r, CX + r, CY + r);
     v     := EngineGaugeValue(Item.Parameter, Item.Value);
     Scale := Abs(EngineGaugeValue(Item.Parameter, Item.Scale));
     If Scale < 0.001 Then
      Begin
       Scale := 1;
       If InstrumentValid(v) Then
        Scale := Max(1, Abs(v));
      End;
     For k := 0 To 8 Do
      Begin
       a := -135 + k * 270 / 8;
       q := PointAt(a, 0.91);
       c.MoveTo(q.x, q.y);
       q := PointAt(a, 0.8);
       c.LineTo(q.x, q.y);
       If k Mod 2 = 0 Then
        Begin
         Tick        := Format('%.0f', [Scale * k / 8]);
         q           := PointAt(a, 0.64);
         c.Font.Size := 8;
         Text(Tick, q.x - c.TextWidth(Tick) Div 2, q.y - c.TextHeight(Tick) Div 2, clSilver);
        End;
      End;
     If InstrumentValid(v) Then
      Begin
       a           := -135 + EnsureRange(v / Scale, 0.0, 1.0) * 270;
       q           := PointAt(a, 0.76);
       c.Pen.Color := clWhite;
       c.MoveTo(CX, CY);
       c.LineTo(q.x, q.y);
       LabelText := Format('%.1f', [v]);
      End
     Else
      LabelText  := '--';
     LabelText   := LabelText + ' ' + EngineGaugeUnit(Item.Parameter);
     c.Font.Size := Max(8, r Div 9);
     Text(Item.Caption, CX - c.TextWidth(Item.Caption) Div 2, CY + r Div 4, clSilver);
     Text(LabelText, CX - c.TextWidth(LabelText) Div 2, CY + r Div 2, clWhite);
    End;

  Begin
   If fUseEicas And Not fCompact Then
    Begin
     fEicas.PaintTo(Canvas, ClientRect);
     Exit;
    End;
   Scale := 1;
   If (ClientWidth < 1) Or (ClientHeight < 1) Then
    Exit;
   c             := Canvas;
   c.Brush.Style := bsSolid;
   c.Brush.Color := Color;
   c.FillRect(ClientRect);
   If Not fCompact Then
    Begin
     Maximum := 0;
     For e   := 1 To fProfile.EngineCount Do
      Begin
       Secondary := 0;
       For Item In fItems Do
        If (Item.Engine = e) And Not Item.Primary Then
         Inc(Secondary);
       Maximum := Max(Maximum, Secondary);
      End;
     fCardHeight := 360 + Maximum * 23;
     Scale       := -1;
     fColumns    := 1;
     For Columns := 1 To Max(1, fProfile.EngineCount) Do
      Begin
       Candidate := Min(ClientWidth / (Columns * 340), ClientHeight / (((Max(1, fProfile.EngineCount) + Columns - 1) Div Columns) * fCardHeight + 110));
       If Candidate > Scale Then
        Begin
         Scale    := Candidate;
         fColumns := Columns;
        End;
      End;
     RenderWidth  := fColumns * 340;
     RenderHeight := ((Max(1, fProfile.EngineCount) + fColumns - 1) Div fColumns) * fCardHeight + 110;

    End
   Else
    Begin
     RenderWidth  := ClientWidth;
     RenderHeight := ClientHeight;
    End;
   RenderDC := BeginInstrumentRender(fBuffer, RenderWidth, RenderHeight, ClientWidth, ClientHeight);
   Try
    c             := fBuffer.Canvas;
    c.Brush.Style := bsSolid;
    c.Brush.Color := Color;
    c.FillRect(Rect(0, 0, RenderWidth, RenderHeight));
    c.Font.Name := 'Segoe UI';
    c.Font.Size := 9;
    If fCompact Then
     Begin
      ColumnWidth := Max(1, Width Div Max(1, fProfile.EngineCount));
      For e       := 1 To fProfile.EngineCount Do
       Begin
        x := (e - 1) * ColumnWidth + 6;
        y := 5;
        Text('ENG ' + IntToStr(e), x, y, clSilver);
        Inc(y, 22);
        For Item In fItems Do
         If (Item.Engine = e) And Item.Primary Then
          Begin
           v := EngineGaugeValue(Item.Parameter, Item.Value);
           If InstrumentValid(v) Then
            s := Format('%.1f', [v])
           Else
            s := '--';
           Text(Item.Caption + ' ' + s + ' ' + EngineGaugeUnit(Item.Parameter), x, y, clWhite);
           Inc(y, 21);
          End;
       End;
      Exit;
     End;
    If fColumns < 1 Then
     fColumns   := 1;
    ColumnWidth := RenderWidth Div fColumns;
    For e       := 1 To fProfile.EngineCount Do
     Begin
      x     := ((e - 1) Mod fColumns) * ColumnWidth;
      CardY := ((e - 1) Div fColumns) * fCardHeight;
      Text('ENG ' + IntToStr(e), x + 10, CardY + 8, clSilver);
      n     := 0;
      TextY := CardY + 350;
      For Item In fItems Do
       If Item.Engine = e Then
        Begin
         If Item.Primary Then
          Begin
           r := Min(75, (ColumnWidth - 20) Div 4);
           Dial(Item, x + (n Mod 2) * ColumnWidth Div 2 + ColumnWidth Div 4, CardY + 110 + (n Div 2) * 160, r);
           Inc(n);
          End
         Else
          Begin
           v := EngineGaugeValue(Item.Parameter, Item.Value);
           If InstrumentValid(v) Then
            s := Format('%.2f', [v])
           Else
            s := '--';
           Text(Item.Caption, x + 12, TextY, clSilver);
           Text(s + ' ' + EngineGaugeUnit(Item.Parameter), x + ColumnWidth Div 2, TextY, clWhite);
           Inc(TextY, 23);
          End;
        End;
     End;
    y := RenderHeight - 100;
    x := 10;
    For Item In fItems Do
     If Item.Engine = 0 Then
      Begin
       v := EngineGaugeValue(Item.Parameter, Item.Value);
       If InstrumentValid(v) Then
        s := Format('%.1f', [v])
       Else
        s := '--';
       s  := Item.Caption + ' ' + s + ' ' + EngineGaugeUnit(Item.Parameter);
       If x + c.TextWidth(s) > RenderWidth - 10 Then
        Begin
         Inc(y, 25);
         x := 10;
        End;
       Text(s, x, y, clSilver);
       Inc(x, c.TextWidth(s) + 25);
      End;
    If fProfile.EngineCount = 0 Then
     Text('--', 10, 30, clSilver);
   Finally
    EndInstrumentRender(fBuffer, RenderDC);
   End;
   Target := Rect(0, 0, Max(1, Round(RenderWidth * Scale)), Max(1, Round(RenderHeight * Scale)));
   OffsetRect(Target, (ClientWidth - Target.Width) Div 2, (ClientHeight - Target.Height) Div 2);
   SetStretchBltMode(Canvas.Handle, HALFTONE);
   SetBrushOrgEx(Canvas.Handle, 0, 0, Nil);
   DrawInstrumentBitmap(Canvas, Target, fBuffer);
  End;

End.
