unit ChatWin;
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
    XMLTag,
    Clipbrd,
    RichEdit,
    JabberID,
    Chat, Dockable,
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    StdCtrls, ComCtrls, ExtCtrls, Buttons, Menus, ToolWin, ExRichEdit,
    AppEvnts, OLERichEdit, ImgList;

type
  TfrmChat = class(TfrmDockable)
    Splitter1: TSplitter;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    Clear1: TMenuItem;
    CopyAll1: TMenuItem;
    Panel3: TPanel;
    pnlInput: TPanel;
    SaveDialog1: TSaveDialog;
    Copy1: TMenuItem;
    MsgOut: TMemo;
    Panel7: TPanel;
    MsgList: TExRichEdit;
    pnlFrom: TPanel;
    lblJID: TStaticText;
    popContact: TPopupMenu;
    mnuHistory: TMenuItem;
    mnuBlock: TMenuItem;
    mnuProfile: TMenuItem;
    mnuSendFile: TMenuItem;
    mnuSave: TMenuItem;
    N1: TMenuItem;
    mnuReturns: TMenuItem;
    mnuEncrypt: TMenuItem;
    mnuAdd: TMenuItem;
    lblNick: TStaticText;
    imgStatus: TPaintBox;
    timFlash: TTimer;
    Emoticons1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure MsgOutKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure MsgOutKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnHistoryClick(Sender: TObject);
    procedure btnProfileClick(Sender: TObject);
    procedure btnAddRosterClick(Sender: TObject);
    procedure MsgListURLClick(Sender: TObject; url: String);
    procedure lblJIDClick(Sender: TObject);
    procedure mnuReturnsClick(Sender: TObject);
    procedure mnuSendFileClick(Sender: TObject);
    procedure imgStatusPaint(Sender: TObject);
    procedure timFlashTimer(Sender: TObject);
    procedure MsgOutChange(Sender: TObject);
    procedure Emoticons1Click(Sender: TObject);
  private
    { Private declarations }
    jid: string;            // jid of the person we are talking to
    _jid: TJabberID;        // JID object of jid
    _callback: integer;     // Message Callback
    _pcallback: integer;    // Presence Callback
    _scallback: integer;    // Session callback
    _thread : string;       // thread for conversation
    _pres_img: integer;     // current index of the presence image

    // Stuff for composing events
    _flash_ticks: integer;
    _cur_img: integer;
    _old_img: integer;
    _last_id: string;
    _reply_id: string;
    _check_event: boolean;
    _send_composing: boolean;

    procedure ChangePresImage(show: string);
    procedure ResetPresImage;

    function GetThread: String;

  protected
    {protected stuff}

  published
    procedure MsgCallback(event: string; tag: TXMLTag);
    procedure PresCallback(event: string; tag: TXMLTag);
    procedure SessionCallback(event: string; tag: TXMLTag);

  public
    { Public declarations }
    OtherNick: string;
    chat_object: TJabberChat;

    procedure showMsg(tag: TXMLTag);
    procedure showPres(tag: TXMLTag);
    procedure sendMsg;
    procedure SetJID(cjid: string);
    procedure SetEmoticon(msn: boolean; imgIndex: integer);
  end;

var
  frmChat: TfrmChat;

function StartChat(sjid, resource: string; show_window: boolean; chat_nick: string=''): TfrmChat;
procedure CloseAllChats;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation
{$R *.DFM}

uses
    Emoticons, 
    Presence, PrefController,
    Transfer, RosterAdd, RiserWindow,
    Jabber1, Profile, ExUtils, MsgDisplay,
    JabberMsg, Roster, Session, XMLUtils,
    ShellAPI, RosterWindow;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
function StartChat(sjid, resource: string; show_window: boolean; chat_nick: string=''): TfrmChat;
var
    chat: TJabberChat;
    win: TfrmChat;
    tmp_jid: TJabberID;
    cjid: string;
    lt: longword;
    ritem: TJabberRosterItem;
begin
    // either show an existing chat or start one.
    lt := frmJabber.last_tick;

    chat := MainSession.ChatList.FindChat(sjid, resource, '');
    if chat = nil then begin
        // Create one
        chat := MainSession.ChatList.AddChat(sjid, resource);
        win := TfrmChat.Create(nil);
        chat.window := win;
        win.chat_object := chat;
        end;

    with TfrmChat(chat.window) do begin
        tmp_jid := TJabberID.Create(sjid);
        if (chat_nick = '') then begin
            ritem := MainSession.roster.Find(sjid);
            if (ritem = nil) then
                OtherNick := tmp_jid.user
            else
                OtherNick := ritem.nickname;
            end
        else
            OtherNick := chat_nick;

        if resource <> '' then
            cjid := sjid + '/' + resource
        else
            cjid := sjid;
        tmp_jid.Free;
        SetJID(cjid);

        // setup prefs
        AssignDefaultFont(MsgList.Font);
        MsgList.Color := TColor(MainSession.Prefs.getInt('color_bg'));
        MsgOut.Color := MsgList.Color;
        MsgOut.Font.Assign(MsgList.Font);

        ShowDefault();
        if (show_window) then
            Show();
        end;
    Result := TfrmChat(chat.window);
    frmJabber.ResetLastTick(lt + 1000);
end;

{---------------------------------------}
procedure CloseAllChats;
var
    i: integer;
    c: TJabberChat;
begin
    with MainSession.ChatList do begin
        for i := Count - 1 downto 0 do begin
            c := TJabberChat(Objects[i]);
            if c <> nil then begin
                if c.window <> nil then
                    TfrmChat(c.window).chat_object := nil;
                    c.window.Close;
                end;
            c.Free;
            Delete(i);
            end;
        end;
end;


{---------------------------------------}
procedure TfrmChat.FormCreate(Sender: TObject);
begin
    inherited;
    _thread := '';
    _callback := -1;
    _pcallback := -1;
    _scallback := -1;
    OtherNick := '';
    _pres_img := -1;
    _check_event := false;
    _last_id := '';
    _reply_id := '';
end;

{---------------------------------------}
procedure TfrmChat.SetJID(cjid: string);
var
    ritem: TJabberRosterItem;
    p: TJabberPres;
    i: integer;
begin
    jid := cjid;
    _jid := TJabberID.Create(cjid);

    // setup the callbacks if we don't have them already
    if (_callback < 0) then begin
        _callback := MainSession.RegisterCallback(MsgCallback,
            '/packet/message[@from="' + Lowercase(cjid) + '*"]');
        _pcallback := MainSession.RegisterCallback(PresCallback,
            '/packet/presence[@from="' + Lowercase(cjid) + '*"]');
        end;

    if (_scallback < 0) then
        _scallback := MainSession.RegisterCallback(SessionCallback, '/session');

    // setup the captions, etc..
    ritem := MainSession.Roster.Find(_jid.jid);
    p := MainSession.ppdb.FindPres(_jid.jid, '');

    if ritem <> nil then begin
        lblNick.Caption := ' ' + ritem.Nickname;
        lblJID.Caption := '<' + _jid.full + '>';
        Caption := ritem.Nickname + ' - Chat';
        end
    else begin
        lblNick.Caption := ' ';
        lblJID.Caption := cjid;
        if OtherNick <> '' then
            Caption := OtherNick + ' - Chat'
        else
            Caption := _jid.user + ' - Chat';
        end;

    if (p = nil) then
        ChangePresImage('offline')
    else
        ChangePresImage(p.show);

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
    Result := _thread;
end;

{---------------------------------------}
procedure TfrmChat.FormClose(Sender: TObject; var Action: TCloseAction);
var
    i: integer;
begin
    // Unregister the callbacks + stuff
    MainSession.UnRegisterCallback(_pcallback);
    MainSession.UnRegisterCallback(_callback);
    MainSession.UnRegisterCallback(_scallback);

    if chat_object <> nil then begin
        i := MainSession.ChatList.IndexOfObject(chat_object);
        if i >= 0 then
            MainSession.ChatList.Delete(i);
        chat_object.Free;
        end;

    Action := caFree;
end;

{---------------------------------------}
procedure TfrmChat.btnCloseClick(Sender: TObject);
begin
    Self.Close;
end;

{---------------------------------------}
procedure TfrmChat.MsgCallback(event: string; tag: TXMLTag);
var
    msg_type, from_jid: string;
    etag, tagThread : TXMLTag;
begin
    // callback
    if MainSession.IsPaused then begin
        MainSession.QueueEvent(event, tag, Self.MsgCallback);
        exit;
        end;

    if Event = 'xml' then begin
        // check for a jabber:x:event tag
        msg_type := tag.GetAttribute('type');
        from_jid := tag.getAttribute('from');
        if from_jid <> jid then
            SetJID(from_jid);

        if (msg_type = 'chat') then begin
            // normal chat message
            if (timFlash.Enabled) then
                Self.ResetPresImage();
            _check_event := false;

            etag := tag.QueryXPTag('/message/*[@xmlns="jabber:x:event"]/composing');
            _send_composing := (etag <> nil);
            if (_send_composing) then
                _reply_id := tag.GetAttribute('id');

            showMsg(tag);
            if _thread = '' then begin
                //get thread from message
                tagThread := tag.GetFirstTag('thread');
                if tagThread <> nil then
                    _thread := tagThread.Data;
               end;
            end
        else if (_check_event) then begin
            // check for composing events
            etag := tag.QueryXPTag('/message/*[@xmlns="jabber:x:event"]');
            if ((etag <> nil) and (etag.GetFirstTag('composing') <> nil))then begin
                // they are composing a message
                if (etag.GetBasicText('id') = _last_id) then begin
                    _flash_ticks := 0;
                    _old_img := _pres_img;
                    _cur_img := _pres_img;
                    timFlashTimer(Self);
                    timFlash.Enabled := true;
                    end;
                end;
            end;

        end;
end;

{---------------------------------------}
procedure TfrmChat.showMsg(tag: TXMLTag);
var
    cn: integer;
    etag, btag: TXMLTag;
    Msg: TJabberMessage;
begin
    // display the body of the msg
    btag := tag.QueryXPTag('/message/body');
    etag := tag.QueryXPTag('/message/*@xmlns="jabber:iq:event"');
    if ((etag <> nil) and (btag = nil)) then begin
        // display the event type..
        end;

    cn := MainSession.Prefs.getInt('notify_chatactivity');

    if (not Application.Active) then begin
        // Pop toast
        if (cn and notify_toast) > 0 then begin
            ShowRiserWindow('Chat Activity: ' + OtherNick, 20);
            end;

        // Flash Window
        if (cn and notify_flash) > 0 then begin
            if (Self.Docked) then
                FlashWindow(frmJabber.Handle, true)
            else
                FlashWindow(Self.Handle, true);
            end;
        end;

    if ((btag = nil) or (btag.Data = '')) then exit;

    Msg := TJabberMessage.Create(tag);
    Msg.Nick := OtherNick;
    Msg.IsMe := false;
    DisplayMsg(Msg, MsgList);

    // log if we want..
    if (MainSession.Prefs.getBool('log')) then
        LogMessage(Msg);
end;

{---------------------------------------}
procedure TfrmChat.SendMsg;
var
    msg: TJabberMessage;
    mtag: TXMLTag;
begin
    // Send the actual message out
    if _thread = '' then begin   //get thread from message
        _thread := GetThread;
        end;

    // send the msg
    msg := TJabberMessage.Create(jid, 'chat', MsgOut.Text, '');
    msg.thread := _thread;
    msg.nick := MainSession.Username;
    msg.isMe := true;

    _last_id := MainSession.generateID();
    _check_event := true;
    msg.id := _last_id;

    mtag := msg.Tag;
    with mtag.AddTag('x') do begin
        PutAttribute('xmlns', XMLNS_MSGEVENTS);
        AddTag('composing');
        end;

    MainSession.SendTag(mtag);
    DisplayMsg(Msg, MsgList);

    // log the msg
    if (MainSession.Prefs.getBool('log')) then
        LogMessage(Msg);

    // Send cursor back to the txt entry box
    MsgOut.Text := '';
    MsgOut.SetFocus;
end;

{---------------------------------------}
procedure TfrmChat.MsgOutKeyPress(Sender: TObject; var Key: Char);
begin
    // Send the msg if they hit return
    if ( (Key = #13) and not(mnuReturns.Checked)) then
        SendMsg();
    if ( Key = #27 ) then
        Close();
end;

{---------------------------------------}
procedure TfrmChat.SessionCallback(event: string; tag: TXMLTag);
begin
    if (event = '/session/disconnected') then begin
        DisplayPresence('You have been disconnected', MsgList);
        MainSession.UnRegisterCallback(_callback);
        MainSession.UnRegisterCallback(_pcallback);
        _callback := -1;
        _pcallback := -1;
        end
    else if (event = '/session/connected') then begin
        Self.SetJID(jid);
        end;
end;

{---------------------------------------}
procedure TfrmChat.PresCallback(event: string; tag: TXMLTag);
begin
    // display some presence packet
    if Event = 'xml' then
        showPres(tag);
end;

{---------------------------------------}
procedure TfrmChat.ChangePresImage(show: string);
begin
    // Change the bulb
    if (show = 'offline') then
        _pres_img := ico_Offline
    else if (show = 'away') then
        _pres_img := ico_Away
    else if (show = 'xa') then
        _pres_img := ico_XA
    else if (show = 'dnd') then
        _pres_img := ico_DND
    else if (show = 'chat') then
        _pres_img := ico_Chat
    else
        _pres_img := ico_Online;

    Self.imgStatusPaint(Self);
end;

{---------------------------------------}
procedure TfrmChat.showPres(tag: TXMLTag);
var
    txt: string;
    s, User  : String;
begin
    // Get the user
    user := tag.GetAttribute('from');

    //check to see if this is the person you are chatting with...
    if pos(jid, user) = 0 then Exit;
    txt := '';

    s := tag.GetBasicText('show');
    ChangePresImage(s);

    txt := tag.GetBasicText('status');

    if (txt = '') then txt := s;
    if txt = '' then exit;

    txt := '[' + formatdatetime('HH:MM',now) + '] ' + jid + ' is now ' + txt;
    DisplayPresence(txt, MsgList);
end;

{---------------------------------------}
procedure TfrmChat.FormActivate(Sender: TObject);
begin
    if Self.Visible then
        MsgOut.SetFocus;
        
    if (frmEmoticons.Visible) then
        frmEmoticons.Hide;
end;

{---------------------------------------}
procedure TfrmChat.MsgOutKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
    cur_buff: string;
    s,e, i: integer;
begin
  inherited;
    if ((Key = VK_BACK) and (ssCtrl in Shift)) then begin
        // delete the last word
        cur_buff := MsgOut.Lines.Text;
        e := MsgOut.SelStart;
        s := -1;
        i := e;
        while (i > 0) do begin
            if (cur_buff[i] = ' ') then begin
                s := i;
                break;
                end
            else
                dec(i);
            end;

        if (s > 0) then with MsgOut do begin
            SelStart := s;
            SelLength := (e - s);
            SelText := '';
            Key := 0;
            end;
        end;
end;

{---------------------------------------}
procedure TfrmChat.btnHistoryClick(Sender: TObject);
begin
  inherited;
    ShowLog(_jid.jid);
end;

{---------------------------------------}
procedure TfrmChat.btnProfileClick(Sender: TObject);
begin
  inherited;
    ShowProfile(_jid.jid);
end;

{---------------------------------------}
procedure TfrmChat.btnAddRosterClick(Sender: TObject);
var
    ritem: TJabberRosterItem;
    add: TfrmAdd;
begin
  inherited;
    // check to see if we're already subscribed...
    ritem := MainSession.roster.find(_jid.jid);
    if ((ritem <> nil) and ((ritem.subscription = 'both') or (ritem.subscription = 'to'))) then begin
        MessageDlg('You are already subscribed to this contact', mtInformation,
            [mbOK], 0);
        exit;
        end
    else begin
        add := ShowAddContact();
        add.txtJID.Text := _jid.jid;
        add.txtNickname.Text := _jid.user;
        end;

end;

{---------------------------------------}
procedure TfrmChat.MsgListURLClick(Sender: TObject; url: String);
begin
  inherited;
    ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOWNORMAL);
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
end;

{---------------------------------------}
procedure TfrmChat.mnuSendFileClick(Sender: TObject);
begin
  inherited;
    FileSend(_jid.full);
end;

{---------------------------------------}
procedure TfrmChat.imgStatusPaint(Sender: TObject);
begin
  inherited;
    // repaint
    frmRosterWindow.ImageList1.Draw(imgStatus.Canvas, 1, 1, _pres_img);
end;

{---------------------------------------}
procedure TfrmChat.ResetPresImage;
begin
    timFlash.Enabled := false;
    _pres_img := _old_img;
    imgStatus.Repaint();
end;

{---------------------------------------}
procedure TfrmChat.timFlashTimer(Sender: TObject);
begin
  inherited;
    // Flash the presence image for 30 seconds..
    inc(_flash_ticks);
    if (_cur_img = _old_img) then
        _cur_img := ico_Chat
    else
        _cur_img := _old_img;

    _pres_img := _cur_img;
    imgStatus.Repaint();

    if (_flash_ticks >= 60) then resetPresImage();
end;

{---------------------------------------}
procedure TfrmChat.MsgOutChange(Sender: TObject);
var
    c: TXMLTag;
begin
  inherited;
    if (_send_composing) then begin
        _send_composing := false;
        c := TXMLTag.Create('message');
        with c do begin
            PutAttribute('to', jid);
            with AddTag('x') do begin
                PutAttribute('xmlns', XMLNS_MSGEVENTS);
                AddTag('composing');
                AddBasicTag('id', _reply_id);
                end;
            end;
        MainSession.SendTag(c);
        end;
end;

{---------------------------------------}
procedure TfrmChat.Emoticons1Click(Sender: TObject);
var
    l, t: integer;
    cp: TPoint;
begin
  inherited;
    // Show the emoticons form
    GetCaretPos(cp);
    l := MsgOut.ClientOrigin.x + cp.X;

    if (Self.Docked) then begin
        t := frmJabber.Top + frmJabber.ClientHeight - 10;
        frmEmoticons.Left := l + 10;
        end
    else begin
        t := Self.Top + Self.ClientHeight - 10;
        frmEmoticons.Left := l + 10;
        end;

    if ((t + frmEmoticons.Height) > Screen.Height) then
        t := Screen.Height - frmEmoticons.Height;

    frmEmoticons.Top := t;
    frmEmoticons.ChatWindow := Self;
    frmEmoticons.Show;
end;

{---------------------------------------}
procedure TfrmChat.SetEmoticon(msn: boolean; imgIndex: integer);
var
    l, i, m: integer;
    eo: TEmoticon;
begin
    // Setup some Emoticon
    m := -1;

    if (emoticon_list.Count = 0) then
        ConfigEmoticons();

    for i := 0 to emoticon_list.Count - 1 do begin
        eo := TEmoticon(emoticon_list.Objects[i]);
        if (((msn) and (eo.il = frmJabber.imgMSNEmoticons)) or
        ((not msn) and (eo.il = frmJabber.imgYahooEmoticons))) then begin
            // the image lists match
            if (eo.idx = imgIndex) then begin
                m := i;
                break;
                end;
            end;
        end;

    if (m >= 0) then begin
        l := length(MsgOut.Text);
        if ((l > 0) and ((MsgOut.Text[l]) <> ' ')) then
            MsgOut.SelText := ' ';
        MsgOut.SelText := emoticon_list[m];
        end;
end;

end.

