unit Behavior.MyWebBrowser;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TMyWebBrowserBehavior = class(TBehaviorEventHandler)
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
  end;

implementation

uses
  MyWebBrowser;

{ TMyWebBrowserBehavior }

procedure TMyWebBrowserBehavior.OnAttached(const he: IDomElement);
var
  sUrl: WideString;
begin
  if he.Root.Attributes['initWebBrower'] = 'true' then
    Exit;
  he.Root.Attributes['initWebBrower'] := 'true';
  he.Root.Attributes['FinalWebBrower'] := '';

  webBrowser := TSciterWebBrowser.CreateParented(he.GetElementHwnd);
  he.AttachHwnd(webBrowser.Handle);

  sUrl := he.Attributes['data-url'];
  if (sUrl <> '') and (sUrl <> webBrowser.URL) then
  begin
    webBrowser.Navigate(sUrl);
  end;
  webBrowser.Visible := True;
end;

procedure TMyWebBrowserBehavior.OnDetached(const he: IDomElement);
begin
  if he.Root.Attributes['FinalWebBrower'] = 'true' then
    Exit;
  he.Root.Attributes['initWebBrower'] := '';
  he.Root.Attributes['FinalWebBrower'] := 'true';

  if webBrowser <> nil then
  begin
    he.AttachHwnd(0);
    FreeAndNil(webBrowser);
  end;
end;

end.
