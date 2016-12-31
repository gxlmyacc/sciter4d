unit WkeImportDefs;

interface

uses
  Windows;

const
  DLL_Wke4D     = 'Wke4D.dll';
  DLL_Wke       = 'Wke.dll';
  CLASSNAME_WKE = 'gxl.wke4d7.class';
  WkeExports_FuncsCount = 1;

  //function Wke: PWke;
  FuncIdx_Wke = 0;

type
  PDynPointerArray = ^TDynPointerArray;
  TDynPointerArray = array of Pointer;

  PPWkeExports = ^PWkeExports;
  PWkeExports = ^TWkeExports;
  TWkeExports = record
    Flags: array[0..1] of AnsiChar;
    Instance: HMODULE;
    InitWkeExports: procedure(const Api: PPWkeExports; const Instance: HINST);
    FinalWkeExports: procedure(const Api: PPWkeExports; const Instance: HINST);
    FuncsCount: Integer;
    Funcs: TDynPointerArray;
  end;

{$IFNDEF Wke4D}
function LoadWke4D(ADllPath: string = DLL_Wke4D): Boolean;
procedure UnloadWke4D;
{$ENDIF}

function WkeEnabled: Boolean;
function WkeExports: PWkeExports;
procedure WkeClearRef;

implementation

uses
  SysUtils{$IFDEF Wke4D}, WkeExportDefs{$ENDIF};

var
  varWkeExports: PWkeExports = nil;
  varDLLHandle: THandle = 0;

function WkeEnabled: Boolean;
begin
  Result := varWkeExports <> nil;
end;

function WkeExports: PWkeExports;
begin
  Result := varWkeExports;
end;

procedure WkeClearRef;
begin
  varWkeExports := nil;
end;

{$IFNDEF Wke4D}
function LoadWke4D(ADllPath: string = DLL_Wke4D): Boolean;
var
  wc: TWndClassA;
begin
  Result := False;
  try
    if WkeEnabled then
    begin
      Result := True;
      Exit;
    end;
    if GetClassInfoA(SysInit.HInstance, CLASSNAME_WKE, wc) then
    begin
      varWkeExports := PWkeExports(wc.lpfnWndProc);
      varWkeExports.InitWkeExports(@varWkeExports, SysInit.HInstance);
      Result := True;
      Exit;
    end;
    if not FileExists(ADllPath) then
    begin
      OutputDebugString(PChar('[' + ADllPath + ']加载失败：[' + ADllPath + ']不存在！'));
      Exit;
    end;
    varDLLHandle := LoadLibrary(PChar(ADllPath));
    if varDLLHandle < 32 then
    begin
      OutputDebugString(PChar('[' + ADllPath + ']加载失败：' + SysErrorMessage(GetLastError)));
      Exit;
    end;
    try
      if GetClassInfoA(SysInit.HInstance, CLASSNAME_WKE, wc) then
      begin
        varWkeExports := PWkeExports(wc.lpfnWndProc);
        varWkeExports.InitWkeExports(@varWkeExports, SysInit.HInstance);
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
      OutputDebugString(PChar('[LoadWke4D]' + E.Message));
  end;
end;

procedure UnloadWke4D;
begin
  try
    if varDLLHandle > 0 then
    begin
      if varWkeExports <> nil then
      try
        varWkeExports.FinalWkeExports(@varWkeExports, SysInit.HInstance);
      except
        on E: Exception do
          OutputDebugString(PChar('[FinalWkeExports]' + E.Message));
      end;
      varWkeExports := nil;
      FreeLibrary(varDLLHandle);
      varDLLHandle := 0;
    end;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[UnloadWke4D]' + E.Message));
    end
  end;
end;
{$ENDIF}

initialization
{$IFDEF Wke4D}
  varWkeExports := @WkeExportDefs.varWkeExports;
{$ELSE}
  if IsLibrary then
    LoadWke4D;
{$ENDIF}

finalization
  varWkeExports := nil;
{$IFNDEF Wke4D}
  UnloadWke4D;
{$ENDIF}

end.


