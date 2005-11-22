unit Entity;
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
    IQ, DiscoIdentity, JabberID, XMLTag, Signals, Session, Unicode,
    Classes, SysUtils;

const

    // browse stuff
    FEAT_SEARCH         = 'search';
    FEAT_REGISTER       = 'register';
    FEAT_GROUPCHAT      = 'groupchat';
    FEAT_PRIVATE        = 'private';
    FEAT_PUBLIC         = 'gc-public';
    FEAT_JUD            = 'jud';
    FEAT_GATEWAY        = 'gateway';
    FEAT_AIM            = 'aim';
    FEAT_ICQ            = 'icq';
    FEAT_YAHOO          = 'yahoo';
    FEAT_MSN            = 'msn';
    FEAT_PROXY          = 'proxy';
    FEAT_BYTESTREAMS    = 'bytestreams';

    WALK_LIMIT          = 20;   // max # of items to do disco#info on
    WALK_MAX_TIMEOUT    = 30;   // max # of seconds for iq timeouts.

type

    TJabberEntityType = (ent_unknown, ent_disco, ent_browse, ent_agents);

    // This class is designed to gather information about a host.
    // It first tries disco, then falls back on browse, and finally agents.
    TJabberEntity = class
    published
        procedure ItemsCallback(event: string; tag: TXMLTag);
        procedure InfoCallback(event: string; tag: TXMLTag);
        procedure BrowseCallback(event: string; tag: TXMLTag);
        procedure AgentsCallback(event: string; tag: TXMLTag);
        
        procedure WalkCallback(event: string; tag: TXMLTag);
        procedure WalkItemsCallback(event: string; tag: TXMLTag);
        
    private
        _parent: TJabberEntity;
        _jid: TJabberID;
        _node: Widestring;
        _name: Widestring;
        _feats: TWidestringlist;
        _type: TJabberEntityType;

        _has_info: Boolean;             // do we need to do a disco#info?
        _has_items: boolean;            // do we have children?
        _items: TWidestringlist;        // our children
        _idents: TWidestringlist;       // our Identities
        _iq: TJabberIQ;

        _cat: Widestring;
        _cat_type: Widestring;

        _use_limit: boolean;
        _timeout: integer;
        _fallback: boolean;

        function _getFeature(i: integer): Widestring;
        function _getFeatureCount: integer;

        function _getItem(i: integer): TJabberEntity;
        function _getItemCount: integer;

        function _getIdentity(i: integer): TDiscoIdentity;
        function _getIdentityCount: integer;

        procedure _discoInfo(js: TJabberSession; callback: TSignalEvent);
        procedure _discoItems(js: TJabberSession; callback: TSignalEvent);

        procedure _processDiscoInfo(tag: TXMLTag);
        procedure _processDiscoItems(tag: TXMLTag);
        procedure _processLegacyFeatures();
        procedure _processBrowse(tag: TXMLTag);
        procedure _processBrowseItem(item: TXMLTag);
        procedure _processAgent(item: TXMLTag);

        procedure _finishDiscoItems(jso: TObject; tag: TXMLTag);
        procedure _finishWalk(jso: TObject);
        procedure _finishBrowse(jso: TObject);

    public
        Tag: integer;
        Data: TObject;
        
        constructor Create(jid: TJabberID; node: Widestring = '');
        destructor Destroy; override;

        procedure getInfo(js: TJabberSession);
        procedure getItems(js: TJabberSession);
        procedure walk(js: TJabberSession; items_limit: boolean = true;
            timeout: integer = 10);
        procedure refresh(js: TJabberSession);

        function ItemByJid(jid: Widestring; node: Widestring = ''): TJabberEntity;
        function hasFeature(f: Widestring): boolean;
        function getItemByFeature(f: Widestring): TJabberEntity;

        property Parent: TJabberEntity read _parent;
        property Jid: TJabberID read _jid;
        property Node: Widestring read _node;
        property entityType: TJabberEntityType read _type;
        property Category: Widestring read _cat;
        property CatType: Widestring read _cat_type;
        property Name: Widestring read _name;

        property hasItems: boolean read _has_items;
        property hasInfo: boolean read _has_info;

        property FeatureCount: Integer read _getFeatureCount;
        property Features[Index: integer]: Widestring read _getFeature;

        property ItemCount: Integer read _getItemCount;
        property Items[Index: integer]: TJabberEntity read _getItem;

        property IdentityCount: Integer read _getIdentityCount;
        property Identities[Index: integer]: TDiscoIdentity read _getIdentity;
        
        property fallbackProtocols: boolean read _fallback write _fallback;
        property timeout: integer read _timeout write _timeout;

    end;

    TJabberEntityProcess = class(TThread)
    public
        jso: TObject;
        tag: TXMLTag;
        e: TJabberEntity;
        ptype: integer;
    private
        procedure FinishDisco();
        procedure FinishBrowse();
        procedure FinishWalk();

    protected
        procedure Execute(); override;
    end;


implementation
uses
    {$ifdef Win32}
    Windows,
    {$endif}
    EntityCache, JabberConst, XMLUtils;

const
    ProcDisco = 0;
    ProcBrowse = 1;
    ProcWalk = 2;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure TJabberEntityProcess.Execute();
begin
    if (ptype = ProcDisco) then begin
        e._processDiscoItems(tag);
        Synchronize(FinishDisco);
    end
    else if (ptype = ProcBrowse) then begin
        e._processBrowse(tag);
        Synchronize(FinishBrowse);
    end
    else if (ptype = ProcWalk) then begin
        if (tag <> nil) then
            e._processDiscoitems(tag);
        Synchronize(FinishWalk);
    end;
    tag.Release();
end;

{---------------------------------------}
procedure TJabberEntityProcess.FinishDisco();
begin
    e._finishDiscoItems(jso, tag);
end;

{---------------------------------------}
procedure TJabberEntityProcess.FinishWalk();
begin
    e._finishWalk(jso);
end;

{---------------------------------------}
procedure TJabberEntityProcess.FinishBrowse();
begin
    e._finishBrowse(jso);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TJabberEntity.Create(jid: TJabberID; node: Widestring);
begin
    _parent := nil;
    _jid := jid;
    _node := '';
    _name := '';
    _feats := TWidestringlist.Create();
    _type := ent_unknown;
    _has_info := false;
    _has_items := false;

    _items := TWidestringlist.Create();
    _items.Sorted := false;

    _idents := TWidestringlist.Create();
    _idents.Sorted := false;

    _timeout := 10;
    _node := node;
    _fallback := true;

    Tag := -1;
    Data := nil;
end;

{---------------------------------------}
destructor TJabberEntity.Destroy;
begin
    if (_iq <> nil) then _iq.Free();
    
    jEntityCache.Remove(Self);
    ClearStringListObjects(_items);
    _items.Clear();
    ClearStringListObjects(_idents);
    _idents.Clear();
    _feats.Clear();
    FreeAndNil(_items);
    FreeAndNil(_feats);
    _jid.Free();
end;

{---------------------------------------}
function TJabberEntity._getFeature(i: integer): Widestring;
begin
    if (i < _feats.Count) then
        Result := _feats[i]
    else
        Result := '';
end;

{---------------------------------------}
function TJabberEntity.hasFeature(f: Widestring): boolean;
begin
    Result := (_feats.IndexOf(f) >= 0)
end;

{---------------------------------------}
function TJabberEntity._getFeatureCount: integer;
begin
    Result := _feats.Count;
end;

{---------------------------------------}
function TJabberEntity._getItem(i: integer): TJabberEntity;
begin
    if (i < _items.Count) then
        Result := TJabberEntity(_items.Objects[i])
    else
        Result := nil;
end;


{---------------------------------------}
function TJabberEntity._getIdentityCount: integer;
begin
    Result := _idents.Count;
end;

{---------------------------------------}
function TJabberEntity._getIdentity(i: integer): TDiscoIdentity;
begin
    if (i < _idents.Count) then
        Result := TDiscoIdentity(_idents.Objects[i])
    else
        Result := nil;
end;

{---------------------------------------}
function TJabberEntity.ItemByJid(jid: Widestring; node: Widestring): TJabberEntity;
var
    id: Widestring;
    i: integer;
begin
    if (node <> '') then
        id := node + ':' + jid
    else
        id := jid;

    i := _items.IndexOf(id);
    if (i >= 0) then
        Result := TJabberEntity(_items.Objects[i])
    else
        Result := nil;
end;

{---------------------------------------}
function TJabberEntity.getItemByFeature(f: Widestring): TJabberEntity;
var
    c: TJabberEntity;
    i: integer;
begin
    Result := nil;
    for i := 0 to _items.Count - 1 do begin
        c := TJabberEntity(_items.Objects[i]);
        if (c.hasFeature(f)) then begin
            Result := c;
            exit;
        end;
    end;
end;

{---------------------------------------}
function TJabberEntity._getItemCount: integer;
begin
    Result := _items.Count;
end;

{---------------------------------------}
procedure TJabberEntity._discoInfo(js: TJabberSession; callback: TSignalEvent);
begin
    // Dispatch a disco#info query
    _iq := TJabberIQ.Create(js, js.generateID(), callback, _timeout);
    _iq.toJid := _jid.full;
    _iq.Namespace := XMLNS_DISCOINFO;
    _iq.iqType := 'get';
    
    if (_node <> '') then
        _iq.qTag.setAttribute('node', _node);
        
    _iq.Send();
end;

{---------------------------------------}
procedure TJabberEntity.getInfo(js: TJabberSession);
var
    t: TXMLTag;
begin
    if (_iq <> nil) then exit;

    if ((_has_info) or (_type = ent_browse) or (_type = ent_agents)) then begin
        t := TXMLTag.Create('entity');
        t.setAttribute('from', _jid.full);
        js.FireEvent('/session/entity/info', t);
        t.Free();
        exit;
    end;

    _discoInfo(js, InfoCallback);
end;

{---------------------------------------}
procedure TJabberEntity._discoItems(js: TJabberSession; callback: TSignalEvent);
begin
    // Dispatch a disco#items query
    _iq := TJabberIQ.Create(js, js.generateID(), callback, _timeout);
    _iq.toJid := _jid.full;
    _iq.Namespace := XMLNS_DISCOITEMS;
    _iq.iqType := 'get';

    if (_node <> '') then
        _iq.qTag.setAttribute('node', _node);
        
    _iq.Send();
end;

{---------------------------------------}
procedure TJabberEntity.getItems(js: TJabberSession);
var
    t: TXMLTag;
begin
    if (_iq <> nil) then exit;
    
    if ((_has_items) or (_type = ent_browse) or (_type = ent_agents)) then begin
        // send info for ea. child
        t := TXMLTag.Create('entity');
        t.setAttribute('from', _jid.full);
        js.FireEvent('/session/entity/items', t);
        t.Free();
        exit;
    end;

    _discoItems(js, ItemsCallback);
end;

{---------------------------------------}
procedure TJabberEntity.ItemsCallback(event: string; tag: TXMLTag);
var
    pt: TJabberEntityProcess;
    js: TJabberSession;
begin
    assert(_iq <> nil);
    js := _iq.JabberSession;
    assert(js <> nil);
    _iq := nil;

    // if we're not connected anymore, just bail.
    if (js.Active = false) then exit;

    if ((event <> 'xml') or (tag.getAttribute('type') = 'error')) then begin
        // Dispatch a disco#items query
        if (not _fallback) then exit;

        _iq := TJabberIQ.Create(js, js.generateID(), Self.BrowseCallback, _timeout);
        _iq.toJid := _jid.full;
        _iq.Namespace := XMLNS_BROWSE;
        _iq.iqType := 'get';
        _iq.Send();
        exit;
    end;

    tag.AddRef();
    pt := TJabberEntityProcess.Create(true);
    pt.jso := js;
    pt.tag := tag;
    pt.ptype := ProcDisco;
    pt.e := Self;
    pt.FreeOnTerminate := true;
    pt.Resume();
end;

{---------------------------------------}
procedure TJabberEntity._finishDiscoItems(jso: TObject; tag: TXMLTag);
begin
    TJabberSession(jso).FireEvent('/session/entity/items', tag);
end;

{---------------------------------------}
procedure TJabberEntity._finishBrowse(jso: TObject);
var
    i: integer;
    js: TJabberSession;
    ce: TJabberEntity;
    t: TXMLTag;
begin
    // send events for this entity
    js := TJabberSession(jso);
    getInfo(js);
    getItems(js);

    // Send info for each child
    t := TXMLTag.Create('entity');
    for i := 0 to _items.Count - 1 do begin
        ce := TJabberEntity(_items.Objects[i]);
        t.setAttribute('from', ce.jid.full);
        js.FireEvent('/session/entity/info', t);
    end;
    t.Free();
end;

{---------------------------------------}
procedure TJabberEntity.InfoCallback(event: string; tag: TXMLTag);
var
    js: TJabberSession;
begin
    // if disco didn't so much workout, try browse next
    assert(_iq <> nil);
    js := _iq.JabberSession;
    assert(js <> nil);
    _iq := nil;

    // if we're not connected anymore, just bail.
    if (js.Active = false) then exit;

    if ((event <> 'xml') or (tag.getAttribute('type') = 'error')) then begin
        // Dispatch a browse query
        if (not _fallback) then begin
            _has_info := true;
            js.FireEvent('/session/entity/info', tag);
            exit;
        end;
        
        _iq := TJabberIQ.Create(js, js.generateID(), Self.BrowseCallback, _timeout);
        _iq.toJid := _jid.full;
        _iq.Namespace := XMLNS_BROWSE;
        _iq.iqType := 'get';
        _iq.Send();
        exit;
    end;

    _processDiscoInfo(tag);
    js.FireEvent('/session/entity/info', tag);
end;

{---------------------------------------}
procedure TJabberEntity.walk(js: TJabberSession; items_limit: boolean;
    timeout: integer);
begin
    // Get Items, then get info for each one.
    if (_iq <> nil) then exit;
    
    _use_limit := items_limit;
    _timeout := timeout;
    _discoInfo(js, WalkCallback);
end;

{---------------------------------------}
procedure TJabberEntity.refresh(js: TJabberSession);
begin
    if (_iq <> nil) then exit;

    _has_info := false;
    _has_items := false;
    _type := ent_unknown;

    ClearStringListObjects(_items);
    _items.Clear();
    _feats.Clear();

    _discoInfo(js, WalkCallback);
end;

{---------------------------------------}
procedure TJabberEntity._processDiscoInfo(tag: TXMLTag);
var
    id, q: TXMLTag;
    fset: TXMLTagList;
    i: integer;
begin
    {
    We get back something like:
        <iq
            type='result'
            from='plays.shakespeare.lit'
            to='romeo@montague.net/orchard'
            id='info1'>
          <query xmlns='http://jabber.org/protocol/disco#info'>
            <identity
                category='conference'
                type='text'
                name='Play-Specific Chatrooms'/>
            <identity
                category='directory'
                type='room'
                name='Play-Specific Chatrooms'/>
            <feature var='gc-1.0'/>
            <feature var='http://jabber.org/protocol/muc'/>
            <feature var='jabber:iq:register'/>
            <feature var='jabber:iq:search'/>
            <feature var='jabber:iq:time'/>
            <feature var='jabber:iq:version'/>
          </query>
        </iq>
    }

    _has_info := true;
    _feats.Clear();
    _idents.Clear();

    q := tag.GetFirstTag('query');
    if (q = nil) then exit;

    // process features
    fset := q.QueryTags('feature');
    for i := 0 to fset.count - 1 do
        _feats.Add(fset[i].GetAttribute('var'));
    fset.Free();

    // XXX: Is this what to do w/ the other <identity> elements?
    fset := q.QueryTags('identity');
    for i := 0 to fset.count - 1 do begin
        id := fset[i];
        _idents.AddObject(id.GetAttribute('category') + '/' + id.GetAttribute('type'),
                          TDiscoIdentity.Create(id.GetAttribute('category'),
                                                id.GetAttribute('type'),
                                                id.GetAttribute('name')));
        if i = 0 then begin
            _cat := id.getAttribute('category');
            _cat_type := id.getAttribute('type');
            if (_name = '') then
                _name := id.getAttribute('name');
        end;
    end;
    fset.Free();

    _processLegacyFeatures();
end;

{---------------------------------------}
procedure TJabberEntity._processLegacyFeatures();
begin
    // check for some legacy stuff..
    if (_feats.IndexOf(XMLNS_SEARCH) >= 0) then _feats.Add(FEAT_SEARCH);
    if (_feats.IndexOf(XMLNS_REGISTER) >= 0) then _feats.Add(FEAT_REGISTER);
    if (_feats.IndexOf(XMLNS_MUC) >= 0) then _feats.Add(FEAT_GROUPCHAT);
    if (_feats.IndexOf('gc-1.0') >= 0) then _feats.Add(FEAT_GROUPCHAT);
    if (_cat = 'conference') then
        _feats.Add(FEAT_GROUPCHAT);

    // this is for transports.
    if (_cat_type = FEAT_AIM) then _feats.Add(FEAT_AIM)
    else if (_cat_type = FEAT_MSN) then _feats.Add(FEAT_MSN)
    else if (_cat_type = FEAT_ICQ) then _feats.Add(FEAT_ICQ)
    else if (_cat_type = FEAT_YAHOO) then _feats.Add(FEAT_YAHOO)
    else if (_feats.IndexOf('jabber:iq:gateway') >= 0) then _feats.Add(_cat_type);
end;

{---------------------------------------}
procedure TJabberEntity._processDiscoItems(tag: TXMLTag);
var
    q: TXMLTag;
    iset: TXMLTagList;
    idx, i: integer;
    id, nid, tmps: Widestring;
    cj: TJabberID;
    ce: TJabberEntity;
begin
    {
    <iq
        type='result'
        from='catalog.shakespeare.lit'
        to='romeo@montague.net/orchard'
        id='items2'>
      <query xmlns='http://jabber.org/protocol/disco#items'>
        <item
            jid='catalog.shakespeare.lit'
            node='books'
            name='Books by and about Shakespeare'/>
        <item
            jid='catalog.shakespeare.lit'
            node='clothing'
            name='Show off your literary taste'/>
        <item
            jid='catalog.shakespeare.lit'
            node='music'
            name='Music from the time of Shakespeare'/>
      </query>
    </iq>
    }


    {$ifdef WIN32}
    OutputDebugString(PChar('111: _processDiscoItems '));
    {$endif}

    _has_items := true;
    q := tag.GetFirstTag('query');
    if (q = nil) then exit;

    iset := q.QueryTags('item');
    if (iset.Count > 0) then begin
        // clear out the old items
        ClearStringListObjects(_items);
        _items.Clear();

        for i := 0 to iset.Count - 1 do begin
            tmps := iset[i].getAttribute('jid');
            nid := iset[i].getAttribute('node');
            cj := TJabberID.Create(tmps);
            if (nid = '') then
                id := cj.full
            else
                id := nid + ':' + cj.full;
            idx := _items.IndexOf(id);
            if (idx < 0) then begin
                ce := TJabberEntity.Create(cj);
                ce._parent := Self;
                _items.AddObject(tmps, ce);
                ce._name := iset[i].getAttribute('name');
                ce._node := nid;
                jEntityCache.Add(id, ce);
            end
            else
                cj.Free();
        end;
    end;
    iset.Free();

    {$ifdef Win32}
    OutputDebugString(PChar('222: _processDiscoItems ' + IntToStr(_items.Count)));
    {$endif}
end;


{---------------------------------------}
procedure TJabberEntity.WalkCallback(event: string; tag: TXMLTag);
var
    js: TJabberSession;

begin
    // if disco didn't so much workout, try browse next
    assert(_iq <> nil);
    js := _iq.JabberSession;
    assert(js <> nil);
    _iq := nil;

    // if we're not connected anymore, just bail.
    if (js.Active = false) then exit;

    if ((event <> 'xml') or (tag.getAttribute('type') = 'error')) then begin
        // Dispatch a disco#items query
        _iq := TJabberIQ.Create(js, js.generateID(), Self.BrowseCallback, _timeout);
        _iq.toJid := _jid.full;
        _iq.Namespace := XMLNS_BROWSE;
        _iq.iqType := 'get';
        _iq.Send();
        exit;
    end;

    // we got disco#info back! sweet.
    _type := ent_disco;
    _processDiscoInfo(tag);
    getInfo(js);

    // We got info back... so lets get our items..
    _discoItems(js, WalkItemsCallback);
end;

{---------------------------------------}
procedure TJabberEntity.WalkItemsCallback(event: string; tag: TXMLTag);
var
    pt: TJabberEntityProcess;
    js: TJabberSession;
begin
    assert(_iq <> nil);
    js := _iq.JabberSession;
    assert(js <> nil);
    _iq := nil;

    // if we're not connected anymore, just bail.
    if (js.Active = false) then exit;

    if ((event <> 'xml') or (tag.getAttribute('type') = 'error')) then begin
        // Hrmpf.. we got info back, but no items?
        _has_items := true;
        getItems(js);
        exit;
    end;

    // We got items back... process them
    tag.AddRef();
    pt := TJabberEntityProcess.Create(true);
    pt.jso := js;
    pt.tag := tag;
    pt.ptype := ProcWalk;
    pt.e := Self;
    pt.FreeOnTerminate := true;
    pt.Resume();
end;

{---------------------------------------}
procedure TJabberEntity._finishWalk(jso: TObject);
var
    i: integer;
    js: TJabberSession;
begin
    js := TJabberSession(jso);
    getItems(js);

    // Don't fetch info on all items if we have tons
    if ((_use_limit) and (_items.Count >= WALK_LIMIT)) then exit;

    for i := 0 to _items.Count - 1 do
        TJabberEntity(_items.Objects[i]).getInfo(js);
end;

{---------------------------------------}
procedure TJabberEntity._processBrowseItem(item: TXMLTag);
var
    nss: TXMLTagList;
    n: integer;
begin
    _name := item.getAttribute('name');
    _cat := item.getAttribute('category');
    _cat_type := item.getAttribute('type');
    if ((_cat = '') and (item.Name <> 'item')) then
        _cat := item.Name;

    // this item can have ns elements.. *sigh*
    _feats.Clear();
    nss := item.QueryTags('ns');
    for n := 0 to nss.Count - 1 do
        _feats.Add(nss[n].Data);
    nss.Free();

    _processLegacyFeatures();

    // we have the info about this object..
    _has_info := true;

    // but not it's children
    _has_items := false;
end;

{---------------------------------------}
procedure TJabberEntity.BrowseCallback(event: string; tag: TXMLTag);
var
    pt: TJabberEntityProcess;
    js: TJabberSession;
begin
    // if browse didn't work out so well, try agents
    assert(_iq <> nil);
    js := _iq.JabberSession;
    assert(js <> nil);
    _iq := nil;

    // if we're not connected anymore, just bail.
    if (js.Active = false) then exit;

    if ((event <> 'xml') or (tag.getAttribute('type') = 'error')) then begin
        // Dispatch a disco#items query
        _iq := TJabberIQ.Create(js, js.generateID(), Self.AgentsCallback, _timeout);
        _iq.toJid := _jid.full;
        _iq.Namespace := XMLNS_AGENTS;
        _iq.iqType := 'get';
        _iq.Send();
        exit;
    end;

    //_processBrowse(tag);
    tag.AddRef();
    pt := TJabberEntityProcess.Create(true);
    pt.jso := js;
    pt.tag := tag;
    pt.ptype := ProcBrowse;
    pt.e := Self;
    pt.FreeOnTerminate := true;
    pt.Resume();

end;

{---------------------------------------}
procedure TJabberEntity._processBrowse(tag: TXMLTag);
var
    idx, i: integer;
    q: TXMLTag;
    clist: TXMLTagList;
    tmps: Widestring;
    cj: TJabberID;
    ce: TJabberEntity;
begin
    // we got browse back
    _type := ent_browse;
    _has_info := true;
    _has_items := true;

    // process results
    clist := tag.ChildTags();
    if (clist.Count > 0) then begin
        q := clist[0];
        clist.Free();

        clist := q.ChildTags();

        // process our own info
        ClearStringListObjects(_items);
        _items.Clear();
        _processBrowseItem(q);

        _has_info := true;
        _has_items := true;


        // Get our children
        for i := 0 to clist.Count - 1 do begin
            if (clist[i].Name <> 'ns') then begin
                // this is a child
                tmps := clist[i].GetAttribute('jid');
                idx := _items.IndexOf(tmps);
                if (idx = -1) then begin
                    cj := TJabberID.Create(tmps);
                    ce := TJabberEntity.Create(cj);
                    ce._parent := Self;
                    ce._processBrowseItem(clist[i]);
                    jEntityCache.Add(tmps, ce);
                    _items.AddObject(tmps, ce);
                end;
            end;
        end;
        clist.Free();

    end;

    {
    // send events for this entity
    getInfo(js);
    getItems(js);

    // Send info for each child
    t := TXMLTag.Create('entity');
    for i := 0 to _items.Count - 1 do begin
        ce := TJabberEntity(_items.Objects[i]);
        t.setAttribute('from', ce.jid.full);
        js.FireEvent('/session/entity/info', t);
    end;
    t.Free();
    }

end;

{---------------------------------------}
procedure TJabberEntity._processAgent(item: TXMLTag);
var
    tmps: Widestring;
    nss: TXMLTagList;
    n: integer;
begin
    _name := item.GetBasicText('name');

    {
    <agent jid='users.jabber.org'>
        <name>Jabber User Directory</name>
        <service>jud</service>
        <search/>
        <register/>
    </agent>
    }

    // desc := agent.GetBasicText('description');
    _has_info := true;
    
    tmps := item.GetBasicText('service');
    if (tmps <> '') then _feats.Add(tmps);
    _cat_type := tmps;

    if (item.tagExists('register')) then _feats.Add(FEAT_REGISTER);
    if (item.tagExists('search')) then _feats.Add(FEAT_SEARCH);

    if (item.tagExists('groupchat')) then begin
        _cat := 'conference';
        _feats.Add(FEAT_GROUPCHAT);
    end;

    nss := item.QueryTags('ns');
    for n := 0 to nss.COunt - 1 do
        _feats.Add(nss[n].Data);

end;


{---------------------------------------}
procedure TJabberEntity.AgentsCallback(event: string; tag: TXMLTag);
var
    js: TJabberSession;
    tmps: Widestring;
    t: TXMLTag;
    cj: TJabberID;
    ce: TJabberEntity;
    i: integer;
    agents: TXMLTagList;
begin
    assert(_iq <> nil);
    js := _iq.JabberSession;
    assert(js <> nil);
    _iq := nil;

    // if we're not connected anymore, just bail.
    if (js.Active = false) then exit;

    if ((event <> 'xml') or (tag.getAttribute('type') = 'error')) then begin
        // BAH! agents didn't work either.. this thing sucks,
        // if our event is a timeout, let's retry the whole mess, with a longer
        // timeout.
        if ((event = 'timeout') and (_timeout < WALK_MAX_TIMEOUT)) then begin
            _timeout := _timeout * 3;
            _discoInfo(js, WalkCallback);
        end
        else begin
            _has_info := true;
            _has_items := true;
        end;        
        exit;
    end;

    _type := ent_agents;
    _has_info := true;
    _has_items := true;

    ClearStringListObjects(_items);
    _items.Clear();

    agents := tag.QueryXPTags('/iq/query[@xmlns="jabber:iq:agents"/agent');
    for i := 0 to agents.Count -1 do begin
        tmps := agents[i].getAttribute('jid');
        cj := TJabberID.Create(tmps);
        ce := TJabberEntity.Create(cj);
        ce._parent := Self;
        ce._processAgent(agents[i]);
        jEntityCache.Add(tmps, ce);
        _items.AddObject(tmps, ce);
    end;
    agents.Free();

    // send events for this entity
    getInfo(js);
    getItems(js);

    // Send info for each child
    t := TXMLTag.Create('entity');
    for i := 0 to _items.Count - 1 do begin
        ce := TJabberEntity(_items.Objects[i]);
        t.setAttribute('from', ce.jid.full);
        js.FireEvent('/session/entity/info', t);
    end;
    t.Free();

end;

end.
