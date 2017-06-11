object MConfig: TMConfig
  Left = 304
  Top = 188
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Configurar DSP'
  ClientHeight = 464
  ClientWidth = 498
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
  object SpeedButton3: TSpeedButton
    Left = 367
    Top = 298
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SpeedButton2Click
  end
  object SpeedButton7: TSpeedButton
    Left = 367
    Top = 284
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SpeedButton6Click
  end
  object Button1: TButton
    Left = 90
    Top = 407
    Width = 113
    Height = 41
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object Button2: TButton
    Left = 304
    Top = 407
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
    Width = 488
    Height = 393
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Misc'
      ExplicitLeft = 0
      ExplicitTop = 28
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
      object Label1: TLabel
        Left = 3
        Top = 110
        Width = 90
        Height = 13
        Caption = 'Preview Images'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton1: TSpeedButton
        Left = 363
        Top = 124
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton1Click
      end
      object Label4: TLabel
        Left = 1
        Top = 14
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
      object Label5: TLabel
        Left = 3
        Top = 62
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
        Left = 363
        Top = 76
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton5Click
      end
      object Label2: TLabel
        Left = 3
        Top = 156
        Width = 48
        Height = 13
        Caption = 'Samples'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton2: TSpeedButton
        Left = 362
        Top = 170
        Width = 24
        Height = 22
        Caption = '...'
        OnClick = SpeedButton2Click
      end
      object Label3: TLabel
        Left = 3
        Top = 252
        Width = 49
        Height = 13
        Caption = 'NV RAM'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton6: TSpeedButton
        Left = 363
        Top = 266
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton6Click
      end
      object Label12: TLabel
        Left = 3
        Top = 199
        Width = 91
        Height = 13
        Caption = 'Quick Snapshot'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object SpeedButton8: TSpeedButton
        Left = 363
        Top = 213
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton8Click
      end
      object d1: TEdit
        Left = 3
        Top = 124
        Width = 354
        Height = 21
        TabOrder = 0
      end
      object d4: TEdit
        Left = 3
        Top = 28
        Width = 354
        Height = 21
        TabOrder = 1
      end
      object d5: TEdit
        Left = 3
        Top = 76
        Width = 354
        Height = 21
        TabOrder = 2
      end
      object d2: TEdit
        Left = 3
        Top = 170
        Width = 354
        Height = 21
        TabOrder = 3
      end
      object d3: TEdit
        Left = 3
        Top = 266
        Width = 354
        Height = 21
        TabOrder = 4
      end
      object D6: TEdit
        Left = 3
        Top = 213
        Width = 354
        Height = 21
        TabOrder = 5
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Input'
      ImageIndex = 2
      object GroupBox1: TGroupBox
        Left = 5
        Top = 13
        Width = 225
        Height = 340
        Caption = 'Player 1'
        TabOrder = 0
        object Label6: TLabel
          Left = 3
          Top = 252
          Width = 25
          Height = 13
          Caption = 'But 0'
        end
        object Label7: TLabel
          Left = 3
          Top = 276
          Width = 25
          Height = 13
          Caption = 'But 1'
        end
        object Label8: TLabel
          Left = 3
          Top = 299
          Width = 25
          Height = 13
          Caption = 'But 2'
        end
        object Label15: TLabel
          Left = 113
          Top = 252
          Width = 25
          Height = 13
          Caption = 'But 3'
        end
        object Label16: TLabel
          Left = 113
          Top = 276
          Width = 25
          Height = 13
          Caption = 'But 4'
        end
        object Label17: TLabel
          Left = 113
          Top = 299
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
        object BitBtn2: TBitBtn
          Left = 138
          Top = 172
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = BitBtn2Click
        end
        object BitBtn3: TBitBtn
          Left = 91
          Top = 206
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = BitBtn3Click
        end
        object BitBtn1: TBitBtn
          Left = 46
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
          OnClick = BitBtn1Click
        end
        object BitBtn4: TBitBtn
          Left = 91
          Top = 136
          Width = 41
          Height = 33
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -8
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
          OnClick = BitBtn4Click
        end
        object BitBtn9: TBitBtn
          Left = 33
          Top = 243
          Width = 52
          Height = 27
          TabOrder = 6
          OnClick = BitBtn9Click
        end
        object BitBtn10: TBitBtn
          Left = 33
          Top = 268
          Width = 52
          Height = 27
          TabOrder = 7
          OnClick = BitBtn10Click
        end
        object BitBtn11: TBitBtn
          Left = 33
          Top = 293
          Width = 52
          Height = 28
          TabOrder = 8
          OnClick = BitBtn11Click
        end
        object ComboBox3: TComboBox
          Left = 33
          Top = 245
          Width = 58
          Height = 21
          TabOrder = 9
          Text = 'ComboBox3'
        end
        object ComboBox4: TComboBox
          Left = 33
          Top = 270
          Width = 58
          Height = 21
          TabOrder = 10
          Text = 'ComboBox4'
        end
        object ComboBox5: TComboBox
          Left = 33
          Top = 296
          Width = 58
          Height = 21
          TabOrder = 11
          Text = 'ComboBox5'
        end
        object BitBtn15: TBitBtn
          Left = 139
          Top = 268
          Width = 52
          Height = 27
          TabOrder = 12
          OnClick = BitBtn15Click
        end
        object BitBtn16: TBitBtn
          Left = 139
          Top = 293
          Width = 52
          Height = 28
          TabOrder = 13
          OnClick = BitBtn16Click
        end
        object BitBtn17: TBitBtn
          Left = 139
          Top = 243
          Width = 53
          Height = 27
          TabOrder = 14
          OnClick = BitBtn17Click
        end
        object ComboBox9: TComboBox
          Left = 140
          Top = 245
          Width = 58
          Height = 21
          TabOrder = 15
          Text = 'ComboBox3'
        end
        object ComboBox10: TComboBox
          Left = 140
          Top = 270
          Width = 58
          Height = 21
          TabOrder = 16
          Text = 'ComboBox4'
        end
        object ComboBox11: TComboBox
          Left = 139
          Top = 296
          Width = 58
          Height = 21
          TabOrder = 17
          Text = 'ComboBox5'
        end
        object GroupBox7: TGroupBox
          Left = 7
          Top = 75
          Width = 177
          Height = 52
          Color = clWhite
          ParentBackground = False
          ParentColor = False
          TabOrder = 18
          object RadioButton22: TRadioButton
            Left = 66
            Top = 28
            Width = 52
            Height = 17
            Caption = 'Analog'
            TabOrder = 0
            OnClick = RadioButton22Click
          end
          object RadioButton21: TRadioButton
            Left = 4
            Top = 28
            Width = 56
            Height = 17
            Caption = 'Digital'
            TabOrder = 1
            OnClick = RadioButton21Click
          end
          object Button7: TButton
            Left = 121
            Top = 25
            Width = 52
            Height = 24
            Caption = 'Calibrate'
            TabOrder = 2
            OnClick = Button7Click
          end
          object ComboBox1: TComboBox
            Left = 4
            Top = 3
            Width = 159
            Height = 21
            TabOrder = 3
            TabStop = False
            Text = 'ComboBox1'
            OnChange = ComboBox1Change
          end
        end
      end
      object GroupBox2: TGroupBox
        Left = 236
        Top = 13
        Width = 238
        Height = 340
        Caption = 'Player 2'
        TabOrder = 1
        object Label9: TLabel
          Left = 7
          Top = 252
          Width = 25
          Height = 13
          Caption = 'But 0'
        end
        object Label10: TLabel
          Left = 7
          Top = 276
          Width = 25
          Height = 13
          Caption = 'But 1'
        end
        object Label11: TLabel
          Left = 7
          Top = 299
          Width = 25
          Height = 13
          Caption = 'But 2'
        end
        object Label18: TLabel
          Left = 120
          Top = 251
          Width = 25
          Height = 13
          Caption = 'But 3'
        end
        object Label19: TLabel
          Left = 120
          Top = 276
          Width = 25
          Height = 13
          Caption = 'But 4'
        end
        object Label20: TLabel
          Left = 120
          Top = 299
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
          Top = 52
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
          Left = 108
          Top = 136
          Width = 41
          Height = 33
          TabOrder = 3
          OnClick = BitBtn5Click
        end
        object BitBtn6: TBitBtn
          Left = 61
          Top = 172
          Width = 41
          Height = 33
          TabOrder = 4
          OnClick = BitBtn6Click
        end
        object BitBtn7: TBitBtn
          Left = 152
          Top = 172
          Width = 40
          Height = 33
          TabOrder = 5
          OnClick = BitBtn7Click
        end
        object BitBtn8: TBitBtn
          Left = 108
          Top = 206
          Width = 41
          Height = 33
          TabOrder = 6
          OnClick = BitBtn8Click
        end
        object BitBtn12: TBitBtn
          Left = 37
          Top = 243
          Width = 52
          Height = 27
          TabOrder = 7
          OnClick = BitBtn12Click
        end
        object BitBtn13: TBitBtn
          Left = 37
          Top = 268
          Width = 52
          Height = 27
          TabOrder = 8
          OnClick = BitBtn13Click
        end
        object BitBtn14: TBitBtn
          Left = 37
          Top = 293
          Width = 52
          Height = 28
          TabOrder = 9
          OnClick = BitBtn14Click
        end
        object ComboBox6: TComboBox
          Left = 37
          Top = 245
          Width = 58
          Height = 21
          TabOrder = 10
          Text = 'ComboBox6'
        end
        object ComboBox7: TComboBox
          Left = 37
          Top = 270
          Width = 58
          Height = 21
          TabOrder = 11
          Text = 'ComboBox7'
        end
        object ComboBox8: TComboBox
          Left = 37
          Top = 297
          Width = 58
          Height = 21
          TabOrder = 12
          Text = 'ComboBox8'
        end
        object BitBtn18: TBitBtn
          Left = 148
          Top = 243
          Width = 52
          Height = 27
          TabOrder = 13
          OnClick = BitBtn18Click
        end
        object BitBtn19: TBitBtn
          Left = 148
          Top = 268
          Width = 52
          Height = 27
          TabOrder = 14
          OnClick = BitBtn19Click
        end
        object BitBtn20: TBitBtn
          Left = 148
          Top = 293
          Width = 52
          Height = 27
          TabOrder = 15
          OnClick = BitBtn20Click
        end
        object ComboBox12: TComboBox
          Left = 148
          Top = 245
          Width = 58
          Height = 21
          TabOrder = 16
          Text = 'ComboBox6'
        end
        object ComboBox13: TComboBox
          Left = 148
          Top = 270
          Width = 58
          Height = 21
          TabOrder = 17
          Text = 'ComboBox6'
        end
        object ComboBox14: TComboBox
          Left = 148
          Top = 296
          Width = 58
          Height = 21
          TabOrder = 18
          Text = 'ComboBox6'
        end
        object Button8: TButton
          Left = 127
          Top = 101
          Width = 52
          Height = 25
          Caption = 'Calibrate'
          TabOrder = 19
          OnClick = Button8Click
        end
        object RadioButton24: TRadioButton
          Left = 75
          Top = 105
          Width = 52
          Height = 17
          Caption = 'Analog'
          TabOrder = 20
        end
        object RadioButton23: TRadioButton
          Left = 11
          Top = 105
          Width = 54
          Height = 17
          Caption = 'Digital'
          TabOrder = 21
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Main Keys'
      ImageIndex = 3
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
    object ROM: TTabSheet
      Caption = 'ROM'
      ImageIndex = 4
      object BitBtn21: TBitBtn
        Left = 40
        Top = 32
        Width = 121
        Height = 49
        Caption = 'Export ROM data'
        TabOrder = 0
        OnClick = BitBtn21Click
      end
    end
    object Autofire: TTabSheet
      Caption = 'Autofire'
      ImageIndex = 5
      object GroupBox8: TGroupBox
        Left = 32
        Top = 79
        Width = 185
        Height = 209
        Caption = 'Player 1'
        TabOrder = 0
        object CheckBox4: TCheckBox
          Left = 28
          Top = 34
          Width = 109
          Height = 16
          Caption = 'Button 0'
          TabOrder = 0
        end
        object CheckBox5: TCheckBox
          Left = 28
          Top = 56
          Width = 68
          Height = 16
          Caption = 'Button 1'
          TabOrder = 1
        end
        object CheckBox6: TCheckBox
          Left = 28
          Top = 80
          Width = 65
          Height = 16
          Caption = 'Button 2'
          TabOrder = 2
        end
        object CheckBox7: TCheckBox
          Left = 28
          Top = 101
          Width = 69
          Height = 16
          Caption = 'Button 3'
          TabOrder = 3
        end
        object CheckBox8: TCheckBox
          Left = 28
          Top = 123
          Width = 67
          Height = 16
          Caption = 'Button 4'
          TabOrder = 4
        end
        object CheckBox9: TCheckBox
          Left = 28
          Top = 145
          Width = 64
          Height = 16
          Caption = 'Button 5'
          TabOrder = 5
        end
      end
      object GroupBox9: TGroupBox
        Left = 256
        Top = 79
        Width = 185
        Height = 209
        Caption = 'Player 2'
        TabOrder = 1
        object CheckBox10: TCheckBox
          Left = 28
          Top = 34
          Width = 109
          Height = 16
          Caption = 'Button 0'
          TabOrder = 0
        end
        object CheckBox11: TCheckBox
          Left = 28
          Top = 56
          Width = 68
          Height = 16
          Caption = 'Button 1'
          TabOrder = 1
        end
        object CheckBox12: TCheckBox
          Left = 28
          Top = 80
          Width = 65
          Height = 16
          Caption = 'Button 2'
          TabOrder = 2
        end
        object CheckBox13: TCheckBox
          Left = 28
          Top = 101
          Width = 69
          Height = 16
          Caption = 'Button 3'
          TabOrder = 3
        end
        object CheckBox14: TCheckBox
          Left = 28
          Top = 123
          Width = 67
          Height = 16
          Caption = 'Button 4'
          TabOrder = 4
        end
        object CheckBox15: TCheckBox
          Left = 28
          Top = 145
          Width = 64
          Height = 16
          Caption = 'Button 5'
          TabOrder = 5
        end
      end
      object CheckBox16: TCheckBox
        Left = 36
        Top = 42
        Width = 109
        Height = 16
        Caption = 'Enabled/Disabled'
        TabOrder = 2
        OnClick = CheckBox16Click
      end
    end
  end
end
