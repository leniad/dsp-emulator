object ConfigSP: TConfigSP
  Left = 329
  Top = 154
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Configurar'
  ClientHeight = 434
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 7
    Top = 6
    Width = 488
    Height = 374
    Caption = 'Spectrum'
    TabOrder = 2
    object GroupBox2: TGroupBox
      Left = 69
      Top = 316
      Width = 361
      Height = 49
      Caption = 'ROM'
      TabOrder = 0
      object Edit1: TEdit
        Left = 9
        Top = 16
        Width = 297
        Height = 21
        TabOrder = 0
        OnKeyUp = FormKeyUp
      end
      object Button3: TButton
        Left = 312
        Top = 16
        Width = 41
        Height = 25
        Caption = 'Open'
        TabOrder = 1
        OnClick = Button3Click
        OnKeyUp = FormKeyUp
      end
    end
    object GroupBox3: TGroupBox
      Left = 10
      Top = 16
      Width = 109
      Height = 73
      Caption = 'Spectrum 48K Issue'
      TabOrder = 1
      object RadioButton1: TRadioButton
        Left = 13
        Top = 20
        Width = 64
        Height = 17
        Caption = 'Issue 2'
        TabOrder = 0
        OnKeyUp = FormKeyUp
      end
      object RadioButton2: TRadioButton
        Left = 13
        Top = 43
        Width = 66
        Height = 17
        Caption = 'Issue 3'
        TabOrder = 1
        OnKeyUp = FormKeyUp
      end
    end
    object GroupBox5: TGroupBox
      Left = 10
      Top = 167
      Width = 109
      Height = 90
      Caption = 'Border Emulation'
      TabOrder = 2
      object RadioButton7: TRadioButton
        Left = 13
        Top = 17
        Width = 60
        Height = 17
        Caption = 'None'
        TabOrder = 0
        OnKeyUp = FormKeyUp
      end
      object RadioButton8: TRadioButton
        Left = 13
        Top = 40
        Width = 65
        Height = 17
        Caption = 'Normal'
        TabOrder = 1
        OnKeyUp = FormKeyUp
      end
      object RadioButton9: TRadioButton
        Left = 13
        Top = 63
        Width = 57
        Height = 17
        Caption = 'Full'
        TabOrder = 2
        OnKeyUp = FormKeyUp
      end
    end
    object GroupBox7: TGroupBox
      Left = 10
      Top = 95
      Width = 109
      Height = 66
      Caption = 'LensLok'
      TabOrder = 3
      object RadioButton12: TRadioButton
        Left = 13
        Top = 17
        Width = 71
        Height = 17
        Caption = 'Enabled'
        TabOrder = 0
        OnKeyUp = FormKeyUp
      end
      object RadioButton13: TRadioButton
        Left = 13
        Top = 40
        Width = 72
        Height = 17
        Caption = 'Disabled'
        TabOrder = 1
        OnKeyUp = FormKeyUp
      end
    end
    object GroupBox11: TGroupBox
      Left = 130
      Top = 151
      Width = 348
      Height = 162
      Caption = 'Audio'
      TabOrder = 4
      object GroupBox8: TGroupBox
        Left = 11
        Top = 15
        Width = 120
        Height = 78
        Caption = 'Spectrum 128K Audio'
        TabOrder = 0
        object RadioButton14: TRadioButton
          Left = 13
          Top = 17
          Width = 65
          Height = 17
          Caption = 'Mono'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object RadioButton15: TRadioButton
          Left = 13
          Top = 35
          Width = 81
          Height = 17
          Caption = 'Stereo ABC'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
        object RadioButton16: TRadioButton
          Left = 13
          Top = 54
          Width = 83
          Height = 18
          Caption = 'Stereo ACB'
          TabOrder = 2
          OnKeyUp = FormKeyUp
        end
      end
      object GroupBox10: TGroupBox
        Left = 137
        Top = 15
        Width = 94
        Height = 66
        Caption = 'Load Audio'
        TabOrder = 1
        object RadioButton21: TRadioButton
          Left = 13
          Top = 17
          Width = 68
          Height = 17
          Caption = 'Enabled'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object RadioButton22: TRadioButton
          Left = 13
          Top = 40
          Width = 69
          Height = 17
          Caption = 'Disabled'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
      end
      object GroupBox9: TGroupBox
        Left = 241
        Top = 15
        Width = 95
        Height = 66
        Caption = 'Beeper Filter'
        TabOrder = 2
        object RadioButton17: TRadioButton
          Left = 13
          Top = 17
          Width = 70
          Height = 17
          Caption = 'Enabled'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object RadioButton18: TRadioButton
          Left = 13
          Top = 40
          Width = 72
          Height = 17
          Caption = 'Disabled'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
      end
      object GroupBox13: TGroupBox
        Left = 12
        Top = 93
        Width = 317
        Height = 61
        Caption = 'Beeper Oversample'
        TabOrder = 3
        object Label1: TLabel
          Left = 12
          Top = 43
          Width = 11
          Height = 13
          Caption = '1x'
        end
        object Label2: TLabel
          Left = 84
          Top = 43
          Width = 11
          Height = 13
          Caption = '2x'
        end
        object Label3: TLabel
          Left = 152
          Top = 43
          Width = 11
          Height = 13
          Caption = '3x'
        end
        object Label4: TLabel
          Left = 225
          Top = 43
          Width = 11
          Height = 13
          Caption = '4x'
        end
        object Label5: TLabel
          Left = 292
          Top = 41
          Width = 11
          Height = 13
          Caption = '5x'
        end
        object TrackBar1: TTrackBar
          Left = 7
          Top = 16
          Width = 305
          Height = 27
          Max = 5
          Min = 1
          Position = 1
          SelEnd = 1
          SelStart = 5
          TabOrder = 0
        end
      end
    end
    object GroupBox12: TGroupBox
      Left = 130
      Top = 16
      Width = 222
      Height = 129
      Caption = 'Input'
      TabOrder = 5
      object GroupBox4: TGroupBox
        Left = 12
        Top = 13
        Width = 96
        Height = 106
        Caption = 'Joystick'
        TabOrder = 0
        object RadioButton3: TRadioButton
          Left = 5
          Top = 14
          Width = 79
          Height = 17
          Caption = 'Kempston'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object RadioButton4: TRadioButton
          Left = 5
          Top = 32
          Width = 88
          Height = 17
          Caption = 'Cursor/Protek'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
        object RadioButton5: TRadioButton
          Left = 5
          Top = 50
          Width = 89
          Height = 17
          Caption = 'Sinclair 1/IF 2'
          TabOrder = 2
          OnKeyUp = FormKeyUp
        end
        object RadioButton6: TRadioButton
          Left = 5
          Top = 68
          Width = 89
          Height = 17
          Caption = 'Sinclair 2/IF 2'
          TabOrder = 3
          OnKeyUp = FormKeyUp
        end
        object RadioButton25: TRadioButton
          Left = 5
          Top = 86
          Width = 89
          Height = 17
          Caption = 'Fuller'
          TabOrder = 4
          OnKeyUp = FormKeyUp
        end
      end
      object GroupBox6: TGroupBox
        Left = 118
        Top = 13
        Width = 93
        Height = 106
        Caption = 'Mouse'
        TabOrder = 1
        object RadioButton10: TRadioButton
          Left = 13
          Top = 20
          Width = 65
          Height = 17
          Caption = 'Disabled'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object RadioButton11: TRadioButton
          Left = 13
          Top = 39
          Width = 73
          Height = 17
          Caption = 'GunStick'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
        object RadioButton19: TRadioButton
          Left = 13
          Top = 59
          Width = 73
          Height = 17
          Caption = 'Kempston'
          TabOrder = 2
          OnKeyUp = FormKeyUp
        end
        object RadioButton20: TRadioButton
          Left = 13
          Top = 82
          Width = 73
          Height = 14
          Caption = 'AMX'
          TabOrder = 3
          OnKeyUp = FormKeyUp
        end
      end
    end
    object GroupBox14: TGroupBox
      Left = 360
      Top = 16
      Width = 111
      Height = 77
      Caption = 'ULA +'
      TabOrder = 6
      object RadioButton23: TRadioButton
        Left = 13
        Top = 20
        Width = 64
        Height = 17
        Caption = 'Enabled'
        TabOrder = 0
        OnKeyUp = FormKeyUp
      end
      object RadioButton24: TRadioButton
        Left = 13
        Top = 43
        Width = 66
        Height = 17
        Caption = 'Disabled'
        TabOrder = 1
        OnKeyUp = FormKeyUp
      end
    end
  end
  object Button1: TButton
    Left = 85
    Top = 393
    Width = 89
    Height = 33
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object Button2: TButton
    Left = 287
    Top = 393
    Width = 89
    Height = 33
    Caption = 'CANCELAR'
    TabOrder = 1
    OnClick = Button2Click
    OnKeyUp = FormKeyUp
  end
end
