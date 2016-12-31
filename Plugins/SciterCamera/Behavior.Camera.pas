unit Behavior.Camera;

interface
uses
  Windows, SysUtils, Classes, SciterIntf, SciterTypes, SciterBehavior, vfw;

type
  TCameraStreamBehavior = class(TBehaviorEventHandler)
  private
    FDevices: TStrings;
    rendering_site: PVideoDestination;
  protected
    function OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;

    function  OnVideoBindRQ(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; reason: UINT_PTR): Boolean; override;
  public
    constructor Create(const he: IDomElement); override; 
    destructor Destroy; override;
  published
    function Devices: IDomValue;
    function StreamFrom(const device: IDomValue): IDomValue; // either int (index) or string (name)
  end;
  
implementation

{ TCameraStreamBehavior }

constructor TCameraStreamBehavior.Create(const he: IDomElement);
begin
  inherited;
  FDevices := TStringList.Create;
end;

destructor TCameraStreamBehavior.Destroy;
begin
  if FDevices <> nil then
    FreeAndNil(FDevices);
  inherited;
end;

function TCameraStreamBehavior.Devices: IDomValue;
var
  iDeviceIndex: Integer;
  szDeviceName: array[0..80] of char;
  szDeviceVersion: array[0..80] of char;
begin
  FDevices.Clear;
  iDeviceIndex := 0;
  while capGetDriverDescription(iDeviceIndex, szDeviceName, sizeof(szDeviceName),
    szDeviceVersion, sizeof(szDeviceVersion)) do
  begin
    FDevices.Add(szDeviceName + szDeviceVersion);
    Result.Append(ValueFactory.Create(FDevices[iDeviceIndex]));
    Inc(iDeviceIndex);
  end;
end;

procedure TCameraStreamBehavior.OnAttached(const he: IDomElement);
begin
  inherited;

end;

procedure TCameraStreamBehavior.OnDetached(const he: IDomElement);
begin
  inherited;

end;

function TCameraStreamBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin               
  event_groups := HANDLE_ALL;
  Result := True;
end;

function TCameraStreamBehavior.OnVideoBindRQ(const he, target: IDomElement;
  _type: UINT; reason: UINT_PTR): Boolean;
begin
  Result := False;

  if not IsBubbling(_type) then
    Exit;
  if _type <> VIDEO_BIND_RQ then
    Exit;

  // we handle only VIDEO_BIND_RQ requests here
  if reason = 0 then
  begin
    Result := True; // first phase, consume the event to mark as we will provide frames
    Exit;
  end;

  if rendering_site <> nil then
    rendering_site.StopStreaming;
    
  rendering_site := PVideoDestination(reason);
  Result := True;
end;

function TCameraStreamBehavior.StreamFrom(
  const device: IDomValue): IDomValue;
var
  iDeviceIndex: Integer;
  bResult: Boolean;
begin
  if rendering_site <> nil then
    rendering_site.StopStreaming;

  iDeviceIndex := -1;
  if device.IsInt then
    iDeviceIndex := device.AsInteger(-1)
  else
  if device.IsString then
    iDeviceIndex := FDevices.IndexOf(device.AsString());
  if iDeviceIndex < 0 then
  begin
    Result.SetAsBool(False);
    Exit;
  end;

  bResult := capDriverConnect(FCaphwnd, DriveID);
  capGetStatus(FCaphwnd, @CapStatus, sizeof(CAPSTATUS));
  FWidth := CapStatus.uiImageWidth;
  FHeight := CapStatus.uiImageHeight;
  SetWindowPos(FCaphwnd, 0, 0, 0, FWidth, FHeight, SWP_NOZORDER or SWP_NOMOVE);

  capPreviewRate(FCaphwnd, 66); //set preview rate to 66 miliseconds

  vfw.capOverlay(FCaphwnd, true);
  capPreview(FCaphwnd, true);
  capPreviewScale(FCaphwnd, FScale);
  

  Result.SetAsBool(True);
end;

end.
