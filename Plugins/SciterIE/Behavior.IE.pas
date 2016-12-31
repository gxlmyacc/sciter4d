unit Behavior.IE;

interface

uses
  SysUtils, Windows, ActiveX, SciterTypes, SciterIntf, SciterBehavior,
  WebBrowserEx, Variants, TiscriptIntf;

type
  TIEBehavior = class;
  
  {$METHODINFO ON}
  TWBContainerExternal = class
  private
    FBehavior: TIEBehavior;
    FOnGetMessage: OleVariant;
    function GetPostEnable: Boolean;
    procedure SetOnGetMessage(const Value: OleVariant);
  public
    constructor Create(ABehavior: TIEBehavior);
  published
    function Eval(const AScript: WideString): OleVariant;
    function PostMessage(const AMsg: WideString): OleVariant;
  published
    property OnGetMessage: OleVariant read FOnGetMessage write SetOnGetMessage;
    property PostEnable: Boolean read GetPostEnable;
  end;
  {$METHODINFO OFF}
  
  TIEBehavior = class(TBehaviorEventHandler)
  private
    FThisObject: ITiscriptObject;
    FWebBrowser: TWebBrowserEx;
    FExternalObj: TWBContainerExternal;
    FExternal: IDispatch;
  private
    function GetValue: WideString;
    function GetOffline: Boolean;
    function GetSilent: Boolean;
    function GetResizable: Boolean;
    function GetContextMenu: Boolean;
    function GetScrollBar: Boolean;
    procedure SetValue(const Value: WideString);
    procedure SetOffline(const Value: Boolean);
    procedure SetSilent(const Value: Boolean);
    procedure SetResizable(const Value: Boolean);
    procedure SetContextMenu(const Value: Boolean);
    procedure SetScrollBar(const Value: Boolean);
  protected
    procedure DoStatusTextChange(Sender: TObject; const Text: WideString);
    procedure DoTitleChange(Sender: TObject; const Text: WideString);
    procedure BeforeNavigate(Sender: TObject; const pDisp: IDispatch; 
      const URL: OleVariant; const Flags: OleVariant; const TargetFrameName: OleVariant;
      const PostData: OleVariant; const Headers: OleVariant; var Cancel: WordBool);
   procedure DoNewWindow(Sender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
   procedure DoNavigateComplete(Sender: TObject; const pDisp: IDispatch; const URL: OleVariant);
   procedure DoDocumentComplete(Sender: TObject; const pDisp: IDispatch; const URL: OleVariant);
   procedure DoDownloadBegin(Sender: TObject);
   procedure DoDownloadComplete(Sender: TObject);
   procedure DoQuit(Sender: TObject);
   procedure DoGetExternal(Sender: TObject; out ppDispatch: IDispatch; var AResult: HRESULT);
  protected
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
  public
    procedure Config(const AOptions: ITiscriptObject);

    procedure GoBack();
    procedure GoForward();
    
    procedure Go(const URL: WideString);

    procedure Refresh();
    procedure Stop();

    function Eval(const Script: WideString): OleVariant;
    function PostEnable: Boolean;
    function PostMessage(const param: OleVariant): OleVariant;

    function Web: IWebBrowser2;
  published
    property Value: WideString read GetValue write SetValue;
    property Offline: Boolean read GetOffline write SetOffline;
    property Silent: Boolean read GetSilent write SetSilent;
    property Resizable: Boolean read GetResizable write SetResizable;
    property ScrollBar: Boolean read GetScrollBar write SetScrollBar;
    property ContextMenu: Boolean read GetContextMenu write SetContextMenu;
  end;

implementation

uses
  ObjComAutoEx;

procedure TIEBehavior.BeforeNavigate(Sender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onBeforeNavigate'];
  if not LEvent.IsFunction then Exit;
  Cancel := LEvent.F.Call([URL]).B;
end;

procedure TIEBehavior.Config(const AOptions: ITiscriptObject);
var
  v: ITiscriptValue;
begin
  v := AOptions['offline'];
  if not v.IsUndefined then
    Self.Offline := v.B;
  v := AOptions['silent'];
  if not v.IsUndefined then
    Self.Silent := v.B;
  v := AOptions['resizable'];
  if not v.IsUndefined then
    Self.Resizable := v.B;
  v := AOptions['scrollbar'];
  if not v.IsUndefined then
    Self.ScrollBar := v.B;
  v := AOptions['contextmenu'];
  if not v.IsUndefined then
    Self.ContextMenu := v.B;
end;

procedure TIEBehavior.DoDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onDocumentComplete'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([URL]);
end;

procedure TIEBehavior.DoDownloadBegin(Sender: TObject);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onDownloadBegin'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([]);
end;

procedure TIEBehavior.DoDownloadComplete(Sender: TObject);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onDownloadComplete'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([]);
end;

procedure TIEBehavior.DoGetExternal(Sender: TObject;
  out ppDispatch: IDispatch; var AResult: HRESULT);
begin
  if FExternal = nil then
  begin
    FExternalObj := TWBContainerExternal.Create(Self);
    FExternal := WrapObjectDispatch(FExternalObj);
  end;
  ppDispatch := FExternal;
  AResult := S_OK;
end;

procedure TIEBehavior.DoNavigateComplete(Sender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onNavigateComplete'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([URL]);
end;

procedure TIEBehavior.DoNewWindow(Sender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool);
var
  LEvent: ITiscriptValue;
  LBrower: IWebBrowser2;
begin
  if FThisObject = nil then Exit;
  if not Supports(ppDisp, IWebBrowser2, LBrower) then Exit;
  LEvent := FThisObject['onNewWindow'];
  if not LEvent.IsFunction then Exit;
  Cancel := LEvent.F.Call([LBrower.LocationURL]).B;
end;

procedure TIEBehavior.DoQuit(Sender: TObject);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onQuit'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([]);
end;

procedure TIEBehavior.DoStatusTextChange(Sender: TObject;
  const Text: WideString);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onStatusTextChange'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([Text]);
end;

procedure TIEBehavior.DoTitleChange(Sender: TObject;
  const Text: WideString);
var
  LEvent: ITiscriptValue;
begin
  if FThisObject = nil then Exit;
  LEvent := FThisObject['onTitleChange'];
  if not LEvent.IsFunction then Exit;
  LEvent.F.Call([Text]);
end;

function TIEBehavior.Eval(const Script: WideString): OleVariant;
begin
  Result := FWebBrowser.Eval(Script)
end;

function TIEBehavior.GetContextMenu: Boolean;
begin
  Result := FWebBrowser.ContextMenu;
end;

function TIEBehavior.GetOffline: Boolean;
begin
  Result := FWebBrowser.Offline;
end;

function TIEBehavior.GetResizable: Boolean;
begin
  Result := FWebBrowser.Resizable;
end;

function TIEBehavior.GetScrollBar: Boolean;
begin
  Result := FWebBrowser.ScrollBars;
end;

function TIEBehavior.GetSilent: Boolean;
begin
  Result := FWebBrowser.Silent;
end;

function TIEBehavior.GetValue: WideString;
begin
  Result := This.Attributes['src'];
end;

procedure TIEBehavior.Go(const URL: WideString);
begin
  FWebBrowser.Navigate(Sciter.DecodeURI(This.CombineURL(Sciter.EncodeURI(URL))));
end;

procedure TIEBehavior.GoBack();
begin
  FWebBrowser.GoBack;
end;

procedure TIEBehavior.GoForward();
begin
  FWebBrowser.GoForward;
end;

procedure TIEBehavior.OnAttached(const he: IDomElement);
var
  sUrl: WideString;
  LValue: ITiscriptValue;
begin
  FWebBrowser := TWebBrowserEx.Create(he.GetElementHwnd, he.GetLocation(VIEW_RELATIVE));
  FWebBrowser.OnStatusTextChange := DoStatusTextChange;
  FWebBrowser.OnTitleChange := DoTitleChange;
  FWebBrowser.OnBeforeNavigate2 := BeforeNavigate;
  FWebBrowser.OnNewWindow2 := DoNewWindow;
  FWebBrowser.OnNavigateComplete2 := DoNavigateComplete;
  FWebBrowser.OnDocumentComplete := DoDocumentComplete;
  FWebBrowser.OnDownloadBegin := DoDownloadBegin;
  FWebBrowser.OnDownloadComplete := DoDownloadComplete;
  FWebBrowser.OnQuit := DoQuit;
  FWebBrowser.OnGetExternal := DoGetExternal;

  LValue := Tiscript.CreateValue(he.vm, he.GetObject(True));
  FThisObject := LValue.O;

  if he.HasAttribute('offline') then
    Self.Offline := True;
  if he.HasAttribute('silent') then
    Self.Silent := True;
  if he.HasAttribute('resizable') then
    Self.Resizable := True;
  if he.HasAttribute('scrollbar') then
    Self.ScrollBar := True;
  if he.HasAttribute('contextmenu') then
    Self.ContextMenu := True;

  sUrl := he.Attributes['src'];
  if (sUrl <> '') then Go(sUrl);
end;

procedure TIEBehavior.OnDetached(const he: IDomElement);
begin
  if FWebBrowser <> nil then
  begin
    FreeAndNil(FWebBrowser);
  end;
  FThisObject := nil;
end;

{ TWBContainerExternal }

constructor TWBContainerExternal.Create(ABehavior: TIEBehavior);
begin
  FBehavior := ABehavior;
  FOnGetMessage := EmptyParam;
end;

procedure TWBContainerExternal.SetOnGetMessage(const Value: OleVariant);
begin
  FOnGetMessage := Value;
end;

function TWBContainerExternal.Eval(const AScript: WideString): OleVariant;
begin
  Result := FBehavior.This.Eval(AScript);
end;

function TWBContainerExternal.GetPostEnable: Boolean;
var
  LEvent: ITiscriptValue;
begin
  Result := False;
  if FBehavior.FThisObject = nil then Exit;
  LEvent := FBehavior.FThisObject['onGetMessage'];
  Result := LEvent.IsFunction;
end;

function TWBContainerExternal.PostMessage(const AMsg: WideString): OleVariant;
var
  LEvent, LRet: ITiscriptValue;
begin
  Result := Null;
  if FBehavior.FThisObject = nil then Exit;
  LEvent := FBehavior.FThisObject['onGetMessage'];
  if not LEvent.IsFunction then Exit;
  LRet := LEvent.F.Call([AMsg]);
  if LRet.IsInt then
    Result := LRet.I
  else
  if LRet.IsFloat then
    Result := LRet.D
  else
  if LRet.IsSymbol or LRet.IsString then
    Result := LRet.S
  else
  if LRet.IsNativeObject then
    Result := LRet.O.NativeInstance
  else
  if LRet.IsArray or LRet.IsObject then
    Result := LRet.S
  else            
  if LRet.IsFunction or LRet.IsNativeFunction then
    Result := LRet.F.ToDispatch;
end;

procedure TIEBehavior.OnSize(const he: IDomElement);
begin
  FWebBrowser.UpdateBounds(he.GetLocation(VIEW_RELATIVE));
end;

function TIEBehavior.OnSubscription(const he: IDomElement; var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_SIZE;
  Result := True;
end;

function TIEBehavior.PostEnable: Boolean;
begin
  Result := (FExternalObj <> nil) and (not VarIsEmptyParam(FExternalObj.OnGetMessage)) and
    (not VarIsNull(FExternalObj.OnGetMessage)); 
end;

function TIEBehavior.PostMessage(const param: OleVariant): OleVariant;
  function _CallFunction(const aCallback: OleVariant; const Args: array of OleVariant): OleVariant;
  var
    I, iLen: Integer;
    v: OleVariant;
    LArgs: array of OleVariant;
    Disp: IDispatch;
    DispParams: TDispParams;
    {$IF CompilerVersion <= 18.5  }
    ws: WideString;
    {$IFEND}
  begin
    Disp := IDispatch(aCallback);

    iLen := Length(Args);
    SetLength(LArgs, iLen);
    for I := 0 to iLen - 1 do
    begin
      v := Args[I];
      {$IF CompilerVersion <= 18.5  }
      if VarType(v) = varString then
      begin
        ws := v;
        v := ws;
      end;
      {$IFEND}
      LArgs[iLen - I - 1] :=  v;
    end;
    DispParams.cArgs := Length(LArgs);
    if Length(LArgs) > 0 then
      DispParams.rgvarg := @LArgs[0]
    else
      DispParams.rgvarg := nil;

    DispParams.cNamedArgs := 0;
    DispParams.rgdispidNamedArgs := nil;
    Disp.Invoke(0, GUID_NULL, LOCALE_USER_DEFAULT, DISPATCH_METHOD,
      DispParams, @Result, nil, nil);
  end;
begin
  if not PostEnable then Exit;
  Result := _CallFunction(FExternalObj.OnGetMessage, [param]);
end;

procedure TIEBehavior.Refresh();
begin
  FWebBrowser.Refresh;
end;

procedure TIEBehavior.SetContextMenu(const Value: Boolean);
begin
  FWebBrowser.ContextMenu := Value;
end;

procedure TIEBehavior.SetOffline(const Value: Boolean);
begin
  FWebBrowser.Offline := Value;
end;

procedure TIEBehavior.SetResizable(const Value: Boolean);
begin
  FWebBrowser.Resizable := Value;
end;

procedure TIEBehavior.SetScrollBar(const Value: Boolean);
begin
  FWebBrowser.ScrollBars := Value;
end;

procedure TIEBehavior.SetSilent(const Value: Boolean);
begin
  FWebBrowser.Silent := Value;
end;

procedure TIEBehavior.SetValue(const Value: WideString);
begin
  This.Attributes['src'] := Value;
  if Value <> '' then
    Go(Value);
end;

procedure TIEBehavior.Stop();
begin
  FWebBrowser.Stop;
end;

function TIEBehavior.Web: IWebBrowser2;
begin
  Result := FWebBrowser.WebBrowser;
end;

initialization
  {$IF CompilerVersion > 18.5}
  SetSSEExceptionMask(exAllArithmeticExceptions);
  {$IFEND}
  SetFPUExceptionMask(exAllArithmeticExceptions);
finalization

end.
