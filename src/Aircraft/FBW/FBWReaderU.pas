{$StackFrames On}
Unit FBWReaderU;

Interface

 Uses
  System.SysUtils, AircraftLVarReaderU;

 Type
  TFBWReader = Class(TAircraftLVarReader)
   Public
    Constructor Create(Const DLL : String = '');
  End;

Implementation

 Uses
  FBWCatalogU;

 Constructor TFBWReader.Create(Const DLL : String);
  Var
   Names : TArray<String>;
   i     : Integer;
  Begin
   SetLength(Names, FBWFieldCount);
   For i     := 0 To FBWFieldCount - 1 Do
    Names[i] := FBWFields[i].Name;
   Inherited Create(Names, 'MSFS FDR FBW A32NX L-vars (read only)', DLL);
  End;

End.
