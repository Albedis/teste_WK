unit wk.model.pedido;

interface

uses
  System.Generics.Collections, System.SysUtils,
  wk.model.cliente, wk.model.pedido_item;

type
  TPedido = class
  private
    FId: Integer;
    FDataEmissao: TDate;
    FCliente: TCliente;
    FItens: TObjectDictionary<Integer, TPedidoItem>;
    FValor_Total: Currency;

    function GetCliente: TCliente;

  public
    constructor Create; overload;
    constructor Create(ACliente: TCliente); overload;
    destructor Destroy; override;

    function ValorTotalItens: Currency;
    procedure AlterarCliente(ACliente: TCliente);

    procedure AdicionarItem(AItem: TPedidoItem);
    procedure RemoverItem(AIdItem: Integer);
    procedure RemoverTodosItens;

    property Id: Integer read FId write FId;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;
    property Cliente: TCliente read GetCliente;
    property Itens: TObjectDictionary<Integer, TPedidoItem> read FItens;
    property ValorTotal: Currency read FValor_Total write FValor_Total;

  end;

implementation

{ TPedido }

constructor TPedido.Create;
begin
  inherited Create;
  FItens := TObjectDictionary<Integer, TPedidoItem>.Create([doOwnsValues]);
  FDataEmissao := Date;
end;

constructor TPedido.Create(ACliente: TCliente);
begin
  Create;
  AlterarCliente(ACliente);
end;

function TPedido.GetCliente: TCliente;
begin
  if not Assigned(FCliente) then
    raise Exception.Create('Erro interno: cliente não associado ao pedido.');
  Result := FCliente;
end;

destructor TPedido.Destroy;
begin
  FItens.Free;
  if Assigned(FCliente) then
    FreeAndNil(FCliente);
  inherited;
end;

procedure TPedido.AdicionarItem(AItem: TPedidoItem);
begin
  if not Assigned(AItem) then
    raise Exception.Create('Item inválido ao adicionar no pedido.');
  FItens.AddOrSetValue(AItem.Id, AItem);
end;

procedure TPedido.RemoverItem(AIdItem: Integer);
begin
  if not FItens.ContainsKey(AIdItem) then
    raise Exception.CreateFmt('Item %d não encontrado no pedido.', [AIdItem]);

  FItens.Remove(AIdItem);
end;

procedure TPedido.RemoverTodosItens;
begin
  FItens.Clear;
end;

function TPedido.ValorTotalItens: Currency;
var
  LItem: TPedidoItem;
begin
  Result := 0;
  for LItem in FItens.Values do
    Result := Result + LItem.total;
end;

procedure TPedido.AlterarCliente(ACliente: TCliente);
begin
  if Id > 0 then
    raise Exception.Create('Não é permitido alterar o cliente de um pedido já gravado.');

  if not Assigned(ACliente) then
    raise Exception.Create('Erro interno: um pedido precisa de um cliente válido.');

  if Assigned(FCliente) then
    FCliente.Free;

  FCliente := TCliente.Create;
  FCliente.Clone(ACliente);
end;

end.

