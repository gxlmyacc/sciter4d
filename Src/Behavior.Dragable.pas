{*******************************************************************************
 标题:     Behavior.Dragable.pas
 描述:     可拖动 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Dragable;

interface

uses
  Windows, Classes, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
(*
  BEHAVIOR: draggable
     goal: 元素可拖动行为
  VIEWS:
      ________________________________________________
     |     _________________________                 |
     |    |    容器元素            |                 |
     |    |    _____________       |                 |
     |    |   |            |       |     body        |
     |    |   | 可拖动元素 |       |                 |
     |    |   |____________|       |                 |
     |    |________________________|                 |
     |_______________________________________________|
  COMMENTS:
      <html>
        <body>
          <div.container style="positon:relative|absolute|fixed;">
            <div style="behavior:draggable" draggable="both|horizontal|vertical" drag-margin="5 5 5 5" dragmode="auto|attached-window|detached-window" />
          </div>
      </html>
  NOTE:
    1、【可拖动元素】可以在【容器元素】内部被鼠标拖动来移动位置；
    2、【可拖动元素】可以通过【draggable】属性来设置允许拖动的方向：
         both:        双向拖动
         horizontal:  横向拖动
         vertical:    纵向拖动
    3、【可拖动元素】可以通过【drag-margin】属性来设置在【容器元素】中被拖动的最大范围，格式为【上 右 下 左】；
         比如【drag-margin="5 5 5 5"】的含义是：【可拖动元素】可在由【容器元素】的边界距离5像素的位置组成的矩形内拖动；
    4、【容器元素】指包含【可拖动元素】，且它的样式中包含【positon:relative|absolute|fixed;】的元素，
         如果没有这样的元素，则【容器元素】为网页的根元素,即HTML元素。
    5、【可拖动元素】中的dragmode属性指定拖动模式，支持以下模式：
         空:                      通过移动元素的left和top属性来拖动元素
         auto:                    如果元素移动到视图外面将会创建窗口。如果元素在视图内则它会被渲染为popup:fixed
         attached-window:         强制引擎为该元素创建一个弹出窗口。该窗口和它的宿主窗口(视图)是同步移动的
         detached-window:         强制引擎为该元素创建弹出窗口，该元素的窗口位置独立于它的宿主窗口
         detached-topmost-window: 与#detached-window相同，不过是创建在最顶窗口层上。 
*)

  TDragableBehavior = class(TBehaviorEventHandler)
  private
		dragMarginTop: Integer;
    dragMarginRight: Integer;
    dragMarginBottom: Integer;
    dragMarginLeft: Integer;
    view: IDomElement;
    dx, dy: Integer;
    mode: IDomValue;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;
  
implementation

uses
  SciterFactoryIntf;

{ TDragableBehavior }

procedure TDragableBehavior.OnAttached(const he: IDomElement);
var
  dragMargin, position, sMode: SciterString;
  t: array of Integer;
  ls: TStringList;
  i: Integer;
  ltView: IDomElement;
begin
  he.Style['position'] := 'absolute';
  dragMargin := he.Attributes['drag-margin'];
  if dragMargin = EmptyStr then
    dragMargin := he.Style['drag-margin'];

  if dragMargin <> EmptyStr then
  begin
    ls := TStringList.Create;
    try
      ls.Delimiter := ' ';
      ls.DelimitedText := dragMargin;

      for i := ls.Count - 1 downto 0 do
        if ls[i] = '' then
          ls.Delete(i);

      if ls.Count > 0 then
      begin
        SetLength(t, ls.Count);
        for i := 0 to ls.Count - 1 do
          t[i] := StrToIntDef(ls[i], 0);

        if t[0] > 0 then
        begin
          dragMarginTop := t[0];
          if Length(t) < 2 then
            dragMarginRight := t[0]
          else
            dragMarginRight := t[1];
          if Length(t) < 3 then
            dragMarginBottom := t[2]
          else
            dragMarginBottom := dragMarginTop;
          if Length(t) < 4 then
            dragMarginLeft := t[3]
          else
            dragMarginLeft := dragMarginRight;
        end;
      end;
    finally
      ls.Free;
    end;   
  end;

  sMode := he.Attributes['drag-mode'];
  if (sMode <> '') and (sMode <> 'none') then
    mode := ValueFactory.MakeSymbol(sMode)
  else
    mode := nil;

  ltView := he.Parent;
  while ltView <> nil do
  begin
    position := ltView.Style['position'];
    if (position='relative') or (position='absolute') or (position='fixed') then
    begin
      view := ltView;
      break;
    end;
    ltView := ltView.Parent;
  end;
  if view = nil then
    view := he.Root;
end;

function NotDraggable(const target: IDomElement): Boolean;
var
  sTag: SciterString;
begin
  sTag := WideLowerCase(target.Tag);
  Result := (sTag = 'a') or (sTag = 'select') or (sTag = 'input') or (sTag = 'button')
    or (sTag = 'checkbox') or target.HasAttribute('no-drag');
end;

function TDragableBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  sDragable: string;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if params.button_state = MAIN_MOUSE_BUTTON then
  begin
    sDragable := he.Attributes['draggable'];
    if (sDragable = '') or (sDragable = 'none') or NotDraggable(target) then
      Exit;

    he.SetCapture;
    dx := params.pos.X;
    dy := params.pos.Y;

    he.ChangeState(STATE_MOVING);
    he.SendEvent(UI_STATE_CHANGED);
    he.Update(True);
  end;
end;

function TDragableBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  rcWnd, rc: TRect;
  pos: TPoint;
  sDragable: string;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if (params.button_state = MAIN_MOUSE_BUTTON) and he.TestState(STATE_MOVING) then
  begin
    sDragable := he.Attributes['draggable'];
    if (sDragable = '') or (sDragable = 'none') then
      Exit;
    if view = nil then
      Exit;

    pos.x := params.pos_view.X - dx;
    pos.y := params.pos_view.Y - dy;

    if dragMarginTop <> 0 then
    begin
      rcWnd := view.GetLocation(VIEW_RELATIVE or MARGIN_BOX);
      rc    := he.GetLocation(VIEW_RELATIVE or MARGIN_BOX);
      
      if (sDragable = 'both') or (sDragable = 'horizontal') then
      begin
        if pos.x <= (rcWnd.Left + dragMarginLeft) then
          pos.x := rcWnd.Left + dragMarginLeft
        else
        if (pos.x+rc.Right-rc.Left) > (rcWnd.Right-dragMarginRight) then
          pos.X := rcWnd.Right - dragMarginRight - (rc.Right - rc.Left);
      end;

      if (sDragable = 'both') or (sDragable = 'vertical') then
      begin
        if pos.y <= (rcWnd.Top + dragMarginTop) then
          pos.y := rcWnd.top + dragMarginTop
        else
        if (pos.y+rc.Bottom-rc.Top) > (rcWnd.bottom-dragMarginBottom) then
          pos.y := rcWnd.bottom - dragMarginBottom - (rc.Bottom - rc.top);
      end;
    end;

    if mode = nil then
    begin
      if (sDragable = 'both') or (sDragable = 'horizontal') then
        he.Style['left'] := IntToStr(pos.X-rcWnd.Left);
      if (sDragable = 'both') or (sDragable = 'vertical') then
        he.Style['top'] := IntToStr(pos.Y-rcWnd.Top);
    end
    else
    begin
      he.CallMethod('move', [
        ValueFactory.Create(pos.X),
        ValueFactory.Create(pos.Y),
        ValueFactory.MakeSymbol('#view'),
        mode
        ]);
    end;
  end;
end;

function TDragableBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  if (params.button_state = MAIN_MOUSE_BUTTON) and he.TestState(STATE_MOVING) then
  begin
    he.ReleaseCapture;
    he.ClearState(STATE_MOVING);
    he.SendEvent(UI_STATE_CHANGED);
    he.Update(True);
  end;                        
end;

function TDragableBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_MOUSE;
  Result := True;
end;


initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('draggable', TDragableBehavior));

finalization
  BehaviorFactorys.UnReg('draggable');

end.
