library VSTPlugin;


uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  Windows,
  SciterImportDefs,
  SciterPluginIntf,
  SciterBehavior,
  SciterIntf in '..\..\Public\SciterIntf.pas',
  SciterTypes in '..\..\Public\SciterTypes.pas',
  Behavior.VSTDemo in 'Behavior.VSTDemo.pas',
  superobject in 'superobject.pas';

{$R *.res}

procedure SciterLoadPlugin(const APlugin: ISciterPlugin); stdcall;
begin
  APlugin.BehaviorFactorys.Reg(TBehaviorFactory.Create('VSTDemo', TVSTDemoBehavior));
end;

procedure SciterUnloadPlugin(const APlugin: ISciterPlugin); stdcall;
begin

end;

function SciterSendMessage(const APlugin: ISciterPlugin;
  Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var bHandle: Boolean; const AFilter: WideString): LRESULT; stdcall;
begin
  Result := 0;
end;

exports
  SciterLoadPlugin,
  SciterUnloadPlugin,
  SciterSendMessage;

begin
end.
