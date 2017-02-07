library SciterFlash;

{$IF CompilerVersion >= 18.5}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  ShareFastMM,
  SysUtils,
  Classes,
  Windows,
  SciterIntf,
  SciterPluginIntf,
  SciterBehavior,
  Behavior.Flash in 'Behavior.Flash.pas',
  Behavior.ActiveX in 'Behavior.ActiveX.pas';

{$R *.res}

procedure SciterLoadPlugin(const APlugin: ISciterPlugin); stdcall;
begin   
  APlugin.BehaviorFactorys.Reg(TBehaviorFactory.Create('flash', TFlashBehavior));
end;

procedure SciterUnloadPlugin(const APlugin: ISciterPlugin); stdcall;
begin
 
end;

exports
  SciterLoadPlugin,
  SciterUnloadPlugin;

begin
end.
