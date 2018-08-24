{*******************************************************************************
 标题:     TiscriptClass.pas
 描述:     Tiscript脚本类定义
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptClass;

interface

uses
  SysUtils, Windows, SciterTypes, TiscriptApiImpl, TiscriptTypes, Variants,
  TiscriptIntf;

type
  // pinned value, a.k.a. gc root variable.
  // use pinned values when you need to store the value for long time
  TTiscriptPinned = class(TInterfacedObject, ITiscriptPined)
  private
    FOwned: Boolean;
    FValue: tiscript_pvalue;
    function GetOwned: Boolean;
    function GetValue: tiscript_value;
    function GetVM: HVM;
    procedure SetValue(const Value: tiscript_value);
  public
    constructor Create; overload;
    constructor Create(const c: HVM; Owned: Boolean = True); overload;
    constructor Create(const c: HVM; const v: tiscript_value; Owned: Boolean = True); overload;
    destructor Destroy; override;

    function ToString: SciterString; reintroduce;
    function Stringify: SciterString;

    function  IsValid: Boolean;
    procedure Assign(const v: tiscript_value); virtual;
    procedure Attach(const c: HVM);
    procedure Detach();

    procedure Pin;
    procedure UnPin;

    property Owned: Boolean read GetOwned;
    property VM: HVM read GetVM;
    property Value: tiscript_value read GetValue;
  end;

  TTiscriptBytes = class(TInterfacedObject, ITiscriptBytes)
  private
    FMemory: Pointer;
    FSize: Cardinal;
  private
    function GetMemory: Pointer;
    function GetSize: Cardinal;
  public
    constructor Create(const ASize: Cardinal); overload;
    constructor Create(const AMemory: Pointer; const ASize: Cardinal); overload;
    destructor Destroy; override;

    property Memory: Pointer read GetMemory;
    property Size: Cardinal read GetSize;
  end;

  TTiscriptValue = class(TTiscriptPinned, ITiscriptValue)
  private
    FThis: tiscript_value;
    FA: ITiscriptArray;
    FF: ITiscriptFunction;
    FO: ITiscriptObject;
  private
    function GetA: ITiscriptArray;
    function GetB: Boolean;
    function GetBytes: ITiscriptBytes;
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
    procedure SetBytes(const Value: ITiscriptBytes);
    procedure SetD(const Value: Double);
    procedure SetDT(const Value: TDateTime);
    procedure SetF(const Value: ITiscriptFunction);
    procedure SetI(const Value: Integer);
    procedure SetO(const Value: ITiscriptObject);
    procedure SetS(const Value: SciterString);
    procedure SetE(const Value: HELEMENT);
    procedure SetSymbol(const Value: SciterString);
  private
    procedure Invalidate;
  public
    constructor Create(const c: HVM; const v: tiscript_value; Owned: Boolean = True; this: tiscript_value = 0); overload;
    
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
    property Bytes: ITiscriptBytes read GetBytes write SetBytes;
    property F: ITiscriptFunction read GetF write SetF;
    property O: ITiscriptObject read GetO write SetO;
    property NO: IDispatch read GetNO;
    property A: ITiscriptArray read GetA write SetA;
    property E: HELEMENT read GetE write SetE;
  end;

  TTiscriptFunction = class(TTiscriptPinned, ITiscriptFunction)
  private
    FThis: ITiscriptObject;
  protected
    function GetThis: ITiscriptObject;

    function IsNativeFunction: Boolean;

    function Call(const Args: Array of const): ITiscriptValue;
    function TryCall(const Args: array of const): Boolean; overload;
    function TryCall(const Args: array of const; out RetVal: ITiscriptValue): Boolean; overload;
    function TryCallEx(const Args: array of ITiscriptValue; out RetVal: ITiscriptValue): Boolean;
  public
    constructor Create(vm: HVM; aFunc: tiscript_value; const aThis: tiscript_object);
    destructor Destroy; override;

    function ToDispatch: IDispatch;
    function ToValue: ITiscriptValue;

    property This: ITiscriptObject read GetThis;
  end;

  IDispatchFunction = interface
  ['{8E82BFC9-9DF0-46C6-BEE3-512767289170}']
    function GetValue: ITiscriptFunction;
    property Value: ITiscriptFunction read GetValue;
  end;

  TDispatchFunction = class(TInterfacedObject, IDispatch, IDispatchFunction)
  private
    FValue: ITiscriptFunction;
    function GetValue: ITiscriptFunction;
  protected
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
  public
    constructor Create(AFunc: ITiscriptFunction);

    property Value: ITiscriptFunction read GetValue;
  end;

  TTiscriptObject = class(TTiscriptPinned, ITiscriptObject)
  private
    function GetProp(const AKey: SciterString): tiscript_value;
    procedure SetProp(const AKey: SciterString; const AValue: tiscript_value);
  private
    function GetLength: Cardinal;
    function GetItem(const AKey: SciterString): ITiscriptValue;
    function GetNativeInstance: IDispatch;
    function GetA(const AKey: SciterString): ITiscriptArray;
    function GetB(const AKey: SciterString): Boolean;
    function GetBytes(const AKey: SciterString): ITiscriptBytes;
    function GetD(const AKey: SciterString): Double;
    function GetDT(const AKey: SciterString): TDateTime;
    function GetE(const AKey: SciterString): HELEMENT;
    function GetF(const AKey: SciterString): ITiscriptFunction;
    function GetI(const AKey: SciterString): Integer;
    function GetNO(const AKey: SciterString): IDispatch;
    function GetO(const AKey: SciterString): ITiscriptObject;
    function GetS(const AKey: SciterString): SciterString;
    function GetSymbol(const AKey: SciterString): SciterString;
    procedure SetA(const AKey: SciterString; const Value: ITiscriptArray);
    procedure SetB(const AKey: SciterString; const Value: Boolean);
    procedure SetBytes(const AKey: SciterString; const Value: ITiscriptBytes);
    procedure SetD(const AKey: SciterString; const Value: Double);
    procedure SetDT(const AKey: SciterString; const Value: TDateTime);
    procedure SetE(const AKey: SciterString; const Value: HELEMENT);
    procedure SetF(const AKey: SciterString; const Value: ITiscriptFunction);
    procedure SetI(const AKey: SciterString; const Value: Integer);
    procedure SetO(const AKey: SciterString; const Value: ITiscriptObject);
    procedure SetS(const AKey, Value: SciterString);
    procedure SetSymbol(const AKey, Value: SciterString);
    procedure SetItem(const AKey: SciterString; const AValue: ITiscriptValue);
  public
    constructor Create(vm: HVM; const aObject: tiscript_value);
    // create new object [of class]
    constructor CreateByClass(const c: HVM; const of_class: tiscript_value = 0);
    constructor CreateByPath(const c: HVM; const class_path: SciterString);

    destructor Destroy; override;

    procedure Assign(const v: tiscript_value); override;

    function GetEnumerator: ITiscriptObjectEnumerator;
    function IsNativeObject: Boolean;

    function Call(const AFunc: SciterString; const Args: Array of const): ITiscriptValue;
    function TryCall(const AFunc: SciterString; const Args: array of const): Boolean; overload;
    function TryCall(const AFunc: SciterString; const Args: array of const; out RetVal: ITiscriptValue): Boolean; overload;
    function TryCallEx(const AFunc: SciterString; const Args: array of ITiscriptValue; out RetVal: ITiscriptValue): Boolean;

    function ToValue: ITiscriptValue;
    
    property Length: Cardinal read GetLength;
    property Item[const AKey: SciterString]: ITiscriptValue read GetItem write SetItem; default;
    property I[const AKey: SciterString]: Integer read GetI write SetI;
    property D[const AKey: SciterString]: Double read GetD write SetD;
    property DT[const AKey: SciterString]: TDateTime read GetDT write SetDT;
    property B[const AKey: SciterString]: Boolean read GetB write SetB;
    property Symbol[const AKey: SciterString]: SciterString read GetSymbol write SetSymbol;
    property S[const AKey: SciterString]: SciterString read GetS write SetS;
    property Bytes[const AKey: SciterString]: ITiscriptBytes read GetBytes write SetBytes;
    property F[const AKey: SciterString]: ITiscriptFunction read GetF write SetF;
    property O[const AKey: SciterString]: ITiscriptObject read GetO write SetO;
    property NO[const AKey: SciterString]: IDispatch read GetNO;
    property A[const AKey: SciterString]: ITiscriptArray read GetA write SetA;
    property E[const AKey: SciterString]: HELEMENT read GetE write SetE;
    property NativeInstance: IDispatch read GetNativeInstance;
  end;

  TTiscriptArray = class(TTiscriptPinned, ITiscriptArray)
  private
    function GetA(const AIndex: Integer): ITiscriptArray;
    function GetB(const AIndex: Integer): Boolean;
    function GetBytes(const AIndex: Integer): ITiscriptBytes;
    function GetD(const AIndex: Integer): Double;
    function GetDT(const AIndex: Integer): TDateTime;
    function GetE(const AIndex: Integer): HELEMENT;
    function GetF(const AIndex: Integer): ITiscriptFunction;
    function GetI(const AIndex: Integer): Integer;
    function GetNO(const AIndex: Integer): IDispatch;
    function GetO(const AIndex: Integer): ITiscriptObject;
    function GetS(const AIndex: Integer): SciterString;
    function GetSymbol(const AIndex: Integer): SciterString;
    function GetItem(const AIndex: Integer): ITiscriptValue;
    function GetLength: Cardinal;
    procedure SetA(const AIndex: Integer; const Value: ITiscriptArray);
    procedure SetB(const AIndex: Integer; const Value: Boolean);
    procedure SetBytes(const AIndex: Integer; const Value: ITiscriptBytes);
    procedure SetD(const AIndex: Integer; const Value: Double);
    procedure SetDT(const AIndex: Integer; const Value: TDateTime);
    procedure SetE(const AIndex: Integer; const Value: HELEMENT);
    procedure SetF(const AIndex: Integer; const Value: ITiscriptFunction);
    procedure SetI(const AIndex, Value: Integer);
    procedure SetO(const AIndex: Integer; const Value: ITiscriptObject);
    procedure SetS(const AIndex: Integer; const Value: SciterString);
    procedure SetSymbol(const AIndex: Integer; const Value: SciterString);
    procedure SetItem(const AIndex: Integer; const AValue: ITiscriptValue);
    procedure SetLength(const Value: Cardinal);
  public
    constructor Create(num_elements: Cardinal); overload;
    constructor Create(vm: HVM; num_elements: Cardinal); overload;
    destructor Destroy; override;

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

    function ToValue: ITiscriptValue;

    property Length: Cardinal read GetLength write SetLength;
    property Item[const AIndex: Integer]: ITiscriptValue read GetItem write SetItem; default;
    property I[const AIndex: Integer]: Integer read GetI write SetI;
    property D[const AIndex: Integer]: Double read GetD write SetD;
    property DT[const AIndex: Integer]: TDateTime read GetDT write SetDT;
    property B[const AIndex: Integer]: Boolean read GetB write SetB;
    property Symbol[const AIndex: Integer]: SciterString read GetSymbol write SetSymbol;
    property S[const AIndex: Integer]: SciterString read GetS write SetS;
    property Bytes[const AIndex: Integer]: ITiscriptBytes read GetBytes write SetBytes;
    property F[const AIndex: Integer]: ITiscriptFunction read GetF write SetF;
    property O[const AIndex: Integer]: ITiscriptObject read GetO write SetO;
    property NO[const AIndex: Integer]: IDispatch read GetNO;
    property A[const AIndex: Integer]: ITiscriptArray read GetA write SetA;
    property E[const AIndex: Integer]: HELEMENT read GetE write SetE;
  end;

  TTiscriptObjectPair = class(TInterfacedObject, ITiscriptObjectPair)
  private
    FVm: HVM;
    FPos: ITiscriptValue;
    FKey: ITiscriptValue;
    FValue: ITiscriptValue;
  protected
    function GetPos: ITiscriptValue;
    function GetKey: ITiscriptValue;
    function GetValue: ITiscriptValue;
    function GetVM: HVM;
  public
    constructor Create(vm: HVM; APos, AKey, AValue: tiscript_value);

    property Pos: ITiscriptValue read GetPos;
    property Key: ITiscriptValue read GetKey;
    property Value: ITiscriptValue read GetValue;
    property vm: HVM read GetVM;
  end;
  
  TTiscriptObjectEnumerator = class(TInterfacedObject, ITiscriptObjectEnumerator)
  private
    FCollection: tiscript_value;
    FVm: HVM;
    FCurrent: ITiscriptObjectPair;
    FPos: tiscript_value;
    FKey: tiscript_value;
    FValue: tiscript_value;
  protected
    function GetCurrent: ITiscriptObjectPair;
    function GetCollection: tiscript_object;
    function GetVM: HVM;
  public
    constructor Create(const AVM: HVM; const ACollection: tiscript_object);

    function MoveNext: Boolean;

    property Current: ITiscriptObjectPair read GetCurrent;
    property Collection: tiscript_object read GetCollection;
    property vm: HVM read GetVM;
  end;

  TTiscriptArrayEnumerator = class(TInterfacedObject, ITiscriptArrayEnumerator)
  private
    FVM: HVM;
    FArray: tiscript_value;
    FPos: Integer;
    FCurrent: ITiscriptValue;
    function GetCurrent: ITiscriptValue;
    function GetPos: Integer;
  public
    constructor Create(const AVM: HVM; const AArray: tiscript_value);

    function MoveNext: Boolean;
    property Current: ITiscriptValue read GetCurrent;
    property Pos: Integer read GetPos;
  end;

implementation

uses
  SciterApiImpl, TiscriptOle, ActiveX;

{$IF CompilerVersion <= 18.5}
const
  vtUnicodeString = 17;
{$IFEND}

function FileTimeToDateTime(const AFileTime: TFileTime): TDateTime;
var
  st: TSystemTime;
begin
  Assert(FileTimeToSystemTime(AFileTime, st));
  Result := SystemTimeToDateTime(st);
end;

function DateTimeToFileTime(const ADateTime: TDateTime): TFileTime;
var
  st: TSystemTime;
begin
  DateTimeToSystemTime(ADateTime, st);
  Assert(SystemTimeToFileTime(st, Result));
end;

{ TTiscriptFunction }

constructor TTiscriptFunction.Create(vm: HVM; aFunc: tiscript_value; const aThis: tiscript_object);
begin
  inherited Create(vm, aFunc);
  FThis := TTiscriptObject.Create(vm, aThis);
end;

function TTiscriptFunction.TryCallEx(const Args: array of ITiscriptValue;
  out RetVal: ITiscriptValue): Boolean;
var
  pArgs: array of tiscript_value;
  cArgs: Integer;
  SR: tiscript_value;
  pargv: Ptiscript_value;
  i: Integer;
begin
  Result := False;
  try
    Assert(IsValid);
    cArgs := System.Length(Args);
    if cArgs > 0 then
    begin
      if cArgs > MaxParams then
        raise ESciterException.Create('Too many arguments.');
      SetLength(pArgs, cArgs);
      for i := Low(Args) to High(Args) do
      begin
        if Args[i] = nil then
          pArgs[i] := ni.undefined_value
        else
          pArgs[i] := Args[i].Value;
      end;
      pargv := @pArgs[0]
    end
    else
      pargv := nil;
    Result := ni.call(FValue.vm, FThis.Value, FValue.val, pargv, cArgs, SR);
    if Result then
      RetVal := TTiscriptValue.Create(FValue.vm, SR)
    else
      RetVal := TTiscriptValue.Create(FValue.vm, ni.undefined_value);
  except
    on E: Exception do
      TraceException('[TTiscriptFunction.TryCallEx]'+E.Message);
  end;
end;

function TTiscriptFunction.GetThis: ITiscriptObject;
begin
  Result := FThis;
end;

function TTiscriptFunction.IsNativeFunction: Boolean;
begin
  Result := ni.is_native_function(FValue.val);
end;

function TTiscriptFunction.Call(const Args: array of const): ITiscriptValue;
begin
  if not TryCall(Args, Result) then
    raise ESciterCallException.Create('TTiscriptFunction.Call');
end;

function TTiscriptFunction.TryCall(const Args: array of const): Boolean;
var
  pRetVal: ITiscriptValue;
begin
  Result := TryCall(Args, pRetVal);
end;

function TTiscriptFunction.TryCall(const Args: array of const; out RetVal: ITiscriptValue): Boolean;
var
  pArg: TVarRec;
  pArgs: array of ITiscriptValue;
  cArgs: Integer;
  i: Integer;
  tValue: tiscript_value;
  iTisValue: ITiscriptValue;
  iDisp: IDispatch;
  iObj: ITiscriptObject;
  iArray: ITiscriptArray;
  iFunc: ITiscriptFunction;
begin
  Result := False;
  try
    cArgs := Length(Args);
    if cArgs > 0 then
    begin
      if cArgs > MaxParams then
        raise ETiscriptException.Create('Too many arguments.');
      SetLength(pArgs, cArgs);
      for i := Low(Args) to High(Args) do
      begin
        pArg := Args[i];
        pArgs[i] := TTiscriptValue.Create(FValue.vm);
        case pArg.VType of
          vtInteger:    pArgs[i].I := pArg.VInteger;
          vtBoolean:    pArgs[i].B := pArg.VBoolean;
          vtChar:       pArgs[i].S := WideChar(pArg.VChar);
          vtExtended:   pArgs[i].D := pArg.VExtended^;
          vtString:     pArgs[i].S := string(pArg.VString^);
          vtPChar:      pArgs[i].S := string(AnsiString(pArg.VPChar));
          vtWideChar:   pArgs[i].S := pArg.VWideChar;
          vtPWideChar:  pArgs[i].S := pArg.VPWideChar;
          vtAnsiString: pArgs[i].S := string(AnsiString(pArg.VAnsiString));
          vtCurrency:   pArgs[i].D := pArg.VCurrency^;
          vtVariant:
          begin
            if V2T(FValue.vm, pArg.VVariant^, tValue) <> 0 then
              raise ETiscriptException.CreateFmt('Args[%d] is not support Variant type: %s', [i, VarTypeAsText(VarType(pArg.VVariant^))]);
          end;
          vtPointer:
          begin
            if pArg.VPointer = nil  then
              pArgs[i].Value := ni.undefined_value
            else
              raise ETiscriptException.CreateFmt('Args[%d] is not support Pointer type', [i]);
          end;
          vtInterface:
          begin
            if Supports(IInterface(pArg.VInterface), IDispatch, iDisp) then
              pArgs[i] := TTiscriptValue.Create(FValue.vm, _WrapOleObject(FValue.vm, iDisp))
            else
            if Supports(IInterface(pArg.VInterface), ITiscriptValue, iTisValue) then
              pArgs[i] := iTisValue
            else
            if Supports(IInterface(pArg.VInterface), ITiscriptObject, iObj) then
              pArgs[i] := TTiscriptValue.Create(FValue.vm, iObj.Value)
            else
            if Supports(IInterface(pArg.VInterface), ITiscriptArray, iArray) then
              pArgs[i] := TTiscriptValue.Create(FValue.vm, iArray.Value)
            else
            if Supports(IInterface(pArg.VInterface), ITiscriptFunction, iFunc) then
              pArgs[i] := TTiscriptValue.Create(FValue.vm, iFunc.Value)
            else
              raise ETiscriptException.CreateFmt('Args[%d] not support interface', [i]);
          end;
          vtWideString:    pArgs[i].S := WideString(pArg.VWideString);
          vtInt64:         pArgs[i].I := pArg.VInt64^;
          {$IF CompilerVersion > 18.5}
            vtUnicodeString: pArgs[i].S := UnicodeString(pArg.VUnicodeString);
          {$ELSE}
            vtUnicodeString: pArgs[i].S := PWideChar(pArg.VWideString);
          {$IFEND}
        else
          raise ETiscriptException.CreateFmt('Args[%d] is not support type: %d', [i, pArg.VType]);
        end;
      end;
    end;
    Result := TryCallEx(pArgs, RetVal);
  except
    on E: Exception do
      TraceException('[TTiscriptFunction.TryCall]'+E.Message);
  end;
end;

destructor TTiscriptFunction.Destroy;
begin
  inherited;
end;

function TTiscriptFunction.ToDispatch: IDispatch;
begin
  Result := TDispatchFunction.Create(Self);
end;

function TTiscriptFunction.ToValue: ITiscriptValue;
begin
  Result := TTiscriptValue.Create(VM, FValue.val)
end;

{ TTiscriptObject }

function TTiscriptObject.Call(const AFunc: SciterString;
  const Args: array of const): ITiscriptValue;
begin
  if not TryCall(AFunc, Args, Result) then
    raise ESciterCallException.Create('TTiscriptObject.Call');
end;

constructor TTiscriptObject.Create(vm: HVM; const aObject: tiscript_value);
begin
  inherited Create(vm, aObject);
end;

constructor TTiscriptObject.CreateByClass(const c: HVM; const of_class: tiscript_value);
begin
  inherited Create(c, ni.create_object(FValue.vm, of_class));
end;

constructor TTiscriptObject.CreateByPath(const c: HVM; const class_path: SciterString);
var
  cls: tiscript_value;
begin
  Assert(ni.get_value_by_path(FValue.vm, cls, PAnsiChar(AnsiString(class_path))));
  Assert(ni.is_class(vm,cls));
  inherited Create(c, ni.create_object(vm, cls));
end;

destructor TTiscriptObject.Destroy;
begin

  inherited;
end;

function TTiscriptObject.GetItem(const AKey: SciterString): ITiscriptValue;
var
  sPropName: UTF8String;
begin
  Assert(IsValid);
  sPropName := UTF8Encode(AKey);
  Result := TTiscriptValue.Create(FValue.vm,
    ni.get_prop(FValue.vm, FValue.val, ni.symbol_value(PAnsiChar(sPropName))));
end;

function TTiscriptObject.GetLength: Cardinal;
begin
  Assert(IsValid);
  Result := ni.get_length(FValue.vm, FValue.val);
end;

function TTiscriptObject.IsNativeObject: Boolean;
begin
  Result := ni.is_native_object(FValue.val);
end;

function TTiscriptObject.GetNativeInstance: IDispatch;
begin
  Assert(ni.is_native_object(FValue.val));
  Result := IDispatch(ni.get_instance_data(FValue.val));
end;

function TTiscriptObject.GetEnumerator: ITiscriptObjectEnumerator;
begin
  Result := TTiscriptObjectEnumerator.Create(FValue.vm, FValue.val);
end;

procedure TTiscriptObject.SetItem(const AKey: SciterString;
  const AValue: ITiscriptValue);
var
  sPropName: UTF8String;
begin
  Assert(IsValid);
  sPropName := UTF8Encode(AKey);
  if AValue = nil then
    ni.set_prop(FValue.vm, FValue.val, ni.symbol_value(PAnsiChar(sPropName)), ni.undefined_value)
  else
    ni.set_prop(FValue.vm, FValue.val, ni.symbol_value(PAnsiChar(sPropName)), AValue.Value);
end;

function TTiscriptObject.TryCall(const AFunc: SciterString;
  const Args: array of const; out RetVal: ITiscriptValue): Boolean;
var
  func: ITiscriptValue;
begin
  Result := False;
  try
    Assert(IsValid);
    func := GetItem(AFunc);
    if (func = nil) or (not func.IsFunction) and (not func.IsNativeFunction) then
      Exit;
    Result := func.F.TryCall(Args, RetVal);
  except
    on E: Exception do
      TraceException('[TTiscriptObject.TryCall]'+E.Message);
  end;
end;

function TTiscriptObject.TryCallEx(const AFunc: SciterString;
  const Args: array of ITiscriptValue; out RetVal: ITiscriptValue): Boolean;
var
  func: ITiscriptValue;
begin
  Result := False;
  try
    Assert(IsValid);
    func := GetItem(AFunc);
    if (func = nil) or (not func.IsFunction) and (not func.IsNativeFunction) then
      Exit;
    Result := func.F.TryCallEx(Args, RetVal);
  except
    on E: Exception do
      TraceException('[TTiscriptObject.TryCall]'+E.Message);
  end;
end;

function TTiscriptObject.TryCall(const AFunc: SciterString;
  const Args: array of const): Boolean;
var
  RetVal: ITiscriptValue;
begin
  Result := TryCall(AFunc, Args, RetVal);
end;

procedure TTiscriptObject.Assign(const v: tiscript_value);
begin
  inherited;
  Assert( ni.is_object(v) or ni.is_native_object(v) );
end;

function TTiscriptObject.ToValue: ITiscriptValue;
begin
  Result := TTiscriptValue.Create(VM, FValue.val)
end;

function TTiscriptObject.GetA(const AKey: SciterString): ITiscriptArray;
begin                                         
  Result := TTiscriptArray.Create(FValue.vm, GetProp(AKey));
end;

function TTiscriptObject.GetB(const AKey: SciterString): Boolean;
begin
  ni.get_bool_value(GetProp(AKey), Result)
end;

function TTiscriptObject.GetBytes(const AKey: SciterString): ITiscriptBytes;
var
  data: PAnsiChar;
  datalen: LongWord;
begin
  ni.get_bytes(GetProp(AKey), data, datalen);
  if datalen > 0 then
    Result := TTiscriptBytes.Create(data, datalen)
  else
    Result := nil;
end;

function TTiscriptObject.GetD(const AKey: SciterString): Double;
begin
  ni.get_float_value(GetProp(AKey), Result)
end;

function TTiscriptObject.GetDT(const AKey: SciterString): TDateTime;
var
  i64: Int64;
begin
  Assert(ni.get_datetime(FValue.vm, GetProp(AKey), i64));
  Result := FileTimeToDateTime(TFileTime(i64));
end;

function TTiscriptObject.GetE(const AKey: SciterString): HELEMENT;
begin
  Result := HELEMENT(ni.get_instance_data(GetProp(AKey)));
end;

function TTiscriptObject.GetF(const AKey: SciterString): ITiscriptFunction;
begin
  Result := TTiscriptFunction.Create(FValue.vm, GetProp(AKey), ni.get_current_ns(FValue.vm));
end;

function TTiscriptObject.GetI(const AKey: SciterString): Integer;
begin
  ni.get_int_value(GetProp(AKey), Result);
end;

function TTiscriptObject.GetNO(const AKey: SciterString): IDispatch;
begin
  Result := IDispatch(NI.get_instance_data(GetProp(AKey)));
end;

function TTiscriptObject.GetO(const AKey: SciterString): ITiscriptObject;
begin
  Result := TTiscriptObject.Create(FValue.vm, GetProp(AKey));
end;

function TTiscriptObject.GetS(const AKey: SciterString): SciterString;
var
  len: LongWord;
  dv: PWideChar;
  v1, v: tiscript_value;
begin
  v1 := GetProp(AKey);
  if ni.is_string(v1) then
    v := v1
  else
    v := ni.to_string(fValue.vm, v1);
  ni.get_string_value(v, dv, len);
  if len > 0 then
    Result := dv;
end;

function TTiscriptObject.GetSymbol(const AKey: SciterString): SciterString;
var
  dv: PWideChar;
begin
  ni.get_symbol_value(GetProp(AKey), dv);
  Result := dv;
end;

procedure TTiscriptObject.SetA(const AKey: SciterString; const Value: ITiscriptArray);
begin
  if Value = nil then
    SetProp(AKey, ni.undefined_value)
  else
    SetProp(AKey, Value.Value)
end;

procedure TTiscriptObject.SetB(const AKey: SciterString; const Value: Boolean);
begin
  SetProp(AKey, ni.bool_value(Value));
end;

procedure TTiscriptObject.SetBytes(const AKey: SciterString; const Value: ITiscriptBytes);
begin
  if (Value = nil) or (Value.Size <= 0) then
    SetProp(AKey, ni.bytes_value(FValue.vm, nil, 0))
  else
    SetProp(AKey, ni.bytes_value(FValue.vm, Value.Memory, Value.Size))
end;

procedure TTiscriptObject.SetD(const AKey: SciterString; const Value: Double);
begin
  SetProp(AKey, ni.float_value(Value))
end;

procedure TTiscriptObject.SetDT(const AKey: SciterString; const Value: TDateTime);
begin
  SetProp(AKey, ni.datetime_value(vm, Int64(DateTimeToFileTime(Value))))
end;

procedure TTiscriptObject.SetF(const AKey: SciterString; const Value: ITiscriptFunction);
begin
  if Value = nil then
    SetProp(AKey, ni.undefined_value)
  else
    SetProp(AKey, Value.Value)
end;

procedure TTiscriptObject.SetI(const AKey: SciterString; const Value: Integer);
begin
  SetProp(AKey, ni.int_value(Value));
end;

procedure TTiscriptObject.SetO(const AKey: SciterString; const Value: ITiscriptObject);
begin
  if Value = nil then
    SetProp(AKey, ni.undefined_value)
  else
    SetProp(AKey, Value.Value)
end;

procedure TTiscriptObject.SetS(const AKey, Value: SciterString);
begin
  SetProp(AKey, ni.string_value(FValue.vm, PWideChar(Value), System.Length(Value)));
end;

procedure TTiscriptObject.SetSymbol(const AKey, Value: SciterString);
begin
  SetProp(AKey, ni.symbol_value(PAnsiChar(UTF8Encode(Value))));
end;

function TTiscriptObject.GetProp(const AKey: SciterString): tiscript_value;
begin
  Result := ni.get_prop(FValue.vm, FValue.val, ni.string_value(FValue.vm, PWideChar(AKey), System.Length(AKey)))
end;

procedure TTiscriptObject.SetProp(const AKey: SciterString; const AValue: tiscript_value);
begin
  ni.set_prop(FValue.vm, FValue.val, ni.string_value(FValue.vm, PWideChar(AKey), System.Length(AKey)), AValue);
end;

procedure TTiscriptObject.SetE(const AKey: SciterString; const Value: HELEMENT);
var
  v: tiscript_value;
begin
  v := GetProp(AKey);
  if ni.is_object(v) then
    ni.set_instance_data(v, Value);
end;

{ TTiscriptPinned }

procedure TTiscriptPinned.Assign(const v: tiscript_value);
begin
  FValue.val := v;
  Assert(vm<>nil);
end;

procedure TTiscriptPinned.Attach(const c: HVM);
begin
  Detach();
  ni().pin(c, @FValue);
end;

constructor TTiscriptPinned.Create;
begin
  FValue.val := 0;
  FValue.vm  := nil;
  FValue.d1  := nil;
  FValue.d2  := nil;
end;

constructor TTiscriptPinned.Create(const c: HVM; Owned: Boolean);
begin
  FOwned := Owned;
  FValue.val := 0;
  FValue.d1  := nil;
  FValue.d2  := nil;
  if FOwned then
    ni.pin(c, @FValue)
  else
    FValue.vm  := c;
end;

constructor TTiscriptPinned.Create(const c: HVM; const v: tiscript_value; Owned: Boolean = True);
begin
  FOwned := Owned;
  FValue.d1  := nil;
  FValue.d2  := nil;
  if FOwned then
    ni.pin(c, @FValue)
  else
    FValue.vm  := c;
  FValue.val := v;
end;

destructor TTiscriptPinned.Destroy;
begin
  Detach();
  inherited;
end;

procedure TTiscriptPinned.Detach();
begin
  if FOwned and (FValue.vm <> nil) then
    ni.unpin(@FValue);
end;

function TTiscriptPinned.IsValid: Boolean;
begin
  Result := FValue.val <> 0;
end;

procedure TTiscriptPinned.SetValue(const Value: tiscript_value);
begin
  FValue.val := Value;
end;

function TTiscriptPinned.Stringify: SciterString;
begin
  Result := TiscriptApiImpl.GetNativeObjectJson(FValue.vm, FValue.val);
end;

function TTiscriptPinned.ToString: SciterString;
var
  len: LongWord;
  dv: PWideChar;
  v: tiscript_value;
begin
  if ni.is_string(fValue.val) then
    v := fValue.val
  else
    v := ni.to_string(fValue.vm, fValue.val);
  ni.get_string_value(v, dv, len);
  if len > 0 then
    Result := dv;
end;

function TTiscriptPinned.GetValue: tiscript_value;
begin
  Result := FValue.val;
end;

function TTiscriptPinned.GetVM: HVM;
begin
  Result := FValue.vm;
end;

procedure TTiscriptPinned.Pin;
begin
  ni.pin(vm, @FValue);  
end;

procedure TTiscriptPinned.UnPin;
begin
  ni.unpin(@FValue);
end;

function TTiscriptPinned.GetOwned: Boolean;
begin
  Result := FOwned;
end;

{ TTiscriptValue }

function TTiscriptValue.GetA: ITiscriptArray;
begin
  if FA = nil then
    FA := TTiscriptArray.Create(FValue.vm, FValue.val);
  Result := FA;
end;

function TTiscriptValue.GetB: Boolean;
begin
  ni.get_bool_value(FValue.val, Result);
end;

function TTiscriptValue.GetBytes: ITiscriptBytes;
var
  data: PAnsiChar;
  datalen: LongWord;
begin
  ni.get_bytes(FValue.val, data, datalen);
  if datalen > 0 then
    Result := TTiscriptBytes.Create(data, datalen)
  else
    Result := nil;
end;

function TTiscriptValue.GetD: Double;
begin
  ni.get_float_value(FValue.val, Result);
end;

function TTiscriptValue.GetDT: TDateTime;
var
  i64: Int64;
begin
  Assert(ni.get_datetime(FValue.vm, FValue.val, i64));
  Result := FileTimeToDateTime(TFileTime(i64));
end;

function TTiscriptValue.GetF: ITiscriptFunction;
var
  dThis: tiscript_value;
begin
  if FF = nil then
  begin
    if FThis <> 0 then dThis := FThis
    else dThis := ni.get_current_ns(FValue.vm);
    FF := TTiscriptFunction.Create(FValue.vm, FValue.val, dThis);
  end;
  Result := FF;
end;

function TTiscriptValue.GetI: Integer;
begin
  ni.get_int_value(FValue.val, Result);
end;

function TTiscriptValue.GetNO: IDispatch;
begin
  Result := IDispatch(NI.get_instance_data(FValue.val));
end;

function TTiscriptValue.GetO: ITiscriptObject;
begin
  if FO = nil then
    FO := TTiscriptObject.Create(FValue.vm, FValue.val);
  Result := FO;
end;

function TTiscriptValue.GetS: SciterString;
begin
  Result := Self.ToString;
end;

function TTiscriptValue.GetSymbol: SciterString;
var
  dv: PWideChar;
begin
  ni.get_symbol_value(fValue.val, dv);
  Result := dv;
end;

procedure TTiscriptValue.SetA(const Value: ITiscriptArray);
begin
  if Value = nil then
    FValue.val := ni.undefined_value
  else
    FValue.val := Value.Value;
  Invalidate
end;

procedure TTiscriptValue.SetB(const Value: Boolean);
begin
  FValue.val := ni.bool_value(Value);
  Invalidate
end;

procedure TTiscriptValue.SetBytes(const Value: ITiscriptBytes);
begin
  if (Value = nil) or (Value.Size <= 0) then
    FValue.val := ni.bytes_value(FValue.vm, nil, 0)
  else
    FValue.val := ni.bytes_value(FValue.vm, Value.Memory, Value.Size);
  Invalidate
end;

procedure TTiscriptValue.SetD(const Value: Double);
begin
  FValue.val := ni.float_value(Value);
  Invalidate
end;

procedure TTiscriptValue.SetDT(const Value: TDateTime);
begin
  FValue.val := ni.datetime_value(vm, Int64(DateTimeToFileTime(Value)));
  Invalidate
end;

procedure TTiscriptValue.SetF(const Value: ITiscriptFunction);
begin
  if Value = nil then
    FValue.val := ni.undefined_value
  else
    FValue.val := Value.Value;
  Invalidate
end;

procedure TTiscriptValue.SetI(const Value: Integer);
begin
  FValue.val := ni.int_value(Value);
  Invalidate
end;

procedure TTiscriptValue.SetO(const Value: ITiscriptObject);
begin
  if Value = nil then
    FValue.val := ni.undefined_value
  else
    FValue.val := Value.Value;
  Invalidate
end;

procedure TTiscriptValue.SetS(const Value: SciterString);
begin
  FValue.val := ni.string_value(FValue.vm, PWideChar(Value), Length(Value));
  Invalidate
end;

procedure TTiscriptValue.SetSymbol(const Value: SciterString);
begin
  FValue.val := ni.symbol_value(PAnsiChar(UTF8Encode(Value)));
  Invalidate;
end;

function TTiscriptValue.IsArray: Boolean;
begin
  Result := ni.is_array(FValue.val);
end;

function TTiscriptValue.IsBytes: Boolean;
begin
  Result := ni.is_bytes(FValue.val);
end;

function TTiscriptValue.IsClass: Boolean;
begin
  Result := ni.is_class(FValue.vm, FValue.val);
end;

function TTiscriptValue.IsDateTime: Boolean;
begin
  Result := ni.is_datetime(FValue.vm, FValue.val);
end;

function TTiscriptValue.IsError: Boolean;
begin
  Result := ni.is_error(FValue.val);
end;

function TTiscriptValue.IsFalse: Boolean;
begin
  Result := ni.is_nothing(FValue.val) or ni.is_undefined(FValue.val) or ni.is_null(FValue.val) or ni.is_false(FValue.val);
end;

function TTiscriptValue.IsFloat: Boolean;
begin
  Result := ni.is_float(FValue.val);
end;

function TTiscriptValue.IsFunction: Boolean;
begin
  Result := ni.is_function(FValue.val);
end;

function TTiscriptValue.IsInstanceOf(const cls: tiscript_class): Boolean;
begin
  Result := ni.is_instance_of(FValue.val, cls);
end;

function TTiscriptValue.IsInt: Boolean;
begin
  Result := ni.is_int(FValue.val);
end;

function TTiscriptValue.IsNativeFunction: Boolean;
begin
  Result := ni.is_native_function(FValue.val);
end;

function TTiscriptValue.IsNativeObject: Boolean;
begin
  Result := ni.is_native_object(FValue.val);
end;

function TTiscriptValue.IsNothing: Boolean;
begin
  Result := ni.is_nothing(FValue.val);
end;

function TTiscriptValue.IsNull: Boolean;
begin
  Result := ni.is_null(FValue.val);
end;

function TTiscriptValue.IsObject: Boolean;
begin
  Result := ni.is_object(FValue.val);
end;

function TTiscriptValue.IsString: Boolean;
begin
  Result := ni.is_string(FValue.val);
end;

function TTiscriptValue.IsSymbol: Boolean;
begin
  Result := ni.is_symbol(FValue.val);
end;

function TTiscriptValue.IsTrue: Boolean;
begin
  Result := ni.is_true(FValue.val);
end;

function TTiscriptValue.IsUndefined: Boolean;
begin
  Result := ni.is_undefined(FValue.val);
end;

function TTiscriptValue.IsElement: Boolean;
begin
  Result := NI.is_instance_of(FValue.val, ElementClass(FValue.vm));
end;

function TTiscriptValue.GetE: HELEMENT;
begin
  Result := HELEMENT(ni.get_instance_data(FValue.val));
end;

procedure TTiscriptValue.SetE(const Value: HELEMENT);
begin
  ni.set_instance_data(FValue.val, Value);
  Invalidate
end;

procedure TTiscriptValue.Invalidate;
begin
  FA := nil;
  FF := nil;
  FO := nil;
end;

constructor TTiscriptValue.Create(const c: HVM; const v: tiscript_value; Owned: Boolean; this: tiscript_value);
begin
  inherited Create(c, v, Owned);
  FThis := this;
end;

{ TTiscriptArray }

constructor TTiscriptArray.Create(vm: HVM; num_elements: Cardinal);
begin
  inherited Create(vm, ni.create_array(vm, num_elements));
end;

constructor TTiscriptArray.Create(num_elements: Cardinal);
begin
  Create(ni.get_current_vm, num_elements);
end;

destructor TTiscriptArray.Destroy;
begin

  inherited;
end;

function TTiscriptArray.GetEnumerator: ITiscriptArrayEnumerator;
begin
  Result := TTiscriptArrayEnumerator.Create(FValue.vm, FValue.val);
end;

function TTiscriptArray.GetItem(const AIndex: Integer): ITiscriptValue;
begin
  Result := TTiscriptValue.Create(FValue.vm, ni.get_elem(FValue.vm, FValue.val, AIndex));
end;

function TTiscriptArray.GetLength: Cardinal;
begin
  if (FValue.val <> 0) and (FValue.vm  <> nil) then
    Result := ni.get_length(FValue.vm, FValue.val)
  else
    Result := 0;
end;

function TTiscriptArray.Push(const AValue: SciterString): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, ni.string_value(FValue.vm, PWideChar(AValue), System.Length(AValue)));
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: TBytes): Boolean;
var
  pin: ITiscriptValue;
begin
  if System.Length(AValue) > 0 then
    pin := TTiscriptValue.Create(FValue.vm, ni.bytes_value(FValue.vm, @AValue[0], System.Length(AValue)))
  else
    pin := TTiscriptValue.Create(FValue.vm, ni.bytes_value(FValue.vm, nil, 0));
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: Boolean): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, ni.bool_value(AValue));
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: Integer): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, ni.int_value(AValue));
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: Double): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, ni.float_value(AValue));
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: ITiscriptArray): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, AValue.Value);
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: ITiscriptValue): Boolean;
var
  l: Cardinal;
  v: tiscript_value;
begin
  if AValue = nil then
    v := ni.undefined_value
  else
  begin
    Assert(AValue.IsValid);
    v := AValue.Value;
  end;
  l := GetLength;
  FValue.val := ni.set_array_size(FValue.vm, FValue.val, l + 1);
  Result := ni.set_elem(FValue.vm, FValue.val, l, v);
end;

function TTiscriptArray.Push(const AValue: ITiscriptFunction): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, AValue.Value);
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: ITiscriptObject): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, AValue.Value);
  Result := Push(pin);
end;

function TTiscriptArray.Push(const AValue: tiscript_value): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, AValue);
  Result := Push(pin);
end;

procedure TTiscriptArray.SetItem(const AIndex: Integer; const AValue: ITiscriptValue);
begin
  if AValue <> nil then
    ni.set_elem(FValue.vm, FValue.val, AIndex, AValue.Value)
  else
    ni.set_elem(FValue.vm, FValue.val, AIndex, ni.null_value);
end;
        
procedure TTiscriptArray.SetLength(const Value: Cardinal);
begin
  ni.set_array_size(FValue.vm, FValue.val, Value)
end;

function TTiscriptArray.PushSymbol(const AValue: SciterString): Boolean;
var
  pin: ITiscriptValue;
begin
  pin := TTiscriptValue.Create(FValue.vm, ni.symbol_value(PAnsiChar(UTF8Encode(AValue))));
  Result := Push(pin);
end;

function TTiscriptArray.ToValue: ITiscriptValue;
begin
  Result := TTiscriptValue.Create(VM, FValue.val)
end;

function TTiscriptArray.GetA(const AIndex: Integer): ITiscriptArray;
begin
  Result := TTiscriptArray.Create(FValue.vm, ni.get_elem(FValue.vm, FValue.val, AIndex));
end;

function TTiscriptArray.GetB(const AIndex: Integer): Boolean;
begin
  ni.get_bool_value(ni.get_elem(FValue.vm, FValue.val, AIndex), Result)
end;

function TTiscriptArray.GetBytes(const AIndex: Integer): ITiscriptBytes;
var
  data: PAnsiChar;
  datalen: LongWord;
begin
  ni.get_bytes(ni.get_elem(FValue.vm, FValue.val, AIndex), data, datalen);
  if datalen > 0 then
    Result := TTiscriptBytes.Create(data, datalen)
  else
    Result := nil;
end;

function TTiscriptArray.GetD(const AIndex: Integer): Double;
begin
  ni.get_float_value(ni.get_elem(FValue.vm, FValue.val, AIndex), Result)
end;

function TTiscriptArray.GetDT(const AIndex: Integer): TDateTime;
var
  i64: Int64;
begin
  Assert(ni.get_datetime(FValue.vm, ni.get_elem(FValue.vm, FValue.val, AIndex), i64));
  Result := FileTimeToDateTime(TFileTime(i64));
end;

function TTiscriptArray.GetE(const AIndex: Integer): HELEMENT;
begin
  Result := HELEMENT(ni.get_instance_data(ni.get_elem(FValue.vm, FValue.val, AIndex)));
end;

function TTiscriptArray.GetF(const AIndex: Integer): ITiscriptFunction;
begin
  Result := TTiscriptFunction.Create(FValue.vm, ni.get_elem(FValue.vm, FValue.val, AIndex), ni.get_current_ns(FValue.vm));
end;

function TTiscriptArray.GetI(const AIndex: Integer): Integer;
begin
  ni.get_int_value(ni.get_elem(FValue.vm, FValue.val, AIndex), Result);
end;

function TTiscriptArray.GetNO(const AIndex: Integer): IDispatch;
begin
  Result := IDispatch(NI.get_instance_data(ni.get_elem(FValue.vm, FValue.val, AIndex)));
end;

function TTiscriptArray.GetO(const AIndex: Integer): ITiscriptObject;
begin
  Result := TTiscriptObject.Create(FValue.vm, ni.get_elem(FValue.vm, FValue.val, AIndex));
end;

function TTiscriptArray.GetS(const AIndex: Integer): SciterString;
var
  len: LongWord;
  dv: PWideChar;
  v1, v: tiscript_value;
begin
  v1 := ni.get_elem(FValue.vm, FValue.val, AIndex);
  if ni.is_string(v1) then
    v := v1
  else
    v := ni.to_string(fValue.vm, v1);
  ni.get_string_value(v, dv, len);
  if len > 0 then
    Result := dv;
end;

function TTiscriptArray.GetSymbol(const AIndex: Integer): SciterString;
var
  dv: PWideChar;
begin
  ni.get_symbol_value(ni.get_elem(FValue.vm, FValue.val, AIndex), dv);
  Result := dv;
end;

procedure TTiscriptArray.SetA(const AIndex: Integer; const Value: ITiscriptArray);
begin
  if Value = nil then
    ni.set_elem(FValue.vm, FValue.val, AIndex, ni.undefined_value)
  else
    ni.set_elem(FValue.vm, FValue.val, AIndex, Value.Value)
end;

procedure TTiscriptArray.SetB(const AIndex: Integer; const Value: Boolean);
begin
  ni.set_elem(FValue.vm, FValue.val, AIndex, ni.bool_value(Value))
end;

procedure TTiscriptArray.SetBytes(const AIndex: Integer; const Value: ITiscriptBytes);
begin
  if (Value = nil) or (Value.Size <= 0) then
    ni.set_elem(FValue.vm, FValue.val, AIndex, ni.bytes_value(FValue.vm, nil, 0))
  else
    ni.set_elem(FValue.vm, FValue.val, AIndex, ni.bytes_value(FValue.vm, Value.Memory, Value.Size))
end;

procedure TTiscriptArray.SetD(const AIndex: Integer; const Value: Double);
begin
  ni.set_elem(FValue.vm, FValue.val, AIndex, ni.float_value(Value))
end;

procedure TTiscriptArray.SetDT(const AIndex: Integer; const Value: TDateTime);
begin
  ni.set_elem(FValue.vm, FValue.val, AIndex, ni.datetime_value(vm, Int64(DateTimeToFileTime(Value))))
end;

procedure TTiscriptArray.SetF(const AIndex: Integer; const Value: ITiscriptFunction);
begin
  if Value = nil then
    ni.set_elem(FValue.vm, FValue.val, AIndex, ni.undefined_value)
  else
    ni.set_elem(FValue.vm, FValue.val, AIndex, Value.Value)
end;

procedure TTiscriptArray.SetI(const AIndex, Value: Integer);
begin
  ni.set_elem(FValue.vm, FValue.val, AIndex, ni.int_value(Value));
end;

procedure TTiscriptArray.SetO(const AIndex: Integer; const Value: ITiscriptObject);
begin
  if Value = nil then
    ni.set_elem(FValue.vm, FValue.val, AIndex, ni.undefined_value)
  else
    ni.set_elem(FValue.vm, FValue.val, AIndex, Value.Value)
end;

procedure TTiscriptArray.SetS(const AIndex: Integer; const Value: SciterString);
begin
  ni.set_elem(FValue.vm, FValue.val, AIndex, ni.string_value(FValue.vm, PWideChar(Value), System.Length(Value)));
end;

procedure TTiscriptArray.SetSymbol(const AIndex: Integer; const Value: SciterString);
begin
  ni.set_elem(FValue.vm, FValue.val, AIndex, ni.symbol_value(PAnsiChar(UTF8Encode(Value))));
end;

procedure TTiscriptArray.SetE(const AIndex: Integer; const Value: HELEMENT);
var
  v: tiscript_value;
begin
  v := ni.get_elem(FValue.vm, FValue.val, AIndex);
  if ni.is_object(v) then
    ni.set_instance_data(v, Value);
end;

{ TTiscriptObjectEnumerator }

constructor TTiscriptObjectEnumerator.Create(const AVM: HVM;
  const ACollection: tiscript_object);
begin
  FCollection := ACollection;
  FVM := AVM;
  FPos := 0;
end;

function TTiscriptObjectEnumerator.GetCollection: tiscript_object;
begin
  Result := FCollection;
end;

function TTiscriptObjectEnumerator.GetCurrent: ITiscriptObjectPair;
begin
  Result := FCurrent;
end;

function TTiscriptObjectEnumerator.GetVM: HVM;
begin
  Result := FVm;
end;

function TTiscriptObjectEnumerator.MoveNext: Boolean;
begin
  Result := ni.get_next_key_value(FVM, FCollection, FPos, FKey, FValue);
  if Result then
    FCurrent := TTiscriptObjectPair.Create(FVm, FPos, FKey, FValue)
  else
    FCurrent := nil;
end;

{ TTiscriptArrayEnumerator }

constructor TTiscriptArrayEnumerator.Create(const AVM: HVM;
  const AArray: tiscript_value);
begin
  FVM := AVM;
  FArray := AArray;
  FPos := -1;
end;

function TTiscriptArrayEnumerator.GetCurrent: ITiscriptValue;
begin
  Result := FCurrent;
end;

function TTiscriptArrayEnumerator.GetPos: Integer;
begin
  Result := FPos;
end;

function TTiscriptArrayEnumerator.MoveNext: Boolean;
begin
  FPos := FPos + 1;
  Result := (FPos+1) <= ni.get_length(FVM, FArray);
  if Result then
    FCurrent := TTiscriptValue.Create(FVM, ni.get_elem(FVM, FArray, FPos));
end;

{ TTiscriptObjectPair }

constructor TTiscriptObjectPair.Create(vm: HVM; APos, AKey,
  AValue: tiscript_value);
begin
  FVm := vm;
  FPos := TTiscriptValue.Create(vm, APos);
  FKey := TTiscriptValue.Create(vm, AKey);;
  FValue := TTiscriptValue.Create(vm, AValue);
end;

function TTiscriptObjectPair.GetKey: ITiscriptValue;
begin
  Result := FKey;
end;

function TTiscriptObjectPair.GetPos: ITiscriptValue;
begin
  Result := FPos;
end;

function TTiscriptObjectPair.GetValue: ITiscriptValue;
begin
  Result := FValue;
end;

function TTiscriptObjectPair.GetVM: HVM;
begin
  Result := FVm;
end;

{ TDispatchFunction }
constructor TDispatchFunction.Create(AFunc: ITiscriptFunction);
begin
  FValue := AFunc;
end;

function TDispatchFunction.GetValue: ITiscriptFunction;
begin
  Result := FValue;
end;

function TDispatchFunction.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchFunction.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchFunction.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchFunction.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
type
  PVariantArray = ^TVariantArray;
  TVariantArray = array[0..65535] of Variant;
var
  Parms: PDispParams;
  pArg: TVarData;
  pArgs: array of ITiscriptValue;
  i: Integer;
  iTisValue: ITiscriptValue;
  iDisp: IDispatch;
  iObj: ITiscriptObject;
  iArray: ITiscriptArray;
  iFunc: ITiscriptFunction;
begin
  Result := S_FALSE;
  Assert(DispID = 0);
  Assert(IsEqualGUID(IID, GUID_NULL));
  Parms := @Params;
  if Parms.cArgs > 0 then
  begin
    if Parms.cArgs > MaxParams then
      raise ETiscriptException.Create('Too many arguments.');
    SetLength(pArgs, Parms.cArgs);
    for i := 0 to Parms.cArgs-1 do
    begin
      pArg := TVarData(Parms.rgvarg[i]);
      pArgs[i] := TTiscriptValue.Create(FValue.VM);
      case pArg.VType of
        varSmallInt:  pArgs[i].I := pArg.VSmallInt;
        varInteger:   pArgs[i].I := pArg.VInteger;
        varShortInt:  pArgs[i].I := pArg.VShortInt;
        varByte:      pArgs[i].I := pArg.VByte;
        varWord:      pArgs[i].I := pArg.VWord;
        varLongWord:  pArgs[i].I := pArg.VLongWord;
        varInt64:     pArgs[i].I := pArg.VInt64;
        varSingle:    pArgs[i].D := pArg.VSingle;
        varDouble:    pArgs[i].D := pArg.VDouble;
        varCurrency:  pArgs[i].D := pArg.VCurrency;
        varDate:      pArgs[i].D := pArg.VDate;
        varOleStr:    pArgs[i].S := pArg.VOleStr;
        varBoolean:   pArgs[i].B := pArg.VBoolean;
        varString:    pArgs[i].S := string(AnsiString(pArg.VString));
        varUnknown:
        begin
          if Supports(IInterface(pArg.VUnknown), IDispatch, iDisp) then
            pArgs[i] := TTiscriptValue.Create(FValue.vm, _WrapOleObject(FValue.vm, iDisp))
          else
          if Supports(IInterface(pArg.VUnknown), ITiscriptValue, iTisValue) then
            pArgs[i] := iTisValue
          else
          if Supports(IInterface(pArg.VUnknown), ITiscriptObject, iObj) then
            pArgs[i] := TTiscriptValue.Create(FValue.vm, iObj.Value)
          else
          if Supports(IInterface(pArg.VUnknown), ITiscriptArray, iArray) then
            pArgs[i] := TTiscriptValue.Create(FValue.vm, iArray.Value)
          else
          if Supports(IInterface(pArg.VUnknown), ITiscriptFunction, iFunc) then
            pArgs[i] := TTiscriptValue.Create(FValue.vm, iFunc.Value)
          else
            raise ETiscriptException.CreateFmt('Args[%d] not support interface', [i]);
        end;
      else
        raise ETiscriptException.CreateFmt('Args[%d] is not support type: %d', [i, pArg.VType]);
      end;
    end;
  end;
  if FValue.TryCallEx(pArgs, iTisValue) then
    Result := S_OK;
end;

{ TTiscriptBytes }

constructor TTiscriptBytes.Create(const AMemory: Pointer; const ASize: Cardinal);
begin
  FSize := ASize;
  GetMem(FMemory, FSize);
  CopyMemory(FMemory, AMemory, FSize);
end;

constructor TTiscriptBytes.Create(const ASize: Cardinal);
begin
  FSize := ASize;  
  FMemory := AllocMem(FSize)
end;

destructor TTiscriptBytes.Destroy;
begin
  if (FMemory <> nil) and (FSize > 0) then
    FreeMem(FMemory);
  inherited;
end;

function TTiscriptBytes.GetMemory: Pointer;
begin
  Result := FMemory;
end;

function TTiscriptBytes.GetSize: Cardinal;
begin
  Result := FSize;
end;

end.
