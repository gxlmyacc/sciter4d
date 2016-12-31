unit Behavior.MoreBtn;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TMoreButtonBehavior = class(TBehaviorEventHandler)
  protected
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseLeave(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

uses
  Dialogs, SciterFactoryIntf;

{ TMoreButtonBehavior }

function TMoreButtonBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  navbar: IDomElement;
  rc: TRect;
  x, y, w: IDomValue;
begin
  if not IsBubbling(event_type) then
  begin
    Result := False;
    Exit;
  end;
  navbar := he.Root.FindFirst('#header ul.navbar');
  if navbar <> nil then
  begin
    rc := navbar.GetLocation;

    x := ValueFactory.Create(rc.Left);
    y := ValueFactory.Create(rc.Bottom - 4);
    w := ValueFactory.Create(rc.Right - rc.Left);
    he.Root.CallFunction('popupMoreApp', [x, y, w]);
  end;
  Result := True;
end;

function TMoreButtonBehavior.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

function TMoreButtonBehavior.OnMouseLeave(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  //Layout.RootElement.CallFunction('closeMoreApp');

  Result := True;
end;

function TMoreButtonBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

end.
