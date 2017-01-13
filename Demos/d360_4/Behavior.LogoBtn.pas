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
  ShellAPI, SciterFactoryIntf;

{ TLogoButtonBehavior }

function TLogoButtonBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  sUrl: WideString;
 // LBrowser: IDomElement;
begin
  if event_type and SINKING <> SINKING then
  begin
    Result := False;
    Exit;
  end;
  
  sUrl := he.Attributes['url'];
  if sUrl <> EmptyStr then
  begin
    he.Root.CallFunction('webGo', [ValueFactory.Create(sUrl)]);
    //LBrowser := he.Root.FindFirst('widget[type=webbrowser]');
    //if LBrowser <> nil then
    //  LBrowser.Eval('this.go("%s")', [sUrl]);
  end;
  Result := True;
end;

end.
