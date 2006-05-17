unit ChatWin;
{
    Copyright 2002, Peter Millard

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
    Avatar, Chat, ChatController, JabberID, XMLTag, IQ, Unicode, NodeItem,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, BaseChat, ExtCtrls, StdCtrls, Menus, ComCtrls, ExRichEdit, RichEdit2,
    RichEdit, TntStdCtrls, Buttons, TntMenus, FloatingImage;

type
  TfrmChat = class(TfrmBaseChat)
    popContact: TTntPopupMenu;
    SaveDialog1: TSaveDialog;
    btnClose: TSpeedButton;
    pnlJID: TPanel;
    lblNick: TTntLabel;
    timBusy: TTimer;
    mnuWordwrap: TTntMenuItem;
    mnuReturns: TTntMenuItem;
    mnuOnTop: TTntMenuItem;
    NotificationOptions1: TTntMenuItem;
    N1: TTntMenuItem;
    mnuBlock: TTntMenuItem;
    C1: TTntMenuItem;
    mnuProfile: TTntMenuItem;
    popAddContact: TTntMenuItem;
    mnuSendFile: TTntMenuItem;
    N4: TTntMenuItem;
    popResources: TTntMenuItem;
    N5: TTntMenuItem;
    popClearHistory: TTntMenuItem;
    mnuHistory: TTntMenuItem;
    mnuSave: TTntMenuItem;
    Panel3: TPanel;
    imgAvatar: TPaintBox;
    PrintHistory1: TTntMenuItem;
    mnuLastActivity: TTntMenuItem;
    mnuTimeRequest: TTntMenuItem;
    mnuVersionRequest: TTntMenuItem;
    PrintDialog1: TPrintDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MsgOutKeyPress(Sender: TObject; var Key: Char);
    procedure doHistory(Sender: TObject);
    procedure doProfile(Sender: TObject);
    procedure doAddToRoster(Sender: TObject);
    procedure lblJIDClick(Sender: TObject);
    procedure mnuReturnsClick(Sender: TObject);
    procedure mnuSendFileClick(Sender: TObject);
    procedure MsgOutChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CTCPClick(Sender: TObject);
    procedure mnuBlockClick(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuOnTopClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure popClearHistoryClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure mnuWordwrapClick(Sender: TObject);
    procedure btnCloseMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NotificationOptions1Click(Sender: TObject);
    procedure timBusyTimer(Sender: TObject);
    procedure popResourcesClick(Sender: TObject);
    procedure imgAvatarPaint(Sender: TObject);
    procedure imgAvatarClick(Sender: TObject);
    procedure PrintHistory1Click(Sender: TObject);
  private
    { Private declarations }
    jid: widestring;        // jid of the person we are talking to
    _jid: TJabberID;        // JID object of jid
    _pcallback: integer;    // Presence Callback
    _scallback: integer;    // Session callback
    _thread : string;       // thread for conversation
    _pres_img: integer;     // current index of the presence image
    _msg_out: boolean;
    _res_menus: TWidestringlist;

    // Stuff for composing events
    _flash_ticks: integer;
    _cur_img: integer;
    _old_img: integer;
    {
    _old_hint: string;
    }
    _last_id: string;
    _reply_id: string;
    _check_event: boolean;
    _send_composing: boolean;
    _sent_composing: boolean;
    _warn_busyclose: boolean;

    _destroying: boolean;

    _cur_ver: TJabberIQ;    // pending events
    _cur_time: TJabberIQ;
    _cur_last: TJabberIQ;

    _mynick: Widestring;

    // custom notification options to use..
    _notify: array[0..3] of integer;

    // the current contact's avatar
    _avatar: TAvatar;
    _unknown_avatar: TBitmap;

    // Stash away the status
    _status: Widestring;
    _show: Widestring;

    procedure SetupPrefs();
    procedure SetupMenus();
    procedure ChangePresImage(ritem: TJabberRosterItem; show: widestring; status: widestring);
    procedure freeChatObject();
    function  _sendMsg(txt: Widestring): boolean;
    procedure _sendComposing(id: Widestring);

    function GetThread: String;

  published
    procedure PresCallback(event: string; tag: TXMLTag);
    procedure SessionCallback(event: string; tag: TXMLTag);
    procedure CTCPCallback(event: string; tag: TXMLTag);

  public
    { Public declarations }
    OtherNick: widestring;
    chat_object: TChatController;

    procedure PlayQueue();
    procedure MessageEvent(tag: TXMLTag);
    procedure showMsg(tag: TXMLTag);
    procedure showPres(tag: TXMLTag);
    procedure SetupResources();
    procedure SendRawMessage(body, subject, xml: Widestring; fire_plugins: boolean);

    procedure SendMsg; override;
    function  SetJID(cjid: widestring): boolean;
    procedure AcceptFiles( var msg : TWMDropFiles ); message WM_DROPFILES;
    procedure DockForm; override;
    procedure FloatForm; override;

    procedure pluginMenuClick(Sender: TObject); override;

    property getJid: Widestring read jid;
    property CurrentThread: string read _thread;
    property LastImage: integer read _old_img;
  end;

var
  frmChat: TfrmChat;

function StartChat(sjid, resource: widestring; show_window: boolean; chat_nick: widestring=''): TfrmChat;
procedure CloseAllChats;

implementation
uses
    CapPresence, RosterImages, PrtRichEdit, RTFMsgList, BaseMsgList, 
    CustomNotify, COMChatController, Debug, ExEvents,
    JabberConst, ExSession, JabberUtils, ExUtils,  Presence, PrefController, Room,
    XferManager, RosterAdd, RiserWindow, Notify,
    Jabber1, Profile, MsgDisplay, GnuGetText,
    JabberMsg, Roster, Session, XMLUtils,
    ShellAPI, RosterWindow, Emoticons;

const
    sReplying = ' is replying.';
    sChatActivity = 'Chat Activity: ';
    sUserBlocked = 'This user is now blocked.';
    sIsNow = 'is now';
    sAvailable = 'available';
    sOffline = 'offline';
    sCloseBusy = 'This chat window is busy. Close anyways?';
    sChat = 'Chat';
    sAlreadySubscribed = 'You are already subscribed to this contact';
    sMsgLocalTime = 'Local Time: ';

{$R *.dfm}   

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
function StartChat(sjid, resource: widestring; show_window: boolean; chat_nick: widestring=''): TfrmChat;
var
    r, m: integer;
    chat: TChatController;
    win: TfrmChat;
    tmp_jid: TJabberID;
    cjid: widestring;
    ritem: TJabberRosterItem;
    new_chat: boolean;
    do_scroll: boolean;
    exp: boolean;
    hist: string;
begin
    // either show an existing chat or start one.
    chat := MainSession.ChatList.FindChat(sjid, resource, '');
    new_chat := false;
    do_scroll := false;
    hist := '';

    // If we have an existing chat, we may just want to raise it
    // or redock it, etc...
    r := MainSession.Prefs.getInt(P_CHAT);
    m := MainSession.Prefs.getInt('chat_memory');

    if (((r = msg_existing_chat) and (m > 0)) and (chat <> nil)) then begin
        win := TfrmChat(chat.window);
        if (win <> nil) then begin
            if (win.Docked) then begin
                if (not win.Visible) then
                    win.ShowDefault()
                else if (win.TabSheet <> nil) then
                    frmExodus.Tabs.ActivePage := win.TabSheet;
            end
            else
                win.ShowDefault();
            Result := win;
            exit;
        end;

        DebugMsg('Existing chat refcount: ' + IntToStr(chat.RefCount));
    end;

    // Create a new chat controller if we don't have one
    if chat = nil then begin
        chat := MainSession.ChatList.AddChat(sjid, resource);
    end;

    // Create a window if we don't have one.
    if (chat.window = nil) then begin
        new_chat := true;
        win := TfrmChat.Create(Application);
        chat.Window := win;
        chat.stopTimer();
        win.chat_object := chat;
        win.chat_object.AddRef();
        hist := TrimRight(chat.getHistory());
        DebugMsg('new window chat refcount: ' + IntToStr(chat.RefCount));
    end;

    // Setup the properties of the window,
    // and hook it up to the chat controller.
    with TfrmChat(chat.window) do begin
        _thread := chat.getThreadID();
        tmp_jid := TJabberID.Create(sjid);
        if (chat_nick = '') then begin
            ritem := MainSession.roster.Find(sjid);
            if (ritem = nil) then begin
                // If not in our roster, check for a TC room
                if (IsRoom(sjid)) then
                    chat_nick := FindRoomNick(sjid + '/' + resource);

                if (chat_nick = '') then
                    OtherNick := tmp_jid.user
                else
                    OtherNick := chat_nick;
            end
            else begin
                OtherNick := ritem.Text;
                mnuSendFile.Enabled := ritem.IsNative;
                C1.Enabled := ritem.IsNative;
            end;
        end
        else
            OtherNick := chat_nick;

        if resource <> '' then
            cjid := sjid + '/' + resource
        else
            cjid := sjid;
        tmp_jid.Free;

        if (SetJID(cjid) = false) then begin
            // we can't chat with this person for some reason
            Result := nil;
            chat.Free();
            exit;
        end;

        SetupResources();

        chat.OnMessage := MessageEvent;

        // handle setting position for this window
        if (not MainSession.Prefs.RestorePosition(TfrmChat(chat.window),
            MungeName(Caption))) then
            Position := poDefaultPosOnly;

        ShowDefault();
        exp := MainSession.Prefs.getBool('expanded');
        if ((show_window) and (Application.Active)) then begin
            Show();
            if (((exp) and (frmExodus.Tabs.ActivePage = TfrmChat(chat.window).TabSheet)) or
                (exp = false)) then begin
                if (TfrmChat(chat.window).Visible) then
                    TfrmChat(chat.window).SetFocus();
            end;
        end;

        if (hist <> '') then begin
            MsgList.populate(hist);
            do_scroll := true;
        end;

        PlayQueue();

        // scroll to the bottom..
        if (do_scroll) then
            _scrollBottom();
    end;

    if (new_chat) then
        ExCOMController.fireNewChat(sjid, TExodusChat(chat.ComController));

    Result := TfrmChat(chat.window);
end;

{---------------------------------------}
procedure CloseAllChats;
var
    i: integer;
    c: TChatController;
begin
    with MainSession.ChatList do begin
        for i := Count - 1 downto 0 do begin
            c := TChatController(Objects[i]);
            Delete(i);
            if c <> nil then begin
                if c.window <> nil then
                    TfrmChat(c.window).Free();
            end;
        end;
    end;
end;

{---------------------------------------}
procedure TfrmChat.FormCreate(Sender: TObject);
begin
    inherited;
    _thread := '';
    _pcallback := -1;
    _scallback := -1;
    OtherNick := '';
    _pres_img := RosterTreeImages.Find('unknown');
    _check_event := false;
    _last_id := '';
    _reply_id := '';
    _msg_out := false;
    _jid := nil;
    _destroying := false;
    _res_menus := TWidestringlist.Create();
    _unknown_avatar := TBitmap.Create();
    frmExodus.bigImages.GetBitmap(0, _unknown_avatar);

    _notify[0] := MainSession.Prefs.getInt('notify_chatactivity');

    SetupPrefs();
    SetupMenus();

    // branding/menus
    with MainSession.Prefs do begin
        if ((getBool('brand_ft')) and
            (MainSession.Profile.ConnectionType = conn_normal)) then begin
            mnuSendFile.Enabled := true;
            DragAcceptFiles( Handle, True );
        end
        else
            mnuSendFile.Visible := false;
    end;

end;

{---------------------------------------}
procedure TfrmChat.setupMenus();
begin
    mnuHistory.Enabled := (ExCOMController.ContactLogger <> nil);
    popClearHistory.Enabled := (ExCOMController.ContactLogger <> nil);
end;

{---------------------------------------}
procedure TfrmChat.SetupPrefs();
begin
    AssignDefaultFont(Self.Font);
    AssignUnicodeURL(lblNick.Font, 12);

    // setup prefs
    MsgList.setupPrefs();
    MsgOut.Color := TColor(MainSession.Prefs.getInt('color_bg'));
    MsgOut.Font.Assign(Self.Font);

    _embed_returns := MainSession.Prefs.getBool('embed_returns');
    _wrap_input := MainSession.Prefs.getBool('wrap_input');
    _warn_busyclose := MainSession.Prefs.getBool('warn_closebusy');
    mnuReturns.Checked := _embed_returns;
    mnuWordwrap.Checked := _wrap_input;
    MsgOut.WantReturns := _embed_returns;
    MsgOut.WordWrap := _wrap_input;

    _mynick := MainSession.Prefs.getString('default_nick');
    if (_mynick = '') then
        _mynick := MainSession.Profile.getDisplayUsername();
end;

{---------------------------------------}
procedure TfrmChat.SetupResources();
var
    i: integer;
    p: TJabberPres;
    m: TMenuItem;
begin
    // Make sure we have menu items for all resources
    p := MainSession.ppdb.FindPres(_jid.jid, '');
    while (p <> nil) do begin
        i := _res_menus.IndexOf(p.fromJid.Resource);
        if (i = -1) then begin
            m := TMenuItem.Create(popContact);
            m.Caption := p.fromJID.resource;
            m.OnClick := popResourcesClick;
            popResources.Add(m);
            _res_menus.AddObject(p.fromJid.resource, m);
        end;
        p := MainSession.ppdb.NextPres(p);
    end;

    // Make sure we purge old ones..
    for i := _res_menus.Count - 1 downto 0 do begin
        p := MainSession.ppdb.FindPres(_jid.jid, _res_menus[i]);
        if (p = nil) then begin
            TMenuItem(_res_menus.Objects[i]).Free();
            _res_menus.Delete(i);
        end;
    end;
end;


{---------------------------------------}
function TfrmChat.SetJID(cjid: widestring): boolean;
var
    ritem: TJabberRosterItem;
    p: TJabberPres;
    m, i: integer;
    a: TAvatar;
    //do_pres: boolean;
    //dp: TCapPresence;
    n: Widestring;
begin
    Result := true;
    jid := cjid;
    if (_jid <> nil) then _jid.Free();

    _jid := TJabberID.Create(cjid);
    _avatar := nil;
    Panel1.ClientHeight := 28;

    // check for an avatar
    if (MainSession.Prefs.getBool('chat_avatars')) then begin
        a := Avatars.Find(_jid.jid);
        if ((a <> nil) and (a.isValid())) then begin
            // Put some upper bounds on avatars in chat windows
            m := a.Height;
            if (m >= 0) then begin
                _avatar := a;
                if (m > 32) then begin
                    m := 32;
                    imgAvatar.Width := Trunc((32 / _avatar.Height) * (_avatar.Width))
                end
                else
                    imgAvatar.Width := _avatar.Width;

                Panel1.ClientHeight := m + 1;
            end;
        end
    end
    else begin
        // No avatars are displayed
        imgAvatar.Visible := false;
    end;

    // setup the callbacks if we don't have them already
    if (_pcallback = -1) then
        _pcallback := MainSession.RegisterCallback(PresCallback,
            '/packet/presence[@from="' + Lowercase(cjid) + '*"]');

    if (_scallback = -1) then
        _scallback := MainSession.RegisterCallback(SessionCallback, '/session');

    // setup the captions, etc..
    ritem := MainSession.Roster.Find(_jid.jid);
    p := MainSession.ppdb.FindPres(_jid.jid, _jid.resource);

    // whether or not to send directed presence to this person
    // do_pres := true;

    if ((ritem <> nil) and (ritem.tag <> nil) and
        (ritem.tag.GetAttribute('xmlns') = 'jabber:iq:roster')) then begin

        // if this person can not do offline msgs, and they are offline, bail
        if ((not ritem.CanOffline) and (p = nil)) then begin
            MessageDlgW(_('This contact can not receive offline messages.'), mtError,
                [mbOK], 0);
            Result := false;
            exit;
        end;

        // This person is in our roster
        lblNick.Caption := ritem.Text;
        Caption := ritem.Text;
        lblNick.Hint := _jid.getDisplayFull();
        MsgList.setTitle(ritem.Text);
        if (p = nil) then
            ChangePresImage(ritem, 'offline', 'offline')
        else
            ChangePresImage(ritem, p.show, p.status);
        {
        if ((ritem.Subscription = 'to') or (ritem.Subscription = 'both')) then
            do_pres := false;
        }
    end
    else begin
        if (OtherNick <> '') then
            n := OtherNick
        else if (_jid.userDisplay <> '') then
            n := _jid.userDisplay
        else
            n := _jid.getDisplayFull();

        lblNick.Caption := n;
        lblNick.Hint := cjid;
        MsgList.setTitle(cjid);
        Caption := n;
        if (p = nil) then
            ChangePresImage(nil, 'unknown', 'Unknown Presence')
        else
            ChangePresImage(nil, p.show, p.status);
    end;

    // TODO: Can't send directed presence to people not in roster. Cope w/ TC??
    // because this causes havoc w/ TC rooms that we are in, or NOT in
    {
    if (do_pres) then begin
        dp := TCapPresence.Create();
        dp.Status := MainSession.Status;
        dp.Show := MainSession.Show;
        dp.Priority := MainSession.Priority;
        dp.setAttribute('to', _jid.full);
        MainSession.SendTag(dp);
    end;
    }

    // synchronize the session chat list with this JID
    i := MainSession.ChatList.indexOfObject(chat_object);
    if (i >= 0) then
        MainSession.ChatList[i] := cjid;
end;

{---------------------------------------}
function TfrmChat.GetThread: String;
Var
    seed: string;
begin
    if _thread <> '' then exit;

    seed := FormatDateTime('MMDDYYYYHHMM',now);
    seed := seed + jid + MainSession.Username + MainSession.Server;

    // hash the seed to get the thread
    _thread := Sha1Hash(seed);
    chat_object.setThreadID(_thread);
    Result := _thread;
end;

{---------------------------------------}
procedure TfrmChat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
    inherited;
end;

{---------------------------------------}
procedure TfrmChat.PlayQueue();
var
    t: TXMLTag;
begin
    // pull all of the msgs from the controller queue,
    // and feed them into this window
    if (chat_object = nil) then exit;

    while (chat_object.msg_queue.AtLeast(1)) do begin
        t := TXMLTag(chat_object.msg_queue.Pop());
        Self.MessageEvent(t);
    end;
end;

{---------------------------------------}
procedure TfrmChat.MessageEvent(tag: TXMLTag);
var
    xml, body: Widestring;
    msg_type, from_jid: WideString;
    etag, tagThread : TXMLTag;
begin
    // callback for messages
    // check for a jabber:x:event tag
    msg_type := tag.GetAttribute('type');
    from_jid := tag.getAttribute('from');

    if from_jid <> jid then begin
        chat_object.SetJID(from_jid);
        SetJID(from_jid);
    end;

    if (msg_type = 'error') then begin
        showMsg(tag);
        exit;
    end;

    if (_check_event) then begin
        // check for composing events
        etag := tag.QueryXPTag(XP_MSGXEVENT);
        if ((etag <> nil) and (etag.GetFirstTag('composing') <> nil))then begin
            // we got a composing a message
            if (etag.GetBasicText('id') = _last_id) then begin
                _flash_ticks := 0;

                // Setup the cache'd old versions in ChangePresImage
                _cur_img := _pres_img;
                MsgList.DisplayComposing('-- ' + OtherNick + _(' is replying --'));

                {
                should we really bail here??
                Gabber sends type=chat for msg events so it'll get into the
                next block of code anyways. If we don't bail,
                then we'll have to check to see if we have a body in the
                next block of code. ICK
                }

                exit;
            end
            else if (etag.GetFirstTag('id') <> nil) then
                MsgList.HideComposing();
        end;
    end;

    // process the msg
    etag := tag.QueryXPTag(XP_MSGCOMPOSING);
    _sent_composing := false;
    _send_composing := (etag <> nil);
    if (_send_composing) then
        _reply_id := tag.GetAttribute('id');

    // plugin
    xml := tag.xml();
    body := tag.GetBasicText('body');
    TExodusChat(chat_object.ComController).fireRecvMsg(body, xml);

    // make sure we are visible..
    if (not visible) then begin
        ShowDefault();
    end;

    showMsg(tag);
    if _thread = '' then begin
        // cache thread from message
        tagThread := tag.GetFirstTag('thread');
        if tagThread <> nil then begin
            _thread := tagThread.Data;
            chat_object.setThreadID(_thread);
        end;
   end;
end;

{---------------------------------------}
procedure TfrmChat.showMsg(tag: TXMLTag);
var
    m, etag: TXMLTag;
    subj_msg, msg: TJabberMessage;
    emsg, err: Widestring;
begin
    // display the body of the msg
    if (_warn_busyclose) then begin
        timBusy.Enabled := false;
        timBusy.Enabled := true;
    end;

    if (tag.GetAttribute('type') = 'error') then begin
        // Display the error info..
        err := _('The last message bounced!. ');
        etag := tag.GetFirstTag('error');
        if (etag <> nil) then begin
            emsg := etag.QueryXPData('/error/text[@xmlns="urn:ietf:params:xml:ns:xmpp-streams"]');
            if (emsg = '') then emsg := etag.Data;
            err := err + emsg;
            err := err + '(' + _('Error Code: ') + etag.GetAttribute('code') + ')';
        end;
        MessageDlgW(err, mtError, [mbOK], 0);
        exit;
    end;

    _check_event := false;
    MsgList.HideComposing();

    Msg := TJabberMessage.Create(tag);
    Msg.Nick := OtherNick;
    Msg.IsMe := false;

    if (Msg.Thread = '') then begin
        if (_thread <> '') then
            Msg.Thread := _thread
        else begin
            _thread := GetThread();
            Msg.Thread := _thread;
        end;
    end;

    // only display + notify if we have something to display :)
    if (Msg.Subject <> '') then begin
        subj_msg := TJabberMessage.Create(tag);
        subj_msg.Body := 'The subject has been changed to: ' + subj_msg.Subject;
        subj_msg.Subject := '';
        subj_msg.Nick := '';
        DisplayMsg(subj_msg, MsgList);
        subj_msg.Free();
    end;

    if (Msg.Body <> '') then begin
        DoNotify(Self, _notify[0], _(sChatActivity) + OtherNick,
            RosterTreeImages.Find('contact'), 'notify_chatactivity');
        DisplayMsg(Msg, MsgList);

        // log if we want..
        LogMessage(Msg);

        // check for displayed events
        etag := tag.QueryXPTag(XP_MSGXEVENT);
        if ((etag <> nil) and (etag.GetFirstTag('id') = nil)) then begin
            if (etag.GetFirstTag('displayed') <> nil) then begin
                // send back a displayed event
                m := generateEventMsg(tag, 'displayed');
                MainSession.SendTag(m);
            end;
        end;
    end;

    Msg.Free();
end;

{---------------------------------------}
procedure TfrmChat.SendRawMessage(body, subject, xml: Widestring;
    fire_plugins: boolean);
var
    add_xml: WideString;
    msg: TJabberMessage;
    mtag: TXMLTag;
begin
    if _thread = '' then begin   //get thread from message
        _thread := GetThread;
    end;

    // send the msg
    // XXX: PGM: is this your trim?  What should we do with messages that
    // start with $#D, etc.?
    msg := TJabberMessage.Create(jid, 'chat', Trim(body), '');
    msg.thread := _thread;
    msg.nick := _mynick;
    msg.isMe := true;

    _last_id := MainSession.generateID();
    _check_event := true;
    msg.id := _last_id;

    // put in the composing stuff
    mtag := msg.Tag;
    with mtag.AddTag('x') do begin
        setAttribute('xmlns', XMLNS_XEVENT);
        AddTag('composing');
    end;

    // additional plugin madness
    if (fire_plugins) then begin
        if (chat_object <> nil) then
            add_xml := TExodusChat(chat_object.ComController).fireAfterMsg(body);
        if (add_xml <> '') then
            mtag.addInsertedXML(add_xml);
    end;

    // add any xml passed to us
    if (xml <> '') then mtag.addInsertedXML(xml);

    MainSession.SendTag(mtag);
    DisplayMsg(Msg, MsgList);

    // log the msg
    LogMessage(Msg);

    Msg.Free();
end;

{---------------------------------------}
function TfrmChat._sendMsg(txt: Widestring): boolean;
var
    allowed: boolean;
begin
    // plugin madness
    allowed := true;
    if (chat_object <> nil) then
        allowed := TExodusChat(chat_object.ComController).fireBeforeMsg(txt);

    Result := allowed;
    if ((allowed = false) or (txt = '')) then exit;

    sendRawMessage(txt, '', '', true);
end;

{---------------------------------------}
procedure TfrmChat.SendMsg;
var
    txt: Widestring;
begin
    // Send the actual message out
    txt := getInputText(MsgOut);
    if (txt = '/clear') then begin
      Clear1Click(self);
      MsgOut.Clear();
      exit;
    end;

    if (_sendMsg(txt)) then begin
        _sent_composing := false;
        inherited;
    end;
end;

{---------------------------------------}
procedure TfrmChat.MsgOutKeyPress(Sender: TObject; var Key: Char);
begin
    if (Key = #0) then exit;
    if (chat_object = nil) then exit;

    // dispatch key-presses to Plugins
    TExodusChat(chat_object.ComController).fireMsgKeyPress(Key);

    inherited;
end;

{---------------------------------------}
procedure TfrmChat.SessionCallback(event: string; tag: TXMLTag);
begin
    if (event = '/session/disconnected') then begin
        MsgList.DisplayPresence(_('You have been disconnected.'), '');
        MainSession.UnRegisterCallback(_pcallback);
        _pcallback := -1;

        // this should make sure that hidden windows
        // just go away when we get disconnected.
        if (not Visible) then Self.Free();
    end
    else if (event = '/session/connected') then begin
        Self.SetJID(jid);
    end
    else if (event = '/session/prefs') then
        SetupPrefs()

    else if (event = '/session/logger') then
        SetupMenus()

    else if (event = '/session/block') then begin
        // if this jid just got blocked, just close the window.
        if (_jid.jid = tag.GetAttribute('jid')) then begin
            MsgList.DisplayPresence(_(sUserBlocked), '');
            MainSession.UnRegisterCallback(_pcallback);
            _pcallback := -1;
            freeChatObject();
        end;
    end;
end;

{---------------------------------------}
procedure TfrmChat.PresCallback(event: string; tag: TXMLTag);
begin
    // display some presence packet
    if (event = 'xml') then begin
        showPres(tag);
        SetupResources();
    end;
end;

{---------------------------------------}
procedure TfrmChat.ChangePresImage(ritem: TJabberRosterItem; show: WideString; status: WideString);
var
    h: Widestring;
begin
    // Change the bulb
    if (ritem = nil) then begin
        // TODO: get image prefix from prefs
        if (show = _('offline')) then
            _pres_img := RosterTreeImages.Find('offline')
        else if (show = _('unknown')) then
            _pres_img := RosterTreeImages.Find('unknown')
        else if (show = _('away')) then
            _pres_img := RosterTreeImages.Find('away')
        else if (show = _('xa')) then
            _pres_img := RosterTreeImages.Find('xa')
        else if (show = _('dnd')) then
            _pres_img := RosterTreeImages.Find('dnd')
        else if (show = _('chat')) then
            _pres_img := RosterTreeImages.Find('chat')
        else
            _pres_img := RosterTreeImages.Find('available')
    end
    else begin
        // Always use the image from the roster item
        _pres_img := ritem.getPresenceImage(show);
    end;

    _show := show;
    _status := status;

    h := show;
    if (status <> '') then h := h + ', ' + status;
    h := h + ' <' + _jid.getDisplayFull() + '>';
    lblNick.Hint := h;

    RosterTreeImages.GetIcon(_pres_img, Self.Icon);
    if ((Docked) and (Self.TabSheet.ImageIndex <> tab_notify)) then
        Self.TabSheet.ImageIndex := _pres_img;
    _old_img := _pres_img;

end;

{---------------------------------------}
procedure TfrmChat.showPres(tag: TXMLTag);
var
    txt: WideString;
    status, show, User, ts  : String;
    p: TJabberPres;
    j: TJabberID;
    ritem: TJabberRosterItem;
begin
    // Get the user
    user := tag.GetAttribute('from');

    // make sure the user is still connected
    j := TJabberID.Create(jid);

    ritem := MainSession.Roster.Find(j.jid);
    if (ritem = nil) then
        ritem := MainSession.Roster.Find(j.full);

    // Get the pres for this resource
    p := MainSession.ppdb.FindPres(j.jid, j.resource);
    if (p = nil) then begin
        show := _(sOffline);
        status := _(sOffline);
    end
    else begin
        show := tag.GetBasicText('show');
        status := tag.GetBasicText('status');
    end;

    j.Free();
    ChangePresImage(ritem, show, status);

    if (status = '') then
        txt := show
    else
        txt := status;

    if (txt = '') then
        txt := _(sAvailable);

    if (MainSession.Prefs.getBool('timestamp')) then
        ts := FormatDateTime(MainSession.Prefs.getString('timestamp_format'), Now)
    else
        ts := '';

    MsgList.DisplayPresence(jid + ' ' + _(sIsNow) + ' ' + txt, ts);
end;

{---------------------------------------}
procedure TfrmChat.doHistory(Sender: TObject);
begin
  inherited;
    ShowLog(_jid.jid);
end;

{---------------------------------------}
procedure TfrmChat.doProfile(Sender: TObject);
begin
  inherited;
    ShowProfile(_jid.jid);
end;

{---------------------------------------}
procedure TfrmChat.doAddToRoster(Sender: TObject);
var
    ritem: TJabberRosterItem;
begin
  inherited;
    // check to see if we're already subscribed...
    ritem := MainSession.roster.find(_jid.jid);
    if ((ritem <> nil) and ((ritem.subscription = 'both') or (ritem.subscription = 'to'))) then begin
        MessageDlgW(_(sAlreadySubscribed), mtInformation,
            [mbOK], 0);
        exit;
    end
    else begin
        ShowAddContact(TJabberID.Create(_jid.full));
    end;

end;

{---------------------------------------}
procedure TfrmChat.lblJIDClick(Sender: TObject);
var
    cp: TPoint;
begin
  inherited;
    GetCursorPos(cp);
    popContact.popup(cp.x, cp.y);
end;

{---------------------------------------}
procedure TfrmChat.mnuReturnsClick(Sender: TObject);
begin
  inherited;
    mnuReturns.Checked := not mnuReturns.Checked;
    MsgOut.WantReturns := mnuReturns.Checked;
    _embed_returns := mnuReturns.Checked;
    MainSession.Prefs.setBool('embed_returns', _embed_returns);
end;

{---------------------------------------}
procedure TfrmChat.mnuWordwrapClick(Sender: TObject);
begin
    inherited;
    mnuWordwrap.Checked := not mnuWordWrap.Checked;
    _wrap_input := mnuWordwrap.Checked;
    MsgOut.WordWrap := _wrap_input;
    MainSession.Prefs.setBool('wrap_input', _wrap_input);
end;

{---------------------------------------}
procedure TfrmChat.mnuSendFileClick(Sender: TObject);
begin
  inherited;
    FileSend(_jid.full);
end;

{---------------------------------------}
procedure TfrmChat._sendComposing(id: Widestring);
var
    c: TXMLTag;
begin
    c := TXMLTag.Create('message');
    with c do begin
        setAttribute('to', jid);
        setAttribute('type', 'chat');
        with AddTag('x') do begin
            setAttribute('xmlns', XMLNS_XEVENT);
            AddTag('composing');
            if (id <> '') then
                AddBasicTag('id', id)
            else
                AddTag('id');
        end;
    end;

    if (MainSession.Active) then
        MainSession.SendTag(c);
end;

{---------------------------------------}
procedure TfrmChat.MsgOutChange(Sender: TObject);
begin
  inherited;
    if ((_sent_composing) and (MsgOut.Text = '')) then begin
        // send cancel event
        _sendComposing('');
        _sent_composing := false;
        _send_composing := true;
    end
    else if (_send_composing) then begin
        _sendComposing(_reply_id);
        _sent_composing := true;
        _send_composing := false;
    end;
end;

{---------------------------------------}
procedure TfrmChat.AcceptFiles( var msg : TWMDropFiles );
const
    cnMaxFileNameLen = 255;
var
    i,
    nCount     : integer;
    acFileName : array [0..cnMaxFileNameLen] of char;
begin
    // find out how many files we're accepting
    if (MainSession.Prefs.getBool('brand_ft') = false) then exit;

    nCount := DragQueryFile( msg.Drop, $FFFFFFFF, acFileName, cnMaxFileNameLen );

    // query Windows one at a time for the file name
    for i := 0 to nCount-1 do begin
        DragQueryFile( msg.Drop, i, acFileName, cnMaxFileNameLen );
        // do your thing with the acFileName
        FileSend(_jid.full, acFileName);
    end;

    // let Windows know that you're done
    DragFinish( msg.Drop );
end;

{---------------------------------------}
procedure TfrmChat.freeChatObject();
begin
    if (chat_object = nil) then exit;
    chat_object.unassignEvent();
    chat_object.window := nil;
    chat_object.Release();
    chat_object := nil;
end;

{---------------------------------------}
procedure TfrmChat.FormDestroy(Sender: TObject);
begin
    // Unregister the callbacks + stuff
    if (MainSession <> nil) then begin
        MainSession.UnRegisterCallback(_pcallback);
        MainSession.UnRegisterCallback(_scallback);
    end;

    if (chat_object <> nil) then
        freeChatObject();

    if (_jid <> nil) then
        FreeAndNil(_jid);

    _res_menus.Clear();
    _res_menus.Free();

    DragAcceptFiles(Handle, false);

    inherited;
end;

{---------------------------------------}
procedure TfrmChat.CTCPClick(Sender: TObject);
var
    jid: WideString;
    p: TJabberPres;
begin
    // get some CTCP query sent out
    p := MainSession.ppdb.FindPres(_jid.jid, '');
    if p = nil then
        // this person isn't online.
        jid := _jid.jid
    else
        jid := p.fromJID.full;

    if Sender = mnuVersionRequest then
        _cur_ver := jabberSendCTCP(jid, XMLNS_VERSION, CTCPCallback)
    else if Sender = mnuTimeRequest then
        _cur_time := jabberSendCTCP(jid, XMLNS_TIME, CTCPCallback)
    else if Sender = mnuLastActivity then
        _cur_last := jabberSendCTCP(jid, XMLNS_LAST, CTCPCallback);
end;

{---------------------------------------}
procedure TfrmChat.CTCPCallback(event: string; tag: TXMLTag);
var
    from: WideString;
    ns: WideString;
    procedure DispString(str: WideString);
    var
        subj_msg: TJabberMessage;
    begin
        subj_msg := TJabberMessage.Create();
        subj_msg.Body := str;
        subj_msg.Subject := '';
        subj_msg.Nick := '';
        DisplayMsg(subj_msg, MsgList);
        subj_msg.Free();
    end;
begin
    // record some kind of CTCP result
    if ((tag <> nil) and (tag.getAttribute('type') = 'result')) then begin
        from := tag.getAttribute('from');

        ns := tag.Namespace(true);
        if ns = XMLNS_TIME then begin
            _cur_time := nil;
            DispString(ParseTimeEvent(tag));
        end

        else if ns = XMLNS_VERSION then begin
            _cur_ver := nil;
            DispString(ParseVersionEvent(tag)); 
        end

        else if ns = XMLNS_LAST then begin
            _cur_last := nil;
            DispString(ParseLastEvent(tag));
        end;

    end;
end;

{---------------------------------------}
procedure TfrmChat.mnuBlockClick(Sender: TObject);
begin
    MainSession.Block(_jid);
    freeChatObject();
end;

{---------------------------------------}
procedure TfrmChat.DockForm;
var
    ritem: TJabberRosterItem;
begin
    inherited;
    btnClose.Visible := true;
    DragAcceptFiles( Handle, False );

    ritem := MainSession.Roster.Find(_jid.jid);
    if (ritem = nil) then
        ritem := MainSession.Roster.FInd(_jid.full);
        
    ChangePresImage(ritem, _show, _status);
end;

{---------------------------------------}
procedure TfrmChat.FloatForm;
begin
    inherited;
    btnClose.Visible := false;
    DragAcceptFiles(Handle, True);
end;

{---------------------------------------}
procedure TfrmChat.FormEndDock(Sender, Target: TObject; X, Y: Integer);
var
    ritem: TJabberRosterItem;
begin
    if (target = nil) then exit;

    inherited;

    btnClose.Visible := Docked;
    if ((Docked) and (TabSheet <> nil)) then
        Self.TabSheet.ImageIndex := _old_img;

    DragAcceptFiles(Handle, not Docked);

    // scroll the MsgView to the bottom.
    _scrollBottom();
    Self.Refresh();

    ritem := MainSession.Roster.Find(_jid.jid);
    if (ritem = nil) then
        ritem := MainSession.Roster.Find(_jid.full);
    ChangePresImage(ritem, _show, _status);
end;

{---------------------------------------}
procedure TfrmChat.mnuSaveClick(Sender: TObject);
begin
  inherited;
    // save the conversation as RTF
    if SaveDialog1.Execute then begin
        MsgList.Save(SaveDialog1.Filename);
    end;
end;

{---------------------------------------}
procedure TfrmChat.mnuOnTopClick(Sender: TObject);
begin
  inherited;
    mnuOnTop.Checked := not mnuOnTop.Checked;

    if (mnuOnTop.Checked) then
        Self.FormStyle := fsStayOnTop
    else
        Self.FormStyle := fsNormal;
end;

{---------------------------------------}
procedure TfrmChat.FormResize(Sender: TObject);
begin
  inherited;
    // make the close btn be right justified..
    btnClose.Left := Panel1.Width - btnClose.Width - 2;
    pnlJID.Width := Panel1.Width - btnClose.Width - 5;
end;

{---------------------------------------}
procedure TfrmChat.btnCloseClick(Sender: TObject);
begin
    Self.Close();
end;

{---------------------------------------}
procedure TfrmChat.popClearHistoryClick(Sender: TObject);
begin
    inherited;
    ClearLog(Self._jid.jid)
end;

{---------------------------------------}
procedure TfrmChat.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    s: String;
begin
    if ((_warn_busyclose) and
        ((timBusy.Enabled) or (MsgList.isComposing()))) then begin
        if MessageDlgW(_(sCloseBusy), mtConfirmation, [mbYes, mbNo], 0) = mrNo then begin
            CanClose := false;
            exit;
        end;
    end;

    // Cancel our composing event
    if (_sent_composing) then
        _sendComposing('');

    if (_cur_ver <> nil) then FreeAndNil(_cur_ver);
    if (_cur_time <> nil) then FreeAndNil(_cur_time);
    if (_cur_last <> nil) then FreeAndNil(_cur_last);

    if ((MainSession.Prefs.getInt('chat_memory') > 0) and
        (MainSession.Prefs.getInt(P_CHAT) = msg_existing_chat) and
        (not MsgList.empty()) and
        (chat_object <> nil) and
        (not _destroying)) then begin
        s := MsgList.getHistory();
        chat_object.SetHistory(s);
        chat_object.UnassignEvent();
        chat_object.Window := nil;
        chat_object.TimedRelease();
        DebugMsg('(close) chat refcount: ' + IntToStr(chat_object.RefCount));
        chat_object := nil;
    end;

    inherited;
end;

{---------------------------------------}
procedure TfrmChat.FormShow(Sender: TObject);
begin
  inherited;
end;

{---------------------------------------}
procedure TfrmChat.btnCloseMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    _destroying := (ssCtrl in Shift);
end;

{---------------------------------------}
procedure TfrmChat.NotificationOptions1Click(Sender: TObject);
var
    f: TfrmCustomNotify;
begin
    // change notification options..
    f := TfrmCustomNotify.Create(Application);

    f.addItem('Chat activity');
    f.setVal(0, _notify[0]);
    if (f.ShowModal) = mrOK then begin
        _notify[0] := f.getVal(0);
    end;

    f.Free();
end;

{---------------------------------------}
procedure TfrmChat.timBusyTimer(Sender: TObject);
begin
  inherited;
    timBusy.Enabled := false;
end;

{---------------------------------------}
procedure TfrmChat.pluginMenuClick(Sender: TObject);
begin
    if (chat_object <> nil) then
        TExodusChat(chat_object.ComController).fireMenuClick(Sender);
end;

{---------------------------------------}
procedure TfrmChat.popResourcesClick(Sender: TObject);
begin
  inherited;
    // set the message to this resource.
    SetJid(_jid.jid + '/' + TMenuItem(Sender).Caption);
end;

{---------------------------------------}
procedure TfrmChat.imgAvatarPaint(Sender: TObject);
var
    r: TRect;
begin
  inherited;
    if (_avatar <> nil) then begin
        if (_avatar.Height > imgAvatar.Height) then begin
            r.Top := 1;
            r.Left := 1;
            r.Bottom := imgAvatar.Height;
            r.Right := imgAvatar.Width;
            _avatar.Draw(imgAvatar.Canvas, r);
        end
        else
            _avatar.Draw(imgAvatar.Canvas);
    end
    else begin
        r.Top := 1;
        r.Left := 1;
        r.Bottom := 28;
        r.Right := 28;
        imgAvatar.Canvas.StretchDraw(r, _unknown_avatar);
    end;
end;

{---------------------------------------}
procedure TfrmChat.imgAvatarClick(Sender: TObject);
var
  r : TRect;
begin
  inherited;
  if (FloatingImage.FloatImage.Active) then exit;
  if (_avatar = nil) then exit;

  with FloatingImage.FloatImage do
  begin
    r := imgAvatar.ClientRect;
    r.TopLeft := imgAvatar.ClientOrigin;
    r.Right := r.Right + imgAvatar.ClientOrigin.X;
    r.Bottom := r.Bottom + imgAvatar.ClientOrigin.Y;
    ParentRect := r;
    Avatar := _avatar;
    Show();
  end;
end;

{---------------------------------------}
procedure TfrmChat.PrintHistory1Click(Sender: TObject);
var
    cap: Widestring;
    ml: TfBaseMsgList;
    msglist: TfRTFMsgList;
begin
  inherited;
    ml := getMsgList();

    if (ml is TfRTFMsgList) then begin
        msglist := TfRTFMsgList(ml);
        with PrintDialog1 do begin
            if (not Execute) then exit;

            cap := _('Chat Transcript: %s');
            cap := WideFormat(cap, [Self.Caption]);

            PrintRichEdit(cap, TRichEdit(msglist.MsgList), Copies, PrintRange);
        end;
    end;
end;

end.
