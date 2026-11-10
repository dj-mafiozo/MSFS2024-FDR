{$StackFrames On}
Unit MarkdownRichEditU;

Interface

 Uses
  Vcl.ComCtrls;

 Procedure RenderMarkdown(Rich : TRichEdit; Const Markdown : String);

Implementation

 Uses
  System.SysUtils, System.Classes, Vcl.Graphics;

 Procedure RenderMarkdown(Rich : TRichEdit; Const Markdown : String);
  Var
   Lines   : TStringList;
   Line    : String;
   Part    : String;
   i       : Integer;
   j       : Integer;
   Finish  : Integer;
   Bold    : Boolean;
   Italic  : Boolean;
   Code    : Boolean;
   Heading : Boolean;
   Quote   : Boolean;
   Styles  : TFontStyles;

   Procedure Append(Const Text : String);
    Begin
     Rich.SelStart  := Rich.GetTextLen;
     Rich.SelLength := 0;
     Styles         := [];
     If Bold Or Heading Then
      Include(Styles, fsBold);
     If Italic Then
      Include(Styles, fsItalic);
     Rich.SelAttributes.Style := Styles;
     Rich.SelAttributes.Size  := 11 + Ord(Heading) * 2;
     If Code Then
      Rich.SelAttributes.Name := 'Consolas'
     Else
      Rich.SelAttributes.Name := Rich.Font.Name;
     If Quote Then
      Rich.SelAttributes.Color := clGrayText
     Else
      Rich.SelAttributes.Color := clWindowText;
     Rich.SelText              := Text;
    End;

  Begin
   Lines := TStringList.Create;
   Rich.Lines.BeginUpdate;
   Try
    Rich.Clear;
    Lines.Text := Markdown;
    For i      := 0 To Lines.Count - 1 Do
     Begin
      Line    := Lines[i];
      Heading := (Line <> '') And (Line[1] = '#');
      If Heading Then
       Begin
        While (Line <> '') And (Line[1] = '#') Do
         Delete(Line, 1, 1);
        Line := TrimLeft(Line);
       End;
      Quote := Copy(Line, 1, 2) = '> ';
      If Quote Then
       Line := Copy(Line, 3, MaxInt);
      If Copy(Line, 1, 2) = '- ' Then
       Line := '• ' + Copy(Line, 3, MaxInt);
      If Line = '---' Then
       Line  := '────────────────────────';
      Bold   := False;
      Italic := False;
      Code   := False;
      j      := 1;
      While j <= Length(Line) Do
       Begin
        If Line[j] = '`' Then
         Begin
          Code := Not Code;
          Inc(j);
          Continue;
         End;
        If Not Code And (Copy(Line, j, 2) = '**') Then
         Begin
          Bold := Not Bold;
          Inc(j, 2);
          Continue;
         End;
        If Not Code And (Line[j] = '*') Then
         Begin
          Italic := Not Italic;
          Inc(j);
          Continue;
         End;
        If Not Code And (Line[j] = '[') Then
         Begin
          Finish := Pos('](', Copy(Line, j, MaxInt));
          If Finish > 0 Then
           Begin
            Part   := Copy(Line, j + 1, Finish - 2);
            Finish := j + Finish + 1;
            While (Finish <= Length(Line)) And (Line[Finish] <> ')') Do
             Inc(Finish);
            If Finish <= Length(Line) Then
             Begin
              Append(Part);
              j := Finish + 1;
              Continue;
             End;
           End;
         End;
        Append(Line[j]);
        Inc(j);
       End;
      Append(sLineBreak);
     End;
    Rich.SelStart := 0;
   Finally
    Rich.Lines.EndUpdate;
    Lines.Free;
   End;
  End;

End.
