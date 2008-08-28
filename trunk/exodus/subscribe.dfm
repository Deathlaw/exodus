inherited frmSubscribe: TfrmSubscribe
  Left = 250
  Top = 165
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 3
  Caption = 'Subscription Request'
  ClientHeight = 215
  ClientWidth = 328
  Position = poMainFormCenter
  OnClose = FormClose
  ExplicitWidth = 340
  ExplicitHeight = 253
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TTntLabel
    Left = 0
    Top = 35
    Width = 328
    Height = 26
    Align = alTop
    Caption = 
      'This person or agent would like to see your online presence and ' +
      'add you to their contact list.'
    WordWrap = True
    ExplicitWidth = 326
  end
  object Bevel1: TBevel
    Left = 0
    Top = 33
    Width = 328
    Height = 2
    Align = alTop
  end
  object chkSubscribe: TTntCheckBox
    Left = 8
    Top = 69
    Width = 217
    Height = 17
    Caption = 'Add this person to my contact list'
    Checked = True
    State = cbChecked
    TabOrder = 0
    OnClick = chkSubscribeClick
  end
  object boxAdd: TGroupBox
    Left = 24
    Top = 88
    Width = 289
    Height = 81
    TabOrder = 1
    object lblNickname: TTntLabel
      Left = 8
      Top = 16
      Width = 49
      Height = 13
      Caption = 'Nickname:'
    end
    object lblGroup: TTntLabel
      Left = 8
      Top = 48
      Width = 33
      Height = 13
      Caption = 'Group:'
    end
    object txtNickname: TTntEdit
      Left = 70
      Top = 14
      Width = 200
      Height = 21
      TabOrder = 0
    end
    object cboGroup: TTntComboBox
      Left = 70
      Top = 44
      Width = 200
      Height = 21
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
    end
  end
  inline frameButtons1: TframeButtons
    Left = 0
    Top = 179
    Width = 328
    Height = 36
    Align = alBottom
    Color = 13681583
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 2
    TabStop = True
    ExplicitTop = 179
    ExplicitWidth = 328
    ExplicitHeight = 36
    inherited Panel2: TPanel
      Width = 328
      Height = 36
      ExplicitTop = -4
      ExplicitWidth = 328
      ExplicitHeight = 36
      inherited Bevel1: TBevel
        Width = 328
        ExplicitWidth = 328
      end
      inherited Panel1: TPanel
        Left = 90
        Width = 238
        Height = 31
        ExplicitLeft = 90
        ExplicitWidth = 238
        ExplicitHeight = 31
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 328
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 3
    object imgIdent: TImage
      Left = 0
      Top = 0
      Width = 33
      Height = 33
      Align = alLeft
      Center = True
      Transparent = True
    end
    object lblJID: TTntLabel
      Left = 33
      Top = 0
      Width = 295
      Height = 33
      Cursor = crHandPoint
      Align = alClient
      AutoSize = False
      Caption = 'lblJID'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlue
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      OnClick = lblJIDClick
    end
  end
  object btnBlock: TTntButton
    Left = 250
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Block'
    TabOrder = 4
    OnClick = btnBlockClick
  end
  object PopupMenu1: TTntPopupMenu
    Left = 208
    Top = 56
    object mnuProfile: TTntMenuItem
      Caption = 'Show Profile'
      OnClick = mnuProfileClick
    end
    object mnuChat: TTntMenuItem
      Caption = 'Start Chat'
      OnClick = mnuChatClick
    end
  end
end
