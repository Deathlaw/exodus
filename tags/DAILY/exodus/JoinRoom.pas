unit JoinRoom;
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
    JabberID, XMLTag, Unicode,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Wizard, ComCtrls, TntComCtrls, StdCtrls, TntStdCtrls, ExtCtrls,
    TntExtCtrls;

type
  TfrmJoinRoom = class(TfrmWizard)
    Label2: TTntLabel;
    Label1: TTntLabel;
    lblPassword: TTntLabel;
    Label3: TTntLabel;
    txtServer: TTntComboBox;
    txtRoom: TTntEdit;
    txtPassword: TTntEdit;
    txtNick: TTntEdit;
    optSpecify: TTntRadioButton;
    optBrowse: TTntRadioButton;
    TabSheet2: TTabSheet;
    lstRooms: TTntListView;
    Panel2: TPanel;
    lblFetch: TTntLabel;
    txtServerFilter: TTntComboBox;
    btnFetch: TTntButton;
    chkDefaultConfig: TTntCheckBox;
    TntLabel1: TTntLabel;
    Bevel3: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNextClick(Sender: TObject);
    procedure btnFetchClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure optSpecifyClick(Sender: TObject);
    procedure txtServerFilterKeyPress(Sender: TObject; var Key: Char);
    procedure lstRoomsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lstRoomsDblClick(Sender: TObject);
    procedure txtServerFilterSelect(Sender: TObject);
    procedure lstRoomsData(Sender: TObject; Item: TListItem);
    procedure lstRoomsColumnClick(Sender: TObject; Column: TListColumn);
    procedure txtServerFilterChange(Sender: TObject);
    procedure lstRoomsDataFind(Sender: TObject; Find: TItemFind;
      const FindString: WideString; const FindPosition: TPoint;
      FindData: Pointer; StartIndex: Integer; Direction: TSearchDirection;
      Wrap: Boolean; var Index: Integer);
    procedure lstRoomsKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    _cb: integer;
    _all: TList;
    _filter: TList;
    _cur: TList;

    _cur_sort: integer;
    _asc: boolean;

    procedure _addRoomJid(tmp: TJabberID);
    procedure _processFilter();
  published
    procedure EntityCallback(event: string; tag: TXMLTag);
  public
    { Public declarations }
    procedure populateServers();
  end;

var
  frmJoinRoom: TfrmJoinRoom;

procedure StartJoinRoom; overload;
procedure StartJoinRoom(room_jid: TJabberID; nick, password: WideString); overload;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
{$R *.DFM}
uses
    Entity, EntityCache, JabberUtils, ExUtils,  GnuGetText, Jabber1, Session, Room;

const
    sInvalidNick = 'You must enter a nickname';
    sInvalidRoomJID = 'The Room Address you entered is invalid. It must be valid Jabber ID.';

{---------------------------------------}
procedure StartJoinRoom;
var
    jr: TfrmJoinRoom;
begin
    if (not MainSession.Prefs.getBool('brand_muc')) then exit;
    jr := TfrmJoinRoom.Create(Application);
    with jr do begin
        txtRoom.Text := MainSession.Prefs.getString('tc_lastroom');
        txtServer.Text := MainSession.Prefs.getString('tc_lastserver');
        txtNick.Text := MainSession.Prefs.getString('tc_lastnick');
        if (txtNick.Text = '') then
            txtNick.Text := MainSession.Prefs.getString('default_nick');
        if (txtNick.Text = '') then
            txtNick.Text := MainSession.Username;
        populateServers();
        Show;
    end;
end;

{---------------------------------------}
procedure StartJoinRoom(room_jid: TJabberID; nick, password: WideString); overload;
var
    jr: TfrmJoinRoom;
begin
    if (not MainSession.Prefs.getBool('brand_muc')) then exit;
    jr := TfrmJoinRoom.Create(Application);
    with jr do begin
        txtRoom.Text := room_jid.user;
        txtServer.Text := room_jid.domain;
        txtNick.Text := nick;

        if (txtNick.Text = '') then
            txtNick.Text := MainSession.Username;

        populateServers();
        Show;
    end;
end;

{---------------------------------------}
procedure TfrmJoinRoom.populateServers();
var
    l: TWidestringlist;
    i: integer;
    tmp: TJabberID;
    ce: TJabberEntity;
begin
    txtServer.Items.Clear();
    l := TWidestringlist.Create();
    jEntityCache.getByFeature(FEAT_GROUPCHAT, l);
    tmp := TJabberID.Create('');
    for i := 0 to l.Count - 1 do begin
        tmp.ParseJID(l[i]);
        if (tmp.user <> '') then
            _addRoomJid(tmp)
        else begin
            txtServer.Items.Add(l[i]);
            txtServerFilter.Items.Add(l[i]);
            ce := jEntityCache.getByJid(l[i]);
            if (not ce.hasItems) then begin
                ce.walk(MainSession);
            end;
        end;
    end;
    tmp.Free();
    l.Free();
    txtServerFilter.ItemIndex := 0;
    _processFilter();
end;

{---------------------------------------}
procedure TfrmJoinRoom.FormCreate(Sender: TObject);
begin
    tabSheet1.TabVisible := false;
    tabSheet2.TabVisible := false;
    Tabs.ActivePage := tabSheet1;

    MainSession.Prefs.RestorePosition(Self);

    AssignUnicodeFont(Self);
    TranslateComponent(Self);

    _all := TList.Create();
    _filter := TList.Create();
    _cur := _all;
    _cur_sort := 0;
    _asc := true;

    _cb := MainSession.RegisterCallback(EntityCallback, '/session/entity/info');
    txtServerFilter.Items.Add(_('- ALL SERVERS -'));

    if (MainSession.Prefs.getBool('tc_browse')) then
        optBrowse.Checked := true
    else
        optSpecify.Checked := true;
    chkDefaultConfig.Checked := MainSession.Prefs.getBool('tc_default_config');
    optSpecifyClick(Self);
end;

{---------------------------------------}
procedure TfrmJoinRoom.FormDestroy(Sender: TObject);
begin
    if (MainSession <> nil) then begin
        MainSession.Prefs.SavePosition(Self);
        MainSession.UnRegisterCallback(_cb);
    end;
end;

{---------------------------------------}
procedure TfrmJoinRoom.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

{---------------------------------------}
procedure TfrmJoinRoom.btnNextClick(Sender: TObject);
var
    dconfig: boolean;
    pass: Widestring;
    rjid: Widestring;
    li: TTntListItem;
begin
    if ((Tabs.ActivePage = tabSheet1) and (optBrowse.Checked)) then begin
        // change tabs if they selected browse
        Tabs.ActivePage := tabSheet2;
        btnBack.Enabled := true;
        btnNext.Caption := _('Finish');
        exit;
    end;

    // otherwise, just join..
    if (Tabs.ActivePage = tabSheet1) then begin
        rjid := txtRoom.Text + '@' + txtServer.Text;
        if (not isValidJid(rjid)) then begin
            MessageDlgW(_(sInvalidRoomJID), mtError, [mbOK], 0);
            exit;
        end;
    end
    else begin
        li := lstRooms.Selected;
        if (li = nil) then exit;
        rjid := li.Caption + '@' + li.SubItems[0];
    end;

    if (txtNick.Text = '') then begin
        MessageDlgW(_(sInvalidNick), mtError, [mbOK], 0);
        exit;
    end;

    pass := Trim(txtPassword.Text);
    dconfig := chkDefaultConfig.Checked;
    StartRoom(rjid, txtNick.Text, pass, true, dconfig);

    with MainSession.Prefs do begin
        setString('tc_lastroom', txtRoom.Text);
        setString('tc_lastserver', txtServer.Text);
        setString('tc_lastnick', txtNick.Text);
        setBool('tc_browse', optBrowse.Checked);
        setBool('tc_default_config', dconfig);
    end;
    Self.Close;
    exit;

end;

{---------------------------------------}
procedure TfrmJoinRoom.btnFetchClick(Sender: TObject);
begin
    jEntityCache.fetch(txtServerFilter.Text, MainSession, false);
    _processFilter();
end;

{---------------------------------------}
procedure TfrmJoinRoom._addRoomJid(tmp: TJabberID);
var
    ce: TJabberEntity;
    tmps, n: Widestring;
begin
    n := tmp.User;
    tmps := tmp.Domain;
    ce := jEntityCache.getByJid(tmp.full);
    if (ce = nil) then exit;

    // make sure to not add dupes.
    if (_all.IndexOf(ce) = -1) then begin
        _all.Add(ce);
        _processFilter();
    end;
end;

{---------------------------------------}
procedure TfrmJoinRoom._processFilter();
var
    ce: TJabberEntity;
    e, i: integer;
    f: Widestring;
begin
    // filter on the current dropdown..
    i := txtServerFilter.ItemIndex;

    if (i = 0) then
        _cur := _all
    else begin
        f := txtServerFilter.Text;
        _filter.Clear();
        for e := 0 to _all.Count - 1 do begin
            ce := TJabberEntity(_all[e]);
            if (ce.jid.domain = f) then
                _filter.Add(ce);
        end;
        _cur := _filter;
    end;

    if (_cur_sort = 0) then begin
        if (_asc) then
            _cur.Sort(EntityJidCompare)
        else
            _cur.Sort(EntityJidCompareRev);
    end
    else begin
        if (_asc) then
            _cur.Sort(EntityDomainCompare)
        else
            _cur.Sort(EntityDomainCompare);
    end;
    lstRooms.Items.Count := _cur.Count;
    lstRooms.Invalidate();
end;

{---------------------------------------}
procedure TfrmJoinRoom.EntityCallback(event: string; tag: TXMLTag);
var
    tmp: TJabberID;
    ce: TJabberEntity;
begin
    tmp := TJabberID.Create(tag.getAttribute('from'));
    ce := jEntityCache.getByJid(tmp.full);
    if (ce = nil) then begin
        tmp.Free();
        exit;
    end;

    if (not ce.hasFeature(FEAT_GROUPCHAT)) then begin
        tmp.Free();
        exit;
    end;

    if (tmp.user = '') then begin
        if (txtServer.Items.IndexOf(tmp.domain) = -1) then begin
            txtServer.Items.Add(tmp.domain);
            txtServerFilter.Items.Add(tmp.domain);
        end;
    end
    else
        _addRoomJid(tmp);
    tmp.Free();
end;

{---------------------------------------}
procedure TfrmJoinRoom.btnBackClick(Sender: TObject);
begin
    if (Tabs.ActivePage = tabSheet2) then begin
        Tabs.ActivePage := tabSheet1;
        btnNext.Caption := _('Next >');
        btnBack.Enabled := false;
    end;
end;

{---------------------------------------}
procedure TfrmJoinRoom.btnCancelClick(Sender: TObject);
begin
    Self.Close();
end;

{---------------------------------------}
procedure TfrmJoinRoom.optSpecifyClick(Sender: TObject);
begin
    txtServer.Enabled := optSpecify.Checked;
    txtRoom.Enabled := optSpecify.Checked;
    txtPassword.Enabled := optSpecify.Checked;

    if (optSpecify.Checked) then
        btnNext.Caption := _('Finish')
    else
        btnNext.Caption := _('Next >');
end;

{---------------------------------------}
procedure TfrmJoinRoom.txtServerFilterKeyPress(Sender: TObject;
  var Key: Char);
begin
  inherited;
    if (Key = Chr(13)) then begin
        jEntityCache.fetch(txtServerFilter.Text, MainSession, false);
        _processFilter();
        Key := Chr(0);
    end;
end;

{---------------------------------------}
procedure TfrmJoinRoom.lstRoomsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
    li: TTntListItem;
begin
    li := lstRooms.Selected;
    if (li = nil) then exit;

    txtServer.Text := li.SubItems[0];
    txtRoom.Text := li.Caption;
end;

{---------------------------------------}
procedure TfrmJoinRoom.lstRoomsDblClick(Sender: TObject);
begin
    btnNextClick(Self);
end;

{---------------------------------------}
procedure TfrmJoinRoom.txtServerFilterSelect(Sender: TObject);
begin
    btnFetch.Enabled := (txtServerFilter.ItemIndex <> 0);

    // Filter on this server.
    _processFilter();
end;

{---------------------------------------}
procedure TfrmJoinRoom.lstRoomsData(Sender: TObject; Item: TListItem);
var
    i: integer;
    ce: TJabberEntity;
begin
    // populate this item from the current list
    i := Item.Index;
    if ((i < 0) or (i > _cur.Count)) then exit;
    ce := TJabberEntity(_cur[i]);
    Item.Caption := ce.Jid.user;
    Item.SubItems.Add(ce.jid.domain);
    Item.SubItems.Add(ce.Name);
end;

{---------------------------------------}
procedure TfrmJoinRoom.lstRoomsColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  inherited;
    if (Column.Index = 2) then exit;

    if (Column.Index = _cur_sort) then
        _asc := not _asc
    else begin
        _cur_sort := Column.Index;
        _asc := true;
    end;
    _processFilter();
end;

{---------------------------------------}
procedure TfrmJoinRoom.txtServerFilterChange(Sender: TObject);
begin
    btnFetch.Enabled := (txtServerFilter.ItemIndex <> 0);
end;

{---------------------------------------}
procedure TfrmJoinRoom.lstRoomsDataFind(Sender: TObject; Find: TItemFind;
  const FindString: WideString; const FindPosition: TPoint;
  FindData: Pointer; StartIndex: Integer; Direction: TSearchDirection;
  Wrap: Boolean; var Index: Integer);
var
    ci: TJabberEntity;
    i: integer;
    f: boolean;
begin
    // incremental search for items..
    // shamelessly stolen from our JUD code :)
    i := StartIndex;

    if (Find = ifExactString) or (Find = ifPartialString) then begin
        repeat
            if (i = _cur.Count - 1) then begin
                if (Wrap) then i := 0 else exit;
            end;
            ci := TJabberEntity(_cur[i]);
            f := Pos(FindString, ci.Jid.user) > 0;
            inc(i);
        until (f or (i = StartIndex));
        if (f) then Index := i - 1;
    end;
end;

{---------------------------------------}
procedure TfrmJoinRoom.lstRoomsKeyPress(Sender: TObject; var Key: Char);
begin
    if (Key = Chr(13)) then btnNextClick(Self);

end;

end.
