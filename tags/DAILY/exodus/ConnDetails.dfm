object frmConnDetails: TfrmConnDetails
  Left = 256
  Top = 245
  Width = 410
  Height = 314
  ActiveControl = cboJabberID
  Caption = 'Connection Details'
  Color = clBtnFace
  Constraints.MinWidth = 410
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TTntPageControl
    Left = 0
    Top = 0
    Width = 402
    Height = 247
    ActivePage = tbsProfile
    Align = alClient
    TabOrder = 0
    object tbsProfile: TTntTabSheet
      Caption = 'Account Details'
      ImageIndex = -1
      object lblUsername: TTntLabel
        Left = 2
        Top = 8
        Width = 49
        Height = 13
        Caption = 'Jabber ID:'
        Transparent = True
      end
      object Label10: TTntLabel
        Left = 2
        Top = 71
        Width = 49
        Height = 13
        Caption = 'Password:'
        Transparent = True
      end
      object Label12: TTntLabel
        Left = 2
        Top = 95
        Width = 49
        Height = 13
        Caption = 'Resource:'
        Transparent = True
      end
      object lblServerList: TTntLabel
        Left = 100
        Top = 49
        Width = 152
        Height = 13
        Cursor = crHandPoint
        Caption = 'Download a list of public servers'
        OnClick = lblServerListClick
      end
      object Label13: TTntLabel
        Left = 100
        Top = 32
        Width = 285
        Height = 17
        AutoSize = False
        Caption = 'Enter desired Jabber ID for new accounts.'
        WordWrap = True
      end
      object Label6: TTntLabel
        Left = 3
        Top = 120
        Width = 34
        Height = 13
        Caption = 'Priority:'
        Transparent = True
      end
      object lblRename: TTntLabel
        Left = 100
        Top = 201
        Width = 90
        Height = 13
        Cursor = crHandPoint
        Caption = 'Rename this profile'
        OnClick = lblRenameClick
      end
      object cboJabberID: TTntComboBox
        Left = 100
        Top = 3
        Width = 285
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        OnExit = txtUsernameExit
        OnKeyPress = txtUsernameKeyPress
        Items.WideStrings = (
          'jabber.org'
          'jabber.com')
      end
      object chkSavePasswd: TTntCheckBox
        Left = 100
        Top = 145
        Width = 170
        Height = 17
        Caption = 'Save pass&word'
        TabOrder = 5
      end
      object txtPassword: TTntEdit
        Left = 100
        Top = 68
        Width = 170
        Height = 21
        PasswordChar = '*'
        TabOrder = 1
      end
      object cboResource: TTntComboBox
        Left = 100
        Top = 92
        Width = 170
        Height = 21
        ItemHeight = 13
        TabOrder = 2
        OnExit = txtUsernameExit
        OnKeyPress = txtUsernameKeyPress
      end
      object chkRegister: TTntCheckBox
        Left = 100
        Top = 162
        Width = 181
        Height = 17
        Caption = 'This is a new account'
        TabOrder = 6
      end
      object txtPriority: TTntEdit
        Left = 100
        Top = 116
        Width = 46
        Height = 21
        TabOrder = 3
        Text = '0'
      end
      object spnPriority: TUpDown
        Left = 146
        Top = 116
        Width = 16
        Height = 21
        Associate = txtPriority
        Min = -1
        Max = 128
        TabOrder = 4
      end
      object chkWinLogin: TTntCheckBox
        Left = 100
        Top = 179
        Width = 181
        Height = 17
        Caption = 'Use Windows login information'
        TabOrder = 7
        OnClick = chkWinLoginClick
      end
    end
    object tbsConn: TTntTabSheet
      Caption = 'Connection'
      ImageIndex = -1
      object chkSRV: TTntCheckBox
        Left = 4
        Top = 2
        Width = 269
        Height = 17
        Caption = 'Automatically discover host and port'
        TabOrder = 0
        OnClick = chkSRVClick
      end
      object boxHost: TTntGroupBox
        Left = 12
        Top = 23
        Width = 306
        Height = 73
        TabOrder = 1
        object Label4: TTntLabel
          Left = 6
          Top = 17
          Width = 25
          Height = 13
          Caption = 'Host:'
          Transparent = True
        end
        object Label7: TTntLabel
          Left = 6
          Top = 44
          Width = 22
          Height = 13
          Caption = 'Port:'
          Transparent = True
        end
        object txtHost: TTntEdit
          Left = 55
          Top = 13
          Width = 234
          Height = 21
          TabOrder = 0
        end
        object txtPort: TTntEdit
          Left = 55
          Top = 41
          Width = 46
          Height = 21
          TabOrder = 1
          Text = '5222'
        end
      end
    end
    object tbsSSL: TTntTabSheet
      Caption = 'Encryption'
      object TntLabel1: TTntLabel
        Left = 1
        Top = 9
        Width = 73
        Height = 13
        Caption = 'SSL Certificate:'
        Transparent = True
      end
      object txtSSLCert: TTntEdit
        Left = 18
        Top = 29
        Width = 263
        Height = 21
        TabOrder = 0
      end
      object btnCertBrowse: TTntButton
        Left = 285
        Top = 28
        Width = 72
        Height = 25
        Caption = 'Browse'
        TabOrder = 1
        OnClick = btnCertBrowseClick
      end
      object optSSL: TTntRadioGroup
        Left = 8
        Top = 64
        Width = 345
        Height = 105
        Caption = 'SSL Modes'
        Items.WideStrings = (
          'Encrypt the connection whenever possible.'
          'All connections must be encrypted.'
          'Use old SSL port method.')
        TabOrder = 2
      end
    end
    object tbsSocket: TTntTabSheet
      Caption = 'Proxy'
      ImageIndex = -1
      object lblSocksHost: TTntLabel
        Left = 5
        Top = 38
        Width = 25
        Height = 13
        Caption = 'Host:'
        Enabled = False
        Transparent = True
      end
      object lblSocksPort: TTntLabel
        Left = 5
        Top = 65
        Width = 22
        Height = 13
        Caption = 'Port:'
        Enabled = False
        Transparent = True
      end
      object lblSocksType: TTntLabel
        Left = 5
        Top = 13
        Width = 27
        Height = 13
        Caption = 'Type:'
        Transparent = True
      end
      object lblSocksUsername: TTntLabel
        Left = 5
        Top = 112
        Width = 51
        Height = 13
        Caption = 'Username:'
        Enabled = False
        Transparent = True
      end
      object lblSocksPassword: TTntLabel
        Left = 5
        Top = 140
        Width = 49
        Height = 13
        Caption = 'Password:'
        Enabled = False
        Transparent = True
      end
      object chkSocksAuth: TTntCheckBox
        Left = 91
        Top = 85
        Width = 190
        Height = 17
        Caption = 'Authentication Required'
        Enabled = False
        TabOrder = 2
        OnClick = chkSocksAuthClick
      end
      object txtSocksHost: TTntEdit
        Left = 91
        Top = 34
        Width = 190
        Height = 21
        Enabled = False
        TabOrder = 0
      end
      object txtSocksPort: TTntEdit
        Left = 91
        Top = 61
        Width = 39
        Height = 21
        Enabled = False
        TabOrder = 1
      end
      object txtSocksUsername: TTntEdit
        Left = 90
        Top = 108
        Width = 190
        Height = 21
        Enabled = False
        TabOrder = 3
      end
      object txtSocksPassword: TTntEdit
        Left = 90
        Top = 136
        Width = 190
        Height = 21
        Enabled = False
        PasswordChar = '*'
        TabOrder = 4
      end
      object cboSocksType: TTntComboBox
        Left = 91
        Top = 8
        Width = 190
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        Items.WideStrings = (
          'None'
          'Version 4'
          'Version 4a'
          'Version 5'
          'HTTP')
      end
    end
    object tbsHttp: TTntTabSheet
      BorderWidth = 2
      Caption = 'HTTP Polling'
      ImageIndex = -1
      object Label1: TTntLabel
        Left = 1
        Top = 27
        Width = 25
        Height = 13
        Caption = 'URL:'
        Transparent = True
      end
      object Label2: TTntLabel
        Left = 1
        Top = 60
        Width = 46
        Height = 13
        Caption = 'Poll Time:'
        Transparent = True
      end
      object Label5: TTntLabel
        Left = 164
        Top = 61
        Width = 40
        Height = 13
        Caption = 'seconds'
      end
      object Label9: TTntLabel
        Left = 1
        Top = 95
        Width = 48
        Height = 13
        Caption = '# of Keys:'
        Transparent = True
      end
      object lblNote: TTntLabel
        Left = 0
        Top = 155
        Width = 390
        Height = 60
        Align = alBottom
        AutoSize = False
        Caption = 
          'NOTE: You must use the URL of your jabber server'#39's HTTP tunnelli' +
          'ng proxy. You can not use some "standard" HTTP proxy for this to' +
          ' work. Contact your server administrator for additional informat' +
          'ion.'
        WordWrap = True
      end
      object txtURL: TTntEdit
        Left = 100
        Top = 24
        Width = 197
        Height = 21
        TabOrder = 0
      end
      object txtTime: TTntEdit
        Left = 100
        Top = 57
        Width = 53
        Height = 21
        TabOrder = 1
      end
      object txtKeys: TTntEdit
        Left = 100
        Top = 90
        Width = 53
        Height = 21
        TabOrder = 2
      end
      object chkPolling: TTntCheckBox
        Left = 2
        Top = 3
        Width = 263
        Height = 17
        Caption = 'Use HTTP Polling'
        TabOrder = 3
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 247
    Width = 402
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object Panel1: TPanel
      Left = 159
      Top = 4
      Width = 239
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOK: TTntButton
        Left = 4
        Top = 0
        Width = 75
        Height = 25
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
        OnClick = frameButtons1btnOKClick
      end
      object btnCancel: TTntButton
        Left = 82
        Top = 0
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
      end
      object btnConnect: TTntButton
        Left = 161
        Top = 0
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Connect'
        ModalResult = 6
        TabOrder = 2
        OnClick = btnConnectClick
      end
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'pem'
    Filter = 'SSL Key Files|*.pem|All Files|*.*'
    Left = 8
    Top = 176
  end
end
