{*******************************************************************************
 标题:     TiscriptIntf.pas
 描述:     Tiscript的全局接口
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptIntf;

interface

{$I Sciter.inc}

uses
  Windows, SciterTypes, TiscriptTypes;

const
  ClassOfObject = 0;

type
  ITiscriptMethodInfo = interface;
  ITiscriptMethodInfoList = interface;
  ITiscriptClassInfo = interface;
  ITiscriptClassInfoList = interface;
  IVMClassBag = interface;
  IVMClassBagList = interface;
  ITiscriptClassBag = interface;
  ITiscriptStream = interface;
  ITiscriptPined = interface;
  ITiscriptValue= interface;
  ITiscriptFunction = interface;
  ITiscriptObject = interface;
  ITiscriptArray = interface;
  ITiscriptObjectEnumerator = interface;
  ITiscriptArrayEnumerator = interface;

  PITiscriptRuntime = ^ITiscriptRuntime;
  ITiscriptRuntime = interface
  ['{3696A8CA-F395-452D-BA31-3B10D4F46136}']
    function GetArgCount: UINT;
    function GetArg(const n: UINT): ITiscriptValue;
    function GetValueByPath(const path: SciterString): ITiscriptValue;
    function GetCurrentNs: ITiscriptObject;
    function GetGlobalNs: ITiscriptObject;
    function GetVM: HVM;

    // so runtime reference can be used in places where HVM is required
    procedure GC();

    // designates ultimate "does not exist" situation.
    function Nothing: tiscript_value;
    // non-initialized or non-existent value
    function Undefined: tiscript_value;
    // explicit "no object" value
    function Null: tiscript_value;
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
    // Each function call has at least two parameters:
    //    arg[0] -> 'this' - object or namespace object for 'static' functions.
    //    arg[1] -> 'super' - usually you will just args::skip it.
    //    arg[2..argc] -> params defined in script
    property ArgCount: UINT read GetArgCount;
    property Arg[const n: UINT]: ITiscriptValue read GetArg;
    // path here is a global "path" of the object, something like: "one", "one.two", etc.
    property ValueByPath[const path: SciterString]: ITiscriptValue read GetValueByPath; default;
  end;
  
  ITiscriptClassInfo = interface
    ['{2BE4157E-35F2-4279-AD60-C54A867153DE}']
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
    
    function ToString: SciterString;
    
    property FinalizerHandler: tiscript_finalizer read GetFinalizerHandler write SetFinalizerHandler;
    property GCCopyHandler: tiscript_on_gc_copy read GetGCCopyHandler write SetGCCopyHandler;
    property GetItemHandler: tiscript_get_item read GetGetItemHandler write SetGetItemHandler;
    property GetterHandler: tiscript_tagged_get_prop read GetGetterHandler write SetGetterHandler;
    property IteratorHandler: tiscript_iterator read GetIteratorHandler write SetIteratorHandler;
    property MethodHandler: tiscript_tagged_method read GetMethodHandler write SetMethodHandler;
    property Methods: ITiscriptMethodInfoList read GetMethods;
    property SciterClassDef: ptiscript_class_def read GetSciterClassDef;
    property SetItemHandler: tiscript_set_item read GetSetItemHandler write SetSetItemHandler;
    property SetterHandler: tiscript_tagged_set_prop read GetSetterHandler write SetSetterHandler;
    property TypeName: SciterString read GetTypeName write SetTypeName;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

  ITiscriptMethodInfo = interface
  ['{4C446750-0C0E-4F59-99E8-013EAF05CF5C}']
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
    function ToString: SciterString;
    
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

  ITiscriptMethodInfoList = interface
  ['{A4230388-20BF-4ED5-81B7-C5227F579CFC}']
    procedure Add(const Item: ITiscriptMethodInfo);
    procedure Remove(const Item: ITiscriptMethodInfo);
    procedure Clear;
    function Exists(const MethodName: SciterString): boolean;
    function GetCount: Integer;
    function GetItem(Index: Integer): ITiscriptMethodInfo;
    function LookupMethod(const MethodName: SciterString): ITiscriptMethodInfo;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ITiscriptMethodInfo read GetItem; default;
  end;

  ITiscriptClassInfoList = interface
  ['{8A49B48A-8BED-4668-AB37-64C2BD019F96}']
    procedure Add(const ClsInfo: ITiscriptClassInfo);
    function Exists(const TypeName: SciterString): boolean;
    function FindClassInfo(const TypeName: SciterString): ITiscriptClassInfo;
    function GetCount: Integer;
    function GetItem(Index: Integer): ITiscriptClassInfo;
    function ToString: SciterString;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: ITiscriptClassInfo read GetItem; default;
  end;

  { Key-value pair where key is a HVM and value is a list of class definitions registered for that VM }
  IVMClassBag = interface
    ['{BC375E40-BB49-4B0A-A4F4-C61ADA94ED03}']
    function GetClassInfoList: ITiscriptClassInfoList;
    function GetVM: HVM;
    function ToString: SciterString;
    property ClassInfoList: ITiscriptClassInfoList read GetClassInfoList;
    property VM: HVM read GetVM;
  end;

  IVMClassBagList = interface
    ['{B7B0C33B-7B30-4B32-A3A5-630621887710}']
    function GetCount: Integer;
    function GetItem(Index: Integer): IVMClassBag;

    function  IndexOf(const vm: HVM): Integer;
    function  Exists(const vm: HVM): boolean;
    function  GetClassInfoList(const vm: HVM): ITiscriptClassInfoList;

    function  Add(const Item: IVMClassBag): Integer;
    procedure Remove(const Item: IVMClassBag); overload;
    procedure Remove(const vm: HVM); overload;
    function  ClassInfoExists(const vm: HVM; const TypeName: SciterString): boolean;
    function  FindClassInfo(const vm: HVM; const TypeName: SciterString): ITiscriptClassInfo;

    function  ToString: SciterString;

    property Count: Integer read GetCount;
    property Item[Index: Integer]: IVMClassBag read GetItem; default;
  end;

  PITiscriptClassBag = ^ITiscriptClassBag;
  ITiscriptClassBag = interface(IVMClassBagList)
  ['{388C1FB0-67AF-4B07-A71F-9F32F50552A1}']
    function ClassInfoExists(const vm: HVM; const TypeName: SciterString): boolean;
    function CreateInstance(const vm: HVM; const TypeName: SciterString): tiscript_object;
    function FindClassInfo(const vm: HVM; const TypeName: SciterString): ITiscriptClassInfo;
    function RegisterClassInfo(vm: HVM; const ClsInfo: ITiscriptClassInfo): tiscript_class;
    function ResolveClass(vm: HVM; const TypeName: SciterString): tiscript_class;
  end;

  ITiscriptObjectRegInfo = interface
  ['{46357158-103D-47DF-843D-FB5954658710}']
    function GetName: SciterString;
    function GetValue: IDispatch;
    procedure SetName(const Value: SciterString);
    procedure SetValue(const Value: IDispatch);

    property Name: SciterString read GetName write SetName;
    property Value: IDispatch read GetValue write SetValue;
  end;

  TTiscriptObjectAction = (tocaReg, tocaUnreg, tocaChanged);
  TTiscriptObjectListener = procedure (const AInfo: ITiscriptObjectRegInfo; Action: TTiscriptObjectAction) of object;

  PITiscriptObjectList = ^ITiscriptObjectList;
  ITiscriptObjectList = interface
  ['{E2129C46-3426-45A4-8B23-DA1215FC8FE8}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): ITiscriptObjectRegInfo;
    function  GetItemName(const Index: Integer): SciterString;
    function  GetItemByName(const AName: SciterString): ITiscriptObjectRegInfo;
    procedure SetItem(const Index: Integer; const Value: ITiscriptObjectRegInfo);
    procedure SetItemByName(const AName: SciterString; const Value: ITiscriptObjectRegInfo);

    procedure Invalidate;

    function  Reg(const AName: SciterString; const AItem: IDispatch): Integer;
    procedure UnReg(const Index: Integer); overload;
    procedure UnReg(const AName: SciterString); overload;
    procedure Clear;
    
    function  IndexOf(const AItem: IDispatch): Integer;
    function  IndexOfName(const AName: SciterString): Integer;

    function AddListener(const AListener: TTiscriptObjectListener): Integer;
    function RemoveListener(const AListener: TTiscriptObjectListener): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: ITiscriptObjectRegInfo read GetItem write SetItem; default;
    property ItemName[const Index: Integer]: SciterString read GetItemName;
    property ItemByName[const AName: SciterString]: ITiscriptObjectRegInfo read GetItemByName write SetItemByName;
  end;


  PITiscriptStream = ^ITiscriptStream;
  ITiscriptStream = interface
  ['{3567BDB5-0113-4BFE-ABD2-A0DE38BD20C8}']
    function  GetData: Ptiscript_stream;
    function  GetStreamName: SciterString;
    procedure SetData(const Value: Ptiscript_stream);
    procedure SetStreamName(const Value: SciterString);

    // these need to be overrided
    function  Read: Integer;
    function  Write(const value: Integer): Boolean;
    procedure Close();

    function SaveToFile(const filename: SciterString): Boolean;

    property StreamName: SciterString read GetStreamName write SetStreamName;
    property Data: Ptiscript_stream read GetData write SetData;
  end;

  ITiscriptStringStream = interface(ITiscriptStream)
  ['{E329D54B-3D1E-4C15-BC23-3EDAFB6F2414}']
    function GetDataString: SciterString;
    
    property DataString: SciterString read GetDataString;
  end;
  ITiscriptFileStream = interface(ITiscriptStream)
  ['{B1A35FC1-0DEF-4EF5-B9AF-8F32E045BBF1}']
  end;

  PITiscriptOle = ^ITiscriptOle;
  ITiscriptOle = interface
  ['{6967A48E-AEFF-4991-82C1-176E394A1A5B}']
    function Implementator: Pointer;
    
    function DispatchInvoke(const Dispatch: IDispatch; const DispID: integer; const MethodName: SciterString;
      const AParams: array of OleVariant; AParamAsc: Boolean = False): OleVariant; overload;
    function DispatchInvoke(const Dispatch: IDispatch; const MethodName: SciterString;
      const AParams: array of OleVariant; AParamAsc: Boolean = False): OleVariant; overload;

    function  DispatchGetItem(const Dispatch: IDispatch; const Index: OleVariant): OleVariant;
    procedure DispatchSetItem(const Dispatch: IDispatch; const Index: OleVariant; const Value: OleVariant);

    function GetOleObjectGuid(const Obj: IDispatch): SciterString;
    function FindOrCreateOleObjectClass(vm: HVM; const Dispatch: IDispatch): tiscript_class;

    function  RegisterOleObject(vm: HVM; Dispatch: IDispatch; const Name: SciterString): tiscript_object;
    procedure UnRegisterObject(const vm: HVM; const VarName: SciterString);
    function  WrapOleObject(vm: HVM; Dispatch: IDispatch): tiscript_object;

    function CreateOleObjectList: ITiscriptObjectList;
  end;

  TTiscriptCreateNativeObjectProc = function (const vm: HVM; const AObjectName: SciterString;
    argCount: Integer; args: Ptiscript_value_array): IDispatch of object;

  ITiscriptPined = interface
  ['{08540024-B788-402E-8ECE-49DD379AF16F}']
    function GetOwned: Boolean;
    function GetValue: tiscript_value;
    function GetVM: HVM;
    procedure SetValue(const Value: tiscript_value);

    function  IsValid: Boolean;
    procedure Assign(const v: tiscript_value);
    procedure Attach(const c: HVM);
    procedure Detach();

    procedure Pin;
    procedure UnPin;

    function ToString: SciterString;
    function Stringify: SciterString;

    property Owned: Boolean read GetOwned;
    property VM: HVM read GetVM;
    property Value: tiscript_value read GetValue write SetValue;
  end;

  ITiscriptValue= interface(ITiscriptPined)
  ['{03E18D5F-A63C-4EE5-9F55-DF1492F689EB}']
    function GetA: ITiscriptArray;
    function GetB: Boolean;
    function GetBytes: TBytes;
    function GetD: Double;
    function GetDT: TDateTime;
    function GetF: ITiscriptFunction;
    function GetI: Integer;
    function GetNO: IDispatch;
    function GetO: ITiscriptObject;
    function GetS: SciterString;
    function GetE: HELEMENT;
    function GetSymbol: SciterString;
    procedure SetA(const Value: ITiscriptArray);
    procedure SetB(const Value: Boolean);
    procedure SetBytes(const Value: TBytes);
    procedure SetD(const Value: Double);
    procedure SetDT(const Value: TDateTime);
    procedure SetF(const Value: ITiscriptFunction);
    procedure SetI(const Value: Integer);
    procedure SetO(const Value: ITiscriptObject);
    procedure SetS(const Value: SciterString);
    procedure SetE(const Value: HELEMENT);
    procedure SetSymbol(const Value: SciterString);

    function IsInt: Boolean;
    function IsFloat: Boolean;
    function IsSymbol: Boolean;
    function IsString: Boolean;
    function IsArray: Boolean;
    function IsObject: Boolean;
    function IsNativeObject: Boolean;
    function IsFunction: Boolean;
    function IsNativeFunction: Boolean;
    function IsInstanceOf(const cls: tiscript_class): Boolean;
    function IsUndefined: Boolean;
    function IsNothing: Boolean;
    function IsNull: Boolean;
    function IsTrue: Boolean;
    function IsFalse: Boolean;
    function IsClass: Boolean;
    function IsError: Boolean;
    function IsBytes: Boolean;
    function IsDateTime: Boolean;
    function IsElement: Boolean;

    property I: Integer read GetI write SetI;
    property D: Double read GetD write SetD;
    property DT: TDateTime read GetDT write SetDT;
    property B: Boolean read GetB write SetB;
    property Symbol: SciterString read GetSymbol write SetSymbol;
    property S: SciterString read GetS write SetS;
    property Bytes: TBytes read GetBytes write SetBytes;
    property F: ITiscriptFunction read GetF write SetF;
    property O: ITiscriptObject read GetO write SetO;
    property NO: IDispatch read GetNO;
    property A: ITiscriptArray read GetA write SetA;
    property E: HELEMENT read GetE write SetE;
  end;

  ITiscriptFunction = interface(ITiscriptPined)
  ['{768E71F5-067D-491F-BE42-6186DB400E68}']
    function GetThis: ITiscriptObject;

    function IsNativeFunction: Boolean;

    function Call(const Args: Array of const): ITiscriptValue;
    function TryCall(const Args: array of const): Boolean; overload;
    function TryCall(const Args: array of const; out RetVal: ITiscriptValue): Boolean; overload;
    function TryCallEx(const Args: array of ITiscriptValue; out RetVal: ITiscriptValue): Boolean;

    function ToDispatch: IDispatch;

    property This: ITiscriptObject read GetThis;
  end;

  ITiscriptObject = interface(ITiscriptPined)
  ['{69C7F2DB-01F8-4117-B010-D63618BA2E31}']
    function GetLength: Cardinal;
    function GetItem(const AKey: SciterString): ITiscriptValue;
    function GetNativeInstance: IDispatch;
    procedure SetItem(const AKey: SciterString; const AValue: ITiscriptValue);

    function GetEnumerator: ITiscriptObjectEnumerator;
    function IsNativeObject: Boolean;

    function Call(const AFunc: SciterString; const Args: Array of const): ITiscriptValue;
    function TryCall(const AFunc: SciterString; const Args: array of const): Boolean; overload;
    function TryCall(const AFunc: SciterString; const Args: array of const; out RetVal: ITiscriptValue): Boolean; overload;
    function TryCallEx(const AFunc: SciterString; const Args: array of ITiscriptValue; out RetVal: ITiscriptValue): Boolean;

    property Length: Cardinal read GetLength;
    property Item[const AKey: SciterString]: ITiscriptValue read GetItem write SetItem; default;
    property NativeInstance: IDispatch read GetNativeInstance;
  end;

  ITiscriptArray = interface(ITiscriptPined)
  ['{F5469043-D2AC-44A5-A34D-077C23C2526B}']
    function GetLength: Cardinal;
    function GetItem(const AIndex: Integer): ITiscriptValue;
    procedure SetItem(const AIndex: Integer; const AValue: ITiscriptValue);
    procedure SetLength(const Value: Cardinal);

    function GetEnumerator: ITiscriptArrayEnumerator;

    function Push(const AValue: ITiscriptValue): Boolean; overload;
    function Push(const AValue: tiscript_value): Boolean; overload;
    function Push(const AValue: Integer): Boolean; overload;
    function Push(const AValue: Double): Boolean; overload;
    function Push(const AValue: Boolean): Boolean; overload;
    function Push(const AValue: SciterString): Boolean; overload;
    function Push(const AValue: TBytes): Boolean; overload;
    function Push(const AValue: ITiscriptFunction): Boolean; overload;
    function Push(const AValue: ITiscriptObject): Boolean; overload;
    function Push(const AValue: ITiscriptArray): Boolean; overload;
    function PushSymbol(const AValue: SciterString): Boolean;

    property Length: Cardinal read GetLength write SetLength;
    property Item[const AIndex: Integer]: ITiscriptValue read GetItem write SetItem; default;
  end;

  ITiscriptObjectPair = interface
  ['{89B9BAD0-8225-4ED7-A3FF-9248B127CBEE}']
    function GetPos: ITiscriptValue;
    function GetKey: ITiscriptValue;
    function GetValue: ITiscriptValue;
    function GetVM: HVM;

    property Pos: ITiscriptValue read GetPos;
    property Key: ITiscriptValue read GetKey;
    property Value: ITiscriptValue read GetValue;
    property vm: HVM read GetVM;
  end;

  ITiscriptObjectEnumerator = interface
  ['{D7F3DE18-B61F-4CDD-80F4-924B41DA3801}']
    function GetCurrent: ITiscriptObjectPair;
    function GetCollection: tiscript_object;
    function GetVM: HVM;

    function MoveNext: Boolean;

    property Current: ITiscriptObjectPair read GetCurrent;
    property Collection: tiscript_object read GetCollection;
    property vm: HVM read GetVM;
  end;

  ITiscriptArrayEnumerator = interface
  ['{7719AAB9-51D5-43E8-ADD2-475DCDED8D7F}']
    function GetCurrent: ITiscriptValue;
    function GetPos: Integer;

    function MoveNext: Boolean;
    property Current: ITiscriptValue read GetCurrent;
    property Pos: Integer read GetPos;
  end;

  PITiscript = ^ITiscript;
  ITiscript = interface
  ['{9EC818BD-7CF3-45B5-BC73-CACA7080F51E}']
    function  GetApi: Pointer;
    function  GetOnCreateNativeObject: TTiscriptCreateNativeObjectProc;
    function  GetCurrent: PITiscriptRuntime;
    function  GetOle: PITiscriptOle;
    function  GetClassBag: PITiscriptClassBag;
    function  GetGlobalObjects: PITiscriptObjectList;
    procedure SetOnCreateNativeObject(const Value: TTiscriptCreateNativeObjectProc);

    function CreateValue(vm: HVM; const aValue: tiscript_value): ITiscriptValue;
    function CreateObject(vm: HVM; const aObject: tiscript_value): ITiscriptObject;
    function CreateObjectByClass(const vm: HVM; const of_class: tiscript_value = 0): ITiscriptObject;
    function CreateObjectByPath(const vm: HVM; const class_path: SciterString): ITiscriptObject;
    function CreateArray(vm: HVM; const aArray: tiscript_value): ITiscriptArray; overload;
    function CreateArray(vm: HVM; num_elements: Cardinal): ITiscriptArray; overload;
    function CreateArray(num_elements: Cardinal): ITiscriptArray; overload;
    function CreateFunction(vm: HVM; aFunc: tiscript_value; aThis: tiscript_object = 0): ITiscriptFunction; overload;
    function CreateFunction(vm: HVM; aFunc: tiscript_native_method; aTag: Pointer = nil): ITiscriptFunction; overload;

    function CreateRuntime(const vm: HVM): ITiscriptRuntime; overload;
    function CreateRuntime(features: UINT = $ffffffff; heap_size: UINT= 1*1024*1024; stack_size: UINT = 64*1024): ITiscriptRuntime; overload;

    function ParseData(vm: HVM; const AJson: PJSONObject; ALen: Cardinal): tiscript_value; overload;
    function ParseData(vm: HVM; const AJson: JSONObject): tiscript_value; overload;
    function ParseData(const AJson: JSONObject): tiscript_value; overload;
    function Eval(vm: HVM; const AScript: PWideChar; ALen: Cardinal): tiscript_value; overload;
    function Eval(vm: HVM; const AScript: SciterString): tiscript_value; overload;
    function Eval(const AScript: SciterString): tiscript_value; overload;

    function IsNameExists(const vm: HVM; const Name: SciterString): tiscript_value;
    function IsClassExists(const vm: HVM; const Name: SciterString): tiscript_value;
    function FindObject(const vm: HVM; const Name: SciterString): tiscript_value;
    function FindClass(const vm: HVM; const ClassName: SciterString): tiscript_class;
    function RegisterFunction(const vm: HVM; const Name: SciterString; Handler: tiscript_native_method;
      Tag: Pointer = nil; ThrowIfExists: Boolean = False): tiscript_value;
    function RegisterClass(const vm: HVM; ClassDef: ptiscript_class_def; ThrowIfExists: Boolean): tiscript_class;
    function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: tiscript_class): tiscript_object; overload;
    function CreateObjectInstance(const vm: HVM; Obj: Pointer; OfClass: SciterString): tiscript_object; overload;
    
    procedure RegisterObject(const vm: HVM; Obj: tiscript_object; const VarName: SciterString); overload;
    procedure RegisterObject(const vm: HVM; Obj: Pointer; const OfClass: SciterString; const VarName: SciterString); overload;

    function  T2V(const vm: HVM; Value: tiscript_value): OleVariant;
    function  V2T(const vm: HVM; const Value: OleVariant): tiscript_value;

    function CreateStringStream(const str: SciterString): ITiscriptStringStream;
    function CreateFileStream(const filename: SciterString): ITiscriptFileStream;

    property Api: Pointer read GetApi;
    property Current: PITiscriptRuntime read GetCurrent;
    property Ole: PITiscriptOle read GetOle;
    property ClassBag: PITiscriptClassBag read GetClassBag;
    property GlobalObjects: PITiscriptObjectList read GetGlobalObjects;
    
    property OnCreateNativeObject: TTiscriptCreateNativeObjectProc read GetOnCreateNativeObject write SetOnCreateNativeObject;
  end;

function Tiscript: PITiscript;

function Ole: PITiscriptOle;
function ClassBag: PITiscriptClassBag;

implementation

uses
  SciterImportDefs;

function Tiscript: PITiscript;
type
  TTiscript = function : PITiscript;
begin
  Result :=  TTiscript(SciterApi.Funcs[FuncIdx_Tiscript]);
end;

function Ole: PITiscriptOle;
begin
  Result := Tiscript.Ole;
end;

function ClassBag: PITiscriptClassBag;
begin
  Result := Tiscript.ClassBag;
end;

end.
