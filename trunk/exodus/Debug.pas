unit Debug;
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
    Dockable, XMLTag,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, StdCtrls, ExtCtrls, ComCtrls, Menus, RichEdit2, ExRichEdit,
    Buttons, TntStdCtrls;

type
  TfrmDebug = class(TfrmDockable)
    Panel2: TPanel;
    Splitter1: TSplitter;
    PopupMenu1: TPopupMenu;
    popMsg: TMenuItem;
    popIQGet: TMenuItem;
    popIQSet: TMenuItem;
    popPres: TMenuItem;
    MsgDebug: TExRichEdit;
    pnlTop: TPanel;
    btnClose: TSpeedButton;
    lblJID: TTntLabel;
    N1: TMenuItem;
    Clear1: TMenuItem;
    SendXML1: TMenuItem;
    Find1: TMenuItem;
    WordWrap1: TMenuItem;
    FindDialog1: TFindDialog;
    lblLabel: TTntLabel;
    MemoSend: TExRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure chkDebugWrapClick(Sender: TObject);
    procedure btnClearDebugClick(Sender: TObject);
    procedure btnSendRawClick(Sender: TObject);
    procedure popMsgClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure WordWrap1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure lblJIDClick(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure MsgDebugKeyPress(Sender: TObject; var Key: Char);
    procedure MemoSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    _cb: integer;
    _scb: integer;
    procedure DataCallback(event: string; tag: TXMLTag; data: Widestring);
  protected
    procedure SessionCallback(event: string; tag: TXMLTag);
  public
    procedure AddWideText(txt: WideString; txt_color: TColor);

    procedure DockForm; override;
    procedure FloatForm; override;

  end;

procedure ShowDebugForm();
procedure DockDebugForm();
procedure FloatDebugForm();
procedure CloseDebugForm();
procedure DebugMessage(txt: Widestring);

function isDebugShowing(): boolean;

const
    DEBUG_LIMIT = 500;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

{$R *.dfm}
uses
    Signals, Session, ExUtils, Jabber1;

var
    frmDebug: TfrmDebug;


{---------------------------------------}
procedure ShowDebugForm();
begin
    // Singleton factory
    if ( frmDebug = nil ) then
        frmDebug := TfrmDebug.Create(Application);
    if (not frmDebug.Visible) then
        frmDebug.ShowDefault();

    if (frmDebug.Docked) then
        frmExodus.Tabs.ActivePage := frmDebug.TabSheet
    else
        frmDebug.Show();
end;

{---------------------------------------}
function isDebugShowing(): boolean;
begin
    Result := (frmDebug <> nil);
end;

{---------------------------------------}
procedure DockDebugForm();
begin
    if ((frmDebug <> nil) and (not frmDebug.Docked)) then begin
        frmDebug.DockForm;
        frmDebug.Show;
    end;
end;

{---------------------------------------}
procedure FloatDebugForm();
begin
    // make sure debug window is hidden and undocked
    if ((frmDebug <> nil) and (frmDebug.Docked)) then begin
        frmDebug.Hide;
        frmDebug.FloatForm;
    end;
end;

{---------------------------------------}
procedure CloseDebugForm();
begin
    if ( frmDebug = nil ) then exit;
    frmDebug.Close();
end;

{---------------------------------------}
procedure DebugMessage(txt: Widestring);
begin
    if (frmDebug = nil) then exit;
    if (not frmDebug.Visible) then exit;

    frmDebug.AddWideText(txt, clRed);
end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
procedure TfrmDebug.FormCreate(Sender: TObject);
begin
    // make sure the output is showing..
    inherited;

    lblJID.Left := lblLabel.Left + lblLabel.Width + 5;
    lblJID.Font.Color := clBlue;
    lblJID.Font.Style := [fsUnderline];

    _cb := MainSession.RegisterCallback(DataCallback);
    _scb := MainSession.RegisterCallback(SessionCallback, '/session');

    if MainSession.Active then begin
        lblJID.Caption := MainSession.Username + '@' + MainSession.Server +
            '/' + MainSession.Resource;
    end
    else
        lblJID.Caption := '(Disconnected)';

end;

{---------------------------------------}
procedure TfrmDebug.AddWideText(txt: WideString; txt_color: TColor);
var
    ScrollInfo: TScrollInfo;
    r: integer;
    ts: longword;
    bot_thumb: integer;
    at_bottom: boolean;
begin
    //
    with MsgDebug do begin
        ScrollInfo.cbSize := SizeOf(TScrollInfo);
        ScrollInfo.fMask := SIF_PAGE + SIF_POS + SIF_RANGE;
        GetScrollInfo(Handle, SB_VERT, ScrollInfo);
        ts := ScrollInfo.nPage;
        r := ScrollInfo.nMax - Scrollinfo.nMin;
        bot_thumb := ScrollInfo.nPos + Integer(ScrollInfo.nPage) + 2;
        at_bottom := (bot_thumb >= ScrollInfo.nMax) or (ScrollInfo.nMax = 0) or
            (ts >= Trunc(0.8 * r));

        SelStart := GetTextLen;
        SelLength := 0;
        SelAttributes.Color := txt_Color;
        WideSelText := txt + ''#13#10;

        if (at_bottom) then
        Perform(EM_SCROLL, SB_PAGEDOWN, 0);
    end;
end;

{---------------------------------------}
procedure TfrmDebug.DataCallback(event: string; tag: TXMLTag; data: Widestring);
var
    l, d: integer;
begin
    if (frmDebug = nil) then exit;
    if (not frmDebug.Visible) then exit;

    if (MsgDebug.Lines.Count >= DEBUG_LIMIT) then begin
        d := (MsgDebug.Lines.Count - DEBUG_LIMIT) + 1;
        for l := 1 to d do
            MsgDebug.Lines.Delete(0);
    end;

    if (event = '/data/send') then begin
        if (Trim(data) <> '') then
            AddWideText('SENT: ' + data, clBlue);
    end
    else
        AddWideText('RECV: ' + data, clGreen);
end;

{---------------------------------------}
procedure TfrmDebug.chkDebugWrapClick(Sender: TObject);
begin
end;

{---------------------------------------}
procedure TfrmDebug.btnClearDebugClick(Sender: TObject);
begin
end;

{---------------------------------------}
procedure TfrmDebug.btnSendRawClick(Sender: TObject);
var
    cmd: WideString;
    sig: TSignal;
    i, s: integer;
    msg: WideString;
    l: TSignalListener;
begin
    // Send the text in the MsgSend memo box
    cmd := getInputText(MemoSend);
    // cmd := Trim(MemoSend.Lines.Text);
    if (cmd = '') then exit;
    if (cmd[1] = '/') then begin
        // we are giving some kind of interactive debugger cmd
        if (cmd ='/help') then
            DebugMessage('/dispcount'#13#10'/dispdump'#13#10'/args')
        else if (cmd = '/args') then begin
            for i := 0 to ParamCount do
                DebugMessage(ParamStr(i))
        end
        else if (cmd = '/dispcount') then
            DebugMessage('Dispatcher listener count: ' + IntToStr(MainSession.Dispatcher.TotalCount))
        else if (cmd = '/dispdump') then begin
            // dump out all signals
            with MainSession.Dispatcher do begin
                for s := 0 to Count - 1 do begin
                    sig := TSignal(Objects[s]);
                    DebugMessage('SIGNAL: ' + Strings[s] + ' of class: ' + sig.ClassName);
                    DebugMessage('-----------------------------------');
                    for i := 0 to sig.Count - 1 do begin
                        l := TSignalListener(sig.Objects[i]);
                        msg := 'LID: ' + IntToStr(l.cb_id) + ', ';
                        msg := msg + sig.Strings[i] + ', ';
                        msg := msg + l.classname + ', ';
                        msg := msg + l.methodname;
                        DebugMessage(msg);
                    end;
                    DebugMessage(''#13#10);
                end;
            end;
        end;
    end
    else
        MainSession.Stream.Send(cmd);
end;

{---------------------------------------}
procedure TfrmDebug.popMsgClick(Sender: TObject);
var
    id: string;
begin
    // setup an XML fragment
    id := MainSession.generateID;
    with MemoSend.Lines do begin
        Clear;
        if Sender = popMsg then
            Add('<message to="" id="' + id + '"><body></body></message>')
        else if Sender = popIQGet then
            Add('<iq type="get" to="" id="' + id + '"><query xmlns=""></query></iq>')
        else if Sender = popIQSet then
            Add('<iq type="set" to="" id="' + id + '"><query xmlns=""></query></iq>')
        else if Sender = popPres then
            Add('<presence to="" id="' + id + '"/>');
    end;
end;

{---------------------------------------}
procedure TfrmDebug.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    Action := caFree;

    if ((MainSession <> nil) and (_cb <> -1)) then begin
        MainSession.UnregisterCallback(_scb);
        MainSession.UnregisterCallback(_cb);
    end;

    frmDebug := nil;

    inherited;
end;

{---------------------------------------}
procedure TfrmDebug.btnCloseClick(Sender: TObject);
begin
  inherited;
    Self.Close;
end;

{---------------------------------------}
procedure TfrmDebug.DockForm;
begin
    inherited;
    btnClose.Visible := true;
end;

{---------------------------------------}
procedure TfrmDebug.FloatForm;
begin
    inherited;
    btnClose.Visible := false;
end;

{---------------------------------------}
procedure TfrmDebug.FormEndDock(Sender, Target: TObject; X, Y: Integer);
begin
    inherited;
    btnClose.Visible := Docked;
end;

{---------------------------------------}
procedure TfrmDebug.WordWrap1Click(Sender: TObject);
begin
  inherited;
    WordWrap1.Checked := not WordWrap1.Checked;
    MsgDebug.WordWrap := WordWrap1.Checked;
end;

{---------------------------------------}
procedure TfrmDebug.Clear1Click(Sender: TObject);
begin
  inherited;
    MsgDebug.Lines.Clear;
end;

{---------------------------------------}
procedure TfrmDebug.SessionCallback(event: string; tag: TXMLTag);
begin
    if (event = '/session/authenticated') then begin
        lblJID.Caption := MainSession.Username + '@' + MainSession.Server +
            '/' + MainSession.Resource;
    end
    else if (event = '/session/disconnected') then
        lblJID.Caption := '(Disconnected)';
end;

{---------------------------------------}
procedure TfrmDebug.lblJIDClick(Sender: TObject);
var
    cp: TPoint;
begin
  inherited;
    GetCursorPos(cp);
    popupMenu1.popup(cp.x, cp.y);
end;

{---------------------------------------}
procedure TfrmDebug.Find1Click(Sender: TObject);
begin
  inherited;
    FindDialog1.Execute();
end;

{---------------------------------------}
procedure TfrmDebug.FindDialog1Find(Sender: TObject);
var
    FoundAt: LongInt;
    StartPos: Integer;
begin
  inherited;
    { begin the search after the current selection if there is one }
    { otherwise, begin at the start of the text }
    with MsgDebug do begin
        if SelLength <> 0 then
          StartPos := SelStart + SelLength
        else
          StartPos := 0;

        FoundAt := FindText(FindDialog1.FindText, StartPos, -1, [stMatchCase]);
        if FoundAt <> -1 then begin
            SetFocus;
            SelStart := FoundAt;
            SelLength := Length(FindDialog1.FindText);
        end
        else if (StartPos > 0) then begin
            Beep();
            SelLength := 0;
            FindDialog1Find(Self);
        end
        else
            Beep();
    end;
end;

{---------------------------------------}
procedure TfrmDebug.MsgDebugKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
    Key := Chr(0);
end;

{---------------------------------------}
procedure TfrmDebug.MemoSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
    if (Key = 0) then exit;

    // handle Ctrl-Tab to switch tabs
    if ((Key = VK_TAB) and (ssCtrl in Shift) and (self.Docked))then begin
        Self.TabSheet.PageControl.SelectNextPage(not (ssShift in Shift));
        Key := 0;
    end

    // handle Ctrl-ENTER and ENTER to send msgs
    else if ((Key = VK_RETURN) and (Shift = [ssCtrl])) then begin
        Key := 0;
        btnSendRawClick(Self);
    end;

end;

{---------------------------------------}
procedure TfrmDebug.FormActivate(Sender: TObject);
begin
  inherited;
    if (not Docked) then exit;

    // do something here to activate the appropriate tab
end;

end.
