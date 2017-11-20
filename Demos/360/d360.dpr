program d360;

uses
  SysUtils,
  Windows,
  Forms,
  SciterImportDefs,
  SciterIntf,
  SciterArchiveIntf,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {MinimalWindow};

{$R *.res}

begin
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  Sciter.ReportBehaviorCount := True;

  SciterArchive.Open(ExtractFilePath(ParamStr(0)) + 'd360.dat');

  //SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, Cardinal(False), nil, 0);

  Application.Initialize;
  Application.CreateForm(Td360Window, d360Window);
  // d360Window.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'d360\main.html');
  d360Window.LoadHtmlFile('this://app/main.html');
  Application.Run;
end.
