unit Prefs;
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
    // panels
    PrefPanel, PrefSystem, PrefRoster, PrefSubscription, PrefFont, PrefDialogs,
    PrefMsg, PrefNotify, PrefAway, PrefPresence, PrefPlugins, PrefTransfer,
    PrefNetwork,      

    // other stuff
    Menus, ShellAPI, Unicode,
    Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
    ComCtrls, StdCtrls, ExtCtrls, buttonFrame, CheckLst,
    ExRichEdit, Dialogs, RichEdit2, TntStdCtrls, TntComCtrls;

type
  TfrmPrefs = class(TForm)
    ScrollBox1: TScrollBox;
    imgDialog: TImage;
    lblDialog: TLabel;
    imgFonts: TImage;
    lblFonts: TLabel;
    imgS10n: TImage;
    lblS10n: TLabel;
    imgRoster: TImage;
    lblRoster: TLabel;
    PageControl1: TPageControl;
    ColorDialog1: TColorDialog;
    imgSystem: TImage;
    lblSystem: TLabel;
    imgNotify: TImage;
    lblNotify: TLabel;
    imgAway: TImage;
    lblAway: TLabel;
    tbsKeywords: TTabSheet;
    StaticText8: TStaticText;
    memKeywords: TTntMemo;
    tbsBlockList: TTabSheet;
    StaticText9: TStaticText;
    Label10: TLabel;
    memBlocks: TTntMemo;
    imgKeywords: TImage;
    lblKeywords: TLabel;
    imgBlockList: TImage;
    lblBlockList: TLabel;
    imgCustompres: TImage;
    lblCustomPres: TLabel;
    Panel1: TPanel;
    Panel3: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Button6: TButton;
    Panel2: TPanel;
    Label1: TLabel;
    chkRegex: TCheckBox;
    imgMessages: TImage;
    lblMessages: TLabel;
    imgPlugins: TImage;
    lblPlugins: TLabel;
    imgNetwork: TImage;
    lblNetwork: TLabel;
    imgTransfer: TImage;
    lblTransfer: TLabel;
    Bevel1: TBevel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure TabSelect(Sender: TObject);
    procedure frameButtons1btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    _cur_panel: TfrmPrefPanel;
    _system: TfrmPrefSystem;
    _roster: TfrmPrefRoster;
    _subscription: TfrmPrefSubscription;
    _font: TfrmPrefFont;
    _dialogs: TfrmPrefDialogs;
    _message: TfrmPrefMsg;
    _notify: TfrmPrefNotify;
    _away: TfrmPrefAway;
    _pres: TfrmPrefPresence;
    _plugs: TfrmPrefPlugins;
    _xfer: TfrmPrefTransfer;
    _network: TfrmPrefNetwork;
    
  public
    { Public declarations }
    procedure LoadPrefs;
    procedure SavePrefs;
  end;

var
  frmPrefs: TfrmPrefs;

procedure StartPrefs;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

{$R *.DFM}
{$WARN UNIT_PLATFORM OFF}

uses
    GnuGetText, PrefController, Session;

{---------------------------------------}
procedure StartPrefs;
var
    f: TfrmPrefs;
begin
    f := TfrmPrefs.Create(Application);
    f.LoadPrefs;
    // frmExodus.PreModal(f);
    f.ShowModal;
    //frmExodus.PostModal();
    f.Free();
end;

{---------------------------------------}
procedure TfrmPrefs.LoadPrefs;
begin
    // load prefs from the reg.
    with MainSession.Prefs do begin

        // Keywords and Blockers
        fillStringList('keywords', memKeywords.Lines);
        chkRegex.Checked := getBool('regex_keywords');
        fillStringList('blockers', memBlocks.Lines);
   end;
end;


{---------------------------------------}
procedure TfrmPrefs.SavePrefs;
begin
    // save prefs to the reg
    with MainSession.Prefs do begin
        BeginUpdate();

        // Iterate over all the panels we have
        if (_roster <> nil) then
            _roster.SavePrefs();

        if (_system <> nil) then
            _system.SavePrefs();

        if (_subscription <> nil) then
            _subscription.SavePrefs();

        if (_font <> nil) then
            _font.SavePrefs();

        if (_dialogs <> nil) then
            _dialogs.SavePrefs();

        if (_message <> nil) then
            _message.SavePrefs();

        if (_notify <> nil) then
            _notify.SavePrefs();

        if (_away <> nil) then
            _away.SavePrefs();

        if (_pres <> nil) then
            _pres.SavePrefs();

        if (_plugs <> nil) then
            _plugs.SavePrefs();

        if (_xfer <> nil) then
            _xfer.SavePrefs();

        if (_network <> nil) then
            _network.SavePrefs();

        // Keywords
        setStringList('keywords', memKeywords.Lines);
        setBool('regex_keywords', chkRegex.Checked);
        setStringList('blockers', memBlocks.Lines);

        endUpdate();
    end;
    MainSession.FireEvent('/session/prefs', nil);
end;

{---------------------------------------}
procedure TfrmPrefs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    MainSession.Prefs.SavePosition(Self);
    Action := caFree;
end;

{---------------------------------------}
procedure TfrmPrefs.FormCreate(Sender: TObject);
begin
    TranslateProperties(Self);
    
    tbsKeywords.TabVisible := false;
    tbsBlockList.TabVisible := false;

    // Load the system panel
    _system := nil;
    _cur_panel := nil;
    TabSelect(lblSystem);

    // Init all the other panels
    _roster := nil;
    _subscription := nil;
    _font := nil;
    _dialogs := nil;
    _message := nil;
    _notify := nil;
    _away := nil;
    _pres := nil;
    _plugs := nil;
    _xfer := nil;
    _network := nil;

    MainSession.Prefs.RestorePosition(Self);
end;

{---------------------------------------}
procedure TfrmPrefs.TabSelect(Sender: TObject);

    procedure toggleSelector(lbl: TLabel);
    var
        i: integer;
        c: TControl;
    begin
        for i := 0 to ScrollBox1.ControlCount - 1 do begin
            c := ScrollBox1.Controls[i];
            if (c is TLabel) then begin
                if (c = lbl) then begin
                    TLabel(c).Color := clHighlight;
                    TLabel(c).Font.Color := clHighlightText;
                end
                else begin
                    TLabel(c).Color := clWindow;
                    TLabel(c).Font.Color := clWindowText;
                end;
            end;
        end;
        Self.ScrollBox1.Repaint();
    end;


var
    f: TfrmPrefPanel;
begin
    f := nil;
    if ((Sender = imgSystem) or (Sender = lblSystem)) then begin
        // PageControl1.ActivePage := tbsSystem;
        toggleSelector(lblSystem);
        if (_system <> nil) then
            f := _system
        else begin
            _system := TfrmPrefSystem.Create(Self);
            f := _system;
        end;
    end
    else if ((Sender = imgRoster) or (Sender = lblRoster)) then begin
        // PageControl1.ActivePage := tbsRoster;
        toggleSelector(lblRoster);
        if (_roster <> nil) then
            f := _roster
        else begin
            _roster := TfrmPrefRoster.Create(Self);
            f := _roster;
        end;
    end
    else if ((Sender = imgS10n) or (Sender = lblS10n)) then begin
        // PageControl1.ActivePage := tbsSubscriptions;
        toggleSelector(lblS10n);
        if (_subscription <> nil) then
            f := _subscription
        else begin
            _subscription := TfrmPrefSubscription.Create(Self);
            f := _subscription;
        end;
    end
    else if ((Sender = imgFonts) or (Sender = lblFonts)) then begin
        // PageControl1.ActivePage := tbsFonts;
        toggleSelector(lblFonts);
        if (_font <> nil) then
            f := _font
        else begin
            _font := TfrmPrefFont.Create(Self);
            f := _font;
        end;
    end
    else if ((Sender = imgDialog) or (Sender = lblDialog)) then begin
        // PageControl1.ActivePage := tbsDialog;
        toggleSelector(lblDialog);
        if (_dialogs <> nil) then
            f := _dialogs
        else begin
            _dialogs := TfrmPrefDialogs.Create(Self);
            f := _dialogs;
        end;
    end
    else if ((Sender = imgMessages) or (Sender = lblMessages)) then begin
        // PageControl1.ActivePage := tbsMessages;
        toggleSelector(lblMessages);
        if (_message <> nil) then
            f := _message
        else begin
            _message := TfrmPrefMsg.Create(Self);
            f := _message;
        end;
    end
    else if ((Sender = imgNotify) or (Sender = lblNotify)) then begin
        // PageControl1.ActivePage := tbsNotify;
        toggleSelector(lblNotify);
        if (_notify <> nil) then
            f := _notify
        else begin
            _notify := TfrmPrefNotify.Create(Self);
            f := _notify;
        end;
    end
    else if ((Sender = imgAway) or (Sender = lblAway)) then begin
        toggleSelector(lblAway);
        if (_away <> nil) then
            f := _away
        else begin
            _away := TfrmPrefAway.Create(Self);
            f := _away;
        end;
    end
    else if ((Sender = imgCustompres) or (Sender = lblCustomPres)) then begin
        toggleSelector(lblCustompres);
        if (_pres <> nil) then
            f := _pres
        else begin
            _pres := TfrmPrefPresence.Create(Self);
            f := _pres;
        end;
    end
    else if ((Sender = imgPlugins) or (Sender = lblPlugins)) then begin
        toggleSelector(lblPlugins);
        if (_plugs <> nil) then
            f := _plugs
        else begin
            _plugs := TfrmPrefPlugins.Create(Self);
            f := _plugs;
        end;
    end
    else if ((Sender = imgTransfer) or (Sender = lblTransfer)) then begin
        toggleSelector(lblTransfer);
        if (_xfer <> nil) then
            f := _xfer
        else begin
            _xfer := TfrmPrefTransfer.Create(Self);
            f := _xfer;
        end;
    end
    else if ((Sender = imgNetwork) or (Sender = imgNetwork)) then begin
        toggleSelector(lblTransfer);
        if (_network <> nil) then
            f := _network
        else begin
            _network := TfrmPrefNetwork.Create(Self);
            f := _network;
        end;
    end
    else if ((Sender = imgKeywords) or (Sender = lblKeywords)) then begin
        PageControl1.ActivePage := tbsKeywords;
        toggleSelector(lblKeywords);
    end
    else if ((Sender = imgBlockList) or (Sender = lblBlockList)) then begin
        PageControl1.ActivePage := tbsBlockList;
        toggleSelector(lblBlocklist);
    end;
    
    // setup the panel..
    if (f <> nil) then begin
        if PageControl1.Visible then
            PageControl1.Visible := false;

        f.Parent := Self;
        f.Align := alClient;
        f.Visible := true;
        f.BringToFront();
        _cur_panel := f;
    end
    else begin
        if (not PageControl1.Visible) then
            PageControl1.Visible := true;
        PageControl1.BringToFront();
    end;
end;

{---------------------------------------}
procedure TfrmPrefs.frameButtons1btnOKClick(Sender: TObject);
begin
    SavePrefs;
    Self.BringToFront();
end;

{---------------------------------------}
procedure TfrmPrefs.FormDestroy(Sender: TObject);
begin
    // destroy all panels we have..
    _system.Free();
    _roster.Free();
    _subscription.Free();
    _font.Free();
    _dialogs.Free();
    _message.Free();
    _notify.Free();
    _away.Free();
    _pres.Free();
    _plugs.Free();
    _xfer.Free();
    _network.Free();
end;

end.

