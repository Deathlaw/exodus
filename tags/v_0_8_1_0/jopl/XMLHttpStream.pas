{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W+,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}

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


{$ifdef VER150}
    {$define INDY9}
{$endif}

unit XMLHttpStream;

interface

uses
    XMLTag,
    XMLStream,
    PrefController,
    {$ifdef linux}
    QExtCtrls,
    {$else}
    ExtCtrls,
    {$endif}

    {$ifdef INDY9}
    IdHTTPHeaderInfo,
    IdCoderMime,
    {$else}
    IdCoder3To4,
    {$endif}

    Classes, SysUtils, IdException, SecHash,
    IdHTTP, SyncObjs;

type
    THttpThread = class;

    TXMLHttpStream = class(TXMLStream)
    private
        _thread:    THttpThread;
    protected
        procedure MsgHandler(var msg: TJabberMsg); message WM_JABBER;
    public
        constructor Create(root: string); override;
        destructor Destroy; override;

        procedure Connect(profile: TJabberProfile); override;
        procedure Send(xml: Widestring); override;
        procedure Disconnect; override;
end;

    THttpThread = class(TParseThread)
    private
        _profile : TJabberProfile;
        _poll_id: string;
        _poll_time: integer;
        _http: TIdHttp;
        _request: TStringlist;
        _response: TStringStream;
        _cookie_list : TStringList;
        _lock: TCriticalSection;
        _event: TEvent;
        _hasher : TSecHash;
        {$ifdef INDY9}
        _encoder: TIdEncoderMIME;
        {$else}
        _encoder: TIdBase64Encoder;
        {$endif}

        _keys: array of string;
        _kcount: integer;

        procedure GenKeys();
        procedure DoPost();
    protected
        procedure Run; override;
    public
        constructor Create(strm: TXMLHttpStream; profile: TJabberProfile; root: string);
        destructor Destroy(); override;

        procedure Send(xml: WideString);
        procedure Disconnect(end_tag: string);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
uses
    {$ifdef Win32}
    Registry, StrUtils,
    {$endif}

    IdGlobal;

const
    MIN_TIME : integer = 250;
    INCREASE_FACTOR : single = 1.5;

{---------------------------------------}
constructor TXMLHttpStream.Create(root: string);
begin
    //
    inherited;
    _thread := nil;
end;

{---------------------------------------}
destructor TXMLHttpStream.Destroy;
begin
    //
    inherited;
end;

{---------------------------------------}
procedure TXMLHttpStream.Connect(profile: TJabberProfile);
begin
    // kick off the thread.

    // TODO: check to see if the thread will get freed when it stops
    _thread := THttpThread.Create(Self, profile, _root_tag);
    _thread.doMessageSync(WM_CONNECTED);
    _thread.Start();
end;

{---------------------------------------}
procedure TXMLHttpStream.Send(xml: Widestring);
begin
    if (_thread <> nil) then begin
        DoDataCallbacks(true, xml);
        _thread.Send(xml);
    end;
end;

{---------------------------------------}
procedure TXMLHttpStream.Disconnect;
var
end_tag: string;
begin
end_tag := '</' + Self._root_tag + '>';
    DoDataCallbacks(true, end_tag);
    _thread.Disconnect(end_tag);
    _thread.doMessageSync(WM_DISCONNECTED);

    // Note that the free will free itself.
end;

{---------------------------------------}
procedure TXMLHttpStream.MsgHandler(var msg: TJabberMsg);
var
    tmps: string;
    tag: TXMLTag;
begin
    //
    case msg.lparam of

        WM_XML: begin
            // We are getting XML data from the thread
            if _thread = nil then exit;

            tag := _thread.GetTag;
            if tag <> nil then begin
                DoCallbacks('xml', tag);
            end;
        end;

        WM_SOCKET: begin
            // We are getting something on the socket
            tmps := _thread.Data;
            if tmps <> '' then
                DoDataCallbacks(false, tmps);
        end;
        WM_CONNECTED: begin
            // Socket is connected
            _active := true;
            DoCallbacks('connected', nil);
        end;

        WM_DISCONNECTED: begin
            // Socket is disconnected
            _active := false;
            DoCallbacks('disconnected', nil);
        end;
        WM_COMMERROR: begin
            // There was a COMM ERROR
            _active := false;
            DoCallbacks('disconnected', nil);
            DoCallbacks('commerror', nil);
        end;
    end;
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor THttpThread.Create(strm: TXMLHttpStream; profile: TJabberProfile; root: string);
var
    {$ifdef Win32}
    reg: TRegistry;
    {$endif}
    srv: string;
    colon: integer;
begin
    inherited Create(strm, root);

    _profile := profile;
    _poll_id := '0';
    _poll_time := MIN_TIME;
    _http := TIdHTTP.Create(nil);
    {$ifdef INDY9}
    _http.AllowCookies := true;
    {$endif}
    _cookie_list := TStringList.Create();
    _cookie_list.Delimiter := ';';
    _cookie_list.QuoteChar := #0;
    _lock := TCriticalSection.Create();
    _event := TEvent.Create(nil, false, false, 'exodus_http_poll');
    _hasher := TSecHash.Create(nil);
    {$ifdef INDY9}
    _encoder := TIdEncoderMIME.Create(nil);
    {$else}
    _encoder := TIdBase64Encoder.Create(nil);
    {$endif}
    SetLength(_keys, _profile.NumPollKeys); 
    GenKeys();

    _request := TStringlist.Create();
    _response := TStringstream.Create('');

    if (_profile.ProxyApproach = http_proxy_ie) then begin
        // get IE settings from registry

        // todo: figure out some way of doing this XP??
        {$ifdef Win32}
        reg := TRegistry.Create();
        try
            reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', false);
            if (reg.ValueExists('ProxyEnable') and
                (reg.ReadInteger('ProxyEnable') <> 0)) then begin
                srv := reg.ReadString('ProxyServer');
                colon := pos(':', srv);
                {$ifdef INDY9}
                with _http.ProxyParams do begin
                    ProxyServer := Copy(srv, 1, colon-1);
                    ProxyPort := StrToInt(Copy(srv, colon+1, length(srv)));
                end;
                {$else}
                with _http.Request do begin
                    ProxyServer := Copy(srv, 1, colon-1);
                    ProxyPort := StrToInt(Copy(srv, colon+1, length(srv)));
                end;
                {$endif}
            end;
        finally
            reg.Free();
        end;
        {$endif}
        
    end
    else if (_profile.ProxyApproach = http_proxy_custom) then begin
        {$ifdef INDY9}
        with _http.ProxyParams do begin
        {$else}
        with _http.Request do begin
        {$endif}
            ProxyServer := _profile.ProxyHost;
            ProxyPort := _profile.ProxyPort;
            if (_profile.ProxyAuth) then begin
                ProxyUsername := _profile.ProxyUsername;
                ProxyPassword := _profile.ProxyPassword;
            end;
        end;
    end;
end;

{---------------------------------------}
destructor THttpThread.Destroy();
begin
   _lock.Free();
   _hasher.Free();
   _encoder.Free();
   _event.Free();
   _cookie_list.Free();
   _http.Free();
   _request.Free();
   _response.Free();
end;

procedure THttpThread.GenKeys;
var
    i, j : integer;
    seed : string;
    b: TByteDigest;
    ts : string;
begin
    for i := 1 to 21 do
        seed := seed + chr(random(95) + 32);

    _kcount := length(_keys) - 1;
    for i := 0 to _kcount do begin
        b := _hasher.IntDigestToByteDigest(_hasher.ComputeString(seed));
        ts := '';
        for j := 0 to 19 do
            ts := ts + chr(b[j]);
        {$ifdef INDY9}
        seed := _encoder.Encode(ts);
        _keys[i] := seed;
        {$else}
        _encoder.CodeString(ts);
        seed := _encoder.CompletedInput;
        Fetch(seed, ';');
        _keys[i] := seed;
        {$endif}
    end;
end;

{---------------------------------------}
procedure THttpThread.Send(xml: Widestring);
begin
    _lock.Acquire();
    _request.Add(UTF8Encode(xml));
    _lock.Release();
    _event.SetEvent();
end;

{---------------------------------------}
procedure THttpThread.DoPost();
var
    key : string;
begin
    // nuke whatever is currently in the stream
    _response.Size := 0;

    key := _poll_id + ';' + _keys[_kcount];
    dec(_kcount);
    if (_kcount < 0) then begin
        GenKeys();
        key := key + ';' + _keys[_kcount];
        dec(_kcount);
        Assert(_kcount <> 0);
    end;

    _request.Insert(0, key + ',');
    try
        _lock.Acquire();
        _http.Post(_profile.URL, _request, _response);
        _request.Clear();
        _lock.Release();
    except
        on E: Exception do begin
            if (not Self.Stopped) then begin
                doMessage(WM_COMMERROR);
                Self.Terminate();
            end;
            exit;
    end;
end;
end;

{---------------------------------------}
procedure THttpThread.Run();
var
    r, pid, new_cookie: string;
    i: integer;
begin
    // Bail if we're stopped.
    if ((Self.Stopped) or (Self.Suspended) or (Self.Terminated)) then
        exit;

    Self.DoPost();

    // parse the response stream
    if (_http.ResponseCode <> 200) then begin
        // HTTP error!
        doMessage(WM_COMMERROR);
        Self.Terminate();
        exit;
    end;

    pid := '';

    // Get the cookie values + parse them, looking for the ID
    {$ifdef INDY9}
    // TODO: Make this work w/ Indy9... this is probably close
    pid := _http.CookieManager.CookieCollection.Cookie['ID', ''].CookieText;
    {$else}
    new_cookie := _http.Response.ExtraHeaders.Values['Set-Cookie'];
    _cookie_list.DelimitedText := new_cookie;
    for i := 0 to _cookie_list.Count - 1 do begin
        if (Pos('ID=', _cookie_list[i]) = 1) then begin
            pid := Copy(_cookie_list[i], 4, length(_cookie_list[i]));
            break;
        end;
    end;
    {$endif}

    if (_poll_id = '0') then begin
        _poll_id := pid;
    end;

    // compare the most recent pid with our stored poll_id
    // if ((pid = '') or AnsiEndsStr(':0', pid) or (pid <> _poll_id)) then begin
    if ((pid = '') or (Pos(':0', pid) = length(pid) - 1) or (pid <> _poll_id)) then begin
        // something really bad has happened!
        doMessage(WM_COMMERROR);
        Self.Terminate();
        exit;
    end;

    r := UTF8Decode(_response.DataString);
    if (r <> '') then begin
        Push(r);
        _poll_time := MIN_TIME;
    end
    else if (_poll_time <> _profile.Poll) then begin
        _poll_time := Trunc(_poll_time * INCREASE_FACTOR);
        if (_poll_time >= _profile.Poll) then
            _poll_time := _profile.Poll;
    end;

    _event.WaitFor(_poll_time);
end;

{---------------------------------------}
procedure THttpThread.Disconnect(end_tag: string);
begin
    // Yes, we analyzed to see if there is a race condition.
    // There's not.
    Stop();
    _event.SetEvent();
    if (end_tag <> '') then begin
        Send(end_tag);
        DoPost();
    end;

    // Free me.  Touch me.  Feel me.
    Terminate();
end;

end.
