program SciterTest;


uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  Classes,
  Forms,
  SciterImportDefs,
  SciterIntf,
  MainFrm in 'MainFrm.pas' {MainForm},
  SciterCtl in '..\..\Public\vcl\SciterCtl.pas',
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm};

{$R *.res}

var
  sMasterFile: string;

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  sMasterDir := ExtractFilePath(ParamStr(0))
    + ChangeFileExt(ExtractFileName(ParamStr(0)), '') + '\';

  sMasterFile := sMasterDir + 'win-master.css';
  if FileExists(sMasterFile) then
    Sciter.MainMasterFile := sMasterFile;
  sMasterFile := sMasterDir + 'msgbox.htm';
  if FileExists(sMasterFile) then
    Sciter.MsgboxHtmlFile := sMasterFile;
  sMasterFile := sMasterDir + 'msgbox.css';
  if FileExists(sMasterFile) then
    Sciter.MsgboxCSSFile := sMasterFile;
  sMasterFile := sMasterDir + 'debug-peer.tis';
  if FileExists(sMasterFile) then
    Sciter.DebugPeerFile := sMasterFile;
  sMasterFile := sMasterDir + 'base-library.tis';
  if FileExists(sMasterFile) then
    Sciter.BaseLibraryFile := sMasterFile;
          
  Application.Initialize;
  Application.Title := 'SciterTest';
  Application.CreateForm(TMainForm, MainForm);

  Application.Run;
end.
