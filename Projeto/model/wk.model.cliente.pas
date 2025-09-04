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
  if not Assigned(ASource) then Exit;
  id_cliente := ASource.id_cliente;
  nome := ASource.nome;
  cidade := ASource.cidade;
  uf := ASource.uf;
end;

end.
