unit Behavior.MenuHover;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TMenuHoverBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;

    function  OnMouseEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseLeave(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

uses
  SciterFactoryIntf;

{ TMenuHoverBehavior }

function TMenuHoverBehavior.OnMouseEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  elePopup, eleBusMenu, eleCaptionImg: IDomElement;
  rc: TRect;
  x, y, id: IDomValue;
  ptPopup: TPoint;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  eleBusMenu := he.FindNearestParent('.busMenu[state]');
  if (eleBusMenu <> nil) and (eleBusMenu.Attributes['state'] = 'cllopse') then
  begin
    eleCaptionImg := he; //.FindFirst('caption.icon');
    if eleCaptionImg <> nil then
    begin
      rc := eleCaptionImg.GetLocation(VIEW_RELATIVE);

      elePopup := he.Parent.FindFirst('.popup.busMenuItemDetailsPopup');
      if elePopup <> nil then
      begin
        if he.Parent.ID <> EmptyStr then
        begin
          ptPopup.X := rc.Right;
          ptPopup.Y := rc.Top;
         // elePopup.PopupAt(he.Parent, ptPopup);

          x  := ValueFactory.Create(ptPopup.X);
          y  := ValueFactory.Create(ptPopup.Y);
          id := ValueFactory.Create(he.Parent.ID);

          he.Root.CallFunction('popupBusMenu', [id, x, y]);
        end;
      end;

      Result := True;
    end;
  end;
end;

function TMenuHoverBehavior.OnMouseLeave(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
//var
//  eleBusMenu, elePopup: IDomElement;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

//  eleBusMenu := he.Root.FindFirst('.busMenu[state]');
//  if (eleBusMenu <> nil) and (eleBusMenu.Attributes['state'] = 'cllopse') then
//  begin
//    elePopup := he.FindFirst('.popup.busMenuItemDetailsPopup');
//    if elePopup <> nil then
//    begin
//      elePopup.HidePopup;
//      elePopup := nil;
//    end;
//  end;

 // Result := True;
end;

function TMenuHoverBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

end.
