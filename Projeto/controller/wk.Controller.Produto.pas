unit wk.Controller.Produto;

interface

uses
  wk.model.produto, Data.DB;


type
  TCtrlProduto = class(TObject)
    private

    public
      function DataSetToModel(ADataset: TDataSet): TProduto;
      function Load(Afilter: string): TDataSet;
  end;

implementation

uses
  wk.datamodule.consulta;

{ TCtrlCliente }

function TCtrlProduto.DataSetToModel(ADataset: TDataSet): TProduto;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  Result := TProduto.Create;
  Result.id_produto := ADataset.FieldByName('id_produto').AsInteger;
  Result.descricao := ADataset.FieldByName('descricao').AsString;
  Result.preco_venda := ADataset.FieldByName('preco_venda').AsFloat;
end;

function TCtrlProduto.Load(Afilter: string): TDataSet;
begin
  Result:= dmconsulta.LoadProduto(Afilter);
end;

end.

