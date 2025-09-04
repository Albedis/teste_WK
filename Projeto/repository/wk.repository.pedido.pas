unit wk.repository.pedido;

interface

uses
  System.SysUtils, System.Generics.Collections,
  FireDAC.Comp.Client, Data.DB,
  wk.model.pedido, wk.model.pedido_item, wk.model.cliente, wk.model.produto,
  wk.sql.pedido, wk.sql.pedido_item;

type
  TPedidoRepository = class
  private
    FConn: TFDConnection;
    FCache: TObjectDictionary<Integer, TPedido>;

    function DataSetToModelPedido(ADataSet: TDataSet): TPedido;
    function DataSetToModelPedidoItem(ADataSet: TDataSet): TPedidoItem;

  public
    constructor Create(AConn: TFDConnection);
    destructor Destroy; override;

    function BuscarPorId(AId: Integer): TPedido;
    procedure Inserir(APedido: TPedido);
    procedure Atualizar(APedido: TPedido);
    procedure Salvar(APedido: TPedido); // insert ou update
    procedure Excluir(APedido: TPedido);
    procedure LimparCache;
    procedure SalvarDoDataSet(ACliente: TCliente; ADataSet: TDataSet);
  end;

implementation

uses
  wk.factory.model;

{ TPedidoRepository }

constructor TPedidoRepository.Create(AConn: TFDConnection);
begin
  FConn := AConn;
  FCache := TObjectDictionary<Integer, TPedido>.Create([doOwnsValues]);
end;

destructor TPedidoRepository.Destroy;
begin
  FCache.Free;
  inherited;
end;

function TPedidoRepository.BuscarPorId(AId: Integer): TPedido;
var
  LQueryPedido: TFDQuery;
  LQueryItens: TFDQuery;
  LPedidoItem: TPedidoItem;
begin
  Result := nil;

  // consultar o pedido, considerar JOIN com cliente:
  LQueryPedido := TFDQuery.Create(nil);
  try
    LQueryPedido.Connection := FConn;
    LQueryPedido.SQL.Text := TPedidoSQL.SelectById;
    LQueryPedido.ParamByName('id').AsInteger := AId;
    LQueryPedido.Open;

    if LQueryPedido.IsEmpty then
      raise Exception.Create('Pedido não foi encontrado!');

    Result := DataSetToModelPedido(LQueryPedido);

    // consulta itens do pedido, considerar JOIN com produto:
    LQueryItens := TFDQuery.Create(nil);
    try
      LQueryItens.Connection := FConn;
      LQueryItens.SQL.Text := TPedidoItemSQL.SelectByPedidoId;
      LQueryItens.ParamByName('id_pedido').AsInteger := AId;
      LQueryItens.Open;

      if LQueryItens.IsEmpty then
        raise Exception.Create('O pedido não possui itens!');

      LQueryItens.First;
      while not LQueryItens.Eof do
      begin
        LPedidoItem := DataSetToModelPedidoItem(LQueryItens);
        Result.Itens.AddOrSetValue(LPedidoItem.Id, LPedidoItem);
        LQueryItens.Next;
      end;
    finally
      LQueryItens.Free;
    end;

  finally
    LQueryPedido.Free;
  end;
end;

procedure TPedidoRepository.LimparCache;
begin
  FCache.Clear;
end;

function TPedidoRepository.DataSetToModelPedido(ADataSet: TDataSet): TPedido;
var
  LCliente: TCliente;
  LPedido: TPedido;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  LCliente := TModelFactory.ClienteFromDataset(ADataSet);
  LPedido := TModelFactory.PedidoFromDataset(ADataSet, LCliente);
  Result := LPedido;
end;

function TPedidoRepository.DataSetToModelPedidoItem(ADataSet: TDataSet): TPedidoItem;
var
  LProduto: TProduto;
  LItem: TPedidoItem;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  LProduto := TModelFactory.ProdutoFromDataset(ADataSet);
  LItem := TModelFactory.PedidoItemFromDataset(ADataSet, LProduto);
  Result := LItem;
end;

procedure TPedidoRepository.Inserir(APedido: TPedido);
var
  LQuery: TFDQuery;
  LItem: TPedidoItem;
begin
  LQuery := TFDQuery.Create(nil);
  try
    FConn.StartTransaction;
    try
      // crair o pedido, obtendo somatório do valor dos itens:
      LQuery.Connection := FConn;
      LQuery.SQL.Text := TPedidoSQL.Insert;
      LQuery.ParamByName('id_cliente').AsInteger := APedido.Cliente.id_cliente;
      LQuery.ParamByName('data_emissao').AsDate := Date;
      LQuery.ParamByName('valor_total').AsCurrency := APedido.ValorTotalItens;
      LQuery.ExecSQL;
      APedido.Id := FConn.ExecSQLScalar('SELECT LAST_INSERT_ID()');

      // inserir itens
      for LItem in APedido.Itens.Values do
      begin
        LQuery.Close;
        LQuery.SQL.Text := TPedidoItemSQL.Insert;
        LQuery.ParamByName('id_pedido').AsInteger := APedido.Id;
        LQuery.ParamByName('id_produto').AsInteger := LItem.Produto.id_produto;
        LQuery.ParamByName('quantidade').AsFloat := LItem.Quantidade;
        LQuery.ParamByName('valor_unitario').AsCurrency := LItem.ValorUnitario;
        LQuery.ExecSQL;
        LItem.Id := FConn.ExecSQLScalar('SELECT LAST_INSERT_ID()');
      end;

      FConn.Commit;
    except
      FConn.Rollback;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TPedidoRepository.Atualizar(APedido: TPedido);
var
  LQuery: TFDQuery;
  LItem: TPedidoItem;
begin
  LQuery := TFDQuery.Create(nil);
  try
    FConn.StartTransaction;
    try
      // atualizar o pedido, sempre obtendo somatório do valor dos itens:
      LQuery.Connection := FConn;
      LQuery.SQL.Text := TPedidoSQL.Update;
      LQuery.ParamByName('id').AsInteger := APedido.Id;
      LQuery.ParamByName('id_cliente').AsInteger := APedido.Cliente.id_cliente;
      LQuery.ParamByName('data_emissao').AsDate := APedido.DataEmissao;
      LQuery.ParamByName('valor_total').AsCurrency := APedido.ValorTotalItens;
      LQuery.ExecSQL;

      // excluir itens antigos
      LQuery.SQL.Text := TPedidoItemSQL.DeleteByPedidoId;
      LQuery.ParamByName('id_pedido').AsInteger := APedido.Id;
      LQuery.ExecSQL;

      // inserir itens atuais
      for LItem in APedido.Itens.Values do
      begin
        LQuery.SQL.Text := TPedidoItemSQL.Insert;
        LQuery.ParamByName('id_pedido').AsInteger := APedido.Id;
        LQuery.ParamByName('id_produto').AsInteger := LItem.Produto.id_produto;
        LQuery.ParamByName('quantidade').AsFloat := LItem.Quantidade;
        LQuery.ParamByName('valor_unitario').AsCurrency := LItem.ValorUnitario;
        LQuery.Open;
        LItem.Id := LQuery.FieldByName('id_pedido_item').AsInteger;
      end;

      FConn.Commit;
    except
      FConn.Rollback;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TPedidoRepository.Salvar(APedido: TPedido);
begin
  if APedido.Id = 0 then
    Inserir(APedido)
  else
    Atualizar(APedido);
end;

procedure TPedidoRepository.Excluir(APedido: TPedido);
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    FConn.StartTransaction;
    try
      // excluir os itens primeiro, devido FKs:
      LQuery.Connection := FConn;
      LQuery.SQL.Text := TPedidoItemSQL.DeleteByPedidoId;
      LQuery.ParamByName('id_pedido').AsInteger := APedido.Id;
      LQuery.ExecSQL;

      // excluir o pedido:
      LQuery.SQL.Text := TPedidoSQL.Delete;
      LQuery.ParamByName('id').AsInteger := APedido.Id;
      LQuery.ExecSQL;

      FConn.Commit;
    except
      FConn.Rollback;
      raise;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TPedidoRepository.SalvarDoDataSet(ACliente: TCliente; ADataSet: TDataSet);
var
  LPedido: TPedido;
  LProduto: TProduto;
  LItem: TPedidoItem;
begin
  if not Assigned(ACliente) then
    raise Exception.Create('Cliente inválido.');

  if ADataSet.IsEmpty then
    raise Exception.Create('O pedido deve possuir ao menos um item.');

  LPedido := TPedido.Create(ACliente);
  try
    ADataSet.First;
    while not ADataSet.Eof do
    begin
      LProduto := TProduto.Create;
      try
        // para salvar, precisamos somente do Id.
        LProduto.id_produto := ADataSet.FieldByName('id_produto').AsInteger;
        LItem := TPedidoItem.Create(
          LProduto,
          ADataSet.FieldByName('quantidade').AsFloat,
          ADataSet.FieldByName('valor_unitario').AsCurrency
        );
        LItem.Id := ADataSet.FieldByName('id_pedido_item').AsInteger;

        LPedido.AdicionarItem(LItem); // adiciona na lista
        ADataSet.Next;
      finally
        LProduto.Free;
      end;
    end;

    Salvar(LPedido); // persiste no banco de dados

  finally
    LPedido.Free;
  end;
end;


end.
