unit ActiveX;

interface

uses
  Windows;

const
  VT_PTR             = 26;  {    [T]     pointer type                }
  VT_CARRAY          = 28;  {    [T]     C style array               }
  VT_USERDEFINED     = 29;  {    [T]     user defined type           }

  VT_UI1             = 17;  {    [T]     unsigned char               }
  VT_I2              = 2;   { [V][T][P]  2 byte signed int           }
  VT_I4              = 3;   { [V][T][P]  4 byte signed int           }
  VT_R4              = 4;   { [V][T][P]  4 byte real                 }
  VT_R8              = 5;   { [V][T][P]  8 byte real                 }
  VT_CY              = 6;   { [V][T][P]  currency                    }
  VT_DATE            = 7;   { [V][T][P]  date                        }
  VT_BSTR            = 8;   { [V][T][P]  binary string               }
  VT_DISPATCH        = 9;   { [V][T]     IDispatch FAR*              }
  VT_ERROR           = 10;  { [V][T]     SCODE                       }
  VT_BOOL            = 11;  { [V][T][P]  True=-1, False=0            }
  VT_VARIANT         = 12;  { [V][T][P]  VARIANT FAR*                }
  VT_UNKNOWN         = 13;  { [V][T]     IUnknown FAR*               }
  VT_DECIMAL         = 14;  { [V][T]   [S]  16 byte fixed point      }
  VT_I1              = 16;  {    [T]     signed char                 }
  VT_UI2             = 18;  {    [T]     unsigned short              }
  VT_UI4             = 19;  {    [T]     unsigned long               }
  VT_INT             = 22;  {    [T]     signed machine int          }
  VT_UINT            = 23;  {    [T]     unsigned machine int        }
            
  VT_ARRAY         = $2000; { [V]        SAFEARRAY*                  }
  VT_BYREF         = $4000; { [V]                                    }

  INVOKE_FUNC           = 1;
  INVOKE_PROPERTYGET    = 2;
  INVOKE_PROPERTYPUT    = 4;
  INVOKE_PROPERTYPUTREF = 8;

  VAR_PERINSTANCE = 0;
  VAR_STATIC      = 1;
  VAR_CONST       = 2;
  VAR_DISPATCH    = 3;

  DISPATCH_METHOD         = $1;
  DISPATCH_PROPERTYGET    = $2;
  DISPATCH_PROPERTYPUT    = $4;
  DISPATCH_PROPERTYPUTREF = $8;
  DISPATCH_CONSTRUCT      = $4000;

  CLSCTX_INPROC_SERVER     = 1;
  CLSCTX_INPROC_HANDLER    = 2;
  CLSCTX_LOCAL_SERVER      = 4;
  CLSCTX_INPROC_SERVER16   = 8;
  CLSCTX_REMOTE_SERVER     = $10;
  CLSCTX_INPROC_HANDLER16  = $20;
  CLSCTX_INPROC_SERVERX86  = $40;
  CLSCTX_INPROC_HANDLERX86 = $80;

  DISPID_VALUE       = 0;
  DISPID_UNKNOWN     = -1;
  DISPID_STARTENUM   = DISPID_UNKNOWN;
  DISPID_PROPERTYPUT = -3;
  DISPID_NEWENUM     = -4;

  GUID_NULL: TGUID = '{00000000-0000-0000-0000-000000000000}';
  
type
  PSafeArrayBound = ^TSafeArrayBound;
  tagSAFEARRAYBOUND = record
    cElements: Longint;
    lLbound: Longint;
  end;
  TSafeArrayBound = tagSAFEARRAYBOUND;
  SAFEARRAYBOUND = TSafeArrayBound;

  PSafeArray = ^TSafeArray;
  tagSAFEARRAY = record
    cDims: Word;
    fFeatures: Word;
    cbElements: Longint;
    cLocks: Longint;
    pvData: Pointer;
    rgsabound: array[0..0] of TSafeArrayBound;
  end;
  TSafeArray = tagSAFEARRAY;
  SAFEARRAY = TSafeArray;

  PHResult = ^HResult;
  PSCODE = ^Integer;
  SCODE = Integer;

  PSYSINT = ^SYSINT;
  SYSINT = Integer;
  PSYSUINT = ^SYSUINT;
  SYSUINT = LongWord;

  PResultList = ^TResultList;
  TResultList = array[0..65535] of HRESULT;

  PUnknownList = ^TUnknownList;
  TUnknownList = array[0..65535] of IUnknown;
  
  TOleChar = WideChar;
  POleStr = PWideChar;
  PPOleStr = ^POleStr;
  TOleDate = Double;
  POleDate = ^TOleDate;
  TOleBool = WordBool;
  POleBool = ^TOleBool;
  TLCID = DWORD;

  TVarType = Word;

  TOldOleEnum = type Integer;
  TOleEnum = type LongWord;

  PBStr = ^TBStr;
  TBStr = POleStr;

  PBStrList = ^TBStrList;
  TBStrList = array[0..65535] of TBStr;

  POleStrList = ^TOleStrList;
  TOleStrList = array[0..65535] of POleStr;

  Largeint = Int64;
  PLargeuint = ^Largeuint;
  Largeuint = Int64;

  PIID = PGUID;
  TIID = TGUID;
  PCLSID = PGUID;
  TCLSID = TGUID;

  PComp = ^Comp;

  PDecimal = ^TDecimal;
  tagDEC = packed record
    wReserved: Word;
    case Integer of
      0: (scale, sign: Byte; Hi32: Longint;
      case Integer of
        0: (Lo32, Mid32: Longint);
        1: (Lo64: LONGLONG));
      1: (signscale: Word);
  end;
  TDecimal = tagDEC;
  DECIMAL = TDecimal;

  TDispID = Longint;
  PDispIDList = ^TDispIDList;
  TDispIDList = array[0..65535] of TDispID;

  TMemberID = TDispID;
  PMemberIDList = ^TMemberIDList;
  TMemberIDList = array[0..65535] of TMemberID;

  PCoServerInfo = ^TCoServerInfo;
  _COSERVERINFO = record
    dwReserved1: Longint;
    pwszName: LPWSTR;
    pAuthInfo: Pointer;
    dwReserved2: Longint;
  end;
  TCoServerInfo = _COSERVERINFO;
  COSERVERINFO = TCoServerInfo;

  PMultiQI = ^TMultiQI;
  tagMULTI_QI = record
    IID: PIID;
    Itf: IUnknown;
    hr: HRESULT;
  end;
  TMultiQI = tagMULTI_QI;
  MULTI_QI = TMultiQI;

  PMultiQIArray = ^TMultiQIArray;
  TMultiQIArray = array[0..65535] of TMultiQI;

  HRefType = DWORD;

  tagTYPEKIND = DWORD;
  TTypeKind = tagTYPEKIND;

  PVariantArg = ^TVariantArg;
  tagVARIANT = record
    vt: TVarType;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    case Integer of
      VT_UI1:                  (bVal: Byte);
      VT_I2:                   (iVal: Smallint);
      VT_I4:                   (lVal: Longint);
      VT_R4:                   (fltVal: Single);
      VT_R8:                   (dblVal: Double);
      VT_BOOL:                 (vbool: TOleBool);
      VT_ERROR:                (scode: HResult);
      VT_CY:                   (cyVal: Currency);
      VT_DATE:                 (date: TOleDate);
      VT_BSTR:                 (bstrVal: PWideChar{WideString});
      VT_UNKNOWN:              (unkVal: Pointer{IUnknown});
      VT_DISPATCH:             (dispVal: Pointer{IDispatch});
      VT_ARRAY:                (parray: PSafeArray);
      VT_BYREF or VT_UI1:      (pbVal: ^Byte);
      VT_BYREF or VT_I2:       (piVal: ^Smallint);
      VT_BYREF or VT_I4:       (plVal: ^Longint);
      VT_BYREF or VT_R4:       (pfltVal: ^Single);
      VT_BYREF or VT_R8:       (pdblVal: ^Double);
      VT_BYREF or VT_BOOL:     (pbool: ^TOleBool);
      VT_BYREF or VT_ERROR:    (pscode: ^HResult);
      VT_BYREF or VT_CY:       (pcyVal: ^Currency);
      VT_BYREF or VT_DATE:     (pdate: ^TOleDate);
      VT_BYREF or VT_BSTR:     (pbstrVal: ^WideString);
      VT_BYREF or VT_UNKNOWN:  (punkVal: ^IUnknown);
      VT_BYREF or VT_DISPATCH: (pdispVal: ^IDispatch);
      VT_BYREF or VT_ARRAY:    (pparray: ^PSafeArray);
      VT_BYREF or VT_VARIANT:  (pvarVal: PVariant);
      VT_BYREF:                (byRef: Pointer);
      VT_I1:                   (cVal: Char);
      VT_UI2:                  (uiVal: Word);
      VT_UI4:                  (ulVal: LongWord);
      VT_INT:                  (intVal: Integer);
      VT_UINT:                 (uintVal: LongWord);
      VT_BYREF or VT_DECIMAL:  (pdecVal: PDecimal);
      VT_BYREF or VT_I1:       (pcVal: PChar);
      VT_BYREF or VT_UI2:      (puiVal: PWord);
      VT_BYREF or VT_UI4:      (pulVal: PInteger);
      VT_BYREF or VT_INT:      (pintVal: PInteger);
      VT_BYREF or VT_UINT:     (puintVal: PLongWord);
  end;
  TVariantArg = tagVARIANT;

  PVariantArgList = ^TVariantArgList;
  TVariantArgList = array[0..65535] of TVariantArg;

  PArrayDesc = ^TArrayDesc;
  PTypeDesc = ^TTypeDesc;
  tagTYPEDESC = record
    case Integer of
      VT_PTR:         (ptdesc: PTypeDesc; vt: TVarType);
      VT_CARRAY:      (padesc: PArrayDesc);
      VT_USERDEFINED: (hreftype: HRefType);
  end;
  TTypeDesc = tagTYPEDESC;
  TYPEDESC = TTypeDesc;

  tagARRAYDESC = record
    tdescElem: TTypeDesc;
    cDims: Word;
    rgbounds: array[0..0] of TSafeArrayBound;
  end;
  TArrayDesc = tagARRAYDESC;
  ARRAYDESC = TArrayDesc;


  PIDLDesc = ^TIDLDesc;
  tagIDLDESC = record
    dwReserved: Longint;
    wIDLFlags: Word;
  end;
  TIDLDesc = tagIDLDESC;
  IDLDESC = TIDLDesc;


  PParamDescEx = ^TParamDescEx;
  tagPARAMDESCEX = record
    cBytes: Longint;
    FourBytePad: Longint;
    varDefaultValue: TVariantArg;
  end;
  TParamDescEx = tagPARAMDESCEX;
  PARAMDESCEX = TParamDescEx;


  PParamDesc = ^TParamDesc;
  tagPARAMDESC = record
    pparamdescex: PParamDescEx;
    wParamFlags: Word;
  end;
  TParamDesc = tagPARAMDESC;
  PARAMDESC = TParamDesc;


  PElemDesc = ^TElemDesc;
  tagELEMDESC = record
    tdesc: TTypeDesc;
    case Integer of
      0: (idldesc: TIDLDesc);
      1: (paramdesc: TParamDesc);
  end;
  TElemDesc = tagELEMDESC;
  ELEMDESC = TElemDesc;

  PElemDescList = ^TElemDescList;
  TElemDescList = array[0..65535] of TElemDesc;

  ITypeInfo = interface;
  ITypeLib = interface;

  PTypeAttr = ^TTypeAttr;
  tagTYPEATTR = record
    guid: TGUID;
    lcid: TLCID;
    dwReserved: Longint;
    memidConstructor: TMemberID;
    memidDestructor: TMemberID;
    lpstrSchema: POleStr;
    cbSizeInstance: Longint;
    typekind: TTypeKind;
    cFuncs: Word;
    cVars: Word;
    cImplTypes: Word;
    cbSizeVft: Word;
    cbAlignment: Word;
    wTypeFlags: Word;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    tdescAlias: TTypeDesc;
    idldescType: TIDLDesc;
  end;
  TTypeAttr = tagTYPEATTR;
  TYPEATTR = TTypeAttr;


  PDispParams = ^TDispParams;
  tagDISPPARAMS = record
    rgvarg: PVariantArgList;
    rgdispidNamedArgs: PDispIDList;
    cArgs: Longint;
    cNamedArgs: Longint;
  end;
  TDispParams = tagDISPPARAMS;
  DISPPARAMS = TDispParams;


  PExcepInfo = ^TExcepInfo;

  TFNDeferredFillIn = function(ExInfo: PExcepInfo): HResult stdcall;

  tagEXCEPINFO = record
    wCode: Word;
    wReserved: Word;
    bstrSource: WideString;
    bstrDescription: WideString;
    bstrHelpFile: WideString;
    dwHelpContext: Longint;
    pvReserved: Pointer;
    pfnDeferredFillIn: TFNDeferredFillIn;
    scode: HResult;
  end;
  TExcepInfo = tagEXCEPINFO;
  EXCEPINFO = TExcepInfo;

  tagFUNCKIND = Longint;
  TFuncKind = tagFUNCKIND;

  tagINVOKEKIND = Longint;
  TInvokeKind = tagINVOKEKIND;

  tagCALLCONV = Longint;
  TCallConv = tagCALLCONV;


  PFuncDesc = ^TFuncDesc;
  tagFUNCDESC = record
    memid: TMemberID;
    lprgscode: PResultList;
    lprgelemdescParam: PElemDescList;
    funckind: TFuncKind;
    invkind: TInvokeKind;
    callconv: TCallConv;
    cParams: Smallint;
    cParamsOpt: Smallint;
    oVft: Smallint;
    cScodes: Smallint;
    elemdescFunc: TElemDesc;
    wFuncFlags: Word;
  end;
  TFuncDesc = tagFUNCDESC;
  FUNCDESC = TFuncDesc;

  TVarKind = Longint;

  PVarDesc = ^TVarDesc;
  tagVARDESC = record
    memid: TMemberID;
    lpstrSchema: POleStr;
    case Integer of
      VAR_PERINSTANCE: (
        oInst: Longint;
        elemdescVar: TElemDesc;
        wVarFlags: Word;
        varkind: TVarKind);
      VAR_CONST: (
        lpvarValue: POleVariant);
  end;
  TVarDesc = tagVARDESC;
  VARDESC = TVarDesc;

{ ITypeComp interface }

  TDescKind = Longint;

  PBindPtr = ^TBindPtr;
  tagBINDPTR = record
    case Integer of
      0: (lpfuncdesc: PFuncDesc);
      1: (lpvardesc: PVarDesc);
      2: (lptcomp: Pointer {ITypeComp});
  end;
  TBindPtr = tagBINDPTR;
  BINDPTR = TBindPtr;

  ITypeComp = interface(IUnknown)
    ['{00020403-0000-0000-C000-000000000046}']
    function Bind(szName: POleStr; lHashVal: Longint; wflags: Word;
      out tinfo: ITypeInfo; out desckind: TDescKind;
      out bindptr: TBindPtr): HResult; stdcall;
    function BindType(szName: POleStr; lHashVal: Longint;
      out tinfo: ITypeInfo; out tcomp: ITypeComp): HResult;
      stdcall;
  end;
  
{ ITypeInfo interface }

  ITypeInfo = interface(IUnknown)
    ['{00020401-0000-0000-C000-000000000046}']
    function GetTypeAttr(out ptypeattr: PTypeAttr): HResult; stdcall;
    function GetTypeComp(out tcomp: ITypeComp): HResult; stdcall;
    function GetFuncDesc(index: Integer; out pfuncdesc: PFuncDesc): HResult;
      stdcall;
    function GetVarDesc(index: Integer; out pvardesc: PVarDesc): HResult;
      stdcall;
    function GetNames(memid: TMemberID; rgbstrNames: PBStrList;
      cMaxNames: Integer; out cNames: Integer): HResult; stdcall;
    function GetRefTypeOfImplType(index: Integer; out reftype: HRefType): HResult;
      stdcall;
    function GetImplTypeFlags(index: Integer; out impltypeflags: Integer): HResult;
      stdcall;
    function GetIDsOfNames(rgpszNames: POleStrList; cNames: Integer;
      rgmemid: PMemberIDList): HResult; stdcall;
    function Invoke(pvInstance: Pointer; memid: TMemberID; flags: Word;
      var dispParams: TDispParams; varResult: PVariant;
      excepInfo: PExcepInfo; argErr: PInteger): HResult; stdcall;
    function GetDocumentation(memid: TMemberID; pbstrName: PWideString;
      pbstrDocString: PWideString; pdwHelpContext: PLongint;
      pbstrHelpFile: PWideString): HResult; stdcall;
    function GetDllEntry(memid: TMemberID; invkind: TInvokeKind;
      bstrDllName, bstrName: PWideString; wOrdinal: PWord): HResult;
      stdcall;
    function GetRefTypeInfo(reftype: HRefType; out tinfo: ITypeInfo): HResult;
      stdcall;
    function AddressOfMember(memid: TMemberID; invkind: TInvokeKind;
      out ppv: Pointer): HResult; stdcall;
    function CreateInstance(const unkOuter: IUnknown; const iid: TIID;
      out vObj): HResult; stdcall;
    function GetMops(memid: TMemberID; out bstrMops: WideString): HResult;
      stdcall;
    function GetContainingTypeLib(out tlib: ITypeLib; out pindex: Integer): HResult;
      stdcall;
    procedure ReleaseTypeAttr(ptypeattr: PTypeAttr); stdcall;
    procedure ReleaseFuncDesc(pfuncdesc: PFuncDesc); stdcall;
    procedure ReleaseVarDesc(pvardesc: PVarDesc); stdcall;
  end;

{ ITypeLib interface }

  TSysKind = Longint;

  PTLibAttr = ^TTLibAttr;
  tagTLIBATTR = record
    guid: TGUID;
    lcid: TLCID;
    syskind: TSysKind;
    wMajorVerNum: Word;
    wMinorVerNum: Word;
    wLibFlags: Word;
  end;
  TTLibAttr = tagTLIBATTR;
  TLIBATTR = TTLibAttr;

  PTypeInfoList = ^TTypeInfoList;
  TTypeInfoList = array[0..65535] of ITypeInfo;

  ITypeLib = interface(IUnknown)
    ['{00020402-0000-0000-C000-000000000046}']
    function GetTypeInfoCount: Integer; stdcall;
    function GetTypeInfo(index: Integer; out tinfo: ITypeInfo): HResult; stdcall;
    function GetTypeInfoType(index: Integer; out tkind: TTypeKind): HResult;
      stdcall;
    function GetTypeInfoOfGuid(const guid: TGUID; out tinfo: ITypeInfo): HResult;
      stdcall;
    function GetLibAttr(out ptlibattr: PTLibAttr): HResult; stdcall;
    function GetTypeComp(out tcomp: ITypeComp): HResult; stdcall;
    function GetDocumentation(index: Integer; pbstrName: PWideString;
      pbstrDocString: PWideString; pdwHelpContext: PLongint;
      pbstrHelpFile: PWideString): HResult; stdcall;
    function IsName(szNameBuf: POleStr; lHashVal: Longint; out fName: BOOL): HResult;
      stdcall;
    function FindName(szNameBuf: POleStr; lHashVal: Longint;
      rgptinfo: PTypeInfoList; rgmemid: PMemberIDList;
      out pcFound: Word): HResult; stdcall;
    procedure ReleaseTLibAttr(ptlibattr: PTLibAttr); stdcall;
  end;

{ IEnumVariant interface }

  IEnumVariant = interface(IUnknown)
    ['{00020404-0000-0000-C000-000000000046}']
    function Next(celt: LongWord; var rgvar : OleVariant;
      out pceltFetched: LongWord): HResult; stdcall;
    function Skip(celt: LongWord): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumVariant): HResult; stdcall;
  end;

function Succeeded(Res: HResult): Boolean;
function Failed(Res: HResult): Boolean;
function ResultCode(Res: HResult): Integer;

function SystemTimeToVariantTime(var SystemTime: TSystemTime;
  out vtime: TOleDate): Integer; stdcall;
function VariantTimeToSystemTime(vtime: TOleDate;
  out SystemTime: TSystemTime): Integer; stdcall;

function CoTaskMemAlloc(cb: Longint): Pointer; stdcall;
function CoTaskMemRealloc(pv: Pointer; cb: Longint): Pointer; stdcall;
procedure CoTaskMemFree(pv: Pointer); stdcall;

function ProgIDFromCLSID(const clsid: TCLSID; out pszProgID: POleStr): HResult; stdcall;
function CLSIDFromProgID(pszProgID: POleStr; out clsid: TCLSID): HResult; stdcall;

function SysAllocString(psz: POleStr): TBStr; stdcall;

function GetActiveObject(const clsid: TCLSID; pvReserved: Pointer;
  out unk: IUnknown): HResult; stdcall;

function CoInitialize(pvReserved: Pointer): HResult; stdcall;
procedure CoUninitialize; stdcall;
function OleInitialize(pwReserved: Pointer): HResult; stdcall;
procedure OleUninitialize; stdcall;

function CoCreateInstance(const clsid: TCLSID; unkOuter: IUnknown;
  dwClsContext: Longint; const iid: TIID; out pv): HResult; stdcall;
function CoCreateInstanceEx(const clsid: TCLSID;
  unkOuter: IUnknown; dwClsCtx: Longint; ServerInfo: PCoServerInfo;
  dwCount: Longint; rgmqResults: PMultiQIArray): HResult; stdcall;
  
implementation

const
{$IFDEF MSWINDOWS}
  ole32    = 'ole32.dll';
  oleaut32 = 'oleaut32.dll';
  olepro32 = 'olepro32.dll';
{$ENDIF}

function Succeeded(Res: HResult): Boolean;
begin
  Result := Res and $80000000 = 0;
end;

function Failed(Res: HResult): Boolean;
begin
  Result := Res and $80000000 <> 0;
end;

function ResultCode(Res: HResult): Integer;
begin
  Result := Res and $0000FFFF;
end;

function SystemTimeToVariantTime;       external oleaut32 name 'SystemTimeToVariantTime';
function VariantTimeToSystemTime;       external oleaut32 name 'VariantTimeToSystemTime';

function CoTaskMemAlloc;                external ole32 name 'CoTaskMemAlloc';
function CoTaskMemRealloc;              external ole32 name 'CoTaskMemRealloc';
procedure CoTaskMemFree;                external ole32 name 'CoTaskMemFree';

function ProgIDFromCLSID;               external ole32 name 'ProgIDFromCLSID';
function CLSIDFromProgID;               external ole32 name 'CLSIDFromProgID';

function SysAllocString;                external oleaut32 name 'SysAllocString';

function GetActiveObject;               external oleaut32 name 'GetActiveObject';

function CoInitialize;                  external ole32 name 'CoInitialize';
procedure CoUninitialize;               external ole32 name 'CoUninitialize';
function CoCreateInstance;              external ole32 name 'CoCreateInstance';
function CoCreateInstanceEx;            external ole32 name 'CoCreateInstanceEx';

function OleInitialize;                 external ole32 name 'OleInitialize';
procedure OleUninitialize;              external ole32 name 'OleUninitialize';

end.
