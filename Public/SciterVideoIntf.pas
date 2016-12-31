{*******************************************************************************
 标题:     SciterVideoImpl.pas
 描述:     sciter视频相关定义的接口单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterVideoIntf;

interface

{$I Sciter.inc}

uses
  Windows;

const
  VIDEO_SOURCE_INAME                 = 'source.video.sciter.com';
  VIDEO_DESTINATION_INAME            = 'destination.video.sciter.com';
  FRAGMENTED_VIDEO_DESTINATION_INAME = 'fragmented.destination.video.sciter.com';

type
  //enum COLOR_SPACE {
  TColorSpace = (
    COLOR_SPACE_UNKNOWN,
    COLOR_SPACE_YV12,
    COLOR_SPACE_IYUV, // a.k.a. I420  
    COLOR_SPACE_NV12,
    COLOR_SPACE_YUY2,
    COLOR_SPACE_RGB24,
    COLOR_SPACE_RGB555,
    COLOR_SPACE_RGB565,
    COLOR_SPACE_RGB32 // with alpha, sic!
  );
  COLOR_SPACE = TColorSpace;
  //};

  IAsset = interface
  ['{130768F9-78AA-4F40-8A50-1773485916EF}']
    function GetHandle: Pointer;
    function Implementor: Pointer;
    property Handle: Pointer read GetHandle;
  end;

  IVideoSource = interface
  ['{A39FE419-9A08-4EB5-B884-EC500D666DA0}']
    function GetIsEnded: Boolean;
    function GetPosition: Double;
    function GetDuration: Double;
    function GetVolume: Double;
    function GetBalance: Double;
    procedure SetPosition(const seconds: Double);
    procedure SetVolume(const vol: Double);
    procedure SetBalance(const vol: Double);

    function Play(): Boolean;
    function Pause(): Boolean;
    function Stop(): Boolean;

    property IsEnded: Boolean read GetIsEnded;
    property Position: Double read GetPosition write SetPosition;
    property Duration: Double read GetDuration;
    property Volume: Double read GetVolume write SetVolume;
    property Balance: Double read GetBalance write SetBalance;
  end;
  
  IVideoDestination = interface(IAsset)
  ['{BF9901C5-BF71-423F-9332-C398031D0B23}']
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

  IFragmentedVideoDestination = interface(IVideoDestination)
  ['{BE9B1C23-1D2B-4CDB-A869-37E045825E33}']
    // render frame part request, returns false - video_destination is not available ( isn't alive, document unloaded etc.)
    function RenderFramePart(const frame_data: PByte; frame_data_size: UINT; x, y, width, height: Integer): Boolean;
  end;
              
function  CreateVideoSource(const AHandle: Pointer): IVideoSource;
function  CreateVideoDestination(const AHandle: Pointer): IVideoDestination;
function  CreateFragmentedVideoDestination(const AHandle: Pointer): IFragmentedVideoDestination;

implementation

uses
  SciterImportDefs;

function  CreateVideoSource(const AHandle: Pointer): IVideoSource;
type
  TCreateVideoSource = function  (const AHandle: Pointer): IVideoSource;
begin
  Result :=  TCreateVideoSource(SciterApi.Funcs[FuncIdx_CreateVideoSource])(AHandle);
end;

function CreateVideoDestination(const AHandle: Pointer): IVideoDestination;
type
  TCreateVideoDestination = function  (const AHandle: Pointer): IVideoDestination;
begin
  Result :=  TCreateVideoDestination(SciterApi.Funcs[FuncIdx_CreateVideoDestination])(AHandle);
end;

function  CreateFragmentedVideoDestination(const AHandle: Pointer): IFragmentedVideoDestination;
type
  TCreateFragmentedVideoDestination = function  (const AHandle: Pointer): IFragmentedVideoDestination;
begin
  Result :=  TCreateFragmentedVideoDestination(SciterApi.Funcs[FuncIdx_FragmentedVideoDestination])(AHandle);
end;

end.
