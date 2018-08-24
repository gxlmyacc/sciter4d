{*******************************************************************************
 标题:     SciterRequestImpl.pas
 描述:     Sciter的request请求接口封装的实现单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterRequestImpl;

interface

uses
  SciterTypes, SciterRequestIntf, SciterRequestApiImpl, Windows;

type
  TSciterRequest = class(TInterfacedObject, ISciterRequest)
  private
    FRequest: HREQUEST;
  protected
    function GetRequest: HREQUEST;
    function GetIsValid: Boolean;
    function GetURL: SciterString;
    function GetContentURL: SciterString;
    function GetRequestType: REQUEST_RQ_TYPE;
    function GetRequestedDataType: SciterResourceType;
    function GetReceivedDataType: SciterString;
    function GetNumberOfParameters: UINT;
    function GetParameterName(n: UINT): SciterString;
    function GetParameterValue(n: UINT): SciterString;
    function GetParameter(const name: SciterString): SciterString;
    function GetRequestTimes: UINT;
    function GetNumberOfReqHeaders: UINT;
    function GetReqHeaderName(n: UINT): SciterString;
    function GetReqHeaderValue(n: UINT): SciterString;
    function GetReqHeader(const name: SciterString): SciterString;
    function GetNumberOfRspHeaders: UINT;
    function GetRspHeaderName(n: UINT): SciterString;
    function GetRspHeaderValue(n: UINT): SciterString;
    function GetRspHeader(const name: SciterString): SciterString;
    function GetCompletionStatus: TSciterCompletionStatus;
    function GetProxyHost: SciterString;
    function GetProxyPort: UINT;
    procedure SetReceivedDataType(const Value: SciterString);
    procedure SetReqHeader(const name, value: SciterString);
    procedure SetRspHeader(const name, value: SciterString);
    
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create(const rq: HREQUEST);
    destructor Destroy; override;

    procedure Succeeded(status: UINT; dataOrNull: LPCBYTE = nil; dataLength: UINT = 0);
    procedure Failed(status: UINT; dataOrNull: LPCBYTE = nil; dataLength: UINT = 0);
    procedure AppendData(data: LPCBYTE; dataLength: UINT);

    function  SetReceivedDataEncoding(const type_: SciterString): REQUEST_RESULT;
    function  RequestData(const rcv: TSciterRequestDataReceiver): REQUEST_RESULT;

    property Request: HREQUEST read GetRequest;
    property IsValid: Boolean read GetIsValid;
    property URL: SciterString read GetURL;
    property ContentURL: SciterString read GetContentURL;
    property RequestType: REQUEST_RQ_TYPE read GetRequestType;
    property RequestedDataType: SciterResourceType read GetRequestedDataType;
    property ReceivedDataType: SciterString read GetReceivedDataType write SetReceivedDataType;
    property NumberOfParameters: UINT read GetNumberOfParameters;
    property ParameterName[n: UINT]: SciterString read GetParameterName;
    property ParameterValue[n: UINT]: SciterString read GetParameterValue;
    property Parameter[const name: SciterString]: SciterString read GetParameter;
    property RequestTimes: UINT read GetRequestTimes;
    property NumberOfReqHeaders: UINT read GetNumberOfReqHeaders;
    property ReqHeaderName[n: UINT]: SciterString read GetReqHeaderName;
    property ReqHeaderValue[n: UINT]: SciterString read GetReqHeaderValue;
    property ReqHeader[const name: SciterString]: SciterString read GetReqHeader write SetReqHeader;
    property NumberOfRspHeaders: UINT read GetNumberOfRspHeaders;
    property RspHeaderName[n: UINT]: SciterString read GetRspHeaderName;
    property RspHeaderValue[n: UINT]: SciterString read GetRspHeaderValue;
    property RspHeader[const name: SciterString]: SciterString read GetRspHeader write SetRspHeader;
    property CompletionStatus: TSciterCompletionStatus read GetCompletionStatus;
    property ProxyHost: SciterString read GetProxyHost;
    property ProxyPort: UINT read GetProxyPort;
  end;

implementation

uses
  SciterApiImpl;

{ TSciterRequest }

procedure TSciterRequest.AppendData(data: LPCBYTE; dataLength: UINT);
begin
  Assert(RAPI.RequestAppendDataChunk(FRequest, data, dataLength) = REQUEST_OK);
end;

constructor TSciterRequest.Create(const rq: HREQUEST);
begin
  FRequest := rq;
end;

destructor TSciterRequest.Destroy;
begin
  inherited;
end;

procedure TSciterRequest.Failed(status: UINT; dataOrNull: LPCBYTE;
  dataLength: UINT);
begin
  Assert(RAPI.RequestSetFailed(FRequest, status, dataOrNull, dataLength) = REQUEST_OK);
end;

function TSciterRequest.GetCompletionStatus: TSciterCompletionStatus;
begin
  Assert(RAPI.RequestGetCompletionStatus(FRequest, Result.State, Result.CompletionStatus) = REQUEST_OK);
end;

function TSciterRequest.GetContentURL: SciterString;
begin
  Assert(RAPI.RequestContentUrl(FRequest, _LPCSTR2String, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetIsValid: Boolean;
begin
  Result := FRequest <> nil;
end;

function TSciterRequest.GetNumberOfParameters: UINT;
begin 
  Assert(RAPI.RequestGetNumberOfParameters(FRequest, Result) = REQUEST_OK);
end;

function TSciterRequest.GetNumberOfReqHeaders: UINT;
begin       
  Assert(RAPI.RequestGetNumberOfRqHeaders(FRequest, Result) = REQUEST_OK);
end;

function TSciterRequest.GetNumberOfRspHeaders: UINT;
begin         
  Assert(RAPI.RequestGetNumberOfRspHeaders(FRequest, Result) = REQUEST_OK);
end;

function TSciterRequest.GetParameter(const name: SciterString): SciterString;
var
  i: Integer;
begin
  for i := 0 to GetNumberOfParameters - 1 do
  begin
    if GetParameterName(i) = name then
    begin
      Result := GetParameterValue(i);
      Exit;
    end;
  end;
  Result := '';
end;

function TSciterRequest.GetParameterName(n: UINT): SciterString;
begin         
  Assert(RAPI.RequestGetNthParameterName(FRequest, n, _LPCWSTR2STRING, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetParameterValue(n: UINT): SciterString;
begin
  Assert(RAPI.RequestGetNthParameterValue(FRequest, n, _LPCWSTR2STRING, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetProxyHost: SciterString;
begin
  Assert(RAPI.RequestGetProxyHost(FRequest, _LPCSTR2String, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetProxyPort: UINT;
begin
  Assert(RAPI.RequestGetProxyPort(FRequest, Result) = REQUEST_OK);
end;

function TSciterRequest.GetReceivedDataType: SciterString;
begin
  Assert(RAPI.RequestGetReceivedDataType(FRequest, _LPCSTR2String, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetReqHeader(const name: SciterString): SciterString;
var
  i: Integer;
begin
  for i := 0 to GetNumberOfReqHeaders - 1 do
  begin
    if GetReqHeaderName(i) = name then
    begin
      Result := GetReqHeaderValue(i);
      Exit;
    end;
  end;
  Result := '';
end;

function TSciterRequest.GetReqHeaderName(n: UINT): SciterString;
begin        
  Assert(RAPI.RequestGetNthRqHeaderName(FRequest, n, _LPCWSTR2STRING, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetReqHeaderValue(n: UINT): SciterString;
begin
  Assert(RAPI.RequestGetNthRqHeaderValue(FRequest, n, _LPCWSTR2STRING, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetRequest: HREQUEST;
begin
  Result := FRequest;
end;

function TSciterRequest.GetRequestedDataType: SciterResourceType;
begin      
  Assert(RAPI.RequestGetRequestedDataType(FRequest, Result) = REQUEST_OK);
end;

function TSciterRequest.GetRequestTimes: UINT;
var
  iStarted, iEnded: UINT;
begin
  Assert(RAPI.RequestGetTimes(FRequest, iStarted, iEnded) = REQUEST_OK);
  Result := iEnded - iStarted;
end;

function TSciterRequest.GetRequestType: REQUEST_RQ_TYPE;
begin
  Assert(RAPI.RequestGetRequestType(FRequest, Result) = REQUEST_OK);
end;

function TSciterRequest.GetRspHeader(const name: SciterString): SciterString;
var
  i: Integer;
begin
  for i := 0 to GetNumberOfRspHeaders - 1 do
  begin
    if GetRspHeaderName(i) = name then
    begin
      Result := GetRspHeaderValue(i);
      Exit;
    end;
  end;
  Result := '';
end;

function TSciterRequest.GetRspHeaderName(n: UINT): SciterString;
begin
  Assert(RAPI.RequestGetNthRspHeaderName(FRequest, n, _LPCWSTR2STRING, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetRspHeaderValue(n: UINT): SciterString;
begin
  Assert(RAPI.RequestGetNthRspHeaderValue(FRequest, n, _LPCWSTR2STRING, @Result) = REQUEST_OK);
end;

function TSciterRequest.GetURL: SciterString;
begin
  Assert(RAPI.RequestUrl(FRequest, _LPCSTR2String, @Result) = REQUEST_OK);
end;

function TSciterRequest.RequestData(
  const rcv: TSciterRequestDataReceiver): REQUEST_RESULT;
var
  sResult: TBytes;
begin
  Result := RAPI.RequestGetData(FRequest, _LPCBYTE2ASTRING, @sResult);
  if Result = REQUEST_OK then
  begin
    if Length(sResult) = 0 then
      rcv(Self, nil, 0)
    else
      rcv(Self, @sResult[0], Length(sResult))
  end;
end;

function TSciterRequest.SetReceivedDataEncoding(const type_: SciterString): REQUEST_RESULT;
begin
  Result := RAPI.RequestSetReceivedDataEncoding(FRequest, PAnsiChar(UTF8Encode(type_)))
end;

procedure TSciterRequest.SetReceivedDataType(const Value: SciterString);
begin
  Assert(RAPI.RequestSetReceivedDataType(FRequest, PAnsiChar(UTF8Encode(Value))) = REQUEST_OK);
end;

procedure TSciterRequest.SetReqHeader(const name, value: SciterString);
begin
  Assert(RAPI.RequestSetRqHeader(FRequest, PWideChar(name), PWideChar(value)) = REQUEST_OK);
end;

procedure TSciterRequest.SetRspHeader(const name, value: SciterString);
begin
  Assert(RAPI.RequestSetRspHeader(FRequest, PWideChar(name), PWideChar(value)) = REQUEST_OK);
end;

procedure TSciterRequest.Succeeded(status: UINT; dataOrNull: LPCBYTE;
  dataLength: UINT);
begin          
  Assert(RAPI.RequestSetSucceeded(FRequest, status, dataOrNull, dataLength) = REQUEST_OK);
end;

function TSciterRequest._AddRef: Integer;
begin
  Result := inherited _AddRef;
  if FRequest <> nil then
    RAPI.RequestUse(FRequest);
end;

function TSciterRequest._Release: Integer;
begin
  if FRequest <> nil then
    RAPI.RequestUnUse(FRequest);
  Result := inherited _Release;
end;

end.
