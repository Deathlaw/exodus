inherited frmRegister: TfrmRegister
  Left = 246
  Top = 361
  Caption = 'Service Registration'
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited TntPanel1: TTntPanel
    inherited btnBack: TTntButton
      OnClick = btnPrevClick
    end
    inherited btnNext: TTntButton
      OnClick = btnNextClick
    end
    inherited btnCancel: TTntButton
      OnClick = btnCancelClick
    end
  end
  inherited Tabs: TPageControl
    ActivePage = TabSheet4
    inherited TabSheet1: TTabSheet
      object Label1: TTntLabel
        Left = 0
        Top = 0
        Width = 408
        Height = 90
        Align = alTop
        AutoSize = False
        Caption = 
          'This wizard will register you with a service or Agent. Use the N' +
          'ext button to advance through the steps. Use Cancel anytime to c' +
          'ancel this registration.'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object lblIns: TTntLabel
        Left = 0
        Top = 90
        Width = 408
        Height = 135
        Align = alClient
        AutoSize = False
        Caption = 'Waiting for agent instructions.....'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'TabSheet2'
      ImageIndex = 1
      object formBox: TScrollBox
        Left = 0
        Top = 0
        Width = 408
        Height = 193
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Ctl3D = True
        ParentCtl3D = False
        TabOrder = 0
      end
      object Panel2: TPanel
        Left = 0
        Top = 193
        Width = 408
        Height = 32
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object btnDelete: TTntButton
          Left = 243
          Top = 3
          Width = 161
          Height = 25
          Caption = 'Delete My Registration'
          TabOrder = 0
          OnClick = btnDeleteClick
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'TabSheet3'
      ImageIndex = 2
      object Label2: TTntLabel
        Left = 0
        Top = 0
        Width = 408
        Height = 90
        Align = alTop
        AutoSize = False
        Caption = 'Please wait, Sending your registration to the service....'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'TabSheet4'
      ImageIndex = 3
      object lblOK: TTntLabel
        Left = 0
        Top = 0
        Width = 408
        Height = 90
        Align = alTop
        AutoSize = False
        Caption = 
          'Your Registration to this service has been completed Successfull' +
          'y. Press the '#39'Next'#39' button to Finish.'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Visible = False
        WordWrap = True
      end
      object lblBad: TTntLabel
        Left = 0
        Top = 90
        Width = 408
        Height = 90
        Align = alTop
        AutoSize = False
        Caption = 
          'Your Registration to this service has Failed! Press Previous to ' +
          'go back and verify that all of the parameters have been filled i' +
          'n correctly. Press Cancel to close this wizard.'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Visible = False
        WordWrap = True
      end
    end
  end
end
