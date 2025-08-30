unit wk.Service.PedidoUpdater;

interface

uses
  wk.Controller.PedidoItem;

Type
TServicePedidoUpdater = class(TObject)
  private
    FCtrlPedidoItem: TCtrlPedidoItem;
    procedure novoPedido;
    procedure atualizarPedido(const AIdPedido: Integer);
  public
    constructor Create(ACtrlPedidoItem: TCtrlPedidoItem);
    procedure excluirItemPedido(const AIdPedidoItem: Integer);
    procedure atualizarValorPedido;
    procedure gravarPedido;
end;

implementation

uses
  System.SysUtils, wk.datamodule.consulta, wk.connection.conn,
  FireDAC.Comp.Client;

{ TServicePedidoUpdater }

procedure TServicePedidoUpdater.atualizarValorPedido;
var
  LValorItens: Double;
begin
  LValorItens := FCtrlPedidoItem.calcularTotalPedido;
  dmConsulta.cdsPedido.Edit;
  dmConsulta.cdsPedido.FieldByName('valor_total').AsFloat := LValorItens;
  dmConsulta.cdsPedido.Post;
end;

constructor TServicePedidoUpdater.Create(ACtrlPedidoItem: TCtrlPedidoItem);
begin
  if not Assigned(ACtrlPedidoItem) then
    raise Exception.Create('Erro interno: classe não foi instanciada!');

  FCtrlPedidoItem := ACtrlPedidoItem;
end;

procedure TServicePedidoUpdater.excluirItemPedido(const AIdPedidoItem: Integer);
begin
  FCtrlPedidoItem.excluirItemPedido(AIdPedidoItem);
  AtualizarValorPedido;
end;

procedure TServicePedidoUpdater.gravarPedido;
var
  LIdPedido: Integer;
begin
  if dmConsulta.cdsPedidoItem.IsEmpty then
    raise Exception.Create('O pedido precisa possuir um ou mais item, não é possível gravar!');

  dmConn.FDConn.StartTransaction;
  try
    LIdPedido := dmConsulta.cdsPedido.FieldByName('id_pedido').AsInteger;

    if LIdPedido = -1 then
      novoPedido
    else
      atualizarPedido(LIdPedido);

    dmConn.FDConn.Commit;
  except
    dmConn.FDConn.Rollback;
    raise;
  end;
end;

procedure TServicePedidoUpdater.novoPedido;
var
  LIdPedido: Integer;
begin
  dmConsulta.obterPedido();
  with dmConsulta do
  begin
    qryPedido.Insert;
    qryPedido.FieldByName('data_emissao').AsDateTime := cdsPedido.FieldByName('data_emissao').AsDateTime;
    qryPedido.FieldByName('id_cliente').AsInteger := cdsPedido.FieldByName('id_cliente').AsInteger;
    qryPedido.FieldByName('valor_total').AsFloat := cdsPedido.FieldByName('valor_total').AsFloat;
    qryPedido.Post;

    LIdPedido := qryPedido.FieldByName('id_pedido').AsInteger;

    cdsPedidoItem.DisableControls;
    try
      cdsPedidoItem.First;
      while not cdsPedidoItem.Eof do
      begin
        qryPedidoItem.Insert;
        qryPedidoItem.FieldByName('id_pedido').AsInteger := LIdPedido;
        qryPedidoItem.FieldByName('id_produto').AsInteger := cdsPedidoItem.FieldByName('id_produto').AsInteger;
        qryPedidoItem.FieldByName('quantidade').AsFloat := cdsPedidoItem.FieldByName('quantidade').AsFloat;
        qryPedidoItem.FieldByName('valor_unitario').AsFloat := cdsPedidoItem.FieldByName('valor_unitario').AsFloat;
        // qryPedidoItem.FieldByName('valor_total').AsFloat // este campo eh calculado no banco de dados;
        qryPedidoItem.Post;
        cdsPedidoItem.Next;
      end;
    finally
      cdsPedidoItem.EnableControls;
    end;
  end;
end;

procedure TServicePedidoUpdater.atualizarPedido(const AIdPedido: Integer);
begin
  dmconsulta.excluirItemPedido(AIdPedido);
  dmConsulta.obterPedido(AIdPedido);

  if dmConsulta.qryPedido.IsEmpty then
    raise Exception.Create('Error interno: pedido não foi encontrado!');

  with dmConsulta do
  begin
    qryPedido.Edit;
    qryPedido.FieldByName('data_emissao').AsDateTime := cdsPedido.FieldByName('data_emissao').AsDateTime;
    qryPedido.FieldByName('id_cliente').AsInteger := cdsPedido.FieldByName('id_cliente').AsInteger;
    qryPedido.FieldByName('valor_total').AsFloat := cdsPedido.FieldByName('valor_total').AsFloat;
    qryPedido.Post;

    cdsPedidoItem.DisableControls;
    try
      cdsPedidoItem.First;
      while not cdsPedidoItem.Eof do
      begin
        qryPedidoItem.Insert;
        qryPedidoItem.FieldByName('id_pedido').AsInteger := AIdPedido;
        qryPedidoItem.FieldByName('id_produto').AsInteger := cdsPedido.FieldByName('id_produto').AsInteger;
        qryPedidoItem.FieldByName('quantidade').AsFloat := cdsPedido.FieldByName('quantidade').AsFloat;
        qryPedidoItem.FieldByName('valor_unitario').AsFloat := cdsPedido.FieldByName('valor_unitario').AsFloat;
        // qryPedidoItem.FieldByName('valor_total').AsFloat // este campo eh calculado no banco de dados;
        qryPedidoItem.Post;
        cdsPedidoItem.Next;
      end;
    finally
      cdsPedidoItem.EnableControls;
    end;
  end;
end;


end.
