library Sciter4D;

{$I Sciter.inc}

{$IF CompilerVersion >= 18.5}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$IFDEF CPUX64}
  {$R 'MyRes64.res' 'MyRes64.rc'}
{$ELSE}
  {$R 'MyRes32.res' 'MyRes32.rc'}
{$ENDIF}
{$R 'version.res' 'version.rc'}
   
uses
  ShareFastMM,
  SciterTypes in '..\Public\SciterTypes.pas',
  SciterImportDefs in '..\Public\SciterImportDefs.pas',
  SciterIntf in '..\Public\SciterIntf.pas',
  SciterVideoIntf in '..\Public\SciterVideoIntf.pas',
  TiscriptIntf in '..\Public\TiscriptIntf.pas',
  SciterDebugIntf in '..\Public\SciterDebugIntf.pas',
  SciterBehavior in '..\Public\SciterBehavior.pas',
  TiscriptTypes in '..\Public\TiscriptTypes.pas',
  SciterFactoryIntf in '..\Public\SciterFactoryIntf.pas',
  SciterWndIntf in '..\Public\SciterWndIntf.pas',
  SciterGraphicTypes in '..\Public\SciterGraphicTypes.pas',
  SciterGraphicIntf in '..\Public\SciterGraphicIntf.pas',
  SciterRequestIntf in '..\Public\SciterRequestIntf.pas',
  SciterURIIntf in '..\Public\SciterURIIntf.pas',
  SciterPluginIntf in '..\Public\SciterPluginIntf.pas',
  SciterDomainIntf in '..\Public\SciterDomainIntf.pas',
  SciterDirectXIntf in '..\Public\SciterDirectXIntf.pas',
  ObjAutoEx in '..\Public\ObjAutoEx.pas',
  ObjComAutoEx in '..\Public\ObjComAutoEx.pas',
  SciterMath in 'SciterMath.pas',
  SciterHash in 'SciterHash.pas',
  SciterMemLib in 'SciterMemLib.pas',
  SciterApiImpl in 'SciterApiImpl.pas',
  SciterDom in 'SciterDom.pas',
  SciterValue in 'SciterValue.pas',
  SciterDebugImpl in 'SciterDebugImpl.pas',
  SciterLayout in 'SciterLayout.pas',
  SciterWndImpl in 'SciterWndImpl.pas',
  SciterBehaviorDef in 'SciterBehaviorDef.pas',
  SciterURIImpl in 'SciterURIImpl.pas',
  SciterPluginImpl in 'SciterPluginImpl.pas',
  SciterFactoryImpl in 'SciterFactoryImpl.pas',
  Behavior.WinCmd in 'Behavior.WinCmd.pas',
  Behavior.WinSizer in 'Behavior.WinSizer.pas',
  Behavior.MenuTab in 'Behavior.MenuTab.pas',
  Behavior.Dragable in 'Behavior.Dragable.pas',
  SciterDomainImpl in 'SciterDomainImpl.pas',
  SciterVideoImpl in 'SciterVideoImpl.pas',
  SciterGraphicApiImpl in 'SciterGraphicApiImpl.pas',
  SciterGraphicImpl in 'SciterGraphicImpl.pas',
  SciterRequestApiImpl in 'SciterRequestApiImpl.pas',
  SciterRequestImpl in 'SciterRequestImpl.pas',
  SciterDirectXImpl in 'SciterDirectXImpl.pas',
  SciterNativeMethods in 'SciterNativeMethods.pas',
  TiscriptApiImpl in 'TiscriptApiImpl.pas',
  TiscriptStream in 'TiscriptStream.pas',
  TiscriptOle in 'TiscriptOle.pas',
  TiscriptClassInfo in 'TiscriptClassInfo.pas',
  TiscriptClass in 'TiscriptClass.pas',
  TiscriptRuntime in 'TiscriptRuntime.pas',
  SciterExportDefs in 'SciterExportDefs.pas',
  SciterImpl in 'SciterImpl.pas',
  TiscriptImpl in 'TiscriptImpl.pas',
  ShadowUtils in 'ShadowUtils.pas',
  RoundUtils in 'RoundUtils.pas',
  SciterTimerMgr in 'SciterTimerMgr.pas',
  SciterArchiveImpl in 'SciterArchiveImpl.pas',
  SciterArchiveIntf in '..\Public\SciterArchiveIntf.pas';

{.$R *.res}

begin

end.
