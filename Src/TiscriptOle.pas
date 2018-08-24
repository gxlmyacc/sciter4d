{*******************************************************************************
 标题:     TiscriptOle.pas
 描述:     Tiscript脚本OLE相关
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptOle;

interface

uses
  Windows, Variants, Classes, SciterApiImpl, SciterTypes, SciterHash,
  TiscriptApiImpl, TiscriptTypes, SysUtils, TiscriptClassInfo,  ActiveX,
  TiscriptIntf;

type
  ESciterOleException = class(ESciterException);
  EOleError = class(Exception);

  ISciterOleClassInfo = interface(ITiscriptClassInfo)
  ['{AE243F09-EB10-4A07-AAB6-A09C6F053C42}']
    procedure Build(Ptr: Pointer); overload;
    procedure Build(const Value: OleVariant); overload;
    procedure Build(const Dispatch: IDispatch); overload;
    procedure Build(const TypeInfo: ITypeInfo; const Dispatch: IDispatch = nil); overload;
  end;

  TTiscriptOleClassInfo = class(TTiscriptClassInfo, ISciterOleClassInfo)
  public
    constructor Create; override;
    procedure Build(Ptr: Pointer); overload;
    procedure Build(const Value: OleVariant); overload;
    procedure Build(const Dispatch: IDispatch); overload;
    procedure Build(const TypeInfo: ITypeInfo; const Dispatch: IDispatch = nil); overload;
  end;

  TTiscriptVariableItem = class(TInterfacedObject, ITiscriptVariableItem)
  private
    FName: SciterString;
    FType: TTiscriptVariableType;
    FObject: IDispatch;
    FFunction: TTiscriptNativeMethod;
    FTag: Pointer;
    function GetName: SciterString;
    function GetType: TTiscriptVariableType;
    function GetObject: IDispatch;
    function GetFunction: TTiscriptNativeMethod;
    function GetTag: Pointer;
    procedure SetName(const Value: SciterString);
    procedure SetType(const Value: TTiscriptVariableType);
    procedure SetObject(const Value: IDispatch);
    procedure SetFunction(const Value: TTiscriptNativeMethod);
    procedure SetTag(const Value: Pointer);
  public
    constructor Create(const AName: SciterString; const AObject: IDispatch); overload;
    constructor Create(const AName: SciterString; AFunction: TTiscriptNativeMethod; ATag: Pointer = nil); overload;
    destructor Destroy; override;
    property Name: SciterString read GetName write SetName;
    property Type_: TTiscriptVariableType read GetType write SetType;
    property Object_: IDispatch read GetObject write SetObject;
    property Function_: TTiscriptNativeMethod read GetFunction write SetFunction;
    property Tag: Pointer read GetTag write SetTag;
  end;

  TTiscriptVariableList = class(TInterfacedObject, ITiscriptVariableList)
  private
    FList: IInterfaceList;
    FNotifyList: TMethodList;
    FNameList: TStrings;
    FNameHash: TStringHash;
    FNameHashValid: Boolean;
  protected
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): ITiscriptVariableItem;
    function  GetItemName(const Index: Integer): SciterString;
    function  GetItemByName(const AName: SciterString): ITiscriptVariableItem;
    procedure SetItem(const Index: Integer; const Value: ITiscriptVariableItem);
    procedure SetItemByName(const AName: SciterString; const Value: ITiscriptVariableItem);
  protected
    procedure UpdateNameHash;
    procedure DoNotify(const AInfo: ITiscriptVariableItem; Action: TTiscriptObjectAction);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Invalidate;

    function  RegObject(const AName: SciterString; const AItem: IDispatch): Integer;
    function  RegFunction(const AName: SciterString; AFunction: TTiscriptNativeMethod; ATag: Pointer = nil): Integer;
    procedure UnReg(const Index: Integer); overload;
    procedure UnReg(const AName: SciterString); overload;
    procedure Clear;

    function  IndexOfName(const AName: SciterString): Integer;

    function AddListener(const AListener: TTiscriptObjectListener): Integer;
    function RemoveListener(const AListener: TTiscriptObjectListener): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: ITiscriptVariableItem read GetItem write SetItem; default;
    property ItemName[const Index: Integer]: SciterString read GetItemName;
    property ItemByName[const AName: SciterString]: ITiscriptVariableItem read GetItemByName write SetItemByName;
  end;

  TTiscriptOle = class(TInterfacedObject, ITiscriptOle)
  public
    function Implementator: Pointer;
    
    function CreateOleNative(): ISciterOleClassInfo;

    function DispatchInvoke(const Dispatch: IDispatch; const DispID: integer;
      const MethodName: SciterString; const AParams: array of OleVariant;
      AParamAsc: Boolean = False): OleVariant; overload;
    function DispatchInvoke(const Dispatch: IDispatch; const MethodName: SciterString;
      const AParams: array of OleVariant; AParamAsc: Boolean = False): OleVariant; overload;

    function  DispatchGetItem(const Dispatch: IDispatch; const Index: OleVariant): OleVariant;
    procedure DispatchSetItem(const Dispatch: IDispatch; const Index: OleVariant; const Value: OleVariant);

    function GetOleObjectGuid(const Obj: IDispatch): SciterString;
    function FindOrCreateOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_class;

    function  RegisterOleObject(vm: HVM; const Name: SciterString; Dispatch: IDispatch): tiscript_object;
    function  WrapOleObject(vm: HVM; Dispatch: IDispatch): tiscript_object;
  end;

function  _OleGetItemHandler(vm: HVM; this, key: tiscript_value): tiscript_value; cdecl;
procedure _OleSetItemHandler(vm: HVM; this, key, value: tiscript_value); cdecl;
procedure _OleOnGCCopyHandler(instance_data: Pointer; new_self: tiscript_value); cdecl;
function  _OleGetterHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
procedure _OleSetterHandler(vm: HVM; obj, value: tiscript_value; tag: Pointer); cdecl;
function  _OleMethodHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
procedure _OleFinalizerHandler(vm: HVM; obj: tiscript_value); cdecl;

function _DispatchInvoke(const Dispatch: IDispatch; const MethodName: SciterString;
  const AParams: array of OleVariant; AParamAsc: Boolean): OleVariant;  overload;
function _DispatchInvoke(const Dispatch: IDispatch; const DispID: integer;const MethodName: SciterString;
  const AParams: array of OleVariant; AParamAsc: Boolean): OleVariant; overload;

function _GetOleObjectGuid(const Obj: IDispatch): SciterString;
function _FindOrCreateOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_class;
function _WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_object;
function _RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: SciterString): tiscript_object;

implementation

uses
  ObjAuto, ComObj, TypInfo;

function _GetOleObjectGuid(const Obj: IDispatch): SciterString;
var
  typeInfo: ITypeInfo;
  typeAttr: PTypeAttr;
begin
  Result := '';
  try
    if Obj = nil then
      Exit;

    OleCheck(Obj.GetTypeInfo(0, LOCALE_USER_DEFAULT, typeInfo));

    OleCheck(typeInfo.GetTypeAttr(typeAttr));

    // Guid
    Result := GUIDToString(typeAttr.guid);
  finally
    if typeAttr <> nil then
      if typeInfo <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
  end;
end;

function _FindOrCreateOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_class;
var
  pOleClassInfo: ISciterOleClassInfo;
  sGuid: SciterString;
  tclass: tiscript_class;
begin
  sGuid := _GetOleObjectGuid(Dispatch);

  tclass := TiscriptApiImpl.FindClass(vm, sGuid);
  if NI.is_class(vm, tclass) then
  begin
    Result := tclass;
    Exit;
  end;

  if not ClassBag.ClassInfoExists(vm, sGuid) then
  begin
    pOleClassInfo := TTiscriptOleClassInfo.Create;
    pOleClassInfo.Build(Dispatch);
    tclass := ClassBag.RegisterClassInfo(vm, pOleClassInfo);
    Result := tclass;
  end
  else
  begin
    tclass := TiscriptApiImpl.FindClass(vm, sGuid);
    if not NI.is_class(vm, tclass) then
    begin
      pOleClassInfo := TTiscriptOleClassInfo.Create;
      pOleClassInfo.Build(Dispatch);
      tclass := ClassBag.RegisterClassInfo(vm, pOleClassInfo);
    end;
    Result := tclass;
  end;
end;

function _WrapOleObject(vm: HVM; const Dispatch: IDispatch): tiscript_object;
var
  ole_class_def: tiscript_class;
begin
  if Dispatch = nil then
  begin
    Result := NI.undefined_value;
    Exit;
  end;
  ole_class_def := _FindOrCreateOleObjectClass(vm, Dispatch);
  Dispatch._AddRef;
  Result := TiscriptApiImpl.CreateObjectInstance(vm, Pointer(Dispatch), ole_class_def);
end;

function _RegisterOleObject(vm: HVM; const Dispatch: IDispatch; const Name: SciterString): tiscript_object;
var
  ole_class_def: tiscript_class;
  class_instance: tiscript_object;
begin
//  if SAPI.IsNameExists(vm, Name) then
//    raise ESciterOleException.CreateFmt('Cannot register OLE Object: variable with name %s already exists.', [Name]);

  Assert(Dispatch <> nil, 'OLE object is undefined');
      
  ole_class_def := _FindOrCreateOleObjectClass(vm, Dispatch);
  Dispatch._AddRef;
  class_instance := TiscriptApiImpl.CreateObjectInstance(vm, Pointer(Dispatch), ole_class_def);
  TiscriptApiImpl.RegisterObject(vm, class_instance, Name);

  Result := class_instance;
end;

function _DispatchInvoke(const Dispatch: IDispatch; const MethodName: SciterString;
  const AParams: array of OleVariant; AParamAsc: Boolean): OleVariant;
var
  Argc: integer;
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Flags: Word;
  i: integer;
  j: integer;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  pDispIds: array[0..0] of TDispID;
  pNames: array[0..0] of POleStr;
  VarResult: Variant;
begin
  Result := Unassigned;

  Flags := INVOKE_FUNC;

  Argc := High(AParams) + 1;
  if Argc < 0 then Argc := 0;

  // Method DISPID
  pNames[0] := PWideChar(MethodName);
  OleCheck(Dispatch.GetIDsOfNames(GUID_NULL, @pNames, 1, LOCALE_USER_DEFAULT, @pDispIds));
  try
    // Building paramarray
    GetMem(pArgs, sizeof(TVariantArg) * Argc);
    try
      if AParamAsc then
      begin
        for i := Low(AParams) to High(AParams) do
          pArgs[i] := tagVARIANT(TVarData(AParams[i]));
      end
      else
      begin
        j := 0;
        for i := High(AParams) downto Low(AParams) do
        begin
          pArgs[j] := tagVARIANT(TVarData(AParams[i]));
          j := j + 1;
        end;
      end;

      Params.rgvarg := pArgs;
      Params.cArgs := Argc;
      params.cNamedArgs := 0;
      params.rgdispidNamedArgs := nil;
  
      OleCheck(Dispatch.Invoke(pDispIds[0], GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
      Result := VarResult;
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * Argc);
    end;
  except
    on E:EOleError do
    begin
      TraceException('[_DispatchInvoke]'+MethodName+':'+e.Message);
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
  end;
end;

function _DispatchInvoke(const Dispatch: IDispatch; const DispID: integer;const MethodName: SciterString;
  const AParams: array of OleVariant; AParamAsc: Boolean): OleVariant; 
var
  Argc: integer;
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Flags: Word;
  i: integer;
  j: integer;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  VarResult: OleVariant;
begin
  Result := Unassigned;
  
  Flags := INVOKE_FUNC; // or INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;
  
  Argc := High(AParams) + 1;
  if Argc < 0 then Argc := 0;

  try
    GetMem(pArgs, sizeof(TVariantArg) * Argc);
    try
      if AParamAsc then
      begin
        for i := Low(AParams) to High(AParams) do
          pArgs[i] := tagVARIANT(TVarData(AParams[i]));
      end
      else
      begin
        j := 0;
        for i := High(AParams) downto Low(AParams) do
        begin
          pArgs[j] := tagVARIANT(TVarData(AParams[i]));
          j := j + 1;
        end;
      end;

      Params.rgvarg := pArgs;
      Params.cArgs := Argc;
      params.cNamedArgs := 0;
      params.rgdispidNamedArgs := nil;
  
      OleCheck(Dispatch.Invoke(DispID, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * Argc);
    end;
  except
    on E:EOleError do
    begin
      TraceException('[_DispatchInvoke]'+MethodName+':'+e.Message);
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
  end;
  Result := VarResult;
end;

procedure _DispatchSetItem(const Dispatch: IDispatch; const Index: OleVariant; const Value: OleVariant);
var
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  VarResult: Variant;
  Flags: Word;
begin
  Flags := INVOKE_FUNC or INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF;

  GetMem(pArgs, sizeof(TVariantArg) * 2);
  pArgs[0] := tagVARIANT(TVarData(Index));
  pArgs[1] := tagVARIANT(TVarData(Value));

  Params.rgvarg := pArgs;
  Params.cArgs := 2;
  params.cNamedArgs := 0;
  params.rgdispidNamedArgs := nil;

  try
    try
      OleCheck(Dispatch.Invoke(DISPID_VALUE, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * 2);
    end;
  except
    on E:EOleError do
    begin
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
  end;
end;

function _DispatchGetItem(const Dispatch: IDispatch; const Index: OleVariant): OleVariant;
var
  ArgErr: integer;
  ExcepInfo: TExcepInfo;
  Params: DISPPARAMS;
  pArgs: PVariantArgList;
  VarResult: Variant;
  Flags: Word;
begin
  Flags := INVOKE_FUNC or DISPATCH_PROPERTYGET;
  
  GetMem(pArgs, sizeof(TVariantArg) * 1);
  pArgs[0] := tagVARIANT(TVarData(Index));

  Params.rgvarg := pArgs;
  Params.cArgs := 1;
  params.cNamedArgs := 0;
  params.rgdispidNamedArgs := nil;
  try
    try
      OleCheck(Dispatch.Invoke(DISPID_VALUE, GUID_NULL, LOCALE_USER_DEFAULT, Flags, TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr));
    finally
      FreeMem(pArgs, sizeof(TVariantArg) * 1);
    end;
  except
    on E:EOleError do
    begin
      raise ESciterOleException.CreateFmt('OLE Error code %d: %s', [ExcepInfo.wCode, ExcepInfo.bstrDescription]);
    end;
  end;
  Result := VarResult;
end;

function _OleIteratorHandler(vm: HVM; index: ptiscript_value; obj: tiscript_value): tiscript_value; cdecl;
var
  pDisp: IDispatch;
  oIndex: OleVariant;
  oValue: OleVariant;
  pEnum: IEnumVariant;
  Params: DISPPARAMS;
  VarResult: Variant;
  Flags: Word;
  ExcepInfo: TExcepInfo;
  ArgErr: integer;
  Celt: UINT;
  CeltFetched: UINT;
begin
  Result := NI.nothing_value;
  try
    pDisp := IDispatch(NI.get_instance_data(obj));
    if not NI.is_int(index^) then
    begin
      index^ := NI.int_value(0);
    end;

    T2V(vm, index^, oIndex, @obj);
    Flags := INVOKE_FUNC or INVOKE_PROPERTYGET;
    Params.rgvarg := nil;
    Params.cArgs := 0;
    params.cNamedArgs := 0;
    params.rgdispidNamedArgs := nil;
    if Succeeded(pDisp.Invoke(DISPID_NEWENUM, GUID_NULL, LOCALE_USER_DEFAULT, Flags,
      TDispParams(Params), @VarResult, @ExcepInfo, @ArgErr)) then
    begin
      Celt := oIndex;
      if VarSupports(VarResult, IEnumVariant, pEnum) then
      begin
        if pEnum.Reset <> S_OK then
          Exit;
        if pEnum.Skip(Celt) <> S_OK then
          Exit;
        if pEnum.Next(1, oValue, CeltFetched) = S_OK then
        begin
          if VarType(oValue) = varDispatch then
          begin
            Result := _WrapOleObject(vm, IDispatch(oValue));
            index^ := NI.int_value(Integer(oIndex) + 1);
          end
          else
          begin
            Assert(V2T(vm, oValue, Result) = HV_OK);
            index^ := NI.int_value(Integer(oIndex) + 1);
          end;
        end;
      end
      else
        ThrowError(vm, 'Iterator is not supported. Cannot cast value returned by property or method with DISPID=-4 to IEnumVARIANT.');
    end
    else
      ThrowError(vm, 'Iterator is not supported.');
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure _OleFinalizerHandler(vm: HVM; obj: tiscript_value); cdecl;
var
  pDisp: IDispatch;
begin
  try
    pDisp := IDispatch(NI.get_instance_data(obj));
    
    if pDisp = nil then
      Exit;
   
    pDisp._Release; // in most cases should be 1 here
    NI.set_instance_data(obj, nil);
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

function _OleGetItemHandler(vm: HVM; this, key: tiscript_value): tiscript_value; cdecl;
var
  pSelf: Pointer;
  pDisp: IDispatch;
  oValue: OleVariant;
  oKey: OleVariant;
begin
  Result := NI.nothing_value;
  try
    pSelf := NI.get_instance_data(this);
    if pSelf <> nil then
    begin
      pDisp := IDispatch(pSelf);
      Assert(T2V(vm, key, oKey, @this) = 0, 'convert key error!');
      oValue := _DispatchGetItem(pDisp, oKey);
      Assert(V2T(vm, oValue, Result)=HV_OK);
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure _OleSetItemHandler(vm: HVM; this, key, value: tiscript_value); cdecl;
var
  pSender: Pointer;
  pDisp: IDispatch;
  okey: OleVariant;
  ovalue: OleVariant;
begin
  try
    pSender := NI.get_instance_data(this);
    if pSender <> nil then
    begin
      pDisp := IDispatch(pSender);
      T2V(vm, key, oKey, @this);
      T2V(vm, value, oValue, @this);
      _DispatchSetItem(pDisp, oKey, oValue);
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure _OleOnGCCopyHandler(instance_data: Pointer; new_self: tiscript_value); cdecl;
begin
  if instance_data <> nil then
  begin
    //pthis := IDispatch(instance_data);
    //pthis._AddRef();
    //NI.set_instance_data(new_self, Pointer(pthis));

    NI.set_instance_data(new_self, instance_data);
  end;
end;

function _OleGetterHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pSender: Pointer;
  pDispatch: IDispatch;
  iMethodDispID: Integer;
  LMethodInfo: ITiscriptMethodInfo;
  LPropInfo: TypInfo.PPropInfo;
  oValue: OleVariant;
begin
  Result := NI.nothing_value;
  try
    LMethodInfo := ITiscriptMethodInfo(tag);
    iMethodDispID := LMethodInfo.Index;

    pSender := NI.get_instance_data(obj);
    pDispatch := IDispatch(pSender);

    if iMethodDispID <> -1 then
      oValue := ComObj.GetDispatchPropValue(pDispatch, iMethodDispID)
    else
      oValue := ComObj.GetDispatchPropValue(pDispatch, LMethodInfo.Name);

    if VarType(oValue) = varDispatch then
      Result := _WrapOleObject(vm, IDispatch(oValue))
    else
    begin
      LPropInfo := LMethodInfo.PropInfo;
      if (LPropInfo <> nil) then
        Assert(V2T(vm, oValue, Result, LPropInfo^.PropType) = 0)
      else
        Assert(V2T(vm, oValue, Result, nil) = 0);
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

procedure _OleSetterHandler(vm: HVM; obj, value: tiscript_value; tag: Pointer); cdecl;
var
  pSender: Pointer;
  pDispatch: IDispatch;
  oValue: OleVariant;
  sMethodName: SciterString;
  iMethodDispID: Integer;
  LMethodInfo: ITiscriptMethodInfo;
begin
  try
    pSender := NI.get_instance_data(obj);
    pDispatch := IDispatch(pSender);

    LMethodInfo := ITiscriptMethodInfo(tag);
    iMethodDispID := LMethodInfo.Index;

    Assert(T2V(vm, value, oValue, @obj, LMethodInfo.PropInfo) = 0);

    if iMethodDispID <> -1 then
      ComObj.SetDispatchPropValue(pDispatch, iMethodDispID, oValue)
    else
    begin
      sMethodName := LMethodInfo.Name;
      ComObj.SetDispatchPropValue(pDispatch, SciterString(sMethodName), oValue);
    end;
  except
    on E:Exception do
      ThrowError(vm, E.Message);
  end;
end;

function _OleMethodHandler(vm: HVM; obj: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  pSender: Pointer;
  pDisp: IDispatch;
  argc: Integer;
  arg: tiscript_value;
  pThis: tiscript_object;
  sarg: SCITER_VALUE;
  oargs: array of OleVariant;
  i: Integer;
  oresult, ov: OleVariant;
  iMethodDispID: Integer;
  LMethodInfo: ITiscriptMethodInfo;
  LReturnInfo: PReturnInfo;
  LParamInfos: TDynPointerArray;
  LParamTypeInfo: PPTypeInfo;
  sJsonValue: SciterString;
begin
  SAPI.ValueInit(sarg);

  Result := NI.nothing_value;
  try
    LMethodInfo := ITiscriptMethodInfo(tag);
    iMethodDispID := LMethodInfo.Index;
    
    pThis := NI.get_arg_n(vm, 0);
    // super = arg(1)
    pSender    := NI.get_instance_data(pthis);
    pDisp      := IDispatch(pSender);

    argc := NI.get_arg_count(vm);
    LParamInfos := LMethodInfo.ParamInfos;
    LParamTypeInfo  := nil;
    // Invoke params
    SetLength(oargs, argc - 2);
    for i := 2 to argc - 1 do
    begin
      arg := NI.get_arg_n(vm, i);
      if Length(LParamInfos) > 0 then
        LParamTypeInfo := PPTypeInfo(PParamInfo(LParamInfos[i - 2]).ParamType);
      if T2V(vm, arg, ov, @pthis, LParamTypeInfo) = 0 then
        oargs[i - 2] := ov
      else
        oargs[i - 2] := arg
    end;
    // Call method
    if iMethodDispID <> -1 then
      oResult := _DispatchInvoke(pDisp, iMethodDispID, LMethodInfo.Name, oargs, LMethodInfo.ParamsAsc)
    else
      oResult := _DispatchInvoke(pDisp, LMethodInfo.Name, oargs, LMethodInfo.ParamsAsc);

    if VarType(oResult) = varDispatch then
      Result := _WrapOleObject(vm, IDispatch(oResult))
    else
    begin
      LReturnInfo := LMethodInfo.ReturnInfo;
      if (LReturnInfo <> nil) and (LReturnInfo^.ReturnType <> nil) then
      begin
        if (LReturnInfo^.ReturnType^.Name = JSONObjectName) then
        begin
          sJsonValue := oResult;
          if sJsonValue <> '' then
            Result := Tiscript.ParseData(sJsonValue, vm)
          else
            Result  := ni.undefined_value;
        end
        else
          Assert(V2T(vm, oResult, Result, PPTypeInfo(LReturnInfo^.ReturnType)) = 0)
      end
      else
        Assert(V2T(vm, oResult, Result, nil) = 0); 
    end;
  except
    on E:Exception do
    begin
      TraceException('[_OleMethodHandler]'+LMethodInfo.Name + ':' + E.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

constructor TTiscriptOleClassInfo.Create;
begin
  inherited;
  Self.GetItemHandler   := _OleGetItemHandler;
  Self.SetItemHandler   := _OleSetItemHandler;
  Self.GCCopyHandler    := _OleOnGCCopyHandler;
  Self.FinalizerHandler := _OleFinalizerHandler;
  Self.MethodHandler    := _OleMethodHandler;
  Self.GetterHandler    := _OleGetterHandler;
  Self.SetterHandler    := _OleSetterHandler;
  Self.IteratorHandler  := _OleIteratorHandler;
end;

{ TSciterOleWrapper }

procedure TTiscriptOleClassInfo.Build(Ptr: Pointer);
var
  pDisp: IDispatch;
begin
  if Ptr = nil then
    raise ESciterNullPointerException.Create;

  try
    pDisp := IDispatch(Ptr);
    pDisp._AddRef;
    pDisp._Release;
  except
    on E:Exception do
      raise ESciterException.Create('Cannot cast pointer to IDispatch.');
  end;
  Build(IDispatch(Ptr));
end;

procedure TTiscriptOleClassInfo.Build(const Value: OleVariant);
begin
  Build(IDispatch(Value));
end;

procedure TTiscriptOleClassInfo.Build(const Dispatch: IDispatch);
var
  pTypeInfo: ITypeInfo;
begin
  if Dispatch = nil then
    raise ESciterNullPointerException.Create;
    
  OleCheck(Dispatch.GetTypeInfo(0, LOCALE_USER_DEFAULT, pTypeInfo));
  Build(pTypeInfo, Dispatch);
end;

procedure TTiscriptOleClassInfo.Build(const TypeInfo: ITypeInfo; const Dispatch: IDispatch);
var
  typeAttr: PTypeAttr;
  funcDesc: PFuncDesc;
  sfuncName: PWideChar;
  funcName: SciterString;
  i, j: Integer;
  cNames: Integer;
  pMethodInfo: ITiscriptMethodInfo;

  pDispIds: array[0..0] of TDispID;
  pNames: array[0..0] of POleStr;
  LDispatchMethodInfo: PDispatchMethodInfo;
  LDispatchPropertyInfo: PDispatchPropertyInfo;
  LDispatchRttiObject: IDispatchRttiObject;
  LParamInfos: TDynPointerArray;
begin
  if TypeInfo = nil then
    raise ESciterNullPointerException.Create;
    
  try
    OleCheck(TypeInfo.GetTypeAttr(typeAttr));

    if Supports(Dispatch, IDispatchRttiObject, LDispatchRttiObject) then
      Self.TypeName := LDispatchRttiObject.ObjectName
    else
      Self.TypeName := GUIDToString(typeAttr.guid);
      
    for i := 0 to typeAttr.cFuncs - 1 do
    try
      funcDesc := nil;
      OleCheck(typeInfo.GetFuncDesc(i, funcDesc));

      sfuncName := nil;
      typeInfo.GetNames(funcDesc.memid, PBStrList(@sfuncName), 1, cNames);
      funcName := SciterString(sfuncName);
      
      pMethodInfo := Methods.LookupMethod(funcName);

      pNames[0] := PWideChar(funcName);
      OleCheck(typeInfo.GetIDsOfNames(@pNames, 1, @pDispIds));
      pMethodInfo.Index := pDispIds[0];

      if LDispatchRttiObject <> nil then
      begin
        LDispatchMethodInfo := LDispatchRttiObject.DispatchMethodInfo[pMethodInfo.Index];
        if LDispatchMethodInfo <> nil then
        begin
          pMethodInfo.ReturnInfo := LDispatchMethodInfo.ReturnInfo;
          SetLength(LParamInfos, LDispatchMethodInfo.ParamCount);
          for j := 0 to LDispatchMethodInfo.ParamCount - 1 do
            LParamInfos[j] := LDispatchMethodInfo.Params[j];
          pMethodInfo.ParamInfos := LParamInfos;
          pMethodInfo.ParamsAsc := LDispatchMethodInfo.ParamsAsc;
        end;
        LDispatchPropertyInfo := LDispatchRttiObject.DispatchPropertyInfo[pMethodInfo.Index];
        if LDispatchPropertyInfo <> nil then
          pMethodInfo.PropInfo := LDispatchPropertyInfo.Header;
      end;

      if funcDesc.invkind = INVOKE_FUNC then
      begin
        pMethodInfo.CallType := Method;
        pMethodInfo.CallParamsCount := funcDesc.cParams;
      end
      else
      if funcDesc.invkind = INVOKE_PROPERTYGET then
      begin
        if funcDesc.cParams > 0 then
          pMethodInfo.CallType := IndexedProperty
        else
          pMethodInfo.CallType := NonIndexedProperty;
        pMethodInfo.HasGetter := true;
        pMethodInfo.GetParamsCount := funcDesc.cParams;
      end
      else
      // INVOKE_PROPERTYPUT or INVOKE_PROPERTYPUTREF
      begin
        if funcDesc.cParams > 1 then
          pMethodInfo.CallType := IndexedProperty
        else
          pMethodInfo.CallType := NonIndexedProperty;

        pMethodInfo.HasSetter := True;
        pMethodInfo.SetParamsCount := funcDesc.cParams;
      end;
    finally       
       // if sfuncName <> nil then
       //   CoTaskMemFree(sfuncName);
       if funcDesc <> nil then
        typeInfo.ReleaseFuncDesc(funcDesc);
    end;
  finally
    if typeAttr <> nil then
      if typeInfo <> nil then
        typeInfo.ReleaseTypeAttr(typeAttr);
  end;
end;

{ TTiscriptOle }

function TTiscriptOle.CreateOleNative: ISciterOleClassInfo;
begin
  Result := TTiscriptOleClassInfo.Create;
end;

function TTiscriptOle.DispatchGetItem(const Dispatch: IDispatch;
  const Index: OleVariant): OleVariant;
begin
  Result := _DispatchGetItem(Dispatch, Index)
end;

function TTiscriptOle.DispatchInvoke(const Dispatch: IDispatch;
  const DispID: integer; const MethodName: SciterString; const AParams: array of OleVariant;
  AParamAsc: Boolean): OleVariant;
begin
  Result := _DispatchInvoke(Dispatch, DispID, MethodName, AParams, AParamAsc)
end;

function TTiscriptOle.DispatchInvoke(const Dispatch: IDispatch;
  const MethodName: SciterString; const AParams: array of OleVariant; AParamAsc: Boolean): OleVariant;
begin
  Result := _DispatchInvoke(Dispatch, MethodName, AParams, AParamAsc)
end;

procedure TTiscriptOle.DispatchSetItem(const Dispatch: IDispatch;
  const Index, Value: OleVariant);
begin
  _DispatchSetItem(Dispatch, Index, Value);
end;

function TTiscriptOle.FindOrCreateOleObjectClass(vm: HVM;
  const Dispatch: IDispatch): tiscript_class;
begin
  Result := _FindOrCreateOleObjectClass(vm, Dispatch)
end;

function TTiscriptOle.GetOleObjectGuid(const Obj: IDispatch): SciterString;
begin
  Result := _GetOleObjectGuid(Obj)
end;

function TTiscriptOle.RegisterOleObject(vm: HVM; const Name: SciterString; Dispatch: IDispatch): tiscript_object;
begin
  Result := _RegisterOleObject(vm, Dispatch, Name)
end;

function TTiscriptOle.WrapOleObject(vm: HVM; Dispatch: IDispatch): tiscript_object;
begin
  Result := _WrapOleObject(vm, Dispatch)
end;

function TTiscriptOle.Implementator: Pointer;
begin
  Result := Self;
end;

{ TTiscriptVariableItem }

constructor TTiscriptVariableItem.Create(const AName: SciterString; const AObject: IDispatch);
begin
  FName := AName;
  FType := tvtObject;
  FObject := AObject;
end;

constructor TTiscriptVariableItem.Create(const AName: SciterString;
  AFunction: TTiscriptNativeMethod; ATag: Pointer);
begin
  FName := AName;
  FType := tvtFunction;
  FFunction := AFunction;
  FTag := ATag;
end;

destructor TTiscriptVariableItem.Destroy;
begin
  FObject := nil;
  inherited;
end;

function TTiscriptVariableItem.GetName: SciterString;
begin
  Result := FName;
end;

function TTiscriptVariableItem.GetType: TTiscriptVariableType;
begin
  Result := FType;
end;

function TTiscriptVariableItem.GetObject: IDispatch;
begin
  Result := FObject;
end;

procedure TTiscriptVariableItem.SetName(const Value: SciterString);
begin
  FName := Value;
end;

procedure TTiscriptVariableItem.SetType(const Value: TTiscriptVariableType);
begin
  FType := Value;
end;

procedure TTiscriptVariableItem.SetObject(const Value: IDispatch);
begin
  FObject := Value;
end;

function TTiscriptVariableItem.GetFunction: TTiscriptNativeMethod;
begin
  Result := FFunction;
end;

function TTiscriptVariableItem.GetTag: Pointer;
begin
  Result := FTag;
end;

procedure TTiscriptVariableItem.SetFunction(const Value: TTiscriptNativeMethod);
begin
  FFunction := Value;
end;

procedure TTiscriptVariableItem.SetTag(const Value: Pointer);
begin
  FTag := Value;
end;

{ TTiscriptVariableList }

function TTiscriptVariableList.RegObject(const AName: SciterString; const AItem: IDispatch): Integer;
var
  i: Integer;
  LInfo: ITiscriptVariableItem;
begin
  i := IndexOfName(AName);
  LInfo := TTiscriptVariableItem.Create(AName, AItem);
  if i < 0 then
  begin
    Result := FList.Add(LInfo);
    FNameList.Add(AName);
    FNameHash.Add(AnsiUpperCase(AName), Result);
    DoNotify(LInfo, tocaReg);
  end
  else
  begin
    SetItem(i, LInfo);
    Result := i;
  end;
end;

function TTiscriptVariableList.RegFunction(const AName: SciterString;
  AFunction: TTiscriptNativeMethod; ATag: Pointer): Integer;
var
  i: Integer;
  LInfo: ITiscriptVariableItem;
begin
  i := IndexOfName(AName);
  LInfo := TTiscriptVariableItem.Create(AName, AFunction, ATag);
  if i < 0 then
  begin
    Result := FList.Add(LInfo);
    FNameList.Add(AName);
    FNameHash.Add(AnsiUpperCase(AName), Result);
    DoNotify(LInfo, tocaReg);
  end
  else
  begin
    SetItem(i, LInfo);
    Result := i;
  end;
end;

procedure TTiscriptVariableList.Clear;
var
  i: Integer;
begin
  if FList = nil then Exit;
  for i := FList.Count - 1 downto 0 do
    DoNotify(GetItem(i), tocaUnreg);
  FList.Clear;
  FNameHashValid := False;
end;

constructor TTiscriptVariableList.Create;
begin
  FList := TInterfaceList.Create;
  FNameList := TStringList.Create;
  FNameHash := TStringHash.Create(1024);
  FNotifyList := TMethodList.Create;
end;

procedure TTiscriptVariableList.UnReg(const Index: Integer);
begin
  DoNotify(GetItem(Index), tocaUnreg);
  FList.Delete(Index);
  FNameHashValid := False;
end;

procedure TTiscriptVariableList.UnReg(const AName: SciterString);
var
  i: Integer;
begin
  i := IndexOfName(AName);
  if i >= 0 then
    UnReg(i);
end;

destructor TTiscriptVariableList.Destroy;
begin
  if FList <> nil then
  begin
    Clear;
    FList := nil;
  end;
  if FNotifyList <> nil then
    FreeAndNil(FNotifyList);
  if FNameList <> nil then
    FreeAndNil(FNameList);
  if FNameHash <> nil then
    FreeAndNil(FNameHash);
  inherited;
end;

function TTiscriptVariableList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TTiscriptVariableList.GetItem(const Index: Integer): ITiscriptVariableItem;
begin
  Result := FList[index] as ITiscriptVariableItem;
end;

function TTiscriptVariableList.GetItemByName(
  const AName: SciterString): ITiscriptVariableItem;
var
  i: Integer;
begin
  i := IndexOfName(AName);
  if i >= 0 then
    Result := GetItem(i)
  else
    Result := nil;
end;

function TTiscriptVariableList.IndexOfName(const AName: SciterString): Integer;
begin
  UpdateNameHash;
  Result := FNameHash.ValueOf(AnsiUpperCase(AName));
end;

procedure TTiscriptVariableList.Invalidate;
begin
  FNameHashValid := False;
end;

procedure TTiscriptVariableList.SetItemByName(const AName: SciterString;
  const Value: ITiscriptVariableItem);
var
  i: Integer;
begin
  i := IndexOfName(AName);
  if i >= 0 then
    SetItem(i, Value);
end;

procedure TTiscriptVariableList.UpdateNameHash;
var
  I: Integer;
  Key: string;
begin
  if FNameHashValid then Exit;
  FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := AnsiUpperCase(FNameList[i]);
    FNameHash.Add(Key, I);
  end;
  FNameHashValid := True;
end;

procedure TTiscriptVariableList.SetItem(const Index: Integer;
  const Value: ITiscriptVariableItem);
begin
  Assert(GetItem(Index).Name = Value.Name);
  FList[Index] := Value;
  DoNotify(Value, tocaChanged);
end;

function TTiscriptVariableList.GetItemName(const Index: Integer): SciterString;
begin
  Result := FNameList[index];
end;

function TTiscriptVariableList.AddListener(const AListener: TTiscriptObjectListener): Integer;
begin
  Result := FNotifyList.Add(TMethod(AListener));
end;

function TTiscriptVariableList.RemoveListener(
  const AListener: TTiscriptObjectListener): Integer;
begin
  Result := FNotifyList.Remove(TMethod(AListener));
end;

procedure TTiscriptVariableList.DoNotify(const AInfo: ITiscriptVariableItem;
  Action: TTiscriptObjectAction);
var
  i: Integer;
begin
  for i := 0 to FNotifyList.Count - 1 do
  try
    TTiscriptObjectListener(FNotifyList[i]^)(AInfo, Action);
  except
  end;
end;

end.
