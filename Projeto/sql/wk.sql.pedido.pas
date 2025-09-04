unit wk.sql.pedido;

interface

type
  TPedidoSQL = class
  private
     //
  public
    class function SelectById: string; static;
    class function Insert: string; static;
    class function Update: string; static;
    class function Delete: string; static;
    class function LoadAll: string; static;
  end;

implementation

class function TPedidoSQL.SelectById: string;
begin
  Result :=
    'SELECT                         ' +
    'p.id_pedido,                   ' +
    'p.id_cliente,                  ' +
    'c.nome       AS nome_cliente,  ' +
    'c.cidade     AS cidade,        ' +
    'c.uf         AS uf,            ' +
    'p.data_emissao,                ' +
    'p.valor_total                  ' +
    'FROM pedido p                  ' +
    'INNER JOIN cliente c ON c.id_cliente = p.id_cliente  ' +
    'WHERE p.id_pedido = :id                              ' ;
end;

class function TPedidoSQL.Insert: string;
begin
  Result :=
    'INSERT INTO pedido (id_cliente, data_emissao, valor_total) ' +
    'VALUES (:id_cliente, :data_emissao, :valor_total)';
end;

class function TPedidoSQL.LoadAll: string;
begin
  Result :=
    'SELECT                         ' +
    'p.id_pedido,                   ' +
    'p.id_cliente,                  ' +
    'c.nome       AS nome_cliente,  ' +
    'c.cidade     AS cidade,        ' +
    'c.uf         AS uf,            ' +
    'p.data_emissao,                ' +
    'p.valor_total                  ' +
    'FROM pedido p                  ' +
    'INNER JOIN cliente c ON c.id_cliente = p.id_cliente  ' +
    'Order by p.data_emissao, p.id_pedido';

end;

class function TPedidoSQL.Update: string;
begin
  Result :=
    'UPDATE pedido SET ' +
    '  id_cliente   = :id_cliente, ' +
    '  data_emissao = :data_emissao, ' +
    '  valor_total  = :valor_total ' +
    'WHERE id_pedido = :id';
end;

class function TPedidoSQL.Delete: string;
begin
  Result :=
    'DELETE FROM pedido ' +
    'WHERE id_pedido = :id';
end;



end.

