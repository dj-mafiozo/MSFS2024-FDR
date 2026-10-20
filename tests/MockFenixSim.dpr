library MockFenixSim;
uses Winapi.Windows,System.SysUtils,System.Math,FenixCatalogU,FBWCatalogU,AirlinerVarsU, AirlinerCatalogU, GSXVarsU;
var IsAirliner,IsFBW,IsGSX:Boolean;Mode,Adds,Requests,Opens,Closes,Writes,Errors,Queue:Integer;LastSend:DWORD;
 Counts:array[0..FenixFieldCount-1] of Integer;
 RequestSend:array[0..FenixFieldCount-1] of DWORD;
 Packet:array[0..40+FenixBatchSize*8-1] of Byte;
function BlockSize:Integer;begin if IsAirliner or IsGSX then Result:=1 else Result:=FenixBatchSize;end;
function FieldCount:Integer;begin if IsGSX then Result:=GSXVarCount else if IsAirliner then Result:=AirlinerVarCount else if IsFBW then Result:=FBWFieldCount else Result:=FenixFieldCount;end;
function BatchCount:Integer;begin Result:=(FieldCount+BlockSize-1) div BlockSize;end;
function FieldName(I:Integer):string;begin if IsGSX then Result:=GSXNames[I] else if IsAirliner then Result:=AirlinerNames[I] else if IsFBW then Result:=FBWFields[I].Name else Result:=FenixFields[I].Name;end;
procedure FenixMockReset(M:Integer);stdcall;
begin IsGSX:=False;IsAirliner:=False;IsFBW:=False;Mode:=M;Adds:=0;Requests:=0;Opens:=0;Closes:=0;Writes:=0;Errors:=0;Queue:=0;LastSend:=0;FillChar(Counts,SizeOf(Counts),0);end;
function FenixMockCount(Kind:Integer):Integer;stdcall;
begin case Kind of 0:Result:=Adds;1:Result:=Requests;2:Result:=Opens;3:Result:=Closes;4:Result:=Writes;else Result:=Errors;end;end;
function SimConnect_Open(var H:THandle;N:PAnsiChar;W:HWND;E:DWORD;EH:THandle;C:DWORD):HRESULT;stdcall;
begin IsGSX:=Pos('GSX',string(AnsiString(N)))>0;IsAirliner:=Pos('AIRLINER',string(AnsiString(N)))>0;IsFBW:=Pos('FBW',string(AnsiString(N)))>0;Inc(Opens);H:=1;Result:=0;end;
function SimConnect_Close(H:THandle):HRESULT;stdcall;begin Inc(Closes);Result:=0;end;
function SimConnect_GetLastSentPacketID(H:THandle;var ID:DWORD):HRESULT;stdcall;begin ID:=LastSend;Result:=0;end;
function SimConnect_AddToDataDefinition(H:THandle;ID:DWORD;N,U:PAnsiChar;T:DWORD;E:Single;D:DWORD):HRESULT;stdcall;
var B,I:Integer;
begin
 Inc(LastSend);Inc(Adds);Result:=0;B:=Integer(ID)-1000;
 if (B<0) or (B>=BatchCount) then begin Inc(Errors);Exit;end;
 I:=B*BlockSize+Counts[B];Inc(Counts[B]);
 if (I>=FieldCount) or (string(AnsiString(N))<>'L:'+FieldName(I)) or (string(AnsiString(U))<>'number') or (T<>4) then Inc(Errors);
end;
function SimConnect_RequestDataOnSimObject(H:THandle;R,D,O,P,F,A,I,L:DWORD):HRESULT;stdcall;
var B:Integer;
begin
 Inc(LastSend);Inc(Requests);B:=Integer(D)-1000;Result:=0;
 if (B<0) or (B>=BatchCount) then begin Inc(Errors);Exit;end;
 RequestSend[B]:=LastSend;if (R<>2000+DWORD(B)) or (P<>3) or (O<>0) or (F<>0) then Inc(Errors);
end;
procedure Put(Offset:Integer;Value:DWORD);begin Move(Value,Packet[Offset],4);end;
function SimConnect_GetNextDispatch(H:THandle;var P:Pointer;var Size:DWORD):HRESULT;stdcall;
var B,I,N:Integer;V:Double;Name:string;
begin
 Result:=HRESULT($80004005);if (Mode=6) or (Queue>=BatchCount) then Exit;
 B:=Queue;Inc(Queue);if (Mode=1) and (B=BatchCount-1) then Exit;
 FillChar(Packet,SizeOf(Packet),0);P:=@Packet[0];Result:=0;
 if (Mode=5) then begin Put(8,3);Size:=12;Queue:=BatchCount;Exit;end;
 if (Mode=3) and (B=0) then begin Put(8,1);Put(12,3);Put(16,RequestSend[0]);Size:=24;Exit;end;
 N:=Min(BlockSize,FieldCount-B*BlockSize);Size:=40+N*8;
 Put(0,Size);Put(8,8);Put(12,2000+B);Put(20,1000+B);Put(36,N);
 if (Mode=4) and (B=0) then Put(36,N+1);
 for I:=0 to N-1 do begin
  Name:=FieldName(B*BlockSize+I);V:=0;
  if Name='S_MIP_GEAR' then V:=1 else if Name='S_FC_FLAPS' then V:=3
  else if Name='A_FC_THROTTLE_LEFT_INPUT' then V:=3 else if Name='I_FCU_AP1' then V:=1;
  if IsAirliner then begin
   if Name='AIRLINER_V1_SPEED' then V:=135 else if Name='AIRLINER_VR_SPEED' then V:=140 else if Name='AIRLINER_V2_SPEED' then V:=145
   else if Name='AIRLINER_MINIMUM_DESCENT_ALTITUDE' then V:=420 else V:=200;
  end;
  if IsGSX then begin if Pos('_STATE',Name)>0 then V:=5 else if Name='FSDT_VAR_Frozen' then V:=1 else V:=42;end;
  if IsFBW then begin
   if Name='A32NX_IS_READY' then V:=1
   else if Name='A32NX_FLAPS_HANDLE_INDEX' then V:=3
   else if Name='A32NX_AUTOTHRUST_STATUS' then V:=2
   else if Name='A32NX_SPEEDS_VAPP' then V:=138
   else if Name='A32NX_SPEEDS_MANAGED_PFD' then V:=145
   else if Name='A32NX_FCU_AFS_DISPLAY_SPD_MACH_VALUE' then begin if Mode=9 then V:=0.78 else V:=180;end
   else if Name='A32NX_FCU_AFS_DISPLAY_MACH_MODE' then V:=Ord(Mode=9)
   else if Name='A32NX_FCU_AP_1_LIGHT_ON' then V:=1;
   if (Mode=8) and (Name='A32NX_IS_READY') then V:=0;
   if (Mode=10) and (Name='A32NX_FCU_AFS_DISPLAY_SPD_MACH_DASHES') then V:=1;
  end;
  if (Mode=2) and ((Name='S_MIP_GEAR') or (Name='A32NX_AUTOTHRUST_STATUS') or (Name='AIRLINER_V1_SPEED') or (Name='FSDT_GSX_BOARDING_STATE')) then V:=NaN;
  if Mode=7 then V:=0;Move(V,Packet[40+I*8],8);
 end;
end;
function SimConnect_SetDataOnSimObject:HResult;stdcall;begin Inc(Writes);Result:=HRESULT($80004005);end;
exports SimConnect_Open,SimConnect_Close,SimConnect_GetLastSentPacketID,SimConnect_AddToDataDefinition,
 SimConnect_RequestDataOnSimObject,SimConnect_GetNextDispatch,SimConnect_SetDataOnSimObject,FenixMockReset,FenixMockCount;
begin FenixMockReset(0);end.
