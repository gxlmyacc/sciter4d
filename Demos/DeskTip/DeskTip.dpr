program DeskTip;

{$R 'MyRes.res' 'MyRes.rc'}

uses
  SysUtils,
  Windows,
  Forms,
  CommCtrl,
  Messages,
  SciterImportDefs,
  SciterIntf,
  ShellAPI,
  Controls,
  ImgList,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MainForm},
  DesktopUtils in 'DesktopUtils.pas';

{$R *.res}



var
  iIndex: Integer;
  rc: TRect;
begin
  iIndex := DesktopManager.IndexOfItemCaption('回收站');
  if iIndex < 0 then
    Exit;
  
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  SetWindowLong(Application.Handle, GWL_EXSTYLE,
      GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
  //显示桌面
  DesktopManager.ShowDesktop;

  rc := DesktopManager.ItemRect[iIndex];
  SetWindowLong(MainForm.Handle, GWL_HWNDPARENT, DesktopManager.DeskWnd);
  MainForm.SetBounds(rc.Right, (rc.Top + rc.Bottom - MainForm.Height) div 2, MainForm.Width, MainForm.Height);

  MainForm.LoadHtmlFile('res:default.html');

  Application.Run;
end.
