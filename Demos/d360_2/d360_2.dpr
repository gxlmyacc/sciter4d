program d360_2;

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
  Behavior.menuBtn in 'Behavior.menuBtn.pas';

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
  
  Application.Initialize;
  Application.CreateForm(Td360Window, d360Window);
  //d360Window.WindowState := wsMaximized;
  d360Window.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'d360_2\main.html');
  Application.Run;
end.
