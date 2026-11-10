Unit AirbusMessagesU;

// FBW message catalog: Copyright (c) 2022-2026 FlyByWire Simulations, GPL-3.0.

Interface

 Uses
  AirbusDataU, Vcl.Graphics;

 Function AirbusMessage(Code : Double; Var PreviousGroup : String) : String;
 Function AirbusMessageLines(Data : TAirbusData; Right : Boolean) : String;
 Procedure DrawAirbusText(Canvas : TCanvas; x, y, FontSize, LineHeight : Integer; Const Message : String; FlashOn : Boolean);

Implementation

 Uses
  System.SysUtils, System.Math, InstrumentDataU;

 Function AirbusMessage(Code : Double; Var PreviousGroup : String) : String;
  Var
   Group  : String;
   Prefix : String;
   s      : String;
   n      : Integer;
   i      : Integer;
   Esc    : Boolean;
  Begin
   Result := '';
   Group  := '';
   Prefix := '';
   If Not InstrumentValid(Code) Then
    Begin
     PreviousGroup := '';
     Exit;
    End;
   If (Code < 0) Or (Code > 999999999) Or (Code <> Trunc(Code)) Then
    Begin
     PreviousGroup := '';
     Exit;
    End;
   n := Trunc(Code);
   Case n Of
    {$I AirbusMessageCatalog.inc}
   Else
     Begin
      PreviousGroup := '';
      If n <> 0 Then
       Result := #27'<4mMSG ' + Format('%.9d', [n]);
      Exit;
     End;
   End;
   If Group <> '' Then
    Begin
     If PreviousGroup = Group Then
      Begin
       s     := '';
       Esc   := False;
       For i := 1 To Length(Prefix) Do
        Begin
         If Prefix[i] = #27 Then
          Esc := True
         Else If Esc Then
          Begin
           If Prefix[i] = 'm' Then
            Esc := False;
          End
         Else
          s := s + ' ';
        End;
       // Retain the group color, omit its repeated heading.
       Result := Copy(Prefix, 1, 4) + s + Result;
      End
     Else
      Result       := Prefix + Result;
     PreviousGroup := Group;
    End;
  End;

 Function AirbusMessageLines(Data : TAirbusData; Right : Boolean) : String;
  Var
   i         : Integer;
   Prefix    : String;
   Group     : String;
   s         : String;
   v         : Double;
   Available : Boolean;
  Begin
   Result    := '';
   Group     := '';
   Available := False;
   Prefix    := 'A32NX_Ewd_LOWER_LEFT_LINE_';
   If Right Then
    Prefix := 'A32NX_Ewd_LOWER_RIGHT_LINE_';
   For i   := 1 To 7 Do
    Begin
     v         := Data.FBW(Prefix + IntToStr(i));
     Available := Available Or InstrumentValid(v);
     s         := AirbusMessage(v, Group);
     If i > 1 Then
      Result := Result + #13;
     Result  := Result + s;
    End;
   If Not Available Then
    Result := #27'<7mTEXT --';
  End;

 Procedure DrawAirbusText(Canvas : TCanvas; x, y, FontSize, LineHeight : Integer; Const Message : String; FlashOn : Boolean);
  Var
   i          : Integer;
   j          : Integer;
   PX         : Integer;
   PY         : Integer;
   w          : Integer;
   s          : String;
   Cmd        : String;
   Col        : TColor;
   Underlined : Boolean;
   Framed     : Boolean;
   Flashing   : Boolean;

   Procedure Flush;
    Begin
     If s = '' Then
      Exit;
     Canvas.Font.Color  := Col;
     Canvas.Brush.Style := bsClear;
     w                  := Canvas.TextWidth(s);
     If Not Flashing Or FlashOn Then
      Begin
       Canvas.TextOut(PX, PY, s);
       Canvas.Pen.Color := Col;
       Canvas.Pen.Width := 1;
       If Underlined Then
        Begin
         Canvas.MoveTo(PX, PY + Canvas.TextHeight(s));
         Canvas.LineTo(PX + w, PY + Canvas.TextHeight(s));
        End;
       If Framed Then
        Canvas.Rectangle(PX - 1, PY - 1, PX + w + 1, PY + LineHeight);
      End;
     Inc(PX, w);
     s := '';
    End;

  Begin
   Canvas.Font.Name  := 'Consolas';
   Canvas.Font.Size  := FontSize;
   Canvas.Font.Style := [];
   Col               := clWhite;
   Underlined        := False;
   Framed            := False;
   Flashing          := False;
   PX                := x;
   PY                := y;
   i                 := 1;
   s                 := '';
   While i <= Length(Message) Do
    Begin
     If Message[i] = #13 Then
      Begin
       Flush;
       PX := x;
       Inc(PY, LineHeight);
      End
     Else If Message[i] = #27 Then
      Begin
       Flush;
       j := i + 1;
       While (j <= Length(Message)) And (Message[j] <> 'm') Do
        Inc(j);
       Cmd := Copy(Message, i + 1, j - i - 1);
       i   := j;
       If Cmd = '' Then
        Begin
         Underlined := False;
         Framed     := False;
         Flashing   := False;
        End
       Else If Cmd = '4' Then
        Underlined := True
       Else If Cmd = ')' Then
        Flashing := True
       Else If Cmd = '''' Then
        Framed := True
       Else If Cmd = '<1' Then
        Col := clYellow
       Else If Cmd = '<2' Then
        Col := clRed
       Else If Cmd = '<3' Then
        Col := clLime
       Else If Cmd = '<4' Then
        Col := $0000BFFF
       Else If Cmd = '<5' Then
        Col := clAqua
       Else If Cmd = '<6' Then
        Col := clFuchsia
       Else If Cmd = '<7' Then
        Col := clWhite;
      End
     Else
      s := s + Message[i];
     Inc(i);
    End;
   Flush;
   Canvas.Brush.Style := bsSolid;
  End;

End.
