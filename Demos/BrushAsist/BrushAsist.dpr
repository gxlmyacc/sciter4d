program BrushAsist;

uses
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MainForm},
  Behavior.Tabs in '..\..\Public\Behaviors\Behavior.Tabs.pas';

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
  
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'BrushAsist\main.html');
  Application.Run;
end.
