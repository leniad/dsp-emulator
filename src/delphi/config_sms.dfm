object SMSConfig: TSMSConfig
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'SMS Config'
  ClientHeight = 214
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 24
    Top = 157
    Width = 97
    Height = 49
    Caption = 'OK'
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 168
    Top = 157
    Width = 89
    Height = 49
    Caption = 'CANCEL'
    OnClick = SpeedButton2Click
  end
  object GroupBox1: TGroupBox
    Left = 63
    Top = 24
    Width = 161
    Height = 113
    Caption = 'SMS BIOS'
    TabOrder = 0
    object RadioButton1: TRadioButton
      Left = 16
      Top = 25
      Width = 137
      Height = 17
      Caption = 'Japan/Korea (NTSC)'
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 48
      Width = 138
      Height = 17
      Caption = 'Europe/Australia (PAL)'
      TabOrder = 1
    end
    object RadioButton3: TRadioButton
      Left = 16
      Top = 71
      Width = 97
      Height = 17
      Caption = 'US/Brazil (NTSC)'
      TabOrder = 2
    end
  end
end
