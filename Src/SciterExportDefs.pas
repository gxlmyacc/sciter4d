{*******************************************************************************
 标题:     SciterExportDefs.pas
 描述:     导出接口定义
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterExportDefs;

interface

uses
  SciterImportDefs, SciterTypes, SciterIntf, SciterDebugIntf, TiscriptIntf,
  SciterVideoIntf, Classes, Windows, SysUtils, SciterFactoryIntf, SciterWndIntf,
  SciterGraphicIntf, SciterRequestIntf, SciterDirectXIntf, SciterPluginIntf,
  SciterDomainIntf, SciterURIIntf, SciterArchiveIntf, SciterImpl;
                          
var
  varSciterApi: TSciterApi;
  
procedure _RegSciterClass;
procedure _UnregSciterClass;

procedure FreeSciter;
function  __SciterEnable: Boolean;
function  __Sciter: PISciter;
function  __CreateVideoSource(const AData: Pointer): IVideoSource;
function  __CreateVideoDestination(const AData: Pointer): IVideoDestination;
function  __CreateFragmentedVideoDestination(const AData: Pointer): IFragmentedVideoDestination;
function  __Tiscript: PITiscript;
function  __GetDebugOut: PIDebugOutput;
procedure __SetDebugOut(const Value: IDebugOutput);
function __ElementFactory: PISciterElementFactory;
function __NodeFactory: PISciterNodeFactory;
function __ValueFactory: PISciterValueFactory;
function __LayoutFactory: PISciterLayoutFactory;
function __CreateRequest(h: HREQUEST): ISciterRequest;
function __SciterDirectX: PISciterDirectX;
function __SciterPluginList: PISciterPluginList;
function __SciterTopDomain: PISciterDomain;
function __SciterCreateURI(const AURI: SciterString = ''): ISciterURI;
function __CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags;
  const frame: TRect; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow;
function __SciterGraphicFactory: PISciterGraphicFactory;
function __SciterArchive: PISciterArchive;

procedure _InitSciterApi(const Api: PPSciterApi; const Instance: HINST);
procedure _FinalSciterApi(const Api: PPSciterApi; const Instance: HINST);

function  _VMIsInited(const vm: HVM): Boolean;
procedure _InitVM(const vm: HVM);
function  _LoadFileToMemoryStream(const AFileName: string): TMemoryStream;
function  _load_resource_data(hinst: HMODULE; uri: LPCWSTR; var bp: LPCBYTE; var cb: UINT): Boolean;

implementation

uses
  SciterDebugImpl, SciterApiImpl, SciterVideoImpl, SciterFactoryImpl, TiscriptApiImpl,
  SciterWndImpl, TiscriptImpl, SciterGraphicImpl, SciterRequestImpl,
  SciterDirectXImpl, SciterPluginImpl, SciterDomainImpl, SciterNativeMethods,
  SciterURIImpl, SciterArchiveImpl;

var
  varWC: TWndClassA;

  varSciter: ISciter = nil;
  varTiscript: ITiscript = nil;
  varDebugOut: IDebugOutput = nil;
  varElementFactory: ISciterElementFactory = nil;
  varNodeFactory: ISciterNodeFactory = nil;
  varValueFactory: ISciterValueFactory = nil;
  varLayoutFactory: ISciterLayoutFactory = nil;
  varSciterGraphicFactory: ISciterGraphicFactory = nil;
  varSDirectX: ISciterDirectX = nil;
  varPluginList: ISciterPluginList = nil;
  varTopDomain: ISciterDomain = nil;
  varArchive: ISciterArchive = nil;

procedure  FreeSciter;
begin
  varSciter := nil;
end;

function  __SciterEnable: Boolean;
begin
  Result := varSciter <> nil;
end;

function __Sciter: PISciter;
begin
  if varSciter = nil then
    varSciter := SciterObject;
  Result := @varSciter;
end;

function  __Tiscript: PITiscript;
begin
  if varTiscript = nil then
    varTiscript := TTiscript.Create;
  Result := @varTiscript;
end;

function  __CreateVideoSource(const AData: Pointer): IVideoSource;
begin
  Result := TVideoSource.Create(AData);
end;

function  __CreateVideoDestination(const AData: Pointer): IVideoDestination;
begin
  Result := TVideoDestination.Create(AData);
end;

function  __CreateFragmentedVideoDestination(const AData: Pointer): IFragmentedVideoDestination;
begin
  Result := TFragmentedVideoDestination.Create(AData);
end;

function  __GetDebugOut: PIDebugOutput;
begin
  if varDebugOut = nil then
    varDebugOut := TDebugOutput.Create;
  Result := @varDebugOut;
end;

procedure __SetDebugOut(const Value: IDebugOutput);
begin
  if Value = varDebugOut then
    Exit;

  if varDebugOut <> nil then
  begin
    varDebugOut.SetupOff;
    varDebugOut := nil;
  end;
  
  varDebugOut := Value;
end;


function __ElementFactory: PISciterElementFactory;
begin
  if varElementFactory = nil then
    varElementFactory := TSciterElementFactory._Create;
  Result := @varElementFactory;
end;

function __NodeFactory: PISciterNodeFactory;
begin
  if varNodeFactory = nil then
    varNodeFactory := TSciterNodeFactory._Create;
  Result := @varNodeFactory;
end;

function __ValueFactory: PISciterValueFactory;
begin
  if varValueFactory = nil then
    varValueFactory := TSciterValueFactory._Create;
  Result := @varValueFactory;
end;

function __LayoutFactory: PISciterLayoutFactory;
begin
  if varLayoutFactory = nil then
    varLayoutFactory := TSciterLayoutFactory._Create;
  Result := @varLayoutFactory;
end;

function __CreateRequest(h: HREQUEST): ISciterRequest;
begin
  Result := TSciterRequest.Create(h);
end;

function __CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags; const frame: TRect;
    parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow;
begin
  Result := TSciterWindow.Create(AInstance, creationFlags, frame, parent, AWndProc);
end;

function __SciterGraphicFactory: PISciterGraphicFactory;
begin
  if varSciterGraphicFactory = nil then
    varSciterGraphicFactory := TSciterGraphicFactory.Create;
  Result := @varSciterGraphicFactory;
end;

function __SciterDirectX: PISciterDirectX;
begin
  if varSDirectX = nil then
    varSDirectX := TSciterDirectX.Create;
  Result := @varSDirectX;
end;

function __SciterPluginList: PISciterPluginList;
begin
  if varPluginList = nil then
    varPluginList := TSciterPluginList.Create;
  Result := @varPluginList;
end;

function __SciterTopDomain: PISciterDomain;
begin
  if varTopDomain = nil then
  begin
    varTopDomain := TSciterDomain.Create('root');
    varTopDomain.Add(DOMAIN_Sciter4D, ExcludeTrailingPathDelimiter(SciterModulePath));
    varTopDomain.Add(DOMAIN_App, ExcludeTrailingPathDelimiter(SciterMainModulePath));
  end;
  Result := @varTopDomain;
end;

function __SciterCreateURI(const AURI: SciterString): ISciterURI;
begin
  Result := TSciterURI.Create(AURI);
  Result.OnToFilePath := TSciterDomain(__SciterTopDomain.Implementator).URIToFilePath;
end;

function __SciterArchive: PISciterArchive;
begin
  if varArchive = nil then
    varArchive := TSciterArchive.Create;
  Result := @varArchive;
end;

function _LoadFileToMemoryStream(const AFileName: string): TMemoryStream;
var
  fs: TFileStream;
  bom: array[0..2] of Byte;
  bufferw: array of WideChar;
  iSize: Integer;
begin
  Result := nil;
  try
    {$WARNINGS OFF}
    fs := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyRead);
    {$WARNINGS ON}
    try
      Result := TMemoryStream.Create;
      try
        if fs.Size < 3 then Exit;

        fs.Read(bom, sizeof(bom));
        fs.Position := 0;
        if (bom[0] = $FF) and (bom[1] = $FE) then  //unicode
        begin
          fs.Position := 2;
          SetLength(bufferw, (fs.Size-2) div 2);
          fs.ReadBuffer(bufferw[0], fs.Size-2);
          iSize := WideCharToMultiByte(CP_UTF8, 0, @bufferw[0], Length(bufferw), nil, 0, nil, nil);
          if iSize <= 0 then
            Exit;
          Result.SetSize(iSize);
          WideCharToMultiByte(CP_UTF8, 0, @bufferw[0], Length(bufferw), Result.Memory, Result.Size, nil, nil);
        end
        else
        begin  //Ansi or utf8
          if (bom[0] = $EF) and (bom[1] = $BB) and (bom[2] = $BF) then  //utf-8
            fs.Position := 3
          else
            fs.Position := 0;
          Result.CopyFrom(fs, fs.Size-fs.Position);
        end;
        Result.Position := 0;
      except
        if Result <> nil then
          FreeAndNil(Result);
        raise;
      end;
    finally
      fs.Free;
    end;
  except
    on E: Exception do
      TraceException('[_LoadFileToMemoryStream]'+E.Message);
  end;
end;

const
  vm_inited = '__vm_inited';
function  _VMIsInited(const vm: HVM): Boolean;
var
  b: Boolean;
begin
  Result := (vm <> nil) and ni.get_bool_value(ni.get_prop(vm, ni.get_global_ns(vm), ni.symbol_value(vm_inited)), b) and b;
end;

procedure _InitVM(const vm: HVM);
var
  bp: LPCBYTE;
  cb: UINT;
  ms: TMemoryStream;
  sMasterTisFile: string;
  sMasterConent: UTF8String;
  utf8: UTF8String;
  sScript: SciterString;
  retval: tiscript_value;
  i: Integer;
  LVariableItem: ITiscriptVariableItem;
begin
  if vm = nil then Exit;
  if _VMIsInited(vm) then Exit;
  ni.set_prop(vm, ni.get_global_ns(vm), ni.symbol_value(vm_inited), ni.bool_value(True));

  SAPI.SciterSetupDebugOutput(0, nil, @_SciterDebug);

  // regisiter native functions
  RegisterNativeFunction(vm, 'ActiveXObject', @_ActiveXObject);
  RegisterNativeFunction(vm, 'NativeObject', @_NativeObject);
  RegisterNativeFunction(vm, 'freeNativeObject', @_FreeNativeObject);
  RegisterNativeFunction(vm, 'encodeURL', @_URLEncode);
  RegisterNativeFunction(vm, 'fileExist', @_FileExist);
  RegisterNativeFunction(vm, 'dirExist', @_DirExist);
  RegisterNativeFunction(vm, 'forceDir', @_ForceDir);
  RegisterNativeFunction(vm, 'setupShadow', @_SetupShadow);
  RegisterNativeFunction(vm, 'roundWindow', @_RoundWindow);
  RegisterNativeFunction(vm, 'enableMinToTaskbar', @_EnbaleMinToTaskbar);
  RegisterNativeFunction(vm, 'getCommandLine', @_GetCommandLine);
  RegisterNativeFunction(vm, 'nrequire', @_NRequrie);
  RegisterNativeFunction(vm, 'unloadPlugin', @_UnloadPlugin);
  RegisterNativeFunction(vm, 'setTimeout', @_SetTimeout);
  RegisterNativeFunction(vm, 'setTimer', @_SetTimer);
  RegisterNativeFunction(vm, 'killTimer', @_KillTimer);
  for i := 0 to GlobalVariables.Count - 1 do
  begin
    LVariableItem := GlobalVariables^[i];
    case LVariableItem.Type_ of
      tvtFunction: RegisterNativeFunction(vm, LVariableItem.Name, @LVariableItem.Function_, LVariableItem.Tag);
      tvtObject: TiscriptApiImpl.RegisterObject(vm, LVariableItem.Object_, LVariableItem.Name);
    end;
  end;

  //menu support chinese language
  if _load_resource_data(SysInit.HInstance, PWideChar(SciterString('res:menuLang_zh.css')), bp, cb) then
    varSciter.AppendMasterCSS(PAnsiChar(bp), cb);
  sMasterTisFile := varSciter.MainMasterTisFile;
  if FastFileExists(sMasterTisFile) then
    sMasterConent := UTF8Encode(Format('html { aspect: MasterScript(url:"master:%s") url(res:masterscript.tis); }',
      [ExtractFileName(sMasterTisFile)]))
  else
    sMasterConent := 'html { aspect: MasterScript(url:null) url(res:masterscript.tis); }';
  varSciter.AppendMasterCSS(PAnsiChar(sMasterConent), Length(sMasterConent));

//  sMasterConent := 'wallpaper {display:block; display-model:block-inside; }';
//  sMasterConent := sMasterConent + sLineBreak + 'wallpaper, .wallpaper {background-repeat:no-repeat; prototype:Wallpaper url(res:wallpaper.tis);}';
//  varSciter.AppendMasterCSS(PAnsiChar(sMasterConent), Length(sMasterConent));
  if (varSciter.MainMasterFile <> EmptyStr) and (FastFileExists(varSciter.MainMasterFile)) then
  begin
    ms := _LoadFileToMemoryStream(varSciter.MainMasterFile);
    if ms <> nil then
    try
      varSciter.AppendMasterCSS(ms.Memory, ms.Size);
    finally
      ms.Free;
    end;
  end;

  if _load_resource_data(SysInit.HInstance, 'res:sciter4d_rtl.tis', bp, cb) then
  begin
    SetLength(utf8, cb);
    CopyMemory(PAnsiChar(utf8), bp, cb);
    sScript := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(utf8);
    if not ni.eval_string(vm, ni.get_global_ns(vm), PWideChar(sScript), Length(sScript), retval) then
      Trace('load sciter4d_rtl.tis failed!');
  end;
  if FastFileExists(varSciter.BaseLibraryFile) then
  begin
    ms := _LoadFileToMemoryStream(varSciter.BaseLibraryFile);
    if (ms <> nil) and (ms.Memory <> nil) then
    try
      SetLength(sMasterConent, ms.Size);
      CopyMemory(PAnsiChar(sMasterConent), ms.Memory, ms.Size);
      sScript := {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(sMasterConent);
      ni.eval_string(vm, ni.get_global_ns(vm), PWideChar(sScript), Length(sScript), retval);
    finally
      ms.Free;
    end;
  end;
end;

procedure _RegSciterClass;
begin
  varSciterApi.Flags          := 'SC';
  varSciterApi.Instance       := SysInit.HInstance;
  varSciterApi.InitSciterApi  := _InitSciterApi;
  varSciterApi.FinalSciterApi := _FinalSciterApi;
  varSciterApi.FuncsCount     := SciterApi_FuncsCount;
  varSciterApi.Funcs[FuncIdx_Sciter]                     := @__Sciter;
  varSciterApi.Funcs[FuncIdx_CreateVideoSource]          := @__CreateVideoSource;
  varSciterApi.Funcs[FuncIdx_CreateVideoDestination]     := @__CreateVideoDestination;
  varSciterApi.Funcs[FuncIdx_FragmentedVideoDestination] := @__CreateFragmentedVideoDestination;
  varSciterApi.Funcs[FuncIdx_Tiscript]                   := @__Tiscript;
  varSciterApi.Funcs[FuncIdx_GetDebugOut]                := @__GetDebugOut;
  varSciterApi.Funcs[FuncIdx_SetDebugOut]                := @__SetDebugOut;
  varSciterApi.Funcs[FuncIdx_ElementFactory]             := @__ElementFactory;
  varSciterApi.Funcs[FuncIdx_NodeFactory]                := @__NodeFactory;
  varSciterApi.Funcs[FuncIdx_ValueFactory]               := @__ValueFactory;
  varSciterApi.Funcs[FuncIdx_LayoutFactory]              := @__LayoutFactory;
  varSciterApi.Funcs[FuncIdx_CreateWindow]               := @__CreateWindow;
  varSciterApi.Funcs[FuncIdx_SciterGraphicFactory]       := @__SciterGraphicFactory;
  varSciterApi.Funcs[FuncIdx_CreateRequest]              := @__CreateRequest;
  varSciterApi.Funcs[FuncIdx_SciterDirectX]              := @__SciterDirectX;
  varSciterApi.Funcs[FuncIdx_SciterPluginList]           := @__SciterPluginList;
  varSciterApi.Funcs[FuncIdx_SciterTopDomain]            := @__SciterTopDomain;
  varSciterApi.Funcs[FuncIdx_SciterCreateURI]            := @__SciterCreateURI;
  varSciterApi.Funcs[FuncIdx_SciterWindowList]           := @__SciterWindowList;
  varSciterApi.Funcs[FuncIdx_SciterArchive]              := @__SciterArchive;

  FillChar(varWC, SizeOf(varWC), 0);
  varWC.lpszClassName := CLASSNAME_SCITER4D;
  varWC.style         := CS_GLOBALCLASS;
  varWC.hInstance     := SysInit.HInstance;
  varWC.lpfnWndProc   := @varSciterApi;

  if Windows.RegisterClassA(varWC)=0 then
    Halt;
end;

procedure _UnregSciterClass;
begin
  Windows.UnregisterClassA(CLASSNAME_SCITER4D, SysInit.HInstance);
end;

procedure _InitSciterApi(const Api: PPSciterApi; const Instance: HINST);
begin

end;

procedure _FinalSciterApi(const Api: PPSciterApi; const Instance: HINST);
begin

end;

// loads data from resource section of hinst library.
// accepts "name.ext" and "res:name.ext" uri's
function _load_resource_data(hinst: HMODULE; uri: LPCWSTR; var bp: LPCBYTE; var cb: UINT): Boolean;
var
  sUrl, sName, sExt: string;
  hrsrc: Windows.HRSRC;
  hgres: Windows.HGLOBAL;
begin
  Result := False;
  if (uri  = nil) or (uri[0] = #0) then
    Exit;

  sUrl := uri;

  // Retrieve url specification into a local storage since FindResource() expects 
  // to find its parameters on stack rather then on the heap under Win9x/Me
  if Pos('res:', sUrl) = 1 then
    sUrl := Copy(sUrl, 5, MaxInt);

  if Pos('//', sUrl) = 1 then
    sUrl := Copy(sUrl, 3, MaxInt);

  if Pos('\\', sUrl) = 1 then
    sUrl := Copy(sUrl, 3, MaxInt);

  sName := StringReplace(sUrl, '-', '_', [rfReplaceAll]);

  // Separate extension if any
  if Pos('.', sName) > 0 then
  begin
    sExt := Copy(sName, Pos('.', sName)+1, MaxInt);
    sName := Copy(sName, 1, Pos('.', sName)-1);

    if sExt = EmptyStr then
      Exit;
  end;

  // Find specified resource and leave if failed. Note that we use extension
  // as the custom resource type specification or assume standard HTML resource 
  // if no extension is specified
  hrsrc := FindResource(hinst, PChar(sName), PChar(sExt));
  if hrsrc = 0 then
  begin
    hrsrc := FindResource(HInstance, PChar(sName), PChar(sExt));
    if hrsrc = 0 then
      Exit  // resource not found here - proceed with default loader
    else
      hinst := HInstance;
  end;
  // Load specified resource and check if ok
  hgres := LoadResource(hinst, hrsrc);
  if hgres = 0 then Exit;

  // Retrieve resource data and check if ok
  bp := LPCBYTE(LockResource(hgres));
  if bp = nil then Exit;
  cb := SizeofResource(hinst, hrsrc);
  if cb = 0 then Exit;

  Result := True;
end;


initialization
  _RegSciterClass;

finalization
  try
    varArchive := nil;
    varSciterGraphicFactory := nil;
    varSDirectX := nil;
    varPluginList := nil;
    varTopDomain := nil;
    varElementFactory := nil;
    varNodeFactory := nil;
    varValueFactory := nil;
    varLayoutFactory := nil;
    varDebugOut := nil;
    varTiscript := nil;
    varSciter := nil;
    _UnregSciterClass;
  except
    on E: Exception do
      TraceException('[SciterExportDefs][finalization]'+e.Message);
  end;

end.
