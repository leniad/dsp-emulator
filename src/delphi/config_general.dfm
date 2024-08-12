object MConfig: TMConfig
  Left = 304
  Top = 188
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Config DSP'
  ClientHeight = 504
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object Button1: TButton
    Left = 90
    Top = 459
    Width = 113
    Height = 41
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object Button2: TButton
    Left = 304
    Top = 459
    Width = 113
    Height = 41
    Caption = 'CANCELAR'
    TabOrder = 1
    OnClick = Button2Click
    OnKeyUp = FormKeyUp
  end
  object other: TPageControl
    Left = 8
    Top = 16
    Width = 488
    Height = 439
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Misc'
      object GroupBox3: TGroupBox
        Left = 23
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
          Top = 33
          Width = 105
          Height = 17
          Caption = 'English'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = RadioButton6Click
        end
        object RadioButton5: TRadioButton
          Left = 35
          Top = 14
          Width = 105
          Height = 17
          Caption = 'Castellano'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = RadioButton5Click
        end
        object RadioButton7: TRadioButton
          Left = 35
          Top = 51
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
          OnClick = RadioButton7Click
        end
        object RadioButton8: TRadioButton
          Left = 35
          Top = 69
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
          OnClick = RadioButton8Click
        end
        object RadioButton9: TRadioButton
          Left = 35
          Top = 87
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
          OnClick = RadioButton9Click
        end
        object RadioButton10: TRadioButton
          Left = 35
          Top = 105
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
          OnClick = RadioButton10Click
        end
        object RadioButton11: TRadioButton
          Left = 35
          Top = 123
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
          OnClick = RadioButton11Click
        end
      end
      object GroupBox4: TGroupBox
        Left = 235
        Top = 13
        Width = 187
        Height = 58
        Caption = 'Sound'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
        object RadioButton14: TRadioButton
          Left = 16
          Top = 15
          Width = 121
          Height = 17
          Caption = 'Enabled'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
        end
        object RadioButton15: TRadioButton
          Left = 16
          Top = 35
          Width = 121
          Height = 17
          Caption = 'Disabled'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
        end
      end
      object GroupBox5: TGroupBox
        Left = 23
        Top = 178
        Width = 399
        Height = 82
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
          Left = 191
          Top = 23
          Width = 97
          Height = 15
          Caption = 'Scanlines'
          TabOrder = 3
        end
        object RadioButton19: TRadioButton
          Left = 191
          Top = 46
          Width = 97
          Height = 15
          Caption = 'Scanlines 2X'
          TabOrder = 4
        end
        object RadioButton20: TRadioButton
          Left = 35
          Top = 56
          Width = 81
          Height = 17
          Caption = '3X'
          TabOrder = 2
        end
      end
      object GroupBox6: TGroupBox
        Left = 23
        Top = 280
        Width = 399
        Height = 111
        Caption = 'Misc'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
        object CheckBox2: TCheckBox
          Left = 19
          Top = 19
          Width = 286
          Height = 20
          TabStop = False
          Caption = 'Arrancar driver en inicio'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object CheckBox1: TCheckBox
          Left = 19
          Top = 37
          Width = 300
          Height = 24
          TabStop = False
          Caption = 'Mostar errores CRC de la ROM'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
        object CheckBox3: TCheckBox
          Left = 19
          Top = 59
          Width = 300
          Height = 20
          TabStop = False
          Caption = 'Centrar pantalla principal'
          TabOrder = 2
          OnKeyUp = FormKeyUp
        end
        object CheckBox17: TCheckBox
          Left = 19
          Top = 80
          Width = 360
          Height = 20
          TabStop = False
          Caption = 'CONSOLA: Cargar juego al principio'
          TabOrder = 3
          OnKeyUp = FormKeyUp
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Folders'
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
      object SpeedButton4: TSpeedButton
        Left = 363
        Top = 28
        Width = 23
        Height = 22
        Caption = '...'
        OnClick = SpeedButton4Click
      end
      object d1: TEdit
        Left = 3
        Top = 124
        Width = 354
        Height = 21
        TabOrder = 2
      end
      object d4: TEdit
        Left = 3
        Top = 28
        Width = 354
        Height = 21
        TabOrder = 0
      end
      object d5: TEdit
        Left = 3
        Top = 76
        Width = 354
        Height = 21
        TabOrder = 1
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
        TabOrder = 5
      end
      object D6: TEdit
        Left = 3
        Top = 213
        Width = 354
        Height = 21
        TabOrder = 4
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Input'
      ImageIndex = 2
      object GroupBox1: TGroupBox
        Left = 5
        Top = 13
        Width = 225
        Height = 395
        Caption = 'Player 1'
        TabOrder = 0
        object Label6: TLabel
          Left = 3
          Top = 251
          Width = 25
          Height = 13
          Caption = 'But 0'
        end
        object Label7: TLabel
          Left = 3
          Top = 278
          Width = 25
          Height = 13
          Caption = 'But 1'
        end
        object Label8: TLabel
          Left = 3
          Top = 305
          Width = 25
          Height = 13
          Caption = 'But 2'
        end
        object Label15: TLabel
          Left = 111
          Top = 251
          Width = 25
          Height = 13
          Caption = 'But 3'
        end
        object Label16: TLabel
          Left = 111
          Top = 278
          Width = 25
          Height = 13
          Caption = 'But 4'
        end
        object Label17: TLabel
          Left = 111
          Top = 305
          Width = 25
          Height = 13
          Caption = 'But 5'
        end
        object Label13: TLabel
          Left = 35
          Top = 337
          Width = 75
          Height = 13
          Caption = ' COIN/SELECT'
        end
        object Label14: TLabel
          Left = 149
          Top = 337
          Width = 54
          Height = 13
          Caption = 'P1/START'
        end
        object BitBtn10: TBitBtn
          Left = 33
          Top = 270
          Width = 74
          Height = 30
          TabOrder = 7
          OnClick = BitBtn10Click
        end
        object RadioButton1: TRadioButton
          Left = 11
          Top = 29
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
          Enabled = False
          TabOrder = 1
          OnClick = RadioButton2Click
        end
        object BitBtn2: TBitBtn
          Left = 138
          Top = 170
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
          Top = 204
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
          Top = 170
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
          Top = 134
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
        object GroupBox7: TGroupBox
          Left = 3
          Top = 75
          Width = 177
          Height = 52
          Color = clBtnFace
          ParentBackground = False
          ParentColor = False
          TabOrder = 12
          object Button7: TButton
            Left = 43
            Top = 27
            Width = 64
            Height = 24
            Caption = 'Get Center'
            TabOrder = 0
            OnClick = Button7Click
          end
          object ComboBox1: TComboBox
            Left = 8
            Top = 6
            Width = 159
            Height = 21
            Enabled = False
            TabOrder = 1
            TabStop = False
            Text = 'ComboBox1'
            OnChange = ComboBox1Change
          end
        end
        object Button9: TButton
          Left = 33
          Top = 356
          Width = 75
          Height = 30
          TabOrder = 13
          OnClick = Button9Click
        end
        object Button10: TButton
          Left = 138
          Top = 356
          Width = 75
          Height = 30
          TabOrder = 14
          OnClick = Button10Click
        end
        object BitBtn16: TBitBtn
          Left = 139
          Top = 300
          Width = 74
          Height = 30
          TabOrder = 10
          OnClick = BitBtn16Click
        end
        object BitBtn15: TBitBtn
          Left = 139
          Top = 270
          Width = 74
          Height = 30
          TabOrder = 9
          OnClick = BitBtn15Click
        end
        object BitBtn17: TBitBtn
          Left = 139
          Top = 240
          Width = 74
          Height = 30
          TabOrder = 11
          OnClick = BitBtn17Click
        end
        object BitBtn11: TBitBtn
          Left = 33
          Top = 300
          Width = 74
          Height = 30
          TabOrder = 8
          OnClick = BitBtn11Click
        end
        object BitBtn9: TBitBtn
          Left = 33
          Top = 240
          Width = 74
          Height = 30
          TabOrder = 6
          OnClick = BitBtn9Click
        end
      end
      object GroupBox2: TGroupBox
        Left = 236
        Top = 13
        Width = 238
        Height = 395
        Caption = 'Player 2'
        TabOrder = 1
        object Label9: TLabel
          Left = 7
          Top = 251
          Width = 25
          Height = 13
          Caption = 'But 0'
        end
        object Label10: TLabel
          Left = 7
          Top = 278
          Width = 25
          Height = 13
          Caption = 'But 1'
        end
        object Label11: TLabel
          Left = 7
          Top = 305
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
          Top = 278
          Width = 25
          Height = 13
          Caption = 'But 4'
        end
        object Label20: TLabel
          Left = 120
          Top = 305
          Width = 25
          Height = 13
          Caption = 'But 5'
        end
        object Label25: TLabel
          Left = 38
          Top = 337
          Width = 72
          Height = 13
          Caption = 'COIN/SELECT'
        end
        object Label26: TLabel
          Left = 159
          Top = 337
          Width = 54
          Height = 13
          Caption = 'P2/START'
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
        object BitBtn5: TBitBtn
          Left = 108
          Top = 134
          Width = 41
          Height = 33
          TabOrder = 2
          OnClick = BitBtn5Click
        end
        object BitBtn6: TBitBtn
          Left = 61
          Top = 170
          Width = 41
          Height = 33
          TabOrder = 3
          OnClick = BitBtn6Click
        end
        object BitBtn7: TBitBtn
          Left = 155
          Top = 170
          Width = 40
          Height = 33
          TabOrder = 4
          OnClick = BitBtn7Click
        end
        object BitBtn8: TBitBtn
          Left = 108
          Top = 204
          Width = 41
          Height = 33
          TabOrder = 5
          OnClick = BitBtn8Click
        end
        object BitBtn12: TBitBtn
          Left = 37
          Top = 240
          Width = 74
          Height = 30
          TabOrder = 6
          OnClick = BitBtn12Click
        end
        object BitBtn13: TBitBtn
          Left = 37
          Top = 270
          Width = 74
          Height = 30
          TabOrder = 7
          OnClick = BitBtn13Click
        end
        object BitBtn14: TBitBtn
          Left = 37
          Top = 300
          Width = 74
          Height = 30
          TabOrder = 8
          OnClick = BitBtn14Click
        end
        object BitBtn18: TBitBtn
          Left = 148
          Top = 240
          Width = 74
          Height = 30
          TabOrder = 9
          OnClick = BitBtn18Click
        end
        object BitBtn19: TBitBtn
          Left = 148
          Top = 270
          Width = 74
          Height = 30
          TabOrder = 10
          OnClick = BitBtn19Click
        end
        object BitBtn20: TBitBtn
          Left = 148
          Top = 300
          Width = 74
          Height = 30
          TabOrder = 11
          OnClick = BitBtn20Click
        end
        object GroupBox10: TGroupBox
          Left = 19
          Top = 75
          Width = 177
          Height = 52
          Color = clBtnFace
          ParentBackground = False
          ParentColor = False
          TabOrder = 12
          object ComboBox2: TComboBox
            Left = 9
            Top = 6
            Width = 159
            Height = 21
            Enabled = False
            TabOrder = 0
            Text = 'ComboBox2'
            OnChange = ComboBox2Change
          end
          object Button8: TButton
            Left = 48
            Top = 27
            Width = 64
            Height = 24
            Caption = 'Get Center'
            TabOrder = 1
            OnClick = Button8Click
          end
        end
        object Button11: TButton
          Left = 37
          Top = 356
          Width = 75
          Height = 30
          TabOrder = 13
          OnClick = Button11Click
        end
        object Button12: TButton
          Left = 148
          Top = 356
          Width = 75
          Height = 30
          TabOrder = 14
          OnClick = Button12Click
        end
      end
    end
    object ROM: TTabSheet
      Caption = 'ROMs export'
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
        TabOrder = 1
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
        TabOrder = 2
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
        TabOrder = 0
        OnClick = CheckBox16Click
      end
    end
  end
end
