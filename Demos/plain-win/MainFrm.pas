unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf;

type
  TPlainWindow = class(TSciterForm)
  protected
    procedure DoWndProc(var Msg: TMessage; var Handled: Boolean); override;
  end;

var
  PlainWindow: TPlainWindow;

implementation

{$R *.dfm}

uses
  SciterDebugIntf, SciterFactoryIntf;

{ TPlainWindow }

procedure TPlainWindow.DoWndProc(var Msg: TMessage;
  var Handled: Boolean);
var
  r: IDomValue;
  root, el_time: IDomElement;
begin
  if Layout = nil then
  begin
    Handled := False;
    Exit;
  end;

  if (Msg.Msg = WM_KEYDOWN) then
  begin
    Handled := True;
    
    case Msg.WParam of
      VK_F12:
      begin
        DebugOut.Inspect(Layout);
        Msg.Result := 0;
      end;
      VK_F5:
      begin
        Layout.LoadFile('res:default.htm');
        Msg.Result := 0;
      end;
      VK_F2:
      begin
        r := Layout.RootElement.CallFunction('Test.add', [ValueFactory.Create(2), ValueFactory.Create(2)]);
        Assert(r.IsInt() and (r.AsInteger(0) = 4));
        Msg.Result := 0;
      end;
      VK_F9:
      begin
        Layout.LoadFile('http://terrainformatica.com/tests/test.htm');
        Msg.Result := 0;
      end;
      VK_F8:
      begin
        root := self.Layout.RootElement;
        el_time := root.FindFirst('input#time');
        el_time.Value := ValueFactory.DateTime(now);
        Msg.Result := 0;
      end;
    else
      Handled := False;
    end;
  end;
end;

end.
