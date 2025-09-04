unit wk.facade.Consultas;

interface

uses
  wk.connection.conn, wk.repository.Consultas, wk.model.pedido, Data.DB,
  wk.model.cliente, wk.model.produto;

type
TConsultasFacade = class
  private
    FRepository: TConsultaRepository;
  public
    constructor Create(ADMConexao: TdmConn);
    function LoadPedidos: Olevariant;
    function LoadClientes: Olevariant;
    function LoadProdutos: Olevariant;

    function PedidoDataSetToModel(ADataSet: TDataSet): TPedido;
    function ClienteDataSetToModel(ADataSet: TDataSet): TCliente;
    function ProdutoDataSetToModel(ADataSet: TDataSet): TProduto;

end;

implementation

uses
  wk.factory.model;

{ TConsultasFacade }

function TConsultasFacade.ClienteDataSetToModel(ADataSet: TDataSet): TCliente;
begin
  Result:= TModelFactory.ClienteFromDataset(ADataSet);
end;

constructor TConsultasFacade.Create(ADMConexao: TdmConn);
begin
  FRepository := TConsultaRepository.Create(dmConn.Connection);
end;

function TConsultasFacade.LoadClientes: Olevariant;
begin
  Result := FRepository.LoadClientes;
end;

function TConsultasFacade.LoadPedidos: Olevariant;
begin
  Result := FRepository.LoadPedidos;
end;

function TConsultasFacade.LoadProdutos: Olevariant;
begin
  Result := FRepository.LoadProdutos;
end;

function TConsultasFacade.PedidoDataSetToModel(ADataSet: TDataSet): TPedido;
begin
  Result := TModelFactory.PedidoFromDataset(ADataSet, nil);
end;

function TConsultasFacade.ProdutoDataSetToModel(ADataSet: TDataSet): TProduto;
begin
  Result := TModelFactory.ProdutoFromDataset(ADataSet);
end;

end.
