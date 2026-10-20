Unit frmSimBriefFrameU;

Interface

 Uses
  LocalizationU, i18nLocalizer, i18nCore, System.Classes, System.SysUtils,
  System.JSON, System.IniFiles, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, System.Generics.Collections, System.Types,
  Vcl.AppEvnts, Winapi.Windows, FireDAC.Comp.Client, SimBriefImportU,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList, Vcl.ComCtrls,
  Vcl.ToolWin;

 Type
  TfraSimBrief = Class(TLocalizedFrame)
   Published
    ToolBar1: TToolBar;
    btnFetch: TToolButton;
    btnRecorded: TToolButton;
    btnAttach: TToolButton;
    btnOFP: TToolButton;
    ToolButton5: TToolButton;
    btnWindow: TToolButton;
    ToolButton7: TToolButton;
    ActionList: TActionList;
    ImageList: TImageList;
    aFetch: TAction;
    aRecorded: TAction;
    aAttach: TAction;
    aOFP: TAction;
    aWindow: TAction;
    btnOlder: TToolButton;
    aOlder: TAction;
    ToolButton1: TToolButton;
   Published
    AppTranslator : TTranslator;
    eAccount      : TEdit;
    FetchTimer    : TTimer;
    lStatus       : TLabel;
    Sections      : TScrollBox;
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
    fConfig         : TMemIniFile;
    fConnection     : TFDConnection;
    fTrip           : Integer;
    fPayload        : String;
    fFetch          : TSimBriefFetch;
    fWheelRemainder : Integer;
    Procedure AddSection(Const Key, Title, Text : String; Expanded : Boolean);
    Function SectionText(Root : TJSONObject; Const Paths : String) : String;
    Function CardText(Root : TJSONObject; Const Specs : String) : String;
    Function MemoSectionHeight(Memo : TMemo) : Integer;
   Public
    Procedure Retranslate;
    Destructor Destroy; Override;
    Procedure Configure(Config : TMemIniFile);
    Procedure SetTrip(Connection : TFDConnection; Trip : Integer);
    Procedure LoadPayload(Const Payload, Source : String);
    Property Payload : String Read fPayload;
  End;

Implementation

 Uses
  System.IOUtils, System.NetEncoding, System.RegularExpressions, Winapi.Messages,
  Vcl.Dialogs, Vcl.Graphics, System.Math, frmReportU, frmSimBriefU;

 {$R *.dfm}

 Procedure TfraSimBrief.Retranslate;
  Begin
   If fPayload <> '' Then
    LoadPayload(fPayload, '');
  End;

 Procedure TfraSimBrief.WheelMessage(Var Msg : TMsg; Var Handled : Boolean);
  Var
   P     : TPoint;
   R     : TRect;
   Steps : Integer;
  Begin
   If Handled Or (Msg.message <> WM_MOUSEWHEEL) Or Not Showing Then
    Exit;
   If (Msg.hwnd <> Handle) And Not IsChild(Handle, Msg.hwnd) Then
    Exit;
   P             := Point(SmallInt(LoWord(Msg.lParam)), SmallInt(HiWord(Msg.lParam)));
   R             := ClientRect;
   R.TopLeft     := ClientToScreen(R.TopLeft);
   R.BottomRight := ClientToScreen(R.BottomRight);
   If Not PtInRect(R, P) Then
    Exit;
   Inc(fWheelRemainder, SmallInt(HiWord(Msg.wParam)));
   Steps                           := fWheelRemainder Div WHEEL_DELTA;
   fWheelRemainder                 := fWheelRemainder Mod WHEEL_DELTA;
   Sections.VertScrollBar.Position := Sections.VertScrollBar.Position - Steps * 60;
   Handled                         := True;
  End;

 Destructor TfraSimBrief.Destroy;
  Begin
   if FetchTimer <> nil then FetchTimer.Enabled := False;
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
      lStatus.Caption := Tr('Nie mozna odczytac kopii SimBrief: ') + E.message;
    End;
  End;

 Procedure TfraSimBrief.SetTrip(Connection : TFDConnection; Trip : Integer);
  Begin
   fConnection         := Connection;
   fTrip               := Trip;
   aAttach.Enabled   := (Connection <> Nil) And (Trip > 0) And (fPayload <> '');
   aRecorded.Enabled := (Connection <> Nil) And (Trip > 0);
  End;

 Function TfraSimBrief.SectionText(Root : TJSONObject; Const Paths : String) : String;
  Var
   Path : String;
   Key  : String;
   V    : TJSONValue;

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
     V := Root;
     For Key In Path.Split(['.']) Do
      Begin
       If Not(V Is TJSONObject) Then
        Begin
         V := Nil;
         Break;
        End;
       V := TJSONObject(V).GetValue(Key);
      End;
     Lines(V, Key, 0);
    End;
   If Result = '' Then
    Result := Tr('Brak danych w pobranym planie.');
  End;

 Function TfraSimBrief.CardText(Root : TJSONObject; Const Specs : String) : String;
  Var
   Spec  : String;
   Value : String;
   Path  : String;
   P     : Integer;
   V     : TJSONValue;
   Item  : TJSONValue;
  Begin
   Result := '';
   For Spec In Specs.Split([';']) Do
    Begin
     P     := Pos('=', Spec);
     Path  := Copy(Spec, P + 1, MaxInt);
     Value := SBValue(Root, Path);
     If Path = 'general.flight_number' Then
      Value := SBValue(Root, 'general.icao_airline') + Value;
     If Path = 'alternate.icao_code' Then
      Begin
       V := Root.GetValue('alternate');
       If V Is TJSONArray Then
        For Item In TJSONArray(V) Do
         Begin
          If Value <> '' Then
           Value := Value + ', ';
          Value  := Value + SBValue(Item, 'icao_code');
         End;
      End;
     If Value = '' Then
      Value := Tr('brak danych');
     Result := Result + Copy(Spec, 1, P - 1) + ': ' + Value + sLineBreak;
    End;
  End;

 Function TfraSimBrief.MemoSectionHeight(Memo : TMemo) : Integer;
  Var
   Measure : TBitmap;
  Begin
   Measure := TBitmap.Create;
   Try
    Measure.Canvas.Font.Assign(Memo.Font);
    Result := Max(1, Memo.Lines.Count) * Measure.Canvas.TextHeight('Mg') + 60 + GetSystemMetrics(SM_CYHSCROLL);
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
   G       : TGroupBox;
   Flow    : TFlowPanel;
  Begin
   If (csLoading in ComponentState) or (Sections = Nil) or
      (Tools = nil) or (ToolBar1 = nil) or (eAccount = nil) or (aOlder = nil) Then
    Exit;
   Tools.Height := ToolBar1.Height + eAccount.Height + 52;
   For i          := 0 To Sections.ControlCount - 1 Do
    If Sections.Controls[i] Is TGroupBox Then
     Begin
      G     := TGroupBox(Sections.Controls[i]);
      For j := 0 To G.ControlCount - 1 Do
       If G.Controls[j] Is TFlowPanel Then
        Begin
         Flow    := TFlowPanel(G.Controls[j]);
         Columns := Max(1, (Sections.ClientWidth - 32) Div 136);
         n       := ((Flow.ControlCount + Columns - 1) Div Columns) * 68 + 52;
         G.Tag   := n;
         If G.Height > 49 Then
          G.Height := n;
        End
       Else If G.Controls[j] Is TMemo Then
        Begin
         n     := MemoSectionHeight(TMemo(G.Controls[j]));
         G.Tag := n;
         If G.Height > 49 Then
          G.Height := n;
        End;
     End;
  End;

 Procedure TfraSimBrief.AddSection(Const Key, Title, Text : String; Expanded : Boolean);
  Var
   G    : TGroupBox;
   B    : TButton;
   M    : TMemo;
   Flow : TFlowPanel;
   Card : TPanel;
   L    : TLabel;
   Line : String;
   P    : Integer;
  Begin
   If fConfig <> Nil Then
    Expanded          := fConfig.ReadBool('simbrief_sections', Key, Expanded);
   G                  := TGroupBox.Create(Self);
   G.Parent           := Sections;
   G.Name             := 'SB_' + Key;
   G.Caption          := Tr(Title);
   G.AlignWithMargins := True;
   G.Margins.SetBounds(6, 5, 6, 5);
   G.Height  := 230;
   G.Top     := 100000;
   G.Align   := alTop;
   G.Tag     := 230;
   B         := TButton.Create(G);
   B.Parent  := G;
   B.Align   := alTop;
   B.Height  := 24;
   B.Caption := Tr('Zwin');
   B.OnClick := ToggleSection;
   If (Key = 'flight') Or (Key = 'summary') Or (Key = 'load') Then
    Begin
     Flow            := TFlowPanel.Create(G);
     Flow.Parent     := G;
     Flow.Align      := alClient;
     Flow.BevelOuter := bvNone;
     For Line In Text.Split([#10], TStringSplitOptions.ExcludeEmpty) Do
      Begin
       P := Pos(':', Line);
       If P = 0 Then
        Continue;
       Card                  := TPanel.Create(Flow);
       Card.Parent           := Flow;
       Card.Width            := 130;
       Card.Height           := 62;
       Card.AlignWithMargins := True;
       Card.Margins.SetBounds(3, 3, 3, 3);
       Card.BevelOuter := bvNone;
       L               := TLabel.Create(Card);
       L.Parent        := Card;
       L.Align         := alTop;
       L.AutoSize      := False;
       L.Height        := 20;
       L.Alignment     := taCenter;
       L.Font.Color    := clGrayText;
       L.Font.Size     := 8;
       L.Caption       := Tr(Copy(Line, 1, P - 1));
       L               := TLabel.Create(Card);
       L.Parent        := Card;
       L.Align         := alClient;
       L.AutoSize      := False;
       L.WordWrap      := True;
       L.Alignment     := taCenter;
       L.Font.Style    := [fsBold];
       L.Caption       := Trim(Copy(Line, P + 1, MaxInt));
       L.ShowHint      := True;
       L.Hint          := L.Caption;
      End;
     Flow.Visible := Expanded;
    End
   Else
    Begin
     M            := TMemo.Create(G);
     M.Parent     := G;
     M.Align      := alClient;
     M.ReadOnly   := True;
     M.ScrollBars := ssHorizontal;
     M.WordWrap   := False;
     M.Font.Name  := 'Consolas';
     M.Font.Size  := 9;
     M.Text       := StringReplace(StringReplace(StringReplace(Text, #13#10, #10, [rfReplaceAll]), #13, #10, [rfReplaceAll]), #10, sLineBreak, [rfReplaceAll]);
     G.Tag        := MemoSectionHeight(M);
     G.Height     := G.Tag;
     M.Visible    := Expanded;
    End;
   If Not Expanded Then
    Begin
     G.Height  := 49;
     B.Caption := Tr('Rozwin');
    End;
  End;

 Procedure TfraSimBrief.ToggleSection(Sender : TObject);
  Var
   B        : TButton;
   G        : TGroupBox;
   i        : Integer;
   Expanded : Boolean;
  Begin
   B        := TButton(Sender);
   G        := TGroupBox(B.Parent);
   Expanded := G.Height <= 49;
   For i    := 0 To G.ControlCount - 1 Do
    If G.Controls[i] <> B Then
     G.Controls[i].Visible := Expanded;
   If Expanded Then
    Begin
     G.Height  := G.Tag;
     B.Caption := Tr('Zwin');
    End
   Else
    Begin
     G.Height  := 49;
     B.Caption := Tr('Rozwin');
    End;
   If fConfig <> Nil Then
    Begin
     fConfig.WriteBool('simbrief_sections', Copy(G.Name, 4, MaxInt), Expanded);
     fConfig.UpdateFile;
    End;
  End;

 Procedure TfraSimBrief.LoadPayload(Const Payload, Source : String);
  Var
   V      : TJSONValue;
   O      : TJSONObject;
   Text   : String;
   Layout : String;
  Begin
   V := TJSONObject.ParseJSONValue(Payload);
   Try
    If Not(V Is TJSONObject) Then
     Raise Exception.Create(Tr('Nieprawidlowy JSON SimBrief.'));
    O := TJSONObject(V);
    If (SBValue(O, 'origin.icao_code') = '') Or (SBValue(O, 'destination.icao_code') = '') Then
     Raise Exception.Create(Tr('Odpowiedz nie zawiera planu lotu.'));
    fPayload := Payload;
    Sections.DisableAlign;
    Try
     While Sections.ControlCount > 0 Do
      Sections.Controls[0].Free;
     Layout := SBValue(O, 'params.ofp_layout');
     If Layout = '' Then
      Layout := 'LIDO';
     AddSection('flight', Tr('Flight Info'), CardText(O, 'Flight Number=general.flight_number;Callsign=atc.callsign;Departure=origin.icao_code;Arrival=destination.icao_code;Alternate=alternate.icao_code;Aircraft=aircraft.name;Departure UTC=times.sched_out;Ar' + 'rival UTC=times.sched_in;Air Time=times.est_time_enroute;Block Time=times.est_block;Airframe=aircraft.reg'), True);
     AddSection('summary', Tr('Flight Plan Summary'), CardText(O, 'Initial Altitude (ft)=general.initial_altitude;Cruise Profile=general.cruise_profile;Cost Index=general.costindex;Route Distance (nm)=general.route_distance;Average Wind (deg)=general.avg_wind_dir;Win' + 'd Speed (kt)=general.avg_wind_spd;Wind Component (kt)=general.avg_wind_comp;ISA Deviation (C)=general.avg_temp_dev;Release Number=general.release;AIRAC Cycle=params.airac;Units=params.units') + Tr('OFP Layout') + ': ' + Layout +
      sLineBreak, True);
     AddSection('load', Tr('Load Sheet - ') + SBValue(O, 'params.units'), CardText(O, 'Enroute Burn=fuel.enroute_burn;Passenger Count=weights.pax_count;Empty Weight=weights.oew;Estimated ZFW=weights.est_zfw;Estimated TOW=weights.est_tow;Estimated LW=weights.est_ldw;Block Fuel=fuel.plan_' + 'ramp;Bag Weight (each)=weights.bag_weight;Payload=weights.payload;Max ZFW=weights.max_zfw;Max TOW=weights.max_tow;Max LW=weights.max_ldw'), True);
     AddSection('route', Tr('Route'), SectionText(O, 'general.route;general.sid_ident;general.sid_trans;general.star_ident;general.star_trans;origin.plan_rwy;destination.plan_rwy'), True);
     AddSection('remarks', Tr('Dispatch Remarks'), SectionText(O, 'general.dx_rmk;general.sys_rmk'), True);
     AddSection('atc', Tr('ATC Flight Plan'), SectionText(O, 'atc'), False);
     Text := SBValue(O, 'text.plan_html');
     Text := TRegEx.Replace(Text, '(?is)<(script|style)\b[^>]*>.*?</\1>', '');
     Text := TRegEx.Replace(Text, '(?i)<br\s*/?>|</p>|</div>|</tr>|</pre>', #10);
     Text := DecodeSimBriefHTML(TRegEx.Replace(Text, '<[^>]*>', ''));
     // SimBrief uses LF inside PRE; the native Windows edit control needs CRLF.
     Text := StringReplace(Text, #13#10, #10, [rfReplaceAll]);
     Text := StringReplace(Text, #13, #10, [rfReplaceAll]);
     Text := StringReplace(Text, #10, sLineBreak, [rfReplaceAll]);
     AddSection('ofp', Tr('Briefing Preview / OFP - ') + Layout, Text, False);
     AddSection('runway', Tr('Runway Analysis'), SectionText(O, 'tlr'), False);
     AddSection('maps', Tr('Flight Maps'), SectionText(O, 'images;links;map_data'), False);
     AddSection('departure', Tr('Departure Airport'), SectionText(O, 'origin'), False);
     AddSection('arrival', Tr('Arrival Airport'), SectionText(O, 'destination'), False);
     AddSection('alternate', Tr('Alternate Airport'), SectionText(O, 'alternate'), False);
     AddSection('takeoffalternate', Tr('Takeoff Alternate'), SectionText(O, 'takeoff_altn'), False);
     AddSection('enroutealternate', Tr('Enroute Alternate'), SectionText(O, 'enroute_altn'), False);
     AddSection('prefile', Tr('Prefile on a Network'), SectionText(O, 'prefile;vatsim_prefile;ivao_prefile;pilotedge_prefile;poscon_prefile'), False);
    Finally
     Sections.EnableAlign;
    End;
    ResizeCards(Nil);
    lStatus.Caption := Source + ': ' + SBValue(O, 'origin.icao_code') + ' - ' + SBValue(O, 'destination.icao_code') + sLineBreak + Tr('Wygenerowano: ') + SBValue(O, 'params.time_generated') + Tr('. Przypisanie do tripu wymaga osobnego sprawdzenia.');
    aOFP.Enabled  := SBValue(O, 'text.plan_html') <> '';
    SetTrip(fConnection, fTrip);
   Finally
    V.Free;
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
   aFetch.Enabled := False;
   lStatus.Caption  := Tr('Pobieranie ostatniego planu SimBrief...');
   fFetch           := TSimBriefFetch.Create(eAccount.Text);
   fFetch.Start;
   FetchTimer.Enabled := True;
  End;

 Procedure TfraSimBrief.FetchTick(Sender : TObject);
  Begin
   If (fFetch = Nil) Or (WaitForSingleObject(fFetch.Handle, 0) <> WAIT_OBJECT_0) Then
    Exit;
   if FetchTimer <> nil then FetchTimer.Enabled := False;
   Try
    If fFetch.Error <> '' Then
     Raise Exception.Create(fFetch.Error);
    LoadPayload(fFetch.Payload, Tr('Ostatni pobrany plan SimBrief'));
    If fConfig <> Nil Then
     TFile.WriteAllText(TPath.Combine(ExtractFilePath(fConfig.FileName), 'simbrief-latest.json'), fPayload, TEncoding.UTF8);
   Except
    On E : Exception Do
     lStatus.Caption := 'SimBrief: ' + E.message;
   End;
   FreeAndNil(fFetch);
   aFetch.Enabled := True;
  End;

 Procedure TfraSimBrief.aRecordedExecute(Sender : TObject);
  Var
   Q : TFDQuery;
  Begin
   If (fConnection = Nil) Or (fTrip <= 0) Then
    Exit;
   Q := TFDQuery.Create(Nil);
   Try
    Q.Connection := fConnection;
    Q.Open('select payload from trip_simbrief where trip=:t', [fTrip]);
    If Q.IsEmpty Then
     lStatus.Caption := Tr('Nagranie nie ma przypisanego planu SimBrief. Podglad pozostaje bez zmian.')
    Else
     LoadPayload(Q.Fields[0].AsString, Tr('Plan zapisany przy nagraniu #') + IntToStr(fTrip));
   Finally
    Q.Free;
   End;
  End;

 Procedure TfraSimBrief.aAttachExecute(Sender : TObject);
  Begin
   If (fConnection = Nil) Or (fTrip <= 0) Or (fPayload = '') Then
    Exit;
   Try
    SaveSimBrief(fConnection, fTrip, fPayload, '', aOlder.Checked);
    If fConfig <> Nil Then
     Begin
      fConfig.WriteBool('simbrief', 'allow_older', aOlder.Checked);
      fConfig.UpdateFile;
     End;
    lStatus.Caption := Tr('Plan sprawdzony i zapisany przy nagraniu #') + IntToStr(fTrip);
   Except
    On E : Exception Do
     lStatus.Caption := Tr('Nie przypisano planu: ') + E.message;
   End;
  End;

 Procedure TfraSimBrief.aOFPExecute(Sender : TObject);
  Var
   V : TJSONValue;
   F : TfrmReport;
  Begin
   V := TJSONObject.ParseJSONValue(fPayload);
   Try
    F         := TfrmReport.Create(Application);
    F.Caption := Tr('SimBrief OFP');
    F.SetHTMLDocument(SBValue(V, 'text.plan_html'));
    F.Show;
   Finally
    V.Free;
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
