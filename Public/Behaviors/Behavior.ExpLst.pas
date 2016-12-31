{*******************************************************************************
 标题:     Behavior.ExpLst.pas
 描述:     可 展开 列表 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.ExpLst;

interface

uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  //expandableList 扩展列表
  TExpandableListBehavior = class(TBehaviorEventHandler)
  protected
    procedure SetCurrentItem(const ltOwner, item: IDomElement);  virtual;
    
    procedure OnAttached(const he: IDomElement); override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnActivateChild(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; reason: UINT_PTR): Boolean; override;
    function  OnKeyDown(const he, target: IDomElement; event_type: UINT; code, keyboardStates: UINT; var params: TKeyParams): Boolean; override;
  public

    function  TargetItem(const ltOwner, ltTarget: IDomElement): IDomElement;
  end;

implementation

{ TExpandableListBehavior }

function TExpandableListBehavior.OnActivateChild(const he,
  target: IDomElement; _type: UINT; reason: UINT_PTR): Boolean;
var
  item: IDomElement;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

	item := targetItem(he, target);
	if item <> nil then
  begin
		// click on the item caption 
		setCurrentItem(he, item);
		Result := true; 
  end;	
end;

procedure TExpandableListBehavior.OnAttached(const he: IDomElement);
var
  gotOne: Boolean;
  i: Integer;
  eleChild: IDomElement;
begin
	gotOne := False;

  for i := 0 to he.ChildCount - 1 do
  begin
    eleChild := he.Child[i];
    if (eleChild.Attributes['default'] <> '') and (not gotOne) then
    begin
      eleChild.ChangeState(STATE_CURRENT or STATE_EXPANDED);
      gotOne := True;
    end
    else
    begin
      eleChild.ChangeState(STATE_COLLAPSED);
    end;
  end;
end;

function TExpandableListBehavior.OnKeyDown(const he, target: IDomElement;
  event_type, code, keyboardStates: UINT; var params: TKeyParams): Boolean;
var
  c: IDomElement;
  idx: Integer;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  case code of
    VK_DOWN:
    begin
			c := he.FindFirst(':current');

      if c <> nil then
			  idx := c.index + 1
      else
        idx := 0;

			if idx < Integer(he.childCount) then
   			setCurrentItem(he, he.child[idx] );
    end;
    VK_UP:
    begin
      c := he.FindFirst(':current');

      if c <> nil then
			  idx := c.index - 1
      else
        idx := he.ChildCount - 1;

			if idx >= 0 then
        setCurrentItem(he, he.child[idx]);
    end;
  end;
end;

function TExpandableListBehavior.OnMouseDClick(const he,
  target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
begin
  Result := OnMouseDown(he, target, event_type, pt, mouseButtons, keyboardStates, params)
end;

function TExpandableListBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
var
  item: IDomElement;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

	if mouseButtons <> MAIN_MOUSE_BUTTON then
    Exit;
		
 	// el is presumably <li>; 
  item := targetItem(he, target);

  if item <> nil then // click on the item caption
    setCurrentItem(he, item);

  Result := true; // as it is always ours then stop event bubbling
end;

procedure TExpandableListBehavior.SetCurrentItem(const ltOwner,
  item: IDomElement);
var
  prevCurrent, prev: IDomElement;
begin
	// get previously selected item:
//	prevCurrent := ltOwner.FindFirst(':root > :current');
//  prev := ltOwner.FindFirst(':root > :expanded');
	prevCurrent := ltOwner.FindFirst(':current');
  prev := ltOwner.FindFirst(':expanded');
	
	if (prevCurrent <> item) and (prevCurrent <> nil) then
		prevCurrent.SetStateEx(0, STATE_CURRENT);
	
	if prev <> nil then
  begin
		if prev = item then
      Exit; // already here, nothing to do.

		prev.SetStateEx(0, STATE_CURRENT or STATE_EXPANDED);

		// notify all parties involved
		prev.postEvent(ELEMENT_COLLAPSED, 0, prev); // source here is old collapsed tab itself
	end;
	item.ChangeState(STATE_CURRENT or STATE_EXPANDED); // set state flags
	item.postEvent(ELEMENT_EXPANDED,0, item);  // source here is new expanded tab itself
end;

function TExpandableListBehavior.TargetItem(const ltOwner,
  ltTarget: IDomElement): IDomElement;
var
  ltTargetParent: IDomElement;
begin
  Result := nil;

	if ltTarget = ltOwner then
		Exit;
	
	if ltTarget = nil then
		Exit;
	
	ltTargetParent := ltTarget.Parent;
	if ltTargetParent = nil then
		Exit;
	
	if ltTarget.Match('li > .caption', []) then
	begin
    Result := ltTargetParent; // only if click on "caption" element of <li>. Returns that <li> element.
    Exit;
  end;
	
	Result := targetItem( ltOwner, ltTarget.parent );
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('expandableList', TExpandableListBehavior));

finalization
  BehaviorFactorys.UnReg('expandableList');

end.
