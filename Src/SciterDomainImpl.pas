{*******************************************************************************
 标题:     SciterDomainImpl.pas
 描述:     Sciter域对象的定义实现单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDomainImpl;

interface

uses
  SysUtils, Classes, SciterTypes, SciterHash, SciterURIIntf, SciterDomainIntf;

type
  TSciterDomain = class(TInterfacedObject, ISciterDomain)
  private
    FList: TStringList;
    FNameHash: TStringHash;
    FNameHashValid: Boolean;
    FParent: TSciterDomain;
    FName: SciterString;
    FLevel: Integer;
    FData1: Pointer;
    FData2: Pointer;
  protected
    function  GetName: SciterString;
    function  GetLevel: Integer;
    function  GetCount: Integer;
    function  GetParent: ISciterDomain;
    function  GetPath: SciterString;
    function  GetData1: Pointer;
    function  GetData2: Pointer;
    function  GetDomain(const Index: Integer): PSciterDomainValueRec;
    function  GetDomainName(const Index: Integer): SciterString;
    function  GetDomainByName(const AName: SciterString): PSciterDomainValueRec;
    procedure SetName(const Value: SciterString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
  protected
    procedure UpdateNameHash;
  public
    constructor Create(const AName: SciterString; AParent: TSciterDomain = nil);
    destructor Destroy; override;

    function  Implementator: Pointer;
    function  URIToFilePath(const AURL: ISciterURI; var APath: SciterString): Boolean;

    function  Add(const AName, AValue: SciterString): Integer;
    procedure Clear;
    procedure Delete(const Index: Integer);
    procedure Insert(const Index: Integer; const AName, AValue: SciterString);

    function  IndexOf(const AName: SciterString): Integer;
    procedure Invalidate;

    function ToURI: SciterString;

    function URIToPath(const AURI: SciterString): SciterString; overload;
    function URIToPath(const AURI: ISciterURI): SciterString; overload;

    function URIToDomain(const AURI: SciterString): ISciterDomain; overload;
    function URIToDomain(const AURI: ISciterURI): ISciterDomain; overload;

    property Name: SciterString read GetName write SetName;
    property Level: Integer read GetLevel;
    property Parent: ISciterDomain read GetParent;
    property Path: SciterString read GetPath;

    property Count: Integer read GetCount;
    property DomainName[const Index: Integer]: SciterString read GetDomainName;
    property Domain[const Index: Integer]: PSciterDomainValueRec read GetDomain; default;
    property DomainByName[const AName: SciterString]: PSciterDomainValueRec read GetDomainByName;
    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;
  end;

implementation

uses
  SciterApiImpl, SciterExportDefs;

{ TSciterDomain }

function TSciterDomain.Add(const AName, AValue: SciterString): Integer;
var
  i: Integer;
  LRec: PSciterDomainValueRec;
begin
  i := IndexOf(AName);
  if i < 0 then
  begin
    New(LRec);
    LRec.Value := AValue;
    LRec.Domain := TSciterDomain.Create(AName, Self);
    Result := FList.AddObject(AName, TObject(LRec));
    FNameHash.Add(AnsiUpperCase(AName), Result);
  end
  else
  begin
    LRec := PSciterDomainValueRec(FList.Objects[i]);
    LRec.Value := AValue;
    Result := i;
  end;
end;

procedure TSciterDomain.Clear;
var
  i: Integer;
  LRec: PSciterDomainValueRec;
begin
  for i := FList.Count - 1 downto 0 do
  try
    LRec := PSciterDomainValueRec(FList.Objects[i]);
    LRec.Domain := nil;
    Dispose(LRec);
  except
    on E: Exception do
      TraceException('[TSciterDomain.Clear]'+E.Message);
  end;
  FList.Clear;
  FNameHashValid := False;
end;

constructor TSciterDomain.Create(const AName: SciterString; AParent: TSciterDomain);
begin
  FName := AName;
  FParent := AParent;
  FList := TStringList.Create;
  FNameHash := TStringHash.Create(1024);
  if FParent = nil then
    FLevel := 0
  else
    FLevel := FParent.Level + 1;
end;

procedure TSciterDomain.Delete(const Index: Integer);
var
  LRec: PSciterDomainValueRec;
begin
  LRec := PSciterDomainValueRec(FList.Objects[Index]);
  LRec.Domain := nil;
  Dispose(LRec);
  FList.Delete(Index);
  FNameHashValid := False;
end;

destructor TSciterDomain.Destroy;
begin
  Clear;
  if FNameHash <> nil then
    FreeAndNil(FNameHash);
  if FList <> nil then
    FreeAndNil(FList);
  inherited;
end;

function TSciterDomain.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TSciterDomain.GetData1: Pointer;
begin
  Result := FData1;
end;

function TSciterDomain.GetData2: Pointer;
begin
  Result := FData2;
end;

function TSciterDomain.GetDomain(const Index: Integer): PSciterDomainValueRec;
begin
  Result := PSciterDomainValueRec(FList.Objects[Index]);
end;

function TSciterDomain.GetDomainByName(
  const AName: SciterString): PSciterDomainValueRec;
var
  i: Integer;
begin
  i := IndexOf(AName);
  if i >= 0 then
    Result := GetDomain(i)
  else
    Result := nil;
end;

function TSciterDomain.GetDomainName(const Index: Integer): SciterString;
begin
  Result := FList[index]
end;

function TSciterDomain.GetLevel: Integer;
begin
  Result := FLevel
end;

function TSciterDomain.GetName: SciterString;
begin
  Result := FName;
end;

function TSciterDomain.GetParent: ISciterDomain;
begin
  Result := FParent;
end;

function TSciterDomain.GetPath: SciterString;
var
  LDomain: TSciterDomain;
begin
  Result := EmptyStr;
  LDomain := FParent;
  if LDomain = nil then
    Result := EmptyStr
  else
    Result := LDomain.Path + LDomain.DomainByName[FName].Value;
end;

function TSciterDomain.Implementator: Pointer;
begin
  Result := Self;
end;

function TSciterDomain.IndexOf(const AName: SciterString): Integer;
begin
  UpdateNameHash;
  Result := FNameHash.ValueOf(AnsiUpperCase(AName))
end;


procedure TSciterDomain.Insert(const Index: Integer; const AName,
  AValue: SciterString);
var
  LRec: PSciterDomainValueRec;
begin
  New(LRec);
  LRec.Value := AValue;
  LRec.Domain := TSciterDomain.Create(AName, Self);
  FList.InsertObject(Index, AName, TObject(LRec));
  FNameHashValid := False;
end;

procedure TSciterDomain.Invalidate;
begin
  FNameHashValid := False;
end;

procedure TSciterDomain.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TSciterDomain.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

procedure TSciterDomain.SetName(const Value: SciterString);
begin
  FName := Value;
end;

function TSciterDomain.ToURI: SciterString;
begin
  if FParent = nil then
    Result := ''
  else
    Result := FParent.ToURI + '.' + FName;
end;

procedure TSciterDomain.UpdateNameHash;
var
  I: Integer;
  Key: string;
begin
  if FNameHashValid then Exit;
  FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := AnsiUpperCase(FList[I]);
    FNameHash.Add(Key, I);
  end;
  FNameHashValid := True;
end;

function TSciterDomain.URIToDomain(
  const AURI: ISciterURI): ISciterDomain;
var
  i: Integer;
  sHostName: SciterString;
  LDomans: ISciterDomain;
  LResult: ISciterDomain;
  LRec: PSciterDomainValueRec;
begin
  Result := nil;
  if AURI = nil then
    Exit;
  if AURI.HostCount = 0 then
    Exit;

  LResult :=  nil;
  LDomans := Self;
  for i := 0 to AURI.HostCount - 1 do
  begin
    sHostName := AURI.HostValue[i];

    LRec := LDomans.DomainByName[sHostName];
    if LRec = nil then
      Exit;

    if i = (AURI.HostCount - 1) then
      LResult := LRec.Domain;

    LDomans := LRec.Domain;
  end;

  Result := LResult;
end;

function TSciterDomain.URIToDomain(const AURI: SciterString): ISciterDomain;
begin
  Result := nil;
  if AURI = '' then
    Exit;
  Result := URIToDomain(__SciterCreateURI(AURI));
end;

function TSciterDomain.URIToFilePath(const AURL: ISciterURI; var APath: SciterString): Boolean;
var
  LDomains: ISciterDomain;
  i, j: Integer;
  sValue: SciterString;
  LRec: PSciterDomainValueRec;
begin
  Result := False;

  {$IF CompilerVersion < 18.5}
  LRec := nil;
  {$IFEND}
  LDomains := __SciterTopDomain^;
  for i := 0 to AURL.HostCount - 1 do
  begin
    sValue := AURL.HostValue[i];
                
    if LDomains = nil then
    begin
      TraceError(Format('未找到[%s]域名的解析内容：没有%d级域名！', [sValue, i + 1]));
      Exit;        
    end;

    j := LDomains.IndexOf(sValue);
    if j >= 0 then
    begin
      LRec := LDomains[j];
      APath := APath + LRec.Value;
    end
    else
    begin
      TraceError(Format('未找到[%s]域名的解析内容！', [sValue]));
      Exit;
    end;

    if (LRec <> nil) and (LRec.Domain <> nil) then
      LDomains := LRec.Domain
    else
      LDomains := nil;
  end;

  APath := APath + StringReplace(AURL.Path, '/' , '\', [rfReplaceAll]);
  
  if AURL.Port <> '' then
    APath := APath + AURL.Port + '\';

  APath := APath + AURL.Document;

  Result := True;
end;

function TSciterDomain.URIToPath(const AURI: ISciterURI): SciterString;
var
  i: Integer;
  sHostName: SciterString;
  LDomans: ISciterDomain;
  LRec: PSciterDomainValueRec;
  sResult: SciterString;
begin
  Result := EmptyStr;
  if AURI = nil then
    Exit;
  if AURI.HostCount = 0 then
    Exit;

  LDomans := Self;
  for i := 0 to AURI.HostCount - 1 do
  begin
    sHostName := AURI.HostValue[i];

    LRec := LDomans.DomainByName[sHostName];
    if LRec = nil then
      Exit;
    sResult := sResult + LRec.Value;
    LDomans := LRec.Domain;
  end;

  Result := sResult;
end;

function TSciterDomain.URIToPath(const AURI: SciterString): SciterString;
begin
  Result := EmptyStr;
  if AURI = '' then
    Exit;
  Result := URIToPath(__SciterCreateURI(AURI));
end;

end.
