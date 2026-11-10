Program VerifyInstrumentRender;
{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
{$RTTI EXPLICIT METHODS([vcPublic])}

Uses
 TestPathsU, DUnitX.TestFramework, NativeTestRunnerU, Winapi.Messages, Winapi.Windows, System.SysUtils, System.Types, Vcl.Forms, Vcl.Controls,
 Vcl.Graphics, Vcl.Imaging.pngimage, InstrumentRenderU, Boeing737PFDU, AirbusPFDU,
 SixPackU, B38MEICASU;

Procedure Check(b : Boolean; Const s : String);
 Begin
  If Not b Then
   Raise Exception.Create(s);
 End;

Type
 TPaintAccess = Class(TCustomControl)
  Public
   Procedure Snapshot(Dest : TCanvas; x, y : Integer);
 End;

Procedure TPaintAccess.Snapshot(Dest : TCanvas; x, y : Integer);
 Var
  Saved : Integer;
 Begin
  Dest.Lock;
  Saved         := SaveDC(Dest.Handle);
  Canvas.Handle := Dest.Handle;
  Try
   SetViewportOrgEx(Dest.Handle, x, y, Nil);
   Paint;
  Finally
   Canvas.Handle := 0;
   RestoreDC(Dest.Handle, Saved);
   Dest.Refresh;
   Dest.Unlock;
  End;
 End;

Const
 Percentages : Array[0..7] Of Integer = (25, 50, 75, 100, 125, 150, 200, 300);

Var
 Source  : Vcl.Graphics.TBitmap;
 Dest    : Vcl.Graphics.TBitmap;
 Preview : Vcl.Graphics.TBitmap;
 DC      : Integer;
 Scale   : Integer;
 Percent : Integer;
 x       : Integer;
 y       : Integer;
 Gray    : Integer;
 Col     : TColor;
 Region  : HRGN;
 PNG     : TPngImage;
 Main    : TForm;
 Boeing  : TPFD737Display;
 Airbus  : TAirbusPFD;
 Analog  : TSixPackDisplay;
 Eicas   : TB38MEICAS;

Type

 [TestFixture]
 TVerifyInstrumentRenderTests = Class
  Public
   [Test] Procedure Regression;
 End;

Procedure TVerifyInstrumentRenderTests.Regression;
 Begin
  Application.Initialize;
  Source  := Vcl.Graphics.TBitmap.Create;
  Dest    := Vcl.Graphics.TBitmap.Create;
  Preview := Vcl.Graphics.TBitmap.Create;
  Try
   For Scale := 0 To High(Percentages) Do
    Begin
     Percent := Percentages[Scale];
     DC      := BeginInstrumentRender(Source, 100, 100, Percent, Percent);
     Try
      Check(Source.Width >= 2 * Percent, 'Supersampling follows final physical size');
      Source.Canvas.Brush.Color := clBlack;
      Source.Canvas.FillRect(Rect(0, 0, 100, 100));
      Source.Canvas.Pen.Color := clWhite;
      Source.Canvas.Pen.Width := 2;
      Source.Canvas.MoveTo(10, 10);
      Source.Canvas.LineTo(90, 67);
      Region := CreateEllipticRgn(25, 25, 75, 75);
      Try
       SelectInstrumentClip(Source.Canvas, Region);
       Source.Canvas.Brush.Color := clRed;
       Source.Canvas.FillRect(Rect(0, 0, 100, 100));
      Finally
       DeleteObject(Region);
      End;
     Finally
      EndInstrumentRender(Source, DC);
     End;
     Check(GetMapMode(Source.Canvas.Handle) = MM_TEXT, 'Source mapping restored');
     Dest.SetSize(Percent, Percent);
     DrawInstrumentBitmap(Dest.Canvas, Rect(0, 0, Dest.Width, Dest.Height), Source);
     Check(ColorToRGB(Dest.Canvas.Pixels[Percent Div 2, Percent Div 2]) = clRed, 'Scaled clip includes center');
     Check(ColorToRGB(Dest.Canvas.Pixels[5 * Percent Div 100, 5 * Percent Div 100]) = clBlack, 'Scaled clip excludes outside');
     Gray   := 0;
     For y  := 0 To Dest.Height - 1 Do
      For x := 0 To Dest.Width - 1 Do
       Begin
        Col := ColorToRGB(Dest.Canvas.Pixels[x, y]);
        If (GetRValue(Col) = GetGValue(Col)) And (GetRValue(Col) = GetBValue(Col)) And
        (GetRValue(Col) > 0) And (GetRValue(Col) < 255) Then
         Inc(Gray);
       End;
     Check(Gray > 0, 'Downsample creates antialiased intermediate edge pixels');
    End;
   Main := TForm.Create(Nil);
   Try
    B38MInfoEnabled := False;
    Boeing          := TPFD737Display.Create(Main);
    Boeing.Parent   := Main;
    Boeing.SetBounds(0, 0, 860, 640);
    Airbus        := TAirbusPFD.Create(Main);
    Airbus.Parent := Main;
    Airbus.SetBounds(0, 0, 640, 640);
    Analog        := TSixPackDisplay.Create(Main);
    Analog.Parent := Main;
    Analog.SetBounds(0, 0, 640, 480);
    Eicas := TB38MEICAS.Create;
    Try
     Preview.SetSize(1500, 1280);
     Preview.Canvas.Brush.Color := clBlack;
     Preview.Canvas.FillRect(Rect(0, 0, 1500, 1280));
     TPaintAccess(Boeing).Snapshot(Preview.Canvas, 0, 0);
     Check(ColorToRGB(Preview.Canvas.Pixels[300, 20]) <> clBlack, 'Real PFD draws onto preview bitmap');
     TPaintAccess(Airbus).Snapshot(Preview.Canvas, 860, 0);
     TPaintAccess(Analog).Snapshot(Preview.Canvas, 0, 640);
     Eicas.PaintTo(Preview.Canvas, Rect(860, 640, 1500, 1280));
     PNG := TPngImage.Create;
     Try
      PNG.Assign(Preview);
      PNG.SaveToFile(TestDataDirectory + 'instrument-aa.png');
     Finally
      PNG.Free;
     End;
     System.Writeln('Preview: ' + TestDataDirectory + 'instrument-aa.png');
    Finally
     Eicas.Free;
    End;
   Finally
    Main.Free;
   End;
  Finally
   Preview.Free;
   Dest.Free;
   Source.Free;
  End;
  System.Writeln('PASS: scaled supersampling at 25/50/75/100/125/150/200/300 percent, antialiased edges, transformed clipping and DC restoration; real instrument render smoke test. Synthetic only.');

 End;

Begin
 RunNativeTests(TVerifyInstrumentRenderTests);
End.
