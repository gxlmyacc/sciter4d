program Plus;

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  Forms,
  SciterImportDefs,
  SciterIntf,
  Dialogs,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MainForm};

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
  
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.LoadHtmlFile(Sciter.FilePathToURL(ExtractFilePath(ParamStr(0)))+'plus\main.html');
  Application.Run;
end.
