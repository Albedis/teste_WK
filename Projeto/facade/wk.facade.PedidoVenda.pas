unit wk.facade.PedidoVenda;

interface

uses
  System.SysUtils, wk.controller.pedido_venda, wk.repository.pedido,
  wk.dm.PedidoVenda, wk.connection.conn, wk.model.cliente, wk.model.produto,
  wk.DTO.PedidoItem, wk.model.pedido_item;


type
  TPedidoVendaFacade = class
  private
    FCtrlPedidoVenda: TPedidoVendaController;
    FRepository: TPedidoRepository;
    FdmPedido: TdmPedido;
  public
    constructor Create(ADMConexao: TdmConn);
    destructor Destroy; override;

    function ExisteItensPedido: Boolean;
    function GetItensDTO: TArray<TPedidoItemDTO>;
    function PodeAlterarCliente: Boolean;
    function ValorTotalPedido: Currency;
    function ObterClienteDoPedido: TCliente;
    function ObterDataEmisaoPedido: TDate;
    function ObterItemPedido(AIdItem: Integer): TPedidoItem;
    function ObterIdPedidoVenda: Integer;

    //OLD: se utilizar TClientDataSet para popular a grid:
    procedure AddItemDataSet(ACliente: TCliente; AProduto: TProduto;
      AQuantidade: Double; AValorUnit: Currency);
    procedure RemoverItemDataSet(AIdItem: Integer);
    //-------------------------------------------

    procedure AlterarCliente(ACliente: TCliente);
    procedure AlterarItem(AItemId: Integer; AQtd: Double; AValor: Currency);
    procedure NovoPedido(ACliente: TCliente);
    procedure CarregarPedido(AId: Integer);
    procedure AdicionarItem(ACliente: TCliente; AProduto: TProduto;
      AQuantidade: Double; AValor: Currency);
    procedure RemoverItem(AIdItem: Integer);
    procedure GravarPedido;
    procedure ExcluirPedido;

  end;

implementation

{ TPedidoVendaFacade }

constructor TPedidoVendaFacade.Create(ADMConexao: TdmConn);
begin
  inherited Create;

  if not Assigned(ADMConexao) then
    raise Exception.Create('Erro interno: conexão com o banco de dados não instanciada!');

  FdmPedido := TdmPedido.Create(nil); // se utilizando TClientDataSet;
  FRepository := TPedidoRepository.Create(ADMConexao.Connection); // CRUD
  FCtrlPedidoVenda := TPedidoVendaController.Create(FRepository); // Controller
end;

destructor TPedidoVendaFacade.Destroy;
begin
  FCtrlPedidoVenda.Free;
  FRepository.Free;
  FdmPedido.Free;
  inherited;
end;

procedure TPedidoVendaFacade.NovoPedido(ACliente: TCliente);
begin
  FCtrlPedidoVenda.NovoPedido(ACliente);
end;

function TPedidoVendaFacade.ObterClienteDoPedido: TCliente;
begin
  Result := nil;
  if FCtrlPedidoVenda.Pedido <> nil then
    Result := FCtrlPedidoVenda.Pedido.Cliente;
end;

function TPedidoVendaFacade.ObterDataEmisaoPedido: TDate;
begin
  Result := 0;
  if FCtrlPedidoVenda.Pedido <> nil then
    Result := FCtrlPedidoVenda.Pedido.DataEmissao;
end;

function TPedidoVendaFacade.ObterIdPedidoVenda: Integer;
begin
  Result := 0;
  if FCtrlPedidoVenda.Pedido <> nil then
    Result := FCtrlPedidoVenda.Pedido.Id;
end;

function TPedidoVendaFacade.ObterItemPedido(AIdItem: Integer): TPedidoItem;
begin
  Result := FCtrlPedidoVenda.ObterItemPedido(AIdItem);
end;

procedure TPedidoVendaFacade.AdicionarItem(ACliente: TCliente; AProduto: TProduto;
  AQuantidade: Double; AValor: Currency);
begin
  if (FCtrlPedidoVenda.Pedido = nil) then
    FCtrlPedidoVenda.NovoPedido(ACliente);

  if FCtrlPedidoVenda.Pedido.Cliente.id_cliente <> ACliente.id_cliente then
    FCtrlPedidoVenda.Pedido.AlterarCliente(ACliente);

  FCtrlPedidoVenda.AdicionarItem(AProduto, AQuantidade, AValor);

end;

procedure TPedidoVendaFacade.AlterarCliente(ACliente: TCliente);
begin
  if (FCtrlPedidoVenda.Pedido = nil) or not Assigned(ACliente) then
    Exit;

  if (FCtrlPedidoVenda.Pedido.Cliente.id_cliente <> ACliente.id_cliente) then
    FCtrlPedidoVenda.Pedido.AlterarCliente(ACliente);
end;

procedure TPedidoVendaFacade.AlterarItem(AItemId: Integer;
  AQtd: Double; AValor: Currency);
begin
  FCtrlPedidoVenda.AlterarItem(AItemId, AQtd, AValor);
end;

// carregar o pedido e seus itens do banco de dados:
procedure TPedidoVendaFacade.CarregarPedido(AId: Integer);
begin
  FCtrlPedidoVenda.CarregarPedido(AId);
end;

function TPedidoVendaFacade.PodeAlterarCliente: Boolean;
begin
  Result := FCtrlPedidoVenda.PodeAlterarCliente;
end;

// inserir no ClientDataSet:
procedure TPedidoVendaFacade.AddItemDataSet(ACliente: TCliente; AProduto: TProduto;
  AQuantidade: Double; AValorUnit: Currency);
begin
  // se ainda não há pedido criado, cria agora
  if FCtrlPedidoVenda.Pedido = nil then
    FCtrlPedidoVenda.NovoPedido(ACliente);

  if FCtrlPedidoVenda.Pedido.Cliente.id_cliente <> ACliente.id_cliente then
    FCtrlPedidoVenda.Pedido.AlterarCliente(ACliente);

  // adiciona item apenas no dataset (grid)
  FdmPedido.AddItem(AProduto, AQuantidade, AValorUnit);
end;

procedure TPedidoVendaFacade.RemoverItem(AIdItem: Integer);
begin
  FCtrlPedidoVenda.RemoverItem(AIdItem);
end;

// remove item do ClientDataSet (memoria)
procedure TPedidoVendaFacade.RemoverItemDataSet(AIdItem: Integer);
begin
  FdmPedido.RemoveItem(AIdItem);
end;

function TPedidoVendaFacade.ValorTotalPedido: Currency;
begin
  Result := FCtrlPedidoVenda.Pedido.ValorTotalItens;
end;

// gravar no banco de dados: persistencia
procedure TPedidoVendaFacade.GravarPedido;
begin
  FCtrlPedidoVenda.SalvarPedido;
end;

// excluir o pedido e seus itens do banco de dados.
procedure TPedidoVendaFacade.ExcluirPedido;
begin
  FCtrlPedidoVenda.ExcluirPedido;
end;

function TPedidoVendaFacade.ExisteItensPedido: Boolean;
begin
  Result := False;
  if FCtrlPedidoVenda.Pedido <> nil then
    Result := FCtrlPedidoVenda.Pedido.Itens.Count > 0;
end;

function TPedidoVendaFacade.GetItensDTO: TArray<TPedidoItemDTO>;
begin
  Result := FCtrlPedidoVenda.GetItensDTO;
end;





end.

