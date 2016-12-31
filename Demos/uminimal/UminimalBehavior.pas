unit UminimalBehavior;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior, ActiveX, TiscriptIntf;

type
  TUminimalBehavior = class(TBehaviorEventHandler)
  published
    function helloWorld(s: WideString): WideString;

    function nativeApi(): IObjectInterface;
  end;

  TNaitiveMath = class(TSciterRttiObject)
  published
    function sum(a, b: Integer): Integer;
    function sub(a, b: Integer): Integer;
  end;

  TNativeApi = class(TSciterRttiObject)
  private
    FMath: IObjectInterface;
  published
    function GetMath: IObjectInterface;

    property math: IObjectInterface read GetMath;
  end;

implementation

{ TUminimalBehavior }

function TUminimalBehavior.helloWorld(s: WideString): WideString;
begin
  try
    Result := 'ÄãºÃ u-minimal World ' + s;
  except
    on E: Exception do
    begin
      OutputDebugString(PChar('[TUminimalBehavior.helloWorld]'+E.Message));
    end
  end;
end;

function TUminimalBehavior.nativeApi: IObjectInterface;
begin
  Result := TNativeApi.Create;
end;


function TNaitiveMath.sub(a, b: Integer): Integer;
begin
  Result := a - b;
end;

function TNaitiveMath.sum(a, b: Integer): Integer;
begin
  Result := a + b;
end;

{ TNativeApi }

function TNativeApi.GetMath: IObjectInterface;
begin
  if FMath = nil then
    FMath := TNaitiveMath.Create;
  Result := FMath;
end;

end.
