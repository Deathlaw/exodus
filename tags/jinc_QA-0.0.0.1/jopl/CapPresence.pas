unit CapPresence;
{
    Copyright 2003, Joe Hildebrand

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
    Presence, XMLTag,
    Contnrs, SysUtils;

type

    TCapPresence = class(TJabberPres)
    private
    public
        constructor Create; override;
        destructor Destroy; override;
        // TODO: add accessors for ver and ext, and allow setting ext.
    end;
implementation

uses
    ExResponders, Session, PrefController, JabberConst, XMLUtils;

{---------------------------------------}
constructor TCapPresence.Create;
var
    c : TXMLTag;
    ext : WideString;
begin
    inherited;
    // Add in client capabilities if we have them enabled.
    if (MainSession.Prefs.getBool('client_caps')) then begin
        c := AddTag('c');
        c.setAttribute('xmlns', XMLNS_CLIENTCAPS);
        c.setAttribute('node', MainSession.Prefs.getString('client_caps_uri'));
        c.setAttribute('ver', GetAppVersion());
        ext := Exodus_Disco_Info.ExtList();
        if (ext <> '') then
            c.setAttribute('ext', ext);
    end;
end;

{---------------------------------------}
destructor TCapPresence.Destroy;
begin
    inherited Destroy;
end;

end.
