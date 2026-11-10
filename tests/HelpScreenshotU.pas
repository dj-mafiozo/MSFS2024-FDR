Unit HelpScreenshotU;

Interface

 Uses
  Vcl.Forms, Vcl.ComCtrls, Vcl.Graphics;

 Function CaptureHelpWindow(Form : TCustomForm) : Vcl.Graphics.TBitmap;
 Function HelpReportText(Form : TCustomForm) : TRichEdit;

Implementation

 Uses
  Winapi.Windows, Winapi.Messages, Winapi.RichEdit, System.SysUtils, System.Types, Vcl.Controls;

 Function HelpReportText(Form : TCustomForm) : TRichEdit;
  Var
   i : Integer;
  Begin
   Result := Nil;
   For i  := 0 To Form.ComponentCount - 1 Do
    If (Form.Components[i] Is TRichEdit) And TRichEdit(Form.Components[i]).Visible Then
     Exit(TRichEdit(Form.Components[i]));
  End;

 Function CaptureHelpWindow(Form : TCustomForm) : Vcl.Graphics.TBitmap;
  Var
   Rich   : TRichEdit;
   Range  : TFormatRange;
   Origin : TPoint;
   Saved  : Integer;
   DpiX   : Integer;
   DpiY   : Integer;
   x      : Integer;
   y      : Integer;
   Ink    : Integer;
   Last   : NativeInt;
   c      : COLORREF;
  Begin
   Result := Form.GetFormImage;
   Try
    Rich := HelpReportText(Form);
    If Rich = Nil Then
     Exit;
    If Rich.GetTextLen = 0 Then
     Raise Exception.Create('Cannot capture an empty report');
    Origin := Form.ScreenToClient(Rich.ClientToScreen(Point(0, 0)));
    Saved  := SaveDC(Result.Canvas.Handle);
    Try
     IntersectClipRect(Result.Canvas.Handle, Origin.x, Origin.y, Origin.x + Rich.ClientWidth, Origin.y + Rich.ClientHeight);
     SetViewportOrgEx(Result.Canvas.Handle, Origin.x, Origin.y, Nil);
     Result.Canvas.Brush.Color := Rich.Color;
     Result.Canvas.FillRect(Rect(0, 0, Rich.ClientWidth, Rich.ClientHeight));
     DpiX := GetDeviceCaps(Result.Canvas.Handle, LOGPIXELSX);
     DpiY := GetDeviceCaps(Result.Canvas.Handle, LOGPIXELSY);
     FillChar(Range, SizeOf(Range), 0);
     Range.hdc        := Result.Canvas.Handle;
     Range.hdcTarget  := Result.Canvas.Handle;
     Range.rc         := Rect(0, 0, MulDiv(Rich.ClientWidth, 1440, DpiX), MulDiv(Rich.ClientHeight, 1440, DpiY));
     Range.rcPage     := Range.rc;
     Range.chrg.cpMin := Rich.Perform(EM_LINEINDEX, Rich.Perform(EM_GETFIRSTVISIBLELINE, 0, 0), 0);
     Range.chrg.cpMax := -1;
     Last             := Rich.Perform(EM_FORMATRANGE, 1, LPARAM(@Range));
     Rich.Perform(EM_FORMATRANGE, 0, 0);
     If Last <= Range.chrg.cpMin Then
      Raise Exception.Create('RichEdit did not render report text');
    Finally
     RestoreDC(Result.Canvas.Handle, Saved);
    End;
    Ink    := 0;
    For y  := Origin.y + 8 To Origin.y + Rich.ClientHeight - 9 Do
     For x := Origin.x + 8 To Origin.x + Rich.ClientWidth - 9 Do
      Begin
       c := ColorToRGB(Result.Canvas.Pixels[x, y]);
       If Integer(GetRValue(c)) + GetGValue(c) + GetBValue(c) < 450 Then
        Inc(Ink);
      End;
    If Ink < 100 Then
     Raise Exception.Create('Report screenshot has no visible text');
   Except
    Result.Free;
    Raise;
   End;
  End;

End.
