unit wk.sql.pedido_item;

interface

type
  TPedidoItemSQL = class
  public
    class function SelectByPedidoId: string; static;
    class function Insert: string; static;   static;
    class function DeleteByPedidoId: string; static;
  end;

implementation

class function TPedidoItemSQL.SelectByPedidoId: string;
begin
  Result :=
    'SELECT                             ' +
    'i.id_pedido_item,                  ' +
    'i.id_pedido,                       ' +
    'i.id_produto,                      ' +
    'pr.descricao,                      ' +
    'pr.preco_venda,                    ' +
    'i.quantidade,                      ' +
    'i.valor_unitario                   ' +
    'FROM pedido_item i                 ' +
    'INNER JOIN produto pr ON pr.id_produto = i.id_produto ' +
    'WHERE i.id_pedido = :id_pedido                        ' +
    'order by i.id_pedido_item';

end;

class function TPedidoItemSQL.Insert: string;
begin
  Result :=
    'INSERT INTO pedido_item (id_pedido, id_produto, quantidade, valor_unitario) ' +
    'VALUES (:id_pedido, :id_produto, :quantidade, :valor_unitario)';
  // nota: campo valor_total eh STORED GENERATED
end;

class function TPedidoItemSQL.DeleteByPedidoId: string;
begin
  Result :=
    'DELETE FROM pedido_item ' +
    'WHERE id_pedido = :id_pedido';
end;


end.

