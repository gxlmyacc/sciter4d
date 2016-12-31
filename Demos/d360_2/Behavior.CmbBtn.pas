unit Behavior.CmbBtn;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TCmdButtonBehavior = class(TBehaviorEventHandler)
  protected
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TCmdButtonBehavior }

function TCmdButtonBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  selectedEle, browser: IDomElement;
  sUrl: WideString;
begin
  if event_type and SINKING <> SINKING then
  begin
    Result := False;
    Exit;
  end;

  selectedEle := he.Root.FindFirst('li[selected="true"]');
  if selectedEle <> nil then
    selectedEle.Attributes['selected'] := 'false';

  //ÃÌº”"selected" Ù–‘
  he.Attributes['selected'] := 'true';
  browser := he.Root.FindFirst('#main');
  if browser <> nil then
  begin
    sUrl := he.Attributes['url'];
    sUrl := he.CombineURL(sUrl);
    browser.LoadHtml(sUrl);
  end;

  Result := True;
end;

function TCmdButtonBehavior.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

function TCmdButtonBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

end.
