unit MainFrm;

interface

uses
  SysUtils, Classes, Controls, Forms,
  SciterFrm, SciterIntf;

type
  Td360Window = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  d360Window: Td360Window;

implementation

{$R *.dfm}

uses
  SciterBehavior,
  Behavior.CmbBtn,
  Behavior.menuBtn,
  Behavior.LogoBtn;

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

end.
