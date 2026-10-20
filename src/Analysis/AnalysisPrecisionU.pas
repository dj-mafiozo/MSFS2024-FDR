Unit AnalysisPrecisionU;

Interface

 Uses
  System.JSON;

 Const
  AnalysisDeadband = 0.0015;

 Function RoundAnalysisJSON(Value : TJSONValue) : TJSONValue;
 Function AnalysisValuesEqual(A, B : TJSONValue) : Boolean;

Implementation

 Uses
  System.SysUtils, System.Math, System.Generics.Collections;

 Function IntegerLiteral(Const S : String) : Boolean;
  Var
   N : Int64;
  Begin
   Result := TryStrToInt64(S, N);
  End;

 Function RoundAnalysisJSON(Value : TJSONValue) : TJSONValue;
  Var
   P  : TJSONPair;
   V  : TJSONValue;
   O  : TJSONObject;
   A  : TJSONArray;
   N  : Double;
   FS : TFormatSettings;
   S  : String;
  Begin
   If Value Is TJSONObject Then
    Begin
     O      := TJSONObject.Create;
     Result := O;
     Try
      For P In TJSONObject(Value) Do
       O.AddPair(P.JsonString.Value, RoundAnalysisJSON(P.JsonValue));
     Except
      O.Free;
      Raise;
     End;
    End
   Else If Value Is TJSONArray Then
    Begin
     A      := TJSONArray.Create;
     Result := A;
     Try
      For V In TJSONArray(Value) Do
       A.AddElement(RoundAnalysisJSON(V));
     Except
      A.Free;
      Raise;
     End;
    End
   Else If Value Is TJSONNumber Then
    Begin
     If IntegerLiteral(Value.Value) Then
      Exit(TJSONNumber.Create(Value.Value));
     N := TJSONNumber(Value).AsDouble;
     If IsNan(N) Or IsInfinite(N) Then
      Exit(TJSONNull.Create);
     FS                  := TFormatSettings.Create;
     FS.DecimalSeparator := '.';
     S                   := FormatFloat('0.###', N, FS);
     If S = '-0' Then
      S     := '0';
     Result := TJSONNumber.Create(S);
    End
   Else
    Result := TJSONObject.ParseJSONValue(Value.ToJSON);
  End;

 Function AnalysisValuesEqual(A, B : TJSONValue) : Boolean;
  Var
   i : Integer;
   P : TJSONPair;
   N : Double;
   M : Double;
  Begin
   If (A = Nil) Or (B = Nil) Then
    Exit(A = B);
   If (A Is TJSONNumber) And (B Is TJSONNumber) Then
    Begin
     If IntegerLiteral(A.Value) And IntegerLiteral(B.Value) Then
      Exit(A.Value = B.Value);
     N := TJSONNumber(A).AsDouble;
     M := TJSONNumber(B).AsDouble;
     Exit(Not IsNan(N) And Not IsNan(M) And Not IsInfinite(N) And Not IsInfinite(M) And (Abs(N - M) <= AnalysisDeadband + 1E-12));
    End;
   If (A Is TJSONArray) And (B Is TJSONArray) Then
    Begin
     If TJSONArray(A).Count <> TJSONArray(B).Count Then
      Exit(False);
     For i := 0 To TJSONArray(A).Count - 1 Do
      If Not AnalysisValuesEqual(TJSONArray(A).Items[i], TJSONArray(B).Items[i]) Then
       Exit(False);
     Exit(True);
    End;
   If (A Is TJSONObject) And (B Is TJSONObject) Then
    Begin
     If TJSONObject(A).Count <> TJSONObject(B).Count Then
      Exit(False);
     For P In TJSONObject(A) Do
      If Not AnalysisValuesEqual(P.JsonValue, TJSONObject(B).GetValue(P.JsonString.Value)) Then
       Exit(False);
     Exit(True);
    End;
   Result := A.ToJSON = B.ToJSON;
  End;

End.
