unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterTypes, ExtCtrls, Menus;

type
  TIam = (iaDad, iaMom, iaBaby);
  TMainForm = class(TSciterForm)
    tm: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FIsSwimming: Boolean;
    FDownPos: TPoint;
    FIam: TIam;
    FIsLeftSwim: Boolean;
    FNum, r: Integer;
    cx, cy: Integer;
  protected
    //鼠标按下拖动触发下面的函数
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean;
    //鼠标按下触发下面的函数
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean;
    //鼠标弹起触发下面的函数
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean;
    //右键菜单触发下面的函数
    function  OnMenuItemClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
  protected
    //修改节点代码
    procedure xghtml;
    //默认设置
    function getScreen: TPoint;
    //随机向上向下平行游动
    procedure RandMove(xnum: Integer);
    //向左移动
    procedure ToLeft;
    //向右移动
    procedure ToRight;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ShellAPI, Math, TLHelp32;

var
  hDskManager: THandle = 0;
  hShellView: THandle = 0;

{ TMainForm }

function TMainForm.getScreen: TPoint;
begin
  Self.Left := -200;
  Self.Top  := 200;  //起始位置
  Show;

  Randomize;

  FNum := 1;
  r   := 0;
  FIam := iaDad;
  FIsLeftSwim := True; //向左移动
  FIsSwimming := True; //开始时游动
end;

function TMainForm.OnMenuItemClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;
  
	FIsSwimming := false;
  if target.Text = '退出' then
  begin
    if hShellView <> 0 then
      ShowWindow(hShellView, SW_NORMAL);  //退出前显示桌面图标
    tm.Enabled := False;

    Application.Terminate;
  end
  else
  if target.Text = '隐藏图标' then
  begin
    if hShellView <> 0 then
      ShowWindow(hShellView, SW_HIDE); //隐藏桌面图标
    tm.Interval := 15; //修改定时器
    FIsSwimming := True;
  end
  else
  if target.Text = '显示图标' then
  begin
    if hShellView <> 0 then
      ShowWindow(hShellView, SW_NORMAL); //显示桌面图标
    tm.Interval := 15; //修改定时器
    FIsSwimming := True;
  end
  else
  if target.Text = '鲸鱼爸爸' then
  begin
    FIam := iaDad;
    xghtml; //修改代码 
  end
  else
  if target.Text = '鲸鱼妈妈' then
  begin
    FIam := iaMom;
    xghtml; //修改代码 
  end
  else
  if target.Text = '鲸鱼宝宝' then
  begin
    FIam := iaBaby;
    xghtml; //修改代码 
  end
  else
  if target.Text = '关于虎鲸' then
  begin
    ShellExecute(Handle, nil,PChar('http://baike.baidu.com/view/9005.htm'), nil, nil, SW_shownormal);
    
    tm.Interval := 15; //修改定时器
    FIsSwimming := True;
  end;
  Result := True;
end;

function TMainForm.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  
  if (params.button_state = MAIN_MOUSE_BUTTON) or (params.button_state = PROP_MOUSE_BUTTON) then
  begin
    FIsSwimming := False;
    tm.Interval := 1000000; //定时器暂停3秒等待退出等命令
    if params.button_state = MAIN_MOUSE_BUTTON then
      he.SetCapture;
    FDownPos := params.pos;
    
    Result := True;
  end;
end;

function TMainForm.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  wx, wy: Integer;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if params.button_state = MAIN_MOUSE_BUTTON then
  begin
    FIsSwimming := False;
    tm.Interval := 5000;
    
    wx := Self.Left + params.pos.X - FDownPos.X;
    wy := Self.Top  + params.pos.Y - FDownPos.Y;
    Self.SetBounds(wx, wy, Self.Width, Self.Height);
    
    Result := True;
  end
end;

function TMainForm.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if (params.button_state = MAIN_MOUSE_BUTTON) or (params.button_state = PROP_MOUSE_BUTTON) then
  begin
    he.ReleaseCapture;
  end;
  
  if params.button_state = MAIN_MOUSE_BUTTON then
  begin
    tm.Interval := 15;   //修改定时器
    FIsSwimming := True;
    
    Result := True;
  end
  else
    Result := False;
end;

procedure TMainForm.RandMove(xnum: Integer);
begin
  //在屏幕内游动200次后，随机改变方向
  if (FNum > 200) and (cy<Screen.DesktopRect.Bottom) and (cy > 0) then
  begin   
    r := RandomRange(-1, 1);
    FNum := 1;
  end
  else
  if (cy > Screen.DesktopRect.Bottom+20) then //游动超出屏幕下方时改为向上游动
  begin
    r := -1;
  end
  else
  if cy < -20 then  //游动超出屏幕上方时改为向下游动
  begin
    r := 1;
  end;
  FNum := FNum + 1;

  if r = 0 then  //直线游动时减慢速度
  begin
    tm.Interval := 25;
  end
  else  //加快速度
  begin
    tm.Interval := 15;
  end;

  Self.SetBounds(cx+xnum, cy+r, Self.Width, Self.Height);
end;

procedure TMainForm.xghtml;
var
  myTab: IDomElement;
begin
  case FIam of
    iaDad:
    begin
      myTab := Layout.RootElement.FindFirst('#myTab img');   //获取节点
      if myTab <> nil then
      begin
        if FIsLeftSwim then
          myTab.Attributes['src'] := 'res:daddy_left.png'
        else
          myTab.Attributes['src'] := 'res:daddy_right.png';
      end;
    end;
    iaMom:
    begin
      myTab := Layout.RootElement.FindFirst('#myTab img');   //获取节点
      if myTab <> nil then
      begin
        if FIsLeftSwim then
          myTab.Attributes['src'] := 'res:mummy_left.png'
        else
          myTab.Attributes['src'] := 'res:mummy_right.png';
      end;
    end;
    iaBaby:
    begin
      myTab := Layout.RootElement.FindFirst('#myTab img');   //获取节点
      if myTab <> nil then
      begin
        if FIsLeftSwim then
          myTab.Attributes['src'] := 'res:son_left.png'
        else
          myTab.Attributes['src'] := 'res:son_right.png';
      end;   
    end;
  end;
  FIsSwimming := True;

  tm.Interval := 15; //修改定时器
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  Self.Left := Screen.DesktopWidth-200;
  Self.Top  := 200;  //起始位置

  Randomize;

  FNum := 1;
  r   := 0;
  FIam := iaDad;
  FIsLeftSwim := True; //向左移动
  FIsSwimming := True; //开始时游动

  Behavior.OnMouseMove := OnMouseMove;
  Behavior.OnMouseDown := OnMouseDown;
  Behavior.OnMouseUp   := OnMouseUp;
  Behavior.OnMenuItemClick := OnMenuItemClick;

  tm.Enabled := True;
end;

procedure TMainForm.ToLeft;
var
  xnum: Integer;
begin
  cx := Self.Left;
  cy := Self.Top;

	if cx > -240 then //未超出屏幕左边时，随机游动
  begin
		xnum := -1;
		randmove(xnum)//随机游动
	end
	else
  begin
		FIsLeftSwim := false;//调用向右移动;
		xghtml();//修改代码
	end;
end;

procedure TMainForm.ToRight;
var
  xnum: Integer;
begin
  cx := Self.Left;
  cy := Self.Top;

	if cx < Screen.DesktopWidth then //未超出屏幕右边时，随机游动
  begin
		xnum := 1;
		randmove(xnum)//随机游动
	end
	else
  begin
		FIsLeftSwim := True;//向左移动
		xghtml();//修改代码
	end;
end;

procedure TMainForm.tmTimer(Sender: TObject);
begin
  if FIsLeftSwim then
    ToLeft
  else
    ToRight;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  tm.Enabled := False;
  inherited;
end;

initialization
  hDskManager := FindWindowEx(FindWindow('Progman',nil),0,'shelldll_defview',nil);
  hShellView  := FindWindowEx(FindWindow('WorkerW',nil),0,'shelldll_defview',nil);



finalization

end.
