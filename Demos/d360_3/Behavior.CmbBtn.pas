unit Behavior.CmbBtn;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior, MyWebBrowser;

type
  TCmdButtonBehavior = class(TBehaviorEventHandler)
  private
  protected
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

{ TCmdButtonBehavior }

procedure TCmdButtonBehavior.OnAttached(const he: IDomElement);
var
  LBrowserElement, browser: IDomElement;
  sUrl: WideString;
begin
  if he.Root.Attributes['initWebBrower'] = 'true' then
    Exit;
  he.Root.Attributes['initWebBrower'] := 'true';

  LBrowserElement := he.Root.FindFirst('widget[type=webbrowser]');
  if LBrowserElement <> nil then
  begin
    varBrowser := TSciterWebBrowser.CreateParented(LBrowserElement.GetElementHwnd);
    LBrowserElement.AttachHwnd(varBrowser.Handle);

    browser := he.Root.FindFirst('#main');
    if (browser <> nil)  then
    begin
      sUrl := he.Attributes['url'];
      sUrl := 'file://' + ExtractFilePath(ParamStr(0)) + 'd360_3\' + StringReplace(sUrl, '/', '\', [rfReplaceAll]);
      varBrowser.Web.Navigate(sUrl);
    end;
      
    varBrowser.Visible := True;
  end;
end;

procedure TCmdButtonBehavior.OnDetached(const he: IDomElement);
begin
  if varBrowser <> nil then
  begin
    he.AttachHwnd(0);
    FreeAndNil(varBrowser);
  end;
end;

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
  if (browser <> nil) and (varBrowser <> nil) then
  begin
    sUrl := he.Attributes['url'];
    sUrl := 'file://' + ExtractFilePath(ParamStr(0)) + 'd360_3\' + StringReplace(sUrl, '/', '\', [rfReplaceAll]);
    varBrowser.Web.Navigate(sUrl);
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
