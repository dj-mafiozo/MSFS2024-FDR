{$StackFrames On}
Unit RouteBridgeU;

Interface

 Uses
  System.SysUtils, System.Classes, System.SyncObjs, IdContext, IdCustomHTTPServer, IdHTTPServer;

 Type
  TRouteBridge = Class
   Private
    fServer  : TIdHTTPServer;
    fLock    : TCriticalSection;
    fPending : String;
    Procedure Command(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
   Public
    Constructor Create(Port : Word);
    Destructor Destroy; Override;
    Function Take : String;
  End;

Implementation

 Constructor TRouteBridge.Create(Port : Word);
  Begin
   Inherited Create;
   fLock   := TCriticalSection.Create;
   fServer := TIdHTTPServer.Create(Nil);
   fServer.Bindings.Clear;
   fServer.Bindings.Add;
   fServer.Bindings[0].IP   := '127.0.0.1';
   fServer.Bindings[0].Port := Port;
   fServer.OnCommandGet     := Command;
   fServer.OnCommandOther   := Command;
   fServer.Active           := True;
  End;

 Destructor TRouteBridge.Destroy;
  Begin
   fServer.Free;
   fLock.Free;
   Inherited;
  End;

 Procedure TRouteBridge.Command(Context : TIdContext; Request : TIdHTTPRequestInfo; Response : TIdHTTPResponseInfo);
  Var
   Bytes : TBytes;
   Text  : String;
  Begin
   Response.ContentType                                                  := 'text/plain';
   Response.CharSet                                                      := 'utf-8';
   Response.CustomHeaders.Values['Access-Control-Allow-Origin']          := '*';
   Response.CustomHeaders.Values['Access-Control-Allow-Methods']         := 'POST, OPTIONS';
   Response.CustomHeaders.Values['Access-Control-Allow-Headers']         := 'Content-Type';
   Response.CustomHeaders.Values['Access-Control-Allow-Private-Network'] := 'true';
   Response.CloseConnection                                              := True;
   If Request.Document <> '/efb-route' Then
    Begin
     Response.ResponseNo := 404;
     Exit;
    End;
   If Request.Command = 'OPTIONS' Then
    Begin
     Response.ResponseNo := 204;
     Exit;
    End;
   If Request.Command <> 'POST' Then
    Begin
     Response.ResponseNo := 405;
     Exit;
    End;
   If (Request.PostStream = Nil) Or (Request.PostStream.Size < 2) Or (Request.PostStream.Size > 1048576) Then
    Begin
     Response.ResponseNo := 413;
     Exit;
    End;
   SetLength(Bytes, Request.PostStream.Size);
   Request.PostStream.Position := 0;
   Request.PostStream.ReadBuffer(Bytes[0], Length(Bytes));
   Text := TEncoding.UTF8.GetString(Bytes);
   fLock.Enter;
   Try
    fPending := Text;
   Finally
    fLock.Leave;
   End;
   Response.ResponseNo  := 202;
   Response.ContentText := 'Route queued';
  End;

 Function TRouteBridge.Take : String;
  Begin
   fLock.Enter;
   Try
    Result   := fPending;
    fPending := '';
   Finally
    fLock.Leave;
   End;
  End;

End.
