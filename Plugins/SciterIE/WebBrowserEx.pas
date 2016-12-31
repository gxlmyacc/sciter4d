unit WebBrowserEx;

{$DEFINE DYNAMIC_LINK}

interface

uses
  SysUtils, Variants, Windows, ActiveX;

type
  TOleDate = Double;
  POleDate = ^TOleDate;
  TOleBool = WordBool;
  POleBool = ^TOleBool;
  PCLSID = PGUID;
  TCLSID = TGUID;
  TVariantArray = array of OleVariant;

const
  OLEIVERB_PRIMARY = 0;
  OLEIVERB_SHOW = -1;
  OLEIVERB_OPEN = -2;
  OLEIVERB_HIDE = -3;
  OLEIVERB_UIACTIVATE = -4;
  OLEIVERB_INPLACEACTIVATE = -5;
  OLEIVERB_DISCARDUNDOSTATE = -6;
const
  DOCHOSTUIFLAG_DIALOG = $00000001;
  DOCHOSTUIFLAG_DISABLE_HELP_MENU = $00000002;
  DOCHOSTUIFLAG_NO3DBORDER = $00000004;
  DOCHOSTUIFLAG_SCROLL_NO = $00000008;
  DOCHOSTUIFLAG_DISABLE_SCRIPT_INACTIVE = $00000010;
  DOCHOSTUIFLAG_OPENNEWWIN = $00000020;
  DOCHOSTUIFLAG_DISABLE_OFFSCREEN = $00000040;
  DOCHOSTUIFLAG_FLAT_SCROLLBAR = $00000080;
  DOCHOSTUIFLAG_DIV_BLOCKDEFAULT = $00000100;
  DOCHOSTUIFLAG_ACTIVATE_CLIENTHIT_ONLY = $00000200;
  DOCHOSTUIFLAG_OVERRIDEBEHAVIOURFACTORY = $00000400;
  DOCHOSTUIFLAG_CODEPAGELINKEDFONTS = $00000800;
  DOCHOSTUIFLAG_URL_ENCODING_DISABLE_UTF8 = $00001000;
  DOCHOSTUIFLAG_URL_ENCODING_ENABLE_UTF8 = $00002000;
  DOCHOSTUIFLAG_ENABLE_FORMS_AUTOCOMPLETE = $00004000;

const
  ole32 = 'ole32.dll';
  oleaut32 = 'oleaut32.dll';

  CLSCTX_INPROC_SERVER = 1;
  CLSCTX_INPROC_HANDLER = 2;
  CLSCTX_INPROC = CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER;

  CLSID_WebBrowser: TGUID = '{8856F961-340A-11D0-A96B-00C04FD705A2}';
  IID_IOleInPlaceObject: TGUID = '{00000113-0000-0000-C000-000000000046}';
  IID_IOleObject: TGUID = '{00000112-0000-0000-C000-000000000046}';

type
  POleStr = PWideChar;
  SYSINT = Integer;
  TOleEnum = type LongWord;

  TSafeArrayBound = record
    cElements: Longint;
    lLbound: Longint;
  end;
  PSafeArray = ^TSafeArray;
  TSafeArray = record
    cDims: Word;
    fFeatures: Word;
    cbElements: Longint;
    cLocks: Longint;
    pvData: Pointer;
    rgsabound: array [0 .. 0] of TSafeArrayBound;
  end;
  TOleInPlaceFrameInfo = record
    cb: Integer;
    fMDIApp: BOOL;
    hwndFrame: HWND;
    haccel: haccel;
    cAccelEntries: Integer;
  end;

  IOleClientSite = interface(IUnknown)
    ['{00000118-0000-0000-C000-000000000046}']
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IUnknown): HResult; stdcall;
    function GetContainer(out container: IUnknown): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
  end;
  IOleWindow = interface(IUnknown)
    ['{00000114-0000-0000-C000-000000000046}']
    function GetWindow(out wnd: HWND): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
  end;
  IOleInPlaceActiveObject = interface;
  IOleInPlaceUIWindow = interface(IOleWindow)
    ['{00000115-0000-0000-C000-000000000046}']
    function GetBorder(out rectBorder: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(pborderwidths: PRect): HResult; stdcall;
    function SetActiveObject(const activeObject: IOleInPlaceActiveObject;
      pszObjName: POleStr): HResult; stdcall;
  end;
  IOleInPlaceActiveObject = interface(IOleWindow)
    ['{00000117-0000-0000-C000-000000000046}']
    function TranslateAccelerator(var msg: TMsg): HResult; stdcall;
    function OnFrameWindowActivate(fActivate: BOOL): HResult; stdcall;
    function OnDocWindowActivate(fActivate: BOOL): HResult; stdcall;
    function ResizeBorder(const rcBorder: TRect; const uiWindow: IOleInPlaceUIWindow; fFrameWindow: BOOL): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
  end;
  IOleInPlaceFrame = IUnknown;
  IOleInPlaceSite = interface(IOleWindow)
    ['{00000119-0000-0000-C000-000000000046}']
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out frame: IOleInPlaceFrame; out doc: IUnknown;
      out rcPosRect: TRect; out rcClipRect: TRect;
      out frameInfo: TOleInPlaceFrameInfo): HResult; stdcall;
    function Scroll(scrollExtent: TPoint): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(const rcPosRect: TRect): HResult; stdcall;
  end;
  IOleInPlaceObject = interface(IOleWindow)
    ['{00000113-0000-0000-C000-000000000046}']
    function InPlaceDeactivate: HResult; stdcall;
    function UIDeactivate: HResult; stdcall;
    function SetObjectRects(const rcPosRect: TRect; const rcClipRect: TRect): HResult; stdcall;
    function ReactivateAndUndo: HResult; stdcall;
  end;
  IOleObject = interface(IUnknown)
    ['{00000112-0000-0000-C000-000000000046}']
    function SetClientSite(const clientSite: IOleClientSite): HResult; stdcall;
    function GetClientSite(out clientSite: IOleClientSite): HResult; stdcall;
    function SetHostNames(szContainerApp: Pointer; szContainerObj: Pointer): HResult; stdcall;
    function Close(dwSaveOption: Longint): HResult; stdcall;
    function SetMoniker(dwWhichMoniker: Longint; const mk: IUnknown): HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint; out mk: IUnknown): HResult; stdcall;
    function InitFromData(const dataObject: IUnknown; fCreation: BOOL; dwReserved: Longint): HResult; stdcall;
    function GetClipboardData(dwReserved: Longint; out dataObject: IUnknown): HResult; stdcall;
    function DoVerb(iVerb: Longint; msg: PMsg; const activeSite: IOleClientSite;
      lindex: Longint; hwndParent: HWND; const posRect: TRect): HResult; stdcall;
    function EnumVerbs(out enumOleVerb: IUnknown): HResult; stdcall;
    function Update: HResult; stdcall;
    function IsUpToDate: HResult; stdcall;
    function GetUserClassID(out clsid: TGUID): HResult; stdcall;
    function GetUserType(dwFormOfType: Longint; out pszUserType: Pointer): HResult; stdcall;
    function SetExtent(dwDrawAspect: Longint; const size: TPoint): HResult; stdcall;
    function GetExtent(dwDrawAspect: Longint; out size: TPoint): HResult; stdcall;
    function Advise(const advSink: IUnknown; out dwConnection: Longint): HResult; stdcall;
    function Unadvise(dwConnection: Longint): HResult; stdcall;
    function EnumAdvise(out EnumAdvise: IUnknown): HResult; stdcall;
    function GetMiscStatus(dwAspect: Longint; out dwStatus: Longint): HResult; stdcall;
    function SetColorScheme(const logpal: TLogPalette): HResult; stdcall;
  end;
  IEnumConnections = interface
    ['{B196B287-BAB4-101A-B69C-00AA00341D07}']
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumConnections): HResult; stdcall;
  end;
  IEnumConnectionPoints = interface
    ['{B196B285-BAB4-101A-B69C-00AA00341D07}']
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumConnectionPoints): HResult; stdcall;
  end;
  IConnectionPoint = interface;
  IConnectionPointContainer = interface
    ['{B196B284-BAB4-101A-B69C-00AA00341D07}']
    function EnumConnectionPoints(out Enum: IEnumConnectionPoints): HResult; stdcall;
    function FindConnectionPoint(const iid: TGUID; out cp: IConnectionPoint): HResult; stdcall;
  end;
  IConnectionPoint = interface
    ['{B196B286-BAB4-101A-B69C-00AA00341D07}']
    function GetConnectionInterface(out iid: TGUID): HResult; stdcall;
    function GetConnectionPointContainer(out cpc: IConnectionPointContainer): HResult; stdcall;
    function Advise(const unkSink: IUnknown; out dwCookie: Longint): HResult; stdcall;
    function Unadvise(dwCookie: Longint): HResult; stdcall;
    function EnumConnections(out Enum: IEnumConnections): HResult; stdcall;
  end;

const
  VT_EMPTY    = 0; { [V]   [P]  nothing }
  VT_NULL     = 1; { [V]        SQL style Null }
  VT_I2       = 2; { [V][T][P]  2 byte signed int }
  VT_I4       = 3; { [V][T][P]  4 byte signed int }
  VT_R4       = 4; { [V][T][P]  4 byte real }
  VT_R8       = 5; { [V][T][P]  8 byte real }
  VT_CY       = 6; { [V][T][P]  currency }
  VT_DATE     = 7; { [V][T][P]  date }
  VT_BSTR     = 8; { [V][T][P]  binary string }
  VT_DISPATCH = 9; { [V][T]     IDispatch FAR* }
  VT_ERROR    = 10; { [V][T]     SCODE }
  VT_BOOL     = 11; { [V][T][P]  True=-1, False=0 }
  VT_VARIANT  = 12; { [V][T][P]  VARIANT FAR* }
  VT_UNKNOWN  = 13; { [V][T]     IUnknown FAR* }
  VT_DECIMAL  = 14; { [V][T]   [S]  16 byte fixed point }

  VT_I1          = 16; { [T]     signed char }
  VT_UI1         = 17; { [T]     unsigned char }
  VT_UI2         = 18; { [T]     unsigned short }
  VT_UI4         = 19; { [T]     unsigned long }
  VT_I8          = 20; { [T][P]  signed 64-bit int }
  VT_UI8         = 21; { [T]     unsigned 64-bit int }
  VT_INT         = 22; { [T]     signed machine int }
  VT_UINT        = 23; { [T]     unsigned machine int }
  VT_VOID        = 24; { [T]     C style void }
  VT_HRESULT     = 25; { [T] }
  VT_PTR         = 26; { [T]     pointer type }
  VT_SAFEARRAY   = 27; { [T]     (use VT_ARRAY in VARIANT) }
  VT_CARRAY      = 28; { [T]     C style array }
  VT_USERDEFINED = 29; { [T]     user defined type }
  VT_LPSTR       = 30; { [T][P]  null terminated string }
  VT_LPWSTR      = 31; { [T][P]  wide null terminated string }
  VT_RECORD      = 36; { [V]   [P][S]  user defined type }
  VT_INT_PTR     = 37; { [T]     signed machine register size width }
  VT_UINT_PTR    = 38; { [T]     unsigned machine register size width }

  VT_FILETIME         = 64; { [P]  FILETIME }
  VT_BLOB             = 65; { [P]  Length prefixed bytes }
  VT_STREAM           = 66; { [P]  Name of the stream follows }
  VT_STORAGE          = 67; { [P]  Name of the storage follows }
  VT_STREAMED_OBJECT  = 68; { [P]  Stream contains an object }
  VT_STORED_OBJECT    = 69; { [P]  Storage contains an object }
  VT_BLOB_OBJECT      = 70; { [P]  Blob contains an object }
  VT_CF               = 71; { [P]  Clipboard format }
  VT_CLSID            = 72; { [P]  A Class ID }
  VT_VERSIONED_STREAM = 73; { [P]  Stream with a GUID version }

  VT_VECTOR        = $1000; { [P]  simple counted array }
  VT_ARRAY         = $2000; { [V]        SAFEARRAY* }
  VT_BYREF         = $4000; { [V] }
  VT_RESERVED      = $8000;
  VT_ILLEGAL       = $FFFF;
  VT_ILLEGALMASKED = $0FFF;
  VT_TYPEMASK      = $0FFF;

type
{$ALIGN 1}
  PDecimal = ^TDecimal;
  tagDEC = record
    wReserved: Word;
    case Integer of
      0: (scale, sign: Byte; Hi32: Longint;
          case Integer of
            0: (Lo32, Mid32: Longint);
            1: (Lo64: LONGLONG)
         );
      1: (signscale: Word);
  end;
  TDecimal = tagDEC;
  DECIMAL = TDecimal;
{$ALIGN ON}
  PVariantArg = ^TVariantArg;
  tagVARIANT = record
    vt: TVarType;
    wReserved1: Word;
    wReserved2: Word;
    wReserved3: Word;
    case Integer of
      VT_UI1: (bVal: Byte);
      VT_I2: (iVal: Smallint);
      VT_I4: (lVal: Longint);
      VT_R4: (fltVal: Single);
      VT_R8: (dblVal: Double);
      VT_BOOL: (vbool: TOleBool);
      VT_ERROR: (scode: HResult);
      VT_CY: (cyVal: Currency);
      VT_DATE: (date: TOleDate);
      VT_BSTR: (bstrVal: PWideChar { WideString } );
      VT_UNKNOWN: (unkVal: Pointer { IUnknown } );
      VT_DISPATCH: (dispVal: Pointer { IDispatch } );
      VT_ARRAY: (parray: PSafeArray);
      VT_BYREF or VT_UI1: (pbVal: ^Byte);
      VT_BYREF or VT_I2: (piVal: ^Smallint);
      VT_BYREF or VT_I4: (plVal: ^Longint);
      VT_BYREF or VT_R4: (pfltVal: ^Single);
      VT_BYREF or VT_R8: (pdblVal: ^Double);
      VT_BYREF or VT_BOOL: (pbool: ^TOleBool);
      VT_BYREF or VT_ERROR: (pscode: ^HResult);
      VT_BYREF or VT_CY: (pcyVal: ^Currency);
      VT_BYREF or VT_DATE: (pdate: ^TOleDate);
      VT_BYREF or VT_BSTR: (pbstrVal: ^WideString);
      VT_BYREF or VT_UNKNOWN: (punkVal: ^IUnknown);
      VT_BYREF or VT_DISPATCH: (pdispVal: ^IDispatch);
      VT_BYREF or VT_ARRAY: (pparray: ^PSafeArray);
      VT_BYREF or VT_VARIANT: (pvarVal: PVariant);
      VT_BYREF: (byRef: Pointer);
      VT_I1: (cVal: AnsiChar);
      VT_UI2: (uiVal: Word);
      VT_UI4: (ulVal: LongWord);
      VT_I8: (llVal: Int64);
      VT_UI8: (ullVal: UInt64);
      VT_INT: (intVal: Integer);
      VT_UINT: (uintVal: LongWord);
      VT_BYREF or VT_DECIMAL: (pdecVal: PDecimal);
      VT_BYREF or VT_I1: (pcVal: PAnsiChar);
      VT_BYREF or VT_UI2: (puiVal: PWord);
      VT_BYREF or VT_UI4: (pulVal: PInteger);
      VT_BYREF or VT_INT: (pintVal: PInteger);
      VT_BYREF or VT_UINT: (puintVal: PLongWord);
      VT_BYREF or VT_I8: (pllVal: ^Int64);
      VT_BYREF or VT_UI8: (pullVal: ^UInt64);
      VT_RECORD: (pvRecord: Pointer; pRecInfo: Pointer);
  end;
  TVariantArg = tagVARIANT;
  PVariantArgList = ^TVariantArgList;
  TVariantArgList = array [0 .. 65535] of TVariantArg;

  TDispID = Longint;
  PDispIDList = ^TDispIDList;
  TDispIDList = array [0 .. 65535] of TDispID;

  PDispParams = ^TDispParams;
  tagDISPPARAMS = record
    rgvarg: PVariantArgList;
    rgdispidNamedArgs: PDispIDList;
    cArgs: Longint;
    cNamedArgs: Longint;
  end;
  TDispParams = tagDISPPARAMS;
  DISPPARAMS = TDispParams;

procedure OleUninitialize; stdcall;
function  OleInitialize(pwReserved: Pointer): HResult; stdcall;
function  CoCreateInstance(const clsid: TGUID; unkOuter: IUnknown; dwClsContext: Longint;
  const iid: TGUID; out pv): HResult; stdcall;
function  SafeArrayCreate(vt: TVarType; cDims: Integer; const rgsabound): PSafeArray; stdcall;
function  SafeArrayDestroy(psa: PSafeArray): HResult; stdcall;
procedure VariantInit(var varg: OleVariant); stdcall;
function  VariantClear(var varg: OleVariant): HResult; stdcall;

function  SysAllocString(psz: POleStr): POleStr; stdcall;
procedure SysFreeString(bstr: POleStr); stdcall;

const
  IID_IWebBrowser2: TGUID = '{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}';

type
  OLECMDID = TOleEnum;
  OLECMDF = TOleEnum;
  OLECMDEXECOPT = TOleEnum;
  tagREADYSTATE = TOleEnum;
const
  READYSTATE_UNINITIALIZED = $00000000;
  READYSTATE_LOADING       = $00000001;
  READYSTATE_LOADED        = $00000002;
  READYSTATE_INTERACTIVE   = $00000003;
  READYSTATE_COMPLETE      = $00000004;

type
  IWebBrowser = interface(IDispatch)
    ['{EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B}']
    procedure GoBack; safecall;
    procedure GoForward; safecall;
    procedure GoHome; safecall;
    procedure GoSearch; safecall;
    procedure Navigate(const URL: WideString; const Flags: OleVariant;
      const TargetFrameName: OleVariant; const PostData: OleVariant;
      const Headers: OleVariant); safecall;
    procedure Refresh; safecall;
    procedure Refresh2(var Level: OleVariant); safecall;
    procedure Stop; safecall;
    function  Get_Application: IDispatch; safecall;
    function  Get_Parent: IDispatch; safecall;
    function  Get_Container: IDispatch; safecall;
    function  Get_Document: IDispatch; safecall;
    function  Get_TopLevelContainer: WordBool; safecall;
    function  Get_Type_: WideString; safecall;
    function  Get_Left: Integer; safecall;
    procedure Set_Left(pl: Integer); safecall;
    function  Get_Top: Integer; safecall;
    procedure Set_Top(pl: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(pl: Integer); safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(pl: Integer); safecall;
    function  Get_LocationName: WideString; safecall;
    function  Get_LocationURL: WideString; safecall;
    function  Get_Busy: WordBool; safecall;
    property Application: IDispatch read Get_Application;
    property Parent: IDispatch read Get_Parent;
    property Container: IDispatch read Get_Container;
    property Document: IDispatch read Get_Document;
    property TopLevelContainer: WordBool read Get_TopLevelContainer;
    property Type_: WideString read Get_Type_;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property LocationName: WideString read Get_LocationName;
    property LocationURL: WideString read Get_LocationURL;
    property Busy: WordBool read Get_Busy;
  end;
  IWebBrowserApp = interface(IWebBrowser)
    ['{0002DF05-0000-0000-C000-000000000046}']
    procedure Quit; safecall;
    procedure ClientToWindow(var pcx: SYSINT; var pcy: SYSINT); safecall;
    procedure PutProperty(const Property_: WideString; vtValue: OleVariant); safecall;
    function GetProperty(const Property_: WideString): OleVariant; safecall;
    function Get_Name: WideString; safecall;
    function Get_HWnd: Integer; safecall;
    function Get_FullName: WideString; safecall;
    function Get_Path: WideString; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(pbool: WordBool); safecall;
    function Get_StatusBar: WordBool; safecall;
    procedure Set_StatusBar(pbool: WordBool); safecall;
    function Get_StatusText: WideString; safecall;
    procedure Set_StatusText(const StatusText: WideString); safecall;
    function Get_ToolBar: SYSINT; safecall;
    procedure Set_ToolBar(Value: SYSINT); safecall;
    function Get_MenuBar: WordBool; safecall;
    procedure Set_MenuBar(Value: WordBool); safecall;
    function Get_FullScreen: WordBool; safecall;
    procedure Set_FullScreen(pbFullScreen: WordBool); safecall;
    property Name: WideString read Get_Name;
    property HWND: Integer read Get_HWnd;
    property FullName: WideString read Get_FullName;
    property Path: WideString read Get_Path;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property StatusBar: WordBool read Get_StatusBar write Set_StatusBar;
    property StatusText: WideString read Get_StatusText write Set_StatusText;
    property ToolBar: SYSINT read Get_ToolBar write Set_ToolBar;
    property MenuBar: WordBool read Get_MenuBar write Set_MenuBar;
    property FullScreen: WordBool read Get_FullScreen write Set_FullScreen;
  end;
  IWebBrowser2 = interface(IWebBrowserApp)
    ['{D30C1661-CDAF-11D0-8A3E-00C04FC9E26E}']
    procedure Navigate2(const URL: OleVariant; const Flags: OleVariant;
      const TargetFrameName: OleVariant; const PostData: OleVariant;
      const Headers: OleVariant); safecall;
    function QueryStatusWB(cmdID: OLECMDID): OLECMDF; safecall;
    procedure ExecWB(cmdID: OLECMDID; cmdexecopt: OLECMDEXECOPT;
      var pvaIn: OleVariant; var pvaOut: OleVariant); safecall;
    procedure ShowBrowserBar(var pvaClsid: OleVariant; var pvarShow: OleVariant;
      var pvarSize: OleVariant); safecall;
    function Get_ReadyState: tagREADYSTATE; safecall;
    function Get_Offline: WordBool; safecall;
    procedure Set_Offline(pbOffline: WordBool); safecall;
    function Get_Silent: WordBool; safecall;
    procedure Set_Silent(pbSilent: WordBool); safecall;
    function Get_RegisterAsBrowser: WordBool; safecall;
    procedure Set_RegisterAsBrowser(pbRegister: WordBool); safecall;
    function Get_RegisterAsDropTarget: WordBool; safecall;
    procedure Set_RegisterAsDropTarget(pbRegister: WordBool); safecall;
    function Get_TheaterMode: WordBool; safecall;
    procedure Set_TheaterMode(pbRegister: WordBool); safecall;
    function Get_AddressBar: WordBool; safecall;
    procedure Set_AddressBar(Value: WordBool); safecall;
    function Get_Resizable: WordBool; safecall;
    procedure Set_Resizable(Value: WordBool); safecall;
    property ReadyState: tagREADYSTATE read Get_ReadyState;
    property Offline: WordBool read Get_Offline write Set_Offline;
    property Silent: WordBool read Get_Silent write Set_Silent;
    property RegisterAsBrowser: WordBool read Get_RegisterAsBrowser write Set_RegisterAsBrowser;
    property RegisterAsDropTarget: WordBool read Get_RegisterAsDropTarget write Set_RegisterAsDropTarget;
    property TheaterMode: WordBool read Get_TheaterMode write Set_TheaterMode;
    property AddressBar: WordBool read Get_AddressBar write Set_AddressBar;
    property Resizable: WordBool read Get_Resizable write Set_Resizable;
  end;
  pDocHostUIInfo = ^TDocHostUIInfo;
  TDocHostUIInfo = packed record
    cbSize: ULONG;
    dwFlags: DWORD;
    dwDoubleClick: DWORD;
    pchHostCss: polestr;
    pchHostNS: polestr;
  end;
  POleCmd = ^TOleCmd;
  _tagOLECMD = record
    cmdID: Cardinal;
    cmdf: Longint;
  end;
  OLECMD = _tagOLECMD;
  TOleCmd = _tagOLECMD;
  POleCmdText = ^TOleCmdText;
  _tagOLECMDTEXT = record
    cmdtextf: Longint;
    cwActual: Cardinal;
    cwBuf: Cardinal;         // size in wide chars of the buffer for text
    rgwz: array [0..0] of WideChar; // Array into which callee writes the text
  end;
  OLECMDTEXT = _tagOLECMDTEXT;
  TOleCmdText = _tagOLECMDTEXT;

  IOleCommandTarget = interface(IUnknown)
    ['{b722bccb-4e68-101b-a2bc-00aa00404770}']
    function QueryStatus(CmdGroup: PGUID; cCmds: Cardinal;
      prgCmds: POleCmd; CmdText: POleCmdText): HResult; stdcall;
    function Exec(CmdGroup: PGUID; nCmdID, nCmdexecopt: DWORD;
      const vaIn: OleVariant; var vaOut: OleVariant): HResult; stdcall;
  end;

  PClipFormat = ^TClipFormat;
  TClipFormat = Word;

  PDVTargetDevice = ^TDVTargetDevice;
  tagDVTARGETDEVICE = record
    tdSize: Longint;
    tdDriverNameOffset: Word;
    tdDeviceNameOffset: Word;
    tdPortNameOffset: Word;
    tdExtDevmodeOffset: Word;
    tdData: record end;
  end;
  TDVTargetDevice = tagDVTARGETDEVICE;
  DVTARGETDEVICE = TDVTargetDevice;

  PFormatEtc = ^TFormatEtc;
  tagFORMATETC = record
    cfFormat: TClipFormat;
    ptd: PDVTargetDevice;
    dwAspect: Longint;
    lindex: Longint;
    tymed: Longint;
  end;
  TFormatEtc = tagFORMATETC;
  FORMATETC = TFormatEtc;

  PStgMedium = ^TStgMedium;
  tagSTGMEDIUM = record
    tymed: Longint;
    case Integer of
      0: (hBitmap: HBitmap; unkForRelease: Pointer{IUnknown});
      1: (hMetaFilePict: THandle);
      2: (hEnhMetaFile: THandle);
      3: (hGlobal: HGlobal);
      4: (lpszFileName: POleStr);
      5: (stm: Pointer{IStream});
      6: (stg: Pointer{IStorage});
  end;
  TStgMedium = tagSTGMEDIUM;
  STGMEDIUM = TStgMedium;

  IEnumFORMATETC = interface(IUnknown)
    ['{00000103-0000-0000-C000-000000000046}']
    function Next(celt: Longint; out elt;
      pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out Enum: IEnumFormatEtc): HResult; stdcall;
  end;
  IPersist = interface(IUnknown)
    ['{0000010C-0000-0000-C000-000000000046}']
    function GetClassID(out classID: TCLSID): HResult; stdcall;
  end;
  IPersistStream = interface(IPersist)
    ['{00000109-0000-0000-C000-000000000046}']
    function IsDirty: HResult; stdcall;
    function Load(const stm: IStream): HResult; stdcall;
    function Save(const stm: IStream; fClearDirty: BOOL): HResult; stdcall;
    function GetSizeMax(out cbSize: Largeint): HResult; stdcall;
  end;
  PIMoniker = ^IMoniker;
  IMoniker = interface(IPersistStream)
    ['{0000000F-0000-0000-C000-000000000046}']
    function BindToObject(const bc: IBindCtx; const mkToLeft: IMoniker;
      const iidResult: TIID; out vResult): HResult; stdcall;
    function BindToStorage(const bc: IBindCtx; const mkToLeft: IMoniker;
      const iid: TIID; out vObj): HResult; stdcall;
    function Reduce(const bc: IBindCtx; dwReduceHowFar: Longint;
      mkToLeft: PIMoniker; out mkReduced: IMoniker): HResult; stdcall;
    function ComposeWith(const mkRight: IMoniker; fOnlyIfNotGeneric: BOOL;
      out mkComposite: IMoniker): HResult; stdcall;
    function Enum(fForward: BOOL; out enumMoniker: IEnumMoniker): HResult;
      stdcall;
    function IsEqual(const mkOtherMoniker: IMoniker): HResult; stdcall;
    function Hash(out dwHash: Longint): HResult; stdcall;
    function IsRunning(const bc: IBindCtx; const mkToLeft: IMoniker;
      const mkNewlyRunning: IMoniker): HResult; stdcall;
    function GetTimeOfLastChange(const bc: IBindCtx; const mkToLeft: IMoniker;
      out filetime: TFileTime): HResult; stdcall;
    function Inverse(out mk: IMoniker): HResult; stdcall;
    function CommonPrefixWith(const mkOther: IMoniker;
      out mkPrefix: IMoniker): HResult; stdcall;
    function RelativePathTo(const mkOther: IMoniker;
      out mkRelPath: IMoniker): HResult; stdcall;
    function GetDisplayName(const bc: IBindCtx; const mkToLeft: IMoniker;
      out pszDisplayName: POleStr): HResult; stdcall;
    function ParseDisplayName(const bc: IBindCtx; const mkToLeft: IMoniker;
      pszDisplayName: POleStr; out chEaten: Longint;
      out mkOut: IMoniker): HResult; stdcall;
    function IsSystemMoniker(out dwMksys: Longint): HResult; stdcall;
  end;
  IAdviseSink = interface(IUnknown)
    ['{0000010F-0000-0000-C000-000000000046}']
    procedure OnDataChange(const formatetc: TFormatEtc; const stgmed: TStgMedium);
      stdcall;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint);
      stdcall;
    procedure OnRename(const mk: IMoniker); stdcall;
    procedure OnSave; stdcall;
    procedure OnClose; stdcall;
  end;
  IDataObject = interface(IUnknown)
    ['{0000010E-0000-0000-C000-000000000046}']
    function GetData(const formatetcIn: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc; out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium; fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc: IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  end;
  IDropTarget = interface(IUnknown)
    ['{00000122-0000-0000-C000-000000000046}']
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
  end;
  IDocHostUIHandler = interface(IUnknown)
    ['{bd3f23c0-d43e-11cf-893b-00aa00bdce1a}']
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HRESULT; stdcall;
    function GetHostInfo(var pInfo: TDOCHOSTUIINFO): HRESULT; stdcall;
    function ShowUI(const dwID: DWORD; const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame; const pDoc: IOleInPlaceUIWindow): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless(const fEnable: BOOL): HRESULT; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function ResizeBorder(const prcBorder: PRECT; const pUIWindow: IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID; const nCmdID: DWORD): HRESULT; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD): HRESULT; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget; out ppDropTarget: IDropTarget): HRESULT; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HRESULT; stdcall;
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT; stdcall;
    function FilterDataObject(const pDO: IDataObject; out ppDORet: IDataObject): HRESULT; stdcall;
  end;

const
  DWebBrowserEvents2ID: TGUID = '{34A715A0-6587-11D0-924A-0020AFC7AC4D}';
type
  TArithmeticException = (exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision);
  TFPUException = type TArithmeticException;
  TSSEException = type TArithmeticException;
  TFPUExceptionMask = set of TFPUException;
  TSSEExceptionMask = set of TSSEException;

const
  exAllArithmeticExceptions = [exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow,exPrecision];
  DefaultExceptionFlags = [exInvalidOp, exZeroDivide, exOverflow];

function SetFPUExceptionMask(const Mask: TFPUExceptionMask): TFPUExceptionMask;
{$IF CompilerVersion > 18.5}
function SetSSEExceptionMask(const Mask: TSSEExceptionMask): TSSEExceptionMask;
{$IFEND}

type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TWebBrowserStatusTextChange = procedure(ASender: TObject; const Text: WideString) of object;
  TWebBrowserProgressChange = procedure(ASender: TObject; Progress: Integer; ProgressMax: Integer) of object;
  TWebBrowserCommandStateChange = procedure(ASender: TObject; Command: Integer; Enable: WordBool) of object;
  TWebBrowserTitleChange = procedure(ASender: TObject; const Text: WideString) of object;
  TWebBrowserPropertyChange = procedure(ASender: TObject; const szProperty: WideString) of object;
  TWebBrowserBeforeNavigate2 = procedure(ASender: TObject; const pDisp: IDispatch; 
                                                           const URL: OleVariant; 
                                                           const Flags: OleVariant; 
                                                           const TargetFrameName: OleVariant; 
                                                           const PostData: OleVariant; 
                                                           const Headers: OleVariant; 
                                                           var Cancel: WordBool) of object;
  TWebBrowserNewWindow2 = procedure(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool) of object;
  TWebBrowserNavigateComplete2 = procedure(ASender: TObject; const pDisp: IDispatch; 
                                                             const URL: OleVariant) of object;
  TWebBrowserDocumentComplete = procedure(ASender: TObject; const pDisp: IDispatch; 
                                                            const URL: OleVariant) of object;
  TWebBrowserOnVisible = procedure(ASender: TObject; Visible: WordBool) of object;
  TWebBrowserOnToolBar = procedure(ASender: TObject; ToolBar: WordBool) of object;
  TWebBrowserOnMenuBar = procedure(ASender: TObject; MenuBar: WordBool) of object;
  TWebBrowserOnStatusBar = procedure(ASender: TObject; StatusBar: WordBool) of object;
  TWebBrowserOnFullScreen = procedure(ASender: TObject; FullScreen: WordBool) of object;
  TWebBrowserOnTheaterMode = procedure(ASender: TObject; TheaterMode: WordBool) of object;
  TWebBrowserWindowSetResizable = procedure(ASender: TObject; Resizable: WordBool) of object;
  TWebBrowserWindowSetLeft = procedure(ASender: TObject; Left: Integer) of object;
  TWebBrowserWindowSetTop = procedure(ASender: TObject; Top: Integer) of object;
  TWebBrowserWindowSetWidth = procedure(ASender: TObject; Width: Integer) of object;
  TWebBrowserWindowSetHeight = procedure(ASender: TObject; Height: Integer) of object;
  TWebBrowserWindowClosing = procedure(ASender: TObject; IsChildWindow: WordBool; 
                                                         var Cancel: WordBool) of object;
  TWebBrowserClientToHostWindow = procedure(ASender: TObject; var CX: Integer; var CY: Integer) of object;
  TWebBrowserSetSecureLockIcon = procedure(ASender: TObject; SecureLockIcon: Integer) of object;
  TWebBrowserFileDownload = procedure(ASender: TObject; ActiveDocument: WordBool; 
                                                        var Cancel: WordBool) of object;
  TWebBrowserNavigateError = procedure(ASender: TObject; const pDisp: IDispatch; 
                                                         const URL: OleVariant; 
                                                         const Frame: OleVariant; 
                                                         const StatusCode: OleVariant; 
                                                         var Cancel: WordBool) of object;
  TWebBrowserPrintTemplateInstantiation = procedure(ASender: TObject; const pDisp: IDispatch) of object;
  TWebBrowserPrintTemplateTeardown = procedure(ASender: TObject; const pDisp: IDispatch) of object;
  TWebBrowserUpdatePageStatus = procedure(ASender: TObject; const pDisp: IDispatch; 
                                                            const nPage: OleVariant; 
                                                            const fDone: OleVariant) of object;
  TWebBrowserPrivacyImpactedStateChange = procedure(ASender: TObject; bImpacted: WordBool) of object;
  TWebBrowserNewWindow3 = procedure(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool; 
                                                      dwFlags: LongWord; 
                                                      const bstrUrlContext: WideString; 
                                                      const bstrUrl: WideString) of object;
  TWebBrowserSetPhishingFilterStatus = procedure(ASender: TObject; PhishingFilterStatus: Integer) of object;
  TWebBrowserWindowStateChanged = procedure(ASender: TObject; dwWindowStateFlags: LongWord; 
                                                              dwValidFlagsMask: LongWord) of object;
  TWebBrowserNewProcess = procedure(ASender: TObject; lCauseFlag: Integer; const pWB2: IDispatch; 
                                                      var Cancel: WordBool) of object;
  TWebBrowserThirdPartyUrlBlocked = procedure(ASender: TObject; const URL: OleVariant; 
                                                                dwCount: LongWord) of object;
  TWebBrowserRedirectXDomainBlocked = procedure(ASender: TObject; const pDisp: IDispatch; 
                                                                  const StartURL: OleVariant; 
                                                                  const RedirectURL: OleVariant; 
                                                                  const Frame: OleVariant; 
                                                                  const StatusCode: OleVariant) of object;
  TWebBrowserBeforeScriptExecute = procedure(ASender: TObject; const pDispWindow: IDispatch) of object;
  TWebBrowserWebWorkerStarted = procedure(ASender: TObject; dwUniqueID: LongWord; 
                                                            const bstrWorkerLabel: WideString) of object;
  TWebBrowserWebWorkerFinsihed = procedure(ASender: TObject; dwUniqueID: LongWord) of object;
  TWebBrowserGetExternal = procedure (Sender: TObject; out ppDispatch: IDispatch; var AResult: HRESULT) of object;
  
  TWebBrowserEx = class(TObject, IUnknown, IDispatch, IOleClientSite, IOleInPlaceSite, IDocHostUIHandler)
  private
    FOnStatusTextChange: TWebBrowserStatusTextChange;
    FOnProgressChange: TWebBrowserProgressChange;
    FOnCommandStateChange: TWebBrowserCommandStateChange;
    FOnDownloadBegin: TNotifyEvent;
    FOnDownloadComplete: TNotifyEvent;
    FOnTitleChange: TWebBrowserTitleChange;
    FOnPropertyChange: TWebBrowserPropertyChange;
    FOnBeforeNavigate2: TWebBrowserBeforeNavigate2;
    FOnNewWindow2: TWebBrowserNewWindow2;
    FOnNavigateComplete2: TWebBrowserNavigateComplete2;
    FOnDocumentComplete: TWebBrowserDocumentComplete;
    FOnQuit: TNotifyEvent;
    FOnVisible: TWebBrowserOnVisible;
    FOnToolBar: TWebBrowserOnToolBar;
    FOnMenuBar: TWebBrowserOnMenuBar;
    FOnStatusBar: TWebBrowserOnStatusBar;
    FOnFullScreen: TWebBrowserOnFullScreen;
    FOnTheaterMode: TWebBrowserOnTheaterMode;
    FOnWindowSetResizable: TWebBrowserWindowSetResizable;
    FOnWindowSetLeft: TWebBrowserWindowSetLeft;
    FOnWindowSetTop: TWebBrowserWindowSetTop;
    FOnWindowSetWidth: TWebBrowserWindowSetWidth;
    FOnWindowSetHeight: TWebBrowserWindowSetHeight;
    FOnWindowClosing: TWebBrowserWindowClosing;
    FOnClientToHostWindow: TWebBrowserClientToHostWindow;
    FOnSetSecureLockIcon: TWebBrowserSetSecureLockIcon;
    FOnFileDownload: TWebBrowserFileDownload;
    FOnNavigateError: TWebBrowserNavigateError;
    FOnPrintTemplateInstantiation: TWebBrowserPrintTemplateInstantiation;
    FOnPrintTemplateTeardown: TWebBrowserPrintTemplateTeardown;
    FOnUpdatePageStatus: TWebBrowserUpdatePageStatus;
    FOnPrivacyImpactedStateChange: TWebBrowserPrivacyImpactedStateChange;
    FOnNewWindow3: TWebBrowserNewWindow3;
    FOnSetPhishingFilterStatus: TWebBrowserSetPhishingFilterStatus;
    FOnWindowStateChanged: TWebBrowserWindowStateChanged;
    FOnNewProcess: TWebBrowserNewProcess;
    FOnThirdPartyUrlBlocked: TWebBrowserThirdPartyUrlBlocked;
    FOnRedirectXDomainBlocked: TWebBrowserRedirectXDomainBlocked;
    FOnBeforeScriptExecute: TWebBrowserBeforeScriptExecute;
    FOnWebWorkerStarted: TWebBrowserWebWorkerStarted;
    FOnWebWorkerFinsihed: TWebBrowserWebWorkerFinsihed;
    FOnGetExternal: TWebBrowserGetExternal;
    
    FConnected: Boolean;
    FCookie: Integer;
    FConnectionPoint: IConnectionPoint;
    FWebBrowser: IWebBrowser2;
    FHandle: HWND;
    FPrivateHandle: Boolean;
    FOleObject: IOleObject;
    FOleInPlaceObject: IOleInPlaceObject;
    FOleInPlaceActiveObject: IOleInPlaceActiveObject;
    FContextMenu: Boolean;
    FScrollBars: Boolean;
    FFlatScrollBars: Boolean;
    FEnable3DBorder: Boolean;
    function GetOffline: WordBool;
    function GetResizable: WordBool;
    function GetSilent: WordBool;
    function GetTheaterMode: WordBool;
    function GetDocument: OleVariant;
    procedure SetOffline(const Value: WordBool);
    procedure SetResizable(const Value: WordBool);
    procedure SetSilent(const Value: WordBool);
    procedure SetTheaterMode(const Value: WordBool);
  private
    // IDispatch(Events)
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const iid: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const iid: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
    procedure Disconnect;
  private
    // IUnknown
    function QueryInterface(const iid: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    // IOleClientSite
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint; out mk: IUnknown): HResult; stdcall;
    function GetContainer(out container: IUnknown): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
    // IOleWindow
    function GetWindow(out wnd: HWND): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    // IOleInPlaceSite
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out frame: IOleInPlaceFrame; out doc: IUnknown;
      out rcPosRect: TRect; out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult; stdcall;
    function Scroll(scrollExtent: TPoint): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(const rcPosRect: TRect): HResult; stdcall;
    function GetWBClientRect: TRect;
    { IDocHostUIHandler }
    function ShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HRESULT; stdcall;
    function GetHostInfo(var pInfo: TDOCHOSTUIINFO): HRESULT; stdcall;
    function ShowUI(const dwID: DWORD; const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HRESULT; stdcall;
    function HideUI: HRESULT; stdcall;
    function UpdateUI: HRESULT; stdcall;
    function EnableModeless(const fEnable: BOOL): HRESULT; stdcall;
    function OnDocWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function OnFrameWindowActivate(const fActivate: BOOL): HRESULT; stdcall;
    function ResizeBorder(const prcBorder: PRECT; const pUIWindow: IOleInPlaceUIWindow;
      const fRameWindow: BOOL): HRESULT; stdcall;
    function TranslateAccelerator(const lpMsg: PMSG; const pguidCmdGroup: PGUID;
      const nCmdID: DWORD): HRESULT; stdcall;
    function GetOptionKeyPath(var pchKey: POLESTR; const dw: DWORD): HRESULT; stdcall;
    function GetDropTarget(const pDropTarget: IDropTarget; out ppDropTarget: IDropTarget): HRESULT; stdcall;
    function GetExternal(out ppDispatch: IDispatch): HRESULT; stdcall;
    function TranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
       var ppchURLOut: POLESTR): HRESULT; stdcall;
    function FilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HRESULT; stdcall;
  protected
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); 
  public
    constructor Create(); overload; virtual;
    constructor Create(AParent: HWND); overload; virtual;
    constructor Create(AParent: HWND; ALeft, ATop, AWidth, AHeight: Integer); overload; virtual;
    constructor Create(AParent: HWND; const ABounds: TRect); overload; virtual;
    destructor Destroy; override;

    procedure Show();
    procedure Hide();

    procedure GoBack;
    procedure GoForward;
    procedure GoHome;
    procedure GoSearch;
    procedure Stop;
    procedure Quit;
    procedure Refresh;
    function  WaitComplete(TimeOut: Cardinal): HResult;
    procedure UpdateBounds(ALeft, ATop, AWidth, AHeight: Integer); overload;
    procedure UpdateBounds(const ARect: TRect); overload;
    procedure Navigate(const URL: WideString);
    function  Eval(const AScript: WideString): OleVariant;

    property WebBrowser: IWebBrowser2 read FWebBrowser;
    property Document: OleVariant read GetDocument;
    property Offline: WordBool read GetOffline write SetOffline;
    property Silent: WordBool read GetSilent write SetSilent;
    property TheaterMode: WordBool read GetTheaterMode write SetTheaterMode;
    property Resizable: WordBool read GetResizable write SetResizable;
    property ClientRect: TRect read GetWBClientRect;
    property ContextMenu: Boolean read FContextMenu write FContextMenu;
    property ScrollBars: Boolean read FScrollBars write FScrollBars;
    property FlatScrollBars: Boolean read FFlatScrollBars write FFlatScrollBars;
    property Enable3DBorder: Boolean read FEnable3DBorder write FEnable3DBorder;
    property OnStatusTextChange: TWebBrowserStatusTextChange read FOnStatusTextChange write FOnStatusTextChange;
    property OnProgressChange: TWebBrowserProgressChange read FOnProgressChange write FOnProgressChange;
    property OnCommandStateChange: TWebBrowserCommandStateChange read FOnCommandStateChange write FOnCommandStateChange;
    property OnDownloadBegin: TNotifyEvent read FOnDownloadBegin write FOnDownloadBegin;
    property OnDownloadComplete: TNotifyEvent read FOnDownloadComplete write FOnDownloadComplete;
    property OnTitleChange: TWebBrowserTitleChange read FOnTitleChange write FOnTitleChange;
    property OnPropertyChange: TWebBrowserPropertyChange read FOnPropertyChange write FOnPropertyChange;
    property OnBeforeNavigate2: TWebBrowserBeforeNavigate2 read FOnBeforeNavigate2 write FOnBeforeNavigate2;
    property OnNewWindow2: TWebBrowserNewWindow2 read FOnNewWindow2 write FOnNewWindow2;
    property OnNavigateComplete2: TWebBrowserNavigateComplete2 read FOnNavigateComplete2 write FOnNavigateComplete2;
    property OnDocumentComplete: TWebBrowserDocumentComplete read FOnDocumentComplete write FOnDocumentComplete;
    property OnQuit: TNotifyEvent read FOnQuit write FOnQuit;
    property OnVisible: TWebBrowserOnVisible read FOnVisible write FOnVisible;
    property OnToolBar: TWebBrowserOnToolBar read FOnToolBar write FOnToolBar;
    property OnMenuBar: TWebBrowserOnMenuBar read FOnMenuBar write FOnMenuBar;
    property OnStatusBar: TWebBrowserOnStatusBar read FOnStatusBar write FOnStatusBar;
    property OnFullScreen: TWebBrowserOnFullScreen read FOnFullScreen write FOnFullScreen;
    property OnTheaterMode: TWebBrowserOnTheaterMode read FOnTheaterMode write FOnTheaterMode;
    property OnWindowSetResizable: TWebBrowserWindowSetResizable read FOnWindowSetResizable write FOnWindowSetResizable;
    property OnWindowSetLeft: TWebBrowserWindowSetLeft read FOnWindowSetLeft write FOnWindowSetLeft;
    property OnWindowSetTop: TWebBrowserWindowSetTop read FOnWindowSetTop write FOnWindowSetTop;
    property OnWindowSetWidth: TWebBrowserWindowSetWidth read FOnWindowSetWidth write FOnWindowSetWidth;
    property OnWindowSetHeight: TWebBrowserWindowSetHeight read FOnWindowSetHeight write FOnWindowSetHeight;
    property OnWindowClosing: TWebBrowserWindowClosing read FOnWindowClosing write FOnWindowClosing;
    property OnClientToHostWindow: TWebBrowserClientToHostWindow read FOnClientToHostWindow write FOnClientToHostWindow;
    property OnSetSecureLockIcon: TWebBrowserSetSecureLockIcon read FOnSetSecureLockIcon write FOnSetSecureLockIcon;
    property OnFileDownload: TWebBrowserFileDownload read FOnFileDownload write FOnFileDownload;
    property OnNavigateError: TWebBrowserNavigateError read FOnNavigateError write FOnNavigateError;
    property OnPrintTemplateInstantiation: TWebBrowserPrintTemplateInstantiation read FOnPrintTemplateInstantiation write FOnPrintTemplateInstantiation;
    property OnPrintTemplateTeardown: TWebBrowserPrintTemplateTeardown read FOnPrintTemplateTeardown write FOnPrintTemplateTeardown;
    property OnUpdatePageStatus: TWebBrowserUpdatePageStatus read FOnUpdatePageStatus write FOnUpdatePageStatus;
    property OnPrivacyImpactedStateChange: TWebBrowserPrivacyImpactedStateChange read FOnPrivacyImpactedStateChange write FOnPrivacyImpactedStateChange;
    property OnNewWindow3: TWebBrowserNewWindow3 read FOnNewWindow3 write FOnNewWindow3;
    property OnSetPhishingFilterStatus: TWebBrowserSetPhishingFilterStatus read FOnSetPhishingFilterStatus write FOnSetPhishingFilterStatus;
    property OnWindowStateChanged: TWebBrowserWindowStateChanged read FOnWindowStateChanged write FOnWindowStateChanged;
    property OnNewProcess: TWebBrowserNewProcess read FOnNewProcess write FOnNewProcess;
    property OnThirdPartyUrlBlocked: TWebBrowserThirdPartyUrlBlocked read FOnThirdPartyUrlBlocked write FOnThirdPartyUrlBlocked;
    property OnRedirectXDomainBlocked: TWebBrowserRedirectXDomainBlocked read FOnRedirectXDomainBlocked write FOnRedirectXDomainBlocked;
    property OnBeforeScriptExecute: TWebBrowserBeforeScriptExecute read FOnBeforeScriptExecute write FOnBeforeScriptExecute;
    property OnWebWorkerStarted: TWebBrowserWebWorkerStarted read FOnWebWorkerStarted write FOnWebWorkerStarted;
    property OnWebWorkerFinsihed: TWebBrowserWebWorkerFinsihed read FOnWebWorkerFinsihed write FOnWebWorkerFinsihed;
    property OnGetExternal: TWebBrowserGetExternal read FOnGetExternal write FOnGetExternal;
  end;

function Navigate(const URL: WideString; const TimeOut: Cardinal = 15000): HResult;
procedure HandleIECompatible;

implementation

function Navigate(const URL: WideString; const TimeOut: Cardinal): HResult;
var
  wb: TWebBrowserEx;
begin
  Result := E_FAIL;
  OleInitialize(nil);
  wb := TWebBrowserEx.Create;
  try
    if wb.WebBrowser = nil then
      Exit;
    wb.Navigate(URL);
    Result := wb.WaitComplete(TimeOut);
  finally
    wb.Free;
    OleUninitialize;
  end;
end;

procedure HandleIECompatible;
  function GetIEFeatrueValue: Integer;
  var
    StrVer, StrVer1: string;
    IntPos, IntVer: Integer;
    DataType, DataSize: Cardinal;
    LKey: HKEY;
    LData: PChar;
  begin
    Result := 8000; //默认IE8，即使有问题也不会出错的
    if RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Internet Explorer', 0, KEY_READ, LKey) = ERROR_SUCCESS then
    begin
      DataType := REG_SZ;
      if RegQueryValueEx(LKey, 'Version', nil, @DataType, nil, @DataSize) = ERROR_SUCCESS then
      begin
        LData := AllocMem(DataSize);
        try
          RegQueryValueEx(LKey, 'Version', nil, @DataType, PByte(LData), @DataSize);
          StrVer := Trim(LData); //获取IE版本号
          IntPos := Pos('.', StrVer);
          if IntPos > 1 then
          begin
            StrVer1 := Copy(StrVer, 1, IntPos - 1);
            if TryStrToInt(StrVer1, IntVer) then
            begin
              //根据版本号检测改使用什么特征值
              case IntVer of
                8:  Result := 8000; //IE8
                9:
                begin
                  Result := 9999; //IE9
                  StrVer := Copy(StrVer, IntPos+1, MaxInt);
                  IntPos := Pos('.', StrVer);
                  if IntPos > 1 then
                  begin
                    StrVer1 := Copy(StrVer, 1, IntPos - 1);
                    if TryStrToInt(StrVer1, IntVer) then
                    begin
                      case IntVer of
                        10: Result := 10000; //IE10
                        11: Result := 11000; //IE11
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        finally
          FreeMem(LData);
        end;
      end;
      RegCloseKey(LKey);
    end;
  end;
  procedure WriteIEFeatureControl(const AKey, AName: string; const AValue: Integer; var Changed: Boolean);
  var
    iOldValue: Integer;
    LKey: HKEY;
    dwDataType, dwDataSize: Cardinal;
  begin
    if RegOpenKeyEx(HKEY_CURRENT_USER, PChar('Software\Microsoft\Internet Explorer\Main\FeatureControl\' + AKey),
      0, KEY_READ or KEY_WRITE, LKey) = ERROR_SUCCESS then
    try
      dwDataType := REG_DWORD;
      if RegQueryValueEx(LKey, PChar(AName), nil, @dwDataType, @iOldValue, @dwDataSize) <> ERROR_SUCCESS then
        iOldValue := -1;
      if iOldValue <> AValue then
        Changed := RegSetValueEx(LKey, PChar(AName), 0, dwDataType, @iOldValue, dwDataSize) = ERROR_SUCCESS;
    finally
      RegCloseKey(LKey);
    end;
  end;
const
  WM_SETTINGCHANGE = $001A;
var
  sRegName: string;
  iFeatrueValue: Integer;
  bChanged: Boolean;
begin
  bChanged := False;
  iFeatrueValue := GetIEFeatrueValue;
  sRegName := ExtractFileName(ParamStr(0));
  WriteIEFeatureControl('FEATURE_BROWSER_EMULATION', sRegName, iFeatrueValue, bChanged);
  WriteIEFeatureControl('FEATURE_ZONE_ELEVATION', sRegName, 1, bChanged);
  WriteIEFeatureControl('FEATURE_DISABLE_NAVIGATION_SOUNDS', sRegName, 1, bChanged);
  WriteIEFeatureControl('FEATURE_DOCUMENT_COMPATIBLE_MODE', sRegName, 1, bChanged);
  WriteIEFeatureControl('FEATURE_GPU_RENDERING', sRegName, 1, bChanged);
  if bChanged then
    PostMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 0);
end;

function SetFPUExceptionMask(const Mask: TFPUExceptionMask): TFPUExceptionMask;
var
  CtlWord: Word;
begin
  CtlWord := Get8087CW;
  Set8087CW((CtlWord and $FFC0) or Byte(Mask));
  Byte(Result) := CtlWord and $3F;
end;
{$IF CompilerVersion > 18.5}
function SetSSEExceptionMask(const Mask: TSSEExceptionMask): TSSEExceptionMask;
var
  MXCSR: Word;
begin
{$WARNINGS OFF}
  MXCSR := GetMXCSR;
  SetMXCSR((MXCSR and $FFFFE07F) or (Byte(Mask) shl 7));
  Byte(Result) := (MXCSR shr 7) and $3F;
{$WARNINGS ON}
end;
{$IFEND}

function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ARight;
    Bottom := ABottom;
  end;
end;

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect; 
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ALeft + AWidth;
    Bottom := ATop + AHeight;
  end;
end;

{$IFDEF DYNAMIC_LINK}
var
  _OleUninitialize: procedure; stdcall;
  _OleInitialize: function(pwReserved: Pointer): HResult; stdcall;
  _CoCreateInstance: function(const clsid: TGUID; unkOuter: IUnknown;
    dwClsContext: Longint; const iid: TGUID; out pv): HResult; stdcall;
  _SafeArrayCreate: function(vt: TVarType; cDims: Integer; const rgsabound)
    : PSafeArray; stdcall;
  _SafeArrayDestroy: function(psa: PSafeArray): HResult; stdcall;
  _VariantInit: procedure(var varg: OleVariant); stdcall;
  _VariantClear: function(var varg: OleVariant): HResult; stdcall;
  _SysAllocString: function(psz: POleStr): POleStr; stdcall;
  _SysFreeString: procedure(bstr: POleStr); stdcall;

procedure GetProcedureAddress(var P: Pointer; const ModuleName, ProcName: string);
var
  ModuleHandle: HMODULE;
begin
  if not Assigned(P) then
  begin
    ModuleHandle := GetModuleHandle(PChar(ModuleName));
    if ModuleHandle = 0 then
    begin
      ModuleHandle := LoadLibrary(PChar(ModuleName));
      if ModuleHandle = 0 then
        Exit;
    end;
    P := Pointer(GetProcAddress(ModuleHandle, PAnsiChar(AnsiString(ProcName))));
    if not Assigned(P) then
      Exit;
  end;
end;

procedure OleUninitialize; stdcall;
begin
  GetProcedureAddress(@_OleUninitialize, ole32, 'OleUninitialize');
  _OleUninitialize();
end;

function OleInitialize(pwReserved: Pointer): HResult; stdcall;
begin
  GetProcedureAddress(@_OleInitialize, ole32, 'OleInitialize');
  Result := _OleInitialize(pwReserved);
end;

function CoCreateInstance(const clsid: TGUID; unkOuter: IUnknown;
  dwClsContext: Longint; const iid: TGUID; out pv): HResult; stdcall;
begin
  GetProcedureAddress(@_CoCreateInstance, ole32, 'CoCreateInstance');
  Result := _CoCreateInstance(clsid, unkOuter, dwClsContext, iid, pv);
end;

function SafeArrayCreate(vt: TVarType; cDims: Integer; const rgsabound): PSafeArray; stdcall;
begin
  GetProcedureAddress(@_SafeArrayCreate, oleaut32, 'SafeArrayCreate');
  Result := _SafeArrayCreate(vt, cDims, rgsabound);
end;

function SafeArrayDestroy(psa: PSafeArray): HResult; stdcall;
begin
  GetProcedureAddress(@_SafeArrayDestroy, oleaut32, 'SafeArrayDestroy');
  Result := _SafeArrayDestroy(psa);
end;

procedure VariantInit(var varg: OleVariant); stdcall;
begin
  GetProcedureAddress(@_VariantInit, oleaut32, 'VariantInit');
  _VariantInit(varg);
end;

function VariantClear(var varg: OleVariant): HResult; stdcall;
begin
  GetProcedureAddress(@_VariantClear, oleaut32, 'VariantClear');
  Result := _VariantClear(varg);
end;

function SysAllocString(psz: POleStr): POleStr; stdcall;
begin
  GetProcedureAddress(@_SysAllocString, oleaut32, 'SysAllocString');
  Result := _SysAllocString(psz);
end;

procedure SysFreeString(bstr: POleStr); stdcall;
begin
  GetProcedureAddress(@_SysFreeString, oleaut32, 'SysFreeString');
  _SysFreeString(bstr);
end;

{$ELSE}
procedure OleUninitialize; stdcall; external ole32;
function OleInitialize; stdcall; external ole32;
function CoCreateInstance; stdcall; external ole32;
function SafeArrayCreate; stdcall; external oleaut32;
function SafeArrayDestroy; stdcall; external oleaut32;
procedure VariantInit; stdcall; external oleaut32;
function VariantClear; stdcall; external oleaut32;
function SysAllocString; stdcall; external oleaut32;
procedure SysFreeString; stdcall; external oleaut32;
{$ENDIF}

type
  TWndMethod = Pointer;
var
  WebBrowserWndClass: TWndClass = (style: 0; lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0; cbWndExtra: 0; hInstance: 0; hIcon: 0; hCursor: 0;
    hbrBackground: 0; lpszMenuName: nil; lpszClassName: 'WebBrowserEx_38CFEEA7C831');

function AllocateHWnd(const AMethod: TWndMethod): HWND;
var
  TempClass: TWndClass;
begin
  { 使用DefWindowProc默认窗口处理过程,AMethod是被忽略的.
    之所以留这个是为了代码兼容真正的Classes单元的AllocateHWnd函数.
  }
  WebBrowserWndClass.hInstance := hInstance;
  if not GetClassInfo(hInstance, WebBrowserWndClass.lpszClassName, TempClass) then
    Windows.RegisterClass(WebBrowserWndClass);
  Result := CreateWindowEx(WS_EX_TOOLWINDOW, WebBrowserWndClass.lpszClassName,
    '', WS_POPUP { + 0 } , 0, 0, 0, 0, 0, 0, hInstance, nil);
end;

procedure DeallocateHWnd(wnd: HWND);
begin
  DestroyWindow(wnd);
end;

constructor TWebBrowserEx.Create();
begin
  FPrivateHandle := true;
  Create(AllocateHWnd(nil));
end;

constructor TWebBrowserEx.Create(AParent: HWND);
var
  r: TRect;
begin
  GetClientRect(AParent, r);
  Create(AParent, r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
end;

constructor TWebBrowserEx.Create(AParent: HWND; ALeft, ATop, AWidth, AHeight: Integer);
var
  ConnectionPointContainer: IConnectionPointContainer;
begin
  FHandle := AParent;
  if (CoCreateInstance(CLSID_WebBrowser, nil, CLSCTX_INPROC, IID_IOleObject, FOleObject) <> S_OK)
    or (FOleObject.SetClientSite(Self) <> S_OK)
    or (FOleObject.DoVerb(OLEIVERB_INPLACEACTIVATE, nil, Self, 0, 0, PRect(nil)^) <> S_OK)
    or (FOleObject.QueryInterface(IID_IWebBrowser2, FWebBrowser) <> S_OK) then
    Exit;
  FWebBrowser.Set_Left(ALeft);
  FWebBrowser.Set_Top(ATop);
  FWebBrowser.Set_Width(AWidth);
  FWebBrowser.Set_Height(AHeight);
  FWebBrowser.Set_Silent(true);
  FConnected := (FWebBrowser.QueryInterface(IConnectionPointContainer, ConnectionPointContainer) = S_OK)
    and (ConnectionPointContainer.FindConnectionPoint(DWebBrowserEvents2ID, FConnectionPoint) = S_OK)
    and (FConnectionPoint.Advise(Self, FCookie) = S_OK);
  ConnectionPointContainer := nil;
  if FConnected then
  begin
    Show;
    //Navigate('about:blank');
  end;
end;

constructor TWebBrowserEx.Create(AParent: HWND; const ABounds: TRect);
begin
  Create(AParent, ABounds.Left, ABounds.Top, ABounds.Right-ABounds.Left-1, ABounds.Bottom-ABounds.Top-1);
end;

destructor TWebBrowserEx.Destroy;
begin
  if FConnected then
    Disconnect;
  if FOleObject <> nil then
    FOleObject.SetClientSite(nil);
  FOleObject := nil;
  FOleInPlaceObject := nil;
  FOleInPlaceActiveObject := nil;
  if FPrivateHandle then
    DeallocateHWnd(FHandle);
  FPrivateHandle := False;
  inherited;
end;

procedure TWebBrowserEx.Navigate(const URL: WideString);
var
  v: OleVariant;
begin
  v := EmptyParam;
  FWebBrowser.Navigate(URL, EmptyParam, EmptyParam, v, EmptyParam);
end;

procedure TWebBrowserEx.Hide;
begin
  FOleObject.DoVerb(OLEIVERB_HIDE, nil, Self, -1, FHandle, ClientRect);
end;

procedure TWebBrowserEx.Show;
begin
  FOleObject.DoVerb(OLEIVERB_SHOW, nil, Self, -1, FHandle, ClientRect);
end;

procedure TWebBrowserEx.Disconnect;
begin
  if FConnected then
  begin
    if FConnectionPoint <> nil then
      FConnectionPoint.Unadvise(FCookie);
    FWebBrowser := nil;
    FConnectionPoint := nil;
    FConnected := False;
  end;
end;

function TWebBrowserEx.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Count := 0;
  Result := S_OK;
end;

function TWebBrowserEx.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Pointer(TypeInfo) := nil;
  Result := E_NOTIMPL;
end;

function TWebBrowserEx.GetIDsOfNames(const iid: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowserEx.Invoke(DispID: Integer; const iid: TGUID; LocaleID: Integer; 
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
var
  i: integer;
  vVarArray : TVariantArray;

  vPVarArgIn: PVariantArg;
  vPDispParams: PDispParams;
  vFistArrItem, vLastArrItem: integer;
begin
  vPDispParams := PDispParams(@Params);     // DispParams
  SetLength(vVarArray, vPDispParams.cArgs); // set our array to appropriate length
  // array boundaries
  vFistArrItem := Low(vVarArray); vLastArrItem := High(vVarArray);
  if vPDispParams.cNamedArgs > 0 then
    // Copy over data from Params in NamedArgs order
    for i := vFistArrItem to vLastArrItem do
    begin
      vPVarArgIn := @vPDispParams.rgvarg[i];
      vVarArray[vPDispParams.rgdispidNamedArgs[i]] := POleVariant(vPVarArgIn)^;
    end
  else
    // Copy over data from Params in reverse order
    for i := vFistArrItem to vLastArrItem do
    begin
      vPVarArgIn := @vPDispParams.rgvarg[i];
      vVarArray[vLastArrItem - i] := POleVariant(vPVarArgIn)^;
    end;

  // Invoke Server proxy class
  InvokeEvent(DispID, vVarArray);

  if vPDispParams.cNamedArgs > 0 then
    // Copy data back to DispParams if Item passed by reference (NamedArgs order)
    for i := vFistArrItem to vLastArrItem do
    begin
      vPVarArgIn := @vPDispParams.rgvarg[i];
      if (vPVarArgIn.vt and varByRef) <> varByRef then
        Continue;
      POleVariant(vPVarArgIn)^ := vVarArray[vPDispParams.rgdispidNamedArgs[i]];
    end
  else
    // Copy data back to DispParams if Item passed by reference (reverse order)
    for i := vFistArrItem to vLastArrItem do
    begin
      vPVarArgIn := @vPDispParams.rgvarg[i];
      if (vPVarArgIn.vt and varByRef) <> varByRef then
        Continue;
      POleVariant(vPVarArgIn)^ := vVarArray[vLastArrItem - i];
    end;

  // Clean array
  SetLength(vVarArray, 0);
  // Pascal Events return 'void' - so assume success!
  Result := S_OK;
end;

// IUnknow
function TWebBrowserEx.QueryInterface(const iid: TGUID; out Obj): HResult;
begin
  if GetInterface(iid, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TWebBrowserEx._AddRef: Integer;
begin
  Result := -1;
end;

function TWebBrowserEx._Release: Integer;
begin
  Result := -1;
end;
// IOleWindow

function TWebBrowserEx.GetWindow(out wnd: HWND): HResult;
begin
  wnd := FHandle;
  Result := S_OK;
end;

function TWebBrowserEx.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

// IOleInPlaceSite

function TWebBrowserEx.CanInPlaceActivate: HResult;
begin
  Result := S_OK;
end;

function TWebBrowserEx.OnInPlaceActivate: HResult;
begin
  FOleObject.QueryInterface(IOleInPlaceObject, FOleInPlaceObject);
  FOleObject.QueryInterface(IOleInPlaceActiveObject, FOleInPlaceActiveObject);
  Result := S_OK;
end;

function TWebBrowserEx.OnUIActivate: HResult;
begin
  Result := S_OK;
end;

function TWebBrowserEx.GetWBClientRect: TRect;
begin
  Result := Bounds(0, 0, 0, 0);
  if FWebBrowser <> nil then
    with FWebBrowser do
      Result := Bounds(Get_Left, Get_Top, Get_Width, Get_Height);
end;

function TWebBrowserEx.GetWindowContext(out frame: IOleInPlaceFrame;
  out doc: IUnknown; out rcPosRect, rcClipRect: TRect;
  out frameInfo: TOleInPlaceFrameInfo): HResult;
begin
  /// frame := Self;
  frameInfo.fMDIApp := False;
  frameInfo.hwndFrame := FHandle;
  frameInfo.haccel := 0;
  frameInfo.cAccelEntries := 0;
  rcClipRect := Rect(0, 0, 32767, 32767);
  Result := S_OK;
end;

function TWebBrowserEx.Scroll(scrollExtent: TPoint): HResult;
begin
  Result := E_NOTIMPL;
end;

procedure TWebBrowserEx.UpdateBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if WebBrowser <> nil then
    with WebBrowser do
    begin
      Set_Left(ALeft);
      Set_Top(ATop);
      Set_Width(AWidth);
      Set_Height(AHeight);
    end;
end;

procedure TWebBrowserEx.UpdateBounds(const ARect: TRect);
begin
  UpdateBounds(ARect.Left, ARect.Top, ARect.Right-ARect.Left-1, ARect.Bottom-ARect.Top-1);
end;

function TWebBrowserEx.OnUIDeactivate(fUndoable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TWebBrowserEx.OnInPlaceDeactivate: HResult;
begin
  FOleInPlaceActiveObject := nil;
  FOleInPlaceObject := nil;
  Result := S_OK;
end;

function TWebBrowserEx.DiscardUndoState: HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowserEx.DeactivateAndUndo: HResult;
begin
  FOleInPlaceObject.UIDeactivate;
  Result := S_OK;
end;

function TWebBrowserEx.OnPosRectChange(const rcPosRect: TRect): HResult;
begin
  FOleInPlaceObject.SetObjectRects(rcPosRect, Rect(0, 0, 32767, 32767));
  Result := S_OK;
end;

// IOleClientSite
function TWebBrowserEx.SaveObject: HResult;
begin
  Result := S_OK;
end;

function TWebBrowserEx.GetMoniker(dwAssign, dwWhichMoniker: Integer; out mk: IUnknown): HResult;
begin
  // mk := nil;
  Result := E_NOTIMPL;
end;

function TWebBrowserEx.GetContainer(out container: IUnknown): HResult;
begin
  // container := nil;
  Result := E_NOINTERFACE;
end;

function TWebBrowserEx.ShowObject: HResult;
begin
  Result := S_OK;
end;

function TWebBrowserEx.OnShowWindow(fShow: BOOL): HResult;
begin
  Result := S_OK;
end;

function TWebBrowserEx.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

function TWebBrowserEx.WaitComplete(TimeOut: Cardinal): HResult;
const
  WM_QUIT = $0012;
var
  startTime: Cardinal;
  Unicode, MsgExists: Boolean;
  msg: TMsg;
begin
  Result := E_FAIL;
  startTime := GetTickCount;
  while true do
  begin
    if FWebBrowser.ReadyState = READYSTATE_COMPLETE then
    begin
      Result := S_OK;
      Break;
    end;
    if (TimeOut <> INFINITE) and ((GetTickCount - startTime) > TimeOut) then
    begin
      Result := ERROR_TIMEOUT;
      Break;
    end;
    // 处理消息循环.如果多线程的话也是可以的.
    while PeekMessage(msg, 0, 0, 0, PM_NOREMOVE) do
    begin
      Unicode := (msg.HWND = 0) or IsWindowUnicode(msg.HWND);
      if Unicode then
        MsgExists := PeekMessageW(msg, 0, 0, 0, PM_REMOVE)
      else
        MsgExists := PeekMessageA(msg, 0, 0, 0, PM_REMOVE);
      if MsgExists then
      begin
        if msg.Message = WM_QUIT then
          Break
        else
        begin
          TranslateMessage(msg);
          if Unicode then
            DispatchMessageW(msg)
          else
            DispatchMessageA(msg);
        end;
      end;
    end;
    Sleep(1);
  end;
end;

procedure TWebBrowserEx.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
    102:
    begin
      if Assigned(FOnStatusTextChange) then
         FOnStatusTextChange(Self, Params[0] {const WideString});
    end;
    108: if Assigned(FOnProgressChange) then
         FOnProgressChange(Self,
                           Params[0] {Integer},
                           Params[1] {Integer});
    105: if Assigned(FOnCommandStateChange) then
         FOnCommandStateChange(Self,
                               Params[0] {Integer},
                               Params[1] {WordBool});
    106: if Assigned(FOnDownloadBegin) then
         FOnDownloadBegin(Self);
    104: if Assigned(FOnDownloadComplete) then
         FOnDownloadComplete(Self);
    113: if Assigned(FOnTitleChange) then
         FOnTitleChange(Self, Params[0] {const WideString});
    112: if Assigned(FOnPropertyChange) then
         FOnPropertyChange(Self, Params[0] {const WideString});
    250: if Assigned(FOnBeforeNavigate2) then
         FOnBeforeNavigate2(Self,
                            Params[0] {const IDispatch},
                            Params[1] {const OleVariant},
                            Params[2] {const OleVariant},
                            Params[3] {const OleVariant},
                            Params[4] {const OleVariant},
                            Params[5] {const OleVariant},
                            WordBool((TVarData(Params[6]).VPointer)^) {var WordBool});
    251: if Assigned(FOnNewWindow2) then
         FOnNewWindow2(Self,
                       IDispatch((TVarData(Params[0]).VPointer)^) {var IDispatch},
                       WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
    252: if Assigned(FOnNavigateComplete2) then
         FOnNavigateComplete2(Self,
                              Params[0] {const IDispatch},
                              Params[1] {const OleVariant});
    259: if Assigned(FOnDocumentComplete) then
         FOnDocumentComplete(Self,
                             Params[0] {const IDispatch},
                             Params[1] {const OleVariant});
    253: if Assigned(FOnQuit) then
         FOnQuit(Self);
    254: if Assigned(FOnVisible) then
         FOnVisible(Self, Params[0] {WordBool});
    255: if Assigned(FOnToolBar) then
         FOnToolBar(Self, Params[0] {WordBool});
    256: if Assigned(FOnMenuBar) then
         FOnMenuBar(Self, Params[0] {WordBool});
    257: if Assigned(FOnStatusBar) then
         FOnStatusBar(Self, Params[0] {WordBool});
    258: if Assigned(FOnFullScreen) then
         FOnFullScreen(Self, Params[0] {WordBool});
    260: if Assigned(FOnTheaterMode) then
         FOnTheaterMode(Self, Params[0] {WordBool});
    262: if Assigned(FOnWindowSetResizable) then
         FOnWindowSetResizable(Self, Params[0] {WordBool});
    264: if Assigned(FOnWindowSetLeft) then
         FOnWindowSetLeft(Self, Params[0] {Integer});
    265: if Assigned(FOnWindowSetTop) then
         FOnWindowSetTop(Self, Params[0] {Integer});
    266: if Assigned(FOnWindowSetWidth) then
         FOnWindowSetWidth(Self, Params[0] {Integer});
    267: if Assigned(FOnWindowSetHeight) then
         FOnWindowSetHeight(Self, Params[0] {Integer});
    263: if Assigned(FOnWindowClosing) then
         FOnWindowClosing(Self,
                          Params[0] {WordBool},
                          WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
    268: if Assigned(FOnClientToHostWindow) then
         FOnClientToHostWindow(Self,
                               Integer((TVarData(Params[0]).VPointer)^) {var Integer},
                               Integer((TVarData(Params[1]).VPointer)^) {var Integer});
    269: if Assigned(FOnSetSecureLockIcon) then
         FOnSetSecureLockIcon(Self, Params[0] {Integer});
    270: if Assigned(FOnFileDownload) then
         FOnFileDownload(Self,
                         Params[0] {WordBool},
                         WordBool((TVarData(Params[1]).VPointer)^) {var WordBool});
    271: if Assigned(FOnNavigateError) then
         FOnNavigateError(Self,
                          Params[0] {const IDispatch},
                          Params[1] {const OleVariant},
                          Params[2] {const OleVariant},
                          Params[3] {const OleVariant},
                          WordBool((TVarData(Params[4]).VPointer)^) {var WordBool});
    225: if Assigned(FOnPrintTemplateInstantiation) then
         FOnPrintTemplateInstantiation(Self, Params[0] {const IDispatch});
    226: if Assigned(FOnPrintTemplateTeardown) then
         FOnPrintTemplateTeardown(Self, Params[0] {const IDispatch});
    227: if Assigned(FOnUpdatePageStatus) then
         FOnUpdatePageStatus(Self,
                             Params[0] {const IDispatch},
                             Params[1] {const OleVariant},
                             Params[2] {const OleVariant});
    272: if Assigned(FOnPrivacyImpactedStateChange) then
         FOnPrivacyImpactedStateChange(Self, Params[0] {WordBool});
    273: if Assigned(FOnNewWindow3) then
         FOnNewWindow3(Self,
                       IDispatch((TVarData(Params[0]).VPointer)^) {var IDispatch},
                       WordBool((TVarData(Params[1]).VPointer)^) {var WordBool},
                       Params[2] {LongWord},
                       Params[3] {const WideString},
                       Params[4] {const WideString});
    282: if Assigned(FOnSetPhishingFilterStatus) then
         FOnSetPhishingFilterStatus(Self, Params[0] {Integer});
    283: if Assigned(FOnWindowStateChanged) then
         FOnWindowStateChanged(Self,
                               Params[0] {LongWord},
                               Params[1] {LongWord});
    284: if Assigned(FOnNewProcess) then
         FOnNewProcess(Self,
                       Params[0] {Integer},
                       Params[1] {const IDispatch},
                       WordBool((TVarData(Params[2]).VPointer)^) {var WordBool});
    285: if Assigned(FOnThirdPartyUrlBlocked) then
         FOnThirdPartyUrlBlocked(Self,
                                 Params[0] {const OleVariant},
                                 Params[1] {LongWord});
    286: if Assigned(FOnRedirectXDomainBlocked) then
         FOnRedirectXDomainBlocked(Self,
                                   Params[0] {const IDispatch},
                                   Params[1] {const OleVariant},
                                   Params[2] {const OleVariant},
                                   Params[3] {const OleVariant},
                                   Params[4] {const OleVariant});
    290: if Assigned(FOnBeforeScriptExecute) then
         FOnBeforeScriptExecute(Self, Params[0] {const IDispatch});
    288: if Assigned(FOnWebWorkerStarted) then
         FOnWebWorkerStarted(Self,
                             Params[0] {LongWord},
                             Params[1] {const WideString});
    289: if Assigned(FOnWebWorkerFinsihed) then
         FOnWebWorkerFinsihed(Self, Params[0] {LongWord});
  end; {case DispID}
end;

function TWebBrowserEx.EnableModeless(const fEnable: BOOL): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.FilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.GetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.GetExternal(out ppDispatch: IDispatch): HRESULT;
begin
  Result := E_NOTIMPL;
  if @FOnGetExternal <> nil then
    FOnGetExternal(Self, ppDispatch, Result);
end;

function TWebBrowserEx.GetHostInfo(var pInfo: TDOCHOSTUIINFO): HRESULT;
begin
  pInfo.cbSize := SizeOf(pInfo);
  pInfo.dwFlags := 0;
  if not FScrollBars then
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_SCROLL_NO;
  if FFlatScrollBars then
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_FLAT_SCROLLBAR;
  if not FEnable3DBorder then
    pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_NO3DBORDER;
  result := S_OK;
end;

function TWebBrowserEx.GetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.HideUI: HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.OnDocWindowActivate(const fActivate: BOOL): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.OnFrameWindowActivate(
  const fActivate: BOOL): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.ResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fRameWindow: BOOL): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.ShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HRESULT;
begin
  if FContextMenu then
    result := S_FALSE
  else
    result := S_OK;
end;

function TWebBrowserEx.ShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.TranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.TranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.UpdateUI: HRESULT;
begin
  result := S_FALSE;
end;

function TWebBrowserEx.GetOffline: WordBool;
begin
  Result := FWebBrowser.Offline;
end;

function TWebBrowserEx.GetResizable: WordBool;
begin
  Result := FWebBrowser.Resizable;
end;

function TWebBrowserEx.GetSilent: WordBool;
begin
  Result := FWebBrowser.Silent;
end;

function TWebBrowserEx.GetTheaterMode: WordBool;
begin
  Result := FWebBrowser.TheaterMode;
end;

procedure TWebBrowserEx.SetOffline(const Value: WordBool);
begin
  FWebBrowser.Offline := Value;
end;

procedure TWebBrowserEx.SetResizable(const Value: WordBool);
begin
  FWebBrowser.Resizable := Value;
end;

procedure TWebBrowserEx.SetSilent(const Value: WordBool);
begin
  FWebBrowser.Silent := Value;
end;

procedure TWebBrowserEx.SetTheaterMode(const Value: WordBool);
begin
  FWebBrowser.TheaterMode := Value;
end;

function TWebBrowserEx.Eval( const AScript: WideString): OleVariant;
begin
  Result := Document.parentWindow.execScript(AScript,'JavaScript');
end;

function TWebBrowserEx.GetDocument: OleVariant;
begin
  Result := FWebBrowser.Document;
end;

procedure TWebBrowserEx.GoBack;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.GoBack;
end;

procedure TWebBrowserEx.GoForward;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.GoForward;
end;

procedure TWebBrowserEx.GoHome;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.GoHome;
end;

procedure TWebBrowserEx.GoSearch;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.GoSearch;
end;

procedure TWebBrowserEx.Quit;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.Quit;
end;

procedure TWebBrowserEx.Stop;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.Stop;
end;

procedure TWebBrowserEx.Refresh;
begin
  if FWebBrowser = nil then Exit;
  FWebBrowser.Refresh;
end;





initialization
  OleInitialize(nil);
  HandleIECompatible;

finalization
  OleUninitialize;

end.
