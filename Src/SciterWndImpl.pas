{*******************************************************************************
 标题:     SciterWndImpl.pas
 描述:     sciter窗口接口的实现定义
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterWndImpl;

interface

uses
  Windows, Classes, SysUtils, SciterTypes, Messages, SciterIntf, SciterWndIntf, SciterLayout;

const
  GWLP_USERDATA            = -21;
  SCITER_WINDOW_CLASS_NAME = 'SciterWindow-6A3E08A1C6D4';	 // the main frame class name
  
type      
  TSciterWindow = class(TInterfacedObject, ISciterBase, ISciterWindow)
  private
    FFlags: TSciterCreateWindowFlags;
    FHwnd: HWINDOW;
    FInstance: HMODULE;
    FOnWndProc: TSciterWndProc;
    FIsShowing: Boolean;
    FIsModaling: Boolean;
    FDestroying: Boolean;
    FIsWindowDestroying: Boolean;
    FParentWnds: array of HWINDOW;
    FModalCode: Integer;
    FTag: Pointer;
    FLayout: ISciterLayout;
    FLayoutImpl: TSciterLayout;
    FOnClose: TSciterNotifyEvent;
    FOnCloseQuery: TSciterCloseQueryEvent;
    FOnCreate: TSciterNotifyEvent;
    FOnDestroy: TSciterNotifyEvent;
    FOnHide: TSciterNotifyEvent;
    FOnShow: TSciterNotifyEvent;
    FOnKeyDown: TSciterKeyDownEvent;
  protected
    function GetFlags: TSciterCreateWindowFlags;
    function GetLayout: PISciterLayout;
    function GetBehavior: IDefalutBehaviorEventHandler;
    function GetParent: HWINDOW;
    function GetCaption: SciterString;
    function GetLeft: Integer;
    function GetTop: Integer;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetBounds: TRect;
    function GetIsModaling: Boolean;
    function GetIsShowing: Boolean;
    function GetModalCode: Integer;
    function GetTag: Pointer;
    function GetOnWndProc: TSciterWndProc;
    function GetOnClose: TSciterNotifyEvent;
    function GetOnCloseQuery: TSciterCloseQueryEvent;
    function GetOnCreate: TSciterNotifyEvent;
    function GetOnDestroy: TSciterNotifyEvent;
    function GetOnHide: TSciterNotifyEvent;
    function GetOnShow: TSciterNotifyEvent;
    function GetOnKeyDown: TSciterKeyDownEvent;
    procedure SetBehavior(const Value: IDefalutBehaviorEventHandler);
    procedure SetParent(const Value: HWINDOW);
    procedure SetCaption(const Value: SciterString);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetBounds(const Value: TRect);
    procedure SetModalCode(const Value: Integer);
    procedure SetTag(const Value: Pointer);
    procedure SetOnWndProc(const Value: TSciterWndProc);
    procedure SetOnClose(const Value: TSciterNotifyEvent);
    procedure SetOnCloseQuery(const Value: TSciterCloseQueryEvent);
    procedure SetOnCreate(const Value: TSciterNotifyEvent);
    procedure SetOnDestroy(const Value: TSciterNotifyEvent);
    procedure SetOnHide(const Value: TSciterNotifyEvent);
    procedure SetOnShow(const Value: TSciterNotifyEvent);
    procedure SetOnKeyDown(const Value: TSciterKeyDownEvent);
  protected
    class function InitSciterClass: Boolean;
    class procedure FinalSciterClass;
    
    function WndProc(hwnd: HWINDOW; msg: UINT; wParam: WPARAM;
        lParam: LPARAM; var pHandled: Boolean): LRESULT;

    procedure DoEnableModalParent;

    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(AInstance: HMODULE; AFlags: TSciterCreateWindowFlags;
      frame: TRect; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil);
    destructor Destroy; override;

    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;

    function GetWindowName: SciterString; virtual;
    function GetHwnd: HWINDOW; virtual;
    function GetResourceInstance: HMODULE; virtual;

    procedure Close;

    procedure Show(nCmdShow: Integer = SW_SHOW; Update: Boolean = True; AddToList: Boolean = True);
    procedure Hide;

    function  ShowModal(nCmdShow: Integer = SW_SHOW): Integer;
    procedure EndModal(nCode: Integer);

    property Flags: TSciterCreateWindowFlags read GetFlags;
    property Layout: PISciterLayout read GetLayout;
    property Behavior: IDefalutBehaviorEventHandler read GetBehavior write SetBehavior;
    property Handle: HWINDOW read  GetHwnd;
    property Parent: HWINDOW read GetParent;
    property Caption: SciterString read GetCaption write SetCaption;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Bounds: TRect read GetBounds write SetBounds;
    property IsShowing: Boolean read GetIsShowing;
    property IsModaling: Boolean read GetIsModaling;
    property ModalCode: Integer read GetModalCode write SetModalCode;
    property OnWndProc: TSciterWndProc read GetOnWndProc write SetOnWndProc;
    property Tag: Pointer read GetTag write SetTag;
    
    property OnCreate: TSciterNotifyEvent read GetOnCreate write SetOnCreate;
    property OnDestroy: TSciterNotifyEvent read GetOnDestroy write SetOnDestroy;
    property OnClose: TSciterNotifyEvent read GetOnClose write SetOnClose;
    property OnShow: TSciterNotifyEvent read GetOnShow write SetOnShow;
    property OnHide: TSciterNotifyEvent read GetOnHide write SetOnHide;
    property OnKeyDown: TSciterKeyDownEvent read GetOnKeyDown write SetOnKeyDown;
  end;

  TSciterWindowList = class(TInterfacedObject, ISciterWindowList)
  private
    FList: IInterfaceList;
  private
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): ISciterWindow;
    function  GetItemByHandle(const AHandle: Cardinal): ISciterWindow;
  public
    constructor Create();
    destructor Destroy; override;

    function  Implementor: Pointer;
    
    function  Add(AWindow: ISciterWindow): Integer;
    procedure Delete(const AIndex: Integer); overload;
    procedure DeleteByHandle(const AHandle: Cardinal); overload;
    procedure Clear;

    function  IndexOf(const AHandle: Cardinal): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: ISciterWindow read GetItem; default;
    property ItemByHandle[const AHandle: Cardinal]: ISciterWindow read GetItemByHandle;
  end;

function _wnd_proc(hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;

function __SciterWindowList: PISciterWindowList;

implementation

uses
  SciterImpl, SciterApiImpl, SciterExportDefs, ShadowUtils;

var
  varWndCls: ATOM = 0;
  varLoadAttemptHasBeenMade: Boolean = False;
  varSciterWindowList: ISciterWindowList = nil;

function __SciterWindowList: PISciterWindowList;
begin
  if varSciterWindowList = nil then
    varSciterWindowList := TSciterWindowList.Create;
  Result := @varSciterWindowList;
end;

function _wnd_proc(hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  handled: Boolean;
  lr: LRESULT;
  LWnd: TSciterWindow;
begin
  //SCITER integration starts
  try
    handled := False;
    if msg = WM_CREATE then
    begin
      LWnd :=  TSciterWindow(PCreateStruct(lParam).lpCreateParams);
      SetWindowLongW(hWnd, GWLP_USERDATA, Integer(LWnd));
    end
    else
      LWnd := TSciterWindow(GetWindowLongW(hWnd, GWLP_USERDATA));
    if LWnd = nil then
    try
      Result := DefWindowProcW(hWnd, Msg, wParam, lParam);
      Exit;
    except
      on E: Exception do
        TraceException('[LWnd.WndProc][DefWindowProc]'+E.Message);
    end;
    lr := 0;
    try
      lr := LWnd.WndProc(hWnd, msg, wParam, lParam, handled);
    except
      on E: Exception do
         TraceException('[LWnd.WndProc]'+e.Message);
    end;
    if msg = WM_DESTROY then
    begin
      SetWindowLongW(hWnd, GWLP_USERDATA, 0);
      if (swMain in LWnd.FFlags) or (hWnd = SciterObject.MainWnd) then
      begin
        __SciterWindowList.Clear;
        SciterObject.Terminate;
      end;
    end;
    if handled then
    begin
      Result := lr;
      Exit;
    end;
  except
    on E: Exception do
      TraceException('[_wnd_proc]'+E.Message);
  end;
  //SCITER integration ends
  Result := DefWindowProcW(hWnd, Msg, wParam, lParam);
end;

{ TSciterWindow }

procedure TSciterWindow.Close;
begin
  if FHwnd = 0 then
    Exit;
  if not FIsWindowDestroying then
  begin
    if IsWindow(FHwnd) and FIsShowing then
      Hide;
    if (FHwnd <> 0) and IsWindow(FHwnd) then
    begin
      PostMessage(FHwnd, WM_CLOSE, 0, 0);
      // DestroyWindow(FHwnd);
      assert(FHwnd = 0);
    end;
  end;
end;

constructor TSciterWindow.Create(AInstance: HMODULE; AFlags: TSciterCreateWindowFlags; frame: TRect;
  parent: HWINDOW; AWndProc: TSciterWndProc);
var
  dwStyle, dwStyleEx: UINT;
  LRectP: TRect;
  w, h: Integer;
  sClassName: SciterString;
begin
  FFlags := AFlags;
  FInstance := AInstance;
  FOnWndProc := AWndProc;
  FDestroying := False;
  FIsShowing  := False;
  FIsModaling := False;
  FModalCode  := -1;
  
  InitSciterClass;
       
  dwStyle := 0;
  dwStyleEx := 0;
  if swAlpha in FFlags then
    dwStyle := (dwStyle or WS_POPUP) and (not WS_BORDER);
  if swPopup in FFlags then
    dwStyle := (dwStyle or WS_POPUP) and (not WS_BORDER);
  if swChild in FFlags then
    dwStyle := dwStyle or WS_CHILD;
  if swTitlebar in FFlags then
    dwStyle := dwStyle or WS_OVERLAPPED or WS_CAPTION;
  if swResizeable in FFlags then
    dwStyle := dwStyle or WS_THICKFRAME;
  if swSysMenu in FFlags then
    dwStyle := dwStyle or WS_SYSMENU;
  if swMinimizeBox in FFlags then
    dwStyle := dwStyle or WS_MINIMIZEBOX;
  if swMaximizeBox in FFlags then
    dwStyle := dwStyle or WS_MAXIMIZEBOX;
  if swTool in FFlags then
    dwStyleEx := dwStyleEx or WS_EX_TOOLWINDOW;
  if swTopMost in FFlags then
    dwStyleEx := dwStyleEx or WS_EX_TOPMOST;
  if swNoActivate in FFlags then
    dwStyleEx := dwStyleEx or WS_EX_NOACTIVATE;
  if swAcceptFiles in FFlags then
    dwStyleEx := dwStyleEx or WS_EX_ACCEPTFILES;
  if (swMain in FFlags) and (not (swNoTaskIcon in FFlags)) then
    dwStyleEx := dwStyleEx or WS_EX_APPWINDOW;
  if swScreenCenter in FFlags then
  begin
    w := frame.Right-frame.Left;
    h := frame.Bottom-frame.Top;
    frame.Left := (GetSystemMetrics(SM_CXSCREEN) - w) div 2;
    frame.Top := (GetSystemMetrics(SM_CYSCREEN) - h) div 2;
    frame.Right := frame.Left + w;
    frame.Bottom := frame.Top + h;
  end
  else
  if IsWindow(parent) and (swParentCenter in FFlags) then
  begin
    w := frame.Right-frame.Left;
    h := frame.Bottom-frame.Top;
    
    GetWindowRect(parent, LRectP);
    frame.Left := LRectP.Left + ((LRectP.Right-LRectP.Left) - w) div 2;
    frame.Top := LRectP.Top + ((LRectP.Bottom-LRectP.Top) - h) div 2;
    frame.Right := frame.Left + w;
    frame.Bottom := frame.Top + h;
  end;
  dwStyle := WS_CLIPCHILDREN or dwStyle;
  sClassName := Self.ClassName;
  FHwnd := CreateWindowExW(dwStyleEx, SCITER_WINDOW_CLASS_NAME, PSciterChar(sClassName),
    dwStyle, frame.Left, frame.Top, frame.Right-frame.Left, frame.Bottom-frame.Top,
    parent, 0, MainInstance, Self);
  Assert(FHwnd<>0);
  Assert(FLayoutImpl<>nil);

  if swWindowShadow in FFlags then
    SetupShadow(FHwnd);

  if swEnableDebug in FFlags then
    FLayoutImpl.EnableDebugger(True);
  if swAlpha in FFlags then
    FLayoutImpl.SetOption(SCITER_ALPHA_WINDOW, Integer(True));
  if swUxTheme in FFlags then
    FLayoutImpl.SetOption(SCITER_SET_UX_THEMING, Integer(True));

  FLayoutImpl.Setup;
end;

destructor TSciterWindow.Destroy;
begin
  if FDestroying then
    Exit;
  FDestroying := True;
  Close;
  FLayoutImpl := nil;
  FLayout := nil;
  inherited;
end;

procedure TSciterWindow.DoEnableModalParent;
var
  i: Integer;
  hParentWnd: HWINDOW;
begin
  for i := High(FParentWnds) downto 0 do
  begin
    hParentWnd := FParentWnds[i];
    if IsWindow(hParentWnd) then
      EnableWindow(hParentWnd, True)
    else
      Break;
  end;
  if Length(FParentWnds) > 0 then
    BringWindowToTop(FParentWnds[0]);
  SetLength(FParentWnds, 0);
end;

procedure TSciterWindow.EndModal(nCode: Integer);
begin
  if nCode >= 0 then
    FModalCode := nCode;
  FIsModaling := False;
  DoEnableModalParent;
  
  PostMessage(0, WM_NULL, 0, 0);
end;

class procedure TSciterWindow.FinalSciterClass;
begin
  if varWndCls = 0 then
    Exit;
  UnregisterClassW(SCITER_WINDOW_CLASS_NAME, HInstance);
  varWndCls := 0;
end;

function TSciterWindow.GetBehavior: IDefalutBehaviorEventHandler;
begin
  if FLayoutImpl <> nil then
    Result := FLayoutImpl.Behavior
  else
    Result := nil;
end;

function TSciterWindow.GetBounds: TRect;
begin
  GetWindowRect(FHwnd, Result);
end;

function TSciterWindow.GetCaption: SciterString;
var
  iLen: Integer;
begin
  if FHwnd <> 0 then
  begin
    SetLength(Result, 256);
    iLen := GetWindowTextW(FHwnd, PWideChar(Result), Length(Result));
    SetLength(Result, iLen);
  end;
end;

function TSciterWindow.GetFlags: TSciterCreateWindowFlags;
begin
  Result := FFlags;
end;

function TSciterWindow.GetHeight: Integer;
var
  rcBounds: TRect;
begin
  rcBounds := GetBounds;
  Result := rcBounds.Bottom - rcBounds.Top;
end;

function TSciterWindow.GetHwnd: HWINDOW;
begin 
  Result := FHwnd;
end;

function TSciterWindow.GetIsModaling: Boolean;
begin
  Result := FIsModaling;
end;

function TSciterWindow.GetIsShowing: Boolean;
begin                     
  Result := FIsShowing;
end;

function TSciterWindow.GetLayout: PISciterLayout;
begin
  Result := @FLayout;
end;

function TSciterWindow.GetLeft: Integer;
begin
  Result := GetBounds.Left;
end;

function TSciterWindow.GetModalCode: Integer;
begin
  Result := FModalCode;
end;

function TSciterWindow.GetOnClose: TSciterNotifyEvent;
begin
  Result := FOnClose;
end;

function TSciterWindow.GetOnCloseQuery: TSciterCloseQueryEvent;
begin
  Result := FOnCloseQuery;
end;

function TSciterWindow.GetOnCreate: TSciterNotifyEvent;
begin
  Result := FOnCreate;
end;

function TSciterWindow.GetOnDestroy: TSciterNotifyEvent;
begin
  Result := FOnDestroy;
end;

function TSciterWindow.GetOnHide: TSciterNotifyEvent;
begin
  Result := FOnHide;
end;

function TSciterWindow.GetOnKeyDown: TSciterKeyDownEvent;
begin
  Result := FOnKeyDown;
end;

function TSciterWindow.GetOnShow: TSciterNotifyEvent;
begin
  Result := FOnShow;
end;

function TSciterWindow.GetOnWndProc: TSciterWndProc;
begin
  Result := FOnWndProc;
end;

function TSciterWindow.GetParent: HWINDOW;
begin
  Assert(FHwnd<>0);
  Result := GetWindowLong(FHwnd, GWL_HWNDPARENT);
end;

function TSciterWindow.GetResourceInstance: HMODULE;
begin
  Result := FInstance;
end;

function TSciterWindow.GetTag: Pointer;
begin
  Result := FTag;
end;

function TSciterWindow.GetTop: Integer;
begin
  Result := GetBounds.Top;
end;

function TSciterWindow.GetWidth: Integer;
var
  rcBounds: TRect;
begin
  rcBounds := GetBounds;
  Result := rcBounds.Right - rcBounds.Left;
end;

function TSciterWindow.GetWindowName: SciterString;
begin
  Result := Self.ClassName;
end;

procedure TSciterWindow.Hide;
begin
  if IsWindow(FHwnd) and IsWindowVisible(FHwnd) then
    ShowWindow(FHwnd, SW_HIDE);
  FIsShowing := False;
end;

class function TSciterWindow.InitSciterClass: Boolean;
var
  wcex: TWndClassExW;
begin
  if varWndCls <> 0 then
  begin
    Result := True;
    Exit;
  end;

  //SCITER_WINDOW_CLASS_NAME := SAPI.SciterClassName();

  wcex.cbSize         := SizeOf(wcex);
  wcex.style			    := 0; //CS_HREDRAW or CS_VREDRAW;
  wcex.lpfnWndProc	  := @_wnd_proc;
  wcex.cbClsExtra		  := 0;
  wcex.cbWndExtra		  := 0;
  wcex.hInstance		  := HInstance;
  wcex.hIcon		      := LoadIcon(MainInstance, 'MAINICON');
  wcex.hCursor		    := LoadCursor(0, IDC_ARROW);
  wcex.hbrBackground  := (COLOR_WINDOW+1);
  wcex.lpszMenuName	  := nil;
  wcex.lpszClassName  := SCITER_WINDOW_CLASS_NAME;
  wcex.hIconSm		    := LoadIcon(MainInstance, 'MAINICON');

  varWndCls := RegisterClassExW(wcex);
  Result := varWndCls <> 0;
end;

function TSciterWindow.IsBubbling(event_type: UINT): Boolean;
begin
  Result := Behavior.IsBubbling(event_type)
end;

function TSciterWindow.IsHandled(event_type: UINT): Boolean;
begin
  Result := Behavior.IsHandled(event_type)
end;

function TSciterWindow.IsSinking(event_type: UINT): Boolean;
begin
  Result := Behavior.IsSinking(event_type)
end;

procedure TSciterWindow.SetBehavior(
  const Value: IDefalutBehaviorEventHandler);
begin
  if FLayoutImpl = nil then
    Exit;
  FLayoutImpl.Behavior := Value;
end;

procedure TSciterWindow.SetBounds(const Value: TRect);
begin
  if not IsIconic(FHwnd) then
    SetWindowPos(FHwnd, 0, Value.Left, Value.Top,
      (Value.Right-Value.Left), (Value.Bottom-Value.Top),
      SWP_NOZORDER + SWP_NOACTIVATE)
end;

procedure TSciterWindow.SetCaption(const Value: SciterString);
begin
  if FHwnd <> 0 then
    SetWindowTextW(FHwnd, PWideChar(Value));
end;

procedure TSciterWindow.SetHeight(const Value: Integer);
var
  rcBounds: TRect;
begin
  rcBounds := GetBounds;
  rcBounds.Bottom := rcBounds.Top + Value;
  SetBounds(rcBounds);
end;

procedure TSciterWindow.SetLeft(const Value: Integer);
var
  rcBounds: TRect;
begin
  rcBounds := GetBounds;
  rcBounds.Left := Value;
  SetBounds(rcBounds);
end;

procedure TSciterWindow.SetModalCode(const Value: Integer);
begin
  FModalCode := Value;
end;

procedure TSciterWindow.SetOnClose(const Value: TSciterNotifyEvent);
begin
  FOnClose := Value;
end;

procedure TSciterWindow.SetOnCloseQuery(const Value: TSciterCloseQueryEvent);
begin
  FOnCloseQuery := Value;
end;

procedure TSciterWindow.SetOnCreate(const Value: TSciterNotifyEvent);
begin
  FOnCreate := Value;
end;

procedure TSciterWindow.SetOnDestroy(const Value: TSciterNotifyEvent);
begin
  FOnDestroy := Value;
end;

procedure TSciterWindow.SetOnHide(const Value: TSciterNotifyEvent);
begin
  FOnHide := Value;
end;

procedure TSciterWindow.SetOnKeyDown(const Value: TSciterKeyDownEvent);
begin
  FOnKeyDown := Value;
end;

procedure TSciterWindow.SetOnShow(const Value: TSciterNotifyEvent);
begin
  FOnShow := Value;
end;

procedure TSciterWindow.SetOnWndProc(const Value: TSciterWndProc);
begin
  FOnWndProc := Value;
end;

procedure TSciterWindow.SetParent(const Value: HWINDOW);
begin
  Assert(FHwnd<>0);
  SetWindowLong(FHwnd, GWL_HWNDPARENT, Value);
end;

procedure TSciterWindow.SetTag(const Value: Pointer);
begin
  FTag := Value;
end;

procedure TSciterWindow.SetTop(const Value: Integer);
var
  rcBounds: TRect;
begin
  rcBounds := GetBounds;
  rcBounds.Top := Value;
  SetBounds(rcBounds);
end;

procedure TSciterWindow.SetWidth(const Value: Integer);
var
  rcBounds: TRect;
begin
  rcBounds := GetBounds;
  rcBounds.Right := rcBounds.Left + Value;
  SetBounds(rcBounds);
end;

procedure TSciterWindow.Show(nCmdShow: Integer; Update, AddToList: Boolean);
begin
  FIsShowing := True;                                         
  if IsWindow(FHwnd) then
  begin
    ShowWindow(FHwnd, nCmdShow);
    if Update then
      UpdateWindow(FHwnd);
    if AddToList and (__SciterWindowList.IndexOf(FHwnd) = -1) then
      __SciterWindowList.Add(Self);
  end;
end;

function TSciterWindow.ShowModal(nCmdShow: Integer): Integer;
var
  hParentWnd: HWINDOW;
  msg: TMsg;
begin
  FModalCode  := 0;
  FisModaling := True;

  if GetCapture <> 0 then SendMessageW(GetCapture, WM_CANCELMODE, 0, 0);
  ReleaseCapture;

  Show(nCmdShow);

  hParentWnd := Self.Parent;
  SetLength(FParentWnds, 0);
  while (hParentWnd <> 0) and IsWindowEnabled(hParentWnd) do
  begin
    SetLength(FParentWnds, Length(FParentWnds)+1);
    FParentWnds[High(FParentWnds)] := hParentWnd;
    EnableWindow(hParentWnd, False);

    hParentWnd := Windows.GetParent(hParentWnd);
  end;
  while IsWindow(FHwnd) and FIsModaling do
  begin
    if not GetMessageW(msg, 0, 0, 0) then
      Break;
    TranslateMessage(msg);
    DispatchMessageW(msg);
  end;
  DoEnableModalParent;
  Hide;

  Result := FModalCode;
end;

function TSciterWindow.WndProc(hwnd: HWINDOW; msg: UINT; wParam: WPARAM;
  lParam: LPARAM; var pHandled: Boolean): LRESULT;
var
  LMsg: PMsg;
  bCanClose: Boolean;
  ps: TPaintStruct;
begin
  pHandled := False;
  Result := -1;

  if FHwnd = 0 then
    FHwnd := hwnd;
  if @FOnWndProc <> nil then
  begin
    Result := FOnWndProc(Self, msg, wParam, lParam, pHandled);
    if pHandled then
      Exit;
  end;  
  case msg of
    WM_CREATE:
    begin
      FLayoutImpl := TSciterLayout.Create(TSciter(Sciter.Implementor), Self);
      FLayout := FLayoutImpl;
      if @FOnCreate <> nil then
      begin
        FOnCreate(Self, pHandled, Result);
        if pHandled then
          Exit;      
      end;
    end;
    WM_NCACTIVATE:
    begin   
      if (word(wParam) = WA_ACTIVE) and (swNoActivate in FFlags) then
      begin
        Result := SendMessageW(lParam, WM_NCACTIVATE, wParam, lParam);
        pHandled := True;
      end;
    end;
    WM_GETDLGCODE:
    begin
      Result := DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
      if lParam <> 0 then
      begin
        LMsg := PMsg(lParam);
        case LMsg.Message of
          WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR, WM_KEYDOWN, WM_KEYUP, WM_CHAR:
          begin
            Result := _wnd_proc(hwnd, LMsg.message, LMsg.wParam, LMsg.lParam);
          end;
        end;
      end;
      pHandled := True;
      Exit;
    end;
    WM_MOUSEACTIVATE:
    begin
      if (swNoMouseActivate in FFlags) and IsWindow(Self.Parent)  then
      begin                   
        Result := MA_NOACTIVATE;
        pHandled := True;
      end;
    end;
    WM_WINDOWPOSCHANGED:
    begin
      if (PWindowPos(lParam).flags and SWP_SHOWWINDOW) <> 0 then
      begin
        if @FOnShow <> nil then
        begin
          FOnShow(Self, pHandled, Result);
          if pHandled then
            Exit;
        end;
      end
      else
      if (PWindowPos(lParam).flags and SWP_HIDEWINDOW) <> 0 then
      begin
        if @FOnHide <> nil then
        begin
          FOnHide(Self, pHandled, Result);
          if pHandled then
            Exit;
        end;
      end;      
    end;
    WM_KEYDOWN,
    WM_SYSKEYDOWN:
    begin
      if @FOnKeyDown <> nil then
      begin
        FOnKeyDown(Self, msg, wParam, lParam, pHandled, Result);
        if pHandled then
          Exit;
      end
      else if (wParam = VK_F12) and (swEnableDebug in FFlags) then
        __GetDebugOut.Inspect(Self.Layout);
    end;
    WM_CLOSE:
    begin
      if FIsModaling then
        EndModal(-1)
      else
      if IsWindow(Self.Parent) then
        BringWindowToTop(Self.Parent);
      if @FOnClose <> nil then
      begin
        FOnClose(Self, pHandled, Result);
        if pHandled then
          Exit;
      end;
    end;
    WM_QUERYENDSESSION:
    begin
      Result := Windows.LRESULT(True);
      if @FOnCloseQuery <> nil then
      begin
        bCanClose := True;
        FOnCloseQuery(Self, pHandled, bCanClose);
        if pHandled then
        begin
          Result := Windows.LRESULT(bCanClose);
          Exit;
        end;
      end;
    end;
    WM_PAINT:
    begin
      if swDXPaint in FFlags then
      begin
        BeginPaint(hwnd, ps);
        EndPaint(hwnd, ps);
      end;
    end;
  end;
  // if dxpaint, we create the engine instance later,
  // by calling SciterCreateOnDirectXWindow(hWnd, pSwapChain);
  if (FLayoutImpl <> nil) then
  begin
    if (msg<>WM_CREATE) or (not (swDXPaint in FFlags)) then
      Result := FLayoutImpl.ProcND(hwnd, msg, wParam, lParam, pHandled);
    if pHandled then
      Exit;
  end;
  if msg = WM_DESTROY then
  begin
    FIsWindowDestroying := True;
    if @FOnDestroy <> nil then
    begin
      FOnDestroy(Self, pHandled, Result);
      if pHandled then
        Exit;
    end;
    if (Self <> nil) and (not FDestroying) then
    begin
      if FLayoutImpl <> nil then
      begin
        FLayoutImpl := nil;
        FLayout := nil;
      end;
      __SciterWindowList.DeleteByHandle(hwnd);
      FHwnd := 0;
    end;
    pHandled := True;
  end;
end;

function TSciterWindow._AddRef: Integer;
begin
  if not FDestroying then
    Result := inherited _AddRef
  else
    Result := FRefCount;
end;

function TSciterWindow._Release: Integer;
begin
  if not FDestroying then
    Result := inherited _Release
  else
    Result := FRefCount;
end;

{ TSciterWindowList }

function TSciterWindowList.Add(AWindow: ISciterWindow): Integer;
begin
  Result := FList.Add(AWindow);
end;

procedure TSciterWindowList.Clear;
begin
  try
    FList.Clear;
  except
    on E: Exception do
      Trace('[TSciterWindowList.Clear]'+E.Message);
  end;
end;

constructor TSciterWindowList.Create;
begin
  FList := TInterfaceList.Create;
end;

procedure TSciterWindowList.Delete(const AIndex: Integer);
begin
  FList.Delete(AIndex);
end;

procedure TSciterWindowList.DeleteByHandle(const AHandle: Cardinal);
var
  idx: Integer;
begin
  idx := IndexOf(AHandle);
  if idx >= 0 then
    Delete(idx);
end;

destructor TSciterWindowList.Destroy;
begin
  FList := nil;
  inherited;
end;

function TSciterWindowList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSciterWindowList.GetItem(const Index: Integer): ISciterWindow;
begin
  Result := FList[Index] as ISciterWindow;
end;

function TSciterWindowList.GetItemByHandle(const AHandle: Cardinal): ISciterWindow;
var
  idx: Integer;
begin
  idx := IndexOf(AHandle);
  if idx < 0 then
    Result := nil
  else
    Result := GetItem(idx);
end;

function TSciterWindowList.Implementor: Pointer;
begin
  Result := Self;
end;

function TSciterWindowList.IndexOf(const AHandle: Cardinal): Integer;
begin
  for Result := 0 to FList.Count - 1 do
    if GetItem(Result).Handle = AHandle then
      Exit;
  Result := - 1;
end;

initialization

finalization
  varSciterWindowList := nil;
  TSciterWindow.FinalSciterClass;

end.
