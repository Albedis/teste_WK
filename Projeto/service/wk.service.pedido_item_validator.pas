unit wk.service.pedido_item_validator;

interface

uses
  System.SysUtils,
  wk.model.pedido_item;

type
  TPedidoItemValidator = class
  public
    class procedure Validate(const Item: TPedidoItem);
    class procedure ValidarQuantidade(AQuantidade: Double);
    class procedure ValidarValorUnitario(AValor: Currency);
  end;

implementation

{ TPedidoItemValidator }

class procedure TPedidoItemValidator.Validate(const Item: TPedidoItem);
begin
  if Item.Produto = nil then
    raise Exception.Create('Informe o produto.');
end;

class procedure TPedidoItemValidator.ValidarQuantidade(AQuantidade: Double);
begin
  if AQuantidade <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero.');

  if AQuantidade > 9999 then
    raise Exception.Create('Quantidade deve ser menor ou igual a 9.999.');
end;

class procedure TPedidoItemValidator.ValidarValorUnitario(AValor: Currency);
begin
  if AValor <= 0 then
    raise Exception.Create('Valor unitário deve ser maior que zero.');
end;


end.

