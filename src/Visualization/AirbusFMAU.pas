Unit AirbusFMAU;

// Adapted from FlyByWire FMA.tsx / FgBusProvider.ts, GPL-3.0.
// Copyright(c) FlyByWire Simulations. See support/fbw/display-protocol.md.

Interface

 Uses
  AirbusDataU, Vcl.Graphics;

 Type
  TFMAEntry = Record
   Text  : String;
   Color : TColor;
   Boxed : Boolean;
   Flash : Boolean;
  End;

  TAirbusFMA = Record
   Cells     : Array [0..4, 0..2] Of TFMAEntry;
   Common    : String;
   Available : Boolean;
  End;

 Function AirbusBit(Value : Double; Bit : Integer) : Boolean;
 Function ReadAirbusFMA(Data : TAirbusData) : TAirbusFMA;

Implementation

 Uses
  System.SysUtils, System.Math, InstrumentDataU;

 Function AirbusBit(Value : Double; Bit : Integer) : Boolean;
  Begin
   Result := False;
   If InstrumentValid(Value) And (Value >= 0) And (Value <= 4294967295.0) Then
    Result := (UInt64(Trunc(Value)) And (UInt64(1) Shl (Bit - 1))) <> 0;
  End;

 Function ReadAirbusFMA(Data : TAirbusData) : TAirbusFMA;
  Var
   W1         : Double;
   W2         : Double;
   W3         : Double;
   W4         : Double;
   W7         : Double;
   a          : Double;
   t          : Double;
   F1         : Double;
   F2         : Double;
   FC         : Double;
   Constraint : Double;
   v          : Double;
   Engaged    : Boolean;
   Active     : Boolean;
   AP1        : Boolean;
   AP2        : Boolean;
   FD1        : Boolean;
   FD2        : Boolean;
   FG1        : Boolean;
   Inop1      : Boolean;
   Inop2      : Boolean;
   Prefix     : String;
   l          : String;
   r          : String;
   i          : Integer;
   j          : Integer;
   n          : Integer;

   Procedure Put(c, r : Integer; Const s : String; Color : TColor = clLime; Boxed : Boolean = False; Flash : Boolean = False);
    Begin
     Result.Cells[c, r].Text  := s;
     Result.Cells[c, r].Color := Color;
     Result.Cells[c, r].Boxed := Boxed;
     Result.Cells[c, r].Flash := Flash;
    End;

   Function B(w : Double; Bit : Integer) : Boolean;
    Begin
     Result := AirbusBit(w, Bit);
    End;

   Function FG(Const s : String) : Double;
    Begin
     Result := Data.ARINC(Prefix + s);
    End;

   Function Positive(Const s : String) : Boolean;
    Var
     x : Double;
    Begin
     x      := Data.FBW(s);
     Result := InstrumentValid(x) And (x > 0);
    End;

  Begin
   Result                     := Default(TAirbusFMA);
   For i                      := 0 To 4 Do
    For j                     := 0 To 2 Do
     Result.Cells[i, j].Color := clWhite;
   F1                         := Data.ARINC('A32NX_FMGC_1_DISCRETE_WORD_4');
   F2                         := Data.ARINC('A32NX_FMGC_2_DISCRETE_WORD_4');
   AP1                        := B(F1, 12);
   AP2                        := B(F2, 12);
   FD1                        := B(F1, 13);
   FD2                        := B(F2, 13);
   v                          := Data.ARINC('A32NX_FMGC_1_ATS_DISCRETE_WORD');
   Inop1                      := B(v, 24) Or Not InstrumentValid(v) Or Not InstrumentValid(F1);
   v                          := Data.ARINC('A32NX_FMGC_2_ATS_DISCRETE_WORD');
   Inop2                      := B(v, 24) Or Not InstrumentValid(v) Or Not InstrumentValid(F2);
   FG1                        := AP1 Or (Not(AP1 Or AP2) And FD1) Or (Not(AP1 Or AP2 Or FD1 Or FD2) And (Not Inop1 Or Inop2));
   If FG1 Then
    Prefix := 'A32NX_FMGC_1_'
   Else
    Prefix          := 'A32NX_FMGC_2_';
   W1               := FG('DISCRETE_WORD_1');
   W2               := FG('DISCRETE_WORD_2');
   W3               := FG('DISCRETE_WORD_3');
   W4               := FG('DISCRETE_WORD_4');
   W7               := FG('DISCRETE_WORD_7');
   Constraint       := FG('FM_ALTITUDE_CONSTRAINT');
   a                := Data.ARINC('A32NX_FCU_ATS_FMA_DISCRETE_WORD');
   t                := Data.ARINC('A32NX_FCU_ATS_DISCRETE_WORD');
   FC               := Data.ARINC('A32NX_FCU_DISCRETE_WORD_2');
   Result.Available := InstrumentValid(W1) Or InstrumentValid(W2) Or InstrumentValid(a);
   If Not Result.Available Then
    Begin
     Put(1, 0, 'FMA --', clSilver);
     Exit;
    End;
   Engaged := B(t, 13);
   Active  := B(t, 14);
   If B(a, 11) Then
    Begin
     Put(0, 0, 'MAN', clWhite, True);
     Put(0, 1, 'TOGA', clWhite, True);
    End
   Else If B(a, 13) Then
    Begin
     Put(0, 0, 'MAN', clWhite, True);
     v := Data.FBW('A32NX_AIRLINER_TO_FLEX_TEMP');
     If InstrumentValid(v) Then
      Put(0, 1, 'FLX ' + FormatFloat('+0;-0;0', v), clAqua, True)
     Else
      Put(0, 1, 'FLX --', clAqua, True);
    End
   Else If B(a, 29) Then
    Begin
     Put(0, 0, 'MAN', clWhite, True);
     Put(0, 1, 'DTO', clWhite, True);
    End
   Else If Engaged And Not Active And (B(a, 12) Or B(a, 15)) Then
    Begin
     Put(0, 0, 'MAN', clWhite, True);
     If B(a, 12) Then
      Put(0, 1, 'MCT', clWhite, True)
     Else
      Put(0, 1, 'THR', clWhite, True, True);
    End
   Else If B(a, 17) Then
    Put(0, 0, 'A.FLOOR', clLime, True, True)
   Else If B(a, 18) Then
    Put(0, 0, 'TOGA LK', clLime, True, True)
   Else If B(a, 19) Then
    Put(0, 0, 'SPEED')
   Else If B(a, 20) Then
    Put(0, 0, 'MACH')
   Else If B(a, 12) And Engaged And Active Then
    Put(0, 0, 'THR MCT')
   Else If B(a, 14) Then
    Put(0, 0, 'THR CLB')
   Else If B(a, 15) And Engaged And Active Then
    Put(0, 0, 'THR LVR')
   Else If B(a, 16) Then
    Put(0, 0, 'THR IDLE');
   v := Data.FBW('A32NX_AUTOBRAKES_ARMED_MODE');
   n := -1;
   If InstrumentValid(v) Then
    n := Trunc(v);
   If Positive('A32NX_AUTOBRAKES_ACTIVE') And (Result.Cells[0, 0].Text = '') Then
    Case n Of
     1 : Put(0, 0, 'BRK LO');
     2 : Put(0, 0, 'BRK MED');
     3 : Put(0, 0, 'BRK MAX');
    End;
   If (Result.Cells[0, 1].Text = '') And Not Positive('A32NX_AUTOBRAKES_ACTIVE') Then
    Case n Of
     1 : Put(0, 1, 'BRK LO', clAqua);
     2 : Put(0, 1, 'BRK MED', clAqua);
    End;
   If B(Data.ARINC('A32NX_ECU_1_MAINTENANCE_WORD_6'), 12) Or B(Data.ARINC('A32NX_ECU_2_MAINTENANCE_WORD_6'), 12) Then
    Put(0, 2, 'THR LK', $0000BFFF, False, True)
   Else If B(a, 22) Then
    Put(0, 2, 'LVR CLB', clWhite, False, True)
   Else If B(a, 23) Then
    Put(0, 2, 'LVR MCT', clWhite, False, True)
   Else If B(a, 21) Then
    Put(0, 2, 'LVR ASYM', $0000BFFF)
   Else If (n = 3) And Not Positive('A32NX_AUTOBRAKES_ACTIVE') Then
    Put(0, 2, 'BRK MAX', clAqua);
   If B(W1, 22) And B(W1, 20) Then
    Put(1, 0, 'G/S')
   Else If B(W1, 22) And B(W1, 21) Then
    Put(1, 0, 'G/S*')
   Else If B(W1, 24) And B(W1, 12) Then
    Put(1, 0, 'EXP DES')
   Else If B(W1, 24) And B(W1, 11) Then
    Put(1, 0, 'EXP CLB')
   Else If B(W1, 15) Or B(W1, 16) Then
    Put(1, 0, 'SRS')
   Else If B(W7, 13) Then
    Put(1, 0, 'TCAS')
   Else If B(W1, 23) And Not B(W2, 12) Then
    Put(1, 0, 'FINAL')
   Else If B(W1, 12) Then
    Begin
     If B(W1, 14) Then
      Put(1, 0, 'OP DES')
     Else
      Put(1, 0, 'DES');
    End
   Else If B(W1, 11) Then
    Begin
     If B(W1, 14) Then
      Put(1, 0, 'OP CLB')
     Else
      Put(1, 0, 'CLB');
    End
   Else If B(W1, 19) And Not B(W1, 26) And (B(W1, 20) Or B(W1, 21)) Then
    Begin
     l := 'ALT';
     If InstrumentValid(Constraint) Then
      l := l + ' CST';
     If B(W1, 21) Then
      l := l + '*';
     Put(1, 0, l);
    End
   Else If B(W1, 26) And (Not B(W1, 19) Or Not InstrumentValid(Constraint)) Then
    Put(1, 0, 'ALT CRZ')
   Else If B(W1, 18) Then
    Begin
     v := Data.ARINC('A32NX_FCU_SELECTED_FPA');
     l := '--';
     If InstrumentValid(v) Then
      l := FormatFloat('+0.0;-0.0;0.0', v, TFormatSettings.Create('en-US'));
     Put(1, 0, 'FPA ' + l);
    End
   Else If B(W1, 17) Then
    Begin
     v := Data.ARINC('A32NX_FCU_SELECTED_VERTICAL_SPEED');
     l := '--';
     If InstrumentValid(v) Then
      l := FormatFloat('+0;-0;0', v);
     Put(1, 0, 'V/S ' + l);
    End;
   If B(W3, 12) And Not B(W3, 24) Then
    Begin
     If InstrumentValid(Constraint) Then
      Put(1, 1, 'ALT', clFuchsia)
     Else
      Put(1, 1, 'ALT', clAqua);
    End
   Else If B(W3, 24) Then
    Put(1, 1, 'CLB', clAqua)
   Else If B(W3, 25) Then
    Put(1, 1, 'DES', clAqua);
   If B(W3, 22) Then
    Result.Cells[1, 1].Text := Trim(Result.Cells[1, 1].Text + ' G/S')
   Else If B(W3, 23) Then
    Result.Cells[1, 1].Text := Trim(Result.Cells[1, 1].Text + ' FINAL');
   If B(W2, 15) Then
    Put(2, 0, 'GA TRK')
   Else If B(W2, 13) Then
    Begin
     If B(W3, 19) Then
      Put(2, 0, 'LOC B/C*')
     Else
      Put(2, 0, 'LOC*');
    End
   Else If B(W2, 16) Then
    Put(2, 0, 'HDG')
   Else If B(W2, 11) And B(W2, 20) Then
    Put(2, 0, 'RWY')
   Else If B(W2, 11) And B(W2, 23) Then
    Put(2, 0, 'RWY TRK')
   Else If B(W2, 17) Then
    Put(2, 0, 'TRACK')
   Else If B(W2, 14) Then
    Begin
     If B(W3, 19) Then
      Put(2, 0, 'LOC B/C')
     Else
      Put(2, 0, 'LOC');
    End
   Else If B(W2, 12) And Not B(W1, 23) Then
    Begin
     If B(W3, 23) Then
      Put(2, 0, 'APP NAV')
     Else
      Put(2, 0, 'NAV');
    End;
   If B(W3, 16) Then
    Begin
     If B(W3, 19) Then
      Put(2, 1, 'LOC B/C', clAqua)
     Else
      Put(2, 1, 'LOC', clAqua);
    End
   Else If B(W3, 14) Then
    Begin
     If B(W3, 23) Or B(W1, 23) Then
      Put(2, 1, 'APP NAV', clAqua)
     Else
      Put(2, 1, 'NAV', clAqua);
    End;
   If B(W2, 26) Then
    Result.Common := 'ROLL OUT'
   Else If B(W1, 25) Then
    Result.Common := 'FLARE'
   Else If B(W4, 14) Then
    Result.Common := 'LAND'
   Else If B(W2, 12) And B(W1, 23) Then
    Result.Common := 'FINAL APP';
   If Result.Common <> '' Then
    Begin
     Put(1, 0, '');
     Put(2, 0, '');
    End;
   If B(W4, 23) Then
    Put(3, 0, 'CAT2', clWhite)
   Else If B(W4, 24) Then
    Begin
     Put(3, 0, 'CAT3', clWhite);
     Put(3, 1, 'SINGLE', clWhite);
    End
   Else If B(W4, 25) Then
    Begin
     Put(3, 0, 'CAT3', clWhite);
     Put(3, 1, 'DUAL', clWhite);
    End
   Else If B(W3, 20) Or B(W4, 14) Then
    Put(3, 0, 'CAT1', clWhite);
   If AP1 And AP2 Then
    Put(4, 0, 'AP1+2', clWhite)
   Else If AP1 Then
    Put(4, 0, 'AP1', clWhite)
   Else If AP2 Then
    Put(4, 0, 'AP2', clWhite);
   If AP1 Or AP2 Or FD1 Or FD2 Then
    Begin
     l := '-';
     r := '-';
     If Not B(FC, 26) Then
      Begin
       If FD1 Then
        l := '1'
       Else If FD2 Then
        l := '2';
      End;
     If Not B(FC, 27) Then
      Begin
       If FD2 Then
        r := '2'
       Else If FD1 Then
        r := '1';
      End;
     Put(4, 1, l + ' FD ' + r, clWhite);
    End;
   If Engaged Then
    Begin
     If Active Then
      Put(4, 2, 'A/THR', clWhite)
     Else
      Put(4, 2, 'A/THR', clAqua);
    End;
   If B(W7, 12) Then
    Put(1, 2, 'TCAS', clAqua)
   Else If B(W7, 24) Then
    Put(1, 2, 'TCAS RA INHIBITED', clWhite)
   Else If B(W7, 25) Then
    Put(1, 2, 'TRK FPA DESELECTED', clWhite)
   Else If Positive('A32NX_PFD_MSG_TD_REACHED') Then
    Put(1, 2, 'T/D REACHED', clWhite)
   Else If Positive('A32NX_PFD_MSG_CHECK_SPEED_MODE') Then
    Put(1, 2, 'CHECK SPEED MODE', clWhite)
   Else If Positive('A32NX_PFD_MSG_SET_HOLD_SPEED') Then
    Put(1, 2, 'SET HOLD SPEED', clWhite);
  End;

End.
