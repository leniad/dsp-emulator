object ConfigCPC: TConfigCPC
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Config CPC'
  ClientHeight = 404
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 153
    Height = 121
    Caption = 'CPC Type'
    TabOrder = 0
    object RadioButton1: TRadioButton
      Left = 16
      Top = 16
      Width = 121
      Height = 25
      Caption = 'UK'
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 40
      Width = 121
      Height = 25
      Caption = 'French'
      TabOrder = 1
    end
    object RadioButton3: TRadioButton
      Left = 16
      Top = 64
      Width = 121
      Height = 25
      Caption = 'Spanish'
      TabOrder = 2
    end
    object RadioButton4: TRadioButton
      Left = 16
      Top = 88
      Width = 121
      Height = 25
      Caption = 'Danish'
      TabOrder = 3
    end
  end
  object GroupBox2: TGroupBox
    Left = 10
    Top = 135
    Width = 439
    Height = 194
    Caption = 'ROMS'
    TabOrder = 1
    object Label1: TLabel
      Left = 13
      Top = 24
      Width = 34
      Height = 13
      Caption = 'SLOT 1'
    end
    object Label2: TLabel
      Left = 13
      Top = 51
      Width = 34
      Height = 13
      Caption = 'SLOT 2'
    end
    object Label3: TLabel
      Left = 13
      Top = 78
      Width = 34
      Height = 13
      Caption = 'SLOT 3'
    end
    object Label4: TLabel
      Left = 13
      Top = 105
      Width = 34
      Height = 13
      Caption = 'SLOT 4'
    end
    object Label5: TLabel
      Left = 13
      Top = 132
      Width = 34
      Height = 13
      Caption = 'SLOT 5'
    end
    object Label6: TLabel
      Left = 13
      Top = 159
      Width = 34
      Height = 13
      Caption = 'SLOT 6'
    end
    object Edit1: TEdit
      Left = 53
      Top = 21
      Width = 297
      Height = 21
      TabOrder = 0
    end
    object Button1: TButton
      Left = 356
      Top = 19
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 395
      Top = 19
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 2
      OnClick = Button2Click
    end
    object Edit2: TEdit
      Left = 53
      Top = 48
      Width = 297
      Height = 21
      TabOrder = 3
    end
    object Button3: TButton
      Left = 356
      Top = 46
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 4
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 395
      Top = 46
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 5
      OnClick = Button4Click
    end
    object Edit3: TEdit
      Left = 53
      Top = 75
      Width = 297
      Height = 21
      TabOrder = 6
    end
    object Button5: TButton
      Left = 356
      Top = 73
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 7
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 395
      Top = 73
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 8
      OnClick = Button6Click
    end
    object Edit4: TEdit
      Left = 53
      Top = 102
      Width = 297
      Height = 21
      TabOrder = 9
    end
    object Button7: TButton
      Left = 356
      Top = 100
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 10
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 395
      Top = 100
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 11
      OnClick = Button8Click
    end
    object Edit5: TEdit
      Left = 53
      Top = 129
      Width = 297
      Height = 21
      TabOrder = 12
    end
    object Button9: TButton
      Left = 356
      Top = 127
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 13
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 395
      Top = 127
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 14
      OnClick = Button10Click
    end
    object Edit6: TEdit
      Left = 53
      Top = 156
      Width = 297
      Height = 21
      TabOrder = 15
    end
    object Button11: TButton
      Left = 356
      Top = 154
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 16
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 395
      Top = 154
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 17
      OnClick = Button12Click
    end
  end
  object Button13: TButton
    Left = 56
    Top = 347
    Width = 105
    Height = 49
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 255
    Top = 347
    Width = 105
    Height = 49
    Caption = 'CANCEL'
    TabOrder = 3
    OnClick = Button14Click
  end
end
