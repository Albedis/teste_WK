unit wk.view.consultarPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, wk.model.pedido;

type
  TfrmConsultarPedido = class(TForm)
    dbgPedido: TDBGrid;
    dsPedido: TDataSource;
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
    procedure sbtnPesquisarPedidoClick(Sender: TObject);
    procedure sbtnCancelarClick(Sender: TObject);
    procedure sbtnSelecionarClick(Sender: TObject);
    procedure dbgPedidoDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
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
  wk.facade.pedido;

{$R *.dfm}

{ TfrmConsultarPedido }

procedure TfrmConsultarPedido.dbgPedidoDblClick(Sender: TObject);
begin
  selecionarPedido;
end;

procedure TfrmConsultarPedido.executarConsulta;
var
  LValue: Integer;
  LFilter: string;
  Lfacade: TFacadePedido;
begin
  sbtnSelecionar.Enabled := false;
  LFilter := '';

  if Trim(edtNumeroPedido.Text).Length > 0 then
  begin
    if TryStrToInt(edtNumeroPedido.Text, LValue) then
      LFilter := LValue.ToString
    else
    begin
      ShowMessage('O número do pedido deve ser um valor numérico!');
      Exit;
    end;
  end;

  Lfacade:= TFacadePedido.Create;
  try
    dsPedido.DataSet := Lfacade.LoadPedido(LFilter);
    sbtnSelecionar.Enabled := (dsPedido.DataSet.RecordCount > 0);
  finally
    Lfacade.Free;
  end;
end;

procedure TfrmConsultarPedido.FormDestroy(Sender: TObject);
begin
  if assigned(FPedido) then
    FreeAndnil(FPedido);
end;

procedure TfrmConsultarPedido.sbtnCancelarClick(Sender: TObject);
begin
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
var
  Lfacade: TFacadePedido;
begin
  if dsPedido.DataSet.IsEmpty then
    Exit;

  Lfacade:= TFacadePedido.Create;
  try
    FPedido := Lfacade.PedidoDataSetToModel(dsPedido.DataSet);
    Close;
  finally
    Lfacade.Free;
  end;
end;

end.
