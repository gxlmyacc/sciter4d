{*******************************************************************************
 标题:     SciterHash.pas
 描述:     Sciter4D中使用的Hash列表
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterHash;

interface

uses
  SysUtils, Classes;

type
  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Next: PHashItem;
    Key: string;
    Value: Integer;
  end;

  TStringHash = class
  private
    Buckets: array of PHashItem;
  protected
    function Find(const Key: string): PPHashItem;
    function HashOf(const Key: string): Cardinal; virtual;
  public
    constructor Create(Size: Cardinal = 256);
    destructor Destroy; override;

    function Exits(const Key: string): Boolean;

    procedure Add(const Key: string; Value: Integer);
    procedure Clear;
    procedure Remove(const Key: string);
    function Modify(const Key: string; Value: Integer): Boolean;
    function ValueOf(const Key: string): Integer;
  end;

  { THashedStringList - A TStringList that uses TStringHash to improve the
    speed of Find }
  THashedStringList = class(TStringList)
  private
    FValueHash: TStringHash;
    FNameHash: TStringHash;
    FValueHashValid: Boolean;
    FNameHashValid: Boolean;
    procedure UpdateValueHash;
    procedure UpdateNameHash;
  protected
    procedure Changed; override;
  public
    destructor Destroy; override;
    function IndexOf(const S: string): Integer; override;
    function IndexOfName(const Name: string): Integer; override;
  end;

  PMethod = ^TMethod;
  TMethodList = class
  private
    FList: TList;
  protected
    function Get(Index: Integer): PMethod;
    function GetCount: Integer;
  public
    constructor Create();
    destructor Destroy; override;
    function Add(const Item: TMethod): Integer;
    function IndexOf(const Item: TMethod): Integer;
    procedure Clear; 
    procedure Delete(Index: Integer);
    function First: PMethod;
    function Last: PMethod;
    function Remove(const Item: TMethod): Integer;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: PMethod read Get; default;
  end;

implementation

{ TStringHash }

procedure TStringHash.Add(const Key: string; Value: Integer);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.Value := Value;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
end;

procedure TStringHash.Clear;
var
  I: Integer;
  P, N: PHashItem;
begin
  for I := 0 to Length(Buckets) - 1 do
  begin
    P := Buckets[I];
    while P <> nil do
    begin
      N := P^.Next;
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
end;

constructor TStringHash.Create(Size: Cardinal);
begin
  inherited Create;
  SetLength(Buckets, Size);
end;

destructor TStringHash.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TStringHash.Exits(const Key: string): Boolean;
begin
  Result := Find(Key)^ <> nil;
end;

function TStringHash.Find(const Key: string): PPHashItem;
var
  Hash: Integer;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  Result := @Buckets[Hash];
  while Result^ <> nil do
  begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;

function TStringHash.HashOf(const Key: string): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(Key) do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
      Ord(Key[I]);
end;

function TStringHash.Modify(const Key: string; Value: Integer): Boolean;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    P^.Value := Value;
  end
  else
    Result := False;
end;

procedure TStringHash.Remove(const Key: string);
var
  P: PHashItem;
  Prev: PPHashItem;
begin
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then
  begin
    Prev^ := P^.Next;
    Dispose(P);
  end;
end;

function TStringHash.ValueOf(const Key: string): Integer;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := -1;
end;

{ THashedStringList }

procedure THashedStringList.Changed;
begin
  inherited Changed;
  FValueHashValid := False;
  FNameHashValid := False;
end;

destructor THashedStringList.Destroy;
begin
  if FValueHash <> nil then
    FreeAndNil(FValueHash);
  if FNameHash <> nil then
    FreeAndNil(FNameHash);
  inherited Destroy;
end;

function THashedStringList.IndexOf(const S: string): Integer;
begin
  UpdateValueHash;
  if not CaseSensitive then
    Result :=  FValueHash.ValueOf(AnsiUpperCase(S))
  else
    Result :=  FValueHash.ValueOf(S);
end;

function THashedStringList.IndexOfName(const Name: string): Integer;
begin
  UpdateNameHash;
  if not CaseSensitive then
    Result := FNameHash.ValueOf(AnsiUpperCase(Name))
  else
    Result := FNameHash.ValueOf(Name);
end;

procedure THashedStringList.UpdateNameHash;
var
  I: Integer;
  P: Integer;
  Key: string;
begin
  if FNameHashValid then Exit;
  
  if FNameHash = nil then
    FNameHash := TStringHash.Create
  else
    FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := Get(I);
    P := AnsiPos(NameValueSeparator, Key);
    if P <> 0 then
    begin
      if not CaseSensitive then
        Key := AnsiUpperCase(Copy(Key, 1, P - 1))
      else
        Key := Copy(Key, 1, P - 1);
      FNameHash.Add(Key, I);
    end;
  end;
  FNameHashValid := True;
end;

procedure THashedStringList.UpdateValueHash;
var
  I: Integer;
begin
  if FValueHashValid then Exit;
  
  if FValueHash = nil then
    FValueHash := TStringHash.Create
  else
    FValueHash.Clear;
  for I := 0 to Count - 1 do
    if not CaseSensitive then
      FValueHash.Add(AnsiUpperCase(Self[I]), I)
    else
      FValueHash.Add(Self[I], I);
  FValueHashValid := True;
end;

{ TMethodList }

function TMethodList.Add(const Item: TMethod): Integer;
var
  pData: PMethod;
begin
  New(pData);
  pData^ := TMethod(Item);
  Result := FList.Add(pData);
end;

procedure TMethodList.Clear;
var
  pData: PMethod;
  i: Integer;
begin
  for i := FList.Count - 1  downto 0 do
  begin
    pData := FList[i];
    if pData <> nil then
      Dispose(pData);
  end;
  FList.Clear;
end;

constructor TMethodList.Create;
begin
  FList := TList.Create;
end;

procedure TMethodList.Delete(Index: Integer);
var
  pData: PMethod;
begin
  pData := FList[Index];
  if pData <> nil then
    Dispose(pData);
  FList.Delete(Index);
end;

destructor TMethodList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TMethodList.First: PMethod;
begin
  if FList.Count > 0 then
    Result := PMethod(FList.First)
  else
    Result := nil;
end;

function TMethodList.Get(Index: Integer): PMethod;
begin
  Result := PMethod(FList[Index]);
end;

function TMethodList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TMethodList.IndexOf(const Item: TMethod): Integer;
var
  pData: PMethod;
begin
  for Result := 0 to FList.Count - 1 do
  begin
    pData := FList[Result];
    if (pData.Code = TMethod(Item).Code) and (pData.Data = TMethod(Item).Data) then
      Exit;
  end;
  Result := -1;
end;

function TMethodList.Last: PMethod;
begin
  if FList.Count > 0 then
    Result := PMethod(FList.Last)
  else
    Result := nil;
end;

function TMethodList.Remove(const Item: TMethod): Integer;
begin
  Result := IndexOf(Item);
  if Result >= 0 then
    Delete(Result);
end;

end.
