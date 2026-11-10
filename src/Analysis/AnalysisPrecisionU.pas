{$StackFrames On}
Unit AnalysisPrecisionU;

Interface

 Uses
  System.JSON;

 Const
  AnalysisDeadband = 0.0015;

 Function RoundAnalysisJSON(Value : TJSONValue) : TJSONValue;
 Function AnalysisValuesEqual(a, b : TJSONValue) : Boolean;

Implementation

 Uses
  System.SysUtils, System.Math, System.Generics.Collections;

 Function IntegerLiteral(Const s : String) : Boolean;
  Var
   n : Int64;
  Begin
   Result := TryStrToInt64(s, n);
  End;

 Function RoundAnalysisJSON(Value : TJSONValue) : TJSONValue;
  Var
   p  : TJSONPair;
   v  : TJSONValue;
   o  : TJSONObject;
   a  : TJSONArray;
   n  : Double;
   FS : TFormatSettings;
   s  : String;
  Begin
   If Value Is TJSONObject Then
    Begin
     o      := TJSONObject.Create;
     Result := o;
     Try
      For p In TJSONObject(Value) Do
       o.AddPair(p.JsonString.Value, RoundAnalysisJSON(p.JsonValue));
     Except
      o.Free;
      Raise;
     End;
    End
   Else If Value Is TJSONArray Then
    Begin
     a      := TJSONArray.Create;
     Result := a;
     Try
      For v In TJSONArray(Value) Do
       a.AddElement(RoundAnalysisJSON(v));
     Except
      a.Free;
      Raise;
     End;
    End
   Else If Value Is TJSONNumber Then
    Begin
     If IntegerLiteral(Value.Value) Then
      Exit(TJSONNumber.Create(Value.Value));
     n := TJSONNumber(Value).AsDouble;
     If IsNan(n) Or IsInfinite(n) Then
      Exit(TJSONNull.Create);
     FS                  := TFormatSettings.Create;
     FS.DecimalSeparator := '.';
     s                   := FormatFloat('0.###', n, FS);
     If s = '-0' Then
      s     := '0';
     Result := TJSONNumber.Create(s);
    End
   Else
    Result := TJSONObject.ParseJSONValue(Value.ToJSON);
  End;

 Function AnalysisValuesEqual(a, b : TJSONValue) : Boolean;
  Var
   i : Integer;
   p : TJSONPair;
   n : Double;
   m : Double;
  Begin
   If (a = Nil) Or (b = Nil) Then
    Exit(a = b);
   If (a Is TJSONNumber) And (b Is TJSONNumber) Then
    Begin
     If IntegerLiteral(a.Value) And IntegerLiteral(b.Value) Then
      Exit(a.Value = b.Value);
     n := TJSONNumber(a).AsDouble;
     m := TJSONNumber(b).AsDouble;
     Exit(Not IsNan(n) And Not IsNan(m) And Not IsInfinite(n) And Not IsInfinite(m) And (Abs(n - m) <= AnalysisDeadband + 1E-12));
    End;
   If (a Is TJSONArray) And (b Is TJSONArray) Then
    Begin
     If TJSONArray(a).Count <> TJSONArray(b).Count Then
      Exit(False);
     For i := 0 To TJSONArray(a).Count - 1 Do
      If Not AnalysisValuesEqual(TJSONArray(a).Items[i], TJSONArray(b).Items[i]) Then
       Exit(False);
     Exit(True);
    End;
   If (a Is TJSONObject) And (b Is TJSONObject) Then
    Begin
     If TJSONObject(a).Count <> TJSONObject(b).Count Then
      Exit(False);
     For p In TJSONObject(a) Do
      If Not AnalysisValuesEqual(p.JsonValue, TJSONObject(b).GetValue(p.JsonString.Value)) Then
       Exit(False);
     Exit(True);
    End;
   Result := a.ToJSON = b.ToJSON;
  End;

End.
