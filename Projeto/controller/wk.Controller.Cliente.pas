unit wk.Controller.Cliente;

interface

uses
  wk.model.cliente, Data.DB;


type
  TCtrlCliente = class(TObject)
    public
      function DataSetToModel(ADataset: TDataSet): TCliente;
  end;

implementation


{ TCtrlCliente }

function TCtrlCliente.DataSetToModel(ADataset: TDataSet): TCliente;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  Result := TCliente.Create;
  Result.id_cliente := ADataset.FieldByName('id_cliente').AsInteger;
  Result.nome := ADataset.FieldByName('nome').AsString;
  Result.cidade := ADataset.FieldByName('cidade').AsString;
  Result.uf := ADataset.FieldByName('uf').AsString;
end;

end.
