{*******************************************************************************
 标题:     Behavior.Scroller.pas
 描述:     可自动滚动 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Scroller;

interface
     
uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  //scroller 自动滚动
  TScrollerBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TScrollerBehavior }

function TScrollerBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
var
  scrollInfo: TDomElementScrollInfo;
  pos: TPoint;
  rc: TRect;
  sz: TSize;
  vh, dh, py: Integer;
begin
  //鼠标以SINKING(捕获模式)向下传递下,使用sinking名字空间响应事件
  if not IsSinking(event_type) then
  begin
    Result := False;
    Exit;
  end;

  if mouseButtons <> 0 then
  begin
    Result := False; // only mouse move in unpressed state.
    Exit;
  end;

  scrollInfo := he.ScrollInfo;
  pos   := scrollInfo.scroll_pos;
  rc    := scrollInfo.view_rect;
  sz    := scrollInfo.content_size;

  if (pt.X < rc.left) or (pt.X > rc.right) or (pt.Y < rc.top) or (pt.Y > rc.bottom) then
  begin
    Result := False;
    Exit;
  end;

  vh := rc.bottom - rc.top;
  if vh >= sz.cy then
  begin
    Result := False;
    Exit;  
  end;
		
	dh := sz.cy - vh;
	py := Round((pt.Y * dh) / vh);
  if py <> pos.y then
  begin
		pos.y := py;
    he.ScrollPos := pos;
	end;
  
	Result := False;  
end;

function TScrollerBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;


initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('scroller', TScrollerBehavior));

finalization
  BehaviorFactorys.UnReg('scroller');

end.
