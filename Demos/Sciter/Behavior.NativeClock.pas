unit Behavior.NativeClock;

interface

uses
  SysUtils, Windows, SciterIntf, SciterTypes, SciterBehavior, SciterGraphicIntf,
  SciterGraphicTypes;

type
  (*
  BEHAVIOR: native-clock
    - draws content layer using sciter-x-graphics.hpp primitives.

  SAMPLE:
     See: samples/behaviors/native-drawing.htm
  *)
  
  TNativeClockBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnTimer(const he: IDomElement): Boolean; override;
    function  OnDraw(const he: IDomElement; draw_type: UINT{DRAW_EVENTS}; var params: TDrawParams): Boolean; override;
  public
    // generation of Graphics.Path object on native side to be passed to script for drawing
    function nativeGetPath(x, y, w, h, t: Double; closed: Boolean): tiscript_value;
    function nativeImage(width, height: Cardinal): tiscript_value;
  end;

implementation

{ TNativeClockBehavior }

function TNativeClockBehavior.nativeGetPath(x, y, w, h, t: Double;
  closed: Boolean): tiscript_value;
var
  samples, sx, sy: array[0..5] of Single;
  dx: Single;
  i: Integer;
  p: ISciterGraphicPath;
begin
  dx := w / 5.0;

  samples[0] := (1+sin(t*1.2345+cos(t*0.33457)*0.44))*0.5;
  samples[1] := (1+sin(t*0.68363+cos(t*1.3)*1.55))*0.5;
  samples[2] := (1+sin(t*1.1642+cos(t*0.33457)*1.24))*0.5;
  samples[3] := (1+sin(t*0.56345+cos(t*1.63)*0.14))*0.5;
  samples[4] := (1+sin(t*1.6245+cos(t*0.254)*0.3))*0.5;
  samples[5] := (1+sin(t*0.345+cos(t*0.03)*0.6))*0.5;

  for i := 0 to 5 do
  begin
    sx[i] := x+i*dx;
    sy[i] := y+h*samples[i]*0.8;
  end;

  // creating path:
  p := CreatePath;

  p.MoveTo(sx[0], sy[0],false);
  for i := 1 to 5 do
    p.BezierCurveTo(sx[i-1]+dx*0.5,sy[i-1], sx[i]-dx*0.5,sy[i], sx[i],sy[i],false);

  if closed then
  begin
    p.LineTo(x+w,y+h,false);
    p.LineTo(x+0,y+h,false);
    p.ClosePath();
  end;

  // .line_to(points[n],points[n+1]);
 Result := p.Value; // wrap the path into sciter::value;
end;

procedure _image_paint_function(prm: Pointer; hgfx: HGFX; width, height: UINT); stdcall;
var
  gfx: ISciterGraphic;
begin
  gfx := CreateGraphic(hgfx);
  gfx.LineWidth(3);
  gfx.LineColor(RGBA(255, 0, 0));
  gfx.Line(0, 0, width, height);
  gfx.line(width, 0, 0, height);
end;

function TNativeClockBehavior.nativeImage(width,
  height: Cardinal): tiscript_value;
var
  b: array of Byte;
  img: ISciterImage;
begin
  SetLength(b, width * height * 4);
  FillMemory(b, width * height * 4, 127);

  img := CreateImageFromPixmap(width, height, false, PByte(b));
  img.Paint(_image_paint_function);

  Result := img.Value;
end;

procedure TNativeClockBehavior.OnAttached(const he: IDomElement);
begin
  he.StartTimer(1000);
end;

procedure TNativeClockBehavior.OnDetached(const he: IDomElement);
begin
  
end;

function TNativeClockBehavior.OnDraw(const he: IDomElement;
  draw_type: UINT; var params: TDrawParams): Boolean;
var
  w, h, scale: Single;
  rawtime: TDateTime;
  gfx: ISciterGraphic;
  i: Integer;
  msec, sec, min, hr: Word;
begin
  Result := False;
  if draw_type <> DRAW_CONTENT then
    Exit; // drawing only content layer

  try
    w := params.area.right - params.area.left;
    h := params.area.bottom - params.area.top;

    if w < h then
      scale := w / 300.0
    else
      scale := h / 300.0;

    rawtime := Now;

    gfx := CreateGraphic(params.gfx);
 
    gfx.Save();

    gfx.Translate(params.area.left + w / 2.0, params.area.top + h / 2.0);
    gfx.Scale(scale,scale);
    gfx.Rotate(-PI/2);
    gfx.LineColor(0);
    gfx.LineWidth(8.0);
    gfx.LineCap(SCITER_LINE_CAP_ROUND);
       
    // Hour marks
    gfx.Save();
      gfx.LineColor(RGBA($32, $5F, $A2));
      for i := 0 to 11 do
      begin
        gfx.Rotate(PI/6);
        gfx.Line(137.0, 0, 144.0, 0);
      end;
    gfx.Restore();

    // Minute marks
    gfx.Save();
      gfx.LineWidth(3.0);
      gfx.LineColor(RGBA($A5,$2A, $2A));
      for i := 0 to 59 do
      begin
        if  i mod 5 <> 0 then
          gfx.Line(143, 0, 146, 0);
        gfx.Rotate(PI/30.0);
      end;
    gfx.Restore();

    DecodeTime(rawtime, hr, min, sec, msec);

    hr := hr mod 12;
  
    // draw Hours
    gfx.Save();
      gfx.Rotate( hr*(PI/6) + (PI/360)*min + (PI/21600)*sec );
      gfx.LineWidth(14);
      gfx.LineColor(RGBA($32,$5F,$A2));
      gfx.Line(-20,0,70,0);
      gfx.Restore();

      // draw Minutes
      gfx.Save();
      gfx.Rotate( (PI/30)*min + (PI/1800)*sec );
      gfx.LineWidth(10);
      gfx.LineColor(RGBA($32,$5F,$A2));
      gfx.Line(-28,0,100,0);
    gfx.Restore();

    // draw seconds
    gfx.Save();
      gfx.Rotate(sec * PI/30);
      gfx.LineColor(RGBA($D4,0,0));
      gfx.FillColor(RGBA($D4,0,0));
      gfx.LineWidth(6);
      gfx.Line(-30,0,83,0);
      gfx.Ellipse(0,0,10,10);

      gfx.FillColor(0);
      gfx.Ellipse(95,0,10,10);
    gfx.Restore();

    gfx.Restore();

    Result := True;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[TNativeClockBehavior.OnDraw]'+E.Message));
    end
  end;
end;

function TNativeClockBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_DRAW      // it does drawing
                  or HANDLE_TIMER; // and handles timer
  Result := True;
end;

function TNativeClockBehavior.OnTimer(const he: IDomElement): Boolean;
begin
  he.Refresh;  // refresh element's area
  Result := True; // keep ticking
end;

initialization


finalization
  BehaviorFactorys.UnReg('native-clock');

end.
