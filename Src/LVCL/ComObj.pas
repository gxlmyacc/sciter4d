unit ComObj;

interface

uses
  SysUtils, ActiveX, Windows;

type
  EOleError = class(Exception);

  EOleSysError = class(EOleError)
  private
    FErrorCode: HRESULT;
  public
    constructor Create(const Message: string; ErrorCode: HRESULT;
      HelpContext: Integer);
    property ErrorCode: HRESULT read FErrorCode write FErrorCode;
  end;

  EOleException = class(EOleSysError)
  private
    FSource: string;
    FHelpFile: string;
  public
    constructor Create(const Message: string; ErrorCode: HRESULT;
      const Source, HelpFile: string; HelpContext: Integer);
    property HelpFile: string read FHelpFile write FHelpFile;
    property Source: string read FSource write FSource;
  end;

  EOleRegistrationError = class(EOleError);

procedure OleError(ErrorCode: HResult);
procedure OleCheck(Result: HResult);

function ProgIDToClassID(const ProgID: string): TGUID;
function ClassIDToProgID(const ClassID: TGUID): string;

function CreateComObject(const ClassID: TGUID): IUnknown;
function CreateRemoteComObject(const MachineName: WideString; const ClassID: TGUID): IUnknown;
function CreateOleObject(const ClassName: string): IDispatch;
function GetActiveOleObject(const ClassName: string): IDispatch;

procedure DispatchInvokeError(Status: Integer; const ExcepInfo: TExcepInfo);

function GetDispatchPropValue(Disp: IDispatch; DispID: Integer): OleVariant; overload;
function GetDispatchPropValue(Disp: IDispatch; Name: WideString): OleVariant; overload;
procedure SetDispatchPropValue(Disp: IDispatch; DispID: Integer; const Value: OleVariant); overload;
procedure SetDispatchPropValue(Disp: IDispatch; Name: WideString; const Value: OleVariant); overload;

{$IF CompilerVersion <= 18.5}
function CharInSet(const C: WideChar; const CharSet: TSysCharSet): Boolean; overload;
function CharInSet(const C: AnsiChar; const CharSet: TSysCharSet): Boolean; overload;
{$IFEND}

implementation

resourcestring
  SOleError = 'OLE error %.8x';
  SDCOMNotInstalled = 'DCOM not installed';

{$IF CompilerVersion <= 18.5}
function CharInSet(const C: WideChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := AnsiChar(C) in CharSet;
end;
function CharInSet(const C: AnsiChar; const CharSet: TSysCharSet): Boolean;
begin
 Result := C in CharSet;
end;
{$IFEND}


procedure OleError(ErrorCode: HResult);
begin
  raise EOleSysError.Create('', ErrorCode, 0);
end;

procedure OleCheck(Result: HResult);
begin
  if not Succeeded(Result) then OleError(Result);
end;

function ProgIDToClassID(const ProgID: string): TGUID;
begin
  OleCheck(CLSIDFromProgID(PWideChar(WideString(ProgID)), Result));
end;

function ClassIDToProgID(const ClassID: TGUID): string;
var
  P: PWideChar;
begin
  OleCheck(ProgIDFromCLSID(ClassID, P));
  Result := P;
  CoTaskMemFree(P);
end;

function CreateComObject(const ClassID: TGUID): IUnknown;
begin
  OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or
    CLSCTX_LOCAL_SERVER, IUnknown, Result));
end;

function CreateRemoteComObject(const MachineName: WideString;
  const ClassID: TGUID): IUnknown;
const
  LocalFlags = CLSCTX_LOCAL_SERVER or CLSCTX_REMOTE_SERVER or CLSCTX_INPROC_SERVER;
  RemoteFlags = CLSCTX_REMOTE_SERVER;
var
  MQI: TMultiQI;
  ServerInfo: TCoServerInfo;
  IID_IUnknown: TGuid;
  Flags, Size: DWORD;
  LocalMachine: array [0..MAX_COMPUTERNAME_LENGTH] of char;
begin
  if @CoCreateInstanceEx = nil then
    raise Exception.CreateRes(@SDCOMNotInstalled);
  FillChar(ServerInfo, sizeof(ServerInfo), 0);
  ServerInfo.pwszName := PWideChar(MachineName);
  IID_IUnknown := IUnknown;
  MQI.IID := @IID_IUnknown;
  MQI.itf := nil;
  MQI.hr := 0;
  { If a MachineName is specified check to see if it the local machine.
    If it isn't, do not allow LocalServers to be used. }
  if Length(MachineName) > 0 then
  begin
    Size := Sizeof(LocalMachine);  // Win95 is hypersensitive to size
    if GetComputerName(LocalMachine, Size) and
       (AnsiCompareText(LocalMachine, MachineName) = 0) then
      Flags := LocalFlags else
      Flags := RemoteFlags;
  end else
    Flags := LocalFlags;
  OleCheck(CoCreateInstanceEx(ClassID, nil, Flags, @ServerInfo, 1, @MQI));
  OleCheck(MQI.HR);
  Result := MQI.itf;
end;

function CreateOleObject(const ClassName: string): IDispatch;
var
  ClassID: TCLSID;
begin
  ClassID := ProgIDToClassID(ClassName);
  OleCheck(CoCreateInstance(ClassID, nil, CLSCTX_INPROC_SERVER or
    CLSCTX_LOCAL_SERVER, IDispatch, Result));
end;

function GetActiveOleObject(const ClassName: string): IDispatch;
var
  ClassID: TCLSID;
  Unknown: IUnknown;
begin
  ClassID := ProgIDToClassID(ClassName);
  OleCheck(GetActiveObject(ClassID, nil, Unknown));
  OleCheck(Unknown.QueryInterface(IDispatch, Result));
end;

procedure DispCallError(Status: Integer; var ExcepInfo: TExcepInfo;
  ErrorAddr: Pointer; FinalizeExcepInfo: Boolean);
var
  E: Exception;
begin
  if Status = Integer(DISP_E_EXCEPTION) then
  begin
    with ExcepInfo do
      E := EOleException.Create(bstrDescription, scode, bstrSource,
        bstrHelpFile, dwHelpContext);
    if FinalizeExcepInfo then
      Finalize(ExcepInfo);
  end else
    E := EOleSysError.Create('', Status, 0);
  if ErrorAddr <> nil then
    raise E at ErrorAddr
  else
    raise E;
end;


procedure DispatchInvokeError(Status: Integer; const ExcepInfo: TExcepInfo);
begin
  DispCallError(Status, PExcepInfo(@ExcepInfo)^, nil, False);
end;

const
  DispIDArgs: Longint = DISPID_PROPERTYPUT;

function GetDispatchPropValue(Disp: IDispatch; DispID: Integer): OleVariant;
var
  ExcepInfo: TExcepInfo;
  DispParams: TDispParams;
  Status: HResult;
begin
  FillChar(DispParams, SizeOf(DispParams), 0);
  Status := Disp.Invoke(DispID, GUID_NULL, 0, DISPATCH_PROPERTYGET, DispParams,
    @Result, @ExcepInfo, nil);
  if Status <> S_OK then DispatchInvokeError(Status, ExcepInfo);
end;

function GetDispatchPropValue(Disp: IDispatch; Name: WideString): OleVariant;
var
  ID: Integer;
begin
  OleCheck(Disp.GetIDsOfNames(GUID_NULL, @Name, 1, 0, @ID));
  Result := GetDispatchPropValue(Disp, ID);
end;

procedure SetDispatchPropValue(Disp: IDispatch; DispID: Integer;
  const Value: OleVariant);
var
  ExcepInfo: TExcepInfo;
  DispParams: TDispParams;
  Status: HResult;
begin
  with DispParams do
  begin
    rgvarg := @Value;
    rgdispidNamedArgs := @DispIDArgs;
    cArgs := 1;
    cNamedArgs := 1;
  end;
  Status := Disp.Invoke(DispId, GUID_NULL, 0, DISPATCH_PROPERTYPUT, DispParams,
    nil, @ExcepInfo, nil);
  if Status <> S_OK then DispatchInvokeError(Status, ExcepInfo);
end;

procedure SetDispatchPropValue(Disp: IDispatch; Name: WideString;
  const Value: OleVariant); overload;
var
  ID: Integer;
begin
  OleCheck(Disp.GetIDsOfNames(GUID_NULL, @Name, 1, 0, @ID));
  SetDispatchPropValue(Disp, ID, Value);
end;

function TrimPunctuation(const S: string): string;
var
  P: PChar;
begin
  Result := S;
  P := AnsiLastChar(Result);
  while (Length(Result) > 0) and CharInSet(P^, [#0..#32, '.']) do
  begin
    SetLength(Result, P - PChar(Result));
    P := AnsiLastChar(Result);
  end;
end;

{ EOleSysError }

constructor EOleSysError.Create(const Message: string;
  ErrorCode: HRESULT; HelpContext: Integer);
var
  S: string;
begin
  S := Message;
  if S = '' then
  begin
    S := SysErrorMessage(ErrorCode);
    if S = '' then FmtStr(S, SOleError, [ErrorCode]);
  end;
  inherited CreateHelp(S, HelpContext);
  FErrorCode := ErrorCode;
end;

{ EOleException }

constructor EOleException.Create(const Message: string; ErrorCode: HRESULT;
  const Source, HelpFile: string; HelpContext: Integer);
begin
  inherited Create(TrimPunctuation(Message), ErrorCode, HelpContext);
  FSource := Source;
  FHelpFile := HelpFile;
end;

end.