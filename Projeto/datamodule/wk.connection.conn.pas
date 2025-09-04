unit wk.connection.conn;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client;

type
  TdmConn = class(TDataModule)
    FDConn: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConectarDataBase;
  public
    function Connection: TFDConnection;
    function DataBaseConnected: Boolean;
  end;

var
  dmConn: TdmConn;

implementation

uses
  wk.connection.config, Vcl.Forms, Vcl.Dialogs;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TdmConn.Connection: TFDConnection;
begin
  if not DataBaseConnected then
    ConectarDataBase;
  Result := FDConn;
end;

procedure TdmConn.DataModuleCreate(Sender: TObject);
begin
  ConectarDataBase;
end;

function TdmConn.DataBaseConnected: Boolean;
begin
  Result := FDConn.Connected;
end;

procedure TdmConn.ConectarDataBase;
begin
  try
    LoadConnection(FDConn, FDPhysMySQLDriverLink1);
    FDConn.Connected := True;
  except
    raise;
  end;
end;

end.
