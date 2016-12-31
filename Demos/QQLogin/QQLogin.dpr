program QQLogin;

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  Windows,
  SciterImportDefs,
  SciterTypes,
  SciterIntf,
  SciterWndIntf;

{$R *.res}

var
  MainFrom: ISciterWindow;
begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  MainFrom := CreateWindow(HInstance, CWFlags_None + [swAlpha, swScreenCenter, swMain], 442, 342);
  MainFrom.Caption := 'QQµÇÂ¼´°¿Ú';
  MainFrom.Layout.LoadFile('file://'+ExtractFilePath(ParamStr(0))+'QQLogin\QQLogin.htm');
  MainFrom.Show();
  
  Sciter.RunAppclition(MainFrom.Handle);
end.
