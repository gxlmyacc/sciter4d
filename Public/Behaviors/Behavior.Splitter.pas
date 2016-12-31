{*******************************************************************************
 标题:     Behavior.Splitter.pas
 描述:     拆分条 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Splitter;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  //splitter 拆分条
  TSplitterBehavior = class(TBehaviorEventHandler)
  private
    pressedOffset: Integer;
  private
    function doHorizontal(event_type: UINT; x,y: Integer;
      const ltOwner, first, second, elParent: IDomElement): Boolean;
    function doVertical(event_type: UINT; x,y: Integer;
      const ltOwner, first, second, elParent: IDomElement): Boolean;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TSplitterBehavior }

function TSplitterBehavior.doHorizontal(event_type: UINT; x, y: Integer;
  const ltOwner, first, second, elParent: IDomElement): Boolean;
var
  rcParent, rc: TRect;
  changeFirst: Boolean;
  width: Integer;
begin
	// which element width we will change? 
  rcParent := elParent.GetLocation;
	rc := first.GetLocation;

	changeFirst := (rc.right - rc.left) < (rcParent.right - rcParent.left)/2; 
  if not changeFirst then
    rc := second.GetLocation;
		
  if event_type = MOUSE_DOWN then
  begin
    pressedOffset := x;
    ltOwner.SetCapture;
    Result := False;
    Exit; // don't need updates
  end;
  
  // mouse move handling
  if pressedOffset = 0 then
  begin
    Result := False;
    Exit; // don't need updates  
  end;
		
  // mouse move handling
  if x = pressedOffset then
  begin
    Result := False;
    Exit; // don't need updates
  end;
		
	width := rc.right - rc.left; 
  if changeFirst then
  begin
		width := width + (x - pressedOffset);
		if width >= 0 then
    begin
      //first.delayMeasure();
      //second.delayMeasure();
				
      first.style['width']  := IntToStr(width) + 'px';
      second.style['width'] := '100%%';
		end;
	end
  else
  begin
		width := width - (x - pressedOffset);
		if width >= 0 then
    begin
      //first.delayMeasure();
	   	//second.delayMeasure();

			first.style['width']  := '100%%';
      second.style['width'] := IntToStr(width) + 'px';
		end;
	end;
	Result := True; // need update
end;

function TSplitterBehavior.doVertical(event_type: UINT; x, y: Integer;
  const ltOwner, first, second, elParent: IDomElement): Boolean;
var
  rcParent, rc: TRect;
  changeFirst: Boolean;
  height: Integer;
begin
	rcParent := elParent.GetLocation;
	rc := first.GetLocation;
		
	// if width of first element is less than half of parent we
	// will change its width.
  changeFirst :=  (rc.bottom - rc.top) < (rcParent.bottom - rcParent.top)/2;

  if not changeFirst then
  begin
    rc := second.GetLocation;
    if event_type = MOUSE_DOWN then
    begin
      pressedOffset := y;
      ltOwner.SetCapture;
      Result := False;
      Exit; // don't need updates
    end;
  end;
  if pressedOffset = 0 then
  begin
    Result := False;
    Exit;
  end;
		
  // mouse move handling
  if y = pressedOffset then
  begin
    Result := False;
    Exit; // don't need updates
  end;
		
  height := rc.bottom - rc.top; 
  if changeFirst then
  begin
    height := height + (y - pressedOffset);
    if height >= 0 then
    begin
      //first.delayMeasure();
      //second.delayMeasure();

      first.style['height']  := IntToStr(height) + 'px';
      second.style['height'] := '100%%';
    end;
  end
  else
  begin
    height := height - (y - pressedOffset);
    if height >= 0 then
    begin
      //first.delayMeasure();
      //second.delayMeasure();

      first.style['height'] := '100%%';
      second.style['height']  := IntToStr(height) + 'px';
    end;
  end;
  Result := true;
end;

function TSplitterBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
var
  elParent: IDomElement;
  first, second: IDomElement;
  needUpdate, horizontal: Boolean;
begin
  Result := False;
  if event_type and BUBBLING <> BUBBLING then
    Exit;

  if mouseButtons <> MAIN_MOUSE_BUTTON then
    Exit;

	elParent := he.Parent;

  first  := he.Prior;
  second := he.Next;
  if (first = nil) or (second = nil) then
    Exit;

  // what kind of splitter do we have? 
  horizontal := elParent.Style['flow'] = 'horizontal';

  if horizontal then
    needUpdate := doHorizontal(event_type, pt.X, pt.Y, he,first,second, target)
  else
    needUpdate := doVertical(event_type, pt.X, pt.Y,he,first,second, target);

  if needUpdate and (event_type = MOUSE_MOVE) then
    elParent.Update(True); //done! update changes on the view

  Result := True;
end;

function TSplitterBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
begin
  Result := OnMouseDown(he, target, event_type, pt, mouseButtons, keyboardStates, params);
end;

function TSplitterBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
begin
  if event_type and BUBBLING <> BUBBLING then
  begin
    Result := False;
    Exit;
  end;

  if mouseButtons = MAIN_MOUSE_BUTTON then
  begin
    he.ReleaseCapture;
  end;
  
  Result := False;
end;

function TSplitterBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('splitter', TSplitterBehavior));

finalization
  BehaviorFactorys.UnReg('splitter');


end.
