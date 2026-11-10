Unit PFDMinimaU;

// FBW channel meanings and NO DH bit follow the official FMA.tsx (GPL-3.0).
// Copyright(c) FlyByWire Simulations. See support/fbw/minima.md.

Interface

 Uses
  AirbusDataU, System.Types, Vcl.Graphics;

 Type
  TMinimumKind = (mkNone, mkBaro, mkRadio, mkNoDH);

  TPFDMinimum = Record
   Kind : TMinimumKind;
   Feet : Double;
  End;

 Function ReadFBWMinimum(Data : TAirbusData) : TPFDMinimum;
 Function MinimumTapeY(Const m : TPFDMinimum; Altitude, RadioHeight : Double; Bounds : TRect; Span : Double) : Integer;
 Procedure DrawMinimum(c : TCanvas; Const m : TPFDMinimum; Altitude, RadioHeight : Double; Bounds : TRect; Span : Double);
 Function MinimumCaption(Const m : TPFDMinimum) : String;

Implementation

 Uses
  System.SysUtils, System.Math, InstrumentDataU, AirbusFMAU, ParameterNamesU;

 Function ReadFBWMinimum(Data : TAirbusData) : TPFDMinimum;
  Var
   Prefix : String;
   m      : Double;
   d      : Double;
   w      : Double;
  Begin
   Result.Kind := mkNone;
   Result.Feet := NaN;
   Prefix      := 'A32NX_FM1_';
   // Do not replace an explicitly invalid captain source with another FM's stale data.
   If Not InstrumentValid(Data.FBW(Prefix + 'MINIMUM_DESCENT_ALTITUDE')) And Not InstrumentValid(Data.FBW(Prefix + 'DECISION_HEIGHT')) And Not InstrumentValid(Data.FBW(Prefix + 'EIS_DISCRETE_WORD_2')) Then
    Prefix := 'A32NX_FM2_';
   w       := Data.ARINC(Prefix + 'EIS_DISCRETE_WORD_2');
   If AirbusBit(w, 29) Then
    Begin
     Result.Kind := mkNoDH;
     Exit;
    End;
   d := Data.ARINC(Prefix + 'DECISION_HEIGHT');
   m := Data.ARINC(Prefix + 'MINIMUM_DESCENT_ALTITUDE');
   If InstrumentValid(d) And (d >= 0) And (d <= 5000) Then
    Begin
     Result.Kind := mkRadio;
     Result.Feet := d;
    End
   Else If InstrumentValid(m) And (m >= -1500) And (m <= 60000) Then
    Begin
     Result.Kind := mkBaro;
     Result.Feet := m;
    End;
  End;

 Function MinimumTapeY(Const m : TPFDMinimum; Altitude, RadioHeight : Double; Bounds : TRect; Span : Double) : Integer;
  Var
   Delta : Double;
  Begin
   Result := -1;
   If Not InstrumentValid(m.Feet) Or (Span <= 0) Or (Bounds.Height < 1) Or Not InstrumentValid(Altitude) Then
    Exit;
   Case m.Kind Of
    mkBaro :
     Delta := Altitude - m.Feet;
    mkRadio :
     Begin
      If Not InstrumentValid(RadioHeight) Or (RadioHeight < 0) Then
       Exit;
      Delta := RadioHeight - m.Feet;
     End;
   Else
     Exit;
   End;
   // RADIO is a relative RA marker, never a fabricated absolute MSL minimum.
   If Abs(Delta) > Span Then
    Exit;
   Result := (Bounds.Top + Bounds.Bottom) Div 2 + Round(Delta / Span * (Bounds.Height Div 2));
  End;

 Function MinimumCaption(Const m : TPFDMinimum) : String;
  Begin
   Result := '';
   If m.Kind = mkNoDH Then
    Exit('NO DH');
   If Not InstrumentValid(m.Feet) Then
    Exit;
   If m.Kind = mkBaro Then
    Result := 'BARO '
   Else If m.Kind = mkRadio Then
    Result := 'RADIO '
   Else
    Exit;
   Result := Result + Format('%.0f', [ParameterDisplayValue('indicated_altitude', m.Feet)]) + ' ' + ParameterDisplayUnit('indicated_altitude');
  End;

 Procedure DrawMinimum(c : TCanvas; Const m : TPFDMinimum; Altitude, RadioHeight : Double; Bounds : TRect; Span : Double);
  Var
   y : Integer;
  Begin
   y := MinimumTapeY(m, Altitude, RadioHeight, Bounds, Span);
   If y < 0 Then
    Exit;
   c.Pen.Color := clAqua;
   c.Pen.Width := 3;
   If ((m.Kind = mkBaro) And (Altitude <= m.Feet)) Or ((m.Kind = mkRadio) And (RadioHeight <= m.Feet)) Then
    c.Pen.Color := $0000BFFF;
   c.MoveTo(Bounds.Left - 7, y - 5);
   c.LineTo(Bounds.Left, y);
   c.LineTo(Bounds.Left - 7, y + 5);
   c.MoveTo(Bounds.Left, y);
   c.LineTo(Bounds.Left + 3, y);
  End;

End.
