unit AboutFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterTypes;

type
  TTest = class(TSciterRttiObject)
  public
    procedure showMessage(const AMsg: WideString);
  end;

  TAboutForm = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    FTest: TTest;
    FInit: Boolean;
    function  OnDocumentComplete(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
    function  OnCreateNativeObject(const ALayout: ISciterLayout; const AObjectName: SciterString;
      argCount: Integer; args: Ptiscript_value_array): IDispatch;
  public
    { Public declarations }
  end;

procedure ShowAboutFrom(Modal: Boolean);

implementation

{$R *.dfm}

uses
  ObjComAutoEx;

procedure ShowAboutFrom(Modal: Boolean);
var
  AboutForm: TAboutForm;
begin
  AboutForm := TAboutForm.Create(nil);
  AboutForm.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'EPPortal\about.html');
  if Modal then
    AboutForm.ShowModal
  else
    AboutForm.Show;
end;  

{ TAboutForm }

var
  AppInfoArray: array[0..6] of array[0..1] of string = (
    ('网上申报(河北简版)', 'V7.2.001'),
    ('重点税源信息采集', 'V1.0.012'),
    ('电子税务局(标准版)', 'V1.0.005'),
    ('普票管理(河北标准版)', 'V1.0.115'),
    ('发票工具箱', 'V1.0.011'),
    ('易税门户', 'V3.0.007'),
    ('重点税源信息采集', 'V1.0.012')
  );


procedure TAboutForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  //OutputDebugString('TAboutForm.FormClose');
  Action := caFree;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  inherited;
  FTest := TTest.Create;
  Layout.OnCreateNativeObject := OnCreateNativeObject;
  //Layout.RegisterObject('Test', WrapObjectDispatch(FTest));
  Behavior.OnDocumentComplete := OnDocumentComplete;
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
  inherited;
  FTest.Free;
  //OutputDebugString('TAboutForm.FormDestroy');
end;

function TAboutForm.OnCreateNativeObject(const ALayout: ISciterLayout;
  const AObjectName: SciterString; argCount: Integer; args: Ptiscript_value_array): IDispatch;
begin
  if AObjectName = 'Test' then
  begin
    Result := WrapObjectDispatch(FTest);
    Exit;
  end;
end;

function TAboutForm.OnDocumentComplete(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  eleAppList, eleAppListItem, eleAppListCap, eleAppListVer: IDomElement;
  i: Integer;
begin
  Result := False;
 
  if FInit then
    Exit;
  FInit := True;

  eleAppList := Layout.RootElement.FindFirst('#app_list');
  if eleAppList <> nil then
  begin
    for i := Low(AppInfoArray) to High(AppInfoArray) do
    begin
      eleAppListItem := eleAppList.CreateElement('li');
      eleAppListCap := eleAppListItem.CreateElement('div', AppInfoArray[i][0]);
      eleAppListVer := eleAppListItem.CreateElement('div', AppInfoArray[i][1]);
      
      eleAppList.Append(eleAppListItem);
      eleAppListItem.Append(eleAppListCap);
      eleAppListItem.Append(eleAppListVer);
      
      eleAppListItem.Attributes['class'] := 'app_list_item';
      eleAppListCap.Attributes['class'] := 'app_list_cap';
      eleAppListVer.Attributes['class'] := 'app_list_ver';
    end;
  end;

  Result := True;
end;

{ TTest }

procedure TTest.showMessage(const AMsg: WideString);
begin
  Dialogs.ShowMessage(AMsg);
end;

end.
