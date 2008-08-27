{
    Copyright 2001-2008, Estate of Peter Millard
	
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
unit COMExEdit;



{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}
{ This is autogenerated code using the COMGuiGenerator. DO NOT MODIFY BY HAND }
{-----------------------------------------------------------------------------}
{-----------------------------------------------------------------------------}


{$WARN SYMBOL_PLATFORM OFF}

interface
uses
    ActiveX,Classes,COMExFont,COMExPopupMenu,ComObj,Controls,Exodus_TLB,Forms,Graphics,StdCtrls,StdVcl,TntMenus,TntStdCtrls;

type
    TExControlEdit = class(TAutoObject, IExodusControl, IExodusControlEdit)
    public
        constructor Create(control: TTntEdit);

    private
        _control: TTntEdit;

    protected
        function Get_ControlType: ExodusControlTypes; safecall;
        function Get_Name: Widestring; safecall;
        procedure Set_Name(const Value: Widestring); safecall;
        function Get_Tag: Integer; safecall;
        procedure Set_Tag(Value: Integer); safecall;
        function Get_Left: Integer; safecall;
        procedure Set_Left(Value: Integer); safecall;
        function Get_Top: Integer; safecall;
        procedure Set_Top(Value: Integer); safecall;
        function Get_Width: Integer; safecall;
        procedure Set_Width(Value: Integer); safecall;
        function Get_Height: Integer; safecall;
        procedure Set_Height(Value: Integer); safecall;
        function Get_Cursor: Integer; safecall;
        procedure Set_Cursor(Value: Integer); safecall;
        function Get_Hint: Widestring; safecall;
        procedure Set_Hint(const Value: Widestring); safecall;
        function Get_HelpType: Integer; safecall;
        procedure Set_HelpType(Value: Integer); safecall;
        function Get_HelpKeyword: Widestring; safecall;
        procedure Set_HelpKeyword(const Value: Widestring); safecall;
        function Get_HelpContext: Integer; safecall;
        procedure Set_HelpContext(Value: Integer); safecall;
        function Get_TabStop: Integer; safecall;
        procedure Set_TabStop(Value: Integer); safecall;
        function Get_AutoSelect: Integer; safecall;
        procedure Set_AutoSelect(Value: Integer); safecall;
        function Get_AutoSize: Integer; safecall;
        procedure Set_AutoSize(Value: Integer); safecall;
        function Get_BevelInner: Integer; safecall;
        procedure Set_BevelInner(Value: Integer); safecall;
        function Get_BevelKind: Integer; safecall;
        procedure Set_BevelKind(Value: Integer); safecall;
        function Get_BevelOuter: Integer; safecall;
        procedure Set_BevelOuter(Value: Integer); safecall;
        function Get_BiDiMode: Integer; safecall;
        procedure Set_BiDiMode(Value: Integer); safecall;
        function Get_BorderStyle: Integer; safecall;
        procedure Set_BorderStyle(Value: Integer); safecall;
        function Get_CharCase: Integer; safecall;
        procedure Set_CharCase(Value: Integer); safecall;
        function Get_Color: Integer; safecall;
        procedure Set_Color(Value: Integer); safecall;
        function Get_Ctl3D: Integer; safecall;
        procedure Set_Ctl3D(Value: Integer); safecall;
        function Get_DragCursor: Integer; safecall;
        procedure Set_DragCursor(Value: Integer); safecall;
        function Get_DragKind: Integer; safecall;
        procedure Set_DragKind(Value: Integer); safecall;
        function Get_DragMode: Integer; safecall;
        procedure Set_DragMode(Value: Integer); safecall;
        function Get_Enabled: Integer; safecall;
        procedure Set_Enabled(Value: Integer); safecall;
        function Get_Font: IExodusControlFont; safecall;
        function Get_HideSelection: Integer; safecall;
        procedure Set_HideSelection(Value: Integer); safecall;
        function Get_ImeMode: Integer; safecall;
        procedure Set_ImeMode(Value: Integer); safecall;
        function Get_ImeName: Widestring; safecall;
        procedure Set_ImeName(const Value: Widestring); safecall;
        function Get_MaxLength: Integer; safecall;
        procedure Set_MaxLength(Value: Integer); safecall;
        function Get_OEMConvert: Integer; safecall;
        procedure Set_OEMConvert(Value: Integer); safecall;
        function Get_ParentBiDiMode: Integer; safecall;
        procedure Set_ParentBiDiMode(Value: Integer); safecall;
        function Get_ParentColor: Integer; safecall;
        procedure Set_ParentColor(Value: Integer); safecall;
        function Get_ParentCtl3D: Integer; safecall;
        procedure Set_ParentCtl3D(Value: Integer); safecall;
        function Get_ParentFont: Integer; safecall;
        procedure Set_ParentFont(Value: Integer); safecall;
        function Get_ParentShowHint: Integer; safecall;
        procedure Set_ParentShowHint(Value: Integer); safecall;
        function Get_PasswordChar: Widestring; safecall;
        procedure Set_PasswordChar(const Value: Widestring); safecall;
        function Get_PopupMenu: IExodusControlPopupMenu; safecall;
        function Get_ReadOnly: Integer; safecall;
        procedure Set_ReadOnly(Value: Integer); safecall;
        function Get_ShowHint: Integer; safecall;
        procedure Set_ShowHint(Value: Integer); safecall;
        function Get_TabOrder: Integer; safecall;
        procedure Set_TabOrder(Value: Integer); safecall;
        function Get_Text: Widestring; safecall;
        procedure Set_Text(const Value: Widestring); safecall;
        function Get_Visible: Integer; safecall;
        procedure Set_Visible(Value: Integer); safecall;
    end;


{---------------------------------------}
{---------------------------------------}
{---------------------------------------}
implementation


constructor TExControlEdit.Create(control: TTntEdit);
begin
     _control := control; 
end;

function TExControlEdit.Get_ControlType: ExodusControlTypes;
begin
    Result := ExodusControlEdit;
end;

function TExControlEdit.Get_Name: Widestring;
begin
      Result := _control.Name;
end;

procedure TExControlEdit.Set_Name(const Value: Widestring);
begin
      _control.Name := Value;
end;

function TExControlEdit.Get_Tag: Integer;
begin
      Result := _control.Tag;
end;

procedure TExControlEdit.Set_Tag(Value: Integer);
begin
      _control.Tag := Value;
end;

function TExControlEdit.Get_Left: Integer;
begin
      Result := _control.Left;
end;

procedure TExControlEdit.Set_Left(Value: Integer);
begin
      _control.Left := Value;
end;

function TExControlEdit.Get_Top: Integer;
begin
      Result := _control.Top;
end;

procedure TExControlEdit.Set_Top(Value: Integer);
begin
      _control.Top := Value;
end;

function TExControlEdit.Get_Width: Integer;
begin
      Result := _control.Width;
end;

procedure TExControlEdit.Set_Width(Value: Integer);
begin
      _control.Width := Value;
end;

function TExControlEdit.Get_Height: Integer;
begin
      Result := _control.Height;
end;

procedure TExControlEdit.Set_Height(Value: Integer);
begin
      _control.Height := Value;
end;

function TExControlEdit.Get_Cursor: Integer;
begin
      Result := _control.Cursor;
end;

procedure TExControlEdit.Set_Cursor(Value: Integer);
begin
      _control.Cursor := Value;
end;

function TExControlEdit.Get_Hint: Widestring;
begin
      Result := _control.Hint;
end;

procedure TExControlEdit.Set_Hint(const Value: Widestring);
begin
      _control.Hint := Value;
end;

function TExControlEdit.Get_HelpType: Integer;
begin
    if (_control.HelpType = htKeyword) then Result := 0;
    if (_control.HelpType = htContext) then Result := 1;
end;

procedure TExControlEdit.Set_HelpType(Value: Integer);
begin
   if (Value = 0) then _control.HelpType := htKeyword;
   if (Value = 1) then _control.HelpType := htContext;
end;

function TExControlEdit.Get_HelpKeyword: Widestring;
begin
      Result := _control.HelpKeyword;
end;

procedure TExControlEdit.Set_HelpKeyword(const Value: Widestring);
begin
      _control.HelpKeyword := Value;
end;

function TExControlEdit.Get_HelpContext: Integer;
begin
      Result := _control.HelpContext;
end;

procedure TExControlEdit.Set_HelpContext(Value: Integer);
begin
      _control.HelpContext := Value;
end;

function TExControlEdit.Get_TabStop: Integer;
begin
    if (_control.TabStop = False) then Result := 0;
    if (_control.TabStop = True) then Result := 1;
end;

procedure TExControlEdit.Set_TabStop(Value: Integer);
begin
   if (Value = 0) then _control.TabStop := False;
   if (Value = 1) then _control.TabStop := True;
end;

function TExControlEdit.Get_AutoSelect: Integer;
begin
    if (_control.AutoSelect = False) then Result := 0;
    if (_control.AutoSelect = True) then Result := 1;
end;

procedure TExControlEdit.Set_AutoSelect(Value: Integer);
begin
   if (Value = 0) then _control.AutoSelect := False;
   if (Value = 1) then _control.AutoSelect := True;
end;

function TExControlEdit.Get_AutoSize: Integer;
begin
    if (_control.AutoSize = False) then Result := 0;
    if (_control.AutoSize = True) then Result := 1;
end;

procedure TExControlEdit.Set_AutoSize(Value: Integer);
begin
   if (Value = 0) then _control.AutoSize := False;
   if (Value = 1) then _control.AutoSize := True;
end;

function TExControlEdit.Get_BevelInner: Integer;
begin
    if (_control.BevelInner = bvNone) then Result := 0;
    if (_control.BevelInner = bvLowered) then Result := 1;
    if (_control.BevelInner = bvRaised) then Result := 2;
    if (_control.BevelInner = bvSpace) then Result := 3;
end;

procedure TExControlEdit.Set_BevelInner(Value: Integer);
begin
   if (Value = 0) then _control.BevelInner := bvNone;
   if (Value = 1) then _control.BevelInner := bvLowered;
   if (Value = 2) then _control.BevelInner := bvRaised;
   if (Value = 3) then _control.BevelInner := bvSpace;
end;

function TExControlEdit.Get_BevelKind: Integer;
begin
    if (_control.BevelKind = bkNone) then Result := 0;
    if (_control.BevelKind = bkTile) then Result := 1;
    if (_control.BevelKind = bkSoft) then Result := 2;
    if (_control.BevelKind = bkFlat) then Result := 3;
end;

procedure TExControlEdit.Set_BevelKind(Value: Integer);
begin
   if (Value = 0) then _control.BevelKind := bkNone;
   if (Value = 1) then _control.BevelKind := bkTile;
   if (Value = 2) then _control.BevelKind := bkSoft;
   if (Value = 3) then _control.BevelKind := bkFlat;
end;

function TExControlEdit.Get_BevelOuter: Integer;
begin
    if (_control.BevelOuter = bvNone) then Result := 0;
    if (_control.BevelOuter = bvLowered) then Result := 1;
    if (_control.BevelOuter = bvRaised) then Result := 2;
    if (_control.BevelOuter = bvSpace) then Result := 3;
end;

procedure TExControlEdit.Set_BevelOuter(Value: Integer);
begin
   if (Value = 0) then _control.BevelOuter := bvNone;
   if (Value = 1) then _control.BevelOuter := bvLowered;
   if (Value = 2) then _control.BevelOuter := bvRaised;
   if (Value = 3) then _control.BevelOuter := bvSpace;
end;

function TExControlEdit.Get_BiDiMode: Integer;
begin
    if (_control.BiDiMode = bdLeftToRight) then Result := 0;
    if (_control.BiDiMode = bdRightToLeft) then Result := 1;
    if (_control.BiDiMode = bdRightToLeftNoAlign) then Result := 2;
    if (_control.BiDiMode = bdRightToLeftReadingOnly) then Result := 3;
end;

procedure TExControlEdit.Set_BiDiMode(Value: Integer);
begin
   if (Value = 0) then _control.BiDiMode := bdLeftToRight;
   if (Value = 1) then _control.BiDiMode := bdRightToLeft;
   if (Value = 2) then _control.BiDiMode := bdRightToLeftNoAlign;
   if (Value = 3) then _control.BiDiMode := bdRightToLeftReadingOnly;
end;

function TExControlEdit.Get_BorderStyle: Integer;
begin
    if (_control.BorderStyle = bsNone) then Result := 0;
    if (_control.BorderStyle = bsSingle) then Result := 1;
end;

procedure TExControlEdit.Set_BorderStyle(Value: Integer);
begin
   if (Value = 0) then _control.BorderStyle := bsNone;
   if (Value = 1) then _control.BorderStyle := bsSingle;
end;

function TExControlEdit.Get_CharCase: Integer;
begin
    if (_control.CharCase = ecNormal) then Result := 0;
    if (_control.CharCase = ecUpperCase) then Result := 1;
    if (_control.CharCase = ecLowerCase) then Result := 2;
end;

procedure TExControlEdit.Set_CharCase(Value: Integer);
begin
   if (Value = 0) then _control.CharCase := ecNormal;
   if (Value = 1) then _control.CharCase := ecUpperCase;
   if (Value = 2) then _control.CharCase := ecLowerCase;
end;

function TExControlEdit.Get_Color: Integer;
begin
      Result := _control.Color;
end;

procedure TExControlEdit.Set_Color(Value: Integer);
begin
      _control.Color := Value;
end;

function TExControlEdit.Get_Ctl3D: Integer;
begin
    if (_control.Ctl3D = False) then Result := 0;
    if (_control.Ctl3D = True) then Result := 1;
end;

procedure TExControlEdit.Set_Ctl3D(Value: Integer);
begin
   if (Value = 0) then _control.Ctl3D := False;
   if (Value = 1) then _control.Ctl3D := True;
end;

function TExControlEdit.Get_DragCursor: Integer;
begin
      Result := _control.DragCursor;
end;

procedure TExControlEdit.Set_DragCursor(Value: Integer);
begin
      _control.DragCursor := Value;
end;

function TExControlEdit.Get_DragKind: Integer;
begin
    if (_control.DragKind = dkDrag) then Result := 0;
    if (_control.DragKind = dkDock) then Result := 1;
end;

procedure TExControlEdit.Set_DragKind(Value: Integer);
begin
   if (Value = 0) then _control.DragKind := dkDrag;
   if (Value = 1) then _control.DragKind := dkDock;
end;

function TExControlEdit.Get_DragMode: Integer;
begin
    if (_control.DragMode = dmManual) then Result := 0;
    if (_control.DragMode = dmAutomatic) then Result := 1;
end;

procedure TExControlEdit.Set_DragMode(Value: Integer);
begin
   if (Value = 0) then _control.DragMode := dmManual;
   if (Value = 1) then _control.DragMode := dmAutomatic;
end;

function TExControlEdit.Get_Enabled: Integer;
begin
    if (_control.Enabled = False) then Result := 0;
    if (_control.Enabled = True) then Result := 1;
end;

procedure TExControlEdit.Set_Enabled(Value: Integer);
begin
   if (Value = 0) then _control.Enabled := False;
   if (Value = 1) then _control.Enabled := True;
end;

function TExControlEdit.Get_Font: IExodusControlFont;
begin
      Result := TExControlFont.Create(TFont(_control.Font));
end;

function TExControlEdit.Get_HideSelection: Integer;
begin
    if (_control.HideSelection = False) then Result := 0;
    if (_control.HideSelection = True) then Result := 1;
end;

procedure TExControlEdit.Set_HideSelection(Value: Integer);
begin
   if (Value = 0) then _control.HideSelection := False;
   if (Value = 1) then _control.HideSelection := True;
end;

function TExControlEdit.Get_ImeMode: Integer;
begin
    if (_control.ImeMode = imDisable) then Result := 0;
    if (_control.ImeMode = imClose) then Result := 1;
    if (_control.ImeMode = imOpen) then Result := 2;
    if (_control.ImeMode = imDontCare) then Result := 3;
    if (_control.ImeMode = imSAlpha) then Result := 4;
    if (_control.ImeMode = imAlpha) then Result := 5;
    if (_control.ImeMode = imHira) then Result := 6;
    if (_control.ImeMode = imSKata) then Result := 7;
    if (_control.ImeMode = imKata) then Result := 8;
    if (_control.ImeMode = imChinese) then Result := 9;
    if (_control.ImeMode = imSHanguel) then Result := 10;
    if (_control.ImeMode = imHanguel) then Result := 11;
end;

procedure TExControlEdit.Set_ImeMode(Value: Integer);
begin
   if (Value = 0) then _control.ImeMode := imDisable;
   if (Value = 1) then _control.ImeMode := imClose;
   if (Value = 2) then _control.ImeMode := imOpen;
   if (Value = 3) then _control.ImeMode := imDontCare;
   if (Value = 4) then _control.ImeMode := imSAlpha;
   if (Value = 5) then _control.ImeMode := imAlpha;
   if (Value = 6) then _control.ImeMode := imHira;
   if (Value = 7) then _control.ImeMode := imSKata;
   if (Value = 8) then _control.ImeMode := imKata;
   if (Value = 9) then _control.ImeMode := imChinese;
   if (Value = 10) then _control.ImeMode := imSHanguel;
   if (Value = 11) then _control.ImeMode := imHanguel;
end;

function TExControlEdit.Get_ImeName: Widestring;
begin
      Result := _control.ImeName;
end;

procedure TExControlEdit.Set_ImeName(const Value: Widestring);
begin
      _control.ImeName := Value;
end;

function TExControlEdit.Get_MaxLength: Integer;
begin
      Result := _control.MaxLength;
end;

procedure TExControlEdit.Set_MaxLength(Value: Integer);
begin
      _control.MaxLength := Value;
end;

function TExControlEdit.Get_OEMConvert: Integer;
begin
    if (_control.OEMConvert = False) then Result := 0;
    if (_control.OEMConvert = True) then Result := 1;
end;

procedure TExControlEdit.Set_OEMConvert(Value: Integer);
begin
   if (Value = 0) then _control.OEMConvert := False;
   if (Value = 1) then _control.OEMConvert := True;
end;

function TExControlEdit.Get_ParentBiDiMode: Integer;
begin
    if (_control.ParentBiDiMode = False) then Result := 0;
    if (_control.ParentBiDiMode = True) then Result := 1;
end;

procedure TExControlEdit.Set_ParentBiDiMode(Value: Integer);
begin
   if (Value = 0) then _control.ParentBiDiMode := False;
   if (Value = 1) then _control.ParentBiDiMode := True;
end;

function TExControlEdit.Get_ParentColor: Integer;
begin
    if (_control.ParentColor = False) then Result := 0;
    if (_control.ParentColor = True) then Result := 1;
end;

procedure TExControlEdit.Set_ParentColor(Value: Integer);
begin
   if (Value = 0) then _control.ParentColor := False;
   if (Value = 1) then _control.ParentColor := True;
end;

function TExControlEdit.Get_ParentCtl3D: Integer;
begin
    if (_control.ParentCtl3D = False) then Result := 0;
    if (_control.ParentCtl3D = True) then Result := 1;
end;

procedure TExControlEdit.Set_ParentCtl3D(Value: Integer);
begin
   if (Value = 0) then _control.ParentCtl3D := False;
   if (Value = 1) then _control.ParentCtl3D := True;
end;

function TExControlEdit.Get_ParentFont: Integer;
begin
    if (_control.ParentFont = False) then Result := 0;
    if (_control.ParentFont = True) then Result := 1;
end;

procedure TExControlEdit.Set_ParentFont(Value: Integer);
begin
   if (Value = 0) then _control.ParentFont := False;
   if (Value = 1) then _control.ParentFont := True;
end;

function TExControlEdit.Get_ParentShowHint: Integer;
begin
    if (_control.ParentShowHint = False) then Result := 0;
    if (_control.ParentShowHint = True) then Result := 1;
end;

procedure TExControlEdit.Set_ParentShowHint(Value: Integer);
begin
   if (Value = 0) then _control.ParentShowHint := False;
   if (Value = 1) then _control.ParentShowHint := True;
end;

function TExControlEdit.Get_PasswordChar: Widestring;
begin
      Result := _control.PasswordChar;
end;

procedure TExControlEdit.Set_PasswordChar(const Value: Widestring);
begin
      _control.PasswordChar := Widestring(Value)[1];
end;

function TExControlEdit.Get_PopupMenu: IExodusControlPopupMenu;
begin
      Result := TExControlPopupMenu.Create(TTntPopupMenu(_control.PopupMenu));
end;

function TExControlEdit.Get_ReadOnly: Integer;
begin
    if (_control.ReadOnly = False) then Result := 0;
    if (_control.ReadOnly = True) then Result := 1;
end;

procedure TExControlEdit.Set_ReadOnly(Value: Integer);
begin
   if (Value = 0) then _control.ReadOnly := False;
   if (Value = 1) then _control.ReadOnly := True;
end;

function TExControlEdit.Get_ShowHint: Integer;
begin
    if (_control.ShowHint = False) then Result := 0;
    if (_control.ShowHint = True) then Result := 1;
end;

procedure TExControlEdit.Set_ShowHint(Value: Integer);
begin
   if (Value = 0) then _control.ShowHint := False;
   if (Value = 1) then _control.ShowHint := True;
end;

function TExControlEdit.Get_TabOrder: Integer;
begin
      Result := _control.TabOrder;
end;

procedure TExControlEdit.Set_TabOrder(Value: Integer);
begin
      _control.TabOrder := Value;
end;

function TExControlEdit.Get_Text: Widestring;
begin
      Result := _control.Text;
end;

procedure TExControlEdit.Set_Text(const Value: Widestring);
begin
      _control.Text := Value;
end;

function TExControlEdit.Get_Visible: Integer;
begin
    if (_control.Visible = False) then Result := 0;
    if (_control.Visible = True) then Result := 1;
end;

procedure TExControlEdit.Set_Visible(Value: Integer);
begin
   if (Value = 0) then _control.Visible := False;
   if (Value = 1) then _control.Visible := True;
end;




end.
