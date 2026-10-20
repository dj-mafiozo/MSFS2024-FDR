Unit GSXVarsU;

Interface

 Uses
  System.JSON, AircraftLVarReaderU;

 Const
  GSXVarCount                                       = 16;
  GSXNames : Array [0 .. GSXVarCount - 1] Of String =
   (
    'FSDT_GSX_BOARDING_STATE',
    'FSDT_GSX_DEBOARDING_STATE',
    'FSDT_GSX_CATERING_STATE',
    'FSDT_GSX_REFUELING_STATE',
    'FSDT_GSX_DEPARTURE_STATE',
    'FSDT_GSX_DEICE_STATE',
    'FSDT_VAR_Frozen',
    'FSDT_GSX_NUMPASSENGERS_BOARDING',
    'FSDT_GSX_NUMPASSENGERS_DEBOARDING',
    'FSDT_GSX_NUMPASSENGERS_BOARDING_TOTAL',
    'FSDT_GSX_NUMPASSENGERS_DEBOARDING_TOTAL',
    'FSDT_GSX_BOARDING_CARGO',
    'FSDT_GSX_DEBOARDING_CARGO',
    'FSDT_GSX_BOARDING_CARGO_PERCENT',
    'FSDT_GSX_DEBOARDING_CARGO_PERCENT',
    'FSDT_GSX_DEICING_TYPE'
   );

 Type

  TGSXVars = Class
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

 Constructor TGSXVars.Create(Const DLL : String);
  Var
   Names : TArray<String>;
   i     : Integer;
  Begin
   Inherited Create;
   SetLength(Names, GSXVarCount);
   For i     := 0 To High(GSXNames) Do
    Names[i] := GSXNames[i];
   fReader   := TAircraftLVarReader.Create(Names, 'MSFS FDR GSX Pro L-vars', DLL, 1);
  End;

 Destructor TGSXVars.Destroy;
  Begin
   fReader.Free;
   Inherited;
  End;

 Procedure TGSXVars.Close;
  Begin
   fReader.Close;
  End;

 Procedure TGSXVars.Tick;
  Begin
   fReader.Tick;
  End;

 Function TGSXVars.Snapshot : TJSONObject;
  Var
   Values : TArray<Double>;
   Age    : UInt64;
   i      : Integer;
   n      : Integer;
   Fields : TJSONObject;
  Begin
   n      := fReader.Snapshot(Values, Age, 3000);
   Result := TJSONObject.Create;
   Result.AddPair('source', 'GSX Pro SDK L-vars via SimConnect');
   If n = GSXVarCount Then
    Result.AddPair('status', 'received_not_verified')
   Else If n > 0 Then
    Result.AddPair('status', 'partial')
   Else
    Result.AddPair('status', 'unavailable');
   Fields := TJSONObject.Create;
   Result.AddPair('fields', Fields);
   For i := 0 To High(GSXNames) Do
    If IsNan(Values[i]) Or IsInfinite(Values[i]) Then
     Fields.AddPair(GSXNames[i], TJSONNull.Create)
    Else
     Fields.AddPair(GSXNames[i], TJSONNumber.Create(Values[i]));
  End;

End.
