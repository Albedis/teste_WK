unit wk.facade.pedido;

interface

uses
  Data.DB, wk.model.cliente, wk.model.produto, wk.model.pedido_item,
  wk.model.pedido;

type
TFacadePedido = class(Tobject)
  private
    FMessageInfo: string;

  public
    function ClienteDataSetToModel(ADataset: TDataSet): TCliente;
    function ProdutoDataSetToModel(ADataset: TDataSet): TProduto;
    function PedidoDataSetToModel(ADataset: TDataSet): TPedido;
    function ItemPedidoDataSetToModel(ADataset: TDataSet): TPedidoItem;

    function LoadCliente(Afilter: string): TDataSet;
    function LoadProduto(Afilter: string): TDataSet;
    function LoadPedido(Afilter: string): TDataSet;
    function CalcularValorTotalPedido: Double;
    function obterCliente(AIdCliente: Integer): TCliente;

    procedure alterarItemPedido(const APedidoItem: TPedidoItem; const ANomeProduto: string);
    procedure adicionarItemPedido(ACliente: TCliente; AProduto: TProduto; AQuantidade: Double);
    procedure carregarPedido(AIdPedido: Integer);
    procedure excluirPedidoItem(AIdPedidoItem: Integer);
    procedure excluirPedido(AIdPedido: Integer);
    procedure gravarPedido;

    property MessageInfo: string read FMessageInfo;

end;

implementation

uses
  wk.controller.cliente, wk.controller.produto, wk.Controller.Pedido, wk.Controller.PedidoItem,
  wk.Service.PedidoUpdater;

{ TFacadePedido }

procedure TFacadePedido.adicionarItemPedido(ACliente: TCliente; AProduto: TProduto; AQuantidade: Double);
var
  LCtrlPedido: TCtrlPedido;
begin
  FMessageInfo := '';
  LCtrlPedido := TCtrlPedido.Create(ACliente, AProduto, AQuantidade);
  try
    try
      LCtrlPedido.adicionarItemPedido;
    except
      FMessageInfo := LCtrlPedido.MessageInfo;
    end;
  finally
    LCtrlPedido.Free;
  end;
end;

procedure TFacadePedido.alterarItemPedido(const APedidoItem: TPedidoItem; const ANomeProduto: string);
var
  LCtrlPedidoItem: TCtrlPedidoItem;
  LService: TServicePedidoUpdater;
begin
  FMessageInfo := '';
  LCtrlPedidoItem := TCtrlPedidoItem.Create;
  try
    try
      LCtrlPedidoItem.alterarItemPedido(APedidoItem, ANomeProduto);
      LService := TServicePedidoUpdater.Create(LCtrlPedidoItem);
      try
        LService.atualizarValorPedido;
      finally
        LService.Free;
      end;
    except
      FMessageInfo := LCtrlPedidoItem.MessageInfo;
    end;
  finally
    LCtrlPedidoItem.Free;
  end;
end;

function TFacadePedido.CalcularValorTotalPedido: Double;
var
  LCtrlPedidoItem: TCtrlPedidoItem;
begin
  LCtrlPedidoItem := TCtrlPedidoItem.Create;
  try
    Result := LCtrlPedidoItem.calcularTotalPedido;
  finally
    LCtrlPedidoItem.Free;
  end;
end;

procedure TFacadePedido.carregarPedido(AIdPedido: Integer);
var
  LCtrlPedido: TCtrlPedido;
begin
  LCtrlPedido := TCtrlPedido.Create;
  try
    LCtrlPedido.carregarPedido(AIdPedido);
  finally
    LCtrlPedido.Free;
  end;
end;

function TFacadePedido.ClienteDataSetToModel(ADataset: TDataSet): TCliente;
var
  LCtrlCliente: TCtrlCliente;
begin
  LCtrlCliente := TCtrlCliente.Create;
  try
    Result := LCtrlCliente.DataSetToModel(ADataset);
  finally
    LCtrlCliente.Free;
  end;
end;

procedure TFacadePedido.excluirPedido(AIdPedido: Integer);
var
  LCtrlPedido: TCtrlPedido;
begin
  LCtrlPedido := TCtrlPedido.Create;
  try
    LCtrlPedido.excluirPedido(AIdPedido);
  finally
    LCtrlPedido.Free;
  end;
end;

procedure TFacadePedido.excluirPedidoItem(AIdPedidoItem: Integer);
var
  LCtrlPedidoItem: TCtrlPedidoItem;
  LService: TServicePedidoUpdater;
begin
  LCtrlPedidoItem := TCtrlPedidoItem.Create;
  LService := TServicePedidoUpdater.Create(LCtrlPedidoItem);
  try
    LService.excluirItemPedido(AIdPedidoItem);
  finally
    LService.Free;
    LCtrlPedidoItem.Free;
  end;
end;

procedure TFacadePedido.gravarPedido;
var
  LService: TServicePedidoUpdater;
  LCtrlPedidoItem: TCtrlPedidoItem;
begin
  LCtrlPedidoItem := TCtrlPedidoItem.Create;
  LService := TServicePedidoUpdater.Create(LCtrlPedidoItem);
  try
    LService.gravarPedido;
  finally
    LCtrlPedidoItem.Free;
    LService.Free;
  end;
end;

function TFacadePedido.ItemPedidoDataSetToModel(ADataset: TDataSet): TPedidoItem;
var
  LCtrlPedidoItem: TCtrlPedidoItem;
begin
  LCtrlPedidoItem := TCtrlPedidoItem.Create;
  try
    Result := LCtrlPedidoItem.DataSetToModel(ADataset);
  finally
    LCtrlPedidoItem.Free;
  end;
end;

function TFacadePedido.LoadCliente(Afilter: string): TDataSet;
var
  LCtrlCliente: TCtrlCliente;
begin
  LCtrlCliente := TCtrlCliente.Create;
  try
    Result := LCtrlCliente.Load(AFilter);
  finally
    LCtrlCliente.Free;
  end;
end;

function TFacadePedido.LoadPedido(Afilter: string): TDataSet;
var
  LCtrlPedido: TCtrlPedido;
begin
  LCtrlPedido := TCtrlPedido.Create;
  try
    Result := LCtrlPedido.Load(Afilter);
  finally
    LCtrlPedido.Free;
  end;
end;

function TFacadePedido.LoadProduto(Afilter: string): TDataSet;
var
  LCtrlProduto: TCtrlProduto;
begin
  LCtrlProduto := TCtrlProduto.Create;
  try
    Result := LCtrlProduto.Load(AFilter);
  finally
    LCtrlProduto.Free;
  end;
end;

function TFacadePedido.obterCliente(AIdCliente: Integer): TCliente;
var
  LCtrlCliente: TCtrlCliente;
begin
  LCtrlCliente := TCtrlCliente.Create;
  try
    Result := LCtrlCliente.obterCliente(AIdCliente);
  finally
    LCtrlCliente.Free;
  end;
end;

function TFacadePedido.PedidoDataSetToModel(ADataset: TDataSet): TPedido;
var
  LCtrlPedido: TCtrlPedido;
begin
  LCtrlPedido := TCtrlPedido.Create;
  try
    Result := LCtrlPedido.DataSetToModel(ADataset);
  finally
    LCtrlPedido.Free;
  end;
end;

function TFacadePedido.ProdutoDataSetToModel(ADataset: TDataSet): TProduto;
var
  LCtrlProduto: TCtrlProduto;
begin
  LCtrlProduto := TCtrlProduto.Create;
  try
    Result := LCtrlProduto.DataSetToModel(ADataset);
  finally
    LCtrlProduto.Free;
  end;
end;

end.
