unit wk.service.pedido_service;

interface

uses
  System.SysUtils,
  wk.model.pedido,
  wk.model.pedido_item,
  wk.service.pedido_item_validator;

type
  TPedidoService = class
  public
    class procedure AdicionarItem(APedido: TPedido; AItem: TPedidoItem);
    class procedure RemoverItem(APedido: TPedido; AIdItem: Integer);
    class procedure AlterarQuantidade(AItem: TPedidoItem; ANovaQtd: Double);
    class procedure AlterarValorUnitario(AItem: TPedidoItem; ANovoValor: Currency);

    class procedure ValidarPedido(APedido: TPedido);
  end;

implementation

uses
  wk.service.pedido_validator;

{ TPedidoService }

class procedure TPedidoService.AdicionarItem(APedido: TPedido; AItem: TPedidoItem);
begin
  if not Assigned(APedido) then
    raise Exception.Create('Pedido não informado.');

  if not Assigned(AItem) then
    raise Exception.Create('Item do pedido não foi não informado.');

  TPedidoItemValidator.Validate(AItem);
  APedido.AdicionarItem(AItem);

end;

class procedure TPedidoService.RemoverItem(APedido: TPedido; AIdItem: Integer);
begin
  if not Assigned(APedido) then
    raise Exception.Create('Pedido não informado.');
  APedido.RemoverItem(AIdItem);
end;

class procedure TPedidoService.AlterarQuantidade(AItem: TPedidoItem; ANovaQtd: Double);
begin
  TPedidoItemValidator.ValidarQuantidade(ANovaQtd);
  AItem.Quantidade := ANovaQtd;
end;

class procedure TPedidoService.AlterarValorUnitario(AItem: TPedidoItem; ANovoValor: Currency);
begin
  TPedidoItemValidator.ValidarValorUnitario(ANovoValor);
  AItem.ValorUnitario := ANovoValor;
end;

class procedure TPedidoService.ValidarPedido(APedido: TPedido);
begin
   TPedidoValidator.Validate(APedido);
end;

end.

