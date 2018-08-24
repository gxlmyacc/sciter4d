{*******************************************************************************
 标题:     TiscriptClassInfo.pas
 描述:     Tiscript脚本类信息相关
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptClassInfo;

interface

{$I Sciter.inc}
                                                                                  
uses
  Classes, SciterApiImpl, SciterTypes,
  TiscriptApiImpl, TiscriptTypes, SysUtils, ActiveX, TiscriptIntf;

type
  TTiscriptMethodList = class;
  TTiscriptMethodInfo = class;

  TTiscriptClassInfo = class(TInterfacedObject, ITiscriptClassInfo)
  private
    FAllMethods: ITiscriptMethodInfoList;
    FFinalizerHandler: tiscript_finalizer;
    FGCCopyHandler: tiscript_on_gc_copy;
    FGetItemHandler: tiscript_get_item;
    FGetterHandler: tiscript_tagged_get_prop;
    FIteratorHandler: tiscript_iterator;
    FMethodHandler: tiscript_tagged_method;
    FMethods: ITiscriptMethodInfoList;
    FProps: ITiscriptMethodInfoList;
    FSetItemHandler: tiscript_set_item;
    FSetterHandler: tiscript_tagged_set_prop;
    FTypeName: AnsiString;
    FData1: Pointer;
    FData2: Pointer;
  private
    function SelectMethods: ITiscriptMethodInfoList;
    function SelectProperties: ITiscriptMethodInfoList;
  protected
    FSciterClassDef: ptiscript_class_def;
    function GetFinalizerHandler: tiscript_finalizer;
    function GetGCCopyHandler: tiscript_on_gc_copy;
    function GetGetItemHandler: tiscript_get_item;
    function GetGetterHandler: tiscript_tagged_get_prop;
    function GetIteratorHandler: tiscript_iterator;
    function GetMethodHandler: tiscript_tagged_method;
    function GetMethods: ITiscriptMethodInfoList;
    function GetSciterClassDef: ptiscript_class_def;
    function GetSetItemHandler: tiscript_set_item;
    function GetSetterHandler: tiscript_tagged_set_prop;
    function GetTypeName: SciterString;
    function GetData1: Pointer;
    function GetData2: Pointer;
    procedure SetFinalizerHandler(const Value: tiscript_finalizer);
    procedure SetGCCopyHandler(const Value: tiscript_on_gc_copy);
    procedure SetGetItemHandler(const Value: tiscript_get_item);
    procedure SetGetterHandler(const Value: tiscript_tagged_get_prop);
    procedure SetIteratorHandler(const Value: tiscript_iterator);
    procedure SetMethodHandler(const Value: tiscript_tagged_method);
    procedure SetSetItemHandler(const Value: tiscript_set_item);
    procedure SetSetterHandler(const Value: tiscript_tagged_set_prop);
    procedure SetTypeName(const Value: SciterString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);

    procedure FreeClassDef;
    procedure BuildClassDef;

    property FinalizerHandler: tiscript_finalizer read GetFinalizerHandler write SetFinalizerHandler;
    property GCCopyHandler: tiscript_on_gc_copy read GetGCCopyHandler write SetGCCopyHandler;
    property GetItemHandler: tiscript_get_item read GetGetItemHandler write SetGetItemHandler;
    property GetterHandler: tiscript_tagged_get_prop read GetGetterHandler write SetGetterHandler;
    property IteratorHandler: tiscript_iterator read GetIteratorHandler write SetIteratorHandler;
    property MethodHandler: tiscript_tagged_method read GetMethodHandler write SetMethodHandler;
    property Methods: ITiscriptMethodInfoList read GetMethods;
    property SetItemHandler: tiscript_set_item read GetSetItemHandler write SetSetItemHandler;
    property SetterHandler: tiscript_tagged_set_prop read GetSetterHandler write SetSetterHandler;
    property TypeName: SciterString read GetTypeName write SetTypeName;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: SciterString; {$IFDEF UNICODE} reintroduce; {$ENDIF}
    
    property SciterClassDef: ptiscript_class_def read GetSciterClassDef;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

  TTiscriptClassInfoList = class(TInterfacedObject, ITiscriptClassInfoList)
  private
    FList: IInterfaceList;
    function GetCount: Integer;
    function GetItem(Index: Integer): ITiscriptClassInfo;
  protected
    procedure Add(const ClsInfo: ITiscriptClassInfo);
    
    function Exists(const TypeName: SciterString): boolean;
    function FindClassInfo(const TypeName: SciterString): ITiscriptClassInfo;
    
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ITiscriptClassInfo read GetItem; default;
  public
    constructor Create;
    destructor Destroy; override;
    function ToString: SciterString; {$IFDEF UNICODE} reintroduce; {$ENDIF}
  end;

  TTiscriptMethodInfo = class(TInterfacedObject, ITiscriptMethodInfo)
  private
    FCallParamsCount: Integer;
    FCallType: TTiscriptMethodType;
    FGetParamsCount: Integer;
    FHasGetter: Boolean;
    FHasSetter: Boolean;
    FName: SciterString;
    FIndex: Integer;
    FSetParamsCount: Integer;
    FParamsAsc: Boolean;
    FParamInfos: TDynPointerArray;
    FReturnInfo: Pointer;
    FPropInfo: Pointer;
    function GetCallParamsCount: Integer;
    function GetCallType: TTiscriptMethodType;
    function GetGetParamsCount: Integer;
    function GetHasGetter: Boolean;
    function GetHasSetter: Boolean;
    function GetName: SciterString;
    function GetIndex: Integer;
    function GetSetParamsCount: Integer;
    function GetParamsAsc: Boolean;
    function GetParamInfos: TDynPointerArray;
    function GetReturnInfo: Pointer;
    function GetPropInfo: Pointer;
    procedure SetCallParamsCount(const Value: Integer);
    procedure SetCallType(const Value: TTiscriptMethodType);
    procedure SetGetParamsCount(const Value: Integer);
    procedure SetHasGetter(const Value: Boolean);
    procedure SetHasSetter(const Value: Boolean);
    procedure SetName(const Value: SciterString);
    procedure SetIndex(const Value: Integer);
    procedure SetSetParamsCount(const Value: Integer);
    procedure SetParamsAsc(const Value: Boolean);
    procedure SetParamInfos(const Value: TDynPointerArray);
    procedure SetReturnInfo(const Value: Pointer);
    procedure SetPropInfo(const Value: Pointer);
  public
    constructor Create;
    destructor Destroy; override;
    
    function ToString: SciterString; {$IFDEF UNICODE} reintroduce; {$ENDIF}

    property CallParamsCount: Integer read GetCallParamsCount write SetCallParamsCount;
    property CallType: TTiscriptMethodType read GetCallType write SetCallType;
    property Name: SciterString read GetName write SetName;
    property Index: Integer read GetIndex write SetIndex;
    property HasGetter: Boolean read GetHasGetter write SetHasGetter;
    property HasSetter: Boolean read GetHasSetter write SetHasSetter;
    property GetParamsCount: Integer read GetGetParamsCount write SetGetParamsCount;
    property SetParamsCount: Integer read GetSetParamsCount write SetSetParamsCount;
    property ParamsAsc: Boolean read GetParamsAsc write SetParamsAsc;
    property ParamInfos: TDynPointerArray read GetParamInfos write SetParamInfos;
    property ReturnInfo: Pointer read GetReturnInfo write SetReturnInfo;
    property PropInfo: Pointer read GetPropInfo write SetPropInfo;
  end;

  TTiscriptMethodList = class(TInterfacedObject, ITiscriptMethodInfoList)
  private
    FList: IInterfaceList;
    function GetCount: Integer;
    function GetItem(Index: Integer): ITiscriptMethodInfo;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure Add(const Item: ITiscriptMethodInfo);
    procedure Remove(const Item: ITiscriptMethodInfo);
    procedure Clear;
    function Exists(const MethodName: SciterString): boolean;
    function LookupMethod(const MethodName: SciterString): ITiscriptMethodInfo;
    
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ITiscriptMethodInfo read GetItem; default;
  end;
  
  { Key-value pair where key is a HVM and value is a list of class definitions registered for that VM }
  TVMClassBag = class(TInterfacedObject, IVMClassBag)
  private
    FList: ITiscriptClassInfoList;
    FVM: HVM;
    function GetClassInfoList: ITiscriptClassInfoList;
    function GetVM: HVM;
  protected
    constructor Create(vm: HVM);
  public
    destructor Destroy; override;

    function ToString: SciterString;  {$IFDEF UNICODE} reintroduce; {$ENDIF}
    
    property ClassInfoList: ITiscriptClassInfoList read GetClassInfoList;
    property VM: HVM read GetVM;
  end;

  TVMClassBagList = class(TInterfacedObject, IVMClassBagList)
  private
    FList: IInterfaceList;
    function GetCount: Integer;
    function GetItem(Index: Integer): IVMClassBag;
  public
    constructor Create;
    destructor Destroy; override;

    function  IndexOf(const vm: HVM): Integer;
    function  Exists(const vm: HVM): boolean;
    function  GetClassInfoList(const vm: HVM): ITiscriptClassInfoList;

    function  Add(const Item: IVMClassBag): Integer;
    procedure Remove(const Item: IVMClassBag); overload;
    procedure Remove(const vm: HVM); overload;
    
    function  ClassInfoExists(const vm: HVM; const TypeName: SciterString): boolean; virtual;
    function  FindClassInfo(const vm: HVM; const TypeName: SciterString): ITiscriptClassInfo; virtual;
    
    function  ToString: SciterString; {$IFDEF UNICODE} reintroduce; {$ENDIF}

    property Count: Integer read GetCount;
    property Item[Index: Integer]: IVMClassBag read GetItem; default;
  end;

  // TypeName is an input.
  TTiscriptClassBag = class(TVMClassBagList, ITiscriptClassBag)
  public
    function CreateMethodInfo(): ITiscriptMethodInfo;
    function CreateMethodInfoList(): ITiscriptMethodInfoList;

    function CreateClassInfo(const TypeName: SciterString): ITiscriptClassInfo;
    function CreateClassInfoList(): ITiscriptClassInfoList;

    function CreateVMClassBag(vm: HVM): IVMClassBag;
    function CreateVMClassBagList(): IVMClassBagList;

    function ClassInfoExists(const vm: HVM; const TypeName: SciterString): boolean; override;
    function CreateInstance(const vm: HVM; const TypeName: SciterString): tiscript_object;
    function FindClassInfo(const vm: HVM; const TypeName: SciterString): ITiscriptClassInfo; override;
    function RegisterClassInfo(vm: HVM; const ClsInfo: ITiscriptClassInfo): tiscript_class;
    function ResolveClass(vm: HVM; const TypeName: SciterString): tiscript_class;
  end;
  
implementation

{$IFDEF DELPHIXE5UP}
uses
  AnsiStrings;
{$ENDIF}

constructor TTiscriptClassInfo.Create;
begin
  FSciterClassDef := nil;
  FAllMethods := TTiscriptMethodList.Create;
  FProps := TTiscriptMethodList.Create;
  FMethods := TTiscriptMethodList.Create;
end;

destructor TTiscriptClassInfo.Destroy;
begin
  //Log('SciterClassInfo ' + FTypeName + ' is being destroyed.');
  try
    FProps := nil;
    FMethods := nil;
    FAllMethods := nil;
    FreeClassDef;
    inherited;
  except
    on E: Exception do
      TraceException('[TTiscriptClassInfo.Destroy]'+E.Message);
  end;
end;

procedure TTiscriptClassInfo.FreeClassDef;
var
  pMethods: ptiscript_method_def;
  pProps: ptiscript_prop_def;
  i: Integer;
begin
  if FSciterClassDef = nil then
    Exit;
  {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrDispose(FSciterClassDef.name);
  FSciterClassDef.consts := nil;
  FSciterClassDef.get_item := nil;
  FSciterClassDef.set_item := nil;
  FSciterClassDef.finalizer := nil;
  FSciterClassDef.iterator := nil;
  FSciterClassDef.on_gc_copy := nil;
  FSciterClassDef.prototype := 0;

  // Dispose methods
  pMethods := FSciterClassDef.methods;
  for i := 0 to FSciterClassDef.methodsc - 1 do
  begin
    {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrDispose(pMethods.name);
    Inc(pMethods);
  end;
  CoTaskMemFree(FSciterClassDef.methods);

  // Dispose properties
  pProps := FSciterClassDef.props;
  for i := 0 to FSciterClassDef.propsc - 1 do
  begin
    {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrDispose(pProps.name);
    Inc(pProps);
  end;
  CoTaskMemFree(FSciterClassDef.props);

  Dispose(FSciterClassDef);
  FSciterClassDef := nil;
end;

procedure TTiscriptClassInfo.BuildClassDef;
var
  i: Integer;
  pInfo: ITiscriptMethodInfo;
  pclass_methods: ptiscript_method_def;
  pMethods: ITiscriptMethodInfoList;
  pProps: ITiscriptMethodInfoList;
  smethod_name: AnsiString;
  sprop_name: AnsiString;
  szMethods: Integer;
  szProps: Integer;
  pclass_props: ptiscript_prop_def;
begin
  New(FSciterClassDef);
  FSciterClassDef.methods    := nil;
  FSciterClassDef.props      := nil;
  FSciterClassDef.consts     := nil; // Not implemented
  FSciterClassDef.get_item   := FGetItemHandler;
  FSciterClassDef.set_item   := FSetItemHandler;
  FSciterClassDef.finalizer  := FFinalizerHandler;
  FSciterClassDef.iterator   := FIteratorHandler;
  FSciterClassDef.on_gc_copy := FGCCopyHandler;
  FSciterClassDef.prototype  := 0;   // Not implemented
  FSciterClassDef.name       := {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrNew(PAnsiChar(Self.FTypeName));

  // Methods
  pMethods := Self.SelectMethods;
  FSciterClassDef.methodsc := pMethods.Count + 1;
  szMethods := SizeOf(tiscript_method_def) * FSciterClassDef.methodsc; // 1 - "null-terminating record"
  pclass_methods := CoTaskMemAlloc(szMethods);
  FSciterClassDef.methods := pclass_methods;

  for i := 0 to pMethods.Count - 1 do
  begin
    pInfo := pMethods[i];
    smethod_name := UTF8Encode(pInfo.Name);
    pclass_methods.name := {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrNew(PAnsiChar(smethod_name));
    pclass_methods.handler := @FMethodHandler;
    pclass_methods.dispatch := nil;
    pclass_methods.tag := Pointer(pInfo);
    pclass_methods.payload := 0;
    Inc(pclass_methods);
  end;
  // null-terminating record
  pclass_methods.dispatch := nil;
  pclass_methods.name := nil;
  pclass_methods.handler := nil;
  pclass_methods.tag := nil;

  // Properties
  pProps := Self.SelectProperties;
  FSciterClassDef.propsc := pProps.Count + 1;
  szProps := SizeOf(tiscript_prop_def) * FSciterClassDef.propsc; // 1 - "null-terminating record"
  pclass_props := CoTaskMemAlloc(szProps);
  FSciterClassDef.props := pclass_props;
  for i := 0 to pProps.Count - 1 do
  begin
    pInfo := pProps[i];
    sprop_name := UTF8Encode(pInfo.Name);
    pclass_props.dispatch := nil;
    pclass_props.name := {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrNew(PAnsiChar(sprop_name));

    // non-indexed property getter
    if (pInfo.HasGetter) and (pInfo.GetParamsCount = 0) then
      pclass_props.getter := @FGetterHandler
    else
      pclass_props.getter := nil;

    // non-indexed property setter
    if (pInfo.HasSetter) and (pInfo.SetParamsCount = 1) then
      pclass_props.setter := @FSetterHandler
    else
      pclass_props.setter := nil;

    pclass_props.tag := Pointer(pInfo);

    Inc(pclass_props);
  end;
  // null-terminating record
  pclass_props.dispatch := nil;
  pclass_props.name := nil;
  pclass_props.getter := nil;
  pclass_props.setter := nil;
  pclass_props.tag := nil;
end;

function TTiscriptClassInfo.GetFinalizerHandler: tiscript_finalizer;
begin
  Result := FFinalizerHandler;
end;

function TTiscriptClassInfo.GetGCCopyHandler: tiscript_on_gc_copy;
begin
  Result := FGCCopyHandler;
end;

function TTiscriptClassInfo.GetGetItemHandler: tiscript_get_item;
begin
  Result := FGetItemHandler;
end;

function TTiscriptClassInfo.GetGetterHandler: tiscript_tagged_get_prop;
begin
  Result := FGetterHandler;
end;

function TTiscriptClassInfo.GetIteratorHandler: tiscript_iterator;
begin
  Result := FIteratorHandler;
end;

function TTiscriptClassInfo.GetMethodHandler: tiscript_tagged_method;
begin
  Result := FMethodHandler;
end;

function TTiscriptClassInfo.GetMethods: ITiscriptMethodInfoList;
begin
  Result := FAllMethods;
end;

function TTiscriptClassInfo.GetSciterClassDef: ptiscript_class_def;
begin
  if FSciterClassDef = nil then
    Self.BuildClassDef;
  Result := FSciterClassDef;
end;

function TTiscriptClassInfo.GetSetItemHandler: tiscript_set_item;
begin
  Result := SetItemHandler;
end;

function TTiscriptClassInfo.GetSetterHandler: tiscript_tagged_set_prop;
begin
  Result := FSetterHandler;
end;

function TTiscriptClassInfo.GetTypeName: SciterString;
begin
  Result := SciterString(FTypeName);
end;

function TTiscriptClassInfo.SelectMethods: ITiscriptMethodInfoList;
var
  i: Integer;
  pItem: ITiscriptMethodInfo;
begin
  FMethods.Clear;
  for i := 0 to FAllMethods.Count - 1 do
  begin
    pItem := FAllMethods[i];
    if pItem.CallType = Method then
      FMethods.Add(pItem);
  end;
  Result := FMethods;
end;

function TTiscriptClassInfo.SelectProperties: ITiscriptMethodInfoList;
var
  i: Integer;
  pItem: ITiscriptMethodInfo;
begin
  FProps.Clear;
  for i := 0 to FAllMethods.Count - 1 do
  begin
    pItem := FAllMethods[i];
    if pItem.CallType = NonIndexedProperty then
      FProps.Add(pItem);
  end;
  Result := FProps;
end;

procedure TTiscriptClassInfo.SetFinalizerHandler(
  const Value: tiscript_finalizer);
begin
  FFinalizerHandler := Value;
end;

procedure TTiscriptClassInfo.SetGCCopyHandler(
  const Value: tiscript_on_gc_copy);
begin
  FGCCopyHandler := Value;
end;

procedure TTiscriptClassInfo.SetGetItemHandler(
  const Value: tiscript_get_item);
begin
  FGetItemHandler := Value;
end;

procedure TTiscriptClassInfo.SetGetterHandler(
  const Value: tiscript_tagged_get_prop);
begin
  FGetterHandler := Value;
end;

procedure TTiscriptClassInfo.SetIteratorHandler(
  const Value: tiscript_iterator);
begin
  FIteratorHandler := Value;
end;

procedure TTiscriptClassInfo.SetMethodHandler(
  const Value: tiscript_tagged_method);
begin
  FMethodHandler := Value;
end;

procedure TTiscriptClassInfo.SetSetItemHandler(
  const Value: tiscript_set_item);
begin
  FSetItemHandler := Value;
end;

procedure TTiscriptClassInfo.SetSetterHandler(
  const Value: tiscript_tagged_set_prop);
begin
  FSetterHandler := Value;
end;

procedure TTiscriptClassInfo.SetTypeName(const Value: SciterString);
begin
  FTypeName := UTF8Encode(Value);
end;

function TTiscriptClassInfo.ToString: SciterString;
var
  i: Integer;
  sResult: SciterString;
begin
  sResult := 'class: ' + Self.TypeName + #13#10;
  for i := 0 to Self.FAllMethods.Count - 1 do
    sResult := sResult + Self.FAllMethods[i].ToString + #13#10;
  Result := sResult;
end;

constructor TTiscriptMethodList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TTiscriptMethodList.Destroy;
begin
  FList := nil;
  inherited;
end;

{ TTiscriptMethodList }

procedure TTiscriptMethodList.Add(const Item: ITiscriptMethodInfo);
begin   
  if not Exists(Item.Name) then
    FList.Add(Item)
  else
    raise ESciterException.CreateFmt('Method "%s" was already added.', []);
end;

procedure TTiscriptMethodList.Clear;
begin
  FList.Clear;
end;

function TTiscriptMethodList.Exists(const MethodName: SciterString): boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Item[i].Name = MethodName then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function TTiscriptMethodList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTiscriptMethodList.GetItem(
  Index: Integer): ITiscriptMethodInfo;
begin
  Result := FList[Index] as ITiscriptMethodInfo;
end;

function TTiscriptMethodList.LookupMethod(const MethodName: SciterString): ITiscriptMethodInfo;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if Item[i].Name = MethodName then
    begin
      Result := Item[i];
      Exit;
    end;
  end;
  Result := TTiscriptMethodInfo.Create;
  Result.Name := MethodName;
  Add(Result);
end;

constructor TTiscriptClassInfoList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TTiscriptClassInfoList.Destroy;
begin
  FList := nil;
  inherited;
end;

procedure TTiscriptMethodList.Remove(const Item: ITiscriptMethodInfo);
begin
  FList.Remove(Item);
end;

{ TTiscriptClassInfoList }

procedure TTiscriptClassInfoList.Add(const ClsInfo: ITiscriptClassInfo);
begin
  if not Exists(ClsInfo.TypeName) then
    FList.Add(ClsInfo)
  else
    raise ESciterException.CreateFmt('Class "%s" was already added.', [ClsInfo.TypeName]);
end;

function TTiscriptClassInfoList.Exists(const TypeName: SciterString): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    if Item[i].TypeName = TypeName then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TTiscriptClassInfoList.FindClassInfo(
  const TypeName: SciterString): ITiscriptClassInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if Item[i].TypeName = TypeName then
    begin
      Result := Item[i];
      Exit;
    end;
  end;
end;

function TTiscriptClassInfoList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTiscriptClassInfoList.GetItem(Index: Integer): ITiscriptClassInfo;
begin
  Result := FList[Index] as ITiscriptClassInfo;
end;

function TTiscriptClassInfoList.ToString: SciterString;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Item[i].ToString + #13#10;
end;

{ TTiscriptClassBag }

function TTiscriptClassBag.ClassInfoExists(const vm: HVM;
  const TypeName: SciterString): boolean;
begin
  Result := Inherited ClassInfoExists(vm, TypeName);
end;

function TTiscriptClassBag.CreateClassInfo(
  const TypeName: SciterString): ITiscriptClassInfo;
var
  pResult: ITiscriptClassInfo;
begin
  pResult := TTiscriptClassInfo.Create;
  pResult.TypeName := SciterString(TypeName);
  Result := pResult;
end;

function TTiscriptClassBag.CreateClassInfoList: ITiscriptClassInfoList;
begin
  Result := TTiscriptClassInfoList.Create;
end;

function TTiscriptClassBag.CreateInstance(const vm: HVM; 
  const TypeName: SciterString): tiscript_object;
begin
  Result := NI.undefined_value;
end;

function TTiscriptClassBag.CreateMethodInfo: ITiscriptMethodInfo;
begin
  Result := TTiscriptMethodInfo.Create;
end;

function TTiscriptClassBag.CreateMethodInfoList: ITiscriptMethodInfoList;
begin
  Result := TTiscriptMethodList.Create;
end;

function TTiscriptClassBag.CreateVMClassBag(vm: HVM): IVMClassBag;
begin
  Result := TVMClassBag.Create(vm);
end;

function TTiscriptClassBag.CreateVMClassBagList: IVMClassBagList;
begin
  Result := TVMClassBagList.Create;
end;

function TTiscriptClassBag.FindClassInfo(const vm: HVM;
  const TypeName: SciterString): ITiscriptClassInfo;
begin
  Result := Inherited FindClassInfo(vm, TypeName);
end;

function TTiscriptClassBag.RegisterClassInfo(vm: HVM; const ClsInfo: ITiscriptClassInfo): tiscript_class;
var
  pVMClassBag: IVMClassBag;
  pClassList: ITiscriptClassInfoList;
  zns: tiscript_value;
begin
  pClassList := nil;
  if not Exists(vm) then
  begin
    pVMClassBag := TVMClassBag.Create(vm);
    Self.Add(pVMClassBag);
    pClassList := pVMClassBag.ClassInfoList;
  end;
  if pClassList = nil then
    pClassList := Self.GetClassInfoList(vm);
  if not pClassList.Exists(ClsInfo.TypeName) then
  begin
    pClassList.Add(ClsInfo);
    Result := TiscriptApiImpl.RegisterNativeClass(vm, ClsInfo.SciterClassDef, False);
  end
  else
    Result := TiscriptApiImpl.FindClass(vm, SciterString(ClsInfo.TypeName));

  // Probably class def was somehow collected by GC
  if not NI.is_class(vm, Result) then
  begin
    zns := NI.get_global_ns(vm);
    Result := NI.define_class(vm, ClsInfo.SciterClassDef, zns);
  end;

  Assert(NI.is_class(vm, Result), 'Failed to Register class info.');
end;

function TTiscriptClassBag.ResolveClass(vm: HVM;
 const TypeName: SciterString): tiscript_class;
begin
 if not Self.ClassInfoExists(vm, SciterString(TypeName)) then
 begin
   raise ESciterException.CreateFmt('Cannot resolve class "%s": class not registered.', [TypeName]);
 end
 else
 begin
   Result := TiscriptApiImpl.FindClass(vm, TypeName);
 end;
end;

{ TVMClassInfoDictionary }

constructor TVMClassBag.Create(vm: HVM);
begin
  FVM := vm;
  FList := TTiscriptClassInfoList.Create;
end;

destructor TVMClassBag.Destroy;
begin
  //Log(AnsiString('VMClassBag ' + IntToStr(Integer(FVM)) + ' is being destroyed.'));
  FVM := nil;
  FList := nil;
  inherited;
end;

function TVMClassBag.GetClassInfoList: ITiscriptClassInfoList;
begin
  Result := FList;
end;

function TVMClassBag.GetVM: HVM;
begin
  Result := FVM;
end;

function TVMClassBag.ToString: SciterString;
begin
  Result := 'VM: ' + IntToStr(Integer(FVM)) + #13#10;
  Result := Result + ClassInfoList.ToString;
end;

constructor TVMClassBagList.Create;
begin
  FList := TInterfaceList.Create;
end;

destructor TVMClassBagList.Destroy;
begin
  FList := nil;
  inherited;
end;

{ TVMClassBagList }

function TVMClassBagList.Add(const Item: IVMClassBag): Integer;
begin
  if Exists(Item.VM) then
    raise ESciterException.CreateFmt('VM handle %d was already added.', [Integer(Item.VM)]);
  Result :=FList.Add(Item);
end;

function TVMClassBagList.ClassInfoExists(const vm: HVM;
  const TypeName: SciterString): boolean;
var
  pList: ITiscriptClassInfoList;
begin
  if not Exists(vm) then
  begin
    Result := False;
  end
  else
  begin
    pList := Self.GetClassInfoList(vm);
    if pList = nil then
    begin
      Result := False;
      Exit;
    end;
    Result := pList.Exists(TypeName);
  end;
end;

function TVMClassBagList.Exists(const vm: HVM): boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count - 1 do
  begin
    if Item[i].VM = vm then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TVMClassBagList.FindClassInfo(const vm: HVM;
  const TypeName: SciterString): ITiscriptClassInfo;
var
  pClassList: ITiscriptClassInfoList;
begin
  pClassList := GetClassInfoList(vm);
  if pClassList = nil then
  begin
    Result := nil;
    Exit;
  end;
  Result := pClassList.FindClassInfo(TypeName);
end;

function TVMClassBagList.GetClassInfoList(const vm: HVM): ITiscriptClassInfoList;
var
  i: Integer;
  pVMClassBag: IVMClassBag;
  pList: ITiscriptClassInfoList;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    pVMClassBag := Item[i];
    if pVMClassBag.VM = vm then
    begin
      pList := pVMClassBag.ClassInfoList;
      Result := pList;
      Exit;
    end;
  end;
end;

function TVMClassBagList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TVMClassBagList.GetItem(Index: Integer): IVMClassBag;
begin
  Result := FList[Index] as IVMClassBag;
end;

function TVMClassBagList.ToString: SciterString;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Result := Result + Item[i].ToString + #13#10;
end;

function TVMClassBagList.IndexOf(const vm: HVM): Integer;
begin
  for Result := 0 to Count - 1 do
  begin
    if Item[Result].VM = vm then
      Exit;
  end;
  Result := -1;
end;

procedure TVMClassBagList.Remove(const Item: IVMClassBag);
begin
  Remove(Item.VM);
end;

procedure TVMClassBagList.Remove(const vm: HVM);
var
  i: Integer;
begin
  i := IndexOf(vm);
  if i >= 0 then
    FList.Delete(i);
end;

{ TTiscriptMethodInfo }

constructor TTiscriptMethodInfo.Create;
begin
  FIndex := -1;
end;

destructor TTiscriptMethodInfo.Destroy;
begin
  //Log('  SciterMethodInfo ' + FName + ' is being destroyed.');
  inherited;
end;

function TTiscriptMethodInfo.GetCallParamsCount: Integer;
begin
  Result := FCallParamsCount;
end;

function TTiscriptMethodInfo.GetCallType: TTiscriptMethodType;
begin
  Result := FCallType;
end;

function TTiscriptMethodInfo.GetGetParamsCount: Integer;
begin
  Result := FGetParamsCount;
end;

function TTiscriptMethodInfo.GetHasGetter: Boolean;
begin
  Result := FHasGetter;
end;

function TTiscriptMethodInfo.GetHasSetter: Boolean;
begin
  Result := FHasSetter;
end;

function TTiscriptMethodInfo.GetIndex: Integer;
begin
  Result := FIndex;
end;

function TTiscriptMethodInfo.GetName: SciterString;
begin
  Result := FName;
end;

function TTiscriptMethodInfo.GetParamInfos: TDynPointerArray;
begin
  Result := FParamInfos;
end;

function TTiscriptMethodInfo.GetParamsAsc: Boolean;
begin
  Result := FParamsAsc;
end;

function TTiscriptMethodInfo.GetPropInfo: Pointer;
begin
  Result := FPropInfo;
end;

function TTiscriptMethodInfo.GetReturnInfo: Pointer;
begin
  Result := FReturnInfo;
end;

function TTiscriptMethodInfo.GetSetParamsCount: Integer;
begin
  Result := FSetParamsCount;
end;

procedure TTiscriptMethodInfo.SetCallParamsCount(const Value: Integer);
begin
  FCallParamsCount := Value;
end;

procedure TTiscriptMethodInfo.SetCallType(const Value: TTiscriptMethodType);
begin
  FCallType := Value;
end;

procedure TTiscriptMethodInfo.SetGetParamsCount(const Value: Integer);
begin
  FGetParamsCount := Value;
end;

procedure TTiscriptMethodInfo.SetHasGetter(const Value: Boolean);
begin
  FHasGetter := Value;
end;

procedure TTiscriptMethodInfo.SetHasSetter(const Value: Boolean);
begin
  FHasSetter := Value;
end;

procedure TTiscriptMethodInfo.SetIndex(const Value: Integer);
begin
  FIndex := Value;
end;

procedure TTiscriptMethodInfo.SetName(const Value: SciterString);
begin
  FName := SciterString(Value);
end;

procedure TTiscriptMethodInfo.SetParamInfos(const Value: TDynPointerArray);
begin
  FParamInfos := Value;
end;

procedure TTiscriptMethodInfo.SetParamsAsc(const Value: Boolean);
begin
  FParamsAsc := Value;
end;

procedure TTiscriptMethodInfo.SetPropInfo(const Value: Pointer);
begin
  FPropInfo := Value;
end;

procedure TTiscriptMethodInfo.SetReturnInfo(const Value: Pointer);
begin
  FReturnInfo := Value;
end;

procedure TTiscriptMethodInfo.SetSetParamsCount(const Value: Integer);
begin
  FSetParamsCount := Value;
end;

function TTiscriptMethodInfo.ToString: SciterString;
begin
  Result := String(Self.Name)+':'+ IntToStr(FIndex);
  case CallType of
    Method: Result := Result + ' (method)';
    NonIndexedProperty: Result := Result + ' (non-indexed property)';
    IndexedProperty: Result := Result + ' (indexed property)';
  end;
end;

function TTiscriptClassInfo.GetData1: Pointer;
begin
  Result := FData1;
end;

function TTiscriptClassInfo.GetData2: Pointer;
begin
  Result := FData2;
end;

procedure TTiscriptClassInfo.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TTiscriptClassInfo.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

end.
