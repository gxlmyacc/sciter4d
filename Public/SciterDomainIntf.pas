{*******************************************************************************
 标题:     SciterDomainImpl.pas
 描述:     Sciter域对象的定义接口单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterDomainIntf;

interface

{$I Sciter.inc}

uses
  SciterTypes, SciterURIIntf;

type
  ISciterDomain = interface;
  
  PSciterDomainValueRec = ^TSciterDomainValueRec;
  TSciterDomainValueRec = record
    Value: SciterString;
    Domain: ISciterDomain;
  end;

  PISciterDomain = ^ISciterDomain;
  ISciterDomain = interface
  ['{EF780B52-2C50-4426-A1DF-580A38A8384C}']
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

    function  Implementator: Pointer;

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

function SciterTopDomain: PISciterDomain;

implementation

uses
  SciterImportDefs;

function SciterTopDomain: PISciterDomain;
type
  TSciterTopDomain = function : PISciterDomain;
begin
  Result := TSciterTopDomain(SciterApi.Funcs[FuncIdx_SciterTopDomain]);
end;

end.
