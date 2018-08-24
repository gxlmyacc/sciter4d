{*******************************************************************************
 标题:     SciterRequestApiImpl.pas
 描述:     Sciter的request请求api接口定义
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterRequestApiImpl;

interface

uses
  SciterTypes, SciterRequestIntf, Windows;

type
  SciterRequestAPI = record
    // a.k.a AddRef()
    RequestUse: function (rq: HREQUEST): REQUEST_RESULT; stdcall;
    // a.k.a Release()
    RequestUnUse: function (rq: HREQUEST): REQUEST_RESULT; stdcall;
    // get requested URL
    RequestUrl: function (rq: HREQUEST; rcv: LPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get real, content URL (after possible redirection)
    RequestContentUrl: function (rq: HREQUEST; rcv: LPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get requested data type
    RequestGetRequestType: function (rq: HREQUEST; var pType: REQUEST_RQ_TYPE): REQUEST_RESULT; stdcall;
    // get requested data type
    RequestGetRequestedDataType: function (rq: HREQUEST; var pData: SciterResourceType): REQUEST_RESULT; stdcall;
    // get received data type, string, mime type
    RequestGetReceivedDataType: function (rq: HREQUEST; rcv: LPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get number of request parameters passed
    RequestGetNumberOfParameters: function (rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth request parameter name
    RequestGetNthParameterName: function (rq: HREQUEST; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth request parameter value
    RequestGetNthParameterValue: function (rq: HREQUEST; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get request times , ended - started = milliseconds to get the requst
    RequestGetTimes: function (rq: HREQUEST; var pStarted, pEnded: UINT): REQUEST_RESULT; stdcall;
    // get number of request headers
    RequestGetNumberOfRqHeaders: function (rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth request header name
    RequestGetNthRqHeaderName: function (rq: HREQUEST; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth request header value
    RequestGetNthRqHeaderValue: function (rq: HREQUEST; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get number of response headers
    RequestGetNumberOfRspHeaders: function (rq: HREQUEST; var pNumber: UINT): REQUEST_RESULT; stdcall;
    // get nth response header name
    RequestGetNthRspHeaderName: function (rq: HREQUEST; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get nth response header value
    RequestGetNthRspHeaderValue: function (rq: HREQUEST; n: UINT; rcv: LPCWSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get completion status (CompletionStatus - http response code : 200, 404, etc.)
    RequestGetCompletionStatus: function (rq: HREQUEST; var pState: REQUEST_STATE; var pCompletionStatus: UINT): REQUEST_RESULT; stdcall;
    // get proxy host
    RequestGetProxyHost: function (rq: HREQUEST; rcv: LPCSTR_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
    // get proxy port
    RequestGetProxyPort: function (rq: HREQUEST; var pPort: UINT): REQUEST_RESULT; stdcall;
    // mark reequest as complete with status and data
    RequestSetSucceeded: function (rq: HREQUEST; status: UINT; dataOrNull: LPCBYTE; dataLength: UINT): REQUEST_RESULT; stdcall;
    // mark reequest as complete with failure and optional data
    RequestSetFailed: function (rq: HREQUEST; status: UINT; dataOrNull: LPCBYTE; dataLength: UINT): REQUEST_RESULT; stdcall;
    // append received data chunk
    RequestAppendDataChunk: function (rq: HREQUEST; data: LPCBYTE; dataLength: UINT): REQUEST_RESULT; stdcall;
    // set request header (single item)
    RequestSetRqHeader: function (rq: HREQUEST; name, value: LPCWSTR): REQUEST_RESULT; stdcall;
    // set respone header (single item)
    RequestSetRspHeader: function (rq: HREQUEST; name, value: LPCWSTR): REQUEST_RESULT; stdcall;
    // set received data type, string, mime type
    RequestSetReceivedDataType: function (rq: HREQUEST; type_: LPCSTR): REQUEST_RESULT; stdcall;
    // set received data encoding, string
    RequestSetReceivedDataEncoding: function (rq: HREQUEST; type_: LPCSTR): REQUEST_RESULT; stdcall;
    // get received (so far) data
    RequestGetData: function (rq: HREQUEST; rcv: LPCBYTE_RECEIVER; rcv_param: LPVOID): REQUEST_RESULT; stdcall;
  end;
  LPSciterRequestAPI = ^SciterRequestAPI;

function RAPI: LPSciterRequestAPI;

implementation

uses
  SciterApiImpl;

var
  varRAPI: LPSciterRequestAPI = nil;

function RAPI: LPSciterRequestAPI;
begin
  if varRAPI = nil then
    varRAPI := SAPI.GetSciterRequestAPI;
  Result := varRAPI;
end;

end.
