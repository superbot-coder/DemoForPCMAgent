object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Demo for "PCMonitoringAgent"'
  ClientHeight = 742
  ClientWidth = 745
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    745
    742)
  TextHeight = 15
  object LblPostFile: TLabel
    Left = 143
    Top = 235
    Width = 57
    Height = 15
    Caption = 'LblPostFile'
  end
  object Label1: TLabel
    Left = 279
    Top = 14
    Width = 54
    Height = 15
    Caption = 'URL Path: '
  end
  object LblPort: TLabel
    Left = 183
    Top = 14
    Width = 25
    Height = 15
    Caption = 'Port:'
  end
  object LblHostName: TLabel
    Left = 8
    Top = 14
    Width = 63
    Height = 15
    Caption = 'Host Name:'
  end
  object BtnUpdate: TButton
    Left = 567
    Top = 30
    Width = 106
    Height = 25
    Caption = 'Update'
    TabOrder = 0
    OnClick = BtnUpdateClick
  end
  object mm: TMemo
    Left = 8
    Top = 272
    Width = 724
    Height = 462
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitHeight = 356
  end
  object BtnOpenFile: TButton
    Left = 8
    Top = 231
    Width = 105
    Height = 25
    Caption = 'Open File'
    TabOrder = 2
    OnClick = BtnOpenFileClick
  end
  object LblEdUpdateKey: TLabeledEdit
    Left = 8
    Top = 134
    Width = 416
    Height = 23
    EditLabel.Width = 153
    EditLabel.Height = 15
    EditLabel.Caption = #1040#1087#1076#1077#1081#1090' '#1050#1083#1102#1095': / Update  Key:'
    TabOrder = 3
    Text = ''
  end
  object BtnGet: TButton
    Left = 441
    Top = 30
    Width = 105
    Height = 25
    Caption = 'Get Command'
    TabOrder = 4
    OnClick = BtnGetClick
  end
  object CmBoxURLPath: TComboBox
    Left = 279
    Top = 31
    Width = 145
    Height = 23
    Style = csDropDownList
    TabOrder = 5
    Items.Strings = (
      '/access_key'
      '/aida64_sensors'
      '/aida64_sensors.json'
      '/test_authorization'
      '/cpu_info'
      '/cpu_info.json'
      '/ohm_sensors'
      '/ohm_sensors.json'
      '/reboot'
      '/shellexecute'
      '/shutdown'
      '/test_authorization'
      '/version')
  end
  object lblEdPrivatKey: TLabeledEdit
    Left = 8
    Top = 80
    Width = 416
    Height = 23
    EditLabel.Width = 55
    EditLabel.Height = 15
    EditLabel.Caption = 'Privat Key:'
    TabOrder = 6
    Text = ''
  end
  object SpEdPort: TSpinEdit
    Left = 183
    Top = 31
    Width = 90
    Height = 24
    MaxValue = 65535
    MinValue = 1
    TabOrder = 7
    Value = 2424
  end
  object LblEdParam: TLabeledEdit
    Left = 8
    Top = 184
    Width = 145
    Height = 23
    EditLabel.Width = 92
    EditLabel.Height = 15
    EditLabel.Caption = 'Header Parametr:'
    TabOrder = 8
    Text = 'shell_execute'
  end
  object LblEdParamValue: TLabeledEdit
    Left = 159
    Top = 184
    Width = 265
    Height = 23
    EditLabel.Width = 82
    EditLabel.Height = 15
    EditLabel.Caption = 'Parametr Value:'
    TabOrder = 9
    Text = 'win32calc.exe'
  end
  object ChBoxHeaderEnabled: TCheckBox
    Left = 441
    Top = 187
    Width = 97
    Height = 17
    Caption = 'Header Enabled'
    TabOrder = 10
  end
  object ChBoxPrivatKey: TCheckBox
    Left = 441
    Top = 83
    Width = 97
    Height = 17
    Caption = 'Use Privat Key'
    TabOrder = 11
  end
  object CmBoxHostName: TComboBox
    Left = 8
    Top = 31
    Width = 169
    Height = 23
    TabOrder = 12
    Text = 'localhost'
  end
  object BtnSaveAllKey: TButton
    Left = 441
    Top = 133
    Width = 105
    Height = 25
    Caption = 'Save Keys'
    TabOrder = 13
    OnClick = BtnSaveAllKeyClick
  end
  object OpenDialog: TOpenDialog
    Left = 456
    Top = 432
  end
  object LbRijndael: TLbRijndael
    CipherMode = cmECB
    KeySize = ks128
    Left = 344
    Top = 432
  end
end
