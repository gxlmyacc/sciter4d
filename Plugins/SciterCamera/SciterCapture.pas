unit SciterCapture; 

interface

uses
  Windows, Classes, ActiveX, vfw, SciterTypes, SciterIntf, Controls, Messages;

type
  TMyEvent = procedure(Sender: TObject; Button: TMouseButton;
    X, Y: Integer) of object;

type
  TCapture = class
  private
    FOwner: TWinControl;
    FCaphwnd: HWND;
    FWidth: Integer;
    FHeight: Integer;
    FScale: boolean;
    FIsRecording: boolean;
    FPreWndProc: LongInt;
    FLastClickTick: Cardinal;
    FxPos: Integer;
    FyPos: Integer;
    FDblClick: TNotifyEvent;
    FMouseMove: TMyEvent;
    FMouseDown: TMyEvent;
    FMouseUp: TMyEvent;
    procedure DblClick;
    procedure MouseMove(Button: TMouseButton; X, Y: Integer);
    procedure MouseDown(Button: TMouseButton; X, Y: Integer);
    procedure MouseUp(Button: TMouseButton; X, Y: Integer);
    procedure SetWidth(w: Integer);
    procedure SetHeight(h: Integer);
    procedure SetScale(s: boolean);
  public
    constructor Create(Owner: TWinControl);
    destructor Destory;
    procedure CapWndProc(var Message: TMessage);
    function GetCapDevice(list: TStrings): Integer;
    function CapOpen(DriveID: Integer = 0): boolean;
    function CapClose: boolean;
    function CapDlgVideoSource: boolean;
    function CapDlgVideoFormat: boolean;
    function CapDlgVideoDisplay: boolean;
    function CapDlgVideoCompression: boolean;
    function CapFileSaveDIB(FileName: string): boolean;
    procedure CapStartRecord(FileName: string; Minsize: Integer = 1048576);
    procedure CapStopRecord;
  published
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Scale: boolean read FScale write SetScale;
    property IsRecording: boolean read FIsRecording;
    property Handle: HWND read FCaphwnd;
    property OnMouseMove: TMyEvent read FMouseMove write FMouseMove;
    property OnMouseDown: TMyEvent read FMouseDown write FMouseDown;
    property OnMouseUp: TMyEvent read FMouseUp write FMouseUp;
    property OnDblClick: TNotifyEvent read FDblClick write FDblClick;
  end;

implementation

{ TCapture }

constructor TCapture.Create(Owner: TWinControl);
begin
  FCaphwnd := capCreateCaptureWindow(
    'MyCapture', WS_CHILD or WS_VISIBLE,
    0, 0, 0, 0, Owner.Handle, 1);
  FScale := false;
  FIsRecording := false;
  FOwner := Owner;
  FPreWndProc := GetWindowLong(FCaphwnd, GWL_WNDPROC);
  SetWindowLong(FCaphwnd, GWL_WNDPROC, Longint(MakeObjectInstance(CapWndProc)));
end;

destructor TCapture.Destory;
begin
  CapClose;
  CapStopRecord;
  DestroyWindow(FCaphwnd);
end;

function TCapture.CapOpen(DriveID: Integer = 0): boolean;
var
  CapStatus: TCapStatus;
begin
  Result := capDriverConnect(FCaphwnd, DriveID);
  capGetStatus(FCaphwnd, @CapStatus, sizeof(CAPSTATUS));
  FWidth := CapStatus.uiImageWidth;
  FHeight := CapStatus.uiImageHeight;
  SetWindowPos(FCaphwnd, 0, 0, 0, FWidth, FHeight, SWP_NOZORDER or SWP_NOMOVE);

  capPreviewRate(FCaphwnd, 66); //set preview rate to 66 miliseconds

  vfw.capOverlay(FCaphwnd, true);
  capPreview(FCaphwnd, true);
  capPreviewScale(FCaphwnd, FScale);
end;

function TCapture.CapClose: boolean;
begin
  Result := capDriverDisconnect(FCaphwnd);
  SetWindowPos(FCaphwnd, 0, 0, 0, 0, 0, SWP_NOZORDER or SWP_NOMOVE);
end;

function TCapture.CapDlgVideoCompression: boolean;
begin
  Result := vfw.capDlgVideoCompression(FCaphwnd);
end;

function TCapture.CapDlgVideoDisplay: boolean;
begin
  Result := vfw.capDlgVideoDisplay(FCaphwnd);
end;

function TCapture.capDlgVideoFormat: boolean;
var
  CapStatus: TCapStatus;
begin
  Result := vfw.capDlgVideoFormat(FCaphwnd);
  capPreview(FCaphwnd, false);
  capGetStatus(FCaphwnd, @CapStatus, sizeof(CAPSTATUS));
  FWidth := CapStatus.uiImageWidth;
  FHeight := CapStatus.uiImageHeight;
  SetWindowPos(FCaphwnd, 0, 0, 0, FWidth, FHeight, SWP_NOZORDER or SWP_NOMOVE);
  capPreview(FCaphwnd, true);
end;

function TCapture.CapDlgVideoSource: boolean;
begin
  Result := vfw.capDlgVideoSource(FCaphwnd);
end;

function TCapture.GetCapDevice(list: TStrings): Integer;
var
  wDriverIndex: Integer;
  szDeviceName: array[0..80] of char;
  szDeviceVersion: array[0..80] of char;
begin
  wDriverIndex := 0;
  while capGetDriverDescription(wDriverIndex, szDeviceName, sizeof(szDeviceName),
    szDeviceVersion, sizeof(szDeviceVersion)) do
  begin
    list.Add(szDeviceName + szDeviceVersion);
    Inc(wDriverIndex);
  end;
  Result := wDriverIndex; //返回可用摄像头设备数
end;

procedure TCapture.SetHeight(h: Integer);
begin
  if FScale then
  begin
    FHeight := h;
    SetWindowPos(FCaphwnd, 0, 0, 0, FWidth, FHeight, SWP_NOZORDER or SWP_NOMOVE);
  end;
end;

procedure TCapture.SetWidth(w: Integer);
begin
  if FScale then
  begin
    FWidth := w;
    SetWindowPos(FCaphwnd, 0, 0, 0, FWidth, FHeight, SWP_NOZORDER or SWP_NOMOVE);
  end;
end;

procedure TCapture.SetScale(s: boolean);
begin
  capPreviewScale(FCaphwnd, s);
  FScale := s;
  if FScale then
    SetWindowPos(FCaphwnd, 0, 0, 0, FOwner.Width, FOwner.Height, SWP_NOZORDER or SWP_NOMOVE);
end;

procedure TCapture.CapStartRecord(FileName: string; Minsize: Integer = 1048576);
begin
  capFileSetCaptureFile(FCaphwnd, PChar(FileName));
  capFileAlloc(FCaphwnd, Minsize);
  capCaptureSequence(FCaphwnd);
  FIsRecording := true;
end;

procedure TCapture.CapStopRecord;
begin
  if FIsRecording then
  begin
    capCaptureStop(FCaphwnd);
    FIsRecording := false;
  end;
end;

function TCapture.CapFileSaveDIB(FileName: string): boolean;
begin
  Result := vfw.CapFileSaveDIB(FCaphwnd, PChar(FileName));
end;

procedure TCapture.CapWndProc(var Message: TMessage);
var
  rect: TRect;
begin
  case Message.Msg of
    WM_SETCURSOR:
      begin
        case HIWORD(Message.LParam) of
          WM_LBUTTONDOWN:
            begin
              if GetTickCount - FLastClickTick > 400 then
              begin
                MouseDown(mbLeft, FxPos, FyPos);
                FLastClickTick := GetTickCount;
              end
              else
              begin
                DblClick;
                FLastClickTick := 0;
              end;
            end;
          WM_RBUTTONDOWN:
            begin
              if GetTickCount - FLastClickTick > 400 then
              begin
                MouseDown(mbRight, FxPos, FyPos);
                FLastClickTick := GetTickCount;
              end
              else
              begin
                DblClick;
                FLastClickTick := 0;
              end;
            end;
          WM_LBUTTONUP: MouseUp(mbLeft, FxPos, FyPos);
          WM_RBUTTONUP: MouseUp(mbRight, FxPos, FyPos);
          WM_MOUSEMOVE: MouseMove(mbLeft, FxPos, FyPos);
        end;
      end;
    WM_NCHITTEST:
      begin
        GetWindowRect(FCaphwnd, rect);
        FxPos := LOWORD(Message.LParam) - rect.Left;
        FyPos := HIWORD(Message.LParam) - rect.Top;
      end;
  else
    CallWindowProc(Pointer(FPreWndProc), FCaphwnd, Message.Msg, Message.wParam, Message.lParam);
  end;

end;

procedure TCapture.DblClick;
begin
  if Assigned(FDblClick) then
    FDblClick(Self);
end;

procedure TCapture.MouseDown(Button: TMouseButton; X, Y: Integer);
begin
  if Assigned(FMouseDown) then
    FMouseDown(Self, Button, X, Y);
end;

procedure TCapture.MouseMove(Button: TMouseButton; X, Y: Integer);
begin
  if Assigned(FMouseMove) then
    FMouseMove(Self, Button, X, Y);
end;

procedure TCapture.MouseUp(Button: TMouseButton; X, Y: Integer);
begin
  if Assigned(FMouseUp) then
    FMouseUp(Self, Button, X, Y);
end;
end.

