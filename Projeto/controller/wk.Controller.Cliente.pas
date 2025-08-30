unit wk.Controller.Cliente;

interface

uses
  wk.model.cliente, Data.DB;


type
  TCtrlCliente = class(TObject)
    private

    public
      function DataSetToModel(ADataset: TDataSet): TCliente;
      function Load(Afilter: string): TDataSet;
      function obterCliente(AIdCliente: Integer): TCliente;
  end;

implementation

uses
  wk.datamodule.consulta;

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

function TCtrlCliente.Load(Afilter: string): TDataSet;
begin
  Result:= dmconsulta.LoadClient(Afilter);
end;

function TCtrlCliente.obterCliente(AIdCliente: Integer): TCliente;
begin
  Result := nil;
  dmConsulta.obterCliente(AIdCliente);
  if not dmConsulta.qryCliente.IsEmpty then
    Result := DataSetToModel(dmConsulta.qryCliente);
end;

end.
