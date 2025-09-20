object load_spec: Tload_spec
  Left = 219
  Top = 115
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Spectrum Tape/Snapshot Load'
  ClientHeight = 501
  ClientWidth = 611
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
  object DirectoryListBox1: TDirectoryListBox
    Left = 16
    Top = 33
    Width = 281
    Height = 177
    FileList = FileListBox1
    TabOrder = 0
  end
  object DriveComboBox1: TDriveComboBox
    Left = 16
    Top = 8
    Width = 281
    Height = 19
    DirList = DirectoryListBox1
    TabOrder = 1
  end
  object FileListBox1: TFileListBox
    Left = 303
    Top = 8
    Width = 299
    Height = 409
    ItemHeight = 13
    TabOrder = 2
    OnClick = FileListBox1Click
    OnDblClick = FileListBox1DblClick
    OnKeyUp = FormKeyUp
  end
  object Button1: TButton
    Left = 464
    Top = 432
    Width = 121
    Height = 39
    Caption = 'Button1'
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 320
    Top = 432
    Width = 121
    Height = 39
    Caption = 'Button2'
    TabOrder = 4
    OnClick = Button2Click
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 216
    Width = 281
    Height = 255
    Caption = 'Info'
    TabOrder = 5
    object Label1: TLabel
      Left = 24
      Top = 11
      Width = 49
      Height = 13
      Caption = 'FORMAT: '
    end
    object Label2: TLabel
      Left = 24
      Top = 25
      Width = 41
      Height = 13
      Caption = 'MODEL: '
    end
    object Label3: TLabel
      Left = 79
      Top = 11
      Width = 179
      Height = 13
      AutoSize = False
    end
    object Label4: TLabel
      Left = 79
      Top = 25
      Width = 156
      Height = 13
      AutoSize = False
    end
    object GroupBox2: TGroupBox
      Left = 7
      Top = 40
      Width = 266
      Height = 210
      Caption = 'Screen View'
      TabOrder = 0
      object Image1: TImage
        Left = 5
        Top = 14
        Width = 256
        Height = 192
      end
    end
  end
  object TreeView1: TTreeView
    Left = 608
    Top = 200
    Width = 137
    Height = 193
    Indent = 19
    TabOrder = 6
  end
end
