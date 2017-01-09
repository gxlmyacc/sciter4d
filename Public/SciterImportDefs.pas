{*******************************************************************************
 标题:     SciterImportDefs.pas
 描述:     sciter4D组件引导加载
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterImportDefs;

interface

uses
  Windows;

const
{$IFDEF CPUX64}
  DLL_Sciter = 'sciter64.dll';
{$ELSE}
  DLL_Sciter = 'sciter32.dll';
{$ENDIF}
  DLL_Sciter4D       = 'Sciter4D.dll';
  CLASSNAME_SCITER4D = 'gxl.sciter4.delphi.class';

  SciterApi_FuncsCount               = 19;

  //function Sciter: PSciter;
  FuncIdx_Sciter                     =  0;
  //function  CreateVideoSource(const AData: Pointer): IVideoSource;
  FuncIdx_CreateVideoSource          =  1;
  //function  CreateVideoDestination(const AData: Pointer): IVideoDestination;
  FuncIdx_CreateVideoDestination     =  2;
  //function  FragmentedVideoDestination(const AData: Pointer): IFragmentedVideoDestination;
  FuncIdx_FragmentedVideoDestination =  3;
  //function Tiscript: PITiscript;
  FuncIdx_Tiscript                   =  4;
  //function  GetDebugOut: PIDebugOutput;
  FuncIdx_GetDebugOut                =  5;
  //procedure SetDebugOut(const Value: IDebugOutput);
  FuncIdx_SetDebugOut                =  6;
  //function ElementFactory: PISciterElementFactory;
  FuncIdx_ElementFactory             =  7;
  //function NodeFactory: PISciterNodeFactory;
  FuncIdx_NodeFactory                =  8;
  //function ValueFactory: PISciterValueFactory;
  FuncIdx_ValueFactory               =  9;
  //function LayoutFactory: PISciterLayoutFactory;
  FuncIdx_LayoutFactory              = 10;
  //function CreateWindow(AInstance: HMODULE; creationFlags: TSciterCreateWindowFlags; const frame: TRect; parent: HWINDOW = 0; AWndProc: TSciterWndProc = nil): ISciterWindow;
  FuncIdx_CreateWindow               = 11;
  //function SciterGraphicFactory(): PISciterGraphicFactory;
  FuncIdx_SciterGraphicFactory       = 12;
  //function CreateRequest(h: HREQUEST): ISciterRequest;
  FuncIdx_CreateRequest              = 13;
  //function SciterDirectX: PISciterDirectX;
  FuncIdx_SciterDirectX              = 14;
  //function SciterPluginList: PISciterPluginList;
  FuncIdx_SciterPluginList           = 15;
  //function SciterTopDomain: PISciterDomains;
  FuncIdx_SciterTopDomain            = 16;
  //function SciterCreateURI(const AURI: SciterString = ''): ISciterURI;
  FuncIdx_SciterCreateURI            = 17;
  //function SciterWindowList(): PISciterWindowList;
  FuncIdx_SciterWindowList           = 18;

type
  PSciterFuncArray = ^TSciterFuncArray;
  TSciterFuncArray = array[0..SciterApi_FuncsCount-1] of Pointer;
  
  PPSciterApi = ^PSciterApi;
  PSciterApi = ^TSciterApi;
  TSciterApi = record
    Flags: array[0..1] of AnsiChar;
    Instance: HMODULE;
    InitSciterApi:  procedure (const Api: PPSciterApi; const Instance: HINST);
    FinalSciterApi: procedure (const Api: PPSciterApi; const Instance: HINST);
    FuncsCount: Integer;
    Funcs: TSciterFuncArray;
  end;

{$IFNDEF Sciter4D}
function  LoadSciter4D(ADllPath: string = DLL_Sciter4D): Boolean;
procedure UnloadSciter4D;
{$ENDIF}
function SciterEnabled: Boolean;
function SciterApi: PSciterApi;

implementation

uses
{$IFDEF Sciter4D}
  SciterExportDefs;
{$ELSE}
  SysUtils;
{$ENDIF}

var
  varSciterApi: PSciterApi;
  varDLLHandle: THandle = 0;
  
function SciterEnabled: Boolean;
begin
  Result := varSciterApi <> nil;
end;

function  SciterApi: PSciterApi;
begin
  Result := varSciterApi;
end;

{$IFNDEF Sciter4D}
function  LoadSciter4D(ADllPath: string): Boolean;
var
  wc: TWndClassA;
begin
  Result := False;
  try
    if SciterEnabled then
    begin
      Result := True;
      Exit;
    end;
    if GetClassInfoA(SysInit.HInstance, CLASSNAME_SCITER4D, wc) then
    begin
      varSciterApi := PSciterApi(wc.lpfnWndProc);
      varSciterApi.InitSciterApi(@varSciterApi, SysInit.HInstance);
      Result := True;
      Exit;
    end;
    if not FileExists(ADllPath) then
    begin
      OutputDebugString(PChar('[' + ADllPath + ']加载失败：['+ADllPath+']不存在！'));
      Exit;    
    end;

    varDLLHandle := LoadLibrary(PChar(ADllPath));
    if varDLLHandle < 32 then
    begin
      OutputDebugString(PChar('[' + ADllPath + ']加载失败：'+ SysErrorMessage(GetLastError)));
      Exit;
    end;
    try
      if GetClassInfoA(SysInit.HInstance, CLASSNAME_SCITER4D, wc) then
      begin
        varSciterApi := PSciterApi(wc.lpfnWndProc);
        varSciterApi.InitSciterApi(@varSciterApi, SysInit.HInstance);
      end
      else
      begin
        OutputDebugString(PChar('[' + ADllPath + ']加载失败：未找到全局注册信息！'));
        Exit;
      end;
      Result := True;
    finally
      if not Result then
      begin
        FreeLibrary(varDLLHandle);
        varDLLHandle := 0;
      end;
    end;
  except
    on E: Exception do
      OutputDebugString(PChar('[LoadSciter4D]'+E.Message));
  end;
end;

procedure UnloadSciter4D;
begin
  try
    if varDLLHandle > 0 then
    begin
      if varSciterApi <> nil then
      try
        varSciterApi.FinalSciterApi(@varSciterApi, SysInit.HInstance);
      except
        on E: Exception do
          OutputDebugString(PChar('[FinalSpringApi]'+E.Message));
      end;
      FreeLibrary(varDLLHandle);
      varDLLHandle := 0;
    end;
    varSciterApi := nil;
  except
    on E: Exception do
      OutputDebugString(PChar('[UnloadSciter4D]'+E.Message));
  end;
end;
{$ENDIF}

initialization
  IsMultiThread := True;
{$IFDEF Sciter4D}
  varSciterApi := @SciterExportDefs.varSciterApi;
{$ELSE}
  if IsLibrary or FileExists(DLL_Sciter) then
    LoadSciter4D;
{$ENDIF}

finalization
{$IFDEF Sciter4D}
  varSciterApi := nil;
{$ELSE}
  UnloadSciter4D;
{$ENDIF}
   
end.
