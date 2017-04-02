{*******************************************************************************
 标题:     SciterDirectXIntf.pas
 描述:     sciter与DirectX相关的接口
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDirectXIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes;

type
  PISciterDirectX = ^ISciterDirectX;
  ISciterDirectX = interface
  ['{86BC7B95-64A4-4891-B05A-84CC6B3485B7}']
    function GetD2DFactory: Pointer; //PID2D1Factory
    function GetDWFactory: Pointer;  //IDWriteFactory
    
    function CreateOnDirectXWindow(hwnd: HWINDOW; const pSwapChain: IUnknown): Boolean; // IDXGISwapChain
    function RenderOnDirectXWindow(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT = nil; frontLayer: Boolean = False): Boolean;
    function RenderOnDirectXTexture(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; const surface: IUnknown): Boolean; // IDXGISurface

    function RenderD2D(hwnd: HWINDOW; prt: IUnknown): Boolean;

    property D2DFactory: Pointer read GetD2DFactory;
    property DWFactory: Pointer read GetDWFactory;
  end;

function SciterDirectX: PISciterDirectX;

implementation

uses
  SciterImportDefs;

function SciterDirectX: PISciterDirectX;
type
  TSciterDirectX = function : PISciterDirectX;
begin
  Result := TSciterDirectX(SciterApi.Funcs[FuncIdx_SciterDirectX]);
end;

end.
