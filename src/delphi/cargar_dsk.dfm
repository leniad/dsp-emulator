object load_dsk: Tload_dsk
  Left = 183
  Top = 154
  Caption = 'Open/Abrir Disk'
  ClientHeight = 455
  ClientWidth = 688
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
  object Button1: TButton
    Left = 579
    Top = 376
    Width = 97
    Height = 34
    Caption = 'CANCELAR'
    TabOrder = 1
    OnClick = Button1Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 270
    Width = 565
    Height = 179
    Caption = 'Contenido ZIP / Inside ZIP'
    TabOrder = 2
    object StringGrid1: TStringGrid
      Left = 4
      Top = 18
      Width = 556
      Height = 151
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
      OnDblClick = StringGrid1DblClick
      ColWidths = (
        134
        134)
      RowHeights = (
        15
        15)
    end
  end
  object Button2: TButton
    Left = 579
    Top = 336
    Width = 97
    Height = 34
    Caption = 'CARGAR'
    TabOrder = 0
    OnClick = Button2Click
  end
  object FileListBox1: TFileListBox
    Left = 271
    Top = 8
    Width = 420
    Height = 257
    TabStop = False
    ItemHeight = 13
    TabOrder = 3
    OnClick = FileListBox1Click
    OnDblClick = FileListBox1DblClick
  end
  object DirectoryListBox1: TDirectoryListBox
    Left = 8
    Top = 33
    Width = 257
    Height = 232
    TabStop = False
    FileList = FileListBox1
    TabOrder = 4
    OnChange = DirectoryListBox1Change
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
