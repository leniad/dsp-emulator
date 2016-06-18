object load_dsk: Tload_dsk
  Left = 183
  Top = 154
  Caption = 'Open/Abrir DSK'
  ClientHeight = 492
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnKeyUp = FileListBox1KeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 459
    Top = 320
    Width = 97
    Height = 34
    Caption = 'CANCELAR'
    TabOrder = 1
    OnClick = Button1Click
    OnKeyUp = FileListBox1KeyUp
  end
  object GroupBox1: TGroupBox
    Left = 275
    Top = 33
    Width = 281
    Height = 185
    Caption = 'Contenido ZIP / Inside ZIP'
    TabOrder = 2
    object StringGrid1: TStringGrid
      Left = 6
      Top = 18
      Width = 272
      Height = 159
      TabStop = False
      ColCount = 2
      DefaultColWidth = 134
      DefaultRowHeight = 15
      FixedCols = 0
      RowCount = 2
      GridLineWidth = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 0
      OnClick = StringGrid1Click
      OnDblClick = StringGrid1DblClick
      OnKeyUp = FileListBox1KeyUp
      ColWidths = (
        134
        134)
      RowHeights = (
        15
        15)
    end
  end
  object Button2: TButton
    Left = 459
    Top = 280
    Width = 97
    Height = 34
    Caption = 'CARGAR'
    TabOrder = 0
    OnClick = Button2Click
    OnKeyUp = FileListBox1KeyUp
  end
  object FileListBox1: TFileListBox
    Left = 8
    Top = 224
    Width = 445
    Height = 257
    TabStop = False
    ItemHeight = 13
    Mask = '*.zip;*.dsk;*.ipf'
    TabOrder = 3
    OnClick = FileListBox1Click
    OnDblClick = FileListBox1DblClick
    OnKeyUp = FileListBox1KeyUp
  end
  object DirectoryListBox1: TDirectoryListBox
    Left = 8
    Top = 33
    Width = 257
    Height = 185
    TabStop = False
    FileList = FileListBox1
    TabOrder = 4
    OnKeyUp = FileListBox1KeyUp
  end
  object DriveComboBox1: TDriveComboBox
    Left = 8
    Top = 8
    Width = 257
    Height = 19
    DirList = DirectoryListBox1
    TabOrder = 5
    TabStop = False
  end
end
