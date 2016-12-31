unit WkeCtl;

interface

uses
  SysUtils, Classes, Windows, Controls, WkeIntf, Messages, WkeTypes;

type
  TWkeControl = class(TWinControl, IWkeWebBase)
  private
    FWebView: IWkeWebView;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure WndProc(var Msg: TMessage); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;

    function GetWindowName: WideString;
    function GetHwnd: HWND;
    function GetResourceInstance: THandle;
    function IWkeWebBase.GetBoundsRect = GetWkeBoundsRect;
    function GetWkeBoundsRect: TRect;
    function GetDrawRect: TRect;
    function GetDrawDC: HDC;
    procedure ReleaseDC(const ADC: HDC);
  public
    procedure LoadURL(const url: WideString);
    procedure LoadHTML(const html: WideString); overload;
    procedure LoadHTML(const html: PAnsiChar);  overload;
    procedure LoadFile(const filename: WideString);

    procedure StopLoading;
    procedure Reload;
    
    function IsLoading: Boolean;
    function IsLoaded: Boolean;
    function IsLoadFailed: Boolean;
    function IsLoadComplete: Boolean;
    function IsDocumentReady: Boolean;
    
    property WebView: IWkeWebView read FWebView;
  end;

implementation

{ TWkeControl }

procedure TWkeControl.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  if FWebView <> nil then
    FWebView.HostWindow := Self.WindowHandle;
end;

procedure TWkeControl.CreateWnd;
begin
  inherited;
  FWebView := Wke.CreateWebView(Self);
end;

procedure TWkeControl.DestroyWindowHandle;
begin
  if FWebView <> nil then
    FWebView.HostWindow := 0;

  inherited;
end;

procedure TWkeControl.DestroyWnd;
begin
  FWebView := nil;
  inherited;
end;

function TWkeControl.GetDrawDC: HDC;
begin
  Result := GetDC(GetHwnd);
end;

function TWkeControl.GetDrawRect: TRect;
begin
  Result := Self.ClientRect;
end;

function TWkeControl.GetHwnd: HWND;
begin
  Result := Self.Handle;
end;

function TWkeControl.GetResourceInstance: THandle;
begin
  Result := SysInit.HInstance;
end;

function TWkeControl.GetWindowName: WideString;
begin
  Result := Self.ClassName;
end;

function TWkeControl.GetWkeBoundsRect: TRect;
begin
  Result := Self.GetClientRect;
end;

function TWkeControl.IsDocumentReady: Boolean;
begin
  Result := FWebView.IsDocumentReady;
end;

function TWkeControl.IsLoadComplete: Boolean;
begin
  Result := FWebView.IsLoadComplete;
end;

function TWkeControl.IsLoaded: Boolean;
begin
  Result := FWebView.IsLoadSucceeded;
end;

function TWkeControl.IsLoadFailed: Boolean;
begin
  Result := FWebView.IsLoadFailed;
end;

function TWkeControl.IsLoading: Boolean;
begin
  Result := FWebView.IsLoading;
end;

procedure TWkeControl.LoadFile(const filename: WideString);
begin
  FWebView.LoadFile(filename);
end;

procedure TWkeControl.LoadHTML(const html: PAnsiChar);
begin
  FWebView.LoadHTML(html);
end;

procedure TWkeControl.LoadHTML(const html: WideString);
begin
  FWebView.LoadHTML(html);
end;

procedure TWkeControl.LoadURL(const url: WideString);
begin
  FWebView.LoadURL(url);
end;

procedure TWkeControl.ReleaseDC(const ADC: HDC);
begin
  Windows.ReleaseDC(GetHwnd, ADC);
end;

procedure TWkeControl.Reload;
begin
  FWebView.Reload;
end;

procedure TWkeControl.StopLoading;
begin
  FWebView.StopLoading;
end;

procedure TWkeControl.WndProc(var Msg: TMessage);
var
  bHandle: Boolean;
begin
  if HandleAllocated and (FWebView <> nil) then
  begin
    bHandle := False;
    Msg.Result := FWebView.ProcND(Msg.Msg, Msg.WParam, Msg.LParam, bHandle);
    if bHandle then
      Exit;
  end;

  inherited;
end;

end.
