Unit frmWeatherU;

Interface

 Uses
  System.Classes, System.Generics.Collections, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Comp.Client, LocalizationU, i18nLocalizer, i18nCore, Vcl.Controls;

 Type
  TWeatherEvent = Record
   TableName    : String;
   Time         : String;
   ICAO         : String;
   RealText     : String;
   RealStatus   : String;
   RealError    : String;
   RealObserved : String;
   RealFetched  : String;
   ID           : Integer;
  End;

  TfrmWeather = Class(TLocalizedForm)
    AppTranslator : TTranslator;
    Events        : TComboBox;
    Sources       : TPanel;
    SimulatorBox  : TGroupBox;
    RealBox       : TGroupBox;
    SimulatorMemo : TMemo;
    RealMemo      : TMemo;
    CompareBox    : TGroupBox;
    CompareMemo   : TMemo;
    Buttons       : TPanel;
    btnRefresh    : TButton;
    btnFetch      : TButton;
    btnClose      : TButton;
    RefreshTimer  : TTimer;
    Procedure SourcesResize(Sender : TObject);
    Procedure RefreshClick (Sender : TObject);
    Procedure EventChanged (Sender : TObject);
    Procedure FetchClick   (Sender : TObject);
   Private
    fConnection : TFDConnection;
    fTrip       : Integer;
    fRows       : TList<TWeatherEvent>;
    fFetch      : TNotifyEvent;
    Function  HasReports : Boolean;
    Procedure Reload;
   Public
    Destructor Destroy; Override;
    Procedure  Load(Connection : TFDConnection; Trip : Integer; AllowFetch : Boolean; OnFetch : TNotifyEvent);
  End;

Implementation

 Uses
  System.SysUtils, Data.DB, MetarDecodeU;
{$R *.dfm}

 Function Cell(q : TFDQuery; Const Name : String) : String;
  Var
   f : TField;
  Begin
   f := q.FindField(Name);
   If f = Nil Then
    Result := ''
   Else
    Result := f.AsString;
  End;

 Procedure SetText(m : TMemo; Const s : String);
  Begin
   If m.Text <> s Then
    m.Text := s;
  End;

 Destructor TfrmWeather.Destroy;
  Begin
   RefreshTimer.Enabled := False;
   fRows.Free;
   Inherited;
  End;

 Function TfrmWeather.HasReports : Boolean;
  Begin
   Result := fConnection.ExecSQLScalar('select count(*) from sqlite_master where type=''table'' and name=''trip_weather_reports''') <> 0;
  End;

 Procedure TfrmWeather.Load(Connection : TFDConnection; Trip : Integer; AllowFetch : Boolean; OnFetch : TNotifyEvent);
  Begin
   fConnection      := Connection;
   fTrip            := Trip;
   fFetch           := OnFetch;
   fRows            := TList<TWeatherEvent>.Create;
   btnFetch.Enabled := AllowFetch;
   Reload;
   RefreshTimer.Enabled := True;
  End;

 Procedure TfrmWeather.Reload;
  Const
   Tables : Array [0..1] Of String = ('trip_liftoffs', 'trip_touchdowns');
  Var
   q         : TFDQuery;
   TableName : String;
   Phase     : String;
   Selected  : String;
   e         : TWeatherEvent;
   i         : Integer;
   Index     : Integer;
  Begin
   If (fConnection = Nil) Or (fRows = Nil) Then
    Exit;
   Selected := '';
   Index    := Events.ItemIndex;
   If (Index >= 0) And (Index < fRows.Count) Then
    Selected := fRows[Index].TableName + IntToStr(fRows[Index].ID);
   Events.Items.BeginUpdate;
   q := TFDQuery.Create(Nil);
   Try
    fRows.Clear;
    Events.Items.Clear;
    q.Connection := fConnection;
    For TableName In Tables Do
     Begin
      q.SQL.Text                   := 'select * from ' + TableName + ' where trip=:t order by id';
      q.ParamByName('t').AsInteger := fTrip;
      q.Open;
      If TableName = 'trip_liftoffs' Then
       Phase := Tr('Start')
      Else
       Phase := Tr('Lądowanie');
      While Not q.Eof Do
       Begin
        e              := Default(TWeatherEvent);
        e.TableName    := TableName;
        e.ID           := q.FieldByName('id').AsInteger;
        e.Time         := Cell(q, 'time_zulu');
        e.ICAO         := Cell(q, 'icao');
        e.RealText     := Cell(q, 'metar_text');
        e.RealStatus   := Cell(q, 'metar_status');
        e.RealError    := Cell(q, 'metar_error');
        e.RealObserved := Cell(q, 'metar_observed_utc');
        e.RealFetched  := Cell(q, 'metar_fetched_utc');
        fRows.Add(e);
        Events.Items.Add(Phase + ' / ' + e.ICAO + ' / ' + e.Time);
        q.Next;
       End;
      q.Close;
     End;
    Events.ItemIndex := -1;
    For i            := 0 To fRows.Count - 1 Do
     If fRows[i].TableName + IntToStr(fRows[i].ID) = Selected Then
      Events.ItemIndex := i;
    If (Events.ItemIndex < 0) And (fRows.Count > 0) Then
     Events.ItemIndex := 0;
   Finally
    q.Free;
    Events.Items.EndUpdate;
   End;
   EventChanged(Self);
  End;

 Procedure TfrmWeather.SourcesResize(Sender : TObject);
  Begin
   If SimulatorBox <> Nil Then
    SimulatorBox.Width := Sources.ClientWidth Div 2;
  End;

 Procedure TfrmWeather.RefreshClick(Sender : TObject);
  Begin
   Reload;
  End;

 Procedure TfrmWeather.FetchClick(Sender : TObject);
  Begin
   If Assigned(fFetch) Then
    fFetch(Self);
   Reload;
  End;

 Procedure TfrmWeather.EventChanged(Sender : TObject);
  Var
   e        : TWeatherEvent;
   q        : TFDQuery;
   SimText  : String;
   RealText : String;
   SimInfo  : String;
   RealInfo : String;
   TAFText  : String;
   Source   : String;

   Function Description(Const Raw, Status, Error, Station, Observed, Fetched : String) : String;
    Begin
     Result := Raw + sLineBreak + sLineBreak + Tr('Status') + ': ' + Status + sLineBreak + 'ICAO: ' + Station + sLineBreak + Tr('Obserwacja UTC') + ': ' + Observed + sLineBreak + Tr('Pobrano UTC') + ': ' + Fetched + sLineBreak;
     If Error <> '' Then
      Result := Result + Error + sLineBreak;
     If Raw <> '' Then
      Result := Result + sLineBreak + DecodedMetarText(Raw);
    End;

  Begin
   If (Events.ItemIndex < 0) Or (Events.ItemIndex >= fRows.Count) Then
    Begin
     SetText(SimulatorMemo, '');
     SetText(RealMemo, '');
     SetText(CompareMemo, Tr('Brak dwóch raportów do porównania'));
     Exit;
    End;
   e        := fRows[Events.ItemIndex];
   RealText := e.RealText;
   SimText  := '';
   SimInfo  := Tr('Brak zapisanego raportu MSFS');
   TAFText  := '';
   RealInfo := Description(e.RealText, e.RealStatus, e.RealError, e.ICAO, e.RealObserved, e.RealFetched);
   If HasReports Then
    Begin
     q := TFDQuery.Create(Nil);
     Try
      q.Connection                  := fConnection;
      q.SQL.Text                    := 'select * from trip_weather_reports where trip=:t and contact_table=:tb and contact_id=:id';
      q.ParamByName('t').AsInteger  := fTrip;
      q.ParamByName('tb').AsString  := e.TableName;
      q.ParamByName('id').AsInteger := e.ID;
      q.Open;
      While Not q.Eof Do
       Begin
        Source := Cell(q, 'source');
        If Source = 'msfs' Then
         Begin
          SimText := Cell(q, 'metar_text');
          TAFText := Cell(q, 'taf_text');
          SimInfo := Description(SimText, Cell(q, 'status'), Cell(q, 'error'), Cell(q, 'station'), DecodeMetarReport(SimText).TimeGroup, Cell(q, 'fetched_utc'));
          SimInfo := SimInfo + sLineBreak + Tr('Żądane lotnisko') + ': ' + Cell(q, 'requested_station');
         End
        Else If Source = 'aviationweather.gov' Then
         Begin
          RealText := Cell(q, 'metar_text');
          RealInfo := Description(RealText, Cell(q, 'status'), Cell(q, 'error'), Cell(q, 'station'), Cell(q, 'observed_utc'), Cell(q, 'fetched_utc'));
         End;
        q.Next;
       End;
     Finally
      q.Free;
     End;
    End;
   If TAFText <> '' Then
    SimInfo := SimInfo + sLineBreak + sLineBreak + 'TAF:' + sLineBreak + TAFText;
   SetText(SimulatorMemo, SimInfo);
   SetText(RealMemo, RealInfo);
   SetText(CompareMemo, CompareMetarReports(SimText, RealText));
  End;

End.
