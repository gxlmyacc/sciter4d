unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterBehavior, UminimalBehavior;

type
  TUminimalWindow = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FEventHandler: IBehaviorEventHandler;
  public
    { Public declarations }
  end;

var
  UminimalWindow: TUminimalWindow;

implementation

{$R *.dfm}

procedure TUminimalWindow.FormCreate(Sender: TObject);
begin
  inherited;
  FEventHandler := TUminimalBehavior.Create;
  if Layout <> nil then
    Layout.AttachDomEventHandler(FEventHandler);
end;

procedure TUminimalWindow.FormDestroy(Sender: TObject);
begin
  inherited;
  if Layout <> nil then
    Layout.DetachDomEventHandler(FEventHandler);
//
  FEventHandler := nil;
end;

end.
