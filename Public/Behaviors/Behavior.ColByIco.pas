{*******************************************************************************
 标题:     Behavior.ColByIco.pas
 描述:     点击图标 展开/折叠 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.ColByIco;

interface

uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  TCollapsibleByIconBehavior = class(TBehaviorEventHandler)
  protected
    function OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function OnMouseDown(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function OnMouseDClick(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;
  
implementation

{ TCollapsibleByIconBehavior }

function TCollapsibleByIconBehavior.OnMouseDClick(const he,
  target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
begin
  Result := OnMouseDown(he, target, event_type, pt, mouseButtons, keyboardStates, params)
end;

function TCollapsibleByIconBehavior.OnMouseDown(const he,
  target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
var
  eleIcon: IDomElement;
  is_closed: Boolean;
begin
  if not IsBubbling(event_type) then
  begin
    Result := False;
    Exit;
  end;
  
  // find first element with class "icon"
  eleIcon := he.FindFirst('.icon'{css selector, sic!});  
    
  if not eleIcon.Equal(target) then
  begin
    Result := False;  // event is not targeted to element having class "icon"
    Exit;
  end;
    
  // ok, we've got here targeted to icon. then get open/closed state.
  is_closed := he.Attributes['state'] = 'close'; 
    
  // toggle value of attribute "state" and
  // correspondent state flag - this is needed to play animation
  if is_closed then
    he.Attributes['state'] := 'open'
  else
    he.Attributes['state'] := 'close';
    
  // as it is ours then stop event bubbling
  Result := True; 
end;

function TCollapsibleByIconBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('collapsible-by-icon', TCollapsibleByIconBehavior));

finalization
  BehaviorFactorys.UnReg('collapsible-by-icon');


end.
