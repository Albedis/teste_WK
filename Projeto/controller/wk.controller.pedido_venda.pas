unit wk.controller.pedido_venda;

interface

uses
  System.SysUtils,
  wk.model.pedido,
  wk.model.cliente,
  wk.repository.pedido,
  wk.model.pedido_item,
  wk.model.produto,
  wk.DTO.PedidoItem;

type
  TPedidoVendaController = class
  private
    FNextIdTemp: Integer;
    FPedido: TPedido;
    FRepository: TPedidoRepository;
    procedure ValidarPedidoIniciado;
  public
    constructor Create(ARepository: TPedidoRepository);
    destructor Destroy; override;

    function ObterItemPedido(AIdItem: Integer): TPedidoItem;
    function Pedido: TPedido;
    function PodeAlterarCliente: Boolean;
    function GetItensDTO: TArray<TPedidoItemDTO>;

    procedure NovoPedido(ACliente: TCliente);
    procedure CarregarPedido(AId: Integer);

    // trabalhando com Lista de objetos:
    procedure AdicionarItem(AProduto: TProduto; AQtd: Double; AValor: Currency);
    procedure RemoverItem(AIdItem: Integer);
    procedure AlterarItem(AItemId: Integer; AQuantidade: Double; AValor: Currency);

    procedure SalvarPedido;
    procedure ExcluirPedido;

  end;

implementation

uses
  System.Generics.Collections;

{ TPedidoVendaController }

constructor TPedidoVendaController.Create(ARepository: TPedidoRepository);
begin
  inherited Create;
  FRepository := ARepository;
  FNextIdTemp := 0;
end;

destructor TPedidoVendaController.Destroy;
begin
  if Assigned(FPedido) then
    FreeAndNil(FPedido);
  inherited;
end;

procedure TPedidoVendaController.NovoPedido(ACliente: TCliente);
begin
  FNextIdTemp := 0;

  if Assigned(FPedido) then
    FreeAndNil(FPedido);

  if Assigned(ACliente) then
    FPedido := TPedido.Create(ACliente);
end;

function TPedidoVendaController.ObterItemPedido(AIdItem: Integer): TPedidoItem;
var
  LPedidoItem: TPedidoItem;
begin
  Result := nil;
  ValidarPedidoIniciado;

  if FPedido.Itens.TryGetValue(AIdItem, LPedidoItem) then
    Exit(LPedidoItem);

  raise Exception.Create('Erro Interno: Item do pedido não foi encontrado!');

end;

procedure TPedidoVendaController.AlterarItem(AItemId: Integer;
  AQuantidade: Double; AValor: Currency);
var
  LItem: TPedidoItem;
begin
  ValidarPedidoIniciado;
  if not FPedido.Itens.TryGetValue(AItemId, LItem) then
    raise Exception.Create('Erro interno: o item não foi encontrado!');
  LItem.Quantidade := AQuantidade;
  LItem.ValorUnitario := AValor;
end;

procedure TPedidoVendaController.CarregarPedido(AId: Integer);
begin
  if Assigned(FPedido) then
    FreeAndNil(FPedido);

  FPedido := FRepository.BuscarPorId(AId);

  if not Assigned(FPedido) then
    FNextIdTemp := FPedido.Itens.Count;

end;

function TPedidoVendaController.Pedido: TPedido;
begin
  Result := nil;
  if Assigned(FPedido) then
    Result := FPedido;
end;

function TPedidoVendaController.PodeAlterarCliente: Boolean;
begin
  Result := Assigned(FPedido) and (FPedido.Id = 0);
end;

procedure TPedidoVendaController.AdicionarItem(AProduto: TProduto;
  AQtd: Double; AValor: Currency);
var
  LItem: TPedidoItem;
begin
  ValidarPedidoIniciado;
  LItem := TPedidoItem.Create(AProduto, AQtd, AValor);
  try
    Inc(FNextIdTemp);
    LItem.Id := FNextIdTemp;
    LItem.IdPedido := FPedido.Id;
    FPedido.AdicionarItem(LItem);
  except
    FreeAndNil(LItem);
    raise;
  end;
end;

procedure TPedidoVendaController.RemoverItem(AIdItem: Integer);
begin
  ValidarPedidoIniciado;
  FPedido.RemoverItem(AIdItem);
end;

procedure TPedidoVendaController.SalvarPedido;
begin
  ValidarPedidoIniciado;
  FRepository.Salvar(FPedido);
end;

procedure TPedidoVendaController.ExcluirPedido;
begin
  if not Assigned(FPedido) or (FPedido.Id = 0) then
    raise Exception.Create('Não há pedido gravado para excluir.');

  FRepository.Excluir(FPedido);
  FreeAndNil(FPedido);
end;

procedure TPedidoVendaController.ValidarPedidoIniciado;
begin
  if not Assigned(FPedido) then
    raise Exception.Create('Erro interno: pedido não iniciado.');
end;

function TPedidoVendaController.GetItensDTO: TArray<TPedidoItemDTO>;
var
  LItem: TPedidoItem;
  LDTO: TPedidoItemDTO;
  LList: TList<TPedidoItemDTO>;
begin
  LList := TList<TPedidoItemDTO>.Create;
  try
    if Assigned(FPedido) then
      for LItem in FPedido.Itens.Values do
      begin
        LDTO.IdItem := LItem.Id;
        LDTO.IdProduto := LItem.Produto.id_produto;
        LDTO.DescricaoProduto := LItem.Produto.Descricao;
        LDTO.Quantidade := LItem.Quantidade;
        LDTO.ValorUnitario := LItem.ValorUnitario;
        LDTO.ValorTotal := LItem.total;
        LList.Add(LDTO);
      end;
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

end.

