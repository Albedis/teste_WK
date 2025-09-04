unit wk.view.consultarProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, wk.model.produto, Datasnap.DBClient,
  wk.facade.Consultas;

type
  TfrmConsultarProduto = class(TForm)
    dbgProduto: TDBGrid;
    dsProdutos: TDataSource;
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
    cdsProdutos: TClientDataSet;
    procedure dbgProdutoDblClick(Sender: TObject);
    procedure sbtnSelecionarClick(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure sbtnPesquisarProdutoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtNomeProdutoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FFacadeConsultas: TConsultasFacade;
    FProduto: TProduto;
    procedure executarConsulta;
    procedure selecionarProduto;
  public
    property Produto: TProduto read FProduto;
  end;


implementation

uses
  wk.connection.conn;

{$R *.dfm}


{ TfrmConsultarProduto }

procedure TfrmConsultarProduto.dbgProdutoDblClick(Sender: TObject);
begin
  selecionarProduto;
end;

procedure TfrmConsultarProduto.edtNomeProdutoKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  executarConsulta;
end;

procedure TfrmConsultarProduto.executarConsulta;
var
  Lfilter: string;
begin
  sbtnSelecionar.Enabled := false;
  LFilter := '';

  if trim(edtNomeProduto.Text).Length > 0 then
  begin
    Lfilter := QuotedStr('%' + UpperCase(edtNomeProduto.Text) + '%');
    LFilter := Format('upper(descricao) like %s', [Lfilter]);
  end;

  cdsProdutos.Filter := Lfilter;
  cdsProdutos.Filtered := Lfilter <> '';
  sbtnSelecionar.Enabled := (cdsProdutos.RecordCount > 0);
end;

procedure TfrmConsultarProduto.FormCreate(Sender: TObject);
begin
  FFacadeConsultas := TConsultasFacade.Create(dmConn);
  cdsProdutos.Data := FFacadeConsultas.LoadProdutos;
  FProduto := nil;
end;

procedure TfrmConsultarProduto.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFacadeConsultas);
  if assigned(FProduto) then
    FreeAndNil(FProduto);
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
begin
  if cdsProdutos.IsEmpty then
    Exit;

  FProduto := FFacadeConsultas.ProdutoDataSetToModel(CdsProdutos);
  Close;
end;

end.
