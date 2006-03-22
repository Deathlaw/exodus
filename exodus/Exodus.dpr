program Exodus;

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

{%File 'README.txt'}
{%File '..\todo.txt'}
{$R 'version.res' 'version.rc'}
{$R 'iehtml.res' 'iehtml.rc'}
{%File 'defaults.xml'}

{$ifdef VER150}
    {$define INDY9}
{$endif}
{$ifdef VER180}
    {$define INDY9}
{$endif}

uses
  Forms,
  Controls,
  Windows,
  About in 'About.pas' {frmAbout},
  AutoUpdate in '..\jopl\AutoUpdate.pas',
  AutoUpdateStatus in 'AutoUpdateStatus.pas' {frmAutoUpdateStatus},
  BaseChat in 'BaseChat.pas' {frmBaseChat},
  Bookmark in 'Bookmark.pas' {frmBookmark},
  Browser in 'Browser.pas' {frmBrowse},
  Chat in '..\jopl\Chat.pas',
  ChatController in '..\jopl\ChatController.pas',
  ChatWin in 'ChatWin.pas' {frmChat},
  COMChatController in 'COMChatController.pas' {ExodusChatController: CoClass},
  COMController in 'COMController.pas' {ExodusController: CoClass},
  COMPPDB in 'COMPPDB.pas' {ExodusPPDB: CoClass},
  COMPresence in 'COMPresence.pas' {ExodusPresence: CoClass},
  COMRoster in 'COMRoster.pas' {ExodusRoster: CoClass},
  COMRosterItem in 'COMRosterItem.pas' {ExodusRosterItem: CoClass},
  ConnDetails in 'ConnDetails.pas' {frmConnDetails},
  CustomNotify in 'CustomNotify.pas' {frmCustomNotify},
  CustomPres in 'CustomPres.pas' {frmCustomPres},
  Debug in 'Debug.pas' {frmDebug},
  Dockable in 'Dockable.pas' {frmDockable},
  DropTarget in 'DropTarget.pas' {ExDropTarget: CoClass},
  Emoticons in 'Emoticons.pas' {frmEmoticons},
  ExEvents in 'ExEvents.pas',
  ExResponders in 'ExResponders.pas',
  ExUtils in 'ExUtils.pas',
  fGeneric in 'fGeneric.pas' {frameGeneric: TFrame},
  fLeftLabel in 'fLeftLabel.pas' {frmField: TFrame},
  fListbox in 'fListbox.pas' {frameListbox: TFrame},
  fRosterTree in 'fRosterTree.pas' {frameTreeRoster: TFrame},
  fService in 'fService.pas' {frameObjectActions: TFrame},
  fTopLabel in 'fTopLabel.pas' {frameTopLabel: TFrame},
  getOpt in 'getOpt.pas',
  GrpRemove in 'GrpRemove.pas' {frmGrpRemove},
  GUIFactory in 'GUIFactory.pas',
  InputPassword in 'InputPassword.pas' {frmInputPass},
  InvalidRoster in 'InvalidRoster.pas' {frmInvalidRoster},
  invite in 'invite.pas' {frmInvite},
  IQ in '..\jopl\IQ.pas',
  Jabber1 in 'Jabber1.pas' {frmExodus},
  JabberAuth in '..\jopl\JabberAuth.pas',
  JabberConst in '..\jopl\JabberConst.pas',
  JabberID in '..\jopl\JabberID.pas',
  JabberMsg in '..\jopl\JabberMsg.pas',
  Langs in '..\jopl\Langs.pas',
  LibXmlComps in '..\jopl\LibXmlComps.pas',
  LibXmlParser in '..\jopl\LibXmlParser.pas',
  MsgController in '..\jopl\MsgController.pas',
  MsgDisplay in 'MsgDisplay.pas',
  MsgList in '..\jopl\MsgList.pas',
  MsgQueue in 'MsgQueue.pas' {frmMsgQueue},
  MsgRecv in 'MsgRecv.pas' {frmMsgRecv},
  Notify in 'Notify.pas',
  Password in 'Password.pas' {frmPassword},
  PathSelector in 'PathSelector.pas' {frmPathSelector},
  PluginAuth in 'PluginAuth.pas',
  PrefAway in 'prefs\PrefAway.pas' {frmPrefAway},
  PrefController in '..\jopl\PrefController.pas',
  PrefDialogs in 'prefs\PrefDialogs.pas' {frmPrefDialogs},
  PrefFont in 'prefs\PrefFont.pas' {frmPrefFont},
  PrefMsg in 'prefs\PrefMsg.pas' {frmPrefMsg},
  PrefNotify in 'prefs\PrefNotify.pas' {frmPrefNotify},
  PrefPanel in 'prefs\PrefPanel.pas' {frmPrefPanel},
  PrefPlugins in 'prefs\PrefPlugins.pas' {frmPrefPlugins},
  PrefPresence in 'prefs\PrefPresence.pas' {frmPrefPresence},
  PrefRoster in 'prefs\PrefRoster.pas' {frmPrefRoster},
  Prefs in 'Prefs.pas' {frmPrefs},
  PrefSubscription in 'prefs\PrefSubscription.pas' {frmPrefSubscription},
  PrefSystem in 'prefs\PrefSystem.pas' {frmPrefSystem},
  Presence in '..\jopl\Presence.pas',
  Profile in 'Profile.pas' {frmProfile},
  RegExpr in '..\jopl\RegExpr.pas',
  Register in 'Register.pas',
  RemoveContact in 'RemoveContact.pas' {frmRemove},
  Responder in '..\jopl\Responder.pas',
  RiserWindow in 'RiserWindow.pas' {frmRiser},
  Room in 'Room.pas' {frmRoom},
  RoomAdminList in 'RoomAdminList.pas' {frmRoomAdminList},
  Roster in '..\jopl\Roster.pas',
  RosterAdd in 'RosterAdd.pas' {frmAdd},
  RosterRecv in 'RosterRecv.pas' {frmRosterRecv},
  RosterWindow in 'RosterWindow.pas' {frmRosterWindow},
  S10n in '..\jopl\S10n.pas',
  SecHash in '..\jopl\SecHash.pas',
  SelContact in 'SelContact.pas' {frmSelContact},
  Session in '..\jopl\Session.pas',
  Signals in '..\jopl\Signals.pas',
  StandardAuth in '..\jopl\StandardAuth.pas',
  subscribe in 'subscribe.pas' {frmSubscribe},
  Transports in 'Transports.pas',
  Unicode in '..\jopl\Unicode.pas',
  vcard in 'vcard.pas' {frmVCard},
  XMLAttrib in '..\jopl\XMLAttrib.pas',
  XMLCData in '..\jopl\XMLCData.pas',
  XMLConstants in '..\jopl\XMLConstants.pas',
  XMLHttpStream in '..\jopl\XMLHttpStream.pas',
  XMLNode in '..\jopl\XMLNode.pas',
  XMLParser in '..\jopl\XMLParser.pas',
  XMLSocketStream in '..\jopl\XMLSocketStream.pas',
  XMLStream in '..\jopl\XMLStream.pas',
  XMLTag in '..\jopl\XMLTag.pas',
  XMLUtils in '..\jopl\XMLUtils.pas',
  XMLVCard in '..\jopl\XMLVCard.pas',
  gnugettext in 'gnugettext.pas',
  PrefTransfer in 'prefs\PrefTransfer.pas' {frmPrefTransfer},
  buttonFrame in 'buttonFrame.pas' {frameButtons: TFrame},
  ExSession in 'ExSession.pas',
  WebGet in 'WebGet.pas' {frmWebDownload},
  PrefNetwork in 'prefs\PrefNetwork.pas' {frmPrefNetwork},
  PrefGroups in 'prefs\PrefGroups.pas' {frmPrefGroups},
  HttpProxyIOHandler in '..\jopl\HttpProxyIOHandler.pas',
  PrefLayouts in 'prefs\PrefLayouts.pas' {frmPrefLayouts},
  Wizard in 'Wizard.pas' {frmWizard},
  LocalUtils in 'LocalUtils.pas',
  SendStatus in 'SendStatus.pas' {fSendStatus: TFrame},
  XferManager in 'XferManager.pas' {frmXferManager},
  RecvStatus in 'RecvStatus.pas' {fRecvStatus: TFrame},
  GrpManagement in 'GrpManagement.pas' {frmGrpManagement},
  CapPresence in '..\jopl\CapPresence.pas',
  NodeItem in '..\jopl\NodeItem.pas',
  Jud in 'Jud.pas' {frmJud},
  DockWizard in 'DockWizard.pas' {frmDockWizard},
  SSLWarn in 'SSLWarn.pas' {frmSSLWarn},
  DNSUtils in '..\jopl\DNSUtils.pas',
  IdDNSResolver in '..\jopl\IdDNSResolver.pas',
  Entity in '..\jopl\Entity.pas',
  EntityCache in '..\jopl\EntityCache.pas',
  SASLAuth in '..\jopl\SASLAuth.pas',
  ExGettextUtils in 'ExGettextUtils.pas',
  JoinRoom in 'JoinRoom.pas',
  PrefFile in '..\jopl\PrefFile.pas',
  RegForm in 'RegForm.pas' {frmRegister},
  ExTracer in 'ExTracer.pas' {frmException},
  NetMeetingFix in 'NetMeetingFix.pas',
  BaseMsgList in 'BaseMsgList.pas' {fBaseMsgList: TFrame},
  RTFMsgList in 'RTFMsgList.pas' {fRTFMsgList: TFrame},
  Emote in 'Emote.pas',
  GIFImage in 'GIFImage.pas',
  PrefEmote in 'prefs\PrefEmote.pas' {frmPrefEmote},
  EmoteProps in 'EmoteProps.pas' {frmEmoteProps},
  JabberUtils in '..\jopl\JabberUtils.pas',
  DockContainer in 'DockContainer.pas' {frmDockContainer},
  Random in '..\jopl\Random.pas',
  stringprep in '..\jopl\stringprep.pas',
  CommandWizard in 'CommandWizard.pas' {frmCommandWizard},
  fResults in 'fResults.pas' {frameResults: TFrame},
  Avatar in '..\jopl\Avatar.pas',
  FloatingImage in 'FloatingImage.pas' {FloatImage},
  xdata in 'xdata.pas' {frmXData},
  fXData in 'fXData.pas' {frameXData: TFrame},
  NewUser in 'NewUser.pas' {frmNewUser},
  pngzlib in '..\jopl\png\pngzlib.pas',
  pngimage in '..\jopl\png\pngimage.pas',
  pnglang in '..\jopl\png\pnglang.pas',
  DiscoIdentity in '..\jopl\DiscoIdentity.pas',
  fProfile in 'fProfile.pas' {frameProfile: TFrame},
  ZlibHandler in '..\jopl\ZlibHandler.pas',
  Bookmarks in '..\jopl\Bookmarks.pas',
  RosterImages in '..\jopl\RosterImages.pas',
  COMRosterGroup in 'COMRosterGroup.pas' {ExodusRosterGroup: CoClass},
  COMRosterImages in 'COMRosterImages.pas' {ExodusRosterImages: CoClass},
  CapsCache in '..\jopl\CapsCache.pas',
  COMEntityCache in 'COMEntityCache.pas' {ExodusEntityCache: CoClass},
  COMEntity in 'COMEntity.pas' {ExodusEntity: CoClass},
  PrtRichEdit in 'PrtRichEdit.pas',
  IdAuthenticationSSPI in '..\jopl\IdAuthenticationSSPI.pas',
  IdSSPI in '..\jopl\IdSSPI.pas',
  COMExRichEdit in 'COMGuis\COMExRichEdit.pas',
  COMExButton in 'COMGuis\COMExButton.pas',
  COMExCheckBox in 'COMGuis\COMExCheckBox.pas',
  COMExComboBox in 'COMGuis\COMExComboBox.pas',
  COMExEdit in 'COMGuis\COMExEdit.pas',
  COMExFont in 'COMGuis\COMExFont.pas',
  COMExLabel in 'COMGuis\COMExLabel.pas',
  COMExListBox in 'COMGuis\COMExListBox.pas',
  COMExMenuItem in 'COMGuis\COMExMenuItem.pas',
  COMExPanel in 'COMGuis\COMExPanel.pas',
  COMExPopupMenu in 'COMGuis\COMExPopupMenu.pas',
  COMExRadioButton in 'COMGuis\COMExRadioButton.pas',
  COMExControls in 'COMGuis\COMExControls.pas',
  Exodus_TLB in 'Exodus_TLB.pas',
  COMExSpeedButton in 'COMGuis\COMExSpeedButton.pas',
  COMExBitBtn in 'COMGuis\COMExBitBtn.pas',
  COMExMainMenu in 'COMGuis\COMExMainMenu.pas',
  COMExMemo in 'COMGuis\COMExMemo.pas',
  COMExPageControl in 'COMGuis\COMExPageControl.pas',
  COMToolbar in 'COMToolbar.pas' {ExodusToolbar: CoClass},
  COMToolbarButton in 'COMToolbarButton.pas' {ExodusToolbarButton: CoClass},
  COMExForm in 'COMGuis\COMExForm.pas',
  COMLogMsg in 'COMLogMsg.pas' {ExodusLogMsg: CoClass},
  COMLogListener in 'COMLogListener.pas' {ExodusLogListener: CoClass},
  KerbAuth in '..\jopl\KerbAuth.pas';

{$R *.TLB}

{$R *.RES}

{$R manifest.res}
{$R xtra.res}
{$R xml.res}

var
    continue: boolean;

begin

  // Sometimes OLE registration fails if the user don't
  // have sufficient privs.. Just silently eat these.
  try
    Application.Initialize;
  except
  end;

  Application.Title := '';
  Application.ShowMainForm := false;

  {$ifdef LEAKCHECK}
  // MemChk();
  {$endif}

  // Main startup stuff
  continue := SetupSession();
  if (not continue) then exit;

  Application.CreateForm(TfrmExodus, frmExodus);
  Application.CreateForm(TFloatImage, FloatImage);
  frmRosterWindow := TfrmRosterWindow.Create(Application);

  frmRosterWindow.DockRoster;
  frmRosterWindow.Show;

  frmExodus.Startup();
  Application.Run;

end.

