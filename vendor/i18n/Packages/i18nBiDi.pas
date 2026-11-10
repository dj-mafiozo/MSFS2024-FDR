{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// This unit contains code for flipping controls and updating properties based
/// on the direction of the user interface language.
Unit i18nBiDi;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Messages, SysUtils, TypInfo, Classes, Controls, i18nHashList;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// BiDi provides a set of class methods for horizontal flipping of the
  /// bi-directional controls.
  /// </summary>
  {$Endregion}
  BiDi = Class
   Public
    Type
    {$Region 'xmldoc'}
    /// <summary>
    /// Represents a callback function that receives the runtime type information of
    /// the property that should be updated when its owner object is flipped.
    /// </summary>
    /// <param name="Instance">
    /// The object whose properties are examined.
    /// </param>
    /// <param name="Prop">
    /// The runtime type information of the property to update.
    /// </param>
    /// <seealso cref="RegisterProperty"/>
    /// <seealso cref="FlipProperties"/>
    /// <seealso cref="FlipChildren"/>
    {$Endregion}
    TPropertyFlipFunc = Procedure(Instance : TObject; Prop : PPropInfo);
   Private
    Class Var PropFlipFuncs : TKeyLookup<PTypeInfo, TPropertyFlipFunc>;
    Class Procedure Cleanup; Static;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Performs special actions on a specified common control to toggle its
    /// direction.
    /// </summary>
    /// <param name="Control">
    /// The target common control.
    /// </param>
    /// <seealso cref="FlipChildren"/>
    {$Endregion}
    Class Procedure FlipCommonControl(Control : TWinControl); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Applies the registered property flip functions to the properties of a
    /// specified object.
    /// </summary>
    /// <param name="Instance">
    /// The target object.
    /// </param>
    /// <seealso cref="RegisterProperty"/>
    {$Endregion}
    Class Procedure FlipProperties(Instance : TObject); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Updates the ExStyle of a specified window handle to mirror its layout
    /// according to a specified <see cref="TBiDiMode"/> value.
    /// </summary>
    /// <param name="hWnd">
    /// The window handle of the control.
    /// </param>
    /// <param name="BiDiMode">
    /// The <see cref="TBiDiMode"/> that determines the requested direction of
    /// the control's layout.
    /// </param>
    {$Endregion}
    Class Procedure UpdateLayout(hWnd : hWnd; BiDiMode : TBiDiMode); Static;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Registers a callback function that will be responsible for updating a particular
    /// property type when the owner object is flipped.
    /// </summary>
    /// <param name="PropType">
    /// The type information of the property that the handler is registered for.
    /// </param>
    /// <param name="FlipFunc">
    /// The callback function that handles flipping of the property.
    /// </param>
    /// <seealso cref="FlipChildren"/>
    /// <seealso cref="UnregisterProperty"/>
    {$Endregion}
    Class Procedure RegisterProperty(PropType : PTypeInfo; FlipFunc : TPropertyFlipFunc); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Unregisters a callback function that was responsible for updating a particular
    /// property type when the owner object was flipped.
    /// </summary>
    /// <param name="PropType">
    /// The type information of the property that the handler was registered for.
    /// </param>
    /// <seealso cref="RegisterProperty"/>
    {$Endregion}
    Class Procedure UnregisterProperty(PropType : PTypeInfo); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Horizontally flips position of child controls of a specified control.
    /// </summary>
    /// <remarks>
    /// When <see cref="ParentBidiMode"/> property of a child control is <see langword="true"/>,
    /// this function also flips the content of the child control and updates its direction-dependent
    /// properties.
    /// </remarks>
    /// <param name="Control">
    /// The control to flip its children.
    /// </param>
    /// <seealso cref="RegisterProperty"/>
    {$Endregion}
    Class Procedure FlipChildren(Control : TWinControl); Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Swaps Left and Right properties of a specified <see cref="TMargins"/> object.
    /// </summary>
    /// <param name="Margins">
    /// The <see cref="TMargins"/> object that should be flipped.
    /// </param>
    {$Endregion}
    Class Procedure FlipMargins(Margins : TMargins); Inline; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Toggles akLeft and akRight members of a specified <see cref="TAnchors"/>
    /// value if it has one and only one of these members.
    /// </summary>
    /// <param name="Anchors">
    /// The <see cref="TAnchors"/> value that should be flipped.
    /// </param>
    /// <returns>
    /// The new <see cref="TAnchors"/> value.
    /// </returns>
    {$Endregion}
    Class Function FlipAnchors(Anchors : TAnchors) : TAnchors; Inline; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Changes alLeft and alRight values of a specified <see cref="TAlign"/> value
    /// respectively to alRight and alLeft if the <see cref="TAlign"/> value is one
    /// of these two values.
    /// </summary>
    /// <param name="Align">
    /// The <see cref="TAlign"/> value that should be flipped.
    /// </param>
    /// <returns>
    /// The new <see cref="TAlign"/> value.
    /// </returns>
    {$Endregion}
    Class Function FlipAlign(Align : TAlign) : TAlign; Inline; Static;
    {$Region 'xmldoc'}
    /// <summary>
    /// Changes taLeftJustify and taRightJustify values of a specified
    /// <see cref="TAlignment"/> value respectively to taRightJustify and
    /// taLeftJustify if the <see cref="TAlignment"/> value is one of these two
    /// values.
    /// </summary>
    /// <param name="Alignment">
    /// The <see cref="TAlignment"/> value that should be flipped.
    /// </param>
    /// <returns>
    /// The new <see cref="TAlignment"/> value.
    /// </returns>
    {$Endregion}
    Class Function FlipAlignment(Alignment : TAlignment) : TAlignment; Inline; Static;
  End;

Implementation

 Uses
  Types, ComCtrls, CommCtrl, Buttons;

 Type
   TControlHack = Class(TControl);

    TWinControlHack = Class(TWinControl);

  { BiDi }

    Class Procedure BiDi.FlipChildren(Control : TWinControl);

   Var
    ChildControl : TControl;
    i            : Integer;
    ParentWidth  : Integer;

  Begin
   Control.DisableAlign;
   Try
    ParentWidth := Control.ClientWidth;
    For i       := 0 To Control.ControlCount - 1 Do
     Begin
      ChildControl := Control.Controls[i];
      With TControlHack(ChildControl) Do
       Begin
        Left := ParentWidth - Width - Left;
        If ParentBiDiMode Then
         Begin
          FlipProperties(ChildControl);
          If ChildControl Is TWinControl Then
           Begin
            FlipCommonControl(TWinControl(ChildControl));
            If TWinControl(ChildControl).ControlCount <> 0 Then
             FlipChildren(TWinControl(ChildControl));
           End;
         End;
        Perform(CM_ALLCHILDRENFLIPPED, 0, 0);
        FlipMargins(Margins);
        Align   := FlipAlign(Align);
        Anchors := FlipAnchors(Anchors);
       End;
     End;
   Finally
    Control.EnableAlign;
   End;

 End;

   Class Procedure BiDi.FlipCommonControl(Control : TWinControl);

  Var
   i       : Integer;
   hHeader : hWnd;

 Begin
  If Control Is TCustomTabControl Then
   Begin
    {$IFDEF COMPILER2010_UP}
    // Just adjust ExStyle of the window to mirror its layout.
    UpdateLayout(Control.Handle, Control.BiDiMode);
    {$ENDIF}
   End
  Else If Control Is TCustomTreeView Then
   Begin
    // Just adjust ExStyle of the window to mirror its layout.
    UpdateLayout(Control.Handle, Control.BiDiMode);
   End
  Else If Control Is TCustomListView Then
   Begin
    // Adjust ExStyle of the window to mirror its layout.
    UpdateLayout(Control.Handle, Control.BiDiMode);
    // If the ListView has a header, update its ExStyle too.
    hHeader := ListView_GetHeader(Control.Handle);
    If hHeader <> 0 Then
     UpdateLayout(hHeader, Control.BiDiMode);
    // Because the layout is mirrored, there is no need to flip alignment of
    // list columns. So, flip them back to original.
    With TListView(Control) Do
     Begin
      Columns.BeginUpdate;
      For i                 := 0 To Columns.Count - 1 Do
       Columns[i].Alignment := FlipAlignment(Columns[i].Alignment);
      Columns.EndUpdate;
     End;
   End
  Else If Control Is TCustomStatusBar Then
   Begin
    If Not Control.HandleAllocated And (Control.BiDiMode <> bdLeftToRight) Then
     Begin
      // If the control's BiDiMode is bdRightToLeft and the control's handle is
      // not allocated yet, caption of the panels render in opposite direction.
      // This needs a workaround!
     End;
    // Adjust ExStyle of the window to mirror its layout.
    UpdateLayout(Control.Handle, Control.BiDiMode);
    // Because the layout is mirrored, there is no need to flip alignment of
    // status panels. So, flip them back to original.
    With TCustomStatusBar(Control) Do
     Begin
      Panels.BeginUpdate;
      For i                := 0 To Panels.Count - 1 Do
       Panels[i].Alignment := FlipAlignment(Panels[i].Alignment);
      Panels.EndUpdate;
     End;
   End
  Else If Control Is TCustomHeaderControl Then
   Begin
    If Not Control.HandleAllocated And (Control.BiDiMode <> bdLeftToRight) Then
     Begin
      // If the control's BiDiMode is bdRightToLeft and the control's handle is
      // not allocated yet, caption of the sections render in opposite direction.
      // This is a workaround!
      Control.BiDiMode := bdLeftToRight;
      Control.HandleNeeded;
      TControlHack(Control).ParentBiDiMode := True;
     End;
    // Adjust ExStyle of the window to mirror its layout.
    UpdateLayout(Control.Handle, Control.BiDiMode);
    // Because the layout is mirrored, there is no need to flip alignment of
    // header sections. So, flip them back to original.
    With TCustomHeaderControl(Control) Do
     Begin
      Sections.BeginUpdate;
      For i                  := 0 To Sections.Count - 1 Do
       Sections[i].Alignment := FlipAlignment(Sections[i].Alignment);
      Sections.EndUpdate;
     End;
   End;

 End;

   Class Procedure BiDi.UpdateLayout(hWnd : hWnd; BiDiMode : TBiDiMode);

  Const
   RTLOffBits = WS_EX_RIGHT Or WS_EX_LEFTSCROLLBAR Or WS_EX_RTLREADING;
   RTLOnBits  = WS_EX_LAYOUTRTL Or WS_EX_NOINHERITLAYOUT;

  Var
   ExStyle : Integer;

 Begin
  ExStyle := GetWindowLong(hWnd, GWL_EXSTYLE);
  If BiDiMode = bdRightToLeft Then
   ExStyle := (ExStyle And Not RTLOffBits) Or RTLOnBits
  Else
   ExStyle := ExStyle And Not RTLOnBits;
  SetWindowLong(hWnd, GWL_EXSTYLE, ExStyle);

 End;

   Class Procedure BiDi.FlipMargins(Margins : TMargins);

  Var
   t : Integer;

 Begin
  t             := Margins.Left;
  Margins.Left  := Margins.Right;
  Margins.Right := t;

 End;

   Class Function BiDi.FlipAnchors(Anchors : TAnchors) : TAnchors;

 Begin
  If (akLeft In Anchors) Xor (akRight In Anchors) Then
   Anchors := (Anchors - [akLeft, akRight]) + ([akLeft, akRight] - Anchors);
  Result   := Anchors;

 End;

   Class Function BiDi.FlipAlign(Align : TAlign) : TAlign;

 Begin
  If Align = alLeft Then
   Align := alRight
  Else If Align = alRight Then
   Align := alLeft;
  Result := Align;

 End;

   Class Function BiDi.FlipAlignment(Alignment : TAlignment) : TAlignment;

 Begin
  If Alignment = taLeftJustify Then
   Alignment := taRightJustify
  Else If Alignment = taRightJustify Then
   Alignment := taLeftJustify;
  Result     := Alignment;

 End;

   Class Procedure BiDi.RegisterProperty(PropType : PTypeInfo; FlipFunc : TPropertyFlipFunc);

 Begin
  If Assigned(FlipFunc) Then
   Begin
    If Not Assigned(PropFlipFuncs) Then
     PropFlipFuncs := TKeyLookup<PTypeInfo, TPropertyFlipFunc>.Create(8);
    PropFlipFuncs.AddOrUpdate(PropType, @FlipFunc);
   End;

 End;

   Class Procedure BiDi.UnregisterProperty(PropType : PTypeInfo);

 Begin
  If Assigned(PropFlipFuncs) Then
   PropFlipFuncs.Remove(PropType);

 End;

   Class Procedure BiDi.FlipProperties(Instance : TObject);

  Var
   Count    : Integer;
   i        : Integer;
   PropList : PPropList;
   PropInfo : PPropInfo;
   FlipFunc : TPropertyFlipFunc;

 Begin
  If Assigned(PropFlipFuncs) Then
   Begin
    Count := GetPropList(Instance, PropList);
    If Count <> 0 Then
     Try
      For i := 0 To Count - 1 Do
       Begin
        PropInfo := PropList[i];
        If PropFlipFuncs.Retrieve(PropInfo^.PropType^, FlipFunc) Then
         FlipFunc(Instance, PropInfo);
       End;
     Finally
      FreeMem(PropList);
     End;
   End;

End;

  Class Procedure BiDi.Cleanup;

Begin
 If Assigned(PropFlipFuncs) Then
  FreeAndNil(PropFlipFuncs);

End;

{ Custom Property Flip Functions }

 Procedure PropFlipper_ButtonLayout(Instance : TObject; Prop : PPropInfo);
  Var
   EnumName : String;
  Begin
   EnumName := GetEnumProp(Instance, Prop);
   If EnumName = 'blGlyphLeft' Then
    SetEnumProp(Instance, Prop, 'blGlyphRight')
   Else If EnumName = 'blGlyphRight' Then
    SetEnumProp(Instance, Prop, 'blGlyphLeft');
  End;

 Procedure PropFlipper_Padding(Instance : TObject; Prop : PPropInfo);
  Begin
   BiDi.FlipMargins(TPadding(GetObjectProp(Instance, Prop)));
  End;

Initialization
 BiDi.RegisterProperty(TypeInfo(TButtonLayout), @PropFlipper_ButtonLayout);
 BiDi.RegisterProperty(TypeInfo(TPadding), @PropFlipper_Padding);

Finalization
 BiDi.Cleanup;

End.
