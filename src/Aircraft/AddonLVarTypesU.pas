{$StackFrames On}
Unit AddonLVarTypesU;

Interface

 Type
  TAddonLVarField = Record
   Provider     : String;
   Name         : String;
   SourceUnits  : String;
   DisplayValue : String;
  End;

  TAddonLVarProfile = Record
   Provider : String;
   Title    : String;
   First    : Integer;
   Count    : Integer;
  End;

  TAddonTitle = Record
   Profile : Integer;
   Title   : String;
  End;

Implementation

End.
