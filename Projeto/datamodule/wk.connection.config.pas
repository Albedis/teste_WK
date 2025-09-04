unit wk.connection.config;

interface

uses
  System.SysUtils, System.IniFiles,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef;

function ExeDir: string;
function AppConfigIniPath: string;
procedure LoadConnection(AConn: TFDConnection; ADrvLink: TFDPhysMySQLDriverLink);

implementation

uses
  Vcl.Forms;

function ExeDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

function AppConfigIniPath: string;
begin
  Result := ExeDir + 'DBConfig.ini';
end;

procedure LoadConnection(AConn: TFDConnection; ADrvLink: TFDPhysMySQLDriverLink);
var
  LIni: TIniFile;
  LIniPath,
  LDriverID,
  LVendorLib,
  LServer,
  LDatabase,
  LUser,
  LPass,
  LCharset,
  LSSLMode,
  LPort: string;
begin
  LIniPath := AppConfigIniPath;

  try
    if not FileExists(LIniPath) then
      raise Exception.CreateFmt('Arquivo INI não encontrado em %s', [LIniPath]);

    LIni := TIniFile.Create(LIniPath);
    try
      LDriverID    := LIni.ReadString('mysql', 'DriverID', 'MySQL');
      LVendorLib   := LIni.ReadString('mysql', 'VendorLib', 'libmysql.dll');
      LServer      := LIni.ReadString('mysql', 'Server', 'localhost');
      LPort        := LIni.ReadString('mysql', 'Port', '3306');
      LDatabase    := LIni.ReadString('mysql', 'Database', 'wkdatabase');
      LUser        := LIni.ReadString('mysql', 'UserName', 'root');
      LPass        := LIni.ReadString('mysql', 'Password', '');
      LCharset     := LIni.ReadString('mysql', 'CharacterSet','utf8mb4');
      LSSLMode     := LIni.ReadString('mysql', 'SSLMode', 'DISABLED');

      if Assigned(ADrvLink) then
      begin
        LVendorLib := Exedir + '\' + LVendorLib;
        if FileExists(LVendorLib) then
          ADrvLink.VendorLib := LVendorLib
        else
          raise Exception.CreateFmt('Arquivo libmysql.dll não encontrado em %s', [LVendorLib]);
      end;

      AConn.Connected := False;
      AConn.LoginPrompt := false;
      AConn.Params.Clear;

      AConn.Params.Add('DriverID='    + LDriverID);
      AConn.Params.Add('Server='      + LServer);
      AConn.Params.Add('Port='        + LPort);
      AConn.Params.Add('Database='    + LDatabase);
      AConn.Params.Add('User_Name='   + LUser);
      AConn.Params.Add('Password='    + LPass);
      AConn.Params.Add('CharacterSet='+ LCharset);
      AConn.Params.Add('SSLMode=' + UpperCase(LSSLMode));

    finally
      LIni.Free;
    end;
  except
    on E:Exception do
    begin
      E.Message :=
       'Erro ocorrido ao conectar o banco de dados.' + sLineBreak + E.Message;
      raise;
    end;
  end;
end;

end.
