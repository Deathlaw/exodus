unit RemoveContact;
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
    Unicode, 
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
    buttonFrame, StdCtrls, ExtCtrls, TntStdCtrls;

type
  TfrmRemove = class(TForm)
    frameButtons1: TframeButtons;
    Bevel1: TBevel;
    optMove: TTntRadioButton;
    optRemove: TTntRadioButton;
    chkRemove1: TTntCheckBox;
    chkRemove2: TTntCheckBox;
    lblJID: TTntStaticText;
    procedure frameButtons1btnOKClick(Sender: TObject);
    procedure frameButtons1btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure optRemoveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    jid: Widestring;
    sel_grp: Widestring;
  public
    { Public declarations }
  end;

var
  frmRemove: TfrmRemove;

resourcestring
    sRemoveGrpLabel = 'Remove this contact from the %s group.';

procedure RemoveRosterItem(sjid: Widestring; grp: Widestring = '');
procedure QuietRemoveRosterItem(sjid: Widestring);

implementation
uses
    GnuGetText, ExUtils, JabberConst, S10n, Roster, Session, XMLTag;
{$R *.DFM}

procedure RemoveRosterItem(sjid: Widestring; grp: Widestring);
var
    f: TfrmRemove;
    ritem: TJabberRosterItem;
begin
    f := TfrmRemove.Create(Application);
    with f do begin
        lblJID.Caption := sjid;
        sel_grp := grp;
        jid := sjid;
        optMove.Caption := Format(sRemoveGrpLabel, [grp]);
        ritem := MainSession.Roster.Find(sjid);
        optMove.Enabled := ((ritem <> nil) and (ritem.Groups.Count > 1));
        Show;
    end;
end;

procedure QuietRemoveRosterItem(sjid: Widestring);
var
    iq: TXMLTag;
begin
    // just send an iq-remove
    iq := TXMLTag.Create('iq');
    with iq do begin
        setAttribute('type', 'set');
        setAttribute('id', MainSession.generateID);
        with AddTag('query') do begin
            setAttribute('xmlns', XMLNS_ROSTER);
            with AddTag('item') do begin
                setAttribute('jid', sjid);
                setAttribute('subscription', 'remove');
            end;
        end;
    end;
    MainSession.SendTag(iq);
end;

procedure TfrmRemove.frameButtons1btnOKClick(Sender: TObject);
var
    idx: integer;
    iq: TXMLTag;
    ritem: TJabberRosterItem;
begin
    // Handle removing from a single grp
    if (optMove.Checked) then begin
        ritem := MainSession.roster.Find(jid);
        if (ritem <> nil) then begin
            idx := ritem.Groups.IndexOf(sel_grp);
            if (idx >= 0) then
                ritem.Groups.Delete(idx);
            ritem.update();
        end;
    end

    // Really remove or unsub
    else if ((chkRemove1.Checked) and (chkRemove2.Checked)) then begin
        // send a subscription='remove'
        iq := TXMLTag.Create('iq');
        with iq do begin
            setAttribute('type', 'set');
            setAttribute('id', MainSession.generateID);
            with AddTag('query') do begin
                setAttribute('xmlns', XMLNS_ROSTER);
                with AddTag('item') do begin
                    setAttribute('jid', jid);
                    setAttribute('subscription', 'remove');
                end;
            end;
        end;
        MainSession.SendTag(iq);
    end
    else if chkRemove1.Checked then begin
        // send an unsubscribe
        SendUnSubscribe(lblJID.Caption, MainSession);
    end
    else if chkRemove2.Checked then begin
        // send an unsubscribed
        SendUnSubscribed(lblJID.Caption, MainSession);
    end;
    Self.Close;
end;

procedure TfrmRemove.frameButtons1btnCancelClick(Sender: TObject);
begin
    Self.Close;
end;

procedure TfrmRemove.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TfrmRemove.optRemoveClick(Sender: TObject);
begin
    chkRemove1.Enabled := optRemove.Checked;
    chkRemove2.Enabled := optRemove.Checked;
end;

procedure TfrmRemove.FormCreate(Sender: TObject);
begin
    AssignUnicodeFont(Self);
    TranslateProperties(Self);
end;

end.
