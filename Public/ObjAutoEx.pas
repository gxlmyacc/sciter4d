{*******************************************************************************
 标题:     ObjAutoEx.pas
 描述:     对ObjAuto单元的扩展
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit ObjAutoEx;

interface

uses
  SysUtils, ObjAuto, Variants, TypInfo;

const
  MaxParams = 32;
  SHORT_LEN = SizeOf(ShortString) - 1;
  ParamIndexes: array[0..MaxParams-1] of Integer = (
      1,   2,   3,   4,   5,   6,   7,   8,   9,  10, 
     11,  12,  13,  14,  15,  16,  17,  18,  19,  20, 
     21,  22,  23,  24,  25,  26,  27,  28,  29,  30, 
     31,  32);

type
  TParamInfoArray  = array of PParamInfo;
  
{$IF CompilerVersion <= 15.0 }

type
  TMethodInfoArray = array of PMethodInfoHeader;

function GetMethods(ClassType: TClass): TMethodInfoArray;
{$IFEND}
function GetParams(const MethodHeader: PMethodInfoHeader): TParamInfoArray;
function GetParamCount(const MethodHeader: PMethodInfoHeader): Integer;
function GetReturnInfo(MethodInfoHeader: PMethodInfoHeader): PReturnInfo;

{$IF CompilerVersion < 18.5}
function GetPropValue(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean = True): Variant; 
procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo;
  const Value: Variant);
{$IFEND}

implementation

uses
  SysConst, RTLConsts;

{$IF CompilerVersion <= 15.0 }

function GetMethods(ClassType: TClass): TMethodInfoArray;
var
  VMT:        Pointer;
  MethodInfo: Pointer;
  Count:      Integer;
  I:          Integer;
begin
  Count := 0;
  VMT   := ClassType;
  repeat
    MethodInfo := PPointer(Integer(VMT) + vmtMethodTable)^;
    if MethodInfo <> nil then
      Inc(Count, PWord(MethodInfo)^);
    // Find the parent VMT
    VMT := PPointer(Integer(VMT) + vmtParent)^;
    if VMT = nil then
      Break;
    VMT := PPointer(VMT)^;
  until False;
  SetLength(Result, Count);
  I   := 0;
  VMT := ClassType;
  repeat
    MethodInfo := PPointer(Integer(VMT) + vmtMethodTable)^;
    if MethodInfo <> nil then
    begin
      Count := PWord(MethodInfo)^;
      Inc(Integer(MethodInfo), SizeOf(Word));
      while Count > 0 do
      begin
        Result[I] := MethodInfo;
        Inc(I);
        Inc(Integer(MethodInfo), PMethodInfoHeader(MethodInfo)^.Len);
        Dec(Count);
      end;
    end;
    // Find the parent VMT
    VMT := PPointer(Integer(VMT) + vmtParent)^;
    if VMT = nil then
      Exit;
    VMT := PPointer(VMT)^;
  until False;
end;

{$IFEND}

function GetParams(const MethodHeader: PMethodInfoHeader): TParamInfoArray;
const
  SMethodOver = 'Method definition for %s has over %d parameters';
var
  MethodInfo: Pointer;
  ReturnInfo: PReturnInfo;
  MethodName: string;
  Count: Integer;
  {$IF CompilerVersion > 18.5}
  I: Integer;
  {$ELSE}
  InfoEnd: Pointer;
  {$IFEND}
begin
  MethodInfo := MethodHeader;
  MethodName := {$IF CompilerVersion > 18.5}UTF8ToString{$IFEND}(PMethodInfoHeader(MethodInfo)^.Name);
  Inc(PByte(MethodInfo), SizeOf(TMethodInfoHeader) - SizeOf(ShortString) + 1 +
    Length(PMethodInfoHeader(MethodInfo)^.Name));
  ReturnInfo := MethodInfo;
  Inc(PAnsiChar(MethodInfo), SizeOf(TReturnInfo));

  {$IF CompilerVersion > 18.5}
  Count := ReturnInfo^.ParamCount;
  if Count >= MaxParams then
    raise Exception.CreateFmt(SMethodOver, [MethodName, MaxParams]);
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
  begin
    Result[I] := MethodInfo;
    Inc(PByte(MethodInfo), SizeOf(TParamInfo) - SizeOf(ShortString) + 1 +
      Length(PParamInfo(MethodInfo)^.Name));
    // Skip attribute data
    Inc(PByte(MethodInfo), PWord(MethodInfo)^);
  end;
  {$ELSE}
  InfoEnd := Pointer(Integer(MethodHeader) + MethodHeader^.Len);
  Count := 0;
  while Integer(MethodInfo) < Integer(InfoEnd) do
  begin
    Inc(Count);
    if Count >= MaxParams then
      raise Exception.CreateFmt(SMethodOver, [MethodName, MaxParams]);
    SetLength(Result, Count);
    Result[Count-1] := MethodInfo;
    Inc(Integer(MethodInfo), SizeOf(TParamInfo) - SizeOf(ShortString) + 1 +
      Length(PParamInfo(MethodInfo)^.Name));
  end;
  {$IFEND}
end;

function GetParamCount(const MethodHeader: PMethodInfoHeader): Integer;
var
  LParamInfoArray: TParamInfoArray;
  i: Integer;
begin
  LParamInfoArray:= GetParams(MethodHeader);
  try
    Result := Length(LParamInfoArray);
    if LParamInfoArray[0].Name = 'Self' then Dec(Result);
    for i := 0 to Length(LParamInfoArray) - 1 do
      if pfResult in LParamInfoArray[i].Flags then Dec(Result);
  finally
    SetLength(LParamInfoArray, 0);
  end;
end;

function GetReturnInfo(MethodInfoHeader: PMethodInfoHeader): PReturnInfo;
begin
  if MethodInfoHeader = nil then
    Result:= nil
  else
  if MethodInfoHeader.Len <= SizeOf(TMethodInfoHeader) + Length(MethodInfoHeader.Name) - SHORT_LEN then
    Result := nil
  else
    Result := PReturnInfo(Integer(MethodInfoHeader) + SizeOf(TMethodInfoHeader) + Length(MethodInfoHeader.Name) - SHORT_LEN);
end;

{$IF CompilerVersion < 18.5}

function GetPropValue(Instance: TObject; PropInfo: PPropInfo;
  PreferStrings: Boolean): Variant;
begin
  // assume failure
  Result := Null;
  // return the right type
  case PropInfo^.PropType^^.Kind of
    tkInteger, tkChar, tkWChar, tkClass:
      Result := GetOrdProp(Instance, PropInfo);
    tkEnumeration:
      if PreferStrings then
        Result := GetEnumProp(Instance, PropInfo)
      else if GetTypeData(PropInfo^.PropType^)^.BaseType^ = TypeInfo(Boolean) then
        Result := Boolean(GetOrdProp(Instance, PropInfo))
      else
        Result := GetOrdProp(Instance, PropInfo);
    tkSet:
      if PreferStrings then
        Result := GetSetProp(Instance, PropInfo)
      else
        Result := GetOrdProp(Instance, PropInfo);
    tkFloat:
      Result := GetFloatProp(Instance, PropInfo);
    tkMethod:
      Result := PropInfo^.PropType^.Name;
    tkString, tkLString:
      Result := GetStrProp(Instance, PropInfo);
    tkWString:
      Result := GetWideStrProp(Instance, PropInfo);
    tkVariant:
      Result := GetVariantProp(Instance, PropInfo);
    tkInt64:
      Result := GetInt64Prop(Instance, PropInfo);
    tkDynArray:
      DynArrayToVariant(Result, Pointer(GetOrdProp(Instance, PropInfo)), PropInfo^.PropType^);
  else
    raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType,
                                             [PropInfo.PropType^^.Name]);
  end;
end;

procedure SetPropValue(Instance: TObject; PropInfo: PPropInfo; const Value: Variant);

  function RangedValue(const AMin, AMax: Int64): Int64;
  begin
    Result := Trunc(Value);
    if (Result < AMin) or (Result > AMax) then
      raise ERangeError.CreateRes(@SRangeError);
  end;

var
  TypeData: PTypeData;
  DynArray: Pointer;
begin
  TypeData := GetTypeData(PropInfo^.PropType^);
  // set the right type
  case PropInfo.PropType^^.Kind of
    tkInteger, tkChar, tkWChar:
      if TypeData^.MinValue < TypeData^.MaxValue then
        SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
          TypeData^.MaxValue))
      else
        // Unsigned type
        SetOrdProp(Instance, PropInfo,
          RangedValue(LongWord(TypeData^.MinValue),
          LongWord(TypeData^.MaxValue)));
    tkEnumeration:
      if VarType(Value) = varString then
        SetEnumProp(Instance, PropInfo, VarToStr(Value))
      else if VarType(Value) = varBoolean then
        // Need to map variant boolean values -1,0 to 1,0
        SetOrdProp(Instance, PropInfo, Abs(Trunc(Value)))
      else
        SetOrdProp(Instance, PropInfo, RangedValue(TypeData^.MinValue,
          TypeData^.MaxValue));
    tkSet:
      if VarType(Value) = varInteger then
        SetOrdProp(Instance, PropInfo, Value)
      else
        SetSetProp(Instance, PropInfo, VarToStr(Value));
    tkFloat:
      SetFloatProp(Instance, PropInfo, Value);
    tkString, tkLString:
      SetStrProp(Instance, PropInfo, VarToStr(Value));
    tkWString:
      SetWideStrProp(Instance, PropInfo, VarToWideStr(Value));
    tkVariant:
      SetVariantProp(Instance, PropInfo, Value);
    tkInt64:
      SetInt64Prop(Instance, PropInfo, RangedValue(TypeData^.MinInt64Value,
        TypeData^.MaxInt64Value));
    tkDynArray:
    begin
      DynArrayFromVariant(DynArray, Value, PropInfo^.PropType^);
      SetOrdProp(Instance, PropInfo, Integer(DynArray));
    end;
  else
    raise EPropertyConvertError.CreateResFmt(@SInvalidPropertyType,
      [PropInfo.PropType^^.Name]);
  end;
end;
{$IFEND}

end.
