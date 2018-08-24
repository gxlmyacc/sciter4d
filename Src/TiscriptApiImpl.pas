{*******************************************************************************
 标题:     TiscriptApiImpl.pas
 描述:     Tiscript的API定义单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptApiImpl;

interface

{$I Sciter.inc}

uses
  SysUtils, Windows, Classes, SciterTypes, TiscriptTypes, TiscriptIntf,
  TypInfo;

type
  ETiscriptException = class(Exception);

  tiscript_native_interface = record
    // create new tiscript_VM [and make it current for the thread].
    create_vm: function (features: UINT{= 0xffffffff}; heap_size: UINT{= 1*1024*1024}; stack_size: UINT{= 64*1024}): HVM; cdecl;
    // destroy tiscript_VM
    destroy_vm: procedure (pvm: HVM); cdecl;
    // invoke GC
    invoke_gc: procedure (pvm: HVM); cdecl;
    // set stdin, stdout and stderr for this tiscript_VM
    set_std_streams: procedure (pvm: HVM; input, output, error: Ptiscript_stream); cdecl;
    // get tiscript_VM attached to the current thread
    get_current_vm: function (): HVM; cdecl;
    // get global namespace (Object)
    get_global_ns: function (pvm: HVM): tiscript_value; cdecl;
    // get current namespace (Object)
    get_current_ns: function (pvm: HVM): tiscript_value; cdecl;

    is_int: function (v: tiscript_value): Boolean; cdecl;
    is_float: function (v: tiscript_value): Boolean; cdecl;
    is_symbol: function (v: tiscript_value): Boolean; cdecl;
    is_string: function (v: tiscript_value): Boolean; cdecl;
    is_array: function (v: tiscript_value): Boolean; cdecl;
    is_object: function (v: tiscript_value): Boolean; cdecl;
    is_native_object: function (v: tiscript_value): Boolean; cdecl;
    is_function: function (v: tiscript_value): Boolean; cdecl;
    is_native_function: function (v: tiscript_value): Boolean; cdecl;
    is_instance_of: function (v, cls: tiscript_value): Boolean; cdecl;
    is_undefined: function (v: tiscript_value): Boolean; cdecl;
    is_nothing: function (v: tiscript_value): Boolean; cdecl;
    is_null: function (v: tiscript_value): Boolean; cdecl;
    is_true: function (v: tiscript_value): Boolean; cdecl;
    is_false: function (v: tiscript_value): Boolean; cdecl;
    is_class: function (pvm: HVM; v: tiscript_value): Boolean; cdecl;
    is_error: function (v: tiscript_value): Boolean; cdecl;
    is_bytes: function (v: tiscript_value): Boolean; cdecl;
    is_datetime: function (pvm: HVM; v: tiscript_value): Boolean; cdecl;

    get_int_value: function (v: tiscript_value; var pi: Integer): Boolean; cdecl;
    get_float_value: function (v: tiscript_value; var pi: double): Boolean; cdecl;
    get_bool_value: function (v: tiscript_value; var pi: Boolean): Boolean; cdecl;
    get_symbol_value: function (v: tiscript_value; var pi: PWideChar): Boolean; cdecl;
    get_string_value: function (v: tiscript_value; var pdata: PWideChar; var plength: UINT): Boolean; cdecl;
    get_bytes: function (v: tiscript_value; var ppbi: PAnsiChar; var pblen: UINT): Boolean; cdecl;
    get_datetime: function (pvm: HVM; v: tiscript_value; var dt: Int64): Boolean; cdecl;
      // dt - 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC)
      // a.k.a. FILETIME in Windows
                                                         
    nothing_value: function (): tiscript_value; cdecl;  // special value that designates "does not exist" result.
    undefined_value: function (): tiscript_value; cdecl;
    null_value: function (): tiscript_value; cdecl;
    bool_value: function (v: Boolean): tiscript_value; cdecl;
    int_value: function (v: Integer): tiscript_value; cdecl;
    float_value: function (v: Double): tiscript_value; cdecl;
    string_value: function (pvm: HVM; const text: PWideChar; text_length: UINT): tiscript_value; cdecl;
    symbol_value: function (const zstr: PAnsiChar): tiscript_value; cdecl;
    bytes_value: function (pvm: HVM; const data: PByte; data_length: UINT): tiscript_value; cdecl;
    datetime_value: function (pvm: HVM; dt: UINT): tiscript_value; cdecl;

    to_string: function (pvm: HVM; v: tiscript_value): tiscript_value; cdecl;
    
    // define native class
    define_class: function (
      vm:  HVM;          // in this tiscript_VM
      cls: Ptiscript_class_def;   //
      zns: tiscript_value        // in this namespace object (or 0 if global)
      ): tiscript_value; cdecl;

    // object
    create_object: function (pvm: HVM; of_class: tiscript_value): tiscript_value; cdecl;  // of_class == 0 - "Object"
    set_prop: function (pvm: HVM; obj, key, tiscript_value: tiscript_value): Boolean; cdecl;
    get_prop: function (pvm: HVM; obj, key: tiscript_value): tiscript_value; cdecl;
    for_each_prop: function (pvm: HVM; obj: tiscript_value; cb: tiscript_object_enum; tag: Pointer): Boolean; cdecl;
    get_instance_data: function (obj: tiscript_value): Pointer; cdecl;
    set_instance_data: procedure (obj: tiscript_value; data: Pointer); cdecl;

    // array
    create_array: function (pvm: HVM; of_size: UINT): tiscript_value; cdecl;
    set_elem: function (pvm: HVM; obj: tiscript_value; idx: UINT; tiscript_value: tiscript_value): Boolean; cdecl;
    get_elem: function (pvm: HVM; obj: tiscript_value; idx: UINT): tiscript_value; cdecl;
    set_array_size: function (pvm: HVM; obj: tiscript_value; of_size: UINT): tiscript_value; cdecl;
    get_array_size: function (pvm: HVM; obj: tiscript_value): UINT; cdecl;

    // eval
    eval: function (pvm: HVM; ns: tiscript_value; input: Ptiscript_stream; template_mode: Boolean; var pretval: tiscript_value): Boolean; cdecl;
    eval_string: function (pvm: HVM; ns: tiscript_value; const script: PWideChar; script_length: UINT; var pretval: tiscript_value): Boolean; cdecl;

    // call function (method)
    call: function (pvm: HVM; obj, func: tiscript_value; const argv: Ptiscript_value; argn: UINT; var pretval: tiscript_value): Boolean; cdecl;

    // compiled bytecodes
    compile: function (pvm: HVM; input, output_bytecodes: Ptiscript_stream; template_mode: Boolean): Boolean; cdecl;
    loadbc: function (pvm: HVM; input_bytecodes: Ptiscript_stream): Boolean; cdecl;

    // throw error
    throw_error: procedure (pvm: HVM; const error: PWideChar); cdecl;

    // arguments access
    get_arg_count: function (pvm: HVM): UINT; cdecl;
    get_arg_n: function (pvm: HVM; n: UINT): tiscript_value; cdecl;

    // path here is global "path" of the object, something like
    // "one"
    // "one.two", etc.
    get_value_by_path: function (pvm: HVM; var v: tiscript_value; const path: PAnsiChar): Boolean; cdecl;

    // pins
    pin: procedure (pvm: HVM; pp: Ptiscript_pvalue); cdecl;
    unpin: procedure (pp: Ptiscript_pvalue); cdecl;

    // create native_function_value and native_property_value,
    // use this if you want to add native functions/properties in runtime to exisiting classes or namespaces (including global ns)
    native_function_value: function (pvm: HVM; p_method_def: Ptiscript_method_def): tiscript_value; cdecl;
    native_property_value: function (pvm: HVM; p_prop_def: Ptiscript_prop_def): tiscript_value; cdecl;

    // Schedule execution of the pfunc(prm) in the thread owning this VM.
    // Used when you need to call scripting methods from threads other than main (GUI) thread
    // It is safe to call tiscript functions inside the pfunc.
    // returns 'true' if scheduling of the call was accepted, 'false' when failure (VM has no dispatcher attached).
    post: function (pvm: HVM; pfunc: tiscript_callback; prm: Pointer): Boolean; cdecl;

   // Introduce alien VM to the host VM:
   // Calls method found on "host_method_path" (if there is any) on the pvm_host
   // notifying the host about other VM (alien) creation. Return value of script function "host_method_path" running in pvm_host is passed
   // as a parametr of a call to function at "alien_method_path".
   // One of possible uses of this function:
   // Function at "host_method_path" creates async streams that will serve a role of stdin, stdout and stderr for the alien vm.
   // This way two VMs can communicate with each other.
   //unsigned      (TISAPI *introduce_vm)(tiscript_VM* pvm_host, const char* host_method_path,  tiscript_VM* pvm_alien, const char* alien_method_path);
   set_remote_std_streams: function (pvm: HVM; var input, output, error: tiscript_pvalue): Boolean; cdecl;

   // support of multi-return values from native fucntions, n here is a number 1..64
   set_nth_retval: function (pvm: HVM; n: Integer; ns: tiscript_value): Boolean; cdecl;
   // returns number of props in object, elements in array, or bytes in byte array.
   get_length: function (pvm: HVM; obj: tiscript_value): Integer; cdecl;
   // for( var val in coll ) {...}
   get_next: function (pvm: HVM; var obj, pos, val: tiscript_value): Boolean; cdecl;
   // for( var (key,val) in coll ) {...}
   get_next_key_value: function (pvm: HVM; var obj, pos, key, val: tiscript_value): Boolean; cdecl;

   // associate extra data pointer with the VM
   set_extra_data: function (pvm: HVM; data: Pointer): Boolean; cdecl;
   get_extra_data: function (pvm: HVM): Pointer; cdecl;
  end;
  Ptiscript_native_interface = ^tiscript_native_interface;

  // signature of TIScriptLibraryInit function - entry point of TIScript Extnension Library
  TIScriptLibraryInitFunc = procedure (vm: HVM; piface: Ptiscript_native_interface); stdcall;

function ni(ni: Ptiscript_native_interface = nil): Ptiscript_native_interface;

function  T2V(vm: HVM; const Value: tiscript_value; var OleValue: OleVariant; tObject: Ptiscript_value;
  ReturnType: PPTypeInfo = nil): UINT;
function  V2T(vm: HVM; const Value: OleVariant; var tsValue: tiscript_value;
  ReturnType: PPTypeInfo = nil): UINT;
function GetNativeObjectJson(const vm: HVM; const Value: tiscript_value): SciterString;

function ElementClass(const vm: HVM): tiscript_value;
function IsNameExists(const vm: HVM; const Name: SciterString): tiscript_value;
function IsClassExists(const vm: HVM; const Name: SciterString): tiscript_value;
function FindObject(const vm: HVM; const Name: SciterString): tiscript_value;
function FindClass(const vm: HVM; const ClassName: SciterString): tiscript_class;
function RegisterNativeFunction(const vm: HVM; const Name: SciterString; Handler: Pointer;
  Tag: Pointer = nil; Wrap: Boolean = True): tiscript_value;
function RegisterNativeClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean): tiscript_class;
function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object; overload;
function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: SciterString): tiscript_object; overload;
procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: SciterString); overload;
function RegisterObject(const vm: HVM; Obj: IDispatch; const OfClass: SciterString; const VarName: SciterString): tiscript_value; overload;
function RegisterObject(const vm: HVM; Obj: IDispatch; const VarName: SciterString): tiscript_value; overload;
procedure UnRegisterVariable(const vm: HVM; const VarName: SciterString);
procedure ThrowError(const vm: HVM; const Message: AnsiString); overload;
procedure ThrowError(const vm: HVM; const Message: SciterString); overload;

procedure ClearMethodRecList(const vm: HVM = nil);

implementation

uses
  SciterApiImpl, Variants, ActiveX, SciterFactoryIntf, SciterIntf, TiscriptOle,
  TiscriptClass{$IFDEF DELPHIXE5UP},AnsiStrings{$ENDIF};

var
  _ni: Ptiscript_native_interface = nil;
  _method_rec_list: TThreadList = nil;

procedure ClearMethodRecList(const vm: HVM);
var
  i: Integer;
  method_rec: Ptiscript_method_rec;
  LList: TList;
begin
  LList := _method_rec_list.LockList;
  try
    for i := LList.Count - 1 downto 0 do
    begin
      method_rec := Ptiscript_method_rec(LList[i]);
      if (vm <> nil) and (vm <> method_rec.vm) then
        Continue;
      if method_rec.def.name <> nil then
        {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrDispose(method_rec.def.name);
      Dispose(method_rec);
      LList.Delete(i);
    end;
  finally
    _method_rec_list.UnlockList;
  end;
end;

function ni(ni: Ptiscript_native_interface = nil): Ptiscript_native_interface;
begin
  if ni <> nil then
    _ni := ni;
  Result := _ni;
end;

function GetNativeObjectJson(const vm: HVM; const Value: tiscript_value): SciterString;
var
  sValue: SCITER_VALUE;
begin
  SAPI.ValueInit(sValue);
  if not SAPI.Sciter_T2S(vm, Value, @sValue, False) then
    raise ETiscriptException.Create('Failed to convert tiscript_value to SCITER_VALUE.');
  Result := SciterApiImpl.GetNativeObjectJson(sValue);
end;

{ Variant to tiscript value conversion }
function  V2T(vm: HVM; const Value: OleVariant; var tsValue: tiscript_value; ReturnType: PPTypeInfo): UINT;
{$IF CompilerVersion <= 18.5}
const
  varUString  = $0102; 
{$IFEND}
var
  sWStr: SciterString;
  date: TDateTime;
  st: SYSTEMTIME;
  ft: TFileTime;
  pDisp: IDispatch;
  cCur: Currency;
  vt: Word;
  pValue: ITiscriptValue;
  pObj: ITiscriptObject;
  pArray: ITiscriptArray;
  pFunc: ITiscriptFunction;
  pDispFunc: IDispatchFunction;
  pElement: IDomElement;
begin
  vt := VarType(Value);
  case vt of
    varEmpty:
    begin
      tsValue := ni.undefined_value;
      Result := HV_OK;
    end;
    varNull:
    begin
      tsValue := ni.null_value;
      Result := HV_OK;
    end;
    varString, varUString, varOleStr:
    begin
      sWStr := Value;
      if (ReturnType <> nil) and (ReturnType^.Name = JSONObjectName) then
      begin
        if sWStr <> '' then
          tsValue := Tiscript.ParseData(sWStr, vm)
        else
          tsValue := ni.undefined_value;
      end
      else
        tsValue := ni.string_value(vm, PWideChar(sWStr), Length(sWStr));
      Result := HV_OK;
    end;
    varBoolean:
    begin
      tsValue := ni.bool_value(Value);
      Result := HV_OK;
    end;
    varByte,
    varSmallInt,
    varInteger,
    varWord,
    varLongWord,
    varInt64:
    begin
      if (ReturnType<>nil) and (
           (ReturnType^.Name = 'tiscript_value')
        or (ReturnType^.Name = 'tiscript_object')
        or (ReturnType^.Name = 'tiscript_class')) then
        tsValue := Value
      else
        tsValue := ni.int_value(Value);
      Result := HV_OK;
    end;
    varSingle,
    varDouble:
    begin
      tsValue := ni.float_value(Value);
      Result := HV_OK;
    end;
    varCurrency:
    begin
      cCur := Value;
      tsValue := ni.float_value(cCur);
      Result := HV_OK;
    end;
    varDate:
    begin
      date := TDateTime(Value);
      if ReturnType <> nil  then
        DateTimeToSystemTime(date, st)
      else
        VariantTimeToSystemTime(date, st);
      SystemTimeToFileTime(st, ft);
      tsValue := ni.datetime_value(vm, Int64(ft));
      Result := HV_OK;
    end;
    varUnknown:
    begin
      if TVarData(Value).VUnknown = nil  then
        tsValue := ni.undefined_value
      else
      if Supports(IUnknown(TVarData(Value).VUnknown), ITiscriptValue, pValue) then
        tsValue := pValue.Value
      else
      if Supports(IInterface(TVarData(Value).VUnknown), ITiscriptObject, pObj) then
        tsValue := pObj.Value
      else
      if Supports(IInterface(TVarData(Value).VUnknown), ITiscriptArray, pArray) then
        tsValue := pArray.Value
      else
      if Supports(IInterface(TVarData(Value).VUnknown), ITiscriptFunction, pFunc) then
        tsValue := pFunc.Value
      else
      if Supports(IInterface(TVarData(Value).VUnknown), IDispatchFunction, pDispFunc) then
        tsValue := pDispFunc.Value.Value
      else
      if Supports(IInterface(TVarData(Value).VUnknown), IDomElement, pElement) then
      begin
        tsValue := ni.create_object(vm, ElementClass(vm));
        ni.set_instance_data(tsValue, pElement.Element);
      end
      else
        raise ETiscriptException.CreateFmt('Cannot convert VARIANT of type %d to TIScript value.', [vt]);
      Result := HV_OK;
    end;
    varDispatch:
    begin
      pDisp := IDispatch(Value);
      if Supports(pDisp, IDispatchFunction, pDispFunc) then
        tsValue := pDispFunc.Value.Value
      else
        tsValue := _WrapOleObject(vm, pDisp);
      //pDisp._AddRef;
      Result := HV_OK;
    end;
  else
    raise ETiscriptException.CreateFmt('Cannot convert VARIANT of type %d to TIScript value.', [vt]);
  end;
end;

function  T2V(vm: HVM; const Value: tiscript_value; var OleValue: OleVariant; tObject: Ptiscript_value;
  ReturnType: PPTypeInfo): UINT;
var
  pWStr: PWideChar;
  iNum: UINT;
  sWStr: SciterString;
  iResult: Integer;
  dResult: Double;
  i64Result: Int64;
  ft: TFileTime;
  st: SYSTEMTIME;
  pDispValue: IDispatch;
  pTisValue: ITiscriptValue;
  pFuncValue: ITiscriptFunction;
  pObjValue: ITiscriptObject;
  pArrayValue: ITiscriptArray;
  ns: tiscript_value;
begin
  if ni.is_int(Value) then
  begin
    if NI.get_int_value(Value, iResult) then
      Result := HV_OK
    else
      raise ETiscriptException.CreateFmt('Cannot get integer value.', []);
    OleValue := iResult;
  end
  else
  if ni.is_float(Value) then
  begin
    if NI.get_float_value(Value, dResult) then
      Result := HV_OK
    else
      raise ETiscriptException.CreateFmt('Cannot get float value.', []);
    OleValue := dResult;
  end
  else
  if ni.is_symbol(Value) then
  begin
    if ni.is_undefined(Value) or ni.is_null(Value) then
    begin
      if (ReturnType <> nil) and (ReturnType^.Kind = tkInterface) then
      begin
        TVarData(OleValue).VType := varUnknown;
        TVarData(OleValue).VUnknown := nil;
      end
      else
        OleValue := Unassigned;
      Result := HV_OK;
    end
    else
    if ni.get_symbol_value(Value, pWStr) then
    begin
      Result := HV_OK;
      sWStr := pWStr;
      OleValue := sWStr;
    end
    else
      raise ETiscriptException.CreateFmt('Cannot get symbol value.', []);
  end
  else
  if ni.is_string(Value) then
  begin
    if ni.get_string_value(Value, pWStr, iNum) then
      Result := HV_OK
    else
      raise ETiscriptException.CreateFmt('Cannot get string value.', []);
    sWStr := SciterString(pWStr);
    OleValue := sWStr;
  end
  else
  if ni.is_array(Value) then
  begin
    if (ReturnType<>nil) and (ReturnType^.Kind = tkInterface) then
    begin
      if ReturnType^.Name = 'ITiscriptArray' then
      begin
        pArrayValue := TTiscriptArray.Create(vm, Value);
        OleValue := pArrayValue;
      end
      else
      if ReturnType^.Name = 'ITiscriptValue' then
      begin
        pTisValue := TTiscriptValue.Create(vm, Value);
        OleValue := pTisValue;
      end
      else
      if ReturnType^.Name = 'tiscript_value' then
        OleValue := Value
      else
        raise ETiscriptException.Create('Cannot convert T_ARRAY to unknown interface.');
    end
    else
      OleValue := GetNativeObjectJson(vm, Value);
    Result := HV_OK;
  end
  else
  if ni.is_object(Value) or ni.is_native_object(Value) then
  begin
    if (ReturnType<>nil) and (ReturnType^.Kind = tkInterface) then
    begin
      if ReturnType^.Name = 'ITiscriptObject' then
      begin
        pObjValue := TTiscriptObject.Create(vm, Value);
        OleValue := pObjValue;
      end
      else
      if  ReturnType^.Name = 'ITiscriptValue' then
      begin
        pTisValue := TTiscriptValue.Create(vm, Value);
        OleValue := pTisValue;
      end
      else
      if (ReturnType^.Name = 'IDomElement') and (ni.is_native_object(Value)) then
      begin
        pTisValue := TTiscriptValue.Create(vm, Value);
        OleValue := ElementFactory.Create(pTisValue.E)
      end
      else
        raise ETiscriptException.Create('Cannot convert T_OBJECT to unknown interface.');
    end
    else
    if (ReturnType<>nil) and (ReturnType^.Kind = tkInt64) and
       ((ReturnType^.Name = 'tiscript_value')
        or (ReturnType^.Name = 'tiscript_object')
        or (ReturnType^.Name = 'tiscript_class')) then
       OleValue := Value
    else
    if ni.is_native_object(Value) then
    begin
      pDispValue := IDispatch(NI.get_instance_data(Value));
      OleValue := pDispValue;
    end
    else
      OleValue := GetNativeObjectJson(vm, Value);
    Result := HV_OK;
  end
  else
  if ni.is_function(Value) or ni.is_native_function(Value) then
  begin
    if tObject = nil then
    begin
      ns := ni.get_current_ns(vm);
      tObject := @ns;
    end;
    if ReturnType <> nil then
    begin
      if ReturnType^.Kind = tkInterface then
      begin
        if ReturnType^.Name = 'ITiscriptFunction' then
        begin
          pFuncValue := TTiscriptFunction.Create(vm, Value, tObject^);
          OleValue := pFuncValue;
        end
        else
        if ReturnType^.Name = 'IDispatch' then
        begin
          pFuncValue := TTiscriptFunction.Create(vm, Value, tObject^);
          pDispValue := TDispatchFunction.Create(pFuncValue);
          OleValue := pDispValue;
        end
        else
        if ReturnType^.Name = 'tiscript_value' then
          OleValue := Value
        else
         raise ETiscriptException.Create('Cannot convert T_FUNCTION to unknown interface.');
      end
      else
      if ReturnType^.Kind = tkVariant then
      begin
        pFuncValue := TTiscriptFunction.Create(vm, Value, tObject^);
        pDispValue := TDispatchFunction.Create(pFuncValue);
        OleValue := pDispValue;
      end
      else
        raise ETiscriptException.Create('Cannot convert T_FUNCTION to unsupport type.');
    end
    else
      raise ETiscriptException.Create('Cannot convert T_FUNCTION to unknown type.');
    Result := HV_OK;
  end
  else
  if ni.is_nothing(Value) then
  begin
    if (ReturnType <> nil) and (ReturnType^.Kind = tkInterface) then
    begin
      TVarData(OleValue).VType := varUnknown;
      TVarData(OleValue).VUnknown := nil;
    end
    else
      OleValue := Null;
    Result := HV_OK;
  end
  else
  if ni.is_true(Value) then
  begin
    OleValue := True;
    Result := HV_OK;
  end
  else
  if ni.is_false(Value) then
  begin
    OleValue := False;
    Result := HV_OK;
  end
  else
  if ni.is_error(Value) then
  begin
    raise ETiscriptException.Create('Cannot convert T_ERROR to Variant (not implemented).');
  end
  else
  if ni.is_bytes(Value) then
  begin
    raise ETiscriptException.Create('Cannot convert T_BYTES to Variant (not implemented).');
  end
  else
  if ni.is_datetime(vm, Value) then
  begin
    if ni.get_datetime(vm, Value, i64Result) then
      Result := HV_OK
    else
      raise ETiscriptException.Create('Cannot get datetime value.');
    ft := TFileTime(i64Result);
    FileTimeToSystemTime(ft, st);
    SystemTimeToVariantTime(st, dResult);
    OleValue := TDateTime(dResult);
  end
  else
    raise ETiscriptException.Create('Conversion from TIScript type to Variant is not implemented.');
end;

function ElementClass(const vm: HVM): tiscript_value;
const
  Element_Name: WideString = 'Element';
begin
  Result := NI.get_prop(vm, ni.get_global_ns(vm), ni.string_value(vm, PWideChar(Element_Name), Length(Element_Name)));
end;

function IsNameExists(const vm: HVM; const Name: SciterString): tiscript_value;
var
  var_name, var_value: tiscript_value;
  zns: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  if NI.is_undefined(var_value) then
    Result := 0
  else
    Result := var_value;
end;

function IsClassExists(const vm: HVM; const Name: SciterString): tiscript_value;
var
  var_name: tiscript_value;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  if NI.is_class(vm, var_value) then
    Result := var_value
  else
    Result := 0;
end;

function FindObject(const vm: HVM; const Name: SciterString): tiscript_value;
var
  var_name: tiscript_value;
  var_value: tiscript_object;
  zns: tiscript_value;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));
  var_value := NI.get_prop(vm, zns, var_name);
  Result := var_value;
end;

function FindClass(const vm: HVM; const ClassName: SciterString): tiscript_class;
var
  zns: tiscript_value;
  tclass_name: tiscript_value;
  class_def: tiscript_class;
begin
  zns := NI.get_global_ns(vm);
  tclass_name  := NI.string_value(vm, PWideChar(ClassName), Length(ClassName));
  class_def    := NI.get_prop(vm, zns, tclass_name);
  if NI.is_class(vm, class_def) then
    Result := class_def
  else
    Result := NI.undefined_value;
end;

function _WrapTiscriptValueArray(vm: HVM; argCount: Integer; args: Ptiscript_value_array): TTiscriptDynValueArray;
var
  i: Integer;
begin
  if argCount <= 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  SetLength(Result, argCount);
  for i := 0 to argCount -1 do
    Result[i] := TTiscriptValue.Create(vm, args[i]);
end;

function _NativeFunctionWrap(vm: HVM; this: tiscript_value; method_rec: Ptiscript_method_rec): tiscript_value; cdecl;
var
  argCount, i: Integer;
  args: TTiscriptDynValueArray;
  pThis, pSuper: ITiscriptObject;
  vResult: ITiscriptValue;
begin
  Result := ni.undefined_value;
  try
    pThis := TTiscriptObject.Create(vm, this);
    vResult := nil;
    argCount := NI.get_arg_count(vm);
    if argCount > 2 then
    begin
      pSuper := TTiscriptObject.Create(vm, NI.get_arg_n(vm, 1));
      SetLength(args, argCount-2);
      for i := 2 to argCount-1 do
        args[i-2] := TTiscriptValue.Create(vm, NI.get_arg_n(vm, i), True, this);
      vResult := TTiscriptNativeMethod(method_rec.Handler)(vm, pThis, pSuper, argCount-2, PTiscriptValueArray(args), method_rec.tag);
      SetLength(args, 0);
    end
    else
      vResult := TTiscriptNativeMethod(method_rec.Handler)(vm, pThis, nil, 0, nil, method_rec.tag);
    if vResult <> nil then
      Result := vResult.Value;
  except
    on E: Exception do
    begin
      TraceException('[_NativeFunctionWrap]'+e.Message);
      ThrowError(vm, E.Message);
    end
  end;
end;

function RegisterNativeFunction(const vm: HVM; const Name: SciterString;
  Handler, Tag: Pointer; Wrap: Boolean): tiscript_value;
var
  method_rec: Ptiscript_method_rec;
  smethod_name: UTF8String;
  func_def, func_name, zns: tiscript_value;
begin
  if vm = nil then
    raise ETiscriptException.CreateFmt('Failed to register native function %s. vm is nil.', [Name]);

  if Name <> '' then
  begin
    zns := NI.get_global_ns(vm);
    func_name := NI.string_value(vm, PWideChar(Name), Length(Name));
    func_def := NI.get_prop(vm, zns, func_name);
  end
  else
  begin
    zns := 0;
    func_name := 0;
    func_def := ni.undefined_value;
  end;
  if ni.is_undefined(func_def) or NI.is_native_function(func_def) then
  begin
    smethod_name := UTF8Encode(Name);
    New(method_rec);
    method_rec.vm := vm;
    method_rec.Handler := Handler;
    method_rec.tag := Tag;
    method_rec.def.dispatch := nil;
    if smethod_name <> '' then
      method_rec.def.name := {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrNew(PAnsiChar(smethod_name))
    else
      method_rec.def.name := nil;
    if Wrap then
    begin
      method_rec.def.handler := @_NativeFunctionWrap;
      method_rec.def.tag := method_rec;
    end
    else
    begin
      method_rec.def.handler := Handler;
      if Tag = nil then method_rec.def.tag := Pointer(1)
      else method_rec.def.tag := Tag;
    end;
    method_rec.def.payload := 0;
    func_def := NI.native_function_value(vm, @method_rec.def);
    if not NI.is_native_function(func_def) then
    begin
      if method_rec.def.name <> nil then
        {$IFDEF DELPHIXE5UP}AnsiStrings.{$ENDIF}StrDispose(method_rec.def.name);
      Dispose(method_rec);
      raise ETiscriptException.CreateFmt('Failed to register native function "%s".', [Name]);
    end;
    _method_rec_list.Add(method_rec);
    if func_name <> 0 then
      NI.set_prop(vm, zns, func_name, func_def);
    Result := func_def;
  end
  else
    raise ETiscriptException.CreateFmt('Failed to register native function %s. Object with same name already exists.', [Name])
end;

function RegisterNativeClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean): tiscript_class;
var
  zns: tiscript_value;
  wclass_name: SciterString;
  tclass_name: tiscript_value;
  class_def: tiscript_class;
begin
  zns := NI.get_global_ns(vm);

  wclass_name  := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(UTF8String(ClassDef.name));
  tclass_name  := NI.string_value(vm, PWideChar(wclass_name), Length(wclass_name));
  class_def    := NI.get_prop(vm, zns, tclass_name);

  if NI.is_undefined(class_def) or NI.is_nothing(class_def) or NI.is_null(class_def) then
  begin
    class_def := NI.define_class(vm, ClassDef, zns);
    if not NI.is_class(vm, class_def) then
      raise ETiscriptException.CreateFmt('Failed to register class definition.', []);
    Result := class_def;
  end
  else
  if NI.is_class(vm, class_def) then
  begin
    if ThrowIfExists then
      raise ETiscriptException.CreateFmt('Class "%s" already exists.', [String(ClassDef.name)])
    else
      Result := class_def;
  end
  else
    raise ETiscriptException.CreateFmt('Failed to register native class "%s". Object with same name (class, namespace, constant, variable or function) already exists.', [String(ClassDef.name)]);
end;

function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object;
begin
  if not NI.is_class(vm, OfClass) then
    raise ETiscriptException.CreateFmt('Cannot create object instance. Provided value is not a class.', []);
  Result := NI.create_object(vm, OfClass);
  NI.set_instance_data(Result, Obj);
end;

function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: SciterString): tiscript_object;
var
  t_class: tiscript_class;
begin
  t_class := FindClass(vm, OfClass);
  Result := CreateObjectInstance(vm, Obj, t_class);
end;

procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: SciterString);
var
  zns: tiscript_value;
  var_name: tiscript_value;
begin
  if not NI.is_native_object(Obj) then
    raise ETiscriptException.CreateFmt('Cannot register object instance. Provided value is not an object.', []);

  // If a variable VarName already exists it'll be rewritten
  var_name := NI.string_value(vm, PWideChar(VarName), Length(VarName));
  zns := NI.get_global_ns(vm);
  NI.set_prop(vm, zns, var_name, Obj);
end;

function RegisterObject(const vm: HVM; Obj: IDispatch; const OfClass: SciterString; const VarName: SciterString): tiscript_value;
begin
  Result := _RegisterOleObject(vm, Obj, OfClass);
  RegisterObject(vm, Result, VarName);
end;

function RegisterObject(const vm: HVM; Obj: IDispatch; const VarName: SciterString): tiscript_value;
begin
  Result := _RegisterOleObject(vm, Obj, 'T'+VarName);
  RegisterObject(vm, Result, VarName);
end;

procedure UnRegisterVariable(const vm: HVM; const VarName: SciterString);
var
  zns: tiscript_value;
  var_name: tiscript_value;
begin
  if vm = nil then Exit;
  // If a variable VarName already exists it'll be rewritten
  var_name := NI.string_value(vm, PWideChar(VarName), Length(VarName));
  zns := NI.get_global_ns(vm);
  NI.set_prop(vm, zns, var_name, NI.undefined_value);
end;

procedure ThrowError(const vm: HVM; const Message: AnsiString);
begin
  NI.throw_error(vm, PWideChar(SciterString(Message)));
end;

procedure ThrowError(const vm: HVM; const Message: SciterString);
begin
  NI.throw_error(vm, PWideChar(Message));
end;

initialization
  _method_rec_list := TThreadList.Create;

finalization
  _ni := nil;
  ClearMethodRecList(nil);
  FreeAndNil(_method_rec_list);

end.
