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
  SciterTypes, JSB.D2D1, JSB.DirectWrite;

type
  PISciterDirectX = ^ISciterDirectX;
  ISciterDirectX = interface
  ['{86BC7B95-64A4-4891-B05A-84CC6B3485B7}']
    function GetD2DFactory: ID2D1Factory;
    function GetDWFactory: IDWriteFactory;
    
    function CreateOnDirectXWindow(hwnd: HWINDOW; const pSwapChain: IUnknown): Boolean; // IDXGISwapChain
    function RenderOnDirectXWindow(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT = nil; frontLayer: Boolean = False): Boolean;
    function RenderOnDirectXTexture(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; const surface: IUnknown): Boolean; // IDXGISurface

    function RenderD2D(hwnd: HWINDOW; prt: ID2D1RenderTarget): Boolean;

    property D2DFactory: ID2D1Factory read GetD2DFactory;
    property DWFactory: IDWriteFactory read GetDWFactory;
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
