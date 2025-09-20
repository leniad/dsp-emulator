object config_arcade: Tconfig_arcade
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Arcade Config'
  ClientHeight = 374
  ClientWidth = 818
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poDesktopCenter
  OnClose = FormClose
  OnKeyUp = FormKeyUp
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 257
    Height = 297
    Caption = 'DIP A'
    TabOrder = 2
  end
  object Button1: TButton
    Left = 208
    Top = 320
    Width = 121
    Height = 41
    Caption = 'OK'
    TabOrder = 1
    TabStop = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 496
    Top = 320
    Width = 121
    Height = 41
    Caption = 'CANCEL'
    TabOrder = 0
    TabStop = False
    OnClick = Button2Click
  end
  object GroupBox2: TGroupBox
    Left = 280
    Top = 8
    Width = 257
    Height = 297
    Caption = 'DIP B'
    TabOrder = 3
    Visible = False
  end
  object GroupBox3: TGroupBox
    Left = 552
    Top = 8
    Width = 257
    Height = 297
    Caption = 'DIP C'
    TabOrder = 4
    Visible = False
  end
end
