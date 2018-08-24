{*******************************************************************************
 标题:     TiscriptStream.pas
 描述:     Tiscript流对象定义单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit TiscriptStream;

interface

uses
  SysUtils, Windows, Classes, SciterTypes, TiscriptTypes, TiscriptIntf;

type
  TTiscriptStream = class(TInterfacedObject, ITiscriptStream)
  private
    FValue: tiscript_stream;
    FStreamName: SciterString;
  protected
    function  GetData: Ptiscript_stream; virtual;
    function  GetStreamName: SciterString; virtual;
    procedure SetData(const Value: Ptiscript_stream); virtual;
    procedure SetStreamName(const Value: SciterString); virtual;
  public
    constructor Create();
    destructor Destroy; override;

    // these need to be overrided
    function  Read: Integer; virtual;
    function  Write(const value: Integer): Boolean; virtual;
    procedure Close(); virtual;

    function SaveToFile(const filename: SciterString): Boolean; virtual; 

    property StreamName: SciterString read GetStreamName write SetStreamName;
    property Data: Ptiscript_stream read GetData write SetData;
  end;

  TTiscriptStringInputStream = class(TTiscriptStream, ITiscriptStringInputStream)
  private
    FStr: SciterString;
    FPos: PWideChar;
    FEnd: PWideChar;
  public
    constructor Create(const str: SciterString);
    function  Read: Integer; override;
  end;

  // various stream implementations
  TTiscriptStringOutputStream = class(TTiscriptStream, ITiscriptStringOutputStream)
  private
    FStr: PWideChar;
    FPos: PWideChar;
    FEnd: PWideChar;
    function GetDataString: SciterString;
  public
    constructor Create();
    function  Write(const value: Integer): Boolean; override;
    procedure Close(); override;

    function SaveToFile(const filename: SciterString): Boolean; override; 

    property DataString: SciterString read GetDataString;
  end;

  // simple file input stream.
  TTiscriptFileStream = class(TTiscriptStream, ITiscriptFileStream)
  private
    FFile: TStream;
  public
    constructor Create(const filename: SciterString);
    function  Read: Integer; override;
    function  Write(const value: Integer): Boolean; override;
    procedure Close(); override;
    function SaveToFile(const filename: SciterString): Boolean; override; 
  end;

implementation

uses
  SciterExportDefs;

function _stream_input(tag: Ptiscript_stream; pv: PInteger): Boolean; cdecl;
begin
  pv^ := TTiscriptStream(tag.tag).Read;
  Result := pv^ >= 0;
end;

function _stream_output(tag: Ptiscript_stream; v: Integer): Boolean; cdecl;
begin
  Result := TTiscriptStream(tag.tag).Write(v)
end;

function _stream_name(tag: Ptiscript_stream): PWideChar; cdecl;
begin
  Result := PWideChar(TTiscriptStream(tag.tag).FStreamName);
end;

procedure _stream_close(tag: Ptiscript_stream); cdecl;
begin
  TTiscriptStream(tag.tag).Close;
end;

var
  _methods: tiscript_stream_vtbl = (
    input:    _stream_input;
    output:   _stream_output;
    get_name: _stream_name;
    close:    _stream_close
  );

{ TTiscriptStream }

procedure TTiscriptStream.Close;
begin

end;

constructor TTiscriptStream.Create;
begin
  FStreamName := Self.ClassName;
  FValue.vtbl := @_methods;
  FValue.tag  := Self;
end;

destructor TTiscriptStream.Destroy;
begin
  Close;
  inherited;
end;

function TTiscriptStream.Read: Integer;
begin
  Result := -1;
end;

function TTiscriptStream.GetData: Ptiscript_stream;
begin
  Result := @FValue;
end;

function TTiscriptStream.Write(const value: Integer): Boolean;
begin
  Result := False;
end;

procedure TTiscriptStream.SetData(const Value: Ptiscript_stream);
begin
  if Value = nil then
    ZeroMemory(@FValue, SizeOf(tiscript_stream))
  else
    FValue := Value^;
end;

function TTiscriptStream.GetStreamName: SciterString;
begin
  Result := '';
end;

procedure TTiscriptStream.SetStreamName(const Value: SciterString);
begin
  FStreamName := Value;
end;

function TTiscriptStream.SaveToFile(const filename: SciterString): Boolean;
begin
  Result := False;
end;

{ TTiscriptStringOutputStream }

procedure TTiscriptStringOutputStream.Close;
begin
  if FStr <> nil then
  begin
    FreeMem(FStr);
    FStr := nil;
    FPos := nil;
    FEnd := nil;
  end;
end;

constructor TTiscriptStringOutputStream.Create();
begin
  inherited Create;
  FStr := AllocMem(128 * SizeOf(SciterChar));
  FPos := FStr;
  FEnd := FPos + 128;
end;

function TTiscriptStringOutputStream.Write(const value: Integer): Boolean;
var
  sz, nsz: Cardinal;
  nstr: PWideChar;
begin
  if FPos >= FEnd then
  begin               
    sz := FEnd - FStr;
    nsz := (sz * 2) div 3;
    if nsz < 128 then
      nsz := 128;
    nstr := ReallocMemory(FStr, nsz * SizeOf(SciterChar));
    if (nstr = nil) then
    begin
      Result := False;
      Exit;
    end;
    FStr := nstr;
    FPos := FStr + sz;
    FEnd := FStr + nsz;
  end;
  FPos^  := WideChar(value);
  FPos   := FPos + 1;
  Result := True;
end;

function TTiscriptStringOutputStream.GetDataString: SciterString;
begin
  write(0);
  FPos := FPos - 1;
  Result := FStr;
end;

function TTiscriptStringOutputStream.SaveToFile(const filename: SciterString): Boolean;
var
  ms: TMemoryStream;
  p: PAnsiChar;
begin
  ms := TMemoryStream.Create;
  try
    p := @FStr[0];
    while p < FPos do
    begin
      ms.Write(p^, SizeOf(AnsiChar));
      p := p  + 1;
    end;
    ms.SaveToFile(filename);
    Result := True;
  finally
    ms.Free;
  end;   
end;


{ TTiscriptFileStream }

procedure TTiscriptFileStream.Close;
begin
  if FFile <> nil then
  begin
    FreeAndNil(FFile);
  end;
end;

constructor TTiscriptFileStream.Create(const filename: SciterString);
begin
  inherited Create;
  FStreamName := ExtractFileName(filename);
  FFile := _LoadFileToMemoryStream(filename);
end;

function TTiscriptFileStream.Read: Integer;
var
  c: AnsiChar;
begin
  if FFile.Read(c, 1) = 0 then
    Result := -1
  else
  begin
    Result := Ord(c);
  end;
end;

function TTiscriptFileStream.SaveToFile(
  const filename: SciterString): Boolean;
var
  fs: TFileStream;
  pos: Int64;
begin
  Result := False;
  if FFile = nil then
    Exit;
  pos := FFile.Position;
  fs := TFileStream.Create(filename, fmCreate or fmOpenWrite);
  try
    FFile.Position := 0;
    fs.CopyFrom(fs, FFile.Size);
  finally
    FFile.Position := pos;
    fs.Free;
  end;
  Result := True;
end;

function TTiscriptFileStream.Write(const value: Integer): Boolean;
begin
  Result := False; //FFile.Write(value, SizeOf(Integer)) = SizeOf(Integer);
end;

{ TTiscriptStringInputStream }

constructor TTiscriptStringInputStream.Create(const str: SciterString);
var
  len: Integer;
begin
  inherited Create;
  FStr := str;
  len := Length(FStr);
  FPos := PSciterChar(FStr);
  FEnd := FPos + len;
end;

function TTiscriptStringInputStream.Read: Integer;
begin
  if (FPos^ <> #0) and (FPos < FEnd) then
  begin
    FPos := FPos + 1;
    Result := Integer(FPos^);
  end
  else
    Result := -1;
end;

end.


