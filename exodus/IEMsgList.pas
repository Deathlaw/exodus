unit IEMsgList;
{
    Copyright 2004, Peter Millard

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
    TntMenus, JabberMsg,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, Regexpr, iniFiles,
    BaseMsgList, Session, gnugettext, unicode,
    XMLTag, XMLNode, XMLConstants, XMLCdata, LibXmlParser, XMLUtils,
    OleCtrls, SHDocVw, MSHTML, mshtmlevents, ActiveX;

type
  TfIEMsgList = class(TfBaseMsgList)
    browser: TWebBrowser;
    procedure browserDocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure browserEnter(Sender: TObject);
    procedure browserBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);

  private
    { Private declarations }
    _home: WideString;

    _doc: IHTMLDocument2;
    _win: IHTMLWindow2;
    _body: IHTMLElement;
    _style: IHTMLStyleSheet;
    _content: IHTMLElement;
    _content2: IHTMLElement2;

    _we: TMSHTMLHTMLElementEvents;
    _de: TMSHTMLHTMLDocumentEvents;

    _bottom: Boolean;
    _menu:  TTntPopupMenu;
    _queue: TWideStringList;
    _title: WideString;
    _ready: Boolean;

    procedure onScroll(Sender: TObject);
    procedure onResize(Sender: TObject);
    function onContextMenu(Sender: TObject): WordBool;

  protected
      procedure writeHTML(html: WideString);

  public
    { Public declarations }
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure Invalidate(); override;
    procedure CopyAll(); override;
    procedure Copy(); override;
    procedure ScrollToBottom(); override;
    procedure Clear(); override;
    procedure setContextMenu(popup: TTntPopupMenu); override;
    procedure setDragOver(event: TDragOverEvent); override;
    procedure setDragDrop(event: TDragDropEvent); override;
    procedure DisplayMsg(Msg: TJabberMessage; AutoScroll: boolean = true); override;
    procedure DisplayPresence(txt: string); override;
    function  getHandle(): THandle; override;
    function  getObject(): TObject; override;
    function  empty(): boolean; override;
    function  getHistory(): Widestring; override;
    procedure Save(fn: string); override;
    procedure populate(history: Widestring); override;
    procedure setupPrefs(); override;
    procedure setTitle(title: Widestring); override;
    procedure ready(); override;
    procedure refresh(); override;

    procedure ChangeStylesheet(url: WideString);
  end;

var
  fIEMsgList: TfIEMsgList;
  xp_xhtml: TXPLite;
  url_regex: TRegExpr;
  crlf_regex: TRegExpr;
  ok_tags: THashedStringList;
  style_tags: THashedStringList;
  style_props: THashedStringList;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

uses Jabber1, BaseChat, ExUtils, ShellAPI, Emote;

{$R *.dfm}

{---------------------------------------}
constructor TfIEMsgList.Create(Owner: TComponent);
begin
    inherited;
    _queue := TWideStringList.Create();
    _ready := true;
end;

{---------------------------------------}
destructor TfIEMsgList.Destroy;
begin
    if (_queue <> nil) then begin
        _queue.Free();
        _queue := nil;
    end;
    inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.writeHTML(html: WideString);
begin
    if (_content = nil) then begin
        assert(_queue <> nil);
        _queue.Add(html);
        exit;
    end;

    _content.insertAdjacentHTML('beforeEnd', html);
end;

{---------------------------------------}
procedure TfIEMsgList.Invalidate();
begin
//    browser.Invalidate();
end;

{---------------------------------------}
procedure TfIEMsgList.CopyAll();
begin
    _doc.execCommand('SelectAll', false, varNull);
    _doc.execCommand('Copy', true, varNull);
    _doc.execCommand('Unselect', false, varNull);
end;

{---------------------------------------}
procedure TfIEMsgList.Copy();
begin
    _doc.execCommand('Copy', true, varNull);
end;

{---------------------------------------}
procedure TfIEMsgList.ScrollToBottom();
var
    tags: IHTMLElementCollection;
    last: IHTMLElement;
begin
    if (_win = nil) then exit;

    // this is a slowness for large histories, I think, but it is the only
    // thing that seems to work, since we are now scrolling the _content
    // element, rather than the window, as Bill intended.
    tags := _content.children as IHTMLElementCollection;
    if (tags.length > 0) then begin
        last := tags.Item(tags.length - 1, 0) as IHTMLElement;
        last.ScrollIntoView(false);
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.Clear();
begin
    _ready := true;
    _home := 'res://' + URL_EscapeChars(Application.ExeName);
    browser.Navigate(_home + '/iemsglist');
end;

{---------------------------------------}
procedure TfIEMsgList.setContextMenu(popup: TTntPopupMenu);
begin
    _menu := popup;
end;

{---------------------------------------}
function TfIEMsgList.getHandle(): THandle;
begin
    Result := 0; //Browser.Handle;
end;

{---------------------------------------}
function TfIEMsgList.getObject(): TObject;
begin
    // Result := Browser;
    result := nil;
end;

{---------------------------------------}
function ProcessTag(parent: TXMLTag; n: TXMLNode): WideString;
var
    nodes: TXMLNodeList;
    i, j: integer;
    attrs: TAttrList;
    attr: TAttr;
    tag: TXMLTag;
    chunks: TWideStringList;
    nv : TWideStringList;
    started: boolean;
    str: WideString;
begin
    // See JEP-71 (http://www.jabber.org/jeps/jep-0071.html) for details.

    result := '';

    // any tag not in the good list should be deleted, but everything else
    // around it should stay.
    // opted to do own serialization for efficiency; didn't want to have to
    // make many passes over the same data.
    if (n.NodeType = xml_Tag) then begin
        tag := TXMLTag(n);
        if (ok_tags.IndexOf(tag.Name) < 0) then
            exit;

        result := result + '<' + tag.Name;

        nv := TWideStringList.Create();
        chunks := TWideStringList.Create();
        attrs := tag.Attributes;
        for i := 0 to attrs.Count - 1 do begin
            attr := TAttr(attrs[i]);
            if (attr.Name = 'style') then begin
                // style attribute only allowed on style_tags.
                if (style_tags.IndexOf(tag.Name) >= 0) then begin
                    //  remove any style properties that aren't in the allowed list
                    chunks.Clear();
                    split(attr.value, chunks, ';');
                    started := false;
                    for j := 0 to chunks.Count - 1 do begin
                        nv.Clear();
                        split(chunks[j], nv, ':');
                        if (nv.Count < 1) then
                            continue;
                        if (style_props.IndexOf(nv[0]) >= 0) then begin
                            if (not started) then begin
                                started := true;
                                result := result + ' style="';
                            end;
                            result := result + HTML_EscapeChars(chunks[j], false) + ';';
                        end;
                    end;
                    if (started) then
                        result := result + '"';
                end;
            end
            else if (tag.Name = 'a') then begin
                if (attr.Name = 'href') then
                    result := result + ' ' +
                        attr.Name + '="' + HTML_EscapeChars(attr.Value, false) + '"';
            end
            else if (tag.Name = 'img') then begin
                if ((attr.Name = 'alt') or
                    (attr.Name = 'height') or
                    (attr.Name = 'longdesc') or
                    (attr.Name = 'src') or
                    (attr.Name = 'width')) then begin
                    result := result + ' ' +
                        attr.Name + '="' + HTML_EscapeChars(attr.Value, false) + '"';
                end;
            end
        end;
        nv.Free();
        chunks.Free();

        nodes := tag.Nodes;
        if (nodes.Count = 0) then
            result := result + '/>'
        else begin
            // iterate over all the children
            result := result + '>';
            for i := 0 to nodes.Count - 1 do
                result := result + ProcessTag(tag, TXMLNode(nodes[i]));
            result := result + '</' + tag.name + '>';
        end;
    end
    else if (n.NodeType = xml_CDATA) then begin
        // Check for URLs
        if ((parent = nil) or (parent.Name <> 'a')) then begin
            str := url_regex.Replace(TXMLCData(n).Data,
                                     '<a href="$0">$0</a>', true);
            result := result + ProcessIEEmoticons(str);
        end
        else
            result := result + TXMLCData(n).Data;
    end;
end;

{---------------------------------------}
procedure TfIEMsgList.DisplayMsg(Msg: TJabberMessage; AutoScroll: boolean = true);
var
    txt: WideString;
    body: TXmlTag;
    i: integer;
    nodes: TXMLNodeList;
    cd: TXMLCData;
begin
    body := Msg.Tag.QueryXPTag(xp_xhtml);
    if (body <> nil) then begin
        nodes := body.nodes;
        for i := 0 to nodes.Count - 1 do
            txt := txt + ProcessTag(body, TXMLNode(nodes[i]));
    end;

    if (txt = '') then begin
        txt := HTML_EscapeChars(Msg.Body, false);
        txt := crlf_regex.Replace(txt, '<br />', true);
        cd := TXMLCData.Create(txt);
        txt := ProcessTag(nil, cd);
    end;

    writeHTML('<div class="line">');
    if (MainSession.Prefs.getBool('timestamp')) then begin
        try
            writeHTML('<span class="ts">[' +
                FormatDateTime(MainSession.Prefs.getString('timestamp_format'),
                               Msg.Time) + ']</span>');
        except
            on EConvertError do begin
                writeHTML('<span class="ts">[' +
                    FormatDateTime(MainSession.Prefs.getString('timestamp_format'),
                    Now()) + ']</span>');
            end;
        end;
    end;

    if (Msg.Nick = '') then begin
        // Server generated msgs (mostly in TC Rooms)
        writeHTML('&nbsp;<span class="svr">' + txt + '</span>');
    end
    else if not Msg.Action then begin
        // This is a normal message
        if Msg.isMe then
            // our own msgs
            writeHTML('&nbsp;<span class="me">&lt;' + Msg.Nick + '&gt;</span>')
        else
            writeHTML('&nbsp;<span class="other">&lt;' + Msg.Nick + '&gt;</span>');

        if (Msg.Highlight) then
            writeHTML('&nbsp;<span class="alert"> ' + txt + '</span>')
        else
            writeHTML('&nbsp;<span class="msg">' + txt + '</span>');
    end
    else
        // This is an action
        writeHTML('<span class="action">&nbsp;*&nbsp;' + Msg.Nick + '&nbsp;' + txt + '</span>');

    writeHTML('</div>');

    if (_bottom) then
        ScrollToBottom();
end;

{---------------------------------------}
procedure TfIEMsgList.DisplayPresence(txt: string);
var
    pt : integer;
begin
    pt := MainSession.Prefs.getInt('pres_tracking');
    if (pt = 2) then exit;

    if (pt = 1) then begin
        // if previous is a presence, replace with this one.
    end;

    writeHTML('<span class="pres">' + txt + '</span><br />');

    if (_bottom) then
        ScrollToBottom();
end;

{---------------------------------------}
procedure TfIEMsgList.Save(fn: string);
begin
    // XXX: Save IE MsgList
end;

{---------------------------------------}
procedure TfIEMsgList.populate(history: Widestring);
begin
    writeHTML(history);
end;

{---------------------------------------}
procedure TfIEMsgList.setupPrefs();
begin
    // XXX: IE MsgList should pick up stylesheet prefs
end;

{---------------------------------------}
function TfIEMsgList.empty(): boolean;
begin
    if (_content = nil) then
        Result := true
    else
        Result := (_content.innerHTML = '');
end;

{---------------------------------------}
function TfIEMsgList.getHistory(): Widestring;
begin
    Result := _content.innerHTML;
end;


{---------------------------------------}
procedure TfIEMsgList.setDragOver(event: TDragOverEvent);
begin
    // XXX: IEMsgList drag-n-drop
end;

{---------------------------------------}
procedure TfIEMsgList.setDragDrop(event: TDragDropEvent);
begin
    // XXX: IEMsgList drag-n-drop
end;

{---------------------------------------}
procedure TfIEMsgList.ChangeStylesheet(url: WideString);
begin
    // XXX: remove or disable old stylesheets
    _style := _doc.createStyleSheet(url, 0);
end;

{---------------------------------------}
procedure TfIEMsgList.onScroll(Sender: TObject);
begin
    _bottom :=
        ((_content2.scrollTop + _content2.clientHeight) >= _content2.scrollHeight);
end;

{---------------------------------------}
procedure TfIEMsgList.onResize(Sender: TObject);
begin
//    if (_bottom) then
//         ScrollToBottom();
end;

{---------------------------------------}
function TfIEMsgList.onContextMenu(Sender: TObject): WordBool;
begin
    Refresh();
    _menu.Popup(_win.event.screenX, _win.event.screeny);
    result := false;
end;

{---------------------------------------}
procedure TfIEMsgList.browserDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
    i: integer;
begin
    inherited;
    if ((not _ready) or (browser.Document = nil)) then
        exit;

    _ready := false;
    _doc := browser.Document as IHTMLDocument2;
    ChangeStylesheet(_home + '/iemsglist_style');

    _content := _doc.all.item('content', 0) as IHTMLElement;
    _content2 := _content as IHTMLElement2;
    _body := _doc.body;
    _bottom := true;

    _win := _doc.parentWindow;
    if (_we <> nil) then
        _we.Free();

    _we := TMSHTMLHTMLElementEvents.Create(self);
    _we.Connect(_content);
    _we.onscroll   := onscroll;
    _we.onresize   := onresize;
   // _we.onkeypress := onkeypress;

    if (_de <> nil) then
        _de.Free();
    _de := TMSHTMLHTMLDocumentEvents.Create(self);
    _de.Connect(_doc);
    _de.oncontextmenu := onContextMenu;

    assert (_queue <> nil);
    for i := 0 to _queue.Count - 1 do begin
        writeHTML(_queue.Strings[i]);
    end;
    _queue.Clear();
    if (_title <> '') then begin
        setTitle(_title);
    end;
    ScrollToBottom();
end;

{---------------------------------------}
procedure TfIEMsgList.browserEnter(Sender: TObject);
var
    bc: TfrmBaseChat;
begin
    bc := TfrmBaseChat(_base);
    if (frmExodus.ActiveChat <> bc) then
        bc.FormActivate(bc);
    inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.browserBeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
    u: string;
begin
    u := URL;
    if (u <> _home + '/iemsglist') then begin
        ShellExecute(Application.Handle, 'open', pAnsiChar(u), '', '', SW_SHOW);
        cancel := true;
    end;
    inherited;
end;

{---------------------------------------}
procedure TfIEMsgList.setTitle(title: Widestring);
var
    splash : IHTMLElement;
begin
    if (_doc = nil) then begin
        _title := title;
        exit;
    end;

    splash :=  _doc.all.item('splash', 0) as IHTMLElement;
    if (splash = nil) then exit;

    splash.innerText := _title;
end;

procedure TfIEMsgList.ready();
begin
//    _ready := true;
    Clear();
end;

procedure TfIEMsgList.refresh();
begin
    _queue.Add(getHistory());
    Clear();
end;

initialization
    TP_GlobalIgnoreClassProperty(TWebBrowser, 'StatusText');

    xp_xhtml := TXPLite.Create('/message/html/body');

    url_regex := TRegExpr.Create();
    url_regex.expression := '(https?|ftp|xmpp)://[^ '#$D#$A#$9']+';
    url_regex.Compile();

    crlf_regex := TRegExpr.Create();
    crlf_regex.expression := '('#$D'?'#$A'|'#$D')';
    crlf_regex.Compile();

    ok_tags := THashedStringList.Create();
    ok_tags.Add('blockquote');
    ok_tags.Add('br');
    ok_tags.Add('cite');
    ok_tags.Add('code');
    ok_tags.Add('div');
    ok_tags.Add('em');
    ok_tags.Add('h1');
    ok_tags.Add('h2');
    ok_tags.Add('h3');
    ok_tags.Add('p');
    ok_tags.Add('pre');
    ok_tags.Add('q');
    ok_tags.Add('span');
    ok_tags.Add('strong');
    ok_tags.Add('a');
    ok_tags.Add('ol');
    ok_tags.Add('ul');
    ok_tags.Add('li');
    ok_tags.Add('img');

    style_tags := THashedStringList.Create();
    style_tags.Add('blockquote');
    style_tags.Add('body');
    style_tags.Add('div');
    style_tags.Add('h1');
    style_tags.Add('h2');
    style_tags.Add('h3');
    style_tags.Add('li');
    style_tags.Add('ol');
    style_tags.Add('p');
    style_tags.Add('pre');
    style_tags.Add('q');
    style_tags.Add('span');
    style_tags.Add('ul');

    style_props := THashedStringList.Create();
    style_props.Add('color');
    style_props.Add('font-family');
    style_props.Add('font-size');
    style_props.Add('font-style');
    style_props.Add('font-weight');
    style_props.Add('text-align');
    style_props.Add('text-decoration');

finalization
    xp_xhtml.Free();
    url_regex.Free();
    ok_tags.Free();
    style_tags.Free();
    style_props.Free();

end.
