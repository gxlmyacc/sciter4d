{*******************************************************************************
 标题:     TiscriptRuntime.pas
 描述:     Tiscript的vm相关接口封装
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptRuntime;

interface

{$I Sciter.inc}

uses
  SysUtils, Windows, SciterTypes, TiscriptStream, TiscriptTypes, TiscriptIntf,
  TiscriptApiImpl;

type
  TTiscriptRuntime = class(TInterfacedObject, ITiscriptRuntime)
  private
    Fvm: HVM;
    FOwn: Boolean;
    FCurrentNs: ITiscriptObject;
    FGlobalNs: ITiscriptObject;
  private
    function GetArgCount: UINT;
    function GetArg(const n: UINT): ITiscriptValue;
    function GetValueByPath(const path: SciterString): ITiscriptValue;
    function GetCurrentNs: ITiscriptObject;
    function GetGlobalNs: ITiscriptObject;
    function GetVM: HVM;
  public
    constructor Create(features: UINT = $ffffffff; heap_size: UINT = 1*1024*1024; stack_size: UINT = 64*1024); overload;
    constructor Create(const vm: HVM); overload;
    destructor Destroy; override;

    // so runtime reference can be used in places where HVM is required
    procedure GC();

    // designates ultimate "does not exist" situation.
    function Nothing: ITiscriptValue;
    // non-initialized or non-existent value
    function Undefined: ITiscriptValue;
    // explicit "no object" value
    function Null: ITiscriptValue;
    function V(const v: tiscript_value): ITiscriptValue;
    function B(const v: Boolean): ITiscriptValue;
    function I(const v: Integer): ITiscriptValue;
    function D(const v: Double): ITiscriptValue;
    function S(const v: SciterString): ITiscriptValue;
    function F(const v: tiscript_value; const this: tiscript_object = 0): ITiscriptFunction;
    // object creation, of_class == 0 - "Object"
    function O(const of_class: tiscript_class = ClassOfObject): ITiscriptObject; overload;
    function O(const class_path: SciterString): ITiscriptObject; overload;
    function O(const native_object: IDispatch): ITiscriptObject; overload;
    //@region Array
    function A(const v: tiscript_value): ITiscriptArray; overload;
    function A(const num_elements: UINT): ITiscriptArray; overload;
    function Symbol(const v: SciterString): ITiscriptValue;
    function Bytes(const data: PByte; datalen: UINT): ITiscriptValue;
    function Json(const jsonStr: SciterString): ITiscriptValue;

    // informs VM that native method got an error condition. Native method should return from the function after the call.
    procedure ThrowError(const error_text: SciterString);

    function Eval(ns: tiscript_value; const text: SciterString): ITiscriptValue; overload;
    function Eval(const text: SciterString): ITiscriptValue; overload;
    // call global function
    function Call(const funcpath: SciterString; const argv: array of const): ITiscriptValue;

    // compile bytecodes
    function Compile(const input, output_bytecodes: ITiscriptStream; template_mode: Boolean = false): Boolean; overload;
    function Compile(const filename: SciterString; const output_bytecodes: ITiscriptStream; template_mode: Boolean = false): Boolean; overload;
    // load bytecodes
    function Loadbc(const input_bytecodes: ITiscriptStream): Boolean; overload;
    function Loadbc(const filename: SciterString): Boolean; overload;
    function LoadTisFile(const filename: SciterString): Boolean;
    function LoadTisText(const script: SciterString): Boolean;

    // Schedule execution of the pfunc(prm) in the thread owning this VM.
    // Used when you need to call scripting methods from threads other than main (GUI) thread
    // It is safe to call tiscript functions inside the pfunc.
    // returns 'true' if scheduling of the call was accepted, 'false' when failure (VM has no dispatcher attached).
    function Post(pfunc: tiscript_callback; prm: Pointer): Boolean;

    property vm: HVM read GetVM;
    property GlobalNs: ITiscriptObject read GetGlobalNs;
    property CurrentNs: ITiscriptObject read GetCurrentNs;
    property ArgCount: UINT read GetArgCount;
    property Arg[const n: UINT]: ITiscriptValue read GetArg;
    // path here is a global "path" of the object, something like: "one", "one.two", etc.
    property ValueByPath[const path: SciterString]: ITiscriptValue read GetValueByPath; default;
  end;

implementation

uses
  TiscriptClass, TiscriptOle {$IFDEF DELPHIXE5UP},AnsiStrings{$ENDIF};

{ TTiscriptRuntime }

constructor TTiscriptRuntime.Create(features, heap_size, stack_size: UINT);
begin
  Fvm := ni.create_vm(features, heap_size,stack_size);
  assert(Fvm<>nil);
  FOwn := True;
end;

destructor TTiscriptRuntime.Destroy;
begin
  if FOwn and (Fvm <> nil) then
    ni.destroy_vm(Fvm);
  inherited;
end;

function TTiscriptRuntime.GetCurrentNs: ITiscriptObject;
begin
  if (FCurrentNs = nil) or (vm <> FCurrentNs.VM) or (FCurrentNs.Value <> ni.get_current_ns(vm)) then
    FCurrentNs := TTiscriptObject.Create(vm, ni.get_current_ns(vm));
  Result := FCurrentNs;
end;

function TTiscriptRuntime.GetGlobalNs: ITiscriptObject;
begin
  if (FGlobalNs = nil) or (vm <> FGlobalNs.VM) then
    FGlobalNs := TTiscriptObject.Create(vm, ni.get_global_ns(vm));
  Result := FGlobalNs;
end;

function TTiscriptRuntime.GetVM: HVM;
begin
  if Fvm = nil then
    Result := ni.get_current_vm
  else
    Result := Fvm;
end;

procedure TTiscriptRuntime.GC;
begin
  ni.invoke_gc(vm);
end;

constructor TTiscriptRuntime.Create(const vm: HVM);
begin
  Fvm := vm;
  FOwn := False;
end;

function TTiscriptRuntime.A(const v: tiscript_value): ITiscriptArray;
begin
  Assert(ni.is_array(v));
  Result := TTiscriptArray.Create(vm, v);
end;

function TTiscriptRuntime.B(const v: Boolean): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.bool_value(v));
end;

function TTiscriptRuntime.D(const v: Double): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.float_value(v));
end;

function TTiscriptRuntime.I(const v: Integer): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.int_value(v));
end;

function TTiscriptRuntime.Nothing: ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.nothing_value());
end;

function TTiscriptRuntime.Null: ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.null_value());
end;

function TTiscriptRuntime.O(const native_object: IDispatch): ITiscriptObject;
begin
  Result := TTiscriptObject.Create(vm, _WrapOleObject(vm, native_object));
end;

function TTiscriptRuntime.Symbol(const v: SciterString): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.symbol_value(PAnsiChar(UTF8Encode(v))));
end;

function TTiscriptRuntime.Undefined: ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.undefined_value);
end;

function TTiscriptRuntime.V(const v: tiscript_value): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, v);
end;

function TTiscriptRuntime.S(const v: SciterString): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.string_value(vm, PWideChar(v), Length(v)));
end;

function TTiscriptRuntime.Bytes(const data: PByte;
  datalen: UINT): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.bytes_value(FVm, data, datalen));
end;

function TTiscriptRuntime.GetValueByPath(const path: SciterString): ITiscriptValue;
var
  v: tiscript_value;
begin
  v := ni.undefined_value;
  ni.get_value_by_path(vm, v, PAnsiChar(UTF8Encode(path)));
  Result := TTiscriptValue.Create(vm, v);
end;

function TTiscriptRuntime.O(const of_class: tiscript_class): ITiscriptObject;
begin
  Result := TTiscriptObject.Create(vm, ni.create_object(vm, of_class));
end;

function TTiscriptRuntime.O(const class_path: SciterString): ITiscriptObject;
var
  cls: ITiscriptValue;
begin
  cls := GetValueByPath(class_path);
  assert(cls.IsClass);
  Result := O(cls.Value);
end;

function TTiscriptRuntime.Json(const jsonStr: SciterString): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, Tiscript.ParseData(jsonStr, vm));
end;

function TTiscriptRuntime.A(const num_elements: UINT): ITiscriptArray;
begin
  Result := TTiscriptArray.Create(vm, num_elements);
end;

procedure TTiscriptRuntime.ThrowError(const error_text: SciterString);
begin
  ni.throw_error(vm, PWideChar(error_text));
end;

function TTiscriptRuntime.Eval(ns: tiscript_value; const text: SciterString): ITiscriptValue;
var
  v: tiscript_value;
begin
  if not ni.eval_string(vm, ns, PWideChar(text), Length(text), v) then
    v := ni.undefined_value();
  Result := TTiscriptValue.Create(vm, v);
end;

function TTiscriptRuntime.Eval(const text: SciterString): ITiscriptValue;
begin
  Result := Eval(ni.get_current_ns(vm), text);
end;

function TTiscriptRuntime.F(const v: tiscript_value; const this: tiscript_object): ITiscriptFunction;
begin
  Assert(ni.is_function(v) or ni.is_native_function(v));
  if this = 0 then
    Result := TTiscriptFunction.Create(vm, v, ni.get_current_ns(vm))
  else
    Result := TTiscriptFunction.Create(vm, v, this)
end;

function TTiscriptRuntime.call(const funcpath: SciterString; const argv: array of const): ITiscriptValue;
var
  func: ITiscriptValue;
begin
  func := GetValueByPath(funcpath);
  if func.IsFunction or func.IsNativeFunction then
    Result := func.F.Call(argv)
  else
    Result := Undefined;
end;

function TTiscriptRuntime.compile(const input, output_bytecodes: ITiscriptStream;
  template_mode: Boolean): Boolean;
begin
  Result := ni.compile(vm, input.Data, output_bytecodes.Data, template_mode);
end;

function TTiscriptRuntime.loadbc(const input_bytecodes: ITiscriptStream): Boolean;
begin
  Result := ni.loadbc(vm,input_bytecodes.Data);
end;

function TTiscriptRuntime.post(pfunc: tiscript_callback;
  prm: Pointer): Boolean;
begin
  Result := ni.post(vm, pfunc, prm);
end;

function TTiscriptRuntime.GetArgCount: UINT;
begin
  Result := ni.get_arg_count(vm);
end;

function TTiscriptRuntime.GetArg(const n: UINT): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(vm, ni.get_arg_n(vm, n));
end;

function TTiscriptRuntime.Loadbc(const filename: SciterString): Boolean;
var
  fs: ITiscriptStream;
begin
  fs := TTiscriptFileStream.Create(filename);
  Result := loadbc(fs);
end;

function TTiscriptRuntime.LoadTisFile(const filename: SciterString): Boolean;
var
  input, output: ITiscriptStream;
begin
  Result := False;
  input := TTiscriptFileStream.Create(filename);
  output := TTiscriptStringStream.Create('');
  if not compile(input, output) then
  begin
    // output.SaveToFile(ChangeFileExt(filename, '1.tis'));
    Exit;
  end;
  Result := loadbc(output);
end;

function TTiscriptRuntime.Compile(const filename: SciterString;
  const output_bytecodes: ITiscriptStream;
  template_mode: Boolean): Boolean;
var
  input: ITiscriptStream;
begin
  input := TTiscriptFileStream.Create(filename);
  Result := compile(input, output_bytecodes, template_mode);
end;

function TTiscriptRuntime.LoadTisText(const script: SciterString): Boolean;
var
  input, output: ITiscriptStream;
begin
  Result := False;
  input := TTiscriptStringStream.Create(script);
  output := TTiscriptStringStream.Create('');
  if not compile(input, output) then
    Exit;
  Result := loadbc(output);
end;

end.
