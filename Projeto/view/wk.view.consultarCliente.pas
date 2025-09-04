unit wk.view.consultarCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Vcl.Grids, Vcl.DBGrids, wk.model.cliente, Datasnap.DBClient,
  wk.facade.Consultas;

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
    dsClientes: TDataSource;
    pnlbottom: TPanel;
    sbtnCancelar: TSpeedButton;
    sbtnSelecionar: TSpeedButton;
    cdsClientes: TClientDataSet;
    procedure sbtnPesquisarClienteClick(Sender: TObject);
    procedure dbgClientesDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure sbtnSelecionarClick(Sender: TObject);
    procedure edtNomeClienteKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FFacadeConsultas: TConsultasFacade;
    FCliente: TCliente;
    procedure executarConsulta;
    procedure selecionarCliente;
  public
    property Cliente: TCliente read FCliente;
  end;

implementation

uses
  wk.connection.conn;

{$R *.dfm}

procedure TfrmConsultarCliente.dbgClientesDblClick(Sender: TObject);
begin
  selecionarCliente;
end;

procedure TfrmConsultarCliente.edtNomeClienteKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  executarConsulta;
end;

procedure TfrmConsultarCliente.executarConsulta;
var
  Lfilter: string;
begin
  sbtnSelecionar.Enabled := False;
  LFilter := '';

  if Trim(edtNomeCliente.Text).Length > 0 then
  begin
    Lfilter := QuotedStr('%' + UpperCase(edtNomeCliente.Text) + '%');
    Lfilter := format('upper(nome_cliente) like %s', [Lfilter]);
  end;

  cdsClientes.Filter := LFilter;
  cdsClientes.Filtered := Lfilter <> '';
  sbtnSelecionar.Enabled := (cdsClientes.RecordCount > 0);
end;

procedure TfrmConsultarCliente.FormCreate(Sender: TObject);
begin
  FCliente := nil;
  FFacadeConsultas := TConsultasFacade.Create(dmConn);
  cdsClientes.Data := FFacadeConsultas.LoadClientes;
end;

procedure TfrmConsultarCliente.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFacadeConsultas);
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
begin
  if cdsClientes.IsEmpty then
    Exit;

  FCliente := FFacadeConsultas.ClienteDataSetToModel(cdsClientes);
  Close;
end;

procedure TfrmConsultarCliente.sbtnCancelarClick(Sender: TObject);
begin
  if Assigned(FCliente) then
    FreeAndNil(FCliente);
  Close;
end;

end.
