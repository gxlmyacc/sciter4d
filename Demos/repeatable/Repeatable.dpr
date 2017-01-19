program Repeatable;

uses
 {$IF CompilerVersion >= 18.5}
  SimpleShareMem,
 {$ELSE}
  FastMM4,
 {$IFEND}
  SysUtils,
  Forms,
  SciterImportDefs,
  SciterIntf,
  TiscriptIntf,
  ObjComAutoEx,
  Dialogs,
  SciterFrm in '..\..\Public\vcl\SciterFrm.pas' {SciterForm},
  MainFrm in 'MainFrm.pas' {LayeredWindow},
  FrmDataEdit in 'FrmDataEdit.pas' {frm_DataEdit};

{$R *.res}

begin
  Sciter.DriverName := ExtractFilePath(ParamStr(0)) + DLL_Sciter;
  LoadSciter4D(ExtractFilePath(ParamStr(0)) + DLL_Sciter4D);
  Sciter.ReportBehaviorCount := True;

  Tiscript.RegisterGlobalObject('Test2', WrapObjectDispatch(varTest));
  //ShowMessage(Sciter.SciterVersion);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(Tfrm_DataEdit, frm_DataEdit);
  MainForm.LoadHtmlFile('file://'+ExtractFilePath(ParamStr(0))+'Repeatable\main.html');
  Application.Run;
end.
