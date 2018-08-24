{*******************************************************************************
 标题:     SciterImpl.pas
 描述:     Sciter对外发布的全局交互对象
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterImpl;

interface

uses
  Windows, SysUtils, Classes, ShadowUtils, SciterTypes, SciterIntf, SciterBehaviorDef,
  SciterHash;

type
  TSciter = class(TInterfacedObject, ISciter)
  private
    FDestroying: Boolean;
    FTerminate: Boolean;
    FBehaviorFactorys: IBehaviorFactorys;
    FData1: Pointer;
    FData2: Pointer;
    FMainMasterFile: SciterString;
    FMainMasterPath: SciterString;
    FMsgboxHtmlFile: SciterString;
    FMsgboxCSSFile: SciterString;
    FBaseLibraryFile: SciterString;
    FMainMasterTisFile: SciterString;
    FDebugPeerFile: SciterString;
    FMainWnd: HWINDOW;

    FLoadDataProcList: TMethodList;
    FFontList: TList;

    FOnDataLoaded: TSciterDataLoadedProc;
    FOnEngineDestroyed: TSciterEngineDestroyedProc;
    FOnNotification: TSciterNotificationProc;
    FOnPostedNotification: TSciterPostedNotificationProc;
    FOnAttachBehavior: TSciterAttachBehaviorProc;
    FAfterCreateBehavior: TSciterAfterCreateBehaviorProc;
    FOnRunAppclition: TSciterRunAppclitionProc;
    FOnDebugMessage: TSciterDebugMessage;
  private
    function GetReportBehaviorCount: Boolean;
    function GetHandle: HMODULE;
    function GetMainWnd: HWINDOW;
    function GetDriverName: SciterString;
    function GetSciterClassName: SciterString;
    function GetMainMasterFile: SciterString;
    function GetMainMasterPath: SciterString;
    function GetMainMasterTisFile: SciterString;
    function GetMsgboxHtmlFile: SciterString;
    function GetMsgboxCSSFile: SciterString;
    function GetDebugPeerFile: SciterString;
    function GetBaseLibraryFile: SciterString;
    function GetSciterVersion: SciterString;
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
    function GetOnDebugMessage: TSciterDebugMessage;
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
    procedure SetOnDataLoaded(const Value: TSciterDataLoadedProc);
    procedure SetOnEngineDestroyed(const Value: TSciterEngineDestroyedProc);
    procedure SetOnNotification(const Value: TSciterNotificationProc);
    procedure SetOnPostedNotification(const Value: TSciterPostedNotificationProc);
    procedure SetOnRunAppclition(const Value: TSciterRunAppclitionProc);
    procedure SetOnDebugMessage(const Value: TSciterDebugMessage);
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    procedure _ClearFontList;

    property LoadDataProcList: TMethodList read FLoadDataProcList;
  public
    constructor Create;
    destructor Destroy; override;

    function Implementor: Pointer;

    function  AddDataLoadProc(const ADataLoadProc: TSciterLoadDataProc): Integer;
    function  RemoveDataLoadProc(const ADataLoadProc: TSciterLoadDataProc): Integer;
    procedure ClearDataLoadProcs;

    function  AddCustomFont(const AFontFile: SciterString): Cardinal;
    function  AddCustomFontFromDir(const AFontDir: SciterString): Boolean;

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

    procedure SetupShadow(AWnd: Cardinal; shadowColor: TColor);

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
    (** main master tiscript file **)
    property MainMasterTisFile: SciterString read GetMainMasterTisFile write SetMainMasterTisFile;
    (** main master path **)
    property MainMasterPath: SciterString read GetMainMasterPath;
    (** view.msgbox html file **)
    property MsgboxHtmlFile: SciterString read GetMsgboxHtmlFile write SetMsgboxHtmlFile;
    (** view.msgbox css file **)
    property MsgboxCSSFile: SciterString read GetMsgboxCSSFile write SetMsgboxCSSFile;
    (** debug-peer.tis file **)
    property DebugPeerFile: SciterString read GetDebugPeerFile write SetDebugPeerFile;
    {** tiscript custom base library file **}
    property BaseLibraryFile: SciterString read GetBaseLibraryFile write SetBaseLibraryFile;

    property BehaviorFactorys: IBehaviorFactorys read GetBehaviorFactorys;

    (** Get graphics capabilities of the system
     *
     * \pcaps[in] LPUINT \b pcaps, address of variable receiving: 
     *                             0 - no compatible graphics found;
     *                             1 - compatible graphics found but Direct2D will use WARP driver (software emulation);
     *                             2 - Direct2D will use hardware backend (best performance);
     * \return \b BOOL, \c TRUE if pcaps is valid pointer.
     *
     **)
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
    property OnDebugMessage: TSciterDebugMessage read GetOnDebugMessage write SetOnDebugMessage;
  end;

function  SciterObject: TSciter;

implementation

uses
  SciterApiImpl, SciterExportDefs,
  Messages, SciterLayout, ActiveX;

var
  varSciterObject: TSciter = nil;
  varDestroying: Boolean = False;

function  SciterObject: TSciter;
begin
  if varDestroying then
  begin
    Result := nil;
    Exit;
  end;
  if varSciterObject = nil then
    varSciterObject := TSciter.Create;
  Result := varSciterObject;
end;

{ TSciter }

function TSciter.AppendMasterCSS(utf8: PAnsiChar; numBytes: UINT): Boolean;
begin
  Result := SAPI.SciterAppendMasterCSS(utf8, numBytes);
end;

constructor TSciter.Create;
begin
  FLoadDataProcList := TMethodList.Create;
  FTerminate := False;
  FFontList := TList.Create;
end;

function TSciter.CreateDefalutHandler: IDefalutBehaviorEventHandler;
begin
  Result := TDefalutBehaviorEventHandler.Create('default');
end;

function TSciter.CreateDefalutHandler(const ABehaviorName: SciterString; 
  const Controller: Pointer; ARttiObject: IDispatchRttiObject): IDefalutBehaviorEventHandler;
begin
  Result := TDefalutBehaviorEventHandler.Create(ABehaviorName, Controller, ARttiObject);
end;

destructor TSciter.Destroy;
begin
  try
    if FDestroying then
      Exit;
    FDestroying := True;
    varDestroying := True;

    FBehaviorFactorys := nil;

    if FLoadDataProcList <> nil then
      FreeAndNil(FLoadDataProcList);
    if FFontList <> nil then
    begin
      _ClearFontList;
      FreeAndNil(FFontList);
    end;

    FreeSciter;
    varSciterObject := nil;

    FreeSAPI;

    inherited;
  except
    on E: Exception do
      TraceException('[TSciter.Destroy]'+E.Message);
  end;
end;


function TSciter.GetBehaviorFactorys: IBehaviorFactorys;
begin
  if FBehaviorFactorys = nil then
    FBehaviorFactorys := TBehaviorFactorys.Create;
  Result := FBehaviorFactorys;
end;

function TSciter.GetDriverName: SciterString;
begin                
  Result := SciterApiImpl.SciterDLLFile;
end;

function TSciter.GetGraphicsCaps: UINT;
begin
  if not SAPI.SciterGraphicsCaps(@Result) then
    Result := 0;
end;

function TSciter.GetSciterClassName: SciterString;
begin
  Result := SAPI.SciterClassName;
end;

function TSciter.GetSciterVersion: SciterString;
type
  TVer = record a, b: Word; end;
  PVer = ^TVer;
var
  verA, verB: UINT;
begin
  verA := SAPI.SciterVersion(true);
  verB := SAPI.SciterVersion(false);
  Result := WideFormat('%d.%d.%d.%d', [PVer(@verA)^.b, PVer(@verA)^.a, PVer(@verB)^.b, PVer(@verB)^.a]);
end;

procedure TSciter.SetDriverName(const Value: SciterString);
begin
  SciterApiImpl.SciterDLLFile := Value;
end;

function TSciter.SetMasterCSS(utf8: PAnsiChar; numBytes: UINT): Boolean;
begin
  Result := SAPI.SciterSetMasterCSS(utf8, numBytes);
end;

function TSciter.TranslateMessage(var lpMsg: TMsg): Boolean;
begin
  Result := SAPI.SciterTranslateMessage(lpMsg)
end;

function TSciter.TraverseUIEvent(evt: UINT;
  eventCtlStruct: LPVOID): Boolean;
begin
  Result := SAPI.SciterTraverseUIEvent(evt, eventCtlStruct)
end;

function TSciter.FilePathToURL(const FileName: SciterString): SciterString;
begin
  Result := 'file:///' + StringReplace(FileName, '\', '/', [rfReplaceAll]);
end;

function TSciter.GetNativeObjectJson(var Value: SCITER_VALUE): SciterString;
begin
  Result := SciterApiImpl.GetNativeObjectJson(Value);
end;

function TSciter.S2V(var Value: SCITER_VALUE; var OleValue: OleVariant; vm: HVM): UINT;
begin
  Result := SciterApiImpl.S2V(Value, OleValue, vm)
end;

function TSciter.V2S(const Value: OleVariant;
  var SciterValue: SCITER_VALUE; vm: HVM): UINT;
begin
  Result := SciterApiImpl.V2S(Value, SciterValue, vm)
end;

function TSciter._AddRef: Integer;
begin
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _AddRef;
end;

function TSciter._Release: Integer;
begin
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _Release;
end;

function TSciter.GetOnAttachBehavior: TSciterAttachBehaviorProc;
begin
  Result := FOnAttachBehavior;
end;

function TSciter.GetOnDataLoaded: TSciterDataLoadedProc;
begin
  Result := FOnDataLoaded;
end;

function TSciter.GetOnEngineDestroyed: TSciterEngineDestroyedProc;
begin
  Result := FOnEngineDestroyed;
end;

function TSciter.GetOnNotification: TSciterNotificationProc;
begin
  Result := FOnNotification;
end;

function TSciter.GetOnPostedNotification: TSciterPostedNotificationProc;
begin
  Result := FOnPostedNotification;
end;

procedure TSciter.SetOnAttachBehavior(
  const Value: TSciterAttachBehaviorProc);
begin
  FOnAttachBehavior := Value;
end;

procedure TSciter.SetOnDataLoaded(const Value: TSciterDataLoadedProc);
begin
  FOnDataLoaded := Value;
end;

procedure TSciter.SetOnEngineDestroyed(
  const Value: TSciterEngineDestroyedProc);
begin
  FOnEngineDestroyed := Value;
end;

procedure TSciter.SetOnNotification(const Value: TSciterNotificationProc);
begin
  FOnNotification := Value;
end;

procedure TSciter.SetOnPostedNotification(
  const Value: TSciterPostedNotificationProc);
begin
  FOnPostedNotification := Value;
end;

function TSciter.CreateDefalutHandler(
  const ABehaviorName: SciterString): IDefalutBehaviorEventHandler;
begin
  Result := TDefalutBehaviorEventHandler.Create(ABehaviorName);
end;

function TSciter.GetReportBehaviorCount: Boolean;
begin
  Result := _ReportBehaviorCount;
end;

procedure TSciter.SetReportBehaviorCount(const Value: Boolean);
begin
  _ReportBehaviorCount := Value;
end;

function TSciter.DecodeURI(const URI: SciterString): SciterString;
begin
  Result := SciterApiImpl.HTTPDecode(URI);
end;


function TSciter.EncodeURI(const URI: SciterString): SciterString;
begin
  Result := SciterApiImpl.EncodeURI(URI);
end;

procedure TSciter.Log(const ALog: SciterString);
begin
  SciterApiImpl.Log(ALog);
end;

procedure TSciter.Trace(const ALog: SciterString);
begin
  SciterApiImpl.Trace(ALog);
end;

function TSciter.S2T(vm: HVM; valuev: PSCITER_VALUE;
  var script_value: tiscript_value): Boolean;
begin
  Result := SAPI.Sciter_S2T(vm, valuev, script_value);
end;

function TSciter.T2S(vm: HVM; script_value: tiscript_value; value: PSCITER_VALUE;
  isolate: Boolean): Boolean;
begin
  Result := SAPI.Sciter_T2S(vm, script_value, value, isolate);
end;

function TSciter.GetBaseLibraryFile: SciterString;
begin
  Result := FBaseLibraryFile;
end;

procedure TSciter.SetBaseLibraryFile(const Value: SciterString);
begin
  FBaseLibraryFile := Value;
end;

function TSciter.GetAfterCreateBehavior: TSciterAfterCreateBehaviorProc;
begin
  Result := FAfterCreateBehavior;
end;

procedure TSciter.SetAfterCreateBehavior(
  const Value: TSciterAfterCreateBehaviorProc);
begin
  FAfterCreateBehavior := Value;
end;

function TSciter.GetData1: Pointer;
begin
  Result := FData1;
end;

function TSciter.GetData2: Pointer;
begin
  Result := FData2;
end;

function TSciter.GetDebugPeerFile: SciterString;
begin
  Result := FDebugPeerFile;
end;

procedure TSciter.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TSciter.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

procedure TSciter.SetDebugPeerFile(const Value: SciterString);
begin
  FDebugPeerFile := Value;
end;

function TSciter.SetMasterCSSFile(const ACSSFile: SciterString): Boolean;
var
  ms: TMemoryStream;
begin
  Result := False;
  if not FastFileExists(ACSSFile) then
    Exit;
  ms := _LoadFileToMemoryStream(ACSSFile);
  if (ms <> nil) and (ms.Memory <> nil) then
  try
    Result := Self.SetMasterCSS(PAnsiChar(ms.Memory), ms.Size);
  finally
    ms.Free;
  end;
end;

function TSciter.FindLayout(const AWnd: Cardinal): ISciterLayout;
begin
  Result := TSciterLayout(GetPropW(AWnd, PROPNAME_LAYOUT));
end;

function TSciter.FindLayoutByVM(const vm: HVM): ISciterLayout;
begin
  Result := SciterLayout.FindLayoutByVM(vm);
end;

function TSciter.GetMainMasterFile: SciterString;
begin
  Result := FMainMasterFile;
end;

procedure TSciter.SetMainMasterFile(const Value: SciterString);
begin
  FMainMasterFile := StringReplace(Value, '/', '\', [rfReplaceAll]);;
  FMainMasterPath := ExtractFilePath(FMainMasterFile);
end;

procedure TSciter.SetMainMasterTisFile(const Value: SciterString);
begin
  FMainMasterTisFile := Value;
  if FMainMasterPath = '' then
    FMainMasterPath := ExtractFilePath(FMainMasterTisFile);
end;

procedure TSciter.SetMainWnd(const Value: HWINDOW);
begin
  FMainWnd := Value;
end;

function TSciter.GetMainMasterPath: SciterString;
begin
  Result := FMainMasterPath;
end;

function TSciter.GetMainMasterTisFile: SciterString;
begin
  Result := FMainMasterTisFile;
end;

function TSciter.GetHandle: HMODULE;
begin
  Result := HInstance;
end;

function TSciter.GetMainWnd: HWINDOW;
begin
  Result := FMainWnd;
end;

procedure TSciter.LogFmt(const ALog: SciterString;
  const Args: array of const);
begin
  Log(WideFormat(ALog, Args));
end;

procedure TSciter.TraceFmt(const ALog: SciterString;
  const Args: array of const);
begin
  Trace(WideFormat(ALog, Args));
end;

{$HINTS OFF}
function TSciter.RunAppclition(const MainWnd: HWINDOW): Integer;
var
  msg: TMsg;
  bHooked, bHandled: Boolean;
begin
  Result := -1;
  FMainWnd := MainWnd;
  OleInitialize(nil); // for system drag-n-drop
  try
    bHooked := @FOnRunAppclition <> nil;
    if bHooked then
    begin
      bHandled := False;
      Result := FOnRunAppclition(MainWnd, bHandled);
      if bHandled then Exit;
    end;
    while (not FTerminate) and (FMainWnd<>0) and IsWindow(FMainWnd) do
    begin
      if not GetMessageW(msg, 0, 0, 0) then
        break;
      //if not Self.TranslateMessage(msg) then
      Windows.TranslateMessage(msg);
      Windows.DispatchMessageW(msg);
    end;
  finally
    OleUninitialize;
  end;
  Result := msg.wParam;
end;
{$HINTS ON}

procedure TSciter.ProcessMessages;
  function _ProcessMessage(var Msg: TMsg): Boolean;
  begin
    Result := (not FTerminate) and PeekMessageW(Msg, 0, 0, 0, PM_REMOVE);
    if Result then
    begin
      Result := Msg.Message <> WM_QUIT;
      if Result then
      begin
        TranslateMessage(Msg);
        DispatchMessageW(Msg);
      end
      else
        FTerminate := True;
    end;
  end;
var
  Msg: TMsg;
begin
  while _ProcessMessage(Msg) do {loop};
end;

procedure TSciter.Terminate;
begin
  FTerminate := True;
  PostQuitMessage(0);
end;

function TSciter.GetMsgboxCSSFile: SciterString;
begin
  Result := FMsgboxCSSFile;
end;

procedure TSciter.SetMsgboxCSSFile(const Value: SciterString);
begin
  FMsgboxCSSFile := Value;
end;

function TSciter.GetMsgboxHtmlFile: SciterString;
begin
  Result := FMsgboxHtmlFile;
end;

procedure TSciter.SetMsgboxHtmlFile(const Value: SciterString);
begin
  FMsgboxHtmlFile := Value;
end;

function TSciter.DataReadyAsync(const hwnd: HWINDOW; uri: SciterString;
  data: LPCBYTE; dataLength: UINT; requestId: LPVOID): Boolean;
begin
  Result := SAPI.SciterDataReadyAsync(hwnd, PWideChar(uri), data, dataLength, requestId);
end;

function TSciter.Implementor: Pointer;
begin
  Result := Self;
end;

function TSciter.AddDataLoadProc(
  const ADataLoadProc: TSciterLoadDataProc): Integer;
begin
  Result := FLoadDataProcList.Add(TMethod(ADataLoadProc));
end;

procedure TSciter.ClearDataLoadProcs;
begin
  FLoadDataProcList.Clear;
end;

function TSciter.RemoveDataLoadProc(
  const ADataLoadProc: TSciterLoadDataProc): Integer;
begin
  if FLoadDataProcList <> nil then
    Result := FLoadDataProcList.Remove(TMethod(ADataLoadProc))
  else
    Result := -1;
end;

procedure TSciter.SetupShadow(AWnd: Cardinal; shadowColor: TColor);
begin
  ShadowUtils.SetupShadow(AWnd, shadowColor);
end;

function TSciter.GetOnRunAppclition: TSciterRunAppclitionProc;
begin
  Result := FOnRunAppclition;
end;

procedure TSciter.SetOnRunAppclition(const Value: TSciterRunAppclitionProc);
begin
  FOnRunAppclition := Value;
end;

function TSciter.GetOnDebugMessage: TSciterDebugMessage;
begin
  Result := FOnDebugMessage;
end;

procedure TSciter.SetOnDebugMessage(const Value: TSciterDebugMessage);
begin
  FOnDebugMessage := Value;
end;

procedure TSciter._ClearFontList;
var
  i: Integer;
begin
  if FFontList = nil then Exit;
  for i := FFontList.Count - 1 downto 0 do
  try
    RemoveFontMemResourceEx(Cardinal(FFontList[i]))
  except
  end;
  FFontList.Clear;
end;

function TSciter.AddCustomFont(const AFontFile: SciterString): Cardinal;
var
  hFont, dwFonts: Cardinal;
  ms: TMemoryStream;
begin
  Result := 0;
  if not FileExists(AFontFile) then Exit;
  if GetGraphicsCaps >= 2 then Exit;
  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(AFontFile);
    if ms.Size <= 0 then Exit;
    dwFonts := 0;
    hFont := AddFontMemResourceEx(ms.Memory, ms.Size, nil, @dwFonts);
    if hFont <> 0 then
    begin
      if FFontList.IndexOf(Pointer(hFont)) < 0 then
        FFontList.Add(Pointer(hFont));
    end
    else
      TraceFmt('font [%s] install fail: %s', [AFontFile, SysErrorMessage(GetLastError)]);
  finally
    ms.Free;
  end;
end;

function TSciter.AddCustomFontFromDir(const AFontDir: SciterString): Boolean;
var
  oSearchRec: TSearchRec;
  sDir: WideString;
begin
  Result := False;
  if GetGraphicsCaps >= 2 then Exit;
  sDir := IncludeTrailingPathDelimiter(AFontDir);
  if FindFirst(sDir + '*.*', faAnyFile, oSearchRec) = 0 then
  try
    repeat
      if (oSearchRec.Name = '.') or (oSearchRec.Name = '..') then
        continue;
      if (oSearchRec.Attr and faDirectory) <> 0 then
        Continue;
      if LowerCase(ExtractFileExt(oSearchRec.Name)) <> '.ttf' then
        Continue;
      AddCustomFont(sDir + oSearchRec.Name);
    until FindNext(oSearchRec) <> 0;
    Result := True;
  finally
    SysUtils.FindClose(oSearchRec);
  end;
end;

end.
