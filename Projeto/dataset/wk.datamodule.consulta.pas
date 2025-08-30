unit wk.datamodule.consulta;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Datasnap.DBClient,
  Datasnap.Provider;

type
  TdmConsulta = class(TDataModule)
    qryCliente: TFDQuery;
    qryProduto: TFDQuery;
    qryPedido: TFDQuery;
    qryPedidoItem: TFDQuery;
    cdsPedidoItem: TClientDataSet;
    cdsPedido: TClientDataSet;
    procedure DataModuleCreate(Sender: TObject);
  private
    function GetDataPacket(const ASQL: string): OleVariant;

    procedure LoadEstruturaPedido;
    procedure LoadEstruturaPedidoItem;

    function getLoadClient(AFilter: string): string;
    function getLoadProduto(AFilter: string): string;
    function getLoadPedido(AFilter: string): string;
    function getLoadPedidoItem(AIdPedido: integer): string;
    function Connection: TFDConnection;
    procedure executeSQL(const ASQL: string);

  public

    function LoadClient(Afilter: string): TDataSet;
    function LoadProduto(Afilter: string): TDataSet;
    function LoadPedido(Afilter: string): TDataSet;

    procedure obterPedido(const AIdPedido: Integer = 0);
    procedure obterPedidoConsulta(const AIdPedido: Integer);
    procedure obterCliente(const AIdCliente: Integer);
    procedure novoPedido;

    procedure excluirPedido(AIdPedido: Integer);
    procedure excluirItemPedido(AIdPedido: Integer);

  end;

var
  dmConsulta: TdmConsulta;

implementation

uses
  wk.connection.conn;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

function TdmConsulta.Connection: TFDConnection;
begin
   Result := dmConn.FDConn;
end;

procedure TdmConsulta.DataModuleCreate(Sender: TObject);
begin
  qryCliente.Connection := Connection;
  qryProduto.Connection := Connection;
  qryPedido.Connection  := Connection;
  qryPedidoItem.Connection := Connection;

  LoadEstruturaPedido;
  LoadEstruturaPedidoItem;

end;

procedure TdmConsulta.excluirPedido(AIdPedido: Integer);
var
  LSQL: string;
begin
  dmConn.FDConn.StartTransaction;
  try
    excluirItemPedido(AIdPedido);
    LSQL:= Format('DELETE FROM pedido WHERE id_pedido = %d', [AIdPedido]);
    executeSQL(LSQL);
    dmconn.FDConn.Commit;
  except
    dmConn.FDConn.Rollback;
    raise;
  end;

  cdsPedido.EmptyDataSet;
  cdsPedidoItem.EmptyDataSet;

end;

procedure TdmConsulta.excluirItemPedido(AIdPedido: Integer);
var
  LSQL: string;
begin
  LSQL := Format('DELETE FROM pedido_item WHERE id_pedido = %d', [AIdPedido]);
  executeSQL(LSQL);
end;

procedure TdmConsulta.executeSQL(const ASQL: string);
var
  qryExec: TFdQuery;
begin
  qryExec := TFdQuery.Create(nil);
  try
    qryExec.Connection := Connection;
    qryExec.SQL.Text := ASQL;
    qryExec.ExecSQL;
  finally
    qryExec.Free;
  end;
end;

function TdmConsulta.getLoadClient(AFilter: string): string;
var
  LSQL: string;
  Llike: string;
begin
  LSQL:= 'Select c.* from cliente c ' +
         'where upper(c.nome) like %s ' +
         'order by c.nome';

  Llike := '%';
  if not Afilter.IsEmpty then
    Llike := '%' + UpperCase(Afilter) + '%';
  LSQL := Format(LSQL,[Llike.QuotedString]);

  Result := LSQL;

end;

function TdmConsulta.getLoadPedido(AFilter: string): string;
var
  LLike: string;
  LSQL: string;
begin
  LSQL:= 'Select pedido.*, cliente.nome as nome_cliente, cliente.uf ' +
         ' from pedido ' +
         ' inner join cliente on cliente.id_cliente = pedido.id_cliente ' +
         ' where id_pedido like %s ' +
         ' order by data_emissao';

  LLike := '%';
  if not Afilter.IsEmpty then
    LLike := Afilter + '%';

  Result := format(LSQL, [LLike.QuotedString]);

end;

function TdmConsulta.getLoadPedidoItem(AIdPedido: integer): string;
var
  LSQL: TStringList;
begin
  LSQL:= TStringList.Create;
  try
    LSQL.Add('select');
    LSQL.Add('pedido_item.*,');
    LSQL.Add('produto.descricao');
    LSQL.Add('from pedido_item');
    LSQL.Add('inner join produto on produto.id_produto = pedido_item.id_produto');
    LSQL.Add('where pedido_item.id_pedido = %d');
    LSQL.Add('order by pedido_item.id_pedido_item');

    Result := Format(LSQL.Text, [AIdPedido]);

  finally
    LSQL.Free;
  end;
end;

function TdmConsulta.getLoadProduto(AFilter: string): string;
var
  LSQL: string;
  Llike: string;
begin
  LSQL:= 'Select p.* from produto p ' +
         'where upper(p.descricao) like %s ' +
         'order by p.descricao';

  Llike := '%';
  if not Afilter.IsEmpty then
    Llike := '%' + UpperCase(Afilter) + '%';
  LSQL := Format(LSQL,[Llike.QuotedString]);

  Result := LSQL;

end;

function TdmConsulta.LoadClient(Afilter: string): TDataSet;
begin
  qryCliente.SQL.Text := getLoadClient(Afilter);
  qryCliente.Open;
  Result := qryCliente;
end;

procedure TdmConsulta.LoadEstruturaPedidoItem;
begin
  cdsPedidoItem.Close;
  cdsPedidoItem.FieldDefs.Clear;
  cdsPedidoItem.FieldDefs.Add('id_pedido_item', ftInteger);
  cdsPedidoItem.FieldDefs.Add('id_pedido', ftInteger);
  cdsPedidoItem.FieldDefs.Add('id_produto', ftInteger);
  cdsPedidoItem.FieldDefs.Add('quantidade', ftFloat);
  cdsPedidoItem.FieldDefs.Add('valor_unitario', ftFloat);
  cdsPedidoItem.FieldDefs.Add('valor_total', ftFloat);
  cdsPedidoItem.FieldDefs.Add('descricao', ftString, 100);
  cdsPedidoItem.CreateDataSet;
end;

procedure TdmConsulta.LoadEstruturaPedido;
begin
  cdsPedido.Close;
  cdsPedido.FieldDefs.Clear;
  cdsPedido.FieldDefs.Add('id_pedido', ftInteger);
  cdsPedido.FieldDefs.Add('data_emissao', ftDateTime);
  cdsPedido.FieldDefs.Add('id_cliente', ftInteger);
  cdsPedido.FieldDefs.Add('valor_total', ftFloat);
  cdsPedido.CreateDataSet;
end;

function TdmConsulta.LoadPedido(Afilter: string): TDataSet;
begin
  qryPedido.SQL.Text := getLoadPedido(Afilter);
  qryPedido.Open;
  Result := qryPedido;
end;

function TdmConsulta.LoadProduto(Afilter: string): TDataSet;
begin
  qryProduto.SQL.Text := getLoadProduto(Afilter);
  qryProduto.Open;
  Result := qryProduto;
end;

procedure TdmConsulta.novoPedido;
begin
  cdsPedido.EmptyDataSet;
  cdsPedidoItem.EmptyDataSet;
end;

procedure TdmConsulta.obterCliente(const AIdCliente: Integer);
var
  LSQL: string;
begin
  LSQL := format('Select * from cliente where id_cliente = %d', [AIdCliente]);
  qryCliente.Close;
  qryCliente.Open(LSQL);
end;

procedure TdmConsulta.obterPedido(const AIdPedido: Integer);
var
  LSQL: string;
begin
  LSQL := format('Select * from pedido where id_pedido = %d', [AIdPedido]);
  qryPedido.Close;
  qryPedido.Open(LSQL);

  LSQL := format('Select * from pedido_item where id_pedido = %d', [AIdPedido]);
  qryPedidoItem.Close;
  qryPedidoItem.Open(LSQL);
end;

procedure TdmConsulta.obterPedidoConsulta(const AIdPedido: Integer);
var
  LListSQL: TStringList;
  LSQL: string;
begin
  qryPedido.Close;
  qryPedidoItem.Close;

  LListSQL := TStringList.Create;
  try
     LListSQL.Add('select c.nome, p.*');
     LListSQL.Add('from pedido p');
     LListSQL.Add('inner join cliente c on c.id_cliente = p.id_cliente');
     LListSQL.Add('where p.id_pedido = %d ');

     LSQL := format(LListSQL.Text, [AIdPedido]);
     qryPedido.Open(LSQL);

     LSQL := getLoadPedidoItem(AIdPedido);
     qryPedidoItem.Open(LSQL);

  finally
    LListSQL.Free;
  end;
end;

function TdmConsulta.GetDataPacket(const ASQL: string): OleVariant;
var
  LQuery: TFDQuery;
  LProvider: TDataSetProvider;
begin
  LQuery := TFDQuery.Create(nil);
  LProvider := TDataSetProvider.Create(nil);
  try
    LQuery.Connection := Connection;
    LQuery.SQL.Text := ASQL;
    LQuery.Open;

    LProvider.DataSet := LQuery;
    Result := LProvider.Data;
  finally
    LProvider.Free;
    LQuery.Free;
  end;
end;


end.
