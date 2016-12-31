unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterTypes;

type
  TMainForm = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
  private
    function  OnHyperlinkClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ShellAPI, CommCtrl, DesktopUtils;

{ TMainForm }

function TMainForm.OnHyperlinkClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  path: WideString;
begin
  if not IsBubbling(_type) then
  begin
    Result := False;
    Exit;
  end;
  path := he.Attributes['href'];
  if path <> EmptyStr then
    ShellExecuteW(he.GetElementHwnd, nil,PWideChar(path), nil, nil, SW_shownormal);
  Result := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  Behavior.OnHyperlinkClick := OnHyperlinkClick;
end;

end.
