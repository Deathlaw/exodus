unit ConnDetails;
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
    PrefController,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, buttonFrame, ComCtrls, StdCtrls, ExtCtrls, TntStdCtrls,
    TntComCtrls, TntExtCtrls;

type
  TfrmConnDetails = class(TForm)
    frameButtons1: TframeButtons;
    PageControl1: TTntPageControl;
    tbsSocket: TTntTabSheet;
    tbsHttp: TTntTabSheet;
    Label1: TTntLabel;
    txtURL: TTntEdit;
    txtTime: TTntEdit;
    Label2: TTntLabel;
    Label5: TTntLabel;
    txtKeys: TTntEdit;
    Label9: TTntLabel;
    tbsProfile: TTntTabSheet;
    lblSocksHost: TTntLabel;
    lblSocksPort: TTntLabel;
    lblSocksType: TTntLabel;
    lblSocksUsername: TTntLabel;
    lblSocksPassword: TTntLabel;
    chkSocksAuth: TTntCheckBox;
    txtSocksHost: TTntEdit;
    txtSocksPort: TTntEdit;
    txtSocksUsername: TTntEdit;
    txtSocksPassword: TTntEdit;
    cboJabberID: TTntComboBox;
    chkSavePasswd: TTntCheckBox;
    txtPassword: TTntEdit;
    cboResource: TTntComboBox;
    tbsConn: TTntTabSheet;
    lblNote: TTntLabel;
    lblUsername: TTntLabel;
    Label10: TTntLabel;
    Label12: TTntLabel;
    lblServerList: TTntLabel;
    Label13: TTntLabel;
    chkRegister: TTntCheckBox;
    OpenDialog1: TOpenDialog;
    tbsSSL: TTntTabSheet;
    TntLabel1: TTntLabel;
    txtSSLCert: TTntEdit;
    btnCertBrowse: TTntButton;
    optSSL: TTntRadioGroup;
    cboSocksType: TTntComboBox;
    Label6: TTntLabel;
    txtPriority: TTntEdit;
    spnPriority: TUpDown;
    chkSRV: TTntCheckBox;
    boxHost: TTntGroupBox;
    Label4: TTntLabel;
    Label7: TTntLabel;
    txtHost: TTntEdit;
    txtPort: TTntEdit;
    chkPolling: TTntCheckBox;
    procedure frameButtons1btnOKClick(Sender: TObject);
    procedure chkSocksAuthClick(Sender: TObject);
    procedure cboSocksTypeChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure txtUsernameKeyPress(Sender: TObject; var Key: Char);
    procedure lblServerListClick(Sender: TObject);
    procedure btnCertBrowseClick(Sender: TObject);
    procedure optSSLClick(Sender: TObject);
    procedure chkSRVClick(Sender: TObject);
    procedure txtUsernameExit(Sender: TObject);
  private
    { Private declarations }
    _profile: TJabberProfile;

    procedure RestoreSocket(profile: TJabberProfile);
    procedure SaveSocket(profile: TJabberProfile);
    procedure RestoreHttp(profile: TJabberProfile);
    procedure SaveHttp(profile: TJabberProfile);
    procedure RestoreProfile(profile: TJabberProfile);
    procedure SaveProfile(profile: TJabberProfile);
    procedure RestoreConn(profile: TJabberProfile);
    procedure SaveConn(profile: TJabberProfile);


  public
    { Public declarations }
  end;

var
  frmConnDetails: TfrmConnDetails;

function ShowConnDetails(p: TJabberProfile): integer;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

{$R *.dfm}

uses
    ExSession, Stringprep, 
    JabberUtils, ExUtils,  GnuGetText, JabberID, Unicode, Session, WebGet, XMLTag, XMLParser,
    Registry;

const
    sSmallKeys = 'Must have a larger number of poll keys.';
    sConnDetails = '%s Details';
    sProfileInvalidJid = 'The Jabber ID you entered (username@server/resource) is invalid. Please enter a valid username, server, and resource.';
    sResourceWork = 'Work';
    sResourceHome = 'Home';
    sDownloadServers = 'Download the public server list from jabber.org? (Requires an internet connection).';
    sDownloadCaption = 'Downloading public server list';
    sNoSSL = 'This profile is currently to use SSL, however, your system does not have the required libraries to use SSL. Turning SSL OFF.';

{---------------------------------------}
function ShowConnDetails(p: TJabberProfile): integer;
var
    f: TfrmConnDetails;
begin
    //
    f := TfrmConnDetails.Create(nil);

    with f do begin
        _profile := p;
        f.Caption := WideFormat(_(sConnDetails), [p.Name]);
        RestoreProfile(p);
        RestoreConn(p);
        RestoreHttp(p);
        RestoreSocket(p);
        PageControl1.ActivePage := tbsProfile;
    end;

    result := f.ShowModal();
    f.Free();
end;

{---------------------------------------}
procedure TfrmConnDetails.frameButtons1btnOKClick(Sender: TObject);
var
    valid: boolean;
    jid: Widestring;
begin
    // Validate the JID..
    jid := cboJabberID.Text + '/' + cboResource.Text;
    valid := (Pos('@', jid) > 0);
    if (valid) then
        valid := isValidJid(jid);

    if (valid = false) then begin
        MessageDlgW(_(sProfileInvalidJid), mtError, [mbOK], 0);
        exit;
    end;

    // save the info...
    SaveProfile(_profile);
    SaveConn(_profile);

    if _profile.ConnectionType = conn_normal then
        SaveSocket(_profile)
    else
        SaveHttp(_profile);

    MainSession.Prefs.SaveProfiles();
    ModalResult := mrOK;
end;

{---------------------------------------}
procedure TfrmConnDetails.chkSocksAuthClick(Sender: TObject);
begin
    if (chkSocksAuth.Checked) then begin
        lblSocksUsername.Enabled := true;
        lblSocksPassword.Enabled := true;
        txtSocksUsername.Enabled := true;
        txtSocksPassword.Enabled := true;
    end
    else begin
        lblSocksUsername.Enabled := false;
        lblSocksPassword.Enabled := false;
        txtSocksUsername.Enabled := false;
        txtSocksPassword.Enabled := false;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.cboSocksTypeChange(Sender: TObject);
begin
    if (cboSocksType.ItemIndex = proxy_none) or
       (cboSocksType.ItemIndex = proxy_http) then begin
        txtSocksHost.Enabled := false;
        txtSocksPort.Enabled := false;
        txtSocksUsername.Enabled := false;
        txtSocksPassword.Enabled := false;
        chkSocksAuth.Enabled := false;
        chkSocksAuth.Checked := false;
        lblSocksHost.Enabled := false;
        lblSocksPort.Enabled := false;
        lblSocksUsername.Enabled := false;
        lblSocksPassword.Enabled := false;
    end
    else begin
        if (not txtSocksHost.Enabled) then begin
            txtSocksHost.Enabled := true;
            txtSocksPort.Enabled := true;
            chkSocksAuth.Enabled := true;
            lblSocksHost.Enabled := true;
            lblSocksPort.Enabled := true;
        end;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.RestoreSocket(profile: TJabberProfile);
begin
    with profile do begin
        cboSocksType.ItemIndex := SocksType;
        cboSocksTypeChange(cboSocksType);
        txtSocksHost.Text := SocksHost;
        txtSocksPort.Text := IntToStr(SocksPort);
        chkSocksAuth.Checked := SocksAuth;
        chkSocksAuthClick(chkSocksAuth);
        txtSocksUsername.Text := SocksUsername;
        txtSocksPassword.Text := SocksPassword;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.SaveSocket(profile: TJabberProfile);
begin
    with profile do begin
        Host := txtHost.Text;
        Port := StrToIntDef(txtPort.Text, 5222);
        ssl := optSSL.ItemIndex;

        SocksType := cboSocksType.ItemIndex;
        SocksHost := txtSocksHost.Text;
        SocksPort := StrToIntDef(txtSocksPort.Text, 0);
        SocksAuth := chkSocksAuth.Checked;
        SocksUsername := txtSocksUsername.Text;
        SocksPassword := txtSocksPassword.Text;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.RestoreProfile(profile: TJabberProfile);
begin
    with profile do begin
        // populate the fields
        cboJabberID.Text := Username + '@' + Server;
        cboResource.Text := Resource;
        txtPassword.Text := Password;
        chkSavePasswd.Checked := SavePasswd;
        chkRegister.Checked := NewAccount;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.SaveProfile(profile: TJabberProfile);
var
    jid: TJabberID;
begin
    with Profile do begin
        // Update the profile
        jid := TJabberID.Create(cboJabberID.Text);
        Server := jid.domain;
        Username := jid.user;
        SavePasswd := chkSavePasswd.Checked;
        password := txtPassword.Text;
        resource := cboResource.Text;
        NewAccount := chkRegister.Checked;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.RestoreConn(profile: TJabberProfile);
begin
    with profile do begin
        txtHost.Text := Host;
        txtPort.Text := IntToStr(Port);
        if ((ExStartup.ssl_ok = false) and (ssl = ssl_port)) then begin
            MessageDlgW(_(sNoSSL), mtError, [mbOK], 0);
            ssl := ssl_tls;
        end;
        optSSL.ItemIndex := ssl;
        chkPolling.Checked := (ConnectionType = conn_http);
        spnPriority.Position := Priority;
        txtSSLCert.Text := SSL_Cert;
        chkSRV.Checked := srv;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.SaveConn(profile: TJabberProfile);
begin
    with profile do begin
        srv := chkSRV.Checked;
        Host := txtHost.Text;
        Port := StrToIntDef(txtPort.Text, 5222);
        ssl := optSSL.ItemIndex;
        if (chkPolling.Checked) then
            ConnectionType := conn_http
        else
            ConnectionType := conn_normal;
        Priority := spnPriority.Position;
        SSL_Cert := txtSSLCert.Text;
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.RestoreHttp(profile: TJabberProfile);
begin
    with profile do begin
        txtURL.Text := URL;
        txtTime.Text := FloatToStr(Poll / 1000.0);
        txtKeys.Text := IntToStr(NumPollKeys);
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.SaveHttp(profile: TJabberProfile);
begin
    with profile do begin
        URL := txtURL.Text;
        Poll := Trunc(strToFloatDef(txtTime.Text, 30) * 1000);
        NumPollKeys := StrToInt(txtKeys.Text);
        if (NumPollKeys < 2) then begin
            NumPollKeys := 256;
            txtKeys.Text := '256';
            MessageDlgW(_(sSmallKeys), mtWarning, [mbOK], 0);
        end;
        
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.FormCreate(Sender: TObject);
var
    list : TWideStrings;
    i : integer;
begin
    AssignUnicodeFont(Self, 8);
    TranslateComponent(Self);

    URLLabel(lblServerList);
    MainSession.Prefs.RestorePosition(Self);

    list := TWideStringList.Create();
    MainSession.Prefs.fillStringList('brand_profile_server_list', list);
    if (list.Count > 0) then begin
        cboJabberID.Items.Clear();
        for i := 0 to list.Count - 1 do
            cboJabberID.Items.Add('@' + list[i]);
    end;
    MainSession.Prefs.fillStringList('brand_profile_resource_list', list);
    if (list.Count > 0) then begin
        cboResource.Clear();
        for i := 0 to list.Count - 1 do
            cboResource.Items.Add(list[i]);
    end
    else begin
        cboResource.Items.Add(_(sResourceHome));
        cboResource.Items.Add(_(sResourceWork));
        cboResource.Items.Add(_('Exodus'));
    end;
    list.Free();

    if (not ExStartup.ssl_ok) then
        ExStartup.ssl_ok := checkSSL();

    tbsSSL.TabVisible := ExStartup.ssl_ok;
    if (not tbsSSL.TabVisible) then
        optSSL.ItemIndex := ssl_tls;
end;

{---------------------------------------}
procedure TfrmConnDetails.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    MainSession.Prefs.SavePosition(Self);
    Action := caFree;
end;

{---------------------------------------}
procedure TfrmConnDetails.txtUsernameKeyPress(Sender: TObject;
  var Key: Char);
var
    uh, r, jid: Widestring;
begin
    // alway allow people to fix mistakes :)
    if (Key = #8) then exit;

    // check to make sure JID is valid
    uh := cboJabberID.Text;
    r := cboResource.Text;

    if (Sender = cboJabberID) then uh := uh + Key
    else if (Sender = cboResource) then r := r + Key;

    jid := uh + '/' + r;
    if (not isValidJid(jid)) then
        Key := #0;
end;

{---------------------------------------}
procedure TfrmConnDetails.lblServerListClick(Sender: TObject);
var
    slist: string;
    parser: TXMLTagParser;
    q: TXMLTag;
    items: TXMLTagList;
    i: integer;
begin
    if (MessageDlgW(_(sDownloadServers), mtConfirmation, [mbYes, mbNo], 0) = mrNo) then
        exit;

    frameButtons1.btnOK.Enabled := false;

    slist := ExWebDownload(_(sDownloadCaption), 'http://jabber.org/servers.xml');

    frameButtons1.btnOK.Enabled := true;

    if (slist = '') then exit;

    parser := TXMLTagParser.Create();
    parser.ParseString(slist, '');
    if (parser.Count > 0) then begin
        q := parser.popTag();
        items := q.QueryTags('item');
        if (items.Count > 0) then
            cboJabberID.Items.Clear();
        for i := 0 to items.Count - 1 do
            cboJabberID.Items.Add(items[i].getAttribute('jid'));
        items.Free();
        q.Free();
    end;
    parser.Free();
end;

{---------------------------------------}
procedure TfrmConnDetails.btnCertBrowseClick(Sender: TObject);
begin
    if (OpenDialog1.Execute()) then
        txtSSLCert.Text := OpenDialog1.FileName;
end;

{---------------------------------------}
procedure TfrmConnDetails.optSSLClick(Sender: TObject);
begin
    if (optSSL.ItemIndex = ssl_port) then begin
        if (txtPort.Text = '5222') then
            txtPort.Text := '5223';
    end
    else begin
        if (txtPort.Text = '5223') then
            txtPort.Text := '5222';
    end;
end;

{---------------------------------------}
procedure TfrmConnDetails.chkSRVClick(Sender: TObject);
begin
    boxHost.Enabled := not chkSRV.Checked;
    txtHost.Enabled := boxHost.Enabled;
    txtPort.Enabled := boxHost.Enabled;
end;

{---------------------------------------}
procedure TfrmConnDetails.txtUsernameExit(Sender: TObject);
var
    jid: TJabberID;
    inp, outp: Widestring;
begin
    // stringprep txtUsername, cboServer, or cboResource.
    if (Sender = cboJabberID) then begin
        jid := TJabberID.Create(cboJabberID.Text);
        if (not jid.isValid) then
            MessageDlgW(_('The Jabber ID you entered is not allowed.'), mtError, [mbOK], 0)
        else
            cboJabberID.Text := jid.jid;
        jid.Free();
    end
    else if (Sender = cboResource) then begin
        inp := cboResource.Text;
        outp := xmpp_resourceprep(inp);
        if (outp = '') then
            MessageDlgW(_('The resource you entered is not allowed.'), mtError, [mbOK], 0)
        else
            cboResource.Text := outp;
    end;
end;

end.
