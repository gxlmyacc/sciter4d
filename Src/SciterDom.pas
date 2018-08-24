{*******************************************************************************
 标题:     SciterDom.pas
 描述:     Dom元素类定义单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDom;

interface

{$I Sciter.inc}

uses
  Windows, Classes, SciterTypes, SciterBehaviorDef, SciterIntf;

type
  TDomNode = class;
  TDomElement = class;

  TDomNode = class(TInterfacedObject, IDomNode)
  private
    hn: HNODE;
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
  protected
    procedure Use(h: HNODE);
    procedure Unuse();
    procedure Set_(h: HNODE);
  public
    constructor Create; overload;
    constructor Create(const el: IDomElement); overload;
    constructor Create(const n: IDomNode); overload;
    constructor CreateFromNode(h: HNODE);
    constructor CreateFromElement(h: HELEMENT);
    destructor Destroy; override;

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
    function ToBool: Boolean;

    function Implementor: Pointer;

    procedure Remove(); // remove it from the DOM and release reference
    procedure Detach(); // detach it from the DOM and keep reference

    class function MakeTextNode(const text: SciterString): IDomNode;
    class function MakeCommentNode(const text: SciterString): IDomNode;

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

  TDomNodeList = class(TInterfacedObject, IDomNodeList)
  private
    FList: IInterfaceList;
  protected
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IDomNode;
    procedure SetItem(const Index: Integer; const Value: IDomNode);
  public
    constructor Create;
    destructor Destroy; override;

    function  Add(const AItem: IDomNode): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IDomNode);
    function  IndexOf(const AItem: IDomNode): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IDomNode read GetItem write SetItem; default;
  end;

  TDomElement = class(TInterfacedObject, IDomElement)
  protected
    he: HELEMENT;
    FBehavior: Pointer;
  private
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
  protected
    procedure Use(h: HELEMENT);
    procedure Unuse();
    procedure Set_(h: HELEMENT);
  public
    (**Construct \c undefined element . **)
    constructor Create; overload;
    (**Construct \c element from existing element handle.
      * \param h \b #HELEMENT
      **)
    constructor Create(h: HELEMENT); overload;
    (**Copy constructor;
      * \param e \b #element
      **)
    constructor Create(const e: IDomElement); overload;
    constructor Create(const e: IDomNode); overload;
    destructor Destroy; override;

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
    procedure LoadData(const url: SciterString; dataType: SciterResourceType; initiator: IDomElement = nil);

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
    
    // call scripting method attached to the element (directly or through of scripting behavior)
    // Example, script:
    //   var elem = ...
    //   elem.foo = function() {...}
    // Native code:
    //   dom::element elem = ...
    //   elem.call_method("foo");
    function  Call(const name: SciterString; const Args: array of OleVariant): OleVariant; overload;
    function  Call( const name: SciterString): OleVariant; overload;

    // call scripting function defined on global level   
    // Example, script:
    //   function foo() {...}
    // Native code: 
    //   dom::element root = ... get root element of main document or some frame inside it
    //   root.call_function("foo"); // call the function
    function CallFunction(const name: SciterString; const argv: array of IDomValue): IDomValue; overload;
    function CallFunction(const name: SciterString): IDomValue; overload;
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

    function CreateElement(const TagName: SciterString; const Text: SciterString = ''): IDomElement;

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
    procedure PopupAt(const heAnchor: IDomElement; const pos: TPoint; animate: Boolean);
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

  TDomElementList = class(TInterfacedObject, IDomElementList)
  private
    FList: IInterfaceList;
  protected
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
  public
    constructor Create;
    destructor Destroy; override;

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

(**Get root DOM element of the Sciter document.
  * \param hSciterWnd \b HWINDOW, Sciter window
  * \return \b #HELEMENT, root element
  * \see also \b #root
  **)
function RootElement(hSciterWnd: HWINDOW): IDomElement;

(**Get focus DOM element of the Sciter document.
  * \param hSciterWnd \b HWINDOW, Sciter window
  * \return \b #HELEMENT, focus element
  *
  * COMMENT: to set focus use: set_state(STATE_FOCUS)
  *
  **)
function FocusElement(hSciterWnd: HWINDOW): IDomElement;

function HighlightElement(hSciterWnd: HWINDOW): IDomElement;

procedure RemoveHighlightion(hSciterWnd: HWINDOW);

(**Find DOM element of the Sciter document by coordinates.
  * \param hSciterWnd \b HWINDOW, Sciter window
  * \param clientPt \b POINT,  coordinates.
  * \return \b #HELEMENT, found element handle or zero
  **)
function FindElement(hSciterWnd: HWINDOW; const clientPt: TPoint): IDomElement;

(**Get element handle by its UID.
  * \param hSciterWnd \b HWINDOW, Sciter window
  * \param uid \b UINT, uid of the element
  * \return \b #HELEMENT, handle of element with the given uid or 0 if not found
  **)
function FindElementByUID(hSciterWnd: HWINDOW; const uid: UINT): IDomElement;

(** create brand new element with text (optional).
  Example:
      element div = element::create("div");
  - will create DIV element,
      element opt = element::create("option",L"Europe");
  - will create OPTION element with text "Europe" in it.
**)
function CreateElement(const TagName: SciterString; const Text: SciterString = ''): IDomElement;

implementation

uses
  SciterApiImpl, SysUtils, Variants, SciterFactoryIntf;

const
  ATTR_Behavior = 'Behavior_353A92E77A1A';
  ATTR_Behavior_Own = 'Behavior_Own_353A92E77A1A';

function RootElement(hSciterWnd: HWINDOW): IDomElement;
begin
  Result := ElementFactory.Create(SAPI.SciterGetRootElement(hSciterWnd));
end;

function FocusElement(hSciterWnd: HWINDOW): IDomElement;
begin
  Result := ElementFactory.Create(SAPI.SciterGetFocusElement(hSciterWnd));
end;

function HighlightElement(hSciterWnd: HWINDOW): IDomElement;
begin
  Result := ElementFactory.Create(SAPI.SciterGetHighlightedElement(hSciterWnd));
end;

procedure RemoveHighlightion(hSciterWnd: HWINDOW);
begin
  SAPI.SciterSetHighlightedElement(hSciterWnd, nil);
end;

function FindElement(hSciterWnd: HWINDOW; const clientPt: TPoint): IDomElement;
begin
  Result := ElementFactory.Create(SAPI.SciterFindElement(hSciterWnd, clientPt));
end;

function FindElementByUID(hSciterWnd: HWINDOW; const uid: UINT): IDomElement;
begin
  Result := ElementFactory.Create(SAPI.SciterGetElementByUID(hSciterWnd, uid));
end;

function CreateElement(const TagName: SciterString; const Text: SciterString): IDomElement;
var
  LElement: TDomElement;
begin
  LElement := TDomElement.Create;
  // don't need 'use' here, as it is already "addrefed"
  LElement.he := SAPI.SciterCreateElement(PAnsiChar(UTF8Encode(TagName)), PWideChar(Text));
  Result := LElement;
end;

{ TDomNode }

constructor TDomNode.CreateFromNode(h: HNODE);
begin
  Use(h);
end;

constructor TDomNode.Create;
begin
  hn := nil;
end;

constructor TDomNode.CreateFromElement(h: HELEMENT);
var
  LElement: IDomElement;
begin
  hn := nil;
  LElement := ElementFactory.Create(h);
  use(LElement.ToNode);
  assert(hn<>nil);
end;

procedure TDomNode.Append(const thatnode: IDomNode);
begin
  SAPI().SciterNodeInsert(hn, NIT_APPEND, thatnode.Node);
end;

function TDomNode.Assign(const n: IDomNode): IDomNode;
begin
  hn := n.Node;
  Result := Self;
end;

function TDomNode.Assign(const n: IDomElement): IDomNode;
begin
  Set_(n.ToNode);
  Result := Self;
end;

function TDomNode.Assign(h: HNODE): IDomNode;
begin
  Set_(h);
  Result := Self;
end;

function TDomNode.Assign(h: HELEMENT): IDomNode;
var
  LDomElement: IDomElement;
begin
  LDomElement := ElementFactory.Create(h);
  
  Set_(LDomElement.ToNode);
  Result := Self;
end;

constructor TDomNode.Create(const n: IDomNode);
begin
  use(n.Node);
end;

constructor TDomNode.Create(const el: IDomElement);
begin
  hn := nil;
  use(el.ToNode);
  assert(hn<>nil);
end;

destructor TDomNode.Destroy;
begin
  unuse;
  inherited;
end;

procedure TDomNode.Detach;
begin
  SAPI().SciterNodeRemove(hn, False);
end;

function TDomNode.Equal(const n: IDomNode): Boolean;
begin
  Result := hn = n.Node;
end;

function TDomNode.Equal(n: HNODE): Boolean;
begin
  Result := hn = n;
end;

function TDomNode.GetChildCount: UINT;
begin
  Result := SAPI.SciterNodeChildrenCount(hn);
end;

function TDomNode.GetFirstChild: IDomNode;
begin
  Result := TDomNode.CreateFromNode(SAPI.SciterNodeFirstChild(hn));
end;

function TDomNode.GetLastChild: IDomNode;
begin
  Result := TDomNode.CreateFromNode(SAPI.SciterNodeLastChild(hn));
end;

function TDomNode.GetNextSibling: IDomNode;
begin
  Result := TDomNode.CreateFromNode(SAPI().SciterNodeNextSibling(hn));
end;

function TDomNode.GetNode: HNODE;
begin
  Result := hn;
end;

function TDomNode.GetParent: IDomElement;
begin
  Result := ElementFactory.Create(SAPI.SciterNodeParent(hn));
end;

function TDomNode.GetPrevSibling: IDomNode;
begin
  Result := TDomNode.CreateFromNode(SAPI().SciterNodePrevSibling(hn));
end;


function TDomNode.GetText: SciterString;
begin
  SAPI.SciterNodeGetText(hn, _LPCWSTR2STRING, @Result);
end;

function TDomNode.Implementor: Pointer;
begin
  Result := Self;
end;

procedure TDomNode.InsertAfter(const thatnode: IDomNode);
begin
  SAPI().SciterNodeInsert(hn,NIT_AFTER,thatnode.Node);
end;

procedure TDomNode.InsertBefore(const thatnode: IDomNode);
begin
  SAPI().SciterNodeInsert(hn,NIT_BEFORE,thatnode.Node);
end;

function TDomNode.IsComment: Boolean;
begin
  Result := SAPI().SciterNodeType(hn) = NT_COMMENT;
end;

function TDomNode.IsElement: Boolean;
begin
  Result := SAPI().SciterNodeType(hn) = NT_ELEMENT;
end;

function TDomNode.IsText: Boolean;
begin
  Result := SAPI().SciterNodeType(hn) = NT_TEXT;
end;

function TDomNode.IsValid: Boolean;
begin
  Result := hn <> nil;
end;

class function TDomNode.MakeCommentNode(const text: SciterString): IDomNode;
var
  LNode: TDomNode;
begin
  LNode := TDomNode.Create;
  LNode.hn := SAPI().SciterCreateCommentNode(PWideChar(text), Length(text));
  Result := LNode;
end;

class function TDomNode.MakeTextNode(const text: SciterString): IDomNode;
var
  LNode: TDomNode;
begin
  LNode := TDomNode.Create;
  LNode.hn := SAPI().SciterCreateTextNode(PWideChar(text), Length(text));
  Result := LNode;
end;
                 
procedure TDomNode.Prepend(const thatnode: IDomNode);
begin
  SAPI().SciterNodeInsert(hn, NIT_PREPEND, thatnode.Node);
end;

procedure TDomNode.Remove;
begin
  SAPI().SciterNodeRemove(hn, True);
end;

procedure TDomNode.SetNode(const Value: HNODE);
begin
  Set_(Value);
end;

procedure TDomNode.SetText(const Value: SciterString);
begin
  SAPI().SciterNodeSetText(hn, LPCWSTR(Value), Length(Value));
end;

procedure TDomNode.Set_(h: HNODE);
begin
  if h = hn then Exit;
  unuse();
  use(h);
end;

function TDomNode.ToElement: HELEMENT;
begin
  Result := SAPI().SciterNodeCastToElement(hn);
end;

procedure TDomNode.Unuse;
begin
  if hn <> nil then
   SAPI.SciterNodeRelease(hn);
  hn := nil;
end;

procedure TDomNode.Use(h: HNODE);
begin
  hn := nil;
  SAPI.SciterNodeAddRef(h);
  hn := h;
end;

function TDomNode.GetChild(const AIndex: UINT): IDomNode;
begin
  Result := TDomNode.CreateFromNode(SAPI().SciterNodeNthChild(hn, AIndex));
end;

function TDomNode.ToBool: Boolean;
begin
  Result := hn <> nil;
end;

{ TDomElement }

constructor TDomElement.Create(h: HELEMENT);
begin
  use(h);
end;

constructor TDomElement.Create;
begin
  he := nil;
end;

function TDomElement.Assign(h: HELEMENT): IDomElement;
begin
  Set_(h);
  Result := Self;
end;

function TDomElement.Assign(const n: IDomElement): IDomElement;
begin
  Set_(n.Element);
  Result := Self;
end;

constructor TDomElement.Create(const e: IDomNode);
begin
  use(e.ToElement);
end;

constructor TDomElement.Create(const e: IDomElement);
begin
  use(e.Element)
end;

destructor TDomElement.Destroy;
begin
  Unuse;
  inherited;
end;

function TDomElement.GetElement: HELEMENT;
begin
  Result := he;
end;

function TDomElement.Implementor: Pointer;
begin
  Result := Self;
end;

procedure TDomElement.SetElement(const Value: HELEMENT);
begin
  Set_(Value);
end;

procedure TDomElement.Set_(h: HELEMENT);
begin
  unuse();
  use(h);
end;

function TDomElement.ToBool: Boolean;
begin
  Result := he <> nil;
end;

function TDomElement.ToNode: HNODE;
begin
  Result := SAPI().SciterNodeCastFromElement(he);
end;

procedure TDomElement.Unuse;
begin
  if he <> nil then
    SAPI().Sciter_UnuseElement(he);
  he := nil;
end;

procedure TDomElement.Use(h: HELEMENT);
begin
  he := nil;
  SAPI().Sciter_UseElement(h);
  he := h;
end;

function TDomElement.Equal(n: HELEMENT): Boolean;
begin
  Result := he = n;
end;

function TDomElement.Equal(const n: IDomElement): Boolean;
begin
  if n = nil then
  begin
    Result := False;
    Exit;
  end;
  Result := Integer(he) = Integer(n.Element);
end;

function TDomElement.IsValid: Boolean;
begin
  Result := he <> nil;
end;

function TDomElement.GetChild(const AIndex: UINT): IDomElement;
begin
  Result := TDomElement.Create(SAPI.SciterGetNthChild(he, AIndex));
end;

function TDomElement.GetChildCount: UINT;
begin
  Result := SAPI.SciterGetChildrenCount(he);
end;

function TDomElement.GetParent: IDomElement;
var
  LResult: HELEMENT;
begin
  if SAPI.SciterGetParentElement(he, LResult) = 0 then
    Result := TDomElement.Create(LResult)
  else
    Result := nil;
end;

function TDomElement.GetIndex: Integer;
begin
  Result := SAPI.SciterGetElementIndex(he);
end;

function TDomElement.GetAttributeCount: UINT;
begin
  Result := SAPI.SciterGetAttributeCount(he);
end;

function TDomElement.GetAttributeByIndex(const AIndex: UINT): SciterString;
begin
  SAPI.SciterGetNthAttributeValueCB(he, AIndex, _LPCWSTR2STRING, @Result);
end;

function TDomElement.GetAttributeName(const AIndex: UINT): SciterString;
begin
  SAPI.SciterGetNthAttributeNameCB(he, AIndex, _LPCSTR2String, @Result);
end;

function TDomElement.GetAttributes(const AName: SciterString): SciterString;
begin
  if SAPI.SciterGetAttributeByNameCB(he, LPCSTR(AnsiString(AName)), _LPCWSTR2STRING, @Result) <> 0 then
    Result := '';
end;

procedure TDomElement.SetAttributes(const AName, Value: SciterString);
begin
  SAPI.SciterSetAttributeByName(he, LPCSTR(UTF8Encode(AName)), PWideChar(Value));
end;

procedure TDomElement.RemoveAttribute(const AName: SciterString);
begin
  SAPI.SciterSetAttributeByName(he, LPCSTR(UTF8Encode(AName)), nil);
end;

function TDomElement.GetStyle(
  const AName: SciterString): SciterString;
begin
  if SAPI.SciterGetStyleAttributeCB(he, LPCSTR(UTF8Encode(AName)), _LPCWSTR2STRING, @Result) <> 0 then
    Result := '';
end;

procedure TDomElement.SetStyle(const AName, Value: SciterString);
begin
  if SAPI.SciterSetStyleAttribute(he, LPCSTR(UTF8Encode(AName)), PWideChar(Value)) <> 0 then
    Log('style: '+AName+' set failed!');
end;

procedure TDomElement.SetCapture;
begin
  SAPI.SciterSetCapture(he);
end;

procedure TDomElement.ReleaseCapture;
begin
  SAPI.SciterReleaseCapture(he);
end;

function _callback_func(he: HELEMENT; param: LPVOID): BOOL; stdcall;
var
  pcall: TElementSelectCallback;
begin
  pcall := TElementSelectCallback(param);
  Result := pcall(he);
end;
  
procedure TDomElement.SelectElements(const selectors: SciterString;
  pcall: TElementSelectCallback);
begin
  SAPI.SciterSelectElements(he, LPCSTR(UTF8Encode(selectors)), _callback_func, @pcall);
end;

function _FirstCallback(hfe: HELEMENT; param: Pointer): BOOL stdcall;
begin
  PHELEMENT(param)^ := hfe;
  Result := True; // stop enum
end;

function TDomElement.FindFirst(const selectors: SciterString; Args: array of const): IDomElement;
begin
  Result := FindFirst(WideFormat(selectors, Args));
end;

procedure TDomElement.FindAll(pcall: TElementSelectCallback;
  const selectors: SciterString; Args: array of const);
begin
  SelectElements(WideFormat(selectors, Args), pcall);
end;

function TDomElement.GetElementById(const AId: SciterString): IDomElement;
begin
  if AId = ''  then
    Result := nil
  else
    Result := FindFirst('[id="%s"]', [AId])
end;

procedure TDomElement.Update(render_now: Boolean);
begin
  SAPI.SciterUpdateElement(he, render_now);
end;

procedure TDomElement.Refresh(const rc: TRect);
begin
  SAPI.SciterRefreshElementArea(he, rc);
end;

procedure TDomElement.Refresh;
var
  rc: TRect;
begin
  rc := GetLocation(SELF_RELATIVE or CONTENT_BOX);
  Refresh( rc );
end;

function TDomElement.GetLocation(area: UINT): TRect;
begin
  SAPI.SciterGetElementLocation(he,Result, area);
end;

function TDomElement.First: IDomElement;
var
  pel: IDomElement;
begin
  pel := GetParent;

  if pel.IsValid then
    Result := pel.Child[0]
  else
    Result := nil;
end;

function TDomElement.Last: IDomElement;
var
  pel: IDomElement;
begin
  pel := GetParent;

  if pel.IsValid then
    Result := pel.Child[pel.ChildCount-1]
  else
    Result := nil;
end;

function TDomElement.Next: IDomElement;
var
  idx: UINT;
  pel: IDomElement;
begin
  idx := GetIndex + 1;
  pel := GetParent;
  if pel.IsValid and (idx < pel.ChildCount) then
    Result := pel.Child[idx]
  else
    Result := nil;
end;

function TDomElement.Prior: IDomElement;
var
  idx: Integer;
  pel: IDomElement;
begin
  idx := GetIndex - 1;
  pel := GetParent;
  if pel.IsValid and (idx >= 0) then
    Result := pel.Child[idx]
  else
    Result := nil;
end;

function TDomElement.Root: IDomElement;
var
  pel: IDomElement;
begin
  pel := GetParent;

  if (pel <> nil) and pel.IsValid and (LowerCase(pel.Tag) <> 'html') then
    Result := pel.Root
  else
    Result := TDomElement.Create(he);
end;

function TDomElement.IsInside(const client_pt: TPoint): Boolean;
var
  rc: TRect;
begin
  rc := GetLocation(ROOT_RELATIVE or BORDER_BOX);
  Result :=
          (client_pt.x >= rc.left)
      and (client_pt.x <  rc.right)
      and (client_pt.y >= rc.top)
      and (client_pt.y <  rc.bottom);
end;

procedure TDomElement.ScrollToView(toTopOfView, smooth: Boolean);
var
  flag: UINT;
begin
  flag := 0;
  if toTopOfView then
    flag := flag or SCROLL_TO_TOP;
  if smooth then
    flag := flag or SCROLL_SMOOTH;
  SAPI.SciterScrollToView(he, flag);
end;

function TDomElement.GetScrollInfo: TDomElementScrollInfo;
begin
  SAPI.SciterGetScrollInfo(he, Result.scroll_pos, Result.view_rect, Result.content_size);
end;

function TDomElement.GetScrollPos: TPoint;
begin
  Result := GetScrollInfo.scroll_pos;
end;

procedure TDomElement.SetScrollPos(const Value: TPoint);
begin
  SAPI.SciterSetScrollPos(he, Value, True);
end;

function TDomElement.GetIntrinsicHeight(for_width: Integer): Integer;
begin
  Result := SAPI.SciterGetElementIntrinsicHeight(he, for_width);
end;

procedure TDomElement.GetIntrinsicWidths(var min_width,
  max_width: Integer);
begin
  SAPI.SciterGetElementIntrinsicWidths(he, min_width, max_width);
end;

function TDomElement.GetElementType: SciterString;
begin
  SAPI.SciterGetElementTypeCB(he, _LPCSTR2String, @Result);
end;

function TDomElement.GetTag: SciterString;
begin
  Result := GetElementType;
end;

function TDomElement.GetElementHwnd(root_window: Boolean): HWINDOW;
begin
  if he = nil then
    Result := 0
  else
    SAPI.SciterGetElementHwnd(he, Result, root_window);
end;

procedure TDomElement.AttachHwnd(child: HWINDOW);
begin
  SAPI.SciterAttachHwndToElement(he, child);
end;

function TDomElement.GetUID: UINT;
begin
  Result := SAPI.SciterGetElementUID(he);
end;

function TDomElement.CombineURL(const aGivenUrl: SciterString;
  const ABufferSize: UINT): SciterString;
var
  pResult: PWideChar;
begin
  pResult := AllocMem(ABufferSize);
  try
    CopyMemory(pResult, PWideChar(aGivenUrl), (Length(aGivenUrl)+1)*2);
    SAPI.SciterCombineURL(he, pResult, ABufferSize);
    Result := pResult;
  finally
    FreeMem(pResult);
  end;
end;

function TDomElement.CombineURL(const aRelativeUrl: SciterString): SciterString;
begin
  Result := CombineURL(aRelativeUrl, 4096);
end;

function TDomElement.GetHtml: SciterString;
begin
  Result := GetHtmlEx(False);
end;

procedure TDomElement.SetHtml(const Value: SciterString);
begin
  SetHtmlEx(Value, SIH_REPLACE_CONTENT);
end;

function TDomElement.GetHtmlEx(outer: Boolean): SciterString;
var
  sResult: TBytes;
begin
  SAPI.SciterGetElementHtmlCB(he, outer, _LPCBYTE2ASTRING, @sResult);
  Result := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(PAnsiChar(@sResult));
end;

procedure TDomElement.SetHtmlEx(const html: SciterString;
  where: TSetElementHtml);
var
  sHtml: string;
begin
  sHtml := html;
  SAPI.SciterSetElementHtml(he, PByte(sHtml), Length(sHtml), where);
end;

function TDomElement.GetText: SciterString;
begin
  SAPI.SciterGetElementTextCB(he, _LPCWSTR2STRING, @Result);
end;

procedure TDomElement.SetText(const Value: SciterString);
begin
  SAPI.SciterSetElementText(he, PWideChar(Value), Length(Value));
end;

procedure TDomElement.Clear;
begin
  SAPI.SciterSetElementText(he, nil, 0);
end;

procedure TDomElement.ClearAttribute;
begin
  SAPI.SciterClearAttributes(he);
end;


function TDomElement.FindNearestParent(const selectors: SciterString;
  Args: array of const; depth: UINT): IDomElement;
var
  sSel: UTF8String;
begin
  sSel := UTF8Encode(Format(selectors, Args));
  Result := TDomElement.Create(SAPI.SciterSelectParent(he, PAnsiChar(sSel), depth));
end;

function TDomElement.FindNearestParent(const selectors: SciterString;
  depth: UINT): IDomElement;
var
  sSel: UTF8String;
begin
  sSel := UTF8Encode(selectors);
  Result := TDomElement.Create(SAPI.SciterSelectParent(he, PAnsiChar(sSel), depth));
end;

function TDomElement.Match(const selectors: SciterString; Args: array of const): Boolean;
var
  sSel: UTF8String;
begin
  sSel := UTF8Encode(Format(selectors, Args));
  Result := SAPI.SciterSelectParent(he, PAnsiChar(sSel), 1) <> nil;
end;

function TDomElement.GetState: UINT;
begin
  Result := SAPI.SciterGetElementState(he);
end;

function TDomElement.TestState(bits: UINT): Boolean;
begin
  Result := (GetState and bits) <> 0;
end;

procedure TDomElement.SetStateEx(bitsToSet, bitsToClear: UINT; update: Boolean);
begin
  SAPI.SciterSetElementState(he, bitsToSet, bitsToClear, update);
end;

procedure TDomElement.ChangeState(bitsToSet: UINT; update: Boolean);
begin
  SetStateEx(bitsToSet, 0, update);
end;

procedure TDomElement.ClearState(bitsToClear: UINT; update: Boolean);
begin
  SetStateEx(0, bitsToClear, update);
end;

procedure TDomElement.SetState(const Value: UINT);
begin
  SetStateEx(Value, $FFFFFFFF);
end;

function TDomElement.GetEnable: Boolean;
begin
  Result := SAPI.SciterIsElementEnabled(he);
end;

function TDomElement.GetVisible: Boolean;
begin
  Result := SAPI.SciterIsElementVisible(he);
end;

procedure TDomElement.StartTimer(ms: UINT; timer_id: UINT_PTR);
begin
  SAPI.SciterSetTimer(he, ms, timer_id);
end;

procedure TDomElement.StopTimer(timer_id: UINT_PTR);
begin
  SAPI.SciterSetTimer(he, 0, timer_id);
end;

function TDomElement.Clone: IDomElement;
var
  LElement: TDomElement;
begin
  LElement := TDomElement.Create(nil);
  LElement.he := SAPI.SciterCloneElement(he);
  Result := LElement;
end;

procedure TDomElement.Insert(const e: IDomElement; index: UINT);
begin
  SAPI.SciterInsertElement(e.Element, he, index);
end;

procedure TDomElement.Append(const e: IDomElement);
begin
  Insert(e, $7FFFFFFF);
end;

procedure TDomElement.Detach;
begin
  SAPI.SciterDetachElement(he);
end;

procedure TDomElement.Delete;
var
  t: HELEMENT;
begin
  if he = nil then Exit;
  t  := he;
  he := nil;
  SAPI.SciterDeleteElement(t);
end;

procedure TDomElement.Swap(eWith: IDomElement);
begin
  SAPI.SciterSwapElements(he, eWith.Element);
end;

function TDomElement.SendEvent(event_code, reason: UINT;
  heSource: IDomElement): Boolean;
begin
  if heSource = nil then
    Result := SAPI.SciterSendEvent(he, event_code, he, reason)
  else
    Result := SAPI.SciterSendEvent(he, event_code, heSource.Element, reason);
end;

procedure TDomElement.PostEvent(event_code, reason: UINT;
  heSource: IDomElement);
begin
  if heSource = nil then
    SAPI.SciterPostEvent(he, event_code, he, reason)
  else
    SAPI.SciterPostEvent(he, event_code, heSource.Element, reason);
end;

function TDomElement.FireEvent(const evt: TBehaviorEventParams;
  post: Boolean): Boolean;
begin
  Result := SAPI.SciterFireEvent(evt, post);
end;

function TDomElement.CallBehaviorMethod(const p: PMethodParams): Boolean;
begin
  if IsValid then
    Result := False
  else
    Result := SAPI.SciterCallBehaviorMethod(he, p) = SCDOM_OK;
end;

procedure TDomElement.LoadData(const url: SciterString; dataType: SciterResourceType;
  initiator: IDomElement);
var
  sUrl: SciterString;
begin
  try
    sUrl := EncodeURI(url);
    if initiator <> nil then
      SAPI.SciterRequestElementData(he, PWideChar(sUrl), dataType, initiator.Element)
    else
      SAPI.SciterRequestElementData(he, PWideChar(sUrl), dataType, nil)
  except
    on E: Exception do
      Trace('[TDomElement.LoadData]'+E.Message);
  end;
end;

procedure TDomElement.LoadHtml(const url: SciterString; initiator: IDomElement);
begin
  LoadData(url, RT_DATA_HTML, initiator);
end;

procedure TDomElement.Sort(cmp: TElementComparator; param: LPVOID; AStart,
  AEnd: Integer);
begin
  SAPI.SciterSortElements(he, AStart, AEnd, cmp, param);
end;

procedure TDomElement.AttachEventHandler(
  const p_event_handler: IBehaviorEventHandler);
begin
  SAPI.SciterAttachEventHandler(he, SciterBehaviorDef._element_proc, Pointer(p_event_handler));
end;

procedure TDomElement.DetachEventHandler(const p_event_handler: IBehaviorEventHandler);
begin
  SAPI.SciterDetachEventHandler(he, SciterBehaviorDef._element_proc, Pointer(p_event_handler));
end;

function TDomElement.CallMethod(const name: SciterString; const argv: array of IDomValue): IDomValue;
var
  LArgv: SCITER_VALUE_ARRAY;
  pArgv: PSCITER_VALUE_ARRAY;
  i: Integer;
begin
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
  SAPI.SciterCallScriptingMethod(he, PAnsiChar(UTF8Encode(name)), pArgv, System.Length(argv), Result.Value^);
end;

function TDomElement.CallMethod(const name: SciterString): IDomValue;
begin
  Result := CallMethod(name, []);
end;

function TDomElement.CallFunction(const name: SciterString; const argv: array of IDomValue): IDomValue;
var
  LArgv: SCITER_VALUE_ARRAY;
  pArgv: PSCITER_VALUE_ARRAY;
  i: Integer;
begin
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
  SAPI.SciterCallScriptingFunction(he, PAnsiChar(UTF8Encode(name)), pArgv, System.Length(argv), Result.Value^);
end;

function TDomElement.CallFunction(const name: SciterString): IDomValue;
begin
  CallFunction(name, []);
end;

function TDomElement.Eval(const script: SciterString): OleVariant;
var
  pVal: SCITER_VALUE;
  pResult: OleVariant;
begin
  SAPI.ValueInit(pVal); 
  if SAPI.SciterEvalElementScript(he, PWideChar(script), Length(script), pVal) = SCDOM_OK  then
    S2V(pVal, pResult, SAPI.SciterGetVM(Self.GetElementHwnd()))
  else
    pResult := Unassigned;
  Result := pResult;
end;

function TDomElement.Eval(const script: SciterString;
  const Args: array of const): OleVariant;
begin
  Result := Eval(WideFormat(script, Args));
end;

function TDomElement.GetControlType: TControlType;
begin
  Result := SAPI.SciterControlGetType(he);
end;

function TDomElement.GetValue: IDomValue;
begin
  Result := ValueFactory.Create;
  SAPI.SciterGetValue(he, Result.Value^);
end;

procedure TDomElement.SetValue(const Value: IDomValue);
begin
  SAPI.SciterSetValue(he, Value.Value^);
end;

function TDomElement.GetExpando(force_create: Boolean): IDomValue;
begin
  Result := ValueFactory.Create;
  SAPI.SciterGetExpando(he, Result.Value^, force_create);
end;

function TDomElement.GetObject(force_create: Boolean): tiscript_value;
begin
  SAPI.SciterGetObject(he, Result, force_create);
end;

function TDomElement.GetNamespace: tiscript_value;
begin
  Result := SAPI.SciterGetElementNamespace(he);
end;

procedure TDomElement.Highlight;
var
  hwnd: HWINDOW;
begin
  hwnd := GetElementHwnd(true);
  SetHighlighted(hwnd);
end;

procedure TDomElement.SetHighlighted(hSciterWnd: HWINDOW);
begin
  SAPI.SciterSetHighlightedElement(hSciterWnd,he);
end;

procedure TDomElement.Popup(const heAnchor: IDomElement;
  placement: UINT);
begin
  SAPI.SciterShowPopup(he, heAnchor.Element, placement)
end;

procedure TDomElement.PopupAt(const heAnchor: IDomElement; const pos: TPoint; animate: Boolean);
//var
//  sScript: SciterString;
begin
//  sScript := Format('$(%s).popup($(%s), %d, %d);', [heAnchor.UniqueSelector, Self.UniqueSelector, pos.X, pos.Y]);
//  Self.Eval(sScript);

  SAPI.SciterShowPopupAt(he, pos, animate)
end;

procedure TDomElement.HidePopup;
begin
  SAPI.SciterHidePopup(he);
end;


function TDomElement.GetID: SciterString;
begin
  Result := GetAttributes('ID');
end;

procedure TDomElement.SetID(const Value: SciterString);
begin
  SetAttributes('ID', Value);
end;

function TDomElement.GetOuterHtml: SciterString;
begin
  Result := GetHtmlEx(True);
end;

procedure TDomElement.SetOuterHtml(const Value: SciterString);
begin
  SetHtmlEx(Value, SOH_REPLACE);
end;

function TDomElement.FindFirst(const selectors: SciterString): IDomElement;
var
  e: HELEMENT;
begin
  Result := nil;
  e := nil;
  SAPI.SciterSelectElementsW(he, PWideChar(selectors), _FirstCallback, @e);
  if e <> nil  then
    Result := TDomElement.Create(e);
end;

function TDomElement.IsChild(const p: IDomElement): Boolean;
var
  p1: IDomElement;
begin
  p1 := GetParent;

  if (p = nil) or (p1 = nil) then
  begin
    Result := False;
    Exit;
  end;

  while (p1 <> nil) do
  begin
    if p1.Equal(p) then
    begin
      Result := True;
      Exit;
    end;
    p1 := p1.Parent;
  end;

  Result := False;
end;

function TDomElement.IsParent(const c: IDomElement): Boolean;
begin
  if c = nil then
  begin
    Result := False;
    Exit;
  end;
  Result := c.IsChild(Self);
end;

function TDomElement.CreateElement(const TagName,
  Text: SciterString): IDomElement;
begin
  Result := SciterDom.CreateElement(TagName, Text);
end;

function TDomElement.GetElementByUID(const AUID: UINT): IDomElement;
var
  he: HELEMENT;
begin
  he := SAPI.SciterGetElementByUID(GetElementHwnd, AUID);
  if he = nil then
    Result := nil
  else
    Result := TDomElement.Create(he);
end;

procedure TDomElement.Request(const url: SciterString; dataType: SciterResourceType;
  requestType: TRequestType; const requestParams: TRequestParamArray);
begin
  SAPI.SciterHttpRequest(he, PWideChar(url), dataType, requestType, @requestParams, Length(requestParams))
end;

procedure TDomElement.Request(const url: SciterString;
  dataType: SciterResourceType; requestType: TRequestType);
begin
  SAPI.SciterHttpRequest(he, PWideChar(url), dataType, requestType, nil, 0)
end;

function TDomElement.Call(const name: SciterString;
  const Args: array of OleVariant): OleVariant;
var
  pVal: SCITER_VALUE;
  sFunctionName: AnsiString;
  pArgs: array[0..255] of SCITER_VALUE;
  cArgs: Integer;
  i: Integer;
begin
  sFunctionName := AnsiString(name);
  SAPI.ValueInit(pVal);

  cArgs := Length(Args);
  if cArgs > MaxParams then
    raise ESciterException.Create('Too many arguments.');

  for i := Low(pArgs) to High(pArgs) do
    SAPI.ValueInit(pArgs[i]);
  for i := Low(Args) to High(Args) do
    V2S(Args[i], pArgs[i], SAPI.SciterGetVM(Self.GetElementHwnd()));
  if SAPI.SciterCallScriptingMethod(he, PAnsiChar(sFunctionName), @pArgs[0], cArgs, pVal) = SCDOM_OK then
    S2V(pVal, Result, SAPI.SciterGetVM(Self.GetElementHwnd()))
  else
    Result := Unassigned;
end;

function TDomElement.Call(const name: SciterString): OleVariant;
begin
  Result := Call(name, []);
end;

function TDomElement.GetBehavior: IDefalutBehaviorEventHandler;
var
  LBehavior: IDefalutBehaviorEventHandler;
begin
  if (FBehavior = nil) then
  begin
    FBehavior := Pointer(StrToIntDef(GetAttributes(ATTR_Behavior), 0)); 
  end;
  
  if (FBehavior = nil) then
  begin
    LBehavior := TDefalutBehaviorEventHandler.Create(Format('Element_T:%s_I:%s_N:%s', [GetTag, GetID, GetAttributes('name')]), True);
    AttachEventHandler(LBehavior);

    LBehavior._AddRef;
    FBehavior := Pointer(LBehavior);
    
    SetAttributes(ATTR_Behavior, IntToStr(Integer(FBehavior)));
    SetAttributes(ATTR_Behavior_Own, 'true');
  end;
  
  Result := IDefalutBehaviorEventHandler(FBehavior);
end;

procedure TDomElement.SetBehavior(
  const Value: IDefalutBehaviorEventHandler);
begin
  if (FBehavior = nil) then
  begin
    FBehavior := Pointer(StrToIntDef(GetAttributes(ATTR_Behavior), 0)); 
  end;

  if FBehavior = Pointer(Value) then
    Exit;

  if (Value <> nil) and (FBehavior<>nil) and
    (IDefalutBehaviorEventHandler(FBehavior).Implementor = Value.Implementor) then
    Exit;
    
  if (FBehavior <> nil) then
  begin
    DetachEventHandler(IDefalutBehaviorEventHandler(FBehavior));

    if GetAttributes(ATTR_Behavior_Own) <> 'true' then
    begin
      RemoveAttribute(ATTR_Behavior_Own);
      
      IDefalutBehaviorEventHandler(FBehavior)._Release;
    end;

    FBehavior := nil;
  end;

  AttachEventHandler(Value);

  FBehavior := Pointer(Value);

  if FBehavior <> nil then
    SetAttributes(ATTR_Behavior, IntToStr(Integer(FBehavior)))
  else
    RemoveAttribute(ATTR_Behavior);
end;

function TDomElement.GetUniqueSelector: SciterString;
var
  LParent: IDomElement;
begin
  Result := GetTag;
  if GetID <> EmptyStr then
    Result := Result + '#' + GetID
  else
  if SameText(Result, 'html') then
    Exit
  else
    Result := Result + Format(':nth-child(%d)', [GetIndex+1]);
  LParent := GetParent;
  while (LParent <> nil) and (LParent.Tag <> EmptyStr) and (LParent.Tag <> 'html') do
  begin
    Result := LParent.Tag + ' > ' + Result;
    LParent := LParent.Parent;
  end;
end;

function TDomElement.GetHeight: Integer;
var
  rc: TRect;
begin
  rc := GetLocation(SELF_RELATIVE or CONTENT_BOX);
  Result := rc.Bottom - rc.Top;
end;

function TDomElement.GetWidth: Integer;
var
  rc: TRect;
begin
  rc := GetLocation(SELF_RELATIVE or CONTENT_BOX);
  Result := rc.Right - rc.Left;
end;

function TDomElement.GetLeft: Integer;
var
  rc: TRect;
begin
  rc := GetLocation(ROOT_RELATIVE or CONTENT_BOX);
  Result := rc.Left;
end;

function TDomElement.GetTop: Integer;
var
  rc: TRect;
begin
  rc := GetLocation(ROOT_RELATIVE or CONTENT_BOX);
  Result := rc.Top;
end;

function TDomElement.IndexOfAttribute(const AName: SciterString): Integer;
var
  sName: SciterString;
begin
  for Result := 0 to AttributeCount - 1 do
  begin
    sName := GetAttributeName(Result);
    if WideSameText(sName, AName) then
      Exit;
  end;
  Result := -1;
end;

function TDomElement.HasAttribute(const AName: SciterString): Boolean;
begin
  Result := IndexOfAttribute(AName) >= 0;
end;

function TDomElement.GetVM: HVM;
begin
  Result := SAPI.SciterGetVM(Self.GetElementHwnd());
end;

procedure TDomElement.Hide;
begin
  SetStyle('visibility', 'none');
end;

procedure TDomElement.Show;
begin
  SetStyle('visibility', 'visible');
end;

{ TDomElementList }

function TDomElementList.Add(const AItem: IDomElement): Integer;
begin
  Result := FList.Add(AItem)
end;

procedure TDomElementList.Clear;
begin
  FList.Clear;
end;

constructor TDomElementList.Create;
begin
  FList := TInterfaceList.Create;
end;

procedure TDomElementList.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TDomElementList.Destroy;
begin
  Clear;
  FList := nil;
  inherited;
end;

function TDomElementList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDomElementList.GetItem(const Index: Integer): IDomElement;
begin
  Result := FList[Index] as IDomElement;
end;

function TDomElementList.GetItemByID(const AID: SciterString): IDomElement;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    Result := GetItem(i);
    if WideSameText(Result.ID, AID) then
      Exit;
  end;
  Result := nil;
end;

function TDomElementList.GetItemByName(
  const AName: SciterString): IDomElement;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    Result := GetItem(i);
    if WideSameText(Result.Attributes['name'], AName) then
      Exit;
  end;
  Result := nil;
end;

function TDomElementList.GetItemByTag(const ATag: SciterString): IDomElement;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    Result := GetItem(i);
    if WideSameText(Result.Tag, ATag) then
      Exit;
  end;
  Result := nil;
end;

function TDomElementList.GetItemByUID(const AUID: UINT): IDomElement;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    Result := GetItem(i);
    if Result.UID = AUID then
      Exit;
  end;
  Result := nil;
end;

function TDomElementList.IndexOf(const AItem: IDomElement): Integer;
begin
  Result := IndexOf(AItem);
end;

function TDomElementList.IndexOfID(const AID: SciterString): Integer;
begin
  for Result := 0 to FList.Count - 1 do
  begin
    if WideSameText(GetItem(Result).ID, AID) then
      Exit;
  end;
  Result := -1;
end;

function TDomElementList.IndexOfName(const AName: SciterString): Integer;
begin
  for Result := 0 to FList.Count - 1 do
  begin
    if WideSameText(GetItem(Result).Attributes['name'], AName) then
      Exit;
  end;
  Result := -1;
end;

function TDomElementList.IndexOfTag(const ATag: SciterString): Integer;
begin
  for Result := 0 to FList.Count - 1 do
  begin
    if WideSameText(GetItem(Result).Tag, ATag) then
      Exit;
  end;
  Result := -1;
end;

function TDomElementList.IndexOfUID(const AUID: UINT): Integer;
begin
  for Result := 0 to FList.Count - 1 do
  begin
    if GetItem(Result).UID = AUID then
      Exit;
  end;
  Result := -1;
end;

procedure TDomElementList.Insert(const Index: Integer;
  const AItem: IDomElement);
begin
  FList.Insert(Index, AItem);
end;

procedure TDomElementList.SetItem(const Index: Integer;
  const Value: IDomElement);
begin
  FList[Index] := Value;
end;

procedure TDomElementList.SetItemByID(const AID: SciterString;
  const Value: IDomElement);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if WideSameText(GetItem(i).ID, AID) then
    begin
      SetItem(i, Value);
      Exit;
    end;
  end;
end;

procedure TDomElementList.SetItemByName(const AName: SciterString;
  const Value: IDomElement);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if WideSameText(GetItem(i).Attributes['name'], AName) then
    begin
      SetItem(i, Value);
      Exit;
    end;
  end;
end;

procedure TDomElementList.SetItemByTag(const ATag: SciterString;
  const Value: IDomElement);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if WideSameText(GetItem(i).Tag, ATag) then
    begin
      SetItem(i, Value);
      Exit;
    end;
  end;
end;

procedure TDomElementList.SetItemByUID(const AUID: UINT;
  const Value: IDomElement);
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if GetItem(i).UID = AUID then
    begin
      SetItem(i, Value);
      Exit;
    end;
  end;
end;

{ TDomNodeList }

function TDomNodeList.Add(const AItem: IDomNode): Integer;
begin
  Result := FList.Add(AItem)
end;

procedure TDomNodeList.Clear;
begin
  FList.Clear;
end;

constructor TDomNodeList.Create;
begin
  FList := TInterfaceList.Create;
end;

procedure TDomNodeList.Delete(const Index: Integer);
begin
  FList.Delete(Index);
end;

destructor TDomNodeList.Destroy;
begin
  Clear;
  FList := nil;
  inherited;
end;

function TDomNodeList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDomNodeList.GetItem(const Index: Integer): IDomNode;
begin
  Result := FList[index] as IDomNode;
end;

function TDomNodeList.IndexOf(const AItem: IDomNode): Integer;
begin
  Result := FList.IndexOf(AItem)
end;

procedure TDomNodeList.Insert(const Index: Integer; const AItem: IDomNode);
begin
  FList.Insert(Index, AItem);
end;

procedure TDomNodeList.SetItem(const Index: Integer;
  const Value: IDomNode);
begin
  FList[Index] := Value;
end;

end.
