object frmRemove: TfrmRemove
  Left = 276
  Top = 147
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 2
  Caption = 'Remove Contact'
  ClientHeight = 157
  ClientWidth = 328
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 22
    Width = 328
    Height = 2
    Align = alTop
  end
  inline frameButtons1: TframeButtons
    Left = 0
    Top = 123
    Width = 328
    Height = 34
    Align = alBottom
    AutoScroll = False
    TabOrder = 1
    inherited Bevel1: TBevel
      Width = 328
    end
    inherited Panel1: TPanel
      Left = 168
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
    Top = 24
    Width = 249
    Height = 17
    Caption = 'Remove this contact from this group'
    TabOrder = 2
    OnClick = optRemoveClick
  end
  object optRemove: TRadioButton
    Left = 8
    Top = 48
    Width = 233
    Height = 17
    Caption = 'Remove this contact from my roster.'
    Checked = True
    TabOrder = 3
    TabStop = True
    OnClick = optRemoveClick
  end
  object chkRemove1: TCheckBox
    Left = 24
    Top = 72
    Width = 217
    Height = 17
    Caption = 'Remove this person from my roster.'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object chkRemove2: TCheckBox
    Left = 24
    Top = 96
    Width = 265
    Height = 17
    Caption = 'Force this person to remove me from their roster'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object lblJID: TTntStaticText
    Left = 0
    Top = 0
    Width = 328
    Height = 22
    Align = alTop
    Caption = 'foo@jabber.org'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial Unicode MS'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    TabOrder = 0
  end
end
