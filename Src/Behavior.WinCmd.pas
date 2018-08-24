{*******************************************************************************
 标题:     Behavior.WinCmd.pas
 描述:     Window 系统按钮 行为
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit Behavior.WinCmd;

interface

uses
  SysUtils, Windows, SciterIntf, SciterTypes, SciterBehavior, Messages;

(*
  BEHAVIOR: windowCommand
     goal: 窗口行为(最大化、最小化、标题拖动等)的实现
  VIEWS:
     -------------------------------------------------
     | caption         | min | max | restore | close |
     -------------------------------------------------
     |                                               |
     |                     客户区                    |
     |                                               |
     |_______________________________________________|
  COMMENTS:
      <html>
        <body style="behavior:windowCommand">
          <div.header command="window-caption">
            <span.min command="window-min">最小化</span>
            <span.max command="window-max ">最大化</span>
            <span.restore command="window-restore">还原</span>
            <span.close command="window-close">关闭</span>
          </div>
          <div.client>
          </div>
        </body>
      </html>
  NOTE:
     1、如果某元素指定了windowCommand行为，该行为将在该元素内查找有command属性的元素，不同的command值代表不同的含义：
          -command:window-min      //最小化 按钮
          -command:window-max      //最大化 按钮
          -command:window-restore  //还原   按钮
          -command:window-close    //关闭   按钮
          -command:window-caption  //允许拖动,节点可指定command但不是此属性禁止拖动
    2、 【最大化】和【还原】按钮都需要在网页中定义，该行为会负责对这两个按钮的显隐控制；
    3、在【command=window-caption】的元素内部，只要不是其他command命令元素上，按下鼠标时可以拖动窗口；
    4、如果在【command=window-caption】的元素内部的某个元素上要求不能拖动窗口，需要在关元素上添加【command=no-window-caption】;
*)                            

type
  TWinCmdBehavior = class(TBehaviorEventHandler)
  protected
    function IsTitleBar(const ltTarget,ltOwner: IDomElement): Boolean;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseDClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    procedure OnSize(const he: IDomElement); override;
  end;

implementation

uses
  SciterFactoryIntf,Types;

{ TWinCmdBehavior }

function _MaxEnumElement(he: HELEMENT): BOOL; stdcall;
var
  ltBorder: IDomElement;
begin
  ltBorder := ElementFactory.Create(he);
  ltBorder.Hide;
  Result := True;
end;

function _RestoreEnumElement(he: HELEMENT): BOOL; stdcall;
var
  ltBorder: IDomElement;
begin
  ltBorder := ElementFactory.Create(he);
  ltBorder.Show;
  Result := True;
end;


function TWinCmdBehavior.IsTitleBar(const ltTarget, ltOwner: IDomElement): Boolean;
var
  cmdTarget, cmd, c, customCmd, tagName: SciterString;
  ltParent: IDomElement;
begin
  Result := False;
  
  cmdTarget := ltTarget.Attributes['command'];
  cmd := ltOwner.Attributes['command'];
  if cmdTarget = EmptyStr then
    c := cmd
  else
    c := cmdTarget;

  if c <> EmptyStr then
  begin
    if cmdTarget <> EmptyStr then
    begin
      if (cmdTarget <> 'window-caption') then
        Exit;
    end
    else
    begin
      ltParent := ltTarget;
      while ltParent <> nil do
      begin
        customCmd := ltParent.Attributes['command'];
        if customCmd <> EmptyStr then
        begin
          if (customCmd = 'no-window-caption') or (customCmd = 'window-client') then
            Exit;
        end;
        tagName := ltParent.Tag;
        if (tagName ='popup') or (tagName ='menu') then
          Exit;
        ltParent := ltParent.parent;
      end;    
    end;    
    Result := true;
  end;
end;

procedure TWinCmdBehavior.OnAttached(const he: IDomElement);
var
  ltBody: IDomElement;
begin
  if he.Root.IndexOfAttribute('-init-window-command') >= 0 then
    Exit;
  he.Root.Attributes['-init-window-command'] := '';
  he.Root.RemoveAttribute('-final-window-command');

  ltBody := he.Root.FindFirst('body');
  if ltBody <> nil then
  begin    
    if IsZoomed(he.GetElementHwnd) then
      ltBody.Attributes['maximize'] := 'true'
    else
      ltBody.Attributes['maximize'] := 'false';
  end;
end;

procedure TWinCmdBehavior.OnDetached(const he: IDomElement);
begin
  if he.IndexOfAttribute('-final-window-command') >= 0 then
    Exit; 
  he.Root.Attributes['-final-window-command'] := '';
  he.Root.RemoveAttribute('-init-window-command');
end;

function TWinCmdBehavior.OnMouseDClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  doc: IDomElement;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  if not IsTitleBar(target, he) then
     Exit;
  doc := he.Root;
  if IsZoomed(doc.GetElementHwnd) then
  begin
    if (doc.FindFirst('[command="window-restore"]')<>nil) or he.HasAttribute('can-window-restore') then
      PostMessage(he.GetElementHwnd, WM_SYSCOMMAND, SC_RESTORE, 0);
  end
  else
  if (doc.FindFirst('[command="window-max"]')<>nil) or he.HasAttribute('can-window-max') then
    PostMessage(he.GetElementHwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
      
  Result := True;
end;

function TWinCmdBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  p: TPoint;
  LFormHandle: HWND;
begin
  Result := False; 
  if not IsBubbling(event_type) then
    Exit;
  if not IsTitleBar(target, he) then
    Exit;
  LFormHandle := he.GetElementHwnd;
  if IsZoomed(LFormHandle) then
    Exit;

  P := Types.Point(0, 0);
  ClientToScreen(LFormHandle, p);

  PostMessage(LFormHandle, WM_NCLBUTTONDOWN,  HTCAPTION, 0);
  Result := True;
end;

function TWinCmdBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  cmd: SciterString;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  cmd := target.Attributes['command'];
  if cmd = EmptyStr then
    cmd := he.Attributes['command'];
    
  if cmd = 'window-max' then
    PostMessage(he.GetElementHwnd, WM_SYSCOMMAND, SC_MAXIMIZE, 0)
  else
  if cmd = 'window-restore' then
    PostMessage(he.GetElementHwnd, WM_SYSCOMMAND, SC_RESTORE, 0)
  else
  if cmd = 'window-min' then
    PostMessage(he.GetElementHwnd, WM_SYSCOMMAND, SC_MINIMIZE, 0)
  else
  if cmd = 'window-close' then
    PostMessage(he.GetElementHwnd, WM_SYSCOMMAND, SC_CLOSE, 0)
  else
  if cmd = 'window-sysmenu' then
    PostMessage(he.GetElementHwnd, WM_NCLBUTTONDOWN, HTSYSMENU, 0)
  else
    Exit;
  Result := True;
end;

procedure TWinCmdBehavior.OnSize(const he: IDomElement);
var
  ltRoot, ltBody, elMax, elRestore: IDomElement;
  Placement: TWindowPlacement;
begin
  ltRoot := he.Root;
  if ltRoot.Tag = 'body' then
    ltBody := ltRoot
  else
    ltBody := ltRoot.FindFirst('body');

  GetWindowPlacement(he.GetElementHwnd, @Placement);
  case Placement.showCmd of
    SW_SHOWMINIMIZED:
    begin
    
    end;
    SW_SHOWMAXIMIZED:
    begin
      elMax := ltRoot.FindFirst('[command="window-max"]');
      if elMax <> nil then
      begin
        elRestore := ltRoot.FindFirst('[command="window-restore"]');
        if elRestore = nil then
        begin
          elMax.Show;
          elMax.Attributes['command'] := 'window-restore';
        end
        else
        begin
          elRestore.Show;
          elMax.Hide;
        end;
        if ltBody <> nil then
          ltBody.Attributes['maximize'] := '';
      end;
      if ltRoot.HasAttribute('-init-window-sizer') then
        ltRoot.SelectElements('[windowSizer][sizer-command]', @_MaxEnumElement);
    end;
    SW_NORMAL:
    begin
      elRestore := ltRoot.FindFirst('[command="window-restore"]');
      if elRestore <> nil then
      begin
        elMax := ltRoot.FindFirst('[command="window-max"]');
        if elMax = nil then
        begin
          elRestore.Show;
          elRestore.Attributes['command'] := 'window-max'
        end
        else
        begin
          elMax.Show;
          elRestore.Hide;
        end;
        if ltBody <> nil then
          ltBody.RemoveAttribute('maximize');
      end;
      if ltRoot.HasAttribute('-init-window-sizer') then
        ltRoot.SelectElements('[windowSizer][sizer-command]', @_RestoreEnumElement);
    end;
  end;
end;

function TWinCmdBehavior.OnSubscription(const he: IDomElement; var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_MOUSE or HANDLE_SIZE;
  Result := True;
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('windowCommand', TWinCmdBehavior));

finalization
  BehaviorFactorys.UnReg('windowCommand');


end.
