unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, OleCtrls, SHDocVw;

type
  Td360Window = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
  public
    class function NewInstance: TObject; override;
  end;

var
  d360Window: Td360Window;

implementation

{$R *.dfm}

uses
  SciterBehavior,
  Behavior.CmbBtn,
  Behavior.menuBtn,
  Behavior.LogoBtn,
  MyWebBrowser;

procedure Td360Window.FormCreate(Sender: TObject);
begin
  inherited;
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('cmd-button', TCmdButtonBehavior));
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('logo-button', TLogoButtonBehavior));
  Layout.BehaviorFactorys.Reg(TBehaviorFactory.Create('menu-button', TMenuButtonBehavior));
end;

procedure Td360Window.FormDestroy(Sender: TObject);
begin
  Layout.BehaviorFactorys.UnReg('cmd-button');
  Layout.BehaviorFactorys.UnReg('logo-button');
  Layout.BehaviorFactorys.UnReg('menu-button');
  inherited;
end;

class function Td360Window.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  //TSciterForm(Result).Transparent := False;
end;

end.
