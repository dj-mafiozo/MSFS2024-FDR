program VerifyDisplayUnits;
{$APPTYPE CONSOLE}
uses System.SysUtils,System.IOUtils,System.Classes,System.IniFiles,System.Math,System.Generics.Collections,
 Vcl.Forms,Vcl.Graphics,Vcl.Imaging.pngimage,ParameterNamesU,frmSettingsU,LocalizationU,FlightChartsU;
procedure Check(B:Boolean;const M:string);begin if not B then raise Exception.Create(M);end;
procedure Near(A,B:Double;const M:string);begin Check(Abs(A-B)<0.000001,M+' '+FloatToStr(A));end;
var Config:TMemIniFile;F:TfrmSettings;C:TFlightCharts;Indices:TList<Integer>;I:Integer;FileName:string;B:TBitmap;P:TPngImage;
begin
 Application.Initialize;SetLanguage('pl-PL');FileName:=TPath.GetTempFileName;Config:=TMemIniFile.Create(FileName);
 try
  LoadDisplayUnits(Config);Near(ParameterDisplayValue('plane_altitude',1000),1000,'Default raw');
  SaveDisplayUnit(Config,'ft','m');SaveDisplayUnit(Config,'lb','kg');SaveDisplayUnit(Config,'lb/h','kg/h');
  SaveDisplayUnit(Config,'ft/min','m/s');SaveDisplayUnit(Config,'kt','km/h');SaveDisplayUnit(Config,'US gal','l');
  SaveDisplayUnit(Config,#$00B0+'C',#$00B0+'F');SaveDisplayUnit(Config,'inHg','hPa');
  LoadDisplayUnits(Config);
  Near(ParameterDisplayValue('plane_altitude',1000),304.8,'Feet');
  Near(ParameterDisplayValue('vertical_speed',600),3.048,'Vertical speed');
  Near(ParameterDisplayValue('airspeed_indicated',100),185.2,'Knots');
  Near(ParameterDisplayValue('total_weight',100),45.359237,'Pounds');
  Near(ParameterDisplayValue('fuel_total_quantity',10),37.85411784,'US gallons');
  Near(ParameterDisplayValue('ambient_temperature',0),32,'Temperature offset');
  Near(ParameterDisplayValue('ambient_pressure',1),33.86389,'Pressure');
  Near(ParameterDisplayValue('iFlySDK.Unknown',100),100,'Unknown SDK unit is not guessed');
  Check(IsNan(ParameterDisplayValue('plane_altitude',NaN)),'NaN retained');
  Check(IsInfinite(ParameterDisplayValue('plane_altitude',Infinity)),'Infinity retained');
  Check(Pos('[m]',ParameterCaption('plane_altitude'))>0,'Caption unit agrees');
  SaveDisplayUnit(Config,'ft','kg');LoadDisplayUnits(Config);
  Near(ParameterDisplayValue('plane_altitude',1000),304.8,'Reject incompatible target');
  F:=TfrmSettings.Create(nil);
  try
   F.Load(Config);Check(F.UnitsEditor.RowCount=DisplayUnitCount+1,'One setting per source unit');
   Check(F.UnitsEditor.ItemProps[0].PickList.IndexOf('m')>=0,'Unit dropdown');
   F.UnitsEditor.Cells[1,1]:='ft';F.Save(Config);
   Near(ParameterDisplayValue('plane_altitude',1000),1000,'Settings save applies immediately');
   for I:=0 to 3 do begin
    case I of 0:SetLanguage('pl-PL');1:SetLanguage('en-US');2:SetLanguage('de-DE');3:SetLanguage('es-ES');end;
    Check(F.UnitsEditor.TitleCaptions[0]<>'','Localized headings');
   end;
   Check(F.UnitsEditor.TitleCaptions[0]='Unidad original','Spanish column heading');
   F.Position:=poDesigned;F.Left:=-4000;F.Show;Application.ProcessMessages;
   F.SettingsPages.ActivePage:=F.UnitsPage;Application.ProcessMessages;
   B:=TBitmap.Create;P:=TPngImage.Create;
   try B.SetSize(F.ClientWidth,F.ClientHeight);F.PaintTo(B.Canvas,0,0);P.Assign(B);P.SaveToFile(ExtractFilePath(ParamStr(0))+'units-preview.png');finally P.Free;B.Free;end;
  finally F.Free;end;
  C:=TFlightCharts.Create(nil);Indices:=TList<Integer>.Create;
  try for I:=0 to 63 do Indices.Add(I);C.Select(Indices);Check(C.DoubleBuffered,'64 charts remain buffered');finally Indices.Free;C.Free;end;
 finally Config.Free;DeleteFile(FileName);end;
 Writeln('PASS: display conversion, affine temperature, units/captions, invalid targets, unknown SDK, NaN/Infinity, settings and 64 buffered charts. Synthetic only.');
end.
