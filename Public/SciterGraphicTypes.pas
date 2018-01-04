{*******************************************************************************
 标题:     SciterGraphicIntf.pas
 描述:     sciter绘图相关类型
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterGraphicTypes;

interface

{$I Sciter.inc}

uses
  Windows, SciterTypes;

type
  SC_REAL      = Single;
  SC_POS       = SC_REAL;  // position
  SC_DIM       = SC_REAL;  // dimension
  SC_ANGLE     = SC_REAL;  // angle (radians)
  SC_COLOR     = UINT;          // COLOR

  PSC_POS      = ^SC_POS;
  PSC_DIM      = ^SC_DIM;
  PSC_COLOR    = ^SC_COLOR;

  SC_DIM_ARRAY8 = array[0..7] of SC_DIM;
  PSC_DIM_ARRAY8 = ^SC_DIM_ARRAY8;

  SC_COLOR_STOP = packed record
    color:  SC_COLOR;
    offset: Single; // 0.0 ... 1.0
  end;
  TColorStop = SC_COLOR_STOP;
  PColorStop = ^TColorStop;

  GRAPHIN_RESULT = (
    GRAPHIN_PANIC = -1, // e.g. not enough memory
    GRAPHIN_OK = 0,
    GRAPHIN_BAD_PARAM = 1,  // bad parameter
    GRAPHIN_FAILURE = 2,    // operation failed, e.g. restore() without save()
    GRAPHIN_NOTSUPPORTED = 3 // the platform does not support requested feature
  );
  TGraphinResult = GRAPHIN_RESULT;

  DRAW_PATH_MODE = (
    DRAW_FILL_ONLY = 1,
    DRAW_STROKE_ONLY = 2,
    DRAW_FILL_AND_STROKE = 3
  );
  TDrawPathMode = DRAW_PATH_MODE;

  SCITER_LINE_JOIN_TYPE = (
    SCITER_JOIN_MITER = 0,
    SCITER_JOIN_ROUND = 1,
    SCITER_JOIN_BEVEL = 2,
    SCITER_JOIN_MITER_OR_BEVEL = 3
  );
  TSciterLineJoinType = SCITER_LINE_JOIN_TYPE;

  SCITER_LINE_CAP_TYPE = (
    SCITER_LINE_CAP_BUTT = 0,
    SCITER_LINE_CAP_SQUARE = 1,
    SCITER_LINE_CAP_ROUND = 2
  );
  TSciterLineCapType = SCITER_LINE_CAP_TYPE;

  SCITER_TEXT_ALIGNMENT = (
    TEXT_ALIGN_DEFAULT,
    TEXT_ALIGN_START,
    TEXT_ALIGN_END,
    TEXT_ALIGN_CENTER
  );
  TSciterTextAlignment = SCITER_TEXT_ALIGNMENT;

  SCITER_TEXT_DIRECTION = (
    TEXT_DIRECTION_DEFAULT,
    TEXT_DIRECTION_LTR,
    TEXT_DIRECTION_RTL,
    TEXT_DIRECTION_TTB
  );
  TSciterTextDirection = SCITER_TEXT_DIRECTION;


  SCITER_IMAGE_ENCODING = (
    SCITER_IMAGE_ENCODING_RAW, // [a,b,g,r,a,b,g,r,...] vector
    SCITER_IMAGE_ENCODING_PNG,
    SCITER_IMAGE_ENCODING_JPG,
    SCITER_IMAGE_ENCODING_WEBP
  );
  TSciterImageEncoding = SCITER_IMAGE_ENCODING;

  SCITER_TEXT_FORMAT = packed record
    fontFamily:       LPWSTR;
    fontWeight:       UINT; // 100...900, 400 - normal, 700 - bold
    fontItalic:       LongBool;
    fontSize:         Single;   // dips
    lineHeight:       Single;   // dips
    textDirection:    SCITER_TEXT_DIRECTION;
    textAlignment:    SCITER_TEXT_ALIGNMENT; // horizontal alignment
    lineAlignment:    SCITER_TEXT_ALIGNMENT; // a.k.a. vertical alignment for roman writing systems
    localeName:       LPWSTR;
  end;
  TSciterTextFormat = SCITER_TEXT_FORMAT;
  PSciterTextFormat = ^TSciterTextFormat;

  // imageSave callback:
  image_write_function = function(prm: Pointer; const data: PByte; data_length: UINT): LongBool; stdcall;
  // imagePaint callback:
  image_paint_function = procedure(prm: Pointer; hgfx: HGFX; width, height: UINT); stdcall;


implementation

end.
