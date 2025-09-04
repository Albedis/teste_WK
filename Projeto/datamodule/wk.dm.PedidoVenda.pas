unit wk.dm.PedidoVenda;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient,
  wk.model.produto;

type
  TdmPedido = class(TDataModule)
    cdsItensPedido: TClientDataSet;
    dsItensPedido: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    FNextTempId: Integer;

    procedure CreateDataSet;

  public
    function ValorTotalPedido: Currency;

    procedure AddItem(AProduto: TProduto;
      AQuantidade: Double; AValorUnit: Currency);

    procedure RemoveItem(AIdPedidoItem: Integer);

    procedure EditItem(AIdPedidoItem: Integer;
      AQuantidade: Double; AValorUnit: Currency);
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}


procedure TdmPedido.CreateDataSet;
begin
  cdsItensPedido.Close;
  cdsItensPedido.FieldDefs.Clear;
  cdsItensPedido.FieldDefs.Add('id_pedido_item', ftInteger);
  cdsItensPedido.FieldDefs.Add('id_produto', ftInteger);
  cdsItensPedido.FieldDefs.Add('descricao', ftString, 100);
  cdsItensPedido.FieldDefs.Add('quantidade', ftFloat);
  cdsItensPedido.FieldDefs.Add('valor_unitario', ftCurrency);
  cdsItensPedido.FieldDefs.Add('valor_total', ftCurrency);
  cdsItensPedido.CreateDataSet;
end;

procedure TdmPedido.DataModuleCreate(Sender: TObject);
begin
  CreateDataSet;
  FNextTempId := 0;
end;

procedure TdmPedido.AddItem(AProduto: TProduto;
  AQuantidade: Double; AValorUnit: Currency);
begin
  inc(FNextTempId);
  cdsItensPedido.Append;
  cdsItensPedido.FieldByName('id_pedido_item').AsInteger := FNextTempId;
  cdsItensPedido.FieldByName('id_produto').AsInteger := AProduto.id_produto;
  cdsItensPedido.FieldByName('descricao').AsString := AProduto.descricao;
  cdsItensPedido.FieldByName('quantidade').AsFloat := AQuantidade;
  cdsItensPedido.FieldByName('valor_unitario').AsCurrency := AValorUnit;
  cdsItensPedido.FieldByName('valor_total').AsCurrency := AQuantidade * AValorUnit;
  cdsItensPedido.Post;
end;

procedure TdmPedido.RemoveItem(AIdPedidoItem: Integer);
begin
  if cdsItensPedido.Locate('id_pedido_item', AIdPedidoItem, []) then
  begin
    cdsItensPedido.Delete;
    Exit;
  end;
  raise Exception.Create('Não é possivel excluir, item não encontrado!');
end;

function TdmPedido.ValorTotalPedido: Currency;
begin
  Result := 0;

  if cdsItensPedido.IsEmpty then
    Exit;

  cdsItensPedido.DisableControls;
  try
    cdsItensPedido.First;
    while not cdsItensPedido.Eof do
    begin
      Result := Result + cdsItensPedido.FieldByName('valor_total').AsCurrency;
      cdsItensPedido.Next;
    end;
  finally
    cdsItensPedido.EnableControls;
  end;
end;

procedure TdmPedido.EditItem(AIdPedidoItem: Integer;
  AQuantidade: Double; AValorUnit: Currency);
begin
  if cdsItensPedido.Locate('id_pedido_item', AIdPedidoItem, []) then
  begin
    cdsItensPedido.Edit;
    cdsItensPedido.FieldByName('quantidade').AsFloat := AQuantidade;
    cdsItensPedido.FieldByName('valor_unitario').AsCurrency := AValorUnit;
    cdsItensPedido.FieldByName('valor_total').AsCurrency := AQuantidade * AValorUnit;
    cdsItensPedido.Post;
  end;
end;

end.
