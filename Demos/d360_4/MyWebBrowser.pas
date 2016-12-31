unit MyWebBrowser;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterWtlCtl, OleCtrls, SHDocVw, ExtCtrls, StdCtrls;

type
  TSciterWebBrowser = class(TWinToolForm)
    Web: TWebBrowser;
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  varBrowser: TSciterWebBrowser;

implementation

{$R *.dfm}

procedure TSciterWebBrowser.Button1Click(Sender: TObject);
begin
  inherited;
  Web.Navigate(Edit1.Text);
end;

end.
