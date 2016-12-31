{*******************************************************************************
 标题:     Behavior.Gripper.pas
 描述:      拖动手柄 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Gripper;

interface

uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  //gripper 拖动手柄
  TGripperBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TGripperBehavior }

function TGripperBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
begin
  Result := False;
  if event_type and BUBBLING <> BUBBLING then
    Exit;

  if mouseButtons = MAIN_MOUSE_BUTTON then
  begin
    params.dragging := he.Parent.Element;
    params.dragging_mode := DRAGGING_MOVE;

    Result := True;
  end;
end;

function TGripperBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('gripper', TGripperBehavior));

finalization
  BehaviorFactorys.UnReg('gripper');

end.
