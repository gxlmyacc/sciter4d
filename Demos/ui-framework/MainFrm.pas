unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterTypes, SciterIntf, BackWorkerIntf, TiscriptIntf,
  SciterFactoryIntf;

type
  PThreadParams = ^TThreadParams;
  TThreadParams = record
    vm: HVM;
    taskId: Integer;
    progressCb: ITiscriptFunction; // "progress" callback, function passed from script
    doneCb: ITiscriptFunction;     // "done" callback, function passed from script
  end;

  {$METHODINFO ON}
  TUIFrameworkWindow = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDestroying: Boolean;
    
    procedure DoBackWork(const Worker: IBackgroundWorker; State: TWorkState;
      Param1, Param2: Pointer; PercentDone: Integer; Cancelled: Boolean);
  public
    function execTask(const ATaskID: Integer; const progressCb, doneCb: ITiscriptFunction; const obj: ITiscriptObject): Boolean;
  end;
  {$METHODINFO OFF}
var
  UIFrameworkWindow: TUIFrameworkWindow;

implementation

{$R *.dfm}

uses
  ObjComAutoEx;

procedure TUIFrameworkWindow.DoBackWork(const Worker: IBackgroundWorker;
  State: TWorkState; Param1, Param2: Pointer; PercentDone: Integer;
  Cancelled: Boolean);
var
  i: Integer;
  LParams: PThreadParams;
begin
  case State of
    wsStart:
    begin
    
    end;
    wsWorking:
    begin
      for i := 1 to 100 do
      begin
        Sleep(100);

        //如果用户选择了取消，则退出
        if Worker.CancellationPending then
        begin
          //接受【取消】请求
          Worker.AcceptCancellation;
          Exit;
        end;

        //LParams := Worker.Data1;

        Worker.ReportProgress(i);
      end;
    end;
    wsProgress:
    begin
      if FDestroying then
      begin
        Worker.Cancel;
        Exit;
      end;

      LParams := Worker.Data1;
      LParams.progressCb.Call([PercentDone]);
    end;
    wsComplete:
    begin

      LParams := Worker.Data1;

      if not FDestroying then
      begin
        // report task completion,
        // we can pass some result data here, for now just taskId
        LParams.doneCb.Call([LParams.taskId]);
      end;
      
      Dispose(LParams);

      Worker.Data1 := nil;
    end;
    wsFeedback:
    begin
    
    end;
  end;
end;

function TUIFrameworkWindow.execTask(const ATaskID: Integer;
  const progressCb, doneCb: ITiscriptFunction; const obj: ITiscriptObject): Boolean;
var
  LParams: PThreadParams;
  LWorker: IBackgroundWorker;
  sTaskID: WideString;
//  LKey: ITiscriptValue;
begin
  Result := False;
  LParams := nil;
  try
//    for LKey in obj do
//      ShowMessage(Format('%s: %s', [LKey.S, obj.ItemEx[LKey.Value].ToJSON]));
    //ShowMessage(obj.ToJSON);
    //ShowMessage(obj);
    New(LParams);

    LParams.vm         := Layout.VM;
    LParams.taskId     := ATaskID;
    LParams.progressCb := progressCb;
    LParams.doneCb     := doneCb;

    sTaskID := IntToStr(ATaskID);

    LWorker := WorkerFactory.WorkerList.Add(sTaskID);
    LWorker.Data1 := LParams;

    LWorker.Execute(DoBackWork);

    Result := True;

  except
    on e: Exception do
    begin
      if LParams <> nil then
        Dispose(LParams);
      OutputDebugString(PChar('[TUIFrameworkWindow.OnBehaviorScriptCallCs]'+e.Message));
    end;
  end;
end;

procedure TUIFrameworkWindow.FormCreate(Sender: TObject);
begin
  inherited;
//  Behavior.ScriptingCallOptions := [scoCSSS];
  if Behavior.RttiObject = nil then
    Behavior.RttiObject := TObjectDispatchEx.Create(Self);
end;

procedure TUIFrameworkWindow.FormDestroy(Sender: TObject);
begin
  FDestroying := True;
  inherited;
end;

end.
