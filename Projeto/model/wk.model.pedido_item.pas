unit wk.model.pedido_item;

interface

uses
  System.SysUtils,
  wk.model.produto;

type
  TPedidoItem = class
  private
    FId: Integer;
    FIdPedido: Integer;
    FProduto: TProduto;
    FQuantidade: Double;
    FValorUnitario: Currency;

    function GetProduto: TProduto;

    procedure SetQuantidade(const Value: Double);
    procedure SetValorUnitario(const Value: Currency);

  public
    constructor Create(AProduto: TProduto; AQtd: Double; AVlrUnitario: Currency); overload;
    destructor Destroy; override;

    function total: Currency;
    procedure AlterarProduto(AProduto: TProduto);

    property Id: Integer read FId write FId;
    property IdPedido: Integer read FIdPedido write FIdPedido;
    property Produto: TProduto read GetProduto;
    property Quantidade: Double read FQuantidade write SetQuantidade;
    property ValorUnitario: Currency read FValorUnitario write SetValorUnitario;

  end;

implementation

{ TPedidoItem }

procedure TPedidoItem.AlterarProduto(AProduto: TProduto);
begin
  if Id > 0 then
    raise Exception.Create('Não é permitido alterar o produto de um item já gravado.');

  if not Assigned(AProduto) then
    raise Exception.Create('Erro interno: um item precisa de um produto válido.');

  if Assigned(FProduto) then
    FProduto.Free;

  FProduto := TProduto.Create;
  FProduto.Clone(AProduto);

end;

constructor TPedidoItem.Create(AProduto: TProduto; AQtd: Double; AVlrUnitario: Currency);
begin
  inherited Create;
  if not Assigned(AProduto) then
    raise Exception.Create('Erro interno: o item precisa de um produto válido.');

  SetQuantidade(AQtd);
  SetValorUnitario(AVlrUnitario);

  FProduto := TProduto.Create;
  FProduto.Clone(AProduto);

end;

destructor TPedidoItem.Destroy;
begin
  if Assigned(FProduto) then
    FreeAndNil(FProduto);
  inherited;
end;

function TPedidoItem.GetProduto: TProduto;
begin
  if not Assigned(FProduto) then
    raise Exception.Create('Erro interno: produto não associado ao pedido.');
  Result := FProduto;
end;

procedure TPedidoItem.SetQuantidade(const Value: Double);
begin
  if Value <= 0 then
    raise Exception.Create('Quantidade deve ser maior que zero.');
  FQuantidade := Value;
end;

procedure TPedidoItem.SetValorUnitario(const Value: Currency);
begin
  // um item pode ser incluído com valor zero, mas não com valor negativo:
  if Value < 0 then
    raise Exception.Create('o valor unitário deve ser igual ou maior que zero.');
  FValorUnitario := Value;
end;

function TPedidoItem.total: Currency;
begin
  Result := FQuantidade * FValorUnitario;
end;

end.

