{*******************************************************************************
 标题:     SciterCtl.pas
 描述:     对Sciter封装的WinControl控件
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterCtl;

interface

uses
  SysUtils, Classes, Windows, Controls, SciterIntf, Messages, SciterTypes;

type
  TSciterControl = class(TWinControl, ISciterBase)
  private
    FLayout: ISciterLayout;
    FOnHandleCreated: TNotifyEvent;
  protected
    function GetLayout: ISciterLayout;
    function GetWindowName: SciterString;
    function GetHwnd: HWINDOW;
    function GetResourceInstance: HMODULE;
    
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure MouseWheelHandler(var Message: TMessage); override;

    function DesignMode: Boolean;
    procedure UpdateWindow;

    property Layout: ISciterLayout read GetLayout;
  published
    property Action;
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property OnClick;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnHandleCreated: TNotifyEvent read FOnHandleCreated write FOnHandleCreated;
  end;

implementation

uses
  SciterFactoryIntf;

function OleInitialize(pwReserved: Pointer): HResult; stdcall; external 'ole32.dll' name 'OleInitialize';
procedure OleUninitialize; stdcall; external 'ole32.dll' name 'OleUninitialize';

{ TSciterControl }

function TSciterControl.GetLayout: ISciterLayout;
begin
  if FLayout = nil then
    FLayout := LayoutFactory.Create(Self);

  Result := FLayout;
end;

function TSciterControl.GetHwnd: HWINDOW;
begin
  Result := Handle;
end;

function TSciterControl.GetResourceInstance: HMODULE;
begin
  Result := SysInit.HInstance;
end;

procedure TSciterControl.WndProc(var Message: TMessage);
var
  bHandled: Boolean;
  M: PMsg;
begin
  if (FLayout = nil) and (not (csDestroying in ComponentState)) then
  begin
    FLayout := LayoutFactory.Create(Self);
  end;

  if HandleAllocated and (FLayout <> nil) then
  begin
    if Message.Msg = WM_GETDLGCODE then
    begin
      Message.Result := DLGC_WANTALLKEYS or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
      if TabStop then
        Message.Result := Message.Result or DLGC_WANTTAB;
      if Message.lParam <> 0 then
      begin
        M := PMsg(Message.lParam);
        case M.Message of
          WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR,
          WM_KEYDOWN, WM_KEYUP, WM_CHAR:
          begin
            Perform(M.message, M.wParam, M.lParam);
          end;
        end;
      end;
      Exit;
    end;
    try
      bHandled := False;
      Message.Result := FLayout.ProcND(WindowHandle, Message.Msg, Message.WParam, Message.LParam, bHandled);
      if bHandled then
        Exit;

      if (Message.Msg = WM_DESTROY) and (csDestroying in ComponentState) then
        FLayout := nil;
    except
      on E: Exception do
        OutputDebugString(PChar('[TSciterControl.WndProc]['+IntToStr(Message.Msg)+']'+E.Message));
    end;
  end;
  inherited WndProc(Message);
end;

constructor TSciterControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csDoubleClicks, csReplicatable];

  TabStop := True;
  ParentFont := False;
end;

procedure TSciterControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CHILD or WS_VISIBLE;
  if TabStop then
    Params.Style := Params.Style or WS_TABSTOP;
  Params.ExStyle := Params.ExStyle or WS_EX_CONTROLPARENT;
end;

procedure TSciterControl.CreateWnd;
begin
  inherited CreateWnd;
  if DesignMode then
    Exit;
  DoubleBuffered := True;

  if FLayout = nil then
    FLayout := LayoutFactory.Create(Self);

  if HandleAllocated and (FLayout <> nil) then
    FLayout.Setup;
  if Assigned(FOnHandleCreated) then
    FOnHandleCreated(Self);
end;

destructor TSciterControl.Destroy;
var
  pbHandled: Boolean;
begin
  if FLayout <> nil then
  begin
    if IsWindow(WindowHandle) then
      FLayout.ProcND(WindowHandle, WM_DESTROY, 0, 0, pbHandled);
    FLayout := nil;
  end;
  inherited;
end;

procedure TSciterControl.DestroyWnd;
var
  pbHandled: Boolean;
begin
  if (FLayout <> nil) and (not DesignMode) then
  begin
    if IsWindow(WindowHandle) then
      FLayout.ProcND(WindowHandle, WM_DESTROY, 0, 0, pbHandled);
    FLayout := nil;
  end;
  inherited;
end;

function TSciterControl.DesignMode: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

procedure TSciterControl.MouseWheelHandler(var Message: TMessage);
var
  pMsg: TWMMouseWheel;
begin
  pMsg := TWMMouseWheel(Message);
  if pMsg.WheelDelta < 0 then
    Perform(WM_VSCROLL, 1, 0)
  else
    Perform(WM_VSCROLL, 0, 0);
end;

procedure TSciterControl.UpdateWindow;
begin
  if FLayout <> nil then
    FLayout.UpdateWindow;
end;

function TSciterControl.GetWindowName: SciterString;
begin
  Result := Self.Name;
end;

initialization
  OleInitialize(nil);
finalization
  OleUninitialize;

end.
