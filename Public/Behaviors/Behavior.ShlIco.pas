unit Behavior.ShlIco;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior, Messages, Graphics;

type
  //css -icon-size:"jumbo";
  TShellIconBehavior = class(TBehaviorEventHandler)
  protected
   function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
   function  OnDraw(const he: IDomElement; draw_type: UINT; hdc: PSciterGraphics; const rc: TRect): Boolean; override;
  end;


  TShellIconBehaviorFactory = class(TBehaviorFactory)
  public
    function CreateHandler(const he: IDomElement): IBehaviorEventHandler; override;
  end;

implementation

uses
  ShellAPI;

{ TShellIconBehavior }

function TShellIconBehavior.OnDraw(const he: IDomElement;
  draw_type: UINT; hdc: PSciterGraphics; const rc: TRect): Boolean;
var
  filename, size: string;
  psfi: TSHFileInfo;
  uFlags: UINT;
  icon: TIcon;
  x, y: Integer;
  canvas: TCanvas;
begin
  Result := False;

  if draw_type = DRAW_FOREGROUND then
  begin
    filename := he.Attributes['filename'];
    if filename = EmptyStr then
      Exit;
    size := LowerCase(he.Attributes['icon-size']);
    if size = EmptyStr then
      size := 'extraLarge';

    uFlags := SHGFI_USEFILEATTRIBUTES;
    if size = 'large' then
      uFlags := uFlags or SHGFI_LARGEICON
    else
    if size = 'small' then
      uFlags := uFlags or SHGFI_SMALLICON
    else
    if size = 'extralarge' then
      uFlags := uFlags or SHGFI_OPENICON
    else
    if size = 'syssmall' then
      uFlags := uFlags or  3(*_SHIL_SYSSMALL*)
    else
    if size = 'jumbo' then
      uFlags := uFlags or SHGFI_SHELLICONSIZE;

    if SHGetFileInfo(PChar(filename), SHGFI_USEFILEATTRIBUTES or SHGFI_SYSICONINDEX,
      psfi, SizeOf(psfi), uFlags) <> 0 then
      Exit;

    if psfi.hIcon > 0 then
    begin
      icon := TIcon.Create;
      canvas := TCanvas.Create;
      try
        canvas.Handle := Windows.HDC(hdc);
        icon.Handle := psfi.hIcon;

        x := rc.left + (rc.right - rc.left - icon.Width) div 2;
        y := rc.top + (rc.bottom - rc.top - icon.Height) div 2;

        SetBkMode(canvas.Handle, TRANSPARENT);

        canvas.Draw(x, y, icon);
      finally
        canvas.Free;
        icon.Free;
      end;

      Result := True; 
    end;
  end;
end;

function TShellIconBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_DRAW;
  Result := True;
end;

{ TShellIconBehaviorFactory }

function TShellIconBehaviorFactory.CreateHandler(
  const he: IDomElement): IBehaviorEventHandler;
begin
  Result := TShellIconBehavior.Create;
end;

initialization
  BehaviorFactorys.Reg(TShellIconBehaviorFactory.Create('shellicon'));

finalization

end.
