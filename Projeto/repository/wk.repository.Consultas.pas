unit wk.repository.Consultas;

interface

uses
  FireDAC.Comp.Client;

type
  TConsultaRepository = class
    private
      FConn: TFDConnection;
    function GetDataPacket(const ASQL: string): OleVariant;
    public
      constructor Create(AConn: TFDConnection);

      function LoadPedidos: Olevariant;
      function LoadClientes: Olevariant;
      function LoadProdutos: Olevariant;
  end;

implementation

uses
  Datasnap.Provider, wk.sql.pedido, wk.sql.cliente, wk.sql.produto;

{ TConsultasRepository }

constructor TConsultaRepository.Create(AConn: TFDConnection);
begin
  FConn := AConn;
end;

function TConsultaRepository.LoadClientes: Olevariant;
begin
  Result := GetDataPacket(TClienteSQL.LoadAll);
end;

function TConsultaRepository.LoadPedidos: Olevariant;
var
  LSQL: string;
begin
  LSQL := TPedidoSQL.LoadAll;
  Result := GetDataPacket(LSQL);
end;

function TConsultaRepository.LoadProdutos: Olevariant;
var
  LSQL: string;
begin
  LSQL :=  TProdutoSQL.LoadAll;
  Result := GetDataPacket(LSQL);
end;

function TConsultaRepository.GetDataPacket(const ASQL: string): OleVariant;
var
  LQuery: TFDQuery;
  LProvider: TDataSetProvider;
begin
  LQuery := TFDQuery.Create(nil);
  LProvider := TDataSetProvider.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := ASQL;
    LQuery.Open;

    LProvider.DataSet := LQuery;
    Result := LProvider.Data;
  finally
    LProvider.Free;
    LQuery.Free;
  end;
end;

end.
