object frmBaseChat: TfrmBaseChat
  Left = 317
  Top = 428
  Width = 388
  Height = 310
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnEndDock = FormEndDock
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 249
    Width = 380
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    AutoSnap = False
    Beveled = True
    OnMoved = Splitter1Moved
  end
  object pnlMsgList: TPanel
    Left = 0
    Top = 22
    Width = 380
    Height = 227
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
  end
  object pnlInput: TPanel
    Left = 0
    Top = 252
    Width = 380
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 1
    object MsgOut: TExRichEdit
      Left = 2
      Top = 2
      Width = 376
      Height = 24
      Align = alClient
      AutoURLDetect = adNone
      Ctl3D = True
      CustomURLs = <
        item
          Name = 'e-mail'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'http'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'file'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'mailto'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'ftp'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'https'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'gopher'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'nntp'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'prospero'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'telnet'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'news'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end
        item
          Name = 'wais'
          Color = clWindowText
          Cursor = crDefault
          Underline = True
        end>
      LangOptions = [loAutoFont]
      Language = 1033
      ParentCtl3D = False
      PopupMenu = popOut
      ScrollBars = ssVertical
      ShowSelectionBar = False
      TabOrder = 0
      URLColor = clBlue
      URLCursor = crHandPoint
      WantTabs = True
      WordWrap = False
      OnKeyDown = MsgOutKeyDown
      OnKeyPress = MsgOutKeyPress
      OnKeyUp = MsgOutKeyUp
      AutoVerbMenu = False
      InputFormat = ifUnicode
      OutputFormat = ofUnicode
      SelectedInOut = False
      PlainRTF = False
      UndoLimit = 0
      AllowInPlace = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 380
    Height = 22
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 2
  end
  object popMsgList: TTntPopupMenu
    Left = 16
    Top = 120
    object Copy1: TTntMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object CopyAll1: TTntMenuItem
      Caption = 'Copy All'
      OnClick = CopyAll1Click
    end
    object Clear1: TTntMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
  end
  object popOut: TTntPopupMenu
    Left = 48
    Top = 120
    object Copy2: TTntMenuItem
      Caption = 'Cut'
      OnClick = Copy2Click
    end
    object Copy3: TTntMenuItem
      Caption = 'Copy'
      OnClick = Copy3Click
    end
    object Paste2: TTntMenuItem
      Caption = 'Paste '
      OnClick = Paste1Click
    end
    object N2: TTntMenuItem
      Caption = '-'
    end
    object Emoticons2: TTntMenuItem
      Caption = 'Emoticons'
      ShortCut = 16453
      OnClick = Emoticons1Click
    end
    object emot_sep: TTntMenuItem
      Caption = '-'
    end
  end
  object timWinFlash: TTimer
    Enabled = False
    Interval = 500
    OnTimer = timWinFlashTimer
    Left = 16
    Top = 88
  end
end
