program d360_3;

uses
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  SciterChildFrm in '..\..\Public\vcl\SciterChildFrm.pas' {WinToolForm},
  MainFrm in 'MainFrm.pas' {d360Window},
  Behavior.CmbBtn in 'Behavior.CmbBtn.pas',
  Behavior.LogoBtn in 'Behavior.LogoBtn.pas',
  Behavior.menuBtn in 'Behavior.menuBtn.pas',
  MyWebBrowser in 'MyWebBrowser.pas' {SciterWebBrowser};

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  Application.Initialize;
  Application.CreateForm(Td360Window, d360Window);
  d360Window.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'d360_3\main.html');
  Application.Run;
end.
