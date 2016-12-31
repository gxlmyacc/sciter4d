{*******************************************************************************
 标题:     SciterIntf.pas
 描述:     Sciter访问单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterIntf;

interface

{$I Sciter.inc}

uses
  Windows, SciterTypes, TiscriptTypes;

const
  DOMAIN_Sciter4D    = 'Sciter4D';
  DOMAIN_App         = 'app';

  SCHEMA_Res         = 'res:';
  SCHEMA_ResLen      = Length(SCHEMA_Res);
  SCHEMA_Master      = 'master:';
  SCHEMA_MasterLen   = Length(SCHEMA_Master);
  SCHEMA_Sciter4D    = 'sciter4d:';
  SCHEMA_Sciter4DLen = Length(SCHEMA_Sciter4D);
  SCHEMA_App         = 'app:';
  SCHEMA_AppDLen     = Length(SCHEMA_App);
  SCHEMA_Plugin      = 'plugin:';
  SCHEMA_PluginLen   = Length(SCHEMA_Plugin);
  SCHEMA_File        = 'file://';
  SCHEMA_FileLen     = Length(SCHEMA_File);
  SCHEMA_Sciter      = 'sciter:';
  SCHEMA_SciterLen   = Length(SCHEMA_Sciter);

  EXT_PLUGIN         = '.plugin';
  EXT_PLUGINLen      = Length(EXT_PLUGIN);
  EXT_PLUGIN_Plat    = '.dll';
  
  URL_MsgboxHTML     = 'sciter:msgbox.htm';
  URL_MsgboxCSS      = 'sciter:msgbox.css';
  URL_DebugPeer      = 'sciter:debug-peer.tis';

const
  PROC_SciterLoadPlugin      = 'SciterLoadPlugin';
  PROC_SciterCanUnloadPlugin = 'SciterCanUnloadPlugin';
  PROC_SciterUnloadPlugin    = 'SciterUnloadPlugin';
  PROC_SciterSendMessage     = 'SciterSendMessage';

type
  IDomValue = interface;
  IDomElement = interface;
  IBehaviorEventHandler = interface;
  IDefalutBehaviorEventHandler = interface;
  ISciterLayout = interface;


  (** \struct notification_handler
   *  \brief standard implementation of SCITER_CALLBACK_NOTIFY handler.
   *  Supposed to be used as a C++ mixin, see: <a href="http://en.wikipedia.org/wiki/Curiously_Recurring_Template_Pattern">CRTP</a>
   **)
  ISciterBase = interface
  ['{E52156B5-78F9-439A-8720-42E6016382EF}']
    function GetWindowName: SciterString;
    function GetHwnd: HWINDOW;
    function GetResourceInstance: HMODULE;
  end;

  TDynDomValueArray = array of IDomValue;
  IDomValue = interface
  ['{7B3A4F88-B10E-41A9-81E3-AB7CB2E3C998}']
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
      
    function IsNull(): Boolean;

    function Equal(const rs: IDomValue): Boolean;

    function AsString(how: TDomValueStringCvtType): SciterString; overload;
    function AsString(const defv: SciterString = ''): SciterString; overload;
    function AsPString(const defv: PWideChar = nil): PWideChar;
    function AsInteger(defv: Integer = 0): Integer;
    function AsFloat(defv: Double = 0.0): Double;
    function AsBool(defv: BOOL = False): BOOL;
    function AsCurrency(defv: Currency = 0.0): Currency;
    function AsDate(defv: FILETIME): FILETIME;
    function AsDateTime(defv: TDateTime): TDateTime;

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

    // if it is an array or map returns number of elements there, otherwise - 0
    // if it is a function - returns number of arguments
    property Length: Cardinal read GetLength;
    
    property Key[const n: UINT]: IDomValue read GetKey;
    // if it is an array - sets nth element expanding the array if needed
    // if it is a map - sets nth value of the map;
    // if it is a function - sets nth argument of the function;
    // otherwise it converts this to array and adds v as first element.
    property Item[const n: UINT]: IDomValue read GetItem write SetItem; default;
    property ItemByKey[const key: IDomValue]: IDomValue read GetItemByKey write SetItemByKey;
    property ItemByName[const AName: SciterString]: IDomValue read GetItemByName write SetItemByName;

    {$IFDEF HAS_TISCRIPT}
    // T_OBJECT and T_DOM_OBJECT only, get value of object's data slot
    // T_OBJECT only, set value of object's data slot
    property ObjectData: Pointer read GetObjectData write SetObjectData;
    {$ENDIF}
  end;

  IDomValueList = interface
  ['{6F216C2B-32A4-4EE8-8EB7-4B8DA74A12DE}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IDomValue;
    procedure SetItem(const Index: Integer; const Value: IDomValue);

    function  Add(const AItem: IDomValue): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IDomValue);
    function  IndexOf(const AItem: IDomValue): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IDomValue read GetItem write SetItem; default;
  end;

  IDomNode = interface
  ['{12C9583C-0E62-43DB-A3AA-71876507134E}']
    function  GetNode: HNODE;
    function  GetParent: IDomElement;
    function  GetChildCount: UINT;
    function  GetFirstChild: IDomNode;
    function  GetLastChild: IDomNode;
    function  GetNextSibling: IDomNode;
    function  GetPrevSibling: IDomNode;
    function  GetText: SciterString;
    function  GetChild(const AIndex: UINT): IDomNode;
    procedure SetNode(const Value: HNODE);
    procedure SetText(const Value: SciterString);
    
    function Assign(h: HNODE): IDomNode; overload;
    function Assign(h: HELEMENT): IDomNode; overload;
    function Assign(const n: IDomElement): IDomNode; overload;
    function Assign(const n: IDomNode): IDomNode; overload;

    function Equal(n: HNODE): Boolean; overload;
    function Equal(const n: IDomNode): Boolean; overload;

    function IsValid: Boolean;
    function IsText: Boolean;
    function IsComment: Boolean;
    function IsElement: Boolean;

    function ToElement: HELEMENT;

    function Implementor: Pointer;

    procedure Remove(); // remove it from the DOM and release reference
    procedure Detach(); // detach it from the DOM and keep reference

    procedure Append(const thatnode: IDomNode);  // as a last child node
    procedure Prepend(const thatnode: IDomNode); // as a first child node
    procedure InsertBefore(const thatnode: IDomNode); // as a previous sibling
    procedure InsertAfter(const thatnode: IDomNode);  // as a next sibling

    property Node: HNODE read GetNode write SetNode;
    property NextSibling: IDomNode read GetNextSibling;
    property PrevSibling: IDomNode read GetPrevSibling;
    property FirstChild: IDomNode read GetFirstChild;
    property LastChild: IDomNode read GetLastChild;
    
    property Parent: IDomElement read  GetParent;

    property ChildCount: UINT read GetChildCount;
    property Child[const AIndex: UINT]: IDomNode read GetChild; default;

    property Text: SciterString read GetText write SetText;
  end;

  IDomNodeList = interface
  ['{2973DD22-1AD0-4A4D-88D7-70403F6AEBE4}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IDomNode;
    procedure SetItem(const Index: Integer; const Value: IDomNode);

    function  Add(const AItem: IDomNode): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IDomNode);
    function  IndexOf(const AItem: IDomNode): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IDomNode read GetItem write SetItem; default;
  end;

  TDomElementScrollInfo = record
    scroll_pos:   TPoint;
    view_rect:    TRect;
    content_size: TSize;
  end;

  IDomElement = interface
  ['{1571BB84-AE67-4C4E-8A22-F78881D14C69}']
    function  GetID: SciterString;
    function  GetUID: UINT;
    function  GetElement: HELEMENT;
    function  GetElementType: SciterString;
    function  GetElementById(const AId: SciterString): IDomElement;
    function  GetElementByUID(const AUID: UINT): IDomElement;
    function  GetHtml(): SciterString;
    function  GetOuterHtml(): SciterString;
    function  GetText: SciterString;
    function  GetIndex: Integer;
    function  GetScrollInfo: TDomElementScrollInfo;
    function  GetScrollPos: TPoint;
    function  GetAttributeByIndex(const AIndex: UINT): SciterString;
    function  GetAttributeName(const AIndex: UINT): SciterString;
    function  GetAttributes(const AName: SciterString): SciterString;
    function  GetStyle(const AName: SciterString): SciterString;
    function  GetLeft: Integer;
    function  GetTop: Integer;
    function  GetHeight: Integer;
    function  GetWidth: Integer;
    function  GetAttributeCount: UINT;
    function  GetChild(const AIndex: UINT): IDomElement;
    function  GetChildCount: UINT;
    function  GetParent: IDomElement;
    function  GetTag: SciterString;
    function  GetUniqueSelector: SciterString;
    function  GetState: UINT;
    function  GetEnable: Boolean;
    function  GetVisible: Boolean;
    function  GetControlType: TControlType;
    function  GetValue: IDomValue;
    function  GetNamespace: tiscript_value;
    function  GetVM: HVM;
    function  GetBehavior: IDefalutBehaviorEventHandler;
    procedure SetID(const Value: SciterString);
    procedure SetElement(const Value: HELEMENT);
    procedure SetHtml(const Value: SciterString);
    procedure SetOuterHtml(const Value: SciterString);
    procedure SetText(const Value: SciterString);
    procedure SetScrollPos(const Value: TPoint);
    procedure SetAttributes(const AName, Value: SciterString);
    procedure SetStyle(const AName, Value: SciterString);
    procedure SetState(const Value: UINT);
    procedure SetValue(const Value: IDomValue);
    procedure SetBehavior(const Value: IDefalutBehaviorEventHandler);

    function Implementor: Pointer;

    (**Assign \c element an \c #HELEMENT
      * \param h \b #HELEMENT
      * \return \b #element&
      **)
    function Assign(h: HELEMENT): IDomElement; overload;
    (**Assign \c element another \c #element
      * \param e \b #element
      * \return \b #element&
      **)
    function Assign(const n: IDomElement): IDomElement; overload;

    (**Test equality of this and another \c #element's
      * \param rs \b const \b #element 
      * \return \b bool, true if elements are equal, false otherwise
      **)
    function Equal(n: HELEMENT): Boolean; overload;
    function Equal(const n: IDomElement): Boolean; overload;

    function ToBool: Boolean;
    function ToNode: HNODE;

    (**Test whether element is valid.
      * \return \b bool, true if element is valid, false otherwise
      **)
    function IsValid: Boolean;
    (** Test if point is inside shape rectangle of the element.
      client_pt - client rect relative point          
      **)
    function IsInside(const client_pt: TPoint): Boolean;
    function IsChild(const p: IDomElement): Boolean;
    function IsParent(const c: IDomElement): Boolean;

    (**Get bounding rectangle of the element.
      * \param root_relative \b bool, if true function returns location of the 
      * element relative to Sciter window, otherwise the location is given 
      * relative to first scrollable container.
      * \return \b RECT, bounding rectangle of the element.
      **)
    function GetLocation(area: UINT = ROOT_RELATIVE or CONTENT_BOX): TRect;

    (** get min-intrinsic and max-intrinsic widths of the element. *)
    procedure GetIntrinsicWidths(var min_width: Integer; var max_width: Integer);
    (** get min-intrinsic height of the element calculated for forWidth. *)
    function  GetIntrinsicHeight(for_width: Integer): Integer;
    // get scripting object associated with this DOM element
    function GetExpando(force_create: Boolean = false): IDomValue;
    // get scripting object associated with this DOM element
    function GetObject(force_create: Boolean = false): tiscript_value;

    (**Get HWINDOW of containing window.
      * \param root_window \b bool, handle of which window to get:
      * - true - Sciter window
      * - false - nearest windowed parent element. 
      * \return \b HWINDOW
      **)
    function GetElementHwnd(root_window: Boolean = True): HWINDOW;

    (** create brand new copy of this element. Element will be created disconected.
        You need to call insert to inject it in some container.
        Example:
            element select = ...;
            element option1 = ...;
            element option2 = option1.clone();
            select.insert(option2, option1.index() + 1);
        - will create copy of option1 element (option2) and insert it after option1,
      **)
    function Clone: IDomElement;

    procedure LoadHtml(const url: SciterString; initiator: IDomElement = nil);
    procedure LoadData(const url: SciterString; dataType: SciterResourceType = RT_DATA_HTML; initiator: IDomElement = nil);

    function CreateElement(const TagName: SciterString; const Text: SciterString = ''): IDomElement;

    (** Insert element e at \i index position of this element.**)
    procedure Insert(const e: IDomElement; index: UINT);
    (** Append element e as last child of this element. **)
    procedure Append(const e: IDomElement);
    (** delete - remove this element from its parent and destroy all behaviors **)
    procedure Delete();
    (** swap two elements in the DOM**)
    procedure Swap(eWith: IDomElement);
    (** reorders children of the element using sorting order defined by cmp**)
    procedure Sort(cmp: TElementComparator; param: LPVOID = nil; AStart: Integer = 0; AEnd: Integer = -1);

    procedure Highlight;

    procedure SetHighlighted(hSciterWnd: HWINDOW);

    (** traverse event - send it by sinking/bubbling on the 
      * parent/child chain of this element
      **)
    function SendEvent(event_code: UINT; reason: UINT = 0; heSource: IDomElement = nil): Boolean;
    (** post event - post it in the queue for later sinking/bubbling on the 
      * parent/child chain of this element.
      * method returns immediately
      *)
    procedure PostEvent(event_code: UINT; reason: UINT = 0; heSource: IDomElement = nil);

    function  FireEvent(const evt: TBehaviorEventParams; post: Boolean = True): Boolean;

    (** call method, invokes method in all event handlers attached to the element **)
    function CallBehaviorMethod(const p: PMethodParams): Boolean;
    // call scripting method attached to the element (directly or through of scripting behavior)
    // Example, script:
    //   var elem = ...
    //   elem.foo = function() {...}
    // Native code:
    //   dom::element elem = ...
    //   elem.call_method("foo");
    function CallMethod(const name: SciterString; const argv: array of IDomValue): IDomValue; overload;
    function CallMethod(const name: SciterString): IDomValue; overload;

    // call scripting function defined on global level   
    // Example, script:
    //   function foo() {...}
    // Native code: 
    //   dom::element root = ... get root element of main document or some frame inside it
    //   root.call_function("foo"); // call the function
    function CallFunction(const name: SciterString; const argv: array of IDomValue): IDomValue; overload;
    function CallFunction(const name: SciterString): IDomValue; overload;
    // call scripting method attached to the element (directly or through of scripting behavior)
    // Example, script:
    //   var elem = ...
    //   elem.foo = function() {...}
    // Native code:
    //   dom::element elem = ...
    //   elem.call_method("foo");
    function  Call(const name: SciterString; const Args: array of OleVariant): OleVariant; overload;
    function  Call(const name: SciterString): OleVariant; overload;
    // evaluate script in element context:
    // 'this' in script will be the element
    // and in namespace of element's document.
    function Eval(const script: SciterString): OleVariant; overload;
    function Eval(const script: SciterString; const Args: array of const): OleVariant; overload;
    
    (**Set inner or outer html of the element.
      * \param html \b const \b unsigned \b char*, UTF-8 encoded string containing html text
      * \param html_length \b size_t, length in bytes of \c html
      * \param where \b int, possible values are:
      * - SIH_REPLACE_CONTENT - replace content of the element
      * - SIH_INSERT_AT_START - insert html before first child of the element
      * - SIH_APPEND_AFTER_LAST - insert html after last child of the element
      **)
    procedure SetHtmlEx(const html: SciterString; where: TSetElementHtml = SIH_REPLACE_CONTENT);
    function  GetHtmlEx(outer: Boolean = True): SciterString;

    procedure AttachHwnd(child: HWINDOW);
    (** detach - remove this element from its parent**)
    procedure Detach();

    // "manually" attach event_handler proc to the DOM element 
    procedure AttachEventHandler(const p_event_handler: IBehaviorEventHandler);
    procedure DetachEventHandler(const p_event_handler: IBehaviorEventHandler);

    (**Combine given URL with URL of the document element belongs to.
        * \param[in, out] inOutURL \b LPWSTR, at input this buffer contains 
        * zero-terminated URL to be combined, after function call it contains 
        * zero-terminated combined URL
        * \param bufferSize \b UINT, size of the buffer pointed by \c inOutURL
          **)
    function CombineURL(const aGivenUrl: SciterString; const ABufferSize: UINT): SciterString; overload;
    function CombineURL(const aRelativeUrl: SciterString): SciterString; overload;

    function  IndexOfAttribute(const AName: SciterString): Integer;
    function  HasAttribute(const AName: SciterString): Boolean;
    procedure RemoveAttribute(const AName: SciterString);

    // clears content of the element
    procedure Clear();
    procedure ClearAttribute();

    (**Set mouse capture.
      * After call to this function all mouse events will be targeted to this element.
      * To remove mouse capture call #sciter::dom::element::release_capture().
      **)
    procedure SetCapture();
    (**Release mouse capture.
      * Mouse capture can be set with #element:set_capture()
      **)
    procedure ReleaseCapture();

    (**Scroll this element to view. **)
    procedure ScrollToView(toTopOfView: Boolean = False; smooth: Boolean = True);

    (** Shows block element (DIV) in popup window.
     * \param[in] hePopup \b HELEMENT, element to show as popup
     * \param[in] heAnchor \b HELEMENT, anchor element - hePopup will be shown near this element
     * \param[in] placement \b UINT, values:
     *     2 - popup element below of anchor
     *     8 - popup element above of anchor
     *     4 - popup element on left side of anchor
     *     6 - popup element on right side of anchor
     *     ( see numpad on keyboard to get an idea of the numbers)
     * \return \b #EXTERN_C SCDOM_RESULT SCAPI
     **)
    procedure Popup(const heAnchor: IDomElement; placement: UINT);
    (** Shows block element (DIV) in popup window at given position.
     * \param[in] hePopup \b HELEMENT, element to show as popup
     * \param[in] pos \b POINT, popup element position, relative to origin of Sciter window.
     * \param[in] animate \b BOOL, true if animation is needed.
     **)
    procedure PopupAt(const heAnchor: IDomElement; const pos: TPoint; animate: Boolean = True);
    (** Removes popup window.
     * \param[in] he \b HELEMENT, element which belongs to popup window or popup element itself
     **)
    procedure HidePopup;

    (**Apply changes and refresh element area in its window.
      * \param[in] render_now \b bool, if true element will be redrawn immediately.
      **)
    procedure Update(render_now: Boolean = False);

    procedure Refresh(const rc: TRect); overload;
    procedure Refresh; overload;

    procedure SelectElements(const selectors: SciterString;{CSS selectors, comma separated list}
      pcall: TElementSelectCallback);

    procedure StartTimer(ms: UINT; timer_id: UINT_PTR = 0);
    procedure StopTimer(timer_id: UINT_PTR = 0);

    function  FindFirst(const selectors: SciterString; Args: array of const): IDomElement; overload;
    function  FindFirst(const selectors: SciterString): IDomElement; overload;
    procedure FindAll(pcall: TElementSelectCallback; const selectors: SciterString; Args: array of const);
    // will find first parent satisfying given css selector(s)
    function  FindNearestParent(const selectors: SciterString; Args: array of const; depth: UINT = 0): IDomElement; overload;
    function  FindNearestParent(const selectors: SciterString; depth: UINT = 0): IDomElement; overload;

    // test this element against CSS selector(s)
    function Match(const selectors: SciterString; Args: array of const): Boolean;

    (**Checks if particular UI state bits are set in the element. **)
    function TestState(bits: UINT{ELEMENT_STATE_BITS}): Boolean;
    (**Set UI state of the element with optional view update.**)
    procedure SetStateEx(bitsToSet, bitsToClear: UINT{ELEMENT_STATE_BITS}; update: Boolean = True);
    
    procedure ChangeState(bitsToSet: UINT; update: Boolean = True);
    procedure ClearState(bitsToClear: UINT; update: Boolean = True);

    (**
       *  Request - send GET or POST request for the element
       *
       * event handler on the 'he' element (if any) will be notified
       * when data will be ready by receiving HANDLE_DATA_DELIVERY event.
       *
       **)
    procedure Request(const url: SciterString; dataType: SciterResourceType;
      requestType: TRequestType; const requestParams: TRequestParamArray); overload;
    procedure Request(const url: SciterString; dataType: SciterResourceType = RT_DATA_HTML;
      requestType: TRequestType = GET_ASYNC); overload;

    (** set visibility to visible **)
    procedure Show();
    (** set visibility to none **)
    procedure Hide();

    (**Get next sibling element.
      * \return \b #HELEMENT, handle of the next sibling element if it exists or 0 otherwise
      **)
    function Next: IDomElement;
    (**Get previous sibling element.
      * \return \b #HELEMENT, handle of previous sibling element if it exists or 0 otherwise
      **)
    function Prior: IDomElement;
    (**Get first sibling element.
      * \return \b #HELEMENT, handle of the first sibling element if it exists or 0 otherwise
      **)
    function First: IDomElement;
    (**Get last sibling element.
      * \return \b #HELEMENT, handle of last sibling element if it exists or 0 otherwise
      **)
    function Last: IDomElement;
    (**Get root of the element
      * \return \b #HELEMENT, handle of document root element (html)
      **)
    function Root: IDomElement;

    (**parent element of given element or null if this element is a root element. Read-only.**)
    property Parent: IDomElement read GetParent;
    {** element's handle **}
    property Element: HELEMENT read GetElement write SetElement;

    (**Get element UID - identifier suitable for storage. **)
    property UID: UINT read GetUID;
    (** value of attribute id (if any). Read-only. **)
    property ID: SciterString read GetID write SetID;
    (** tag name of the element. Read-only.**)
    property Tag: SciterString read GetTag;
    {element's unique selector }
    property UniqueSelector: SciterString read GetUniqueSelector;
    (**Get element's tag name.
    * \return \b sciter::astring, tag name of the element
    * 
      * \par Example:
      * For &lt;div&gt; tag function will return "div".
    **)
    property ElementType: SciterString read GetElementType;
    property ElementById[const AId: SciterString]: IDomElement read GetElementById;
    property ElementByUID[const AUID: UINT]: IDomElement read GetElementByUID;
    
    (**Get UI state bits of the element as set of ELEMENT_STATE_BITS**)
    property State: UINT read GetState write SetState;

    property ControlType: TControlType read GetControlType;
    (**String by default and if the element has native behavior attached to
       the element it could be also: integer, boolean, array, etc.
       For example <input type="radio"> will return true if this radio button
       has "on" state.
     Note: property value(v) can be overriden in a behavior class in script.
       To access native value in such case use Element.state.value property.**)
    property Value: IDomValue read GetValue write SetValue;

    (**true if element and all its containers are not in :disabled state ( setState(Element.STATE_DISABLED)).**)
    property IsEnable: Boolean read GetEnable;
    (**true if element and all its containers are in visible state - no visibility:hidden or display:none defined for them.
       false - otherwise.**)
    property IsVisible: Boolean read GetVisible;

    (**namespace object of the element. All static functions and classes defined
      in scripts of current document are members of this [namespace] object.**)
    property ns: tiscript_value read GetNamespace;
    property vm: HVM read GetVM;

    (**child element of the element at the index position, Read-write index accessor. Zero-based index.**)
    property Index: Integer read GetIndex;
    (**number of child elements in this element. Read-only property.**)
    property ChildCount: UINT read GetChildCount;
    (**child element of the element at the index position, Read-write index accessor. Zero-based index.**)
    property Child[const AIndex: UINT]: IDomElement read GetChild; default;

    property AttributeCount: UINT read GetAttributeCount;
    property AttributeByIndex[const AIndex: UINT]: SciterString read GetAttributeByIndex;
    property AttributeName[const AIndex: UINT]: SciterString read GetAttributeName;
    property Attributes[const AName: SciterString]: SciterString read GetAttributes write SetAttributes;
    (**style attributes of the DOM element.**)
    property Style[const AName: SciterString]: SciterString read GetStyle write SetStyle;
    property Left: Integer read  GetLeft;
    property Top: Integer read  GetTop;
    property Width: Integer read  GetWidth;
    property Height: Integer read  GetHeight;

    (**html source of the content of the element. Text returned (String) will not include head and tail tags of the element.
       Value to set can be either String or Stream object.**)
    property Html: SciterString read GetHtml write SetHtml;
    (** html source of the element. Text returned (String) will include head and tail tags of the element.
        Value to set can be either String or Stream object.**)
    property OuterHtml: SciterString read GetOuterHtml write SetOuterHtml;
    (**text of the element. For compound elements this property returns plain-text version of the content**)
    property Text: SciterString read GetText write SetText;

    property Behavior: IDefalutBehaviorEventHandler read GetBehavior write SetBehavior;

    property ScrollInfo: TDomElementScrollInfo read GetScrollInfo;
    property ScrollPos: TPoint read GetScrollPos write SetScrollPos;
  end;

  IDomElementList = interface
  ['{298AAAFC-89E0-4143-8D3D-E704B5BA779D}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IDomElement;
    function  GetItemByID(const AID: SciterString): IDomElement;
    function  GetItemByName(const AName: SciterString): IDomElement;
    function  GetItemByTag(const ATag: SciterString): IDomElement;
    function  GetItemByUID(const AUID: UINT): IDomElement;
    procedure SetItem(const Index: Integer; const Value: IDomElement);
    procedure SetItemByID(const AID: SciterString; const Value: IDomElement);
    procedure SetItemByName(const AName: SciterString; const Value: IDomElement);
    procedure SetItemByTag(const ATag: SciterString; const Value: IDomElement);
    procedure SetItemByUID(const AUID: UINT; const Value: IDomElement);

    function  Add(const AItem: IDomElement): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IDomElement);
    
    function  IndexOf(const AItem: IDomElement): Integer;
    function  IndexOfID(const AID: SciterString): Integer;
    function  IndexOfName(const AName: SciterString): Integer;
    function  IndexOfTag(const ATag: SciterString): Integer;
    function  IndexOfUID(const AUID: UINT): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IDomElement read GetItem write SetItem; default;
    property ItemByID[const AID: SciterString]: IDomElement read GetItemByID write SetItemByID;
    property ItemByName[const AName: SciterString]: IDomElement read GetItemByName write SetItemByName;
    property ItemByTag[const ATag: SciterString]: IDomElement read GetItemByTag write SetItemByTag;
    property ItemByUID[const AUID: UINT]: IDomElement read GetItemByUID write SetItemByUID;
  end;

  IDomEditBox = interface(IDomElement)
  ['{EC3610CE-B791-4AE7-9C1E-0D497804475E}']
    function  GetTextValue: SciterString;
    procedure SetTextValue(const Value: SciterString);

    function Selection(var AStart: Integer; var AEnd: Integer): Boolean;
    function Select(const AStart: Integer = 0; const AEnd: Integer = $FFFF): Boolean;
    function Replace(const text: SciterString): Boolean;

    function CharPosAtXY(x, y: Integer): Integer;

    property TextValue: SciterString read GetTextValue write SetTextValue;
  end;

  PDomScrollbarInfo = ^TDomScrollbarInfo;
  TDomScrollbarInfo = record
    Pos:      Integer;
    min_value:  Integer;
    max_value:  Integer ;
    page_value: Integer; // page increment
    step_value: Integer; // step increment (arrow button click)
  end;

  IDomScrollbar = interface(IDomElement)
  ['{516E79FF-8A41-45AE-9864-5994FF81886E}']
    function  GetInfo: TDomScrollbarInfo;
    function  GetPos: Integer;
    procedure SetInfo(const Value: TDomScrollbarInfo);
    procedure SetPos(const Value: Integer);

    property Info: TDomScrollbarInfo read GetInfo write SetInfo;
    property Pos: Integer read GetPos write SetPos;
  end;

  // event handler which can be attached to any DOM element.
  // event handler can be attached to the element as a "behavior" (see below)
  // or by sciter::dom::element::attach( event_handler* eh )
  PIBehaviorEventHandler = ^IBehaviorEventHandler;
  IBehaviorEventHandler = interface
  ['{19688372-F8D2-4086-B8D1-CEF0685B32C3}']
    function  GetData1: Pointer;
    function  GetData2: Pointer;
    function  GetData3: IInterface;
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetData3(const Value: IInterface);
    
    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;
    function  IsType(event, event_type: UINT): Boolean;

    function  Implementor: Pointer;
    
    procedure Attached(he: HELEMENT);
    procedure Detached(he: HELEMENT);
    // defines list of event groups this event_handler is subscribed to
    function  Subscription(he: HELEMENT; var event_groups: UINT{EVENT_GROUPS}): Boolean;
    // handlers with extended interface
    // by default they are calling old set of handlers (for compatibility with legacy code)
    function  HandleMouse(he: HELEMENT; var params: TMouseParams): Boolean;
    function  HandleKey(he: HELEMENT; var params: TKeyParams): Boolean;
    function  HandleFocus(he: HELEMENT; var params: TFocusParams): Boolean;
    function  HandleTimer(he: HELEMENT; var params: TTimerParams): Boolean;
    procedure HandleSize(he: HELEMENT); 
    function  HandleScroll(he: HELEMENT; params: TScorllParams): Boolean;
    function  HandleGesture(he: HELEMENT; var params: TGestrueParams): Boolean;
    function  HandleDraw(he: HELEMENT; var params: TDrawParams): Boolean;
    function  HandleMethodCall(he: HELEMENT; var params: TMethodParams): Boolean;
    // notification events from builtin behaviors - synthesized events: BUTTON_CLICK, VALUE_CHANGED
    // see enum BEHAVIOR_EVENTS
    function HandleEvent(he: HELEMENT; var params: TBehaviorEventParams): Boolean;
    // notification event: data requested by HTMLayoutRequestData just delivered
    function HandleDataArrived(he: HELEMENT; var params: TDataArrivedParams): Boolean;
    function HandleScriptingCallCs(he: HELEMENT; var params: TScriptingMethodParams): Boolean; overload;
    function HandleScriptingCallTs(he: HELEMENT; var params: TTiscriptMethodParams): Boolean; overload;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
    property Data3: IInterface read GetData3 write SetData3;
  end;

  TLayoutBeforeWndProc = function (msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT of object;
  TLayoutAfterWndProc = procedure (msg: UINT; wParam: WPARAM; lParam: LPARAM; var Result: LRESULT) of object;

  TBehaviorAttachedProc = procedure (const he: IDomElement) of object;
  TBehaviorDetachedProc = procedure (const he: IDomElement) of object;
  TBehaviorSubscriptionProc = function (const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean of object;
  TBehaviorMouseProc =  function (const he, target: IDomElement; event_type: UINT{MOUSE_EVENTS}; var params: TMouseParams): Boolean of object;
  TBehaviorKeyProc =  function (const he, target: IDomElement; event_type: UINT{KEY_EVENTS}; var params: TKeyParams): Boolean of object;
  TBehaviorFocusProc =  function (const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean of object;
  TBehaviorTimerProc =  function (const he: IDomElement): Boolean of object;
  TBehaviorTimerExProc =  function (const he: IDomElement; extTimerId: UINT_PTR): Boolean of object;
  TBehaviorDrawProc  =  function (const he: IDomElement; draw_type: UINT{DRAW_EVENTS}; var params: TDrawParams): Boolean of object;
  TBehaviorSizeProc  =  procedure (const he: IDomElement) of object;
  TBehaviorMethodCallProc =  function  (const he: IDomElement; methodID: TBehaviorMethodIdentifier; params: PMethodParams): Boolean of object;
  //    when-click: r = self.my-method(1,"one");
  // }
  // will end up with on_script_call(he, "my-method" , 2, argv, retval );
  // where argv[0] will be 1 and argv[1] will be "one".
  TBehaviorScriptCallCsProc =  function (const he: IDomElement; name: LPCSTR; const argv: TDynDomValueArray; var retval: IDomValue): Boolean of object;

  // Calls from TIScript. Override this if you want your own methods accessible directly from tiscript engine.
  // Use tiscript::args to access parameters.
  TBehaviorScriptCallTsProc =  function (const he: IDomElement; pvm: Ptiscript_VM;
    const name: PWideChar; var retval: tiscript_value): Boolean of object;
  // notification events from builtin behaviors - synthesized events: BUTTON_CLICK, VALUE_CHANGED
  // see enum BEHAVIOR_EVENTS
  TBehaviorEventProc =  function (const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean of object;
  // notification event: data requested by HTMLayoutRequestData just delivered
  TBehaviorDataArrivedProc =  function  (const he: IDomElement; initiator: IDomElement; var params: TDataArrivedParams): Boolean of object;
  TBehaviorScrollProc =  function (const he, target: IDomElement; cmd: UINT{SCROLL_EVENTS}; var params: TScorllParams): Boolean of object;

  TBehaviorGestureProc = function (const he, target: IDomElement; cmd: UINT{GESTURE_CMD}; var params: TGestrueParams): Boolean of object;

  IDefalutBehaviorEventHandler = interface(IBehaviorEventHandler)
  ['{80DBA724-5036-4DDE-92D9-C420B60F8B0D}']
    function GetRttiObject: IDispatchRttiObject;
    function GetLayout: Pointer;
    function GetController: Pointer;
    function GetData1: Pointer;
    function GetData2: Pointer;
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
    function GetOnInitDataView: TBehaviorEventProc;
    function GetOnRowsDataRequest: TBehaviorEventProc;
    function GetOnUIStateChanged: TBehaviorEventProc;
    function GetOnFormSubmit: TBehaviorEventProc;
    function GetOnFormReset: TBehaviorEventProc;
    function GetOnDocumentCreated: TBehaviorEventProc;
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
    procedure SetOnInitDataView(const Value: TBehaviorEventProc);
    procedure SetOnRowsDataRequest(const Value: TBehaviorEventProc);
    procedure SetOnUIStateChanged(const Value: TBehaviorEventProc);
    procedure SetOnFormSubmit(const Value: TBehaviorEventProc);
    procedure SetOnFormReset(const Value: TBehaviorEventProc);
    procedure SetOnDocumentCreated(const Value: TBehaviorEventProc);
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
    procedure SetOnScriptCallTs(const Value: TBehaviorScriptCallTsProc);
    procedure SetOnScroll(const Value: TBehaviorScrollProc);
    procedure SetOnGesture(const Value: TBehaviorGestureProc);
    procedure SetOnSize(const Value: TBehaviorSizeProc);
    procedure SetOnTimer(const Value: TBehaviorTimerProc);
    procedure SetOnTimerEx(const Value: TBehaviorTimerExProc);
    procedure SetAfterWndProc(const Value: TLayoutAfterWndProc);
    procedure SetBeforeWndProc(const Value: TLayoutBeforeWndProc);

    function  Implementor: Pointer;

    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;
    function  IsType(event, event_type: UINT): Boolean;

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

    {request to virtual grid to initialize its view}
    property OnInitDataView: TBehaviorEventProc read GetOnInitDataView write SetOnInitDataView;
    {request from virtual grid to data source behavior to fill data in the table
     parameters passed throug DATA_ROWS_PARAMS structure.}
    property OnRowsDataRequest: TBehaviorEventProc read GetOnRowsDataRequest write SetOnRowsDataRequest;

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
  end;

  IBehaviorFactory = interface
  ['{DBBCA7A7-C6E3-4766-A02C-825968171BB9}']
    function GetName: SciterString;
    procedure SetName(const Value: SciterString);

    function  Implementator: Pointer;

    function  CreateHandler(const he: IDomElement; const ALayout: ISciterLayout = nil): IBehaviorEventHandler;

    property Name: SciterString read GetName write SetName;
  end;

  IBehaviorFactorys = interface
  ['{EE9E748E-4DB6-4249-A490-1DE7B666F99C}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IBehaviorFactory;
    function  GetItemByName(const AName: SciterString): IBehaviorFactory;
    procedure SetItem(const Index: Integer; const Value: IBehaviorFactory);
    procedure SetItemByName(const AName: SciterString; const Value: IBehaviorFactory);

    function  Reg(AItem: IBehaviorFactory): Integer;
    procedure UnReg(AItem: IBehaviorFactory); overload;
    procedure UnReg(const AName: SciterString); overload;

    procedure Invalidate;
    function  ToString: SciterString;
    
    procedure Clear;
    procedure Delete(const Index: Integer);
    function  IndexOf(const AItem: IBehaviorFactory): Integer;
    function  IndexOfName(const AName: SciterString): Integer;
    function  First: IBehaviorFactory;
    function  Last: IBehaviorFactory;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IBehaviorFactory read GetItem write SetItem; default;
    property ItemByName[const AName: SciterString]: IBehaviorFactory read GetItemByName write SetItemByName;
  end;

  TLayoutNotificationProc =  function (var pnm: PSciterCallbackNotification; var Handled: Boolean): LRESULT of object;
  TLayoutLoadDataProc = function (var pnmld: LPSCN_LOAD_DATA; const schema: PSciterSchemaInfo; var Handled: Boolean): TLoadDataResult of object;
  TLayoutDataLoadedProc = function (var pnmld: LPSCN_DATA_LOADED; var Handled: Boolean): LRESULT of object;
  TLayoutAttachBehaviorProc = function (var lpab: LPSCN_ATTACH_BEHAVIOR; var Handled: Boolean): LRESULT of object;
  TLayoutEngineDestroyedProc = function (var Handled: Boolean): LRESULT of object;
  TLayoutPostedNotificationProc = function (var lpab: LPSCN_POSTED_NOTIFICATION; var Handled: Boolean): LRESULT of object;
  TLayoutCreateNativeObjectProc = function (const ALayout: ISciterLayout; const AObjectName: SciterString;
    argCount: Integer; args: Ptiscript_value_array): IDispatch of object;
  TLayoutAfterCreateBehaviorProc = procedure (const ALayout: ISciterLayout; const lpab: LPSCN_ATTACH_BEHAVIOR; const ABehavior: IBehaviorEventHandler; var bHandled: Boolean) of object;
  TLayoutGraphicsCriticalFailure = procedure (const ALayout: ISciterLayout; var lpab: LPSCN_GRAPHICS_CRITICAL_FAILURE) of object; 
  TLayoutDebugMessage = procedure(const ALayout: ISciterLayout; subsystem: TOutputSubSystem; severity: TOutputSeverity; const msg: SciterString) of object;

  PSciterGetPPIInfo = ^TSciterGetPPIInfo;
  TSciterGetPPIInfo = record
    px: UINT;
    py: UINT;
  end;

  TSciterLayoutOption = (
    sloUseHtmlTitle,
    sloUseHtmlSize
  );
  TSciterLayoutOptions = set of TSciterLayoutOption;

  PISciterLayout = ^ISciterLayout;
  ISciterLayout = interface
  ['{0B21CBE8-B486-4813-8808-7F7837ADC898}']
    function GetCurrentNS: tiscript_value;
    function GetGlobalNS: tiscript_value;
    function GetMaxToFullScreen: Boolean;
    function GetBaseUri: SciterString;
    function GetHomeURL: SciterString;
    function GetHtml: SciterString;
    function GetHwnd: HWINDOW;
    function GetHookWnd: HWINDOW;
    function GetHVM: HVM;
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
    function GetBehavior: IDefalutBehaviorEventHandler;
    function GetBehaviorFactorys: IBehaviorFactorys;
    function GetOptions: TSciterLayoutOptions;
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
    function GetOnDebugMessage: TLayoutDebugMessage;
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
    procedure SetOnDebugMessage(const Value: TLayoutDebugMessage);

    function  Implementor: Pointer;

    procedure Setup;
    procedure Teardown;

    function AddBeforeWndProc(const AWndProc: TLayoutBeforeWndProc): Integer;
    function RemoveBeforeWndProc(const AWndProc: TLayoutBeforeWndProc): Integer;

    function AddAfterWndProc(const AWndProc: TLayoutAfterWndProc): Integer;
    function RemoveAfterWndProc(const AWndProc: TLayoutAfterWndProc): Integer;

    function  LoadPluginByUrl(const AUrl: SciterString): TLoadDataResult;
    function  LoadPluginByPath(const APath: SciterString): TLoadDataResult;

     //Invokes garbage collector
    procedure GC;
    //Sciter Window Proc without call of DefWindowProc.
    function ProcND(hWnd: HWINDOW; msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT;

    // notifiaction cracker
    function HandleNotification(pnm: PSciterCallbackNotification): LRESULT;
    function HandleLoadData(pnmld: LPSCN_LOAD_DATA): LRESULT;
    function HandleDataLoaded(pnmld: LPSCN_DATA_LOADED): LRESULT;
    function HandleAttachBehavior(lpab: LPSCN_ATTACH_BEHAVIOR): LRESULT;
    function HandleEngineDestroyed: LRESULT; 
    function HandlePostedNotification(lpab: LPSCN_POSTED_NOTIFICATION): LRESULT;
    procedure HandleGraphicsCriticalFailure(lpab: LPSCN_GRAPHICS_CRITICAL_FAILURE); 

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

    function  RegisterObject(const Name: SciterString; Obj: IDispatch): tiscript_object;
    function  RegisterFunction(const Name: SciterString; Handler: tiscript_native_method; Tag: Pointer = nil): tiscript_value;
    procedure UnRegisterObject(const VarName: SciterString);
    
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
    property OnDebugMessage: TLayoutDebugMessage read GetOnDebugMessage write SetOnDebugMessage;
  end;


  TSciterNotificationProc =  function (const ALayout: ISciterLayout; var pnm: PSciterCallbackNotification; var Handled: Boolean): LRESULT of object;
  TSciterLoadDataProc = function (const ALayout: ISciterLayout; var pnmld: LPSCN_LOAD_DATA; const schema: PSciterSchemaInfo; var Handled: Boolean): TLoadDataResult of object;
  TSciterDataLoadedProc = function (const ALayout: ISciterLayout; var pnmld: LPSCN_DATA_LOADED; var Handled: Boolean): LRESULT of object;
  TSciterAttachBehaviorProc = function (const ALayout: ISciterLayout; var lpab: LPSCN_ATTACH_BEHAVIOR; var Handled: Boolean): LRESULT of object;
  TSciterEngineDestroyedProc = function (const ALayout: ISciterLayout; var Handled: Boolean): LRESULT of object;
  TSciterPostedNotificationProc = function (const ALayout: ISciterLayout; var lpab: LPSCN_POSTED_NOTIFICATION; var Handled: Boolean): LRESULT of object;

  TSciterAfterCreateBehaviorProc = procedure (const ALayout: ISciterLayout; const lpab: LPSCN_ATTACH_BEHAVIOR;
    const Behavior: IBehaviorEventHandler) of object;
  TSciterRunAppclitionProc = function (const MainWnd: HWINDOW; var bHandled: Boolean): Integer;


  PISciter = ^ISciter;
  ISciter = interface
  ['{E28C8092-669D-4362-A398-04149728B5E1}']
    function GetReportBehaviorCount: Boolean;
    function GetHandle: HMODULE;
    function GetMainWnd: HWINDOW;
    function GetDriverName: SciterString;
    function GetSciterClassName: SciterString;
    function GetSciterVersion: SciterString;
    function GetMainMasterFile: SciterString;
    function GetMainMasterPath: SciterString;
    function GetMainMasterTisFile: SciterString;
    function GetMsgboxHtmlFile: SciterString;
    function GetMsgboxCSSFile: SciterString;
    function GetDebugPeerFile: SciterString;
    function GetBaseLibraryFile: SciterString;
    function GetGraphicsCaps: UINT;
    function GetBehaviorFactorys: IBehaviorFactorys;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetOnAttachBehavior: TSciterAttachBehaviorProc;
    function GetAfterCreateBehavior: TSciterAfterCreateBehaviorProc;
    function GetOnDataLoaded: TSciterDataLoadedProc;
    function GetOnEngineDestroyed: TSciterEngineDestroyedProc;
    function GetOnNotification: TSciterNotificationProc;
    function GetOnPostedNotification: TSciterPostedNotificationProc;
    function GetOnRunAppclition: TSciterRunAppclitionProc;
    procedure SetReportBehaviorCount(const Value: Boolean);
    procedure SetMainWnd(const Value: HWINDOW);
    procedure SetDriverName(const Value: SciterString);
    procedure SetMainMasterFile(const Value: SciterString);
    procedure SetMainMasterTisFile(const Value: SciterString);
    procedure SetMsgboxHtmlFile(const Value: SciterString);
    procedure SetMsgboxCSSFile(const Value: SciterString);
    procedure SetDebugPeerFile(const Value: SciterString);
    procedure SetBaseLibraryFile(const Value: SciterString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetOnAttachBehavior(const Value: TSciterAttachBehaviorProc);
    procedure SetAfterCreateBehavior(const Value: TSciterAfterCreateBehaviorProc);
    procedure SetOnEngineDestroyed(const Value: TSciterEngineDestroyedProc);
    procedure SetOnDataLoaded(const Value: TSciterDataLoadedProc);
    procedure SetOnNotification(const Value: TSciterNotificationProc);
    procedure SetOnPostedNotification(const Value: TSciterPostedNotificationProc);
    procedure SetOnRunAppclition(const Value: TSciterRunAppclitionProc);

    function Implementor: Pointer;

    function  AddDataLoadProc(const ADataLoadProc: TSciterLoadDataProc): Integer;
    function  RemoveDataLoadProc(const ADataLoadProc: TSciterLoadDataProc): Integer;
    procedure ClearDataLoadProcs;

    (**Set Master style sheet.
     *
     * \param[in] utf8 \b LPCBYTE, start of CSS buffer.
     * \param[in] numBytes \b UINT, number of bytes in utf8.
     **)
    function SetMasterCSS(utf8: PAnsiChar; numBytes: UINT): Boolean;
    function SetMasterCSSFile(const ACSSFile: SciterString): Boolean;
    (**Append Master style sheet.
     *
     * \param[in] utf8 \b LPCBYTE, start of CSS buffer.
     * \param[in] numBytes \b UINT, number of bytes in utf8.
     *
     **)
    function AppendMasterCSS(utf8: PAnsiChar; numBytes: UINT): Boolean;

    function  RunAppclition(const MainWnd: HWINDOW): Integer;
    procedure ProcessMessages;
    procedure Terminate;

    (** Try to translate message that sciter window is interested in.
     *
     * \param[in,out] lpMsg \b MSG*, address of message structure that was passed before to ::DispatchMessage(), ::PeekMessage().
     *
     * SciterTranslateMessage has the same meaning as ::TranslateMessage() and should be called immediately before it.
     * Example:
     *
     *   if( !SciterTranslateMessage(&msg) )
     *      TranslateMessage(&msg);
     *
     * ATTENTION!: SciterTranslateMessage call is critical for popup elements in MoSciter.
     *             On Desktop versions of the Sciter this function does nothing so can be ommited.
     *
     **)
    function TranslateMessage(var lpMsg: TMsg): Boolean;
    (** SciterTraverseUIEvent - traverse (sink-and-bubble) MOUSE or KEY event.
     * \param[in] evt \b EVENT_GROUPS, either HANDLE_MOUSE or HANDLE_KEY code.
     * \param[in] eventCtlStruct \b LPVOID, pointer on either MOUSE_PARAMS or KEY_PARAMS structure.
     * \param[out] bOutProcessed \b LPBOOL, pointer to BOOL receiving TRUE if event was processed by some element and FALSE otherwise.
     **)
    function TraverseUIEvent(evt: UINT; eventCtlStruct: LPVOID): Boolean;
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
    function DataReadyAsync(const hwnd: HWINDOW; uri: SciterString; data: LPCBYTE;
      dataLength: UINT; requestId: LPVOID): Boolean;

    function CreateDefalutHandler: IDefalutBehaviorEventHandler; overload;
    function CreateDefalutHandler(const ABehaviorName: SciterString): IDefalutBehaviorEventHandler; overload;
    function CreateDefalutHandler(const ABehaviorName: SciterString;
      const Controller: Pointer; ARttiObject: IDispatchRttiObject = nil): IDefalutBehaviorEventHandler; overload;

    function FilePathToURL(const FileName: SciterString): SciterString;
    function DecodeURI(const URI: SciterString): SciterString;
    function EncodeURI(const URI: SciterString): SciterString;

    function  S2V(var Value: SCITER_VALUE; var OleValue: OleVariant; vm: HVM): UINT;
    function  V2S(const Value: OleVariant; var SciterValue: SCITER_VALUE; vm: HVM): UINT;
    function  GetNativeObjectJson(var Value: SCITER_VALUE): SciterString;

    function T2S(vm: HVM; script_value: tiscript_value; value: PSCITER_VALUE; isolate: Boolean): Boolean;
    function S2T(vm: HVM; valuev: PSCITER_VALUE; var script_value: tiscript_value): Boolean;

    function  FindLayout(const AWnd: Cardinal): ISciterLayout;
    function  FindLayoutByVM(const vm: HVM): ISciterLayout;

    procedure Log(const ALog: SciterString);
    procedure LogFmt(const ALog: SciterString; const Args: array of const);
    procedure Trace(const ALog: SciterString);
    procedure TraceFmt(const ALog: SciterString; const Args: array of const);

    procedure SetupShadow(AWnd: Cardinal; shadowColor: TColor = 0); 

    property ReportBehaviorCount: Boolean read GetReportBehaviorCount write SetReportBehaviorCount;
    (** the handle of sciter32.dll **)
    property Handle: HMODULE read GetHandle;
    (** Main window of application **)
    property MainWnd: HWINDOW read GetMainWnd write SetMainWnd;
    (** the position of sciter32.dll **)
    property DriverName: SciterString read GetDriverName write SetDriverName;
    (**Get name of Sciter window class.
     *
     * \return \b LPCWSTR, name of Sciter window class.
     *         \b NULL if initialization of the engine failed, Direct2D or DirectWrite are not supported on the OS.
     *
     * Use this function if you wish to create unicode version of Sciter.
     * The returned name can be used in CreateWindow(Ex)W function.
     * You can use #SciterClassNameT macro.
     **)
    property SciterClassName: SciterString read GetSciterClassName;
    (**Returns major and minor version of Sciter engine.**)
    property SciterVersion: SciterString read GetSciterVersion;
    (** main master file **)
    property MainMasterFile: SciterString read GetMainMasterFile write SetMainMasterFile;
    (** main master path **)
    property MainMasterPath: SciterString read GetMainMasterPath;
    (** main master tiscript file **)
    property MainMasterTisFile: SciterString read GetMainMasterTisFile write SetMainMasterTisFile;
    (** view.msgbox html file **)
    property MsgboxHtmlFile: SciterString read GetMsgboxHtmlFile write SetMsgboxHtmlFile;
    (** view.msgbox css file **)
    property MsgboxCSSFile: SciterString read GetMsgboxCSSFile write SetMsgboxCSSFile;
    (** debug-peer.tis file **)
    property DebugPeerFile: SciterString read GetDebugPeerFile write SetDebugPeerFile;
    {** tiscript custom base library file **}
    property BaseLibraryFile: SciterString read GetBaseLibraryFile write SetBaseLibraryFile;
    
    property BehaviorFactorys: IBehaviorFactorys read GetBehaviorFactorys;

    property GraphicsCaps: UINT read GetGraphicsCaps;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;

    property OnNotification: TSciterNotificationProc read GetOnNotification write SetOnNotification;
    property OnDataLoaded: TSciterDataLoadedProc read GetOnDataLoaded write SetOnDataLoaded;
    property OnAttachBehavior: TSciterAttachBehaviorProc read GetOnAttachBehavior write SetOnAttachBehavior;
    property AfterCreateBehavior: TSciterAfterCreateBehaviorProc read GetAfterCreateBehavior write SetAfterCreateBehavior;
    property OnEngineDestroyed: TSciterEngineDestroyedProc read GetOnEngineDestroyed write SetOnEngineDestroyed;
    property OnPostedNotification: TSciterPostedNotificationProc read GetOnPostedNotification write SetOnPostedNotification;
    property OnRunAppclition: TSciterRunAppclitionProc read GetOnRunAppclition write SetOnRunAppclition;
  end;

function Sciter: PISciter;

function BehaviorFactorys: IBehaviorFactorys;

implementation

uses
  SciterImportDefs;

function Sciter: PISciter;
type
  TSciter = function (): PISciter;
begin
  Result :=  TSciter(SciterApi.Funcs[FuncIdx_Sciter]);
end;

function BehaviorFactorys: IBehaviorFactorys;
begin
  Result := Sciter.BehaviorFactorys;
end;

end.

