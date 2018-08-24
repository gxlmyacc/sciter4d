{*******************************************************************************
 标题:     SciterVideoImpl.pas
 描述:     sciter视频相关定义的实现单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterVideoImpl;

interface

uses
  SysUtils, Windows, Classes, SciterVideoIntf;

type
  TAsset = class(TInterfacedObject, IAsset)
  private
    FHandle: Pointer;
    function GetHandle: Pointer;
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const AHandle: Pointer);
    destructor Destroy; override;

    function Implementor: Pointer;

    property Handle: Pointer read GetHandle;
  end;

  TVideoSource = class(TAsset, IVideoSource)
  protected
    function GetIsEnded: Boolean;
    function GetPosition: Double;
    function GetDuration: Double;
    function GetVolume: Double;
    function GetBalance: Double;
    procedure SetPosition(const seconds: Double);
    procedure SetVolume(const vol: Double);
    procedure SetBalance(const vol: Double);
  public
    function Play(): Boolean;
    function Pause(): Boolean;
    function Stop(): Boolean;

    property IsEnded: Boolean read GetIsEnded;
    property Position: Double read GetPosition write SetPosition;
    property Duration: Double read GetDuration;
    property Volume: Double read GetVolume write SetVolume;
    property Balance: Double read GetBalance write SetBalance;
  end;

  TVideoDestination = class(TAsset, IVideoDestination)
  public
    // true if this instance of video_renderer is attached to DOM element and is capable of playing.
    function IsAlive(): Boolean;
    // start streaming/rendering
    function StartStreaming(frame_width, frame_height: Integer;
      color_space: TColorSpace; src: Pointer = nil): Boolean;
    // stop streaming, eof.
    function StopStreaming(): Boolean;
    // render frame request, false - video_destination is not available ( isn't alive, document unloaded etc.)
    function RenderFrame(const frame_data: PByte; frame_data_size: UINT): Boolean;
  end;

  TFragmentedVideoDestination = class(TVideoDestination, IFragmentedVideoDestination)
  public
    // render frame part request, returns false - video_destination is not available ( isn't alive, document unloaded etc.)
    function RenderFramePart(const frame_data: PByte; frame_data_size: UINT; x, y, width, height: Integer): Boolean;
  end;


  TSciterVideoApi = class
  private
    FDLLMemory: TResourceStream;
    FDLLHandle: THandle;
  protected
    iasset_add_ref: function (self: Pointer): LongInt; cdecl;
    iasset_release: function (self: Pointer): LongInt; cdecl;
    iasset_get_interface: function (self: Pointer; const name: PChar; var out: Pointer): Boolean; cdecl;

    video_source_play: function (self: Pointer): Boolean; cdecl;
    video_source_pause: function (self: Pointer): Boolean; cdecl;
    video_source_stop: function (self: Pointer): Boolean; cdecl;
    video_source_get_is_ended: function (self: Pointer; var eos: Boolean): Boolean; cdecl;
    video_source_get_position: function (self: Pointer; var seconds: Double): Boolean; cdecl;
    video_source_set_position: function (self: Pointer; seconds: Double): Boolean; cdecl;
    video_source_get_duration: function (self: Pointer; var seconds: Double): Boolean; cdecl;
    video_source_get_volume: function (self: Pointer; var vol: Double): Boolean; cdecl;
    video_source_set_volume: function (self: Pointer; vol: Double): Boolean; cdecl;
    video_source_get_balance: function (self: Pointer; var vol: Double): Boolean; cdecl;
    video_source_set_balance: function (self: Pointer; vol: Double): Boolean; cdecl;

    video_destination_is_alive: function (self: Pointer): Boolean; cdecl;
    video_destination_start_streaming: function (self: Pointer;frame_width, frame_height, color_space: Integer;
      src: Pointer = nil): Boolean; cdecl;
    video_destination_stop_streaming: function (self: Pointer): Boolean; cdecl;
    video_destination_render_frame: function (self: Pointer; const frame_data: PByte;
      frame_data_size: UINT): Boolean; cdecl;
    fragmented_video_destination_render_frame_part: function (self: Pointer;
      const frame_data: PByte; frame_data_size: UINT; x, y, width, height: Integer): Boolean; cdecl;  
  public
    constructor Create;
    destructor Destroy; override;
  end;

function SVA: TSciterVideoApi;

var
  varSciterVideoApi: TSciterVideoApi = nil;

implementation

uses
  SciterMemLib, SciterApiImpl;

//{$L 'sciter_video_api_32_omf.obj'}
//function _iasset_add_ref(self: Pointer): LongInt; cdecl; external;


function SVA: TSciterVideoApi;
begin
  if varSciterVideoApi = nil then
    varSciterVideoApi := TSciterVideoApi.Create;
  Result := varSciterVideoApi;
end;

{ TVideoDestination }

function TVideoDestination.IsAlive: Boolean;
begin
  Result := SVA.video_destination_is_alive(FHandle)
end;

function TVideoDestination.RenderFrame(const frame_data: PByte;
  frame_data_size: UINT): Boolean;
begin
  Result := SVA.video_destination_render_frame(FHandle, frame_data, frame_data_size)
end;

function TVideoDestination.StartStreaming(frame_width,
  frame_height: Integer; color_space: TColorSpace; src: Pointer): Boolean;
begin
  Result := SVA.video_destination_start_streaming(FHandle, frame_width, frame_height, Integer(color_space), src);
end;

function TVideoDestination.StopStreaming: Boolean;
begin
  Result := SVA.video_destination_stop_streaming(FHandle)
end;

{ TSciterVideoApi }

constructor TSciterVideoApi.Create;
var
  sDllFile: string;
  LGetProcAddress: function (hModule: HMODULE; lpProcName: PChar): FARPROC; stdcall;
begin
  sDllFile := SciterModulePath + 'SciterVideoLib.dll';
  if FastFileExists(sDllFile) then
  begin
    FDLLHandle := LoadLibrary(PChar(sDllFile));
    LGetProcAddress := GetProcAddress;
  end
  else
  begin
    FDLLMemory := TResourceStream.Create(SysInit.HInstance, 'SciterVideoLib', PChar('dll'));
    FDLLHandle := memLoadLibrary(FDLLMemory.Memory, FDLLMemory.Size);
    LGetProcAddress := memGetProcAddress;
  end;
  if FDLLHandle < 32 then
  begin
    FDLLHandle := 0;
    TraceError('Load [SciterVideoLib.dll] failed！');
    Exit;
  end;

  @iasset_add_ref := LGetProcAddress(FDLLHandle, 'iasset_add_ref');
  @iasset_release := LGetProcAddress(FDLLHandle, 'iasset_release');
  @iasset_get_interface := LGetProcAddress(FDLLHandle, 'iasset_get_interface');

  @video_source_play := LGetProcAddress(FDLLHandle, 'video_source_play');
  @video_source_pause := LGetProcAddress(FDLLHandle, 'video_source_pause');
  @video_source_stop := LGetProcAddress(FDLLHandle, 'video_source_stop');
  @video_source_get_is_ended := LGetProcAddress(FDLLHandle, 'video_source_get_is_ended');
  @video_source_get_position := LGetProcAddress(FDLLHandle, 'video_source_get_position');
  @video_source_set_position := LGetProcAddress(FDLLHandle, 'video_source_set_position');
  @video_source_get_duration := LGetProcAddress(FDLLHandle, 'video_source_get_duration');
  @video_source_get_volume := LGetProcAddress(FDLLHandle, 'video_source_get_volume');
  @video_source_set_volume := LGetProcAddress(FDLLHandle, 'video_source_set_volume');
  @video_source_get_balance := LGetProcAddress(FDLLHandle, 'video_source_get_balance');
  @video_source_set_balance := LGetProcAddress(FDLLHandle, 'video_source_set_balance');

  @video_destination_is_alive := LGetProcAddress(FDLLHandle, 'video_destination_is_alive');
  @video_destination_start_streaming := LGetProcAddress(FDLLHandle, 'video_destination_start_streaming');
  @video_destination_stop_streaming := LGetProcAddress(FDLLHandle, 'video_destination_stop_streaming');
  @video_destination_render_frame := LGetProcAddress(FDLLHandle, 'video_destination_render_frame');
  @fragmented_video_destination_render_frame_part := LGetProcAddress(FDLLHandle, 'fragmented_video_destination_render_frame_part');
end;

destructor TSciterVideoApi.Destroy;
begin
  if FDLLHandle > 0 then
  begin
    if FDLLMemory <> nil then
      memFreeLibrary(FDLLHandle)
    else
      FreeLibrary(FDLLHandle);

    FDLLHandle := 0;
  end;
  if FDLLMemory <> nil then
    FreeAndNil(FDLLMemory);

  inherited;
end;

{ TFragmentedVideoDestination }

function TFragmentedVideoDestination.RenderFramePart(
  const frame_data: PByte; frame_data_size: UINT; x, y, width,
  height: Integer): Boolean;
begin
  Result := SVA.fragmented_video_destination_render_frame_part(FHandle, frame_data, frame_data_size, x, y, width, height)
end;

{ TAsset }

constructor TAsset.Create(const AHandle: Pointer);
begin
  FHandle := AHandle;
end;

destructor TAsset.Destroy;
begin
  inherited;
end;

function TAsset.GetHandle: Pointer;
begin
  Result := FHandle;
end;

function TAsset.Implementor: Pointer;
begin
  Result := Self;
end;

function TAsset._AddRef: Integer;
begin
  if FHandle <> nil then
    SVA.iasset_add_ref(FHandle);
  Result := inherited _AddRef;
end;

function TAsset._Release: Integer;
begin
  if FHandle <> nil then
    SVA.iasset_release(FHandle);
  Result := inherited _Release;
end;

{ TVideoSource }

function TVideoSource.GetBalance: Double;
begin
  Assert(SVA.video_source_get_balance(FHandle, Result));
end;

function TVideoSource.GetDuration: Double;
begin
  Assert(SVA.video_source_get_duration(FHandle, Result));
end;

function TVideoSource.GetIsEnded: Boolean;
begin
  Assert(SVA.video_source_get_is_ended(FHandle, Result));
end;

function TVideoSource.GetPosition: Double;
begin
  Assert(SVA.video_source_get_position(FHandle, Result));
end;

function TVideoSource.GetVolume: Double;
begin
  Assert(SVA.video_source_get_volume(FHandle, Result));
end;

function TVideoSource.Pause: Boolean;
begin
  Result := SVA.video_source_pause(FHandle);
end;

function TVideoSource.Play: Boolean;
begin
  Result := SVA.video_source_play(FHandle);
end;

procedure TVideoSource.SetBalance(const vol: Double);
begin
  Assert(SVA.video_source_set_balance(FHandle, vol));
end;

procedure TVideoSource.SetPosition(const seconds: Double);
begin
  Assert(SVA.video_source_set_position(FHandle, seconds));
end;

procedure TVideoSource.SetVolume(const vol: Double);
begin
  Assert(SVA.video_source_set_volume(FHandle, vol));
end;

function TVideoSource.Stop: Boolean;
begin
  Result := SVA.video_source_stop(FHandle);
end;

initialization

finalization
  if varSciterVideoApi <> nil then
  try
    FreeAndNil(varSciterVideoApi);
  except
    on E: Exception do
      TraceException('[SciterVideo.finalization]'+e.Message);
  end;
end.


