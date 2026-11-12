Program VerifyViewState;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU In 'TestPathsU.pas', DUnitX.TestFramework, NativeTestRunnerU In 'NativeTestRunnerU.pas', Winapi.Windows, System.SysUtils, System.Classes, System.Types, System.IniFiles,
 Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, ViewStateU In '..\src\Core\ViewStateU.pas', frmViewWindowU In '..\src\Forms\frmViewWindowU.pas', frmMainU In '..\src\Forms\frmMainU.pas',
 fraFMCU In '..\src\Frames\fraFMCU.pas', fraSixPackU In '..\src\Frames\fraSixPackU.pas', fraEnginesU In '..\src\Frames\fraEnginesU.pas', fraMapU In '..\src\Frames\fraMapU.pas', fraGraphU In '..\src\Frames\fraGraphU.pas', frmSimBriefFrameU In '..\src\Frames\frmSimBriefFrameU.pas';

Procedure Check(b : Boolean; Const m : String);
 Begin
  If Not b Then
   Raise Exception.Create(m);
 End;

Const
 IDs : Array[0..5] Of String = ('map', 'charts', 'fmc', 'six_pack', 'engines', 'simbrief');

Function WindowOf(m : TfrmMain; i : Integer) : TfrmViewWindow;
 Begin
  Case i Of
   0 : Result := m.MapWindow;
   1 : Result := m.GraphWindow;
   2 : Result := m.FMCWindow;
   3 : Result := m.SixPackWindow;
   4 : Result := m.EnginesWindow;
   5 : Result := m.SimBriefWindow;
  Else Result := Nil;
  End;
 End;

Procedure Toggle(m : TfrmMain; i : Integer);
 Begin
  Case i Of
   0 : m.aMapWindow.Execute;
   1 : m.aGraphWindow.Execute;
   2 : m.FMCFrame.btnWindow.Click;
   3 : m.SixPackFrame.btnWindow.Click;
   4 : m.EnginesFrame.btnWindow.Click;
   5 : m.SimBriefFrame.aWindow.Execute;
  End;
 End;

Function MakeMain : TfrmMain;
 Begin
  Result               := TfrmMain.Create(Nil);
  Result.Timer.Enabled := False;
 End;

Procedure MainLifecycle;
 Var
  m    : TfrmMain;
  Ini  : TMemIniFile;
  b    : Array[0..5] Of TRect;
  Work : TRect;
  i    : Integer;
  w    : TfrmViewWindow;
  Name : String;
 Begin
  Name := TestDataDirectory + 'settings.ini';
  Ini  := TMemIniFile.Create(Name, TEncoding.UTF8);
  Try
   Ini.WriteBool('recording', 'enabled', False);
   Ini.WriteBool('map', 'online_tiles', False);
   Ini.UpdateFile;
  Finally
   Ini.Free;
  End;
  Work := Screen.PrimaryMonitor.WorkareaRect;
  m    := MakeMain;
  Try
   m.InstrumentsPanel.Height := 211;
   m.SixPackPanel.Width      := 321;
   For i                     := 0 To 5 Do
    Begin
     Toggle(m, i);
     w := WindowOf(m, i);
     Check(w <> Nil, 'Initial detach ' + IDs[i]);
     w.SetBounds(Work.Left + 20 + i * 10, Work.Top + 20 + i * 10, 520 + i * 12, 340 + i * 10);
     b[i] := w.BoundsRect;
    End;
   Application.ProcessMessages;
   For i := 0 To 5 Do
    Check(WindowOf(m, i) <> Nil, 'Queued restore must not toggle an already open view');
  Finally
   m.Free;
  End;
  Application.ProcessMessages;
  Ini := TMemIniFile.Create(Name, TEncoding.UTF8);
  Try
   Check(Ini.ReadInteger('layout', 'instruments_height', 0) = 211, 'Instrument container height persisted');
   Check(Ini.ReadInteger('layout', 'six_pack_width', 0) = 321, 'Instrument split width preserved while detached');
   For i := 0 To 5 Do
    Begin
     Check(Ini.ReadBool('view.' + IDs[i], 'detached', False), 'Shutdown preserves detached ' + IDs[i]);
     Check(Ini.ReadInteger('view.' + IDs[i], 'width', 0) = b[i].Width, 'Independent width ' + IDs[i]);
    End;
  Finally
   Ini.Free;
  End;
  m := MakeMain;
  Try
   Application.ProcessMessages;
   Check(m.InstrumentsPanel.Height = 211, 'Instrument container height restored');
   For i := 0 To 5 Do
    Begin
     w := WindowOf(m, i);
     Check(w <> Nil, 'Automatic restore ' + IDs[i]);
     Check(EqualRect(w.BoundsRect, b[i]), 'Independent restored bounds ' + IDs[i]);
    End;
   m.GraphWindow.Close;
   m.FMCFrame.btnWindow.Click;
   m.aMapWindow.Execute;
   Application.ProcessMessages;
   Check((m.GraphWindow = Nil) And (m.FMCWindow = Nil) And (m.MapWindow = Nil), 'Explicit return persists docked');
  Finally
   m.Free;
  End;
  Application.ProcessMessages;
  m := MakeMain;
  Try
   Application.ProcessMessages;
   Check((m.MapWindow = Nil) And (m.GraphWindow = Nil) And (m.FMCWindow = Nil), 'Only docked views stay docked after restart');
   Check((m.SixPackWindow <> Nil) And (m.EnginesWindow <> Nil), 'Detached siblings remain independent');
   Toggle(m, 0);
   Check(EqualRect(m.MapWindow.BoundsRect, b[0]), 'Docked view retains last floating geometry');
   Toggle(m, 0);
   Toggle(m, 3);
   Toggle(m, 4);
   Toggle(m, 5);
   Application.ProcessMessages;
  Finally
   m.Free;
  End;
  Application.ProcessMessages;
 End;

Type
 TFuture = Class
  Host   : TForm;
  Dock   : TPanel;
  Frame  : TFrame;
  Window : TfrmViewWindow;
  Store  : TViewStateStore;
  Constructor Create  (Config : TCustomIniFile);
  Destructor  Destroy; Override;
  Procedure   Toggle  (Sender : TObject);
  Procedure   Returned(Sender : TObject);
 End;

Constructor TFuture.Create(Config : TCustomIniFile);
 Begin
  Inherited Create;
  Host         := TForm.Create(Nil);
  Dock         := TPanel.Create(Host);
  Dock.Parent  := Host;
  Dock.Align   := alClient;
  Frame        := TFrame.Create(Host);
  Frame.Parent := Dock;
  Frame.Align  := alClient;
  Store        := TViewStateStore.Create(Config);
  Store.RegisterView('future_hud', Toggle);
 End;

Destructor TFuture.Destroy;
 Begin
  Window.Free;
  Store.Free;
  Host.Free;
  Inherited;
 End;

Procedure TFuture.Returned(Sender : TObject);
 Begin
  Window := Nil;
 End;

Procedure TFuture.Toggle(Sender : TObject);
 Begin
  If Window <> Nil Then
   Begin
    Window.Close;
    Exit;
   End;
  Window := TfrmViewWindow.Create(Host);
  Window.Attach(Frame, Dock, 'Future', Returned, Store, 'future_hud');
 End;

Procedure FutureAndGeometry;
 Var
  Ini    : TMemIniFile;
  p      : TFuture;
  b      : TRect;
  Work   : TRect;
  Failed : Boolean;
 Begin
  Ini := TMemIniFile.Create(TestDataDirectory + 'future.ini', TEncoding.UTF8);
  Try
   p := TFuture.Create(Ini);
   Try
    p.Store.Restore;
    Check(p.Window = Nil, 'Missing settings default docked');
    p.Toggle(Nil);
    Work := Screen.PrimaryMonitor.WorkareaRect;
    p.Window.SetBounds(Work.Left + 30, Work.Top + 30, 540, 350);
    b                    := p.Window.BoundsRect;
    p.Window.WindowState := wsMaximized;
    Application.ProcessMessages;
    p.Store.BeginShutdown;
    Check(Ini.ReadInteger('view.future_hud', 'width', 0) = b.Width, 'Save normal width while maximized');
    Check(Ini.ReadBool('view.future_hud', 'maximized', False), 'Maximized flag');
   Finally
    p.Free;
   End;
   p := TFuture.Create(Ini);
   Try
    p.Store.Restore;
    Check((p.Window <> Nil) And (p.Window.WindowState = wsMaximized), 'Future frame restores without Main changes');
    p.Window.Close;
    Application.ProcessMessages;
    Check(Not Ini.ReadBool('view.future_hud', 'detached', True), 'Close records docked');
    p.Store.Restore;
    Check(p.Window = Nil, 'Restore once; never reopen after explicit docking');
    p.Toggle(Nil);
    p.Window.WindowState := wsNormal;
    p.Window.SetBounds(b.Left, b.Top, b.Width, b.Height);
    p.Window.WindowState := wsMinimized;
    Application.ProcessMessages;
    p.Store.BeginShutdown;
    Check(Ini.ReadInteger('view.future_hud', 'width', 0) = b.Width, 'Minimize does not save minimized geometry');
   Finally
    p.Free;
   End;
   p := TFuture.Create(Ini);
   Try
    p.Store.Restore;
    Check(p.Window.WindowState = wsNormal, 'Do not start hidden/minimized');
    Check(EqualRect(p.Window.BoundsRect, b), 'Normal bounds retained through minimize');
    p.Store.Reset;
    Application.ProcessMessages;
    Check(p.Window = Nil, 'Reset docks all registered views');
    Check(Not Ini.SectionExists('view.future_hud'), 'Reset clears state and geometry');
    Failed := False;
    Try
     p.Store.RegisterView('bad]id', p.Toggle);
    Except
     On E : EArgumentException Do
      Failed := True;
    End;
    Check(Failed, 'Invalid IDs rejected');
    Failed := False;
    Try
     p.Store.RegisterView('future_hud', p.Toggle);
    Except
     On E : EArgumentException Do
      Failed := True;
    End;
    Check(Failed, 'Duplicate IDs rejected');
   Finally
    p.Free;
   End;
   Ini.WriteBool('view.future_hud', 'detached', True);
   Ini.WriteBool('view.future_hud', 'maximized', False);
   Ini.WriteInteger('view.future_hud', 'width', 1000);
   Ini.WriteInteger('view.future_hud', 'height', 800);
   Ini.WriteInteger('view.future_hud', 'left', Work.Left + 10);
   Ini.WriteInteger('view.future_hud', 'top', Work.Top + 10);
   p := TFuture.Create(Ini);
   Try
    // Emulate settings saved at twice this process's DPI.
    Ini.WriteInteger('view.future_hud', 'ppi', p.Host.PixelsPerInch * 2);
    p.Store.Restore;
    Check((p.Window.Width = 500) And (p.Window.Height = 400), 'DPI conversion of floating dimensions');
    p.Window.Close;
    Application.ProcessMessages;
   Finally
    p.Free;
   End;
   Ini.WriteBool('view.future_hud', 'detached', True);
   Ini.WriteInteger('view.future_hud', 'left', MaxInt);
   Ini.WriteInteger('view.future_hud', 'top', Low(Integer));
   Ini.WriteInteger('view.future_hud', 'width', MaxInt);
   Ini.WriteInteger('view.future_hud', 'height', -1);
   Ini.WriteInteger('view.future_hud', 'ppi', 0);
   p := TFuture.Create(Ini);
   Try
    p.Store.Restore;
    Work := Screen.MonitorFromWindow(p.Window.Handle).WorkareaRect;
    Check((p.Window.Left >= Work.Left) And (p.Window.Top >= Work.Top) And (p.Window.BoundsRect.Right <= Work.Right) And (p.Window.BoundsRect.Bottom <= Work.Bottom), 'Corrupt/offscreen bounds recovered to a monitor');
    p.Store.BeginShutdown;
   Finally
    p.Free;
   End;
  Finally
   Ini.Free;
  End;
 End;

Type

 [TestFixture]
 TVerifyViewStateTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyViewStateTests.Regression;
 Begin
  Try
   Application.Initialize;
   MainLifecycle;
   FutureAndGeometry;
   System.Writeln('PASS: all six Main view slots persist independent dock/float and bounds over restarts; return button/Close/shutdown, geometry while docked, generic future frame, ' +
   'maximize/minimize normal bounds, reset, corrupt/offscreen coordinates, duplicate IDs and restore-once. Synthetic VCL/INI only.');
  Except
   On E : Exception Do
    Begin
     System.Writeln(E.ClassName + ': ' + E.Message);
     Raise Exception.Create('Regression failed; see diagnostic above');
    End;
  End;

 End;

Begin
 RunNativeTests(TVerifyViewStateTests);
End.
