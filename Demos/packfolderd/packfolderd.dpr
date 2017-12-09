program packfolderd;

{$APPTYPE CONSOLE}

{$R 'res.res' 'res.rc'}

uses
  SysUtils,
  Classes,
  ShellAPI,
  Windows,
  StrUtils,
  NativePublic in 'NativePublic.pas';

var
  packfolderFile: string;
  sCurrentDir, sPackfolder, sResourceFile, sTargetFile: string;
  msResource: TMemoryStream;
  pByte: PAnsiChar;
begin
  sCurrentDir := GetCurrentDir;
  sPackfolder := ParamStr(1);
  sResourceFile := IncludeTrailingPathDelimiter(sCurrentDir) + '~resources.sar';
  sTargetFile := IncludeTrailingPathDelimiter(sCurrentDir) + ExtractFileName(sPackfolder) + '.dat';
  packfolderFile := ExtractFilePath(ParamStr(0)) + 'packfolder.exe';
  if not FileExists(packfolderFile) then
  begin
    if not ExtractRes('packfolder', 'exe', packfolderFile) then
    begin
      Writeln(Format('[%s] file not extract resource fail!', [ExtractFileName(packfolderFile)]));
      Exit;
    end;
  end;
  if not FileExists(packfolderFile) then
  begin
    Writeln(Format('[%s] file not exist!', [ExtractFileName(packfolderFile)]));
    Exit;
  end;
  if not WinExecAndWait32(packfolderFile, sPackfolder + ' resources.sar -binary', sCurrentDir, SW_HIDE) then
  begin
    Writeln(Format('run [%s] fail!', [ExtractFileName(packfolderFile)]));
    Exit;
  end;
  if not FileExists(sResourceFile) then
  begin
    Writeln(Format('resources file [%s] not find!', [sResourceFile]));
    Exit;
  end;
  msResource := TMemoryStream.Create;
  try
    msResource.LoadFromFile(sResourceFile);
    pByte := msResource.Memory;
    CopyMemory(pByte, PChar('dat'), 3);
    msResource.SaveToFile(sTargetFile);
  finally
    msResource.Free;
  end;
  if FileExists(sResourceFile) then
    DeleteFile(PChar(sResourceFile));
end.
