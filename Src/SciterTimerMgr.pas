{*******************************************************************************
 标题:     SciterTimerMgr.pas
 描述:     一个计时器管理对象
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterTimerMgr;

interface

uses
  SysUtils, Classes, Windows, Messages, TiscriptIntf;

type
  PTimerRec = ^TTimerRec;

  TSciterTimerProc = procedure (hwnd: HWND; uMsg: UINT; aRec: PTimerRec; dwTime: DWORD); stdcall;

  TTimerRec = record
    Active: Boolean;
    Destroyed: Boolean;
    code: ITiscriptFunction;
    millisec: Integer;
    timerId: Integer;
    timerFunc: TSciterTimerProc;
  end;
  
  TSciterTimerMananger = class
  private
    FTimerWnd: HWND;
    FTimerRecList: TList;
  protected
    procedure DoClearTimers;
    procedure DoTimerWndProc(var Message: TMessage);
    procedure DoKillTimer(const aRec: PTimerRec; const aIndex: Integer);
  public
    constructor Create();
    destructor Destroy; override;

    function KillTimer(callback: ITiscriptFunction): Boolean; overload;
    function KillTimer(timerId: Integer): Boolean; overload;
    function KillTimer(aRec: PTimerRec): Boolean; overload;
    function Timer(milliseconds: Integer; callback: ITiscriptFunction;
      timerFunc: TSciterTimerProc; avoidSameOriginCheck: Boolean = False): Integer;
  end;

function TimerMananger: TSciterTimerMananger;

implementation

uses
  SciterApiImpl;

var
  varTimerMananger: TSciterTimerMananger;

function TimerMananger: TSciterTimerMananger;
begin
  if varTimerMananger = nil then
    varTimerMananger := TSciterTimerMananger.Create;
  Result := varTimerMananger;
end;

procedure _InternalTimerProc(hwnd: HWND; uMsg: UINT; aRec: PTimerRec; dwTime: DWORD); stdcall;
begin
  try
    aRec.Active := True;
    try
      aRec.timerFunc(hwnd, uMsg, aRec, dwTime);
    finally
      aRec.Active := False;
      if aRec.Destroyed then
      try
        Dispose(aRec);
      except
      end;
    end;
  except
    on E: Exception do
      TraceException('[_InternalTimerProc]'+E.Message);
  end;
end;
  
{ TSciterTimerMananger }

procedure TSciterTimerMananger.DoClearTimers;
var
  i: Integer;
begin
  for i := FTimerRecList.Count - 1 downto 0 do
    DoKillTimer(PTimerRec(FTimerRecList[i]), i);
  FTimerRecList.Clear;
end;

constructor TSciterTimerMananger.Create;
begin
  FTimerRecList := TList.Create;
  FTimerWnd := AllocateHWnd(DoTimerWndProc);
end;

destructor TSciterTimerMananger.Destroy;
begin
  DoClearTimers;
  FreeAndNil(FTimerRecList);
  DeallocateHWnd(FTimerWnd);
  inherited;
end;

function TSciterTimerMananger.KillTimer(callback: ITiscriptFunction): Boolean;
var
  i: Integer;
  LRec: PTimerRec;
begin
  Result := False;
  try
    for i := FTimerRecList.Count - 1 downto 0 do
    begin
      LRec := PTimerRec(FTimerRecList[i]);
      if LRec.code.Value = callback.Value then
      begin
        DoKillTimer(LRec, i);
        Result := True;
        Break;
      end;
    end;
  except
    on E:Exception do
    begin
      E.Message := '[TSciterTimerMananger.KillTimer]'+e.Message;
      raise;
    end;
  end;
end;

function TSciterTimerMananger.KillTimer(timerId: Integer): Boolean;
var
  i: Integer;
  LRec: PTimerRec;
begin
  Result := False;
  try
    for i := FTimerRecList.Count - 1 downto 0 do
    begin
      LRec := PTimerRec(FTimerRecList[i]);
      if LRec.timerId = timerId then
      begin
        DoKillTimer(LRec, i);
        Result := True;
        Break;
      end;
    end;
  except
    on E:Exception do
    begin
      E.Message := '[TSciterTimerMananger.KillTimer]'+e.Message;
      raise;
    end;
  end;
end;

function TSciterTimerMananger.KillTimer(aRec: PTimerRec): Boolean;
var
  i: Integer;
begin
  Result := False;
  try
    for i := FTimerRecList.Count - 1 downto 0 do
    begin
      if PTimerRec(FTimerRecList[i]) = aRec then
      begin
        DoKillTimer(aRec, i);
        Result := True;
        Break;
      end;
    end;
  except
    on E:Exception do
    begin
      E.Message := '[TSciterTimerMananger.KillTimer]'+e.Message;
      raise;
    end;
  end;
end;

function TSciterTimerMananger.Timer(milliseconds: Integer;
  callback: ITiscriptFunction; timerFunc: TSciterTimerProc; avoidSameOriginCheck: Boolean): Integer;
var
  LRec: PTimerRec;
begin
  Result := 0;
  try
    if avoidSameOriginCheck then
      KillTimer(callback);
    New(LRec);
    LRec.Active := False;
    LRec.Destroyed := False;
    LRec.code := callback;
    LRec.millisec := milliseconds;
    LRec.timerFunc := timerFunc;
    LRec.timerId := Windows.SetTimer(FTimerWnd, Cardinal(LRec), LRec.millisec, @_InternalTimerProc);
    if LRec.timerId = 0 then
    begin
      Dispose(LRec);
      Exit;
    end;
    FTimerRecList.Add(LRec);
    Result := LRec.timerId;
  except
    on E:Exception do
    begin
      E.Message := '[TSciterTimerMananger.Timer]'+e.Message;
      raise;
    end;
  end;
end;

procedure TSciterTimerMananger.DoTimerWndProc(var Message: TMessage);
begin
  Message.Result := DefWindowProc(FTimerWnd, Message.Msg, Message.WParam, Message.LParam);
end;

procedure TSciterTimerMananger.DoKillTimer(const aRec: PTimerRec; const aIndex: Integer);
begin
  try
    FTimerRecList.Delete(aIndex);
    Windows.KillTimer(FTimerWnd, aRec.timerId);
    if aRec.Active then
      aRec.Destroyed := True
    else
      Dispose(aRec);
  except
    on E: Exception do
      TraceException('[TSciterTimerMananger.DoKillTimer]'+E.Message);
  end;
end;



initialization

finalization
  if varTimerMananger <> nil then
    FreeAndNil(varTimerMananger);

end.
