object MConfig: TMConfig
  Left = 304
  Top = 188
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Config DSP'
  ClientHeight = 509
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object Button1: TButton
    Left = 64
    Top = 453
    Width = 113
    Height = 41
    Caption = 'OK'
    TabOrder = 0
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object Button2: TButton
    Left = 301
    Top = 453
    Width = 113
    Height = 41
    Caption = 'CANCELAR'
    TabOrder = 1
    OnClick = Button2Click
    OnKeyUp = FormKeyUp
  end
  object other: TPageControl
    Left = 8
    Top = 8
    Width = 495
    Height = 439
    ActivePage = TabSheet3
    TabOrder = 2
    TabStop = False
    object TabSheet1: TTabSheet
      Caption = 'Misc'
      object GroupBox3: TGroupBox
        Left = 23
        Top = 13
        Width = 169
        Height = 159
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        object RadioButton6: TRadioButton
          Left = 35
          Top = 49
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
          Top = 32
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
          Top = 66
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
          Top = 83
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
          Top = 100
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
          Top = 117
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
          Top = 134
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
        object RadioButton12: TRadioButton
          Left = 35
          Top = 15
          Width = 105
          Height = 17
          Caption = 'Auto'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 7
          OnClick = RadioButton12Click
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
          Top = 26
          Width = 97
          Height = 17
          Caption = 'Scanlines'
          TabOrder = 3
        end
        object RadioButton19: TRadioButton
          Left = 191
          Top = 46
          Width = 97
          Height = 17
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
          Top = 15
          Width = 286
          Height = 20
          TabStop = False
          Caption = 'Arrancar driver en inicio'
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object CheckBox1: TCheckBox
          Left = 19
          Top = 35
          Width = 300
          Height = 20
          TabStop = False
          Caption = 'Mostar errores CRC de la ROM'
          TabOrder = 1
          OnKeyUp = FormKeyUp
        end
        object CheckBox3: TCheckBox
          Left = 19
          Top = 55
          Width = 300
          Height = 20
          TabStop = False
          Caption = 'Centrar pantalla principal'
          TabOrder = 2
          OnKeyUp = FormKeyUp
        end
        object CheckBox17: TCheckBox
          Left = 19
          Top = 75
          Width = 360
          Height = 20
          TabStop = False
          Caption = 'CONSOLA: Cargar juego al principio'
          TabOrder = 3
          OnKeyUp = FormKeyUp
        end
      end
      object GroupBox15: TGroupBox
        Left = 235
        Top = 92
        Width = 111
        Height = 60
        Caption = 'Tape Autotype'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 4
        object RadioButton28: TRadioButton
          Left = 14
          Top = 15
          Width = 66
          Height = 17
          Caption = 'Enabled'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnKeyUp = FormKeyUp
        end
        object RadioButton29: TRadioButton
          Left = 14
          Top = 35
          Width = 72
          Height = 17
          Caption = 'Disabled'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
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
        Left = 423
        Top = 124
        Width = 54
        Height = 22
        Caption = 'Open'
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
        Left = 423
        Top = 76
        Width = 54
        Height = 22
        Caption = 'Open'
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
        Left = 423
        Top = 170
        Width = 55
        Height = 21
        Caption = 'Open'
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
        Left = 423
        Top = 265
        Width = 54
        Height = 22
        Caption = 'Open'
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
        Left = 423
        Top = 213
        Width = 54
        Height = 22
        Caption = 'Open'
        OnClick = SpeedButton8Click
      end
      object SpeedButton4: TSpeedButton
        Left = 423
        Top = 27
        Width = 54
        Height = 22
        Caption = 'Open'
        OnClick = SpeedButton4Click
      end
      object d1: TEdit
        Left = 3
        Top = 127
        Width = 398
        Height = 21
        TabStop = False
        TabOrder = 2
      end
      object d4: TEdit
        Left = 3
        Top = 31
        Width = 398
        Height = 21
        TabStop = False
        TabOrder = 0
      end
      object d5: TEdit
        Left = 3
        Top = 79
        Width = 398
        Height = 21
        TabStop = False
        TabOrder = 1
      end
      object d2: TEdit
        Left = 3
        Top = 173
        Width = 398
        Height = 21
        TabStop = False
        TabOrder = 3
      end
      object d3: TEdit
        Left = 3
        Top = 269
        Width = 398
        Height = 21
        TabStop = False
        TabOrder = 5
      end
      object D6: TEdit
        Left = 3
        Top = 216
        Width = 398
        Height = 21
        TabStop = False
        TabOrder = 4
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Input'
      ImageIndex = 2
      object Label6: TLabel
        Left = 24
        Top = 24
        Width = 38
        Height = 13
        Caption = 'Player 1'
        Color = clBtnFace
        ParentColor = False
      end
      object Label7: TLabel
        Left = 25
        Top = 59
        Width = 38
        Height = 13
        Caption = 'Player 2'
        Color = clBtnFace
        ParentColor = False
      end
      object Label8: TLabel
        Left = 25
        Top = 98
        Width = 38
        Height = 13
        Caption = 'Player 3'
        Color = clBtnFace
        ParentColor = False
      end
      object Label9: TLabel
        Left = 26
        Top = 138
        Width = 38
        Height = 13
        Caption = 'Player 4'
        Color = clBtnFace
        Enabled = False
        ParentColor = False
      end
      object ComboBox1: TComboBox
        Left = 87
        Top = 21
        Width = 226
        Height = 21
        TabOrder = 0
      end
      object ComboBox2: TComboBox
        Left = 89
        Top = 56
        Width = 225
        Height = 21
        TabOrder = 1
      end
      object ComboBox3: TComboBox
        Left = 88
        Top = 95
        Width = 226
        Height = 21
        TabOrder = 2
      end
      object Button3: TButton
        Left = 16
        Top = 224
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Keyboard 1'
        TabOrder = 3
        WordWrap = True
        OnClick = Button3Click
      end
      object Button4: TButton
        Left = 128
        Top = 224
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Keyboard 2'
        TabOrder = 4
        WordWrap = True
        OnClick = Button4Click
      end
      object Button5: TButton
        Left = 240
        Top = 224
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Keyboard 3'
        TabOrder = 5
        WordWrap = True
        OnClick = Button5Click
      end
      object Button6: TButton
        Left = 352
        Top = 224
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Keyboard 4'
        TabOrder = 6
        WordWrap = True
        OnClick = Button6Click
      end
      object Button7: TButton
        Left = 16
        Top = 288
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Joystick 1'
        TabOrder = 7
        WordWrap = True
        OnClick = Button7Click
      end
      object Button8: TButton
        Left = 128
        Top = 288
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Joystick 2'
        TabOrder = 8
        WordWrap = True
        OnClick = Button8Click
      end
      object Button9: TButton
        Left = 240
        Top = 288
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Joystick 3'
        TabOrder = 9
        WordWrap = True
        OnClick = Button9Click
      end
      object Button10: TButton
        Left = 352
        Top = 288
        Width = 97
        Height = 79
        Caption = 'Redefine'#13#10'Joystick 4'
        TabOrder = 10
        WordWrap = True
        OnClick = Button10Click
      end
      object ComboBox4: TComboBox
        Left = 89
        Top = 135
        Width = 226
        Height = 21
        Enabled = False
        TabOrder = 11
      end
    end
    object ROM: TTabSheet
      Caption = 'DATs export'
      ImageIndex = 4
      object BitBtn21: TBitBtn
        Left = 40
        Top = 32
        Width = 121
        Height = 49
        Caption = 'Export ROM data'
        TabOrder = 0
        TabStop = False
        OnClick = BitBtn21Click
      end
      object BitBtn22: TBitBtn
        Left = 224
        Top = 32
        Width = 121
        Height = 49
        Caption = 'Export SAMPLE data'
        TabOrder = 1
        TabStop = False
        OnClick = BitBtn22Click
      end
    end
    object Autofire: TTabSheet
      Caption = 'Autofire'
      ImageIndex = 5
      object GroupBox8: TGroupBox
        Left = 32
        Top = 79
        Width = 185
        Height = 210
        Caption = 'Player 1'
        TabOrder = 1
        object CheckBox4: TCheckBox
          Left = 28
          Top = 34
          Width = 109
          Height = 16
          TabStop = False
          Caption = 'Button 0'
          TabOrder = 0
        end
        object CheckBox5: TCheckBox
          Left = 28
          Top = 56
          Width = 68
          Height = 16
          TabStop = False
          Caption = 'Button 1'
          TabOrder = 1
        end
        object CheckBox6: TCheckBox
          Left = 28
          Top = 80
          Width = 65
          Height = 16
          TabStop = False
          Caption = 'Button 2'
          TabOrder = 2
        end
        object CheckBox7: TCheckBox
          Left = 28
          Top = 101
          Width = 69
          Height = 16
          TabStop = False
          Caption = 'Button 3'
          TabOrder = 3
        end
        object CheckBox8: TCheckBox
          Left = 28
          Top = 123
          Width = 67
          Height = 16
          TabStop = False
          Caption = 'Button 4'
          TabOrder = 4
        end
        object CheckBox9: TCheckBox
          Left = 28
          Top = 145
          Width = 64
          Height = 16
          TabStop = False
          Caption = 'Button 5'
          TabOrder = 5
        end
      end
      object GroupBox9: TGroupBox
        Left = 256
        Top = 79
        Width = 185
        Height = 210
        Caption = 'Player 2'
        TabOrder = 2
        object CheckBox10: TCheckBox
          Left = 28
          Top = 34
          Width = 109
          Height = 15
          TabStop = False
          Caption = 'Button 0'
          TabOrder = 0
        end
        object CheckBox11: TCheckBox
          Left = 28
          Top = 56
          Width = 68
          Height = 15
          TabStop = False
          Caption = 'Button 1'
          TabOrder = 1
        end
        object CheckBox12: TCheckBox
          Left = 28
          Top = 80
          Width = 65
          Height = 15
          TabStop = False
          Caption = 'Button 2'
          TabOrder = 2
        end
        object CheckBox13: TCheckBox
          Left = 28
          Top = 101
          Width = 69
          Height = 15
          TabStop = False
          Caption = 'Button 3'
          TabOrder = 3
        end
        object CheckBox14: TCheckBox
          Left = 28
          Top = 123
          Width = 67
          Height = 15
          TabStop = False
          Caption = 'Button 4'
          TabOrder = 4
        end
        object CheckBox15: TCheckBox
          Left = 28
          Top = 145
          Width = 64
          Height = 15
          TabStop = False
          Caption = 'Button 5'
          TabOrder = 5
        end
      end
      object CheckBox16: TCheckBox
        Left = 172
        Top = 42
        Width = 109
        Height = 17
        TabStop = False
        Caption = 'Enabled/Disabled'
        TabOrder = 0
        OnClick = CheckBox16Click
      end
    end
  end
end
