unit Behavior.ActiveX;

interface

uses
  SysUtils, Classes, Windows, ActiveX, SciterBehavior, SciterTypes, Messages,
  SciterIntf, SciterVideoIntf;

type
  TActiveXBehavior = class;

  PDVExtentInfo = ^TDVExtentInfo;
  tagExtentInfo = packed record
    cb: ULONG;
    dwExtentMode: DWORD;
    sizelProposed: TPoint;
  end;
  TDVExtentInfo = tagExtentInfo;
  DVEXTENTINFO = TDVExtentInfo;

  IViewObjectEx = interface(IViewObject2)
  ['{3AF24292-0C96-11CE-A0CF-00AA00600AB8}']
    function GetRect(dwAspect: DWORD; out pRect: TRect): HResult; stdcall;
    function GetViewStatus(out pdwStatus: DWORD): HResult; stdcall;
    function QueryHitPoint(dwAspect: DWORD; pRectBounds: PRect; ptlLoc: TPoint;
      lCloseHint: LongInt; out pHitResult: DWORD): HResult; stdcall;
    function QueryHitRect(dwAspect: DWORD; pRectBounds: PRect; pRectLoc: PRect;
      lCloseHint: LongInt; out pHitResult: DWORD): HResult; stdcall;
    function GetNaturalExtent(dwAspect: DWORD; lindex: LongInt; ptd: PDVTargetDevice;
      hicTargetDev: HDC; pExtentInfo: PDVExtentInfo; out size: TPoint): HResult; stdcall;
  end;
  
  PIUnknown = ^IUnknown;
  TActiveXEnum = class(TInterfacedObject, IUnknown, IEnumUnknown)
  private
    m_iPos: LongInt;
    m_pUnk: IUnknown;
  public
    constructor Create(const pUnk: IUnknown);
    destructor Destroy; override;
    
    { IEnumUnknown }
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enm: IEnumUnknown): HResult; stdcall;
  end;

  TActiveXFrameWnd = class(TInterfacedObject,
    IUnknown,
    IOleWindow,
    IOleInPlaceUIWindow, 
    IOleInPlaceFrame)
  private
    m_pOwner: TActiveXBehavior;
    m_pActiveObject: IOleInPlaceActiveObject;
  public
    constructor Create(const pOwner: TActiveXBehavior);
    destructor Destroy; override;
    
    { IOleWindow }
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;

    { IOleInPlaceUIWindow }
    function GetBorder(out rectBorder: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(pborderwidths: PRect): HResult; stdcall;
    function SetActiveObject(const activeObject: IOleInPlaceActiveObject;
      pszObjName: POleStr): HResult; stdcall;

    { IOleInPlaceFrame }
    function InsertMenus(hmenuShared: HMenu;
      var menuWidths: TOleMenuGroupWidths): HResult; stdcall;
    function SetMenu(hmenuShared: HMenu; holemenu: HMenu;
      hwndActiveObject: HWnd): HResult; stdcall;
    function RemoveMenus(hmenuShared: HMenu): HResult; stdcall;
    function SetStatusText(pszStatusText: POleStr): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    function TranslateAccelerator(var msg: TMsg; wID: Word): HResult; stdcall;
  end;

  TActiveXCtrl = class(TInterfacedObject,
    IUnknown,
    IOleWindow,
    IOleClientSite,
    IOleInPlaceSite,
    IOleInPlaceSiteEx,
    IOleInPlaceSiteWindowless,
    IOleControlSite,
    IObjectWithSite,
    IParseDisplayName,
    IOleContainer)
  private
    m_pOwner: TActiveXBehavior;
    m_pUnkSite: IUnknown; 
    m_pViewObject: IViewObject;
    m_pInPlaceObject: IOleInPlaceObjectWindowless; 
  
    m_bLocked: Boolean;
    m_bFocused: Boolean;
    m_bCaptured: Boolean;
    m_bUIActivated: Boolean;
    m_bInPlaceActive: Boolean;
    m_bWindowless: Boolean;
  public
    constructor Create(AOwner: TActiveXBehavior);
    destructor Destroy; override;

    { IOleWindow }
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;

    { IOleClientSite }
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;

    { IOleInPlaceSite }
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out frame: IOleInPlaceFrame;
      out doc: IOleInPlaceUIWindow; out rcPosRect: TRect;
      out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult;
      stdcall;
    function Scroll(scrollExtent: TPoint): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(const rcPosRect: TRect): HResult; stdcall;

    { IOleInPlaceSiteEx }
    function OnInPlaceActivateEx(fNoRedraw: PBOOL; 
       dwFlags: DWORD): HResult; stdcall;
    function OnInPlaceDeActivateEx(fNoRedraw: BOOL): HResult; stdcall;
    function RequestUIActivate: HResult; stdcall;

    { IOleInPlaceSiteWindowless }
    function CanWindowlessActivate: HResult; stdcall;
    function GetCapture: HResult; stdcall;
    function SetCapture(fCapture: BOOL): HResult; stdcall;
    function GetFocus: HResult; stdcall;
    function SetFocus(fFocus: BOOL): HResult; stdcall;
    function GetDC(var Rect: TRect; qrfFlags: DWORD; 
       var hDC: HDC): HResult; stdcall;
    function ReleaseDC(hDC: HDC): HResult; stdcall;
    function InvalidateRect(var Rect: TRect; fErase: BOOL): HResult; stdcall;
    function InvalidateRgn(hRGN: HRGN; fErase: BOOL): HResult; stdcall;
    function ScrollRect(dx, dy: Integer; var RectScroll: TRect; 
       var RectClip: TRect): HResult; stdcall;
    function AdjustRect(var rc: TRect): HResult; stdcall;
    function OnDefWindowMessage(msg: LongWord; wParam: WPARAM;
       lParam: LPARAM; var LResult: LRESULT): HResult; stdcall;

    { IOleControlSite }
    function OnControlInfoChanged: HResult; stdcall;
    function LockInPlaceActive(fLock: BOOL): HResult; stdcall;
    function GetExtendedControl(out disp: IDispatch): HResult; stdcall;
    function TransformCoords(var ptlHimetric: TPoint; var ptfContainer: TPointF;
      flags: Longint): HResult; stdcall;
    function TranslateAccelerator(msg: PMsg; grfModifiers: Longint): HResult; stdcall;
    function OnFocus(fGotFocus: BOOL): HResult; stdcall;
    function ShowPropertyFrame: HResult; stdcall;

    { IObjectWithSite }
    function SetSite(const pUnkSite: IUnknown ):HResult; stdcall;
    function GetSite(const riid: TIID; out site: IUnknown):HResult; stdcall;

    { IParseDisplayName }
    function ParseDisplayName(const bc: IBindCtx; pszDisplayName: POleStr;
      out chEaten: Longint; out mkOut: IMoniker): HResult; stdcall;

    { IOleContainer }
    function EnumObjects(grfFlags: Longint; out Enum: IEnumUnknown): HResult; stdcall;
    function LockContainer(fLock: BOOL): HResult; stdcall;
  end;

  TActiveXBehavior = class(TBehaviorEventHandler)
  protected
    m_isInstall: Boolean;
    m_clsid: TGUID;
    m_pControl: IUnknown;
    m_pUnk: IOleObject;
    m_sModuleName: string;
    m_bCreated: Boolean;
    m_bDelayCreate: Boolean;
    FSizeChanged: Boolean;
    rendering_site: IVideoDestination;
    m_hwndHost: HWND;
    m_activeXCtrl: TActiveXCtrl;
    m_MouseEnter: Boolean;
        
    function  GetClsid: TGUID;
    procedure SetClsid(const Value: TGUID);
  protected
    procedure DoInitObject(const AObject: IOleObject); virtual;
    procedure DoVerb(iVerb: LongInt);
    procedure DoPaintUpdate; virtual;
    procedure DoPaintInstall(const dc: HDC; const ARect: TRect; const BufBits: Pointer; BufLen: Cardinal); virtual;
    procedure DoPaintNotInstall(const dc: HDC; const ARect: TRect; const BufBits: Pointer; BufLen: Cardinal); virtual;
    
    procedure ReleaseControl(); virtual;
    function  DoCreateControl(): Boolean; virtual;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;

    function  OnMouseEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseLeave(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
    function  OnFocusGot(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; override;
    function  OnFocusLost(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; override;
    function  OnVideoBindRQ(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; override;
        
    function DoBeforeWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT; override;
  public
    constructor Create(const he: IDomElement); override;
    destructor Destroy; override;

    function IsWindowless: Boolean; virtual;
    function IsInstall: Boolean;
    
    property Clsid: TGUID read GetClsid write SetClsid;
  end;

implementation

const
//enum tagOLEDCFLAGS {
  OLEDC_NODRAW	    = $1;
	OLEDC_PAINTBKGND	= $2;
	OLEDC_OFFSCREEN  	= $4;
//    } 	OLEDCFLAGS;

//enum tagACTIVATEFLAGS {
  ACTIVATE_WINDOWLESS	= 1;
//    }

//enum tagHITRESULT {
  HITRESULT_OUTSIDE     = 0;
	HITRESULT_TRANSPARENT	= 1;
	HITRESULT_CLOSE	      = 2;
	HITRESULT_HIT	        = 3;
//    } 	HITRESULT;

procedure PixelToHiMetric(const lpSizeInPix: TSize; var lpSizeInHiMetric: TSize);
const
   HIMETRIC_PER_INCH = 2540;
   
  function MapPixToLoghim(x, ppli: Integer): Integer;
  begin
    Result := MulDiv(HIMETRIC_PER_INCH, x, ppli);
  end;
  function MapLoghimToPix(x, ppli: Integer): Integer;
  begin
    Result := MulDiv(ppli, x, HIMETRIC_PER_INCH);
  end;
  
var
  nPixelsPerInchX, nPixelsPerInchY: Integer;
  hDCScreen: HDC; 
begin
  hDCScreen := Windows.GetDC(0);
  nPixelsPerInchX := Windows.GetDeviceCaps(hDCScreen, LOGPIXELSX);
  nPixelsPerInchY := Windows.GetDeviceCaps(hDCScreen, LOGPIXELSY);
  Windows.ReleaseDC(0, hDCScreen);

  lpSizeInHiMetric.cx := MapPixToLoghim(lpSizeInPix.cx, nPixelsPerInchX);
  lpSizeInHiMetric.cy := MapPixToLoghim(lpSizeInPix.cy, nPixelsPerInchY);
end;

function GET_X_LPARAM(const lp: LPARAM): Integer;
begin
  Result := Integer(short(LOWORD(lp)));
end;

function GET_Y_LPARAM(const lp: LPARAM): Integer;
begin
  Result := Integer(short(HIWORD(lp)));
end;

{ TActiveXEnum }

function TActiveXEnum.Clone(out enm: IEnumUnknown): HResult;
begin
  Result := E_NOTIMPL;
end;

constructor TActiveXEnum.Create(const pUnk: IUnknown);
begin
  m_pUnk := pUnk;
  m_iPos := 0;
end;

destructor TActiveXEnum.Destroy;
begin
  m_pUnk := nil;
  inherited;
end;

function TActiveXEnum.Next(celt: Integer; out elt;
  pceltFetched: PLongint): HResult;
begin
  if pceltFetched <> nil then
    pceltFetched^ := 0;
    
  m_iPos := m_iPos + 1;
  if m_iPos > 1 then
  begin
    Result := S_FALSE;
    Exit;
  end;

  IUnknown(elt) := m_pUnk;

  if pceltFetched <> nil then
     pceltFetched^ := 1;
     
  Result := S_OK;
end;

function TActiveXEnum.Reset: HResult;
begin
  m_iPos := 0;
  Result := S_OK;
end;

function TActiveXEnum.Skip(celt: Integer): HResult;
begin
  m_iPos := m_iPos + celt;
  Result := S_OK;
end;

{ TActiveXFrameWnd }

function TActiveXFrameWnd.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

constructor TActiveXFrameWnd.Create(const pOwner: TActiveXBehavior);
begin
  m_pOwner := pOwner;
  m_pActiveObject := nil;
end;

destructor TActiveXFrameWnd.Destroy;
begin
  m_pActiveObject := nil;
  inherited;
end;

function TActiveXFrameWnd.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.GetBorder(out rectBorder: TRect): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.GetWindow(out wnd: HWnd): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit; 
  end;
  wnd := m_pOwner.m_hwndHost;
  Result := S_OK;
end;

function TActiveXFrameWnd.InsertMenus(hmenuShared: HMenu;
  var menuWidths: TOleMenuGroupWidths): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.RemoveMenus(hmenuShared: HMenu): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.RequestBorderSpace(
  const borderwidths: TRect): HResult;
begin
  Result := INPLACE_E_NOTOOLSPACE;
end;

function TActiveXFrameWnd.SetActiveObject(
  const activeObject: IOleInPlaceActiveObject;
  pszObjName: POleStr): HResult;
begin
  m_pActiveObject := activeObject;
  Result := S_OK;
end;

function TActiveXFrameWnd.SetBorderSpace(pborderwidths: PRect): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.SetMenu(hmenuShared, holemenu: HMenu;
  hwndActiveObject: HWnd): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.SetStatusText(pszStatusText: POleStr): HResult;
begin
  Result := S_OK;
end;

function TActiveXFrameWnd.TranslateAccelerator(var msg: TMsg;
  wID: Word): HResult;
begin
  Result := S_FALSE;
end;

{ TActiveXCtrl }

function TActiveXCtrl.AdjustRect(var rc: TRect): HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.CanInPlaceActivate: HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.CanWindowlessActivate: HResult;
begin
  Result := S_OK;  // Yes, we can!!
end;

function TActiveXCtrl.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

constructor TActiveXCtrl.Create(AOwner: TActiveXBehavior);
begin
  m_pOwner := AOwner;
  //m_pWindow := nil;
  m_pUnkSite := nil;
  m_pViewObject := nil;
  m_pInPlaceObject := nil;
  m_bLocked := False;
  m_bFocused := False;
  m_bCaptured := False;
  m_bWindowless := True;
  m_bUIActivated := False;
  m_bInPlaceActive := False;
end;

function TActiveXCtrl.DeactivateAndUndo: HResult;
begin
  Result := E_NOTIMPL;
end;

destructor TActiveXCtrl.Destroy;
begin
  m_pUnkSite := nil;
  m_pViewObject := nil;
  m_pInPlaceObject := nil;
    
  inherited;
end;

function TActiveXCtrl.DiscardUndoState: HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.EnumObjects(grfFlags: Integer;
  out Enum: IEnumUnknown): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  Enum := TActiveXEnum.Create(m_pOwner.m_pUnk); 
  Result := S_OK;
end;

function TActiveXCtrl.GetCapture: HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  if m_bCaptured then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TActiveXCtrl.GetContainer(out container: IOleContainer): HResult;
var
  Hr: HRESULT;
begin
  container := nil;
  Hr := E_NOTIMPL;
  
  if m_pUnkSite <> nil then
    Hr := m_pUnkSite.QueryInterface(IOleContainer, container);
  if FAILED(Hr) then
    Hr := QueryInterface(IOleContainer, container);
    
  Result := Hr;
end;

function TActiveXCtrl.GetDC(var Rect: TRect; qrfFlags: DWORD; var hDC: HDC): HResult;
var
  rcItem: TRect;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  if m_bWindowless then
  begin
    Result := S_FALSE;
    Exit;
  end;

  hDC := Windows.GetDC(m_pOwner.m_hwndHost);
  if (qrfFlags and OLEDC_PAINTBKGND) <> 0 then
  begin
    rcItem := m_pOwner.This.GetLocation(VIEW_RELATIVE or CONTENT_BOX);
    if not m_bWindowless then
      Windows.OffsetRect(rcItem, -rcItem.Left, -rcItem.Top);

    Windows.FillRect(hDC, rcItem, COLOR_WINDOW + 1);
  end;

  Result := S_OK;
end;

function TActiveXCtrl.GetExtendedControl(out disp: IDispatch): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  if m_pOwner.m_pUnk = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;

  Result := m_pOwner.m_pUnk.QueryInterface(IDispatch, disp);
end;

function TActiveXCtrl.GetFocus: HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  if m_bFocused then
    Result := S_OK
  else
    Result := S_FALSE;
end;

function TActiveXCtrl.GetMoniker(dwAssign, dwWhichMoniker: Integer; out mk: IMoniker): HResult;
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.GetSite(const riid: TIID;
  out site: IInterface): HResult;
begin
  site := nil;
  if m_pUnkSite = nil then
  begin
    Result := E_FAIL;
    Exit;
  end;
  Result := m_pUnkSite.QueryInterface(riid, site);
end;

function TActiveXCtrl.GetWindow(out wnd: HWnd): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  //if( m_pOwner->m_hwndHost == NULL ) CreateActiveXWnd();
  if m_pOwner.m_hwndHost = 0 then
  begin
    Result := E_FAIL;
    Exit;
  end;
  wnd := m_pOwner.m_hwndHost;
  Result := S_OK;
end;

function TActiveXCtrl.GetWindowContext(out frame: IOleInPlaceFrame;
  out doc: IOleInPlaceUIWindow; out rcPosRect, rcClipRect: TRect;
  out frameInfo: TOleInPlaceFrameInfo): HResult;
var
  rcItem: TRect;
  ac: ACCEL;
  hac: HACCEL;
begin
  rcItem := m_pOwner.This.GetLocation(VIEW_RELATIVE or CONTENT_BOX);
  CopyMemory(@rcPosRect, @rcItem, SizeOf(rcItem));
  CopyMemory(@rcClipRect, @rcItem, SizeOf(rcItem));

  frame := TActiveXFrameWnd.Create(m_pOwner);
  doc := nil;

  ZeroMemory(@ac, SizeOf(ACCEL));
  hac := CreateAcceleratorTable(ac, 1);

  frameInfo.cb := SizeOf(OLEINPLACEFRAMEINFO);
  frameInfo.fMDIApp := False;
  frameInfo.hwndFrame := m_pOwner.This.GetElementHwnd;
  frameInfo.haccel := hac;
  frameInfo.cAccelEntries := 1;

  Result := S_OK;
end;

function TActiveXCtrl.InvalidateRect(var Rect: TRect; fErase: BOOL): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  if m_pOwner.m_hwndHost = 0 then
  begin
    Result := E_FAIL;
    Exit;
  end;

  if Windows.InvalidateRect(m_pOwner.m_hwndHost, @Rect, fErase) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TActiveXCtrl.InvalidateRgn(hRGN: HRGN; fErase: BOOL): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;

  if Windows.InvalidateRgn(m_pOwner.m_hwndHost, hRGN, fErase) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TActiveXCtrl.LockContainer(fLock: BOOL): HResult;
begin
  m_bLocked := fLock;
  Result := S_OK;
end;

function TActiveXCtrl.LockInPlaceActive(fLock: BOOL): HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.OnControlInfoChanged: HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.OnDefWindowMessage(msg: LongWord; wParam: WPARAM;
  lParam: LPARAM; var LResult: LRESULT): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  
  LResult := Windows.DefWindowProc(m_pOwner.m_hwndHost, msg, wParam, lParam);
  Result := S_OK;
end;

function TActiveXCtrl.OnFocus(fGotFocus: BOOL): HResult;
begin
  m_bFocused := fGotFocus;
  Result := S_OK;
end;

function TActiveXCtrl.OnInPlaceActivate: HResult;
var
  bDummy: BOOL;
begin
  bDummy := FALSE;
  Result := OnInPlaceActivateEx(@bDummy, 0);
end;

function TActiveXCtrl.OnInPlaceActivateEx(fNoRedraw: PBOOL;
  dwFlags: DWORD): HResult;
var
  hWndFrame: HWND;
  Hr: HRESULT;
  rcItem: TRect;
begin
  Assert(m_pInPlaceObject = nil);
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  if m_pOwner.m_pUnk = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;

  OleLockRunning(m_pOwner.m_pUnk, TRUE, FALSE);
  hWndFrame := m_pOwner.This.GetElementHwnd;

  m_bWindowless := true;
  Hr := m_pOwner.m_pUnk.QueryInterface(IOleInPlaceObjectWindowless, m_pInPlaceObject);
  m_pOwner.m_hwndHost := hWndFrame;

  if m_pInPlaceObject <> nil then
  begin
    rcItem := m_pOwner.This.GetLocation(VIEW_RELATIVE or CONTENT_BOX);
    if not m_bWindowless then
      OffsetRect(rcItem, -rcItem.Left, -rcItem.Top);
      m_pInPlaceObject.SetObjectRects(rcItem, rcItem);
  end;
    
  m_bInPlaceActive := SUCCEEDED(Hr);
  Result := Hr;
end;

function TActiveXCtrl.OnInPlaceDeactivate: HResult;
begin
  Result := OnInPlaceDeactivateEx(TRUE);
end;

function TActiveXCtrl.OnInPlaceDeActivateEx(fNoRedraw: BOOL): HResult;
begin
  m_bInPlaceActive := False;
  m_pInPlaceObject := nil;

  Result := S_OK;
end;

function TActiveXCtrl.OnPosRectChange(const rcPosRect: TRect): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.OnShowWindow(fShow: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.OnUIActivate: HResult;
begin
  m_bUIActivated := true;
  Result := S_OK;
end;

function TActiveXCtrl.OnUIDeactivate(fUndoable: BOOL): HResult;
begin
  m_bUIActivated := false;
  Result := S_OK;
end;

function TActiveXCtrl.ParseDisplayName(const bc: IBindCtx;
  pszDisplayName: POleStr; out chEaten: Integer;
  out mkOut: IMoniker): HResult;
begin
  Result := E_NOTIMPL
end;

function TActiveXCtrl.ReleaseDC(hDC: HDC): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  
  Windows.ReleaseDC(m_pOwner.m_hwndHost, hDC);
  Result := S_OK;
end;

function TActiveXCtrl.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.RequestUIActivate: HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.SaveObject: HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.Scroll(scrollExtent: TPoint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.ScrollRect(dx, dy: Integer; var RectScroll,
  RectClip: TRect): HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.SetCapture(fCapture: BOOL): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  m_bCaptured := fCapture;
  if m_bCaptured then
    m_pOwner.This.SetCapture
  else
    m_pOwner.This.ReleaseCapture;

  Result := S_OK;
end;

function TActiveXCtrl.SetFocus(fFocus: BOOL): HResult;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;

  m_bFocused := fFocus;
  if m_bFocused then
  begin
    m_pOwner.This.ChangeState(STATE_FOCUS);
  end
  else
    m_pOwner.This.ClearState(STATE_FOCUS);

  Result := S_OK;
end;

function TActiveXCtrl.SetSite(const pUnkSite: IInterface): HResult;
begin
  m_pUnkSite := pUnkSite;
  Result := S_OK;
end;

function TActiveXCtrl.ShowObject: HResult;
var
  hDC: Windows.HDC;
  rcItem: TRect;
begin
  if m_pOwner = nil then
  begin
    Result := E_UNEXPECTED;
    Exit;
  end;
  hDC := Windows.GetDC(m_pOwner.m_hwndHost);
  if hDC = 0 then
  begin
    Result := E_FAIL;
    Exit;
  end;
  try
    if m_pViewObject <> nil then
    begin
      rcItem := m_pOwner.This.GetLocation(VIEW_RELATIVE or CONTENT_BOX);
      m_pViewObject.Draw(DVASPECT_CONTENT, -1, nil, nil, 0, hDC, @rcItem, @rcItem, nil, 0);
    end;
  finally
    Windows.ReleaseDC(m_pOwner.m_hwndHost, hDC);
  end;

  Result := S_OK;
end;

function TActiveXCtrl.ShowPropertyFrame: HResult;
begin
  Result := E_NOTIMPL;
end;

function TActiveXCtrl.TransformCoords(var ptlHimetric: TPoint;
  var ptfContainer: TPointF; flags: Integer): HResult;
begin
  Result := S_OK;
end;

function TActiveXCtrl.TranslateAccelerator(msg: PMsg;
  grfModifiers: Integer): HResult;
begin
  Result := S_FALSE;
end;

{ TActiveXBehavior }

constructor TActiveXBehavior.Create(const he: IDomElement);
begin
  inherited;
  
  m_pUnk := nil;
  m_pControl := nil;
  m_hwndHost := 0;
  m_bCreated := False;
  m_bDelayCreate := False;
  m_clsid := GUID_NULL;
end;

destructor TActiveXBehavior.Destroy;
begin
  ReleaseControl();
  inherited;
end;

function TActiveXBehavior.DoBeforeWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var pbHandled: Boolean): LRESULT;
var
  dwHitResult: DWORD;
  pViewEx: IViewObjectEx;
  bWasHandled: Boolean;
  ptMouse: TPoint;
  dwMiscStatus: Integer;
  rcItem: TRect;
begin
  Result := 0;
  if m_pControl = nil then
    Exit;
  if not IsWindowless then
    Exit;
  if not m_activeXCtrl.m_bInPlaceActive then
    Exit;
  if m_activeXCtrl.m_pViewObject = nil then
    Exit;
  if m_activeXCtrl.m_pInPlaceObject = nil then
    Exit;
  if (not m_MouseEnter) then
    Exit;

  bWasHandled := False;
  if ((msg >= WM_MOUSEFIRST) and (msg<= WM_MOUSELAST)) or (msg = WM_SETCURSOR) then
  begin
    bWasHandled := True;
    // Mouse message only go when captured or inside rect
    if m_activeXCtrl.m_bCaptured then
      dwHitResult := HITRESULT_HIT
    else
      dwHitResult := HITRESULT_OUTSIDE;
    if (dwHitResult = HITRESULT_OUTSIDE) and (m_activeXCtrl.m_pViewObject <> nil) then
    begin
      if m_activeXCtrl.m_pViewObject.QueryInterface(IViewObjectEx, pViewEx) = S_OK then
      begin
        ptMouse.X := GET_X_LPARAM(lParam);
        ptMouse.Y := GET_Y_LPARAM(lParam);
        rcItem := This.GetLocation();
        pViewEx.QueryHitPoint(DVASPECT_CONTENT, @rcItem, ptMouse, 0, dwHitResult);
        pViewEx := nil;
      end;
    end;
    if dwHitResult <> HITRESULT_HIT then
      Exit;
    if msg = WM_SETCURSOR then
      bWasHandled := False;
  end
  else
  if (msg >= WM_KEYFIRST) and (msg <= WM_KEYLAST) then
  begin
    // Keyboard messages just go when we have focus
    if not m_activeXCtrl.m_bFocused then
      Exit;
  end
  else
  begin
    case msg of
      WM_MOUSEACTIVATE:
      begin
        m_pUnk.GetMiscStatus(DVASPECT_CONTENT, dwMiscStatus);
        if (dwMiscStatus and OLEMISC_NOUIACTIVATE) <> 0 then
        begin
          Result := 0;
          Exit;
        end;
        if m_activeXCtrl.m_bInPlaceActive then
           DoVerb(OLEIVERB_INPLACEACTIVATE);
        pbHandled := False;
        Result := 0;     
      end;
      WM_HELP,
      WM_CONTEXTMENU:
        bWasHandled := False;
    else
      Exit;
    end;
  end;

  if m_activeXCtrl.m_pInPlaceObject.OnWindowMessage(msg, wParam, lParam, Result) = S_OK then
    pbHandled := bWasHandled;
end;

function TActiveXBehavior.DoCreateControl(): Boolean;
type
  DllGetClassObjectFunc = function (const rclsid: TGUID; const riid: TGUID; var ppv: LPVOID): HRESULT; stdcall;

var
  pOleControl: IOleControl;
  Hr: HRESULT;
  hModule: Windows.HMODULE;
  aClassFactory: IClassFactory;
  aDllGetClassObjectFunc: DllGetClassObjectFunc;
  dwMiscStatus: Integer;
  pOleClientSite: IOleClientSite;
  pPersistStreamInit: IPersistStreamInit;
  pSite: IObjectWithSite;
  rcItem: TRect;
begin
  Result := False;
  try
    ReleaseControl();
    // At this point we'll create the ActiveX control
    m_bCreated := True;
    pOleControl := nil;


    rcItem := This.GetLocation(VIEW_RELATIVE or CONTENT_BOX);
  
    Hr := -1;
    if (m_sModuleName <> EmptyStr) then
    begin
      hModule := LoadLibrary(PChar(m_sModuleName));
      if hModule <> 0 then
      begin
        aClassFactory := nil;
        @aDllGetClassObjectFunc := GetProcAddress(hModule, 'DllGetClassObject');
        Hr := aDllGetClassObjectFunc(m_clsid, IClassFactory, LPVOID(aClassFactory));
        if SUCCEEDED(Hr) then
          Hr := aClassFactory.CreateInstance(nil, IOleObject, LPVOID(pOleControl));
      end;
    end;
    if Failed(Hr) then
      Hr := CoCreateInstance(m_clsid, nil, CLSCTX_ALL, IOleControl, LPVOID(pOleControl));
    
    ASSERT(SUCCEEDED(Hr));
    if FAILED(Hr) then
      Exit;
    
    pOleControl.QueryInterface(IOleObject, m_pUnk);
    if m_pUnk = nil then
      Exit;
    // Create the host too
    m_activeXCtrl := TActiveXCtrl.Create(Self);
    m_pControl := m_activeXCtrl;
    // More control creation stuff
    dwMiscStatus := 0;
    m_pUnk.GetMiscStatus(DVASPECT_CONTENT, dwMiscStatus);
    pOleClientSite := nil;
    m_pControl.QueryInterface(IOleClientSite, pOleClientSite);
    // Initialize control
    if (dwMiscStatus and OLEMISC_SETCLIENTSITEFIRST) <> 0 then
      m_pUnk.SetClientSite(pOleClientSite);
    pPersistStreamInit := nil;
    m_pUnk.QueryInterface(IPersistStreamInit, pPersistStreamInit);
    if pPersistStreamInit <> nil then
    begin
      Hr := pPersistStreamInit.InitNew();
    end;
    if FAILED(Hr) then
      Exit;
    if (dwMiscStatus and OLEMISC_SETCLIENTSITEFIRST) = 0 then
       m_pUnk.SetClientSite(pOleClientSite);
    // Grab the view...
    Hr := m_pUnk.QueryInterface(IViewObjectEx, m_activeXCtrl.m_pViewObject);
    if FAILED(Hr) then
      Hr := m_pUnk.QueryInterface(IViewObject2, m_activeXCtrl.m_pViewObject);
    if FAILED(Hr) then
      Hr := m_pUnk.QueryInterface(IViewObject, m_activeXCtrl.m_pViewObject);
    // Activate and done...
    m_pUnk.SetHostNames('UIActiveX', nil);

    DoInitObject(m_pUnk);

    if (dwMiscStatus and OLEMISC_INVISIBLEATRUNTIME) = 0 then
    begin
      Hr := m_pUnk.DoVerb(OLEIVERB_INPLACEACTIVATE, nil, pOleClientSite, 0, m_hwndHost, rcItem);
    end;
    pSite := nil;
    m_pUnk.QueryInterface(IObjectWithSite, pSite);
    if pSite <> nil then
    begin
      pSite.SetSite(m_pControl);
    end;
    Result := SUCCEEDED(Hr);
  finally
    m_isInstall := Result;
  end;
end;

procedure TActiveXBehavior.DoInitObject(const AObject: IOleObject);
begin

end;

procedure TActiveXBehavior.DoPaintInstall(const dc: HDC; const ARect: TRect;
  const BufBits: Pointer; BufLen: Cardinal);
begin
  m_activeXCtrl.m_pViewObject.Draw(DVASPECT_CONTENT, -1, nil, nil, 0, dc,
    @ARect, @ARect, nil, 0);
end;

procedure TActiveXBehavior.DoPaintNotInstall(const dc: HDC; const ARect: TRect;
  const BufBits: Pointer; BufLen: Cardinal);
begin

end;

//procedure SaveBitmap(pixels: Pointer; w, h: Integer; const filename: WideString);
//var
//  fileHdr: TBitmapFileHeader;
//  infoHdr: TBitmapInfoHeader;
//  fs: TFileStream;
//begin
//  ZeroMemory(@fileHdr, SizeOf(fileHdr));
//  ZeroMemory(@infoHdr, SizeOf(infoHdr));
//    
//  fileHdr.bfType := $4d42; //'BM'
//  fileHdr.bfOffBits := sizeof(fileHdr) + sizeof(infoHdr);
//  fileHdr.bfSize := w * h * 4 + fileHdr.bfOffBits;
//
//  infoHdr.biSize := sizeof(BITMAPINFOHEADER);
//  infoHdr.biWidth := w;
//  infoHdr.biHeight := -h;
//  infoHdr.biPlanes := 1;
//  infoHdr.biBitCount := 32;
//  infoHdr.biCompression := 0;
//  infoHdr.biSizeImage := w * h * 4;
//  infoHdr.biXPelsPerMeter := 3780;
//  infoHdr.biYPelsPerMeter := 3780;
//
//  fs := TFileStream.Create(filename, fmCreate or fmOpenReadWrite);
//  try
//    fs.Write(fileHdr, SizeOf(fileHdr));
//    fs.Write(infoHdr, SizeOf(infoHdr));
//    fs.Write(pixels^, infoHdr.biSizeImage);
//  finally
//    fs.Free;
//  end;
//end;

procedure TActiveXBehavior.DoPaintUpdate;
  function _BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
  begin
    Dec(Alignment);
    Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result div 8;
  end;
var
  BufferDC: HDC;
  BitmapInfo: TBitmapInfo;
  BufferBitmap, OldBitmap: HBitmap;
  BufferBits: Pointer;
  w, h: Integer;
  rcItem, rcBuffer: TRect;
begin
  if rendering_site = nil then
    Exit;

  rcItem := This.GetLocation();
  w := rcItem.Right - rcItem.Left;
  h := rcItem.Bottom - rcItem.Top;
                                 
  if FSizeChanged then
  begin
    if rendering_site.IsAlive then
      rendering_site.StopStreaming;

    rendering_site.StartStreaming(w, h, COLOR_SPACE_RGB32);
    FSizeChanged := False;
  end;

  if (not IsIconic(m_hwndHost)) and IsWindowVisible(m_hwndHost) then
  begin
    if (w = 0) or (h = 0) then
      Exit;

    BufferDC := CreateCompatibleDC(0);
    try
      rcBuffer := Rect(0, 0, w, h);

      Fillchar(BitmapInfo, sizeof(BitmapInfo), #0);
      with BitmapInfo.bmiHeader do
      begin
        biSize     := SizeOf(TBitmapInfoHeader);
        biWidth    := w;
        biHeight   := -h;
        biPlanes   := 1;
        biBitCount := 32;
        biCompression := BI_RGB;
      end;
      BufferBitmap := CreateDIBSection(BufferDC, BitmapInfo, DIB_RGB_COLORS, BufferBits, 0, 0);
      try
        OldBitmap := SelectObject(BufferDC, BufferBitmap);
        try
          if IsInstall then
          begin
            if (m_activeXCtrl <> nil) and IsWindowless and (m_activeXCtrl.m_pViewObject <> nil) then
            begin
              DoPaintInstall(BufferDC, rcBuffer, BufferBits, h * w * 4);
            end;
          end
          else
          begin
            DoPaintNotInstall(BufferDC, rcBuffer, BufferBits, h * w * 4);
          end;
          rendering_site.RenderFrame(BufferBits, h * w * 4);
        finally
          SelectObject(BufferDC, OldBitmap);
        end;
      finally
        if BufferBitmap <> 0 then DeleteObject(BufferBitmap);
      end;
    finally
      if BufferDC <> 0 then
        DeleteDC(BufferDC);
    end;
  end;
end;

procedure TActiveXBehavior.DoVerb(iVerb: Integer);
var
  pOleClientSite: IOleClientSite;
begin
  if m_pUnk = nil then
    Exit;
  m_pUnk.DoVerb(iVerb, nil, pOleClientSite, 0, m_hwndHost, This.GetLocation(VIEW_RELATIVE or CONTENT_BOX));
end;

function TActiveXBehavior.GetClsid: TGUID;
begin
  Result := m_clsid;
end;

function TActiveXBehavior.IsInstall: Boolean;
begin
  Result := m_isInstall;
end;

function TActiveXBehavior.IsWindowless: Boolean;
begin
  Result := m_activeXCtrl.m_bWindowless;
end;

procedure TActiveXBehavior.OnAttached(const he: IDomElement);
var
  sBehavior: string;
begin
  AddBeforeWndProc;
  FSizeChanged := True;

  sBehavior := he.Style['behavior'];
  if Pos('video', sBehavior) = 0 then
  begin
    sBehavior :=  sBehavior + ' video';
    he.Style['behavior'] := sBehavior;
  end;
  if he.Style['image-rendering'] = '' then
    he.Style['image-rendering'] := 'optimize-speed';

  m_hwndHost := he.GetElementHwnd();
  m_sModuleName := he.Attributes['plugin'];
  if CompareMem(@m_clsid, @GUID_NULL, SizeOf(TGUID)) then
    m_clsid :=  StringToGUID(he.Attributes['clsid']);

  if not DoCreateControl() then
    Sciter.Trace('DoCreateControl Failed!');
end;

procedure TActiveXBehavior.OnDetached(const he: IDomElement);
begin
  if (rendering_site <> nil) then
  begin
    rendering_site.StopStreaming();
    rendering_site := nil;
  end;
  
  ReleaseControl;

  RemoveBeforeWndProc;
end;

function TActiveXBehavior.OnFocusGot(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  m_activeXCtrl.m_bFocused := True;
  if m_activeXCtrl.m_bUIActivated then DoVerb(OLEIVERB_UIACTIVATE);
  Result := True;
end;

function TActiveXBehavior.OnFocusLost(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  m_activeXCtrl.m_bFocused := False;
  Result := True;
end;

function TActiveXBehavior.OnMouseEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  m_MouseEnter := True;
end;

function TActiveXBehavior.OnMouseLeave(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  m_MouseEnter := False;
end;

procedure TActiveXBehavior.OnSize(const he: IDomElement);
var
  hmSize, pxSize: TSize;
  rcItem2, rcItem: TRect;
begin
  FSizeChanged := True;
  
  if not m_bCreated then
    DoCreateControl();

  if m_pUnk = nil then
    Exit;
  if m_pControl = nil then
    Exit;

  rcItem := he.GetLocation(VIEW_RELATIVE or CONTENT_BOX);
  if not IsWindowless then
  begin
    rcItem.Right := rcItem.Right - 1;
    rcItem.Bottom := rcItem.Bottom - 1;
  end;
  
  pxSize.cx := rcItem.right - rcItem.left;
  pxSize.cy := rcItem.bottom - rcItem.top;
  
  PixelToHiMetric(pxSize, hmSize);

  if m_pUnk <> nil then
  {$IFDEF WIN64}
    m_pUnk.SetExtent(DVASPECT_CONTENT, @TPoint(hmSize));
  {$ELSE}
    m_pUnk.SetExtent(DVASPECT_CONTENT, TPoint(hmSize));
  {$ENDIF}


  if m_activeXCtrl.m_pInPlaceObject <> nil then
  begin
    rcItem2 := rcItem;
    if not m_activeXCtrl.m_bWindowless then
      OffsetRect(rcItem2, -rcItem2.Left, -rcItem2.Top);
    m_activeXCtrl.m_pInPlaceObject.SetObjectRects(rcItem2, rcItem2);
  end;
end;

function TActiveXBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_ALL; // HANDLE_MOUSE or HANDLE_KEY or HANDLE_FOCUS or HANDLE_SIZE or HANDLE_BEHAVIOR_EVENT; // we only handle VIDEO_BIND_RQ here
  Result := True;  
end;

function TActiveXBehavior.OnVideoBindRQ(const he, target: IDomElement;
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

procedure TActiveXBehavior.ReleaseControl;
var
  pSite: IObjectWithSite;
begin
  m_hwndHost := 0;
  if m_pUnk <> nil then
  begin
    if Supports(m_pUnk, IObjectWithSite, pSite) then
    begin
      pSite.SetSite(nil);
      pSite := nil;
    end;

    m_pUnk.Close(OLECLOSE_NOSAVE);
    m_pUnk.SetClientSite(nil);
    m_pUnk := nil;
  end;
  if m_pControl <> nil then
  begin
    m_activeXCtrl.m_pOwner := nil;
    m_pControl := nil;
  end;
end;

procedure TActiveXBehavior.SetClsid(const Value: TGUID);
begin
  if CompareMem(@Value, @m_clsid, SizeOf(TGUID)) then
    Exit;
    
  m_clsid := Value;
  DoCreateControl();
end;

end.
