unit Avatar;
{
    Copyright 2004, Peter Millard

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
    Session, IQ,
    Unicode, JabberUtils, SecHash, Graphics, IdCoderMime, GifImage, Jpeg, XMLTag,
    Types, SysUtils, Classes;

type

    TAvatarType = (avOLD, avCard);

    TAvatar = class
    public
        constructor Create();
        destructor Destroy(); override;

    private
        _pic: TGraphic;
        _hash: string;  // contains the sha1 hash
        _data: string;  // contains the base64 encoded image
        _iq: TJabberIQ;
        _height, _width: integer;

        procedure _genData();
        function getMimeType(): string;

    protected
        procedure fetchCallback(event: string; tag: TXMLTag);

    public
        jid: Widestring;
        AvatarType: TAvatarType;
        Valid: boolean;
        Pending: boolean;

        procedure SaveToFile(var filename: string);
        procedure LoadFromFile(filename: string);
        procedure Draw(c: TCanvas; r: TRect); overload;
        procedure Draw(c: TCanvas); overload;
        procedure parse(tag: TXMLTag);
        procedure fetch(session: TJabberSession);

        function  getHash(): string;
        function  isValid(): boolean;

        property  Data: string read _data;
        property  MimeType: string read getMimeType;
        property  Height: integer read _height;
        property  Width: integer read _width;
    end;

    TAvatarCache = class
    private
        _cache: TWidestringlist;
        _session: TJabberSession;
        _pres1: integer;
        _pres2: integer;
        _sess: integer;

        _xp1: TXPLite;
        _xp2: TXPLite;

    protected
        procedure presCallback(event: string; tag: TXMLTag);
        procedure sessionCallback(event: string; tag: TXMLTag);

    public
        constructor Create();
        destructor  Destroy(); override;

        procedure Clear();
        procedure setSession(session: TJabberSession);
        procedure Save();
        procedure Load();
        
        function Add(jid: Widestring; a: TAvatar): integer;
        function Find(jid: Widestring): TAvatar;
    end;

var
    Avatars: TAvatarCache;

implementation
uses
    XMLParser, PrefController, JabberID;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TAvatar.Create();
begin
    inherited;
    _pic := nil;
    _iq := nil;
    _hash := '';
    _data := '';
    Valid := false;
end;

{---------------------------------------}
destructor TAvatar.Destroy();
begin
    if (_pic <> nil) then FreeAndNil(_pic);
    inherited;
end;

{---------------------------------------}
procedure TAvatar.SaveToFile(var filename: string);
var
    base: string;
begin
    if (_pic = nil) then exit;
    
    base := ChangeFileExt(filename, '');
    if (_pic is TGifImage) then begin
        filename := base + '.gif';
        TGifImage(_pic).SaveToFile(filename);
    end
    else if (_pic is TJPEGImage) then begin
        filename := base + '.jpg';
        TJPEGImage(_pic).SaveToFile(filename);
    end
    else begin
        filename := base + '.bmp';
        TBitmap(_pic).SaveToFile(filename);
   end;
end;

{---------------------------------------}
procedure TAvatar.LoadFromFile(filename: string);
var
    ext: string;
begin
    Valid := false;
    ext := Lowercase(ExtractFileExt(filename));
    if (ext = '.gif') then begin
        _pic := TGifImage.Create();
        _pic.Transparent := true;
        _pic.LoadFromFile(filename);
    end
    else if ((ext = '.jpg') or (ext = '.jpeg')) then begin
        _pic := TJpegImage.Create();
        _pic.Transparent := true;
        _pic.LoadFromFile(filename);
    end
    else if (ext = '.bmp') then begin
        _pic := TBitmap.Create();
        _pic.Transparent := true;
        _pic.LoadFromFile(filename);
    end
    else begin
        if (_pic <> nil) then FreeAndNil(_pic);
    end;

    if (_pic.Width > 256) then begin
        // resize
    end;

    _genData();
end;

{---------------------------------------}
procedure TAvatar._genData();
var
    m: TMemoryStream;
    c: TIdEncoderMime;
begin
    _hash := '';
    _data := '';
    m := TMemoryStream.Create();
    if (_pic <> nil) then
        _pic.SaveToStream(m)
    else begin
        m.Free();
        exit;
    end;

    m.Position := 0;
    c := TIdEncoderMime.Create(nil);
    _data := c.Encode(m);
    c.Free();

    _height := _pic.Height;
    _width := _pic.Width;

    Valid := true;
end;

{---------------------------------------}
function TAvatar.getHash(): string;
var
    i: integer;
    m: TMemoryStream;
    hasher: TSecHash;
    h: TIntDigest;
    s: string;
begin
    if (_hash <> '') then begin
        Result := _hash;
        exit;
    end;

    m := TMemoryStream.Create();
    if (_pic <> nil) then
        _pic.SaveToStream(m)
    else begin
        m.Free();
        exit;
    end;
    m.Position := 0;
    hasher := TSecHash.Create(nil);
    h := hasher.ComputeMem(m.Memory, m.Size);
    for i := 0 to 4 do
        s := s + IntToHex(h[i], 8);
    _hash := Lowercase(s);

    m.Free();
    hasher.Free();
    Result := _hash;
end;

{---------------------------------------}
procedure TAvatar.Draw(c: TCanvas; r: TRect);
begin
    if (_pic = nil) then exit;
    c.StretchDraw(r, _pic);
end;

{---------------------------------------}
procedure TAvatar.Draw(c: TCanvas);
begin
    if (_pic = nil) then exit;
    c.Draw(1, 1, _pic);
end;

{---------------------------------------}
procedure TAvatar.parse(tag: TXMLTag);
var
    mt: Widestring;
    m: TMemoryStream;
    d: TIdDecoderMime;
    i: integer;
    tmps: TWidestringList;
begin
    Valid := false;
    if (_pic <> nil) then FreeAndNil(_pic);

    tmps := TWidestringList.Create();
    split(tag.Data, tmps);
    _data := '';
    for i := 0 to tmps.Count - 1 do begin
        _data := _data + tmps[i];
    end;

    m := TMemoryStream.Create();
    d := TIdDecoderMime.Create(nil);
    try
        d.DecodeToStream(_data, m);
        m.Position := 0;

        mt := tag.GetAttribute('mimetype');
        if (mt = '') then mt := tag.GetAttribute('mime-type');
        if (mt = '') then mt := tag.GetAttribute('type');

        if (mt = 'image/gif') then begin
            _pic := TGifImage.Create();
            _pic.Transparent := true;
            _pic.LoadFromStream(m);
            _genData();
        end
        else if (mt = 'image/jpeg') then begin
            _pic := TJPEGImage.Create();
            _pic.Transparent := true;
            _pic.LoadFromStream(m);
            _genData();
        end
        else if (mt = 'image/x-ms-bmp') or (mt = 'image/bmp') then begin
            _pic := TBitmap.Create();
            _pic.Transparent := true;
            _pic.LoadFromStream(m);
            _genData();
        end
        else if (_data <> '') then begin
            try
                _pic := TJPEGImage.Create();
                _pic.Transparent := true;
                _pic.LoadFromStream(m);
                _genData();
            except
                try
                    FreeAndNil(_pic);
                    m.Position := 0;
                    _pic := TGifImage.Create();
                    _pic.Transparent := true;
                    _pic.LoadFromStream(m);
                    _genData();
                except
                    try
                        FreeAndNil(_pic);
                        m.Position := 0;
                        _pic := TBitmap.Create();
                        _pic.Transparent := true;
                        _pic.LoadFromStream(m);
                        _genData();
                    except
                        FreeAndNil(_pic);
                    end;
                end;
            end;
        end;
    except
        if (_pic <> nil) then FreeAndNil(_pic);
    end;

    m.Free();
    d.Free();
end;

{---------------------------------------}
procedure TAvatar.fetch(session: TJabberSession);
var
    tmpjid: TJabberID;
begin
    //
    tmpjid := TJabberID.Create(jid);
    assert(_iq = nil);
    assert(jid <> '');
    _iq := TJabberIQ.Create(session, session.generateID(), fetchCallback);
    _iq.iqType := 'get';
    Pending := true;

    if (AvatarType = avOld) then begin
        _iq.Namespace := 'jabber:iq:avatar';
        _iq.toJid := tmpjid.full;
        _iq.Send();
    end
    else begin
        _iq.Namespace := 'vcard-temp';
        _iq.toJid := tmpjid.jid;
        _iq.Send();
    end;
    tmpjid.Free();
end;

{---------------------------------------}
procedure TAvatar.fetchCallback(event: string; tag: TXMLTag);
var
    tmpjid: TJabberID;
    q, d: TXMLTag;
begin
    _iq := nil;
    Pending := false;
    if (event <> 'xml') then exit;

    if (AvatarType = avOld) then begin
        q := tag.GetFirstTag('query');
        if (q <> nil) then begin
            d := q.GetFirstTag('data');
            if (d <> nil) then Parse(d);
        end;
    end
    else begin
        q := tag.GetFirstTag('vcard');
        if (q = nil) then
            q := tag.GetFirstTag('VCARD');
        if (q = nil) then
            q := tag.GetFirstTag('vCard');
        if (q = nil) then
            q := tag.GetFirstTag('query');
            
        if (q <> nil) then begin
            d := q.GetFirstTag('PHOTO');
            if (d <> nil) then Parse(d);
        end;
    end;

    if (Valid) then begin
        tmpjid := TJabberID.Create(jid);
        Avatars.Add(tmpjid.jid, Self);
        tmpjid.Free();
        MainSession.FireEvent('/session/avatars', nil);
    end;
end;

function TAvatar.getMimeType: string;
begin
    if (_pic = nil) then
        Result := 'INVALID'
    else if (Valid = false) then
        Result := 'INVALID'
    else if (_pic is TGifImage) then
        Result := 'image/gif'
    else if (_pic is TJPEGImage) then
        Result := 'image/jpeg'
    else if (_pic is TBitmap) then
        Result := 'image/x-ms-bmp';
end;

function TAvatar.isValid(): boolean;
begin
    Result := (_pic <> nil);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TAvatarCache.Create();
begin
    inherited Create;
    _cache := TWidestringlist.Create();

    _xp1 := TXPLite.Create('/presence/x[@xmlns="jabber:x:avatar"]');
    _xp2 := TXPLite.Create('/presence/x[@xmlns="vcard-temp:x:update"]');
end;

{---------------------------------------}
destructor  TAvatarCache.Destroy();
begin
    Clear();
    inherited;
end;

{---------------------------------------}
function TAvatarCache.Add(jid: Widestring; a: TAvatar): integer;
var
    o: TAvatar;
    i: integer;
begin
    i := _cache.IndexOf(jid);
    if (i >= 0) then begin
        o := TAvatar(_cache.Objects[i]);
        if (o <> a) then begin
            o.Free();
            _cache.Objects[i] := a;
        end;
    end
    else begin
        i := _cache.AddObject(jid, a);
    end;

    Result := i;
end;

{---------------------------------------}
procedure TAvatarCache.Clear();
begin
    while (_cache.Count > 0) do begin
        TAvatar(_cache.Objects[0]).Free();
        _cache.Delete(0);
    end;
end;

{---------------------------------------}
function TAvatarCache.Find(jid: Widestring): TAvatar;
var
    i: integer;
begin
    i := _cache.IndexOf(jid);
    if (i >= 0) then
        Result := TAvatar(_cache.Objects[i])
    else
        Result := nil;
end;

{---------------------------------------}
procedure TAvatarCache.setSession(session: TJabberSession);
begin
    //
    _session := session;
    _pres1 := _session.RegisterCallback(presCallback,
        '/packet/presence/x[@xmlns="vcard-temp:x:update"]');
    _pres2 := _session.RegisterCallback(presCallback,
        '/packet/presence/x[@xmlns="jabber:x:avatar"]');
    _sess := _session.RegisterCallback(sessionCallback, '/session');

    Load();
end;

{---------------------------------------}
procedure TAvatarCache.presCallback(event: string; tag: TXMLTag);
var
    fetch: boolean;
    a: TAvatar;
    fjid: TJabberID;
    hash: Widestring;
    x1: TXMLTag;
    x2: TXMLTag;
begin
    // we got an avatar enabled presence
    fetch := false;
    fjid := TJabberID.Create(tag.getAttribute('from'));

    x1 := tag.QueryXPTag(_xp1);
    x2 := tag.QueryXPTag(_xp2);

    if (x2 <> nil) then
        hash := x2.GetBasicText('photo')
    else
        hash := x1.GetBasicText('hash');

    assert((x1 <> nil) or (x2 <> nil));

    a := find(fjid.jid);
    if (a = nil) then begin
        fetch := true;
        a := TAvatar.Create();
        _cache.AddObject(fjid.jid, a);
    end
    else begin
        // compare hashes
        if (a.Pending) then
            fetch := false
        else if (hash <> a.getHash()) then
            fetch := true;
    end;

    if (fetch) then begin
        a.jid := fjid.full;
        if (x2 <> nil) then
            a.AvatarType := avCard
        else
            a.AvatarType := avOld;
        a.Fetch(_session);
    end;

    fjid.Free();
end;

{---------------------------------------}
procedure TAvatarCache.sessionCallback(event: string; tag: TXMLTag);
begin
    if (event = '/session/disconnected') then
        Save();
end;

{---------------------------------------}
procedure TAvatarCache.Load();
var
    a: TAvatar;
    i: integer;
    jid: Widestring;
    name, path, fn: string;
    p: TXMLTagParser;
    root, t: TXMLTag;
    items: TXMLTagList;
begin
    path := getUserDir() + 'avatars';
    if (DirectoryExists(path) = false) then exit;

    fn := path + '\cache.xml';
    if (FileExists(fn)) then begin
        p := TXMLTagParser.Create();
        p.ParseFile(fn);
        root := p.popTag();
        if (root <> nil) then begin
            items := root.QueryTags('item');
            for i := 0 to items.Count - 1 do begin
                t := items[i];
                //name := path + '\' + t.GetAttribute('name');
                name := t.GetAttribute('name');
                jid := t.GetAttribute('jid');
                if ((jid <> '') and (name <> '') and (FileExists(name))) then begin
                    a := TAvatar.Create();
                    a.LoadFromFile(name);
                    _cache.AddObject(jid, a);
                end;
            end;
            items.Free();
            root.Free();
        end;
        p.Free();
    end;
end;

{---------------------------------------}
procedure TAvatarCache.Save();
var
    i: integer;
    a: TAvatar;
    jid: Widestring;
    fn, path, name: string;
    root, t: TXMLTag;
    s: TWidestringlist;
    tmp: TJabberID;
begin
    path := getUserDir() + 'avatars';
    if (DirectoryExists(path) = false) then
        CreateDir(path);
    if (DirectoryExists(path) = false) then exit;

    fn := path + '\cache.xml';

    root := TXMLTag.Create('cache');
    for i := 0 to _cache.Count - 1 do begin
        a := TAvatar(_cache.Objects[i]);
        tmp := TJabberID.Create(a.jid);
        jid := tmp.jid;
        tmp.Free();
        name := path + '\' + a.getHash();
        a.SaveToFile(name);
        t := root.AddTag('item');
        t.setAttribute('name', name);
        t.setAttribute('jid', jid);
    end;

    s := TWidestringlist.Create();
    s.Add(root.xml);
    s.SaveToFile(fn);
    s.Free();

    root.Free();
end;

initialization
    Avatars := TAvatarCache.Create();

finalization
    Avatars.Free();

end.
