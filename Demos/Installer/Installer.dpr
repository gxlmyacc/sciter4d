program Installer;

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  Windows,
  SciterObj,
  SciterImportDefs,
  SciterTypes,
  SciterIntf,
  SciterWndIntf,
  ObjComAutoEx;

{$R *.res}

var
  MainForm: ISciterWindow;
  LRect: TRect;

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
  
  LRect.Left := 0;
  LRect.Top := 0;
  LRect.Right := 666;
  LRect.Bottom := 456;
  MainForm := CreateWindow(HInstance, CWFlags_None + [swScreenCenter, swEnableDebug, swMain], LRect);
  MainForm.Layout.Behavior.RttiObject := WrapObjectDispatch(TSciterObject.Create(MainForm), True) as IDispatchRttiObject;
  MainForm.Caption := '应用安装包';
  MainForm.Layout.LoadFile('file://'+ExtractFilePath(ParamStr(0))+'Installer/Index.html');
  MainForm.Show();
  
  Sciter.RunAppclition(MainForm.Handle);
end.
