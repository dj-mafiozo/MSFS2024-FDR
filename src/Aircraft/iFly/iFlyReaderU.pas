{$StackFrames On}
Unit iFlyReaderU;

Interface

 Uses
  Winapi.Windows, System.SysUtils, FDRTypesU, IFlySDKCatalogU;

 Type
  TiFlyReader = Class
   Private
    fMap       : THandle;
    fMutex     : THandle;
    fView      : Pointer;
    fMapName   : String;
    fMutexName : String;
   Public
    Constructor Create(Const MapName : String = 'iFly737MAX_SDK_FileMappingObject'; Const MutexName : String = 'iFly737MAX_SDK_Mutex');
    Destructor Destroy; Override;
    Procedure Close;
    Function Read(Out Values : TReadings; Out Stamp : TCaptureTime) : Boolean;
  End;

Implementation

 Constructor TiFlyReader.Create(Const MapName, MutexName : String);
  Begin
   Inherited Create;
   fMapName   := MapName;
   fMutexName := MutexName;
  End;

 Procedure TiFlyReader.Close;
  Begin
   If fView <> Nil Then
    UnmapViewOfFile(fView);
   fView := Nil;
   If fMap <> 0 Then
    CloseHandle(fMap);
   fMap := 0;
   If fMutex <> 0 Then
    CloseHandle(fMutex);
   fMutex := 0;
  End;

 Destructor TiFlyReader.Destroy;
  Begin
   Close;
   Inherited;
  End;

 Function TiFlyReader.Read(Out Values : TReadings; Out Stamp : TCaptureTime) : Boolean;
  Var
   Buffer : Array [0 .. SDKSize - 1] Of Byte;
   Wait   : DWORD;
   i      : Integer;
   State  : Integer;
  Begin
   Result := False;
   SetLength(Values, 0);
   If fView = Nil Then
    Begin
     fMutex := OpenMutex(SYNCHRONIZE Or MUTEX_MODIFY_STATE, False, PChar(fMutexName));
     fMap   := OpenFileMapping(FILE_MAP_READ, False, PChar(fMapName));
     If (fMutex = 0) Or (fMap = 0) Then
      Begin
       Close;
       Exit;
      End;
     fView := MapViewOfFile(fMap, FILE_MAP_READ, 0, 0, SDKSize);
     If fView = Nil Then
      Begin
       Close;
       Exit;
      End;
    End;
   Wait := WaitForSingleObject(fMutex, 5);
   If Wait = WAIT_ABANDONED Then
    Begin
     ReleaseMutex(fMutex);
     Close;
     Exit;
    End;
   If Wait <> WAIT_OBJECT_0 Then
    Exit;
   Try
    Move(fView^, Buffer, SDKSize);
    Stamp := CaptureTime;
   Finally
    ReleaseMutex(fMutex);
   End;
   Move(Buffer[0], State, 4);
   If State <> 1 Then
    Begin
     Close;
     Exit;
    End;
   SetLength(Values, SDKFieldCount);
   For i      := 0 To SDKFieldCount - 1 Do
    Values[i] := MakeReading(SDKFields[i].Name, 'iFlySDK', SDKFields[i].Kind, '', @Buffer[SDKFields[i].Offset], SDKFields[i].Size);
   Result     := True;
  End;

End.
