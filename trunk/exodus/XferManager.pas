unit XferManager;
{
    Copyright 2003, Peter Millard

    This file is part of Exodus.

    Exodus is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Exodus is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Exodus; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

{$ifdef VER150}
    {$define INDY9}
{$endif}

interface

uses
    Unicode, XMLTag, SyncObjs, 
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Dockable, ExtCtrls, IdCustomHTTPServer, IdHTTPServer, IdSocks,
    IdTCPServer, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
    IdHTTP, IdServerIOHandler, IdServerIOHandlerSocket;

const
    WM_CLOSE_FRAME = WM_USER + 6005;
    WM_CLEANUP_FRAME = WM_USER + 6006;

type

  TFileXferMode = (send_auto, send_socks, send_proxy, send_oob, send_dav, send_si, recv_oob, recv_si);

  TFileXferPkg = class
    mode: TFileXferMode;
    recip: Widestring;
    pathname: Widestring;
    url: string;
    desc: Widestring;
    busy: boolean;
    oob_thread: TIdPeerThread;
    frame: TFrame;
    size: longint;
    packet: TXMLTag;
    stream_host: Widestring;
  end;

    THostPortPair = class
        host: string;
        Port: integer;
        jid: Widestring;
    end;

    TStreamPkg = class
        hash: string;
        stream: TFileStream;
        sid: Widestring;
        frame: TFrame;
        conn: TIdTCPServerConnection;
        thread: TIdPeerThread;
    end;


  TfrmXferManager = class(TfrmDockable)
    httpServer: TIdHTTPServer;
    box: TScrollBox;
    OpenDialog1: TOpenDialog;
    tcpServer: TIdTCPServer;
    procedure FormCreate(Sender: TObject);
    procedure httpServerCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure httpServerDisconnect(AThread: TIdPeerThread);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tcpServerConnect(AThread: TIdPeerThread);
    procedure tcpServerExecute(AThread: TIdPeerThread);
    procedure tcpServerDisconnect(AThread: TIdPeerThread);

  protected
    procedure WMCloseFrame(var msg: TMessage); message WM_CLOSE_FRAME;

  published
    procedure SessionCallback(event: string; tag: TXMLTag);

    procedure ClientWork(Sender: TObject;
        AWorkMode: TWorkMode; const AWorkCount: Integer);

  private
    { Private declarations }
    _pnl_list: TWidestringList;
    _current: integer;
    _cb: integer;
    _stream_list: TStringlist;
    _slock: TCriticalSection;

  public
    { Public declarations }
    procedure SendFile(pkg: TFileXferPkg);
    procedure RecvFile(pkg: TFileXferPkg);

    function getFrameIndex(frame: TFrame): integer;
    procedure killFrame(frame: TFrame);
    procedure ServeStream(spkg: TStreamPkg);
    procedure UnServeStream(hash: string);
  end;

var
  frmXferManager: TfrmXferManager;

resourcestring
    sXferNewPort = 'Your new file transfer port will not take affect until all current trasfers are stopped. Stop existing transfers?';
    sXferRecv = '%s is sending you a file.';
    sXferURL = 'File transfer URL: ';
    sXferDesc = 'File Description: ';
    sXferOnline = 'The Contact must be online before you can send a file.';
    sSend = 'Send';
    sOpen = 'Open';
    sClose = 'Close';
    sTo = 'To:     ';
    sXferOverwrite = 'This file already exists. Overwrite?';
    sXferWaiting = 'Waiting for connection...';
    sXferSending = 'Sending file...';
    sXferRecvDisconnected = 'Receiver disconnected.';
    sXferTryingClose = 'Trying to close.';
    sXferDone = 'File transfer is done.';
    sXferConn = 'Got connection.';
    sXferDefaultDesc = 'Sending you a file.';
    sXferCreateDir = 'This directory does not exist. Create it?';
    sXferStreamError = 'There was an error trying to create the file.';
    sXferDavError = 'There was an error trying to upload the file to your web host.';
    sXferRecvError = 'There was an error receiving the file. (%d)';


function getXferManager(): TfrmXferManager;

procedure FileSend(tojid: string; fn: string = '');
procedure FileReceive(tag: TXMLTag); overload;
procedure FileReceive(from, url, desc: string); overload;

procedure SIStart(tag: TXMLTag);


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

{$R *.dfm}
uses
    ExUtils, Jabber1, JabberConst, JabberID, Presence, InputPassword,
    XMLUtils, Notify, RecvStatus, SendStatus, Session;

{---------------------------------------}
procedure FileSend(tojid: string; fn: string = '');
var
    tmp_id: TJabberID;
    filename, url, ip, tmps: string;
    pri: TJabberPres;
    p: integer;
    jid, desc, dav_path: Widestring;
    pkg: TFileXferPkg;
begin

    // Make sure the contact is online
    tmp_id := TJabberID.Create(tojid);
    if (tmp_id.resource = '') then begin
        pri := MainSession.ppdb.FindPres(tmp_id.jid, '');
        if (pri = nil) then begin
            MessageDlg(sXferOnline, mtError, [mbOK], 0);
            exit;
        end;
        tmps := pri.fromJID.full;
    end
    else
        tmps := tojid;
    jid := tmps;

    if (fn <> '') then
        filename := fn
    else begin
        if not getXferManager().OpenDialog1.Execute then exit;
        filename := getXferManager().OpenDialog1.Filename;
    end;

    // Create a wrapper and call sendFile();
    pkg := TFileXferPkg.Create();
    pkg.recip := jid;
    pkg.pathname := filename;
    pkg.desc := desc;

    // get xfer prefs, and spin up URL
    with MainSession.Prefs do begin
        if (getBool('xfer_webdav')) then begin
            ip := getString('xfer_davhost');
            dav_path := getString('xfer_davpath');
            url := ip + dav_path + '/' + ExtractFilename(filename);
        end
        else begin
            ip := getString('xfer_ip');
            p := getInt('xfer_port');

            if (ip = '') then ip := MainSession.Stream.LocalIP;
            url := 'http://' + ip + ':' + IntToStr(p) + '/' + ExtractFileName(filename);
        end;

        if (getBool('xfer_proxy')) then begin
            pkg.stream_host := getString('xfer_prefproxy');
        end
        else begin
            pkg.stream_host := '';
        end;
    end;

    // Get the description
    pkg.mode := send_auto;
    pkg.url := url;

    getXferManager().sendFile(pkg);
end;

{---------------------------------------}
procedure FileReceive(tag: TXMLTag); overload;
var
    qTag, tmp_tag: TXMLTag;
    from, url, desc: string;
begin
    // Callback for receiving file transfers
    from := tag.GetAttribute('from');
    qTag := tag.getFirstTag('query');
    tmp_tag := qtag.GetFirstTag('url');
    url := tmp_tag.Data;

    // if this isn't an http:// url, then ignore.
    if (Pos('http:', url) <> 1) then exit;

    tmp_tag := qTag.GetFirstTag('desc');
    if (tmp_tag <> nil) then
        desc := tmp_tag.Data
    else
        desc := '';
    FileReceive(from, url, desc);
end;

{---------------------------------------}
procedure FileReceive(from, url, desc: string); overload;
var
    pkg: TFileXferPkg;
    tmps: Widestring;
    tmp_jid: TJabberID;
begin
    tmp_jid := TJabberID.Create(from);

    pkg := TFileXferPkg.Create();
    pkg.mode := recv_oob;
    pkg.recip := from;
    pkg.url := url;
    pkg.pathname := ExtractFilename(URLToFileName(url));
    pkg.desc := desc;
    pkg.mode := recv_oob;

    tmps := Format(sXferRecv, [from]);

    tmp_jid.Free();

    getXferManager().RecvFile(pkg);

    DoNotify(getXferManager(), 'notify_oob', 'File from ' + tmps, ico_service);
end;

{---------------------------------------}
procedure SIStart(tag: TXMLTag);
var
    tmps, from: Widestring;
    v, f, fld, e, err, si: TXMLTag;
    pkg: TFileXferPkg;
    xp: Widestring;
    opts: TXMLTagList;
    invalid_profile, s5b: boolean;
    i: integer;
begin
    // we only want files.. not other streams
    // make sure it's a file, and they are offering socks5 bytestreams
    from := tag.GetAttribute('from');
    si := tag.GetFirstTag('si');
    f := tag.QueryXPTag('/iq/si/file[@xmlns="' + XMLNS_FTPROFILE + '"]');
    xp := '/iq/si/feature[@xmlns="' + XMLNS_FEATNEG + '"]/x[@xmlns="' + XMLNS_XDATA + '"]/field[@var="stream-method"]';
    fld := tag.QueryXPTag(xp);
    s5b := false;
    if (fld <> nil) then begin
        opts := fld.QueryTags('option');
        for i := 0 to opts.Count - 1 do begin
            v := opts[i].GetFirstTag('value');
            if (v <> nil) then begin
                s5b := (v.Data = XMLNS_BYTESTREAMS);
                if (s5b) then break;
            end;
        end;
    end;

    if (si.GetAttribute('profile') <> XMLNS_FTPROFILE) then
        invalid_profile := true
    else
        invalid_profile := false;

    if ((s5b = false) or (invalid_profile)) then begin

        e := TXMLTag.Create('iq');
        e.setAttribute('type', 'error');
        e.setAttribute('to', tag.GetAttribute('from'));
        e.setAttribute('id', tag.GetAttribute('id'));

        err := e.AddTag('error');
        err.setAttribute('code', '400');
        err.setAttribute('type', 'cancel');

        err.AddTagNS('bad-request', XMLNS_STREAMERR);

        if (invalid_profile) then
            err.AddTagNS('bad-profile', XMLNS_SI);
        if (s5b = false) then
            err.AddTagNS('no-valid-stream', XMLNS_SI);

        
        MainSession.SendTag(e);
        exit;
    end;

    tmps := Format(sXferRecv, [from]);

    pkg := TFileXferPkg.Create();
    pkg.mode := recv_si;
    pkg.recip := tag.getAttribute('from');
    pkg.pathname := f.GetAttribute('name');
    pkg.size := SafeInt(f.GetAttribute('size'));
    pkg.packet := TXMLTag.Create(tag);
    pkg.desc := '';

    getXferManager().RecvFile(pkg);

    DoNotify(getXferManager(), 'notify_oob', 'File from ' + tmps, ico_service);

end;

{---------------------------------------}
function getXferManager(): TfrmXferManager;
begin
    if (frmXferManager = nil) then
        frmXferManager := TfrmXferManager.Create(Application);

    Result := frmXferManager;
    Result.Show();
end;

{---------------------------------------}
procedure TfrmXferManager.RecvFile(pkg: TFileXferPkg);
var
    f: Widestring;
    fRecv: TfRecvStatus;
begin
    f := ExtractFilename(pkg.pathname);
    pkg.busy := false;

    fRecv := TfRecvStatus.Create(Self);
    fRecv.Parent := Self.box;
    fRecv.Align := alTop;
    fRecv.Visible := true;
    fRecv.Name := 'recv' + IntToStr(box.ControlCount);
    pkg.frame := fRecv;

    _pnl_list.AddObject('RECV:' + pkg.pathname, pkg);

    fRecv.setup(pkg);
end;

{---------------------------------------}
procedure TfrmXferManager.SendFile(pkg: TFileXferPkg);
var
    f: Widestring;
    fSend: TfSendStatus;
begin
    // Create a new panel, and do the right thing.
    f := ExtractFilename(pkg.pathname);
    pkg.busy := false;
    _pnl_list.AddObject(f, pkg);

    fSend := TfSendStatus.Create(Self);
    fSend.Parent := Self.box;
    fSend.Align := alTop;
    fSend.Visible := true;
    fSend.Name := 'send_' + IntToStr(box.ControlCount);

    fSend.Setup(pkg);
    pkg.Frame := fSend;
    fSend.SendStart();
end;

{---------------------------------------}
procedure TfrmXferManager.FormCreate(Sender: TObject);
begin
  inherited;
    _pnl_list := TWidestringList.Create();
    _stream_list := TStringlist.Create();
    _slock := TCriticalSection.Create();

    // setup http server
    with httpServer do begin
        Active := false;
        AutoStartSession := true;
        DefaultPort := MainSession.Prefs.getInt('xfer_port');
        _current := 0;
    end;

    _cb := MainSession.RegisterCallback(SessionCallback, '/session');


end;

{---------------------------------------}
procedure TfrmXferManager.httpServerCommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
    f: string;
    idx: integer;
    p: TFileXferPkg;
begin
  inherited;
    // send the file.
    f := ARequestInfo.Document;
    if (f[1] = '/') then Delete(f, 1, 1);
    idx := _pnl_list.IndexOf(f);

    if (idx < 0) then with AResponseInfo do begin
        ResponseNo := 404;
        CloseConnection := true;
    end
    else begin
        p := TFileXferPkg(_pnl_list.Objects[idx]);
        p.oob_thread := AThread;
        inc(_current);
        httpServer.ServeFile(AThread, AResponseInfo, p.pathname);
    end;
end;

{---------------------------------------}
procedure TfrmXferManager.SessionCallback(event: string; tag: TXMLTag);
var
    p: integer;
begin
    // check for new xfer prefs
    if (event = '/session/prefs') then begin
        p := MainSession.Prefs.getInt('xfer_port');
        if (p <> httpServer.DefaultPort) then begin

            // check to see if we should disconnect current xfers
            if ((httpServer.Active) or (_current > 0)) then
                if (MessageDlg(sXferNewPort, mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin
                    httpServer.Active := false;
                    _current := 0;
                end;

            // change it.
            httpServer.DefaultPort := p;
        end;
    end;
end;

{---------------------------------------}
procedure TfrmXferManager.WMCloseFrame(var msg: TMessage);
var
    ps: TfSendStatus;
    pr: TfRecvStatus;

    idx: integer;
    p: TFileXferPkg;
begin
    // Close a specific frame.
    idx := msg.WParam;
    if (idx < 0) then exit;
    if (idx >= _pnl_list.Count) then exit;

    p := TFileXferPkg(_pnl_list.Objects[idx]);

    if (p.frame is TfSendStatus) then begin
        ps := TfSendStatus(p.frame);
        p.frame := nil;
        ps.Visible := false;
        FreeAndNil(ps);
    end
    else if (p.frame is TfRecvStatus) then begin
        pr := TfRecvStatus(p.frame);
        p.frame := nil;
        pr.Visible := false;
        FreeAndNil(pr);
    end;
    
    p.Free();
    _pnl_list.Delete(idx);

    if (box.ControlCount <= 0) then
        Self.Close();

end;


{---------------------------------------}
procedure TfrmXferManager.httpServerDisconnect(AThread: TIdPeerThread);
var
    i: integer;
    p: TFileXferPkg;
begin
  inherited;
    // Find this thread and close the frame
    for i := 0 to _pnl_list.Count - 1  do begin
        p := TFileXferPkg(_pnl_list.Objects[i]);
        if (p.oob_thread = AThread) then begin
            SendMessage(Self.Handle, WM_CLOSE_FRAME, i, 0);
            exit;
        end;
    end;
end;

{---------------------------------------}
procedure TfrmXferManager.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
    frmXferManager := nil;
    Action := caFree;
end;

{---------------------------------------}
function TfrmXferManager.getFrameIndex(frame: TFrame): integer;
var
    i: integer;
    p: TFileXferPkg;
begin
    //
    Result := -1;
    for i := 0 to _pnl_list.Count - 1  do begin
        p := TFileXferPkg(_pnl_list.Objects[i]);
        if (p.frame = frame) then begin
            Result := i;
            exit;
        end;
    end;
end;

{---------------------------------------}
procedure TfrmXferManager.killFrame(frame: TFrame);
var
    i: integer;
begin
    i := getFrameIndex(frame);
    if (i = -1) then exit;
    PostMessage(Self.Handle, WM_CLOSE_FRAME, i, 0);
end;


{---------------------------------------}
procedure TfrmXferManager.tcpServerConnect(AThread: TIdPeerThread);
begin
  inherited;
    // someone connected to us..
    AThread.Connection.OnWork := Self.ClientWork;
end;

{---------------------------------------}
procedure TfrmXferManager.tcpServerExecute(AThread: TIdPeerThread);
var
    i, idx: integer;
    cmd, atype, ver, num_meths: char;
    meths: array[1..255] of char;
    auth_ok: boolean;
    dst_addr: PChar;
    dst_len: Cardinal;
    hash: String;
    spkg: TStreamPkg;
    buff: array[1..2] of char;
    resp_len: Cardinal;
    resp: PChar;
    ip_len: Byte;
    myip: string;
    stat: PChar;
begin
  inherited;
    // we need to do something
    ver := AThread.Connection.ReadChar;
    if (Ord(ver) <> $05) then begin
        // not socks5
        AThread.Connection.Disconnect();
        exit;
    end;

    num_meths := AThread.Connection.ReadChar;

    // check methods
    auth_ok := false;
    AThread.Connection.ReadBuffer(meths, Ord(num_meths));
    for i := 1 to Ord(num_meths) do begin
        if (Ord(meths[i]) = $00) then begin
            auth_ok := true;
            break;
        end;
    end;

    buff[1] := Chr($05);
    if (not auth_ok) then begin
        buff[2] := Chr($FF);
        AThread.Connection.WriteBuffer(buff, 2);
        AThread.Connection.Disconnect();
        exit;
    end
    else begin
        buff[2] := Chr($00);
        AThread.Connection.WriteBuffer(buff, 2);
    end;

    // get the command
    ver := AThread.Connection.ReadChar();
    if (Ord(ver) <> $05) then begin
        AThread.Connection.Disconnect();
        exit;
    end;

    cmd := AThread.Connection.ReadChar();
    if (Ord(cmd) <> $01) then begin
        AThread.Connection.Disconnect();
        exit;
    end;

    // Read the RSV byte
    AThread.Connection.ReadChar();

    atype := AThread.Connection.ReadChar();

    if (Ord(atype) = $01) then begin
        // ipv4 addr
        dst_addr := StrAlloc(4);
        FillChar(dst_addr^, 4, 0);
        AThread.Connection.ReadBuffer(dst_addr^, 4);
    end
    else if (Ord(atype) = $03) then begin
        // domain name
        dst_len := Ord(AThread.Connection.ReadChar());
        dst_addr := StrAlloc(dst_len + 1);
        FillChar(dst_addr^, dst_len + 1, 0);
        AThread.Connection.ReadBuffer(dst_addr^, dst_len);
    end
    else begin
        AThread.Connection.Disconnect();
        exit;
    end;

    // We don't care about this value, but we have to read it
    AThread.Connection.ReadSmallInt();

    hash := String(dst_addr);

    _slock.Acquire();
    idx := _stream_list.IndexOf(hash);
    if (idx = -1) then begin
        AThread.Connection.Disconnect();
        exit;
    end;
    spkg := TStreamPkg(_stream_list.Objects[idx]);
    AThread.Connection.Tag := spkg.frame.Handle;
    _stream_list.Delete(idx);
    _slock.Release();
    PostMessage(spkg.frame.Handle, WM_SEND_STATUS, 1, 0);
    PostMessage(spkg.frame.Handle, WM_SEND_START, spkg.stream.Size, 0);

    // Reply back
    myip := MainSession.Stream.LocalIP;
    ip_len := Length(myip);
    resp_len := 1 + 1 + 1 + 1 + 1 + ip_len;
    resp := StrAlloc(resp_len + 1);
    FillChar(resp^, resp_len + 1, 0);
    resp[0] := Chr($05);
    resp[1] := Chr($00);
    resp[2] := Chr($00);
    resp[3] := Chr($03);
    resp[4] := Chr(Length(myip));
    StrPCopy(@resp[5], PChar(myip));
    AThread.Connection.WriteBuffer(resp^, resp_len);
    AThread.Connection.WriteSmallInt(Self.tcpServer.DefaultPort);

    AThread.Connection.WriteStream(spkg.stream);

    killFrame(spkg.frame);

    FreeAndNil(spkg.stream);
    //FreeAndNil(spkg);

    AThread.Connection.Disconnect();
end;


{---------------------------------------}
procedure TfrmXferManager.ServeStream(spkg: TStreamPkg);
begin
    _slock.Acquire();
    _stream_list.AddObject(spkg.hash, spkg);
    _slock.Release();
    if (not tcpServer.Active) then
        tcpServer.Active := true;
end;

{---------------------------------------}
procedure TfrmXferManager.UnServeStream(hash: string);
var
    i: integer;
begin
    _slock.Acquire();
    i := _stream_list.IndexOf(hash);
    if (i >= 0) then begin
        TStreamPkg(_stream_list.Objects[i]).Free();
        _stream_list.Delete(i);
    end;
    _slock.Release();

    if ((_stream_list.Count = 0) and (tcpServer.Active)) then
        tcpServer.Active := false;
end;

{---------------------------------------}
procedure TfrmXferManager.ClientWork(Sender: TObject;
  AWorkMode: TWorkMode; const AWorkCount: Integer);
begin
    // Update the progress meter
    PostMessage(TIdTCPServerConnection(Sender).Tag, WM_SEND_UPDATE,
        AWorkCount, 0);
end;

{---------------------------------------}
procedure TfrmXferManager.tcpServerDisconnect(AThread: TIdPeerThread);
begin
  inherited;
    // remove this connection from the list
end;

initialization
    frmXferManager := nil;

end.
