unit wk.DTO.PedidoItem;

interface

type
  TPedidoItemDTO = record
    IdItem: Integer;
    IdProduto: Integer;
    DescricaoProduto: string;
    Quantidade: Double;
    ValorUnitario: Currency;
    ValorTotal: Currency;
end;

implementation

end.
