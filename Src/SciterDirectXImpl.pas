{*******************************************************************************
 标题:     SciterDirectXImpl.pas
 描述:     sciter与DirectX相关的实现
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDirectXImpl;

interface

uses
  SciterTypes, SciterApiImpl, SciterDirectXIntf;

type
  TSciterDirectX = class(TInterfacedObject, ISciterDirectX)
  private
    function GetD2DFactory: Pointer;
    function GetDWFactory: Pointer;
  public
    function CreateOnDirectXWindow(hwnd: HWINDOW; const pSwapChain: IUnknown): Boolean;
    function RenderOnDirectXWindow(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; frontLayer: Boolean): Boolean;
    function RenderOnDirectXTexture(hwnd: HWINDOW; elementToRenderOrNull: HELEMENT; const surface: IUnknown): Boolean;

    function RenderD2D(hwnd: HWINDOW; prt: IUnknown): Boolean;

    property D2DFactory: Pointer read GetD2DFactory;
    property DWFactory: Pointer read GetDWFactory;
  end;

implementation

{ TSciterDirectX }

function TSciterDirectX.CreateOnDirectXWindow(hwnd: HWINDOW;
  const pSwapChain: IUnknown): Boolean;
begin
  Result := SAPI.SciterCreateOnDirectXWindow(hwnd, pSwapChain);
end;

function TSciterDirectX.GetD2DFactory: Pointer;
begin
  SAPI.SciterD2DFactory(Result);
end;

function TSciterDirectX.GetDWFactory: Pointer;
begin
  SAPI.SciterDWFactory(Result);
end;

function TSciterDirectX.RenderD2D(hwnd: HWINDOW; prt: IUnknown): Boolean;
begin
  Result := SAPI.SciterRenderD2D(hwnd, prt);
end;

function TSciterDirectX.RenderOnDirectXTexture(hwnd: HWINDOW;
  elementToRenderOrNull: HELEMENT; const surface: IUnknown): Boolean;
begin
  Result := SAPI.SciterRenderOnDirectXTexture(hwnd, elementToRenderOrNull, surface);
end;

function TSciterDirectX.RenderOnDirectXWindow(hwnd: HWINDOW;
  elementToRenderOrNull: HELEMENT; frontLayer: Boolean): Boolean;
begin
  Result := SAPI.SciterRenderOnDirectXWindow(hwnd, elementToRenderOrNull, frontLayer);
end;

end.
