{*******************************************************************************
 标题:     SciterGraphicApiImpl.pas
 描述:     Sciter导出的GraphicApi接口定义
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterGraphicApiImpl;

interface

uses
  SciterTypes, Windows, SciterGraphicTypes;
  
{$I Sciter.inc}

type
  // image primitives
  TSciterGraphicsAPI = record
    imageCreate: function(out poutImg: HIMG; width, height: UINT; withAlpha: LongBool): GRAPHIN_RESULT; stdcall;
    // construct image from B[n+0],G[n+1],R[n+2],A[n+3] data.
    // Size of pixmap data is pixmapWidth*pixmapHeight*4
    imageCreateFromPixmap: function(out poutImg: HIMG; pixmapWidth, pixmapHeight: UINT; withAlpha: LongBool; const pixmap: PByte): GRAPHIN_RESULT; stdcall;
    imageAddRef: function(himg: HIMG): GRAPHIN_RESULT; stdcall;
    imageRelease: function(himg: HIMG): GRAPHIN_RESULT; stdcall;
    imageGetInfo: function(himg: HIMG; var width, height: UINT; var usesAlpha: LongBool): GRAPHIN_RESULT; stdcall;
    //imageGetPixels: function: (himg: HIMG; var dataReceiver: image_write_function): GRAPHIN_RESULT; stdcall;
    imageClear: function(himg: HIMG; byColor: SC_COLOR): GRAPHIN_RESULT; stdcall;
    // load png/jpeg/etc. image from stream of bytes
    imageLoad: function(const bytes: PByte; num_bytes: UINT; out pout_img: HIMG): GRAPHIN_RESULT; stdcall;
    // save png/jpeg/etc. image to stream of bytes
    imageSave: function(himg: HIMG;
        pfn: image_write_function;
        prm: Pointer;     (* function and its param passed "as is" *)
        encoding: TSciterImageEncoding; // SCITER_IMAGE_ENCODING
        quality: UINT     (* if webp or jpeg: 10 - 100 *)
      ): GRAPHIN_RESULT; stdcall;

    // SECTION: graphics primitives and drawing operations

    // create COLOR value
    RGBA: function(red, green, blue: UINT; alpha: UINT (*= 255*)): SC_COLOR; stdcall;
    gCreate: function(img: HIMG; var pout_gfx: HGFX): GRAPHIN_RESULT; stdcall;
    gAddRef: function(gfx: HGFX): GRAPHIN_RESULT; stdcall;
    gRelease: function(gfx: HGFX): GRAPHIN_RESULT; stdcall;
    // Draws line from x1,y1 to x2,y2 using current lineColor and lineGradient.
    gLine: function(gfx: HGFX; x1, y1, x2, y2: SC_POS): GRAPHIN_RESULT; stdcall;
    // Draws rectangle using current lineColor/lineGradient and fillColor/fillGradient with (optional) rounded corners.
    gRectangle: function(gfx: HGFX; x1, y1, x2, y2: SC_POS): GRAPHIN_RESULT; stdcall;
    // Draws rounded rectangle using current lineColor/lineGradient and fillColor/fillGradient with (optional) rounded corners.
    gRoundedRectangle: function(gfx: HGFX; x1, y1, x2, y2: SC_POS; const radii8: PSC_DIM_ARRAY8(* DIM[8] - four rx/ry pairs *)): GRAPHIN_RESULT; stdcall;
    // Draws circle or ellipse using current lineColor/lineGradient and fillColor/fillGradient.
    gEllipse: function(gfx: HGFX; x, y: SC_POS;  rx, ry: SC_DIM): GRAPHIN_RESULT; stdcall;
    // Draws closed arc using current lineColor/lineGradient and fillColor/fillGradient.
    gArc: function(gfx: HGFX; x, y, rx, ry: SC_POS;  start, sweep: SC_ANGLE): GRAPHIN_RESULT; stdcall;
    // Draws star.
    gStar: function(gfx: HGFX; x, y: SC_POS;  r1, r2: SC_DIM; start: SC_ANGLE; rays: UINT): GRAPHIN_RESULT; stdcall;
    // Closed polygon.
    gPolygon: function(gfx: HGFX; const xy: PSC_POS;  num_points: UINT): GRAPHIN_RESULT; stdcall;
    // Polyline.
    gPolyline: function(gfx: HGFX; const xy: PSC_POS;  num_points: UINT): GRAPHIN_RESULT; stdcall;

    // SECTION: Path operations
    pathCreate: function(out path: HPATH): GRAPHIN_RESULT; stdcall;
    pathAddRef: function(path: HPATH): GRAPHIN_RESULT; stdcall;
    pathRelease: function(path: HPATH): GRAPHIN_RESULT; stdcall;
    pathMoveTo: function(path: HPATH; x, y: SC_POS; relative: LongBool): GRAPHIN_RESULT; stdcall;
    pathLineTo: function(path: HPATH; x, y: SC_POS; relative: LongBool): GRAPHIN_RESULT; stdcall;
    pathArcTo: function(path: HPATH; x, y: SC_POS; angle: SC_ANGLE;
      rx, ry: SC_DIM; is_large_arc, clockwise, relative: LongBool): GRAPHIN_RESULT; stdcall;
    pathQuadraticCurveTo: function(path: HPATH; xc, yc, x, y: SC_POS; relative: LongBool): GRAPHIN_RESULT; stdcall;
    pathBezierCurveTo: function(path: HPATH; xc1, yc1, xc2, yc2, x, y: SC_POS; relative: LongBool): GRAPHIN_RESULT; stdcall;
    pathClosePath: function(path: HPATH): GRAPHIN_RESULT; stdcall;

    gDrawPath: function(hgfx: HGFX; path: HPATH; dpm: DRAW_PATH_MODE): GRAPHIN_RESULT; stdcall;

    // end of path opearations

    // SECTION: affine tranformations:
    gRotate: function(hgfx: HGFX; radians: SC_ANGLE;
      cx: PSC_POS (*= 0*); cy: PSC_POS (*= 0*)): GRAPHIN_RESULT; stdcall;
    gTranslate: function(hgfx: HGFX; cx, cy: SC_POS): GRAPHIN_RESULT; stdcall;
    gScale: function(hgfx: HGFX; x, y: SC_DIM): GRAPHIN_RESULT; stdcall;
    gSkew: function(hgfx: HGFX; dx, dy: SC_DIM): GRAPHIN_RESULT; stdcall;
    // all above in one shot
    gTransform: function(hgfx: HGFX; m11, m12, m21, m22: SC_POS; dx, dy: SC_POS): GRAPHIN_RESULT; stdcall;

    // end of affine tranformations.

    // SECTION: state save/restore
    gStateSave: function(hgfx: HGFX): GRAPHIN_RESULT; stdcall;
    gStateRestore: function(hgfx: HGFX): GRAPHIN_RESULT; stdcall;
    // end of state save/restore

    // SECTION: drawing attributes
   
    // set line width for subsequent drawings.
    gLineWidth: function(hgfx: HGFX; width: SC_DIM): GRAPHIN_RESULT; stdcall;
    gLineJoin: function(hgfx: HGFX; type_: SCITER_LINE_JOIN_TYPE): GRAPHIN_RESULT; stdcall;
    gLineCap: function(hgfx: HGFX; type_: SCITER_LINE_CAP_TYPE): GRAPHIN_RESULT; stdcall;
    //gNoLine: function(hgfx: HGFX): GRAPHIN_RESULT; stdcall; { gLineWidth(hgfx,0.0); }

    // COLOR for solid lines/strokes
    gLineColor: function(hgfx: HGFX; c: SC_COLOR): GRAPHIN_RESULT; stdcall;
    // COLOR for solid fills
    gFillColor: function(hgfx: HGFX; color: SC_COLOR): GRAPHIN_RESULT; stdcall;

    // setup parameters of linear gradient of lines.
    gLineGradientLinear: function(hgfx: HGFX; x1, y1, x2, y2: SC_POS; stops: PColorStop; nstops: UINT): GRAPHIN_RESULT; stdcall;
    // setup parameters of linear gradient of fills.
    gFillGradientLinear: function(hgfx: HGFX; x1, y1, x2, y2: SC_POS; stops: PColorStop; nstops: UINT): GRAPHIN_RESULT; stdcall;
    // setup parameters of line gradient radial fills.
    gLineGradientRadial: function(hgfx: HGFX; x, y: SC_POS; rx, ry: SC_DIM; stops: PColorStop; nstops: UINT): GRAPHIN_RESULT; stdcall;
    // setup parameters of gradient radial fills.
    gFillGradientRadial: function(hgfx: HGFX; x, y: SC_POS; rx, ry: SC_DIM; stops: PColorStop; nstops: UINT): GRAPHIN_RESULT; stdcall;
    gFillMode: function(hgfx: HGFX; even_odd: LongBool (* false - fill_non_zero *)): GRAPHIN_RESULT; stdcall;

    // SECTION: text
    
    // create text layout using element's styles
    textCreateForElement: function(out ptext: HTEXT; text: LPCWSTR; textLength: UINT; he: HELEMENT): GRAPHIN_RESULT; stdcall;
    // create text layout using explicit format declaration
    textCreate: function(out ptext: HTEXT; text: LPCWSTR; textLength: UINT; const format: PSciterTextFormat): GRAPHIN_RESULT; stdcall;
    
    textGetMetrics: function(text: HTEXT; minWidth, maxWidth, height, ascent, descent: PSC_DIM; nLines: PUINT): GRAPHIN_RESULT; stdcall;
    textSetBox: function(text: HTEXT; width, height: SC_DIM): GRAPHIN_RESULT; stdcall;
                                   
    // draw text with position (1..9 on MUMPAD) at px,py
    // Ex: gDrawText( 100,100,5) will draw text box with its center at 100,100 px
    gDrawText: function(hgfx: HGFX; text: HTEXT; px, py: SC_POS; position: UINT): GRAPHIN_RESULT; stdcall;

    // SECTION: image rendering

    // draws img onto the graphics surface with current transformation applied (scale, rotation).
    gDrawImage: function(hgfx: HGFX; himg: HIMG; x, y: SC_POS;
      w: PSC_DIM (*= 0*); h: PSC_DIM (*= 0*); ix: PUINT (*= 0*); iy: PUINT (*= 0*); iw: PUINT (*= 0*); ih: PUINT (*= 0*);
      opacity: PSingle (*= 0, if provided is in 0.0 .. 1.0*) ): GRAPHIN_RESULT; stdcall;

    // SECTION: coordinate space
    gWorldToScreen: function(hgfx: HGFX; inout_x, inout_y: PSC_POS): GRAPHIN_RESULT; stdcall;
    gScreenToWorld: function(hgfx: HGFX; inout_x, inout_y: PSC_POS): GRAPHIN_RESULT; stdcall;

    // SECTION: clipping
    gPushClipBox: function(hgfx: HGFX; x1, y1, x2, y2: SC_POS; opacity: Single (*=1.f*)): GRAPHIN_RESULT; stdcall;
    gPushClipPath: function(hgfx: HGFX; hpath: HPATH; opacity: Single (*=1.f*)): GRAPHIN_RESULT; stdcall;
    // pop clip layer previously set by gPushClipBox or gPushClipPath
    gPopClip: function(hgfx: HGFX): GRAPHIN_RESULT; stdcall;

    // image painter. paint on image using graphics
    imagePaint: function(himg: HIMG; pPainter: image_paint_function; prm: Pointer): GRAPHIN_RESULT; stdcall;

    // VALUE interface
    vWrapGfx: function(hgfx: HGFX; toValue: PSCITER_VALUE): GRAPHIN_RESULT; stdcall;
    vWrapImage: function(himg: HIMG; toValue: PSCITER_VALUE): GRAPHIN_RESULT; stdcall;
    vWrapPath: function(hpath: HPATH; toValue: PSCITER_VALUE): GRAPHIN_RESULT; stdcall;
    vWrapText: function(htext: HTEXT; toValue: PSCITER_VALUE): GRAPHIN_RESULT; stdcall;
    vUnWrapGfx: function(const fromValue: PSCITER_VALUE; var phgfx: HGFX): GRAPHIN_RESULT; stdcall;
    vUnWrapImage: function(const fromValue: PSCITER_VALUE; var phimg: HIMG): GRAPHIN_RESULT; stdcall;
    vUnWrapPath: function(const fromValue: PSCITER_VALUE; var phpath: HPATH): GRAPHIN_RESULT; stdcall;
    vUnWrapText: function(const fromValue: PSCITER_VALUE; var phtext: HTEXT): GRAPHIN_RESULT; stdcall;
  end;
  PSciterGraphicsAPI = ^TSciterGraphicsAPI;

function GAPI(api: PSciterGraphicsAPI = nil): PSciterGraphicsAPI;

implementation

var
  _SGAPI: PSciterGraphicsAPI = nil;

function GAPI(api: PSciterGraphicsAPI): PSciterGraphicsAPI;
begin
  if api <> nil then
    _SGAPI := api;
  Result := _SGAPI;
end;

end.
