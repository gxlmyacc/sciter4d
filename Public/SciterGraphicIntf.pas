{*******************************************************************************
 标题:     SciterGraphicIntf.pas
 描述:     sciter绘图接口
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterGraphicIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes, SciterGraphicTypes, Windows;

type
  ISciterGraphic = interface;

  ISciterDIB32 = interface
  ['{92317028-4025-40A8-8BE5-85D7CAA27F9E}']
    function GetHeight: Cardinal;
    function GetWidth: Cardinal;
    function GetBits: Pointer;
    function GetBitsSize: Cardinal;
    function GetBytes: PByte;
    function GetDC: HDC;
    function GetBitmapInfo: PBitmapInfo;

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
  
  ISciterImage = interface
  ['{40CCE0EB-BD9C-4AC7-9FAF-FBC253F5A43A}']
    function GetHandle: HIMG;
    function GetValue: tiscript_value;
    function GetWidth: UINT;
    function GetHeight: UINT;
    function GetUsesAlpha: BOOL;

    function GetInfo(var width, height: UINT; var usesAlpha: BOOL): GRAPHIN_RESULT;
    function Clear(byColor: SC_COLOR): ISciterImage;

    function Save(pfn: image_write_function; var prm: Pointer;
      encoding: TSciterImageEncoding = SCITER_IMAGE_ENCODING_PNG;
      quality: UINT = 0 (*JPEG qquality: 20..100, if 0 - PNG*)): ISciterImage; overload;
    function Save(const filename: SciterString; encoding:
      TSciterImageEncoding = SCITER_IMAGE_ENCODING_PNG;
      quality: UINT = 0 (*JPEG qquality: 20..100, if 0 - PNG*)): ISciterImage; overload;

    function CreateGraphic: ISciterGraphic;

    // draws img onto the graphics surface with current transformation applied (scale, rotation).
    function Draw(hgfx: HGFX; x, y: SC_POS;
      w: SC_DIM = 0; h: SC_DIM = 0; ix: PUINT = nil; iy: PUINT = nil; iw: PUINT = nil; ih: PUINT = nil;
      opacity: PSingle = nil): ISciterImage;
    function Paint(pPainter: image_paint_function; prm: Pointer = nil): ISciterImage;

    property Handle: HIMG read GetHandle;
    property Value: tiscript_value read GetValue;
    property Width: UINT read GetWidth;
    property Height: UINT read GetHeight;
    property UsesAlpha: BOOL read GetUsesAlpha;
  end;

  ISciterGraphic = interface
  ['{182CB868-B0B2-4BB8-AD34-AC6A654D7709}']
    function GetHandle: HGFX;
    function GetValue: tiscript_value;

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
    function FillMode(even_odd: LongBool = False(* false - fill_non_zero *)): ISciterGraphic;
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

    // draws img onto the graphics surface with current transformation applied (scale, rotation).expensive
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

  ISciterGraphicPath = interface
  ['{D01D14A8-62B6-45C5-B01B-D9006743C08C}']
    function GetHandle: HPATH;
    function GetValue: tiscript_value;
     
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

  ISciterGraphicText = interface
  ['{51019EE5-ECED-4F22-9E10-341399D1D17F}']
    function GetHandle: HTEXT;
    function GetValue: tiscript_value;
    function GetMinWidth: SC_DIM;
    function GetMaxWidth: SC_DIM;
    function GetHeight: SC_DIM;
    function GetAscent: SC_DIM;
    function GetDescent: SC_DIM;
    function GetLines: UINT;
    
    function GetMetrics(var minWidth, maxWidth, height, ascent, descent: SC_DIM; var nLines: UINT): ISciterGraphicText;
    function SetBox(width, height: SC_DIM): ISciterGraphicText;

    // draw text with position (1..9 on MUMPAD) at px,py
    // Ex: gDrawText( 100,100,5) will draw text box with its center at 100,100 px
    function DrawText(hgfx: HGFX; px, py: SC_POS; position: UINT): ISciterGraphicText;

    property Handle: HTEXT read GetHandle;
    property Value: tiscript_value read GetValue;
    property MinWidth: SC_DIM read GetMinWidth;
    property MaxWidth: SC_DIM read GetMaxWidth;
    property Height: SC_DIM read GetHeight;
    property Ascent: SC_DIM read GetAscent;
    property Descent: SC_DIM read GetDescent;
    property Lines: UINT read GetLines;
  end;

  PISciterGraphicFactory = ^ISciterGraphicFactory;
  ISciterGraphicFactory = interface
  ['{4746E69D-164A-4A55-874B-8BA3B83A2131}']
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

function RGBA(red, green, blue: UINT; alpha: UINT = 255): SC_COLOR;

function CreateDIB32(const AWidth, AHeight: Cardinal): ISciterDIB32;
function LoadImage(const filename: SciterString): ISciterImage; overload;
function LoadImage(const bytes: PByte; num_bytes: UINT): ISciterImage; overload;
function CreateImage(himg: HIMG): ISciterImage; overload;
function CreateImage(width, height: UINT; withAlpha: LongBool): ISciterImage; overload;
function CreateImageFromPixmap(pixmapWidth, pixmapHeight: UINT; withAlpha: LongBool; const pixmapPixels: PByte): ISciterImage;
function CreateImageFromValue(const value: tiscript_value): ISciterImage;
function CreateGraphicFromImage(img: HIMG): ISciterGraphic;
function CreateGraphic(hgfx: HGFX): ISciterGraphic;
function CreateGraphicFromValue(const value: tiscript_value): ISciterGraphic;
function CreatePath: ISciterGraphicPath; overload;
function CreatePath(path: HPATH): ISciterGraphicPath; overload;
function CreatePathFromValue(const value: tiscript_value): ISciterGraphicPath;
function CreateTextForElement(text: LPCWSTR; textLength: UINT; he: HELEMENT): ISciterGraphicText; overload;
function CreateTextForElement(const text: SciterString; he: HELEMENT): ISciterGraphicText; overload;
function CreateText(const handle: HTEXT): ISciterGraphicText; overload;
function CreateText(text: LPCWSTR; textLength: UINT; const format: TSciterTextFormat): ISciterGraphicText; overload;
function CreateText(const text: SciterString; const format: TSciterTextFormat): ISciterGraphicText; overload;
function CreateTextFromValue(const value: tiscript_value): ISciterGraphicText;

implementation

uses
  SciterImportDefs;

function __SciterGraphicFactory: PISciterGraphicFactory;
type
  TSciterGraphicFactory = function (): PISciterGraphicFactory;
begin
  Result := TSciterGraphicFactory(SciterApi.Funcs[FuncIdx_SciterGraphicFactory]);
end;

function RGBA(red, green, blue: UINT; alpha: UINT): SC_COLOR;
begin
  Result := __SciterGraphicFactory.RGBA(red, green, blue, alpha);
end;

function CreateDIB32(const AWidth, AHeight: Cardinal): ISciterDIB32;
begin
  Result := __SciterGraphicFactory.CreateDIB32(AWidth, AHeight);
end;

function LoadImage(const filename: SciterString): ISciterImage;
begin
  Result := __SciterGraphicFactory.LoadImage(filename);
end;

function LoadImage(const bytes: PByte; num_bytes: UINT): ISciterImage;
begin
  Result := __SciterGraphicFactory.LoadImage(bytes, num_bytes);
end;

function CreateImage(himg: HIMG): ISciterImage;
begin
  Result := __SciterGraphicFactory.CreateImage(himg);
end;

function CreateImage(width, height: UINT; withAlpha: LongBool): ISciterImage;
begin
  Result := __SciterGraphicFactory.CreateImage(width, height, withAlpha);
end;

function CreateImageFromPixmap(pixmapWidth, pixmapHeight: UINT; withAlpha: LongBool; const pixmapPixels: PByte): ISciterImage;
begin
  Result := __SciterGraphicFactory.CreateImageFromPixmap(pixmapWidth, pixmapHeight, withAlpha, pixmapPixels);
end;

function CreateImageFromValue(const value: tiscript_value): ISciterImage;
begin
  Result := __SciterGraphicFactory.CreateImageFromValue(value)
end;

function CreateGraphicFromImage(img: HIMG): ISciterGraphic;
begin
  Result := __SciterGraphicFactory.CreateGraphicFromImage(img);
end;

function CreateGraphic(hgfx: HGFX): ISciterGraphic;
begin
  Result := __SciterGraphicFactory.CreateGraphic(hgfx);
end;

function CreateGraphicFromValue(const value: tiscript_value): ISciterGraphic;
begin
  Result := __SciterGraphicFactory.CreateGraphicFromValue(value);
end;

function CreatePath: ISciterGraphicPath;
begin
  Result := __SciterGraphicFactory.CreatePath;
end;

function CreatePath(path: HPATH): ISciterGraphicPath; 
begin
  Result := __SciterGraphicFactory.CreatePath(path);
end;

function CreatePathFromValue(const value: tiscript_value): ISciterGraphicPath;
begin
  Result := __SciterGraphicFactory.CreatePathFromValue(value);
end;

function CreateTextForElement(text: LPCWSTR; textLength: UINT; he: HELEMENT): ISciterGraphicText;
begin
  Result := __SciterGraphicFactory.CreateTextForElement(text, textLength, he);
end;

function CreateTextForElement(const text: SciterString; he: HELEMENT): ISciterGraphicText;
begin
  Result := __SciterGraphicFactory.CreateTextForElement(text, he);
end;

function CreateText(const handle: HTEXT): ISciterGraphicText; 
begin
  Result := __SciterGraphicFactory.CreateText(handle);
end;

function CreateText(text: LPCWSTR; textLength: UINT; const format: TSciterTextFormat): ISciterGraphicText;
begin
  Result := __SciterGraphicFactory.CreateText(text, textLength, format);
end;

function CreateText(const text: SciterString; const format: TSciterTextFormat): ISciterGraphicText;
begin
  Result := __SciterGraphicFactory.CreateText(text, format);
end;

function CreateTextFromValue(const value: tiscript_value): ISciterGraphicText;
begin
  Result := __SciterGraphicFactory.CreateTextFromValue(value);
end;

end.
