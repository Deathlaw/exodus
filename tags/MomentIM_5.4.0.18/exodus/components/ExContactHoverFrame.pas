unit ExContactHoverFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ExFrame, StdCtrls, ExtCtrls, ExGraphicButton, Exodus_TLB, ActnList,
  ExBrandPanel, ExGroupBox, TntStdCtrls, Avatar, XMLVCard;

type
  TExContactHoverFrame = class(TExFrame)
    lblDisplayName: TTntLabel;
    lblUID: TTntLabel;
    btnRename: TExGraphicButton;
    btnDelete: TExGraphicButton;
    btnChat: TExGraphicButton;
    imgPresence: TImage;
    lblPresence: TTntLabel;
    Separator2: TExGroupBox;
    Separator1: TExGroupBox;
    imgAvatar: TPaintBox;
    lblPhone: TTntLabel;
    procedure TntFrameMouseLeave(Sender: TObject);
    procedure TntFrameMouseEnter(Sender: TObject);
    procedure InitControls(Item: IExodusItem);
    procedure btnChatClick(Sender: TObject);
    procedure TntFrameMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgAvatarMouseEnter(Sender: TObject);
    procedure imgAvatarMouseLeave(Sender: TObject);
    procedure TnTLabel1MouseLeave(Sender: TObject);
    procedure imgPresenceMouseEnter(Sender: TObject);
    procedure imgPresenceMouseLeave(Sender: TObject);
    procedure lblDisplayNameMouseEnter(Sender: TObject);
    procedure lblDisplayNameMouseLeave(Sender: TObject);
    procedure lblPresenceMouseEnter(Sender: TObject);
    procedure lblUIDMouseEnter(Sender: TObject);
    procedure lblUIDMouseLeave(Sender: TObject);
    procedure TnTLabel1MouseEnter(Sender: TObject);
    procedure lblPresenceMouseLeave(Sender: TObject);
    procedure btnChatMouseEnter(Sender: TObject);
    procedure btnChatMouseLeave(Sender: TObject);
    procedure btnRenameMouseEnter(Sender: TObject);
    procedure btnRenameMouseLeave(Sender: TObject);
    procedure btnDeleteMouseEnter(Sender: TObject);
    procedure btnDeleteMouseLeave(Sender: TObject);
    procedure imgAvatarPaint(Sender: TObject);
    procedure btnRenameClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure vcardCallback(UID: Widestring; vcard: TXMLVCard);
  private
    { Private declarations }
    _Items: IExodusItemList;
    _Avatar: TAvatar;
    _UnknownAvatar: TBitmap;
    _TypedActs: IExodusTypedActions;
    _ActMap: IExodusActionMap;
    _Loaded: Boolean;
    
    //
    procedure _BuildActions();
    procedure _GetAvatar();
    procedure _GetPresence();
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

  end;


implementation
uses AvatarCache, ExItemHoverForm, ExForm, Session, Jabber1, Presence, COMExodusItemList,
     ExActionCtrl, TntSysUtils, XMLVCardCache, gnugettext;

{$R *.dfm}

constructor TExContactHoverFrame.Create(AOwner: TComponent);
begin
    inherited;
    _Items := TExodusItemList.Create();
    _UnknownAvatar := TBitmap.Create();
    _TypedActs := nil;
    _ActMap := nil;
end;

procedure TExContactHoverFrame.InitControls(Item: IExodusItem);
begin
    _Items.Clear();
    _Items.Add(Item);

    _Loaded := false;
    Separator1.Caption := '';
    Separator2.Caption := '';
    lblDisplayName.Caption := Item.Text;

    lblDisplayName.Hint := Item.Text;
    lblDisplayName.ShowHint := true;
    lblUID.Hint := Item.UID;
    lblUID.Caption := Item.UID;
    lblUID.ShowHint := true;
    lblPresence.ShowHint := true;
    lblPresence.Hint := Item.ExtendedText;

    _GetAvatar();
    _GetPresence();
    _BuildActions();
end;

procedure TExContactHoverFrame._GetPresence();
var
    Pres: TJabberPres;
    Item: IExodusItem;
begin
    lblPresence.Caption := '';
    Item := _Items.Item[0];
    frmExodus.ImageList1.GetIcon(Item.ImageIndex, imgPresence.Picture.Icon);
    try
        lblPresence.Caption := DecodeShowDisplayValue(Item.value['show']);
    except
    end;
    Pres := MainSession.ppdb.FindPres(Item.uid, '');
    if (Pres <> nil) then
    begin
        if (MainSession.prefs.getBool('inline_status')) then
            lblPresence.Caption := lblPresence.Caption + ' - ' + Item.ExtendedText;
    end;
end;

procedure TExContactHoverFrame._BuildActions();
var
    Item: IExodusItem;
    Act: IExodusAction;
begin
    Item := _Items.Item[0];
    _ActMap := GetActionController().buildActions(_Items);
    _TypedActs := _ActMap.GetActionsFor('');
    
    Act := _TypedActs.GetActionNamed('{000-exodus.googlecode.com}-000-start-chat');
    btnChat.Tag := Integer(Pointer(Act));
    btnChat.Enabled := Act <> nil;
    if (Act <> nil) then btnChat.Caption := Act.Caption;
    btnChat.Caption := '     ' + btnChat.Caption;
    Act := _TypedActs.GetActionNamed('{000-exodus.googlecode.com}-150-rename');
    btnRename.Tag := Integer(Pointer(Act));
    btnRename.Enabled := Act <> nil;
    if (Act <> nil) then btnRename.Caption := Act.Caption;
    btnRename.Caption := '     ' + btnRename.Caption;
    Act := _TypedActs.GetActionNamed('{000-exodus.googlecode.com}-190-delete');
    btnDelete.Tag := Integer(Pointer(Act));
    btnDelete.Enabled := Act <> nil;
    if (Act <> nil) then btnDelete.Caption := Act.Caption;
    btnDelete.Caption := '     ' + btnDelete.Caption;

end;

procedure TExContactHoverFrame._GetAvatar();
begin
    if (_UnknownAvatar.Empty) then
        frmExodus.bigImages.GetBitmap(0, _UnknownAvatar);
    _Avatar := nil;
    GetVCardCache().find(_Items.Item[0].uid, vcardCallback);
    if (not _Loaded) then begin
        lblPhone.Caption := _('N/A');
        imgAvatar.Invalidate();
    end;
end;

procedure TExContactHoverFrame.vcardCallback(UID: Widestring; vcard: TXMLVCard);
var
    number: Widestring;
    avatar: TAvatar;
begin
   if (UID <> _Items.Item[0].uid) then exit;

   //Assume "nothing"
   number := '';

   if (vcard <> nil) then begin
       number := vcard.WorkPhone.number;
       if (number = '') then
         number := vcard.WorkCell.number;
       if (number = '') then
         number := vcard.HomePhone.number;
       if (number = '') then
         number := vcard.HomeCell.number;

   end;
   avatar := Avatars.Find(UID);
   if (avatar = nil) or (not avatar.isValid) or (avatar.Height < 0) then
       avatar := nil;

   if (number = '') then
     number := _('N/A');

   _Avatar := avatar;
   if (avatar <> nil) then begin
     if (_Avatar.Height > 32) then
       imgAvatar.Width := Trunc((32 / _avatar.Height) * (_avatar.Width))
     else
       imgAvatar.Width := _Avatar.Width;

   end;

   lblPhone.Caption := number;
   imgAvatar.Invalidate;
   Invalidate;
   _Loaded := true;
end;

procedure TExContactHoverFrame.btnChatClick(Sender: TObject);
var
    act: IExodusAction;
begin
  act := IExodusAction(Pointer(TExGraphicButton(Sender).Tag));
  act.Execute(_Items);
end;

procedure TExContactHoverFrame.btnChatMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.btnChatMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.btnDeleteClick(Sender: TObject);
var
    act: IExodusAction;
begin
  act := IExodusAction(Pointer(TExGraphicButton(Sender).Tag));
  act.Execute(_Items);
end;

procedure TExContactHoverFrame.btnDeleteMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.btnDeleteMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.btnRenameClick(Sender: TObject);
var
    act: IExodusAction;
begin
  //inherited;
  act := IExodusAction(Pointer(TExGraphicButton(Sender).Tag));
  act.Execute(_Items);
end;

procedure TExContactHoverFrame.btnRenameMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.btnRenameMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.imgAvatarMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.imgAvatarMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.imgAvatarPaint(Sender: TObject);
var
    Rect: TRect;
begin
    inherited;
    if (_Avatar <> nil) then
    begin
        if (_Avatar.Height > imgAvatar.Height) then begin
            Rect.Top := 1;
            Rect.Left := 1;
            Rect.Bottom := imgAvatar.Height;
            Rect.Right := imgAvatar.Width;
            _Avatar.Draw(imgAvatar.Canvas, Rect);
        end
        else
            _Avatar.Draw(imgAvatar.Canvas);
    end
    else begin
        Rect.Top := 1;
        Rect.Left := 1;
        Rect.Bottom := 33;
        Rect.Right := 33;
        imgAvatar.Canvas.StretchDraw(Rect, _UnknownAvatar);
    end;
end;

procedure TExContactHoverFrame.imgPresenceMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.imgPresenceMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.TntFrameMouseEnter(Sender: TObject);
begin
  //inherited;
  //OutputDebugString(PChar('Contact MouseEnter'));
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.TntFrameMouseLeave(Sender: TObject);
begin
   //OutputDebugString(PChar('Contact MouseLeave'));
   TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.TntFrameMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  //OutputDebugString(PChar('Contact Mouse Move'));
end;


procedure TExContactHoverFrame.lblDisplayNameMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.lblDisplayNameMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.TnTLabel1MouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.TnTLabel1MouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;


procedure TExContactHoverFrame.lblPresenceMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.lblPresenceMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;

procedure TExContactHoverFrame.lblUIDMouseEnter(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).SetHover();
end;

procedure TExContactHoverFrame.lblUIDMouseLeave(Sender: TObject);
begin
  inherited;
  TExItemHoverForm(Parent).CancelHover();
end;


end.