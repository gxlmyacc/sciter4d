unit SciterChildFrm;

interface

uses
  Windows, Classes, Controls, Forms, SciterIntf, Messages;

type
  TSciterChildForm = class(TForm)
  private
    FLastRect: TRect;
    FElement: IDomElement;
    FRefreshWndPosTimerId: Cardinal;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
  public
    constructor Create(AOwner: TComponent; const AElement: IDomElement = nil); reintroduce; virtual;
    destructor Destroy; override;

    property Element: IDomElement read FElement;
  end;

implementation

{$R *.dfm}

procedure _RefreshWndPosTimerProc(hwnd:HWND; uMsg: Cardinal; AForm: TSciterChildForm; dwTime: DWORD); stdcall;
  function GetClientLocation: TRect;
  var
    pt: TPoint;
  begin
    pt.X := 0;
    pt.Y  := 0;
    Windows.ClientToScreen(AForm.FElement.GetElementHwnd, pt);
    Result := AForm.FElement.GetLocation(0);
    OffsetRect(Result, pt.X, pt.Y);
  end;
var
  rc: TRect;
begin
  if AForm.FElement = nil then Exit;
  if not AForm.FElement.IsValid then Exit;
  rc := GetClientLocation;
  if IsRectEmpty(rc) or IsIconic(AForm.FElement.GetElementHwnd) or (not AForm.FElement.IsVisible) then
    AForm.Visible := False
  else
  begin
    if not AForm.Visible then
      AForm.Visible := True;
    AForm.Enabled := AForm.FElement.IsEnable;
    if EqualRect(AForm.FLastRect, rc) then
      Exit;
    SetWindowPos(AForm.Handle, AForm.FElement.GetElementHwnd,
      rc.Left, rc.Top, rc.Right-rc.Left, rc.Bottom-rc.Top, SWP_SHOWWINDOW);
  end;
  AForm.FLastRect := rc;
end;

{ TSciterChildForm }

constructor TSciterChildForm.Create(AOwner: TComponent; const AElement: IDomElement);
begin
  FElement := AElement;
  inherited Create(AOwner);
end;

procedure TSciterChildForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if FElement <> nil then
  begin
    Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE {or WS_EX_COMPOSITED} and (not WS_EX_APPWINDOW);
    Params.WndParent := FElement.GetElementHwnd();
  end;
end;

destructor TSciterChildForm.Destroy;
begin
  FElement := nil;
  inherited;
end;

procedure TSciterChildForm.WndProc(var Message: TMessage);
begin
  inherited;
  if FElement <> nil then
    case message.Msg of
      WM_NCACTIVATE:
      begin
        if (TWMActivate(Message).Active = WA_ACTIVE) and IsWindow(TWMActivate(Message).ActiveWindow) then
          message.Result := SendMessage(TWMActivate(Message).ActiveWindow, WM_NCACTIVATE, 1, 0);
      end;
      WM_MOUSEACTIVATE:
        Message.Result := MA_NOACTIVATE;
    end;
end;

procedure TSciterChildForm.DoCreate;
begin
  inherited;
  if FElement <> nil then
    FRefreshWndPosTimerId := SetTimer(Self.Handle, Cardinal(Self), 10, @_RefreshWndPosTimerProc);
end;

procedure TSciterChildForm.DoDestroy;
begin
  inherited;
  if FRefreshWndPosTimerId <> 0 then
    KillTimer(Self.Handle, FRefreshWndPosTimerId);
end;

end.
