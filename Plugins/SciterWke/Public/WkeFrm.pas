unit WkeFrm;

interface

uses
  Classes, SysUtils, Windows, Forms, WkeIntf, Controls, Messages;

type
  TWkeForm = class(TForm, IWkeWebBase)
  private
    FWebView: IWkeWebView;
    FDestroying: Boolean;
  private
    function GetIsTransparent: Boolean;
    procedure SetIsTransparent(const Value: Boolean);
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    procedure WndProc(var Msg: TMessage); override;
    
    function GetWindowName: WideString;
    function GetHwnd: HWND;
    function GetResourceInstance: THandle;
    function IWkeWebBase.GetBoundsRect = GetWkeBoundsRect;
    function GetWkeBoundsRect: TRect;
    function GetDrawRect: TRect;
    function GetDrawDC: HDC;
    procedure ReleaseDC(const ADC: HDC);
  public
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

    property IsTransparent: Boolean read GetIsTransparent write SetIsTransparent default True;
    property WebView: IWkeWebView read FWebView write FWebView;
  end;

implementation

{$R *.dfm}

{ TWkeForm }

procedure TWkeForm.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  if FWebView <> nil then
    FWebView.HostWindow := Self.WindowHandle;
end;

procedure TWkeForm.DestroyWindowHandle;
begin
  if FWebView <> nil then
    FWebView.HostWindow := 0;
  inherited;
end;

procedure TWkeForm.DoCreate;
begin
  FWebView := Wke.CreateWebView(Self);
  inherited;
end;

procedure TWkeForm.DoDestroy;
begin;
  FDestroying := True;
  FWebView := nil;
  inherited;
end;

function TWkeForm.GetDrawDC: HDC;
begin
  if FDestroying then
    Result := 0
  else
    Result := GetDC(GetHwnd);
end;

function TWkeForm.GetDrawRect: TRect;
begin
  Result := Self.ClientRect;
end;

function TWkeForm.GetHwnd: HWND;
begin
  if FDestroying then
    Result := 0
  else
    Result := Self.Handle;
end;

function TWkeForm.GetIsTransparent: Boolean;
begin
  Result := FWebView.Transparent;
end;

function TWkeForm.GetResourceInstance: THandle;
begin
  Result := SysInit.HInstance;
end;

function TWkeForm.GetWindowName: WideString;
begin
  Result := Self.ClassName;
end;

function TWkeForm.GetWkeBoundsRect: TRect;
begin
  Result := Self.GetClientRect;
end;

function TWkeForm.IsDocumentReady: Boolean;
begin
  Result := FWebView.IsDocumentReady;
end;

function TWkeForm.IsLoadComplete: Boolean;
begin
  Result := FWebView.IsLoadComplete;
end;

function TWkeForm.IsLoaded: Boolean;
begin
  Result := FWebView.IsLoadSucceeded;
end;

function TWkeForm.IsLoadFailed: Boolean;
begin
  Result := FWebView.IsLoadFailed;
end;

function TWkeForm.IsLoading: Boolean;
begin
  Result := FWebView.IsLoading;
end;

procedure TWkeForm.LoadFile(const filename: WideString);
begin
  FWebView.LoadFile(filename);
end;

procedure TWkeForm.LoadHTML(const html: PAnsiChar);
begin   
  FWebView.LoadHTML(html);
end;

procedure TWkeForm.LoadHTML(const html: WideString);
begin
  FWebView.LoadHTML(html);
end;

procedure TWkeForm.LoadURL(const url: WideString);
begin
  FWebView.LoadURL(url);
end;

procedure TWkeForm.ReleaseDC(const ADC: HDC);
begin
  if (not FDestroying) and (ADC > 0) then
    Windows.ReleaseDC(GetHwnd, ADC);
end;

procedure TWkeForm.Reload;
begin
  FWebView.Reload;
end;

procedure TWkeForm.SetIsTransparent(const Value: Boolean);
begin
  if FWebView.Transparent = Value then
    Exit;

  FWebView.Transparent := Value;
  
  if Value then
    SetWindowLong(GetHwnd, GWL_EXSTYLE, GetWindowLong(GetHwnd, GWL_EXSTYLE) or WS_EX_LAYERED)
  else
    SetWindowLong(GetHwnd, GWL_EXSTYLE, GetWindowLong(GetHwnd, GWL_EXSTYLE) or (not WS_EX_LAYERED));
end;

procedure TWkeForm.StopLoading;
begin
  FWebView.StopLoading;
end;

procedure TWkeForm.WndProc(var Msg: TMessage);
var
  bHandle: Boolean;
begin
  if FWebView <> nil then
  begin
    bHandle := False;
    Msg.Result := FWebView.ProcND(Msg.Msg, Msg.WParam, Msg.LParam, bHandle);
    if bHandle then
      Exit;
  end;

  inherited;
end;

end.
