{*******************************************************************************
 标题:     SciterWndIntf.pas
 描述:     sciter窗口接口
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterWndIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes, SciterIntf, Windows;

type
  ISciterWindow = interface;

  TSciterWndProc = function (const hwnd: ISciterWindow; msg: UINT; wParam: WPARAM;
    lParam: LPARAM; var pHandle: Boolean): LRESULT;
  TSciterNotifyEvent = procedure (const hwnd: ISciterWindow; var pHandle: Boolean; var Result: LRESULT) of object;
  TSciterCloseQueryEvent = procedure(const hwnd: ISciterWindow; var pHandle: Boolean; var CanClose: Boolean) of object;
  TSciterKeyDownEvent = procedure (const hwnd: ISciterWindow; msg: UINT;
    CharCode, KeyData: Integer; var pHandle: Boolean; var Result: LRESULT) of object;
    
  ISciterWindow = interface(ISciterBase)
  ['{F6715C06-382C-479E-B257-07ABECCAB60D}']
    function GetFlags: TSciterCreateWindowFlags;
    function GetLayout: PISciterLayout;
    function GetBehavior: IDefalutBehaviorEventHandler;
    function GetParent: HWINDOW;
    function GetCaption: SciterString;
    function GetLeft: Integer;
    function GetTop: Integer;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetBounds: TRect;
    function GetIsModaling: Boolean;
    function GetIsShowing: Boolean;
    function GetModalCode: Integer;
    function GetTag: Pointer;
    function GetOnWndProc: TSciterWndProc;
    function GetOnClose: TSciterNotifyEvent;
    function GetOnCloseQuery: TSciterCloseQueryEvent;
    function GetOnCreate: TSciterNotifyEvent;
    function GetOnDestroy: TSciterNotifyEvent;
    function GetOnHide: TSciterNotifyEvent;
    function GetOnShow: TSciterNotifyEvent;
    function GetOnKeyDown: TSciterKeyDownEvent;
    procedure SetBehavior(const Value: IDefalutBehaviorEventHandler);
    procedure SetParent(const Value: HWINDOW);
    procedure SetCaption(const Value: SciterString);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetBounds(const Value: TRect);
    procedure SetModalCode(const Value: Integer);
    procedure SetTag(const Value: Pointer);
    procedure SetOnWndProc(const Value: TSciterWndProc);
    procedure SetOnClose(const Value: TSciterNotifyEvent);
    procedure SetOnCloseQuery(const Value: TSciterCloseQueryEvent);
    procedure SetOnCreate(const Value: TSciterNotifyEvent);
    procedure SetOnDestroy(const Value: TSciterNotifyEvent);
    procedure SetOnHide(const Value: TSciterNotifyEvent);
    procedure SetOnShow(const Value: TSciterNotifyEvent);
    procedure SetOnKeyDown(const Value: TSciterKeyDownEvent);

    function  IsSinking(event_type: UINT): Boolean;
    function  IsBubbling(event_type: UINT): Boolean;
    function  IsHandled(event_type: UINT): Boolean;

    procedure Show(nCmdShow: Integer = SW_SHOW; Update: Boolean = True; AddToList: Boolean = True);
    procedure Hide;

    function  ShowModal(nCmdShow: Integer = SW_SHOW): Integer;
    procedure EndModal(nCode: Integer);

    procedure Close;

    property Flags: TSciterCreateWindowFlags read GetFlags;
    property Layout: PISciterLayout read GetLayout;
    property Behavior: IDefalutBehaviorEventHandler read GetBehavior write SetBehavior;
    property Handle: HWINDOW read  GetHwnd;
    property Parent: HWINDOW read GetParent write SetParent;
    property Caption: SciterString read GetCaption write SetCaption;
    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Bounds: TRect read GetBounds write SetBounds;
    property IsShowing: Boolean read GetIsShowing;
    property IsModaling: Boolean read GetIsModaling;
    property ModalCode: Integer read GetModalCode write SetModalCode;
    property Tag: Pointer read GetTag write SetTag;

    property OnWndProc: TSciterWndProc read GetOnWndProc write SetOnWndProc;
    property OnCreate: TSciterNotifyEvent read GetOnCreate write SetOnCreate;
    property OnDestroy: TSciterNotifyEvent read GetOnDestroy write SetOnDestroy;
    property OnClose: TSciterNotifyEvent read GetOnClose write SetOnClose;
    property OnCloseQuery: TSciterCloseQueryEvent read GetOnCloseQuery write SetOnCloseQuery;
    property OnShow: TSciterNotifyEvent read GetOnShow write SetOnShow;
    property OnHide: TSciterNotifyEvent read GetOnHide write SetOnHide;
    property OnKeyDown: TSciterKeyDownEvent read GetOnKeyDown write SetOnKeyDown;
  end;

  PISciterWindowList = ^ISciterWindowList;
  ISciterWindowList = interface
  ['{EBE29BFE-894D-4209-9AC2-97754F7EF355}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): ISciterWindow;
    function  GetItemByHandle(const AHandle: Cardinal): ISciterWindow;

    function  Implementor: Pointer;

    function  Add(AWindow: ISciterWindow): Integer;
    procedure Delete(const AIndex: Integer); overload;
    procedure DeleteByHandle(const AHandle: Cardinal); overload;
    procedure Clear;
    function  IndexOf(const AHandle: Cardinal): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: ISciterWindow read GetItem; default;
    property ItemByHandle[const AHandle: Cardinal]: ISciterWindow read GetItemByHandle;
  end;

function CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags;
  const frame: TRect; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow; overload;
function CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags;
  width, height: Integer; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow; overload;
  
function SciterWindowList(): PISciterWindowList;

implementation

uses
  SciterImportDefs;

function CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags;
  const frame: TRect; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow;
type
  TCreateWindow = function (AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags;
    const frame: TRect; parent: HWINDOW; AWndProc: TSciterWndProc): ISciterWindow;
begin
  Result := TCreateWindow(SciterApi.Funcs[FuncIdx_CreateWindow])(AInstance, creationFlags, frame, parent, AWndProc);
end;

function CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags;
  width, height: Integer; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow;
var
  rc: TRect;
begin
  rc.Left := 0;
  rc.Top := 0;
  rc.Right := width;
  rc.Bottom := height;
  if parent = 0 then
    Result := CreateWindow(AInstance, creationFlags + [swScreenCenter], rc, parent, AWndProc)
  else
    Result := CreateWindow(AInstance, creationFlags + [swParentCenter], rc, parent, AWndProc)
end;

function SciterWindowList(): PISciterWindowList;
type
  TSciterWindowList = function (): PISciterWindowList;
begin
  Result := TSciterWindowList(SciterApi.Funcs[FuncIdx_SciterWindowList])();
end;

end.
