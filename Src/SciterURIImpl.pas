{*******************************************************************************
 标题:     SciterURIImpl.pas
 描述:     URL工具类的实现单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterURIImpl;

interface

uses
  SysUtils, SciterApiImpl, SciterURIIntf, SciterTypes;

type
  TSciterURIValue = record
    Name: SciterString;
    Value: SciterString;
  end;
  
  TSciterURI = class(TSciterRttiObject, ISciterURI, IObjectInterface)
  private
    FDocumentNoExt: SciterString;
    FExt: SciterString;
    FProtocol: SciterString;
    FURI: SciterString;
    FPort: SciterString;

    FBookmark: SciterString;
    FUserName: SciterString;
    FPassword: SciterString;

    FPath: SciterString;
    FPaths: array of SciterString;
    FPathsChanged: Boolean;
        
    FHost: SciterString;
    FHosts: array of SciterString;
    FHostsChanged: Boolean;

    FParamStr: SciterString;
    FParams: array of TSciterURIValue;
    FParamChanged: Boolean;

    FDestroying: Boolean;

    FData1: Pointer;
    FData2: Pointer;

    FOnGetDefaultPort: ISciterURIGetDefaultPortProc;
    FOnToFilePath: ISciterURIToFilePathProc;
    FOnDestroy: ISciterURIDestroyProc;
  protected
    function GetBookmark: SciterString;
    function GetDocument: SciterString;
    function GetExt: SciterString;
    function GetDocumentNoExt: SciterString;
    function GetHost: SciterString;
    function GetParamStr: SciterString;
    function GetPassword: SciterString;
    function GetPath: SciterString;
    function GetPort: SciterString;
    function GetProtocol: SciterString;
    function GetUserName: SciterString;
    function GetURI: SciterString;
    function GetHostCount: Integer;
    function GetHostValue(const AIndex: Integer): SciterString;
    function GetPathCount: Integer;
    function GetPathValue(const AIndex: Integer): SciterString;
    function GetParamCount: Integer;
    function GetParamName(const AIndex: Integer): SciterString;
    function GetParamValue(const AName: SciterString): SciterString;
    function GetParamValueFromIndex(const AIndex: Integer): SciterString;
    function GetData1: Pointer;
    function GetData2: Pointer;
    function GetOnGetDefaultPort: ISciterURIGetDefaultPortProc;
    function GetOnToFilePath: ISciterURIToFilePathProc;
    function GetOnDestroy: ISciterURIDestroyProc;
    procedure SetBookMark(const Value: SciterString);
    procedure SetDocument(const Value: SciterString);
    procedure SetExt(const Value: SciterString);
    procedure SetDocumentNoExt(const Value: SciterString);
    procedure SetHost(const Value: SciterString);
    procedure SetParamStr(const Value: SciterString);
    procedure SetPassword(const Value: SciterString);
    procedure SetPath(const Value: SciterString);
    procedure SetPort(const Value: SciterString);
    procedure SetProtocol(const Value: SciterString);
    procedure SetUserName(const Value: SciterString);
    procedure SetURI(const Value: SciterString);
    procedure SetHostValue(const AIndex: Integer; const Value: SciterString);
    procedure SetPathValue(const AIndex: Integer; const Value: SciterString);
    procedure SetParamValue(const AName, Value: SciterString);
    procedure SetParamValueFromIndex(const AIndex: Integer; const Value: SciterString);
    procedure SetData1(const Value: Pointer);
    procedure SetData2(const Value: Pointer);
    procedure SetOnGetDefaultPort(const Value: ISciterURIGetDefaultPortProc);
    procedure SetOnToFilePath(const Value: ISciterURIToFilePathProc);
    procedure SetOnDestroy(const Value: ISciterURIDestroyProc);
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    
    procedure DoDestroy;
  public
    constructor Create(const AURI: SciterString = ''); virtual;
    destructor Destroy; override;

    function  ToURI(const AOptionalFileds: TSciterURIOptionalFieldsSet = [ofAuthInfo, ofBookmark, ofParams]): SciterString;
    function  ToFilePath(var APath: SciterString): Boolean;

    function  HasParam(const AName: SciterString): Boolean;
    function  IndexOfParam(const AName: SciterString): Integer;
    function  AddParam(const AName, AValue: SciterString): Integer;

    procedure NormalizePath(var APath: SciterString);
    function  URLDecode(const ASrc: SciterString): SciterString;
    function  URLEncode(const ASrc: SciterString): SciterString;
    function  ParamsEncode(const ASrc: SciterString): SciterString;
    function  PathEncode(const ASrc: SciterString): SciterString;

    property Bookmark: SciterString read GetBookmark write SetBookMark;
    property Document: SciterString read GetDocument write SetDocument;
    property Ext: SciterString read GetExt write SetExt;
    property DocumentNoExt: SciterString read GetDocumentNoExt write SetDocumentNoExt;
    property Host: SciterString read GetHost write SetHost;
    property Password: SciterString read GetPassword write SetPassword;
    property Path: SciterString read GetPath write SetPath;
    property ParamStr: SciterString read GetParamStr write SetParamStr;
    property Port: SciterString read GetPort write SetPort;
    property Protocol: SciterString read GetProtocol write SetProtocol;
    property URI: SciterString read GetURI write SetURI;
    property Username: SciterString read GetUserName write SetUserName;

    property HostCount: Integer read GetHostCount;
    property HostValue[const AIndex: Integer]: SciterString read GetHostValue write SetHostValue;

    property PathCount: Integer read GetPathCount;
    property PathValue[const AIndex: Integer]: SciterString read GetPathValue write SetPathValue;

    property ParamCount: Integer read GetParamCount;
    property ParamName[const AIndex: Integer]: SciterString read GetParamName;
    property ParamValue[const AName: SciterString]: SciterString read GetParamValue write SetParamValue; default;
    property ParamValueFromIndex[const AIndex: Integer]: SciterString read GetParamValueFromIndex write SetParamValueFromIndex;

    property Data1: Pointer read GetData1 write SetData1;
    property Data2: Pointer read GetData2 write SetData2;

    property OnGetDefaultPort: ISciterURIGetDefaultPortProc read GetOnGetDefaultPort write SetOnGetDefaultPort;
    property OnToFilePath: ISciterURIToFilePathProc read GetOnToFilePath write SetOnToFilePath;
    property OnDestroy: ISciterURIDestroyProc read GetOnDestroy write SetOnDestroy;
  end;                            

  ESciterURIException = class(ESciterException);

implementation


const
  IdFetchDelimDefault = ' ';
  IdFetchDeleteDefault = true;
  IdFetchCaseSensitiveDefault = true;
resourcestring
  RSURINoProto                 = 'Protocol field is empty';
  RSURINoHost                  = 'Host field is empty';

function FetchCaseInsensitive(var AInput: SciterString; const ADelim: SciterString = IdFetchDelimDefault;
  const ADelete: Boolean = IdFetchDeleteDefault): SciterString;
var
  LPos: integer;
begin
  LPos := Pos(ADelim, AInput);
  if LPos = 0 then
  begin
    Result := AInput;
    if ADelete then
      AInput := '';
  end
  else
  begin
    Result := Copy(AInput, 1, LPos - 1);
    //This is faster than Delete(AInput, 1, LPos + Length(ADelim) - 1);
    if ADelete then
      AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
  end;
end;

function Fetch(var AInput: SciterString; const ADelim: SciterString = IdFetchDelimDefault;
  const ADelete: Boolean = IdFetchDeleteDefault;
  const ACaseSensitive: Boolean = IdFetchCaseSensitiveDefault): SciterString;
var
  LPos: integer;
begin
  if ACaseSensitive then
  begin
    // AnsiPos does not work with #0
    LPos := Pos(ADelim, AInput);
    if LPos = 0 then
    begin
      Result := AInput;
      if ADelete then
        AInput := '';
    end
    else
    begin
      Result := Copy(AInput, 1, LPos - 1);
      //slower Delete(AInput, 1, LPos + Length(ADelim) - 1);
      if ADelete then
        AInput := Copy(AInput, LPos + Length(ADelim), MaxInt);
    end;
  end
  else
    Result := FetchCaseInsensitive(AInput, ADelim, ADelete);
end;

// Find a token given a direction (>= 0 from start; < 0 from end)
// S.G. 19/4/00:
//  Changed to be more readable

function RPos(const ASub, AIn: SciterString; AStart: Integer = -1): Integer;
var
  i: Integer;
  LStartPos: Integer;
  LTokenLen: Integer;
  ASubLow: SciterString;
begin
  result := 0;
  LTokenLen := Length(ASub);
  // Get starting position
  if AStart = -1 then
    AStart := Length(AIn);
  if AStart < (Length(AIn) - LTokenLen + 1) then
    LStartPos := AStart
  else
    LStartPos := (Length(AIn) - LTokenLen + 1);
  // Search for the string
  ASubLow := WideLowerCase(ASub);
  for i := LStartPos downto 1 do
  begin
    if WideLowerCase(Copy(AIn, i, LTokenLen)) = ASubLow then
    begin
      Result := i;
      Break;
    end;
  end;
end;

constructor TSciterURI.Create(const AURI: SciterString = ''); {Do not Localize}
begin
  inherited Create;
  if Length(AURI) > 0 then
    SetURI(AURI);
end;

procedure TSciterURI.NormalizePath(var APath: SciterString);
var
  i, iLen: Integer;
begin
  // Normalize the directory delimiters to follow the UNIX syntax
  i := 1;
  iLen := Length(APath);
  while i <= iLen do
  begin
    if APath[i] = '\' then
      APath[i] := '/';
    inc(i, 1);
  end;
end;

procedure TSciterURI.SetURI(const Value: SciterString);
var
  LBuffer: SciterString;
  LTokenPos, LPramsPos: Integer;
  LURI, LDocument: SciterString;
begin
  FURI := Value;
  NormalizePath(FURI);
  LURI := FURI;
  Host := '';
  FProtocol := '';
  Path := '';
  FDocumentNoExt := '';
  FExt := '';
  Port := '';
  FBookmark := '';
  FUsername := '';
  FPassword := '';
  ParamStr := '';

  LTokenPos := Pos(SciterString(':'), LURI);
  if LTokenPos > 0 then
  begin
    // absolute URI
    // What to do when data don't match configuration ??
    // Get the protocol
    FProtocol := Copy(LURI, 1, LTokenPos - 1);
    if LURI[LTokenPos+1] = '/' then Delete(LURI, 1, LTokenPos + 2)
    else Delete(LURI, 1, LTokenPos);
    // Get the user name, password, host and the port number
    LBuffer := Fetch(LURI, '/', True);
    // Get username and password
    LTokenPos := Pos('@', LBuffer);
    FPassword := Copy(LBuffer, 1, LTokenPos - 1);
    if LTokenPos > 0 then
      Delete(LBuffer, 1, LTokenPos);
    FUserName := Fetch(FPassword, ':', True);
    // Ignore cases where there is only password (http://:password@host/pat/doc)
    if Length(FUserName) = 0 then
      FPassword := '';
    // Get the host and the port number
    Host := Fetch(LBuffer, ':', True);
    FPort := LBuffer;
    // Get the path
    LPramsPos := Pos('?', LURI);
    if LPramsPos > 0 then
    begin // The case when there is parameters after the document name '?'
      LTokenPos := RPos('/', LURI, LPramsPos);
    end
    else
    begin
      LPramsPos := Pos('=', LURI);
      if LPramsPos > 0 then
      begin // The case when there is parameters after the document name '='
        LTokenPos := RPos('/', LURI, LPramsPos);
      end
      else
        LTokenPos := RPos('/', LURI, -1);
    end;

    Path := '/' + Copy(LURI, 1, LTokenPos);
    // Get the document
    if LPramsPos > 0 then
    begin
      LDocument := Copy(LURI, 1, LPramsPos - 1);
      Delete(LURI, 1, LPramsPos - 1);
      ParamStr := LURI;
    end
    else
      LDocument := LURI;
    Delete(LDocument, 1, LTokenPos);
    FBookmark := LDocument;
    LDocument := Fetch(FBookmark, '#');
  end
  else
  begin
    // received an absolute path, not an URI
    LPramsPos := Pos('?', LURI);
    if LPramsPos > 0 then
    begin // The case when there is parameters after the document name '?'
      LTokenPos := RPos('/', LURI, LPramsPos);
    end
    else
    begin
      LPramsPos := Pos('=', LURI);
      if LPramsPos > 0 then
      begin // The case when there is parameters after the document name '='
        LTokenPos := RPos('/', LURI, LPramsPos);
      end
      else
        LTokenPos := RPos('/', LURI, -1);
    end;
    Path := Copy(LURI, 1, LTokenPos);
    // Get the document
    if LPramsPos > 0 then
    begin
      LDocument := Copy(LURI, 1, LPramsPos - 1);
      Delete(LURI, 1, LPramsPos - 1);
      ParamStr := LURI;
    end
    else
      LDocument := LURI;
    Delete(LDocument, 1, LTokenPos);
  end;

  FExt := ExtractFileExt(LDocument);
  FDocumentNoExt := Copy(LDocument, 1, Length(LDocument)- Length(FExt));

  if (FPort = '') and (@FOnGetDefaultPort <> nil) then
    FPort := FOnGetDefaultPort;
  // Parse the # bookmark from the document
  if Length(FBookmark) = 0 then
  begin
    FBookmark := FParamStr;
    ParamStr := Fetch(FBookmark, '#');
  end;
end;

function TSciterURI.GetURI: SciterString;
begin
  FURI := ToURI;
  // result must contain only the proto://host/path/document
  // If you need the full URI then you have to call GetFullURI
  Result := ToURI([]);
end;

function TSciterURI.URLDecode(const ASrc: SciterString): SciterString;
var
  i: integer;
  CharCode: integer;
  ESC, sSrc: string;
  sResult: UTF8String;
begin
  sResult := '';
  sSrc := StringReplace(ASrc, '+', ' ', [rfReplaceAll]);
  i := 1;
  while i <= Length(sSrc) do
  begin
    if sSrc[i] <> '%' then
    begin
      if sResult <> '' then
      begin
        Result := Result + {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(sResult);
        sResult := '';
      end;
      Result := Result + sSrc[i];
    end
    else
    begin
      Inc(i);
      ESC := Copy(sSrc, i, 2);
      Inc(i, 1);
      try
        CharCode := StrToInt('$' + ESC);
        if (CharCode > 0) and (CharCode < 256) then
          sResult := sResult + UTF8String(AnsiChar(CharCode));
      except
      end;
    end;
    Inc(i);
  end;
  if sResult <> '' then
    Result := Result + {$IF CompilerVersion > 18.5}UTF8ToString{$ELSE}UTF8Decode{$IFEND}(sResult);
end;

function TSciterURI.ParamsEncode(const ASrc: SciterString): SciterString;
var
  i: Integer;
  sSrc: UTF8String;
begin
  Result := '';
  sSrc := UTF8Encode(ASrc);
  for i := 0 to Length(sSrc)-1 do
  begin
    if sSrc[i] = ' ' then
      Result := Result + '+'
    else
    if not (sSrc[i] in ['A'..'Z','a'..'z','*','@','.','_','-', '0'..'9','$','!','''','(',')']) then
      Result := Result + '%' + IntToHex(Ord(ASrc[i]), 2)
    else
      Result := Result + ASrc[i];
  end;
end;

function TSciterURI.PathEncode(const ASrc: SciterString): SciterString;
const
  UnsafeChars = ['*', '#', '%', '<','>', '+', ' '];
var
  i: Integer;
  sSrc: UTF8String;
begin
  sSrc := UTF8Encode(ASrc);
  Result := '';
  for i := 1 to Length(sSrc) do
  begin
    if (sSrc[i] in UnsafeChars) or (sSrc[i] >= #$80) or (sSrc[1] < #32) then
      Result := Result + '%' + IntToHex(Ord(sSrc[i]), 2)
    else
      Result := Result + WideChar(sSrc[i]);
  end;
end;

function TSciterURI.URLEncode(const ASrc: SciterString): SciterString;
var
  LURI: TSciterURI;
begin
  LURI := TSciterURI.Create(ASrc);
  try
    LURI.Path := PathEncode(LURI.Path);
    LURI.Document := PathEncode(LURI.Document);
    LURI.ParamStr := ParamsEncode(LURI.ParamStr);
  finally
    result := LURI.URI;
    LURI.Free;
  end;
end;

function TSciterURI.ToURI(
  const AOptionalFileds: TSciterURIOptionalFieldsSet): SciterString;
begin
  if Length(FProtocol) = 0 then
    raise ESciterURIException.Create(RSURINoProto);
  Result := FProtocol + '://';
  if (Length(FUserName) > 0) and (ofAuthInfo in AOptionalFileds) then
  begin
    Result := Result + FUserName;
    if Length(FPassword) > 0 then
    begin
      Result := Result + ':' + FPassword;
    end;
    Result := Result + '@';
  end;
  if Length(FHost) = 0 then
    raise ESciterURIException.Create(RSURINoHost);
  Result := Result + FHost;
  if Length(FPort) > 0 then
    Result := Result + ':' + FPort
  else
  if SameText(FProtocol, 'file') then
    Result := Result + ':';
  Result := Result + Path + FDocumentNoExt + FExt;
  if (ofParams in AOptionalFileds) then
    Result := Result + GetParamStr;
  if (Length(FBookmark) > 0) and (ofBookmark in AOptionalFileds) then
    Result := Result + '#' + FBookmark;
end;

function TSciterURI.GetBookmark: SciterString;
begin
  Result := FBookmark;
end;

function TSciterURI.GetDocument: SciterString;
begin
  Result := FDocumentNoExt + FExt;
end;

function TSciterURI.GetHost: SciterString;
var
  sStr: SciterString;
  i: Integer;
begin
  if FHostsChanged then
  begin
    sStr := EmptyStr;
    for i := 0 to Length(FHosts) - 2 do
    begin
      sStr := sStr + FHosts[i] + '.';
    end;
    sStr := sStr + FHosts[High(FHosts)];

    FHost := sStr;
    FHostsChanged := False;
  end;
  Result := FHost;
end;

function TSciterURI.GetParamStr: SciterString;
var
  sParamStr: SciterString;
  i: Integer;
begin
  if FParamChanged then
  begin
    sParamStr :='?';
    for i := 0 to Length(FParams) - 2 do
    begin
      sParamStr := sParamStr + ParamsEncode(FParams[i].Name) + '=' + ParamsEncode(FParams[i].Value) + '&';
    end;
    sParamStr := sParamStr + ParamsEncode(FParams[High(FParams)].Name) + '=' + ParamsEncode(FParams[High(FParams)].Value);

    FParamStr := sParamStr;
    FParamChanged := False;
  end;
  Result := FParamStr;
end;

function TSciterURI.GetPassword: SciterString;
begin
  Result := FPassword;
end;

function TSciterURI.GetPath: SciterString;
var
  sStr: SciterString;
  i: Integer;
begin
  if FPathsChanged then
  begin
    sStr := EmptyStr;
    for i := 0 to Length(FPaths) - 2 do
    begin
      sStr := sStr + FPaths[i] + '/';
    end;
    sStr := sStr + FPaths[High(FPaths)];

    FPath := sStr;
    FPathsChanged := False;
  end;
  Result := FPath;
end;

function TSciterURI.GetPort: SciterString;
begin
  Result := FPort;
end;

function TSciterURI.GetProtocol: SciterString;
begin
  Result := FProtocol;
end;

function TSciterURI.GetUserName: SciterString;
begin
  Result := FUserName;
end;

procedure TSciterURI.SetBookMark(const Value: SciterString);
begin
  FBookmark := Value;
end;

procedure TSciterURI.SetDocument(const Value: SciterString);
begin
  FExt := ExtractFileExt(Value);
  FDocumentNoExt := Copy(Value, 1, Length(Value)- Length(FExt));
end;

procedure TSciterURI.SetHost(const Value: SciterString);
var
  LURI, LBuffer: SciterString;
  LPramsPos, LLen: Integer;
begin
  if Value = FHost then
    Exit;
  if Length(Value) > 0 then
  begin
    SetLength(FHosts, 0);
    LLen := 0;
    LURI := Value;
    repeat
      LPramsPos := Pos('.', LURI);
      if LPramsPos > 0 then
      begin
        LBuffer := Copy(LURI, 1, LPramsPos-1);
        Delete(LURI, 1, LPramsPos);
      end
      else
      begin
        LBuffer := LURI;
        LURI := '';
      end;
      if Length(LBuffer) > 0 then
      begin
        LLen := LLen + 1;
        SetLength(FHosts, LLen);
        FHosts[LLen-1] := LBuffer;
      end;
    until Length(LURI) <= 0;
  end;
  FHostsChanged := False;
  FHost := Value;
end;

procedure TSciterURI.SetParamStr(const Value: SciterString);
var
  LURI, LBuffer: SciterString;
  LPramsPos, LLen: Integer;
begin
  if Value = FParamStr then
    Exit;
  if Length(Value) > 0 then
  begin
    SetLength(FParams, 0);
    LLen := 0;
    LURI := Value;
    if LURI[1] = '?' then
      Delete(LURI, 1, 1);
    repeat
      LPramsPos := Pos('&', LURI);
      if LPramsPos > 0 then
      begin
        LBuffer := Copy(LURI, 1, LPramsPos-1);
        Delete(LURI, 1, LPramsPos);
      end
      else
      begin
        LBuffer := LURI;
        LURI := '';
      end;
      if Length(LBuffer) > 0 then
      begin
        LLen := LLen + 1;
        SetLength(FParams, LLen);
        LPramsPos := Pos('=', LBuffer);
        if LPramsPos > 0 then
        begin
          FParams[LLen-1].Name  := URLDecode(Copy(LBuffer, 1, LPramsPos-1));
          FParams[LLen-1].Value := URLDecode(Copy(LBuffer, LPramsPos+1, MaxInt));
        end
        else
        begin
          FParams[LLen-1].Name  := URLDecode(Copy(LBuffer, 1, MaxInt));
          FParams[LLen-1].Value := '';        
        end;
      end;
    until Length(LURI) <= 0;
  end;
  FParamChanged := False;
  FParamStr := Value;
end;

procedure TSciterURI.SetPassword(const Value: SciterString);
begin
  FPassword := Value;
end;

procedure TSciterURI.SetPath(const Value: SciterString);
var
  sValue: SciterString;
  LURI, LBuffer: SciterString;
  LPramsPos, LLen: Integer;
begin
  sValue := PathEncode(Value);
  NormalizePath(sValue);
  if sValue = FPath then
    Exit;
  if Length(sValue) > 0 then
  begin
    SetLength(FPaths, 0);
    LLen := 0;
    LURI := sValue;
    repeat
      LPramsPos := Pos('/', LURI);
      if LPramsPos > 0 then
      begin
        LBuffer := Copy(LURI, 1, LPramsPos-1);
        Delete(LURI, 1, LPramsPos);
      end
      else
      begin
        LBuffer := LURI;
        LURI := '';
      end;
      if Length(LBuffer) > 0 then
      begin
        LLen := LLen + 1;
        SetLength(FPaths, LLen);

        FPaths[LLen-1] := LBuffer;
      end;
    until Length(LURI) <= 0;
  end;
  FPathsChanged := False;
  FPath := sValue;
end;

procedure TSciterURI.SetPort(const Value: SciterString);
begin
  FPort := Value;
end;

procedure TSciterURI.SetProtocol(const Value: SciterString);
begin
  FProtocol := Value;
end;

procedure TSciterURI.SetUserName(const Value: SciterString);
begin
  FUserName := Value;
end;

destructor TSciterURI.Destroy;
begin
  FDestroying := True;
  DoDestroy;
  inherited;
end;

function TSciterURI.GetParamCount: Integer;
begin
  Result := Length(FParams);
end;

function TSciterURI.GetParamName(const AIndex: Integer): SciterString;
begin
  Result := FParams[AIndex].Name;
end;

function TSciterURI.GetParamValue(const AName: SciterString): SciterString;
var
  i: Integer;
begin
  i := IndexOfParam(AName);
  if i = -1 then
    Result := ''
  else
    Result := FParams[i].Value;
end;

function TSciterURI.GetParamValueFromIndex(
  const AIndex: Integer): SciterString;
begin
  Result := FParams[AIndex].Value;
end;

procedure TSciterURI.SetParamValue(const AName, Value: SciterString);
var
  i: Integer;
begin
  i := IndexOfParam(AName);
  if i >= 0 then
  begin
    FParams[i].Value := Value;
    FParamChanged := True;
  end
  else
    AddParam(AName, Value);
end;

procedure TSciterURI.SetParamValueFromIndex(const AIndex: Integer;
  const Value: SciterString);
begin
  FParams[AIndex].Value := Value;
  FParamChanged := True;
end;

function TSciterURI.IndexOfParam(const AName: SciterString): Integer;
begin
  for Result := 0 to High(FParams) do
  begin
    if WideSameText(AName, FParams[Result].Name) then
      Exit;
  end;
  Result := -1;
end;

function TSciterURI.HasParam(const AName: SciterString): Boolean;
begin
  Result := IndexOfParam(AName) <> -1;
end;

function TSciterURI.AddParam(const AName, AValue: SciterString): Integer;
var
  i: Integer;
begin
  i := Length(FParams);
  SetLength(FParams, i+1);

  FParams[i].Name := AName;
  FParams[i].Value := AValue;

  Result := i;
  FParamChanged := True;
end;

function TSciterURI.GetHostCount: Integer;
begin
  Result := Length(FHosts);
end;

function TSciterURI.GetHostValue(const AIndex: Integer): SciterString;
begin
  Result := FHosts[AIndex];
end;

function TSciterURI.GetPathCount: Integer;
begin
  Result := Length(FPaths);
end;

function TSciterURI.GetPathValue(const AIndex: Integer): SciterString;
begin
  Result := FPaths[AIndex];
end;

procedure TSciterURI.SetHostValue(const AIndex: Integer;
  const Value: SciterString);
begin
  FHosts[AIndex] := Value;
  FHostsChanged := True;
end;

procedure TSciterURI.SetPathValue(const AIndex: Integer;
  const Value: SciterString);
begin
  FPaths[AIndex] := Value;
  FPathsChanged := True;
end;

function TSciterURI.GetDocumentNoExt: SciterString;
begin
  Result := FDocumentNoExt;
end;

procedure TSciterURI.SetDocumentNoExt(const Value: SciterString);
begin
  FDocumentNoExt := Value;
end;

function TSciterURI.GetExt: SciterString;
begin
  Result := FExt;
end;

procedure TSciterURI.SetExt(const Value: SciterString);
begin
  FExt := Value;
end;

function TSciterURI.GetData1: Pointer;
begin
  Result := FData1;
end;

function TSciterURI.GetData2: Pointer;
begin
  Result := FData2;
end;

procedure TSciterURI.SetData1(const Value: Pointer);
begin
  FData1 := Value;
end;

procedure TSciterURI.SetData2(const Value: Pointer);
begin
  FData2 := Value;
end;

function TSciterURI.GetOnDestroy: ISciterURIDestroyProc;
begin
  Result := FOnDestroy;
end;

procedure TSciterURI.SetOnDestroy(const Value: ISciterURIDestroyProc);
begin
  FOnDestroy := Value;
end;

procedure TSciterURI.DoDestroy;
begin
  if @FOnDestroy <> nil then
  try
    FOnDestroy(Self);
  except
    on E: Exception do
      TraceException('[TSciterURI.DoDestroy]'+E.Message);
  end;             
end;

function TSciterURI.GetOnToFilePath: ISciterURIToFilePathProc;
begin
  Result := FOnToFilePath;
end;

procedure TSciterURI.SetOnToFilePath(
  const Value: ISciterURIToFilePathProc);
begin
  FOnToFilePath := Value;
end;

function TSciterURI.ToFilePath(var APath: SciterString): Boolean;
begin
  if @FOnToFilePath <> nil then
    Result := FOnToFilePath(Self, APath)
  else
  begin
    TraceException('[TSciterURI.ToFilePath]未设置OnToFilePath事件，不能使用ToFilePath方法！');
    Result := False;
  end;
end;

function TSciterURI.GetOnGetDefaultPort: ISciterURIGetDefaultPortProc;
begin
  Result := FOnGetDefaultPort;
end;

procedure TSciterURI.SetOnGetDefaultPort(
  const Value: ISciterURIGetDefaultPortProc);
begin
  FOnGetDefaultPort := Value;
end;

function TSciterURI._Release: Integer;
begin
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _Release;
end;

function TSciterURI._AddRef: Integer;
begin
  if FDestroying then
    Result := FRefCount
  else
    Result := inherited _AddRef;
end;

end.

