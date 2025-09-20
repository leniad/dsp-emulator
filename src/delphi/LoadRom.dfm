object FLoadRom: TFLoadRom
  Left = 293
  Top = 115
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Load Rom'
  ClientHeight = 507
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poDesigned
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object gpxrominfo: TGroupBox
    Left = 492
    Top = 8
    Width = 400
    Height = 81
    Caption = 'Driver Info'
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 29
      Height = 13
      Caption = 'Year:'
    end
    object Label2: TLabel
      Left = 8
      Top = 44
      Width = 97
      Height = 13
      Caption = 'Hi Score Support:'
    end
    object Label3: TLabel
      Left = 8
      Top = 30
      Width = 38
      Height = 13
      Caption = 'Sound:'
    end
    object Label4: TLabel
      Left = 120
      Top = 16
      Width = 3
      Height = 13
    end
    object Label5: TLabel
      Left = 120
      Top = 30
      Width = 3
      Height = 13
    end
    object Label6: TLabel
      Left = 120
      Top = 44
      Width = 3
      Height = 13
    end
    object Label9: TLabel
      Left = 120
      Top = 58
      Width = 3
      Height = 13
    end
    object Label10: TLabel
      Left = 8
      Top = 58
      Width = 56
      Height = 13
      Caption = 'Company:'
    end
  end
  object RomList: TStringGrid
    Left = 195
    Top = 8
    Width = 291
    Height = 473
    ColCount = 3
    Ctl3D = False
    DefaultColWidth = 120
    DefaultRowHeight = 15
    FixedCols = 0
    RowCount = 41
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ParentCtl3D = False
    TabOrder = 0
    Visible = False
    OnClick = RomListClick
    OnDblClick = RomListDblClick
    ColWidths = (
      193
      71
      120)
    RowHeights = (
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15
      15)
  end
  object BitBtn3: TBitBtn
    Left = 553
    Top = 432
    Width = 123
    Height = 49
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    Kind = bkOK
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 2
    TabStop = False
    OnClick = BitBtn3Click
  end
  object BitBtn1: TBitBtn
    Left = 728
    Top = 432
    Width = 121
    Height = 49
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    Kind = bkCancel
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 3
    TabStop = False
    OnClick = BitBtn1Click
  end
  object Panel1: TPanel
    Left = 492
    Top = 112
    Width = 402
    Height = 301
    Color = clBlack
    ParentBackground = False
    TabOrder = 4
    object ImgPreview: TImage
      Left = 1
      Top = 1
      Width = 400
      Height = 299
      Align = alClient
      Center = True
      Proportional = True
      Stretch = True
      ExplicitLeft = -25
      ExplicitTop = -5
      ExplicitHeight = 300
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 177
    Height = 405
    Caption = 'Sort'
    TabOrder = 5
    object RadioButton1: TRadioButton
      Left = 12
      Top = 25
      Width = 93
      Height = 25
      Caption = 'All'
      TabOrder = 0
      OnClick = RadioButton1Click
    end
    object RadioButton2: TRadioButton
      Left = 12
      Top = 47
      Width = 105
      Height = 25
      Caption = 'Computers'
      TabOrder = 1
      OnClick = RadioButton2Click
    end
    object RadioButton3: TRadioButton
      Left = 12
      Top = 76
      Width = 97
      Height = 17
      Caption = 'Consoles'
      TabOrder = 2
      OnClick = RadioButton3Click
    end
    object RadioButton4: TRadioButton
      Left = 12
      Top = 99
      Width = 124
      Height = 17
      Caption = 'Game && Watch'
      TabOrder = 3
      OnClick = RadioButton4Click
    end
    object RadioButton5: TRadioButton
      Left = 12
      Top = 120
      Width = 89
      Height = 17
      Caption = 'Arcade'
      TabOrder = 4
      OnClick = RadioButton5Click
    end
    object GroupBox2: TGroupBox
      Left = 12
      Top = 143
      Width = 149
      Height = 146
      Caption = 'Arcade Sub-Type'
      TabOrder = 5
      object CheckBox1: TCheckBox
        Left = 16
        Top = 16
        Width = 121
        Height = 17
        Caption = 'Sport'
        TabOrder = 0
        OnClick = CheckBox1Click
      end
      object CheckBox3: TCheckBox
        Left = 16
        Top = 48
        Width = 113
        Height = 36
        Caption = 'Shot'
        TabOrder = 2
        OnClick = CheckBox1Click
      end
      object CheckBox4: TCheckBox
        Left = 16
        Top = 79
        Width = 113
        Height = 17
        Caption = 'Maze'
        TabOrder = 3
        OnClick = CheckBox1Click
      end
      object CheckBox2: TCheckBox
        Left = 16
        Top = 32
        Width = 121
        Height = 25
        Caption = 'Run && Gun'
        TabOrder = 1
        OnClick = CheckBox1Click
      end
      object CheckBox5: TCheckBox
        Left = 16
        Top = 97
        Width = 89
        Height = 25
        Caption = 'Fight'
        TabOrder = 4
        OnClick = CheckBox1Click
      end
      object CheckBox6: TCheckBox
        Left = 16
        Top = 118
        Width = 89
        Height = 25
        Caption = 'Drive'
        TabOrder = 5
        OnClick = CheckBox1Click
      end
    end
  end
end
