inherited frmPrefRoster: TfrmPrefRoster
  Left = 236
  Top = 161
  Caption = 'frmPrefRoster'
  ClientHeight = 347
  ClientWidth = 344
  PixelsPerInch = 96
  TextHeight = 13
  object Label18: TLabel
    Left = 8
    Top = 298
    Width = 150
    Height = 13
    Caption = 'Group to be used for Gateways:'
  end
  object Label21: TLabel
    Left = 8
    Top = 245
    Width = 93
    Height = 13
    Caption = 'Double Click Action'
  end
  object chkOnlineOnly: TCheckBox
    Left = 8
    Top = 24
    Width = 209
    Height = 17
    Caption = 'Show only online contacts.'
    TabOrder = 0
  end
  object StaticText1: TStaticText
    Left = 0
    Top = 0
    Width = 344
    Height = 20
    Align = alTop
    Alignment = taCenter
    Caption = 'Roster Options'
    Color = clHighlight
    Font.Charset = ANSI_CHARSET
    Font.Color = clCaptionText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    TabOrder = 1
  end
  object chkShowUnsubs: TCheckBox
    Left = 8
    Top = 41
    Width = 209
    Height = 17
    Caption = 'Show unsubscribed contacts.'
    TabOrder = 2
  end
  object chkOfflineGroup: TCheckBox
    Left = 8
    Top = 76
    Width = 241
    Height = 17
    Caption = 'Show offline contacts in the "Offline" group.'
    TabOrder = 3
  end
  object chkInlineStatus: TCheckBox
    Left = 8
    Top = 198
    Width = 241
    Height = 17
    Caption = 'Show status in the roster: Joe <Meeting>'
    TabOrder = 4
    OnClick = chkInlineStatusClick
  end
  object cboInlineStatus: TColorBox
    Left = 32
    Top = 214
    Width = 201
    Height = 22
    DefaultColorColor = clBlue
    Selected = clBlue
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    DropDownCount = 12
    ItemHeight = 16
    TabOrder = 5
  end
  object chkHideBlocked: TCheckBox
    Left = 8
    Top = 93
    Width = 201
    Height = 17
    Caption = 'Hide blocked contacts '
    TabOrder = 6
  end
  object chkPresErrors: TCheckBox
    Left = 8
    Top = 110
    Width = 209
    Height = 17
    Caption = 'Detect invalid roster items'
    TabOrder = 7
  end
  object chkShowPending: TCheckBox
    Left = 8
    Top = 58
    Width = 161
    Height = 17
    Caption = 'Show pending contacts'
    TabOrder = 8
  end
  object chkMessenger: TCheckBox
    Left = 8
    Top = 126
    Width = 273
    Height = 17
    Caption = 'Roster && Msg Queue share a tab when expanded'
    TabOrder = 9
  end
  object txtGatewayGrp: TTntEdit
    Left = 32
    Top = 312
    Width = 201
    Height = 21
    TabOrder = 10
  end
  object cboDblClick: TComboBox
    Left = 32
    Top = 261
    Width = 201
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 11
    Items.Strings = (
      'A new one to one chat window'
      'An instant message window'
      'A new or existing chat window')
  end
  object chkRosterUnicode: TCheckBox
    Left = 9
    Top = 143
    Width = 328
    Height = 17
    Caption = 'Allow Unicode characters in the roster (requires 2000, ME, XP).'
    TabOrder = 12
  end
  object chkCollapsed: TCheckBox
    Left = 9
    Top = 160
    Width = 200
    Height = 17
    Caption = 'Collapse all roster groups initially.'
    TabOrder = 13
  end
  object chkGroupCounts: TCheckBox
    Left = 9
    Top = 176
    Width = 288
    Height = 17
    Caption = 'Show online and total group counts in roster (eg, 5/10)'
    TabOrder = 14
  end
end
