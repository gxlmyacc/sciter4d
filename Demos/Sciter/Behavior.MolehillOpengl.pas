unit Behavior.MolehillOpengl;

interface

uses
  SysUtils, Windows, Classes, SciterIntf, SciterTypes, SciterBehavior, SciterGraphicIntf,
  TiscriptIntf, SyncObjs, OpenGL;

type
  PContext = ^TContext;
  TContext = record
    hwnd: HWND;
    mainGLRC: HGLRC;
    done: Boolean;
    event_draw: TEvent;
  end;

  TMolehillOpenglBehavior = class(TBehaviorEventHandler)
  private
    FContext: PContext;
  protected
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;

    function  OnDraw(const he: IDomElement; draw_type: UINT{DRAW_EVENTS}; var params: TDrawParams): Boolean; override;
  end;

implementation

procedure opengl_thread(ctx: PContext);
var
  hdc: Windows.HDC;
  hglrc: Windows.HGLRC;
begin
  hdc := GetDC(ctx.hwnd);
  hglrc := wglCreateContext(hdc); 

  wglShareLists(ctx.mainGLRC,hglrc);

  // make it the calling thread's current rendering context 
  wglMakeCurrent(hdc, hglrc);

  //Set up the orthographic projection so that coordinates (0, 0) are in the top left
  //and the minimum and maximum depth is -10 and 10. To enable depth just put in
  //glEnable(GL_DEPTH_TEST)
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(0, 640, 480, 0, -10, 10);

  //Back to the modelview so we can draw stuff 
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //Clear the screen and depth buffer

  while True do
  begin
    ctx.event_draw.WaitFor(INFINITE);
    if (ctx.done) then
     break;
    if not IsWindow(ctx.hwnd) then
     break;

    wglMakeCurrent(hdc, hglrc); // ?

    //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glPushMatrix();         //Make sure our transformations don't affect any other transformations in other code
    glTranslatef(0, 0, 10);  //Translate rectangle to its assigned x and y position
                            //Put other transformations here
    glBegin(GL_QUADS);      //We want to draw a quad, i.e. shape with four sides
    glColor3f(1, 0, 0);     //Set the colour to red 
    glVertex2f(0, 0);       //Draw the four corners of the rectangle
    glVertex2f(0, 480);
    glVertex2f(640,480);
    glVertex2f(640, 0);
    glEnd();
    glPopMatrix();

    glFlush();
  end;

  // make the rendering context not current  
  wglMakeCurrent(0, 0);
  // delete the rendering context  
  wglDeleteContext(hglrc);

  ReleaseDC(ctx.hwnd,hdc);

  ctx.event_draw.Free;
  Dispose(ctx);
end;

{ TMolehillOpenglBehavior }

procedure TMolehillOpenglBehavior.OnAttached(const he: IDomElement);
var
  hThread, tid: Cardinal;
begin
  New(FContext);
  FContext.hwnd := he.GetElementHwnd(true);
  FContext.mainGLRC := wglGetCurrentContext();
  FContext.event_draw := TSimpleEvent.Create;

  hThread := BeginThread(nil, 0, @opengl_thread, FContext, 0, tid);
  CloseHandle(hThread);
end;

procedure TMolehillOpenglBehavior.OnDetached(const he: IDomElement);
begin
  FContext.done := true;
  FContext.event_draw.SetEvent;
  FContext := nil;
end;

function TMolehillOpenglBehavior.OnDraw(const he: IDomElement;
  draw_type: UINT; var params: TDrawParams): Boolean;
begin
  Result := False;
  if params.cmd <>  DRAW_CONTENT then Exit; // drawing only content layer

  FContext.event_draw.SetEvent;
  //ctx->event_draw_complete.wait();

  Result := true; // done drawing
end;

function TMolehillOpenglBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_DRAW;
  Result := True;
end;

initialization


finalization
  BehaviorFactorys.UnReg('molehill-opengl');

end.
