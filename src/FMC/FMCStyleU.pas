{$StackFrames On}
Unit FMCStyleU;

Interface

 Uses
  System.JSON, Vcl.Graphics;

 Type
  TFMCCellStyle = Record
   Foreground : TColor;
   Background : TColor;
   Small      : Boolean;
  End;

  TFMCStyle = Class
   Private
    fJSON     : TJSONValue;
    fRows     : TJSONArray;
    fEncoding : String;
    fOverlay  : String;
   Public
    Constructor Create(Const JSON : String);
    Destructor Destroy; Override;
    Function Cell(Row, Column : Integer) : TFMCCellStyle;
    Property Overlay : String Read fOverlay;
  End;

Implementation

 Uses
  System.SysUtils, Winapi.Windows;

 Constructor TFMCStyle.Create(Const JSON : String);
  Var
   v : TJSONValue;
  Begin
   Inherited Create;
   fJSON := TJSONObject.ParseJSONValue(JSON);
   If fJSON Is TJSONObject Then
    Begin
     v := TJSONObject(fJSON).GetValue('encoding');
     If v Is TJSONString Then
      fEncoding := v.Value;
     v          := TJSONObject(fJSON).GetValue('rows');
     If v Is TJSONArray Then
      fRows := TJSONArray(v);
     v      := TJSONObject(fJSON).GetValue('overlay');
     If v Is TJSONString Then
      fOverlay := v.Value;
    End;
  End;

 Destructor TFMCStyle.Destroy;
  Begin
   fJSON.Free;
   Inherited;
  End;

 Function TFMCStyle.Cell(Row, Column : Integer) : TFMCCellStyle;
  Var
   Codes : String;
   Color : Integer;
   Flags : Integer;
   Small : Integer;
   p     : Integer;
  Begin
   Result.Foreground := clWhite;
   Result.Background := clBlack;
   Result.Small      := False;
   If (fRows = Nil) Or (Row < 0) Or (Row >= fRows.Count) Or (Column < 0) Or (Column > 23) Or Not(fRows.Items[Row] Is TJSONString) Then
    Exit;
   Codes := fRows.Items[Row].Value;
   If fEncoding = 'rgb-flags-v1' Then
    Begin
     p := Column * 8 + 1;
     If Length(Codes) < p + 7 Then
      Exit;
     If Not TryStrToInt('$' + Copy(Codes, p, 6), Color) Then
      Exit;
     Flags := StrToIntDef('$' + Copy(Codes, p + 6, 2), 0);
     If (Flags And 4) <> 0 Then
      Color            := (((Color Shr 16) And 255) Div 2 Shl 16) Or (((Color Shr 8) And 255) Div 2 Shl 8) Or ((Color And 255) Div 2);
     Result.Foreground := RGB((Color Shr 16) And 255, (Color Shr 8) And 255, Color And 255);
     Result.Small      := (Flags And 1) <> 0;
     If (Flags And 2) <> 0 Then
      Begin
       Result.Background := Result.Foreground;
       Result.Foreground := clBlack;
      End;
    End
   Else
    Begin
     p := Column * 2 + 1;
     If Length(Codes) < p + 1 Then
      Exit;
     Color        := StrToIntDef('$' + Codes[p], 15);
     Small        := StrToIntDef('$' + Codes[p + 1], 15);
     Result.Small := Small = 1;
     Case Color Of
      1    : Result.Foreground := clLime;
      2    : Result.Foreground := clAqua;
      3, 8 : Result.Foreground := clFuchsia;
      4, 7 : Result.Background := $666666;
     End;
    End;
  End;

End.
