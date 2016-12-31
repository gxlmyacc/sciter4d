{*******************************************************************************
 标题:     SciterBehavior.pas
 描述:     行为 基类
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterBehavior;

interface

{$I Sciter.inc}

uses
  SysUtils, Windows, SciterTypes, SciterIntf;

type
{$M+}
{$METHODINFO ON}
  TBehaviorEventHandlerClass = class of TBehaviorEventHandler;
  
  TBehaviorEventHandler = class(TInterfacedObject, IBehaviorEventHandler)
  private
    FDestroying: Boolean;
    FEventHandler: IDefalutBehaviorEventHandler;
    FThis: IDomElement;
    FSuper: IDefalutBehaviorEventHandler;
  protected
    function  GetThis: IDomElement; virtual;
    function  GetSuper: IDefalutBehaviorEventHandler;
    function  GetDestroying: Boolean; virtual;
    function  GetLayout: ISciterLayout; virtual;
    function  GetRttiObject: IDispatchRttiObject; virtual;
    procedure SetSuper(const Value: IDefalutBehaviorEventHandler);
    procedure SetLayout(const Value: ISciterLayout); virtual;
    procedure SetRttiObject(const Value: IDispatchRttiObject); virtual;
        
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    function DoScriptCallTs(const he: IDomElement; pvm: Ptiscript_VM; const name: PWideChar;
      var retval: tiscript_value): Boolean; virtual;
  protected
    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;
    function  IsType(event, event_type: UINT): Boolean;

    function AddBeforeWndProc: Integer;
    function RemoveBeforeWndProc: Integer;

    function AddAfterWndProc: Integer;
    function RemoveAfterWndProc: Integer;

    procedure OnAttached(const he: IDomElement); virtual;
    procedure OnDetached(const he: IDomElement); virtual;
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; virtual;

    function  OnMouse(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseLeave(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseWheel(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseTick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnMouseIdle(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;

    function  OnDrop(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnDragEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnDragLeave(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnDragRequest(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;
    function  OnDragging(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; virtual;

    function  OnKey(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; virtual;
    function  OnKeyDown(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; virtual;
    function  OnKeyUp(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; virtual;
    function  OnKeyChar(const he, target: IDomElement; event_type: UINT; var params: TKeyParams): Boolean; virtual;

    function  OnFocus(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; virtual;
    function  OnFocusGot(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; virtual;
    function  OnFocusLost(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; virtual;
    function  OnFocusIn(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; virtual;
    function  OnFocusOut(const he, target: IDomElement; event_type: UINT{FOCUS_EVENTS}; var params: TFocusParams): Boolean; virtual;
    function  OnTimer(const he: IDomElement): Boolean; virtual;
    function  OnTimerEx(const he: IDomElement; extTimerId: UINT_PTR): Boolean; virtual;
    function  OnDraw(const he: IDomElement; draw_type: UINT{DRAW_EVENTS}; var params: TDrawParams): Boolean; virtual;
    procedure OnSize(const he: IDomElement); virtual;
    function  OnMethodCall(const he: IDomElement; methodID: TBehaviorMethodIdentifier; params: PMethodParams): Boolean; virtual;
    function  OnScriptCallTs(const he: IDomElement; pvm: Ptiscript_VM; const name: PWideChar; var retval: tiscript_value): Boolean; virtual;

    function  OnEvent(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnChange(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnButtonPress(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnButtonStateChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnEditValueChanging(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnEditValueChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    
    function  OnSelectSelectionChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnSelectStateChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnRequestTooltip(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnPopupRequest(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnPopupReady(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnPopupDismissing(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnPopupDismissed(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnClosePopup(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnMenuItemActive(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnMenuItemClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnContextMenuRequest(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnVisiualStatusChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnDisabledStatusChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnContentChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnHyperlinkClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnElementCollapsed(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnElementExpanded(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnActivateChild(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    
    function  OnInitDataView(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnRowsDataRequest(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    
    function  OnUIStateChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    
    function  OnFormSubmit(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnFormReset(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    
    function  OnDocumentCreated(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnDocumentReady(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnDocumentComplete(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnDocumentCloseRequest(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnDocumentClose(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnHistoryPush(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnHistoryDrop(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnHistoryPrior(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnHistoryNext(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnHistoryStateChanged(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnAnimation(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnVideoInitialized(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnVideoStarted(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnVideoStopped(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnVideoBindRQ(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnPaginationStarts(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnPaginationPage(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;
    function  OnPaginationEnds(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean; virtual;

    function  OnDataArrived(const he: IDomElement; initiator: IDomElement; var params: TDataArrivedParams): Boolean; virtual;
    function  OnScroll(const he, target: IDomElement; cmd: UINT{SCROLL_EVENTS}; var params: TScorllParams): Boolean; virtual;
    function  OnGesture(const he, target: IDomElement; cmd: UINT{GESTURE_CMD}; var params: TGestrueParams): Boolean; virtual;
    
    function  DoBeforeWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM; var pbHandled: Boolean): LRESULT; virtual;
    procedure DoAfterWndProc(msg: UINT; wParam: WPARAM; lParam: LPARAM; var Result: LRESULT); virtual;
  public
    constructor Create; overload; virtual;
    constructor Create(const he: IDomElement); overload; virtual; 
    destructor Destroy; override;

    property Layout: ISciterLayout read GetLayout write SetLayout;
    property Super: IDefalutBehaviorEventHandler read GetSuper write SetSuper;
    property This: IDomElement read GetThis;
    property EventHandler: IDefalutBehaviorEventHandler read FEventHandler implements IBehaviorEventHandler;
    property Destroying: Boolean read GetDestroying;

    property RttiObject: IDispatchRttiObject read GetRttiObject write SetRttiObject;
  end;
{$METHODINFO OFF}
{$M-}

  TBehaviorFactory = class(TInterfacedObject, IBehaviorFactory)
  protected
    FName: SciterString;
    FClass: TBehaviorEventHandlerClass;
  protected
    function  GetName: SciterString; virtual;
    procedure SetName(const Value: SciterString); virtual;
  public
    constructor Create(const external_name: SciterString; const AClass: TBehaviorEventHandlerClass); virtual;

    function  Implementator: Pointer;

    // needs to be overriden
    function CreateHandler(const he: IDomElement; const ALayout: ISciterLayout = nil): IBehaviorEventHandler; virtual;

    property Name: SciterString read GetName write SetName;
  end;
  
{$IFNDEF Sciter4D}
var
  SciterGlobalPlugin: Boolean = False;
{$ENDIF}

implementation

uses
  ObjComAutoEx;

var
  varLocalBehaviorCount: Integer = 0;

{$IFNDEF Sciter4D}
function SciterCanUnloadPlugin: Boolean; stdcall;
begin
  Result := (not SciterGlobalPlugin) and (varLocalBehaviorCount <= 0);
end;
exports
  SciterCanUnloadPlugin;
{$ENDIF}

{ TBehaviorEventHandler }

constructor TBehaviorEventHandler.Create(const he: IDomElement);
begin
  InterlockedIncrement(varLocalBehaviorCount);
  FDestroying := False;
//  if Self.ClassName = 'TWinCmdBehavior' then
//    OutputDebugString(PChar('[TBehaviorEventHandler]'+Self.ClassName + ' Create'));

  FThis := he;
  FEventHandler := Sciter.CreateDefalutHandler(Self.ClassName, Self,
    TObjectDispatchEx.Create(TObject(Self), False) as IDispatchRttiObject);

  FEventHandler.OnAttached := OnAttached;
  FEventHandler.OnDetached := OnDetached;
  FEventHandler.OnSubscription := OnSubscription;

  FEventHandler.OnMouse := OnMouse;
  FEventHandler.OnMouseEnter := OnMouseEnter;
  FEventHandler.OnMouseLeave := OnMouseLeave;
  FEventHandler.OnMouseMove := OnMouseMove;
  FEventHandler.OnMouseUp := OnMouseUp;
  FEventHandler.OnMouseDown := OnMouseDown;
  FEventHandler.OnMouseClick := OnMouseClick;
  FEventHandler.OnMouseDClick := OnMouseDClick;
  FEventHandler.OnMouseWheel := OnMouseWheel;
  FEventHandler.OnMouseTick := OnMouseTick;
  FEventHandler.OnMouseIdle := OnMouseIdle;

  FEventHandler.OnDrop := OnDrop;
  FEventHandler.OnDragEnter := OnDragEnter;
  FEventHandler.OnDragLeave := OnDragLeave;
  FEventHandler.OnDragRequest := OnDragRequest;
  FEventHandler.OnDragging := OnDragging;

  FEventHandler.OnKeyDown := OnKeyDown;
  FEventHandler.OnKeyUp := OnKeyUp;
  FEventHandler.OnKeyChar := OnKeyChar;

  FEventHandler.OnFocusGot := OnFocusGot;
  FEventHandler.OnFocusLost := OnFocusLost;
  FEventHandler.OnFocusIn := OnFocusIn;
  FEventHandler.OnFocusOut := OnFocusOut;
  FEventHandler.OnTimer := OnTimer;
  FEventHandler.OnTimerEx := OnTimerEx;
  FEventHandler.OnDraw := OnDraw;
  FEventHandler.OnSize := OnSize;
  FEventHandler.OnMethodCall := OnMethodCall;
  FEventHandler.OnScriptCallTs := DoScriptCallTs;
  FEventHandler.OnEvent := OnEvent;
  FEventHandler.OnClick := OnClick;
  FEventHandler.OnChange := OnChange;
  FEventHandler.OnButtonClick := OnButtonClick;
  FEventHandler.OnButtonPress := OnButtonPress;
  FEventHandler.OnButtonStateChanged := OnButtonStateChanged;
  FEventHandler.OnEditValueChanging := OnEditValueChanging;
  FEventHandler.OnEditValueChanged := OnEditValueChanged;
  FEventHandler.OnSelectSelectionChanged := OnSelectSelectionChanged;
  FEventHandler.OnSelectStateChanged := OnSelectStateChanged;
  FEventHandler.OnRequestTooltip := OnRequestTooltip;
  FEventHandler.OnPopupRequest := OnPopupRequest;
  FEventHandler.OnPopupReady := OnPopupReady;
  FEventHandler.OnPopupDismissing := OnPopupDismissing;
  FEventHandler.OnPopupDismissed := OnPopupDismissed;
  FEventHandler.OnClosePopup := OnClosePopup;
  FEventHandler.OnMenuItemActive := OnMenuItemActive;
  FEventHandler.OnMenuItemClick := OnMenuItemClick;
  FEventHandler.OnContextMenuRequest := OnContextMenuRequest;
  FEventHandler.OnVisiualStatusChanged := OnVisiualStatusChanged;
  FEventHandler.OnDisabledStatusChanged := OnDisabledStatusChanged;
  FEventHandler.OnContentChanged := OnContentChanged;
  FEventHandler.OnHyperlinkClick := OnHyperlinkClick;
  FEventHandler.OnElementCollapsed := OnElementCollapsed;
  FEventHandler.OnElementExpanded := OnElementExpanded;
  FEventHandler.OnActivateChild := OnActivateChild;
  FEventHandler.OnInitDataView := OnInitDataView;
  FEventHandler.OnRowsDataRequest := OnRowsDataRequest;
  FEventHandler.OnUIStateChanged := OnUIStateChanged;
  FEventHandler.OnFormSubmit := OnFormSubmit;
  FEventHandler.OnFormReset := OnFormReset;
  FEventHandler.OnDocumentCreated := OnDocumentCreated;
  FEventHandler.OnDocumentReady := OnDocumentReady;
  FEventHandler.OnDocumentComplete := OnDocumentComplete;
  FEventHandler.OnDocumentCloseRequest := OnDocumentCloseRequest;
  FEventHandler.OnDocumentClose := OnDocumentClose;
  FEventHandler.OnHistoryPush := OnHistoryPush;
  FEventHandler.OnHistoryDrop := OnHistoryDrop;
  FEventHandler.OnHistoryPrior := OnHistoryPrior;
  FEventHandler.OnHistoryNext := OnHistoryNext;
  FEventHandler.OnHistoryStateChanged := OnHistoryStateChanged;
  FEventHandler.OnAnimation := OnAnimation;
  FEventHandler.OnVideoInitialized := OnVideoInitialized;
  FEventHandler.OnVideoStarted := OnVideoStarted;
  FEventHandler.OnVideoStopped := OnVideoStopped;
  FEventHandler.OnVideoBindRQ := OnVideoBindRQ;
  FEventHandler.OnPaginationStarts := OnPaginationStarts;
  FEventHandler.OnPaginationPage := OnPaginationPage;
  FEventHandler.OnPaginationEnds := OnPaginationEnds;
  FEventHandler.OnDataArrived := OnDataArrived;
  FEventHandler.OnScroll := OnScroll;
  FEventHandler.OnGesture := OnGesture;
  FEventHandler.BeforeWndProc := DoBeforeWndProc;
  FEventHandler.AfterWndProc := DoAfterWndProc;
end;

destructor TBehaviorEventHandler.Destroy;
begin
//  if Self.ClassName = 'TWinCmdBehavior' then
//    OutputDebugString(PChar('[TBehaviorEventHandler]'+Self.ClassName + ' Destroy'));
  if FDestroying then Exit;
  FDestroying := True;

  FThis  := nil;
  FSuper := nil;

  FEventHandler.Controller := nil;
  FEventHandler.RttiObject := nil;
  FEventHandler := nil;
  inherited;
  
  InterlockedDecrement(varLocalBehaviorCount);
end;

function TBehaviorEventHandler.DoScriptCallTs(const he: IDomElement;
  pvm: Ptiscript_VM; const name: PWideChar; var retval: tiscript_value): Boolean;
begin
  Result := OnScriptCallTs(he, pvm, name, retval);
end;

function TBehaviorEventHandler.IsSinking(event_type: UINT): Boolean;
begin
  Result := EventHandler.IsSinking(event_type)
end;

function TBehaviorEventHandler.IsBubbling(event_type: UINT): Boolean;
begin
  Result := EventHandler.IsBubbling(event_type)
end;

function TBehaviorEventHandler.IsHandled(event_type: UINT): Boolean;
begin
  Result := EventHandler.IsHandled(event_type);
end;

function TBehaviorEventHandler.OnActivateChild(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnActivateChild <> nil) then
    Result := FSuper.OnActivateChild(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnAnimation(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnAnimation <> nil) then
    Result := FSuper.OnAnimation(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

procedure TBehaviorEventHandler.OnAttached(const he: IDomElement);
begin
  if (FSuper <> nil) and (@FSuper.OnAttached <> nil) then
    FSuper.OnAttached(he);
end;

function TBehaviorEventHandler.OnButtonClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnButtonClick <> nil) then
    Result := FSuper.OnButtonClick(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnButtonPress(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnButtonPress <> nil) then
    Result := FSuper.OnButtonPress(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnButtonStateChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnButtonStateChanged <> nil) then
    Result := FSuper.OnButtonStateChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnClosePopup(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnClosePopup <> nil) then
    Result := FSuper.OnClosePopup(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnContentChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnContentChanged <> nil) then
    Result := FSuper.OnContentChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnContextMenuRequest(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnContextMenuRequest <> nil) then
    Result := FSuper.OnContextMenuRequest(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDataArrived(const he: IDomElement;
  initiator: IDomElement; var params: TDataArrivedParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDataArrived <> nil) then
    Result := FSuper.OnDataArrived(he, initiator, params)
  else
  begin
    Result := False;
  end;
end;

procedure TBehaviorEventHandler.OnDetached(const he: IDomElement);
begin
  if (FSuper <> nil) and (@FSuper.OnDetached <> nil) then
    FSuper.OnDetached(he);
end;

function TBehaviorEventHandler.OnDisabledStatusChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDisabledStatusChanged <> nil) then
    Result := FSuper.OnDisabledStatusChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDocumentComplete(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDocumentComplete <> nil) then
    Result := FSuper.OnDocumentComplete(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDocumentCreated(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDocumentCreated <> nil) then
    Result := FSuper.OnDocumentCreated(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDragEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDragEnter <> nil) then
    Result := FSuper.OnDragEnter(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDragging(const he, target: IDomElement;
  event_type: UINT;var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDragging <> nil) then
    Result := FSuper.OnDragging(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDragLeave(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDragLeave <> nil) then
    Result := FSuper.OnDragLeave(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDragRequest(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDragRequest <> nil) then
    Result := FSuper.OnDragRequest(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDraw(const he: IDomElement;
  draw_type: UINT; var params: TDrawParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDraw <> nil) then
    Result := FSuper.OnDraw(he, draw_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDrop(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDrop <> nil) then
    Result := FSuper.OnDrop(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnEditValueChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnEditValueChanged <> nil) then
    Result := FSuper.OnEditValueChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnEditValueChanging(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnEditValueChanging <> nil) then
    Result := FSuper.OnEditValueChanging(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnElementCollapsed(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnElementCollapsed <> nil) then
    Result := FSuper.OnElementCollapsed(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnElementExpanded(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnElementExpanded <> nil) then
    Result := FSuper.OnElementExpanded(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnEvent(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnEvent <> nil) then
    Result := FSuper.OnEvent(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;


function TBehaviorEventHandler.OnFormReset(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFormReset <> nil) then
    Result := FSuper.OnFormReset(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnFormSubmit(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFormSubmit <> nil) then
    Result := FSuper.OnFormSubmit(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnHistoryDrop(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnHistoryDrop <> nil) then
    Result := FSuper.OnHistoryDrop(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnHistoryNext(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnHistoryNext <> nil) then
    Result := FSuper.OnHistoryNext(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnHistoryPrior(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnHistoryPrior <> nil) then
    Result := FSuper.OnHistoryPrior(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnHistoryPush(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnHistoryPush <> nil) then
    Result := FSuper.OnHistoryPush(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnHistoryStateChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnHistoryStateChanged <> nil) then
    Result := FSuper.OnHistoryStateChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnHyperlinkClick(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnHyperlinkClick <> nil) then
    Result := FSuper.OnHyperlinkClick(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnInitDataView(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnInitDataView <> nil) then
    Result := FSuper.OnInitDataView(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnKeyChar(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnKeyChar <> nil) then
    Result := FSuper.OnKeyChar(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnKeyDown(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnKeyDown <> nil) then
    Result := FSuper.OnKeyDown(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnKeyUp(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnKeyUp <> nil) then
    Result := FSuper.OnKeyUp(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMenuItemActive(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMenuItemActive <> nil) then
    Result := FSuper.OnMenuItemActive(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMenuItemClick(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMenuItemClick <> nil) then
    Result := FSuper.OnMenuItemClick(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMethodCall(const he: IDomElement;
  methodID: TBehaviorMethodIdentifier; params: PMethodParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMethodCall <> nil) then
    Result := FSuper.OnMethodCall(he, methodID, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseClick <> nil) then
    Result := FSuper.OnMouseClick(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseDClick <> nil) then
    Result := FSuper.OnMouseDClick(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseDown <> nil) then
    Result := FSuper.OnMouseDown(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseEnter <> nil) then
    Result := FSuper.OnMouseEnter(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseIdle(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseIdle <> nil) then
    Result := FSuper.OnMouseIdle(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseLeave(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseLeave <> nil) then
    Result := FSuper.OnMouseLeave(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseMove <> nil) then
    Result := FSuper.OnMouseMove(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseTick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseTick <> nil) then
    Result := FSuper.OnMouseTick(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseUp <> nil) then
    Result := FSuper.OnMouseUp(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouseWheel(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouseWheel <> nil) then
    Result := FSuper.OnMouseWheel(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPopupDismissed(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPopupDismissed <> nil) then
    Result := FSuper.OnPopupDismissed(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPopupDismissing(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPopupDismissing <> nil) then
    Result := FSuper.OnPopupDismissing(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPopupReady(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPopupReady <> nil) then
    Result := FSuper.OnPopupReady(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPopupRequest(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPopupRequest <> nil) then
    Result := FSuper.OnPopupRequest(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnRequestTooltip(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnRequestTooltip <> nil) then
    Result := FSuper.OnRequestTooltip(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnRowsDataRequest(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnRowsDataRequest <> nil) then
    Result := FSuper.OnRowsDataRequest(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnScriptCallTs(const he: IDomElement;
  pvm: Ptiscript_VM; const name: PWideChar; var retval: tiscript_value): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnScriptCallTs <> nil) then
    Result := FSuper.OnScriptCallTs(he, pvm, name, retval)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnScroll(const he, target: IDomElement;
  cmd: UINT{SCROLL_EVENTS}; var params: TScorllParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnScroll <> nil) then
    Result := FSuper.OnScroll(he, target, cmd, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnSelectSelectionChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnSelectSelectionChanged <> nil) then
    Result := FSuper.OnSelectSelectionChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnSelectStateChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnSelectStateChanged <> nil) then
    Result := FSuper.OnSelectStateChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

procedure TBehaviorEventHandler.OnSize(const he: IDomElement);
begin
  if (FSuper <> nil) and (@FSuper.OnSize <> nil) then
    FSuper.OnSize(he);
end;

function TBehaviorEventHandler.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnSubscription <> nil) then
    Result := FSuper.OnSubscription(he, event_groups)
  else
  begin
    event_groups := HANDLE_ALL;
    Result := True;
  end;
end;

function TBehaviorEventHandler.OnTimer(const he: IDomElement): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnTimer <> nil) then
    Result := FSuper.OnTimer(he)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnTimerEx(const he: IDomElement;
  extTimerId: UINT_PTR): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnTimerEx <> nil) then
    Result := FSuper.OnTimerEx(he, extTimerId)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnUIStateChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnUIStateChanged <> nil) then
    Result := FSuper.OnUIStateChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnVideoBindRQ(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnVideoBindRQ <> nil) then
    Result := FSuper.OnVideoBindRQ(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnVideoInitialized(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnVideoInitialized <> nil) then
    Result := FSuper.OnVideoInitialized(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnVideoStarted(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnVideoStarted <> nil) then
    Result := FSuper.OnVideoStarted(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnVideoStopped(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnVideoStopped <> nil) then
    Result := FSuper.OnVideoStopped(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnVisiualStatusChanged(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnVisiualStatusChanged <> nil) then
    Result := FSuper.OnVisiualStatusChanged(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.GetThis: IDomElement;
begin
  Result := IDomElement(FThis);
end;

constructor TBehaviorEventHandler.Create;
begin
  Create(nil);
end;

function TBehaviorEventHandler._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
//  if Self.ClassName = 'TWinCmdBehavior' then
//    OutputDebugString(PChar('[TBehaviorEventHandler]'+'after ' + Self.ClassName + '._AddRef:' + IntToStr(Result)));
end;

function TBehaviorEventHandler._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
//  if Self.ClassName = 'TWinCmdBehavior' then
//    OutputDebugString(PChar('[TBehaviorEventHandler]'+'after ' + Self.ClassName + '._Release:' + IntToStr(FRefCount)));
  if Result = 0 then
    Destroy;
end;

function TBehaviorEventHandler.GetDestroying: Boolean;
begin
  Result := FDestroying;
end;

function TBehaviorEventHandler.GetLayout: ISciterLayout;
begin
  Result := ISciterLayout(FEventHandler.Layout);
end;

procedure TBehaviorEventHandler.SetLayout(const Value: ISciterLayout);
begin
  FEventHandler.Layout := Pointer(Value);
end;

function TBehaviorEventHandler.OnFocusGot(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFocusGot <> nil) then
    Result := FSuper.OnFocusGot(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnFocusLost(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFocusLost <> nil) then
    Result := FSuper.OnFocusLost(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.GetRttiObject: IDispatchRttiObject;
begin
  Result := FEventHandler.RttiObject;
end;

procedure TBehaviorEventHandler.SetRttiObject(const Value: IDispatchRttiObject);
begin
  FEventHandler.RttiObject := Value;
end;

procedure TBehaviorEventHandler.DoAfterWndProc(
  msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var Result: LRESULT);
begin
  if (FSuper <> nil) and (@FSuper.AfterWndProc <> nil) then
    FSuper.AfterWndProc(msg, wParam, lParam, Result)
end;

function TBehaviorEventHandler.DoBeforeWndProc(
  msg: UINT; wParam: WPARAM; lParam: LPARAM;
  var pbHandled: Boolean): LRESULT;
begin
  if (FSuper <> nil) and (@FSuper.BeforeWndProc <> nil) then
    Result := FSuper.BeforeWndProc(msg, wParam, lParam, pbHandled)
  else
  begin
    Result := 0;
  end;
end;

function TBehaviorEventHandler.AddAfterWndProc: Integer;
begin
  Result := FEventHandler.AddAfterWndProc;
end;

function TBehaviorEventHandler.AddBeforeWndProc: Integer;
begin
  Result := FEventHandler.AddBeforeWndProc
end;

function TBehaviorEventHandler.RemoveAfterWndProc: Integer;
begin
  Result := FEventHandler.RemoveAfterWndProc
end;

function TBehaviorEventHandler.RemoveBeforeWndProc: Integer;
begin
  Result := FEventHandler.RemoveBeforeWndProc
end;

function TBehaviorEventHandler.OnDocumentClose(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDocumentClose <> nil) then
    Result := FSuper.OnDocumentClose(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDocumentCloseRequest(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDocumentCloseRequest <> nil) then
    Result := FSuper.OnDocumentCloseRequest(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnDocumentReady(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnDocumentReady <> nil) then
    Result := FSuper.OnDocumentReady(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPaginationEnds(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPaginationEnds <> nil) then
    Result := FSuper.OnPaginationEnds(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPaginationPage(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPaginationPage <> nil) then
    Result := FSuper.OnPaginationPage(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnPaginationStarts(const he,
  target: IDomElement; _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnPaginationStarts <> nil) then
    Result := FSuper.OnPaginationStarts(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnChange(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnChange <> nil) then
    Result := FSuper.OnChange(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnClick <> nil) then
    Result := FSuper.OnClick(he, target, _type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnFocusIn(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFocusIn <> nil) then
    Result := FSuper.OnFocusIn(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnFocusOut(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFocusOut <> nil) then
    Result := FSuper.OnFocusOut(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.IsType(event, event_type: UINT): Boolean;
begin
  Result := EventHandler.IsType(event, event_type);
end;

function TBehaviorEventHandler.OnFocus(const he, target: IDomElement;
  event_type: UINT; var params: TFocusParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnFocus <> nil) then
    Result := FSuper.OnFocus(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnMouse(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnMouse <> nil) then
    Result := FSuper.OnMouse(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.OnKey(const he, target: IDomElement;
  event_type: UINT; var params: TKeyParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnKey <> nil) then
    Result := FSuper.OnKey(he, target, event_type, params)
  else
  begin
    Result := False;
  end;
end;

function TBehaviorEventHandler.GetSuper: IDefalutBehaviorEventHandler;
begin
  Result := FSuper;
end;

procedure TBehaviorEventHandler.SetSuper(
  const Value: IDefalutBehaviorEventHandler);
begin
  FSuper := Value;
end;

function TBehaviorEventHandler.OnGesture(const he, target: IDomElement;
  cmd: UINT; var params: TGestrueParams): Boolean;
begin
  if (FSuper <> nil) and (@FSuper.OnGesture <> nil) then
    Result := FSuper.OnGesture(he, target, cmd, params)
  else
  begin
    Result := False;
  end;
end;

{ TBehaviorFactory }

constructor TBehaviorFactory.Create(const external_name: SciterString; const AClass: TBehaviorEventHandlerClass);
begin
  FName := external_name;
  FClass := AClass;
end;

function TBehaviorFactory.CreateHandler(const he: IDomElement;
  const ALayout: ISciterLayout = nil): IBehaviorEventHandler;
var
  LObj: TBehaviorEventHandler;
begin
  Result := nil;
  try
    LObj := FClass.Create(he);
    LObj.Layout := ALayout;
    Result := LObj;
  except
    on E: Exception do
      OutputDebugString(PChar('[TBehaviorFactory.CreateHandler]'+E.Message));
  end;
end;

function TBehaviorFactory.GetName: SciterString;
begin
  Result := FName;
end;

function TBehaviorFactory.Implementator: Pointer;
begin
  Result := Self;
end;

procedure TBehaviorFactory.SetName(const Value: SciterString);
begin
  FName := Value;
end;

end.
