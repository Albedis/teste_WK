unit wk.sql.produto;

interface

type
  TProdutoSQL = class
  public
    class function SelectById: string;
    class function LoadAll: string;
  end;

implementation

uses
  System.SysUtils;

class function TProdutoSQL.SelectById: string;
begin
  Result := 'SELECT       ' +
            'id_produto,  ' +
            'descricao,   ' +
            'preco_venda  ' +
            'FROM produto ' +
            'WHERE id_produto = :id';
end;

class function TProdutoSQL.LoadAll: string;
begin
  Result := 'SELECT id_produto, descricao, preco_venda ' +
            'FROM produto ' +
            'ORDER BY descricao';
end;

end.

