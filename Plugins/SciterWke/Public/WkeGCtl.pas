unit WkeGCtl;

interface

uses
 SysUtils, Classes, Windows, Controls, Graphics, WkeIntf, Messages, WkeTypes;

type
  TWkeGraphicControl = class(TGraphicControl, IWkeWebBase)
  private
    FMouseEnter: Boolean;
    FDrawBuffer: TBitmap;
    FWebView: IWkeWebView;
    FOldParentWndProc: TWndMethod;
  protected
    procedure ParentWndProc(var Msg: TMessage);
    procedure SetParent(AParent: TWinControl); override;
    procedure WndProc(var Msg: TMessage); override;
    procedure Paint; override;
    procedure RequestAlign; override;

    function GetWindowName: WideString;
    function GetHwnd: HWND;
    function GetResourceInstance: THandle;
    function IWkeWebBase.GetBoundsRect = GetWkeBoundsRect;
    function GetWkeBoundsRect: TRect;
    function GetDrawRect: TRect;
    function GetDrawDC: HDC;
    procedure ReleaseDC(const ADC: HDC);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure LoadURL(const url: WideString);
    procedure LoadHTML(const html: WideString); overload;
    procedure LoadHTML(const html: PAnsiChar);  overload;
    procedure LoadFile(const filename: WideString);

    procedure StopLoading;
    procedure Reload;
    
    function IsLoading: Boolean;
    function IsLoaded: Boolean;
    function IsLoadFailed: Boolean;
    function IsLoadComplete: Boolean;
    function IsDocumentReady: Boolean;
    
    property WebView: IWkeWebView read FWebView;
  end;

implementation

{ TWkeGraphicControl }

constructor TWkeGraphicControl.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque, csParentBackground];
  FWebView := wke.CreateWebView(Self);
end;

destructor TWkeGraphicControl.Destroy;
begin
  FWebView := nil;
  if FDrawBuffer <> nil then
  begin
    FDrawBuffer.Free;
    FDrawBuffer := nil;
  end;
  inherited;
end;

function TWkeGraphicControl.GetDrawRect: TRect;
begin
  Result := Self.ClientRect;
end;

function TWkeGraphicControl.GetDrawDC: HDC;
var
  LCanvas: TControlCanvas;
begin
  if Parent <> nil then
  begin
    if FDrawBuffer <> nil then
    begin
      FDrawBuffer.Free;
      FDrawBuffer := nil;
    end;
    FDrawBuffer := TBitmap.Create;
    FDrawBuffer.PixelFormat := pf32bit;
    FDrawBuffer.Width := Self.ClientWidth;
    FDrawBuffer.Height := Self.ClientHeight;

    LCanvas := TControlCanvas.Create;
    try
      LCanvas.Control := Parent;       
      FDrawBuffer.Canvas.CopyRect(Self.ClientRect, LCanvas, Self.BoundsRect);
      //FDrawBuffer.SaveToFile('D:\123\'+FormatDateTime('hhnnsszzz', now) +'.bmp');
    finally
      LCanvas.Free;
    end;

    Result := FDrawBuffer.Canvas.Handle; 
  end
  else
    Result := GetDC(GetHwnd)
end;

procedure TWkeGraphicControl.ReleaseDC(const ADC: HDC);
begin
  if (FDrawBuffer <> nil) and (FDrawBuffer.Canvas.Handle = ADC) then
  begin
    Self.Invalidate;
  end
  else
    Windows.ReleaseDC(GetHwnd, ADC);
end;

function TWkeGraphicControl.GetHwnd: HWND;
begin
  if Parent <> nil then
    Result := Parent.Handle
  else
    Result := 0;
end;

function TWkeGraphicControl.GetResourceInstance: THandle;
begin
  Result := SysInit.HInstance;
end;

function TWkeGraphicControl.GetWindowName: WideString;
begin
  Result := Self.ClassName;
end;

function TWkeGraphicControl.IsDocumentReady: Boolean;
begin
  Result := FWebView.IsDocumentReady;
end;

function TWkeGraphicControl.IsLoadComplete: Boolean;
begin
  Result := FWebView.IsLoadComplete;
end;

function TWkeGraphicControl.IsLoaded: Boolean;
begin
  Result := FWebView.IsLoadSucceeded;
end;

function TWkeGraphicControl.IsLoadFailed: Boolean;
begin
  Result := FWebView.IsLoadFailed;
end;

function TWkeGraphicControl.IsLoading: Boolean;
begin
  Result := FWebView.IsLoading;
end;

procedure TWkeGraphicControl.LoadFile(const filename: WideString);
begin
  FWebView.LoadFile(filename);
end;

procedure TWkeGraphicControl.LoadHTML(const html: PAnsiChar);
begin
  FWebView.LoadHTML(html);
end;

procedure TWkeGraphicControl.LoadHTML(const html: WideString);
begin
  FWebView.LoadHTML(html);
end;

procedure TWkeGraphicControl.LoadURL(const url: WideString);
begin
  FWebView.LoadURL(url);
end;

procedure TWkeGraphicControl.Reload;
begin
  FWebView.Reload;
end;

procedure TWkeGraphicControl.SetParent(AParent: TWinControl);
begin
  if (AParent = nil) and (Parent <> nil) then
  begin
    Parent.WindowProc := FOldParentWndProc;  
    FOldParentWndProc := nil;
  end;

  inherited;
  
  if AParent <> nil then
  begin    
    AParent.DoubleBuffered := True;
    FOldParentWndProc := AParent.WindowProc;
    AParent.WindowProc := ParentWndProc;
  end;
end;

procedure TWkeGraphicControl.StopLoading;
begin
  FWebView.StopLoading;
end;

procedure TWkeGraphicControl.ParentWndProc(var Msg: TMessage);
var
  bHandle: Boolean;
begin
  if (Parent <> nil) and (FWebView <> nil) then
  begin
    bHandle := False;
    if FWebView.IsFocused then
      case Msg.Msg of
        WM_GETDLGCODE,
        WM_CHAR,
        WM_IME_COMPOSITION,
        WM_IME_STARTCOMPOSITION,
        WM_CONTEXTMENU,
        WM_KILLFOCUS,
        WM_ERASEBKGND,
        WM_NCPAINT,
        WM_PAINT:
          Msg.Result := FWebView.ProcND(Msg.Msg, Msg.WParam, Msg.LParam, bHandle);
      end;
    if FMouseEnter then
      case Msg.Msg of
        WM_SETCURSOR:
          Msg.Result := FWebView.ProcND(Msg.Msg, Msg.WParam, Msg.LParam, bHandle);
      end;
    if bHandle then
      Exit;
  end;
  
  if @FOldParentWndProc <> nil then
    FOldParentWndProc(Msg);
end;

procedure TWkeGraphicControl.RequestAlign;
begin
  inherited;
  if FWebView <> nil then
    FWebView.Resize(Self.ClientWidth, Self.ClientHeight);
end;

procedure TWkeGraphicControl.WndProc(var Msg: TMessage);
var
  bHandle: Boolean;
begin
  if FWebView <> nil then
  begin
    case Msg.Msg of
      CM_MOUSEENTER:
        FMouseEnter := True;
      CM_MOUSELEAVE:
        FMouseEnter := False;
      WM_LBUTTONDOWN:
      begin
        if not FWebView.IsFocused then
          FWebView.SetFocus;      
      end;
    end;
    bHandle := False;
    Msg.Result := FWebView.ProcND(Msg.Msg, Msg.WParam, Msg.LParam, bHandle);
    if bHandle and (Msg.Msg <> WM_LBUTTONDOWN) then
      Exit;
  end;
  inherited;
end;

procedure TWkeGraphicControl.Paint;
begin
  if FDrawBuffer = nil then
    Exit;

  Canvas.CopyRect(Self.ClientRect, FDrawBuffer.Canvas, GetDrawRect);
end;


function TWkeGraphicControl.GetWkeBoundsRect: TRect;
begin
  Result := Self.BoundsRect;
end;

end.
