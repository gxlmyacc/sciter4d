program Sciter;

{$R 'MyRes.res' 'MyRes.rc'}

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  Windows,
  Classes,
  SysUtils,
  SciterBehavior,
  SciterImportDefs,
  SciterTypes,
  SciterIntf,
  SciterWndIntf,
  SciterObj in 'SciterObj.pas',
  ObjComAutoEx,
  //Behavior.Cef,
  Behavior.NativeClock in 'Behavior.NativeClock.pas',
  Behavior.GDIDrawing in 'Behavior.GDIDrawing.pas',
  Behavior.MolehillOpengl in 'Behavior.MolehillOpengl.pas';

{$R *.res}

function OleInitialize(pwReserved: Pointer): HResult; stdcall; external 'ole32.dll' name 'OleInitialize';
procedure OleUninitialize; stdcall; external 'ole32.dll' name 'OleUninitialize';

var
  MainForm: ISciterWindow;
  sMasterFile, sMasterDir, sOpenFile: string;

begin
  {$IF CompilerVersion > 18.5}
   ReportMemoryLeaksOnShutdown := True;
  {$IFEND}
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  //SciterIntf.Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  //SciterIntf.Sciter.ReportBehaviorCount := True;

  sMasterDir := ExtractFilePath(ParamStr(0)) + 'SciterTest\';
//  sMasterFile := sMasterDir + 'win-master.css';
//  if FileExists(sMasterFile) then
//    SciterIntf.Sciter.MainMasterFile := sMasterFile;
  sMasterFile := sMasterDir + 'debug-peer.tis';
  if FileExists(sMasterFile) then
    SciterIntf.Sciter.DebugPeerFile := sMasterFile;

  BehaviorFactorys.Reg(TBehaviorFactory.Create('native-clock', TNativeClockBehavior));
  BehaviorFactorys.Reg(TBehaviorFactory.Create('gdi-drawing', TGDIDrawingBehavior));
  BehaviorFactorys.Reg(TBehaviorFactory.Create('molehill-opengl', TMolehillOpenglBehavior));

  MainForm := CreateWindow(HInstance,
    CWFlags_Sizeable + [swScreenCenter,swEnableDebug, swMain], 970, 642);
  MainForm.Layout.Behavior.RttiObject :=  WrapObjectDispatch(TSciterObject.Create(MainForm), True) as IDispatchRttiObject;
  sOpenFile := ParamStr(1);
  if (sOpenFile <> '') then
  begin
    if FileExists(sOpenFile) then
      MainForm.Layout.LoadFile('file://' + sOpenFile)
    else
      MainForm.Layout.LoadFile(sOpenFile);
  end
  else
    MainForm.Layout.LoadFile('res:default.html');

  MainForm.Show();
  SciterIntf.Sciter.RunAppclition(MainForm.Handle);
end.
