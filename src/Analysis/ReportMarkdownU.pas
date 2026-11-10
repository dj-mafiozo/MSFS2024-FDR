{$StackFrames On}
Unit ReportMarkdownU;

Interface

 Function ReportHTML(Const Markdown : String) : String;

Implementation

 Uses
  System.SysUtils, System.Classes, System.StrUtils;

 Function Escape(Const s : String) : String;
  Begin
   Result := s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;');
  End;

 Function RenderInline(Const s : String) : String;
  Var
   i     : Integer;
   j     : Integer;
   Token : String;
   Tag   : String;
  Begin
   Result := '';
   i      := 1;
   While i <= Length(s) Do
    Begin
     Token := '';
     Tag   := '';
     If Copy(s, i, 2) = '**' Then
      Begin
       Token := '**';
       Tag   := 'strong';
      End
     Else If s[i] = '`' Then
      Begin
       Token := '`';
       Tag   := 'code';
      End
     Else If s[i] = '*' Then
      Begin
       Token := '*';
       Tag   := 'em';
      End;
     If Token <> '' Then
      Begin
       j := PosEx(Token, s, i + Length(Token));
       If j > i + Length(Token) Then
        Begin
         Result := Result + '<' + Tag + '>' + Escape(Copy(s, i + Length(Token), j - i - Length(Token))) + '</' + Tag + '>';
         i      := j + Length(Token);
         Continue;
        End;
      End;
     Result := Result + Escape(s[i]);
     Inc(i);
    End;
  End;

 Function ReportHTML(Const Markdown : String) : String;
  Var
   Lines   : TStringList;
   Line    : String;
   Body    : String;
   ListTag : String;
   NewList : String;
   Text    : String;
   Level   : Integer;
   i       : Integer;
   j       : Integer;
   Fence   : Boolean;
  Begin
   Lines := TStringList.Create;
   Try
    Lines.Text := Markdown;
    Body       := '';
    ListTag    := '';
    Fence      := False;
    For i      := 0 To Lines.Count - 1 Do
     Begin
      Line := Trim(Lines[i]);
      If StartsStr('```', Line) Then
       Begin
        If ListTag <> '' Then
         Begin
          Body    := Body + '</' + ListTag + '>';
          ListTag := '';
         End;
        If Fence Then
         Body := Body + '</code></pre>'
        Else
         Body := Body + '<pre><code>';
        Fence := Not Fence;
        Continue;
       End;
      If Fence Then
       Begin
        Body := Body + Escape(Lines[i]) + #10;
        Continue;
       End;
      NewList := '';
      Text    := Line;
      If StartsStr('- ', Line) Or StartsStr('* ', Line) Then
       Begin
        NewList := 'ul';
        Text    := Copy(Line, 3, MaxInt);
       End
      Else
       Begin
        j := 1;
        While (j <= Length(Line)) And CharInSet(Line[j], ['0'..'9']) Do
         Inc(j);
        If (j > 1) And (Copy(Line, j, 2) = '. ') Then
         Begin
          NewList := 'ol';
          Text    := Copy(Line, j + 2, MaxInt);
         End;
       End;
      If NewList <> ListTag Then
       Begin
        If ListTag <> '' Then
         Body   := Body + '</' + ListTag + '>';
        ListTag := NewList;
        If ListTag <> '' Then
         Body := Body + '<' + ListTag + '>';
       End;
      If NewList <> '' Then
       Begin
        Body := Body + '<li>' + RenderInline(Text) + '</li>';
        Continue;
       End;
      If Line = '' Then
       Continue;
      Level := 0;
      While (Level < Length(Line)) And (Level < 6) And (Line[Level + 1] = '#') Do
       Inc(Level);
      If (Level > 0) And (Copy(Line, Level + 1, 1) = ' ') Then
       Body := Body + '<h' + IntToStr(Level) + '>' + RenderInline(Copy(Line, Level + 2, MaxInt)) + '</h' + IntToStr(Level) + '>'
      Else If StartsStr('> ', Line) Then
       Body := Body + '<blockquote>' + RenderInline(Copy(Line, 3, MaxInt)) + '</blockquote>'
      Else If Line = '---' Then
       Body := Body + '<hr>'
      Else
       Body := Body + '<p>' + RenderInline(Line) + '</p>';
     End;
    If Fence Then
     Body := Body + '</code></pre>';
    If ListTag <> '' Then
     Body  := Body + '</' + ListTag + '>';
    Result := '<!doctype html><html lang="pl"><head><meta charset="utf-8">' + '<meta http-equiv="Content-Security-Policy" content="default-src ' + #39 + 'none' + #39 + '; style-src ' + #39 + 'unsafe-inline' + #39 + '">' + '<style>body{font:17px/1.65 Segoe UI,sans-serif;color:#203044;background:#f5f7fa;margin:0}' + 'main{max-width:900px;margin:24px auto;padding:24px 36px;background:white;border-radius:10px}' + 'h1,h2,h3{line-height:1.3;color:#163e61}li{margin:.5em 0}p{margin:.8em 0}' +
    'code{background:#edf1f5;padding:2px 5px;border-radius:4px}pre{white-space:pre-wrap;overflow-wrap:anywhere}' + 'blockquote{border-left:4px solid #7196b5;padding-left:16px;color:#506070}main{overflow-wrap:anywhere}</style></head><body><main>' + Body + '</main></body></html>';
   Finally
    Lines.Free;
   End;
  End;

End.
