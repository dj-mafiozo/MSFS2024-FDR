Program RebuildToolbarImages;
{$APPTYPE CONSOLE}

Uses
 Vcl.XPMan, System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics, Vcl.ImgList, Vcl.Imaging.pngimage;

Type
 PPixel = ^TPixel;

 TPixel = Packed Record
  b : Byte;
  g : Byte;
  r : Byte;
  a : Byte;
 End;

Function PaletteIndex(Image : TPngImage; x, y : Integer) : Byte;
 Var
  Row : PByteArray;
 Begin
  Row := Image.Scanline[y];
  Case Image.Header.BitDepth Of
   1    : Result := (Row^[x Div 8] Shr (7 - x Mod 8)) And 1;
   2, 4 : Result := (Row^[x Div 2] Shr ((1 - x Mod 2) * 4)) And 15;
  Else Result := Row^[x];
  End;
 End;

Function PixelColor(Image : TPngImage; x, y : Integer) : TColor;
 Var
  Color : TRGBQuad;
 Begin
  If Image.Header.ColorType = COLOR_PALETTE Then
   Begin
    Color  := TChunkPLTE(Image.Chunks.ItemFromClass(TChunkPLTE)).Item[PaletteIndex(Image, x, y)];
    Result := RGB(Color.rgbRed, Color.rgbGreen, Color.rgbBlue);
   End
  Else
   Result := ColorToRGB(Image.Canvas.Pixels[x, y]);
 End;

Function PixelAlpha(Image : TPngImage; x, y : Integer) : Byte;
 Var
  Trns  : TChunktRNS;
  Row   : PByteArray;
  Index : Byte;
 Begin
  If Image.AlphaScanline[y] <> Nil Then
   Exit(Image.AlphaScanline[y]^[x]);
  If Image.Header.ColorType = COLOR_PALETTE Then
   Begin
    Trns := TChunktRNS(Image.Chunks.ItemFromClass(TChunktRNS));
    If Trns = Nil Then
     Exit(255);
    Row := Image.Scanline[y];
    Case Image.Header.BitDepth Of
     1    : Index := (Row^[x Div 8] Shr (7 - x Mod 8)) And 1;
     2, 4 : Index := (Row^[x Div 2] Shr ((1 - x Mod 2) * 4)) And 15;
    Else Index := Row^[x];
    End;
    Exit(Trns.PaletteValues[Index]);
   End;
  If (Image.TransparencyMode = ptmBit) And
  (ColorToRGB(Image.Canvas.Pixels[x, y]) = ColorToRGB(Image.TransparentColor)) Then
   Exit(0);
  Result := 255;
 End;

Var
 Images   : TImageList;
 b        : TBitmap;
 Flag     : TBitmap;
 p        : TPngImage;
 Pixel    : PPixel;
 Color    : TColor;
 i        : Integer;
 x        : Integer;
 y        : Integer;
 a        : Integer;
 SX       : Integer;
 SY       : Integer;
 Size     : Integer;
 Root     : String;
 FileName : String;
 Bin      : TMemoryStream;
 Text     : TMemoryStream;
 Names    : TStringList;

Begin
 Root := IncludeTrailingPathDelimiter(ParamStr(1));
 Size := StrToIntDef(ParamStr(3), 22);
 If (Size <> 16) And (Size <> 22) Then
  Raise Exception.Create('Unsupported icon size');
 Names := TStringList.Create;
 Names.LoadFromFile(Root + 'tools\' + ParamStr(2) + '-icons.txt');
 Images := TImageList.Create(Nil);
 b      := TBitmap.Create;
 p      := TPngImage.Create;
 Flag   := TBitmap.Create;
 Bin    := TMemoryStream.Create;
 Text   := TMemoryStream.Create;
 Try
  Images.Name         := 'ImageList';
  Images.ColorDepth   := cd32Bit;
  Images.Masked       := False;
  Images.DrawingStyle := dsTransparent;
  Images.Width        := Size;
  Images.Height       := Size;
  // ImageList_Add premultiplies straight RGBA; do not premultiply a second time.
  b.PixelFormat := pf32bit;
  b.SetSize(Size, Size);
  b.AlphaFormat := afDefined;
  For i         := 0 To Names.Count - 1 Do
   Begin
    For y := 0 To Size - 1 Do
     FillChar(b.Scanline[y]^, Size * 4, 0);
    FileName := Root + 'Icons\' + IntToStr(Size) + 'x' + IntToStr(Size) + '\' + Names[i];
    If Not FileExists(FileName) Then
     FileName := Root + 'Icons\Flags\' + Names[i];
    If Not FileExists(FileName) Then
     FileName := Root + 'Icons\' + Names[i];
    If Not FileExists(FileName) Then
     FileName := Root + 'Icons\22x22\' + Names[i];
    If SameText(ExtractFileExt(FileName), '.png') Then
     Begin
      p.LoadFromFile(FileName);
      For y  := 0 To Size - 1 Do
       For x := 0 To Size - 1 Do
        Begin
         Color   := PixelColor(p, x * p.Width Div Size, y * p.Height Div Size);
         a       := PixelAlpha(p, x * p.Width Div Size, y * p.Height Div Size);
         Pixel   := PPixel(NativeUInt(b.Scanline[y]) + NativeUInt(x * 4));
         Pixel.b := GetBValue(Color);
         Pixel.g := GetGValue(Color);
         Pixel.r := GetRValue(Color);
         Pixel.a := a;
        End;
     End
    Else
     Begin
      Flag.LoadFromFile(FileName);
      SX     := (Size - Flag.Width) Div 2;
      SY     := (Size - Flag.Height) Div 2;
      For y  := 0 To Flag.Height - 1 Do
       For x := 0 To Flag.Width - 1 Do
        Begin
         Color   := ColorToRGB(Flag.Canvas.Pixels[x, y]);
         Pixel   := PPixel(NativeUInt(b.Scanline[y + SY]) + NativeUInt((x + SX) * 4));
         Pixel.b := GetBValue(Color);
         Pixel.g := GetGValue(Color);
         Pixel.r := GetRValue(Color);
         Pixel.a := 255;
        End;
     End;
    If Images.Add(b, Nil) <> i Then
     Raise Exception.Create('Unexpected image index');
   End;
  Bin.WriteComponent(Images);
  Bin.Position := 0;
  ObjectBinaryToText(Bin, Text);
  Text.SaveToFile(Root + '.build\' + ParamStr(2) + '-images.dfm');
  Writeln('PASS: ', Names.Count, ' ', ParamStr(2), ' icons rebuilt with alpha transparency.');
 Finally
  Text.Free;
  Bin.Free;
  Flag.Free;
  p.Free;
  b.Free;
  Images.Free;
  Names.Free;
 End;

End.
