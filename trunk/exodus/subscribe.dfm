object frmSubscribe: TfrmSubscribe
  Left = 309
  Top = 495
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 3
  Caption = 'Subscription Request'
  ClientHeight = 198
  ClientWidth = 252
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TTntLabel
    Left = 0
    Top = 23
    Width = 252
    Height = 26
    Align = alTop
    Caption = 
      'This person or agent would like to see your online presence and ' +
      'add you to their roster.'
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = 0
    Top = 21
    Width = 252
    Height = 2
    Align = alTop
  end
  object lblJID: TTntLabel
    Left = 0
    Top = 0
    Width = 252
    Height = 21
    Cursor = crHandPoint
    Align = alTop
    AutoSize = False
    Caption = 'lblJID'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    Transparent = False
    OnClick = lblJIDClick
  end
  object chkSubscribe: TTntCheckBox
    Left = 8
    Top = 56
    Width = 217
    Height = 17
    Caption = 'Add this person to my roster'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = chkSubscribeClick
  end
  object boxAdd: TGroupBox
    Left = 24
    Top = 72
    Width = 209
    Height = 81
    TabOrder = 1
    object lblNickname: TTntLabel
      Left = 8
      Top = 16
      Width = 51
      Height = 13
      Caption = 'Nickname:'
    end
    object lblGroup: TTntLabel
      Left = 8
      Top = 48
      Width = 32
      Height = 13
      Caption = 'Group:'
    end
    object txtNickname: TTntEdit
      Left = 70
      Top = 14
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object cboGroup: TTntComboBox
      Left = 70
      Top = 44
      Width = 123
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
    end
  end
  inline frameButtons1: TframeButtons
    Left = 0
    Top = 162
    Width = 252
    Height = 36
    Align = alBottom
    AutoScroll = False
    TabOrder = 2
    inherited Panel2: TPanel
      Width = 252
      Height = 36
      inherited Bevel1: TBevel
        Width = 252
      end
      inherited Panel1: TPanel
        Left = 92
        Height = 31
        inherited btnOK: TTntButton
          Caption = 'Accept'
          OnClick = frameButtons1btnOKClick
        end
        inherited btnCancel: TTntButton
          Caption = 'Deny'
          OnClick = frameButtons1btnCancelClick
        end
      end
    end
  end
  object PopupMenu1: TTntPopupMenu
    Left = 8
    Top = 168
    object mnuProfile: TTntMenuItem
      Caption = 'Show Profile'
      OnClick = mnuProfileClick
    end
    object mnuChat: TTntMenuItem
      Caption = 'Start Chat'
      OnClick = mnuChatClick
    end
    object mnuMessage: TTntMenuItem
      Caption = 'Send Message'
      OnClick = mnuMessageClick
    end
  end
end
