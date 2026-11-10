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
   FontFiles     : TStringList;
   EmbeddedFonts : Array [0..4] Of THandle;

  Function BundledFontsDirectory : String;
   Begin
    Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'fonts');
    If Not TDirectory.Exists(Result) Then
     Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '..\bin\fonts'));
   End;

  Procedure LoadFonts;
   Const
    Names : Array [0..4] Of String = ('NotoSans-Regular.ttf', 'NotoSansArabic-Regular.ttf', 'NotoSansHebrew-Regular.ttf', 'NotoSansDevanagari-Regular.ttf', 'NotoSansCJK-Regular.ttc');
   Var
    Name     : String;
    FileName : String;
    i        : Integer;
    Resource : HRSRC;
    Loaded   : HGLOBAL;
    Count    : DWORD;
   Begin
    FontFiles := TStringList.Create;
    i         := 0;
    For Name In Names Do
     Begin
      FileName := TPath.Combine(BundledFontsDirectory, Name);
      If FileExists(FileName) And (AddFontResourceEx(PChar(FileName), FR_PRIVATE, Nil) > 0) Then
       FontFiles.Add(FileName)
      Else
       Begin
        Resource := FindResource(HInstance, PChar('SETUP_FONT_' + IntToStr(i)), RT_RCDATA);
        If Resource <> 0 Then
         Begin
          Loaded           := LoadResource(HInstance, Resource);
          Count            := 0;
          EmbeddedFonts[i] := AddFontMemResourceEx(LockResource(Loaded), SizeofResource(HInstance, Resource), Nil, @Count);
          If EmbeddedFonts[i] <> 0 Then
           FontFiles.Add('@resource:' + Name);
         End;
       End;
      Inc(i);
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

  Function RawControl(c : TControl) : Boolean;
   Var
    n : String;
   Begin
    n      := LowerCase(c.Name);
    Result := (c Is TCustomMemo) Or (c Is TCustomUpDown) Or (c Is TTrackBar) Or (c.ClassName = 'TFlightCharts') Or (c.ClassName = 'TFlightMap') Or (c.ClassName = 'TfraFMC') Or (c.ClassName = 'TSixPackDisplay') Or (c.ClassName = 'TEngineGauges') Or ((c Is TCustomEdit) And ((Pos('url', n) > 0) Or (Pos('path', n) > 0) Or (Pos('key', n) > 0) Or (Pos('model', n) > 0) Or (Pos('codex', n) > 0) Or (Pos('username', n) > 0) Or (Pos('interval', n) > 0)));
   End;

  Procedure SyncNativeDirection(c : TControl);
   Const
    RTLBits = WS_EX_RIGHT Or WS_EX_RTLREADING Or WS_EX_LEFTSCROLLBAR;
   Var
    w       : TWinControl;
    Style   : NativeInt;
    Updated : NativeInt;
   Begin
    If Not(c Is TWinControl) Then
     Exit;
    w := TWinControl(c);
    If Not w.HandleAllocated Then
     Exit;
    Style   := GetWindowLongPtr(w.Handle, GWL_EXSTYLE);
    Updated := Style;
    If TControlAccess(c).BiDiMode = bdLeftToRight Then
     Updated := Style And Not NativeInt(RTLBits Or WS_EX_LAYOUTRTL Or WS_EX_NOINHERITLAYOUT)
    Else If c Is TFrame Then
     Updated := Style Or RTLBits;
    // TFrame does not reliably recreate its HWND when BiDiMode changes. Clear
    // stale native reading/scrollbar/layout flags as well as the VCL property.
    If Updated <> Style Then
     Begin
      SetWindowLongPtr(w.Handle, GWL_EXSTYLE, Updated);
      SetWindowPos(w.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_FRAMECHANGED);
     End;
   End;

  Procedure ApplyControl(c : TControl; Const Locale : String);
   Var
    i : Integer;
    a : TControlAccess;
   Begin
    a := TControlAccess(c);
    If Not SameText(a.Font.Name, 'Consolas') And Not SameText(a.Font.Name, 'Courier New') Then
     Begin
      a.Font.Charset := DEFAULT_CHARSET;
      a.Font.Name    := LocaleFontName(Locale);
     End;
    If RawControl(c) Then
     Begin
      a.ParentBiDiMode := False;
      a.BiDiMode       := bdLeftToRight;
     End;
    SyncNativeDirection(c);
    If c Is TWinControl Then
     For i := 0 To TWinControl(c).ControlCount - 1 Do
      ApplyControl(TWinControl(c).Controls[i], Locale);
    c.Invalidate;
   End;

  Function SyncMenuHandle(MenuHandle : HMENU; RTL : Boolean) : Boolean;
   Const
    DirectionFlags = MFT_RIGHTORDER Or MFT_RIGHTJUSTIFY;
   Var
    i     : Integer;
    Info  : TMenuItemInfo;
    Flags : Cardinal;
   Begin
    Result := False;
    For i  := 0 To GetMenuItemCount(MenuHandle) - 1 Do
     Begin
      FillChar(Info, SizeOf(Info), 0);
      Info.cbSize := SizeOf(Info);
      Info.fMask  := MIIM_FTYPE Or MIIM_SUBMENU;
      If Not GetMenuItemInfo(MenuHandle, i, True, Info) Then
       Continue;
      Flags := Info.fType And Not Cardinal(DirectionFlags);
      If RTL Then
       Flags := Flags Or DirectionFlags;
      If Flags <> Info.fType Then
       Begin
        Info.fType := Flags;
        Info.fMask := MIIM_FTYPE;
        If SetMenuItemInfo(MenuHandle, i, True, Info) Then
         Result := True;
       End;
      If Info.hSubMenu <> 0 Then
       If SyncMenuHandle(Info.hSubMenu, RTL) Then
        Result := True;
     End;
   End;

  Procedure SyncMenus(Root : TComponent);
   Var
    i       : Integer;
    Menu    : TMenuAccess;
    Mode    : TBiDiMode;
    Changed : Boolean;
   Begin
    If Not(Root Is TControl) Then
     Exit;
    Mode    := TControlAccess(Root).BiDiMode;
    Changed := False;
    For i   := 0 To Root.ComponentCount - 1 Do
     If Root.Components[i] Is TMenu Then
      Begin
       Menu                := TMenuAccess(Root.Components[i]);
       Menu.ParentBiDiMode := False;
       If Menu.BiDiMode <> Mode Then
        Begin
         Menu.BiDiMode := Mode;
         Changed       := True;
        End;
       // Delphi 10.2's TMenu.DoBiDiModeChanged is gated by SysLocale.MiddleEast
       // and updates only the first root item. Existing submenus need all of
       // their native direction flags synchronized, also on Polish Windows.
       If SyncMenuHandle(Menu.Handle, Mode = bdRightToLeft) Then
        Changed := True;
      End;
    If Changed And (Root Is TCustomForm) And TCustomForm(Root).HandleAllocated Then
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
    Handle   : THandle;
   Begin
    For Handle In EmbeddedFonts Do
     If Handle <> 0 Then
      RemoveFontMemResourceEx(Handle);
    For FileName In FontFiles Do
     If Copy(FileName, 1, 10) <> '@resource:' Then
      RemoveFontResourceEx(PChar(FileName), FR_PRIVATE, Nil);
    FontFiles.Free;
   End;

 Initialization

  LoadFonts;

 Finalization

  UnloadFonts;

End.
