unit wk.view.consultarPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, wk.model.pedido, wk.facade.Consultas,
  Datasnap.DBClient;

type
  TfrmConsultarPedido = class(TForm)
    dbgPedido: TDBGrid;
    dsPedidos: TDataSource;
    pnlbottom: TPanel;
    sbtnCancelar: TSpeedButton;
    sbtnSelecionar: TSpeedButton;
    pnlPesquisa: TPanel;
    lblTitlePedido: TLabel;
    sbtnPesquisarPedido: TSpeedButton;
    edtNumeroPedido: TEdit;
    pnlTitle: TPanel;
    Shape1: TShape;
    lblTitle: TLabel;
    Shape2: TShape;
    cdsPedidos: TClientDataSet;
    procedure sbtnPesquisarPedidoClick(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure sbtnSelecionarClick(Sender: TObject);
    procedure dbgPedidoDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtNumeroPedidoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FFacadeConsultas: TConsultasFacade;
    FPedido: TPedido;
    procedure executarConsulta;
    procedure selecionarPedido;
  public
    property Pedido: TPedido read FPedido;
  end;

var
  frmConsultarPedido: TfrmConsultarPedido;

implementation

uses
  wk.connection.conn;

{$R *.dfm}

{ TfrmConsultarPedido }

procedure TfrmConsultarPedido.dbgPedidoDblClick(Sender: TObject);
begin
  selecionarPedido;
end;

procedure TfrmConsultarPedido.edtNumeroPedidoKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  executarConsulta;
end;

procedure TfrmConsultarPedido.executarConsulta;
var
  LValue: Integer;
  LFilter: string;
begin
  sbtnSelecionar.Enabled := false;
  LFilter := '';

  if Trim(edtNumeroPedido.Text).Length > 0 then
  begin
    if TryStrToInt(edtNumeroPedido.Text, LValue) then
      LFilter := 'id_pedido Like ' + QuotedStr(LValue.ToString + '%')
    else
    begin
      ShowMessage('O número do pedido deve ser um valor numérico!');
      Exit;
    end;
  end;

  cdsPedidos.Filter := LFilter;
  cdsPedidos.Filtered := Lfilter <> '';
  sbtnSelecionar.Enabled := (cdsPedidos.RecordCount > 0);

end;

procedure TfrmConsultarPedido.FormCreate(Sender: TObject);
begin
  FFacadeConsultas := TConsultasFacade.Create(dmConn);
  cdsPedidos.Data := FFacadeConsultas.LoadPedidos;
  FPedido := nil;
end;

procedure TfrmConsultarPedido.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFacadeConsultas);
  if Assigned(FPedido) then
    FreeAndNil(FPedido);
end;

procedure TfrmConsultarPedido.sbtnCancelarClick(Sender: TObject);
begin
  if Assigned(FPedido) then
    FreeAndNil(FPedido);
  Close;
end;

procedure TfrmConsultarPedido.sbtnPesquisarPedidoClick(Sender: TObject);
begin
  executarConsulta;
end;

procedure TfrmConsultarPedido.sbtnSelecionarClick(Sender: TObject);
begin
  selecionarPedido;
end;

procedure TfrmConsultarPedido.selecionarPedido;
begin
  if cdsPedidos.IsEmpty then
    Exit;
  FPedido := FFacadeConsultas.PedidoDataSetToModel(cdsPedidos);
  Close;
end;

end.
