inherited frmPrefFont: TfrmPrefFont
  Left = 256
  Top = 192
  Caption = 'frmPrefFont'
  ClientHeight = 349
  ClientWidth = 403
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lblRoster: TTntLabel [0]
    Left = 8
    Top = 56
    Width = 73
    Height = 13
    Caption = 'Roster Window'
  end
  object lblChat: TTntLabel [1]
    Left = 136
    Top = 56
    Width = 69
    Height = 13
    Caption = 'Chat Windows'
  end
  object Label24: TTntLabel [2]
    Left = 8
    Top = 186
    Width = 88
    Height = 13
    Caption = 'Background Color:'
  end
  object Label25: TTntLabel [3]
    Left = 8
    Top = 210
    Width = 51
    Height = 13
    Caption = 'Font Color:'
  end
  object Label5: TTntLabel [4]
    Left = 8
    Top = 32
    Width = 283
    Height = 13
    Caption = 'Click on the appropriate font or window to change elements.'
  end
  object lblColor: TTntLabel [5]
    Left = 8
    Top = 168
    Width = 69
    Height = 13
    Caption = 'Element Name'
  end
  object clrBoxBG: TColorBox [6]
    Left = 135
    Top = 183
    Width = 170
    Height = 22
    DefaultColorColor = clBlue
    Selected = clBlue
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    DropDownCount = 12
    ItemHeight = 16
    TabOrder = 2
    OnChange = clrBoxBGChange
  end
  object clrBoxFont: TColorBox [7]
    Left = 135
    Top = 207
    Width = 170
    Height = 22
    DefaultColorColor = clBlue
    Selected = clBlue
    Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
    DropDownCount = 12
    ItemHeight = 16
    TabOrder = 3
    OnChange = clrBoxFontChange
  end
  object btnFont: TTntButton [8]
    Left = 135
    Top = 234
    Width = 90
    Height = 25
    Caption = 'Change Font'
    TabOrder = 4
    OnClick = btnFontClick
  end
  object colorChat: TExRichEdit [9]
    Left = 136
    Top = 72
    Width = 225
    Height = 89
    AutoURLDetect = adNone
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
    ReadOnly = True
    ScrollBars = ssBoth
    ShowSelectionBar = False
    TabOrder = 1
    URLColor = clBlue
    URLCursor = crHandPoint
    WordWrap = False
    OnMouseUp = colorChatMouseUp
    InputFormat = ifRTF
    OutputFormat = ofRTF
    SelectedInOut = False
    PlainRTF = False
    UndoLimit = 0
    AllowInPlace = False
  end
  inherited pnlHeader: TTntPanel
    Width = 403
    Caption = 'Fonts and Colors'
    TabOrder = 5
  end
  object colorRoster: TTntTreeView
    Left = 8
    Top = 72
    Width = 121
    Height = 90
    BevelWidth = 0
    Indent = 19
    ReadOnly = True
    ShowButtons = False
    ShowLines = False
    TabOrder = 0
    OnMouseDown = colorRosterMouseDown
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = []
    Left = 301
    Top = 27
  end
end
