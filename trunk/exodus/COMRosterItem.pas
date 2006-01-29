unit COMRosterItem;
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
    NodeItem, Roster, ComObj, ActiveX, ExodusCOM_TLB, StdVcl;

type
  TExodusRosterItem = class(TAutoObject, IExodusRosterItem)
  protected
    function Get_JabberID: WideString; safecall;
    procedure Set_JabberID(const Value: WideString); safecall;
    function Get_Subscription: WideString; safecall;
    procedure Set_Subscription(const Value: WideString); safecall;
    function Get_Ask: WideString; safecall;
    function Get_GroupCount: Integer; safecall;
    function Group(Index: Integer): WideString; safecall;
    function Get_Nickname: WideString; safecall;
    function Get_RawNickname: WideString; safecall;
    function XML: WideString; safecall;
    procedure Remove; safecall;
    procedure Set_Nickname(const Value: WideString); safecall;
    procedure Update; safecall;
    function Get_ContextMenuID: WideString; safecall;
    procedure Set_ContextMenuID(const Value: WideString); safecall;
    { Protected declarations }
  private
    _ritem: TJabberRosterItem;
    _menu_id: Widestring;
    
  public
    constructor Create(ritem: TJabberRosterItem);
  end;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

uses
    TntMenus, Menus, ExSession, COMRoster, Session, JabberID, ComServ;

{---------------------------------------}
constructor TExodusRosterItem.Create(ritem: TJabberRosterItem);
begin
    // this is just a wrapper for the roster item
    _ritem := ritem;
    _menu_id := '';
end;

{---------------------------------------}
function TExodusRosterItem.Get_JabberID: WideString;
begin
    Result := _ritem.jid.full();
end;

{---------------------------------------}
procedure TExodusRosterItem.Set_JabberID(const Value: WideString);
begin
    // XXX: remove Set_JabberID from the interface
    {
    if (_ritem.jid <> nil) then
        _ritem.jid.Free();

    _ritem.setJid(value);
    }
end;

{---------------------------------------}
function TExodusRosterItem.Get_Subscription: WideString;
begin
    Result := _ritem.subscription;
end;

{---------------------------------------}
procedure TExodusRosterItem.Set_Subscription(const Value: WideString);
begin
    _ritem.Tag.setAttribute('subscription', value);
end;

{---------------------------------------}
function TExodusRosterItem.Get_Ask: WideString;
begin
    Result := _ritem.ask;
end;

{---------------------------------------}
function TExodusRosterItem.Get_GroupCount: Integer;
begin
    Result := _ritem.GroupCount;
end;

{---------------------------------------}
function TExodusRosterItem.Group(Index: Integer): WideString;
begin
    if ((index >= 0) and (Index < _ritem.GroupCount)) then
        Result := _ritem.Group[Index]
    else
        Result := '';
end;

{---------------------------------------}
function TExodusRosterItem.Get_Nickname: WideString;
begin
    Result := _ritem.Text;
end;

{---------------------------------------}
function TExodusRosterItem.Get_RawNickname: WideString;
begin
    Result := _ritem.Text;
end;

{---------------------------------------}
function TExodusRosterItem.XML: WideString;
begin
    Result := _ritem.Tag.xml();
end;

{---------------------------------------}
procedure TExodusRosterItem.Remove;
begin
    _ritem.remove();
end;

{---------------------------------------}
procedure TExodusRosterItem.Set_Nickname(const Value: WideString);
begin
    _ritem.Text := Value;
end;

{---------------------------------------}
procedure TExodusRosterItem.Update;
begin
    _ritem.update();
end;

{---------------------------------------}
function TExodusRosterItem.Get_ContextMenuID: WideString;
begin
    Result := _menu_id;
end;

{---------------------------------------}
procedure TExodusRosterItem.Set_ContextMenuID(const Value: WideString);
var
    menu: TTntPopupMenu;
begin
    menu := ExCOMRoster.findContextMenu(value);
    if (menu <> nil) then begin
        _menu_id := Value;
        _ritem.CustomContext := menu;
    end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TExodusRosterItem, Class_ExodusRosterItem,
    ciMultiInstance, tmApartment);
end.
