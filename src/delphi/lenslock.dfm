object lenslock1: Tlenslock1
  Left = 658
  Top = 538
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'LensLock'
  ClientHeight = 193
  ClientWidth = 166
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 17
    Top = 153
    Width = 43
    Height = 25
    Caption = 'Show'
    TabOrder = 0
    TabStop = False
    OnClick = BitBtn1Click
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 145
    Height = 89
    Caption = 'LensLok'
    TabOrder = 1
    object Image1: TImage
      Left = 9
      Top = 19
      Width = 127
      Height = 57
    end
  end
  object BitBtn18: TBitBtn
    Left = 101
    Top = 153
    Width = 43
    Height = 25
    Caption = 'Close'
    TabOrder = 2
    TabStop = False
    OnClick = close_button
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 112
    Width = 137
    Height = 21
    TabOrder = 3
    TabStop = False
    Text = 'ComboBox1'
    OnChange = ComboBox1Change
  end
end
