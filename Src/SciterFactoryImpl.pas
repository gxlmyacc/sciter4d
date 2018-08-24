{*******************************************************************************
 标题:     SciterFactoryImpl.pas
 描述:     Sciter对象创建工厂实现单元
 创建时间：2015-02-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterFactoryImpl;

interface

{$I Sciter.inc}

uses
  Windows, SciterTypes, SciterValue, SciterIntf, SciterFactoryIntf, 
  SciterDom, SciterLayout;

type
  TSciterValueFactory = class(TInterfacedObject, ISciterValueFactory)
  public
    constructor _Create;
    destructor Destroy; override;

    function Create: IDomValue; overload;
    function Create(const src: SCITER_VALUE): IDomValue; overload;
    function Create(const src: PSCITER_VALUE): IDomValue; overload;
    function Create(const src: IDomValue): IDomValue; overload;
    function Create(vm: HVM; const src: tiscript_value): IDomValue; overload;
    function Create(const v: BOOL): IDomValue; overload;
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

  TSciterNodeFactory = class(TInterfacedObject, ISciterNodeFactory)
  public
    constructor _Create;
    
    function Create: IDomNode; overload;
    function Create(const el: IDomElement): IDomNode; overload;
    function Create(const n: IDomNode): IDomNode; overload;
    function CreateFromNode(h: HNODE): IDomNode;
    function CreateFromElement(h: HELEMENT): IDomNode;

    function CreateList: IDomNodeList;
  end;

  TSciterElementFactory = class(TInterfacedObject, ISciterElementFactory)
  public
    constructor _Create;

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

    function CreateList: IDomElementList;
  end;

  TSciterLayoutFactory = class(TInterfacedObject, ISciterLayoutFactory)
  public
    constructor _Create;
    
    function Create(const AThis: ISciterBase): ISciterLayout; 
  end;

implementation

uses
  SciterImpl;


{ TSciterValueFactory }

function TSciterValueFactory.Create(const v: BOOL): IDomValue;
begin
  Result := TDomValue.Create(v)
end;

function TSciterValueFactory.Create(const v: Boolean): IDomValue;
begin
  Result := TDomValue.Create(v)
end;

function TSciterValueFactory.Create(const v: Integer): IDomValue;
begin
  Result := TDomValue.Create(v)
end;

function TSciterValueFactory.Create(const v: Double): IDomValue;
begin
  Result := TDomValue.Create(v)
end;

function TSciterValueFactory.Create: IDomValue;
begin
  Result := TDomValue.Create();
end;

function TSciterValueFactory.Create(const src: PSCITER_VALUE): IDomValue;
begin
  Result := TDomValue.Create(src);
end;

function TSciterValueFactory.Create(const src: IDomValue): IDomValue;
begin
  Result := TDomValue.Create(src);
end;

function TSciterValueFactory.Create(arr: array of IDomValue): IDomValue;
begin
  Result := TDomValue.Create(arr);
end;

function TSciterValueFactory.Create(arr: array of SCITER_VALUE): IDomValue;
begin
  Result := TDomValue.Create(arr);
end;

function TSciterValueFactory.Create(const b: LPCBYTE;
  blen: UINT): IDomValue;
begin
  Result := TDomValue.Create(b, blen);
end;

function TSciterValueFactory.Create(const v: SciterString): IDomValue;
begin
  Result := TDomValue.Create(v);
end;

function TSciterValueFactory.Create(const s: PWideChar;
  slen: UINT): IDomValue;
begin
  Result := TDomValue.Create(s, slen);
end;

function TSciterValueFactory.Create(vm: HVM; const src: tiscript_value): IDomValue;
begin
  Result := TDomValue.Create(vm, src)
end;

function TSciterValueFactory.Create(const src: SCITER_VALUE): IDomValue;
begin
  Result := TDomValue.Create(src);
end;

function TSciterValueFactory.CreateList: IDomValueList;
begin
  Result := TDomValueList.Create;
end;

function TSciterValueFactory.Currency(const v: Currency): IDomValue;
begin
  Result := TDomValue.Currency(v);
end;

function TSciterValueFactory.Date(const v: FILETIME): IDomValue;
begin
  Result := TDomValue.Date(v);
end;

function TSciterValueFactory.DateTime(const v: TDateTime; isUTC: Boolean = True): IDomValue;
begin
  Result := TDomValue.DateTime(v, isUTC);
end;

destructor TSciterValueFactory.Destroy;
begin
  inherited;
end;

function TSciterValueFactory.FromString(const s: SciterString;
  ct: TDomValueStringCvtType): IDomValue;
begin
  Result := TDomValue.FromString(s, ct);
end;

function TSciterValueFactory.FromString(str: LPCWSTR; strLength: UINT;
  ct: TDomValueStringCvtType): IDomValue;
begin
  Result := TDomValue.FromString(str, strLength, ct);
end;

function TSciterValueFactory.MakeError(const s: SciterString): IDomValue;
begin
  Result := TDomValue.MakeError(s);
end;

function TSciterValueFactory.MakeSymbol(const s: SciterString): IDomValue;
begin
  Result := TDomValue.MakeSymbol(s);
end;

function TSciterValueFactory.Null: IDomValue;
begin
  Result := TDomValue.Null;
end;

function TSciterValueFactory.SecureString(const s: PWideChar;
  slen: size_t): IDomValue;
begin
  Result := TDomValue.SecureString(s, slen);
end;

constructor TSciterValueFactory._Create;
begin
  inherited;
end;

{ TSciterNodeFactory }

constructor TSciterNodeFactory._Create;
begin
  inherited;
end;

function TSciterNodeFactory.Create: IDomNode;
begin
  Result := TDomNode.Create();
end;

function TSciterNodeFactory.Create(const n: IDomNode): IDomNode;
begin
  Result := TDomNode.Create(n);
end;

function TSciterNodeFactory.Create(const el: IDomElement): IDomNode;
begin
  Result := TDomNode.Create(el);
end;

function TSciterNodeFactory.CreateFromElement(h: HELEMENT): IDomNode;
begin
  Result := TDomNode.CreateFromElement(h);
end;

function TSciterNodeFactory.CreateFromNode(h: HNODE): IDomNode;
begin
  Result := TDomNode.CreateFromNode(h);
end;

function TSciterNodeFactory.CreateList: IDomNodeList;
begin
  Result := TDomNodeList.Create;
end;

{ TSciterElementFactory }

constructor TSciterElementFactory._Create;
begin
  inherited;
end;

function TSciterElementFactory.Create: IDomElement;
begin
  Result := TDomElement.Create();
end;

function TSciterElementFactory.Create(h: HELEMENT): IDomElement;
begin
  Result := TDomElement.Create(h);
end;

function TSciterElementFactory.Create(const e: IDomNode): IDomElement;
begin
  Result := TDomElement.Create(e);
end;

function TSciterElementFactory.Create(const e: IDomElement): IDomElement;
begin
  Result := TDomElement.Create(e);
end;

function TSciterElementFactory.Create(const TagName, Text: SciterString): IDomElement;
begin
  Result := SciterDom.CreateElement(TagName, Text)
end;

function TSciterElementFactory.CreateList: IDomElementList;
begin
  Result := TDomElementList.Create;
end;


{ TSciterLayoutFactory }

constructor TSciterLayoutFactory._Create;
begin
  inherited;
end;

function TSciterLayoutFactory.Create(const AThis: ISciterBase): ISciterLayout;
begin
  Result := TSciterLayout.Create(SciterObject, AThis);
end;


end.
