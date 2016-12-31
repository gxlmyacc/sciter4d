program Picasa;

uses
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm};

{$R *.res}

var
  MainFrom: TSciterForm;

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
  
  Application.Initialize;
  Application.CreateForm(TSciterForm, MainFrom);
  MainFrom.BorderStyle := bsNone;
  MainFrom.WindowState := wsMaximized;
  MainFrom.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'Picasa/main.html');
  Application.Run;
end.
