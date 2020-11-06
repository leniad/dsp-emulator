object FLoadRom: TFLoadRom
  Left = 293
  Top = 115
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Load Rom'
  ClientHeight = 511
  ClientWidth = 590
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 120
    Top = 44
    Width = 3
    Height = 13
  end
  object GroupBox1: TGroupBox
    Left = 283
    Top = 143
    Width = 289
    Height = 311
    Caption = 'Preview'
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    object ImgPreview: TImage
      Left = 12
      Top = 16
      Width = 266
      Height = 281
      Stretch = True
    end
  end
  object gpxrominfo: TGroupBox
    Left = 283
    Top = 8
    Width = 289
    Height = 129
    Caption = 'Driver Info'
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 2
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
    Left = 28
    Top = 8
    Width = 249
    Height = 481
    ColCount = 2
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
      165
      64)
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
    Left = 305
    Top = 467
    Width = 86
    Height = 29
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 3
    TabStop = False
    OnClick = BitBtn3Click
  end
  object BitBtn1: TBitBtn
    Left = 456
    Top = 467
    Width = 86
    Height = 29
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 4
    TabStop = False
    OnClick = BitBtn1Click
  end
end
