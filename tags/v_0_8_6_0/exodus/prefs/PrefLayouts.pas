unit PrefLayouts;
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
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PrefPanel, StdCtrls, jpeg, ExtCtrls, TntStdCtrls, TntExtCtrls;

type
  TfrmPrefLayouts = class(TfrmPrefPanel)
    lblPreview: TTntLabel;
    cboView: TTntComboBox;
    imgView2: TImage;
    imgView3: TImage;
    imgView1: TImage;
    lblViewHelp: TTntLabel;
    StaticText4: TTntPanel;
    procedure cboViewChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadPrefs(); override;
    procedure SavePrefs(); override;

  end;

var
  frmPrefLayouts: TfrmPrefLayouts;

resourcestring
    sViewSimple = 'The main window shows only the roster. Other windows are opened in seperate windows and never docked';
    sViewShare = 'The main window always shows the roster. Other windows are docked using a tabbed interface to the main window.';
    sViewExpanded = 'The main window shows the roster. Other windows are docked using a tabbed interface to the main window.';


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation

{$R *.dfm}
uses
    Session, PrefController; 

{---------------------------------------}
procedure TfrmPrefLayouts.LoadPrefs();
begin
    //
    imgView1.Left := lblPreview.Left;
    imgView2.Left := lblPreview.Left;
    imgView3.Left := lblPreview.Left;

    with MainSession.Prefs do begin
        // View management stuff
        if (getBool('expanded')) then begin
            if (getBool('roster_messenger')) then
                cboView.ItemIndex := 2
            else
                cboView.ItemIndex := 1;
        end
        else
            cboView.ItemIndex := 0;
        cboViewChange(Self);
    end;
end;

{---------------------------------------}
procedure TfrmPrefLayouts.SavePrefs();
begin
    //
    with MainSession.Prefs do begin
        //
        if (cboView.ItemIndex = 0) then begin
            setBool('expanded', false);
            setBool('roster_messenger', false);
        end
        else if (cboView.ItemIndex = 1) then begin
            setBool('expanded', true);
            setBool('roster_messenger', false);
        end
        else if (cboView.ItemIndex = 2) then begin
            setBool('expanded', true);
            setBool('roster_messenger', true);
        end;
    end;
end;

{---------------------------------------}
procedure TfrmPrefLayouts.cboViewChange(Sender: TObject);
var
    idx: integer;
begin
  inherited;
    idx := cboView.ItemIndex;
    imgView1.Visible := (idx = 0);
    imgView2.Visible := (idx = 1);
    imgView3.Visible := (idx = 2);

    case idx of
    0: lblViewHelp.Caption := sViewSimple;
    1: lblViewHelp.Caption := sViewShare;
    2: lblViewHelp.Caption := sViewExpanded;
    end;
    
end;

end.
