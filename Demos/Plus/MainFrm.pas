unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, SciterTypes, SciterIntf,
  Dialogs, SciterFrm;

type
  TMainForm = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;

  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

function TMainForm.OnButtonClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  if he.ID = 'getitem' then
  begin
    ShowMessage(Layout.Eval('Basket.items'));
    Result := True;
  end        
  else
  if he.ID = 'setitem' then
  begin
    Layout.Eval('Basket.items = [{name:"Æ»¹û", price:1.2, quantity:10}, {name:"éÙ×Ó", price:1.0, quantity:8}];');
    Layout.Eval('Basket.calcTotal()');
    Result := True;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  Behavior.OnButtonClick := OnButtonClick;
end;

end.
