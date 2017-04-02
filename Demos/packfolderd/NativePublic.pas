unit NativePublic;

interface

uses
  Windows, Classes, SysUtils;

type
  TDynStringArray = array of string;


//阻塞调用外部程序
function WinExecAndWait32(const AFile, ACMDLine: WideString; sCurrentDir: WideString = ''; AShowMode: Integer = SW_SHOWNORMAL;
  ARunAs: Boolean = False): Boolean;
function WinExecute(const AFile, ACMDLine: WideString; sCurrentDir: WideString = ''; AShowMode: Integer = SW_SHOWNORMAL;
  ARunAs: Boolean = False): Cardinal;

type
  PShellExecuteInfoW  = ^TShellExecuteInfoW;
  TShellExecuteInfoW = record
    cbSize: DWORD;
    fMask: ULONG;
    Wnd: HWND;
    lpVerb: PWideChar;
    lpFile: PWideChar;
    lpParameters: PWideChar;
    lpDirectory: PWideChar;
    nShow: Integer;
    hInstApp: HINST;
    { Optional fields }
    lpIDList: Pointer;
    lpClass: PWideChar;
    hkeyClass: HKEY;
    dwHotKey: DWORD;
    hIcon: THandle;
    hProcess: THandle;
  end;

function ShellExecuteExW(lpExecInfo: PShellExecuteInfoW): BOOL; stdcall; external 'shell32.dll';
function ShellExecuteW(hWnd: HWND; Operation, FileName, Parameters,
   Directory: PWideChar; ShowCmd: Integer): HINST; stdcall; external 'shell32.dll';
procedure RtlGetNtVersionNumbers(var dwMajorVer, dwMinorVer, dwBuildNumber: DWORD); stdcall; external 'ntdll.dll';

//字符串保存到文件
procedure StrSaveToFile(sStr: AnsiString; AFileName: string);
//从文件加载字符串
function StrLoadFromFile(AFileName: string): string;
//字符串保存到流
procedure StrSaveToStream(sStr: AnsiString; AStream: TStream);
//从流加载字符串
function StrLoadFromStream(AStream: TStream): string;
//流保存到文件
procedure StreamSaveToFile(AStream: TStream; AFileName: string);
//从文件加载到流
procedure StreamLoadFromFile(var AStream: TStream; AFileName: string);

function ExtractRes(ResName, ResType, ResNewName: string): Boolean;

implementation

function WinExecute(const AFile, ACMDLine: WideString; sCurrentDir: WideString = ''; AShowMode: Integer = SW_SHOWNORMAL;
  ARunAs: Boolean = False): Cardinal;
const
  SEE_MASK_NOCLOSEPROCESS = $00000040;
var
  sei: TShellExecuteInfoW;
  dwMajorVersion, dwMinorVersion, dwBuildNumber: DWORD;
  AWin32Version: Extended;
begin
  Result := 0;
  RtlGetNtVersionNumbers(dwMajorVersion, dwMinorVersion, dwBuildNumber);
  AWin32Version := StrtoFloat(format('%d.%d' ,[dwMajorVersion, dwMinorVersion]));
  if (sCurrentDir = '') and (AFile <> '') then
  begin
    sCurrentDir := ExtractFileDir(AFile);
    if not DirectoryExists(sCurrentDir) then
      sCurrentDir := '';
  end;
  if AWin32Version >= 3.51 then
  begin
    ZeroMemory(@sei, SizeOf(TShellExecuteInfoW));
    sei.cbSize       := SizeOf(TShellExecuteInfoW);
    sei.fMask        := SEE_MASK_NOCLOSEPROCESS;
    if ARunAs then
      sei.lpVerb     := 'runas';
    sei.lpFile       := PWideChar(AFile);
    sei.lpParameters := PWideChar(ACMDLine);
    sei.lpDirectory  := PWideChar(sCurrentDir);
    sei.nShow := AShowMode;
    if not ShellExecuteExW(@sei) then Exit;
    Result := sei.hProcess;
  end
  else
  begin
    Result := ShellExecuteW(0, 'open', PWideChar(AFile), PWideChar(ACMDLine), PWideChar(sCurrentDir), AShowMode);
  end;
end;
  
function WinExecAndWait32(const AFile, ACMDLine: WideString; sCurrentDir: WideString; AShowMode: Integer; ARunAs: Boolean): Boolean;
var
  hProcess: THandle;
  ExitCode: DWORD;
begin
  hProcess := WinExecute(AFile, ACMDLine, sCurrentDir, AShowMode, ARunAs);
  Result := hProcess >= 32;
  if Result then
  begin
    WaitforSingleObject(hProcess,INFINITE);
    GetExitCodeProcess(hProcess, ExitCode);
    Exit;
  end;
end;

procedure StrSaveToFile(sStr: AnsiString; AFileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    StrSaveToStream(sStr, Stream);
  finally
    Stream.Free;
  end;
end;

function StrLoadFromFile(AFileName: string): string;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := StrLoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure StrSaveToStream(sStr: AnsiString; AStream: TStream);
begin
  AStream.WriteBuffer(Pointer(sStr)^, Length(sStr));
end;

function StrLoadFromStream(AStream: TStream): string;
var
  Size: Integer;
  S: AnsiString;
begin
  Size := AStream.Size - AStream.Position;
  SetString(S, nil, Size);
  AStream.Read(Pointer(S)^, Size);
  Result := string(S);
end;

procedure StreamSaveToFile(AStream: TStream; AFileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmCreate);
  try
    Stream.CopyFrom(AStream, AStream.Size);
  finally
    Stream.Free;
  end;
end;

procedure StreamLoadFromFile(var AStream: TStream; AFileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    AStream.CopyFrom(Stream, Stream.Size);
  finally
    Stream.Free;
  end;
end;

function ExtractRes(ResName, ResType, ResNewName: string): Boolean;
var
  Res: TResourceStream;
begin
  try
    Res := TResourceStream.Create(Hinstance, Resname, PChar(ResType));
    try
      Res.SavetoFile(ResNewName);
      Result := true;
    finally
      Res.Free;
    end;
  except
    Result := false;
  end;
end;
end.

