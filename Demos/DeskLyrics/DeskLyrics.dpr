program DeskLyrics;

uses
  Forms,
  SysUtils,
  SciterImportDefs,
  SciterTypes in '..\..\Public\SciterTypes.pas',
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  SciterIntf in '..\..\Public\SciterIntf.pas',
  MainFrm in 'MainFrm.pas' {MainForm};

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'DeskLyrics\main.html');
  Application.Run;
end.
