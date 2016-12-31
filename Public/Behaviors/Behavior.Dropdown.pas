{*******************************************************************************
 标题:     Behavior.Dropdown.pas
 描述:     下拉选框 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Dropdown;

interface

uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  //dropdown 下拉选框
  TDropdownBehavior = class(TBehaviorEventHandler)
  protected
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TDropdownBehavior }

function TDropdownBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
var
  elPopup: IDomElement;
begin
  Result := False;
  if event_type and BUBBLING <> BUBBLING then
    Exit;

	elPopup := he.FindFirst('.popup,popup'); // either class or element <popup>
  if elPopup = nil then
    Exit;
    
	if elPopup.IsChild(target) then
  begin
    Result := True;
    Exit;
  end;      
	 
	if not he.TestState(STATE_OWNS_POPUP) then
  begin
		// you can use :popup and :owns-popup pseudo-classes in CSS now.
	 	elPopup.Popup(he,  2); // show it below
	end;
	Result := true;
end;


initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('dropdown', TDropdownBehavior));

finalization
  BehaviorFactorys.UnReg('dropdown');
  
end.
