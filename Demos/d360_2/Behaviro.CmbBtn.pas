unit Behaviro.CmbBtn;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TCmdButtonBehavior = class(TBehaviorEventHandler)
  protected
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT): Boolean; override;
  end;

  TCmdButtonBehaviorFactory = class(TBehaviorFactory)
  public
    function CreateHandler(const he: IDomElement): IBehaviorEventHandler; override;
  end;

implementation

{ TCmdButtonBehavior }

function TCmdButtonBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT): Boolean;
var
  selectedEle, browser: IDomElement;
  sUrl: WideString;
begin
   selectedEle := he.Root.FindFirst('li[selected]');
   if selectedEle <> nil then
     selectedEle.Attributes['selected'] := '';

   //添加"selected"属性，也可以用 ltEle.selected = "true";
   he.Attributes['selected'] := 'true';
   browser := he.Root.FindFirst('[data-url]');
   if browser <> nil then
   begin
     sUrl := he.Attributes['url'];
     browser.LoadHtml(sUrl);
   end;

   Result := True;
end;

function TCmdButtonBehavior.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

function TCmdButtonBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons,
  keyboardStates: UINT): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

{ TCmdButtonBehaviorFactory }

function TCmdButtonBehaviorFactory.CreateHandler(
  const he: IDomElement): IBehaviorEventHandler;
begin
  Result := TCmdButtonBehavior.Create;
end;

end.
