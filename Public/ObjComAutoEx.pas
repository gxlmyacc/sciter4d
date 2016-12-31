{*******************************************************************************
 标题:     ObjComAutoEx.pas
 描述:     IDispatch接口适配器定义单元：使一个普通的支持RTTI的TObject对象支持IDispatch接口
 创建时间：2015-05-03
 作者：    gxlmyacc
 ******************************************************************************}
unit ObjComAutoEx;

interface

uses
  SysUtils, Windows, Classes, SciterTypes, TypInfo, ObjAuto, ObjAutoEx,
  ActiveX, {$IFDEF Sciter4D}SciterHash{$ELSE}IniFiles{$ENDIF};

type
  TObjectDispatchEx = class;
  
  TDispatchTypeInfo = class(TInterfacedObject, ITypeInfo)
  private
    FDispatch: TObjectDispatchEx;
    FTypeAttr: PTypeAttr;
    FFuncDescArray: array of PFuncDesc;
  public
    constructor Create(ADispatch: TObjectDispatchEx);
    destructor Destroy; override;

    { ITypeInfo }
    function GetTypeAttr(out ptypeattr: PTypeAttr): HResult; stdcall;
    function GetTypeComp(out tcomp: ITypeComp): HResult; stdcall;
    function GetFuncDesc(index: Integer; out pfuncdesc: PFuncDesc): HResult; stdcall;
    function GetVarDesc(index: Integer; out pvardesc: PVarDesc): HResult; stdcall;
    function GetNames(memid: TMemberID; rgbstrNames: PBStrList;
      cMaxNames: Integer; out cNames: Integer): HResult; stdcall;
    function GetRefTypeOfImplType(index: Integer; out reftype: HRefType): HResult; stdcall;
    function GetImplTypeFlags(index: Integer; out impltypeflags: Integer): HResult; stdcall;
    function GetIDsOfNames(rgpszNames: POleStrList; cNames: Integer;
      rgmemid: PMemberIDList): HResult; stdcall;
    function Invoke(pvInstance: Pointer; memid: TMemberID; flags: Word;
      var dispParams: TDispParams; varResult: PVariant;
      excepInfo: PExcepInfo; argErr: PInteger): HResult; stdcall;
    function GetDocumentation(memid: TMemberID; pbstrName: PWideString;
      pbstrDocString: PWideString; pdwHelpContext: PLongint;
      pbstrHelpFile: PWideString): HResult; stdcall;
    function GetDllEntry(memid: TMemberID; invkind: TInvokeKind;
      bstrDllName, bstrName: PWideString; wOrdinal: Windows.PWord): HResult; stdcall;
    function GetRefTypeInfo(reftype: HRefType; out tinfo: ITypeInfo): HResult; stdcall;
    function AddressOfMember(memid: TMemberID; invkind: TInvokeKind; out ppv: Pointer): HResult; stdcall;
    function CreateInstance(const unkOuter: IUnknown; const iid: TIID; out vObj): HResult; stdcall;
    function GetMops(memid: TMemberID; out bstrMops: WideString): HResult; stdcall;
    function GetContainingTypeLib(out tlib: ITypeLib; out pindex: Integer): HResult; stdcall;
    procedure ReleaseTypeAttr(ptypeattr: PTypeAttr); stdcall;
    procedure ReleaseFuncDesc(pfuncdesc: PFuncDesc); stdcall;
    procedure ReleaseVarDesc(pvardesc: PVarDesc); stdcall;
  end;
  
  TObjectDispatchEx = class(TInterfacedObject, IDispatchRttiObject, IDispatch)
  private
    FTypeInfo: ITypeInfo;
    FObjectInterface: IObjectInterface;
    FInstance: TObject;
    FOwned: Boolean;
    FInvalid: Boolean;

    FDefalutPropertyInfo: PDispatchPropertyInfo;
    FPropList: PPropList;
    FMethodInfoList: THashedStringList;
    FPropertyInfoList: THashedStringList;
    FMemberArray: array of PDispatchMethodInfo;
    FParamsOrderAsc: Boolean;
  private
    function GetObjectName: SciterString;
    function GetDelphiVersion: Cardinal;
    function GetMemberCount: Integer;
    function GetMethodCount: Integer;
    function GetPropertyCount: Integer;
    function GetDefalutPropertyInfo: PDispatchPropertyInfo;
    function GetMemberInfo(const AIndex: Integer): PDispatchMethodInfo;
    function GetMethodInfo(const AIndex: Integer): PDispatchMethodInfo;
    function GetDispatchMethodInfo(const DispID: Integer): PDispatchMethodInfo;
    function GetDispatchPropertyInfo(const DispID: Integer): PDispatchPropertyInfo;
    function GetPropertyInfo(const AIndex: Integer): PDispatchPropertyInfo;
    function GetMethodInfoByName(const AName: SciterString): PDispatchMethodInfo;
    function GetPropertyInfoByName(const AName: SciterString): PDispatchPropertyInfo;
    function GetMethodInfoList: THashedStringList;
    function GetPropertyInfoList: THashedStringList;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    procedure Invalidate; virtual;

    procedure ResolveResult(var Result: OleVariant; const AResultType: PPTypeInfo);

    function InvokeMethod(AMethodInfo: PDispatchMethodInfo; Flags: Word; var Params; VarResult, ExcepInfo,
      ArgErr: Pointer): HRESULT;
    function InvokeProperty(APropertyInfo: PDispatchPropertyInfo; Flags: Word; var Params; VarResult, ExcepInfo,
      ArgErr: Pointer): HRESULT;
  public
    { IDispatch }
    function GetIDsOfNames(const IID: TGUID; Names: Pointer; NameCount: Integer;
      LocaleID: Integer; DispIDs: Pointer): HRESULT; virtual; stdcall;
    function GetTypeInfo(Index: Integer; LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult: Pointer; ExcepInfo: Pointer; ArgErr: Pointer): HRESULT; virtual; stdcall;
  public
    constructor Create(const AInstance: IObjectInterface; ParamsOrderAsc: Boolean = False); overload;
    constructor Create(const AInstance: TObject; Owned: Boolean = False; ParamsOrderAsc: Boolean = False); overload;
    destructor Destroy; override;

    function  RttiGetEnumProp(const APropInfo: PDispatchPropertyInfo): SciterString;
    procedure RttiSetEnumProp(const APropInfo: PDispatchPropertyInfo; const Value: SciterString); 
    function  RttiGetPropValue(const APropInfo: PDispatchPropertyInfo; PreferStrings: Boolean = True): OleVariant;
    procedure RttiSetPropValue(const APropInfo: PDispatchPropertyInfo; const Value: OleVariant);
    function  RttiObjectInvoke(const AMethodInfo: PDispatchMethodInfo; const ParamIndexes: array of Integer;
      const Params: array of Variant): OleVariant;
       
    procedure ClearMethodInfo;
    procedure ClearPropertyInfo;
    function IndexOf(const AName: SciterString): Integer;
    function IndexOfMethod(const AName: SciterString): Integer;
    function IndexOfProperty(const AName: SciterString): Integer;
    function IsMethodIndex(const AIndex: Integer): Boolean;
    function IsMethodName(const AName: SciterString): Boolean;
    function IsPropertyIndex(const AIndex: Integer): Boolean;
    function IsPropertyName(const AName: SciterString): Boolean;

    property MemberCount: Integer read GetMemberCount;
    property MethodCount: Integer read GetMethodCount;
    property PropertyCount: Integer read GetPropertyCount;
    property MethodInfoList: THashedStringList read GetMethodInfoList;
    property PropertyInfoList: THashedStringList read GetPropertyInfoList;

    property ParamsOrderAsc: Boolean read FParamsOrderAsc write FParamsOrderAsc;
    property MemberInfo[const AIndex: Integer]: PDispatchMethodInfo read GetMemberInfo;
    property MethodInfo[const AIndex: Integer]: PDispatchMethodInfo read GetMethodInfo;
    property PropertyInfo[const AIndex: Integer]: PDispatchPropertyInfo read GetPropertyInfo;
    property DispatchMethodInfo[const DispID: Integer]: PDispatchMethodInfo read GetDispatchMethodInfo;
    property DispatchPropertyInfo[const DispID: Integer]: PDispatchPropertyInfo read GetDispatchPropertyInfo;
    property MethodInfoByName[const AName: SciterString]: PDispatchMethodInfo read GetMethodInfoByName;
    property PropertyInfoByName[const AName: SciterString]: PDispatchPropertyInfo read GetPropertyInfoByName;
    property DefalutPropertyInfo: PDispatchPropertyInfo read GetDefalutPropertyInfo;
  end;

function WrapObjectDispatch(const AInstance: IObjectInterface; ParamsOrderAsc: Boolean = False): IDispatch; overload;
function WrapObjectDispatch(const AInstance: TObject; Owned: Boolean = False; ParamsOrderAsc: Boolean = False): IDispatch; overload;

function CreateMethodPointer(const Instance: IDispatch; const MethodName: SciterString;
  TypeInfo: PTypeInfo): TMethod; overload;
function CreateMethodPointer(const Instance: IDispatch; DispID: Integer;
  TypeInfo: PTypeInfo): TMethod; overload;
procedure ReleaseMethodPointer(const MethodPointer: TMethod);

implementation

uses
  Variants;

const
  IndexNotFound = -1;
  DispIDOffset  = 32;

type
  PVariantArray = ^TVariantArray;
  TVariantArray = array[0..65535] of Variant;
  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array[0..65535] of Integer;

var
  _DispClassList: THashedStringList = nil;

function WrapObjectDispatch(const AInstance: IObjectInterface; ParamsOrderAsc: Boolean): IDispatch;
begin
  Result := TObjectDispatchEx.Create(AInstance, ParamsOrderAsc);
end;

function WrapObjectDispatch(const AInstance: TObject; Owned, ParamsOrderAsc: Boolean): IDispatch;
begin
  Result := TObjectDispatchEx.Create(AInstance, Owned, ParamsOrderAsc);
end;

{ TObjectDispatchEx }

procedure TObjectDispatchEx.ClearMethodInfo;
var
  i: Integer;
  LMethod: PDispatchMethodInfo;
begin
  for i := FMethodInfoList.Count - 1 downto 0 do
  begin
    LMethod := PDispatchMethodInfo(FMethodInfoList.Objects[i]);
    Dispose(LMethod);
    FMethodInfoList.Delete(i);
  end;
  FMethodInfoList.Clear;
end;

procedure TObjectDispatchEx.ClearPropertyInfo;
var
  i: Integer;
begin
  for i := FPropertyInfoList.Count - 1 downto 0 do
  begin
    Dispose(PDispatchPropertyInfo(FPropertyInfoList.Objects[i]));
    FPropertyInfoList.Delete(i);
  end;
  FPropertyInfoList.Clear;
end;

constructor TObjectDispatchEx.Create(const AInstance: IObjectInterface; ParamsOrderAsc: Boolean);
begin
  Assert(AInstance<>nil, 'Instance cannot be nil!');
  FParamsOrderAsc := ParamsOrderAsc;
  FObjectInterface := AInstance;
  Create(TObject(FObjectInterface.Implementor));
end;

constructor TObjectDispatchEx.Create(const AInstance: TObject; Owned, ParamsOrderAsc: Boolean);
begin
  Assert(AInstance<>nil, 'Instance cannot be nil!');
  FParamsOrderAsc := ParamsOrderAsc;
  FInvalid    := True;
  FInstance   := AInstance;
  FOwned      := Owned;

  FMethodInfoList   := THashedStringList.Create;
  FPropertyInfoList := THashedStringList.Create;
end;

destructor TObjectDispatchEx.Destroy;
begin
  if FPropList <> nil then
  begin
    FreeMem(FPropList);
    FPropList := nil;
  end;
  FTypeInfo := nil;
  SetLength(FMemberArray, 0);

  if FMethodInfoList <> nil then
  begin
    ClearMethodInfo;
    FreeAndNil(FMethodInfoList);
  end;
  if FPropertyInfoList <> nil then
  begin
    ClearPropertyInfo;
    FreeAndNil(FPropertyInfoList);
  end;
  if FOwned and (FInstance <> nil) then
    FreeAndNil(FInstance);
  FObjectInterface := nil;

  inherited;
end;

function TObjectDispatchEx.GetDefalutPropertyInfo: PDispatchPropertyInfo;
begin
  if FInvalid then
    Invalidate;
  Result := FDefalutPropertyInfo;
end;

function TObjectDispatchEx.GetDelphiVersion: Cardinal;
begin
  {$IFDEF VER130}
    Result := Delphi5
  {$ENDIF}
  {$IFDEF VER140}
    Result := Delphi6
  {$ENDIF}
  {$IFDEF VER150}
    Result := Delphi7
  {$ENDIF}
  {$IFDEF VER160}
    Result := Delphi8
  {$ENDIF}
  {$IFDEF VER170}
    Result := Delphi2005
  {$ENDIF}
  {$IFDEF VER180}
    Result := Delphi2006
  {$ENDIF}
  {$IFDEF VER185}
    Result := Delphi2007
  {$ENDIF}
  {$IFDEF VER190}
    Result := Delphi2008
  {$ENDIF}
  {$IFDEF VER200}
    Result := Delphi2009
  {$ENDIF}
  {$IFDEF VER210}
    Result := Delphi2010
  {$ENDIF}
  {$IFDEF VER220}
    Result := DelphiXE
  {$ENDIF}
  {$IFDEF VER230}
    Result := DelphiXE2
  {$ENDIF}
  {$IFDEF VER240}
    Result := DelphiXE3
  {$ENDIF}
  {$IFDEF VER250}
    Result := DelphiXE4
  {$ENDIF}
  {$IFDEF VER260}
    Result := DelphiXE5
  {$ENDIF}
  {$IFDEF VER270}
    Result := DelphiXE6
  {$ENDIF}
  {$IFDEF VER280}
    Result := DelphiXE7
  {$ENDIF}
  {$IFDEF VER290}
    Result := DelphiXE8
  {$ENDIF}
  {$IFDEF VER300}
    Result := DelphiXE10
  {$ENDIF}
  {$IFDEF VER310}
    Result := DelphiXE10_1
  {$ENDIF}
end;

function TObjectDispatchEx.GetDispatchMethodInfo(const DispID: Integer): PDispatchMethodInfo;
var
  iIndex: Integer;
begin
  Result := nil;
  iIndex := DispID - DispIDOffset;

  if iIndex <= IndexNotFound then
    Exit;
  if (iIndex < FMethodInfoList.Count) then
    Result := PDispatchMethodInfo(FMethodInfoList.Objects[iIndex]);
end;

function TObjectDispatchEx.GetDispatchPropertyInfo(const DispID: Integer): PDispatchPropertyInfo;
var
  iIndex: Integer;
begin
  Result := nil;
  iIndex := DispID - DispIDOffset;

  if iIndex <= IndexNotFound then
    Exit;
  if (iIndex < FMethodInfoList.Count) then
    Exit;

  iIndex := iIndex - FMethodInfoList.Count;
  if (iIndex <= IndexNotFound) or (iIndex >= FPropertyInfoList.Count) then
    Exit;

  Result := PDispatchPropertyInfo(FPropertyInfoList.Objects[iIndex]);
end;

function TObjectDispatchEx.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT;
var
  sName: String;
  lDispId: TDispID;
  iIndex: Integer;
begin
  if FInvalid then
    Invalidate;
    
  Result := DISP_E_UNKNOWNNAME;
  if DispIDs = nil then Exit;
  if NameCount < 1 then Exit;
  try
    sName := WideCharToString(POleStrList(Names)^[0]);

    { method }
    iIndex := FMethodInfoList.IndexOf(sName);
    if iIndex <> IndexNotFound then
    begin
      Result := S_OK;
      lDispId := iIndex;
      PDispIDList(DispIDs)^[0] := DispIDOffset + lDispId;
      Exit;
    end;

    { property }
    iIndex := FPropertyInfoList.IndexOf(sName);
    if iIndex <> IndexNotFound then
    begin
      Result := S_OK;
      lDispId := FMethodInfoList.Count + iIndex;
      PDispIDList(DispIDs)^[0] := DispIDOffset + lDispId;
      Exit;
    end;
  except
    on e: Exception do
    begin
      OutputDebugString(PChar('[TObjectDispatchEx.GetIDsOfNames]'+e.Message));
      Result:= DISP_E_EXCEPTION;
    end;
  end;
end;

function TObjectDispatchEx.GetMemberCount: Integer;
begin
  if FInvalid then
    Invalidate;
  Result := Length(FMemberArray);
end;

function TObjectDispatchEx.GetMemberInfo(const AIndex: Integer): PDispatchMethodInfo;
begin
  if FInvalid then
    Invalidate;
  Result := FMemberArray[AIndex];
end;

function TObjectDispatchEx.GetMethodCount: Integer;
begin
  if FInvalid then
    Invalidate;
  Result := FMethodInfoList.Count;
end;

function TObjectDispatchEx.GetMethodInfo(const AIndex: Integer): PDispatchMethodInfo;
begin
  if FInvalid then
    Invalidate;
  Result := PDispatchMethodInfo(FMethodInfoList.Objects[Aindex]);
end;

function TObjectDispatchEx.GetMethodInfoByName(const AName: SciterString): PDispatchMethodInfo;
var
  iIndex: Integer;
begin
  if FInvalid then
    Invalidate;
  iIndex := FMethodInfoList.IndexOf(AName);
  if iIndex = IndexNotFound then
    Result := nil
  else
    Result := PDispatchMethodInfo(FMethodInfoList.Objects[iIndex]);
end;

function TObjectDispatchEx.GetMethodInfoList: THashedStringList;
begin
  if FInvalid then
    Invalidate;
  Result := FMethodInfoList;
end;

function TObjectDispatchEx.GetObjectName: SciterString;
var
  ins: TObject;
  cls: TClass;
  clsData: PTypeData;
begin
  if FInstance <> nil then
    ins := FInstance
  else
    ins := Self;
  cls := ins.ClassType;
  clsData := GetTypeData(cls.ClassInfo);
  Result := ExtractFileName(GetModuleName(HInstance)) + '.' + string(clsData.UnitName) + '.'+ cls.ClassName + '.' + IntToStr(Integer(ins));
end;

function TObjectDispatchEx.GetPropertyCount: Integer;
begin
  if FInvalid then
    Invalidate;    
  Result := FPropertyInfoList.Count;
end;

function TObjectDispatchEx.GetPropertyInfo(const AIndex: Integer): PDispatchPropertyInfo;
begin
  if FInvalid then
    Invalidate;
  Result := PDispatchPropertyInfo(FPropertyInfoList.Objects[Aindex]);
end;

function TObjectDispatchEx.GetPropertyInfoByName(const AName: SciterString): PDispatchPropertyInfo;
var
  iIndex: Integer;
begin
  if FInvalid then
    Invalidate;
  iIndex := FPropertyInfoList.IndexOf(AName);
  if iIndex = IndexNotFound then
    Result := nil
  else
    Result := PDispatchPropertyInfo(FPropertyInfoList.Objects[iIndex]);
end;

function TObjectDispatchEx.GetPropertyInfoList: THashedStringList;
begin
  if FInvalid then
    Invalidate;
  Result := FPropertyInfoList;
end;

function TObjectDispatchEx.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
begin
  Result := S_FALSE;
  try
    if FTypeInfo = nil then
      FTypeInfo := TDispatchTypeInfo.Create(Self);
    ITypeInfo(TypeInfo) := FTypeInfo;
    Result := S_OK;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[TObjectDispatchEx.GetTypeInfo]'+E.Message));
    end
  end;
end;

function TObjectDispatchEx.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
  Count := 1;
  Result := S_OK;
end;

function TObjectDispatchEx.IndexOf(const AName: SciterString): Integer;
begin
  if FInvalid then
    Invalidate;
  { method }
  Result := FMethodInfoList.IndexOfName(AName);
  if Result <> IndexNotFound then
    Exit;
  { property }
  Result := FPropertyInfoList.IndexOf(AName);
  if Result <> IndexNotFound then
  begin
    Result := FMethodInfoList.Count + Result;
    Exit;
  end;
end;

function TObjectDispatchEx.IndexOfMethod(const AName: SciterString): Integer;
begin
  Result := FMethodInfoList.IndexOf(AName);
end;

function TObjectDispatchEx.IndexOfProperty(const AName: SciterString): Integer;
begin
  Result := FPropertyInfoList.IndexOf(AName);
end;

procedure TObjectDispatchEx.Invalidate;
const
  SMethodOver = 'Method definition for %s has over %d parameters';
var
  idx, i, j, iParamIndex, iPropertyCount: Integer;
  LMethodInfo: PDispatchMethodInfo;
  LPropertyInfo: PDispatchPropertyInfo;
  LMethodInfoHeader: PMethodInfoHeader;
  LMethodInfoArray: TMethodInfoArray;
  LParamInfoArray: TParamInfoArray;
  sMethodName: SciterString;
  LPropInfo: PPropInfo;
begin
  ClearMethodInfo;

  LMethodInfoArray := GetMethods(FInstance.ClassType);
  SetLength(FMemberArray, Length(LMethodInfoArray));
  for i := 0 to High(LMethodInfoArray) do
  begin
    LMethodInfoHeader := LMethodInfoArray[i];
    LParamInfoArray := GetParams(LMethodInfoHeader);
    
    if Length(LParamInfoArray) > MaxParams then
      raise Exception.CreateFmt(SMethodOver, [LMethodInfoHeader.Name, MaxParams]);

    new(LMethodInfo);
    LMethodInfo^.ReturnInfo := GetReturnInfo(LMethodInfoHeader);
    LMethodInfo^.Header := LMethodInfoHeader;
    LMethodInfo^.MethodIndex := i;
    LMethodInfo^.ParamsAsc := FParamsOrderAsc;

    iParamIndex := 0;
    ZeroMemory(@LMethodInfo^.Params[0], SizeOf(LMethodInfo^.Params));
    for j := Low(LParamInfoArray) to High(LParamInfoArray) do
    begin
      if (string(LParamInfoArray[j].Name) = 'Self') or (pfResult in LParamInfoArray[j].Flags) then
      begin
        //Dec(LMethodInfo^.ParamCount);
        Continue;
      end;
      //SetLength(LMethodInfo^.Params, iParamIndex+1);
      LMethodInfo^.Params[iParamIndex] := LParamInfoArray[j];
      iParamIndex := iParamIndex + 1;
    end;
    sMethodName := {$IF CompilerVersion > 18.5}UTF8ToString{$IFEND}(LMethodInfoHeader^.Name);
    if sMethodName[Length(sMethodName)] = '_' then
      sMethodName := Copy(sMethodName, 1, Length(sMethodName)-1);
    idx := FMethodInfoList.IndexOf(sMethodName);
    if idx >= 0 then
      sMethodName := sMethodName + IntToStr(Length(LMethodInfo^.Params));
    LMethodInfo^.MethodName := sMethodName;
    LMethodInfo^.ParamCount := iParamIndex; //Length(LMethodInfo^.Params);
    
    FMethodInfoList.AddObject(sMethodName, TObject(LMethodInfo));
    FMemberArray[i] := LMethodInfo;
  end;
  SetLength(LMethodInfoArray, 0);

  if FInstance.ClassInfo <> nil then
  begin
    if FPropList <> nil then
      FreeMem(FPropList);
    
    FPropertyInfoList.Clear;
    iPropertyCount := TypInfo.GetPropList(FInstance, FPropList);
    for i := 0 to iPropertyCount-1 do
    begin
      LPropInfo := FPropList[i];

      new(LPropertyInfo);
      //ZeroMemory(LPropertyInfo, SizeOf(TDispatchPropertyInfo));
      LPropertyInfo^.Header := LPropInfo;
      LPropertyInfo^.GetMethodInfo := nil;
      LPropertyInfo^.SetMethodInfo := nil;
      for j := 0 to FMethodInfoList.Count - 1 do
      begin
        LMethodInfo := PDispatchMethodInfo(FMethodInfoList.Objects[j]);
        LMethodInfoHeader := LMethodInfo^.Header;
        if LPropInfo^.GetProc = LMethodInfoHeader.Addr then
        begin
          LPropertyInfo^.GetMethodInfo := LMethodInfo;
          LMethodInfo^.PropertyName := {$IF CompilerVersion > 18.5}UTF8ToString{$IFEND}(LPropInfo^.Name);
          LMethodInfo^.IsPropertyGet := True;
          LMethodInfo^.PropertyIndex := Length(FMemberArray);
          
          SetLength(FMemberArray, LMethodInfo^.PropertyIndex+1);
          FMemberArray[High(FMemberArray)] := LMethodInfo;
        end
        else
        if LPropInfo^.SetProc = LMethodInfoHeader.Addr then
        begin
          LPropertyInfo^.SetMethodInfo := LMethodInfo;
          LMethodInfo^.PropertyName := {$IF CompilerVersion > 18.5}UTF8ToString{$IFEND}(LPropInfo^.Name);
          LMethodInfo^.IsPropertyPut := True;
          LMethodInfo^.PropertyIndex := Length(FMemberArray);

          SetLength(FMemberArray, LMethodInfo^.PropertyIndex+1);
          FMemberArray[High(FMemberArray)] := LMethodInfo;
        end;
      end;
      FPropertyInfoList.AddObject(
        {$IF CompilerVersion > 18.5}UTF8ToString{$IFEND}(LPropInfo^.Name), TObject(LPropertyInfo));
    end;
  end;
  FInvalid := False;
end;

function TObjectDispatchEx.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HRESULT;
var
  LMethodInfo: PDispatchMethodInfo;
  LPropertyInfo: PDispatchPropertyInfo;
  iIndex: Integer;
  LDispParams: PDispParams;
begin
  if FInvalid then
    Invalidate;
  Result := S_FALSE;
  
  LDispParams := @Params;
  iIndex := DispID - DispIDOffset;
  if iIndex <= IndexNotFound then
    Exit;
  try
    if (iIndex < FMethodInfoList.Count) then
    begin
      LMethodInfo := PDispatchMethodInfo(FMethodInfoList.Objects[iIndex]);
      if LMethodInfo.ParamCount <> LDispParams.cArgs then
      begin
        iIndex := FMethodInfoList.IndexOf(LMethodInfo.MethodName + IntToStr(LDispParams.cArgs));
        if iIndex >= 0 then
          LMethodInfo := PDispatchMethodInfo(FMethodInfoList.Objects[iIndex])
        else
        begin
          Result := DISP_E_MEMBERNOTFOUND;
          Exit;
        end;
      end;
      Result := InvokeMethod(LMethodInfo, Flags, Params, VarResult, ExcepInfo, ArgErr);
      Exit;
    end
    else
    begin
      iIndex := iIndex - FMethodInfoList.Count;
      if (iIndex <= IndexNotFound) or (iIndex >= FPropertyInfoList.Count) then
      begin
        Result := DISP_E_MEMBERNOTFOUND;
        Exit;
      end;
      LPropertyInfo := PDispatchPropertyInfo(FPropertyInfoList.Objects[iIndex]);
      Result := InvokeProperty(LPropertyInfo, Flags, Params, VarResult, ExcepInfo, ArgErr);
      Exit;
    end;
    Result := S_OK;
  except
    if ExcepInfo <> nil then
    begin
      FillChar(ExcepInfo^, SizeOf(TExcepInfo), 0);
      with TExcepInfo(ExcepInfo^) do
      begin
        bstrSource := StringToOleStr(ClassName);
        if ExceptObject is Exception then
        begin
          bstrDescription := StringToOleStr(Exception(ExceptObject).Message);
          OutputDebugString(PChar('[TObjectDispatchEx.Invoke]' + Exception(ExceptObject).Message));
        end;
        scode := E_FAIL;
      end;
    end;
    Result := DISP_E_EXCEPTION;
  end;
end;

function TObjectDispatchEx.InvokeMethod(AMethodInfo: PDispatchMethodInfo;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
var
  LMethodInfoHeader: PMethodInfoHeader;
  LDispParams: PDispParams;
  TempRet: OleVariant;
  i: Integer;
  LParamIndexes: array of Integer;
begin
  LDispParams := @Params;
  try
    LMethodInfoHeader := AMethodInfo.Header;
    if LMethodInfoHeader = nil then
    begin
      Result := DISP_E_MEMBERNOTFOUND;
      Exit;
    end;
    if VarResult = nil then
      VarResult := @TempRet;

    SetLength(LParamIndexes, LDispParams.cArgs);
    for i := 0 to  LDispParams.cArgs - 1 do
    if FParamsOrderAsc then
      LParamIndexes[i] := i + 1
    else
      LParamIndexes[i] := LDispParams.cArgs - i;
    POleVariant(VarResult)^ := RttiObjectInvoke(AMethodInfo, LParamIndexes,
      Slice(PVariantArray(LDispParams.rgvarg)^, LDispParams.cArgs));
    Result := S_OK;
  except
    if ExcepInfo <> nil then
    begin
      FillChar(ExcepInfo^, SizeOf(TExcepInfo), 0);
      with TExcepInfo(ExcepInfo^) do
      begin
        bstrSource := StringToOleStr(ClassName);
        if ExceptObject is Exception then
        begin
          bstrDescription := StringToOleStr(Exception(ExceptObject).Message);
          OutputDebugString(PChar('[TObjectDispatchEx.InvokeMethod]' + Exception(ExceptObject).Message));
        end;
        scode := E_FAIL;
      end;
    end;
    Result := DISP_E_EXCEPTION;
  end;                
end;

function TObjectDispatchEx.InvokeProperty(APropertyInfo: PDispatchPropertyInfo;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
var
  LPropInfo: PPropInfo;
  LDispParams: PDispParams;
  TempRet: Variant;
begin
  LDispParams := @Params;
  try
    LPropInfo := APropertyInfo.Header;
    if LPropInfo = nil then
    begin
      Result := DISP_E_MEMBERNOTFOUND;
      Exit;
    end;
    if Flags and (DISPATCH_PROPERTYPUTREF or DISPATCH_PROPERTYPUT) <> 0 then 
    begin
      if APropertyInfo.SetMethodInfo <> nil then
      begin
        Result := InvokeMethod(APropertyInfo.SetMethodInfo, Flags, Params, VarResult, ExcepInfo, ArgErr);
        Exit;
      end
      else
      if (LDispParams.cNamedArgs <> 1) or (PIntegerArray(LDispParams.rgdispidNamedArgs)^[0] <> DISPID_PROPERTYPUT) then
      begin
        Result := DISP_E_MEMBERNOTFOUND;
        Exit;
      end
      else
        SetPropValue(FInstance, LPropInfo, PVariantArray(LDispParams.rgvarg)^[0]);
    end
    else
    begin
      if APropertyInfo.GetMethodInfo <> nil then
      begin
        Result := InvokeMethod(APropertyInfo.GetMethodInfo, Flags, Params, VarResult, ExcepInfo, ArgErr);
        Exit;
      end;
      
      if VarResult = nil then
        VarResult := @TempRet;
      if LDispParams.cArgs <> 0 then
      begin
        Result := DISP_E_BADPARAMCOUNT;
        Exit;
      end
      else
        POleVariant(VarResult)^ := GetPropValue(FInstance, LPropInfo, False);
      ResolveResult(POleVariant(VarResult)^, PPTypeInfo(LPropInfo.PropType));
    end;      
    Result := S_OK;
  except
    if ExcepInfo <> nil then
    begin
      FillChar(ExcepInfo^, SizeOf(TExcepInfo), 0);
      with TExcepInfo(ExcepInfo^) do
      begin
        bstrSource := StringToOleStr(ClassName);
        if ExceptObject is Exception then
        begin
          bstrDescription := StringToOleStr(Exception(ExceptObject).Message);
          OutputDebugString(PChar('[TObjectDispatchEx.InvokeProperty]' + Exception(ExceptObject).Message));
        end;
        scode := E_FAIL;
      end;
    end;
    Result := DISP_E_EXCEPTION;
  end;                
end;

function TObjectDispatchEx.IsMethodIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex > IndexNotFound) and (AIndex < FMethodInfoList.Count);
end;

function TObjectDispatchEx.IsMethodName(const AName: SciterString): Boolean;
begin
  Result := IsMethodIndex(IndexOf(AName))
end;

function TObjectDispatchEx.IsPropertyIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex > IndexNotFound) and (AIndex >= FMethodInfoList.Count) and (AIndex < FPropertyInfoList.Count);
end;

function TObjectDispatchEx.IsPropertyName(const AName: SciterString): Boolean;
begin
  Result := IsPropertyIndex(IndexOf(AName))
end;

function TObjectDispatchEx.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := inherited QueryInterface(IID, Obj);
  if FObjectInterface <> nil then
    Result := FObjectInterface.QueryInterface(IID, Obj);
end;

function TObjectDispatchEx.RttiObjectInvoke(const AMethodInfo: PDispatchMethodInfo;
  const ParamIndexes: array of Integer; const Params: array of Variant): OleVariant;
var
  LReturnInfo: PReturnInfo;
begin
  Result := ObjectInvoke(FInstance, AMethodInfo.Header, ParamIndexes, Params);
  LReturnInfo := PReturnInfo(AMethodInfo.ReturnInfo);
  if LReturnInfo <> nil then
    ResolveResult(Result, PPTypeInfo(LReturnInfo^.ReturnType));
end;

procedure TObjectDispatchEx.ResolveResult(var Result: OleVariant; const AResultType: PPTypeInfo);
var
  LIntf: IInterface;
  LDspIntf: IDispatch;
  LObjIntf: IObjectInterface;
  LObj: TObject;
  LVarData: PVarData;
begin
  if AResultType = nil then Exit;
  case AResultType^.Kind of
  {$IF CompilerVersion > 18.5}
    tkUString,
 {$IFEND}
    tkString:
      Result := VarToWideStr(Result);
    tkInterface:
    begin
      LIntf := Result;
      if LIntf <> nil then
      begin
        if LIntf.QueryInterface(IDispatch, LDspIntf) = S_OK then
          Result := LDspIntf
        else
        if LIntf.QueryInterface(IObjectInterface, LObjIntf) = S_OK then
          Result := WrapObjectDispatch(LObjIntf)
      end;
    end;
    tkClass:
    begin
      if not varIsNull(Result) then
      begin
        LVarData := @Result;
        LObj := LVarData^.VPointer;
        if LObj <> nil then
          Result := WrapObjectDispatch(LObj);
      end;
    end;
  end;
end;

function TObjectDispatchEx.RttiGetEnumProp(const APropInfo: PDispatchPropertyInfo): SciterString;
begin
  Result := GetEnumProp(FInstance, APropInfo.Header);
end;

function TObjectDispatchEx.RttiGetPropValue(const APropInfo: PDispatchPropertyInfo; PreferStrings: Boolean): OleVariant;
begin
  Result := GetPropValue(FInstance, APropInfo.Header, PreferStrings)
end;
procedure TObjectDispatchEx.RttiSetPropValue(const APropInfo: PDispatchPropertyInfo; const Value: OleVariant);
begin
  SetPropValue(FInstance, APropInfo.Header, Value);
end;

procedure TObjectDispatchEx.RttiSetEnumProp(const APropInfo: PDispatchPropertyInfo; const Value: SciterString);
begin
  SetEnumProp(FInstance, APropInfo.Header, Value);
end;

{ TDispatchTypeInfo }

function TDispatchTypeInfo.AddressOfMember(memid: TMemberID;
  invkind: TInvokeKind; out ppv: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

constructor TDispatchTypeInfo.Create(ADispatch: TObjectDispatchEx);
begin
  Assert(ADispatch<>nil, 'ADispatch cannot be nil!');
  FDispatch := ADispatch;
end;

function TDispatchTypeInfo.CreateInstance(const unkOuter: IInterface;
  const iid: TIID; out vObj): HResult;
begin
  Result := E_NOTIMPL;
end;

destructor TDispatchTypeInfo.Destroy;
var
  i: Integer;
  LFuncDesc: PFuncDesc;
begin
  if FTypeAttr <> nil then
  begin
    Dispose(FTypeAttr);
    FTypeAttr := nil;
  end;
  for i := Low(FFuncDescArray) to High(FFuncDescArray) do
  begin
    LFuncDesc := FFuncDescArray[i];
    if LFuncDesc <> nil then
    begin
      Dispose(LFuncDesc);
      FFuncDescArray[i] := nil;
    end;
  end;
  SetLength(FFuncDescArray, 0);
  inherited;
end;

function TDispatchTypeInfo.GetContainingTypeLib(out tlib: ITypeLib; out pindex: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetDllEntry(memid: TMemberID; invkind: TInvokeKind;
  bstrDllName, bstrName: PWideString; wOrdinal: Windows.PWord): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetDocumentation(memid: TMemberID; pbstrName,
  pbstrDocString: PWideString; pdwHelpContext: PLongint; pbstrHelpFile: PWideString): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetFuncDesc(index: Integer; out pfuncdesc: PFuncDesc): HResult;
var
  LFuncDesc: ActiveX.PFuncDesc;
  LMethodInfo: PDispatchMethodInfo;
begin
  Result := S_FALSE;
  LFuncDesc := nil;
  try
    if Length(FFuncDescArray) = 0 then
    begin
      SetLength(FFuncDescArray, FDispatch.MemberCount);
      ZeroMemory(@FFuncDescArray[0], SizeOf(FFuncDescArray));
    end;
    if FFuncDescArray[index] = nil then
    begin
      new(LFuncDesc);

      LMethodInfo := FDispatch.MemberInfo[index];
      LFuncDesc.memid := DispIDOffset + index;
      LFuncDesc.cParams := LMethodInfo.ParamCount;
      if LMethodInfo.IsPropertyGet and (index = LMethodInfo.PropertyIndex) then
        LFuncDesc.invkind := INVOKE_PROPERTYGET
      else
      if LMethodInfo.IsPropertyPut and (index = LMethodInfo.PropertyIndex) then
        LFuncDesc.invkind := INVOKE_PROPERTYPUT
      else
        LFuncDesc.invkind := INVOKE_FUNC;;
      FFuncDescArray[index] := LFuncDesc;
      LFuncDesc := nil;
    end;
    New(pfuncdesc);
    pfuncdesc^ := FFuncDescArray[index]^;
    Result := S_OK;
  except
    on E: Exception do
    begin
      if LFuncDesc <> nil then
        Dispose(LFuncDesc);
      if pfuncdesc <> nil then
        Dispose(pfuncdesc);
      OutputDebugString(PChar('[TDispatchTypeInfo.GetFuncDesc]' + E.Message));
    end
  end;  
end;

function TDispatchTypeInfo.GetIDsOfNames(rgpszNames: POleStrList;
  cNames: Integer; rgmemid: PMemberIDList): HResult;
begin
  Result := FDispatch.GetIDsOfNames(GUID_NULL, rgpszNames, cNames, LOCALE_USER_DEFAULT, rgmemid);
end;

function TDispatchTypeInfo.GetImplTypeFlags(index: Integer; out impltypeflags: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetMops(memid: TMemberID; out bstrMops: WideString): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetNames(memid: TMemberID; rgbstrNames: PBStrList;
  cMaxNames: Integer; out cNames: Integer): HResult;
var
  iIndex: Integer;
  LMethodInfo: PDispatchMethodInfo;
begin
  Result := S_FALSE;
  try
    iIndex := memid - DispIDOffset;
    if (iIndex <= IndexNotFound) or (iIndex > FDispatch.MemberCount) then
    begin
      Result := DISP_E_UNKNOWNNAME;
      Exit;
    end;
    LMethodInfo := FDispatch.MemberInfo[iIndex];
    if iIndex = LMethodInfo.MethodIndex then
      rgbstrNames[0] := PWideChar(LMethodInfo.MethodName)
    else
    if iIndex = LMethodInfo.PropertyIndex then
      rgbstrNames[0] := PWideChar(LMethodInfo.PropertyName)
    else
    begin
      Result := DISP_E_UNKNOWNNAME;
      Exit;
    end;
    cNames := 1;
    Result := S_OK;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[TDispatchTypeInfo.GetNames]' + E.Message));
    end
  end;
end;

function TDispatchTypeInfo.GetRefTypeInfo(reftype: HRefType; out tinfo: ITypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetRefTypeOfImplType(index: Integer; out reftype: HRefType): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetTypeAttr(out ptypeattr: PTypeAttr): HResult;
var
  sGUID, sClassName: string;
  iIndex: Integer;
begin
  Result := S_FALSE;
  try
    if FTypeAttr = nil then
    begin
      new(FTypeAttr);
      ZeroMemory(FTypeAttr, SizeOf(FTypeAttr));
      sClassName := IntToStr(Integer(FDispatch.FInstance.ClassType));
      iIndex := _DispClassList.IndexOfName(sClassName);
      if iIndex = IndexNotFound then
      begin
        CreateGUID(FTypeAttr.guid);
        _DispClassList.Add(sClassName+'='+GUIDToString(FTypeAttr.guid));
      end
      else
      begin
        sGUID := _DispClassList.ValueFromIndex[iIndex];
        FTypeAttr.guid := StringToGUID(sGUID);
      end;
      FTypeAttr.lcid := GetUserDefaultLCID;
      FTypeAttr.cFuncs := FDispatch.MemberCount;
    end;    
    New(ptypeattr);
    ptypeattr^ := FTypeAttr^;
    Result := S_OK;
  except
    on E: Exception do
      OutputDebugString(PChar('[TDispatchTypeInfo.GetTypeAttr]' + E.Message));
  end;
end;

function TDispatchTypeInfo.GetTypeComp(out tcomp: ITypeComp): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.GetVarDesc(index: Integer; out pvardesc: PVarDesc): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDispatchTypeInfo.Invoke(pvInstance: Pointer; memid: TMemberID;
  flags: Word; var dispParams: TDispParams; varResult: PVariant;
  excepInfo: PExcepInfo; argErr: PInteger): HResult;
begin
  Result := FDispatch.Invoke(memid, GUID_NULL, LOCALE_USER_DEFAULT, flags,
    dispParams, varResult, excepInfo, argErr);
end;

procedure TDispatchTypeInfo.ReleaseFuncDesc(pfuncdesc: PFuncDesc);
begin
  if pfuncdesc <> nil then
    Dispose(pfuncdesc)
end;

procedure TDispatchTypeInfo.ReleaseTypeAttr(ptypeattr: PTypeAttr);
begin
  if ptypeattr <> nil then
    Dispose(ptypeattr);
end;

procedure TDispatchTypeInfo.ReleaseVarDesc(pvardesc: PVarDesc);
begin
  if pvardesc <> nil then
    Dispose(pvardesc);
end;

type
  TComMethodHandler = class(TInterfacedObject, IMethodHandler)
  private
    FInstance: IDispatch;
    FDispID: Integer;
  public
    function Execute(const Args: array of Variant): Variant;
    function InstanceToVariant(Instance: TObject): Variant;
  public
    constructor Create(const Instance: IDispatch; DispID: Integer);
  end;

function CreateMethodPointer(const Instance: IDispatch; DispID: Integer; TypeInfo: PTypeInfo): TMethod;
begin
  Result := ObjAuto.CreateMethodPointer(TComMethodHandler.Create(Instance, DispID),
    GetTypeData(TypeInfo));
end;

function CreateMethodPointer(const Instance: IDispatch; const MethodName: SciterString;
  TypeInfo: PTypeInfo): TMethod;
var
  PMethodName: PWideChar;
  DispID: Integer;
begin
  PMethodName := PWideChar(MethodName);
  Assert(Succeeded(Instance.GetIDsOfNames(GUID_NULL, @PMethodName, 1, 0, @DispID)));
  Result := CreateMethodPointer(Instance, DispID, TypeInfo);
end;

procedure ReleaseMethodPointer(const MethodPointer: TMethod);
begin
  ObjAuto.ReleaseMethodPointer(MethodPointer);
end;

{ TComMethodHandler }

constructor TComMethodHandler.Create(const Instance: IDispatch; DispID: Integer);
begin
  inherited Create;
  FInstance := Instance;
  FDispID := DispID;
end;

function WashVariant(const Value: Variant): OleVariant;
begin
  if TVarData(Value).VType = (varString or varByRef) then
    Result := PString(TVarData(VAlue).VString)^ + ''
  else
    Result := Value;
end;

function TComMethodHandler.Execute(const Args: array of Variant): Variant;
var
  ExcepInfo: TExcepInfo;
  ArgErr: Integer;
  OleArgs: array of OleVariant;
  I: Integer;
  DispParams: TDispParams;
begin
  SetLength(OleArgs, High(Args) + 1);
  for I := Low(Args) to High(Args) do
    OleArgs[I] := WashVariant(Args[I]);
  DispParams.rgvarg := @OleArgs[0];
  DispParams.cArgs := High(Args) + 1;
  DispParams.rgdispidNamedArgs := nil;
  DispParams.cNamedArgs := 0;
  // TODO: Pay attention to errors.
  FInstance.Invoke(FDispID, GUID_NULL, 0, DISPATCH_METHOD, DispParams, @Result,
    @ExcepInfo, @ArgErr);
end;

function TComMethodHandler.InstanceToVariant(Instance: TObject): Variant;
begin
  Result := WrapObjectDispatch(Instance);
end;

initialization
  _DispClassList := THashedStringList.Create;
finalization
  if _DispClassList <> nil then
    FreeAndNil(_DispClassList);
end.


