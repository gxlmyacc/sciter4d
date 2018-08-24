{*******************************************************************************
 标题:     Behavior.MenuTab.pas
 描述:     标签页 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.MenuTab;

interface

uses
  SysUtils, Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  (*

  BEHAVIOR: menutab
     goal: menutab行为的实现，类似一个Tab标签页行为
  VIEWS:
     | 标签1 | 标签2 | 标签3 |
     -------------------------
     |                       |
     |          面板         |
     |                       |
     |_______________________|
  COMMENTS:
      <ul>
         <li href|target="panel-name1" style="behavior:menutab" group="groupDemo" selected >标签1</li>
         <li href|target="panel-name2" style="behavior:menutab" group="groupDemo" >标签2</li>
         <li href|target="panel-name3" style="behavior:menutab" group="groupDemo" noselect>标签3</li>
         <li href|target="panel-name4" style="behavior:menutab" group="groupDemo" onselect="execSomeFunc(this);">标签3</li>
         <li href|target="panel-name5" style="behavior:menutab" group="groupDemo" onselected="afterSelect(this);">标签4</li>
         <li href|target="panel-name6" style="behavior:menutab" group="groupDemo" trigger="hover" >标签4</li>
      </ul>
      <div>
        <div name="panel-name1" group="groupDemo" > 面板1 </div>
        <div name="panel-name2" group="groupDemo" alwaysload > 面板2 </div>
     </div>
  NOTE:
     1、 如果一个页面中有多个【标签】使用了【menutab】行为，则不同的【标签】需要使用【group】进行分组；
     2、 【标签】元素中的【href】属性指定当点击【标签】时显示的【面板】元素;
     3、  包含【selected】属性的【标签】元素，表示初始化页面时默认选中的【标签】及默认显示的【面板】;
     4、 【标签】和【面板】元素的位置可以随意放，该行为的查找规则是中html根元素下找，但不能超过一个页面；
     5、 可以在脚本中调用【selectTab】函数来选中该【标签】，比如【el.selectTab()】；
     6、 指定了【alwaysload】属性的【面板】元素在每次选择【标签】时都会重新加载【面板】的内容；
     7、 指定了【noselect】属性的【标签】单击是不会更新【面板】元素内容，这时用户可以对该【标签】绑定onClick事件进行处理；
     8、 如果【标签】有name属性，则选中该【标签】时会将【标签】的name和group属性值分别写到【面板】元素的【menu-name】【menu-group】属性上；
     9、 当选中【标签1】时，【标签1】.state会增加【expand】状态，同时产生【expand】事件；
     10、当【标签1】不再选中时【expand】状态会去掉，同时添加【collapsed】状态, 同时产生【collapsed】事件；
     11、当选中【标签1】时，【面板1】显示后增加【activechild】状态，同时产生【statechange】事件；
     12、如果【标签1】有onselect属性，则在选择该标签前将把onselect的值作为一个表达式来执行，如果表达式返回true,则不再切换【面板】内容；
     13、如果【标签1】有onselected属性，则在【面板1】内容成功改变后将onselected的值作为一个表达式来执行，可以在这个事件里做一些扫尾工作；
     14、如果【标签1】有trigger属性，且值为hover，则该标签页不是通过鼠标点击激活的，而是当鼠标进入该标签页时即激活；
  *)
  TMenuTabBehavior = class(TBehaviorEventHandler)
  private
    FGroup: SciterString;
    FElement: HELEMENT;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  published
    function selectTab: Boolean;
  end;

function _GetTargetName(const he: IDomElement): SciterString;
function _GetSelectedElement(const he: IDomElement; const AGroup: SciterString): IDomElement;
function _MenuTabLoadFrame(const he, target: IDomElement): Boolean;
function _MenuTabSelectTab(const he: IDomElement; const AGroup: SciterString;
  const doAnimation: Boolean = True): Boolean;

implementation

uses
  SciterFactoryIntf, SciterApiImpl;

const
  Trigger_Click = 'click';
  Trigger_Hover = 'hover';

{ TMenuTabBehavior }

function _GetTargetName(const he: IDomElement): SciterString;
begin
  Result := he.Attributes['target'];
  if Result = EmptyStr then
    Result := he.Attributes['href'];
end;

function _GetSelectedElement(const he: IDomElement; const AGroup: SciterString): IDomElement;
begin
  Result := he.Root.FindFirst('[target][selected]'+AGroup, []);
  if Result = nil then
    Result := he.Root.FindFirst('[href][selected]'+AGroup, []);
end;

function _MenuTabLoadFrame(const he, target: IDomElement): Boolean;
var
  sUrl: SciterString;
  bAlwaysLoad, bLoaded: Boolean;
begin
  Result := False;
  sUrl :=  target.Attributes['url'];
  if sUrl = '' then
  begin
    sUrl :=  he.Attributes['url'];
    if sUrl = '' then
      Exit;
  end;

  bAlwaysLoad := target.IndexOfAttribute('alwaysload') >= 0;
  bLoaded := target.IndexOfAttribute('-menutab-url-loaded') >= 0;
  if bLoaded and (not bAlwaysLoad) then
  begin
    Result := True;
    Exit;
  end;
  sUrl := Sciter.DecodeURI(target.CombineURL(Sciter.EncodeURI(sUrl)));
  target.LoadHtml(sUrl);
  if not bLoaded then
    target.Attributes['-menutab-url-loaded'] := '';
  Result := True;
end;

function _MenuTabSelectTab(const he: IDomElement; const AGroup: SciterString; const doAnimation: Boolean): Boolean;
var
  selectedEle, selectedPanel, Ltarget, LtargetP, LChild: IDomElement;
  i, v: Integer;
  iIsBefore: Integer;
  sAnimation, sTarget, sEvent: SciterString;
  val: SCITER_VALUE;
  pType: TDomValueType; 
  pUnits: UINT;
begin
  Result := False;
  if he.IndexOfAttribute('noselect') >= 0 then
    Exit;
  //如果绑定了onselect事件，则直接执行这个事件
  sEvent := he.Attributes['onselect'];
  if sEvent <> '' then
  begin
    if SAPI.SciterEvalElementScript(he.Element, PWideChar(sEvent), Length(sEvent), val) <> SCDOM_OK  then
      Exit;
    SAPI.ValueType(val, pType, pUnits);
    if pType = T_BOOL then
    begin
      SAPI.ValueIntData(val, v);
      if v <> 0 then
        Exit;
    end;
  end;
  
  sTarget := _GetTargetName(he);
  if sTarget = EmptyStr then
    Exit;
  Ltarget := he.Root.FindFirst('[name="%s"]'+AGroup, [sTarget]);
  if Ltarget = nil then
    Exit;

  //隐藏原标签
  selectedEle := _GetSelectedElement(he, AGroup); 
  iIsBefore := -1;
  if (selectedEle <> nil) then
  begin
    if doAnimation and selectedEle.Equal(he) and (not he.HasAttribute('alwaysload')) then
    begin
      Result := True;
      Exit;
    end;
    selectedPanel := he.Root.FindFirst('[name="%s"]'+AGroup, [_GetTargetName(selectedEle)]);
    if selectedPanel <> nil then
      selectedPanel.ClearState(ACTIVATE_CHILD);

    selectedEle.RemoveAttribute('selected');
    if selectedEle.UID > he.UID then
      iIsBefore := 1
    else                     
      iIsBefore := 0;              
    selectedEle.SetStateEx(STATE_COLLAPSED, STATE_EXPANDED or ACTIVATE_CHILD);
    selectedEle.PostEvent(STATE_COLLAPSED);
  end;                                      
  he.Attributes['selected'] := '';

  //设置目标显示
  LtargetP := Ltarget.Parent;
  for i := 0 to LtargetP.ChildCount - 1 do
  begin
    LChild := LtargetP.Child[i];
    if LChild = nil then
      continue;
    if LChild.Attributes['name'] <> '' then
      LChild.Style['visibility'] := 'none';
  end;

  if doAnimation and (iIsBefore >= 0) then
  begin
    if iIsBefore=1 then
      sAnimation := Ltarget.Attributes['before-animation']
    else
      sAnimation := Ltarget.Attributes['after-animation'];

    if sAnimation <> '' then
      Ltarget.Style['transition'] := sAnimation;
  end;
  
  if he.Attributes['name'] <> '' then
    Ltarget.Attributes['menu-name'] := he.Attributes['name']
  else
    Ltarget.RemoveAttribute('menu-name');
  Ltarget.Attributes['menu-group'] := he.Attributes['group'];

  he.SetStateEx(STATE_EXPANDED, STATE_COLLAPSED);
  he.PostEvent(ELEMENT_EXPANDED);
  
  Ltarget.Style['visibility'] := 'visible';
  Ltarget.PostEvent(ACTIVATE_CHILD);
  Ltarget.PostEvent(UI_STATE_CHANGED);
  
  Result := _MenuTabLoadFrame(he, Ltarget);
  if Result then
  begin
    sEvent := he.Attributes['onselected'];
    if sEvent <> '' then
      SAPI.SciterEvalElementScript(he.Element, PWideChar(sEvent), Length(sEvent), val);
  end;
end;

procedure TMenuTabBehavior.OnAttached(const he: IDomElement);
var
  selectedEle: IDomElement;
  sGroup: SciterString;
begin
  sGroup := he.Attributes['group'];
  FGroup := sGroup;
  if FGroup <> EmptyStr then
    FGroup := '[group="'+FGroup+'"]';
  FElement := he.Element;
  
  if he.Root.IndexOfAttribute('-init-menutab-'+sGroup) >= 0 then
    Exit;
  he.Root.Attributes['-init-menutab-'+sGroup] := '';
  selectedEle := _GetSelectedElement(he, FGroup);
  if selectedEle <> nil then
    _MenuTabSelectTab(selectedEle, FGroup, False);
end;

procedure TMenuTabBehavior.OnDetached(const he: IDomElement);
begin
  he.RemoveAttribute('-init-menutab-'+he.Attributes['group']);
  FElement := nil;
end;

function TMenuTabBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if (not IsBubbling(event_type)) or (not he.IsValid) then
    Exit;
  if he.Attributes['trigger'] <> Trigger_Hover then
    Result := _MenuTabSelectTab(he, FGroup);
end;

function TMenuTabBehavior.OnMouseEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if (not IsBubbling(event_type)) or (not he.IsValid) then
    Exit;
  if he.Attributes['trigger'] = Trigger_Hover then
    Result := _MenuTabSelectTab(he, FGroup);
end;

function TMenuTabBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

function TMenuTabBehavior.selectTab: Boolean;
var
  LHe: IDomElement;
begin
  LHe := ElementFactory.Create(FElement);
  Result := _MenuTabSelectTab(LHe, FGroup);
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('menutab', TMenuTabBehavior));

finalization
  BehaviorFactorys.UnReg('menutab');


end.
