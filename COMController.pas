unit COMController;
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

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
    XMLTag, Unicode, Menus,
    Windows, Classes, ComObj, ActiveX, ExodusCOM_TLB, StdVcl;

type
  TExodusController = class(TAutoObject, IExodusController)
  protected
    function Get_Connected: WordBool; safecall;
    function Get_Server: WideString; safecall;
    function Get_Username: WideString; safecall;
    procedure AddRosterItem(const jid, nickname, group: WideString); safecall;
    procedure ChangePresence(const Show, Status: WideString;
        Priority: Integer); safecall;
    function isRosterJID(const jid: WideString): WordBool; safecall;
    function isSubscribed(const jid: WideString): WordBool; safecall;
    function RegisterCallback(const xpath: WideString;
      const callback: IExodusPlugin): Integer; safecall;
    procedure RemoveRosterItem(const jid: WideString); safecall;
    procedure Send(const xml: WideString); safecall;
    procedure UnRegisterCallback(callback_id: Integer); safecall;
    procedure GetProfile(const jid: WideString); safecall;
    procedure StartChat(const jid, resource, nickname: WideString); safecall;
    function CreateDockableWindow(const Caption: WideString): Integer;
      safecall;
    function addPluginMenu(const Caption: WideString): WideString; safecall;
    procedure removePluginMenu(const ID: WideString); safecall;
    procedure monitorImplicitRegJID(const JabberID: WideString;
      FullJID: WordBool); safecall;
    function getAgentService(const Server, Service: WideString): WideString;
      safecall;
    procedure getAgentList(const Server: WideString); safecall;
    function generateID: WideString; safecall;
    function Get_IsInvisible: WordBool; safecall;
    function Get_IsPaused: WordBool; safecall;
    function Get_Port: Integer; safecall;
    function Get_PresenceShow: WideString; safecall;
    function Get_PresenceStatus: WideString; safecall;
    function Get_Priority: Integer; safecall;
    function Get_Resource: WideString; safecall;
    function isBlocked(const JabberID: WideString): WordBool; safecall;
    procedure Block(const JabberID: WideString); safecall;
    procedure Connect; safecall;
    procedure Disconnect; safecall;
    procedure UnBlock(const JabberID: WideString); safecall;
    function getPrefAsBool(const Key: WideString): WordBool; safecall;
    function getPrefAsInt(const Key: WideString): Integer; safecall;
    function getPrefAsString(const Key: WideString): WideString; safecall;
    procedure setPrefAsBool(const Key: WideString; Value: WordBool); safecall;
    procedure setPrefAsInt(const Key: WideString; Value: Integer); safecall;
    procedure setPrefAsString(const Key_, Value: WideString); safecall;
    function findChat(const JabberID, Resource: WideString): Integer; safecall;
    procedure startInstantMsg(const JabberID: WideString); safecall;
    procedure startRoom(const RoomJID, nickname, Password: WideString;
      SendPresence: WordBool); safecall;
    procedure startSearch(const SearchJID: WideString); safecall;
    procedure showJoinRoom(const RoomJID, Nickname, Password: WideString);
      safecall;
    procedure startBrowser(const BrowseJID: WideString); safecall;
    procedure showCustomPresDialog; safecall;
    procedure showDebug; safecall;
    procedure showLogin; safecall;
    procedure showPrefs; safecall;
    procedure showToast(const Message: WideString; wndHandle,
      imageIndex: Integer); safecall;
    procedure setPresence(const Show, Status: WideString; Priority: Integer);
      safecall;
    function Get_Roster: IExodusRoster; safecall;
    function Get_PPDB: IExodusPPDB; safecall;
    function registerBrowseNS(const Namespace: WideString): WideString;
      safecall;
    function registerDiscoFeature(const Feature: WideString): WideString;
      safecall;
    function registerDiscoItem(const JabberID, Name: WideString): WideString;
      safecall;
    procedure removeBrowseNS(const ID: WideString); safecall;
    procedure removeDiscoFeature(const ID: WideString); safecall;
    procedure removeDiscoItem(const ID: WideString); safecall;
    function registerPresenceXML(const XML: WideString): WideString; safecall;
    procedure removePresenceXML(const ID: WideString); safecall;
    procedure trackWindowsMsg(Message: Integer); safecall;
    function addContactMenu(const Caption: WideString): WideString; safecall;
    procedure removeContactMenu(const ID: WideString); safecall;
    function getActiveContact: WideString; safecall;
    function getActiveGroup: WideString; safecall;
    function getActiveContacts(Online: WordBool): OleVariant; safecall;
    function Get_LocalIP: WideString; safecall;
    procedure setPluginAuth(const AuthAgent: IExodusAuth); safecall;
    procedure setAuthenticated(Authed: WordBool; const XML: WideString);
      safecall;
    procedure setAuthJID(const Username, Host, Resource: WideString); safecall;
    function addMessageMenu(const Caption: WideString): WideString; safecall;
    function addGroupMenu(const Caption: WideString): WideString; safecall;
    procedure removeGroupMenu(const ID: WideString); safecall;
    procedure registerWithService(const JabberID: WideString); safecall;
    { Protected declarations }
  private
    _menu_items: TWideStringList;
    _roster_menus: TWidestringlist;
    _msg_menus: TWidestringList;
    _nextid: longint;
    
  public
    constructor Create();
    destructor Destroy(); override;

    procedure fireNewChat(jid: WideString; ExodusChat: IExodusChat);
    procedure fireNewRoom(jid: Widestring; ExodusChat: IExodusChat);
    procedure fireNewOutgoingIM(jid: Widestring; ExodusChat: IExodusChat);
    procedure fireMenuClick(Sender: TObject);
    procedure fireRosterMenuClick(Sender: TObject);
    function fireIM(Jid: Widestring; var Body: Widestring;
        var Subject: Widestring; xtags: Widestring): Widestring;
    procedure fireMsgMenuClick(idx: integer; jid: Widestring;
        var Body: Widestring; var Subject: Widestring);

    procedure populateMsgMenus(parent: TPopupMenu; event: TNotifyEvent);

  end;

    TPlugin = class
        com: IExodusPlugin;
    end;

    // This class is a local object which receives events which a plugin has
    // registered for, and sends them thru the COM interface to the actual
    // plugin. Using this method, the dispatcher never needs to understand COM.
    TPluginProxy = class
    private
        _xpath: Widestring;
    public
        id: integer;
        com: OleVariant;
        constructor Create(xpath: Widestring; obj: OleVariant);
        destructor Destroy; override;
        procedure Callback(event: string; tag: TXMLTag);
    end;

    TMenuContainer = class
    public
        idx: integer;
        id: Widestring;
        caption: Widestring;
    end;


// Forward declares for plugin utils
function CheckPluginDll(dll : WideString; var libname: Widestring;
    var obname: Widestring; var doc: Widestring): boolean;
function LoadPlugin(com_name: string): boolean;

procedure InitPlugins();
procedure UnloadPlugins();
procedure ConfigurePlugin(com_name: string);
procedure ReloadPlugins(sl: TWidestringlist);

var
    plugs: TStringList;

implementation

uses
    DockContainer, Profile,  
    ExResponders, ExSession, GnuGetText, JabberUtils, ExUtils,  EntityCache, Entity,
    Chat, ChatController, JabberID, MsgRecv, Room, Browser, Jud,
    ChatWin, JoinRoom, CustomPres, Prefs, RiserWindow, Debug,
    COMChatController, Dockable, RegForm,
    Jabber1, Session, NodeItem, RemoveContact, Roster, RosterWindow, PluginAuth, PrefController,
    Controls, Dialogs, Variants, Forms, SysUtils, ComServ;

const
    sPluginErrCreate = 'Plugin could not be created. (%s)';
    sPluginErrNoIntf = 'Plugin class does not support IExodusPlugin. (%s)';
    sPluginErrInit   = 'Plugin class could not be initialized. (%s)';
    sPluginRemove    = 'Remove this plugin from the list of plugins to be loaded at startup?';


var
    proxies: TStringList;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure InitPlugins();
var
    s, ok: TWideStringlist;
    i: integer;
begin
    // load all of the plugins listed in the prefs
    s := TWideStringlist.Create();
    ok := TWidestringList.Create();
    MainSession.Prefs.fillStringList('plugin_selected', s);

    for i := 0 to s.count - 1 do begin
        if (LoadPlugin(s[i]) = false) then begin
            // remove from list?
            if (MessageDlgW(_(sPluginRemove), mtConfirmation, [mbYes, mbNo], 0) = mrNo) then
                ok.Add(s[i]);
        end
        else
            ok.Add(s[i]);
    end;

    // re-save the "ok" ones.
    if (ok.Count <> s.Count) then
        MainSession.Prefs.setStringlist('plugin_selected', ok);

    s.Free();
    ok.Free();
end;

{---------------------------------------}
function CheckPluginDll(dll : WideString; var libname: Widestring;
    var obname: Widestring; var doc: Widestring): boolean;
var
    lib : ITypeLib;
    i, j : integer;
    tinfo, iface : ITypeInfo;
    tattr, iattr: PTypeAttr;
    r: cardinal;
begin
    // load the .dll.  This SHOULD register the bloody thing if it's not, but that
    // doesn't seem to work for me.
    Result := false;
    try
        OleCheck(LoadTypeLibEx(PWideChar(dll), REGKIND_REGISTER, lib));
        OleCheck(lib.GetDocumentation(-1, @libname, nil, nil, nil));
    except
        on EOleSysError do exit;
    end;

    // for each type in the project
    for i := 0 to lib.GetTypeInfoCount() - 1 do begin
        // get the info about the type
        try
            OleCheck(lib.GetTypeInfo(i, tinfo));

            // get attributes of the type
            OleCheck(tinfo.GetTypeAttr(tattr));
        except
            on EOleSysError do exit;
        end;
        // is this a coclass?
        if (tattr.typekind <> TKIND_COCLASS) then continue;

        // for each interface that the coclass implements
        for j := 0 to tattr.cImplTypes - 1 do begin
            // get the type info for the interface
            try
                OleCheck(tinfo.GetRefTypeOfImplType(j, r));
                OleCheck(tinfo.GetRefTypeInfo(r, iface));

                // get the attributes of the interface
                OleCheck(iface.GetTypeAttr(iattr));
            except
                on EOleSysError do continue;
            end;

            // is this the IExodusPlugin interface?
            if  (IsEqualGUID(iattr.guid, ExodusCOM_TLB.IID_IExodusPlugin)) then begin
                // oho!  it IS.  Get the name of this coclass, so we can show
                // what we did.  Get the doc string, just to show off.
                try
                    OleCheck(tinfo.GetDocumentation(-1, @obname, @doc, nil, nil));
                    // SysFreeString of obname and doc needed?  In C, yes, but here?
                    Result := true;
                    break;
                except
                    on EOleSysError do exit;
                end;

            end;
            iface.ReleaseTypeAttr(iattr);
        end;
        tinfo.ReleaseTypeAttr(tattr);
    end;
end;


{---------------------------------------}
function LoadPlugin(com_name: string): boolean;
var
    idisp: IDispatch;
    plugin: IExodusPlugin;
    p: TPlugin;
    msg: Widestring;
begin
    // Fire up an instance of the specified COM object
    Result := false;
    if (plugs.indexof(com_name) > -1) then exit;

    try
        idisp := CreateOleObject(com_name);
    except
        on EOleSysError do begin
            msg := WideFormat(_(sPluginErrCreate), [com_name]);
            MessageDlgW(msg, mtError, [mbOK], 0);
            exit;
        end;
    end;

    try
        plugin := IUnknown(idisp) as IExodusPlugin;
    except
        on EIntfCastError do begin
            msg := WideFormat(_(sPluginErrNoIntf), [com_name]);
            MessageDlgW(msg, mtError, [mbOK], 0);
            exit;
        end;
    end;

    p := TPlugin.Create();
    p.com := plugin;
    plugs.AddObject(com_name, p);
    try
        p.com.Startup(ExComController);
    except
        msg := WideFormat(_(sPluginErrInit), [com_name]);
        MessageDlgW(msg, mtError, [mbOK], 0);
        exit;
    end;

    Result := true;
end;

{---------------------------------------}
procedure ConfigurePlugin(com_name: string);
var
    idx: integer;
    p: TPlugin;
begin
    //
    idx := plugs.IndexOf(com_name);
    if (idx < 0) then begin
        LoadPlugin(com_name);
        idx := plugs.IndexOf(com_name);
    end;

    if (idx < 0) then begin
        MessageDlgW(_('Plugin could not be initialized or configured.'),
            mtError, [mbOK], 0);
        exit;
    end;

    p := TPlugin(plugs.Objects[idx]);
    p.com.Configure();
end;

{---------------------------------------}
procedure ReloadPlugins(sl: TWidestringlist);
var
    i, idx: integer;
    loaded: TStringlist;
    p: TPlugin;
begin
    // load all plugins listed, if they are not already loaded.
    loaded := TStringlist.Create();
    for i := 0 to sl.Count -1  do begin
        idx := plugs.IndexOf(sl[i]);
        if (idx < 0) then
            LoadPlugin(sl[i]);
        loaded.Add(sl[i]);
    end;

    // unload any plugins not in the loaded list
    for i := plugs.Count - 1 downto 0 do begin
        idx := loaded.IndexOf(plugs[i]);
        if (idx < 0) then begin
            // unload the plugin
            p := TPlugin(plugs.Objects[i]);
            plugs.Delete(i);
            p.com.Shutdown;
        end;
    end;
    loaded.Free();
end;

{---------------------------------------}
procedure UnloadPlugins();
var
    pp: TPlugin;
    i: integer;
begin
    // kill all of the various plugins which are loaded.
    for i := proxies.Count -1 downto 0 do
        TPluginProxy(proxies.Objects[i]).Free();

    // pgm Dec 12, 2002 - Don't free pp, or call pp.com._Release,
    // or else bad things can happen here... assume that mem is getting
    // cleared.
    for i := plugs.Count - 1 downto 0 do begin
        pp := TPlugin(plugs.Objects[i]);
        plugs.Delete(i);
        pp.com.Shutdown;
    end;

    plugs.Clear();
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TPluginProxy.Create(xpath: Widestring; obj: OleVariant);
begin
    inherited Create;

    _xpath := xpath;

    id := MainSession.RegisterCallback(Self.Callback, xpath);
    com := obj;

    proxies.AddObject(IntToStr(id), Self)
end;

{---------------------------------------}
destructor TPluginProxy.Destroy;
var
    idx: integer;
begin
    if (MainSession <> nil) and (id <> -1) then
        MainSession.UnRegisterCallback(id);

    idx := proxies.IndexOfObject(Self);
    if (idx <> -1) then
        proxies.Delete(idx);

    inherited Destroy;
end;

{---------------------------------------}
procedure TPluginProxy.Callback(event: string; tag: TXMLTag);
var
    plugin: IExodusPlugin;
    xml: WideString;
begin
    // call the plugin back
    // Lets just wholesale catch exceptions here. This will prevent
    // Exodus show catastrophic errors when plugins are bad
    try
        plugin := IUnknown(com) as IExodusPlugin;
        if (tag = nil) then
            xml := ''
        else
            xml := tag.xml;

        plugin.Process(_xpath, event, xml);
    except
    end;
end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
constructor TExodusController.Create();
begin
    inherited Create();
    _menu_items := TWidestringList.Create();
    _roster_menus := Twidestringlist.Create();
    _msg_menus := TWidestringlist.Create();
    _nextid := 0;
end;

{---------------------------------------}
destructor TExodusController.Destroy();
begin
    // should we cleanup these menu items???
    _menu_items.Free();
    _roster_menus.Free();
    _msg_menus.Free();

    OutputDebugString('Destroying TExodusController');

    inherited;
end;

{---------------------------------------}
procedure TExodusController.fireNewChat(jid: WideString; ExodusChat: IExodusChat);
var
    i: integer;
begin
    for i := 0 to plugs.count - 1 do
        TPlugin(plugs.Objects[i]).com.NewChat(jid, ExodusChat);
end;

{---------------------------------------}
procedure TExodusController.fireNewOutgoingIM(jid: Widestring; ExodusChat: IExodusChat);
var
    i: integer;
begin
    for i := 0 to plugs.Count - 1 do
        TPlugin(plugs.Objects[i]).com.NewOutgoingIM(jid, ExodusChat);
end;

{---------------------------------------}
procedure TExodusController.fireNewRoom(jid: Widestring; ExodusChat: IExodusChat);
var
    i: integer;
begin
    for i := 0 to plugs.Count - 1 do
        TPlugin(plugs.Objects[i]).com.NewRoom(jid, ExodusChat);
end;

{---------------------------------------}
function TExodusController.fireIM(Jid: Widestring; var Body: Widestring;
    var Subject: Widestring; xtags: Widestring): Widestring;
var
    i: integer;
    xml: Widestring;
begin
    xml := '';
    for i := 0 to plugs.Count - 1 do
        xml := xml + TPlugin(plugs.Objects[i]).com.NewIM(jid, body, subject, xtags);
    Result := xml;
end;

{---------------------------------------}
procedure TExodusController.fireMsgMenuClick(idx: integer; jid: Widestring;
        var Body: Widestring; var Subject: Widestring);
var
    i: integer;
begin
    if (idx >= _msg_menus.Count) then exit;
    for i := 0 to plugs.Count - 1 do
        TPlugin(plugs.Objects[i]).com.MsgMenuClick(_msg_menus[idx], jid,
            Body, Subject);
end;

{---------------------------------------}
function TExodusController.Get_Connected: WordBool;
begin
    Result := MainSession.Active;
end;

{---------------------------------------}
function TExodusController.Get_Server: WideString;
begin
    Result := MainSession.Profile.Server;
end;

{---------------------------------------}
function TExodusController.Get_Username: WideString;
begin
    Result := MainSession.Profile.Username;
end;

{---------------------------------------}
procedure TExodusController.AddRosterItem(const jid, nickname,
  group: WideString);
begin
    MainSession.roster.AddItem(jid, nickname, group, true);
end;

{---------------------------------------}
procedure TExodusController.ChangePresence(const Show, Status: WideString;
        Priority: Integer);
begin
    // Change our presence
    MainSession.setPresence(Show, Status, Priority);
end;

{---------------------------------------}
function TExodusController.isRosterJID(const jid: WideString): WordBool;
begin
    Result := (MainSession.Roster.Find(jid) <> nil);
end;

{---------------------------------------}
function TExodusController.isSubscribed(const jid: WideString): WordBool;
var
    ritem: TJabberRosterItem;
begin
    Result := false;
    ritem := MainSession.Roster.Find(jid);
    if (ritem <> nil) then begin
        if (ritem.subscription = 'to') or
        (ritem.subscription = 'both') then
            Result := true;
    end;
end;

{---------------------------------------}
function TExodusController.RegisterCallback(const xpath: WideString;
  const callback: IExodusPlugin): Integer;
var
    pp: TPluginProxy;
begin
    pp := TPluginProxy.Create(xpath, callback);
    Result := pp.id;
end;

{---------------------------------------}
procedure TExodusController.RemoveRosterItem(const jid: WideString);
begin
    // todo: plugin remove roster item
    QuietRemoveRosterItem(jid);
end;

{---------------------------------------}
procedure TExodusController.Send(const xml: WideString);
begin
    MainSession.Stream.Send(xml);
end;

{---------------------------------------}
procedure TExodusController.UnRegisterCallback(callback_id: Integer);
var
    idx: integer;
begin
    idx := proxies.indexOf(IntToStr(callback_id));
    if (idx <> -1) then begin
        TPluginProxy(proxies.Objects[idx]).Free;
        proxies.Delete(idx);
    end;
end;

{---------------------------------------}
procedure TExodusController.GetProfile(const jid: WideString);
begin
    // Fetch and display a profile
    ShowProfile(jid);
end;

{---------------------------------------}
procedure TExodusController.StartChat(const jid, resource,
  nickname: WideString);
begin
    // start chat
    ChatWin.StartChat(jid, resource, true, nickname);
end;

{---------------------------------------}
function TExodusController.CreateDockableWindow(
  const Caption: WideString): Integer;
var
    f: TfrmDockContainer;
begin
    Application.CreateForm(TfrmDockContainer, f);
    f.ShowDefault();
    f.Caption := Caption;
    Result := f.Panel1.Handle;
end;

{---------------------------------------}
function TExodusController.addPluginMenu(
  const Caption: WideString): WideString;
var
    id: Widestring;
    mi: TMenuItem;
begin
    // add a new TMenuItem to the Plugins menu
    mi := TMenuItem.Create(frmExodus);
    frmExodus.mnuPlugins.Add(mi);
    mi.Caption := caption;
    mi.OnClick := frmExodus.mnuPluginDummyClick;
    inc(_nextid);
    id := 'plugin_' + IntToStr(_nextid);
    mi.Name := id;
    _menu_items.AddObject(id, mi);
    Result := id;
end;

{---------------------------------------}
procedure TExodusController.removePluginMenu(const ID: WideString);
var
    idx: integer;
begin
    idx := _menu_items.IndexOf(id);
    if (idx >= 0) then begin
        TMenuItem(_menu_items.Objects[idx]).Free();
        _menu_items.Delete(idx);
    end;
end;

{---------------------------------------}
procedure TExodusController.fireMenuClick(Sender: TObject);
var
    i, idx: integer;
begin
    idx := _menu_items.IndexOfObject(Sender);
    if (idx >= 0) then begin
        for i := 0 to plugs.count - 1 do
            TPlugin(plugs.Objects[i]).com.menuClick(_menu_items[idx]);
    end;
end;

{---------------------------------------}
procedure TExodusController.fireRosterMenuClick(Sender: TObject);
var
    i, idx: integer;
begin
    idx := _roster_menus.indexOfObject(Sender);
    if (idx >= 0) then begin
        for i := 0 to plugs.count - 1 do
            TPlugin(plugs.Objects[i]).com.menuClick(_roster_menus[idx]);
    end;
end;

{---------------------------------------}
procedure TExodusController.monitorImplicitRegJID(
  const JabberID: WideString; FullJID: WordBool);
begin
    ExRegController.MonitorJid(JabberID, FullJID);
end;

{---------------------------------------}
function TExodusController.getAgentService(const Server,
  Service: WideString): WideString;
var
    e: TJabberEntity;
begin
    result := '';
    e := jEntityCache.getByJid(Server);
    if (e = nil) then
        exit;
    e := e.getItemByFeature(Service);
    if (e = nil) then
        exit;
    result := e.Jid.full;
end;

{---------------------------------------}
procedure TExodusController.getAgentList(const Server: WideString);
begin
    // XXX: COM interface for agents/entities
end;

{---------------------------------------}
function TExodusController.generateID: WideString;
begin
    Result := MainSession.generateID();
end;

function TExodusController.Get_IsInvisible: WordBool;
begin
    Result := MainSession.Invisible;
end;

function TExodusController.Get_IsPaused: WordBool;
begin
    Result := MainSession.IsPaused;
end;

function TExodusController.Get_Port: Integer;
begin
    Result := MainSession.Port;
end;

function TExodusController.Get_PresenceShow: WideString;
begin
    Result := MainSession.Show;
end;

function TExodusController.Get_PresenceStatus: WideString;
begin
    Result := MainSession.Status;
end;

function TExodusController.Get_Priority: Integer;
begin
    Result := MainSession.Priority;
end;

function TExodusController.Get_Resource: WideString;
begin
    Result := MainSession.Resource;
end;

function TExodusController.isBlocked(const JabberID: WideString): WordBool;
begin
    Result := MainSession.IsBlocked(JabberID);
end;

{---------------------------------------}
procedure TExodusController.Block(const JabberID: WideString);
var
    tmpjid: TJabberID;
begin
    tmpjid := TJabberID.Create(jabberID);
    MainSession.Block(tmpjid);
    tmpjid.Free();
end;

{---------------------------------------}
procedure TExodusController.Connect;
begin
    if not MainSession.Active then
        MainSession.Connect();
end;

{---------------------------------------}
procedure TExodusController.Disconnect;
begin
    if MainSession.Active then
        MainSession.Disconnect();
end;

{---------------------------------------}
procedure TExodusController.UnBlock(const JabberID: WideString);
var
    tmpjid: TJabberID;
begin
    tmpjid := TJabberID.Create(JabberID);
    MainSession.UnBlock(tmpjid);
    tmpjid.Free();
end;

{---------------------------------------}
function TExodusController.getPrefAsBool(const Key: WideString): WordBool;
begin
    Result := MainSession.Prefs.getBool(key);
end;

{---------------------------------------}
function TExodusController.getPrefAsInt(const Key: WideString): Integer;
begin
    Result := MainSession.Prefs.getInt(key);
end;

{---------------------------------------}
function TExodusController.getPrefAsString(
  const Key: WideString): WideString;
begin
    Result := MainSession.Prefs.getString(key);
end;

{---------------------------------------}
procedure TExodusController.setPrefAsBool(const Key: WideString;
  Value: WordBool);
begin
    MainSession.Prefs.setBool(key, value);
end;

{---------------------------------------}
procedure TExodusController.setPrefAsInt(const Key: WideString;
  Value: Integer);
begin
    MainSession.Prefs.setInt(key, value);
end;

{---------------------------------------}
procedure TExodusController.setPrefAsString(const Key_, Value: WideString);
begin
    MainSession.Prefs.setString(Key_, value);
end;

{---------------------------------------}
function TExodusController.findChat(const JabberID,
  Resource: WideString): Integer;
var
    c: TChatController;
begin
    c := MainSession.ChatList.FindChat(JabberID, Resource, '');
    if (c = nil) then
        Result := 0
    else
        Result := TForm(c.window).Handle;
end;

{---------------------------------------}
procedure TExodusController.startInstantMsg(const JabberID: WideString);
begin
    startMsg(JabberID);
end;

{---------------------------------------}
procedure TExodusController.startRoom(const RoomJID, nickname,
  Password: WideString; SendPresence: WordBool);
begin
    Room.startRoom(RoomJID, Nickname, Password, SendPresence);
end;

{---------------------------------------}
procedure TExodusController.startSearch(const SearchJID: WideString);
begin
    startSearch(SearchJID);
end;

{---------------------------------------}
procedure TExodusController.showJoinRoom(const RoomJID, Nickname,
  Password: WideString);
var
    tmpjid: TJabberID;
begin
    tmpjid := TJabberID.Create(RoomJID);
    startJoinRoom(tmpjid, NickName, Password);
    tmpjid.free();
end;

{---------------------------------------}
procedure TExodusController.startBrowser(const BrowseJID: WideString);
begin
    showBrowser(BrowseJID);
end;

{---------------------------------------}
procedure TExodusController.showCustomPresDialog;
begin
    ShowCustomPresence();
end;

{---------------------------------------}
procedure TExodusController.showDebug;
begin
    ShowDebugForm();
end;

{---------------------------------------}
procedure TExodusController.showLogin;
begin
    PostMessage(frmExodus.Handle, WM_SHOWLOGIN, 0, 0);
end;

{---------------------------------------}
procedure TExodusController.showPrefs;
begin
    startPrefs();
end;

{---------------------------------------}
procedure TExodusController.showToast(const Message: WideString; wndHandle,
  imageIndex: Integer);
begin
    showRiserWindow(wndHandle, Message, imageIndex);
end;

{---------------------------------------}
procedure TExodusController.setPresence(const Show, Status: WideString;
  Priority: Integer);
begin
    MainSession.setPresence(Show, Status, Priority);
end;

{---------------------------------------}
function TExodusController.Get_Roster: IExodusRoster;
begin
    ExCOMRoster.ObjAddRef();
    Result := ExCOMRoster;
end;

{---------------------------------------}
function TExodusController.Get_PPDB: IExodusPPDB;
begin
    ExCOMPPDB.ObjAddRef();
    Result := ExCOMPPDB;
end;

{---------------------------------------}
function TExodusController.registerBrowseNS(
  const Namespace: WideString): WideString;
begin
    Result := IntToStr(Exodus_Browse.Namespaces.Add(namespace));
end;

{---------------------------------------}
function TExodusController.registerDiscoFeature(
  const Feature: WideString): WideString;
begin
    Result := IntToStr(Exodus_Disco_Info.Features.Add(Feature));
end;

{---------------------------------------}
function TExodusController.registerDiscoItem(const JabberID,
  Name: WideString): WideString;
begin
    Result := Exodus_Disco_Items.addItem(Name, JabberID);
end;

{---------------------------------------}
procedure TExodusController.removeBrowseNS(const ID: WideString);
var
    idx: integer;
begin
    idx := StrToIntDef(ID, -1);
    if ((idx >= 0) and (idx < Exodus_Browse.Namespaces.Count)) then
        Exodus_Browse.Namespaces.Delete(idx);
end;

{---------------------------------------}
procedure TExodusController.removeDiscoFeature(const ID: WideString);
var
    idx: integer;
begin
    idx := StrToIntDef(ID, -1);
    if ((idx >= 0) and (idx < Exodus_Disco_Info.Features.Count)) then
        Exodus_Disco_Info.Features.Delete(idx);
end;

{---------------------------------------}
procedure TExodusController.removeDiscoItem(const ID: WideString);
begin
    Exodus_Disco_Items.removeItem(ID);
end;

{---------------------------------------}
function TExodusController.registerPresenceXML(
  const XML: WideString): WideString;
begin
    Result := IntToStr(MainSession.Presence_XML.Add(XML));
end;

{---------------------------------------}
procedure TExodusController.removePresenceXML(const ID: WideString);
var
    idx: integer;
begin
    idx := StrToIntDef(ID, -1);
    if ((idx >= 0) and (idx < MainSession.Presence_XML.Count)) then
        MainSession.Presence_XML.Delete(idx);
end;

{---------------------------------------}
procedure TExodusController.trackWindowsMsg(Message: Integer);
begin
    frmExodus.TrackWindowsMsg(Message);
end;

{---------------------------------------}
function TExodusController.addContactMenu(
  const Caption: WideString): WideString;
var
    id: Widestring;
    mi: TMenuItem;
begin
    // add a new TMenuItem to the Plugins menu
    mi := TMenuItem.Create(frmRosterWindow);
    frmRosterWindow.popRoster.Items.Add(mi);
    mi.Caption := caption;
    mi.OnClick := frmRosterWindow.pluginClick;
    id := 'ct_menu_' + IntToStr(_roster_menus.Count);
    mi.Name := id;
    _roster_menus.AddObject(id, mi);
    Result := id;
end;

{---------------------------------------}
procedure TExodusController.removeContactMenu(const ID: WideString);
var
    idx: integer;
begin
    idx := _roster_menus.IndexOf(ID);
    if (idx >= 0) then begin
        TMenuItem(_roster_menus.Objects[idx]).Free();
        _roster_menus.Delete(idx);
    end;
end;

{---------------------------------------}
function TExodusController.getActiveContact: WideString;
var
    ritem: TJabberRosterItem;
begin
    ritem := frmRosterWindow.CurRosterItem;
    if (ritem <> nil) then
        Result := ritem.jid.full
    else
        Result := '';
end;

{---------------------------------------}
function TExodusController.getActiveGroup: WideString;
begin
    Result := frmRosterWindow.CurGroup;
end;

{---------------------------------------}
function TExodusController.getActiveContacts(Online: WordBool): OleVariant;
var
    clist: TList;
    i: integer;
    ritem: TJabberRosterItem;
    va : Variant;
begin
    clist := frmRosterWindow.getSelectedContacts(Online);
    va := VarArrayCreate([0,clist.Count], varOleStr);

    for i := 0 to clist.count - 1 do begin
        ritem := TJabberRosterItem(clist[i]);
        VarArrayPut(va, ritem.jid.full, i);
    end;
    clist.Free();
    result := va;
end;

{---------------------------------------}
function TExodusController.Get_LocalIP: WideString;
begin
    Result := MainSession.Stream.LocalIP;
end;

{---------------------------------------}
procedure TExodusController.setPluginAuth(const AuthAgent: IExodusAuth);
var
    aa: TExPluginAuth;
begin
    // spin up a new auth agent, and register it w/ the session.
    aa := TExPluginAuth.Create();
    aa.plugin := AuthAgent;
    MainSession.setAuthAgent(aa);
end;

{---------------------------------------}
procedure TExodusController.setAuthenticated(Authed: WordBool;
  const XML: WideString);
begin
    // todo: parse & pass along the XML Tag for auth plugins
    MainSession.setAuthenticated(authed, nil, false);
end;

{---------------------------------------}
procedure TExodusController.setAuthJID(const Username, Host,
  Resource: WideString);
begin
    MainSession.setAuthdJID(username, host, resource);
end;

{---------------------------------------}
function TExodusController.addMessageMenu(
  const Caption: WideString): WideString;
var
    mc: TMenuContainer;
    id: Widestring;
begin
    // add a new TMenuItem to the Msg-Plugins menu
    id := 'msg_menu_' + IntToStr(_msg_menus.Count);
    mc := TMenuContainer.Create();
    mc.id := id;
    mc.caption := Caption;
    mc.idx := _msg_menus.AddObject(id, mc);
    Result := id;
end;

{---------------------------------------}
procedure TExodusController.populateMsgMenus(parent: TPopupMenu;
    event: TNotifyEvent);
var
    i: integer;
    mc: TMenuContainer;
    mi: TMenuItem;
begin
    for i := 0 to _msg_menus.Count - 1 do begin
        mc := TMenuContainer(_msg_menus.Objects[i]);
        mi := TMenuItem.Create(parent.Owner);
        mi.Caption := mc.caption;
        mi.Tag := i;
        mi.OnClick := event;
        mi.Name := mc.id;
    end;
end;

{---------------------------------------}
function TExodusController.addGroupMenu(
  const Caption: WideString): WideString;
var
    id: Widestring;
    mi: TMenuItem;
begin
    // add a new TMenuItem to the Plugins menu
    mi := TMenuItem.Create(frmRosterWindow);
    frmRosterWindow.popGroup.Items.Add(mi);
    mi.Caption := caption;
    mi.OnClick := frmRosterWindow.pluginClick;
    id := 'group_menu_' + IntToStr(_roster_menus.Count);
    mi.Name := id;
    _roster_menus.AddObject(id, mi);
    Result := id;
end;

{---------------------------------------}
procedure TExodusController.removeGroupMenu(const ID: WideString);
var
    idx: integer;
begin
    idx := _roster_menus.IndexOf(ID);
    if (idx >= 0) then begin
        TMenuItem(_roster_menus.Objects[idx]).Free();
        _roster_menus.Delete(idx);
    end;
end;

{---------------------------------------}
procedure TExodusController.registerWithService(
  const JabberID: WideString);
begin
    StartServiceReg(JabberID);
end;

initialization
  TAutoObjectFactory.Create(ComServer, TExodusController, Class_ExodusController,
    ciMultiInstance, tmApartment);

  plugs := TStringList.Create();
  proxies := TStringList.Create();

finalization
    plugs.Free();
    proxies.Free();

end.
