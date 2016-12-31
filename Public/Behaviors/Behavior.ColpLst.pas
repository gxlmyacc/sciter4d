{*******************************************************************************
 标题:     Behavior.ColpLst.pas
 描述:     可折叠列表 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.ColpLst;

interface

uses
  SciterIntf, SciterTypes, SciterBehavior, Behavior.ExpLst;

type
  TCollapsibleListBehavior = class(TExpandableListBehavior)
  protected
    procedure SetCurrentItem(const ltOwner, item: IDomElement); override;
  end;

implementation


{ TCollapsibleListBehavior }

procedure TCollapsibleListBehavior.SetCurrentItem(const ltOwner,
  item: IDomElement);
var
  prev, prevCurrent: IDomElement;
begin
  // get previously expanded ltTarget:
//  prev := ltOwner.FindFirst(':root > :expanded');
//  prevCurrent := ltOwner.FindFirst(':root > :current');
  prev := ltOwner.FindFirst(':expanded');
  prevCurrent := ltOwner.FindFirst(':current');

  if (prevCurrent <> item) and (prevCurrent<>nil) then
    prevCurrent.SetStateEx(0,  STATE_CURRENT);

  if prev = item then
  begin
    prev.SetStateEx(0,  STATE_EXPANDED);
    prev.postEvent(ELEMENT_COLLAPSED, 0, prev); // source here is old collapsed tab itself
  end
  else
  begin
    if prev <> nil then
    begin
      prev.SetStateEx(0,  STATE_EXPANDED); // collapse old one
      prev.postEvent(ELEMENT_COLLAPSED,0, prev); // source here is old collapsed tab itself
    end;

    item.ChangeState(STATE_CURRENT or STATE_EXPANDED); // set new expanded.
    item.postEvent(ELEMENT_EXPANDED,0, item);  // source here is new expanded tab itself
  end;

  item.scrollToView();
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('collapsibleList', TCollapsibleListBehavior));

finalization
  BehaviorFactorys.UnReg('collapsibleList');

end.
