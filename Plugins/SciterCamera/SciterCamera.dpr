library SciterCamera;

uses
  FastMM4,
  Windows,
  SciterBehavior,
  SciterIntf in '..\..\Public\SciterIntf.pas',
  SciterTypes in '..\..\Public\SciterTypes.pas',
  Behavior.Camera in 'Behavior.Camera.pas',
  SciterCapture in 'SciterCapture.pas',
  vfw in 'vfw.pas';

{$R *.res}

procedure SciterLoadPlugin(const APlugin: ISciterPlugin; const URI: ISciterURI); stdcall;
begin
  APlugin.BehaviorFactorys.Reg(TBehaviorFactory.Create('camera', TCameraStreamBehavior));
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
