{*******************************************************************************
 标题:     Behavior.WinSizer.pas
 描述:     窗口尺寸可调整 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.WinSizer;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior, Messages;

type
  TWinSizerBehavior = class(TBehaviorEventHandler)
  private
    FBorderInited: Boolean;
    FBorderTopLeft: IDomElement;
    FBorderLeft: IDomElement;
    FBorderBottomLeft: IDomElement;
    FBorderTop: IDomElement;
    FBorderBottom: IDomElement;
    FBorderTopRight: IDomElement;
    FBorderRight: IDomElement;
    FBorderBottomRight: IDomElement;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
    function  OnTimer(const he: IDomElement): Boolean; override;
  end;

implementation

uses
  SciterFactoryIntf;

{ TWinSizerBehavior }

procedure TWinSizerBehavior.OnAttached(const he: IDomElement);
begin
  if he.Root.IndexOfAttribute('-init-window-sizer') >= 0 then
    Exit; 
  he.Root.Attributes['-init-window-sizer'] := '';
  he.Root.RemoveAttribute('-final-window-sizer');
  
  if not he.Root.HasAttribute('window-resizable') then
    he.StartTimer(10);
end;

procedure TWinSizerBehavior.OnDetached(const he: IDomElement);
begin
  if he.Root.IndexOfAttribute('-final-window-sizer') >= 0 then
    Exit; 
  he.Root.Attributes['-final-window-sizer'] := '';
  he.Root.RemoveAttribute('-init-window-sizer');
end;

function TWinSizerBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  sizerCommand: SciterString;
  wParam: Integer;
begin
  Result := False;
  if (not FBorderInited) or (not IsBubbling(event_type)) then
    Exit;
  if params.button_state <> MAIN_MOUSE_BUTTON then
    Exit;
  sizerCommand := target.Attributes['sizer-command'];
  if sizerCommand = '' then
    Exit;
  if IsZoomed(he.GetElementHwnd) then
    Exit;

  if sizerCommand = 'hitTopleft' then
    wParam := HTTOPLEFT
  else
  if sizerCommand = 'hitLeft' then
    wParam := HTLEFT
  else
  if sizerCommand = 'hitBottomleft' then
    wParam := HTBOTTOMLEFT
  else
  if sizerCommand = 'hitTop' then
    wParam := HTTOP
  else
  if sizerCommand = 'hitBottom' then
    wParam := HTBOTTOM
  else
  if sizerCommand = 'hitTopright' then
    wParam := HTTOPRIGHT
  else
  if sizerCommand = 'hitRight' then
    wParam := HTRIGHT
  else
  if sizerCommand = 'hitBottomright' then
    wParam := HTBOTTOMRIGHT
  else
    Exit;

  PostMessage(he.GetElementHwnd(True), WM_NCLBUTTONDOWN,  wParam, 0);
  Result := True;
end;

procedure TWinSizerBehavior.OnSize(const he: IDomElement);
var
  Placement: TWindowPlacement;
begin
  if not FBorderInited then Exit;
  GetWindowPlacement(he.GetElementHwnd, @Placement);
  case Placement.showCmd of
    SW_SHOWMINIMIZED:
    begin
    
    end;
    SW_SHOWMAXIMIZED:
    begin
      FBorderTopLeft.SetStateEx(STATE_DISABLED, 0, False);
      FBorderLeft.SetStateEx(STATE_DISABLED, 0, False);
      FBorderBottomLeft.SetStateEx(STATE_DISABLED, 0, False);
      FBorderTop.SetStateEx(STATE_DISABLED, 0, False);
      FBorderBottom.SetStateEx(STATE_DISABLED, 0, False);
      FBorderTopRight.SetStateEx(STATE_DISABLED, 0, False);
      FBorderRight.SetStateEx(STATE_DISABLED, 0, False);
      FBorderBottomRight.SetStateEx(STATE_DISABLED, 0, False);
    end;
    SW_NORMAL:
    begin
      FBorderTopLeft.ClearState(STATE_DISABLED, False);
      FBorderLeft.ClearState(STATE_DISABLED, False);
      FBorderBottomLeft.ClearState(STATE_DISABLED, False);
      FBorderTop.ClearState(STATE_DISABLED, False);
      FBorderBottom.ClearState(STATE_DISABLED, False);
      FBorderTopRight.ClearState(STATE_DISABLED, False);
      FBorderRight.ClearState(STATE_DISABLED, False);
      FBorderBottomRight.ClearState(STATE_DISABLED, False);
    end;
  end;
end;

function TWinSizerBehavior.OnSubscription(const he: IDomElement; var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_MOUSE or HANDLE_SIZE or HANDLE_TIMER;
  Result := True;
end;


function TWinSizerBehavior.OnTimer(const he: IDomElement): Boolean;
var
  border, corner: SciterString;
begin
  border := he.Attributes['border'];
  if border = EmptyStr then
    border := '4dip';
  corner := he.Attributes['corner'];
  if corner = EmptyStr then
    corner := '8dip';

  he.Attributes['windowSizer'] := '';

  FBorderTopLeft := ElementFactory.Create('div');
  he.Append(FBorderTopLeft);
  FBorderTopLeft.Attributes['sizer-command'] := 'hitTopleft';
  FBorderTopLeft.Style['left'] := '0';
  FBorderTopLeft.Style['top'] := '0';
  FBorderTopLeft.Style['width'] := corner;
  FBorderTopLeft.Style['height'] := corner;
  FBorderTopLeft.Style['cursor'] := 'nw-resize';
  FBorderTopLeft.Style['position'] := 'absolute';

  FBorderLeft := ElementFactory.Create('div');
  he.Append(FBorderLeft);
  FBorderLeft.Attributes['sizer-command'] := 'hitLeft';
  FBorderLeft.Style['left'] := '0';
  FBorderLeft.Style['top'] := corner;
  FBorderLeft.Style['bottom'] := corner;
  FBorderLeft.Style['width'] := border;
  FBorderLeft.Style['cursor'] := 'w-resize';
  FBorderLeft.Style['position'] := 'absolute';

  FBorderBottomLeft := ElementFactory.Create('div');
  he.Append(FBorderBottomLeft);
  FBorderBottomLeft.Attributes['sizer-command'] := 'hitBottomleft';
  FBorderBottomLeft.Style['left'] := '0';
  FBorderBottomLeft.Style['bottom'] := '0';
  FBorderBottomLeft.Style['width'] := corner;
  FBorderBottomLeft.Style['height'] := corner;
  FBorderBottomLeft.Style['cursor'] := 'sw-resize';
  FBorderBottomLeft.Style['position'] := 'absolute';

  FBorderTop := ElementFactory.Create('div');
  he.Append(FBorderTop);
  FBorderTop.Attributes['sizer-command'] := 'hitTop';
  FBorderTop.Style['left'] := corner;
  FBorderTop.Style['top'] := '0';
  FBorderTop.Style['right'] := corner;
  FBorderTop.Style['height'] := border;
  FBorderTop.Style['cursor'] := 'n-resize';
  FBorderTop.Style['position'] := 'absolute';

  FBorderBottom := ElementFactory.Create('div');
  he.Append(FBorderBottom);
  FBorderBottom.Attributes['sizer-command'] := 'hitBottom';
  FBorderBottom.Style['left'] := corner;
  FBorderBottom.Style['bottom'] := '0';
  FBorderBottom.Style['right'] := corner;
  FBorderBottom.Style['height'] := border;
  FBorderBottom.Style['cursor'] := 's-resize';
  FBorderBottom.Style['position'] := 'absolute';

  FBorderTopRight := ElementFactory.Create('div');
  he.Append(FBorderTopRight);
  FBorderTopRight.Attributes['sizer-command'] := 'hitTopright';
  FBorderTopRight.Style['top'] := '0';
  FBorderTopRight.Style['right'] := '0';
  FBorderTopRight.Style['width'] := corner;
  FBorderTopRight.Style['height'] := corner;
  FBorderTopRight.Style['cursor'] := 'ne-resize';
  FBorderTopRight.Style['position'] := 'absolute';

  FBorderRight := ElementFactory.Create('div');
  he.Append(FBorderRight);
  FBorderRight.Attributes['sizer-command'] := 'hitRight';
  FBorderRight.Style['right'] := '0';
  FBorderRight.Style['top'] := corner;
  FBorderRight.Style['bottom'] := corner;
  FBorderRight.Style['width'] := border;
  FBorderRight.Style['cursor'] := 'e-resize';
  FBorderRight.Style['position'] := 'absolute';

  FBorderBottomRight := ElementFactory.Create('div');
  he.Append(FBorderBottomRight);
  FBorderBottomRight.Attributes['sizer-command'] := 'hitBottomright';
  FBorderBottomRight.Style['position'] := 'absolute';
  FBorderBottomRight.Style['right'] := '0';
  FBorderBottomRight.Style['bottom'] := '0';
  FBorderBottomRight.Style['width'] := corner;
  FBorderBottomRight.Style['height'] := corner;
  FBorderBottomRight.Style['cursor'] := 'se-resize';

  FBorderInited := True;
  Result := False; 
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('windowSizer', TWinSizerBehavior));

finalization
  BehaviorFactorys.UnReg('windowSizer');

end.
