{$StackFrames On}
Unit frmSimBriefFrameU;

Interface

 Uses
  LocalizationU, i18nLocalizer, i18nCore, System.Classes, System.SysUtils,
  System.JSON, System.IniFiles, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, System.Generics.Collections, System.Types,
  Vcl.AppEvnts, Winapi.Windows, FireDAC.Comp.Client, SimBriefImportU, SimBriefMapsU,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList, Vcl.ComCtrls,
  Vcl.ToolWin;

 Type
  TfraSimBrief = Class(TFrame)
    aAttach       : TAction;
    ActionList    : TActionList;
    aFetch        : TAction;
    aOFP          : TAction;
    aOlder        : TAction;
    AppTranslator : TTranslator;
    aRecorded     : TAction;
    aWindow       : TAction;
    btnAttach     : TToolButton;
    btnFetch      : TToolButton;
    btnOFP        : TToolButton;
    btnOlder      : TToolButton;
    btnRecorded   : TToolButton;
    btnWindow     : TToolButton;
    eAccount      : TEdit;
    FetchTimer    : TTimer;
    ImageList     : TImageList;
    lStatus       : TLabel;
    Sections      : TScrollBox;
    ToolBar1      : TToolBar;
    ToolButton1   : TToolButton;
    ToolButton5   : TToolButton;
    ToolButton7   : TToolButton;
    Tools         : TPanel;
    WheelEvents   : TApplicationEvents;
    Procedure WheelMessage(Var Msg : TMsg; Var Handled : Boolean);
    Procedure aOlderExecute(Sender : TObject);
    Procedure aFetchExecute(Sender : TObject);
    Procedure aRecordedExecute(Sender : TObject);
    Procedure aAttachExecute(Sender : TObject);
    Procedure aOFPExecute(Sender : TObject);
    Procedure aWindowExecute(Sender : TObject);
    Procedure FetchTick(Sender : TObject);
    Procedure ToggleSection(Sender : TObject);
    Procedure ResizeCards(Sender : TObject);
   Private
    fMapsFetch        : TSimBriefMapsFetch;
    fMapImages        : TArray<TSimBriefMap>;
    fMapsKey          : String;
    fMapsAttemptedKey : String;
    fResizingCards    : Boolean;
    fLocalized        : Boolean;
    fConfig           : TMemIniFile;
    fConnection       : TFDConnection;
    fTrip             : Integer;
    fReadOnly         : Boolean;
    fPayload          : String;
    fFetch            : TSimBriefFetch;
    fWheelRemainder   : Integer;
    Procedure PrepareMaps;
    Procedure StartMapFetch;
    Procedure RenderMaps;
    Procedure AddSection(Const Key, Title, Text : String; Expanded : Boolean);
    Function SectionText(Root : TJSONObject; Const Paths : String) : String;
    Function CardText(Root : TJSONObject; Const Specs : String) : String;
    Function MemoSectionHeight(Memo : TMemo) : Integer;
   Protected
    Procedure Loaded; Override;
    Procedure SetParent(AParent : TWinControl); Override;
   Public
    Procedure Retranslate;
    Destructor Destroy; Override;
    Procedure Configure(Config : TMemIniFile);
    Procedure SetTrip(Connection : TFDConnection; Trip : Integer);
    Procedure LoadPayload(Const Payload, Source : String);
    Property ReadOnly : Boolean Read fReadOnly Write fReadOnly;
    Property Payload  : String Read fPayload;
  End;

Implementation

 Uses
  System.IOUtils, System.NetEncoding, System.RegularExpressions, Winapi.Messages,
  Vcl.Dialogs, Vcl.Graphics, System.Math, fraSimBriefMapU, frmReportU, frmSimBriefU;

{$R *.dfm}

 Procedure TfraSimBrief.Loaded;
  Begin
   Inherited;
   // Keep the application-event component in DFM, but do not stream this
   // signature through the source-only inline-frame designer.
   If Not(csDesigning In ComponentState) And (WheelEvents <> Nil) Then
    WheelEvents.OnMessage := WheelMessage;
  End;

 Procedure TfraSimBrief.SetParent(AParent : TWinControl);
  Begin
   Inherited;
   If (AParent <> Nil) And Not fLocalized Then
    Begin
     LocalizeRoot(Self);
     fLocalized := True;
    End;
  End;

 Procedure TfraSimBrief.Retranslate;
  Begin
   If fPayload <> '' Then
    LoadPayload(fPayload, '');
  End;

 Procedure TfraSimBrief.WheelMessage(Var Msg : TMsg; Var Handled : Boolean);
  Var
   p     : TPoint;
   r     : TRect;
   Steps : Integer;
  Begin
   If Handled Or (Msg.Message <> WM_MOUSEWHEEL) Or Not Showing Then
    Exit;
   p             := Point(SmallInt(LoWord(Msg.lParam)), SmallInt(HiWord(Msg.lParam)));
   r             := ClientRect;
   r.TopLeft     := ClientToScreen(r.TopLeft);
   r.BottomRight := ClientToScreen(r.BottomRight);
   If Not PtInRect(r, p) Then
    Exit;
   Inc(fWheelRemainder, SmallInt(HiWord(Msg.wParam)));
   Steps                           := fWheelRemainder Div WHEEL_DELTA;
   fWheelRemainder                 := fWheelRemainder Mod WHEEL_DELTA;
   Sections.VertScrollBar.Position := Sections.VertScrollBar.Position - Steps * 60;
   Handled                         := True;
  End;

 Destructor TfraSimBrief.Destroy;
  Begin
   If FetchTimer <> Nil Then
    FetchTimer.Enabled := False;
   If fMapsFetch <> Nil Then
    Begin
     fMapsFetch.Terminate;
     fMapsFetch.WaitFor;
     FreeAndNil(fMapsFetch);
    End;
   If fFetch <> Nil Then
    Begin
     fFetch.Terminate;
     fFetch.WaitFor;
     fFetch.Free;
    End;
   Inherited;
  End;

 Procedure TfraSimBrief.Configure(Config : TMemIniFile);
  Var
   Cache : String;
  Begin
   fConfig        := Config;
   eAccount.Text  := Config.ReadString('simbrief', 'username', '');
   aOlder.Checked := Config.ReadBool('simbrief', 'allow_older', False);
   Cache          := TPath.Combine(ExtractFilePath(Config.FileName), 'simbrief-latest.json');
   If TFile.Exists(Cache) Then
    Try
     LoadPayload(TFile.ReadAllText(Cache, TEncoding.UTF8), Tr('Ostatni pobrany plan (lokalna kopia)'));
    Except
     On E : Exception Do
      lStatus.Caption := Tr('Nie mozna odczytac kopii SimBrief: ') + E.Message;
    End;
  End;

 Procedure TfraSimBrief.SetTrip(Connection : TFDConnection; Trip : Integer);
  Begin
   fConnection       := Connection;
   fTrip             := Trip;
   aAttach.Enabled   := Not fReadOnly And (Connection <> Nil) And (Trip > 0) And (fPayload <> '');
   aRecorded.Enabled := (Connection <> Nil) And (Trip > 0);
  End;

 Function TfraSimBrief.SectionText(Root : TJSONObject; Const Paths : String) : String;
  Var
   Path : String;
   Key  : String;
   v    : TJSONValue;

   Procedure Lines(Value : TJSONValue; Const Prefix : String; Depth : Integer);
    Var
     Pair      : TJSONPair;
     Item      : TJSONValue;
     LabelText : String;
     Text      : String;
    Begin
     If Depth > 8 Then
      Exit;
     If Value Is TJSONObject Then
      For Pair In TJSONObject(Value) Do
       Lines(Pair.JsonValue, Pair.JsonString.Value, Depth + 1)
     Else If Value Is TJSONArray Then
      Begin
       For Item In TJSONArray(Value) Do
        Lines(Item, Prefix, Depth + 1);
      End
     Else If (Value <> Nil) And Not(Value Is TJSONNull) And (Value.Value <> '') Then
      Begin
       Text      := DecodeSimBriefHTML(Value.Value);
       LabelText := StringReplace(Prefix, '_', ' ', [rfReplaceAll]);
       If (Prefix = 'dx_rmk') Or (Prefix = 'sys_rmk') Or (Prefix = 'flightplan_text') Or (Prefix = 'route') Or (Prefix = 'text') Or (Pos(#10, Text) > 0) Then
        LabelText := '';
       If LabelText <> '' Then
        Begin
         LabelText[1] := UpCase(LabelText[1]);
         Text         := Tr(LabelText) + ': ' + Text;
        End;
       Result := Result + Text + sLineBreak;
      End;
    End;

  Begin
   Result := '';
   For Path In Paths.Split([';']) Do
    Begin
     v := Root;
     For Key In Path.Split(['.']) Do
      Begin
       If Not(v Is TJSONObject) Then
        Begin
         v := Nil;
         Break;
        End;
       v := TJSONObject(v).GetValue(Key);
      End;
     Lines(v, Key, 0);
    End;
   If Result = '' Then
    Result := Tr('Brak danych w pobranym planie.');
  End;

 Function TfraSimBrief.CardText(Root : TJSONObject; Const Specs : String) : String;
  Var
   Spec  : String;
   Value : String;
   Path  : String;
   p     : Integer;
   v     : TJSONValue;
   Item  : TJSONValue;
  Begin
   Result := '';
   For Spec In Specs.Split([';']) Do
    Begin
     p     := Pos('=', Spec);
     Path  := Copy(Spec, p + 1, MaxInt);
     Value := SBValue(Root, Path);
     If Path = 'general.flight_number' Then
      Value := SBValue(Root, 'general.icao_airline') + Value;
     If Path = 'alternate.icao_code' Then
      Begin
       v := Root.GetValue('alternate');
       If v Is TJSONArray Then
        For Item In TJSONArray(v) Do
         Begin
          If Value <> '' Then
           Value := Value + ', ';
          Value  := Value + SBValue(Item, 'icao_code');
         End;
      End;
     If Value = '' Then
      Value := Tr('brak danych');
     Result := Result + Copy(Spec, 1, p - 1) + ': ' + Value + sLineBreak;
    End;
  End;

 Function TfraSimBrief.MemoSectionHeight(Memo : TMemo) : Integer;
  Var
   Measure : TBitmap;
  Begin
   Measure := TBitmap.Create;
   Try
    Measure.Canvas.Font.Assign(Memo.Font);
    Result := Max(1, Memo.Lines.Count) * Measure.Canvas.TextHeight('Mg') + 60;
   Finally
    Measure.Free;
   End;
  End;

 Procedure TfraSimBrief.ResizeCards(Sender : TObject);
  Var
   i       : Integer;
   j       : Integer;
   n       : Integer;
   Columns : Integer;
   Total   : Integer;
   g       : TGroupBox;
   Flow    : TFlowPanel;
   HasMaps : Boolean;
  Begin
   If fResizingCards Or (csLoading In ComponentState) Or (Sections = Nil) Or (Tools = Nil) Or (ToolBar1 = Nil) Or (eAccount = Nil) Then
    Exit;
   fResizingCards := True;
   Try
    Tools.Height := ToolBar1.Height + eAccount.Height + 52;
    For i        := 0 To Sections.ControlCount - 1 Do
     If Sections.Controls[i] Is TGroupBox Then
      Begin
       g       := TGroupBox(Sections.Controls[i]);
       Total   := 50;
       HasMaps := False;
       For j   := 0 To g.ControlCount - 1 Do
        Begin
         n := 0;
         If g.Controls[j] Is TFlowPanel Then
          Begin
           Flow    := TFlowPanel(g.Controls[j]);
           Columns := Max(1, (Sections.ClientWidth - 32) Div 136);
           n       := ((Flow.ControlCount + Columns - 1) Div Columns) * 68 + 52;
          End
         Else If g.Controls[j] Is TMemo Then
          n := MemoSectionHeight(TMemo(g.Controls[j]))
         Else If g.Controls[j] Is TfraSimBriefMap Then
          Begin
           HasMaps := True;
           Inc(Total, g.Controls[j].Height);
          End;
         If n > 0 Then
          Begin
           g.Tag := n;
           If g.Height > 49 Then
            g.Height := n;
          End;
        End;
       If HasMaps Then
        Begin
         g.Tag := Total;
         If g.Height > 49 Then
          g.Height := Total;
        End;
      End;
   Finally
    fResizingCards := False;
   End;
  End;

 Procedure TfraSimBrief.PrepareMaps;
  Var
   Key    : String;
   Stored : TArray<TSimBriefMap>;
   i      : Integer;
   j      : Integer;
  Begin
   Key := SimBriefPlanKey(fPayload);
   If Key <> fMapsKey Then
    Begin
     fMapsKey          := Key;
     fMapsAttemptedKey := '';
     fMapImages        := SimBriefMapRequests(fPayload);
     If (fMapsFetch <> Nil) And (fMapsFetch.PlanKey <> Key) Then
      fMapsFetch.Terminate;
    End;
   Stored := LoadSimBriefMaps(fConnection, fTrip, fPayload);
   For i  := 0 To High(fMapImages) Do
    For j := 0 To High(Stored) Do
     If fMapImages[i].URL = Stored[j].URL Then
      Begin
       fMapImages[i] := Stored[j];
       Break;
      End;
   StartMapFetch;
  End;

 Procedure TfraSimBrief.StartMapFetch;
  Var
   m    : TSimBriefMap;
   Need : Boolean;
  Begin
   If fReadOnly Or (fMapsFetch <> Nil) Or (fMapsAttemptedKey = fMapsKey) Or (Length(fMapImages) = 0) Then
    Exit;
   Need := False;
   For m In fMapImages Do
    Need := Need Or ((Length(m.Data) = 0) And (m.Error = ''));
   If Not Need Then
    Exit;
   fMapsAttemptedKey := fMapsKey;
   fMapsFetch        := TSimBriefMapsFetch.Create(fPayload);
   fMapsFetch.Start;
   FetchTimer.Enabled := True;
  End;

 Procedure TfraSimBrief.RenderMaps;
  Var
   g        : TGroupBox;
   c        : TComponent;
   i        : Integer;
   Total    : Integer;
   Expanded : Boolean;
   f        : TfraSimBriefMap;
   m        : TSimBriefMap;
   Memo     : TMemo;
  Begin
   c := FindComponent('SB_maps');
   If Not(c Is TGroupBox) Then
    Exit;
   g        := TGroupBox(c);
   Expanded := g.Height > 49;
   Sections.DisableAlign;
   g.DisableAlign;
   Try
    For i := g.ControlCount - 1 DownTo 0 Do
     If Not(g.Controls[i] Is TButton) Then
      g.Controls[i].Free;
    Total := 50;
    For i := 0 To High(fMapImages) Do
     Begin
      m := fMapImages[i];
      If (Length(m.Data) = 0) And (m.Error = '') Then
       If fReadOnly Then
        m.Error := Tr('Brak zapisanej mapy.')
       Else
        m.Error := Tr('Pobieranie map SimBrief...');
      f         := TfraSimBriefMap.Create(Nil);
      f.Name    := 'SB_Map_' + IntToStr(i);
      g.InsertComponent(f);
      f.Parent := g;
      f.Width  := g.ClientWidth;
      f.Top    := 100000;
      f.Align  := alTop;
      f.Bind(m);
      f.OnHeightChanged := ResizeCards;
      f.Visible         := Expanded;
      Inc(Total, f.Height);
     End;
    If Length(fMapImages) = 0 Then
     Begin
      Memo             := TMemo.Create(g);
      Memo.Parent      := g;
      Memo.Align       := alClient;
      Memo.ReadOnly    := True;
      Memo.BorderStyle := bsNone;
      Memo.Color       := clBtnFace;
      Memo.Text        := Tr('Brak danych w pobranym planie.');
      Memo.Visible     := Expanded;
      Total            := 100;
     End;
    g.Tag := Total;
    If Expanded Then
     g.Height := Total;
   Finally
    g.EnableAlign;
    Sections.EnableAlign;
   End;
  End;

 Procedure TfraSimBrief.AddSection(Const Key, Title, Text : String; Expanded : Boolean);
  Var
   g    : TGroupBox;
   b    : TButton;
   m    : TMemo;
   Flow : TFlowPanel;
   Card : TPanel;
   l    : TLabel;
   Line : String;
   p    : Integer;
  Begin
   If fConfig <> Nil Then
    Expanded          := fConfig.ReadBool('simbrief_sections', Key, Expanded);
   g                  := TGroupBox.Create(Self);
   g.Parent           := Sections;
   g.Name             := 'SB_' + Key;
   g.Caption          := Tr(Title);
   g.AlignWithMargins := True;
   g.Margins.SetBounds(6, 5, 6, 5);
   g.Height  := 230;
   g.Top     := 100000;
   g.Align   := alTop;
   g.Tag     := 230;
   b         := TButton.Create(g);
   b.Parent  := g;
   b.Align   := alTop;
   b.Height  := 24;
   b.Caption := Tr('Zwin');
   b.OnClick := ToggleSection;
   If (Key = 'flight') Or (Key = 'summary') Or (Key = 'load') Then
    Begin
     Flow            := TFlowPanel.Create(g);
     Flow.Parent     := g;
     Flow.Align      := alClient;
     Flow.BevelOuter := bvNone;
     For Line In Text.Split([#10], TStringSplitOptions.ExcludeEmpty) Do
      Begin
       p := Pos(':', Line);
       If p = 0 Then
        Continue;
       Card                  := TPanel.Create(Flow);
       Card.Parent           := Flow;
       Card.Width            := 130;
       Card.Height           := 62;
       Card.AlignWithMargins := True;
       Card.Margins.SetBounds(3, 3, 3, 3);
       Card.BevelOuter := bvNone;
       l               := TLabel.Create(Card);
       l.Parent        := Card;
       l.Align         := alTop;
       l.AutoSize      := False;
       l.Height        := 20;
       l.Alignment     := taCenter;
       l.Font.Color    := clGrayText;
       l.Font.Size     := 8;
       l.Caption       := Tr(Copy(Line, 1, p - 1));
       l               := TLabel.Create(Card);
       l.Parent        := Card;
       l.Align         := alClient;
       l.AutoSize      := False;
       l.WordWrap      := True;
       l.Alignment     := taCenter;
       l.Font.Style    := [fsBold];
       l.Caption       := Trim(Copy(Line, p + 1, MaxInt));
       l.ShowHint      := True;
       l.Hint          := l.Caption;
      End;
     Flow.Visible := Expanded;
    End
   Else
    Begin
     m             := TMemo.Create(g);
     m.Parent      := g;
     m.Align       := alClient;
     m.ReadOnly    := True;
     m.ScrollBars  := ssNone;
     m.BorderStyle := bsNone;
     m.BevelInner  := bvNone;
     m.BevelOuter  := bvNone;
     m.Color       := clBtnFace;
     m.WordWrap    := False;
     m.Font.Name   := 'Consolas';
     m.Font.Size   := 9;
     m.Text        := StringReplace(StringReplace(StringReplace(Text, #13#10, #10, [rfReplaceAll]), #13, #10, [rfReplaceAll]), #10, sLineBreak, [rfReplaceAll]);
     g.Tag         := MemoSectionHeight(m);
     g.Height      := g.Tag;
     m.Visible     := Expanded;
    End;
   If Not Expanded Then
    Begin
     g.Height  := 49;
     b.Caption := Tr('Rozwin');
    End;
  End;

 Procedure TfraSimBrief.ToggleSection(Sender : TObject);
  Var
   b        : TButton;
   g        : TGroupBox;
   i        : Integer;
   Expanded : Boolean;
  Begin
   b        := TButton(Sender);
   g        := TGroupBox(b.Parent);
   Expanded := g.Height <= 49;
   For i    := 0 To g.ControlCount - 1 Do
    If g.Controls[i] <> b Then
     g.Controls[i].Visible := Expanded;
   If Expanded Then
    Begin
     g.Height  := g.Tag;
     b.Caption := Tr('Zwin');
    End
   Else
    Begin
     g.Height  := 49;
     b.Caption := Tr('Rozwin');
    End;
   If fConfig <> Nil Then
    Begin
     fConfig.WriteBool('simbrief_sections', Copy(g.Name, 4, MaxInt), Expanded);
     fConfig.UpdateFile;
    End;
  End;

 Procedure TfraSimBrief.LoadPayload(Const Payload, Source : String);
  Var
   v      : TJSONValue;
   o      : TJSONObject;
   Text   : String;
   Layout : String;
  Begin
   v := TJSONObject.ParseJSONValue(Payload);
   Try
    If Not(v Is TJSONObject) Then
     Raise Exception.Create(Tr('Nieprawidlowy JSON SimBrief.'));
    o := TJSONObject(v);
    If (SBValue(o, 'origin.icao_code') = '') Or (SBValue(o, 'destination.icao_code') = '') Then
     Raise Exception.Create(Tr('Odpowiedz nie zawiera planu lotu.'));
    fPayload := Payload;
    PrepareMaps;
    Sections.DisableAlign;
    Try
     While Sections.ControlCount > 0 Do
      Sections.Controls[0].Free;
     Layout := SBValue(o, 'params.ofp_layout');
     If Layout = '' Then
      Layout := 'LIDO';
     AddSection('flight', Tr('Flight Info'), CardText(o, 'Flight Number=general.flight_number;Callsign=atc.callsign;Departure=origin.icao_code;Arrival=destination.icao_code;Alternate=alternate.icao_code;Aircraft=aircraft.name;Departure UTC=times.sched_out;Ar' + 'rival UTC=times.sched_in;Air Time=times.est_time_enroute;Block Time=times.est_block;Airframe=aircraft.reg'), True);
     AddSection('summary', Tr('Flight Plan Summary'), CardText(o, 'Initial Altitude (ft)=general.initial_altitude;Cruise Profile=general.cruise_profile;Cost Index=general.costindex;Route Distance (nm)=general.route_distance;Average Wind (deg)=general.avg_wind_dir;Win' + 'd Speed (kt)=general.avg_wind_spd;Wind Component (kt)=general.avg_wind_comp;ISA Deviation (C)=general.avg_temp_dev;Release Number=general.release;AIRAC Cycle=params.airac;Units=params.units') + Tr('OFP Layout') + ': ' + Layout +
     sLineBreak, True);
     AddSection('load', Tr('Load Sheet - ') + SBValue(o, 'params.units'), CardText(o, 'Enroute Burn=fuel.enroute_burn;Passenger Count=weights.pax_count;Empty Weight=weights.oew;Estimated ZFW=weights.est_zfw;Estimated TOW=weights.est_tow;Estimated LW=weights.est_ldw;Block Fuel=fuel.plan_' + 'ramp;Bag Weight (each)=weights.bag_weight;Payload=weights.payload;Max ZFW=weights.max_zfw;Max TOW=weights.max_tow;Max LW=weights.max_ldw'), True);
     AddSection('route', Tr('Route'), SectionText(o, 'general.route;general.sid_ident;general.sid_trans;general.star_ident;general.star_trans;origin.plan_rwy;destination.plan_rwy'), True);
     AddSection('remarks', Tr('Dispatch Remarks'), SectionText(o, 'general.dx_rmk;general.sys_rmk'), True);
     AddSection('atc', Tr('ATC Flight Plan'), SectionText(o, 'atc'), False);
     Text := SBValue(o, 'text.plan_html');
     Text := TRegEx.Replace(Text, '(?is)<(script|style)\b[^>]*>.*?</\1>', '');
     Text := TRegEx.Replace(Text, '(?i)<br\s*/?>|</p>|</div>|</tr>|</pre>', #10);
     Text := DecodeSimBriefHTML(TRegEx.Replace(Text, '<[^>]*>', ''));
     // SimBrief uses LF inside PRE; the native Windows edit control needs CRLF.
     Text := StringReplace(Text, #13#10, #10, [rfReplaceAll]);
     Text := StringReplace(Text, #13, #10, [rfReplaceAll]);
     Text := StringReplace(Text, #10, sLineBreak, [rfReplaceAll]);
     AddSection('ofp', Tr('Briefing Preview / OFP - ') + Layout, Text, False);
     AddSection('runway', Tr('Runway Analysis'), SectionText(o, 'tlr'), False);
     AddSection('maps', Tr('Flight Maps'), '', False);
     RenderMaps;
     AddSection('departure', Tr('Departure Airport'), SectionText(o, 'origin'), False);
     AddSection('arrival', Tr('Arrival Airport'), SectionText(o, 'destination'), False);
     AddSection('alternate', Tr('Alternate Airport'), SectionText(o, 'alternate'), False);
     AddSection('takeoffalternate', Tr('Takeoff Alternate'), SectionText(o, 'takeoff_altn'), False);
     AddSection('enroutealternate', Tr('Enroute Alternate'), SectionText(o, 'enroute_altn'), False);
    Finally
     Sections.EnableAlign;
    End;
    ResizeCards(Nil);
    lStatus.Caption := Source + ': ' + SBValue(o, 'origin.icao_code') + ' - ' + SBValue(o, 'destination.icao_code') + sLineBreak + Tr('Wygenerowano: ') + SBValue(o, 'params.time_generated') + Tr('. Przypisanie do tripu wymaga osobnego sprawdzenia.');
    aOFP.Enabled    := SBValue(o, 'text.plan_html') <> '';
    SetTrip(fConnection, fTrip);
   Finally
    v.Free;
   End;
  End;

 Procedure TfraSimBrief.aOlderExecute(Sender : TObject);
  Begin
   If fConfig <> Nil Then
    Begin
     fConfig.WriteBool('simbrief', 'allow_older', aOlder.Checked);
     fConfig.UpdateFile;
    End;
  End;

 Procedure TfraSimBrief.aFetchExecute(Sender : TObject);
  Begin
   If (fFetch <> Nil) Or (Trim(eAccount.Text) = '') Then
    Exit;
   If fConfig <> Nil Then
    Begin
     fConfig.WriteString('simbrief', 'username', Trim(eAccount.Text));
     fConfig.UpdateFile;
    End;
   aFetch.Enabled  := False;
   lStatus.Caption := Tr('Pobieranie ostatniego planu SimBrief...');
   fFetch          := TSimBriefFetch.Create(eAccount.Text);
   fFetch.Start;
   FetchTimer.Enabled := True;
  End;

 Procedure TfraSimBrief.FetchTick(Sender : TObject);
  Begin
   If (fFetch <> Nil) And (WaitForSingleObject(fFetch.Handle, 0) = WAIT_OBJECT_0) Then
    Begin
     Try
      If fFetch.Error <> '' Then
       Raise Exception.Create(fFetch.Error);
      LoadPayload(fFetch.Payload, Tr('Ostatni pobrany plan SimBrief'));
      If fConfig <> Nil Then
       TFile.WriteAllText(TPath.Combine(ExtractFilePath(fConfig.FileName), 'simbrief-latest.json'), fPayload, TEncoding.UTF8);
     Except
      On E : Exception Do
       lStatus.Caption := 'SimBrief: ' + E.Message;
     End;
     FreeAndNil(fFetch);
     aFetch.Enabled := True;
    End;
   If (fMapsFetch <> Nil) And (WaitForSingleObject(fMapsFetch.Handle, 0) = WAIT_OBJECT_0) Then
    Begin
     Try
      If fMapsFetch.PlanKey = fMapsKey Then
       Begin
        fMapImages := Copy(fMapsFetch.Images);
        If Not fReadOnly Then
         SaveSimBriefMaps(fConnection, fTrip, fPayload, fMapImages);
        RenderMaps;
        ResizeCards(Self);
       End;
     Except
      On E : Exception Do
       lStatus.Caption := 'SimBrief maps: ' + E.Message;
     End;
     FreeAndNil(fMapsFetch);
    End;
   StartMapFetch;
   FetchTimer.Enabled := (fFetch <> Nil) Or (fMapsFetch <> Nil);
  End;

 Procedure TfraSimBrief.aRecordedExecute(Sender : TObject);
  Var
   q : TFDQuery;
  Begin
   If (fConnection = Nil) Or (fTrip <= 0) Then
    Exit;
   q := TFDQuery.Create(Nil);
   Try
    q.Connection := fConnection;
    q.Open('select payload from trip_simbrief where trip=:t', [fTrip]);
    If q.IsEmpty Then
     lStatus.Caption := Tr('Nagranie nie ma przypisanego planu SimBrief. Podglad pozostaje bez zmian.')
    Else
     LoadPayload(q.Fields[0].AsString, Tr('Plan zapisany przy nagraniu #') + IntToStr(fTrip));
   Finally
    q.Free;
   End;
  End;

 Procedure TfraSimBrief.aAttachExecute(Sender : TObject);
  Begin
   If fReadOnly Or (fConnection = Nil) Or (fTrip <= 0) Or (fPayload = '') Then
    Exit;
   Try
    SaveSimBrief(fConnection, fTrip, fPayload, '', aOlder.Checked);
    SaveSimBriefMaps(fConnection, fTrip, fPayload, fMapImages);
    If fConfig <> Nil Then
     Begin
      fConfig.WriteBool('simbrief', 'allow_older', aOlder.Checked);
      fConfig.UpdateFile;
     End;
    lStatus.Caption := Tr('Plan sprawdzony i zapisany przy nagraniu #') + IntToStr(fTrip);
   Except
    On E : Exception Do
     lStatus.Caption := Tr('Nie przypisano planu: ') + E.Message;
   End;
  End;

 Procedure TfraSimBrief.aOFPExecute(Sender : TObject);
  Var
   v : TJSONValue;
   f : TfrmReport;
  Begin
   v := TJSONObject.ParseJSONValue(fPayload);
   Try
    f         := TfrmReport.Create(Application);
    f.Caption := Tr('SimBrief OFP');
    f.SetHTMLDocument(SBValue(v, 'text.plan_html'));
    f.Show;
   Finally
    v.Free;
   End;
  End;

 Procedure TfraSimBrief.aWindowExecute(Sender : TObject);
  Begin
   aWindow.Enabled := False;
   Try
    ShowSimBriefWindow(Self);
   Finally
    aWindow.Enabled := True;
   End;
  End;

End.
