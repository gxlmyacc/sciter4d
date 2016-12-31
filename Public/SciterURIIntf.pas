{*******************************************************************************
 标题:     SciterURIIntf.pas
 描述:     URL工具类的接口单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterURIIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes;

type
  ISciterURI = interface;
  
  TSciterURIOptionalFields = (ofAuthInfo, ofBookmark, ofParams);
  TSciterURIOptionalFieldsSet = set of TSciterURIOptionalFields;
  ISciterURIGetDefaultPortProc = function (): SciterString of object;
  ISciterURIToFilePathProc = function (const AURL: ISciterURI; var APath: SciterString): Boolean of object;
  ISciterURIDestroyProc = procedure (const AURL: ISciterURI) of object;
                                       
  ISciterURI = interface
  ['{7DB67E8C-1EBC-4DCA-91B9-781234C57761}']
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

function SciterCreateURI(const AURI: SciterString = ''): ISciterURI;

implementation

uses
  SciterImportDefs;

function SciterCreateURI(const AURI: SciterString): ISciterURI;
type
  TSciterCreateURI = function (const AURI: SciterString): ISciterURI;
begin
  Result := TSciterCreateURI(SciterApi.Funcs[FuncIdx_SciterCreateURI])(AURI);
end;

end.
