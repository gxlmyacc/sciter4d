unit Behavior.LogoBtn;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

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
    ShellExecuteW(he.GetElementHwnd, nil,PWideChar(sUrl), nil, nil, SW_shownormal);
  Result := True;
end;

end.
