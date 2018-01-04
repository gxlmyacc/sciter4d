unit MainFrm;

interface
uses
  Windows, SysUtils, Classes, Controls, Forms,
  Dialogs, StdCtrls, SciterIntf, SciterTypes, ComCtrls, SciterCtl,
  SynHighlighterHtml, SynMemo, ExtCtrls, TiscriptIntf, SciterURIIntf,
  {$IF CompilerVersion <= 18.5}Placemnt, SynEdit, SynEditHighlighter{$ELSE}RxPlacemnt,
  SynEdit, SynEditHighlighter{$IFEND};

type
  {$WARNINGS OFF}
  {$METHODINFO ON}
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    EdtFilePath: TEdit;
    FormStorage1: TFormStorage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Panel3: TPanel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    SynMemo1: TSynMemo;
    SynHTMLSyn1: TSynHTMLSyn;
    Button5: TButton;
    Button6: TButton;
    btnBrw: TButton;
    dlgOpen: TOpenDialog;
    Button7: TButton;
    Button8: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure SynMemo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button5Click(Sender: TObject);
    procedure EdtFilePathKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button6Click(Sender: TObject);
    procedure btnBrwClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    Html, Html2: TSciterControl;
    tick: Cardinal;
    function  OnDocumentComplete(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
  public
    procedure launchDebugView(const AEle: IDomElement);
  public
    procedure Test;
    function Test1(const AElement: IDomElement): IDomElement;
  end;
  {$METHODINFO OFF}
  {$WARNINGS ON}

var
  MainForm: TMainForm;
  sMasterDir: string;

implementation
{$R *.dfm}

uses
  ShellAPI, SciterDebugIntf, SciterWndIntf, ObjComAutoEx;

procedure TMainForm.Button1Click(Sender: TObject);
var
  sFile: string;
begin
  if Html = nil then
  begin
    Html := TSciterControl.Create(Panel1);
    Html.Parent := Panel1;
    Html.Align := alClient;
    Html.Layout.Behavior.OnDocumentComplete := OnDocumentComplete;
  end;

  sFile := Trim(EdtFilePath.Text);
  if Pos(':', sFile) <= 0 then
    sFile := ExtractFilePath(ParamStr(0)) + sFile;

  Html.Visible := True;

  tick := GetTickCount;
  Html.Layout.LoadFile('file://'+sFile);
end;

procedure TMainForm.Button2Click(Sender: TObject);
var
  sFile: string;
begin
  if Html2 = nil then
  begin
    Html2 := TSciterControl.Create(Panel2);
    Html2.Parent := Panel2;
    Html2.Align := alClient;
    Html2.Visible := True;
    Html2.Layout.Behavior.OnDocumentComplete := OnDocumentComplete;
    Html2.Layout.Behavior.RttiObject := TObjectDispatchEx.Create(Self, False);
  end;

  sFile := ChangeFileExt(ParamStr(0), '.html');
  SynMemo1.Lines.SaveToFile(sFile);

  tick := GetTickCount;
  Html2.Layout.LoadFile('file://'+sFile);
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  ShellExecute(handle, nil,pchar(ChangeFileExt(ParamStr(0), '.html')),nil,nil, SW_shownormal);
end;

procedure TMainForm.Button4Click(Sender: TObject);
var
  sFile: string;
begin
  sFile := Trim(EdtFilePath.Text);
  if Pos(':', sFile) <= 0 then
    sFile := ExtractFilePath(ParamStr(0)) + sFile;

  ShellExecute(handle, nil,pchar(sFile),nil,nil, SW_shownormal);
end;

procedure TMainForm.SynMemo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F9) then
    Button2.Click
  else
  if (Key = VK_F8) then
    Button3.Click
  else
  if (Key = VK_F7) then
    Button5.Click
  else
  if (Key = VK_F12) and (Html2<>nil) then
    launchDebugView(Html2.Layout.RootElement);
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  ShellExecute(handle, PChar('Open'),pchar('explorer.exe'),
    PChar(ExtractFileDir(ParamStr(0))), nil, SW_shownormal);
end;

procedure TMainForm.EdtFilePathKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_F9) or (Key = VK_RETURN) then
    Button1.Click
  else
  if (Key = VK_F8) then
    Button4.Click
  else
  if (Key = VK_F12) and (Html<>nil) then
    launchDebugView(Html.Layout.RootElement);
end;

procedure TMainForm.Button6Click(Sender: TObject);
const
  const_template =
  '<html>'#13#10 +
  ' <head>'#13#10 +
  '  <style type="text/css">'#13#10 +
  '   '#13#10 +
  '  </style>'#13#10 +
  '  <script type="text/tiscript">'#13#10 +
  '   '#13#10 +
  '  </script>'#13#10 +
  ' </head>'#13#10 +
  ' <body>'#13#10 +
  '  '#13#10 +
  ' </body>'#13#10 +
  '</html>';
begin
  SynMemo1.Lines.Text := const_template;
end;

procedure TMainForm.btnBrwClick(Sender: TObject);
begin
  dlgOpen.FileName := EdtFilePath.Text;
  if not dlgOpen.Execute then
    Exit;

  EdtFilePath.Text := dlgOpen.FileName;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  sFile: string;
begin
  FormStorage1.IniFileName := ChangeFileExt(ParamStr(0), '.ini');
  sFile := ChangeFileExt(ParamStr(0), '.html');
  if FileExists(sFile) then
    SynMemo1.Lines.LoadFromFile(sFile);
end;

procedure TMainForm.Button7Click(Sender: TObject);
var
  LWindow: ISciterWindow;
begin
  LWindow := CreateWindow(SysInit.HInstance, CWFlags_Sizeable + [swScreenCenter],
    500, 400, Self.Handle);
  LWindow.Layout.LoadFile(Sciter.FilePathToURL(EdtFilePath.Text));
  LWindow.ShowModal();
  //LWindow.Show();
end;

procedure TMainForm.launchDebugView(const AEle: IDomElement);
begin
  DebugOut.Inspect(AEle);
end;

function TMainForm.OnDocumentComplete(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin             
  Caption := 'Sciter Ò³Ãæ²âÊÔ£º' + IntToStr(GetTickCount - tick) + ' ms';
  Result := True;
end;

procedure TMainForm.Test();
var
  tr: ITiscriptRuntime;
  sMasterFile: string;
  vm: HVM;
begin
  sMasterFile := sMasterDir + 'test.tis';
  if FileExists(sMasterFile) then
  begin
    vm := Html2.Layout.VM;
    tr := Tiscript.CreateRuntime(vm);
    tr.loadtisFile(sMasterFile);
  end;
end;

function TMainForm.Test1(const AElement: IDomElement): IDomElement;
begin
  if AElement <> nil then
    ShowMessage('[TMainForm.Test1]'+AElement.Tag)
  else
    ShowMessage('[TMainForm.Test1]null');
  Result := AElement;
end;

function _NativeAnonymousFunction(vm: HVM; this, super: ITiscriptObject;
  argCount: Integer; args: PTiscriptValueArray; tag: Pointer): ITiscriptValue;
begin
  try
    ShowMessage(args[0].S);
  except
  end;
end;

procedure TMainForm.Button8Click(Sender: TObject);
var
  func: ITiscriptFunction;
begin
  func := Tiscript.F(_NativeAnonymousFunction);
  func.Call(['¹þ¹þ']);
end;

end.
