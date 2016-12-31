{*******************************************************************************
 标题:     SciterDebugIntf.pas
 描述:     sciter调试相关的接口
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDebugIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes, SciterIntf, Windows;

type
  PIDebugOutput = ^IDebugOutput;
  IDebugOutput = interface
  ['{4EB30A25-A376-4284-B55B-5CEE73DF25E2}']
    procedure SetupOn(hwnd: HWINDOW = 0);
    procedure SetupOff;

    function Implementator: Pointer;

    function InspectorIsPresent: Boolean;

    function Inspect(const root: IDomElement; const IP: SciterString = ''): Boolean; overload;
    function Inspect(const layout: PISciterLayout; const IP: SciterString = ''): Boolean; overload;

    procedure Output(subsystem: TOutputSubSystem; severity: TOutputSeverity; text: LPCWSTR; text_length: UINT);
  end;

function DebugOut: PIDebugOutput;

procedure SetDebugOut(const Value: IDebugOutput);

implementation

uses
  SciterImportDefs;

function DebugOut: PIDebugOutput;
type
  TGetDebugOut = function  : PIDebugOutput;
begin
  Result :=  TGetDebugOut(SciterApi.Funcs[FuncIdx_GetDebugOut]);
end;

procedure SetDebugOut(const Value: IDebugOutput);
type
  TSetDebugOut = procedure (const Value: IDebugOutput);
begin
  TSetDebugOut(SciterApi.Funcs[FuncIdx_SetDebugOut])(Value);
end;

end.
