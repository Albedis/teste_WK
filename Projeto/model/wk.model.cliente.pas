unit wk.model.cliente;

interface

type
TCliente = class(TObject)
private
  Fid_cliente: integer;
  Fnome: string;
  Fcidade: string;
  Fuf: string;
public
  property id_cliente: integer read Fid_cliente write Fid_cliente;
  property nome: string read Fnome write Fnome;
  property cidade: string read Fcidade write Fcidade;
  property uf: string read fuf write fuf;

  procedure Clone(ASource: TCliente);
end;

implementation

{ TCliente }

procedure TCliente.Clone(ASource: TCliente);
begin
  with ASource do
  begin
    self.id_cliente := id_cliente;
    self.nome := nome;
    self.cidade := cidade;
    self.uf := uf;
  end;
end;

end.
