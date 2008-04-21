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

unit ExTreeView;

interface

uses
  SysUtils, Classes, Controls, TntComCtrls, XMLTag, Exodus_TLB,
  GroupParser, Types, ComCtrls, Contnrs, Messages, Unicode;

type

  TExTreeView = class(TTntTreeView)
  private
      { Private declarations }
      _JS: TObject;
      _SessionCB: Integer;
      _RosterCB: Integer;
      _DataCB: Integer;
      _GroupParser: TGroupParser;
      _StatusColor: Integer;
      _TotalsColor: Integer;
      _InactiveColor: Integer;
      _ShowGroupTotals: Boolean;
      _ShowStatus: Boolean;
      _CurrentNode: TTntTreeNode;
      _GroupSeparator: WideChar;
      _TabIndex: Integer;

      //Methods
      procedure _RosterCallback(Event: string; Item: IExodusItem);
      procedure _SessionCallback(Event: string; Tag: TXMLTag);
      procedure _GroupCallback(Event: string; Tag: TXMLTag; Data: WideString);

      procedure _GetActionableItems(items: IExodusItemList; node: TTntTreeNode);
      function _GetNodeByUID(UID: WideString) : TTntTreeNode;
  protected
      { Protected declarations }
      function  AddItemNode(Item: IExodusItem): TTntTreeNode;virtual;
      function  GetItemNodes(Uid: WideString) : TObjectList; virtual;
      procedure UpdateItemNodes(Item: IExodusItem); virtual;
      procedure RemoveItemNodes(Item: IExodusItem); virtual;
      procedure UpdateItemNode(Node: TTntTreeNode); virtual;
      function  GetActiveCounts(Node: TTntTreeNode): Integer; virtual;
      function  GetLeavesCounts(Node: TTntTreeNode): Integer; virtual;
      procedure SaveGroupsState(); virtual;
      procedure RestoreGroupsState(); virtual;
      procedure CustomDrawItem(Sender: TCustomTreeView;
                               Node: TTreeNode;
                               State: TCustomDrawState;
                               var DefaultDraw: Boolean); virtual;
      procedure DrawNodeText(Node: TTntTreeNode;
                             State: TCustomDrawState;
                             Text, ExtendedText: Widestring);  virtual;
      procedure Editing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
      function  FilterItem(Item: IExodusItem): Boolean; virtual;
  public
      { Public declarations }
      constructor Create(AOwner: TComponent; Session: TObject); virtual;
      procedure CreateParams(var Params: TCreateParams); override;
      destructor Destroy(); override;
      procedure MouseDown(Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);  override;
      function  GetNodePath(Node: TTntTreeNode): WideString; virtual;
      procedure DblClick(); override;
      function  GetSubgroups(Group: WideString): TWideStringList; virtual;
      function  GetSelectedItems(): IExodusItemList; virtual;
      //Properties
      property Session: TObject read _JS write _JS;
      procedure SetFontsAndColors();

      procedure Refresh();
      //Properties
      property TabIndex: Integer read _TabIndex write _TabIndex;

  end;

//procedure Register;

implementation
uses Session, Graphics, Windows, ExUtils, CommCtrl, Jabber1,
     RosterImages, JabberID, ContactController, COMExodusItem, COMExodusItemList,
     ChatWin, GroupInfo, Room, Forms,
     ActionMenus, ExActionCtrl, TntMenus,
     gnugettext;

procedure TExTreeView.CreateParams(var Params: TCreateParams);
begin
    inherited CreateParams(Params);
    Params.Style := Params.Style or $8000;
end;

{---------------------------------------}
constructor TExTreeView.Create(AOwner: TComponent; Session: TObject);
var
    popup: TExActionPopupMenu;
    mi: TTntMenuItem;
begin
    inherited Create(AOwner);

    Align := alClient;
    Anchors := [akLeft, akTop, akRight, akBottom];
    BorderStyle := bsNone;
    ShowButtons := true;    //buttons are owner-drawn (at least on XP)
    ShowLines := false;
    AutoExpand := false;
    HideSelection := false;
    MultiSelect := true;
    MultiSelectStyle := [msControlSelect, msShiftSelect, msVisibleOnly];
    RowSelect := false;
    SortType := stText;
    OnCustomDrawItem := CustomDrawItem;
    OnEditing := Editing;

    popup := TExActionPopupMenu.Create(Self);
    popup.ActionController := GetActionController();
    mi := TTntMenuItem.Create(popup.Items);
    mi.Caption := _('Move...');
    mi.OnClick := nil;
    popup.Items.Add(mi);
    mi := TTntMenuItem.Create(popup.Items);
    mi.Caption := _('Copy...');
    mi.OnClick := nil;
    popup.Items.Add(mi);
    mi := TTntMenuItem.Create(popup.Items);
    mi.Caption := _('Delete');
    mi.OnClick := nil;
    popup.Items.Add(mi);
    PopupMenu := popup;

    _JS :=  TJabberSession(Session);
    _RosterCB := TJabberSession(_JS).RegisterCallback(_RosterCallback, '/item');
    _SessionCB := TJabberSession(_JS).RegisterCallback(_SessionCallback, '/session');
    _DataCB := TJabberSession(_JS).RegisterCallback(_GroupCallback);
    _GroupSeparator := PWideChar(TJabberSession(_JS).Prefs.getString('group_seperator'))^;

    _GroupParser := TGroupParser.Create(_JS);
    _TotalsColor := TColor(RGB(130,143,154 ));
    _InactiveColor := TColor(RGB(130,143,154 ));
    Perform(TVM_SETITEMHEIGHT, -1, 0);
    _CurrentNode := nil;
    _TabIndex := -1;
end;

{---------------------------------------}
destructor TExTreeView.Destroy();
begin
    with TJabberSession(_js) do begin
        UnregisterCallback(_SessionCB);
        UnregisterCallback(_RosterCB);
        UnregisterCallback(_DataCB);
    end;
   _GroupParser.Free;

   inherited;
end;

{---------------------------------------}
procedure TExTreeView.SetFontsAndColors();
begin
    //Initialize fonts and colors
    _StatusColor := TColor(TJabberSession(_JS).Prefs.getInt('inline_color'));
    Color := TColor(TJabberSession(_JS).prefs.getInt('roster_bg'));
    Font.Name := TJabberSession(_JS).prefs.getString('roster_font_name');
    Font.Size := TJabberSession(_JS).prefs.getInt('roster_font_size');
    Font.Color := TColor(TJabberSession(_JS).prefs.getInt('roster_font_color'));
    Font.Charset := TJabberSession(_JS).prefs.getInt('roster_font_charset');
    Font.Style := [];
    if (TJabberSession(_JS).prefs.getBool('font_bold')) then
        Font.Style := Font.Style + [fsBold];
    if (TJabberSession(_JS).prefs.getBool('font_italic')) then
        Font.Style := Font.Style + [fsItalic];
    if (TJabberSession(_JS).prefs.getBool('font_underline')) then
        Font.Style := Font.Style + [fsUnderline];
    _ShowGroupTotals := TJabberSession(_JS).prefs.getBool('roster_groupcounts');
    _ShowStatus := TJabberSession(_JS).prefs.getBool('inline_status');
end;

{---------------------------------------}
procedure TExTreeView._RosterCallback(Event: string; Item: IExodusItem);
begin
  if Event = '/item/begin' then begin
      Self.Items.BeginUpdate;
      exit;
  end;
  if event = '/item/end' then begin
     Self.Items.EndUpdate;
     exit;
  end;

  if (FilterItem(Item) = false) then
      exit;

  if Event = '/item/add' then begin
         AddItemNode(Item);
     exit;
  end;
  if Event = '/item/update' then begin
     DebugMsg('received /item/update for ' + item.UID);
     if (Item.Type_ <> EI_TYPE_GROUP) then
         UpdateItemNodes(Item);
     exit;
  end;
  if event = '/item/remove' then begin
     if (Item.Type_ <> EI_TYPE_GROUP) then
         RemoveItemNodes(Item);
     exit;
  end;


end;

{---------------------------------------}
procedure TExTreeView._SessionCallback(Event: string; Tag: TXMLTag);
begin
     //Force repaing if prefs have changed.
     if Event = '/session/prefs' then
     begin
         SetFontsAndColors();
         Invalidate();
     end
     else if (Event = '/session/disconnecting') then
     begin
         SaveGroupsState();
     end;
          
end;

{---------------------------------------}
procedure TExTreeView._GroupCallback(Event: string; Tag: TXMLTag; Data: WideString);
begin
    if Event = '/data/item/group/save' then
        SaveGroupsState()
    else
        if Event = '/data/item/group/restore' then
            RestoreGroupsState();

end;

{---------------------------------------}
function TExTreeView.AddItemNode(Item: IExodusItem): TTntTreeNode;
var
    Parent, Group, Node: TTntTreeNode;
    GroupItem: IExodusItem;
    i: Integer;
begin
    Result := nil;
    //Remove all nodes pointing to the item
    if (Item.Type_ <> EI_TYPE_GROUP) then
        RemoveItemNodes(Item);

    if (Item.GroupCount = 0) then
    begin
        Node := _GetNodeByUID(Item.UID);
        if (Node = nil) then
        begin
              Node := TTntTreeNode.Create(Items);
              Node.Data := Pointer(Item);
              Node.Text := Item.Text;
              Items.AddNode(Node, nil, Item.Text, Pointer(Item), naAddChild);
              if (TJabberSession(_js).ItemController.GroupExpanded[Item.UID]) then
                  Node.Expand(false)
              else
                  Node.Collapse(false);
        end;
        Result := Node;
        exit;
    end;
    //Iterate through list of groups and make sure group exists
    for i := 0 to Item.GroupCount - 1 do
    begin
        //Check if group node exists
        Group := _GetNodeByUID(Item.Group[i]);
        //If group does not exists, create node.
        if (Group = nil) then
        begin
            //Group := AddNodeByName(Item);
            GroupItem := TJabberSession(_JS).ItemController.GetItem(Item.Group[i]);
            Group := AddItemNode(GroupItem);
        end;

        //Add item to the group
        Node := _GetNodeByUID(Item.UID);
        if (Node = nil) then
        begin
            Node := TTntTreeNode.Create(Items);
            Node.Data := Pointer(Item);
            Node.Text := Item.Text;
            Items.AddNode(Node, Group, Item.Text, Pointer(Item), naAddChild);
            if (TJabberSession(_js).ItemController.GroupExpanded[Item.Group[i]]) then
                Group.Expand(false)
            else
                Group.Collapse(false);
        end;
        if (Item.Type_ <> EI_TYPE_GROUP) then
            UpdateItemNode(Node);
        Result := Node;
    end;

end;


{---------------------------------------}
//Returns a list of nodes for the given uid.
function TExTreeView.GetItemNodes(Uid: WideString) : TObjectList;
var
    i:Integer;
    Item: IExodusItem;
begin
    Result := TObjectList.Create();
    try
        for i := 0 to Items.Count - 1 do
        begin
           //Find non-group nodes
           if (IExodusItem(Items[i].Data).Type_ <> EI_TYPE_GROUP) then
           begin
              Item := IExodusItem(Items[i].Data);
              if (Item.Uid = Uid) then
                  Result.Add(Items[i]);
           end;
        end;
    except

    end;

end;

{---------------------------------------}
//Perform repainting for all the nodes for the given item.
procedure TExTreeView.UpdateItemNodes(Item: IExodusItem);
var
    Nodes: TObjectList;
    i: Integer;
begin
    if (Item = nil) then exit;
    Nodes := GetItemNodes(Item.Uid);
    for i := 0 to Nodes.Count - 1 do
       UpdateItemNode(TTntTreeNode(Nodes[i]));
end;

{---------------------------------------}
//Removes all the nodes for the given item.
procedure TExTreeView.RemoveItemNodes(Item: IExodusItem);
var
    i:Integer;
    CurrentItem: IExodusItem;
begin
    try
        for i := Items.Count - 1 downto 0 do
        begin
           //Find non-group nodes
           if (IExodusItem(Items[i].Data).Type_ <> EI_TYPE_GROUP) then
           begin
              CurrentItem := IExodusItem(Items[i].Data);
              if (CurrentItem.Uid = Item.Uid) then
                  Items.Delete(Items[i]);
           end;
        end;
    except

    end;
end;

{---------------------------------------}
//Repaint given node and all it's ancestors.
procedure TExTreeView.UpdateItemNode(Node: TTntTreeNode);
var
    Rect: TRect;
begin
    //Update all ancestors for the node if showing totals
    Rect := Node.DisplayRect(false);
    InvalidateRect(Handle, @Rect, true);
    Node := Node.Parent;
    while (Node <> nil) do
    begin
        UpdateItemNode(Node);
        Node := Node.parent;
    end;
end;

{---------------------------------------}
//This recursive function counts totals
//for active items in the given group node.
function  TExTreeView.GetActiveCounts(Node: TTntTreeNode): Integer;
var
    Child: TTntTreeNode;
    Item: IExodusItem;
begin
    if (Node.Data = nil) then exit;
    if (IExodusItem(Node.Data).Type_ <> EI_TYPE_GROUP) then
    begin
        //If it is a leaf, end recursion.
        item := IExodusItem(node.Data);
        if (item.Active) then
            Result := 1
        else
            Result := 0;
        exit;
    end;

    //Iterate through children and accumulate
    //totals for active for each child.
    Result := 0;
    Child := Node.GetFirstChild();
    while (Child <> nil) do
    begin
        //The following statement takes care of nested group totals.
        Result := Result + GetActiveCounts(Child);
        Child := Node.GetNextChild(Child);
    end;
end;

{---------------------------------------}
//This recursive function counts totals
//for total number of items in the given group node.
function  TExTreeView.GetLeavesCounts(Node: TTntTreeNode): Integer;
var
    Child: TTntTreeNode;
begin
    if (Node.Data = nil) then exit;
    
    if (IExodusItem(Node.Data).Type_ <> EI_TYPE_GROUP) then
    //If it is a leaf, end recursion.
    begin
        Result := 1;
        exit;
    end;

    //Iterate through children and accumulate
    //totals for each child.
    Result := 0;
    Child := node.GetFirstChild();
    while (child <> nil) do
    begin
        //The following statement takes care of nested group totals.
        Result := Result + GetLeavesCounts(Child);
        Child := Node.GetNextChild(child);
    end;
end;

{---------------------------------------}
//This recursive function returns full group name path for the nested groups
function  TExTreeView.GetNodePath(Node: TTntTreeNode): WideString;
begin
    if (Node = nil) then exit;

    if (Node.Parent <> nil) then
        Result := GetNodePath(Node.Parent) + _GroupSeparator + Node.Text
    else
        Result := Node.Text;

end;

{---------------------------------------}
//Returns the list of immediate subgroups
function  TExTreeView.GetSubgroups(Group: WideString): TWideStringList;
var
   Subgroups: TWideStringList;
   GroupNode, ChildNode: TTntTreeNode;
begin
   Subgroups := TWideStringList.Create();
   Result := Subgroups;
   GroupNode := _GetNodeByUID(Group);
   if (GroupNode = nil) then
       exit;
   if (IExodusItem(GroupNode.Data).Type_ <> EI_TYPE_GROUP) then
       exit;
   ChildNode := GroupNode.GetFirstChild();
   while (ChildNode <> nil) do
   begin
      if (IExodusItem(ChildNode.Data).Type_ = EI_TYPE_GROUP) then
          Subgroups.Add(ChildNode.Text);

      ChildNode := GroupNode.GetNextChild(ChildNode);
   end;
end;

{---------------------------------------}
//Iterates thorugh all the nodes and saves exapanded state for group nodes.
procedure  TExTreeView.SaveGroupsState();
var
    i: Integer;
    Name: WideString;
begin
    for i := 0 to Items.Count - 1 do
    begin

        if (IExodusItem(Items[i].Data).Type_ <> EI_TYPE_GROUP) then
            continue;
        Name := GetNodePath(Items[i]);
        TJabberSession(_js).ItemController.GroupExpanded[Name] := Items[i].Expanded;
    end;

    TJabberSession(_js).ItemController.SaveGroups();

end;

{---------------------------------------}
//Iterates thorugh all the nodes and restores expanded/collapsed state for the group.
procedure  TExTreeView.RestoreGroupsState();
var
    Expanded: Boolean;
    Name: WideString;
    i: Integer;
    Root: TTntTreeNode;
begin
     for i := 0 to Items.Count - 1 do
     begin
       if (IExodusItem(Items[i].Data).Type_ <> EI_TYPE_GROUP) then continue;
       Name := GetNodePath(Items[i]);
       Expanded := TJabberSession(_js).ItemController.GroupExpanded[Name];
       if (Expanded) then
           Items[i].Expand(false)
       else
           Items[i].Collapse(false);
    end;
end;

{---------------------------------------}
//This function figures out all the pieces
//to perform custom drawing for the individual node.
procedure TExTreeView.CustomDrawItem(Sender: TCustomTreeView;
                                     Node: TTreeNode;
                                     State: TCustomDrawState;
                                     var DefaultDraw: Boolean);
var
    Text, ExtendedText: WideString;
    IsGroup: Boolean;
    Item: IExodusItem;
begin
    // Perform initialization
    if (Node = nil) then exit;
    if (Node.Data = nil) then exit;
    if (IExodusItem(Node.Data).Type_ = '') then exit;
    
    if (not Node.IsVisible) then exit;
    Item := nil;
    DefaultDraw := false;
    Text := '';
    ExtendedText := '';

    //If there is no data attached to the node, it is a group.
    if (IExodusItem(Node.Data).Type_ = EI_TYPE_GROUP) then
        IsGroup := true
    else
    begin
        IsGroup := false;
        Item := IExodusItem(Node.Data);
    end;

   if (IsGroup) then
   begin
       //Set extended text for totals for the groups, if required.
       Text := Node.Text;
       if (_ShowGroupTotals) then
          ExtendedText := '(' + IntToStr(GetActiveCounts(TTntTreeNode(Node))) + ' of '+ IntToStr(GetLeavesCounts(TTntTreeNode(Node))) + ' online)';
   end
   else
   begin
       if (Item <> nil) then
       begin
           //Set extended text for status for the node, if required.
           Text := Item.Text;
           if (_ShowStatus) then
               if (WideTrim(Item.ExtendedText) <> '') then
                   ExtendedText := ' - ' + Item.ExtendedText;
       end;
    end;

    DrawNodeText(TTntTreeNode(Node), State, Text, ExtendedText);
end;

{---------------------------------------}
//Performs drawing of text and images for the given node.
procedure TExTreeView.DrawNodeText(Node: TTntTreeNode; State: TCustomDrawState;
    Text, ExtendedText: Widestring);
var
    RightEdge, MaxRight, Arrow, Folder, TextWidth: integer;
    ImgRect, TxtRect, NodeRect, NodeFullRow: TRect;
    MainColor, StatColor, TotalsColor, InactiveColor: TColor;
    IsGroup: boolean;
    Item: IExodusItem;

begin

    Item := nil;
    //Save string width and height for the node text
    TextWidth := CanvasTextWidthW(Canvas, Text);
    //Set group flag based on presence of data attached.
    if (Node.Data = nil) then exit;
    
    if (IExodusItem(Node.Data).Type_ = EI_TYPE_GROUP) then
       IsGroup := true
    else
    begin
       IsGroup := false;
       Item := IExodusItem(Node.Data);
    end;

    //Get default rectangle for the node
    NodeRect := Node.DisplayRect(true);
    NodeFullRow := NodeRect;
    NodeFullRow.Left := 0;
    NodeFullRow.Right := ClientWidth - 2;
    Canvas.Font.Color := Font.Color;
    Canvas.Brush.Color := Color;
    Canvas.FillRect(NodeFullRow);
    //Shift to the right to support two group icons for all groups
    NodeRect.Left := NodeRect.Left + Indent;
    NodeRect.Right := NodeRect.Right + Indent;
    TxtRect := NodeRect;
    ImgRect := NodeRect;
    RightEdge := nodeRect.Left + TextWidth + 2 + CanvasTextWidthW(Canvas, (ExtendedText + ' '));
    MaxRight := ClientWidth - 2;

    // make sure our rect isn't bigger than the treeview
    if (RightEdge >= MaxRight) then
        TxtRect.Right := MaxRight
    else
        TxtRect.Right := RightEdge;

    ImgRect.Left := ImgRect.Left - (2*Indent);

    Canvas.Font.Style := Self.Font.Style;
    // if selected, draw a solid rect
    if (cdsSelected in State) then
    begin
        Canvas.Font.Color := clHighlightText;
        Canvas.Brush.Color := clHighlight;
        Canvas.FillRect(TxtRect);
    end;

    if (IsGroup) then
    begin
        // this is a group
        if (Node.Expanded) then
        begin
            Arrow := RosterTreeImages.Find(RI_OPENGROUP_KEY);
            Folder := RosterTreeImages.Find(RI_FOLDER_OPEN_KEY);
        end
        else
        begin
            Arrow := RosterTreeImages.Find(RI_CLOSEDGROUP_KEY);
            Folder := RosterTreeImages.Find(RI_FOLDER_CLOSED_KEY);
        end;
        //Groups have two images
        //Draw > image
        frmExodus.ImageList1.Draw(Canvas,
                                  ImgRect.Left,
                                  ImgRect.Top, Arrow);
        //Move to the second image drawing
        ImgRect.Left := ImgRect.Left + Indent;
        //Draw second image
        frmExodus.ImageList1.Draw(Canvas,
                                  ImgRect.Left,
                                  ImgRect.Top, Folder);
    end
    else
        //Draw image for the item
        frmExodus.ImageList1.Draw(Canvas,
                                  ImgRect.Left + Indent,
                                  ImgRect.Top, Item.ImageIndex);


    // draw the text
    if (cdsSelected in State) then
    begin
        // Draw the focus box.
        Canvas.DrawFocusRect(TxtRect);
        MainColor := clHighlightText;
        StatColor := MainColor;
        TotalsColor := MainColor;
        InactiveColor := MainColor;
    end
    else
    begin
        MainColor := Canvas.Font.Color;
        StatColor := _StatusColor;
        TotalsColor := _TotalsColor;
        InactiveColor := _InactiveColor;
    end;

    //Figure out color for the node.
    if (IsGroup) then
       SetTextColor(Canvas.Handle, ColorToRGB(MainColor))
    else
       if (Item.Active) then
           SetTextColor(Canvas.Handle, ColorToRGB(MainColor))
       else
           SetTextColor(Canvas.Handle, ColorToRGB(InactiveColor));

    //Draw basic node text
    CanvasTextOutW(Canvas, TxtRect.Left + 1,  TxtRect.Top, Text, MaxRight);

    //Draw additional node text, if required.
    if (ExtendedText <> '') then begin
        if (IsGroup) then
            SetTextColor(Canvas.Handle, ColorToRGB(TotalsColor))
        else
            SetTextColor(Canvas.Handle, ColorToRGB(StatColor));

        CanvasTextOutW(Canvas, txtRect.Left + TextWidth + 4, TxtRect.Top, ExtendedText, MaxRight);
    end;

end;

{---------------------------------------}
procedure TExTreeView.DblClick();
var
    Item: IExodusItem;
    Nick, RegNick: WideString;
    UseRegNick: Boolean;
begin
    OutputDebugMsg('tree double-click event!');
    //inherited;

    if (_CurrentNode = nil) then exit;
    if (IExodusItem(_CurrentNode.Data).Type_ <> EI_TYPE_GROUP) then

    //Non-group node
    begin
        Item := IExodusItem(_CurrentNode.Data);
        if (Item.Type_ = EI_TYPE_CONTACT) then
        begin
            StartChat(Item.UID, '', true);
        end
        else if (Item.Type_ = EI_TYPE_ROOM) then
        begin
            try
               Nick := Item.value['nick'];
            except
            end;
            try
               RegNick := Item.value['reg_nick'];
            except
            end;
            if (RegNick = 'true') then
                UseRegNick := true
            else
                UseRegNick := false;

            StartRoom(Item.UID, Nick, '', true, false, UseRegNick);
        end;
    end;
end;

procedure TExTreeView.MouseDown(Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
var
  NodeRect: TRect;
  node: TTntTreeNode;
  hits: THitTests;
begin
    // check to see if we're hitting a button
    node := GetNodeAt(X, Y);
    if (node = nil) then begin
        Selected := nil;
        exit;
    end;
    hits := GetHitTestInfoAt(X, Y);
    if ((hits = [htOnButton]) or (hits = [htOnIndent])) then begin
        Selected := nil;
        exit;
    end;

    // if we have a legit node.... make sure it's selected..
    if not (ssShift in Shift) and not (ssCtrl in Shift) then begin
        if (Selected <> node) then
            Select(node, Shift);
    end;

    _CurrentNode := node;
{
    if (_CurrentNode <> nil) then begin
        //Obtain node coordinates
        //NodeRect := _CurrentNode.DisplayRect(true);
        //Save mouse down event information for the future handling
        _LastMouseEvent.X := X;
        _LastMouseEvent.Y := Y;
        _LastMouseEvent.Button := Button;
        //We need to save expanded state for the node on the
        //"Mouse Down" event since tree control it trying to
        //expand/collapse node if mouse down event is part of
        //double click chain of events.
        //_LastMouseEvent.Expanded := _CurrentNode.Expanded;
    end;
}
end;

{---------------------------------------}
procedure TExTreeView.Editing(Sender: TObject; Node: TTreeNode; var AllowEdit: Boolean);
begin
     AllowEdit := false;
end;

{---------------------------------------}
function  TExTreeView.FilterItem(Item: IExodusItem): Boolean;
begin
    Result := true;
end;

procedure TExTreeView._GetActionableItems(items: IExodusItemList; node: TTntTreeNode);
var
    item: IExodusItem;

    procedure recurseNode();
    var
        idx: Integer;
    begin
        for idx := 0 to node.Count - 1 do begin
            _GetActionableItems(items, node.Item[idx]);
        end;
    end;
begin
    if (node.Data = nil) then begin
        recurseNode();
    end else begin
        item := IExodusItem(node.Data);

        if (item.Type_ = 'group') then begin
            if node.Selected and item.IsVisible then items.Add(item);
            recurseNode();
        end
        else if item.IsVisible then items.Add(item);
    end;

end;

function TExTreeView._GetNodeByUID(UID: WideString) : TTntTreeNode;
var
    i: Integer;
begin
    Result := nil;
    for i := 0 to Items.Count - 1 do
    begin
       if (Items[i].Data = nil) then continue;
       if (IExodusItem(Items[i].Data).UID = UID) then
       begin
          Result := Items[i];
          break;
       end;
       
    end;
      
end;


function TExTreeView.GetSelectedItems(): IExodusItemList;
var
    idx: Integer;
begin
    Result := TExodusItemList.Create() as IExodusItemList;

    for idx := 0 to SelectionCount - 1 do begin
        _GetActionableItems(Result, Selections[idx]);
    end;
end;

procedure TExTreeView.Refresh;
var
    itemCtrl: IExodusItemController;
    item: IExodusItem;
    idx: Integer;
begin
    Items.Clear();

    //TODO:  make this use a local variable??
    itemCtrl := TJabberSession(_JS).ItemController;
    for idx := 0 to itemCtrl.ItemsCount - 1 do begin
        item := itemCtrl.Item[idx];

        if not FilterItem(item) then continue;

        AddItemNode(item);
    end;
end;

end.
