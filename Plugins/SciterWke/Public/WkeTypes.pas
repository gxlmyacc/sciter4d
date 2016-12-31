unit WkeTypes;

interface

{$I Wke.inc}

uses
  Windows;

const
  JSONObjectName = 'JSONObject';

type
  Utf8  = AnsiChar;
  PUtf8 = PAnsiChar;

  wchar_t  = WideChar;
  Pwchar_t = PWideChar;
  size_t = UINT;
  float = Single;

  {$IF not Declared(UnicodeString)}
  UnicodeString = WideString;
  {$IFEND}
  PUnicodeChar  = PWideChar;
  UnicodeChar   = WideChar;

  wkeString = type Pointer;

  wkeRect = record
    x: Integer;
    y: Integer;
    w: Integer;
    h: Integer;
  end;

const
  //wkeMouseFlags = (
    WKE_LBUTTON = $01;
    WKE_RBUTTON = $02;
    WKE_SHIFT   = $04;
    WKE_CONTROL = $08;
    WKE_MBUTTON = $10;
  //);

  //wkeKeyFlags = (
    WKE_EXTENDED = $0100;
    WKE_REPEAT = $4000;
  //);

  //wkeMouseMsg = (
    WKE_MSG_MOUSEMOVE       =  $0200;
    WKE_MSG_LBUTTONDOWN     =  $0201;
    WKE_MSG_LBUTTONUP       =  $0202;
    WKE_MSG_LBUTTONDBLCLK   =  $0203;
    WKE_MSG_RBUTTONDOWN     =  $0204;
    WKE_MSG_RBUTTONUP       =  $0205;
    WKE_MSG_RBUTTONDBLCLK   =  $0206;
    WKE_MSG_MBUTTONDOWN     =  $0207;
    WKE_MSG_MBUTTONUP       =  $0208;
    WKE_MSG_MBUTTONDBLCLK   =  $0209;
    WKE_MSG_MOUSEWHEEL      =  $020A;
  //);

  //wkeSettingMask = (
    WKE_SETTING_PROXY       = 1;
    WKE_SETTING_COOKIE_FILE_PATH = 1 shl 1;
  //);

type
  jsExecState = Pointer;
  jsValue     = Int64;
  PjsValue    = ^jsValue;

  JsValueArray  = array of jsValue;
  PJsValeuArray = ^JsValueArray;
  
  TWebView = Pointer;
  wkeWebView = TWebView;
  
  wkeProxyType = (
    WKE_PROXY_NONE,
    WKE_PROXY_HTTP,
    WKE_PROXY_SOCKS4,
    WKE_PROXY_SOCKS4A,
    WKE_PROXY_SOCKS5,
    WKE_PROXY_SOCKS5HOSTNAME
  );

  wkeProxy = packed record
    type_: wkeProxyType;
    hostname: array[0..99] of AnsiChar;
    port: Word;
    username: array[0..49] of AnsiChar;
    password: array[0..49] of AnsiChar;
  end;
  PwkeProxy = ^wkeProxy;

  wkeSettings = packed record
    proxy: wkeProxy;
    cookieFilePath: array[0..1023] of AnsiChar;
    mask: UINT;
  end;
  PwkeSettings = ^wkeSettings;

  FILE_OPEN = function (const path: PUtf8): Pointer; cdecl;
  FILE_CLOSE = procedure (handle: Pointer); cdecl;
  FILE_SIZE = function (handle: Pointer): size_t; cdecl;
  FILE_READ = function (handle: Pointer; buffer: Pointer; size: size_t): Integer; cdecl;
  FILE_SEEK = function (handle: Pointer; offset: Integer; origin: Integer): Integer; cdecl;

  jsNativeFunction = function (es: jsExecState): jsValue;

  PtagjsData = ^tagjsData;
  jsGetPropertyCallback = function(es: jsExecState; obj: jsValue; const propertyName: PAnsiChar): jsValue; cdecl;
  jsSetPropertyCallback = function(es: jsExecState; obj: jsValue; const propertyName: PAnsiChar; value: jsValue): Boolean; cdecl;
  jsCallAsFunctionCallback = function(es: jsExecState; obj: jsValue; args: PJsValeuArray; argCount: Integer): jsValue; cdecl;
  jsFinalizeCallback = procedure(data: PtagjsData); cdecl;

  tagjsData = packed record
    typeName: array[0..99] of AnsiChar;
    propertyGet: jsGetPropertyCallback;
    propertySet: jsSetPropertyCallback;
    finalize: jsFinalizeCallback;
    callAsFunction: jsCallAsFunctionCallback;
  end;
  jsData = tagjsData;
  PjsData = ^jsData;

  jsType = (
    JSTYPE_NUMBER,
    JSTYPE_STRING,
    JSTYPE_BOOLEAN,
    JSTYPE_OBJECT,
    JSTYPE_FUNCTION,
    JSTYPE_UNDEFINED
  );

  wkeMessageSource = (
    WKE_MESSAGE_SOURCE_HTML,
    WKE_MESSAGE_SOURCE_XML,
    WKE_MESSAGE_SOURCE_JS,
    WKE_MESSAGE_SOURCE_NETWORK,
    WKE_MESSAGE_SOURCE_CONSOLE_API,
    WKE_MESSAGE_SOURCE_OTHER
  );

  wkeMessageType = (
    WKE_MESSAGE_TYPE_LOG,
    WKE_MESSAGE_TYPE_DIR,
    WKE_MESSAGE_TYPE_DIR_XML,
    WKE_MESSAGE_TYPE_TRACE,
    WKE_MESSAGE_TYPE_START_GROUP,
    WKE_MESSAGE_TYPE_START_GROUP_COLLAPSED,
    WKE_MESSAGE_TYPE_END_GROUP,
    WKE_MESSAGE_TYPE_ASSERT
  );

  wkeMessageLevel = (
    WKE_MESSAGE_LEVEL_TIP,
    WKE_MESSAGE_LEVEL_LOG,
    WKE_MESSAGE_LEVEL_WARNING,
    WKE_MESSAGE_LEVEL_ERROR,
    WKE_MESSAGE_LEVEL_DEBUG
  );

  wkeConsoleMessage = packed record
    source: wkeMessageSource;
    type_: wkeMessageType;
    level: wkeMessageLevel;
    msg: wkeString;
    url: wkeString;
    lineNumber: Integer;
  end;
  PwkeConsoleMessage = ^wkeConsoleMessage;

  wkeNavigationType = (
    WKE_NAVIGATION_TYPE_LINKCLICK,
    WKE_NAVIGATION_TYPE_FORMSUBMITTE,
    WKE_NAVIGATION_TYPE_BACKFORWARD,
    WKE_NAVIGATION_TYPE_RELOAD,
    WKE_NAVIGATION_TYPE_FORMRESUBMITT,
    WKE_NAVIGATION_TYPE_OTHER
  );

  wkeNewViewInfo = packed record
    navigationType: wkeNavigationType;
    url: wkeString;
    target: wkeString;
    
    x: Integer;
    y: Integer;
    width: Integer;
    height: Integer;

    menuBarVisible: Boolean;
    statusBarVisible: Boolean;
    toolBarVisible: Boolean;
    locationBarVisible: Boolean;
    scrollbarsVisible: Boolean;
    resizable: Boolean;
    fullscreen: Boolean;
  end;
  PwkeNewViewInfo = ^wkeNewViewInfo;

  wkeLoadingResult = (
    WKE_LOADING_SUCCEEDED,
    WKE_LOADING_FAILED,
    WKE_LOADING_CANCELED
  );

  wkeWindowType = (
    WKE_WINDOW_TYPE_POPUP,
    WKE_WINDOW_TYPE_TRANSPARENT,
    WKE_WINDOW_TYPE_CONTROL
  );

  wkeDocumentReadyInfo = packed record
    url: wkeString;
    frameJSState: jsExecState;
    mainFrameJSState: jsExecState;
  end;
  PwkeDocumentReadyInfo = ^wkeDocumentReadyInfo;

  wkeCursorType = (
    WKE_CURSOR_POINTER,
    WKE_CURSOR_CROSS,
    WKE_CURSOR_HAND,
    WKE_CURSOR_IBEAM,
    WKE_CURSOR_WAIT,
    WKE_CURSOR_HELP,
    WKE_CURSOR_EASTRESIZE,
    WKE_CURSOR_NORTHRESIZE,
    WKE_CURSOR_NORTHEASTRESIZE,
    WKE_CURSOR_NORTHWESTRESIZE,
    WKE_CURSOR_SOUTHRESIZE,
    WKE_CURSOR_SOUTHEASTRESIZE,
    WKE_CURSOR_SOUTHWESTRESIZE,
    WKE_CURSOR_WESTRESIZE,
    WKE_CURSOR_NORTHSOUTHRESIZE,
    WKE_CURSOR_EASTWESTRESIZE,
    WKE_CURSOR_NORTHEASTSOUTHWESTRESIZE,
    WKE_CURSOR_NORTHWESTSOUTHEASTRESIZE,
    WKE_CURSOR_COLUMNRESIZE,
    WKE_CURSOR_ROWRESIE,
    WKE_CURSOR_MIDDLEPANNING,
    WKE_CURSOR_EASTPANNING,
    WKE_CURSOR_NORTHPANNING,
    WKE_CURSOR_NORTHEASTPANNING,
    WKE_CURSOR_NORTHWESTPANNING,
    WKE_CURSOR_SOUTHPANNING,
    WKE_CURSOR_SOUTHEASTPANNING,
    WKE_CURSOR_SOUTHWESTPANNING,
    WKE_CURSOR_WESTPANNING,
    WKE_CURSOR_MOVE,
    WKE_CURSOR_VERTICALTEXT,
    WKE_CURSOR_CELL,
    WKE_CURSOR_CONTEXTMENU,
    WKE_CURSOR_ALIAS,
    WKE_CURSOR_PROGRESS,
    WKE_CURSOR_NODROP,
    WKE_CURSOR_COPY,
    WKE_CURSOR_NONE,
    WKE_CURSOR_NOTALLOWED,
    WKE_CURSOR_ZOOMIN,
    WKE_CURSOR_ZOOMOUT,
    WKE_CURSOR_GRAB,
    WKE_CURSOR_GRABBING,
    WKE_CURSOR_CUSTOM
  );
  

  TwkeTitleChangedCallback = procedure (webView: wkeWebView; param: Pointer; const title: wkeString); cdecl;
  TwkeURLChangedCallback = procedure (webView: wkeWebView; param: Pointer; const url: wkeString); cdecl;
  TwkePaintUpdatedCallback = procedure (webView: wkeWebView; param: Pointer; const hdc: HDC; x, y, cx, cy: Integer); cdecl;
  TwkeAlertBoxCallback = procedure(webView: wkeWebView; param: Pointer; const msg: wkeString); cdecl;
  TwkeConfirmBoxCallback = function(webView: wkeWebView; param: Pointer; const msg: wkeString): Boolean; cdecl;
  TwkePromptBoxCallback = function(webView: wkeWebView; param: Pointer; const msg, defaultResult: wkeString; result: wkeString): Boolean; cdecl;
  TwkeConsoleMessageCallback = procedure(webView: wkeWebView; param: Pointer; const msg: PwkeConsoleMessage);cdecl;
  TwkeNavigationCallback = function(webView: wkeWebView; param: Pointer; navigationType: wkeNavigationType; const url: wkeString): Boolean;cdecl;
  TwkeCreateViewCallback = function(webView: wkeWebView; param: Pointer; const info: PwkeNewViewInfo): wkeWebView; cdecl;
  TwkeDocumentReadyCallback = procedure(webView: wkeWebView; param: Pointer; const info: PwkeDocumentReadyInfo);cdecl;
  TwkeLoadingFinishCallback = procedure(webView: wkeWebView; param: Pointer; const url: wkeString; result: wkeLoadingResult; const failedReason: wkeString); cdecl;
  TwkeWindowClosingCallback = function(webView: wkeWebView; param: Pointer): Boolean; cdecl;
  TwkeWindowDestroyCallback = procedure(webView: wkeWebView; param: Pointer); cdecl;


{$METHODINFO ON}
  IObjectInterface = interface
  ['{745C7A99-B138-490F-8999-840F8A3FB7E7}']
    function  Implementor: Pointer;
  end;
  
  TWkeRttiObject = class(TInterfacedObject, IObjectInterface)
  protected
    { IObjectInterface }
    function  Implementor: Pointer; virtual;
  end;
{$METHODINFO OFF}

implementation


{ TWkeRttiObject }

function TWkeRttiObject.Implementor: Pointer;
begin
  Result := Self;
end;

end.
