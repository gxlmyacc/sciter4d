{*******************************************************************************
 标题:     SciterTypes.pas
 描述:     Sciter类型定义
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterTypes;

interface

{$I Sciter.inc}

uses
  Windows;

type
  HWINDOW   = HWND;

  wchar_t   = WCHAR;
  uint16_t  = WCHAR;

  {$IF not Declared(UINT_PTR)}
  UINT_PTR  = Cardinal;
  {$IFEND}
  PINT_PTR  = ^UINT_PTR;
  size_t    = UINT_PTR;

  LPVOID    = Pointer;
  LPCVOID   = ^LPVOID;
  LPUINT    = ^UINT;
  LPCBYTE   = PByte;
  LPRECT    = ^TRect;
  LPPoint   = ^TPoint;

  PColor = ^TColor;
  TColor = -$7FFFFFFF-1..$7FFFFFFF;

  {$IF not Declared(TBytes)}
  TBytes = array of Byte;
  PBytes = ^TBytes;
  {$IFEND}
  {$IF not Declared(TDynPointerArray)}
  TDynPointerArray = array of Pointer;
  {$IFEND}

  PMethod = ^TMethod;

  HELEMENT  = type Pointer;
  PHELEMENT = ^HELEMENT;
  HNODE     = type Pointer;
  HRANGE    = type Pointer;
  HSARCHIVE = type Pointer;

  //namespace gool {
  HGFX      = type Pointer;
  HIMG      = type Pointer;
  HPATH     = type Pointer;
  HTEXT     = type Pointer;
  //}

  PHGFX     = ^HGFX;

  sciter_request = record end;
  HREQUEST = ^sciter_request;

  SciterString = {$IF CompilerVersion >= 18.5}WideString{$ELSE}WideString{$IFEND};
  PSciterString = ^SciterString;
  PSciterChar   = PWideChar;
  SciterChar    = WideChar;
  JSONObject   = type SciterString;
  PJSONObject  = PWideChar;
  FLOAT_VALUE  = Double;

  HPosition = record
    hn:  HNODE;
    pos: Integer;
  end;

  SCDOM_RESULT  = Integer;

  VALUE_TYPE = (
    T_UNDEFINED = 0,
    T_NULL = 1,
    T_BOOL,
    T_INT,
    T_FLOAT,
    T_STRING,
    T_DATE,     // INT64 - contains a 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 (UTC), a.k.a. FILETIME on Windows
    T_CURRENCY, // INT64 - 14.4 fixed number. E.g. dollars = int64 / 10000; 
    T_LENGTH,   // length units, value is int or float, units are VALUE_UNIT_TYPE
    T_ARRAY,
    T_MAP,
    T_FUNCTION,
    T_BYTES,      // sequence of bytes - e.g. image data
    T_OBJECT,     // scripting object proxy (TISCRIPT/SCITER)
    T_DOM_OBJECT  // DOM object, use get_object_data to get HELEMENT 
  );
  TDomValueType = VALUE_TYPE;

  PSCITER_VALUE= ^SCITER_VALUE;
  SCITER_VALUE = record
    t: VALUE_TYPE;
    u: UINT;  //< VALUE_UNIT_TYPE or VALUE_UNIT_TYPE_OBJECT 
    d: UInt64;
  end;
  SCITER_VALUE_ARRAY  = array of SCITER_VALUE;
  PSCITER_VALUE_ARRAY = ^SCITER_VALUE_ARRAY;

  JsonValue     = SCITER_VALUE;
  PJsonValue    = ^JsonValue;

  tiscript_VM = record
  end;
  Ptiscript_VM   = ^tiscript_VM;
  HVM            = Ptiscript_VM;

  { TIScript value }
  tiscript_value = type Int64;
  Ptiscript_value =^tiscript_value;
  tiscript_value_array = array[Word] of tiscript_value;
  Ptiscript_value_array = ^tiscript_value_array;

  { TIScript value handy synonyms }
  tiscript_class  = type tiscript_value;
  tiscript_object = type tiscript_value;

  tiscript_native_method = function (vm: HVM; this, super: tiscript_value;
    argCount: Integer; args: Ptiscript_value_array; tag: Pointer): tiscript_value;
  
const
  MaxParams = 32;

  JSONObjectName = 'JSONObject';

  //VALUE_RESULT = (
    HV_OK_TRUE = -1;
    HV_OK = 0;
    HV_BAD_PARAMETER = 1;
    HV_INCOMPATIBLE_TYPE = 2;
  //);
  //THtmlValueResult = VALUE_RESULT;

  //VALUE_UNIT_TYPE = (
    UT_EM = 1; //height of the element's font.
    UT_EX = 2; //height of letter 'x'
    UT_PR = 3; //%
    UT_SP = 4; //%% "springs", a.k.a. flex units
    reserved1 = 5;
    reserved2 = 6;
    UT_PX = 7; //pixels
    UT_IN = 8; //inches (1 inch = 2.54 centimeters).
    UT_CM = 9; //centimeters.
    UT_MM = 10; //millimeters.
    UT_PT = 11; //points (1 point = 1/72 inches). 
    UT_PC = 12; //picas (1 pica = 12 points).
    UT_DIP = 13;
    reserved3 = 14;
    UT_COLOR = 15; // color in int
    UT_URL   = 16;  // url in string
  //);
  //TDomValueUnitType = VALUE_UNIT_TYPE;

  // Sciter or TIScript specific
  //VALUE_UNIT_TYPE_OBJECT = (
    UT_OBJECT_ARRAY  = 0;   // type T_OBJECT of type Array
    UT_OBJECT_OBJECT = 1;   // type T_OBJECT of type Object
    UT_OBJECT_CLASS  = 2;   // type T_OBJECT of type Type (class or namespace)
    UT_OBJECT_NATIVE = 3;   // type T_OBJECT of native Type with data slot (LPVOID)
    UT_OBJECT_FUNCTION = 4; // type T_OBJECT of type Function
    UT_OBJECT_ERROR = 5;    // type T_OBJECT of type Error
  //);
  //THtmlValueUnitTypeObject = VALUE_UNIT_TYPE_OBJECT;


  // Sciter or TIScript specific
  //VALUE_UNIT_TYPE_STRING = (
      UT_STRING_STRING = 0;        // string
      UT_STRING_ERROR  = 1;        // is an error string
      UT_STRING_SECURE = 2;        // secure string ("wiped" on destroy)
      UT_STRING_SYMBOL = $ffff;    // symbol in tiscript sense
  //);


  //BEHAVIOR_EVENTS = (
      BUTTON_CLICK = 0;              // click on button
      BUTTON_PRESS = 1;              // mouse down or key down in button
      BUTTON_STATE_CHANGED = 2;      // checkbox/radio/slider changed its state/value
      EDIT_VALUE_CHANGING = 3;       // before text change
      EDIT_VALUE_CHANGED = 4;        // after text change
      SELECT_SELECTION_CHANGED = 5;  // selection in <select> changed
      SELECT_STATE_CHANGED = 6;      // node in select expanded/collapsed, heTarget is the node

      POPUP_REQUEST   = 7;           // request to show popup just received,
                                     //     here DOM of popup element can be modifed.
      POPUP_READY     = 8;           // popup element has been measured and ready to be shown on screen,
                                     //     here you can use functions like ScrollToView.
      POPUP_DISMISSED = 9;           // popup element is closed,
                                     //     here DOM of popup element can be modifed again - e.g. some items can be removed
                                     //     to free memory.

      MENU_ITEM_ACTIVE = $A;        // menu item activated by mouse hover or by keyboard,
      MENU_ITEM_CLICK = $B;         // menu item click,
                                     //   BEHAVIOR_EVENT_PARAMS structure layout
                                     //   BEHAVIOR_EVENT_PARAMS.cmd - MENU_ITEM_CLICK/MENU_ITEM_ACTIVE
                                     //   BEHAVIOR_EVENT_PARAMS.heTarget - owner(anchor) of the menu
                                     //   BEHAVIOR_EVENT_PARAMS.he - the menu item, presumably <li> element
                                     //   BEHAVIOR_EVENT_PARAMS.reason - BY_MOUSE_CLICK | BY_KEY_CLICK


      CONTEXT_MENU_REQUEST = $10;   // "right-click", BEHAVIOR_EVENT_PARAMS::he is current popup menu HELEMENT being processed or NULL.
                                     // application can provide its own HELEMENT here (if it is NULL) or modify current menu element.

      VISIUAL_STATUS_CHANGED = $11; // broadcast notification, sent to all elements of some container being shown or hidden
      DISABLED_STATUS_CHANGED = $12;// broadcast notification, sent to all elements of some container that got new value of :disabled state

      POPUP_DISMISSING = $13;       // popup is about to be closed

      CONTENT_CHANGED = $15;        // content has been changed, is posted to the element that gets content changed,  reason is combination of CONTENT_CHANGE_BITS.
                                     // target == NULL means the window got new document and this event is dispatched only to the window.

      CLICK = $16;                  // generic click
      CHANGE = $17;                 // generic change

      // "grey" event codes  - notfications from behaviors from this SDK
      HYPERLINK_CLICK = $80;        // hyperlink click

      //TABLE_HEADER_CLICK,            // click on some cell in table header,
      //                               //     target = the cell,
      //                               //     reason = index of the cell (column number, 0..n)
      //TABLE_ROW_CLICK,               // click on data row in the table, target is the row
      //                               //     target = the row,
      //                               //     reason = index of the row (fixed_rows..n)
      //TABLE_ROW_DBL_CLICK,           // mouse dbl click on data row in the table, target is the row
      //                               //     target = the row,
      //                               //     reason = index of the row (fixed_rows..n)

      ELEMENT_COLLAPSED = $90;      // element was collapsed, so far only behavior:tabs is sending these two to the panels
      ELEMENT_EXPANDED  = $91;      // element was expanded,

      ACTIVATE_CHILD    = $92;       // activate (select) child,
                                     // used for example by accesskeys behaviors to send activation request, e.g. tab on behavior:tabs.

      //DO_SWITCH_TAB = ACTIVATE_CHILD,// command to switch tab programmatically, handled by behavior:tabs
      //                               // use it as HTMLayoutPostEvent(tabsElementOrItsChild, DO_SWITCH_TAB, tabElementToShow, 0);

      INIT_DATA_VIEW    = $93;       // request to virtual grid to initialize its view
      
      ROWS_DATA_REQUEST = $94;         // request from virtual grid to data source behavior to fill data in the table
                                      // parameters passed throug DATA_ROWS_PARAMS structure.

      UI_STATE_CHANGED = $95;        // ui state changed, observers shall update their visual states.
                                     // is sent for example by behavior:richtext when caret position/selection has changed.

      FORM_SUBMIT      = $96;        // behavior:form detected submission event. BEHAVIOR_EVENT_PARAMS::data field contains data to be posted.
                                     // BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about 
                                     // to be submitted. You can modify the data or discard submission by returning true from the handler.
      FORM_RESET       = $97;        // behavior:form detected reset event (from button type=reset). BEHAVIOR_EVENT_PARAMS::data field contains data to be reset.
                                     // BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
                                     // to be rest. You can modify the data or discard reset by returning true from the handler.

      DOCUMENT_COMPLETE = $98;       // document in behavior:frame or root document is complete.

      HISTORY_PUSH      = $99;      // requests to behavior:history (commands)
      HISTORY_DROP      = $9A;
      HISTORY_PRIOR     = $9B;
      HISTORY_NEXT      = $9C;
      HISTORY_STATE_CHANGED = $9D;  // behavior:history notification - history stack has changed
      
      CLOSE_POPUP           = $9E;   // close popup request,
      REQUEST_TOOLTIP       = $9F;   // request tooltip, evt.source <- is the tooltip element.

      ANIMATION         = $A0;      // animation started (reason=1) or ended(reason=0) on the element.
      DOCUMENT_CREATED  = $C0;      // document created, script namespace initialized. target -> the document
      DOCUMENT_CLOSE_REQUEST = $C1; // document is about to be closed, to cancel closing do: evt.data = sciter::value("cancel");
      DOCUMENT_CLOSE    = $C2;      // last notification before document removal from the DOM
      DOCUMENT_READY    = $C3;      // document has got DOM structure, styles and behaviors of DOM elements. Script loading run is complete at this moment. 


      VIDEO_INITIALIZED = $D1;      // <video> "ready" notification
      VIDEO_STARTED     = $D2;      // <video> playback started notification
      VIDEO_STOPPED     = $D3;      // <video> playback stoped/paused notification
      VIDEO_BIND_RQ     = $D4;      // <video> request for frame source binding,
                                     //   If you want to provide your own video frames source for the given target <video> element do the following:
                                     //   1. Handle and consume this VIDEO_BIND_RQ request 
                                     //   2. You will receive second VIDEO_BIND_RQ request/event for the same <video> element
                                     //      but this time with the 'reason' field set to an instance of sciter::video_destination interface.
                                     //   3. add_ref() it and store it for example in worker thread producing video frames.
                                     //   4. call sciter::video_destination::start_streaming(...) providing needed parameters
                                     //      call sciter::video_destination::render_frame(...) as soon as they are available
                                     //      call sciter::video_destination::stop_streaming() to stop the rendering (a.k.a. end of movie reached)

      PAGINATION_STARTS  = $E0;     // behavior:pager starts pagination
      PAGINATION_PAGE    = $E1;     // behavior:pager paginated page no, reason -> page no
      PAGINATION_ENDS    = $E2;     // behavior:pager end pagination, reason -> total pages

      FIRST_APPLICATION_EVENT_CODE = $100;
      // all custom event codes shall be greater
      // than this number. All codes below this will be used
      // solely by application - HTMLayout will not intrepret it
      // and will do just dispatching.
      // To send event notifications with  these codes use
      // HTMLayoutSend/PostEvent API.
  //);
  //TBehaviorEvent = BEHAVIOR_EVENTS;

  //EVENT_REASON = (
    BY_MOUSE_CLICK = 0;
    BY_KEY_CLICK   = 1;
    SYNTHESIZED    = 2;  // synthesized, programmatically generated.
  //);
  //TEventReason = EVENT_REASON;

  //EDIT_CHANGED_REASON = (
    BY_INS_CHAR  = 0;  // single char insertion
    BY_INS_CHARS = 1; // character range insertion, clipboard
    BY_DEL_CHAR  = 2;  // single char deletion
    BY_DEL_CHARS = 3;  // character range deletion (selection)
  //);
  //TEditChangedReason = EDIT_CHANGED_REASON;

type
  VALUE_UNIT_TYPE_DATE = (
    DT_HAS_DATE         = $01, // date contains date portion
    DT_HAS_TIME         = $02, // date contains time portion HH:MM
    DT_HAS_SECONDS      = $04, // date contains time and seconds HH:MM:SS
    DT_UTC              = $10  // T_DATE is known to be UTC. Otherwise it is local date/time
  );
  THtmlValueUnitTypeDate = VALUE_UNIT_TYPE_DATE;

  VALUE_STRING_CVT_TYPE = (
    CVT_SIMPLE,        ///< simple conversion of terminal values 
    CVT_JSON_LITERAL,  ///< json literal parsing/emission 
    CVT_JSON_MAP,      ///< json parsing/emission, it parses as if token '{' already recognized 
    CVT_XJSON_LITERAL  ///< x-json parsing/emission, date is emitted as ISO8601 date literal, currency is emitted in the form DDDD$CCC
  );
  TDomValueStringCvtType = VALUE_STRING_CVT_TYPE;
  
  {** Resource data type.
   *  Used by SciterDataReadyAsync() function.
   **}
  SciterResourceType = (
    RT_DATA_HTML       = 0,
    RT_DATA_IMAGE      = 1,
    RT_DATA_STYLE      = 2,
    RT_DATA_CURSOR     = 3,
    RT_DATA_SCRIPT     = 4,
    RT_DATA_RAW        = 5,
    RT_DATA_FONT       = 6,
    RT_DATA_SOUND      = 7 // wav bytes
  );

  (**Set various options.
   *
   * \param[in] hWnd \b HWINDOW, Sciter window handle.
   * \param[in] option \b UINT, id of the option, one of SCITER_RT_OPTIONS
   * \param[in] option \b UINT, value of the option.
   *
   **)
  SCRIPT_RUNTIME_FEATURES = (
    ALLOW_FILE_IO   = $00000001,
    ALLOW_SOCKET_IO = $00000002,
    ALLOW_EVAL      = $00000004,
    ALLOW_SYSINFO   = $00000008
  );
  TScriptRuntimeFeatures = SCRIPT_RUNTIME_FEATURES;

  GFX_LAYER = (
    GFX_LAYER_GDI         = 1,
    GFX_LAYER_WARP        = 2,
    GFX_LAYER_D2D         = 3,
    GFX_LAYER_SKIA        = 4,
    GFX_LAYER_SKIA_OPENGL = 5,
    GFX_LAYER_AUTO        = $FFFF
  );
  TGfxLayer = GFX_LAYER;

  SCITER_RT_OPTIONS = (
   SCITER_SMOOTH_SCROLL      = 1,  // value:TRUE - enable, value:FALSE - disable, enabled by default
   SCITER_CONNECTION_TIMEOUT = 2,  // value: milliseconds, connection timeout of http client
   SCITER_HTTPS_ERROR        = 3,  // value: 0 - drop connection, 1 - use builtin dialog, 2 - accept connection silently
   SCITER_FONT_SMOOTHING     = 4,  // value: 0 - system default, 1 - no smoothing, 2 - std smoothing, 3 - clear type

   SCITER_TRANSPARENT_WINDOW = 6,  // Windows Aero support, value:
                                   // 0 - normal drawing,
                                   // 1 - window has transparent background after calls DwmExtendFrameIntoClientArea() or DwmEnableBlurBehindWindow().
   SCITER_SET_GPU_BLACKLIST  = 7,  // hWnd = NULL,
                                   // value = LPCBYTE, json - GPU black list, see: gpu-blacklist.json resource.
   SCITER_SET_SCRIPT_RUNTIME_FEATURES = 8, // value - combination of SCRIPT_RUNTIME_FEATURES flags.
   SCITER_SET_GFX_LAYER      = 9,  // hWnd = NULL, value - GFX_LAYER
   SCITER_SET_DEBUG_MODE     = 10, // hWnd, value - TRUE/FALSE
   SCITER_SET_UX_THEMING     = 11, // hWnd = NULL, value - BOOL, TRUE - the engine will use "unisex" theme that is common for all platforms.
                                   // That UX theme is not using OS primitives for rendering input elements. Use it if you want exactly
                                   // the same (modulo fonts) look-n-feel on all platforms.

   SCITER_ALPHA_WINDOW       = 12  //  hWnd, value - TRUE/FALSE - window uses per pixel alpha (e.g. WS_EX_LAYERED/UpdateLayeredWindow() window)
  );
  TSciterRtOption = SCITER_RT_OPTIONS;

  TSciterCreateWindowFlag = (
    swChild,       // child window only, if this flag is set all other flags ignored
    swTitlebar,    // toplevel window, has titlebar
    swResizeable,   // has resizeable frame
    swTool,        // is tool window
    swAlpha,       // transparent window ( e.g. WS_EX_LAYERED on Windows )
    swMain,        // main window of the app, will terminate app on close
    swPopup,       // the window is created as topmost.
    swEnableDebug, // make this window inspector ready
    swNoTaskIcon,
    swMaxToFullScreen,
    swScreenCenter,
    swParentCenter,
    swTopMost,
    swNoActivate,
    swNoMouseActivate,
    swAcceptFiles,
    swSysMenu,
    swMinimizeBox,
    swMaximizeBox,
    swWindowShadow,
    swDXPaint
  );
  TSciterCreateWindowFlags = set of TSciterCreateWindowFlag;
const
  CWFlags_Sizeable = [swTitlebar, swResizeable, swSysMenu, swMinimizeBox, swMaximizeBox, swAcceptFiles];
  CWFlags_Dialog   = [swTitlebar, swPopup, swAcceptFiles];
  CWFlags_ToolWnd  = [swTool, swPopup, swAcceptFiles];
  CWFlags_None     = [swPopup, swAcceptFiles];

type
  OUTPUT_SUBSYTEMS = (
     OT_DOM = 0,       // html parser & runtime
     OT_CSSS,          // csss! parser & runtime
     OT_CSS,           // css parser
     OT_TIS            // TIS parser & runtime
  );
  TOutputSubSystem = OUTPUT_SUBSYTEMS;
  POutputSubSystem = ^TOutputSubSystem;
  
  OUTPUT_SEVERITY = (
    OS_INFO,
    OS_WARNING,  
    OS_ERROR
  );
  TOutputSeverity = OUTPUT_SEVERITY;
  POutputSeverity = ^TOutputSeverity;

  DEBUG_OUTPUT_PROC = procedure (param: LPVOID; subsystem: TOutputSubSystem;
    severity: TOutputSeverity; text: LPCWSTR; text_length: UINT); stdcall;
  TDebugOutputProc = DEBUG_OUTPUT_PROC;

  {TISCRIPT_DEBUG_COMMANDS = (
    SCRIPT_DEBUG_CONTINUE = 1,
    SCRIPT_DEBUG_STEP_INTO,
    SCRIPT_DEBUG_STEP_OVER,
    SCRIPT_DEBUG_STEP_OUT
    //SCRIPT_DEBUG_GET_CONTEXT, // will cause onDataReady() call 
  );
  TIscriptDebugCommands = TISCRIPT_DEBUG_COMMANDS;

  TISCRIPT_DEBUG_DATA_REQUESTS = (
    SCRIPT_DEBUG_CONTEXT    = $100,
    SCRIPT_DEBUG_NAMESPACES = $200,
    SCRIPT_DEBUG_STACKTRACE = $300
  );
  TIscriptDebugDataRequests = TISCRIPT_DEBUG_DATA_REQUESTS;   }


  // Native functor
  TNativeFunctorInvoke = procedure (tag: Pointer; const argv: PVALUE; var retval: SCITER_VALUE); cdecl; // retval may contain error definition
  NATIVE_FUNCTOR_INVOKE = TNativeFunctorInvoke;
  TNativeFunctorRelease = procedure (tag: Pointer); cdecl;
  NATIVE_FUNCTOR_RELEASE = TNativeFunctorRelease;

const
  //SCDOM_RESULT = (
    SCDOM_OK_NOT_HANDLED = -1;
    SCDOM_OK = 0;
    SCDOM_INVALID_HWND = 1;
    SCDOM_INVALID_HANDLE = 2;
    SCDOM_PASSIVE_HANDLE = 3;
    SCDOM_INVALID_PARAMETER = 4;
    SCDOM_OPERATION_FAILED = 5;
 // );
 
  //SCITER_SCROLL_FLAGS = (
    SCROLL_TO_TOP = $01;
    SCROLL_SMOOTH = $10;
  //);

   (** event groups. **)
  //EVENT_GROUPS = (
    HANDLE_INITIALIZATION = $0000; (** attached/detached *)
    HANDLE_MOUSE = $0001;          (** mouse events *)
    HANDLE_KEY = $0002;            (** key events *)
    HANDLE_FOCUS = $0004;          (** focus events, if this flag is set it also means that element it attached to is focusable *)
    HANDLE_SCROLL = $0008;         (** scroll events *)
    HANDLE_TIMER = $0010;          (** timer event *)
    HANDLE_SIZE = $0020;           (** size changed event *)
    HANDLE_DRAW = $0040;           (** drawing request (event) *)
    HANDLE_DATA_ARRIVED = $080;    (** requested data () has been delivered *)
    HANDLE_BEHAVIOR_EVENT        = $0100; (** logical, synthetic events:
                                               BUTTON_CLICK, HYPERLINK_CLICK, etc.,
                                               a.k.a. notifications from intrinsic behaviors *)
    HANDLE_METHOD_CALL           = $0200; (** behavior specific methods *)
    HANDLE_SCRIPTING_METHOD_CALL = $0400; (** behavior specific methods *)
    HANDLE_TISCRIPT_METHOD_CALL  = $0800; (** behavior specific methods using direct tiscript::value's *)

    HANDLE_EXCHANGE              = $1000; (** system drag-n-drop *)
    HANDLE_GESTURE               = $2000; (** touch input events *)

    HANDLE_ALL                   = $FFFF; (* all of them *)

    SUBSCRIPTIONS_REQUEST        = $FFFFFFFF; (** special value for getting subscription flags *)
  //);

  //ELEMENT_STATE_BITS = (
    STATE_LINK             = $00000001;
    STATE_HOVER            = $00000002;
    STATE_ACTIVE           = $00000004;
    STATE_FOCUS            = $00000008;
    STATE_VISITED          = $00000010;
    STATE_CURRENT          = $00000020;  // current (hot) item
    STATE_CHECKED          = $00000040;  // element is checked (or selected)
    STATE_DISABLED         = $00000080;  // element is disabled
    STATE_READONLY         = $00000100;  // readonly input element
    STATE_EXPANDED         = $00000200;  // expanded state - nodes in tree view
    STATE_COLLAPSED        = $00000400;  // collapsed state - nodes in tree view - mutually exclusive with
    STATE_INCOMPLETE       = $00000800;  // one of fore/back images requested but not delivered
    STATE_ANIMATING        = $00001000;  // is animating currently
    STATE_FOCUSABLE        = $00002000;  // will accept focus
    STATE_ANCHOR           = $00004000;  // anchor in selection (used with current in selects)
    STATE_SYNTHETIC        = $00008000;  // this is a synthetic element - don't emit it's head/tail
    STATE_OWNS_POPUP       = $00010000;  // this is a synthetic element - don't emit it's head/tail
    STATE_TABFOCUS         = $00020000;  // focus gained by tab traversal
    STATE_EMPTY            = $00040000;  // empty - element is empty (text.size() == 0 && subs.size() == 0)
                                         //  if element has behavior attached then the behavior is responsible for the value of this flag.
    STATE_BUSY             = $00080000;  // busy; loading
   
    STATE_DRAG_OVER        = $00100000;  // drag over the block that can accept it (so is current drop target). Flag is set for the drop target block
    STATE_DROP_TARGET      = $00200000;  // active drop target.
    STATE_MOVING           = $00400000;  // dragging/moving - the flag is set for the moving block.
    STATE_COPYING          = $00800000;  // dragging/copying - the flag is set for the copying block.
    STATE_DRAG_SOURCE      = $01000000;  // element that is a drag source.
    STATE_DROP_MARKER      = $02000000;  // element is drop marker
   
    STATE_PRESSED          = $04000000;  // pressed - close to active but has wider life span - e.g. in MOUSE_UP it
                                         //   is still on; so behavior can check it in MOUSE_UP to discover CLICK condition.
    STATE_POPUP            = $08000000;  // this element is out of flow - popup

    STATE_IS_LTR           = $10000000;  // the element or one of its containers has dir=ltr declared
    STATE_IS_RTL           = $20000000;   // the element or one of its containers has dir=rtl declared
  //);
  //TElementStateBits = ELEMENT_STATE_BITS;


  //ELEMENT_AREAS = (
    ROOT_RELATIVE      = $01; // - or this flag if you want to get sciter window relative coordinates,
                              //   otherwise it will use nearest windowed container e.g. popup window.
    SELF_RELATIVE      = $02; // - "or" this flag if you want to get coordinates relative to the origin
                              //   of element iself.
    CONTAINER_RELATIVE = $03; // - position inside immediate container.
    VIEW_RELATIVE      = $04; // - position relative to view - HTMLayout window

    CONTENT_BOX        = $00; // content (inner)  box
    PADDING_BOX        = $10; // content + paddings
    BORDER_BOX         = $20; // content + paddings + border
    MARGIN_BOX         = $30; // content + paddings + border + margins

    BACK_IMAGE_AREA    = $40; // relative to content origin - location of background image (if it set no-repeat)
    FORE_IMAGE_AREA    = $50; // relative to content origin - location of foreground image (if it set no-repeat)

    SCROLLABLE_AREA    = $60;  // scroll_area - scrollable area in content box
  //);
  //TElementAreas = ELEMENT_AREAS;

type
  SET_ELEMENT_HTML = (
    SIH_REPLACE_CONTENT     = 0, 
    SIH_INSERT_AT_START     = 1,
    SIH_APPEND_AFTER_LAST   = 2, 
    SOH_REPLACE             = 3,
    SOH_INSERT_BEFORE       = 4,
    SOH_INSERT_AFTER        = 5  
  );
  TSetElementHtml = SET_ELEMENT_HTML;


type
  REQUEST_TYPE = (
    GET_ASYNC,  // async GET
    POST_ASYNC, // async POST
    GET_SYNC,   // synchronous GET
    POST_SYNC   // synchronous POST
  );
  TRequestType = REQUEST_TYPE;

  (** Control types.
   *  Control here is any dom element having appropriate behavior applied
   **)
  CTL_TYPE = (
    CTL_NO,               ///< This dom element has no behavior at all.
    CTL_UNKNOWN = 1,      ///< This dom element has behavior but its type is unknown.
    CTL_EDIT,             ///< Single line edit box.
    CTL_NUMERIC,          ///< Numeric input with optional spin buttons.
    CTL_CLICKABLE,        ///< toolbar button, behavior:clickable.
    CTL_BUTTON,           ///< Command button.
    CTL_CHECKBOX,         ///< CheckBox (button).
    CTL_RADIO,            ///< OptionBox (button).
    CTL_SELECT_SINGLE,    ///< Single select, ListBox or TreeView.
    CTL_SELECT_MULTIPLE,  ///< Multiselectable select, ListBox or TreeView.
    CTL_DD_SELECT,        ///< Dropdown single select.
    CTL_TEXTAREA,         ///< Multiline TextBox.
    CTL_HTMLAREA,         ///< WYSIWYG HTML editor.
    CTL_PASSWORD,         ///< Password input element.
    CTL_PROGRESS,         ///< Progress element.
    CTL_SLIDER,           ///< Slider input element.  
    CTL_DECIMAL,          ///< Decimal number input element.
    CTL_CURRENCY,         ///< Currency input element.
    CTL_SCROLLBAR,
    
    CTL_HYPERLINK,
    
    CTL_MENUBAR,
    CTL_MENU,
    CTL_MENUBUTTON,

    CTL_CALENDAR,
    CTL_DATE,
    CTL_TIME,
    
    CTL_FRAME,
    CTL_FRAMESET,

    CTL_GRAPHICS,
    CTL_SPRITE,

    CTL_LIST,
    CTL_RICHTEXT,
    CTL_TOOLTIP,

    CTL_HIDDEN,
    CTL_URL,            ///< URL input element.
    CTL_TOOLBAR,
    
    CTL_FORM,
    CTL_FILE,           ///< file input element.
    CTL_PATH,           ///< path input element.
    CTL_WINDOW,         ///< has HWND attached to it

    CTL_LABEL,            
    CTL_IMAGE           ///< image/object.
  );
  TControlType = CTL_TYPE;

  NODE_TYPE = (
    NT_ELEMENT,
    NT_TEXT,
    NT_COMMENT 
  );
  TNodeType = NODE_TYPE;

  NODE_INS_TARGET = (
    NIT_BEFORE,
    NIT_AFTER,
    NIT_APPEND,
    NIT_PREPEND
  );
  TNodeInsTarget = NODE_INS_TARGET;

  (** #SC_LOAD_DATA notification return codes *)
  TLoadDataResult = (
    LOAD_OK      = 0,  // do default loading if data not set
    LOAD_DISCARD = 1,  // discard request completely
    LOAD_DELAYED = 2,  // data will be delivered later by the host application.
                       // Host application must call SciterDataReadyAsync(,,, requestId) on each LOAD_DELAYED request to avoid memory leaks.
    LOAD_MYSELF  = 3   // you return LOAD_MYSELF result to indicate that your (the host) application took or will take care about HREQUEST in your code completely.
                       // Use sciter-x-request.h[pp] API functions with SCN_LOAD_DATA::requestId handle .
  );
  SC_LOAD_DATA_RETURN_CODES = TLoadDataResult;
  
const
  (**Notifies that Sciter is about to download a referred resource.
   *
   * \param lParam #LPSCN_LOAD_DATA.
   * \return #SC_LOAD_DATA_RETURN_CODES
   *
   * This notification gives application a chance to override built-in loader and
   * implement loading of resources in its own way (for example images can be loaded from
   * database or other resource). To do this set #SCN_LOAD_DATA::outData and
   * #SCN_LOAD_DATA::outDataSize members of SCN_LOAD_DATA. Sciter does not
   * store pointer to this data. You can call #SciterDataReady() function instead
   * of filling these fields. This allows you to free your outData buffer
   * immediately.
  **)
  SC_LOAD_DATA           = $01;

  (**This notification indicates that external data (for example image) download process
   * completed.
   *
   * \param lParam #LPSCN_DATA_LOADED
   *
   * This notifiaction is sent for each external resource used by document when
   * this resource has been completely downloaded. Sciter will send this
   * notification asynchronously.
   **)
  SC_DATA_LOADED         = $02;

  (**This notification is sent when all external data (for example image) has been downloaded.
   *
   * This notification is sent when all external resources required by document
   * have been completely downloaded. Sciter will send this notification
   * asynchronously.
   **)
  (* obsolete #define SC_DOCUMENT_COMPLETE 0x03
     use DOCUMENT_COMPLETE DOM event.
    *)


  (**This notification is sent on parsing the document and while processing
   * elements having non empty style.behavior attribute value.
   *
   * \param lParam #LPSCN_ATTACH_BEHAVIOR
   *
   * Application has to provide implementation of #sciter::behavior interface.
   * Set #SCN_ATTACH_BEHAVIOR::impl to address of this implementation.
   **)
  SC_ATTACH_BEHAVIOR     = $04;

  (**This notification is sent when instance of the engine is destroyed.
   * It is always final notification.
   *
   * \param lParam #LPSCN_ENGINE_DESTROYED
   *
   **)
  SC_ENGINE_DESTROYED    = $05;

  (**Posted notification.
 
   * \param lParam #LPSCN_POSTED_NOTIFICATION
   *
   **)
  SC_POSTED_NOTIFICATION = $06;

  (**This notification is sent when the engine encounters critical rendering error: e.g. DirectX gfx driver error.
     Most probably bad gfx drivers.
 
   * \param lParam #LPSCN_GRAPHICS_CRITICAL_FAILURE
   *
   **)
  SC_GRAPHICS_CRITICAL_FAILURE = $07;

  (**Type of the result value for Sciter DOM functions.
   * Possible values are:
   * - \b SCDOM_OK - function completed successfully
   * - \b SCDOM_INVALID_HWND - invalid HWINDOW
   * - \b SCDOM_INVALID_HANDLE - invalid HELEMENT
   * - \b SCDOM_PASSIVE_HANDLE - attempt to use HELEMENT which is not marked by 
   *   #Sciter_UseElement()
   * - \b SCDOM_INVALID_PARAMETER - parameter is invalid, e.g. pointer is null
   * - \b SCDOM_OPERATION_FAILED - operation failed, e.g. invalid html in 
   *   #SciterSetElementHtml()
   **)

type
  (**Notification callback structure.**)
  SCITER_CALLBACK_NOTIFICATION = record
    code: UINT;    (**< [in] one of the codes above.*)
    hwnd: HWINDOW; (**< [in] HWINDOW of the window this callback was attached to.*)
  end;
  LPSCITER_CALLBACK_NOTIFICATION = ^SCITER_CALLBACK_NOTIFICATION;  
  TSciterCallbackNotification     = SCITER_CALLBACK_NOTIFICATION;
  PSciterCallbackNotification    = ^TSciterCallbackNotification;

  LPSciterHostCallback = function (pns: PSciterCallbackNotification; callbackParam: LPVOID): UINT; stdcall;

  (**This structure is used by #SC_LOAD_DATA notification.
   *\copydoc SC_LOAD_DATA
   **)

  SCN_LOAD_DATA = record
    code: UINT ;               (**< [in] one of the codes above.*)
    hwnd: HWINDOW;             (**< [in] HWINDOW of the window this callback was attached to.*)

    uri: LPCWSTR;              (**< [in] Zero terminated string, fully qualified uri, for example "http://server/folder/file.ext".*)

    outData:     LPCBYTE;      (**< [in,out] pointer to loaded data to return. if data exists in the cache then this field contain pointer to it*)
    outDataSize: UINT;         (**< [in,out] loaded data size to return.*)
    dataType:    SciterResourceType;  (**< [in] SciterResourceType *)

    requestId:   HREQUEST;     (**< [in] request handle that can be used with sciter-x-request API *)

    principal:   HELEMENT;
    initiator:   HELEMENT;
  end;
  LPSCN_LOAD_DATA = ^SCN_LOAD_DATA;
  TScnLoadData    = SCN_LOAD_DATA;
  PScnLoadData    = ^TScnLoadData;

  (**This structure is used by #SC_DATA_LOADED notification.
   *\copydoc SC_DATA_LOADED
   **)
  SCN_DATA_LOADED = record
    code:     UINT;     (**< [in] one of the codes above.*)
    hwnd:     HWINDOW;  (**< [in] HWINDOW of the window this callback was attached to.*)
    
    uri:      LPCWSTR;  (**< [in] zero terminated string, fully qualified uri, for example "http://server/folder/file.ext".*)
    data:     LPCBYTE;  (**< [in] pointer to loaded data.*)
    dataSize: UINT;     (**< [in] loaded data size (in bytes).*)
    dataType: SciterResourceType;     (**< [in] SciterResourceType *)
    status:   UINT;     (**< [in]
                           status = 0 (dataSize == 0) - unknown error. 
                           status = 100..505 - http response status, Note: 200 - OK!
                           status > 12000 - wininet error code, see ERROR_INTERNET_*** in wininet.h
                        *)
  end;
  LPSCN_DATA_LOADED = ^SCN_DATA_LOADED;
  TScnDataLoaded    = SCN_DATA_LOADED;
  PScnDataLoaded   = ^TScnDataLoaded;


  (**Element callback function for all types of events. Similar to WndProc
   * \param tag \b LPVOID, tag assigned by SciterAttachElementProc function (like GWL_USERDATA)
   * \param he \b HELEMENT, this element handle (like HWINDOW)
   * \param evtg \b UINT, group identifier of the event, value is one of EVENT_GROUPS
   * \param prms \b LPVOID, pointer to group specific parameters structure.
   * \return TRUE if event was handled, FALSE otherwise.
   **)
   TElementEventProc = function (tag: LPVOID; he: HELEMENT; evtg: UINT; prms: LPVOID): BOOL; stdcall;
   LPELEMENT_EVENT_PROC = TElementEventProc;

  (**This structure is used by #SC_ATTACH_BEHAVIOR notification.
   *\copydoc SC_ATTACH_BEHAVIOR **)
  SCN_ATTACH_BEHAVIOR = record
    code:  UINT;    (**< [in] one of the codes above.*)
    hwnd:  HWINDOW ; (**< [in] HWINDOW of the window this callback was attached to.*)
    
    element: HELEMENT ;          (**< [in] target DOM element handle*)
    behaviorName: LPCSTR;     (**< [in] zero terminated string, string appears as value of CSS behavior:"???" attribute.*)

    elementProc: TElementEventProc;    (**< [out] pointer to ElementEventProc function.*)
    elementTag:  LPVOID;     (**< [out] tag value, passed as is into pointer ElementEventProc function.*)
  end;
  LPSCN_ATTACH_BEHAVIOR = ^SCN_ATTACH_BEHAVIOR;

  (**This structure is used by #SC_ENGINE_DESTROYED notification.
   *\copydoc SC_ENGINE_DESTROYED **)
  SCN_ENGINE_DESTROYED = record
    code: UINT;     (**< [in] one of the codes above.*)
    hwnd: HWINDOW ; (**< [in] HWINDOW of the window this callback was attached to.*)
  end;
  LPSCN_ENGINE_DESTROYED = ^SCN_ENGINE_DESTROYED;
  TScnEngineDestroyed = SCN_ENGINE_DESTROYED;
  PScnEngineDestroyed = ^TScnEngineDestroyed;

  (**This structure is used by #SC_ENGINE_DESTROYED notification.
   *\copydoc SC_ENGINE_DESTROYED **)
  SCN_POSTED_NOTIFICATION = record
    code:     UINT;     (**< [in] one of the codes above.*)
    hwnd:     HWINDOW;  (**< [in] HWINDOW of the window this callback was attached to.*)
    wparam:   UINT_PTR;
    lparam:   UINT_PTR;
    lreturn:  UINT_PTR;
  end;
  LPSCN_POSTED_NOTIFICATION = ^SCN_POSTED_NOTIFICATION;
  TScnPostedNotification = SCN_POSTED_NOTIFICATION;
  PScnPostedNotification = ^TScnPostedNotification;

  (**This structure is used by #SC_ENGINE_DESTROYED notification.
   *\copydoc SC_ENGINE_DESTROYED **)
  SCN_GRAPHICS_CRITICAL_FAILURE = record
    code:  UINT;    (**< [in] one of the codes above.*)
    hwnd:  HWINDOW; (**< [in] HWINDOW of the window this callback was attached to.*)
  end;
  LPSCN_GRAPHICS_CRITICAL_FAILURE = ^SCN_GRAPHICS_CRITICAL_FAILURE;
  TScnGraphicsCriticalFailure = SCN_GRAPHICS_CRITICAL_FAILURE;
  PScnGraphicsCriticalFailure = ^TScnGraphicsCriticalFailure;

  URL_DATA = record
    requestedUrl:  LPCSTR;              // requested URL
    realUrl:       LPCSTR;              // real URL data arrived from (after possible redirections)
    requestedType: SciterResourceType;  // requested data category: html, script, image, etc.
    httpHeaders:   LPCSTR;              // if any
    mimeType:      LPCSTR;              // mime type reported by server (if any)
    encoding:      LPCSTR;              // data encoding (if any)
    data:          LPCBYTE;
    dataLength:    UINT;
  end;
  TUrlData = URL_DATA;
  PUrlData = ^TUrlData;

  URL_DATA_RECEIVER = procedure (const pUrlData: TUrlData; param: LPVOID); stdcall;
  TUrlDataReceiver  = URL_DATA_RECEIVER;

  {$IFDEF WINDOWS}
  TSciterWindowDelegate = function (hwnd: HWINDOW; msg: UINT; wParam: WPARAM;
    lParam: LPARAM; pParam: LPVOID; var pHandled: BOOL): LRESULT; stdcall;
  {$ENDIF}
  
  REQUEST_PARAM = record
    name:  LPCWSTR;
    value: LPCWSTR;
  end;
  TRequestParam = REQUEST_PARAM;
  PRequestParam = ^TRequestParam;
  TRequestParamArray = array[Word] of TRequestParam;
  PRequestParamArray = ^TRequestParamArray;

  (**callback function used with various get*** functions *)
  LPCBYTE_RECEIVER = procedure (bytes: LPCBYTE; num_bytes: UINT; param: LPVOID); stdcall;
  TLCPBYTEReceiver = LPCBYTE_RECEIVER;
  LPCWSTR_RECEIVER = procedure (str: LPCWSTR; str_length: UINT; param: LPVOID); stdcall;
  TLPCWSTRReceiver = LPCWSTR_RECEIVER;
  LPCSTR_RECEIVER = procedure (str: LPCSTR; str_length: UINT; param: LPVOID); stdcall;
  TLPCSTRReceiver = LPCSTR_RECEIVER;

  (**Callback function used with #SciterVisitElement().*)
  TSciterElementCallback = function (he: HELEMENT; param: LPVOID): BOOL; stdcall;

  (**Callback comparator function used with #SciterSortElements().
     Shall return -1,0,+1 values to indicate result of comparison of two elements
   **)
  ELEMENT_COMPARATOR = function (he1, he2: HELEMENT; param: LPVOID): Integer; stdcall;
  TElementComparator = ELEMENT_COMPARATOR;

  (**Callback function used with #ValueEnumElements().
   * return TRUE to continue enumeration
   *)
  TKeyValueCallback = function (param: LPVOID; const pkey: SCITER_VALUE; var pval: SCITER_VALUE): BOOL; stdcall;

  (**Is called for every element that match criteria specified when calling to #sciter::dom::element::select() function.*)
  TElementSelectCallback = function (he: HELEMENT): BOOL; stdcall;

const
  //GESTURE_TYPE_FLAGS = ( // requested
    GESTURE_FLAG_ZOOM               = $0001;
    GESTURE_FLAG_ROTATE             = $0002;
    GESTURE_FLAG_PAN_VERTICAL       = $0004;
    GESTURE_FLAG_PAN_HORIZONTAL     = $0008;
    GESTURE_FLAG_TAP1               = $0010; // press & tap
    GESTURE_FLAG_TAP2               = $0020; // two fingers tap

    GESTURE_FLAG_PAN_WITH_GUTTER    = $4000; // PAN_VERTICAL and PAN_HORIZONTAL modifiers
    GESTURE_FLAG_PAN_WITH_INERTIA   = $8000; //
    GESTURE_FLAGS_ALL               = $FFFF; //
  //);

  //MOUSE_BUTTONS = (
    MAIN_MOUSE_BUTTON = 1; //aka left button
    PROP_MOUSE_BUTTON = 2; //aka right button
    MIDDLE_MOUSE_BUTTON = 4;
  //);
  //TMouseButton = MOUSE_BUTTONS;
  //TMouseButtons = set of TMouseButton;

  //KEYBOARD_STATES = (
    CONTROL_KEY_PRESSED = $1;
    SHIFT_KEY_PRESSED   = $2;
    ALT_KEY_PRESSED     = $4;
  //);
  //TKeyboardState = KEYBOARD_STATES;
  //TKeyboardStates = set of TKeyboardState;

// parameters of evtg == HANDLE_MOUSE

  //MOUSE_EVENTS = (
    MOUSE_ENTER = 0;
    MOUSE_LEAVE = 1;
    MOUSE_MOVE = 2;
    MOUSE_UP = 3;
    MOUSE_DOWN = 4;
    MOUSE_DCLICK = 5;
    MOUSE_WHEEL = 6;
    MOUSE_TICK = 7; // mouse pressed ticks
    MOUSE_IDLE = 8; // mouse stay idle for some time

    DROP        = 9;   // item dropped, target is that dropped item
    DRAG_ENTER  = $A; // drag arrived to the target element that is one of current drop targets.
    DRAG_LEAVE  = $B; // drag left one of current drop targets. target is the drop target element.
    DRAG_REQUEST = $C;  // drag src notification before drag start. To cancel - return true from handler.

    MOUSE_CLICK = $FF; // mouse click event

    DRAGGING = $100;  // This flag is 'ORed' with MOUSE_ENTER..MOUSE_DOWN codes if dragging operation is in effect.
                      // E.g. event DRAGGING | MOUSE_MOVE is sent to underlying DOM elements while dragging.
  //);
  //TMouseEvent = MOUSE_EVENTS;

// parameters of evtg == HANDLE_KEY

  //KEY_EVENTS = (
    KEY_DOWN = 0;
    KEY_UP   = 1;
    KEY_CHAR = 2;
  //);
  //TKeyEvent = KEY_EVENTS;

  //PHASE_MASK = (
      BUBBLING = 0;      // bubbling (emersion) phase
      SINKING  = $8000;  // capture (immersion) phase, this flag is or'ed with EVENTS codes below
      HANDLED  = $10000;
    // see: http://www.w3.org/TR/xml-events/Overview.html#s_intro
  //);
  //TPhaseMask = PHASE_MASK;

  //FOCUS_EVENTS = (
    FOCUS_OUT = 0;            (**< container lost focus from any element inside it, target is an element that got focus *)
    FOCUS_IN = 1;             (**< container got focus on element inside it, target is an element that lost focus *)
    FOCUS_GOT = 2;            (**< target element got focus *)
    FOCUS_LOST = 3;           (**< target element lost focus *)
    FOCUS_REQUEST = 4;        (**< bubbling event/request, gets sent on child-parent chain to accept/reject focus to be set on the child (target) *)
//);
  //TFocusEvent = FOCUS_EVENTS;

  //DRAW_EVENTS = (
      DRAW_BACKGROUND = 0;
      DRAW_CONTENT = 1;
      DRAW_FOREGROUND = 2;
  //);
  //TDrawEvent = DRAW_EVENTS;

type
  // breakpoint hit event receiver
  SCITER_DEBUG_BP_HIT_CB = function (inFile: LPCWSTR; atLine: UINT; const envData: PVALUE; param: LPVOID): UINT; stdcall;
  TSciterDebugBpHitCb = SCITER_DEBUG_BP_HIT_CB;
  // requested data ready receiver
  SCITER_DEBUG_DATA_CB = procedure (onCmd: UINT; const data: PVALUE; param: LPVOID); stdcall;
  TSciterDebugDataCb = SCITER_DEBUG_DATA_CB;

  SCITER_DEBUG_BREAKPOINT_CB = function (fileUrl: LPCWSTR; lineNo: UINT; param: LPVOID): BOOL; stdcall;
  TSciterDebugBreakpointCb = SCITER_DEBUG_BREAKPOINT_CB;


// parameters of evtg == HANDLE_INITIALIZATION

  INITIALIZATION_EVENTS = (
    BEHAVIOR_DETACH = 0,
    BEHAVIOR_ATTACH = 1
  );
  TInitializationEvent = INITIALIZATION_EVENTS;

  INITIALIZATION_PARAMS = record
    cmd: TInitializationEvent; // INITIALIZATION_EVENTS
  end;
  TInitializationParams = INITIALIZATION_PARAMS;
  PInitializationParams = ^TInitializationParams;

  DRAGGING_TYPE = (
    NO_DRAGGING,
    DRAGGING_MOVE,
    DRAGGING_COPY
  );
  TDraggingType = DRAGGING_TYPE;

  CURSOR_TYPE = (
      CURSOR_NONE = -1,   //-1
      CURSOR_ARROW = 0,   // 0
      CURSOR_IBEAM,       // 1
      CURSOR_WAIT,        // 2
      CURSOR_CROSS,       // 3
      CURSOR_UPARROW,     // 4
      CURSOR_SIZENWSE,    // 5
      CURSOR_SIZENESW,    // 6
      CURSOR_SIZEWE,      // 7
      CURSOR_SIZENS,      // 8
      CURSOR_SIZEALL,     // 9
      CURSOR_NO,          //10
      CURSOR_APPSTARTING, //11
      CURSOR_HELP,        //12
      CURSOR_HAND,        //13
      CURSOR_DRAG_MOVE,   //14
      CURSOR_DRAG_COPY    //15
  );
  TCursorType = CURSOR_TYPE;

  MOUSE_PARAMS = record
    cmd:           UINT;            // MOUSE_EVENTS
    target:        HELEMENT;        // target element
    pos:           TPoint;          // position of cursor, element relative
    pos_view:      TPoint;          // position of cursor, view relative
    button_state:  UINT;            // MOUSE_BUTTONS
    alt_state:     UINT;            // KEYBOARD_STATES
    cursor_type:   TCursorType;     // CURSOR_TYPE to set, see CURSOR_TYPE
    is_on_icon:    BOOL;            // mouse is over icon (foreground-image, foreground-repeat:no-repeat)

    dragging:      HELEMENT;        // element that is being dragged over, this field is not NULL if (cmd & DRAGGING) != 0
    dragging_mode: TDraggingType;   // see DRAGGING_TYPE.
   end;
   TMouseParams = MOUSE_PARAMS;
   PMouseParams = ^TMouseParams;

  KEY_PARAMS = record
    cmd:       UINT;            // KEY_EVENTS
    target:    HELEMENT;        // target element
    key_code:  UINT;            // key scan code, or character unicode for KEY_CHAR
    alt_state: UINT;            // KEYBOARD_STATES
  end;
  TKeyParams = KEY_PARAMS;
  PKeyParams = ^TKeyParams;

// parameters of evtg == HANDLE_FOCUS

  FOCUS_PARAMS = record
    cmd:      UINT;        // FOCUS_EVENTS
    target:   HELEMENT;    // target element, for FOCUS_LOST it is a handle of new focus element
                           //    and for FOCUS_GOT it is a handle of old focus element, can be NULL
    by_mouse_click: BOOL;  // true if focus is being set by mouse click
    cancel:         BOOL;  // in FOCUS_LOST phase setting this field to true will cancel transfer focus from old element to the new one.
  end;
  TFocusParams = FOCUS_PARAMS;
  PFocusParams = ^TFocusParams;

// parameters of evtg == HANDLE_SCROLL

  SCROLL_EVENTS = (
    SCROLL_HOME = 0,
    SCROLL_END,
    SCROLL_STEP_PLUS,
    SCROLL_STEP_MINUS,
    SCROLL_PAGE_PLUS,
    SCROLL_PAGE_MINUS,
    SCROLL_POS,
    SCROLL_SLIDER_RELEASED,
    SCROLL_CORNER_PRESSED,
    SCROLL_CORNER_RELEASED
  );
  TScrollEvent = SCROLL_EVENTS;

  SCROLL_PARAMS = record
    cmd:      UINT;         // SCROLL_EVENTS
    target:   HELEMENT;     // target element
    pos:      Integer;      // scroll position if SCROLL_POS
    vertical: BOOL;         // true if from vertical scrollbar
  end;
  TScorllParams = SCROLL_PARAMS;
  PScorllParams = ^TScorllParams;

  GESTURE_CMD = (
    GESTURE_REQUEST = 0, // return true and fill flags if it will handle gestures.
    GESTURE_ZOOM,        // The zoom gesture.
    GESTURE_PAN,         // The pan gesture.
    GESTURE_ROTATE,      // The rotation gesture.
    GESTURE_TAP1,        // The tap gesture.
    GESTURE_TAP2         // The two-finger tap gesture.
  );
  TGestureCmd = GESTURE_CMD;
  
  GESTURE_STATE = (
    GESTURE_STATE_BEGIN   = 1, // starts
    GESTURE_STATE_INERTIA = 2, // events generated by inertia processor
    GESTURE_STATE_END     = 4  // end, last event of the gesture sequence
  );
  TGestureState = GESTURE_STATE;

  GESTURE_PARAMS = record
    cmd:        UINT;     // GESTURE_CMD
    target:     HELEMENT; // target element
    pos:        TPoint;   // position of cursor, element relative
    pos_view:   TPoint;   // position of cursor, view relative
    flags:      UINT;     // for GESTURE_REQUEST combination of GESTURE_FLAGs.
                          // for others it is a combination of GESTURE_STATe's
    delta_time: UINT;     // period of time from previous event.
    delta_xy:   TSize;    // for GESTURE_PAN it is a direction vector
    delta_v:    double;   // for GESTURE_ROTATE - delta angle (radians)
                          // for GESTURE_ZOOM - zoom value, is less or greater than 1.0
  end;
  TGestrueParams = GESTURE_PARAMS;
  PGestrueParams = ^TGestrueParams;

  DRAW_PARAMS = record
      cmd: UINT;           // DRAW_EVENTS
      gfx: HGFX;           // hdc to paint on
      area: TRect;         // element area, to get invalid area to paint use GetClipBox,
      reserved: UINT;      // for DRAW_BACKGROUND/DRAW_FOREGROUND - it is a border box
                           // for DRAW_CONTENT - it is a content box
  end;
  TDrawParams = DRAW_PARAMS;
  PDrawParams = ^TDrawParams;

  CONTENT_CHANGE_BITS = (  // for CONTENT_CHANGED reason
     CONTENT_ADDED   = $01,
     CONTENT_REMOVED = $02
  );
  TContentChangeBits = CONTENT_CHANGE_BITS;

  BEHAVIOR_EVENT_PARAMS = packed record
    cmd:      UINT; // BEHAVIOR_EVENTS
    heTarget: HELEMENT;       // target element handler, in MENU_ITEM_CLICK this is owner element that caused this menu - e.g. context menu owner
                              // In scripting this field named as Event.owner
    he:       HELEMENT;       // source element e.g. in SELECTION_CHANGED it is new selected <option>, in MENU_ITEM_CLICK it is menu item (LI) element
    reason:   UINT_PTR;       // EVENT_REASON or EDIT_CHANGED_REASON - UI action causing change.
                              // In case of custom event notifications this may be any
                              // application specific value.
    data:     SCITER_VALUE;   // auxiliary data accompanied with the event. E.g. FORM_SUBMIT event is using this field to pass collection of values.
  end;
  TBehaviorEventParams = BEHAVIOR_EVENT_PARAMS;
  PBehaviorEventParams = ^TBehaviorEventParams;

  TIMER_PARAMS = record
    timerId:  UINT_PTR;    // timerId that was used to create timer by using HTMLayoutSetTimerEx
  end;
  TTimerParams = TIMER_PARAMS;
  PTimerParams = ^TTimerParams;

  // identifiers of methods currently supported by intrinsic behaviors,
  // see function HTMLayoutCallMethod

  BEHAVIOR_METHOD_IDENTIFIERS = (
    DO_CLICK = 0,
    GET_TEXT_VALUE = 1,
    SET_TEXT_VALUE,
      // p - TEXT_VALUE_PARAMS

    TEXT_EDIT_GET_SELECTION,
      // p - TEXT_EDIT_SELECTION_PARAMS

    TEXT_EDIT_SET_SELECTION,
      // p - TEXT_EDIT_SELECTION_PARAMS

    // Replace selection content or insert text at current caret position.
    // Replaced text will be selected.
    TEXT_EDIT_REPLACE_SELECTION,
      // p - TEXT_EDIT_REPLACE_SELECTION_PARAMS

    // Set value of type="vscrollbar"/"hscrollbar"
    SCROLL_BAR_GET_VALUE,
    SCROLL_BAR_SET_VALUE,

    TEXT_EDIT_GET_CARET_POSITION, 
    TEXT_EDIT_GET_SELECTION_TEXT, // p - TEXT_SELECTION_PARAMS
    TEXT_EDIT_GET_SELECTION_HTML, // p - TEXT_SELECTION_PARAMS
    TEXT_EDIT_CHAR_POS_AT_XY,     // p - TEXT_EDIT_CHAR_POS_AT_XY_PARAMS

    IS_EMPTY      = $FC,       // p - IS_EMPTY_PARAMS // set VALUE_PARAMS::is_empty (false/true) reflects :empty state of the element.
    GET_VALUE     = $FD,       // p - VALUE_PARAMS
    SET_VALUE     = $FE,       // p - VALUE_PARAMS

    FIRST_APPLICATION_METHOD_ID = $100
  );
  TBehaviorMethodIdentifier = BEHAVIOR_METHOD_IDENTIFIERS;

  METHOD_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
  end;
  TMethodParams = METHOD_PARAMS;
  PMethodParams = ^TMethodParams;

  SCRIPTING_METHOD_PARAMS = record
    name:    LPCSTR;        //< method name
    argv:    PSCITER_VALUE; //< vector of arguments
    argc:    UINT;          //< argument count
    result:  SCITER_VALUE;  //< return value
  end;
  TScriptingMethodParams = SCRIPTING_METHOD_PARAMS;
  PScriptingMethodParams = ^TScriptingMethodParams;

  TISCRIPT_METHOD_PARAMS = record
    vm:     Ptiscript_VM;
    tag:    tiscript_value;    //< method id (symbol)
    result: tiscript_value;    //< return value
    // parameters are accessible through tiscript::args.
  end;
  TTiscriptMethodParams = TISCRIPT_METHOD_PARAMS;
  PTiscriptMethodParams = ^TTiscriptMethodParams;

  // GET_VALUE/SET_VALUE methods params
  VALUE_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    val:      JsonValue;
  end;
  TValueParams = VALUE_PARAMS;
  PValueParams = ^TValueParams;

  // IS_EMPTY method params
  IS_EMPTY_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    is_empty: UINT;  // !0 - is empty
  end;
  TIsEmptyParams = IS_EMPTY_PARAMS;
  PIsEmptyParams = ^TIsEmptyParams;

  TEXT_VALUE_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    text:  LPCWSTR;
    length: UINT;
  end;
  TTextValueParams = TEXT_VALUE_PARAMS;
  PTextValueParams = ^TTextValueParams;

  TEXT_EDIT_SELECTION_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    selection_start: UINT;
    selection_end: UINT;
  end;
  TTextEditSelectionParams = TEXT_EDIT_SELECTION_PARAMS;
  PTextEditSelectionParams = ^TTextEditSelectionParams;

  TEXT_EDIT_REPLACE_SELECTION_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    text:        LPCWSTR;
    text_length: UINT;
  end;
  TTextEditReplaceSelectionParams = TEXT_EDIT_REPLACE_SELECTION_PARAMS;
  PTextEditReplaceSelectionParams = ^TTextEditReplaceSelectionParams;

  TEXT_EDIT_CHAR_POS_AT_XY_PARAMS = record
    methodID: TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    x,y:      Integer;     // in
    char_pos: Integer;     // out
    he:       HELEMENT ;   // out
    he_pos:   Integer;     // out
  end;
  TTextEditCharPosAtXYParams = TEXT_EDIT_CHAR_POS_AT_XY_PARAMS;
  PTextEditCharPosAtXYParams = ^TTextEditCharPosAtXYParams;

  SCROLLBAR_VALUE_PARAMS = record
    methodID:   TBehaviorMethodIdentifier; // see: #BEHAVIOR_METHOD_IDENTIFIERS
    value:      Integer;
    min_value:  Integer;
    max_value:  Integer ;
    page_value: Integer; // page increment
    step_value: Integer; // step increment (arrow button click)
  end;
  TScrollbarValueParams = SCROLLBAR_VALUE_PARAMS;
  PScrollbarValueParams = ^TScrollbarValueParams;

  // see SciterRequestElementData

  DATA_ARRIVED_PARAMS = record
      initiator: HELEMENT;    // element intiator of HTMLayoutRequestElementData request,
      data:      LPCBYTE;     // data buffer
      dataSize:  UINT;        // size of data
      dataType:  UINT;        // data type passed "as is" from HTMLayoutRequestElementData
      status:    UINT;        // status = 0 (dataSize == 0) - unknown error.
                              // status = 100..505 - http response status, Note: 200 - OK! 
                              // status > 12000 - wininet error code, see ERROR_INTERNET_*** in wininet.h
      uri:       LPCWSTR;     // requested url
  end;
  TDataArrivedParams = DATA_ARRIVED_PARAMS;
  PDataArrivedParams = ^TDataArrivedParams;

  TSciterSchemaType = (
    sstNormal,
    sstFile,
    sstRes,
    sstPlugin
  );
  PSciterSchemaInfo = ^TSciterSchemaInfo;
  TSciterSchemaInfo = record
    Path: SciterString;
    Schema: TSciterSchemaType;
    IsOrigin: Boolean;
    IsPlugin: Boolean;
  end;
type
(** #SCITER_X_MSG_CODE message/function identifier *)
  SCITER_X_MSG_CODE = (
    SXM_CREATE  = 0,
    SXM_DESTROY = 1,
    SXM_SIZE    = 2,
    SXM_PAINT   = 3
  );

(** #SCITER_X_MSG common header of message structures passed to SciterProcX *)
  SCITER_X_MSG = record
    msg: UINT;  (**< [in] one of the codes of #SCITER_X_MSG_CODE.*)
  end;
  PSCITER_X_MSG = ^SCITER_X_MSG;

  SCITER_X_MSG_CREATE = record
    header: SCITER_X_MSG;
    backend: UINT;
    transparent: BOOL;
  end;
  PSCITER_X_MSG_CREATE = ^SCITER_X_MSG_CREATE;

  SCITER_X_MSG_DESTROY = record
    header: SCITER_X_MSG;
  end;
  PSCITER_X_MSG_DESTROY = ^SCITER_X_MSG_DESTROY;

  SCITER_X_MSG_SIZE = record
    header: SCITER_X_MSG;
    width: UINT;
    height: UINT;
  end;
  PSCITER_X_MSG_SIZE = ^SCITER_X_MSG_SIZE;

(** #ELEMENT_BITMAP_RECEIVER - callback function that receives pointer to pixmap and location
* \param[in] bgra \b LPCBYTE, pointer to BGRA bitmap, number of bytes = width * height * 4
* \param[in] x \b INT, position of the bitmap on elements window.
* \param[in] y \b INT, position of the bitmap on elements window.
* \param[in] width \b UINT, width of bitmap (and element's shape).
* \param[in] height \b UINT, height of bitmap (and element's shape).
* \param[in] param \b LPVOID, param that passed as SCITER_X_MSG_PAINT::receiver::param .
**)
  ELEMENT_BITMAP_RECEIVER = procedure (rgba: LPCBYTE; x, y: Integer; width, height: UINT; param: Pointer); stdcall;

(** #SCITER_X_MSG_CODE message/function identifier *)
  SCITER_PAINT_TARGET_TYPE = (
    SPT_DEFAULT   = 0,  (**< default rendering target - window surface *)
    SPT_RECEIVER  = 1,  (**< target::receiver fields are valid *)
    SPT_DC        = 2   (**< target::dc is valid *)
    // ...
  );

  SCITER_X_MSG_PAINT_TARGET = record
    case Integer of
      0: (hdc: HDC);
      1: (
        receiver: record
          param: Pointer;
          callback: ELEMENT_BITMAP_RECEIVER;
        end;
      );
  end;

  PSCITER_X_MSG_PAINT = ^SCITER_X_MSG_PAINT;
  SCITER_X_MSG_PAINT = record
    header: SCITER_X_MSG;
    element: HELEMENT;    (**< [in] layer #HELEMENT, can be NULL if whole tree (document) needs to be rendered.*)
    isFore: BOOL;         (**< [in] if element is not null tells if that element is fore-layer.*)
    targetType: UINT ;    (**< [in] one of #SCITER_PAINT_TARGET_TYPE values *)
    target: SCITER_X_MSG_PAINT_TARGET;
  end;

type
  TDispatchParamArray = array[0..31] of Pointer;
  TDispatchMethodInfo = packed record
    Header     : Pointer; //ObjAuto.PMethodInfoHeader;
    ParamsAsc  : Boolean;
    ParamCount : Integer;
    Params     : TDispatchParamArray;  //PParamInfo
    MethodIndex: Integer;
    MethodName : SciterString;
    ReturnInfo : Pointer;   //PReturnInfo

    PropertyIndex: Integer;
    PropertyName: SciterString;
    IsPropertyGet: Boolean;
    IsPropertyPut: Boolean;
  end;
  PDispatchMethodInfo = ^TDispatchMethodInfo;

  TDispatchPropertyInfo = packed record
    Header: Pointer; //TypInfo.PPropInfo
    GetMethodInfo: PDispatchMethodInfo;
    SetMethodInfo: PDispatchMethodInfo;
    Defalut: Boolean;
  end;
  PDispatchPropertyInfo = ^TDispatchPropertyInfo;

const
  Delphi5      = 130;
  Delphi6      = 140;
  Delphi7      = 150;
  Delphi8      = 160;
  Delphi2005   = 170;
  Delphi2006   = 180;
  Delphi2007   = 185;
  Delphi2008   = 190;
  Delphi2009   = 200;
  Delphi2010   = 210;
  DelphiXE     = 220;
  DelphiXE2    = 230;
  DelphiXE3    = 240;
  DelphiXE4    = 250;
  DelphiXE5    = 260;
  DelphiXE6    = 270;
  DelphiXE7    = 280;
  DelphiXE8    = 290;
  DelphiXE10   = 300;
  DelphiXE10_1 = 310;
type
  IDispatchRttiObject = interface
  ['{2ADEF444-B602-43A6-9F5B-AB13A98192F8}']
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

    function  RttiGetEnumProp(const APropInfo: PDispatchPropertyInfo): SciterString;
    procedure RttiSetEnumProp(const APropInfo: PDispatchPropertyInfo; const Value: SciterString); 
    function  RttiGetPropValue(const APropInfo: PDispatchPropertyInfo; PreferStrings: Boolean = True): OleVariant;
    procedure RttiSetPropValue(const APropInfo: PDispatchPropertyInfo; const Value: OleVariant);
    function  RttiObjectInvoke(const AMethodInfo: PDispatchMethodInfo;
      const ParamIndexes: array of Integer; const Params: array of Variant): OleVariant;

    property MemberInfo[const AIndex: Integer]: PDispatchMethodInfo read GetMemberInfo;
    property MethodInfo[const AIndex: Integer]: PDispatchMethodInfo read GetMethodInfo;
    property PropertyInfo[const AIndex: Integer]: PDispatchPropertyInfo read GetPropertyInfo;
    property DispatchMethodInfo[const DispID: Integer]: PDispatchMethodInfo read GetDispatchMethodInfo;
    property DispatchPropertyInfo[const DispID: Integer]: PDispatchPropertyInfo read GetDispatchPropertyInfo;
    property MethodInfoByName[const AName: SciterString]: PDispatchMethodInfo read GetMethodInfoByName;
    property PropertyInfoByName[const AName: SciterString]: PDispatchPropertyInfo read GetPropertyInfoByName;
    property DefalutPropertyInfo: PDispatchPropertyInfo read GetDefalutPropertyInfo;

    procedure ClearMethodInfo;
    procedure ClearPropertyInfo;

    function IndexOf(const AName: SciterString): Integer;
    function IndexOfMethod(const AName: SciterString): Integer;
    function IndexOfProperty(const AName: SciterString): Integer;

    function IsMethodIndex(const AIndex: Integer): Boolean;
    function IsMethodName(const AName: SciterString): Boolean;
    function IsPropertyIndex(const AIndex: Integer): Boolean;
    function IsPropertyName(const AName: SciterString): Boolean;

    property ObjectName: SciterString read GetObjectName;
    property DelphiVersion: Cardinal read GetDelphiVersion;
  end;

{$METHODINFO ON}
  IObjectInterface = interface
  ['{745C7A99-B138-490F-8999-840F8A3FB7E7}']
    function  Implementor: Pointer;
  end;
  TSciterRttiObject = class(TInterfacedObject, IObjectInterface)
  protected
    { IObjectInterface }
    function  Implementor: Pointer; virtual;
  end;
{$METHODINFO OFF}

implementation


{ TSciterRttiObject }

function TSciterRttiObject.Implementor: Pointer;
begin
  Result := Self;
end;

end.
