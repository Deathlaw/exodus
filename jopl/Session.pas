unit Session;
{
    Copyright 2001, Peter Millard

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

interface

uses
    PrefController,
    JabberAuth, Chat, MsgList, Presence, Roster, NodeItem,
    Signals, XMLStream, XMLTag, Unicode,
    Contnrs, Classes, SysUtils, JabberID;

type
    TJabberAuthType = (jatZeroK, jatDigest, jatPlainText, jatNoAuth);

    TJabberSession = class
    private
        _stream: TXMLStream;
        _register: boolean;
        _stream_id: WideString;
        _show: WideString;
        _status: WideString;
        _priority: integer;
        _invisible: boolean;
        _profile: TJabberProfile;
        _features: TXMLTag;
        _xmpp: boolean;
        _cur_server: Widestring;
        _tls_cb: integer;
        _ssl_on: boolean;
        _lang: WideString;

        // Dispatcher
        _dispatcher: TSignalDispatcher;
        _packetSignal: TPacketSignal;
        _sessionSignal: TBasicSignal;
        _rosterSignal: TRosterSignal;
        _presSignal: TPresenceSignal;
        _dataSignal: TStringSignal;
        _unhandledSignal: TBasicSignal;
        _winSignal: TPacketSignal;
        _paused: boolean;
        _pauseQueue: TQueue;
        _id: longint;
        _cb_id: longint;
        _authd: boolean;
        _first_pres: boolean;
        _avails: TWidestringlist;
        _auth_agent: TJabberAuth;

        procedure StreamCallback(msg: string; tag: TXMLTag);

        procedure SetUsername(username: WideString);
        procedure SetPassword(password: WideString);
        procedure SetServer(server: WideString);
        procedure SetResource(resource: WideString);
        procedure SetPort(port: integer);

        procedure handleDisconnect();
        procedure manualBlastPresence(p: TXMLTag);
        procedure StartSession(tag: TXMLTag);
        procedure ResetStream();
        procedure StartTLS();

        function GetUsername(): WideString;
        function GetPassword(): WideString;
        function GetServer(): WideString;
        function GetResource(): WideString;
        function GetPort(): integer;
        function GetFullJid(): Widestring;
        function GetBareJid(): Widestring;
        function GetActive(): boolean;

        procedure doConnect();

    published
        procedure DataEvent(send: boolean; data: Widestring);
        procedure SessionCallback(event: string; tag: TXMLTag);
        procedure BindCallback(event: string; tag: TXMLTag);
        procedure TLSCallback(event: string; tag: TXMLTag);

    public
        ppdb: TJabberPPDB;
        roster: TJabberRoster;
        MsgList: TJabberMsgList;
        ChatList: TJabberChatList;
        Prefs: TPrefController;
        dock_windows: boolean;
        Presence_XML: TWideStringlist;

        Constructor Create(ConfigFile: widestring);
        Destructor Destroy; override;

        procedure CreateAccount;
        procedure Connect;
        procedure Disconnect;


        // AuthAgent stuff
        procedure setAuthAgent(new_auth: TJabberAuth);
        procedure setAuthdJID(user, host, res: Widestring);
        procedure setAuthenticated(ok: boolean; tag: TXMLTag; reset_stream: boolean);
        function  getAuthAgent: TJabberAuth;

        procedure setPresence(show, status: WideString; priority: integer);

        function RegisterCallback(callback: TPacketEvent; xplite: string; pausable: boolean = false): integer; overload;
        function RegisterCallback(callback: TRosterEvent): integer; overload;
        function RegisterCallback(callback: TPresenceEvent): integer; overload;
        function RegisterCallback(callback: TDataStringEvent): integer; overload;
        procedure UnRegisterCallback(index: integer);

        procedure FireEvent(event: string; tag: TXMLTag); overload;
        procedure FireEvent(event: string; tag: TXMLTag; const p: TJabberPres); overload;
        procedure FireEvent(event: string; tag: TXMLTag; const ritem: TJabberRosterItem); overload;
        procedure FireEvent(event: string; tag: TXMLTag; const data: WideString); overload;

        procedure SendTag(tag: TXMLTag);
        procedure ActivateProfile(i: integer);

        procedure Pause;
        procedure Play;
        procedure QueueEvent(event: string; tag: TXMLTag; Callback: TPacketEvent);

        function generateID: WideString;
        function IsBlocked(jid : WideString): boolean;  overload;
        function IsBlocked(jid : TJabberID): boolean; overload;

        procedure Block(jid : TJabberID);
        procedure UnBlock(jid : TJabberID);

        procedure addAvailJid(jid: Widestring);
        procedure removeAvailJid(jid: Widestring);

        property Username: WideString read GetUsername write SetUsername;
        property Password: WideString read GetPassword write SetPassword;
        property Server: WideString read GetServer write SetServer;
        property Resource: WideString read GetResource write SetResource;
        property Jid: Widestring read GetFullJid;
        property BareJid: Widestring read GetBareJid;
        property Port: integer read GetPort write SetPort;
        property Priority: integer read _priority write _priority;
        property Show: WideString read _show;
        property Status: WideString read _status;
        property Stream: TXMLStream read _stream;
        property StreamID: Widestring read _stream_id;
        property Dispatcher: TSignalDispatcher read _dispatcher;
        property IsPaused: boolean read _paused;
        property Invisible: boolean read _invisible write _invisible;
        property Active: boolean read GetActive;
        property Profile: TJabberProfile read _profile;

        property isXMPP: boolean read _xmpp;
        property xmppFeatures: TXMLTag read _features;
        property SSLEnabled: boolean read _ssl_on;
        property xmlLang: WideString read _lang;
    end;

var
    MainSession: TJabberSession;

implementation
uses
    {$ifdef Win32}
    Forms, Dialogs,
    {$else}
    QForms, QDialogs,
    {$endif}
    XMLUtils, XMLSocketStream, XMLHttpStream, IdGlobal, IQ,
    JabberConst, CapPresence;

{---------------------------------------}
Constructor TJabberSession.Create(ConfigFile: widestring);
begin
    //
    inherited Create();

    _register := false;
    _id := 1;
    _cb_id := 1;
    _profile := nil;

    // Create the event dispatcher mechanism
    _dispatcher := TSignalDispatcher.Create;
    _packetSignal := TPacketSignal.Create();
    _sessionSignal := TBasicSignal.Create();
    _rosterSignal := TRosterSignal.Create();
    _presSignal := TPresenceSignal.Create();
    _dataSignal := TStringSignal.Create();
    _unhandledSignal := TBasicSignal.Create();
    _winSignal := TPacketSignal.Create();

    _dispatcher.AddSignal('/packet', _packetSignal);
    _dispatcher.AddSignal('/session', _sessionSignal);
    _dispatcher.AddSignal('/roster', _rosterSignal);
    _dispatcher.AddSignal('/presence', _presSignal);
    _dispatcher.AddSignal('/data', _dataSignal);
    _dispatcher.AddSignal('/unhandled', _unhandledSignal);
    _dispatcher.AddSignal('/windows', _winSignal);

    _pauseQueue := TQueue.Create();
    _avails := TWidestringlist.Create();
    _features := nil;
    _xmpp := false;
    _ssl_on := false;

    // Create all the things which might register w/ the session

    // Create the Presence Proxy Database (PPDB)
    ppdb := TJabberPPDB.Create;
    ppdb.SetSession(Self);

    // Create the Roster
    roster := TJabberRoster.Create;
    roster.SetSession(Self);

    // Create the msg & chat controllers
    MsgList := TJabberMsgList.Create();
    ChatList := TJabberChatList.Create();
    MsgList.SetSession(Self);
    ChatList.SetSession(Self);

    // Create the preferences controller
    Prefs := TPrefController.Create(ConfigFile);
    Prefs.LoadProfiles;
    Prefs.SetSession(Self);

    if (Prefs.getBool('always_lang')) then
        _lang := Prefs.getString('locale')
    else
        _lang := '';

    // Create the Presence_XML list for stashing stuff in every pres packet
    Presence_XML := TWideStringlist.Create();
end;

{---------------------------------------}
Destructor TJabberSession.Destroy;
begin
    // Clean up everything

    ClearStringListObjects(ppdb);
    ppdb.Clear();
    Prefs.Free;
    ppdb.Free;
    roster.Free;
    MsgList.Free;
    ChatList.Free;

    if (_stream <> nil) then
        _stream.Free();
    _pauseQueue.Free();
    Presence_XML.Free();

    // Free the dispatcher... this should free the signals
    _dispatcher.Free;

    inherited Destroy;
end;

{---------------------------------------}
procedure TJabberSession.SetUsername(username: WideString);
begin
    _profile.Username := username;
end;

{---------------------------------------}
function TJabberSession.GetUsername(): WideString;
begin
    if (_profile = nil) then
        result := ''
    else
        result := _profile.Username;
end;

{---------------------------------------}
function TJabberSession.GetFullJid(): WideString;
begin
    if (_profile = nil) then
        result := ''
    else
        result := _profile.Username + '@' + _profile.Server + '/' +
            _profile.Resource;
end;

{---------------------------------------}
function TJabberSession.GetBareJid(): Widestring;
begin
    if (_profile = nil) then
        Result := ''
    else
        Result := _profile.username + '@' + _profile.server;
end;

{---------------------------------------}
procedure TJabberSession.SetPassword(password: WideString);
begin
    _profile.Password := Trim(password);
end;

{---------------------------------------}
function TJabberSession.GetPassword(): WideString;
begin
    if (_profile = nil) then
        result := ''
    else
        result := _profile.Password;
end;

{---------------------------------------}
procedure TJabberSession.SetServer(server: WideString);
begin
    _profile.Server := server;
end;

{---------------------------------------}
function TJabberSession.GetServer(): WideString;
begin
    if (_profile = nil) then
        result := ''
    else if (_cur_server <> '') then
        result := _cur_server
    else
        result := _profile.Server;
end;

{---------------------------------------}
procedure TJabberSession.SetResource(resource: WideString);
begin
    _profile.Resource := resource;
end;

{---------------------------------------}
function TJabberSession.GetResource(): WideString;
begin
    if (_profile = nil) then
        result := ''
    else
        result := _profile.Resource;
end;

{---------------------------------------}
procedure TJabberSession.SetPort(port: integer);
begin
    _profile.Port := port;
end;

{---------------------------------------}
function TJabberSession.GetPort(): integer;
begin
    if (_profile = nil) then
        result := 0
    else
        result := _profile.Port;
end;

{---------------------------------------}
procedure TJabberSession.CreateAccount;
begin
    _register := true;
    if (not _auth_agent.StartRegistration()) then begin
        // xxx: throw some kind of error..
        // this auth mechanism doesn't support registration
    end;
end;

{---------------------------------------}
procedure TJabberSession.Connect;
begin
    DoConnect();
end;

{---------------------------------------}
procedure TJabberSession.DoConnect;
begin
    if (_profile = nil) then
        raise Exception.Create('Invalid profile')
    else if (_stream <> nil) then
        raise Exception.Create('Session is already connected')
    else if (not Assigned(_auth_agent)) then
        raise Exception.Create('No auth agent has been assigned');

    case _profile.ConnectionType of
    conn_normal:
        _stream := TXMLSocketStream.Create('stream:stream');
    conn_http:
        _stream := TXMLHttpStream.Create('stream:stream');
    else
        // don't I18N
        raise Exception.Create('Invalid connection type');
    end;

    // Register our session to get XML Tags
    _stream.RegisterStreamCallback(Self.StreamCallback);
    _stream.OnData := DataEvent;
    _stream.Connect(_profile);

    if (_profile.ssl = ssl_port) then
        _ssl_on := true;
end;

{---------------------------------------}
procedure TJabberSession.Disconnect;
begin
    // Save the server side prefs and kill our connection.
    if (_stream = nil) then exit;

    if (Self.Stream.Active) then begin
        if (_authd) then begin
            Prefs.SaveServerPrefs();
            _stream.Send('<presence type="unavailable"/>');
        end
        else if (_register) then
            _auth_agent.CancelRegistration()
        else
            _auth_agent.CancelAuthentication();

        _stream.Disconnect;
    end
    else
        Self.handleDisconnect();

    _register := false;
end;

{---------------------------------------}
procedure TJabberSession.SendTag(tag: TXMLTag);
begin
    // Send this tag out to the socket
    if (_stream <> nil) then begin
        if (_lang <> '') then
            tag.setAttribute('xml:lang', _lang);

        _stream.SendTag(tag);
        tag.Free;
    end
    else begin
        tag.Free;
        raise Exception.Create('Invalid stream');
    end;
end;

{---------------------------------------}
procedure TJabberSession.DataEvent(send: boolean; data: Widestring);
begin
    if (send) then
        // we are sending data
        _dataSignal.Invoke('/data/send', nil, data)
    else begin
        // getting data from the socket
        if (Pos('<stream:error>', data) > 0) then
            _dispatcher.DispatchSignal('/session/stream:error', nil);
        _dataSignal.Invoke('/data/recv', nil, data);
    end;
end;

{---------------------------------------}
procedure TJabberSession.handleDisconnect();
begin
    // Clear the roster, ppdb and fire the callbacks
    _first_pres := false;
    _authd := false;
    _cur_server := '';
    _dispatcher.DispatchSignal('/session/disconnected', nil);

    if (_paused) then
        Self.Play();

    FreeAndNil(_features);

    ppdb.Clear;
    Roster.Clear;
    ppdb.Clear;

    _stream.Free();
    _stream := nil;
end;

{---------------------------------------}
procedure TJabberSession.StreamCallback(msg: string; tag: TXMLTag);
var
    biq: TJabberIQ;
    l, lang, tmps: WideString;
begin
    // Process callback info..
    if msg = 'connected' then begin
        // we are connected... send auth stuff.
        lang := Prefs.getString('locale');
        if (lang <> '') then l := ' xml:lang="' + lang + '" ' else l := '';
        tmps := '<stream:stream to="' + Trim(Server) +
            '" xmlns="jabber:client" ' +
            'xmlns:stream="http://etherx.jabber.org/streams" ' + l +
            'version="1.0" ' +
            '>';
        _stream.Send(tmps);
    end

    else if msg = 'ssl-error' then
        // Throw a dialog box up..
        _dispatcher.DispatchSignal('/session/sslerror', tag)

    else if msg = 'disconnected' then
        Self.handleDisconnect()

    else if msg = 'commtimeout' then
        _dispatcher.DispatchSignal('/session/commtimeout', nil)

    else if msg = 'commerror' then
        _dispatcher.DispatchSignal('/session/commerror', nil)

    else if msg = 'xml' then begin
        // process XML
        // always fire debug
        if (tag.Name = 'stream:stream') then begin

            // we got connected
            _stream_id := tag.getAttribute('id');
            _xmpp := (tag.GetAttribute('version') = '1.0');

            // Stash away our current server.
            _cur_server := tag.getAttribute('from');
            _dispatcher.DispatchSignal('/session/connected', nil);

            if ((_register) or (_profile.NewAccount)) then begin
                _xmpp := false;
                CreateAccount()
            end
            else if (not _xmpp) then
                _auth_agent.StartAuthentication();
        end
        else if (tag.Name = 'stream:error') then begin
            // we got a stream error
            FireEvent('/session/stream:error', tag);
        end

        else if ((_xmpp) and (tag.Name = 'stream:features')) then begin
            // cache stream features..
            FreeAndNil(_features);
            _features := TXMLTag.Create(tag);

            if (_authd) then begin
                // bind to our resource
                biq := TJabberIQ.Create(Self, generateID(), BindCallback);
                biq.Namespace := 'urn:ietf:params:xml:ns:xmpp-bind';
                biq.qTag.Name := 'bind';
                biq.qTag.AddBasicTag('resource', Self.Resource);
                biq.iqType := 'set';
                biq.Send();
            end
            else begin
                if (_features.GetFirstTag('starttls') <> nil) then begin
                    // check to see if we can do startTLS
                    if (_stream.isSSLCapable()) then begin
                        StartTLS();
                        exit;
                    end;
                end;

                // start auth. if we are not registering..
                if ((not _register) and (not _profile.NewAccount)) then
                    _auth_agent.StartAuthentication();
            end;
        end

        else
            _dispatcher.DispatchSignal('/packet', tag);
    end;

end;

{---------------------------------------}
procedure TJabberSession.BindCallback(event: string; tag: TXMLTag);
var
    iq: TJabberIQ;
begin
    if ((event <> 'xml') or (tag.getAttribute('type') <> 'result')) then begin
        _dispatcher.DispatchSignal('/session/autherror', tag);
        exit;
    end
    else begin
        iq := TJabberIQ.Create(Self, generateID(), SessionCallback);
        iq.Namespace := 'urn:ietf:params:xml:ns:xmpp-session';
        iq.qTag.Name := 'session';
        iq.iqType := 'set';
        iq.Send();
    end;
end;

{---------------------------------------}
procedure TJabberSession.SessionCallback(event: string; tag: TXMLTag);
begin
    if ((event <> 'xml') or (tag.getAttribute('type') <> 'result')) then begin
        _dispatcher.DispatchSignal('/session/autherror', tag);
        exit;
    end
    else
        StartSession(tag);
end;

{---------------------------------------}
procedure TJabberSession.StartSession(tag: TXMLTag);
begin
    _first_pres := true;
    _dispatcher.DispatchSignal('/session/authenticated', tag);
    Prefs.FetchServerPrefs();
end;

{---------------------------------------}
procedure TJabberSession.Pause();
begin
    // pause the _pDispatcher;
    _paused := true;
end;

{---------------------------------------}
procedure TJabberSession.Play();
var
    q: TQueuedEvent;
    sig: TSignalEvent;
begin
    // playback the stuff in the queue
    _paused := false;

    // WOAH! Make sure things are played back or cleared when we get disconnected.
    while (_pauseQueue.Count > 0) do begin
        q := TQueuedEvent(_pauseQueue.pop);
        sig := TSignalEvent(q.callback);
        sig(q.event, q.tag);
        q.Free;
    end;
end;

{---------------------------------------}
procedure TJabberSession.QueueEvent(event: string; tag: TXMLTag; Callback: TPacketEvent);
var
    q: TQueuedEvent;
begin
    // Queue an event to a specific Callback

    q := TQueuedEvent.Create();
    q.callback := TMethod(Callback);
    q.event := event;

    // make sure we make a dup of tag since it's going to go away after
    // it makes the rounds thru the dispatcher.
    q.tag := TXMLTag.Create(tag);
    _pauseQueue.Push(q);

end;

{---------------------------------------}
function TJabberSession.RegisterCallback(callback: TPacketEvent; xplite: string; pausable: boolean = false): integer;
var
    p, i: integer;
    l: TSignalListener;
    pk: TPacketListener;
    sig: TBasicSignal;
    tok1: string;
begin
    // add this callback to the packet signal
    Result := -1;
    p := Pos('/', Copy(xplite, 2, length(xplite) - 1));
    if p > 0 then
        tok1 := Copy(xplite, 1, p)
    else
        tok1 := xplite;

    // Find the correct signal to register with
    i := _dispatcher.IndexOf(tok1);
    if tok1 = '/packet' then begin
        pk := _packetSignal.addListener(xplite, callback);
        result := pk.cb_id;
    end
    else if i >= 0 then begin
        sig := TBasicSignal(_dispatcher.Objects[i]);
        l := sig.addListener(xplite, callback);
        result := l.cb_id;
    end;
end;

{---------------------------------------}
function TJabberSession.RegisterCallback(callback: TRosterEvent): integer;
var
    l: TRosterListener;
begin
    // add a callback to the roster signal
    l := _rosterSignal.addListener(callback);
    Result := l.cb_id;
end;

{---------------------------------------}
function TJabberSession.RegisterCallback(callback: TPresenceEvent): integer;
var
    l: TPresenceListener;
begin
    // add a callback to the presence signal
    l := _presSignal.addListener(callback);
    Result := l.cb_id;
end;

{---------------------------------------}
function TJabberSession.RegisterCallback(callback: TDataStringEvent): integer;
var
    sl: TStringListener;
begin
    // add a callback to the data signal
    sl := _dataSignal.addListener(callback);
    Result := sl.cb_id;
end;

{---------------------------------------}
procedure TJabberSession.FireEvent(event: string; tag: TXMLTag);
begin
    // dispatch some basic signal
    _dispatcher.DispatchSignal(event, tag);
end;

{---------------------------------------}
procedure TJabberSession.FireEvent(event: string; tag: TXMLTag; const p: TJabberPres);
begin
    // dispatch a presence signal directly
    _presSignal.Invoke(event, tag, p);
end;

{---------------------------------------}
procedure TJabberSession.FireEvent(event: string; tag: TXMLTag; const ritem: TJabberRosterItem);
begin
    // dispatch a roster event directly
    _rosterSignal.Invoke(event, tag, ritem);
end;

{---------------------------------------}
procedure TJabberSession.FireEvent(event: string; tag: TXMLTag; const data: WideString);
begin
    // dispatch a data event directly
    _dataSignal.Invoke(event, tag, data);
end;

{---------------------------------------}
procedure TJabberSession.UnRegisterCallback(index: integer);
begin
    // Unregister a callback
    if (index >= 0) then
        _dispatcher.DeleteListener(index);
end;

{---------------------------------------}
function TJabberSession.generateID: WideString;
begin
    Result := 'jcl_' + IntToStr(_id);
    _id := _id + 1;
end;


{---------------------------------------}
procedure TJabberSession.ActivateProfile(i: integer);
begin
    Assert((i >= 0) and (i < Prefs.Profiles.Count));

    // make this profile the active one..
    _profile := TJabberProfile(Prefs.Profiles.Objects[i]);
    _priority := _profile.Priority;
end;

{---------------------------------------}
procedure TJabberSession.setPresence(show, status: WideString; priority: integer);
var
    p: TJabberPres;
    i: integer;
begin
    _show := show;
    _status := status;
    _priority := priority;

    if (Self.Active) then begin
        p := TCapPresence.Create();
        p.Show := show;
        p.Status := status;
        if (priority = -1) then priority := 0;
        p.Priority := priority;

        // allow plugins to add stuff, by trapping this event
        MainSession.FireEvent('/session/before_presence', p);

        for i := 0 to Presence_XML.Count - 1 do
            p.addInsertedXML(Presence_XML[i]);

        // for invisible, only send to those people we've
        // directed presence to.
        if ((self.Invisible) and (Self.Active) and (not _first_pres)) then begin
            manualBlastPresence(p);
        end
        else begin
            if (_invisible) then
                p.setAttribute('type', 'invisible');
            SendTag(p);
            if (_first_pres) then _first_pres := false;
        end;

        // if we are going away or xa, save the prefs
        if ((show = 'away') or (show = 'xa')) then
            Prefs.SaveServerPrefs();

        MainSession.FireEvent('/session/presence', nil);

        if (_paused) then begin
            // If the session is paused, and we're changing back
            // to available, or chat, then make sure we play the session
            if ((_show <> 'away') and (_show <> 'xa') and (_show <> 'dnd')) then
                Self.Play();
        end;
    end;
end;

{---------------------------------------}
procedure TJabberSession.manualBlastPresence(p: TXMLTag);
var
    i: integer;
    xml: Widestring;
begin
    for i := 0 to _avails.Count - 1 do begin
        p.setAttribute('to', _avails[i]);
        xml := p.xml();
        _stream.Send(xml);
    end;
    p.Free();
end;

{---------------------------------------}
procedure TJabberSession.addAvailJid(jid: Widestring);
begin
    if (_avails.IndexOf(jid) < 0) then
        _avails.Add(jid);
end;

{---------------------------------------}
procedure TJabberSession.removeAvailJid(jid: Widestring);
var
    idx: integer;
begin
    idx := _avails.IndexOf(jid);
    if (idx >= 0) then
        _avails.Delete(idx);
end;

{---------------------------------------}
function TJabberSession.IsBlocked(jid : WideString): boolean;
var
    tmp_jid:  TJabberID;
begin
    tmp_jid := TJabberID.Create(jid);
    result := IsBlocked(tmp_jid);
    tmp_jid.Free();
end;

{---------------------------------------}
function TJabberSession.IsBlocked(jid : TJabberID): boolean;
var
    r1, r2: TJabberRosterItem;
    blockers: TWideStringList;
begin
    blockers := TWideStringList.Create();
    Prefs.fillStringlist('blockers', blockers);
    if (blockers.IndexOf(jid.jid) < 0) then
        result := false
    else
        result := true;
    blockers.Free();

    if ((not result) and (Prefs.getBool('block_nonroster'))) then begin
        // block this jid if they are not in my roster
        r1 := Roster.Find(jid.jid);
        r2 := nil;
        if (r1 = nil) then
            r2 := Roster.Find(jid.full);
        Result := ((r1 = nil) and (r2 = nil));
    end;
end;

{---------------------------------------}
procedure TJabberSession.UnBlock(jid : TJabberID);
var
    i: integer;
    blockers: TWideStringList;
    block : TXMLTag;
begin
    blockers := TWideStringList.Create();
    Prefs.fillStringlist('blockers', blockers);
    i := blockers.IndexOf(jid.jid);
    if (i >= 0) then begin
        blockers.Delete(i);
        Prefs.setStringlist('blockers', blockers);
    end;
    blockers.Free();
    block := TXMLTag.Create('unblock');
    block.setAttribute('jid', jid.jid);
    MainSession.FireEvent('/session/unblock', block);
    block.Free();
end;

{---------------------------------------}
procedure TJabberSession.Block(jid : TJabberID);
var
    blockers: TWideStringList;
    block: TXMLTag;
begin
    blockers := TWideStringList.Create();
    Prefs.fillStringlist('blockers', blockers);
    if (blockers.IndexOf(jid.jid) < 0) then begin
        blockers.Add(jid.jid);
        Prefs.setStringlist('blockers', blockers);
    end;
    blockers.Free();
    block := TXMLTag.Create('block');
    block.setAttribute('jid', jid.jid);
    MainSession.FireEvent('/session/block', block);
    block.Free();
end;

{---------------------------------------}
function TJabberSession.GetActive(): boolean;
begin
    Result := (_stream <> nil);
end;

{---------------------------------------}
procedure TJabberSession.setAuthAgent(new_auth: TJabberAuth);
begin
    if (assigned(_auth_agent)) then
        FreeAndNil(_auth_agent);
    _auth_agent := new_auth;
end;

{---------------------------------------}
function TJabberSession.getAuthAgent: TJabberAuth;
begin
    Result := _auth_agent;
end;

{---------------------------------------}
procedure TJabberSession.setAuthdJID(user, host, res: Widestring);
begin
    _profile.Username := user;
    _profile.Server := host;
    _profile.Resource := res;
end;

{---------------------------------------}
procedure TJabberSession.setAuthenticated(ok: boolean; tag: TXMLTag; reset_stream: boolean);
begin
    // our auth-agent is all set
    if (ok) then begin
        _authd := true;
        _profile.NewAccount := false;
        _register := false;

        if (reset_stream) then
            ResetStream()
        else
            StartSession(tag);
    end
    else begin
        _dispatcher.DispatchSignal('/session/autherror', tag);
    end;
end;

{---------------------------------------}
procedure TJabberSession.ResetStream();
var
    tmps: Widestring;
begin
    // send a new stream:stream...
    _stream.ResetParser();
    tmps := '<stream:stream to="' + Trim(Server) +
        '" xmlns="jabber:client" ' +
        'xmlns:stream="http://etherx.jabber.org/streams" ' +
        'version="1.0" ' +
        '>';
    _stream.Send(tmps);
end;

{---------------------------------------}
procedure TJabberSession.StartTLS();
var
    s: TXMLTag;
begin
    _tls_cb := Self.RegisterCallback(TLSCallback,
        '/packet/proceed[@xmlns="urn:ietf:params:xml:ns:xmpp-tls"]');

    s := TXMLTag.Create('starttls');
    s.setAttribute('xmlns', 'urn:ietf:params:xml:ns:xmpp-tls');
    Self.SendTag(s);
end;

{---------------------------------------}
procedure TJabberSession.TLSCallback(event: string; tag: TXMLTag);
begin
    Self.UnRegisterCallback(_tls_cb);
    _tls_cb := -1;

    if (event <> 'xml') then begin
        // XXX: kill everything here?
        exit;
    end;

    _stream.EnableSSL();
    ResetStream();
    _ssl_on := true;
end;

end.

