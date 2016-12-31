program VSTDemo;

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
  SciterDomainIntf,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MainForm};

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  //¶þ¼¶ÓòÃû
  SciterTopDomain.DomainByName[DOMAIN_Sciter4D].Domain.Add('VSTDemo', 'VSTDemo\');

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  MainForm.Layout.Options := MainForm.Layout.Options + [sloUseHtmlTitle];
  MainForm.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'VSTDemo/main.html');

  Application.Run;
end.

