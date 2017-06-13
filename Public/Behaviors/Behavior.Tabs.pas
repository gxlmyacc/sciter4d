{*******************************************************************************
 标题:     Behavior.Tabs.pas
 描述:     标签页 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.Tabs;

interface

uses
  Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  (*

  BEHAVIOR: tabs
     goal: Implementation of the tabs: stacked panels switchable by tabs in tab strip
  COMMENTS:
     <div style="behavior:tabs">
        <ul class="strip"> <!-- our tab strip, can be placed on any side of tab container. -->
           <li panel="panel-id1" selected >tab1 caption</li>
           <li panel="panel-id2">tab2 caption</li>
        </ul>
        <div name="panel-id1" > first panel content </div>
        <div name="panel-id2"> second panel content </div>
     </div>
  SAMPLE:
     See: samples/behaviors/tabs.htm
  *)

  TTabBehavior = class(TBehaviorEventHandler)
  private
    function TargetTab(const he, h_tabs_container: IDomElement): IDomElement;
    // select
    function SelectTab(var tabs_el, tab_el: IDomElement): Boolean; overload;
    // select next/prev/first/last tab
    function SelectTab(var tabs_el, tab_el: IDomElement; direction: Integer): Boolean; overload;
    
    function IsInFocus(var el: IDomElement): Boolean;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    //function  OnTimer(const he: IDomElement): Boolean; override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT;
      var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT;
      var params: TMouseParams): Boolean; override;
    function  OnKeyDown(const he, target: IDomElement; event_type: UINT;
      var params: TKeyParams): Boolean; override;
    function  OnEvent(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS};
      var params: TBehaviorEventParams): Boolean; override;

  end;

implementation

{ TTabBehavior }

function TTabBehavior.IsInFocus(var el: IDomElement): Boolean;
begin
  Result := el.Match(':focus', []) or (el.FindNearestParent(':focus', [])<>nil);
end;

procedure TTabBehavior.OnAttached(const he: IDomElement);
var
  tabs_el, tab_el, panel_el, tab_strip_el: IDomElement;
  pname: WideString;
begin
  tabs_el := he;
  //:root below matches the element we use to start lookup from.
  tab_el := tabs_el.FindFirst(':root>.strip>[panel][selected]', []);
  if tab_el <> nil then
    pname := tab_el.Attributes['panel'];
    
  // find panel we need to show by default
  panel_el := tabs_el.FindFirst(':root>[name="%S"],:root>[id="%S"]', [pname, pname]);
  if (panel_el=nil) or (not panel_el.IsValid) then
  begin
    Assert(False); // what a ...!, panel="somename" without matching name="somename"
    Exit;
  end;

  tab_strip_el := tabs_el.Parent;
  tab_strip_el.SetStateEx(STATE_CURRENT, 0); // :current - make tab strip as current element inside focusable.
  tab_el.SetStateEx(STATE_CURRENT, 0); // :current - current tab is, well, current.
  panel_el.SetStateEx(STATE_EXPANDED, 0); // :expanded - current panel is expanded.

  //tabs_el.StartTimer(1000, 12345);
end;

function TTabBehavior.OnEvent(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  newtab, tabs: IDomElement;
begin
  if not IsBubbling(_type) then
  begin
    Result := False;
    Exit;
  end;

  if _type = ACTIVATE_CHILD then
  begin
    newtab := TargetTab(target, he);
    if (newtab = nil) or (not newtab.IsValid) then
    begin
      assert(false); // target is not a tab here.
      Result := True;
      Exit;
    end;

    tabs := he;
    SelectTab(tabs, newtab);
    Result := True;
  end
  else
   Result := False;
end;

function TTabBehavior.OnKeyDown(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
var
  tabs_el, tab_el: IDomElement;
begin
  if not IsBubbling(event_type) then
  begin
    Result := False;
    Exit;
  end;
  
  Result := False;
  
  if event_type in [KEY_DOWN] then
  begin
    tabs_el := he; // our tabs container
    tab_el  := tabs_el.FindFirst(':root>.strip>[panel]:current', []); // currently selected

    if tab_el = nil then
      Exit;

    case params.key_code of
      VK_TAB:
      begin
        if  params.alt_state and CONTROL_KEY_PRESSED <> 0 then
        begin
          if params.alt_state and SHIFT_KEY_PRESSED <> 0 then
            Result := SelectTab(tabs_el, tab_el, -1)
          else
            Result := SelectTab(tabs_el, tab_el, 1);
        end;
      end;
      VK_LEFT:
      begin
        if IsInFocus(tab_el) then
          Result := SelectTab(tabs_el, tab_el, -1 );
      end;
      VK_RIGHT:
      begin
        if IsInFocus(tab_el) then
          Result := SelectTab(tabs_el, tab_el, 1 );
      end;
      VK_HOME:
      begin
        if IsInFocus(tab_el) then
          Result := SelectTab(tabs_el, tab_el, -2);
      end;
      VK_END:
      begin
        if IsInFocus(tab_el) then
          Result := SelectTab(tabs_el, tab_el, 2);
      end;
    end;
  end;
  // we are handling only KEY_DOWN here
end;

function TTabBehavior.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  tabs_el, tab_el: IDomElement;
begin
  if not IsBubbling(event_type) then
  begin
    Result := False;
    Exit;
  end;
  
  tabs_el := he; // our tabs container
  tab_el  := TargetTab(target, he);

  if not tabs_el.IsValid then
  begin
    Result := False;
    Exit;
  end;

  //el here is a <element panel="panel-id1">tab1 caption</element>
  //and we've got here MOUSE_DOWN somewhere on it.
  if tab_el <> nil then
    Result := SelectTab(tabs_el, tab_el)
  else
    Result := False;
end;

function TTabBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  tabs_el, tab_el: IDomElement;
begin
  if not IsBubbling(event_type) then
  begin
    Result := False;
    Exit;
  end;

  tabs_el := he; // our tabs container
  tab_el  := TargetTab(target, he);

  if not tabs_el.IsValid then
  begin
    Result := False;
    Exit;
  end;

  //el here is a <element panel="panel-id1">tab1 caption</element>
  //and we've got here MOUSE_DOWN somewhere on it.
  if tab_el <> nil then
    Result := SelectTab(tabs_el, tab_el)
  else
    Result := False;
end;


function TTabBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE or 
                 HANDLE_KEY or
                 HANDLE_FOCUS or
                 HANDLE_BEHAVIOR_EVENT or
                 HANDLE_TIMER;
  Result := True;
end;

//function TTabBehavior.OnTimer(const he: IDomElement): Boolean;
//begin
//  MessageBeep(MB_ICONASTERISK);
//  Result := True;
//end;

function TTabBehavior.SelectTab(var tabs_el, tab_el: IDomElement): Boolean;
var
  prev_panel_el, prev_tab_el, panel_el: IDomElement;
  pname: WideString;
begin   
  if(tab_el.TestState(STATE_CURRENT))  then
  begin
    // already selected, nothing to do...
    Result := True;
    Exit;
  end;
     
  //find currently selected element (tab and panel) and remove "selected" from them
  prev_panel_el := tabs_el.FindFirst(':root>:not(.strip):expanded', []);
  prev_tab_el := tabs_el.FindFirst(':root>.strip>[panel]:current', []);

  // find new tab and panel       
  pname := tab_el.Attributes['panel'];
  panel_el := tabs_el.FindFirst(':root>[name="%S"],:root>[id="%S"]', [pname, pname]);
      
  if (not panel_el.IsValid) or (not tab_el.IsValid)  then
  begin
    assert(false); // panel="somename" without matching name="somename"
    Result := true;
    Exit;
  end;

  if prev_panel_el.IsValid then
  begin
    prev_panel_el.RemoveAttribute('selected'); // remove selected attribute - just in case somone is using attribute selectors
    prev_panel_el.SetStateEx(STATE_COLLAPSED, 0); // set collapsed in case of someone use it for styling
  end;
  if prev_tab_el.IsValid then
  begin
    prev_tab_el.RemoveAttribute('selected'); // remove selected attribute
    prev_tab_el.SetStateEx(0, STATE_CURRENT); // reset also state flag, :current
  end;

  panel_el.Attributes['selected'] := 'true'; // set selected attribute (empty)
  panel_el.SetStateEx(STATE_EXPANDED,0);     // expand it
      
  tab_el.Attributes['selected'] := 'true';  // set selected attribute (empty)
  tab_el.SetStateEx(STATE_CURRENT,0);       // set also state flag, :current
                  
  // notify all parties involved
  if prev_tab_el.IsValid then
    prev_tab_el.PostEvent(ELEMENT_COLLAPSED,0, prev_tab_el); // source here is old collapsed tab itself
    
  tab_el.PostEvent(ELEMENT_EXPANDED,0, tab_el);  // source here is new expanded tab itself
  // NOTE #1: these event will bubble from panel elements up to the root so panel itself, tabs ctl, its parent, etc.
  // will receive these notifications. Handle them if you need to change UI dependent from current tab. 
  // NOTE #2: while handling this event in:
  //        virtual bool on_event (HELEMENT he, HELEMENT target, BEHAVIOR_EVENTS type, UINT reason ),
  // HELEMENT target is the panel element being collapsed/expanded
      
  Result := true;
end;

function TTabBehavior.SelectTab(var tabs_el, tab_el: IDomElement;
  direction: Integer): Boolean;
var
  new_tab_el: IDomElement;
  rdirection: Integer;
begin
  rdirection := direction;
  
  // find new tab
  case direction of
    -2:
    begin
      new_tab_el := tab_el.First();
      rdirection := +1;
    end;
    -1: new_tab_el := tab_el.Prior();
    +1: new_tab_el := tab_el.Next();
    +2:
    begin
      new_tab_el := tab_el.Last();
      rdirection := -1;
    end;
  else
    Result := False;
    Exit;
  end;

  if (new_tab_el = nil) or (not new_tab_el.IsValid) or (new_tab_el.Attributes['panel'] = '') then //is not a tab element
  begin
    Result := False;
    Exit;
  end;

  if (not new_tab_el.GetEnable) or (not new_tab_el.GetVisible) then  // if it is either disabled or not visible - try next
  begin
    Result := SelectTab(tabs_el, new_tab_el, rdirection);
    Exit;
  end;

  Result := SelectTab( tabs_el, new_tab_el );
end;

function TTabBehavior.TargetTab(const he,
  h_tabs_container: IDomElement): IDomElement;
var
  el: IDomElement;
  panel_name: WideString;
begin
  if (not he.IsValid) or he.Equal(h_tabs_container) then
  begin
    Result := nil;
    Exit;
  end;
  el := he;
  panel_name := el.Attributes['panel'];
  if panel_name <> '' then
  begin
    Result := el;
  end
  else
    Result := TargetTab(el.Parent, h_tabs_container)
end;

initialization
  

finalization
  BehaviorFactorys.UnReg('tabs');

end.
