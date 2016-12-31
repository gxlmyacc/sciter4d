program uminimal;

uses
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MinimalWindow},
  UminimalBehavior in 'UminimalBehavior.pas';

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;
  
  Application.Initialize;
  Application.CreateForm(TUminimalWindow, UminimalWindow);
  UminimalWindow.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'uminimal\main.htm');
  Application.Run;
end.
