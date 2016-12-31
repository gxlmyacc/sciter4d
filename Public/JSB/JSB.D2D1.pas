unit JSB.D2D1;

///////////////////////////////////////////////////////////////////////////////
// Title: Translation of DirectX C++ header files for use with Delphi 2009 and later
//
// File name: JSB.D2D1.pas
//
// Originator: J S Bladen, Sheffield, UK.
//
// Copyright: J S Bladen, Sheffield, UK.
//
// Translation date and time (UTC): 07/10/2010 15:08:55
//
// Email: DirectXForDelphi@jsbmedical.co.uk
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Original file(s):
//   D2DBaseTypes.h
//   D2D1.h
//   D2Derr.h
//   D2D1Helper.h
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
{$define UNICODE}

uses
  Windows, SysUtils, JSB.DXTypes, JSB.DXGI, JSB.DirectWrite, JSB.D3D10_1;

const
  DLL_D2D1='d2d1.dll';

///////////////////////////////////////////////////////////////////////////////
// Begin "D2DBaseTypes.h"
///////////////////////////////////////////////////////////////////////////////

type
  PColor = ^TColor;
  TColor = -$7FFFFFFF-1..$7FFFFFFF;

  TD2D_Point2U = record
    X: LongWord;
    Y: LongWord;
  end;
  PTD2D_Point2U = ^TD2D_Point2U;
  D2D_POINT_2U  = TD2D_Point2U;
  PD2D_POINT_2U = ^TD2D_Point2U;

  TD2D_Point2F = record
    X: Single;
    Y: Single;
  end;
  PTD2D_Point2F = ^TD2D_Point2F;
  D2D_POINT_2F  = TD2D_Point2F;
  PD2D_POINT_2F = ^TD2D_Point2F;

  TD2D_RectF = record
    Left:   Single;
    Top:    Single;
    Right:  Single;
    Bottom: Single;
  end;
  PTD2D_RectF = ^TD2D_RectF;
  D2D_RECT_F  = TD2D_RectF;
  PD2D_RECT_F = ^TD2D_RectF;

  TD2D_RectU = record
    Left:   LongWord;
    Top:    LongWord;
    Right:  LongWord;
    Bottom: LongWord;
  end;
  PTD2D_RectU = ^TD2D_RectU;
  D2D_RECT_U  = TD2D_RectU;
  PD2D_RECT_U = ^TD2D_RectU;

  TD2D_SizeF = record
    Width:  Single;
    Height: Single;
  end;
  PTD2D_SizeF = ^TD2D_SizeF;
  D2D_SIZE_F  = TD2D_SizeF;
  PD2D_SIZE_F = ^TD2D_SizeF;

  TD2D_SizeU = record
    Width:  LongWord;
    Height: LongWord;
  end;
  PTD2D_SizeU = ^TD2D_SizeU;
  D2D_SIZE_U  = TD2D_SizeU;
  PD2D_SIZE_U = ^TD2D_SizeU;

  TD2D_ColorF  = D3DCOLORVALUE;
  PTD2D_ColorF = ^TD2D_ColorF;
  D2D_COLOR_F  = TD2D_ColorF;
  PD2D_COLOR_F = ^TD2D_ColorF;

  TD2D_Matrix3X2F = record
    _11: Single;
    _12: Single;
    _21: Single;
    _22: Single;
    _31: Single;
    _32: Single;
  end;
  PTD2D_Matrix3X2F = ^TD2D_Matrix3X2F;
  D2D_MATRIX_3X2_F = TD2D_Matrix3X2F;
  PD2D_MATRIX_3X2_F = ^TD2D_Matrix3X2F;

///////////////////////////////////////////////////////////////////////////////
// End "D2DBaseTypes.h"
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Begin "D2D1.h"
///////////////////////////////////////////////////////////////////////////////

const
  D2D1_INVALID_TAG = ULONGLONG_MAX;
  D2D1_DEFAULT_FLATTENING_TOLERANCE = (0.25);

type
  ID2D1Factory  = interface;
  PID2D1Factory = ^ID2D1Factory;

  ID2D1RenderTarget  = interface;
  PID2D1RenderTarget = ^ID2D1RenderTarget;

  ID2D1BitmapRenderTarget  = interface;
  PID2D1BitmapRenderTarget = ^ID2D1BitmapRenderTarget;

  ID2D1SimplifiedGeometrySink  = interface;
  PID2D1SimplifiedGeometrySink = ^ID2D1SimplifiedGeometrySink;

  ID2D1TessellationSink  = interface;
  PID2D1TessellationSink = ^ID2D1TessellationSink;

  ID2D1Geometry  = interface;
  PID2D1Geometry = ^ID2D1Geometry;

  ID2D1Brush  = interface;
  PID2D1Brush = ^ID2D1Brush;

  TD2D1_AlphaMode = (
    D2D1_ALPHA_MODE_UNKNOWN       = 0,
    D2D1_ALPHA_MODE_PREMULTIPLIED = 1,
    D2D1_ALPHA_MODE_STRAIGHT      = 2,
    D2D1_ALPHA_MODE_IGNORE        = 3
  );
  PTD2D1_AlphaMode = ^TD2D1_AlphaMode;
  D2D1_ALPHA_MODE  = TD2D1_AlphaMode;
  PD2D1_ALPHA_MODE = ^TD2D1_AlphaMode;

  TD2D1_Gamma = (
    D2D1_GAMMA_2_2 = 0,
    D2D1_GAMMA_1_0 = 1
  );
  PTD2D1_Gamma = ^TD2D1_Gamma;
  D2D1_GAMMA   = TD2D1_Gamma;
  PD2D1_GAMMA  = ^TD2D1_Gamma;

  TD2D1_OpacityMaskContent =
  (
    D2D1_OPACITY_MASK_CONTENT_GRAPHICS            = 0,
    D2D1_OPACITY_MASK_CONTENT_TEXT_NATURAL        = 1,
    D2D1_OPACITY_MASK_CONTENT_TEXT_GDI_COMPATIBLE = 2
  );
  PTD2D1_OpacityMaskContent  = ^TD2D1_OpacityMaskContent;
  D2D1_OPACITY_MASK_CONTENT  = TD2D1_OpacityMaskContent;
  PD2D1_OPACITY_MASK_CONTENT = ^TD2D1_OpacityMaskContent;

  TD2D1_ExtendMode = (
    D2D1_EXTEND_MODE_CLAMP  = 0,
    D2D1_EXTEND_MODE_WRAP   = 1,
    D2D1_EXTEND_MODE_MIRROR = 2
  );
  PTD2D1_ExtendMode = ^TD2D1_ExtendMode;
  D2D1_EXTEND_MODE  = TD2D1_ExtendMode;
  PD2D1_EXTEND_MODE = ^TD2D1_ExtendMode;

  TD2D1_AntialiasMode = (
    D2D1_ANTIALIAS_MODE_PER_PRIMITIVE = 0,
    D2D1_ANTIALIAS_MODE_ALIASED       = 1
  );
  PTD2D1_AntialiasMode = ^TD2D1_AntialiasMode;
  D2D1_ANTIALIAS_MODE  = TD2D1_AntialiasMode;
  PD2D1_ANTIALIAS_MODE = ^TD2D1_AntialiasMode;

  TD2D1_TextAntialiasMode = (
    D2D1_TEXT_ANTIALIAS_MODE_DEFAULT   = 0,
    D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE = 1,
    D2D1_TEXT_ANTIALIAS_MODE_GRAYSCALE = 2,
    D2D1_TEXT_ANTIALIAS_MODE_ALIASED   = 3
  );
  PTD2D1_TextAntialiasMode  = ^TD2D1_TextAntialiasMode;
  D2D1_TEXT_ANTIALIAS_MODE  = TD2D1_TextAntialiasMode;
  PD2D1_TEXT_ANTIALIAS_MODE = ^TD2D1_TextAntialiasMode;

  TD2D1_BitmapInterpolationMode = (
    D2D1_BITMAP_INTERPOLATION_MODE_NEAREST_NEIGHBOR  =0,
    D2D1_BITMAP_INTERPOLATION_MODE_LINEAR           = 1
  );
  PTD2D1_BitmapInterpolationMode  = ^TD2D1_BitmapInterpolationMode;
  D2D1_BITMAP_INTERPOLATION_MODE  = TD2D1_BitmapInterpolationMode;
  PD2D1_BITMAP_INTERPOLATION_MODE = ^TD2D1_BitmapInterpolationMode;

  TD2D1_DrawTextOptions =
  (
    D2D1_DRAW_TEXT_OPTIONS_NO_SNAP = $00000001,
    D2D1_DRAW_TEXT_OPTIONS_CLIP    = $00000002,
    D2D1_DRAW_TEXT_OPTIONS_NONE    = $00000000
  );
  PTD2D1_DrawTextOptions  = ^TD2D1_DrawTextOptions;
  D2D1_DRAW_TEXT_OPTIONS  = TD2D1_DrawTextOptions;
  PD2D1_DRAW_TEXT_OPTIONS = ^TD2D1_DrawTextOptions;

  TD2D1_PixelFormat = record
    Format: TDXGI_Format;
    AlphaMode: TD2D1_AlphaMode;
  end;
  PTD2D1_PixelFormat = ^TD2D1_PixelFormat;
  D2D1_PIXEL_FORMAT  = TD2D1_PixelFormat;
  PD2D1_PIXEL_FORMAT = ^TD2D1_PixelFormat;

  TD2D1_Point2U  = D2D_POINT_2U;
  PTD2D1_Point2U = ^TD2D1_Point2U;
  D2D1_POINT_2U  = TD2D1_Point2U;
  PD2D1_POINT_2U = ^TD2D1_Point2U;

  TD2D1_Point2F  = D2D_POINT_2F;
  PTD2D1_Point2F = ^TD2D1_Point2F;
  D2D1_POINT_2F  = TD2D1_Point2F;
  PD2D1_POINT_2F = ^TD2D1_Point2F;

  TD2D1_RectF  = D2D_RECT_F;
  PTD2D1_RectF = ^TD2D1_RectF;
  D2D1_RECT_F  = TD2D1_RectF;
  PD2D1_RECT_F = ^TD2D1_RectF;

  TD2D1_RectU  = D2D_RECT_U;
  PTD2D1_RectU = ^TD2D1_RectU;
  D2D1_RECT_U  = TD2D1_RectU;
  PD2D1_RECT_U = ^TD2D1_RectU;

  TD2D1_SizeF  = D2D_SIZE_F;
  PTD2D1_SizeF = ^TD2D1_SizeF;
  D2D1_SIZE_F  = TD2D1_SizeF;
  PD2D1_SIZE_F = ^TD2D1_SizeF;

  TD2D1_SizeU  = D2D_SIZE_U;
  PTD2D1_SizeU = ^TD2D1_SizeU;
  D2D1_SIZE_U  = TD2D1_SizeU;
  PD2D1_SIZE_U = ^TD2D1_SizeU;

  TD2D1_ColorF  = D2D_COLOR_F;
  PTD2D1_ColorF = ^TD2D1_ColorF;
  D2D1_COLOR_F  = TD2D1_ColorF;
  PD2D1_COLOR_F = ^TD2D1_ColorF;

  TD2D1_Matrix3X2F   = D2D_MATRIX_3X2_F;
  PTD2D1_Matrix3X2F  = ^TD2D1_Matrix3X2F;
  D2D1_MATRIX_3X2_F  = TD2D1_Matrix3X2F;
  PD2D1_MATRIX_3X2_F = ^TD2D1_Matrix3X2F;

  TD2D1_Tag  = UINT64;
  PTD2D1_Tag = ^TD2D1_Tag;
  D2D1_TAG   = TD2D1_Tag;
  PD2D1_TAG  = ^TD2D1_Tag;

  TD2D1_BitmapProperties = record
    PixelFormat: TD2D1_PixelFormat;
    DpiX: Single;
    DpiY: Single;
  end;
  PTD2D1_BitmapProperties = ^TD2D1_BitmapProperties;
  D2D1_BITMAP_PROPERTIES  = TD2D1_BitmapProperties;
  PD2D1_BITMAP_PROPERTIES = ^TD2D1_BitmapProperties;

  TD2D1_GradientStop = record
    Position: Single;
    Color: TD2D1_ColorF;
  end;
  PTD2D1_GradientStop = ^TD2D1_GradientStop;
  D2D1_GRADIENT_STOP  = TD2D1_GradientStop;
  PD2D1_GRADIENT_STOP = ^TD2D1_GradientStop;

  TD2D1_BrushProperties = record
    Opacity: Single;
    Transform: TD2D1_Matrix3X2F;
  end;
  PTD2D1_BrushProperties = ^TD2D1_BrushProperties;
  D2D1_BRUSH_PROPERTIES  = TD2D1_BrushProperties;
  PD2D1_BRUSH_PROPERTIES = ^TD2D1_BrushProperties;

  TD2D1_BitmapBrushProperties = record
    ExtendModeX: TD2D1_ExtendMode;
    ExtendModeY: TD2D1_ExtendMode;
    InterpolationMode: TD2D1_BitmapInterpolationMode;
  end;
  PTD2D1_BitmapBrushProperties  = ^TD2D1_BitmapBrushProperties;
  D2D1_BITMAP_BRUSH_PROPERTIES  = TD2D1_BitmapBrushProperties;
  PD2D1_BITMAP_BRUSH_PROPERTIES = ^TD2D1_BitmapBrushProperties;

  TD2D1_LinearGradientBrushProperties = record
    StartPoint: TD2D1_Point2F;
    EndPoint: TD2D1_Point2F;
  end;
  PTD2D1_LinearGradientBrushProperties   = ^TD2D1_LinearGradientBrushProperties;
  D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES  = TD2D1_LinearGradientBrushProperties;
  PD2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES = ^TD2D1_LinearGradientBrushProperties;

  TD2D1_RadialGradientBrushProperties = record
    Center: TD2D1_Point2F;
    GradientOriginOffset: TD2D1_Point2F;
    RadiusX: Single;
    RadiusY: Single;
  end;
  PTD2D1_RadialGradientBrushProperties   = ^TD2D1_RadialGradientBrushProperties;
  D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES  = TD2D1_RadialGradientBrushProperties;
  PD2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES = ^TD2D1_RadialGradientBrushProperties;

  TD2D1_ArcSize = (
    D2D1_ARC_SIZE_SMALL = 0,
    D2D1_ARC_SIZE_LARGE = 1
  );
  PTD2D1_ArcSize = ^TD2D1_ArcSize;
  D2D1_ARC_SIZE  = TD2D1_ArcSize;
  PD2D1_ARC_SIZE = ^TD2D1_ArcSize;

  TD2D1_CapStyle = (
    D2D1_CAP_STYLE_FLAT     = 0,
    D2D1_CAP_STYLE_SQUARE   = 1,
    D2D1_CAP_STYLE_ROUND    = 2,
    D2D1_CAP_STYLE_TRIANGLE = 3
  );
  PTD2D1_CapStyle = ^TD2D1_CapStyle;
  D2D1_CAP_STYLE  = TD2D1_CapStyle;
  PD2D1_CAP_STYLE = ^TD2D1_CapStyle;

  TD2D1_DashStyle = (
    D2D1_DASH_STYLE_SOLID        = 0,
    D2D1_DASH_STYLE_DASH         = 1,
    D2D1_DASH_STYLE_DOT          = 2,
    D2D1_DASH_STYLE_DASH_DOT     = 3,
    D2D1_DASH_STYLE_DASH_DOT_DOT = 4,
    D2D1_DASH_STYLE_CUSTOM       = 5
  );
  PTD2D1_DashStyle = ^TD2D1_DashStyle;
  D2D1_DASH_STYLE  = TD2D1_DashStyle;
  PD2D1_DASH_STYLE = ^TD2D1_DashStyle;

  TD2D1_LineJoin = (
    D2D1_LINE_JOIN_MITER          = 0,
    D2D1_LINE_JOIN_BEVEL          = 1,
    D2D1_LINE_JOIN_ROUND          = 2,
    D2D1_LINE_JOIN_MITER_OR_BEVEL = 3
  );
  PTD2D1_LineJoin = ^TD2D1_LineJoin;
  D2D1_LINE_JOIN  = TD2D1_LineJoin;
  PD2D1_LINE_JOIN = ^TD2D1_LineJoin;

  TD2D1_CombineMode = (
    D2D1_COMBINE_MODE_UNION     = 0,
    D2D1_COMBINE_MODE_INTERSECT = 1,
    D2D1_COMBINE_MODE_XOR       = 2,
    D2D1_COMBINE_MODE_EXCLUDE   = 3
  );
  PTD2D1_CombineMode = ^TD2D1_CombineMode;
  D2D1_COMBINE_MODE  = TD2D1_CombineMode;
  PD2D1_COMBINE_MODE = ^TD2D1_CombineMode;

  TD2D1_GeometryRelation = (
    D2D1_GEOMETRY_RELATION_UNKNOWN      = 0,
    D2D1_GEOMETRY_RELATION_DISJOINT     = 1,
    D2D1_GEOMETRY_RELATION_IS_CONTAINED = 2,
    D2D1_GEOMETRY_RELATION_CONTAINS     = 3,
    D2D1_GEOMETRY_RELATION_OVERLAP      = 4
  );
  PTD2D1_GeometryRelation = ^TD2D1_GeometryRelation;
  D2D1_GEOMETRY_RELATION  = TD2D1_GeometryRelation;
  PD2D1_GEOMETRY_RELATION = ^TD2D1_GeometryRelation;

  TD2D1_GeometrySimplificationOption = (
    D2D1_GEOMETRY_SIMPLIFICATION_OPTION_CUBICS_AND_LINES = 0,
    D2D1_GEOMETRY_SIMPLIFICATION_OPTION_LINES            = 1
  );
  PTD2D1_GeometrySimplificationOption  = ^TD2D1_GeometrySimplificationOption;
  D2D1_GEOMETRY_SIMPLIFICATION_OPTION  = TD2D1_GeometrySimplificationOption;
  PD2D1_GEOMETRY_SIMPLIFICATION_OPTION = ^TD2D1_GeometrySimplificationOption;

  TD2D1_FigureBegin = (
    D2D1_FIGURE_BEGIN_FILLED = 0,
    D2D1_FIGURE_BEGIN_HOLLOW = 1
  );
  PTD2D1_FigureBegin = ^TD2D1_FigureBegin;
  D2D1_FIGURE_BEGIN  = TD2D1_FigureBegin;
  PD2D1_FIGURE_BEGIN = ^TD2D1_FigureBegin;

  TD2D1_FigureEnd = (
    D2D1_FIGURE_END_OPEN   = 0,
    D2D1_FIGURE_END_CLOSED = 1
  );
  PTD2D1_FigureEnd = ^TD2D1_FigureEnd;
  D2D1_FIGURE_END  = TD2D1_FigureEnd;
  PD2D1_FIGURE_END = ^TD2D1_FigureEnd;

  TD2D1_BezierSegment = record
    Point1: TD2D1_Point2F;
    Point2: TD2D1_Point2F;
    Point3: TD2D1_Point2F;
  end;
  PTD2D1_BezierSegment = ^TD2D1_BezierSegment;
  D2D1_BEZIER_SEGMENT  = TD2D1_BezierSegment;
  PD2D1_BEZIER_SEGMENT = ^TD2D1_BezierSegment;

  TD2D1_Triangle = record
    Point1: TD2D1_Point2F;
    Point2: TD2D1_Point2F;
    Point3: TD2D1_Point2F;
  end;
  PTD2D1_Triangle = ^TD2D1_Triangle;
  D2D1_TRIANGLE   = TD2D1_Triangle;
  PD2D1_TRIANGLE  = ^TD2D1_Triangle;

  TD2D1_PathSegment = (
    D2D1_PATH_SEGMENT_NONE                  = $00000000,
    D2D1_PATH_SEGMENT_FORCE_UNSTROKED       = $00000001,
    D2D1_PATH_SEGMENT_FORCE_ROUND_LINE_JOIN = $00000002
  );
  PTD2D1_PathSegment = ^TD2D1_PathSegment;
  D2D1_PATH_SEGMENT  = TD2D1_PathSegment;
  PD2D1_PATH_SEGMENT = ^TD2D1_PathSegment;

  TD2D1_SweepDirection = (
    D2D1_SWEEP_DIRECTION_COUNTER_CLOCKWISE = 0,
    D2D1_SWEEP_DIRECTION_CLOCKWISE         = 1
  );
  PTD2D1_SweepDirection = ^TD2D1_SweepDirection;
  D2D1_SWEEP_DIRECTION  = TD2D1_SweepDirection;
  PD2D1_SWEEP_DIRECTION = ^TD2D1_SweepDirection;

  TD2D1_FillMode = (
    D2D1_FILL_MODE_ALTERNATE = 0,
    D2D1_FILL_MODE_WINDING   = 1
  );
  PTD2D1_FillMode = ^TD2D1_FillMode;
  D2D1_FILL_MODE  = TD2D1_FillMode;
  PD2D1_FILL_MODE = ^TD2D1_FillMode;

  TD2D1_ArcSegment = record
    Point: TD2D1_Point2F;
    Size: TD2D1_SizeF;
    RotationAngle: Single;
    SweepDirection: TD2D1_SweepDirection;
    ArcSize: TD2D1_ArcSize;
  end;
  PTD2D1_ArcSegment = ^TD2D1_ArcSegment;
  D2D1_ARC_SEGMENT  = TD2D1_ArcSegment;
  PD2D1_ARC_SEGMENT = ^TD2D1_ArcSegment;

  TD2D1_QuadraticBezierSegment = record
    Point1: TD2D1_Point2F;
    Point2: TD2D1_Point2F;
  end;
  PTD2D1_QuadraticBezierSegment  = ^TD2D1_QuadraticBezierSegment;
  D2D1_QUADRATIC_BEZIER_SEGMENT  = TD2D1_QuadraticBezierSegment;
  PD2D1_QUADRATIC_BEZIER_SEGMENT = ^TD2D1_QuadraticBezierSegment;

  TD2D1_Ellipse = record
    Point:   TD2D1_Point2F;
    RadiusX: Single;
    RadiusY: Single;
  end;
  PTD2D1_Ellipse = ^TD2D1_Ellipse;
  D2D1_ELLIPSE   = TD2D1_Ellipse;
  PD2D1_ELLIPSE  = ^TD2D1_Ellipse;

  TD2D1_RoundedRect = record
    Rect:    TD2D1_RectF;
    RadiusX: Single;
    RadiusY: Single;
  end;
  PTD2D1_RoundedRect = ^TD2D1_RoundedRect;
  D2D1_ROUNDED_RECT  = TD2D1_RoundedRect;
  PD2D1_ROUNDED_RECT = ^TD2D1_RoundedRect;

  TD2D1_StrokeStyleProperties = record
    StartCap:    TD2D1_CapStyle;
    EndCap:     TD2D1_CapStyle;
    DashCap:    TD2D1_CapStyle;
    LineJoin:   TD2D1_LineJoin;
    MiterLimit: Single;
    DashStyle:  TD2D1_DashStyle;
    DashOffset: Single;
  end;
  PTD2D1_StrokeStyleProperties  = ^TD2D1_StrokeStyleProperties;
  D2D1_STROKE_STYLE_PROPERTIES  = TD2D1_StrokeStyleProperties;
  PD2D1_STROKE_STYLE_PROPERTIES = ^TD2D1_StrokeStyleProperties;

  TD2D1_LayerOptions = (
    D2D1_LAYER_OPTIONS_NONE                     = $00000000,
    D2D1_LAYER_OPTIONS_INITIALIZE_FOR_CLEARTYPE = $00000001
  );
  PTD2D1_LayerOptions = ^TD2D1_LayerOptions;
  D2D1_LAYER_OPTIONS  = TD2D1_LayerOptions;
  PD2D1_LAYER_OPTIONS = ^TD2D1_LayerOptions;

  TD2D1_LayerParameters = record
    ContentBounds:     TD2D1_RectF;
    GeometricMask:     ID2D1Geometry; (* __field_ecount_opt(1) *)
    MaskAntialiasMode: TD2D1_AntialiasMode;
    MaskTransform:     TD2D1_Matrix3X2F;
    Opacity:           Single;
    OpacityBrush:      ID2D1Brush; (* __field_ecount_opt(1) *)
    LayerOptions:      TD2D1_LayerOptions;
  end;
  PTD2D1_LayerParameters = ^TD2D1_LayerParameters;
  D2D1_LAYER_PARAMETERS  = TD2D1_LayerParameters;
  PD2D1_LAYER_PARAMETERS = ^TD2D1_LayerParameters;

  TD2D1_WindowState= (
    D2D1_WINDOW_STATE_NONE     = $0000000,
    D2D1_WINDOW_STATE_OCCLUDED = $0000001
  );
  PTD2D1_WindowState = ^TD2D1_WindowState;
  D2D1_WINDOW_STATE  = TD2D1_WindowState;
  PD2D1_WINDOW_STATE = ^TD2D1_WindowState;

  TD2D1_RenderTargetType = (
    D2D1_RENDER_TARGET_TYPE_DEFAULT  = 0,
    D2D1_RENDER_TARGET_TYPE_SOFTWARE = 1,
    D2D1_RENDER_TARGET_TYPE_HARDWARE = 2
  );
  PTD2D1_RenderTargetType  = ^TD2D1_RenderTargetType;
  D2D1_RENDER_TARGET_TYPE  = TD2D1_RenderTargetType;
  PD2D1_RENDER_TARGET_TYPE = ^TD2D1_RenderTargetType;

  TD2D1_FeatureLevel = (
    D2D1_FEATURE_LEVEL_DEFAULT = 0,
    D2D1_FEATURE_LEVEL_9       = Integer(D3D10_FEATURE_LEVEL_9_1),
    D2D1_FEATURE_LEVEL_10      = Integer(D3D10_FEATURE_LEVEL_10_0)
  );
  PTD2D1_FeatureLevel = ^TD2D1_FeatureLevel;
  D2D1_FEATURE_LEVEL  = TD2D1_FeatureLevel;
  PD2D1_FEATURE_LEVEL = ^TD2D1_FeatureLevel;

  TD2D1_RenderTargetUsage = (
    D2D1_RENDER_TARGET_USAGE_NONE                  = $00000000,
    D2D1_RENDER_TARGET_USAGE_FORCE_BITMAP_REMOTING = $00000001,
    D2D1_RENDER_TARGET_USAGE_GDI_COMPATIBLE        = $00000002
  );
  PTD2D1_RenderTargetUsage  = ^TD2D1_RenderTargetUsage;
  D2D1_RENDER_TARGET_USAGE  = TD2D1_RenderTargetUsage;
  PD2D1_RENDER_TARGET_USAGE = ^TD2D1_RenderTargetUsage;

  TD2D1_PresentOptions = (
    D2D1_PRESENT_OPTIONS_NONE            = $00000000,
    D2D1_PRESENT_OPTIONS_RETAIN_CONTENTS = $00000001,
    D2D1_PRESENT_OPTIONS_IMMEDIATELY     = $00000002
  );
  PTD2D1_PresentOptions = ^TD2D1_PresentOptions;
  D2D1_PRESENT_OPTIONS  = TD2D1_PresentOptions;
  PD2D1_PRESENT_OPTIONS = ^TD2D1_PresentOptions;

  TD2D1_RenderTargetProperties = record
    _Type:       TD2D1_RenderTargetType;
    PixelFormat: TD2D1_PixelFormat;
    DpiX:        Single;
    DpiY:        Single;
    Usage:       TD2D1_RenderTargetUsage;
    MinLevel:    TD2D1_FeatureLevel;
  end;
  PTD2D1_RenderTargetProperties  = ^TD2D1_RenderTargetProperties;
  D2D1_RENDER_TARGET_PROPERTIES  = TD2D1_RenderTargetProperties;
  PD2D1_RENDER_TARGET_PROPERTIES = ^TD2D1_RenderTargetProperties;

  TD2D1_HwndRenderTargetProperties = record
    hWnd:           HWND;
    PixelSize:      TD2D1_SizeU;
    PresentOptions: TD2D1_PresentOptions;
  end;
  PTD2D1_HwndRenderTargetProperties   = ^TD2D1_HwndRenderTargetProperties;
  D2D1_HWND_RENDER_TARGET_PROPERTIES  = TD2D1_HwndRenderTargetProperties;
  PD2D1_HWND_RENDER_TARGET_PROPERTIES = ^TD2D1_HwndRenderTargetProperties;

  TD2D1_CompatibleRenderTargetOptions = (
    D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_NONE           = $00000000,
    D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS_GDI_COMPATIBLE = $00000001
  );
  PTD2D1_CompatibleRenderTargetOptions   = ^TD2D1_CompatibleRenderTargetOptions;
  D2D1_COMPATIBLE_RENDER_TARGET_OPTIONS  = TD2D1_CompatibleRenderTargetOptions;
  PD2D1_COMPATIBLE_RENDER_TARGET_OPTIONS = ^TD2D1_CompatibleRenderTargetOptions;

  TD2D1_DrawingStateDescription = record
    AntialiasMode:     TD2D1_AntialiasMode;
    TextAntialiasMode: TD2D1_TextAntialiasMode;
    Tag1:              TD2D1_Tag;
    Tag2:              TD2D1_Tag;
    Transform:         TD2D1_Matrix3X2F;
  end;
  PTD2D1_DrawingStateDescription  = ^TD2D1_DrawingStateDescription;
  D2D1_DRAWING_STATE_DESCRIPTION  = TD2D1_DrawingStateDescription;
  PD2D1_DRAWING_STATE_DESCRIPTION = ^TD2D1_DrawingStateDescription;

  TD2D1_DcInitializeMode= (
    D2D1_DC_INITIALIZE_MODE_COPY  = 0,
    D2D1_DC_INITIALIZE_MODE_CLEAR = 1
  );
  PTD2D1_DcInitializeMode  = ^TD2D1_DcInitializeMode;
  D2D1_DC_INITIALIZE_MODE  = TD2D1_DcInitializeMode;
  PD2D1_DC_INITIALIZE_MODE = ^TD2D1_DcInitializeMode;

  TD2D1_DebugLevel = (
    D2D1_DEBUG_LEVEL_NONE        = 0,
    D2D1_DEBUG_LEVEL_ERROR       = 1,
    D2D1_DEBUG_LEVEL_WARNING     = 2,
    D2D1_DEBUG_LEVEL_INFORMATION = 3
  );
  PTD2D1_DebugLevel = ^TD2D1_DebugLevel;
  D2D1_DEBUG_LEVEL  = TD2D1_DebugLevel;
  PD2D1_DEBUG_LEVEL = ^TD2D1_DebugLevel;

  TD2D1_FactoryType = (
    D2D1_FACTORY_TYPE_SINGLE_THREADED = 0,
    D2D1_FACTORY_TYPE_MULTI_THREADED  = 1
  );
  PTD2D1_FactoryType = ^TD2D1_FactoryType;
  D2D1_FACTORY_TYPE  = TD2D1_FactoryType;
  PD2D1_FACTORY_TYPE = ^TD2D1_FactoryType;

  TD2D1_FactoryOptions = record
    DebugLevel: TD2D1_DebugLevel;
  end;
  PTD2D1_FactoryOptions = ^TD2D1_FactoryOptions;
  D2D1_FACTORY_OPTIONS  = TD2D1_FactoryOptions;
  PD2D1_FACTORY_OPTIONS = ^TD2D1_FactoryOptions;

  ID2D1Resource = interface(IUnknown)
    ['{2CD90691-12E2-11DC-9FED-001143A055F9}']
    procedure GetFactory(out Factory:ID2D1Factory); stdcall;
  end;

  ID2D1Bitmap = interface(ID2D1Resource)
    ['{A2296057-EA42-4099-983B-539FB6505426}']
    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetSize(out o_Result:TD2D1_SizeF); stdcall;
    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetPixelSize(out o_Result:TD2D1_SizeU); stdcall;
    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetPixelFormat(out o_Result:TD2D1_PixelFormat); stdcall;
    procedure GetDpi(out DpiX, DpiY: Single); stdcall;
    function CopyFromBitmap(DestPoint: PTD2D1_Point2U; Bitmap: ID2D1Bitmap; SrcRect: PTD2D1_RectU): HResult; stdcall;
    function CopyFromRenderTarget(DestPoint: PTD2D1_Point2U; RenderTarget: ID2D1RenderTarget;
      SrcRect: PTD2D1_RectU): HResult; stdcall;
    function CopyFromMemory(DstRect: PTD2D1_RectU; SrcData: Pointer; Pitch: LongWord): HResult; stdcall;
  end;

  ID2D1GradientStopCollection = interface(ID2D1Resource)
    ['{2CD906A7-12E2-11DC-9FED-001143A055F9}']
    function GetGradientStopCount:LongWord; stdcall;
    procedure GetGradientStops(GradientStops: PTD2D1_GradientStop; GradientStopsCount: LongWord); stdcall;
    function GetColorInterpolationGamma:TD2D1_Gamma; stdcall;
    function GetExtendMode:TD2D1_ExtendMode; stdcall;
  end;

  ID2D1Brush = interface(ID2D1Resource)
    ['{2CD906A8-12E2-11DC-9FED-001143A055F9}']
    procedure SetOpacity(Opacity: Single); stdcall;
    procedure SetTransform(const Transform: TD2D1_Matrix3X2F); stdcall;
    function GetOpacity: Single; stdcall;
    procedure GetTransform(out Transform:TD2D1_Matrix3X2F); stdcall;
  end;

  ID2D1BitmapBrush = interface(ID2D1Brush)
    ['{2CD906AA-12E2-11DC-9FED-001143A055F9}']
    procedure SetExtendModeX(ExtendModeX: TD2D1_ExtendMode); stdcall;
    procedure SetExtendModeY(ExtendModeY: TD2D1_ExtendMode); stdcall;
    procedure SetInterpolationMode(InterpolationMode: TD2D1_BitmapInterpolationMode); stdcall;
    procedure SetBitmap(Bitmap: ID2D1Bitmap); stdcall;
    function GetExtendModeX: TD2D1_ExtendMode; stdcall;
    function GetExtendModeY: TD2D1_ExtendMode; stdcall;
    function GetInterpolationMode:TD2D1_BitmapInterpolationMode; stdcall;
    procedure GetBitmap(out Bitmap:ID2D1Bitmap); stdcall;
  end;

  ID2D1SolidColorBrush = interface(ID2D1Brush)
    ['{2CD906A9-12E2-11DC-9FED-001143A055F9}']
    procedure SetColor(const Color: TD2D1_ColorF); stdcall;
    function GetColor: TD2D1_ColorF; stdcall;
  end;

  ID2D1LinearGradientBrush = interface(ID2D1Brush)
    ['{2CD906AB-12E2-11DC-9FED-001143A055F9}']
    procedure SetStartPoint(StartPoint: TD2D1_Point2F); stdcall;
    procedure SetEndPoint(EndPoint: TD2D1_Point2F); stdcall;
    function GetStartPoint: TD2D1_Point2F; stdcall;
    function GetEndPoint:TD2D1_Point2F; stdcall;
    procedure GetGradientStopCollection(out GradientStopCollection:ID2D1GradientStopCollection); stdcall;
  end;

  ID2D1RadialGradientBrush = interface(ID2D1Brush)
    ['{2CD906AC-12E2-11DC-9FED-001143A055F9}']
    procedure SetCenter(Center: TD2D1_Point2F); stdcall;
    procedure SetGradientOriginOffset(GradientOriginOffset: TD2D1_Point2F); stdcall;
    procedure SetRadiusX(RadiusX: Single); stdcall;
    procedure SetRadiusY(RadiusY: Single); stdcall;
    function GetCenter: TD2D1_Point2F; stdcall;
    function GetGradientOriginOffset: TD2D1_Point2F; stdcall;
    function GetRadiusX: Single; stdcall;
    function GetRadiusY: Single; stdcall;
    procedure GetGradientStopCollection(out GradientStopCollection: ID2D1GradientStopCollection); stdcall;
  end;

  ID2D1StrokeStyle = interface(ID2D1Resource)
    ['{2CD9069D-12E2-11DC-9FED-001143A055F9}']
    function GetStartCap: TD2D1_CapStyle; stdcall;
    function GetEndCap: TD2D1_CapStyle; stdcall;
    function GetDashCap: TD2D1_CapStyle; stdcall;
    function GetMiterLimit: Single; stdcall;
    function GetLineJoin: TD2D1_LineJoin; stdcall;
    function GetDashOffset: Single; stdcall;
    function GetDashStyle: TD2D1_DashStyle; stdcall;
    function GetDashesCount: LongWord; stdcall;
    procedure GetDashes(Dashes: PSingle; DashesCount: LongWord); stdcall;
  end;

  ID2D1Geometry = interface(ID2D1Resource)
    ['{2CD906A1-12E2-11DC-9FED-001143A055F9}']
    function GetBounds(WorldTransform: PTD2D1_Matrix3X2F; out Bounds: TD2D1_RectF): HResult; stdcall;
    function GetWidenedBounds(StrokeWidth: Single; StrokeStyle: ID2D1StrokeStyle; 
      WorldTransform: PTD2D1_Matrix3X2F; FlatteningTolerance: Single; out Bounds: TD2D1_RectF): HResult; stdcall;
    function StrokeContainsPoint(Point: TD2D1_Point2F; StrokeWidth: Single; StrokeStyle: ID2D1StrokeStyle; 
      WorldTransform:PTD2D1_Matrix3X2F; FlatteningTolerance: Single; out Contains: LongBool): HResult; stdcall;
    function FillContainsPoint(Point: TD2D1_Point2F; WorldTransform: PTD2D1_Matrix3X2F;
      FlatteningTolerance: Single; out Contains: LongBool):HResult; stdcall;
    function CompareWithGeometry(InputGeometry: ID2D1Geometry; InputGeometryTransform: PTD2D1_Matrix3X2F; 
      FlatteningTolerance: Single; out Relation: TD2D1_GeometryRelation): HResult; stdcall;
    function Simplify(SimplificationOption: TD2D1_GeometrySimplificationOption;
      WorldTransform: PTD2D1_Matrix3X2F; FlatteningTolerance: Single;
      GeometrySink: ID2D1SimplifiedGeometrySink):HResult; stdcall;
    function Tessellate(WorldTransform: PTD2D1_Matrix3X2F; FlatteningTolerance: Single;
      TessellationSink: ID2D1TessellationSink): HResult; stdcall;
    function CombineWithGeometry(InputGeometry: ID2D1Geometry; CombineMode: TD2D1_CombineMode;
      InputGeometryTransform: PTD2D1_Matrix3X2F; FlatteningTolerance: Single;
      GeometrySink: ID2D1SimplifiedGeometrySink): HResult; stdcall;
    function Outline(WorldTransform: PTD2D1_Matrix3X2F;  FlatteningTolerance: Single;
      GeometrySink: ID2D1SimplifiedGeometrySink): HResult; stdcall;
    function ComputeArea(WorldTransform: PTD2D1_Matrix3X2F; FlatteningTolerance: Single;
      out Area: Single):HResult; stdcall;
    function ComputeLength(WorldTransform: PTD2D1_Matrix3X2F; FlatteningTolerance: Single;
      out Length: Single):HResult; stdcall;
    function ComputePointAtLength(Length: Single; WorldTransform: PTD2D1_Matrix3X2F;
      FlatteningTolerance:Single; Point: PTD2D1_Point2F; UnitTangentVector: PTD2D1_Point2F): HResult; stdcall;
    function Widen(StrokeWidth: Single; StrokeStyle: ID2D1StrokeStyle; WorldTransform: PTD2D1_Matrix3X2F;
      FlatteningTolerance: Single; GeometrySink: ID2D1SimplifiedGeometrySink): HResult; stdcall;
  end;

  ID2D1RectangleGeometry = interface(ID2D1Geometry)
    ['{2CD906A2-12E2-11DC-9FED-001143A055F9}']
    procedure GetRect(out Rect:TD2D1_RectF); stdcall;
  end;

  ID2D1RoundedRectangleGeometry = interface(ID2D1Geometry)
    ['{2CD906A3-12E2-11DC-9FED-001143A055F9}']
    procedure GetRoundedRect(out RoundedRect:TD2D1_RoundedRect); stdcall;
  end;

  ID2D1EllipseGeometry = interface(ID2D1Geometry)
    ['{2CD906A4-12E2-11DC-9FED-001143A055F9}']
    procedure GetEllipse(out Ellipse:TD2D1_Ellipse); stdcall;
  end;

  ID2D1GeometryGroup = interface(ID2D1Geometry)
    ['{2CD906A6-12E2-11DC-9FED-001143A055F9}']
    function GetFillMode:TD2D1_FillMode; stdcall;
    function GetSourceGeometryCount:LongWord; stdcall;
    procedure GetSourceGeometries(Geometries: PID2D1Geometry; GeometriesCount: LongWord); stdcall;
  end;

  ID2D1TransformedGeometry = interface(ID2D1Geometry)
    ['{2CD906BB-12E2-11DC-9FED-001143A055F9}']
    procedure GetSourceGeometry(out SourceGeometry: ID2D1Geometry); stdcall;
    procedure GetTransform(out Transform: TD2D1_Matrix3X2F); stdcall;
  end;

  ID2D1SimplifiedGeometrySink = interface(IUnknown)
    ['{2CD9069E-12E2-11DC-9FED-001143A055F9}']
    procedure SetFillMode(FillMode: TD2D1_FillMode); stdcall;
    procedure SetSegmentFlags(VertexFlags: TD2D1_PathSegment); stdcall;
    procedure BeginFigure(StartPoint: TD2D1_Point2F; FigureBegin: TD2D1_FigureBegin); stdcall;
    procedure AddLines(Points: PTD2D1_Point2F; PointsCount: LongWord); stdcall;
    procedure AddBeziers(Beziers: PTD2D1_BezierSegment; BeziersCount: LongWord); stdcall;
    procedure EndFigure(FigureEnd: TD2D1_FigureEnd); stdcall;
    function Close:HResult; stdcall;
  end;

  ID2D1GeometrySink = interface(ID2D1SimplifiedGeometrySink)
    ['{2CD9069F-12E2-11DC-9FED-001143A055F9}']
    procedure AddLine(Point: TD2D1_Point2F); stdcall;
    procedure AddBezier(const Bezier: TD2D1_BezierSegment); stdcall;
    procedure AddQuadraticBezier(const Bezier: TD2D1_QuadraticBezierSegment); stdcall;
    procedure AddQuadraticBeziers(Beziers: PTD2D1_QuadraticBezierSegment; BeziersCount: LongWord); stdcall;
    procedure AddArc(const Arc: TD2D1_ArcSegment); stdcall;
  end;

  ID2D1TessellationSink = interface(IUnknown)
    ['{2CD906C1-12E2-11DC-9FED-001143A055F9}']
    procedure AddTriangles(Triangles: PTD2D1_Triangle; TrianglesCount: LongWord); stdcall;
    function Close: HResult; stdcall;
  end;

  ID2D1PathGeometry = interface(ID2D1Geometry)
    ['{2CD906A5-12E2-11DC-9FED-001143A055F9}']
    function Open(out GeometrySink: ID2D1GeometrySink): HResult; stdcall;
    function Stream(GeometrySink: ID2D1GeometrySink): HResult; stdcall;
    function GetSegmentCount(out Count: LongWord): HResult; stdcall;
    function GetFigureCount(out Count: LongWord): HResult; stdcall;
  end;

  ID2D1Mesh = interface(ID2D1Resource)
    ['{2CD906C2-12E2-11DC-9FED-001143A055F9}']
    function Open(out TessellationSink: ID2D1TessellationSink): HResult; stdcall;
  end;

  ID2D1Layer = interface(ID2D1Resource)
    ['{2CD9069B-12E2-11DC-9FED-001143A055F9}']
    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetSize(out o_Result:TD2D1_SizeF); stdcall;
  end;

  ID2D1DrawingStateBlock = interface(ID2D1Resource)
    ['{28506E39-EBF6-46A1-BB47-FD85565AB957}']
    procedure GetDescription(out StateDescription: TD2D1_DrawingStateDescription); stdcall;
    procedure SetDescription(const StateDescription: TD2D1_DrawingStateDescription); stdcall;
    procedure SetTextRenderingParams(TextRenderingParams: IDWriteRenderingParams = nil); stdcall;
    procedure GetTextRenderingParams({$IFDEF UsePointersForOptionalOutputInterfaces}textRenderingParams:PIDWriteRenderingParams{$ELSE}out TextRenderingParams:IDWriteRenderingParams{$ENDIF}); stdcall;
  end;

  ID2D1RenderTarget = interface(ID2D1Resource)
    ['{2CD90694-12E2-11DC-9FED-001143A055F9}']
    function CreateBitmap(Size: TD2D1_SizeU; SrcData: Pointer; Pitch: LongWord;
      const BitmapProperties: TD2D1_BitmapProperties; out Bitmap: ID2D1Bitmap): HResult; stdcall;
    function CreateBitmapFromWicBitmap(WicBitmapSource: IUnknown {JSB: To do: IWICBitmapSource}; 
      BitmapProperties: PTD2D1_BitmapProperties; out Bitmap: ID2D1Bitmap):HResult; stdcall;
    function CreateSharedBitmap(const IID:TGUID; Data:Pointer; 
      BitmapProperties:PTD2D1_BitmapProperties; out Bitmap:ID2D1Bitmap):HResult; stdcall;
    function CreateBitmapBrush(Bitmap: ID2D1Bitmap; BitmapBrushProperties: PTD2D1_BitmapBrushProperties; 
      BrushProperties: PTD2D1_BrushProperties; out BitmapBrush: ID2D1BitmapBrush):HResult; stdcall;
    function CreateSolidColorBrush(const Color: TD2D1_ColorF; BrushProperties: PTD2D1_BrushProperties; 
      out SolidColorBrush: ID2D1SolidColorBrush):HResult; stdcall;
    function CreateGradientStopCollection(GradientStops: PTD2D1_GradientStop; GradientStopsCount: LongWord;
      ColorInterpolationGamma: TD2D1_Gamma; ExtendMode: TD2D1_ExtendMode;
      out GradientStopCollection: ID2D1GradientStopCollection): HResult; stdcall;
    function CreateLinearGradientBrush(const LinearGradientBrushProperties: TD2D1_LinearGradientBrushProperties;
      BrushProperties: PTD2D1_BrushProperties; GradientStopCollection: ID2D1GradientStopCollection;
      out LinearGradientBrush: ID2D1LinearGradientBrush): HResult; stdcall;
    function CreateRadialGradientBrush(const RadialGradientBrushProperties:TD2D1_RadialGradientBrushProperties;
      BrushProperties: PTD2D1_BrushProperties; GradientStopCollection:ID2D1GradientStopCollection; 
      out RadialGradientBrush:ID2D1RadialGradientBrush):HResult; stdcall;
    function CreateCompatibleRenderTarget(DesiredSize: PTD2D1_SizeF; 
      DesiredPixelSize: PTD2D1_SizeU; DesiredFormat: PTD2D1_PixelFormat;
      Options: TD2D1_CompatibleRenderTargetOptions; out BitmapRenderTarget:ID2D1BitmapRenderTarget): HResult; stdcall;
    function CreateLayer(Size: PTD2D1_SizeF; out Layer: ID2D1Layer): HResult; stdcall;
    function CreateMesh(out Mesh: ID2D1Mesh): HResult; stdcall;
    
    procedure DrawLine( Point0, Point1:TD2D1_Point2F; Brush: ID2D1Brush; 
      StrokeWidth:Single = 1.0; StrokeStyle:ID2D1StrokeStyle = nil); stdcall;
    procedure DrawRectangle(const Rect:TD2D1_RectF;  Brush:ID2D1Brush;
      StrokeWidth: Single = 1.0; StrokeStyle: ID2D1StrokeStyle = nil); stdcall;
    procedure FillRectangle(const Rect: TD2D1_RectF; Brush: ID2D1Brush); stdcall;
    procedure DrawRoundedRectangle(const RoundedRect: TD2D1_RoundedRect; 
      Brush: ID2D1Brush; StrokeWidth:Single = 1.0; StrokeStyle:ID2D1StrokeStyle = nil); stdcall;
    procedure FillRoundedRectangle(const RoundedRect:TD2D1_RoundedRect; Brush:ID2D1Brush); stdcall;
    procedure DrawEllipse(const Ellipse: TD2D1_Ellipse; Brush: ID2D1Brush;
      StrokeWidth:Single = 1.0; StrokeStyle: ID2D1StrokeStyle = nil); stdcall;
    procedure FillEllipse(const Ellipse: TD2D1_Ellipse; Brush: ID2D1Brush); stdcall;
    procedure DrawGeometry(Geometry: ID2D1Geometry; Brush: ID2D1Brush; 
      StrokeWidth:Single = 1.0; StrokeStyle:ID2D1StrokeStyle = nil); stdcall;
    procedure FillGeometry(Geometry:ID2D1Geometry; Brush: ID2D1Brush; OpacityBrush:ID2D1Brush = nil); stdcall;
    procedure FillMesh(Mesh: ID2D1Mesh; Brush: ID2D1Brush); stdcall;
    procedure FillOpacityMask(OpacityMask: ID2D1Bitmap; Brush: ID2D1Brush;
      Content: TD2D1_OpacityMaskContent; DestinationRectangle: PTD2D1_RectF = nil;
      SourceRectangle:PTD2D1_RectF = nil); stdcall;
      
    procedure DrawBitmap(Bitmap: ID2D1Bitmap; DestinationRectangle:PTD2D1_RectF = nil; 
      Opacity:Single = 1.0; InterpolationMode: TD2D1_BitmapInterpolationMode = D2D1_BITMAP_INTERPOLATION_MODE_LINEAR;
      SourceRectangle:PTD2D1_RectF = nil); stdcall;
    procedure DrawText(_String: PWideChar; StringLength: LongWord; TextFormat: IDWriteTextFormat; 
      const LayoutRect: TD2D1_RectF; DefaultForegroundBrush: ID2D1Brush;
      Options: TD2D1_DrawTextOptions = D2D1_DRAW_TEXT_OPTIONS_NONE;
      MeasuringMode: TDWrite_MeasuringMode = DWRITE_MEASURING_MODE_NATURAL); stdcall;
    procedure DrawTextLayout(Origin: TD2D1_Point2F; TextLayout: IDWriteTextLayout; 
      DefaultForegroundBrush: ID2D1Brush; Options: TD2D1_DrawTextOptions = D2D1_DRAW_TEXT_OPTIONS_NONE); stdcall;
    procedure DrawGlyphRun(BaselineOrigin: TD2D1_Point2F; const GlyphRun: TDWrite_GlyphRun;
      ForegroundBrush: ID2D1Brush; MeasuringMode: TDWrite_MeasuringMode = DWRITE_MEASURING_MODE_NATURAL); stdcall;
      
    procedure SetTransform(const Transform: TD2D1_Matrix3X2F); stdcall;
    procedure GetTransform(out Transform: TD2D1_Matrix3X2F); stdcall;
    procedure SetAntialiasMode(AntialiasMode: TD2D1_AntialiasMode); stdcall;
    function GetAntialiasMode: TD2D1_AntialiasMode; stdcall;
    procedure SetTextAntialiasMode(TextAntialiasMode: TD2D1_TextAntialiasMode); stdcall;
    function GetTextAntialiasMode: TD2D1_TextAntialiasMode; stdcall;
    procedure SetTextRenderingParams(TextRenderingParams:IDWriteRenderingParams = nil); stdcall;
    procedure GetTextRenderingParams({$IFDEF UsePointersForOptionalOutputInterfaces}textRenderingParams:PIDWriteRenderingParams{$ELSE}out TextRenderingParams:IDWriteRenderingParams{$ENDIF}); stdcall;
    procedure SetTags(Tag1: TD2D1_Tag; Tag2: TD2D1_Tag); stdcall;
    procedure GetTags(Tag1:PTD2D1_Tag = nil; Tag2:PTD2D1_Tag = nil); stdcall;

    procedure PushLayer(const LayerParameters: TD2D1_LayerParameters; Layer: ID2D1Layer); stdcall;
    procedure PopLayer; stdcall;

    function Flush(Tag1: PTD2D1_Tag = nil; Tag2: PTD2D1_Tag = nil):HResult; stdcall;

    procedure SaveDrawingState(DrawingStateBlock: ID2D1DrawingStateBlock); stdcall;
    procedure RestoreDrawingState(DrawingStateBlock: ID2D1DrawingStateBlock); stdcall;

    procedure PushAxisAlignedClip(const ClipRect: TD2D1_RectF; AntialiasMode: TD2D1_AntialiasMode); stdcall;
    procedure PopAxisAlignedClip; stdcall;

     // JSB: Added 'const' for compatibility with Embarcado version. Use TD2D1_ColorF(nil^) for nil.
    procedure Clear(const ClearColor: TD2D1_ColorF); stdcall;

    procedure BeginDraw; stdcall;
    function EndDraw(Tag1: PTD2D1_Tag = nil; Tag2: PTD2D1_Tag = nil):HResult; stdcall;

    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetPixelFormat(out o_Result: TD2D1_PixelFormat); stdcall;

    procedure SetDpi(DpiX, DpiY: Single); stdcall;
    procedure GetDpi(out DpiX, DpiY: Single); stdcall;
    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetSize(out o_Result:TD2D1_SizeF); stdcall;
    (* Workaround for the Delphi parameter passing order bug for stdcall methods that return a struct/record. *)
    procedure GetPixelSize(out o_Result: TD2D1_SizeU); stdcall;
    function GetMaximumBitmapSize:LongWord; stdcall;
    function IsSupported(const RenderTargetProperties: TD2D1_RenderTargetProperties): LongBool; stdcall;
  end;

  ID2D1BitmapRenderTarget = interface(ID2D1RenderTarget)
    ['{2CD90695-12E2-11DC-9FED-001143A055F9}']
    function GetBitmap(out Bitmap: ID2D1Bitmap): HResult; stdcall;
  end;

  ID2D1HwndRenderTarget = interface(ID2D1RenderTarget)
    ['{2CD90698-12E2-11DC-9FED-001143A055F9}']
    function CheckWindowState: TD2D1_WindowState; stdcall;
    function Resize(const PixelSize: TD2D1_SizeU): HResult; stdcall;
    function GetHwnd: HWND; stdcall;
  end;

  ID2D1GdiInteropRenderTarget = interface(IUnknown)
    ['{E0DB51C3-6F77-4BAE-B3D5-E47509B35838}']
    function GetDC(Mode: TD2D1_DcInitializeMode; out hDC: HDC): HResult; stdcall;
    function ReleaseDC(Update: PTRect): HResult; stdcall;
  end;

  ID2D1DCRenderTarget = interface(ID2D1RenderTarget)
    ['{1C51BC64-DE61-46FD-9899-63A5D8F03950}']
    function BindDC(hDC: HDC; const SubRect: TRect): HResult; stdcall;
  end;

  ID2D1Factory=interface(IUnknown)
    ['{06152247-6F50-465A-9245-118BFD3B6007}']
    function ReloadSystemMetrics:HResult; stdcall;
    procedure GetDesktopDpi(out DpiX, DpiY:Single); stdcall;

    function CreateRectangleGeometry(const Rectangle: TD2D1_RectF;
      out RectangleGeometry: ID2D1RectangleGeometry): HResult; stdcall;
    function CreateRoundedRectangleGeometry(const RoundedRectangle: TD2D1_RoundedRect; 
      out RoundedRectangleGeometry: ID2D1RoundedRectangleGeometry):HResult; stdcall;
    function CreateEllipseGeometry(const Ellipse:TD2D1_Ellipse;
      out EllipseGeometry:ID2D1EllipseGeometry):HResult; stdcall;
    function CreateGeometryGroup(FillMode: TD2D1_FillMode; Geometries: PID2D1Geometry; 
      GeometriesCount: LongWord; out GeometryGroup:ID2D1GeometryGroup): HResult; stdcall;
    function CreateTransformedGeometry(SourceGeometry: ID2D1Geometry; const Transform: TD2D1_Matrix3X2F;
      out TransformedGeometry:ID2D1TransformedGeometry):HResult; stdcall;
    function CreatePathGeometry(out PathGeometry: ID2D1PathGeometry): HResult; stdcall;
    function CreateStrokeStyle(const StrokeStyleProperties: TD2D1_StrokeStyleProperties; 
      Dashes: PSingle; DashesCount: LongWord; out StrokeStyle: ID2D1StrokeStyle):HResult; stdcall;
    function CreateDrawingStateBlock(DrawingStateDescription:PTD2D1_DrawingStateDescription;
      TextRenderingParams: IDWriteRenderingParams; out DrawingStateBlock: ID2D1DrawingStateBlock): HResult; stdcall;
    function CreateWicBitmapRenderTarget(Target:IUnknown {JSB: To do: IWICBitmap}; 
      const RenderTargetProperties:TD2D1_RenderTargetProperties; 
      out RenderTarget:ID2D1RenderTarget):HResult; stdcall;
    function CreateHwndRenderTarget(const RenderTargetProperties: TD2D1_RenderTargetProperties;
      const HwndRenderTargetProperties: TD2D1_HwndRenderTargetProperties;
      out HwndRenderTarget:ID2D1HwndRenderTarget): HResult; stdcall;
    function CreateDxgiSurfaceRenderTarget(Surface: IDXGISurface; 
      const RenderTargetProperties: TD2D1_RenderTargetProperties;
      out RenderTarget: ID2D1RenderTarget):HResult; stdcall;
    function CreateDCRenderTarget(const RenderTargetProperties:TD2D1_RenderTargetProperties; 
      out RenderTarget:ID2D1DCRenderTarget):HResult; stdcall;
  end;

{$IFDEF UseRuntimeLinking}var D2D1CreateFactory:{$ENDIF}function{$IFNDEF UseRuntimeLinking}D2D1CreateFactory{$ENDIF}
(
  FactoryType:TD2D1_FactoryType; (* __in *)
  const IID:TGUID; (* __in *)
  pFactoryOptions:PTD2D1_FactoryOptions; (* __in_opt *)
  out pIFactory {IUnknown} (* __out *)
):HResult; stdcall; {$IFNDEF UseRuntimeLinking} external DLL_D2D1; {$ENDIF}

{$IFDEF UseRuntimeLinking}var D2D1MakeRotateMatrix:{$ENDIF}procedure{$IFNDEF UseRuntimeLinking}D2D1MakeRotateMatrix{$ENDIF}
(
  Angle:Single; (* __in *)
  Center:TD2D1_Point2F; (* __in *)
  out Matrix:TD2D1_Matrix3X2F (* __out *)
); stdcall; {$IFNDEF UseRuntimeLinking}external DLL_D2D1;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D2D1MakeSkewMatrix:{$ENDIF}procedure{$IFNDEF UseRuntimeLinking}D2D1MakeSkewMatrix{$ENDIF}
(
  AngleX:Single; (* __in *)
  AngleY:Single; (* __in *)
  Center:TD2D1_Point2F; (* __in *)
  out Matrix:TD2D1_Matrix3X2F (* __out *)
); stdcall; {$IFNDEF UseRuntimeLinking}external DLL_D2D1;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D2D1IsMatrixInvertible:{$ENDIF}function{$IFNDEF UseRuntimeLinking}D2D1IsMatrixInvertible{$ENDIF}
(
  const Matrix:TD2D1_Matrix3X2F (* __in *)
):LongBool; stdcall; {$IFNDEF UseRuntimeLinking}external DLL_D2D1;{$ENDIF}

{$IFDEF UseRuntimeLinking}var D2D1InvertMatrix:{$ENDIF}function{$IFNDEF UseRuntimeLinking}D2D1InvertMatrix{$ENDIF}
(
  var Matrix:TD2D1_Matrix3X2F (* __inout *)
):LongBool; stdcall; {$IFNDEF UseRuntimeLinking}external DLL_D2D1;{$ENDIF}

///////////////////////////////////////////////////////////////////////////////
// End "D2D1.h"
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Begin "D2Derr.h"
///////////////////////////////////////////////////////////////////////////////

const
  FACILITY_D2D     = $899;
  D2D_HRESULT_Base = (1 shl 31) or (FACILITY_D2D shl 16);

//!!!  D2DERR__UNSUPPORTED_PIXEL_FORMAT=WINCODEC_ERR_UNSUPPORTEDPIXELFORMAT;
//!!!  D2DERR__INSUFFICIENT_BUFFER=HRESULT_FROM_WIN32(ERROR_INSUFFICIENT_BUFFER);
  D2DERR_WRONG_STATE                         = HResult(D2D_HRESULT_Base or $001);
  D2DERR_NOT_INITIALIZED                     = HResult(D2D_HRESULT_Base or $002);
  D2DERR_UNSUPPORTED_OPERATION               = HResult(D2D_HRESULT_Base or $003);
  D2DERR_UNSUPPORTED_PIXEL_FORMAT            = HResult($88982F80); // JSB: From "wincodec.h"
  D2DERR_SCANNER_FAILED                      = HResult(D2D_HRESULT_Base or $004);
  D2DERR_SCREEN_ACCESS_DENIED                = HResult(D2D_HRESULT_Base or $005);
  D2DERR_DISPLAY_STATE_INVALID               = HResult(D2D_HRESULT_Base or $006);
  D2DERR_ZERO_VECTOR                         = HResult(D2D_HRESULT_Base or $007);
  D2DERR_INTERNAL_ERROR                      = HResult(D2D_HRESULT_Base or $008);
  D2DERR_DISPLAY_FORMAT_NOT_SUPPORTED        = HResult(D2D_HRESULT_Base or $009);
  D2DERR_INVALID_CALL                        = HResult(D2D_HRESULT_Base or $00A);
  D2DERR_NO_HARDWARE_DEVICE                  = HResult(D2D_HRESULT_Base or $00B);
  D2DERR_RECREATE_TARGET                     = HResult(D2D_HRESULT_Base or $00C);
  D2DERR_TOO_MANY_SHADER_ELEMENTS            = HResult(D2D_HRESULT_Base or $00D);
  D2DERR_SHADER_COMPILE_FAILED               = HResult(D2D_HRESULT_Base or $00E);
  D2DERR_MAX_TEXTURE_SIZE_EXCEEDED           = HResult(D2D_HRESULT_Base or $00F);
  D2DERR_UNSUPPORTED_VERSION                 = HResult(D2D_HRESULT_Base or $010);
  D2DERR_BAD_NUMBER                          = HResult(D2D_HRESULT_Base or $0011);
  D2DERR_WRONG_FACTORY                       = HResult(D2D_HRESULT_Base or $012);
  D2DERR_LAYER_ALREADY_IN_USE                = HResult(D2D_HRESULT_Base or $013);
  D2DERR_POP_CALL_DID_NOT_MATCH_PUSH         = HResult(D2D_HRESULT_Base or $014);
  D2DERR_WRONG_RESOURCE_DOMAIN               = HResult(D2D_HRESULT_Base or $015);
  D2DERR_PUSH_POP_UNBALANCED                 = HResult(D2D_HRESULT_Base or $016);
  D2DERR_RENDER_TARGET_HAS_LAYER_OR_CLIPRECT = HResult(D2D_HRESULT_Base or $017);
  D2DERR_INCOMPATIBLE_BRUSH_TYPES            = HResult(D2D_HRESULT_Base or $018);
  D2DERR_WIN32_ERROR                         = HResult(D2D_HRESULT_Base or $019);
  D2DERR_TARGET_NOT_GDI_COMPATIBLE           = HResult(D2D_HRESULT_Base or $01A);
  D2DERR_TEXT_EFFECT_IS_WRONG_TYPE           = HResult(D2D_HRESULT_Base or $01B);
  D2DERR_TEXT_RENDERER_NOT_RELEASED          = HResult(D2D_HRESULT_Base or $01C);
  D2DERR_EXCEEDS_MAX_BITMAP_SIZE             = HResult(D2D_HRESULT_Base or $01D);

  D2DERR_INSUFFICIENT_BUFFER                 = HResult(ERROR_INSUFFICIENT_BUFFER);
  D2DERR_INVALID_GRAPH_CONFIGURATION         = HResult(D2D_HRESULT_Base or $01E);
  D2DERR_INVALID_INTERNAL_GRAPH_CONFIGURATION= HResult(D2D_HRESULT_Base or $01F);
  D2DERR_CYCLIC_GRAPH                        = HResult(D2D_HRESULT_Base or $020);
  D2DERR_BITMAP_CANNOT_DRAW                  = HResult(D2D_HRESULT_Base or $021);
  D2DERR_OUTSTANDING_BITMAP_REFERENCES       = HResult(D2D_HRESULT_Base or $022);
  D2DERR_ORIGINAL_TARGET_NOT_BOUND           = HResult(D2D_HRESULT_Base or $023);
  D2DERR_INVALID_TARGET                      = HResult(D2D_HRESULT_Base or $024);
  D2DERR_BITMAP_BOUND_AS_TARGET              = HResult(D2D_HRESULT_Base or $025);
  D2DERR_INSUFFICIENT_DEVICE_CAPABILITIES    = HResult(D2D_HRESULT_Base or $026);
  D2DERR_INTERMEDIATE_TOO_LARGE              = HResult(D2D_HRESULT_Base or $027);
  D2DERR_EFFECT_IS_NOT_REGISTERED            = HResult(D2D_HRESULT_Base or $028);
  D2DERR_INVALID_PROPERTY                    = HResult(D2D_HRESULT_Base or $029);
  D2DERR_NO_SUBPROPERTIES                    = HResult(D2D_HRESULT_Base or $02A);
  D2DERR_PRINT_JOB_CLOSED                    = HResult(D2D_HRESULT_Base or $02B);
  D2DERR_PRINT_FORMAT_NOT_SUPPORTED          = HResult(D2D_HRESULT_Base or $02C);
  D2DERR_TOO_MANY_TRANSFORM_INPUTS           = HResult(D2D_HRESULT_Base or $02D);
  
///////////////////////////////////////////////////////////////////////////////
// End "D2Derr.h"
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Begin "D2D1Helper.h"
///////////////////////////////////////////////////////////////////////////////

type
  // Predefined colors. The item prefix is required so that "Tan" does not clash with "Math.Tan"!
  // It is a shame that Delphi enumerations do not work the same way as .Net and insist on the enumeration type being used with the item e.g. "TD2D1_Color.Tan".
  TD2D1_Color = (
    D2D1_Color_AliceBlue            = $F0F8FF,
    D2D1_Color_AntiqueWhite         = $FAEBD7,
    D2D1_Color_Aqua                 = $00FFFF,
    D2D1_Color_Aquamarine           = $7FFFD4,
    D2D1_Color_Azure                = $F0FFFF,
    D2D1_Color_Beige                = $F5F5DC,
    D2D1_Color_Bisque               = $FFE4C4,
    D2D1_Color_Black                = $000000,
    D2D1_Color_BlanchedAlmond       = $FFEBCD,
    D2D1_Color_Blue                 = $0000FF,
    D2D1_Color_BlueViolet           = $8A2BE2,
    D2D1_Color_Brown                = $A52A2A,
    D2D1_Color_BurlyWood            = $DEB887,
    D2D1_Color_CadetBlue            = $5F9EA0,
    D2D1_Color_Chartreuse           = $7FFF00,
    D2D1_Color_Chocolate            = $D2691E,
    D2D1_Color_Coral                = $FF7F50,
    D2D1_Color_CornflowerBlue       = $6495ED,
    D2D1_Color_Cornsilk             = $FFF8DC,
    D2D1_Color_Crimson              = $DC143C,
    D2D1_Color_Cyan                 = $00FFFF,
    D2D1_Color_DarkBlue             = $00008B,
    D2D1_Color_DarkCyan             = $008B8B,
    D2D1_Color_DarkGoldenrod        = $B8860B,
    D2D1_Color_DarkGray             = $A9A9A9,
    D2D1_Color_DarkGreen            = $006400,
    D2D1_Color_DarkKhaki            = $BDB76B,
    D2D1_Color_DarkMagenta          = $8B008B,
    D2D1_Color_DarkOliveGreen       = $556B2F,
    D2D1_Color_DarkOrange           = $FF8C00,
    D2D1_Color_DarkOrchid           = $9932CC,
    D2D1_Color_DarkRed              = $8B0000,
    D2D1_Color_DarkSalmon           = $E9967A,
    D2D1_Color_DarkSeaGreen         = $8FBC8F,
    D2D1_Color_DarkSlateBlue        = $483D8B,
    D2D1_Color_DarkSlateGray        = $2F4F4F,
    D2D1_Color_DarkTurquoise        = $00CED1,
    D2D1_Color_DarkViolet           = $9400D3,
    D2D1_Color_DeepPink             = $FF1493,
    D2D1_Color_DeepSkyBlue          = $00BFFF,
    D2D1_Color_DimGray              = $696969,
    D2D1_Color_DodgerBlue           = $1E90FF,
    D2D1_Color_Firebrick            = $B22222,
    D2D1_Color_FloralWhite          = $FFFAF0,
    D2D1_Color_ForestGreen          = $228B22,
    D2D1_Color_Fuchsia              = $FF00FF,
    D2D1_Color_Gainsboro            = $DCDCDC,
    D2D1_Color_GhostWhite           = $F8F8FF,
    D2D1_Color_Gold                 = $FFD700,
    D2D1_Color_Goldenrod            = $DAA520,
    D2D1_Color_Gray                 = $808080,
    D2D1_Color_Green                = $008000,
    D2D1_Color_GreenYellow          = $ADFF2F,
    D2D1_Color_Honeydew             = $F0FFF0,
    D2D1_Color_HotPink              = $FF69B4,
    D2D1_Color_IndianRed            = $CD5C5C,
    D2D1_Color_Indigo               = $4B0082,
    D2D1_Color_Ivory                = $FFFFF0,
    D2D1_Color_Khaki                = $F0E68C,
    D2D1_Color_Lavender             = $E6E6FA,
    D2D1_Color_LavenderBlush        = $FFF0F5,
    D2D1_Color_LawnGreen            = $7CFC00,
    D2D1_Color_LemonChiffon         = $FFFACD,
    D2D1_Color_LightBlue            = $ADD8E6,
    D2D1_Color_LightCoral           = $F08080,
    D2D1_Color_LightCyan            = $E0FFFF,
    D2D1_Color_LightGoldenrodYellow = $FAFAD2,
    D2D1_Color_LightGreen           = $90EE90,
    D2D1_Color_LightGray            = $D3D3D3,
    D2D1_Color_LightPink            = $FFB6C1,
    D2D1_Color_LightSalmon          = $FFA07A,
    D2D1_Color_LightSeaGreen        = $20B2AA,
    D2D1_Color_LightSkyBlue         = $87CEFA,
    D2D1_Color_LightSlateGray       = $778899,
    D2D1_Color_LightSteelBlue       = $B0C4DE,
    D2D1_Color_LightYellow          = $FFFFE0,
    D2D1_Color_Lime                 = $00FF00,
    D2D1_Color_LimeGreen            = $32CD32,
    D2D1_Color_Linen                = $FAF0E6,
    D2D1_Color_Magenta              = $FF00FF,
    D2D1_Color_Maroon               = $800000,
    D2D1_Color_MediumAquamarine     = $66CDAA,
    D2D1_Color_MediumBlue           = $0000CD,
    D2D1_Color_MediumOrchid         = $BA55D3,
    D2D1_Color_MediumPurple         = $9370DB,
    D2D1_Color_MediumSeaGreen       = $3CB371,
    D2D1_Color_MediumSlateBlue      = $7B68EE,
    D2D1_Color_MediumSpringGreen    = $00FA9A,
    D2D1_Color_MediumTurquoise      = $48D1CC,
    D2D1_Color_MediumVioletRed      = $C71585,
    D2D1_Color_MidnightBlue         = $191970,
    D2D1_Color_MintCream            = $F5FFFA,
    D2D1_Color_MistyRose            = $FFE4E1,
    D2D1_Color_Moccasin             = $FFE4B5,
    D2D1_Color_NavajoWhite          = $FFDEAD,
    D2D1_Color_Navy                 = $000080,
    D2D1_Color_OldLace              = $FDF5E6,
    D2D1_Color_Olive                = $808000,
    D2D1_Color_OliveDrab            = $6B8E23,
    D2D1_Color_Orange               = $FFA500,
    D2D1_Color_OrangeRed            = $FF4500,
    D2D1_Color_Orchid               = $DA70D6,
    D2D1_Color_PaleGoldenrod        = $EEE8AA,
    D2D1_Color_PaleGreen            = $98FB98,
    D2D1_Color_PaleTurquoise        = $AFEEEE,
    D2D1_Color_PaleVioletRed        = $DB7093,
    D2D1_Color_PapayaWhip           = $FFEFD5,
    D2D1_Color_PeachPuff            = $FFDAB9,
    D2D1_Color_Peru                 = $CD853F,
    D2D1_Color_Pink                 = $FFC0CB,
    D2D1_Color_Plum                 = $DDA0DD,
    D2D1_Color_PowderBlue           = $B0E0E6,
    D2D1_Color_Purple               = $800080,
    D2D1_Color_Red                  = $FF0000,
    D2D1_Color_RosyBrown            = $BC8F8F,
    D2D1_Color_RoyalBlue            = $4169E1,
    D2D1_Color_SaddleBrown          = $8B4513,
    D2D1_Color_Salmon               = $FA8072,
    D2D1_Color_SandyBrown           = $F4A460,
    D2D1_Color_SeaGreen             = $2E8B57,
    D2D1_Color_SeaShell             = $FFF5EE,
    D2D1_Color_Sienna               = $A0522D,
    D2D1_Color_Silver               = $C0C0C0,
    D2D1_Color_SkyBlue              = $87CEEB,
    D2D1_Color_SlateBlue            = $6A5ACD,
    D2D1_Color_SlateGray            = $708090,
    D2D1_Color_Snow                 = $FFFAFA,
    D2D1_Color_SpringGreen          = $00FF7F,
    D2D1_Color_SteelBlue            = $4682B4,
    D2D1_Color_Tan                  = $D2B48C,
    D2D1_Color_Teal                 = $008080,
    D2D1_Color_Thistle              = $D8BFD8,
    D2D1_Color_Tomato               = $FF6347,
    D2D1_Color_Turquoise            = $40E0D0,
    D2D1_Color_Violet               = $EE82EE,
    D2D1_Color_Wheat                = $F5DEB3,
    D2D1_Color_White                = $FFFFFF,
    D2D1_Color_WhiteSmoke           = $F5F5F5,
    D2D1_Colors_Yellow              = $FFFF00,
    D2D1_Color_YellowGreen          = $9ACD32
  );

function D2D1ColorF(r,g,b: Single; a: Single = 1.0):TD2D1_ColorF; overload;
function D2D1ColorF(rgb: LongWord; a: Single = 1.0):TD2D1_ColorF; overload;
function D2D1ColorF(Color: TColor; a: Single = 1.0):TD2D1_ColorF; overload;
function D2D1ColorF(Color: TD2D1_Color; a: Single = 1.0):TD2D1_ColorF; overload;

const
  D2D1Matrix3x2F_Identity:TD2D1_Matrix3X2F=(_11:1;_12:0;_21:0;_22:1;_31:0;_32:1);

function D2D1Matrix3x2F(_11,_12,_21,_22,_31,_32:Single):TD2D1_Matrix3X2F;
function D2D1Matrix3x2F_Translation(const i_X,i_Y:Single):TD2D1_Matrix3X2F; overload;
function D2D1Matrix3x2F_Translation(const i_Size:TD2D1_SizeF):TD2D1_Matrix3X2F; overload;

function D2D1Point2F(i_X,i_Y:Single):TD2D1_Point2F;

function D2D1RectF(i_Left:Single=0.0;i_Top:Single=0.0;i_Right:Single=0.0;i_Bottom:Single=0.0):TD2D1_RectF; overload;
function D2D1RectF(Rect:TRect):TD2D1_RectF; overload;
function D2D1RectU(i_Left:LongWord=0;i_Top:LongWord=0;i_Right:LongWord=0;i_Bottom:LongWord=0):TD2D1_RectU;

function D2D1PixelFormat(i_dxgiFormat: TDXGI_Format = DXGI_FORMAT_UNKNOWN;
  i_AlphaMode: TD2D1_AlphaMode = D2D1_ALPHA_MODE_UNKNOWN):TD2D1_PixelFormat;
function D2D1RenderTargetProperties(i_Type: TD2D1_RenderTargetType(*=D2D1_RENDER_TARGET_TYPE_DEFAULT*);
  const i_PixelFormat: TD2D1_PixelFormat;
  i_DpiX: Single=0.0; i_DpiY: Single=0.0;
  i_Usage: TD2D1_RenderTargetUsage = D2D1_RENDER_TARGET_USAGE_NONE;
  i_MinLevel: TD2D1_FeatureLevel = D2D1_FEATURE_LEVEL_DEFAULT): TD2D1_RenderTargetProperties;
function D2D1HwndRenderTargetProperties(i_hWnd: HWND; i_PixelSize: TD2D1_SizeU;
  i_PresentOptions: TD2D1_PresentOptions = D2D1_PRESENT_OPTIONS_NONE): TD2D1_HwndRenderTargetProperties;

///////////////////////////////////////////////////////////////////////////////
// End "D2D1Helper.h"
///////////////////////////////////////////////////////////////////////////////

function D2D1_HResultToString(Value: HRESULT):String;

{$IFDEF UseRuntimeLinking}
procedure Link;
{$ENDIF}

implementation

///////////////////////////////////////////////////////////////////////////////
// Begin "D2D1Helper.h"
///////////////////////////////////////////////////////////////////////////////

(*!!!
    //
    // Forward declared IdentityMatrix function to allow matrix class to use
    // these constructors.
    //
    D2D1FORCEINLINE
    D2D1_MATRIX_3X2_F
    IdentityMatrix();

    //
    // The default trait type for objects in D2D is float.
    //
    template<typename Type>
    struct TypeTraits
    {
        typedef D2D1_POINT_2F Point;
        typedef D2D1_SIZE_F   Size;
        typedef D2D1_RECT_F   Rect;
    };

    template<>
    struct TypeTraits<UINT32>
    {
        typedef D2D1_POINT_2U Point;
        typedef D2D1_SIZE_U   Size;
        typedef D2D1_RECT_U   Rect;
    };

    static inline
    FLOAT FloatMax()
    {
        #ifdef FLT_MAX
            return FLT_MAX;
        #else
            return 3.402823466e+38F;
        #endif
    }

    //
    // Construction helpers
    //
    template<typename Type>
    D2D1FORCEINLINE
    typename TypeTraits<Type>::Point
    Point2(
        Type x,
        Type y
        )
    {
        typename TypeTraits<Type>::Point point = { x, y };

        return point;
    }
*)

function D2D1Point2F(i_X,i_Y:Single):TD2D1_Point2F;
begin
  Result.X:=i_X;
  Result.Y:=i_Y;
end;

(*

    Point2F(
        FLOAT x = 0.f,
        FLOAT y = 0.f
        )
    {
        return Point2<FLOAT>(x, y);
    }

    D2D1FORCEINLINE
    D2D1_POINT_2U
    Point2U(
        UINT32 x = 0,
        UINT32 y = 0
        )
    {
        return Point2<UINT32>(x, y);
    }

    template<typename Type>
    D2D1FORCEINLINE
    typename TypeTraits<Type>::Size
    Size(
        Type width,
        Type height
        )
    {
        typename TypeTraits<Type>::Size size = { width, height };

        return size;
    }

    D2D1FORCEINLINE
    D2D1_SIZE_F
    SizeF(
        FLOAT width = 0.f,
        FLOAT height = 0.f
        )
    {
        return Size<FLOAT>(width, height);
    }

    D2D1FORCEINLINE
    D2D1_SIZE_U
    SizeU(
        UINT32 width = 0,
        UINT32 height = 0
        )
    {
        return Size<UINT32>(width, height);
    }

    template<typename Type>
    D2D1FORCEINLINE
    typename TypeTraits<Type>::Rect
    Rect(
        Type left,
        Type top,
        Type right,
        Type bottom
        )
    {
        typename TypeTraits<Type>::Rect rect = { left, top, right, bottom };

        return rect;
    }
*)

function D2D1RectF(i_Left,i_Top,i_Right,i_Bottom:Single):TD2D1_RectF;
begin
  Result.Left:=i_Left;
  Result.Top:=i_Top;
  Result.Right:=i_Right;
  Result.Bottom:=i_Bottom;
end;

function D2D1RectF(Rect:TRect):TD2D1_RectF;
// Added by JSB: For compatibility with Win32.
begin
  Result.Left:=Rect.Left;
  Result.Top:=Rect.Top;
  Result.Right:=Rect.Right;
  Result.Bottom:=Rect.Bottom;
end;

function D2D1RectU(i_Left,i_Top,i_Right,i_Bottom:LongWord):TD2D1_RectU;
begin
  Result.Left:=i_Left;
  Result.Top:=i_Top;
  Result.Right:=i_Right;
  Result.Bottom:=i_Bottom;
end;

(*
    D2D1FORCEINLINE
    D2D1_RECT_F
    InfiniteRect()
    {
        D2D1_RECT_F rect = { -FloatMax(), -FloatMax(), FloatMax(),  FloatMax() };

        return rect;
    }

    D2D1FORCEINLINE
    D2D1_ARC_SEGMENT
    ArcSegment(
        __in CONST D2D1_POINT_2F &point,
        __in CONST D2D1_SIZE_F &size,
        __in FLOAT rotationAngle,
        __in D2D1_SWEEP_DIRECTION sweepDirection,
        __in D2D1_ARC_SIZE arcSize
        )
    {
        D2D1_ARC_SEGMENT arcSegment = { point, size, rotationAngle, sweepDirection, arcSize };

        return arcSegment;
    }

    D2D1FORCEINLINE
    D2D1_BEZIER_SEGMENT
    BezierSegment(
        __in CONST D2D1_POINT_2F &point1,
        __in CONST D2D1_POINT_2F &point2,
        __in CONST D2D1_POINT_2F &point3
        )
    {
        D2D1_BEZIER_SEGMENT bezierSegment = { point1, point2, point3 };

        return bezierSegment;
    }

    D2D1FORCEINLINE
    D2D1_ELLIPSE
    Ellipse(
        __in CONST D2D1_POINT_2F &center,
        FLOAT radiusX,
        FLOAT radiusY
        )
    {
        D2D1_ELLIPSE ellipse;

        ellipse.point = center;
        ellipse.radiusX = radiusX;
        ellipse.radiusY = radiusY;

        return ellipse;
    }

    D2D1FORCEINLINE
    D2D1_ROUNDED_RECT
    RoundedRect(
        __in CONST D2D1_RECT_F &rect,
        FLOAT radiusX,
        FLOAT radiusY
        )
    {
        D2D1_ROUNDED_RECT roundedRect;

        roundedRect.rect = rect;
        roundedRect.radiusX = radiusX;
        roundedRect.radiusY = radiusY;

        return roundedRect;
    }

    D2D1FORCEINLINE
    D2D1_BRUSH_PROPERTIES
    BrushProperties(
        __in FLOAT opacity = 1.0,
        __in CONST D2D1_MATRIX_3X2_F &transform = D2D1::IdentityMatrix()
        )
    {
        D2D1_BRUSH_PROPERTIES brushProperties;

        brushProperties.opacity = opacity;
        brushProperties.transform = transform;

        return brushProperties;
    }

    D2D1FORCEINLINE
    D2D1_GRADIENT_STOP
    GradientStop(
        FLOAT position,
        __in CONST D2D1_COLOR_F &color
        )
    {
        D2D1_GRADIENT_STOP gradientStop = { position, color };

        return gradientStop;
    }

    D2D1FORCEINLINE
    D2D1_QUADRATIC_BEZIER_SEGMENT
    QuadraticBezierSegment(
        __in CONST D2D1_POINT_2F &point1,
        __in CONST D2D1_POINT_2F &point2
        )
    {
        D2D1_QUADRATIC_BEZIER_SEGMENT quadraticBezier = { point1, point2 };

        return quadraticBezier;
    }

    D2D1FORCEINLINE
    D2D1_STROKE_STYLE_PROPERTIES
    StrokeStyleProperties(
        D2D1_CAP_STYLE startCap = D2D1_CAP_STYLE_FLAT,
        D2D1_CAP_STYLE endCap = D2D1_CAP_STYLE_FLAT,
        D2D1_CAP_STYLE dashCap = D2D1_CAP_STYLE_FLAT,
        D2D1_LINE_JOIN lineJoin = D2D1_LINE_JOIN_MITER,
        FLOAT miterLimit = 10.0f,
        D2D1_DASH_STYLE dashStyle = D2D1_DASH_STYLE_SOLID,
        FLOAT dashOffset = 0.0f
        )
    {
        D2D1_STROKE_STYLE_PROPERTIES strokeStyleProperties;

        strokeStyleProperties.startCap = startCap;
        strokeStyleProperties.endCap = endCap;
        strokeStyleProperties.dashCap = dashCap;
        strokeStyleProperties.lineJoin = lineJoin;
        strokeStyleProperties.miterLimit = miterLimit;
        strokeStyleProperties.dashStyle = dashStyle;
        strokeStyleProperties.dashOffset = dashOffset;

        return strokeStyleProperties;
    }

    D2D1FORCEINLINE
    D2D1_BITMAP_BRUSH_PROPERTIES
    BitmapBrushProperties(
        D2D1_EXTEND_MODE extendModeX = D2D1_EXTEND_MODE_CLAMP,
        D2D1_EXTEND_MODE extendModeY = D2D1_EXTEND_MODE_CLAMP,
        D2D1_BITMAP_INTERPOLATION_MODE interpolationMode = D2D1_BITMAP_INTERPOLATION_MODE_LINEAR
        )
    {
        D2D1_BITMAP_BRUSH_PROPERTIES bitmapBrushProperties;

        bitmapBrushProperties.extendModeX = extendModeX;
        bitmapBrushProperties.extendModeY = extendModeY;
        bitmapBrushProperties.interpolationMode = interpolationMode;

        return bitmapBrushProperties;
    }

    D2D1FORCEINLINE
    D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES
    LinearGradientBrushProperties(
        __in CONST D2D1_POINT_2F &startPoint,
        __in CONST D2D1_POINT_2F &endPoint
        )
    {
        D2D1_LINEAR_GRADIENT_BRUSH_PROPERTIES linearGradientBrushProperties;

        linearGradientBrushProperties.startPoint = startPoint;
        linearGradientBrushProperties.endPoint = endPoint;

        return linearGradientBrushProperties;
    }

    D2D1FORCEINLINE
    D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES
    RadialGradientBrushProperties(
        __in CONST D2D1_POINT_2F &center,
        __in CONST D2D1_POINT_2F &gradientOriginOffset,
        FLOAT radiusX,
        FLOAT radiusY
        )
    {
        D2D1_RADIAL_GRADIENT_BRUSH_PROPERTIES radialGradientBrushProperties;

        radialGradientBrushProperties.center = center;
        radialGradientBrushProperties.gradientOriginOffset = gradientOriginOffset;
        radialGradientBrushProperties.radiusX = radiusX;
        radialGradientBrushProperties.radiusY = radiusY;

        return radialGradientBrushProperties;
    }
*)

function D2D1PixelFormat(i_dxgiFormat:TDXGI_Format;i_AlphaMode:TD2D1_AlphaMode):TD2D1_PixelFormat;
begin
  Result.Format:=i_dxgiFormat;
  Result.AlphaMode:=i_AlphaMode;
end;

(*
    //
    // Bitmaps
    //
    D2D1FORCEINLINE
    D2D1_BITMAP_PROPERTIES
    BitmapProperties(
        CONST D2D1_PIXEL_FORMAT &pixelFormat = D2D1::PixelFormat(),
        FLOAT dpiX = 96.0f,
        FLOAT dpiY = 96.0f
        )
    {
        D2D1_BITMAP_PROPERTIES bitmapProperties;

        bitmapProperties.pixelFormat = pixelFormat;
        bitmapProperties.dpiX = dpiX;
        bitmapProperties.dpiY = dpiY;

        return bitmapProperties;
    }
*)

function D2D1RenderTargetProperties(i_Type:TD2D1_RenderTargetType;const i_PixelFormat:TD2D1_PixelFormat;i_DpiX:Single;i_DpiY:Single;
  i_Usage:TD2D1_RenderTargetUsage;i_MinLevel:TD2D1_FeatureLevel):TD2D1_RenderTargetProperties;
begin
  Result._Type:=i_Type;
  Result.PixelFormat:=i_PixelFormat;
  Result.DpiX:=i_DpiX;
  Result.DpiY:=i_DpiY;
  Result.Usage:=i_Usage;
  Result.MinLevel:=i_MinLevel;
end;

function D2D1HwndRenderTargetProperties(i_hWnd:HWND;i_PixelSize:TD2D1_SizeU;
  i_PresentOptions:TD2D1_PresentOptions):TD2D1_HwndRenderTargetProperties;
begin
  Result.hWnd:=i_hWnd;
  Result.PixelSize:=i_PixelSize;
  Result.PresentOptions:=i_PresentOptions;
end;

(*
    D2D1FORCEINLINE
    D2D1_LAYER_PARAMETERS
    LayerParameters(
        __in CONST D2D1_RECT_F &contentBounds = D2D1::InfiniteRect(),
        __in_opt ID2D1Geometry *geometricMask = NULL,
        D2D1_ANTIALIAS_MODE maskAntialiasMode = D2D1_ANTIALIAS_MODE_PER_PRIMITIVE,
        D2D1_MATRIX_3X2_F maskTransform = D2D1::IdentityMatrix(),
        FLOAT opacity = 1.0,
        __in_opt ID2D1Brush *opacityBrush = NULL,
        D2D1_LAYER_OPTIONS layerOptions = D2D1_LAYER_OPTIONS_NONE
        )
    {
        D2D1_LAYER_PARAMETERS layerParameters = { 0 };

        layerParameters.contentBounds = contentBounds;
        layerParameters.geometricMask = geometricMask;
        layerParameters.maskAntialiasMode = maskAntialiasMode;
        layerParameters.maskTransform = maskTransform;
        layerParameters.opacity = opacity;
        layerParameters.opacityBrush = opacityBrush;
        layerParameters.layerOptions = layerOptions;

        return layerParameters;
    }

    D2D1FORCEINLINE
    D2D1_DRAWING_STATE_DESCRIPTION
    DrawingStateDescription(
        D2D1_ANTIALIAS_MODE antialiasMode = D2D1_ANTIALIAS_MODE_PER_PRIMITIVE,
        D2D1_TEXT_ANTIALIAS_MODE textAntialiasMode = D2D1_TEXT_ANTIALIAS_MODE_DEFAULT,
        D2D1_TAG tag1 = 0,
        D2D1_TAG tag2 = 0,
        __in const D2D1_MATRIX_3X2_F &transform = D2D1::IdentityMatrix()
        )
    {
        D2D1_DRAWING_STATE_DESCRIPTION drawingStateDescription;

        drawingStateDescription.antialiasMode = antialiasMode;
        drawingStateDescription.textAntialiasMode = textAntialiasMode;
        drawingStateDescription.tag1 = tag1;
        drawingStateDescription.tag2 = tag2;
        drawingStateDescription.transform = transform;

        return drawingStateDescription;
    }
*)

const // Uses BGRA format.
  sc_RedShift:LongWord=16;
  sc_GreenShift:LongWord=8;
  sc_BlueShift:LongWord=0;
  //
  sc_RedMask:LongWord=$FF shl 16; // sc_RedShift;
  sc_GreenMask:LongWord=$FF shl 8; // sc_GreenShift;
  sc_BlueMask:LongWord=$FF shl 0; // sc_BlueShift;

function D2D1ColorF(r,g,b:Single;a:Single=1.0):TD2D1_ColorF;
begin
  Result.r:=r;
  Result.g:=g;
  Result.b:=b;
  Result.a:=a;
end;

function D2D1ColorF(rgb:LongWord;a:Single=1.0):TD2D1_ColorF;
// Construct a color, note that the alpha value from the "rgb" component is never used.
begin
  Result.r:=((rgb and sc_RedMask) shr sc_RedShift)/255.0;
  Result.g:=((rgb and sc_GreenMask) shr sc_GreenShift)/255.0;
  Result.b:=((rgb and sc_BlueMask) shr sc_BlueShift)/255.0;
  Result.a:=a;
end;

function D2D1ColorF(Color:TColor;a:Single=1.0):TD2D1_ColorF;
// Added by JSB: For compatibility with Delphi Graphics unit.
begin
  Result.r:=((Color and $000000FF))/255.0;
  Result.g:=((Color and $0000FF00) shr 8)/255.0;
  Result.b:=((Color and $00FF0000) shr 16)/255.0;
  Result.a:=a;
end;

function D2D1ColorF(Color:TD2D1_Color;a:Single=1.0):TD2D1_ColorF;
begin
  Result:=D2D1ColorF(LongWord(Color),a);
end;

function D2D1Matrix3x2F(_11,_12,_21,_22,_31,_32:Single):TD2D1_Matrix3X2F;
begin
  Result._11:=_11;
  Result._12:=_12;
  Result._21:=_21;
  Result._22:=_22;
  Result._31:=_31;
  Result._32:=_32;
end;

function D2D1Matrix3x2F_Translation(const i_X,i_Y:Single):TD2D1_Matrix3X2F;
begin
  Result._11:=1.0; Result._12:=0.0;
  Result._21:=0.0; Result._22:=1.0;
  Result._31:=i_X; Result._32:=i_Y;
end;

function D2D1Matrix3x2F_Translation(const i_Size:TD2D1_SizeF):TD2D1_Matrix3X2F;
begin
  Result:=D2D1Matrix3x2F_Translation(i_Size.Width,i_Size.Height);
end;

(*
    class Matrix3x2F : public D2D1_MATRIX_3X2_F
    {
    public:
        static D2D1FORCEINLINE
        Matrix3x2F
        Scale(
            D2D1_SIZE_F size,
            D2D1_POINT_2F center = D2D1::Point2F()
            )
        {
            Matrix3x2F scale;

            scale._11 = size.width; scale._12 = 0.0;
            scale._21 = 0.0; scale._22 = size.height;
            scale._31 = center.x - size.width * center.x;
            scale._32 = center.y - size.height * center.y;

            return scale;
        }

        static D2D1FORCEINLINE
        Matrix3x2F
        Scale(
            FLOAT x,
            FLOAT y,
            D2D1_POINT_2F center = D2D1::Point2F()
            )
        {
            return Scale(SizeF(x, y), center);
        }

        static D2D1FORCEINLINE
        Matrix3x2F
        Rotation(
            FLOAT angle,
            D2D1_POINT_2F center = D2D1::Point2F()
            )
        {
            Matrix3x2F rotation;

            D2D1MakeRotateMatrix(angle, center, &rotation);

            return rotation;
        }

        static D2D1FORCEINLINE
        Matrix3x2F
        Skew(
            FLOAT angleX,
            FLOAT angleY,
            D2D1_POINT_2F center = D2D1::Point2F()
            )
        {
            Matrix3x2F skew;

            D2D1MakeSkewMatrix(angleX, angleY, center, &skew);

            return skew;
        }

        //
        // Functions for convertion from the base D2D1_MATRIX_3X2_F to this type
        // without making a copy
        //
        static inline const Matrix3x2F* ReinterpretBaseType(const D2D1_MATRIX_3X2_F *pMatrix)
        {
            return static_cast<const Matrix3x2F *>(pMatrix);
        }

        static inline Matrix3x2F* ReinterpretBaseType(D2D1_MATRIX_3X2_F *pMatrix)
        {
            return static_cast<Matrix3x2F *>(pMatrix);
        }

        inline
        FLOAT
        Determinant() const
        {
            return (_11 * _22) - (_12 * _21);
        }

        inline
        bool
        IsInvertible() const
        {
            return !!D2D1IsMatrixInvertible(this);
        }

        inline
        bool
        Invert()
        {
            return !!D2D1InvertMatrix(this);
        }

        inline
        bool
        IsIdentity() const
        {
            return     _11 == 1.f && _12 == 0.f
                    && _21 == 0.f && _22 == 1.f
                    && _31 == 0.f && _32 == 0.f;
        }

        inline
        void SetProduct(
            const Matrix3x2F &a,
            const Matrix3x2F &b
            )
        {
            _11 = a._11 * b._11 + a._12 * b._21;
            _12 = a._11 * b._12 + a._12 * b._22;
            _21 = a._21 * b._11 + a._22 * b._21;
            _22 = a._21 * b._12 + a._22 * b._22;
            _31 = a._31 * b._11 + a._32 * b._21 + b._31;
            _32 = a._31 * b._12 + a._32 * b._22 + b._32;
        }

        D2D1FORCEINLINE
        Matrix3x2F
        operator*(
            const Matrix3x2F &matrix
            ) const
        {
            Matrix3x2F result;

            result.SetProduct(*this, matrix);

            return result;
        }

        D2D1FORCEINLINE
        D2D1_POINT_2F
        TransformPoint(
            D2D1_POINT_2F point
            ) const
        {
            D2D1_POINT_2F result =
            {
                point.x * _11 + point.y * _21 + _31,
                point.x * _12 + point.y * _22 + _32
            };

            return result;
        }
    };

    D2D1FORCEINLINE
    D2D1_POINT_2F
    operator*(
        const D2D1_POINT_2F &point,
        const D2D1_MATRIX_3X2_F &matrix
        )
    {
        return Matrix3x2F::ReinterpretBaseType(&matrix)->TransformPoint(point);
    }

} // namespace D2D1

D2D1FORCEINLINE
D2D1_MATRIX_3X2_F
operator*(
    const D2D1_MATRIX_3X2_F &matrix1,
    const D2D1_MATRIX_3X2_F &matrix2
    )
{
    return
        (*D2D1::Matrix3x2F::ReinterpretBaseType(&matrix1)) *
        (*D2D1::Matrix3x2F::ReinterpretBaseType(&matrix2));
}

*)

///////////////////////////////////////////////////////////////////////////////
// End "D2D1Helper.h"
///////////////////////////////////////////////////////////////////////////////

function D2D1_HResultToString(Value: HRESULT):String;
begin
  Result:='';
  if SUCCEEDED(Value) then Exit;
  case Value of
    D2DERR_WRONG_STATE: Result:='D2D: Wrong state.';
    D2DERR_NOT_INITIALIZED: Result:='D2D: Not initialized.';
    D2DERR_UNSUPPORTED_OPERATION: Result:='D2D: Unsupported operation.';
    D2DERR_UNSUPPORTED_PIXEL_FORMAT: Result:='D2D: Unsupported pixel format.';
    D2DERR_SCANNER_FAILED: Result:='D2D: Scanner failed.';
    D2DERR_SCREEN_ACCESS_DENIED: Result:='D2D: Screen access denied.';
    D2DERR_DISPLAY_STATE_INVALID: Result:='D2D: Display state invalid.';
    D2DERR_ZERO_VECTOR: Result:='D2D: Zero vector.';
    D2DERR_INTERNAL_ERROR: Result:='D2D: Internal error.';
    D2DERR_DISPLAY_FORMAT_NOT_SUPPORTED: Result:='D2D: Display format not supported.';
    D2DERR_INVALID_CALL: Result:='D2D: Invalid call.';
    D2DERR_NO_HARDWARE_DEVICE: Result:='D2D: No hardware device.';
    D2DERR_RECREATE_TARGET: Result:='D2D: Recreate target.';
    D2DERR_TOO_MANY_SHADER_ELEMENTS: Result:='D2D: Too many shader elements.';
    D2DERR_SHADER_COMPILE_FAILED: Result:='D2D: Shader compile failed.';
    D2DERR_MAX_TEXTURE_SIZE_EXCEEDED: Result:='D2D: Max texturesize exceeded.';
    D2DERR_UNSUPPORTED_VERSION: Result:='D2D: Unsupported version.';
    D2DERR_BAD_NUMBER: Result:='D2D: Bad number.';
    D2DERR_WRONG_FACTORY: Result:='D2D: Wrong factory.';
    D2DERR_LAYER_ALREADY_IN_USE: Result:='D2D: Layer already in use.';
    D2DERR_POP_CALL_DID_NOT_MATCH_PUSH: Result:='D2D: Pop call did not match push.';
    D2DERR_WRONG_RESOURCE_DOMAIN: Result:='D2D: Wrong resource domain.';
    D2DERR_PUSH_POP_UNBALANCED: Result:='D2D: Push/Pop unbalanced.';
    D2DERR_RENDER_TARGET_HAS_LAYER_OR_CLIPRECT: Result:='D2D: Render target has layer or clip rect.';
    D2DERR_INCOMPATIBLE_BRUSH_TYPES: Result:='D2D: Incompatible brush types.';
    D2DERR_WIN32_ERROR: Result:='D2D: Win32 error.';
    D2DERR_TARGET_NOT_GDI_COMPATIBLE: Result:='D2D: Target is not GDI compatible.';
    D2DERR_TEXT_EFFECT_IS_WRONG_TYPE: Result:='D2D: Text effect is of wrong type.';
    D2DERR_TEXT_RENDERER_NOT_RELEASED: Result:='D2D: Text rendered is not released.';
    D2DERR_EXCEEDS_MAX_BITMAP_SIZE: Result:='D2D: Max bitmap size is exceeded.';
    D2DERR_INSUFFICIENT_BUFFER: Result:='D2D: The supplied buffer is too small to accommodate the data.';
    D2DERR_INVALID_GRAPH_CONFIGURATION: Result:='D2D: A configuration error occurred in the graph.';
    D2DERR_INVALID_INTERNAL_GRAPH_CONFIGURATION: Result:='D2D: An internal configuration error occurred in the graph.';
    D2DERR_CYCLIC_GRAPH: Result:='D2D: A cycle occurred in the graph.';
    D2DERR_BITMAP_CANNOT_DRAW: Result:='D2D: You can''t draw with a bitmap that has the D2D1_BITMAP_OPTIONS_CANNOT_DRAW option.';
    D2DERR_OUTSTANDING_BITMAP_REFERENCES: Result:='D2D: The operation can''t complete while you have outstanding references to the target bitmap.';
    D2DERR_ORIGINAL_TARGET_NOT_BOUND: Result:='D2D: The operation failed because the original target isn''t currently bound as a target.';
    D2DERR_INVALID_TARGET: Result:='D2D: You can''t set the image as a target because it is either an effect or a bitmap that doesn''t have the D2D1_BITMAP_OPTIONS_TARGET option.';
    D2DERR_BITMAP_BOUND_AS_TARGET: Result:='D2D: You can''t draw with a bitmap that is currently bound as the target bitmap.';
    D2DERR_INSUFFICIENT_DEVICE_CAPABILITIES: Result:='D2D: The Direct3D device doesn''t have sufficient capabilities to perform the requested action.';
    D2DERR_INTERMEDIATE_TOO_LARGE: Result:='D2D: You can''t render the graph with the context''s current tiling settings.';
    D2DERR_EFFECT_IS_NOT_REGISTERED: Result:='D2D: The class ID of the specified effect is not registered by the operating system.';
    D2DERR_INVALID_PROPERTY: Result:='D2D: The specified property doesn''t exist.';
    D2DERR_NO_SUBPROPERTIES: Result:='D2D: The specified sub-property doesn''t exist.';
    D2DERR_PRINT_JOB_CLOSED: Result:='D2D: The application called ID2D1PrintControl::AddPage or ID2D1PrintControl::Close after the print job is already finished.';
    D2DERR_PRINT_FORMAT_NOT_SUPPORTED: Result:='D2D: This error occurs during print control creation (ID2D1Device::CreatePrintControl) to indicate that the Direct2D print control (ID2D1PrintControl) can''t support any of the package target types that represent printer formats.';
    D2DERR_TOO_MANY_TRANSFORM_INPUTS: Result:='D2D: An effect attempted to use a transform with too many inputs.';
  end;
end;

{$IFDEF UseRuntimeLinking}
function LoadDLL(DLLName:String):HModule;
begin
  Result:=LoadLibrary(PChar(DLLName));
  if Result=0 then
    raise Exception.Create('Dynamic link library (DLL) '''+DLLName+''' is not available.');
end;

function LinkMethod(hDLL:HModule;MethodName,DLLName:String):Pointer;
begin
  Result:=GetProcAddress(hDLL,PChar(MethodName));
  if Result=nil then
    raise Exception.Create('Failed to link to method '''+MethodName+''' in dynamic link library (DLL) '''+DLLName+'''.');
end;

procedure Link;
var
  hDLL_D2D1:HModule;
begin
  hDLL_D2D1:=LoadDLL(DLL_D2D1);

  D2D1CreateFactory:=LinkMethod(hDLL_D2D1,'D2D1CreateFactory',DLL_D2D1);
  D2D1MakeRotateMatrix:=LinkMethod(hDLL_D2D1,'D2D1MakeRotateMatrix',DLL_D2D1);
  D2D1MakeSkewMatrix:=LinkMethod(hDLL_D2D1,'D2D1MakeSkewMatrix',DLL_D2D1);
  D2D1IsMatrixInvertible:=LinkMethod(hDLL_D2D1,'D2D1IsMatrixInvertible',DLL_D2D1);
  D2D1InvertMatrix:=LinkMethod(hDLL_D2D1,'D2D1InvertMatrix',DLL_D2D1);
end;
{$ENDIF}

initialization
{$IFDEF UseRuntimeLinking}
  //Link;
{$ENDIF}

end.
