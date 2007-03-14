unit Notify;
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
    JabberID,
    Presence,
    Dockable,
    Windows, Forms, Contnrs, SysUtils, classes;

type
    TNotifyController = class
    private
        _session: TObject;
        _presCallback: longint;
    published
        procedure Callback (event: string; tag: TXMLTag);
        procedure PresCallback(event: string; tag: TXMLTag; p: TJabberPres);
    public
        constructor Create;
        destructor Destroy; override;
        procedure SetSession(js: TObject);
end;

procedure DoNotify(win: TForm; notify: integer; msg: Widestring; icon: integer;
    sound_name: string); overload;
procedure DoNotify(win: TForm; pref_name: string; msg: Widestring; icon: integer); overload;

implementation
uses
    BaseChat, ExUtils, ExEvents, GnuGetText,
    Jabber1, PrefController, RiserWindow,
    Room, NodeItem, Roster, MMSystem, Debug, Session;

const
    sNotifyOnline = ' is now online.';
    sNotifyOffline = ' is now offline.';

const
    // image index for tab notification.
    tab_notify = 9;

{---------------------------------------}
constructor TNotifyController.Create;
begin
    //
    inherited;
end;

{---------------------------------------}
destructor TNotifyController.Destroy;
begin
    inherited Destroy;
end;

{---------------------------------------}
procedure TNotifyController.SetSession(js: TObject);
begin
    // Store a reference to the session object
    _session := js;
    with TJabberSession(_session) do begin
        _presCallback := RegisterCallback(PresCallback);
    end;
end;

{---------------------------------------}
procedure TNotifyController.PresCallback(event: string; tag: TXMLTag; p: TJabberPres);
begin
    // getting a pres event
    Callback(event, tag);
end;

{---------------------------------------}
procedure TNotifyController.Callback(event: string; tag: TXMLTag);
var
    sess: TJabberSession;
    nick, j, from: Widestring;
    ritem: TJabberRosterItem;
    tmp_jid: TJabberID;
begin
    // we are getting some event to do notification on

    // DebugMsg('Notify Callback: ' + BoolToStr(MainSession.IsPaused, true));
    if MainSession.IsPaused then begin
        MainSession.QueueEvent(event, tag, Self.Callback);
        exit;
    end;

    sess := TJabberSession(_session);
    from := tag.GetAttribute('from');
    tmp_jid := TJabberID.Create(from);
    j := tmp_jid.jid;
    if (sess.IsBlocked(j)) then exit;
    
    ritem := sess.roster.Find(j);
    if ritem <> nil then
        nick := ritem.nickname
    else if (tmp_jid.user <> '') then
        nick := tmp_jid.user
    else
        nick := tmp_jid.jid;

    tmp_jid.Free();

    // don't display notifications for rooms, here.
    if (IsRoom(j)) then exit;

    // someone is coming online for the first time..
    if (event = '/presence/online') then
        DoNotify(nil, 'notify_online', nick + _(sNotifyOnline), ico_Online)

    // someone is going offline
    else if (event = '/presence/offline') then
        DoNotify(nil, 'notify_offline', nick + _(sNotifyOffline), ico_Offline)

    // don't display normal presence changes
    else if ((event = '/presence/available') or (event = '/presence/error')) then
        // do nothing

    // unkown.
    else
        DebugMessage('Unknown notify event: ' + event);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure DoNotify(win: TForm; notify: integer; msg: Widestring; icon: integer;
    sound_name: string);
var
    w, tw: TForm;
    d: TfrmDockable;
    active_win: HWND;
begin
    if ((Application.Active and (not MainSession.prefs.getBool('notify_active'))) or
        (MainSession.IsPaused)) then exit;

    if (win = nil) then
        w := frmExodus
    else
        w := win;

    // Get the appropriate active form
    tw := nil;
    if (w = frmExodus) then
        tw := frmExodus.getTabForm(frmExodus.Tabs.ActivePage)
    else if (w is TfrmDockable) then begin
        if TfrmDockable(w).Docked then
            tw := frmExodus.getTabForm(frmExodus.Tabs.ActivePage);
    end;
    active_win := getActiveWindow();
    if (active_win = frmExodus.Handle) and (tw <> nil) then
        active_win := tw.Handle;

    // if we are not notifying for the active window,
    // and this is active, bail.
    if ((not MainSession.prefs.getBool('notify_active_win')) and (w.Handle = active_win)) then
        exit;

    if ((notify and notify_tray) > 0) then
        // Flash the tray icon
        StartTrayAlert();

    if ((notify and notify_toast) > 0) then
        // Show toast
        ShowRiserWindow(w, msg, icon);

    if ((notify and notify_flash) > 0) then begin
        // flash or show img
        if (w = frmExodus) then begin
            // The window is the main window
            if frmExodus.Tabs.ActivePage <> frmExodus.tbsRoster then
                frmExodus.tbsRoster.ImageIndex := tab_notify;
            if ((active_win <> frmExodus.Handle) and (not Application.Active)) then
                frmExodus.Flash();
        end
        else if (w is TfrmDockable) then begin
            // it's a dockable window
            d := TfrmDockable(w);
            if d.Docked then begin
                if frmExodus.Tabs.ActivePage <> d.TabSheet then begin
                    d.TabSheet.ImageIndex := tab_notify;
                    frmExodus.Tabs.Repaint();
                end;
                if ((active_win <> frmExodus.Handle) and (not Application.Active)) then
                    frmExodus.Flash();
            end
            else if (w is TfrmBaseChat) then
                TfrmBaseChat(w).Flash()
            else begin
                FlashWindow(w.Handle, true);
                FlashWindow(w.Handle, true);
            end;
        end
        else begin
            // it's something else
            FlashWindow(w.Handle, true);
            FlashWindow(w.Handle, true);
        end;
    end;

    if ((notify and notify_front) > 0) then begin
        // pop the window to the front
        if (w is TfrmDockable) then begin
            d := TfrmDockable(w);
            if (d.Docked) then begin
                frmExodus.doRestore();
                frmExodus.Tabs.ActivePage := d.TabSheet;
                w := frmExodus;
            end;
        end
        else if (w = frmExodus) then
            frmExodus.doRestore()
        else if ((not w.Visible) or (w.WindowState = wsMinimized))then begin
            w.WindowState := wsNormal;
            w.Visible := true;
        end;
        ShowWindow(w.Handle, SW_SHOWNORMAL);
        ForceForegroundWindow(w.Handle);
    end;

    if (MainSession.prefs.getBool('notify_sounds')) then
        PlaySound(pchar('EXODUS_' + sound_name), 0,
                  SND_APPLICATION or SND_ASYNC or SND_NOWAIT or SND_NODEFAULT);
end;


{---------------------------------------}
procedure DoNotify(win: TForm; pref_name: string; msg: Widestring; icon: integer);
begin
    DoNotify(win, MainSession.Prefs.getInt(pref_name), msg, icon, pref_name);
end;

end.