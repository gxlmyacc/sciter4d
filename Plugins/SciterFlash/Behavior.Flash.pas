unit Behavior.Flash;

interface

uses
  SysUtils, Windows, Behavior.ActiveX, ActiveX, SciterTypes, SciterIntf;

type
  IShockwaveFlash = interface(IDispatch)
    ['{D27CDB6C-AE6D-11CF-96B8-444553540000}']
    function Get_ReadyState: Integer; safecall;
    function Get_TotalFrames: Integer; safecall;
    function Get_Playing: WordBool; safecall;
    procedure Set_Playing(pVal: WordBool); safecall;
    function Get_Quality: SYSINT; safecall;
    procedure Set_Quality(pVal: SYSINT); safecall;
    function Get_ScaleMode: SYSINT; safecall;
    procedure Set_ScaleMode(pVal: SYSINT); safecall;
    function Get_AlignMode: SYSINT; safecall;
    procedure Set_AlignMode(pVal: SYSINT); safecall;
    function Get_BackgroundColor: Integer; safecall;
    procedure Set_BackgroundColor(pVal: Integer); safecall;
    function Get_Loop: WordBool; safecall;
    procedure Set_Loop(pVal: WordBool); safecall;
    function Get_Movie: WideString; safecall;
    procedure Set_Movie(const pVal: WideString); safecall;
    function Get_FrameNum: Integer; safecall;
    procedure Set_FrameNum(pVal: Integer); safecall;
    procedure SetZoomRect(left: Integer; top: Integer; right: Integer; bottom: Integer); safecall;
    procedure Zoom(factor: SYSINT); safecall;
    procedure Pan(x: Integer; y: Integer; mode: SYSINT); safecall;
    procedure Play; safecall;
    procedure Stop; safecall;
    procedure Back; safecall;
    procedure Forward; safecall;
    procedure Rewind; safecall;
    procedure StopPlay; safecall;
    procedure GotoFrame(FrameNum: Integer); safecall;
    function CurrentFrame: Integer; safecall;
    function IsPlaying: WordBool; safecall;
    function PercentLoaded: Integer; safecall;
    function FrameLoaded(FrameNum: Integer): WordBool; safecall;
    function FlashVersion: Integer; safecall;
    function Get_WMode: WideString; safecall;
    procedure Set_WMode(const pVal: WideString); safecall;
    function Get_SAlign: WideString; safecall;
    procedure Set_SAlign(const pVal: WideString); safecall;
    function Get_Menu: WordBool; safecall;
    procedure Set_Menu(pVal: WordBool); safecall;
    function Get_Base: WideString; safecall;
    procedure Set_Base(const pVal: WideString); safecall;
    function Get_Scale: WideString; safecall;
    procedure Set_Scale(const pVal: WideString); safecall;
    function Get_DeviceFont: WordBool; safecall;
    procedure Set_DeviceFont(pVal: WordBool); safecall;
    function Get_EmbedMovie: WordBool; safecall;
    procedure Set_EmbedMovie(pVal: WordBool); safecall;
    function Get_BGColor: WideString; safecall;
    procedure Set_BGColor(const pVal: WideString); safecall;
    function Get_Quality2: WideString; safecall;
    procedure Set_Quality2(const pVal: WideString); safecall;
    procedure LoadMovie(layer: SYSINT; const url: WideString); safecall;
    procedure TGotoFrame(const target: WideString; FrameNum: Integer); safecall;
    procedure TGotoLabel(const target: WideString; const label_: WideString); safecall;
    function TCurrentFrame(const target: WideString): Integer; safecall;
    function TCurrentLabel(const target: WideString): WideString; safecall;
    procedure TPlay(const target: WideString); safecall;
    procedure TStopPlay(const target: WideString); safecall;
    procedure SetVariable(const name: WideString; const value: WideString); safecall;
    function GetVariable(const name: WideString): WideString; safecall;
    procedure TSetProperty(const target: WideString; property_: SYSINT; const value: WideString); safecall;
    function TGetProperty(const target: WideString; property_: SYSINT): WideString; safecall;
    procedure TCallFrame(const target: WideString; FrameNum: SYSINT); safecall;
    procedure TCallLabel(const target: WideString; const label_: WideString); safecall;
    procedure TSetPropertyNum(const target: WideString; property_: SYSINT; value: Double); safecall;
    function TGetPropertyNum(const target: WideString; property_: SYSINT): Double; safecall;
    function TGetPropertyAsNumber(const target: WideString; property_: SYSINT): Double; safecall;
    function Get_SWRemote: WideString; safecall;
    procedure Set_SWRemote(const pVal: WideString); safecall;
    function Get_FlashVars: WideString; safecall;
    procedure Set_FlashVars(const pVal: WideString); safecall;
    function Get_AllowScriptAccess: WideString; safecall;
    procedure Set_AllowScriptAccess(const pVal: WideString); safecall;
    function Get_MovieData: WideString; safecall;
    procedure Set_MovieData(const pVal: WideString); safecall;
    function Get_InlineData: IUnknown; safecall;
    procedure Set_InlineData(const ppIUnknown: IUnknown); safecall;
    function Get_SeamlessTabbing: WordBool; safecall;
    procedure Set_SeamlessTabbing(pVal: WordBool); safecall;
    procedure EnforceLocalSecurity; safecall;
    function Get_Profile: WordBool; safecall;
    procedure Set_Profile(pVal: WordBool); safecall;
    function Get_ProfileAddress: WideString; safecall;
    procedure Set_ProfileAddress(const pVal: WideString); safecall;
    function Get_ProfilePort: Integer; safecall;
    procedure Set_ProfilePort(pVal: Integer); safecall;
    function CallFunction(const request: WideString): WideString; safecall;
    procedure SetReturnValue(const returnValue: WideString); safecall;
    procedure DisableLocalSecurity; safecall;
    function Get_AllowNetworking: WideString; safecall;
    procedure Set_AllowNetworking(const pVal: WideString); safecall;
    function Get_AllowFullScreen: WideString; safecall;
    procedure Set_AllowFullScreen(const pVal: WideString); safecall;
    function Get_AllowFullScreenInteractive: WideString; safecall;
    procedure Set_AllowFullScreenInteractive(const pVal: WideString); safecall;
    function Get_IsDependent: WordBool; safecall;
    procedure Set_IsDependent(pVal: WordBool); safecall;
    function Get_BrowserZoom: WideString; safecall;
    procedure Set_BrowserZoom(const pVal: WideString); safecall;
    property ReadyState: Integer read Get_ReadyState;
    property TotalFrames: Integer read Get_TotalFrames;
    property Playing: WordBool read Get_Playing write Set_Playing;
    property Quality: SYSINT read Get_Quality write Set_Quality;
    property ScaleMode: SYSINT read Get_ScaleMode write Set_ScaleMode;
    property AlignMode: SYSINT read Get_AlignMode write Set_AlignMode;
    property BackgroundColor: Integer read Get_BackgroundColor write Set_BackgroundColor;
    property Loop: WordBool read Get_Loop write Set_Loop;
    property Movie: WideString read Get_Movie write Set_Movie;
    property FrameNum: Integer read Get_FrameNum write Set_FrameNum;
    property WMode: WideString read Get_WMode write Set_WMode;
    property SAlign: WideString read Get_SAlign write Set_SAlign;
    property Menu: WordBool read Get_Menu write Set_Menu;
    property Base: WideString read Get_Base write Set_Base;
    property Scale: WideString read Get_Scale write Set_Scale;
    property DeviceFont: WordBool read Get_DeviceFont write Set_DeviceFont;
    property EmbedMovie: WordBool read Get_EmbedMovie write Set_EmbedMovie;
    property BGColor: WideString read Get_BGColor write Set_BGColor;
    property Quality2: WideString read Get_Quality2 write Set_Quality2;
    property SWRemote: WideString read Get_SWRemote write Set_SWRemote;
    property FlashVars: WideString read Get_FlashVars write Set_FlashVars;
    property AllowScriptAccess: WideString read Get_AllowScriptAccess write Set_AllowScriptAccess;
    property MovieData: WideString read Get_MovieData write Set_MovieData;
    property InlineData: IUnknown read Get_InlineData write Set_InlineData;
    property SeamlessTabbing: WordBool read Get_SeamlessTabbing write Set_SeamlessTabbing;
    property Profile: WordBool read Get_Profile write Set_Profile;
    property ProfileAddress: WideString read Get_ProfileAddress write Set_ProfileAddress;
    property ProfilePort: Integer read Get_ProfilePort write Set_ProfilePort;
    property AllowNetworking: WideString read Get_AllowNetworking write Set_AllowNetworking;
    property AllowFullScreen: WideString read Get_AllowFullScreen write Set_AllowFullScreen;
    property AllowFullScreenInteractive: WideString read Get_AllowFullScreenInteractive write Set_AllowFullScreenInteractive;
    property IsDependent: WordBool read Get_IsDependent write Set_IsDependent;
    property BrowserZoom: WideString read Get_BrowserZoom write Set_BrowserZoom;
  end;

  TFlashBehavior = class(TActiveXBehavior)
  protected
    procedure DoInitObject(const AObject: IOleObject); override;
    procedure DoPaintInstall(const dc: HDC; const ARect: TRect;
      const BufBits: Pointer; BufLen: Cardinal); override;
    procedure DoPaintNotInstall(const dc: HDC; const ARect: TRect;
      const BufBits: Pointer; BufLen: Cardinal); override;
  public
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnTimerEx(const he: IDomElement; extTimerId: UINT_PTR): Boolean; override;

    function  IsTransparent: Boolean;
    function  IsWindowless: Boolean; override;
  published
    function flash: IShockwaveFlash;
  end;

implementation

uses
  StrUtils;

const
  DEFAULT_TIMERID       = 20;
type
  TColor32 = record
    b, g, r, a: Byte;
  end;
  PColor32 = ^TColor32;

{ TFlashBehavior }

procedure TFlashBehavior.DoInitObject(const AObject: IOleObject);
var
  sSrc, sBase: string;
begin
  sBase := Sciter.DecodeURI(This.CombineURL('a'));
  if AnsiStartsText('file://', sBase) then
  begin
    sBase :=  Copy(sBase, 8, MaxInt);
    Flash.Base := StringReplace(ExtractFileDir(StringReplace(sBase, '/', '\', [rfReplaceAll])), '\', '/', [rfReplaceAll]);
  end;
  if This.IndexOfAttribute('src') >= 0 then
  begin
    sSrc := Sciter.DecodeURI(This.CombineURL(This.Attributes['src']));
    if AnsiStartsText('file://', sSrc) then
    begin
      sSrc :=  Copy(sSrc, 8, MaxInt);
      Flash.Movie := sSrc;
    end;
  end;

  Flash.WMode := This.Attributes['wmode'];
  Flash.DisableLocalSecurity;
  Flash.AllowScriptAccess := 'always';
  Flash.FlashVars := This.Attributes['flashVars'];
  flash.Scale := This.Attributes['scale'];
end;

function _image_write_function(prm: LPVOID; const data: PByte; data_length: UINT): LongBool; stdcall;
begin
  CopyMemory(prm, data, data_length);
  Result := True;
end;

procedure TFlashBehavior.DoPaintInstall(const dc: HDC; const ARect: TRect;
  const BufBits: Pointer; BufLen: Cardinal);
var
  s: PAnsiChar;
  i: Integer;
begin
  inherited;
  if not IsTransparent then
  begin
    s := BufBits;
    for i := 0 to BufLen div 4 - 1 do
    begin
      s[3] := #255;
      Inc({$IF CompilerVersion > 18.5}NativeInt{$ELSE}Integer{$IFEND}(s), 4);
    end;
  end;
end;

procedure TFlashBehavior.DoPaintNotInstall(const dc: HDC;
  const ARect: TRect; const BufBits: Pointer; BufLen: Cardinal);
const
  PROMPT_NotInstall: WideString = '请安装最新的flashplayer插件！';
var
  s: PAnsiChar;
  i: Integer;
  szText: TSize;
  hbr: HBRUSH;
begin
  try
    hbr := CreateSolidBrush($00333432);
    try
      FrameRect(dc, ARect, hbr);
    finally
      DeleteObject(hbr);
    end;
    szText.cx := 0;
    szText.cy := 0;
    GetTextExtentPoint32W(dc, PWideChar(PROMPT_NotInstall), Length(PROMPT_NotInstall), szText);
    TextOutW(dc,
      (ARect.Right-ARect.Left-szText.cx) div 2, (ARect.Bottom-ARect.top-szText.cy) div 2,
      PWideChar(PROMPT_NotInstall), Length(PROMPT_NotInstall));
    //设置背景不透明
    s := BufBits;
    for i := 0 to BufLen div 4 - 1 do
    begin
      s[3] := #255;
      Inc({$IF CompilerVersion > 18.5}NativeInt{$ELSE}Integer{$IFEND}(s), 4);
    end;
  except
    on E: Exception do
      Sciter.Trace('[TFlashBehavior.DoPaintNotInstall]'+E.Message);
  end;
end;

function TFlashBehavior.flash: IShockwaveFlash;
begin
  Result := m_pUnk as IShockwaveFlash;
end;

function TFlashBehavior.IsTransparent: Boolean;
begin
  Result := This.IndexOfAttribute('bgalpha') >= 0;
end;

function TFlashBehavior.IsWindowless: Boolean;
begin
  Result := This.Attributes['wmode'] = 'Transparent';
end;

procedure TFlashBehavior.OnAttached(const he: IDomElement);
begin
  m_clsid := StringToGUID('{D27CDB6E-AE6D-11cf-96B8-444553540000}');
  inherited;

  if IsWindowless then
    he.StartTimer(100, DEFAULT_TIMERID);
end;

procedure TFlashBehavior.OnDetached(const he: IDomElement);
begin
  if IsWindowless then
    he.StopTimer(DEFAULT_TIMERID);
  inherited;
end;

function TFlashBehavior.OnTimerEx(const he: IDomElement;
  extTimerId: UINT_PTR): Boolean;
begin
  Result := True;
  if extTimerId <> DEFAULT_TIMERID then
    Exit;

  DoPaintUpdate;
end;

end.
