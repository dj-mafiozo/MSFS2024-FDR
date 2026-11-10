{$StackFrames On}
Unit FMCScreensU;

Interface

 Uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections, FireDAC.Comp.Client;

 Type
  TFMCScreen = Class
   Provider         : String;
   Device           : String;
   PageKey          : String;
   StyleJSON        : String;
   AnnunciatorsJSON : String;
   Title            : String;
   Available        : Boolean;
   PowerState       : Integer;
   Lines            : TStringList;
   Constructor Create;
   Destructor Destroy; Override;
   Procedure IdentifyPage;
  End;

 Function ExtractFMCScreens(Root : TJSONObject) : TObjectList<TFMCScreen>;
 Function FMCScreenHTML(Screen : TFMCScreen) : String;
 Function ParseFMCValues(Screen : TFMCScreen) : TJSONObject;
 Procedure SaveFMCScreens(DB : TFDConnection; Trip : Integer; Sample : Int64; Const SimUTC : String; Root : TJSONObject; Const CapturedUTC : String = '');
 Function LatestFMCContext(DB : TFDConnection; Trip : Integer; Const EventUTC : String) : TJSONObject;

Implementation

 Uses
  FMCStyleU, Vcl.Graphics, System.StrUtils, System.RegularExpressions, System.DateUtils, Data.DB, FireDAC.Stan.Param, AirbusMCDUValuesU, BoeingFMCValuesU;

 Constructor TFMCScreen.Create;
  Begin
   Inherited Create;
   Lines            := TStringList.Create;
   Lines.LineBreak  := #13#10;
   PowerState       := -1;
   StyleJSON        := '{}';
   AnnunciatorsJSON := '{}';
  End;

 Destructor TFMCScreen.Destroy;
  Begin
   Lines.Free;
   Inherited;
  End;

 Procedure TFMCScreen.IdentifyPage;
  Var
   t    : String;
   Page : TMatch;
  Begin
   Title := '';
   If Lines.Count > 0 Then
    Title := Trim(Lines[0]);
   t      := UpperCase(Title).Replace(' ', '');
   If Not Available Then
    PageKey := 'UNAVAILABLE'
   Else If ((Provider = 'FenixA32X') Or (Provider = 'FBWA32NX')) And (AirbusMCDUPage(Lines) <> '') Then
    PageKey := AirbusMCDUPage(Lines)
   Else If (Pos('PERFINIT', t) > 0) Or (Pos('PREFINIT', t) > 0) Then
    PageKey := 'PERF_INIT'
   Else If Pos('N1LIMIT', t) > 0 Then
    PageKey := 'N1_LIMIT'
   Else If Pos('TAKEOFFREF', t) > 0 Then
    PageKey := 'TAKEOFF_REF'
   Else If (Pos('APPROACHREF', t) > 0) Or (Pos('APPROCHREF', t) > 0) Then
    PageKey := 'APPROACH_REF'
   Else If t = '' Then
    PageKey := 'BLANK'
   Else
    PageKey := 'OTHER:' + Copy(t, 1, 64);
   Page     := TRegEx.Match(Title, '\b(\d{1,2})/(\d{1,2})\b');
   If Page.Success Then
    PageKey := PageKey + ':' + Page.Value;
   If TRegEx.IsMatch(UpperCase(Title), '\b(MOD|TMPY)\b') Then
    PageKey := PageKey + ':MOD';
  End;

 Function Member(o : TJSONObject; Const Name : String) : TJSONValue;
  Begin
   Result := Nil;
   If o <> Nil Then
    Result := o.GetValue(Name);
  End;

 Function TextValue(o : TJSONObject; Const Name, Default : String) : String;
  Var
   v : TJSONValue;
  Begin
   v      := Member(o, Name);
   Result := Default;
   If v Is TJSONString Then
    Result := v.Value;
  End;

 Procedure CaptureIFlyAppearance(Fields : TJSONObject; Device : Integer; Screen : TFMCScreen);
  Const
   Lamps : Array [0..4] Of String = ('FAIL', 'MSG', 'EXEC', 'CALL', 'OFST');
  Var
   Styles     : TJSONObject;
   Indicators : TJSONObject;
   Rows       : TJSONArray;
   Row        : Integer;
   Col        : Integer;
   c          : Integer;
   f          : Integer;
   i          : Integer;
   Hex        : String;
   v          : TJSONValue;

   Function ReadCode(Const Name : String; Max : Integer) : Integer;
    Var
     d : Double;
    Begin
     Result := 15;
     v      := Member(Fields, Name);
     If v Is TJSONNumber Then
      Begin
       d := TJSONNumber(v).AsDouble;
       If (d >= 0) And (d <= Max) And (d = Trunc(d)) Then
        Result := Trunc(d);
      End;
    End;

  Begin
   Styles     := TJSONObject.Create;
   Indicators := TJSONObject.Create;
   Try
    Styles.AddPair('encoding', 'color-font-nibbles-v1');
    Rows := TJSONArray.Create;
    Styles.AddPair('rows', Rows);
    For Row := 0 To 13 Do
     Begin
      Hex     := '';
      For Col := 0 To 23 Do
       Begin
        c   := ReadCode(Format('LSK_Color[%d][%d][%d]', [Device, Row, Col]), 13);
        f   := ReadCode(Format('LSK_SmallFont[%d][%d][%d]', [Device, Row, Col]), 1);
        Hex := Hex + IntToHex(c, 1) + IntToHex(f, 1);
       End;
      Rows.Add(Hex);
     End;
    For i := 0 To High(Lamps) Do
     Begin
      c := ReadCode(Format('CDU_%s_Status[%d]', [Lamps[i], Device]), 2);
      If c = 15 Then
       Indicators.AddPair(Lamps[i], TJSONNull.Create)
      Else
       Indicators.AddPair(Lamps[i], TJSONNumber.Create(c));
     End;
    Screen.StyleJSON        := Styles.ToJSON;
    Screen.AnnunciatorsJSON := Indicators.ToJSON;
   Finally
    Styles.Free;
    Indicators.Free;
   End;
  End;

 Function ExtractFMCScreens(Root : TJSONObject) : TObjectList<TFMCScreen>;
  Var
   Fields : TJSONObject;
   CDUs   : TJSONObject;
   Obj    : TJSONObject;
   p      : TJSONPair;
   s      : TFMCScreen;
   v      : TJSONValue;
   j      : TJSONValue;
   Rows   : TJSONArray;
   Device : Integer;
   Row    : Integer;
   Col    : Integer;
   Code   : Integer;
   Line   : String;
   Ch     : WideChar;
   Good   : Boolean;
  Begin
   Result := TObjectList<TFMCScreen>.Create(True);
   If Root = Nil Then
    Exit;
   Try
    If (TextValue(Root, 'provider', '') = 'iFly737MAX') And Not(Member(Root, 'cdu') Is TJSONObject) Then
     Begin
      Fields := Nil;
      v      := Member(Root, 'fields');
      If v Is TJSONObject Then
       Fields    := TJSONObject(v);
      For Device := 0 To 1 Do
       Begin
        s := TFMCScreen.Create;
        Result.Add(s);
        s.Provider := 'iFly737MAX';
        s.Device   := IntToStr(Device);
        CaptureIFlyAppearance(Fields, Device, s);
        Good    := True;
        For Row := 0 To 13 Do
         Begin
          v := Member(Fields, Format('LSKChar[%d][%d]', [Device, Row]));
          If Not(v Is TJSONString) Or (Length(v.Value) <> 24) Then
           Begin
            Good := False;
            Break;
           End;
          Line    := v.Value;
          For Col := 0 To 23 Do
           Begin
            Ch := Line[Col + 1];
            If Ch = #0 Then
             Ch := ' ';
            j   := Member(Fields, Format('LSK_Color[%d][%d][%d]', [Device, Row, Col]));
            If j Is TJSONNumber Then
             Begin
              Code := TJSONNumber(j).AsInt;
              Case Code Of
               5       : Ch := WideChar($25A1);
               6, 7, 8 : Ch := WideChar($00B0);
               9       : Ch := WideChar($2190);
               10      : Ch := WideChar($2192);
               11      : Ch := WideChar($2191);
               12      : Ch := WideChar($2193);
               13      : Ch := WideChar($25A0);
              End;
             End;
            Line[Col + 1] := Ch;
           End;
          s.Lines.Add(Line);
         End;
        s.Available := Good;
        If Not Good Then
         s.Lines.Clear;
        s.IdentifyPage;
       End;
      Exit;
     End;
    v := Member(Root, 'cdu');
    If Not(v Is TJSONObject) Then
     Exit;
    CDUs := TJSONObject(v);
    For p In CDUs Do
     Begin
      If Not(p.JsonValue Is TJSONObject) Then
       Continue;
      Obj := TJSONObject(p.JsonValue);
      s   := TFMCScreen.Create;
      Result.Add(s);
      s.Provider         := TextValue(Root, 'provider', 'unknown');
      s.Device           := p.JsonString.Value;
      s.StyleJSON        := TextValue(Obj, 'style_json', '{}');
      s.AnnunciatorsJSON := TextValue(Obj, 'annunciators_json', '{}');
      v                  := Member(Obj, 'powered');
      If v Is TJSONBool Then
       s.PowerState := Ord(TJSONBool(v).AsBoolean);
      v             := Member(Obj, 'rows');
      Good          := (v Is TJSONArray) And (TextValue(Obj, 'status', 'available') = 'available');
      If Good Then
       Begin
        Rows := TJSONArray(v);
        Good := Rows.Count = 14;
        If Good Then
         For Row := 0 To 13 Do
          Begin
           v := Rows.Items[Row];
           If Not(v Is TJSONString) Or (Length(v.Value) <> 24) Then
            Begin
             Good := False;
             Break;
            End;
           s.Lines.Add(v.Value.Replace(#0, ' '));
          End;
       End;
      s.Available := Good;
      If Not Good Then
       s.Lines.Clear;
      s.IdentifyPage;
     End;
   Except
    Result.Free;
    Raise;
   End;
  End;

 Function FMCScreenHTML(Screen : TFMCScreen) : String;
  Var
   Style  : TFMCStyle;
   c      : TFMCCellStyle;
   Next   : TFMCCellStyle;
   r      : Integer;
   Col    : Integer;
   Finish : Integer;
   Text   : String;
   CSS    : String;

   Function RGBHex(Color : TColor) : String;
    Var
     n : Cardinal;
    Begin
     n      := ColorToRGB(Color);
     Result := LowerCase(IntToHex(n And 255, 2) + IntToHex((n Shr 8) And 255, 2) + IntToHex((n Shr 16) And 255, 2));
    End;

  Begin
   Result := '';
   If Not Screen.Available Then
    Exit;
   Style := TFMCStyle.Create(Screen.StyleJSON);
   Try
    Result := '<pre style="background:#000;color:#fff;font-family:monospace;white-space:pre;line-height:1.3">';
    For r  := 0 To Screen.Lines.Count - 1 Do
     Begin
      Col := 0;
      While Col < Length(Screen.Lines[r]) Do
       Begin
        c      := Style.Cell(r, Col);
        Finish := Col + 1;
        While Finish < Length(Screen.Lines[r]) Do
         Begin
          Next := Style.Cell(r, Finish);
          If (Next.Foreground <> c.Foreground) Or (Next.Background <> c.Background) Or (Next.Small <> c.Small) Then
           Break;
          Inc(Finish);
         End;
        Text := Copy(Screen.Lines[r], Col + 1, Finish - Col).Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;');
        CSS  := 'color:#' + RGBHex(c.Foreground) + ';background:#' + RGBHex(c.Background) + ';';
        If c.Small Then
         CSS   := CSS + 'font-size:75%;';
        Result := Result + '<span style="display:inline-block;width:' + IntToStr(Finish - Col) + 'ch;' + CSS + '">' + Text + '</span>';
        Col    := Finish;
       End;
      Result := Result + #10;
     End;
   Finally
    Style.Free;
   End;
   Result := Result + '</pre>';
  End;

 Function ParseFMCValues(Screen : TFMCScreen) : TJSONObject;
  Const
   Patterns : Array [0..5] Of String = ('\bV1\b', '\bVR\b', '\bV2\b', '\bVAPP\b', '\bVREF\b', '\bWIND\s*CORR(?:ECTION)?\b');
   Keys : Array [0..5] Of String = ('v1_kt', 'vr_kt', 'v2_kt', 'vapp_kt', 'vref_kt', 'wind_correction_kt');
  Var
   i        : Integer;
   r        : Integer;
   StartCol : Integer;
   m        : TMatch;
   n        : TMatch;
   Line     : String;
   Cell     : String;
   Value    : Double;
   Found    : Boolean;
   FS       : TFormatSettings;
  Begin
   If Screen.Available And (Screen.PowerState <> 0) And ((Screen.Provider = 'FenixA32X') Or (Screen.Provider = 'FBWA32NX')) Then
    Exit(ParseAirbusMCDU(Screen.Lines));
   Result := TJSONObject.Create;
   If Not Screen.Available Or (Screen.PowerState = 0) Then
    Exit;
   ParseBoeingPerformance(Screen.Lines, Result);
   FS                  := TFormatSettings.Create;
   FS.DecimalSeparator := '.';
   For i               := 0 To High(Patterns) Do
    For r              := 1 To Screen.Lines.Count - 1 Do
     Begin
      Line := UpperCase(Screen.Lines[r]);
      m    := TRegEx.Match(Line, Patterns[i]);
      If Not m.Success Then
       Continue;
      Cell := Copy(Line, m.Index + m.Length + 1, MaxInt);
      n    := TRegEx.Match(Cell, '^\s*[:=]?\s*([+-]?\d{1,3}(?:[.,]\d+)?)\s*(?:KTS?|KNOTS)?\s*$');
      If Not n.Success And (i <> 4) And (r + 1 < Screen.Lines.Count) Then
       Begin
        StartCol := 0;
        If m.Index >= 12 Then
         StartCol := 12;
        // QRH proposals occupy the middle column; only the selected right field is a V-speed.
        If (i <= 2) And (m.Index >= 19) Then
         StartCol := 19;
        Cell      := Copy(UpperCase(Screen.Lines[r + 1]), StartCol + 1, 12);
        n         := TRegEx.Match(Cell, '^\s*[<\[*]?\s*([+-]?\d{1,3}(?:[.,]\d+)?)\s*(?:KTS?|KNOTS)?\s*[>\]]?\s*$');
       End;
      Found := n.Success;
      If Found Then
       Found := TryStrToFloat(n.Groups[1].Value.Replace(',', '.'), Value, FS);
      If Found Then
       Begin
        If i = 5 Then
         Found := (Value >= 0) And (Value <= 99)
        Else
         Found := (Value > 0) And (Value < 400);
       End;
      Result.RemovePair(Keys[i]).Free;
      If Found Then
       Result.AddPair(Keys[i], TJSONNumber.Create(Value))
      Else
       Result.AddPair(Keys[i], TJSONNull.Create);
      Break;
     End;
   For r := 1 To Screen.Lines.Count - 2 Do
    Begin
     m := TRegEx.Match(UpperCase(Screen.Lines[r]), '\bFLAP\s*/\s*SPD\b');
     If Not m.Success Then
      Continue;
     // The label is right aligned. Do not read the runway frequency/course on the left.
     StartCol := m.Index;
     Cell     := Copy(UpperCase(Screen.Lines[r + 1]), StartCol + 1, MaxInt);
     n        := TRegEx.Match(Cell, '^\s*(?:[<\[])?\s*(\d{1,2})\s*/\s*(\d{2,3})\s*(?:KTS?)?\s*(?:[>\]])?\s*$');
     Result.RemovePair('vref_kt').Free;
     Result.RemovePair('approach_flaps_deg').Free;
     If n.Success And TryStrToFloat(n.Groups[2].Value, Value, FS) And (Value > 0) And (Value < 400) And (StrToInt(n.Groups[1].Value) > 0) And (StrToInt(n.Groups[1].Value) <= 40) Then
      Begin
       Result.AddPair('vref_kt', TJSONNumber.Create(Value));
       Result.AddPair('approach_flaps_deg', TJSONNumber.Create(StrToInt(n.Groups[1].Value)));
      End
     Else
      Begin
       Result.AddPair('vref_kt', TJSONNull.Create);
       Result.AddPair('approach_flaps_deg', TJSONNull.Create);
      End;
     Break;
    End;
  End;

 Procedure SaveFMCScreens(DB : TFDConnection; Trip : Integer; Sample : Int64; Const SimUTC : String; Root : TJSONObject; Const CapturedUTC : String);
  Var
   Screens : TObjectList<TFMCScreen>;
   s       : TFMCScreen;
   q       : TFDQuery;
   Parsed  : TJSONObject;
   Raw     : String;
   Same    : Boolean;
   Seen    : TDictionary<String, Boolean>;
   Missing : TList<TPair<String, String>>;
   Pair    : TPair<String, String>;
  Begin
   Screens := ExtractFMCScreens(Root);
   q       := TFDQuery.Create(Nil);
   Seen    := TDictionary<String, Boolean>.Create;
   Missing := TList<TPair<String, String>>.Create;
   Try
    q.Connection             := DB;
    q.FormatOptions.StrsTrim := False;
    // A provider/device disappearing must invalidate its current screen, not retain stale text.
    For s In Screens Do
     Seen.AddOrSetValue(s.Provider + #1 + s.Device, True);
    q.Open('select a.provider,a.device from trip_fmc_screens a where a.trip=:t and a.available=1 and not exists(select 1 from trip_fmc_screens b where b.trip=a.trip and b.provider=a.provider and b.device=a.device and b.id>a.id)', [Trip]);
    While Not q.Eof Do
     Begin
      If Not Seen.ContainsKey(q.FieldByName('provider').AsString + #1 + q.FieldByName('device').AsString) Then
       Missing.Add(TPair<String, String>.Create(q.FieldByName('provider').AsString, q.FieldByName('device').AsString));
      q.Next;
     End;
    q.Close;
    For Pair In Missing Do
     Begin
      s          := TFMCScreen.Create;
      s.Provider := Pair.Key;
      s.Device   := Pair.Value;
      s.IdentifyPage;
      Screens.Add(s);
     End;
    For s In Screens Do
     Begin
      Raw := s.Lines.Text;
      q.Open('select available,powered,raw_text,style_json,annunciators_json from trip_fmc_screens where trip=:t and provider=:p and device=:d order by id desc limit 1', [Trip, s.Provider, s.Device]);
      Same := Not q.IsEmpty;

      If Same Then
       Same := (q.FieldByName('available').AsInteger = Ord(s.Available)) And (q.FieldByName('powered').AsInteger = s.PowerState) And (q.FieldByName('raw_text').AsString = Raw) And (q.FieldByName('style_json').AsString = s.StyleJSON) And (q.FieldByName('annunciators_json').AsString = s.AnnunciatorsJSON);
      q.Close;
      If Same Then
       Continue;
      Parsed := ParseFMCValues(s);
      Try
       q.SQL.Text                    := 'insert into trip_fmc_screens(trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json,style_json,annunciators_json,formatted_html) values(:t,:s,:z,:u,:p,:d,:k,:h,:a,:w,:r,:' + 'j,:style,:lamps,:html)';
       q.ParamByName('t').AsInteger  := Trip;
       q.ParamByName('s').AsLargeInt := Sample;
       q.ParamByName('z').AsString   := SimUTC;
       If CapturedUTC <> '' Then
        q.ParamByName('u').AsString := CapturedUTC
       Else
        q.ParamByName('u').AsString := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
       q.ParamByName('p').AsString  := s.Provider;
       q.ParamByName('d').AsString  := s.Device;
       q.ParamByName('k').AsString  := s.PageKey;
       q.ParamByName('h').AsString  := s.Title;
       q.ParamByName('a').AsInteger := Ord(s.Available);
       q.ParamByName('w').AsInteger := s.PowerState;
       q.ParamByName('r').DataType  := ftWideMemo;
       If s.Available Then
        q.ParamByName('r').AsWideString := Raw
       Else
        q.ParamByName('r').Clear;
       q.ParamByName('j').AsWideString     := Parsed.ToJSON;
       q.ParamByName('style').AsWideString := s.StyleJSON;
       q.ParamByName('lamps').AsWideString := s.AnnunciatorsJSON;
       q.ParamByName('html').AsWideString  := FMCScreenHTML(s);
       q.ExecSQL;
      Finally
       Parsed.Free;
      End;
     End;
   Finally
    Missing.Free;
    Seen.Free;
    q.Free;
    Screens.Free;
   End;
  End;

 Function LatestFMCContext(DB : TFDConnection; Trip : Integer; Const EventUTC : String) : TJSONObject;
  Var
   q              : TFDQuery;
   Screens        : TDictionary<String, TJSONObject>;
   Pages          : TDictionary<String, TJSONObject>;
   Values         : TJSONObject;
   Obj            : TJSONObject;
   Parsed         : TJSONObject;
   Ref            : TJSONObject;
   DeviceValues   : TJSONObject;
   ReparsedScreen : TFMCScreen;
   p              : TJSONPair;
   Key            : String;
   Pair           : TPair<String, TJSONObject>;
   a              : TJSONArray;

   Procedure Replace(d : TDictionary<String, TJSONObject>; Const k : String; o : TJSONObject);
    Var
     Old : TJSONObject;
    Begin
     If d.TryGetValue(k, Old) Then
      Old.Free;
     d.AddOrSetValue(k, o);
    End;

   Procedure Output(Const Name : String; d : TDictionary<String, TJSONObject>);
    Var
     Item : TPair<String, TJSONObject>;
    Begin
     a := TJSONArray.Create;
     Result.AddPair(Name, a);
     For Item In d Do
      a.AddElement(TJSONObject.ParseJSONValue(Item.Value.ToJSON) As TJSONObject);
    End;

  Begin
   Result  := TJSONObject.Create;
   q       := TFDQuery.Create(Nil);
   Screens := TDictionary<String, TJSONObject>.Create;
   Pages   := TDictionary<String, TJSONObject>.Create;
   Values  := TJSONObject.Create;
   Result.AddPair('last_values_by_device', Values);
   Try
    Try
     Result.AddPair('as_of_event_utc', EventUTC);
     Result.AddPair('timestamp_semantics', 'Timestamps identify the first observation of a changed screen. Repeated identical reads are omitted. Device histories and pending MOD pages remain separate.');
     Result.AddPair('boeing_performance_semantics', 'N1 LIMIT and TAKEOFF REF N1 values are displayed limits/targets, not measured engine speeds. ACT and SEL are separate for takeoff (left) and climb (right). ' + 'A missing assumed temperature is not OAT. Weights/fuel ending in _display retain FMC display units; KG/LB cannot be inferred from these pages alone. ' +
     'Selected FLAP/SPD supplies approach_flaps_deg and VREF; wind correction remains separate. CG is percent MAC and takeoff trim is in stabilizer trim units.');
     Result.AddPair('semantics', 'Last observed screens/pages from this trip at or before the event, including observations before the analysis window. Hidden pages are not continuously refreshed. ' + 'Times are observation times, not proven FMC edit times. Raw text preserves fixed columns/rows. Typed SDK references take precedence over text parsing. ' +
     'MOD pages are pending, not executed active values. Unknown power=-1. Power-off/unavailable screens do not provide new parsed values. VREF tables are not collapsed to a guessed selected speed.');
     q.Connection             := DB;
     q.FormatOptions.StrsTrim := False;
     q.Open('select * from trip_fmc_screens where trip=:t and substr(time_zulu,1,23)<=:u order by time_zulu,id', [Trip, Copy(EventUTC, 1, 23)]);
     While Not q.Eof Do
      Begin
       Obj := TJSONObject.Create;
       Obj.AddPair('provider', q.FieldByName('provider').AsString);
       Obj.AddPair('device', q.FieldByName('device').AsString);
       Obj.AddPair('page', q.FieldByName('page_key').AsString);
       Obj.AddPair('title', q.FieldByName('title').AsString);
       Obj.AddPair('observed_sim_utc', q.FieldByName('time_zulu').AsString);
       Obj.AddPair('captured_utc', q.FieldByName('captured_utc').AsString);
       Obj.AddPair('available', TJSONBool.Create(q.FieldByName('available').AsInteger <> 0));
       Obj.AddPair('power_state', TJSONNumber.Create(q.FieldByName('powered').AsInteger));
       If q.FieldByName('raw_text').IsNull Then
        Obj.AddPair('raw_text', TJSONNull.Create)
       Else
        Obj.AddPair('raw_text', q.FieldByName('raw_text').AsWideString);
       Parsed := TJSONObject.ParseJSONValue(q.FieldByName('parsed_json').AsString) As TJSONObject;
       If Parsed = Nil Then
        Parsed := TJSONObject.Create;
       // Reparse all saved raw screens with the current parser; preserve the original database.
       If Not q.FieldByName('raw_text').IsNull Then
        Begin
         ReparsedScreen := TFMCScreen.Create;
         Try
          ReparsedScreen.Provider   := q.FieldByName('provider').AsString;
          ReparsedScreen.Available  := q.FieldByName('available').AsInteger <> 0;
          ReparsedScreen.PowerState := q.FieldByName('powered').AsInteger;
          ReparsedScreen.Lines.Text := q.FieldByName('raw_text').AsWideString;
          ReparsedScreen.IdentifyPage;
          Parsed.Free;
          Parsed := Nil;
          Parsed := ParseFMCValues(ReparsedScreen);
          Obj.RemovePair('page').Free;
          Obj.AddPair('page', ReparsedScreen.PageKey);
         Finally
          ReparsedScreen.Free;
         End;
        End;
       Obj.AddPair('parsed', Parsed);
       If Not q.FieldByName('annunciators_json').IsNull Then
        Obj.AddPair('annunciators', TJSONObject.ParseJSONValue(q.FieldByName('annunciators_json').AsString));
       Key := q.FieldByName('provider').AsString + #1 + q.FieldByName('device').AsString;
       If (q.FieldByName('available').AsInteger <> 0) And (q.FieldByName('powered').AsInteger <> 0) And (Obj.GetValue('page').Value <> 'BLANK') Then
        Begin
         Replace(Pages, Key + #1 + Obj.GetValue('page').Value, TJSONObject.ParseJSONValue(Obj.ToJSON) As TJSONObject);
         If Pos(':MOD', Obj.GetValue('page').Value) = 0 Then
          For p In Parsed Do
           Begin
            Ref := TJSONObject.Create;
            Ref.AddPair('value', TJSONObject.ParseJSONValue(p.JsonValue.ToJSON));
            Ref.AddPair('provider', q.FieldByName('provider').AsString);
            Ref.AddPair('device', q.FieldByName('device').AsString);
            Ref.AddPair('page', Obj.GetValue('page').Value);
            Ref.AddPair('observed_sim_utc', q.FieldByName('time_zulu').AsString);
            DeviceValues := Values.GetValue(q.FieldByName('provider').AsString + '/' + q.FieldByName('device').AsString) As TJSONObject;
            If DeviceValues = Nil Then
             Begin
              DeviceValues := TJSONObject.Create;
              Values.AddPair(q.FieldByName('provider').AsString + '/' + q.FieldByName('device').AsString, DeviceValues);
             End;
            DeviceValues.RemovePair(p.JsonString.Value).Free;
            DeviceValues.AddPair(p.JsonString.Value, Ref);
           End;
        End;
       Replace(Screens, Key, Obj);
       q.Next;
      End;
     Output('last_screen_per_device', Screens);
     Output('last_observed_pages', Pages);
    Except
     Result.Free;
     Raise;
    End;
   Finally
    For Pair In Screens Do
     Pair.Value.Free;
    For Pair In Pages Do
     Pair.Value.Free;
    Pages.Free;
    Screens.Free;
    q.Free;
   End;
  End;

End.
