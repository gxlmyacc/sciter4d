{*******************************************************************************
 标题:     Behavior.MenuTab.pas
 描述:     标签页(Sheet页是一个Frame) 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.FrameTab;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TFrameTabBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TFrameTabBehavior }

procedure TFrameTabBehavior.OnAttached(const he: IDomElement);
var
  selectedEle, browser: IDomElement;
  sUrl, sTarget: WideString;
begin
  if he.Parent.Attributes['InitFrameTab'] <> 'true' then
  begin
    he.Parent.Attributes['InitFrameTab'] := 'true';
    he.Parent.Attributes['FinalFrameTab'] := '';

    sTarget := he.Parent.Attributes['target'];
    selectedEle := he.Parent.FindFirst('li[selected]');
    if (sTarget <> EmptyStr) and (selectedEle <> nil) then
    begin
      browser := he.Root.FindFirst('[name=%s]', [sTarget]);
      if browser <> nil then
      begin
        sUrl := selectedEle.Attributes['url'];
        sUrl := he.CombineURL(Sciter.EncodeURI(sUrl));
        sUrl := StringReplace(sUrl, '\', '/', [rfReplaceAll]);
        browser.LoadHtml(sUrl);
      end;
    end;
  end;
end;

procedure TFrameTabBehavior.OnDetached(const he: IDomElement);
begin
  if he.Parent.Attributes['FinalFrameTab'] <> 'true' then
  begin
    he.Parent.Attributes['FinalFrameTab'] := 'true';
    he.Parent.Attributes['InitFrameTab'] := '';

  end;
end;

function TFrameTabBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT; var params: TMouseParams): Boolean;
var
  selectedEle, browser: IDomElement;
  sUrl, sAnimation, sTarget: WideString;
  bBefore: Boolean;
begin
  Result := False;  
  if not IsBubbling(event_type) then
  begin
    Exit;
  end;

  if he.Match('[noselected]', []) then
    Exit;
    
  bBefore := False;
  selectedEle := he.Parent.Parent.FindFirst('li[selected]');
  if selectedEle <> nil then
  begin
    selectedEle.RemoveAttribute('selected');

    bBefore :=  selectedEle.UID > he.UID;
  end;

  //添加"selected"属性
  he.Attributes['selected'] := '';
  
  if (selectedEle <> nil) and (selectedEle.UID = he.UID) then
      Exit;

  sTarget := he.Parent.Attributes['target'];
  if sTarget = '' then
    Exit;

  browser := he.Root.FindFirst('[name=%s]', [sTarget]);
  if browser <> nil then
  begin
    sUrl :=  he.Attributes['url'];
    if sUrl = EmptyStr then
      Exit;

    sUrl := he.CombineURL(Sciter.EncodeURI(sUrl));
    sUrl := StringReplace(sUrl, '\', '/', [rfReplaceAll]);
    
    if bBefore then
      sAnimation := browser.Attributes['before-animation']
    else
      sAnimation := browser.Attributes['after-animation'];

    if sAnimation <> EmptyStr then
      browser.Style['transition'] := sAnimation;

    browser.LoadHtml(sUrl);
  end;

  Result := True;
end;

function TFrameTabBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('frame-tab', TFrameTabBehavior));

finalization
  BehaviorFactorys.UnReg('frame-tab');

end.
