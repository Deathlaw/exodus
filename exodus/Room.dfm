inherited frmRoom: TfrmRoom
  Left = 276
  Top = 177
  Caption = 'Conference Room'
  OldCreateOrder = True
  OnClose = FormClose
  OnEndDock = FormEndDock
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel3: TPanel
    Top = 23
    Height = 225
    object Splitter2: TSplitter [0]
      Left = 268
      Top = 4
      Width = 3
      Height = 217
      Cursor = crHSplit
      Align = alRight
      ResizeStyle = rsUpdate
    end
    inherited MsgList: TExRichEdit
      Width = 264
      Height = 217
      PopupMenu = popRoom
      ReadOnly = False
      OnDragDrop = lstRosterDragDrop
      OnDragOver = lstRosterDragOver
    end
    object Panel6: TPanel
      Left = 271
      Top = 4
      Width = 105
      Height = 217
      Align = alRight
      BevelOuter = bvNone
      BorderWidth = 1
      Caption = '`'
      TabOrder = 1
      object lstRoster: TTntListView
        Left = 1
        Top = 1
        Width = 103
        Height = 215
        Align = alClient
        Columns = <
          item
            AutoSize = True
          end>
        IconOptions.Arrangement = iaLeft
        IconOptions.WrapText = False
        MultiSelect = True
        ParentShowHint = False
        PopupMenu = popRoomRoster
        ShowColumnHeaders = False
        ShowWorkAreas = True
        ShowHint = True
        SmallImages = frmExodus.ImageList2
        SortType = stText
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lstRosterDblClick
        OnDragDrop = lstRosterDragDrop
        OnDragOver = lstRosterDragOver
        OnInfoTip = lstRosterInfoTip
      end
    end
  end
  inherited Panel1: TPanel
    Height = 23
    BorderWidth = 1
    object btnClose: TSpeedButton
      Left = 356
      Top = 2
      Width = 23
      Height = 20
      Caption = 'X'
      Flat = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
      OnClick = btnCloseClick
    end
    object pnlSubj: TPanel
      Left = 1
      Top = 1
      Width = 352
      Height = 21
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object lblSubjectURL: TLabel
        Left = 0
        Top = 0
        Width = 39
        Height = 21
        Cursor = crHandPoint
        Align = alLeft
        Caption = 'Subject:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
        Layout = tlCenter
        OnClick = lblSubjectURLClick
      end
      object lblSubject: TTntLabel
        Left = 39
        Top = 0
        Width = 314
        Height = 21
        Align = alLeft
        Anchors = [akLeft, akTop, akRight, akBottom]
        AutoSize = False
        Caption = ' lblSubject'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial Unicode MS'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
    end
  end
  object popRoom: TPopupMenu
    Left = 16
    Top = 152
    object popClear: TMenuItem
      Caption = 'Clear Window'
      OnClick = popClearClick
    end
    object popShowHistory: TMenuItem
      Caption = 'Show History'
      OnClick = popShowHistoryClick
    end
    object popClearHistory: TMenuItem
      Caption = 'Clear History'
      OnClick = popClearHistoryClick
    end
    object popBookmark: TMenuItem
      Caption = 'Bookmark Room'
      OnClick = popBookmarkClick
    end
    object popInvite: TMenuItem
      Caption = 'Invite Contacts'
      OnClick = popInviteClick
    end
    object popNick: TMenuItem
      Caption = 'Change Nickname'
      OnClick = popNickClick
    end
    object popAdmin: TMenuItem
      Caption = 'Admin'
      Enabled = False
      object popVoiceList: TMenuItem
        Caption = 'Edit Voice List'
        OnClick = popVoiceListClick
      end
      object popBanList: TMenuItem
        Caption = 'Edit Ban List'
        OnClick = popVoiceListClick
      end
      object popMemberList: TMenuItem
        Caption = 'Edit Member List'
        OnClick = popVoiceListClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object popAdminList: TMenuItem
        Caption = 'Edit Admin List'
        OnClick = popVoiceListClick
      end
      object popOwnerList: TMenuItem
        Caption = 'Edit Owner List'
        OnClick = popVoiceListClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object popConfigure: TMenuItem
        Caption = 'Configure Room'
        OnClick = popConfigureClick
      end
      object popDestroy: TMenuItem
        Caption = 'Destroy Room'
        OnClick = popDestroyClick
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuOnTop: TMenuItem
      Caption = 'Always on Top'
      OnClick = mnuOnTopClick
    end
    object popClose: TMenuItem
      Caption = 'Close Room'
      OnClick = popCloseClick
    end
  end
  object popRoomRoster: TPopupMenu
    OnPopup = popRoomRosterPopup
    Left = 48
    Top = 152
    object popRosterChat: TMenuItem
      Caption = 'Chat'
      OnClick = lstRosterDblClick
    end
    object popRosterBlock: TMenuItem
      Caption = 'Block'
      OnClick = popRosterBlockClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object popKick: TMenuItem
      Caption = 'Kick'
      Enabled = False
      OnClick = popKickClick
    end
    object popBan: TMenuItem
      Caption = 'Ban'
      Enabled = False
      OnClick = popKickClick
    end
    object popVoice: TMenuItem
      Caption = 'Toggle Voice'
      Enabled = False
      OnClick = popVoiceClick
    end
    object popOwner: TMenuItem
      Caption = 'Make Owner'
      Enabled = False
      OnClick = popKickClick
    end
  end
end
