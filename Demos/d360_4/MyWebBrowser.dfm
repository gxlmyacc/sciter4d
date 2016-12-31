inherited SciterWebBrowser: TSciterWebBrowser
  Caption = 'WebBrowser'
  ClientWidth = 730
  PixelsPerInch = 96
  TextHeight = 13
  object Web: TWebBrowser
    Left = 0
    Top = 41
    Width = 730
    Height = 447
    Align = alClient
    TabOrder = 1
    ControlData = {
      4C000000734B0000332E00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 730
    Height = 41
    Align = alTop
    TabOrder = 0
    DesignSize = (
      730
      41)
    object Edit1: TEdit
      Left = 5
      Top = 10
      Width = 637
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#25340#38899#36755#20837#27861
      TabOrder = 1
      Text = 'http://news.baidu.com/'
    end
    object Button1: TButton
      Left = 646
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #20999#25442#32593#39029
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
