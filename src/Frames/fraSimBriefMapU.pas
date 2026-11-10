Unit fraSimBriefMapU;

Interface

 Uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, SimBriefMapsU;

 Type
  TfraSimBriefMap = Class(TFrame)
    MapTitle  : TLabel;
    MapImage  : TImage;
    MapStatus : TLabel;
    Procedure FrameResize(Sender : TObject);
   Private
    fImageWidth  : Integer;
    fImageHeight : Integer;
    fSizing      : Boolean;
   Public
    OnHeightChanged : TNotifyEvent;
    Procedure Bind(Const Map : TSimBriefMap);
  End;

Implementation

 Uses
  System.SysUtils, System.Math, Vcl.Imaging.GIFImg;
{$R *.dfm}

 Procedure TfraSimBriefMap.Bind(Const Map : TSimBriefMap);
  Var
   Stream : TBytesStream;
   GIF    : TGIFImage;
  Begin
   MapTitle.Caption  := Map.Name;
   MapStatus.Caption := Map.Error;
   MapImage.Picture.Assign(Nil);
   fImageWidth  := 0;
   fImageHeight := 0;
   If Length(Map.Data) > 0 Then
    Begin
     Stream := TBytesStream.Create(Map.Data);
     GIF    := TGIFImage.Create;
     Try
      Try
       GIF.LoadFromStream(Stream);
       GIF.Animate  := False;
       fImageWidth  := GIF.Width;
       fImageHeight := GIF.Height;
       MapImage.Picture.Assign(GIF);
      Except
       On E : Exception Do
        MapStatus.Caption := E.Message;
      End;
     Finally
      GIF.Free;
      Stream.Free;
     End;
    End;
   MapImage.Visible  := fImageWidth > 0;
   MapStatus.Visible := Not MapImage.Visible;
   FrameResize(Self);
  End;

 Procedure TfraSimBriefMap.FrameResize(Sender : TObject);
  Var
   h : Integer;
  Begin
   If fSizing Or (MapTitle = Nil) Or (MapImage = Nil) Then
    Exit;
   fSizing := True;
   Try
    h := 64;
    If fImageWidth > 0 Then
     h := MapTitle.Height + Max(1, Round(Max(1, ClientWidth) * fImageHeight / fImageWidth));
    If Height <> h Then
     Begin
      Height := h;
      If Assigned(OnHeightChanged) Then
       OnHeightChanged(Self);
     End;
   Finally
    fSizing := False;
   End;
  End;

End.
