{*******************************************************************************
 标题:     SciterLayout.pas
 描述:     Sciter布局(视图)窗口实现单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterLayout;

interface

{$I Sciter.inc}

uses
  SysUtils, Windows, Classes, Messages, SciterTypes, SciterDom, SciterIntf, 
  SciterPluginImpl, TiscriptIntf, SciterHash, SciterImpl, SciterPluginIntf,
  SciterURIIntf;

const
  PROPNAME_LAYOUT = 'SciterLayout-20567420FE95';

type
  TSciterLayout = class(TInterfacedObject, ISciterLayout)
  private
    FSciter: TSciter;
    FThis: Pointer;
    FHookHandle: HWND;
    FBehaviorFactorys: IBehaviorFactorys;
    FBehavior: IDefalutBehaviorEventHandler;
    FBaseUri: SciterString;
    FHomeURL: SciterString;
    FSetuping: Boolean;
    FOptions: TSciterLayoutOptions;
    FDestroying: Boolean;

    FData1: Pointer;
    FData2: Pointer;
    FData3: IInterface;

    FBeforeWndProcList: TMethodList;
    FAfterWndProcList: TMethodList;
    
    FOnAttachBehavior: TLayoutAttachBehaviorProc;
    FAfterCreateBehavior: TLayoutAfterCreateBehaviorProc;
    FOnDataLoaded: TLayoutDataLoadedProc;
    FOnEngineDestroyed: TLayoutEngineDestroyedProc;
    FOnLoadData: TLayoutLoadDataProc;
    FOnNotification: TLayoutNotificationProc;
    FOnPostedNotification: TLayoutPostedNotificationProc;
    FOnCreateNativeObject: TLayoutCreateNativeObjectProc;
    FOnGraphicsCriticalFailure: TLayoutGraphicsCriticalFailure;
    FAfterWndProc: TLayoutAfterWndProc;
    FBeforeWndProc: TLayoutBeforeWndProc;
  private
    function GetCurrentNS: tiscript_value;
    function GetGlobalNS: tiscript_value;
    function GetBaseUri: SciterString;
    function GetHomeURL: SciterString;
    function GetHtml: SciterString;
    function GetHwnd: HWINDOW; virtual;
    function GetHookWnd: HWINDOW;
    function GetHVM: HVM;
    function GetMaxToFullScreen: Boolean;
    function GetResourceInstance: HMODULE; virtual;
    function GetThis: ISciterBase;
    function GetIsValid: Boolean;
    function GetPPI: TSciterGetPPIInfo;
    function GetRootElement: IDomElement;
    function GetFocusElement: IDomElement;
    function GetHighlightElement: IDomElement;
    function GetElementByUID(const uid: UINT): IDomElement;
    function GetMinHeight: UINT;
    function GetMinHeightEx(const width: UINT): UINT;
    function GetMinWidth: UINT;
    function GetViewExpando: IDomValue;
    function GetOptions: TSciterLayoutOptions;
    function GetBehavior: IDefalutBehaviorEventHandler;
    function GetBehaviorFactorys: IBehaviorFactorys;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetData3: IInterface;
    function GetOnAttachBehavior: TLayoutAttachBehaviorProc;
    function GetAfterCreateBehavior: TLayoutAfterCreateBehaviorProc;
    function GetOnDataLoaded: TLayoutDataLoadedProc;
    function GetOnEngineDestroyed: TLayoutEngineDestroyedProc;
    function GetOnLoadData: TLayoutLoadDataProc;
    function GetOnNotification: TLayoutNotificationProc;
    function GetOnPostedNotification: TLayoutPostedNotificationProc;
    function GetOnCreateNativeObject: TLayoutCreateNativeObjectProc;
    function GetOnGraphicsCriticalFailure: TLayoutGraphicsCriticalFailure;
    function GetAfterWndProc: TLayoutAfterWndProc;
    function GetBeforeWndProc: TLayoutBeforeWndProc;
    procedure SetMaxToFullScreen(const Value: Boolean);
    procedure SetBaseUri(const Value: SciterString);
    procedure SetBehavior(const Value: IDefalutBehaviorEventHandler);
    procedure SetOptions(const Value: TSciterLayoutOptions);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetData3(const Value: IInterface);
    procedure SetHighlightElement(const Value: IDomElement);
    procedure SetOnAttachBehavior(const Value: TLayoutAttachBehaviorProc);
    procedure SetAfterCreateBehavior(const Value: TLayoutAfterCreateBehaviorProc);
    procedure SetOnDataLoaded(const Value: TLayoutDataLoadedProc);
    procedure SetOnEngineDestroyed(const Value: TLayoutEngineDestroyedProc);
    procedure SetOnLoadData(const Value: TLayoutLoadDataProc);
    procedure SetOnNotification(const Value: TLayoutNotificationProc);
    procedure SetOnPostedNotification(const Value: TLayoutPostedNotificationProc);
    procedure SetOnCreateNativeObject(const Value: TLayoutCreateNativeObjectProc);
    procedure SetOnGraphicsCriticalFailure(const Value: TLayoutGraphicsCriticalFailure);
    procedure SetAfterWndProc(const Value: TLayoutAfterWndProc);
    procedure SetBeforeWndProc(const Value: TLayoutBeforeWndProc);
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure DoHtmlLoaded;

    function DoBeforeWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT;
    procedure DoAfterWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM; var Result: LRESULT);
  public
    constructor Create(const ASciter: TSciter; const AThis: ISciterBase); 
    destructor Destroy; override;

    function  Implementor: Pointer;

    procedure Setup;
    procedure Teardown;

    //Sciter Window Proc.
    function Proc(msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
    //Sciter Window Proc without call of DefWindowProc.
    function ProcND(hWnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT;

    function AddBeforeWndProc(const AWndProc: TLayoutBeforeWndProc): Integer;
    function RemoveBeforeWndProc(const AWndProc: TLayoutBeforeWndProc): Integer;

    function AddAfterWndProc(const AWndProc: TLayoutAfterWndProc): Integer;
    function RemoveAfterWndProc(const AWndProc: TLayoutAfterWndProc): Integer;

    function  LoadPluginByUrl(const AUrl: SciterString): TLoadDataResult;
    function  LoadPluginByPath(const APath: SciterString): TLoadDataResult;

    //Invokes garbage collector
    procedure GC;

    // notifiaction cracker
    function HandleNotification(pnm: PSciterCallbackNotification): LRESULT;
    function HandleLoadData(pnmld: LPSCN_LOAD_DATA): LRESULT; virtual;
    function HandleDataLoaded(pnmld: LPSCN_DATA_LOADED): LRESULT; virtual;
    function HandleAttachBehavior(lpab: LPSCN_ATTACH_BEHAVIOR): LRESULT; virtual;
    function HandleEngineDestroyed: LRESULT; virtual;
    function HandlePostedNotification(lpab: LPSCN_POSTED_NOTIFICATION): LRESULT; virtual;
    procedure HandleGraphicsCriticalFailure(lpab: LPSCN_GRAPHICS_CRITICAL_FAILURE); virtual;

    function LoadResourceData(const uri: SciterString; var pb: LPCBYTE; var cb: UINT): Boolean;
    (**Load HTML file.
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[in] filename \b LPCWSTR, File name of an HTML file.
     * \return \b BOOL, \c TRUE if the text was parsed and loaded successfully, \c FALSE otherwise.
     **)
    function LoadFile(const uri: SciterString): Boolean;
    (**Load HTML from in memory buffer with base.
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[in] html \b LPCBYTE, Address of HTML to load.
     * \param[in] htmlSize \b UINT, Length of the array pointed by html parameter.
     * \param[in] baseUrl \b LPCWSTR, base URL. All relative links will be resolved against
     *                                this URL.
     * \return \b BOOL, \c TRUE if the text was parsed and loaded successfully, FALSE otherwise.
     **)
    function LoadHtml(const pb: LPCBYTE; cb: UINT; const uri: SciterString = ''): Boolean;

    (**Set (reset) style sheet of current document.
     Will reset styles for all elements according to given CSS (utf8)
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[in] utf8 \b LPCBYTE, start of CSS buffer.
     * \param[in] numBytes \b UINT, number of bytes in utf8.
     **)
    function SetCSS(utf8: LPCBYTE; numBytes: UINT; const baseUrl: SciterString = '';
      const mediaType: SciterString = ''): Boolean;
    (**Set media type of this sciter instance.
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[in] mediaType \b LPCWSTR, media type name.
     *
     * For example media type can be "handheld", "projection", "screen", "screen-hires", etc.
     * By default sciter window has "screen" media type.
     *
     * Media type name is used while loading and parsing style sheets in the engine so
     * you should call this function *before* loading document in it.
     *
     **)
    function SetMediaType(const mediaType: SciterString): Boolean;
    (**Set media variables of this sciter instance.
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[in] mediaVars \b SCITER_VALUE, map that contains name/value pairs - media variables to be set.
     *
     * For example media type can be "handheld:true", "projection:true", "screen:true", etc.
     * By default sciter window has "screen:true" and "desktop:true"/"handheld:true" media variables.
     *
     * Media variables can be changed in runtime. This will cause styles of the document to be reset.
     *
     **)
    function SetMediaVars(const mediaVars: IDomValue): Boolean;
    (**Set various options.
     *
     * \param[in] hWnd \b HWINDOW, Sciter window handle.
     * \param[in] option \b UINT, id of the option, one of SCITER_RT_OPTIONS
     * \param[in] option \b UINT, value of the option.
     *
     **)
    function SetOption(option: TSciterRtOption; value: UINT_PTR): Boolean;
    (** Set sciter home url.
     *  home url is used for resolving sciter: urls
     *  If you will set it like SciterSetHomeURL(hwnd,"http://sciter.com/modules/")
     *  then <script src="sciter:lib/root-extender.tis"> will load
     *  root-extender.tis from http://sciter.com/modules/lib/root-extender.tis
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[in] baseUrl \b LPCWSTR, URL of sciter home.
     *
     **)
    function SetHomeURL(const baseUrl: SciterString): Boolean;

    procedure SetObject(const Name: SciterString; const Json: SciterString);


    (**This function is used in response to SCN_LOAD_DATA request.
     *
     * \param[in] uri \b LPCWSTR, URI of the data requested by Sciter.
     * \param[in] data \b LPBYTE, pointer to data buffer.
     * \param[in] dataLength \b UINT, length of the data in bytes.
     * \return \b BOOL, TRUE if Sciter accepts the data or \c FALSE if error occured
     * (for example this function was called outside of #SCN_LOAD_DATA request).
     *
     * \warning If used, call of this function MUST be done ONLY while handling
     * SCN_LOAD_DATA request and in the same thread. For asynchronous resource loading
     * use SciterDataReadyAsync
     **)
    function DataReady(const uri: SciterString; data: LPCBYTE; dataLength: UINT): Boolean;
    (**Use this function outside of SCN_LOAD_DATA request. This function is needed when you
     * you have your own http client implemented in your application.
     *
     * \param[in] hwnd \b HWINDOW, Sciter window handle.
     * \param[in] uri \b LPCWSTR, URI of the data requested by Sciter.
     * \param[in] data \b LPBYTE, pointer to data buffer.
     * \param[in] dataLength \b UINT, length of the data in bytes.
     * \param[in] requestId \b LPVOID, SCN_LOAD_DATA requestId.
     * \return \b BOOL, TRUE if Sciter accepts the data or \c FALSE if error occured
     **)
    function DataReadyAsync(const uri: SciterString; data: LPCBYTE; dataLength: UINT; requestId: LPVOID): Boolean;

    // call scripting function defined in the global namespace
    function CallFunction(const name: SciterString; argv: array of IDomValue): IDomValue; overload;
    // flattened wrappers of the above. note SCITER_VALUE is a json::value
    function CallFunction(const name: SciterString): IDomValue; overload;

    function Call(const Method: SciterString): OleVariant; overload;
    function Call(const Method: SciterString; const Args: Array of OleVariant): OleVariant; overload;
    function TryCall(const FunctionName: SciterString; const Args: array of OleVariant): Boolean; overload;
    function TryCall(const FunctionName: SciterString; const Args: array of OleVariant; out RetVal: OleVariant): Boolean; overload;

    function Eval(const script: SciterString; var pretval: IDomValue): Boolean; overload;
    function Eval(const Script: SciterString): OleVariant; overload;
    function Eval(const script: SciterString; const Args: array of const): OleVariant; overload;

    procedure AttachDomEventHandler(const ph: IBehaviorEventHandler);
    procedure DetachDomEventHandler(const ph: IBehaviorEventHandler);

    (**Update pending changes in Sciter window.
     *
     * \param[in] hwnd \b HWINDOW, Sciter window handle.
     *
     **)
    procedure UpdateWindow;
    procedure RemoveHighlightion;
    procedure EnableDebugger(onoff: Boolean);

    (**Find DOM element of the Sciter document by coordinates.
      * \param hSciterWnd \b HWINDOW, Sciter window
      * \param clientPt \b POINT,  coordinates.
      * \return \b #HELEMENT, found element handle or zero
      **)
    function FindElement(const clientPt: TPoint): IDomElement;

    function JsonToDomValue(const Json: SciterString): IDomValue;
    function DomValueToJson(const Obj: IDomValue): SciterString;

    function JsonToTiscriptValue(const Json: SciterString): tiscript_object;
    function TiscriptValueToJson(Obj: tiscript_value): SciterString;

    property Hwnd: HWINDOW read GetHwnd;
    property HookWnd: HWINDOW read GetHookWnd;
    property VM: HVM read GetHVM;
    property This: ISciterBase read GetThis;
    property BaseUri: SciterString read GetBaseUri write SetBaseUri;
    property HomeURL: SciterString read GetHomeURL;
    property Html: SciterString read GetHtml;
    property MaxToFullScreen: Boolean read GetMaxToFullScreen write SetMaxToFullScreen;

    property IsValid: Boolean read GetIsValid;

    property GlobalNS: tiscript_value read GetGlobalNS;
    property CurrentNS: tiscript_value read GetCurrentNS;
               
    property RootElement: IDomElement read GetRootElement;
    property FocusElement: IDomElement read GetFocusElement;
    property HighlightElement: IDomElement read GetHighlightElement write SetHighlightElement;

    (**Get element handle by its UID.
      * \param hSciterWnd \b HWINDOW, Sciter window
      * \param uid \b UINT, uid of the element
      * \return \b #HELEMENT, handle of element with the given uid or 0 if not found
      **)
    property ElementByUID[const uid: UINT]: IDomElement read GetElementByUID;

    property MinWidth: UINT read GetMinWidth;
    property MinHeightEx[const width: UINT]: UINT read GetMinHeightEx;
    property MinHeight: UINT read GetMinHeight;
    (**Get current pixels-per-inch metrics of the Sciter window 
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[out] px \b PUINT, get ppi in horizontal direction.
     * \param[out] py \b PUINT, get ppi in vertical direction.
     *
     **)
    property PPI: TSciterGetPPIInfo read GetPPI;
    (**Get "expando" of the view object 
     *
     * \param[in] hWndSciter \b HWINDOW, Sciter window handle.
     * \param[out] pval \b VALUE*, expando as sciter::value.
     *
     **)
    property ViewExpando: IDomValue read GetViewExpando;

    property Options: TSciterLayoutOptions read GetOptions write SetOptions;
    property Behavior: IDefalutBehaviorEventHandler read GetBehavior write SetBehavior;
    property BehaviorFactorys: IBehaviorFactorys read GetBehaviorFactorys;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
    property Data3: IInterface read GetData3 write SetData3;

    property OnNotification: TLayoutNotificationProc read GetOnNotification write SetOnNotification;
    property OnLoadData: TLayoutLoadDataProc read GetOnLoadData write SetOnLoadData;
    property OnDataLoaded: TLayoutDataLoadedProc read GetOnDataLoaded write SetOnDataLoaded;
    property OnAttachBehavior: TLayoutAttachBehaviorProc read GetOnAttachBehavior write SetOnAttachBehavior;
    property AfterCreateBehavior: TLayoutAfterCreateBehaviorProc read GetAfterCreateBehavior write SetAfterCreateBehavior;
    property OnEngineDestroyed: TLayoutEngineDestroyedProc read GetOnEngineDestroyed write SetOnEngineDestroyed;
    property OnPostedNotification: TLayoutPostedNotificationProc read GetOnPostedNotification write SetOnPostedNotification;
    property OnGraphicsCriticalFailure: TLayoutGraphicsCriticalFailure read GetOnGraphicsCriticalFailure write SetOnGraphicsCriticalFailure;

    property BeforeWndProc: TLayoutBeforeWndProc read GetBeforeWndProc write SetBeforeWndProc;
    property AfterWndProc: TLayoutAfterWndProc read GetAfterWndProc write SetAfterWndProc;

    property OnCreateNativeObject: TLayoutCreateNativeObjectProc read GetOnCreateNativeObject write SetOnCreateNativeObject;
  end;

function _callback_layout(pnm: PSciterCallbackNotification; param: LPVOID): UINT; stdcall;
function _LoadFileData(hwnd: HWINDOW; uri: LPCWSTR; const ASchema: TSciterSchemaInfo; const defResult: LRESULT): LRESULT;

function StrCmpNIW(lpString1, lpString2: PWideChar; nChar: Integer): Integer; stdcall; external 'Shlwapi.dll';
function CompareEndStr(const ASubText, AText: SciterString): Boolean;
function UrlParseSchema(const AURL: SciterString; var Info: TSciterSchemaInfo; const AParsePlugin: Boolean = False): Boolean;
function FindLayoutByVM(const vm: HVM): TSciterLayout;
function LoadPluginByUrl(const AUrl: SciterString): Boolean;
function LoadPluginByPath(const APath: SciterString): Boolean;

implementation

uses
  Variants, SciterApiImpl, TiscriptApiImpl, SciterBehaviorDef, SciterExportDefs,
  SciterFactoryIntf, MultiMon;

type
  TSciterAccess = class(TSciter);

var
  varSciter4DPath: SciterString;
  varAppPath: SciterString;

function _callback_layout(pnm: PSciterCallbackNotification; param: LPVOID): UINT; stdcall;
var
  self: TSciterLayout;
begin
  Result := 0;
  try
    self := TSciterLayout(param);
    if self = nil then Exit;
    //if self.FDestroying then Exit;
    Result := self.HandleNotification(pnm);
  except
    on E: Exception do
      TraceException('[_callback_layout]'+E.Message);
  end;
end;

function CompareEndStr(const ASubText, AText: SciterString): Boolean;
var
  SubTextLen, SubTextLocation: Integer;
begin
  SubTextLen := Length(ASubText);
  SubTextLocation := Length(AText) - SubTextLen + 1;
  if (SubTextLocation > 0) and (ASubText <> '') and
     (ByteType(AText, SubTextLocation) <> mbTrailByte) then
    Result := StrCmpNIW(Pointer(ASubText), Pointer(@AText[SubTextLocation]), SubTextLen) = 0
  else
    Result := False;
end;

function SetWindowTheme(hwnd: HWND; pszSubAppName, pszSubIdList: LPCWSTR): HRESULT; stdcall; external 'UxTheme.dll';

procedure DisableNCRendering(wnd: HWND);
const
// typedef enum _DWMWINDOWATTRIBUTE {
  DWMWA_NCRENDERING_ENABLED         = 1;
  DWMWA_NCRENDERING_POLICY          = 2;
  DWMWA_TRANSITIONS_FORCEDISABLED   = 3;
  DWMWA_ALLOW_NCPAINT               = 4;
  DWMWA_CAPTION_BUTTON_BOUNDS       = 5;
  DWMWA_NONCLIENT_RTL_LAYOUT        = 6;
  DWMWA_FORCE_ICONIC_REPRESENTATION = 7;
  DWMWA_FLIP3D_POLICY               = 8;
  DWMWA_EXTENDED_FRAME_BOUNDS       = 9;
  DWMWA_HAS_ICONIC_BITMAP           = 10;
  DWMWA_DISALLOW_PEEK               = 11;
  DWMWA_EXCLUDED_FROM_PEEK          = 12;
  DWMWA_CLOAK                       = 13;
  DWMWA_CLOAKED                     = 14;
  DWMWA_FREEZE_REPRESENTATION       = 15;
  DWMWA_LAST                        = 16;
//} DWMWINDOWATTRIBUTE;
//typedef enum _DWMNCRENDERINGPOLICY {
  DWMNCRP_USEWINDOWSTYLE = 0;
  DWMNCRP_DISABLED       = 1;
  DWMNCRP_ENABLED        = 2;
  DWMNCRP_LAST           = 3;
//} DWMNCRENDERINGPOLICY;
type
  TDwmSetWindowAttribute = function (wnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HRESULT; stdcall;
var
  hLib: THandle;
  ncrp, da: DWORD;
  DwmSetWindowAttribute: TDwmSetWindowAttribute;
begin
  hLib := LoadLibrary('dwmapi.dll');
  if hLib > 32 then
  try
    @DwmSetWindowAttribute := GetProcAddress(hLib, 'DwmSetWindowAttribute');
    if @DwmSetWindowAttribute <> nil then
    begin
      //da   := DWMWA_TRANSITIONS_FORCEDISABLED;
      //ncrp := DWORD(False);
      da   := DWMWA_NCRENDERING_POLICY;
      ncrp := DWMNCRP_DISABLED;
      DwmSetWindowAttribute(wnd, da, @ncrp, sizeof(ncrp));
    end;
  finally
    FreeLibrary(hLib)
  end;
end;

function _LoadFileData(hwnd: HWINDOW; uri: LPCWSTR; const ASchema: TSciterSchemaInfo; const defResult: LRESULT): LRESULT;
var
  ms: TMemoryStream;
begin
  Result := defResult;
  if ASchema.IsZip then
  begin
    Result := LRESULT(LOAD_OK);
    Exit;
  end;
  if not FastFileExists(ASchema.Path) then
    Exit;
  if ASchema.IsOrigin then
  begin
    ms := TMemoryStream.Create;
    ms.LoadFromFile(ASchema.Path);
  end
  else
    ms := _LoadFileToMemoryStream(ASchema.Path);
  if ms <> nil then
  try
    if ms.Memory <> nil then
    begin
      SAPI.SciterDataReady(hwnd, uri, ms.Memory, ms.Size);
      Result := LRESULT(LOAD_OK);
    end;
  finally
    ms.Free;
  end
end;

function UrlParseSchema(const AURL: SciterString; var Info: TSciterSchemaInfo; const AParsePlugin: Boolean = False): Boolean;
  procedure _ParseUrlPath(var Info: TSciterSchemaInfo; const ARoot, AURL: SciterString;
    const ASchemaLen: Integer; const AIsFile: Boolean = False);
  var
    i, iAnchor, iParams: Integer;
  begin
    iAnchor := Pos('#', AURL);
    iParams := Pos('?', AURL);
    if (iAnchor > 0) or (iParams > 0) then
    begin
      if iAnchor > 0 then i := iAnchor else i := iParams;
      Info.Path := ARoot +Copy(AURL, ASchemaLen+1, i-ASchemaLen-1);
      if iAnchor > 0 then
      begin
        if iParams = 0 then iParams := MaxInt;
        Info.Anchor := Copy(AURL, iAnchor+1, iParams);
      end;
      Info.Params := Copy(AURL, iParams+1, MaxInt);
    end
    else
      Info.Path := ARoot + Copy(AURL, ASchemaLen+1, MaxInt);
    if AIsFile and (Info.Path[1] = '/') then
      Info.Path := Copy(Info.Path, 2, MaxInt);
    Info.IsPlugin := CompareEndStr(EXT_PLUGIN, Info.Path);
    if Info.IsPlugin then
      Info.Path := Copy(Info.Path, 1, Length(Info.Path)-EXT_PLUGINLen) + EXT_PLUGIN_Plat
    else
      Info.IsHtml := CompareEndStr('.htm', Info.Path) or CompareEndStr('.html', Info.Path);
    if not Info.IsHtml then
    begin
      Info.IsFont := CompareEndStr('.ttf', Info.Path);
      Info.IsZip := CompareEndStr('.zip', Info.Path);
    end;
  end;
var
  LURI: ISciterURI;
begin
  Result := False;
  Info.IsOrigin := False;
  Info.IsPlugin := False;
  Info.IsHtml := False;
  Info.IsFont := False;
  Info.IsZip := False;
  Info.Anchor := '';
  Info.Params := '';
  if AURL = URL_DebugPeer then
  begin
    Info.Path := Sciter.DebugPeerFile;
    if FastFileExists(Info.Path) then
      Info.Schema := sstFile
    else
    begin
      Info.Schema := sstNormal;
      //Info.Schema := sstRes;
      //Info.Path := 'debug-peer.tis';
    end;
  end
  else
  if AURL = URL_MsgboxHTML then
  begin
    Info.Path := Sciter.MsgboxHtmlFile;
    if FastFileExists(Info.Path) then
      Info.Schema := sstFile
    else
      Info.Schema := sstNormal;
  end
  else
  if AURL = URL_MsgboxCSS then
  begin
    Info.Path := Sciter.MsgboxCSSFile;
    if FastFileExists(Info.Path) then
      Info.Schema := sstFile
    else
      Info.Schema := sstNormal;
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_File, SCHEMA_FileLen) = 0 then
  begin
    Info.IsOrigin := True;
    Info.Schema := sstFile;
    _ParseUrlPath(Info, '', AURL, SCHEMA_FileLen, True);
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_Sciter4D, SCHEMA_Sciter4DLen) = 0 then
  begin
    Info.Schema := sstFile;
    _ParseUrlPath(Info, varSciter4DPath, AURL, SCHEMA_Sciter4DLen);
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_App, SCHEMA_AppDLen) = 0 then
  begin
    Info.Schema := sstFile;
    _ParseUrlPath(Info, varAppPath, AURL, SCHEMA_AppDLen);
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_Master, SCHEMA_MasterLen) = 0 then
  begin
    Info.Schema := sstFile;
    _ParseUrlPath(Info, Sciter.MainMasterPath, AURL, SCHEMA_MasterLen);
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_Res, SCHEMA_ResLen) = 0 then
  begin
    Info.Schema := sstRes;
    _ParseUrlPath(Info, '', AURL, SCHEMA_ResLen);
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_ThisApp, SCHEMA_ThisAppLen) = 0 then
  begin
    Info.Schema := sstThisApp;
  end
  else
  if StrCmpNIW(PWideChar(AURL), SCHEMA_Plugin, SCHEMA_PluginLen) = 0 then
  begin
    Info.Schema := sstPlugin;
    Info.IsPlugin := True;
    Info.Path := '';
    if AParsePlugin then
    begin
      LURI := __SciterCreateURI(AURL);
      if LURI = nil then
      begin
        TraceError(Format('URL[%s]解析失败！', [AURL]));
        Exit;
      end;
      if not LURI.ToFilePath(Info.Path) then
      begin
        TraceError(Format('URL[%s]解析为路径失败！', [AURL]));
        Exit;
      end;
      if ExtractFileExt(Info.Path) = '' then
        Info.Path := Info.Path + EXT_PLUGIN_Plat;
      Info.Params := LURI.ParamStr;
    end;
  end
  else
    Info.Schema := sstNormal;
  Result := True;
end;

function FindLayoutByVM(const vm: HVM): TSciterLayout;
var
  runtime: ITiscriptRuntime;
  self: ITiscriptValue;
  el: IDomElement;
begin
  runtime := Tiscript.CreateRuntime(vm);
  self := runtime.CurrentNs['self'];
  if self.IsElement then
  begin
    el := __ElementFactory.Create(self.E);
    Result := TSciterLayout(GetPropW(el.GetElementHwnd(), PROPNAME_LAYOUT));
  end
  else
    Result := nil;
end;

function LoadPluginByUrl(const AUrl: SciterString): Boolean;
var
  LSchemaInfo: TSciterSchemaInfo;
begin
  Result := False;
  try
    if not UrlParseSchema(AUrl, LSchemaInfo, True) then
      Exit;
    if LSchemaInfo.IsPlugin then
      Result := LoadPluginByPath(LSchemaInfo.Path);
  except
    on E: Exception do
      TraceException('[LoadPluginByUrl]['+AUrl+']'+E.Message);
  end;
end;

function LoadPluginByPath(const APath: SciterString): Boolean;
var
  i: Integer;
  LPlugin: ISciterPlugin;
  bHandled: Boolean;
begin
  Result := False;
  try
    i := __SciterPluginList.IndexOfPath(APath);
    if i < 0 then
    begin
      LPlugin := TSciterPlugin.Create(APath);

      __SciterPluginList.Add(LPlugin, True);
        
      if @__SciterPluginList.BeforeLoadPlugin <> nil then
      try
        Result := __SciterPluginList.BeforeLoadPlugin(LPlugin, bHandled);
        if bHandled then
          Exit;
      except
        on E: Exception do
        begin
          TraceException('[FSciter.BeforeLoadPlugin]'+E.Message);
          Exit;
        end
      end;
      try
        if not FastFileExists(LPlugin.Path) then
        begin
          TraceError(Format('plugin [%s] not exist！', [LPlugin.Path]));
          Exit;
        end;
        if not LPlugin.LoadPlugin then
        begin
          TraceError(Format('load plugin [%s] failed:%s！', [LPlugin.Path, LPlugin.LastError]));
          Exit;      
        end;
      finally
        if @__SciterPluginList.AfterLoadPlugin <> nil then
        try
          __SciterPluginList.AfterLoadPlugin(LPlugin);
        except
          on E: Exception do
            TraceException('[FSciter.AfterLoadPlugin]'+E.Message);
        end;
      end;
    end;
    Result := True;
  except
    on E: Exception do
      TraceException('[TSciterLayout.LoadPluginByPath]['+APath+']'+E.Message);
  end;
end;

{ TSciterLayout }

function TSciterLayout.CallFunction(const name: SciterString; argv: array of IDomValue): IDomValue;
var
  hwnd: HWINDOW;
  LArgv: SCITER_VALUE_ARRAY;
  pArgv: PSCITER_VALUE_ARRAY;
  i: Integer;
begin
  hwnd := GetHwnd;

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
  Assert(SAPI.SciterCall(hwnd, PAnsiChar(AnsiString(name)), System.Length(argv), pArgv, Result.Value^));
end;

function TSciterLayout.CallFunction(const name: SciterString): IDomValue;
begin
  Result := CallFunction(name, []);
end;

constructor TSciterLayout.Create(const ASciter: TSciter; const AThis: ISciterBase);
begin
  FSetuping := False;
  FSciter := ASciter;
  FThis := Pointer(AThis);
  FOptions := [sloUseHtmlSize];
  FBeforeWndProcList := TMethodList.Create;
  FAfterWndProcList := TMethodList.Create;
end;

function TSciterLayout.GetRootElement: IDomElement;
begin
  Result := SciterDom.RootElement(GetHwnd);
end;

function TSciterLayout.GetThis: ISciterBase;
begin
  Result := ISciterBase(FThis);
end;

function TSciterLayout.HandleNotification(pnm: PSciterCallbackNotification): LRESULT;
var
  bHandled: Boolean;
//  vm: HVM;
begin
  if @FOnNotification <> nil then
  begin
    bHandled := False;
    Result := FOnNotification(pnm, bHandled);
    if bHandled then
      Exit;
  end;
  if @FSciter.OnNotification <> nil then
  begin
    bHandled := False;
    Result := FSciter.OnNotification(Self, pnm, bHandled);
    if bHandled then
      Exit;
  end;
  
  case pnm.code of
    SC_LOAD_DATA: Result := HandleLoadData(LPSCN_LOAD_DATA(pnm));
    SC_DATA_LOADED: Result := HandleDataLoaded(LPSCN_DATA_LOADED(pnm));
    SC_ATTACH_BEHAVIOR: Result := HandleAttachBehavior(LPSCN_ATTACH_BEHAVIOR(pnm));
    SC_ENGINE_DESTROYED:
    try
      Result := HandleEngineDestroyed();
    finally
//      vm := SAPI.SciterGetVM(pnm.hwnd);
//      if vm <> nil then
//      begin
//        ClearMethodRecList(vm);
//        __Tiscript.ClassBag.Remove(vm);
//      end;
    end;
    SC_POSTED_NOTIFICATION: Result := HandlePostedNotification(LPSCN_POSTED_NOTIFICATION(pnm));
    SC_GRAPHICS_CRITICAL_FAILURE:
    begin
      HandleGraphicsCriticalFailure(LPSCN_GRAPHICS_CRITICAL_FAILURE(pnm));
      Result := 0;
    end;
  else
    Result := 0;
  end;
end;

function TSciterLayout.LoadFile(const uri: SciterString): Boolean;
var
  sUrl, sPath: SciterString;
  sUrl1: string;
  iDelimiter: Integer;
  pb: LPCBYTE;
  cb: UINT;
  i: Integer;
begin
  Result := False;
  _InitVM(GetHVM);
  
  sUrl := StringReplace(uri, '\', '/', [rfReplaceAll]);
  if StrCmpNIW(PWideChar(sUrl), SCHEMA_Res, SCHEMA_ResLen) = 0 then
  begin
    i := Pos('?', sUrl);
    if i > 0 then
      sPath := Copy(sUrl, SCHEMA_ResLen+1, i-SCHEMA_ResLen-1)
    else
      sPath := Copy(sUrl, SCHEMA_ResLen+1, MaxInt);
    if not LoadResourceData(sPath, pb, cb) then
      Exit;
    Result := LoadHtml(pb, cb, sUrl);
  end
  else
  begin
    if StrCmpNIW(PWideChar(sUrl), SCHEMA_File, SCHEMA_FileLen) = 0 then
    begin
      sUrl1 := sUrl;
      iDelimiter := LastDelimiter('/', sUrl1);
      if iDelimiter > 0 then
        FBaseUri := Copy(sUrl1, 1, iDelimiter)
      else
        FBaseUri := EmptyStr;
    end
    else
      FBaseUri := EmptyStr;
    sUrl := EncodeURI(sUrl);
    Result := SAPI.SciterLoadFile(GetHwnd, PWideChar(sUrl));
  end;
  DoHtmlLoaded;
end;

function TSciterLayout.LoadHtml(const pb: LPCBYTE; cb: UINT; const uri: SciterString): Boolean;
begin
  _InitVM(GetHVM);
      
  FBaseUri := uri;
  Result := SAPI.SciterLoadHtml(GetHwnd, pb,cb, PWideChar(uri));

  DoHtmlLoaded;
end;

function TSciterLayout.LoadResourceData(const uri: SciterString;
  var pb: LPCBYTE; var cb: UINT): Boolean;
begin
  Result := _load_resource_data(GetResourceInstance, PWideChar(uri), pb, cb);
end;

function TSciterLayout.HandleAttachBehavior(lpab: LPSCN_ATTACH_BEHAVIOR): LRESULT;
var
  bHandled: Boolean;
  i: Integer;
  LPlugin: ISciterPlugin;
begin
  if @FOnAttachBehavior <> nil then
  begin
    bHandled := False;
    Result := FOnAttachBehavior(lpab, bHandled);
    if bHandled then
      Exit;
  end;

  if @FSciter.OnAttachBehavior <> nil then
  begin
    bHandled := False;
    Result := FSciter.OnAttachBehavior(Self, lpab, bHandled);
    if bHandled then
      Exit;
  end;

  Result := LRESULT(False);
  try
    if not CreateBehavior(lpab, Self.BehaviorFactorys, Self) then
    begin
      for i := 0 to __SciterPluginList.Count - 1 do
      begin
        LPlugin := __SciterPluginList^[i];
        if LPlugin.Loaded and CreateBehavior(lpab, LPlugin.BehaviorFactorys, Self) then
        begin
          Result := LRESULT(True);
          Exit;
        end;
      end;
    
      if not CreateBehavior(lpab, FSciter.BehaviorFactorys, Self) then
        Exit;
    end;

    Result := LRESULT(True);
  finally
    if Result = LRESULT(True) then
    begin
      bHandled := False;
      if @FAfterCreateBehavior <> nil then
      try
        FAfterCreateBehavior(Self, lpab, IBehaviorEventHandler(lpab.elementTag), bHandled);
      except
        on E: Exception do
          TraceException('[TSciterLayout.AfterCreateBehavior]'+E.Message);
      end;

      if (not bHandled) and (@FSciter.AfterCreateBehavior <> nil) then
      try
        FSciter.AfterCreateBehavior(Self, lpab, IBehaviorEventHandler(lpab.elementTag));
      except
        on E: Exception do
          TraceException('[FSciter.AfterCreateBehavior]'+E.Message);
      end;
    end;
  end;
end;

function TSciterLayout.HandleDataLoaded(pnmld: LPSCN_DATA_LOADED): LRESULT;
var
  bHandled: Boolean;
begin
  if @FOnDataLoaded <> nil then
  begin
    bHandled := False;
    Result := FOnDataLoaded(pnmld, bHandled);
    if bHandled then
      Exit;
  end;
  if @FSciter.OnDataLoaded <> nil then
  begin
    bHandled := False;
    Result := FSciter.OnDataLoaded(Self, pnmld, bHandled);
    if bHandled then
      Exit;
  end;
  if pnmld.dataSize = 0 then
    Result := LRESULT(LoadPluginByUrl(pnmld.uri))
  else
    Result := LRESULT(LOAD_OK);
end;

function TSciterLayout.HandleEngineDestroyed: LRESULT;
var
  bHandled: Boolean;
begin
  if @FOnEngineDestroyed <> nil then
  begin
    bHandled := False;
    Result := FOnEngineDestroyed(bHandled);
    if bHandled then
      Exit;
  end;

  if @FSciter.OnEngineDestroyed <> nil then
  begin
    bHandled := False;
    Result := FSciter.OnEngineDestroyed(Self, bHandled);
    if bHandled then
      Exit;
  end;

  Result := 0;
end;

function TSciterLayout.HandleLoadData(pnmld: LPSCN_LOAD_DATA): LRESULT;
var
  pb: LPCBYTE;
  cb: UINT;
  bHandled: Boolean;
  LSciter: TSciterAccess;
  i: Integer;
  LProc: TSciterLoadDataProc;
  LSchemaInfo: TSciterSchemaInfo;
begin
  Result := LRESULT(LOAD_DISCARD);
  bHandled := False;
  UrlParseSchema(pnmld.uri, LSchemaInfo);
  if @FOnLoadData <> nil then
  begin
    Result := LRESULT(FOnLoadData(pnmld, @LSchemaInfo, bHandled));
    if bHandled then
      Exit;
  end;
  LSciter := TSciterAccess(FSciter);
  for i := LSciter.LoadDataProcList.Count - 1 downto 0 do
  begin
    LProc := TSciterLoadDataProc(LSciter.LoadDataProcList[i]^);
    try
      Result := LRESULT(LProc(Self, pnmld, @LSchemaInfo, bHandled));
    except
      on E: Exception do
        TraceException('[FSciter.LoadDataProcList]'+E.Message);
    end;             
    if bHandled then
      Exit;
  end;
  if LSchemaInfo.IsPlugin then
    SAPI.SciterDataReady(pnmld.hwnd, pnmld.uri, nil, 0)
  else
    case LSchemaInfo.Schema of
      sstFile:
        Result := _LoadFileData(pnmld.hwnd, pnmld.uri, LSchemaInfo, LRESULT(LOAD_DISCARD));
      sstThisApp:
      begin
        if __SciterArchive.Get(pnmld.uri + SCHEMA_ThisAppLen, pb, cb) and (cb > 0) then
        begin
          SAPI.SciterDataReady(pnmld.hwnd, pnmld.uri, pb, cb);
          Result := LRESULT(LOAD_OK);  
        end
      end;
      sstRes:
      begin
        if LoadResourceData(LSchemaInfo.Path, pb, cb) then
        begin
          SAPI.SciterDataReady(pnmld.hwnd, pnmld.uri, pb, cb);
          Result := LRESULT(LOAD_OK);
        end
      end;
    else
      Result := LRESULT(LOAD_OK);
    end;
end;


function TSciterLayout.HandlePostedNotification(
  lpab: LPSCN_POSTED_NOTIFICATION): LRESULT;
var
  bHandled: Boolean;
begin
  if @FOnPostedNotification <> nil then
  begin
    bHandled := False;
    Result := FOnPostedNotification(lpab, bHandled);
    if bHandled then
      Exit;
  end;

  if @FSciter.OnPostedNotification <> nil then
  begin
    bHandled := False;
    Result := FSciter.OnPostedNotification(Self, lpab, bHandled);
    if bHandled then
      Exit;
  end;
  
  Result := 0;
end;

function TSciterLayout.Proc(msg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
var
  pbHandled: Boolean;
begin
  pbHandled := False;
  Result := DoBeforeWndProc(msg, wParam, lParam, pbHandled);
  if pbHandled then
    Exit;
    
  Result := SAPI.SciterProc(GetHwnd, msg, wParam, lParam);

  DoAfterWndProc(msg, wParam, lParam, Result);
end;

function GetDesktopRect(hWnd: HWND; FullScreen: Boolean = True): TRect;
var
  hm: HMONITOR;
  LMonitorInfo: TMonitorInfoW;
begin
  Result :=  Rect(0, 0, 0, 0);
  ZeroMemory(@LMonitorInfo, SizeOf(LMonitorInfo));
  LMonitorInfo.cbSize := SizeOf(LMonitorInfo);
  hm := MonitorFromWindow(hWnd, MONITOR_DEFAULTTONEAREST);
  if not GetMonitorInfoW(hm, @LMonitorInfo) then Exit;
  if FullScreen then Result := LMonitorInfo.rcMonitor
  else Result := LMonitorInfo.rcWork;
end;

function TSciterLayout.ProcND(hWnd: HWINDOW; msg: UINT; wParam: WPARAM;
  lParam: LPARAM; var pbHandled: Boolean): LRESULT;
var
  bHandled: BOOL;
  rc: TRect;
begin
  Result := 0;
  try
    if Self = nil then Exit;
    if FDestroying then Exit;

    pbHandled := False;
    Result := DoBeforeWndProc(msg, wParam, lParam, pbHandled);
    if pbHandled then
      Exit;

    case msg of
      WM_GetMinMaxInfo:
      begin
        rc := GetDesktopRect(hWnd, GetMaxToFullScreen);
        PMinMaxInfo(lParam).ptMaxSize.X := rc.Right - rc.Left;
        PMinMaxInfo(lParam).ptMaxSize.Y := rc.Bottom - rc.Top;
        Result := 0;
        pbHandled := True;
      end;
    else
      bHandled := pbHandled;
      Result   := SAPI.SciterProcND(hWnd, msg, wParam, lParam, bHandled);
      pbHandled := bHandled;
    end;

    DoAfterWndProc(msg, wParam, lParam, Result);
  except
    on E: Exception do
      TraceException('[TSciterLayout.ProcND][$'+IntToHex(msg,4)+']'+E.Message);
  end;
end;

procedure TSciterLayout.setup;
begin
  if FSetuping then Exit;
  try
    FHookHandle := GetHwnd;

    SAPI.SciterSetCallback(GetHwnd, _callback_layout, Self);
    SetPropW(FHookHandle, PROPNAME_LAYOUT, Cardinal(Self));
    //ni.set_extra_data(vm, Self);

    if GetWindowLong(FHookHandle, GWL_STYLE) and WS_CAPTION = 0 then
      DisableNCRendering(FHookHandle);

    FSetuping := True;
  except
    on E: Exception do
      TraceException('[TSciterLayout.setup]'+E.Message);
  end;
end;

procedure TSciterLayout.teardown;
begin
  if not FSetuping then Exit;
  try
    SetBehavior(nil);
    SAPI.SciterSetCallback(GetHwnd, nil, nil);
    RemovePropW(FHookHandle, PROPNAME_LAYOUT);
    //ni.set_extra_data(vm, nil);
    //FHookHandle := 0;

    FSetuping := False;
  except
    on E: Exception do
      TraceException('[TSciterLayout.teardown]'+E.Message);
  end;
end;

function TSciterLayout.GetHwnd: HWINDOW;
begin
  if FDestroying then
    Result := FHookHandle
  else
  if This <> nil then
    Result := This.GetHwnd
  else
    Result := 0;
end;

function TSciterLayout.GetOnAttachBehavior: TLayoutAttachBehaviorProc;
begin
  Result := FOnAttachBehavior;
end;

function TSciterLayout.GetOnDataLoaded: TLayoutDataLoadedProc;
begin
  Result := FOnDataLoaded;
end;

function TSciterLayout.GetOnEngineDestroyed: TLayoutEngineDestroyedProc;
begin
  Result := FOnEngineDestroyed;
end;

function TSciterLayout.GetOnLoadData: TLayoutLoadDataProc;
begin
  Result := FOnLoadData;
end;

function TSciterLayout.GetOnNotification: TLayoutNotificationProc;
begin
  Result := FOnNotification;
end;

function TSciterLayout.GetOnPostedNotification: TLayoutPostedNotificationProc;
begin
  Result := FOnPostedNotification;
end;

procedure TSciterLayout.SetOnAttachBehavior(
  const Value: TLayoutAttachBehaviorProc);
begin
  FOnAttachBehavior := Value;
end;

procedure TSciterLayout.SetOnDataLoaded(const Value: TLayoutDataLoadedProc);
begin
  FOnDataLoaded := Value;
end;

procedure TSciterLayout.SetOnEngineDestroyed(
  const Value: TLayoutEngineDestroyedProc);
begin
  FOnEngineDestroyed := Value;
end;

procedure TSciterLayout.SetOnLoadData(const Value: TLayoutLoadDataProc);
begin
  FOnLoadData := Value;
end;

procedure TSciterLayout.SetOnNotification(
  const Value: TLayoutNotificationProc);
begin
  FOnNotification := Value;
end;

procedure TSciterLayout.SetOnPostedNotification(
  const Value: TLayoutPostedNotificationProc);
begin
  FOnPostedNotification := Value;
end;

function TSciterLayout.DataReady(const uri: SciterString; data: LPCBYTE; dataLength: UINT): Boolean;
begin
  Result := SAPI.SciterDataReady(GetHwnd, PWideChar(uri), data, dataLength);
end;

function TSciterLayout.DataReadyAsync(const uri: SciterString;
  data: LPCBYTE; dataLength: UINT; requestId: LPVOID): Boolean;
begin
  Result := SAPI.SciterDataReadyAsync(GetHwnd, PWideChar(uri), data, dataLength, requestId);
end;

function TSciterLayout.SetCSS(utf8: LPCBYTE; numBytes: UINT; const baseUrl,
  mediaType: SciterString): Boolean;
begin
  Result := SAPI.SciterSetCSS(GetHwnd, utf8, numBytes, PWideChar(baseUrl), PWideChar(mediaType))
end;

function TSciterLayout.SetMediaType(const mediaType: SciterString): Boolean;
begin
  Result := SAPI.SciterSetMediaType(GetHwnd, PWideChar(mediaType))
end;

function TSciterLayout.SetMediaVars(const mediaVars: IDomValue): Boolean;
begin
  Result := SAPI.SciterSetMediaVars(GetHwnd, mediaVars.Value^)
end;

function TSciterLayout.GetMinHeight: UINT;
begin
  Result := SAPI.SciterGetMinHeight(GetHwnd, GetMinWidth)
end;

function TSciterLayout.GetMinWidth: UINT;
begin
  Result := SAPI.SciterGetMinWidth(GetHwnd)
end;

function TSciterLayout.GetMinHeightEx(const width: UINT): UINT;
begin
  Result := SAPI.SciterGetMinHeight(GetHwnd, width)
end;

function TSciterLayout.Eval(const script: SciterString;
  var pretval: IDomValue): Boolean;
begin
  Result := SAPI.SciterEval(GetHwnd, PWideChar(script), Length(script), pretval.Value^)
end;

procedure TSciterLayout.UpdateWindow;
begin
  SAPI.SciterUpdateWindow(GetHwnd);
end;

function TSciterLayout.SetOption(option: TSciterRtOption; value: UINT_PTR): Boolean;
var
  wnd: HWINDOW;
begin
  if option in [SCITER_SET_GPU_BLACKLIST, SCITER_SET_GFX_LAYER, SCITER_SET_UX_THEMING] then
    wnd := 0
  else
    wnd := GetHwnd;
  Result := SAPI.SciterSetOption(wnd, option, value);
end;

function TSciterLayout.GetPPI: TSciterGetPPIInfo;
begin
  SAPI.SciterGetPPI(GetHwnd, Result.px, Result.py);
end;

function TSciterLayout.GetViewExpando: IDomValue;
begin
  Result := ValueFactory.Create;
  if not SAPI.SciterGetViewExpando(GetHwnd, Result.Value^) then
    Result := nil;
end;

function TSciterLayout.SetHomeURL(const baseUrl: SciterString): Boolean;
begin
  Result := SAPI.SciterSetHomeURL(GetHwnd, PWideChar(baseUrl));
  if Result then
    FHomeURL := baseUrl;
end;

function TSciterLayout.GetFocusElement: IDomElement;
begin
  Result := SciterDom.FocusElement(GetHwnd)
end;

function TSciterLayout.GetHighlightElement: IDomElement;
begin
  Result := SciterDom.HighlightElement(GetHwnd)
end;

procedure TSciterLayout.RemoveHighlightion;
begin
  SciterDom.RemoveHighlightion(GetHwnd);
end;

procedure TSciterLayout.SetHighlightElement(const Value: IDomElement);
begin
  SAPI.SciterSetHighlightedElement(GetHwnd, Value.Element);
end;

function TSciterLayout.FindElement(const clientPt: TPoint): IDomElement;
begin
  Result := SciterDom.FindElement(GetHwnd, clientPt)
end;

function TSciterLayout.GetElementByUID(const uid: UINT): IDomElement;
begin
  Result := SciterDom.FindElementByUID(GetHwnd, uid)
end;

procedure TSciterLayout.AttachDomEventHandler(const ph: IBehaviorEventHandler);
begin
  SAPI.SciterWindowAttachEventHandler(GetHwnd, _element_proc, Pointer(ph), HANDLE_ALL);
  //ph._AddRef;
end;

procedure TSciterLayout.DetachDomEventHandler(const ph: IBehaviorEventHandler);
begin
  SAPI.SciterWindowDetachEventHandler(GetHwnd, _element_proc, Pointer(ph));
 // ph._Release;
end;

procedure TSciterLayout.EnableDebugger(onoff: Boolean);
begin
  if onoff then
    SAPI.SciterSetOption(GetHwnd, SCITER_SET_DEBUG_MODE, Integer(True))
  else
    SAPI.SciterSetOption(GetHwnd, SCITER_SET_DEBUG_MODE, Integer(False));
end;


function TSciterLayout.GetIsValid: Boolean;
begin
  Result := (GetHwnd <> 0) and IsWindow(GetHwnd);
end;

function TSciterLayout.GetResourceInstance: HMODULE;
begin
  Result := this.GetResourceInstance;
end;

function TSciterLayout.GetHookWnd: HWINDOW;
begin
  Result := FHookHandle;
end;

function TSciterLayout.GetBehaviorFactorys: IBehaviorFactorys;
begin
  if FBehaviorFactorys = nil then
    FBehaviorFactorys := TBehaviorFactorys.Create;

  Result := FBehaviorFactorys;
end;

destructor TSciterLayout.Destroy;
begin
  if FDestroying then
    Exit;
  FDestroying := True;

  Teardown;

  FBehaviorFactorys := nil;
  if FBeforeWndProcList <> nil then
    FreeAndNil(FBeforeWndProcList);
  if FAfterWndProcList <> nil then
    FreeAndNil(FAfterWndProcList);
  inherited;
end;

function TSciterLayout.GetBehavior: IDefalutBehaviorEventHandler;
var
  LLayout: ISciterLayout;
begin
  if (FBehavior = nil) then
  begin
    FBehavior := FSciter.CreateDefalutHandler(This.GetWindowName);
    LLayout := Self;
    FBehavior.Layout := Pointer(LLayout);
    AttachDomEventHandler(FBehavior);
  end;
  Result := FBehavior;
end;

procedure TSciterLayout.SetBehavior(const Value: IDefalutBehaviorEventHandler);
begin
  if FBehavior = Value then
    Exit;
  if (FBehavior <> nil) then
  begin
    DetachDomEventHandler(FBehavior);
    FBehavior := nil;
  end;
  FBehavior := Value;
end;

function TSciterLayout.GetBaseUri: SciterString;
begin
  Result := FBaseUri;
end;

procedure TSciterLayout.SetBaseUri(const Value: SciterString);
begin
  FBaseUri := Value;
end;

function TSciterLayout.GetHVM: HVM;
begin
  Result := SAPI.SciterGetVM(GetHwnd);
end;

function TSciterLayout.GetHomeURL: SciterString;
begin
  Result := FHomeURL;
end;

procedure TSciterLayout.GC;
begin
  ni.invoke_gc(VM);
end;

function TSciterLayout.JsonToDomValue(const Json: SciterString): IDomValue;
begin
  Result := ValueFactory.FromString(Json, CVT_XJSON_LITERAL);
end;

function TSciterLayout.JsonToTiscriptValue(const Json: SciterString): tiscript_object;
var
  sv: IDomValue;
  tv: tiscript_value;
begin
  sv := JsonToDomValue(Json);  
  if not SAPI.Sciter_S2T(VM, sv.Value, tv) then
    raise ESciterException.Create('Sciter failed parsing JSON string.');
  Result := tv;
end;

function TSciterLayout.DomValueToJson(const Obj: IDomValue): SciterString;
var
  pWStr: PWideChar;
  iNum: UINT;
  pCopy: IDomValue;
begin
  pCopy := ValueFactory.Create;
  pCopy.Assign(Obj);

  if SAPI.ValueToString(pCopy.Value^, CVT_XJSON_LITERAL) <> 0 then
    raise ESciterException.Create('Failed to convert SciterValue to JSON');
  if SAPI.ValueStringData(pCopy.Value^, pWStr, iNum) <> 0 then
    raise ESciterException.Create('Failed to convert SciterValue to JSON');
  Result := SciterString(pWstr);
end;

function TSciterLayout.TiscriptValueToJson(Obj: tiscript_value): SciterString;
var
  sv: IDomValue;
begin
  sv := ValueFactory.Create;
  if not SAPI.Sciter_T2S(VM, Obj, sv.Value, False) then
    raise ESciterException.Create('Failed to convert tiscript_value to JSON.');
  Result := DomValueToJson(sv);
end;

function TSciterLayout.TryCall(const FunctionName: SciterString;
  const Args: array of OleVariant): Boolean;
var
  pRetVal: OleVariant;
begin
  Result := TryCall(FunctionName, Args, pRetVal);
end;

function TSciterLayout.TryCall(const FunctionName: SciterString;
  const Args: array of OleVariant; out RetVal: OleVariant): Boolean;
var
  pVal: SCITER_VALUE;
  sFunctionName: AnsiString;
  pArgs: array[0..255] of SCITER_VALUE;
  cArgs: Integer;
  i: Integer;
  SR: BOOL;
begin
  sFunctionName := AnsiString(FunctionName);
  SAPI.ValueInit(pVal);

  cArgs := Length(Args);
  if cArgs > MaxParams then
    raise ESciterException.Create('Too many arguments.');

  for i := Low(pArgs) to High(pArgs) do
    SAPI.ValueInit(pArgs[i]);

  for i := Low(Args) to High(Args) do
  begin
    V2S(Args[i], pArgs[i], vm);
  end;

  if cArgs = 0 then
    SR := SAPI.SciterCall(GetHwnd, PAnsiChar(sFunctionName), 0, nil, pVal)
  else
    SR := SAPI.SciterCall(GetHwnd, PAnsiChar(sFunctionName), cArgs, @pArgs[0], pVal);
    
  if SR then
  begin
    S2V(pVal, RetVal, vm);
    Result := True;
  end
  else
  begin
    RetVal := Unassigned;
    Result := False;
  end;
end;

function TSciterLayout.Call(const Method: SciterString;
  const Args: array of OleVariant): OleVariant;
begin
  if not TryCall(Method, Args, Result) then
    raise ESciterCallException.Create(Method);
end;

procedure TSciterLayout.SetObject(const Name, Json: SciterString);
var
  var_name: tiscript_value;
  zns: tiscript_value;
  obj: tiscript_value;
  s: SciterString;
begin
  zns := NI.get_global_ns(vm);
  var_name  := NI.string_value(vm, PWideChar(Name), Length(Name));

  obj := JsonToTiScriptValue(Json);
  s := TiScriptValueToJson(obj);

  if not NI.set_prop(VM, zns, var_name, obj) then
    raise ESciterException.Create('Failed to set native object');
end;

function TSciterLayout.GetOnCreateNativeObject: TLayoutCreateNativeObjectProc;
begin
  Result := FOnCreateNativeObject;
end;

procedure TSciterLayout.SetOnCreateNativeObject(const Value: TLayoutCreateNativeObjectProc);
begin
  FOnCreateNativeObject := Value;
end;

function TSciterLayout.Eval(const Script: SciterString): OleVariant;
var
  pVal: SCITER_VALUE;
  pResult: OleVariant;
begin
  SAPI.ValueInit(pVal);
  if SAPI.SciterEval(GetHwnd, PWideChar(Script), Length(Script), pVal)  then
    S2V(pVal, pResult, GetHVM)       
  else
    pResult := Unassigned;
  Result := pResult;
end;

function TSciterLayout.Eval(const script: SciterString; const Args: array of const): OleVariant;
begin
  Result := Eval(WideFormat(script, Args));
end;

function TSciterLayout.Call(const Method: SciterString): OleVariant;
begin
  Result := Call(Method, []);
end;

function TSciterLayout.GetCurrentNS: tiscript_value;
begin
  Result := ni.get_current_ns(vm);
end;

function TSciterLayout.GetGlobalNS: tiscript_value;
begin
  Result := ni.get_global_ns(vm);
end;

function TSciterLayout.GetHtml: SciterString;
var
  pRoot: IDomElement;
begin
  pRoot := GetRootElement;
  if pRoot = nil then
    Result := ''
  else
    Result := pRoot.OuterHtml;
  pRoot := nil;
end;


function TSciterLayout.GetData1: Pointer;
begin
  Result := FData1;
end;

function TSciterLayout.GetData2: Pointer;
begin
  Result := FData2;
end;

function TSciterLayout.GetData3: IInterface;
begin
  Result := FData3;
end;

procedure TSciterLayout.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TSciterLayout.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

procedure TSciterLayout.SetData3(const Value: IInterface);
begin
  FData3 := Value;
end;

function TSciterLayout.LoadPluginByUrl(const AUrl: SciterString): TLoadDataResult;
begin
  if SciterLayout.LoadPluginByUrl(AUrl) then
    Result := LOAD_OK
  else
    Result := LOAD_DISCARD;
end;

function TSciterLayout.LoadPluginByPath(const APath: SciterString): TLoadDataResult;
begin
  if SciterLayout.LoadPluginByPath(APath) then
    Result := LOAD_OK
  else
    Result := LOAD_DISCARD;
end;

function TSciterLayout.GetAfterCreateBehavior: TLayoutAfterCreateBehaviorProc;
begin
  Result := FAfterCreateBehavior;
end;

procedure TSciterLayout.SetAfterCreateBehavior(const Value: TLayoutAfterCreateBehaviorProc);
begin
  FAfterCreateBehavior := Value;
end;

function TSciterLayout.GetAfterWndProc: TLayoutAfterWndProc;
begin
  Result := FAfterWndProc;
end;

function TSciterLayout.GetBeforeWndProc: TLayoutBeforeWndProc;
begin
  Result := FBeforeWndProc;
end;

procedure TSciterLayout.SetAfterWndProc(const Value: TLayoutAfterWndProc);
begin
  FAfterWndProc := Value;
end;

procedure TSciterLayout.SetBeforeWndProc(const Value: TLayoutBeforeWndProc);
begin
  FBeforeWndProc := Value;
end;

function TSciterLayout.GetOptions: TSciterLayoutOptions;
begin
  Result := FOptions;
end;

procedure TSciterLayout.SetOptions(const Value: TSciterLayoutOptions);
begin
  FOptions := Value;
end;

procedure TSciterLayout.DoHtmlLoaded;
var
  he: IDomElement;
  l, t, w, h: Integer;
  rcWnd: TRect;
begin
  if not IsWindow(GetHwnd) then
    Exit;
  if (sloUseHtmlTitle in FOptions)  then
  try
    he := RootElement.FindFirst('html > head > title');
    if he <> nil then
      SetWindowTextW(GetHwnd, PWideChar(he.Text));
  except
    on E: Exception do
      TraceException('[TSciterLayout.DoHtmlLoaded.sloUseHtmlTitle]'+E.Message);
  end;
  
  if (sloUseHtmlSize in FOptions) and (not IsIconic(GetHwnd)) then
  try
    GetWindowRect(GetHwnd, rcWnd);
    w := StrToIntDef(RootElement.Attributes['width'], 0);
    h := StrToIntDef(RootElement.Attributes['height'], 0);
    l := rcWnd.Left;
    t := rcWnd.Top;
    if w > 0 then
      l := rcWnd.Left + ((rcWnd.Right-rcWnd.Left) - w) div 2
    else
      w := (rcWnd.Right-rcWnd.Left);
    if h > 0 then
      t := rcWnd.Top + ((rcWnd.Bottom-rcWnd.Top) - h) div 2
    else
      h := (rcWnd.Bottom-rcWnd.Top);
    if (l <> rcWnd.Left) or (t <> rcWnd.Top) then
      SetWindowPos(GetHwnd, 0, l, t, w, h, SWP_NOZORDER or SWP_NOACTIVATE);
  except
    on E: Exception do
      TraceException('[TSciterLayout.DoHtmlLoaded.sloUseHtmlSize]'+E.Message);
  end;
end;

function TSciterLayout.AddAfterWndProc(
  const AWndProc: TLayoutAfterWndProc): Integer;
begin
  Result := FAfterWndProcList.Add(TMethod(AWndProc));
end;

function TSciterLayout.AddBeforeWndProc(
  const AWndProc: TLayoutBeforeWndProc): Integer;
begin
  Result := FBeforeWndProcList.Add(TMethod(AWndProc));
end;

function TSciterLayout.RemoveAfterWndProc(
  const AWndProc: TLayoutAfterWndProc): Integer;
begin
  if FAfterWndProcList <> nil then
    Result := FAfterWndProcList.Remove(TMethod(AWndProc))
  else
    Result := -1;
end;

function TSciterLayout.RemoveBeforeWndProc(
  const AWndProc: TLayoutBeforeWndProc): Integer;
begin
  if FBeforeWndProcList <> nil then
    Result := FBeforeWndProcList.Remove(TMethod(AWndProc))
  else
    Result := -1;
end;

function TSciterLayout.DoBeforeWndProc(
  msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var pbHandled: Boolean): LRESULT;
var
  i: Integer;
  LBeforeWndProc: TLayoutBeforeWndProc;
  pData: PMethod;
begin
  Result := 0;
  
  if @FBeforeWndProc <> nil then
  try
    Result := FBeforeWndProc(msg, wParam, lParam, pbHandled);
    if pbHandled then
      Exit;
  except
    on E: Exception do
      TraceException('[TSciterLayout.DoBeforeWndProc]['+IntToStr(msg)+']'+E.Message);
  end;

  for i := 0 to FBeforeWndProcList.Count - 1 do
  try
    pData := FBeforeWndProcList[i];
    if pData = nil then
      continue;
      
    TMethod(LBeforeWndProc) := pData^;
    if @LBeforeWndProc = nil then
      continue;

    Result := LBeforeWndProc(msg, wParam, lParam, pbHandled);
    if pbHandled then
      Exit;    
  except
    on E: Exception do
      TraceException('[TSciterLayout.DoBeforeWndProc]['+IntToStr(msg)+'][for:'+IntToStr(i)+']'+E.Message);
  end;
end;

procedure TSciterLayout.DoAfterWndProc(
  msg: UINT; wParam: WPARAM; lParam: LPARAM; var Result: LRESULT);
var
  i: Integer;
  LAfterWndProc: TLayoutAfterWndProc;
  pData: PMethod;
begin
  if @FAfterWndProc <> nil then
  try
    FAfterWndProc(msg, wParam, lParam, Result);
  except
    on E: Exception do
    begin
      TraceException('[TSciterLayout.DoAfterWndProc]['+IntToStr(msg)+']'+E.Message);
    end
  end;

  for i := 0 to FAfterWndProcList.Count - 1 do
  try
    pData := FAfterWndProcList[i];
    if pData = nil then
      continue;
      
    TMethod(LAfterWndProc) := pData^;
    if @LAfterWndProc = nil then
      continue;

    LAfterWndProc(msg, wParam, lParam, Result);
  except
    on E: Exception do
    begin
      TraceException('[TSciterLayout.DoAfterWndProc]['+IntToStr(msg)+'][for:'+IntToStr(i)+']'+E.Message);
    end
  end;
end;

function TSciterLayout.Implementor: Pointer;
begin
  Result := Self;
end;

function TSciterLayout._AddRef: Integer;
begin
  if Self = nil then
  begin
    Result := 0;
    Exit;
  end;
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _AddRef;
end;

function TSciterLayout._Release: Integer;
begin
  if Self = nil then
  begin
    Result := 0;
    Exit;
  end;
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _Release;
end;

procedure TSciterLayout.HandleGraphicsCriticalFailure(lpab: LPSCN_GRAPHICS_CRITICAL_FAILURE);
begin

end;

function TSciterLayout.GetOnGraphicsCriticalFailure: TLayoutGraphicsCriticalFailure;
begin
  Result := FOnGraphicsCriticalFailure;
end;

procedure TSciterLayout.SetOnGraphicsCriticalFailure(const Value: TLayoutGraphicsCriticalFailure);
begin
  FOnGraphicsCriticalFailure := Value;
end;

function TSciterLayout.GetMaxToFullScreen: Boolean;
var
  LRoot: IDomElement;
begin
  LRoot := Self.RootElement;
  Result := LRoot.IsValid and LRoot.HasAttribute('fullscreen');
end;

procedure TSciterLayout.SetMaxToFullScreen(const Value: Boolean);
var
  LRoot: IDomElement;
begin
  LRoot := Self.RootElement;
  if LRoot.IsValid then
    LRoot.Attributes['fullscreen'] := '';
end;

initialization
  varSciter4DPath := ExtractFilePath(GetModuleName(SysInit.HInstance))+DOMAIN_Sciter4D+'\';
  varAppPath := ChangeFileExt(GetModuleName(MainInstance), '\');

end.






