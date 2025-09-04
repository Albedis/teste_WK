unit wk.repository.produto;

interface

uses
  System.SysUtils, System.Generics.Collections,
  FireDAC.Comp.Client,
  wk.model.produto, wk.sql.produto, Data.DB;

type
  TProdutoRepository = class
  private
    FConn: TFDConnection;
    FCache: TObjectDictionary<Integer, TProduto>;
    function DataSetToModel(ADataSet: TDataSet): TProduto;
  public
    constructor Create(AConn: TFDConnection);
    destructor Destroy; override;

    function BuscarPorId(AId: Integer): TProduto;
    function BuscarPorDescricao(const ATermo: string): TObjectList<TProduto>;
    function ListarTodos: TObjectDictionary<Integer, TProduto>;
    procedure LimparCache;
  end;

implementation

uses
  StrUtils, wk.factory.model;

{ TProdutoRepository }

constructor TProdutoRepository.Create(AConn: TFDConnection);
begin
  FConn := AConn;
  FCache := TObjectDictionary<Integer, TProduto>.Create([doOwnsValues]);
end;

destructor TProdutoRepository.Destroy;
begin
  FCache.Free;
  inherited;
end;

function TProdutoRepository.BuscarPorId(AId: Integer): TProduto;
var
  LQuery: TFDQuery;
begin
  if FCache.TryGetValue(AId, Result) then
    Exit;

  LQuery := TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := TProdutoSQL.SelectById;
    LQuery.ParamByName('id').AsInteger := AId;
    LQuery.Open;

    if LQuery.IsEmpty then
    begin
      Result := nil;
      Exit;
    end;

    Result := DataSetToModel(LQuery);
    FCache.Add(Result.id_produto, Result);

  finally
    LQuery.Free;
  end;
end;

function TProdutoRepository.BuscarPorDescricao(const ATermo: string): TObjectList<TProduto>;
var
  LProduto: TProduto;
  LResultado: TObjectList<TProduto>;
begin
  if FCache.Count = 0 then
    ListarTodos;

  LResultado := TObjectList<TProduto>.Create(False);
  for LProduto in FCache.Values do
    if ContainsText(LProduto.Descricao, ATermo) then
      LResultado.Add(LProduto);
  Result := LResultado;
end;

function TProdutoRepository.ListarTodos: TObjectDictionary<Integer, TProduto>;
var
  LQuery: TFDQuery;
  LProduto: TProduto;
begin
  if FCache.Count > 0 then
    Exit(FCache);

  LQuery:= TFDQuery.Create(nil);
  try
    LQuery.Connection := FConn;
    LQuery.SQL.Text := TProdutoSQL.LoadAll;
    LQuery.Open;

    while not LQuery.Eof do
    begin
      LProduto := DataSetToModel(LQuery);
      FCache.AddOrSetValue(LProduto.id_produto, LProduto);
      LQuery.Next;
    end;
  finally
    LProduto.Free;
  end;

  Result := FCache;
end;

procedure TProdutoRepository.LimparCache;
begin
  FCache.Clear;
end;

function TProdutoRepository.DataSetToModel(ADataSet: TDataSet): TProduto;
begin
  Result := TModelFactory.ProdutoFromDataset(ADataSet);
end;

end.

