unit Behavior.Wke;

interface

uses
  Windows, SysUtils, Messages, SciterIntf, SciterTypes, SciterBehavior,
  WkeIntf, WkeTypes, Imm, SciterVideoIntf;

type
  TWkeStreamBehavior = class;

  TWkeWebViewBase = class(TInterfacedObject, IWkeWebBase)
  private
    FOwner: TWkeStreamBehavior;
  public
    constructor Create(const AOwner: TWkeStreamBehavior);

    function GetWindowName: WideString;
    function GetHwnd: HWND;
    function GetResourceInstance: THandle;
    function GetBoundsRect: TRect;
    function GetDrawRect: TRect;
    function GetDrawDC: HDC;
    procedure ReleaseDC(const ADC: HDC);
  end;

  TWkeStreamBehavior = class(TBehaviorEventHandler)
  private
    rendering_site: IVideoDestination;
    FWebViewBase: IWkeWebBase;
    FWebView: IWkeWebView;
    FSizeChanged: Boolean;
    FImc: HIMC;
    FMouseEnter: Boolean;
  protected
    procedure DoWkeInvalidate(const AWebView: IWkeWebView; var bHandled: Boolean);
    procedure DoLoadingFinish(const AWebView: IWkeWebView; const url: wkeString; result: wkeLoadingResult; const failedReason: wkeString);
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;

    function  OnFocusGot(const he, target: IDomElement; event_type: UINT; var params: TFocusParams): Boolean; override;
    function  OnFocusLost(const he, target: IDomElement; event_type: UINT; var params: TFocusParams): Boolean; override;

    function  OnMouse(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseLeave(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseWheel(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;

    function  OnKeyDown(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; override;
    function  OnKeyUp(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; override;
    function  OnKeyChar(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; override;

    procedure OnSize(const he: IDomElement); override;
    function  OnVideoBindRQ(const he, target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean; override;

    function DoBeforeWndProc(msg: UINT;
      wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT; override;
  public
    constructor Create(const he: IDomElement); override; 
    destructor Destroy; override;
  published
    function Go(const AUrl: WideString): Boolean;
  end;


implementation

function CursorWkeToSciter(AType: wkeCursorType): TCursorType;
begin
  case AType of
    WKE_CURSOR_POINTER:
      Result := CURSOR_ARROW;
    WKE_CURSOR_CROSS:
      Result := CURSOR_CROSS;
    WKE_CURSOR_HAND:
      Result := CURSOR_HAND;
    WKE_CURSOR_IBEAM:
      Result := CURSOR_IBEAM;
    WKE_CURSOR_WAIT:
      Result := CURSOR_WAIT;
    WKE_CURSOR_HELP:
      Result := CURSOR_HELP;
    WKE_CURSOR_NORTHSOUTHRESIZE:
      Result := CURSOR_SIZENS;
    WKE_CURSOR_EASTWESTRESIZE:
      Result := CURSOR_SIZEWE;
    WKE_CURSOR_NORTHEASTSOUTHWESTRESIZE:
      Result := CURSOR_SIZENESW;
    WKE_CURSOR_NORTHWESTSOUTHEASTRESIZE:
      Result := CURSOR_SIZENWSE;
    WKE_CURSOR_MOVE:
      Result := CURSOR_DRAG_MOVE;
    WKE_CURSOR_NODROP:
      Result := CURSOR_NO;
    WKE_CURSOR_COPY:
      Result := CURSOR_DRAG_COPY;
    WKE_CURSOR_NOTALLOWED:
      Result := CURSOR_NO;
  else
    Result := CURSOR_NONE;
  end;
end;


{ TWkeWebViewBase }

constructor TWkeWebViewBase.Create(const AOwner: TWkeStreamBehavior);
begin
  FOwner := AOwner;
end;

function TWkeWebViewBase.GetBoundsRect: TRect;
begin
  Result := FOwner.This.GetLocation(VIEW_RELATIVE or BORDER_BOX);
end;

function TWkeWebViewBase.GetDrawDC: HDC;
begin
  Result := 0;
end;

function TWkeWebViewBase.GetDrawRect: TRect;
begin
  Result := FOwner.This.GetLocation(SELF_RELATIVE or CONTENT_BOX);
end;

function TWkeWebViewBase.GetHwnd: HWND;
begin
  Result := FOwner.This.GetElementHwnd();
end;

function TWkeWebViewBase.GetResourceInstance: THandle;
begin
  Result := SysInit.HInstance;
end;

function TWkeWebViewBase.GetWindowName: WideString;
begin
  Result := FOwner.This.Attributes['name'];
end;

procedure TWkeWebViewBase.ReleaseDC(const ADC: HDC);
begin

end;

{ TWkeStreamBehavior }

constructor TWkeStreamBehavior.Create(const he: IDomElement);
begin
  inherited;
end;

destructor TWkeStreamBehavior.Destroy;
begin
  inherited;
end;

function TWkeStreamBehavior.DoBeforeWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var pbHandled: Boolean): LRESULT;
begin
  Result := 0;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  try
    pbHandled := False;
    if FWebView.IsFocused  then
      case msg of
        WM_IME_SETCONTEXT:
        begin
          if wParam = 1 then
            ImmAssociateContext(FWebViewBase.GetHwnd, FImc)
          else
            ImmAssociateContext(FWebViewBase.GetHwnd, 0);
          Result := 0;
          pbHandled := True;
        end;
        WM_IME_COMPOSITION,
        WM_IME_STARTCOMPOSITION,
        WM_IME_ENDCOMPOSITION:
          Result := FWebView.ProcND(msg, WParam, LParam, pbHandled);
        WM_CHAR,
        WM_SYSCHAR:
        begin
          Result := FWebView.ProcND(msg, WParam, LParam, pbHandled);
        end;
      end;
    if FMouseEnter then
    begin
      case msg of
        WM_SETCURSOR:
        begin
          Result := FWebView.ProcND(msg, WParam, LParam, pbHandled);
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      Sciter.Trace('[TWkeStreamBehavior.DoBeforeWndProc]'+E.Message);
    end
  end;
end;

procedure TWkeStreamBehavior.DoLoadingFinish(const AWebView: IWkeWebView;
  const url: wkeString; result: wkeLoadingResult;
  const failedReason: wkeString);
var
  bHandled: Boolean;
begin
  DoWkeInvalidate(FWebView, bHandled);
end;

procedure TWkeStreamBehavior.DoWkeInvalidate(const AWebView: IWkeWebView;
  var bHandled: Boolean);
var
  p: Pointer;
  w, h: Integer;
begin
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;

  w := FWebView.Width;
  h := FWebView.Height;
  if (w = 0) or (h = 0) then
    Exit;

  if FSizeChanged then
  begin
    if rendering_site.IsAlive then
      rendering_site.StopStreaming;

    rendering_site.StartStreaming(w, h, COLOR_SPACE_RGB32);
    FSizeChanged := False;
  end;

  if not FWebView.IsDirty then
    Exit;

  GetMem(p, h * w * 4);
  try
    FWebView.Paint(p, 0);
    rendering_site.RenderFrame(p, h * w * 4);
  finally
    FreeMem(p);
  end;
end;

function TWkeStreamBehavior.Go(const AUrl: WideString): Boolean;
var
  sFile: WideString;
begin
  Result := False;
  try
    if rendering_site = nil then
      Exit;
    if FWebView = nil then
      Exit;
    if AUrl = '' then
      Exit;

    if (rendering_site <> nil) then
    begin
      rendering_site.StopStreaming();
    end;
    
    if Pos(WideString('http:'), AUrl) = 1 then
      FWebView.LoadURL(AUrl)
    else
    if Pos(WideString('https:'), AUrl) = 1 then
      FWebView.LoadURL(AUrl)
    else
    if Pos(WideString('file:'), AUrl) = 1 then
    begin
      FWebView.LoadFile(sFile);
    end
    else
    begin
      sFile := Layout.BaseUri + AUrl;
      FWebView.LoadFile(sFile);
    end;
      
    Result := True;
  except
    on E: Exception do
    begin
      Sciter.Trace('[TWkeStreamBehavior.Go]'+E.Message);
    end;
  end;
end;

procedure TWkeStreamBehavior.OnAttached(const he: IDomElement);
var
  sUrl, sBehavior: SciterString;
begin
  inherited;
  FWebViewBase := TWkeWebViewBase.Create(Self);
  FWebView := Wke.CreateWebView(FWebViewBase);
  FWebView.Transparent := (he.Style['background-color'] = 'transparent')
    or (Pos(SciterString('transparent'), he.Style['background'])>0);
  FWebView.OnInvalidate := DoWkeInvalidate;
  FWebView.OnLoadingFinish := DoLoadingFinish;
  FWebView.HostWindow := he.GetElementHwnd();

  FImc := ImmCreateContext;

  sBehavior := he.Style['behavior'];
  if Pos(SciterString('video'), sBehavior) = 0 then
  begin
    sBehavior :=  sBehavior + ' video';
    he.Style['behavior'] := sBehavior;
  end;
  if he.Style['image-rendering'] = '' then
    he.Style['image-rendering'] := 'optimize-speed';

  AddBeforeWndProc;
  
  sUrl := he.Attributes['url'];
  Go(sUrl);
end;

procedure TWkeStreamBehavior.OnDetached(const he: IDomElement);
begin
  if (rendering_site <> nil) then
  begin
    rendering_site.StopStreaming();
    rendering_site := nil;
  end;

  if FImc <> 0 then
  begin
    ImmDestroyContext(FImc);
    FImc := 0;
  end;
  if FWebView <> nil then
  begin
    FWebView.StopLoading;
    FWebView.HostWindow := 0;
    FWebView.OnInvalidate := nil;
    FWebView.OnLoadingFinish := nil;
  end;
  FWebView := nil;
  FWebViewBase := nil;

  RemoveBeforeWndProc;

  inherited;
end;

function TWkeStreamBehavior.OnFocusGot(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;

  FWebView.SetFocus;

  //绑定输入法窗口
  SendMessage(FWebViewBase.GetHwnd, WM_IME_SETCONTEXT, 1, Integer(ISC_SHOWUIALL));
  
  Result := True;
end;

function TWkeStreamBehavior.OnFocusLost(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
    
  FWebView.KillFocus;
  Result := True;
end;

function TWkeStreamBehavior.OnKeyChar(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
var
  flags: UINT;
begin
  Result := False;
  Exit; //这个消息总会将小写字母变成大写
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;

  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
  begin
    flags := flags or WKE_CONTROL;
    //Exit;
  end;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;
  
  OutputDebugString(PChar(IntToStr(params.key_code)));
  Result := FWebView.KeyPress(params.key_code, flags, False)
end;

function TWkeStreamBehavior.OnKeyDown(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
var
  flags: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;

  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;
  Result := FWebView.KeyDown(params.key_code, flags, (params.alt_state and ALT_KEY_PRESSED)<>0)
end;

function TWkeStreamBehavior.OnKeyUp(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
var
  flags: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;

  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;

  Result := FWebView.KeyUp(params.key_code, flags, (params.alt_state and ALT_KEY_PRESSED)<>0)
end;

function TWkeStreamBehavior.OnMouse(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;
  params.cursor_type := CursorWkeToSciter(FWebView.CursorType);
  Result := True;
end;

function TWkeStreamBehavior.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  flags, Msg: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;
  
  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;

  Msg := 0;
  if params.button_state and MAIN_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_LBUTTON;
    Msg := WM_LBUTTONDBLCLK;
  end;
  if params.button_state and MIDDLE_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_MBUTTON;
    Msg := WM_MBUTTONDBLCLK;
  end;
  if params.button_state and PROP_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_RBUTTON;
    Msg := WM_RBUTTONDBLCLK;
  end;

  if Msg = 0 then
    Exit;

  FWebView.MouseEvent(Msg, params.pos.X, params.pos.Y, flags);
end;                 
               
function TWkeStreamBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  flags, Msg: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;

  if not target.TestState(STATE_FOCUS) then
    target.ChangeState(STATE_FOCUS, False);
  SetCapture(he.GetElementHwnd());

  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;

  Msg := 0;
  if params.button_state and MAIN_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_LBUTTON;
    Msg := WM_LBUTTONDOWN;
  end;
  if params.button_state and MIDDLE_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_MBUTTON;
    Msg := WM_MBUTTONDOWN;
  end;
  if params.button_state and PROP_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_RBUTTON;
    Msg := WM_RBUTTONDOWN;
  end;
  if Msg = 0 then
    Exit;

  Result := FWebView.MouseEvent(Msg, params.pos.X, params.pos.Y, flags);
  if Msg = WM_LBUTTONDOWN then
    Result := False;
end;

function TWkeStreamBehavior.OnMouseEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;
  
  FMouseEnter := True;
end;

function TWkeStreamBehavior.OnMouseLeave(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;
  FMouseEnter := False;
  FWebView.KillFocus;
  Result := True;
end;

function TWkeStreamBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  flags: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;

  if not FWebView.IsFocused then
    FWebView.SetFocus;

  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;

  if params.button_state and MAIN_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_LBUTTON;
  end;
  if params.button_state and MIDDLE_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_MBUTTON;
  end;
  if params.button_state and PROP_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_RBUTTON;
  end;

  FWebView.MouseEvent(WM_MOUSEMOVE, params.pos.X, params.pos.Y, flags);
end;

function TWkeStreamBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  flags, Msg: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;
  ReleaseCapture;
  
  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;

  Msg := 0;
  if params.button_state and MAIN_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_LBUTTON;
    Msg := WM_LBUTTONUP;
  end;
  if params.button_state and MIDDLE_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_MBUTTON;
    Msg := WM_MBUTTONUP;
  end;
  if params.button_state and PROP_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_RBUTTON;
    Msg := WM_RBUTTONUP;
  end;

  if Msg = 0 then
    Exit;
  FWebView.MouseEvent(Msg, params.pos.X, params.pos.Y, flags);
end;

function TWkeStreamBehavior.OnMouseWheel(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  flags: UINT;
begin
  Result := False;
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;
  if not IsBubbling(event_type) then
    Exit;
    
  flags := 0;
  if params.alt_state and CONTROL_KEY_PRESSED <> 0 then
    flags := flags or WKE_CONTROL;
  if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
    flags := flags or WKE_SHIFT;

  if params.button_state and MAIN_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_LBUTTON;
  end;
  if params.button_state and MIDDLE_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_MBUTTON;
  end;
  if params.button_state and PROP_MOUSE_BUTTON <> 0 then
  begin
    flags := flags or WKE_RBUTTON;
  end;
  FWebView.MouseWheel(params.pos.X, params.pos.Y, ShortInt(params.button_state) * 100, flags);
end;

procedure TWkeStreamBehavior.OnSize(const he: IDomElement);
begin
  if rendering_site = nil then
    Exit;
  if FWebView = nil then
    Exit;

  FSizeChanged := True;
  FWebView.Resize(he.Width, he.Height);
end;

function TWkeStreamBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_ALL; // HANDLE_MOUSE or HANDLE_KEY or HANDLE_FOCUS or HANDLE_SIZE or HANDLE_BEHAVIOR_EVENT; // we only handle VIDEO_BIND_RQ here
  Result := True;
end;

function TWkeStreamBehavior.OnVideoBindRQ(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  Result := False;
  if _type <> VIDEO_BIND_RQ then
    Exit;
    
  // we handle only VIDEO_BIND_RQ requests here
  if params.reason = 0 then
  begin
    Result := True; // first phase, consume the event to mark as we will provide frames 
    Exit;
  end;

  if rendering_site <> nil then
  begin
    rendering_site.StopStreaming();
  end;
    
  rendering_site := CreateVideoDestination(Pointer(params.reason));
  
  Result := True;
end;

end.
