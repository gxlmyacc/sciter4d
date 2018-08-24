{*******************************************************************************
 标题:     SciterNativeMethods.pas
 描述:     向Sciter注册的内置函数
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterNativeMethods;

interface

uses
  SysUtils, Windows, SciterTypes, SciterFactoryIntf, SciterIntf, TiscriptIntf;

function _ActiveXObject(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _NativeObject(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _FreeNativeObject(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;

function _URLEncode(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _FileExist(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _DirExist(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _ForceDir(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _SetupShadow(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _RoundWindow(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _EnbaleMinToTaskbar(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;

function _GetCommandLine(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _NRequrie(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _UnloadPlugin(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;

function _SetTimeout(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _SetTimer(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
function _KillTimer(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;

implementation

uses
  SciterApiImpl, TiscriptApiImpl, TiscriptOle, SciterLayout, ComObj, ShadowUtils,
  RoundUtils, TiscriptClass, SciterExportDefs, SciterPluginIntf, SciterTimerMgr;
  
function _ActiveXObject(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  oVal: IDispatch;
  sProgId: SciterString;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    sProgId := args[0].S;
    oVal := ComObj.CreateOleObject(sProgId);
    if oVal = nil then  Exit;
    Result := TTiscriptValue.Create(vm, __Tiscript.WrapObject(oVal, vm));
  except
    on E:Exception do
    begin
      TraceException('[_ActiveXObject]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _WrapDomValueArray(vm: HVM; argCount: Integer; args: PTiscriptValueArray): TDynDomValueArray;
var
  i: Integer;
begin
  if argCount <= 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  SetLength(Result, argCount);
  for i := 0 to argCount -1 do
    Result[i] := __ValueFactory.Create(vm, args[i].Value);
end;

function _NativeObject(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  sObjectName: SciterString;
  LDispatch: IDispatch;
  LOnCreateNativeObject: TTiscriptCreateNativeObjectProc;
  LLayout: TSciterLayout;
  LArgCount: Integer;
  LDomArgs: TDynDomValueArray;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    sObjectName := args[0].S;
    
    LArgCount := argCount - 1;
    LLayout := FindLayoutByVM(vm);
    if (LLayout <> nil) and (@LLayout.OnCreateNativeObject <> nil) then
    begin
      if LArgCount <= 0 then
        LDispatch := LLayout.OnCreateNativeObject(LLayout, sObjectName, 0, nil)
      else
      begin
        LDomArgs := _WrapDomValueArray(vm, LArgCount, @args[1]);
        LDispatch := LLayout.OnCreateNativeObject(LLayout, sObjectName, LArgCount, PSciterDomValueArray(LDomArgs));
        SetLength(LDomArgs, 0);
      end;
      if LDispatch <> nil then
      begin
        Result := TTiscriptValue.Create(vm, __Tiscript.WrapObject(LDispatch, vm));
        Exit;
      end;
    end;

    LOnCreateNativeObject := Tiscript.OnCreateNativeObject;
    if @LOnCreateNativeObject <> nil then
    begin
      if LArgCount <= 0 then
        LDispatch := LOnCreateNativeObject(vm, sObjectName, 0, nil)
      else
        LDispatch := LOnCreateNativeObject(vm, sObjectName, LArgCount, @args[1]);
      Result := TTiscriptValue.Create(vm, __Tiscript.WrapObject(LDispatch, vm));
    end;
  except
    on E:Exception do
    begin
      TraceException('[_NativeObject]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _FreeNativeObject(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  tProgId: ITiscriptValue;
  sObjectName: SciterString;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    tProgId := args[0];

    if tProgId.IsNativeObject then
      _OleFinalizerHandler(vm, tProgId.Value)
    else
    if tProgId.IsString then
    begin
      sObjectName := tProgId.S;
      TiscriptApiImpl.UnRegisterVariable(vm, sObjectName);
    end;
  except
    on E:Exception do
    begin
      TraceException('[_FreeNativeObject]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _URLEncode(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  sURL: SciterString;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    sURL := EncodeURI(args[0].S);
    Result := __Tiscript.Current.S(sURL);
  except
    on E:Exception do
    begin
      TraceException('[_URLEncode]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _FileExist(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    Result := __Tiscript.Current.B(FastFileExists(args[0].S));
  except
    on E:Exception do
    begin
      TraceException('[_FileExist]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _DirExist(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    Result := __Tiscript.Current.B(DirectoryExists(args[0].S));
  except
    on E:Exception do
    begin
      TraceException('[_DirExist]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _ForceDir(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
begin
  Result := nil;
  try
    if argCount < 1 then Exit;
    Result := __Tiscript.Current.B(ForceDirectories(args[0].S));
  except
    on E:Exception do
    begin
      TraceException('[_ForceDir]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _SetupShadow(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
  function Size(cx, cy: Integer): TSize;
  begin
    Result.cx := cx;
    Result.cy := cy;
  end;
var
  LLayout: TSciterLayout;
  t: ITiscriptValue;
  sz, rx: Integer;
  LRound: TRoundWindow;
  he: IDomElement;
  hwnd: HWINDOW;
begin
  Result := __Tiscript.Current.B(False);
  try
    hwnd := 0;
    if argCount >= 2 then
    begin
      t :=  args[1];
      if t.IsNativeObject and t.IsElement then
      begin
        he := ElementFactory.Create(t.E);
        hwnd := he.GetElementHwnd(True);
      end;
    end
    else
    begin
      LLayout := FindLayoutByVM(vm);
      if (LLayout <> nil) and LLayout.IsValid and (GetParent(LLayout.Hwnd) = 0) then
        hwnd := LLayout.Hwnd;
    end;
    if (hwnd <> 0) and IsWindow(hwnd) then
    begin
      sz := DefaultShadowSize;
      rx := 0;
      if argCount >= 1 then
        sz := args[0].I;
      if sz < 0 then
        sz := DefaultShadowSize;
      LRound := HasRound(hwnd);
      if LRound <> nil then
      begin
        rx := LRound.RX;
      end;
      if HasShadow(hwnd) = nil then
        SetupShadow(hwnd, clBlack, rx, sz);
      Result := __Tiscript.Current.B(True);
    end;
  except
    on E:Exception do
    begin
      TraceException('[_SetupShadow]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _RoundWindow(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  LLayout: TSciterLayout;
  rcWindow: TRect;
  he: IDomElement;
  t: ITiscriptValue;
  rx, ry: Integer;
  hwnd: HWINDOW;
begin
  Result := __Tiscript.Current.B(False);
  try
    hwnd := 0;
    if argCount >= 2 then
    begin
      t :=  args[1];
      if t.IsElement then
      begin
        he := ElementFactory.Create(t.E);
        hwnd := he.GetElementHwnd(True);
      end;
    end
    else
    begin
      LLayout := FindLayoutByVM(vm);
      if (LLayout <> nil) and LLayout.IsValid and (GetParent(LLayout.Hwnd) = 0) then
        hwnd := LLayout.Hwnd;
    end;
    if (hwnd<>0) and IsWindow(hwnd) then
    begin             
      Assert(argCount >= 1);
      rx := args[0].I;
      if rx < 0 then Exit;
      ry := rx;
      GetClientRect(hwnd, rcWindow);
      RoundWindow(hwnd, rx, ry);
      Result := __Tiscript.Current.B(True);
    end;
  except
    on E:Exception do
    begin
      TraceException('[_RoundWindow]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _EnbaleMinToTaskbar(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  LLayout: TSciterLayout;
  he: IDomElement;
  t: ITiscriptValue;
  hwnd: HWINDOW;
  dwStyle: Cardinal;
begin
  Result := __Tiscript.Current.B(False);
  try
    hwnd := 0;
    if argCount >= 1 then
    begin
      t :=  args[0];
      if t.IsElement then
      begin
        he := ElementFactory.Create(t.E);
        hwnd := he.GetElementHwnd(True);
      end;
    end
    else
    begin
      LLayout := FindLayoutByVM(vm);
      if (LLayout <> nil) and LLayout.IsValid and (GetParent(LLayout.Hwnd) = 0) then
        hwnd := LLayout.Hwnd;
    end;
    if (hwnd<>0) and IsWindow(hwnd) then
    begin
      dwStyle := GetWindowLong(hwnd, GWL_STYLE);
      if (dwStyle and WS_MINIMIZEBOX) = 0 then
        SetWindowLong(hwnd, GWL_STYLE, dwStyle or WS_MINIMIZEBOX);
      Result := __Tiscript.Current.B(True);
    end;
  except
    on E:Exception do
    begin
      TraceException('[_EnbaleMinToTaskbar]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _GetCommandLine(vm: HVM; this, super: ITiscriptObject;
    argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  i: Integer;
  sParams: SciterString;
  LArray: ITiscriptArray;
begin
  Result := __Tiscript.Current.V(ni.create_array(vm, 0));
  try
    LArray := Result.A;
    for i := 1 to ParamCount do
    begin
      sParams := ParamStr(i);
      LArray.Push(sParams);
    end;
  except
    on E:Exception do
    begin
      TraceException('[_GetCommandLine]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _NRequrie(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  LInfo: TSciterSchemaInfo;
  LPlugin: ISciterPlugin;
  LDispatch: IDispatch;
begin
  Result := _NativeObject(vm, this, super, argCount, args, tag);
  try
    if (Result <> nil) and Result.B then Exit;
    if argCount < 1 then Exit;
    if not UrlParseSchema(args[0].S, LInfo, True) then Exit;
    if (not LInfo.IsPlugin) or (not FileExists(LInfo.Path)) then Exit;
    if not SciterLayout.LoadPluginByPath(LInfo.Path) then Exit;

    LPlugin := __SciterPluginList.ItemByPath[LInfo.Path];
    if LPlugin = nil then Exit;

    LDispatch := LPlugin.Require(LInfo.Params);
    if LDispatch <> nil then
      Result := TTiscriptValue.Create(vm, _WrapOleObject(vm, LDispatch));
  except
    on E:Exception do
    begin
      TraceException('[_NRequrie]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _UnloadPlugin(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  LInfo: TSciterSchemaInfo;
  idx: Integer;
begin
  Result := __Tiscript.Current.B(False);
  try
    if argCount < 1 then Exit;
    if not UrlParseSchema(args[0].S, LInfo, True) then Exit;
    if (not LInfo.IsPlugin) or (not FileExists(LInfo.Path)) then Exit;

    idx := __SciterPluginList.IndexOfPath(LInfo.Path);
    if idx >= 0 then
    begin
      if not __SciterPluginList^[idx].CanUnload then Exit;
      __SciterPluginList.Delete(idx);
    end;
    Result := __Tiscript.Current.B(True);
  except
    on E:Exception do
    begin
      TraceException('[_UnloadPlugin]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

procedure _SetTimeoutProc(hwnd: HWND; uMsg: UINT; aRec: PTimerRec; dwTime: DWORD); stdcall;
begin
  try
    TimerMananger.KillTimer(aRec);
    if aRec.code <> nil then
      aRec.code.TryCall([]);
  except
    on E: Exception do
      TraceException('[_SetTimeoutProc]'+E.Message);
  end;
end;

function _SetTimeout(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  milliseconds: Integer;
  callback: ITiscriptFunction;
  avoidSameOriginCheck: Boolean;
begin
  Result := __Tiscript.Current.Undefined;
  try
    if (argCount < 1) or (not args[0].IsFunction) then Exit;
    callback := args[0].F;
    if argCount >= 2 then milliseconds := args[1].I
    else milliseconds := 10;
    if milliseconds < 10 then milliseconds := 10;
    if argCount >= 3 then
      avoidSameOriginCheck := args[2].B
    else
      avoidSameOriginCheck := False;
    TimerMananger.Timer(milliseconds, callback, @_SetTimeoutProc, avoidSameOriginCheck);
  except
    on E:Exception do
    begin
      TraceException('[_SetTimeout]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

procedure _SciterTimerProc(hwnd: HWND; uMsg: UINT; aRec: PTimerRec; dwTime: DWORD); stdcall;
var
  code: ITiscriptFunction;
  ret: ITiscriptValue;
begin
  try
    code := aRec.code;
    if (not code.TryCall([], ret)) or (not ret.IsTrue) then
      TimerMananger.KillTimer(aRec);
  except
    on E: Exception do
      TraceException('[_SciterTimerProc]'+E.Message);
  end;
end;

function _SetTimer(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
var
  milliseconds: Integer;
  callback: ITiscriptFunction;
  avoidSameOriginCheck: Boolean;
begin
  Result := __Tiscript.Current.I(0);
  try
    if (argCount < 1) or (not args[0].IsFunction) then Exit;
    callback := args[0].F;
    if argCount >= 2 then
      milliseconds := args[1].I
    else
      milliseconds := 0;
    if argCount >= 3 then
      avoidSameOriginCheck := args[2].B
    else
      avoidSameOriginCheck := False;
      
    if milliseconds = 0 then
      TimerMananger.KillTimer(args[1].F)
    else
      Result := __Tiscript.Current.I(TimerMananger.Timer(milliseconds, callback, @_SciterTimerProc, avoidSameOriginCheck));
  except
    on E:Exception do
    begin
      TraceException('[_SetTimer]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

function _KillTimer(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
begin
  Result := __Tiscript.Current.B(False);
  try
    if (argCount < 1) then Exit;
    if args[0].IsInt then
      Result := __Tiscript.Current.B(TimerMananger.KillTimer(args[0].I))
    else
    if args[0].IsFunction then
      Result := __Tiscript.Current.B(TimerMananger.KillTimer(args[0].F));
  except
    on E:Exception do
    begin
      TraceException('[_KillTimer]'+e.Message);
      ThrowError(vm, E.Message);
    end;
  end;
end;

end.
