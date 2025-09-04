unit wk.factory.model;

interface

uses
  Data.DB,
  wk.model.cliente,
  wk.model.produto,
  wk.model.pedido,
  wk.model.pedido_item;

type
  TModelFactory = class
  public
    class function ClienteFromDataset(ADataSet: TDataSet): TCliente;
    class function ProdutoFromDataset(ADataSet: TDataSet): TProduto;
    class function PedidoFromDataset(ADataSet: TDataSet; ACliente: TCliente): TPedido;
    class function PedidoItemFromDataset(ADataSet: TDataSet; AProduto: TProduto): TPedidoItem;
  end;

implementation

uses
  System.SysUtils;

{ TModelFactory }

class function TModelFactory.ClienteFromDataset(ADataSet: TDataSet): TCliente;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  Result := TCliente.Create;
  try
    Result.id_cliente := ADataSet.FieldByName('id_cliente').AsInteger;
    Result.nome := ADataSet.FieldByName('nome_cliente').AsString;
    Result.cidade := ADataSet.FieldByName('cidade').AsString;
    Result.uf := ADataSet.FieldByName('uf').AsString;
  except
    Result.Free;
    raise;
  end;
end;

class function TModelFactory.ProdutoFromDataset(ADataSet: TDataSet): TProduto;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  Result := TProduto.Create;
  try
    Result.id_produto  := ADataSet.FieldByName('id_produto').AsInteger;
    Result.descricao   := ADataSet.FieldByName('descricao').AsString;
    Result.preco_venda := ADataSet.FieldByName('preco_venda').AsCurrency;
  except
    Result.Free;
    raise;
  end;
end;

class function TModelFactory.PedidoFromDataset(ADataSet: TDataSet;
  ACliente: TCliente): TPedido;
begin
  Result := nil;

  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit;

  Result := TPedido.Create;
  if Assigned(ACliente) then
    Result.AlterarCliente(ACliente);
  try
    Result.Id := ADataSet.FieldByName('id_pedido').AsInteger;
    Result.DataEmissao := ADataSet.FieldByName('data_emissao').AsDateTime;
    Result.ValorTotal := ADataSet.FieldByName('valor_total').AsCurrency;
  except
    Result.Free;
    raise;
  end;
end;

class function TModelFactory.PedidoItemFromDataset(ADataSet: TDataSet;
  AProduto: TProduto): TPedidoItem;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  Result := TPedidoItem.Create(AProduto,
                               ADataSet.FieldByName('quantidade').AsFloat,
                               ADataSet.FieldByName('valor_unitario').AsCurrency
                              );
  Result.Id := ADataSet.FieldByName('id_pedido_item').AsInteger;
end;

end.

