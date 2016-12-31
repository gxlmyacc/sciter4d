unit WkeIntf;

interface

uses
  Windows, WkeTypes;

type
  IWkeWebView = interface;
  IWkeJs = interface;

  IWkeWebBase = interface
  ['{E8396C1B-5B38-44DA-8218-C8F60F1E162E}']
    function GetWindowName: WideString;
    function GetHwnd: HWND;
    function GetResourceInstance: THandle;
    function GetBoundsRect: TRect;
    function GetDrawRect: TRect;
    function GetDrawDC: HDC;
    procedure ReleaseDC(const ADC: HDC);
  end;

  TWkeWebViewTitleChangeProc = procedure(const AWebView: IWkeWebView; const title: wkeString) of object;
  TWkeWebViewURLChangeProc = procedure(const AWebView: IWkeWebView; const url: wkeString) of object;
  TWkeWebViewPaintUpdatedProc = procedure(const AWebView: IWkeWebView; const hdc: HDC; x, y, cx, cy: Integer) of object;
  
  TWkeWebViewAlertBoxProc = procedure(const AWebView: IWkeWebView; const msg: wkeString; var bHandled: Boolean) of object;
  TWkeWebViewConfirmBoxProc = function(const AWebView: IWkeWebView; const msg: wkeString; var bHandled: Boolean): Boolean of object;
  TWkeWebViewPromptBoxProc = function(const AWebView: IWkeWebView; const msg, defaultResult, result: wkeString; var bHandled: Boolean): Boolean of object;
  TWkeWebViewConsoleMessageProc = procedure(const AWebView: IWkeWebView; const msg: PwkeConsoleMessage) of object;
  TWkeWebViewNavigationProc = function(const AWebView: IWkeWebView; navigationType: wkeNavigationType; const url: wkeString; var bHandled: Boolean): Boolean of object;
  TWkeWebViewCreateViewProc = function(const AWebView: IWkeWebView; info: PwkeNewViewInfo; var bHandled: Boolean): wkeWebView of object;
  TWkeWebViewDocumentReadyProc = procedure(const AWebView: IWkeWebView; const info: PwkeDocumentReadyInfo) of object;
  TWkeWebViewLoadingFinishProc = procedure(const AWebView: IWkeWebView; const url: wkeString; result: wkeLoadingResult; const failedReason: wkeString) of object;

  TWkeWindowClosingProc = function(const AWebView: IWkeWebView): Boolean of object;
  TWkeWindowDestroyProc = procedure(const AWebView: IWkeWebView) of object;

  TWkeContextMenuProc = procedure(const AWebView: IWkeWebView; x, y: Integer; flags: UINT) of object;
  TWkeWndProc = function (const AWebView: IWkeWebView; Msg: UINT;
    wParam: WPARAM; lParam: LPARAM; var bHandle: Boolean): LRESULT of object;
  TWkeWndDestoryProc = procedure(const AWebView: IWkeWebView) of object;
  TWkeInvalidateProc = procedure(const AWebView: IWkeWebView; var bHandled: Boolean) of object;

  IWkeWebView = interface
  ['{BE6B7350-E869-43AE-9602-EC4014278406}']
    function GetWebView: TWebView;
    function GetName: WideString;
    function GetTransparent: Boolean;
    function GetTitle: WideString;
    function GetUserAgent: WideString;
    function GetCookie: WideString;
    function GetHostWindow: HWND;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetContentWidth: Integer;
    function GetContentHeight: Integer;
    function GetViewDC(): Pointer;
    function GetCursorType: wkeCursorType;
    function GetDirty: Boolean;
    function GetFocused: Boolean;
    function GetCookieEnabled: Boolean;
    function GetMediaVolume: float;
    function GetCaretRect: wkeRect;
    function GetZoomFactor: float;
    function GetEnabled: Boolean;
    function GetRepaintIerntval: Integer;
    function GetJs: IWkeJs;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetOnTitleChange: TWkeWebViewTitleChangeProc;
    function GetOnURLChange: TWkeWebViewURLChangeProc;
    function GetOnPaintUpdated: TWkeWebViewPaintUpdatedProc;
    function GetOnAlertBox: TWkeWebViewAlertBoxProc;
    function GetOnConfirmBox: TWkeWebViewConfirmBoxProc;
    function GetOnConsoleMessage: TWkeWebViewConsoleMessageProc;
    function GetOnCreateView: TWkeWebViewCreateViewProc;
    function GetOnDocumentReady: TWkeWebViewDocumentReadyProc;
    function GetOnLoadingFinish: TWkeWebViewLoadingFinishProc;
    function GetOnNavigation: TWkeWebViewNavigationProc;
    function GetOnPromptBox: TWkeWebViewPromptBoxProc;
    function GetOnInvalidate: TWkeInvalidateProc;
    function GetOnContextMenu: TWkeContextMenuProc;
    function GetOnWndProc: TWkeWndProc;
    function GetOnWndDestory: TWkeWndDestoryProc;
    procedure SetName(const Value: WideString);
    procedure SetTransparent(const Value: Boolean);
    procedure SetUserAgent(const Value: WideString);
    procedure SetHostWindow(const Value: HWND);
    procedure SetDirty(const Value: Boolean);
    procedure SetCookieEnabled(const Value: Boolean);
    procedure SetMediaVolume(const Value: float);
    procedure SetZoomFactor(const Value: float);
    procedure SetEnabled(const Value: Boolean);
    procedure SetRepaintIerntval(const Value: Integer);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetOnTitleChange(const Value: TWkeWebViewTitleChangeProc);
    procedure SetOnURLChange(const Value: TWkeWebViewURLChangeProc);
    procedure SetOnPaintUpdated(const Value: TWkeWebViewPaintUpdatedProc);
    procedure SetOnAlertBox(const Value: TWkeWebViewAlertBoxProc);
    procedure SetOnConfirmBox(const Value: TWkeWebViewConfirmBoxProc);
    procedure SetOnConsoleMessage(const Value: TWkeWebViewConsoleMessageProc);
    procedure SetOnCreateView(const Value: TWkeWebViewCreateViewProc);
    procedure SetOnDocumentReady(const Value: TWkeWebViewDocumentReadyProc);
    procedure SetOnLoadingFinish(const Value: TWkeWebViewLoadingFinishProc);
    procedure SetOnNavigation(const Value: TWkeWebViewNavigationProc);
    procedure SetOnPromptBox(const Value: TWkeWebViewPromptBoxProc);
    procedure SetOnInvalidate(const Value: TWkeInvalidateProc);
    procedure SetOnContextMenu(const Value: TWkeContextMenuProc);
    procedure SetOnWndProc(const Value: TWkeWndProc);
    procedure SetOnWndDestory(const Value: TWkeWndDestoryProc);

    function ProcND(msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT;

    procedure Close;

    procedure Show(nCmdShow: Integer = SW_SHOW);
    procedure Hide;
    function  IsShowing: Boolean;

    procedure LoadURL(const url: WideString);
    procedure PostURL(const url: WideString; const postData: PAnsiChar; postLen: Integer);
    procedure LoadHTML(const html: WideString); overload;
    procedure LoadHTML(const html: PUtf8);  overload;
    procedure LoadFile(const filename: WideString);
    procedure Load(const str: PUtf8); overload;
    procedure Load(const str: WideString); overload;

    procedure Update;
    procedure Invalidate;
    
    function IsLoading: Boolean;
    function IsLoadSucceeded: Boolean; (*document load sucessed*)
    function IsLoadFailed: Boolean;    (*document load failed*)
    function IsLoadComplete: Boolean;  (*document load complete*)
    function IsDocumentReady: Boolean; (*document ready*)

    procedure StopLoading;
    procedure Reload;

    procedure Resize(w: Integer; h: Integer);

    procedure AddDirtyArea(x, y, w, h: Integer);

    procedure LayoutIfNeeded;
    function  RepaintIfNeeded: Boolean;
    function  RepaintIfNeededAfterInterval: Boolean;
    procedure Paint(bits: Pointer; pitch: Integer); overload;
    procedure Paint(bits: Pointer; bufWid, bufHei, xDst, yDst, w, h,
      xSrc, ySrc: Integer; bCopyAlpha: Boolean); overload;

    function CanGoBack: Boolean;
    function GoBack: Boolean;
    function CanGoForward: Boolean;
    function GoForward: Boolean;

    procedure EditerSelectAll;
    function  EditerCanCopy: Boolean;
    procedure EditerCopy;
    function  EditerCanCut: Boolean;
    procedure EditerCut;
    function  EditerCanPaste: Boolean;
    procedure EditerPaste;
    function  EditerCanDelete: Boolean;
    procedure EditerDelete;
    function  EditerCanUndo: Boolean;
    procedure EditerUndo;
    function  EditerCanRedo: Boolean;
    procedure EditerRedo;

    function MouseEvent(msg: UINT; x, y: Integer; flags: UINT): Boolean;
    function ContextMenuEvent(x, y: Integer; flags: UINT): Boolean;
    function MouseWheel(x, y, delta: Integer; flags: UINT): Boolean;
    function KeyUp(virtualKeyCode: UINT; flags: UINT; systemKey: Boolean): Boolean;
    function KeyDown(virtualKeyCode: UINT; flags: UINT; systemKey: Boolean): Boolean;
    function KeyPress(charCode: UINT; flags: UINT; systemKey: Boolean): Boolean;

    procedure SetFocus;
    procedure KillFocus;

    function RunJS(const script: PUtf8): jsValue; overload;
    function RunJS(const script: WideString): jsValue; overload;

    function GlobalExec: jsExecState;

    procedure Sleep(); //moveOffscreen
    procedure Wake();  //moveOnscreen
    function  IsAwake: Boolean;

    procedure SetEditable(editable: Boolean);

    procedure BindObject(const objName: WideString; obj: TObject);
    procedure UnbindObject(const objName: WideString);

    property WebView: TWebView read GetWebView;

    property Name: WideString read GetName write SetName;
    property Transparent: Boolean read GetTransparent write SetTransparent;
    property Title: WideString read GetTitle;
    property UserAgent: WideString read GetUserAgent write SetUserAgent;
    property Cookie: WideString read GetCookie;

    property HostWindow: HWND read GetHostWindow write SetHostWindow;
    property Width: Integer read GetWidth;    (*viewport width*)
    property Height: Integer read GetHeight;  (*viewport height*)

    property ContentWidth: Integer read GetContentWidth;    (*contents width*)
    property ContentHeight: Integer read GetContentHeight;  (*contents height*)

    property CursorType: wkeCursorType read GetCursorType;
    property IsFocused: Boolean read GetFocused;
    property IsDirty: Boolean read GetDirty write SetDirty;
    property CookieEnabled: Boolean read GetCookieEnabled write SetCookieEnabled;
    property MediaVolume: float read GetMediaVolume write SetMediaVolume;
    property CaretRect: wkeRect read GetCaretRect;
    property ZoomFactor: float read GetZoomFactor write SetZoomFactor;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property RepaintIerntval: Integer read GetRepaintIerntval write SetRepaintIerntval;
    property Js: IWkeJs read GetJs;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;

    property OnTitleChange: TWkeWebViewTitleChangeProc read GetOnTitleChange write SetOnTitleChange;
    property OnURLChange: TWkeWebViewURLChangeProc read GetOnURLChange write SetOnURLChange;
    property OnPaintUpdated: TWkeWebViewPaintUpdatedProc read GetOnPaintUpdated write SetOnPaintUpdated;
    property OnAlertBox: TWkeWebViewAlertBoxProc read GetOnAlertBox write SetOnAlertBox;
    property OnConfirmBox: TWkeWebViewConfirmBoxProc read GetOnConfirmBox write SetOnConfirmBox;
    property OnPromptBox: TWkeWebViewPromptBoxProc read GetOnPromptBox write SetOnPromptBox;
    property OnConsoleMessage: TWkeWebViewConsoleMessageProc read GetOnConsoleMessage write SetOnConsoleMessage;
    property OnNavigation: TWkeWebViewNavigationProc read GetOnNavigation write SetOnNavigation;
    property OnCreateView: TWkeWebViewCreateViewProc read GetOnCreateView write SetOnCreateView;
    property OnDocumentReady: TWkeWebViewDocumentReadyProc read GetOnDocumentReady write SetOnDocumentReady;
    property OnLoadingFinish: TWkeWebViewLoadingFinishProc read GetOnLoadingFinish write SetOnLoadingFinish;
    property OnInvalidate: TWkeInvalidateProc read GetOnInvalidate write SetOnInvalidate;
    property OnContextMenu: TWkeContextMenuProc read GetOnContextMenu write SetOnContextMenu;
    property OnWndProc: TWkeWndProc read GetOnWndProc write SetOnWndProc;
    property OnWndDestory: TWkeWndDestoryProc read GetOnWndDestory write SetOnWndDestory;
  end;

  IWkeWindow = interface(IWkeWebView)
  ['{118FFC2A-9D80-46C1-823D-0A35DFDFDA1D}']
    function GetTitle: WideString;
    function GetWindowHandle: HWND;
    function GetWindowType: wkeWindowType;
    function GetIsModaling: Boolean;
    function GetModalCode: Integer;
    function GetOnClosing: TWkeWindowClosingProc;
    function GetOnDestroy: TWkeWindowDestroyProc;
    procedure SetTitle(const AValue: WideString);
    procedure SetModalCode(const Value: Integer);
    procedure SetOnClosing(const AValue: TWkeWindowClosingProc);
    procedure SetOnDestroy(const AValue: TWkeWindowDestroyProc);

    procedure ShowWindow();
    procedure HideWindow();
    procedure EnableWindow(enable: Boolean);
    procedure CloseWindow;
    procedure DestroyWindow;

    function  ShowModal(AParent: HWND = 0): Integer;
    procedure EndModal(nCode: Integer);

    procedure MoveWindow(x, y, width, height: Integer);
    procedure MoveToCenter;
    procedure ResizeWindow(width, height: Integer);

    property Title: WideString read GetTitle write SetTitle;
    property WindowHandle: HWND read GetWindowHandle;
    property WindowType: wkeWindowType read GetWindowType;
    property IsModaling: Boolean read GetIsModaling;
    property ModalCode: Integer read GetModalCode write SetModalCode;
    property OnClosing: TWkeWindowClosingProc read GetOnClosing write SetOnClosing;
    property OnDestroy: TWkeWindowDestroyProc read GetOnDestroy write SetOnDestroy;
  end;

  IWkeJsValue = interface;

  IWkeJsExecState = interface
  ['{5D6249B4-0BA3-4E3C-91FA-782889265C06}']
    function GetWebView: TWebView;
    function GetProp(const AProp: WideString): IWkeJsValue;
    function GetExecState: jsExecState;
    function GetArg(const argIdx: Integer): IWkeJsValue;
    function GetArgCount: Integer;
    function GetArgType(const argIdx: Integer): jsType;
    function GetGlobalObject: IWkeJsValue;
    function GetData1: Pointer;
    function GetData2: Pointer;
    procedure SetProp(const AProp: WideString; const Value: IWkeJsValue);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);

    function jsInt(n: Integer): IWkeJsValue;
    function jsFloat(n: float): IWkeJsValue;
    function jsDouble(n: Double): IWkeJsValue;
    function jsBoolean(n: Boolean): IWkeJsValue;
    function jsUndefined(): IWkeJsValue;
    function jsNull(): IWkeJsValue;
    function jsTrue(): IWkeJsValue;
    function jsFalse(): IWkeJsValue;
    function jsString(const str: PUtf8): IWkeJsValue;
    function jsStringW(const str: Pwchar_t): IWkeJsValue;
    function jsObject(): IWkeJsValue;
    function jsArray(): IWkeJsValue;
    function jsFunction(fn: jsNativeFunction; argCount: Integer): IWkeJsValue;

    function Eval(const str: PUtf8): IWkeJsValue;
    function EvalW(const str: Pwchar_t): IWkeJsValue;

    function CallGlobal(func: jsValue; args: array of OleVariant): OleVariant; overload;
    function CallGlobal(const func: WideString; args: array of OleVariant): OleVariant; overload;
    function CallGlobalEx(func: jsValue; args: array of IWkeJsValue): IWkeJsValue; overload;
    function CallGlobalEx(const func: WideString; args: array of IWkeJsValue): IWkeJsValue; overload;

    function PropExist(const AProp: WideString): Boolean;

    procedure BindFunction(const name: WideString; fn: jsNativeFunction; argCount: Integer);
    procedure UnbindFunction(const name: WideString);
    procedure BindObject(const objName: WideString; obj: TObject);
    procedure UnbindObject(const objName: WideString);

    function CreateJsObject(obj: TObject): jsValue;
    
    property ExecState: jsExecState read GetExecState;
    //return the window object
    property GlobalObject: IWkeJsValue read GetGlobalObject;
    
    property Prop[const AProp: WideString]: IWkeJsValue read GetProp write SetProp;
    property ArgCount: Integer read GetArgCount;
    property ArgType[const argIdx: Integer]: jsType read GetArgType;
    property Arg[const argIdx: Integer]: IWkeJsValue read GetArg;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;

    property WebView: TWebView read GetWebView;
  end;

  IWkeJsObject = interface;

  IWkeJsValue = interface
  ['{7528CD28-D691-4B16-8AC3-FAC773D0F94B}']
    function GetExecState: jsExecState;
    function GetValue: jsValue;
    function GetValueType: jsType;
    function GetData1: Pointer;
    function GetData2: Pointer;
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);

    function IsNumber: Boolean;
    function IsString: Boolean;
    function IsBoolean: Boolean;
    function IsObject: Boolean;
    function IsFunction: Boolean;
    function IsUndefined: Boolean;
    function IsNull: Boolean;
    function IsArray: Boolean;
    function IsTrue: Boolean;
    function IsFalse: Boolean;

    function ToInt: Integer;
    function ToFloat: float;
    function ToDouble: Double;
    function ToBoolean: Boolean;
    function ToStringA: PUtf8;
    function ToStringW: Pwchar_t;
    function ToObject: IWkeJsObject;

    procedure SetAsInt(n: Integer);
    procedure SetAsFloat(n: float);
    procedure SetAsDouble(n: Double);
    procedure SetAsBoolean(n: Boolean);
    procedure SetAsUndefined();
    procedure SetAsNull();
    procedure SetAsTrue();
    procedure SetAsFalse();
    procedure SetAsString(const str: PUtf8);
    procedure SetAsStringW(const str: Pwchar_t);
    procedure SetAsObject(v: jsValue);
    procedure SetAsArray(v: jsValue);
    procedure SetAsFunction(fn: jsNativeFunction; argCount: Integer);

    property ExecState: jsExecState read GetExecState;
    property Value: jsValue read GetValue;
    property ValueType: jsType read GetValueType;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

  IWkeJsObject = interface(IWkeJsValue)
  ['{7B4DF4BE-EB7E-4738-8F08-47C33857F6D8}']
    function GetProp(const AName: WideString): IWkeJsValue;
    function GetPropAt(const AIndex: Integer): IWkeJsValue;
    function GetLength: Integer;
    procedure SetProp(const AName: WideString; const Value: IWkeJsValue);
    procedure SetPropAt(const AIndex: Integer; const Value: IWkeJsValue);
    procedure SetLength(const Value: Integer);

    function Call(func: jsValue; args: array of OleVariant): OleVariant; overload;
    function Call(const func: WideString; args: array of OleVariant): OleVariant; overload;
    function CallEx(func: jsValue; args: array of IWkeJsValue): IWkeJsValue; overload;
    function CallEx(const func: WideString; args: array of IWkeJsValue): IWkeJsValue; overload;

    function PropExist(const AProp: WideString): Boolean;

    property Length: Integer read GetLength write SetLength;
    property Prop[const AName: WideString]: IWkeJsValue read GetProp write SetProp;
    property PropAt[const AIndex: Integer]: IWkeJsValue read GetPropAt write SetPropAt;
  end;

  IWkeJsObjectRegInfo = interface
  ['{1C6015CD-6E76-4B6A-8302-5B49E283B198}']
    function GetName: WideString;
    function GetValue: TObject;
    procedure SetName(const Value: WideString);
    procedure SetValue(const Value: TObject);

    property Name: WideString read GetName write SetName;
    property Value: TObject read GetValue write SetValue;
  end;

  TWkeJsObjectAction = (woaReg, woaUnreg, woaChanged);
  TWkeJsObjectListener = procedure (const AInfo: IWkeJsObjectRegInfo; Action: TWkeJsObjectAction) of object;

  IWkeJsObjectList = interface
  ['{C4752C12-92DC-4264-8DFF-B0C5C53D9C25}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IWkeJsObjectRegInfo;
    function  GetItemName(const Index: Integer): WideString;
    function  GetItemByName(const AName: WideString): IWkeJsObjectRegInfo;
    function  GetData1: Pointer;
    function  GetData2: Pointer;
    procedure SetItem(const Index: Integer; const Value: IWkeJsObjectRegInfo);
    procedure SetItemByName(const AName: WideString; const Value: IWkeJsObjectRegInfo);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);

    procedure Invalidate;

    function  Reg(const AName: WideString; const AItem: TObject): Integer;
    procedure UnReg(const Index: Integer); overload;
    procedure UnReg(const AName: WideString); overload;
    procedure Clear;
    
    function  IndexOf(const AItem: TObject): Integer;
    function  IndexOfName(const AName: WideString): Integer;
    
    function AddListener(const AListener: TWkeJsObjectListener): Integer;
    function RemoveListener(const AListener: TWkeJsObjectListener): Integer;
    
    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IWkeJsObjectRegInfo read GetItem write SetItem; default;
    property ItemName[const Index: Integer]: WideString read GetItemName;
    property ItemByName[const AName: WideString]: IWkeJsObjectRegInfo read GetItemByName write SetItemByName;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

  IWkeJs = interface
  ['{78D78225-D8EF-4960-8EAD-87191C1065B8}']
    function GetGlobalExec: IWkeJsExecState;
    function GetData1: Pointer;
    function GetData2: Pointer;
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    
    procedure BindFunction(const name: WideString; fn: jsNativeFunction; argCount: Integer);
    procedure UnbindFunction(const name: WideString);
    procedure BindObject(const objName: WideString; obj: TObject);
    procedure UnbindObject(const objName: WideString);
    
    procedure BindGetter(const name: WideString; fn: jsNativeFunction);
    procedure BindSetter(const name: WideString; fn: jsNativeFunction);

    function CreateJsObject(obj: TObject): jsValue;

    procedure GC();

    property GlobalExec: IWkeJsExecState read GetGlobalExec;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;
  
  IWkeFileSystem = interface
  ['{FDF02472-1B02-4E43-9E79-398249F10B5A}']
    function  Open(const path: PUtf8): Boolean;
    procedure Close;
    
    function  Size: Cardinal;
    function  Read(buffer: Pointer; size: Cardinal): Integer;
    function  Seek(offset: Integer; origin: Integer): Integer;
  end;

  TWkeGetFileSystemProc = function(const path: PUtf8; var Handled: Boolean): IWkeFileSystem of object;
  TWkeGetWkeWebBaseProc = function(const AFilter: WideString; const ATag: Pointer): IWkeWebBase of object;
  
  PIWke = ^IWke;
  IWke = interface
  ['{788F9BAC-A483-4097-9581-F7B4F30CF8EC}']
    function GetDriverName: WideString;
    function GetSettings: wkeSettings;
    function GetWkeVersion: WideString;
    function GetGlobalObjects(): IWkeJsObjectList;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetOnGetFileSystem: TWkeGetFileSystemProc;
    function GetOnGetWkeWebBase: TWkeGetWkeWebBaseProc;
    procedure SetDriverName(const Value: WideString);
    procedure SetSettings(const Value: wkeSettings);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetOnGetFileSystem(const Value: TWkeGetFileSystemProc);
    procedure SetOnGetWkeWebBase(const Value: TWkeGetWkeWebBaseProc);

    procedure Configure(const settings: wkeSettings);

    function CreateWebView(const AThis: IWkeWebBase): IWkeWebView; overload;
    function CreateWebView(const AThis: IWkeWebBase; const AWebView: TWebView;
      const AOwnView: Boolean = True): IWkeWebView; overload;
    function CreateWebView(const AFilter: WideString = '';
      const ATag: Pointer = nil): IWkeWebView; overload;
    function CreateWindow(type_: wkeWindowType; parent: HWND; x, y,
      width, height: Integer): IWkeWindow;

    function  RunAppclition(const MainWnd: HWND): Integer;
    procedure ProcessMessages;
    procedure Terminate;
    
    function GetString(const str: wkeString): PUtf8;
    function GetStringW(const str: wkeString): Pwchar_t;

    function CreateExecState(const AExecState: JsExecState): IWkeJsExecState;
    function CreateJsValue(const AExecState: JsExecState): IWkeJsValue; overload;
    function CreateJsValue(const AExecState: JsExecState; const AValue: jsValue): IWkeJsValue; overload;

    procedure BindFunction(const name: WideString; fn: jsNativeFunction; argCount: Integer); overload;
    procedure BindFunction(es: jsExecState; const name: WideString; fn: jsNativeFunction; argCount: Integer); overload;
    procedure UnbindFunction(const name: WideString); overload;
    procedure UnbindFunction(es: jsExecState; const name: WideString); overload;
    procedure BindGetter(const name: WideString; fn: jsNativeFunction);
    procedure BindSetter(const name: WideString; fn: jsNativeFunction);

    procedure BindObject(es: jsExecState; const objName: WideString; obj: TObject);
    procedure UnbindObject(es: jsExecState; const objName: WideString);

    function CreateJsObject(es: jsExecState; obj: TObject): jsValue;

    function CreateFileSystem(const path: PUtf8): IWkeFileSystem;
    function CreateDefaultFileSystem(): IWkeFileSystem;

    property DriverName: WideString read GetDriverName write SetDriverName;
    property Settings: wkeSettings read GetSettings write SetSettings;
    property WkeVersion: WideString read GetWkeVersion;
    property GlobalObjects: IWkeJsObjectList read GetGlobalObjects;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;

    property OnGetFileSystem: TWkeGetFileSystemProc read GetOnGetFileSystem write SetOnGetFileSystem;
    property OnGetWkeWebBase: TWkeGetWkeWebBaseProc read GetOnGetWkeWebBase write SetOnGetWkeWebBase;
  end;

function Wke: IWke;

implementation

uses
  WkeImportDefs;

function Wke: IWke;
type
  TWke = function(): PIWke;
begin
  Assert(WkeExports<>nil);
  Result := TWke(WkeExports.Funcs[FuncIdx_Wke])^;
end;

end.
