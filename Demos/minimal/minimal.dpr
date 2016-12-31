program minimal;

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MinimalWindow},
  Forms;

{$R *.res}

begin
  {$IF CompilerVersion > 18.5}
   ReportMemoryLeaksOnShutdown := True;
  {$IFEND}
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  Application.Initialize;
  Application.CreateForm(TMinimalWindow, MinimalWindow);
  MinimalWindow.Layout.Options := MinimalWindow.Layout.Options + [sloUseHtmlTitle];
  MinimalWindow.LoadHtmlFile('minimal.htm');
  Application.Run;
end.
