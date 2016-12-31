unit SciterObj;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterWndIntf, TiscriptIntf;

type
  {$WARNINGS OFF}
  TSciterObject = class(TSciterRttiObject)
  protected
    FWnd: ISciterWindow;
    filename: WideString;
    debugIsActive: Boolean;
    
    procedure launchDebugView;
    procedure loadFile(const fn: WideString);
  public
    constructor Create(const AMainWnd: ISciterWindow);
    
    procedure DoWindowDestroy(const hwnd: ISciterWindow; var pHandle: Boolean; var Result: LRESULT);
    procedure DoWindowKeyDown(const hwnd: ISciterWindow; msg: UINT;
      CharCode, KeyData: Integer; var pHandle: Boolean; var Result: LRESULT);

    function  OnButtonClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
    function  OnScriptCallTs(const he: IDomElement; pvm: Ptiscript_VM; const name: PWideChar; var retval: tiscript_value): Boolean;

    property Wnd: ISciterWindow read FWnd write FWnd;
  end;
  {$WARNINGS ON}

implementation

uses
  SciterDebugIntf;

const
  file_filter =
    'files *.htm,*.html,*.svg,*.zip,*.scapp|*.HTM;*.HTML;*.SVG;*.ZIP;*.SCAPP|' +
		'HTML files only(*.htm,*.html)|*.HTM;*.HTML|' +
    'SVG files only(*.svg)|*.SVG|' +
		'SCAPP files only (*.zip,*.scapp)|*.ZIP;*.SCAPP|' +
		'All Files (*.*)|*.*';


{ TSciterObject }

function TSciterObject.OnScriptCallTs(const he: IDomElement; pvm: Ptiscript_VM;
  const name: PWideChar; var retval: tiscript_value): Boolean;
var
  vm: ITiscriptRuntime;
begin
  Result := False;

  if name = 'launchDebugView' then
  begin
    launchDebugView;
    vm := Tiscript.CreateRuntime(pvm);
    vm.V(retval).B := True;

    Result := True;
  end;
end;

procedure TSciterObject.launchDebugView;
var
  root, frame: IDomElement;
begin
  // launch sciter::inspector for the document loaded into frame#content
  root := FWnd.Layout.RootElement;
  frame := root.FindFirst('frame#content');
  if (frame <> nil) and (frame.ChildCount > 0) then
    DebugOut.Inspect(frame.Child[0])
  else
    DebugOut.Inspect(FWnd.Layout);

  debugIsActive := True;
end;

function TSciterObject.OnButtonClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
var
  sFileName: String;
begin
  Result := False;
  if not FWnd.IsBubbling(_type) then
    Exit;

  if he.ID = 'open' then
  begin
    sFileName := FWnd.Layout.Eval(Format('view.selectFile(#open, "%s", "%s");', [file_filter, '.html']));
    if (sFileName = 'undefined') or (sFileName = EmptyStr) then
      Exit;

    loadFile(sFileName);
  end
  else
  if he.ID = 'reload' then
  begin
    if filename <> EmptyStr then
    begin
      loadFile(filename);
      if debugIsActive then
        launchDebugView;
    end;
  end
  else
  if he.ID = 'open-in-view' then
  begin
    sFileName := FWnd.Layout.Eval(Format('view.selectFile(#open, "%s", "%s");', [file_filter, '.html']));
    if sFileName = EmptyStr then
      Exit;
      
    FWnd.Layout.LoadFile(sFileName);
  end;
end;

procedure TSciterObject.loadFile(const fn: WideString);
var
  content, reload, inspectorButton, title: IDomElement;
  iPos: Integer;
  sFileName: string;
begin
  try
    filename := fn;
  
    content := FWnd.Layout.RootElement.FindFirst('frame#content');
    if content = nil then
      Exit;

    sFileName := fn;
    iPos := LastDelimiter('/', sFileName);
    FWnd.Layout.BaseUri := Copy(sFileName, 0, iPos);
    content.LoadHtml(sFileName);

    reload := FWnd.Layout.RootElement.FindFirst('button#reload');
    if reload <> nil then
      reload.ClearState(STATE_DISABLED);

    inspectorButton := FWnd.Layout.RootElement.FindFirst('button#inspector');
    if inspectorButton <> nil then
      inspectorButton.ClearState(STATE_DISABLED);

    if debugIsActive then
      launchDebugView;

    if content.ChildCount > 0 then
    begin
      title := content.Child[0].FindFirst('head>title');
      if title <> nil then
        FWnd.Caption := title.Text;

      if FWnd.Caption = EmptyStr then
        FWnd.Caption := 'Sciter';
    end;
  except
    on e: Exception do
    begin
      Sciter.Trace('[TSciterObject.loadFile]'+e.Message);
    end;
  end;
end;

procedure TSciterObject.DoWindowKeyDown(const hwnd: ISciterWindow;
  msg: UINT; CharCode, KeyData: Integer; var pHandle: Boolean;
  var Result: LRESULT);
begin
  if CharCode = VK_F12 then
  begin
    launchDebugView;
    pHandle := True;
    Result := 0;
  end;
end;

procedure TSciterObject.DoWindowDestroy(const hwnd: ISciterWindow;
  var pHandle: Boolean; var Result: LRESULT);
begin
  FWnd := nil;
end;

constructor TSciterObject.Create(const AMainWnd: ISciterWindow);
begin
  FWnd := AMainWnd;
  FWnd.Layout.Behavior.OnButtonClick  := OnButtonClick;
  FWnd.Layout.Behavior.OnScriptCallTs := OnScriptCallTs;
  FWnd.OnDestroy := DoWindowDestroy;
  FWnd.OnKeyDown := DoWindowKeyDown;
end;

end.
