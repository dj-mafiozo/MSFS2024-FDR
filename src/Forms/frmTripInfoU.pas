Unit frmTripInfoU;

Interface

 Uses
  LocalizationU, i18nLocalizer, System.Generics.Collections,
  System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, FireDAC.Comp.Client, Data.DB,
  Vcl.Controls, System.IniFiles, SimBriefImportU, i18nCore;

 Type
  TfrmTripInfo = Class(TLocalizedForm)
   Published
    AppTranslator : TTranslator;
    btnClose      : TButton;
    btnImport     : TButton;
    btnOFP        : TButton;
    btnRefresh    : TButton;
    ButtonsPanel  : TPanel;
    chkAllowOlder : TCheckBox;
    eAccount      : TEdit;
    FetchTimer    : TTimer;
    mInfo         : TMemo;
    SimBriefPanel : TPanel;
    Procedure ImportClick(Sender : TObject);
    Procedure OFPClick(Sender : TObject);
    Procedure FetchTick(Sender : TObject);
    Procedure RefreshClick(Sender : TObject);
   Private
    fFetch      : TSimBriefFetch;
    fAllowOlder : Boolean;
    fConfig     : TMemIniFile;
    fConnection : TFDConnection;
    fTrip       : Integer;
   Public
    Destructor Destroy; Override;
    Procedure ConfigureSimBrief(Config : TMemIniFile);
    Procedure LoadTrip(Connection : TFDConnection; Trip : Integer);
  End;

Implementation

 Uses
  System.SysUtils, System.DateUtils, System.JSON, System.IOUtils, Vcl.Dialogs, Winapi.Windows, FMCScreensU;
 {$R *.dfm}

 Destructor TfrmTripInfo.Destroy;
  Begin
   If fFetch <> Nil Then
    Begin
     fFetch.Terminate;
     fFetch.WaitFor;
     fFetch.Free;
    End;
   Inherited;
  End;

 Procedure TfrmTripInfo.ConfigureSimBrief(Config : TMemIniFile);
  Begin
   fConfig               := Config;
   eAccount.Text         := Config.ReadString('simbrief', 'username', '');
   chkAllowOlder.Checked := Config.ReadBool('simbrief', 'allow_older', False);
  End;

 Procedure TfrmTripInfo.ImportClick(Sender : TObject);
  Begin
   If (fFetch <> Nil) Or (Trim(eAccount.Text) = '') Then
    Exit;
   If fConfig <> Nil Then
    Begin
     fConfig.WriteString('simbrief', 'username', Trim(eAccount.Text));
     fConfig.WriteBool('simbrief', 'allow_older', chkAllowOlder.Checked);
     fConfig.UpdateFile;
    End;
   fAllowOlder           := chkAllowOlder.Checked;
   chkAllowOlder.Enabled := False;
   fFetch                := TSimBriefFetch.Create(eAccount.Text);
   btnImport.Enabled     := False;
   btnClose.Enabled      := False;
   BorderIcons           := BorderIcons - [biSystemMenu];
   btnImport.Caption     := Tr('Pobieranie...');
   fFetch.Start;
   FetchTimer.Enabled := True;
  End;

 Procedure TfrmTripInfo.FetchTick(Sender : TObject);
  Var
   V      : TJSONValue;
   Reason : String;
  Begin
   If (fFetch = Nil) Or (WaitForSingleObject(fFetch.Handle, 0) <> WAIT_OBJECT_0) Then
    Exit;
   FetchTimer.Enabled := False;
   V                  := Nil;
   Try
    If fFetch.Error <> '' Then
     Raise Exception.Create(fFetch.Error);
    V := TJSONObject.ParseJSONValue(fFetch.Payload);
    If Not(V Is TJSONObject) Then
     Raise Exception.Create(Tr('Nieprawidlowy JSON SimBrief.'));
    If Not MatchSimBrief(fConnection, fTrip, TJSONObject(V), Reason, fAllowOlder) Then
     Raise Exception.Create(Reason);
    SaveSimBrief(fConnection, fTrip, fFetch.Payload, Reason, fAllowOlder);
    RefreshClick(Nil);
    ShowMessage(Tr('Zapisano plan SimBrief i OFP dla tego nagrania.'));
   Except
    On E : Exception Do
     ShowMessage('SimBrief: ' + E.Message);
   End;
   V.Free;
   FreeAndNil(fFetch);
   btnImport.Enabled     := True;
   btnImport.Caption     := Tr('Import SimBrief');
   chkAllowOlder.Enabled := True;
   btnClose.Enabled      := True;
   BorderIcons           := BorderIcons + [biSystemMenu];
  End;

 Procedure TfrmTripInfo.OFPClick(Sender : TObject);
  Var
   D    : TSaveDialog;
   HTML : String;
  Begin
   HTML := SimBriefOFP(fConnection, fTrip);
   If HTML = '' Then
    Begin
     ShowMessage(Tr('Brak zapisanego OFP. Najpierw zaimportuj zgodny plan.'));
     Exit;
    End;
   D := TSaveDialog.Create(Self);
   Try
    D.Filter     := 'OFP HTML|*.html';
    D.DefaultExt := 'html';
    D.FileName   := 'OFP-trip-' + IntToStr(fTrip) + '.html';
    D.Options    := D.Options + [ofOverwritePrompt];
    If D.Execute Then
     TFile.WriteAllText(D.FileName, HTML, TEncoding.UTF8);
   Finally
    D.Free;
   End;
  End;

 Procedure TfrmTripInfo.LoadTrip(Connection : TFDConnection; Trip : Integer);
  Begin
   fConnection := Connection;
   fTrip       := Trip;
   RefreshClick(Nil);
  End;

 Procedure TfrmTripInfo.RefreshClick(Sender : TObject);
  Var
   q           : TFDQuery;
   StartUTC    : String;
   EndUTC      : String;
   LatestUTC   : String;
   StartTime   : TDateTime;
   EndTime     : TDateTime;
   Seconds     : Int64;
   HadContacts : Boolean;

   Procedure Add(Const LabelText, Value : String);
    Var
     Text : String;
    Begin
     Text := Value;
     If Trim(Text) = '' Then
      Text := Tr('brak danych');
     mInfo.Lines.Add(Tr(LabelText) + ': ' + Text);
    End;

   Procedure TripField(Const LabelText, Field : String);
    Begin
     Add(LabelText, q.FieldByName(Field).AsString);
    End;

   Procedure Count(Const LabelText, TableName : String);
    Begin
     Add(LabelText, IntToStr(fConnection.ExecSQLScalar('select count(*) from ' + TableName + ' where trip=:t', [fTrip])));
    End;

   Procedure AddFMC(Const AtUTC : String);
    Var
     Context : TJSONObject;
     Devices : TJSONObject;
     Device  : TJSONObject;
     Ref     : TJSONObject;
     Pair    : TJSONPair;

     Procedure Field(Const Key, LabelText, Units : String);
      Var
       V : TJSONValue;
       S : String;
      Begin
       V := Device.GetValue(Key);
       If Not(V Is TJSONObject) Then
        Exit;
       Ref := TJSONObject(V);
       V   := Ref.GetValue('value');
       If (V = Nil) Or (V Is TJSONNull) Then
        S := Tr('brak danych')
       Else
        Begin
         If V Is TJSONNumber Then
          S := V.ToJSON
         Else
          S := V.Value;
         If Units <> '' Then
          S := S + ' ' + Units;
        End;
       Add(LabelText, S);
      End;

    Begin
     Context := LatestFMCContext(fConnection, fTrip, AtUTC);
     Try
      mInfo.Lines.Add(Tr('FMC/MCDU - ostatnio odczytane przed ') + AtUTC);
      Devices := Context.GetValue('last_values_by_device') As TJSONObject;
      If (Devices = Nil) Or (Devices.Count = 0) Then
       Begin
        mInfo.Lines.Add(Tr('Brak odczytanych danych FMC.'));
        Exit;
       End;
      For Pair In Devices Do
       Begin
        Device := Pair.JsonValue As TJSONObject;
        mInfo.Lines.Add(Tr('Urzadzenie: ') + Pair.JsonString.Value);
        Field('v1_kt', 'V1', 'kt');
        Field('vr_kt', 'VR', 'kt');
        Field('v2_kt', 'V2', 'kt');
        Field('vref_kt', 'VREF', 'kt');
        Field('vapp_kt', 'VAPP', 'kt');
        Field('wind_correction_kt', Tr('Wind correction'), 'kt');
        Field('takeoff_flaps_deg', Tr('Klapy start'), 'deg');
        Field('takeoff_flaps', Tr('Klapy start'), '');
        Field('approach_flaps_deg', Tr('Klapy ladowanie'), 'deg');
        Field('takeoff_n1_left_pct', Tr('TO N1 limit lewy'), '%');
        Field('takeoff_n1_right_pct', Tr('TO N1 limit prawy'), '%');
        Field('assumed_temp_c', Tr('Assumed temp'), 'C');
        Field('oat_c', 'OAT', 'C');
        Field('takeoff_cg_pct', Tr('CG start'), '%');
        Field('takeoff_trim_units', Tr('Trim start'), 'units');
        Field('takeoff_mode_active', Tr('Tryb start aktywny'), '');
        Field('takeoff_mode_selected', Tr('Tryb start wybrany'), '');
        Field('climb_mode_active', Tr('Tryb climb aktywny'), '');
        Field('climb_mode_selected', Tr('Tryb climb wybrany'), '');
        Field('takeoff_active_rating_k', Tr('Rating aktywny'), 'K');
        Field('takeoff_selected_rating_k', Tr('Rating wybrany'), 'K');
        Field('takeoff_active_derate_pct', Tr('Derate aktywny'), '%');
        Field('takeoff_selected_derate_pct', Tr('Derate wybrany'), '%');
        Field('takeoff_active_bump', Tr('Bump aktywny'), '');
        Field('takeoff_selected_bump', Tr('Bump wybrany'), '');
        Field('gross_weight_display', Tr('GW (jednostki FMC)'), '');
        Field('cruise_cg_pct', Tr('CRZ CG'), '%');
        Field('zfw_display', Tr('ZFW (jednostki FMC)'), '');
        Field('fuel_display', Tr('Fuel (jednostki FMC)'), '');
        Field('planned_fuel_display', Tr('Plan fuel (jednostki FMC)'), '');
        Field('fuel_source', Tr('Zrodlo fuel'), '');
        Field('reserves_display', Tr('Reserves (jednostki FMC)'), '');
        Field('cost_index', Tr('Cost index'), '');
        Field('cruise_altitude_ft', Tr('CRZ ALT'), 'ft');
        Field('transition_altitude_ft', Tr('TRANS ALT'), 'ft');
       End;
      mInfo.Lines.Add(Tr('Wartosci ze stron ostatnio widzianych; ukryte strony nie sa odswiezane.'));
     Finally
      Context.Free;
     End;
    End;

   Function ParseUTC(Value : String; Out Time : TDateTime) : Boolean;
    Var
     P : Integer;
    Begin
     P := Pos('_', Value);
     If P > 0 Then
      Value := Copy(Value, 1, P - 1);
     Result := TryISO8601ToDate(Value, Time, True);
    End;

  Begin
   If fConnection = Nil Then
    Exit;
   q            := TFDQuery.Create(Nil);
   q.Connection := fConnection;
   mInfo.Lines.BeginUpdate;
   Try
    mInfo.Clear;
    q.Open('select t.*,g.name as group_name from trips t left join trip_groups g on g.id=t.group_id where t.id=:t', [fTrip]);
    If q.IsEmpty Then
     Begin
      mInfo.Lines.Add(Tr('Nie znaleziono nagrania.'));
      Exit;
     End;
    Caption := Tr('Informacje o nagraniu #') + IntToStr(fTrip);
    Add('Trip', IntToStr(fTrip));
    TripField(Tr('Samolot'), 'title');
    TripField(Tr('Rejestracja'), 'atc_id');
    TripField(Tr('Linia'), 'atc_airline');
    TripField(Tr('Numer lotu'), 'atc_flight_number');
    TripField(Tr('Grupa'), 'group_name');
    mInfo.Lines.Add('');
    TripField(Tr('Lotnisko poczatkowe'), 'departure_icao');
    TripField(Tr('Pas poczatkowy'), 'departure_rwy');
    TripField(Tr('Lotnisko docelowe'), 'destination_icao');
    TripField(Tr('Pas docelowy'), 'destination_rwy');
    StartUTC := q.FieldByName('departure_zulu_time').AsString;
    EndUTC   := q.FieldByName('destination_zulu_time').AsString;
    mInfo.Lines.Add('');
    Add(Tr('Poczatek zapisu UTC'), StartUTC);
    Add(Tr('Koniec zapisu UTC'), EndUTC);
    TripField(Tr('Poczatek lokalnie'), 'departure_local_time');
    TripField(Tr('Koniec lokalnie'), 'destination_local_time');
    If EndUTC = '' Then
     Add(Tr('Stan'), Tr('Brak zapisanego zakonczenia'))
    Else
     Add(Tr('Stan'), Tr('Zakonczony'));
    q.Close;
    q.Open('select zulu_time from trip_data where trip=:t order by id desc limit 1', [fTrip]);
    LatestUTC := '';
    If Not q.IsEmpty Then
     LatestUTC := q.Fields[0].AsString;
    Add(Tr('Ostatnia probka UTC'), LatestUTC);
    If EndUTC = '' Then
     EndUTC := LatestUTC;
    If ParseUTC(StartUTC, StartTime) And ParseUTC(EndUTC, EndTime) And (EndTime >= StartTime) Then
     Begin
      Seconds := Round((EndTime - StartTime) * 86400);
      Add(Tr('Czas zapisu (symulator)'), Format('%d:%2.2d:%2.2d', [Seconds Div 3600, (Seconds Div 60) Mod 60, Seconds Mod 60]));
     End
    Else
     Add(Tr('Czas zapisu (symulator)'), Tr('brak danych lub zmiana czasu'));
    mInfo.Lines.Add('');
    Count(Tr('Probki telemetrii'), 'trip_data');
    Count(Tr('Zmiany komunikatow FSHud'), 'trip_fshud_messages');
    Count(Tr('Zdarzenia'), 'trip_events');
    Count(Tr('Oderwania'), 'trip_liftoffs');
    Count(Tr('Przyziemienia'), 'trip_touchdowns');
    Count(Tr('Zmiany danych SDK'), 'trip_aircraft_data');
    Count(Tr('Zmiany ekranow FMC/MCDU'), 'trip_fmc_screens');
    Count(Tr('Rewizje planu lotu'), 'trip_flight_plans');
    q.Close;
    q.Open('select summary from trip_flight_plans where trip=:t order by id desc limit 1', [fTrip]);
    If Not q.IsEmpty Then
     Begin
      mInfo.Lines.Add('');
      Add(Tr('Ostatni plan lotu'), q.Fields[0].AsString);
     End;
    q.Close;
    q.Open('select ''Start'' as phase,time_zulu,icao,runway,metar_text,metar_station,metar_observed_utc,metar_fetched_utc,metar_status,metar_error from trip_liftoffs where trip=:t ' + 'union all select ''Ladowanie'',time_zulu,icao,runway,metar_text,metar_station,metar_observed_utc,metar_fetched_utc,metar_status,metar_error from trip_touchdowns where trip=:t order by time_zulu', [fTrip]);
    mInfo.Lines.Add('');
    mInfo.Lines.Add(Tr('METAR - starty i ladowania'));
    HadContacts := Not q.IsEmpty;
    If q.IsEmpty Then
     mInfo.Lines.Add(Tr('Brak zarejestrowanych kontaktow z pasem.'));
    While Not q.Eof Do
     Begin
      mInfo.Lines.Add('');
      Add(q.FieldByName('phase').AsString, q.FieldByName('time_zulu').AsString);
      TripField(Tr('Lotnisko'), 'icao');
      TripField(Tr('Pas'), 'runway');
      TripField(Tr('Status METAR'), 'metar_status');
      TripField(Tr('Stacja METAR'), 'metar_station');
      TripField(Tr('Obserwacja UTC'), 'metar_observed_utc');
      TripField(Tr('Pobrano UTC'), 'metar_fetched_utc');
      TripField('METAR', 'metar_text');
      If q.FieldByName('metar_error').AsString <> '' Then
       TripField(Tr('Blad pobrania'), 'metar_error');
      AddFMC(q.FieldByName('time_zulu').AsString);
      q.Next;
     End;
    q.Close;
    If Not HadContacts Then
     Begin
      If EndUTC <> '' Then
       AddFMC(EndUTC)
      Else If LatestUTC <> '' Then
       AddFMC(LatestUTC)
      Else
       Begin
        q.Open('select max(time_zulu) from trip_fmc_screens where trip=:t', [fTrip]);
        If Not q.Fields[0].IsNull Then
         AddFMC(q.Fields[0].AsString);
        q.Close;
       End;
     End;
    q.Open('select captured_utc,evidence,payload from trip_simbrief where trip=:t', [fTrip]);
    mInfo.Lines.Add('');
    If q.IsEmpty Then
     Add(Tr('SimBrief'), Tr('brak przypisanego planu'))
    Else
     Begin
      Add(Tr('SimBrief - pobrano UTC'), q.FieldByName('captured_utc').AsString);
      Add(Tr('Dopasowanie'), q.FieldByName('evidence').AsString);
      Add('OFP', Tr('zapisany w bazie; przycisk Zapisz OFP eksportuje HTML'));
     End;
    mInfo.SelStart := 0;
   Finally
    mInfo.Lines.EndUpdate;
    q.Free;
   End;
  End;

End.
