unit PrefRoster;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PrefPanel, StdCtrls, TntStdCtrls, ExtCtrls;

type
  TfrmPrefRoster = class(TfrmPrefPanel)
    Label18: TLabel;
    Label21: TLabel;
    chkOnlineOnly: TCheckBox;
    StaticText1: TStaticText;
    chkShowUnsubs: TCheckBox;
    chkOfflineGroup: TCheckBox;
    chkInlineStatus: TCheckBox;
    cboInlineStatus: TColorBox;
    chkHideBlocked: TCheckBox;
    chkPresErrors: TCheckBox;
    chkShowPending: TCheckBox;
    chkMessenger: TCheckBox;
    txtGatewayGrp: TTntEdit;
    cboDblClick: TComboBox;
    chkRosterUnicode: TCheckBox;
    chkCollapsed: TCheckBox;
    chkGroupCounts: TCheckBox;
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
    Session;

procedure TfrmPrefRoster.LoadPrefs();
begin
    //
    with MainSession.Prefs do begin
        // Roster Prefs
        chkOnlineOnly.Checked := getBool('roster_only_online');
        chkShowUnsubs.Checked := getBool('roster_show_unsub');
        chkShowPending.Checked := getBool('roster_show_pending');
        chkOfflineGroup.Checked := getBool('roster_offline_group');
        chkInlineStatus.Checked := getBool('inline_status');
        cboInlineStatus.Selected := TColor(getInt('inline_color'));
        cboInlineStatus.Enabled := chkInlineStatus.Checked;
        chkHideBlocked.Checked := getBool('roster_hide_block');
        chkPresErrors.Checked := getBool('roster_pres_errors');
        chkMessenger.Checked := getBool('roster_messenger');
        chkRosterUnicode.Checked := getBool('roster_unicode');
        chkCollapsed.Checked := getBool('roster_collapsed');
        chkGroupCounts.Checked := getBool('roster_groupcounts');
        cboDblClick.ItemIndex := getInt('roster_chat');
        txtGatewayGrp.Text := getString('roster_transport_grp');
    end;    
end;

procedure TfrmPrefRoster.SavePrefs();
begin
    //
    with MainSession.Prefs do begin
        // Roster prefs
        setBool('roster_only_online', chkOnlineOnly.Checked);
        setBool('roster_show_unsub', chkShowUnsubs.Checked);
        setBool('roster_show_pending', chkShowPending.Checked);
        setBool('roster_offline_group', chkOfflineGroup.Checked);
        setBool('roster_hide_block', chkHideBlocked.Checked);
        setBool('inline_status', chkInlineStatus.Checked);
        setInt('inline_color', integer(cboInlineStatus.Selected));
        setInt('roster_chat', cboDblClick.ItemIndex);
        setBool('roster_pres_errors', chkPresErrors.Checked);
        setBool('roster_messenger', chkMessenger.Checked);
        setBool('roster_unicode', chkRosterUnicode.Checked);
        setBool('roster_collapsed', chkCollapsed.Checked);
        setBool('roster_groupcounts', chkGroupCounts.Checked);
        setString('roster_transport_grp', txtGatewayGrp.Text);
    end;
end;

procedure TfrmPrefRoster.chkInlineStatusClick(Sender: TObject);
begin
  inherited;
    // toggle the color drop down on/off
    cboInlineStatus.Enabled := chkInlineStatus.Checked;
end;

end.
