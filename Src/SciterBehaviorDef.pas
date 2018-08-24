{*******************************************************************************
 标题:     SciterBehaviorDef.pas
 描述:     内部使用的 行为类
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterBehaviorDef;

interface

{$I Sciter.inc}

uses
  Windows, SysUtils, Classes, SciterTypes, TiscriptApiImpl, SciterBehavior,
  SciterIntf, ObjAuto, ObjAutoEx, TypInfo, SciterHash;

type
  TEventProcArray = array of TBehaviorEventProc;
  TMouseProcArray = array of TBehaviorMouseProc;
  TKeyProcArray   = array of TBehaviorKeyProc;

type
  TBehaviorEventHandlerAccess = class(TBehaviorEventHandler);

  TDefalutBehaviorEventHandler = class(TInterfacedObject,
    IBehaviorEventHandler,
    IDefalutBehaviorEventHandler)
  private
    FController: TBehaviorEventHandlerAccess;  // weak reference to controller
    FRttiObject: IDispatchRttiObject;
    FLayout: Pointer;
    FOwnObject: Boolean;

    FOnAttached: TBehaviorAttachedProc;
    FOnDetached: TBehaviorDetachedProc;
    FOnSubscription: TBehaviorSubscriptionProc;
    FOnDataArrived: TBehaviorDataArrivedProc;
    FOnDraw: TBehaviorDrawProc;
    FOnMouse: TBehaviorMouseProc;
    FOnEvent: TBehaviorEventProc;
    FOnKey: TBehaviorKeyProc;
    FOnFocus: TBehaviorFocusProc;
    FOnFocusGot: TBehaviorFocusProc;
    FOnFocusLost: TBehaviorFocusProc;
    FOnFocusIn: TBehaviorFocusProc;
    FOnFocusOut: TBehaviorFocusProc;
    FOnMethodCall: TBehaviorMethodCallProc;
    FOnScriptCallCs: TBehaviorScriptCallCsProc;
    FOnScriptCallTs: TBehaviorScriptCallTsProc;
    FOnScroll: TBehaviorScrollProc;
    FOnGesture: TBehaviorGestureProc;
    FOnSize: TBehaviorSizeProc;
    FOnTimer: TBehaviorTimerProc;
    FOnTimerEx: TBehaviorTimerExProc;
    
    FEventProcArrayLength: UINT;
    FEventProcArray: TEventProcArray;
    FMouseProcArrayLength: UINT;
    FMouseProcArray: TMouseProcArray;
    FKeyProcArrayLength: UINT;
    FKeyProcArray: TKeyProcArray;

    FBehaviorName: SciterString;

    FValueProp: PDispatchPropertyInfo;
    FIsEmptyProp: PDispatchPropertyInfo;
    
    FInitValueProp: Boolean;
    FInitIsEmptyProp: Boolean;

    FHasAddAfterWndProc: Boolean;
    FHasAddBeforeWndProc: Boolean;
    FAfterWndProc: TLayoutAfterWndProc;
    FBeforeWndProc: TLayoutBeforeWndProc;

    FData1: Pointer;
    FData2: Pointer;
    FData3: IInterface;
  private
    function GetRttiObject: IDispatchRttiObject;
    function GetLayout: Pointer;
    function GetController: Pointer;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetData3: IInterface;
    function GetOnAttached: TBehaviorAttachedProc;
    function GetOnDetached: TBehaviorDetachedProc;
    function GetOnSubscription: TBehaviorSubscriptionProc;
    function GetDataArrived: TBehaviorDataArrivedProc;
    function GetOnDraw: TBehaviorDrawProc;
    function GetOnButtonClick: TBehaviorEventProc;
    function GetOnButtonPress: TBehaviorEventProc;
    function GetOnButtonStateChanged: TBehaviorEventProc;
    function GetOnContextMenuRequest: TBehaviorEventProc;
    function GetOnEditValueChanged: TBehaviorEventProc;
    function GetOnEditValueChanging: TBehaviorEventProc;
    function GetOnHyperlinkClick: TBehaviorEventProc;
    function GetOnSelectSelectionChanged: TBehaviorEventProc;
    function GetOnSelectStateChanged: TBehaviorEventProc;
    function GetOnPopupRequest: TBehaviorEventProc;
    function GetOnPopupReady: TBehaviorEventProc;
    function GetOnPopupDismissing: TBehaviorEventProc;
    function GetOnPopupDismissed: TBehaviorEventProc;
    function GetOnClosePopup: TBehaviorEventProc;
    function GetOnMenuItemActive: TBehaviorEventProc;
    function GetOnMenuItemClick: TBehaviorEventProc;
    function GetOnVisiualStatusChanged: TBehaviorEventProc;
    function GetOnDisabledStatusChanged: TBehaviorEventProc;
    function GetOnContentChanged: TBehaviorEventProc;
    function GetOnElementCollapsed: TBehaviorEventProc;
    function GetOnElementExpanded: TBehaviorEventProc;
    function GetOnActivateChild: TBehaviorEventProc;
    function GetOnUIStateChanged: TBehaviorEventProc;
    function GetOnFormSubmit: TBehaviorEventProc;
    function GetOnFormReset: TBehaviorEventProc;
    function GetOnDocumentCreated: TBehaviorEventProc;
    function GetOnDocumentParsed: TBehaviorEventProc;
    function GetOnDocumentReady: TBehaviorEventProc;
    function GetOnDocumentComplete: TBehaviorEventProc;
    function GetOnDocumentClose: TBehaviorEventProc;
    function GetOnDocumentCloseRequest: TBehaviorEventProc;
    function GetOnHistoryPush: TBehaviorEventProc;
    function GetOnHistoryDrop: TBehaviorEventProc;
    function GetOnHistoryPrior: TBehaviorEventProc;
    function GetOnHistoryNext: TBehaviorEventProc;
    function GetOnHistoryStateChanged: TBehaviorEventProc;
    function GetOnRequestTooltip: TBehaviorEventProc;
    function GetOnAnimation: TBehaviorEventProc;
    function GetOnVideoInitialized: TBehaviorEventProc;
    function GetOnVideoStarted: TBehaviorEventProc;
    function GetOnVideoStopped: TBehaviorEventProc;
    function GetOnVideoBindRQ: TBehaviorEventProc;
    function GetOnPaginationStarts: TBehaviorEventProc;
    function GetOnPaginationPage: TBehaviorEventProc;
    function GetOnPaginationEnds: TBehaviorEventProc;
    function GetOnChange: TBehaviorEventProc;
    function GetOnClick: TBehaviorEventProc;
    function GetOnEventByCmd(const Cmd: UINT): TBehaviorEventProc;
    function GetOnEvent: TBehaviorEventProc;
    function GetOnFocus: TBehaviorFocusProc;
    function GetOnFocusLost: TBehaviorFocusProc;
    function GetOnFocusGot: TBehaviorFocusProc;
    function GetOnFocusIn: TBehaviorFocusProc;
    function GetOnFocusOut: TBehaviorFocusProc;
    function GetOnKey: TBehaviorKeyProc;
    function GetOnKeyDown: TBehaviorKeyProc;
    function GetOnKeyChar: TBehaviorKeyProc;
    function GetOnKeyUp: TBehaviorKeyProc;
    function GetOnKeyByType(const AType: UINT): TBehaviorKeyProc;
    function GetOnMethodCall: TBehaviorMethodCallProc;
    function GetOnMouse: TBehaviorMouseProc;
    function GetOnMouseEnter: TBehaviorMouseProc;
    function GetOnMouseLeave: TBehaviorMouseProc;
    function GetOnMouseMove: TBehaviorMouseProc;
    function GetOnMouseUp: TBehaviorMouseProc;
    function GetOnMouseDown: TBehaviorMouseProc;
    function GetOnMouseClick: TBehaviorMouseProc;
    function GetOnMouseDClick: TBehaviorMouseProc;
    function GetOnMouseWheel: TBehaviorMouseProc;
    function GetOnMouseTick: TBehaviorMouseProc;
    function GetOnMouseIdle: TBehaviorMouseProc;
    function GetOnDrop: TBehaviorMouseProc;
    function GetOnDragEnter: TBehaviorMouseProc;
    function GetOnDragLeave: TBehaviorMouseProc;
    function GetOnDragRequest: TBehaviorMouseProc;
    function GetOnDragging: TBehaviorMouseProc;
    function GetOnMouseByType(const AType: UINT): TBehaviorMouseProc;
    function GetOnScriptCallCs: TBehaviorScriptCallCsProc;
    function GetOnScriptCallTs: TBehaviorScriptCallTsProc;
    function GetOnScroll: TBehaviorScrollProc;
    function GetOnGesture: TBehaviorGestureProc;
    function GetOnSize: TBehaviorSizeProc;
    function GetOnTimer: TBehaviorTimerProc;
    function GetOnTimerEx: TBehaviorTimerExProc;
    function GetAfterWndProc: TLayoutAfterWndProc;
    function GetBeforeWndProc: TLayoutBeforeWndProc;
    procedure SetRttiObject(const Value: IDispatchRttiObject);
    procedure SetLayout(const Value: Pointer);
    procedure SetController(const Value: Pointer);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetData3(const Value: IInterface);
    procedure SetOnAttached(const Value: TBehaviorAttachedProc);
    procedure SetOnDetached(const Value: TBehaviorDetachedProc);
    procedure SetOnSubscription(const Value: TBehaviorSubscriptionProc);
    procedure SetDataArrived(const Value: TBehaviorDataArrivedProc);
    procedure SetOnDraw(const Value: TBehaviorDrawProc);
    procedure SetOnButtonClick(const Value: TBehaviorEventProc);
    procedure SetOnButtonPress(const Value: TBehaviorEventProc);
    procedure SetOnButtonStateChanged(const Value: TBehaviorEventProc);
    procedure SetOnContextMenuRequest(const Value: TBehaviorEventProc);
    procedure SetOnEditValueChanged(const Value: TBehaviorEventProc);
    procedure SetOnEditValueChanging(const Value: TBehaviorEventProc);
    procedure SetOnHyperlinkClick(const Value: TBehaviorEventProc);
    procedure SetOnSelectSelectionChanged(const Value: TBehaviorEventProc);
    procedure SetOnSelectStateChanged(const Value: TBehaviorEventProc);
    procedure SetOnPopupRequest(const Value: TBehaviorEventProc);
    procedure SetOnPopupReady(const Value: TBehaviorEventProc);
    procedure SetOnPopupDismissing(const Value: TBehaviorEventProc);
    procedure SetOnPopupDismissed(const Value: TBehaviorEventProc);
    procedure SetOnClosePopup(const Value: TBehaviorEventProc);
    procedure SetOnMenuItemActive(const Value: TBehaviorEventProc);
    procedure SetOnMenuItemClick(const Value: TBehaviorEventProc);
    procedure SetOnVisiualStatusChanged(const Value: TBehaviorEventProc);
    procedure SetOnDisabledStatusChanged(const Value: TBehaviorEventProc);
    procedure SetOnContentChanged(const Value: TBehaviorEventProc);
    procedure SetOnElementCollapsed(const Value: TBehaviorEventProc);
    procedure SetOnElementExpanded(const Value: TBehaviorEventProc);
    procedure SetOnActivateChild(const Value: TBehaviorEventProc);
    procedure SetOnUIStateChanged(const Value: TBehaviorEventProc);
    procedure SetOnFormSubmit(const Value: TBehaviorEventProc);
    procedure SetOnFormReset(const Value: TBehaviorEventProc);
    procedure SetOnDocumentCreated(const Value: TBehaviorEventProc);
    procedure SetOnDocumentParsed(const Value: TBehaviorEventProc);
    procedure SetOnDocumentReady(const Value: TBehaviorEventProc);
    procedure SetOnDocumentComplete(const Value: TBehaviorEventProc);
    procedure SetOnDocumentClose(const Value: TBehaviorEventProc);
    procedure SetOnDocumentCloseRequest(const Value: TBehaviorEventProc);
    procedure SetOnHistoryPush(const Value: TBehaviorEventProc);
    procedure SetOnHistoryDrop(const Value: TBehaviorEventProc);
    procedure SetOnHistoryPrior(const Value: TBehaviorEventProc);
    procedure SetOnHistoryNext(const Value: TBehaviorEventProc);
    procedure SetOnHistoryStateChanged(const Value: TBehaviorEventProc);
    procedure SetOnRequestTooltip(const Value: TBehaviorEventProc);
    procedure SetOnAnimation(const Value: TBehaviorEventProc);
    procedure SetOnVideoInitialized(const Value: TBehaviorEventProc);
    procedure SetOnVideoStarted(const Value: TBehaviorEventProc);
    procedure SetOnVideoStopped(const Value: TBehaviorEventProc);
    procedure SetOnVideoBindRQ(const Value: TBehaviorEventProc);
    procedure SetOnPaginationStarts(const Value: TBehaviorEventProc);
    procedure SetOnPaginationPage(const Value: TBehaviorEventProc);
    procedure SetOnPaginationEnds(const Value: TBehaviorEventProc);
    procedure SetOnChange(const Value: TBehaviorEventProc);
    procedure SetOnClick(const Value: TBehaviorEventProc);
    procedure SetOnEventByCmd(const Cmd: UINT; const Value: TBehaviorEventProc);
    procedure SetOnEvent(const Value: TBehaviorEventProc);
    procedure SetOnFocus(const Value: TBehaviorFocusProc);
    procedure SetOnFocusLost(const Value: TBehaviorFocusProc);
    procedure SetOnFocusGot(const Value: TBehaviorFocusProc);
    procedure SetOnFocusIn(const Value: TBehaviorFocusProc);
    procedure SetOnFocusOut(const Value: TBehaviorFocusProc);
    procedure SetOnKey(const Value: TBehaviorKeyProc);
    procedure SetOnKeyDown(const Value: TBehaviorKeyProc);
    procedure SetOnKeyChar(const Value: TBehaviorKeyProc);
    procedure SetOnKeyUp(const Value: TBehaviorKeyProc);
    procedure SetOnKeyByType(const AType: UINT; const Value: TBehaviorKeyProc);
    procedure SetOnMethodCall(const Value: TBehaviorMethodCallProc);
    procedure SetOnMouse(const Value: TBehaviorMouseProc);
    procedure SetOnMouseEnter(const Value: TBehaviorMouseProc);
    procedure SetOnMouseLeave(const Value: TBehaviorMouseProc);
    procedure SetOnMouseMove(const Value: TBehaviorMouseProc);
    procedure SetOnMouseUp(const Value: TBehaviorMouseProc);
    procedure SetOnMouseDown(const Value: TBehaviorMouseProc);
    procedure SetOnMouseClick(const Value: TBehaviorMouseProc);
    procedure SetOnMouseDClick(const Value: TBehaviorMouseProc);
    procedure SetOnMouseWheel(const Value: TBehaviorMouseProc);
    procedure SetOnMouseTick(const Value: TBehaviorMouseProc);
    procedure SetOnMouseIdle(const Value: TBehaviorMouseProc);
    procedure SetOnDrop(const Value: TBehaviorMouseProc);
    procedure SetOnDragEnter(const Value: TBehaviorMouseProc);
    procedure SetOnDragLeave(const Value: TBehaviorMouseProc);
    procedure SetOnDragRequest(const Value: TBehaviorMouseProc);
    procedure SetOnDragging(const Value: TBehaviorMouseProc);
    procedure SetOnMouseByType(const AType: UINT; const Value: TBehaviorMouseProc);
    procedure SetOnScriptCallCs(const Value: TBehaviorScriptCallCsProc);
    procedure SetOnScriptCallTs(const Value: TBehaviorScriptCallTsProc);
    procedure SetOnScroll(const Value: TBehaviorScrollProc);
    procedure SetOnGesture(const Value: TBehaviorGestureProc);
    procedure SetOnSize(const Value: TBehaviorSizeProc);
    procedure SetOnTimer(const Value: TBehaviorTimerProc);
    procedure SetOnTimerEx(const Value: TBehaviorTimerExProc);
    procedure SetAfterWndProc(const Value: TLayoutAfterWndProc);
    procedure SetBeforeWndProc(const Value: TLayoutBeforeWndProc);
  protected
    { IInterface }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    function DoScriptCallTs(he: HELEMENT; var params: TTiscriptMethodParams): Boolean; virtual;

    function DoBeforeWndProc(msg: UINT;
      wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT; virtual;
    procedure DoAfterWndProc(msg: UINT;
      wParam: WPARAM; lParam: LPARAM; var Result: LRESULT); virtual;
  public
    constructor Create(const ABehaviorName: SciterString; AOwnObject: Boolean = False); overload; // EVENT_GROUPS flags
    constructor Create(const ABehaviorName: SciterString; const Controller: Pointer; ARttiObject: IDispatchRttiObject); overload;
    destructor Destroy; override;

    function  Implementor: Pointer;

    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;
    function  IsType(event, event_type: UINT): Boolean;

    procedure Attached(he: HELEMENT); virtual;
    procedure Detached(he: HELEMENT); virtual;
    // defines list of event groups this event_handler is subscribed to
    function Subscription(he: HELEMENT; var event_groups: UINT{EVENT_GROUPS}): Boolean; virtual;
    // handlers with extended interface
    // by default they are calling old set of handlers (for compatibility with legacy code)
    function  HandleMouse(he: HELEMENT; var params: TMouseParams): Boolean; virtual;
    function  HandleKey(he: HELEMENT; var params: TKeyParams): Boolean; virtual;
    function  HandleFocus(he: HELEMENT; var params: TFocusParams): Boolean; virtual;
    function  HandleTimer(he: HELEMENT; var params: TTimerParams): Boolean; virtual;
    procedure HandleSize(he: HELEMENT); virtual;
    function  HandleScroll(he: HELEMENT; params: TScorllParams): Boolean; virtual;
    function  HandleGesture(he: HELEMENT; var params: TGestrueParams): Boolean; virtual;
    function  HandleDraw(he: HELEMENT; var params: TDrawParams): Boolean; virtual;
    function  HandleMethodCall(he: HELEMENT; var params: TMethodParams): Boolean; virtual;
    // notification events from builtin behaviors - synthesized events: BUTTON_CLICK, VALUE_CHANGED
    // see enum BEHAVIOR_EVENTS
    function HandleEvent(he: HELEMENT; var params: TBehaviorEventParams): Boolean; virtual;
    // notification event: data requested by HTMLayoutRequestData just delivered
    function HandleDataArrived(he: HELEMENT; var params: TDataArrivedParams): Boolean; virtual;
    function HandleScriptingCallCs(he: HELEMENT; var params: TScriptingMethodParams): Boolean; overload; virtual;
    function HandleScriptingCallTs(he: HELEMENT; var params: TTiscriptMethodParams): Boolean; overload; virtual;

    function AddBeforeWndProc: Integer;
    function RemoveBeforeWndProc: Integer;

    function AddAfterWndProc: Integer;
    function RemoveAfterWndProc: Integer;

    property RttiObject: IDispatchRttiObject read GetRttiObject write SetRttiObject;

    property OnAttached: TBehaviorAttachedProc read GetOnAttached write SetOnAttached;
    property OnDetached: TBehaviorDetachedProc read GetOnDetached write SetOnDetached;
    property OnSubscription: TBehaviorSubscriptionProc read GetOnSubscription write SetOnSubscription;

    property OnMouse: TBehaviorMouseProc read GetOnMouse write SetOnMouse;
    property OnMouseEnter: TBehaviorMouseProc read GetOnMouseEnter write SetOnMouseEnter;
    property OnMouseLeave: TBehaviorMouseProc read GetOnMouseLeave write SetOnMouseLeave;
    property OnMouseMove: TBehaviorMouseProc read GetOnMouseMove write SetOnMouseMove;
    property OnMouseUp: TBehaviorMouseProc read GetOnMouseUp write SetOnMouseUp;
    property OnMouseDown: TBehaviorMouseProc read GetOnMouseDown write SetOnMouseDown;
    property OnMouseClick: TBehaviorMouseProc read GetOnMouseClick write SetOnMouseClick;
    property OnMouseDClick: TBehaviorMouseProc read GetOnMouseDClick write SetOnMouseDClick;
    property OnMouseWheel: TBehaviorMouseProc read GetOnMouseWheel write SetOnMouseWheel;
    property OnMouseTick: TBehaviorMouseProc read GetOnMouseTick write SetOnMouseTick;
    property OnMouseIdle: TBehaviorMouseProc read GetOnMouseIdle write SetOnMouseIdle;

    property OnDrop: TBehaviorMouseProc read GetOnDrop write SetOnDrop;
    property OnDragEnter: TBehaviorMouseProc read GetOnDragEnter write SetOnDragEnter;
    property OnDragLeave: TBehaviorMouseProc read GetOnDragLeave write SetOnDragLeave;
    property OnDragRequest: TBehaviorMouseProc read GetOnDragRequest write SetOnDragRequest;
    property OnDragging: TBehaviorMouseProc read GetOnDragging write SetOnDragging;

    property OnKey: TBehaviorKeyProc read GetOnKey write SetOnKey;
    property OnKeyDown: TBehaviorKeyProc read GetOnKeyDown write SetOnKeyDown;
    property OnKeyUp: TBehaviorKeyProc read GetOnKeyUp write SetOnKeyUp;
    property OnKeyChar: TBehaviorKeyProc read GetOnKeyChar write SetOnKeyChar;

    property OnFocus: TBehaviorFocusProc read GetOnFocus write SetOnFocus;
    property OnFocusGot: TBehaviorFocusProc read GetOnFocusGot write SetOnFocusGot;
    property OnFocusLost: TBehaviorFocusProc read GetOnFocusLost write SetOnFocusLost;
    property OnFocusIn: TBehaviorFocusProc read GetOnFocusIn write SetOnFocusIn;
    property OnFocusOut: TBehaviorFocusProc read GetOnFocusOut write SetOnFocusOut;
    property OnTimer: TBehaviorTimerProc read GetOnTimer write SetOnTimer;
    property OnTimerEx: TBehaviorTimerExProc read GetOnTimerEx write SetOnTimerEx;
    property OnDraw: TBehaviorDrawProc read GetOnDraw write SetOnDraw;
    property OnSize: TBehaviorSizeProc read GetOnSize write SetOnSize;
    property OnMethodCall: TBehaviorMethodCallProc read GetOnMethodCall write SetOnMethodCall;
    property OnScriptCallCs: TBehaviorScriptCallCsProc read GetOnScriptCallCs write SetOnScriptCallCs;
    property OnScriptCallTs: TBehaviorScriptCallTsProc read GetOnScriptCallTs write SetOnScriptCallTs;

    {generic click}
    property OnClick: TBehaviorEventProc read GetOnClick write SetOnClick;
    {generic change}
    property OnChange: TBehaviorEventProc read GetOnChange write SetOnChange;
    {click on button}
    property OnButtonClick: TBehaviorEventProc read GetOnButtonClick write SetOnButtonClick;
    {mouse down or key down in button}
    property OnButtonPress: TBehaviorEventProc read GetOnButtonPress write SetOnButtonPress;
    {checkbox/radio/slider changed its state/value}
    property OnButtonStateChanged: TBehaviorEventProc read GetOnButtonStateChanged write SetOnButtonStateChanged;

    {before text change}
    property OnEditValueChanging: TBehaviorEventProc read GetOnEditValueChanging write SetOnEditValueChanging;
    {after text change}
    property OnEditValueChanged: TBehaviorEventProc read GetOnEditValueChanged write SetOnEditValueChanged;

    {selection in <select> changed}
    property OnSelectSelectionChanged: TBehaviorEventProc read GetOnSelectSelectionChanged write SetOnSelectSelectionChanged;
    {node in select expanded/collapsed, heTarget is the node}
    property OnSelectStateChanged: TBehaviorEventProc read GetOnSelectStateChanged write SetOnSelectStateChanged;

    {request tooltip, evt.source <- is the tooltip element.}
    property OnRequestTooltip: TBehaviorEventProc read GetOnRequestTooltip write SetOnRequestTooltip;

    {request to show popup just received,
     here DOM of popup element can be modifed.}
    property OnPopupRequest: TBehaviorEventProc read GetOnPopupRequest write SetOnPopupRequest;
    {popup element has been measured and ready to be shown on screen,
     here you can use functions like ScrollToView.}
    property OnPopupReady: TBehaviorEventProc read GetOnPopupReady write SetOnPopupReady;
    {popup is about to be closed}
    property OnPopupDismissing: TBehaviorEventProc read GetOnPopupDismissing write SetOnPopupDismissing;
    {popup element is closed,
     here DOM of popup element can be modifed again - e.g. some items can be removed to free memory.}
    property OnPopupDismissed: TBehaviorEventProc read GetOnPopupDismissed write SetOnPopupDismissed;
    {close popup request}
    property OnClosePopup: TBehaviorEventProc read GetOnClosePopup write SetOnClosePopup;

    {menu item activated by mouse hover or by keyboard}
    property OnMenuItemActive: TBehaviorEventProc read GetOnMenuItemActive write SetOnMenuItemActive;
    {menu item click,
     //   BEHAVIOR_EVENT_PARAMS structure layout
     //   BEHAVIOR_EVENT_PARAMS.cmd - MENU_ITEM_CLICK/MENU_ITEM_ACTIVE
     //   BEHAVIOR_EVENT_PARAMS.heTarget - owner(anchor) of the menu
     //   BEHAVIOR_EVENT_PARAMS.he - the menu item, presumably <li> element
     //   BEHAVIOR_EVENT_PARAMS.reason - BY_MOUSE_CLICK | BY_KEY_CLICK
    }
    property OnMenuItemClick: TBehaviorEventProc read GetOnMenuItemClick write SetOnMenuItemClick;
    {"right-click", BEHAVIOR_EVENT_PARAMS::he is current popup menu HELEMENT being processed or NULL.
     application can provide its own HELEMENT here (if it is NULL) or modify current menu element.
    }
    property OnContextMenuRequest: TBehaviorEventProc read GetOnContextMenuRequest write SetOnContextMenuRequest;

    {broadcast notification, sent to all elements of some container being shown or hidden}
    property OnVisiualStatusChanged: TBehaviorEventProc read GetOnVisiualStatusChanged write SetOnVisiualStatusChanged;
    {broadcast notification, sent to all elements of some container that got new value of :disabled state}
    property OnDisabledStatusChanged: TBehaviorEventProc read GetOnDisabledStatusChanged write SetOnDisabledStatusChanged;

    {content has been changed, is posted to the element that gets content changed,  reason is combination of CONTENT_CHANGE_BITS.
     target == NULL means the window got new document and this event is dispatched only to the window.}
    property OnContentChanged: TBehaviorEventProc read GetOnContentChanged write SetOnContentChanged;
    {hyperlink click}
    property OnHyperlinkClick: TBehaviorEventProc read GetOnHyperlinkClick write SetOnHyperlinkClick;

    {element was collapsed, so far only behavior:tabs is sending these two to the panels}
    property OnElementCollapsed: TBehaviorEventProc read GetOnElementCollapsed write SetOnElementCollapsed;
    {element was expanded}
    property OnElementExpanded: TBehaviorEventProc read GetOnElementExpanded write SetOnElementExpanded;

    {activate (select) child,
     used for example by accesskeys behaviors to send activation request, e.g. tab on behavior:tabs.}
    property OnActivateChild: TBehaviorEventProc read GetOnActivateChild write SetOnActivateChild;

    {ui state changed, observers shall update their visual states.
     is sent for example by behavior:richtext when caret position/selection has changed.}
    property OnUIStateChanged: TBehaviorEventProc read GetOnUIStateChanged write SetOnUIStateChanged;

    {behavior:form detected submission event. BEHAVIOR_EVENT_PARAMS::data field contains data to be posted.
     BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
     to be submitted. You can modify the data or discard submission by returning true from the handler.}
    property OnFormSubmit: TBehaviorEventProc read GetOnFormSubmit write SetOnFormSubmit;
    {behavior:form detected reset event (from button type=reset). BEHAVIOR_EVENT_PARAMS::data field contains data to be reset.
     BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
     to be rest. You can modify the data or discard reset by returning true from the handler.}
    property OnFormReset: TBehaviorEventProc read GetOnFormReset write SetOnFormReset;

    {document created, script namespace initialized. target -> the document}
    property OnDocumentCreated: TBehaviorEventProc read GetOnDocumentCreated write SetOnDocumentCreated;
    {document just finished parsing - has got DOM structure. This event is generated before DOCUMENT_READY}
    property OnDocumentParsed: TBehaviorEventProc read GetOnDocumentParsed write SetOnDocumentParsed;
    {document has got DOM structure, styles and behaviors of DOM elements. Script loading run is complete at this moment.}
    property OnDocumentReady: TBehaviorEventProc read GetOnDocumentReady write SetOnDocumentReady;
    {document in behavior:frame or root document is complete.}
    property OnDocumentComplete: TBehaviorEventProc read GetOnDocumentComplete write SetOnDocumentComplete;
    {document is about to be closed, to cancel closing do: evt.data = sciter::value("cancel");}
    property OnDocumentCloseRequest: TBehaviorEventProc read GetOnDocumentCloseRequest write SetOnDocumentCloseRequest;
    {last notification before document removal from the DOM}
    property OnDocumentClose: TBehaviorEventProc read GetOnDocumentClose write SetOnDocumentClose;

    {requests to behavior:history (commands)}
    property OnHistoryPush: TBehaviorEventProc read GetOnHistoryPush write SetOnHistoryPush;
    property OnHistoryDrop: TBehaviorEventProc read GetOnHistoryDrop write SetOnHistoryDrop;
    property OnHistoryPrior: TBehaviorEventProc read GetOnHistoryPrior write SetOnHistoryPrior;
    property OnHistoryNext: TBehaviorEventProc read GetOnHistoryNext write SetOnHistoryNext;
    {behavior:history notification - history stack has changed}
    property OnHistoryStateChanged: TBehaviorEventProc read GetOnHistoryStateChanged write SetOnHistoryStateChanged;

    {animation started (reason=1) or ended(reason=0) on the element.}
    property OnAnimation: TBehaviorEventProc read GetOnAnimation write SetOnAnimation;

    {<video> "ready" notification}
    property OnVideoInitialized: TBehaviorEventProc read GetOnVideoInitialized write SetOnVideoInitialized;
    {<video> playback started notification}
    property OnVideoStarted: TBehaviorEventProc read GetOnVideoStarted write SetOnVideoStarted;
    {<video> playback stoped/paused notification}
    property OnVideoStopped: TBehaviorEventProc read GetOnVideoStopped write SetOnVideoStopped;
    { <video> request for frame source binding,
        If you want to provide your own video frames source for the given target <video> element do the following:
        1. Handle and consume this VIDEO_BIND_RQ request
        2. You will receive second VIDEO_BIND_RQ request/event for the same <video> element
           but this time with the 'reason' field set to an instance of sciter::video_destination interface.
        3. add_ref() it and store it for example in worker thread producing video frames.
        4. call sciter::video_destination::start_streaming(...) providing needed parameters
           call sciter::video_destination::render_frame(...) as soon as they are available
           call sciter::video_destination::stop_streaming() to stop the rendering (a.k.a. end of movie reached)
    }
    property OnVideoBindRQ: TBehaviorEventProc read GetOnVideoBindRQ write SetOnVideoBindRQ;
    {behavior:pager starts pagination}
    property OnPaginationStarts: TBehaviorEventProc read GetOnPaginationStarts write SetOnPaginationStarts;
    {behavior:pager paginated page no, reason -> page no}
    property OnPaginationPage: TBehaviorEventProc read GetOnPaginationPage write SetOnPaginationPage;
    {behavior:pager end pagination, reason -> total pages}
    property OnPaginationEnds: TBehaviorEventProc read GetOnPaginationEnds write SetOnPaginationEnds;
                    
    property OnEvent: TBehaviorEventProc read GetOnEvent write SetOnEvent;
    property OnDataArrived: TBehaviorDataArrivedProc read GetDataArrived write SetDataArrived;
    property OnScroll: TBehaviorScrollProc read GetOnScroll write SetOnScroll;
    property OnGesture: TBehaviorGestureProc read GetOnGesture write SetOnGesture;

    property BeforeWndProc: TLayoutBeforeWndProc read GetBeforeWndProc write SetBeforeWndProc;
    property AfterWndProc: TLayoutAfterWndProc read GetAfterWndProc write SetAfterWndProc;

    property Layout: Pointer read GetLayout write SetLayout;
    property Controller: Pointer read GetController write SetController;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
    property Data3: IInterface read GetData3 write SetData3;
  end;

  TBehaviorFactorys = class(TInterfacedObject, IBehaviorFactorys)
  private
    FList: IInterfaceList;
    FNameHash: TStringHash;
    FNameHashValid: Boolean;
  protected
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IBehaviorFactory;
    function  GetItemByName(const AName: SciterString): IBehaviorFactory;
    procedure SetItem(const Index: Integer; const Value: IBehaviorFactory);
    procedure SetItemByName(const AName: SciterString; const Value: IBehaviorFactory);
  protected
    procedure UpdateNameHash;
  public
    constructor Create;
    destructor Destroy; override;

    function  Reg(AItem: IBehaviorFactory): Integer;
    procedure UnReg(AItem: IBehaviorFactory); overload;
    procedure UnReg(const AName: SciterString); overload;

    function  ToString: SciterString; reintroduce;

    procedure Invalidate;

    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IBehaviorFactory);
    function  IndexOf(const AItem: IBehaviorFactory): Integer;
    function  IndexOfName(const AName: SciterString): Integer;
    function  First: IBehaviorFactory;
    function  Last: IBehaviorFactory;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IBehaviorFactory read GetItem write SetItem; default;
    property ItemByName[const AName: SciterString]: IBehaviorFactory read GetItemByName write SetItemByName;
  end;

function GetValueParams(do_set: bool): TValueParams;
function GetIsEmptyParams(): TIsEmptyParams;

function _element_proc(tag: LPVOID; he: HELEMENT; evtg: UINT; prms: LPVOID): BOOL; stdcall;

function CreateEventHandler(const name: SciterString; he: HELEMENT;
  ABehaviorFactorys: IBehaviorFactorys; const ALayout: ISciterLayout): IBehaviorEventHandler;

// standard implementation of SCN_ATTACH_BEHAVIOR notification
function CreateBehavior(var lpab: LPSCN_ATTACH_BEHAVIOR;
  const ABehaviorFactorys: IBehaviorFactorys; const ALayout: ISciterLayout): Boolean;

var
  _ReportBehaviorCount: Boolean = False;

implementation

uses
  SciterApiImpl, Variants, SciterFactoryIntf;
    
var
  varBehaviorNames: TStrings = nil;
  varBehaviorCount: Integer = 0;

procedure CheckBehaviorLeak;
var
  i: Integer;
  sBehaviorNamesStr: string;
begin
  if _ReportBehaviorCount then
  begin
    if varBehaviorCount <> 0 then
    begin
      for i := 0 to varBehaviorNames.Count -1 do
      begin
        sBehaviorNamesStr := sBehaviorNamesStr + varBehaviorNames[i];
        if i < varBehaviorNames.Count -1 then
          sBehaviorNamesStr := sBehaviorNamesStr + sLineBreak;
      end;
      MessageBox(0,
        PChar('共有' + IntToStr(varBehaviorCount)+
          '个Behavior未释放, 这些Behavior有：'#13#10 + sBehaviorNamesStr),
       '警告',
       MB_OK + MB_ICONWARNING);
    end;
  end;
end;


function GetValueParams(do_set: bool): TValueParams;
begin
  if do_set then
    Result.methodID := SET_VALUE
  else
    Result.methodID := GET_VALUE;
end;

function GetIsEmptyParams(): TIsEmptyParams;
begin
  Result.is_empty := 0;
  Result.methodID := IS_EMPTY;
end;

function CreateEventHandler(const name: SciterString; he: HELEMENT;
  ABehaviorFactorys: IBehaviorFactorys; const ALayout: ISciterLayout): IBehaviorEventHandler;
var
  i: Integer;
begin
  if ABehaviorFactorys = nil then
    ABehaviorFactorys := BehaviorFactorys;
  i := ABehaviorFactorys.IndexOfName(name);
  if i >= 0 then
    Result := ABehaviorFactorys[i].CreateHandler(ElementFactory.Create(he), ALayout)
  else
    Result := nil;
end;

function CreateBehavior(var lpab: LPSCN_ATTACH_BEHAVIOR;
  const ABehaviorFactorys: IBehaviorFactorys; const ALayout: ISciterLayout): Boolean;
var
  pb: IBehaviorEventHandler;
  sBehaviorName: SciterString;
begin
  sBehaviorName := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(lpab.behaviorName);
  if sBehaviorName = '~' then
  begin
    Result := False;
    Exit;
  end;
  pb := CreateEventHandler(sBehaviorName, lpab.element, ABehaviorFactorys, ALayout);
  Result := pb <> nil;
  if Result then
  begin
    lpab.elementTag  := Pointer(pb);
    lpab.elementProc := _element_proc;
  end
end;


{ TDefalutBehaviorEventHandler }

// ElementEventProc implementeation
function _element_proc(tag: LPVOID; he: HELEMENT; evtg: UINT; prms: LPVOID): BOOL; stdcall;
var
  pThis: IBehaviorEventHandler;
begin
  Result := False;
  try
    pThis := IBehaviorEventHandler(tag);
    if (pThis = nil) then
      Exit;
    case evtg of
      SUBSCRIPTIONS_REQUEST:
      begin
        Result := pThis.subscription( he, PUINT(prms)^);
      end;
      HANDLE_INITIALIZATION:
      begin
        case PInitializationParams(prms).cmd of
          BEHAVIOR_DETACH: pThis.Detached(he);
          BEHAVIOR_ATTACH: pThis.Attached(he);
        end;
        Result := True;
      end;
      HANDLE_MOUSE:
      begin
        Result := pThis.HandleMouse(he, PMouseParams(prms)^)
      end; 
      HANDLE_KEY:
      begin
        Result := pThis.HandleKey(he, PKeyParams(prms)^)
      end;
      HANDLE_FOCUS:
      begin
        Result := pThis.HandleFocus(he, PFocusParams(prms)^)
      end;
      HANDLE_DRAW:
      begin
        Result := pThis.HandleDraw(he, PDrawParams(prms)^)
      end;
      HANDLE_TIMER:
      begin              
        Result := pThis.HandleTimer(he, PTimerParams(prms)^)
      end;
      HANDLE_BEHAVIOR_EVENT:
      begin
        Result := pThis.HandleEvent(he, PBehaviorEventParams(prms)^);
        //if PBehaviorEventParams(prms)^.cmd = DOCUMENT_CLOSE then
        //  pThis := nil;
      end;
      HANDLE_METHOD_CALL:
      begin
        Result := pThis.HandleMethodCall(he, PMethodParams(prms)^)
      end;
      HANDLE_DATA_ARRIVED:
      begin
        Result := pThis.HandleDataArrived(he, PDataArrivedParams(prms)^)
      end;
      HANDLE_SCROLL:
      begin
        Result := pThis.HandleScroll(he, PScorllParams(prms)^)
      end;
      HANDLE_SIZE:
      begin
        pThis.HandleSize(he);
        Result := False;
      end;
      // call using json::value's (from CSSS!)
      HANDLE_SCRIPTING_METHOD_CALL:
      begin
        Result := pThis.HandleScriptingCallCs(he, PScriptingMethodParams(prms)^)
      end;
      // call using tiscript::value's (from the script)
      HANDLE_TISCRIPT_METHOD_CALL:
      begin
        Result := pThis.HandleScriptingCallTs(he, PTiscriptMethodParams(prms)^)
      end;
      HANDLE_GESTURE:
      begin
        Result := pThis.HandleGesture(he, PGestrueParams(prms)^)
      end;
    end;
  except
    on E: Exception do
      TraceException('[_element_proc]'+E.Message);
  end;
end;

procedure TDefalutBehaviorEventHandler.Attached(he: HELEMENT);
begin
  try
    if @FOnAttached <> nil then
      FOnAttached(ElementFactory.Create(he));
  except
    on E: Exception do
    begin   
      TraceException('['+FBehaviorName+'.Attached]'+E.Message);
    end
  end;
end;

constructor TDefalutBehaviorEventHandler.Create(const ABehaviorName: SciterString; AOwnObject: Boolean);
begin
  FOwnObject := AOwnObject;
  FBehaviorName := ABehaviorName;
  FEventProcArrayLength := FIRST_APPLICATION_EVENT_CODE + 1;
  SetLength(FEventProcArray, FEventProcArrayLength);
  FMouseProcArrayLength := DRAGGING + 1;
  SetLength(FMouseProcArray, FMouseProcArrayLength);
  FKeyProcArrayLength := KEY_CHAR + 1;
  SetLength(FKeyProcArray, FKeyProcArrayLength);

  if FBehaviorName = EmptyStr then
    FBehaviorName := 'TDefalutBehaviorEventHandler';

  if _ReportBehaviorCount then
  begin
    InterlockedIncrement(varBehaviorCount);
    varBehaviorNames.Add(FBehaviorName);
  end;
end;

procedure TDefalutBehaviorEventHandler.Detached(he: HELEMENT);
begin
  try
    if @FOnDetached <> nil then
      FOnDetached(ElementFactory.Create(he));

//    if FBehaviorName = 'TWinCmdBehavior' then
//      Log('[TDefalutBehaviorEventHandler]'+FBehaviorName + ' Detached');
    if (FController <> nil) or (FOwnObject) then
      _Release;
    //Log('after Detached: ' + IntToStr(FRefCount));
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.Detached]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleDataArrived(he: HELEMENT;
  var params: TDataArrivedParams): Boolean;
var
  LHe, LInitiator: IDomElement;
begin
  Result := False;
  try
    if @FOnDataArrived <> nil then
    begin
      LHe := ElementFactory.Create(he);
      LInitiator := ElementFactory.Create(params.initiator);
      
      Result := FOnDataArrived(LHe, LInitiator, params);

      LHe := nil;
      LInitiator := nil;
    end;

  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleDataArrived]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleDraw(he: HELEMENT;
  var params: TDrawParams): Boolean;
var
  LHe: IDomElement;
begin
  Result := False;
  try
    if @FOnDraw <> nil then
    begin
      LHe := ElementFactory.Create(he);
      Result := FOnDraw(LHe, params.cmd, params);
      LHe := nil;
    end;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleDraw]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleEvent(he: HELEMENT;
  var params: TBehaviorEventParams): Boolean;
var
  LEventProc: TBehaviorEventProc;
  LHe, LTarget: IDomElement;
begin
  Result := False;
  try
    LEventProc := GetOnEventByCmd(params.cmd);
    if (he = nil) or (params.heTarget = nil) then
      Exit;

    LHe := nil;
    LTarget := nil;
    if (@LEventProc <> nil) then
    begin
      LHe := ElementFactory.Create(he);
      LTarget := ElementFactory.Create(params.heTarget);

      Result := LEventProc(LHe, LTarget, params.cmd, params);
    end;

    if (not Result) and (@FOnEvent <> nil) then
    begin
      if LHe = nil then
        LHe := ElementFactory.Create(he);
      if LTarget = nil then
        LTarget := ElementFactory.Create(params.heTarget);
      
      Result := FOnEvent(LHe, LTarget, params.cmd, params);
    end;
  except
    on E: Exception do
      TraceException('['+FBehaviorName+'.HandleEvent]['+IntToStr(params.cmd)+']'+E.Message);
  end;
end;

function TDefalutBehaviorEventHandler.HandleFocus(he: HELEMENT;
  var params: TFocusParams): Boolean;
var
  LHe, LTarget: IDomElement;
  iPhaseMask: UINT;
  iType: UINT;
  LOnFocus: TBehaviorFocusProc;
begin
  Result := False;
  try
    iPhaseMask := params.cmd and (BUBBLING or SINKING or HANDLED);
    iType := params.cmd and not iPhaseMask;

    if iType = FOCUS_LOST then
      LOnFocus := FOnFocusLost
    else
    if iType = FOCUS_GOT then
      LOnFocus := FOnFocusGot
    else
    if iType = FOCUS_IN then
      LOnFocus := FOnFocusIn
    else
    if iType = FOCUS_OUT then
      LOnFocus := FOnFocusOut
    else
      LOnFocus := nil;
           
    if @LOnFocus <> nil then
    begin
      LHe := ElementFactory.Create(he);
      LTarget := ElementFactory.Create(params.target);
      
      Result := LOnFocus(LHe, LTarget, params.cmd, params);
    end;

    if (not Result) and (@FOnFocus <> nil) then
    begin
      if LHe = nil then
        LHe := ElementFactory.Create(he);
      if LTarget = nil then
        LTarget := ElementFactory.Create(params.target);
      
      Result := FOnFocus(LHe, LTarget, params.cmd, params);
    end;
    
    LHe := nil;
    LTarget := nil;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleFocus]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleKey(he: HELEMENT;
  var params: TKeyParams): Boolean;
var
  LOnKey: TBehaviorKeyProc;
  LHe, LTarget: IDomElement;
begin
  Result := False;
  try
    LOnKey :=  GetOnKeyByType(params.cmd);
    if @LOnKey <> nil then
    begin
      LHe := ElementFactory.Create(he);
      LTarget := ElementFactory.Create(params.target);
      
      Result := LOnKey(LHe, LTarget, params.cmd, params);
    end;
    
    if (not Result) and (@FOnKey <> nil) then
    begin
      if LHe = nil then
        LHe := ElementFactory.Create(he);
      if LTarget = nil then
        LTarget := ElementFactory.Create(params.target);
      
      Result := FOnKey(LHe, LTarget, params.cmd, params);
    end;
    
    LHe := nil;
    LTarget := nil;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleKey]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleMethodCall(he: HELEMENT;
  var params: TMethodParams): Boolean;
var
  LHe: IDomElement;
  x: TBehaviorMethodIdentifier;
  EmptyParams: PIsEmptyParams;
  ValueParams: PValueParams;
  vValue: OleVariant;
begin
  Result := False;
  try
    if @FOnMethodCall <> nil then
    begin
      LHe := ElementFactory.Create(he);
      Result := FOnMethodCall(LHe, params.methodID, @params);
      LHe := nil;
      if Result then
        Exit;
    end;
    if FRttiObject = nil then
      Exit;
    x := params.methodID;
    case x of
      IS_EMPTY:
      begin
        if not FInitIsEmptyProp then
        begin
          FIsEmptyProp := FRttiObject.PropertyInfoByName['IsEmpty'];
          FInitIsEmptyProp := True;
        end;
        if FIsEmptyProp = nil then
          Exit;
        EmptyParams := PIsEmptyParams(@params);
        if FRttiObject.RttiGetEnumProp(FIsEmptyProp) = 'True' then
          EmptyParams.is_empty := 0
        else
          EmptyParams.is_empty := 1;
      end;
      GET_VALUE:
      begin
        if not FInitValueProp then
        begin
          FValueProp := FRttiObject.PropertyInfoByName['Value'];
          FInitValueProp := True;
        end;
        if FValueProp = nil then
          Exit;
        ValueParams := PValueParams(@params);
        vValue := FRttiObject.RttiGetPropValue(FValueProp);
        if V2S(vValue, ValueParams.val, ISciterLayout(FLayout).VM, PPropInfo(FValueProp.Header).PropType) <> 0 then
          Exit;
      end;
      SET_VALUE:
      begin
        if not FInitValueProp then
        begin
          FValueProp := FRttiObject.PropertyInfoByName['Value'];
          FInitValueProp := True;
        end;
        if FValueProp = nil then
          Exit;
        ValueParams := PValueParams(@params);
        S2V(ValueParams.val, vValue, ISciterLayout(FLayout).VM, PPropInfo(FValueProp.Header).PropType);
        FRttiObject.RttiSetPropValue(FValueProp, vValue);
      end;
    else
      Exit;
    end;
    Result := True;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleMethodCall]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleMouse(he: HELEMENT;
  var params: TMouseParams): Boolean;
var
  LOnMouse: TBehaviorMouseProc;
  LHe, LTarget: IDomElement;
begin
  Result := False;
  try
    LOnMouse := GetOnMouseByType(params.cmd);
    if @LOnMouse <> nil then
    begin
      LHe :=  ElementFactory.Create(he);
      LTarget := ElementFactory.Create(params.target);

      Result := LOnMouse(LHe, LTarget, params.cmd, params);
    end;
    
    if (not Result) and (@FOnMouse <> nil) then
    begin
      if LHe = nil then
        LHe := ElementFactory.Create(he);
      if LTarget = nil then
        LTarget := ElementFactory.Create(params.target);
      Result := FOnMouse(LHe, LTarget, params.cmd, params);
    end;
    LHe := nil;
    LTarget := nil;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleMouse:'+IntToStr(params.cmd)+']'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleScriptingCallCs(he: HELEMENT;
  var params: TScriptingMethodParams): Boolean;
begin
  Result := False;
end;

function TDefalutBehaviorEventHandler.HandleScriptingCallTs(he: HELEMENT; var params: TTiscriptMethodParams): Boolean;
var
  LHe: IDomElement;
  pMethodName: PWideChar;
begin
  Result := False;
  try
    Result := DoScriptCallTs(he, params);
    if Result then
      Exit;
    if @FOnScriptCallTs <> nil then
    begin
      NI.get_symbol_value(params.tag, pMethodName);
      LHe := ElementFactory.Create(he);
      Result := FOnScriptCallTs(LHe, params.vm, pMethodName, params.result);
      LHe := nil;
    end;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleSize]'+E.Message);
    end
  end;
end;

procedure TDefalutBehaviorEventHandler.HandleSize(he: HELEMENT);
var
  LHe: IDomElement;
begin
  try
    if @FOnSize <> nil then
    begin
      LHe := ElementFactory.Create(he);
      FOnSize(LHe);
      LHe := nil;
    end;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleSize]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleScroll(he: HELEMENT; params: TScorllParams): Boolean;
var
  LHe, LTarget: IDomElement;
begin
  Result := False;
  try
    if @FOnScroll <> nil then
    begin
      LHe := ElementFactory.Create(he);
      LTarget := ElementFactory.Create(params.target);
      
      Result := FOnScroll(LHe, LTarget, params.cmd, params);

      LHe := nil;
      LTarget := nil;
    end;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleScroll]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleGesture(he: HELEMENT; var params: TGestrueParams): Boolean;
var
  LHe, LTarget: IDomElement;
begin
  Result := False;
  try
    if @FOnGesture <> nil then
    begin
      LHe := ElementFactory.Create(he);
      LTarget := ElementFactory.Create(params.target);
      
      Result := FOnGesture(LHe, LTarget, params.cmd, params);

      LHe := nil;
      LTarget := nil;
    end;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleScroll]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.HandleTimer(he: HELEMENT; var params: TTimerParams): Boolean;
var
  LHe: IDomElement;
begin
  Result := False;
  try
    LHe := ElementFactory.Create(he);
    if params.timerId <> 0 then
    begin
      if @FOnTimerEx <> nil then
        Result := FOnTimerEx(LHe, params.timerId);
    end
    else
    begin
      if @FOnTimer <> nil then
        Result := FOnTimer(LHe);
    end;
    LHe := nil;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.HandleTimer]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.Subscription(he: HELEMENT;
  var event_groups: UINT): Boolean;
var
  LHe: IDomElement;
begin
  Result := False;
  try
    if @FOnSubscription = nil then
    begin
      event_groups := HANDLE_ALL;
      Result := True;
    end
    else
    begin
      LHe := ElementFactory.Create(he);
      Result := FOnSubscription(LHe, event_groups);
      LHe := nil;
    end;
  except
    on E: Exception do
    begin
      TraceException('['+FBehaviorName+'.Subscription]'+E.Message);
    end
  end;
end;

function TDefalutBehaviorEventHandler.GetDataArrived: TBehaviorDataArrivedProc;
begin
  Result := FOnDataArrived;
end;

function TDefalutBehaviorEventHandler.GetOnDraw: TBehaviorDrawProc;
begin
  Result := FOnDraw;
end;

function TDefalutBehaviorEventHandler.GetOnEvent: TBehaviorEventProc;
begin
  Result := FOnEvent;
end;

function TDefalutBehaviorEventHandler.GetOnMethodCall: TBehaviorMethodCallProc;
begin
  Result := FOnMethodCall;
end;

function TDefalutBehaviorEventHandler.GetOnScriptCallCs: TBehaviorScriptCallCsProc;
begin
  Result := FOnScriptCallCs;
end;

function TDefalutBehaviorEventHandler.GetOnScriptCallTs: TBehaviorScriptCallTsProc;
begin
  Result := FOnScriptCallTs;
end;

function TDefalutBehaviorEventHandler.GetOnScroll: TBehaviorScrollProc;
begin
  Result := FOnScroll;
end;

function TDefalutBehaviorEventHandler.GetOnSize: TBehaviorSizeProc;
begin
  Result := FOnSize;
end;

function TDefalutBehaviorEventHandler.GetOnTimer: TBehaviorTimerProc;
begin
  Result := FOnTimer;
end;

function TDefalutBehaviorEventHandler.GetOnTimerEx: TBehaviorTimerExProc;
begin
  Result := FOnTimerEx;
end;

procedure TDefalutBehaviorEventHandler.SetDataArrived(
  const Value: TBehaviorDataArrivedProc);
begin
  FOnDataArrived := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnDraw(const Value: TBehaviorDrawProc);
begin
  FOnDraw := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnEvent(
  const Value: TBehaviorEventProc);
begin
  FOnEvent := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnMethodCall(
  const Value: TBehaviorMethodCallProc);
begin
  FOnMethodCall := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnScriptCallCs(
  const Value: TBehaviorScriptCallCsProc);
begin
  FOnScriptCallCs := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnScriptCallTs(
  const Value: TBehaviorScriptCallTsProc);
begin
  FOnScriptCallTs := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnScroll(
  const Value: TBehaviorScrollProc);
begin
  FOnScroll := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnSize(const Value: TBehaviorSizeProc);
begin
  FOnSize := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnTimer(
  const Value: TBehaviorTimerProc);
begin
  FOnTimer := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnTimerEx(
  const Value: TBehaviorTimerExProc);
begin
  FOnTimerEx := Value;
end;

function TDefalutBehaviorEventHandler.GetOnAttached: TBehaviorAttachedProc;
begin
  Result := FOnAttached;
end;

function TDefalutBehaviorEventHandler.GetOnDetached: TBehaviorDetachedProc;
begin
  Result := FOnDetached;
end;

function TDefalutBehaviorEventHandler.GetOnSubscription: TBehaviorSubscriptionProc;
begin
  Result := FOnSubscription;
end;

procedure TDefalutBehaviorEventHandler.SetOnAttached(
  const Value: TBehaviorAttachedProc);
begin
  FOnAttached := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnDetached(
  const Value: TBehaviorDetachedProc);
begin
  FOnDetached := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnSubscription(
  const Value: TBehaviorSubscriptionProc);
begin
  FOnSubscription := Value;
end;

function TDefalutBehaviorEventHandler.GetController: Pointer;
begin
  Result := FController
end;

procedure TDefalutBehaviorEventHandler.SetController(
  const Value: Pointer);
begin
  FController := Value
end;

function TDefalutBehaviorEventHandler._AddRef: Integer;
begin
  if FController = nil then
    Result := InterlockedIncrement(FRefCount)
  else
    Result := FController._AddRef;
//  if FBehaviorName = 'TWinCmdBehavior' then
//    Log('[TDefalutBehaviorEventHandler]'+'after ' + FBehaviorName + '._AddRef:' + IntToStr(Result));
end;

function TDefalutBehaviorEventHandler._Release: Integer;
begin
//  if FBehaviorName = 'TWinCmdBehavior' then
//    Log('[TDefalutBehaviorEventHandler]'+'before ' + FBehaviorName + '._Release:' + IntToStr(FRefCount));
  if FController = nil then
  begin
    Result := InterlockedDecrement(FRefCount);
    if Result = 0 then
      Destroy;
  end
  else
  if not FController.Destroying then
    Result := FController._Release
  else
    Result := FRefCount;
end;

function TDefalutBehaviorEventHandler.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if FController = nil then
    Result := inherited QueryInterface(IID, Obj)
  else
    Result := FController.QueryInterface(IID, Obj);
end;

{ TBehaviorFactorys }

function TBehaviorFactorys.Reg(AItem: IBehaviorFactory): Integer;
var
  i: Integer;
begin
  i := IndexOfName(AItem.Name);
  if i < 0 then
  begin
    Result := FList.Add(AItem);
    FNameHash.Add(AnsiUpperCase(AItem.Name), Result);
  end
  else
  begin
    SetItem(i, AItem);
    Result := i;
  end;
end;

procedure TBehaviorFactorys.Clear;
begin
  FList.Clear;
  FNameHashValid := False;
end;

constructor TBehaviorFactorys.Create;
begin
  FList := TInterfaceList.Create;
  FNameHash := TStringHash.Create(1024);
end;

procedure TBehaviorFactorys.Delete(const Index: Integer);
begin
  FList.Delete(Index);
  FNameHashValid := False;
end;

destructor TBehaviorFactorys.Destroy;
begin
  try
    if FNameHash <> nil then
      FreeAndNil(FNameHash);
    if FList <> nil then
    begin
      FList.Clear;
      FList := nil;
    end;
  except
    on E: Exception do
      TraceException('[TBehaviorFactorys.Destroy]'+E.Message);
  end;
  inherited;
end;

function TBehaviorFactorys.First: IBehaviorFactory;
begin
  Result := FList.First as IBehaviorFactory;
end;

function TBehaviorFactorys.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TBehaviorFactorys.GetItem(const Index: Integer): IBehaviorFactory;
begin
  Result := FList.Items[Index] as IBehaviorFactory;
end;

function TBehaviorFactorys.GetItemByName(
  const AName: SciterString): IBehaviorFactory;
var
  i: Integer;
begin
  i := IndexOfName(AName);
  if i >= 0 then
    Result := GetItem(i)
  else
    Result := nil;
end;

function TBehaviorFactorys.IndexOf(const AItem: IBehaviorFactory): Integer;
begin
  Result := FList.IndexOf(AItem)
end;

function TBehaviorFactorys.IndexOfName(const AName: SciterString): Integer;
begin
  UpdateNameHash;
  Result := FNameHash.ValueOf(AnsiUpperCase(AName));
end;

procedure TBehaviorFactorys.Insert(const Index: Integer;
  const AItem: IBehaviorFactory);
begin
  FList.Insert(Index, AItem);
  FNameHashValid := False;
end;

function TBehaviorFactorys.Last: IBehaviorFactory;
begin
  Result := FList.Last as IBehaviorFactory;
end;

procedure TBehaviorFactorys.SetItem(const Index: Integer;
  const Value: IBehaviorFactory);
begin
  FList[Index] := Value;
  FNameHashValid := False;
end;

procedure TBehaviorFactorys.SetItemByName(const AName: SciterString;
  const Value: IBehaviorFactory);
var
  i: Integer;
begin
  i := IndexOfName(AName);
  if i >= 0 then
    SetItem(i, Value);
end;

procedure TBehaviorFactorys.UnReg(AItem: IBehaviorFactory);
var
  i: Integer;
begin
  if AItem = nil then Exit;
  for i := GetCount - 1 downto 0 do
  begin
    if GetItem(i).Implementator = AItem.Implementator then
    begin
      Delete(i);
      break;
    end;
  end;
end;

procedure TBehaviorFactorys.UnReg(const AName: SciterString);
var
  i: Integer;
begin
  if AName = '' then Exit;
  i := IndexOfName(AName);
  if i >= 0 then
    Delete(i);
end;

function TDefalutBehaviorEventHandler.GetOnDocumentComplete: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DOCUMENT_COMPLETE);
end;

procedure TDefalutBehaviorEventHandler.SetOnDocumentComplete(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DOCUMENT_COMPLETE, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnButtonClick(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(BUTTON_CLICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnButtonPress: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(BUTTON_PRESS);
end;

procedure TDefalutBehaviorEventHandler.SetOnButtonPress(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(BUTTON_PRESS, Value);
end;

function TDefalutBehaviorEventHandler.GetOnButtonStateChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(BUTTON_STATE_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnButtonStateChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(BUTTON_STATE_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnEditValueChanging: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(EDIT_VALUE_CHANGING);
end;

procedure TDefalutBehaviorEventHandler.SetOnEditValueChanging(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(EDIT_VALUE_CHANGING, Value);
end;

function TDefalutBehaviorEventHandler.GetOnEditValueChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(EDIT_VALUE_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnEditValueChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(EDIT_VALUE_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnContextMenuRequest: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(CONTEXT_MENU_REQUEST);
end;

procedure TDefalutBehaviorEventHandler.SetOnContextMenuRequest(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(CONTEXT_MENU_REQUEST, Value);
end;

function TDefalutBehaviorEventHandler.GetOnHyperlinkClick: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(HYPERLINK_CLICK);
end;

procedure TDefalutBehaviorEventHandler.SetOnHyperlinkClick(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(HYPERLINK_CLICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnEventByCmd(
  const Cmd: UINT): TBehaviorEventProc;
var
  iPhaseMask: UINT;
  iType: UINT;
begin
  iPhaseMask := Cmd and (BUBBLING or SINKING or HANDLED);
  iType := Cmd and not iPhaseMask;
  
  if (iType < FEventProcArrayLength) then
    Result := FEventProcArray[iType]
  else
    Result := nil;
end;

procedure TDefalutBehaviorEventHandler.SetOnEventByCmd(const Cmd: UINT;
  const Value: TBehaviorEventProc);
var
  iPhaseMask: UINT;
  iType: UINT;
begin
  iPhaseMask := Cmd and (BUBBLING or SINKING or HANDLED);
  iType := Cmd and not iPhaseMask;

  if (iType < FEventProcArrayLength) then
    FEventProcArray[iType] := Value;
end;

function TDefalutBehaviorEventHandler.GetOnButtonClick: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(BUTTON_CLICK);
end;

function TDefalutBehaviorEventHandler.GetOnSelectSelectionChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(SELECT_SELECTION_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnSelectSelectionChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(SELECT_SELECTION_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnSelectStateChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(SELECT_STATE_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnSelectStateChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(SELECT_STATE_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnPopupRequest: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(POPUP_REQUEST);
end;

procedure TDefalutBehaviorEventHandler.SetOnPopupRequest(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(POPUP_REQUEST, Value);
end;

function TDefalutBehaviorEventHandler.GetOnPopupReady: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(POPUP_READY);
end;

procedure TDefalutBehaviorEventHandler.SetOnPopupReady(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(POPUP_READY, Value);
end;

function TDefalutBehaviorEventHandler.GetOnPopupDismissed: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(POPUP_DISMISSED);
end;

procedure TDefalutBehaviorEventHandler.SetOnPopupDismissed(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(POPUP_DISMISSED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMenuItemActive: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(MENU_ITEM_ACTIVE);
end;

procedure TDefalutBehaviorEventHandler.SetOnMenuItemActive(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(MENU_ITEM_ACTIVE, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMenuItemClick: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(MENU_ITEM_CLICK);
end;

procedure TDefalutBehaviorEventHandler.SetOnMenuItemClick(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(MENU_ITEM_CLICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnVisiualStatusChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(VISIUAL_STATUS_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnVisiualStatusChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(VISIUAL_STATUS_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDisabledStatusChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DISABLED_STATUS_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnDisabledStatusChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DISABLED_STATUS_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnPopupDismissing: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(POPUP_DISMISSING);
end;

procedure TDefalutBehaviorEventHandler.SetOnPopupDismissing(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(POPUP_DISMISSING, Value);
end;

function TDefalutBehaviorEventHandler.GetOnContentChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(CONTENT_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnContentChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(CONTENT_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnElementCollapsed: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(ELEMENT_COLLAPSED);
end;

procedure TDefalutBehaviorEventHandler.SetOnElementCollapsed(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(ELEMENT_COLLAPSED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnElementExpanded: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(ELEMENT_EXPANDED);
end;

procedure TDefalutBehaviorEventHandler.SetOnElementExpanded(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(ELEMENT_EXPANDED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnActivateChild: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(ACTIVATE_CHILD);
end;

procedure TDefalutBehaviorEventHandler.SetOnActivateChild(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(ACTIVATE_CHILD, Value);
end;

function TDefalutBehaviorEventHandler.GetOnUIStateChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(UI_STATE_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnUIStateChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(UI_STATE_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnFormSubmit: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(FORM_SUBMIT);
end;

procedure TDefalutBehaviorEventHandler.SetOnFormSubmit(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(FORM_SUBMIT, Value);
end;

function TDefalutBehaviorEventHandler.GetOnFormReset: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(FORM_RESET);
end;

procedure TDefalutBehaviorEventHandler.SetOnFormReset(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(FORM_RESET, Value);
end;

function TDefalutBehaviorEventHandler.GetOnHistoryPush: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(HISTORY_PUSH);
end;

procedure TDefalutBehaviorEventHandler.SetOnHistoryPush(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(HISTORY_PUSH, Value);
end;

function TDefalutBehaviorEventHandler.GetOnHistoryDrop: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(HISTORY_DROP);
end;

procedure TDefalutBehaviorEventHandler.SetOnHistoryDrop(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(HISTORY_DROP, Value);
end;

function TDefalutBehaviorEventHandler.GetOnHistoryPrior: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(HISTORY_PRIOR);
end;

procedure TDefalutBehaviorEventHandler.SetOnHistoryPrior(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(HISTORY_PRIOR, Value);
end;

function TDefalutBehaviorEventHandler.GetOnHistoryNext: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(HISTORY_NEXT);
end;

procedure TDefalutBehaviorEventHandler.SetOnHistoryNext(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(HISTORY_NEXT, Value);
end;

function TDefalutBehaviorEventHandler.GetOnHistoryStateChanged: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(HISTORY_STATE_CHANGED);
end;

procedure TDefalutBehaviorEventHandler.SetOnHistoryStateChanged(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(HISTORY_STATE_CHANGED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnClosePopup: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(CLOSE_POPUP);
end;

procedure TDefalutBehaviorEventHandler.SetOnClosePopup(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(CLOSE_POPUP, Value);
end;

function TDefalutBehaviorEventHandler.GetOnRequestTooltip: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(REQUEST_TOOLTIP);
end;

procedure TDefalutBehaviorEventHandler.SetOnRequestTooltip(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(REQUEST_TOOLTIP, Value);
end;

function TDefalutBehaviorEventHandler.GetOnAnimation: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(ANIMATION);
end;

procedure TDefalutBehaviorEventHandler.SetOnAnimation(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(ANIMATION, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDocumentCreated: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DOCUMENT_CREATED);
end;

procedure TDefalutBehaviorEventHandler.SetOnDocumentCreated(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DOCUMENT_CREATED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnVideoInitialized: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(VIDEO_INITIALIZED);
end;

procedure TDefalutBehaviorEventHandler.SetOnVideoInitialized(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(VIDEO_INITIALIZED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnVideoStarted: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(VIDEO_STARTED);
end;

procedure TDefalutBehaviorEventHandler.SetOnVideoStarted(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(VIDEO_STARTED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnVideoStopped: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(VIDEO_STOPPED);
end;

procedure TDefalutBehaviorEventHandler.SetOnVideoStopped(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(VIDEO_STOPPED, Value);
end;

function TDefalutBehaviorEventHandler.GetOnVideoBindRQ: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(VIDEO_BIND_RQ);
end;

procedure TDefalutBehaviorEventHandler.SetOnVideoBindRQ(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(VIDEO_BIND_RQ, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseByType(
  const AType: UINT): TBehaviorMouseProc;
var
  iType, iPhaseMask: UINT;
begin
  iPhaseMask := AType and (BUBBLING or SINKING or HANDLED or DRAGGING);
  iType := AType and not iPhaseMask;
  if iType >= FMouseProcArrayLength then
    Result := nil
  else
    Result := FMouseProcArray[iType]
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseByType(
  const AType: UINT; const Value: TBehaviorMouseProc);
var
  iType, iPhaseMask: UINT;
begin
  iPhaseMask := AType and (BUBBLING or SINKING or HANDLED);
  iType := AType and not iPhaseMask;
  
  if iType < FMouseProcArrayLength then
    FMouseProcArray[iType] := Value;
end;

function TDefalutBehaviorEventHandler.GetOnMouseEnter: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_ENTER);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseEnter(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_ENTER, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseLeave: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_LEAVE);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseLeave(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_LEAVE, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseMove: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_MOVE);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseMove(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_MOVE, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseUp: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_UP);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseUp(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_UP, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseDown: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_DOWN);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseDown(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_DOWN, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseDClick: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_DCLICK);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseDClick(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_DCLICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseWheel: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_WHEEL);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseWheel(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_WHEEL, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseTick: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_TICK);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseTick(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_TICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseIdle: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_IDLE);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseIdle(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_IDLE, Value);
end;

function TDefalutBehaviorEventHandler.GetOnMouseClick: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(MOUSE_CLICK);
end;

procedure TDefalutBehaviorEventHandler.SetOnMouseClick(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(MOUSE_CLICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDrop: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(DROP);
end;

procedure TDefalutBehaviorEventHandler.SetOnDrop(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(DROP, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDragEnter: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(DRAG_ENTER);
end;

procedure TDefalutBehaviorEventHandler.SetOnDragEnter(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(DRAG_ENTER, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDragLeave: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(DRAG_LEAVE);
end;

procedure TDefalutBehaviorEventHandler.SetOnDragLeave(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(DRAG_LEAVE, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDragRequest: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(DRAG_REQUEST);
end;

procedure TDefalutBehaviorEventHandler.SetOnDragRequest(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(DRAG_REQUEST, Value);
end;

function TDefalutBehaviorEventHandler.GetOnDragging: TBehaviorMouseProc;
begin
  Result := GetOnMouseByType(DRAGGING);
end;

procedure TDefalutBehaviorEventHandler.SetOnDragging(
  const Value: TBehaviorMouseProc);
begin
  SetOnMouseByType(DRAGGING, Value);
end;

function TDefalutBehaviorEventHandler.GetOnKeyByType(
  const AType: UINT): TBehaviorKeyProc;
var
  iPhaseMask: UINT;
  iType: UINT;
begin
  iPhaseMask := AType and (BUBBLING or SINKING or HANDLED);
  iType := AType and not iPhaseMask;
  if (iType >= FKeyProcArrayLength) then
    Result := nil
  else
    Result := FKeyProcArray[iType];
end;

procedure TDefalutBehaviorEventHandler.SetOnKeyByType(
  const AType: UINT; const Value: TBehaviorKeyProc);
var
  iType, iPhaseMask: UINT;
begin
  iPhaseMask := AType and (BUBBLING or SINKING or HANDLED);
  iType := AType and not iPhaseMask;
  if iType < FKeyProcArrayLength then
    FKeyProcArray[iType] := Value;
end;

function TDefalutBehaviorEventHandler.GetOnKeyDown: TBehaviorKeyProc;
begin
  Result := GetOnKeyByType(KEY_DOWN);
end;

procedure TDefalutBehaviorEventHandler.SetOnKeyDown(
  const Value: TBehaviorKeyProc);
begin
  SetOnKeyByType(KEY_DOWN, Value);
end;

function TDefalutBehaviorEventHandler.GetOnKeyChar: TBehaviorKeyProc;
begin
  Result := GetOnKeyByType(KEY_UP);
end;

function TDefalutBehaviorEventHandler.GetOnKeyUp: TBehaviorKeyProc;
begin
  Result := GetOnKeyByType(KEY_CHAR);
end;

procedure TDefalutBehaviorEventHandler.SetOnKeyChar(
  const Value: TBehaviorKeyProc);
begin
  SetOnKeyByType(KEY_UP, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnKeyUp(const Value: TBehaviorKeyProc);
begin
  SetOnKeyByType(KEY_CHAR, Value);
end;

constructor TDefalutBehaviorEventHandler.Create(const ABehaviorName: SciterString; 
  const Controller: Pointer; ARttiObject: IDispatchRttiObject);
begin
  FBehaviorName := ABehaviorName;
  if Controller <> nil then
    _AddRef;
  FRttiObject := ARttiObject;
  FController := Controller;
  Create(ABehaviorName);
end;

function TDefalutBehaviorEventHandler.IsBubbling(event_type: UINT): Boolean;
begin
  Result := event_type and (HANDLED or SINKING) = 0;
end;

function TDefalutBehaviorEventHandler.IsHandled(event_type: UINT): Boolean;
begin
  Result := event_type and HANDLED = HANDLED;
end;

function TDefalutBehaviorEventHandler.IsSinking(event_type: UINT): Boolean;
begin
  Result := event_type and SINKING = SINKING;
end;

destructor TDefalutBehaviorEventHandler.Destroy;
var
  iIndex: Integer;
begin
//  if FBehaviorName = 'TWinCmdBehavior' then
//    Log('[TDefalutBehaviorEventHandler]'+FBehaviorName+'.Destroy');
  if FHasAddAfterWndProc then
    RemoveAfterWndProc;
  if FHasAddBeforeWndProc then
    RemoveBeforeWndProc;
  if _ReportBehaviorCount then
  begin
    InterlockedDecrement(varBehaviorCount);
    iIndex := varBehaviorNames.IndexOf(FBehaviorName);
    if iIndex <> -1 then
      varBehaviorNames.Delete(iIndex);
  end;
  inherited;
end;

function TDefalutBehaviorEventHandler.GetLayout: Pointer;
begin
  Result := FLayout;
end;

procedure TDefalutBehaviorEventHandler.SetLayout(
  const Value: Pointer);
begin
  FLayout := Value;
end;

function TBehaviorFactorys.ToString: SciterString;
var
  i, iIndex: Integer;
  sResult: TStrings;
begin
  sResult := TStringList.Create;
  try
    sResult.Add('count: ' + IntToStr(Count));
    for i := 0 to Count - 1 do
    begin
      iIndex := sResult.IndexOf(GetItem(i).Name);
      if iIndex < 0 then
        sResult.Values[GetItem(i).Name] := '0'
      else
        sResult.ValueFromIndex[iIndex] := IntToStr(StrToIntDef(sResult.ValueFromIndex[iIndex], 0) + 1);
    end;
    Result := sResult.Text;
  finally
    sResult.Free;
  end;
end;

function TDefalutBehaviorEventHandler.Implementor: Pointer;
begin
  Result := Self;
end;

function TDefalutBehaviorEventHandler.GetOnFocusGot: TBehaviorFocusProc;
begin
  Result := FOnFocusGot;
end;

procedure TDefalutBehaviorEventHandler.SetOnFocusGot(
  const Value: TBehaviorFocusProc);
begin
  FOnFocusGot := Value;
end;

function TDefalutBehaviorEventHandler.GetOnFocusLost: TBehaviorFocusProc;
begin
  Result := FOnFocusLost;
end;

procedure TDefalutBehaviorEventHandler.SetOnFocusLost(
  const Value: TBehaviorFocusProc);
begin
  FOnFocusLost := Value;
end;

function TDefalutBehaviorEventHandler.DoScriptCallTs(he: HELEMENT;
  var params: TTiscriptMethodParams): Boolean;
var
  pArgs: array of Variant;
  cArgs: Integer;
  i, iParamIndex: Integer;
  ov, SR: OleVariant;
  LMethodInfo: PDispatchMethodInfo;
  LParams: TParamInfoArray;
  pMethodName: PWideChar;
  sMethodName: SciterString;
  arg, tThis: tiscript_value;
  LReturnInfo: PReturnInfo;
begin                           
  Result := False;
  try
    if FRttiObject = nil then
      Exit;
    NI.get_symbol_value(params.tag, pMethodName);
    sMethodName := SciterString(pMethodName);
    LMethodInfo:= FRttiObject.MethodInfoByName[sMethodName];
    if LMethodInfo = nil then Exit;
    params.result := ni.undefined_value;
    Result := True;

    LParams := GetParams(LMethodInfo.Header);
    iParamIndex := 0;
    if (Length(LParams) > 0) and (LParams[0].Name = 'Self') then
      iParamIndex := iParamIndex + 1;

    cArgs := NI.get_arg_count(params.vm);
    if cArgs > MaxParams then
      raise ESciterException.Create('Too many arguments.');
    tThis := NI.get_arg_n(params.vm, 0);
    // Invoke params
    SetLength(pArgs, cArgs - 2);
    for i := 2 to cArgs - 1 do
    begin
      arg := NI.get_arg_n(params.vm, i);
      if T2V(params.vm, arg, ov, @tThis, PPTypeInfo(LParams[iParamIndex].ParamType)) = 0 then
        pArgs[i - 2] := ov
      else
        pArgs[i - 2] := arg;
      iParamIndex := iParamIndex + 1;
    end;
    SR := FRttiObject.RttiObjectInvoke(LMethodInfo, Slice(ParamIndexes, Length(pArgs)), pArgs);
    LReturnInfo := GetReturnInfo(LMethodInfo.Header);
    if LReturnInfo <> nil then
      Assert(V2T(params.vm, SR, params.Result, PPTypeInfo(LReturnInfo.ReturnType)) = 0)
    else
      Assert(V2T(params.vm, SR, params.Result, nil) = 0);
  except
    on e: Exception do
      TraceException('[TDefalutBehaviorEventHandler.DoScriptCallTs]'+e.Message);
  end;
end;

function TDefalutBehaviorEventHandler.GetRttiObject: IDispatchRttiObject;
begin
  Result := FRttiObject;
end;

procedure TDefalutBehaviorEventHandler.SetRttiObject(const Value: IDispatchRttiObject);
begin
  FRttiObject := Value;
end;

procedure TBehaviorFactorys.UpdateNameHash;
var
  I: Integer;
  Key: string;
begin
  if FNameHashValid then Exit;
  FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := AnsiUpperCase(GetItem(I).Name);
    FNameHash.Add(Key, I);
  end;
  FNameHashValid := True;
end;

procedure TBehaviorFactorys.Invalidate;
begin
  FNameHashValid := False;
end;

function TDefalutBehaviorEventHandler.GetData1: Pointer;
begin
  Result := FData1;
end;

function TDefalutBehaviorEventHandler.GetData2: Pointer;
begin
  Result := FData2;
end;

function TDefalutBehaviorEventHandler.GetData3: IInterface;
begin
  Result := FData3;
end;

procedure TDefalutBehaviorEventHandler.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TDefalutBehaviorEventHandler.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

procedure TDefalutBehaviorEventHandler.SetData3(const Value: IInterface);
begin
  FData3 := Value;
end;

function TDefalutBehaviorEventHandler.AddAfterWndProc: Integer;
begin
  if FHasAddAfterWndProc then
    Result := -1
  else
  begin
    Result := ISciterLayout(FLayout).AddAfterWndProc(DoAfterWndProc);
    FHasAddAfterWndProc := True;
  end;
end;

function TDefalutBehaviorEventHandler.AddBeforeWndProc: Integer;
begin
  if FHasAddBeforeWndProc then
    Result := -1
  else
  begin
    Result := ISciterLayout(FLayout).AddBeforeWndProc(DoBeforeWndProc);
    FHasAddBeforeWndProc := True;
  end;
end;

function TDefalutBehaviorEventHandler.RemoveAfterWndProc: Integer;
begin
  if FHasAddAfterWndProc then
  begin
    Result := ISciterLayout(FLayout).RemoveAfterWndProc(DoAfterWndProc);
    FHasAddAfterWndProc := False;
  end
  else
   Result := -1;  
end;

function TDefalutBehaviorEventHandler.RemoveBeforeWndProc: Integer;
begin
  if FHasAddBeforeWndProc then
  begin
    Result := ISciterLayout(FLayout).RemoveBeforeWndProc(DoBeforeWndProc);
    FHasAddBeforeWndProc := False;
  end
  else
   Result := -1;  
end;

function TDefalutBehaviorEventHandler.GetAfterWndProc: TLayoutAfterWndProc;
begin
  Result := FAfterWndProc;
end;

function TDefalutBehaviorEventHandler.GetBeforeWndProc: TLayoutBeforeWndProc;
begin
  Result := FBeforeWndProc;
end;

procedure TDefalutBehaviorEventHandler.SetAfterWndProc(
  const Value: TLayoutAfterWndProc);
begin
  FAfterWndProc := Value;
end;

procedure TDefalutBehaviorEventHandler.SetBeforeWndProc(
  const Value: TLayoutBeforeWndProc);
begin
  FBeforeWndProc := Value;
end;

procedure TDefalutBehaviorEventHandler.DoAfterWndProc(
  msg: UINT; wParam: WPARAM; lParam: LPARAM; var Result: LRESULT);
begin
  if @FAfterWndProc <> nil then
    FAfterWndProc(msg, wParam, lParam, Result);
end;

function TDefalutBehaviorEventHandler.DoBeforeWndProc(
  msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT;
begin
  if @FBeforeWndProc <> nil then
    Result := FBeforeWndProc(msg, wParam, lParam, pbHandled)
  else
    Result := 0;
end;

function TDefalutBehaviorEventHandler.GetOnDocumentClose: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DOCUMENT_CLOSE);
end;

function TDefalutBehaviorEventHandler.GetOnDocumentCloseRequest: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DOCUMENT_CLOSE_REQUEST);
end;

function TDefalutBehaviorEventHandler.GetOnDocumentReady: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DOCUMENT_READY);
end;

procedure TDefalutBehaviorEventHandler.SetOnDocumentClose(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DOCUMENT_CLOSE, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnDocumentCloseRequest(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DOCUMENT_CLOSE_REQUEST, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnDocumentReady(const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DOCUMENT_READY, Value);
end;

function TDefalutBehaviorEventHandler.GetOnPaginationEnds: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(PAGINATION_ENDS);
end;

function TDefalutBehaviorEventHandler.GetOnPaginationPage: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(PAGINATION_PAGE);
end;

function TDefalutBehaviorEventHandler.GetOnPaginationStarts: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(PAGINATION_STARTS);
end;

procedure TDefalutBehaviorEventHandler.SetOnPaginationEnds(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(PAGINATION_ENDS, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnPaginationPage(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(PAGINATION_PAGE, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnPaginationStarts(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(PAGINATION_STARTS, Value);
end;

function TDefalutBehaviorEventHandler.GetOnChange: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(CHANGE);
end;

function TDefalutBehaviorEventHandler.GetOnClick: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(CLICK);
end;

procedure TDefalutBehaviorEventHandler.SetOnChange(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(CHANGE, Value);
end;

procedure TDefalutBehaviorEventHandler.SetOnClick(
  const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(CLICK, Value);
end;

function TDefalutBehaviorEventHandler.GetOnFocusIn: TBehaviorFocusProc;
begin
  Result := FOnFocusIn;
end;

function TDefalutBehaviorEventHandler.GetOnFocusOut: TBehaviorFocusProc;
begin
  Result := FOnFocusOut;
end;

procedure TDefalutBehaviorEventHandler.SetOnFocusIn(
  const Value: TBehaviorFocusProc);
begin
  FOnFocusIn := Value;
end;

procedure TDefalutBehaviorEventHandler.SetOnFocusOut(
  const Value: TBehaviorFocusProc);
begin
  FOnFocusOut := Value;
end;

function TDefalutBehaviorEventHandler.IsType(event, event_type: UINT): Boolean;
var
  iPhaseMask: UINT;
  iType: UINT;
begin
  iPhaseMask := event and (BUBBLING or SINKING or HANDLED);
  iType := event and not iPhaseMask;
  Result := iType = event_type;
end;

function TDefalutBehaviorEventHandler.GetOnMouse: TBehaviorMouseProc;
begin
  Result := FOnMouse;
end;

procedure TDefalutBehaviorEventHandler.SetOnMouse(
  const Value: TBehaviorMouseProc);
begin
  FOnMouse := Value;
end;

function TDefalutBehaviorEventHandler.GetOnKey: TBehaviorKeyProc;
begin
  Result := FOnKey;
end;

procedure TDefalutBehaviorEventHandler.SetOnKey(
  const Value: TBehaviorKeyProc);
begin
  FOnKey := Value;
end;

function TDefalutBehaviorEventHandler.GetOnFocus: TBehaviorFocusProc;
begin
  Result := FOnFocus;
end;

procedure TDefalutBehaviorEventHandler.SetOnFocus(
  const Value: TBehaviorFocusProc);
begin
  FOnFocus := Value;
end;

function TDefalutBehaviorEventHandler.GetOnGesture: TBehaviorGestureProc;
begin
  Result := FOnGesture;
end;

procedure TDefalutBehaviorEventHandler.SetOnGesture(const Value: TBehaviorGestureProc);
begin
  FOnGesture := Value;
end;

function TDefalutBehaviorEventHandler.GetOnDocumentParsed: TBehaviorEventProc;
begin
  Result := GetOnEventByCmd(DOCUMENT_PARSED);
end;

procedure TDefalutBehaviorEventHandler.SetOnDocumentParsed(const Value: TBehaviorEventProc);
begin
  SetOnEventByCmd(DOCUMENT_PARSED, Value);
end;

initialization
  varBehaviorNames := TStringList.Create();

finalization
  CheckBehaviorLeak;
  if varBehaviorNames <> nil then
    FreeAndNil(varBehaviorNames);

end.

