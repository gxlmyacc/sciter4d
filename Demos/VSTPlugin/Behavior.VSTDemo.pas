unit Behavior.VSTDemo;

interface

uses
  Windows, SysUtils, Classes, SciterIntf, SciterTypes, SciterBehavior, VirtualTrees,
  Controls, Forms, superobject;

type
  TVSTDemoBehavior = class(TBehaviorEventHandler)
  private
    FVST: TVirtualStringTree;
    FValue: ISuperObject;
    FDatas: TSuperArray;
  private
    procedure VSTInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure VSTInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: {$IF CompilerVersion > 15.0 }string{$ELSE}WideString{$IFEND});
  protected
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;

    procedure DoParseValue(const OldValue: ISuperObject);
  published
    function GetIsEmpty: Boolean;
    function GetValue: JSONObject;
    function GetColumn: WideString;
    procedure SetColumn(const Value: WideString);
    procedure SetValue(const Value: JSONObject);

    function AddData(const Value: WideString): Boolean;

    property IsEmpty: Boolean read GetIsEmpty;
    property Value: JSONObject read GetValue write SetValue;
    property column: WideString read GetColumn write SetColumn;
  end;

implementation

uses
  Dialogs, Math, Graphics;

{ TVSTDemoBehavior }

function TVSTDemoBehavior.AddData(const Value: WideString): Boolean;
var
  s: ISuperObject;
begin
  Result := False;
  try
    if (FValue = nil) or (FDatas = nil) then
    begin
      ShowMessage('列表尚未加载！');
      Exit;
    end;
    
    s := so(StringReplace(value, #9, '', [rfReplaceAll]));
    if s = nil then
    begin
      ShowMessage('数据格式不正确！');
      Exit;
    end;

    FDatas.Add(s);

    FVST.Clear;
    FVST.RootNodeCount := FDatas.Length;

    Result := True;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;
end;

procedure TVSTDemoBehavior.DoParseValue(const OldValue: ISuperObject);
var
  jColumns: TSuperArray;
  i: Integer;
  LVstColumn: TVirtualTreeColumn;
  jColumnOptions, jColumn: ISuperObject;
begin
  if FValue = nil then
    Exit;

  FVST.Clear;
  FVST.Header.Columns.Clear;
  FDatas := nil;

  jColumns := FValue.A['columns'];
  if jColumns = nil then
    Exit;

  jColumnOptions := FValue.O['columnOptions'];
  if jColumnOptions <> nil then
  begin
    if jColumnOptions.I['height'] > 0 then
      FVST.Header.Height := jColumnOptions.I['height'];

    if jColumnOptions.B['visible'] then
      FVST.Header.Options := FVST.Header.Options + [hoVisible]
    else
      FVST.Header.Options := FVST.Header.Options - [hoVisible];
  end;

  for i := 0 to jColumns.Length - 1 do
  begin
    jColumn := jColumns.O[i];
    
    LVstColumn := FVST.Header.Columns.Add;
    LVstColumn.Text := jColumn.S['text'];
    LVstColumn.Width := IfThen(jColumn.I['width']=0, 100, jColumn.I['width']);

    if jColumn.B['fixed'] then
      LVstColumn.Options := LVstColumn.Options + [coFixed];

    if jColumn.S['align'] = 'center' then
      LVstColumn.Alignment := taCenter
    else
    if jColumn.S['align'] = 'right' then
      LVstColumn.Alignment := taRightJustify;
  end;

  FDatas := FValue.A['datas'];
  if FDatas = nil then
    Exit;

  FVST.RootNodeCount := FDatas.Length;
end;

function TVSTDemoBehavior.GetColumn: WideString;
begin
  ShowMessage('GetColumn');
end;

function TVSTDemoBehavior.GetIsEmpty: Boolean;
begin
  Result := FValue = nil;
end;

function TVSTDemoBehavior.GetValue: JSONObject;
begin
  if FValue <> nil then
    Result := FValue.AsJSon
  else
    Result := 'null';
end;

procedure TVSTDemoBehavior.OnAttached(const he: IDomElement);
begin
  inherited;
  
  FVST := TVirtualStringTree.CreateParented(Layout.Hwnd);
  if he.ID <> EmptyStr then
    FVST.Name := he.ID
  else
  if he.Attributes['name'] <> EmptyStr then
    FVST.Name := he.Attributes['name'];

  FVST.ParentFont := False;
  
  FVST.BorderStyle := bsNone;

  SetWindowText(FVST.Handle, PChar(FVST.Name));

  FVST.NodeDataSize := 4;
  FVST.Header.Style := hsFlatButtons;

  FVST.OnInitNode := VSTInitNode;
  FVST.OnInitChildren := VSTInitChildren;
  FVST.OnGetText := VSTGetText;

  he.AttachHwnd(FVST.Handle);
end;

procedure TVSTDemoBehavior.OnDetached(const he: IDomElement);
begin
  inherited;
  
  if FVST <> nil then
  begin
    he.AttachHwnd(0);
    FreeAndNil(FVST);
  end;
end;


procedure TVSTDemoBehavior.SetColumn(const Value: WideString);
begin
  ShowMessage('SetColumn');
end;

procedure TVSTDemoBehavior.SetValue(const Value: JSONObject);
var
  LSO, LOldValue: ISuperObject;
begin
  LSO := SO(StringReplace(Value, #9, '', [rfReplaceAll]));
  if LSO = nil then
  begin
    ShowMessage('JSON不正确！');
    Exit;
  end;

  LOldValue := FValue;
   
  FValue := LSO;

  DoParseValue(LOldValue);
end;

procedure TVSTDemoBehavior.VSTGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: {$IF CompilerVersion > 15.0 }string{$ELSE}WideString{$IFEND});
var
  jChilds, jRow, jDatas: TSuperArray;
begin
  jDatas := nil;
  if column < 0 then
    Exit;
  
  case Sender.GetNodeLevel(Node) of
    0:
    begin
      jDatas := FDatas;
    end;
    1:
    begin
      if Node.Parent = nil then
        Exit;
        
      jChilds := FDatas.O[Node.Parent.Index].A['childs'];
      if jChilds = nil then
        Exit;

      jDatas := jChilds;
    end;
  end;
  if jDatas = nil then
    Exit;

  jRow := jDatas.O[Node.Index].A['row'];
  if jRow = nil then
    Exit;

  if Column > jRow.Length then
    Exit;

  CellText := jRow.O[column].S['text'];
end;

procedure TVSTDemoBehavior.VSTInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
var
  jChilds: TSuperArray;
begin
  jChilds := FDatas.O[Node.Index].A['childs'];
  if (jChilds <> nil) and (jChilds.Length > 0) then
    ChildCount := jChilds.Length;
end;

procedure TVSTDemoBehavior.VSTInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  jChilds: TSuperArray;
begin
  case Sender.GetNodeLevel(Node) of
    0:
    begin
      jChilds := FDatas.O[Node.Index].A['childs'];

      if (jChilds <> nil) and (jChilds.Length > 0) then
        Include(InitialStates, ivsHasChildren);
    end;
    1:
    begin
    
    end;
  end;
end;

end.
