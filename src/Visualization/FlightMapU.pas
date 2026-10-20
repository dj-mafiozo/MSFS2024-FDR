{$StackFrames On}
Unit FlightMapU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Types, System.Math, System.IOUtils,
  System.SyncObjs, System.Generics.Collections, System.Net.HttpClient, Vcl.Controls,
  Vcl.Graphics, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  FlightDatabaseU, FlightPlanU, LocalizationU;

 Type
  TTileWorker = Class(TThread)
   Private
    fQueue : TThreadList<String>;
    fRoot  : String;
   Protected
    Procedure Execute; Override;
   Public
    Constructor Create(Const Root : String);
    Destructor Destroy; Override;
    Procedure Request(Const Key : String);
  End;

  TFlightMap = Class(TCustomControl)
   Private
    fWorker    : TTileWorker;
    fCache     : TObjectDictionary<String, TPngImage>;
    fRequested : TDictionary<String, Boolean>;
    fTimer     : TTimer;
    fRoot      : String;
    fZoom      : Integer;
    fX, fY     : Double;
    fDrag      : Boolean;
    fLast      : TPoint;
    fData      : TTripPlot;
    fCursor    : Integer;
    Procedure Tick(Sender : TObject);
    Function Project(Lat, Lon : Double) : TPointF;
   Protected
    Procedure Paint; Override;
    Procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); Override;
    Procedure MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); Override;
    Procedure MouseMove(Shift : TShiftState; X, Y : Integer); Override;
    Function DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean; Override;
   Public
    TilesEnabled : Boolean;
    Constructor Create(AOwner : TComponent); Override;
    Destructor Destroy; Override;
    Procedure SetData(Data : TTripPlot);
    Procedure SetCursor(Index : Integer);
    Procedure Fit;
  End;

Implementation

 Constructor TTileWorker.Create(Const Root : String);
  Begin
   Inherited Create(True);
   FreeOnTerminate := False;
   fRoot           := Root;
   fQueue          := TThreadList<String>.Create;
  End;

 Destructor TTileWorker.Destroy;
  Begin
   Terminate;
   WaitFor;
   fQueue.Free;
   Inherited;
  End;

 Procedure TTileWorker.Request(Const Key : String);
  Begin
   fQueue.Add(Key);
  End;

 Procedure TTileWorker.Execute;
  Var
   HTTP     : THTTPClient;
   List     : TList<String>;
   Key      : String;
   Path     : String;
   Tmp      : String;
   Response : IHTTPResponse;
   Stream   : TMemoryStream;
  Begin
   HTTP := THTTPClient.Create;
   Try
    HTTP.UserAgent         := 'MSFS-FDR-Delphi/1.0';
    HTTP.ConnectionTimeout := 2000;
    HTTP.ResponseTimeout   := 3000;
    While Not Terminated Do
     Begin
      Key  := '';
      List := fQueue.LockList;
      Try
       If List.Count > 0 Then
        Begin
         Key := List[0];
         List.Delete(0);
        End;
      Finally
       fQueue.UnlockList;
      End;
      If Key = '' Then
       Begin
        Sleep(100);
        Continue;
       End;
      Path := TPath.Combine(fRoot, Key.Replace('/', '_') + '.png');
      If FileExists(Path) And (Now - TFile.GetLastWriteTime(Path) < 7) Then
       Continue;
      Stream := TMemoryStream.Create;
      Try
       Response := HTTP.Get('https://tile.openstreetmap.org/' + Key + '.png', Stream);
       If (Response.StatusCode = 200) And Not Terminated Then
        Begin
         ForceDirectories(fRoot);
         Tmp := Path + '.tmp';
         Stream.SaveToFile(Tmp);
         If FileExists(Path) Then
          DeleteFile(Path);
         RenameFile(Tmp, Path);
        End;
      Except
      End;
      Stream.Free;
     End;
   Finally
    HTTP.Free;
   End;
  End;

 Constructor TFlightMap.Create(AOwner : TComponent);
  Begin
   Inherited;
   ParentBiDiMode := False;
   BiDiMode       := bdLeftToRight;
   DoubleBuffered := True;
   fZoom          := 4;
   TilesEnabled   := True;
   fRoot          := TPath.Combine(GetEnvironmentVariable('LOCALAPPDATA'), 'MSFS-FDR-Delphi\tiles');
   fCache         := TObjectDictionary<String, TPngImage>.Create([doOwnsValues]);
   fRequested     := TDictionary<String, Boolean>.Create;
   fWorker        := TTileWorker.Create(fRoot);
   fWorker.Start;
   fTimer          := TTimer.Create(Self);
   fTimer.Interval := 500;
   fTimer.OnTimer  := Tick;
   fX              := Project(52, 19).X;
   fY              := Project(52, 19).Y;
  End;

 Destructor TFlightMap.Destroy;
  Begin
   If Assigned(fTimer) Then
    fTimer.Enabled := False;
   fWorker.Free;
   fCache.Free;
   fRequested.Free;
   Inherited;
  End;

 Procedure TFlightMap.Tick(Sender : TObject);
  Begin
   Invalidate;
  End;

 Function TFlightMap.Project(Lat, Lon : Double) : TPointF;
  Var
   Size : Double;
  Begin
   Size     := 256 * Power(2, fZoom);
   Lat      := EnsureRange(Lat, -85.051128, 85.051128);
   Result.X := (Lon + 180) / 360 * Size;
   Result.Y := (1 - Ln(Tan(DegToRad(Lat)) + 1 / Cos(DegToRad(Lat))) / Pi) / 2 * Size;
  End;

 Procedure TFlightMap.Paint;
  Const
   Colors : Array [0 .. 7] Of Integer = ($55BB11, $3344DD, $CC6600, $AA44AA, $00AAAA, $EE6699, $CCAAAA, $8855EE);
  Var
   X            : Integer;
   Y            : Integer;
   TX           : Integer;
   TY           : Integer;
   N            : Integer;
   Key          : String;
   Path         : String;
   PNG          : TPngImage;
   P            : TPointF;
   I            : Integer;
   ContactPoint : TContactView;
   PlanPoint    : TPlanPoint;
  Begin
   Canvas.Brush.Color := $30251B;
   Canvas.FillRect(ClientRect);
   N := Round(Power(2, fZoom));
   If TilesEnabled Then
    For Y  := Floor((fY - Height / 2) / 256) To Floor((fY + Height / 2) / 256) Do
     For X := Floor((fX - Width / 2) / 256) To Floor((fX + Width / 2) / 256) Do
      Begin
       If (Y < 0) Or (Y >= N) Then
        Continue;
       TX  := ((X Mod N) + N) Mod N;
       TY  := Y;
       Key := IntToStr(fZoom) + '/' + IntToStr(TX) + '/' + IntToStr(TY);
       If Not fCache.TryGetValue(Key, PNG) Then
        Begin
         Path := TPath.Combine(fRoot, Key.Replace('/', '_') + '.png');
         If FileExists(Path) Then
          Begin
           PNG := TPngImage.Create;
           Try
            PNG.LoadFromFile(Path);
            fCache.Add(Key, PNG);
           Except
            PNG.Free;
            PNG := Nil;
           End;
          End;
         If Not fRequested.ContainsKey(Key) Then
          Begin
           fRequested.Add(Key, True);
           fWorker.Request(Key);
          End;
        End;
       If Assigned(PNG) Then
        Canvas.Draw(Round(X * 256 - fX + Width / 2), Round(Y * 256 - fY + Height / 2), PNG);
      End;
   If Assigned(fData) Then
    Begin
     If fData.FlightPlan <> Nil Then
      Begin
       Canvas.Pen.Color := clFuchsia;
       Canvas.Pen.Width := 1;
       Canvas.Pen.Style := psDash;
       For I            := 0 To fData.FlightPlan.Points.Count - 1 Do
        Begin
         PlanPoint := fData.FlightPlan.Points[I];
         P         := Project(PlanPoint.Lat, PlanPoint.Lon);
         X         := Round(P.X - fX + Width / 2);
         Y         := Round(P.Y - fY + Height / 2);
         If (I = 0) Or PlanPoint.BreakBefore Then
          Canvas.MoveTo(X, Y)
         Else
          Canvas.LineTo(X, Y);
         Canvas.Brush.Style := bsClear;
         Canvas.Font.Color  := clFuchsia;
         Canvas.TextOut(X + 3, Y + 3, PlanPoint.Ident);
         Canvas.Brush.Style := bsSolid;
        End;
       Canvas.Pen.Style := psSolid;
      End;
     Canvas.Pen.Color := $55BB11;
     Canvas.Pen.Width := 3;
     For I            := 0 To fData.Points.Count - 1 Do
      Begin
       P                := Project(fData.Points[I].Lat, fData.Points[I].Lon);
       Canvas.Pen.Color := Colors[fData.Points[I].GroupID Mod 8];
       If (I = 0) Or fData.Points[I].BreakBefore Then
        Canvas.MoveTo(Round(P.X - fX + Width / 2), Round(P.Y - fY + Height / 2))
       Else
        Canvas.LineTo(Round(P.X - fX + Width / 2), Round(P.Y - fY + Height / 2));
      End;
     For ContactPoint In fData.Contacts Do
      Begin
       P                  := Project(ContactPoint.Lat, ContactPoint.Lon);
       X                  := Round(P.X - fX + Width / 2);
       Y                  := Round(P.Y - fY + Height / 2);
       Canvas.Pen.Color   := clWhite;
       Canvas.Brush.Color := clLime;
       If ContactPoint.Kind = Tr('Landing') Then
        Canvas.Brush.Color := clRed;
       Canvas.Rectangle(X - 5, Y - 5, X + 5, Y + 5);
      End;
     If (fCursor >= 0) And (fCursor < fData.Points.Count) Then
      Begin
       P                  := Project(fData.Points[fCursor].Lat, fData.Points[fCursor].Lon);
       X                  := Round(P.X - fX + Width / 2);
       Y                  := Round(P.Y - fY + Height / 2);
       Canvas.Brush.Color := clYellow;
       Canvas.Pen.Color   := clBlack;
       Canvas.Ellipse(X - 6, Y - 6, X + 6, Y + 6);
      End;
    End;
   Canvas.Font.Color  := clBlack;
   Canvas.Brush.Color := clWhite;
   Canvas.TextOut(4, Height - 20, Tr(#169' OpenStreetMap contributors | k'#243#322'ko: zoom, przeci'#261'gnij: mapa'));
  End;

 Procedure TFlightMap.SetData(Data : TTripPlot);
  Begin
   fData   := Data;
   fCursor := 0;
   Fit;
  End;

 Procedure TFlightMap.SetCursor(Index : Integer);
  Begin
   fCursor := Index;
   Invalidate;
  End;

 Procedure TFlightMap.Fit;
  Var
   MinX      : Double;
   MaxX      : Double;
   MinY      : Double;
   MaxY      : Double;
   P         : TPointF;
   Item      : TPlotPoint;
   PlanPoint : TPlanPoint;
  Begin
   If Not Assigned(fData) Then
    Exit;
   If fData.Points.Count = 0 Then
    If (fData.FlightPlan = Nil) Or (fData.FlightPlan.Points.Count = 0) Then
     Exit;
   fZoom := 16;
   Repeat
    MinX := MaxDouble;
    MinY := MaxDouble;
    MaxX := -MaxDouble;
    MaxY := -MaxDouble;
    For Item In fData.Points Do
     Begin
      P    := Project(Item.Lat, Item.Lon);
      MinX := Min(MinX, P.X);
      MaxX := Max(MaxX, P.X);
      MinY := Min(MinY, P.Y);
      MaxY := Max(MaxY, P.Y);
     End;
    If fData.FlightPlan <> Nil Then
     For PlanPoint In fData.FlightPlan.Points Do
      Begin
       P    := Project(PlanPoint.Lat, PlanPoint.Lon);
       MinX := Min(MinX, P.X);
       MaxX := Max(MaxX, P.X);
       MinY := Min(MinY, P.Y);
       MaxY := Max(MaxY, P.Y);
      End;
    If ((MaxX - MinX < Width - 60) And (MaxY - MinY < Height - 60)) Or (fZoom = 2) Then
     Break;
    Dec(fZoom);
   Until False;
   fX := (MinX + MaxX) / 2;
   fY := (MinY + MaxY) / 2;
   Invalidate;
  End;

 Procedure TFlightMap.MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
  Begin
   Inherited;
   If Button = mbLeft Then
    Begin
     fDrag        := True;
     fLast        := Point(X, Y);
     MouseCapture := True;
    End;
  End;

 Procedure TFlightMap.MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
  Begin
   Inherited;
   fDrag        := False;
   MouseCapture := False;
  End;

 Procedure TFlightMap.MouseMove(Shift : TShiftState; X, Y : Integer);
  Begin
   Inherited;
   If fDrag Then
    Begin
     fX    := fX + fLast.X - X;
     fY    := fY + fLast.Y - Y;
     fLast := Point(X, Y);
     Invalidate;
    End;
  End;

 Function TFlightMap.DoMouseWheel(Shift : TShiftState; WheelDelta : Integer; MousePos : TPoint) : Boolean;
  Var
   Old    : Integer;
   Factor : Double;
  Begin
   Old    := fZoom;
   fZoom  := EnsureRange(fZoom + Sign(WheelDelta), 2, 19);
   Factor := Power(2, fZoom - Old);
   fX     := fX * Factor;
   fY     := fY * Factor;
   Invalidate;
   Result := True;
  End;

End.
