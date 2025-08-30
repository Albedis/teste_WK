unit wk.Controller.Pedido;

interface

uses
  wk.model.pedido, wk.model.pedido_item, wk.model.cliente, wk.model.produto,
  wk.Controller.PedidoItem, Data.DB, Datasnap.DBClient;

type
TCtrlPedido = class(TObject)
  private
    FMessageInfo: string;
    FNomeProduto: string;
    FPedido: TPedido;
    FPedidoItem: TPedidoItem;

    FCtrlPedidoItem: TCtrlPedidoItem;

    procedure adicionarPedido;
    procedure adicionarItem;
    procedure atualizarValorTotalPedido;
    procedure validarInclusaoProduto;
    procedure CopiarDadosParaClientDataSet(AFonte: TDataSet; ADestino: TClientDataSet);

  public
    constructor Create(ACliente: TCliente;
      AProduto: TProduto; AQuantidade: Double); overload;
    constructor Create; overload;
    destructor Destroy; override;

    function DataSetToModel(ADataset: TDataSet): TPedido;
    function Load(Afilter: string): TDataSet;

    procedure adicionarItemPedido;
    procedure carregarPedido(AIdPedido: Integer);
    procedure excluirPedido(AIdPedido: Integer);

    property MessageInfo: string read FMessageInfo;

end;

implementation

uses
  System.SysUtils, wk.datamodule.consulta, System.Generics.Collections,
  wk.Service.PedidoUpdater;

{ TCtrlPedido }

constructor TCtrlPedido.Create(ACliente: TCliente; AProduto: TProduto; AQuantidade: Double);
begin
  FPedido := nil;
  FPedidoItem := nil;

  if not (Assigned(ACliente) or Assigned(AProduto)) then
    raise Exception.Create('Erro interno: classes não instanciadas!');

  FPedido := TPedido.Create;
  FPedidoItem := TPedidoItem.Create;
  FCtrlPedidoItem := TCtrlPedidoItem.Create;

  FNomeProduto := AProduto.descricao;

  try
    FPedido.id_cliente := ACliente.id_cliente;
    FPedidoItem.id_produto := AProduto.id_produto;
    FPedidoItem.quantidade := AQuantidade;
    FPedidoItem.valor_unitario := AProduto.preco_venda;
  except
    raise;
  end;
end;

function TCtrlPedido.DataSetToModel(ADataset: TDataSet): TPedido;
var
  LPedido: TPedido;
begin
  if not Assigned(ADataSet) or ADataSet.IsEmpty then
    Exit(nil);

  LPedido := TPedido.Create;
  LPedido.id_pedido := ADataset.FieldByName('id_pedido').AsInteger;
  LPedido.data_emissao := ADataset.FieldByName('data_emissao').AsDateTime;
  LPedido.id_cliente := ADataset.FieldByName('id_cliente').AsInteger;
  LPedido.valor_total := ADataset.FieldByName('valor_total').AsFloat;

  Result := LPedido;

end;

destructor TCtrlPedido.Destroy;
begin
  if assigned(FPedido) then
    FPedido.Free;

  if assigned(FPedidoItem) then
    FPedidoItem.Free;

  if assigned(FCtrlPedidoItem) then
    FCtrlPedidoItem.Free;

  inherited;
end;

procedure TCtrlPedido.excluirPedido(AIdPedido: Integer);
begin
  dmConsulta.excluirPedido(AIdPedido);
end;

procedure TCtrlPedido.validarInclusaoProduto;
begin
  if not(FPedido.id_cliente > 0) then
    FMessageInfo := 'Informe um cliente para o pedido'
  else
    FMessageInfo := FPedidoItem.validate;
end;

procedure TCtrlPedido.adicionarItemPedido;
begin
  FMessageInfo := '';
  try
    validarInclusaoProduto;
    if not FMessageInfo.IsEmpty then
      raise Exception.Create(FMessageInfo);

    adicionarPedido;
    adicionarItem;
    atualizarValorTotalPedido;

  except
    on E:Exception do
    begin
      if FMessageInfo.IsEmpty then
        FMessageinfo := 'Ocorreu um erro ao adicionar o produto, tente novamente.';
      raise;
    end;
  end;
end;

procedure TCtrlPedido.atualizarValorTotalPedido;
var
  LService: TServicePedidoUpdater;
begin
  LService := TServicePedidoUpdater.Create(FCtrlPedidoItem);
  try
    LService.atualizarValorPedido;
  finally
    LService.Free;
  end;
end;

procedure TCtrlPedido.carregarPedido(AIdPedido: Integer);
begin
  dmConsulta.obterPedidoConsulta(AIdPedido);
  dmConsulta.novoPedido;
  CopiarDadosParaClientDataSet(dmConsulta.qryPedido, dmconsulta.cdsPedido);
  CopiarDadosParaClientDataSet(dmConsulta.qryPedidoItem, dmconsulta.cdsPedidoItem);
end;

procedure TCtrlPedido.CopiarDadosParaClientDataSet(AFonte: TDataSet; ADestino: TClientDataSet);
var
  i: Integer;
begin
  ADestino.DisableControls;
  try
    AFonte.First;
    while not AFonte.Eof do
    begin
      ADestino.Append;
      for i := 0 to AFonte.FieldCount - 1 do
      begin
        if ADestino.FindField(AFonte.Fields[i].FieldName) <> nil then
          ADestino.FieldByName(AFonte.Fields[i].FieldName).Value := AFonte.Fields[i].Value;
      end;
      ADestino.Post;
      AFonte.Next;
    end;
  finally
    ADestino.EnableControls;
  end;
end;

constructor TCtrlPedido.Create;
begin
  inherited;
  FPedido := nil;
  FPedidoItem := nil;
  FCtrlPedidoItem := nil;
end;

procedure TCtrlPedido.adicionarItem;
begin
  FPedidoItem.id_pedido := dmConsulta.cdsPedido.FieldByName('id_pedido').AsInteger;
  FCtrlPedidoItem.adicionarPedidoItem(FPedidoItem, FNomeProduto);
end;

procedure TCtrlPedido.adicionarPedido;
begin
  with dmConsulta.cdsPedido do
  begin
    if IsEmpty then
    begin
      Insert;
      FieldByName('id_pedido').AsInteger := -1;
      FieldByName('data_emissao').AsDateTime := now();
      FieldByName('id_cliente').AsInteger := FPedido.id_cliente;
      FieldByName('valor_total').AsInteger := 0;
      Post;
      Exit;
    end;

    if FieldByName('id_cliente').AsInteger <> FPedido.id_cliente then
    begin
      Edit;
      FieldByName('id_cliente').AsInteger := FPedido.id_cliente;
      Post;
    end;
  end;
end;

function TCtrlPedido.Load(Afilter: string): TDataSet;
begin
  Result:= dmconsulta.LoadPedido(Afilter);
end;

end.
