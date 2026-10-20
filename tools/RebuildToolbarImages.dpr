program RebuildToolbarImages;
{$APPTYPE CONSOLE}
uses Vcl.XPMan,System.SysUtils,System.Classes,Winapi.Windows,Vcl.Controls,Vcl.Graphics,Vcl.ImgList,Vcl.Imaging.pngimage;
type PPixel=^TPixel;TPixel=packed record B,G,R,A:Byte;end;
function PaletteIndex(Image:TPngImage;X,Y:Integer):Byte;
var Row:PByteArray;
begin
 Row:=Image.Scanline[Y];
 case Image.Header.BitDepth of
  1:Result:=(Row^[X div 8] shr (7-X mod 8)) and 1;
  2,4:Result:=(Row^[X div 2] shr ((1-X mod 2)*4)) and 15;
  else Result:=Row^[X];
 end;
end;
function PixelColor(Image:TPngImage;X,Y:Integer):TColor;
var Color:TRGBQuad;
begin
 if Image.Header.ColorType=COLOR_PALETTE then begin
  Color:=TChunkPLTE(Image.Chunks.ItemFromClass(TChunkPLTE)).Item[PaletteIndex(Image,X,Y)];
  Result:=RGB(Color.rgbRed,Color.rgbGreen,Color.rgbBlue);
 end else Result:=ColorToRGB(Image.Canvas.Pixels[X,Y]);
end;
function PixelAlpha(Image:TPngImage;X,Y:Integer):Byte;
var Trns:TChunkTRNS;Row:PByteArray;Index:Byte;
begin
 if Image.AlphaScanline[Y]<>nil then Exit(Image.AlphaScanline[Y]^[X]);
 if Image.Header.ColorType=COLOR_PALETTE then begin
  Trns:=TChunkTRNS(Image.Chunks.ItemFromClass(TChunkTRNS));
  if Trns=nil then Exit(255);
  Row:=Image.Scanline[Y];
  case Image.Header.BitDepth of
   1:Index:=(Row^[X div 8] shr (7-X mod 8)) and 1;
   2,4:Index:=(Row^[X div 2] shr ((1-X mod 2)*4)) and 15;
   else Index:=Row^[X];
  end;
  Exit(Trns.PaletteValues[Index]);
 end;
 if (Image.TransparencyMode=ptmBit) and
    (ColorToRGB(Image.Canvas.Pixels[X,Y])=ColorToRGB(Image.TransparentColor)) then Exit(0);
 Result:=255;
end;
var Images:TImageList;B,Flag:TBitmap;P:TPngImage;Pixel:PPixel;Color:TColor;
 I,X,Y,A,SX,SY,Size:Integer;Root,FileName:string;Bin,Text:TMemoryStream;Names:TStringList;
begin
 Root:=IncludeTrailingPathDelimiter(ParamStr(1));
 Size:=StrToIntDef(ParamStr(3),22);
 if (Size<>16) and (Size<>22) then raise Exception.Create('Unsupported icon size');
 Names:=TStringList.Create;Names.LoadFromFile(Root+'tools\'+ParamStr(2)+'-icons.txt');
 Images:=TImageList.Create(nil);B:=TBitmap.Create;P:=TPngImage.Create;Flag:=TBitmap.Create;
 Bin:=TMemoryStream.Create;Text:=TMemoryStream.Create;
 try
  Images.Name:='ImageList';Images.ColorDepth:=cd32Bit;Images.Masked:=False;
  Images.DrawingStyle:=dsTransparent;Images.Width:=Size;Images.Height:=Size;
  // ImageList_Add premultiplies straight RGBA; do not premultiply a second time.
  B.PixelFormat:=pf32bit;B.SetSize(Size,Size);B.AlphaFormat:=afDefined;
  for I:=0 to Names.Count-1 do begin
   for Y:=0 to Size-1 do FillChar(B.ScanLine[Y]^,Size*4,0);
   FileName:=Root+'Icons\'+IntToStr(Size)+'x'+IntToStr(Size)+'\'+Names[I];
   if not FileExists(FileName) then FileName:=Root+'Icons\'+Names[I];
   if not FileExists(FileName) then FileName:=Root+'Icons\22x22\'+Names[I];
   if SameText(ExtractFileExt(FileName),'.png') then begin
    P.LoadFromFile(FileName);
    for Y:=0 to Size-1 do for X:=0 to Size-1 do begin
     Color:=PixelColor(P,X*P.Width div Size,Y*P.Height div Size);A:=PixelAlpha(P,X*P.Width div Size,Y*P.Height div Size);
     Pixel:=PPixel(NativeUInt(B.ScanLine[Y])+NativeUInt(X*4));
     Pixel.B:=GetBValue(Color);Pixel.G:=GetGValue(Color);
     Pixel.R:=GetRValue(Color);Pixel.A:=A;
    end;
   end else begin
    Flag.LoadFromFile(FileName);SX:=(Size-Flag.Width) div 2;SY:=(Size-Flag.Height) div 2;
    for Y:=0 to Flag.Height-1 do for X:=0 to Flag.Width-1 do begin
     Color:=ColorToRGB(Flag.Canvas.Pixels[X,Y]);Pixel:=PPixel(NativeUInt(B.ScanLine[Y+SY])+NativeUInt((X+SX)*4));
     Pixel.B:=GetBValue(Color);Pixel.G:=GetGValue(Color);Pixel.R:=GetRValue(Color);Pixel.A:=255;
    end;
   end;
   if Images.Add(B,nil)<>I then raise Exception.Create('Unexpected image index');
  end;
  Bin.WriteComponent(Images);Bin.Position:=0;ObjectBinaryToText(Bin,Text);
  Text.SaveToFile(Root+'.build\'+ParamStr(2)+'-images.dfm');
  Writeln('PASS: ',Names.Count,' ',ParamStr(2),' icons rebuilt with alpha transparency.');
 finally Text.Free;Bin.Free;Flag.Free;P.Free;B.Free;Images.Free;Names.Free;end;
end.
