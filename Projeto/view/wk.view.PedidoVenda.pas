unit wk.view.PedidoVenda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, System.ImageList, Vcl.ImgList,
  Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.NumberBox,
  wk.facade.PedidoVenda, wk.model.cliente, wk.model.produto;

type
  TfrmPedidoVenda = class(TForm)
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
    nbxValorTotal: TNumberBox;
    Label4: TLabel;
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
    GridItens: TStringGrid;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure sbtnPesquisarClienteClick(Sender: TObject);
    procedure sbtnPesquisarProdutoClick(Sender: TObject);
    procedure nbxQuantidadeExit(Sender: TObject);
    procedure nbxPrecoVendaExit(Sender: TObject);
    procedure sbtnAdicionarClick(Sender: TObject);

    procedure sbtnGravarPedidoClick(Sender: TObject);
    procedure sbtnConsultarClick(Sender: TObject);
    procedure sbtnExcluirClick(Sender: TObject);
    procedure sbtnDesistirAlteracaoClick(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure GridItensKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    FPedidoVendaFacade: TPedidoVendaFacade;
    FClienteSelecionado: TCliente;
    FProdutoSelecionado: TProduto;

    function GetIdItemPedido: Integer;
    function PodeAlterarCliente: boolean;

    procedure PesquisarCliente;
    procedure PesquisarProduto;
    procedure AtualizarSelecaoCliente(ACliente: TCliente);
    procedure AtualizarSelecaoProduto(AProduto: TProduto);
    procedure AtualizarCamposDoCliente;
    procedure AtualizarCamposDoProduto(AQuantidade: Double);
    procedure AtualizarValorTotalPedido(AValorTotal: Currency);
    procedure AtualizarParaEdicao(const IsUpdate: Boolean);
    procedure AtualizarGrid;
    procedure CalcularValorTotalProduto;
    procedure ConsultarPedido;
    procedure CreateColumnsGrid;
    procedure CarregarPedido(AIdPedido: Integer);
    procedure AdicionarItemPedido;
    procedure ExcluirPedido;
    procedure ExcluirItemPedido;
    procedure EditarItemPedido;
    procedure ExibirMensagem(const AMensagem: string);
    procedure LimparCamposProduto;
    procedure LimparFormulario;
    procedure LimparGrid;
    procedure NovoPedido;
    procedure GravarPedido;

  end;

var
  frmPedidoVenda: TfrmPedidoVenda;

implementation

uses
  System.Generics.Collections,
  wk.view.consultarCliente,
  wk.view.consultarProduto,
  wk.model.pedido_item,
  wk.view.consultarPedido,
  wk.connection.conn,
  wk.DTO.PedidoItem;

{$R *.dfm}

const
  COL_DESCRICAO_PRODUTO = 1;
  COL_ID_ITEM = 5;

procedure TfrmPedidoVenda.FormCreate(Sender: TObject);
begin
  FPedidoVendaFacade := TPedidoVendaFacade.Create(dmConn);
  CreateColumnsGrid;
end;

procedure TfrmPedidoVenda.FormDestroy(Sender: TObject);
begin
  if Assigned(FPedidoVendaFacade) then
    FreeAndNil(FPedidoVendaFacade);
end;

procedure TfrmPedidoVenda.sbtnPesquisarClienteClick(Sender: TObject);
begin
  if PodeAlterarCliente then
    PesquisarCliente;
end;

procedure TfrmPedidoVenda.sbtnPesquisarProdutoClick(Sender: TObject);
begin
  PesquisarProduto;
end;

procedure TfrmPedidoVenda.nbxQuantidadeExit(Sender: TObject);
begin
  calcularValorTotalProduto;
end;

procedure TfrmPedidoVenda.nbxPrecoVendaExit(Sender: TObject);
begin
  calcularValorTotalProduto;
end;

procedure TfrmPedidoVenda.sbtnAdicionarClick(Sender: TObject);
begin
  CalcularValorTotalProduto;
  AdicionarItemPedido;
end;

procedure TfrmPedidoVenda.sbtnDesistirAlteracaoClick(Sender: TObject);
begin
  LimparCamposProduto;
  AtualizarParaEdicao(False);
end;

procedure TfrmPedidoVenda.sbtnCancelarClick(Sender: TObject);
var
  LMessage: string;
begin
  LMessage :=
    'As alterações não gravadas serão perdidas!' + sLineBreak +
    'Confirma o cancelamento?';

  if MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    NovoPedido;
end;

procedure TfrmPedidoVenda.sbtnExcluirClick(Sender: TObject);
begin
  ExcluirPedido;
end;

procedure TfrmPedidoVenda.sbtnConsultarClick(Sender: TObject);
begin
  ConsultarPedido;
end;

procedure TfrmPedidoVenda.sbtnGravarPedidoClick(Sender: TObject);
begin
  GravarPedido;
end;

procedure TfrmPedidoVenda.GridItensKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FPedidoVendaFacade.ExisteItensPedido then
  begin
    if (Key = VK_DELETE) then
    begin
      Key := 0;
      ExcluirItemPedido;
      Exit;
    end;

    if key = VK_RETURN then
    begin
      Key := 0;
      EditarItemPedido;
    end;
  end;
end;

procedure TfrmPedidoVenda.CreateColumnsGrid;
begin
  GridItens.FixedRows := 1;
  GridItens.ColCount  := 6;

  GridItens.Cells[0, 0] := 'Cód. Produto';
  GridItens.Cells[1, 0] := 'Descr. Produto';
  GridItens.Cells[2, 0] := 'Quantidade';
  GridItens.Cells[3, 0] := 'Valor Unit.';
  GridItens.Cells[4, 0] := 'Valor Total';
  GridItens.Cells[5, 0] := 'ItemId';

  GridItens.ColWidths[0] := 100; // "Cód. Produto"
  GridItens.ColWidths[1] := 250; // "Descr. Produto"
  GridItens.ColWidths[2] := 80;  // "Quantidade"
  GridItens.ColWidths[3] := 120; // "Valor Unit."
  GridItens.ColWidths[4] := 120; // "Valor Total"
  GridItens.ColWidths[5] := 0;   // "ItemId" (deixar invisível)

  GridItens.ColAlignments[2] := taRightJustify;
  GridItens.ColAlignments[3] := taRightJustify;
  GridItens.ColAlignments[4] := taRightJustify;

end;

function TfrmPedidoVenda.PodeAlterarCliente: boolean;
var
  LMessage: string;
  LResposta: Integer;
begin
  Result := true;
  if not FPedidoVendaFacade.ExisteItensPedido then
    Exit;

  Result := FPedidoVendaFacade.PodeAlterarCliente;
  if not Result then
  begin
    ExibirMensagem('Não é possível alterar o cliente do pedido.');
    Exit;
  end;

  LMessage := 'O pedido já possui um ou mais itens lançados!' + sLineBreak +
              'Confirma realizar a troca do cliente?';
  Result := (MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) = mrYes);

end;

procedure TfrmPedidoVenda.PesquisarCliente;
var
  Lform: TfrmConsultarCliente;
begin
  Application.CreateForm(TfrmConsultarCliente, Lform);
  try
    Lform.ShowModal;
    if Assigned(Lform.Cliente) then
      AtualizarSelecaoCliente(Lform.Cliente);
  finally
    Lform.Free;
  end;
end;

procedure TfrmPedidoVenda.PesquisarProduto;
var
  Lform: TfrmConsultarProduto;
begin
  Application.CreateForm(TfrmConsultarProduto, Lform);
  try
    Lform.ShowModal;
    if Assigned(Lform.Produto) then
      AtualizarSelecaoProduto(Lform.Produto);
  finally
    Lform.Free;
  end;
end;

procedure TfrmPedidoVenda.AtualizarSelecaoCliente(ACliente: TCliente);
begin
  if Assigned(FClienteSelecionado) then
    FreeAndNil(FClienteSelecionado);

  FClienteSelecionado := TCliente.Create;
  FClienteSelecionado.Clone(ACliente);

  FPedidoVendaFacade.AlterarCliente(FClienteSelecionado);
  AtualizarCamposDoCliente;
end;

procedure TfrmPedidoVenda.AtualizarSelecaoProduto(AProduto: TProduto);
begin
  if Assigned(FProdutoSelecionado) then
    FreeAndNil(FProdutoSelecionado);

  FProdutoSelecionado := TProduto.Create;
  FProdutoSelecionado.Clone(AProduto);
  AtualizarCamposDoProduto(1);
end;

procedure TfrmPedidoVenda.AtualizarCamposDoCliente;
begin
  edtCodCliente.Text := FClienteSelecionado.id_cliente.ToString;
  edtNomeCliente.Text := FClienteSelecionado.nome;
end;

procedure TfrmPedidoVenda.AtualizarCamposDoProduto(AQuantidade: Double);
begin
  nbxQuantidade.Value := AQuantidade;
  nbxPrecoVenda.Value := FProdutoSelecionado.preco_venda;
  edtNomeProduto.Text := FProdutoSelecionado.descricao;

  calcularValorTotalProduto;
end;

procedure TfrmPedidoVenda.AtualizarGrid;
var
  LItens: TArray<TPedidoItemDTO>;
  LValorTotal: Currency;
  LRow: Integer;
  LLine: Integer;
begin
  LValorTotal := 0;
  LItens := FPedidoVendaFacade.GetItensDTO;
  LimparGrid;

  if not Length(LItens) > 0 then
  begin
    AtualizarValorTotalPedido(0.00);
    Exit;
  end;

  GridItens.RowCount := Length(LItens) + 1;
  for LRow := 0 to High(LItens) do
  begin
    LLine:= LRow + 1;
    GridItens.Cells[0, LLine] := LItens[LRow].IdProduto.ToString;
    GridItens.Cells[1, LLine] := LItens[LRow].DescricaoProduto;
    GridItens.Cells[2, LLine] := FloatToStr(LItens[LRow].Quantidade);
    GridItens.Cells[3, LLine] := FormatFloat('0.00', LItens[LRow].ValorUnitario);
    GridItens.Cells[4, LLine] := FormatFloat('0.00', LItens[LRow].ValorTotal);
    GridItens.Cells[5, LLine] := LItens[LRow].IdItem.ToString;
    LValorTotal := LItens[LRow].ValorTotal + LValorTotal;
  end;

  AtualizarValorTotalPedido(LValorTotal);

end;

procedure TfrmPedidoVenda.CalcularValorTotalProduto;
begin
  nbxValorTotal.Value := 0.00;
  if (nbxQuantidade.Value > 0) and (nbxPrecoVenda.Value > 0) then
    nbxValorTotal.Value := nbxQuantidade.Value * nbxPrecoVenda.Value;
end;

procedure TfrmPedidoVenda.AdicionarItemPedido;
var
  LMessage: string;
  LQtd: Double;
  LValor: Currency;
  LItemId: Integer;
begin
  LMessage := '';
  if not Assigned(FClienteSelecionado) then
    LMessage := 'É necessário selecionar um cliente antes de incluir um pedido!'
  else if not Assigned(FProdutoSelecionado) then
    LMessage := 'É necessário selecionar um produto antes de incluir um pedido!';

  if not LMessage.IsEmpty then
  begin
    exibirMensagem(LMessage);
    Exit;
  end;

  try
    LQtd := nbxQuantidade.Value;
    LValor := nbxPrecoVenda.Value;

    if sbtnAdicionar.Tag = 0 then
      FPedidoVendaFacade.AdicionarItem(
        FClienteSelecionado, FProdutoSelecionado, LQtd, LValor)
    else
    begin
      LItemId := GetIdItemPedido;
      FPedidoVendaFacade.AlterarItem(LItemId, LQtd, LValor);
    end;

    AtualizarGrid;
    AtualizarParaEdicao(False);

  except
    on E: Exception do
      ShowMessage('Ocorreu um erro ao adicionar o item: ' + E.Message);
  end;
end;

procedure TfrmPedidoVenda.ExcluirPedido;
var
  LIdPedido: Integer;
  LMessage: string;
begin
  if not FPedidoVendaFacade.ExisteItensPedido then
    Exit;

  LIdPedido := FPedidoVendaFacade.ObterIdPedidoVenda;
  if LIdPedido = 0 then
  begin
    LMessage := 'Consulte um pedido de venda para realizar a exclusão.';
    ExibirMensagem(LMessage);
    Exit;
  end;

  LMessage := Format('Confirma excluir o pedido %d ?', [LIdPedido]);
  LMessage := LMessage + sLineBreak +
    'Não será possível recuperar o pedido após a exclusão.';

  if MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) <> MrYes then
    Exit;

  try
    FPedidoVendaFacade.ExcluirPedido;
    NovoPedido;
    ExibirMensagem('Pedido excluido com sucesso!');
  except
    on E:Exception do
      ExibirMensagem('Ocorreu um erro ao excluir o pedido: ' + sLineBreak + E.Message);
  end;
end;

procedure TfrmPedidoVenda.ExcluirItemPedido;
var
  LMessage: string;
  LProdutoNome: string;
  LIdItem: Integer;
  LValorTotal: Currency;
  LRow: Integer;
begin
  if not FPedidoVendaFacade.ExisteItensPedido then
    Exit;

  LRow := GridItens.Row;
  if (LRow <= 0) or (GridItens.RowCount <= 1) then
    Exit;

  LProdutoNome := GridItens.Cells[COL_DESCRICAO_PRODUTO, LRow];
  LIdItem := StrToInt(GridItens.Cells[COL_ID_ITEM, LRow]);

  LMessage:=
    'Confirma a remoção do produto selecionado?' + sLineBreak +
    'Produto: ' + LProdutoNome;

  if MessageDlg(LMessage, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    FPedidoVendaFacade.RemoverItem(LIdItem);
    AtualizarGrid;
  except
    on E: Exception do
      ExibirMensagem(E.Message);
  end;
end;

procedure TfrmPedidoVenda.ExibirMensagem(const AMensagem: string);
begin
  if AMensagem.Trim <> '' then
    ShowMessage(AMensagem);
end;

procedure TfrmPedidoVenda.EditarItemPedido;
var
  LIdItem: Integer;
  LPedidoItem: TPedidoItem;
begin
  if not FPedidoVendaFacade.ExisteItensPedido then
    Exit;

  LIdItem := GetIdItemPedido;
  LimparCamposProduto;

  if LIdItem <= 0 then
    Exit;

  try
    LPedidoItem := FPedidoVendaFacade.ObterItemPedido(LIdItem);
    if not Assigned(LPedidoItem) then
      Exit;

    if Assigned(FProdutoSelecionado) then
      FreeAndNil(FProdutoSelecionado);

    FProdutoSelecionado := TProduto.Create;
    FProdutoSelecionado.Clone(LPedidoItem.Produto);
    FProdutoSelecionado.preco_venda := LPedidoItem.ValorUnitario;

    AtualizarCamposDoProduto(LPedidoItem.Quantidade);
    AtualizarParaEdicao(True);
  except
    on E:Exception do
      exibirMensagem(E.Message);
  end;
end;

function TfrmPedidoVenda.GetIdItemPedido: Integer;
var
  LRow: Integer;
begin
  Result := 0;
  LRow := GridItens.Row;
  if (LRow <= 0) or (GridItens.RowCount <= 1) then
    Exit;

  Result := StrToInt(GridItens.Cells[COL_ID_ITEM, LRow]);

end;

procedure TfrmPedidoVenda.AtualizarValorTotalPedido(AValorTotal: Currency);
begin
  lblValorTotal.Caption := FormatFloat('0.00', AValorTotal);
end;

procedure TfrmPedidoVenda.LimparCamposProduto;
begin
  edtNomeProduto.Clear;
  nbxQuantidade.Clear;
  nbxPrecoVenda.Clear;
  nbxValorTotal.Clear;
end;

procedure TfrmPedidoVenda.AtualizarParaEdicao(const IsUpdate: Boolean);
var
  LExistItem: Boolean;
begin
  LExistItem := FPedidoVendaFacade.ExisteItensPedido;
  sbtnDesistirAlteracao.Enabled := IsUpdate;
  sbtnAdicionar.Caption:= 'Adicionar';
  sbtnPesquisarCliente.Enabled := not IsUpdate;
  sbtnPesquisarProduto.Enabled := not IsUpdate;
  sbtnGravarPedido.Enabled := not(IsUpdate and LExistItem);
  sbtnAdicionar.Tag := 0;
  GridItens.Enabled := not IsUpdate;

  if IsUpdate then
  begin
    sbtnAdicionar.Caption := 'Alterar';
    sbtnAdicionar.Tag := 1;
  end;

end;

procedure TfrmPedidoVenda.ConsultarPedido;
var
  LExistItem: Boolean;
  LMessage: string;
  LForm: TfrmConsultarPedido;
begin
  LExistItem := FPedidoVendaFacade.ExisteItensPedido;

  if LExistItem then
  begin
    LMessage := 'Uma consulta de pedido foi solicitada.' + sLineBreak +
      'É necessário gravar o pedido atual antes de continuar.' + slineBreak;
    ExibirMensagem(LMessage);
    Exit;
  end;

  Application.CreateForm(TfrmConsultarPedido, LForm);
  try
    LForm.ShowModal;
    if Assigned(LForm.Pedido) then
      CarregarPedido(LForm.Pedido.Id);
  finally
    FreeAndNil(LForm);
  end;
end;

procedure TfrmPedidoVenda.CarregarPedido(AIdPedido: Integer);
begin
  LimparFormulario;
  AtualizarParaEdicao(False);

  if Assigned(FClienteSelecionado) then
    FreeAndNil(FClienteSelecionado);

  if Assigned(FProdutoSelecionado) then
    FreeAndNil(FProdutoSelecionado);

  try
    FPedidoVendaFacade.CarregarPedido(AIdPedido);
    if not FPedidoVendaFacade.ExisteItensPedido then
      Exit;

    edtNumPedido.Text := IntToStr(AIdPedido);
    edtDataEmissao.Text := DateToStr(FPedidoVendaFacade.ObterDataEmisaoPedido);
    AtualizarSelecaoCliente(FPedidoVendaFacade.ObterClienteDoPedido);
    AtualizarGrid;
  except
    on E:Exception do
      ExibirMensagem(E.Message);
  end;
end;

procedure TfrmPedidoVenda.NovoPedido;
begin
  FPedidoVendaFacade.NovoPedido(nil);
  LimparFormulario;
  if Assigned(FClienteSelecionado) then
    FreeAndNil(FClienteSelecionado);

  if Assigned(FProdutoSelecionado) then
    FreeAndNil(FProdutoSelecionado);

  AtualizarParaEdicao(False);
end;

procedure TFrmPedidoVenda.LimparFormulario;
begin
  LimparGrid;
  LimparCamposProduto;
  edtCodCliente.Clear;
  edtNomeCliente.Clear;
  edtNumPedido.Clear;
  edtDataEmissao.Clear;
  AtualizarValorTotalPedido(0.00);
end;

procedure TfrmPedidoVenda.LimparGrid;
var
  LRow, LCol: Integer;
begin
  for LRow := 1 to GridItens.RowCount - 1 do
    for LCol := 0 to GridItens.ColCount - 1 do
      GridItens.Cells[LCol, LRow] := '';

  GridItens.RowCount := 1;
  GridItens.FixedRows := 0;
end;

procedure TfrmPedidoVenda.GravarPedido;
begin
  if not FPedidoVendaFacade.ExisteItensPedido then
  begin
    ExibirMensagem('É necessário que o Pedido possua um ou mais itens.');
    Exit;
  end;

  try
    FPedidoVendaFacade.GravarPedido;
    ExibirMensagem('Pedido gravado com sucesso!');
    NovoPedido;
  except
    on E:Exception do
      ExibirMensagem('Ocorreu um erro ao gravar o pedido:' + sLineBreak + E.Message);
  end;
end;

end.
