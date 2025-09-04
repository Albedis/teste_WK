program CadastroPedido;

uses
  Vcl.Forms,
  FireDAC.DApt,
  wk.model.cliente in '..\model\wk.model.cliente.pas',
  wk.model.produto in '..\model\wk.model.produto.pas',
  wk.model.pedido in '..\model\wk.model.pedido.pas',
  wk.model.pedido_item in '..\model\wk.model.pedido_item.pas',
  wk.view.PedidoVenda in '..\view\wk.view.PedidoVenda.pas' {frmPedidoVenda},
  wk.view.consultarCliente in '..\view\wk.view.consultarCliente.pas' {frmConsultarCliente},
  wk.Controller.Cliente in '..\controller\wk.Controller.Cliente.pas',
  wk.view.consultarProduto in '..\view\wk.view.consultarProduto.pas' {frmConsultarProduto},
  wk.Controller.Produto in '..\controller\wk.Controller.Produto.pas',
  wk.view.consultarPedido in '..\view\wk.view.consultarPedido.pas' {frmConsultarPedido},
  wk.service.pedido_item_validator in '..\service\wk.service.pedido_item_validator.pas',
  wk.service.pedido_service in '..\service\wk.service.pedido_service.pas',
  wk.service.pedido_validator in '..\service\wk.service.pedido_validator.pas',
  wk.sql.produto in '..\sql\wk.sql.produto.pas',
  wk.sql.cliente in '..\sql\wk.sql.cliente.pas',
  wk.repository.produto in '..\repository\wk.repository.produto.pas',
  wk.repository.cliente in '..\repository\wk.repository.cliente.pas',
  wk.repository.pedido in '..\repository\wk.repository.pedido.pas',
  wk.sql.pedido in '..\sql\wk.sql.pedido.pas',
  wk.sql.pedido_item in '..\sql\wk.sql.pedido_item.pas',
  wk.factory.model in '..\model\wk.factory.model.pas',
  wk.connection.config in '..\datamodule\wk.connection.config.pas',
  wk.connection.conn in '..\datamodule\wk.connection.conn.pas' {dmConn: TDataModule},
  wk.dm.PedidoVenda in '..\datamodule\wk.dm.PedidoVenda.pas' {dmPedido: TDataModule},
  wk.facade.PedidoVenda in '..\facade\wk.facade.PedidoVenda.pas',
  wk.controller.pedido_venda in '..\controller\wk.controller.pedido_venda.pas',
  wk.DTO.PedidoItem in '..\dto\wk.DTO.PedidoItem.pas',
  wk.facade.Consultas in '..\facade\wk.facade.Consultas.pas',
  wk.repository.Consultas in '..\repository\wk.repository.Consultas.pas',
  wk.application.initializer in '..\application\wk.application.initializer.pas';

{$R *.res}

begin
  TAppInitializer.Run;
end.
