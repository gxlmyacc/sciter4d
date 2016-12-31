program EPPortal;

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {EPPortalWindow},
  Behavior.LogoBtn in 'Behavior.LogoBtn.pas',
  Behavior.MoreBtn in 'Behavior.MoreBtn.pas',
  AboutFrm in 'AboutFrm.pas' {AboutForm},
  MyWebBrowser in 'MyWebBrowser.pas' {SciterWebBrowser},
  Behavior.MyWebBrowser in 'Behavior.MyWebBrowser.pas',
  Behavior.MenuHover in 'Behavior.MenuHover.pas',
  SciterCtl in '..\..\Public\vcl\SciterCtl.pas';

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
              
  Application.Initialize;
  Application.CreateForm(TEPPortalWindow, EPPortalWindow);
  EPPortalWindow.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'EPPortal\main.html');
  Application.Run;
end.
