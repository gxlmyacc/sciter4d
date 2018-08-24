{*******************************************************************************
 标题:     SciterHash.pas
 描述:     Sciter4D中使用的计算函数单元
 创建时间：2015-05-07
 作者：    gxlmyacc
 ******************************************************************************}
unit SciterMath;

interface

function Max(const A, B: Integer): Integer;


implementation

function Max(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;


end.
