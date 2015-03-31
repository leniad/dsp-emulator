object MConfig: TMConfig
  Left = 304
  Top = 188
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Configurar DSP'
  ClientHeight = 420
  ClientWidth = 410
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
  object Label12: TLabel
    Left = 7
    Top = 265
    Width = 25
    Height = 13
    Caption = 'But 2'
  end
  object Label13: TLabel
    Left = 7
    Top = 218
    Width = 25
    Height = 13
    Caption = 'But 0'
  end
  object Label14: TLabel
    Left = 7
    Top = 242
    Width = 25
    Height = 13
    Caption = 'But 1'
  end
  object Button1: TButton
    Left = 48
    Top = 367
    Width = 113
    Height = 41
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object Button2: TButton
    Left = 232
    Top = 367
    Width = 113
    Height = 41
    Caption = 'CANCELAR'
    TabOrder = 1
    OnClick = Button2Click
    OnKeyUp = FormKeyUp
  end
  object other: TPageControl
    Left = 3
    Top = 8
    Width = 399
    Height = 353
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Misc'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBox3: TGroupBox
        Left = 6
        Top = 13
        Width = 169
        Height = 147
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object RadioButton6: TRadioButton
          Left = 35
          Top = 28
          Width = 105
          Height = 17
          Caption = 'English'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object RadioButton5: TRadioButton
          Left = 35
          Top = 9
          Width = 105
          Height = 17
          Caption = 'Castellano'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object RadioButton7: TRadioButton
          Left = 35
          Top = 46
          Width = 105
          Height = 17
          Caption = 'Catal'#224
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object RadioButton8: TRadioButton
          Left = 35
          Top = 64
          Width = 105
          Height = 17
          Caption = 'Francais'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
        end
        object RadioButton9: TRadioButton
          Left = 35
          Top = 82
          Width = 105
          Height = 17
          Caption = 'German'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
        end
        object RadioButton10: TRadioButton
          Left = 35
          Top = 100
          Width = 105
          Height = 17
          Caption = 'Brazil'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
        end
        object RadioButton11: TRadioButton
          Left = 35
          Top = 118
          Width = 105
          Height = 17
          Caption = 'Italian'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
        end
      end
      object GroupBox4: TGroupBox
        Left = 181
        Top = 13
        Width = 203
        Height = 147
        Caption = 'Audio'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object RadioButton12: TRadioButton
          Left = 40
          Top = 27
          Width = 121
          Height = 17
          Caption = '11025'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object RadioButton13: TRadioButton
          Left = 40
          Top = 51
          Width = 121
          Height = 17
          Caption = '22050'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
        object RadioButton14: TRadioButton
          Left = 40
          Top = 75
          Width = 121
          Height = 17
          Caption = '44100'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
        end
        object RadioButton15: TRadioButton
          Left = 40
          Top = 98
          Width = 121
          Height = 17
          Caption = 'No sound'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
        end
      end
      object GroupBox5: TGroupBox
        Left = 6
        Top = 165
        Width = 378
        Height = 81
        Caption = 'Video'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
        object RadioButton16: TRadioButton
          Left = 35
          Top = 17
          Width = 81
          Height = 17
          Caption = '1X'
          TabOrder = 0
        end
        object RadioButton17: TRadioButton
          Left = 35
          Top = 36
          Width = 81
          Height = 17
          Caption = '2X'
          TabOrder = 1
        end
        object RadioButton18: TRadioButton
          Left = 195
          Top = 20
          Width = 97
          Height = 14
          Caption = 'Scanlines'
          TabOrder = 2
        end
        object RadioButton19: TRadioButton
          Left = 195
          Top = 40
          Width = 97
          Height = 13
          Caption = 'Scanlines 2X'
          TabOrder = 3
        end
        object RadioButton20: TRadioButton
          Left = 35
          Top = 56
          Width = 81
          Height = 17
          Caption = '3X'
          TabOrder = 4
        end
      end
      object GroupBox6: TGroupBox
        Left = 6
        Top = 249
        Width = 378
        Height = 66
        Caption = 'Misc'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        object CheckBox2: TCheckBox
          Left = 29
          Top = 11
          Width = 284
          Height = 17
          TabStop = False
          Caption = 'Arrancar driver en inicio / Load driver at start'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object CheckBox1: TCheckBox
          Left = 29
          Top = 29
          Width = 338
          Height = 17
          TabStop = False
          Caption = 'Mostar errores CRC de la ROM/Show CRC ROM errors'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
        object CheckBox3: TCheckBox
          Left = 29
          Top = 46
          Width = 338
          Height = 17
          TabStop = False
          Caption = 'Centrar pantalla principal/Center main screen'
          TabOrder = 2
          OnKeyUp = FormKeyUp
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Directory'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 5
        Top = 13
        Width = 86
        Height = 13
        Caption = 'Nintendo - Nes'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton1: TSpeedButton
        Left = 365
        Top = 28
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton1Click
      end
      object SpeedButton2: TSpeedButton
        Left = 365
        Top = 76
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton2Click
      end
      object Label2: TLabel
        Left = 5
        Top = 61
        Width = 58
        Height = 13
        Caption = 'Game Boy'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton3: TSpeedButton
        Left = 365
        Top = 124
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton3Click
      end
      object Label3: TLabel
        Left = 5
        Top = 109
        Width = 73
        Height = 13
        Caption = 'Colecovision'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label4: TLabel
        Left = 5
        Top = 157
        Width = 41
        Height = 13
        Caption = 'Arcade'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton4: TSpeedButton
        Left = 365
        Top = 172
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton4Click
      end
      object Label5: TLabel
        Left = 3
        Top = 212
        Width = 88
        Height = 13
        Caption = 'Arcade Hiscore'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton5: TSpeedButton
        Left = 365
        Top = 228
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton5Click
      end
      object d1: TEdit
        Left = 5
        Top = 28
        Width = 354
        Height = 21
        TabOrder = 0
      end
      object d2: TEdit
        Left = 5
        Top = 76
        Width = 354
        Height = 21
        TabOrder = 1
      end
      object d3: TEdit
        Left = 5
        Top = 124
        Width = 354
        Height = 21
        TabOrder = 2
      end
      object d4: TEdit
        Left = 5
        Top = 172
        Width = 354
        Height = 21
        TabOrder = 3
      end
      object d5: TEdit
        Left = 3
        Top = 228
        Width = 354
        Height = 21
        TabOrder = 4
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Input'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBox1: TGroupBox
        Left = 7
        Top = 13
        Width = 187
        Height = 292
        Caption = 'Player 1'
        TabOrder = 0
        object Label6: TLabel
          Left = 7
          Top = 218
          Width = 25
          Height = 13
          Caption = 'But 0'
        end
        object Label7: TLabel
          Left = 7
          Top = 242
          Width = 25
          Height = 13
          Caption = 'But 1'
        end
        object Label8: TLabel
          Left = 7
          Top = 265
          Width = 25
          Height = 13
          Caption = 'But 2'
        end
        object Label15: TLabel
          Left = 95
          Top = 218
          Width = 25
          Height = 13
          Caption = 'But 3'
        end
        object Label16: TLabel
          Left = 96
          Top = 242
          Width = 25
          Height = 13
          Caption = 'But 4'
        end
        object Label17: TLabel
          Left = 96
          Top = 265
          Width = 25
          Height = 13
          Caption = 'But 5'
        end
        object RadioButton1: TRadioButton
          Left = 11
          Top = 25
          Width = 70
          Height = 17
          Caption = 'Keyboard'
          TabOrder = 0
          OnClick = RadioButton1Click
        end
        object RadioButton2: TRadioButton
          Left = 11
          Top = 52
          Width = 70
          Height = 17
          Caption = 'Joystick'
          TabOrder = 1
          OnClick = RadioButton2Click
        end
        object ComboBox1: TComboBox
          Left = 14
          Top = 75
          Width = 155
          Height = 21
          TabOrder = 2
          TabStop = False
          Text = 'ComboBox1'
        end
        object BitBtn2: TBitBtn
          Left = 116
          Top = 138
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = BitBtn2Click
        end
        object BitBtn3: TBitBtn
          Left = 69
          Top = 172
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnClick = BitBtn3Click
        end
        object BitBtn1: TBitBtn
          Left = 24
          Top = 138
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
          OnClick = BitBtn1Click
        end
        object BitBtn4: TBitBtn
          Left = 69
          Top = 102
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 6
          OnClick = BitBtn4Click
        end
        object BitBtn9: TBitBtn
          Left = 37
          Top = 209
          Width = 52
          Height = 27
          TabOrder = 7
          OnClick = BitBtn9Click
        end
        object BitBtn10: TBitBtn
          Left = 37
          Top = 234
          Width = 52
          Height = 27
          TabOrder = 8
          OnClick = BitBtn10Click
        end
        object BitBtn11: TBitBtn
          Left = 37
          Top = 259
          Width = 52
          Height = 28
          TabOrder = 9
          OnClick = BitBtn11Click
        end
        object ComboBox3: TComboBox
          Left = 37
          Top = 211
          Width = 58
          Height = 21
          TabOrder = 10
          Text = 'ComboBox3'
        end
        object ComboBox4: TComboBox
          Left = 37
          Top = 236
          Width = 58
          Height = 21
          TabOrder = 11
          Text = 'ComboBox4'
        end
        object ComboBox5: TComboBox
          Left = 37
          Top = 262
          Width = 58
          Height = 21
          TabOrder = 12
          Text = 'ComboBox5'
        end
        object BitBtn15: TBitBtn
          Left = 126
          Top = 234
          Width = 52
          Height = 27
          TabOrder = 13
          OnClick = BitBtn15Click
        end
        object BitBtn16: TBitBtn
          Left = 126
          Top = 259
          Width = 52
          Height = 28
          TabOrder = 14
          OnClick = BitBtn16Click
        end
        object BitBtn17: TBitBtn
          Left = 125
          Top = 209
          Width = 53
          Height = 27
          TabOrder = 15
          OnClick = BitBtn17Click
        end
        object ComboBox9: TComboBox
          Left = 126
          Top = 211
          Width = 58
          Height = 21
          TabOrder = 16
          Text = 'ComboBox3'
        end
        object ComboBox10: TComboBox
          Left = 126
          Top = 236
          Width = 58
          Height = 21
          TabOrder = 17
          Text = 'ComboBox4'
        end
        object ComboBox11: TComboBox
          Left = 125
          Top = 262
          Width = 58
          Height = 21
          TabOrder = 18
          Text = 'ComboBox5'
        end
        object Button7: TButton
          Left = 96
          Top = 40
          Width = 57
          Height = 33
          Caption = 'Calibrate'
          TabOrder = 19
          OnClick = Button7Click
        end
      end
      object GroupBox2: TGroupBox
        Left = 200
        Top = 13
        Width = 185
        Height = 292
        Caption = 'Player 2'
        TabOrder = 1
        object Label9: TLabel
          Left = 7
          Top = 218
          Width = 25
          Height = 13
          Caption = 'But 0'
        end
        object Label10: TLabel
          Left = 7
          Top = 242
          Width = 25
          Height = 13
          Caption = 'But 1'
        end
        object Label11: TLabel
          Left = 7
          Top = 265
          Width = 25
          Height = 13
          Caption = 'But 2'
        end
        object Label18: TLabel
          Left = 95
          Top = 218
          Width = 25
          Height = 13
          Caption = 'But 3'
        end
        object Label19: TLabel
          Left = 95
          Top = 242
          Width = 25
          Height = 13
          Caption = 'But 4'
        end
        object Label20: TLabel
          Left = 95
          Top = 265
          Width = 25
          Height = 13
          Caption = 'But 5'
        end
        object RadioButton3: TRadioButton
          Left = 16
          Top = 25
          Width = 81
          Height = 17
          Caption = 'Keyboard'
          TabOrder = 0
          OnClick = RadioButton3Click
        end
        object RadioButton4: TRadioButton
          Left = 16
          Top = 48
          Width = 89
          Height = 17
          Caption = 'Joystick'
          Enabled = False
          TabOrder = 1
          OnClick = RadioButton4Click
        end
        object ComboBox2: TComboBox
          Left = 14
          Top = 75
          Width = 159
          Height = 21
          Enabled = False
          TabOrder = 2
          Text = 'ComboBox2'
        end
        object BitBtn5: TBitBtn
          Left = 67
          Top = 102
          Width = 41
          Height = 33
          TabOrder = 3
          OnClick = BitBtn5Click
        end
        object BitBtn6: TBitBtn
          Left = 20
          Top = 138
          Width = 41
          Height = 33
          TabOrder = 4
          OnClick = BitBtn6Click
        end
        object BitBtn7: TBitBtn
          Left = 111
          Top = 138
          Width = 40
          Height = 33
          TabOrder = 5
          OnClick = BitBtn7Click
        end
        object BitBtn8: TBitBtn
          Left = 67
          Top = 172
          Width = 41
          Height = 33
          TabOrder = 6
          OnClick = BitBtn8Click
        end
        object BitBtn12: TBitBtn
          Left = 38
          Top = 209
          Width = 52
          Height = 27
          TabOrder = 7
          OnClick = BitBtn12Click
        end
        object BitBtn13: TBitBtn
          Left = 38
          Top = 234
          Width = 52
          Height = 27
          TabOrder = 8
          OnClick = BitBtn13Click
        end
        object BitBtn14: TBitBtn
          Left = 38
          Top = 259
          Width = 52
          Height = 28
          TabOrder = 9
          OnClick = BitBtn14Click
        end
        object ComboBox6: TComboBox
          Left = 38
          Top = 211
          Width = 58
          Height = 21
          TabOrder = 10
          Text = 'ComboBox6'
        end
        object ComboBox7: TComboBox
          Left = 38
          Top = 236
          Width = 58
          Height = 21
          TabOrder = 11
          Text = 'ComboBox7'
        end
        object ComboBox8: TComboBox
          Left = 38
          Top = 263
          Width = 58
          Height = 21
          TabOrder = 12
          Text = 'ComboBox8'
        end
        object BitBtn18: TBitBtn
          Left = 123
          Top = 209
          Width = 52
          Height = 27
          TabOrder = 13
          OnClick = BitBtn18Click
        end
        object BitBtn19: TBitBtn
          Left = 123
          Top = 234
          Width = 52
          Height = 27
          TabOrder = 14
          OnClick = BitBtn19Click
        end
        object BitBtn20: TBitBtn
          Left = 123
          Top = 259
          Width = 52
          Height = 27
          TabOrder = 15
          OnClick = BitBtn20Click
        end
        object ComboBox12: TComboBox
          Left = 123
          Top = 211
          Width = 58
          Height = 21
          TabOrder = 16
          Text = 'ComboBox6'
        end
        object ComboBox13: TComboBox
          Left = 123
          Top = 236
          Width = 58
          Height = 21
          TabOrder = 17
          Text = 'ComboBox6'
        end
        object ComboBox14: TComboBox
          Left = 123
          Top = 262
          Width = 58
          Height = 21
          TabOrder = 18
          Text = 'ComboBox6'
        end
        object Button8: TButton
          Left = 103
          Top = 40
          Width = 57
          Height = 33
          Caption = 'Calibrate'
          TabOrder = 19
          OnClick = Button8Click
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Main Keys'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label21: TLabel
        Left = 58
        Top = 40
        Width = 38
        Height = 13
        Caption = ' COIN 1'
      end
      object Label22: TLabel
        Left = 150
        Top = 39
        Width = 35
        Height = 13
        Caption = 'COIN 2'
      end
      object Label23: TLabel
        Left = 40
        Top = 96
        Width = 77
        Height = 13
        Caption = 'Player 1 START'
      end
      object Label24: TLabel
        Left = 128
        Top = 96
        Width = 77
        Height = 13
        Caption = 'Player 2 START'
      end
      object Button3: TButton
        Left = 40
        Top = 56
        Width = 73
        Height = 25
        Caption = '5'
        TabOrder = 0
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 128
        Top = 55
        Width = 73
        Height = 25
        Caption = '6'
        TabOrder = 1
        OnClick = Button4Click
      end
      object Button5: TButton
        Left = 40
        Top = 112
        Width = 73
        Height = 25
        Caption = '1'
        TabOrder = 2
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 128
        Top = 112
        Width = 73
        Height = 25
        Caption = '2'
        TabOrder = 3
        OnClick = Button6Click
      end
    end
  end
end
