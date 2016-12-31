unit Behavior.GDIDrawing;

interface

uses
  SysUtils, Windows, Classes, SciterIntf, SciterTypes, SciterBehavior, SciterGraphicIntf,
  TiscriptIntf;

type
  (*
    BEHAVIOR: gdi-drawing
      - draws content layer using GDI primitives.

    SAMPLE:
       See: samples/behaviors/gdi-drawing.htm
  *)

  TGDIDrawingBehavior = class(TBehaviorEventHandler)
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    function  OnDraw(const he: IDomElement; draw_type: UINT{DRAW_EVENTS}; var params: TDrawParams): Boolean; override;

    procedure DoDraw(hdc: HDC; width, height: Cardinal);
  end;
  
implementation

uses
  Math;

{ TGDIDrawingBehavior }

procedure TGDIDrawingBehavior.DoDraw(hdc: HDC; width, height: Cardinal);
var
  rc: TRect;
  hbr1,hbr2: HBRUSH;
begin
  rc := Rect(0, 0, width, height);
  hbr1 := CreateSolidBrush($000000);
  hbr2 := CreateSolidBrush($0000FF);
  // fill it by black color:
  FillRect(hdc, rc, hbr1);
  InflateRect(rc, -40, -40);
  FillRect(hdc, rc, hbr2);
  DeleteObject(hbr1);
  DeleteObject(hbr2);
end;

function TGDIDrawingBehavior.OnDraw(const he: IDomElement; draw_type: UINT;
  var params: TDrawParams): Boolean;
var
  w, h: Cardinal;
  buffer: ISciterDIB32;
  img: ISciterImage;
  gfx: ISciterGraphic;
begin
  if draw_type <> DRAW_CONTENT then   // drawing only content layer
  begin
    Result := False;
    Exit;
  end;
  w := params.area.Right - params.area.Left;
  h := params.area.Bottom - params.area.Top;
  buffer := CreateDIB32(w, h);
  try
    DoDraw(buffer.DC, w, h);
    img := CreateImageFromPixmap(w, h, False, buffer.Bytes);

    gfx := CreateGraphic(params.gfx);
    gfx.DrawImage(img.Handle, params.area.Left, params.area.Top);
  finally
    buffer := nil;
  end;
  Result := True;
end;

function TGDIDrawingBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_DRAW; // it does drawing
  Result := True;
end;

initialization


finalization
  BehaviorFactorys.UnReg('gdi-drawing');

end.
