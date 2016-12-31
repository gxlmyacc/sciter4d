unit DesktopUtils;

interface

uses
  SysUtils, Classes, Windows, CommCtrl, Messages;

type
  TWindowOSType = (windowUnknown, windows95, windows98, windowsMe, windowsNT351,
    windowsNT40, windows2000, windowsXP, windows2003, windowsVista, windows7,
    windows8, windows10
  );

  PLVItem64 = ^TLVItem64;
  TLVItem64 = record
    mask: UINT;
    iItem: Integer;
    iSubItem: Integer;
    state: UINT;
    stateMask: UINT;
    placeholder1: Integer;
    pszText: PAnsiChar;
    placeholder11: Integer;
    cchTextMax: Integer;
    iImage: Integer;
    lParam: LPARAM;
    placeholder2: Integer;
    iIndent: Integer;
  end;
  
  TDesktopManager = class
  protected
    FDeskWnd: HWND;
    FDeskProcess: THandle;
    FDeskBuffer: Pointer;
    
    function GetIsWin64: Boolean;
    function GetWindowOS: TWindowOSType;
    function GetItemCount: Integer;
  protected
    function FindDesktopWnd: HWND;

    function GetLVItemSize: Integer; virtual; abstract;
    function GetItemCaption(const AItem, ASubItem: Integer): string; virtual; abstract;
    function GetItemRect(const AItem: Integer): TRect; virtual;

    property LVItemSize: Integer read GetLVItemSize;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    //显示桌面
    procedure ShowDesktop;

    //根据桌面图标名称返回该图标的索引
    function IndexOfItemCaption(const ACaption: string): Integer;

    //桌面列表控件的句柄
    property DeskWnd: HWND read  FDeskWnd;
    //操作系统类型
    property WindowOS: TWindowOSType read GetWindowOS;
    //是否是64位系统
    property IsWin64: Boolean read GetIsWin64;

    //桌面图标项数量
    property ItemCount: Integer read GetItemCount;
    //根据索引获取桌面图标的标题
    property ItemCaption[const AItem, ASubItem: Integer]: string read GetItemCaption;
    //根据索引获取桌面图标的区域矩形
    property ItemRect[const AItem: Integer]: TRect read GetItemRect;
  end;

  TDesktopManager32 = class(TDesktopManager)
  protected
    function GetLVItemSize: Integer; override;
    function GetItemCaption(const AItem, ASubItem: Integer): string; override;
  public
    constructor Create; override;
  end;

  TDesktopManager64 = class(TDesktopManager)
  protected
    function GetLVItemSize: Integer; override;
    function GetItemCaption(const AItem, ASubItem: Integer): string; override;
  public
    constructor Create; override;
  end;

function DesktopManager: TDesktopManager;

implementation

var
  varIsWin64: Boolean;
  varWindowOS: TWindowOSType;
  varDesktopManager: TDesktopManager;

function DesktopManager: TDesktopManager;
begin
  if varDesktopManager = nil then
  begin
    if varIsWin64 then
      varDesktopManager := TDesktopManager64.Create
    else
      varDesktopManager := TDesktopManager32.Create;
  end;

  Result := varDesktopManager;
end;

procedure RtlGetNtVersionNumbers(var dwMajorVer, dwMinorVer, dwBuildNumber: DWORD); stdcall; external 'ntdll.dll';

function _GetWindowsOS: TWindowOSType; //读取操作系统版本
var
  AWin32Version: Extended;
  dwMajorVersion, dwMinorVersion, dwBuildNumber: DWORD;
begin
  RtlGetNtVersionNumbers(dwMajorVersion, dwMinorVersion, dwBuildNumber);
  AWin32Version := StrtoFloat(format('%d.%d' ,[dwMajorVersion, dwMinorVersion]));

  Result := windowUnknown;
  if Win32Platform=VER_PLATFORM_WIN32_WINDOWS then
  begin
    if AWin32Version=4.0 then
      Result := windows95
    else
    if AWin32Version=4.1 then
      Result := windows98
    else
    if AWin32Version=4.9 then
      Result := windowsMe;
  end
  else
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    if AWin32Version=3.51 then
      Result := windowsNT351
    else
    if AWin32Version=4.0 then
      Result := windowsNT40
    else
    if AWin32Version=5.0 then
      Result := windows2000
    else
    if AWin32Version=5.1 then
      Result := windowsXP
    else
    if AWin32Version=5.2 then
      Result := windows2003
    else
    if AWin32Version=6.0 then
      Result := windowsVista
    else
    if AWin32Version=6.1 then
      Result := windows7
    else
    if AWin32Version=6.3 then
      Result := windows8
    else
    if AWin32Version=10 then
      Result := windows10;
  end;
end;

function _IsWin64: Boolean;   
var  
  Kernel32Handle: THandle;   
  IsWow64Process: function(Handle: Windows.THandle; var Res: Windows.BOOL): Windows.BOOL; stdcall;   
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;   
  isWoW64: Bool;   
  SystemInfo: TSystemInfo;   
const  
  PROCESSOR_ARCHITECTURE_AMD64 = 9;   
  PROCESSOR_ARCHITECTURE_IA64 = 6;   
begin  
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');   
  if Kernel32Handle = 0 then  
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');   
  if Kernel32Handle <> 0 then  
  begin  
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');   
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');   
    if Assigned(IsWow64Process) then  
    begin  
      IsWow64Process(GetCurrentProcess,isWoW64);   
      Result := isWoW64 and Assigned(GetNativeSystemInfo);   
      if Result then  
      begin  
        GetNativeSystemInfo(SystemInfo);   
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or  
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);   
      end;   
    end  
    else Result := False;   
  end  
  else Result := False;   
end; 

{ TDesktopManager }

constructor TDesktopManager.Create;
var
  dwProcessId: Cardinal;
begin
  FDeskWnd := FindDesktopWnd;
  if FDeskWnd = 0 then
    raise Exception.Create('桌面窗口句柄未找到！');

  //保存桌面的进程ID
  GetWindowThreadProcessId(FDeskWnd, @dwProcessId);
  //打开桌面进程
  FDeskProcess := OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwProcessId);

  FDeskBuffer := VirtualAllocEx(FDeskProcess, nil, 1024, MEM_COMMIT, PAGE_READWRITE)
end;

destructor TDesktopManager.Destroy;
begin
  if FDeskProcess <> 0 then
  begin
    if FDeskBuffer <> nil then
    begin
      VirtualFreeEx(FDeskProcess, FDeskBuffer, 0, MEM_RELEASE);
    end;

    CloseHandle(FDeskProcess);
    FDeskProcess := 0;
  end;

  inherited;
end;

function TDesktopManager.FindDesktopWnd: HWND;
var
  hWin: HWND;
  bufClassName: PChar;
begin
  Result := 0;

  bufClassName := GetMemory(256);
  try
    hWin := FindWindow('Progman', 'Program Manager');
    if (hWin = 0) or (GetWindow(hWin, GW_CHILD) = 0) then
    begin
      repeat
        GetClassName(hWin, bufClassName, 255);
        if bufClassName = 'WorkerW' then
        begin
          if GetWindow(hWin, GW_CHILD) <> 0 then
            Break
        end;
        hWin := GetNextWindow(hWin, GW_HWNDNEXT);
      until hWin = 0;      
    end;
    if hWin = 0 then
      Exit;

    //取得窗体的下一个HWND
    GetClassName(hWin, bufClassName, 255);
    if Trim(bufClassName) <> 'SHELLDLL_DefView' then
    begin
      hWin := GetWindow(hWin, GW_CHILD);
      GetClassName(hWin, bufClassName, 255);
    end;

    while Trim(bufClassName) <> 'SHELLDLL_DefView' do
    begin
      if hWin <> 0 then
      begin
        hWin := GetNextWindow(hWin, GW_HWNDNEXT);
        GetClassName(hWin, bufClassName, 255);
      end
      else
      begin
        Result := hWin;
        Exit;
      end;
    end;
    hWin := GetWindow(hWin, GW_CHILD);
    GetClassName(hWin, bufClassName, 255);
    while Trim(bufClassName) <> 'SysListView32' do
    begin
      if hWin <> 0 then
      begin
        hWin := GetNextWindow(hWin, GW_HWNDNEXT);
        GetClassName(hWin, bufClassName, 255);
      end
      else
      begin
        Result := hWin;
        Exit;
      end;
    end;
    Result := hWin;
  finally
    FreeMem(bufClassName);
  end;
end;

function TDesktopManager.GetItemCount: Integer;
begin
  Assert(FDeskWnd<>0);
  Result := ListView_GetItemCount(FDeskWnd);
end;

function TDesktopManager.GetIsWin64: Boolean;
begin
  Result := varIsWin64;
end;

function TDesktopManager.GetWindowOS: TWindowOSType;
begin
  Result := varWindowOS;
end;

function TDesktopManager.GetItemRect(const AItem: Integer): TRect;
var
  bBytes: {$IF CompilerVersion > 15.0 }SIZE_T{$ELSE}Cardinal{$IFEND};
begin
  Assert(FDeskWnd<>0);
  Assert(FDeskProcess<>0);

  ZeroMemory(@Result, SizeOf(TRect));
  //往进程写入内存
  WriteProcessMemory(FDeskProcess, FDeskBuffer, @Result, SizeOf(TRect), bBytes);
  //获取桌面图标的区域信息
  SendMessage(FDeskWnd, LVM_GETITEMRECT, AItem, Integer(FDeskBuffer));
  //读取桌面图标区域信息
  ReadProcessMemory(FDeskProcess, FDeskBuffer, @Result, SizeOf(TRect), bBytes);
end;

function TDesktopManager.IndexOfItemCaption(
  const ACaption: string): Integer;
var
  i: Integer;
begin
  for i := 0 to GetItemCount - 1 do
  begin
    if SameText(GetItemCaption(i, 0), ACaption)  then
    begin
      Result := i;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TDesktopManager.ShowDesktop;
begin
  SendMessage(FindWindow('Shell_TrayWnd', nil), WM_COMMAND,  419, 0);//显示桌面
  keybd_event(VK_F5, 0, KEYEVENTF_KEYUP, 0);  //刷新桌面
end;

{ TDesktopManager32 }

constructor TDesktopManager32.Create;
begin
  Assert(not varIsWin64);
  inherited;
end;

function TDesktopManager32.GetItemCaption(const AItem,
  ASubItem: Integer): string;
var
  LItem: TLVItem;
  pDeskText, pszText: PChar;
  bBytes: {$IF CompilerVersion > 15.0 }SIZE_T{$ELSE}Cardinal{$IFEND};
begin
  Assert(FDeskWnd<>0);
  Assert(FDeskProcess<>0);
  
  pDeskText := VirtualAllocEx(FDeskProcess, nil, 512, MEM_COMMIT, PAGE_READWRITE);
  try
    LItem.cchTextMax := 512;
    LItem.iSubItem   := ASubItem;
    LItem.pszText    := pDeskText;

    //往进程写入内存
    WriteProcessMemory(FDeskProcess, FDeskBuffer, @LItem, LVItemSize, bBytes);
    //获取桌面图标的名称
    SendMessage(FDeskWnd, LVM_GETITEMTEXT, AItem, Integer(FDeskBuffer));
    //读取桌面图标的名称
    pszText := GetMemory(512);
    try
      ReadProcessMemory(FDeskProcess, pDeskText, pszText, 512, bBytes);

      Result := pszText;
    finally
      FreeMemory(pszText);
    end;
  finally
    VirtualFreeEx(FDeskProcess, pDeskText, 0, MEM_RELEASE);
  end;
end;

function TDesktopManager32.GetLVItemSize: Integer;
begin
  Result := SizeOf(TLVItem)
end;

{ TDesktopManager64 }

constructor TDesktopManager64.Create;
begin
  Assert(varIsWin64);
  inherited;
end;

function TDesktopManager64.GetItemCaption(const AItem,
  ASubItem: Integer): string;
var
  LItem: TLVItem64;
  pDeskText, pszText: PAnsiChar;
  bBytes: {$IF CompilerVersion > 15.0 }SIZE_T{$ELSE}Cardinal{$IFEND};
begin
  Assert(FDeskWnd<>0);
  Assert(FDeskProcess<>0);
  
  pDeskText := VirtualAllocEx(FDeskProcess, nil, 512, MEM_COMMIT, PAGE_READWRITE);
  try
    LItem.cchTextMax := 512;
    LItem.iSubItem   := ASubItem;
    LItem.pszText    := pDeskText;

    //往进程写入内存
    WriteProcessMemory(FDeskProcess, FDeskBuffer, @LItem, LVItemSize, bBytes);
    //获取桌面图标的名称
    SendMessage(FDeskWnd, LVM_GETITEMTEXT, AItem, Integer(FDeskBuffer));
    //读取桌面图标的名称
    pszText := GetMemory(512);
    try
      ReadProcessMemory(FDeskProcess, pDeskText, pszText, 512, bBytes);
      Result := {$IF CompilerVersion > 18.5}UTF8ToString{$IFEND}(pszText);
    finally
      FreeMemory(pszText);
    end;
  finally
    VirtualFreeEx(FDeskProcess, pDeskText, 0, MEM_RELEASE);
  end;
end;

function TDesktopManager64.GetLVItemSize: Integer;
begin
  Result := SizeOf(TLVItem64)
end;

initialization
  varIsWin64  := _IsWin64;
  varWindowOS := _GetWindowsOS;

finalization
  if varDesktopManager <> nil then
    FreeAndNil(varDesktopManager);

end.
