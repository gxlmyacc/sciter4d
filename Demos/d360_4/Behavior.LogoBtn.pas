unit Behavior.LogoBtn;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior, MyWebBrowser;

type
  TLogoButtonBehavior = class(TBehaviorEventHandler)
  protected
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

uses
  ShellAPI;

{ TLogoButtonBehavior }

function TLogoButtonBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  sUrl: WideString;
begin
  if event_type and SINKING <> SINKING then
  begin
    Result := False;
    Exit;
  end;
  
  sUrl := he.Attributes['url'];
  if sUrl <> EmptyStr then
  begin
    varBrowser.Web.Navigate(sUrl);
  end;

  Result := True;
end;

end.
