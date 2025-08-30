unit wk.view.consultarProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, wk.model.produto;

type
  TfrmConsultarProduto = class(TForm)
    dbgProduto: TDBGrid;
    dsProduto: TDataSource;
    pnlbottom: TPanel;
    sbtnCancelar: TSpeedButton;
    pnlPesquisa: TPanel;
    lblNomeCliente: TLabel;
    sbtnPesquisarProduto: TSpeedButton;
    edtNomeProduto: TEdit;
    pnlTitle: TPanel;
    Shape1: TShape;
    lblTitle: TLabel;
    Shape2: TShape;
    sbtnSelecionar: TSpeedButton;
    procedure dbgProdutoDblClick(Sender: TObject);
    procedure edtNomeProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSelecionarClick(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure sbtnPesquisarProdutoClick(Sender: TObject);
  private
    FProduto: TProduto;
    procedure executarConsulta;
    procedure selecionarProduto;
  public
    property Produto: TProduto read FProduto;
  end;


implementation

{$R *.dfm}

uses
  wk.facade.pedido, wk.datamodule.consulta;


{ TfrmConsultarProduto }

procedure TfrmConsultarProduto.dbgProdutoDblClick(Sender: TObject);
begin
  selecionarProduto;
end;

procedure TfrmConsultarProduto.edtNomeProdutoKeyPress(Sender: TObject;
  var Key: Char);
begin
  executarConsulta;
end;

procedure TfrmConsultarProduto.executarConsulta;
var
  Lfilter: string;
  Lfacade: TFacadePedido;
begin
  sbtnSelecionar.Enabled := false;
  Lfilter:= edtNomeProduto.Text;
  Lfacade:= TFacadePedido.Create;
  try
    dsProduto.DataSet := Lfacade.LoadProduto(Lfilter);
    sbtnSelecionar.Enabled := (dsProduto.DataSet.RecordCount > 0);
  finally
    Lfacade.Free;
  end;
end;

procedure TfrmConsultarProduto.sbtnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConsultarProduto.sbtnPesquisarProdutoClick(Sender: TObject);
begin
  executarConsulta;
end;

procedure TfrmConsultarProduto.sbtnSelecionarClick(Sender: TObject);
begin
  selecionarProduto;
end;

procedure TfrmConsultarProduto.selecionarProduto;
var
  Lfacade: TFacadePedido;
begin
  if dsProduto.DataSet.IsEmpty then
    Exit;

  Lfacade:= TFacadePedido.Create;
  try
    FProduto := Lfacade.ProdutoDataSetToModel(dsProduto.DataSet);
    Close;
  finally
    Lfacade.Free;
  end;
end;

end.
