unit Behavior.LgtBoxDlg;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior, Messages;

type
  TLightBoxDialogBehavior = class(TBehaviorEventHandler)
  private
	  savedParent: IDomElement;
	  savedIdx: Integer;
		focusUid: UINT;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    function  OnKeyDown(const he, target: IDomElement; event_type: UINT; code, keyboardStates: UINT): Boolean; override;
    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; reason: UINT_PTR): Boolean; override;
  public
    procedure Show(const ltOwner: IDomElement);
    procedure Hide(const ltOwner: IDomElement);
  end;

  TLightBoxDialogBehaviorFactory = class(TBehaviorFactory)
  public
    function CreateHandler(const he: IDomElement): IBehaviorEventHandler; override;
  end;

implementation

{ TLightBoxDialogBehavior }

procedure TLightBoxDialogBehavior.Hide(const ltOwner: IDomElement);
var
  root, shim, body, focus: IDomElement; 
begin
  if savedParent = nil then
    Exit; // already hidden

  savedParent.Insert(ltOwner, savedIdx); //move it back to original position in the DOM
  
  root := ltOwner.Root;
  shim := root.FindFirst('div.shim'); //get shim
  if shim = nil then
    Exit;
  shim.Detach();//detaching shim from DOM
		
  ltOwner.style['display'] := 'none';  //clearing display set in showDialog()

  body := root.FindFirst('body');
  body.ClearState(STATE_DISABLED); //enable it again

  focus := root.ElementByUID[focusUid];
  savedParent := nil;
  savedIdx := -1;
end;

procedure TLightBoxDialogBehavior.OnAttached(const he: IDomElement);
begin
	savedParent := nil;
	savedIdx := -1;
	focusUid := 0;
end;

function TLightBoxDialogBehavior.OnButtonClick(const he,
  target: IDomElement; _type: UINT; reason: UINT_PTR): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  if target.Match('[role=''ok-button'']', []) or target.Match('[role=''cancel-button'']', []) then
    Hide(he);
end;

function TLightBoxDialogBehavior.OnKeyDown(const he, target: IDomElement;
  event_type, code, keyboardStates: UINT): Boolean;
var
  default: IDomElement;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  case code of
    VK_RETURN:
    begin
      default := he.FindFirst('[role=''ok-button'']');
      if default <> nil then
        Result := default.SendEvent(BUTTON_CLICK);
    end;
    VK_ESCAPE:
    begin
      default := he.FindFirst('[role=''cancel-button'']');
      if default <> nil then
        Result := default.SendEvent(BUTTON_CLICK);    
    end;
  end;
end;

function TLightBoxDialogBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_BEHAVIOR_EVENT or HANDLE_INITIALIZATION or HANDLE_KEY;
  Result := True;
end;

procedure TLightBoxDialogBehavior.Show(const ltOwner: IDomElement);
var
  root, focus, shim, body: IDomElement;
begin
  if savedParent <> nil then
    Exit;  // already shown

  savedParent := ltOwner.Parent;
  savedIdx    := ltOwner.Index;
  root        := ltOwner.Root; //root <html> element

  // saving focus
  focus := root.FindFirst(':focus');
  if focus <> nil then
    focusUid := focus.UID;
    
  shim := ltOwner.CreateElement('div');
  shim.Attributes['class'] := 'shim';
  root.Append(shim); //adding shim to DOM
  
  shim.Insert(ltOwner, 0);  //make dialog a child of the shim
  ltOwner.Style['display'] := 'block'; //make it visible

  body := root.FindFirst('body');
  body.ChangeState(STATE_DISABLED); // disable body. 
end;


	

{ TLightBoxDialogBehaviorFactory }

function TLightBoxDialogBehaviorFactory.CreateHandler(
  const he: IDomElement): IBehaviorEventHandler;
begin
  Result := TLightBoxDialogBehavior.Create(he);
end;

end.
