unit Bookmarks;
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
    {$ifdef Exodus}
    TntClasses,
    {$endif}
    Menus, TntMenus, 
    NodeItem, Signals, Unicode, XMLTag, SysUtils, Classes;

type

    TBookmarkManager = class(TWidestringlist)
    private
        _xdb_bm: boolean;
        _js: TObject;
        _menu: TTntPopupMenu;

    published
        procedure SessionCallback(event: string; tag: TXMLTag);
        procedure UpdateCallback(event: string; tag: TXMLTag);
        procedure bmCallback(event: string; tag: TXMLTag);

        procedure MenuClick(Sender: TObject);

    public
        constructor Create();
        destructor  Destroy(); override;

        procedure setSession(js: TObject);
        procedure Fetch();

        procedure SaveBookmarks();

        procedure AddBookmark(sjid, name, nick: Widestring; auto_join: boolean);
        procedure RemoveBookmark(sjid: Widestring);
        function  FindBookmark(sjid: Widestring): TXMLTag;
        procedure parseItem(tag: TXMLTag; ri: TJabberRosterItem);

    end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
uses
    XMLUtils, 
    RosterImages, GnuGetText, Session, Roster, JabberConst, IQ, JabberID;

{---------------------------------------}
constructor TBookmarkManager.Create();
var
    mi: TTntMenuItem;
begin
    //
    inherited Create();
    _xdb_bm := true;

    _menu := TTntPopupMenu.Create(nil);
    _menu.Name := 'mnuBookmarksContext';
    _menu.AutoHotkeys := maManual;
    _menu.AutoPopup := true;

    mi := TTntMenuItem.Create(_menu);
    mi.Name := 'mnuJoinRoom';
    mi.Caption := _('Join Room');
    mi.OnClick := Self.MenuClick;
    _menu.Items.Add(mi);

    mi := TTntMenuItem.Create(_menu);
    mi.Name := 'mnuRemoveRoom';
    mi.Caption := _('Remove');
    mi.OnClick := Self.MenuClick;
    _menu.Items.Add(mi);

    mi := TTntMenuItem.Create(_menu);
    mi.Name := 'mnuProperties';
    mi.Caption := _('Properties');
    mi.OnClick := Self.MenuClick;
    _menu.Items.Add(mi);
end;

{---------------------------------------}
destructor TBookmarkManager.Destroy();
begin
    inherited Destroy();
end;

{---------------------------------------}
procedure TBookmarkManager.MenuClick(Sender: TObject);
var
    ri: TJabberRosterItem;
    mi: TTntMenuItem;
begin
    if (Sender is TTntMenuItem) then
        mi := TTntMenuItem(Sender)
    else
        exit;

    ri := MainSession.roster.ActiveItem;
    if (ri = nil) then exit;

    if (mi.Name = 'mnuJoinRoom') then
        MainSession.FireEvent('/session/gui/conference', ri.tag)
    else if (mi.Name = 'mnuRemoveRoom') then begin
        // XXX: remove bookmark
    end
    else if (mi.Name = 'mnuProperties') then
        MainSession.FireEvent('/session/gui/conference-props', ri.tag);
end;

{---------------------------------------}
procedure TBookmarkManager.setSession(js: TObject);
begin
    _js := js;
    with TJabberSession(js) do begin
        RegisterCallback(Self.SessionCallback, '/session');
        RegisterCallback(Self.UpdateCallback, '/roster/item/update');
    end;
end;

{---------------------------------------}
procedure TBookmarkManager.UpdateCallback(event: string; tag: TXMLTag);
var
    jid: Widestring;
    ri: TJabberRosterItem;
begin
    if (tag.getAttribute('xmlns') <> XMLNS_BM) then exit;

    jid := tag.getAttribute('jid');
    ri := MainSession.Roster.Find(jid);
    if (ri = nil) then exit;

    tag.setAttribute('name', ri.Text);
    SaveBookmarks();
end;

{---------------------------------------}
procedure TBookmarkManager.SessionCallback(event: string; tag: TXMLTag);
begin
    if (event = '/session/authenticated') then
        Fetch()
    else if (event = '/session/disconnected') then begin
        // note that the tags will be cleaned up by the roster items.
        Clear();
    end;
end;

{---------------------------------------}
procedure TBookmarkManager.Fetch();
var
    s: TJabberSession;
    iq: TJabberIQ;
    go: TJabberGroup;
begin
    // setup the Bookmarks group first
    go := MainSession.roster.getGroup(_('Bookmarks'));
    if (go = nil) then
        go := MainSession.roster.addGroup(_('Bookmarks'));
    go.SortPriority := 50;
    go.ShowPresence := false;
    go.KeepEmpty := false;
    go.DragTarget := false;
    go.DragSource := false;

    s := TJabberSession(_js);
    iq := TJabberIQ.Create(s, s.generateID(), bmCallback, 180);
    with iq do begin
        iqType := 'get';
        toJid := '';
        Namespace := XMLNS_PRIVATE;
        with qtag.AddTag('storage') do
            setAttribute('xmlns', XMLNS_BM);
        Send();
    end;
end;

{---------------------------------------}
procedure TBookmarkManager.parseItem(tag: TXMLTag; ri: TJabberRosterItem);
begin
    ri.IsContact := false;
    ri.Text := tag.getAttribute('name');
    ri.Status := '';
    ri.Tooltip := tag.GetAttribute('jid');
    ri.Action := '/session/gui/conference';
    ri.Tag := tag;
    tag.setAttribute('xmlns', XMLNS_BM);

    ri.AddGroup(_('Bookmarks'));
    ri.SetCleanGroups();

    ri.ImageIndex := RosterTreeImages.Find('bookmark');
    ri.InlineEdit := true;

    // setup right click opts for bookmarks
    ri.CustomContext := _menu;
end;

{---------------------------------------}
procedure TBookmarkManager.bmCallback(event: string; tag: TXMLTag);
var
    bms: TXMLTagList;
    i, idx: integer;
    bm, p, stag: TXMLTag;
    jid: Widestring;
    ri: TJabberRosterItem;
begin
    // get all of the bm's
    bms := nil;
    if ((event = 'xml') and (tag.getAttribute('type') = 'result')) then begin
        // we got a response..
        {
        <iq type="set" id="jcl_4">
            <query xmlns="jabber:iq:private">
                <storage xmlns="storage:bookmarks">
                    <conference name='Council of Oberon'
                                  autojoin='true'
                                  jid='council@conference.underhill.org'>
                        <nick>Puck</nick>
                        <password>titania</password>
                    </conference>
                </storage>
        </query></iq>
        }
        stag := tag.QueryXPTag('/iq/query/storage');
        if (stag <> nil) then
            bms := stag.ChildTags();
    end
    else if ((event = 'xml') and (tag.getAttribute('type') = 'error')) then begin
        // XDB prolly doesn't support remote storage. Get bm's from prefs
        _xdb_bm := false;
        p := MainSession.Prefs.LoadBookmarks();
        if (p <> nil) then
            bms := p.ChildTags();
    end;

    if (bms <> nil) then begin
        for i := 0 to bms.count -1  do begin
            if (bms[i].Name = 'conference') then begin
                jid := WideLowerCase(bms[i].GetAttribute('jid'));
                idx := Self.Indexof(jid);
                if (idx >= 0) then begin
                    // remove the existing bm
                    Self.RemoveBookmark(jid);
                end;
                bm := TXMLTag.Create(bms[i]);
                Self.AddObject(jid, bm);

                ri := TJabberRosterItem.Create(jid);
                parseItem(bm, ri);
                MainSession.Roster.AddItem(jid, ri);

                // Fire an event to join the room
                if (bm.GetAttribute('autojoin') = 'true') then
                    MainSession.FireEvent('/session/gui/conference', bm);
            end;
        end;

        bms.Free();
    end;
end;

{---------------------------------------}
procedure TBookmarkManager.SaveBookmarks();
var
    s: TJabberSession;
    stag, iq: TXMLTag;
    i: integer;
begin
    // save bookmarks to jabber:iq:private
    s := TJabberSession(_js);

    if (_xdb_bm) then begin
        iq := TXMLTag.Create('iq');
        with iq do begin
            setAttribute('type', 'set');
            setAttribute('id', s.generateID());
            with AddTag('query') do begin
                setAttribute('xmlns', XMLNS_PRIVATE);
                stag := AddTag('storage');
                stag.setAttribute('xmlns', XMLNS_BM);
                for i := 0 to Count - 1 do
                    stag.AddTag(TXMLTag.Create(TXMLTag(Objects[i])))
            end;
        end;
        s.SendTag(iq);
    end
    else begin
        // bookmarks from prefs
        stag := TXMLTag.Create('local-bookmarks');
        for i := 0 to Count - 1 do
            stag.AddTag(TXMLTag.Create(TXMLTag(Objects[i])));
        s.Prefs.SaveBookmarks(stag);
    end;
end;

{---------------------------------------}
procedure TBookmarkManager.AddBookmark(sjid, name, nick: Widestring; auto_join: boolean);
var
    bm: TXMLTag;
    ri: TJabberRosterItem;
begin
    {
    <conference name='Council of Oberon'
                  autojoin='true'
                  jid='council@conference.underhill.org'>
        <nick>Puck</nick>
        <password>titania</password>
    </conference>
    }

    bm := TXMLTag.Create('conference');
    bm.setAttribute('xmlns', XMLNS_BM);
    bm.setAttribute('jid', sjid);
    bm.setAttribute('name', name);
    if (auto_join) then
        bm.setAttribute('autojoin', 'true')
    else
        bm.setAttribute('autojoin', 'false');
    bm.AddBasicTag('nick', nick);

    AddObject(sjid, bm);
    ri := TJabberRosterItem.Create(sjid);
    parseItem(bm, ri);
    TJabberSession(_js).roster.AddItem(sjid, ri);

    SaveBookmarks();
end;

{---------------------------------------}
procedure TBookmarkManager.RemoveBookmark(sjid: Widestring);
var
    bm: TXMLTag;
    i: integer;
begin
    // remove a bm from the list
    i := IndexOf(sjid);
    if ((i >= 0) and (i < Count)) then begin
        bm := TXMLTag(Objects[i]);
        TJabberSession(_js).FireEvent('/roster/item/remove', bm);
        Objects[i] := nil;
        Delete(i);
        bm.Free();
        SaveBookmarks();
    end;
end;

{---------------------------------------}
function TBookmarkManager.FindBookmark(sjid: Widestring): TXMLTag;
var
    i: integer;
begin
    i := IndexOf(sjid);
    if (i >= 0) then
        Result := TXMLTag(Objects[i])
    else
        Result := nil;
end;


end.
