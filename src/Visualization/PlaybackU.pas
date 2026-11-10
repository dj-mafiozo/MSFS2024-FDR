Unit PlaybackU;

Interface

 Uses
  FlightDatabaseU;

 Const
  PlaybackRates : Array [0..8] Of Double = (0.125, 0.25, 0.5, 0.75, 1, 2, 4, 8, 16);

 Type
  TPlayback = Class
   Private
    fKinds   : TArray<Integer>;
    fTimes   : TArray<Double>;
    fTime    : Double;
    fIndex   : Integer;
    fRate    : Integer;
    fTick    : UInt64;
    fPlaying : Boolean;
    Procedure Locate;
    Function GetCount : Integer;
   Public
    Constructor Create;
    Procedure Bind(Plot : TTripPlot);
    Procedure Present(Plot : TTripPlot);
    Procedure Play(Now : UInt64);
    Procedure Pause(Now : UInt64);
    Procedure Advance(Now : UInt64);
    Procedure Seek(Index : Integer; Now : UInt64);
    Procedure Skip(Seconds : Double; Now : UInt64);
    Procedure SetRate(Index : Integer; Now : UInt64);
    Procedure Stop(Now : UInt64);
    Function RateCaption : String;
    Property Position  : Integer Read fIndex;
    Property Time      : Double Read fTime;
    Property Playing   : Boolean Read fPlaying;
    Property RateIndex : Integer Read fRate;
    Property Count     : Integer Read GetCount;
  End;

Implementation

 Uses
  System.SysUtils, System.Math, System.DateUtils, TelemetryCatalogU;

 Constructor TPlayback.Create;
  Begin
   Inherited;
   fRate := 4;
  End;

 Function TPlayback.GetCount : Integer;
  Begin
   Result := Length(fTimes);
  End;

 Procedure TPlayback.Bind(Plot : TTripPlot);
  Var
   i    : Integer;
   j    : Integer;
   k    : Integer;
   f    : Integer;
   d    : Double;
   Step : Double;
   n    : String;
   u    : String;
  Begin
   fPlaying := False;
   fTime    := 0;
   fIndex   := 0;
   fRate    := 4;
   fTimes   := Nil;
   fKinds   := Nil;
   If Plot = Nil Then
    Exit;
   Plot.ClearDisplayPoint;
   SetLength(fKinds, Plot.Labels.Count);
   For i := 0 To Plot.Labels.Count - 1 Do
    Begin
     n     := Plot.Labels[i];
     f     := -1;
     For j := 0 To High(NumericColumns) Do
      If NumericColumns[j].Name = n Then
       Begin
        f := NumericColumns[j].FieldIndex;
        Break;
       End;
     k := Pos(' #', n);
     If k > 0 Then
      For j := 0 To High(EngineColumns) Do
       If EngineColumns[j].Name = Copy(n, 1, k - 1) Then
        Begin
         f := EngineColumns[j].FieldIndex;
         Break;
        End;
     If f < 0 Then
      Continue;
     u := LowerCase(SimFields[f].Units);
     If (u <> 'bool') And (u <> 'enum') And (u <> 'flags') And (u <> 'mask') And (u <> 'number') And (u <> 'seconds') And (u <> 'hours') And (u <> 'mhz') And (u <> 'khz') Then
      fKinds[i] := 1;
     If (Pos('heading', n) > 0) Or (n = 'ambient_wind_direction') Then
      If u = 'radians' Then
       fKinds[i] := 3
      Else If u = 'degrees' Then
       fKinds[i] := 2;
     If n = 'plane_bank_degrees' Then
      fKinds[i] := 4;
     If (Pos('autopilot_', n) = 1) And (Pos('flight_director_pitch', n) = 0) And (Pos('flight_director_bank', n) = 0) Then
      fKinds[i] := 0;
    End;
   SetLength(fTimes, Plot.Points.Count);
   Step  := Max(1, Plot.SamplingIntervalMS) / 1000;
   For i := 1 To High(fTimes) Do
    Begin
     d := Plot.Points[i].Seconds - Plot.Points[i - 1].Seconds;
     If IsNan(d) Or IsInfinite(d) Or (d <= 0) Then
      d        := Step;
     fTimes[i] := fTimes[i - 1] + d;
    End;
  End;

 Procedure TPlayback.Present(Plot : TTripPlot);
  Var
   a        : TPlotPoint;
   b        : TPlotPoint;
   p        : TPlotPoint;
   i        : Integer;
   Fraction : Double;
   Delta    : Double;
   Period   : Double;
   d        : Double;
   TA       : TDateTime;
   TB       : TDateTime;
   s        : String;
   k        : Integer;

   Function Stamp(Const Text : String; Out Value : TDateTime) : Boolean;
    Begin
     s := Text;
     k := Pos('_', s);
     If k > 0 Then
      SetLength(s, k - 1);
     Result := TryISO8601ToDate(s, Value, True);
    End;

   Function Blend(x, y : Double; Cycle : Double = 0) : Double;
    Var
     v : Double;
    Begin
     Result := x;
     If IsNan(x) Or IsInfinite(x) Or IsNan(y) Or IsInfinite(y) Then
      Exit;
     v := y - x;
     If Cycle > 0 Then
      v     := v - Floor((v + Cycle / 2) / Cycle) * Cycle;
     Result := x + v * Fraction;
     If Cycle > 0 Then
      Result := Result - Floor(Result / Cycle) * Cycle;
    End;

  Begin
   If (Plot = Nil) Or (Count <> Plot.Points.Count) Or (Count = 0) Then
    Exit;
   a := Plot.Points[fIndex];
   p := a;
   If fIndex < Count - 1 Then
    Begin
     b         := Plot.Points[fIndex + 1];
     Delta     := fTimes[fIndex + 1] - fTimes[fIndex];
     Fraction  := EnsureRange((fTime - fTimes[fIndex]) / Delta, 0.0, 1.0);
     p.Seconds := a.Seconds + (b.Seconds - a.Seconds) * Fraction;
     If Stamp(a.Time, TA) And Stamp(b.Time, TB) And (TB > TA) Then
      p.Time := DateToISO8601(TA + (TB - TA) * Fraction, True);
     // Do not invent motion across missing recording segments.
     d := b.Seconds - a.Seconds;
     If Not b.BreakBefore And (a.GroupID = b.GroupID) And (d > 0) And (d <= Max(2.0, Plot.SamplingIntervalMS / 1000 * 4)) Then
      Begin
       p.Lat := Blend(a.Lat, b.Lat);
       p.Lon := Blend(a.Lon, b.Lon, 360);
       If p.Lon > 180 Then
        p.Lon   := p.Lon - 360;
       p.Values := Copy(a.Values);
       For i    := 0 To Min(High(p.Values), Min(High(b.Values), High(fKinds))) Do
        If fKinds[i] > 0 Then
         Begin
          Period := 0;
          If (fKinds[i] = 2) Or (fKinds[i] = 4) Then
           Period := 360
          Else If fKinds[i] = 3 Then
           Period     := 2 * Pi;
          p.Values[i] := Blend(a.Values[i], b.Values[i], Period);
          If (fKinds[i] = 4) And (p.Values[i] > 180) Then
           p.Values[i] := p.Values[i] - 360;
         End;
      End;
    End;
   Plot.SetDisplayPoint(fIndex, p);
  End;

 Procedure TPlayback.Locate;
  Var
   l : Integer;
   r : Integer;
   m : Integer;
  Begin
   If Count = 0 Then
    Begin
     fIndex := 0;
     Exit;
    End;
   fTime := EnsureRange(fTime, 0.0, fTimes[High(fTimes)]);
   l     := 0;
   r     := High(fTimes);
   While l < r Do
    Begin
     m := (l + r + 1) Div 2;
     If fTimes[m] <= fTime Then
      l := m
     Else
      r := m - 1;
    End;
   fIndex := l;
  End;

 Procedure TPlayback.Advance(Now : UInt64);
  Begin
   If Not fPlaying Then
    Exit;
   If Now >= fTick Then
    fTime := fTime + (Now - fTick) * PlaybackRates[fRate] / 1000;
   fTick  := Now;
   Locate;
   If fIndex = High(fTimes) Then
    fPlaying := False;
  End;

 Procedure TPlayback.Play(Now : UInt64);
  Begin
   If Count < 2 Then
    Exit;
   If fIndex = High(fTimes) Then
    Begin
     fTime  := 0;
     fIndex := 0;
    End;
   fTick    := Now;
   fPlaying := True;
  End;

 Procedure TPlayback.Pause(Now : UInt64);
  Begin
   Advance(Now);
   fPlaying := False;
  End;

 Procedure TPlayback.Seek(Index : Integer; Now : UInt64);
  Begin
   If Count = 0 Then
    Exit;
   fIndex := EnsureRange(Index, 0, High(fTimes));
   fTime  := fTimes[fIndex];
   fTick  := Now;
   If fIndex = High(fTimes) Then
    fPlaying := False;
  End;

 Procedure TPlayback.Skip(Seconds : Double; Now : UInt64);
  Begin
   If Count = 0 Then
    Exit;
   Advance(Now);
   fTime := fTime + Seconds;
   Locate;
   fTick := Now;
   If fIndex = High(fTimes) Then
    fPlaying := False;
  End;

 Procedure TPlayback.SetRate(Index : Integer; Now : UInt64);
  Begin
   Advance(Now);
   fRate := EnsureRange(Index, 0, High(PlaybackRates));
   fTick := Now;
  End;

 Procedure TPlayback.Stop(Now : UInt64);
  Begin
   fPlaying := False;
   fRate    := 4;
   Seek(0, Now);
  End;

 Function TPlayback.RateCaption : String;
  Var
   f : TFormatSettings;
  Begin
   f                  := TFormatSettings.Create;
   f.DecimalSeparator := '.';
   Result             := FormatFloat('0.###', PlaybackRates[fRate], f) + 'x';
  End;

End.
