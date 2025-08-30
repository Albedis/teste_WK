unit wk.model.pedido;

interface

type
TPedido = class(TObject)
  private
    Fid_pedido: integer;
    Fdata_emissao: TDate;
    Fid_cliente: integer;
    Fvalor_total: currency;
  public
    property id_pedido: integer read Fid_pedido write Fid_pedido;
    property data_emissao: TDate read fdata_emissao write fdata_emissao;
    property id_cliente: integer read fid_cliente write fid_cliente;
    property valor_total: currency read Fvalor_Total write fvalor_total;
end;

implementation

end.
