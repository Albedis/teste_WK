unit wk.sql.cliente;

interface

type
  TClienteSQL = class
  public
    class function SelectById: string; static;
    class function LoadAll: string; static;
  end;

implementation

class function TClienteSQL.SelectById: string;
begin
  Result := 'SELECT id_cliente, nome as nome_cliente, ' +
            ' cidade, uf ' +
            ' FROM cliente ' +
            ' WHERE id_cliente = :id';
end;

class function TClienteSQL.LoadAll: string;
begin
  Result := 'SELECT '       +
            ' id_cliente, ' +
            ' nome as nome_cliente, ' +
            ' cidade, ' +
            ' uf '      +
            ' FROM cliente ' +
            ' ORDER BY nome';
end;

end.

