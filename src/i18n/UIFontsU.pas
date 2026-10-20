{$StackFrames On}
Unit UIFontsU;

Interface

 Uses
  System.Classes, Vcl.Controls;

 Function LocaleFontName(Const Locale : String) : String;
 Function BundledFontsDirectory : String;
 Function BundledFontCount : Integer;
 Procedure ApplyLocalePresentation(Root : TComponent; Const Locale : String);

Implementation

 Uses
  System.SysUtils, System.IOUtils, Winapi.Windows, Vcl.Forms, Vcl.Menus, Vcl.Graphics, Vcl.StdCtrls, Vcl.ComCtrls;

 Type
  TControlAccess = Class(TControl);
  TMenuAccess = Class(TMenu);

 Var
  FontFiles : TStringList;

 Function BundledFontsDirectory : String;
  Begin
   Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'fonts');
   If Not TDirectory.Exists(Result) Then
    Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\bin\fonts'));
  End;

 Procedure LoadFonts;
  Const
   Names : Array [0 .. 4] Of String = ('NotoSans-Regular.ttf', 'NotoSansArabic-Regular.ttf', 'NotoSansHebrew-Regular.ttf', 'NotoSansDevanagari-Regular.ttf', 'NotoSansCJK-Regular.ttc');
  Var
   Name     : String;
   FileName : String;
  Begin
   FontFiles := TStringList.Create;
   For Name In Names Do
    Begin
     FileName := TPath.Combine(BundledFontsDirectory, Name);
     If FileExists(FileName) And (AddFontResourceEx(PChar(FileName), FR_PRIVATE, Nil) > 0) Then
      FontFiles.Add(FileName);
    End;
  End;

 Function BundledFontCount : Integer;
  Begin
   Result := FontFiles.Count;
  End;

 Function LocaleFontName(Const Locale : String) : String;
  Begin
   If SameText(Copy(Locale, 1, 2), 'zh') Then
    Result := 'Noto Sans CJK SC'
   Else If SameText(Copy(Locale, 1, 2), 'ja') Then
    Result := 'Noto Sans CJK JP'
   Else If SameText(Copy(Locale, 1, 2), 'ar') Then
    Result := 'Noto Sans Arabic'
   Else If SameText(Copy(Locale, 1, 2), 'he') Then
    Result := 'Noto Sans Hebrew'
   Else If SameText(Copy(Locale, 1, 2), 'hi') Then
    Result := 'Noto Sans Devanagari'
   Else
    Result := 'Noto Sans';
  End;

 Function RawControl(C : TControl) : Boolean;
  Var
   N : String;
  Begin
   N      := LowerCase(C.Name);
   Result := (C Is TCustomMemo) Or (C Is TCustomUpDown) Or (C Is TTrackBar) Or (C.ClassName = 'TFlightCharts') Or (C.ClassName = 'TFlightMap') Or (C.ClassName = 'TWVWindowParent') Or ((C Is TCustomEdit) And ((Pos('url', N) > 0) Or (Pos('path', N) > 0) Or (Pos('key', N) > 0) Or (Pos('model', N) > 0) Or (Pos('codex', N) > 0) Or (Pos('username', N) > 0) Or (Pos('interval', N) > 0)));
  End;

 Procedure SyncNativeDirection(C : TControl);
  Const
   RTLBits = WS_EX_RIGHT Or WS_EX_RTLREADING Or WS_EX_LEFTSCROLLBAR;
  Var
   W       : TWinControl;
   Style   : NativeInt;
   Updated : NativeInt;
  Begin
   If Not(C Is TWinControl) Then
    Exit;
   W := TWinControl(C);
   If Not W.HandleAllocated Then
    Exit;
   Style   := GetWindowLongPtr(W.Handle, GWL_EXSTYLE);
   Updated := Style;
   If TControlAccess(C).BiDiMode = bdLeftToRight Then
    Updated := Style And Not NativeInt(RTLBits Or WS_EX_LAYOUTRTL Or WS_EX_NOINHERITLAYOUT)
   Else If C Is TFrame Then
    Updated := Style Or RTLBits;
   // TFrame does not reliably recreate its HWND when BiDiMode changes. Clear
   // stale native reading/scrollbar/layout flags as well as the VCL property.
   If Updated <> Style Then
    Begin
     SetWindowLongPtr(W.Handle, GWL_EXSTYLE, Updated);
     SetWindowPos(W.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_FRAMECHANGED);
    End;
  End;

 Procedure ApplyControl(C : TControl; Const Locale : String);
  Var
   i : Integer;
   A : TControlAccess;
  Begin
   A := TControlAccess(C);
   If Not SameText(A.Font.Name, 'Consolas') And Not SameText(A.Font.Name, 'Courier New') Then
    Begin
     A.Font.Charset := DEFAULT_CHARSET;
     A.Font.Name    := LocaleFontName(Locale);
    End;
   If RawControl(C) Then
    Begin
     A.ParentBiDiMode := False;
     A.BiDiMode       := bdLeftToRight;
    End;
   SyncNativeDirection(C);
   If C Is TWinControl Then
    For i := 0 To TWinControl(C).ControlCount - 1 Do
     ApplyControl(TWinControl(C).Controls[i], Locale);
   C.Invalidate;
  End;

 Procedure SyncMenuHandle(MenuHandle : HMENU; RTL : Boolean);
  Const
   DirectionFlags = MFT_RIGHTORDER Or MFT_RIGHTJUSTIFY;
  Var
   I : Integer;
   Info : TMenuItemInfo;
   Flags : Cardinal;
  Begin
   For I := 0 To GetMenuItemCount(MenuHandle)-1 Do
    Begin
     FillChar(Info,SizeOf(Info),0);
     Info.cbSize := SizeOf(Info);
     Info.fMask := MIIM_FTYPE Or MIIM_SUBMENU;
     If Not GetMenuItemInfo(MenuHandle,I,True,Info) Then Continue;
     Flags := Info.fType And Not Cardinal(DirectionFlags);
     If RTL Then Flags := Flags Or DirectionFlags;
     If Flags <> Info.fType Then
      Begin
       Info.fType := Flags;
       Info.fMask := MIIM_FTYPE;
       SetMenuItemInfo(MenuHandle,I,True,Info);
      End;
     If Info.hSubMenu <> 0 Then SyncMenuHandle(Info.hSubMenu,RTL);
    End;
  End;

 Procedure SyncMenus(Root : TComponent);
  Var
   I : Integer;
   Menu : TMenuAccess;
   Mode : TBiDiMode;
  Begin
   If Not (Root Is TControl) Then Exit;
   Mode := TControlAccess(Root).BiDiMode;
   For I := 0 To Root.ComponentCount-1 Do
    If Root.Components[I] Is TMenu Then
     Begin
      Menu := TMenuAccess(Root.Components[I]);
      Menu.ParentBiDiMode := False;
      Menu.BiDiMode := Mode;
      // Delphi 10.2's TMenu.DoBiDiModeChanged is gated by SysLocale.MiddleEast
      // and updates only the first root item. Existing submenus need all of
      // their native direction flags synchronized, also on Polish Windows.
      SyncMenuHandle(Menu.Handle,Mode=bdRightToLeft);
     End;
   If (Root Is TCustomForm) And TCustomForm(Root).HandleAllocated Then
    DrawMenuBar(TCustomForm(Root).Handle);
  End;

 Procedure ApplyLocalePresentation(Root : TComponent; Const Locale : String);
  Begin
   If Root Is TControl Then
    ApplyControl(TControl(Root), Locale);
   SyncMenus(Root);
  End;

 Procedure UnloadFonts;
  Var
   FileName : String;
  Begin
   For FileName In FontFiles Do
    RemoveFontResourceEx(PChar(FileName), FR_PRIVATE, Nil);
   FontFiles.Free;
  End;

Initialization

 LoadFonts;

Finalization

 UnloadFonts;

End.
