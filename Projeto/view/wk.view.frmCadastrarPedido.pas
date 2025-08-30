unit wk.view.frmCadastrarPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, System.ImageList, Vcl.ImgList,
  Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.NumberBox,
  wk.model.cliente, wk.model.produto, wk.model.pedido;

type
  TfrmCadastrarPedido = class(TForm)
    edtNomeCliente: TEdit;
    imgList: TImageList;
    sbtnPesquisarCliente: TSpeedButton;
    lblNomeCliente: TLabel;
    pnlTitle: TPanel;
    lblTitle: TLabel;
    pnlTop: TPanel;
    pnlbody: TPanel;
    pnlbottom: TPanel;
    Shape2: TShape;
    Label1: TLabel;
    edtNomeProduto: TEdit;
    sbtnPesquisarProduto: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    nbxPrecoVenda: TNumberBox;
    nbxQuantidade: TNumberBox;
    sbtnAdicionar: TSpeedButton;
    pnlLista: TPanel;
    dbgPedidoItem: TDBGrid;
    nbxValorTotal: TNumberBox;
    Label4: TLabel;
    dsPedidoItem: TDataSource;
    pnlValue: TPanel;
    lblValorTotal: TLabel;
    Label5: TLabel;
    pnlButtons: TPanel;
    sbtnGravarPedido: TSpeedButton;
    sbtnConsultar: TSpeedButton;
    sbtnExcluir: TSpeedButton;
    sbtnDesistirAlteracao: TSpeedButton;
    edtCodCliente: TEdit;
    Label6: TLabel;
    edtNumPedido: TEdit;
    Label7: TLabel;
    edtDataEmissao: TEdit;
    sbtnCancelar: TSpeedButton;
    procedure sbtnPesquisarClienteClick(Sender: TObject);
    procedure nbxQuantidadeExit(Sender: TObject);
    procedure nbxPrecoVendaExit(Sender: TObject);
    procedure sbtnPesquisarProdutoClick(Sender: TObject);
    procedure sbtnAdicionarClick(Sender: TObject);
    procedure dbgPedidoItemKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure sbtnGravarPedidoClick(Sender: TObject);
    procedure sbtnConsultarClick(Sender: TObject);
    procedure sbtnExcluirClick(Sender: TObject);
    procedure sbtnDesistirAlteracaoClick(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
  private
    FCliente: TCliente;
    FProduto: TProduto;

    procedure adicionarItemPedido;
    procedure alterarItemPedido;
    procedure consultarPedido;
    procedure carregarPedido(AIdPedido: Integer);
    procedure editarItemPedido;
    procedure gravarPedido;
    procedure excluirPedido;
    procedure excluirPedidoItem;
    procedure limparCampos;
    procedure pesquisarCliente;
    procedure pesquisarProduto;
    procedure calcularValorTotalProduto;
    procedure atualizarSelecaoCliente(ACliente: TCliente);
    procedure atualizarSelecaoProduto(AProduto: TProduto; const AQuantidade: double);
    procedure atualizarBotaoAdicionarItem(const IsUpdate: Boolean);
    procedure atualizarValorTotalPedido;
    procedure exibirMensagem(const AMensagem: string);
    procedure incluirItemPedido;
    procedure novoPedido;

    function podeAlterarCliente: boolean;
    function validarItemPedido: string;

  end;

var
  frmCadastrarPedido: TfrmCadastrarPedido;

implementation

uses
  wk.datamodule.consulta,
  wk.view.consultarCliente,
  wk.view.consultarProduto,
  wk.facade.pedido,
  wk.model.pedido_item,
  wk.view.consultarPedido;

{$R *.dfm}

procedure TfrmCadastrarPedido.sbtnAdicionarClick(Sender: TObject);
begin
  adicionarItemPedido;
end;

procedure TfrmCadastrarPedido.sbtnDesistirAlteracaoClick(Sender: TObject);
begin
  limparCampos;
  AtualizarBotaoAdicionarItem(False);
end;

procedure TfrmCadastrarPedido.sbtnCancelarClick(Sender: TObject);
var
  LMessage: string;
begin
  LMessage := 'As alterações não gravadas serão perdidas!' + sLineBreak +
          'Confirma cancelar?';
  if MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    NovoPedido;
end;

procedure TfrmCadastrarPedido.sbtnConsultarClick(Sender: TObject);
begin
  consultarPedido;
end;

procedure TfrmCadastrarPedido.sbtnExcluirClick(Sender: TObject);
begin
  excluirPedido;
end;

procedure TfrmCadastrarPedido.sbtnGravarPedidoClick(Sender: TObject);
begin
  gravarPedido;
end;

procedure TfrmCadastrarPedido.sbtnPesquisarClienteClick(Sender: TObject);
begin
  if podeAlterarCliente then
    pesquisarCliente;
end;

procedure TfrmCadastrarPedido.sbtnPesquisarProdutoClick(Sender: TObject);
begin
  pesquisarProduto;
end;

procedure TfrmCadastrarPedido.adicionarItemPedido;
var
  LMessage: string;
  LValorPedido: Double;
begin
  LMessage := validarItemPedido;
  if LMessage <> '' then
  begin
    ShowMessage(LMessage);
    Exit;
  end;

  try
    if sbtnAdicionar.Tag = 0 then
      incluirItemPedido
    else
      alterarItemPedido;

    atualizarValorTotalPedido;
    limparCampos;
    AtualizarBotaoAdicionarItem(false);

    if Assigned(FProduto) then
      FreeAndNil(FProduto);

  except
    on E: Exception do
      ShowMessage('Ocorreu um erro ao adicionar o item: ' + E.Message);
  end;
end;

function TfrmCadastrarPedido.validarItemPedido: string;
var
  LErros: TStringList;
begin
  Result := '';
  LErros := TStringList.Create;
  try
    if not Assigned(FCliente) then
      LErros.Add('É necessário informar o cliente do pedido.');

    if not Assigned(FProduto) then
      LErros.Add('É necessário informar um produto para o pedido.')
    else
    begin
      if nbxPrecoVenda.Value <= 0 then
        LErros.Add('Informe o preço de venda do produto.')
      else if nbxPrecoVenda.Value < FProduto.preco_venda then
        LErros.Add('Informe um preço de venda maior ou igual a: ' + FloatToStr(FProduto.preco_venda));
    end;
    Result := LErros.Text;
  finally
    LErros.Free;
  end;
end;

procedure TfrmCadastrarPedido.incluirItemPedido;
var
  LFacade: TFacadePedido;
begin
  LFacade := TFacadePedido.Create;
  try
    FProduto.preco_venda := nbxPrecoVenda.Value;
    LFacade.adicionarItemPedido(FCliente, FProduto, nbxQuantidade.Value);
    exibirMensagem(LFacade.MessageInfo);
  finally
    LFacade.Free;
  end;
end;

procedure TfrmCadastrarPedido.alterarItemPedido;
var
  LFacade: TFacadePedido;
  LPedidoItem: TPedidoItem;
begin
  LFacade := TFacadePedido.Create;
  try
    LPedidoItem := LFacade.ItemPedidoDataSetToModel(dmConsulta.cdsPedidoItem);
    try
      LPedidoItem.id_produto := FProduto.id_produto;
      LPedidoItem.quantidade := nbxQuantidade.Value;
      LPedidoItem.valor_unitario := nbxPrecoVenda.Value;

      LFacade.alterarItemPedido(LPedidoItem, FProduto.descricao);
      if LFacade.MessageInfo.Trim <> '' then
        exibirMensagem(LFacade.MessageInfo)
      else
        exibirMensagem('Item alterado com sucesso!' + sLineBreak +
          'É necessário gravar o pedido para efetivar a alteração.');

    finally
      LPedidoItem.Free;
    end;
  finally
    LFacade.Free;
  end;
end;

procedure TfrmCadastrarPedido.atualizarValorTotalPedido;
var
  LValorPedido: Double;
begin
  LValorPedido := dmConsulta.cdsPedido.FieldByName('valor_total').AsFloat;
  lblValorTotal.Caption := FormatFloat('0.00', LValorPedido);
end;

procedure TfrmCadastrarPedido.exibirMensagem(const AMensagem: string);
begin
  if AMensagem.Trim <> '' then
    ShowMessage(AMensagem);
end;

procedure TfrmCadastrarPedido.editarItemPedido;
var
  LFacade: TFacadePedido;
  LPedidoItem: TPedidoItem;
begin
  limparCampos;
  if Assigned(FProduto) then
    FreeAndNil(FProduto);

  LFacade := TFacadePedido.Create;
  try
    LPedidoItem := LFacade.ItemPedidoDataSetToModel(dmConsulta.cdsPedidoItem);
  finally
    LFacade.Free;
  end;

  if not Assigned(LPedidoItem) then
    Exit;

  FProduto := TProduto.Create;
  FProduto.id_produto := LPedidoItem.id_produto;
  FProduto.preco_venda := LPedidoItem.valor_unitario;
  FProduto.descricao := dmConsulta.cdsPedidoItem.FieldByName('descricao').AsString;

  atualizarSelecaoProduto(FProduto, LPedidoItem.quantidade);
  AtualizarBotaoAdicionarItem(true);
end;

procedure TfrmCadastrarPedido.atualizarSelecaoCliente(ACliente: TCliente);
var
  LOldCliente: Integer;
  LUpdateCliente: Boolean;
begin
  LOldCliente := 0;
  if not dmConsulta.cdsPedido.IsEmpty then
    LOldCliente := dmConsulta.cdsPedido.FieldByName('id_cliente').AsInteger;

  if Assigned(FCliente) then
    FreeAndnil(FCliente);

  FCliente := TCliente.Create;
  if not Assigned(ACliente) then
    Exit;

  FCliente.Clone(ACliente);
  LUpdateCliente := (LOldCliente > 0) and (ACliente.id_cliente <> LOldCliente);

  edtCodCliente.Text := FCliente.id_cliente.ToString;
  edtNomeCliente.Text := FCliente.nome;

  if LUpdateCliente then
  begin
    dmConsulta.cdsPedido.Edit;
    dmConsulta.cdsPedido.FieldByName('id_cliente').AsInteger := FCliente.id_cliente;
    dmConsulta.cdsPedido.Post;
    ShowMessage('Cliente atualizado com sucesso!');
  end;

end;

procedure TfrmCadastrarPedido.atualizarSelecaoProduto(AProduto: TProduto;
  const AQuantidade: double);
begin
  edtNomeProduto.Text := AProduto.descricao;
  nbxPrecoVenda.Value := AProduto.preco_venda;
  nbxQuantidade.Value := AQuantidade;
  calcularValorTotalProduto;
end;

procedure TfrmCadastrarPedido.calcularValorTotalProduto;
begin
  nbxValorTotal.Value := 0.00;
  if (nbxQuantidade.Value > 0) and (nbxPrecoVenda.Value > 0) then
    nbxValorTotal.Value := nbxQuantidade.Value * nbxPrecoVenda.Value;
end;

procedure TfrmCadastrarPedido.carregarPedido(AIdPedido: Integer);
var
  LFacade: TFacadePedido;
  LidCliente: Integer;
  LCliente: TCliente;
begin
  novoPedido;
  LFacade := TFacadePedido.Create;
  try
    LFacade.carregarPedido(AIdPedido);

    if dmConsulta.cdsPedido.IsEmpty then
      Exit;

    LidCliente := dmConsulta.cdsPedido.FieldByName('id_cliente').AsInteger;
    LCliente := LFacade.obterCliente(LidCliente);
    try
      atualizarSelecaoCliente(LCliente);
    finally
      LCliente.Free;
    end;

    edtNumPedido.Text := dmConsulta.cdsPedido.FieldByName('id_pedido').AsString;
    edtDataEmissao.Text := dmConsulta.cdsPedido.FieldByName('data_emissao').AsString;

    atualizarValorTotalPedido;
    atualizarBotaoAdicionarItem(false);

  finally
    LFacade.Free;
  end;
end;

procedure TfrmCadastrarPedido.consultarPedido;
var
  LExistItem: Boolean;
  LMessage: string;
  LForm: TfrmConsultarPedido;
begin
  LExistItem := not dmConsulta.cdsPedidoItem.IsEmpty;

  if LExistItem then
  begin
    LMessage := 'Uma consulta de pedido foi solicitada.' + sLineBreak +
      'É necessário gravar o pedido atual antes de continuar.' + slineBreak;
    exibirMensagem(LMessage);
    Exit;
  end;

  Application.CreateForm(TfrmConsultarPedido, LForm);
  try
    LForm.ShowModal;
    if Assigned(LForm.Pedido) then
      carregarPedido(LForm.Pedido.id_pedido);
  finally
    LForm.Free;
  end;
end;

procedure TfrmCadastrarPedido.dbgPedidoItemKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if not dmConsulta.cdsPedido.IsEmpty then
  begin
    if (Key = VK_DELETE) then
    begin
      Key := 0;
      excluirPedidoItem;
      Exit;
    end;

    if key = VK_RETURN then
    begin
      Key := 0;
      editarItemPedido;
    end;
  end;
end;

procedure TfrmCadastrarPedido.excluirPedido;
var
  LidPedido: Integer;
  LResposta: Integer;
  LMessage: string;
  LFacade: TFacadePedido;
begin
  LidPedido := dmConsulta.cdsPedido.FieldByName('id_pedido').AsInteger;
  if LidPedido <= 0 then
  begin
    LMessage := 'Consulte um Pedido de Venda para realizar a exclusão.';
    exibirMensagem(LMessage);
    Exit;
  end;

  LMessage := Format('Confirma excluir o pedido %d ?', [LidPedido]);
  LMessage := LMessage + sLineBreak +
    'Não será possível recuperar o pedido após a exclusão';

  LResposta := MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0);
  if (LResposta <> mrYes) then
    Exit;

  try
    LFacade := TFacadePedido.Create;
    try
      LFacade.excluirPedido(LidPedido);
      exibirMensagem('Pedido excluido com sucesso!');
      NovoPedido;

    finally
      LFacade.Free;
    end;
  except
    exibirMensagem('Ocorreu um erro interno ao excluir o pedido!');
  end;
end;

procedure TfrmCadastrarPedido.excluirPedidoItem;
var
  LFacade: TFacadePedido;
  LPedido, LItemPedido: Integer;
  LValorTotal: Double;
  LMessage: string;
begin
  if dmConsulta.cdsPedidoItem.IsEmpty then
    Exit;

  LMessage:= 'Confirma a remoção do item selecionado?' + sLineBreak +
    'Produto: ' + dmConsulta.cdsPedidoItem.FieldByName('descricao').AsString;

  if MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  LFacade := TFacadePedido.Create;
  try
    LPedido := dmConsulta.cdsPedido.FieldByName('id_pedido').AsInteger;
    LItemPedido := dmConsulta.cdsPedidoItem.FieldByName('id_pedido_item').AsInteger;
    LFacade.excluirPedidoItem(LItemPedido);
    LValorTotal := dmConsulta.cdsPedido.FieldByName('valor_total').AsFloat;
    lblValorTotal.Caption := FormatFloat('0.00', LValorTotal);

    if LPedido > 0 then
    begin
      LMessage:= 'É necessário gravar o pedido %d para efetivar a remoção.';
      LMessage:= Format(LMessage, [LPedido]);
      exibirMensagem(LMessage);
    end;

  finally
    LFacade.Free;
  end;
end;

procedure TfrmCadastrarPedido.FormCreate(Sender: TObject);
begin
  dmConsulta.novoPedido;
end;

procedure TfrmCadastrarPedido.gravarPedido;
var
  LFacade: TFacadePedido;
begin
  if dmConsulta.cdsPedidoItem.IsEmpty then
  begin
    exibirMensagem('É necessário que o Pedido possua um ou mais itens!');
    Exit;
  end;

  try
    LFacade := TFacadePedido.Create;
    try
      LFacade.gravarPedido;
      exibirMensagem('Pedido gravado com sucesso!');
      NovoPedido;
    finally
      LFacade.Free;
    end;
  except
    on E:Exception do
      exibirMensagem('Ocorreu um erro ao gravar o pedido:' + sLineBreak + E.Message);
  end;
end;

procedure TfrmCadastrarPedido.atualizarBotaoAdicionarItem(const IsUpdate: Boolean);
begin
  sbtnDesistirAlteracao.Enabled := IsUpdate;
  sbtnAdicionar.Caption:= 'Adicionar';
  sbtnAdicionar.Tag := 0;
  sbtnPesquisarCliente.Enabled := not IsUpdate;
  sbtnPesquisarProduto.Enabled := not IsUpdate;
  sbtnGravarPedido.Enabled := not(IsUpdate and dmConsulta.cdsPedidoItem.IsEmpty);

  dbgPedidoItem.Enabled := not IsUpdate;

  if IsUpdate then
  begin
    sbtnAdicionar.Caption := 'Alterar';
    sbtnAdicionar.Tag := 1;
  end;
end;

procedure TfrmCadastrarPedido.limparCampos;
begin
  edtNomeProduto.Clear;
  nbxQuantidade.Clear;
  nbxPrecoVenda.Clear;
  nbxValorTotal.Clear;
end;

procedure TfrmCadastrarPedido.pesquisarCliente;
var
  Lform: TfrmConsultarCliente;
begin
  Application.CreateForm(TfrmConsultarCliente, Lform);
  try
    Lform.ShowModal;
    atualizarSelecaoCliente(Lform.Cliente);
  finally
    Lform.Free;
  end;
end;

procedure TfrmCadastrarPedido.pesquisarProduto;
var
  Lform: TfrmConsultarProduto;
begin
  Application.CreateForm(TfrmConsultarProduto, Lform);
  try
    Lform.ShowModal;

    if Assigned(FProduto) then
      FreeAndnil(FProduto);

    if Assigned(Lform.Produto) then
    begin
      FProduto := TProduto.Create;
      FProduto.Clone(Lform.Produto);
      atualizarSelecaoProduto(FProduto, 1);
    end;
  finally
    Lform.Free;
  end;
end;


function TfrmCadastrarPedido.podeAlterarCliente: boolean;
var
  LMessage: string;
  LResposta: Integer;
begin
  Result:= true;
  if not dmConsulta.cdsPedidoItem.IsEmpty then
  begin
    LMessage := 'O cliente já possui um ou mais lançamentos!' + sLineBreak +
                'Tem certeza de que deseja realizar a troca do cliente?';

    LResposta := MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0);
    Result := (LResposta = mrYes);
  end;
end;

procedure TfrmCadastrarPedido.nbxPrecoVendaExit(Sender: TObject);
begin
  calcularValorTotalProduto;
end;

procedure TfrmCadastrarPedido.nbxQuantidadeExit(Sender: TObject);
begin
  calcularValorTotalProduto;
end;

procedure TfrmCadastrarPedido.novoPedido;
begin
  LimparCampos;

  lblValorTotal.Caption := '0,00';
  edtCodCliente.Clear;
  edtNomeCliente.Clear;
  edtNumPedido.Clear;
  edtDataEmissao.Clear;

  if Assigned(FCliente) then
    FreeAndNil(FCliente);

  if Assigned(FProduto) then
    FreeAndNil(FProduto);

  dmConsulta.novoPedido;
  atualizarBotaoAdicionarItem(false);

end;

end.
