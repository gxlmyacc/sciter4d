{*******************************************************************************
 标题:     SciterGraphicApiImpl.pas
 描述:     Sciter导出的GraphicApi接口封装
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterGraphicImpl;

interface

uses
  SysUtils, SciterTypes, Classes, SciterGraphicTypes, SciterGraphicIntf, Windows;

type
  TSciterDIB32 = class(TInterfacedObject, ISciterDIB32)
  private
    FWidth: Cardinal;
    FHeight: Cardinal;
    FBits: Pointer;
    FOldBitmap: HBITMAP;
    FDC: HDC;
    FBitmap: HBITMAP;
    FBitmapInfo: TBitmapInfo;
    function GetHeight: Cardinal;
    function GetWidth: Cardinal;
    function GetBits: Pointer;
    function GetBitsSize: Cardinal;
    function GetBytes: PByte;
    function GetDC: HDC;
    function GetBitmapInfo: PBitmapInfo;
  public
    constructor Create(const AWidth, AHeight: Cardinal);
    destructor Destroy; override;

    procedure ClearToWhite;
    function  Detach: HBITMAP;

    property Width: Cardinal read GetWidth;
    property Height: Cardinal read GetHeight;
    property Bits: Pointer read GetBits;
    property BitsSize: Cardinal read GetBitsSize;
    property Bytes: PByte read GetBytes;
    property DC: HDC read GetDC;
    property Info: PBitmapInfo read GetBitmapInfo;
  end;
  
  TSciterImage = class(TInterfacedObject, ISciterImage)
  private
    FHandle: HIMG;
  protected
    function GetHandle: HIMG;
    function GetValue: tiscript_value;
    function GetWidth: UINT;
    function GetHeight: UINT;
    function GetUsesAlpha: BOOL;
    
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const bytes: PByte; num_bytes: UINT); overload;
    constructor Create(img: HIMG); overload;
    constructor Create(width, height: UINT; withAlpha: LongBool); overload;
    constructor CreateFromPixmap(pixmapWidth, pixmapHeight: UINT; withAlpha: LongBool; const pixmapPixels: PByte);
    constructor CreateImageFromValue(value: PSCITER_VALUE);
    
    function GetInfo(var width, height: UINT; var usesAlpha: BOOL): GRAPHIN_RESULT;
    function Clear(byColor: SC_COLOR): ISciterImage;
    function Save(pfn: image_write_function; var prm: Pointer; encoding: TSciterImageEncoding; quality: UINT): ISciterImage; overload;
    function Save(const filename: SciterString; encoding: TSciterImageEncoding; quality: UINT): ISciterImage; overload;

    function CreateGraphic: ISciterGraphic;

    // draws img onto the graphics surface with current transformation applied (scale, rotation).
    function Draw(hgfx: HGFX; x, y: SC_POS;
      w: SC_DIM = 0; h: SC_DIM = 0; ix: PUINT = nil; iy: PUINT = nil; iw: PUINT = nil; ih: PUINT = nil;
      opacity: PSingle = nil): ISciterImage;
    function Paint(pPainter: image_paint_function; prm: Pointer): ISciterImage;

    property Handle: HIMG read GetHandle;
    property Value: tiscript_value read GetValue;
    property Width: UINT read GetWidth;
    property Height: UINT read GetHeight;
    property UsesAlpha: BOOL read GetUsesAlpha;
  end;

  TSciterGraphic = class(TInterfacedObject, ISciterGraphic)
  private
    FHandle: HGFX;
  protected
    function GetHandle: HGFX;
    function GetValue: tiscript_value;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(hgfx: HGFX);
    constructor CreateFromImage(img: HIMG);
    constructor CreateGraphicFromValue(value: PSCITER_VALUE);

    //== SECTION: graphics primitives and drawing operations
    // Draws line from x1,y1 to x2,y2 using current lineColor and lineGradient.
    function Line(x1, y1, x2, y2: SC_POS): ISciterGraphic;
    // Draws rectangle using current lineColor/lineGradient and fillColor/fillGradient with (optional) rounded corners.
    function Rectangle(x1, y1, x2, y2: SC_POS): ISciterGraphic;
    // Draws rounded rectangle using current lineColor/lineGradient and fillColor/fillGradient with (optional) rounded corners.
    function RoundedRectangle(x1, y1, x2, y2: SC_POS; const radii8: PSC_DIM_ARRAY8(* DIM[8] - four rx/ry pairs *)): ISciterGraphic;
    // Draws circle or ellipse using current lineColor/lineGradient and fillColor/fillGradient.
    function Ellipse(x, y: SC_POS;  rx, ry: SC_DIM): ISciterGraphic;
    // Draws closed arc using current lineColor/lineGradient and fillColor/fillGradient.
    function Arc(x, y, rx, ry: SC_POS; start, sweep: SC_ANGLE): ISciterGraphic;
    // Draws star.
    function Star(x, y: SC_POS; r1, r2: SC_DIM; start: SC_ANGLE; rays: UINT): ISciterGraphic;
    // Closed polygon.
    function Polygon(const xy: PSC_POS; num_points: UINT): ISciterGraphic;
    // Polyline.
    function Polyline(const xy: PSC_POS; num_points: UINT): ISciterGraphic;
    //== END: graphics primitives and drawing operations.

    //== SECTION: affine tranformations:
    function Rotate(radians: SC_ANGLE; cx: PSC_POS = nil; cy: PSC_POS = nil): ISciterGraphic;
    function Translate(cx, cy: SC_POS): ISciterGraphic;
    function Scale(x, y: SC_DIM): ISciterGraphic;
    function Skew(dx, dy: SC_DIM): ISciterGraphic;
    // all above in one shot
    function Transform(m11, m12, m21, m22: SC_POS; dx, dy: SC_POS): ISciterGraphic;
    //== END: affine tranformations.

    //== SECTION: state save/restore
    function Save: ISciterGraphic;
    function Restore: ISciterGraphic;
    //== END: state save/restore

    //== SECTION: drawing attributes
    // set line width for subsequent drawings.
    function NoLine(): ISciterGraphic;
    function LineWidth(width: SC_DIM): ISciterGraphic;
    function LineJoin(type_: SCITER_LINE_JOIN_TYPE): ISciterGraphic;
    function LineCap(type_: SCITER_LINE_CAP_TYPE): ISciterGraphic;
    // COLOR for solid lines/strokes
    function LineColor(c: SC_COLOR): ISciterGraphic;
    // COLOR for solid fills
    function FillColor(color: SC_COLOR): ISciterGraphic;
    function NoFill(): ISciterGraphic;
    // setup parameters of linear gradient of lines.
    function LineLinearGradient(x1, y1, x2, y2: SC_POS; stops: PColorStop; nstops: UINT): ISciterGraphic; overload;
    function LineLinearGradient(x1, y1, x2, y2: SC_POS; c1, c2: SC_COLOR): ISciterGraphic; overload;
    // setup parameters of linear gradient of fills.
    function FillLinearGradient(x1, y1, x2, y2: SC_POS; stops: PColorStop; nstops: UINT): ISciterGraphic; overload;
    function FillLinearGradient(x1, y1, x2, y2: SC_POS; c1, c2: SC_COLOR): ISciterGraphic; overload;
    // setup parameters of line gradient radial fills.
    function LineRadialGradient(x, y: SC_POS; rx, ry: SC_DIM; stops: PColorStop; nstops: UINT): ISciterGraphic; overload;
    function LineRadialGradient(x, y: SC_POS; rx, ry: SC_DIM; c1, c2: SC_COLOR): ISciterGraphic; overload;
    // setup parameters of gradient radial fills.
    function FillRadialGradient(x, y: SC_POS; rx, ry: SC_DIM; stops: PColorStop; nstops: UINT): ISciterGraphic; overload;
    function FillRadialGradient(x, y: SC_POS; rx, ry: SC_DIM; c1, c2: SC_COLOR): ISciterGraphic; overload;
    function FillMode(even_odd: LongBool = False): ISciterGraphic;
    //== EMD: drawing attributes

    //== SECTION: coordinate space
    function WorldToScreen(var inout_x, inout_y: SC_POS): ISciterGraphic; overload;
    function WorldToScreen(var inout_length: SC_DIM): ISciterGraphic; overload;
    function WorldToScreenX(x: SC_POS): SC_POS;
    function WorldToScreenY(y: SC_POS): SC_POS;
    function ScreenToWorld(var inout_x, inout_y: SC_POS): ISciterGraphic; overload;
    function ScreenToWorld(var inout_length: SC_DIM): ISciterGraphic; overload;
    function ScreenToWorldX(var x: SC_POS): SC_POS;
    function ScreenToWorldY(var y: SC_POS): SC_POS;
    //== END: coordinate space

    //== SECTION: clipping
    function PushClipBox(x1, y1, x2, y2: SC_POS; opacity: Single = 1.0): ISciterGraphic;
    function PushClipPath(path: HPATH; opacity: Single = 1.0): ISciterGraphic;
    // pop clip layer previously set by gPushClipBox or gPushClipPath
    function PopClip: ISciterGraphic;
    //== END: clipping

    function DrawPath(path: HPATH; dpm: DRAW_PATH_MODE): ISciterGraphic;
    // draw text with position (1..9 on MUMPAD) at px,py
    // Ex: gDrawText( 100,100,5) will draw text box with its center at 100,100 px
    function DrawText(text: HTEXT; px, py: SC_POS; position: UINT): ISciterGraphic;

    // draws img onto the graphics surface with current transformation applied (scale, rotation).
    function DrawImage(himg: HIMG; x, y: SC_POS): ISciterGraphic; overload;
    function DrawImage(himg: HIMG; x, y: SC_POS; w, h: SC_DIM): ISciterGraphic; overload;
    function DrawImage(himg: HIMG; x, y: SC_POS; w, h: SC_DIM;
      ix, iy, iw, ih: UINT): ISciterGraphic; overload;
    // blends image bits with bits of the surface. no affine transformations. less expensive
    function BlendImage(himg: HIMG; x, y: SC_POS; opacity: Single): ISciterGraphic; overload;
    function BlendImage(himg: HIMG; x, y: SC_POS; opacity: Single;
      ix, iy, iw, ih: UINT): ISciterGraphic; overload;
    function BlendImage(himg: HIMG; x, y: SC_POS; w, h: SC_DIM; opacity: Single): ISciterGraphic; overload;
    function BlendImage(himg: HIMG; x, y: SC_POS; w, h: SC_DIM; opacity: Single;
      ix, iy, iw, ih: UINT): ISciterGraphic; overload;

    property Handle: HGFX read GetHandle;
    property Value: tiscript_value read GetValue;
  end;

  TSciterGraphicPath = class(TInterfacedObject, ISciterGraphicPath)
  private
    FHandle: HPATH;
  protected
    function GetHandle: HPATH;
    function GetValue: tiscript_value;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(path: HPATH); overload;
    constructor Create; overload;
    constructor CreatePathFromValue(value: PSCITER_VALUE);
     
    function MoveTo(x, y: SC_POS; relative: LongBool): ISciterGraphicPath;
    function LineTo(x, y: SC_POS; relative: LongBool): ISciterGraphicPath;
    function ArcTo(x, y: SC_POS; angle: SC_ANGLE; rx, ry: SC_DIM;
      is_large_arc, clockwise, relative: LongBool): ISciterGraphicPath;
    function QuadraticCurveTo( xc, yc, x, y: SC_POS; relative: LongBool): ISciterGraphicPath;
    function BezierCurveTo(xc1, yc1, xc2, yc2, x, y: SC_POS; relative: LongBool): ISciterGraphicPath;

    function DrawPath(hgfx: HGFX; dpm: DRAW_PATH_MODE): ISciterGraphicPath;
    function ClosePath: ISciterGraphicPath;
    
    property Handle: HPATH read GetHandle;
    property Value: tiscript_value read GetValue;
  end;

  TSciterGraphicText = class(TInterfacedObject, ISciterGraphicText)
  private
    FHandle: HTEXT;
  protected
    function GetHandle: HTEXT;
    function GetValue: tiscript_value;
    function GetMinWidth: SC_DIM;
    function GetMaxWidth: SC_DIM;
    function GetHeight: SC_DIM;
    function GetAscent: SC_DIM;
    function GetDescent: SC_DIM;
    function GetLines: UINT;
  public
    constructor CreateForElement(text: LPCWSTR; textLength: UINT; he: HELEMENT);
    constructor Create(text: LPCWSTR; textLength: UINT; const format: TSciterTextFormat); overload;
    constructor Create(text: HTEXT); overload;
    constructor CreateTextFromValue(value: PSCITER_VALUE);
      
    function GetMetrics(var minWidth, maxWidth, height, ascent, descent: SC_DIM; var nLines: UINT): ISciterGraphicText;
    function SetBox(width, height: SC_DIM): ISciterGraphicText;

    // draw text with position (1..9 on MUMPAD) at px,py
    // Ex: gDrawText( 100,100,5) will draw text box with its center at 100,100 px
    function DrawText(hgfx: HGFX; px, py: SC_POS; position: UINT): ISciterGraphicText;

    property Handle: HTEXT read GetHandle;
    property Value: tiscript_value read GetValue;
    property MinWidth: SC_DIM read GetMinWidth;
    property Height: SC_DIM read GetHeight;
    property Ascent: SC_DIM read GetAscent;
    property Descent: SC_DIM read GetDescent;
    property Lines: UINT read GetLines;
  end;

  TSciterGraphicFactory = class(TInterfacedObject, ISciterGraphicFactory)
  public
    function CreateDIB32(const AWidth, AHeight: Cardinal): ISciterDIB32;
    
    function LoadImage(const filename: SciterString): ISciterImage; overload;
    function LoadImage(const bytes: PByte; num_bytes: UINT): ISciterImage; overload;
    function CreateImage(himg: HIMG): ISciterImage; overload;
    function CreateImage(width, height: UINT; withAlpha: LongBool): ISciterImage; overload;
    function CreateImageFromPixmap(pixmapWidth, pixmapHeight: UINT; withAlpha: LongBool; const pixmapPixels: PByte): ISciterImage;
    function CreateImageFromValue(const value: tiscript_value): ISciterImage;

    function CreateGraphic(hgfx: HGFX): ISciterGraphic;
    function CreateGraphicFromImage(img: HIMG): ISciterGraphic;
    function CreateGraphicFromValue(const value: tiscript_value): ISciterGraphic;

    function CreatePath: ISciterGraphicPath; overload;
    function CreatePath(path: HPATH): ISciterGraphicPath; overload;
    function CreatePathFromValue(const value: tiscript_value): ISciterGraphicPath;

    // create text layout using element's styles
    function CreateTextForElement(text: LPCWSTR; textLength: UINT; he: HELEMENT): ISciterGraphicText; overload;
    function CreateTextForElement(const text: SciterString; he: HELEMENT): ISciterGraphicText; overload;
    function CreateText(const handle: HTEXT): ISciterGraphicText; overload;
    function CreateText(text: LPCWSTR; textLength: UINT; const format: TSciterTextFormat): ISciterGraphicText; overload;
    function CreateText(const text: SciterString; const format: TSciterTextFormat): ISciterGraphicText; overload;
    function CreateTextFromValue(const value: tiscript_value): ISciterGraphicText;

    function RGBA(red, green, blue: UINT; alpha: UINT = 255): SC_COLOR;
  end;

implementation

uses
  SciterGraphicApiImpl, SciterApiImpl, TiscriptApiImpl;

{ TSciterDIB32 }

procedure TSciterDIB32.ClearToWhite;
begin
  FillMemory(FBits, FWidth*FHeight*4, $FF);
end;

constructor TSciterDIB32.Create(const AWidth, AHeight: Cardinal);
begin
  FWidth := AWidth;
  FHeight := AHeight;
  FBits := nil;
  FOldBitmap := 0;
  FDC := 0;

  ZeroMemory(@FBitmapInfo, SizeOf(FBitmapInfo));
  FBitmapInfo.bmiHeader.biSize := SizeOf(FBitmapInfo.bmiHeader);
  FBitmapInfo.bmiHeader.biWidth := FWidth;
  FBitmapInfo.bmiHeader.biHeight := 0 - Integer(FHeight);
  FBitmapInfo.bmiHeader.biPlanes := 1;
  FBitmapInfo.bmiHeader.biBitCount := 32;
  FBitmapInfo.bmiHeader.biCompression := BI_RGB;
  FBitmap := CreateDIBSection(
    0,                // device context
    FBitmapInfo,
    DIB_RGB_COLORS,
    FBits,
    0,                // file mapping object
    0                 // file offset
  );
  Assert(FBits<>nil, SysErrorMessage(GetLastError));
  ZeroMemory(FBits, FWidth*FHeight*4);
end;

destructor TSciterDIB32.Destroy;
begin
  if FDC <> 0 then
  begin
    SelectObject(FDC, FOldBitmap);
    DeleteDC(FDC);
    FDC := 0;
  end;
  if FBitmap <> 0 then
  begin
    DeleteObject(FBitmap);
    FBitmap := 0;
    FBits := nil;
  end;
  inherited;
end;

function TSciterDIB32.Detach: HBITMAP;
begin
  Result := FBitmap;
  FBitmap := 0;
end;

function TSciterDIB32.GetBitmapInfo: PBitmapInfo;
begin
  Result := @FBitmapInfo;
end;

function TSciterDIB32.GetBits: Pointer;
begin
  Result := FBits;
end;

function TSciterDIB32.GetBitsSize: Cardinal;
begin
  Result := FWidth*FHeight*4;
end;

function TSciterDIB32.GetBytes: PByte;
begin
  Result := FBits;
end;

function TSciterDIB32.GetDC: HDC;
begin
  if FDC = 0 then
  begin
    FDC := CreateCompatibleDC(0);
    if FDC <> 0 then
      FOldBitmap := SelectObject(FDC, FBitmap);
  end;
  Result := FDC;
end;

function TSciterDIB32.GetHeight: Cardinal;
begin
  Result := FHeight;
end;

function TSciterDIB32.GetWidth: Cardinal;
begin
  Result := FWidth;
end;

{ TSciterImage }

function TSciterImage.Clear(byColor: SC_COLOR): ISciterImage;
begin
  GAPI.imageClear(FHandle, byColor);
  Result := Self;
end;

constructor TSciterImage.Create(img: HIMG);
begin
  FHandle := img;
end;

constructor TSciterImage.Create(width, height: UINT; withAlpha: LongBool);
begin
  GAPI.imageCreate(FHandle, width, height, withAlpha);
end;

constructor TSciterImage.Create(const bytes: PByte; num_bytes: UINT);
begin
  GAPI.imageLoad(bytes, num_bytes, FHandle);
end;

constructor TSciterImage.CreateFromPixmap(pixmapWidth, pixmapHeight: UINT;
  withAlpha: LongBool; const pixmapPixels: PByte);
begin
  GAPI.imageCreateFromPixmap(FHandle, pixmapWidth, pixmapHeight, withAlpha, pixmapPixels);
end;

function TSciterImage.CreateGraphic: ISciterGraphic;
begin
  Result := TSciterGraphic.CreateFromImage(FHandle);
end;


function TSciterImage.Draw(hgfx: HGFX; x, y: SC_POS; w,
  h: SC_DIM; ix, iy, iw, ih: PUINT; opacity: PSingle): ISciterImage;
var
  pw, ph: PSC_DIM;
begin
  if w = 0 then
    pw := nil
  else
    pw := @w;
  if h = 0 then
    ph := nil
  else
    ph := @h;
  GAPI.gDrawImage(hgfx, FHandle, x, y, pw, ph, ix, iy, iw, ih, opacity);
  Result := Self;
end;

function TSciterImage.GetHandle: HIMG;
begin
  Result := FHandle;
end;

function TSciterImage.GetValue: tiscript_value;
var
  v: SCITER_VALUE;
begin
  Result := 0;
  if GAPI.vWrapImage(FHandle, @v) <> GRAPHIN_OK then Exit;
  SAPI.Sciter_S2T(ni.get_current_vm, @v, Result)
end;

function TSciterImage.GetHeight: UINT;
var
  width, height: UINT;
  usesAlpha: BOOL;
begin
  GetInfo(width, height, usesAlpha);
  Result := height;
end;

function TSciterImage.GetInfo(var width, height: UINT;
  var usesAlpha: BOOL): GRAPHIN_RESULT;
begin
  Result := GAPI.imageGetInfo(FHandle, width, height, usesAlpha);
end;

function TSciterImage.GetUsesAlpha: BOOL;
var
  width, height: UINT;
  usesAlpha: BOOL;
begin
  GetInfo(width, height, usesAlpha);
  Result := usesAlpha;
end;

function TSciterImage.GetWidth: UINT;
var
  width, height: UINT;
  usesAlpha: BOOL;
begin
  GetInfo(width, height, usesAlpha);
  Result := width;
end;

function TSciterImage.Save(pfn: image_write_function; var prm: Pointer;
  encoding: TSciterImageEncoding; quality: UINT): ISciterImage;
begin
  GAPI.imageSave(FHandle, pfn, prm, encoding, quality);
  Result := Self;
end;

type
  PSciterImageSaveToFileInfo = ^TSciterImageSaveToFileInfo;
  TSciterImageSaveToFileInfo = record
    filename: SciterString;
  end;
  
function _SciterImageSaveToFile(prm: LPVOID; const data: PByte; data_length: UINT): LongBool; stdcall;
const
  fmOpenReadWrite = $0002;
var
  fs: TFileStream;
  LInfo: PSciterImageSaveToFileInfo;
begin
  LInfo := PSciterImageSaveToFileInfo(prm);
  fs := TFileStream.Create(LInfo.filename, fmCreate or fmOpenReadWrite);
  try
    fs.Write(data, data_length);
  finally
    fs.Free;
  end;
  Result := True;
end;

function TSciterImage.Paint(pPainter: image_paint_function;
  prm: Pointer): ISciterImage;
begin
  GAPI.imagePaint(FHandle, pPainter, prm);
  Result := Self;
end;

function TSciterImage.Save(const filename: SciterString; encoding: TSciterImageEncoding;
  quality: UINT): ISciterImage;
var
  LInfo: TSciterImageSaveToFileInfo;
begin
  LInfo.filename := filename;
  GAPI.imageSave(FHandle, _SciterImageSaveToFile, @LInfo, encoding, quality);
  Result := Self;
end;

function TSciterImage._AddRef: Integer;
begin
  if FHandle <> nil then
    GAPI.imageAddRef(FHandle);    
  Result := inherited _AddRef;
end;

function TSciterImage._Release: Integer;
begin
  if FHandle <> nil then
    GAPI.imageRelease(FHandle);
  Result := inherited _Release;
end;

constructor TSciterImage.CreateImageFromValue(value: PSCITER_VALUE);
begin
  GAPI.vUnWrapImage(value, FHandle)
end;

{ TSciterGraphic }

function TSciterGraphic.Arc(x, y, rx, ry: SC_POS; start,
  sweep: SC_ANGLE): ISciterGraphic;
begin
  GAPI.gArc(FHandle, x, y, rx, ry, start, sweep);
  Result := Self;
end;

constructor TSciterGraphic.CreateFromImage(img: HIMG);
begin
  GAPI.gCreate(img, FHandle);
end;

function TSciterGraphic.BlendImage(himg: HIMG; x, y: SC_POS;
  opacity: Single; ix, iy, iw, ih: UINT): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, nil, nil, @ix, @iy, @iw, @ih, @opacity);
  Result := Self;
end;

function TSciterGraphic.BlendImage(himg: HIMG; x, y: SC_POS;
  opacity: Single): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, nil, nil, nil, nil, nil, nil, @opacity);
  Result := Self;
end;

function TSciterGraphic.BlendImage(himg: HIMG; x, y: SC_POS; w,
  h: SC_DIM; opacity: Single; ix, iy, iw, ih: UINT): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, @w, @h, @ix, @iy, @iw, @ih, @opacity);
  Result := Self;
end;

function TSciterGraphic.BlendImage(himg: HIMG; x, y: SC_POS; w,
  h: SC_DIM; opacity: Single): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, nil, nil, nil, nil, nil, nil, @opacity);
  Result := Self;
end;

constructor TSciterGraphic.Create(hgfx: HGFX);
begin
  FHandle := hgfx;
end;

function TSciterGraphic.DrawPath(path: HPATH;
  dpm: DRAW_PATH_MODE): ISciterGraphic;
begin
  GAPI.gDrawPath(FHandle, path, dpm);
  Result := Self;
end;

function TSciterGraphic.DrawText(text: HTEXT; px, py: SC_POS;
  position: UINT): ISciterGraphic;
begin
  GAPI.gDrawText(FHandle, text, px, py, position);
  Result := Self;
end;

function TSciterGraphic.Ellipse(x, y: SC_POS; rx,
  ry: SC_DIM): ISciterGraphic;
begin
  GAPI.gEllipse(FHandle, x, y, rx, ry);
  Result := Self;
end;

function TSciterGraphic.FillColor(color: SC_COLOR): ISciterGraphic;
begin
  GAPI.gFillColor(FHandle, color);
  Result := Self;
end;

function TSciterGraphic.FillLinearGradient(x1, y1, x2, y2: SC_POS; c1,
  c2: SC_COLOR): ISciterGraphic;
var
  stops: array[0..1] of SC_COLOR_STOP;
begin
  stops[0].color := c1;
  stops[0].offset := 0.0;
  stops[1].color := c2;
  stops[1].offset := 1.0;
  Result := FillLinearGradient(x1, y1, x2, y2, @stops, 2);
end;

function TSciterGraphic.FillLinearGradient(x1, y1, x2, y2: SC_POS;
  stops: PColorStop; nstops: UINT): ISciterGraphic;
begin
  GAPI.gFillGradientLinear(FHandle, x1, y1, x2, y2, stops, nstops);
  Result := Self;
end;

function TSciterGraphic.FillRadialGradient(x, y: SC_POS; rx,
  ry: SC_DIM; stops: PColorStop; nstops: UINT): ISciterGraphic;
begin
  GAPI.gFillGradientRadial(FHandle, x, y, rx, ry, stops, nstops);
  Result := Self;
end;

function TSciterGraphic.FillMode(even_odd: LongBool): ISciterGraphic;
begin
  GAPI.gFillMode(FHandle, even_odd);
  Result := Self;
end;

function TSciterGraphic.FillRadialGradient(x, y: SC_POS; rx,
  ry: SC_DIM; c1, c2: SC_COLOR): ISciterGraphic;
var
  stops: array[0..1] of SC_COLOR_STOP;
begin
  stops[0].color := c1;
  stops[0].offset := 0.0;
  stops[1].color := c2;
  stops[1].offset := 1.0;
  Result := FillRadialGradient(x, y, rx, ry, @stops, 2);
end;

function TSciterGraphic.GetHandle: HGFX;
begin
  Result := FHandle;
end;

function TSciterGraphic.GetValue: tiscript_value;
var
  v: SCITER_VALUE;
begin
  Result := 0;
  if GAPI.vWrapGfx(FHandle, @v) <> GRAPHIN_OK then Exit;
  SAPI.Sciter_S2T(ni.get_current_vm, @v, Result)
end;

function TSciterGraphic.Line(x1, y1, x2, y2: SC_POS): ISciterGraphic;
begin
  GAPI.gLine(FHandle, x1, y1, x2, y2);
  Result := Self;
end;

function TSciterGraphic.LineCap(
  type_: SCITER_LINE_CAP_TYPE): ISciterGraphic;
begin
  GAPI.gLineCap(FHandle, type_);
  Result := Self;
end;

function TSciterGraphic.LineColor(c: SC_COLOR): ISciterGraphic;
begin
  GAPI.gLineColor(FHandle, c);
  Result := Self;
end;

function TSciterGraphic.LineLinearGradient(x1, y1, x2, y2: SC_POS;
  stops: PColorStop; nstops: UINT): ISciterGraphic;
begin
  GAPI.gLineGradientLinear(FHandle, x1, y1, x2, y2, stops, nstops);
  Result := Self;
end;

function TSciterGraphic.LineRadialGradient(x, y: SC_POS; rx,
  ry: SC_DIM; stops: PColorStop; nstops: UINT): ISciterGraphic;
begin
  GAPI.gLineGradientRadial(FHandle, x, y, rx, ry, stops, nstops);
  Result := Self;
end;

function TSciterGraphic.LineJoin(
  type_: SCITER_LINE_JOIN_TYPE): ISciterGraphic;
begin
  GAPI.gLineJoin(FHandle, type_);
  Result := Self;
end;

function TSciterGraphic.LineLinearGradient(x1, y1, x2, y2: SC_POS; c1,
  c2: SC_COLOR): ISciterGraphic;
var
  stops: array[0..1] of SC_COLOR_STOP;
begin
  stops[0].color := c1;
  stops[0].offset := 0.0;
  stops[1].color := c2;
  stops[1].offset := 1.0;
  Result := LineLinearGradient(x1, y1, x2, y2, @stops, 2);
end;

function TSciterGraphic.LineRadialGradient(x, y: SC_POS; rx,
  ry: SC_DIM; c1, c2: SC_COLOR): ISciterGraphic;
var
  stops: array[0..1] of SC_COLOR_STOP;
begin
  stops[0].color := c1;
  stops[0].offset := 0.0;
  stops[1].color := c2;
  stops[1].offset := 1.0;
  Result := LineRadialGradient(x, y, rx, ry, @stops, 2);
end;

function TSciterGraphic.LineWidth(width: SC_DIM): ISciterGraphic;
begin
  GAPI.gLineWidth(FHandle, width);
  Result := Self;
end;

function TSciterGraphic.NoFill: ISciterGraphic;
begin
  GAPI.gFillColor(FHandle, 0);
  Result := Self;
end;

function TSciterGraphic.NoLine: ISciterGraphic;
begin
  GAPI.gLineWidth(FHandle, 0);
  Result := Self;
end;

function TSciterGraphic.Polygon(const xy: PSC_POS;
  num_points: UINT): ISciterGraphic;
begin
  GAPI.gPolygon(FHandle, xy, num_points);
  Result := Self;
end;

function TSciterGraphic.Polyline(const xy: PSC_POS;
  num_points: UINT): ISciterGraphic;
begin
  GAPI.gPolyline(FHandle, xy, num_points);
  Result := Self;
end;

function TSciterGraphic.PopClip: ISciterGraphic;
begin
  GAPI.gPopClip(FHandle);
  Result := Self;
end;

function TSciterGraphic.PushClipBox(x1, y1, x2, y2: SC_POS;
  opacity: Single): ISciterGraphic;
begin
  GAPI.gPushClipBox(FHandle, x1, y1, x2, y2, opacity);
  Result := Self;
end;

function TSciterGraphic.PushClipPath(path: HPATH;
  opacity: Single): ISciterGraphic;
begin
  GAPI.gPushClipPath(FHandle, path, opacity);
  Result := Self;
end;

function TSciterGraphic.Rectangle(x1, y1, x2,
  y2: SC_POS): ISciterGraphic;
begin
  GAPI.gRectangle(FHandle, x1, y1, x2, y2);
  Result := Self;
end;

function TSciterGraphic.Rotate(radians: SC_ANGLE; cx,
  cy: PSC_POS): ISciterGraphic;
begin
  GAPI.gRotate(FHandle, radians, cx, cy);
  Result := Self;
end;

function TSciterGraphic.RoundedRectangle(x1, y1, x2, y2: SC_POS;
  const radii8: PSC_DIM_ARRAY8): ISciterGraphic;
begin
  GAPI.gRoundedRectangle(FHandle, x1, y1, x2, y2, radii8);
  Result := Self;
end;

function TSciterGraphic.Scale(x, y: SC_DIM): ISciterGraphic;
begin
  GAPI.gScale(FHandle, x, y);
  Result := Self;
end;

function TSciterGraphic.ScreenToWorld(var inout_x,
  inout_y: SC_POS): ISciterGraphic;
begin
  GAPI.gScreenToWorld(FHandle, @inout_x, @inout_y);
  Result := Self;
end;

function TSciterGraphic.ScreenToWorld(
  var inout_length: SC_DIM): ISciterGraphic;
begin
  GAPI.gScreenToWorld(FHandle, @inout_length, nil);
  Result := Self;
end;

function TSciterGraphic.ScreenToWorldX(var x: SC_POS): SC_POS;
var
  y: SC_POS;
begin
  GAPI.gScreenToWorld(FHandle, @x, @y);
  Result := x;
end;

function TSciterGraphic.ScreenToWorldY(var y: SC_POS): SC_POS;
var
  x: SC_POS;
begin
  GAPI.gScreenToWorld(FHandle, @x, @y);
  Result := y;
end;

function TSciterGraphic.Skew(dx, dy: SC_DIM): ISciterGraphic;
begin
  GAPI.gSkew(FHandle, dx, dy);
  Result := Self;
end;

function TSciterGraphic.Star(x, y: SC_POS; r1, r2: SC_DIM;
  start: SC_ANGLE; rays: UINT): ISciterGraphic;
begin
  GAPI.gStar(FHandle, x, y, r1, r2, start, rays);
  Result := Self;
end;

function TSciterGraphic.Restore: ISciterGraphic;
begin
  GAPI.gStateRestore(FHandle);
  Result := Self;
end;

function TSciterGraphic.Save: ISciterGraphic;
begin
  GAPI.gStateSave(FHandle);
  Result := Self;
end;

function TSciterGraphic.Transform(m11, m12, m21, m22, dx,
  dy: SC_POS): ISciterGraphic;
begin
  GAPI.gTransform(FHandle, m11, m12, m21, m22, dx, dy);
  Result := Self;
end;

function TSciterGraphic.Translate(cx, cy: SC_POS): ISciterGraphic;
begin
  GAPI.gTranslate(FHandle, cx, cy);
  Result := Self;
end;

function TSciterGraphic.WorldToScreen(var inout_x,
  inout_y: SC_POS): ISciterGraphic;
begin
  GAPI.gWorldToScreen(FHandle, @inout_x, @inout_y);
  Result := Self;
end;

function TSciterGraphic.WorldToScreen(
  var inout_length: SC_DIM): ISciterGraphic;
begin
  GAPI.gWorldToScreen(FHandle, @inout_length, nil);
  Result := Self;
end;

function TSciterGraphic.WorldToScreenX(x: SC_POS): SC_POS;
var
  y: SC_POS; 
begin
  y := 0;
  GAPI.gWorldToScreen(FHandle, @x, @y);
  Result := x;
end;

function TSciterGraphic.WorldToScreenY(y: SC_POS): SC_POS;
var
  x: SC_POS;
begin
  x := 0;
  GAPI.gWorldToScreen(FHandle, @x, @y);
  Result := y;
end;

function TSciterGraphic._AddRef: Integer;
begin
  if FHandle <> nil then
    GAPI.gAddRef(FHandle);
  Result := inherited _AddRef;
end;

function TSciterGraphic._Release: Integer;
begin
  if FHandle <> nil then
    GAPI.gRelease(FHandle);
  Result := inherited _Release;
end;

function TSciterGraphic.DrawImage(himg: HIMG; x, y: SC_POS; w, h: SC_DIM;
  ix, iy, iw, ih: UINT): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, @w, @h, @ix, @iy, @iw, @ih, nil);
  Result := Self;
end;

function TSciterGraphic.DrawImage(himg: HIMG; x,
  y: SC_POS): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, nil, nil, nil, nil, nil, nil, nil);
  Result := Self;
end;

function TSciterGraphic.DrawImage(himg: HIMG; x, y: SC_POS; w,
  h: SC_DIM): ISciterGraphic;
begin
  GAPI.gDrawImage(FHandle, himg, x, y, @w, @h, nil, nil, nil, nil, nil);
  Result := Self;
end;

constructor TSciterGraphic.CreateGraphicFromValue(value: PSCITER_VALUE);
begin
  GAPI.vUnWrapGfx(value, FHandle)
end;

{ TSciterGraphicPath }

function TSciterGraphicPath.ArcTo(x, y: SC_POS; angle: SC_ANGLE;
  rx, ry: SC_DIM; is_large_arc, clockwise,
  relative: LongBool): ISciterGraphicPath;
begin
  GAPI.pathArcTo(FHandle, x, y, angle, rx, ry, is_large_arc, clockwise, relative);
  Result := Self;
end;

function TSciterGraphicPath.BezierCurveTo(xc1, yc1, xc2, yc2, x,
  y: SC_POS; relative: LongBool): ISciterGraphicPath;
begin
  GAPI.pathBezierCurveTo(FHandle, xc1, yc1, xc2, yc2, x, y, relative);
  Result := Self;
end;

function TSciterGraphicPath.ClosePath: ISciterGraphicPath;
begin
  GAPI.pathClosePath(FHandle);
  Result := Self;
end;

constructor TSciterGraphicPath.Create(path: HPATH);
begin
  FHandle := path;
end;

constructor TSciterGraphicPath.Create;
var
  path: HPATH;
begin
  GAPI.pathCreate(path);
  Create(path);
end;

constructor TSciterGraphicPath.CreatePathFromValue(value: PSCITER_VALUE);
begin
  GAPI.vUnWrapPath(value, FHandle)
end;

function TSciterGraphicPath.DrawPath(hgfx: HGFX;
  dpm: DRAW_PATH_MODE): ISciterGraphicPath;
begin
  GAPI.gDrawPath(hgfx, FHandle, dpm);
  Result := Self;
end;

function TSciterGraphicPath.GetHandle: HPATH;
begin
  Result := FHandle;
end;

function TSciterGraphicPath.GetValue: tiscript_value;
var
  v: SCITER_VALUE;
begin
  Result := 0;
  if GAPI.vWrapPath(FHandle, @v) <> GRAPHIN_OK then Exit;
  SAPI.Sciter_S2T(ni.get_current_vm, @v, Result)
end;

function TSciterGraphicPath.LineTo(x, y: SC_POS;
  relative: LongBool): ISciterGraphicPath;
begin
  GAPI.pathLineTo(FHandle, x, y, relative);
  Result := Self;
end;

function TSciterGraphicPath.MoveTo(x, y: SC_POS;
  relative: LongBool): ISciterGraphicPath;
begin
  GAPI.pathMoveTo(FHandle, x, y, relative);
  Result := Self;
end;

function TSciterGraphicPath.QuadraticCurveTo(xc, yc, x, y: SC_POS;
  relative: LongBool): ISciterGraphicPath;
begin
  GAPI.pathQuadraticCurveTo(FHandle, xc, yc, x, y, relative);
  Result := Self;
end;

function TSciterGraphicPath._AddRef: Integer;
begin
  if FHandle <> nil then
    GAPI.pathAddRef(FHandle);
  Result := inherited _AddRef;
end;

function TSciterGraphicPath._Release: Integer;
begin
  if FHandle <> nil then
    GAPI.pathRelease(FHandle);
  Result := inherited _Release;
end;

{ TSciterGraphicText }

constructor TSciterGraphicText.Create(text: HTEXT);
begin
  FHandle := text;
end;

constructor TSciterGraphicText.Create(text: LPCWSTR; textLength: UINT;
  const format: TSciterTextFormat);
var
  LHandle: HTEXT;
begin
  GAPI.textCreate(LHandle, text, textLength, @format);
  Create(LHandle);
end;

constructor TSciterGraphicText.CreateForElement(text: LPCWSTR;
  textLength: UINT; he: HELEMENT);
var
  LHandle: HTEXT;
begin
  GAPI.textCreateForElement(LHandle, text, textLength, he);
  Create(LHandle);
end;

constructor TSciterGraphicText.CreateTextFromValue(value: PSCITER_VALUE);
begin
  GAPI.vUnWrapText(value, FHandle)
end;

function TSciterGraphicText.DrawText(hgfx: HGFX; px, py: SC_POS;
  position: UINT): ISciterGraphicText;
begin
  GAPI.gDrawText(hgfx, FHandle, px, py, position);
  Result := Self;
end;

function TSciterGraphicText.GetAscent: SC_DIM;
begin
  GAPI.textGetMetrics(FHandle, nil, nil, nil, @Result, nil, nil);
end;

function TSciterGraphicText.GetDescent: SC_DIM;
begin
  GAPI.textGetMetrics(FHandle, nil, nil, nil, nil, @Result, nil);
end;

function TSciterGraphicText.GetHandle: HTEXT;
begin
  Result := FHandle;
end;

function TSciterGraphicText.GetHeight: SC_DIM;
begin
  GAPI.textGetMetrics(FHandle, nil, nil, @Result, nil, nil, nil);
end;

function TSciterGraphicText.GetLines: UINT;
begin
  GAPI.textGetMetrics(FHandle, nil, nil, nil, nil, nil, @Result);
end;

function TSciterGraphicText.GetMaxWidth: SC_DIM;
begin
  GAPI.textGetMetrics(FHandle, nil, @Result, nil, nil, nil, nil);
end;

function TSciterGraphicText.GetMetrics(var minWidth, maxWidth, height, ascent,
  descent: SC_DIM; var nLines: UINT): ISciterGraphicText;
begin
  GAPI.textGetMetrics(FHandle, @minWidth, @maxWidth, @height, @ascent, @descent, @nLines);
  Result := Self;
end;

function TSciterGraphicText.GetMinWidth: SC_DIM;
begin
  GAPI.textGetMetrics(FHandle, @Result, nil, nil, nil, nil, nil);
end;

function TSciterGraphicText.GetValue: tiscript_value;
var
  v: SCITER_VALUE;
begin
  Result := 0;
  if GAPI.vWrapText(FHandle, @v) <> GRAPHIN_OK then Exit;
  SAPI.Sciter_S2T(ni.get_current_vm, @v, Result)
end;

function TSciterGraphicText.SetBox(width, height: SC_DIM): ISciterGraphicText;
begin
  GAPI.textSetBox(FHandle, width, height);
  Result := Self;
end;

{ TSciterGraphicFactory }

function TSciterGraphicFactory.CreateGraphic(hgfx: HGFX): ISciterGraphic;
begin
  Result := TSciterGraphic.Create(hgfx);
end;

function TSciterGraphicFactory.CreateGraphicFromImage(img: HIMG): ISciterGraphic;
begin
  Result := TSciterGraphic.CreateFromImage(img);
end;

function TSciterGraphicFactory.CreateGraphicFromValue(const value: tiscript_value): ISciterGraphic;
var
  v: SCITER_VALUE;
begin
  if SAPI.Sciter_T2S(ni.get_current_vm, value, @v, False) then
    Result := TSciterGraphic.CreateGraphicFromValue(@v)
  else
    Result := nil;
end;

function TSciterGraphicFactory.CreateImage(width, height: UINT;
  withAlpha: LongBool): ISciterImage;
begin
  Result := TSciterImage.Create(width, height, withAlpha);
end;

function TSciterGraphicFactory.CreateImage(himg: HIMG): ISciterImage;
begin
  Result := TSciterImage.Create(himg);
end;

function TSciterGraphicFactory.CreateImageFromPixmap(pixmapWidth,
  pixmapHeight: UINT; withAlpha: LongBool; const pixmapPixels: PByte): ISciterImage;
begin
  Result := TSciterImage.CreateFromPixmap(pixmapWidth, pixmapHeight, withAlpha, pixmapPixels);
end;

function TSciterGraphicFactory.CreateImageFromValue(const value: tiscript_value): ISciterImage;
var
  v: SCITER_VALUE;
begin
  if SAPI.Sciter_T2S(ni.get_current_vm, value, @v, False) then
    Result := TSciterImage.CreateImageFromValue(@v)
  else
    Result := nil;
end;

function TSciterGraphicFactory.CreatePath: ISciterGraphicPath;
begin
  Result := TSciterGraphicPath.Create;
end;

function TSciterGraphicFactory.CreatePath(path: HPATH): ISciterGraphicPath;
begin
  Result := TSciterGraphicPath.Create(path);
end;

function TSciterGraphicFactory.CreatePathFromValue(const value: tiscript_value): ISciterGraphicPath;
var
  v: SCITER_VALUE;
begin
  if SAPI.Sciter_T2S(ni.get_current_vm, value, @v, False) then
    Result := TSciterGraphicPath.CreatePathFromValue(@v)
  else
    Result := nil;
end;

function TSciterGraphicFactory.CreateText(const text: SciterString;
  const format: TSciterTextFormat): ISciterGraphicText;
begin
  Result := TSciterGraphicText.Create(PWideChar(text), Length(text), format);
end;

function TSciterGraphicFactory.CreateTextFromValue(const value: tiscript_value): ISciterGraphicText;
var
  v: SCITER_VALUE;
begin
  if SAPI.Sciter_T2S(ni.get_current_vm, value, @v, False) then
    Result := TSciterGraphicText.CreateTextFromValue(@v)
  else
    Result := nil;
end;

function TSciterGraphicFactory.CreateText(text: LPCWSTR; textLength: UINT;
  const format: TSciterTextFormat): ISciterGraphicText;
begin
  Result := TSciterGraphicText.Create(text, textLength, format);
end;

function TSciterGraphicFactory.CreateTextForElement(text: LPCWSTR;
  textLength: UINT; he: HELEMENT): ISciterGraphicText;
begin
  Result := TSciterGraphicText.CreateForElement(text, textLength, he);
end;

function TSciterGraphicFactory.CreateText(
  const handle: HTEXT): ISciterGraphicText;
begin
  Result := TSciterGraphicText.Create(handle);
end;

function TSciterGraphicFactory.CreateTextForElement(const text: SciterString;
  he: HELEMENT): ISciterGraphicText;
begin
  Result := TSciterGraphicText.CreateForElement(PWideChar(text), Length(text), he);
end;

function TSciterGraphicFactory.LoadImage(const bytes: PByte;
  num_bytes: UINT): ISciterImage;
begin
  Result := TSciterImage.Create(bytes, num_bytes);
end;

function TSciterGraphicFactory.LoadImage(
  const filename: SciterString): ISciterImage;
var
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    ms.LoadFromFile(filename);
    Result := TSciterImage.Create(ms.Memory, ms.Size);
  finally
    ms.Free;
  end;   
end;

function TSciterGraphicFactory.RGBA(red, green, blue,
  alpha: UINT): SC_COLOR;
begin
  Result := GAPI.RGBA(red, green, blue, alpha);
end;

function TSciterGraphicFactory.CreateDIB32(const AWidth,
  AHeight: Cardinal): ISciterDIB32;
begin
  Result := TSciterDIB32.Create(AWidth, AHeight);
end;


end.

