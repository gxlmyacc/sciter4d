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
  sCurrentDir, sResourceFile, sTargetFile, sResource: string;
  iPrefixLen, iSuffixLen, i: Integer;
  lsBytes: TStrings;
  msResource: TMemoryStream;
  pByte: PAnsiChar;
begin
  sCurrentDir := GetCurrentDir;
  sResourceFile := IncludeTrailingPathDelimiter(sCurrentDir) + 'resources.cpp';
  sTargetFile := IncludeTrailingPathDelimiter(sCurrentDir) + 'resources.dat';
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
  if not WinExecAndWait32(packfolderFile, ParamStr(1) + ' resources.cpp -v "resources"', sCurrentDir, SW_HIDE) then
  begin
    Writeln(Format('run [%s] fail!', [ExtractFileName(packfolderFile)]));
    Exit;
  end;
  if not FileExists(sResourceFile) then
  begin
    Writeln(Format('resources file [%s] not find!', [sResourceFile]));
    Exit;
  end;
  iPrefixLen := Length('const unsigned char resources[] = {'#$A#9);
  iSuffixLen := Length(', };'#$A);
  sResource := StrLoadFromFile(sResourceFile);
  sResource := Copy(sResource, iPrefixLen+1, Length(sResource)-iPrefixLen-iSuffixLen);
  lsBytes := TStringList.Create;
  try
    lsBytes.Delimiter := ',';
    lsBytes.DelimitedText := sResource;

    msResource := TMemoryStream.Create;
    try
      msResource.SetSize(lsBytes.Count);
      pByte := msResource.Memory;
      CopyMemory(pByte, PChar('dat'), 3);
      for i := 3 to lsBytes.Count - 1 do
        pByte[i] := AnsiChar(StrToInt(lsBytes[i]));
      msResource.SaveToFile(sTargetFile);
    finally
      msResource.Free;
    end;
  finally
    lsBytes.Free;
  end;
  if FileExists(sResourceFile) then
    DeleteFile(PChar(sResourceFile));
end.
