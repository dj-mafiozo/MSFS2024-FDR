Unit AirlinerVarsU;

Interface

 Uses
  System.JSON, AircraftLVarReaderU, AirlinerCatalogU;

 Type
  TAirlinerVars = Class
   Private
    fReader : TAircraftLVarReader;
   Public
    Constructor Create(Const DLL : String = '');
    Destructor Destroy; Override;
    Procedure Close;
    Procedure Tick;
    Function Snapshot : TJSONObject;
  End;

Implementation

 Uses
  System.SysUtils, System.Math;

 Constructor TAirlinerVars.Create(Const DLL : String);
  Var
   Names : TArray<String>;
   i     : Integer;
  Begin
   Inherited Create;
   SetLength(Names, AirlinerVarCount);
   For i     := 0 To High(AirlinerNames) Do
    Names[i] := AirlinerNames[i];
   fReader   := TAircraftLVarReader.Create(Names, 'MSFS FDR common AIRLINER L-vars', DLL, 1);
  End;

 Destructor TAirlinerVars.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Procedure TAirlinerVars.Close;
  Begin
   fReader.Close;
  End;

 Procedure TAirlinerVars.Tick;
  Begin
   fReader.Tick;
  End;

 Function TAirlinerVars.Snapshot : TJSONObject;
  Const
   Keys : Array [0 .. 2] Of String = ('v1_kt', 'vr_kt', 'v2_kt');
  Var
   V          : TArray<Double>;
   Age        : UInt64;
   i          : Integer;
   N          : Integer;
   Fields     : TJSONObject;
   References : TJSONObject;
  Begin
   N      := fReader.Snapshot(V, Age, 3000);
   Result := TJSONObject.Create;
   Result.AddPair('source', 'SimConnect L:*AIRLINER*');
   If N = AirlinerVarCount Then
    Result.AddPair('status', 'received_not_verified')
   Else If N > 0 Then
    Result.AddPair('status', 'partial')
   Else
    Result.AddPair('status', 'unavailable');
   Fields := TJSONObject.Create;
   Result.AddPair('fields', Fields);
   References := TJSONObject.Create;
   Result.AddPair('performance_reference', References);
   For i := 0 To High(AirlinerNames) Do
    Begin
     If IsNan(V[i]) Or IsInfinite(V[i]) Then
      Fields.AddPair(AirlinerNames[i], TJSONNull.Create)
     Else
      Fields.AddPair(AirlinerNames[i], TJSONNumber.Create(V[i]));
     If i < 3 Then
      Begin
       If Not IsNan(V[i]) And Not IsInfinite(V[i]) And (V[i] > 0) And (V[i] < 400) Then
        References.AddPair(Keys[i], TJSONNumber.Create(V[i]));
      End;
    End;
   Result.AddPair('semantics', 'Optional shared instrument L-vars. A transported zero does not prove the variable exists or that the aircraft publishes current data. Prefer aircraft-specific SDK/FMS references.');
  End;

End.
