unit PrefMsg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PrefPanel, StdCtrls;

type
  TfrmPrefMsg = class(TfrmPrefPanel)
    Label19: TLabel;
    Label7: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    chkEmoticons: TCheckBox;
    chkTimestamp: TCheckBox;
    chkLog: TCheckBox;
    txtLogPath: TEdit;
    StaticText11: TStaticText;
    txtTimestampFmt: TEdit;
    btnLogBrowse: TButton;
    chkMsgQueue: TCheckBox;
    chkLogRooms: TCheckBox;
    cboMsgOptions: TComboBox;
    btnLogClearAll: TButton;
    chkCloseQueue: TCheckBox;
    txtSpoolPath: TEdit;
    btnSpoolBrowse: TButton;
    cboInviteOptions: TComboBox;
    chkBlockNonRoster: TCheckBox;
    OpenDialog1: TOpenDialog;
    procedure btnLogBrowseClick(Sender: TObject);
    procedure btnLogClearAllClick(Sender: TObject);
    procedure btnSpoolBrowseClick(Sender: TObject);
    procedure chkLogClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadPrefs(); override;
    procedure SavePrefs(); override;
  end;

var
  frmPrefMsg: TfrmPrefMsg;

resourcestring
    sPrefsLogDir = 'Select log directory';

implementation
{$WARN UNIT_PLATFORM OFF}
{$R *.dfm}
uses
    ExUtils, FileCtrl, Session;

procedure TfrmPrefMsg.LoadPrefs();
begin
    with MainSession.Prefs do begin
        // Message Options
        chkTimestamp.Checked := getBool('timestamp');
        txtTimestampFmt.Text := getString('timestamp_format');
        chkMsgQueue.Checked := getBool('msg_queue');
        chkCloseQueue.Checked := getBool('close_queue');
        chkEmoticons.Checked := getBool('emoticons');
        chkBlockNonRoster.Checked := getBool('block_nonroster');
        chkLog.Checked := getBool('log');
        chkLogRooms.Checked := getBool('log_rooms');
        txtLogPath.Text := getString('log_path');
        txtSpoolPath.Text := getString('spool_path');
        cboInviteOptions.ItemIndex := getInt('invite_treatment');
        cboMsgOptions.ItemIndex := getInt('msg_treatment');
        self.chkLogClick(nil);
    end;
end;

procedure TfrmPrefMsg.SavePrefs();
begin
    with MainSession.Prefs do begin
        // Message Prefs
        setBool('timestamp', chkTimestamp.Checked);
        setString('timestamp_format', txtTimestampFmt.Text);
        setBool('emoticons', chkEmoticons.Checked);
        setBool('block_nonroster', chkBlockNonRoster.Checked);
        setBool('msg_queue', chkMsgQueue.Checked);
        setBool('close_queue', chkCloseQueue.Checked);
        setBool('log', chkLog.Checked);
        setBool('log_rooms', chkLogRooms.Checked);
        setString('log_path', txtLogPath.Text);
        setString('spool_path', txtSpoolPath.Text);
        setInt('invite_treatment', cboInviteOptions.ItemIndex);
        setInt('msg_treatment', cboMsgOptions.ItemIndex);
    end;
end;


procedure TfrmPrefMsg.btnLogBrowseClick(Sender: TObject);
var
    tmps: string;
begin
    tmps := txtLogPath.Text;
    if SelectDirectory(sPrefsLogDir, '', tmps) then
        txtLogPath.Text := tmps;
end;

procedure TfrmPrefMsg.btnLogClearAllClick(Sender: TObject);
begin
  inherited;
    ClearAllLogs();
end;

procedure TfrmPrefMsg.btnSpoolBrowseClick(Sender: TObject);
begin
    OpenDialog1.FileName := txtSpoolPath.Text;
    if (OpenDialog1.Execute) then
        txtSpoolPath.Text := OpenDialog1.FileName;
end;

procedure TfrmPrefMsg.chkLogClick(Sender: TObject);
begin
  inherited;
    chkLogRooms.Enabled := chkLog.Checked;
    txtLogPath.Enabled := chkLog.Checked;
    btnLogBrowse.Enabled := chkLog.Checked;
end;

end.
