unit ICQPlugin;
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

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
    XMLParser, ExodusCOM_TLB, ComObj, ActiveX, ICQImport_TLB, StdVcl;

type
  TICQImportPlugin = class(TAutoObject, IICQImportPlugin, IExodusPlugin)
  protected
    procedure Startup(const ExodusController: IExodusController); safecall;
    procedure Shutdown; safecall;
    procedure NewChat(const jid: WideString; const Chat: IExodusChat); safecall;
    procedure NewRoom(const jid: WideString; const Room: IExodusChat); safecall;
    procedure menuClick(const ID: WideString); safecall;
    function onInstantMsg(const Body: WideString; const Subject: WideString): WideString; safecall;
    procedure Configure; safecall;
    procedure Process(const xpath, event, xml: WideString); safecall;
    { Protected declarations }

  private
    _controller: IExodusController;
    _menu_id: Widestring;
    _parser: TXMLTagParser;
    _agent_cb: integer;

    procedure AgentsList(const Server: WideString); safecall;
  end;

{-----------------------------------------}
{-----------------------------------------}
{-----------------------------------------}
{-----------------------------------------}
implementation
uses
    XMLTag, Importer, StrUtils, SysUtils,
    Dialogs, ComServ;

{-----------------------------------------}
procedure TICQImportPlugin.menuClick(const ID: WideString);
var
    f: TfrmImport;
begin
    if (id = _menu_id) then begin
        // make sure we are online..
        if (_controller.Connected = false) then begin
            MessageDlg('You must be connected before trying to import a ICQ Contact List.',
                mtError, [mbOK], 0);
            exit;
        end;
        f := getImportForm(_controller, true);
        f.Show();
    end;
end;

{-----------------------------------------}
procedure TICQImportPlugin.AgentsList(const Server: WideString);
var
    f: TfrmImport;
begin
    // we got back an agents list
    f := getImportForm(_controller, false);
    if (f <> nil) then begin
        if (AnsiSameText(Server, f.txtGateway.Text)) then begin
            f.processAgents();
        end;
    end;
end;

{-----------------------------------------}
procedure TICQImportPlugin.NewChat(const jid: WideString;
  const Chat: IExodusChat);
begin

end;

{-----------------------------------------}
procedure TICQImportPlugin.NewRoom(const jid: WideString;
  const Room: IExodusChat);
begin

end;

{-----------------------------------------}
procedure TICQImportPlugin.Process(const xpath, event, xml: WideString);
var
    a: TXMLTag;
begin
    if (xpath = '/session/agents') then begin
        _parser.ParseString(xml, '');
        if (_parser.Count < 1) then exit;
        a := _parser.popTag();
        AgentsList(a.GetAttribute('from'));
        a.Free();
    end;
end;

{-----------------------------------------}
procedure TICQImportPlugin.Shutdown;
begin
    _controller.removePluginMenu(_menu_id);
    _controller.UnRegisterCallback(_agent_cb);
    _parser.Free();
end;

{-----------------------------------------}
procedure TICQImportPlugin.Startup(
  const ExodusController: IExodusController);
begin
    _controller := ExodusController;
    _menu_id := _controller.addPluginMenu('Import ICQ Contacts');
    _agent_cb := _controller.RegisterCallback('/session/agents', Self);
    _parser := TXMLTagParser.Create();
end;

{-----------------------------------------}
function TICQImportPlugin.onInstantMsg(const Body: WideString;
    const Subject: WideString): WideString;
begin
    //
end;

{-----------------------------------------}
procedure TICQImportPlugin.Configure;
begin
    //
end;

initialization
  TAutoObjectFactory.Create(ComServer, TICQImportPlugin, Class_ICQImportPlugin,
    ciMultiInstance, tmApartment);
end.
