{*******************************************************************************
 标题:     Behavior.Pupup.pas
 描述:     弹出 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Pupup;

interface

uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  //popup 弹出面板
  TPupupBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; reason: UINT_PTR): Boolean; override;
    function  OnHyperlinkClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; reason: UINT_PTR): Boolean; override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnFocusLost(const he, target: IDomElement; event_type: UINT): Boolean; override;
  end;

implementation

{ TPupupBehavior }

function TPupupBehavior.OnButtonClick(const he, target: IDomElement;
  _type: UINT; reason: UINT_PTR): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  he.HidePopup;
end;

function TPupupBehavior.OnFocusLost(const he, target: IDomElement;
  event_type: UINT{FOCUS_EVENTS}): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if he.IsChild(target) then
    he.HidePopup;
end;

function TPupupBehavior.OnHyperlinkClick(const he, target: IDomElement;
  _type: UINT; reason: UINT_PTR): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  he.HidePopup;
end;

function TPupupBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
begin
  Result := True;
end;

function TPupupBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  he.HidePopup;
end;

function TPupupBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE or HANDLE_BEHAVIOR_EVENT or HANDLE_FOCUS;
  Result := True;
end;

initialization
  //BehaviorFactorys.Reg(TBehaviorFactory.Create('popup', TPupupBehavior));

finalization
  //BehaviorFactorys.UnReg('popup');

end.
