unit JoinRoom;
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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  buttonFrame, StdCtrls;

type
  TfrmJoinRoom = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtRoom: TEdit;
    txtNick: TEdit;
    frameButtons1: TframeButtons;
    txtServer: TComboBox;
    txtPassword: TEdit;
    lblPassword: TLabel;
    procedure frameButtons1btnOKClick(Sender: TObject);
    procedure frameButtons1btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmJoinRoom: TfrmJoinRoom;

procedure StartJoinRoom;

resourcestring
    sInvalidNick = 'You must enter a nickname';

implementation
uses
    Jabber1, 
    JabberID, 
    Agents,
    Session,
    Room;
{$R *.DFM}

procedure StartJoinRoom;
var
    f: TfrmJoinRoom;
    i: integer;
    agents: TAgents;
    a: TAgentItem;
begin
    f := TfrmJoinRoom.Create(Application);
    with f do begin
        txtRoom.Text := MainSession.Prefs.getString('tc_lastroom');
        txtServer.Text := MainSession.Prefs.getString('tc_lastserver');
        txtNick.Text := MainSession.Prefs.getString('tc_lastnick');
        if (txtNick.Text = '') then
            txtNick.Text := MainSession.Username;

        with txtServer do begin
            Items.Clear;
            agents := MainSession.MyAgents;
            for i := 0 to agents.Count -1 do begin
                a := agents.getAgent(i);
                if (a.groupchat) then
                    Items.Add(a.jid);
                end;
            end;
        Show;
        end;
end;

procedure TfrmJoinRoom.frameButtons1btnOKClick(Sender: TObject);
var
    pass: Widestring;
    rjid: string;
begin
    // join this room
    rjid := txtRoom.Text + '@' + txtServer.Text;
    if (not isValidJid(rjid)) then begin
        MessageDlg(sInvalidRoomJID, mtError, [mbOK], 0);
        exit;
        end;

    if (txtNick.Text = '') then begin
        MessageDlg(sInvalidNick, mtError, [mbOK], 0);
        exit;
        end;

    pass := Trim(txtPassword.Text);
    StartRoom(rjid, txtNick.Text, pass);

    with MainSession.Prefs do begin
        setString('tc_lastroom', txtRoom.Text);
        setString('tc_lastserver', txtServer.Text);
        setString('tc_lastnick', txtNick.Text);
        end;

    Self.Close;
end;

procedure TfrmJoinRoom.frameButtons1btnCancelClick(Sender: TObject);
begin
    Self.Close;
end;

procedure TfrmJoinRoom.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

end.
