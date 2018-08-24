{*******************************************************************************
 标题:     SciterDebugImpl.pas
 描述:     调试相关
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDebugImpl;

interface

uses
  Windows, SysUtils, SciterTypes, SciterIntf, SciterApiImpl, SciterDebugIntf;

type
  TDebugOutput = class(TInterfacedObject, IDebugOutput)
  private
    Fhwnd: HWINDOW;
  public
    procedure SetupOn(hwnd: HWINDOW = 0);
    procedure SetupOff;

    function Implementator: Pointer;

    function InspectorIsPresent: Boolean;

    function Inspect(const root: IDomElement; const IP: SciterString = ''): Boolean; overload;
    function Inspect(const layout: PISciterLayout; const IP: SciterString = ''): Boolean; overload;

    procedure Output(subsystem: TOutputSubSystem; severity: TOutputSeverity; text: LPCWSTR; text_length: UINT); virtual;
  end;

procedure _SciterDebug(param: Pointer; subsystem: TOutputSubSystem; severity: TOutputSeverity; text: PWideChar; text_length: UINT); stdcall;

implementation

uses
  SciterExportDefs;

procedure _output_debug(param: LPVOID; subsystem: TOutputSubSystem;
  severity: TOutputSeverity; text: LPCWSTR; text_length: UINT); stdcall;
begin
  TDebugOutput(param).Output(subsystem, severity, text, text_length);
end;

procedure _SciterDebug(param: Pointer; subsystem: TOutputSubSystem; severity: TOutputSeverity; text: PWideChar; text_length: UINT); stdcall;
begin
  if (@__Sciter.OnDebugMessage <> nil) then
    __Sciter.OnDebugMessage(subsystem, severity, SciterString(text))
  else
    case severity of
      OS_INFO:    Trace(text);
      OS_WARNING: TraceWarnning(text);
      OS_ERROR:   TraceError(text);
    end;
end;

{ debug_output }
function TDebugOutput.Implementator: Pointer;
begin
  Result := Self;
end;

function TDebugOutput.Inspect(const root: IDomElement; const IP: SciterString): Boolean;
var
  sScript: SciterString;
  sInspectorFile, sDirectory: SciterString;
begin
  Result := False;
  sInspectorFile := SciterModulePath + 'inspector.exe';
  sDirectory := SciterModulePath;
  if not FastFileExists(sInspectorFile) then Exit;
  if (not InspectorIsPresent) then
    ShellExecuteW(0, 'open', PWideChar(sInspectorFile), '', PWideChar(sDirectory), SW_SHOWNORMAL);

  if IP = EmptyStr then
    sScript := 'this.timer(500ms, function(){if (view.connectToInspector) view.connectToInspector(this.tag==="html" ? this.parent: this);})'
  else
    sScript := 'this.timer(500ms, function(){if (view.connectToInspector) view.connectToInspector(this.tag==="html" ? this.parent: this, "'+IP+'");})';
  root.Eval(sScript);
  Result := True;
end;

function TDebugOutput.Inspect(const layout: PISciterLayout; const IP: SciterString): Boolean;
begin
  Result := Inspect(layout.RootElement, IP);
end;

function TDebugOutput.InspectorIsPresent: Boolean;
begin
  Result := FindWindowW('H-SMILE-FRAME', 'Sciter''s Inspector') <> 0;
  if not Result then
    Result := FindWindowW('H-SMILE-FRAME', 'Sciter 检视器') <> 0;
end;

procedure TDebugOutput.Output(subsystem: TOutputSubSystem;
  severity: TOutputSeverity; text: LPCWSTR; text_length: UINT);
var
  sOutput: string;
begin
  case severity of
    OS_INFO:    sOutput := sOutput + 'info:';
    OS_WARNING: sOutput := sOutput + 'warning:';
    OS_ERROR:   sOutput := sOutput + 'error:';
  end;
  case subsystem of
    OT_DOM:   sOutput := sOutput + 'DOM:';
    OT_CSSS:  sOutput := sOutput + 'csss!:';
    OT_CSS:   sOutput := sOutput + 'css:';
    OT_TIS:   sOutput := sOutput + 'script:';
  end;
  if text_length > 0 then
    sOutput := sOutput + text;
  Trace(sOutput);
end;

procedure TDebugOutput.SetupOff;
begin
  if Fhwnd <> 0 then
    SAPI.SciterSetupDebugOutput(Fhwnd, @Self, nil);
end;

procedure TDebugOutput.SetupOn(hwnd: HWINDOW);
begin
  Fhwnd := hwnd;
  if Fhwnd <> 0 then
    SAPI.SciterSetupDebugOutput(hwnd, @Self, _output_debug);
end;

end.
