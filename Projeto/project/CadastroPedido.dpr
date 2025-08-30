program CadastroPedido;

uses
  Vcl.Forms,
  wk.model.cliente in '..\model\wk.model.cliente.pas',
  wk.model.produto in '..\model\wk.model.produto.pas',
  wk.model.pedido in '..\model\wk.model.pedido.pas',
  wk.model.pedido_item in '..\model\wk.model.pedido_item.pas',
  wk.connection.conn in '..\dataset\wk.connection.conn.pas' {dmConn: TDataModule},
  wk.connection.config in '..\dataset\wk.connection.config.pas',
  wk.view.frmCadastrarPedido in '..\view\wk.view.frmCadastrarPedido.pas' {frmCadastrarPedido},
  wk.datamodule.consulta in '..\dataset\wk.datamodule.consulta.pas' {dmConsulta: TDataModule},
  wk.view.consultarCliente in '..\view\wk.view.consultarCliente.pas' {frmConsultarCliente},
  wk.Controller.Cliente in '..\controller\wk.Controller.Cliente.pas',
  wk.facade.pedido in '..\facade\wk.facade.pedido.pas',
  wk.view.consultarProduto in '..\view\wk.view.consultarProduto.pas' {frmConsultarProduto},
  wk.Controller.Produto in '..\controller\wk.Controller.Produto.pas',
  wk.Controller.Pedido in '..\controller\wk.Controller.Pedido.pas',
  wk.Controller.PedidoItem in '..\controller\wk.Controller.PedidoItem.pas',
  wk.Service.PedidoUpdater in '..\service\wk.Service.PedidoUpdater.pas',
  wk.view.consultarPedido in '..\view\wk.view.consultarPedido.pas' {frmConsultarPedido};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Cadastro de Pedido';
  Application.CreateForm(TdmConn, dmConn);
  Application.CreateForm(TdmConsulta, dmConsulta);
  Application.CreateForm(TfrmCadastrarPedido, frmCadastrarPedido);
  Application.CreateForm(TfrmConsultarPedido, frmConsultarPedido);
  Application.Run;
end.
