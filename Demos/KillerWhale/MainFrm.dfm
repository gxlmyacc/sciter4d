inherited MainForm: TMainForm
  Left = 385
  Top = 175
  BorderStyle = bsNone
  Caption = 'MainForm'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tm: TTimer
    Enabled = False
    Interval = 15
    OnTimer = tmTimer
    Left = 40
    Top = 32
  end
end
