unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterTypes;

type
  TEPPortalWindow = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure OnSize(const he: IDomElement);
    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
    function  OnMenuItemClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
  end;

var
  EPPortalWindow: TEPPortalWindow;

implementation

{$R *.dfm}

uses
  SciterBehavior,
  Behavior.MoreBtn,
  Behavior.LogoBtn,
  Behavior.MyWebBrowser,
  Behavior.MenuHover,
  AboutFrm;

procedure TEPPortalWindow.FormCreate(Sender: TObject);
begin
  inherited;
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('logo-button', TLogoButtonBehavior));
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('more-button', TMoreButtonBehavior));
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('myWebBrowser', TMyWebBrowserBehavior));
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('menuhover', TMenuHoverBehavior));

  Behavior.OnSize :=  OnSize;
  Behavior.OnButtonClick := OnButtonClick;
  Behavior.OnMenuItemClick := OnMenuItemClick;
end;

procedure TEPPortalWindow.FormDestroy(Sender: TObject);
begin
  Layout.BehaviorFactorys.UnReg('cmd-button');
  Layout.BehaviorFactorys.UnReg('logo-button');
  Layout.BehaviorFactorys.UnReg('myWebBrowser');
  Layout.BehaviorFactorys.UnReg('menuhover');
  inherited;
end;

function TEPPortalWindow.OnButtonClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  eleHeader: IDomElement;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  if he.ID = 'about1' then
  begin
    ShowAboutFrom(True);
    Result := True;
  end
  else
  if he.ID = 'about2' then
  begin
    ShowAboutFrom(False);
    Result := True;
  end
  else
  if he.ID = 'cycd_pfcj' then
  begin
    ShowMessage('Äúµã»÷ÁË ' + he.Text);

    Result := True;
  end
  else
  if he.ID = 'maxContainer' then
  begin
    if he.Parent.Attributes['state'] = 'max' then
    begin
      eleHeader := he.Root.Parent.Root.FindFirst('#header');
      if eleHeader <> nil then
      begin
        eleHeader.Style['visibility'] := 'none';
        he.Parent.Attributes['state'] := 'restore';
      end;
    end
    else
    if he.Parent.Attributes['state'] = 'restore' then
    begin
      eleHeader := he.Root.Parent.Root.FindFirst('#header');
      if eleHeader <> nil then
      begin
        eleHeader.Style['visibility'] := 'visible';
        he.Parent.Attributes['state'] := 'max';
      end;
    end
    else
      Exit;

    Result := True;
  end
end;

function TEPPortalWindow.OnMenuItemClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  if he.ID = 'mnExit' then
  begin
    Close;
    Result := True;
  end
  else
  if he.ID = 'mnAbout' then
  begin
    ShowAboutFrom(True);

    Result := True;
  end
end;

procedure TEPPortalWindow.OnSize(const he: IDomElement);
begin
  OutputDebugString(PChar('TEPPortalWindow.OnSize'));
end;

end.
