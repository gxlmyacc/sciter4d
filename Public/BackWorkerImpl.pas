{*******************************************************************************
 标题:     BackWorkerImpl.pas
 描述:     后台线程类的实现定义单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit BackWorkerImpl;

interface

uses
  SysUtils, Classes, Windows, Messages, BackWorkerIntf;

type
  PMethod = ^TMethod;

  TBackgroundWorker = class(TInterfacedObject, IBackgroundWorker)
  private
    fName: WideString;
    fGroup: WideString;
    fCompleted: Boolean;
    fThread: TThread;
    fWindow: HWND;
    fSyncSignal: THandle;
    fFeedbackSignal: THandle;
    fProgressSignal: THandle;
    fCancellationPending: Boolean;
    fCancelled: Boolean;
    fOnWork: TWorkEvent;
    fOnWorkProc: TWorkEventProc;
    FData: TStrings;
    fData1: Pointer;
    fData2: Pointer;
    fData3: IInterface;
  protected
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
  protected
    property Thread: TThread read fThread;
    property Window: HWND read fWindow;

    procedure WindowCallback(var Message: TMessage); virtual;
    procedure Cleanup(Forced: Boolean); virtual;
    
    procedure DoStart; virtual;
    procedure DoWork; virtual;
    procedure DoWorkComplete(Cancelled: Boolean); virtual;
    procedure DoWorkProgress(PercentDone: Integer); virtual;
    procedure DoWorkFeedback(Parma1, Parma2: Pointer); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function  Implementator: Pointer;
    
    procedure Execute; overload;
    procedure Execute(const AWorkEvent: TWorkEvent); overload;
    procedure Execute(const AWorkEvent: TWorkEventProc); overload;
    procedure Cancel;
    procedure WaitFor;
    
    procedure ReportProgress(const PercentDone: Integer);
    procedure ReportProgressWait(const PercentDone: Integer);
    procedure ReportFeedback(const Param1, Param2: Pointer);
    procedure ReportFeedbackWait(const Param1, Param2: Pointer);
    
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

  TBackgroundWorkerList = class(TInterfacedObject, IBackgroundWorkerList)
  protected
    FList: IInterfaceList;
    FLock: TRTLCriticalSection;
    FGroup: WideString;
    FGCing: Boolean;
    FDestroying: Boolean;
  protected
    function  GetGroup: WideString;
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IBackgroundWorker;
    function  GetItemByName(const AName: WideString): IBackgroundWorker;
    procedure SetGroup(const Value: WideString);
    procedure SetItem(const Index: Integer; const Value: IBackgroundWorker);
    procedure SetItemByName(const AName: WideString; const Value: IBackgroundWorker);

    procedure DoListChange();
  public
    constructor Create;
    destructor Destroy; override;

    function  Implementator: Pointer;
      
    function  Add(const AItem: IBackgroundWorker): Integer; overload;
    function  Add(const AName: WideString; const AGroup: WideString = ''): IBackgroundWorker; overload;
    procedure Clear(const AGroup: WideString = '');
    procedure Cancel(const AGroup: WideString = ''; const AWaitFor: Boolean = False);

    procedure GC;

    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AItem: IBackgroundWorker);
    function  IndexOf(const AItem: IBackgroundWorker): Integer;
    function  IndexOfName(const AName: WideString; const AGroup: WideString = ''): Integer;
    function  Remove(const Item: IBackgroundWorker): Integer;

    function  First: IBackgroundWorker;
    function  Last: IBackgroundWorker;

    procedure Lock;
    procedure Unlock;

    property Group: WideString read GetGroup write SetGroup;
    
    property Count: Integer read GetCount;
    property Item[const Index: Integer]: IBackgroundWorker read GetItem write SetItem; default;
    property ItemByName[const AName: WideString]: IBackgroundWorker read GetItemByName write SetItemByName;
  end;

  TWorkerFactory = class(TInterfacedObject, IWorkerFactory)
  private
    FWindow: HWND;
    FWorkerList: IBackgroundWorkerList;
    FCustomMessageProcList: TStringList;
    FOnCustomWorkMessageProc: TCustomWorkMessageEventProc;
  protected
    function GetWorkerList: IBackgroundWorkerList;
    function GetOnCustomWorkMessageProc: TCustomWorkMessageEventProc;
    procedure SetOnCustomWorkMessageProc(const Value: TCustomWorkMessageEventProc);

    procedure MainWindowCallback(var Msg: TMessage); virtual;
    procedure WindowCallback(var Message: TMessage); virtual;
  public
    constructor Create;
    destructor Destroy; override;

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

function __WorkerFactory: PIWorkerFactory;
function WorkerFactoryObject: TWorkerFactory;

implementation

const
  SInvalidCall = '您必须在OnWork或OnWorkProc事件函数中调用【%s.%s】';
  SInvalidExit = '在关闭应用程序之前, 必须先关闭【%s】';
  SInvalidRun  = '【%s】已经在执行了';

  SNoTimers = '没有足够的可用计时器';

const
  WM_WORK_FEEDBACK      = WM_USER + 1;
  WM_WORK_FEEDBACK_WAIT = WM_USER + 2;
  WM_WORK_PROGRESS      = WM_USER + 3;
  WM_WORK_PROGRESS_WAIT = WM_USER + 4;
  WM_WORK_SYNCHORONIZE  = WM_USER + 5;
  WM_WORK_COMPLETE      = WM_USER + 6;

  WM_MAIN_ALLOCWND      = WM_USER + 1;
  WM_MAIN_DEALLOCWND    = WM_USER + 2;
  
type
  PSyncRec = ^TSyncRec;
  TSyncRec = record
    Method: TNotifyEvent;
    Sender: TObject;
  end;

const
  TimerInterval = 5 * 1000;
var
  varMainWindow: HWND = 0;
  varTimerId: Cardinal = 0;
  varWorkerFactoryDestorying: Boolean = False;
  varWorkerFactory: IWorkerFactory = nil;

function  __WorkerFactory: PIWorkerFactory;
begin
  if varWorkerFactory = nil then
    varWorkerFactory := TWorkerFactory.Create;
  Result := @varWorkerFactory;
end;

function WorkerFactoryObject: TWorkerFactory;
begin
  if varWorkerFactory = nil then
    Result := nil
  else
    Result := TWorkerFactory(__WorkerFactory.Implementor);
end;

procedure _BackGCTimerProc(hwnd:HWND; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  try
    if varWorkerFactoryDestorying then Exit;
    if varWorkerFactory = nil then Exit;
    if WorkerFactoryObject.FWorkerList = nil then Exit;
    if WorkerFactoryObject.FWorkerList.Count <= 0 then Exit;
    varWorkerFactory.WorkerList.GC;
  except
    on E: Exception do
      OutputDebugString(PChar('[_BackGCTimerProc]'+E.Message));
  end;
end;

{ TBackgroundWorkerThread }

type
  TBackgroundWorkerThread = class(TThread)
  private
    fOwner: TBackgroundWorker;
  public
    constructor CreateWorker(AOwner: TBackgroundWorker);
    procedure Execute; override;
  end;

constructor TBackgroundWorkerThread.CreateWorker(AOwner: TBackgroundWorker);
begin
  fOwner := AOwner;
  Create(True);
end;

procedure TBackgroundWorkerThread.Execute;
begin
  try
    try
      fOwner.DoWork;
    except
      fOwner.AcceptCancellation;
      ShowException(ExceptObject, ExceptAddr);
    end;
  finally
    PostMessage(fOwner.Window, WM_WORK_COMPLETE, Ord(fOwner.IsCancelled), 0);
  end;
end;

{ TBackgroundWorker }

constructor TBackgroundWorker.Create;
begin
  fName := CONST_DEFNAME;
  FData := TStringList.Create;
end;

destructor TBackgroundWorker.Destroy;
begin
  try
    if IsWorking then
    begin
      TerminateThread(fThread.Handle, 0);
      Cleanup(True);
      raise EBackgroundWorker.CreateFmt(SInvalidExit, [Name]);
    end;
    FData.Free;
    inherited Destroy;
  except
    on e: Exception do
      OutputDebugString(PChar('[TBackgroundWorker.Destroy]'+e.Message));
  end;
end;

function TBackgroundWorker.GetWorking: Boolean;
begin
  Result := (fWindow <> 0);
end;

function TBackgroundWorker.GetThreadID: DWORD;
begin
  if Assigned(fThread) then
    Result := fThread.ThreadID
  else
    Result := 0;
end;

procedure TBackgroundWorker.WindowCallback(var Message: TMessage);
var
  SyncRec: PSyncRec;
begin
  case Message.Msg of
    WM_WORK_FEEDBACK:
      DoWorkFeedback(Pointer(Message.WParam), Pointer(Message.LParam));
    WM_WORK_FEEDBACK_WAIT:
      try
        DoWorkFeedback(Pointer(Message.WParam), Pointer(Message.LParam));
      finally
        SetEvent(fFeedbackSignal);
      end;
    WM_WORK_PROGRESS:
      DoWorkProgress(Message.WParam);
    WM_WORK_PROGRESS_WAIT:
      try
        DoWorkProgress(Message.WParam);
      finally
        SetEvent(fProgressSignal);
      end;
    WM_WORK_SYNCHORONIZE:
      try
        SyncRec := PSyncRec(Message.WParam);
        if Assigned(SyncRec) and Assigned(SyncRec^.Method) then
          SyncRec^.Method(SyncRec^.Sender);
      finally
        SetEvent(fSyncSignal);
      end;
    WM_WORK_COMPLETE:
    begin
      Cleanup(false);
      DoWorkComplete(LongBool(Message.WParam));
    end;
  else
    with Message do
    begin
      Result := DefWindowProc(fWindow, Msg, WParam, LParam);
      if Msg = WM_DESTROY then
        fWindow := 0;
    end;
  end;
end;

procedure TBackgroundWorker.Execute;
var
  LMethod: TWndMethod;
begin
  if not IsWorking then
  begin
    DoStart;
    
    fCancelled := False;
    fCancellationPending := False;
    try
      LMethod := WindowCallback;
      if GetCurrentThreadId = MainThreadID then
        fWindow := Classes.AllocateHWnd(LMethod)
      else
        fWindow := SendMessage(varMainWindow, WM_MAIN_ALLOCWND, Integer(TMethod(LMethod).Code), Integer(TMethod(LMethod).data));
      fThread := TBackgroundWorkerThread.CreateWorker(Self);
      {$WARNINGS OFF}
      fThread.Resume;
      {$WARNINGS OFF}
    except
      Cleanup(True);
      raise;
    end;
  end
  else
    raise EBackgroundWorker.CreateFmt(SInvalidRun, [Name]);
end;

procedure TBackgroundWorker.Cleanup(Forced: Boolean);
begin
  if fSyncSignal <> 0 then
  begin
    CloseHandle(fSyncSignal);
    fSyncSignal := 0;
  end;
  if fFeedbackSignal <> 0 then
  begin
    CloseHandle(fFeedbackSignal);
    fFeedbackSignal := 0;
  end;
  if fProgressSignal <> 0 then
  begin
    CloseHandle(fProgressSignal);
    fProgressSignal := 0;
  end;
  if Assigned(fThread) then
  begin
    fThread.Free;
    fThread := nil;
  end;
  if fWindow <> 0 then
  begin
    if GetCurrentThreadId = MainThreadID then
      Classes.DeallocateHWnd(fWindow)
    else
      SendMessage(varMainWindow, WM_MAIN_DEALLOCWND, fWindow, 0);
    if Forced then
      fWindow := 0;
  end;
end;

procedure TBackgroundWorker.DoWork;
begin
  try
    if Assigned(fOnWork) then
      fOnWork(Self, wsWorking, nil, nil, 0, False);

    if Assigned(fOnWorkProc) then
      fOnWorkProc(Self, wsWorking, nil, nil, 0, False);
  except
    on E: Exception do
      OutputDebugString(PChar('[TBackgroundWorker.DoWork]'+E.Message));
  end;
end;

procedure TBackgroundWorker.DoStart;
begin
  try
    if Assigned(fOnWork) then
      fOnWork(Self, wsStart, fData1, fData2, 0, False);

    if Assigned(fOnWorkProc) then
      fOnWorkProc(Self, wsStart, fData1, fData2, 0, False);
  except
    on E: Exception do
      OutputDebugString(PChar('[TBackgroundWorker.DoStart]'+E.Message));
  end;
end;

procedure TBackgroundWorker.DoWorkProgress(PercentDone: Integer);
begin
  try
    if Assigned(fOnWork) then
      fOnWork(Self, wsProgress, fData1, fData2, PercentDone, False);

    if Assigned(fOnWorkProc) then
      fOnWorkProc(Self, wsProgress, fData1, fData2, PercentDone, False);
  except
    on E: Exception do
      OutputDebugString(PChar('[TBackgroundWorker.DoWorkProgress]'+E.Message));
  end;
end;

procedure TBackgroundWorker.DoWorkComplete(Cancelled: Boolean);
begin
  try
    try
      if Assigned(fOnWork) then
        fOnWork(Self, wsComplete, fData1, fData2, 0, Cancelled);

      if Assigned(fOnWorkProc) then
        fOnWorkProc(Self, wsComplete, fData1, fData2, 0, Cancelled);
    finally
      fCompleted := True;
    end;
  except
    on E: Exception do
      OutputDebugString(PChar('[TBackgroundWorker.DoWorkComplete]'+E.Message));
  end;
end;

procedure TBackgroundWorker.DoWorkFeedback(Parma1, Parma2: Pointer);
begin
  try
    if Assigned(fOnWork) then
      fOnWork(Self, wsFeedback, Parma1, Parma2, 0, False);
    if Assigned(fOnWorkProc) then
      fOnWorkProc(Self, wsFeedback, Parma1, Parma2, 0, False);
  except
    on E: Exception do
      OutputDebugString(PChar('[TBackgroundWorker.DoWorkFeedback]'+E.Message));
  end;
end;

procedure TBackgroundWorker.ReportProgress(const PercentDone: Integer);
begin
  if ThreadID = GetCurrentThreadId then
    PostMessage(fWindow, WM_WORK_PROGRESS, PercentDone, 0)
  else
    raise EBackgroundWorker.CreateFmt(SInvalidCall, [Name, 'ReportProgress']);
end;

procedure TBackgroundWorker.ReportProgressWait(const PercentDone: Integer);
begin
  if ThreadID = GetCurrentThreadId then
  begin
    if fProgressSignal = 0 then
      fProgressSignal := CreateEvent(nil, True, False, nil)
    else
      ResetEvent(fProgressSignal);
    PostMessage(fWindow, WM_WORK_PROGRESS_WAIT, PercentDone, 0);
    WaitForSingleObject(fProgressSignal, INFINITE);
  end
  else
    raise EBackgroundWorker.CreateFmt(SInvalidCall, [Name, 'ReportProgressWait']);
end;

procedure TBackgroundWorker.ReportFeedback(const Param1, Param2: Pointer);
begin
  if Assigned(fThread) and (GetCurrentThreadId = fThread.ThreadID) then
    PostMessage(fWindow, WM_WORK_FEEDBACK, Integer(Param1), Integer(Param2))
  else
    raise EBackgroundWorker.CreateFmt(SInvalidCall, [Name, 'ReportFeedback']);
end;

procedure TBackgroundWorker.ReportFeedbackWait(const Param1, Param2: Pointer);
begin
  if Assigned(fThread) and (GetCurrentThreadId = fThread.ThreadID) then
  begin
    if fFeedbackSignal = 0 then
      fFeedbackSignal := CreateEvent(nil, True, False, nil)
    else
      ResetEvent(fFeedbackSignal);
    PostMessage(fWindow, WM_WORK_FEEDBACK_WAIT, Integer(Param1), Integer(Param2));
    WaitForSingleObject(fFeedbackSignal, INFINITE);
  end
  else
    raise EBackgroundWorker.CreateFmt(SInvalidCall, [Name, 'ReportFeedbackWait']);
end;

procedure TBackgroundWorker.Synchronize(const Method: TNotifyEvent; const Sender: TObject);
var
  SyncRec: TSyncRec;
begin
  if Assigned(fThread) and (GetCurrentThreadId = fThread.ThreadID) then
  begin
    SyncRec.Method := Method;
    SyncRec.Sender := Sender;
    if fSyncSignal = 0 then
      fSyncSignal := CreateEvent(nil, True, False, nil)
    else
      ResetEvent(fSyncSignal);
    PostMessage(fWindow, WM_WORK_SYNCHORONIZE, Integer(@SyncRec), 0);
    WaitForSingleObject(fSyncSignal, INFINITE);
  end
  else
    raise EBackgroundWorker.CreateFmt(SInvalidCall, [Name, 'Synchronize']);
end;

procedure TBackgroundWorker.AcceptCancellation;
begin
  if ThreadID = GetCurrentThreadId then
  begin
    fCancelled := True;
    fCancellationPending := False;
  end
  else
    raise EBackgroundWorker.CreateFmt(SInvalidCall, [Name, 'AcceptCancellation']);
end;

procedure TBackgroundWorker.Cancel;
begin
  if IsWorking then
    fCancellationPending := True;
end;

procedure TBackgroundWorker.WaitFor;
var
  Msg: TMSG;
begin
  while IsWorking do
    if PeekMessage(Msg, fWindow, 0, 0, PM_REMOVE) then
    begin
      if Msg.message = WM_QUIT then
        Break;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
end;

function TBackgroundWorker.GetName: WideString;
begin
  Result := fName;
end;

function TBackgroundWorker.GetCancellationPending: Boolean;
begin
  Result := fCancellationPending;
end;

function TBackgroundWorker.GetCancelled: Boolean;
begin
  Result := fCancelled;
end;

function TBackgroundWorker.GetOnWork: TWorkEvent;
begin
  Result := fOnWork;
end;

procedure TBackgroundWorker.SetOnWork(const Value: TWorkEvent);
begin
  fOnWork := Value;
end;

function TBackgroundWorker.GetOnWorkProc: TWorkEventProc;
begin
  Result := fOnWorkProc;
end;

procedure TBackgroundWorker.SetOnWorkProc(const Value: TWorkEventProc);
begin
  fOnWorkProc := Value;
end;

procedure TBackgroundWorker.SetName(const Value: WideString);
begin
  fName := Value;
end;

function TBackgroundWorker.Implementator: Pointer;
begin
  Result := Self;
end;

function TBackgroundWorker.GetGroup: WideString;
begin
  Result := fGroup;
end;

procedure TBackgroundWorker.SetGroup(const Value: WideString);
begin
  fGroup := Value;
end;

function TBackgroundWorker.GetData1: Pointer;
begin
  Result := fData1;
end;

function TBackgroundWorker.GetData2: Pointer;
begin
  Result := fData2;
end;

procedure TBackgroundWorker.SetData1(const Value: Pointer);
begin
  fData1 := Value;
end;

procedure TBackgroundWorker.SetData2(const Value: Pointer);
begin
  fData2 := Value;
end;

procedure TBackgroundWorker.Execute(const AWorkEvent: TWorkEvent);
begin
  FOnWork := AWorkEvent;
  FOnWorkProc := nil;
  Execute;
end;

procedure TBackgroundWorker.Execute(const AWorkEvent: TWorkEventProc);
begin
  FOnWork := nil;
  FOnWorkProc := AWorkEvent;
  Execute;
end;

function TBackgroundWorker.GetCompleted: Boolean;
begin
  Result := fCompleted;
end;

procedure TBackgroundWorker.SetCompleted(const Value: Boolean);
begin
  fCompleted := Value;
end;

function TBackgroundWorker.GetData3: IInterface;
begin
  Result := fData3;
end;

procedure TBackgroundWorker.SetData3(const Value: IInterface);
begin
  fData3 := Value;
end;

function TBackgroundWorker.GetData(const AName: WideString): WideString;
begin
  Result := FData.Values[AName];
end;

procedure TBackgroundWorker.SetData(const AName, Value: WideString);
begin
  FData.Values[AName] := Value;
end;

{ TWorkerFactory }

procedure TWorkerFactory.CancelWorker(const AWork: IBackgroundWorker);
begin
  if AWork = nil then Exit;
  try
    if AWork.IsWorking then
    begin
      AWork.Cancel;
      AWork.WaitFor;
    end;
  except
    on e: Exception do
      OutputDebugString(PChar('[TWorkerFactory.CancelWorker]'+e.Message));
  end;
end;

function TWorkerFactory.CreateWorker(const AWorkEvent: TWorkEventProc;
  const AName: WideString; const AGroup: WideString): IBackgroundWorker;
begin
  Result := TBackgroundWorker.Create;
  Result.Name := AName;
  Result.Group := AGroup;
  Result.OnWorkProc := AWorkEvent;
end;

function TWorkerFactory.CreateWorker(const AWorkEvent: TWorkEvent;
  const AName: WideString; const AGroup: WideString): IBackgroundWorker;
begin
  Result := TBackgroundWorker.Create;
  Result.Name := AName;
  Result.Group := AGroup;
  Result.OnWork := AWorkEvent;
end;

procedure TWorkerFactory.Execute(const AWork: IBackgroundWorker);
begin
  if AWork = nil then Exit;
  if AWork.IsWorking then
  begin
    AWork.Cancel;
    AWork.WaitFor;
  end;
  AWork.Execute;
end;

procedure TWorkerFactory.Execute(const AWork: IBackgroundWorker;
  const AWorkEvent: TWorkEventProc);
begin
  if AWork = nil then Exit;
  if not Assigned(AWorkEvent) then Exit;
  
  if AWork.IsWorking then
  begin
    AWork.Cancel;
    AWork.WaitFor;
  end;
  
  AWork.OnWork := nil;
  AWork.OnWorkProc := AWorkEvent;
  AWork.Execute;
end;

procedure TWorkerFactory.Execute(const AWork: IBackgroundWorker; const AWorkEvent: TWorkEvent);
begin
  if AWork = nil then Exit;
  if not Assigned(AWorkEvent) then Exit;

  if AWork.IsWorking then
  begin
    AWork.Cancel;
    AWork.WaitFor;
  end;

  AWork.OnWork := AWorkEvent;
  AWork.OnWorkProc := nil;
  AWork.Execute;
end;

procedure TWorkerFactory.FreeWorker(var AWork: IBackgroundWorker);
begin
  if AWork = nil then Exit;
  try
    CancelWorker(AWork);
    AWork := nil;
  except
    on e: Exception do
      OutputDebugString(PChar('[TWorkerFactory.FreeWorker]'+e.Message));
  end;  
end;

function TWorkerFactory.GetWorkerList: IBackgroundWorkerList;
begin
  if FWorkerList = nil then
    FWorkerList := TBackgroundWorkerList.Create;
  Result := FWorkerList;
end;

constructor TWorkerFactory.Create;
begin
  varMainWindow := Classes.AllocateHWnd(MainWindowCallback);
  FWindow := Classes.AllocateHWnd(WindowCallback);
  FCustomMessageProcList := TStringList.Create;
  FCustomMessageProcList.Duplicates := dupIgnore;
  
  varTimerId := SetTimer(0, 0, TimerInterval, @_BackGCTimerProc);
end;

destructor TWorkerFactory.Destroy;
begin
  if varWorkerFactoryDestorying then Exit;
  varWorkerFactoryDestorying := True;
  if varTimerId <> 0 then
  begin
    KillTimer(0, varTimerId);
    varTimerId := 0;
  end;
  if FWorkerList <> nil then
  begin
    FWorkerList.Cancel('', False);
    FWorkerList.Clear;
    FWorkerList := nil;
  end;
  if FWindow <> 0 then
  begin
    Classes.DeallocateHWnd(FWindow);
    FWindow := 0;
  end;
  ClearAllCustomMessage;
  if FCustomMessageProcList <> nil then
    FreeAndNil(FCustomMessageProcList);
  if varMainWindow <> 0 then
  begin
    Classes.DeallocateHWnd(varMainWindow);
    varMainWindow := 0;
  end;
  inherited;
end;

procedure TWorkerFactory.WindowCallback(var Message: TMessage);
var
  bHandled: Boolean;
  LProc: TCustomWorkMessageEvent;
  i: Integer;
begin
  bHandled := False;
  if FCustomMessageProcList <> nil then
  begin
    for i := FCustomMessageProcList.Count-1 downto 0 do
    begin
      LProc := TCustomWorkMessageEvent(PMethod(FCustomMessageProcList.Objects[i])^);
      LProc(Message, bHandled);
      if bHandled then
        Exit;
    end;
    if @FOnCustomWorkMessageProc <> nil then
      FOnCustomWorkMessageProc(Message, bHandled);
    if bHandled then
      Exit;
  end;
  DefWindowProc(FWindow, Message.Msg, Message.WParam, Message.LParam);
  if Message.Msg = WM_DESTROY then
    FWindow := 0;
end;


function TWorkerFactory.GetOnCustomWorkMessageProc: TCustomWorkMessageEventProc;
begin
  Result := FOnCustomWorkMessageProc;
end;

procedure TWorkerFactory.SetOnCustomWorkMessageProc(const Value: TCustomWorkMessageEventProc);
begin
  FOnCustomWorkMessageProc := Value;
end;

function TWorkerFactory.PostCustomMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL;
begin
  Result := Windows.PostMessage(FWindow, Msg, wParam, lParam);
end;

function TWorkerFactory.SendCustomMessage(Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  Result := Windows.SendMessage(FWindow, Msg, wParam, lParam);
end;

function TWorkerFactory.AddCustomMessageListener(const AWndProc: TCustomWorkMessageEvent): Integer;
var
  LProc: PMethod;
begin
  New(LProc);
  LProc^ := TMethod(AWndProc);
  Result := FCustomMessageProcList.AddObject(IntToStr(Integer(@AWndProc)), TObject(LProc))
end;

procedure TWorkerFactory.ClearAllCustomMessage;
var
  i: Integer;
  LProc: PMethod;
begin
  for i := 0 to FCustomMessageProcList.Count -1 do
  begin
    LProc := PMethod(FCustomMessageProcList.Objects[i]);
    Dispose(LProc);
  end;
  FCustomMessageProcList.Clear;
end;

procedure TWorkerFactory.DeleteCustomMessageListener(const AProcIndex: Integer);
var
  LProc: PMethod;
begin
  LProc := PMethod(FCustomMessageProcList.Objects[AProcIndex]);
  Dispose(LProc);
  FCustomMessageProcList.Delete(AProcIndex);
end;

procedure TWorkerFactory.RemoveCustomMessageListener(const AWndProc: TCustomWorkMessageEvent);
var
  i: Integer;
begin
  i := FCustomMessageProcList.IndexOf(IntToStr(Integer(@AWndProc)));
  if i >= 0 then
    DeleteCustomMessageListener(i);
end;

procedure TWorkerFactory.MainWindowCallback(var Msg: TMessage);
var
  LMethod: TMethod;
begin
  case Msg.Msg of
    WM_MAIN_ALLOCWND:
    begin
      LMethod.Code := Pointer(Msg.WParam);
      LMethod.Data := Pointer(Msg.LParam);
      Msg.Result := Classes.AllocateHWnd(TWndMethod(LMethod));
    end;
    WM_MAIN_DEALLOCWND:
    begin
      Classes.DeallocateHWnd(Msg.WParam);
    end
  else
    Msg.Result := DefWindowProc(varMainWindow, Msg.Msg, Msg.WParam, Msg.LParam);
  end;
end;

function TWorkerFactory.Implementor: Pointer;
begin
  Result := Self;
end;

procedure TWorkerFactory.Execute(const AWorkEvent: TWorkEvent);
begin
  Self.WorkerList.Add(CreateWorker(AWorkEvent))
end;

procedure TWorkerFactory.Execute(const AWorkEvent: TWorkEventProc);
begin
  Self.WorkerList.Add(CreateWorker(AWorkEvent))
end;

{ TBackgroundWorkerList }

function TBackgroundWorkerList.Add(
  const AName: WideString; const AGroup: WideString): IBackgroundWorker;
var
  i: Integer;
begin
  if AName = '' then
    raise Exception.Create('[TBackgroundWorkerList.Add] AName Parameter cannot empty!');
    
  i := -1; //IndexOfName(AName, AGroup);
  Lock;
  try
    if i < 0 then
    begin
      Result := TBackgroundWorker.Create;
      Result.Name := AName;

      if AGroup = '' then
        Result.Group := FGroup
      else
        Result.Group := AGroup;

      FList.Add(Result);
    end
    else
      Result := FList[i] as IBackgroundWorker;
    DoListChange;
  finally
    Unlock;
  end;
end;

function TBackgroundWorkerList.Add(
  const AItem: IBackgroundWorker): Integer;
begin
  Lock;
  try
    Result := FList.Add(AItem);
    DoListChange;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.Cancel(const AGroup: WideString; const AWaitFor: Boolean);
var
  i: Integer;
  LItem: IBackgroundWorker;
begin
  Lock;
  try
    for i := FList.Count - 1 downto 0 do
    begin
      LItem := FList[i] as IBackgroundWorker;

      if (LItem = nil) or (not LItem.IsWorking) or LItem.IsCompleted then
        continue;

      if (AGroup <> EmptyStr) and (not WideSameText(LItem.Group, AGroup)) then
        continue;

      LItem.Cancel;
      if AWaitFor then
        LItem.WaitFor;
    end;

    DoListChange;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.Clear(const AGroup: WideString = '');
var
  i: Integer;
  LItem: IBackgroundWorker;
begin
  Lock;
  try
    if AGroup = '' then
      FList.Clear
    else
    for i := FList.Count - 1 downto 0 do
    begin
      LItem := FList[i] as IBackgroundWorker;
      if (LItem = nil) or WideSameText(LItem.Group, AGroup) then
      begin
        Delete(i);
        Continue;
      end;
    end;
    DoListChange;
  finally
    Unlock;
  end;
end;

constructor TBackgroundWorkerList.Create;
begin
  FList := TInterfaceList.Create;
  InitializeCriticalSection(FLock);
end;

procedure TBackgroundWorkerList.Delete(const Index: Integer);
begin
  Lock;
  try
    FList.Delete(Index);

    DoListChange;
  finally
    Unlock;
  end;
end;

destructor TBackgroundWorkerList.Destroy;
begin
  FDestroying := True;
  Clear;
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TBackgroundWorkerList.DoListChange;
begin
  //
end;

function TBackgroundWorkerList.First: IBackgroundWorker;
begin
  Lock;
  try
    Result := FList.First as IBackgroundWorker;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.GC;
var
  i: Integer;
  LItem: IBackgroundWorker;
begin
  FGCing := True;
  try
    Lock;
    try
      //LogFmt('正在进行Background Worker 垃圾回收, 当前线程数:%d', [FList.Count]);
      for i := FList.Count - 1 downto 0 do
      begin
        LItem := FList[i] as IBackgroundWorker;
        if (LItem = nil) or LItem.IsCompleted then
          FList.Delete(i);
      end;
      //LogFmt('已经结束Background Worker 垃圾回收, 当前线程数:%d', [FList.Count]);
    finally
      Unlock;
    end;
  finally
    FGCing := False;
  end;  
end;

function TBackgroundWorkerList.GetCount: Integer;
begin
  Lock;
  try
    Result := FList.Count;
  finally
    Unlock;
  end;   
end;

function TBackgroundWorkerList.GetGroup: WideString;
begin
  Result := FGroup;
end;

function TBackgroundWorkerList.GetItem(
  const Index: Integer): IBackgroundWorker;
begin
  Lock;
  try
    Result := FList[Index] as IBackgroundWorker;
  finally
    Unlock;
  end;
end;

function TBackgroundWorkerList.GetItemByName(
  const AName: WideString): IBackgroundWorker;
var
  i: Integer;
begin
  Lock;
  try
    for i := 0 to FList.Count - 1 do
    begin
      Result := FList[i] as IBackgroundWorker;
      if Result = nil then
        Continue;

      if WideSameText(Result.Name, AName) then
        Exit;
    end;
    Result := nil;
  finally
    Unlock;
  end;
end;

function TBackgroundWorkerList.Implementator: Pointer;
begin
  Result := Self;
end;

function TBackgroundWorkerList.IndexOf(
  const AItem: IBackgroundWorker): Integer;
begin
  Lock;
  try
    Result := FList.IndexOf(AItem);
  finally
    Unlock;
  end;
end;

function TBackgroundWorkerList.IndexOfName(
  const AName: WideString; const AGroup: WideString): Integer;
var
  LItem: IBackgroundWorker;
  sGroup: WideString;
begin
  Lock;
  try
    if AGroup = '' then
      sGroup := FGroup
    else
      sGroup := AGroup;
      
    for Result := 0 to FList.Count - 1 do
    begin
      LItem := FList[Result] as IBackgroundWorker;
      if LItem = nil then
        Continue;

      if WideSameText(LItem.Name, AName) and (LItem.Group = sGroup) then
        Exit;
    end;
    Result := -1;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.Insert(const Index: Integer;
  const AItem: IBackgroundWorker);
begin
  Lock;
  try
    FList.Insert(Index, AItem);

    DoListChange;
  finally
    Unlock;
  end;
end;

function TBackgroundWorkerList.Last: IBackgroundWorker;
begin
  Lock;
  try
    Result := FList.Last as IBackgroundWorker;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.Lock;
begin
  EnterCriticalSection(FLock);
end;

function TBackgroundWorkerList.Remove(
  const Item: IBackgroundWorker): Integer;
var
  LItem: IBackgroundWorker;
begin
  Lock;
  try
    for Result := 0 to FList.Count - 1 do
    begin
      LItem := FList[Result] as IBackgroundWorker;
      if (LItem = nil) and (Item = nil) then
      begin
        FList.Delete(Result);
        Exit;
      end;

      if (LItem = nil) or (Item = nil) then
        Continue;

      if LItem.Implementator = Item.Implementator  then
      begin
        FList.Delete(Result);
        Exit;
      end;
    end;
    Result := -1;

    DoListChange;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.SetGroup(const Value: WideString);
begin
  FGroup := Value;
end;

procedure TBackgroundWorkerList.SetItem(const Index: Integer;
  const Value: IBackgroundWorker);
begin
  Lock;
  try
    FList[Index] := Value;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.SetItemByName(const AName: WideString;
  const Value: IBackgroundWorker);
var
  i: Integer;
  LItem: IBackgroundWorker;
begin
  Lock;
  try
    for i := 0 to FList.Count - 1 do
    begin
      LItem := FList[i] as IBackgroundWorker;
      if LItem = nil then
        Continue;

      if WideSameText(LItem.Name, AName) then
      begin
        FList[i] := Value;
        Exit;
      end;
    end;
  finally
    Unlock;
  end;
end;

procedure TBackgroundWorkerList.Unlock;
begin
  LeaveCriticalSection(FLock);
end;

initialization
  __WorkerFactory.WorkerList;
  
finalization
  varWorkerFactory := nil;

end.
