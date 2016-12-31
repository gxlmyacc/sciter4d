program Layered;

uses
  {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
  {$ELSE}
  FastMM4,
  {$IFEND }
  Windows,
  SysUtils,
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

  MainFrom := CreateWindow(HInstance, CWFlags_None + [swAlpha, swScreenCenter, swMain], 412, 588);
  MainFrom.Caption := '¶¯»­Í¼²ã´°¿Ú';
  MainFrom.Layout.LoadFile('file://'+ExtractFilePath(ParamStr(0))+'Layered\main.htm');
  MainFrom.Show();
  
  Sciter.RunAppclition(MainFrom.Handle);
end.
