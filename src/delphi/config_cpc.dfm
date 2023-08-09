object ConfigCPC: TConfigCPC
  Left = 629
  Top = 295
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Config CPC'
  ClientHeight = 420
  ClientWidth = 586
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poDesigned
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object GroupBox1: TGroupBox
    Tag = 1
    Left = 8
    Top = 8
    Width = 313
    Height = 143
    Caption = 'CPC Low ROM'
    TabOrder = 2
    object RadioButton1: TRadioButton
      Tag = 1
      Left = 16
      Top = 13
      Width = 121
      Height = 25
      Caption = 'UK'
      TabOrder = 1
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 33
      Width = 121
      Height = 25
      Caption = 'French'
      TabOrder = 0
    end
    object RadioButton3: TRadioButton
      Left = 16
      Top = 56
      Width = 121
      Height = 25
      Caption = 'Spanish'
      TabOrder = 2
    end
    object RadioButton4: TRadioButton
      Left = 16
      Top = 78
      Width = 121
      Height = 25
      Caption = 'Danish'
      TabOrder = 3
    end
    object RadioButton8: TRadioButton
      Left = 16
      Top = 99
      Width = 121
      Height = 25
      Caption = 'Other'
      TabOrder = 4
    end
    object Edit7: TEdit
      Left = 8
      Top = 119
      Width = 265
      Height = 21
      TabStop = False
      TabOrder = 5
    end
    object Button15: TButton
      Left = 277
      Top = 115
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 6
      TabStop = False
      OnClick = Button15Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 157
    Width = 570
    Height = 194
    Caption = 'ROM Slots'
    TabOrder = 5
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
      Width = 428
      Height = 21
      TabStop = False
      TabOrder = 0
    end
    object Button1: TButton
      Left = 487
      Top = 19
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 1
      TabStop = False
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 526
      Top = 19
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 2
      TabStop = False
      OnClick = Button2Click
    end
    object Edit2: TEdit
      Left = 53
      Top = 48
      Width = 428
      Height = 21
      TabStop = False
      TabOrder = 3
    end
    object Button3: TButton
      Left = 487
      Top = 46
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 4
      TabStop = False
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 526
      Top = 46
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 5
      TabStop = False
      OnClick = Button4Click
    end
    object Edit3: TEdit
      Left = 53
      Top = 75
      Width = 428
      Height = 21
      TabStop = False
      TabOrder = 6
    end
    object Button5: TButton
      Left = 487
      Top = 73
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 7
      TabStop = False
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 526
      Top = 73
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 8
      TabStop = False
      OnClick = Button6Click
    end
    object Edit4: TEdit
      Left = 53
      Top = 102
      Width = 428
      Height = 21
      TabStop = False
      TabOrder = 9
    end
    object Button7: TButton
      Left = 487
      Top = 100
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 10
      TabStop = False
      OnClick = Button7Click
    end
    object Button8: TButton
      Left = 526
      Top = 100
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 11
      TabStop = False
      OnClick = Button8Click
    end
    object Edit5: TEdit
      Left = 53
      Top = 129
      Width = 428
      Height = 21
      TabStop = False
      TabOrder = 12
    end
    object Button9: TButton
      Left = 487
      Top = 127
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 13
      TabStop = False
      OnClick = Button9Click
    end
    object Button10: TButton
      Left = 526
      Top = 127
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 14
      TabStop = False
      OnClick = Button10Click
    end
    object Edit6: TEdit
      Left = 53
      Top = 156
      Width = 428
      Height = 21
      TabStop = False
      TabOrder = 15
    end
    object Button11: TButton
      Left = 487
      Top = 154
      Width = 33
      Height = 25
      Caption = 'Open'
      TabOrder = 16
      TabStop = False
      OnClick = Button11Click
    end
    object Button12: TButton
      Left = 526
      Top = 154
      Width = 33
      Height = 25
      Caption = 'Clear'
      TabOrder = 17
      TabStop = False
      OnClick = Button12Click
    end
  end
  object Button13: TButton
    Left = 116
    Top = 357
    Width = 105
    Height = 49
    Caption = 'OK'
    TabOrder = 0
    TabStop = False
    OnClick = Button13Click
  end
  object Button14: TButton
    Left = 346
    Top = 357
    Width = 105
    Height = 49
    Caption = 'CANCEL'
    TabOrder = 1
    TabStop = False
    OnClick = Button14Click
  end
  object GroupBox7: TGroupBox
    Left = 327
    Top = 87
    Width = 98
    Height = 64
    Caption = 'LensLok'
    TabOrder = 6
    object RadioButton12: TRadioButton
      Left = 16
      Top = 17
      Width = 71
      Height = 17
      Caption = 'Enabled'
      TabOrder = 1
    end
    object RadioButton13: TRadioButton
      Left = 16
      Top = 38
      Width = 72
      Height = 17
      Caption = 'Disabled'
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 327
    Top = 8
    Width = 98
    Height = 77
    Caption = 'RAM Expansion'
    TabOrder = 3
    object RadioButton5: TRadioButton
      Left = 16
      Top = 17
      Width = 73
      Height = 17
      Caption = 'Disabled'
      TabOrder = 2
    end
    object RadioButton6: TRadioButton
      Tag = 1
      Left = 16
      Top = 38
      Width = 62
      Height = 16
      Caption = '512Kb'
      TabOrder = 0
    end
    object RadioButton7: TRadioButton
      Left = 16
      Top = 56
      Width = 64
      Height = 17
      Caption = '4Mb'
      Enabled = False
      TabOrder = 1
    end
  end
  object GroupBox4: TGroupBox
    Left = 431
    Top = 8
    Width = 147
    Height = 103
    Caption = 'Monitor'
    TabOrder = 4
    object RadioButton9: TRadioButton
      Tag = 1
      Left = 13
      Top = 15
      Width = 71
      Height = 17
      Caption = 'Color'
      TabOrder = 0
      OnClick = RadioButton9Click
    end
    object RadioButton10: TRadioButton
      Left = 13
      Top = 35
      Width = 72
      Height = 17
      Caption = 'Green'
      TabOrder = 1
      OnClick = RadioButton10Click
    end
    object GroupBox5: TGroupBox
      Left = 2
      Top = 55
      Width = 143
      Height = 45
      Caption = 'Brillo/Brightness'
      TabOrder = 2
      object TrackBar1: TTrackBar
        Left = 1
        Top = 12
        Width = 140
        Height = 28
        Max = 4
        Min = 1
        Position = 1
        ShowSelRange = False
        TabOrder = 0
        TabStop = False
        TickMarks = tmTopLeft
      end
    end
  end
end
