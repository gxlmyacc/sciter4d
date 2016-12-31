{*******************************************************************************
 标题:     SciterRequestIntf.pas
 描述:     Sciter的request请求接口封装的接口单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterRequestIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes, Windows;

type
  REQUEST_RESULT = (
    REQUEST_PANIC        = -1, // e.g. not enough memory
    REQUEST_OK           =  0,
    REQUEST_BAD_PARAM    =  1, // bad parameter
    REQUEST_FAILURE      =  2, // operation failed, e.g. index out of bounds
    REQUEST_NOTSUPPORTED =  3  // the platform does not support requested feature
  );

  REQUEST_RQ_TYPE = (
    RRT_GET         = 1,
    RRT_POST        = 2,
    RRT_PUT         = 3,
    RRT_DELETE      = 4
  );

  REQUEST_STATE = (
    RS_PENDING = 0,
    RS_SUCCESS = 1, // completed successfully
    RS_FAILURE = 2  // completed with failure
  );

  TSciterCompletionStatus = record
    State: REQUEST_STATE;
    CompletionStatus: UINT; //CompletionStatus - http response code : 200, 404, etc
  end;

  ISciterRequest = interface;

  TSciterRequestDataReceiver = procedure (const ARequest: ISciterRequest;
    bytes: LPCBYTE; num_bytes: UINT) of object;
  
  ISciterRequest = interface
  ['{65A69494-EE3A-491B-B82B-C5A2866CC295}']
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
    procedure SetReqHeader(const name, value: SciterString);
    procedure SetRspHeader(const name, value: SciterString);

    procedure Succeeded(status: UINT; dataOrNull: LPCBYTE = nil; dataLength: UINT = 0);
    procedure Failed(status: UINT; dataOrNull: LPCBYTE = nil; dataLength: UINT = 0);
    procedure AppendData(data: LPCBYTE; dataLength: UINT);

    function  RequestData(const rcv: TSciterRequestDataReceiver): REQUEST_RESULT;

    property Request: HREQUEST read GetRequest;
    property IsValid: Boolean read GetIsValid;
    property URL: SciterString read GetURL;
    property ContentURL: SciterString read GetContentURL;
    property RequestType: REQUEST_RQ_TYPE read GetRequestType;
    property RequestedDataType: SciterResourceType read GetRequestedDataType;
    property ReceivedDataType: SciterString read GetReceivedDataType;
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

function CreateRequest(h: HREQUEST): ISciterRequest;

implementation

uses
  SciterImportDefs;

function CreateRequest(h: HREQUEST): ISciterRequest;
type
  TCreateRequest = function (h: HREQUEST): ISciterRequest;
begin
  Result := TCreateRequest(SciterApi.Funcs[FuncIdx_CreateRequest])(h);
end;

end.
