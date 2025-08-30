unit wk.model.produto;

interface

type
TProduto = class (TObject)
  private
     Fid_produto: integer;
     Fdescricao: string;
     Fpreco_venda: currency;
  public
    property id_produto: integer read fid_produto write fid_produto;
    property descricao: string read fdescricao write fdescricao;
    property preco_venda: currency read fpreco_venda write fpreco_venda;

    procedure Clone(ASource: TProduto);
end;

implementation

procedure TProduto.Clone(ASource: TProduto);
begin
  with ASource do
  begin
    self.id_produto := id_produto;
    self.descricao := descricao;
    self.preco_venda := preco_venda;
  end;
end;

end.
