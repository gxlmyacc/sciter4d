{*******************************************************************************
 标题:     SciterFrm.pas
 描述:     对Sciter封装的弹出窗口单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterFrm;

interface

uses
  Windows, Messages, Classes, Controls, Forms, SciterIntf, SciterTypes;

type
  TSciterForm = class(TForm, ISciterBase)
  private
    FLayout: ISciterLayout;
    FOnHandleCreated: TNotifyEvent;
  protected
    function  GetWindowName: SciterString;
    function  GetHwnd: HWINDOW;
    function  GetResourceInstance: HMODULE;
    function  GetLayout: PISciterLayout; virtual;
    function  GetBehavior: IDefalutBehaviorEventHandler; virtual;
    procedure SetBehavior(const Value: IDefalutBehaviorEventHandler); virtual;
  protected
    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;

    procedure DoWndProc(var Msg: TMessage; var Handled: Boolean); virtual;
    procedure DefWndProc(var Msg: TMessage); virtual;

    procedure WndProc(var Message: TMessage); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
  public
    destructor Destroy; override;

    procedure MouseWheelHandler(var Message: TMessage); override;

    function LoadHtmlFile(const uri: SciterString): Boolean;
    function LoadHtml(const pb: LPCBYTE; cb: UINT; const uri: SciterString = ''): Boolean;

    property Layout: PISciterLayout read GetLayout;
    property Behavior: IDefalutBehaviorEventHandler read GetBehavior write SetBehavior;

    property OnHandleCreated: TNotifyEvent read FOnHandleCreated write FOnHandleCreated;
  end;

implementation

{$R *.dfm}

uses
  SciterFactoryIntf;

function OleInitialize(pwReserved: Pointer): HResult; stdcall; external 'ole32.dll' name 'OleInitialize';
procedure OleUninitialize; stdcall; external 'ole32.dll' name 'OleUninitialize';

{ TSciterForm }

function TSciterForm.GetHwnd: HWINDOW;
begin
  Result := Self.Handle;
end;

function TSciterForm.GetResourceInstance: HMODULE;
begin
  Result := SYSInit.HInstance;
end;

procedure TSciterForm.WndProc(var Message: TMessage);
var
  bHandled: Boolean;
  M: PMsg;
begin
  if (FLayout = nil) and (not (csDestroying in ComponentState)) then
    FLayout := LayoutFactory.Create(Self);

  bHandled := False;
  DoWndProc(Message, bHandled);
  if bHandled then
    Exit;

  if HandleAllocated and (FLayout <> nil) then
  begin
    if Message.Msg = WM_GETDLGCODE then
    begin
      Message.Result := DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS or DLGC_WANTCHARS or DLGC_HASSETSEL;
      if Message.lParam <> 0 then
      begin
        M := PMsg(Message.lParam);
        case M.Message of
          WM_SYSKEYDOWN, WM_SYSKEYUP, WM_SYSCHAR, WM_KEYDOWN, WM_KEYUP, WM_CHAR:
            Message.Result := Perform(M.message, M.wParam, M.lParam);
        end;
      end;
      Exit;
    end;
    bHandled := False;
    Message.Result := FLayout.ProcND(WindowHandle, Message.Msg, Message.WParam, Message.LParam, bHandled);
    if bHandled then
      Exit;
    if (Message.Msg = WM_DESTROY) and (csDestroying in ComponentState) then
      FLayout := nil;
  end;
  DefWndProc(Message);
end;

function TSciterForm.GetBehavior: IDefalutBehaviorEventHandler;
begin
  if FLayout <> nil then
    Result := FLayout.Behavior
  else
    Result := nil;
end;

function TSciterForm.GetLayout: PISciterLayout;
begin
  Result := @FLayout;
end;

procedure TSciterForm.DoWndProc(var Msg: TMessage; var Handled: Boolean);
begin
  Handled := False;
end;

procedure TSciterForm.DefWndProc(var Msg: TMessage);
begin
  inherited WndProc(Msg);
end;

function TSciterForm.IsBubbling(event_type: UINT): Boolean;
begin
  Result := Behavior.IsBubbling(event_type);
end;

function TSciterForm.IsHandled(event_type: UINT): Boolean;
begin
  Result := Behavior.IsHandled(event_type);
end;

function TSciterForm.IsSinking(event_type: UINT): Boolean;
begin
  Result := Behavior.IsSinking(event_type);
end;

function TSciterForm.LoadHtmlFile(const uri: SciterString): Boolean;
begin
  Result := Layout.LoadFile(uri);
end;

function TSciterForm.LoadHtml(const pb: LPCBYTE; cb: UINT; const uri: SciterString): Boolean;
begin
  Result := Layout.LoadHtml(pb, cb, uri);
end;

destructor TSciterForm.Destroy;
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

procedure TSciterForm.SetBehavior(const Value: IDefalutBehaviorEventHandler);
begin
  if FLayout = nil then
    Exit;
  FLayout.Behavior := Value;
end;

procedure TSciterForm.CreateWnd;
begin
  inherited CreateWnd;
  if csDesigning in ComponentState then
    Exit;
  DoubleBuffered := True;
  if FLayout = nil then
  begin
    FLayout := LayoutFactory.Create(Self);
    //设置主窗口
    if (Sciter.MainWnd = 0) and (Application.MainForm <> nil) then
      Sciter.MainWnd := Application.MainForm.Handle;
  end;
  if HandleAllocated and (FLayout <> nil) then
    FLayout.Setup;
  if Assigned(FOnHandleCreated) then
    FOnHandleCreated(Self);
end;

procedure TSciterForm.DestroyWnd;
var
  pbHandled: Boolean;
begin
  if (not (csDesigning in ComponentState)) and (FLayout <> nil) then
  begin
    if IsWindow(WindowHandle) then
      FLayout.ProcND(WindowHandle, WM_DESTROY, 0, 0, pbHandled);
    FLayout := nil;
  end;
  inherited;
end;

procedure TSciterForm.MouseWheelHandler(var Message: TMessage);
var
  pMsg: TWMMouseWheel;
begin
  pMsg := TWMMouseWheel(Message);
  if pMsg.WheelDelta < 0 then
    Perform(WM_VSCROLL, 1, 0)
  else
    Perform(WM_VSCROLL, 0, 0);
end;

function TSciterForm.GetWindowName: SciterString;
begin
  Result := Self.ClassName;
end;

initialization
  OleInitialize(nil);
finalization
  OleUninitialize;
end.
