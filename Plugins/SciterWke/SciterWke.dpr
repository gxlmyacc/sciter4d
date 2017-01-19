library SciterWke;

{$IF CompilerVersion >= 18.5}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  ShareFastMM,
  SysUtils,
  Windows,
  SciterBehavior,
  WkeImportDefs,
  SciterPluginIntf,
  WkeIntf,
  SciterIntf in '..\..\Public\SciterIntf.pas',
  SciterTypes in '..\..\Public\SciterTypes.pas',
  Behavior.Wke in 'Behavior.Wke.pas';

{$R *.res}

procedure SciterLoadPlugin(const APlugin: ISciterPlugin); stdcall;
var
  sWkePath: string;
begin               
  sWkePath := ExtractFilePath(GetModuleName(Sciter.Handle)) + 'Wke';
  if DirectoryExists(sWkePath) then
    LoadWke4D(sWkePath+'\'+DLL_Wke4D);
  if not WkeEnabled then
  begin
    Sciter.TraceFmt('Load [%s] Failed!', [sWkePath + 'Wke\' + DLL_Wke4D]);
    Exit;
  end;
  Wke.DriverName := sWkePath + '\'+ DLL_Wke;

  APlugin.BehaviorFactorys.Reg(TBehaviorFactory.Create('wke', TWkeStreamBehavior));
end;

procedure SciterUnloadPlugin(const APlugin: ISciterPlugin); stdcall;
begin

end;

function SciterSendMessageProc(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
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
