library SciterIE;

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
  Behavior.IE in 'Behavior.IE.pas',
  WebBrowserEx in 'WebBrowserEx.pas';

{$R *.res}

procedure SciterLoadPlugin(const APlugin: ISciterPlugin); stdcall;
begin   
  APlugin.BehaviorFactorys.Reg(TBehaviorFactory.Create('ie', TIEBehavior));
end;

procedure SciterUnloadPlugin(const APlugin: ISciterPlugin); stdcall;
begin
 
end;

exports
  SciterLoadPlugin,
  SciterUnloadPlugin;

begin
end.
