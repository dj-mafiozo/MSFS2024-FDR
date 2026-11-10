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
/// This unit implements components for connecting to the Google online services
/// including the Google online translator.
/// </summary>
Unit i18nGoogle;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Classes, SysUtils, Types, i18nHTTP, i18nJSON, i18nCore;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// EGoogleServiceError is the exception class for problems that occur while
  /// sending a request to a Google service.
  /// </summary>
  /// <remarks>
  /// EGoogleServiceError represents exceptions that occur when trying to execute
  /// a Google service request. These exceptions include:
  /// <list type="bullet">
  ///   <item>Attempts to send an invalid request to a Google service.</item>
  ///   <item>Failure to connect to the server of a Google service.</item>
  /// </list>
  /// </remarks>
  /// <seealso cref="TCustomGoogleService"/>
  {$Endregion}
  EGoogleServiceError = Class(Exception)
   Private
    fStatusCode : Integer;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of EGoogleServiceError exception class with a
    /// specified error message and HTTP status code.
    /// </summary>
    /// <param name="Msg">
    /// The error message that explains the reason for the exception.
    /// </param>
    /// <param name="AStatusCode">
    /// The HTTP status code of the failed request.
    /// </param>
    {$Endregion}
    Constructor Create(Const Msg : String; AStatusCode : Integer = 0);
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the HTTP status code of the failed request, or zero if not
    /// applicable.
    /// </summary>
    {$Endregion}
    Property StatusCode : Integer Read fStatusCode;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomGoogleService is the base class for components that connect to an
/// online Google service.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomGoogleService as a base class when defining components that
/// need to connect to an online Google service.
/// </para>
/// <para>
/// TCustomGoogleService has properties and methods to facilitate sending the
/// requests to and retrieving the results from the Google services.
/// </para>
/// </remarks>
{$Endregion}

    TCustomGoogleService = Class Abstract(TCustomHTTP)
   Private
    fAPIKey : String;
    fUserIP : String;
    Function ValidateResponse(Response : TJSONValue; Out ErrorText : String) : Boolean;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Embeds <see cref="APIKey"/> and <see cref="UserIP"/> into a specified URL.
    /// </summary>
    /// <param name="URL">
    /// The URL of the request.
    /// </param>
    /// <returns>
    /// The URL that has values of <see cref="APIKey"/> and <see cref="UserIP"/>
    /// as arguments.
    /// </returns>
    {$Endregion}
    Function Personalize(Const URL : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// <para>
    /// Sends a specified request to the Google's API server (using HTTP POST method)
    /// and retrieves its result as a <see cref="TJSONValue"/> object.
    /// </para>
    /// <para>
    /// NOTE: The caller is responsible for releasing the returned <see cref="TJSONValue"/> object.
    /// </para>
    /// </summary>
    /// <param name="URL">
    /// The URL of the request.
    /// </param>
    /// <param name="JsonData">
    /// The JSON data to send in the POST request.
    /// </param>
    /// <returns>
    /// Returns a <see cref="TJSONValue"/> object that stores the result of the request.
    /// </returns>
    /// <exception cref="EGoogleServiceError">
    /// Raised when the request fails.
    /// </exception>
    {$Endregion}
    Function SendRequest(Const URL : String; Const JsonData : String) : TJSONValue;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the Google API key.
    /// </summary>
    {$Endregion}
    Property APIKey : String Read fAPIKey Write fAPIKey;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the IP address of the end-user on whose behalf the requests
    /// are being made.
    /// </summary>
    {$Endregion}
    Property UserIP : String Read fUserIP Write fUserIP;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies different types of text for the Google
/// translator.
/// </summary>
{$Endregion}

  TTextFormat = (
  {$Region 'xmldoc'}
  /// The text is not formatted.
  {$Endregion}
  txtPlain,
  {$Region 'xmldoc'}
  /// The text is HTML formatted.
  {$Endregion}
  txtHTML
  );

{$Region 'xmldoc'}
/// <summary>
/// TCustomGoogleTranslator is the base class for components that connect to
/// the Google translator.
/// </summary>
/// <remarks>
/// <para>
/// Use TCustomGoogleTranslator as a base class when defining components that
/// need to connect to the Google translator.
/// </para>
///
/// <para>
/// TCustomGoogleTranslator has properties and methods to facilitate automatic
/// translation of text using the Google translator.
/// </para>
/// </remarks>
{$Endregion}

  TCustomGoogleTranslator = Class(TCustomGoogleService)
   Private
    fSourceLang         : String;
    fTargetLang         : String;
    fDetectedSourceLang : String;
    fTextFormat         : TTextFormat;
    Procedure SetSourceLang(Const Value : String);
    Procedure SetTargetLang(Const Value : String);
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the URL that is used to send the translation request.
    /// text string.
    /// </summary>
    /// <returns>
    /// Returns the translation request URL for the Google translator.
    /// </returns>
    {$Endregion}
    Function GetRequestURL : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Returns the JSON payload that is used to send the translation request.
    /// </summary>
    /// <param name="SourceText">
    /// The source text to translate.
    /// </param>
    /// <returns>
    /// Returns the JSON payload for the translation request.
    /// </returns>
    {$Endregion}
    Function GetRequestJsonPayload(Const SourceText : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the language of the source text.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The value of SourceLang property should be one of the language codes
    /// listed in <see cref="GoogleLanguages"/> global variable.
    /// </para>
    ///
    /// <para>
    /// If a language is not specified, the Google translator will attempt to
    /// identify the source language automatically.
    /// </para>
    /// </remarks>
    /// <seealso cref="TargetLang"/>
    /// <seealso cref="CultureToGoogleLang"/>
    /// <seealso cref="GoogleLangToCulture"/>
    {$Endregion}
    Property SourceLang : String Read fSourceLang Write SetSourceLang;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the language to translate the source text into.
    /// </summary>
    /// <remarks>
    /// The value of TargetLang property should be one of the language codes
    /// listed in <see cref="GoogleLanguages"/> global variable.
    /// </remarks>
    /// <seealso cref="SourceLang"/>
    /// <seealso cref="CultureToGoogleLang"/>
    /// <seealso cref="GoogleLangToCulture"/>
    {$Endregion}
    Property TargetLang : String Read fTargetLang Write SetTargetLang;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the format of the source text.
    /// </summary>
    {$Endregion}
    Property TextFormat : TTextFormat Read fTextFormat Write fTextFormat Default txtPlain;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Indicates whether a text in the language specified by <see cref="SourceLang"/>
    /// can be translated into the language specified by <see cref="TargetLang"/>.
    /// </summary>
    /// <returns>
    /// Returns <see langword="true"/> if <see cref="TargetLang"/> is specified, and
    /// <see cref="SourceLang"/> and <see cref="TargetLang"/> are different languages.</returns>
    /// <seealso cref="Translate"/>
    {$Endregion}
    Function CanTranslate : Boolean; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Translates a specified text from the source language specified by the
    /// <see cref="SourceLang"/> property into the language specified by the
    /// <see cref="TargetLang"/> property.
    /// </summary>
    /// <param name="Text">
    /// The source text to translate.
    /// </param>
    /// <returns>
    /// Returns the translated text.
    /// </returns>
    /// <exception cref="EGoogleServiceError">
    /// Occurs if the method fails to translate the source text.
    /// </exception>
    {$Endregion}
    Function Translate(Const Text : String) : String;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets the language of the source text, which is automatically detected
    /// by the Google translator.
    /// </summary>
    /// <remarks>
    /// The value of DetectedSourceLang property will be one of the language
    /// codes listed in <see cref="GoogleLanguages"/> global variable.
    /// </remarks>
    /// <seealso cref="CultureToGoogleLang"/>
    /// <seealso cref="GoogleLangToCulture"/>
    {$Endregion}
    Property DetectedSourceLang : String Read fDetectedSourceLang;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TGoogleTranslator is an interface to the Google translator service for
/// automatic text translation.
/// </summary>
/// <remarks>
/// <para>
/// Use TGoogleTranslator to translate text from one language to another using
/// the Google translator.
/// </para>
///
/// <para>
/// TGoogleTranslator publishes many of the properties, events, and methods of
/// <see cref="TCustomGoogleTranslator"/>, but does not introduce any new behavior.
/// </para>
/// </remarks>
/// <group name="Components"/>
{$Endregion}
{$IFDEF COMPILER_XE2_UP}

  [ComponentPlatformsAttribute(pidWin32 Or pidWin64)]
  {$ENDIF}
  TGoogleTranslator = Class(TCustomGoogleTranslator)
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the proxy configuration.
    /// </summary>
    {$Endregion}
    Property Proxy;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the language of the source text.
    /// </summary>
    /// <remarks>
    /// <para>
    /// The value of SourceLang property should be one of the language codes
    /// listed in <see cref="GoogleLanguages"/> global variable.
    /// </para>
    ///
    /// <para>
    /// If a language is not specified, the Google translator will attempt to
    /// identify the source language automatically.
    /// </para>
    /// </remarks>
    /// <seealso cref="TargetLang"/>
    /// <seealso cref="CultureToGoogleLang"/>
    /// <seealso cref="GoogleLangToCulture"/>
    {$Endregion}
    Property SourceLang;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the language to translate the source text into.
    /// </summary>
    /// <remarks>
    /// The value of TargetLang property should be one of the language codes
    /// listed in <see cref="GoogleLanguages"/> global variable.
    /// </remarks>
    /// <seealso cref="SourceLang"/>
    /// <seealso cref="CultureToGoogleLang"/>
    /// <seealso cref="GoogleLangToCulture"/>
    {$Endregion}
    Property TargetLang;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the format of the source text.
    /// </summary>
    {$Endregion}
    Property TextFormat;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the value of the <c>User-Agent</c> header of the HTTP request
    /// message.
    /// </summary>
    {$Endregion}
    Property UserAgent;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the Google API key.
    /// </summary>
    {$Endregion}
    Property APIKey;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the IP address of the end-user on whose behalf the requests
    /// are being made.
    /// </summary>
    {$Endregion}
    Property UserIP;
  End;

{$Region 'xmldoc'}
/// <summary>
/// Returns the corresponding Google language code of a specified
/// <see cref="TCultureInfo"/> object.
/// </summary>
/// <param name="Culture">
/// The <see cref="TCultureInfo"/> object.
/// </param>
/// <returns>
/// The language code of the specified <see cref="TCultureInfo"/> object, which is
/// recognizable by the Google language services.
/// </returns>
/// <seealso cref="GoogleLangToCulture"/>
{$Endregion}

 Function CultureToGoogleLang(Culture : TCultureInfo) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// <para>
 /// Returns the corresponding <see cref="TCultureInfo"/> object of a specified
 /// Google language code.
 /// </para>
 ///
 /// <para>
 /// NOTE: Some Google language codes do not have the corresponding
 /// <see cref="TCultureInfo"/> object.
 /// </para>
 /// </summary>
 /// <param name="Lang">
 /// The Google language code.
 /// </param>
 /// <returns>
 /// Returns the <see cref="TCultureInfo"/> object of the specified Google language
 /// code or <see langword="nil"/> if the Google language code does not have a
 /// corresponding <see cref="TCultureInfo"/> object.
 /// </returns>
 /// <seealso cref="CultureToGoogleLang"/>
 {$Endregion}
 Function GoogleLangToCulture(Const Lang : String) : TCultureInfo;

 Const
  {$Region 'xmldoc'}
  /// <summary>
  /// Lists the language codes, which are recognizable by the Google language services.
  /// </summary>
  {$Endregion}
  GoogleLanguages : Array[1..107] Of String = (
  'af', 'sq', 'am', 'ar', 'hy', 'az', 'eu', 'be', 'bn', 'bh', 'br', 'bg',
  'my', 'ca', 'chr', 'zh', 'zh-CN', 'zh-TW', 'co', 'hr', 'cs', 'da', 'dv',
  'nl', 'en', 'eo', 'et', 'fo', 'tl', 'fi', 'fr', 'fy', 'gl', 'ka', 'de',
  'el', 'gu', 'ht', 'iw', 'hi', 'hu', 'is', 'id', 'iu', 'ga', 'it', 'ja',
  'jw', 'kn', 'kk', 'km', 'ko', 'ku', 'ky', 'lo', 'la', 'lv', 'lt', 'lb',
  'mk', 'ms', 'ml', 'mt', 'mi', 'mr', 'mn', 'ne', 'no', 'oc', 'or', 'ps',
  'fa', 'pl', 'pt', 'pt-PT', 'pa', 'qu', 'ro', 'ru', 'sa', 'gd', 'sr', 'sd',
  'si', 'sk', 'sl', 'es', 'su', 'sw', 'sv', 'syr', 'tg', 'ta', 'tt', 'te',
  'th', 'bo', 'to', 'tr', 'uk', 'ur', 'uz', 'ug', 'vi', 'cy', 'yi', 'yo');

Implementation

 Resourcestring
  SHTTPRequestFailed = 'HTTP request failed with status code %d';
  SInvalidJSONResponse = 'Invalid JSON response: %s';

{ EGoogleServiceError }

 Constructor EGoogleServiceError.Create(Const Msg : String; AStatusCode : Integer);
  Begin
   Inherited Create(Msg);
   fStatusCode := AStatusCode;
  End;

{ Helper Functions }

 Function IsGoogleLanguage(Const Lang : String) : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   If Lang <> '' Then
    For i := Low(GoogleLanguages) To High(GoogleLanguages) Do
     If SameText(GoogleLanguages[i], Lang) Then
      Begin
       Result := True;
       Exit;
      End;
  End;

 Function CultureToGoogleLang(Culture : TCultureInfo) : String;
  Var
   i : Integer;
  Begin
   Result := '';
   If Assigned(Culture) Then
    Begin
     For i := High(GoogleLanguages) Downto Low(GoogleLanguages) Do
      If (GoogleLanguages[i] = Culture.Locale) Or
      (GoogleLanguages[i] = Culture.Language2) Then
       Begin
        Result := GoogleLanguages[i];
        Exit;
       End;
    End;
  End;

 Function GoogleLangToCulture(Const Lang : String) : TCultureInfo;
  Begin
   If IsGoogleLanguage(Lang) Then
    Result := CultureOf(Lang, False)
   Else
    Result := Nil;
  End;

{ TCustomGoogleService }

 Function TCustomGoogleService.Personalize(Const URL : String) : String;
  Var
   Delimiter : Char;
  Begin
   If StrPos(PChar(URL), '?') = Nil Then
    Delimiter := '?'
   Else
    Delimiter := '&';
   Result     := URL;
   If APIKey <> '' Then
    Begin
     Result    := Result + Delimiter + 'key=' + EscapeURLArg(APIKey);
     Delimiter := '&';
    End;
   If UserIP <> '' Then
    Result := Result + Delimiter + 'userip=' + EscapeURLArg(UserIP);
  End;

 Function TCustomGoogleService.ValidateResponse(Response : TJSONValue; Out ErrorText : String) : Boolean;
  Var
   v : TJSONValue;
  Begin
   ErrorText := '';
   If Assigned(Response) And (Response Is TJSONValueObject) Then
    Begin
     v := TJSONValueObject(Response).Values['error'];
     If Assigned(v) And (v Is TJSONValueObject) Then
      Begin
       v := TJSONValueObject(v).Values['message'];
       If Assigned(v) And (v Is TJSONValueString) Then
        ErrorText := TJSONValueString(v).Value;
       Result     := False;
      End
     Else
      Result := True;
    End
   Else
    Result := False;
  End;

 Function TCustomGoogleService.SendRequest(Const URL : String; Const JsonData : String) : TJSONValue;
  Var
   ResponseStream : TStringStream;
   StatusCode     : Integer;
   ErrorText      : String;
  Begin
   Result         := Nil;
   ResponseStream := TStringStream.Create('', TEncoding.UTF8, False);
   Try
    StatusCode := HttpRequest(URL, ResponseStream, JsonData, 'application/json');
    If StatusCode <> 200 Then
     Raise EGoogleServiceError.Create(Format(SHTTPRequestFailed, [StatusCode]), StatusCode);

    Try
     Result := DecodeJSON(ResponseStream.DataString);
    Except
     On E : Exception Do
      Raise EGoogleServiceError.Create(Format(SInvalidJSONResponse, [E.Message]), StatusCode);
    End;

    If Not ValidateResponse(Result, ErrorText) Then
     Begin
      FreeAndNil(Result);
      Raise EGoogleServiceError.Create(ErrorText, StatusCode);
     End;
   Finally
    ResponseStream.Free;
   End;
  End;

{ TCustomGoogleTranslator }

 Procedure TCustomGoogleTranslator.SetSourceLang(Const Value : String);
  Begin
   If SourceLang <> Value Then
    Begin
     If IsGoogleLanguage(Value) Then
      fSourceLang := Value
     Else
      fSourceLang := '';
    End;
  End;

 Procedure TCustomGoogleTranslator.SetTargetLang(Const Value : String);
  Begin
   If TargetLang <> Value Then
    Begin
     If IsGoogleLanguage(Value) Then
      fTargetLang := Value
     Else
      fTargetLang := '';
    End;
  End;

 Function TCustomGoogleTranslator.CanTranslate : Boolean;
  Begin
   Result := (APIKey <> '') And (SourceLang <> TargetLang) And (TargetLang <> '');
  End;

 Function TCustomGoogleTranslator.GetRequestURL : String;
  Const
   BaseURL = 'https://translation.googleapis.com/language/translate/v2';
  Begin
   Result := Personalize(BaseURL);
  End;

 Function TCustomGoogleTranslator.GetRequestJsonPayload(Const SourceText : String) : String;
  Var
   Text    : String;
   Payload : TJSONValueObject;
  Begin
   If TextFormat = txtPlain Then
    Text := EncodeHtmlEntities(SourceText)
   Else
    Text   := SourceText;
   Payload := TJSONValueObject.Create;
   Try
    Payload.Values['q'] := TJSONValueString.Create(Text);
    If SourceLang <> '' Then
     Payload.Values['source'] := TJSONValueString.Create(SourceLang);
    Payload.Values['target']  := TJSONValueString.Create(TargetLang);
    If TextFormat = txtHTML Then
     Payload.Values['format'] := TJSONValueString.Create('html')
    Else
     Payload.Values['format'] := TJSONValueString.Create('text');
    Result                    := Payload.JSON;
   Finally
    Payload.Free;
   End;
  End;

 Function TCustomGoogleTranslator.Translate(Const Text : String) : String;
  Var
   RequestURL   : String;
   JsonData     : String;
   Response     : TJSONValue;
   Data         : TJSONValue;
   Translations : TJSONValue;
   Translation  : TJSONValue;
   v            : TJSONValue;
  Begin
   Result := '';
   If Trim(Text) = '' Then
    Exit;

   RequestURL          := GetRequestURL;
   JsonData            := GetRequestJsonPayload(Text);
   Response            := SendRequest(RequestURL, JsonData);
   fDetectedSourceLang := SourceLang;
   Try
    If Response Is TJSONValueObject Then
     Begin
      Data := TJSONValueObject(Response).Values['data'];
      If Assigned(Data) And (Data Is TJSONValueObject) Then
       Begin
        Translations := TJSONValueObject(Data).Values['translations'];
        If Assigned(Translations) And (Translations Is TJSONValueArray) And
        (TJSONValueArray(Translations).Count > 0) Then
         Begin
          Translation := TJSONValueArray(Translations)[0];
          If Assigned(Translation) And (Translation Is TJSONValueObject) Then
           Begin
            v := TJSONValueObject(Translation).Values['detectedSourceLanguage'];
            If Assigned(v) And (v Is TJSONValueString) Then
             fDetectedSourceLang := TJSONValueString(v).Value;
            v                    := TJSONValueObject(Translation).Values['translatedText'];
            If Assigned(v) And (v Is TJSONValueString) Then
             Begin
              Result := TJSONValueString(v).Value;
              If TextFormat = txtPlain Then
               Result := DecodeHtmlEntities(Result);
             End;
           End;
         End;
       End;
     End;
   Finally
    Response.Free;
   End;
  End;

End.
