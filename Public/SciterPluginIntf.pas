{*******************************************************************************
 标题:     SciterPluginImpl.pas
 描述:     Sciter4D扩展插件支持类定义接口单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterPluginIntf;

interface

{$I Sciter.inc}

uses
  Windows, SciterTypes, SciterIntf;

type
  ISciterPlugin = interface;

  TSciterBeforeLoadPluginProc = function(const APlugin: ISciterPlugin;
    var Handled: Boolean): Boolean of object;
  TSciterAfterLoadPluginProc = procedure(const APlugin: ISciterPlugin) of object;

  TSciterLoadPluginProc = procedure (const APlugin: ISciterPlugin); stdcall;
  TSciterCanUnloadPluginProc = function : Boolean; stdcall;
  TSciterUnloadPluginProc = procedure (const APlugin: ISciterPlugin); stdcall;
  TSciterSendMessageProc = function (const APlugin: ISciterPlugin;
    Msg: UINT; wParam: WPARAM; lParam: LPARAM;
    var bHandle: Boolean; const AFilter: SciterString): LRESULT; stdcall;
  TSciterRequirePluginProc = function(const APlugin: ISciterPlugin; vm: HVM; this: tiscript_value;
    argCount: Integer; args: Ptiscript_value_array): tiscript_value; stdcall;
  

  PSciterPlugin = ^ISciterPlugin;
  ISciterPlugin = interface
  ['{48AAE011-6932-464A-AA39-253D293C6383}']
    function GetBehaviorFactorys: IBehaviorFactorys;
    function GetHandle: Cardinal;
    function GetCanUnload: Boolean;
    function GetLastError: SciterString;
    function GetOwner: Pointer;
    function GetPath: SciterString;
    function GetData1: Pointer;
    function GetData2: Pointer;
    procedure SetOwner(const Value: Pointer);
    procedure SetPath(const Value: SciterString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);

    function Implementator: Pointer;
    function Loaded: Boolean;
    
    function  LoadPlugin(): Boolean;
    procedure UnloadPlugin;

    function  Require(vm: HVM; argCount: Integer; args: Ptiscript_value_array; ns: tiscript_value = 0): tiscript_value;

    function SendMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
      var bHandle: Boolean; const AFilter: SciterString = ''): LRESULT;

    function  Broadcast(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
      var bHandle: Boolean; const AFilter: SciterString = ''): LRESULT; overload;
    procedure Broadcast(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
      const AFilter: SciterString = ''); overload;

    property LastError: SciterString read GetLastError;
    property Owner: Pointer read GetOwner write SetOwner;
    property Path: SciterString read GetPath write SetPath;
    property Handle: Cardinal read GetHandle;
    property CanUnload: Boolean read GetCanUnload;
    property BehaviorFactorys: IBehaviorFactorys read GetBehaviorFactorys;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

  PISciterPluginList = ^ISciterPluginList;
  ISciterPluginList = interface
  ['{D3F61125-DA7D-4C9A-9B66-6612475015BE}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): ISciterPlugin;
    function  GetItemByPath(const APath: SciterString): ISciterPlugin;
    function  GetAfterLoadPlugin: TSciterAfterLoadPluginProc;
    function  GetBeforeLoadPlugin: TSciterBeforeLoadPluginProc;
    procedure SetItem(const Index: Integer; const Value: ISciterPlugin);
    procedure SetItemByPath(const APath: SciterString; const Value: ISciterPlugin);
    procedure SetAfterLoadPlugin(const Value: TSciterAfterLoadPluginProc);
    procedure SetBeforeLoadPlugin(const Value: TSciterBeforeLoadPluginProc);

    procedure Invalidate;
    function  Implementator: Pointer;

    function  Add(const AItem: ISciterPlugin; const AOwner: Boolean): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: ISciterPlugin; const AOwner: Boolean);

    function  Broadcast(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
      var bHandle: Boolean; const AFilter: SciterString = ''): LRESULT; overload;
    procedure Broadcast(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
      const AFilter: SciterString = ''); overload;
    
    function  IndexOf(const AItem: ISciterPlugin): Integer;
    function  IndexOfPath(const APath: SciterString): Integer;
    function  IndexOfImplementator(const AImpl: Pointer): Integer;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: ISciterPlugin read GetItem write SetItem; default;
    property ItemByPath[const APath: SciterString]: ISciterPlugin read GetItemByPath write SetItemByPath;

    property BeforeLoadPlugin: TSciterBeforeLoadPluginProc read GetBeforeLoadPlugin write SetBeforeLoadPlugin;
    property AfterLoadPlugin: TSciterAfterLoadPluginProc read GetAfterLoadPlugin write SetAfterLoadPlugin;
  end;

function SciterPluginList: PISciterPluginList;

implementation

uses
  SciterImportDefs;

function SciterPluginList: PISciterPluginList;
type
  TSciterPluginList = function : PISciterPluginList;
begin
  Result := TSciterPluginList(SciterApi.Funcs[FuncIdx_SciterPluginList]);
end;

end.
