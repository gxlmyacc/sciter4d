object SciterWebBrowser: TSciterWebBrowser
  Left = 369
  Top = 144
  VertScrollBar.Visible = False
  BorderStyle = bsNone
  Caption = 'WebBrowser'
  ClientHeight = 385
  ClientWidth = 704
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Web: TWebBrowser
    Left = 0
    Top = 41
    Width = 704
    Height = 344
    Align = alClient
    TabOrder = 1
    ControlData = {
      4C000000C34800008E2300000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 704
    Height = 41
    Align = alTop
    TabOrder = 0
    DesignSize = (
      704
      41)
    object Edit1: TEdit
      Left = 3
      Top = 10
      Width = 613
      Height = 21
      Anchors = [akLeft, akTop, akRight, akBottom]
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 1
      Text = 'http://news.baidu.com/'
    end
    object Button1: TButton
      Left = 625
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight, akBottom]
      Caption = #20999#25442#32593#39029
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
