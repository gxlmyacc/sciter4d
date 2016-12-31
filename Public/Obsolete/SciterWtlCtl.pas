unit SciterWtlCtl;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, SciterIntf, Messages, SciterTypes;

type
  TWinToolForm = class(TForm)
  private
    FParentWND: HWND;
    FParentElement: IDomElement;
  protected
    procedure WMWindowPosChanging(var Msg: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;

    function GetParentElement: IDomElement; virtual;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(const AParent: IDomElement); reintroduce; virtual;
    destructor Destroy; override;

    property ParentElement: IDomElement read GetParentElement;
  end;

implementation

{$R *.dfm}

{ TWinToolForm }

constructor TWinToolForm.Create(const AParent: IDomElement);
begin
  FParentElement := AParent;    
  if FParentElement <> nil then
  begin
    FParentWND := FParentElement.GetElementHwnd();
  end;
    
  inherited Create(nil);
end;

procedure TWinToolForm.CreateParams(var Params: TCreateParams);
begin
  inherited;

  if FParentWND <> 0 then
    ParentWindow := FParentWND
  else
    raise Exception.Create('Parent Window not exist!');

  Params.WndParent := FParentWND
end;

destructor TWinToolForm.Destroy;
begin
  FParentElement := nil;
  inherited;
end;

function TWinToolForm.GetParentElement: IDomElement;
begin
  Result := FParentElement
end;

procedure TWinToolForm.WMWindowPosChanging(var Msg: TWMWindowPosChanging);
var
  rcWnd, rcEle: TRect;
begin
  //OutputDebugString(PChar(Format('WMWindowPosChanging: [%d, %d]',[Msg.WindowPos.cx, Msg.WindowPos.cy])));

  if FParentElement <> nil then
  with Msg do
  begin
    if not ((WindowPos.cx=0) or (WindowPos.cy=0)) and (WindowPos.flags and SWP_NOMOVE = 0) then
    begin
      GetWindowRect(FParentElement.GetElementHwnd, rcWnd);
      rcEle := FParentElement.GetLocation(ROOT_RELATIVE or PADDING_BOX);
      OffsetRect(rcEle, rcWnd.Left, rcWnd.Top);

//      OutputDebugString(PChar(Format('before [%d, %d][%d, %d] flags:%d',
//        [WindowPos.x, WindowPos.y, WindowPos.cx, WindowPos.cy, WindowPos.flags])));
//
//      OutputDebugString(PChar(Format('rcWnd: [%d, %d][%d, %d]',
//        [rcWnd.Left, rcWnd.top, rcWnd.Right-rcWnd.Left, rcWnd.Bottom - rcWnd.Top])));
//      OutputDebugString(PChar(Format('rcEle: [%d, %d][%d, %d]',
//        [rcEle.Left, rcEle.top, rcEle.Right-rcEle.Left, rcEle.Bottom - rcEle.Top])));

      WindowPos.x := rcEle.Left;
      WindowPos.y := rcEle.Top;

//      OutputDebugString(PChar(Format('after [%d, %d][%d, %d] flags:%d',
//        [WindowPos.x, WindowPos.y, WindowPos.cx, WindowPos.cy, WindowPos.flags])));
    end;

    if (WindowPos.x = Left) and (WindowPos.y = Top) and (WindowPos.cx = Width) and (WindowPos.cy = Height) then
    begin
      Result := 0;
      Exit;
    end;
  end;

  inherited;

  if FParentElement <> nil then
  begin
    if (Msg.WindowPos^.flags and SWP_SHOWWINDOW <> 0) and IsWindowVisible(FParentWND) and (not Visible) then
      Visible := True;
  end;
end;

end.
