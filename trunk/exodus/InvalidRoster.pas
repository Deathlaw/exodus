unit InvalidRoster;
interface
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

uses
    Dockable, XMLTag,
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, buttonFrame, ComCtrls;

type
  TfrmInvalidRoster = class(TfrmDockable)
    frameButtons1: TframeButtons;
    ListView1: TListView;
    procedure frameButtons1btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure frameButtons1btnOKClick(Sender: TObject);
  private
    { Private declarations }
    _jids: TStringList;
  public
    { Public declarations }
    procedure AddPacket(tag: TXMLTag);
  end;

var
  frmInvalidRoster: TfrmInvalidRoster;

function getInvalidRoster: TfrmInvalidRoster;

{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

{$R *.dfm}
uses
    Session, Roster;

{---------------------------------------}
function getInvalidRoster: TfrmInvalidRoster;
begin
    //
    if (frmInvalidRoster = nil) then begin
        frmInvalidRoster := TfrmInvalidRoster.Create(nil);
        end;
    Result := frmInvalidRoster;
    Result.ShowDefault();
end;

{---------------------------------------}
procedure TfrmInvalidRoster.AddPacket(tag: TXMLTag);
var
    j: string;
    li: TListItem;
    e: TXMLTag;
    ritem: TJabberRosterItem;
begin
    // add a new list view item
    j := tag.GetAttribute('from');
    if (_jids.IndexOf(j) >= 0) then exit;

    ritem := MainSession.Roster.Find(j);
    if (ritem <> nil) then begin
        _jids.Add(j);
        li := ListView1.Items.Add();
        li.Caption := tag.GetAttribute('from');
        e := tag.GetFirstTag('error');
        li.SubItems.Add(ritem.nickname);
        li.SubItems.Add(e.Data);
        li.Checked := true;
        li.Data := ritem;
        end;
end;

{---------------------------------------}
procedure TfrmInvalidRoster.frameButtons1btnCancelClick(Sender: TObject);
begin
    Self.Close();
end;

{---------------------------------------}
procedure TfrmInvalidRoster.FormCreate(Sender: TObject);
begin
    _jids := TStringlist.Create;

    inherited;
end;

{---------------------------------------}
procedure TfrmInvalidRoster.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    _jids.Free();
    Action := caFree;
    frmInvalidRoster := nil;
end;

{---------------------------------------}
procedure TfrmInvalidRoster.frameButtons1btnOKClick(Sender: TObject);
var
    li: TListItem;
    i: integer;
    ritem: TJabberRosterItem;
begin
    // remove all of the checked items
    for i := 0 to ListView1.Items.Count - 1 do begin
        li := ListView1.Items[i];
        if (li.Checked) then begin
            ritem := TJabberRosterItem(li.Data);
            if (ritem <> nil) then
                ritem.remove();
            end;
        end;

    for i := ListView1.Items.Count - 1 downto 0 do begin
        li := ListView1.Items[i];
        if (li.Checked) then
            ListView1.Items.Delete(i);
        end;
end;

end.
