unit wk.model.pedido_item;

interface

uses
  System.Generics.Collections;

type
TPedidoItem = class(TObject)
  private
    FRules: TDictionary<string, string>;

    Fid_pedido_item: integer;
    Fid_pedido: integer;
    Fid_produto: integer;
    Fquantidade: double;
    Fvalor_unitario: currency;
    Fvalor_total: currency;

    function getValorTotal: currency;
    function getQuantidade: double;

    procedure rules;

  public
    constructor Create;
    destructor Destroy; override;

    property id_pedido_item: integer read Fid_pedido_item write Fid_pedido_item;
    property id_pedido: integer read Fid_pedido write Fid_pedido;
    property id_produto: integer read Fid_produto write Fid_produto;
    property quantidade: double read getQuantidade write Fquantidade;
    property valor_unitario: currency read Fvalor_unitario write Fvalor_unitario;
    property valor_total: currency read getValorTotal;

    function validate: string;

end;

implementation

{ TPedidoItem }

constructor TPedidoItem.Create;
begin
  FRules := TDictionary<string, string>.Create;
  rules;
end;

destructor TPedidoItem.Destroy;
begin
  FRules.Free;
  inherited;
end;

function TPedidoItem.getQuantidade: double;
begin
  if FQuantidade <= 0 then
    FQuantidade := 1; //fallback
  Result := Fquantidade;
end;

function TPedidoItem.getValorTotal: currency;
begin
  result := Fquantidade * Fvalor_unitario;
end;

procedure TPedidoItem.rules;
begin
   // apenas exemplo, os valores de validação devem ser configuráveis:
  FRules.Add('quantidade.max', 'Informe uma quantidade menor ou igual a 9.999');
  FRules.Add('quantidade.min', 'Informe uma quantidade maior ou igual a 1.');
  FRules.Add('produto.required', 'Informe o código do produto.');
  FRules.Add('valorunitario.required', 'Informe o valor unitário do produto.');
end;

function TPedidoItem.validate: string;
var
  LMessage: string;
begin
  if Fquantidade > 9999 then
  begin
    FRules.TryGetValue('quantidade.max', LMessage);
    Exit(LMessage);
  end;

  if Fquantidade <= 0 then
  begin
    FRules.TryGetValue('quantidade.min', LMessage);
    Exit(LMessage);
  end;

  if not(Fid_produto > 0) then
  begin
    FRules.TryGetValue('produto.required', LMessage);
    Exit(LMessage);
  end;

  if not(Fvalor_unitario > 0) then
  begin
    FRules.TryGetValue('valorunitario.required', LMessage);
    Exit(LMessage);
  end;
end;

end.
