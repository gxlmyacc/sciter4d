{*******************************************************************************
 标题:     SciterArchiveImpl.pas
 描述:     sciter自带的打包资源的解析对象 实现单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterArchiveImpl;

interface

uses
  SysUtils, Classes, Windows, SciterTypes, SciterIntf, SciterArchiveIntf;

type
  TSciterArchive = class(TInterfacedObject, ISciterArchive)
  private
    FStream: TMemoryStream;
    FHandle: HSARCHIVE;
    FHandleOwner: Boolean;
  private
    function GetActive: Boolean;
    function GetHandle: HSARCHIVE;
    function GetHandleOwner: Boolean;
    procedure SetHandle(const Value: HSARCHIVE);
    procedure SetHandleOwner(const Value: Boolean);
  public
    constructor Create();
    destructor Destroy; override;

    // open archive blob:
    function  Open(data: LPCBYTE; data_length: UINT): Boolean; overload;
    function  Open(const filename: SciterString): Boolean; overload;
    function  Open(const stream: TMemoryStream; Owner: Boolean): Boolean; overload;
    procedure Close();

    // get archive item:
    function Get(path: LPCWSTR; var data: LPCBYTE; var data_length: UINT): Boolean;

    property Active: Boolean read GetActive;
    property Handle: HSARCHIVE read GetHandle write SetHandle;
    property HandleOwner: Boolean read GetHandleOwner write SetHandleOwner;
  end;

implementation

uses
  SciterApiImpl;

{ TSciterArchive }

procedure TSciterArchive.Close;
begin
  if (FHandle <> nil) and FHandleOwner then SAPI.SciterCloseArchive(FHandle);
  if FStream <> nil then FreeAndNil(FStream);
  FHandle := nil;
  FHandleOwner := True;
end;

constructor TSciterArchive.Create;
begin
  FHandleOwner := True;
end;

destructor TSciterArchive.Destroy;
begin
  Close;
  inherited;
end;

function TSciterArchive.Get(path: LPCWSTR; var data: LPCBYTE;
  var data_length: UINT): Boolean;
begin
  Result := False;
  data := nil;
  data_length := 0;
  if not GetActive then Exit;
  if (path[0] = '/') and (path[1] = '/') then
    path := path + 2;
  Result := SAPI.SciterGetArchiveItem(FHandle, path,data,data_length);
end;

function TSciterArchive.GetActive: Boolean;
begin
  Result := FHandle <> nil;
end;

function TSciterArchive.GetHandle: HSARCHIVE;
begin
  Result := FHandle;
end;

function TSciterArchive.GetHandleOwner: Boolean;
begin
  Result := FHandleOwner;
end;

function TSciterArchive.Open(data: LPCBYTE; data_length: UINT): Boolean;
var
  ms: TMemoryStream;
begin
  Close();
  Result := False;
  if data = nil then Exit;
  if data_length <= 3 then Exit;
  ms := TMemoryStream.Create;
  ms.SetSize(data_length);
  CopyMemory(ms.Memory, data, data_length);
  Result := Open(ms, True);
end;

function TSciterArchive.Open(const filename: SciterString): Boolean;
var
  ms: TMemoryStream;
begin
  Close();
  Result := False;
  if not FileExists(filename) then Exit;
  ms := TMemoryStream.Create;
  ms.LoadFromFile(filename);
  Result := Open(ms, True);
end;

function TSciterArchive.Open(const stream: TMemoryStream; Owner: Boolean): Boolean;
var
  data: PAnsiChar;
begin
  Result := False;
  if stream = nil then Exit;
  if stream.Size <= 3 then Exit;
  data := stream.Memory;
  if (data[0] = 'd') and (data[1] = 'a') and (data[2] = 't') then
    CopyMemory(data, PAnsiChar('SAr'), 3);
  FHandle := SAPI.SciterOpenArchive(data, stream.Size);
  Result := Self.Active;
  if Result then FStream := stream
  else if Owner then stream.Free;
end;

procedure TSciterArchive.SetHandle(const Value: HSARCHIVE);
begin
  Close();
  FHandle := Value;
  FHandleOwner := False;
end;

procedure TSciterArchive.SetHandleOwner(const Value: Boolean);
begin
  FHandleOwner := Value;
end;

end.
