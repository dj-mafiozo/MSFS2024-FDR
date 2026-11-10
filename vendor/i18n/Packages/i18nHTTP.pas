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
/// This unit implements base classes and components for sending HTTP requests.
/// </summary>
Unit i18nHTTP;

{$I DELPHIAREA.INC}

Interface

 Uses
  Windows, Classes, SysUtils, WinInet;

 Type

  {$Region 'xmldoc'}
  /// <summary>
  /// TURLParts represents the component parts that build a URL.
  /// </summary>
  {$Endregion}
  TURLParts = Record
   {$Region 'xmldoc'}
   /// The value that indicates the Internet protocol scheme.
   {$Endregion}
   Scheme : Word;
   {$Region 'xmldoc'}
   /// The scheme name
   {$Endregion}
   SchemeName : String;
   {$Region 'xmldoc'}
   /// The host name
   {$Endregion}
   HostName : String;
   {$Region 'xmldoc'}
   /// The port number
   {$Endregion}
   Port : Integer;
   {$Region 'xmldoc'}
   /// The user name
   {$Endregion}
   UserName : String;
   {$Region 'xmldoc'}
   /// The password
   {$Endregion}
   Password : String;
   {$Region 'xmldoc'}
   /// The path
   {$Endregion}
   Path : String;
   {$Region 'xmldoc'}
   /// The extra information (for example, <c>?something</c> or <c>#something</c>).
   {$Endregion}
   ExtraInfo : String;
  End;

{$Region 'xmldoc'}
/// <summary>
/// This enumeration type identifies the access types for a TCP/IP network
/// connection.
/// </summary>
{$Endregion}

  TProxyType = (
  {$Region 'xmldoc'}
  /// <summary>
  /// Resolves all host names locally.
  /// </summary>
  {$Endregion}
  ptDirect,
  {$Region 'xmldoc'}
  /// <summary>
  /// Retrieves the proxy or direct configuration from the registry.
  /// </summary>
  {$Endregion}
  ptAuto,
  {$Region 'xmldoc'}
  /// <summary>
  /// Passes requests to the specified proxy server unless a proxy bypass
  /// list is supplied and the name to be resolved bypasses the proxy. In
  /// this case, resolves the name locally.
  /// </summary>
  {$Endregion}
  ptManual
  );

{$Region 'xmldoc'}
/// <summary>
/// TProxyConfig provides proxy configuration for a TCP/IP network connection.
/// </summary>
{$Endregion}

  TProxyConfig = Class(TPersistent)
   Private
    fType     : TProxyType;
    fHost     : String;
    fPort     : Word;
    fBypass   : TStrings;
    fOnChange : TNotifyEvent;
    Procedure SetType(Value : TProxyType);
    Procedure SetHost(Const Value : String);
    Procedure SetPort(Value : Word);
    Procedure SetBypass(Value : TStrings);
    Function IsStoredBypass : Boolean;
    Procedure BypassChanged(Sender : TObject);
    Function GetIOType : Cardinal;
    Function GetIOName : PChar;
    Function GetIOBypass : PChar;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Generates an <see cref="OnChange"/> event.
    /// </summary>
    {$Endregion}
    Procedure DoChange; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides the value for the <c>dwAccessType</c> parameter of the InternetOpen
    /// Windows API function.
    /// </summary>
    {$Endregion}
    Property IOType : Cardinal Read GetIOType;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides the value for the <c>lpszProxyName</c> parameter of the InternetOpen
    /// Windows API function.
    /// </summary>
    {$Endregion}
    Property IOName : PChar Read GetIOName;
    {$Region 'xmldoc'}
    /// <summary>
    /// Provides the value for the <c>lpszProxyBypass</c> parameter of the InternetOpen
    /// Windows API function.
    /// </summary>
    {$Endregion}
    Property IOBypass : PChar Read GetIOBypass;
    {$Region 'xmldoc'}
    /// <summary>
    /// Occurs when proxy configuration changes.
    /// </summary>
    {$Endregion}
    Property OnChange : TNotifyEvent Read fOnChange Write fOnChange;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the class.
    /// </summary>
    {$Endregion}
    Constructor Create; Virtual;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Copies the proxy configuration from another object.
    /// </summary>
    /// <param name="Source">
    /// The source object.
    /// </param>
    {$Endregion}
    Procedure Assign(Source : TPersistent); Override;
   Published
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the type of access required.
    /// </summary>
    {$Endregion}
    Property AccessType : TProxyType Read fType Write SetType Default ptAuto;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the host name of the proxy server when <see cref="AccessType"/>
    /// is ptManual.
    /// </summary>
    {$Endregion}
    Property Host : String Read fHost Write SetHost;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the port number of the proxy server when <see cref="AccessType"/>
    /// is ptManual.
    /// </summary>
    {$Endregion}
    Property Port : Word Read fPort Write SetPort Default 0;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the optional list of host names or IP addresses, or both, that
    /// should not be routed through the proxy when <see cref="AccessType"/> is
    /// ptManual. The list can contain wildcards.
    /// </summary>
    {$Endregion}
    Property Bypass : TStrings Read fBypass Write SetBypass Stored IsStoredBypass;
  End;

{$Region 'xmldoc'}
/// <summary>
/// TCustomHTTP is the base class for components that are based on HTTP get or post
/// requests.
/// </summary>
/// <remarks>
/// Use TCustomHTTP as a base class when defining components that need to connect
/// to a network service via HTTP get or post requests.
/// </remarks>
{$Endregion}

    TCustomHTTP = Class Abstract(TComponent)
   Private
    fProxy         : TProxyConfig;
    fUserAgent     : String;
    fReferer       : String;
    hInternet      : hInternet;
    hConnection    : hInternet;
    SessionDetails : TURLParts;
    Procedure SetProxy(Value : TProxyConfig);
    Procedure SetUserAgent(Const Value : String);
    Function IsStoredUserAgent : Boolean;
    Procedure ConfigChanged(Sender : TObject);
    Function PrepareSession(Const Details : TURLParts) : Boolean;
    Procedure UnprepareSession;
   Protected
    {$Region 'xmldoc'}
    /// <summary>
    /// Sends a GET or POST request to a server.
    /// </summary>
    /// <param name="URL">
    /// The URL of the request.
    /// </param>
    /// <param name="Response">
    /// Receives the content of the response from the server.
    /// </param>
    /// <param name="PostData">
    /// The optional data to send to the server. If this parameter is omitted or
    /// an empty string is used, HttpRequest uses the GET method to send the HTTP
    /// request. Otherwise, it uses the POST method.
    /// </param>
    /// <param name="ContentType">
    /// The content type of the POST data. Relevant only if <c>PostData</c> is
    /// provided.
    /// </param>
    /// <returns>
    /// Returns the HTTP status code or zero if the connection is not established
    /// at all.
    /// </returns>
    {$Endregion}
    Function HttpRequest(Const URL : String; Response : TStream; Const PostData : String = ''; Const ContentType : String = '') : Cardinal; Overload;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the proxy configuration.
    /// </summary>
    {$Endregion}
    Property Proxy : TProxyConfig Read fProxy Write SetProxy;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the value of the <c>User-Agent</c> header of the HTTP request
    /// message.
    /// </summary>
    {$Endregion}
    Property UserAgent : String Read fUserAgent Write SetUserAgent Stored IsStoredUserAgent;
    {$Region 'xmldoc'}
    /// <summary>
    /// Gets or sets the value of the <c>Referer</c> header of the HTTP request
    /// message.
    /// </summary>
    {$Endregion}
    Property Referer : String Read fReferer Write fReferer;
   Public
    {$Region 'xmldoc'}
    /// <summary>
    /// Creates an instance of the component.
    /// </summary>
    /// <param name="AOwner">
    /// The component that owns this instance.
    /// </param>
    {$Endregion}
    Constructor Create(AOwner : TComponent); Override;
    {$Region 'xmldoc'}
    /// <summary>
    /// Destroys the component's instance and releases its allocated memory.
    /// </summary>
    {$Endregion}
    Destructor Destroy; Override;
  End;

{$Region 'xmldoc'}
/// <summary>
/// Converts the special HTML characters to HTML entities.
/// </summary>
/// <param name="Str">
/// The string containing the HTML special characters.
/// </param>
/// <returns>
/// The string that is safe to render as HTML text.
/// </returns>
/// <seealso cref="DecodeHtmlEntities"/>
{$Endregion}

 Function EncodeHtmlEntities(Const Str : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Converts the HTML entities to normal characters.
 /// </summary>
 /// <param name="Str">
 /// The string containing the HTML entities.
 /// </param>
 /// <returns>
 /// The string that is safe to render as plain text.
 /// </returns>
 /// <seealso cref="EncodeHtmlEntities"/>
 {$Endregion}
 Function DecodeHtmlEntities(Const Str : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Escapes a string value, so that it can be used safely in a URL as an argument
 /// value.
 /// </summary>
 /// <param name="Str">
 /// The string to escape.
 /// </param>
 /// <returns>
 /// The escaped string.
 /// </returns>
 {$Endregion}
 Function EscapeURLArg(Const Str : String) : String;

 {$Region 'xmldoc'}
 /// <summary>
 /// Disassembles a URL into its component parts.
 /// </summary>
 /// <param name="URL">
 /// The URL to be cracked.
 /// </param>
 /// <param name="Components">
 /// The component parts of the cracked URL.
 /// </param>
 {$Endregion}
 Procedure CrackURL(Const URL : String; Out Components : TURLParts);

Implementation

 Const
  DefaultProxyBypass = '<local>';
  DefaultUserAgent   = 'Mozila/5.0';

 Const
  CodedChars : Array[1..60] Of WideString = (
  'nbsp', 'copy', 'reg', 'trade', 'sup1', 'sup2', 'sup3', 'quot', 'amp',
  'lt', 'gt', 'ndash', 'mdash', 'lsquo', 'rsquo', 'ldquo', 'rdquo',
  'bull', 'dagger', 'Dagger', 'prime', 'Prime', 'lsaquo', 'rsaquo',
  'tilde', 'circ', 'spades', 'clubs', 'hearts', 'diams', 'loz', 'larr',
  'rarr', 'uarr', 'darr', 'harr', 'not', 'frac14', 'frac12', 'frac34',
  'plusmn', 'laquo', 'raquo', 'deg', 'ordf', 'ordm', 'iexcl', 'iquest',
  'euro', 'cent', 'pound', 'yen', 'curren', 'sect', 'para', 'macr',
  'middot', 'micro', 'times', 'divide');
  SpecialChars : Array[1..60] Of WideChar = (
  #$00A0, #$00A9, #$00AE, #$2122, #$00B9, #$00B2, #$00B3, #$0022, #$0026, #$003C,
  #$003E, #$2013, #$2014, #$2018, #$2019, #$201C, #$201D, #$2022, #$2020, #$2021,
  #$2030, #$2031, #$2039, #$203A, #$02DC, #$02C6, #$2660, #$2663, #$2665, #$2666,
  #$25CA, #$2190, #$2192, #$2191, #$2193, #$2194, #$00AC, #$00BC, #$00BD, #$00BE,
  #$00B1, #$00AB, #$00BB, #$00B0, #$00AB, #$00C6, #$00A1, #$00BF, #$20AC, #$00A2,
  #$00A3, #$00A5, #$00A4, #$00A7, #$00B6, #$00AF, #$00B7, #$00B5, #$00D7, #$00F7);

{ Helper Functions }

 Function EncodeWebChar(c : Char; Out Code : String) : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   For i  := Low(SpecialChars) To High(SpecialChars) Do
    If SpecialChars[i] = c Then
     Begin
      Code   := CodedChars[i];
      Result := True;
      Exit;
     End;
  End;

 Function DecodeWebChar(Const Code : String; Out c : Char) : Boolean;
  Var
   i : Integer;
  Begin
   Result := False;
   If Code <> '' Then
    Begin
     If Code[1] = '#' Then
      Begin
       c     := #0;
       For i := 2 To Length(Code) Do
        If (Code[i] >= '0') And (Code[i] <= '9') Then
         c := Char(Ord(c) * 10 + Ord(Code[i]) - Ord('0'))
        Else
         Exit;
       Result := (c <> #0);
      End
     Else
      For i := Low(CodedChars) To High(CodedChars) Do
       If CodedChars[i] = Code Then
        Begin
         c      := SpecialChars[i];
         Result := True;
         Exit;
        End;
    End;
  End;

 Function DecodeHtmlEntities(Const Str : String) : String;
  Var
   p    : PChar;
   s    : PChar;
   e    : PChar;
   Code : String;
  Begin
   SetString(Result, Nil, Length(Str));
   s := PChar(Str);
   p := PChar(Result);
   While s^ <> #0 Do
    Begin
     p^ := s^;
     If s^ = '&' Then
      Begin
       e := s + 1;
       While (e^ <> #0) And (e^ <> ';') Do
        Inc(e);
       If e^ = ';' Then
        Begin
         SetString(Code, s + 1, e - s - 1);
         If DecodeWebChar(Code, p^) Then
          s := e;
        End;
      End;
     Inc(p);
     Inc(s);
    End;
   SetLength(Result, p - PChar(Result));
  End;

 Function EncodeHtmlEntities(Const Str : String) : String;
  Var
   Code : String;
   p    : PChar;
   s    : PChar;
   i    : Integer;
  Begin
   SetString(Result, Nil, 8 * Length(Str));
   s := PChar(Str);
   p := PChar(Result);
   While s^ <> #0 Do
    Begin
     p^ := s^;
     If EncodeWebChar(s^, Code) Then
      Begin
       p^ := '&';
       Inc(p);
       For i := 1 To Length(Code) Do
        Begin
         p^ := Code[i];
         Inc(p);
        End;
       p^ := ';';
      End;
     Inc(p);
     Inc(s);
    End;
   SetLength(Result, p - PChar(Result));
  End;

 Function EscapeURLArg(Const Str : String) : String;
  Var
   p : PAnsiChar;
  Begin
   Result := '';
   p      := PAnsiChar(UTF8Encode(Str));
   While p^ <> #0 Do
    Begin
     If Not CharInSet(p^, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', '_']) Then
      Result := Result + '%' + IntToHex(Ord(p^), 2)
     Else
      Result := Result + WideChar(p^);
     Inc(p);
    End;
  End;

 Procedure CrackURL(Const URL : String; Out Components : TURLParts);
  Var
   Parts        : TURLComponents;
   CanonicalURL : String;
   Size         : Cardinal;
  Begin
   FillChar(Parts, SizeOf(TURLComponents), 0);
   Parts.dwStructSize := SizeOf(TURLComponents);
   If URL <> '' Then
    Begin
     Size := 3 * Length(URL);
     SetString(CanonicalURL, Nil, Size);
     If Not InternetCanonicalizeUrl(PChar(URL), PChar(CanonicalURL), Size, ICU_NO_META) Then
      Size := 0;
     SetLength(CanonicalURL, Size);
     Parts.dwSchemeLength    := 1;
     Parts.dwUserNameLength  := 1;
     Parts.dwPasswordLength  := 1;
     Parts.dwHostNameLength  := 1;
     Parts.dwURLPathLength   := 1;
     Parts.dwExtraInfoLength := 1;
     InternetCrackUrl(PChar(CanonicalURL), Size, 0, Parts);
    End;
   With Components Do
    Begin
     Scheme := Parts.nScheme;
     SetString(SchemeName, Parts.lpszScheme, Parts.dwSchemeLength);
     SetString(UserName, Parts.lpszUserName, Parts.dwUserNameLength);
     SetString(Password, Parts.lpszPassword, Parts.dwPasswordLength);
     SetString(HostName, Parts.lpszHostName, Parts.dwHostNameLength);
     Port := Parts.nPort;
     SetString(Path, Parts.lpszUrlPath, Parts.dwURLPathLength);
     SetString(ExtraInfo, Parts.lpszExtraInfo, Parts.dwExtraInfoLength);
    End;
  End;

{ TProxyConfig }

 Constructor TProxyConfig.Create;
  Begin
   fType                         := ptAuto;
   fBypass                       := TStringList.Create;
   fBypass.Text                  := DefaultProxyBypass;
   TStringList(fBypass).OnChange := BypassChanged;
  End;

 Destructor TProxyConfig.Destroy;
  Begin
   fBypass.Free;
   Inherited Destroy;
  End;

 Procedure TProxyConfig.Assign(Source : TPersistent);
  Begin
   If Source Is TProxyConfig Then
    Begin
     AccessType := TProxyConfig(Source).AccessType;
     Host       := TProxyConfig(Source).Host;
     Port       := TProxyConfig(Source).Port;
    End
   Else
    Inherited Assign(Source);
  End;

 Function TProxyConfig.GetIOType : Cardinal;
  Begin
   Case AccessType Of
    ptDirect : Result := INTERNET_OPEN_TYPE_DIRECT;
    ptAuto   : Result := INTERNET_OPEN_TYPE_PRECONFIG;
   Else Result := INTERNET_OPEN_TYPE_PROXY;
   End;
  End;

 Function TProxyConfig.GetIOName : PChar;
  Var
   ProxyName : String;
  Begin
   Result := Nil;
   If AccessType = ptManual Then
    Begin
     ProxyName := Trim(Host);
     If ProxyName <> '' Then
      Begin
       If Port <> 0 Then
        ProxyName := ProxyName + ':' + IntToStr(Port);
       Result     := PChar(ProxyName);
      End;
    End;
  End;

 Function TProxyConfig.GetIOBypass : PChar;
  Var
   ProxyBypass : String;
  Begin
   Result := Nil;
   If AccessType = ptManual Then
    Begin
     ProxyBypass := Trim(Bypass.Text);
     If ProxyBypass <> '' Then
      Result := PChar(ProxyBypass);
    End;
  End;

 Procedure TProxyConfig.SetType(Value : TProxyType);
  Begin
   If AccessType <> Value Then
    Begin
     fType := Value;
     DoChange;
    End;
  End;

 Procedure TProxyConfig.SetHost(Const Value : String);
  Begin
   If Host <> Value Then
    Begin
     fHost := Value;
     If AccessType = ptManual Then
      DoChange;
    End;
  End;

 Procedure TProxyConfig.SetPort(Value : Word);
  Begin
   If Port <> Value Then
    Begin
     fPort := Value;
     If AccessType = ptManual Then
      DoChange;
    End;
  End;

 Procedure TProxyConfig.SetBypass(Value : TStrings);
  Begin
   Bypass.Assign(Value);
  End;

 Function TProxyConfig.IsStoredBypass : Boolean;
  Begin
   Result := (Trim(Bypass.Text) <> DefaultProxyBypass);
  End;

 Procedure TProxyConfig.BypassChanged(Sender : TObject);
  Begin
   If AccessType = ptManual Then
    DoChange;
  End;

 Procedure TProxyConfig.DoChange;
  Begin
   If Assigned(OnChange) Then
    OnChange(Self);
  End;

{ TCustomHTTP }

 Constructor TCustomHTTP.Create(AOwner : TComponent);
  Begin
   Inherited Create(AOwner);
   fUserAgent      := DefaultUserAgent;
   fProxy          := TProxyConfig.Create;
   fProxy.OnChange := ConfigChanged;
  End;

 Destructor TCustomHTTP.Destroy;
  Begin
   UnprepareSession;
   fProxy.Free;
   Inherited Destroy;
  End;

 Procedure TCustomHTTP.ConfigChanged(Sender : TObject);
  Begin
   UnprepareSession;
  End;

 Procedure TCustomHTTP.SetProxy(Value : TProxyConfig);
  Begin
   Proxy.Assign(Value);
  End;

 Procedure TCustomHTTP.SetUserAgent(Const Value : String);
  Begin
   If UserAgent <> Value Then
    Begin
     fUserAgent := Value;
     ConfigChanged(Self);
    End;
  End;

 Function TCustomHTTP.IsStoredUserAgent : Boolean;
  Begin
   Result := (UserAgent <> DefaultUserAgent);
  End;

 Function TCustomHTTP.PrepareSession(Const Details : TURLParts) : Boolean;
  Var
   pUserName : PChar;
   pPassword : PChar;
  Begin
   Result := False;
   If hInternet = Nil Then
    Begin
     hInternet := InternetOpen(PChar(UserAgent), Proxy.IOType, Proxy.IOName, Proxy.IOBypass, 0);
     If hInternet = Nil Then
      Exit;
    End;
   If (hConnection = Nil) Or
   (SessionDetails.Scheme <> Details.Scheme) Or
   (SessionDetails.Port <> Details.Port) Or
   (SessionDetails.HostName <> Details.HostName) Or
   (SessionDetails.UserName <> Details.UserName) Or
   (SessionDetails.Password <> Details.Password) Then
    Begin
     pUserName := Nil;
     pPassword := Nil;
     If Details.UserName <> '' Then
      Begin
       pUserName := PChar(Details.UserName);
       pPassword := PChar(Details.Password);
      End;
     hConnection := InternetConnect(hInternet, PChar(Details.HostName), Details.Port,
     pUserName, pPassword, INTERNET_SERVICE_HTTP, 0, 0);
     If hConnection = Nil Then
      Exit;
     SessionDetails.Scheme   := Details.Scheme;
     SessionDetails.HostName := Details.HostName;
     SessionDetails.Port     := Details.Port;
     SessionDetails.UserName := Details.UserName;
     SessionDetails.Password := Details.Password;
    End;
   Result := True;
  End;

 Procedure TCustomHTTP.UnprepareSession;
  Begin
   If hConnection <> Nil Then
    Begin
     InternetCloseHandle(hConnection);
     hConnection := Nil;
    End;
   If hInternet <> Nil Then
    Begin
     InternetCloseHandle(hInternet);
     hInternet := Nil;
    End;
  End;

 Function TCustomHTTP.HttpRequest(Const URL : String; Response : TStream; Const PostData : String; Const ContentType : String) : Cardinal;
  Const
   HttpMethod : Array[Boolean] Of PChar = ('GET', 'POST');
   AcceptContentTypes : Array[0..1] Of PChar = ('*/*', Nil);
  Var
   PostHeaders : String;
   URLParts    : TURLParts;
   hResource   : WinInet.hInternet;
   Buffer      : Array[0..1023] Of Byte;
   Flags       : Cardinal;
   Size        : Cardinal;
   Reserved    : Cardinal;
   Data        : UTF8String;
   ReqOK       : Boolean;
  Begin
   Result := 0;
   CrackURL(URL, URLParts);
   If PrepareSession(URLParts) Then
    Begin
     Flags := INTERNET_FLAG_RELOAD Or INTERNET_FLAG_PRAGMA_NOCACHE
     Or INTERNET_FLAG_NO_CACHE_WRITE Or INTERNET_FLAG_NO_COOKIES
     Or INTERNET_FLAG_NO_UI Or INTERNET_FLAG_KEEP_CONNECTION;
     If URLParts.Scheme = INTERNET_SCHEME_HTTPS Then
      Flags    := Flags Or INTERNET_FLAG_SECURE;
     hResource := HttpOpenRequest(hConnection, HttpMethod[PostData <> ''],
     PChar(URLParts.Path + URLParts.ExtraInfo), Nil, PChar(Referer),
     @AcceptContentTypes[0], Flags, 0);
     If hResource <> Nil Then
      Try
       If PostData = '' Then
        ReqOK := HttpSendRequest(hResource, Nil, 0, Nil, 0)
       Else
        Begin
         PostHeaders := 'Content-Type: ' + ContentType + #13#10;
         Data        := UTF8Encode(PostData);
         ReqOK       := HttpSendRequest(hResource, PChar(PostHeaders), Length(PostHeaders),
         PAnsiChar(Data), Length(Data));
        End;
       If ReqOK Then
        Begin
         Reserved := 0;
         Size     := SizeOf(Result);
         HttpQueryInfo(hResource, HTTP_QUERY_FLAG_NUMBER Or HTTP_QUERY_STATUS_CODE, @Result, Size, Reserved);
         While InternetReadFile(hResource, @Buffer[0], SizeOf(Buffer), Size) And (Size <> 0) Do
          Response.Write(Buffer[0], Size);
        End;
      Finally
       InternetCloseHandle(hResource);
      End;
    End;
  End;

End.
