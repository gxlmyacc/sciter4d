unit Behavior.Switch;

interface

uses
  Windows, Classes, SysUtils, SciterIntf, SciterTypes, SciterBehavior, Messages;

type
  TSwitchBehavior = class(TBehaviorEventHandler)
  private
    function GetValue(const v: WideString): WideString;
    procedure SetValue(const v, Value: WideString);
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnKeyDown(const he, target: IDomElement; event_type: UINT; code, keyboardStates: UINT): Boolean; override;

    function  OptValue(const opt: IDomElement): WideString;
  public
    property Value[const v: WideString]: WideString read GetValue write SetValue;
  end;

  TSwitchBehaviorFactory = class(TBehaviorFactory)
  public
    function CreateHandler(const he: IDomElement): IBehaviorEventHandler; override;
  end;

implementation

{ TSwitchBehavior }

function TSwitchBehavior.GetValue(const v: WideString): WideString;
var
  opt: IDomElement;
begin
  opt := this.FindFirst(':root>option:checked');
  if opt <> nil then
    Result := OptValue(opt)
  else
    Result := '';
end;

procedure TSwitchBehavior.OnAttached(const he: IDomElement);
begin
  he.ChangeState(STATE_FOCUSABLE);
end;

function TSwitchBehavior.OnKeyDown(const he, target: IDomElement;
  event_type, code, keyboardStates: UINT): Boolean;
var
  popt, opt: IDomElement;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  popt := he.FindFirst(':root>option:checked');
  opt := popt;
  case  code of
    VK_LEFT:
    begin
      if popt <> nil then
      begin
        opt := popt.Prior;
        if opt = nil then
          opt := popt;
      end
      else
      begin
        opt := he.First;
      end;
    end;
    VK_RIGHT:
    begin
      if popt <> nil then
      begin
        opt := popt.Next;
        if opt = nil then
          opt := popt;
      end
      else
      begin
        opt := he.Last;
      end;
    end;
    VK_HOME:
    begin
      opt := he.First;
    end;
    VK_END:
    begin
      opt := he.Last;
    end;    
  end;

  if opt <> popt then
  begin
    if popt <> nil then
      popt.ClearState(STATE_CHECKED);
    if opt <> nil then
      opt.ChangeState(STATE_CHECKED);
    he.PostEvent(BUTTON_STATE_CHANGED);

    Result := True;
  end;
end;

function TSwitchBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
var
  opt, popt: IDomElement;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  opt := target.FindNearestParent('option', []);
  if (opt = nil) or opt.TestState(STATE_CHECKED) or opt.TestState(STATE_PRESSED) then
    Exit;
  popt := he.FindFirst('root>option:checked');
  if popt <> nil then
    popt.ClearState(STATE_CHECKED);
  opt.ClearState(STATE_CHECKED);
  
  he.PostEvent(BUTTON_STATE_CHANGED);
end;

function TSwitchBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE or HANDLE_INITIALIZATION or HANDLE_KEY;
  Result := True;
end;

function TSwitchBehavior.OptValue(const opt: IDomElement): WideString;
var
  av: WideString;
begin
  av := opt.Attributes['value'];
  if av = EmptyStr then
  begin
    Result := opt.Text;
    Exit;
  end
  else
    Result := av;
end;

procedure TSwitchBehavior.SetValue(const v, Value: WideString);
var
  popt, opt: IDomElement;
  i: Integer;
begin
  popt := this.FindFirst(':root>option:checked');
  if popt <> nil then
    popt.ClearState(STATE_CHECKED);
  for i := 0 to this.ChildCount - 1 do
  begin
    opt := this.Child[i];
    if OptValue(opt) = v then
    begin
      opt.ChangeState(STATE_CHECKED);
      Exit;
    end;
  end;
end;

{ TSwitchBehaviorFactory }

function TSwitchBehaviorFactory.CreateHandler(
  const he: IDomElement): IBehaviorEventHandler;
begin
  Result := TSwitchBehavior.Create(he);
end;

end.
