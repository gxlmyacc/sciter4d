{*******************************************************************************
 标题:     SciterFactoryIntf.pas
 描述:     sciter的工厂接口单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterFactoryIntf;

interface

{$I Sciter.inc}

uses
  Windows, SciterTypes, SciterIntf;

type
  PISciterValueFactory = ^ISciterValueFactory;
  ISciterValueFactory = interface
  ['{9E73A2FC-2C72-4F86-B58B-535E3B0F28B0}']
    function Create: IDomValue; overload;
    function Create(const src: SCITER_VALUE): IDomValue; overload;
    function Create(const src: PSCITER_VALUE): IDomValue; overload;
    function Create(const src: IDomValue): IDomValue; overload;
    function Create(vm: HVM; const src: tiscript_value): IDomValue; overload;
    function Create(const v: Boolean): IDomValue; overload;
    function Create(const v: Integer): IDomValue; overload;
    function Create(const v: Double): IDomValue; overload;
    function Create(const v: SciterString): IDomValue; overload;
    function Create(const s: PWideChar; slen: UINT): IDomValue; overload;
    function Create(const b: LPCBYTE; blen: UINT): IDomValue; overload;
    function Create(arr: array of IDomValue): IDomValue; overload;
    function Create(arr: array of SCITER_VALUE): IDomValue; overload;

    function Currency(const v: Currency): IDomValue;
    function Date(const v: FILETIME): IDomValue;
    function DateTime(const v: TDateTime; isUTC: Boolean = True): IDomValue;
    function SecureString(const s: PWideChar; slen: size_t): IDomValue;
    function Null: IDomValue;
    function MakeError(const s: SciterString): IDomValue;
    function MakeSymbol(const s: SciterString): IDomValue;

    function FromString(const s: SciterString; ct: TDomValueStringCvtType = CVT_SIMPLE): IDomValue; overload;
    function FromString(str: LPCWSTR; strLength: UINT; ct: TDomValueStringCvtType = CVT_SIMPLE): IDomValue; overload;

    function CreateList: IDomValueList;
  end;

  PISciterNodeFactory = ^ISciterNodeFactory;
  ISciterNodeFactory = interface
  ['{4A92419B-E79E-488E-B74D-2546FFC1C865}']
    function Create: IDomNode; overload;
    function CreateFromNode(h: HNODE): IDomNode; overload;
    function CreateFromElement(h: HELEMENT): IDomNode; overload;
    function Create(const el: IDomElement): IDomNode; overload;
    function Create(const n: IDomNode): IDomNode; overload;

    function CreateList: IDomNodeList;
  end;

  PISciterElementFactory = ^ISciterElementFactory;
  ISciterElementFactory = interface
  ['{E9827E50-7E36-4054-9A0D-5E1EAC629521}']
    (** create brand new element with text (optional).
      Example:
          element div = element::create("div");
      - will create DIV element,
          element opt = element::create("option",L"Europe");
      - will create OPTION element with text "Europe" in it.
    **)
    function Create(const TagName: SciterString; const Text: SciterString = ''): IDomElement; overload;
    function Create: IDomElement; overload;
    function Create(h: HELEMENT): IDomElement; overload;
    function Create(const e: IDomElement): IDomElement; overload;
    function Create(const e: IDomNode): IDomElement; overload;

    function CreateEditBox: IDomEditBox; overload;
    function CreateEditBox(h: HELEMENT): IDomEditBox; overload;
    function CreateEditBox(const e: IDomElement): IDomEditBox; overload;
    function CreateEditBox(const e: IDomNode): IDomEditBox; overload;

    function CreateScrollbar: IDomScrollbar; overload;
    function CreateScrollbar(h: HELEMENT): IDomScrollbar; overload;
    function CreateScrollbar(const e: IDomElement): IDomScrollbar; overload;
    function CreateScrollbar(const e: IDomNode): IDomScrollbar; overload;

    function CreateList: IDomElementList;
  end;

  PISciterLayoutFactory = ^ISciterLayoutFactory;
  ISciterLayoutFactory = interface
  ['{EBC68798-A5DA-49FB-8426-A759923B7243}']
    function Create(const AThis: ISciterBase): ISciterLayout; overload;
  end;

function ElementFactory: PISciterElementFactory;
function NodeFactory: PISciterNodeFactory;
function ValueFactory: PISciterValueFactory;
function LayoutFactory: PISciterLayoutFactory;

implementation

uses
  SciterImportDefs;

function ElementFactory: PISciterElementFactory;
type
  TElementFactory = function : PISciterElementFactory;
begin
  Result := TElementFactory(SciterApi.Funcs[FuncIdx_ElementFactory]);
end;

function NodeFactory: PISciterNodeFactory;
type
  TNodeFactory = function : PISciterNodeFactory;
begin
  Result := TNodeFactory(SciterApi.Funcs[FuncIdx_NodeFactory]);
end;

function ValueFactory: PISciterValueFactory;
type
  TValueFactory = function : PISciterValueFactory;
begin
  Result := TValueFactory(SciterApi.Funcs[FuncIdx_ValueFactory]);
end;

function LayoutFactory: PISciterLayoutFactory;
type
  TLayoutFactory = function : PISciterLayoutFactory;
begin
  Result := TLayoutFactory(SciterApi.Funcs[FuncIdx_LayoutFactory]);
end;


end.
