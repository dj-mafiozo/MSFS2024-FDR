Unit PanelProportionsU;

Interface

 Uses
  System.Classes, System.Generics.Collections, Vcl.Controls, Vcl.ExtCtrls;

 Type
  TPanelRatio = Class
   Control    : TWinControl;
   Parent     : TWinControl;
   Horizontal : Boolean;
   DockOnly   : Boolean;
   Ratio      : Double;
   Minimum    : Integer;
   Rest       : Integer;
  End;

  TPanelProportions = Class
   Private
    fItems    : TObjectList<TPanelRatio>;
    fApplying : Boolean;
    Function Active   (e : TPanelRatio)                            : Boolean;
    Function Available(Parent : TWinControl; Horizontal : Boolean) : Integer;
   Public
    Constructor Create;
    Destructor  Destroy; Override;
    Procedure   Add         (Control : TWinControl; Horizontal : Boolean; Minimum, Rest : Integer; DockOnly : Boolean = False);
    Procedure   CaptureGroup(Parent : TWinControl; Horizontal : Boolean);
    Procedure   Capture;
    Procedure   Apply;
  End;

Implementation

 Uses
  System.Math;

 Constructor TPanelProportions.Create;
  Begin
   Inherited;
   fItems := TObjectList<TPanelRatio>.Create(True);
  End;

 Destructor TPanelProportions.Destroy;
  Begin
   fItems.Free;
   Inherited;
  End;

 Function TPanelProportions.Active(e : TPanelRatio) : Boolean;
  Begin
   Result := (e.Control.Parent = e.Parent) And e.Control.Visible And ((e.Horizontal And (e.Control.Align In [alLeft, alRight])) Or (Not e.Horizontal And (e.Control.Align In [alTop, alBottom]))) And (Not e.DockOnly Or (e.Control.DockClientCount > 0));
  End;

 Function TPanelProportions.Available(Parent : TWinControl; Horizontal : Boolean) : Integer;
  Var
   i       : Integer;
   c       : TControl;
   e       : TPanelRatio;
   Managed : Boolean;
  Begin
   If Horizontal Then
    Result := Parent.ClientWidth
   Else
    Result := Parent.ClientHeight;
   For i   := 0 To Parent.ControlCount - 1 Do
    Begin
     c := Parent.Controls[i];
     If Not c.Visible Then
      Continue;
     If (Horizontal And Not(c.Align In [alLeft, alRight])) Or (Not Horizontal And Not(c.Align In [alTop, alBottom])) Then
      Continue;
     Managed := False;
     For e In fItems Do
      If (e.Control = c) And Active(e) Then
       Begin
        Managed := True;
        Break;
       End;
     If Not Managed Then
      If Horizontal Then
       Dec(Result, c.Width)
      Else
       Dec(Result, c.Height);
    End;
   Result := Max(0, Result);
  End;

 Procedure TPanelProportions.Add(Control : TWinControl; Horizontal : Boolean; Minimum, Rest : Integer; DockOnly : Boolean);
  Var
   e : TPanelRatio;
  Begin
   e            := TPanelRatio.Create;
   e.Control    := Control;
   e.Parent     := Control.Parent;
   e.Horizontal := Horizontal;
   e.Minimum    := Minimum;
   e.Rest       := Rest;
   e.DockOnly   := DockOnly;
   e.Ratio      := 0.25;
   fItems.Add(e);
  End;

 Procedure TPanelProportions.CaptureGroup(Parent : TWinControl; Horizontal : Boolean);
  Var
   e : TPanelRatio;
   n : Integer;
  Begin
   If fApplying Then
    Exit;
   n := Available(Parent, Horizontal);
   If n <= 0 Then
    Exit;
   For e In fItems Do
    If (e.Parent = Parent) And (e.Horizontal = Horizontal) And Active(e) Then
     If Horizontal Then
      e.Ratio := e.Control.Width / n
     Else
      e.Ratio := e.Control.Height / n;
  End;

 Procedure TPanelProportions.Capture;
  Var
   e : TPanelRatio;
   n : Integer;
  Begin
   If fApplying Then
    Exit;
   For e In fItems Do
    If Active(e) Then
     Begin
      n := Available(e.Parent, e.Horizontal);
      If n > 0 Then
       If e.Horizontal Then
        e.Ratio := e.Control.Width / n
       Else
        e.Ratio := e.Control.Height / n;
     End;
  End;

 Procedure TPanelProportions.Apply;
  Var
   e       : TPanelRatio;
   p       : TPanelRatio;
   i       : Integer;
   j       : Integer;
   n       : Integer;
   Budget  : Integer;
   Minimum : Integer;
   Extra   : Integer;
   Want    : Integer;
   Size    : Integer;
   Used    : Integer;
   MinRest : Integer;
   Seen    : Boolean;
   f       : Double;
  Begin
   If fApplying Then
    Exit;
   fApplying := True;
   Try
    For i := 0 To fItems.Count - 1 Do
     Begin
      e     := fItems[i];
      Seen  := False;
      For j := 0 To i - 1 Do
       If (fItems[j].Parent = e.Parent) And (fItems[j].Horizontal = e.Horizontal) Then
        Seen := True;
      If Seen Then
       Continue;
      n := Available(e.Parent, e.Horizontal);
      If n <= 0 Then
       Continue;
      Minimum := 0;
      Extra   := 0;
      MinRest := 0;
      For p In fItems Do
       If (p.Parent = e.Parent) And (p.Horizontal = e.Horizontal) And Active(p) Then
        Begin
         Inc(Minimum, p.Minimum);
         MinRest := Max(MinRest, p.Rest);
         Inc(Extra, Max(0, Round(p.Ratio * n) - p.Minimum));
        End;
      Budget := Max(0, n - MinRest);
      Used   := 0;
      f      := 1;
      If Extra > 0 Then
       f := Min(1.0, Max(0, Budget - Minimum) / Extra);
      e.Parent.DisableAlign;
      Try
       For p In fItems Do
        If (p.Parent = e.Parent) And (p.Horizontal = e.Horizontal) And Active(p) Then
         Begin
          Want := Max(0, Round(p.Ratio * n) - p.Minimum);
          If Minimum > Budget Then
           Size := Floor(p.Minimum * Budget / Max(1, Minimum))
          Else
           Size := p.Minimum + Floor(Want * f);
          Size  := EnsureRange(Size, 0, Max(0, Budget - Used));
          Inc(Used, Size);
          If p.Horizontal Then
           p.Control.Width := Size
          Else
           p.Control.Height := Size;
         End;
      Finally
       e.Parent.EnableAlign;
      End;
     End;
   Finally
    fApplying := False;
   End;
  End;

End.
