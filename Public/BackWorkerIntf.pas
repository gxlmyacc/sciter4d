{*******************************************************************************
 标题:     BackWorkerIntf.pas
 描述:     后台线程类的接口定义单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit BackWorkerIntf;

interface


uses
  SysUtils, Classes, Windows, Messages;

const
  CONST_DEFNAME  = 'Background Worker';

type
  TWorkState = (wsStart, wsWorking, wsProgress, wsComplete, wsFeedback);
  EBackgroundWorker = class(Exception);

  IBackgroundWorker = interface;

  TCustomWorkMessageEvent = procedure (const Msg: TMessage; var bHandled: Boolean) of object;
  TCustomWorkMessageEventProc = procedure (const Msg: TMessage; var bHandled: Boolean);

  TWorkEvent = procedure(const Worker: IBackgroundWorker; State: TWorkState;
    Param1, Param2: Pointer; PercentDone: Integer; Cancelled: Boolean) of object;
  TWorkEventProc = procedure(const Worker: IBackgroundWorker; State: TWorkState;
    Param1, Param2: Pointer; PercentDone: Integer; Cancelled: Boolean);
  (*
  case State of
    wsStart:
    begin
    
    end;
    wsWorking: //该段代码在线程中
    begin
      //如果用户选择了取消，则退出
      if Worker.CancellationPending then
      begin
        //接受【取消】请求
        Worker.AcceptCancellation;
        Exit;
      end;

      LParams := Worker.Data1;
    end;
    wsProgress:  //处理进度消息
    begin
      LParams := Worker.Data1;
      ……
    end;
    wsComplete: //报告处理完成
    begin
      LParams := Worker.Data1;
      ……
    end;
    wsFeedback:
    begin
    
    end;
  end;
  *)

  IBackgroundWorker = interface
  ['{170D13CC-CECE-4EBD-B2F4-77B106651E08}']
    function GetName: WideString;
    function GetGroup: WideString;
    function GetCompleted: Boolean;
    function GetCancellationPending: Boolean;
    function GetCancelled: Boolean;
    function GetWorking: Boolean;
    function GetThreadID: DWORD;
    function GetData(const AName: WideString): WideString;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetData3: IInterface;
    function GetOnWork: TWorkEvent;
    function GetOnWorkProc: TWorkEventProc;
    procedure SetName(const Value: WideString);
    procedure SetGroup(const Value: WideString);
    procedure SetCompleted(const Value: Boolean);
    procedure SetData(const AName, Value: WideString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetData3(const Value: IInterface);
    procedure SetOnWork(const Value: TWorkEvent);
    procedure SetOnWorkProc(const Value: TWorkEventProc);

    function  Implementator: Pointer;

    procedure Execute; overload;
    procedure Execute(const AWorkEvent: TWorkEvent); overload;
    procedure Execute(const AWorkEvent: TWorkEventProc); overload;
    procedure Cancel;
    procedure WaitFor;
    
    procedure ReportProgress(const PercentDone: Integer);
    procedure ReportProgressWait(const PercentDone: Integer);
    procedure ReportFeedback(const Param1: Pointer = nil; const Param2: Pointer = nil);
    procedure ReportFeedbackWait(const Param1: Pointer = nil; const Param2: Pointer = nil);

    procedure Synchronize(const Method: TNotifyEvent; const Sender: TObject);
    procedure AcceptCancellation;
    
    property CancellationPending: Boolean read GetCancellationPending;
    property IsCancelled: Boolean read GetCancelled;
    property IsWorking: Boolean read GetWorking;
    property IsCompleted: Boolean read GetCompleted write SetCompleted;
    property ThreadID: DWORD read GetThreadID;
    property Name: WideString read GetName write SetName;
    property Group: WideString read GetGroup write SetGroup;

    property Data[const AName: WideString]: WideString read GetData write SetData; default;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
    property Data3: IInterface read GetData3 write SetData3;

    property OnWork: TWorkEvent read GetOnWork write SetOnWork;
    property OnWorkProc: TWorkEventProc read GetOnWorkProc write SetOnWorkProc;
  end;

  IBackgroundWorkerList = interface
  ['{CF8F3BF8-1EC0-4B54-B632-50DA54AF6E60}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IBackgroundWorker;
    function  GetItemByName(const AName: WideString): IBackgroundWorker;
    procedure SetItem(const Index: Integer; const Value: IBackgroundWorker);
    procedure SetItemByName(const AName: WideString; const Value: IBackgroundWorker);

    function  Implementator: Pointer;

    procedure GC;
      
    function  Add(const AItem: IBackgroundWorker): Integer; overload;
    function  Add(const AName: WideString; const AGroup: WideString = ''): IBackgroundWorker; overload;
    procedure Clear(const AGroup: WideString = '');
    procedure Cancel(const AGroup: WideString = ''; const AWaitFor: Boolean = False);

    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IBackgroundWorker);
    function  IndexOf(const AItem: IBackgroundWorker): Integer;
    function  IndexOfName(const AName: WideString; const AGroup: WideString = ''): Integer;
    function  Remove(const Item: IBackgroundWorker): Integer;

    function  First: IBackgroundWorker;
    function  Last: IBackgroundWorker;

    procedure Lock;
    procedure Unlock;

    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IBackgroundWorker read GetItem write SetItem; default;
    property ItemByName[const AName: WideString]: IBackgroundWorker read GetItemByName write SetItemByName;
  end;

  PIWorkerFactory = ^IWorkerFactory;
  IWorkerFactory = interface
  ['{D68455DA-1443-4715-9613-1E44A8344A75}']
    function GetWorkerList: IBackgroundWorkerList;
    function GetOnCustomWorkMessageProc: TCustomWorkMessageEventProc;
    procedure SetOnCustomWorkMessageProc(const Value: TCustomWorkMessageEventProc);

    function Implementor: Pointer;

    function CreateWorker(const AWorkEvent: TWorkEvent = nil;
      const AName: WideString = CONST_DEFNAME; const AGroup: WideString = ''): IBackgroundWorker; overload;
    function CreateWorker(const AWorkEvent: TWorkEventProc = nil;
      const AName: WideString = CONST_DEFNAME; const AGroup: WideString = ''): IBackgroundWorker; overload;

    procedure Execute(const AWork: IBackgroundWorker); overload;
    procedure Execute(const AWork: IBackgroundWorker; const AWorkEvent: TWorkEvent); overload;
    procedure Execute(const AWork: IBackgroundWorker; const AWorkEvent: TWorkEventProc); overload;
    procedure Execute(const AWorkEvent: TWorkEvent); overload;
    procedure Execute(const AWorkEvent: TWorkEventProc); overload;

    procedure CancelWorker(const AWork: IBackgroundWorker);
    procedure FreeWorker(var AWork: IBackgroundWorker);

    procedure ClearAllCustomMessage;
    function  AddCustomMessageListener(const AWndProc: TCustomWorkMessageEvent): Integer;
    procedure RemoveCustomMessageListener(const AWndProc: TCustomWorkMessageEvent);
    procedure DeleteCustomMessageListener(const AProcIndex: Integer);

    function SendCustomMessage(Msg: UINT; wParam: WPARAM = 0; lParam: LPARAM = 0): LRESULT;
    function PostCustomMessage(Msg: UINT; wParam: WPARAM = 0; lParam: LPARAM = 0): BOOL;

    property WorkerList: IBackgroundWorkerList read GetWorkerList;
    property OnCustomWorkMessageProc: TCustomWorkMessageEventProc read GetOnCustomWorkMessageProc write SetOnCustomWorkMessageProc;
  end;


function WorkerFactory: PIWorkerFactory;
function WorkerList: IBackgroundWorkerList;

{$IF CompilerVersion > 15.0 }
type
  TWorkEventProcEx = reference to procedure(State: TWorkState;
    Param1, Param2: Pointer; PercentDone: Integer; Cancelled: Boolean);
procedure ExecuteWorker(const AWork: IBackgroundWorker; const AWorkEvent: TWorkEventProcEx);
{$IFEND}
  
implementation

uses
  BackWorkerImpl;

function WorkerFactory: PIWorkerFactory;
begin
  Result := __WorkerFactory;
end;

function WorkerList: IBackgroundWorkerList;
begin
  Result := WorkerFactory.WorkerList;
end;

{$IF CompilerVersion > 15.0 }
type
  IImplementator = interface
  ['{92A8C8D7-2B33-4287-8B03-978203DD73E5}']
    function Implementator: Pointer;
  end;
  TExecuteWorker = class(TInterfacedObject, IImplementator)
    Data3: IInterface;
    Callback: TWorkEventProcEx;
    function Implementator: Pointer;
  end;

function TExecuteWorker.Implementator: Pointer;
begin
  Result := Self;
end;
procedure WorkEventProc(const Worker: IBackgroundWorker; State: TWorkState;
    Param1, Param2: Pointer; PercentDone: Integer; Cancelled: Boolean);
var
  LIntf: IImplementator;
begin
  LIntf := Worker.Data3 as IImplementator;
  Worker.Data3 := TExecuteWorker(LIntf.Implementator).Data3;
  try
    TExecuteWorker(LIntf.Implementator).Callback(State, Param1, Param2, PercentDone, Cancelled);
  finally
    Worker.Data3 := LIntf;
  end;
end;

procedure ExecuteWorker(const AWork: IBackgroundWorker; const AWorkEvent: TWorkEventProcEx);
var
  LExecuteWorker: TExecuteWorker;
begin
  LExecuteWorker := TExecuteWorker.Create;
  LExecuteWorker.Callback := AWorkEvent;
  LExecuteWorker.Data3 := AWork.Data3;
  AWork.Data3 := LExecuteWorker;
  WorkerFactory.Execute(AWork, WorkEventProc);
end;
{$IFEND}

end.
