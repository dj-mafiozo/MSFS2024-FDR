{$StackFrames On}
Unit FenixReaderU;

Interface

 Uses
  System.SysUtils, AircraftLVarReaderU;

 Type
  TFenixReader = Class(TAircraftLVarReader)
   Public
    Constructor Create(Const DLL : String = '');
  End;

Implementation

 Uses
  FenixCatalogU;

 Constructor TFenixReader.Create(Const DLL : String);
  Var
   Names : TArray<String>;
   i     : Integer;
  Begin
   SetLength(Names, FenixFieldCount);
   For i     := 0 To FenixFieldCount - 1 Do
    Names[i] := FenixFields[i].Name;
   Inherited Create(Names, 'MSFS FDR Fenix L-vars (read only)', DLL);
  End;

End.
