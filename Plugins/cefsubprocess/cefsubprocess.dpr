program cefsubprocess;

uses
  SysUtils,
  ceflib;

type
  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
  end;

{ TCustomRenderProcessHandler }

procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin

end;

begin
  CefLibrary := ExtractFilePath(GetModuleName(HInstance)) + 'libcef.dll';
  if not FileExists(CefLibrary) then
    CefLibrary := ExtractFilePath(GetModuleName(HInstance)) + '\Plugins\cef\libcef.dll';
  if not FileExists(CefLibrary) then
    Exit;
  CefRenderProcessHandler := TCustomRenderProcessHandler.Create;
  if not CefLoadLibDefault then
    Exit;
end.
