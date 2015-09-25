object SMSConfig: TSMSConfig
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'SMS Config'
  ClientHeight = 232
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 24
    Top = 152
    Width = 97
    Height = 49
    Caption = 'OK'
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 168
    Top = 152
    Width = 89
    Height = 49
    Caption = 'CANCEL'
    OnClick = SpeedButton2Click
  end
  object GroupBox1: TGroupBox
    Left = 24
    Top = 24
    Width = 89
    Height = 73
    Caption = 'Video'
    TabOrder = 0
    object RadioButton1: TRadioButton
      Left = 16
      Top = 24
      Width = 97
      Height = 17
      Caption = 'NTSC'
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 48
      Width = 97
      Height = 17
      Caption = 'PAL'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 168
    Top = 24
    Width = 89
    Height = 73
    Caption = 'BIOS'
    TabOrder = 1
    object RadioButton3: TRadioButton
      Left = 16
      Top = 24
      Width = 97
      Height = 17
      Caption = 'Enabled'
      TabOrder = 0
    end
    object RadioButton4: TRadioButton
      Left = 16
      Top = 48
      Width = 96
      Height = 17
      Caption = 'Disabled'
      TabOrder = 1
    end
  end
end
