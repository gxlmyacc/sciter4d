{*******************************************************************************
 标题:     SciterPluginImpl.pas
 描述:     Sciter4D扩展插件支持类定义实现单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterPluginImpl;

interface

uses
  SysUtils, Classes, Windows, SciterIntf, SciterBehaviorDef, SciterTypes,
  SciterHash, SciterPluginIntf;

type
  TSciterPluginList = class;

  TSciterPlugin = class(TInterfacedObject, ISciterPlugin)
  private
    FDestroying: Boolean;
    FLoadPluginProc:  TSciterLoadPluginProc;
    FCanUnloadPluginProc: TSciterCanUnloadPluginProc;
    FUnloadPluginProc: TSciterUnloadPluginProc;
    FSendMessageProc: TSciterSendMessageProc;
    FRequirePluginProc: TSciterRequirePluginProc;

    FOwner: TSciterPluginList;
    FLastError: SciterString;
    FBehaviorFactorys: IBehaviorFactorys;
    FPath: SciterString;
    FHandle: Cardinal;
    FData1: Pointer;
    FData2: Pointer;
    function GetBehaviorFactorys: IBehaviorFactorys;
    function GetHandle: Cardinal;
    function GetCanUnload: Boolean;
    function GetLastError: SciterString;
    function GetOwner: Pointer;
    function GetPath: SciterString;
    function GetData1: Pointer;
    function GetData2: Pointer;
    procedure SetOwner(const Value: Pointer);
    procedure SetPath(const Value: SciterString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const APath: SciterString);
    destructor Destroy; override;
    
    function Loaded: Boolean;

    function Implementator: Pointer;
    
    function  LoadPlugin(): Boolean;
    procedure UnloadPlugin;

    function  Require(const AParams: SciterString): IDispatch;

    function SendMessage(const Msg: WideString; wParam: WPARAM; lParam: LPARAM;
      var bHandle: Boolean; const AFilter: SciterString = ''): LRESULT;

    function  Broadcast(const Msg: WideString; wParam: WPARAM; lParam: LPARAM;
      var bHandle: Boolean; const AFilter: SciterString = ''): LRESULT; overload;
    procedure Broadcast(const Msg: WideString; wParam: WPARAM; lParam: LPARAM;
      const AFilter: SciterString = ''); overload;

    property LastError: SciterString read GetLastError;
    property Owner: Pointer read GetOwner write SetOwner;
    property Path: SciterString read GetPath write SetPath;
    property Handle: Cardinal read GetHandle;
    property CanUnload: Boolean read GetCanUnload;
    property BehaviorFactorys: IBehaviorFactorys read GetBehaviorFactorys;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

  TSciterPluginList = class(TInterfacedObject, ISciterPluginList)
  private
    FList: IInterfaceList;
    FPathHash: TStringHash;
    FPathHashValid: Boolean;
    FAfterLoadPlugin: TSciterAfterLoadPluginProc;
    FBeforeLoadPlugin: TSciterBeforeLoadPluginProc;
  protected
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): ISciterPlugin;
    function  GetItemByPath(const APath: SciterString): ISciterPlugin;
    function  GetAfterLoadPlugin: TSciterAfterLoadPluginProc;
    function  GetBeforeLoadPlugin: TSciterBeforeLoadPluginProc;
    procedure SetItem(const Index: Integer; const Value: ISciterPlugin);
    procedure SetItemByPath(const APath: SciterString; const Value: ISciterPlugin);
    procedure SetAfterLoadPlugin(const Value: TSciterAfterLoadPluginProc);
    procedure SetBeforeLoadPlugin(const Value: TSciterBeforeLoadPluginProc);
  protected
    procedure UpdatePathHash;
  public
    constructor Create();
    destructor Destroy; override;

    procedure Invalidate;
    function  Implementator: Pointer;

    function  Add(const AItem: ISciterPlugin; const AOwner: Boolean): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: ISciterPlugin; const AOwner: Boolean);

    function  Broadcast(const Msg: WideString; wParam: WPARAM; lParam: LPARAM;
      var bHandle: Boolean; const AFilter: SciterString = ''): LRESULT; overload;
    procedure Broadcast(const Msg: WideString; wParam: WPARAM; lParam: LPARAM;
      const AFilter: SciterString = ''); overload;
    
    function  IndexOf(const AItem: ISciterPlugin): Integer;
    function  IndexOfPath(const APath: SciterString): Integer;
    function  IndexOfImplementator(const AImpl: Pointer): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: ISciterPlugin read GetItem write SetItem; default;
    property ItemByPath[const APath: SciterString]: ISciterPlugin read GetItemByPath write SetItemByPath;

    property BeforeLoadPlugin: TSciterBeforeLoadPluginProc read GetBeforeLoadPlugin write SetBeforeLoadPlugin;
    property AfterLoadPlugin: TSciterAfterLoadPluginProc read GetAfterLoadPlugin write SetAfterLoadPlugin;
  end;

implementation

uses
  SciterApiImpl;
  
{ TSciterPlugin }

function TSciterPlugin.Broadcast(const Msg: WideString; wParam: WPARAM; lParam: LPARAM;
  var bHandle: Boolean; const AFilter: SciterString): LRESULT;
begin
  if FOwner <> nil then
    Result := FOwner.Broadcast(Msg, wParam, lParam, bHandle, AFilter)
  else
    Result := 0;
end;

procedure TSciterPlugin.Broadcast(const Msg: WideString; wParam: WPARAM;
  lParam: LPARAM; const AFilter: SciterString);
begin
  if FOwner <> nil then
    FOwner.Broadcast(Msg, wParam, lParam, AFilter)
end;

constructor TSciterPlugin.Create(const APath: SciterString);
begin
  FPath := APath;
end;

destructor TSciterPlugin.Destroy;
begin
  FDestroying := True;
  
  if FBehaviorFactorys <> nil then
  begin
    FBehaviorFactorys.Clear;
    FBehaviorFactorys := nil;
  end;

  UnloadPlugin;
  
  inherited;
end;

function TSciterPlugin.GetBehaviorFactorys: IBehaviorFactorys;
begin
  if FBehaviorFactorys = nil then
    FBehaviorFactorys := TBehaviorFactorys.Create;
  Result := FBehaviorFactorys;
end;

function TSciterPlugin.GetCanUnload: Boolean;
begin
  Result := (@FCanUnloadPluginProc <> nil) and FCanUnloadPluginProc();
end;

function TSciterPlugin.GetData1: Pointer;
begin
  Result := FData1;
end;

function TSciterPlugin.GetData2: Pointer;
begin
  Result := FData2;
end;

function TSciterPlugin.GetHandle: Cardinal;
begin
  Result := FHandle;
end;

function TSciterPlugin.GetLastError: SciterString;
begin
  Result := FLastError;
end;

function TSciterPlugin.GetOwner: Pointer;
begin
  Result := FOwner;
end;

function TSciterPlugin.GetPath: SciterString;
begin
  Result := FPath;
end;

function TSciterPlugin.Implementator: Pointer;
begin
  Result := Self;
end;

function TSciterPlugin.Loaded: Boolean;
begin
  Result := FHandle > 0;
end;

function TSciterPlugin.LoadPlugin: Boolean;
begin
  Result := False;
  try
    if not FastFileExists(FPath) then
    begin
      FLastError := Format('[%s]插件不存在！', [FPath]);
      Log(FLastError);
      Exit;
    end;

    if Loaded then
    begin
      Log(Format('[%s]插件已加载！', [FPath]));
    end
    else
    begin
      FHandle := LoadLibrary(PChar(string(FPath)));
      if FHandle <= 0 then
      begin
        FLastError := Format('[%s]插件加载失败:%s！', [FPath, SysErrorMessage(Windows.GetLastError)]);
        Log(FLastError);
        Exit;    
      end;
    end;

    @FLoadPluginProc := GetProcAddress(FHandle, PROC_SciterLoadPlugin);
    @FCanUnloadPluginProc := GetProcAddress(FHandle, PROC_SciterCanUnloadPlugin);
    @FUnloadPluginProc := GetProcAddress(FHandle, PROC_SciterUnloadPlugin);
    @FSendMessageProc := GetProcAddress(FHandle, PROC_SciterSendMessage);
    @FRequirePluginProc := GetProcAddress(FHandle, PROC_SciterRequirePlugin);

    try
      if @FLoadPluginProc <> nil then
        FLoadPluginProc(Self);
    except
      on E: Exception do
      begin
        FLastError := '['+PROC_SciterLoadPlugin+']'+E.Message;
        TraceException(FLastError);
        Exit;
      end
    end;

    Result := True;
  except
    on E: Exception do
    begin
      FLastError := '[TSciterPlugin.LoadPlugin]'+E.Message;
      TraceException(FLastError);
    end
  end;
end;

function TSciterPlugin.Require(const AParams: SciterString): IDispatch;
begin
  Result := nil;
  if @FRequirePluginProc <> nil then
  try
    Result := FRequirePluginProc(AParams);
  except
    on E: Exception do
    begin
      FLastError := '[TSciterPlugin.Require]'+E.Message;
      TraceException(FLastError);
    end
  end;             
end;

function TSciterPlugin.SendMessage(const Msg: WideString; wParam: WPARAM;
  lParam: LPARAM; var bHandle: Boolean; const AFilter: SciterString): LRESULT;
begin
  Result := 0;
  if @FSendMessageProc <> nil then
  try
    Result := FSendMessageProc(Msg, wParam, lParam, bHandle, AFilter);
  except
    on E: Exception do
      TraceException('[TSciterPlugin.SendMessage]'+E.Message);
  end;
end;

procedure TSciterPlugin.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TSciterPlugin.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

procedure TSciterPlugin.SetOwner(const Value: Pointer);
var
  i: Integer;
begin
  if (FOwner<> nil) and (FOwner <> Value) then
  begin
    i := FOwner.IndexOfImplementator(Self);
    if i >= 0 then
      FOwner.Delete(i);
  end;

  FOwner := Value;
end;

procedure TSciterPlugin.SetPath(const Value: SciterString);
begin
  FPath := Value;
end;

procedure TSciterPlugin.UnloadPlugin;
begin
  if not Loaded then
    Exit;

  if @FUnloadPluginProc <> nil then
  try
    FUnloadPluginProc(Self);
  except
    on E: Exception do
    begin
      TraceException('['+PROC_SciterUnloadPlugin+']'+E.Message);
    end
  end;

  @FLoadPluginProc := nil;
  @FCanUnloadPluginProc := nil;
  @FUnloadPluginProc := nil;
  @FSendMessageProc := nil;
  @FRequirePluginProc := nil;
    
  try
    FreeLibrary(FHandle);
  except
    on E: Exception do
    begin
      TraceFmt('[TSciterPlugin.UnloadPlugin][%s]%s', [FPath, E.Message]);
    end
  end;

  FHandle := 0;  
end;

function TSciterPlugin._AddRef: Integer;
begin
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _AddRef;
end;

function TSciterPlugin._Release: Integer;
begin
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _Release;
end;

{ TSciterPluginList }

function TSciterPluginList.Add(const AItem: ISciterPlugin; const AOwner: Boolean): Integer;
var
  i: Integer;
begin
  i := IndexOfPath(AItem.Path);
  if i < 0 then
  begin
    Result := FList.Add(AItem);
    if AOwner then
      AItem.Owner := Self;
    FPathHash.Add(AnsiUpperCase(AItem.Path), Result);
    assert(FList.Count = Result+1);
  end
  else
  begin
    SetItem(i, AItem);
    Result := i;
  end;
end;

function TSciterPluginList.Broadcast(const Msg: WideString; wParam: WPARAM;
  lParam: LPARAM; var bHandle: Boolean; const AFilter: SciterString): LRESULT;
var
  i: Integer;
  LItem: ISciterPlugin;
begin
  Result := 0;
  for i := 0 to GetCount - 1 do
  begin
    LItem := GetItem(i);
    if LItem = nil then
      continue;

    Result := LItem.SendMessage(Msg, wParam, lParam, bHandle, AFilter);
    if bHandle then
      Exit;
  end;
end;

procedure TSciterPluginList.Broadcast(const Msg: WideString; wParam: WPARAM;
  lParam: LPARAM; const AFilter: SciterString);
var
  i: Integer;
  LItem: ISciterPlugin;
  bHandle: Boolean;
begin
  for i := 0 to GetCount - 1 do
  begin
    LItem := GetItem(i);
    if LItem = nil then
      continue;

    LItem.SendMessage(Msg, wParam, lParam, bHandle, AFilter);
  end;
end;

procedure TSciterPluginList.Clear;
begin
  FList.Clear;
  FPathHashValid := False;
end;

constructor TSciterPluginList.Create();
begin
  FList := TInterfaceList.Create;
  FPathHash := TStringHash.Create(1024);
end;

procedure TSciterPluginList.Delete(const Index: Integer);
begin
  FList.Delete(Index);
  FPathHashValid := False;
end;

destructor TSciterPluginList.Destroy;
begin
  if FPathHash <> nil then
    FreeAndNil(FPathHash);
  
  FList.Clear;
  FList := nil;
  inherited;
end;

function TSciterPluginList.GetAfterLoadPlugin: TSciterAfterLoadPluginProc;
begin
  Result := FAfterLoadPlugin;
end;

function TSciterPluginList.GetBeforeLoadPlugin: TSciterBeforeLoadPluginProc;
begin
  Result := FBeforeLoadPlugin;
end;

function TSciterPluginList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSciterPluginList.GetItem(const Index: Integer): ISciterPlugin;
begin
  Result := FList[index] as ISciterPlugin;
end;

function TSciterPluginList.GetItemByPath(const APath: SciterString): ISciterPlugin;
var
  i: Integer;
begin
  i := IndexOfPath(APath);
  if i >= 0 then
    Result := GetItem(i)
  else
    Result := nil;
end;

function TSciterPluginList.Implementator: Pointer;
begin
  Result := Self;
end;

function TSciterPluginList.IndexOf(const AItem: ISciterPlugin): Integer;
begin
  Result := FList.IndexOf(AItem)
end;

function TSciterPluginList.IndexOfImplementator(
  const AImpl: Pointer): Integer;
begin
  for Result := 0 to GetCount - 1 do
  begin
    if GetItem(Result).Implementator = AImpl then
      Exit;
  end;
  Result := -1;
end;

function TSciterPluginList.IndexOfPath(const APath: SciterString): Integer;
begin
  UpdatePathHash;
  Result := FPathHash.ValueOf(AnsiUpperCase(APath));
end;

procedure TSciterPluginList.Insert(const Index: Integer;
  const AItem: ISciterPlugin; const AOwner: Boolean);
begin
  FList.Insert(Index, AItem);
  if AOwner then
    AItem.Owner := Self;
  FPathHashValid := False;
end;

procedure TSciterPluginList.Invalidate;
begin
  FPathHashValid := False;
end;

procedure TSciterPluginList.SetAfterLoadPlugin(const Value: TSciterAfterLoadPluginProc);
begin
  FAfterLoadPlugin := Value;
end;

procedure TSciterPluginList.SetBeforeLoadPlugin(const Value: TSciterBeforeLoadPluginProc);
begin
  FBeforeLoadPlugin := Value;
end;

procedure TSciterPluginList.SetItem(const Index: Integer;
  const Value: ISciterPlugin);
begin
  FList[Index] := Value;
  FPathHashValid := False;
end;

procedure TSciterPluginList.SetItemByPath(const APath: SciterString;
  const Value: ISciterPlugin);
var
  i: Integer;
begin
  i := IndexOfPath(APath);
  if i >= 0 then
    SetItem(i, Value);
end;

procedure TSciterPluginList.UpdatePathHash;
var
  I: Integer;
  Key: string;
begin
  if FPathHashValid then Exit;
  FPathHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := AnsiUpperCase(GetItem(I).Path);
    FPathHash.Add(Key, I);
  end;
  FPathHashValid := True;
end;

end.
