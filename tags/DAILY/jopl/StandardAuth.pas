unit StandardAuth;
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

interface

uses
    JabberAuth, IQ, Session, XMLTag,
    Classes, SysUtils;

type
    TJabberAuthType = (jatZeroK, jatDigest, jatPlainText, jatNoAuth);

    TStandardAuth = class(TJabberAuth)
        _session: TJabberSession;
        _AuthType: TJabberAuthType;
        _auth_iq: TJabberIQ;
        _token: TXMLTag;
        _sasl_auth: TJabberAuth;
        _auto_auth: boolean;

        procedure SendAuthGet;
        procedure SendRegistration;
        procedure SetTokenAuth(tag: TXMLTag);

    published
        procedure RegistrationCallback(event: string; xml: TXMLTag);
        procedure AuthGetCallback(event: string; xml: TXMLTag);
        procedure AuthCallback(event: string; tag: TXMLTag);

    public
        constructor Create(session: TJabberSession);
        destructor Destroy(); override;

        // TJabberAuth
        procedure StartAuthentication(); override;
        procedure CancelAuthentication(); override;

        function StartRegistration(): boolean; override;
        procedure CancelRegistration(); override;

        property TokenAuth: TXMLTag read _token write SetTokenAuth;
        property AutoAuth: boolean read _auto_auth write _auto_auth;
    end;


implementation
uses
    SASLAuth, JabberConst, XMLUtils, JabberID;

{---------------------------------------}
constructor TStandardAuth.Create(session: TJabberSession);
begin
    //
    _session := session;
    _auth_iq := nil;
    _token := nil;
    prompt_password := true;
    _sasl_auth := TSASLAuth.Create(session);
    _auto_auth := true;
end;

{---------------------------------------}
destructor TStandardAuth.Destroy();
begin
    //
    FreeAndNil(_sasl_auth);
    FreeAndNil(_auth_iq);
    FreeAndNil(_token);
end;

// IAuth Implementation
{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure TStandardAuth.StartAuthentication();
var
    feats: TXMLTag;
begin
    if (_session.isXMPP) then begin
        feats := _session.xmppFeatures;
        if (checkSASLFeatures(feats)) then
            _sasl_auth.StartAuthentication()
        else
            SendAuthGet();
    end
    else
        SendAuthGet();
end;

{---------------------------------------}
procedure TStandardAuth.CancelAuthentication();
begin
    // Clean out pending iq's
    if (_session.isXMPP) then
        _sasl_auth.CancelAuthentication()
    else if (_auth_iq <> nil) then
        FreeAndNil(_auth_iq);
end;

{---------------------------------------}
function TStandardAuth.StartRegistration(): boolean;
begin
    // Always try to register, even if XMPP
    SendRegistration();
    Result := true;
end;

{---------------------------------------}
procedure TStandardAuth.CancelRegistration();
begin
    // Clean out pending iq's
    if (_auth_iq <> nil) then
        FreeAndNil(_auth_iq);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure TStandardAuth.SendAuthGet;
begin
    // find out the potential auth kinds for this user
    if (_auth_iq <> nil) then _auth_iq.Free();

    _auth_iq := TJabberIQ.Create(_session, _session.generateID, AuthGetCallback, 180);
    with _auth_iq do begin
        Namespace := XMLNS_AUTH;
        iqType := 'get';
        // might not have username if tokenauth.
        if (_session.Username <> '') then
            qTag.AddBasicTag('username', _session.Username);
    end;
    _auth_iq.Send;
end;

{---------------------------------------}
procedure TStandardAuth.SendRegistration;
begin
    // send an iq register
    if (_auth_iq <> nil) then _auth_iq.Free();

    _auth_iq := TJabberIQ.Create(_session, _session.generateID, RegistrationCallback, 180);
    with _auth_iq do begin
        Namespace := XMLNS_REGISTER;
        iqType := 'set';
        with qTag do begin
            AddBasicTag('username', _session.Username);
            AddBasicTag('password', _session.Password);
        end;
    end;
    _auth_iq.Send;
end;

{---------------------------------------}
procedure TStandardAuth.RegistrationCallback(event: string; xml: TXMLTag);
begin
    // callback from our registration request
    _auth_iq := nil;
    if ((xml = nil) or (xml.getAttribute('type') = 'error')) then begin
        // NB: Don't call Disconnect from within a callback
        // rely on the application to catch this event and post
        // a message to disconnect
        _session.FireEvent('/session/regerror', xml);
    end
    else begin
        // We got a good registration...
        // Go do the entire Auth sequence now.
        if (_auto_auth) then
            // SendAuthGet()
            StartAuthentication()
        else
            _session.FireEvent('/session/regok', xml);
    end;
end;

{---------------------------------------}
procedure TStandardAuth.AuthGetCallback(event: string; xml: TXMLTag);
var
    etag, tok, seq, dig, qtag: TXMLTag;
    authDigest, authHash, authToken, hashA, key: WideString;
    i, authSeq: integer;
begin
    // auth get result or error
    _auth_iq := nil;
    if ((xml = nil) or (xml.getAttribute('type') = 'error')) then begin
        if (xml <> nil) then begin
            // check for non-existant account
            etag := xml.GetFirstTag('error');
            if ((etag <> nil) and
                (etag.getAttribute('code') = '401'))then begin
                _session.FireEvent('/session/noaccount', xml);
                exit;
            end;
        end;

        // otherwise, auth-error
        _session.FireEvent('/session/autherror', xml);
        exit;
    end;

    qtag := xml.GetFirstTag('query');
    if qtag = nil then exit;

    seq := qtag.GetFirstTag('sequence');
    tok := qtag.GetFirstTag('token');
    dig := qtag.GetFirstTag('digest');

    // setup the iq-set
    _auth_iq := TJabberIQ.Create(_session, _session.generateID, AuthCallback, 180);
    with _auth_iq do begin
        Namespace := XMLNS_AUTH;
        iqType := 'set';
        if (_session.Username <> '') then
            qTag.AddBasicTag('username', _session.Username);
        qTag.AddBasicTag('resource', _session.Resource);
    end;

    if (_token <> nil) then begin
        // token auth
        _auth_iq.qTag.AddTag(_token);
        end

    else if seq <> nil then begin
        if tok = nil then exit;
        // Zero-k auth
        _AuthType := jatZeroK;
        authSeq := StrToInt(seq.data);
        authToken := tok.Data;
        hashA := Sha1Hash(_session.Password);
        key := Sha1Hash(Trim(hashA) + Trim(authToken));
        for i := 1 to authSeq do
            key := Sha1Hash(key);
        authHash := key;
        _auth_iq.qTag.AddBasicTag('hash', authHash);
    end

    else if dig <> nil then begin
        // Digest (basic Sha1)
        _AuthType := jatDigest;
        authDigest := Sha1Hash(Trim(_session.StreamID + _session.Password));
        _auth_iq.qTag.AddBasicTag('digest', authDigest);
    end

    else begin
        // Plaintext
        _AuthType := jatPlainText;
        _auth_iq.qTag.AddBasicTag('password', _session.Password);
    end;
    _auth_iq.Send;
end;

{---------------------------------------}
procedure TStandardAuth.AuthCallback(event: string; tag: TXMLTag);
var
    val: TXMLTag;
    jid: TJabberID;
begin
    // check the result of the authentication
    _auth_iq := nil;
    if ((tag = nil) or (tag.getAttribute('type') = 'error')) then begin
        // timeout
        _session.setAuthenticated(false, tag, false);
    end
    else begin
        // look for tokenauth username, put in session.
        if (_session.Username = '') then begin
            val := tag.QueryXPTag('/iq/query[@xmlns="jabber:iq:auth"]/tokenauth[@xmlns="http://www.jabber.com/schemas/tokenauth.xsd"/x[@xmlns="jabber:x:data"]/field[@var="jid"]/value');
            if (val <> nil) then begin
              jid := TJabberID.Create(val.Data);
              _session.Username := jid.user;
              jid.Free();
            end;
        end;
        _session.setAuthenticated(true, tag, false);
    end;
end;

{---------------------------------------}
procedure TStandardAuth.SetTokenAuth(tag: TXMLTag);
begin
    prompt_password := false;
    _token := tag;
end;

end.
