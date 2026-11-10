Program RepairToolbarIcon;
{$APPTYPE CONSOLE}

Uses
 Vcl.XPMan, System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics, Vcl.ImgList, Vcl.Imaging.pngimage, System.RegularExpressions, System.IOUtils;

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
 Images : TImageList;
 b      : TBitmap;
 p      : TPngImage;
 Pixel  : PPixel;
 Color  : TColor;
 x      : Integer;
 y      : Integer;
 a      : Integer;
 Size   : Integer;
 Index  : Integer;
 Path   : String;
 Source : String;
 Block  : String;
 Output : String;
 m      : TMatch;
 Input  : TMemoryStream;
 Bin    : TMemoryStream;
 Text   : TMemoryStream;
 Bytes  : TBytes;
 t      : TStringStream;

Begin
 Path   := ParamStr(1);
 Source := TFile.ReadAllText(Path, TEncoding.UTF8);
 Index  := StrToInt(ParamStr(4));
 m      := TRegEx.Match(Source, '(?ms)^  object ' + ParamStr(2) + ': TImageList\r?\n.*?^  end');
 If Not m.Success Then
  Raise Exception.Create('Image list not found');
 Block  := m.Value;
 Images := TImageList.Create(Nil);
 b      := TBitmap.Create;
 p      := TPngImage.Create;
 Input  := TMemoryStream.Create;
 Bin    := TMemoryStream.Create;
 Text   := TMemoryStream.Create;
 Try
  t := TStringStream.Create(Block, TEncoding.UTF8);
  Try
   ObjectTextToBinary(t, Input);
  Finally
   t.Free;
  End;
  Input.Position := 0;
  Input.ReadComponent(Images);
  If Index >= Images.Count Then
   Raise Exception.Create('Bad icon index');
  Size := Images.Width;
  p.LoadFromFile(ParamStr(3));
  b.PixelFormat := pf32bit;
  b.SetSize(Size, Size);
  b.AlphaFormat := afDefined;
  For y         := 0 To Size - 1 Do
   For x        := 0 To Size - 1 Do
    Begin
     Color   := PixelColor(p, x * p.Width Div Size, y * p.Height Div Size);
     a       := PixelAlpha(p, x * p.Width Div Size, y * p.Height Div Size);
     Pixel   := PPixel(NativeUInt(b.Scanline[y]) + NativeUInt(x * 4));
     Pixel.b := GetBValue(Color);
     Pixel.g := GetGValue(Color);
     Pixel.r := GetRValue(Color);
     Pixel.a := a;
    End;
  Images.Replace(Index, b, Nil);
  Bin.WriteComponent(Images);
  Bin.Position := 0;
  ObjectBinaryToText(Bin, Text);
  SetLength(Bytes, Text.Size);
  Text.Position := 0;
  Text.ReadBuffer(Bytes[0], Length(Bytes));
  Output := TEncoding.UTF8.GetString(Bytes);
  Output := TRegEx.Match(Output, 'Bitmap = \{[\s\S]*?\}').Value;
  Block  := StringReplace(Block, TRegEx.Match(Block, 'Bitmap = \{[\s\S]*?\}').Value, Output, []);
  Source := Copy(Source, 1, m.Index) + Block + Copy(Source, m.Index + m.Length + 1, MaxInt);
  TFile.WriteAllText(Path, Source, TEncoding.UTF8);
  Writeln('PASS: icon ', Index, ' repaired; image count remains ', Images.Count);
 Finally
  Text.Free;
  Bin.Free;
  Input.Free;
  p.Free;
  b.Free;
  Images.Free;
 End;

End.
