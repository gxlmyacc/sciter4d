unit Behavior.Cef;

interface

uses
  SysUtils, Windows, ActiveX, SciterTypes, SciterIntf, SciterBehavior, ceflib,
  TiscriptIntf, Messages, SciterGraphicIntf, Imm;

const
  SCITER_CEF_WINDOW_CLASS_NAME = 'SciterCefWindow-A24989B52E78';

type
  TCefBehavior = class;
  
  TCustomClient = class(TCefClientOwn)
  private
    FBehavior: TCefBehavior;
    FLifeSpan: ICefLifeSpanHandler;
    FCefRender: ICefRenderHandler;
  protected
    function GetLifeSpanHandler: ICefLifeSpanHandler; override;
    function GetRenderHandler: ICefRenderHandler; override;
  public
    constructor Create(const ABehavior: TCefBehavior); reintroduce;
    destructor Destroy; override;
  end;

  TCustomCefRender = class(TCefRenderHandlerOwn)
  private
    FBehavior: TCefBehavior;
  protected
    function GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean; override;
    function GetViewRect(const browser: ICefBrowser; rect: PCefRect): Boolean; override;
    function GetScreenPoint(const browser: ICefBrowser; viewX, viewY: Integer;
      screenX, screenY: PInteger): Boolean; override;
    function GetScreenInfo(const browser: ICefBrowser; screenInfo: PCefScreenInfo): Boolean; override;
    procedure OnPaint(const browser: ICefBrowser; kind: TCefPaintElementType;
      dirtyRectsCount: NativeUInt; const dirtyRects: PCefRectArray;
      const buffer: Pointer; width, height: Integer); override;
    procedure OnCursorChange(const browser: ICefBrowser; cursor: TCefCursorHandle;
      CursorType: TCefCursorType; const customCursorInfo: PCefCursorInfo); override;
  public
    constructor Create(const ABehavior: TCefBehavior); reintroduce;
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
  
  TCefBehavior = class(TBehaviorEventHandler)
  private
    FImc: HIMC;
    FHe: IDomElement;
    FClient: ICefClient;
    FBrowser: ICefBrowser;
    FBrowserId: Integer;
    FUrl: WideString;
    FFocused: Boolean;
    FDIB: ISciterDIB32;
    procedure SetUrl(const Value: WideString);
  protected
    function DoBeforeWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT; override;

    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnKey(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; override;
    function  OnMouse(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnFocus(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
    function  OnDraw(const he: IDomElement; draw_type: UINT{DRAW_EVENTS}; var params: TDrawParams): Boolean; override;
  public
    procedure Config(const AOptions: ITiscriptObject);
    
    function  CanGoBack: Boolean;
    function  CanGoForward: Boolean;
    procedure GoBack();
    procedure GoForward();
    
    procedure Go(const Url: WideString);

    procedure Refresh();
    procedure Stop();
        
    property Url: WideString read FUrl write SetUrl;
  end;

implementation

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

function TCefBehavior.DoBeforeWndProc(msg: UINT; wParam: WPARAM;
  lParam: LPARAM; var pbHandled: Boolean): LRESULT;
var
  event: TCefKeyEvent;
begin
  Result := 0;
  if FHe = nil then Exit;
  //if FFocused then
  FillChar(event, SizeOf(TCefKeyEvent), 0);
  case msg of
    WM_IME_SETCONTEXT:
    begin
      if wParam = 1 then
        ImmAssociateContext(FHe.GetElementHwnd, FImc)
      else
        ImmAssociateContext(FHe.GetElementHwnd, 0);
      Result := 0;
      pbHandled := True;
    end;
    WM_KEYDOWN:  event.kind := KEYEVENT_KEYDOWN;
    WM_KEYUP:    event.kind := KEYEVENT_KEYUP;
    WM_CHAR,
      WM_SYSCHAR: event.kind := KEYEVENT_CHAR;
  else
    Exit;
  end;
  event.windows_key_code := wParam;
  event.native_key_code := lParam;
  if msg = WM_SYSCHAR then
    event.is_system_key := 1;
  FBrowser.Host.SendKeyEvent(@event);
  Result := S_OK;
end;

procedure TCefBehavior.Go(const Url: WideString);
begin
  FUrl := FHe.CombineURL(Url);
  if FUrl = '' then
    FUrl := 'about:blank';
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
  setting: TCefBrowserSettings;
  FUrl: WideString;
begin
  FHe := he;
  FImc := ImmCreateContext;
  
  AddBeforeWndProc;

  FUrl := he.Attributes['src'];
  if FUrl = '' then
    FUrl := he.Attributes['value'];
  if FUrl = '' then
    FUrl := 'about:blank';
  he.Style['behavior'] := '~focusable ' + he.Style['behavior'];

  FFocused := he.State and STATE_FOCUS <> 0;

  FClient := TCustomClient.Create(Self);
  FillChar(info, SizeOf(info), 0);
  info.windowless_rendering_enabled := Ord(True);
  info.transparent_painting_enabled := Ord(True);
  FillChar(setting, sizeof(setting), 0);
  setting.size := SizeOf(setting);
  CefBrowserHostCreateSync(@info, FClient, FUrl, @setting, nil);
end;

procedure TCefBehavior.OnDetached(const he: IDomElement);
begin
  FBrowser := nil;
  FBrowserId := 0;
  RemoveBeforeWndProc;

  if FImc <> 0 then
  begin
    ImmDestroyContext(FImc);
    FImc := 0;
  end;
end;

function TCefBehavior.OnDraw(const he: IDomElement; draw_type: UINT;
  var params: TDrawParams): Boolean;
var
  img: ISciterImage;
  gfx: ISciterGraphic;
begin
  if (draw_type <> DRAW_CONTENT) or (FDIB = nil) then   // drawing only content layer
  begin
    Result := False;
    Exit;
  end;
  img := CreateImageFromPixmap(FDIB.Width, FDIB.Height, True, FDIB.Bytes);
  gfx := CreateGraphic(params.gfx);
  gfx.DrawImage(img.Handle, params.area.Left, params.area.Top);

  Result := True;
end;

function TCefBehavior.OnFocus(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  case event_type of
    FOCUS_GOT:
    begin
      FFocused := True;
      FBrowser.Host.SendFocusEvent(True);
    end;
    FOCUS_LOST:
    begin
      FFocused := False;
      FBrowser.Host.SendFocusEvent(False);
    end;
  end;
end;

function TCefBehavior.OnKey(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
  function getModifiers(const params: TKeyParams): TCefEventFlags;
  begin
    Result := [];
    if SHIFT_KEY_PRESSED and params.alt_state <> 0 then Include(Result, EVENTFLAG_SHIFT_DOWN);
    if ALT_KEY_PRESSED and params.alt_state <> 0 then Include(Result, EVENTFLAG_ALT_DOWN);
    if CONTROL_KEY_PRESSED and params.alt_state <> 0 then Include(Result, EVENTFLAG_CONTROL_DOWN)
  end;
var
  event: TCefKeyEvent;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  case event_type of
    KEY_DOWN, KEY_UP:
    begin
      FillChar(event, SizeOf(TCefKeyEvent), 0);
      if event_type = KEY_DOWN then
        event.kind := KEYEVENT_KEYDOWN
      else
        event.kind := KEYEVENT_KEYUP;
      event.modifiers := getModifiers(params);
      //event.windows_key_code := params.key_code;
      event.native_key_code := params.key_code;
      FBrowser.Host.SendKeyEvent(@event);
      Result := True;
    end;
    KEY_CHAR:
    begin
      FillChar(event, SizeOf(TCefKeyEvent), 0);
      event.kind := KEYEVENT_CHAR;
      event.modifiers := getModifiers(params);
      //event.windows_key_code := params.key_code;
      event.native_key_code := params.key_code;
      FBrowser.Host.SendKeyEvent(@event);
      Result := True;    
    end;
  end;
end;

function TCefBehavior.OnMouse(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
  function getModifiers(const params: TMouseParams): TCefEventFlags;
  begin
    Result := [];
    if SHIFT_KEY_PRESSED and params.alt_state <> 0 then Include(Result, EVENTFLAG_SHIFT_DOWN);
    if ALT_KEY_PRESSED and params.alt_state <> 0 then Include(Result, EVENTFLAG_ALT_DOWN);
    if CONTROL_KEY_PRESSED and params.alt_state <> 0 then Include(Result, EVENTFLAG_CONTROL_DOWN);
    if MAIN_MOUSE_BUTTON and params.button_state <> 0 then Include(Result, EVENTFLAG_LEFT_MOUSE_BUTTON);
    if PROP_MOUSE_BUTTON and params.button_state <> 0 then Include(Result, EVENTFLAG_RIGHT_MOUSE_BUTTON);
    if MIDDLE_MOUSE_BUTTON and params.button_state <> 0 then Include(Result, EVENTFLAG_MIDDLE_MOUSE_BUTTON);
  end;
  function GetButton(const params: TMouseParams): TCefMouseButtonType;
  begin
    Result := MBT_LEFT;
    if PROP_MOUSE_BUTTON and params.button_state <> 0 then Result := MBT_RIGHT;
    if MIDDLE_MOUSE_BUTTON and params.button_state <> 0 then Result := MBT_MIDDLE;
  end;
var      
  event: TCefMouseEvent;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  case event_type of
    MOUSE_DOWN, MOUSE_UP:
    begin
      event.x := params.pos.X;
      event.y := params.pos.Y;
      event.modifiers := getModifiers(params);
      FBrowser.Host.SendMouseClickEvent(@event, GetButton(params), event_type = MOUSE_UP, 1);
      Result := True;
    end;
    MOUSE_MOVE, MOUSE_ENTER, MOUSE_LEAVE:
    begin
      event.x := params.pos.X;
      event.y := params.pos.Y;
      event.modifiers := getModifiers(params);
      FBrowser.Host.SendMouseMoveEvent(@event, event_type = MOUSE_LEAVE);
    end;
    MOUSE_WHEEL:
    begin
      event.x := params.pos_view.X;
      event.y := params.pos_view.Y;
      event.modifiers := getModifiers(params);
      FBrowser.Host.SendMouseWheelEvent(@event, 0, ShortInt(params.button_state) * 100);
    end;
  end;
end;

procedure TCefBehavior.OnSize(const he: IDomElement);
begin
  if FBrowser = nil then Exit;
  FBrowser.Host.WasResized;
  FBrowser.Host.SendFocusEvent(True);
end;

function TCefBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_MOUSE or HANDLE_SIZE or HANDLE_FOCUS or HANDLE_DRAW;
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
  if CefInstances > 0 then
  begin
    looping := True;
    try
      CefDoMessageLoopWork;
    finally
      looping := False;
    end;
  end;
end;

constructor TCustomClient.Create(const ABehavior: TCefBehavior);
begin
  inherited Create();
  FBehavior := ABehavior;
  FLifeSpan := TCustomLifeSpan.Create(FBehavior);
  FCefRender := TCustomCefRender.Create(FBehavior);
  
  if CefInstances = 0 then
    CefTimer := SetTimer(0, 0, 10, @TimerProc);
  InterlockedIncrement(CefInstances);
end;

destructor TCustomClient.Destroy;
begin
  InterlockedDecrement(CefInstances);
  if CefInstances = 0 then
    KillTimer(0, CefTimer);
  FLifeSpan := nil;
  FCefRender := nil;
  inherited;
end;

function TCustomClient.GetLifeSpanHandler: ICefLifeSpanHandler;
begin
  Result := FLifeSpan;
end;

function TCustomClient.GetRenderHandler: ICefRenderHandler;
begin
  Result := FCefRender;
end;

{ TCustomLifeSpan }

constructor TCustomLifeSpan.Create(const ABehavior: TCefBehavior);
begin
  inherited Create;
  FBehavior := ABehavior;
end;

procedure TCustomLifeSpan.OnAfterCreated(const browser: ICefBrowser);
begin
  if (FBehavior.FBrowser = nil) and (not browser.IsPopup) then
  begin
    // get the first browser
    FBehavior.FBrowser := browser;
    FBehavior.FBrowserId := browser.Identifier;
  end;
end;

procedure TCustomLifeSpan.OnBeforeClose(const browser: ICefBrowser);
begin
  if browser.Identifier = FBehavior.FBrowserId then
    FBehavior.FBrowser := nil;
end;

{ TCustomCefRender }

constructor TCustomCefRender.Create(const ABehavior: TCefBehavior);
begin
  inherited Create();
  FBehavior := ABehavior;
end;

function TCustomCefRender.GetRootScreenRect(const browser: ICefBrowser; rect: PCefRect): Boolean;
var
  rc: TRect;
begin
  rc := FBehavior.FHe.GetLocation(VIEW_RELATIVE);
  rect.x := rc.Left;
  rect.y := rc.Top;
  rect.width := rc.Right-rc.Left;
  rect.height := rc.Bottom-rc.Top;
  Result := True;
end;

function TCustomCefRender.GetScreenInfo(const browser: ICefBrowser;
  screenInfo: PCefScreenInfo): Boolean;
var
  rcWorkAreaRect: TRect;
begin
  with screenInfo^ do
  begin
    device_scale_factor := 1.0;
    depth := 32;
    depth_per_component := 8;
    is_monochrome := 0;

    rect.x := 0;
    rect.y := 0;
    rect.width := GetSystemMetrics(SM_CXSCREEN);
    rect.height := GetSystemMetrics(SM_CYSCREEN);
    
    SystemParametersInfo(SPI_GETWORKAREA, 0, @rcWorkAreaRect, 0);
    available_rect.x := rcWorkAreaRect.Left;
    available_rect.y := rcWorkAreaRect.Top;
    available_rect.width := rcWorkAreaRect.Right-rcWorkAreaRect.Left;
    available_rect.height := rcWorkAreaRect.Bottom - rcWorkAreaRect.Top;
  end;
  Result := True;
end;

function TCustomCefRender.GetScreenPoint(const browser: ICefBrowser; viewX,
  viewY: Integer; screenX, screenY: PInteger): Boolean;
var
  rc: TRect;
begin
  GetWindowRect(FBehavior.FHe.GetElementHwnd, rc);
  screenX^ := viewX + rc.Left;
  screenY^ := viewY + rc.Top;
  Result := True;
end;

function TCustomCefRender.GetViewRect(const browser: ICefBrowser;
  rect: PCefRect): Boolean;
var
  rc: TRect;
begin
  rc := FBehavior.FHe.GetLocation(VIEW_RELATIVE);
  rect.x := rc.Left;
  rect.y := rc.Top;
  rect.width := rc.Right-rc.Left;
  rect.height := rc.Bottom-rc.Top;
  Result := True;
end;

procedure TCustomCefRender.OnCursorChange(const browser: ICefBrowser;
  cursor: TCefCursorHandle; CursorType: TCefCursorType;
  const customCursorInfo: PCefCursorInfo);
begin
//  case cursorType of
//    CT_POINTER: PaintBox.Cursor := crArrow;
//    CT_CROSS: PaintBox.Cursor:= crCross;
//    CT_HAND: PaintBox.Cursor := crHandPoint;
//    CT_IBEAM: PaintBox.Cursor := crIBeam;
//    CT_WAIT: PaintBox.Cursor := crHourGlass;
//    CT_HELP: PaintBox.Cursor := crHelp;
//    CT_EASTRESIZE: PaintBox.Cursor := crSizeWE;
//    CT_NORTHRESIZE: PaintBox.Cursor := crSizeNS;
//    CT_NORTHEASTRESIZE: PaintBox.Cursor:= crSizeNESW;
//    CT_NORTHWESTRESIZE: PaintBox.Cursor:= crSizeNWSE;
//    CT_SOUTHRESIZE: PaintBox.Cursor:= crSizeNS;
//    CT_SOUTHEASTRESIZE: PaintBox.Cursor:= crSizeNWSE;
//    CT_SOUTHWESTRESIZE: PaintBox.Cursor:= crSizeNESW;
//    CT_WESTRESIZE: PaintBox.Cursor := crSizeWE;
//    CT_NORTHSOUTHRESIZE: PaintBox.Cursor:= crSizeNS;
//    CT_EASTWESTRESIZE: PaintBox.Cursor := crSizeWE;
//    CT_NORTHEASTSOUTHWESTRESIZE: PaintBox.Cursor:= crSizeNESW;
//    CT_NORTHWESTSOUTHEASTRESIZE: PaintBox.Cursor:= crSizeNWSE;
//    CT_COLUMNRESIZE: PaintBox.Cursor:= crHSplit;
//    CT_ROWRESIZE: PaintBox.Cursor:= crVSplit;
//    CT_MOVE: PaintBox.Cursor := crSizeAll;
//    CT_PROGRESS: PaintBox.Cursor := crAppStart;
//    CT_NODROP: PaintBox.Cursor:= crNo;
//    CT_NONE: PaintBox.Cursor:= crNone;
//    CT_NOTALLOWED: PaintBox.Cursor:= crNo;
//  else
//    PaintBox.Cursor := crArrow;
//  end;
end;

procedure TCustomCefRender.OnPaint(const browser: ICefBrowser;
  kind: TCefPaintElementType; dirtyRectsCount: NativeUInt;
  const dirtyRects: PCefRectArray; const buffer: Pointer; width, height: Integer);
var
  rc: TCefRect;
  src, dst: PAnsiChar;
  offset, i, j, w: Integer;
  LDIB: ISciterDIB32;
begin
  LDIB := FBehavior.FDIB;
  try
    if (LDIB = nil) or (LDIB.Width <> Cardinal(width)) or (LDIB.Height <> Cardinal(height)) then
      LDIB := CreateDIB32(width, height);
    w := Width * 4;
    for j := 0 to dirtyRectsCount - 1 do
    begin
      rc := dirtyRects[j];
      offset := ((rc.y * Width) + rc.x) * 4;
      src := @PAnsiChar(buffer)[offset];
      dst := @PAnsiChar(LDIB.Bits)[offset];
      offset := rc.width * 4;
      for i := 0 to rc.height - 1 do
      begin
        Move(src^, dst^, offset);
        Inc(dst, w);
        Inc(src, w);
      end;
    end;
  finally
    FBehavior.FDIB := LDIB;
  end;
  FBehavior.FHe.Update();
end;

end.
