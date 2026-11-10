{------------------------------------------------------------------------------}
{                                                                              }
{  i18n Package                                                                }
{  Internationalization and Localization for Delphi                            }
{                                                                              }
{ Copyright(c) Kambiz Khojasteh                                              }
{  https://github.com/khojasteh/i18n                                           }
{                                                                              }
{------------------------------------------------------------------------------}

/// <summary>
/// This unit implements functions to get or set the text of an active Delphi
/// IDE's editor.
/// </summary>
/// <remarks>
/// This unit cannot be referenced in the runtime packages.
/// </remarks>
Unit i18nIDE;

{$I DELPHIAREA.INC}

Interface

 Uses
  SysUtils, Classes, Types, ToolsAPI;

{$Region 'xmldoc'}
/// <summary>
/// Gets the text inside the active Delphi IDE's code editor.
/// </summary>
/// <param name="Text">
/// Receives the text being edited in the active code editor.
/// </param>
/// <returns>
/// Returns <see langword="true"/> if there is an open code editor in Delphi
/// IDE, otherwise returns <see langword="false"/>.
/// </returns>
/// <seealso cref="ideSetActiveEditorText"/>
{$Endregion}

 Function ideGetActiveEditorText(Out Text : String) : Boolean;
 {$Region 'xmldoc'}
 /// <summary>
 /// Replaces the text inside the active Delphi IDE's code editor. The user can
 /// undo changes made by this function.
 /// </summary>
 /// <param name="Text">
 /// The new text of the active code editor.
 /// </param>
 /// <returns>
 /// Returns <see langword="true"/> if there is an open code editor in Delphi
 /// IDE and it is not read-only, otherwise returns <see langword="false"/>.
 /// </returns>
 /// <seealso cref="ideGetActiveEditorText"/>
 {$Endregion}
 Function ideSetActiveEditorText(Const Text : String) : Boolean;

Implementation

{ Helper Functions }

 Function ideGetActiveSourceEditor : IOTASourceEditor;
  Var
   ModuleServices : IOTAModuleServices;
   Module         : IOTAModule;
   EditorServices : IOTAEditorServices;
   EditBuffer     : IOTAEditBuffer;
   Editor         : IOTAEditor;
   SourceEditor   : IOTASourceEditor;
   FileName       : String;
   i              : Integer;
  Begin
   Result         := Nil;
   ModuleServices := BorlandIDEServices As IOTAModuleServices;
   EditorServices := (BorlandIDEServices As IOTAEditorServices);
   If (ModuleServices <> Nil) And (EditorServices <> Nil) Then
    Begin
     Module     := ModuleServices.CurrentModule;
     EditBuffer := EditorServices.TopBuffer;
     If (Module <> Nil) And (EditBuffer <> Nil) Then
      Begin
       FileName := EditBuffer.FileName;
       For i    := 0 To Module.GetModuleFileCount - 1 Do
        Begin
         Editor := Module.GetModuleFileEditor(i);
         If Supports(Editor, IOTASourceEditor, SourceEditor) And (SourceEditor <> Nil) And
         ((FileName = '') Or SameFileName(SourceEditor.FileName, FileName)) Then
          Begin
           Result := SourceEditor;
           Exit;
          End;
        End;
      End;
    End;
  End;

 Function ideGetEditorText(Reader : IOTAEditReader) : String;
  Const
   BufferSize = 10 * 1024;
  Var
   Stream         : TStringStream;
   Buffer         : PAnsiChar;
   TotalBytesRead : Integer;
   BytesRead      : Integer;
  Begin
   Stream := TStringStream.Create('', TEncoding.UTF8);
   Try
    GetMem(Buffer, BufferSize);
    Try
     TotalBytesRead := 0;
     BytesRead      := Reader.GetText(TotalBytesRead, Buffer, BufferSize);
     While BytesRead <> 0 Do
      Begin
       Stream.Write(Buffer^, BytesRead);
       Inc(TotalBytesRead, BytesRead);
       BytesRead := Reader.GetText(TotalBytesRead, Buffer, BufferSize);
      End;
    Finally
     FreeMem(Buffer);
    End;
    Result := Stream.DataString;
   Finally
    Stream.Free;
   End;
  End;

 Procedure ideSetEditorText(Writer : IOTAEditWriter; Const Text : String);
  Var
   Buffer : AnsiString;
  Begin
   Buffer := UTF8Encode(Text);
   Writer.CopyTo(0);
   Writer.DeleteTo(MaxInt);
   Writer.Insert(PAnsiChar(Buffer));
  End;

 Function ideGetActiveEditorText(Out Text : String) : Boolean;
  Var
   SourceEditor : IOTASourceEditor;
   EditReader   : IOTAEditReader;
  Begin
   Result       := False;
   SourceEditor := ideGetActiveSourceEditor;
   If (SourceEditor <> Nil) And (SourceEditor.EditViewCount > 0) Then
    Begin
     EditReader := SourceEditor.CreateReader;
     Text       := ideGetEditorText(EditReader);
     Result     := True;
    End;
  End;

 Function ideSetActiveEditorText(Const Text : String) : Boolean;
  Var
   SourceEditor : IOTASourceEditor;
   EditWriter   : IOTAEditWriter;
  Begin
   Result       := False;
   SourceEditor := ideGetActiveSourceEditor;
   If (SourceEditor <> Nil) And (SourceEditor.EditViewCount > 0) Then
    Begin
     EditWriter := SourceEditor.CreateUndoableWriter;
     ideSetEditorText(EditWriter, Text);
     Result := True;
    End;
  End;

End.
