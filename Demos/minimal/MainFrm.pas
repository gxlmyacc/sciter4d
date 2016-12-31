unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterTypes, SciterIntf;

type
  TMinimalWindow = class(TSciterForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function DoLoadData(var pnmld: LPSCN_LOAD_DATA; const schema: PSciterSchemaInfo; var Handled: Boolean): TLoadDataResult;
  end;

var
  MinimalWindow: TMinimalWindow;

implementation

{$R *.dfm}
// generate BGRA image
// check http://sciter.com/forums/topic/how-to-render-memory-image-in-sciter-page/
procedure GenerateBGRATestsImage(hSciter: HWND; Layout: PISciterLayout);
var
  packedData: array[0..4 + 4 + 4 + 10 * 10 * 4 - 1] of Byte;
  i: Integer;
begin
  ZeroMemory(@packedData, SizeOf(packedData));

  // signature
  packedData[0] := Ord('B');
	packedData[1] := Ord('G');
	packedData[2] := Ord('R');
  packedData[3] := Ord('A');

  // width/height
  packedData[7] := 10;
  packedData[11] := 10;

  // image data
  i := 0;
  while i < 10 * 10 * 4 do
  begin
    packedData[4 + 4 + 4 + i] := i div 4;
    packedData[4 + 4 + 4 + i + 1] := 255 - i div 4;
    packedData[4 + 4 + 4 + i + 2] := 255;
    packedData[4 + 4 + 4 + i + 3] := 255;
    i := i + 4;
  end;
  Layout.DataReady('in-memory:test', @packedData, sizeof(packedData));
end;

function TMinimalWindow.DoLoadData(var pnmld: LPSCN_LOAD_DATA; const schema: PSciterSchemaInfo;
  var Handled: Boolean): TLoadDataResult;
begin
  if pnmld.uri = 'in-memory:test' then
  begin
    GenerateBGRATestsImage(Self.Handle, Layout);
    Handled := True;
  end;
  Result := LOAD_OK;
end;

procedure TMinimalWindow.FormCreate(Sender: TObject);
begin
  inherited;
  Layout.OnLoadData := DoLoadData;
end;

end.
