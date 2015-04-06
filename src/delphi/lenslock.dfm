object lenslock1: Tlenslock1
  Left = 658
  Top = 538
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'LensLock'
  ClientHeight = 151
  ClientWidth = 172
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 27
    Top = 113
    Width = 43
    Height = 25
    Caption = 'Show'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object GroupBox2: TGroupBox
    Left = 16
    Top = 8
    Width = 137
    Height = 89
    Caption = 'LensLok'
    TabOrder = 1
    object Image1: TImage
      Left = 3
      Top = 16
      Width = 130
      Height = 60
    end
  end
  object BitBtn18: TBitBtn
    Left = 96
    Top = 113
    Width = 43
    Height = 25
    Caption = 'Close'
    TabOrder = 2
    OnClick = close_button
  end
end
