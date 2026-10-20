library MockPMDGSim;
uses Winapi.Windows,System.SysUtils,System.Math,PMDGNG3CatalogU;
const AreaIDs:array[0..2]of DWORD=(PMDGDataID,PMDGCDU0ID,PMDGCDU1ID);
 DefIDs:array[0..2]of DWORD=(PMDGDataDefinition,PMDGCDU0Definition,PMDGCDU1Definition);
 Sizes:array[0..2]of Integer=(PMDGDataSize,PMDGCDUSize,PMDGCDUSize);
 Names:array[0..2]of string=('PMDG_NG3_Data','PMDG_NG3_CDU_0','PMDG_NG3_CDU_1');
var Mode,Maps,Defs,Requests,Opens,Closes,Writes,Errors,Queue:Integer;LastSend:DWORD;Streams:array[0..2]of DWORD;
 Packet:array[0..40+PMDGCDUSize-1]of Byte;
procedure PMDGMockReset(M:Integer);stdcall;
begin Mode:=M;Maps:=0;Defs:=0;Requests:=0;Opens:=0;Closes:=0;Writes:=0;Errors:=0;Queue:=0;LastSend:=0;end;
function PMDGMockCount(Kind:Integer):Integer;stdcall;
begin case Kind of 0:Result:=Maps;1:Result:=Defs;2:Result:=Requests;3:Result:=Writes;4:Result:=Closes;else Result:=Errors;end;end;
function SimConnect_Open(var H:THandle;N:PAnsiChar;W:HWND;E:DWORD;EH:THandle;C:DWORD):HRESULT;stdcall;begin Inc(Opens);H:=1;Result:=0;end;
function SimConnect_Close(H:THandle):HRESULT;stdcall;begin Inc(Closes);Result:=0;end;
function SimConnect_GetLastSentPacketID(H:THandle;var ID:DWORD):HRESULT;stdcall;begin ID:=LastSend;Result:=0;end;
function SimConnect_MapClientDataNameToID(H:THandle;N:PAnsiChar;ID:DWORD):HRESULT;stdcall;
var I:Integer;
begin Inc(Maps);Inc(LastSend);Result:=0;for I:=0 to 2 do if (ID=AreaIDs[I]) and (string(AnsiString(N))=Names[I]) then Exit;Inc(Errors);Result:=HRESULT($80004005);end;
function SimConnect_AddToClientDataDefinition(H:THandle;ID,Offset,Size:DWORD;Epsilon:Single;DatumID:DWORD):HRESULT;stdcall;
var I:Integer;
begin Inc(Defs);Inc(LastSend);Result:=0;for I:=0 to 2 do if (ID=DefIDs[I]) and (Offset=0) and (Size=DWORD(Sizes[I])) then Exit;Inc(Errors);Result:=HRESULT($80004005);end;
function SimConnect_RequestClientData(H:THandle;ID,RequestID,Definition,Period,Flags,Origin,Interval,Limit:DWORD):HRESULT;stdcall;
var I:Integer;
begin
 Inc(Requests);Inc(LastSend);Result:=0;
 for I:=0 to 2 do if (ID=AreaIDs[I]) and (Definition=DefIDs[I]) and (Flags=0) then begin
  if (RequestID=DWORD(7000+I)) and (Period=3) then begin Streams[I]:=LastSend;Exit;end;
  if (RequestID=DWORD(7100+I)) and (Period=1) then Exit;
 end;Inc(Errors);Result:=HRESULT($80004005);
end;
procedure PutD(Offset:Integer;Value:DWORD);begin Move(Value,Packet[Offset],4);end;
procedure PutField(const Name:string;Value:Double;const Text:AnsiString='');
var I,K:Integer;F:TPMDGField;V:Single;W:Word;SW:SmallInt;D:Cardinal;SD:Integer;
begin
 for I:=0 to PMDGFieldCount-1 do if PMDGFields[I].Name=Name then begin
  F:=PMDGFields[I];K:=40+F.Offset;
  if F.Kind='f32' then begin V:=Value;Move(V,Packet[K],4);end
  else if F.Kind='u16' then begin W:=Round(Value);Move(W,Packet[K],2);end
  else if F.Kind='i16' then begin SW:=Round(Value);Move(SW,Packet[K],2);end
  else if F.Kind='u32' then begin D:=Round(Value);Move(D,Packet[K],4);end
  else if F.Kind='i32' then begin SD:=Round(Value);Move(SD,Packet[K],4);end
  else if F.Kind='text' then begin if Length(Text)>0 then Move(Text[1],Packet[K],Min(Length(Text),F.Size));end
  else Packet[K]:=Round(Value);Exit;
 end;Inc(Errors);
end;
function SimConnect_GetNextDispatch(H:THandle;var P:Pointer;var Size:DWORD):HRESULT;stdcall;
var A,Row,Col,Offset,I:Integer;Text:AnsiString;
begin
 Result:=HRESULT($80004005);if (Mode=6) or (Queue>=3) then Exit;A:=Queue;Inc(Queue);
 if (Mode=1) and (A=2) then Exit;
 FillChar(Packet,SizeOf(Packet),0);P:=@Packet[0];Result:=0;
 if Mode=5 then begin PutD(8,3);Size:=12;Queue:=3;Exit;end;
 if ((Mode=3) and (A=0)) or ((Mode=15) and (A=2)) then begin PutD(8,1);PutD(12,3);PutD(16,Streams[A]);Size:=24;Exit;end;
 Size:=40+Sizes[A];PutD(0,Size);PutD(8,16);PutD(12,7100+A);PutD(16,AreaIDs[A]);PutD(20,DefIDs[A]);PutD(36,1);
 if (Mode=4) and (A=0) then begin Dec(Size);Exit;end;
 if A=0 then begin
  PutField('AircraftModel',1);PutField('FMC_V1',135);PutField('FMC_VR',140);PutField('FMC_V2',145);PutField('FMC_LandingVREF',130);
  PutField('FMC_TakeoffFlaps',5);PutField('FMC_LandingFlaps',30);PutField('FMC_CruiseAlt',37000);PutField('FMC_LandingAltitude',-150);
  PutField('FMC_PerfInputComplete',1);PutField('FMC_DistanceToTOD',0);PutField('FMC_DistanceToDest',123.5);
  PutField('AFS_AutothrottleServosConnected',1);PutField('AFS_ControlsPitch',1);PutField('AFS_ControlsRoll',1);
  PutField('MCP_ATArmSw',1);PutField('MCP_FDSw[0]',1);PutField('MCP_indication_powered',1);PutField('MCP_IASMach',175);
  PutField('MCP_Heading',251);PutField('MCP_Altitude',5000);PutField('MCP_VertSpeed',-700);PutField('MAIN_GearLever',2);
  PutField('AIR_CabinAltNeedle',1250.5);PutField('FUEL_QtyCenter',1000);PutField('FUEL_QtyLeft',2000);PutField('FUEL_QtyRight',2000);
  PutField('FMC_flightNumber',0,'LOT123');PutField('IRS_DisplayLeft',0,'N52.10');PutField('COMM_ReceiverSwitches[0]',$F1234567);
  if Mode=2 then begin PutField('AIR_CabinAltNeedle',NaN);PutField('MCP_IASBlank',255);end;
  if Mode=7 then begin
   PutField('FMC_V1',0);PutField('FMC_VR',0);PutField('FMC_V2',0);PutField('FMC_LandingVREF',0);PutField('FMC_CruiseAlt',0);
   PutField('FMC_LandingAltitude',-32767);PutField('FMC_DistanceToTOD',-1);PutField('FMC_DistanceToDest',-2);
  end;
  if Mode=8 then PutField('MAIN_GearLever',1);
  if Mode=9 then PutField('MCP_IASMach',0.78);
  if Mode=10 then PutField('MCP_indication_powered',0);
  if Mode=11 then PutField('AircraftModel',0);
  if Mode=12 then begin PutField('MCP_IASBlank',1);PutField('MCP_VertSpeedBlank',1);end;
 end else begin
  for Col:=0 to 23 do for Row:=0 to 13 do Packet[40+(Col*14+Row)*3]:=32;
  if A=1 then Text:='PMDG CAPTAIN' else Text:='PMDG FIRST OFFICER';
  for I:=1 to Length(Text) do begin Offset:=40+((I-1)*14)*3;Packet[Offset]:=Byte(Text[I]);end;
  Packet[40+3]:=$A1;Packet[40+4]:=1;Packet[40+5]:=1;Packet[40+1008]:=1;
  if Mode=13 then Packet[40+1008]:=0;
 end;
end;
function SimConnect_SetClientData:HRESULT;stdcall;begin Inc(Writes);Result:=HRESULT($80004005);end;
function SimConnect_TransmitClientEvent:HRESULT;stdcall;begin Inc(Writes);Result:=HRESULT($80004005);end;
exports SimConnect_Open,SimConnect_Close,SimConnect_GetLastSentPacketID,SimConnect_MapClientDataNameToID,SimConnect_AddToClientDataDefinition,
 SimConnect_RequestClientData,SimConnect_GetNextDispatch,SimConnect_SetClientData,SimConnect_TransmitClientEvent,PMDGMockReset,PMDGMockCount;
begin PMDGMockReset(0);end.
