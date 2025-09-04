unit wk.service.pedido_validator;

interface

uses
  System.SysUtils,
  wk.model.pedido,
  wk.model.pedido_item,
  wk.service.pedido_item_validator;

type
  TPedidoValidator = class
  public
    class procedure Validate(const Pedido: TPedido);
  end;

implementation

{ TPedidoValidator }

class procedure TPedidoValidator.Validate(const Pedido: TPedido);
var
  Item: TPedidoItem;
begin
  if not Assigned(Pedido) then
    raise Exception.Create('Pedido não informado.');

  if not Assigned(Pedido.Cliente) then
    raise Exception.Create('Cliente do pedido não informado.');

  if Pedido.Itens.Count = 0 then
    raise Exception.Create('Pedido não possui itens.');

  for Item in Pedido.Itens.Values do
    TPedidoItemValidator.Validate(Item);
end;

end.

