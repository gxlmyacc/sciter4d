program d360_4;

uses
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {d360Window},
  Behavior.CmbBtn in 'Behavior.CmbBtn.pas',
  Behavior.LogoBtn in 'Behavior.LogoBtn.pas',
  Behavior.menuBtn in 'Behavior.menuBtn.pas',
  MyWebBrowser in 'MyWebBrowser.pas' {SciterWebBrowser},
  SciterWtlCtl in '..\..\Public\Obsolete\SciterWtlCtl.pas' {WinToolForm};

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  Application.Initialize;
  Application.CreateForm(Td360Window, d360Window);
  d360Window.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'d360_4/main.html');
  Application.Run;
end.
