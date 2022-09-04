object FLoadRom: TFLoadRom
  Left = 293
  Top = 115
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Load Rom'
  ClientHeight = 471
  ClientWidth = 736
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
    Left = 347
    Top = 8
    Width = 381
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
    Left = 8
    Top = 10
    Width = 291
    Height = 453
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
      193
      71)
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
    Left = 384
    Top = 434
    Width = 86
    Height = 29
    Kind = bkOK
    NumGlyphs = 2
    TabOrder = 2
    TabStop = False
    OnClick = BitBtn3Click
  end
  object BitBtn1: TBitBtn
    Left = 544
    Top = 431
    Width = 86
    Height = 29
    Kind = bkCancel
    NumGlyphs = 2
    TabOrder = 3
    TabStop = False
    OnClick = BitBtn1Click
  end
  object Panel1: TPanel
    Left = 320
    Top = 112
    Width = 402
    Height = 302
    Color = clBlack
    ParentBackground = False
    TabOrder = 4
    object ImgPreview: TImage
      Left = 1
      Top = 1
      Width = 400
      Height = 300
      Align = alClient
      Center = True
      Proportional = True
      Stretch = True
      ExplicitHeight = 313
    end
  end
end
