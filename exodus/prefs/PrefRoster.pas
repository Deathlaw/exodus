unit PrefRoster;
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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PrefPanel, StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls;

type
  TfrmPrefRoster = class(TfrmPrefPanel)
    Label21: TTntLabel;
    chkShowUnsubs: TTntCheckBox;
    chkHideBlocked: TTntCheckBox;
    chkPresErrors: TTntCheckBox;
    chkShowPending: TTntCheckBox;
    cboDblClick: TTntComboBox;
    chkRosterUnicode: TTntCheckBox;
    chkInlineStatus: TTntCheckBox;
    cboInlineStatus: TColorBox;
    StaticText4: TTntPanel;
    TntLabel1: TTntLabel;
    procedure chkInlineStatusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadPrefs(); override;
    procedure SavePrefs(); override;
  end;

var
  frmPrefRoster: TfrmPrefRoster;

implementation
{$R *.dfm}

uses
    ExUtils, Unicode, Session;

procedure TfrmPrefRoster.LoadPrefs();
begin
    //
    with MainSession.Prefs do begin
        // Roster Prefs
        chkShowUnsubs.Checked := getBool('roster_show_unsub');
        chkShowPending.Checked := getBool('roster_show_pending');
        chkHideBlocked.Checked := getBool('roster_hide_block');
        chkPresErrors.Checked := getBool('roster_pres_errors');
        chkRosterUnicode.Checked := getBool('roster_unicode');
        cboDblClick.ItemIndex := getInt('roster_chat');

        chkInlineStatus.Checked := getBool('inline_status');
        cboInlineStatus.Selected := TColor(getInt('inline_color'));
        cboInlineStatus.Enabled := chkInlineStatus.Checked;

    end;
end;

procedure TfrmPrefRoster.SavePrefs();
begin
    //
    with MainSession.Prefs do begin
        // Roster prefs
        setBool('roster_show_unsub', chkShowUnsubs.Checked);
        setBool('roster_show_pending', chkShowPending.Checked);
        setBool('roster_hide_block', chkHideBlocked.Checked);
        setBool('roster_pres_errors', chkPresErrors.Checked);
        setBool('roster_unicode', chkRosterUnicode.Checked);
        setInt('roster_chat', cboDblClick.ItemIndex);

        setBool('inline_status', chkInlineStatus.Checked);
        setInt('inline_color', integer(cboInlineStatus.Selected));

    end;
end;

procedure TfrmPrefRoster.chkInlineStatusClick(Sender: TObject);
begin
  inherited;
    // toggle the color drop down on/off
    cboInlineStatus.Enabled := chkInlineStatus.Checked;
end;

end.
