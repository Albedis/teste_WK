unit wk.view.consultarCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids, wk.model.cliente;

type
  TfrmConsultarCliente = class(TForm)
    pnlPesquisa: TPanel;
    lblNomeCliente: TLabel;
    edtNomeCliente: TEdit;
    sbtnPesquisarCliente: TSpeedButton;
    pnlTitle: TPanel;
    Shape1: TShape;
    lblTitle: TLabel;
    Shape2: TShape;
    dbgClientes: TDBGrid;
    dsClient: TDataSource;
    pnlbottom: TPanel;
    sbtnCancelar: TSpeedButton;
    sbtnSelecionar: TSpeedButton;
    procedure sbtnPesquisarClienteClick(Sender: TObject);
    procedure dbgClientesDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure edtNomeClienteKeyPress(Sender: TObject; var Key: Char);
    procedure sbtnSelecionarClick(Sender: TObject);
  private
    FCliente: TCliente;
    procedure executarConsulta;
    procedure selecionarCliente;
  public
    property Cliente: TCliente read FCliente;
  end;

implementation

uses
  wk.facade.pedido;

{$R *.dfm}

procedure TfrmConsultarCliente.dbgClientesDblClick(Sender: TObject);
begin
  selecionarCliente;
end;

procedure TfrmConsultarCliente.edtNomeClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  executarConsulta;
end;

procedure TfrmConsultarCliente.executarConsulta;
var
  Lfilter: string;
  Lfacade: TFacadePedido;
begin
  sbtnSelecionar.Enabled := False;
  Lfilter := edtNomeCliente.Text;
  Lfacade := TFacadePedido.Create;
  try
    dsClient.DataSet := Lfacade.LoadCliente(Lfilter);
    sbtnSelecionar.Enabled := (dsClient.DataSet.RecordCount > 0);
  finally
    Lfacade.Free;
  end;
end;

procedure TfrmConsultarCliente.FormCreate(Sender: TObject);
begin
  FCliente := nil;
end;

procedure TfrmConsultarCliente.FormDestroy(Sender: TObject);
begin
  if assigned(FCliente) then
    FreeAndNil(FCliente);
end;

procedure TfrmConsultarCliente.sbtnPesquisarClienteClick(Sender: TObject);
begin
  ExecutarConsulta;
end;

procedure TfrmConsultarCliente.sbtnSelecionarClick(Sender: TObject);
begin
  selecionarCliente;
end;

procedure TfrmConsultarCliente.selecionarCliente;
var
  Lfacade: TFacadePedido;
begin
  if dsClient.DataSet.IsEmpty then
    Exit;

  Lfacade:= TFacadePedido.Create;
  try
    FCliente := Lfacade.ClienteDataSetToModel(dsClient.DataSet);
    Close;
  finally
    Lfacade.Free;
  end;
end;

procedure TfrmConsultarCliente.sbtnCancelarClick(Sender: TObject);
begin
  Close;
end;

end.
