object frmGrpRemove: TfrmGrpRemove
  Left = 280
  Top = 173
  Width = 314
  Height = 205
  Caption = 'Remove Contacts'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inline frameButtons1: TframeButtons
    Left = 0
    Top = 137
    Width = 306
    Height = 34
    Align = alBottom
    AutoScroll = False
    TabOrder = 0
    inherited Bevel1: TBevel
      Width = 306
    end
    inherited Panel1: TPanel
      Left = 146
      Height = 29
      inherited btnOK: TButton
        OnClick = frameButtons1btnOKClick
      end
      inherited btnCancel: TButton
        OnClick = frameButtons1btnCancelClick
      end
    end
  end
  object optMove: TRadioButton
    Left = 8
    Top = 8
    Width = 249
    Height = 17
    Caption = 'Move contacts to another group:'
    Checked = True
    TabOrder = 1
    TabStop = True
  end
  object cboNewGroup: TComboBox
    Left = 24
    Top = 32
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    Sorted = True
    TabOrder = 2
  end
  object optNuke: TRadioButton
    Left = 8
    Top = 64
    Width = 209
    Height = 17
    Caption = 'Remove all contacts in this group:'
    TabOrder = 3
  end
  object chkUnsub: TCheckBox
    Left = 24
    Top = 88
    Width = 217
    Height = 17
    Caption = 'Remove these contacts from my roster.'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object chkUnsubed: TCheckBox
    Left = 24
    Top = 112
    Width = 265
    Height = 17
    Caption = 'Force the contacts to remove me from their roster'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
end
