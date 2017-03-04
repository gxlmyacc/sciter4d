unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterTypes, TypInfo, StdCtrls, TiscriptIntf;

type
  TTest = class;
  
  TMainForm = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
    function  OnDocumentComplete(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
    function  OnDocumentCloseRequest(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
    function  OnDataArrived(const he: IDomElement; initiator: IDomElement; var params: TDataArrivedParams): Boolean; virtual;

    function  OnLayoutLoadData(var pnmld: LPSCN_LOAD_DATA; const schema: PSciterSchemaInfo; var Handled: Boolean): TLoadDataResult;
    function  OnCreateNativeObject(const ALayout: ISciterLayout; const AObjectName: SciterString;
      argCount: Integer; args: PSciterDomValueArray): IDispatch;
  public
    FButton: TButton;
    FTest: TTest;
    FData: WideString;
    //FRequestDivHandler: IDefalutBehaviorEventHandler;

    procedure OnNativeButtonClick(Sender: TObject);
  end;

  TTest = class(TSciterRttiObject)
  private
    FName: WideString;
    function GetKey(const s: string): string;
  public
    constructor Create(const AName: WideString);
    destructor Destroy; override;
  public
    function  GetName: WideString;
    procedure SetName(const Value: WideString);

    property Key[const s: string]: string read GetKey; default;

    procedure ShowMessage(const Msg, Msg2: WideString);
  published
    property Name: WideString read GetName write SetName;
  end;

var
  MainForm: TMainForm;
  varTest: TTest;

implementation

{$R *.dfm}

uses
  FrmDataEdit, SciterFactoryIntf, ObjComAutoEx;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  FTest := TTest.Create('属于一个页面的全局对象');
  Tiscript.RegisterObject('Test1', WrapObjectDispatch(FTest), Layout.VM);
  
  Layout.OnCreateNativeObject := OnCreateNativeObject;
  Layout.OnLoadData           := OnLayoutLoadData;

  Behavior.OnDocumentCloseRequest := OnDocumentCloseRequest;
  Behavior.OnDocumentComplete     := OnDocumentComplete;
  Behavior.OnButtonClick          := OnButtonClick;
end;

function TMainForm.OnButtonClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  LData: IDomValue;
  LDiv: IDomElement;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;

  if he.ID = 'get' then
  begin
    FData :=  he.Root.CallFunction('getDataFromView', []).AsString();
    Result := True;
  end        
  else
  if he.ID = 'set' then
  begin
    LData := ValueFactory.Create(FData);
    he.Root.CallFunction('setDataToView', [LData]);

    Result := True;
  end
  else
  if he.ID = 'show' then
  begin
    frm_DataEdit.memData.Lines.Text := FData;
    if frm_DataEdit.ShowModal = mrOk then
      FData := frm_DataEdit.memData.Lines.Text;

    Result := True;
  end
  else
  if he.ID = 'cmdRequest' then
  begin
    LDiv := Layout.RootElement.FindFirst('#divRequest');
    LDiv.LoadData('http://terrainformatica.com/sciter');

    Result := True;
  end
end;

function TMainForm.OnCreateNativeObject(const ALayout: ISciterLayout;
  const AObjectName: SciterString; argCount: Integer; args: PSciterDomValueArray): IDispatch;
begin
  if AObjectName = 'Test1' then
  begin
    ShowMessage(args[0].AsString);
    Result := WrapObjectDispatch(TTest.Create('临时变量'), True);
  end
  else
    Result := nil;
end;

function TMainForm.OnDocumentComplete(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  pDiv: IDomElement;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;
    
  pDiv := Layout.RootElement.FindFirst('#nativeButton');
  if pDiv <> nil then
  begin
    FButton := TButton.Create(Self);
    FButton.Parent := Self;
    FButton.Caption := 'Native Button';
    FButton.OnClick := OnNativeButtonClick;
    FButton.Font.Color := clGreen;
    pDiv.AttachHwnd(FButton.Handle);
  end;

  pDiv := Layout.RootElement.FindFirst('#divRequest');
  pDiv.Behavior.OnDataArrived := OnDataArrived;

  //FRequestDivHandler := Sciter.CreateDefalutHandler;
  //pDiv.AttachEventHandler(FRequestDivHandler);
  //FRequestDivHandler.OnDataArrived := OnDataArrived;
  
  Result := True;
end;

procedure TMainForm.OnNativeButtonClick(Sender: TObject);
begin
  ShowMessage('OnNativeButtonClick');
end;

function TMainForm.OnLayoutLoadData(var pnmld: LPSCN_LOAD_DATA; const schema: PSciterSchemaInfo;
  var Handled: Boolean): TLoadDataResult;
var
  sUrl, sFileName: string;
  pMemStm: TMemoryStream;
begin
  sUrl := pnmld.uri;
  
  if Pos('scide://', sUrl) = 1 then
  begin
    sFileName := ExtractFilePath(ParamStr(0)) + 'Repeatable\' + StringReplace(sUrl, 'scide://', '', []);
    pMemStm := TMemoryStream.Create;
    pMemStm.LoadFromFile(sFileName);
    pMemStm.Position := 0;
    Layout.DataReady(sUrl, pMemStm.Memory, pMemStm.Size);
    pMemStm.Free;
    Result := LOAD_OK;
    Exit;
  end;

  Result := LOAD_DISCARD;
end;

function TMainForm.OnDataArrived(const he: IDomElement;
  initiator: IDomElement; var params: TDataArrivedParams): Boolean;
var
  sText: string;
begin
  sText := Format('Got %d bytes of data from %s. HTTP status: %d', [params.dataSize, wideString(params.uri), params.Status]);
  he.Text := sText;
  Result := True;
end;

function TMainForm.OnDocumentCloseRequest(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then Exit;
end;

{ TTest }

constructor TTest.Create(const AName: WideString);
begin
  FName := AName;
end;

destructor TTest.Destroy;
begin
  inherited;
end;

function TTest.GetKey(const s: string): string;
begin
  Result := '';
end;

function TTest.GetName: WideString;
begin
  Result := FName;
end;

procedure TTest.SetName(const Value: WideString);
begin
  FName := Value;
end;

procedure TTest.ShowMessage(const Msg, Msg2: WideString);
begin
  Dialogs.ShowMessage('[TTest.ShowMessage]['+FName+']['+Msg+']'+Msg2);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  //FRequestDivHandler := nil;
  FTest := nil;
  inherited;
end;

initialization
  varTest := TTest.Create('属于应用程序的全局对象');

finalization
  if varTest <> nil then
    FreeAndNil(varTest);

end.
