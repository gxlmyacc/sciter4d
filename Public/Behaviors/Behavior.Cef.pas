unit Behavior.Cef;

interface

uses
  SysUtils, Windows, ActiveX, ceflib, SciterImportDefs, SciterTypes, SciterIntf, SciterBehavior,
  TiscriptIntf, Messages;

const
  SCITER_CEF_WINDOW_CLASS_NAME = 'SciterCefWindow-A24989B52E78';

type
  TCefBehavior = class;

  ICefClientHandler = interface
    ['{E76F6888-D9C3-4FCE-9C23-E89659820A36}']
    procedure Disconnect;
  end;
  TCustomClient = class(TCefClientOwn, ICefClientHandler)
  private
    FBehavior: TCefBehavior;
    FLifeSpan: ICefLifeSpanHandler;
    FLoad: ICefLoadHandler;
  protected
    function GetLifeSpanHandler: ICefLifeSpanHandler; override;
    function GetLoadHandler: ICefLoadHandler; override;

    procedure Disconnect;
  public
    constructor Create(const ABehavior: TCefBehavior); reintroduce;
    destructor Destroy; override;
  end;

  TCustomLifeSpan = class(TCefLifeSpanHandlerOwn)
  private
    FBehavior: TCefBehavior;
  protected
    procedure OnAfterCreated(const browser: ICefBrowser); override;
    procedure OnBeforeClose(const browser: ICefBrowser); override;
  public
    constructor Create(const ABehavior: TCefBehavior); reintroduce;
  end;

  TCustomLoad = class(TCefLoadHandlerOwn)
  private
    FBehavior: TCefBehavior;
  public
    constructor Create(const ABehavior: TCefBehavior); reintroduce;
  end;
  
  TCefBehavior = class(TBehaviorEventHandler)
  private
    FClient: ICefClient;
    FBrowser: ICefBrowser;
    FBrowserId: Integer;
    FUrl: WideString;
    procedure SetUrl(const Value: WideString);
  protected
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnFocus(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
  public
    procedure Config(const AOptions: ITiscriptObject);
    
    function  CanGoBack: Boolean;
    function  CanGoForward: Boolean;
    procedure GoBack();
    procedure GoForward();
    
    procedure Go(const Url: WideString);

    procedure Refresh();
    procedure Stop();

    procedure ShowDevTools(const APoint: ITiscriptObject);
    procedure CloseDevTools;
        
    property Url: WideString read FUrl write SetUrl;
  end;

function InitCef: Boolean;
function SciterCefRunAppclition(const MainWnd: HWINDOW; var bHandled: Boolean): Integer;

implementation

type
  TCustomBrowserProcessHandler = class(TCefBrowserProcessHandlerOwn)
  end;
var
  UseMyRunAppclition: Boolean = False;
function SciterCefRunAppclition(const MainWnd: HWINDOW; var bHandled: Boolean): Integer;
begin
  Result := -1;
  try
    UseMyRunAppclition := True;
    bHandled := True;
    CefRunMessageLoop;
    Result := 0;
  except
    on E: Exception do
      OutputDebugString(PChar('[CefRunAppclition]'+E.Message));
  end;
end;

procedure RegisterSchemes(const registrar: ICefSchemeRegistrar);
begin
  //registrar.AddCustomScheme(NativeScheme, False, True, False);
end;

procedure BeforeCommandLineProcessing(const processType: ustring; const commandLine: ICefCommandLine);
begin
  if processType = '' then
  begin
    commandLine.AppendSwitch('allow-access-from-files');
    commandLine.AppendSwitch('allow-universal-access-from-files');
    commandLine.AppendSwitch('allow-running-insecure-content');
    commandLine.AppendSwitch('disable-web-security');
    commandLine.AppendSwitch('enable-npapi');
    commandLine.AppendSwitch('process-per-site');
    //commandLine.AppendSwitch('disable-gpu');
  end;
end;

var
  varCefInited: Boolean = False;
  varCefDir: string;
function InitCef: Boolean;
begin
  Result := True;
  if varCefInited then
    Exit;
  varCefDir := ExtractFilePath(GetModuleName(MainInstance)) + 'Plugins\cef\';
  CefLibrary := varCefDir + 'libcef.dll';
  if not FileExists(CefLibrary) then
  begin
    Result := False;
    Exit;  
  end;
  CefCache := ExtractFilePath(GetModuleName(MainInstance)) + 'cefcache';
  CefLogFile := ExtractFilePath(GetModuleName(MainInstance)) + 'SciterCef.log';
  CefBrowserSubprocessPath := ExtractFilePath(GetModuleName(MainInstance)) + 'cefsubprocess.exe';
  CefLocale := 'zh-CN';
  CefResourcesDirPath := ExcludeTrailingPathDelimiter(varCefDir);
  CefLogSeverity := LOGSEVERITY_WARNING;
  CefAcceptLanguageList := 'zh-CN,zh';
  CefOnRegisterCustomSchemes := RegisterSchemes;
  CefOnBeforeCommandLineProcessing := BeforeCommandLineProcessing;
  CefBrowserProcessHandler := TCustomBrowserProcessHandler.Create;
  CefSingleProcess := False;
  CefIgnoreCertificateErrors := True;
  if not CefLoadLibDefault then
  begin
    Result := False;
    Exit;
  end;
  varCefInited := True;
end;

{ TCefBehavior }

function TCefBehavior.CanGoBack: Boolean;
begin
  if FBrowser <> nil then
    Result := FBrowser.CanGoBack
  else
    Result := False;
end;

function TCefBehavior.CanGoForward: Boolean;
begin
  if FBrowser <> nil then
    Result := FBrowser.CanGoForward
  else
    Result := False;
end;

procedure TCefBehavior.Config(const AOptions: ITiscriptObject);
begin

end;

procedure TCefBehavior.ShowDevTools(const APoint: ITiscriptObject);
var
  info: TCefWindowInfo;
  inspectElementAt: TCefPoint;
  settings: TCefBrowserSettings;
begin
  if (FBrowser = nil) then Exit;

  FillChar(info, SizeOf(info), 0);
  info.style := WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE;
  info.parent_window := FBrowser.Host.WindowHandle;
  info.x := Integer(CW_USEDEFAULT);
  info.y := Integer(CW_USEDEFAULT);
  info.width := Integer(CW_USEDEFAULT);
  info.height := Integer(CW_USEDEFAULT);
  info.window_name := CefString('DevTools');
  FillChar(settings, sizeof(settings), 0);
  settings.size := SizeOf(settings);

  if APoint <> nil then
  begin
    inspectElementAt.x := APoint.Item['x'].I;
    inspectElementAt.y := APoint.Item['y'].I;
  end
  else
  begin
    inspectElementAt.x := 0;
    inspectElementAt.y := 0;
  end;
  FBrowser.Host.ShowDevTools(@info, TCefClientOwn.Create as ICefClient, @settings, @inspectElementAt);
end;

procedure TCefBehavior.CloseDevTools;
begin
  if (FBrowser <> nil) then
    FBrowser.Host.CloseDevTools;
end;

procedure TCefBehavior.Go(const Url: WideString);
begin
  FUrl := Url;
  if (FBrowser <> nil) and (FBrowser.MainFrame <> nil) then
    FBrowser.MainFrame.LoadUrl(Url);
end;

procedure TCefBehavior.GoBack;
begin
  if FBrowser <> nil then
    FBrowser.GoBack;
end;

procedure TCefBehavior.GoForward;
begin
  if FBrowser <> nil then
    FBrowser.GoForward;
end;

procedure TCefBehavior.OnAttached(const he: IDomElement);
var
  info: TCefWindowInfo;
  rect: TRect;
  settings: TCefBrowserSettings;
begin
  InitCef;
  
  FUrl := he.Attributes['src'];
  if FUrl = '' then
    FUrl := he.Attributes['value'];

  FClient := TCustomClient.Create(Self);
  GetClientRect(he.GetElementHwnd, rect);
  FillChar(info, SizeOf(info), 0);
  info.Style := WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_TABSTOP;
  info.parent_window := he.GetElementHwnd;
  info.x := rect.left;
  info.y := rect.top;
  info.Width := rect.right - rect.left;
  info.Height := rect.bottom - rect.top;
  FillChar(settings, sizeof(settings), 0);
  settings.size := SizeOf(settings);
  CefBrowserHostCreateSync(@info, FClient, FUrl, @settings, nil);
  Assert(FBrowser <> nil);

  he.AttachHwnd(FBrowser.Host.WindowHandle);
end;

procedure TCefBehavior.OnDetached(const he: IDomElement);
begin
//  if FBrowser <> nil then
//    FBrowser.StopLoad;
//  if FClient <> nil then
//    (FClient as ICefClientHandler).Disconnect;
  FClient := nil;
  FBrowser := nil;
  FBrowserId := 0;
end;

function TCefBehavior.OnFocus(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then Exit;
  if FBrowser = nil then Exit;
  case event_type of
    FOCUS_GOT:
      PostMessage(FBrowser.Host.WindowHandle, WM_SETFOCUS, 0, 0);
  end;
end;

procedure TCefBehavior.OnSize(const he: IDomElement);
var
  rect: TRect;
  hdwp: THandle;
begin
  if (FBrowser = nil) or (FBrowser.Host.WindowHandle = INVALID_HANDLE_VALUE) then Exit;
  // Resize the browser window and address bar to match the new frame window size
  rect := he.GetLocation(ROOT_RELATIVE);
  hdwp := BeginDeferWindowPos(1);
  hdwp := DeferWindowPos(hdwp, FBrowser.Host.WindowHandle, 0, rect.left, rect.top,
    rect.right - rect.left, rect.bottom - rect.top, SWP_NOZORDER);
  EndDeferWindowPos(hdwp);
end;

function TCefBehavior.OnSubscription(const he: IDomElement; var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_FOCUS or HANDLE_SIZE;
  Result := True;
end;

procedure TCefBehavior.Refresh;
begin
  if FBrowser <> nil then
    FBrowser.Reload;
end;

procedure TCefBehavior.SetUrl(const Value: WideString);
begin
  FUrl := Value;
end;

procedure TCefBehavior.Stop;
begin
  if FBrowser <> nil then
    FBrowser.StopLoad;
end;

{ TCustomClient }

var
  CefInstances: Integer = 0;
  CefTimer: UINT = 0;
  looping: Boolean = False;
procedure TimerProc(hwnd: HWND; uMsg: UINT; idEvent: Pointer; dwTime: DWORD); stdcall;
begin
  if looping then Exit;
  if CefInstances <= 0 then Exit;
  looping := True;
  try
    CefDoMessageLoopWork;
  finally
    looping := False;
  end;
end;

constructor TCustomClient.Create(const ABehavior: TCefBehavior);
begin
  inherited Create();
  FBehavior := ABehavior;
  FLifeSpan := TCustomLifeSpan.Create(FBehavior);
  FLoad := TCustomLoad.Create(FBehavior);
  if not UseMyRunAppclition then
  begin
    if CefInstances = 0 then
      CefTimer := SetTimer(0, 0, 10, @TimerProc);
    InterlockedIncrement(CefInstances);
  end;
end;

destructor TCustomClient.Destroy;
begin
  Disconnect;
  inherited;
  if not UseMyRunAppclition then
  begin
    if CefInstances > 0 then
    begin
      InterlockedDecrement(CefInstances);
      if CefInstances = 0 then
      begin
        KillTimer(0, CefTimer);
        CefTimer := 0;
      end;
    end;
  end;
end;

procedure TCustomClient.Disconnect;
begin
  FLoad := nil;
  FLifeSpan := nil;
  if FBehavior <> nil then
    FBehavior.FClient := nil;
  FBehavior := nil;
end;

function TCustomClient.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := FLifeSpan;
end;

function TCustomClient.GetLoadHandler: ICefLoadHandler;
begin
  Result := FLoad;
end;

{ TCustomLifeSpan }

constructor TCustomLifeSpan.Create(const ABehavior: TCefBehavior);
begin
  inherited Create;
  FBehavior := ABehavior;
end;

procedure TCustomLifeSpan.OnAfterCreated(const browser: ICefBrowser);
begin
  if not browser.IsPopup then
  begin
    // get the first browser
    FBehavior.FBrowser := browser;
    FBehavior.FBrowserId := browser.Identifier;
  end;
end;

procedure TCustomLifeSpan.OnBeforeClose(const browser: ICefBrowser);
begin
  if FBehavior = nil then Exit;
  if browser.Identifier = FBehavior.FBrowserId then
  with FBehavior do
  begin
    FBrowser := nil;
    FBrowserId := 0;
  end;
end;

{ TCustomLoad }

constructor TCustomLoad.Create(const ABehavior: TCefBehavior);
begin
  inherited Create();
  FBehavior := ABehavior;
end;

initialization
  if (not IsLibrary) and InitCef and SciterEnabled then
  begin
    Sciter.OnRunAppclition := SciterCefRunAppclition;
    BehaviorFactorys.Reg(TBehaviorFactory.Create('cef', TCefBehavior));
  end;

finalization
  if CefTimer <> 0 then
  begin
    KillTimer(0, CefTimer);
    CefTimer := 0;
  end;

end.
