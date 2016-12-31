unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterBehavior, SciterTypes, SciterIntf, ExtCtrls,
  Menus;

type
  TMainForm = class(TSciterForm)
    tmTimer: TTimer;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure tmTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    function  OnDocumentComplete(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; 
  public
    FTimerEle: IDomElement;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  Behavior.OnDocumentComplete := OnDocumentComplete;
end;


procedure TMainForm.tmTimerTimer(Sender: TObject);
var
  LTarget: IDomElement;
  iWidth: Integer;
begin
  //¸è´Ê¶¯Ì¬Ð§¹û
  LTarget := Layout.RootElement.FindFirst('#lrc_area_copy');
  if LTarget <> nil then
  begin
    iWidth := StrToIntDef(StringReplace(LTarget.Style['width'], '%', '', []), 0);

    iWidth := iWidth + 1;
    LTarget.Style['width'] := IntToStr(iWidth mod 100) + '%';
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  tmTimer.Enabled := False;
  
  inherited;
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
  Close;
end;

function TMainForm.OnDocumentComplete(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if not tmTimer.Enabled then
    tmTimer.Enabled := True;
  
  Result := True;
end;

end.
