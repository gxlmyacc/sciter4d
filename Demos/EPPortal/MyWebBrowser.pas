unit MyWebBrowser;

interface

uses
  SysUtils, Classes, Controls, Forms, windows,
  SHDocVw, ExtCtrls, StdCtrls, OleCtrls, SciterIntf;

type
  TSciterWebBrowser = class(TForm)
    Web: TWebBrowser;
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FURL: WideString;
    FhHandle:Thandle;
    function GetHandle: Thandle;
    procedure SetHandle(const Value: Thandle); 
    { Private declarations }
  public
    procedure Navigate(const URL: WideString);

    property URL: WideString read FURL;
    property hHandle:Thandle  read GetHandle write SetHandle;
    constructor Create(AOwner: TComponent); override;
  end;


var
  webBrowser: TSciterWebBrowser;
  
implementation

{$R *.dfm}


procedure TSciterWebBrowser.Button1Click(Sender: TObject);
begin
  inherited;
  Web.Navigate(Edit1.Text);
end;

constructor TSciterWebBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FhHandle := 0;
end;

function TSciterWebBrowser.GetHandle: Thandle;
begin
   Result := FhHandle;
end;

procedure TSciterWebBrowser.Navigate(const URL: WideString);
begin
  FURL := URL;
  Web.Navigate(URL);
end;

procedure TSciterWebBrowser.SetHandle(const Value: Thandle);
begin
 FhHandle := Value;
 if FhHandle > 0 then
  begin
      windows.SetParent(FhHandle, self.Handle) ;
      windows.SetWindowPos(FhHandle, HWND_TOP, 0, 0, webBrowser.Width , webBrowser.Height, SWP_SHOWWINDOW or SWP_DRAWFRAME);
      SetForegroundWindow(FhHandle);
  end;
end;

procedure TSciterWebBrowser.FormResize(Sender: TObject);
begin
  inherited;
  if FhHandle > 0 then
  begin 
      windows.SetWindowPos(FhHandle, HWND_TOP, 0, 0, webBrowser.Width , webBrowser.Height, SWP_SHOWWINDOW or SWP_DRAWFRAME);
      SetForegroundWindow(FhHandle);
  end;
end;

procedure TSciterWebBrowser.Button2Click(Sender: TObject);
begin
  inherited;
  self.Invalidate;
  self.Repaint;
  self.Refresh;

end;

end.
