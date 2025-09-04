unit wk.model.produto;

interface

type
TProduto = class (TObject)
  private
    Fid_produto: integer;
    Fdescricao: string;
    Fpreco_venda: currency;

    procedure SetId(const Value: Integer);

  public
    property id_produto: integer read fid_produto write fid_produto;
    property descricao: string read fdescricao write fdescricao;
    property preco_venda: currency read fpreco_venda write fpreco_venda;

    procedure Clone(ASource: TProduto);
end;

implementation

procedure TProduto.Clone(ASource: TProduto);
begin
  if not Assigned(ASource) then Exit;

  SetId(ASource.id_produto);
  descricao := ASource.descricao;
  preco_venda := ASource.preco_venda;
end;

procedure TProduto.SetId(const Value: Integer);
begin
  Fid_produto := Value;
end;

end.
