Unit FMCScreensU;

Interface

 Uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections, FireDAC.Comp.Client;

 Type
  TFMCScreen = Class
   Public
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
  System.StrUtils, System.RegularExpressions, System.DateUtils, Data.DB, FireDAC.Stan.Param, AirbusMCDUValuesU, BoeingFMCValuesU;

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
   T    : String;
   Page : TMatch;
  Begin
   Title := '';
   If Lines.Count > 0 Then
    Title := Trim(Lines[0]);
   T      := UpperCase(Title).Replace(' ', '');
   If Not Available Then
    PageKey := 'UNAVAILABLE'
   Else If ((Provider = 'FenixA32X') Or (Provider = 'FBWA32NX')) And (AirbusMCDUPage(Lines) <> '') Then
    PageKey := AirbusMCDUPage(Lines)
   Else If (Pos('PERFINIT', T) > 0) Or (Pos('PREFINIT', T) > 0) Then
    PageKey := 'PERF_INIT'
   Else If Pos('N1LIMIT', T) > 0 Then
    PageKey := 'N1_LIMIT'
   Else If Pos('TAKEOFFREF', T) > 0 Then
    PageKey := 'TAKEOFF_REF'
   Else If (Pos('APPROACHREF', T) > 0) Or (Pos('APPROCHREF', T) > 0) Then
    PageKey := 'APPROACH_REF'
   Else If T = '' Then
    PageKey := 'BLANK'
   Else
    PageKey := 'OTHER:' + Copy(T, 1, 64);
   Page     := TRegEx.Match(Title, '\b(\d{1,2})/(\d{1,2})\b');
   If Page.Success Then
    PageKey := PageKey + ':' + Page.Value;
   If TRegEx.IsMatch(UpperCase(Title), '\b(MOD|TMPY)\b') Then
    PageKey := PageKey + ':MOD';
  End;

 Function Member(O : TJSONObject; Const Name : String) : TJSONValue;
  Begin
   Result := Nil;
   If O <> Nil Then
    Result := O.GetValue(Name);
  End;

 Function TextValue(O : TJSONObject; Const Name, Default : String) : String;
  Var
   V : TJSONValue;
  Begin
   V      := Member(O, Name);
   Result := Default;
   If V Is TJSONString Then
    Result := V.Value;
  End;

 Procedure CaptureIFlyAppearance(Fields : TJSONObject; Device : Integer; Screen : TFMCScreen);
  Const
   Lamps : Array [0 .. 4] Of String = ('FAIL', 'MSG', 'EXEC', 'CALL', 'OFST');
  Var
   Styles     : TJSONObject;
   Indicators : TJSONObject;
   Rows       : TJSONArray;
   Row        : Integer;
   Col        : Integer;
   C          : Integer;
   F          : Integer;
   I          : Integer;
   Hex        : String;
   V          : TJSONValue;

   Function ReadCode(Const Name : String; Max : Integer) : Integer;
    Var
     D : Double;
    Begin
     Result := 15;
     V      := Member(Fields, Name);
     If V Is TJSONNumber Then
      Begin
       D := TJSONNumber(V).AsDouble;
       If (D >= 0) And (D <= Max) And (D = Trunc(D)) Then
        Result := Trunc(D);
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
        C   := ReadCode(Format('LSK_Color[%d][%d][%d]', [Device, Row, Col]), 13);
        F   := ReadCode(Format('LSK_SmallFont[%d][%d][%d]', [Device, Row, Col]), 1);
        Hex := Hex + IntToHex(C, 1) + IntToHex(F, 1);
       End;
      Rows.Add(Hex);
     End;
    For I := 0 To High(Lamps) Do
     Begin
      C := ReadCode(Format('CDU_%s_Status[%d]', [Lamps[I], Device]), 2);
      If C = 15 Then
       Indicators.AddPair(Lamps[I], TJSONNull.Create)
      Else
       Indicators.AddPair(Lamps[I], TJSONNumber.Create(C));
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
   P      : TJSONPair;
   S      : TFMCScreen;
   V      : TJSONValue;
   J      : TJSONValue;
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
      V      := Member(Root, 'fields');
      If V Is TJSONObject Then
       Fields    := TJSONObject(V);
      For Device := 0 To 1 Do
       Begin
        S := TFMCScreen.Create;
        Result.Add(S);
        S.Provider := 'iFly737MAX';
        S.Device   := IntToStr(Device);
        CaptureIFlyAppearance(Fields, Device, S);
        Good    := True;
        For Row := 0 To 13 Do
         Begin
          V := Member(Fields, Format('LSKChar[%d][%d]', [Device, Row]));
          If Not(V Is TJSONString) Or (Length(V.Value) <> 24) Then
           Begin
            Good := False;
            Break;
           End;
          Line    := V.Value;
          For Col := 0 To 23 Do
           Begin
            Ch := Line[Col + 1];
            If Ch = #0 Then
             Ch := ' ';
            J   := Member(Fields, Format('LSK_Color[%d][%d][%d]', [Device, Row, Col]));
            If J Is TJSONNumber Then
             Begin
              Code := TJSONNumber(J).AsInt;
              Case Code Of
               5 :
                Ch := WideChar($25A1);
               6, 7, 8 :
                Ch := WideChar($00B0);
               9 :
                Ch := WideChar($2190);
               10 :
                Ch := WideChar($2192);
               11 :
                Ch := WideChar($2191);
               12 :
                Ch := WideChar($2193);
               13 :
                Ch := WideChar($25A0);
              End;
             End;
            Line[Col + 1] := Ch;
           End;
          S.Lines.Add(Line);
         End;
        S.Available := Good;
        If Not Good Then
         S.Lines.Clear;
        S.IdentifyPage;
       End;
      Exit;
     End;
    V := Member(Root, 'cdu');
    If Not(V Is TJSONObject) Then
     Exit;
    CDUs := TJSONObject(V);
    For P In CDUs Do
     Begin
      If Not(P.JsonValue Is TJSONObject) Then
       Continue;
      Obj := TJSONObject(P.JsonValue);
      S   := TFMCScreen.Create;
      Result.Add(S);
      S.Provider         := TextValue(Root, 'provider', 'unknown');
      S.Device           := P.JsonString.Value;
      S.StyleJSON        := TextValue(Obj, 'style_json', '{}');
      S.AnnunciatorsJSON := TextValue(Obj, 'annunciators_json', '{}');
      V                  := Member(Obj, 'powered');
      If V Is TJSONBool Then
       S.PowerState := Ord(TJSONBool(V).AsBoolean);
      V             := Member(Obj, 'rows');
      Good          := (V Is TJSONArray) And (TextValue(Obj, 'status', 'available') = 'available');
      If Good Then
       Begin
        Rows := TJSONArray(V);
        Good := Rows.Count = 14;
        If Good Then
         For Row := 0 To 13 Do
          Begin
           V := Rows.Items[Row];
           If Not(V Is TJSONString) Or (Length(V.Value) <> 24) Then
            Begin
             Good := False;
             Break;
            End;
           S.Lines.Add(V.Value.Replace(#0, ' '));
          End;
       End;
      S.Available := Good;
      If Not Good Then
       S.Lines.Clear;
      S.IdentifyPage;
     End;
   Except
    Result.Free;
    Raise;
   End;
  End;

 Function FMCScreenHTML(Screen : TFMCScreen) : String;
  Var
   Style  : TJSONValue;
   Rows   : TJSONArray;
   V      : TJSONValue;
   R      : Integer;
   C      : Integer;
   Finish : Integer;
   Color  : Integer;
   Font   : Integer;
   Codes  : String;
   Code   : String;
   Text   : String;
   CSS    : String;

   Function Escape(Const S : String) : String;
    Begin
     Result := S.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;');
    End;

  Begin
   Result := '';
   If Not Screen.Available Then
    Exit;
   Style := TJSONObject.ParseJSONValue(Screen.StyleJSON);
   Rows  := Nil;
   Try
    If Style Is TJSONObject Then
     Begin
      V := TJSONObject(Style).GetValue('rows');
      If V Is TJSONArray Then
       Rows := TJSONArray(V);
     End;
    Result := '<pre style="background:#000;color:#fff;font-family:monospace;white-space:pre;line-height:1.3">';
    For R  := 0 To Screen.Lines.Count - 1 Do
     Begin
      Codes := '';
      If (Rows <> Nil) And (R < Rows.Count) Then
       Codes := Rows.Items[R].Value;
      C      := 1;
      While C <= Length(Screen.Lines[R]) Do
       Begin
        Code   := Copy(Codes, (C - 1) * 2 + 1, 2);
        Finish := C + 1;
        While (Finish <= Length(Screen.Lines[R])) And (Copy(Codes, (Finish - 1) * 2 + 1, 2) = Code) Do
         Inc(Finish);
        Color := 15;
        Font  := 15;
        If Length(Code) = 2 Then
         Begin
          Color := StrToIntDef('$' + Code[1], 15);
          Font  := StrToIntDef('$' + Code[2], 15);
         End;
        CSS := '';
        Case Color Of
         1 :
          CSS := 'color:#00ff00;';
         2 :
          CSS := 'color:#00ffff;';
         3, 8 :
          CSS := 'color:#ff00ff;';
         4, 7 :
          CSS := 'background:#666;';
        End;
        Text := Escape(Copy(Screen.Lines[R], C, Finish - C));
        If Font = 1 Then
         Text  := '<span style="font-size:75%">' + Text + '</span>';
        Result := Result + '<span style="display:inline-block;width:' + IntToStr(Finish - C) + 'ch;' + CSS + '">' + Text + '</span>';
        C      := Finish;
       End;
      Result := Result + #10;
     End;
    Result := Result + '</pre>';
   Finally
    Style.Free;
   End;
  End;

 Function ParseFMCValues(Screen : TFMCScreen) : TJSONObject;
  Const
   Patterns : Array [0 .. 5] Of String = ('\bV1\b', '\bVR\b', '\bV2\b', '\bVAPP\b', '\bVREF\b', '\bWIND\s*CORR(?:ECTION)?\b');
   Keys : Array [0 .. 5] Of String     = ('v1_kt', 'vr_kt', 'v2_kt', 'vapp_kt', 'vref_kt', 'wind_correction_kt');
  Var
   I        : Integer;
   R        : Integer;
   StartCol : Integer;
   M        : TMatch;
   N        : TMatch;
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
   For I               := 0 To High(Patterns) Do
    For R              := 1 To Screen.Lines.Count - 1 Do
     Begin
      Line := UpperCase(Screen.Lines[R]);
      M    := TRegEx.Match(Line, Patterns[I]);
      If Not M.Success Then
       Continue;
      Cell := Copy(Line, M.Index + M.Length + 1, MaxInt);
      N    := TRegEx.Match(Cell, '^\s*[:=]?\s*([+-]?\d{1,3}(?:[.,]\d+)?)\s*(?:KTS?|KNOTS)?\s*$');
      If Not N.Success And (I <> 4) And (R + 1 < Screen.Lines.Count) Then
       Begin
        StartCol := 0;
        If M.Index >= 12 Then
         StartCol := 12;
        // QRH proposals occupy the middle column; only the selected right field is a V-speed.
        If (I <= 2) And (M.Index >= 19) Then
         StartCol := 19;
        Cell      := Copy(UpperCase(Screen.Lines[R + 1]), StartCol + 1, 12);
        N         := TRegEx.Match(Cell, '^\s*[<\[*]?\s*([+-]?\d{1,3}(?:[.,]\d+)?)\s*(?:KTS?|KNOTS)?\s*[>\]]?\s*$');
       End;
      Found := N.Success;
      If Found Then
       Found := TryStrToFloat(N.Groups[1].Value.Replace(',', '.'), Value, FS);
      If Found Then
       Begin
        If I = 5 Then
         Found := (Value >= 0) And (Value <= 99)
        Else
         Found := (Value > 0) And (Value < 400);
       End;
      Result.RemovePair(Keys[I]).Free;
      If Found Then
       Result.AddPair(Keys[I], TJSONNumber.Create(Value))
      Else
       Result.AddPair(Keys[I], TJSONNull.Create);
      Break;
     End;
   For R := 1 To Screen.Lines.Count - 2 Do
    Begin
     M := TRegEx.Match(UpperCase(Screen.Lines[R]), '\bFLAP\s*/\s*SPD\b');
     If Not M.Success Then
      Continue;
     // The label is right aligned. Do not read the runway frequency/course on the left.
     StartCol := M.Index;
     Cell     := Copy(UpperCase(Screen.Lines[R + 1]), StartCol + 1, MaxInt);
     N        := TRegEx.Match(Cell, '^\s*(?:[<\[])?\s*(\d{1,2})\s*/\s*(\d{2,3})\s*(?:KTS?)?\s*(?:[>\]])?\s*$');
     Result.RemovePair('vref_kt').Free;
     Result.RemovePair('approach_flaps_deg').Free;
     If N.Success And TryStrToFloat(N.Groups[2].Value, Value, FS) And (Value > 0) And (Value < 400) And (StrToInt(N.Groups[1].Value) > 0) And (StrToInt(N.Groups[1].Value) <= 40) Then
      Begin
       Result.AddPair('vref_kt', TJSONNumber.Create(Value));
       Result.AddPair('approach_flaps_deg', TJSONNumber.Create(StrToInt(N.Groups[1].Value)));
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
   S       : TFMCScreen;
   Q       : TFDQuery;
   Parsed  : TJSONObject;
   Raw     : String;
   Same    : Boolean;
   Seen    : TDictionary<String, Boolean>;
   Missing : TList<TPair<String, String>>;
   Pair    : TPair<String, String>;
  Begin
   Screens := ExtractFMCScreens(Root);
   Q       := TFDQuery.Create(Nil);
   Seen    := TDictionary<String, Boolean>.Create;
   Missing := TList < TPair < String, String >>.Create;
   Try
    Q.Connection             := DB;
    Q.FormatOptions.StrsTrim := False;
    // A provider/device disappearing must invalidate its current screen, not retain stale text.
    For S In Screens Do
     Seen.AddOrSetValue(S.Provider + #1 + S.Device, True);
    Q.Open('select a.provider,a.device from trip_fmc_screens a where a.trip=:t and a.available=1 and not exists(select 1 from trip_fmc_screens b where b.trip=a.trip and b.provider=a.provider and b.device=a.device and b.id>a.id)', [Trip]);
    While Not Q.Eof Do
     Begin
      If Not Seen.ContainsKey(Q.FieldByName('provider').AsString + #1 + Q.FieldByName('device').AsString) Then
       Missing.Add(TPair<String, String>.Create(Q.FieldByName('provider').AsString, Q.FieldByName('device').AsString));
      Q.Next;
     End;
    Q.Close;
    For Pair In Missing Do
     Begin
      S          := TFMCScreen.Create;
      S.Provider := Pair.Key;
      S.Device   := Pair.Value;
      S.IdentifyPage;
      Screens.Add(S);
     End;
    For S In Screens Do
     Begin
      Raw := S.Lines.Text;
      Q.Open('select available,powered,raw_text,style_json,annunciators_json from trip_fmc_screens where trip=:t and provider=:p and device=:d order by id desc limit 1', [Trip, S.Provider, S.Device]);
      Same := Not Q.IsEmpty;

      If Same Then
       Same := (Q.FieldByName('available').AsInteger = Ord(S.Available)) And (Q.FieldByName('powered').AsInteger = S.PowerState) And (Q.FieldByName('raw_text').AsString = Raw) And (Q.FieldByName('style_json').AsString = S.StyleJSON) And (Q.FieldByName('annunciators_json').AsString = S.AnnunciatorsJSON);
      Q.Close;
      If Same Then
       Continue;
      Parsed := ParseFMCValues(S);
      Try
       Q.SQL.Text                    := 'insert into trip_fmc_screens(trip,sample,time_zulu,captured_utc,provider,device,page_key,title,available,powered,raw_text,parsed_json,style_json,annunciators_json,formatted_html) values(:t,:s,:z,:u,:p,:d,:k,:h,:a,:w,:r,:' + 'j,:style,:lamps,:html)';
       Q.ParamByName('t').AsInteger  := Trip;
       Q.ParamByName('s').AsLargeInt := Sample;
       Q.ParamByName('z').AsString   := SimUTC;
       If CapturedUTC <> '' Then
        Q.ParamByName('u').AsString := CapturedUTC
       Else
        Q.ParamByName('u').AsString := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
       Q.ParamByName('p').AsString  := S.Provider;
       Q.ParamByName('d').AsString  := S.Device;
       Q.ParamByName('k').AsString  := S.PageKey;
       Q.ParamByName('h').AsString  := S.Title;
       Q.ParamByName('a').AsInteger := Ord(S.Available);
       Q.ParamByName('w').AsInteger := S.PowerState;
       Q.ParamByName('r').DataType  := ftWideMemo;
       If S.Available Then
        Q.ParamByName('r').AsWideString := Raw
       Else
        Q.ParamByName('r').Clear;
       Q.ParamByName('j').AsWideString     := Parsed.ToJSON;
       Q.ParamByName('style').AsWideString := S.StyleJSON;
       Q.ParamByName('lamps').AsWideString := S.AnnunciatorsJSON;
       Q.ParamByName('html').AsWideString  := FMCScreenHTML(S);
       Q.ExecSQL;
      Finally
       Parsed.Free;
      End;
     End;
   Finally
    Missing.Free;
    Seen.Free;
    Q.Free;
    Screens.Free;
   End;
  End;

 Function LatestFMCContext(DB : TFDConnection; Trip : Integer; Const EventUTC : String) : TJSONObject;
  Var
   Q              : TFDQuery;
   Screens        : TDictionary<String, TJSONObject>;
   Pages          : TDictionary<String, TJSONObject>;
   Values         : TJSONObject;
   Obj            : TJSONObject;
   Parsed         : TJSONObject;
   Ref            : TJSONObject;
   DeviceValues   : TJSONObject;
   ReparsedScreen : TFMCScreen;
   P              : TJSONPair;
   Key            : String;
   Pair           : TPair<String, TJSONObject>;
   A              : TJSONArray;
   Procedure Replace(D : TDictionary<String, TJSONObject>; Const K : String; O : TJSONObject);
    Var
     Old : TJSONObject;
    Begin
     If D.TryGetValue(K, Old) Then
      Old.Free;
     D.AddOrSetValue(K, O);
    End;
   Procedure Output(Const Name : String; D : TDictionary<String, TJSONObject>);
    Var
     Item : TPair<String, TJSONObject>;
    Begin
     A := TJSONArray.Create;
     Result.AddPair(Name, A);
     For Item In D Do
      A.AddElement(TJSONObject.ParseJSONValue(Item.Value.ToJSON) As TJSONObject);
    End;

  Begin
   Result  := TJSONObject.Create;
   Q       := TFDQuery.Create(Nil);
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
     Q.Connection             := DB;
     Q.FormatOptions.StrsTrim := False;
     Q.Open('select * from trip_fmc_screens where trip=:t and substr(time_zulu,1,23)<=:u order by time_zulu,id', [Trip, Copy(EventUTC, 1, 23)]);
     While Not Q.Eof Do
      Begin
       Obj := TJSONObject.Create;
       Obj.AddPair('provider', Q.FieldByName('provider').AsString);
       Obj.AddPair('device', Q.FieldByName('device').AsString);
       Obj.AddPair('page', Q.FieldByName('page_key').AsString);
       Obj.AddPair('title', Q.FieldByName('title').AsString);
       Obj.AddPair('observed_sim_utc', Q.FieldByName('time_zulu').AsString);
       Obj.AddPair('captured_utc', Q.FieldByName('captured_utc').AsString);
       Obj.AddPair('available', TJSONBool.Create(Q.FieldByName('available').AsInteger <> 0));
       Obj.AddPair('power_state', TJSONNumber.Create(Q.FieldByName('powered').AsInteger));
       If Q.FieldByName('raw_text').IsNull Then
        Obj.AddPair('raw_text', TJSONNull.Create)
       Else
        Obj.AddPair('raw_text', Q.FieldByName('raw_text').AsWideString);
       Parsed := TJSONObject.ParseJSONValue(Q.FieldByName('parsed_json').AsString) As TJSONObject;
       If Parsed = Nil Then
        Parsed := TJSONObject.Create;
       // Reparse all saved raw screens with the current parser; preserve the original database.
       If Not Q.FieldByName('raw_text').IsNull Then
        Begin
         ReparsedScreen := TFMCScreen.Create;
         Try
          ReparsedScreen.Provider   := Q.FieldByName('provider').AsString;
          ReparsedScreen.Available  := Q.FieldByName('available').AsInteger <> 0;
          ReparsedScreen.PowerState := Q.FieldByName('powered').AsInteger;
          ReparsedScreen.Lines.Text := Q.FieldByName('raw_text').AsWideString;
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
       If Not Q.FieldByName('annunciators_json').IsNull Then
        Obj.AddPair('annunciators', TJSONObject.ParseJSONValue(Q.FieldByName('annunciators_json').AsString));
       Key := Q.FieldByName('provider').AsString + #1 + Q.FieldByName('device').AsString;
       If (Q.FieldByName('available').AsInteger <> 0) And (Q.FieldByName('powered').AsInteger <> 0) And (Obj.GetValue('page').Value <> 'BLANK') Then
        Begin
         Replace(Pages, Key + #1 + Obj.GetValue('page').Value, TJSONObject.ParseJSONValue(Obj.ToJSON) As TJSONObject);
         If Pos(':MOD', Obj.GetValue('page').Value) = 0 Then
          For P In Parsed Do
           Begin
            Ref := TJSONObject.Create;
            Ref.AddPair('value', TJSONObject.ParseJSONValue(P.JsonValue.ToJSON));
            Ref.AddPair('provider', Q.FieldByName('provider').AsString);
            Ref.AddPair('device', Q.FieldByName('device').AsString);
            Ref.AddPair('page', Obj.GetValue('page').Value);
            Ref.AddPair('observed_sim_utc', Q.FieldByName('time_zulu').AsString);
            DeviceValues := Values.GetValue(Q.FieldByName('provider').AsString + '/' + Q.FieldByName('device').AsString) As TJSONObject;
            If DeviceValues = Nil Then
             Begin
              DeviceValues := TJSONObject.Create;
              Values.AddPair(Q.FieldByName('provider').AsString + '/' + Q.FieldByName('device').AsString, DeviceValues);
             End;
            DeviceValues.RemovePair(P.JsonString.Value).Free;
            DeviceValues.AddPair(P.JsonString.Value, Ref);
           End;
        End;
       Replace(Screens, Key, Obj);
       Q.Next;
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
    Q.Free;
   End;
  End;

End.
