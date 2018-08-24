{*******************************************************************************
 标题:     RoundUtils.pas
 描述:     为无边框窗口添加窗口圆角
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit RoundUtils;

interface

uses
  Windows;

type
  TStdWndProc = function (hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
  
  TRoundWindow = class
  private
    FOriParentProc: TStdWndProc;
    FWnd: HWND;
    FRY: Integer;
    FRX: Integer;
    FClientRect: TRect;
  public
    constructor Create(Wnd: HWND; rx, ry: Integer);
    destructor Destroy; override;
    procedure Restore;
    procedure Invalidate;
    property Wnd: HWND read FWnd;
    property RX: Integer read FRX;
    property RY: Integer read FRY;
    property ClientRect: TRect read FClientRect;
  end;

function HasRound(hWnd: HWND): TRoundWindow;
function RoundWindow(hWnd: HWND; rx, ry: Integer): TRoundWindow;

implementation

const
  ROUNDWINDOW_PROP = 'ROUNDWINDOW-2B259C3AA1E5';
const
  WM_SIZE             = $0005;
  WM_SHOWWINDOW       = $0018;
  WM_NCDESTROY        = $0082;
  WM_NCACTIVATE       = $0086;

function HasRound(hWnd: HWND): TRoundWindow;
begin
  Result := TRoundWindow(GetProp(hWnd, ROUNDWINDOW_PROP));
end;

function RoundWindow(hWnd: HWND; rx, ry: Integer): TRoundWindow;
begin
  Result := nil;
  if HasRound(hWnd) <> nil then
    Exit;
  Result := TRoundWindow.Create(hWnd, rx, ry);
end;

function _WndProc(hWnd: HWND; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  pThis: TRoundWindow;
  pDefProc: TStdWndProc;
begin
  pThis := TRoundWindow(GetProp(hWnd, ROUNDWINDOW_PROP));
  Assert( pThis <> nil );
  pDefProc := pThis.FOriParentProc;
  case msg of
    WM_NCDESTROY:
    begin
      pThis.Free;
    end;
    WM_SHOWWINDOW:
    begin
      if wParam <> 0 then
        pThis.Invalidate;
    end;
    WM_SIZE:
    begin    
      if (wParam = SIZE_MAXIMIZED) then
        pThis.Restore
      else
      if (wParam = SIZE_RESTORED) then
        pThis.Invalidate();       
    end;
  end;
  Result := pDefProc(hwnd, msg, wParam, lParam);
end;

{ TRoundWindow }

constructor TRoundWindow.Create(Wnd: HWND; rx, ry: Integer);
begin
  Assert(IsWindow(Wnd));
  FWnd := Wnd;
  FRX := rx;
  FRY := ry;
  if IsWindowUnicode(FWnd) then
  begin
    SetPropW(FWnd, ROUNDWINDOW_PROP, Cardinal(Self));
    FOriParentProc := TStdWndProc(GetWindowLongW(FWnd, GWL_WNDPROC));
    SetWindowLongW(FWnd, GWL_WNDPROC, Integer(@_WndProc));
  end
  else
  begin
    SetPropA(FWnd, ROUNDWINDOW_PROP, Cardinal(Self));
    FOriParentProc := TStdWndProc(GetWindowLongA(FWnd, GWL_WNDPROC));
    SetWindowLongA(FWnd, GWL_WNDPROC, Integer(@_WndProc));
  end;
end;

destructor TRoundWindow.Destroy;
begin
  if IsWindow(FWnd) then
  begin
    if IsWindowUnicode(FWnd) then
    begin
      SetWindowLongW(FWnd, GWL_WNDPROC, Integer(@FOriParentProc));
      RemovePropW(FWnd, ROUNDWINDOW_PROP);
    end
    else
    begin
      SetWindowLongA(FWnd, GWL_WNDPROC, Integer(@FOriParentProc));
      RemovePropA(FWnd, ROUNDWINDOW_PROP);
    end;
  end;
  inherited;
end;

procedure TRoundWindow.Invalidate;
var
  rgn: HRGN;
  rcClient: TRect;
begin
  GetClientRect(FWnd, rcClient);
  if EqualRect(rcClient, FClientRect) then Exit;
  FClientRect := rcClient;
  rgn := CreateRoundRectRGN(0, 0, FClientRect.Right+1, FClientRect.Bottom+1, FRX, FRY);
  try
    SetWindowRGN(FWnd, rgn, True);
  finally
    DeleteObject(rgn);
  end;
end;

procedure TRoundWindow.Restore;
var
  rgn: HRGN;
  rcClient: TRect;
begin
  GetClientRect(FWnd, rcClient);
  if EqualRect(rcClient, FClientRect) then Exit;
  FClientRect := rcClient;
  rgn := CreateRoundRectRGN(0, 0, FClientRect.Right+1, FClientRect.Bottom+1, 0, 0);
  try
    SetWindowRGN(FWnd, rgn, True);
  finally
    DeleteObject(rgn);
  end;
end;

end.
