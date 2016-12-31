unit JSB.DXGI;

///////////////////////////////////////////////////////////////////////////////
// Title: Translation of DirectX C++ header files for use with Delphi 2009 and later
//
// File name: JSB.DXGI.pas
//
// Originator: J S Bladen, Sheffield, UK.
//
// Copyright: J S Bladen, Sheffield, UK.
//
// Translation date and time (UTC): 07/10/2010 13:29:35
//
// Email: DirectXForDelphi@jsbmedical.co.uk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Original file(s):
//   DXGIFormat.h
//   DXGIType.h
//   DXGI.h
//
// Copyright (C) Microsoft Corporation.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Software licence:
//
// Use of this "software" is subject to the following software licence:
//
// ***** BEGIN LICENCE BLOCK *****
//
// 1) This software is distributed in the hope that it will be useful, but without warranty of any kind.
// 2) The copyright and/or originator notice(s) may not be altered or removed.
// 3) This software may be used for commercial or non-commercial use.
// 4) This software may be redistributed, provided no charge is made.
// 5) There is no obligation to make source code available to end users even if the software is modified.
// 6) Modified versions of this software will be subject to this software licence.
// 7) If the software is modified, the changes must be marked in the source code with the contributors ID (e.g. name)
//    before redistribution.
//
// ***** END LICENCE BLOCK *****
//
// In addition, users of this software are strongly encouraged to contact the originator with feedback, corrections and
// suggestions for improvement.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Translation notes:
//
// 1) This software is preliminary. For the latest version please see "http://DirectXForDelphi.blogspot.com/".
//
// 2) The header filename suffix "_JSB" is to distinguish the files from the equivalent JEDI/Clootie files
//    and must be left in place". Interface units from different sources may not work correctly together.
//
// 3) By default, optional interface output method and function parameters are translated as "out InterfaceName:IInterfaceName",
//    not "pInterfaceName:PIInterfaceName". This is because with the pointer version, Delphi does not appear to call the
//    COM Release method on the supplied interface before assigning a new value. To pass a nil parameter, use
//    "IInterfaceName(nil^)".
//
//    PLEASE NOTE: This is different to the equivalent JEDI/Clootie files, though only minimal source code changes
//    should be required.
//
//    If you want to use pointers instead, define the conditional define "UsePointersForOptionalOutputInterfaces" but ensure
//    that the interface variable is set to nil before calling the method.
//
// 4) Please contact me if you are interested in versions for FPC or C++ etc.
//
// JSB
///////////////////////////////////////////////////////////////////////////////

{$ifdef fpc}{$mode delphi}{$endif}

interface

{$Z4}
{$define UseRuntimeLinking}
{$define UNICODE}

uses
  Windows, SysUtils, MultiMon, JSB.DXTypes;

const
  DLL_DXGI='dxgi.dll';

///////////////////////////////////////////////////////////////////////////////
// Begin "DXGIFormat.h"
///////////////////////////////////////////////////////////////////////////////

const
  DXGI_FORMAT_DEFINED = 1;

{$IF CompilerVersion <= 18.5} // <= Delphi 2007
{$define NOTLUID}
{$IFEND}

{$ifdef NOTLUID}
type
 TLUID = record
  LowPart: DWORD;
  HighPart: DWORD;
 end;
{$endif}

type
  TDXGI_Format = (
    DXGI_FORMAT_UNKNOWN                    =  0,
    DXGI_FORMAT_R32G32B32A32_TYPELESS      =  1,
    DXGI_FORMAT_R32G32B32A32_FLOAT         =  2,
    DXGI_FORMAT_R32G32B32A32_UINT          =  3,
    DXGI_FORMAT_R32G32B32A32_SINT          =  4,
    DXGI_FORMAT_R32G32B32_TYPELESS         =  5,
    DXGI_FORMAT_R32G32B32_FLOAT            =  6,
    DXGI_FORMAT_R32G32B32_UINT             =  7,
    DXGI_FORMAT_R32G32B32_SINT             =  8,
    DXGI_FORMAT_R16G16B16A16_TYPELESS      =  9,
    DXGI_FORMAT_R16G16B16A16_FLOAT         = 10,
    DXGI_FORMAT_R16G16B16A16_UNORM         = 11,
    DXGI_FORMAT_R16G16B16A16_UINT          = 12,
    DXGI_FORMAT_R16G16B16A16_SNORM         = 13,
    DXGI_FORMAT_R16G16B16A16_SINT          = 14,
    DXGI_FORMAT_R32G32_TYPELESS            = 15,
    DXGI_FORMAT_R32G32_FLOAT               = 16,
    DXGI_FORMAT_R32G32_UINT                = 17,
    DXGI_FORMAT_R32G32_SINT                = 18,
    DXGI_FORMAT_R32G8X24_TYPELESS          = 19,
    DXGI_FORMAT_D32_FLOAT_S8X24_UINT       = 20,
    DXGI_FORMAT_R32_FLOAT_X8X24_TYPELESS   = 21,
    DXGI_FORMAT_X32_TYPELESS_G8X24_UINT    = 22,
    DXGI_FORMAT_R10G10B10A2_TYPELESS       = 23,
    DXGI_FORMAT_R10G10B10A2_UNORM          = 24,
    DXGI_FORMAT_R10G10B10A2_UINT           = 25,
    DXGI_FORMAT_R11G11B10_FLOAT            = 26,
    DXGI_FORMAT_R8G8B8A8_TYPELESS          = 27,
    DXGI_FORMAT_R8G8B8A8_UNORM             = 28,
    DXGI_FORMAT_R8G8B8A8_UNORM_SRGB        = 29,
    DXGI_FORMAT_R8G8B8A8_UINT              = 30,
    DXGI_FORMAT_R8G8B8A8_SNORM             = 31,
    DXGI_FORMAT_R8G8B8A8_SINT              = 32,
    DXGI_FORMAT_R16G16_TYPELESS            = 33,
    DXGI_FORMAT_R16G16_FLOAT               = 34,
    DXGI_FORMAT_R16G16_UNORM               = 35,
    DXGI_FORMAT_R16G16_UINT                = 36,
    DXGI_FORMAT_R16G16_SNORM               = 37,
    DXGI_FORMAT_R16G16_SINT                = 38,
    DXGI_FORMAT_R32_TYPELESS               = 39,
    DXGI_FORMAT_D32_FLOAT                  = 40,
    DXGI_FORMAT_R32_FLOAT                  = 41,
    DXGI_FORMAT_R32_UINT                   = 42,
    DXGI_FORMAT_R32_SINT                   = 43,
    DXGI_FORMAT_R24G8_TYPELESS             = 44,
    DXGI_FORMAT_D24_UNORM_S8_UINT          = 45,
    DXGI_FORMAT_R24_UNORM_X8_TYPELESS      = 46,
    DXGI_FORMAT_X24_TYPELESS_G8_UINT       = 47,
    DXGI_FORMAT_R8G8_TYPELESS              = 48,
    DXGI_FORMAT_R8G8_UNORM                 = 49,
    DXGI_FORMAT_R8G8_UINT                  = 50,
    DXGI_FORMAT_R8G8_SNORM                 = 51,
    DXGI_FORMAT_R8G8_SINT                  = 52,
    DXGI_FORMAT_R16_TYPELESS               = 53,
    DXGI_FORMAT_R16_FLOAT                  = 54,
    DXGI_FORMAT_D16_UNORM                  = 55,
    DXGI_FORMAT_R16_UNORM                  = 56,
    DXGI_FORMAT_R16_UINT                   = 57,
    DXGI_FORMAT_R16_SNORM                  = 58,
    DXGI_FORMAT_R16_SINT                   = 59,
    DXGI_FORMAT_R8_TYPELESS                = 60,
    DXGI_FORMAT_R8_UNORM                   = 61,
    DXGI_FORMAT_R8_UINT                    = 62,
    DXGI_FORMAT_R8_SNORM                   = 63,
    DXGI_FORMAT_R8_SINT                    = 64,
    DXGI_FORMAT_A8_UNORM                   = 65,
    DXGI_FORMAT_R1_UNORM                   = 66,
    DXGI_FORMAT_R9G9B9E5_SHAREDEXP         = 67,
    DXGI_FORMAT_R8G8_B8G8_UNORM            = 68,
    DXGI_FORMAT_G8R8_G8B8_UNORM            = 69,
    DXGI_FORMAT_BC1_TYPELESS               = 70,
    DXGI_FORMAT_BC1_UNORM                  = 71,
    DXGI_FORMAT_BC1_UNORM_SRGB             = 72,
    DXGI_FORMAT_BC2_TYPELESS               = 73,
    DXGI_FORMAT_BC2_UNORM                  = 74,
    DXGI_FORMAT_BC2_UNORM_SRGB             = 75,
    DXGI_FORMAT_BC3_TYPELESS               = 76,
    DXGI_FORMAT_BC3_UNORM                  = 77,
    DXGI_FORMAT_BC3_UNORM_SRGB             = 78,
    DXGI_FORMAT_BC4_TYPELESS               = 79,
    DXGI_FORMAT_BC4_UNORM                  = 80,
    DXGI_FORMAT_BC4_SNORM                  = 81,
    DXGI_FORMAT_BC5_TYPELESS               = 82,
    DXGI_FORMAT_BC5_UNORM                  = 83,
    DXGI_FORMAT_BC5_SNORM                  = 84,
    DXGI_FORMAT_B5G6R5_UNORM               = 85,
    DXGI_FORMAT_B5G5R5A1_UNORM             = 86,
    DXGI_FORMAT_B8G8R8A8_UNORM             = 87,
    DXGI_FORMAT_B8G8R8X8_UNORM             = 88,
    DXGI_FORMAT_R10G10B10_XR_BIAS_A2_UNORM = 89,
    DXGI_FORMAT_B8G8R8A8_TYPELESS          = 90,
    DXGI_FORMAT_B8G8R8A8_UNORM_SRGB        = 91,
    DXGI_FORMAT_B8G8R8X8_TYPELESS          = 92,
    DXGI_FORMAT_B8G8R8X8_UNORM_SRGB        = 93,
    DXGI_FORMAT_BC6H_TYPELESS              = 94,
    DXGI_FORMAT_BC6H_UF16                  = 95,
    DXGI_FORMAT_BC6H_SF16                  = 96,
    DXGI_FORMAT_BC7_TYPELESS               = 97,
    DXGI_FORMAT_BC7_UNORM                  = 98,
    DXGI_FORMAT_BC7_UNORM_SRGB             = 99
  );
  PTDXGI_Format = ^TDXGI_Format;
  DXGI_FORMAT = TDXGI_Format;
  PDXGI_FORMAT = ^TDXGI_Format;

///////////////////////////////////////////////////////////////////////////////
// End "DXGIFormat.h"
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Begin "DXGIType.h"
///////////////////////////////////////////////////////////////////////////////

const
  _FACDXGI          = $87A;
  DXGI_STATUS_Base  = LongWord(_FACDXGI shl 16);
  DXGI_HRESULT_Base = DXGI_STATUS_Base or LongWord(1 shl 31);
  //
  DXGI_STATUS_OCCLUDED                    = DXGI_STATUS_Base or 1;
  DXGI_STATUS_CLIPPED                     = DXGI_STATUS_Base or 2;
  DXGI_STATUS_NO_REDIRECTION              = DXGI_STATUS_Base or 4;
  DXGI_STATUS_NO_DESKTOP_ACCESS           = DXGI_STATUS_Base or 5;
  DXGI_STATUS_GRAPHICS_VIDPN_SOURCE_IN_USE= DXGI_STATUS_Base or 6;
  DXGI_STATUS_MODE_CHANGED                = DXGI_STATUS_Base or 7;
  DXGI_STATUS_MODE_CHANGE_IN_PROGRESS     = DXGI_STATUS_Base or 8;
  //
  DXGI_ERROR_INVALID_CALL                 = HResult(DXGI_HRESULT_Base or 1);
  DXGI_ERROR_NOT_FOUND                    = HResult(DXGI_HRESULT_Base or 2);
  DXGI_ERROR_MORE_DATA                    = HResult(DXGI_HRESULT_Base or 3);
  DXGI_ERROR_UNSUPPORTED                  = HResult(DXGI_HRESULT_Base or 4);
  DXGI_ERROR_DEVICE_REMOVED               = HResult(DXGI_HRESULT_Base or 5);
  DXGI_ERROR_DEVICE_HUNG                  = HResult(DXGI_HRESULT_Base or 6);
  DXGI_ERROR_DEVICE_RESET                 = HResult(DXGI_HRESULT_Base or 7);
  DXGI_ERROR_WAS_STILL_DRAWING            = HResult(DXGI_HRESULT_Base or 10);
  DXGI_ERROR_FRAME_STATISTICS_DISJOINT    = HResult(DXGI_HRESULT_Base or 11);
  DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE = HResult(DXGI_HRESULT_Base or 12);
  DXGI_ERROR_DRIVER_INTERNAL_ERROR        = HResult(DXGI_HRESULT_Base or 32);
  DXGI_ERROR_NONEXCLUSIVE                 = HResult(DXGI_HRESULT_Base or 33);
  DXGI_ERROR_NOT_CURRENTLY_AVAILABLE      = HResult(DXGI_HRESULT_Base or 34);
  DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED   = HResult(DXGI_HRESULT_Base or 35);
  DXGI_ERROR_REMOTE_OUTOFMEMORY           = HResult(DXGI_HRESULT_Base or 36);
  //
  DXGI_CPU_ACCESS_NONE       =  0;
  DXGI_CPU_ACCESS_DYNAMIC    =  1;
  DXGI_CPU_ACCESS_READ_WRITE =  2;
  DXGI_CPU_ACCESS_SCRATCH    =  3;
  DXGI_CPU_ACCESS_FIELD      = 15;
  //
  DXGI_USAGE_SHADER_INPUT         = 1 shl (0 + 4);
  DXGI_USAGE_RENDER_TARGET_OUTPUT = 1 shl (1 + 4);
  DXGI_USAGE_BACK_BUFFER          = 1 shl (2 + 4);
  DXGI_USAGE_SHARED               = 1 shl (3 + 4);
  DXGI_USAGE_READ_ONLY            = 1 shl (4 + 4);
  DXGI_USAGE_DISCARD_ON_PRESENT   = 1 shl (5 + 4);
  DXGI_USAGE_UNORDERED_ACCESS     = 1 shl (6 + 4);

type
  TDXGI_RGB = record
    Red:   Single;
    Green: Single;
    Blue:  Single;
  end;
  PTDXGI_RGB = ^TDXGI_RGB;
  DXGI_RGB   = TDXGI_RGB;
  PDXGI_RGB  = ^TDXGI_RGB;

  TDXGI_GammaControl = record
    Scale: TDXGI_RGB;
    Offset: TDXGI_RGB;
    GammaCurve: array[0..1024] of TDXGI_RGB;
  end;
  PTDXGI_GammaControl = ^TDXGI_GammaControl;
  DXGI_GAMMA_CONTROL  = TDXGI_GammaControl;
  PDXGI_GAMMA_CONTROL = ^TDXGI_GammaControl;

  TDXGI_GammaControlCapabilities = record
    ScaleAndOffsetSupported: LongBool;
    MaxConvertedValue: Single;
    MinConvertedValue: Single;
    NumGammaControlPoints: LongWord;
    ControlPointPositions: array[0..1024] of Single;
  end;
  PTDXGI_GammaControlCapabilities  = ^TDXGI_GammaControlCapabilities;
  DXGI_GAMMA_CONTROL_CAPABILITIES  = TDXGI_GammaControlCapabilities;
  PDXGI_GAMMA_CONTROL_CAPABILITIES = ^TDXGI_GammaControlCapabilities;

  TDXGI_Rational = record
    Numerator: LongWord;
    Denominator: LongWord;
  end;
  PTDXGI_Rational = ^TDXGI_Rational;
  DXGI_RATIONAL   = TDXGI_Rational;
  PDXGI_RATIONAL  = ^TDXGI_Rational;

  TDXGI_ModeScanlineOrder = (
    DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED=0,
    DXGI_MODE_SCANLINE_ORDER_PROGRESSIVE=1,
    DXGI_MODE_SCANLINE_ORDER_UPPER_FIELD_FIRST=2,
    DXGI_MODE_SCANLINE_ORDER_LOWER_FIELD_FIRST=3
  );
  PTDXGI_ModeScanlineOrder  = ^TDXGI_ModeScanlineOrder;
  DXGI_MODE_SCANLINE_ORDER  = TDXGI_ModeScanlineOrder;
  PDXGI_MODE_SCANLINE_ORDER = ^TDXGI_ModeScanlineOrder;

  TDXGI_ModeScaling = (
    DXGI_MODE_SCALING_UNSPECIFIED = 0,
    DXGI_MODE_SCALING_CENTERED    = 1,
    DXGI_MODE_SCALING_STRETCHED   = 2
  );
  PTDXGI_ModeScaling = ^TDXGI_ModeScaling;
  DXGI_MODE_SCALING  = TDXGI_ModeScaling;
  PDXGI_MODE_SCALING = ^TDXGI_ModeScaling;

  TDXGI_ModeRotation = (
    DXGI_MODE_ROTATION_UNSPECIFIED = 0,
    DXGI_MODE_ROTATION_IDENTITY    = 1,
    DXGI_MODE_ROTATION_ROTATE90    = 2,
    DXGI_MODE_ROTATION_ROTATE180   = 3,
    DXGI_MODE_ROTATION_ROTATE270   = 4
  );
  PTDXGI_ModeRotation = ^TDXGI_ModeRotation;
  DXGI_MODE_ROTATION  = TDXGI_ModeRotation;
  PDXGI_MODE_ROTATION = ^TDXGI_ModeRotation;

  TDXGI_ModeDesc = record
    Width: LongWord;
    Height: LongWord;
    RefreshRate: TDXGI_Rational;
    Format: TDXGI_Format;
    ScanlineOrdering: TDXGI_ModeScanlineOrder;
    Scaling: TDXGI_ModeScaling;
  end;
  PTDXGI_ModeDesc = ^TDXGI_ModeDesc;
  DXGI_MODE_DESC  = TDXGI_ModeDesc;
  PDXGI_MODE_DESC = ^TDXGI_ModeDesc;

  TDXGI_SampleDesc = record
    Count: LongWord;
    Quality: LongWord;
  end;
  PTDXGI_SampleDesc = ^TDXGI_SampleDesc;
  DXGI_SAMPLE_DESC  = TDXGI_SampleDesc;
  PDXGI_SAMPLE_DESC = ^TDXGI_SampleDesc;

///////////////////////////////////////////////////////////////////////////////
// End "DXGIType.h"
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Begin "DXGI.h"
///////////////////////////////////////////////////////////////////////////////

const
(* Already defined in "DXGIType.h"
  DXGI_CPU_ACCESS_NONE=0;
  DXGI_CPU_ACCESS_DYNAMIC=1;
  DXGI_CPU_ACCESS_READ_WRITE=2;
  DXGI_CPU_ACCESS_SCRATCH=3;
  DXGI_CPU_ACCESS_FIELD=15;
  DXGI_USAGE_SHADER_INPUT=1L shl (0 + 4);
  DXGI_USAGE_RENDER_TARGET_OUTPUT=1L shl (1 + 4);
  DXGI_USAGE_BACK_BUFFER=1L shl (2 + 4);
  DXGI_USAGE_SHARED=1L shl (3 + 4);
  DXGI_USAGE_READ_ONLY=1L shl (4 + 4);
  DXGI_USAGE_DISCARD_ON_PRESENT=1L shl (5 + 4);
  DXGI_USAGE_UNORDERED_ACCESS=1L shl (6 + 4);
*)
  DXGI_RESOURCE_PRIORITY_MINIMUM = $28000000;
  DXGI_RESOURCE_PRIORITY_LOW     = $50000000;
  DXGI_RESOURCE_PRIORITY_NORMAL  = $78000000;
  DXGI_RESOURCE_PRIORITY_HIGH    = $a0000000;
  DXGI_RESOURCE_PRIORITY_MAXIMUM = $c8000000;
  //
  DXGI_MAP_READ    = 1;
  DXGI_MAP_WRITE   = 2;
  DXGI_MAP_DISCARD = 4;
  //
  DXGI_ENUM_MODES_INTERLACED = 1;
  DXGI_ENUM_MODES_SCALING    = 2;
  //
  DXGI_MAX_SWAP_CHAIN_BUFFERS = 16;
  DXGI_PRESENT_TEST            = $00000001;
  DXGI_PRESENT_DO_NOT_SEQUENCE = $00000002;
  DXGI_PRESENT_RESTART         = $00000004;
  //
  DXGI_MWA_NO_WINDOW_CHANGES = 1 shl 0;
  DXGI_MWA_NO_ALT_ENTER      = 1 shl 1;
  DXGI_MWA_NO_PRINT_SCREEN   = 1 shl 2;
  DXGI_MWA_VALID             = $7;

type
  IDXGIObject  = interface;
  PIDXGIObject = ^IDXGIObject;

  IDXGIDeviceSubObject  = interface;
  PIDXGIDeviceSubObject = ^IDXGIDeviceSubObject;

  IDXGIResource  = interface;
  PIDXGIResource = ^IDXGIResource;

  IDXGIKeyedMutex  = interface;
  PIDXGIKeyedMutex = ^IDXGIKeyedMutex;

  IDXGISurface = interface;
  PIDXGISurface = ^IDXGISurface;

  IDXGISurface1  = interface;
  PIDXGISurface1 = ^IDXGISurface1;

  IDXGIAdapter  = interface;
  PIDXGIAdapter = ^IDXGIAdapter;

  IDXGIOutput = interface;
  PIDXGIOutput = ^IDXGIOutput;

  IDXGISwapChain  = interface;
  PIDXGISwapChain = ^IDXGISwapChain;

  IDXGIFactory  = interface;
  PIDXGIFactory = ^IDXGIFactory;

  IDXGIDevice  = interface;
  PIDXGIDevice = ^IDXGIDevice;

  IDXGIFactory1  = interface;
  PIDXGIFactory1 = ^IDXGIFactory1;

  IDXGIAdapter1  = interface;
  PIDXGIAdapter1 = ^IDXGIAdapter1;

  IDXGIDevice1  = interface;
  PIDXGIDevice1 = ^IDXGIDevice1;

  TDXGI_Usage  = UINT;
  PTDXGI_Usage = ^TDXGI_Usage;
  DXGI_USAGE   = TDXGI_Usage;
  PDXGI_USAGE  = ^TDXGI_Usage;

  TDXGI_FrameStatistics = record
    PresentCount: LongWord;
    PresentRefreshCount: LongWord;
    SyncRefreshCount: LongWord;
    SyncQPCTime: LARGE_INTEGER;
    SyncGPUTime: LARGE_INTEGER;
  end;
  PTDXGI_FrameStatistics = ^TDXGI_FrameStatistics;
  DXGI_FRAME_STATISTICS  = TDXGI_FrameStatistics;
  PDXGI_FRAME_STATISTICS = ^TDXGI_FrameStatistics;

  TDXGI_MappedRect = record
    Pitch: Integer;
    pBits: PByte;
  end;
  PTDXGI_MappedRect = ^TDXGI_MappedRect;
  DXGI_MAPPED_RECT  = TDXGI_MappedRect;
  PDXGI_MAPPED_RECT = ^TDXGI_MappedRect;

  TDXGI_AdapterDesc = record
    Description: array[0..127] of WideChar;
    VendorId: LongWord;
    DeviceId: LongWord;
    SubSysId: LongWord;
    Revision: LongWord;
    DedicatedVideoMemory: SIZE_T;
    DedicatedSystemMemory: SIZE_T;
    SharedSystemMemory: SIZE_T;
    AdapterLuid: TLUID;
  end;
  PTDXGI_AdapterDesc = ^TDXGI_AdapterDesc;
  DXGI_ADAPTER_DESC  = TDXGI_AdapterDesc;
  PDXGI_ADAPTER_DESC = ^TDXGI_AdapterDesc;

  TDXGI_OutputDesc = record
    DeviceName: array[0..31] of WideChar;
    DesktopCoordinates: TRECT;
    AttachedToDesktop: LongBool;
    Rotation: TDXGI_ModeRotation;
    Monitor: HMONITOR;
  end;
  PTDXGI_OutputDesc = ^TDXGI_OutputDesc;
  DXGI_OUTPUT_DESC  = TDXGI_OutputDesc;
  PDXGI_OUTPUT_DESC = ^TDXGI_OutputDesc;

  TDXGI_SharedResource = record
    Handle:THANDLE;
  end;
  PTDXGI_SharedResource = ^TDXGI_SharedResource;
  DXGI_SHARED_RESOURCE  = TDXGI_SharedResource;
  PDXGI_SHARED_RESOURCE = ^TDXGI_SharedResource;

  TDXGI_Residency = (
    DXGI_RESIDENCY_FULLY_RESIDENT = 1,
    DXGI_RESIDENCY_RESIDENT_IN_SHARED_MEMORY = 2,
    DXGI_RESIDENCY_EVICTED_TO_DISK = 3
  );
  PTDXGI_Residency = ^TDXGI_Residency;
  DXGI_RESIDENCY   = TDXGI_Residency;
  PDXGI_RESIDENCY  = ^TDXGI_Residency;

  TDXGI_SurfaceDesc = record
    Width: LongWord;
    Height: LongWord;
    Format: TDXGI_Format;
    SampleDesc: TDXGI_SampleDesc;
  end;
  PTDXGI_SurfaceDesc = ^TDXGI_SurfaceDesc;
  DXGI_SURFACE_DESC  = TDXGI_SurfaceDesc;
  PDXGI_SURFACE_DESC = ^TDXGI_SurfaceDesc;

  TDXGI_SwapEffect = (
    DXGI_SWAP_EFFECT_DISCARD    = 0,
    DXGI_SWAP_EFFECT_SEQUENTIAL = 1
  );
  PTDXGI_SwapEffect = ^TDXGI_SwapEffect;
  DXGI_SWAP_EFFECT  = TDXGI_SwapEffect;
  PDXGI_SWAP_EFFECT = ^TDXGI_SwapEffect;

  TDXGI_SwapChainFlag = (
    DXGI_SWAP_CHAIN_FLAG_NONPREROTATED     = 1,
    DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH = 2,
    DXGI_SWAP_CHAIN_FLAG_GDI_COMPATIBLE    = 4
  );
  PTDXGI_SwapChainFlag  = ^TDXGI_SwapChainFlag;
  DXGI_SWAP_CHAIN_FLAG  = TDXGI_SwapChainFlag;
  PDXGI_SWAP_CHAIN_FLAG = ^TDXGI_SwapChainFlag;

  TDXGI_SwapChainDesc = record
    BufferDesc: TDXGI_ModeDesc;
    SampleDesc: TDXGI_SampleDesc;
    BufferUsage: TDXGI_Usage;
    BufferCount: LongWord;
    OutputWindow: HWND;
    Windowed: LongBool;
    SwapEffect: TDXGI_SwapEffect;
    Flags: LongWord;
  end;
  PTDXGI_SwapChainDesc  = ^TDXGI_SwapChainDesc;
  DXGI_SWAP_CHAIN_DESC  = TDXGI_SwapChainDesc;
  PDXGI_SWAP_CHAIN_DESC = ^TDXGI_SwapChainDesc;

  IDXGIObject = interface(IUnknown)
    ['{AEC22FB8-76F3-4639-9BE0-28EB43A67A2E}']
    function SetPrivateData(const Name: TGUID; DataSize: LongWord; pData: Pointer): HResult; stdcall;
    function SetPrivateDataInterface(const Name: TGUID; Unknown: IUnknown): HResult; stdcall;
    function GetPrivateData(const Name:TGUID; var DataSize:LongWord; pData:Pointer): HResult; stdcall;
    function GetParent(const IID: TGUID; out pParent):HResult; stdcall;
  end;

  IDXGIDeviceSubObject = interface(IDXGIObject)
    ['{3D3E0379-F9DE-4D58-BB6C-18D62992F1A6}']
    function GetDevice(const IID:TGUID; out pDevice):HResult; stdcall;
  end;

  IDXGIResource = interface(IDXGIDeviceSubObject)
    ['{035F3AB4-482E-4E50-B41F-8A7F8BD8960B}']
    function GetSharedHandle(out SharedHandle: THANDLE): HResult; stdcall;
    function GetUsage(out Usage: TDXGI_Usage): HResult; stdcall;
    function SetEvictionPriority(EvictionPriority:LongWord): HResult; stdcall;
    function GetEvictionPriority(out EvictionPriority:LongWord): HResult; stdcall;
  end;

  IDXGIKeyedMutex = interface(IDXGIDeviceSubObject)
    ['{9D8E1289-D7B3-465F-8126-250E349AF85D}']
    function AcquireSync(Key: UInt64; Milliseconds: LongWord): HResult; stdcall;
    function ReleaseSync(Key:UInt64):HResult; stdcall;
  end;

  IDXGISurface = interface(IDXGIDeviceSubObject)
    ['{CAFCB56C-6AC3-4889-BF47-9E23BBD260EC}']
    function GetDesc(out Desc:TDXGI_SurfaceDesc): HResult; stdcall;
    function Map(out LockedRect: TDXGI_MappedRect; MapFlags: LongWord): HResult; stdcall;
    function Unmap: HResult; stdcall;
  end;

  IDXGISurface1 = interface(IDXGISurface)
    ['{4AE63092-6327-4C1B-80AE-BFE12EA32B86}']
    function GetDC(Discard: LongBool; out HDC:HDC): HResult; stdcall;
    function ReleaseDC(pDirtyRect: PTRECT): HResult; stdcall;
  end;

  IDXGIAdapter = interface(IDXGIObject)
    ['{2411E7E1-12AC-4CCF-BD14-9798E8534DC0}']
    function EnumOutputs(OutputIndex: LongWord; out Output: IDXGIOutput):HResult; stdcall;
    function GetDesc(out Desc: TDXGI_AdapterDesc): HResult; stdcall;
    function CheckInterfaceSupport(const InterfaceName: TGUID; out UMDVersion: LARGE_INTEGER):HResult; stdcall;
  end;

  IDXGIOutput = interface(IDXGIObject)
    ['{AE02EEDB-C735-4690-8D52-5A8DC20213AA}']
    function GetDesc(out Desc: TDXGI_OutputDesc): HResult; stdcall;
    function GetDisplayModeList(EnumFormat:TDXGI_Format; Flags:LongWord;
      var NumModes:LongWord; pDesc: PTDXGI_ModeDesc):HResult; stdcall;
    function FindClosestMatchingMode(const ModeToMatch: TDXGI_ModeDesc;
      out ClosestMatch: TDXGI_ModeDesc;  ConcernedDevice:IUnknown): HResult; stdcall;
    function WaitForVBlank: HResult; stdcall;
    function TakeOwnership(Device: IUnknown; Exclusive: LongBool): HResult; stdcall;
    procedure ReleaseOwnership; stdcall;
    function GetGammaControlCapabilities(out GammaCaps: TDXGI_GammaControlCapabilities): HResult; stdcall;
    function SetGammaControl(const _Array: TDXGI_GammaControl): HResult; stdcall;
    function GetGammaControl(out _Array: TDXGI_GammaControl): HResult; stdcall;
    function SetDisplaySurface(ScanoutSurface: IDXGISurface): HResult; stdcall;
    function GetDisplaySurfaceData(Destination: IDXGISurface): HResult; stdcall;
    function GetFrameStatistics(out Stats: TDXGI_FrameStatistics): HResult; stdcall;
  end;

  IDXGISwapChain = interface(IDXGIDeviceSubObject)
    ['{310D36A0-D2E7-4C0A-AA04-6A9D23B8886A}']
    function Present(SyncInterval: LongWord; Flags: LongWord): HResult; stdcall;
    function GetBuffer(Buffer: LongWord; const IID: TGUID; var pSurface): HResult; stdcall;
    function SetFullscreenState(Fullscreen: LongBool; Target: IDXGIOutput): HResult; stdcall;
    function GetFullscreenState(out Fullscreen: LongBool; out Target: IDXGIOutput): HResult; stdcall;
    function GetDesc(out Desc: TDXGI_SwapChainDesc): HResult; stdcall;
    function ResizeBuffers(BufferCount, Width, Height:LongWord; NewFormat:TDXGI_Format; 
      SwapChainFlags:LongWord): HResult; stdcall;
    function ResizeTarget(const NewTargetParameters: TDXGI_ModeDesc): HResult; stdcall;
    function GetContainingOutput(out Output: IDXGIOutput): HResult; stdcall;
    function GetFrameStatistics(out Stats: TDXGI_FrameStatistics): HResult; stdcall;
    function GetLastPresentCount(out LastPresentCount: LongWord): HResult; stdcall;
  end;

  IDXGIFactory = interface(IDXGIObject)
    ['{7B7166EC-21C7-44AE-B21A-C9AE321AE369}']
    function EnumAdapters(AdapterIndex: LongWord; out Adapter: IDXGIAdapter): HResult; stdcall;
    function MakeWindowAssociation(WindowHandle: HWND; Flags: LongWord): HResult; stdcall;
    function GetWindowAssociation(out WindowHandle: HWND): HResult; stdcall;
    function CreateSwapChain(Device: IUnknown; const Desc: TDXGI_SwapChainDesc; 
      out SwapChain: IDXGISwapChain): HResult; stdcall;
    function CreateSoftwareAdapter(Module: HMODULE; out Adapter: IDXGIAdapter): HResult; stdcall;
  end;

  PIUnknown = ^IUnknown;

  IDXGIDevice = interface(IDXGIObject)
    ['{54EC77FA-1377-44E6-8C32-88FD5F44C84C}']
    function GetAdapter(out pAdapter: IDXGIAdapter): HResult; stdcall;
    function CreateSurface(const Desc: TDXGI_SurfaceDesc; NumSurfaces: LongWord;
      Usage: TDXGI_Usage; pSharedResource: PTDXGI_SharedResource; out Surface: IDXGISurface): HResult; stdcall;
    function QueryResourceResidency(pResources: PIUnknown; pResidencyStatus: PTDXGI_Residency;
      NumResources: LongWord):HResult; stdcall;
    function SetGPUThreadPriority(Priority: Integer): HResult; stdcall;
    function GetGPUThreadPriority(out Priority: Integer): HResult; stdcall;
  end;

  TDXGI_AdapterFlag = (
    DXGI_ADAPTER_FLAG_NONE   = 0,
    DXGI_ADAPTER_FLAG_REMOTE = 1
  );
  PTDXGI_AdapterFlag = ^TDXGI_AdapterFlag;
  DXGI_ADAPTER_FLAG  = TDXGI_AdapterFlag;
  PDXGI_ADAPTER_FLAG = ^TDXGI_AdapterFlag;

  TDXGI_AdapterDesc1 = record
    Description: array[0..127] of WideChar;
    VendorId: LongWord;
    DeviceId: LongWord;
    SubSysId: LongWord;
    Revision: LongWord;
    DedicatedVideoMemory: SIZE_T;
    DedicatedSystemMemory: SIZE_T;
    SharedSystemMemory: SIZE_T;
    AdapterLuid: TLUID;
    Flags: LongWord;
  end;
  PTDXGI_AdapterDesc1 = ^TDXGI_AdapterDesc1;
  DXGI_ADAPTER_DESC1  = TDXGI_AdapterDesc1;
  PDXGI_ADAPTER_DESC1 = ^TDXGI_AdapterDesc1;

  TDXGI_DisplayColorSpace = record
    PrimaryCoordinates: array[0..7,0..1] of Single;
    WhitePoints: array[0..15,0..1] of Single;
  end;
  PTDXGI_DisplayColorSpace  = ^TDXGI_DisplayColorSpace;
  DXGI_DISPLAY_COLOR_SPACE  = TDXGI_DisplayColorSpace;
  PDXGI_DISPLAY_COLOR_SPACE = ^TDXGI_DisplayColorSpace;

  IDXGIFactory1 = interface(IDXGIFactory)
    ['{770AAE78-F26F-4DBA-A829-253C83D1B387}']
    function EnumAdapters1(AdapterIndex: LongWord; out Adapter: IDXGIAdapter1): HResult; stdcall;
    function IsCurrent: LongBool; stdcall;
  end;

  IDXGIAdapter1 = interface(IDXGIAdapter)
    ['{29038F61-3839-4626-91FD-086879011A05}']
    function GetDesc1(out Desc: TDXGI_AdapterDesc1): HResult; stdcall;
  end;

  IDXGIDevice1 = interface(IDXGIDevice)
    ['{77DB970F-6276-48BA-BA28-070143B4392C}']
    function SetMaximumFrameLatency(MaxLatency: LongWord): HResult; stdcall;
    function GetMaximumFrameLatency(out MaxLatency:LongWord): HResult; stdcall;
  end;

{$IFDEF UseRuntimeLinking}var CreateDXGIFactory:{$ENDIF}function{$IFNDEF UseRuntimeLinking}CreateDXGIFactory{$ENDIF}(const IID:TGUID;out pFactory {Interface}):HResult; stdcall; {$IFNDEF UseRuntimeLinking}external DLL_DXGI;{$ENDIF}
{$IFDEF UseRuntimeLinking}var CreateDXGIFactory1:{$ENDIF}function{$IFNDEF UseRuntimeLinking}CreateDXGIFactory1{$ENDIF}(const IID:TGUID;out pFactory {Interface}):HResult; stdcall; {$IFNDEF UseRuntimeLinking}external DLL_DXGI;{$ENDIF}

///////////////////////////////////////////////////////////////////////////////
// End "DXGI.h"
///////////////////////////////////////////////////////////////////////////////

{$IFDEF UseRuntimeLinking}
// Asphyre: The following two methods link the functions from DXGI 1.0 and
// from DXGI 1.1 separately.
procedure LinkStart();
procedure LinkDXGI10();
procedure LinkDXGI11();

procedure Link();
{$ENDIF}

implementation

{$IFDEF UseJSBErrors}
function HResultToString(Value:HRESULT):String;
begin
  Result:='';
  if SUCCEEDED(Value) then Exit;

  case Value of
    DXGI_ERROR_INVALID_CALL: Result:='DXGI: Invalid call.';
    DXGI_ERROR_NOT_FOUND: Result:='DXGI: Not found.';
    DXGI_ERROR_MORE_DATA: Result:='DXGI: Insufficient room for data.';
    DXGI_ERROR_UNSUPPORTED: Result:='DXGI: Not supported.';
    DXGI_ERROR_DEVICE_REMOVED: Result:='DXGI: The device has been removed.';
    DXGI_ERROR_DEVICE_HUNG: Result:='DXGI: The device is hung (design time issue).';
    DXGI_ERROR_DEVICE_RESET: Result:='DXGI: The device has reset (run time issue).';
    DXGI_ERROR_WAS_STILL_DRAWING: Result:='DXGI: Was still drawing.';
    DXGI_ERROR_FRAME_STATISTICS_DISJOINT: Result:='DXGI: Disjoint frame statistics.';
    DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE: Result:='DXGI: DXGI_ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE'; // ???
    DXGI_ERROR_DRIVER_INTERNAL_ERROR: Result:='DXGI: Internal driver error.';
    DXGI_ERROR_NONEXCLUSIVE: Result:='DXGI: Failed to acquire exclusive ownership.';
    DXGI_ERROR_NOT_CURRENTLY_AVAILABLE: Result:='DXGI: Not currently available.';
    DXGI_ERROR_REMOTE_CLIENT_DISCONNECTED: Result:='DXGI: The remove client has disconnected.';
    DXGI_ERROR_REMOTE_OUTOFMEMORY: Result:='DXGI: The remote device is out of memory.';
  end;
end;
{$ENDIF}

{$IFDEF UseRuntimeLinking}
function LoadDLL(DLLName: String): HModule;
begin
  Result:=LoadLibrary(PChar(DLLName));
  if Result = 0 then
    raise Exception.Create('Dynamic link library (DLL) '''+DLLName+''' is not available.');
end;

function LinkMethod(hDLL: HModule; MethodName, DLLName:String): Pointer;
begin
  Result := GetProcAddress(hDLL,PChar(MethodName));
  if Result = nil then
    raise Exception.Create('Failed to link to method '''+MethodName+''' in dynamic link library (DLL) '''+DLLName+'''.');
end;

var
 hDLL_DXGI: HModule = 0;

procedure LinkStart();
begin
  hDLL_DXGI:= LoadDLL(DLL_DXGI);
end;

procedure LinkDXGI10();
begin
  CreateDXGIFactory:= LinkMethod(hDLL_DXGI, 'CreateDXGIFactory', DLL_DXGI);
end;

procedure LinkDXGI11();
begin
  CreateDXGIFactory1:= LinkMethod(hDLL_DXGI, 'CreateDXGIFactory1', DLL_DXGI);
end;

procedure Link;
begin
  LinkStart();
  LinkDXGI10();
  LinkDXGI11();
end;
{$ENDIF}

initialization
{$IFDEF UseRuntimeLinking}
  //Link;
{$ENDIF}

end.
