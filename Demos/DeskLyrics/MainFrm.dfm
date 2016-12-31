inherited MainForm: TMainForm
  Left = 190
  Top = 631
  BorderStyle = bsNone
  Caption = 'MainForm'
  ClientHeight = 96
  ClientWidth = 1020
  FormStyle = fsStayOnTop
  PopupMenu = PopupMenu1
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tmTimer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tmTimerTimer
    Left = 715
    Top = 30
  end
  object PopupMenu1: TPopupMenu
    Left = 830
    Top = 25
    object N1: TMenuItem
      Caption = #36864#20986
      OnClick = N1Click
    end
  end
end
