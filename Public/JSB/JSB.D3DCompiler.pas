unit JSB.D3DCompiler;
///////////////////////////////////////////////////////////////////////////////
// Title: Translation of DirectX C++ header files for use with Delphi 2009 and later
//
// File name: JSB.D3DCompiler.pas
//
// Originator: J S Bladen, Sheffield, UK.
//
// Copyright: J S Bladen, Sheffield, UK.
//
// Translation date and time (UTC): 11/10/2010 09:47:30
//
// Email: DirectXForDelphi@jsbmedical.co.uk
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Original file(s):
//   D3Dcompiler.h
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
interface
{$Z4}
{$DEFINE UseRuntimeLinking}
{$DEFINE UNICODE}
uses
  Windows, SysUtils, JSB.DXTypes, JSB.D3DCommon, JSB.D3D10;
///////////////////////////////////////////////////////////////////////////////
// Begin "D3Dcompiler.h"
///////////////////////////////////////////////////////////////////////////////
const
  D3DCOMPILER_DLL = 'd3dcompiler_43.dll';
const
  D3DCOMPILE_DEBUG = (1 shl 0);
  D3DCOMPILE_SKIP_VALIDATION = (1 shl 1);
  D3DCOMPILE_SKIP_OPTIMIZATION = (1 shl 2);
  D3DCOMPILE_PACK_MATRIX_ROW_MAJOR = (1 shl 3);
  D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR = (1 shl 4);
  D3DCOMPILE_PARTIAL_PRECISION = (1 shl 5);
  D3DCOMPILE_FORCE_VS_SOFTWARE_NO_OPT = (1 shl 6);
  D3DCOMPILE_FORCE_PS_SOFTWARE_NO_OPT = (1 shl 7);
  D3DCOMPILE_NO_PRESHADER = (1 shl 8);
  D3DCOMPILE_AVOID_FLOW_CONTROL = (1 shl 9);
  D3DCOMPILE_PREFER_FLOW_CONTROL = (1 shl 10);
  D3DCOMPILE_ENABLE_STRICTNESS = (1 shl 11);
  D3DCOMPILE_ENABLE_BACKWARDS_COMPATIBILITY = (1 shl 12);
  D3DCOMPILE_IEEE_STRICTNESS = (1 shl 13);
  D3DCOMPILE_OPTIMIZATION_LEVEL0 = (1 shl 14);
  D3DCOMPILE_OPTIMIZATION_LEVEL1 = 0;
  D3DCOMPILE_OPTIMIZATION_LEVEL2 = ((1 shl 14) or (1 shl 15));
  D3DCOMPILE_OPTIMIZATION_LEVEL3 = (1 shl 15);
  D3DCOMPILE_RESERVED16 = (1 shl 16);
  D3DCOMPILE_RESERVED17 = (1 shl 17);
  D3DCOMPILE_WARNINGS_ARE_ERRORS = (1 shl 18);
  D3DCOMPILE_EFFECT_CHILD_EFFECT = (1 shl 0);
  D3DCOMPILE_EFFECT_ALLOW_SLOW_OPS = (1 shl 1);
  D3D_DISASM_ENABLE_COLOR_CODE = $00000001;
  D3D_DISASM_ENABLE_DEFAULT_VALUE_PRINTS = $00000002;
  D3D_DISASM_ENABLE_INSTRUCTION_NUMBERING = $00000004;
  D3D_DISASM_ENABLE_INSTRUCTION_CYCLE = $00000008;
  D3D_DISASM_DISABLE_DEBUG_INFO = $00000010;
  D3D_COMPRESS_SHADER_KEEP_ALL_PARTS = $00000001;
  
{$IFDEF UseRuntimeLinking}var D3DCompile: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DCompile{$ENDIF} (
  pSrcData: Pointer; SrcDataSize: SIZE_T; pSourceName: PAnsiChar; 
  pDefines: PTD3D_ShaderMacro; Include: ID3DInclude; pEntrypoint: PAnsiChar; 
  pTarget: PAnsiChar;  Flags1, Flags2: LongWord; out Code: ID3DBlob;
  {$IFDEF UsePointersForOptionalOutputInterfaces}pErrorMsgs: PID3DBlob{$ELSE}out ErrorMsgs: ID3DBlob{$ENDIF}): HResult; stdcall;{$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DPreprocess: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DPreprocess{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; pSourceName: PAnsiChar; 
  pDefines: PTD3D_ShaderMacro; Include: ID3DInclude; out CodeText: ID3DBlob; 
  {$IFDEF UsePointersForOptionalOutputInterfaces}pErrorMsgs: PID3DBlob{$ELSE}out ErrorMsgs: ID3DBlob{$ENDIF}): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DGetDebugInfo: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DGetDebugInfo{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; out DebugInfo: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DReflect: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DReflect{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T;  const pInterface: TGUID; out pReflector (* JSB :Pointer *)): HResult; stdcall;{$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DDisassemble: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DDisassemble{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; Flags: LongWord; Comments: PAnsiChar;
  out Disassembly: ID3DBlob): HResult; stdcall;{$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DDisassemble10Effect: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DDisassemble10Effect{$ENDIF}(
  Effect: ID3D10Effect;  Flags: LongWord; out Disassembly: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DGetInputSignatureBlob: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DGetInputSignatureBlob{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; out SignatureBlob: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DGetOutputSignatureBlob: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DGetOutputSignatureBlob{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; out SignatureBlob: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D3DGetInputAndOutputSignatureBlob: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DGetInputAndOutputSignatureBlob{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; out SignatureBlob: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}

type
  TD3DCOMPILER_STRIP_FLAGS = (
    D3DCOMPILER_STRIP_REFLECTION_DATA = 1,
    D3DCOMPILER_STRIP_DEBUG_INFO = 2,
    D3DCOMPILER_STRIP_TEST_BLOBS = 4
  );
  PTD3DCOMPILER_STRIP_FLAGS = ^TD3DCOMPILER_STRIP_FLAGS;
  D3DCOMPILER_STRIP_FLAGS = TD3DCOMPILER_STRIP_FLAGS;
  PD3DCOMPILER_STRIP_FLAGS = ^TD3DCOMPILER_STRIP_FLAGS;
  
{$IFDEF UseRuntimeLinking}var D3DStripShader: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DStripShader{$ENDIF}(
  pShaderBytecode: Pointer; BytecodeLength: SIZE_T; StripFlags: LongWord;
  out StrippedBlob: ID3DBlob): HResult; stdcall;{$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}
  
type
  TD3D_BlobPart = (
    D3D_BLOB_INPUT_SIGNATURE_BLOB,
    D3D_BLOB_OUTPUT_SIGNATURE_BLOB,
    D3D_BLOB_INPUT_AND_OUTPUT_SIGNATURE_BLOB,
    D3D_BLOB_PATCH_CONSTANT_SIGNATURE_BLOB,
    D3D_BLOB_ALL_SIGNATURE_BLOB,
    D3D_BLOB_DEBUG_INFO,
    D3D_BLOB_LEGACY_SHADER,
    D3D_BLOB_XNA_PREPASS_SHADER,
    D3D_BLOB_XNA_SHADER,
    D3D_BLOB_TEST_ALTERNATE_SHADER = $8000,
    D3D_BLOB_TEST_COMPILE_DETAILS,
    D3D_BLOB_TEST_COMPILE_PERF
  );
  PTD3D_BlobPart = ^TD3D_BlobPart;
  D3D_BLOB_PART = TD3D_BlobPart;
  PD3D_BLOB_PART = ^TD3D_BlobPart;
  
{$IFDEF UseRuntimeLinking}var D3DGetBlobPart: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DGetBlobPart{$ENDIF}(
  pSrcData: Pointer; SrcDataSize: SIZE_T; Part: TD3D_BlobPart; 
  Flags: LongWord; out o_Part: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}
  
type
  TD3D_ShaderData = record
    pBytecode: Pointer;
    BytecodeLength: SIZE_T;
  end;
  PTD3D_ShaderData = ^TD3D_ShaderData;
  D3D_SHADER_DATA = TD3D_ShaderData;
  PD3D_SHADER_DATA = ^TD3D_ShaderData;
  
{$IFDEF UseRuntimeLinking}var D3DCompressShaders: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DCompressShaders{$ENDIF}(
  NumShaders: LongWord;  pShaderData: PTD3D_ShaderData; Flags: LongWord; 
  out CompressedData: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}
  
{$IFDEF UseRuntimeLinking}var D3DDecompressShaders: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DDecompressShaders{$ENDIF}(
  pSrcData: Pointer;  SrcDataSize: SIZE_T; NumShaders: LongWord;
  StartIndex: LongWord; pIndices: PLongWord; Flags: LongWord; 
  pShaders: PID3DBlob; pTotalShaders: PLongWord): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}
  
{$IFDEF UseRuntimeLinking}var D3DCreateBlob: {$ENDIF}function{$IFNDEF UseRuntimeLinking}D3DCreateBlob{$ENDIF}(
  Size: SIZE_T; out Blob: ID3DBlob): HResult; stdcall; {$IFNDEF UseRuntimeLinking}external D3DCOMPILER_DLL;{$ENDIF}
  
///////////////////////////////////////////////////////////////////////////////
// End "D3Dcompiler.h"
///////////////////////////////////////////////////////////////////////////////

{$IFDEF UseRuntimeLinking}
procedure Link;
{$ENDIF}

implementation

{$IFDEF UseRuntimeLinking}
function LoadDLL(DLLName: string): HModule;
begin
  Result := LoadLibrary(PChar(DLLName));
  if Result = 0 then
    raise Exception.Create('Dynamic link library (DLL) ''' + DLLName + ''' is not available.');
end;

function LinkMethod(hDLL: HModule; MethodName, DLLName: string): Pointer;
begin
  Result := GetProcAddress(hDLL, PChar(MethodName));
  if Result = nil then
    raise Exception.Create('Failed to link to method ''' + MethodName + ''' in dynamic link library (DLL) ''' + DLLName + '''.');
end;

procedure Link;
var
  hD3DCOMPILER_DLL: HModule;
begin
  hD3DCOMPILER_DLL := LoadDLL(D3DCOMPILER_DLL);
  D3DCompile := LinkMethod(hD3DCOMPILER_DLL, 'D3DCompile', D3DCOMPILER_DLL);
  D3DPreprocess := LinkMethod(hD3DCOMPILER_DLL, 'D3DPreprocess', D3DCOMPILER_DLL);
  D3DGetDebugInfo := LinkMethod(hD3DCOMPILER_DLL, 'D3DGetDebugInfo', D3DCOMPILER_DLL);
  D3DReflect := LinkMethod(hD3DCOMPILER_DLL, 'D3DReflect', D3DCOMPILER_DLL);
  D3DDisassemble := LinkMethod(hD3DCOMPILER_DLL, 'D3DDisassemble', D3DCOMPILER_DLL);
  D3DDisassemble10Effect := LinkMethod(hD3DCOMPILER_DLL, 'D3DDisassemble10Effect', D3DCOMPILER_DLL);
  D3DGetInputSignatureBlob := LinkMethod(hD3DCOMPILER_DLL, 'D3DGetInputSignatureBlob', D3DCOMPILER_DLL);
  D3DGetOutputSignatureBlob := LinkMethod(hD3DCOMPILER_DLL, 'D3DGetOutputSignatureBlob', D3DCOMPILER_DLL);
  D3DGetInputAndOutputSignatureBlob := LinkMethod(hD3DCOMPILER_DLL, 'D3DGetInputAndOutputSignatureBlob', D3DCOMPILER_DLL);
  D3DStripShader := LinkMethod(hD3DCOMPILER_DLL, 'D3DStripShader', D3DCOMPILER_DLL);
  D3DGetBlobPart := LinkMethod(hD3DCOMPILER_DLL, 'D3DGetBlobPart', D3DCOMPILER_DLL);
  D3DCompressShaders := LinkMethod(hD3DCOMPILER_DLL, 'D3DCompressShaders', D3DCOMPILER_DLL);
  D3DDecompressShaders := LinkMethod(hD3DCOMPILER_DLL, 'D3DDecompressShaders', D3DCOMPILER_DLL);
  D3DCreateBlob := LinkMethod(hD3DCOMPILER_DLL, 'D3DCreateBlob', D3DCOMPILER_DLL);
end;
{$ENDIF}

initialization
{$IFDEF UseRuntimeLinking}
  //Link;
{$ENDIF}
end.
