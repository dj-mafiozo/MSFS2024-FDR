Unit MetarDecodeU;

Interface

 Uses
  System.SysUtils;

 Type
  TDecodedMetar = Record
   Public
    Station           : String;
    TimeGroup         : String;
    Flags             : String;
    WindVariable      : String;
    Clouds            : String;
    Weather           : String;
    Trend             : String;
    Remarks           : String;
    Unknown           : String;
    WindDirection     : Double;
    WindKnots         : Double;
    GustKnots         : Double;
    VisibilityMeters  : Double;
    Temperature       : Double;
    DewPoint          : Double;
    QNH               : Double;
    VariableWind      : Boolean;
    CAVOK             : Boolean;
    VisibilityAtLeast : Boolean;
    VisibilityLess    : Boolean;
    NILReport         : Boolean;
  End;

 Function DecodeMetarReport(Const Raw : String) : TDecodedMetar;
 Function DecodedMetarText(Const Raw : String) : String;
 Function CompareMetarReports(Const Simulator, RealWorld : String) : String;

Implementation

 Uses
  System.Classes, System.Math, System.RegularExpressions, LocalizationU;

 Function Finite(v : Double) : Boolean;
  Begin
   Result := Not IsNan(v) And Not IsInfinite(v);
  End;

 Function Number(Const s : String) : Double;
  Var
   f : TFormatSettings;
  Begin
   f := TFormatSettings.Create('en-US');
   If Not TryStrToFloat(s, Result, f) Then
    Result := NaN;
  End;

 Function Temp(Const s : String) : Double;
  Begin
   If Copy(s, 1, 1) = 'M' Then
    Result := -Number(Copy(s, 2, 20))
   Else
    Result := Number(s);
  End;

 Procedure Add(Var s : String; Const Part : String);
  Begin
   If s <> '' Then
    s := s + ' ';
   s  := s + Part;
  End;

 Function Fraction(Const s : String) : Double;
  Var
   p : Integer;
   d : Double;
  Begin
   p := Pos('/', s);
   If p = 0 Then
    Exit(Number(s));
   d := Number(Copy(s, p + 1, 20));
   If Not Finite(d) Or (d = 0) Then
    Exit(NaN);
   Result := Number(Copy(s, 1, p - 1)) / d;
  End;

 Function DecodeMetarReport(Const Raw : String) : TDecodedMetar;
  Var
   Tokens : TArray<String>;
   i      : Integer;
   j      : Integer;
   t      : String;
   u      : String;
   m      : TMatch;
   v      : Double;
   f      : Double;
  Begin
   Result                  := Default(TDecodedMetar);
   Result.WindDirection    := NaN;
   Result.WindKnots        := NaN;
   Result.GustKnots        := NaN;
   Result.VisibilityMeters := NaN;
   Result.Temperature      := NaN;
   Result.DewPoint         := NaN;
   Result.QNH              := NaN;
   u                       := StringReplace(StringReplace(UpperCase(Trim(Raw)), #13, ' ', [rfReplaceAll]), #10, ' ', [rfReplaceAll]);
   Tokens                  := u.Split([' ', #9], TStringSplitOptions.ExcludeEmpty);
   i                       := 0;
   While i < Length(Tokens) Do
    Begin
     t := Tokens[i];
     Inc(i);
     If t.EndsWith('=') Then
      Delete(t, Length(t), 1);
     If t = 'METAR' Then
      Continue;
     If (t = 'SPECI') Or (t = 'AUTO') Or (t = 'COR') Then
      Begin
       Add(Result.Flags, t);
       Continue;
      End;
     If t = 'NIL' Then
      Begin
       Result.NILReport := True;
       Continue;
      End;
     If (Result.Station = '') And TRegEx.IsMatch(t, '^[A-Z][A-Z0-9]{3}$') Then
      Begin
       Result.Station := t;
       Continue;
      End;
     If TRegEx.IsMatch(t, '^(0[1-9]|[12][0-9]|3[01])([01][0-9]|2[0-3])[0-5][0-9]Z$') Then
      Begin
       Result.TimeGroup := t;
       Continue;
      End;
     If t = 'RMK' Then
      Begin
       While i < Length(Tokens) Do
        Begin
         Add(Result.Remarks, Tokens[i]);
         Inc(i);
        End;
       Break;
      End;
     If (t = 'NOSIG') Or (t = 'BECMG') Or (t = 'TEMPO') Or t.StartsWith('FM') Then
      Begin
       Add(Result.Trend, t);
       While i < Length(Tokens) Do
        Begin
         Add(Result.Trend, Tokens[i]);
         Inc(i);
        End;
       Break;
      End;
     m := TRegEx.Match(t, '^(VRB|[0-9]{3})([0-9]{2,3})(?:G([0-9]{2,3}))?(KT|MPS|KMH)$');
     If m.Success Then
      Begin
       Result.VariableWind := m.Groups[1].Value = 'VRB';
       If Not Result.VariableWind Then
        Result.WindDirection := Number(m.Groups[1].Value);
       If Result.WindDirection = 360 Then
        Result.WindDirection := 0;
       f                     := 1;
       If m.Groups[4].Value = 'MPS' Then
        f := 1.943844492
       Else If m.Groups[4].Value = 'KMH' Then
        f               := 1 / 1.852;
       Result.WindKnots := Number(m.Groups[2].Value) * f;
       If m.Groups[3].Value <> '' Then
        Result.GustKnots := Number(m.Groups[3].Value) * f;
       Continue;
      End;
     If TRegEx.IsMatch(t, '^[0-9]{3}V[0-9]{3}$') Then
      Begin
       Result.WindVariable := t;
       Continue;
      End;
     If t = 'CAVOK' Then
      Begin
       Result.CAVOK             := True;
       Result.VisibilityMeters  := 10000;
       Result.VisibilityAtLeast := True;
       Continue;
      End;
     If TRegEx.IsMatch(t, '^[0-9]{4}$') And Not Finite(Result.VisibilityMeters) Then
      Begin
       v                        := Number(t);
       Result.VisibilityAtLeast := t = '9999';
       Result.VisibilityLess    := t = '0000';
       If Result.VisibilityAtLeast Then
        v := 10000
       Else If Result.VisibilityLess Then
        v                      := 50;
       Result.VisibilityMeters := v;
       Continue;
      End;
     If (i < Length(Tokens)) And TRegEx.IsMatch(t, '^[0-9]+$') And TRegEx.IsMatch(Tokens[i], '^[0-9]+/[0-9]+SM$') Then
      Begin
       t := t + ' ' + Tokens[i];
       Inc(i);
      End;
     If t.EndsWith('SM') Then
      Begin
       u                        := Copy(t, 1, Length(t) - 2);
       Result.VisibilityLess    := u.StartsWith('M');
       Result.VisibilityAtLeast := u.StartsWith('P');
       If Result.VisibilityLess Or Result.VisibilityAtLeast Then
        Delete(u, 1, 1);
       j := Pos(' ', u);
       If j > 0 Then
        v := Number(Copy(u, 1, j - 1)) + Fraction(Copy(u, j + 1, 20))
       Else
        v := Fraction(u);
       If Finite(v) Then
        Begin
         Result.VisibilityMeters := v * 1609.344;
         Continue;
        End;
      End;
     If TRegEx.IsMatch(t, '^(FEW|SCT|BKN|OVC|VV)([0-9]{3}|///)(CB|TCU)?$') Or (t = 'SKC') Or (t = 'CLR') Or (t = 'NSC') Or (t = 'NCD') Then
      Begin
       Add(Result.Clouds, t);
       Continue;
      End;
     m := TRegEx.Match(t, '^(M?[0-9]{2}|//)/(M?[0-9]{2}|//)$');
     If m.Success Then
      Begin
       Result.Temperature := Temp(m.Groups[1].Value);
       Result.DewPoint    := Temp(m.Groups[2].Value);
       Continue;
      End;
     If TRegEx.IsMatch(t, '^Q[0-9]{4}$') Then
      Begin
       Result.QNH := Number(Copy(t, 2, 4));
       Continue;
      End;
     If TRegEx.IsMatch(t, '^A[0-9]{4}$') Then
      Begin
       Result.QNH := Number(Copy(t, 2, 4)) / 100 * 33.8638866667;
       Continue;
      End;
     If TRegEx.IsMatch(t, '^(?:[-+]|VC)?(?:MI|PR|BC|DR|BL|SH|TS|FZ)?(?:DZ|RA|SN|SG|IC|PL|GR|GS|UP|BR|FG|FU|VA|DU|SA|HZ|PY|PO|SQ|FC|SS|DS)+$') Or (t = 'NSW') Then
      Begin
       Add(Result.Weather, t);
       Continue;
      End;
     Add(Result.Unknown, t);
    End;
  End;

 Function Fmt(v : Double; Const Units : String) : String;
  Begin
   If Finite(v) Then
    Result := Format('%.1f %s', [v, Units], TFormatSettings.Create('en-US'))
   Else
    Result := '--';
  End;

 Function PhenomenaText(Const Raw : String) : String;
  Const
   Codes : Array [0..25] Of String = ('DZ', 'RA', 'SN', 'SG', 'IC', 'PL', 'GR', 'GS', 'UP', 'BR', 'FG', 'FU', 'VA', 'DU', 'SA', 'HZ', 'PY', 'PO', 'SQ', 'FC', 'SS', 'DS', 'MI', 'BC', 'PR', 'NSW');
   Names : Array [0..25] Of String = ('mżawka', 'deszcz', 'śnieg', 'śnieg ziarnisty', 'kryształki lodu', 'ziarna lodowe', 'grad', 'drobny grad / krupa śnieżna', 'nieznany opad', 'zamglenie', 'mgła', 'dym', 'popiół wulkaniczny', 'pył', 'piasek', 'zmętnienie', 'aerozol', 'wiry pyłu lub piasku', 'szkwały', 'trąba powietrzna / lejek', 'burza piaskowa', 'burza pyłowa', 'płytkie', 'płaty', 'częściowe', 'brak istotnych zjawisk');
  Var
   Tokens : TArray<String>;
   Token  : String;
   s      : String;
   Part   : String;
   Code   : String;
   j      : Integer;
   Known  : Boolean;
  Begin
   Result := '';
   Tokens := Raw.Split([' '], TStringSplitOptions.ExcludeEmpty);
   For Token In Tokens Do
    Begin
     s    := Token;
     Part := '';
     If s = 'NSW' Then
      Begin
       Add(Result, Tr('brak istotnych zjawisk'));
       Continue;
      End;
     If s.StartsWith('-') Then
      Begin
       Add(Part, Tr('słabe'));
       Delete(s, 1, 1);
      End
     Else If s.StartsWith('+') Then
      Begin
       Add(Part, Tr('silne'));
       Delete(s, 1, 1);
      End;
     While s <> '' Do
      Begin
       Code := Copy(s, 1, 2);
       Delete(s, 1, 2);
       Known := False;
       For j := 0 To High(Codes) Do
        If Codes[j] = Code Then
         Begin
          Add(Part, Tr(Names[j]));
          Known := True;
          Break;
         End;
       If Not Known Then
        Begin
         If Code = 'VC' Then
          Add(Part, Tr('w pobliżu'))
         Else If Code = 'SH' Then
          Add(Part, Tr('przelotne'))
         Else If Code = 'TS' Then
          Add(Part, Tr('burza'))
         Else If Code = 'FZ' Then
          Add(Part, Tr('marznące'))
         Else If Code = 'DR' Then
          Add(Part, Tr('niska zamieć'))
         Else If Code = 'BL' Then
          Add(Part, Tr('wysoka zamieć'))
         Else
          Add(Part, Code);
        End;
      End;
     If Result <> '' Then
      Result := Result + '; ';
     Result  := Result + Token + ' — ' + Part;
    End;
  End;

 Function DecodedMetarText(Const Raw : String) : String;
  Var
   d     : TDecodedMetar;
   l     : TStringList;
   t     : String;
   m     : String;
   Match : TMatch;
   a     : TArray<String>;
   Code  : String;
  Begin
   d := DecodeMetarReport(Raw);
   l := TStringList.Create;
   Try
    l.Add(Tr('Stacja') + ': ' + d.Station);
    l.Add('UTC: ' + d.TimeGroup);
    If d.NILReport Then
     Begin
      l.Add('NIL');
      Exit(l.Text);
     End;
    If d.VariableWind Then
     t := 'VRB'
    Else
     t := Fmt(d.WindDirection, 'deg TRUE');
    l.Add(Tr('Wiatr') + ': ' + t + ' / ' + Fmt(d.WindKnots, 'kt'));
    If Finite(d.GustKnots) Then
     l.Add(Tr('Porywy') + ': ' + Fmt(d.GustKnots, 'kt'));
    If d.WindVariable <> '' Then
     l.Add(Tr('Zmienny kierunek') + ': ' + d.WindVariable);
    t := '';
    If d.VisibilityAtLeast Then
     t := '>= '
    Else If d.VisibilityLess Then
     t := '< ';
    l.Add(Tr('Widzialność') + ': ' + t + Fmt(d.VisibilityMeters, 'm'));
    If d.CAVOK Then
     l.Add('CAVOK');
    l.Add(Tr('Temperatura') + ': ' + Fmt(d.Temperature, 'C'));
    l.Add(Tr('Punkt rosy') + ': ' + Fmt(d.DewPoint, 'C'));
    l.Add('QNH: ' + Fmt(d.QNH, 'hPa'));
    a := d.Clouds.Split([' '], TStringSplitOptions.ExcludeEmpty);
    For Code In a Do
     Begin
      Match := TRegEx.Match(Code, '^(FEW|SCT|BKN|OVC|VV)([0-9]{3}|///)(CB|TCU)?$');
      If Match.Success Then
       Begin
        m := Match.Groups[1].Value;
        If m = 'FEW' Then
         m := m + ' (1-2/8)'
        Else If m = 'SCT' Then
         m := m + ' (3-4/8)'
        Else If m = 'BKN' Then
         m := m + ' (5-7/8)'
        Else If m = 'OVC' Then
         m := m + ' (8/8)';
        t  := '--';
        If Match.Groups[2].Value <> '///' Then
         t := IntToStr(StrToInt(Match.Groups[2].Value) * 100) + ' ft AGL';
        If Match.Groups.Count > 3 Then
         t := t + ' ' + Match.Groups[3].Value;
        l.Add(Tr('Chmury') + ': ' + m + ' / ' + t);
       End
      Else
       l.Add(Tr('Chmury') + ': ' + Code);
     End;
    If d.Weather <> '' Then
     l.Add(Tr('Zjawiska') + ': ' + PhenomenaText(d.Weather));
    If d.Trend <> '' Then
     l.Add(Tr('Trend') + ': ' + d.Trend);
    If d.Remarks <> '' Then
     l.Add('RMK: ' + d.Remarks);
    If d.Unknown <> '' Then
     l.Add(Tr('Pozostałe grupy') + ': ' + d.Unknown);
    Result := l.Text;
   Finally
    l.Free;
   End;
  End;

 Function CompareMetarReports(Const Simulator, RealWorld : String) : String;
  Var
   a : TDecodedMetar;
   b : TDecodedMetar;
   l : TStringList;

   Procedure Numeric(Const Name : String; x, y, Tolerance : Double);
    Begin
     If Finite(x) <> Finite(y) Then
      l.Add(Name + ': -- / ' + Fmt(x, '') + ' / ' + Fmt(y, ''))
     Else If Finite(x) And (Abs(x - y) > Tolerance) Then
      l.Add(Name + ': ' + Fmt(x, '') + ' / ' + Fmt(y, ''));
    End;

   Procedure Text(Const Name, x, y : String);
    Begin
     If x <> y Then
      l.Add(Name + ': ' + x + ' / ' + y);
    End;

  Begin
   If (Trim(Simulator) = '') Or (Trim(RealWorld) = '') Then
    Exit(Tr('Brak dwóch raportów do porównania'));
   a := DecodeMetarReport(Simulator);
   b := DecodeMetarReport(RealWorld);
   If a.NILReport Or b.NILReport Or (a.Station = '') Or (b.Station = '') Then
    Exit(Tr('Brak dwóch raportów do porównania'));
   If a.Station <> b.Station Then
    Exit(Tr('Różne stacje — brak bezpośredniego porównania') + ': ' + a.Station + ' / ' + b.Station);
   l := TStringList.Create;
   Try
    Text('UTC', a.TimeGroup, b.TimeGroup);
    Text(Tr('Znaczniki raportu'), a.Flags, b.Flags);
    Numeric(Tr('Kierunek wiatru'), a.WindDirection, b.WindDirection, 0.1);
    If a.VariableWind <> b.VariableWind Then
     l.Add('VRB');
    Text(Tr('Zmienny kierunek'), a.WindVariable, b.WindVariable);
    Numeric(Tr('Wiatr') + ' [kt]', a.WindKnots, b.WindKnots, 0.51);
    Numeric(Tr('Porywy') + ' [kt]', a.GustKnots, b.GustKnots, 0.51);
    Numeric(Tr('Widzialność') + ' [m]', a.VisibilityMeters, b.VisibilityMeters, 1);
    If (a.VisibilityAtLeast <> b.VisibilityAtLeast) Or (a.VisibilityLess <> b.VisibilityLess) Then
     l.Add(Tr('Granica widzialności'));
    Numeric(Tr('Temperatura') + ' [C]', a.Temperature, b.Temperature, 0.1);
    Numeric(Tr('Punkt rosy') + ' [C]', a.DewPoint, b.DewPoint, 0.1);
    Numeric('QNH [hPa]', a.QNH, b.QNH, 0.51);
    If a.CAVOK <> b.CAVOK Then
     l.Add('CAVOK');
    Text(Tr('Chmury'), a.Clouds, b.Clouds);
    Text(Tr('Zjawiska'), a.Weather, b.Weather);
    Text(Tr('Trend'), a.Trend, b.Trend);
    Text('RMK', a.Remarks, b.Remarks);
    Text(Tr('Pozostałe grupy'), a.Unknown, b.Unknown);
    If l.Count = 0 Then
     Result := Tr('Zgodne rozkodowane pola METAR')
    Else
     Result := Tr('Różnice (MSFS / AviationWeather)') + sLineBreak + l.Text;
   Finally
    l.Free;
   End;
  End;

End.
