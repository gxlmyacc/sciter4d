object SciterWebBrowser: TSciterWebBrowser
  Left = 409
  Top = 146
  BorderStyle = bsNone
  Caption = 'WebBrowser'
  ClientHeight = 356
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Web: TWebBrowser
    Left = 0
    Top = 41
    Width = 554
    Height = 315
    Align = alClient
    TabOrder = 1
    ControlData = {
      4C000000423900008E2000000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 554
    Height = 41
    Align = alTop
    TabOrder = 0
    DesignSize = (
      554
      41)
    object Edit1: TEdit
      Left = 5
      Top = 10
      Width = 472
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 2
      Text = 'http://news.baidu.com/'
    end
    object Button1: TButton
      Left = 735
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #20999#25442#32593#39029
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 484
      Top = 9
      Width = 57
      Height = 22
      Caption = 'Button2'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
end
