{*******************************************************************************
 标题:     ShadowUtils.pas
 描述:     为无边框窗口添加背景阴影
 创建时间：2015-02-07
 作者：    gxlmyaccgxlmyacc
 ******************************************************************************}
unit ShadowUtils;

interface

uses
  Windows, SysUtils, Classes{$IF CompilerVersion > 18.5}, Types{$IFEND};

type
  PColor = ^TColor;
  TColor = -$7FFFFFFF-1..$7FFFFFFF;
const
  clBlack = TColor($000000);
  clGray = TColor($808080);

  MaxShadowSize     = 30;
  DefaultShadowSize = 18;
type
  TStdWndProc = function (hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  
  TShadowWindow = class
  private
    FWnd: HWND;
    FParentWnd: HWND;
    FOriParentProc: TStdWndProc;
    FClientRect: TRect;
    FNeedResize: Boolean;
    FShadowSize: Integer;
    FShadowColor: TColor;
    FRoundSize: Integer;
    procedure SetShadowSize(const Value: Integer);
  protected
    procedure DrawShadow;
  protected
    function DoCreate(msg: UINT; wParam: WPARAM; lParam: LPARAM; var bHandled: Boolean): LRESULT; stdcall;
    function DoDestory(msg: UINT; wParam: WPARAM; lParam: LPARAM; var bHandled: Boolean): LRESULT; stdcall;
  public
    constructor Create(wndParent: HWND; shadowColor: TColor; RoundSize, ShadowSize: Integer);
    destructor Destroy; override;

    procedure AdjustWindowPos;

    property Wnd: HWND read FWnd;
    property ParentWnd: HWND read FParentWnd;
    property ShadowSize: Integer read FShadowSize write SetShadowSize;
    property ShadowColor: TColor read FShadowColor write FShadowColor;
    property RoundSize: Integer read FRoundSize write FRoundSize;
  end;

function HasShadow(const hWnd: HWND): TShadowWindow;
function SetupShadow(const hWnd: HWND; shadowColor: TColor = clGray;
  RoundSize: Integer = 0; ShadowSize: Integer = DefaultShadowSize): TShadowWindow;

implementation

const
  WM_CREATE           = $0001;
  WM_DESTROY          = $0002;
  WM_MOVE             = $0003;
  WM_SIZE             = $0005;
  WM_ACTIVATE         = $0006;
  WM_KILLFOCUS        = $0008;
  WM_SHOWWINDOW       = $0018;
  WM_NCDESTROY        = $0082;

  SHADOW_WINDOW_CLASS_NAME = 'ShadowWindow-0D4E5415F652';

function HasShadow(const hWnd: HWND): TShadowWindow;
begin
  Result := TShadowWindow(GetProp(hWnd, SHADOW_WINDOW_CLASS_NAME));
end;

function SetupShadow(const hWnd: HWND; shadowColor: TColor; RoundSize, ShadowSize: Integer): TShadowWindow;
begin
  Result := TShadowWindow.Create(hWnd, shadowColor, RoundSize, ShadowSize);
  if IsWindowVisible(hWnd) then
    Result.AdjustWindowPos;
end;

function _wnd_proc(hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pThis: TShadowWindow;
  bHandled: Boolean;
begin
  Result := 0;
  if msg = WM_CREATE then
  begin
    pThis :=  TShadowWindow(PCreateStructW(lParam).lpCreateParams);
    pThis.FWnd := hWnd;
    SetWindowLongW(hWnd, GWL_USERDATA, Integer(pThis));
  end
  else
    pThis := TShadowWindow(GetWindowLongW(hWnd, GWL_USERDATA));
  if pThis = nil then
  begin
    Result := DefWindowProcW(hWnd, Msg, wParam, lParam);
    Exit;
  end;
  bHandled := False;
  case msg of
    WM_CREATE:  Result := pThis.DoCreate(msg, wParam, lParam, bHandled);
    WM_DESTROY: Result := pThis.DoDestory(msg, wParam, lParam, bHandled);
  end;
  if bHandled then Exit;
  Result := DefWindowProcW(hWnd, Msg, wParam, lParam);
end;

function ParentProc(hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pThis: TShadowWindow;
  pDefProc: TStdWndProc;
begin
  pThis := TShadowWindow(GetPropW(hWnd, SHADOW_WINDOW_CLASS_NAME));
  Assert( pThis <> nil );
  pDefProc := pThis.FOriParentProc;
  case msg of
    WM_MOVE, WM_ACTIVATE:
    begin
      if IsWindowVisible(hwnd) and (not IsZoomed(hwnd)) then
        pThis.AdjustWindowPos();
    end;
    WM_KILLFOCUS:
    begin
      if Windows.HWND(wParam) = pThis.FWnd then
      begin
        SetForegroundWindow(hWnd);
        Result := 0;
        Exit;
      end;
    end;
    WM_NCDESTROY:
    begin
      pThis.Free;
    end;
    WM_SHOWWINDOW:
    begin
      if wParam = 0 then
        ShowWindow(pThis.FWnd, SW_HIDE)
      else
      begin
        ShowWindow(pThis.FWnd, SW_SHOWNOACTIVATE);
        pThis.AdjustWindowPos;
      end;
    end;
    WM_SIZE:
    begin
      if (wParam = SIZE_MINIMIZED) or (wParam = SIZE_MAXIMIZED) then
        ShowWindow(pThis.FWnd, SW_HIDE)
      else
      if (wParam = SIZE_RESTORED) then
        ShowWindow(pThis.FWnd, SW_SHOWNOACTIVATE);
      if IsWindowVisible(hwnd) and (not IsZoomed(hwnd)) then
        pThis.AdjustWindowPos;
    end;
  end;
  Result := pDefProc(hwnd, msg, wParam, lParam);
end;

var
  varWndCls: Word = 0;
procedure InitWindowClass;
var
  wcex: TWndClassExW;
begin
  if varWndCls <> 0 then
    Exit;
  wcex.cbSize         := SizeOf(wcex);
  wcex.style			    := CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS;
  wcex.lpfnWndProc	  := @_wnd_proc;
  wcex.cbClsExtra		  := 0;
  wcex.cbWndExtra		  := 0;
  wcex.hInstance		  := HInstance;
  wcex.hIcon		      := 0;
  wcex.hCursor		    := 0;
  wcex.hbrBackground  := 0;
  wcex.lpszMenuName	  := nil;
  wcex.lpszClassName  := SHADOW_WINDOW_CLASS_NAME;
  wcex.hIconSm		    := 0;
  varWndCls := RegisterClassExW(wcex);
  Assert(varWndCls <> 0);
end;

procedure FinalWindowClass;
begin
  if varWndCls = 0 then Exit;
  Windows.UnregisterClassW(SHADOW_WINDOW_CLASS_NAME, HInstance);
  varWndCls := 0;
end;

function GetWindowText(hWnd: HWND): WideString;
var
  len: Cardinal;
begin
  SetLength(Result, MAX_PATH);
  len := Windows.GetWindowTextW(hWnd, PWideChar(Result), MAX_PATH);
  SetLength(Result, len);
end;

{ TShadowWindow }

procedure TShadowWindow.AdjustWindowPos;
var
  rcParent, rcClient: TRect;
begin
  GetWindowRect(FParentWnd, rcParent);
  InflateRect(rcParent, FShadowSize, FShadowSize);
  SetWindowPos(FWnd, FParentWnd, rcParent.left, rcParent.top,
    rcParent.right-rcParent.left, rcParent.bottom-rcParent.top, SWP_NOACTIVATE);
    
  GetClientRect(FWnd, rcClient);
  FNeedResize := not EqualRect(rcClient, FClientRect);
  if FNeedResize then
  begin
    FClientRect := rcClient;
    FNeedResize := False;
    DrawShadow;
  end;
end;

constructor TShadowWindow.Create(wndParent: HWND; shadowColor: TColor; RoundSize, ShadowSize: Integer);
var
  rc: TRect;
  dwStyle, dwStyleEx: Cardinal;
begin
  InitWindowClass;
  Assert(IsWindow(wndParent));
  Assert(HasShadow(wndParent) = nil);
  FParentWnd	   := wndParent;
  FOriParentProc := nil;
  FShadowSize	   := ShadowSize;
  FNeedResize		 := False;
  FShadowColor   := ShadowColor;
  FRoundSize     := RoundSize;

  rc.Left := 1;
  rc.Right := 1;
  rc.Top := 1;
  rc.Bottom := 1;
  dwStyle := WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
  dwStyleEx := WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE or WS_EX_LAYERED or WS_EX_TRANSPARENT;
  CreateWindowExW(dwStyleEx, SHADOW_WINDOW_CLASS_NAME, PWideChar(GetWindowText(FParentWnd) + '_shadow'),
    dwStyle, rc.Left, rc.Top, rc.Right-rc.Left, rc.Bottom-rc.Top, wndParent, 0, HInstance, Self);
  Assert(FWnd<>0, SysErrorMessage(GetLastError));
end;

destructor TShadowWindow.Destroy;
begin
  if FWnd <> 0 then
    DestroyWindow(FWnd);
  inherited;
end;

function TShadowWindow.DoCreate(msg: UINT; wParam: WPARAM; lParam: LPARAM; var bHandled: Boolean): LRESULT;
begin
  SetWindowLong(FWnd, GWL_STYLE, GetWindowLong(FWnd, GWL_STYLE) and (not (WS_MAXIMIZEBOX or WS_SIZEBOX or WS_CAPTION or WS_DLGFRAME)));
  if IsWindowUnicode(FParentWnd) then
  begin
    SetPropW(FParentWnd, SHADOW_WINDOW_CLASS_NAME, Cardinal(Self));
    FOriParentProc := TStdWndProc(GetWindowLongW(FParentWnd, GWL_WNDPROC));
    SetWindowLongW(FParentWnd, GWL_WNDPROC, Integer(@ParentProc));
  end
  else
  begin
    SetPropA(FParentWnd, SHADOW_WINDOW_CLASS_NAME, Cardinal(Self));
    FOriParentProc := TStdWndProc(GetWindowLongA(FParentWnd, GWL_WNDPROC));
    SetWindowLongA(FParentWnd, GWL_WNDPROC, Integer(@ParentProc));
  end;
  Result := 0;
end;

function TShadowWindow.DoDestory(msg: UINT; wParam: WPARAM; lParam: LPARAM; var bHandled: Boolean): LRESULT;
begin
  if IsWindow(FParentWnd) and (@FOriParentProc <> nil) then
  begin
    if IsWindowUnicode(FParentWnd) then
    begin
      SetWindowLongW(FParentWnd, GWL_WNDPROC, Integer(@FOriParentProc));
      RemovePropW(FParentWnd, SHADOW_WINDOW_CLASS_NAME);
    end
    else
    begin
      SetWindowLongA(FParentWnd, GWL_WNDPROC, Integer(@FOriParentProc));
      RemovePropA(FParentWnd, SHADOW_WINDOW_CLASS_NAME);
    end;
  end;
  FWnd := 0;
  Result := 0;
end;

procedure TShadowWindow.DrawShadow;
type
  TColor32 = packed record
    b, g, r, a: Byte;
  end;
  PColor32 = ^TColor32;

  function Power2(const value: Extended): Extended;
  begin
    if value >= 1 then
      Result := 1
    else
      Result := value * value;
  end;
  function _CalcSideAlphaValue(const side, ShadowSize: Integer; const LastResult: Double): Double;
  begin
    Result := Power2(side / ShadowSize) * LastResult;
  end;
  function _CalcAlphaValue(const w, h: Integer; const rcParent: TRect; rgnParent: PRgnData; const pt: TPoint; ShadowSize: Integer): Byte;
  var
    bPtFind: Boolean;
    rc: PRect;
    i: Integer;
    dResult: Double;
  begin
    if rgnParent = nil then
      bPtFind := PtInRect(rcParent, pt)
    else
    begin
      bPtFind := False;
      rc := @rgnParent.Buffer;
      for i := 0 to rgnParent.rdh.nCount - 1 do
      begin
        bPtFind := PtInRect(rc^, pt);
        if bPtFind then Break;
        Inc(rc);
      end;
    end;
    if bPtFind then
    begin
      Result := 0;
      Exit;
    end;
    dResult := 255;
    if pt.X <= ShadowSize then
      dResult := _CalcSideAlphaValue(pt.X, ShadowSize, dResult);
    if pt.Y <= ShadowSize then
      dResult := _CalcSideAlphaValue(pt.Y, ShadowSize, dResult);
    if pt.X >= (w - ShadowSize) then
      dResult := _CalcSideAlphaValue(w-pt.X, ShadowSize, dResult);
    if pt.Y >= (h - ShadowSize) then
      dResult := _CalcSideAlphaValue(h-pt.Y, ShadowSize, dResult);
    Result := Round(dResult);
  end;
  
  function _BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
  begin
    Dec(Alignment);
    Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result div 8;
  end;
  procedure _BlendDraw(hwnd: HWND; dc: HDC; w, h: Integer);
  var
    bf: TBlendFunction;
    rcWindow: TRect;
    pt, ptSource: TPoint;
    sz: TSize;
  begin
    bf.BlendOp := AC_SRC_OVER;
    bf.BlendFlags := 0;
    bf.SourceConstantAlpha := 160;
    bf.AlphaFormat := AC_SRC_ALPHA;

    GetWindowRect(hwnd, rcWindow);
    pt := Point(rcWindow.left, rcWindow.top);
    ptSource := Point(0, 0);
    sz.cx := w;
    sz.cy := h;
    UpdateLayeredWindow(hwnd, 0, @pt, @sz, dc, @ptSource, 0, @bf, ULW_ALPHA);
  end;
var
  x, y, w, h, iShadowSize, iRow: Integer;
  dstClr: PColor32;
  pt: TPoint;
  BufferDC: HDC;
  rcParent: TRect;
  rgnParent: HRGN;
  rgnParentData: PRgnData;
  bi: TBitmapInfo;
  BufferBitmap, OldBitmap: HBitmap;
  BufferBits: Pointer;
  dwRgnDataSize: Cardinal;
  br: HBRUSH;
begin
  GetClientRect(FParentWnd, rcParent);
  rgnParentData := nil;
  rgnParent := 0;
  if FRoundSize > 0 then
    rgnParent := CreateRoundRectRGN(0, 0, rcParent.Right+1, rcParent.Bottom+1, FRoundSize, FRoundSize);
  try
    OffsetRect(rcParent, FShadowSize, FShadowSize);
    if rgnParent <> 0 then
    begin
      OffsetRgn(rgnParent, FShadowSize, FShadowSize);
      dwRgnDataSize := GetRegionData(rgnParent, 0, nil);
      rgnParentData := GetMemory(dwRgnDataSize);
      GetRegionData(rgnParent, dwRgnDataSize, rgnParentData);
    end;

    w := FClientRect.Right - FClientRect.Left;
    h := FClientRect.Bottom - FClientRect.Top;
    iShadowSize := MaxShadowSize;
    if iShadowSize * 2 > w then iShadowSize := w div 2;
    if iShadowSize * 2 > h then iShadowSize := h div 2;

    BufferDC := CreateCompatibleDC(0);
    try
      ZeroMemory(@bi, sizeof(bi));
      with bi.bmiHeader do
      begin
        biSize     := SizeOf(TBitmapInfoHeader);
        biWidth    := w;
        biHeight   := h;
        biPlanes   := 1;
        biBitCount := 32;
        biCompression := BI_RGB;
      end;
      BufferBitmap := CreateDIBSection(BufferDC, bi, DIB_RGB_COLORS, BufferBits, 0, 0);
      try
        OldBitmap := SelectObject(BufferDC, BufferBitmap);
        br := CreateSolidBrush(FShadowColor);
        try
          FillRect(BufferDC, Rect(0, 0, w, h), br);
          for y := 0 to h - 1 do
          begin
            iRow := y;
            if bi.bmiHeader.biHeight > 0 then  
              iRow := bi.bmiHeader.biHeight - y - 1;
            PAnsiChar(dstClr) := PAnsiChar(BufferBits) + iRow * _BytesPerScanline(bi.bmiHeader.biWidth, bi.bmiHeader.biBitCount, 32);
            for x := 0 to w - 1 do
            begin
              pt := Point(x, y);
              dstClr^.a := _CalcAlphaValue(w, h, rcParent, rgnParentData, pt, iShadowSize);
              dstClr^.r := Round(dstClr^.r * dstClr^.a / 255);
              dstClr^.g := Round(dstClr^.g * dstClr^.a / 255);
              dstClr^.b := Round(dstClr^.b * dstClr^.a / 255);
              Inc(dstClr);
            end;
          end;
          _BlendDraw(FWnd, BufferDC, w, h);
        finally
          DeleteObject(br);
          SelectObject(BufferDC, OldBitmap);
        end;
      finally
        DeleteObject(BufferBitmap);
      end;
    finally
      DeleteDC(BufferDC);
    end;
  finally
    if rgnParentData <> nil then
      FreeMemory(rgnParentData);
    if rgnParent <> 0 then
      DeleteObject(rgnParent);
  end;
end;

procedure TShadowWindow.SetShadowSize(const Value: Integer);
begin
  if FShadowSize = Value then Exit;
  if (Value <= 0) or (Value > MaxShadowSize) then
    FShadowSize := DefaultShadowSize
  else
    FShadowSize := Value;
  AdjustWindowPos;
end;

initialization
finalization
  FinalWindowClass;
end.
