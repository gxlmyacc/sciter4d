{*******************************************************************************
 标题:     TiscriptImpl.pas
 描述:     Tiscript对外发布的总交互接口
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptImpl;

interface

uses
  SciterTypes, Windows, TiscriptIntf;

type
  TTiscript = class(TInterfacedObject, ITiscript)
  private
    FOnCreateNativeObject: TTiscriptCreateNativeObjectProc;
    FCurrentRuntime: ITiscriptRuntime;
    FOle: ITiscriptOle;
    FClassBag: ITiscriptClassBag;
  private
    function  GetApi: Pointer;
    function  GetOnCreateNativeObject: TTiscriptCreateNativeObjectProc;
    function  GetCurrent: PITiscriptRuntime;
    function  GetOle: PITiscriptOle;
    function  GetClassBag: PITiscriptClassBag;
    procedure SetOnCreateNativeObject(const Value: TTiscriptCreateNativeObjectProc);
  public
    function CreateRuntime(const vm: HVM): ITiscriptRuntime; overload;
    function CreateRuntime(features, heap_size, stack_size: UINT): ITiscriptRuntime; overload;

    function Bytes(const ASize: Cardinal): ITiscriptBytes; overload;
    function Bytes(const AMemory: Pointer; const ASize: Cardinal): ITiscriptBytes; overload;
    function V(const aValue: tiscript_value; vm: HVM = nil): ITiscriptValue; overload;
    function V(const AJson: JSONObject; vm: HVM = nil): ITiscriptValue; overload;
    function O(const aObject: tiscript_value = 0; vm: HVM = nil): ITiscriptObject; overload;
    function O(const AJson: JSONObject; vm: HVM = nil): ITiscriptObject; overload;
    function OC(const of_class: tiscript_value; vm: HVM = nil): ITiscriptObject;
    function OP(const class_path: SciterString; vm: HVM = nil): ITiscriptObject;
    function A(const aArray: tiscript_value; vm: HVM = nil): ITiscriptArray; overload;
    function A(num_elements: Cardinal = 0; vm: HVM = nil): ITiscriptArray; overload;
    function A(const AJson: JSONObject; vm: HVM = nil): ITiscriptArray; overload;
    function F(aFunc: tiscript_value; aThis: tiscript_object = 0; vm: HVM = nil): ITiscriptFunction; overload;
    function F(aFunc: TTiscriptNativeMethod; aTag: Pointer = nil; vm: HVM = nil): ITiscriptFunction; overload;

    function ParseData(const AJson: PJSONObject; ALen: Cardinal; vm: HVM = nil): tiscript_value; overload;
    function ParseData(const AJson: JSONObject; vm: HVM = nil): tiscript_value; overload;
    function Eval(const AScript: PWideChar; ALen: Cardinal; vm: HVM = nil): tiscript_value; overload;
    function Eval(const AScript: SciterString; vm: HVM = nil): tiscript_value; overload;

    function IsNameExists(const Name: SciterString; vm: HVM = nil): tiscript_value;
    function IsClassExists(const Name: SciterString; vm: HVM = nil): tiscript_value;
    function FindObject(const Name: SciterString; vm: HVM = nil): tiscript_value;
    function FindClass(const ClassName: SciterString; vm: HVM = nil): tiscript_class;

    function RegisterFunction(const Name: SciterString; Handler: TTiscriptNativeMethod;
      Tag: Pointer = nil; vm: HVM = nil): tiscript_value;
    function  RegisterObject(const Name: SciterString; Dispatch: IDispatch; vm: HVM = nil): tiscript_object;
    function  WrapObject(Dispatch: IDispatch; vm: HVM = nil): tiscript_object;

    procedure UnRegisterVariable(const Name: SciterString; vm: HVM = nil);

    function  IsGlobalVariableExists(const Name: SciterString): Boolean;
    function  RegisterGlobalFunction(const Name: SciterString; Handler: TTiscriptNativeMethod;
      Tag: Pointer = nil): tiscript_value;
    function  RegisterGlobalObject(const Name: SciterString; Dispatch: IDispatch): tiscript_object;
    procedure UnRegisterGlobalVariable(const Name: SciterString);

    function  T2V(Value: tiscript_value; vm: HVM = nil): OleVariant;
    function  V2T(const Value: OleVariant; vm: HVM = nil): tiscript_value;

    function CreateStringStream(const str: SciterString): ITiscriptStringStream;
    function CreateFileStream(const filename: SciterString): ITiscriptFileStream;

    property Current: PITiscriptRuntime read GetCurrent;
    property Ole: PITiscriptOle read GetOle;
    property ClassBag: PITiscriptClassBag read GetClassBag;
  end;

function GlobalVariables: PITiscriptVariableList;

implementation

uses
  TiscriptApiImpl, TiscriptClassInfo, TiscriptOle, TiscriptClass, TiscriptStream,
  TiscriptRuntime, SciterApiImpl, SciterExportDefs;

var
  varGlobalVariables: ITiscriptVariableList = nil;
function GlobalVariables: PITiscriptVariableList;
begin
  if varGlobalVariables = nil then
    varGlobalVariables := TTiscriptVariableList.Create;
  Result := @varGlobalVariables;
end;

{ TTiscript }

function TTiscript.CreateRuntime(const vm: HVM): ITiscriptRuntime;
begin
  Result := TTiscriptRuntime.Create(vm);
end;

function TTiscript.FindClass(const ClassName: SciterString; vm: HVM): tiscript_class;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TiscriptApiImpl.FindClass(vm, ClassName)
end;

function TTiscript.FindObject(const Name: SciterString; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TiscriptApiImpl.FindObject(vm, Name)
end;

function TTiscript.GetOle: PITiscriptOle;
begin
  if FOle = nil then
    FOle := TTiscriptOle.Create;
  Result := @FOle;
end;

function TTiscript.GetClassBag: PITiscriptClassBag;
begin
  if FClassBag = nil then
    FClassBag := TTiscriptClassBag.Create;
  Result := @FClassBag;
end;

function TTiscript.GetCurrent: PITiscriptRuntime;
begin
  if (SAPI <> nil) and (FCurrentRuntime = nil) then
    FCurrentRuntime := TTiscriptRuntime.Create(nil);
  Result := @FCurrentRuntime;
end;

function TTiscript.GetOnCreateNativeObject: TTiscriptCreateNativeObjectProc;
begin
  Result := FOnCreateNativeObject;
end;

function TTiscript.IsNameExists(const Name: SciterString; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TiscriptApiImpl.IsNameExists(vm, Name)
end;

function TTiscript.IsClassExists(const Name: SciterString; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TiscriptApiImpl.IsClassExists(vm, Name)
end;

function TTiscript.RegisterFunction(const Name: SciterString;
  Handler: TTiscriptNativeMethod; Tag: Pointer; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TiscriptApiImpl.RegisterNativeFunction(vm, Name, @Handler, Tag)
end;

procedure TTiscript.SetOnCreateNativeObject(const Value: TTiscriptCreateNativeObjectProc);
begin
  FOnCreateNativeObject := Value;
end;

function TTiscript.T2V(Value: tiscript_value; vm: HVM): OleVariant;
begin
  if vm = nil then vm := ni.get_current_vm;
  TiscriptApiImpl.T2V(vm, Value, Result, nil);
end;

function TTiscript.V2T(const Value: OleVariant; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Assert(TiscriptApiImpl.V2T(vm, Value, Result)=HV_OK);
end;

function TTiscript.Eval(const AScript: SciterString; vm: HVM): tiscript_value;
begin
  Result := Eval(PWideChar(AScript), System.Length(AScript), vm)
end;

function TTiscript.Eval(const AScript: PWideChar; ALen: Cardinal; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := ni.string_value(vm, AScript, ALen);
  ni.call(vm, ni.get_global_ns(vm), ni.get_prop(vm, ni.get_global_ns(vm), ni.symbol_value('eval')), @Result, 1, Result);
end;

function TTiscript.ParseData(const AJson: JSONObject; vm: HVM): tiscript_value;
begin
  Result := ParseData(PJsonObject(AJson), System.Length(AJson), vm);
end;

function TTiscript.ParseData(const AJson: PJSONObject; ALen: Cardinal; vm: HVM): tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := ni.string_value(vm, AJson, ALen);
  ni.call(vm, ni.get_global_ns(vm), ni.get_prop(vm, ni.get_global_ns(vm), ni.symbol_value('parseData')), @Result, 1, Result);
end;

function TTiscript.V(const aValue: tiscript_value; vm: HVM): ITiscriptValue;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TTiscriptValue.Create(vm, aValue);
end;

function TTiscript.V(const AJson: JSONObject; vm: HVM): ITiscriptValue;
var
  v: tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  v := ParseData(AJson, vm);
  Result := TTiscriptValue.Create(vm, v)
end;

function TTiscript.O(const aObject: tiscript_value; vm: HVM): ITiscriptObject;
begin
  if vm = nil then vm := ni.get_current_vm;
  if aObject = 0 then
    Result := OC(0, vm)
  else
    Result := TTiscriptObject.Create(vm, aObject);
end;

function TTiscript.O(const AJson: JSONObject; vm: HVM): ITiscriptObject;
var
  v: tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  v := ParseData(AJson, vm);
  if ni.is_object(v) then
    Result := TTiscriptObject.Create(vm, v)
  else
    Result := nil;
end;

function TTiscript.OC(const of_class: tiscript_value; vm: HVM): ITiscriptObject;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TTiscriptObject.CreateByClass(vm, of_class);
end;

function TTiscript.OP(const class_path: SciterString; vm: HVM): ITiscriptObject;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TTiscriptObject.CreateByPath(vm, class_path);
end;

function TTiscript.A(num_elements: Cardinal; vm: HVM): ITiscriptArray;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TTiscriptArray.Create(vm, num_elements);
end;

function TTiscript.A(const AJson: JSONObject; vm: HVM): ITiscriptArray;
var
  v: tiscript_value;
begin
  if vm = nil then vm := ni.get_current_vm;
  v := ParseData(AJson, vm);
  if ni.is_array(v) then
    Result := TTiscriptArray.Create(vm, v)
  else
    Result := nil;
end;

function TTiscript.A(const aArray: tiscript_value; vm: HVM): ITiscriptArray;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TTiscriptArray.Create(vm, aArray);
end;

function TTiscript.F(aFunc: tiscript_value; aThis: tiscript_object; vm: HVM): ITiscriptFunction;
begin
  if vm = nil then vm := ni.get_current_vm;
  if aThis = 0 then aThis := ni.get_current_ns(vm);
  Result := TTiscriptFunction.Create(vm, aFunc, aThis);
end;

function TTiscript.F(aFunc: TTiscriptNativeMethod; aTag: Pointer; vm: HVM): ITiscriptFunction;
begin
  Result := F(RegisterFunction('', aFunc, aTag, vm), 0, vm);
end;

function TTiscript.CreateFileStream(const filename: SciterString): ITiscriptFileStream;
begin
  Result := TTiscriptFileStream.Create(filename);
end;

function TTiscript.CreateStringStream(const str: SciterString): ITiscriptStringStream;
begin
  Result := TTiscriptStringStream.Create(str);
end;

function TTiscript.CreateRuntime(features, heap_size, stack_size: UINT): ITiscriptRuntime;
begin
  Result := TTiscriptRuntime.Create(features, heap_size, stack_size);
  _InitVM(Result.vm);
end;

function TTiscript.GetApi: Pointer;
begin
  Result := TiscriptApiImpl.ni;
end;

function TTiscript.RegisterObject(const Name: SciterString; Dispatch: IDispatch; vm: HVM): tiscript_object;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := TiscriptApiImpl.RegisterObject(vm, Dispatch, Name);
end;

procedure TTiscript.UnRegisterVariable(const Name: SciterString; vm: HVM = nil);
begin
  if vm = nil then vm := ni.get_current_vm;
  TiscriptApiImpl.UnRegisterVariable(vm, Name);
end;                   

function TTiscript.WrapObject(Dispatch: IDispatch; vm: HVM): tiscript_object;
begin
  if vm = nil then vm := ni.get_current_vm;
  Result := Self.Ole.WrapOleObject(vm, Dispatch);
end;

function TTiscript.IsGlobalVariableExists(const Name: SciterString): Boolean;
begin
  Result := GlobalVariables.IndexOfName(Name) >= 0;
end;

function TTiscript.RegisterGlobalFunction(const Name: SciterString;
  Handler: TTiscriptNativeMethod; Tag: Pointer): tiscript_value;
var
  idx: Integer;
begin
  Result := 0;
  idx := GlobalVariables.RegFunction(Name, Handler, Tag);
  if (idx >= 0) and (ni <> nil) and _VMIsInited(ni.get_current_vm) then
    Result := RegisterNativeFunction(ni.get_current_vm, Name, @Handler);
end;

function TTiscript.RegisterGlobalObject(const Name: SciterString; Dispatch: IDispatch): tiscript_object;
var
  idx: Integer;
begin
  Result := 0;
  idx := GlobalVariables.RegObject(Name, Dispatch);
  if (idx >= 0) and (ni <> nil) and _VMIsInited(ni.get_current_vm) then
    Result := Self.RegisterObject(Name, Dispatch);
end;

procedure TTiscript.UnRegisterGlobalVariable(const Name: SciterString);
var
  idx: Integer;
begin
  idx := GlobalVariables.IndexOfName(Name);
  if idx >= 0 then
  begin
    if (ni <> nil) and _VMIsInited(ni.get_current_vm) then
      TiscriptApiImpl.UnRegisterVariable(ni.get_current_vm, Name);
    GlobalVariables.UnReg(idx);
  end;
end;

function TTiscript.Bytes(const AMemory: Pointer; const ASize: Cardinal): ITiscriptBytes;
begin
  Result := TTiscriptBytes.Create(AMemory, ASize);
end;

function TTiscript.Bytes(const ASize: Cardinal): ITiscriptBytes;
begin
  Result := TTiscriptBytes.Create(ASize);
end;

initialization
finalization
  varGlobalVariables := nil;

end.

