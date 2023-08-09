object configgb: Tconfiggb
  Left = 0
  Top = 0
  Caption = 'Config GB/GBC'
  ClientHeight = 203
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object GroupBox7: TGroupBox
    Left = 47
    Top = 31
    Width = 170
    Height = 64
    Caption = 'Screen'
    TabOrder = 0
    object RadioButton1: TRadioButton
      Left = 14
      Top = 15
      Width = 147
      Height = 17
      Caption = 'Gameboy Original - Green'
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 13
      Top = 38
      Width = 148
      Height = 17
      Caption = 'Gameboy Pocket - BW'
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 37
    Top = 134
    Width = 105
    Height = 49
    Caption = 'OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 191
    Top = 134
    Width = 105
    Height = 49
    Caption = 'CANCEL'
    TabOrder = 2
    OnClick = Button2Click
  end
end
