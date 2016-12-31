unit unitHook;

interface

uses
  Windows, Messages, Classes, SysUtils;

type
  //NtHook类相关类型
  TNtJmpCode=packed record  //8字节
    MovEax:Byte;
    Addr:DWORD;
    JmpCode:Word;
    dwReserved:Byte;
  end;

  TNtHookClass = class(TObject)
  private
    hProcess:THandle;
    NewAddr:TNtJmpCode;
    OldAddr:array[0..7] of Byte;
    ReadOK:Boolean;
  public
    BaseAddr:Pointer;
    constructor Create(DllName,FuncName:string;NewFunc:Pointer);
    destructor Destroy; override;
    procedure Hook;
    procedure UnHook;
  end;

implementation

//==================================================
//NtHOOK 类开始
//==================================================
constructor TNtHookClass.Create(DllName: string; FuncName: string;NewFunc:Pointer);
var
  DllModule:HMODULE;
  dwReserved: {$IF CompilerVersion > 15.0 }SIZE_T{$ELSE}DWORD{$IFEND};
begin
  //获取模块句柄
  DllModule:=GetModuleHandle(PChar(DllName));
  //如果得不到说明未被加载
  if DllModule=0 then DllModule:=LoadLibrary(PChar(DllName));
  //得到模块入口地址（基址）
  BaseAddr:=Pointer(GetProcAddress(DllModule,PChar(FuncName)));
  //获取当前进程句柄
  hProcess:=GetCurrentProcess;
  //指向新地址的指针
  NewAddr.MovEax:=$B8;
  NewAddr.Addr:=DWORD(NewFunc);
  NewAddr.JmpCode:=$E0FF;
  //保存原始地址
  ReadOK:=ReadProcessMemory(hProcess,BaseAddr,@OldAddr,8,dwReserved);
  //开始拦截
  Hook;
end;

//释放对象
destructor TNtHookClass.Destroy;
begin
  UnHook;
  CloseHandle(hProcess);

  inherited;
end;

//开始拦截
procedure TNtHookClass.Hook;
var
  dwReserved:{$IF CompilerVersion > 15.0 }SIZE_T{$ELSE}DWORD{$IFEND};
begin
  if (ReadOK=False) then Exit;
  //写入新的地址
  WriteProcessMemory(hProcess,BaseAddr,@NewAddr,8,dwReserved);
end;

//恢复拦截
procedure TNtHookClass.UnHook;
var
  dwReserved:{$IF CompilerVersion > 15.0 }SIZE_T{$ELSE}DWORD{$IFEND};
begin
  if (ReadOK=False) then Exit;
  //恢复地址
  WriteProcessMemory(hProcess,BaseAddr,@OldAddr,8,dwReserved);
end;

end.

