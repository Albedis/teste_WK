unit wk.Controller.PedidoItem;

interface

uses
  Data.DB, wk.model.pedido_item, wk.model.produto;

type
  TCtrlPedidoItem = class(TObject)
    private
      FMensageInfo: string;
    public
      function calcularTotalPedido: Double;
      function DataSetToModel(ADataset: TDataSet): TPedidoItem;

      procedure alterarItemPedido(const APedidoItem: TPedidoItem; const ANomeProduto: string);
      procedure adicionarPedidoItem(const APedidoItem: TPedidoItem; const ANomeProduto: string);
      procedure excluirItemPedido(const AId_item_pedido: Integer);

      property MessageInfo: string read FMensageInfo;
  end;



implementation

uses
  wk.datamodule.consulta, System.Classes, System.SysUtils;

{ TCtrlPedidoItem }

function TCtrlPedidoItem.DataSetToModel(ADataset: TDataSet): TPedidoItem;
var
  LPedidoItem: TPedidoItem;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  LPedidoItem := TPedidoItem.Create;
  LPedidoItem.id_pedido_item := ADataset.FieldByName('id_pedido_item').AsInteger;
  LPedidoItem.id_pedido := ADataset.FieldByName('id_pedido').AsInteger;
  LPedidoItem.id_produto:= ADataset.FieldByName('id_produto').AsInteger;
  LPedidoItem.quantidade:= ADataset.FieldByName('quantidade').AsFloat;
  LPedidoItem.valor_unitario:= ADataset.FieldByName('valor_unitario').AsFloat;

  Result := LPedidoItem;

end;

procedure TCtrlPedidoItem.excluirItemPedido(const AId_item_pedido: Integer);
begin
  if not dmConsulta.cdsPedidoItem.Locate('id_pedido_item', AId_item_pedido, []) then
    raise Exception.Create('Erro interno: item não encontrado para exclusão!');
  dmConsulta.cdsPedidoItem.Delete;
end;

procedure TCtrlPedidoItem.adicionarPedidoItem(const APedidoItem: TPedidoItem;
  const ANomeProduto: string);
begin
  with dmconsulta.cdsPedidoItem do
  begin
    Append;
    FieldByName('id_pedido').AsInteger:= APedidoItem.id_pedido;
    FieldByName('id_pedido_item').AsInteger := RecordCount + 1;
    FieldByName('id_produto').AsFloat := APedidoItem.id_produto;
    FieldByName('quantidade').AsFloat := APedidoItem.quantidade;
    FieldByName('valor_unitario').AsFloat := APedidoItem.valor_unitario;
    FieldByName('valor_total').AsFloat := APedidoItem.valor_total;
    FieldByName('descricao').AsString := ANomeProduto;
    Post;
  end;
end;

procedure TCtrlPedidoItem.alterarItemPedido(const APedidoItem: TPedidoItem; const ANomeProduto: string);
begin
  FMensageInfo := '';
  if not dmConsulta.cdsPedidoItem.Locate('id_pedido_item', APedidoItem.id_pedido_item, []) then
    raise Exception.Create('Erro interno: item não encontrado para alteração!');

  with dmconsulta.cdsPedidoItem do
  begin
    Edit;
    FieldByName('id_produto').AsFloat := APedidoItem.id_produto;
    FieldByName('quantidade').AsFloat := APedidoItem.quantidade;
    FieldByName('valor_unitario').AsFloat := APedidoItem.valor_unitario;
    FieldByName('valor_total').AsFloat := APedidoItem.valor_total;
    FieldByName('descricao').AsString := ANomeProduto;
    Post;
  end;
end;

function TCtrlPedidoItem.calcularTotalPedido: Double;
var
  LTotal: Double;
begin
  LTotal := 0;
  dmConsulta.cdsPedidoItem.DisableControls;
  try
    dmConsulta.cdsPedidoItem.First;
    while not dmConsulta.cdsPedidoItem.Eof do
    begin
      LTotal := LTotal + dmConsulta.cdsPedidoItem.FieldByName('valor_total').AsFloat;
      dmConsulta.cdsPedidoItem.Next;
    end;
  finally
    dmConsulta.cdsPedidoItem.EnableControls;
  end;

  Result := LTotal;

end;

end.
