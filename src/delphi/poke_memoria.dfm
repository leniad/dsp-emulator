object poke_spec: Tpoke_spec
  Left = 379
  Top = 213
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Poke Memory/Pokear Memoria'
  ClientHeight = 124
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 8
    Width = 29
    Height = 20
    AutoSize = False
    Caption = 'DIR'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 72
    Top = 8
    Width = 81
    Height = 17
    AutoSize = False
    Caption = '<'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label4: TLabel
    Left = 32
    Top = 40
    Width = 31
    Height = 20
    AutoSize = False
    Caption = 'VAL'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label5: TLabel
    Left = 72
    Top = 40
    Width = 81
    Height = 20
    AutoSize = False
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Button1: TButton
    Left = 16
    Top = 80
    Width = 89
    Height = 33
    Caption = 'POKE!'
    TabOrder = 0
    TabStop = False
    OnClick = Button1Click
    OnKeyUp = FormKeyUp
  end
  object Button2: TButton
    Left = 132
    Top = 80
    Width = 85
    Height = 33
    Caption = 'CANCELAR'
    TabOrder = 1
    TabStop = False
    OnClick = Button2Click
    OnKeyUp = FormKeyUp
  end
end
