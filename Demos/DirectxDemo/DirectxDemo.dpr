program DirectxDemo;

{$R 'MyRes.res' 'MyRes.rc'}

uses
  SysUtils,
  Variants,
  Windows,
  Messages,
  Classes,
  Math,
  SciterBehavior,
  SciterImportDefs,
  SciterTypes,
  SciterIntf,
  SciterWndIntf,
  SciterDirectXIntf,
  JSB.DXTypes,
  JSB.D3DCompiler,
  JSB.D3D10,
  JSB.D3D11,
  JSB.D3DX10,
  JSB.D3DX11,
  JSB.D3DCommon,
  JSB.DXGI;

{$R *.res}

type
  TSimpleVertex = record
    Pos: TD3DXVector3;
    Tex: TD3DXVector2;
  end;
  TCBNeverChanges = record
    mView: TD3DXMatrix;
  end;
  TCBChangeOnResize = record
    mProjection: TD3DXMatrix;
  end;
  TCBChangesEveryFrame = record
    mWorld: TD3DXMatrix;
    vMeshColor: TD3DXVector4;
  end;

  view_dom_event_handler = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
  public
    function setRotationSpeed(speed: Single): Boolean;
    function setColorSpeed(speed: Single): Boolean;
  end;

var
  MainFrom: ISciterWindow;
  g_driverType: D3D_DRIVER_TYPE = D3D_DRIVER_TYPE_NULL;
  g_featureLevel: D3D_FEATURE_LEVEL = D3D_FEATURE_LEVEL_11_0;
  g_pd3dDevice: ID3D11Device = nil;
  g_pImmediateContext: ID3D11DeviceContext = nil;
  g_pSwapChain: IDXGISwapChain = nil;
  g_pRenderTargetView: ID3D11RenderTargetView = nil;
  g_pDepthStencil: ID3D11Texture2D = nil; 
  g_pDepthStencilView: ID3D11DepthStencilView = nil;
  g_pVertexShader: ID3D11VertexShader = nil;
  g_pPixelShader: ID3D11PixelShader = nil;
  g_pVertexLayout: ID3D11InputLayout = nil;
  g_pVertexBuffer: ID3D11Buffer = nil;
  g_pIndexBuffer: ID3D11Buffer = nil;
  g_pCBNeverChanges: ID3D11Buffer = nil;
  g_pCBChangeOnResize: ID3D11Buffer = nil;
  g_pCBChangesEveryFrame: ID3D11Buffer = nil;
  g_pTextureRV: ID3D11ShaderResourceView = nil;
  g_pSamplerLinear: ID3D11SamplerState = nil;
  g_World: TD3DXMatrix;
  g_View: TD3DXMatrix;
  g_Projection: TD3DXMatrix;
  g_vMeshColor: TD3DXVector4 = (x: 0.7; y:0.7; z:0.7; w:1.0);
  g_rotationSpeed: Single = 1.0;
  g_colorSpeed: Single = 1.0;

//SCITER+
  g_backLayer: IDomElement = nil; // layer
  g_foreLayer: IDomElement = nil; // elements
//SCITER-

function InitSciterEngineInstance(hwnd: HWND; const pSwapChain: IDXGISwapChain): Boolean;
var
  root: IDomElement;
  LEventHandler: IBehaviorEventHandler;
begin
  Result := False;
  // 1. create engine instance on the window with the swap chain:
  if not SciterDirectX.CreateOnDirectXWindow(MainFrom.Handle, pSwapChain) then
    Exit;

  // 2. setup DOM event handler:
  LEventHandler := view_dom_event_handler.Create;
  MainFrom.Layout.AttachDomEventHandler(LEventHandler);

  // 3. load HTML content in it:
  MainFrom.Layout.LoadFile('res:facade.htm');

  // 4. get layer elements:
  root := MainFrom.Layout.RootElement;
  g_backLayer := root.FindFirst('section#back-layer');
  g_foreLayer := root.FindFirst('section#fore-layer');
  assert((g_backLayer<>nil) and (g_foreLayer<>nil));
  
  // done
  Result := true;
end;

function CompileShaderFromFile(szFileName: WideString; szEntryPoint, szShaderModel: AnsiString; out ppBlobOut: ID3DBlob): HRESULT;
var
  dwShaderFlags: DWORD;
  pErrorBlob: ID3DBlob;
begin
  dwShaderFlags := D3DCOMPILE_ENABLE_STRICTNESS;
{$IFDEF DEBUG}
  // Set the D3DCOMPILE_DEBUG flag to embed debug information in the shaders.
  // Setting this flag improves the shader debugging experience, but still allows 
  // the shaders to be optimized and to run exactly the way they will run in 
  // the release configuration of this program.
  dwShaderFlags := dwShaderFlags or D3DCOMPILE_DEBUG;
{$ENDIF}

  Result := D3DX11CompileFromFile(PWideChar(szFileName), nil, nil, PAnsiChar(szEntryPoint), PAnsiChar(szShaderModel), 
      dwShaderFlags, 0, nil, ppBlobOut, pErrorBlob, nil );
  if FAILED(Result) then
  begin
    if pErrorBlob <> nil then
        OutputDebugStringA( PAnsiChar(pErrorBlob.GetBufferPointer) );
    pErrorBlob := nil;
    Exit;
  end;
  pErrorBlob := nil;
  Result := S_OK;
end;


function InitDevice: Boolean;
const
  XM_PIDIV4 = 0.785398163;
  
  driverTypes: array[0..2] of TD3D_DriverType = (
    D3D_DRIVER_TYPE_HARDWARE,
    D3D_DRIVER_TYPE_WARP,
    D3D_DRIVER_TYPE_REFERENCE
  );
  featureLevels: array[0..2] of TD3D_FeatureLevel = (
    D3D_FEATURE_LEVEL_11_0,
    D3D_FEATURE_LEVEL_10_1,
    D3D_FEATURE_LEVEL_10_0
  );
  layout: array[0..1] of D3D11_INPUT_ELEMENT_DESC = (
    (SemanticName: 'POSITION'; SemanticIndex: 0; Format: DXGI_FORMAT_R32G32B32_FLOAT;
      InputSlot: 0; AlignedByteOffset: 0; InputSlotClass: D3D11_INPUT_PER_VERTEX_DATA; InstanceDataStepRate: 0),
    (SemanticName: 'TEXCOORD'; SemanticIndex: 0; Format: DXGI_FORMAT_R32G32_FLOAT;
      InputSlot: 0; AlignedByteOffset: 12; InputSlotClass: D3D11_INPUT_PER_VERTEX_DATA; InstanceDataStepRate: 0)
  );
  vertices: array[0..23] of TSimpleVertex = (
    (Pos: (x: -1.0; y:  1.0; z: -1.0); Tex: (x:  0.0; y:  0.0)),
    (Pos: (x:  1.0; y:  1.0; z: -1.0); Tex: (x:  1.0; y:  0.0)),
    (Pos: (x:  1.0; y:  1.0; z:  1.0); Tex: (x:  1.0; y:  1.0)),
    (Pos: (x: -1.0; y:  1.0; z:  1.0); Tex: (x:  0.0; y:  1.0)),

    (Pos: (x: -1.0; y: -1.0; z: -1.0); Tex: (x:  0.0; y:  0.0)),
    (Pos: (x:  1.0; y: -1.0; z: -1.0); Tex: (x:  1.0; y:  0.0)),
    (Pos: (x:  1.0; y: -1.0; z:  1.0); Tex: (x:  1.0; y:  1.0)),
    (Pos: (x: -1.0; y: -1.0; z:  1.0); Tex: (x:  0.0; y:  1.0)),

    (Pos: (x: -1.0; y: -1.0; z:  1.0); Tex: (x:  0.0; y:  0.0)),
    (Pos: (x: -1.0; y: -1.0; z: -1.0); Tex: (x:  1.0; y:  0.0)),
    (Pos: (x: -1.0; y:  1.0; z: -1.0); Tex: (x:  1.0; y:  1.0)),
    (Pos: (x: -1.0; y:  1.0; z:  1.0); Tex: (x:  0.0; y:  1.0)),

    (Pos: (x:  1.0; y: -1.0; z:  1.0); Tex: (x:  0.0; y:  0.0)),
    (Pos: (x:  1.0; y: -1.0; z: -1.0); Tex: (x:  1.0; y:  0.0)),
    (Pos: (x:  1.0; y:  1.0; z: -1.0); Tex: (x:  1.0; y:  1.0)),
    (Pos: (x:  1.0; y:  1.0; z:  1.0); Tex: (x:  0.0; y:  1.0)),

    (Pos: (x: -1.0; y: -1.0; z: -1.0); Tex: (x:  0.0; y:  0.0)),
    (Pos: (x:  1.0; y: -1.0; z: -1.0); Tex: (x:  1.0; y:  0.0)),
    (Pos: (x:  1.0; y:  1.0; z: -1.0); Tex: (x:  1.0; y:  1.0)),
    (Pos: (x: -1.0; y:  1.0; z: -1.0); Tex: (x:  0.0; y:  1.0)),

    (Pos: (x: -1.0; y: -1.0; z:  1.0); Tex: (x:  0.0; y:  0.0)),
    (Pos: (x:  1.0; y: -1.0; z:  1.0); Tex: (x:  1.0; y:  0.0)),
    (Pos: (x:  1.0; y:  1.0; z:  1.0); Tex: (x:  1.0; y:  1.0)),
    (Pos: (x: -1.0; y:  1.0; z:  1.0); Tex: (x:  0.0; y:  1.0))
  );
  indices: array[0..35] of Word = (
      3,1,0,
      2,1,3,

      6,4,5,
      7,4,6,

      11,9,8,
      10,9,11,

      14,12,13,
      15,12,14,

      19,17,16,
      18,17,19,

      22,20,21,
      23,20,22
  );

var
  hr: HRESULT;
  rc: TRect;
  width, height, createDeviceFlags, numDriverTypes, numFeatureLevels,
    driverTypeIndex, numElements, stride, offset: Cardinal;
  sd: DXGI_SWAP_CHAIN_DESC;
  pBackBuffer: ID3D11Texture2D;
  descDepth: D3D11_TEXTURE2D_DESC;
  descDSV: D3D11_DEPTH_STENCIL_VIEW_DESC;
  vp: D3D11_VIEWPORT;
  pVSBlob, pPSBlob: ID3DBlob;
  bd: D3D11_BUFFER_DESC;
  InitData: D3D11_SUBRESOURCE_DATA;
  sampDesc: D3D11_SAMPLER_DESC;
  Eye, At, Up: TD3DXVector3;
  cbNeverChanges: TCBNeverChanges;
  cbChangesOnResize: TCBChangeOnResize;
begin
  Result := False;

  JSB.D3D11.Link;
  JSB.D3DX11.Link;
  JSB.D3DX10.Link;

  GetClientRect( MainFrom.Handle, rc );
  width := rc.right - rc.left;
  height := rc.bottom - rc.top;

//SCITER +
  // createDeviceFlags must contain D3D10_CREATE_DEVICE_BGRA_SUPPORT flag
  createDeviceFlags := Cardinal(D3D10_CREATE_DEVICE_BGRA_SUPPORT);
//SCITER -
{$IFDEF DEBUG}
  createDeviceFlags := createDeviceFlags or Cardinal(D3D11_CREATE_DEVICE_DEBUG);
{$ENDIF}

  numDriverTypes := Length(driverTypes);
  numFeatureLevels := Length(featureLevels);

  ZeroMemory(@sd, sizeof(sd));
  sd.BufferCount := 1;
  sd.BufferDesc.Width := width;
  sd.BufferDesc.Height := height;
  sd.BufferDesc.Format := DXGI_FORMAT_B8G8R8A8_UNORM;
  sd.BufferDesc.RefreshRate.Numerator := 60;
  sd.BufferDesc.RefreshRate.Denominator := 1;
  sd.BufferUsage := DXGI_USAGE_RENDER_TARGET_OUTPUT;
  sd.OutputWindow := MainFrom.Handle;
  sd.SampleDesc.Count := 1;
  sd.SampleDesc.Quality := 0;
  sd.Windowed := TRUE;

  hr := S_OK;
  for driverTypeIndex := 0 to numDriverTypes-1 do
  begin
    g_driverType := driverTypes[driverTypeIndex];
    hr := D3D11CreateDeviceAndSwapChain(nil, g_driverType, 0, createDeviceFlags, @featureLevels, numFeatureLevels,
      D3D11_SDK_VERSION, @sd, g_pSwapChain, g_pd3dDevice, @g_featureLevel, g_pImmediateContext );
    if SUCCEEDED(hr) then
        break;
  end;
  if FAILED(hr) then
    Exit;

  // Create a render target view
  pBackBuffer := nil;
  hr := g_pSwapChain.GetBuffer(0, ID3D11Texture2D, pBackBuffer);
  if FAILED(hr) then
    Exit;

  hr := g_pd3dDevice.CreateRenderTargetView(pBackBuffer, nil, g_pRenderTargetView);
  pBackBuffer := nil;
  if FAILED( hr ) then
    Exit;

  // Create depth stencil texture
  ZeroMemory(@descDepth, sizeof(descDepth));
  descDepth.Width := width;
  descDepth.Height := height;
  descDepth.MipLevels := 1;
  descDepth.ArraySize := 1;
  descDepth.Format := DXGI_FORMAT_D24_UNORM_S8_UINT;
  descDepth.SampleDesc.Count := 1;
  descDepth.SampleDesc.Quality := 0;
  descDepth.Usage := D3D11_USAGE_DEFAULT;
  descDepth.BindFlags := Cardinal(D3D11_BIND_DEPTH_STENCIL);
  descDepth.CPUAccessFlags := 0;
  descDepth.MiscFlags := 0;
  hr := g_pd3dDevice.CreateTexture2D(descDepth, nil, g_pDepthStencil);
  if FAILED( hr ) then
    Exit;

  // Create the depth stencil view
  ZeroMemory(@descDSV, sizeof(descDSV));
  descDSV.Format := descDepth.Format;
  descDSV.ViewDimension := D3D11_DSV_DIMENSION_TEXTURE2D;
  descDSV.Texture2D.MipSlice := 0;
  hr := g_pd3dDevice.CreateDepthStencilView( g_pDepthStencil, @descDSV, g_pDepthStencilView );
  if FAILED(hr) then
    Exit;

  g_pImmediateContext.OMSetRenderTargets( 1, @g_pRenderTargetView, g_pDepthStencilView );

  // Setup the viewport
  vp.Width := width;
  vp.Height := height;
  vp.MinDepth := 0.0;
  vp.MaxDepth := 1.0;
  vp.TopLeftX := 0;
  vp.TopLeftY := 0;
  g_pImmediateContext.RSSetViewports( 1, @vp);

// SCITER+
  // create Sciter engine instance for the window:
  InitSciterEngineInstance(MainFrom.Handle, g_pSwapChain);
// SCITER-

  // Compile the vertex shader
  pVSBlob := nil;
  hr := CompileShaderFromFile(ExtractFilePath(ParamStr(0))+'sciter-directx-res/shaders.fx', 'VS', 'vs_4_0', pVSBlob );
  if FAILED( hr ) then
  begin
    MessageBox(0,
      'The FX file cannot be compiled.  Please run this executable from sciter-sdk/bin folder.', 'Error', MB_OK);
    Exit;
  end;

  // Create the vertex shader
  hr := g_pd3dDevice.CreateVertexShader(pVSBlob.GetBufferPointer, pVSBlob.GetBufferSize(), nil, g_pVertexShader);
  if FAILED( hr ) then
  begin
    pVSBlob := nil;
    Exit;
  end;

  // Define the input layout
  numElements := Length(layout);

  // Create the input layout
  hr := g_pd3dDevice.CreateInputLayout(@layout[0], numElements, pVSBlob.GetBufferPointer,
    pVSBlob.GetBufferSize, g_pVertexLayout );
  pVSBlob := nil;
  if FAILED(hr) then
    Exit;

  // Set the input layout
  g_pImmediateContext.IASetInputLayout( g_pVertexLayout );

  // Compile the pixel shader
  pPSBlob := nil;
  hr := CompileShaderFromFile(ExtractFilePath(ParamStr(0))+'sciter-directx-res/shaders.fx', 'PS', 'ps_4_0', pPSBlob);
  if FAILED( hr ) then
  begin
    MessageBox(0,
      'The FX file cannot be compiled.  Please run this executable from sciter-sdk/bin folder.', 'Error', MB_OK);
    Exit;
  end;
  
  // Create the pixel shader
  hr := g_pd3dDevice.CreatePixelShader(pPSBlob.GetBufferPointer, pPSBlob.GetBufferSize, nil, g_pPixelShader);
  pPSBlob := nil;
  if FAILED(hr) then
    Exit;

  ZeroMemory(@bd, sizeof(bd) );
  bd.Usage := D3D11_USAGE_DEFAULT;
  bd.ByteWidth := sizeof( TSimpleVertex ) * 24;
  bd.BindFlags := D3D11_BIND_VERTEX_BUFFER;
  bd.CPUAccessFlags := 0;

  ZeroMemory(@InitData, sizeof(InitData) );
  InitData.pSysMem := @vertices[0];
  hr := g_pd3dDevice.CreateBuffer(bd, @InitData, g_pVertexBuffer);
  if FAILED(hr) then
    Exit;

  // Set vertex buffer
  stride := sizeof( TSimpleVertex );
  offset := 0;
  g_pImmediateContext.IASetVertexBuffers( 0, 1, @g_pVertexBuffer, @stride, @offset );

  // Create index buffer
  // Create vertex buffer
  bd.Usage := D3D11_USAGE_DEFAULT;
  bd.ByteWidth := sizeof( WORD ) * 36;
  bd.BindFlags := D3D11_BIND_INDEX_BUFFER;
  bd.CPUAccessFlags := 0;
  InitData.pSysMem := @indices[0];
  hr := g_pd3dDevice.CreateBuffer(bd, @InitData, g_pIndexBuffer);
  if FAILED(hr) then
    Exit;

  // Set index buffer
  g_pImmediateContext.IASetIndexBuffer( g_pIndexBuffer, DXGI_FORMAT_R16_UINT, 0 );

  // Set primitive topology
  g_pImmediateContext.IASetPrimitiveTopology( D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST );

  // Create the constant buffers
  bd.Usage := D3D11_USAGE_DEFAULT;
  bd.ByteWidth := sizeof(CBNeverChanges);
  bd.BindFlags := D3D11_BIND_CONSTANT_BUFFER;
  bd.CPUAccessFlags := 0;
  hr := g_pd3dDevice.CreateBuffer(bd, nil, g_pCBNeverChanges );
  if FAILED(hr) then
    Exit;
    
  bd.ByteWidth := sizeof(TCBChangeOnResize);
  hr := g_pd3dDevice.CreateBuffer(bd, nil, g_pCBChangeOnResize );
  if FAILED(hr) then
    Exit;
    
  bd.ByteWidth := sizeof(TCBChangesEveryFrame);
  hr := g_pd3dDevice.CreateBuffer(bd, nil, g_pCBChangesEveryFrame );
  if FAILED(hr) then
    Exit;

  // Load the Texture
  hr := D3DX11CreateShaderResourceViewFromFile( g_pd3dDevice,
    'sciter-directx-res/seafloor.dds', nil, nil, g_pTextureRV, nil);
  if FAILED(hr) then
    Exit;

  // Create the sample state
  ZeroMemory(@sampDesc, sizeof(sampDesc) );
  sampDesc.Filter := D3D11_FILTER_MIN_MAG_MIP_LINEAR;
  sampDesc.AddressU := D3D11_TEXTURE_ADDRESS_WRAP;
  sampDesc.AddressV := D3D11_TEXTURE_ADDRESS_WRAP;
  sampDesc.AddressW := D3D11_TEXTURE_ADDRESS_WRAP;
  sampDesc.ComparisonFunc := D3D11_COMPARISON_NEVER;
  sampDesc.MinLOD := 0;
  sampDesc.MaxLOD := D3D11_FLOAT32_MAX;
  hr := g_pd3dDevice.CreateSamplerState(sampDesc, g_pSamplerLinear);
  if FAILED(hr) then
    Exit;

  // Initialize the world matrices
  g_World := D3DXMatrixIdentity();

  // Initialize the view matrix
  Eye := D3DXVector3( 0.0, 3.0, -6.0);
  At := D3DXVector3( 0.0, 1.0, 0.0);
  Up := D3DXVector3( 0.0, 1.0, 0.0);
  D3DXMatrixLookAtLH(g_View, Eye, At, Up );

  D3DXMatrixTranspose(cbNeverChanges.mView, g_View);
  g_pImmediateContext.UpdateSubresource( g_pCBNeverChanges, 0, nil, @cbNeverChanges, 0, 0 );

  // Initialize the projection matrix
  D3DXMatrixPerspectiveFovLH(g_Projection, XM_PIDIV4, width / height, 0.01, 100.0 );

  D3DXMatrixTranspose(cbChangesOnResize.mProjection, g_Projection);
  g_pImmediateContext.UpdateSubresource( g_pCBChangeOnResize, 0, nil, @cbChangesOnResize, 0, 0 );

  Result := hr = S_OK;
end;

procedure CleanupDevice;
begin
  g_pImmediateContext := nil;
  g_pSamplerLinear := nil;
  g_pTextureRV  := nil;
  g_pCBNeverChanges := nil;
  g_pCBChangeOnResize := nil;
  g_pCBChangesEveryFrame := nil;
  g_pVertexBuffer := nil;
  g_pIndexBuffer := nil;
  g_pVertexLayout := nil;
  g_pVertexShader := nil;
  g_pPixelShader := nil;
  g_pDepthStencil := nil;
  g_pDepthStencilView := nil;
  g_pRenderTargetView := nil;
  g_pSwapChain := nil;
  g_pImmediateContext := nil;
  g_pd3dDevice := nil;
  g_backLayer := nil; // layer
  g_foreLayer := nil; // elements
end;

procedure Resize;
var
  rc: TRect;
  width, height: Integer;
  hr: HRESULT;
  pBuffer: ID3D11Texture2D;
  vp: D3D11_VIEWPORT;
begin
  if g_pSwapChain = nil then
    Exit;

  GetClientRect(MainFrom.Handle, rc);

  width := rc.right - rc.left;
  height := rc.top - rc.bottom;

  g_pImmediateContext.OMSetRenderTargets(0, nil, nil);

  // Release all outstanding references to the swap chain's buffers.
  g_pRenderTargetView := nil;

  // Preserve the existing buffer count and format.
  // Automatically choose the width and height to match the client rect for HWNDs.
  hr := g_pSwapChain.ResizeBuffers(0, 0, 0, DXGI_FORMAT_UNKNOWN, 0);
  if FAILED(hr) then
    Exit;
                                            
  // Perform error handling here!

  // Get buffer and create a render-target-view.
  hr := g_pSwapChain.GetBuffer(0, ID3D11Texture2D, pBuffer);
  if FAILED(hr) then
    Exit;

  // Perform error handling here!
  hr := g_pd3dDevice.CreateRenderTargetView(pBuffer, nil, g_pRenderTargetView);
  if FAILED(hr) then
    Exit;

  // Perform error handling here!
  pBuffer := nil;

  g_pImmediateContext.OMSetRenderTargets(1, @g_pRenderTargetView, nil );

  // Set up the viewport.
  vp.Width := width;
  vp.Height := height;
  vp.MinDepth := 0.0;
  vp.MaxDepth := 1.0;
  vp.TopLeftX := 0;
  vp.TopLeftY := 0;
  g_pImmediateContext.RSSetViewports( 1, @vp );
end;

// Update our time
var
  t: Single = 0.0;
  dwTimeStart: DWORD = 0;

procedure Render;
const
  ClearColor: TColorArray = (0.0, 0.125, 0.3, 1.0);  // red, green, blue, alpha
var
  dwTimeCur: DWORD;
  cb: TCBChangesEveryFrame;
begin
  if g_driverType = D3D_DRIVER_TYPE_REFERENCE then
    t := t + PI * 0.0125
  else
  begin
    dwTimeCur := GetTickCount();
    if dwTimeStart = 0 then
      dwTimeStart := dwTimeCur;
    t := ( dwTimeCur - dwTimeStart ) / 1000.0;
  end;

  // Rotate cube around the origin
  D3DXMatrixRotationY(g_World, t * g_rotationSpeed );

  // Modify the color
  g_vMeshColor.x := ( Sin( t * g_colorSpeed * 1.0 ) + 1.0 ) * 0.5;
  g_vMeshColor.y := ( Cos( t * g_colorSpeed * 3.0 ) + 1.0 ) * 0.5;
  g_vMeshColor.z := ( Sin( t * g_colorSpeed * 5.0 ) + 1.0 ) * 0.5;

  //
  // Clear the back buffer
  //
  g_pImmediateContext.ClearRenderTargetView( g_pRenderTargetView, ClearColor );

// SCITER +
  // render HTML document
  if (g_backLayer<>nil) and (g_foreLayer<>nil) then
    SciterDirectX.RenderOnDirectXWindow(MainFrom.Handle, g_backLayer.Element, False) // render back layer before 3D scene
  else 
    SciterDirectX.RenderOnDirectXWindow(MainFrom.Handle);
// SCITER -

  //
  // Clear the depth buffer to 1.0 (max depth)
  //
  g_pImmediateContext.ClearDepthStencilView( g_pDepthStencilView, D3D11_CLEAR_DEPTH, 1.0, 0 );

  //
  // Update variables that change once per frame
  //
  D3DXMatrixTranspose(cb.mWorld, g_World );
  cb.vMeshColor := g_vMeshColor;
  g_pImmediateContext.UpdateSubresource( g_pCBChangesEveryFrame, 0, nil, @cb, 0, 0 );

  //
  // Render the cube
  //
  g_pImmediateContext.VSSetShader( g_pVertexShader, nil, 0 );
  g_pImmediateContext.VSSetConstantBuffers( 0, 1, @g_pCBNeverChanges );
  g_pImmediateContext.VSSetConstantBuffers( 1, 1, @g_pCBChangeOnResize );
  g_pImmediateContext.VSSetConstantBuffers( 2, 1, @g_pCBChangesEveryFrame );
  g_pImmediateContext.PSSetShader( g_pPixelShader, nil, 0 );
  g_pImmediateContext.PSSetConstantBuffers( 2, 1, @g_pCBChangesEveryFrame );
  g_pImmediateContext.PSSetShaderResources( 0, 1, @g_pTextureRV );
  g_pImmediateContext.PSSetSamplers( 0, 1, @g_pSamplerLinear );
  g_pImmediateContext.DrawIndexed( 36, 0, 0 );

// SCITER +
  // render fore layer on top of 3D scene
  if (g_backLayer<>nil) and (g_foreLayer<>nil) then
    SciterDirectX.RenderOnDirectXWindow(MainFrom.Handle, g_foreLayer.Element, TRUE); 
// SCITER -

  //
  // Present our back buffer to our front buffer
  //
  g_pSwapChain.Present( 0, 0 );
end;

{ view_dom_event_handler }

procedure view_dom_event_handler.OnSize(const he: IDomElement);
begin
  Resize;
end;

function view_dom_event_handler.OnSubscription(const he: IDomElement; var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_SIZE;
  Result := True;
end;

function view_dom_event_handler.setColorSpeed(speed: Single): Boolean;
begin
  if speed = 0 then speed := 1;
  g_colorSpeed := speed;
  Result := True;
end;

function view_dom_event_handler.setRotationSpeed(speed: Single): Boolean;
begin
  if speed = 0 then speed := 1;
  g_rotationSpeed := speed;
  Result := True;
end;

function OleInitialize(pwReserved: Pointer): HResult; stdcall; external 'ole32.dll' name 'OleInitialize';
procedure OleUninitialize; stdcall; external 'ole32.dll' name 'OleUninitialize';

procedure _RenderTimerProc(hwnd:HWND; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  Render();
end;

var
  timerId: Cardinal;
begin
//SCITER+
  // Sciter needs it for Drag-n-drop, etc.
  OleInitialize(nil);
//SCITER-

  MainFrom := CreateWindow(HInstance, CWFlags_Sizeable + [swScreenCenter, swEnableDebug, swDXPaint, swMain],
    Classes.Rect(0, 0, 800, 600), 0);
  MainFrom.Caption := 'Sciter3 Directx Ê¾Àý';
  
  if not InitDevice then
  begin
    CleanupDevice;
    Exit;
  end;
  
  MainFrom.Show();
  timerId := SetTimer(MainFrom.Handle, 1, 50, @_RenderTimerProc);

  // Main message loop
  ExitCode := Sciter.RunAppclition(MainFrom.Handle);
  
  KillTimer(MainFrom.Handle, timerId);
  CleanupDevice;

  MainFrom := nil;

//SCITER+
  OleUninitialize;
//SCITER-
end.
