{*******************************************************************************
 标题:     SciterValue.pas
 描述:     Sciter值类定义 单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterValue;

interface

{$I Sciter.inc}

uses
  SysUtils, Windows, Classes, SciterTypes, SciterIntf;

type
  TDomValue = class(TInterfacedObject, IDomValue)
  private
    FValue: PSCITER_VALUE;
    FValueT: tiscript_value;
    FFromTiscrpt: Boolean;
    FOwn: Boolean;
  private
    function  GetValue: PSCITER_VALUE;
    function  GetOwnValue: Boolean;
    function  GetLength: Cardinal;
    function  GetKey(const n: UINT): IDomValue;
    function  GetItem(const n: UINT): IDomValue;
    function  GetItemByKey(const AKey: IDomValue): IDomValue;
    function  GetItemByName(const AName: SciterString): IDomValue;
    function  GetObjectData(): Pointer;
    procedure SetItem(const n: UINT; const Value: IDomValue);
    procedure SetItemByKey(const Akey, Value: IDomValue);
    procedure SetItemByName(const AName: SciterString; const AValue: IDomValue);
    procedure SetObjectData(const Value: Pointer);
    procedure SetValue(const AValue: PSCITER_VALUE);
    procedure SetOwnValue(const Value: Boolean);
  public
    constructor Create; overload;
    constructor Create(const src: SCITER_VALUE); overload;
    constructor Create(const src: PSCITER_VALUE); overload;
    constructor Create(const src: IDomValue); overload;
    constructor Create(vm: HVM; const src: tiscript_value); overload;
    constructor Create(const v: BOOL); overload;
    constructor Create(const v: Integer); overload;
    constructor Create(const v: Double); overload;
    constructor Create(const v: SciterString); overload;
    constructor Create(const s: PWideChar; slen: UINT); overload;
    constructor Create(const s: PWideChar; slen: UINT; how: UINT); overload;
    constructor Create(const b: LPCBYTE; blen: UINT); overload;
    constructor Create(arr: array of IDomValue); overload;
    constructor Create(arr: array of SCITER_VALUE); overload;
    destructor Destroy; override;

    class function Currency(const v: Currency): IDomValue;
    class function Date(const v: FILETIME): IDomValue;
    class function DateTime(const v: TDateTime; isUTC: Boolean = True): IDomValue;
    class function SecureString(const s: PWideChar; slen: size_t): IDomValue;
    class function Null: IDomValue;
    class function MakeError(const s: SciterString): IDomValue;
    class function MakeSymbol(const s: SciterString): IDomValue;
    // set color value, abgr - a << 24 | b << 16 | g << 8 | r, where a,b,g,r are bytes
    class function MakeColor(const abgr: UINT): IDomValue;
    // set duration value, seconds
    class function MakeDuration(const seconds: Double): IDomValue;
    // set angle value, radians
    class function MakeAngle(const sradians: Double): IDomValue;

    class function FromString(const s: SciterString; ct: TDomValueStringCvtType = CVT_SIMPLE): IDomValue; overload;
    class function FromString(str: LPCWSTR; strLength: UINT; ct: TDomValueStringCvtType = CVT_SIMPLE): IDomValue; overload;

    function  Implementor: Pointer;
    function  Assign(const src: IDomValue): IDomValue;

    function Clone: IDomValue;

    function IsUndefined(): Boolean;
    function IsBool(): Boolean;
    function IsInt(): Boolean;
    function IsFloat() : Boolean;
    function IsString(): Boolean;
    function IsSymbol(): Boolean;
    function IsErrorString(): Boolean;
    function IsDate(): Boolean;
    function IsCurrency(): Boolean;
    function IsMap(): Boolean;
    function IsArray(): Boolean;
    function IsFunction(): Boolean;
    function IsBytes(): Boolean;
    function IsObject(): Boolean;
    function IsDomElement(): Boolean;
    // if it is a native functor reference
    function IsNativeFunction(): Boolean;
    function IsColor(): Boolean;
    function IsDuration(): Boolean;
    function IsAngle(): Boolean;
    function IsNull(): Boolean;

    function Equal(const rs: IDomValue): Boolean; overload;

    class function Equal(const v1, v2: IDomValue): Boolean; overload;

    function AsString(how: TDomValueStringCvtType = CVT_SIMPLE): SciterString; overload;
    function AsString(const defv: SciterString = ''): SciterString; overload;
    function AsPString(const defv: PWideChar = nil): PWideChar;
    function AsInteger(defv: Integer = 0): Integer;
    function AsFloat(defv: Double): Double;
    function AsBool(defv: BOOL): BOOL;
    function AsCurrency(defv: Currency): Currency;
    function AsDate(defv: FILETIME): FILETIME;
    function AsDateTime(defv: TDateTime): TDateTime;
    function AsColor(defv: UINT = 0): UINT;
    function AsAngle(defv: Double = 0): Double;
    function AsDuration(defv: Double = 0): Double;

    function SetAsString(const v: SciterString): Boolean;
    function SetAsPString(const s: PWideChar; slen: UINT): Boolean;
    {
      returns string representing error.
      if such value is used as a return value from native function
      the script runtime will throw an error
    }
    function SetAsErrorString(const v: SciterString): Boolean;
    function SetAsSymbol(const v: SciterString): Boolean;
    function SetAsInteger(const v: Integer): Boolean;
    function SetAsFloat(const v: Double): Boolean;
    function SetAsBool(const v: BOOL): Boolean;
    function SetAsCurrency(const v: Currency): Boolean;
    function SetAsDateTime(const v: TDateTime; isUTC: Boolean = False): Boolean;
    function SetAsArray(const arr: array of IDomValue): Boolean; overload;
    function SetAsArray(const arr: array of SCITER_VALUE): Boolean; overload;
    // set color value, abgr - a << 24 | b << 16 | g << 8 | r, where a,b,g,r are bytes
    function SetAsColor(const abgr: UINT): Boolean;
    // set duration value, seconds
    function SetAsDuration(const seconds: Double): Boolean;
    // set angle value, radians
    function SetAsAngle(const sradians: Double): Boolean;

    procedure Clear;
    procedure Append(const v: IDomValue);

    procedure EnumElements(penum: TKeyValueCallback; param: LPVOID);
    // calls cbf for each key/value pair found in T_OBJECT or T_MAP  
    procedure EachKeyValue(penum: TKeyValueCallback; param: LPVOID);

    {$IFDEF HAS_TISCRIPT}
    function IsObjectNative(): Boolean;
    function IsObjectArray(): Boolean;
    function IsObjectFunction(): Boolean;
    function IsObjectObject(): Boolean;  // that is plain TS object
    function IsObjectClass(): Boolean;   // that is TS class
    function IsObjectError(): Boolean;   // that is TS error

      // T_OBJECT/UT_OBJECT_FUNCTION only, call TS function
      // 'self' here is what will be known as 'this' inside the function, can be undefined for invocations of global functions
    function Call(const argv: array of IDomValue;
      pThis: IDomValue = nil; const url_or_script_name: SciterString = ''): IDomValue; overload;
    function Call(): IDomValue; overload;

    function CallEx(vm: HVM; const argv: array of OleVariant;
      pThis: IDomValue = nil; const url_or_script_name: SciterString = ''): OleVariant; 

    function TryCall(vm: HVM; const Args: array of OleVariant; pThis: IDomValue = nil;
      const url_or_script_name: SciterString = ''): Boolean; overload;
    function TryCall(vm: HVM; const Args: array of OleVariant; out RetVal: OleVariant;
      pThis: IDomValue = nil; const url_or_script_name: SciterString = ''): Boolean; overload;

    procedure Isolate;
    {$ENDIF}

    property Value: PSCITER_VALUE read GetValue write SetValue;
    property OwnValue: Boolean read GetOwnValue write SetOwnValue;

    property Key[const n: UINT]: IDomValue read GetKey;
    // if it is an array - sets nth element expanding the array if needed
    // if it is a map - sets nth TDomValue of the map;
    // if it is a function - sets nth argument of the function;
    // otherwise it converts this to array and adds v as first element.
    property Item[const n: UINT]: IDomValue read GetItem write SetItem; default;
    property ItemByKey[const key: IDomValue]: IDomValue read GetItemByKey write SetItemByKey;
    property ItemByName[const AName: SciterString]: IDomValue read GetItemByName write SetItemByName;

    {$IFDEF HAS_TISCRIPT}
    // T_OBJECT and T_DOM_OBJECT only, get TDomValue of object's data slot
    // T_OBJECT only, set TDomValue of object's data slot
    property ObjectData: Pointer read GetObjectData write SetObjectData;
    {$ENDIF}

    // if it is an array or map returns number of elements there, otherwise - 0
    // if it is a function - returns number of arguments
    property Length: Cardinal read GetLength;
  end;

  TDomValueList = class(TInterfacedObject, IDomValueList)
  private
    FList: IInterfaceList;
  protected
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IDomValue;
    procedure SetItem(const Index: Integer; const Value: IDomValue);
  public
    constructor Create;
    destructor Destroy; override;

    function  Add(const AItem: IDomValue): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IDomValue);
    function  IndexOf(const AItem: IDomValue): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IDomValue read GetItem write SetItem; default;
  end;

implementation

uses
  SciterApiImpl, Variants, SciterFactoryIntf;

function DateTimeToWinFileTime(DT: TDateTime): Windows.TFileTime;
var
  ST: Windows.TSystemTime;
begin
  SysUtils.DateTimeToSystemTime(DT, ST);
  Windows.SystemTimeToFileTime(ST, Result)
end;

function WinFileTimeToDateTime(FT: Windows.TFileTime): TDateTime;
var
  ST: Windows.TSystemTime;
begin
  Windows.FileTimeToSystemTime(FT, ST);
  Result := SystemTimeToDateTime(ST);
end;

{ TDomValue }

constructor TDomValue.Create;
begin
  new(FValue);
  FOwn := True;
  SAPI.ValueInit(FValue^);
end;

constructor TDomValue.Create(const src: SCITER_VALUE);
begin
  Create;
  FValue^ := src;
end;

function TDomValue.Assign(const src: IDomValue): IDomValue;
begin
  SAPI.ValueCopy(FValue^, src.Value^);
  Result := Self;
end;

constructor TDomValue.Create(const src: IDomValue);
begin
  Create;
  SAPI.ValueCopy(FValue^, src.Value^);
end;

destructor TDomValue.Destroy;
begin
  try
    if FOwn and (FValue <> nil) then
    begin
      SAPI.ValueClear(FValue^);
      FValue := nil;
    end;

    inherited;
  except
    on e: Exception do
      TraceException('TDomValue.Destroy'+e.Message);
  end;
end;

constructor TDomValue.Create(const v: BOOL);
begin
  Create;
  if v then
    SAPI.ValueIntDataSet(FValue^, 1, T_BOOL, 0)
  else
    SAPI.ValueIntDataSet(FValue^, 1, T_BOOL, 0);
end;

constructor TDomValue.Create(const v: Integer);
begin
  Create;
  SAPI.ValueIntDataSet(FValue^, v, T_INT, 0);
end;

constructor TDomValue.Create(const v: Double);
begin
  Create;
  SAPI.ValueFloatDataSet(FValue^, v, T_FLOAT, 0);
end;

constructor TDomValue.Create(const v: SciterString);
begin
  Create(LPCWSTR(v), System.Length(v));
end;

constructor TDomValue.Create(const s: PWideChar; slen: UINT);
begin
  Create(s, slen, 0);
end;

constructor TDomValue.Create(const s: PWideChar; slen, how: UINT);
begin
  Create;
  SAPI.ValueStringDataSet(FValue^, s, slen, how);
end;

constructor TDomValue.Create(const b: LPCBYTE; blen: UINT);
begin
  Create;
  SAPI.ValueBinaryDataSet(FValue^, b, blen, T_BYTES, 0);
end;

constructor TDomValue.Create(arr: array of IDomValue);
var
  i: Integer;
begin
  Create;
  SAPI.ValueIntDataSet(FValue^, System.Length(arr), T_ARRAY, 0);
  for i := Low(arr) to High(arr) do
    SetItem(i, arr[i]);
end;

constructor TDomValue.Create(arr: array of SCITER_VALUE);
var
  i: Integer;
  LValue: IDomValue;
begin
  Create;
  SAPI.ValueIntDataSet(FValue^, System.Length(arr), T_ARRAY, 0);
  for i := Low(arr) to High(arr) do
  begin
    LValue := ValueFactory.Create(@arr[i]);
    SetItem(i, LValue);
  end;
end;

function TDomValue.GetItem(const n: UINT): IDomValue;
var
  LResult: SCITER_VALUE;
begin
  SAPI.ValueNthElementValue(FValue^, n, LResult);
  Result := TDomValue.Create(LResult);
end;

procedure TDomValue.SetItem(const n: UINT; const Value: IDomValue);
begin
  SAPI.ValueNthElementValueSet(FValue^, n, Value.Value^);
end;

class function TDomValue.Currency(const v: Currency): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueInt64DataSet(Result.Value^, PInt64(@v)^, T_CURRENCY, 0);
end;

class function TDomValue.Date(const v: FILETIME): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueInt64DataSet(Result.Value^, Int64(v), T_DATE, 0);
end;

class function TDomValue.DateTime(const v: TDateTime; isUTC: Boolean = True): IDomValue;
var
  v1: FILETIME;
begin
  v1 := DateTimeToWinFileTime(v);
  
  Result := TDomValue.Create;
  SAPI.ValueInt64DataSet(Result.Value^, Int64(v1), T_DATE, Integer(isUTC));
end;

class function TDomValue.SecureString(const s: PWideChar; slen: size_t): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueStringDataSet(Result.Value^, s, slen, UT_STRING_SECURE);
end;

function TDomValue.IsArray: Boolean;
begin
  Result := FValue^.t = T_ARRAY;
end;

function TDomValue.IsBool: Boolean;
begin
  Result := FValue^.t = T_BOOL;
end;

function TDomValue.IsBytes: Boolean;
begin
  Result := FValue^.t = T_BYTES;
end;

function TDomValue.IsCurrency: Boolean;
begin
  Result := FValue^.t = T_CURRENCY
end;

function TDomValue.IsDate: Boolean;
begin
  Result := FValue^.t = T_DATE;
end;

function TDomValue.IsDomElement: Boolean;
begin
  Result := FValue^.t = T_DOM_OBJECT;
end;

function TDomValue.IsFloat: Boolean;
begin
  Result := FValue^.t = T_FLOAT;
end;

function TDomValue.IsFunction: Boolean;
begin
  Result := FValue^.t = T_FUNCTION;
end;

function TDomValue.IsInt: Boolean;
begin
  Result := FValue^.t = T_INT;
end;

function TDomValue.IsMap: Boolean;
begin
  Result := FValue^.t = T_MAP;
end;

function TDomValue.IsNativeFunction: Boolean;
begin
  Result := SAPI.ValueIsNativeFunctor(FValue);
end;

function TDomValue.IsAngle: Boolean;
begin
  Result := FValue^.t = T_ANGLE;
end;

function TDomValue.IsColor: Boolean;
begin
  Result := FValue^.t = T_COLOR;
end;

function TDomValue.IsDuration: Boolean;
begin
  Result := FValue^.t = T_DURATION;
end;

function TDomValue.IsNull: Boolean;
begin
  Result := FValue^.t = T_NULL;
end;

function TDomValue.IsObject: Boolean;
begin
  Result := FValue^.t = T_OBJECT;
end;

function TDomValue.IsString: Boolean;
begin
  Result := FValue^.t = T_STRING;
end;

function TDomValue.IsSymbol: Boolean;
begin
  Result := (FValue^.t = T_STRING) and (FValue^.u = UT_STRING_SYMBOL);
end;

function TDomValue.IsUndefined: Boolean;
begin
  Result := FValue^.t = T_UNDEFINED;
end;

class function TDomValue.Null: IDomValue;
begin
  Result := TDomValue.Create;
  Result.Value^.t := T_NULL;
end;

function TDomValue.Equal(const rs: IDomValue): Boolean;
begin
  if FValue = rs.Value then
    Result := True
  else
  begin
    Result := SAPI.ValueCompare(FValue^, rs.Value^) = HV_OK_TRUE;
  end;
end;

function TDomValue.AsFloat(defv: Double): Double;
begin
  if SAPI.ValueFloatData(FValue^, Result) <> HV_OK then
    Result := defv;
end;

function TDomValue.AsInteger(defv: Integer): Integer;
begin
  if SAPI.ValueIntData(FValue^, Result) <> HV_OK then
    Result := defv;
end;

function TDomValue.AsString(const defv: SciterString = ''): SciterString;
var
  pChars: LPCWSTR;
  pNumChars: UINT;
begin
  if SAPI.ValueStringData(FValue^, pChars, pNumChars) <> HV_OK then
    Result := defv
  else
  begin
    SetLength(Result, pNumChars);
    Result := pChars;
  end;
end;

function TDomValue.AsPString(const defv: PWideChar): PWideChar;
var
  pChars: LPCWSTR;
  pNumChars: UINT;
begin
  if SAPI.ValueStringData(FValue^, pChars, pNumChars) <> HV_OK then
    Result := defv
  else
  begin
    pChars[pNumChars+1] := #0;
    Result := pChars;
  end;
end;

function TDomValue.AsBool(defv: BOOL): BOOL;
var
  v: Integer;
begin
  if SAPI.ValueIntData(FValue^, v) <> HV_OK then
    Result := defv
  else
    Result := v <> 0;
end;

function TDomValue.AsCurrency(defv: Currency): Currency;
var
  v: Int64;
begin
  if SAPI.ValueInt64Data(FValue^, v) <> HV_OK then
    Result := defv
  else
    Result := PCurrency(@v)^;
end;

function TDomValue.AsDate(defv: FILETIME): FILETIME;
var
  v: Int64;
begin
  if SAPI.ValueInt64Data(FValue^, v) <> HV_OK then
    Result := defv
  else
    Result := FILETIME(v);
end;

function TDomValue.AsDateTime(defv: TDateTime): TDateTime;
var
  defv1, result1: FILETIME;
begin
  defv1 := DateTimeToWinFileTime(defv);
  result1 := AsDate(defv1);
  Result := WinFileTimeToDateTime(result1);
end;

function TDomValue.AsAngle(defv: Double): Double;
var
  v: Double;
begin
  if SAPI.ValueFloatData(FValue^, v) <> HV_OK then
    Result := defv
  else
    Result := v;
end;

function TDomValue.AsColor(defv: UINT): UINT;
var
  v: Integer;
begin
  if SAPI.ValueIntData(FValue^, v) <> HV_OK then
    Result := defv
  else
    Result := v;
end;

function TDomValue.AsDuration(defv: Double): Double;
var
  v: Double;
begin
  if SAPI.ValueFloatData(FValue^, v) <> HV_OK then
    Result := defv
  else
    Result := v;
end;

class function TDomValue.FromString(const s: SciterString;
  ct: TDomValueStringCvtType): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueFromString(Result.Value^, LPCWSTR(s), System.Length(s), ct);
end;

class function TDomValue.FromString(str: LPCWSTR; strLength: UINT;
  ct: TDomValueStringCvtType): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueFromString(Result.Value^, str, strLength, ct);
end;

function TDomValue.AsString(how: TDomValueStringCvtType): SciterString;
var
  pChars: LPCWSTR;
  pNumChars: UINT;
begin
  if SAPI.ValueStringData(FValue^, pChars, pNumChars) = HV_OK then
    Result := pChars;
end;


procedure TDomValue.Clear;
begin
  SAPI.ValueClear(FValue^);
end;

function TDomValue.GetLength: Cardinal;
begin
  SAPI.ValueElementsCount(FValue^, Result);
end;

function TDomValue.GetItemByKey(const AKey: IDomValue): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueGetValueOfKey(FValue^, AKey.Value^, Result.Value^);
end;

procedure TDomValue.EnumElements(penum: TKeyValueCallback; param: LPVOID);
begin
  SAPI.ValueEnumElements(FValue^, penum, param);
end;

procedure TDomValue.EachKeyValue(penum: TKeyValueCallback; param: LPVOID);
begin
  SAPI.ValueEnumElements(FValue^, penum, param);
end;

function TDomValue.GetKey(const n: UINT): IDomValue;
begin
  Result := TDomValue.Create;
  SAPI.ValueNthElementKey(FValue^, n, Result.Value^);
end;

procedure TDomValue.Append(const v: IDomValue);
begin
  SAPI.ValueNthElementValueSet(FValue^, length, v.Value^);
end;

procedure TDomValue.SetItemByKey(const Akey, Value: IDomValue);
begin
  SAPI.ValueSetValueToKey(FValue^, Akey.Value^, Value.Value^);
end;

function TDomValue.GetItemByName(const AName: SciterString): IDomValue;
var
  LKey: IDomValue;
begin
  LKey := TDomValue.Create(AName);
  Result := GetItemByKey(LKey);
end;

procedure TDomValue.SetItemByName(const AName: SciterString; const AValue: IDomValue);
var
  LKey: IDomValue;
begin
  LKey := TDomValue.Create(AName);
  SAPI.ValueSetValueToKey(FValue^, LKey.Value^, AValue.Value^);
end;

function TDomValue.GetObjectData: Pointer;
var
  pv: LPCBYTE;
  dummy: UINT;
begin
  pv := nil;
  SAPI.ValueBinaryData(FValue^, pv, dummy);
  Result := pv;
end;

procedure TDomValue.SetObjectData(const Value: Pointer);
begin
  Assert(FValue^.u = UT_OBJECT_NATIVE);
  SAPI.ValueBinaryDataSet(FValue^, LPCBYTE(Value), 1, T_OBJECT, 0);
end;

{$IFDEF HAS_TISCRIPT}

function TDomValue.IsObjectArray: Boolean;
begin
  Result := (FValue^.t = T_OBJECT) and (FValue^.u = UT_OBJECT_ARRAY);
end;

function TDomValue.IsObjectClass: Boolean;
begin
  Result := (FValue^.t = T_OBJECT) and (FValue^.u = UT_OBJECT_CLASS);
end;

function TDomValue.IsObjectError: Boolean;
begin
  Result := (FValue^.t = T_OBJECT) and (FValue^.u = UT_OBJECT_ERROR);
end;

function TDomValue.IsObjectFunction: Boolean;
begin
  Result := (FValue^.t = T_OBJECT) and (FValue^.u = UT_OBJECT_FUNCTION);
end;

function TDomValue.IsObjectNative: Boolean;
begin
  Result := (FValue^.t = T_OBJECT) and (FValue^.u = UT_OBJECT_NATIVE);
end;

function TDomValue.IsObjectObject: Boolean;
begin
  Result := (FValue^.t = T_OBJECT) and (FValue^.u = UT_OBJECT_OBJECT);
end;

function TDomValue.Call(const argv: array of IDomValue;
  pThis: IDomValue; const url_or_script_name: SciterString): IDomValue;
var
  LThis: IDomValue;
  LArgv: SCITER_VALUE_ARRAY;
  pArgv: PSCITER_VALUE_ARRAY;
  i: Integer;
  r: Cardinal;
begin
  if System.Length(argv) > 0 then
  begin
    SetLength(LArgv, System.Length(argv));
    for i := 0 to High(argv) do
      LArgv[i] := argv[i].Value^;
    pArgv := @LArgv[0];
  end
  else
    pArgv := nil;
  Result := ValueFactory.Create;
  if pThis = nil then
    pThis := ValueFactory.Create(FValue);
  r := SAPI.ValueInvoke(FValue^, LThis.Value, System.Length(LArgv), pArgv, Result.Value^, LPCWSTR(url_or_script_name));
  if r <> HV_OK then
    raise ESciterCallException.Create('TDomValue.Call');
end;

function TDomValue.Call: IDomValue;
begin
  Result := Call([]);
end;

procedure TDomValue.Isolate;
begin
  SAPI.ValueIsolate(FValue);
end;

{$ENDIF}

class function TDomValue.Equal(const v1, v2: IDomValue): Boolean;
var
  tt: VALUE_TYPE;
  b: Boolean;
  i: Integer;
  f: Double;
begin
  if @v1 = @v2 then
    Result := True
  else
  begin
    if v1.Value^.t  > v2.Value^.t then
      tt := v1.Value^.t
    else
      tt := v2.Value^.t;
    case tt of
      T_BOOL:
      begin
        b := v1.AsBool(False);
        Result := b = v2.AsBool(not b);
      end;
      T_INT:
      begin
        i := v1.AsInteger(0);
        Result := i = v2.AsInteger(-i);
      end;
      T_FLOAT:
      begin
        f := v1.AsFloat(0.0);
        Result := f = v2.AsFloat(-f);
      end;
    else
      Result := False;
    end;
  end;
end;

function TDomValue.GetValue: PSCITER_VALUE;
begin
  Result := FValue;
end;

constructor TDomValue.Create(const src: PSCITER_VALUE);
begin
  FValue := src;
  FOwn   := False;
end;

function TDomValue.SetAsBool(const v: BOOL): Boolean;
begin
  if v then
    Result := SAPI.ValueIntDataSet(FValue^, 1, T_BOOL, 0) = HV_OK
  else
    Result := SAPI.ValueIntDataSet(FValue^, 1, T_BOOL, 0) = HV_OK;
end;

function TDomValue.SetAsCurrency(const v: Currency): Boolean;
begin
  Result := SAPI.ValueInt64DataSet(FValue^, PInt64(@v)^, T_CURRENCY, 0) = HV_OK;
end;

function TDomValue.SetAsDateTime(const v: TDateTime; isUTC: Boolean): Boolean;
var
  v1: FILETIME;
begin
  v1 := DateTimeToWinFileTime(v);
  Result := SAPI.ValueInt64DataSet(FValue^, Int64(v1), T_DATE, Integer(isUTC)) = HV_OK;
end;

function TDomValue.SetAsFloat(const v: Double): Boolean;
begin
  Result := SAPI.ValueFloatDataSet(FValue^, v, T_FLOAT, 0) = HV_OK;
end;

function TDomValue.SetAsInteger(const v: Integer): Boolean;
begin
  Result := SAPI.ValueIntDataSet(FValue^, v, T_INT, 0) = HV_OK;
end;

function TDomValue.SetAsPString(const s: PWideChar; slen: UINT): Boolean;
begin
  Result := SAPI.ValueStringDataSet(FValue^, s, slen, 0) = HV_OK;
end;

function TDomValue.SetAsString(const v: SciterString): Boolean;
begin
  Result := SAPI.ValueStringDataSet(FValue^, LPCWSTR(v), System.Length(v), 0) = HV_OK;
end;

function TDomValue.SetAsArray(const arr: array of IDomValue): Boolean;
var
  i: Integer;
begin
  for i := Low(arr) to High(arr) do
  begin
    SetItem(i, arr[i]);
  end;
  Result := True;
end;

function TDomValue.SetAsArray(const arr: array of SCITER_VALUE): Boolean;
var
  i: Integer;
  LValue: IDomValue;
begin
  for i := Low(arr) to High(arr) do
  begin
    LValue := ValueFactory.Create(@arr[i]);
    SetItem(i, LValue);
  end;
  Result := True;
end;

procedure TDomValue.SetValue(const AValue: PSCITER_VALUE);
begin
  if FValue = AValue then
    Exit;
  if FOwn and (FValue<>nil) then
  begin
    Clear;
    FValue := nil;
  end;

  FValue := AValue;
end;

function TDomValue.GetOwnValue: Boolean;
begin
  Result := FOwn;
end;

procedure TDomValue.SetOwnValue(const Value: Boolean);
begin
  FOwn := Value;
end;

function TDomValue.TryCall(vm: HVM; const Args: array of OleVariant;
  pThis: IDomValue = nil; const url_or_script_name: SciterString = ''): Boolean;
var
  pRetVal: OleVariant;
begin
  Result := TryCall(vm, Args, pRetVal, pThis, url_or_script_name);
end;

function TDomValue.TryCall(vm: HVM; const Args: array of OleVariant; out RetVal: OleVariant;
  pThis: IDomValue = nil; const url_or_script_name: SciterString = ''): Boolean;
var
  pVal: IDomValue;
  pArgs: array of SCITER_VALUE;
  cArgs: Integer;
  i: Integer;
  r: Cardinal;
  pArgs1: PSCITER_VALUE_ARRAY;
begin
  Result := False;
  cArgs := System.Length(Args);
  if cArgs > MaxParams then
    raise ESciterException.Create('Too many arguments.');

  SetLength(pArgs, cArgs);
  for i := Low(Args) to High(Args) do
    V2S(Args[i], pArgs[i], vm);
  pVal := ValueFactory.Create();
  try
    if cArgs <= 0 then
      pArgs1 := nil
    else
      pArgs1 := @pArgs[0];
    if pThis = nil then
      pThis := ValueFactory.Create(FValue);
    r := SAPI.ValueInvoke(FValue^, pThis.Value, cArgs, pArgs1, pVal.Value^, LPCWSTR(url_or_script_name));
  finally
    for i := Low(pArgs) to High(pArgs) do
      SAPI.ValueClear(pArgs[i]);
  end;
  if r <> HV_OK then
  begin
    RetVal := Unassigned;
    Exit;
  end;
  S2V(pVal.Value^, RetVal, vm);
  Result := True;
end;

function TDomValue.CallEx(vm: HVM; const argv: array of OleVariant;
  pThis: IDomValue; const url_or_script_name: SciterString): OleVariant;
begin                                 
  if not TryCall(vm, argv, Result, pThis, url_or_script_name) then
    raise ESciterCallException.Create('TDomValue.CallEx');
end;

function TDomValue.Clone: IDomValue;
begin
  Result := TDomValue.Create;
  Result.Assign(Self);
end;

function TDomValue.IsErrorString: Boolean;
begin
  Result := (FValue^.t = T_STRING) and (FValue^.u = UT_STRING_ERROR);
end;

function TDomValue.SetAsErrorString(const v: SciterString): Boolean;
begin
  Result := SAPI.ValueStringDataSet(FValue^, LPCWSTR(v), System.Length(v), UT_STRING_ERROR) = HV_OK;
end;

        
function TDomValue.SetAsSymbol(const v: SciterString): Boolean;
begin
  Result := SAPI.ValueStringDataSet(FValue^, LPCWSTR(v), System.Length(v), UT_STRING_SYMBOL) = HV_OK;
end;

class function TDomValue.MakeError(const s: SciterString): IDomValue;
begin
  Result := TDomValue.Create;
  Result.SetAsErrorString(s);
end;

class function TDomValue.MakeSymbol(const s: SciterString): IDomValue;
begin
  Result := TDomValue.Create;
  Result.SetAsSymbol(s);
end;

function TDomValue.Implementor: Pointer;
begin
  Result := Self;
end;

constructor TDomValue.Create(vm: HVM; const src: tiscript_value);
begin
  FValueT := src;
  FFromTiscrpt := True;
  new(FValue);
  FOwn := True;
  Assert(SAPI.Sciter_T2S(vm, src, FValue, False));
end;

class function TDomValue.MakeAngle(const sradians: Double): IDomValue;
begin
  Result := TDomValue.Create;
  Result.SetAsAngle(sradians);
end;

class function TDomValue.MakeColor(const abgr: UINT): IDomValue;
begin
  Result := TDomValue.Create;
  Result.SetAsColor(abgr);
end;

class function TDomValue.MakeDuration(const seconds: Double): IDomValue;
begin
  Result := TDomValue.Create;
  Result.SetAsDuration(seconds);
end;

function TDomValue.SetAsAngle(const sradians: Double): Boolean;
begin
  Result := SAPI.ValueFloatDataSet(FValue^, sradians, T_ANGLE, 0) = HV_OK;
end;

function TDomValue.SetAsColor(const abgr: UINT): Boolean;
begin
  Result := SAPI.ValueIntDataSet(FValue^, abgr, T_COLOR, 0) = HV_OK;
end;

function TDomValue.SetAsDuration(const seconds: Double): Boolean;
begin
  Result := SAPI.ValueFloatDataSet(FValue^, seconds, T_DURATION, 0) = HV_OK;
end;

{ TDomValueList }

function TDomValueList.Add(const AItem: IDomValue): Integer;
begin
  Result := FList.Add(AItem)
end;

procedure TDomValueList.Clear;
begin
  FList.Clear;
end;

constructor TDomValueList.Create;
begin
  FList := TInterfaceList.Create;
end;

procedure TDomValueList.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TDomValueList.Destroy;
begin
  Clear;
  FList := nil;
  inherited;
end;

function TDomValueList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDomValueList.GetItem(const Index: Integer): IDomValue;
begin
  Result := FList[index] as IDomValue;
end;

function TDomValueList.IndexOf(const AItem: IDomValue): Integer;
begin
  Result := FList.IndexOf(AItem)
end;

procedure TDomValueList.Insert(const Index: Integer;
  const AItem: IDomValue);
begin
  FList.Insert(Index, AItem);
end;

procedure TDomValueList.SetItem(const Index: Integer;
  const Value: IDomValue);
begin
  FList[Index] := Value;
end;

end.

