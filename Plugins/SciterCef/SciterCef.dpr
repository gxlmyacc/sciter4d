library SciterCef;

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
  SciterBehavior,
  Behavior.Cef;

{$R *.res}

procedure SciterLoadPlugin(const APlugin: ISciterPlugin; const URI: ISciterURI); stdcall;
begin   
  APlugin.BehaviorFactorys.Reg(TBehaviorFactory.Create('cef', TCefBehavior));
end;

procedure SciterUnloadPlugin(const APlugin: ISciterPlugin); stdcall;
begin
 
end;

function SciterSendMessageProc(const APlugin: ISciterPlugin;
  Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var bHandle: Boolean; const AFilter: WideString): LRESULT; stdcall;
begin
  Result := 0;
end;

exports
  SciterLoadPlugin,
  SciterUnloadPlugin,
  SciterSendMessageProc;

begin
end.
